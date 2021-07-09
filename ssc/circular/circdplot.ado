*! NJC 2.1.0 6 August 2004 
* NJC 2.0.1 2 April 2004
* NJC 2.0.0 9 January 2004
* NJC 1.1.1 23 December 1998
* NJC 1.1.0 16 December 1998
* NJC 1.0.0 9 May 1997
* raw data plot for circular data with point symbols
program circdplot
	version 8.0
	syntax varname(numeric) [if] [in] [, ///
	BY(str) SUBtitle(str asis) round(int 1) RESULTant(str asis) ///
	unit(numlist max=1 >=1) /// 
	CTICk(numlist) CLAbel(str asis) TICKlength(real 0.05) fudge(real 1) * ]
	
	if d(`c(born_date)') < 16275 { 
		di as txt "please update your Stata to use this command"
		exit 0 
	} 	

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
		syntax [, ARROWHEADlength(real 0.1) * ] 
		local resultant `options' 
		local options `saveoptions' 
		local varlist `savevarlist' 
	} 
	else local arrowheadlength 0.1
	
	if trim(`"`clabel'"') == "" { 
		local clabel `"0 "N" 90 "E" 180 "S" 270 "W""' 
		Clabelparse `clabel' 
	} 
	else if trim("`clabel'") != "none" {
		if index(`"`clabel'"', `"""') Clabelparse `clabel' 
		else { 
			capture numlist `"`clabel'"' 
			if _rc Clabelparse `clabel' 
			else   Clabelparse `r(numlist)' 
		}	
	} 	
	else local clabel 

	preserve
	tempvar xsum ysum xcirc ycirc freq doty dotx resy resx labely labelx
	tempvar ticky tickx 
	tempname XSUM YSUM vecmean veclng vecstr

	qui {
		keep if `touse'                        

		// trigonometry 
		gen `xsum' = sum(sin((`varlist'*_pi)/180))
		gen `ysum' = sum(cos((`varlist'*_pi)/180))
		local XSUM = `xsum'[_N]
		local YSUM = `ysum'[_N]
		Atan2 `XSUM' `YSUM'
		scalar `vecmean' = r(angle) 
		scalar `veclng' = sqrt((`XSUM')^2 + (`YSUM')^2)
		scalar `vecstr' = `veclng' / _N

		// rounding to bins: default 1 deg 
		replace `varlist' = round(`varlist',`round')
		replace `varlist' = 0 if `varlist' == 360
		
		// coordinates of point symbols 
		bysort `varlist': gen `freq' = _N
		if "`unit'" != "" {  
			if `unit' != 1 { 
				by `varlist' : replace `freq' = ///
						        ceil(_N / `unit') 
				by `varlist' : keep if _n <= `freq'[_N]
			} 	
		} 	
		su `freq', meanonly
		by `varlist': replace `freq' = 1 + (_n * `fudge') / r(max) 
		gen `doty' = `freq' * cos((`varlist'*_pi)/180)
	        gen `dotx' = `freq' * sin((`varlist'*_pi)/180)

*	old code, abandoned 7 August 2004 
* 	// circle is just one connected line 
* 	if _N < 2001 set obs 2001
* 	gen `ycirc' = sin(2 * _pi * (_n-1)/2000) in 1/2001
* 	gen `xcirc' = cos(2 * _pi * (_n-1)/2000) in 1/2001 

		// arrow for resultant 
		local ahl `arrowheadlength' 
		gen `resy' = 0 in 1 
		replace `resy' = `vecstr' * cos(`vecmean'*_pi/180) in 2 
	        gen `resx' = 0 in 1 
		replace `resx' = `vecstr' * sin(`vecmean'*_pi/180) in 2 
	        replace `resy' = ///
	`resy'[2] + `ahl' * cos((`vecmean'*_pi/180) + (5 * _pi / 6)) in 3 
		replace `resx' = ///
	`resx'[2] + `ahl' * sin((`vecmean'*_pi/180) + (5 * _pi / 6)) in 3
		// 4 is missing, to inhibit connect 
		replace `resy' = `vecstr' * cos(`vecmean'*_pi/180) in 5 
		replace `resx' = `vecstr' * sin(`vecmean'*_pi/180) in 5 
	        replace `resy' = ///
	`resy'[2] + `ahl' * cos((`vecmean'*_pi/180) + (7 * _pi / 6)) in 6 
		replace `resx' = ///
	`resx'[2] + `ahl' * sin((`vecmean'*_pi/180) + (7 * _pi / 6)) in 6
	
		if `"`clabel'"' != "" {
			local f = 1 - `ticklength' 
			local i = 1
			local j = 2
			local k = 1 
			
			foreach c of local clabelnumb { 
				local x = sin(`c' * _pi/180) 
				local y = cos(`c' * _pi/180)
				local fx = `f' * `x' 
				local fy = `f' * `y' 
				
				local cmd = cond(`i' == 1, "gen", "replace") 
				`cmd' `labelx' = `x' in `i'
				replace `labelx' = `fx' in `j' 
				`cmd' `labely' = `y' in `i'
				replace `labely' = `fy' in `j'
				
				local i = `i' + 3 
				local j = `j' + 3 

				local K : word `k++' of `clabeltext' 
				Compasspoint C `c' 
				local addtext ///
				`"`addtext' text(`fy' `fx' "`K'", place(`C'))"' 
			}	
			
			local Clabel ///
			"line `labely' `labelx', clp(solid) cmissing(n)"
		} 	
		
		if "`ctick'" != "" {
			local f = 1 - `ticklength' 
			local i = 1
			local j = 2
			local k = 1 
			
			foreach c of local ctick { 
				local x = sin(`c' * _pi/180) 
				local y = cos(`c' * _pi/180)
				local fx = `f' * `x' 
				local fy = `f' * `y' 
				
				local cmd = cond(`i' == 1, "gen", "replace") 
				`cmd' `tickx' = `x' in `i'
				replace `tickx' = `fx' in `j' 
				`cmd' `ticky' = `y' in `i'
				replace `ticky' = `fy' in `j'
				
				local i = `i' + 3 
				local j = `j' + 3 
			}	
			
			local Ctick ///
			"line `ticky' `tickx', clp(solid) cmissing(n)"
		} 	
	} 

        if `"`subtitle'"' == "" {
        	local subtext : ///
		di "mean direction " %2.1f `vecmean' char(176) /// 
                ": vector strength " %4.3f `vecstr'
                // char 176 summons up the degree symbol 
		local subtitle "sub(`subtext', pos(6) size(medium))" 
        }
        else local subtitle `"sub(`subtitle')"' 

	local size = 1.1 + `fudge' 

	// draw the graph 
	twoway line `resy' `resx', ///
	cmissing(n) clp(solid) clw(medthick) `resultant' ///
	|| `Clabel' `addtext' /// 
	|| `Ctick'  ///
	|| function sqrt(1 - x * x) , ra(-1 1) clp(solid) clcolor(blue) ///  
	|| function -sqrt(1 - x * x), ra(-1 1) clp(solid) clcolor(blue) ///  
	|| scatter `doty' `dotx', ms(oh) /// 
	plotregion(margin(zero) style(none)) legend(off) aspect(1) ///
	ysc(r(-`size' `size') off fill) xscale(r(-`size' `size') off fill) /// 
	yla(, nogrid) `subtitle' `options' ///
	// blank 
end

program Clabelparse
* NJC 1.0.0 5 January 2004
	version 8.0
	local j = 0 
	while `"`0'"' != "" { 
		gettoken t 0 : 0, qed(q) 
	        if `q' { 
			if `j' == 0 | "`n_or_s_prev'" == "S" { 
				di as err "invalid clabel()"
				exit 198 
			} 
			else { 
				local S `"`S'`"`t'"' "' 
				local n_or_s_prev "S"
			} 
		} 
		else { 
			local ++j 
			local N "`N'`t' " 
			if "`n_or_s_prev'" == "N" { 
				local S `"`S'`"`prev'"' "' 
			} 
			local prev `t'
			local n_or_s_prev "N" 
		}
	}

	if "`n_or_s_prev'" == "N" local S `"`S'"`prev'""' 
	c_local clabelnumb `N'
	c_local clabeltext `"`S'"' 
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

program Compasspoint 
// label placement is inward of tick, i.e. South for tick at North. 
* 1.0.0 NJC 19 Dec 2003 
	version 8 
	local 2 = round(`2',45) 
	
	if `2' == 0          local C "s"
	else if `2' == 45    local C "sw"
	else if `2' == 90    local C "w"
	else if `2' == 135   local C "nw"
	else if `2' == 180   local C "n"
	else if `2' == 225   local C "ne"
	else if `2' == 270   local C "e"
	else if `2' == 315   local C "se"
	else if `2' == 360   local C "s"
	
	c_local `1' "`C'" 
end 
  
