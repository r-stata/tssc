**multivrs version 1.0, March 2021
**An Estimator for Multiverse Analysis
**Cristobal Young and Katherine Holsteen

program multivrs
	version 12.1
	capture noisily multivrs_u `0'
	local rc = _rc
	capture mata:  mata drop multivrs_varnames
	capture file close listfile
	exit `rc'
end

//main program including all of the important subunits of the procedure
program multivrs_u, rclass
preserve
if !replay() {weight
	syntax anything [if] [in] ///
	[, noplot noinfluence normal nozero nosig plotbs intervals weights(string) ///
	saveas(string) replace noinfluencecalcs inf_means ///
	margins marginsopts(string) *]
			
	*************************************
	*** Checks before starting 		  ***
	*************************************
	multivrs_dependencies
	if "`saveas'" != "" {	
		* Prepare to Save Results Datafile
		if !regexm("`saveas'", "\.dta$") local saveas_dta "`saveas'.dta"
		else local saveas_dta "`saveas'"
		capture confirm file `saveas_dta'
		if _rc == 0 & "`replace'" != "replace" {
			di as error "file `saveas_dta' already exists; please use option replace or specify a different file name for saved results."
			exit 602
		}
		local saveas_option saveas(`saveas_dta') 
	
		* Prepare to Save Models Do-file
		if !regexm("`saveas'", "\.do$") local saveas_do "`saveas'.do"
		else local saveas_do "`saveas'"
		capture confirm file `saveas_do'
		if _rc == 0 & "`replace'" != "replace" {
			di as error "file `saveas_do' already exists; please use option replace or specify a different file name for saved results."
			exit 602
		}
		local savelist_option savelist(`saveas_do') 
		
		quietly file open listfile using `saveas_do', write replace
		file write listfile "* This file gives the code to replicate each of the models estimated in the multivrs command:"
		local full_command_trimmed = trim(stritrim("`0'"))
		file write listfile _n "multivrs `full_command_trimmed'"
		quietly file close listfile
	}
	else {
		local saveas_option ""
		local savelist_option ""
	}
		
	local timer_1 98
	timer clear `timer_1'
	timer on `timer_1'
		
	*************************************
	*** Estimate Multiverse of Models ***
	*************************************

	tempfile temp_model_results
	
	//If the input does not already contain a comma and options then add a comma
	local comma_dummy : subinstr local 0 "," ",", count(local comma_count)
	if "`comma_count'" == "0" local 0 `"`0',"'
	multivrs_estimate `0' results_tempfile(`"`temp_model_results'"') `savelist_option'
	if `r(listwise_delete)' == 0 {
		local listwise "nolistwise"
	}	
	// load file with bootstrap results and display output
	capture use `"`temp_model_results'"', clear
	if c(rc) {
		if inrange(c(rc),900,903) {
			di _newline as err "insufficient memory to load file with multivrs results"
		}
		error c(rc)
	}
	************************************
	*** Calculate Summary Statistics ***
	************************************
	multivrs_calc_summary_stats, `saveas_option' `replace' `influencecalcs' `inf_means' `margins'
	timer off `timer_1'
	quietly timer list `timer_1'
	local time_taken = r(t`timer_1')
	local sig_only `"`r(sig_only)'"'
	
	if "`influencecalcs'" == "noinfluencecalcs" {
		local influence noinfluence
	}
	
	***********************
	*** Display Results ***
	***********************
	multivrs_display_results, full `sig_only' `influence' `intervals' time_taken(`time_taken') `listwise' `inf_means' `margins'
		
	********************
	*** Plot Results ***
	********************	
	if "`plot'" != "noplot" {
		//if "`sig_only'" == "sig_only" | "`r(margins)'" == "margins" {
		//  & "`sig_only'" != "sig_only"
		if "`margins'" == "margins" {
			multivrs_marginsplot, model(`r(model)')
		} 
		else if "`sig_only'" != "sig_only" {
			multivrs_plot , `rmal' `zero' `plotbs' bs(`r(bs_type)')
		}
	}
	 
}
//replaying results
else {
	syntax [, more full sig_only intervals nosig]
	if "`sig'" == "nosig" local full full
	if `"`r(cmd)'"' != "multivrs" {
		di as err "To replay multivrs results, the last command must be a successful run of " as result "multivrs" as err "."
		exit 198
	}
	local varlist `"`r(varlist)'"'	
	multivrs_parse_varlist `varlist', display_only
		if `r(listwise_delete)' == 0 {
		local listwise "nolistwise"
	}	
	local time_taken = `r(time_taken)'
	multivrs_display_results, `more' `full' `sig_only' `intervals' time_taken(`time_taken') `listwise'

}
return local sig_only `"`sig_only'"'
//return local saveas `"`saveas'"'
return add

restore
end
































