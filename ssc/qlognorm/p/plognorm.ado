*! 1.0.0 NJC 2 August 2002 
* pnorm version 2.1.5  27aug2000
program define plognorm, sort
	version 7
	syntax varname [if] [in] [, ml a(real 0.5) /*
	*/ Symbol(string) noBorder Connect(string) /*
	*/ YLAbel(string) XLAbel(string) Grid * ]
	
	tempvar logvar F Psubi
	quietly {
		marksample touse 
		capture assert `varlist' > 0 if `touse' 
		if _rc { 
			error 411
		} 	
		
		sort `touse' `varlist'
		gen float `Psubi' = sum(`touse')
		replace `Psubi' = (`Psubi' - `a') / (`Psubi'[_N] - 2 * `a' + 1)
		gen `logvar' = log(`varlist') if `touse' 
		sum `logvar', detail 
		
		if "`ml'" == "" {
			gen float `F' = normprob((`logvar' - r(mean)) /* 
			*/ / r(sd)) if `touse'
		} 
		else { 
			tempname factor 
			scalar `factor' = sqrt((r(N) - 1) / r(N))
			gen float `F' = normprob((`logvar' - r(mean)) /* 
			*/ / (`factor' * r(sd))) if `touse'
		} 
	}
	
	label var `F' "F if lognormal"
	format `F' `Psubi' %9.2f

	if `a' == 0 { 
		local defn "i / (N + 1)" 
	} 
	else if `a' == 0.5 { 
		local defn "(i - 0.5) / N"  
	} 
	else { 
		local b = 1 - 2 * `a' 
		local sign = cond(`b' > 0, "+ ", "- ") 
		local b = abs(`b') 
		local defn "(i - `a') / (N `sign'`b')" 
	} 
	local lbl "P[i] = `defn'" 
	if length("`lbl'") <= 20 { 
		label var `Psubi' "Empirical `lbl'"        
	}
	else label var `Psubi' "`lbl'"

	if "`symbol'" == "" { 
		local symbol "oi" 
	} 
	else { local symbol "`symbol'i" }
	if "`connect'" == "" { 
		local connect ".l" 
	}
	else { local connect "`connect'l" }
	if "`ylabel'" == "" { 
		local ylabel "0,.25,.5,.75,1" 
	}
	if "`xlabel'" == "" { 
		local xlabel "0,.25,.5,.75,1" 
	}
	if "`grid'" != "" {
		local options "`options' yline(.25,.5,.75) xline(.25,.5,.75)"
	}
		
	if "`border'"=="" { local b "border" }
	graph `F' `Psubi' `Psubi', c(`connect') s(`symbol') /*
	*/ ylab(`ylabel') xlab(`xlabel') `b' `options'
end
