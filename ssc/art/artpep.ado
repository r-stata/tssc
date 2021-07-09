*! version 1.0.4 PR 05jul2013.
program define artpep, rclass
version 10.0
/*
	pts() = list of numbers of patients accrued up to end of current period, P;
		length of this list defines P
	epts() = list of numbers of patients expected to be accrued in periods P+1, P+2, ...
	eperiods() = number of periods to project over, starting at P+1
	stoprecruit() = period number at end of which recruitment is to stop. If given as 0
			(the default), continue recruiting according to schedule in epts()
	startperiod() = period to start forward projections from.
			Default startperiod is final period defined by pts().
	* (other options) = options for artsurv.
	n() (if specified) = number of patients at end of recruitment to current period.
		This makes recruitment figures into weights rather than absolute numbers of patients.
	tunit() = time units, essentially as in -artsurv-
*/

syntax [using/], [ PTS(numlist) EPTs(numlist) EPEriods(int 1) N(integer 0) REPLACE ///
 STArtperiod(int 0) STOPrecruit(int 0) TUnit(int 1) DATEstart(string) * ]

if "`datestart'" != "" {
	// `datestart' corresponds to the first calendar day of the first period
	local sdate = date("`datestart'", "DMY")
	if missing(`sdate') {
		di as err "invalid date, `datestart'"
		exit 198
	}
	if `tunit' == 7 {
		di as err "calendar dates not applicable to tunit(7)"
		exit 198
	}
	// Lengths in days of the various time units
	local length1 365.25
	local length2 = `length1' / 2
	local length3 = `length1' / 4
	local length4 = `length1' / 12
	local length5 = `length1' / 52
	local length6 1
}

// Check for $S_ARTPEP in command, if so display whole command
capture local result: subinstr local 0 "$S_ARTPEP" "", count(local nat)
if _rc==0 {
	if `nat'>0 noisily window push artpep `0'
}

if "`pts'"=="" {
	di as err "option pts() required"
	exit 198
}
if `tunit'<1 | `tunit'>7 {
	di as err "Invalid time-unit code"
	exit 198
}
tokenize `""year" "6 months" "quarter" "month" "week" "day" "period""'
local lperiod ``tunit''

* pts is a numlist of numbers of patients recruited.
* It also defines the number of recruitment periods.
local recperiod: word count `pts'
local endperiod=`recperiod'+`eperiods'

if `startperiod'>0 {
	if `startperiod'>`recperiod' {
		di as err "startperiod() must be less than or equal to the number of periods implied by pts()"
		exit 198
	}
}
else local startperiod 0
if `stoprecruit'!=0 {
	if `stoprecruit'<`recperiod' | `stoprecruit'>`endperiod' {
		di as err "invalid stoprecruit(), must be between `recperiod' and `endperiod'"
		exit 198
	}
}
else local stoprecruit `endperiod'

if `"`using'"'!="" {
	if substr(`"`using'"',-4,.)!=".dta" {
		local using `using'.dta
	}
	if "`replace'"=="" {
		confirm new file `"`using'"'
	}
	tempname tmp
	local postvl period patients ctrl_events tot_events power
	if "`datestart'" != "" local postvl date `postvl'
	postfile `tmp' `postvl' using `using', `replace'
}

* Compute numpats = total #pts recruited from period 1 to recperiod inclusive
local numpats 0
tokenize `pts'
while "`1'"!="" {
	local numpats=`numpats'+`1'
	mac shift
}

/*
	Force sample size at end of recruitment to n if `n' given.
	Recruitment values given by pts() are then weights, not absolute numbers.
	Future recruitment values are then suitably scaled.
	UNDER CONSTRUCTION.
*/
if `n'>0 {
	local factor=`n'/`numpats'
}
else local factor 1

* epts is the expected recruitment from now on.
* If not given, it is taken as the current mean recruitment rate per period, rounded to nearest 1 patient.
if "`epts'"=="" {
	local rate=round(`numpats'/`recperiod', 1)
	di as text "[assuming projected rate of recruitment = " `rate' " patients per `lperiod']"
	* Project accrual forward up to `eperiods' periods
	tokenize `pts'
	while "`1'"!="" {
		local epts `epts' `rate'
		mac shift
	}
}
else {
	* Prepare string of expected patient accruals, replicating final # if it is too short
	local nepts: word count `epts'
	if `nepts'<`eperiods' {
		local lastept: word `nepts' of `epts'
		local j1=`nepts'+1
		forvalues j=`j1'/`eperiods' {
			local pt: word `j' of `pts'
			local epts `epts' `lastept'
		}
	}
}
local hcol 41
local hcol2 = `hcol' + 2
if "`datestart'" != "" {
	di as text _n "Date      {c |} " %8s "`lperiod'" " {c |}    #pats" _col(36) "#C-events" ///
	 _col(48) "#events" _col(58) "Power" _n "{hline 10}{c +}{hline 10}{c +}{hline `hcol'}"
}
else {
	di as text _n %8s "`lperiod'" " {c |}    #pats" _col(26) "#C-events" ///
	 _col(38) "#events" _col(48) "Power" _n "{hline 9}{c +}{hline `hcol2'}"
}
if `startperiod'>0 {
	* Compute and store #pts recruited from 1 to `startperiod'
	local numearlypats 0
	local earlypts
	local i 1
	tokenize `pts'
	while `i'<=`startperiod' {
		local numearlypats=`numearlypats'+``i''
		local earlypts `earlypts' ``i''
		local ++i
	}
	* compute power and #events from `startperiod' to `recperiod'-1
	local finish=`recperiod'-1
	local nall `numearlypats'
	local morepts
	forvalues j=`startperiod'/`finish' {
		* Force sample size at end of recruitment to n if `n' given.
		if `n'>0 {
			local nuse=round(`nall'*`n'/`numpats', 1)
		}
		else local nuse `nall'
		if "`datestart'" != "" {
			// compute date of end this period
			local edate = `sdate' + `j' * `length`tunit'' - 1 // automatically truncates fractions of a day
		}
		if `nuse'>0 {
			qui artsurv, recrt(`j' 0, `earlypts' `morepts', 0 ) nperiod(`j') n(`nuse') `options'
			local events = r(events)	// total number of events
			local Events: word 1 of `r(Events)' // control arm (group 1) events
			// strip trailing comma
			local c = strpos("`Events'", ",")
			if `c' > 0 local Events = substr("`Events'", 1, `c' - 1)
			if "`datestart'" != "" {
				di as text %td `edate' " {c |} " %6.0f `j' "   {c |}" as res %8.0f `nuse' ///
				 _col(33) %8.0f `Events' _col(45) %8.0f `events' _col(57) %7.5f r(power)
			}
			else di as text %6.0f `j' "   {c |}"  as res %8.0f `nuse' ///
			 _col(23) %8.0f `Events' _col(35) %8.0f `events' _col(47) %7.5f r(power)
			if `"`using'"'!="" {
				if "`datestart'" != "" post `tmp' (`edate') (`j') (`nuse') (`Events') (`events') (r(power))
				else post `tmp' (`j') (`nuse') (`Events') (`events') (r(power))
			}
		}
		else {
			if "`datestart'" != "" di as text %td `edate' " {c |} " %6.0f `j' "   {c |} (no patients)"
			else di as text %6.0f `j' "   {c |} (no patients)"
			if `"`using'"'!="" {
				if "`datestart'" != "" post `tmp' (`edate') (`j') (`nuse') (.) (.) (.)
				else post `tmp' (`j') (`nuse') (.) (.) (.)
			}
		}
		local i=`j'+1
		local pt: word `i' of `pts'
		local nall=`nall'+`pt'
		local morepts `morepts' `pt'
	}
	if `finish' >= `startperiod' {
		if "`datestart'" != "" di as text "{hline 10}{c +}{hline 10}{c +}{hline `hcol'}"
		else di as text "{hline 9}{c +}{hline `hcol2'}"
	}
}
* compute power and #events from `recperiod' to `recperiod'+`eperiods'
local accwt
local nperiod `recperiod'
local rperiod `recperiod'
local nall `numpats'
local i 0
local morepts
forvalues j=`recperiod'/`endperiod' {
	if `n'>0 {
		local nuse=round(`nall'*`n'/`numpats', 1)
	}
	else local nuse `nall'
	if "`datestart'" != "" {
		// compute date of end this period
		local edate = `sdate' + `j' * `length`tunit'' - 1
	}
	if `nuse'>0 {
		qui artsurv, recrt(`rperiod' 0, `pts' `morepts', 0 ) nperiod(`nperiod') n(`nuse') `options'
		local events = r(events)
		local Events: word 1 of `r(Events)' // control arm (group 1) events
		local c = strpos("`Events'", ",")
		if `c' > 0 local Events = substr("`Events'", 1, `c' - 1)
		if "`datestart'" != "" {
			di as text %td `edate' " {c |} " %6.0f `nperiod' "   {c |}" as res %8.0f `nuse' ///
			 _col(33) %8.0f `Events' _col(45) %8.0f `events' _col(57) %7.5f r(power)
		}
		else di as text %6.0f `nperiod' "   {c |}" as res %8.0f `nuse' ///
		 _col(23) %8.0f `Events' _col(35) %8.0f `events' _col(47) %7.5f r(power)
		if `"`using'"'!="" {
			if "`datestart'" != "" post `tmp' (`edate') (`nperiod') (`nuse') (`Events') (`events') (r(power))
			else post `tmp' (`nperiod') (`nuse') (`Events') (`events') (r(power))
		}
	}
	else {
		if "`datestart'" != "" di as text %td `edate' " {c |} " %6.0f `j' "   {c |} (no patients)"
		else di as text %6.0f `j' "   {c |} (no patients)"
		if `"`using'"'!="" {
			if "`datestart'" != "" post `tmp' (`edate') (`j') (`nuse') (.) (.) (.)
			else post `tmp' (`j') (`nuse') (.) (.) (.)
		}
	}
	if `j'==`recperiod' {
		if "`datestart'" != "" di as text "{hline 10}{c +}{hline 10}{c +}{hline `hcol'}"
		else di as text "{hline 9}{c +}{hline `hcol2'}"
	}
	local ++nperiod
	if `nperiod'<=`stoprecruit' {
		* Patients continue to be recruited
		local ++rperiod
		local ++i
		local ept: word `i' of `epts'
		local nall=`nall'+`ept'
		local morepts `morepts' `ept'
	}
}
di
if `"`using'"'!="" {
	postclose `tmp'
	preserve
	use `"`using'"', replace
	if "`datestart'" != "" {
		label var date "date of end of period"
		format date %td
	}
	label var period "`lperiod' period"
	label var patients "Cumulative patients"
	label var ctrl_events "Cumulative control-arm events"
	label var tot_events "Cumulative total events"
	label var power "Power"
	save `"`using'"', replace
	restore
}
end
exit
History
1.0.4	05jul2013	Fixed mislabelling in using file.
					Improved names of variables stored in using file.
1.0.3	19oct2009	Added datestart() option.
					Upped version to 10.0.
					Updated help file.
					Output control arm and total events.
1.0.2	14oct2006	Push command line which includes "$S_ARTPEP" to the Review window.
					This expands $S_ARTPEP.
1.0.1	---------	Fixed wordcount() bug which was truncating some macros at 80 chars
