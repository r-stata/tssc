*! 3.0.1 NJC 25 April 2014 
*! 3.0.0 NJC 11 April 2014 
* cpyxplot: 
* 2.0.1 NJC 23 November 2004 
* 2.0.0 NJC 21 November 2004 
* 1.2.2 NJC 26 December 2002 
* 1.2.1 NJC 20 December 2002 
* 1.2.0 NJC 14 January 2000 
* 1.1.0 NJC 15 January 1999
program crossplot
        version 8.0
        gettoken yvars 0 : 0, match(foo)
	unab yvars : `yvars'
        syntax varlist [if] [in] [aweight fweight iweight]            ///
	[, combine(str asis) SEQuence(str) seqopts(str asis) allobs   ///
	plot(str asis) addplot(str asis) * ] 
	
        marksample touse, novarlist 
	if "`allobs'" == "" markout `touse' `yvars' `varlist' 
	tokenize "`sequence'" 
	
	quietly { 
		count if `touse' 
		if r(N) == 0 error 2000 

		local s = 0 
	        foreach y of local yvars {
        	        foreach x of local varlist {
                	        tempname f
				if "`sequence'" != "" { 
					local ++s 
					local slabel ///
				caption("``s''", pos(11) size(large)) `seqopts'
				} 

                        	twoway scatter `y' `x' if `touse'  ///
				[`weight' `exp'], name(`f') nodraw ///
				`slabel' `options'                 ///
				|| `plot'                          ///
				|| `addplot' 

        	                local names `names' `f' 
                	}
	        }
	} 	

        graph combine `names', `combine' 
end

