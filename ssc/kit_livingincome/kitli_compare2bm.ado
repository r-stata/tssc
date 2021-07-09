/*****************************************************************************
LIVING INCOME CALCULATIONS AND OUTPUTS

This stata ado-file produces density (kernel smoothened) plots as fractions about 
the total household income with the goal of comparing to the benchmark value

It produces graphs similar to what can be seen at:
https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf
https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf

Type
help kitli_compare2bm for more details

---------------------------------------------------------------------------

This opensource file was created and is maintained by Marcelo Tyszler
(m.tyszler@kit.nl), from KIT Royal Tropical Institute, Amsterdam.

This project was jointly done with COSA, and it was supported by
ISEAL, Living Income Community of Practice and GIZ

You are free to use it and modify for your needs. BUT PLEASE CITE US:

Tyszler, et al. (2020). Living Income Calculations Toolbox. KIT ROYAL TROPICAL 
INSTITUTE and COSA. Available at: https://github.com/mtyszler/KIT_LivingIncome/

This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.

-----------------------------------------------------------------------------
Last Update:
07/08/2020

*****************************************************************************/

capture program drop kitli_compare2bm
program define kitli_compare2bm, sortpreserve rclass
	syntax varname(numeric) [if] [in], ///
	hh_income(varname numeric) ///
	[grouping_var(varname numeric) ///
	food_value(varname numeric) ///
	label_benchmark(string) ///
	label_food_value(string) /// 
	ytitle(string) ///
	spacing(real 0.02) ///
	placement(string) ///
	step_size(integer -1) ///
	colors(string) ///
	show_distribution_graph ///
	show_detailed_graph ///
	show_bar_graph ///
	save_graph_as(string) ///
	]
	
	version 14 


	********************************************
	** Prepare observations which will be used 
	marksample touse, novarlist
	qui: replace `touse' = 0 if `varlist' == .
	qui: replace `touse' = 0 if `hh_income' == .
	if "`food_value'" !="" {
		qui: replace `touse' = 0 if `food_value' == .
	}


	** color can only be provided if graph is requested:
	if "`show_distribution_graph'" == ""  & "`show_detailed_graph'" == ""  & ("`colors'" !="" | "`ytitle'" !="" | `spacing' !=0.02 | `step_size' != -1 | "`placement'" !="" ) {
		display as error "WARNING: Graph options will be ignored if neither {it:show_distribution_graph} nor {it:show_detailed_graph} are requested."
	}
	

	* Save graph can only be used if graph is requested
	if "`save_graph_as'" !="" & "`show_detailed_graph'" == ""  & "`show_distribution_graph'" == ""  & "`show_bar_graph'" == ""   {
		display as error "WARNING: {it:save_graph_as} will be ignored if neither {it:show_distribution_graph} nor {it:show_detailed_graph}  nor {it:show_bar_graph} are requested."
	}

	* food value matching  matching elements
	if "`label_food_value'" !="" & "`food_value'" == ""   {
		display as error "WARNING: {it:label_food_value} will be ignored if {it:food_value} is not provided."
	}


	** load defaults in case optional arguments are skipped:
	capture confirm existence `label_benchmark'	
	if _rc == 6 {
		local label_benchmark = "Living Income Benchmark"
	}

	capture confirm existence `label_food_value'
	if _rc == 6 {
		local label_food_value = "(including the value of food)"
	}

	capture confirm existence `colors'
	if _rc == 6 {
		if `c(stata_version)' < 15 {
			local colors = "ebblue | blue | green | orange"	
		}
		else {
			local colors = "ebblue%30 | blue%30 | green%30 | orange%30"
		}
	}

	capture confirm existence `ytitle'
	if _rc == 6 {
		local ytitle = "Proportion of households (%)"
	}

	capture confirm existence `placement'
	if _rc == 6 {
		local placement = "right"
	}

	if "`placement'" != "right" & "`placement'" != "left" {
		display as error "WARNING: {it:placement} is provided with value different than {it:right} or {it:left}. This may cause errors in rendering the graph. Consult the help file for valid parameter values"
	}

	********************************************
     * Identify groups:
     if "`grouping_var'" !="" {
        
        qui: levelsof `grouping_var' if `touse', local(group_levels)
         
     }


	********************************************
	*** create tempvars
	** rename key variable:
	local li_benchmark = "`varlist'" 	
	
	* key components
	tempvar temp_bm_not_achieved temp_hh_income
	qui: gen `temp_hh_income' = `hh_income' if `touse'
	if "`food_value'" !="" {
		qui: replace `temp_hh_income' = `temp_hh_income' + `food_value' if `touse'
	}

	if "`grouping_var'" !="" {
		qui: gen `temp_bm_not_achieved' =  `temp_hh_income' < `li_benchmark' if `touse' & `grouping_var' !=. & `temp_hh_income' !=. & `li_benchmark'!=.
	} 
	else {
		qui: gen `temp_bm_not_achieved' =  `temp_hh_income' < `li_benchmark' if `touse'	& `temp_hh_income' !=. & `li_benchmark'!=.
	}

	* for kernels
	tempvar temp_att 

	
  	********************************************
 	 * Identify groups:
	if "`grouping_var'" !="" {
		qui: sum `temp_hh_income' if `touse' & `grouping_var' !=.
	} 
	else {
		qui: sum `temp_hh_income' if `touse'
	}

	if `r(N)' == 0 {
		error 2000 // no observations
	}

	********************************************
	if "`show_distribution_graph'" !="" | "`show_detailed_graph'" !="" | {

		local Note_full = `""N (All) = `r(N)'""'
		local labels_cmd = `"label( 1 "All") "'

		local hh_income_label: variable label `hh_income'
		if "`food_value'" !="" {
			local hh_income_label = `" "`hh_income_label'" "`label_food_value'" "'
		}
		
		* Append group information:
		if "`grouping_var'" !="" {
			local counter = 2
			local cmd_order = "order (1 "
			foreach group in `group_levels' {
			
				qui: sum `temp_hh_income' if  `grouping_var' == `group' & `touse'

				local group_label: label (`grouping_var') `group'
				
				local Note_full= `"`Note_full' "N (`group_label') = `r(N)'""'
				local labels_cmd = `"`labels_cmd' label( `counter' "`group_label'")"'
				local cmd_order = "`cmd_order' `counter'"
				local counter = `counter'+1
				
			}
			
			local cmd_order = "`cmd_order')"
			local labels_cmd = `"`labels_cmd' `cmd_order'"'
		} 
		else {
			local labels_cmd = `"label( 1 "All") order(1)"'
		}

		********************************************
		 * Prepare graph:

		if `step_size' == -1 { 
			if r(max) < =  2 {
				local w = 0.1
			} 
			else if r(max) < = 50 {
				local w = 1
			} 
			else if r(max) < = 100 {
				local w = 10
			}
			else if r(max) < = 500 {
				local w = 25
			}
			else if r(max) < = 1000 {
				local w = 50
			}
			else if r(max) < = 2000 {
				local w = 100
			}
			else if r(max) < = 5000 {
				local w = 200
			}
			else if r(max) < = 20000 {
				local w = 1000
			}
			else if r(max) < = 50000 {
				local w = 10000
			}
			else if r(max) < = 1000000 {
				local w = 100000
			}
			else {
				local w = 1000000
			}
		}
		else {
			local w = `step_size'
		}
		local ticks_x  = "xlabel(0(`w')`r(max)')"

		* Density bin size is defined as half step of the histogram-like bin size    
		local w_2 = `w'/2
		local Note_full = `"`Note_full' "bin size = `w_2'""'
		local att_steps = ceil(r(max)/(`w_2')) // number of steps needed
		egen `temp_att' = seq(), from(0) to(`att_steps') // place holder for the steps
		qui: replace `temp_att' = . if [_n]>`att_steps'
		qui: replace `temp_att' = `temp_att'*(`w_2') // replace for the actual value of the step

		** Prepare additional options to be passed to the kernel computation function
		** for details type 
		** help kdensity
		local extras = "at(`temp_att') bw(`w')"

		local current_max = 0
		local all_colors = "`colors'"

		** Compute kernels of each group
		if "`grouping_var'" !="" {
			local group_graph = ""
			local counter = 1
			foreach group in `group_levels' {
			
				local group_label: label (`grouping_var') `group'
				
				capture drop temp_x_`group' temp_y_`group'	
				capture tempvar temp_x_`group' temp_y_`group'
				kdensity `temp_hh_income' if `grouping_var' == `group' & `touse', gen(`temp_x_`group'' `temp_y_`group'') nograph kernel(gaus) `extras'
				if `r(scale)' == . {
					display as error "ERROR: density estimation failed. Please check variables provided, and/or provide a different step size for estimation"
					error 321
					exit
				}
				qui: replace `temp_y_`group'' = `temp_y_`group''*`r(scale)'
				qui: sum `temp_y_`group''
				local current_max = max(`r(max)',`current_max')

				gettoken this_color all_colors: all_colors, parse("|")
				if "`this_color'" == "|" {
					gettoken this_color all_colors: all_colors, parse("|")
				}

				local group_graph = "`group_graph' || line `temp_y_`group'' `temp_x_`group'', color(`this_color') recast(area)"
				local counter = `counter'+1
			}
		} 
		else {
			gettoken this_color all_colors: all_colors, parse("|")
			local group_graph = " color(`this_color') recast(area) lcolor(black)"
		}


		* Compute kernel for the whole sample
		capture drop temp_x temp_y
		capture tempvar temp_x temp_y
		if "`grouping_var'" !="" {
			kdensity `temp_hh_income' if `touse' & `grouping_var' !=., gen(`temp_x' `temp_y') nograph kernel(gaus) `extras'
				if `r(scale)' == . {
					display as error "ERROR: density estimation failed. Please check variables provided, and/or provide a different step size for estimation"
					error 321
					exit
				}
		} 
		else {
			qui: kdensity `temp_hh_income' if `touse' , gen(`temp_x' `temp_y') nograph kernel(gaus) `extras'
				if `r(scale)' == . {
					display as error "ERROR: density estimation failed. Please check variables provided, and/or provide a different step size for estimation"
					error 321
					exit
				}
		}
		qui: replace `temp_y' = `temp_y'*`r(scale)'
		qui: sum `temp_y'

		local current_max = max(`r(max)',`current_max')

		local h =  round(`current_max',0.01) 


		* ticks y
		if `h'>0.16 {
			local ssize = 0.05
		} 
		else {
			local ssize = 0.01
		}

		local n_ticks = round(`h'/`ssize')
		local ticks_y = `"ylabel(0 "0" "'
		forvalues i = 1(1)`n_ticks'{
			local t_y = `i'*`ssize'
			local t_y_perc = round(`i'*`ssize'*100)
			
			local ticks_y = `"`ticks_y' `t_y' "`t_y_perc'" "'
		}
		local ticks_y = `"`ticks_y' )"'

		local all_colors = "`colors'"


		* Genereate detailed information and graphs:
		if "`grouping_var'" !="" {
			local all_colors = "`colors'"
			local counter = 1
			foreach group in `group_levels' {
				local group_label: label (`grouping_var') `group'
				qui: sum `temp_hh_income' if  `grouping_var' == `group' & `touse', det
				local Note = "N = `r(N)'"
				local Note = "`Note', bin size = `w_2'"
				local this_mean = `r(mean)'
				local this_median = `r(p50)'

				qui: sum `temp_bm_not_achieved' if `grouping_var' == `group' & `touse'
				local share_li = round((`r(mean)')*100,0.1)
				local share_li_`counter' = ustrleft(string(`share_li'),4) + "%"

				qui: sum `li_benchmark' if `grouping_var' == `group' & `touse'
				local li_benchmark_`counter' = round(`r(mean)',1)

				if "`show_detailed_graph'" !="" | {

					gettoken this_color all_colors: all_colors, parse("|")
					if "`this_color'" == "|" {
						gettoken this_color all_colors: all_colors, parse("|")
					}
					
					capture graph drop "detailed_`counter'"
					line `temp_y_`group'' `temp_x_`group'', color(`this_color') recast(area) ///
					ytitle("`ytitle'") `ticks_x' `ticks_y'  xlabel(, labsize(small)) note("`Note'") graphregion(color(white)) ///
					legend(label( 1 "`group_label'") label(2 "`label_benchmark'") label(3 "mean") label(4 "median"))  || ///
					pci 0 `li_benchmark_`counter'' `h' `li_benchmark_`counter'', color(red) || ///
					pci 0 `this_mean' `h' `this_mean', color(blue) || ///
					pci 0 `this_median' `h' `this_median', color(green) ///
					xtitle(`hh_income_label') ///
					text(`h' `li_benchmark_`counter'' "`share_li_`counter'' below the benchmark", place(`placement')) ///
					name("detailed_`counter'")
					
					if "`save_graph_as'" != "" {
						graph export "`save_graph_as' detailed `group_label'.png", as(png) width(1000) replace 
					}
				}


				local counter = `counter'+1
			}

			qui: sum `temp_hh_income' if  `touse' & `grouping_var' !=. , det
			local Note = "N = `r(N)'"
			local Note = "`Note', bin size = `w_2'"
			local this_mean = `r(mean)'
			local this_median = `r(p50)'

			qui: sum `temp_bm_not_achieved' if  `touse' & `grouping_var' !=.
			local share_li = round((`r(mean)')*100,0.1)
			local share_li_`counter' = ustrleft(string(`share_li'),4) + "%"

			qui: sum `li_benchmark' if  `touse'  & `grouping_var' !=.
			local li_benchmark_`counter' = round(`r(mean)',1)

			if "`show_detailed_graph'" !="" | {

				gettoken this_color all_colors: all_colors, parse("|")
				if "`this_color'" == "|" {
					gettoken this_color all_colors: all_colors, parse("|")
				}
				
				capture graph drop "detailed_all_groups"
				line `temp_y' `temp_x', color(`this_color') recast(area) ///
				ytitle("`ytitle'") `ticks_x' `ticks_y'  xlabel(, labsize(small)) note("`Note'") graphregion(color(white)) ///
				legend(label( 1 "All groups") label(2 "`label_benchmark'") label(3 "mean") label(4 "median"))  || ///
				pci 0 `li_benchmark_`counter'' `h' `li_benchmark_`counter'', color(red) || ///
				pci 0 `this_mean' `h' `this_mean', color(blue) || ///
				pci 0 `this_median' `h' `this_median', color(green) ///
				xtitle(`hh_income_label') ///
				text(`h' `li_benchmark_`counter'' "`share_li_`counter'' below the benchmark", place(`placement')) ///
				name("detailed_all_groups")
				
				if "`save_graph_as'" != "" {
					graph export "`save_graph_as' detailed all groups.png", as(png) width(1000) replace 
				}
			}
		}
		else {

			local counter = 1
			qui: sum `temp_hh_income' if  `touse', det
			local Note = "N = `r(N)'"
			local Note = "`Note', bin size = `w_2'"
			local this_mean = `r(mean)'
			local this_median = `r(p50)'

			qui: sum `temp_bm_not_achieved' if  `touse'
			local share_li = round((`r(mean)')*100,0.1)
			local share_li_`counter' = ustrleft(string(`share_li'),4) + "%"

			qui: sum `li_benchmark' if  `touse'
			local li_benchmark_`counter' = round(`r(mean)',1)

			if "`show_detailed_graph'" !="" | {

				gettoken this_color all_colors: all_colors, parse("|")
				if "`this_color'" == "|" {
					gettoken this_color all_colors: all_colors, parse("|")
				}

				capture graph drop "detailed"
				line `temp_y' `temp_x', color(`this_color') recast(area) ///
				ytitle("`ytitle'") `ticks_x' `ticks_y'  xlabel(, labsize(small)) note("`Note'") graphregion(color(white)) ///
				legend(label( 1 "All") label(2 "`label_benchmark'") label(3 "mean") label(4 "median"))  || ///
				pci 0 `li_benchmark_`counter'' `h' `li_benchmark_`counter'', color(red) || ///
				pci 0 `this_mean' `h' `this_mean', color(blue) || ///
				pci 0 `this_median' `h' `this_median', color(green) ///
				xtitle(`hh_income_label') ///
				text(`h' `li_benchmark_`counter'' "`share_li_`counter'' below the benchmark", place(`placement')) ///
				name("detailed")
				
				if "`save_graph_as'" != "" {
					graph export "`save_graph_as' detailed.png", as(png) width(1000) replace 
				}
			}

		}


		if "`show_distribution_graph'" !="" | {
			** All together
			** Decide on the heights, ordering by benchmark value:
			if "`grouping_var'" !="" {
				tempvar temp_order_height temp_order_height_counter current_sort
				local counter = 1
				qui: gen `temp_order_height' = .
				qui: gen `temp_order_height_counter' = .
				foreach group in `group_levels' {

					qui: replace `temp_order_height' =  `li_benchmark_`counter'' in `counter'
					qui: replace `temp_order_height_counter' =  `counter' in `counter'
					local counter = `counter'+1
					
				}

				gen `current_sort' = [_n]
				sort `temp_order_height'

				local counter = 1
				foreach group in `group_levels' {

					if `counter' == 1 {
						local this_counter = `temp_order_height_counter'[`counter']
						local h_`this_counter'  = `h'

					} 
					else {
						local this_counter = `temp_order_height_counter'[`counter']
						local previous_counter = `temp_order_height_counter'[`counter'-1]
						local h_`this_counter'  = `h_`previous_counter'' - `spacing'
					}
					
					local counter = `counter'+1
						
				}

				sort `current_sort'
			}
			else {
				local h_1 = `h'
			}

			local all_colors = "`colors'"
			if "`grouping_var'" !="" {
					local group_bm_line = ""
					local group_bm_box = ""
					local counter = 1
					foreach group in `group_levels' {
					
						local group_label: label (`grouping_var') `group'
							
						gettoken this_color all_colors: all_colors, parse("|")
						if "`this_color'" == "|" {
							gettoken this_color all_colors: all_colors, parse("|")
						}
						local group_bm_line = "`group_bm_line' || pci 0 `li_benchmark_`counter'' `h_`counter'' `li_benchmark_`counter'', color(`this_color')"
						local group_bm_box = `"`group_bm_box' text(`h_`counter'' `li_benchmark_`counter'' "`label_benchmark' `group_label': `share_li_`counter'' below", size(small)  place(`placement') box margin(1 1 1 1) fcolor(`this_color'))"'
					
						local counter = `counter'+1
				
				
					
				}
			} 
			else {
				gettoken this_color all_colors: all_colors, parse("|")
				local group_bm_line = " || pci 0 `li_benchmark_1' `h_1' `li_benchmark_1', color(`this_color')"
		        local group_bm_box = `" text(`h_1' `li_benchmark_1' "`label_benchmark': `share_li_1' below", size(small)  place(`placement') box margin(1 1 1 1) fcolor(`this_color'))"'
			}


			capture graph drop "all_combined"
			line `temp_y' `temp_x',   /// 
			ytitle("`ytitle'") `ticks_x' `ticks_y'  xtitle(`hh_income_label') ///
			xlabel(, labsize(small)) note(`Note_full') graphregion(color(white)) ///
			legend(`labels_cmd') ///
			`group_graph' ///
			`group_bm_line' ///
			`group_bm_box' ///
			name("all_combined")

			* save graph *
			if "`save_graph_as'" != "" {
				graph export "`save_graph_as' distribution.png", as(png) width(1000) replace 
			}
		}

	}

	if "`show_bar_graph'" !="" {

		local this_ylabel = " ylabel(0(10)100, grid)"

		if "`grouping_var'" !="" {
			local this_over = ", over(`grouping_var')"
			local Note_full = ""

			* Append group information:
			if "`grouping_var'" !="" {

				foreach group in `group_levels' {
					qui: sum `temp_hh_income' if  `grouping_var' == `group' & `touse'
					local group_label: label (`grouping_var') `group'
					local Note_full= `"`Note_full' "N (`group_label') = `r(N)'""'				
				}
			}
		}
		else {
			local this_over = ", "
			qui: sum `temp_hh_income' if `touse'
			local Note_full = `""N = `r(N)'""'
		}

		tempvar temp_bm_not_achieved_pct
		qui: gen `temp_bm_not_achieved_pct' = `temp_bm_not_achieved'*100

		local this_title = "Share of observations below the `label_benchmark'"
		if "`food_value'" !="" {
			local this_title = `" "`this_title'" "`label_food_value'" "'
		}


		graph bar (mean)  `temp_bm_not_achieved_pct' if `touse'  `this_over' ///
		stack legend(label(1 "Share of observations below the `label_benchmark'")) ///
		ytitle("`ytitle'") `this_ylabel' ///
		bar(1, color("red")) ///
		blabel(bar, format(%9.0f) position(center) ) ///
		graphregion(color(white)) bgcolor(white) ///
		title(`this_title', size(medium)) ///
		note(`Note_full')


		if "`save_graph_as'" != "" {
			graph export "`save_graph_as' bar.png", as(png) width(1000) replace 
		}


	}
	***************************************************
	* display table with results (and store in r-class)

	local txt_spacing = 35
	local txt_spacing = max(`txt_spacing', strlen("Below the `label_benchmark': "))

	display in b _newline
	display in b "Share of observations below the `label_benchmark'" 
	if "`food_value'" !="" {
		display in b "`label_food_value'"
	}

	if "`grouping_var'" !="" { // show per group, than total
		return local grouping_var = "`grouping_var'"

		** per groups
		foreach group in `group_levels' {

			local group_label: label (`grouping_var') `group'
	
			qui: sum `temp_bm_not_achieved' if `grouping_var' == `group' & `touse' 
			local share_li = `r(mean)'*100
			return scalar share_below_`group' = `share_li'
			return scalar N_`group' = `r(N)'
			display in b ""
			display in b "`group_label'" 
			display in b "n = `r(N)'"
			display in b ""
			display as text %`txt_spacing's "Below the `label_benchmark': " /*
				*/ as result /*
				*/ %9.1f `share_li' "%"
			di as text "{hline 73}"
		}

		** all groups together
		qui: sum `temp_bm_not_achieved' if `grouping_var' != . & `touse' 
		local share_li = `r(mean)'*100
		return scalar share_below = `share_li'
		return scalar N = `r(N)'
		display in b ""
		display in b "All groups"
		display in b "n = `r(N)'"
		display in b ""
		display as text %`txt_spacing's "Below the `label_benchmark': " /*
			*/ as result /*
			*/ %9.1f `share_li' "%"
		di as text "{hline 73}"
	}
	else { // no groups

		qui: sum `temp_bm_not_achieved' if  `touse' 
		local share_li = `r(mean)'*100
		return scalar share_below = `share_li'
		return scalar N = `r(N)'
		display in b ""
		display in b "n = `r(N)'"
		display in b ""
		display as text %`txt_spacing's "Below the `label_benchmark': " /*
			*/ as result /*
			*/ %9.1f `share_li' "%"
		di as text "{hline 73}"
	}

end
