*! kdens2 1.2.0  bivariate kernel density   CFBaum 22feb2007
* 1.0.0: from kdensity version 2.3.5   30nov1999 
* following Christian Beardah's MATLAB kdest2d.m (1994)
* 1.1.0: 5107 reshape long, integrate Ade Mander's wireframe surface plot
* 1.1.1: 5110 use variable labels for axis labels
* 1.1.2: 5111 fix varabbrev bug
* 1.1.3: 5114 reverse X,Y per TS suggestion
* 1.1.4: 6625 add replace to graph saving option
* 1.1.5: 7221 correct definition of denominator of density
* 1.1.6; BB19 correct labeling of Y variable, promote to v10 for surface
* 1.2.0: BB20 enable use of contourline, contour for Stata v12.1

program define kdens2, rclass
 
	version 10
	loc sv c(stata_version)
	if (`sv' >= 12.1) {
		version 12.1
	}
	syntax varlist(min=2 max=2) [if] [in] [fw aw] [, N(integer 50) ///
		XWidth(real 0.0) YWidth(real 0.0) Saving(string) REPLACE NOIsily COLOR NODRAW *] 

	local ix: word 2 of `varlist'
	local iy: word 1 of `varlist'
	local ixl: variable label `ix'
	local iyl: variable label `iy'	
	if `"`ixl'"'=="" { 
		local ixl "`ix'"
	}
	if `"`iyl'"'=="" { 
		local iyl "`iy'"
	}
	preserve

	local kernel=`"Gaussian"'
	marksample use
	qui count if `use'
	if r(N)==0 { 
		error 2000 
		} 
	tempvar mx my zx zy y

	qui gen double `y'=.
	qui gen double `zx'=.
	qui gen double `zy'=.
	qui gen double `mx'=.
	qui gen double `my'=.

	if `"`n'"'!= `""' {
		if `n' <= 1 { 
			local n = 50 
			}
		if `n' > _N { 
			local n = _N
			noi di in gr `"(n() set to "' `n' `")"'
		}
	}

	forv j = 1/`n' {
		qui gen double d`j'=.
		}
		
	if "`weight'" != "" {
		tempvar tt
		qui gen double `tt' `exp' if `use'
		qui summ `tt', meanonly
		if "`weight'" == "aweight" {
			qui replace `tt' = `tt'/r(mean)
		}
	}
	else {
		local tt = 1
	}

	quietly summ `ix' [`weight'`exp'] if `use', detail
	local nmeanx = r(mean)
	local nsigx = r(Var)

	tempname xwwidth ywwidth xybw
	scalar `xwwidth' = `xwidth'
	if `xwwidth' <= 0.0 { 
		scalar `xwwidth' = min( sqrt(r(Var)), (r(p75)-r(p25))/1.349)
		scalar `xwwidth' = 0.9*`xwwidth'/(r(N)^.20)
	}

	tempname xdelta xwid ydelta ywid wid
	scalar `xdelta' = (r(max)-r(min)+2*`xwwidth')/(`n'-1)
//	scalar `xwid'   = r(N) * `xwwidth'
	qui replace `mx' = r(min)-`xwwidth'+(_n-1)*`xdelta' in 1/`n'
	
	quietly summ `iy' [`weight'`exp'] if `use', detail
	local nmeany = r(mean)
	local nsigy = r(Var)
	
	scalar `ywwidth' = `ywidth'
 	if `ywwidth' <= 0.0 { 
		scalar `ywwidth' = min( sqrt(r(Var)), (r(p75)-r(p25))/1.349)
		scalar `ywwidth' = 0.9*`ywwidth'/(r(N)^.20)
	}

	scalar `ydelta' = (r(max)-r(min)+2*`ywwidth')/(`n'-1)
//	scalar `ywid'   = r(N) * `ywwidth'
	qui replace `my' = r(min)-`ywwidth'+(_n-1)*`ydelta' in 1/`n'
//	scalar `wid' = 0.5*(`xwid'+`ywid')
	scalar `xybw' = `xwwidth'*`ywwidth'

	local con1 = 2*_pi
* double loop, over both mx and my 
	qui forv i = 1/`n' {
		replace `zx'=(`ix'-`mx'[`i'])/(`xwwidth') if `use'
		forv j = 1/`n' {
			replace `zy'=(`iy'-`my'[`j'])/(`ywwidth') if `use'
			replace `y'= `tt'*exp(-0.5*((`zx')^2+(`zy')^2))/`con1'
			summ `y', meanonly
			replace d`j' = r(mean)/`xybw' in `i'
//			replace d`j'=(r(sum))/`wid' in `i'
			}
		}
	qui forv j = 1/`n' {
		replace d`j'=0 if d`j'==. in 1/`n'
		}

	label var `mx' `"`ixl'"'
	label var `my' `"`iyl'"'
	rename `mx' _`ix'
	rename `my' _`iy'

	local qqq "quietly"
	if "`noisily'" != "" {
		local qqq "noisily"
		}
	`qqq' {
	keep in 1/`n'
	keep _`ix' _`iy' d1-d`n' 
 	gen _i = _n
 	forv i = 1/`n' {
 		g y`i'= _`iy'[`i']
 		}

	reshape long d y, i(_i)
	drop _`iy'
	rename y _`iy'
	label var _`iy' `"`iyl'"'
	label var d "Density"
	format d %5.3f

	if "`saving'" ~= "" {
		save `saving',`replace'
		local sss "saving(`saving',replace)"
		}
	if "`nodraw'" != "nodraw" {
		if `sv' < 12.1 {
			surface _`ix' _`iy' d, xtitle(`"`ixl'"') ///
			ytitle(`"`iyl'"') ztitle("density") `sss'
		} 
		else if "`color'" == "" {
		    tw contourline d _`iy' _`ix', xtitle(`"`ixl'"') ///
			ytitle(`"`iyl'"')  `sss' ///
			ti("Bivariate density plot" "kernel=`kernel'") `options'
		}
		else {
			tw contour d _`iy' _`ix', xtitle(`"`ixl'"') ///
			ytitle(`"`iyl'"')  `sss' ///
			ti("Bivariate density plot" "kernel=`kernel'") `options'
		}
	}
	}
	restore 
	return local kernel "Gaussian"
	return local xvar "`ix'"
	return local yvar "`iy'"
	return local N "`n'"
end	
