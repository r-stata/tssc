*! 1.1.1 NJC 10 December 2012
*! 1.1.0 NJC 3 December 2012
*! 1.0.0 NJC 12 March 2010 
program zmap, sort 
	version 8   
	syntax varlist(numeric min=3 max=3) [if] [in], /// 
	[ PCTiles(numlist min=1 >0 <100) ///
	BReaks(numlist min=1 sort) /// 
	MULTiples MSymbol(str) MColor(str) addplot(str asis) * ]

	// check options 
	if "`pctiles'" != "" & "`breaks'" != "" { 
		di as err "may not specify pctiles() and breaks()" 
		exit 198 
	} 

	// check data 
	marksample touse  
	qui count if `touse' 
	if r(N) == 0 error 2000 

	quietly {
		tokenize "`varlist'" 
		args z y x 

		local zlab : variable label `z'
		if `"`zlab'"' == "" local zlab "`z'" 

		/// default 
		if "`pctiles'`breaks'" == "" { 
			local pctiles 5 10 25 50 75 90 95 
		}

		local nbreaks : word count `pctiles' `breaks' 

		if `nbreaks' <= 8 & "`mcolor'" == "" { 
			if `nbreaks' == 1        local palette gs12 gs4 
			else if `nbreaks' == 2   local palette gs14 gs8 gs2 
			else if `nbreaks' == 3   local palette gs15 gs10 gs5 gs0 
			else if `nbreaks' == 4   local palette gs15 gs12 gs8 gs4 gs0 
			else if `nbreaks' == 5   local palette gs15 gs13 gs10 gs7 gs4 gs1 
			else if `nbreaks' == 6   local palette gs15 gs13 gs11 gs9 gs7 gs5 gs3
			else if `nbreaks' == 7   local palette gs15 gs13 gs11 gs9 gs7 gs5 gs3 gs1 
			else if `nbreaks' == 8   local palette gs15 gs14 gs12 gs10 gs8 gs6 gs4 gs2 gs0 
			local palette mcolor(`palette' `palette') 
		}
		
		local note "breaks `breaks'" 

		if "`pctiles'" != "" { 
			local OK 1 5 10 25 50 75 90 95 99
			local notOK : list pctiles - OK 
			local OK : list pctiles & OK 
		
			if "`OK'" != "" { 
				su `z' if `touse', detail 
				foreach p of local OK { 
					local breaks `breaks' `= r(p`p')' 
				}
			} 

			if "`notOK'" != "" { 
				_pctile `z' if `touse', percentiles(`notOK') 
				local i = 1 
				foreach p of local notOK { 
					local breaks `breaks' `= r(r`i')'  
					local ++i 
				} 
			} 

			local note "percentile breaks `pctiles'%" 
			numlist "`breaks'", sort 
			local breaks `r(numlist)' 
		} 

		local allint = 1 
		foreach b of local breaks { 
			if `b' != ceil(`b') local allint 0 
		} 

		local bprev : word 1 of `breaks' 
		local breaks : list breaks - bprev 
		local breaks `breaks' . 

		if "`format'" == "" { 
			local fmt : format `z' 
		}
		else local fmt `format' 

		if "`multiples'" == "" { 
			tempvar y1 
			gen `y1' = `y' if `z' < `bprev'
			local Z = cond(`allint', "`bprev'", trim("`: di %4.3f `bprev''")) 
			label var `y1' "-`Z'" 
			local Y `y1'  
			local i = 2

			if "`msymbol'" == "" {  
				tempvar copy1 
				gen byte `copy1' = . 
				label var `copy1' "- `Z'" 
				local COPY `copy1' 
				local P p 
				local S S
			} 
				
			foreach b of local breaks { 
				tempvar y`i'  
				gen `y`i'' = `y' if `z' >= `bprev' & `z' < `b'
				local Y `Y' `y`i'' 
				local Z1 = cond(`allint', "`bprev'", trim("`: di %4.3f `bprev''"))
				local Z2 = cond(`allint', "`b'", trim("`: di %4.3f `b''"))
				if "`b'" == "." local Z2 
				label var `y`i'' "`Z1' - `Z2'" 

				if "`msymbol'" == "" { 
					tempvar copy`i' 
					gen byte `copy`i'' = . 
					label var `copy`i'' "`Z1' - `Z2'" 
					local COPY `COPY' `copy`i'' 
					local P `P' p 
					local S `S' S 
				} 

				local bprev `b' 
				local ++i 
			} 
			
			if "`msymbol'" == "" { 
				local ny : word count `Y' 
				local ny1 = `ny' + 1 
				local ny2 = 2 * `ny' 
				numlist "`ny1'/`ny2'"	
				local order order(`r(numlist)') 
				local msymbol `P' `S' 
			}

			if "`mcolor'" != "" { 
				local palette mcolor(`mcolor' `mcolor') 
			} 
			
			noisily scatter `Y' `COPY' `x' if `touse' /// 
			, ysc(off) xsc(off) ti(`"`zlab'"') ms(`msymbol') `palette' /// 
			legend(`order' col(1) pos(3)) plotregion(style(none)) note(`note') `options' ///
                        || `addplot' 

		} 
		else { 
			tempvar g
			gen byte `g' = 1 if `z' < `bprev' 
			local i = 2 
			local Z = cond(`allint', "`bprev'", trim("`: di %4.3f `b''"))
			local G 1 "-`bprev'" 
			
			foreach b of local breaks { 
				replace `g' = `i' if `z' >= `bprev' & `z' < `b'
				local Z1 = cond(`allint', "`bprev'", trim("`: di %4.3f `bprev''"))
				local Z2 = cond(`allint', "`b'", trim("`: di %4.3f `b''"))
				if "`b'" == "." local Z2 
				local G `G' `i' "`Z1' - `Z2'" 
				local bprev `b' 
				local ++i 
			}
			
			tempname gname 
			label def `gname' `G'                                                                      
			label val `g' `gname' 

			if "`mcolor'" == "" local mcolor "gs4" 

			noisily scatter `y' `x' if `touse' /// 
			, by(`g',  ti(`"`zlab'"') compact note(`note')) ///
			yla(none) xla(none) ms(p) mcolor(`mcolor') legend(off) plotregion(style(none)) `options' ///
			|| `addplot' 
		} 
	}
end

