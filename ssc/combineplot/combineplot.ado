*! 1.0.0 NJC 28 April 2014 
program combineplot 
        version 8.2

	_on_colon_parse `0' 
	local 0 `s(before)' 
        local 1 `s(after)'

	syntax anything [if] [in] [fweight aweight iweight pweight] /// 
	[, combine(str asis) SEQuence(str) seqopts(str asis) allobs ]

	my_parse `anything' 

	if !strpos(`"`1'"', "@y") { 
		di as err "syntax must refer to @y" 
		exit 198 
	}

	if strpos(`"`1'"', "@x") & "`xvars'" == "" { 
		di as err "syntax refers to @x, but no xvarlist specified" 
		exit 198 
	}

	gettoken cmd options : 1, parse(,)  
	gettoken comma options: options, parse(,) 

	quietly { 
        	marksample touse, novarlist 
		if "`allobs'" == "" markout `touse' `yvars' `xvars' 
		count if `touse' 
		if r(N) == 0 error 2000

		if "`xvars'" == ""  local xvars `touse' 
		
		tokenize "`sequence'" 
	}

	local s = 0 
	foreach y of local yvars {
                foreach x of local xvars {
               	        tempname f
			if "`sequence'" != "" { 
				local ++s 
				local slabel ///
				caption("``s''", pos(11) size(large)) `seqopts'
			} 

			local CMD : subinstr local cmd "@y" "`y'", all 
			local CMD : subinstr local CMD "@x" "`x'", all 
			local OPT : subinstr local options "@y" "`y'", all 
			local OPT : subinstr local OPT "@x" "`x'", all 

                       	`CMD' if `touse'                   ///
			[`weight' `exp'], name(`f') nodraw ///
			`slabel' `OPT'                     ///
	
                        local names `names' `f' 
               	}
       }

       graph combine `names', `combine' 
end

program my_parse 
	tokenize `0', parse("( ) ") 

	while "`1'" != "" { 
		if inlist("`1'", "(", ")") local myvars `myvars' `1' 
		else { 
			unab vars :  `1' 
			local myvars `myvars' `vars' 
		} 

		mac shift 
	} 

	if !strpos("`myvars'", "(") c_local yvars `myvars' 
	else { 
		gettoken yvars xvars : myvars, match(isparen) 
		c_local yvars `yvars' 
		local 0 `xvars' 
		syntax varlist 
		c_local xvars `varlist' 
	}       
end 

