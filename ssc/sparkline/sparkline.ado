*! 1.1.1 NJC 24 March 2013 
*! 1.1.0 NJC 19 February 2013 
* 1.0.0 NJC 21 January 2013 
program sparkline
	version 9.2
	syntax varlist(numeric min=2) [if] [in]              ///
	[,                                                   ///
	over(varname) by(str asis)                           ///
        Height(real 0.7)                                     ///
        Format(str)                                          /// 
	LIMits(numlist min=2 max=2 sort)                     /// 
	EXTremes EXTremes2(str asis)                         ///
        extremeslabel extremeslabel2(str asis)               /// 
	flipy                                                /// 
        VERTical                                             /// 
        variablelabels * ] 

	// variables to use 
	tokenize `varlist' 
	local nvars : word count `varlist' 
	local x "``nvars''" 
	local xtitle : var label `x' 
	if `"`xtitle'"' == "" local xtitle "`x'" 
	local varlist : list varlist - x 
	local nvars = `nvars' - 1 
	local nshow = `nvars' 
		
	if `nvars' > 1 & "`over'" != "" { 
		di as err "over() may not be combined with more than one variable"
		exit 198
	}	
		
	if `"`by'"' != "" { 
		gettoken by opts : by, parse(",") 
		gettoken comma opts : opts, parse(",") 
	}

	// observations to use 
	if `nvars' == 1 marksample touse
	else marksample touse, novarlist 

	if "`by'`over'" != "" markout `touse' `by' `over', strok 

	qui count if `touse' 
	if r(N) == 0 error 2000 
	
	// settings 
	// 2.2 squeezes axis labels together a little 
	if "`vertical'" == "" local halfht = `height'/2.2 
	else local halfht = `height'/2 
	
	if "`format'" == "" local format : format `1'
		
	// variables for plot: cases 1-2 
	quietly {
		tempvar yshow flag   
		preserve
		keep if `touse' 

	// 1. several variables are stacked into one

	if `nvars' > 1 { 
		if "`variablelabels'" != "" { 
			forval i = 1/`nvars' { 
				local l : variable label ``i''
				local labels `"`labels' `i' `"`l'"'"'
			}
		} 	
		else forval i = 1/`nvars' {
               		local labels "`labels'`i' ``i'' "
	        }
			
		if "`by'" != "" { 
			local bylbl : value label `by' 
			if "`bylbl'" != "" { 
				tempfile bylabel 
				label save `bylbl' using `bylabel' 
			}
		}
		
		tempvar data   
		foreach v of local varlist { 
			local stacklist "`stacklist' `v' `by' `x'" 
		}	
		stack `stacklist', into(`data' `by' `x') clear
		drop if missing(`data') 
		label var _stack " " 

		if "`bylbl'" != "" { 
			do `bylabel' 
			label val `by' `bylbl' 
		}
		
		su _stack, meanonly 
		local range "`r(min)'/`r(max)'" 

		if "`limits'" != "" { 
			tokenize "`limits'" 
			args min max 
		} 
		else { 
			local min `data'[1] 
			local max `data'[_N] 
		} 

		sort `by' _stack `data' 
		by `by' _stack (`data') : gen `yshow' = (`data' - `min') / (`max' -`min') - 0.5 
		replace `yshow' = _stack + `height' * `yshow' if `yshow' < .   

		by `by' _stack: gen byte `flag' = cond(`data' == `data'[1], 4, 10 * (`data' == `data'[_N]))

		if "`by'" == "" { 
			if "`limits'" != "" { 
				forval j = `range' {
		                       	local y1 = `j' - `halfht' 
					local y2 = `j' + `halfht' 
					local yla2 `yla2' `y1' "`min'" `y2' "`max'" 
				}
			}
			else { 
				forval j = `range' { 
					su `data' if _stack == `j', meanonly 
					local min : di `format' r(min) 
					local max : di `format' r(max) 
                               		local y1 = `j' - `halfht' 
					local y2 = `j' + `halfht' 
					local yla2 `yla2' `y1' "`min'" `y2' "`max'" 
				} 
			} 
		} 
		else local yla2 "none" 
			
		tempname stlbl
		label def `stlbl' `labels' 
	        label val `yshow' `stlbl'
		sort `by' _stack `x' 
		local over "_stack" 
	}
	// 2. one variable 
	else {
		if "`by'" == "" { 
			local stitle `"`: var label `varlist''"' 
			if `"`stitle'"' == "" local stitle `varlist' 
			local stitle subtitle(`stitle') 
		} 

		if "`over'" == "" {
			// 2.1 a single variable, no over()
			clonevar `yshow' = `varlist'
			
			su `yshow', meanonly 
			if "`by'" != "" {  
				bysort `by' (`yshow') : gen byte `flag' = cond(`yshow' == `yshow'[1], 4, 10 * (`yshow' == `yshow'[_N]))   
			}
			else gen byte `flag' = cond(`varlist' == r(min), 4, 10 * (`varlist' == r(max)))
						 
			sort `by' `x' 

			local range "none" 
			if "`limits'" != "" { 
				tokenize "`limits'" 
				args min max 
			} 
			else { 
				local min : di `format' r(min)
				local max : di `format' r(max)
			} 

			local yla2 `min' `max' 
			local over "`touse'" 
			label var `over' " "
		}
		else {
			// 2.2 a single variable with over()
			capture confirm numeric variable `over'
			if _rc == 7 {
				encode `over', gen(`yshow')
			}	
			else { 
				gen `yshow' = `over' 
				label val `yshow' `: value label `over'' 
			} 	
			_crcslbl `yshow' `over' 

			capture levelsof `yshow' 
			if _rc { 
				su `yshow', meanonly 
				numlist "`r(min)'/`r(max)'" 
				local range "`r(numlist)'" 
			} 
			else local range "`r(levels)'" 

			local nshow : word count `range' 

			tempvar work 
			local data "`varlist'" 
			sort `by' `yshow' `data' 

			if "`limits'" != "" { 
				tokenize "`limits'" 
				args min max 
			} 
			else { 
				local min `data'[1] 
				local max `data'[_N] 
			} 

			by `by' `yshow' (`data') : gen `work' = (`data' - `min') / (`max' -`min') - 0.5 
			by `by' `yshow' : gen byte `flag' = cond(`data' == `data'[1], 4, 10 * (`data' == `data'[_N]))

			if "`limits'" != "" { 
				foreach j of local range {
		                       	local y1 = `j' - `halfht' 
					local y2 = `j' + `halfht' 
					local yla2 `yla2' `y1' "`min'" `y2' "`max'" 
				}
			}
			else { 
				foreach j of local range { 
					su `data' if `yshow' == `j', meanonly 
	                                local y1 = `j' - `halfht' 
					local y2 = `j' + `halfht' 
					local min : di `format' r(min)
					local max : di `format' r(max)
					local yla2 `yla2' `y1' "`min'" `y2' "`max'" 
				} 
			} 

			replace `yshow' = `yshow' + `height' * `work' if `work' < . 
			sort `by' `over' `x' 
		}
	}	
	} // end quietly 

	// plot details
	quietly { 
		tab `over' 
	         
		if r(r) > 1 { 	
			if "`vertical'" != "" { 
				separate `x', by(`over') veryshortlabel 
				local xshow `r(varlist)' 
			}	
			else { 
				separate `yshow', by(`over') veryshortlabel 
				local yshow `r(varlist)' 
			}
		}
		else local xshow "`x'" 
	} 	
	
	if "`extremes'`extremes2'" != "" { 
		if "`vertical'" != "" { 
			local call scatter `xshow' `yshow' if `flag', ms(O ..) `extremes2' 
			local nx : word count `xshow' 
			local marg : di _dup(`nx') "`data' " 
			if "`extremeslabel'`extremeslabel2'" != "" { 
				local call `call' mla(`marg') mlabvpos(`flag') `extremeslabel2'
			}  
		}
		else { 
			local call scatter `yshow' `x' if `flag', ms(O ..) `extremes2' 
			local ny : word count `yshow' 
			local marg : di _dup(`ny') "`data' " 
			if "`extremeslabel'`extremeslabel2'" != "" { 
				local call `call' mla(`marg') mlabvpos(`flag') `extremeslabel2'
			}  
		}	
	}  
	
	if "`over'" == "" | "`by'" != "" { 
		if `nvars' == 1 { 
			local axtitle `: var label `varlist'' 
			if `"`axtitle'"' == "" local axtitle "`varlist'" 
		} 
		else local axtitle `" "' 
	}
	else { 
		local axtitle : variable label `over' 
		if `"`axtitle'"' == "" local axtitle "`over'" 
	} 	

	if "`by'" != "" {
		local byby "by(`by', noiytic legend(off) `opts')" 
	}

	if `nshow' <= 3 local factor = 0.8
	else if `nshow' <= 10 local factor = 0.6 
	else local factor = 0.5 

	local y1 = cond("`flipy'" == "", 1, 2) 
	local y2 = cond("`flipy'" == "", 2, 1) 

	if "`vertical'" != "" { 
		line `xshow' `yshow',                                                  ///
		ytitle(`"`xtitle'"') yla(, ang(h))                                     ///
	        xaxis(1 2)                                                             /// 
		xla(`yla2', ang(h) axis(`y2') labsize(*`factor') labgap(*0.7) noticks) ///
		xti(`"`axtitle'"', axis(`y1')) xti("", axis(`y2'))                     ///
	        xla(`range', axis(`y1') val ang(h) noticks) `byby'                     ///
		lc(gs8 ..) legend(off) `stitle' `options'                              /// 
		|| `call'  
		// blank 
		exit 0 
	} 

	line `yshow' `x',                                                      ///
	xtitle(`"`xtitle'"')                                                   /// 
        yaxis(1 2)                                                             ///
	yla(`yla2', ang(h) axis(`y2') labsize(*`factor') labgap(*0.7) noticks) ///
	yti(`"`axtitle'"', axis(`y1')) yti(" ", axis(`y2'))                    ///
        yla(`range', axis(`y1') val ang(h) noticks) `byby'                     ///
	lc(gs8 ..) legend(off) `stitle' `options'                              /// 
	|| `call'  
	// blank 
end 
	
