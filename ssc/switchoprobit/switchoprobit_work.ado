capture program drop switchoprobit_work
program define switchoprobit_work, eclass

local gradient 
global neqs = 5+2*$ncut
forvalues i = 1/$neqs {
	local gradient "`gradient' g`i'"
	}


args todo b lnfj `gradient' //H
tempvar eta1 eta2_0 eta2_1
tempname r1 r0 
forvalues i = 1/$ncut {
	tempname c1`i'
	tempname c0`i'
	}

mleval `eta1' = `b', eq(1)
mleval `eta2_0' = `b', eq(2)
mleval `eta2_1' = `b', eq(3)
mleval `r0' = `b', eq(4) scalar
mleval `r1' = `b', eq(5) scalar

//di "ncut = $ncut"
local r 0
forvalues i = 0/1 {
	forvalues j = 1/$ncut {
		local `++r'
		local k = 5+`r'
		mleval `c`i'`j'' = `b', eq(`k') scalar
	}
}


local touse $touse

local rho0 = tanh(`r0')
local rho1 = tanh(`r1')

tempvar eta2i rhoi
qui g double `eta2i'=`eta2_0' if $ML_y1==0
qui replace `eta2i'=`eta2_1' if $ML_y1==1
qui g double `rhoi' = `rho0' if $ML_y1==0
qui replace `rhoi' = `rho1' if $ML_y1==1 


qui levelsof($ML_y2)
global nchoices: word count `r(levels)'

//local imat0
//local imat1
forvalues i = 1/$nchoices {
	//local j = `i'+$nchoices
	tempvar m0`i' m1`i' ll0`i' ll1`i' //ll`j' 	
	qui g double `m0`i'' = $ML_y1==0 & ($ML_y2==`i')
	qui g double `m1`i'' = $ML_y1==1 & ($ML_y3==`i')
	qui g double `ll0`i'' = 0
	qui g double `ll1`i'' = 0
	/*qui g double `ll`j'' = 0*/
	local imat0 "`imat0' `m0`i''"
	local imat1 "`imat1' `m1`i''"
	}
local imat `imat0' `imat1'	

local neginf = minfloat()
local posinf = maxfloat()

tempname cutpts0 cutpts1 cutptst
mat `cutpts0' = J(1,$ncut,0)
mat `cutpts1' = J(1,$ncut,0)
forvalues i = 1/$ncut {
	mat `cutpts0'[1,`i'] = `c0`i''
	mat `cutpts1'[1,`i'] = `c1`i''
	}
mat `cutpts0' = `neginf', `cutpts0', `posinf'
mat `cutpts1' = `neginf', `cutpts1', `posinf'
mat `cutptst' = `neginf', 0, `posinf'

tempname fv_tmp
qui g double `fv_tmp'=0
forv d = 0/1 {
	local e = `d'+2
	local f = `d'+1
	local cut_h1 = `cutptst'[1,`e']
	local cut_l1 = `cutptst'[1,`f']
	forv i = 1/$nchoices {
		local j = `i'+$nchoices
		local k = `i'+1
				local cut_h2 = `cutpts`d''[1,`k']
				local cut_l2 = `cutpts`d''[1,`i']
				qui replace `ll`d'`i'' = `m`d'`i''*(((binorm(`cut_h1'-`eta1',`cut_h2'-`eta2_`d'',`rho`d''))- ///
				(binorm(`cut_l1'-`eta1',`cut_h2'-`eta2_`d'',`rho`d''))-(binorm(`cut_h1'-`eta1',`cut_l2'-`eta2_`d'',`rho`d''))+ ///
				(binorm(`cut_l1'-`eta1',`cut_l2'-`eta2_`d'',`rho`d''))))
				qui replace `fv_tmp' = `fv_tmp'+`ll`d'`i''			
			}
	}


qui replace `lnfj' = ln(`fv_tmp')

if (`todo'==0) exit

local gradfun
forv i = 1/$neqs {
	tempvar g`i'_tmp
	qui g double `g`i'_tmp'=0 if `touse'
	local gradfun "`gradfun' `g`i'_tmp'"
}

local r_init_0 = tanh(`r0')
local r_init_1 = tanh(`r1')
tempname treat
qui g `treat' = $ML_y1

mata: mata_gradfun_switchoprobit("`eta1'", "`eta2_0'", "`eta2_1'", "`cutptst'", "`cutpts0'",  ///
	 "`cutpts1'", "`r_init_0'", "`r_init_1'", "`imat'", "`lnfj'", "`touse'", "`gradfun'")

	 
local gfun	 
	 forvalues i = 1/$neqs {
	 	qui replace `g`i''=`g`i'_tmp' if `touse'
	 	local gfun "`gfun' `g`i''"
	 	 }


if (`todo'==1) exit

end


mata:
void mata_gradfun_switchoprobit(string scalar xb1, string scalar xb2_0, string scalar xb2_1, ///
		string scalar cutptst, string scalar cutpts0, string scalar cutpts1, string scalar r0, ///
		string scalar r1, string scalar indmat, string scalar llike, string scalar touse, ///
		string scalar gfunout)
{
		
		n = st_nobs()
	
		real matrix gradfun, imat
		real colvector eta1, eta2_0, eta2_1, lnlike 
		real scalar rho1, rho0
		
		
		eta1=st_data(.,xb1,touse)
		eta2_0=st_data(.,xb2_0,touse)
		eta2_1=st_data(.,xb2_1,touse)
		imat=st_data(.,tokens(indmat),touse)
		lnlike=st_data(.,llike,touse)
		cg = cols(tokens(gfunout))
		
		rho0 = atanh(strtoreal(r0))
		rho1 = atanh(strtoreal(r1))
		//printf("rho0= %3.2f \n", rho0)
		//printf("rho1= %3.2f \n", rho1)
		
		cutpts_0 = st_matrix(cutpts0)
		cutpts_1 = st_matrix(cutpts1)
		cutpts_t = st_matrix(cutptst)
		fvi = exp(lnlike)
		
		ci = cols(imat)
		cc = ci/2
		
		imat0 = imat[|1,1\n,cc|]
		imat1 = imat[|1,cc+1\n,ci|]
		//printf("ci=%2.0f \n", ci)
		choices = ci/2
		//printf("choices = %2.0f \n", choices)
		neqs = 5+2*(choices-1)
		gradfun = J(n,neqs,0)
		gradfun_10 = J(n,cc,0)
		gradfun_11 = J(n,cc,0)
		gradfun_2 = J(n,cc,0)
		gradfun_3 = J(n,cc,0)
		delta0 = sqrt(1-rho0^2)
		delta1 = sqrt(1-rho1^2)
		/*derivatives wrt to beta1, beta2_0, and beta2_1*/
		cut_ht = cutpts_t[1,1]
		cut_lt = cutpts_t[1,2]
		Atp1 = cut_ht:-eta1
		At = cut_lt:-eta1
			for(j=1;j<=choices;j++){
				cut_h0 = cutpts_0[1,j+1]
				cut_l0 = cutpts_0[1,j]
				A0p1 = cut_h0:-eta2_0
				A0 = cut_l0:-eta2_0
		gradfun_10[.,j]=(normalden(Atp1):*(normal((A0p1:-rho0:*Atp1):/(delta0)))):- ///
					(normalden(At):*(normal((A0p1:-rho0:*At):/(delta0)))):-	///
					(normalden(Atp1):*(normal((A0:-rho0:*Atp1):/(delta0)))):+ ///
					(normalden(At):*(normal((A0:-rho0:*At):/(delta0))))
		gradfun_2[.,j]=normalden(A0p1):*(normal((Atp1:-rho0:*A0p1):/(delta0))):- ///
						normalden(A0):*(normal((Atp1:-rho0:*A0):/(delta0))):-	///
						normalden(A0p1):*(normal((At:-rho0:*A0p1):/(delta0))):+ ///
						normalden(A0):*(normal((At:-rho0:*A0):/(delta0)))
		}
		cut_ht = cutpts_t[1,2]
		cut_lt = cutpts_t[1,3]
		Atp1 = cut_ht:-eta1
		At = cut_lt:-eta1
			for(j=1;j<=choices;j++){
				cut_h1 = cutpts_1[1,j+1]
				cut_l1 = cutpts_1[j]
				A1p1 = cut_h1:-eta2_1
				A1 = cut_l1:-eta2_1
		gradfun_11[.,j]=(normalden(Atp1):*(normal((A1p1:-rho1:*Atp1):/(delta1)))):- ///
					(normalden(At):*(normal((A1p1:-rho1:*At):/(delta1)))):-	///
					(normalden(Atp1):*(normal((A1:-rho1:*Atp1):/(delta1)))):+ ///
					(normalden(At):*(normal((A1:-rho1:*At):/(delta1))))
		gradfun_3[.,j]=normalden(A1p1):*(normal((Atp1:-rho1:*A1p1):/(delta1))):- ///
						normalden(A1):*(normal((Atp1:-rho1:*A1):/(delta1))):-	///
						normalden(A1p1):*(normal((At:-rho1:*A1p1):/(delta1))):+ ///
						normalden(A1):*(normal((At:-rho1:*A1):/(delta1)))
		}
			
		gradfun[.,1]=((rowsum(imat1:*gradfun_11):/fvi):+(rowsum(imat0:*gradfun_10):/fvi))
		gradfun[.,2]=(rowsum(imat0:*gradfun_2):/fvi)	
		gradfun[.,3]=(rowsum(imat1:*gradfun_3):/fvi)
		/*derivatives wrt r's, rho's */
		gradfun_4 = J(n,cc,0)
		gradfun_5 = J(n,cc,0)
		gamma0 = (1-rho0^2)
		gamma1 = (1-rho1^2)
		nu0 = 1/sqrt(gamma0)
		nu1 = 1/sqrt(gamma1)
		zeta0 = ((2*pi())*sqrt(1-rho0^2))^-1
		zeta1 = ((2*pi())*sqrt(1-rho1^2))^-1
		cut_h1 = cutpts_t[1,2]
		cut_l1 = cutpts_t[1,1]
		A1p1 = cut_h1:-eta1
		A1 = cut_l1:-eta1
			for(j=1;j<=choices;j++){
				cut_h2 = cutpts_0[1,j+1]
				cut_l2 = cutpts_0[1,j]
				A2p1 = cut_h2:-eta2_0
				A2 = cut_l2:-eta2_0
				gradfun_4[.,j]=(exp((-.5):*(((A1p1:^2):+(A2p1:^2):-(rho0:*A1p1:*A2p1:*2)):/gamma0)):- ///
					exp((-.5):*(((A1:^2):+(A2p1:^2):-(rho0:*A1:*A2p1:*2)):/gamma0)):- ///
					exp((-.5):*(((A1p1:^2):+(A2:^2):-(rho0:*A1p1:*A2:*2)):/gamma0)):+ ///
					exp((-.5):*(((A1:^2):+(A2:^2):-(rho0:*A1:*A2:*2)):/gamma0))):*zeta0
				}	
				
		rr0 = tanh(rho0)
		drho_dr0 = 1/(cosh(rr0)^2) // derivative of rho wrt r
		gradscalar = drho_dr0 //zeta
		gradfun[.,4] = gradscalar:*((rowsum(imat0:*gradfun_4)):/fvi)
		cut_h1 = cutpts_t[1,3]
		cut_l1 = cutpts_t[1,2]
		A1p1 = cut_h1:-eta1
		A1 = cut_l1:-eta1
			for(j=1;j<=choices;j++){
				cut_h2 = cutpts_1[1,j+1]
				cut_l2 = cutpts_1[1,j]
				A2p1 = cut_h2:-eta2_1
				A2 = cut_l2:-eta2_1
				gradfun_5[.,j]=(exp((-.5):*(((A1p1:^2):+(A2p1:^2):-(rho1:*A1p1:*A2p1:*2)):/gamma1)):- ///
					exp((-.5):*(((A1:^2):+(A2p1:^2):-(rho1:*A1:*A2p1:*2)):/gamma1)):- ///
					exp((-.5):*(((A1p1:^2):+(A2:^2):-(rho1:*A1p1:*A2:*2)):/gamma1)):+ ///
					exp((-.5):*(((A1:^2):+(A2:^2):-(rho1:*A1:*A2:*2)):/gamma1))):*zeta1
				}	
				
		rr1 = tanh(rho1)
		//printf("rho1=%4.3f \n", rr1)
		drho_dr1 = 1/(cosh(rr1)^2) // derivative of rho wrt r
		gradscalar = drho_dr1  
		gradfun[.,5] = gradscalar:*((rowsum(imat1:*gradfun_5)):/fvi)
		/*derivatives wrt cutpoints*/
		ncuts = choices-1
		gradfun_6_tmp = J(n,cc,0)
		gradfun_6 = J(n,ncuts,.)
		for(i=1;i<=ncuts;i++){
				cut_h1 = cutpts_t[1,2]
				cut_l1 = cutpts_t[1,1]
				A1p1 = cut_h1:-eta1
				A1 = cut_l1:-eta1
				for(k=1;k<=choices;k++){
					delta_kj1 = (i==k)
					delta_kj = (i==k-1)
					cut_h2 = cutpts_0[1,k+1]
					cut_l2 = cutpts_0[1,k]
					A2p1 = cut_h2:-eta2_0
					A2 = cut_l2:-eta2_0
					gradfun_6_tmp[.,k]=((normal((A1p1:-rho0:*A2p1):/delta0):-normal((A1:-rho0:*A2p1):/delta0)):*normalden(A2p1):*delta_kj1):- ///
						((normal((A1p1:-rho0:*A2):/delta0):-normal((A1:-rho0:*A2):/delta0)):*normalden(A2):*delta_kj)
				}
			gradfun_6[.,i] = (rowsum(imat0:*gradfun_6_tmp)):/fvi
		}
		gradfun_7_tmp = J(n,cc,0)
		gradfun_7 = J(n,ncuts,.)
		for(i=1;i<=ncuts;i++){
				cut_h1 = cutpts_t[1,3]
				cut_l1 = cutpts_t[1,2]
				A1p1 = cut_h1:-eta1
				A1 = cut_l1:-eta1
				for(k=1;k<=choices;k++){
					delta_kj1 = (i==k)
					delta_kj = (i==k-1)
					cut_h2 = cutpts_1[1,k+1]
					cut_l2 = cutpts_1[1,k]
					A2p1 = cut_h2:-eta2_1
					A2 = cut_l2:-eta2_1
					gradfun_7_tmp[.,k]=((normal((A1p1:-rho1:*A2p1):/delta1):-normal((A1:-rho1:*A2p1):/delta1)):*normalden(A2p1):*delta_kj1):- ///
						((normal((A1p1:-rho1:*A2):/delta1):-normal((A1:-rho1:*A2):/delta1)):*normalden(A2):*delta_kj)
				}
			gradfun_7[.,i] = (rowsum(imat1:*gradfun_7_tmp)):/fvi
		}
		gradfun_cuts = gradfun_6, gradfun_7
		//gradfun_cuts[|1,1\3,cols(gradfun_cuts)|]
		gradfun[|1,6\n,cols(gradfun)|]=gradfun_cuts
		st_store(.,(tokens(gfunout)),gradfun)		
		
		
}



end


