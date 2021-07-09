*! 2.0.1 NJC 23 November 2004 
* 2.0.0 NJC 21 November 2004 
* 1.2.2 NJC 26 December 2002 
* 1.2.1 NJC 20 December 2002 
* 1.2.0 NJC 14 January 2000 
* 1.1.0 NJC 15 January 1999
program cpyxplot
        version 8.0
        gettoken yvars 0 : 0, parse("\")
	unab yvars : `yvars'
	gettoken bs 0 : 0, parse("\") 
        syntax varlist [if] [in] [aweight fweight iweight] ///
	[, plottype(str) combine(str asis) SEQuence(str) * ] 
	
        marksample touse
	markout `touse' `yvars' 
	
	quietly { 
		count if `touse' 
		if r(N) == 0 error 2000 

		if "`plottype'" == "" local plottype "scatter"
		local s = 0 
	        foreach y of local yvars {
        	        foreach x of local varlist {
                	        tempfile f
				if "`sequence'" != "" { 
					local ++s 
					local slabel ///
			caption("`: word `s' of `sequence''", pos(11) size(large))
				} 
                        	twoway `plottype' `y' `x' if `touse' ///
				[`weight' `exp'], saving("`f'") nodraw ///
				`slabel' `options' 
        	                local files `"`files' "`f'""' 
                	}
	        }
	} 	

        graph combine `files', `combine' 
end

/*

The syntax is

cpyxplot yvarlist \ xvarlist [if] [in] [weight] [, options]

After the first -gettoken- `yvars'   should be   yvarlist
After the second -gettoken `bs'      should be   "\" 

The syntax is then 

xvarlist [if] [in] [weight] [, options]

*/
