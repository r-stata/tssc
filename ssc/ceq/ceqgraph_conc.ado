** Subcommand of ceqgraph
** See ceqgraph.ado for version and notes

**************************
** PRELIMINARY PROGRAMS **
**************************
// BEGIN returncol (Higgins 2015) 
//  Returns Excel column corresponding to a number
cap program drop returncol
program define returncol, rclass
	confirm integer number `1'
	mata: st_strscalar("col",numtobase26(`1'))
	return local col = col
end // END returncol

***************************
** ceqgraph_conc PROGRAM **
***************************
** For sheet E1. Descriptive Statistics
// BEGIN ceqgraph_conc (Higgins 2015)
capture program drop ceqgraph_conc
capture program define ceqgraph_conc, rclass 
	#delimit ;
	syntax 
		[using/]
		[if] [in] [pweight/] 
		[, 
			/** INCOME CONCEPTS: **/
			Market(varname)
			Mpluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			/** FISCAL INTERVENTIONS: **/
			Pensions   (varlist)
			DTRansfers (varlist)
			DTAXes     (varlist) 
			CONTribs   (varlist)
			SUbsidies  (varlist)
			INDTAXes   (varlist)
			HEALTH     (varlist)
			EDUCation  (varlist)
			OTHERpublic(varlist)
			USERFEESHealth(varlist)
			USERFEESEduc(varlist)
			USERFEESOther(varlist)
			/** PPP CONVERSION
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily **/
			/** SURVEY INFORMATION **/
			HHid(varname)
			HSize(varname) 
			PSU(varname) 
			Strata(varname) 
			/** INFORMATION CELLS **/
			COUNtry(string)
			SURVeyyear(string) /** string because could be range of years **/
			AUTHors(string)
			SCENario(string)
			GROUp(string)
			PROJect(string)
			/** SPECIFIC TO THIS ADO FILE: */
			scheme(string)
			path(string)
			graphname(string)
			/** EXPORTING TO CEQ MASTER WORKBOOK: */
			sheet(string)
			OPEN
			/** IGNORE MISSING OPTION */
			IGNOREMissing
			/** additional options (for graphing flexibility) */
			*
		]
	;
	#delimit cr
	
	************
	** LOCALS **
	************
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqgraph_conc
	local version 2.3

	** income concepts
	local m `market'
	local mp `mpluspensions'
	local n `netmarket'
	local g `gross'
	local t `taxable'
	local d `disposable'
	local c `consumable'
	local f `final'
	local alllist m mp n g t d c f
	local incomes = wordcount("`alllist'")
	local origlist m mp n g d
	tokenize `alllist' // so `1' contains m; to get the variable you have to do ``1''
	local varlist ""
	local counter = 1
	foreach y of local alllist {
		local varlist `varlist' ``y'' // so varlist has the variable names
		// reverse tokenize:
		local _`y' = `counter' // so _m = 1, _mp = 2 (regardless of whether these options included)
		local ++counter
	}

	scalar _d_m      = "Market Income"
	scalar _d_mp     = "Market Income + Pensions"
	scalar _d_n      = "Net Market Income"
	scalar _d_g      = "Gross Income"
	scalar _d_t      = "Taxable Income"
	scalar _d_d      = "Disposable Income"
	scalar _d_c      = "Consumable Income"
	scalar _d_f      = "Final Income"
	
	*************************
	** PRESERVE AND MODIFY **
	*************************
	  
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in'
	
	** make sure all newly generated variables are in double format
	set type double 
	
	** transfer and tax categories
	local taxlist dtaxes contribs indtaxes
	local transferlist pensions dtransfers subsidies health education otherpublic
	local programlist  pensions dtransfers dtaxes contribs subsidies indtaxes health education otherpublic userfeeshealth userfeeseduc userfeesother /* nethealth neteducation netother */
	foreach x of local programlist {
		local allprogs `allprogs' ``x'' // so allprogs has the actual variable names
	}
	
	** weight (if they specified hhsize*hhweight type of thing)  // previously under *parse options*, moved up to realize the keep var function
	if strpos("`exp'","*")> 0 { // TBD: what if they premultiplied w by hsize?
		`die' "Please use the household weight in {weight}; this will automatically be multiplied by the size of household given by {bf:hsize}"
		exit
	}
	
	** hsize and hhid    
	if wordcount("`hsize' `hhid'")!=1 {
		`die' "Must exclusively specify {bf:hsize} (number of household members for household-level data) or "
		`die' "{bf:hhid} (unique household identifier for individual-level data)"
		exit 198
	}
	
	*************************
	** PRESERVE AND MODIFY **
	*************************
	
	** collapse to hh-level data // previously under *preserve and modify*, moved up to realize the keep relevant variable function
	if "`hsize'"=="" { // i.e., it is individual-level data
		tempvar members
		sort `hhid', stable
		qui by `hhid': gen `members' = _N // # members in hh 
		qui by `hhid': drop if _n>1 // faster than duplicates drop
		local hsize `members'
	}
	
	** print warning messages 
	local warning "Warnings"
	
	** Check if all income and fisc variables are in double format
	local inctypewarn
	foreach var of local varlist {
		if "`var'"!="" {
			local vartype: type `var'
			if "`vartype'"!="double" {
				if wordcount("`inctypewarn'")>0 local inctypewarn `inctypewarn', `var'
				else local inctypewarn `var'
			}
		}
	}
	if wordcount("`inctypewarn'")>0 `dit' "Warning: Income variable(s) `inctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	if wordcount("`inctypewarn'")>0 local warning `warning' "Warning: Income variable(s) `inctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	
	local fisctypewarn
	foreach var of local allprogs {
		if "`var'"!="" {
			local vartype: type `var'
			if "`vartype'"!="double" {
				if wordcount("`fisctypewarn'")>0 local fisctypewarn `fisctypewarn', `var'
				else local fisctypewarn `var'
			}
		}
	}
	if wordcount("`fisctypewarn'")>0 `dit' "Warning: Fiscal intervention variable(s) `fisctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	if wordcount("`fisctypewarn'")>0 local warning `warning' "Warning: Fiscal intervention variable(s) `fisctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	
	************************
	** SVYSET AND WEIGHTS **
	************************ 
	cap svydes
	scalar no_svydes = _rc
	if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
		local warning `warning' "Warning: weights not specified in svydes or the command. Hence, equal weights (simple random sample) assumed."
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen double `weightvar' = `w'*`hsize'  
			local w `weightvar'
		}
		else local w "`hsize'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}
	else if "`r(su1)'"=="" & "`psu'"=="" {
		di as text "Warning: primary sampling unit not specified in svydes or the `command' command's psu() option"
		di as text "P-values will be incorrect if sample was stratified"
		local warning `warning' "Warning: primary sampling unit not specified in svydes or the `command' command's psu() option. P-values will be incorrect if sample was stratified."
	}
	if "`psu'"=="" & "`r(su1)'"!="" {
		local psu `r(su1)'
	}
	if "`strata'"=="" & "`r(strata1)'"!="" {
		local strata `r(strata1)'
	}
	if "`strata'"!="" {
		local opt strata(`strata')
	}
	** now set it:
	if "`exp'"!="" qui svyset `psu' `pw', `opt'
	else           qui svyset `psu', `opt'
	
	**************************
	** VARIABLE MODIFICATION *
	**************************
	
	** keep the variables used in ceqgraph_conc   

	#delimit ;
	local relevar `varlist' `allprogs'      
				  `w' `psu' `strata' 	  
	;
	#delimit cr
	quietly keep `relevar' 
	
	** missing income concepts
	foreach var of local varlist {
		qui count if missing(`var')  
		if "`ignoremissing'"=="" {
			if r(N) {
				`die' "Missing values not allowed; `r(N)' missing values of `var' found" 
				exit 198
			}
		}
		else {
			if r(N) {
				qui drop if missing(`var')
				`dit' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified {bf:ignoremissing}"
				local warning `warning' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified the ignoremissing option."
			}
		}
    }
	** missing fiscal interventions 
	foreach var of local allprogs {
		qui count if missing(`var') 
		if "`ignoremissing'"=="" {
			if r(N) {
				`die' "Missing values not allowed; `r(N)' missing values of `var' found"
				`die' "For households that did not receive/pay the tax/transfer, assign 0"
				exit 198
			}
		}
		else {
			if r(N) {
				qui drop if missing(`var')
				`dit' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified {bf:ignoremissing}"
				local warning `warning' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified the ignoremissing option."
			}
		}
    } 
	
	
	** columns including disaggregated components and broader categories 
	local broadcats dtransfersp dtaxescontribs inkind userfees /*netinkind*/ alltaxes alltaxescontribs alltransfers alltransfersp
	local dtransfersp `pensions' `dtransfers' 
	local dtaxescontribs `dtaxes' `contribs'
	local inkind `health' `education' `otherpublic' // these contain the variables, or blank if not specified
	local userfees `userfeeshealth' `userfeeseduc' `userfeesother'
	/*local netinkind `nethealth' `neteducation' `netother'*/
	local alltransfers `dtransfers' `subsidies' `inkind' /* `userfees' */
	local alltransfersp `pensions' `dtransfers' `subsidies' `inkind' /* `userfees' */
	local alltaxes `dtaxes' `indtaxes' 
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'
	
	foreach cat of local programlist {
		if "``cat''"!="" {
			tempvar v_`cat'
			qui gen `v_`cat''=0
			foreach x of local `cat' {
				qui replace `v_`cat'' = `v_`cat'' + `x' // so e.g. v_dtaxes will be sum of all vars given in dtaxes() option
			}
				// so suppose there are two direct taxes dtr1, dtr2 and two direct taxes dtax1, dtax2
				// then `programcols' will be dtr1 dtr2 dtransfers dtax1 dtax2 dtaxes
		}	
	}
	foreach bc of local broadcats {
		if wordcount("``bc''")>0 { // i.e. if any of the options were specified; for bc=inkind this says if any options health education or otherpublic were specified
			tempvar v_`bc'
			qui gen `v_`bc'' = 0
			foreach var of local `bc' { // each element will be blank if not specified
				qui replace `v_`bc'' = `v_`bc'' + `var'
			}
		}
	}	

	#delimit ;
	local direct_transfers_cols
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
	;
	local direct_taxes_cols
		`dtaxes' `contribs' `v_dtaxes' `v_contribs' `v_dtaxescontribs'
	;
	local indirect_subsidies_cols 
		`subsidies' `v_subsidies' 
	;
	local indirect_taxes_cols
		`indtaxes' `v_indtaxes'
	;
	local inkind_cols
		`health' `v_health' `education' `v_education' `otherpublic' `v_otherpublic' `v_inkind'
		`userfeeshealth' `v_userfeeshealth' `userfeeseduc' `v_userfeeseduc' `userfeesother' `v_userfeesother' `v_userfees' 
		/*`nethealth' `neteducation'  `netother' `v_netinkind'*/
	;
	local summary_cols
		`v_dtransfers' `v_dtransfersp' 
		`v_dtaxescontribs' 
		`v_subsidies' `v_indtaxes'
		`v_alltransfers' `v_alltransfersp'
	;
	local list_of_cols 
		direct_transfers_cols
		direct_taxes_cols
		indirect_subsidies_cols
		indirect_taxes_cols
		inkind_cols
		summary_cols 
	;
	local programcols 
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
		`dtaxes' `contribs' `v_dtaxes' `v_contribs' `v_dtaxescontribs'
		`subsidies' `v_subsidies' `indtaxes' `v_indtaxes'
		`v_alltaxes' `v_alltaxescontribs'
		`health' `v_health' `education' `v_education' `otherpublic' `v_otherpublic' `v_inkind'
		`userfeeshealth' `v_userfeeshealth' `userfeeseduc' `v_userfeeseduc' `userfeesother' `v_userfeesother' `v_userfees' 
		/*`nethealth' `neteducation'  `netother' `v_netinkind'*/
		`v_alltransfers' `v_alltransfersp'
	;
	local transfercols 
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
		`subsidies' `v_subsidies'
		`health' `education' `otherpublic'
		`v_health' `v_education' `v_otherpublic' `v_inkind'
		/*`nethealth' `neteducation'  `netother' `v_netinkind'*/
		`v_alltransfers' `v_alltransfersp'
	;
	local taxcols: list programcols - transfercols; // set subtraction;
	#delimit cr
	local cols = wordcount("`programcols'") // + 1 for income column

	** labels for fiscal intervention column titles
	foreach pr of local allprogs { // allprogs has variable names already
		local d_`pr' : var label `pr'
		if "`d_`pr''"=="" { // ie, if the var didnt have a label
			local d_`pr' `pr'
			`dit' "Warning: variable `pr' not labeled"
			local warning `warning' "Warning: variable `pr' not labeled."
		}
		if strpos("`d_`pr''","(")!=0 {
			if strpos("`d_`pr''",")")==0 {
				`die' "`d_`pr'' must have a closed parenthesis"
				exit 198
			}
		}
	}
	local d_`v_pensions'         = "All contributory pensions"
	local d_`v_dtransfers'       = "All direct transfers excl contributory pensions"
	local d_`v_dtransfersp'      = "All direct transfers incl contributory pensions"
	local d_`v_contribs'         = "All contributions"
	local d_`v_dtaxes'           = "All direct taxes"
	local d_`v_dtaxescontribs'   = "All direct taxes and contributions"
	local d_`v_subsidies'        = "All indirect subsidies"
	local d_`v_indtaxes'         = "All indirect taxes"
	local d_`v_health'           = "Net health transfers"
	local d_`v_education'        = "Net education transfers"
	local d_`v_otherpublic'      = "Net other public transfers" // LOH need to fix that this is showing up even when I don't specify the option
	local d_`v_inkind'           = "All net in-kind transfers"
	local d_`v_userfeeshealth'   = "All health user fees"
	local d_`v_userfeeseduc'     = "All education user fees"
	local d_`v_userfeesother'    = "All other user fees"
	local d_`v_userfees'	     = "All user fees"
    /* scalar _d_`v_netinkind'        = "All net inkind transfers"   scalar of specfic net inkind transfers created before */
	local d_`v_alltransfers'     = "All net transfers and subsidies excl contributory pensions"
	local d_`v_alltransfersp'    = "All net transfers and subsidies incl contributory pensions"
	local d_`v_alltaxes'         = "All taxes"
	local d_`v_alltaxescontribs' = "All taxes and contributions"
	
	** results
	local supercols totLCU totPPP pcLCU pcPPP shares cumshare
	
	** titles 
	local _totLCU = "CONCENTRATION TOTALS (LCU)"
	local _totPPP = "CONCENTRATION TOTALS (US PPP DOLLARS)"
	local _pcLCU  = "CONCENTRATION PER CAPITA (LCU)"
	local _pcPPP  = "CONCENTRATION PER CAPITA (US PPP DOLLARS)"
	local _shares  = "CONCENTRATION SHARES"
	local _cumshare = "CONCENTRATION CUMULATIVE SHARES"
	foreach v of local alllist {
		local uppered = upper("`d_`v''")
		local _fi_`v' = "FISCAL INCIDENCE WITH RESPECT TO `uppered'"
	}
	
	*******************
	** PARSE OPTIONS **
	*******************
	** ado file specific
	if "`sheet'"=="" local sheet "E25. Concentration Curves" 
	
	** check if fiscal interventions are specified
	if "`allprogs'"=="" `dit' "Warning: Fiscal interventions are not specified. Hence no graphs are produced."
	if "`allprogs'"=="" local warning `warning' "Warning: Fiscal interventions are not specified. Hence no graphs are produced."
	
	** make sure -glcurve- installed
	cap which glcurve
	if _rc {
		`die' "{bf:glcurve} not installed; to install: {stata ssc install glcurve:ssc install glcurve}"
		exit	
	}
	
	/** ppp conversion (leaving this here in case we add PPP converted to sheet later)
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group and bin not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	**/

	** negative incomes
	foreach v of local alllist {
		if "``v''"!="" {
			qui count if ``v''<0 // note `v' is e.g. m, ``v'' is varname
			if r(N) `dit' "Warning: `r(N)' negative values of ``v''"
			if r(N) local warning `warning' "Warning: `r(N)' negative values of ``v''"
		}
	}	
	
	** negative fiscal interventions
	foreach pr of local allprogs {
		if "`pr'"!="" {
			qui summ `pr'
			if r(mean)>0 {
				qui count if `pr'<0
				if r(N) `dit' "Warning: `r(N)' negative values of `pr'."
				if r(N) local warning `warning' "Warning: `r(N)' negative values of `d_`pr''."
			}
			else {
				qui count if `pr'>0
				if r(N) `dit' "Warning: `r(N)' positive values of `pr' (`pr' stored as negatived values)."
				if r(N) local warning `warning' "Warning: `r(N)' positive values of `d_`pr'' (`d_`pr'' stored as negatived values)."
			}
		}
	}
	
	** Graphing options
	if "`graphname'"=="" local graphname "conc"
	else if strpos("`graphname'",",") {
		`die' "{bf:graphname} does not allow sub-options"
		exit
	}
	else if strpos("`graphname'",".gph") local graphname = subinstr("`graphname'",".gph","",.)
	if "`path'"!="" & substr("`path'",-1,1)!="/" & substr("`path'",-1,1)!="\" {
		local path "`path'/"
	}
	
	if "`scheme'"=="" local _scheme scheme(s1color)
	else local _scheme scheme(`scheme')
	
	** create new variables for program categories
	if wordcount("`allprogs'")>0 ///
	foreach pr of local taxcols {
		qui summ `pr', meanonly
		if r(mean)>0 {
			if wordcount("`postax'")>0 local postax `postax', `pr'
			else local postax `pr'
			qui replace `pr' = -`pr' // replace doesnt matter since we restore at the end
		}
	}
	
	** temporary variables
	tempvar one
	qui gen `one' = 1
	

	*********************************
	** CALCULATE AND GRAPH RESULTS **
	*********************************
	// Local macros for graph
	local thickness medthick
	local thinner medthin
	local thinnest thin
	local xsize medsmall
	local numsize medsmall
	local xopts format(%2.1f) labsize(`numsize') labcolor(black) notick nogrid 
	local topts size(`xsize') color(black)
	local maintopts size(`xsize') color(black) margin(bottom)
	local xaxis ///
		xlabel(none .2 .4 .6 .8 1, `xopts') ///
		xtitle("Cum. proportion of population", `topts' margin(t+2))
	local yopts angle(0) format(%2.1f) labsize(`numsize') labcolor(black) notick nogrid
	local yaxis ///
		ylabel(0(.2)1, `yopts') ///
		ytitle("Cum. proportion of intervention", `topts')
	local lopts size(vsmall) symx(*.4) rowgap(*0.1) colgap(*0.2) span
	local legend legend(`lopts')
	local o sort lwidth(`thickness')
	local plotregion plotregion(margin(zero) fcolor(white) lstyle(none) lcolor(white)) 
	local graphregion graphregion(fcolor(white) lstyle(none) lcolor(white)) 
	
	local black clcolor(black)
	local hy 4
	local hx 5
	
	foreach v of local alllist {
		if "``v''"=="" continue
		
		foreach list_ of local list_of_cols {
			if "``list_''"=="" continue // ie, they didn't specify any options in that
				// category
			local list__ = subinstr("`list_'","_cols","",.)
			tempvar `v'x `v'y diagline
			local graphlines ""
			local counter = 0	
			foreach pr of local `list_' {
				local ++counter
				if      mod(`counter',3)==1 local _pattern "clpattern(dash)"
				else if mod(`counter',3)==2 local _pattern "clpattern(shortdash)"
				else                        local _pattern "clpattern(solid)"
				
				// Generate coordinates for curves
				tempvar `pr'x `pr'y 
				#delimit ;
				quietly glcurve `pr' `aw', 
					sortvar(``v'') lorenz 
					glvar(``pr'y') pvar(``pr'x') 
					nograph 
				; // note: checked and confirmed that glcurve uses sort, stable; 
				#delimit cr
				
				label var ``pr'y' "`d_`pr''" 
							
				local graphlines `graphlines' (line ``pr'y' ``pr'x', `o' `_pattern')
			}
		
			#delimit ;
			quietly glcurve ``v'' `aw', 
				sortvar(``v'') lorenz
				glvar(``v'y') pvar(``v'x') 
				nograph 
			;
			gen `diagline' = ``v'y' ;
			label var ``v'y' "`=scalar(_d_`v')'" ;
			label var `diagline' "45 Degree Line" ;
		
			graph twoway 
				(line `diagline' `diagline', sort lwidth(`thinnest')  `black')
				(line ``v'y' ``v'x'        , sort lwidth(`thickness') `black')
				`graphlines'
				,
				`xaxis' `yaxis' 
				aspect(0.8) /* will be overwritten by `options' if they specify that */ 
				`graphregion' `plotregion'
				title("Concentration Curves (ranked by `=scalar(_d_`v')')", `maintopts' span)
				xscale(range(0 1)) yscale(range(0 1)) 
				name("`graphname'_`list__'_`v'", replace)
				saving(`"`path'`graphname'_`list__'_`v'"' /* " */, replace) 
				`legend'
				`options' `_scheme' 
			;
			graph export `"`path'`graphname'_`list__'_`v'.png"', replace; //"
			
			#delimit cr	
		}
	}

	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" {
		if `c(version)' <14.1 {
			`die' "Writing graphs to excel requires Stata 14.1 or newer. {bf:Using} option is not allowed."
		}
		else {
			// " 
			version 14.1
			`dit' `"Writing to "`using'"; may take several minutes"'
			local startcol_o = 4 // this one will stay fixed (column D)

			// Print information
			local date `c(current_date)'		
			local titlesprint
			local titlerow = 3
			local titlecol = 1
			local titlelist country surveyyear authors date scenario group project
			
			foreach title of local titlelist {
				returncol `titlecol'
				if "``title''"!="" & "``title''"!="-1" ///
					local  titlesprint `titlesprint' `r(col)'`titlerow'=("``title''")
				local titlecol = `titlecol' + 1
			}
		
				
			// Print warning message on Excel sheet 
			local warningrow = 185
			local warningcount = -1
			foreach x of local warning {
				local warningprint `warningprint' A`warningrow'=("`x'")
				local ++warningrow
				local ++warningcount
			}
			// overwrite the obsolete warning messages if there are any
			forval i=0/100 {
				local warningprint `warningprint' A`=`warningrow'+`i''=("")
			}
			// count warning messages and print at the top of MWB
			local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 181.") 
		
			// Print version number on Excel sheet
			local versionprint A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'")
			
			// putexcel
			// qui putexcel clear 
			qui putexcel set `"`using'"', modify sheet("`sheet'")  //"
			*set trace on 
			local incrow = 0
			foreach v of local alllist {
				if "``v''"=="" continue
				*local incrow = `_`v''-1
				local graphrow = (`incrow')*26 + 8 
				
				local graphprint ""
				local i=0    // for change of columns
				foreach list_ of local list_of_cols {
					//if "``m''"=="" continue
					if "``list_''"=="" continue //
					local list__ = subinstr("`list_'","_cols","",.)
					local col`list_' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each intervention
					returncol `col`list_''
					local ++i
					local list_name = subinstr("`list__'","_"," ",.)  // change direct_taxes to direct taxes, for example
					local listname = strproper("`list_name'")
					nois di `"putexcel `graphprint' `r(col)'`graphrow'=picture("`path'`graphname'_`list__'_`v'.png")"'
					qui putexcel `graphprint' `r(col)'`=`graphrow'-1'=("`listname'")
					qui putexcel `graphprint' `r(col)'`graphrow'=picture("`path'`graphname'_`list__'_`v'.png")
					local i = `i' + 1
				} 
				local incrow = `incrow' + 1
			}
			*set trace off
			/*
			local i=0
			foreach list_ of local list_of_cols {
				//if "``mp''"=="" continue
				if "``list_''"=="" continue //
				local list__ = subinstr("`list_'","_cols","",.)
				local col`list_' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each intervention
				returncol `col`list_''
				local ++i
				local list_name = subinstr("`list__'","_"," ",.)
				local listname = strproper("`list_name'")
				local graphprint `graphprint' `r(col)'32=("`listname'")
				local graphprint `graphprint' `r(col)'33=picture("`path'`graphname'_`list__'_mp")
			}
			local i=0
			foreach list_ of local list_of_cols {
				//if "``n''"=="" continue
				if "``list_''"=="" continue //
				local list__ = subinstr("`list_'","_cols","",.)
				local col`list_' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each intervention
				returncol `col`list_''
				local ++i
				local list_name = subinstr("`list__'","_"," ",.)
				local listname = strproper("`list_name'")
				local graphprint `graphprint' `r(col)'57=("`listname'")
				local graphprint `graphprint' `r(col)'58=picture("`path'`graphname'_`list__'_n")
			}
			local i=0
			foreach list_ of local list_of_cols {
				//if "``g''"=="" continue
				if "``list_''"=="" continue //
				local list__ = subinstr("`list_'","_cols","",.)
				local col`list_' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each intervention
				returncol `col`list_''
				local ++i
				local list_name = subinstr("`list__'","_"," ",.)
				local listname = strproper("`list_name'")
				local graphprint `graphprint' `r(col)'82=("`listname'")
				local graphprint `graphprint' `r(col)'83=picture("`path'`graphname'_`list__'_g")
			}
			local i=0
			// omit t for now
			foreach list_ of local list_of_cols {
				//if "``d''"=="" continue
				if "``list_''"=="" continue //
				local list__ = subinstr("`list_'","_cols","",.)
				local col`list_' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each intervention
				returncol `col`list_''
				local ++i
				local list_name = subinstr("`list__'","_"," ",.)
				local listname = strproper("`list_name'")
				local graphprint `graphprint' `r(col)'107=("`listname'")
				local graphprint `graphprint' `r(col)'108=picture("`path'`graphname'_`list__'_d")
			}
			local i=0
			foreach list_ of local list_of_cols {
				//if "``c''"=="" continue
				if "``list_''"=="" continue //
				local list__ = subinstr("`list_'","_cols","",.)
				local col`list_' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each intervention
				returncol `col`list_''
				local ++i
				local list_name = subinstr("`list__'","_"," ",.)
				local listname = strproper("`list_name'")
				local graphprint `graphprint' `r(col)'132=("`listname'")
				local graphprint `graphprint' `r(col)'133=picture("`path'`graphname'_`list__'_c")
			}
			local i=0
			foreach list_ of local list_of_cols {
				//if "``f''"=="" continue
				if "``list_''"=="" continue //
				local list__ = subinstr("`list_'","_cols","",.)
				local col`list_' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each intervention
				returncol `col`list_''
				local ++i
				local list_name = subinstr("`list__'","_"," ",.)
				local listname = strproper("`list_name'")
				local graphprint `graphprint' `r(col)'157=("`listname'")
				local graphprint `graphprint' `r(col)'158=picture("`path'`graphname'_`list__'_f")
			}
			*/
			// putexcel
			*set trace on
			qui putexcel `titlesprint' `versionprint' `graphprint' `warningprint' // by default, all existing cell formatting is preserved 
			*set trace off
		}
	}
	
	*********
    ** OPEN *
    *********
    if "`open'"!="" & "`c(os)'"=="Windows" {
         shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
    }
    else if "`open'"!="" & "`c(os)'"=="MacOSX" {
         shell open `using'
    }
    else if "`open'"!="" & "`c(os)'"=="Unix" {
         shell xdg-open `using'
    }
	
	**************
	** CLEAN UP **
	**************
	restore // note this also restores svyset
	
end	// END ceqgraph_conc
