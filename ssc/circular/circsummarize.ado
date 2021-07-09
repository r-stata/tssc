*! 2.0.3 NJC 2 June 2004
* 2.0.2 NJC 6 May 2004
* 2.0.1 NJC 30 March 2004
* 2.0.0 NJC 13 January 2004
* 1.3.3 NJC 10 January 1999
* 1.3.2 NJC 1 January 1999
* 1.3.1 NJC 15 December 1998
* 1.3.0 NJC 15 July 1998
* 1.2.2 NJC 29 October 1996
* mean direction, vector strength and circular range of circular data
* with confidence interval for mean and Rayleigh and Kuiper tests

program circsummarize, sort  
        version 8.0
        syntax varlist(numeric) [if] [in] [fweight aweight] /// 
	[ , BY(varname) CI Level(int $S_level) RAYleigh KUIper Detail ] 

	marksample use, novarlist 
	qui count if `use' 
	if r(N) == 0 error 2000 

	tokenize `varlist'
	local nvars : word count `varlist'
	
        if `nvars' > 1 & "`by'" != "" {
                di as err "too many variables specified"
                exit 103
        }
	
	if "`by'" != "" local which "        Group "
	else            local which "     Variable "
	// cond() strips leading spaces 

        if "`detail'" != "" {
                local ci "ci"
                local rayleigh "rayleigh"
                local kuiper "kuiper"
        }

        local ndash 31
        if "`ci'`rayleigh'`kuiper'" != "" {
                local con "_c"
                if "`ci'" != ""       local ndash = `ndash' + 13 
                if "`rayleigh'" != "" local ndash = `ndash' + 10 
                if "`kuiper'" != ""   local ndash = `ndash' + 8 
        }

        di _n as txt "`which'{c |}   Obs"  ///
	    _col(26) "Mean"                ///
            _col(32) "Strength"            ///
	    _col(42) "Range" `con'
	    
        if "`rayleigh'`kuiper'" != "" local con2 "_c" 
        if "`ci'" != ""       di as txt "   `level'% limits" `con2'
        if "`kuiper'" != ""           local con3 "_c"
        if "`rayleigh'" != "" di as txt "  Rayleigh" `con3' 
        if "`kuiper'" != ""   di as txt "  Kuiper" 
        di as txt " {hline 13}{c +}{hline `ndash'}"

        qui while "`1'" != "" {
	        tempvar touse group
                mark `touse' `if' `in'
                markout `touse' `1'
                bysort `touse' `by' : gen `group' = _n == 1 if `touse'
                replace `group' = sum(`group')
                local max = `group'[_N]
		
                forval j = 1/`max' {
                        Summ `1' if `group' == `j' [`weight' `exp'], ///
                        `ci' level(`level') `rayleigh' `kuiper'
			
                        if "`by'" != "" {
                                local name = `by'[_N]
                                local bylab : value label `by'
                                if "`bylab'" != "" {
                                        local name : label `bylab' `name'
                                }
                        }
                        else local name "`1'"
			
                        if length("`name'") > 12 {
				if "`by'" == "" local name = abbrev("`name'",12) 
			        else local name = substr("`name'",1,12) + "+"
                        }
                        local skip = 13 - length("`name'")
 
                        noi di _skip(`skip') as txt "`name' {c |}" as res ///
                        %6.0f  `r(N)'                                     ///
                        %8.1f  `r(vecmean)'                               ///
                        %10.3f `r(vecstr)'                                ///
                        %7.1f  `r(range)'                                 ///
                        %7.1f  `r(ll)'                                    ///
                        %6.1f  `r(ul)'                                    ///
                        %10.3f `r(PRay)'                                 ///
                        %8.3f  `r(PKui)'                                 
                }

                mac shift
                drop `touse' `group'
        }
end

program Summ, rclass  
	version 8.0
	syntax varname(numeric) [if] [in] [fweight aweight] ///
	[, Rayleigh Kuiper CI LEVel(integer $S_level) Detail] 

	if "`detail'" == "detail" {
		local rayleig "rayleigh"
		local kuiper "kuiper"
		local ci "ci"
	}

	if "`exp'" == "" {
		local exp "= 1"
		local uneqwt = 0
	}
	else local uneqwt = 1

	tempvar touse wt xsum ysum gap scaled rank dplus dminus cos2
	tempname XSUM YSUM vecmean wtmean veclng vecstr veclngw range
	tempname Z factor P_Ray Dplus Dminus Vn V P_Kui

	mark `touse' `if' `in'
	markout `touse' `varlist'

	count if `touse'
	local N = r(N)

	gen `wt' `exp' if `touse'
	gen `xsum' = sum(sin((`varlist' * _pi) / 180) * `wt')
	gen `ysum' = sum(cos((`varlist' * _pi) / 180) * `wt')
	scalar `XSUM' = `xsum'[_N]
	scalar `YSUM' = `ysum'[_N]

	// Stata atan routine takes a single argument
	// and gives the wrong answer in three out of four quadrants 
	Atan2 `XSUM' `YSUM'
	scalar `vecmean' = `r(angle)' 

	su `wt', meanonly
	scalar `wtmean' = r(mean) 
	scalar `XSUM' = `XSUM' * `N' / r(sum)
	scalar `YSUM' = `YSUM' * `N' / r(sum)
	scalar `veclng' = sqrt((`XSUM')^2 + (`YSUM')^2)
	scalar `vecstr' = `veclng' / `N'

	sort `touse' `varlist'
	gen `gap' = `varlist'[_n + 1] - `varlist' if `touse'
	local first = _N - `N' + 1
	replace `gap' = 360 - `varlist' + `varlist'[`first'] in l
	su `gap', meanonly
	scalar `range' = 360 - r(max)

	if "`ci'" == "ci" {
		gen `cos2' = ///
		cos(2 * (`varlist' - `vecmean') * _pi / 180) if `touse'
		su `cos2', meanonly
		local disp = (1 - r(mean)) / (2 * `vecstr'^2)
		local sem = sqrt(`disp' / `N')
		local mult = invnorm((100 + `level') / 200)
		local ul = `vecmean' + (180 / _pi) * asin(`mult' * `sem')
		if `ul' > 360 local ul = `ul' - 360 
		local ll = `vecmean' - (180 / _pi) * asin(`mult' * `sem')
		if `ll' < 0 local ll = `ll' + 360 
	}

	if `uneqwt' scalar `veclngw' = `vecstr' * `wtmean'  

	if "`rayleigh'" == "rayleigh" {
		scalar `Z' = `N' * `vecstr'^2
		scalar `factor' = 1 + (2 * `Z' - `Z'^2) / (4 * `N') - ///
	(24 * `Z' - 132 * `Z'^2 + 76 * `Z'^3 - 9 * `Z'^4) / (288 * `N'^2)
		scalar `P_Ray' = exp(-`Z') * `factor'
	}

	if "`kuiper'" == "kuiper" {
		gen `scaled' = `varlist' / 360 if `touse'
		gen `rank' = _n - _N + `N' if `touse'
		gen `dplus' = `rank' / `N' - `scaled'
		gen `dminus' = `scaled' - (`rank' - 1) / `N'
		su `dplus', meanonly
		scalar `Dplus' = r(max)
		su `dminus', meanonly
		scalar `Dminus' = r(max) 
		scalar `Vn' = `Dplus' + `Dminus'
		scalar `V'  = `Vn' * (sqrt(`N') + 0.155 + 0.24 / sqrt(`N'))
		// Stephens 1970 p.118: preferable to tabulated levels in Fisher
		// 3 dp accuracy for P < 0.447 (V > 1.26) 
		scalar `P_Kui' = (8 * `V'^2 - 2) * exp(-2 * `V'^2)
	}

	return scalar N = `N'
	return scalar vecmean = `vecmean'
	return scalar veclng = `veclng'
	return scalar vecstr = `vecstr'
	return scalar range = `range'

	if "`rayleigh'" == "rayleigh" return scalar PRay = `P_Ray'

	if "`kuiper'" == "kuiper" {
		return scalar Vn = `Vn'
		return scalar V = `V'
		return scalar PKui = `P_Kui'
	}

	if `uneqwt' return scalar veclngw `veclngw'

	if "`ci'" == "ci" {
		return scalar ll = `ll'
		return scalar ul = `ul'
		return scalar sem = `sem'
	}
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

