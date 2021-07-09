
* *************************************************************
* incomecdf.ado
* Written by Sean Higgins, shiggins@tulane.edu
* Last revised Jan 7, 2013
* For usage, see Lustig and Higgins (2012) http://goo.gl/HnB4Q
* *************************************************************

capture program drop incomecdf
program define incomecdf
	*! version 1.0.3, shiggins@tulane.edu
	* changes since version 1.0.0: 
		* 08-22-2015 fixed error that I hadn't defined local die
		* 07-18-2015 fixed PPP conversion, adding CPISurvey and CPIBase options
		* sometime in 2013: added requirement that PPP option comes with one of daily monthly yearly
	capture version 10.0
	#delimit ;
	syntax varlist(numeric) 
		[if] [in] [pweight aweight fweight iweight/] 
		[, Ppp(real -1) 
		   CPISurvey(real -1)
		   CPIBase(real -1) 
		   Yearly 
		   Monthly 
		   Daily 
		   ALreadyppp
		   Ytitle(string) 
		   Xtitle(string) 
		   TITLE(string)
		   SUBtitle(string) 
		   COLors(string) 
		   LEGend(string) 
		   Lwidth(string) 
		   NOdraw
		]
	;
	#delimit cr
	
	* LOCALS 
	local die noisily display in smcl as error
	local dit noisily display in smcl as text
	
	preserve
	marksample touse
	quietly drop if `touse'==0
	if (min(`ppp',`cpisurvey',`cpibase')==-1) & "`alreadyppp'"=="" {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options;" _n ///
			"If already converted to PPP per day, specify {bf:alreadyppp} option"
		exit 198
	}
	if wordcount( "`daily' `monthly' `yearly'" ) > 1 {
		display as error "Cannot select more than one option from: daily, monthly, yearly"
		exit
	}
	if wordcount( "`daily' `monthly' `yearly'" )==0 & "`alreadyppp'"=="" {
		display as error "Daily, monthly, or yearly income must be specified"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	if "`ytitle'"=="" {
		local ytitle ytitle("Cumulative percent of the population")
		}
	else {
		local ytitle ytitle(`ytitle')
		}
	if "`xtitle'"=="" {
		local xtitle xtitle("Income in $ PPP per day")
		}
	else {
		local xtitle xtitle(`xtitle')
		}
	if "`title'"!="" {
		local title title(`title')
		}
	if "`subtitle"!="" {
		local subtitle subtitle(`subtitle')
		}
	if "`legend'"!="" {
		local legend legend(`legend')
		}
	if "`lwidth'"=="" {
		local lwidth "thin"
		}
	if "`lwidth'"!="vvthin" & "`lwidth'"!="vthin" & "`lwidth'"!="thin" & "`lwidth'"!="medthin" & "`lwidth'"!="medium" ///
		& "`lwidth'"!="medthick" & "`lwidth'"!="thick" & "`lwidth'"!="vthick" & "`lwidth'"!="vvthick" & "`lwidth'"!="vvvthick" {
		display as error "Invalid line width; type help linewidthstyle to see options"
		exit
		}
		
	local xbounds 250 400 1000 5000 10000	
	local p250 "1.25 2.5"
	local p400 "1.25 2.5 4"
	local p1000 "1.25 2.5 4 10"
	local p5000 "2.5 4 10 50"
	local p10000 "4 10 50 100"
	tokenize "`colors'"
	local i=1

	if "`exp'"!="" {
		local aw "[aw = `exp']"
		local pw "[pw = `exp']"
	}
	
	foreach var in `varlist' {
		tempvar cum_`var' 
		tempvar ppp_`var'
		if "`alreadyppp'"=="" qui gen `ppp_`var'' = (`var'/`divideby')*(`cpibase'/`cpisurvey')*(1/`ppp')
		else qui gen `ppp_`var'' = `var' // alreadyppp specified
 		cumul `ppp_`var'' `aw', gen(`cum_`var'')
		quietly replace `cum_`var'' = 100*`cum_`var''
		foreach x in `xbounds' {
			local j = `x'/100
			if "``i''"!="" {
				local glist_`x' "`glist_`x'' (line `cum_`var'' `ppp_`var'' if `ppp_`var''<`j' `aw', sort clwidth(`lwidth') clcolor(``i''))"
				}
			else {
				local glist_`x' "`glist_`x'' (line `cum_`var'' `ppp_`var'' if `ppp_`var''<`j' `aw', sort clwidth(`lwidth'))"
				}
			}
		local vlab`var' : var label `var'
		if "`vlab`var''" == "" {
			local vlab`var' `var'
			}
		label var `cum_`var'' `"`vlab`var''"'
		qui di "
		local i=`i'+1
		} // end varlist loop
	foreach x in `xbounds' { 
		local j = `x'/100
		quietly twoway `glist_`x'', ///
			xlabel(0 `p`x'') ///
			xline(`p`x'', lcolor(gs7) lpattern(shortdash) lwidth(medthin)) ///
			`ytitle' `xtitle' `title' `subtitle' `legend' saving(CDF`x', replace) `nodraw'
		display as text ""
		display as text "CDF graph for $0 to $`j' PPP per day saved as CDF`x'.gph"
		display as text "To view it, type: {stata graph use CDF`x'.gph}"
		}
	restore	
end
	
