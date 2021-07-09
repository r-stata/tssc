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

// BEGIN ceqgraph_progressivity
capture program drop ceqgraph_progressivity
capture program define ceqgraph_progressivity
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
			/*PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily*/
			/** SURVEY INFORMATION */
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
			/** EXPORT TO EXCEL */
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
	local command ceqgraph_progressivity
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
	if "`sheet'"=="" local sheet "E24. Lorenz Curves" 
	
	** check if glcurve installed
	cap which glcurve
	if _rc {
		`die' "{bf:glcurve} not installed; to install: {stata ssc install glcurve:ssc install glcurve}"
		exit
	}
		
			
	** negative incomes
	foreach v of local varlist {
		qui count if `v'<0
		if r(N)>0 `dit' "Warning: `r(N)' negative values of `v'"
		if r(N)>0 local warning `warning' "Warning: `r(N)' negative values of `v'"
	}	
	
	** Graphing options
	if "`graphname'"=="" local graphname "prog"
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
	local _if "if z<=`pl'"

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
	
	local yaxis ylabel(0(.2)1, angle(0) labsize(`numsize'))
	local lopts ring(0) pos(11) col(1) size(`titlesize') symx(*0.617) keygap(*0.6) rowgap(*.75) 
	local legend legend(`lopts') 
	local topts size(`titlesize') margin(0 0 3 0) span
	
	local aspectratio aspect(0.8)
	local o sort lwidth(`thickness')
	
	local color_m  blue
	local color_mp ltblue
	local color_n  orange
	local color_g  sand
	local color_d  purple
	local color_c  black
	local color_f  gs7
	
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
	
	** keep the variables needed 
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
	/** missing fiscal interventions 
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
			}
		}
    }*/
	
	
	** temporary variables
	tempvar one
	qui gen `one' = 1
	
	**********************
	** CALCULATE RESULTS *
	**********************
	tempvar diagline
	
	// Pre- and post-fisc Lorenz
	foreach y in m mp c f {
		if "``y''"=="" continue
		tempvar L_`y'_x L_`y'_y
		qui glcurve ``y'' `aw', lorenz pvar(`L_`y'_x') glvar(`L_`y'_y') sortvar(``y'') nograph 
		cap describe `diagline' // this is so that it is generated even if m or mp not specified
		if _rc gen `diagline' = `L_`y'_y' 
	}
	
	// Post-fisc Concentration (wrt Pre-fisc)
	foreach y1 in c f {
		if "``y1''"=="" continue
		foreach y0 in m mp {
			if "``y0''"=="" continue
			tempvar C_`y1'_`y0'_x C_`y1'_`y0'_y
			qui glcurve ``y1'' `aw', lorenz pvar(`C_`y1'_`y0'_x') glvar(`C_`y1'_`y0'_y') sortvar(``y0'') nograph 
		}
	}

	**********
	** GRAPH *
	**********	
	foreach y0 in m mp {
		if "``y0''"=="" continue
		
		foreach y1 in c f {
			if "``y1''"=="" continue
			
			#delimit ;
			twoway 
				(line `diagline' `diagline' `aw', sort lwidth(`thinnest') lcolor(black))
				(line `L_`y0'_y' `L_`y0'_x' `aw', `o' `c2')
				(line `C_`y1'_`y0'_y' `C_`y1'_`y0'_x' `aw', `o' `c1')
				(line `L_`y1'_y' `L_`y1'_x' `aw', `o' `c4')
				,
				xtitle("Cumulative proportion of the population", 
					margin(top) size(`xsize')
				)
				xlabel(0(.2)1, labsize(`numsize'))
				`yaxis'
				legend(`lopts' order(
						2 "Pre-Fisc Lorenz" - 
						3 "Post-Fisc Concentration" -
						4 "Post-Fisc Lorenz" 
					)
				)
				`aspectratio'
				saving(`"`path'`graphname'_`y0'_to_`y1'"' /*"*/, replace)
				title("Lorenz and Concentration Curves", span)
				subtitle("`_d_`y0'' to `_d_`y1''", span)
				`options' `_scheme'
			;
			#delimit cr
			graph export `"`path'`graphname'_`y0'_to_`y1'.png"', replace
		}
		
	}
	
	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" {
		if `c(version)' <14.1 {
			`die' "Writing graphs to excel requires Stata 14.0 or newer. {bf:Using} option is not allowed."
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
			local titlelist country surveyyear authors date scenario group project
			
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
			local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 109.") 
		
			// Print version number on Excel sheet
			local versionprint A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'")

			
			qui putexcel set `"`using'"', modify sheet("`sheet'") 
			if "``m''"=="" | "``c''"=="" {  /*"*/
				/*qui putexcel B7=("Market Income to Consumable Income"), bold*/
				qui putexcel B8=picture("`path'`graphname'_m_to_c.png") 
			}
			if "``m''"=="" | "``f''"=="" {
				qui putexcel B33=("Market Income to Final Income"), bold
				qui putexcel B34=picture("`path'`graphname'_m_to_f.png") 
			}
			if "``mp''"=="" | "``c''"=="" {
				qui putexcel B59=("Market Income Plus Pensions to Consumable Income"), bold
			    qui putexcel B60=picture("`path'`graphname'_mp_to_c.png") 
			}
			if "``mp''"=="" | "``f''"=="" {
				qui putexcel B85=("Market Income Plus Pensions to Final Income"), bold
			    qui putexcel B86=picture("`path'`graphname'_mp_to_f.png") 
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
	
end	// END ceqgraph_progressivity
