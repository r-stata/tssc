capture program drop sqmc
program sqmc
version 13.1
syntax [varlist]
di ""
di as smcl as txt  "{c TLC}{hline 58}{c TRC}"	
di in green "  {bf:Variable}{dup 7: }{c |}{bf:    sqmc}{dup 5: }{c |} {bf:    95% Conf. Interval}"
di as smcl as txt  "{c BLC}{hline 58}{c BRC}"
local i=0
foreach vars of local 0 {
	local rest: subinstr local 0 "`vars'" ""   
	qui reg `vars' `rest'
	//ereturn list
	tempname rsquare
	scalar `rsquare' = e(r2)
	
	qui estat esize
	quietly matrix a = r(esize)
    qui matrix list a
    tempname lci
        scalar `lci' = a[1, 2] //row 1 coloumn 2
    tempname uci
        scalar `uci' = a[1, 3] //row 1 coloumn 3
         
	
	di in yellow "  "%-12s abbrev("`vars'",12) "{dup 3: }{c |}" %9.4f `rsquare' ///
	"{dup 4: }{c |}"%9.4f `lci' "{dup 4: }{c |}" %9.4f `uci' "{dup 4: }"
	}
di as smcl as txt  "{c BLC}{hline 58}{c BRC}"		
end


