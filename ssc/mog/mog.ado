program define mog, rclass byable(recall)

/*
Author:         Matt Hurst
Date:           May 26, 2008
Acronym:        MOG (Mean Over Groups)
Purpose:        Make a table of means or totals
					over 1 or 2 other categorical variables
                and a) automatically perform significance tests
                    b) check estimates against quality standards
Last update:    July 20, 2010.
*/

* Start of code:

version 11.1

* Figure out if a re-showing of previous results are requested.
local replayon "no"
if "`0'" == "" & "`r(cmdtext)'" == "" {
	display as error "The last use of mog was not success."
	display as error "Re-showing the previous results is not possible."
	exit 109
}
else if "`0'" == "" {
	display as text "Re-showing the previous table"
	local 0 `"`r(cmdtext)'"'
	local replayon "yes"
}

capture syntax [varlist] [aw fw iw pw/] [if] [in] [,REF1(integer 1) ///
	REF2(integer 1) Decimals(integer 2) ROUND(real 0) SL(real 0.05) MINCount(integer 15) ///
	Fwer SUrvey CELLWidth(integer 8) VARWidth(integer 15) Underscores NODetail RETest TOTal ///
	PUBStand PUBDichot CVToohigh(real 0.3333333333333333) CVWarning(real 0.1666666666666667) ///
	SYMBToohigh(string) SYMBWarning(string) SYMBMincount NOTEST]

* If we are re-showing results, then no detail is turned on and
* there is no need to re-run the primary mean command
if "`replayon'" == "yes" {
	local retest "retest"
	local nodetail "nodetail"
}

* Brief description of the syntax

* arg1 = the variable for which a mean is being calculated.
* arg2 = first grouping (and thus categorical) variable.
* arg3 = second grouping variable, optional.
* arg4 = if statement, optional.
* arg5 = in statement, optional.

/*
Options
ref1         Reference group for the first grouping variable 
             (1 for 1st group, 2 for 2nd group, etc.).
ref2         Reference group for the second grouping variable, optional 
             (1 for 1st group, 2 for 2nd group, etc.).
decimals     Number of decimals that the mean/total is rounded to.
             This is a format mask for displaying results.
round        This function rounds numbers in units of the number given.
				See help on the "round" function for more information.
sl           Significance level to use for tests.
mincount     Minimum number of observations required in each cell
             (based on an instutitions publication guidelines).
fwer         Displays the family-wise error rate based on individual p-values.
survey       Svyset information is used to calculate means.
cellwidth    Adjusts the width of the columns in the table.
             Does not include space for symbols.
varwidth     Caps the row labels to a maximum length.
underscores  Replace spaces in labels with underscores
nodetail     Display only the final table.
retest       Redispplay the table with different options (like reference groups)
             without re-estimating (saves time with brr estimation).
total        Estimate totals using the "total" command.
pubstand     Shows symbols for each estimate to indicate reliability and
             and confidentiality standards of quality based on mincount
             and cvtoohigh and cvwarning
pubdichot    Used if publication quality standards are desired and
             the dependent variable is dichotomous (see symbmincount).
cvtoohigh    The largest cv (coefficient of variate) value for which an estimate 
             is publishable
cvwarning    The largest cv value for which an estimate is publishable
             with no warning.
symbtoohigh  Symbol warning the estimate is not publishable (sample size < mincount or 
             cv > 1/3)
symbwarning  Symbol warning the estimate is publishable but with poor reliability
             (sample size >= mincount and cv < 1/3 and cv > 1/6)
symbmincount Symbol warning the estimate should be suppressed because the sample on which
             it is based is < mincount or, if pubdichot option is used and 
             the dependent variable is dichotomous, the subsamples created by 
             this additional slice are < mincount.
notest       Do not display the results of significance testing with symbols
*/

* Give a general error message if there is a syntax error 
* generated from syntax.
if _rc != 0 {
	display as error "The syntax command generated error code: " _rc
	errmesshelp
	exit _rc
}

* parse the variable list saved in varlist

local anvar    : word 1 of `varlist'
local ctv1     : word 2 of `varlist'
local ctv2     : word 3 of `varlist'
local toomany  : word 4 of `varlist'

local ctv1grp = `ref1'
local ctv2grp = `ref2'

* drop the "in" in `in' and the "if" in `if'.
local intemp = subinword("`in'","in","",1)
local iftemp = subinword("`if'","if","",1)

local restricttext ""
if "`in'" != "" & "`if'" != "" {
	local restricttext "The data is restricted to observations from `intemp' where `iftemp'" 
}
else if "`in'" != "" & "`if'" == "" {
	local restricttext "The data is restricted to observations from `intemp'" 
}
else if "`in'" == "" & "`if'" != "" {
	local restricttext "The data is restricted to observations where `iftemp'" 
}

* Adjust weight and survey so they contain the information needed for the mean
* command later on.

local weightvar "`exp'"

if "`weight'" != "" {
	local anyweight " [`weight' = `weightvar']"
}
if "`survey'" == "survey" {
	local survey "svy: "
}

* Further error checking on the information passed into
* the program by the user beyond what the syntax command
* may generate.

* Incorrect number of variables, or variable data types, in varlist

* variable 1
* No dependent variable found or dependent variable is 
* not numeric
capture confirm numeric variable `anvar' 
if "`anvar'" == "" {
	display as error "You did not specify any variables."
	display as error "This program requires atleast 2 variables to function."
	display as error "The 1st argument must be a variable in your"
	display as error "data file for which you want to estimate some means."
	errmesshelp
	exit 102
}
else if _rc != 0 {
	display as error "The 1st argument must be a variable and"
	display as error "have a numeric data type."
	display as error `""`anvar'" does not meet this requirement."'
	display as error "The 1st argument must be a variable in your"
	display as error "data file for which you want to estimate some means."
	errmesshelp
	exit 109
}

* variable 2
* The first grouping variable is missing or is not numeric
capture confirm numeric variable `ctv1' 
if "`ctv1'" == "" {
	display as error "You did not specify a 2nd variable."
	display as error "This program requires atleast 2 variables to function."
	display as error "The mean of the variable stated in the 1st argument"
	display as error "will be calculated over the groups formed by this grouping variable."
	errmesshelp
	exit 102
}
else if _rc != 0 {
	display as error "The 2nd argument must be a categorical variable and have a"
	display as error "numeric data type."
	display as error `""`ctv1'" does not meet this requirement."'
	display as error "The mean of the variable stated in the 1st argument"
	display as error "will be calculated over the groups formed by this grouping variable."
	errmesshelp
	exit 109
}

* variable 3		--optional
* The second grouping variable is not numeric
capture confirm numeric variable `ctv2' 
if "`ctv2'" != "" & _rc != 0 {
	display as error "The 3rd argument must be a categorical variable and have a"
	display as error "numeric data type."
	display as error `""`ctv2'" does not meet this requirement."'
	display as error "The mean of the variable stated in the 1st argument"
	display as error "will be calculated over the groups formed by the grouping variable"
	display as error "in the 2nd argument and this grouping variable."
	errmesshelp
	exit 109
}

* Too much information
if "`toomany'" != "" {
	display as error "You have entered too many variables"
	display as error "on the command line."
	display as error `"Variables to the right of "`ctv2grp'" are ignored."'
	capture noisily errmesshelp
	exit 103
}

* A weight option and the survey option can not both be used.
if "`anyweight'" != "" & "`survey'" != "" {
	local anyweight ""
	display as error "survey option requested so svyset information is used and"
	display as error "the weight option ignored."
}

* If users don't want details, set the display macro to include a 
* a quietly statement
if "`nodetail'" == "" {
	local Q ""
}
else {
	local Q "quietly:"
}

* OFWER is incompatible with the notest option
if "`fwer'" != "" & "`notest'" != "" {
	display as error "The fwer option is incompatible with the notest option."
	display as error "fwer option ignored."
	local fwer ""
}	

marksample touse

local cmdtouse "mean"
local cmdtousecap "Mean"
if "`total'" != "" {
	local cmdtouse "total"
	local cmdtousecap "Total"
}

if "`retest'" != "" {
	local tempcmd `e(cmd)'
	local tempeover `"`e(over)'"'
	local firstvar : word 2 of `tempeover'
	local secvar   : word 1 of `tempeover'
	local tempanvar `e(varlist)'
	local tempweight : word 2 of `e(wexp)'
	local tempsurvey `e(prefix)'
	* if survey option was previously used, it must be used now and vice versa.
	if "`tempsurvey'" == "svy" {
		local tempsurvey "svy: "
	}
	else {
		local tempsurvey ""
	}
	if "`survey'" != "`tempsurvey'" {
		display as error "The survey setting can not be adjusted; previous setting used."
	}
	local survey "`tempsurvey'"

	* If the key command parts were not repeated correctly, show an error.
	if "`ctv2'" != "" & "`tempanvar'" == "`anvar'" & "`secvar'" == "`ctv2'" & "`firstvar'" == "`ctv1'" 	///
	& e(sample) == `touse' & "`tempcmd'" == "`cmdtouse'"	{
		* Everything ok
	}
	else if "`ctv2'" == "" & "`tempanvar'" == "`anvar'" & "`secvar'" == "`ctv1'" 	///
	& e(sample) == `touse' & "`tempcmd'" == "`cmdtouse'"	{
		* Everything ok
	}
	else {
		* One of the conditions in the ifs above failed.
		display as error "For the retest option, the command must be typed in the same way"
		display as error "before the comma as in the previous execution of the command."
		display as error "(Exception: the previous survey option must be used.)"
		display as error "The other options may be adjusted (i.e. ref1, ref2, round, decimals)."
		display ""
		if "`tempanvar'" != "`anvar'" {
			display as error "The analysis variable is not the same."
		}
		if "`secvar'" != "`ctv2'" & "`ctv2'" != "" {
			display as error "The second grouping variable is not the same."
		}
		if "`firstvar'" != "`ctv1'"  {
			display as error "The first grouping variable is not the same."
		}
		if e(sample) != `touse'  {
			display as error "The sample (via if, in and the missing values of the variables) is not the same."
		}
		if "`tempweight'" != "`weightvar'" & "`survey'" == ""  {
			display as error "The weight variable is not the same."
		}
		exit 109
	}
}
if "`pubdichot'" != "" & "`pubstand'" == "" {
	* Ignore pubdichot option
	display as error "Pubdichot option ignored, must be used with pubstand."
	local pubdichot ""
}

* Constants

* The default number of characters reserved for each cell is 11
* Substract off 1 blank space for a margin and 2 for 2 possible symbols
* gives a total of 8 spaces for the number

if "`symbtoohigh'" == "" {
	local symbtoohigh "F"
}
if "`symbwarning'" == "" {
	local symbwarning "E"
}
if "`symbmincount'" == "" {
	local symbmincount "X"
}

* display the options chosen
`Q'display ""
`Q'display as text "Options"
`Q'display ""
`Q'display "ref1:        category `ctv1grp' in `ctv1' is the reference group"
if "`ctv2'" != "" {
	`Q'display "ref2:        category `ctv2grp' in `ctv2' is the reference group"
}
`Q'display "decimals:    estimates will be displayed with `decimals' decimals"
if `round' != 0 {
	`Q'display "round:       estimates will be rounded to the nearest multiple of `round'"
	`Q'display "             before being displayed (and formatted with decimals)."
}
`Q'display "sl:          tests will use a `sl' level of significance"
`Q'display "mincount:    the minimum sample size for each estimate is set to `mincount'"
`Q'display "cellwidth:   the number of spaces for each number is `cellwidth'"
if "`underscores'" != "" {
	`Q'display "underscores: spaces in variable labels will be replaced with underscores"
}
if "`fwer'" != "" {
	`Q'display "fwer:        the observed family-wise error rates will be displayed"
}
if "`survey'" != "" {
	`Q'display "survey:      svyset information will be used to calculated means and variances"
}
else if "`anyweight'" != "" {
	`Q'display "weight:      weights will be used to calculated means and variances"
}
if "`pubstand'" != "" {
	`Q'display "pubstand:    symbols will be used in the table to indicate estimate"

	`Q'display "             reliability as per cvtoohigh, and cvwarning"
	`Q'display "             and confidentiality as per mincount"
	`Q'display "cvtoohigh:   `cvtoohigh'"
	`Q'display "symbtoohigh: `symbtoohigh'"
	`Q'display "cvwarning:   `cvwarning'"
	`Q'display "symbwarning: `symbwarning'"
	`Q'display "symbmincount:`symbmincount'"
}
if "`pubdichot'" != "" {
	capture tab `anvar' if `touse'
	if _rc == 0 {
		quietly tab `anvar' if `touse',matrow(anvarvalues)
		local anvarcols = rowsof(anvarvalues)
	}
	if _rc != 0 | `anvarcols' != 2 {
		`Q'display as error "pubdichot:   Option ignored: the dependent variable is not dichotomous."
		local pubdichot ""
	}
	else {
		`Q'display as text "pubdichot:   symbmincount (default X) will indicate minimum cell sizes"
		`Q'display as text "             by the idependent variable(s) AND the analysis variable."
	}
}

* Sample size counts per group
`Q'display ""
`Q'display ""
`Q'display as text "Sample size counts per group"
* Now display a table of frequencies.
* Try to use tabulate first, because it is fast, but
* if it won't work because of there are too many columns,
* then use table.
if "`pubdichot'" == "" {
	capture tabulate `ctv1' `ctv2' if `touse'
	if _rc == 0 {
		`Q'tabulate `ctv1' `ctv2' if `touse'
	}
	else {
	 	`Q'table `ctv1' `ctv2' if `touse'
	}
}
else {
	capture bysort `anvar': tabulate `ctv1' `ctv2' if `touse'
	if _rc == 0 {
		`Q'bysort `anvar': tabulate `ctv1' `ctv2' if `touse'
	}
	else {
	 	`Q'bysort `anvar': table `ctv1' `ctv2' if `touse'
	}
}
* Pick up the values of the grouping variables.
quietly tab `ctv1' if `touse', matrow(ctv1values)
local numrows = rowsof(ctv1values)
local over_cats_ctv1 = `numrows'
local over_cats = `numrows'

if "`ctv2'" != "" {
	quietly tab `ctv2' if `touse',matrow(ctv2values)
	local numcols = rowsof(ctv2values)
	local over_cats_ctv2 = `numcols'
}
else {
	local numcols = 1
}


`Q'display as text ""
`Q'display "Institutional publication guidelines require minimum"
`Q'display "sample sizes in each cell. This minimum amount is "
`Q'display "currently set to `mincount' (see option mincount)."
`Q'display as text ""
`Q'display "Violations of this rule in the table above are:"

local endtextneeded "yes"

* Following code is not as compact as is could be, but is fast.
if "`pubdichot'" == "" {
	forvalues c=1/`numcols' {
		forvalues r=1/`numrows' {
			if "`ctv2'" != "" {
				local countup = `numrows'*(`c'-1) + `r'
				quietly count if `touse' & `ctv1' == ctv1values[`r',1] & `ctv2' == ctv2values[`c',1]
				local count_`countup' = r(N)
			}
			else {
				local countup = `r'
				quietly count if `touse' & `ctv1' == ctv1values[`r',1]
				local count_`countup' = r(N)
			}
			if r(N)  < `mincount' {
				local endtextneeded "no"
				local ctv1valtemp = ctv1values[`r',1]
				local labelrow : label (`ctv1') `ctv1valtemp'
				if "`ctv2'" == "" {
					`Q'display as text `"Row "`labelrow'" is "' as result r(N)
				}
				else {
					local ctv2valtemp = ctv2values[`c',1]
					local labelcol : label (`ctv2') `ctv2valtemp'
					`Q'display as text `"Column "`labelcol'", row "`labelrow'" is "' as result r(N)
				}
				if r(N) < 2 {
					display as error "This command requires each cell's sample size to be"
					display as error "greater than 1."
					exit 461
				}
			}
		}
	}
}
else {
	forvalues c=1/`numcols' {
		forvalues r=1/`numrows' {
			if "`ctv2'" != "" {
				local countup = `numrows'*(`c'-1) + `r'
				quietly count if `anvar' == anvarvalues[1,1] & `touse' & `ctv1' == ctv1values[`r',1] & `ctv2' == ctv2values[`c',1]
				local count_temp1 = r(N)
				quietly count if `anvar' == anvarvalues[2,1] & `touse' & `ctv1' == ctv1values[`r',1] & `ctv2' == ctv2values[`c',1]
				local count_temp2 = r(N)
				local count_`countup' = min(`count_temp1',`count_temp2')  
			}
			else {
				local countup = `r'
				quietly count if `anvar' == anvarvalues[1,1] & `touse' & `ctv1' == ctv1values[`r',1]
				local count_temp1 = r(N)
				quietly count if `anvar' == anvarvalues[2,1] & `touse' & `ctv1' == ctv1values[`r',1]
				local count_temp2 = r(N)
				local count_`countup' = min(`count_temp1',`count_temp2')
			}
			if `count_temp1' < `mincount' {
				local endtextneeded "no"
				local ctv1valtemp = ctv1values[`r',1]
				local labelrow : label (`ctv1') `ctv1valtemp'
				if "`ctv2'" == "" {
					`Q'display as text "Table `anvar' = " anvarvalues[1,1] `": row "`labelrow'" is "' as result `count_temp1'
				}
				else {
					local ctv2valtemp = ctv2values[`c',1]
					local labelcol : label (`ctv2') `ctv2valtemp'
					`Q'display as text "Table `anvar' = " anvarvalues[1,1] `": column "`labelcol'", row "`labelrow'" is "' as result `count_temp1'
				}
			}
			if `count_temp2' < `mincount' {
				local endtextneeded "no"
				local ctv1valtemp = ctv1values[`r',1]
				local labelrow : label (`ctv1') `ctv1valtemp'
				if "`ctv2'" == "" {
					`Q'display as text "Table `anvar' = " anvarvalues[2,1] `": row "`labelrow'" is "' as result `count_temp2'
				}
				else {
					local ctv2valtemp = ctv2values[`c',1]
					local labelcol : label (`ctv2') `ctv2valtemp'
					`Q'display as text "Table `anvar' = " anvarvalues[2,1] `": column "`labelcol'", row "`labelrow'" is "' as result `count_temp2'
				}
			}
			if (`count_temp1'+`count_temp2') < 2 {
				display as error "This command requires each cell's sample size to be"
				display as error "greater than 1."
				exit 461
			}
		}
	}
}

if "`endtextneeded'" == "yes" {
	`Q'display as text "None found"
}

* Determine if one grouping variable is used and stream
* the code accordingly

if "`ctv2'" == "" {

	* Generate a variable of 1s to force the mean command
	* to use "_subpop_#" as the format for all categories
	* Stata 11.1 July 6, 2010 does not use _subpop_ for all
	* variance estimation types. For the new bootstrap method,
	* a number comes thru only.  So I need to pick this up so
	* that the test routines work.
	tempvar tempi
	gen `tempi' = 1

	`Q'display as text ""
	`Q'display "The following text may be used to execute the"
	`Q'display "`cmdtouse' command."
	`Q'display ""
	`Q'display "`survey'`cmdtouse' `anvar'`anyweight' `if'`in', over(`ctv1')"
	if "`retest'" == "" {
		`Q'`survey'`cmdtouse' `anvar'`anyweight' if `touse', over(`ctv1' `tempi')
	}
	else {
		`Q'`cmdtouse'
	}
	`Q'display ""
	`Q'display ""

	* Get estimates and covariance matrix (used in a number of commands).
	matrix M = e(b)
	matrix varcovar = e(V)	
	* Get the text used for the stubs (e.g. "_subpop_", or "")
	local stublist `e(over_namelist)'
	local stubone : word 1 of `stublist'
	*Assume the first stub ends in 1--always seems to be the case
	local stub = substr("`stubone'",1,length("`stubone'")-1)
	
	`Q'display as text "Estimates and their t-ratios and coefficients of variation"
	`Q'display ""
	`Q'display "Group        Estimate            T-ratio     CV"
	forvalues	count = 1/`over_cats' {
		`Q'display as result "_subpop_`count'" _column(14) %-16.5fc = M[1,`count'] ///
		_column(34) M[1,`count']/sqrt(varcovar[`count',`count']) ///
		_column(46) sqrt(varcovar[`count',`count'])/M[1,`count']
	local cv_`count' = sqrt(varcovar[`count',`count'])/M[1,`count']
	}
	`Q'display ""
	* Note the user if a variance is zero.
	* This might be reasonable in small samples of indicator variables.
	forvalues count = 1/`over_cats' {
		scalar curr_variance = varcovar[`count',`count']
		if curr_variance == 0 {
			`Q'display as text "Note: the variance of _subpop_`count' is 0."
		}
	}

	* Perform significance tests

	if "`notest'" == "" {
		`Q'display ""
		`Q'display as text "Significance tests"
	}
	local maxcommandtext "0"
	local OFWER = 1
	forvalues count = 1/`over_cats' {
		local ctv1grpstar`count' = ""
		* run the test
		if "`notest'" == "" {
			`Q'lincom [`anvar']`stub'`ctv1grp' - [`anvar']`stub'`count'
			local p_temp = 2*ttail(`r(df)',abs(`r(estimate)')/`r(se)')
			if `p_temp' != . {
				local OFWER = `OFWER'*(1-`p_temp')
			}
			if `p_temp' < `sl' {
				local ctv1grpstar`count' = "*"
			}
		}
		if "`pubstand'" != "" {
			if `count_`count'' < `mincount' { 
				local ctv1grpstar`count' "`ctv1grpstar`count''`symbmincount'"
			}
			else if `cv_`count'' > `cvtoohigh' {
				local ctv1grpstar`count' "`ctv1grpstar`count''`symbtoohigh'"
			}
			else if `cv_`count'' <= `cvtoohigh' & `cv_`count'' >= `cvwarning' {
				local ctv1grpstar`count' "`ctv1grpstar`count''`symbwarning'"
			}
		}

		* Set up for displaying results
		local ctv1valtemp = ctv1values[`count',1]
		local label`count' : label (`ctv1') `ctv1valtemp'
		local length = length("`label`count''")
		if `length' > `varwidth' {
			local length = `varwidth'
			local label`count' = substr("`label`count''",1,`length')
			local label`count' "`label`count''~"
		}
		local maxcommandtext "`maxcommandtext',`length'" 

		if "`underscores'" == "underscores" {
			*Substitute in "_" for " " in each label if there are any
			local label`count' = subinstr("`label`count''"," ","_",.)
		}
	}

	local OFWER = 1 - `OFWER'

	local varwidthtouse = max(`maxcommandtext')+3

	* display Results in Pretty Table

	display ""
	display as text "`cmdtousecap's of `anvar' by `ctv1'"
	display "Estimation technique for standard errors: " e(vce)
	if "`restricttext'" != "" {
		display "`restricttext'"
	}
	display ""
	local formatvalue = 23
	forvalues count = 1/`over_cats' {
		display as text "`label`count''" as result _column(`varwidthtouse') rtrim(string(round(M[1,`count'],`round'),"%-`formatvalue'.`decimals'fc")) "`ctv1grpstar`count''"
	}

	if "`notest'" == "" {
		display ""
		display as text "Notes"
		display "* significantly different from the reference group of the variable"
		display "  `ctv1', category number `ctv1grp', p < `sl'"
		if "`fwer'" == "fwer" {
			display ""
			display "OFWER: Observed Family-Wise Error Rate."
			display "OFWER is the joint alpha for a row (column) of independent tests"
			display "considered together."
		}
	}
}

else {
	
	local tot_cats = `over_cats_ctv1'*`over_cats_ctv2'

	* Now run the estimation command with the survey prefix over
	* the categories

	`Q'display as text ""
	`Q'display "The following text may be used to execute the"
	`Q'display "`cmdtouse' command."
	`Q'display ""
	`Q'display "`survey'`cmdtouse' `anvar'`anyweight' `if'`in', over(`ctv2' `ctv1')"
	if "`retest'" == "" {
		`Q'`survey'`cmdtouse' `anvar'`anyweight' if `touse', over(`ctv2' `ctv1')
	}
	else {
		`Q'`cmdtouse'
	}

	if "`tot_cats'" != "`e(N_over)'" {
		*Note: situation should not occur with sample sizes over 2 in each group
		display as error "A problem occurred while creating estimates and variance"
		display as error "estimates for the categories requested." 
		display as error "Please try different categories."
		exit 498
	}
	* Store estimates and covariance matrix (used in a number of commands).
	matrix M = e(b)
	matrix varcovar = e(V)	
	* Get the text used for the stubs (e.g. "_subpop_", or "")
	local stublist `e(over_namelist)'
	local stubone : word 1 of `stublist'
	*Assume the first stub ends in 1--always seems to be the case
	local stub = substr("`stubone'",1,length("`stubone'")-1)

	`Q'display ""
	`Q'display ""
	`Q'display as text "Estimates and their t-ratios and coefficients of variation"
	`Q'display ""
	`Q'display "Group        Estimate            T-ratio     CV"
	forvalues	count = 1/`tot_cats' {
		`Q'display as result "_subpop_`count'" _column(14) %-16.5fc = M[1,`count'] ///
		_column(34) M[1,`count']/sqrt(varcovar[`count',`count']) ///
		_column(46) sqrt(varcovar[`count',`count'])/M[1,`count']
	local cv_`count' = sqrt(varcovar[`count',`count'])/M[1,`count']
	}
	`Q'display ""
	* Note the user if a variance is zero.
	* Also make cellwidth larger if any number to display will take up more space
	local formatvalue = 23
	forvalues count = 1/`tot_cats' {
		scalar curr_variance = varcovar[`count',`count']
		if curr_variance == 0 {
			`Q'display as text "Note: the variance of _subpop_`count' is 0."
		}
		local cellwidth = max(`cellwidth',length(rtrim(string(round(M[1,`count'],`round'),"%-`formatvalue'.`decimals'fc"))))
	}

	* Categories are in a different order, but this is just
	* to help the development of the for loops

	* Perform significance tests
	if "`notest'" == "" {
		`Q'display ""
		`Q'display as text "Significance tests"
	}

	* Forloop for tests moving along rows, having a ctv1 ref group
	if "`notest'" == "" {
		forvalues count = 1/`over_cats_ctv2' {
			local OFWER_col_`count' = 1
			local start_ctv1 = ((`count'-1)*`over_cats_ctv1')+1
			local end_ctv1 = `count'*`over_cats_ctv1'
			* Find the subpopulation that refers to the reference group for this column
			local ctv1grp_temp = `ctv1grp'+(`count'-1)*`over_cats_ctv1'
			forvalues count2 = `start_ctv1'/`end_ctv1' {
				* run the test
				local ctv1grpstar`count2' = ""
					`Q'lincom [`anvar']`stub'`ctv1grp_temp' - [`anvar']`stub'`count2'
					local p_temp = 2*ttail(`r(df)',abs(`r(estimate)')/`r(se)')
					if `p_temp' != . {
						local OFWER_col_`count' = `OFWER_col_`count''*(1-`p_temp')
					}
					if `p_temp' < `sl' {
						local ctv1grpstar`count2' = "*"
					}
				}
			local OFWER_col_`count' = 1 - `OFWER_col_`count''
		}
	}

	* Forloop for tests moving down columns, having a ctv2 ref group
	forvalues count = 1/`over_cats_ctv1' {
		local OFWER_row_`count' = 1
		* Find the subpopulation that is the reference group for this row
		local ctv2grp_temp = `count'+(`ctv2grp'-1)*`over_cats_ctv1'
		forvalues count2 = `count'(`over_cats_ctv1')`tot_cats' {
			* run the test 
			local ctv2grpstar`count2' = ""
			if "`notest'" == "" {
				`Q'lincom [`anvar']`stub'`ctv2grp_temp' - [`anvar']`stub'`count2'
				local p_temp = 2*ttail(`r(df)',abs(`r(estimate)')/`r(se)')
				if `p_temp' != . {
					local OFWER_row_`count' = `OFWER_row_`count''*(1-`p_temp')
				}
				if `p_temp' < `sl' {
					local ctv2grpstar`count2' = "^"
				}
			}
			if "`pubstand'" != "" {
				if `count_`count2'' < `mincount' { 
					local ctv2grpstar`count2' "`ctv2grpstar`count2''`symbmincount'"
				}
				else if `cv_`count2'' > `cvtoohigh' {
					local ctv2grpstar`count2' "`ctv2grpstar`count2''`symbtoohigh'"
				}
				else if `cv_`count2'' <= `cvtoohigh' & `cv_`count2'' >= `cvwarning' {
					local ctv2grpstar`count2' "`ctv2grpstar`count2''`symbwarning'"
				}
			}
		}
		local OFWER_row_`count' = 1 - `OFWER_row_`count''
	}

	* Set up for displaying results
	* Find what the spacing should be between the 
	* Row label names and the next column

	* varwidthtouse must have a mininum of 7 characters so that
	* the row label for OFWER will fit comfortably if this
	* option is chosen AND there is space for the TABLE title

	local varwidth = max(`varwidth',5) /* 5 character min length for labels */

	local maxcommandtext "0"
	forvalues count = 1/`over_cats_ctv1' {
		local ctv1valtemp = ctv1values[`count',1]
		local label`count' : label (`ctv1') `ctv1valtemp'
		local length = length("`label`count''")
		if `length' > `varwidth' {
			local length = `varwidth'
			local label`count' = substr("`label`count''",1,`length')
			local label`count' "`label`count''~"
		}
		local varwidthtouse = max(`varwidthtouse',`length'+3,8)
		if "`underscores'" == "underscores" {
			local label`count' = subinstr("`label`count''"," ","_",.)
		}
	}

	* Calculate spaces needed for symbols (includes 1 space as a column separator)
	local symbolspace = 1  
	if "`notest'" == "" {
		local symbolspace = `symbolspace' + 2
	}
	if "`pubstand'" != "" {
		local symbolspace = `symbolspace' + 1
	}

	* display Results in Pretty Table

	display ""
	display as text "`cmdtousecap's of `anvar' by `ctv1' and `ctv2'"
	display "Estimation technique for standard errors: " e(vce)
	if "`restricttext'" != "" {
		display "`restricttext'"
	}
	display ""

	* Store a place holder text, currently set to "table".
	* Needed for the table to copy correctly into other applications
	local starttext = "Table"
	local columncount = `varwidthtouse'

	* Print headings for each label of the 2nd grouping variable (column variable)
	display "`starttext'" _continue
	forvalues count = 1/`over_cats_ctv2' {
		local ctv2valtemp = ctv2values[`count',1]
		local labeltwo`count' : label (`ctv2') `ctv2valtemp'

		if "`underscores'" == "underscores" {
			local labeltwo`count' = subinstr("`labeltwo`count''"," ","_",.)
		}
		if length("`labeltwo`count''") > `cellwidth'+`symbolspace'-1 {
			display _column(`columncount') substr("`labeltwo`count''",1,`cellwidth'+`symbolspace'-2) "~" _continue
		}
		else {
			display _column(`columncount') "`labeltwo`count''" _continue
		}
		local columncount = `columncount' + `cellwidth' + `symbolspace'
	}
	if "`fwer'" == "fwer" {
		display _column(`columncount') "OFWER"
	}
	else {
		* Kick to next line
		display ""
	}

	local columncount = `varwidthtouse'
	local ofwerfv = min(`cellwidth'+1, 6)
	local ofwerdec = `ofwerfv'-1

	forvalues count = 1/`over_cats_ctv1' {
	display as text "`label`count''" _column(`columncount') _continue
		forvalues count2 = `count'(`over_cats_ctv1')`tot_cats' {
			local columncount = `columncount' + `cellwidth' + `symbolspace'
			display as result rtrim(string(round(M[1,`count2'],`round'),"%-`formatvalue'.`decimals'fc")) "`ctv1grpstar`count2''`ctv2grpstar`count2''" _column(`columncount') _continue
		} 
		if "`fwer'" == "fwer" {
			display as result %-`ofwerfv'.`ofwerdec'f = `OFWER_row_`count''
		}
		else {
			display ""
		}
		local columncount = `varwidthtouse'
	}

	* Write last row of OFWER

	if "`fwer'" == "fwer" {
		local columncount = `varwidthtouse'
		display as text "OFWER" _continue
		forvalues count2 = 1 / `over_cats_ctv2' {
			display _column(`columncount') as result %-`ofwerfv'.`ofwerdec'f = `OFWER_col_`count2'' _continue
			local columncount = `columncount' + `cellwidth' + `symbolspace'
		}
		display as text ""
	}

	if "`notest'" == "" {
		display ""
		display as text "Notes"
		display "* significantly different from the reference group of the variable"
		display "  `ctv1', category number `ctv1grp', p < `sl'"
		display "^ significantly different from the reference group of the variable"
		display "  `ctv2', category number `ctv2grp', p < `sl'"
		if "`fwer'" == "fwer" {
			display ""
			display "OFWER: Observed Family-Wise Error Rate."
			display "OFWER is the joint alpha for a row (column) of independent tests"
			display "considered together."
			display "See help file for more information."
		}
	}
}
return local cmdtext `"`0'"'
end


* Helper programs

program errmesshelp
	display as error `"See help file for more information (type "help mog" then hit enter)."'
	display as text ""
	display as text "Example usage:"
	display as text ""
	display as text "mog income sex [pw=weight]"
	display as text "mog income sex agegroup [pw=weight], ref1(2) ref2(3)"
	display as text "mog income sex agegroup [pw=weight], ref1(2) ref2(3) decimals(0) sl(.01)"
	display as text ""
	display as text "See help file for the syntax diagram"
end

