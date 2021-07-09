/*
'xtpsse' runs a conditional fixed-effects Poisson Panel Regression, 
computes sandwich and spatial SE, and tests for time-invariant spatial
dependence according to Bertanha and Moser (2016)
For help, see xtpsse.sthlp
*/

/*
Marinho Bertanha, Version 05/01/2017
I'd appreciate your feedback: mbertanha@nd.edu
Some of the structure here was inspired by Tim Simcoe's xtpqml.ado command 
*/


program xtpsse, eclass
version 11

syntax varlist(numeric) [if] [in], COORDinates(varlist) CUToffs(numlist >0) [ I(varname num) T(varname num) TEst(integer -1)]

** Make sure user specifies cross-section ID variable AND time index variable
if length("`i'") == 0 {	
	local i = "`r(panelvar)'"
	if length("`i'") == 0 {
		di as error "You must specify a cross-section ID variable. Use i(varname) option or 'xtset' command."
		exit
	}
}

if length("`t'") == 0 {	
	local t = "`r(timevar)'"
	if length("`t'") == 0 {
		di as error "You must specify a time index variable. Use t(varname) option or 'xtset' command."
		exit
	}
}

** Dimension of both coordinates and cutoffs must be equal



if  wordcount("`coordinates'") != wordcount("`cutoffs'") {
	di as error "Number of coordinate variables is different than the number of cutoffs."
	exit
}

scalar K2 = `test'		
if K2==-1 {
	scalar K2=wordcount("`varlist'")-1
}


xtpoisson `varlist' `if' `in', fe i(`i') 

di as text "Computing Standard Errors..."




tempvar n_i xb_hat_it mu_hat_it sum_mu_i p_it u_it crossec crossec2 idsamp
tempname b 

quietly{
		matrix b = e(b)
		local varlist : colnames b

		bysort `i' : egen `n_i' = sum(`e(depvar)') if e(sample)	    
		predict `xb_hat_it', xb

		gen `mu_hat_it' = exp(`xb_hat_it') if e(sample)       	     
		by `i' : egen `sum_mu_i' = sum(`mu_hat_it') if e(sample)

		gen `p_it' =  `mu_hat_it' / `sum_mu_i' if e(sample)			      
		gen `u_it' = `e(depvar)' - `p_it'*`n_i' if e(sample)                    

		by `i' : egen `crossec' = min(`t') if e(sample)
		
		foreach v of var `coordinates' {
				tempvar cd_`v'
				gen `cd_`v'' = `v'
				replace `cd_`v'' = . if `t'!=`crossec'
				local cdnames `cdnames' `cd_`v''
				
		}
		
		foreach v of var `varlist' {
				tempvar sum_mu_`v' score_i_`v'
				by `i' : egen `sum_mu_`v'' = sum(`v'*`mu_hat_it') if e(sample)
				by `i': egen `score_i_`v'' = sum((`v' - (`sum_mu_`v''/`sum_mu_i')) * `u_it') if e(sample)
				replace `score_i_`v'' = . if `t'!=`crossec'
				local scorename `scorename' `score_i_`v''
		}
		
		** units that are not dropped in estimation
		by `i' : egen `crossec2' = min(`t')
		gen `idsamp' = `i' if e(sample)==0 & `t'==`crossec2'
 


		

}


mata: varcovar()


ereturn repost V = V_SW
di as result "Robust Standard Errors (Sandwich Formula)"
ereturn display



ereturn repost V = V_SP
di as result "Spatial Standard Errors"
ereturn display

if K2>0 {
	di as text "`msg1'"
	di as text "`msg2'"
	di as result "Null hypothesis of time-invariant spatial dependence"
	di as text "test-statistic: " as result T_hat
	di as text "p-value (Chi2 - " Kstar " df): " as result pval

}

end

mata:
void varcovar()
{
		K2=st_numscalar("K2")
		scorename=st_local("scorename")
		nameid=st_local("idsamp")
		A_hat = st_matrix("e(V)")
		idsamp = st_data(.,nameid,0)
		scores=st_data(.,scorename,0)
		nobs=rows(scores)
		nvars=cols(scores)
		cutoffs=strtoreal(tokens(st_local("cutoffs")))
		C_hat = J(nvars,nvars,0)

		
		coordinates = st_local("cdnames")
		coord=st_data(.,coordinates,0)
		nc=2

//***********************fits spatial coord into regular lattice coordinates
		dist=J(nobs*(nobs-1)/2,1,0)
		l=0
		for (i=1; i<=(nobs-1); i++) {
			for (j=(i+1); j<=nobs; j++) {
				temp=((coord[i,1]-coord[j,1])^2+(coord[i,2]-coord[j,2])^2)^.5
				if (temp>0) {
					l=l+1
					dist[l,1]=temp
				}
			}
		}
		dist=dist[1::l,.]
		dmin=0.95*min(dist)
		dstar=(sqrt(2)/2)*dmin
		
		coord2=J(nobs,2,0)
		spmin=(min(coord[.,1]),min(coord[.,2]))
		
		for (i=1; i<=nobs; i++) {
			coord2[i,.]=(floor( diag((1/dstar,1/dstar))*(coord[i,.]-spmin)')+(1\1))'
		}
		
		cutoffs2=round( diag((1/dstar,1/dstar))* cutoffs' )'
		
//*****************************************computes covariance matrix C_hat
		for (i=1; i<=nobs; i++) {
			for (j=1; j<=nobs; j++) {
				temp=abs(coord2[i,.]-coord2[j,.])

				if (temp<=cutoffs2) {
					prod=1

					if (min(cutoffs2)>0) {
					
						for (k=1; k<=nc; k++) {
							prod=prod*(1-temp[1,k]/cutoffs2[1,k])
						}
					}
					C_hat = C_hat + prod*scores[i,.]'*scores[j,.]

				}

			}	
				
		}
		
						
		V_SP=A_hat*C_hat*A_hat
		st_matrix("V_SP",V_SP)


		B_hat = J(nvars,nvars,0)

		for (i=1; i<=nobs; i++) {
				B_hat = B_hat + scores[i,.]'*scores[i,.]
		}

		V_SW=A_hat*B_hat*A_hat
		st_matrix("V_SW",V_SW)


//********************************************computes test-statistic

		if (K2>0) {
			st_local("msg1"," ")
			st_local("msg2"," ")

			Kstar=K2*(K2+1)/2
			spmomg=J(nobs,K2,0)
			for (i=1; i<=nobs; i++) {
			Nl=(2*cutoffs2[1]+1)*(2*cutoffs2[2]+1)-1
			
			
				for (j=1; j<=nobs; j++) {
					temp=abs(coord2[i,.]-coord2[j,.])
					
					if (i~=j && temp[1]<=cutoffs2[1] && temp[2]<=cutoffs2[2]) {
						//Ni=Ni+1
						spmomg[i,.]=spmomg[i,.]+scores[j,1::K2]
					}
					
		
				}

				spmomg[i,.]=(1/Nl)*spmomg[i,.]	
			
			}

			Z=J(nobs,1,NULL)
			A=J(Kstar,Kstar,0)

			
			for (i=1; i<=nobs; i++) {
				Z[i]=&J(Kstar,K2,0)
				l=1
				for (k=1; k<=K2; k++) {
					(*Z[i])[l::(l+k-1),k]=spmomg[i,1::k]'
					l=l+k
						
				}
				A=A+(*Z[i])*(*Z[i])'


		
			}
			Gamma=(-1/nobs)*A
			
			Omega = J(Kstar,Kstar,0)
			for (i=1; i<=nobs; i++) {		
				for (j=1; j<=nobs; j++) {
					temp=abs(coord2[i,.]-coord2[j,.])
					if (temp<=2*cutoffs2) {
						prod=1
						if (min(cutoffs2)>0) {

							for (k=1; k<=nc; k++) {
								prod=prod*(1-temp[1,k]/(2*cutoffs2[1,k]))
							}		
						}		
						Omega=Omega+(1/nobs)*prod*( (*Z[i]) * scores[i,1::K2]' )*( scores[j,1::K2]*(*Z[j])')
					}
				
				
				}	
			}
			
			if (min((rank(Gamma),rank(Omega)))<Kstar) {
				st_local("msg1","Cannot invert Gamma or Omega matrix using all elements of the score")
				
				while (min((rank(Gamma),rank(Omega)))<Kstar) {

					K2=min(  (  K2-1,floor((sqrt(1+8*nobs)-1)/2) ) ) 
					
					if (K2==0) {
						stata(`"di as error "Error computing test-statistic: Gamma or Omega is zero when using just one element of the score. Try to increase the cutoff.""')
					}
					Kstar=K2*(K2+1)/2;

					Z=J(nobs,1,NULL)
					A=J(Kstar,Kstar,0)

					
					for (i=1; i<=nobs; i++) {
						Z[i]=&J(Kstar,K2,0)
						l=1
						for (k=1; k<=K2; k++) {
							(*Z[i])[l::(l+k-1),k]=spmomg[i,1::k]'
							l=l+k
								
						}
						A=A+(*Z[i])*(*Z[i])'


				
					}
					Gamma=(-1/nobs)*A
					
					Omega = J(Kstar,Kstar,0)
					for (i=1; i<=nobs; i++) {		
						for (j=1; j<=nobs; j++) {
							temp=abs(coord2[i,.]-coord2[j,.])
							if (temp<=2*cutoffs2) {
								prod=1
								if (min(cutoffs2)>0) {

									for (k=1; k<=nc; k++) {
										prod=prod*(1-temp[1,k]/(2*cutoffs2[1,k]))
									}
								}
								Omega=Omega+(1/nobs)*prod*( (*Z[i]) * scores[i,1::K2]' )*( scores[j,1::K2]*(*Z[j])')
							}
						
						
						}	
					}				
					
				}
					
			}
				
			W=luinv(Gamma)*Omega*luinv(Gamma)

			
			B=J(Kstar,1,0);
			for (i=1; i<=nobs; i++) {
				B=B+(*Z[i])*scores[i,1::K2]'
			}

			Theta=luinv(A)*B
			T_hat = nobs*Theta'*luinv(W)*Theta
			pval=1-chi2(Kstar,T_hat)
			
			
			st_numscalar("T_hat",T_hat)
			st_numscalar("Kstar",Kstar)
			st_numscalar("pval",pval)
			st_numscalar("K2",K2)
			st_numscalar("nvars",nvars)
			
			if (K2<nvars) {
				st_local("msg2","Test-statistic computed using "+ strofreal(K2) +" out of "+ strofreal(nvars) +" element(s) of the score" )
			}
	}
}

end


