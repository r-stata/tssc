program _tesen_plot
	
	syntax [anything] [, nobreakdown CREFlines ///
						 boundpatterns(string) /// 
						 boundcolors(string) ///
						 boundoptions(string) ///
						 breakdownoptions(string) ///
	                     xtitle(string) ytitle(string) ///
						 graphregion(string) bgcolor(string) ///
						 ylabel(string) yscale(string) ///
						 xline(string) xscale(string)) ///
						 xline(string) name(string) ///
						 legoptions(string) ///
						 NOLEGend *]		
	
	di `"`options'"'
	
	// =========================================================================
	// 1. Temp names
	// =========================================================================
	
	tempname temp_results c_table cmax
	
	// =========================================================================
	// 2. Process input
	// =========================================================================
	
	qui estimates store `temp_results' 
	if "`anything'" != "" {
		local n_estimates : word count `anything'
		tokenize `anything'
	}
	else {
		local n_estimates 1
		local 1 `temp_results'
	}
	
	// check for multiple estimates + creflines
	if `n_estimates' > 1 & "`creflines'" != "" {
		di as error "cannot plot with c-dependence reference lines and multiple estimates"
		qui error 109
	}
	
	// save variables to dataset
	forvalues i= 1/`n_estimates' {
		qui estimates restore ``i''
		matrix `c_table' = e(c_table)
		matrix colnames `c_table' = cgrid`i' lower`i' upper`i'
		svmat `c_table', names(col)
	}

	// default to no legend
	local leg `"legend(off)"'
	
	// process breakdown point
	if "`breakdown'" == ""{
		local yl = e(y_breakdown)
		if `yl' >= . {
			local yl = 0
		}
		if "`breakdownoptions'" == ""{
			local breakdownline `"yline(`yl',lcolor(black) lwidth(vthin)) "'
		}
		else {
			local breakdownline `"yline(`yl', `breakdownoptions') "'
		}
	}

	// process ccovariates
	// TODO: make more flexible
	if "`creflines'" != "" {
		matrix `cmax' = e(cref)
		
		// get the max and min c values
		_get_cbounds `c_table' 2 3
		local min_y = `s(min_y)'
		local max_y = `s(max_y)'
	
		local vars : rownames(`cmax')
		local i = 3
		foreach v in `vars' {
			local cval = `cmax'["cref:`v'", 1]
			local line_coords `min_y' `cval' `max_y' `cval'
			local ccovlines `"`ccovlines'|| scatteri `line_coords', recast(line) "'
			local leg_lab `"`leg_lab' label(`i' `v') "'
			local leg_ord `"`leg_ord' `i'"'
			local ++i
		}
		local leg `"legend(order(`leg_ord') `leg_lab' pos("right") cols(1))"'
		local leg `"legend(order(`leg_ord') `leg_lab' `legoptions'"'
		if !regexm(`"`leg'"', " pos\(.*\)") & !regexm(`"`leg'"', " cols\(.*\)") {
			local leg `"`leg' pos("right") cols(1)"'
		}
		local leg `"`leg')"'
	}
	
	// process line patterns and colors for bounds
	if "`boundpatterns'" == ""{
		local boundpatterns solid dash dot dash_dot shortdash shortdash_dot longdash longdash_dot
	}
	else {
		local npatterns : word count `boundpatterns'
		if `npatterns' == 1 {
			local b `boundpatterns'
			local boundpatterns `b' `b' `b' `b' `b' `b' `b' `b'
		}
	}
	if "`boundcolors'" == ""{
		local boundcolors gs0 gs0 gs0 gs0 gs0 gs0 gs0 gs0
	}
	else {
		local ncolors : word count `boundpatterns'
		if `ncolors' == 1 {
			local b `boundcolors'
			local boundcolors `b' `b' `b' `b' `b' `b' `b' `b'
		}
	}
	
	// process legend for multiple plots
	if `n_estimates' > 1 {
		forvalues i= 1/`n_estimates' {
			local line_num = `i' * 2
			local leg_lab `"`leg_lab' label(`line_num' "``i''") "'
			local leg_ord `"`leg_ord' `line_num'"'
		}
		local leg `"legend(order(`leg_ord') `leg_lab' `legoptions'"'
		if !regexm(`"`leg'"', " pos\(.*\)") {
			local leg `"`leg' pos("bottom")"'
		}
		local leg `"`leg')"'
	}
	
	// process overall display options with defaults
	local poptions xtitle ytitle /*
	             */graphregion plotregion /*
				 */ylabel yscale /*
				 */xlabel xscale /*
				 */name
	local defaults c `e(stat)' /*
	             */"color(white)" "color(white) margin(b=3 l=0 t=3 r=0)" /*
	             */",nogrid angle(0) notick" "extend" /*
				 */",nogrid angle(0) notick" "noextend" /*
				 */`e(stat)'
	local noptions : word count `poptions'
	forvalues i = 1/`noptions'{
		local option : word `i' of `poptions'
		local default : word `i' of `defaults'
		if "``option''" == ""{
			local `option' `default'
		}
	}
	
	// process additional formatting options
	// NOTE: the syntax of combining graphs (using ||) seems to be sensitive 
	//       to an extra space so need to have no space if there are no options 
	//       but a space after the options if there are.
	if "`options'" != ""{
		local options "`options' "
	}
	
	// Overide to drop legend if option specified
	if "`nolegend'" != "" {
		local leg `"legend(off)"'
	}
	
// 	exit 
	
	// =========================================================================
	// 3. Main plot
	// =========================================================================
	
	forvalues i=1/`n_estimates'{
		local lp : word `i' of `boundpatterns'
		local lc : word `i' of `boundcolors'
		local newplot_ub `"(line upper`i' cgrid`i', lc(`lc') lp(`lp') `boundoptions')"'
		local newplot_lb `"(line lower`i' cgrid`i', lc(`lc') lp(`lp') `boundoptions')"'
		local lineplots `"`lineplots' `newplot_ub' `newplot_lb'"'
	}
	
	twoway `lineplots', ///
    xtitle(`xtitle') ytitle(`ytitle') /// 
	graphregion(`graphregion') plotregion(`plotregion') ///
	ylabel(`ylabel') yscale(`yscale') /// 
	xlabel(`xlabel') xscale(`xscale') ///
	name(`name', replace)/*
  */`breakdownline'/*
  */`options'/*	
  */`ccovlines' /*
  */`leg'
	
	forvalues i=1/`n_estimates'{
		drop lower`i' upper`i' cgrid`i'
	}
	
	qui estimates restore `temp_results'
	qui estimates drop `temp_results'

end

program _get_cbounds, sclass

	args c_table lower upper
	
	mata: m1 = st_matrix("`c_table'")[,`lower']
	mata: m1 = colmin(m1)
	mata: m2 = st_matrix("`c_table'")[,`upper']
	mata: m2 = colmax(m2)
	mata: st_local("max_y", strofreal(m2))
	mata: st_local("min_y", strofreal(m1))
	
	sreturn local max_y = `max_y'
	sreturn local min_y = `min_y'
	
end
