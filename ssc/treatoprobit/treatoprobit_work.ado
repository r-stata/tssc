capture program drop _all
program define treatoprobit_work, eclass

local gradient 
global neqs = 3+$ncut
forvalues i = 1/$neqs {
	local gradient "`gradient' g`i'"
	}



args todo b lnfj `gradient' H 
tempvar eta1 eta2 
tempname r 
forvalues i = 1/$ncut {
	tempname c`i'
	}

mleval `eta1' = `b', eq(1)
mleval `eta2' = `b', eq(2)
mleval  `r' = `b', eq(3) scalar
forvalues i = 1/$ncut {
	local j = 3+`i'
	mleval `c`i'' = `b', eq(`j') scalar
}



local rho = (tanh(`r'))
qui levelsof($ML_y2)
global nchoices: word count `r(levels)'


local imat0
local imat1
forvalues i = 1/$nchoices {
	local j = `i'+$nchoices
	tempvar m0`i' m1`i' ll`i' ll`j' 	
	qui g double `m0`i'' = $ML_y1==0 & $ML_y2==`i'
	qui g double `m1`i'' = $ML_y1==1 & $ML_y2==`i'
	qui g double `ll`i'' = 0
	qui g double `ll`j'' = 0
	local imat0 "`imat0' `m0`i''"
	local imat1 "`imat1' `m1`i''"
	}
local imat `imat0' `imat1'	

local neginf = minfloat()
local posinf = maxfloat()

tempname cutpts0 cutpts0r cutptst
mat `cutpts0' = J(1,$ncut,0)
forvalues i = 1/$ncut {
	mat `cutpts0'[1,`i'] = `c`i''
	}
mat `cutpts0r' = `neginf', `cutpts0', `posinf'
mat `cutptst' = `neginf', 0, `posinf'

tempname fv_tmp
qui g double `fv_tmp'=0
local count 0
forv d = 0/1 {
	local e = `d'+2
	local f = `d'+1
	local cut_h1 = `cutptst'[1,`e']
	local cut_l1 = `cutptst'[1,`f']
	forv i = 1/$nchoices {
		local `++count'
		local k = `i'+1
		local cut_h2 = `cutpts0r'[1,`k']
		local cut_l2 = `cutpts0r'[1,`i']
		qui replace `ll`count'' = `m`d'`i''*(((binorm(`cut_h1'-`eta1',`cut_h2'-`eta2',`rho'))- ///
			(binorm(`cut_l1'-`eta1',`cut_h2'-`eta2',`rho'))-(binorm(`cut_h1'-`eta1',`cut_l2'-`eta2',`rho'))+ ///
			(binorm(`cut_l1'-`eta1',`cut_l2'-`eta2',`rho'))))
			qui replace `fv_tmp' = `fv_tmp'+`ll`count''
		}
}

qui replace `lnfj' = ln(`fv_tmp')

if (`todo'==0 | `lnfj'==.) exit

local gradfun
forv i = 1/$neqs {
	tempvar g`i'_tmp
	qui g double `g`i'_tmp'=0
	local gradfun "`gradfun' `g`i'_tmp'"
}


local r_init = `rho'

mata: mata_gradfun_sobiprobit("`eta1'", "`eta2'", "`cutpts0r'", "`cutptst'", ///
	 "`r_init'", "`imat'", "`lnfj'","`gradfun'")


	 
local gfun	 
forvalues i = 1/$neqs {
	qui replace `g`i''=`g`i'_tmp'
	local gfun "`gfun' `g`i''"
	 }



if (`todo'==1) exit

local hess
forv i = 1/3 {
	forv j = `i'/$neqs {
		tempvar g`i'`j'_tmp
		qui g double `g`i'`j'_tmp'=0
		local hess "`hess' `g`i'`j'_tmp'"
		}
	}
forvalues i = 4/$neqs{
	tempvar g`i'`i'_tmp
	qui g double `g`i'`i'_tmp'=0
	local hess "`hess' `g`i'`i'_tmp'"
	}

global offdiag = $neqs-1
forvalues i = 4/$offdiag {
	local j = `i'+1
	tempvar g`i'`j'_tmp
	qui g double `g`i'`j'_tmp'=0
	local hess "`hess' `g`i'`j'_tmp'"
	} 

mata: mata_hessfun_sobiprobit("`eta1'", "`eta2'", "`cutpts0r'", "`cutptst'", ///
	"`r_init'", "`imat'", "`lnfj'", "`touse'", "`gfun'", "`hess'")

forv i = 1/$neqs {
	forv j= `i'/$neqs {
		tempname g`i'`j'
		}	
}
mlmatsum `lnfj' `g11' = `g11_tmp', eq(1)
forv i = 2/$neqs {
	mlmatsum `lnfj' `g1`i'' = `g1`i'_tmp', eq(1,`i')
	}
mlmatsum `lnfj' `g22' = `g22_tmp', eq(2)
forv i = 2/$neqs {
	mlmatsum `lnfj' `g2`i'' = `g2`i'_tmp', eq(2,`i')
	}
mlmatsum `lnfj' `g33' = `g33_tmp', eq(3)
forv i = 3/$neqs {
	mlmatsum `lnfj' `g3`i'' = `g3`i'_tmp', eq(3,`i')
	}
forv i = 4/$neqs {
	forv j = 4/$neqs {
		if `i'==`j' {
			mlmatsum `lnfj' `g`i'`j'' = `g`i'`j'_tmp', eq(`i')
			}
	  	if `i'==`j'-1 {
			mlmatsum `lnfj' `g`i'`j'' = `g`i'`j'_tmp', eq(`i',`j')
			}
		else  {
			continue
			}
		}
	}

*form hessian matrix*	
tempname H1 H2 H3 A B C d O 

mat `A' = `g11', `g12', `g13'\ `g12'', `g22', `g23'\ `g13'', `g23'', `g33'
mat `H1' = `g14'
mat `H2' = `g24'
mat `H3' = `g34'
forvalues i = 5/$neqs {
	mat `H1' = nullmat(`H1'), `g1`i''
	mat `H2' = nullmat(`H2'), `g2`i''
	mat `H3' = nullmat(`H3'), `g3`i''
	}
mat `B' = nullmat(`H1') \ `H2'
mat `B' = nullmat(`B') \ `H3'

mat `d' = `g44'
forv i = 5/$neqs {
	mat `d' = nullmat(`d'), `g`i'`i'' 	
	}
mat `C' = diag(`d')

global cutM1 = $ncut-1
mat `O' = J(rowsof(`C'),colsof(`C'),0)

forv i = 1/$cutM1 {
	forv j = 2/$ncut {
		 if `i'==`j'-1 {
			local m = `i'+3
			local n = `j'+3 
			mat `O'[`j',`i']=`g`m'`n''
			mat `O'[`i',`j']=`g`m'`n''
			
		}
		else {
			continue
		}
	}
}

mat `C' = `C'+`O'


*hessian
mat `H' = `A', `B' \ `B'', `C'



end

mata:
void mata_gradfun_sobiprobit(string scalar xb1, string scalar xb2, string scalar cutpts0r, ///
		string scalar cutptst, string scalar r, string scalar indmat, string scalar llike, ///
		string scalar gfunout)
{
		
		n = st_nobs()
		real matrix gradfun, imat
		real colvector eta1, eta2, lnlike 
		real scalar rho
	
		st_view(eta1,.,xb1)
		st_view(eta2,.,xb2)
		st_view(imat,.,tokens(indmat))
		st_view(lnlike,.,llike)
		cg = cols(tokens(gfunout))
		
		
		rho =(strtoreal(r))
		cutpts0r = st_matrix(cutpts0r)
		cutptst = st_matrix(cutptst)
		fvi = exp(lnlike)
				
		//lnfvisum = sum(lnlike)
		//printf("Log Like = %9.2f\n", lnfvisum)
		
		ci = cols(imat)
		//printf("ci=%2.0f \n", ci)
		choices = ci/2
		//printf("rho = %3.2f \n", rho)
		neqs = 3+(choices-1)
		gradfun = J(n,neqs,0)
		gradfun_1 = J(n,ci,0)
		gradfun_2 = J(n,ci,0)
		delta = sqrt(1-rho^2)
		//printf("delta = %3.2f \n", delta)
		/*derivatives wrt to beta1 and beta2*/
		for(i=1;i<=2;i++) {
			cut_h1 = cutptst[1,i+1]
			cut_l1 = cutptst[1,i]
			A1p1 = cut_h1:-eta1
			A1 = cut_l1:-eta1
			for(j=1;j<=choices;j++){
				k = ((i-1)*choices)+ j	
				cut_h2 = cutpts0r[1,j+1]
				cut_l2 = cutpts0r[1,j]
				A2p1 = cut_h2:-eta2
				A2 = cut_l2:-eta2
				gradfun_1[.,k]=(normalden(A1p1):*(normal((A2p1:-rho:*A1p1):/(delta)))):- ///
					(normalden(A1):*(normal((A2p1:-rho:*A1):/(delta)))):-	///
					(normalden(A1p1):*(normal((A2:-rho:*A1p1):/(delta)))):+ ///
					(normalden(A1):*(normal((A2:-rho:*A1):/(delta))))
				gradfun_2[.,k]=normalden(A2p1):*(normal((A1p1:-rho:*A2p1):/(delta))):- ///
						normalden(A2):*(normal((A1p1:-rho:*A2):/(delta))):-	///
						normalden(A2p1):*(normal((A1:-rho:*A2p1):/(delta))):+ ///
						normalden(A2):*(normal((A1:-rho:*A2):/(delta)))
				}
			}
		
		gradfun[.,1]=(-1):*rowsum(imat:*gradfun_1):/fvi
		gradfun[.,2]=(-1):*rowsum(imat:*gradfun_2):/fvi	
		/*derivatives wrt r, rho*/
		gradfun_3 = J(n,ci,0)
		gamma = (1-rho^2)
		nu = 1/sqrt(gamma)
		
		zeta = ((2*pi())*sqrt(1-rho^2))^-1
		for(i=1;i<=2;i++) {
			cut_h1 = cutptst[1,i+1]
			cut_l1 = cutptst[1,i]
			A1p1 = cut_h1:-eta1
			A1 = cut_l1:-eta1
			for(j=1;j<=choices;j++){
				k = ((i-1)*choices)+ j	
				cut_h2 = cutpts0r[1,j+1]
				cut_l2 = cutpts0r[1,j]
				A2p1 = cut_h2:-eta2
				A2 = cut_l2:-eta2
				gradfun_3[.,k]=(exp((-.5):*(((A1p1:^2):+(A2p1:^2):-(rho:*A1p1:*A2p1:*2)):/gamma)):- ///
					exp((-.5):*(((A1:^2):+(A2p1:^2):-(rho:*A1:*A2p1:*2)):/gamma)):- ///
					exp((-.5):*(((A1p1:^2):+(A2:^2):-(rho:*A1p1:*A2:*2)):/gamma)):+ ///
					exp((-.5):*(((A1:^2):+(A2:^2):-(rho:*A1:*A2:*2)):/gamma))) //:*zeta
				}
			}	
		rr = atanh(rho) //strtoreal(r)
		drho_dr = 1/(cosh(rr)^2) // derivative of rho wrt r
		gradscalar = drho_dr*zeta
		gradfun[.,3] = gradscalar:*((rowsum(imat:*gradfun_3)):/fvi)
		ncuts = choices-1
		gradfun_4_tmp = J(n,ci,0)
		gradfun_4 = J(n,ncuts,.)
		for(i=1;i<=ncuts;i++){
			for(j=1;j<=2;j++){
				cut_h1 = cutptst[1,j+1]
				cut_l1 = cutptst[1,j]
				A1p1 = cut_h1:-eta1
				A1 = cut_l1:-eta1
				for(k=1;k<=choices;k++){
					q = ((j-1)*choices)+ k
					delta_kj1 = (i==k)
					delta_kj = (i==k-1)
					cut_h2 = cutpts0r[1,k+1]
					cut_l2 = cutpts0r[1,k]
					A2p1 = cut_h2:-eta2
					A2 = cut_l2:-eta2
					gradfun_4_tmp[.,q]=((normal((A1p1:-rho:*A2p1):/delta):-normal((A1:-rho:*A2p1):/delta)):*normalden(A2p1):*delta_kj1):- ///
						((normal((A1p1:-rho:*A2):/delta):-normal((A1:-rho:*A2):/delta)):*normalden(A2):*delta_kj)
				}
			}
			
			gradfun_4[.,i] = (rowsum(imat:*gradfun_4_tmp)):/fvi
		}
		gradfun[|1,4\n,cols(gradfun)|]=gradfun_4
		st_store(.,(tokens(gfunout)),gradfun)		
		
		
}




void mata_hessfun_sobiprobit(string scalar xb1, string scalar xb2, string scalar cutpts0r, ///
		string scalar cutptst, string scalar r, string scalar indmat, string scalar llike, ///
		string scalar touse, string scalar gfunin, string scalar hess)
		
{
		n = st_nobs()
		real matrix gradfun, imat
		real colvector eta1, eta2, lnlike 
		real scalar rho
		
		//touse = st_data(.,tokens(touse))
		eta1=st_data(.,xb1,touse)
		eta2=st_data(.,xb2,touse)
		imat=st_data(.,tokens(indmat),touse)
		lnlike=st_data(.,llike,touse)
		cg = cols(tokens(gfunin))
		gradfunc = st_data(., tokens(gfunin),touse)
		z = cols(gradfunc)
		/*gradients*/
		g1 = gradfunc[.,1]
		g2 = gradfunc[.,2]
		g3 = gradfunc[.,3]
		g4 = gradfunc[|1,4\n,z|]
		/*matrix to store hessian*/
		hess_c = cols(tokens(hess))
		hessfun = J(n,hess_c,0)
		
		rho = strtoreal(r)
		cutpts0r = st_matrix(cutpts0r)
		cutptst = st_matrix(cutptst)
		
		fvi = exp(lnlike)
		fvi2 = fvi:^2
		//lnfvisum = sum(lnlike)
		//printf("Log Like = %9.2f\n", lnfvisum)
		
		ci = cols(imat)
		choices = ci/2
		neqs = 3+(choices-1)
		gradfun = J(n,neqs,0)
			
		gamma = 1-rho^2	
		delta = (sqrt(1-rho^2))^-1
		/*g11*/
		zeta = ((2*pi())*sqrt(1-rho^2))^-1
		g11 = J(n,1,0)
		gh11 = J(n,ci,0)
		gh11_1 = J(n,ci,0)
		gh11_2 = J(n,ci,0)
		gh11_3 = J(n,ci,0)
		gh11_4 = J(n,ci,0)
		for(i=1;i<=2;i++) {
			cut_h1 = cutptst[1,i+1]
			cut_l1 = cutptst[1,i]
			A1p1 = (cut_h1:-eta1)
			A1 = (cut_l1:-eta1)
			for(j=1;j<=choices;j++){
				k = ((i-1)*choices)+ j
				cut_h2 = cutpts0r[1,j+1]
				cut_l2 = cutpts0r[1,j]
				A2p1 = cut_h2:-eta2
				A2 = cut_l2:-eta2
				gh11_1[.,k]=zeta:*(exp((-.5):*(((A1p1:^2):+(A2p1:^2):-(rho:*A1p1:*A2p1:*2)):/gamma))):*(-rho):+ ///
					normal((A2p1:-rho:*A1p1):*delta):*normalden(A1p1):*(-A1p1)
				gh11_2[.,k]=zeta:*(exp((-.5):*(((A1:^2):+(A2p1:^2):-(rho:*A1:*A2p1:*2)):/gamma))):*(-rho):+ ///
					normal((A2p1:-rho:*A1):*delta):*normalden(A1):*(-A1)
				gh11_3[.,k]=zeta:*(exp((-.5):*(((A1p1:^2):+(A2:^2):-(rho:*A1p1:*A2:*2)):/gamma))):*(-rho):+ ///
					normal((A2:-rho:*A1p1):*delta):*normalden(A1p1):*(-A1p1)
				gh11_4[.,k]=zeta:*(exp((-.5):*(((A1:^2):+(A2:^2):-(rho:*A1:*A2:*2)):/gamma))):*(-rho):+ ///
					normal((A2:-rho:*A1):*delta):*normalden(A1):*(-A1)	
				gh11[.,k] = gh11_1[.,k]:-gh11_2[.,k]:-gh11_3[.,k]:+gh11_4[.,k]	
				}
			}
		g11 = ((rowsum(imat:*gh11)):/fvi - (g1:^2))
		/*g12*/
		zeta = ((2*pi())*sqrt(1-rho^2))^-1
		g12 = J(n,1,0)
		gh12 = J(n,ci,0)
		gh12_1 = J(n,ci,0)
		gh12_2 = J(n,ci,0)
		gh12_3 = J(n,ci,0)
		gh12_4 = J(n,ci,0)
		for(i=1;i<=2;i++) {
			cut_h1 = cutptst[1,i+1]
			cut_l1 = cutptst[1,i]
			A1p1 = cut_h1:-eta1
			A1 = cut_l1:-eta1
			for(j=1;j<=choices;j++){
				k = ((i-1)*choices)+ j	
				cut_h2 = cutpts0r[1,j+1]
				cut_l2 = cutpts0r[1,j]
				A2p1 = cut_h2:-eta2
				A2 = cut_l2:-eta2
				/*gh12_1[.,k]=normalden(A1p1):*normalden((A2p1:-rho:*A1p1):*delta)
				gh12_2[.,k]=normalden(A1):*normalden((A2p1:-rho:*A1):*delta)
				gh12_3[.,k]=normalden(A1p1):*normalden((A2:-rho:*A1p1):*delta)
				gh12_4[.,k]=normalden(A1):*normalden((A2:-rho:*A1):*delta)*/
				gh12_1[.,k]=exp((-.5):*(((A1p1:^2):+(A2p1:^2):-(rho:*A1p1:*A2p1:*2)):/gamma))
				gh12_2[.,k]=exp((-.5):*(((A1:^2):+(A2p1:^2):-(rho:*A1:*A2p1:*2)):/gamma))
				gh12_3[.,k]=exp((-.5):*(((A1p1:^2):+(A2:^2):-(rho:*A1p1:*A2:*2)):/gamma))
				gh12_4[.,k]=exp((-.5):*(((A1:^2):+(A2:^2):-(rho:*A1:*A2:*2)):/gamma))
				gh12[.,k] = (gh12_1[.,k]:-gh12_2[.,k]:-gh12_3[.,k]:+gh12_4[.,k]):*zeta
				}
			}	
		g12 = ((rowsum(imat:*gh12)):/fvi):-((g1:*g2))
		sigma = (1-rho^2)^(-3/2)
		rr = atanh(rho)
		drho_dr = 1/((cosh(rr))^2) // derivative of rho wrt r
		
		/*g13*/
		g13 = J(n,1,0)
		gh13 = J(n,ci,0)
		gh13_1 = J(n,ci,0)
		gh13_2 = J(n,ci,0)
		gh13_3 = J(n,ci,0)
		gh13_4 = J(n,ci,0)
		for(i=1;i<=2;i++) {
			cut_h1 = cutptst[1,i+1]
			cut_l1 = cutptst[1,i]
			A1p1 = cut_h1:-eta1
			A1 = cut_l1:-eta1
			for(j=1;j<=choices;j++){
				k = ((i-1)*choices)+ j	
				cut_h2 = cutpts0r[1,j+1]
				cut_l2 = cutpts0r[1,j]
				A2p1 = cut_h2:-eta2
				A2 = cut_l2:-eta2
				gh13_1[.,k]=-normalden(A1p1):*normalden((A2p1:-rho:*A1p1):*delta):*((rho:*A2p1:-A1p1):*sigma)
				gh13_2[.,k]=-normalden(A1):*normalden((A2p1:-rho:*A1):*delta):*((rho:*A2p1:-A1):*sigma)
				gh13_3[.,k]=-normalden(A1p1):*normalden((A2:-rho:*A1p1):*delta):*((rho:*A2:-A1p1):*sigma)
				gh13_4[.,k]=-normalden(A1):*normalden((A2:-rho:*A1):*delta):*((rho:*A2:-A1):*sigma)
				gh13[.,k] = (gh13_1[.,k]:-gh13_2[.,k]:-gh13_3[.,k]:+gh13_4[.,k]	):*drho_dr
				}
			}
		  g13 = ((rowsum(imat:*gh13)):/fvi):-((g1:*g3))
		  ncuts = choices-1
		  /*g14*/
			g14 = J(n,ncuts,.)
			g14_tmp = J(n,ncuts,0)
			for(i=1;i<=ncuts;i++){
			gh14 = J(n,ci,0)
			gh14_1 = J(n,ci,0)
			gh14_2 = J(n,ci,0)
			gh14_3 = J(n,ci,0)
			gh14_4 = J(n,ci,0)
			for(j=1;j<=2;j++){
				cut_h1 = cutptst[1,j+1]
				cut_l1 = cutptst[1,j]
				//printf("cut_l1=%4.3f \n",cut_l1)
				A1p1 = cut_h1:-eta1
				A1 = cut_l1:-eta1
				for(k=1;k<=choices;k++){
					q = ((j-1)*choices)+ k
					delta_kj1 = (i==k)
					delta_kj = (i==k-1)
					cut_h2 = cutpts0r[1,k+1]
					cut_l2 = cutpts0r[1,k]
					A2p1 = cut_h2:-eta2
					A2 = cut_l2:-eta2
					gh14_1[.,q]=((normalden(A1p1):*normalden((A2p1:-rho:*A1p1):*delta)):*delta):*delta_kj1
					gh14_2[.,q]=((normalden(A1):*normalden((A2p1:-rho:*A1):*delta)):*delta):*delta_kj1
					gh14_3[.,q]=((normalden(A1p1):*normalden((A2:-rho:*A1p1):*delta)):*delta):*delta_kj
					gh14_4[.,q]=((normalden(A1):*normalden((A2:-rho:*A1):*delta)):*delta):*delta_kj   
					gh14[.,q] = (-gh14_1[.,q]:+gh14_2[.,q]:+gh14_3[.,q]:-gh14_4[.,q]) //minus sign for zeros
					}
				}
			g14_tmp[.,i] = (rowsum(imat:*gh14)):/fvi
			}
			g14= g14_tmp:-(g1:*g4)
		/*g22*/
		g22 = J(n,1,0)
		gh22 = J(n,ci,0)
		gh22_1 = J(n,ci,0)
		gh22_2 = J(n,ci,0)
		gh22_3 = J(n,ci,0)
		gh22_4 = J(n,ci,0)
		for(i=1;i<=2;i++) {
			cut_h1 = cutptst[1,i+1]
			cut_l1 = cutptst[1,i]
			A1p1 = cut_h1:-eta1
			A1 = cut_l1:-eta1
			for(j=1;j<=choices;j++){
				k = ((i-1)*choices)+ j	
				cut_h2 = cutpts0r[1,j+1]
				cut_l2 = cutpts0r[1,j]
				A2p1 = cut_h2:-eta2
				A2 = cut_l2:-eta2
				gh22_1[.,k]=zeta:*(exp((-.5):*(((A1p1:^2):+(A2p1:^2):-(rho:*A1p1:*A2p1:*2)):/gamma))):*(-rho):+ ///
					normal((A1p1:-rho:*A2p1):*delta):*normalden(A2p1):*(-A2p1)
				gh22_2[.,k]=zeta:*(exp((-.5):*(((A1:^2):+(A2p1:^2):-(rho:*A1:*A2p1:*2)):/gamma))):*(-rho):+ ///
					normal((A1:-rho:*A2p1):*delta):*normalden(A2p1):*(-A2p1)
				gh22_3[.,k]=zeta:*(exp((-.5):*(((A1p1:^2):+(A2:^2):-(rho:*A1p1:*A2:*2)):/gamma))):*(-rho):+ ///
					normal((A1p1:-rho:*A2):*delta):*normalden(A2):*(-A2)
				gh22_4[.,k]=zeta:*(exp((-.5):*(((A1:^2):+(A2:^2):-(rho:*A1:*A2:*2)):/gamma))):*(-rho):+ ///
					normal((A1:-rho:*A2):*delta):*normalden(A2):*(-A2)	
				gh22[.,k] = gh22_1[.,k]:-gh22_2[.,k]:-gh22_3[.,k]:+gh22_4[.,k]	
				}
			}
		g22 = ((rowsum(imat:*gh22)):/fvi - (g2:^2))
		/*g23*/
		//printf("drho_dr = %3.2f \n", drho_dr)
		sigma = (1-rho^2)^-1
		g23 = J(n,1,0)
		gh23 = J(n,ci,0)
		gh23_1 = J(n,ci,0)
		gh23_2 = J(n,ci,0)
		gh23_3 = J(n,ci,0)
		gh23_4 = J(n,ci,0)
		for(i=1;i<=2;i++) {
			cut_h1 = cutptst[1,i+1]
			cut_l1 = cutptst[1,i]
			A1p1 = cut_h1:-eta1
			A1 = cut_l1:-eta1
			for(j=1;j<=choices;j++){
				k = ((i-1)*choices)+ j	
				cut_h2 = cutpts0r[1,j+1]
				cut_l2 = cutpts0r[1,j]
				A2p1 = cut_h2:-eta2
				A2 = cut_l2:-eta2
				gh23_1[.,k]=-zeta:*(exp((-.5):*(((A1p1:^2):+(A2p1:^2):-(rho:*A1p1:*A2p1:*2)):/gamma))):*((rho:*A1p1:-A2p1):*sigma)
				gh23_2[.,k]=-zeta:*(exp((-.5):*(((A1:^2):+(A2p1:^2):-(rho:*A1:*A2p1:*2)):/gamma))):*((rho:*A1:-A2p1):*sigma)
				gh23_3[.,k]=-zeta:*(exp((-.5):*(((A1p1:^2):+(A2:^2):-(rho:*A1p1:*A2:*2)):/gamma))):*((rho:*A1p1:-A2):*sigma)
				gh23_4[.,k]=-zeta:*(exp((-.5):*(((A1:^2):+(A2:^2):-(rho:*A1:*A2:*2)):/gamma))):*((rho:*A1:-A2):*sigma)
				gh23[.,k] = (gh23_1[.,k]:-gh23_2[.,k]:-gh23_3[.,k]:+gh23_4[.,k]):*drho_dr
				}
			}
			 
		  g23 = ((rowsum(imat:*gh23)):/fvi):-((g2:*g3))	
		  
         /*g24*/
         g24 = J(n,ncuts,.)
			for(i=1;i<=ncuts;i++){
			gh24 = J(n,ci,0)
			gh24_1 = J(n,ci,0)
			gh24_2 = J(n,ci,0)
			gh24_3 = J(n,ci,0)
			gh24_4 = J(n,ci,0)
			for(j=1;j<=2;j++){
				cut_h1 = cutptst[1,j+1]
				cut_l1 = cutptst[1,j]
				A1p1 = cut_h1:-eta1
				A1 = cut_l1:-eta1
				for(k=1;k<=choices;k++){
					q = ((j-1)*choices)+ k
					delta_kj1 = (i==k)
					delta_kj = (i==k-1)
					cut_h2 = cutpts0r[1,k+1]
					cut_l2 = cutpts0r[1,k]
					A2p1 = cut_h2:-eta2
					A2 = cut_l2:-eta2
					gh24_1[.,q]=((normalden(A1p1):*normalden((A2p1:-rho:*A1p1):*delta):*-rho*delta):+ /// 
						(normal((A1p1:-rho:*A2p1):*delta):*normalden(A2p1):*(-A2p1))):*delta_kj1
					gh24_2[.,q]=((normalden(A1):*normalden((A2p1:-rho:*A1):*delta):*-rho*delta):+ ///
						(normal((A1:-rho:*A2p1):*delta):*normalden(A2p1):*(-A2p1))):*delta_kj1
					gh24_3[.,q]=((normalden(A1p1):*normalden((A2:-rho:*A1p1):*delta):*-rho*delta)+ ///
						(normal((A1p1:-rho:*A2):*delta):*normalden(A2):*(-A2))):*delta_kj
					gh24_4[.,q]=((normalden(A1):*normalden((A2:-rho:*A1):*delta):*-rho*delta):+ ///
						(normal((A1:-rho:*A2):*delta):*normalden(A2):*(-A2))):*delta_kj    
					gh24[.,q] = -gh24_1[.,q]:+gh24_2[.,q]:+gh24_3[.,q]:-gh24_4[.,q]	
					}
			}
			g24[.,i] = ((rowsum(imat:*gh24)):/fvi)
		}
		g24 = g24:-((g2:*g4))
        /*g33*/
		  
        rr=atanh(rho)
		zeta = ((2*pi())*sqrt(1-rho^2))^-1
        zetainv = zeta^-1
		d2rho_d2r = -2*sinh(rr)/cosh(rr)^3  //-2*tanh(rr)/cosh(rr)^3 //8*exp(2*`r')*(1-exp(2*`r'))/(1+exp(2*`r'))^3
		d2zeta_d2r = rho/(2*pi()*((1-rho^2)^(3/2)))	//((-2*pi()*rho)/((1-rho^2)^(3/2)))
        drho_dr = 1/(cosh(rr)^2)
        gradscalar = drho_dr*zeta
		d2cons_d2r = zeta*d2rho_d2r+drho_dr^2*d2zeta_d2r		  
        gamma = (1-rho^2)
        g3k = (g3:*(zetainv):*(drho_dr^-1))
        g33 = J(n,1,0)
		  gh33 = J(n,ci,0)
		  gh33_1 = J(n,ci,0)
		  gh33_2 = J(n,ci,0)
		  gh33_3 = J(n,ci,0)
		  gh33_4 = J(n,ci,0)
		for(i=1;i<=2;i++) {
			cut_h1 = cutptst[1,i+1]
			cut_l1 = cutptst[1,i]
			A1p1 = cut_h1:-eta1
			A1 = cut_l1:-eta1
			for(j=1;j<=choices;j++){
				k = ((i-1)*choices)+ j	
				cut_h2 = cutpts0r[1,j+1]
				cut_l2 = cutpts0r[1,j]
				A2p1 = cut_h2:-eta2
				A2 = cut_l2:-eta2
				gh33_1[.,k]=(exp((-.5):*(((A1p1:^2):+(A2p1:^2):-(rho:*A1p1:*A2p1:*2)):/gamma)):* /// 
					(-.5:*((((-2:*A1p1:*A2p1):*gamma):+2:*rho:*((A1p1:^2)+(A2p1:^2)-2:*rho:*(A1p1:*A2p1))):/(gamma:^2)))) 
				gh33_2[.,k]=(exp((-.5):*(((A1:^2):+(A2p1:^2):-(rho:*A1:*A2p1:*2)):/gamma)):* ///
					(-.5:*((((-2:*A1:*A2p1):*gamma):+2:*rho:*((A1:^2)+(A2p1:^2)-2:*rho:*(A1:*A2p1))):/(gamma:^2)))) 
				gh33_3[.,k]=(exp((-.5):*(((A1p1:^2):+(A2:^2):-(rho:*A1p1:*A2:*2)):/gamma)):* ///
					(-.5:*((((-2:*A1p1:*A2):*gamma):+2:*rho:*((A1p1:^2)+(A2:^2)-2:*rho:*(A1p1:*A2))):/(gamma:^2)))) 
				gh33_4[.,k]=(exp((-.5):*(((A1:^2):+(A2:^2):-(rho:*A1:*A2:*2)):/gamma)):* ///
					(-.5:*((((-2:*A1:*A2):*gamma):+2:*rho:*((A1:^2)+(A2:^2)-2:*rho:*(A1:*A2))):/(gamma:^2))))
				gh33[.,k] = (gh33_1[.,k]:-gh33_2[.,k]:-gh33_3[.,k]:+gh33_4[.,k]):*drho_dr*gradscalar
				}
			}
		  g33 = ((((rowsum(imat:*gh33)):/fvi):-((g3:^2)))):+g3k:*d2cons_d2r
        /*g34*/
		 // printf("g34")
       	g34 = J(n,ncuts,.)
       
		for(i=1;i<=ncuts;i++){
			gh34 = J(n,ci,0)
			gh34_1 = J(n,ci,0)
			gh34_2 = J(n,ci,0)
			gh34_3 = J(n,ci,0)
			gh34_4 = J(n,ci,0)
			for(j=1;j<=2;j++){
				cut_h1 = cutptst[1,j+1]
				cut_l1 = cutptst[1,j]
				A1p1 = cut_h1:-eta1
				A1 = cut_l1:-eta1
				for(k=1;k<=choices;k++){
					q = ((j-1)*choices)+ k
					delta_kj1 = (i==k)
					delta_kj = (i==k-1)
					cut_h2 = cutpts0r[1,k+1]
					cut_l2 = cutpts0r[1,k]
					A2p1 = cut_h2:-eta2
					A2 = cut_l2:-eta2
					gh34_1[.,q]=(exp((-.5):*(((A1p1:^2):+(A2p1:^2):-(rho:*A1p1:*A2p1:*2)):/gamma)):* ///
						(-.5:*(((2:*A2p1):-(2:*rho:*A1p1)):/gamma))):*delta_kj1
					gh34_2[.,q]=(exp((-.5):*(((A1:^2):+(A2p1:^2):-(rho:*A1:*A2p1:*2)):/gamma)):* ///
						(-.5:*(((2:*A2p1):-(2:*rho:*A1)):/gamma))):*delta_kj1
					gh34_3[.,q]=(exp((-.5):*(((A1p1:^2):+(A2:^2):-(rho:*A1p1:*A2:*2)):/gamma)):* ///
						(-.5:*(((2:*A2):-(2:*rho:*A1p1)):/gamma))):*delta_kj
					gh34_4[.,q]=(exp((-.5):*(((A1:^2):+(A2:^2):-(rho:*A1:*A2:*2)):/gamma)):* ///
						(-.5:*(((2:*A2):-(2:*rho:*A1)):/gamma))):*delta_kj
					gh34[.,q] = (gh34_1[.,q]:-gh34_2[.,q]:-gh34_3[.,q]:+gh34_4[.,q]):*(zeta*drho_dr)
					}
			}
			g34[.,i] = ((rowsum(imat:*gh34)):/fvi)
		}
	 	g34 = g34:-((g3:*g4))
        /*g44*/
		//printf("g44")
      g44_diag = J(n,ncuts,.)
		for(i=1;i<=ncuts;i++){
			gh44 = J(n,ci,0)
			gh44_1 = J(n,ci,0)
			gh44_2 = J(n,ci,0)
			gh44_3 = J(n,ci,0)
			gh44_4 = J(n,ci,0)
			for(j=1;j<=2;j++){
				cut_h1 = cutptst[1,j+1]
				cut_l1 = cutptst[1,j]
				A1p1 = cut_h1:-eta1
				A1 = cut_l1:-eta1
				for(k=1;k<=choices;k++){
					q = ((j-1)*choices)+ k
					delta_kj1 = (i==k)
					delta_kj = (i==k-1)
					cut_h2 = cutpts0r[1,k+1]
					cut_l2 = cutpts0r[1,k]
					A2p1 = cut_h2:-eta2
					A2 = cut_l2:-eta2
					gh44_1[.,q]=(normalden(A2p1):*normalden((A1p1:-rho:*A2p1):*delta):*(-rho):+ ///
						normal((A1p1:-rho:*A2p1):*delta):*normalden(A2p1):*(-A2p1)):*delta_kj1
					gh44_2[.,q]=(normalden(A2p1):*normalden((A1:-rho:*A2p1):*delta):*(-rho):+ ///
						normal((A1:-rho:*A2p1):*delta):*normalden(A2p1):*(-A2p1)):*delta_kj1
					gh44_3[.,q]=(normalden(A2):*normalden((A1p1:-rho:*A2):*delta):*(-rho):+ ///
						normal((A1p1:-rho:*A2):*delta):*normalden(A2):*(-A2)):*delta_kj
					gh44_4[.,q]=(normalden(A2):*normalden((A1:-rho:*A2):*delta):*(-rho):+ ///
						normal((A1:-rho:*A2):*delta):*normalden(A2):*(-A2)):*delta_kj
					gh44[.,q] = gh44_1[.,q]:-gh44_2[.,q]:-gh44_3[.,q]:+gh44_4[.,q]	
					}
			}
			g44_diag[.,i] = ((rowsum(imat:*gh44)):/fvi)
		}
		g44_diag = g44_diag:-((g4:^2))
		/*g44 off diagonal*/
		zeros = J(n,1,0)
		offdiag=ncuts-1
      g44_od = J(n,offdiag,.)
		for(i=1;i<=offdiag;i++){
			t=i+1
			gh44 = J(n,ci,0)
			gh44_1 = J(n,ci,0)
			gh44_2 = J(n,ci,0)
			gh44_3 = J(n,ci,0)
			gh44_4 = J(n,ci,0)
			for(j=1;j<=2;j++){
				cut_h1 = cutptst[1,j+1]
				cut_l1 = cutptst[1,j]
				A1p1 = cut_h1:-eta1
				A1 = cut_l1:-eta1
				for(k=1;k<=choices;k++){
					q = ((j-1)*choices)+ k
					delta_kj1 = (i==k)
					delta_kj = (i==k-1)
					cut_h2 = cutpts0r[1,k+1]
					cut_l2 = cutpts0r[1,k]
					A2p1 = cut_h2:-eta2
					A2 = cut_l2:-eta2
					gh44_1[.,q]=(normalden(A2p1):*normalden((A1p1:-rho:*A2p1):*delta):*(-rho*delta):+ ///
						normal((A1p1:-rho:*A2p1):*delta):*normalden(A2p1):*(-A2p1)):*delta_kj
					gh44_2[.,q]=(normalden(A2p1):*normalden((A1:-rho:*A2p1):*delta):*(-rho*delta):+ ///
						normal((A1:-rho:*A2p1):*delta):*normalden(A2p1):*(-A2p1)):*delta_kj
					gh44_3[.,q]=(normalden(A2):*normalden((A1p1:-rho:*A2):*delta):*(-rho*delta):+ ///
						normal((A1p1:-rho:*A2):*delta):*normalden(A2):*(-A2)):*delta_kj1
					gh44_4[.,q]=(normalden(A2):*normalden((A1:-rho:*A2):*delta):*(-rho*delta):+ ///
						normal((A1:-rho:*A2):*delta):*normalden(A2):*(-A2)):*delta_kj1
					gh44[.,q] = gh44_1[.,q]:-gh44_2[.,q]:-gh44_3[.,q]:+gh44_4[.,q]	//- +  + -
					}
			}
			g44_od[.,i] = ((rowsum(imat:*gh44)):/fvi)
			g44_od[.,i] = zeros:-(g4[.,i]:*g4[.,t])
		}
		g44 = g44_diag, g44_od
		zeros = J(n,1,0)
		hessfun = g11, g12, g13, g14, g22, g23, g24, g33, g34, g44
        st_store(.,tokens(hess),hessfun)
		
}         
end





