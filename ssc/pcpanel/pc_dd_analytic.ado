**********************************************************************************
*** -------------------------------------------------------------------------- ***
*** PROGRAM: ANALYTICAL POWER CALCULATIONS FOR DIFFERENCE IN DIFFERENCES MODEL ***
*** -------------------------------------------------------------------------- ***
**********************************************************************************
	
*! version 3.0 14apr2020

program define pc_dd_analytic
version `=clip(`c(version)', 9.0, 13.1)'

syntax, [n(numlist >0 integer sort) mde(numlist sort) POWer(numlist >0 <1 sort) ///
				pre(numlist >=0 integer sort) post(numlist >=0 integer sort) p(numlist >0 <1 sort) ///
				ALPha(numlist max=1 >0 <1) VARiance(numlist >0 sort) sd(numlist >0 sort) ///
				ar1(numlist >-1 <1 sort) avgcov(numlist min=3 max=3) avgcor(numlist min=3 max=3) ///
				ncovest(numlist >0 integer min=1 max=1) TRUEPARAMeters ///
				DEPvar(varname) i(varname) t(varname) if(string) in(string)  ///
				ONESIDed OUTfile(string) append replace] 

				
// grab file name and store master dataset
{
capture drop PlACEhOLDER_VariaBLE
local master_fname = c(filename)
local tmpdir_pathname = substr("`c(tmpdir)'",1,length("`c(tmpdir)'")-1)
local tmpdir_pathname_len = length("`tmpdir_pathname'")
if substr("`master_fname'",1,`tmpdir_pathname_len')=="`tmpdir_pathname'" {
	local master_fname = ""
}
tempfile m_dta_before_pcs
quietly save "`m_dta_before_pcs'", replace emptyok
quietly gen PlACEhOLDER_VariaBLE = . // fixes bug for cases where there is no dataset in memory
}


// check for errors in options
{
display " "								
capture assert ("`power'"!="" & "`n'"!="" & "`mde'"!="")==0
	local rc = _rc
	if `rc' {
		display "{err}Error: Must leave one of power(), n(), mde() unspecified in order," 
		display "{err}       to give the program a free parameter to solve for"
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
	
capture assert ("`n'"=="" & "`mde'"=="")==0
	local rc = _rc
	if `rc' {
		display "{err}Error: Must specify either option n() or option mde() "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
	
if "`power'"=="" & (("`n'"!="") + ("`mde'"!=""))==1 {
	local power = 0.80
	display "{text}Warning: {inp}Option power() not specified; default power of 0.80 assumed" _n
}

capture assert (("`power'"=="") + ("`n'"=="") + ("`mde'"==""))==1
	local rc = _rc
	if `rc' {
		display "{err}Error: Must leave one of power(), n(), mde() unspecified"
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}
	
if "`pre'"=="" {
	local pre = 1
	display "{text}Warning: {inp}Number of pre-treatment periods not specified; default of 1 pre-period assumed" _n
	}	
if "`post'"=="" {
	local post = 1
	display "{text}Warning: {inp}Number of post-treatment periods not specified; default of 1 post-period assumed" _n
	}
capture assert word("`pre'",1)!="0"  
	local rc = _rc
	if `rc' {
		display "{err}Error: DD model cannot specify 0 pre-treatment periods"
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}
capture assert word("`post'",1)!="0"  
	local rc = _rc
	if `rc' {
		display "{err}Error: DD model cannot specify 0 post-treatment periods"
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	

if "`p'"=="" { 
	local p = 0.5
	display "{text}Warning: {inp}Option p() not specified; default treatment ratio of p=0.5 assumed" _n
}

if "`alpha'"=="" {
	local alpha = 0.05
	display "{text}Warning: {inp}Option alpha() not specified; default Type-I error rate of alpha=0.05 assumed" _n
}

if "`onesided'"=="onesided" {
	display "{text}Warning: {inp}One-sided hypothesis tests toggled " _n
}

capture assert ("`variance'"!="" & "`sd'"!="")==0
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot separately specify residual variance using option variance(), "
		display "{err}       and residual standard deviation using option sd() "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}		
capture assert ("`variance'"!="" | "`sd'"!="") if "`depvar'"==""
	local rc = _rc
	if `rc' {
		display "{err}Error: Must either specify a residual variance [sd] using option variance() [sd()], "
		display "{err}       or indicate dependent variable using the option depvar() "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert "`variance'"!="" | "`sd'"!="" | "`depvar'"!=""
	local rc = _rc
	if `rc' {
		display "{err}Error: Must either specify a residual variance [sd] using option variance() [sd()], "
		display "{err}       or indicate dependent variable using the option depvar() "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert (("`variance'"!="") + ("`sd'"!="") + ("`depvar'"!=""))<2
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify both residual variance [sd] using option variance() [sd()], and "
		display "{err}       dependent variable for calculating residual variance using the option depvar() "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}
capture assert ("`variance'"=="" & "`sd'"=="") if "`depvar'"!=""
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify both residual variance [sd] using option variance() [sd()], and "
		display "{err}       dependent variable for calculating residual variance using the option depvar() "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}
	
capture assert "`avgcov'"=="" if "`variance'"=="" & "`sd'"==""
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify option avgcov() if option variance() or sd() is not specified "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}		
capture assert "`avgcor'"=="" if "`variance'"=="" & "`sd'"==""
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify option avgcor() if option variance() or sd() is not specified "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}		
capture assert "`ar1'"=="" if "`variance'"=="" & "`sd'"==""
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify option ar1() if option variance() or sd() is not specified "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}		
	
capture assert (("`ar1'"!="") + ("`avgcov'"!=""))<2 
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify both option ar1() and option avgcov() "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert (("`ar1'"!="") + ("`avgcor'"!=""))<2 
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify both option ar1() and option avgcor() "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert (("`avgcor'"!="") + ("`avgcov'"!=""))<2 
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify both option avgcov() and option avgcor() "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	

	
if "`variance'"=="" & "`sd'"!=""{
	foreach sdLOOP in `sd' {
		local varLOOP = string(`sdLOOP'^2,"%9.4f")
		local variance = "`variance'" + " " + "`varLOOP'"
	}
}	

	
if "`ar1'"=="" & "`avgcov'"=="" & "`avgcor'"=="" & "`depvar'"=="" & (`pre'!=1 | `post'!=1) {
	display "{text}Warning: {inp}Options ar1(), avgcov(), and avgcor() not specified, meaning that idiosyncratic " 
	display "          error will be assume i.i.d., which is unrealistic in a DD model with 3+ periods " _n
}	

capture assert wordcount("`variance'")==1 if "`avgcov'"!=""
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify multiple values for variance() when using option avgcov() "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert wordcount("`avgcov'")==3 if "`avgcov'"!=""
	local rc = _rc
	if `rc' {
		display "{err}Error: DD model can only accommodate exactly three within-unit average covariance terms using option "
		display "{err}       avgcov(); these three terms represent, in order: the average within-unit covariance in periods "
		display "{err}       before treatment, in periods after treatment, and across pre/post treatment periods "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert wordcount("`avgcor'")==3 if "`avgcor'"!=""
	local rc = _rc
	if `rc' {
		display "{err}Error: DD model can only accommodate exactly three within-unit average correlation terms using option"
		display "{err}       avgcor(); these three terms represent, in order: the average within-unit correlaciton in periods "
		display "{err}       before treatment, in periods after treatment, and across pre/post treatment periods "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert wordcount("`pre'")==1 & wordcount("`post'")==1 if "`avgcov'"!=""
	local rc = _rc
	if `rc' {
		display "{err}Error: When using option avgcov(), DD model can only accommodate a fixed panel length in options pre() and post(). "
		display "{err}       This is because the average within-unit covariance depends on the number of pre/post-treatment periods. "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert wordcount("`pre'")==1 & wordcount("`post'")==1 if "`avgcor'"!=""
	local rc = _rc
	if `rc' {
		display "{err}Error: When using option avgcor(), DD model can only accommodate a fixed panel length in options pre() and post(). "
		display "{err}       This is because the average within-unit correlation depends on the number of pre/post-treatment periods. "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	

if "`depvar'"!="" {
	capture tsset
		if !_rc & "`i'"=="" {
			local i = r(panelvar)
			display "{text}Warning: {inp}Cross-sectional unit i() missing, assumed to be `i'" _n
		}
	capture tsset
		if !_rc & "`t'"=="" {
			local t = r(timevar)
			display "{text}Warning: {inp}Time period variable t() missing, assumed to be `t'" _n
		}
	capture assert "`i'"!="" & "`t'"!=""
		local rc = _rc
		if `rc' {
			display "{err}Error: Must specify unit i() and time period t() variables to estimate covariance structure of `depvar'"
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}	
	capture confirm numeric variable `depvar' 
		local rc = _rc
		if `rc' {
			display "{err}Error: Dependent variable `depvar' must be numeric"
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}
	capture confirm numeric variable `i' 
		local rc = _rc
		if `rc' {
			display "{err}Error: Cross-sectional unit variable `i' must be numeric"
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}
	capture confirm numeric variable `t' 
		local rc = _rc
		if `rc' {
			display "{err}Error: Time period variable `t' must be numeric"
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}
	if "`if'"!="" {
		capture keep if `if'
			local rc = _rc
			if `rc' {
				display "{err}Error: Option if() needs to be a valid if statement, i.e. if(year>2000 & group==1)"
				use "`m_dta_before_pcs'", clear	
				exit `rc'
			}		
	}
	if "`in'"!="" {
		capture keep in `in'
			local rc = _rc
			if `rc' {
				display "{err}Error: Option in() needs to be a valid in statement, i.e. if(1/100)"
				use "`m_dta_before_pcs'", clear	
				exit `rc'
			}		
	}
	capture unique `i' `t' if `depvar'!=. & `i'!=. & `t'!=.
		local rc = _rc
		if `rc' {
			display "{err}Error: Please ssc install unique"
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}		
	quietly unique `i' `t' if `depvar'!=. & `i'!=. & `t'!=.
	capture assert (r(N)==r(sum)) | (r(N)==r(unique))
		local rc = _rc
		if `rc' {
			display "{err}Error: To calculate covariance structure, `depvar' must be unique by `i' and `t' "
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}		
	capture assert "`variance'"==""
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot specify option variance() if option depvar() is specified "
			display "{err}       (program will estimate residual variance from `depvar' data) "
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}	
	capture assert "`sd'"==""
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot specify option sd() if option depvar() is specified "
			display "{err}       (program will estimate residual variance from `depvar' data) "
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}	
	capture assert "`avgcov'"==""
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot specify option avgcov() if option depvar() is specified "
			display "{err}       (program will estimate residual covariances from `depvar' data) "
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}	
	capture assert "`avgcor'"==""
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot specify option avgcor() if option depvar() is specified "
			display "{err}       (program will estimate residual correlations from `depvar' data) "
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}	
	capture assert "`ar1'"==""
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot specify option ar1() if option depvar() is specified "
			display "{err}       (program will estimate residual covariances from `depvar' data) "
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}	

}	

capture assert "`trueparameters'"=="" if "`avgcov'"=="" & "`avgcor'"==""
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify option trueparameters without manually entering  "
		display "{err}       average covariance [correlation] terms using the option avgcov() [avgcor()] "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert "`ncovest'"=="" if "`avgcov'"=="" & "`avgcor'"==""
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify option ncovest without manually entering  "
		display "{err}       average covariance [correlation] terms using the option avgcov() [avgcor()] "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert ("`ncovest'"=="" | "`trueparameters'"=="") if "`avgcov'"!="" | "`avgcor'"!=""
	local rc = _rc
	if `rc' {
		display "{err}Error: Cannot specify BOTH option ncovest (which indicates that manually  "
		display "{err}       inputted avgcov() [avgcor()] terms are estimated from residuals) AND "
		display "{err}       option trueparameters (which indicates they are exact parameter values) "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert ("`ncovest'"!="" | "`trueparameters'"!="") if "`avgcov'"!="" 
	local rc = _rc
	if `rc' {
		display "{err}Error: Must specify EITHER option trueparameters (which indicates that manually inputted avgcov() terms are "
		display "{err}       assumed to be true parameters values) OR option ncovest (which indicates they are estimated from residuals) "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	
capture assert ("`ncovest'"!="" | "`trueparameters'"!="") if "`avgcor'"!="" 
	local rc = _rc
	if `rc' {
		display "{err}Error: Must specify EITHER option trueparameters (which indicates that manually inputted avgcor() terms are "
		display "{err}       assumed to be true parameters values) OR option ncovest (which indicates they are estimated from residuals) "
		use "`m_dta_before_pcs'", clear	
		exit `rc'
	}	


	
if "`outfile'"=="" {
	display "{text}Warning: {inp}To store power calculations in a .txt file, include a filename using option outfile() " _n
}

if "`outfile'"!="" {
	if regexm("`outfile'",".dta") {
		local outfile = subinstr("`outfile'",".dta",".txt",1)
		display "{text}Warning: {inp}Option outfile() changed to .txt format: `outfile' " _n
	}
	else if regexm("`outfile'",".xlsx") {
		local outfile = subinstr("`outfile'",".xlsx",".txt",1)
		display "{text}Warning: {inp}Option outfile() changed to .txt format: `outfile' " _n
	}
	else if regexm("`outfile'",".xls") {
		local outfile = subinstr("`outfile'",".xls",".txt",1)
		display "{text}Warning: {inp}Option outfile() changed to .txt format: `outfile' " _n
	}
	else if regexm("`outfile'",".raw") {
		local outfile = subinstr("`outfile'",".raw",".txt",1)
		display "{text}Warning: {inp}Option outfile() changed to .txt format: `outfile' " _n
	}
	else if regexm("`outfile'",".csv") {
		local outfile = subinstr("`outfile'",".csv",".txt",1)	
		display "{text}Warning: {inp}Option outfile() changed to .txt format: `outfile' " _n
	}
	else if regexm(substr("`outfile'",-5,5),"[.]")==0 & "`outfile'"!="" {
		local outfile = "`outfile'" + ".txt"
		display "{text}Warning: {inp}Option outfile() changed to .txt format: `outfile' " _n
	}	

	capture assert substr("`outfile'",-4,4)==".txt"
		local rc = _rc
		if `rc' {
			display "{err}Error: Option outfile() must be in .txt format"
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}
	capture confirm new file `outfile'	
		local rc = _rc
		if `rc' & "`replace'"=="" & "`append'"=="" { // if the file exists, you must have either append or replace
			display "{err}Error: Option append/replace not specified, cannot overwrite existing file `outfile' "
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}
	capture confirm file `outfile'	
		local rc = _rc
		if `rc' & "`append'"=="append" {
			local append = ""
			*display "{err}Error: Option append not allowed, as file `outfile' does not exist."
			*use "`m_dta_before_pcs'", clear	
			*exit `rc'
		}
	if "`replace'"=="replace" & "`append'"=="append" {
		local replace = ""
	}	
}

}


// make indicators for calculating psi terms (if not specified)
{
if "`avgcov'"!="" {
	local psi_ind = 1
	local psiB = word("`avgcov'",1)
	local psiA = word("`avgcov'",2)
	local psiX = word("`avgcov'",3)
}
else if "`avgcor'"!="" {
	local psi_ind = 1
	local corrB = word("`avgcor'",1)
	local corrA = word("`avgcor'",2)
	local corrX = word("`avgcor'",3)
	capture assert `corrB'<1 & `corrB'>-1 & `corrA'<1 & `corrA'>-1 & `corrX'<1 & `corrX'>-1
		local rc = _rc
		if `rc' {
			display "{err}Error: Option avgcor() must specify three average serial correlations between -1 and 1 "
			use "`m_dta_before_pcs'", clear	
			exit `rc'
		}		
}
else if "`ar1'"!="" {
	local cOUNter = 0
	foreach ar1LOOP in `ar1' {
		local cOUNter = `cOUNter'+1
		local psi_ind = "`psi_ind' `cOUNter'"
	}
}
else if "`depvar'"!="" {
	local psi_ind = 1
	local variance = 0
}
else {
	local psi_ind = 1
}

}	


// write header of outfile, report what program is doing
{
if "`outfile'"!="" {
	capture file close sim_results 
	file open sim_results using "`outfile'", write text `replace' `append'
	file write sim_results _n "       ----------------------------------------------------"
	file write sim_results _n "       Analytical Power Calculations for Panel Diff-in-Diff"
	file write sim_results _n "           RCT with serially correlated error structure    "
	file write sim_results _n "       ----------------------------------------------------"
	file write sim_results _n _n
	file write sim_results "Power calculations assume Type-I error rate of alpha=`alpha'" 
	if "`onesided'"=="onesided"{
		file write sim_results " (with a one-sided hypothesis test)" 
	}
	file write sim_results _n _n
	if "`avgcov'"!="" {
		file write sim_results "User-provided within-unit average covariances of idiosyncratic errors: " _n
		file write sim_results "avgcov_pre   =`psiB' (avg covariance between pre-treatment periods) "	_n
		file write sim_results "avgcov_post  =`psiA' (avg covariance between post-treatment periods) " _n	
		file write sim_results "avgcov_cross =`psiX' (avg covariance across pre/post-treatment periods) " _n
	}	
	else if "`avgcor'"!="" {
		file write sim_results "User-provided within-unit average correlations of idiosyncratic errors: " _n
		file write sim_results "avgcor_pre   =`corrB' (avg correlation between pre-treatment periods) "	_n
		file write sim_results "avgcor_post  =`corrA' (avg correlation between post-treatment periods) " _n	
		file write sim_results "avgcor_cross =`corrX' (avg correlation across pre/post-treatment periods) " _n
	}	
	else if "`ar1'"!="" {
		file write sim_results "Errors assumed to follow an AR(1) process " 
		file write sim_results "(may poorly approximate more complex covariance structures) "	_n
	}	
	else if "`depvar'"!="" {
		file write sim_results "Residual covarianve matrix estimated separately for " 
		file write sim_results "each panel length using variable `depvar' "	_n
	}	
	else {
		file write sim_results "Power calculations assume zero serial correlation " 
		file write sim_results "(unlikely in most panel data settings) "	_n
	}
	file write sim_results _n "p = proportion of units randomized into treatment"
	file write sim_results _n _n "pre/post = number of pre/post treatment periods "
	file write sim_results "(treatment occurs at same time for all treated units) "
	if "`depvar'"=="" /*& "`sd'"==""*/ {
		file write sim_results _n _n "var = variance of the idiosyncratic error term" 
		file write sim_results " (after partialing out unit and time fixed effects) " 
	}
	file write sim_results _n _n

}

if "`power'"!="" & "`n'"=="" & "`mde'"!="" {
	display "{inp}Solving for sample size, given minimum detectable effect mde={`mde'} and power={`power'} " _n
	if "`outfile'"!="" {
		file write sim_results "pc_dd_analytic solved for sample size, given " 
		file write sim_results "minimum detectable effect mde={`mde'} and power={`power'} " _n _n
	}
}
else if "`power'"=="" & "`n'"!="" & "`mde'"!="" {
	display "{inp}Solving for power, given minimum detectable effect mde={`mde'} and sample size n={`n'}" _n 
	if "`outfile'"!="" {
		file write sim_results "pc_dd_analytic solved for power, given " 
		file write sim_results "minimum detectable effect mde={`mde'} and sample size n={`n'} " _n _n
	}
}
else if "`power'"!="" & "`n'"!="" & "`mde'"=="" {
	display "{inp}Solving for minimum detectable effect, given sample size n={`n'} and power={`power'}" _n
	if "`outfile'"!="" {
		file write sim_results "pc_dd_analytic solved for minimum detectable effect, given "
		file write sim_results "sample size n={`n'} and  power ={`power'} " _n _n
	}
}
}


// locals for spacing of output
{
foreach len_MAX in n mde power p pre post variance {
	local len_MAX_`len_MAX' = 0
	foreach len_MAX_loop in ``len_MAX''{
		local len_MAX_`len_MAX' = max(`len_MAX_`len_MAX'',length("`len_MAX_loop'"))
	}
}	
if "`outfile'"!="" {	
	foreach LOOP_var in n mde power p pre post variance {
		local `LOOP_var'_sp = `len_MAX_`LOOP_var'' - length("`LOOP_var'")
		if ``LOOP_var'_sp'==-3 {
			local `LOOP_var'_disp = "`LOOP_var' "
		}
		else if ``LOOP_var'_sp'==-2 {
			local `LOOP_var'_disp = "`LOOP_var'  "
		}
		else if ``LOOP_var'_sp'==-1 {
			local `LOOP_var'_disp = "`LOOP_var'   "
		}
		else if ``LOOP_var'_sp'==0 {
			local `LOOP_var'_disp = "`LOOP_var'    "
		}
		else if ``LOOP_var'_sp'==1 {
			local `LOOP_var'_disp = " `LOOP_var'    "
		}
		else if ``LOOP_var'_sp'==2 {
			local `LOOP_var'_disp = "  `LOOP_var'    "
		}
		else if ``LOOP_var'_sp'==3 {
			local `LOOP_var'_disp = "   `LOOP_var'    "
		}
		else if ``LOOP_var'_sp'==4 {
			local `LOOP_var'_disp = "    `LOOP_var'    "
		}
		else if ``LOOP_var'_sp'==5 {
			local `LOOP_var'_disp = "     `LOOP_var'    "
		}
		else if ``LOOP_var'_sp'==6 {
			local `LOOP_var'_disp = "      `LOOP_var'    "
		}
		else if ``LOOP_var'_sp'==7 {
			local `LOOP_var'_disp = "       `LOOP_var'    "
		}
		else {
			local `LOOP_var'_disp = "`LOOP_var'"
		}
	}
	if `len_MAX_mde'==0 {
		local mde_disp = "  mde     "
	}
	else if `len_MAX_power'==0 {
		local power_disp = "power   "
	}
	else if `len_MAX_n'==0 {
		local n_disp = "   n    "
	}
	local var_disp = subinstr("`variance_disp'","iance","     ",1)
	if "`ar1'"=="" & "`depvar'"=="" {
		file write sim_results   _n "   --------------------------------------------------------------------" _n
		file write sim_results      "     `n_disp' `mde_disp' `power_disp'  `p_disp' `pre_disp' `post_disp'   `var_disp' " _n
		file write sim_results      "   --------------------------------------------------------------------" _n
	}
	else if "`depvar'"!="" {
		file write sim_results  _n "   --------------------------------------------------------------------" _n
		file write sim_results     "     `n_disp' `mde_disp' `power_disp'  `p_disp' `pre_disp' `post_disp' depvar " _n
		file write sim_results     "   --------------------------------------------------------------------" _n
	}
	else {
		file write sim_results  _n "   --------------------------------------------------------------------" _n
		file write sim_results     "     `n_disp' `mde_disp' `power_disp'  `p_disp' `pre_disp' `post_disp'   `var_disp'ar1 " _n
		file write sim_results     "   --------------------------------------------------------------------" _n
	}
}

}


// execute power calculations	
{ 

foreach preLOOP in `pre' {
	foreach postLOOP in `post' {
		foreach varianceLOOP in `variance' {
			foreach psi_indLOOP in `psi_ind' {

				if "`avgcov'"!="" & `psi_indLOOP'==1 {
					local psiBLOOP = "`psiB'"
					local psiALOOP = "`psiA'"
					local psiXLOOP = "`psiX'"
					local estJLOOP = "`ncovest'"
					if "`estJLOOP'"=="" {
						local estJLOOP = 1000
					}	
				}
				
				else if "`avgcor'"!="" & `psi_indLOOP'==1 {
					local psiBLOOP = `corrB'*`varianceLOOP'
					local psiALOOP = `corrA'*`varianceLOOP'
					local psiXLOOP = `corrX'*`varianceLOOP'
					local estJLOOP = "`ncovest'"
					if "`estJLOOP'"=="" {
						local estJLOOP = 1000
					}	
				}
				
				else if "`ar1'"!="" {
					local ar1LOOP = word("`ar1'",`psi_indLOOP')
					
					if `preLOOP'==1 {
						local psiBLOOP = 0
					}
					else {
						local psiBLOOP = 0
						local preLOOP_minus1 = `preLOOP'-1
						forvalues psiB_indLOOP = 1/`preLOOP_minus1' {
							local psiBLOOP = `psiBLOOP' + (`preLOOP'-`psiB_indLOOP')*`ar1LOOP'^`psiB_indLOOP'
						}
						local psiBLOOP = (2/((`preLOOP'-1)*`preLOOP'))*`psiBLOOP'*`varianceLOOP'
					}
					
					if `postLOOP'==1 {
						local psiALOOP = 0
					}
					else {
						local psiALOOP = 0
						local postLOOP_minus1 = `postLOOP'-1
						forvalues psiA_indLOOP = 1/`postLOOP_minus1' {
							local psiALOOP = `psiALOOP' + (`postLOOP'-`psiA_indLOOP')*`ar1LOOP'^`psiA_indLOOP'
						}
						local psiALOOP = (2/((`postLOOP'-1)*`postLOOP'))*`psiALOOP'*`varianceLOOP'
					}

					if `preLOOP'==1 & `postLOOP'==1 {
						local psiXLOOP = `ar1LOOP'
					}
					else if `preLOOP'==`postLOOP' {
						local psiXLOOP = 0
						local postLOOP_plus1 = `postLOOP'+1
						local postLOOP_2minus1 = 2*`postLOOP'-1
						forvalues psiX_indLOOP = 1/`postLOOP' {
							local psiXLOOP = `psiXLOOP' + `psiX_indLOOP'*`ar1LOOP'^`psiX_indLOOP'
						}
						forvalues psiX_indLOOP = `postLOOP_plus1'/`postLOOP_2minus1' {
							local psiXLOOP = `psiXLOOP' + (2*`postLOOP'-`psiX_indLOOP')*`ar1LOOP'^`psiX_indLOOP'
						}
					}
					else if abs(`preLOOP'-`postLOOP')==1 {
						local psiXLOOP = 0
						local prepostLOOP_min = min(`preLOOP',`postLOOP')
						local prepostLOOP_min2 = `preLOOP'+`postLOOP'-`prepostLOOP_min'
						local prepostLOOP_2minus1 = `preLOOP'+`postLOOP'-1
						forvalues psiX_indLOOP = 1/`prepostLOOP_min' {
							local psiXLOOP = `psiXLOOP' + `psiX_indLOOP'*`ar1LOOP'^`psiX_indLOOP'
						}
						forvalues psiX_indLOOP = `prepostLOOP_min2'/`prepostLOOP_2minus1' {
							local psiXLOOP = `psiXLOOP' + (`preLOOP'+`postLOOP'-`psiX_indLOOP')*`ar1LOOP'^`psiX_indLOOP'
						}
					}
					else if `preLOOP'>`postLOOP' {
						local psiXLOOP = 0
						local postLOOP_plus1 = `postLOOP'+1
						local preLOOP_minus1 = `preLOOP'-1
						local prepostLOOP_2minus1 = `preLOOP'+`postLOOP'-1
						forvalues psiX_indLOOP = 1/`postLOOP' {
							local psiXLOOP = `psiXLOOP' + `psiX_indLOOP'*`ar1LOOP'^`psiX_indLOOP'
						}
						forvalues psiX_indLOOP = `postLOOP_plus1'/`preLOOP_minus1' {
							local psiXLOOP = `psiXLOOP' + (`postLOOP')*`ar1LOOP'^`psiX_indLOOP'
						}
						forvalues psiX_indLOOP = `preLOOP'/`prepostLOOP_2minus1' {
							local psiXLOOP = `psiXLOOP' + (`preLOOP'+`postLOOP'-`psiX_indLOOP')*`ar1LOOP'^`psiX_indLOOP'
						}
					}
					else {
						local psiXLOOP = 0
						local preLOOP_plus1 = `preLOOP'+1
						local postLOOP_minus1 = `postLOOP'-1
						local prepostLOOP_2minus1 = `preLOOP'+`postLOOP'-1
						forvalues psiX_indLOOP = 1/`preLOOP' {
							local psiXLOOP = `psiXLOOP' + `psiX_indLOOP'*`ar1LOOP'^`psiX_indLOOP'
						}
						forvalues psiX_indLOOP = `preLOOP_plus1'/`postLOOP_minus1' {
							local psiXLOOP = `psiXLOOP' + (`preLOOP')*`ar1LOOP'^`psiX_indLOOP'
						}
						forvalues psiX_indLOOP = `postLOOP'/`prepostLOOP_2minus1' {
							local psiXLOOP = `psiXLOOP' + (`preLOOP'+`postLOOP'-`psiX_indLOOP')*`ar1LOOP'^`psiX_indLOOP'
						}
					}									
					local psiXLOOP = (1/(`preLOOP'*`postLOOP'))*`psiXLOOP'*`varianceLOOP'
				}

				else if "`depvar'"!="" {
					pc_dd_covar `depvar', i(`i') t(`t') pre(`preLOOP') post(`postLOOP')
					local varianceLOOP = r(variance)
					local psiBLOOP = r(cov_pre)
					local psiALOOP = r(cov_post)
					local psiXLOOP = r(cov_cross)	
					local estJLOOP = r(n_units)
					if `preLOOP'==1 {
						local psiBLOOP = 0
					}
					if `postLOOP'==1 {
						local psiALOOP = 0
					}
				}	
				
				else {
					local psiBLOOP = 0
					local psiALOOP = 0
					local psiXLOOP = 0						
				}
						
				if "`depvar'"!="" | (("`avgcov'"!="" | "`avgcor'"!="") & "`trueparameters'"==""){
					local parenLOOP = ((`estJLOOP'*(`preLOOP'+`postLOOP')^2)/(`estJLOOP'-1)) * (((`preLOOP'+`postLOOP')/(2*(`preLOOP'^2)*(`postLOOP'^2)))*`varianceLOOP' + ((`postLOOP'-1)/(2*(`preLOOP'^2)*`postLOOP'))*`psiALOOP' + ((`preLOOP'-1)/(2*`preLOOP'*(`postLOOP'^2)))*`psiBLOOP')
				}
				else {
					local parenLOOP = ((`preLOOP'+`postLOOP')/(`preLOOP'*`postLOOP'))*`varianceLOOP' + ((`postLOOP'-1)/`postLOOP')*`psiALOOP' + ((`preLOOP'-1)/`preLOOP')*`psiBLOOP' - 2*`psiXLOOP'
				}

				foreach pLOOP in `p' {

					if "`n'"!="" & "`mde'"!="" & "`power'"=="" {
						foreach nLOOP in `n' {
							foreach mdeLOOP in `mde' {
							
								if `psiALOOP'!=0 | `psiBLOOP'!=0 | `psiXLOOP'!=0 {
									local dofLOOP = `nLOOP'
								}	
								else {
									local dofLOOP = `nLOOP'*(`preLOOP'+`postLOOP')-(`nLOOP'+`preLOOP'+`postLOOP') 
								}	
								if "`onesided'"=="onesided" {
									local t_alpLOOP = abs(invttail(`dofLOOP',`alpha'))
								}	
								else {
									local t_alpLOOP = abs(invttail(`dofLOOP',`alpha'/2))
								}	
	
								local powerLOOP = 1-ttail(`dofLOOP',(`mdeLOOP'/sqrt((1/(`pLOOP'*(1-`pLOOP')*`nLOOP'))*`parenLOOP')) - `t_alpLOOP')
								local powerLOOP = string(`powerLOOP',"%9.4f")

								foreach LOOP_var in n mde power p pre post variance {					
									local `LOOP_var'LOOP_sp = `len_MAX_`LOOP_var'' - length("``LOOP_var'LOOP'")
									if ``LOOP_var'LOOP_sp'==0 {
										local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==1 {
										local `LOOP_var'LOOP_disp = " ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==2 {
										local `LOOP_var'LOOP_disp = "  ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==3 {
										local `LOOP_var'LOOP_disp = "   ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==4 {
										local `LOOP_var'LOOP_disp = "    ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==5 {
										local `LOOP_var'LOOP_disp = "     ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==6 {
										local `LOOP_var'LOOP_disp = "      ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==7 {
										local `LOOP_var'LOOP_disp = "       ``LOOP_var'LOOP'"
									}
									else {
										local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'"
									}
								}

								if "`ar1LOOP'"=="" & "`depvar'"=="" {
									noisily display "{inp}DD power calc:  n=`nLOOP_disp'   mde=`mdeLOOP_disp'   power=`powerLOOP_disp'   p=`pLOOP_disp'   pre=`preLOOP_disp'   post=`postLOOP_disp'   var=`varianceLOOP_disp' "
									if "`outfile'"!="" {
											file write sim_results "     `nLOOP_disp'     `mdeLOOP_disp'     `powerLOOP_disp'      `pLOOP_disp'     `preLOOP_disp'     `postLOOP_disp'     `varianceLOOP_disp' " _n
									}
								}
								else if "`depvar'"!="" {
									noisily display "{inp}DD power calc:  n=`nLOOP_disp'   mde=`mdeLOOP_disp'   power=`powerLOOP_disp'   p=`pLOOP_disp'   pre=`preLOOP_disp'   post=`postLOOP_disp'   depvar=`depvar' "
									if "`outfile'"!="" {
											file write sim_results "     `nLOOP_disp'     `mdeLOOP_disp'     `powerLOOP_disp'      `pLOOP_disp'     `preLOOP_disp'     `postLOOP_disp'     `depvar' " _n
									}
								}
								else {
									noisily display "{inp}DD power calc:  n=`nLOOP_disp'   mde=`mdeLOOP_disp'   power=`powerLOOP_disp'   p=`pLOOP_disp'   pre=`preLOOP_disp'   post=`postLOOP_disp'   var=`varianceLOOP_disp'   ar1=`ar1LOOP' "
									if "`outfile'"!="" {
											file write sim_results "     `nLOOP_disp'     `mdeLOOP_disp'     `powerLOOP_disp'      `pLOOP_disp'     `preLOOP_disp'     `postLOOP_disp'     `varianceLOOP_disp'     `ar1LOOP' " _n
									}
								}
							}
						}
					}

					else if "`n'"!="" & "`mde'"=="" & "`power'"!="" {
						foreach nLOOP in `n' {
							foreach powerLOOP in `power' {
							
								if `psiALOOP'!=0 | `psiBLOOP'!=0 | `psiXLOOP'!=0 {
									local dofLOOP = `nLOOP'
								}	
								else {
									local dofLOOP = `nLOOP'*(`preLOOP'+`postLOOP')-(`nLOOP'+`preLOOP'+`postLOOP') 
								}	
								if "`onesided'"=="onesided" {
									local t_alpLOOP = abs(invttail(`dofLOOP',`alpha'))
								}	
								else {
									local t_alpLOOP = abs(invttail(`dofLOOP',`alpha'/2))
								}	
								
								local mdeLOOP = (-invttail(`dofLOOP',`powerLOOP')+`t_alpLOOP')*sqrt((1/(`pLOOP'*(1-`pLOOP')*`nLOOP'))*`parenLOOP')
								local mdeLOOP = string(`mdeLOOP',"%9.4f")
								if substr("`mdeLOOP'",2,1)=="." {
									local mdeLOOP = "  `mdeLOOP'"
								}
								else if substr("`mdeLOOP'",3,1)=="." {
									local mdeLOOP = " `mdeLOOP'"
								}	
								
								foreach LOOP_var in n mde power p pre post variance {					
									local `LOOP_var'LOOP_sp = `len_MAX_`LOOP_var'' - length("``LOOP_var'LOOP'")
									if ``LOOP_var'LOOP_sp'==0 {
										local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==1 {
										local `LOOP_var'LOOP_disp = " ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==2 {
										local `LOOP_var'LOOP_disp = "  ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==3 {
										local `LOOP_var'LOOP_disp = "   ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==4 {
										local `LOOP_var'LOOP_disp = "    ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==5 {
										local `LOOP_var'LOOP_disp = "     ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==6 {
										local `LOOP_var'LOOP_disp = "      ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==7 {
										local `LOOP_var'LOOP_disp = "       ``LOOP_var'LOOP'"
									}
									else {
										local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'"
									}
								}
											
								if "`ar1LOOP'"=="" & "`depvar'"=="" {
									noisily display "{inp}DD power calc:  n=`nLOOP_disp'   mde=`mdeLOOP_disp'   power=`powerLOOP_disp'   p=`pLOOP_disp'   pre=`preLOOP_disp'   post=`postLOOP_disp'   var=`varianceLOOP_disp' "
									if "`outfile'"!="" {
											file write sim_results "     `nLOOP_disp'     `mdeLOOP_disp'     `powerLOOP_disp'      `pLOOP_disp'     `preLOOP_disp'     `postLOOP_disp'     `varianceLOOP_disp' " _n
									}
								}
								else if "`depvar'"!="" {
									noisily display "{inp}DD power calc:  n=`nLOOP_disp'   mde=`mdeLOOP_disp'   power=`powerLOOP_disp'   p=`pLOOP_disp'   pre=`preLOOP_disp'   post=`postLOOP_disp'   depvar=`depvar' "
									if "`outfile'"!="" {
											file write sim_results "     `nLOOP_disp'     `mdeLOOP_disp'     `powerLOOP_disp'      `pLOOP_disp'     `preLOOP_disp'     `postLOOP_disp'     `depvar' " _n
									}
								}
								else {
									noisily display "{inp}DD power calc:  n=`nLOOP_disp'   mde=`mdeLOOP_disp'   power=`powerLOOP_disp'   p=`pLOOP_disp'   pre=`preLOOP_disp'   post=`postLOOP_disp'   var=`varianceLOOP_disp'   ar1=`ar1LOOP' "
									if "`outfile'"!="" {
											file write sim_results "     `nLOOP_disp'     `mdeLOOP_disp'     `powerLOOP_disp'      `pLOOP_disp'     `preLOOP_disp'     `postLOOP_disp'     `varianceLOOP_disp'     `ar1LOOP' " _n
									}
								}
							}
						}
					}

					else if "`n'"=="" & "`mde'"!="" & "`power'"!="" {
						foreach mdeLOOP in `mde' {
							foreach powerLOOP in `power' {

								local nLOOP = 100
								forvalues nLOOP_calibrate = 1/5 {
									
									if `psiALOOP'!=0 | `psiBLOOP'!=0 | `psiXLOOP'!=0 {
										local dofLOOP = `nLOOP'
									}	
									else {
										local dofLOOP = `nLOOP'*(`preLOOP'+`postLOOP')-(`nLOOP'+`preLOOP'+`postLOOP') 
									}	
									if "`onesided'"=="onesided" {
										local t_alpLOOP = abs(invttail(`dofLOOP',`alpha'))
									}	
									else {
										local t_alpLOOP = abs(invttail(`dofLOOP',`alpha'/2))
									}								
													
									local nLOOP = ((-invttail(`dofLOOP',`powerLOOP')+`t_alpLOOP')*sqrt((1/(`pLOOP'*(1-`pLOOP')*(`mdeLOOP'^2)))*`parenLOOP'))^2
									
								}
	
								local nLOOP = round(`nLOOP')
								if length("`nLOOP'")==1 {
									local nLOOP = "   `nLOOP'"
								}
								else if length("`nLOOP'")==2 {
									local nLOOP = "  `nLOOP'"
								}
								else if length("`nLOOP'")==3 {
									local nLOOP = " `nLOOP'"
								}

								foreach LOOP_var in n mde power p pre post variance {					
									local `LOOP_var'LOOP_sp = `len_MAX_`LOOP_var'' - length("``LOOP_var'LOOP'")
									if ``LOOP_var'LOOP_sp'==0 {
										local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==1 {
										local `LOOP_var'LOOP_disp = " ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==2 {
										local `LOOP_var'LOOP_disp = "  ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==3 {
										local `LOOP_var'LOOP_disp = "   ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==4 {
										local `LOOP_var'LOOP_disp = "    ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==5 {
										local `LOOP_var'LOOP_disp = "     ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==6 {
										local `LOOP_var'LOOP_disp = "      ``LOOP_var'LOOP'"
									}
									else if ``LOOP_var'LOOP_sp'==7 {
										local `LOOP_var'LOOP_disp = "       ``LOOP_var'LOOP'"
									}
									else {
										local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'"
									}
								}

								if "`ar1LOOP'"=="" & "`depvar'"=="" {
									noisily display "{inp}DD power calc:  n=`nLOOP_disp'   mde=`mdeLOOP_disp'   power=`powerLOOP_disp'   p=`pLOOP_disp'   pre=`preLOOP_disp'   post=`postLOOP_disp'   var=`varianceLOOP_disp' "
									if "`outfile'"!="" {
											file write sim_results "     `nLOOP_disp'     `mdeLOOP_disp'     `powerLOOP_disp'      `pLOOP_disp'     `preLOOP_disp'     `postLOOP_disp'     `varianceLOOP_disp' " _n
									}
								}
								else if "`depvar'"!="" {
									noisily display "{inp}DD power calc:  n=`nLOOP_disp'   mde=`mdeLOOP_disp'   power=`powerLOOP_disp'   p=`pLOOP_disp'   pre=`preLOOP_disp'   post=`postLOOP_disp'   depvar=`depvar' "
									if "`outfile'"!="" {
											file write sim_results "     `nLOOP_disp'     `mdeLOOP_disp'     `powerLOOP_disp'      `pLOOP_disp'     `preLOOP_disp'     `postLOOP_disp'     `depvar' " _n
									}
								}
								else {
									noisily display "{inp}DD power calc:  n=`nLOOP_disp'   mde=`mdeLOOP_disp'   power=`powerLOOP_disp'   p=`pLOOP_disp'   pre=`preLOOP_disp'   post=`postLOOP_disp'   var=`varianceLOOP_disp'   ar1=`ar1LOOP' "
									if "`outfile'"!="" {
											file write sim_results "     `nLOOP_disp'     `mdeLOOP_disp'     `powerLOOP_disp'      `pLOOP_disp'     `preLOOP_disp'     `postLOOP_disp'     `varianceLOOP_disp'     `ar1LOOP' " _n
									}
								}
							}
						}
					}
				}
			}
		}
	}
}


}
	

// finish writing results to outfile, and report having done so in console	
if "`outfile'"!="" {
	file write sim_results "   --------------------------------------------------------------------" _n 
	file write sim_results "   --------------------------------------------------------------------" _n 
	file close sim_results
	noisily display _n "DD power calculations stored in file `outfile'"
}		

	
quietly use "`m_dta_before_pcs'", clear
capture drop PlACEhOLDER_VariaBLE
end

*******************************************************************************************
*******************************************************************************************
