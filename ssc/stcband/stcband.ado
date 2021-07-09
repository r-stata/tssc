*! version 1.0.1 29Jul2008
*! Nair (EP) and Hall-Wellner confidence band for survival and cumulative hazard function
program define stcband, rclass sortpreserve
	version 9.0
	syntax [if] [in] , [ GENHIgh(name) GENLOw(name) ///
		  NAIR TLOwer(real -1) TUPper(real -1) NA ///
		  TRANsform(name) Level(integer 95) noGraph * ] // graphic options
	st_is 2 analysis
	marksample touse
	qui replace `touse' = 0 if _st==0
	if "`genhigh'"!="" {
		cap confirm new var `genhigh' 
		if _rc {
			di in smcl as err "{p}`genhigh' already defined.{p_end}"
			exit 110
		}
	}	
	if "`genlow'"!="" {
		cap confirm new var `genlow' 
		if _rc {
			di in smcl as err "{p}`genlow' already defined.{p_end}"
			exit 110
		}
	}	
	if "`nair'"!=""	local method "nair"
	else		local method "hw"
	if `tlower' < 0 local tlower
	if `tupper' < 0 local tupper
	su _t if `touse' & _d , meanonly
	if "`tupper'"!="" {
		cap assert `tupper' <= `r(max)'
		if _rc {
			di in smcl as err "{p}Upper time limit is greater than the maximum observed risk time.{p_end}"
			exit 198
		}
	}
	else local tupper = `r(max)'
	if "`tlower'"!="" {
		su _t if `touse' & _d & _t<=`tlower', meanonly
		if "`r(max)'" != ""	local tlower = `r(max)'
		else {
			if "`method'" == "nair" {
				di in smcl as err "{p}Equal precision (Nair) bands does not allow lower time limit less than the minimum observed risk time.{p_end}"
				exit 198
			}
			else local tlower = 0
		}
	}
	else	local tlower = `r(min)'
	qui count if _t>=`tlower' & _t<=`tupper' & `touse' & _d
	if r(N)<1 { 
		di in smcl as err "{p}No observations in the range of time of confidence band{p_end}"
		exit 2000
	}
	if "`transform'"!="" {
		if "`transform'" != "log" & "`transform'" != "linear" & "`transform'" != "arcsine" {
			di in smcl as err "{p}transform() option incorrectly specified. Choose: linear, log or arcsine.{p_end}"
			exit 198
		}
	}
	else local transform "log"
	if `level' != 90  & `level' != 95 & `level' != 99 {
			di in smcl as err "{p}Confidence level for simultaneous bands must be either 90, 95 or 99.{p_end}"
			exit 198
	}
	
	_get_gropts , graphopts(`options') getallowed(LColor LPattern LWidth YLAbel SAving legend scheme xsize ysize plot addplot)
	local options `"`s(graphopts)'"'
	local lpattern `"`s(lpattern)'"'
	local lcolor `"lc(`s(lcolor)')"'
	local lwidth `"lw(`s(lwidth)')"'
	local ylabel `"`s(ylabel)'"'
	local saving `"`s(saving)'"'
	_check4gropts saving, opt(`saving')
	local scheme `"`s(scheme)'"'
	local legend `"`s(legend)'"'
	_check4gropts legend, opt(`legend')
	local plot `"`s(plot)'"'
	local addplot `"`s(addplot)'"'
	local xsize `"`s(xsize)'"'
	local ysize `"`s(ysize)'"'
	if "`saving'" != "" local saving `"saving(`saving')"'
	if "`scheme'" != "" local scheme `"scheme(`scheme')"'
	if "`xsize'" != ""   local xsize `"xsize(`xsize')"'
	if "`ysize'" != ""   local ysize `"ysize(`ysize')"'

	qui count if `touse'
	local n = r(N)
	tempvar s se fa hi_s lo_s time
	tempname al au vperc hperc
	if "`na'" ==""{
		sts gen `s'=s `se'=se(s) if `touse'
		qui replace `se'=`se'^2/`s'^2
	}
	else {
		sts gen `s'=na `se'=se(na) if `touse'
		qui replace `se'=`se'^2
	}
	* Computing al
	g byte `fa' = float(_t)<=float(`tlower') & _d & `touse'
	sort `fa' _t
	scalar `al' = `n' * `se'[_N] / (1+`n'*`se'[_N])
	* Computing au
	qui replace `fa' = float(_t)<=float(`tupper') & _d & `touse'
	sort `fa' _t
	scalar `au' = `n' * `se'[_N] / (1+`n'*`se'[_N])
	sca `vperc' = 1 - (ceil(`au'/2*100)-`au'/2*100)
	sca `hperc' = 1 - (ceil(`al'/2*100)-`al'/2*100)
	qui findcrit `level' `al' `au' `vperc' `hperc' `method' 
*	scalar list
	ret scalar cr = `r(cr)'
	if "`na'" == "" {
		if "`method'"=="hw" {
			if "`transform'"=="log" {
				tempvar theta
				qui g double `theta' = exp( (`r(cr)'*(1+`n'*`se')) / (sqrt(`n')*ln(`s')) ) ///
					if `touse' & float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
				qui g `hi_s' = `s'^`theta'
				qui g `lo_s' = `s'^(1/`theta')
			}
			else if "`transform'"=="arcsine" {
				qui g `lo_s' = sin( max(0,asin(sqrt(`s'))     - 0.5*(`r(cr)'*(1+`n'*`se'))/sqrt(`n') * sqrt(`s'/(1-`s'))) )^2 if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower')
				qui g `hi_s' = sin( min(_pi/2,asin(sqrt(`s')) + 0.5*(`r(cr)'*(1+`n'*`se'))/sqrt(`n') * sqrt(`s'/(1-`s'))) )^2 if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
			}
			else if "`transform'"=="linear" {
				qui g `lo_s' = `s' - (`r(cr)'*(1+`n'*`se')/sqrt(`n')) *`s' if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower')
				qui g `hi_s' = `s' + (`r(cr)'*(1+`n'*`se')/sqrt(`n')) *`s' if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower')
				qui count if `lo_s' < 0
				if `r(N)'>0 {
					qui replace `lo_s' = 0 if `lo_s'<0 & `touse' ///
						& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
					di _n in smcl in gr `"{p}Some value of low confidence band lower than 0 has been changed to 0.{p_end}"'
				}
				qui count if `hi_s' > 1
				if `r(N)'>0 {
					qui replace `hi_s' = 1 if `hi_s'>1 & `touse' ///
						& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
					di _n in smcl in gr `"{p}Some value of high confidence band greater than 1 has been reduced to 1.{p_end}"'
				}
			}
		}
		if "`method'"=="nair" {
			if "`transform'"=="log" {
				tempvar theta
				qui g double `theta' = exp( `r(cr)'*sqrt(`se')/ln(`s') ) if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
				qui g `hi_s' = `s'^`theta'
				qui g `lo_s' = `s'^(1/`theta')
			}
			else if "`transform'"=="arcsine" {
				qui g `lo_s' = sin( max(0,asin(sqrt(`s'))     - 0.5*(`r(cr)'*sqrt(`se')) * sqrt(`s'/(1-`s'))) )^2 if `touse' ///
						& float(_t)<=float(`tupper') & float(_t)>=float(`tlower')
				qui g `hi_s' = sin( min(_pi/2,asin(sqrt(`s')) + 0.5*(`r(cr)'*sqrt(`se')) * sqrt(`s'/(1-`s'))) )^2 if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
			}
			else if "`transform'"=="linear" {
				qui g `lo_s' = `s' - `r(cr)'*sqrt(`se')*`s' if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower')
				qui g `hi_s' = `s' + `r(cr)'*sqrt(`se')*`s' if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower')
				qui count if `lo_s' < 0
				if `r(N)'>0 {
					qui replace `lo_s' = 0 if `lo_s'<0 & `touse' ///
						& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
					di _n in smcl in gr `"{p}Some value of low confidence band lower than 0 has been changed to 0.{p_end}"'
				}
				qui count if `hi_s' > 1
				if `r(N)'>0 {
					qui replace `hi_s' = 1 if `hi_s'>1 & `touse' ///
						& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
					di _n in smcl in gr `"{p}Some value of high confidence band greater than 1 has been reduced to 1.{p_end}"'
				}
			}
		}
	}

	if "`na'" != "" {
		if "`method'"=="hw" {
			if "`transform'"=="log" {
				tempvar theta
				qui g double `theta' = exp( (`r(cr)'*(1+`n'*`se')) / (sqrt(`n')*`s')  ) ///
					if `touse' & float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
				qui g `hi_s' = `s'*`theta'
				qui g `lo_s' = `s'/`theta'
			}
			else if "`transform'"=="arcsine" {
				qui g `lo_s' = -2*ln( sin( min( _pi/2,asin(exp(-`s'/2)) + 0.5*(`r(cr)'*(1+`n'*`se')/sqrt(`n'))*(exp(`s')-1)^-0.5 ))) if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
				qui g `hi_s' = -2*ln( sin( max( 0,asin(exp(-`s'/2)) - 0.5*(`r(cr)'*(1+`n'*`se')/sqrt(`n'))*(exp(`s')-1)^-0.5 ))) if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
			}
			else if "`transform'"=="linear" {
				qui g `lo_s' = `s' - (`r(cr)'*(1+`n'*`se')/sqrt(`n')) if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower')
				qui g `hi_s' = `s' + (`r(cr)'*(1+`n'*`se')/sqrt(`n')) if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower')
				qui count if `lo_s' < 0
				if `r(N)'>0 {
					qui replace `lo_s' = 0 if `lo_s'<0 & `touse' ///
						& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
					di _n in smcl in gr `"{p}Some value of low confidence band lower than 0 has been changed to 0.{p_end}"'
				}
			}
		}
		if "`method'"=="nair" {
			if "`transform'"=="log" {
				tempvar theta
				qui g double `theta' = exp( `r(cr)'*sqrt(`se')/`s' ) if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
				qui g `hi_s' = `s'*`theta'
				qui g `lo_s' = `s'/`theta'
			}
			else if "`transform'"=="arcsine" {
				qui g `lo_s' = -2*ln( sin( min( _pi/2,asin(exp(-`s'/2)) + 0.5*(`r(cr)'*sqrt(`se'))*(exp(`s')-1)^-0.5 ))) if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
				qui g `hi_s' = -2*ln( sin( max( 0,asin(exp(-`s'/2)) - 0.5*(`r(cr)'*sqrt(`se'))*(exp(`s')-1)^-0.5 ))) if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
			}
			else if "`transform'"=="linear" {
				qui g `lo_s' = `s' - `r(cr)'*sqrt(`se') if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower')
				qui g `hi_s' = `s' + `r(cr)'*sqrt(`se') if `touse' ///
					& float(_t)<=float(`tupper') & float(_t)>=float(`tlower')
				qui count if `lo_s' < 0
				if `r(N)'>0 {
					qui replace `lo_s' = 0 if `lo_s'<0 & `touse' ///
						& float(_t)<=float(`tupper') & float(_t)>=float(`tlower') 
					di _n in smcl in gr `"{p}Some value of low confidence band lower than 0 has been changed to 0.{p_end}"'
				}
			}
		}
	}

**To generate varlist
	if "`method'" == "hw" local v "H-W"
	if "`method'" == "nair" local v "EP"
	if "`genhigh'"!="" {
		qui g double `genhigh'  = `hi_s'
		label var `genhigh' `"`v' `level' Upper Band"' 
	}	
	if "`genlow'"!="" {
		qui g double `genlow'  = `lo_s'
		label var `genlow' `"`v' `level' Lower Band"'
	}	

**To graph
	if "`graph'"==""{
		label var `hi_s' `"`v' `level' Upper Band"' 
		label var `lo_s' `"`v' `level' Lower Band"'
		if "`scheme'" == "" {
			cap findfile scheme-lean2.scheme
			if !_rc 	local scheme `"scheme(lean2)"'
		}
		if "`lpattern'"=="" {
			local lpattern `"lpattern(l - -)"'
		}
		else local lpattern lp(`lpattern')"'
		if "`xtitle'"=="" {
			local xtitle `"xtitle("Time")"'
		}
		if "`ytitle'"=="" {
			if "`na'" == "" local ytitle `"ytitle("Survival Probability")"'
			else		local ytitle `"ytitle("Cumulative Hazard")"'
		}
		if `"`legend'"'==`""' {
			if "`na'"==""	local legend `"legend(pos(2) col(1) ring(0))"'
			else		local legend `"legend(pos(11) col(1) ring(0))"'
		}
		else local legend `"legend(`legend')"'
		if "`ylabel'"=="" {
			local ylabel `"ylabel(,nogrid)"'
		}
		else local ylabel `"ylabel(`ylabel')"'

		qui g `time' = _t if `touse'
		qui replace `time' = `tlower' if _t<`tlower' & `touse'
		qui replace `time' = `tupper' if _t>`tupper' & `touse'
		qui {
			replace `s' = . if _t > `tupper' & `touse'
			replace `hi_s' = . if _t > `tupper' & `touse'
			replace `lo_s' = . if _t > `tupper' & `touse'
			sort `touse' _t
			replace `s' = `s'[_n-1] if `s'==. & `touse'
			replace `hi_s' = `hi_s'[_n-1] if `hi_s'==. & `touse'
			replace `lo_s' = `lo_s'[_n-1] if `lo_s'==. & `touse'
			replace `s' = . if _t < `tlower' & `touse'
			replace `hi_s' = . if _t < `tlower' & `touse'
			replace `lo_s' = . if _t < `tlower' & `touse'
			if "`na'" ==""	sort `touse' `s' _t
			else	       gsort `touse' -`s' _t
			replace `s' = `s'[_n-1] if `s'==. & `touse'
			replace `hi_s' = `hi_s'[_n-1] if `hi_s'==. & `touse'
			replace `lo_s' = `lo_s'[_n-1] if `lo_s'==. & `touse'
		}
		twoway	(line `s' `hi_s' `lo_s' `time' , sort c(J J J) `lpattern' `lcolor' `lwidth' /// 
			`title' `ytitle' `xtitle' `legend' `saving' `scheme' `ylabel' `ysize' `xsize'  `options')  ///
				|| `plot' || `addplot'
	}
end


program define findcrit, rclass
	* Computing critical values from the Hall-Wellner and Nair tables
	args level al au vperc hperc method
	preserve
	tempname au_c al_c sc1 sc2 sc3 sc4 int1 int2 int3 int4 crit
	tempvar c1 c2 c3 c4
	if "`method'"=="hw"	cap findfile HallWellnerTables.dta
	if _rc {
		di _n as err `"HallWellnerTables.dta not found. This file must be in one of the {help adopath:ado-path} directories"'
		exit 601 
	}
	if "`method'"=="nair"	cap findfile NairTables.dta
	if _rc {
		di _n as err `"NairTables.dta not found. This file must be in one of the {help adopath:ado-path} directories"'
		exit 601 
	}
	local fileful `"`r(fn)'"'
	use `"`fileful'"',clear
	scalar `au_c' = round(`au',.02)
	if  `au_c' > `au'  sca `au_c' = scalar(`au_c') - .02
	sca `al_c' = round(`al',.02)
	if  `al_c' > `al'  sca `al_c' = scalar(`al_c') - .02
	if "`method'"=="hw" {
		g byte `c1' = ( float(lower)==float(scalar(`al_c')) )       & (float(upper)==float(scalar(`au_c')) )
		g byte `c2' = ( float(lower)==float(scalar(`al_c') + .02) ) & (float(upper)==float(scalar(`au_c')) )
		g byte `c3' = ( float(lower)==float(scalar(`al_c')) )       & (float(upper)==float(scalar(`au_c') + .02) ) 
		g byte `c4' = ( float(lower)==float(scalar(`al_c') + .02) ) & (float(upper)==float(scalar(`au_c') + .02) )
	}
	else {
		tempname al_nc au_nc
		sca `al_nc' = max(`al_c',.02)
		sca `au_nc' = min(`au_c'+.2,.98)		
		g byte `c1' = ( float(lower)==float(scalar(`al_nc')) )       & (float(upper)==float(scalar(`au_c'))  )
		g byte `c2' = ( float(lower)==float(scalar(`al_c') + .02) )  & (float(upper)==float(scalar(`au_c'))  )
		g byte `c3' = ( float(lower)==float(scalar(`al_nc')) )       & (float(upper)==float(scalar(`au_nc')) ) 
		g byte `c4' = ( float(lower)==float(scalar(`al_c') + .02) )  & (float(upper)==float(scalar(`au_nc')) )
	}
	
	sort `c1'
	scalar `sc1' = k`level'[_N] 
	sort `c2'
	scalar `sc2' = k`level'[_N] 
	sort `c3'
	scalar `sc3' = k`level'[_N] 
	sort `c4'
	scalar `sc4' = k`level'[_N] 
	if `sc2' == . scalar `sc2' = (`sc1'+`sc4')/2
*	scalar list `sc1' `sc2' `sc3' `sc4'
	*interpolations
	scalar `int1' = scalar(`sc1') - abs(scalar(`sc1')-scalar(`sc2'))* `hperc'
	scalar `int2' = scalar(`sc4') - abs(scalar(`sc4')-scalar(`sc2'))* `vperc'
	scalar `int3' = scalar(`sc3') - abs(scalar(`sc3')-scalar(`sc4'))* `hperc'
	scalar `int4' = scalar(`sc3') - abs(scalar(`sc3')-scalar(`sc1'))* `vperc'
	scalar `crit' = ( scalar(`int1')*(1-`vperc') + scalar(`int4')*(1-`hperc') + ///
		scalar(`int2')*`hperc' + scalar(`int3')*`vperc' ) / 2
	ret scalar cr = scalar(`crit')
end
