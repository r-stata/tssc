** Subcommand of ceqgraph
** See ceqgraph.ado for version and notes

*************************
** PRELIMINARY PROGRAMS *
*************************
// BEGIN _fifg_ (Higgins 2015)
//  Calculates fiscal impoverishemnt and fiscal gains of the poor
//   measures for a specific poverty line and two income concepts
capture program drop _fifg_ 
program define _fifg_
	#delimit ;
	syntax varlist(min=2 max=2) [aweight], 
		z(real) row(real) col(real)
		[
			HEADcount TOTal PERcapita NORMalized KAPpa(real -1)
		]
	;
	#delimit cr 
	// Marc: What is this for?
	if "`headcount'`total'`percapita'`normalized'"=="" {
		// then calculate results for all
		foreach x in headcount total percapita normalized {
			local `x' "`x'"
		}
	}

	if `kappa' == -1 {
		local _kap_ = ""
	}

	local y0 = word("`varlist'",1)
	local y1 = word("`varlist'",2)
	
	tempvar h_fi d_fi h_fg d_fg 
	qui gen `h_fi' = (`y1' < `y0' & `y1' < `z') 
	qui gen `d_fi' = min(`y0',`z') - min(`y0',`y1',`z')
	qui gen `h_fg' = (`y0' < `y1' & `y0' < `z')
	qui gen `d_fg' = min(`y1',`z') - min(`y0',`y1',`z')	
	
	mata: z[`row',1] = `z'

	foreach sheet in fi fg {
		local _col = 1
		if "`headcount'"!="" {
			qui summ `h_`sheet'' [`weight' `exp'], meanonly
			mata: `sheet'[`row',`_col'] = `r(mean)'
		}
		
		if "`total'`percapita'`normalized'`_kap_'"!="" {
			qui summ `d_`sheet'' [`weight' `exp'], meanonly
			if "`total'"!="" {   
				mata: `sheet'[`row',`_col'] = `r(sum)'
			}
			if "`percapita'"!="" {
				mata: `sheet'[`row',`_col'] = `r(mean)'
			}
			if "`normalized'"!="" {
				mata: `sheet'[`row',`_col'] = `r(mean)'/`z'
			}
			if (`kappa' != -1) {
				mata: `sheet'[`row',`_col'] = `r(sum)'*`kappa'
			}
		}
	}	
end


// BEGIN ceqgraph_fi 
capture program drop fi_fgp_graph
capture program define fi_fgp_graph
	#delimit ;
	syntax varlist(min=2 max=2) [if] [in] [aweight pweight/] ,
		z(string)
		[
		/* ppp values */
		PPP(real -1)
		CPISurvey(real -1)
		CPIBase(real -1)
		YEARly
		MOnthly
		DAily
	
		/** SPECIFIC TO THIS ADO FILE: */
		TOTal 
		PERcapita 
		NORMalized  
		KAPpa(real -1)
		HEADcount
		
		
		/*Household size*/
		HHouse
		INDidivid
		DISPLAYInd
		hhsize(real -1)

		/*Graph Options*/
		precision(real 0.01)
		path(string)
		graphname(string)
		scheme(string)

	
		/* IGNORE MISSING OPTION */
		IGNOREMissing
		/** additional options (for graphing flexibility) */
		*
		]

		;
		#delimit cr
		
		***********
		** LOCALS *
		***********
		** general programming locals
		local dit display as text in smcl
		local die display as error in smcl
		local command fi_fgp_graph 
		local version 1

		** results // MARC: I do not understand what thi is for 
		if "`headcount'`total'`percapita'`normalized'"=="" {
			foreach x in headcount total percapita normalized {
				local `x' "`x'"
			}
		}

		************************
		** PRESERVE AND MODIFY *
		************************
		preserve
		if wordcount("`if' `in'")!=0 quietly keep `if' `in'
		
		** make sure all newly generated variables are in double format
		set type double 
		
		******************
		** PARSE OPTIONS *
		******************	
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
		

		** Variable Modification 
		local y0 = word("`varlist'",1)
		local y1 = word("`varlist'",2)
		local alllist y0 y1
		
		** missing income concepts
		foreach var of local alllist {
			qui count if missing(``var'')  
			if "`ignoremissing'"=="" {
				if r(N) {
					`die' "Missing values not allowed; `r(N)' missing values of ``var'' found" 
					exit 198
				}
			}
			else {
				if r(N) {
					qui drop if missing(``var'')
					`dit' "Warning: `r(N)' observations that are missing ``var'' were dropped because the user specified {bf:ignoremissing}"
					local warning `warning' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified the ignoremissing option."
				}
			}
	    }
		 
		if "`exp'" != "" {	
		if "`hhouse'" !="" & "`displayind'" != "" {
			tempvar hhweights
			gen double `hhweights' = `exp'*`hhsize'
			
			local aw "[aweight = `hhweights']"
			}
		else {
			local aw "[aweight = `exp']"
			}
		}
			
			
		if ( wordcount("`total' `percapita' `normalized' `headcount'")>1 | (`kappa' !=-1 & wordcount("`total' `percapita' `normalized' `headcount'")>0)) {
			`die' "{bf:kappa}, {bf:total}, {bf:percapita}, or {bf:normalized} options are exclusive"
			exit 198
		}
		if (`kappa' == -1 & wordcount("`total' `percapita' `normalized' `headcount'")==0) {
			`die' "One of {bf:kappa},{bf:total}, {bf:percapita}, or {bf:normalized} options must be specified"
			exit 198
		}
		
		** ppp conversion
		if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
			local _ppp = 0
			`dit' "{bf:ppp}, {bf:cpisurvey}, {bf:cpibase} options aren't selected. Variables are assumed to be in ppp dollars per day"
		}
		else local _ppp = 1
		if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
		}
		if ((`_ppp'==0) & (wordcount("`daily' `monthly' `yearly'")>0)) {
			`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
			exit 198
		}
		if ((`_ppp' == 1) & (wordcount("`daily' `monthly' `yearly'")==0)) {
			`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} units"
			local yearly yearly
		}
		if (wordcount("`daily' `monthly' `yearly'")>1) {
			`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
			exit 198
		}

		if ("`daily'"!="")        local divideby = 1
		else if ("`monthly'"!="") local divideby = 365/12
		else if ("`yearly'"!="")  local divideby = 365
		
		** Weights
		if "`individ'" !="" & "`displayind'" != "" {
			`dit' "Warning: {bf:displayind} and {bf:individ} we're both called. Check that data is at household level or remove option {bf:displayind}"
			}
		if "`displayind'" !="" &`hhsize' == -1 {
			`die' "{bf:displayind} requires {bf:hhsize}"
			exit 198
			}
			
		if "`exp'" != "" {	
			if "`hhouse'" !="" & "`displayind'" != "" {
				tempvar hhweights
				gen double `hhweights' = `exp'*`hhsize'
				
				local aw "[aweight = `hhweights']"
				}
			else {
				local aw "[aweight = `exp']"
				}
			}
				
		** PPP converted variables
		if (`_ppp') {
			local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
			foreach v of local alllist {
				tempvar `v'_ppp
				qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
			}
		
		}
		else {
			foreach v of local alllist {
				tempvar `v'_ppp
				qui gen ``v'_ppp' = ``v''
			}
		}

		local supercols_all headcount total percapita normalized kappa
		local k = "kappa(`kappa')"
		local supercols `headcount' `total' `percapita' `normalized' `k'
		if `kappa' !=1 {
			local kap = "kappa"
		}
		local names  `headcount' `total' `percapita' `normalized' `kap'
		
		** matrices
		local rows = ceil(`z'/`precision') + 1
		mata: z = J(`rows',1,.)
		foreach sheet in fi fg {
			// use Mata to avoid matrix limits
			mata: `sheet' = J(`rows',1,.)
		}

		** Graphing options
		if "`graphname'"=="" local graphname "fi_fgp"
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
		local _if "if z<=`z'"

		local c1 lcolor(dknavy)
		local c2 lcolor(orange)
		local c3 lcolor(purple) lpattern(dash)
		local c4 lcolor(gs11) lpattern(dash)
		
		local thickness thick
		local thinner medthick
		local thinnest medium
		local titlesize medium // normally use medium; medlarge if multipanel
		local xsize medlarge // large for multipanel, ow medium
		local numsize medlarge // normally use medlarge; large if multipanel
		
		local  lpattern(shortdash) lwidth(`thinner')) ///
			xlabel(0(1)`z', labsize(`numsize')) ///
			xtitle("Income in dollars per day", margin(top) size(`xsize'))
		local yaxis ylabel(, angle(0) labsize(`numsize'))
		local lopts ring(0) pos(11) col(1) size(`titlesize') symx(*0.617) keygap(*0.6) rowgap(*.75)
		local legend legend(`lopts') 
		local topts size(`titlesize') margin(0 0 3 0) span
		
		local aspectratio aspect(0.7)
		local o sort lwidth(`thickness')
		
		local _headcount  "FI and FGP Headcounts"
		local _total      "Total FI and FGP (PPP per day)"
		local _percapita  "FI and FGP per Person (PPP per day)"
		local _normalized "FI and FGP per Person (Normalized)"
		local _kappa 	  "FI and FGP scaled by kappa = `kappa'"

		
		local prefisc : var label `y0'
		local postfisc: var label `y1'

		if "`prefisc'" == "" {
			local prefisc "`y0'"
		}
		if "`postfisc'" == "" {
			local postfisc "`y1'"
		}
		

		

		** temporary variables
		tempvar one
		qui gen `one' = 1 // MARC: what is this for?
		
		**********************
		** CALCULATE RESULTS *
		**********************
		tempfile pregraph
		qui save `pregraph', replace		

		use `pregraph', clear
		
		local length = `z'/`precision'

		local r=0
		forval xx =0(`precision')`z' {
			local ++r
			local xx = round(`xx',`precision') // due to weird precision in Stata
			_fifg_ `y0_ppp' `y1_ppp' `aw', ///
				z(`xx') row(`r') col(1) ///
				`supercols'
		}

			***********
			** GRAPHS *
			***********
			mata: results = fi , fg /** concatenate */
			clear
			getmata z=z ///
				(fi_)=fi ///
				(fg_)=fg
				
			label var fi_ "FI"
			label var fg_ "FGP"
			
			// Difference
			qui gen diff_ = abs(fi_ - fg_)
			label var diff_ "Difference"
			
			local measure = "`names'" // Since the options are exclusively called this will give string for option called.

			if "`measure'"=="headcount" ///
				local diff_line ""
			else local diff_line "(line diff_ z `_if', `o' `c3')"
			#delimit ;
			graph twoway 
				(line fi_   z `_if', `o' `c1')
				(line fg_   z `_if', `o' `c2')
				`diff_line'
				,
				`xaxis' `yaxis'	`legend' `aspectratio'
				title("`_`measure''", span)
				subtitle("`prefisc' to `postfisc'", span)
				saving(`"`path'`graphname'_`measure'_`y0'_to_`y1'"' /*"*/, replace)
				`options' `_scheme'
			;
			*qui graph export `"`path'`graphname'_`measure'_`y0'_to_`y1'.png"', replace;
				#delimit cr

				// "
			
			
		
		
		
		*************
		** CLEAN UP *
		*************
		restore // note this also restores svyset
	
end	// END ceqgraph_fi
