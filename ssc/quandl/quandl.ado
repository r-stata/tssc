* 1.0.0 FL 22 Mar 2013
* 1.0.1 FL 12 Oct 2014 fixed a "feature" in Windows: http://www.stata.com/statalist/archive/2012-02/msg01016.html
* 1.0.2 FL 14 Aug 2014 changed from http to https
program quandl
version 9.2
// The program, quandl.ado, pulls dataset as specified by the user from the
// Quandl API. The dataset is copied directly from Quandl, as .csv, to a
// temporary file in Stata, if the "using [filename]" option is not specified.
// Of all the options, only the Quandlcode() option is required. Other options
// are optional. For details, please see examples included in the help file,
// quandl.hlp.
syntax [using/],                  ///
	Quandlcode(string asis)       ///
	[                             ///
	Start(string asis)            ///
	End(string asis)              ///
	AUTHtoken(string asis)        ///
	Transformation(string asis)   ///
	freq(string asis)             ///
	Row(string asis)              ///
	replace                       ///
	clear                         ///
	]

// Check if user has provided authentication token
if `"`authtoken'"' != "" {
    global auth_code `"&auth_token=`authtoken'"'
}
if `"`authtoken'"' == "" & "$auth_code" == "" {
    di _n "It would appear you aren't using an authentication token. Please visit {browse www.quandl.com/help/stata} or your usage may be limited."
}

// Other checks
    // Checking freq() is one of daily|weekly|monthly|quarterly|annual
capture assert inlist(`"`freq'"', "", "daily", "weekly", "monthly", "quarterly", "annual")
if _rc==9 {
    di _n "Please check freq() is one of daily|weekly|monthly|quarterly|annual"
    exit
}
    // Checking transformation() is one of diff|rdiff
capture assert inlist(`"`transformation'"', "", "diff", "rdiff")
if _rc==9 {
    di _n "Please check transformation() is one of diff|rdiff"
    exit
}
    // Checking start date is in 'yyyy-mm-dd' format
if `"`start'"' != "" {
    tokenize `"`start'"', parse("-")
    capture assert inrange(`3', 1, 12) & inrange(`5', 1, 31)
    if _rc==9 {
	    di _n "Please make sure start date is in 'yyyy-mm-dd' format"
	    exit
		}
}
    // Checking end date is in 'yyyy-mm-dd' format
if `"`end'"' != "" {
    tokenize `"`end'"', parse("-")
    capture assert inrange(`3', 1, 12) & inrange(`5', 1, 31)
    if _rc==9 {
	    di _n "Please make sure end date is in 'yyyy-mm-dd' format"
	    exit
		}
}

// Construct Quandl API call
local start_url `"https://www.quandl.com/api/v1/datasets/"'
local ts_start ""
local ts_end ""
local ext `".csv?"'
local diff ""
local collapse_freq ""
local n_row ""

if `"`start'"' != ""          local ts_start `"&trim_start=`start'"'
if `"`end'"' != ""            local ts_end `"&trim_end=`end'"'
if `"`transformation'"' != "" local diff `"&transformation=`transformation'"'
if `"`freq'"' != ""           local collapse_freq `"&collapse=`freq'"'
if `"`row'"' != ""            local n_row `"&rows=`row'"'

local QuandlAPI "`start_url'`quandlcode'`ext'`ts_start'`ts_end'`diff'`collapse_freq'`n_row'$auth_code"

// Using the Stata command "copy" to copy the file from the Quandl API to the
// file quandl_tempfile.csv, which will be erased at the end of the program.
di _n "Copying data from:"
di "`QuandlAPI'"
tempfile quandl_tempfile
qui copy "`QuandlAPI'" `quandl_tempfile'.csv, replace

// Read into Stata the temporary file
qui insheet using `quandl_tempfile'.csv, comma `clear'

// Erase temporary file
capture erase `quandl_tempfile'.csv

// Convert dates (as string) to dates (as Stata dates)
rename date date_str
gen date_num = date(date_str, "ymd")
format date_num %td
drop date_str
rename date_num date

// Check number of observations
if _N == 1 di "Only one observation. Data not 'tsset'"

// Declare dataset to be time series if number of observations greater than 1
else if _N > 1 {
	if `"`freq'"' == "" {
	    di _n "Declare data to be time-series data:"
		tsset date
		order date // Order variables
	}
	else if `"`freq'"' == "daily" {
		tsset date, daily
		order date // Order variables
	}
	else if `"`freq'"' == "weekly" {
		qui gen week = wofd(date)
		capture tsset week, weekly
		
		if _rc==451 {
			di _n `"Found duplicates in week. Data cannot be "tsset" in {bf:week}"'
			duplicates list week
			di _n `"This occured because to declare a weekly time-series data, Stata requires a {stata "help dates":%tw} formatted {it:timevar}, which divides a year into 52 weeks."'
			di _n `"Alternatively, try {stata "tsset date, daily delta(7 days)":tsset date, daily delta(7 days)}"'
			di `"If Stata returns with error "time values with period less than delta() found", consider {stata "drop if _n==_N":dropping the most recent observation}, then {stata "tsset date, daily delta(7 days)":tsset date, daily delta(7 days)}"'
		}

		order week date // Order variables
	}
	else if `"`freq'"' == "monthly" {
		qui gen month = mofd(date)
		tsset month, monthly
		order month date // Order variables
	}
	else if `"`freq'"' == "quarterly" {
		qui gen quarter = qofd(date)
		tsset quarter, quarterly
		order quarter date // Order variables
	}
	else if `"`freq'"' == "annual" {
		qui gen year = yofd(date)
		tsset year, yearly
		order year date // Order variables
	}
}

// Save dataset to filename if supplied by user in the "using [filename]" option
if `"`using'"' != "" {
	qui save `"`using'"', `replace'
    di _n "File `using' saved in `c(pwd)'"
	}

// Describe the dataset
di _n "Describe data in memory or in file:"
describe

end
