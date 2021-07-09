****changelog:
* v1.0.3 added option to add other twoway plots
* v1.0.2 bugfix
* v1.0.1 the symbol_opacity() option was added
cap program drop colorscatter
program define colorscatter
    version 11.0
	syntax varlist(max=3)  [if] [in],[ keeplegend scatter_options(string) symbol_opacity(string) cmin(string) cmax(string) rgb_low(string) rgb_high(string) tw_pre(string) tw_post(string)  * ]
	marksample touse
	
	tokenize `varlist'
	local x "`1'"
	local y "`2'"
	local c "`3'"
	qui sum `c' if `touse'
	if "`cmin'"=="" {
		local cmin=r(min)
	}
	if "`cmax'"=="" {
		local cmax=r(max)
	}
	if "`symbol_opacity'"=="" {
		local symbol_opacity  1
	}
	if "`rgb_low'"=="" {
		local rgb_low  0 0 255
	}
	if "`rgb_high'"=="" {
		local rgb_high 255 0 0
	}
	local rl1 : word 1 of `rgb_high'
	local rl2 : word 2 of `rgb_high'
	local rl3 : word 3 of `rgb_high'
	local rh1 : word 1 of `rgb_low'
	local rh2 : word 2 of `rgb_low'
	local rh3 : word 3 of `rgb_low'
	
	
	tempvar cscaled
	gen `cscaled' = round(255*(`c'-`cmin')/(`cmax'-`cmin'))
	
	qui replace `cscaled'=0 if `cscaled' <0
	qui replace `cscaled'=255 if `cscaled'>255 & ! missing(`cscaled') 
	local command tw (`tw_pre')
	qui levelsof `cscaled' if `touse', local(levels) 
	
	local i 0
	local legend_entry 
	local last : word count `levels'
	foreach l of local levels {
		local i = `i'+1
		local gradient=`l'/255		
		local command `command' (scatter `x' `y' if `cscaled'==`l' & `touse', mcolor("`: di round(`gradient'*`rl1' + (1-`gradient')*`rh1')' `: di round(`gradient'*`rl2' + (1-`gradient')*`rh2')' `: di round(`gradient'*`rl3' + (1-`gradient')*`rh3')' `symbol_opacity'") `scatter_options')
		local label ""
		if `i'==1 | `i'==`last' {
			qui sum `c' if `cscaled'==`l' & `touse'
			qui di `r(N)'
			local label `: di %12.2g `r(mean)''
		}
		local legend_entry `legend_entry' `i' "`label'"
	}
	local command `command' (`tw_post')

	if ("`keeplegend'"=="") {
		`command', `options' legend(order(`legend_entry') col(1) symplacement(right)  position(3))
	}
	else {
		`command', `options' 
	}

end
