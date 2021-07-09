*! NJC 2.1.0 7 August 2004
* NJC 2.0.2 2 April 2004 
* NJC 2.0.1 29 January 2004 
* NJC 2.0.0 22 December 2003 
* NJC 1.5.0 15 December 1998
* NJC 1.4.0 9 May 1997
* NJC 1.3.2 30 October 1996
* cumulative vector plot for circular data
program circvplot 
	version 8.0
	syntax varname(numeric) [if] [in] [, ///
	SUBtitle(str asis) RESULTant(str asis) ROTate(real 0) BY(str) * ]
	
	if "`by'" != "" { 
		di as err "by() not supported"
		exit 198 
	} 
	
	marksample touse
	qui count if `touse' 
	if r(N) == 0 error 2000

	if `"`resultant'"' != "" { 
		local saveoptions `options' 
		local savevarlist `varlist' 
		local 0 , `resultant' 
		syntax [, ARROWHEADfactor(real 1) * ] 
		local resultant `options' 
		local options `saveoptions' 
		local varlist `savevarlist' 
	}
	else local arrowheadfactor 1 
	
	preserve
	tempvar xsum ysum newang freq resy resx 
	tempname XSUM YSUM vecmean veclng vecstr

	qui {
		keep if `touse'           

		// trigonometry 
		// first pass to get vector mean etc.  
		gen `xsum' = sum(sin((`varlist'*_pi)/180))
		gen `ysum' = sum(cos((`varlist'*_pi)/180))
		local XSUM = `xsum'[_N]
		local YSUM = `ysum'[_N]
		Atan2 `XSUM' (`YSUM')
		scalar `vecmean' = r(angle)
		scalar `veclng' = sqrt((`XSUM')^2 + (`YSUM')^2)
		scalar `vecstr' = `veclng' / _N

		// restart opposite vector mean, optional rotate 
		gen `newang' = mod(`varlist' - `vecmean' + 180 + `rotate',360)
		
		// reduction to one value per bin 
		bysort `newang':  gen `freq' = _N
		by `newang': keep if _n == 1

		// second pass to recalculate sums 
		set obs `=max(6, _N + 1)' 
		replace `xsum' = 0 in 1
		replace `xsum' = ///
		sum(`freq'[_n-1] * sin((`varlist'[_n-1] * _pi) / 180)) in 2/l
		replace `ysum' = 0 in 1
		replace `ysum' = ///
		sum(`freq'[_n-1] * cos((`varlist'[_n-1] * _pi) / 180)) in 2/l    
		
		// arrow for resultant 
		local ahl = 0.07 * `veclng' * `arrowheadfactor'  
		gen `resy' = 0 in 1 
		replace `resy' = `ysum'[_N] in 2 
	        gen `resx' = 0 in 1 
		replace `resx' = `xsum'[_N]  in 2 
	        replace `resy' = ///
		`resy'[2] + `ahl' * cos((`vecmean'*_pi/180) + (5 * _pi / 6)) in 3 
		replace `resx' = ///
		`resx'[2] + `ahl' * sin((`vecmean'*_pi/180) + (5 * _pi / 6)) in 3
	
		// 4 is missing, to inhibit connect 
		
		replace `resy' = `resy'[2] in 5 
		replace `resx' = `resx'[2] in 5  
	        replace `resy' = ///
		`resy'[2] + `ahl' * cos((`vecmean'*_pi/180) + (7 * _pi / 6)) in 6 
		replace `resx' = ///
		`resx'[2] + `ahl' * sin((`vecmean'*_pi/180) + (7 * _pi / 6)) in 6

	        if `"`subtitle'"' == "" {
			// char 176 summons up the degree symbol 
			local subtext : ///
			di "mean direction " %2.1f `vecmean' char(176) /// 
			": vector strength " %4.3f `vecstr'
			local subtitle "sub(`subtext', pos(6))" 
		}
		else local subtitle `"sub(`subtitle')"' 
	}
	
	// aspect ratio: for Stata >= 23 Jul 2004  
	if d(`c(born_date)') >= 16275 { 
		su `xsum', meanonly 
		local xrange = r(max) - r(min) 
		su `ysum', meanonly 
		local yrange = r(max) - r(min) 
		local ratio = `yrange' / `xrange' 
		local aspect "aspect(`ratio')" 
	} 

	// draw the graph
	twoway line `resy' `resx', ///
	cmissing(n) clp(solid) clw(medthick) `resultant' ///
	|| line `ysum' `xsum', clp(solid) /// 
	plotregion(style(none) margin(zero)) yscale(off) xscale(off) legend(off) /// 
	`subtitle' `aspect' `options' ///
	// blank 

end

program Atan2, rclass 
* 1.3.0 NJC 18 Dec 2003 
* 1.2.0 NJC 14 July 1998
	version 8.0
	tempname at

	local sign1 = sign(`1')
	local sign2 = sign(`2')

	if (`sign1' == 1 & `sign2' == 1) | ((`sign1' == 0) & `sign2' == 1) {
	    scalar `at' = atan(`1'/`2')
	}
	else if `sign1' == 1 & `sign2' == 0 {
	    scalar `at' = _pi / 2
	}
	else if `sign1' == -1 & `sign2' == 0 {
	    scalar `at' = 3 * _pi / 2
	}
	else if `sign2' ==  -1 {
	    scalar `at' = _pi + atan(`1'/`2')
	}
	else if `sign1' == -1 & `sign2' == 1 {
	    scalar `at' = 2 * _pi + atan(`1'/`2')
	}
  	else if `sign1' == 0 & `sign2' == 0 { 
		scalar `at' = . 
	}		
 
	return scalar angle = (180 / _pi) * `at'
end

