*! textgph - program to add text to scatterplots
*! NJGW 1.1.0 4-25-2001
*! syntax: textgph {graph varlist & options} Text(x y text \ x y text \ ...) TSize(%)
*! or: textgph , using(usinglist) ....
program define textgph
	version 7

	qui syntax [varlist(min=2 max=2000)] [if] [in] , [ USING(string) Text(string) TSize(real 0.8) saving(string) * ]

	if `"`saving'"'!="" {
		local saving `"saving(`saving')"'
	}

	local tr=570*`tsize'
	local tc=290*`tsize'

	local ntext 0
	while `"`text'"'!="" {
		gettoken curtext text : text , parse("\")
		if `"`curtext'"' != "\" {
			local ntext=`ntext'+1
			gettoken tx`ntext' curtext : curtext
			gettoken ty`ntext' thetext`ntext' : curtext
		}
	}

	if "`using'"!="" {
		graph using `using', `options'
		local ay 1
		local ax 1
		local by 0
		local bx 0
	}
	else {
		graph `varlist' `if' `in' , `options'
		local ay=`r(ay)'
		local by=`r(by)'
		local ax=`r(ax)'
		local bx=`r(bx)'
	}


	gph open , `saving'
	graph
	gph font `tr' `tc'
	gph pen 1
	forv i=1(1)`ntext' {
		local r = (`ay')*(`ty`i'') + (`by')
		local c = (`ax')*(`tx`i'') + (`bx')
		gph text `r' `c' 0 -1 `thetext`i''
	}
	gph close

end

