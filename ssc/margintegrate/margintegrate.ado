capture program drop margintegrate
program margintegrate, rclass //sortpreserve
version 9
set matsize 800
*!version 1.0 cagregory 31 may 2011
syntax varlist(min=3 max=3 numeric) [if] [in] ,   /*
	*/bw(numlist min=2 max=2)    /*
	*/[nograph          /*
	*/n(integer 50)      /*
	*/GENerate(namelist) /*
	*/ ci(string)        /*
	*/ boot(integer 0)   /*
	*/ trim(real 0)]
	global nobs = _N
	tempname programid xgridpt idgrid ygridpt varhat idout
	local yvar: word 1 of `varlist'
	local xvar1: word 2 of `varlist'
	local xvar2: word 3 of `varlist'
	capture drop _merge
	sort `xvar1' `xvar2', stable
	qui g `programid'=_n
	qui g `idout' = `programid'
	tempname wc
	local `wc': word count `generate'
		if ``wc''>=1 {
			local rhat: word 1 of `generate'
			}
		else {
			local rhat
			}
	capture confirm new variable `rhat'
		if _rc!=0 {
			local tempnum = round(100*runiform())
			disp as text "`rhat' already exists"
			disp as text "`rhat' renamed `rhat'`tempnum'" 
			rename `rhat' `rhat'`tempnum'
			}
		if ``wc''>1 {
			local vhat: word 2 of `generate'
			}
		else {
			local vhat
			}
	capture confirm new variable `vhat'
		if _rc!=0 {
			local tempnum = round(100*runiform())
			disp as text "`vhat' already exists"
			disp as text "`vhat' renamed `vhat'`tempnum'" 
			rename `vhat' `vhat'`tempnum'
			}
	tempfile marginadd
	sort `programid'
	qui save `marginadd'
	marksample touse
	qui keep if `touse'
	/*trimming*/
	if `trim'!=0 {
		local trub = 100-(`trim'/2)
		local trlb = `trim'/2
		_pctile `xvar1', p(`trlb',`trub') //trimming values
		local xlb = round(r(r1),.01)
		local xub = round(r(r2),.01)
		disp as text "Trimming Lower Bound is `xlb'"
		disp as text "Trimming Upper Bound is `xub'"
		qui drop if `xvar1'<`xlb'  | `xvar1'> `xub'
	}	
	/* get estimation grid*/
	
	getgrid_p `yvar' `xvar1' `xvar2' `programid', points(`n')
	tempname estgrid outmat varmat idmat
	matrix `estgrid' = r(estgrid)
	//matrix list `estgrid'
	/*output matrices*/
	global r = rowsof(`estgrid')
	/*integral of squared kernel function--needed for variance*/
	local bw1: word 1 of `bw'
	local bw2: word 2 of `bw'
	tempname hnopt1 hnopt2
	local `hnopt1' = `bw1'/2
	local `hnopt2' = `bw2'/2
	gaussquadk2 `xvar1' `xvar2', hvec(``hnopt1'' ``hnopt2'')
	tempname intksquared
	global intksquared = r(intk2)
	//disp "integral k2="$intksquared
	/*main estimates*/
	miestimate `yvar' `xvar1' `xvar2' `programid', h(``hnopt1'' ``hnopt2'') estmat(`estgrid')
	tempname outMat varMat idMat outVec varVec bootidVec boot_id
	matrix `outMat' = r(out_mat)
	matrix `varMat' = r(var_mat)
	matrix `idMat' = r(id_mat)
	matrix `outVec' = J(1,$r,0)
	matrix `varVec' = J(1,$r, 0)
	matrix `bootidVec' = J(1,$r,0)
	forvalues i = 1/$r {
		forvalues j = 1/$r {
			matrix `varVec'[1,`i'] = `varVec'[1,`i']+`varMat'[`j',`i'] //sample averaging=marginal expectation
			matrix `outVec'[1,`i'] = `outVec'[1,`i']+`outMat'[`j',`i']
			matrix `bootidVec'[1,`i'] = $r*`i'
			}
		}
	matrix `varVec' = (`varVec'/$r)'
	matrix `outVec' = (`outVec'/$r)'
	matrix `bootidVec' = (`bootidVec'/$r)'
	global varhat varhat
	matrix colnames `varVec' = `vhat'
	matrix colnames `outVec' = `rhat'
	matrix colnames `bootidVec' = `boot_id'
	matrix `idMat' = `idMat',`varVec',`outVec',`bootidVec'
	//matrix list `idMat'
	qui drop _all
	qui svmat double `idMat', names(col)
	qui drop ygrid x1grid x2grid
	//qui drop if `rhat'==. | `rhat'==0
	rename idgrid `programid'
	sort `programid'
	merge `programid' using `marginadd' 
	cap drop _merge
	if `boot'==0 {
		if "`graph'"=="" {
				if "`ci'"!="" {
						qui sum `xvar1'
						tempname tail vcons ub lb
						local `tail' = (1-(`ci'/100))/2
						local `vcons' = abs(invnormal(``tail''))
						qui g `ub' = `rhat'+``vcons''*(sqrt(`vhat'))
						qui g `lb' = `rhat'-``vcons''*(sqrt(`vhat'))
						twoway rarea `ub' `lb' `xvar1' , sort color(eltblue)  /*
							*/ || line `rhat' `xvar1' , sort color(black) t1title("Marginal Integration Estimate") /*
							*/ xtitle("`xvar1'") ytitle("`yvar'") legend(lab(1 "`ci'% CI") /*
							*/ lab(2 "Marginal Integration Estimate"))
						}
				else {
						twoway line `rhat' `xvar1', sort t1title("Marginal Integration Estimate") xtitle("`xvar1'") ///
						ytitle("`yvar'")
				 	}
				}
		}
	else {
			sort `boot_id'
			qui save `marginadd', replace
			disp as text "Executing Bootstrap Estimation of Variance"
			bootmi `yvar' `xvar1' `xvar2', h(``hnopt1'' ``hnopt2'') reps(`boot') 
			tempname bootr
			matrix `bootr' = r(bootsd)
			tempname bootmatid bootmatsd
			matrix colnames `bootr'=`bootmatid' `bootmatsd'
			svmat double `bootr', names(col)
			keep `bootmatid' `bootmatsd'
			rename `bootmatid' `boot_id'
			sort `boot_id'
			qui merge `boot_id' using `marginadd'
			qui replace `vhat' = `bootmatsd'
			if "`graph'"=="" {
					if "`ci'"!="" {
						qui sum `vhat'
						local bootsigma = r(mean)
						qui drop if `vhat'>(3*`bootsigma')
						tempname x1max x1min
						qui sum `xvar1'
						local `x1max'=r(max)
						local `x1min'=r(min)
						tempname tail vcons ub lb
						local `tail' = (1-(`ci'/100))/2
						local `vcons' = abs(invnormal(``tail''))
						qui g `ub' = `rhat'+``vcons''*(sqrt(`vhat'))
						qui g `lb' = `rhat'-``vcons''*(sqrt(`vhat'))
						twoway rarea `ub' `lb' `xvar1' if `xvar1'<=``x1max'', sort color(eltblue)  /*
						*/ || line `rhat' `xvar1', sort color(black) t1title("Marginal Integration Estimate") /*
						*/ xtitle("`xvar1'") ytitle("`yvar'") legend(lab(1 "`ci'% Bootstrap CI") /*
						*/ lab(2 "Marginal Integration Estimate"))
						}
					else {
						twoway line `rhat' `xvar1', sort t1title("Marginal Integration Estimate") xtitle("`xvar1'") ///
						ytitle("`yvar'")
				 	}
				}
			}
	
							
end		


program define getgrid_p, rclass 
syntax varlist (min=4 max=4), points(integer)
	local y: word 1 of `varlist'
	local x1: word 2 of `varlist'
	local x2: word 3 of `varlist'
	local progid: word 4 of `varlist'
	tempname grid 
	matrix `grid' = J(`points',4,0)	
	local u=round(`points'+1)
	sort `x1' `x2', stable
	tempname newid pctx1 del pid ygrid xgrid2 tempid pctxvar oldpid
	qui g `newid'=_n
	pctile `pctxvar'=`x1', n(`u')
	forvalues i = 1/`points' {
		 scalar `pctx1' = `pctxvar'[`i'] 
		  matrix `grid'[`i',1] = scalar(`pctx1') 
		    	qui gen `del' = abs(`x1' - scalar(`pctx1'))
		    	qui sum `del' 
		    	qui sum `newid' if `del'==r(min) 
		    		if `i'>1 {
		    			scalar `oldpid' = scalar(`pid')
		    			//scalar list `oldpid'
		    		}
		    		else {
		    			scalar `oldpid' = -99
		    			//scalar list `oldpid'
		    			}
		    	scalar `pid' = max(round(r(mean)),`oldpid')
		    		if scalar(`pid')==scalar(`oldpid') {
		    			scalar `pid' = scalar(`pid')+1
		    		}
		    	qui sum `x2' if `newid'==scalar(`pid')
		    	scalar `xgrid2' = r(mean)
		    	qui sum `y' if `newid'==scalar(`pid')
		    	scalar `ygrid' = r(mean)
		    	qui sum `progid' if `newid'==scalar(`pid')
		    	scalar `tempid' = round(r(mean))
		    	matrix `grid'[`i',2] = scalar(`xgrid2')
		    	matrix `grid'[`i',3] = scalar(`tempid')
		    	matrix `grid'[`i',4] = scalar(`ygrid')
		    	drop `del' 
		    	} 
		matrix colnames `grid'= x1grid x2grid idgrid ygrid
		return matrix estgrid `grid'
end			

program define getgrid, rclass
syntax varlist (min=4 max=4), points(string)

	local y: word 1 of `varlist'
	local x1: word 2 of `varlist'
	local x2: word 3 of `varlist'
	local progid: word 4 of `varlist'
	capture confirm new variable samplemark
		if _rc {
			rename samplemark smark_old
			di as text "samplemark already exists"
			di as text "samplemark renamed smark_old"
			}
	samplemark `x1' `x2', gridsize("`points'") gen(samplemark)
	qui {			
	tempvar countid delta newid
	tempname grid xgrid1 xgrid2 ygrid tempid points
	sum samplemark
	local `points' = r(sum)
		sort `x1' `x2', stable
		g `countid' = sum(samplemark)
		g `delta' = `countid'-`countid'[_n-1]
		replace `countid' = `delta'*`countid'
		matrix `grid' = J(``points'',4,.)
		sort `x1', stable
		qui g `newid'=_n
		forvalues i = 1/``points'' {
				sum `x1' if `countid'==`i'
				scalar `xgrid1' = r(mean)
				matrix `grid'[`i',1] = scalar(`xgrid1')
				qui sum `x2' if `countid'==`i'
				scalar `xgrid2' = (r(mean))
				qui sum `y' if `countid'==`i'
				scalar `ygrid' = r(mean)
				qui sum `progid' if `countid'==`i'
				scalar `tempid' = round(r(mean))
				matrix `grid'[`i',2]= scalar(`xgrid2')
				matrix `grid'[`i',3]= scalar(`tempid')
				matrix `grid'[`i',4]= scalar(`ygrid')
			}
		 }
	global names x1grid x2grid idgrid ygrid
	matrix colnames `grid'= $names //x1grid x2grid idgrid ygrid
	return matrix estgrid `grid'
end


program define samplemark
syntax varlist , GRIDsize(string) [GENerate(name)]
local w: word count varlist
sort `varlist', stable
tempvar markid
g `markid'=_n
local N = _N
local gridobs=`gridsize'
local interval = round((`N'/`gridobs'),1)
if "`generate'"=="" {
	g samplemark = 0 
		forv i=1/`gridobs' {
		local here = `i'*`interval'
		qui replace samplemark=1 if `markid'==`here'
		}
	}
else {
	g `generate' = 0 
		forv i=1/`gridobs' {
		local here = `i'*`interval'
		qui replace `generate'=1 if `markid'==`here'
		}
	}	
end	



program define miestimate, rclass
syntax varlist (min=4 max=4), h(numlist min=2 max=2) estmat(name)
    local y: word 1 of `varlist'
	local x1: word 2 of `varlist'
	local x2: word 3 of `varlist'
	local progid: word 4 of `varlist'
	local h1: word 1 of `h'
	local h2: word 2 of `h'	
	tempname x1gridpt gridobs1 del1 kdel1 wgt1 fz dens1 gridobs2 x2gridpt del2 kdel2 wgt2 /*
	         */ newwgt sumwgt newwgt2 jointfx2 yhat mse wgt2_2 fx2_2 varhat outmat varmat idmat /*
	         */ fx1
	matrix `outmat' = J($r,$r,.)
	matrix `varmat' = J($r,$r,0)
	matrix `idmat' = J($r,4,.)
	qui {
	forvalues j = 1/$r {
				sort `x1' , stable
				scalar `x1gridpt' = `estmat'[`j',1]
				scalar `gridobs1' = `estmat'[`j',3]
				matrix `idmat' = (`estmat'[1..$r,4], `estmat'[1..$r,1], `estmat'[1..$r,2], `estmat'[1..$r,3])
				g `del1'=`x1'-scalar(`x1gridpt')
				g `kdel1'= (abs(`del1')/`h1')^3
				replace `kdel1' = 1 if `kdel1'>1
				g `wgt1' = ((70/81)*(1-`kdel1'))^3
				disp "wgt1"
				sum `wgt1'
				local sigwgt1 = r(sum)
				g `dens1' = `wgt1'/`sigwgt1'
				disp "dens"
				sum `dens1' if `progid'==scalar(`gridobs1')
				scalar `fz' = r(mean)
				di as text "fz="scalar(`fz')
				qui sum `dens1' if `progid'==scalar(`gridobs1')
				scalar `fx1' = r(max)
				forvalues k = 1/$r {
						sort `x2', stable
						scalar `x2gridpt'=`estmat'[`k',2]
						scalar `gridobs2'=`estmat'[`k',3]
						g `del2'=`x2'-scalar(`x2gridpt')
						disp "del2"
						sum `del2'
						g `kdel2'= (abs(`del2')/`h2')^3
						disp "kdel2"
						sum `kdel2'
						replace `kdel2' = 1 if `kdel2'>1
						g `wgt2' = ((70/81)*(1-`kdel2'))^3
						sum `wgt2' 
						local sigwgt2=r(sum)
						g `newwgt' = `wgt1'*`wgt2'
						qui sum `newwgt' 
						scalar `sumwgt' = r(sum)
						//qui replace `newwgt' = `newwgt'/`sumwgt' //joint kernel weight
						qui count if `newwgt'>0 & `newwgt'!=.
						scalar obs = r(N)
						scalar list obs
						disp "del1"
						sum `del1' if `newwgt'>0
						disp "y"
						sum `y' if `newwgt'>0					
						if scalar(obs) >5 {
								reg `y' `del1' [weight=`newwgt']
								scalar `yhat' = _b[_cons] 
								scalar `mse' = (e(rmse))^2
								}
							else {
								scalar `yhat' = 0
								scalar `mse' = 0
								}
						g `newwgt2' = `newwgt'^2
						sum `newwgt2' /*if `progid'==scalar(`gridobs2')*/ //joint kwgt^2: needed for variance
						scalar `jointfx2' = r(max) 
						g `wgt2_2' = `wgt2'^2
						sum `wgt2_2' /*if `progid'==scalar(`gridobs2')*/
						scalar `fx2_2' = r(max) 
						disp "yhat="scalar(`yhat')
						disp "fz="`fz'
						disp "k2="$intksquared
						disp "mse="scalar(`mse')
						disp "fx2_2="scalar(`fx2_2')
						disp "joint="scalar(`jointfx2')
						scalar `varhat' =scalar(`fx1')*($intksquared)*((scalar(`mse')*scalar(`fx2_2'))/scalar(`jointfx2'))
						disp "varhat="scalar(`varhat')
						matrix `varmat'[`k',`j'] = scalar(`varhat')
						matrix `outmat'[`k',`j'] = scalar(`yhat')
						drop `del2' `kdel2' `wgt2' `newwgt' `newwgt2' `wgt2_2'
						}
				drop `del1' `kdel1' `wgt1' `dens1'
			}
		}
	return matrix var_mat `varmat'
	return matrix out_mat `outmat'
	return matrix id_mat `idmat'
end


/*bootstrap estimates*/
program define bootmi, rclass
syntax varlist (min=3 max=3) , h(numlist min=2 max=2) reps(integer) 

tempname bootMat bootid
local yboot: word 1 of `varlist'
local x1boot: word 2 of `varlist'
local x2boot: word 3 of `varlist'
local h1boot: word 1 of `h'
local h2boot: word 2 of `h'	

capture confirm new variable bootid
if _rc!=0 {
			local tempnum = round(100*runiform())
			disp as text "bootid already exists"
			disp as text "bootid renamed oldid`tempnum'" 
			rename bootid oldid`tempnum'
			}
	
	
tempfile bootdata
forvalues i = 1/`reps' {
	capture confirm new var bootout`i'
		if _rc!=0 {
			local rc _rc
			disp as error "bootout`i' already exists"
			error `rc'
		}
	preserve 
	bsample $nobs
	tempname bootmat`i' boottempid 
	sort `x1boot' `x2boot', stable
	qui g `boottempid' = _n
	//sum `x1boot' `x2boot' `boottempid'
	getgrid_p `yboot' `x1boot' `x2boot' `boottempid', points($r)	
	tempname bootgrid 
	matrix `bootgrid' = r(estgrid)
	bootestimate `yboot' `x1boot' `x2boot', h(`h1boot' `h2boot')  bootest(`bootgrid')
	matrix `bootmat`i'' = r(bootoutvec)
	matrix colnames `bootmat`i'' = bootid bootout`i'
	svmat double `bootmat`i'', names(col)
	keep bootid bootout`i'
	qui keep if bootid!=.
	if `i'==1 {
		sort bootid
		qui save `bootdata', replace
		restore
		}
	else if (`i'>1 & `i'< `reps') {
		sort bootid
		qui merge bootid using `bootdata'
		capture drop _merge
		sort bootid
		qui save `bootdata', replace
		restore
		}
	else if `i'==`reps' {
		sort bootid
		qui merge bootid using `bootdata'
		capture drop _merge
		sort bootid
		egen bootsd = rowsd(bootout`reps'-bootout1)
		keep bootid bootsd
		tempname R
		mkmat bootid bootsd, mat(`R')
		//matrix list `R'
		restore
		}
	
}

return matrix bootsd `R'
	
	
end
	
program define bootestimate, rclass
syntax varlist (min=3 max=3), h(numlist min=2 max=2) bootest(name)
    local y: word 1 of `varlist'
	local x1: word 2 of `varlist'
	local x2: word 3 of `varlist'
	local h1: word 1 of `h'
	local h2: word 2 of `h'	
	tempname x1gridptb gridobs1b del1b kdel1b wgt1b gridobs2b x2gridptb del2b kdel2b wgt2b /*
	         */ newwgtb sumwgtb jointfx2 yhatb outVecb outmatb kprod Ykmean ksum
	matrix `outmatb' = J($r,$r,.)
	//matrix `bootmat' = J($r,4,.)
	qui {
	forvalues j = 1/$r {
				sort `x1' , stable
				scalar `x1gridptb' = `bootest'[`j',1]
				scalar list `x1gridptb'
				scalar `gridobs1b' = `bootest'[`j',3]
				qui g `del1b'=`x1'-scalar(`x1gridptb')
				qui g `kdel1b'= (abs(`del1b')/`h1')^3
				replace `kdel1b' = 1 if `kdel1b'>1
				qui g `wgt1b' = ((70/81)*(1-`kdel1b'))^3
				qui sum `wgt1b'
				local sumkern = r(sum)
				qui g `kprod' = `wgt1b'*`y'
				qui g `ksum' = sum(`kprod')
				qui sum `ksum'
				local sumprod = r(max)
				scalar `Ykmean' = `sumprod'/`sumkern' 
				forvalues k = 1/$r {
					sort `x2', stable
						scalar `x2gridptb'=`bootest'[`k',2]
						scalar `gridobs2b'=`bootest'[`k',3]
						g `del2b'=`x2'-scalar(`x2gridptb')
						g `kdel2b'= (abs(`del2b')/`h2')^3
						replace `kdel2b' = 1 if `kdel2b'>1
						g `wgt2b' = ((70/81)*(1-`kdel2b'))^3
						g `newwgtb' = `wgt1b'*`wgt2b'
						sum `newwgtb' 
						scalar sigmawgt = r(sum)
						replace `newwgtb' = `newwgtb'/scalar(sigmawgt)
						replace `newwgtb' =0 if `newwgtb'==.
						tempname bootwindow bootwindcnt M unique 
						g `bootwindow' = `newwgtb'>0 & `newwgtb'!=.
						g `bootwindcnt' = `bootwindow'*`del1b'
						sum `bootwindow' `bootwindcnt'
						levelsof `bootwindcnt', local(`M')
						local `unique': word count ``M''
						di as text "unique="``unique''
								if ``unique''< 10 {
									scalar `yhatb' = scalar(`Ykmean')
									scalar list `yhatb'
									}
								else {
									reg `y' `del1b' [weight=`newwgtb']
								  	scalar `yhatb' = _b[_cons] 
								  	scalar list `yhatb'
									}
						matrix `outmatb'[`k',`j'] = scalar(`yhatb')
						drop `del2b' `kdel2b' `wgt2b' `newwgtb' `bootwindow' `bootwindcnt' 
					}
				drop `del1b' `kdel1b' `wgt1b' `kprod' `ksum'
			}
		}
	matrix `outVecb' = J(2,$r,0)
	forvalues i = 1/$r {
		forvalues j = 1/$r {
			matrix `outVecb'[2,`i'] = `outVecb'[2,`i']+`outmatb'[`j',`i']
			matrix `outVecb'[1,`i'] = `i'*$r
			}
		}
	matrix `outVecb' = (`outVecb'/$r)'
	return matrix bootoutvec `outVecb'
	
end

capture program drop gaussquadk2
program define gaussquadk2, rclass
*! version 1.0 cagregory ers 8 sept 2011
syntax varlist (min=2 max=2 numeric) [if] [in] ///
	 , hvec(numlist min=2 max=2) 

//local kern: word 1 of `varlist'
local xvar1: word 1 of `varlist'
local xvar2: word 2 of `varlist'
local b1: word 1 of `hvec'
local b2: word 2 of `hvec'

local bandw1 = `b1'/2
local bandw2 = `b2'/2

***************************************************************************
*This quadrature routine is from press et al. Numerical Recipes in C.
*Section 4.5, Gaussian Quadratures.* It computes the integral of the squared
*kernel weights for a given observation as a function of the right-hand-side
*variables in an additive model. I use 10 points of integration.
***************************************************************************

tempname max1 min1 max2 min2 aplusb1 bminusa1 aplusb2 bminusa2 xm1 xr1 xm2 xr2 ///
 intpoints intweight dx1 dx2 nodes1 nodes2 NTP s 
	
qui sum `xvar1' 
scalar `max1' = r(max)
scalar `min1' = r(min)
scalar `aplusb1' = `min1'+`max1'
scalar `bminusa1' = `max1'-`min1'
scalar `xm1' = .5*(`aplusb1')
scalar `xr1' = .5*(`bminusa1')

qui sum `xvar2'
scalar `max2' = r(max)
scalar `min2' = r(min)
scalar `aplusb2' = `min2'+`max2'
scalar `bminusa2' = `max2'-`min2'
scalar `xm2' = .5*(`aplusb2')
scalar `xr2' = .5*(`bminusa2')

matrix `intpoints' =[0.0, 0.1488743389, 0.4333953941, 0.6794095682, 0.8650633666, 0.97390652] 
matrix `intweight' =[0.0, 0.2955242247, 0.2692667193, 0.2190863625, 0.1494513491, 0.06667134] 

matrix define `dx1' = J(1,6,0) 
matrix define `nodes1' = J(1,12,0)
matrix define `dx2' = J(1,6,0)
matrix define `nodes2' = J(1,12,0)
matrix define `NTP' = J(2,6,0) 


forvalues j = 1/6 { 
	matrix `dx1'[1,`j'] = `xr1'*`intpoints'[1,`j'] 
	matrix `nodes1'[1,`j'] = `xm1' + `dx1'[1,`j'] 
	matrix `nodes1'[1, 6+`j'] = `xm1' - `dx1'[1,`j'] 
	matrix `dx2'[1,`j'] = `xr2'*`intpoints'[1,`j'] 
	matrix `nodes2'[1,`j'] = `xm2' + `dx2'[1,`j'] 
	matrix `nodes2'[1, 6+`j'] = `xm2' - `dx2'[1,`j'] 
	}
scalar `s' = 0 

/*Gauss-Legendre Quadrature 10 points*/
tempname d1 d2 w1 w2 kern kern2 p1 p2 m1 m2 tPrimePlus tPrimeMinus x1plus x2plus ///
	x1minus x2minus
		g `d1' = 0
		g `d2' = 0
		g `w1' = 0
		g `w2' = 0 
		g `p1' = 0 
		g `kern' = 0
		g `kern2' = 0
		g `p2' = 0 
		g `m1' = 0 
		g `m2' = 0 
		g `tPrimePlus' = 0
		g `tPrimeMinus' = 0
forvalues j = 1/6 {
	qui {
		sort `xvar1', stable
		scalar `x1plus' = `nodes1'[1,`j'] 
		scalar `x2plus' = `nodes2'[1,`j'] 
		replace `d1' = (abs(`xvar1'-scalar(`x1plus'))/(`bandw1'))^3  /*Weights determined by distance from BMI*/
		replace `d1' = 1 if abs(`xvar1'-scalar(`x1plus'))>`bandw1' 
		replace `w1' = (70/81)*(1 - `d1')^3 
		sort `xvar2', stable
		replace `d2' = (abs(`xvar2'-scalar(`x2plus'))/(`bandw2'))^3  /*Weights determined by distance from BMI*/
		replace `d2' = 1 if abs(`xvar2'-scalar(`x2plus'))>`bandw2' 
		replace `w2' = (70/81)*(1 - `d2')^3 
		replace `kern' = `w1'*`w2'
		replace `kern2' = `kern'^2
		replace `p1' = `kern2' 
		replace `tPrimePlus' = (`p1')
		qui sum `tPrimePlus'
		scalar normtprimeplus = r(max)
		matrix `NTP'[1,`j'] = scalar(normtprimeplus) 
		scalar `x1minus' = `nodes1'[1,6+`j'] 
		scalar `x2minus' = `nodes2'[1,6+`j']
		replace `d1' = (abs(`xvar1'-scalar(`x1minus'))/(`bandw1'))^3  /*Weights determined by distance from BMI*/
		replace `d1' = 1 if abs(`xvar1'-scalar(`x1minus'))>`bandw1' 
		replace `w1' = (70/81)*(1 - `d1')^3 
		sort `xvar2', stable
		replace `d2' = (abs(`xvar2'-scalar(`x2minus'))/(`bandw2'))^3  /*Weights determined by distance from BMI*/
		replace `d2' = 1 if abs(`xvar2'-scalar(`x2minus'))>`bandw2' 
		replace `w2' = (70/81)*(1 - `d2')^3 
		replace `kern' = `w1'*`w2'
		replace `kern2' = `kern'^2
		disp "k2,1"
		replace `m1' = `kern2' 
		replace `tPrimeMinus' = (`m1')
		replace `tPrimeMinus' = `tPrimeMinus'^2 
		sum `tPrimeMinus'
		scalar normtprimeminus = r(max)                                                       
		matrix `NTP'[2,`j'] = normtprimeminus    
		matrix list `NTP'
		scalar list normtprimeplus
		scalar `s' = scalar(`s') + `intweight'[1,`j']*(scalar(normtprimeplus) + scalar(normtprimeminus)) 
		scalar list `s'
		}
	}
scalar `s' = scalar(`s')*(sqrt(`xr1'*`xr2'))
return scalar intk2 = scalar(`s') 

end 



