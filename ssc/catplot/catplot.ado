*! 2.0.2 NJC 10 December 2010 
* 2.0.1 NJC 18 May 2010 
* 2.0.0 NJC 28 May 2010 
* 1.1.2 NJC 11 February 2004 
* 1.1.1 NJC 2 February 2004 
* 1.1.0 NJC 8 January 2004 
* 1.0.1 NJC 29 April 2003
* 1.0.0 NJC 18 February 2003
program catplot
	version 8
	syntax varlist(max=3) [if] [in] [fweight aweight iweight/] ///
	[, PERCent(varlist) PERCent2 FRaction(varlist) FRaction2   ///
	YTItle(str asis) by(str asis) VERTical MISSing recast(str)      ///
	var1opts(str asis) var2opts(str asis) var3opts(str asis) * ]
	
	// missings? enough to use? 
	if "`missing'" != "" local novarlist "novarlist" 
	marksample touse, strok `novarlist' 

	if `"`by'"' != "" { 
		Checkbymiss `by' 
		if !`bymiss' markout `touse' `byvar', strok 
		local by by(`by') 
	}
			
	qui count if `touse' 
	if r(N) == 0 error 2000 

	// plot type: hbar (default) or bar or dot 
	if "`recast'" != "" { 
		local plotlist "bar dot hbar" 
		if !`: list recast in plotlist' { 
			di "{p}{txt}`recast' not an allowed type, one of" /// 
			"{cmd: `plotlist'}{p_end}" 
			exit 198 
		}
	}
	else local recast hbar 

	// any percent or fraction calculations
	local pc "`percent'" 
	local pc2 "`percent2'" 
	
	local nopts = ("`pc'" != "") + ("`pc2'" != "") ///
		+ ("`fraction'" != "" ) + ("`fraction2'" != "") 
	if `nopts' > 1 {
		di as err "percent and fraction options may not be combined"
		exit 198
	}

	local pvars `pc' `fraction' 
	local prop = cond("`fraction'`fraction2'" != "", "prop", "") 
		
	tempvar toshow 

	quietly { 
		if "`pc2'" != "" | "`fraction2'" != "" {
			local total = cond("`pc2'" != "", 100, 1)
			if "`weight'" == "" { 
				egen `toshow' = pc(`total') if `touse', `prop' 
			} 
			else egen `toshow' = pc(`exp') if `touse', `prop'
		} 
		else if "`pvars'" != "" {
			local total = cond("`pc'" != "", 100, 1)
			if "`weight'" == "" { 
				egen `toshow' = pc(`total') if `touse', ///
					`prop' by(`pvars') 
			}
			else egen `toshow' = pc(`exp') if `touse', ///
					`prop' by(`pvars') 
		} 	
		else {
			if "`weight'" == "" {
				gen `toshow' = `touse' 
			}	
			else gen `toshow' = `touse' * (`exp') 
		} 	
	} 	

	// default axis titles 
	if `"`ytitle'"' == "" { 
		if "`pc2'`pc'" != "" { 
			local ytitle "percent" 
		} 
		else if "`fraction2'`fraction'" != "" { 
			local ytitle "fraction" 
		}	
		else if "`exp'" != "" {
			cap local explbl : var label `exp' 
			if `"`explbl'"' != "" local ytitle `""`explbl'""' 
			else local ytitle "`exp'" 
		} 
		else local ytitle "frequency" 
	}

	// vertical() option of -graph hbar|bar|dot- is not documented
	if `: word count `varlist'' == 1 & `"`by'"' == "" { 
		local xtitle `"`: var label `varlist''"'
		if `"`xtitle'"' == "" local xtitle "`varlist'" 
		if "`vertical'" != "" { 
			local xtitle b1title(`"`xtitle'"') 
		} 
		else if "`recast'" == "hbar" { 
			local xtitle l1title(`"`xtitle'"') 
		}
		else local xtitle b1title(`"`xtitle'"') 
	} 
	
	// map to -over()- options 
	local i = 1
	foreach v of local varlist { 
		local overs `overs' over(`v' , `var`i++'opts') 
	} 

	// draw graph 
	graph `recast' (sum) `toshow' if `touse', ///
	`vertical' `overs' `by' ytitle(`ytitle') `xtitle' `missing' `options' 
end

program Checkbymiss 
	syntax varname [, MISSing * ] 
	c_local byvar "`varlist'" 
	c_local bymiss = "`missing'" != "" 
end

