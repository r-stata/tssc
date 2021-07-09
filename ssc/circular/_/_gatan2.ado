*! NJC 1.1.2 21 June 2004                 
* NJC 1.1.1 3 May 2004                 
* NJC 1.1.0 27 April 2004                 
* NJC 1.0.0 17 December 1998 STB-50 dm70
program _gatan2
        version 8
        local type "`1'"
        mac shift
        local g "`1'"
        mac shift
        mac shift                               // discard = sign 
	local 0 "`*'" 
        syntax varlist(min=2 max=2) [if] [in] [, RADians ] 
        tokenize `varlist'
	args sin cos
        tempvar ss sc

        quietly {
                gen byte `ss' = sign(`sin') `if' `in'
                gen byte `sc' = sign(`cos') `if' `in'
                gen `type' `g' = atan(`sin' / `cos') ///
                	if (`ss' == 1 & `sc' == 1) | ((`ss' == 0) & `sc' == 1)
                replace `g' =  _pi / 2 if `ss' == 1 & `sc' == 0
                replace `g' = 3 * _pi / 2 if `ss' == -1 & `sc' == 0
                replace `g' = _pi + atan(`sin' / `cos') if `sc' ==  -1
                replace `g' = 2 * _pi + atan(`sin' / `cos') ///
                	if `ss' == -1 & `sc' == 1
		replace `g' = . if `ss' == 0 & `sc' == 0 	
                if "`radians'" == "" replace `g' = `g' * (180 / _pi)
        }
        label var `g' "atan(`sin'/`cos')"
end
