*! statplot - plots of summary statistics
*! 1.2.7  Eric A. Booth and Nicholas J. Cox 5 May 2011
* 1.2.6  Eric A. Booth and Nicholas J. Cox 25 April 2011   **put in check that recast opt was hbar, bar, or dot only
* 1.2.5  Eric A. Booth and Nicholas J. Cox 25 March 2011    ** added single quotes to macros in -if- loops to avoid error when by() or over() options contained suboptions with double quotes
* 1.2.4  Eric A. Booth and Nicholas J. Cox 24 February 2011

program statplot
	version 8.2
	syntax varlist(numeric) [if] [in] ///
	[aweight fweight iweight pweight] /// 
	[, MISSing Statistic(str asis) OVER1(str asis) OVER2(str asis)  ///
	xpose recast(str) varnames varopts(str asis) BY(str asis) *]

	/// The user doesn't get told about the different names -over1()- and -over2()-. 
	/// Two different options have the same allowed abbreviation, but Stata takes them 
	/// in the order given. 

	marksample touse, novarlist 

	if `"`over1'"' != "" { 
		gettoken by1var by1opts: over1, parse(",") 
		if `"`missing'"' == "" { 
			markout `touse' `by1var', strok 
		}
	}

	if `"`over2'"' != "" { 
		gettoken by2var by2opts: over2, parse(",") 
		if `"`missing'"' == "" { 
			markout `touse' `by2var', strok 
		} 
	}

	if `"`by'"' != "" { 
		gettoken by3var by3opts: by, parse(",") 
		if "`missing'" == "" { 
			markout `touse' `by3var', strok 
		} 
		loc over3 "`by'"   //over3 is a by() option
	}

	qui count if `touse'
	if r(N) == 0 error 2000

	preserve
	qui keep if `touse' 

	/// varlist labels
	local nvars : word count `varlist'
	local i = 1
	foreach v of local varlist {
		if "`varnames'" == "" local label`i' : var label `v'
		if `"`label`i''"' == "" local label`i' "`v'"
		local ++i
	}

	/// -over?()- variables if given 
	/// using -egen, group()- allows uniform treatment of numeric 
	/// and string variables 

	forval n = 1/3 {
		if `"`over`n''"' != "" { 
			tempvar myby`n' 
			egen `myby`n'' = group(`by`n'var'), label `missing'  
			su `myby`n'', meanonly 
			local by`n'max = r(max)
	
			forval i = 1/`by`n'max' { 
				local by`n'label`i' `"`: label (`myby`n'') `i''"' 
			}
			
			local by`n'label : var label `by`n'var' 
			if `"`by`n'label'"' == "" local by`n'label `by`n'var' 
		}
	}

	if `"`over1'`over2'`over3'"' != "" { 
		local byby "by(`myby1' `myby2' `myby3')"
	}
			
	/// -collapse-; restructure as needed 
	if `"`statistic'"' == "" local statistic mean 
	collapse (`statistic') `varlist' if `touse' [`weight' `exp'],  `byby'

	if `"`recast'"' == "" local recast "hbar"	
		**check recast opt**
			if !inlist(`"`recast'"', "hbar", "bar", "dot") {
				di as err `"recast option must be: hbar, bar, or dot"'
				exit 198
					}
							 
	tempname what 
	tempvar which 
	
	// no over() or by() options called
	if `"`by1var'`by2var'`by3var'"' == "" { 
		xpose, clear

		/// varlist labels
		g `which' = _n
		forval i = 1/`nvars' {
			label def `what' `i' `"`label`i''"', modify
		}
		label val `which' `what'

		/// graph                                 
		graph `recast' v1,  ///
			over(`which', `varopts') ///
			yti("`statistic'") `options'  
	} 
	
	// over() and/or by() options called
	else { 
		if `nvars' > 1 { 
			foreach v of local varlist { 
				local call `call' `myby1' `myby2' `myby3' `v' 
			}
		 
			stack `call', into(`myby1' `myby2' `myby3' `which') clear 
		} 
		else { 
			gen _stack = 1 
			local which `varlist'
		} 

		/// varlist labels 
		forval i = 1/`nvars' { 
			label def `what' `i' `"`label`i''"', modify 
			local ++i 
		} 
		label val _stack `what' 

		forval n = 1/3 {
			if "`myby`n''" != "" { 
				tempname by`n'labels 
				forval i = 1/`by`n'max' { 
					label def `by`n'labels' `i' `"`by`n'label`i''"', modify 
				} 
				label val `myby`n'' `by`n'labels' 
				label var `myby`n'' `"`by`n'label'"'  	
				if `n'==1  loc OVER1 over(`myby1' `by1opts') 
				else if `n'==2  loc OVER2 over(`myby2' `by2opts') 
				else if `n'==3  loc BY by(`myby3' `by3opts') 
			} 
		}
		
		if `"`xpose'"'  == "" { 
			local overs `OVER1'  `OVER2' `BY' over(_stack, `varopts') 
		}
		else local overs over(_stack, `varopts') `OVER1'  `OVER2' `BY'

		/// graph 
		graph `recast' `which', `overs' ///
			yti("`statistic'") `options'  
	}
end
