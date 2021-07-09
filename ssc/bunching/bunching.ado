*! ver 1.3 2020-05-21
*  ver 1.2 2020-05-19
* ver 1.1 2020-05-05
* ver 1.0 2020-04-30

program define bunching, rclass 
        version 14
		syntax varlist [if] [in] [fw] ///
		,  Kink(real) M(real) tax0(real) tax1(real) ///
		[ GENerate(name) PERC_obs(integer 9999425) POLorder(integer 9999425) ///
		DELTAM(real 9999425) DELTAP(real 9999425) ///
		Grid(numlist min=1 max=99 sort) Numiter(integer 500) BINWidth(real 9999425) ///
		SAVINGTOBIT(string asis) SAVINGBOUNDS(string asis) ///
		NOPIC VERBOSE ]

		********************************************************************************************
		* 0. SETUP
		********************************************************************************************
		* 1. observations to use
		marksample touse
        qui count if `touse'
        if r(N) == 0 error 2000

		* variables to use
		tokenize `varlist'
		local y_i `1'
		macro shift
		local covariates `*'
		
		
		* 2.1 check REQUIRED inputs
		if `tax0' >= `tax1' {
				di as err "value of {bf:tax1} must be bigger than {bf:tax0}" 
				exit 198
		}
		if `m' <= 0 | `m' == . {
				di as err "strictly positive value for {bf:m} is required to run the code"
				exit 198
		}
		
 		* 2.2 check OPTIONAL inputs
		* "deltap" or "deltam" are entered (they should not be not equal the default value)
		if `deltap' != 9999425 | `deltam' != 9999425 {
			if `deltap' < 0 | `deltam' < 0 {
				di as err "delta values must be weakly positive"
				exit 198
		}
		if `deltap' ==. | `deltam' ==. {
				di as err "must enter both delta values"
				exit 198
			}
		}
		
		** "perc:_obs" or "pol:order" are entered - check if "generate(newvar)" or "deltam(# real)" or "deltap(# real)" are entered
 		if `polorder' != 9999425 & `perc_obs' != 9999425 {
			if missing("`generate'") | (`deltap' == 9999425 | `deltam' == 9999425)  {
				di as err "If you'd like to run the filter with custom polorder or perc_obs, you must also provide all three options: deltam, deltap, and generate"
				exit 198
			}
		}
		if (`polorder' != 9999425 & `perc_obs' == 9999425) | (`polorder' == 9999425 & `perc_obs' != 9999425) {
			if missing("`generate'") | (`deltap' == 9999425 | `deltam' == 9999425)  {
				di as err "If you'd like to run the filter with custom polorder or perc_obs, you must also provide all three options: deltam, deltap, and generate"
				exit 198
			}
			
			if `perc_obs' == 9999425 local perc_obs = 40
			if `polorder' == 9999425 local polorder = 7
		}
		
		
		** "perc:_obs" and "pol:order" not entered; any of "generate(newvar)" or "deltam(# real)" or "deltap(# real)" are entered
		if `polorder' == 9999425 & `perc_obs' == 9999425 {
			if missing("`generate'") & (`deltap' != 9999425 | `deltam' != 9999425) {
				di as err "If you'd like to run the filter, you must provide all three options deltam, deltap, and generate"
				exit 198
			}
			if !missing("`generate'") & (`deltap' == 9999425 | `deltam' == 9999425) {
				di as err "If you'd like to run the filter, you must provide all three options deltam, deltap, and generate"
				exit 198
			}
			
			local polorder = 7
			local perc_obs = 40
		}


		* 2.4 check file names
		* check if files already exist on a disk
		CheckSaveFileOpt `savingtobit'
			local savingtobit_filename =  "`s(filename)'"
		CheckSaveFileOpt `savingbounds'
			local savingbounds_filename =  "`s(filename)'"
		* check if saved files have different names
		if ("`savingbounds_filename'" == "`savingtobit_filename'") & !missing("`savingbounds_filename'") {
				di as err "File names for {bf:Bounds} and {bf:Tobit} are the same. Please use different file names."
				exit 198
		}
		
		
		* 2.4 bunchtobit checks
		if `numiter' <= 0 {
				di as err "option {bf:numiter()} incorrectly specified"
				exit 198
		}
		if `binwidth' <= 0  {
				di as err "option {bf:binwidth()} incorrectly specified: must be strictly bigger than 0"
				exit 198
		}
		* default grid size: 10(10)90
		if missing("`grid'") {
			forvalues t = 10 (10) 90 {
				local grid `grid' `t'
			}
		}
		
		
		* 2.6 leave other options to corresponding functions
		
		
		
		********************************************************************************************
		* 1. RUN FUNCTIONS
		********************************************************************************************
		* collect all results in r() via -return add-
		* 1. run bunchfilter
		if (`deltap' != 9999425 & `deltam' != 9999425) & !missing("`generate'") {
			* If deltap, deltam and generate are provided, bunchfilter is run and the newly generated variable will be then used 
			* as dependent variable by bounds/tobit; otherwise bounds/tobit uses the user-entered dependent variable
			
			funcHeader "Filter"
			bunchfilter `y_i' [`weight'`exp'] `in' `if', gen(`generate') deltam(`deltam') deltap(`deltap') kink(`kink') perc_obs(`perc_obs') polorder(`polorder') `nopic' binwidth(`binwidth')
			if _rc != 0 exit 
			local y_i `generate'
			
			* use computed binwidth from filter and use that in tobit
			if missing("`nopic'") local binwidth = r(binwidth)
			return add
		}
		
		
		* 2. run bunchbounds
		funcHeader "Bounds"
		bunchbounds `y_i' [`weight'`exp'] `in' `if', kink(`kink')  tax0(`tax0') tax1(`tax1') m(`m') `nopic' saving(`savingbounds')
		return add
		
		
		* 3. run bunchtobit
		funcHeader "Tobit"
		bunchtobit `y_i' `covariates' [`weight'`exp'] `in' `if', kink(`kink') tax0(`tax0') tax1(`tax1') numiter(`numiter') grid(`grid') `nopic' binwidth(`binwidth') `verbose' saving(`savingtobit')
		if _rc != 0 exit 
		return add
		
end


program CheckSaveFileOpt, sclass
/* parse the contents of the -saving- option:
 * saving(filename [, replace])
 * check if files exists
 */
	version 10
	syntax [anything] [, replace ]
	
	* find -replace- option
	if `"`replace'`anything'"' != "" {
		if 0`:word count `anything'' > 2 {
			di as err "option {bf:saving()} incorrectly specified"
			exit 198
		}
	}
	local filename `anything'
	local replace `replace'


	* check if file exists
	if "`filename'" != "" {
		* add dta extention
		local extpos = strpos("`filename'", ".dta")
		if (`extpos' == 0) local filename = "`filename'.dta"
		
		* raise an error in case a file exists
		if "`replace'" == ""  {
			* find the file in the location specified
			cap confirm file "`filename'"
			
			* raise an error in case a file exists
			if !_rc {
				di as err "file {bf:`filename'} already exists. Use " `"""' "replace" `"""' " option to overwrite the file"
				exit 602
			}
		}
	}
	
	sreturn clear
	sreturn local filename `"`filename'"'
	sreturn local replace `replace'
end

program funcHeader, 
/* displays a header before each function run
 */
	version 8
	syntax [anything] 
	
	di as text ""
	di as text "***********************************************"
	di as text "Bunching - "`anything'
	di as text "***********************************************"
	di as text ""
	
end


