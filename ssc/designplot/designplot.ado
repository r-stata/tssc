*! 1.1.0 NJC 10 July 2014 
*! 1.0.0 NJC 13 May 2014 
program designplot 
	version 8.2 

	syntax varlist(min=2) [if] [in] [aweight fweight]               ///
	[, ///
	STATistics(str)              ///
	MISSing                      /// 
	prefix(str)                  /// 
	saveresults(str asis)        /// 
	MINway(numlist >=0 max=1)    /// 
	MAXway(numlist >=0 max=1)    /// 
	recast(str)                  ///
	variablelabels               ///
	variablenames                ///
 	alllabel(str)                ///
	entryopts(str asis)          ///
	groupopts(str asis) * ]

	quietly { 
		if "`recast'" != "" { 
			if !inlist("`recast'", "bar", "hbar", "dot") {
				di as err "recast(bar) or recast(hbar) allowed"
				exit 198 
			}
		} 
		else local recast "dot" 

		if "`minway'" != "" & "`maxway'" != "" { 
			if `minway' > `maxway' { 
				di as err ///
		"minway(`minway') and maxway(`maxway') are inconsistent" 
				exit 198 
			}
		}

		if "`variablenames'" != "" & "`variablelabels'" != "" { 
			di as err ///
		"must choose between variablenames and variablelabels options" 
			exit 198 
		}

		local vl = "`variablelabels'" != "" 
		local vn = "`variablenames'" != "" 
	
		gettoken y X : varlist 
		confirm numeric variable `y'
		 
		marksample touse, strok  

		count if `touse' 
		if r(N) == 0 error 2000 

		if "`statistics'" == "" local statistics "mean" 

		local how = 1 
		local s1 N sum sum_w mean min max 
		local s2 sd Var 
		local s3 skewness kurtosis p1 p5 p10 p25 p50 p75 p90 p95 p99 

		local nobs `prefix'_nobs=r(N) 
		local j = 1 
		foreach s of local statistics { 
			local OK 0 
			synonym `s' 
			if "`s'" == "N" local nobs  

			forval i = 1/3 { 
				if `: list s in s`i'' { 
					local OK 1 
					local how = max(`i', `how') 
					continue, break 
				} 
			}
	
			if !`OK' { 
				di as err "`s' not allowed as statistic" 
				exit 198 
			}
			
			local res `prefix'_stat`j'
			local call `call' `res'=r(`s') 
			local results `results' `res' 
			local ++j 
		} 	

		local how : word `how' of "meanonly" " " "detail" 
		
		local ylbl : var label `y' 
		if `"`ylbl'"' == "" local ylbl "`y'" 

		local filename `c(filename)' 
		local filedate `c(filedate)' 
	
		preserve 
		statsby `nobs' `call', by(`X') subsets clear : ///
			su `y' [`weight' `exp'] if `touse', `how'  

		tempvar label  
		
		local way `prefix'_way 
		local entry `prefix'_entry 
		local group `prefix'_group 
		
		gen `way' = 0 
		gen `label' = "" 
		gen `group' = "" 
		local space cond(!missing(`label'), "  ", "")

		foreach x of local X { 
			replace `way' = `way' + !missing(`x') 
			replace `group' = `group' + string(!missing(`x')) 

			if "`: value label `x''" != "" { 
				decode `x', gen(`entry') 
				replace `label' = /// 
			`label' + `space' + `entry' if !missing(`entry') 
				// some values might be unlabelled! 
				replace `label' = ///
			`label' + `space' + string(`x') if missing(`entry') & `x' < . 
				drop `entry' 
			} 
 			else { 
				capture confirm string variable `x' 
				if _rc { 
					replace `label' = ///
			`label' + `space' +  string(`x') if !missing(`x') 
				} 
				else replace `label' = ///
			`label' + `space' + `x' if !missing(`x') 
			}
		} 

		if "`maxway'" != "" keep if `way' <= `maxway' 
		if "`minway'" != "" keep if `way' >= `minway' 

		gsort `way' -`group' `X'  
		gen `entry' = sum(`group' != `group'[_n-1]) 
		drop `group' 
		egen `group' = group(`way' `entry') 
		label var `group' 

	  	su `group', meanonly 
		local j = 1 
		tokenize "`X'"

		forval i = 1/`r(max)' { 
			local lbl "`=char(160)'" 
			if (`vl' | `vn') & "``j''" != "" { 
				su `way' if `group' == `i', meanonly 
				if r(min) == 1 { 
					if `vn' local lbl "``j''" 
					else {
						local lbl : var label ``j'' 
						if `"`lbl'"' == "" local lbl "``j''" 
					}
					local ++j 
				}
			}
			label def _blabel `i' "`lbl'", modify 
		}
		label val `group' _blabel  

		if "`alllabel'" == "" local alllabel "(all)" 
		replace `label' = `"`alllabel'"' if missing(`label') 
		replace `entry' = _n 
		forval i = 1/`=_N' { 
			label def _elabel  `i' "`=`label'[`i']'", modify 
		} 
		label val `entry' _elabel 
		drop `label'  
	}

	tokenize "`statistics'" 
	local j = 0 
	foreach r of local results { 
		label var `r' "``++j''" 
	}
	if "`nobs'" != "" label var `prefix'_nobs "number of observations" 

	if "`recast'" == "dot" { 
		local myopts ///
		marker(1, ms(Oh))   ///
		marker(2, ms(+))    ///
		marker(3, ms(X))    ///
		marker(4, ms(Th))   ///
		marker(5, ms(Dh))   ///
		marker(6, ms(Sh))   ///
		linetype(line) lines(lcolor(gs12) lw(vthin)) 
	}

	graph `recast' (asis) `results', `myopts' ///
	over(`entry', `entryopts') over(`group', `groupopts') nofill ///
	t1title(`ylbl') `options' 

	if `"`saveresults'"' != "" { 
		quietly { 
			notes : designplot `0' 
			notes : `filename' 
			notes : `filedate' 
			notes : `ylbl' 
		} 
		save `saveresults' 
	}
end 
			
program synonym 
	local s "`1'" 

	if "`s'" == "n"            c_local s "N" 
	else if "`s'" == "count"   c_local s "N" 
	else if "`s'" == substr("frequency", 1, length("`s'")) c_local s "N" 
	else if "`s'" == "minimum"  c_local s "min" 
	else if "`s'" == "maximum"  c_local s "max" 
	else if "`s'" == "total"    c_local s "sum" 
	else if "`s'" == "median"   c_local s "p50"
	else if "`s'" == "SD"       c_local s "sd" 
	else if "`s'" == substr("variance", 1, length("`s'")) c_local s "Var" 
	else if "`s'" == substr("Variance", 1, length("`s'")) c_local s "Var" 
	else if "`s'" == "skew"     c_local s "skewness"
	else if "`s'" == "kurt"     c_local s "kurtosis"
end 

