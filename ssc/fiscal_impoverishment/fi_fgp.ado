** ADO FILE FOR FISCAL IMPOVERISHMENT AND GAINS OF THE POOR STAND ALONE COMMANDS

** VERSION AND NOTES (changes between versions described under CHANGES)
** v1.0 19jun2017 
*! (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES



// BEGIN _fifgp (Higgins 2017)
//  Calculates fiscal impoverishemnt and fiscal gains of the poor
//   measures for a specific poverty line and two income concepts

capture program drop _fi_fgp
program define _fi_fgp, rclass
	#delimit ;
	syntax varlist(min=2 max=2) [aweight pweight],  
		z(string)
		[
		TOTal 
		PERcapita 
		NORMalized  
		KAPPa(real -1)
		
		NORATio
		HEADcount
		
		/*Total Decompositon */
		DEComp
		
		
		]
	;
	#delimit cr
	
	local y0 = word("`varlist'",1)
	local y1 = word("`varlist'",2)
	
	tempvar t_fi t_fg 
	qui gen double `t_fi' = min(`y0',`z') - min(`y0',`y1',`z')
	qui gen double `t_fg' = min(`y1',`z') - min(`y0',`y1',`z')
		
	if "`exp'" != "" {
		local aw "[aw `exp']"
	}
	/* Calulating main results*/
	tempvar tot_fi tot_fg
	foreach name in  fi fg { 
		if "`total'"!="" {
			qui summ `t_`name'' `aw' , detail
			
			return scalar _`name' = r(sum)
			
			qui gen double `tot_`name'' = `t_`name''
			}
			
		if "`percapita'"!="" {
			qui summ `t_`name'' `aw'
			return scalar _`name'  =  r(mean)
			qui gen double `tot_`name'' = `t_`name''
			}
		if "`normalized'"!="" {
			qui gen double  `tot_`name'' = `t_`name'' / `z'
			qui summ `tot_`name'' `aw', meanonly
			return scalar _`name' = r(mean)
			}	
		if (`kappa' != -1) {
			qui gen  double  `tot_`name'' =  `kappa'*`t_`name'' 
			qui summ `tot_`name'' `aw'
			return scalar _`name' = r(sum)
			}
		}
		
	/* Calculating % fi of fgp */		
	if ("`headcount'" == "" & "`noratio'" == "") {
		qui summ `tot_fi' `aw'
		local fi_tot = r(sum)
		qui summ `tot_fg' `aw'
		local fg_tot = r(sum)
		return scalar _fifg_rat = (`fi_tot' / `fg_tot')
		}
		
	/* Calculating Headcount */	
	if "`headcount'" !="" {
		tempvar h_fi h_fg
		qui gen double `h_fi' = (`y1' < `y0' & `y1' < `z') 
		qui gen double `h_fg' = (`y0' < `y1' & `y0' < `z')
		qui summ `h_fi' `aw', meanonly
		return scalar _h_fi = r(mean)
		qui summ `h_fg' `aw', meanonly
		return scalar _h_fg = r(mean)
		}
		
	
	/* Demcop results */
	if "`decomp'" != "" {
		tempvar p_fi p_fg i_fi i_fg p0 p1 
		qui gen double `p0' = `z' - min(`y0',`z') // individual's pre-fisc poverty gap
		qui gen double `p1' = `z' - min(`y1',`z') // individual's post-fisc poverty gap
		
		//Marc: If total is called we want these p0 p1.
		
		** Total post/pre - fisc pover gap
		if "`total'" !=""  {
			qui sum `p0' `aw'
			return scalar _p0 = r(sum)
			qui sum `p1' `aw'
			return scalar _p1 = r(sum)
			}
		if "`percapita'"!="" {
			qui sum `p0' `aw'
			return scalar _p0 = r(mean)
			qui sum `p1' `aw'
			return scalar _p1 = r(mean)
			}
		if "`normalized'"!="" {
			tempvar p0_z p1_z
			qui gen double `p0_z' = `p0' / `z'
			qui gen double `p1_z' = `p1' / `z'
			qui sum `p0_z' `aw'
			return scalar _p0 = r(mean)
			qui sum `p1_z' `aw'
			return scalar _p1 = r(mean)
			}	
		if (`kappa' != -1) {
			tempvar p0_k p1_k
			qui gen double `p0_k' =  `kappa'*`p0'
			qui summ `p0_k' `aw'
			return scalar _p0 = r(sum)
			qui gen double `p1_k' =  `kappa'*`p1'
			return scalar _p1 = r(sum)
			}
		}
		

end // END _fi_fgp


// BEGIN _fifgp (Higgins 2017)
//  Calculates fiscal impoverishemnt and fiscal gains of the poor
//   measures for a specific poverty line and two income concepts

capture program drop fi_fgp
program define fi_fgp, rclass

	#delimit ;
	syntax varlist(min=2 max=2) [if] [in] [aweight pweight/],  
		z(string)
		[
		/* ppp values */
		PPP(real -1)
		CPISurvey(real -1)
		CPIBase(real -1)
		YEARly
		MOnthly
		DAily
		
		/*scalar values */
		TOTal 
		PERcapita 
		NORMalized  
		KAPpa(real -1)
		
		
		NORATio
		HEADcount
		
		/*Total Decompositon */
		DEComp  
		
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
		
		/** DROP MISSING VALUES */
		IGNOREMissing
		]
	;	
	#delimit cr
	
	version 13
	
	**********
	** LOCALS *
	**********
	** parse subcommand 
	gettoken subcmd 0: 0
	
	if substr("`subcmd'",1,2)=="graph" { // fiscal impoverishment
		fi_fgp_graph `0'
	}
	else {
		
		if "`kappa'" != "" {
			local k = "kappa(`kappa')"
		}

		local options z(`z') `total' `percapita' `normalized' `k'  `headcount' `decomp'
		
		** general programming locals
		local dit display as text in smcl
		local die display as error in smcl
		local command fi_fgp
		local version 1.0
		`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to seanhiggins@berkeley.edu)"
		
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
		


		** income or fisical interventions varialbes 
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
					local warning `warning' "Warning: `r(N)' observations that are missing ``var'' were dropped because the user specified the ignoremissing option."
				}
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

		
		** Calculating FI and FGP
		#delimit ;
		_fi_fgp `y0_ppp' `y1_ppp' `aw', `options'
		
		;
		#delimit cr
		
		return scalar fi = `r(_fi)' 
		return scalar fg = `r(_fg)'
		
		if ("`headcount'" == "" & "`noratio'" == "") {
			return scalar fifg_rat =  `r(_fifg_rat)'
		}
			
		if "`headcount'" !="" {	
			return scalar h_fi = `r(_h_fi)'
			return scalar h_fg = `r(_h_fg)'
		}
			
		if "`decomp'" !="" {
			return scalar p0 = `r(_p0)'
			return scalar p1 = `r(_p1)'

			local __p1 = `r(_p1)'
			local __p0 = `r(_p0)'
			local __fi = `r(_fi)'
			local __fg = `r(_fg)'
			local pgap = `r(_p1)' - `r(_p0)'
			local fifgp =`r(_fi)'  - `r(_fg)'

			return scalar diff_pgap = `pgap'
			return scalar diff_fifpg = `fifgp'
			
			tempname table
			.`table'  = ._tab.new, col(4)  separator(0) lmargin(0)
			.`table'.width  16 16 16 16 
			.`table'.strcolor yellow yellow yellow yellow 
			.`table'.numcolor yellow yellow yellow yellow   
			.`table'.numfmt %16s  %16.5f %16s %16.5f

	       
	      	.`table'.sep, top
	      	.`table'.titles "" "Decomposition of fiscal intervention:" "" "" 
			
			scalar r11 = "p0 = "
			scalar r13 = "FGP = "
			scalar r21 = "p1 = "
			scalar r23 = "FI = "
			scalar r31 = "p1 - p0 = "
			scalar r33 = "FI - FGP = "
			.`table'.sep, mid
			.`table'.row r11 `__p0' r13 `__fg'
			.`table'.row r21 `__p1' r23 `__fi'
			.`table'.row r31 `pgap' r33 `fifgp'
			
		   .`table'.sep,bot

		}

	}
		
end // END fi_fgp
