*! version 1.2.1 18aug2019
*! Authors: Christopher Candelaria (chris.candelaria@vanderbilt.edu) & Kenneth Shores (kshores@psu.edu)

program define cpiget
version 15.0

#d ;
syntax newvarname,
    TStart(numlist integer min=2  max=2)
    TEnd(numlist integer min=2  max=2)
    BStart(numlist integer min=2  max=2)
    BEnd(numlist integer  min=2 max=2)
    FYMStart(numlist integer max=1 >=1 <=12)
    FYMEnd(numlist integer max=1 >=1 <=12)
    [
        outdta(string)
        clear
        preserve
        FYREName(namelist min=2 max=2)
    ]
;
#d cr
*
* User can only specify: clear, preserve, or neither option
*
if "`preserve'" != "" {
    cap assert "`clear'" == ""
    if _rc!=0 {
        display as error "ERROR: User may not specify both {cmd:clear} and {cmd:preserve} options"
        exit _rc
    }
   preserve
   loc preserveclear = "clear"
}
*
* Parse the start time and end time
*
numlist "`tstart'"
tokenize `r(numlist)'
loc timestart = ym(`1', `2')

numlist "`tend'"
tokenize `r(numlist)'
loc timeend = ym(`1', `2')
*
* Check that tend is larger than tstart
*
cap assert `timestart' <= `timeend'
if _rc!=0 {
    display as error "ERROR: {cmd:tend} date must be larger than {cmd:tstart} date"
    exit _rc
}
*
* Parse the base start & end (year, month) pairs
*
numlist "`bstart'"
tokenize `r(numlist)'
loc basestart = ym(`1',`2')

numlist "`bend'"
tokenize `r(numlist)'
loc baseend = ym(`1',`2')
*
* check that base range falls within time range
*
cap {
    assert inrange(`basestart', `timestart',`timeend')
    assert inrange(`baseend', `timestart',`timeend')
}
if _rc!=0 {
    display as error "Base year outside of time range."
    exit _rc
} 
*
* Parse the namelist for renaming.
*
if "`fyrename'" != "" {
    tokenize "`fyrename'"
    loc fyrename_arg1 `1'
    loc fyrename_arg2 `2'
    cap assert "`1'" == "fystart" | "`1'" == "fyend"
    if _rc!=0 {
        di as error "First argument of option fyrename() must either be fystart or fyend"
        exit _rc
    }
    cap confirm new variable `2'
    if _rc!=0 {
        if _rc==7 {
            di as error "Nothing found were variable name expected for option fyrename()"
            exit _rc
        }
        else if _rc==198 {
            di as error "Invalid name for option fyrename()"
            exit _rc
        }
    }
}

*
* Set the dedicated FRED key for CPI extraction generated 2019-04-02
* 
set fredkey ec503200f5f87be7fcb6ad2fdf3dd025
*
* Format the dates to be extracted for use with import fred
*
loc fredstart : di %td dofm(`timestart')
loc fredend : di %td dofm(`timeend')
*
* Obtain non-seasonally adjusted (NSA) CPI-U data from FRED
* Option for SA could be added in future release
*
di as result "Retrieving CPI data from St. Louis Federal Reserve Bank..." _n
import fred CPIAUCNS, dater(`fredstart' `fredend') `clear' `preserveclear'
*
* Provide meta data about the series for the user
*
di _n
di as result "CPI series metadata:" _n
char list CPIAUCNS[]
*
* Format the dates 
*
tempvar year month ym
g `year' = yofd(daten)
g `month' = month(daten)
g `ym' = ym(`year',`month')
format `ym' %tm
*
* Base-year:
* Create a scalar for the base year range
* This serves as the divisor for rescaling later in the program
*
qui su CPIAUCNS if inrange(`ym', `basestart', `baseend')
tempname basescale
sca `basescale' = r(mean)
*
* Based on user input, create list of fiscal year months
* There is redundancy with the calls to numlist/cnumlist;
* will be addressed in a later version
*
if `fymend' - `fymstart' >=0 {
    cnumlist "`fymstart'/`fymend'"
    loc cmonthlist `r(numlist)' //comma separated
    numlist "`fymstart'/`fymend'"
    loc monthlist `r(numlist)' //space separated
}
else {
    cnumlist "`fymstart'/12 1/`fymend'"
    loc cmonthlist `r(numlist)' //comma separated
    numlist "`fymstart'/12 1/`fymend'"
    loc monthlist `r(numlist)' //space separated
}
*
* Keep only months that appear in the fiscal year
*
qui keep if inlist(`month', `cmonthlist')
*
* Count number of months in the month list
*
local monthcount : list sizeof local(monthlist)
*
* Create a fiscal year month counter
*
tempvar fymonthcount
qui g `fymonthcount' = .
tokenize `monthlist'
forv i = 1/`monthcount' {
    qui replace `fymonthcount' = `i' if `month' == ``i''
}
*
* Create fiscal year start and end variables
*
sort `ym'
* Find observation number that begins the fiscal year
tempvar first
qui egen `first' = min(cond(`fymonthcount' == 1, _n, .))
* Drop all prior observations
qui drop if _n < `first'
* Group years into sequences
tempvar blockseq
qui egen `blockseq' = seq(), block(`monthcount')
* Create the start and end vars
tempvar fystart fyend
bys `blockseq' (`ym') : egen `fystart' = min(`year')
bys `blockseq' (`ym') : egen `fyend' = max(`year')
*
* Drop incomplete fiscal years
*
tempvar obcount
qui bys `blockseq': g `obcount' = _N
qui drop if `obcount' != `monthcount'
*
* Report the start and end date for the full fiscal years
*
di _n
di as result "Based on {cmd: fystart} and {cmd: fyend}, the first and last monthly CPI observation dates are as follows:" _n
qui su `ym'
di as text "First CPI observation date: " as result %tm r(min) _n
di as text "Last CPI observation: " as result %tm r(max) _n
*
* Create fiscal year CPI
*
collapse (mean) CPIAUCNS, by(`fystart' `fyend')

* Scale CPI series according to base year
tempvar base1 base2
g `varlist' = 100*(CPIAUCNS/`basescale')

ren `fystart' fystart
ren `fyend' fyend
keep fy* `varlist'
if "`fyrename'" != "" {
    ren `fyrename_arg1' `fyrename_arg2'
    di as result "NOTE: {cmd: `fyrename_arg1'} renamed as {cmd: `fyrename_arg2'}" _n
}

* Export data set
if "`outdta'" != "" sa "`outdta'", replace

end

/* 
Comma separated numlist. Code by Nick Cox:
https://www.stata.com/statalist/archive/2004-06/msg00541.html
*/
program cnumlist, rclass
    version 8.2 
    numlist `0' 
    local result "`r(numlist)'" 
    local result : subinstr local result " " ",", all
    return local numlist "`result'"
end 

