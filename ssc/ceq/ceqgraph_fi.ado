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
			HEADcount TOTal PERcapita NORMalized
		]
	;
	#delimit cr
	if "`headcount'`total'`percapita'`normalized'"=="" {
		// then calculate results for all
		foreach x in headcount total percapita normalized {
			local `x' "`x'"
		}
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
		local _col = 0
		local ++_col
		if "`headcount'"!="" {
			qui summ `h_`sheet'' [`weight' `exp'], meanonly
			mata: `sheet'[`row',`_col'] = `r(mean)'
		}
		
		if "`total'`percapita'`normalized'"!="" {
			qui summ `d_`sheet'' [`weight' `exp'], meanonly
			local ++_col
			if "`total'"!="" {   
				mata: `sheet'[`row',`_col'] = `r(sum)'
			}
			local ++_col
			if "`percapita'"!="" {
				mata: `sheet'[`row',`_col'] = `r(mean)'
			}
			local ++_col
			if "`normalized'"!="" {
				mata: `sheet'[`row',`_col'] = `r(mean)'/`z'
			}
		}
	}	
end

// BEGIN returncol (Higgins 2015) 
//  Returns Excel column corresponding to a number
cap program drop returncol
program define returncol, rclass
	confirm integer number `1'
	mata: st_strscalar("col",numtobase26(`1'))
	return local col = col
end // END returncol

// BEGIN ceqgraph_fi 
capture program drop ceqgraph_fi
capture program define ceqgraph_fi
	#delimit ;
	syntax 
		[using/]
		[if] [in] [pweight/] 
		[, 
			/** INCOME CONCEPTS: */
			Market(varname)
			Mpluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			/** PPP CONVERSION */
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			/** SURVEY INFORMATION */
			HHid(varname)
			HSize(varname) 
			PSU(varname) 
			Strata(varname)  
			/** SPECIFIC TO THIS ADO FILE: */
			HEADcount TOTal PERcapita NORMalized
			pl1(real 1.25)
			pl2(real 2.5)
			pl3(real 4)
			precision(real 0.01)
			path(string)
			graphname(string)
			scheme(string)
			/** INFORMATION CELLS **/
			COUNtry(string)
			SURVeyyear(string) /** string because could be range of years **/
			AUTHors(string)
			BASEyear(real -1)
			SCENario(string)
			GROUp(string)
			PROJect(string)
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
	
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqgraph_fi
	local version 2.3

	** results
	if "`headcount'`total'`percapita'`normalized'"=="" {
		foreach x in headcount total percapita normalized {
			local `x' "`x'"
		}
	}
	local supercols_all headcount total percapita normalized
	local supercols `headcount' `total' `percapita' `normalized'
	
	** matrices
	local rows = ceil(`pl3'/`precision') + 1
	mata: z = J(`rows',1,.)
	foreach sheet in fi fg {
		// use Mata to avoid matrix limits
		mata: `sheet' = J(`rows',4,.)
	}
	
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
	local alllist_no_t = subinstr("`alllist'","t","",1)
	local cols = wordcount("`alllist'")
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
	local varlist_no_t : list varlist - t // varlist without taxable income
	local _d_m      = "Market Income"
	local _d_mp     = "Market Income + Pensions"
	local _d_n      = "Net Market Income"
	local _d_g      = "Gross Income"
	local _d_t      = "Taxable Income"
	local _d_d      = "Disposable Income"
	local _d_c      = "Consumable Income"
	local _d_f      = "Final Income"
	
	** print warning messages 
	local warning "Warnings"
	
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
	if wordcount("`inctypewarn'")>0 local warning `warning' "Warning: Income variable(s) `inctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."	
	
	** ado file specific
	if "`sheet'"=="" local sheet "E27. FIFGP" 
	
	** ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Option {bf:ppp} required."
		exit 198
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
		local warning `warning' "Warning: daily, monthly, or yearly options not specified; variables assumed to be in yearly local currency units."
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
		
	** negative incomes
	foreach v of local varlist {
		qui count if `v'<0
		if r(N)>0 `dit' "Warning: `r(N)' negative values of `v'"
		if r(N)>0 local warning `warning' "Warning: `r(N)' negative values of `v'"
	}	
	
	** Graphing options
	if "`graphname'"=="" local graphname "fi"
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
	local _if "if z<=`pl3'"

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
	
	local xaxis xline(`pl1' `pl2' `pl3', lcolor(gs7) lpattern(shortdash) lwidth(`thinner')) ///
		xlabel(0(1)`pl3', labsize(`numsize')) ///
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
	
	** weight (if they specified hhsize*hhweight type of thing)
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
	
	
	************************
	** PRESERVE AND MODIFY *
	************************
	
	** collapse to hh-level data
	if "`hsize'"=="" { // i.e., it is individual-level data
		tempvar members
		sort `hhid'
		qui bys `hhid': gen `members' = _N // # members in hh 
		qui bys `hhid': drop if _n>1 // faster than duplicates drop
		local hsize `members'
	}
	
	***********************
	** SVYSET AND WEIGHTS *
	***********************
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
	
	** keep the variables used in ceqdes  
	#delimit ;
	local relevar `varlist'   
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
	
	
		
	** PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			if "``v''"!="" {
				tempvar `v'_ppp
				qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
			}
		}
	}	
	
	** temporary variables
	tempvar one
	qui gen `one' = 1
	
	**********************
	** CALCULATE RESULTS *
	**********************
	tempfile pregraph
	qui save `pregraph', replace		
	foreach y0 in m mp {
		foreach y1 in c f {
			if "``y0''"=="" | "``y1''"=="" continue // not included in command options
			
			use `pregraph', clear

			local r=0
			forval z=0(`precision')`pl3' {
				local ++r
				local z = round(`z',`precision') // due to weird precision in Stata
				_fifg_ ``y0'_ppp' ``y1'_ppp' `aw', ///
					z(`z') row(`r') col(1) ///
					`headcount' `total' `percapita' `normalized'
			}

			***********
			** GRAPHS *
			***********
			mata: results = fi , fg /** concatenate */
			clear
			getmata z=z ///
				(fi_headcount fi_total fi_percapita fi_normalized)=fi ///
				(fg_headcount fg_total fg_percapita fg_normalized)=fg
			foreach measure of local supercols {
				label var fi_`measure' "FI"
				label var fg_`measure' "FGP"
				
				// Difference
				qui gen diff_`measure' = abs(fi_`measure' - fg_`measure')
				label var diff_`measure' "Difference"
			}
			
			foreach measure of local supercols {
				if "`measure'"=="headcount" ///
					local diff_line ""
				else local diff_line "(line diff_`measure' z `_if', `o' `c3')"
				#delimit ;
				graph twoway 
					(line fi_`measure'   z `_if', `o' `c1')
					(line fg_`measure'   z `_if', `o' `c2')
					`diff_line'
					,
					`xaxis' `yaxis'	`legend' `aspectratio'
					title("`_`measure''", span)
					subtitle("`_d_`y0'' to `_d_`y1''", span)
					saving(`"`path'`graphname'_`measure'_`y0'_to_`y1'"' /*"*/, replace)
					`options' `_scheme'
				;
				qui graph export `"`path'`graphname'_`measure'_`y0'_to_`y1'.png"', replace;
				#delimit cr
				qui di "
			}
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
			qui di "
			version 14.1
			`dit' `"Writing to "`using'"; may take several minutes"'
			local startcol_o = 4 // this one will stay fixed (column D)

			// Print information
			local date `c(current_date)'		
			local titlesprint
			local titlerow = 3
			local titlecol = 1
			local titlelist country surveyyear authors date ppp baseyear cpibase cpisurvey ppp_calculated ///
					scenario group project
			foreach title of local titlelist {
				returncol `titlecol'
				if "``title''"!="" & "``title''"!="-1" ///
					local  titlesprint `titlesprint' `r(col)'`titlerow'=("``title''")
				local titlecol = `titlecol' + 1
			}
				
			// Print warning message on Excel sheet 
			local warningrow = 115 
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
			local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 60.")  
		
			// Print version number on Excel sheet
			local versionprint A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'")
		
			// putexcel 
			/*local i=0
			foreach y0 in m mp {
				foreach y1 in c f{
					if "``y0''"=="" | "``y1''"=="" continue // not included in command options "
					qui putexcel set `"`using'"', modify sheet("`sheet'")  //"
					foreach measure of local supercols {  
						local col`measure' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each measure
						returncol `col`measure''
						local graphrowmc = 7
						local graphrowmf = 30
						local graphrowmpc = 53
						local graphrowmpf = 76
						qui putexcel `r(col)'`graphrow`y0'`y1''=picture("`path'`graphname'_`measure'_`y0'_to_`y1'.png")
						//local graphprint`y0'to`y1' `graphprint`y0'to`y1'' `r(col)'7=picture("`path'`graphname'_`measure'_`y0'_to_`y1'.png")
						local ++i
					}
					qui putexcel `titlesprint' `versionprint' `graphprint`y0'to`y1'' `warningprint'
				}
			}*/
			local i=0
			qui putexcel set `"`using'"', modify sheet("`sheet'") 
			if "``m''"=="" | "``c''"=="" {  /*"*/
				qui putexcel B7=("Market Income to Consumable Income"), bold
				foreach measure of local supercols { 
					local col`measure' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each measure
					returncol `col`measure''
					qui putexcel `r(col)'8=picture("`path'`graphname'_`measure'_m_to_c.png") 
					local ++i
				}
			}
			local i=0
			if "``m''"=="" | "``f''"=="" {
				qui putexcel B33=("Market Income to Final Income"), bold
				foreach measure of local supercols { 
					local col`measure' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each measure
					returncol `col`measure''
					qui putexcel `r(col)'34=picture("`path'`graphname'_`measure'_m_to_f.png")
					local ++i
				}
			}
			local i=0
			if "``mp''"=="" | "``c''"=="" {
				qui putexcel B59=("Market Income Plus Pensions to Consumable Income"), bold
				foreach measure of local supercols {
					local col`measure' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each measure
					returncol `col`measure''
					qui putexcel `r(col)'60=picture("`path'`graphname'_`measure'_mp_to_c.png")
					local ++i
				}
			}
			local i=0
			if "``mp''"=="" | "``f''"=="" {
				qui putexcel B85=("Market Income Plus Pensions to Final Income"), bold
				foreach measure of local supercols {  
					local col`measure' = 2 + (`i'*6)     // start with column B and then move 6 columns to the right for each measure
					returncol `col`measure''
					qui putexcel `r(col)'86=picture("`path'`graphname'_`measure'_mp_to_f.png")
					local ++i
				}
			} 
			qui putexcel `titlesprint' `versionprint' `warningprint'
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

	*************
	** CLEAN UP *
	*************
	restore // note this also restores svyset
	
end	// END ceqgraph_fi
