clear all

*sysdir set PERSONAL "C:\Users\yguyonvarch\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision"
*sysdir
*sysdir set PLUS "C:\Users\yguyonvarch\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision"
*sysdir



set more off

/************/
/*parameters*/
/************/

/*params that determine where to truncate V random variable between
treated and non-treated*/
scalar v11=0
scalar v00=1

/*parameters to generate (U_0,U_1,V) as trivariate normal(mu,Sigma).*/
scalar sigma0=1
scalar sigma1=1.2
scalar corr0=0.5
scalar corr1=-0.5
matrix Sigma=(sigma0,0,corr0\0,sigma1,corr1\corr0,corr1,sigma0)

local nb_sims=1000

/*****************/
/*Start the loops*/
/*****************/

forvalues j=0(1)2 {

	set seed `j'
	/* Sample sizes of 400, 800 and 1,600 */
	local nbobs=400 + 0.5* `j' *(`j'+1) * 400
	local obs_tot=`nbobs'*`nb_sims'
	
	quietly {
		set obs `obs_tot'

		gen G=(uniform()<=0.5)
		gen T=(uniform()<=0.5)
		
		drawnorm U0 U1 V, cov(Sigma) double
		
		gen D=(V>=v11) if G==1 & T==1
		replace D=(V>=v00) if D==.
		
		/*Y_d=h_d(U_d,T): pure location model*/
		gen Y0=U0+T+G
		gen Y1=1+U1+T+G
				
		/*observed outcome:*/
		gen Y=D*Y1+(1-D)*Y0

		drop U0 U1 V Y0 Y1

		gen DID_estim=.
		gen DID_l_ci=.
		gen DID_u_ci=.
		gen TC_estim=.
		gen TC_l_ci=.
		gen TC_u_ci=.
		gen CIC_estim=.
		gen CIC_l_ci=.
		gen CIC_u_ci=.
		gen LQTE1_estim=.
		gen LQTE1_l_ci=.
		gen LQTE1_u_ci=.
		gen LQTE2_estim=.
		gen LQTE2_l_ci=.
		gen LQTE2_u_ci=.
		gen LQTE3_estim=.
		gen LQTE3_l_ci=.
		gen LQTE3_u_ci=.

	}
	local iter1=1
	local iter2=`nbobs'

	forvalues i=1(1)`nb_sims' {
	
		quietly { 
			fuzzydid Y G T D in `iter1'/`iter2', did tc cic lqte breps(500)
			matrix a=e(b_LATE)
			matrix b=e(ci_LATE)
			replace DID_estim=a[1,1] in `i'
			replace DID_l_ci=b[1,1] in `i'
			replace DID_u_ci=b[1,2] in `i'
			
			replace TC_estim=a[2,1] in `i'
			replace TC_l_ci=b[2,1] in `i'
			replace TC_u_ci=b[2,2] in `i'
			
			replace CIC_estim=a[3,1] in `i'
			replace CIC_l_ci=b[3,1] in `i'
			replace CIC_u_ci=b[3,2] in `i'

			matrix c=e(b_LQTE)
			matrix d=e(ci_LQTE)
			replace LQTE1_estim=c[5,1] in `i'
			replace LQTE1_l_ci=d[5,1] in `i'
			replace LQTE1_u_ci=d[5,2] in `i'

			replace LQTE2_estim=c[10,1] in `i'
			replace LQTE2_l_ci=d[10,1] in `i'
			replace LQTE2_u_ci=d[10,2] in `i'
			
			replace LQTE3_estim=c[15,1] in `i'
			replace LQTE3_l_ci=d[15,1] in `i'
			replace LQTE3_u_ci=d[15,2] in `i'
		
		}
		
		local iter1=`iter1'+`nbobs'
		local iter2=`iter2'+`nbobs'
		
	}

	quietly { 
		gen DID_coverage=(DID_l_ci<=0.540138 & DID_u_ci>=0.540138) if DID_estim!=.
		gen TC_coverage=(TC_l_ci<=0.540138 & TC_u_ci>=0.540138) if TC_estim!=.
		gen CIC_coverage=(CIC_l_ci<=0.540138 & CIC_u_ci>=0.540138) if CIC_estim!=.
		gen LQTE1_coverage=(LQTE1_l_ci<=0.481 & LQTE1_u_ci>=0.481) if LQTE1_estim!=.
		gen LQTE2_coverage=(LQTE2_l_ci<=0.536 & LQTE2_u_ci>=0.536) if LQTE2_estim!=.
		gen LQTE3_coverage=(LQTE3_l_ci<=0.595 & LQTE3_u_ci>=0.595) if LQTE3_estim!=.
	}
	display "Number of observations: " `nbobs'
	su DID_estim TC_estim CIC_estim LQTE1_estim LQTE2_estim LQTE3_estim
	su DID_coverage TC_coverage CIC_coverage LQTE1_coverage LQTE2_coverage LQTE3_coverage
	
	clear
}
