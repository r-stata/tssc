*! _glgroup 1.1.0 NJC 10 June 1999 STB-50 dm70
* _ggroup 1.1.0  30jun1998
program define _glgroup
        version 6
        gettoken type 0 : 0
        gettoken g 0 : 0
        gettoken eqs 0 : 0

        syntax varlist(max=1) [if] [in] [, Missing ]
	tempvar touse 
        mark `touse' `if' `in' 
	tempname tlab
        quietly {
		if "`missing'" == "" { 
			replace `touse' = 0 if missing(`varlist')
		}	
                sort `touse' `varlist'
                by `touse' `varlist': gen byte `g' = 1 if _n == 1 & `touse'
                replace `g' = sum(`g') if `touse' 
                local max = `g'[_N]
                local vallab : value label `varlist'

                local i = 1
                count if !`touse'
                local j = 1 + r(N)
                while `i' <= `max' {
                        local val = `varlist'[`j']
                        if "`vallab'" != "" { local val : label `vallab' `val' }
                        label def `tlab' `i' "`val'", modify
                        count if `g' == `i'
                        local j = `j' + r(N)
                        local i = `i' + 1
                }
        }
        _crcslbl `g' `varlist'
        label val `g' `tlab'
end

/*
   map varlist onto g
   values min, ..., max -> 1, ..., #groups
   values of g are labelled with distinct values of varlist
   value label will have tempname attached
*/

