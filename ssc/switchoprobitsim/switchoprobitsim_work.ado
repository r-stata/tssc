capture program drop switchoprobitsim_work
program define switchoprobitsim_work, eclass

local gradient 
global neqs = 5+2*$ncut
forvalues i = 1/$neqs {
	local gradient "`gradient' g`i'"
	}


args todo b lnfj `gradient' H
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


*predictor index: treatment eq
tempvar zbeta
qui g double `zbeta' = (2*($ML_y1)-1)*`eta1'

*predictor index: outcome eqs
qui levelsof($ML_y2)
global nchoices: word count `r(levels)'

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


local m_zero 
local m_one
forvalues i = 1/$nchoices {
	tempvar m0`i' m1`i' 
	qui g double `m0`i'' = $ML_y1==0 & ($ML_y2==`i')
	qui g double `m1`i'' = $ML_y1==1 & ($ML_y3==`i')
	local m_zero "`m_zero' `m0`i''"
	local m_one "`m_one' `m1`i''"
	}
local imat `m_zero' `m_one'

*re indexing outcome	
tempvar eta2i
qui g double `eta2i' = 0
qui replace `eta2i' = `eta2_0'*(1-$ML_y1)+`eta2_1'*($ML_y1)
	
tempvar xbj xbjM1
qui g double `xbj'= 0
qui g double `xbjM1' =0
forv d = 0/1 {
	forv i = 1/$nchoices {
		local k = `i'+1
		local cut_h2 = `cutpts`d''[1,`k']
		local cut_l2 = `cutpts`d''[1,`i']
		qui replace `xbj' = `xbj'+`m`d'`i''*(`cut_h2'-`eta2i')
		qui replace `xbjM1' = `xbjM1'+`m`d'`i''*(`cut_l2'-`eta2i')
		}
	}		

tempname lnL 
qui g double `lnL'=0	
tempvar theta
qui g double `theta' = (-`r0')*(1-$ML_y1)+ (`r1')*($ML_y1)
*qui g double `theta' = `r0'*(1-$ML_y1)+`r1'*$ML_y1
*tab `theta'



local gradfun
forv i = 1/$neqs {
	tempvar grad`i'_tmp
	qui g double `grad`i'_tmp'=0
	local gradfun "`gradfun' `grad`i'_tmp'"
}


local hess
forv i = 1/5 {
	forv j = `i'/$neqs {
		tempvar h`i'`j'_tmp
		qui g double `h`i'`j'_tmp'=0
		local hess "`hess' `h`i'`j'_tmp'"
		}
	}
forvalues i = 6/$neqs{
	tempvar h`i'`i'_tmp
	qui g double `h`i'`i'_tmp'=0
	local hess "`hess' `h`i'`i'_tmp'"
	}

global offdiag = $neqs-1
forvalues i = 6/$offdiag {
	local j = `i'+1
	tempvar h`i'`j'_tmp
	qui g double `h`i'`j'_tmp'=0
	local hess "`hess' `h`i'`j'_tmp'"
	} 

mata: switchoprobit_lf_hess("`lnL'", "`zbeta'", "`xbj'","`xbjM1'", "`theta'" , ///
  _switchoprobit_S,_switchoprobit_rnd, "`gradfun'", "`r0'", "`r1'", "`imat'", "`hess'")


qui replace `lnfj' = `lnL' 
if (`todo'==0 | `lnfj'==.) exit

forv i = 1/$neqs {
	qui replace `g`i''=`grad`i'_tmp'
}
if (`todo'==1) exit




forv i = 1/$neqs {
	forv j= `i'/$neqs {
		tempname h`i'`j'
		}	
}

mlmatsum `lnfj' `h11' = `h11_tmp', eq(1)
forv i = 2/$neqs {
	mlmatsum `lnfj' `h1`i'' = `h1`i'_tmp', eq(1,`i')
	
	}
mlmatsum `lnfj' `h22' = `h22_tmp', eq(2)
forv i = 3/$neqs {
	mlmatsum `lnfj' `h2`i'' = `h2`i'_tmp', eq(2,`i')
	}
mlmatsum `lnfj' `h33' = `h33_tmp', eq(3)
forv i = 4/$neqs {
	mlmatsum `lnfj' `h3`i'' = `h3`i'_tmp', eq(3,`i')
	}
mlmatsum `lnfj' `h44' = `h44_tmp', eq(4)
forv i = 5/$neqs {
	mlmatsum `lnfj' `h4`i'' = `h4`i'_tmp', eq(4,`i')
	}
mlmatsum `lnfj' `h55' = `h55_tmp', eq(5)
forv i = 6/$neqs {
	mlmatsum `lnfj' `h5`i'' = `h5`i'_tmp', eq(5,`i')
		
}
	
forv i = 6/$neqs {
	forv j = 6/$neqs {
		if `i'==`j' {
			mlmatsum `lnfj' `h`i'`j'' = `h`i'`j'_tmp', eq(`i')		
		}
	  	else if `i'==`j'-1 {
			mlmatsum `lnfj' `h`i'`j'' = `h`i'`j'_tmp', eq(`i',`j')
			}
		else  {
			continue
			}
		}
	}	
	

*form hessian matrix*	
tempname H1 H2 H3 H4 H5 A a1 a2 a3 a4 a5 B C d O 

mat `A' = `h11', `h12', `h13', `h14', `h15' \ `h12'', `h22', `h23', `h24', `h25' \  ///
		  `h13'', `h23'', `h33', `h34', `h35' \ `h14'', `h24'', `h34'', `h44', `h45' \ ///
		  `h15'', `h25'', `h35'', `h45'', `h55'
*mat list `A'
mat `H1' = `h16'
mat `H2' = `h26'
mat `H3' = `h36'
mat `H4' = `h46'
mat `H5' = `h56'
forvalues i = 7/$neqs {
	mat `H1' = nullmat(`H1'), `h1`i''
	mat `H2' = nullmat(`H2'), `h2`i''
	mat `H3' = nullmat(`H3'), `h3`i''
	mat `H4' = nullmat(`H4'), `h4`i''
	mat `H5' = nullmat(`H5'), `h5`i''
	}
mat `B' = nullmat(`H1') \ `H2'
mat `B' = nullmat(`B') \ `H3'
mat `B' = nullmat(`B') \ `H4'
mat `B' = nullmat(`B') \ `H5'
*mat list `B'
mat `d' = `h66'
forv i = 7/$neqs {
	mat `d' = nullmat(`d'), `h`i'`i'' 	
	}
mat `C' = diag(`d')
*mat list `C'
global cutM1 = 2*$ncut-1
global cutall = (2*$ncut)
mat `O' = J(rowsof(`C'),colsof(`C'),0)
forv i = 1/$cutM1 {
	forv j = 2/$cutall {
		 if `i'==`j'-1 {
			local m = `i'+5
			local n = `j'+5 
			mat `O'[`j',`i']=`h`m'`n''
			mat `O'[`i',`j']=`h`m'`n''
			}
		else {
			continue
		}
	}
}
mat `C' = `C'+`O'
*mat list `C'

*hessian

mat `H' = `A', `B' \ `B'', `C'

end

mata:
function switchoprobit_lf_hess(string scalar lnL, string scalar zbeta, string scalar xbj, ///
	string scalar xbjM1, string scalar theta, real scalar S, real matrix rnd, string scalar gradfunc, ///
	string scalar l0, string scalar l1, string scalar indmat, string scalar hessfun)
	{
	
	Y1 = *(findexternal("_switchoprobit_y1"))
	Y2 = *(findexternal("_switchoprobit_y2"))
	st_view(zbetai,., zbeta)
	st_view(xbji,., xbj)
	st_view(xbjM1i,.,xbjM1)
	st_view(thetai,.,theta)
	st_view(imat,.,indmat)
	n = st_nobs()
	lambda0 =(st_numscalar(l0))
	lambda1 =(st_numscalar(l1))
	cuts = strtoreal(st_global("ncut"))
	choices = cuts+1
	imat0 = imat[|1,1\n,choices|]
	imat1 = imat[|1,choices+1\n,cols(imat)|]
	k=cols(imat0)
	hessian = tokens(hessfun)
	
	/*likelihood*/
	zbetarnd = zbetai:+rnd
	normzb = normal(zbetarnd)
	
	xb_j = xbji:-thetai:*rnd
	xb_jM1 = xbjM1i:-thetai:*rnd
	normxb = (normal(xb_j):-normal(xb_jM1))
	treatoprobitsim = normzb:*normxb
	L = (rowsum(treatoprobitsim)):/S
	L=rowmax((L , J(rows(L),1,smallestdouble())))
	vlnL = ln(L)
	st_store(.,lnL,vlnL)
	
	/*gradient*/
	
	sign = ((2:*Y1):-1)
	gf6 = J(n,cuts,0)
	fxbi = normalden(zbetarnd)
	fxb0ri = normalden(xb_j):-normalden(xb_jM1)
	dtanhl0_dl = 1 //cosh(lambda0)^(-2)
	dtanhl1_dl = 1 //cosh(lambda1)^(-2)
	//printf("dtanhl0 = %3.2f", dtanhl1_dl)
	//gf1 = (1:/L):*(-1):*(rowsum(sign(zbetai):*fxbi:*normxb0r))/S
	gf1 = (1:/L):*(rowsum(sign:*fxbi:*normxb)):/S
	
	gf2 = (1:-Y1):*((1:/L):*(-1):*(rowsum(normzb:*(fxb0ri)))/S)
	gf3 = Y1:*((1:/L):*(-1):*(rowsum(normzb:*(fxb0ri)))/S)
	gf4 = -1:*((1:-Y1):*((1:/L):*(rowsum((normzb):*(rnd):*fxb0ri))/S):*-dtanhl0_dl)
	gf5 = Y1:*((1:/L):*(rowsum((normzb):*(rnd):*fxb0ri))/S):*-dtanhl1_dl
	gf6_0 = J(n,cuts,0)
	gf6_1 = J(n,cuts,0)
	gf6tmp0 = J(n,choices,0)
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			gf6tmp0[.,k]=rowsum(((normalden(xb_j):*delta_kj1):-(normalden(xb_jM1):*delta_kj)):*normzb)/S
				}
		gf6_0[.,i] = (rowsum(imat0:*gf6tmp0)):/L	
		}
		gf6tmp1 = J(n,choices,0)
		for(i=1; i<=cuts;i++) {
			for(k=1;k<=choices;k++){
				delta_kj1 = (i==k)
				delta_kj = (i==k-1)
				gf6tmp1[.,k]=rowsum(((normalden(xb_j):*delta_kj1):-(normalden(xb_jM1):*delta_kj)):*normzb)/S
					}
			gf6_1[.,i] = (rowsum(imat1:*gf6tmp1)):/L
		
			}
				
	gfunc = gf1, gf2, gf3, gf4, gf5, gf6_0, gf6_1 
	st_store(.,tokens(gradfunc),gfunc)
	
	/*hessian*/
	/*h1**/
	/*gf1 = (1:/L):*(rowsum(sign:*fxbi:*normxb)):/S */
	zeros = J(n,1,0) 
	
	invL = 1:/(L)
	h11 = invL:*(rowsum(fxbi:*-zbetarnd:*normxb)/S):-(gf1:^2)
	h12 = ((1:-Y1):*invL:*(rowsum(sign:*fxbi:*-fxb0ri)/S)):-(gf1:*gf2)
	h13 = ((Y1):*invL:*(rowsum(sign:*fxbi:*-fxb0ri)/S)):-(gf1:*gf3)
	h14 = ((1:-Y1):*invL:*(rowsum(sign:*fxbi:*fxb0ri:*rnd)/S):*dtanhl0_dl):-(gf1:*gf4)
	//old : h14 = ((1:-Y1):*invL:*(rowsum(sign:*fxbi:*fxb0ri:*rnd)/S):*-dtanhl0_dl):-(gf1:*gf4)
	h15 = ((Y1):*invL:*(rowsum(sign:*fxbi:*fxb0ri:*rnd)/S):*-dtanhl1_dl):-(gf1:*gf5)
	h1c = invL:*(sign:*fxbi)
	h16tmp0 = J(n,choices,0)
	h16tmp1 = J(n,choices,0)
	h16_0 = J(n,cuts,0)
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h16tmp0[.,k]=rowsum(((normalden(xb_j):*delta_kj1):-(normalden(xb_jM1):*delta_kj)):*h1c)/S
				}
		h16_0[.,i] = (rowsum(imat0:*h16tmp0))
	}
	h16_0 = h16_0:-(gf1:*gf6_0)
	h16_1 = J(n,cuts,0)
	for(i=1;i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h16tmp1[.,k]=rowsum(((normalden(xb_j):*delta_kj1):-(normalden(xb_jM1):*delta_kj)):*h1c)/S
				}
		h16_1[.,i] = (rowsum(imat1:*h16tmp1))
	}
	h16_1 = h16_1:-(gf1:*gf6_1)
	h1 = h11,h12,h13,h14,h15,h16_0,h16_1
	
	/*h2*/
	/*gf2 = (1:-Y1):*((1:/L):*(-1):*(rowsum(normzb:*(fxb0ri)))/S) */
	fxb0ri_i = (normalden(xb_j):*(-xb_j)):-(normalden(xb_jM1):*(-xb_jM1))
	h22 = ((1:-Y1):*invL:*(-1):*((rowsum(normzb:*(-fxb0ri_i)))/S)):-(gf2:^2)
	h23 = zeros 
	// old h24 = ((1:-Y1):*invL:*(-1):*(rowsum(normzb:*-fxb0ri_i:*-rnd)/S):*-dtanhl0_dl):-(gf2:*gf4)
	h24 = ((1:-Y1):*invL:*(-1):*(rowsum(normzb:*-fxb0ri_i:*-rnd)/S):*dtanhl0_dl):-(gf2:*gf4)
	h25 = zeros 
	h2c = (1:-Y1):*invL:*(-1):*(normzb)
	h26tmp0 = J(n,choices,0)
	h26tmp1 = J(n,choices,0)
	h26_0 = J(n,cuts,0)
	for(i=1;i<=cuts;i++){
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h26tmp0[.,k]=rowsum((-1):*((normalden(xb_j):*xb_j:*delta_kj1):-(normalden(xb_jM1):*xb_jM1:*delta_kj)):*h2c)/S
				}
		h26_0[.,i] = (rowsum(imat0:*h26tmp0))
	}
	h26_0 = h26_0:-(gf2:*gf6_0)

	h26_1 = J(n,cuts,0)
	for(i=1;i<=cuts;i++){
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h26tmp1[.,k]=rowsum((-1):*((normalden(xb_j):*xb_j:*delta_kj1):-(normalden(xb_jM1):*xb_jM1:*delta_kj)):*h2c)/S
				}
		h26_1[.,i] = (rowsum(imat1:*h26tmp1))
	}
	h26_1 = h26_1:-(gf2:*gf6_1)
	h2 = h22,h23,h24,h25,h26_0,h26_1
	
	/*h3*/
	/*gf3 = Y1:*((1:/L):*(-1):*(rowsum(normzb:*(fxb0ri)))/S)*/	
	h33 = ((Y1):*invL:*(-1):*((rowsum(normzb:*(-fxb0ri_i)))/S)):-(gf3:^2)
	h34 = zeros 
	h35 = ((Y1):*invL:*(-1):*(rowsum(normzb:*-fxb0ri_i:*-rnd)/S):*-dtanhl1_dl):-(gf3:*gf5)
	h3c = (Y1):*invL:*(-1):*(normzb)
	h36tmp0 = J(n,choices,0)
	h36tmp1 = J(n,choices,0)
	h36_0 = J(n,cuts,0)
	for(i=1;i<=cuts;i++){
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h36tmp0[.,k]=rowsum((-1):*((normalden(xb_j):*xb_j:*delta_kj1):-(normalden(xb_jM1):*xb_jM1:*delta_kj)):*h3c)/S
				}
		h36_0[.,i] = (rowsum(imat0:*h36tmp0))
	}
	h36_0 = h36_0:-(gf3:*gf6_0)
	h36_1 = J(n,cuts,0)
	for(i=1;i<=cuts;i++){
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h36tmp1[.,k]=rowsum((-1):*((normalden(xb_j):*xb_j:*delta_kj1):-(normalden(xb_jM1):*xb_jM1:*delta_kj)):*h3c)/S
				}
		h36_1[.,i] = (rowsum(imat1:*h36tmp1))
	}
	h36_1 = h36_1:-(gf3:*gf6_1)
	h3 = h33,h34,h35,h36_0,h36_1
	/*h4*/
	/*gf4 = (1:-Y1):*((1:/L):*(rowsum((normzb):*(rnd):*fxb0ri))/S):*-dtanhl0_dl*/
	/*dtanhl0_dl = cosh(lambda0)^(-2)
	dtanhl1_dl = cosh(lambda1)^(-2)*/
	
	zeros = J(n,1,0)
	d2lam0_d2l = 1 //-2*sinh(lambda0)/cosh(lambda0)^3 
	h41td2 = (gf4:/-dtanhl0_dl):*d2lam0_d2l
	//old h44 = h41td2:-dtanhl0_dl:*((1:-Y1):*invL:*((rowsum(normzb:*(rnd):*fxb0ri_i:*(-rnd)))/S):-(gf4:^2):/(-dtanhl0_dl))
	h44 = -h41td2:+dtanhl0_dl:*((1:-Y1):*invL:*((rowsum(normzb:*(rnd):*fxb0ri_i:*(-rnd)))/S):-(gf4:^2):/(dtanhl0_dl))
	h45 = zeros
	h46tmp0 = J(n,choices,0)
	h46tmp1 = J(n,choices,0)
	//old h4c = (1:-Y1):*invL:*(normzb:*rnd):*-dtanhl0_dl

	h4c = (1:-Y1):*invL:*(normzb:*rnd):*dtanhl0_dl
	h46_0 = J(n,cuts,0)
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h46tmp0[.,k]=rowsum(((normalden(xb_j):*(-xb_j):*delta_kj1):-(normalden(xb_jM1):*(-xb_jM1):*delta_kj)):*h4c)/S
				}
		h46_0[.,i] = (rowsum(imat0:*h46tmp0))
	}
	h46_0 = h46_0:-(gf4:*gf6_0)
	h46_1 = J(n,cuts,0)
	h4c = (1:-Y1):*invL:*(normzb:*rnd):*-dtanhl1_dl
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h46tmp1[.,k]=rowsum(((normalden(xb_j):*(-xb_j):*delta_kj1):-(normalden(xb_jM1):*(-xb_jM1):*delta_kj)):*h4c)/S
				}
		h46_1[.,i] = (rowsum(imat1:*h46tmp1))
	}
	h46_1 = h46_1:-(gf4:*gf6_1)
	h4 = h44,h45,h46_0,h46_1
	/*h5*/
	/*gf5 = Y1:*((1:/L):*(rowsum((normzb):*(rnd):*fxb0ri))/S):*-dtanhl1_dl*/
	d2lam1_d2l = 1 //-2*sinh(lambda1)/cosh(lambda1)^3 
	h51td2 = (gf5:/-dtanhl1_dl):*d2lam1_d2l
	h55 = h51td2:-dtanhl1_dl:*((Y1):*invL:*((rowsum(normzb:*(rnd):*fxb0ri_i:*(-rnd)))/S):-(gf5:^2):/(-dtanhl1_dl))
	h56tmp0 = J(n,choices,0)
	h56tmp1 = J(n,choices,0)
	h5c = (Y1):*invL:*(normzb:*rnd):*-dtanhl0_dl
	h56_0 = J(n,cuts,0)
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h56tmp0[.,k]=rowsum(((normalden(xb_j):*(-xb_j):*delta_kj1):-(normalden(xb_jM1):*(-xb_jM1):*delta_kj)):*h5c)/S
				}
		h56_0[.,i] = (rowsum(imat0:*h56tmp0))
	}
	h56_0 = h56_0:-(gf5:*gf6_0)
	h56_1 = J(n,cuts,0)
	h5c = (Y1):*invL:*(normzb:*rnd):*-dtanhl1_dl
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h56tmp1[.,k]=rowsum(((normalden(xb_j):*(-xb_j):*delta_kj1):-(normalden(xb_jM1):*(-xb_jM1):*delta_kj)):*h5c)/S
				}
		h56_1[.,i] = (rowsum(imat1:*h56tmp1))
	}
	h56_1 = h56_1:-(gf5:*gf6_1)
	h5 = h55,h56_0,h56_1
	
	/*h6*/
	h66tmp0 = J(n,choices,0)
	h66tmp1 = J(n,choices,0)
	h66_0 = J(n,cuts,0)
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h66tmp0[.,k]=rowsum((-1):*((normalden(xb_jM1):*-xb_jM1:*delta_kj):-(normalden(xb_j):*-xb_j:*delta_kj1)):*normzb)/S
				}
		h66_0[.,i] = invL:*(rowsum(imat0:*h66tmp0))
	}
	h66_0=h66_0:-(gf6_0:^2)
	h66_1 = J(n,cuts,0)
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h66tmp1[.,k]=rowsum((-1):*((normalden(xb_jM1):*-xb_jM1:*delta_kj):-(normalden(xb_j):*-xb_j:*delta_kj1)):*normzb)/S
				}
		h66_1[.,i] = invL:*(rowsum(imat1:*h66tmp1))
	}
	h66_1=h66_1:-(gf6_1:^2)
	h6diag = h66_0, h66_1
	offdiag=cuts-1
	h66od0 = J(n,offdiag,.)
	h66od1 = J(n,offdiag,.)
	for (i=1; i<=offdiag;i++) {
		t = i+1
		h66od0[.,i] = zeros:-(gf6_0[.,i]:*gf6_0[.,t])
		h66od1[.,i] = zeros:-(gf6_1[.,i]:*gf6_1[.,t])
		}
	h66od = h66od0,zeros,h66od1
	
	h6 = h6diag,h66od
	hess = h1,h2,h3,h4,h5,h6
	st_store(.,hessian,hess)

	
	
	
	
}
end
