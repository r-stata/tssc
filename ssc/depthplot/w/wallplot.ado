*! 1.0.0 NJC 9 Dec 2015 
program wallplot, sort  
	version 8.2 
	forval j = 1/20 { 
		local opts `opts' var`j'opts(str asis) 
	}
	syntax varlist(min=2 numeric) [if] [in] ///
	[, RECAST(str) varallopts(str asis) `opts' * ] 

	quietly { 
		gettoken y x : varlist 
		marksample touse, novarlist 
		markout `touse' `y' 
		count if `touse' 
		if r(N) == 0 error 2000 

		preserve 
		keep if `touse' 
		isid `y'

		if "`recast'" == "" local recast rarea 
		local cast = substr("`recast'", 2, .) 

		gettoken xfirst x : x 
		local call twoway `cast' `xfirst' `y' ///
		, horizontal `varallopts' `var1opts'   
		local xprev `xfirst' 

		local text : var label `xfirst' 
		if `"`text'"' == "" local text "`xfirst'" 
		local lgnd 1 `"`text'"'  

		local j = 2 
		foreach v of local x { 
			tempvar clone  
			clonevar `clone' = `v' 
			replace `clone' = `xprev' + `clone'  

			local text : var label `v' 
			if `"`text'"' == "" local text "`v'" 
			local lgnd `lgnd' `j' `"`text'"' 

			local call `call' || ///
			`recast' `xprev' `clone' `y', ///
			horizontal `varallopts' `var`j'opts' 

			local xprev `clone'  
			local ++j 
		} 
	
		sort `y' 
	}

	local defaults ///
	xsc(r(0 .)) yla(, ang(h)) ysc(reverse) legend(order(`lgnd')) 

	`call' `defaults' `options'  
end 
