*! xtgraph.ado, Version 2.02
*! by PT Seed (paul.seed@kcl.ac.uk)

*! graphs of xt (cross-sectional time-series) data
*! Presents averages with error bars of a single variable, by time
*! data can be grouped.

* 14/4/2001 All major functions now seem to be working, ready for SUG
* Log & power transformations, model fitting, outputting data & graphs, 
 
* The only problem seems to be that the undeclared "show" does not 
* work with axis labels on the graph.

* -av(am)- now allowed as a synonym for -av(mean)-

* 19/6/2001 Add in error sd as an option following -model-

* version 2.02
* Include boxcox(#) option
* Correct a series of bugs:
* Half-bars facing the wrong way, 
* Missing values in string group variables,
* Spaces in temporary file names.

* To allow version 8.0 graphics


prog define xtgraph
version 8.0

preserve

 *****  parse the command ***************
	error 0
	syntax varlist(min=1 max=1 numeric) [if] [in]  , ///
[AVerage(string) bar(string) display ///
POWer(real 1) log(string) boxcox(real 1) model ///
i(string) t(string) GRoup(varlist max=1) Half ///
OFFset(real 0) show MINobs(real 1) level(real $S_level) ///
list savedat(string asis) by(string) listwise missing ///
baropts(string) lineopts(string) bartype(string) ///
L1title(string) Symbol(string) Connect(string) Weight(string) nograph v7 * ]

if "`display'" == ""  {
	local display = "*" 
}	

`display'"*****  ***** ***** ***** ***** ***** 

`display'"*****  Collect the I and T vars ***** 
	xt_iis `i'
	local ivar "`s(ivar)'"

	xt_tis `t'
	local tvar "`s(timevar)'"
`display'"*****  ***** ***** ***** ***** ***** 

`display'"*****  Handle the conditions *****

	local yvar "`varlist'"
	cap keep `if' `in'
	qui keep if `yvar' ~= . 
	cap keep if `group' ~= .
	cap keep if `group' ~= "." & `group' ~= ""

	tempvar n
	if `minobs' > 1 {
		qui egen `n' = count(`yvar'), by(`group' `by' `tvar') 
		cap keep if `n' >= `minobs'
		if _rc & "`1'" ~= ""  { 
			di in red "Invalid option minobs(" in ye"`minobs'" in red")"
			exit 198
		}
	drop `n'
	}

	if "`listwise'" ~= "" {
		qui egen `n' = count(`yvar'), by(`ivar') 
		summ `n' , meanonly
		keep if `n' == r(max)
	drop `n'
	}

	if "`missing'" == "" { 
		cap drop if `group' == . 
		cap drop if `group' == ""
		if "`by'" ~= "" {
			cap drop if `by' == .
			cap drop if `by' == ""
		}
	}


	qui egen `n' = count(`yvar'), by(`group' `by' `tvar')

	if "`saving'"  ~= "" {
		local graph = "" 
	}
***** ***** ***** ***** ***** ***** 

`display'"*****  Check the syntax ***** 


	if "`log'" ~= "" { 
		cap confirm number `log' 
		if _rc == 7 {
			di in red "Option log() must contain a number." 
			exit 198
		}
	}

	if "`log'" ~= "" & "`power'" ~= "1" {
		di in red "Options log() and power() canot be used together	
		exit 198
	}
	if "`log'" ~= "" & "`boxcox'" ~= "1" {
		di in red "Options log() and boxcox() canot be used together	
		exit 198
	}
	if "`boxcox'" ~= "1" & "`power'" ~= "1" {
		di in red "Options boxcox() and power() canot be used together	
		exit 198
	}

	if "`power'" == "0" | "`boxcox'" == "0" {
		local log = 0
		local power = 1
		local boxcox = 1
	}


	if "`average'" == "" |  "`average'" == "am" {
		local average = "mean" 
	}
	if ("`average'" == "gm" | "`average'" == "hm" ) & "`power'" ~= "1" {
		di in red "Option power() should not be used with average(`average')"
		exit 198
	}
	if ("`average'" == "gm" | "`average'" == "hm" ) & "`boxcox'" ~= "1" {
		di in red "Option boxcox() should not be used with average(`average')"
		exit 198
	}

	if "`average'" == "gm" | "`boxcox'" == "0" | "`power'" == "0" {
		local average "mean" 
		local power = 1
		local boxcox = 1
		local log = 0
	}

	if "`average'" == "hm" {
		local average "mean" 
		local power = -1
	}

	if "`bar'" == "" {
		local bar "ci" 
	}

	if "`average'" == "median" {
		if "`bar'" ~= "ci" & "`bar'" ~= "no" & "`bar'"~= "iqr" & "`bar'" ~= "rr" { 
			di in red "Option bar(`bar') invalid with average(`average')."
			exit 198
		}
	}

	if "`average'" == "mean" {
		if "`bar'" ~= "ci" & "`bar'" ~= "no" & "`bar'"~= "se" /*
		*/ & "`bar'"~= "sd" & "`bar'" ~= "rr" & "`bar'" ~= "error" { 
			di in red "Option bar(`bar') invalid with average(`average')."
			exit 198
		}
	}


	if "`group'" == "" {
		tempvar group
		qui gen `group' = 1
	}

	cap assert ~(( "`bar'" == "no") & ("`half'" == "half" ))
	if _rc { 
		di in gr "Note: There is no point in asking for half-bars if no bars are requested." 
		local half
	}


	if "`bartype'" == "" local bartype rcap

`display'"*****  Symbol ***** 

	tempvar gpno 
	sort `group'
	qui by `group' : gen `gpno' = _n == 1
	qui replace `gpno' = sum(`gpno')
	sort `gpno'
	local ngrp = `gpno'[_N]

	while length("`symbol'") < `ngrp' & `ngrp' ~= . { 
		local symbol "`symbol'OSTodp" 
	}
	local symbol = substr("`symbol'",1,`ngrp') 
	local symbol "`symbol'ii"


`display'"*****  Connect ***** 

	while length("`connect'") < `ngrp' { 
		local connect "`connect'l" 
	}
	local connect "`connect'II"

`display'"*****  Half ***** 

	if "`half'" ~= "" & `ngrp' ~= 2 {
		di in red "Half-bars are not appropriate with more than two groups."
		di in red "Perhaps you should use the offset()option."
		exit 198
	}

`display'"*****  Collect the Y and T labels ***** 

	local y_vrlab : var label `varlist'
	if "`y_vrlab'" == "" { 
		local y_vrlab = "`varlist'" 
	}
	local y_vllab : val label `varlist'

	local t_vrlab : var label `tvar'
	if "`t_vrlab'" == "" { 
		local t_vrlab = "`tvar'" 
	}
	local t_vllab : val label `tvar'
	

***** ***** ***** ***** ***** ***** 

`display'"*****  Carry out the transformations *****

	if "`power'" ~= "1" & "`model'" == "" { 
		qui replace `yvar' = `yvar'^`power' 
	}

	else if "`boxcox'" ~= "1" & "`model'" == "" { 
		qui replace `yvar' = (`yvar'^`boxcox'-1)/`boxcox' 
	}

	else if "`log'" ~= "" & "`model'" == "" { 
		cap assert `yvar' - `log' > 0 
		if _rc { 
			local ln_sign = "-" 
			cap assert -`yvar' - `log' > 0 
			if _rc {
				di in red "Non-positive values of `yvar' - `log' encountered." 
				exit _rc
			}
		}
		qui replace `yvar' = log(`ln_sign'1*`yvar'-`log')
	}
	
******************************************

`display'"*****  Calculate the averages and bars ***********

	tempvar av 
	if "`bar'" ~= "no" { 
		tempvar lb ub 
	}

`display'"*****  ***** ***** means ***** ***** ***** 
	if "`average'" == "mean" { 
		if "`model'" == "" { 
			qui egen `av' = `average'(`yvar'), by(`group' `by' `tvar') 
		}
		else { 
			cap predict `av' 
			if _rc { 
				di in red "The last model fitted cannot be detected."
				exit _rc
			}
		}

`display'"*****  ***** sd & rr ***** ***** 
		if "`bar'" == "sd" | "`bar'" == "rr" {
			tempvar sd 
			if "`model'" == "" { 
				qui egen `sd' = sd(`yvar'), by(`group' `by' `tvar') 
			}
			else { 
				cap predict `sd' , stdf 
				if _rc { 
					di in red "The last model fitted does not permit estimates of stdf,
					di in red "needed for standard deviation bars"
					exit _rc
				}
			}
			if "`bar'" == "sd" {
				qui gen `lb' = `av' - `sd'
				qui gen `ub' = `av' + `sd'
			}
			if "`bar'" == "rr" {
				qui gen `lb' = `av' - invnorm(.5+`level'/200)*`sd'
				qui gen `ub' = `av' + invnorm(.5+`level'/200)*`sd'
			}
		}

`display'"*****  ***** se & ci ***** ***** 

		if "`bar'" == "ci"  | "`bar'" == "se" {
 			tempvar se
			if "`model'" == "" {
				qui egen `se' = sd(`yvar'), by(`group' `by' `tvar') 
				qui replace `se' = `se'/`n'^.5
			}
			else { 
				qui predict `se', stdp  
				if _rc { 
					di in red "The last model fitted does not permit estimates of stdp,
					di in red "(the standard deviation of the forecast) needed for standard error bars"
					exit _rc
				}
			}

			if "`bar'" == "ci" {
				qui gen `lb' = `av' - (invttail(`n'-1,.5-`level'/200)*`se')
				qui gen `ub' = `av' + (invttail(`n'-1,.5-`level'/200)*`se')
			}
			if "`bar'" == "se"  {
				qui gen `lb' = `av' - `se'
				qui gen `ub' = `av' + `se'
			}
		}

`display'"*****  ***** error ***** ***** 
		if "`bar'" == "error" {
			local error = e(rmse)
			if "`error'" == "." { 
				di in red "The last model fitted does not give a root-mean square error."
				exit 198
			}
			qui gen `lb' = `av' - `error'
			qui gen `ub' = `av' + `error'
		}
	}
	***** ***** ***** ***** ***** ***** ***** 

`display'"*****  ***** ***** medians ***** ***** ***** 
	if "`average'" == "median" & "`bar'" == "ci" {
		qui gen `av' = .
		qui gen `lb' = .
		qui gen `ub' = .
		sort `group' `by' `tvar'
		tempvar gp_t
		qui by `group' `by' `tvar': gen `gp_t' = _n == 1
		qui replace `gp_t' = sum(`gp_t')
		local n_gp_t = `gp_t'[_N]
		local i = 1
		while `i' <= `n_gp_t' {
			qui centile `yvar' if `gp_t' == `i', level(`level')
			qui replace `av' = r(c_1) if `gp_t' == `i'
			qui replace `lb' = r(lb_1) if `gp_t' == `i'
			qui replace `ub' = r(ub_1) if `gp_t' == `i'
			local i = `i' + 1
		}
	}

	if "`average'" == "median" & "`bar'" == "iqr" {
		qui egen `av' = pctile(`yvar') , by(`group' `by' `tvar')
		qui egen `lb' = pctile(`yvar') , by(`group' `by' `tvar') p(25)
		qui egen `ub' = pctile(`yvar') , by(`group' `by' `tvar') p(75)
		}

	if "`average'" == "median" & "`bar'" == "rr" {
		local l_cent = 50-`level'/2
		local u_cent = 50+`level'/2
		qui egen `av' = pctile(`yvar') , by(`group' `by' `tvar')
		qui egen `lb' = pctile(`yvar') , by(`group' `by' `tvar') p(`l_cent')
		qui egen `ub' = pctile(`yvar') , by(`group' `by' `tvar') p(`u_cent')
	}
	if "`average'" == "median" & "`bar'" == "no" {
		qui egen `av' = pctile(`yvar') , by(`group' `by' `tvar')
	}

* Check that the model correctly predicts one value only per group.
	if "`model'" ~= "" {
		cap bys `group' `by' `tvar' (`av') : assert `av' == `av'[1] | `av' == .
		if _rc {
			di in red "The most recent model does not producer a single average for each group"
			di "as defined by `group' `by' `tvar'."
			exit _rc
		}
		cap bys `group' `by' `tvar' (`lb') : assert `lb' == `lb'[1] | `lb' == .
		if _rc & "`bar'" ~= "no "{
			di in red "The most recent model does not producer a single lower bound for each group"
			di "as defined by `group' `by' `tvar'."
			exit _rc
		}
		cap bys `group' `by' `tvar' (`ub') : assert `ub' == `ub'[1] | `ub' == .
		if _rc & "`bar'" ~= "no "{
			di in red "The most recent model does not producer a single upper bound for each group"
			di "as defined by `group' `by' `tvar'."
			exit _rc
		}


	}
	
	***** ***** ***** ***** ***** ***** 


`display'"*****  Carry out the back transformations *****
	if "`power'" ~= "1" & "`power'" ~= "0" { 
		qui replace `av' = `av'^(1/`power')
		if "`bar'" ~= "no" & `power' >=0 {

			qui replace `lb' = `lb'^(1/`power')
			qui replace `ub' = `ub'^(1/`power')
		}
		if "`bar'" ~= "no" & `power' <0 {
			tempvar lb_temp
			qui gen `lb_temp' = `ub'^(1/`power')
			qui replace `ub' = `lb'^(1/`power')
			qui replace `lb' = `lb_temp' 
		}
	}

	if "`boxcox'" ~= "1" & "`boxcox'" ~= "0" { 
		qui replace `av' = (`av'*`boxcox'+1)^(1/`boxcox')
		if "`bar'" ~= "no" & `boxcox' >=0 {

			qui replace `lb' = (`lb'*`boxcox'+1)^(1/`boxcox')
			qui replace `ub' = (`ub'*`boxcox'+1)^(1/`boxcox')
		}
		if "`bar'" ~= "no" & `boxcox' <0 {
			tempvar lb_temp
			qui gen `lb_temp' = (`ub'*`boxcox'+1)^(1/`boxcox')
			qui replace `ub' = (`lb'*`boxcox'+1)^(1/`boxcox')
			qui replace `lb' = `lb_temp' 
		}
	}

	if "`log'" ~= "" { 
		qui replace `av' = `ln_sign'1*(exp(`av')+`log')
		if "`bar'" ~= "no" {
			qui replace `lb' = `ln_sign'1*(exp(`lb')+`log')
			qui replace `ub' = `ln_sign'1*(exp(`ub')+`log')
		}
	}


***** ***** ***** ***** ***** 

`display'"*****  Offset the tvar *****

	tempvar t2
	if `offset' ~= 0 {
		qui tab `gpno', 
		qui gen `t2' = `tvar' + (`gpno'-(r(r)+1)/2)*`offset'
	}
	else {
		qui gen `t2' = `tvar' 
	}
	label var `t2' "`t_vrlab'"
	label val `t2' `t_vllab'
	
***** ***** ***** ***** ***** 

`display'"*****  Drop the extra variables & values *****

	sort `group' `by' `tvar'
	tempvar touse
	qui by `group' `by' `tvar' : gen `touse' = _n == 1 
	qui keep if `touse'

 	keep `ivar' `tvar' `n' `group' `gpno' `by' `yvar' `av' `avlist' `lb' `ub' `t2'
	if `group'[_N] == `group'[1] { 
		drop `group' 
		local group 	
	}
***** ***** ***** ***** ***** 

`display'"*****  Rename the variables ***** 
	cap rename `lb' lb
		if _rc == 0 { 
		local lb lb  
	}
	cap rename `ub' ub
		if _rc == 0 { 
			local ub ub  
		}
	cap rename `t2' t2
		if _rc == 0 { 
			local t2 t2 
		}
	cap rename `av' `average'
		if _rc == 0 { 
			local av `average'
		}
	cap noi rename `n' n
		if _rc == 0 { 
			local n n
		}
cap mac li _t2
cap desc `t2'
***** ***** ***** ***** ***** 

`display' "*****  Label the groups *****
	cap assert "`group'" ~= ""
	if _rc {
		local avlist "`av'"
		label var `avlist' "`y_vrlab'"
		local c "l"
	}

	else { 
		tempvar grp_num
		cap confirm numeric var `group'
		if _rc == 0 { 
			local grp_num "`group'" 
 		}
		else { 
			encode `group' , gen(`grp_num') 
		}
* grp_num is the numeric form of group.
		
		local i = 1
		while `i' <= `ngrp' {
			qui summ `grp_num' if `gpno' == `i', meanonly
			local gr_val = r(mean)
			local label  : label (`grp_num') `gr_val'
* First try to make name for average from label
			local name = lower(substr("`label'",1,8))
			while index("`name'", " ") {
				local l_name = substr("`name'", 1, index("`name'", " ")-1)
				local r_name = substr("`name'", index("`name'", " ")+1, .)
				local name "`l_name'_`r_name'"
			}
			cap confirm new var `name'
			while _rc { 
* Then try adding underscores
				local j = `j' + 1
				local name = "_" + substr("`name'",1,7)
				cap confirm new var `name'
				if `j' == 8 {
* Then try numbered groups
					local name "Group_`gr_val'"
				}
				if `j' == 10 {
* Then give up
					di in red "Problem giving meaningful names to all groups."
					di "No solution."
					exit 198
				}
			*End of [not] new var `name'
			}
`display' "*****  Rename the group average for group `i' *****
			qui gen `name' = `av' if `gpno' == `i'
			label var `name' "`label'"
			local avlist  "`avlist' `name'"
			local c "`c'l"
			local i = `i' + 1
		* End of consideration of name for group `i'
		}		
	* End of consideration of group names for multiple groups
	}
***** ***** ***** ***** ***** ***** 

`display'"*****  Label the Y axis ***** 
	if "`l1title'" == "" { 
		local l1title "`y_vrlab'"
	}
	local ytitle "ytitle(`l1title')"
	local l1title "l1(`l1title')"

`display'"*****  List the data *****

	if "`list'" ~= "" {
		if  "`average'" == "mean" {
			if "`log'" == "0" { 
				local av_type "Geometric mean" 
			}
			else if `power' == -1 { 
				local av_type "Harmonic mean" 
			}
			else if "`power'" ~= "1" { 
				local av_type = "Transformed mean [x^`power']" 
			}
			else if "`boxcox'" ~= "1" { 
				local av_type = "Box-Cox transformed mean [x^`power']" 
			}
			else if "`log'" ~= "" { 
				local av_type = "Transformend mean [log(x -`log')]" 
			} 
			else { 
				local av_type "Arithmetic mean" 
			}
		}
		else local av_type = "`average'"
	
		di _n "`av_type' of `varlist' " _c

		if "`bar'" == "ci" |  "`bar'" == "rr" { 
			local l = "`level'% " 
		}
		if "`bar'" ~= "no" {
			local up_bar = upper("`bar'")
			di "with bars based on `l'`up_bar'"
		}
		if "`group'" ~= "" & "`by'" == "" { 
			di "by `group' and `tvar'." 
		}
		else if "`group'" ~= "" & "`by'" ~= "" { 
			di "by `group', `by' and `tvar'." 
		}
		else if "`group'" == "" & "`by'" ~= "" { 
			di "by `by' and `tvar'." 
		}
		else di "by `tvar'."
		if "`group'" ~= "" | "`by'" ~= "" { 
			sort `group' `by' 
			by `group' `by' : list `tvar' `n' `av' `lb' `ub' , noobs 
		}
		else  { 
			list `tvar' `n' `av' `lb' `ub' , noobs 
		}
	}
***** ***** ***** ***** ***** 

`display'"*****  Weight the points ***** 


	if "`weight'" ~= "" { 
		if "`weight'" === "n" { 
			local wtvar "`n'"
		}
		else if "`weight'" == "bar" { 
			tempvar wtvar
			qui gen wtvar = `ub' - `lb'
		}
		else local wtvar = `weight'
		local weight "[fw=`wtvar']"
	}
	

`display'"*****  Save the data ***** 
	cap mac li _savedat
	if _rc == 0 {
		tempfile temp
		qui save "`temp'"
		keep `group' `by' `tvar' `n' `av' `lb' `ub' `wtvar'
		cap noi save `savedat'
		if _rc {	
			di in ye "Make sure that you have put quotation marks round the temporary file name." 
		}
		qui use "`temp'", replace
	}
***** ***** ***** ***** ***** 

`display'"*****  Handle the half-bars ***** 

	if "`half'" ~= "" { 
		tempvar lbs ubs
		qui gen str1 `lbs' = ""
		qui gen str1 `ubs' = ""
		sort `by' `tvar' `av' `group' 
		qui by `by' `tvar' : replace `lb' = `av' if `group' ==  `group'[_N]
		qui by `by' `tvar' : replace `ub' = `av' if `group' ==  `group'[1]

}
***** ***** ***** ***** ***** 


`display'"*****  Sort the data *****
	sort `by' `group' `t2' 

***** ***** ***** ***** ***** 

`display'"*****  Draw the graph *****
* set trace on

	if "`v7'" ~= "" {
		if "`by'" ~= "" { 
				local by "by(`by')" 
		}
		if "`show'" ~= "" {
			cap noi di in wh "version 7: graph `avlist' `lb' `ub' `t2' `weight', connect(`connect') symbol(`symbol') `xlab' `ylab' `by' `options' `saving' "
		}

		if "`graph'" == "" {
			version 7: graph `avlist' `lb' `ub' `t2' `weight', connect(`connect') symbol(`symbol') `xlab' `ylab' `l1title' `by' `saving' `options'
		}
	}

	else  {

		if "`show'" ~= "" {
                	 di "twoway line `avlist' `t2', `lineopts' `ytitle' || `bartype' `lb' `ub' `t2' , `baropts'
		}
		if "`graph'" == "" {
                	 twoway line `avlist' `t2', `lineopts' `ytitle'  || `bartype' `lb' `ub' `t2' , `baropts'
		}
	}


*************************************


end xtgraph

*************************************
*************************************
*************************************


* version 2.2.0  01jul1999
program define centile, rclass
	version 6
	syntax [varlist] [if] [in] [, CCi /*
		*/ Centile(numlist >=0 <=100) /*
		*/ Level(real $S_level) Meansd Normal display]
	
if "`display'" == ""  {
	local display = "*" 
}	
	

	tempvar touse notuse
	mark `touse' `if' `in'
	qui gen byte `notuse' = .  /* will be reset for each variable */

	if "`centile'"=="" { 
		local centile 50 
	}
/*
	Parse `centile' and count the requested centiles, placing them
	into c1, c2, ....
*/
	local nc 0
	tokenize "`centile'"
	while "`1'" != "" {
		local nc = `nc' + 1
		local c`nc' `1'
		local cents "`cents' `1'" /* to return in r() */
		mac shift
	}

	local tl1 "    Obs "
	local ttl "Percentile"
	if "`meansd'"=="" { 
		if "`normal'"=="" { 
			if "`cci'"~="" {
				di in gr _n _col(52) "-- Binomial Exact --"
			}
			else {
				di in gr _n _col(52) "-- Binom. Interp. --"
			}
		}
		else {
			di in gr _n _col(32) /*
			*/ "-- Normal, based on observed centiles --"
		}
	}
	else {
		di in gr _n _col(32) "-- Normal, based on mean and std. dev.--"
	}
	#delimit ;
	di in gr 
	"Variable | `tl1' `ttl'      Centile        [`level'% Conf. Interval]" 
	_n "---------+" _dup(61) "-" ;
	#delimit cr

	local anymark 0
	local alpha2 = (100-`level')/200
	local zalpha2 = -invnorm(`alpha2')
/*
	Run through varlist
*/
	tokenize `varlist'
	local vl
	while "`1'" != "" {
		capt conf str var `1'
		if _rc { 
			local vl "`vl' `1'"
		}
		mac shift 
	}

	local nobs 0			/* in case loop aborted */
	tokenize `vl'
	while "`1'" ~= "" {
		local yvar "`1'"

		/* notuse: 0 = use, 1 = not use -- sort will put use first */
		qui replace `notuse' = ~`touse'
		qui replace `notuse' = 1 if `yvar'==.
		sort `notuse' `yvar'

		qui sum `yvar' if ~`notuse'
		local nobs = r(N)
		local mean = r(mean)
		local sd = sqrt(r(Var))
/*
	Formatting
*/
		local skip = 8 - length("`yvar'")
		local fmt : format `yvar'
		if substr("`fmt'",-1,1)=="f" { 
			local ofmt="%9."+substr("`fmt'",-2,2)
		}
		else if substr("`fmt'",-2,2)=="fc" {
			local ofmt = "%9." + substr("`fmt'",-3,3)
		}
		else	local ofmt "%9.0g"
/*
	Calc required centile(s)
*/
		local j 1
		local s 7
		while `j' <= `nc' {
			local mark ""
			local cj "c`j'"
			local quant = ``cj''/100
			if "`meansd'" ~= "" & (`nobs' > 0) {
			/*
				Normal distribution (parametric estimates)
			*/
				local z = invnorm(`quant')
				local centil = `mean'+`z'*`sd'
				local se = `sd'*sqrt(1/`nobs'+(`z')^2/(2*(`nobs'-1)))
				local cLOWER = `centil'-`zalpha2'*`se'
				local cUPPER = `centil'+`zalpha2'*`se'
			}
			else if `nobs' > 0 {
/*
	If `normal' is not set, calc centile and exact nonparametric confidence
	limits (for example, see Gardner and Altman 1989, pp 72-74),
	interpolating when not at ends of distribution.  An iterative process
	is required for each limit.  As starting values, find ranks for lower
	and upper limits using a normal approximation.

	If `normal' is set, use normal distribution formula for variance, 
	(10.29) in Kendall & Stuart (1969) p 237.

	`alpha2' is for example .025 for a 95% CI.
*/
				local frac1 = (`nobs'+1)*`quant'
`display'"Central fraction and rank = " `quant',`frac1'
				local i1 = int(`frac1')
				local frac1 = `frac1'-`i1'
				if `i1' >= `nobs' {
					local centil = `yvar'[`nobs']
				}
				else if `i1' < 1 {
					local centil = `yvar'[1]
				}
				else {
					local centil = `yvar'[`i1']+ /*
					*/ `frac1'*(`yvar'[`i1'+1]-`yvar'[`i1'])
				}
				if "`normal'" == "" {
					local nq = `nobs'*`quant'
					local z = sqrt(`nq'*(1-`quant'))*`zalpha2'
					local rzLOW = int(.5+`nq'-`z')
					local rzHIGH = 1+int(.5+`nq'+`z')
`display'"lower and upper approx ranks = " `rzLOW',`rzHIGH'
					local r1 `rzHIGH'
					if `r1' > `nobs'+1 { 
						local r1 = `nobs'+1
					}
					local r0 = `r1'-1
					local p0 = Binomial(`nobs',`r0',`quant')
					local p1 = Binomial(`nobs',`r1',`quant')
					local done 0
					while ~`done' {
						if `p0' > `alpha2' {
							if `p1' <= `alpha2' {
								local done 1
							}
							else {
								local r0 = `r1'
								local p0 = `p1'
								local r1 = `r1'+1
								local p1 = Binomial(`nobs',`r1',`quant')
							}
						}
						else if `p0' == `alpha2' {
							local r1 = `r0'
							local p1 = `p0'
							local done 1
						}
						else {
							local r1 = `r0'
							local p1 = `p0'
							local r0 = `r0'-1
							local p0 = Binomial(`nobs',`r0',`quant')
						}
					}
`display'"Upper r0, p0, r1, p1, interp =" `r0',`p0',`r1',`p1',(`p0'-`alpha2')/(`p0'-`p1')
/*
	Upper limit. Interpolate between r0 and r1, r1 being
	conservative. Note that p0>=p1 (upper tail areas).
*/
					if `r0' >= `nobs' {
						local cUPPER = `yvar'[`nobs']
						local mark "*"
						local anymark 1
					}
					else if `r0' < 1 {
						local cUPPER = `yvar'[1]
						local mark "*"
						local anymark 1
					}
					else {
						if "`cci'" == "" {
							local cUPPER = `yvar'[`r0']		/*
							*/	+((`p0'-`alpha2')/(`p0'-`p1'))	/*
							*/	*(`yvar'[`r1']-`yvar'[`r0'])
						}
						else {
							local cUPPER = `yvar'[`r1']
						}
					}
					local r1 `rzLOW'
					if `r1' < 0 { 
						local r1 0 
					}
					local r0 = `r1'-1
					local p0 = 1-Binomial(`nobs',`r0'+1,`quant')
					local p1 = 1-Binomial(`nobs',`r1'+1,`quant')
					local done 0
					while ~`done' {
						if `p1' > `alpha2' {
							if `p0' <= `alpha2' {
								local done 1
							}
							else {
								local r1 = `r0'
								local p1 = `p0'
								local r0 = `r0'-1
								local p0 = 1-Binomial(`nobs',`r0'+1,`quant')
							}
						}
						else if `p0' == `alpha2' {
							local r0 = `r1'
							local p0 = `p1'
							local done 1
						}
						else {
							local r0 = `r1'
							local p0 = `p1'
							local r1 = `r1'+1
							local p1 = 1-Binomial(`nobs',`r1'+1,`quant')
						}
					}
/*
	Interpolate between r1 and r1+1, r1 being conservative.
	Note that p0<=p1 (both are lower tail areas).
*/
					if `r1' >= `nobs' {
						local cLOWER = `yvar'[`nobs']
						local mark "*"
						local anymark 1
					}
					else if `r1' < 1 {
						local cLOWER = `yvar'[1]
						local mark "*"
						local anymark 1
					}
					else {
						if "`cci'" == "" {
							local cLOWER = `yvar'[`r1'] /*
							*/ +((`alpha2'-`p0')/(`p1'-`p0')) /*
							*/ *(`yvar'[`r1'+1]-`yvar'[`r1'])
						}
						else {
							local cLOWER = `yvar'[`r1']
						}
					}
`display'"Lower r0, p0, r1, p1, interp =" `r0',`p0',`r1',`p1',(`alpha2'-`p0')/(`p1'-`p0')
`display'"Var = `yvar', centile `cj'=" `centil' ", CI = " `cLOWER',`cUPPER'
				}
				else {
/*
	Normal distribution, observed centiles
*/
					local dens = exp(-0.5*((`centil'-`mean')/`sd')^2)/(`sd'*sqrt(2*_pi))
					local se = sqrt(`quant'*(1-`quant')/`nobs')/`dens'
					local cLOWER = `centil'-`zalpha2'*`se'
					local cUPPER = `centil'+`zalpha2'*`se'
				}
			}

			if (`j' == 1) & (`nobs' > 0)  {
				di in gr _skip(`skip') "`yvar' |" _col(10) /*
				*/ in yel %8.0f `nobs'		/*
		 		*/ _col(23) %7.0g ``cj''	/*
		 		*/ _col(35) `ofmt' `centil'	/*
		 		*/ _col(51) `ofmt' `cLOWER'	/*
		 		*/ _col(63) `ofmt' `cUPPER' in gr "`mark'"
			}
			else if `nobs' > 0 {
				di in gr "         |"		/*
		 		*/ in yel _col(23) %7.0g ``cj''	/*
		 		*/ _col(35) `ofmt' `centil'	/*
		 		*/ _col(51) `ofmt' `cLOWER'	/*
		 		*/ _col(63) `ofmt' `cUPPER' in gr "`mark'"
			}
			else {  /* `nobs' == 0 */
				if (`j' == 1) {
					di in gr _skip(`skip') "`yvar' |" /*
					*/ _col(10) in yel %8.0f `nobs'
				}
				local centil .
				local cLOWER .
				local cUPPER .
			}
/*
	Store centile in S_# macros, starting at 7.
	Store centiles also in r(c_#) where # starts at 1.
	Store lower and upper bounds on centiles in r(lb_#) and r(ub_#)
*/
			local tmp = `s' - 6
			ret scalar c_`tmp' = `centil'    /* save in r() */
			global S_`s' `centil'      /* also save in S_# */
			/* save confidence limits also in r(), but not S_# */
			ret scalar lb_`tmp' = `cLOWER'
			ret scalar ub_`tmp' = `cUPPER'
			local j = `j'+1
			local s = `s'+1
		}
		mac shift
	}
	if "`anymark'" == "1" {
		di in gr _n /*
*/ "`mark' Lower (upper) confidence limit held at minimum (maximum) of sample"
	}
/*
	Store quantities at final point; S_4 is duplicate of S_[`nc'+6].
*/
	ret scalar N = `nobs'
	ret scalar n_cent = `nc'
	ret local centiles `cents'

	/* double save in S_# */
	global S_1 `nobs'
	global S_2 `nc'
	global S_3 ``cj''
	global S_4 `centil'
	global S_5 `cLOWER'
	global S_6 `cUPPER'
end 


exit

