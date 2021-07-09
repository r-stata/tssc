*! NJC 2.0.0 19 January 2004 
* NJC 1.0.1 1 January 1999
* NJC 1.0.0 17 December 1998
program circylowess 
        version 8.0
        syntax varlist(min=2 max=2) [if] [in] ///
	[ , Generate(str) lowess(str asis) scatter(str asis) plot(str asis) * ]
	
        if "`generate'" != "" confirm new variable `generate' 

	marksample touse
	qui count if `touse' 
	if r(N) == 0 error 2000 
	
        tempvar sine cosine ssine scosine smooth

        qui {
		tokenize `varlist' 
        	args y x
                gen `sine' = sin(`y' * _pi / 180) if `touse'
                gen `cosine' = cos(`y' * _pi / 180) if `touse'
                lowess `sine' `x' if `touse', nograph gen(`ssine') `lowess' 
                lowess `cosine' `x' if `touse', nograph gen(`scosine') `lowess' 
                egen `smooth' = atan2(`ssine' `scosine') if `touse'
        }

        label var `smooth' "smoothed `y'"
	local yla `"yla(0 "0" 90 "90" 180 "180" 270 "270" 360 "360")"' 

        circscatter `y' `smooth' `x', ///
	ycirc `pad' yli(0 360) ms(Oh none) sort c(. l) `yla' `scatter'

        qui if "`generate'" != "" gen `generate' = `smooth' 
end

