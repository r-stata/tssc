capture program drop _all
program define treatoprobitsim_work, eclass

local gradient 
global neqs = 3+($ncut)
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

//local touse $touse

qui levelsof($ML_y2)
global nchoices: word count `r(levels)'

*linear predictor: treatment
tempvar zbeta y1 lambda
qui g double `zbeta' = (2*($ML_y1)-1)*`eta1'
qui g double `y1'=$ML_y1
qui g double `lambda' = `y1'*`r'+(1-`y1')*(-`r')
*tab `lambda'
*linear predictor: outcome

*first, matrix of cutpoints
tempname cutpts0r cutpts
mat `cutpts0r' = J(1,$ncut,0)
forvalues i = 1/$ncut {
	mat `cutpts0r'[1,`i'] = `c`i''
	}
	
local neginf = minfloat()
local posinf = maxfloat() 
mat `cutpts' = `neginf',`cutpts0r',`posinf'


local imat
tempvar xbj xbjM1
qui g double `xbj'=0
qui g double `xbjM1'=0
forvalues i = 1/$nchoices {
	local k = `i'+1
	local cutjM1 = `cutpts'[1,`i']
	local cutj = `cutpts'[1,`k']
	tempvar m`i' xb`i'j xb`i'jM1 	
	qui g double `m`i'' = $ML_y2==`i' 
	qui g double `xb`i'jM1' = `m`i''*(`cutjM1'-`eta2') 
	qui g double `xb`i'j' = `m`i''*(`cutj'-`eta2') 
	qui replace `xbj'=`xbj'+`xb`i'j' 
	qui replace `xbjM1' = `xbjM1'+`xb`i'jM1' 
	local imat "`imat' `m`i''"
	}


	
tempname lnL
qui g double `lnL'=0	



local gradfun
forv i = 1/$neqs {
	tempvar g`i'_tmp
	qui g double `g`i'_tmp'=0
	local gradfun "`gradfun' `g`i'_tmp'"
}


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




mata: treatoprobit_lf_gradhess("`lnL'","`zbeta'", "`xbj'","`xbjM1'","`lambda'",  ///
		_treatoprobit_S,_treatoprobit_rnd, "`gradfun'", "`imat'", "`hess'", "`eta1'", ///
		"`y1'")


qui replace `lnfj' = `lnL' 
if (`todo'==0 | `lnfj' == .) exit

forv i = 1/$neqs {
	qui replace `g`i''=`g`i'_tmp'
	//sum `g`i''
}		

if (`todo'==1) exit

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
forv i = 3/$neqs {
	mlmatsum `lnfj' `g2`i'' = `g2`i'_tmp', eq(2,`i')
	}
mlmatsum `lnfj' `g33' = `g33_tmp', eq(3)
forv i = 4/$neqs {
	mlmatsum `lnfj' `g3`i'' = `g3`i'_tmp', eq(3,`i')
	}
mlmatsum `lnfj' `g44' = `g44_tmp', eq(4)	
forv i = 5/$neqs {
	forv j = 5/$neqs {
		if `i'==`j' {
			mlmatsum `lnfj' `g`i'`j'' = `g`i'`j'_tmp', eq(`i')
		}
		else {
			continue
		}
	}
}
mlmatsum `lnfj' `g11' = `g11_tmp', eq(1)
forv i = 2/$neqs {
	mlmatsum `lnfj' `g1`i'' = `g1`i'_tmp', eq(1,`i')
	}
mlmatsum `lnfj' `g22' = `g22_tmp', eq(2)
forv i = 3/$neqs {
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
*mat list `A'
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
*mat list `B'
mat `d' = `g44'
forv i = 5/$neqs {
	mat `d' = nullmat(`d'), `g`i'`i'' 	
	}
mat `C' = diag(`d')
*mat list `C'
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
function treatoprobit_lf_gradhess(string scalar lnL, string scalar zbeta, string scalar xbj, ///
	string scalar xbjM1, string scalar lambda, real scalar S, real matrix rnd, string ///
	scalar gfun, string scalar indmat, string scalar hess, string scalar nu1, string scalar y)
	{
	
	real matrix xbji, xbjM1i, zbetai, normzb, treatoprobitsim
	n = st_nobs()
	      
	
	gfunout = tokens(gfun)
	hessian = tokens(hess)
	cuts = strtoreal(st_global("ncut")) 
	choices = cuts+1
	
	st_view(y1,.,y)
	st_view(xb1,.,nu1)		
	st_view(zbetai,., zbeta)
	st_view(xbji,., xbj)
	st_view(xbjM1i,., xbjM1)
	st_view(imat,.,indmat)
	st_view(lam,.,lambda)
	
	sign = ((2:*y1):-1)
	zbetarnd = (sign:*xb1):+rnd
	normzb = normal(zbetarnd)
	xbrnd = xb1 :-lam:*rnd
	xbji = xbji:-lam:*rnd
	xbjM1i = xbjM1i:-lam:*rnd
	normxb0r = normal(xbji):-normal(xbjM1i)
	treatoprobitsim = normzb:*normxb0r
	L = (rowsum(treatoprobitsim)):/S
	L=rowmax((L , J(rows(L),1,smallestdouble())))
	vlnL = ln(L)
	
	
	
	/*gradient*/
	srnd = sign:*rnd
	gf4 = J(n,cuts,0)
	fxbr = normalden(xbrnd)
	fxbi = normalden(zbetarnd)
	fxb0ri = normalden(xbji):-normalden(xbjM1i)
	gf1 = (1:/L):*(rowsum(sign:*fxbi:*normxb0r))/S
	gf2 = (1:/L):*(-1):*(rowsum(normzb:*(fxb0ri)))/S
	gf3 = (1:/L):*(-1):*(rowsum((normzb):*(srnd):*fxb0ri))/S
	gf4tmp = J(n,choices,0)
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			gf4tmp[.,k]=rowsum(((normalden(xbji):*delta_kj1):-(normalden(xbjM1i):*delta_kj)):*normzb)/S
				}
		gf4[.,i] = (rowsum(imat:*gf4tmp)):/L
		
		}
	gradfun = gf1, gf2, gf3, gf4 
	
	/*hessian*/
	/*h1**/
	 /*gf1 = (1:/L):*(rowsum(sign:*fxbi:*normxb0r))/S */
	//fxbiM = normalden(-zbetarnd)
	invL = 1:/(L)
	h11 = invL:*(rowsum(fxbi:*-zbetarnd:*normxb0r)/S):-(gf1:^2)
	h12 = invL:*(rowsum(sign:*fxbi:*-fxb0ri)/S):-(gf1:*gf2)
	h13 = invL:*(rowsum(sign:*fxbi:*fxb0ri:*(-srnd))/S):-(gf1:*gf3)
	h1c = invL:*(sign:*fxbi)
	h14tmp = J(n,choices,0)
	h14 = J(n,cuts,0)
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h14tmp[.,k]=rowsum(((normalden(xbji):*delta_kj1):-(normalden(xbjM1i):*delta_kj)):*h1c)/S
				}
		h14[.,i] = (rowsum(imat:*h14tmp))
	}
	h14 = h14:-(gf1:*gf4)
	h1 = h11,h12,h13,h14
	
	
	/*h2**/
	/* gf2 = (1:/L):*(-1):*(rowsum(normzb:*(fxb0ri)))/S */
	fxb0ri_i = (normalden(xbji):*(-xbji)):-(normalden(xbjM1i):*(-xbjM1i))
	h22 = invL:*(-1):*((rowsum(normzb:*(-fxb0ri_i)))/S):-(gf2:^2)
	h23 = invL:*(-1):*(rowsum(normzb:*fxb0ri_i:*-srnd)/S):-(gf2:*gf3)
	h2c = invL:*(-1):*(normzb)
	h24tmp = J(n,choices,0)
	h24 = J(n,cuts,0)
	for (i=1;i<=cuts;i++){
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h24tmp[.,k]=rowsum((-1):*((normalden(xbji):*xbji:*delta_kj1):-(normalden(xbjM1i):*xbjM1i:*delta_kj)):*h2c)/S
				}
		h24[.,i] = (rowsum(imat:*h24tmp))
	}
	h24=h24:-(gf2:*gf4)
	h2 = h22,h23,h24
	/*h3*/	
	/* gf3 = (1:/L):*(rowsum((normzb):*(-rnd):*fxb0ri))/S */
	h33 = invL:*(rowsum((normzb):*(-srnd):*fxb0ri_i:*-srnd)/S):-(gf3:^2)
	h3c = invL:*(normzb:*-srnd)
	h34tmp = J(n,choices,0)
	h34 = J(n,cuts,0)
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h34tmp[.,k]=rowsum(((normalden(xbji):*(-xbji):*delta_kj1):-(normalden(xbjM1i):*(-xbjM1i):*delta_kj)):*h3c)/S
				}
		h34[.,i] = (rowsum(imat:*h34tmp))
	}
	h34 = h34:-(gf3:*gf4)
	h3 = h33, h34
	a=cols(h1)
	b=cols(h2)
	c=cols(h3)
	
	/*h4*/
	h44tmp = J(n,choices,0)
	h44 = J(n,cuts,0)
	for(i=1; i<=cuts;i++) {
		for(k=1;k<=choices;k++){
			delta_kj1 = (i==k)
			delta_kj = (i==k-1)
			h44tmp[.,k]=rowsum((-1):*((normalden(xbjM1i):*-xbjM1i:*delta_kj):-(normalden(xbji):*-xbji:*delta_kj1)):*normzb)/S
				}
		h44[.,i] = invL:*(rowsum(imat:*h44tmp))
	}
	h44 = h44:-(gf4:^2)
	zeros = J(n,1,0)
	offdiag=cuts-1
    h44od = J(n,offdiag,.)
	for (i=1; i<=offdiag;i++) {
		t = i+1
		h44od[.,i] = zeros:-(gf4[.,i]:*gf4[.,t])
		}
	h4 = h44,h44od
	hessfun = h1,h2,h3,h4 

	st_store(.,lnL,vlnL)
	st_store(.,gfunout,gradfun)
	st_store(.,hessian,hessfun)
}
end



