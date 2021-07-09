*! 2.0.2 NJC 28 November 2005
* 2.0.1 NJC 27 June 2005
* 2.0.0 NJC 25 May 2005
* 1.0.0 NJC 19 December 2004
program beamplot, sort  
	version 9   
	syntax varlist(min=1 numeric) [if] [in]              ///
	[, VERTical Height(real 0.6) Width(numlist max=1 >0) ///
	floor CEILing                                        ///
	Over(varname) by(str asis)  variablelabels           ///
	SUmmary(str)                                         ///
	dots(str asis) beam(str asis) fulcrum(str asis)      ///
	addplot(str asis)  * ] 

	// error checking 
	if "`vertical'" != "" { 
		di as err "vertical not supported" 
		exit 198 
	}

	if "`floor'" != "" & "`ceiling'" != "" { 
		di as err "must choose between floor and ceiling"
		exit 198 
	}	
	
	tokenize `varlist' 
	local nvars : word count `varlist' 
	
	if `nvars' > 1 & "`over'" != "" { 
		di as err ///
		"over() may not be combined with more than one variable"
		exit 198
	}	
	
	if `"`by'"' != "" { 
		gettoken by opts : by, parse(",") 
		gettoken comma opts : opts, parse(",") 
		if "`over'" == "" & `nvars' == 1 { 
			local byby "by(`by', noiyla noiytic legend(off) `opts')"
		}
		else local byby "by(`by', noiytic legend(off) `opts')" 
	}	

	marksample touse, novarlist 
	if "`by'" != "" { 
		markout `touse' `by', strok 
	}
	qui count if `touse' 
	if r(N) == 0 error 2000 

	if "`summary'" != "" { 
		capture findfile _g`summary'.ado 
		if _rc { 
			di as err "egen function `summary'() not found" 
			exit 498 
		}
	}	
	else local summary "mean" 

	// variables for plot 
	tempvar mean min max yshow yshow2 yshow3
	
	// several variables are stacked into one 
	// x axis shows `data' 
	// y axis shows `yshow' 
	qui if `nvars' > 1 { 
		tempvar data 
		preserve
		local i = 1 
		
		if "`variablelabels'" != "" { 
			foreach v of local varlist { 
				local l : variable label `v'
				local labels `"`labels'`i++' `"`l'"' "'
			}
		} 	
		else foreach v of local varlist {
			local labels "`labels'`i++' `v' "
		}

		if "`by'" != "" { 
			local bylbl : value label `by' 
			if "`bylbl'" != "" { 
				tempfile bylabel 
				label save `bylbl' using `bylabel' 
			}
		}	

		foreach v of local varlist { 
			local stacklist "`stacklist' `v' `by'" 
		}	
		stack `stacklist' if `touse', into(`data' `by') clear
		drop if missing(`data') 
		label var `data' "`varlist'"
		label var _stack `" "' 

		if "`bylbl'" != "" { 
			do `bylabel' 
			label val `by' `bylbl' 
		}	
		
		su _stack, meanonly
		local Range "`r(min)'/`r(max)'" 

		if "`width'" != "" {
			if "`floor'" != "" {
				replace `data' = `width' * floor(`data'/`width')
			}
			else if "`ceiling'" != "" { 
				replace `data' = `width' * ceil(`data'/`width')
			}	
			else replace `data' = round(`data', `width') 
		}	
		egen `mean' = `summary'(`data'), by(`by' _stack)
		egen `min' = min(`data'), by(`by' _stack)
		egen `max' = max(`data'), by(`by' _stack)
		
		sort `by' _stack `data', stable 
		by `by' _stack `data' : gen `yshow' = _n - 1  
		su `yshow', meanonly
		if r(max) > 0 { 
			replace `yshow' = _stack + `height' * `yshow' / r(max) 
		}
		else replace `yshow' = _stack  
		
		tempname stlbl
		label def `stlbl' `labels' 
		label val `yshow' `stlbl'

		su `yshow', meanonly 
		local range = r(max) - r(min) 
		gen `yshow2' = _stack - 0.01 * `range' 
		gen `yshow3' = _stack - 0.02 * `range'  
	}	
	// one variable
	// two cases: without and with -over()- 
	else qui {
		if "`over'" == "" {
			// a single variable, no over()
			// x axis shows `varlist' 
			// y axis shows `over' = 1  
			
			tempvar over
			gen byte `over' = 1 if `touse'
			
			local axlabel ", nolabels" 
			local yaxtitle `" "' 
			
			tempname overlbl 
			label def `overlbl' 1 "`varlist'"
			label val `over' `overlbl' 
		}
		else {
			// a single variable, with over()
			// x axis shows `varlist' 
			// y axis shows `yshow'
			
			tempvar over2
			capture confirm numeric variable `over'
			if _rc == 7 encode `over' if `touse', gen(`over2')
			else { 
				gen `over2' = `over' if `touse'
				label val `over2' `: value label `over'' 
			} 	
			_crcslbl `over2' `over' 
			local over "`over2'"

			capture levelsof `over' 
			if _rc { 
				su `over', meanonly 
				local Range "`r(min)'/`r(max)'" 
			} 
			else local Range "`r(levels)'" 
		}	
		
		if "`width'" != "" { 
			tempvar clone 
			clonevar `clone' = `varlist' 
			if `"`: variable label `varlist''"' == "" { 
				label var `clone' "`varlist'"
			}	
			
			if "`floor'" != "" {
				replace `clone' = `width' * floor(`clone'/`width')
			}
			else if "`ceiling'" != "" { 
				replace `clone' = `width' * ceil(`clone'/`width')
			}	
			else replace `clone' = round(`clone', `width') 
			
			local varlist "`clone'"
		} 
		
		tempvar count 
		sort `touse' `by' `over' `varlist', stable 
		by `touse' `by' `over' `varlist': gen `yshow' = _n - 1 
		su `yshow' if `touse', meanonly
		if r(max) > 0 { 
			replace `yshow' = `over' + `height' * `yshow' / r(max) 
		} 
		else replace `yshow' = `over' 
		_crcslbl `yshow' `over'
		label val `yshow' `: value label `over'' 
		
		egen `mean' = `summary'(`varlist'), by(`by' `over') 
		egen `min' = min(`varlist'), by(`by' `over') 
		egen `max' = max(`varlist'), by(`by' `over') 

		su `yshow', meanonly 
		local range = r(max) - r(min) 
		gen `yshow2' = `over' - 0.01 * `range'
		gen `yshow3' = `over' - 0.02 * `range'  
		
		local gif "if `touse'" 
	} 
		
	// plot details 
	local margin = cond(r(max) == r(min), 0.1, 0.05 * (r(max) - r(min)))
	local stretch "r(`= r(min) - `margin'' `= r(max) + `margin'')" 
	local stretch "ysc(`stretch')" 

	if `"`axlabel'"' == "" local axlabel "`Range', ang(h) valuelabel" 
	
	if `"`yaxtitle'"' == "" & "`over'" != "" { 
		local yaxtitle : variable label `over' 
		if `"`yaxtitle'"' == "" local yaxtitle "`over'" 
	} 	

	if `nvars' == 1 { 
		local xaxtitle `"`: variable label `varlist''"' 
	} 	
	if `"`xaxtitle'"' == "" local xaxtitle "`varlist'" 

	local xshow = cond("`over'" != "", "`varlist'", "`data'") 
	
	// graph 
	scatter `yshow' `xshow' `gif',                  ///
	ms(O) yti(`"`yaxtitle'"') xti(`"`xaxtitle'"')   /// 
	yla(`axlabel' nogrid notick) `stretch' `dots'   /// 
	                                                ///
	|| pcarrow `yshow3' `mean' `yshow2' `mean',     ///
	msize(medlarge) barbsize(medlarge) `fulcrum'    ///
	                                                ///
	|| rspike `min' `max' `yshow2', hori `beam'     /// 
	legend(off) `byby' `options'                    ///
	                                                ///
	|| `addplot' 
	// blank 
	 	
end 	

