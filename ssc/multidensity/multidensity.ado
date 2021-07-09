*! 1.0.0 NJC 9 July 2020
program multidensity
	version 8 

	gettoken cmd 0 : 0, parse(" ,")  
	local cmd = lower("`cmd'") 

	if "`cmd'" == substr("generate", 1, length("`cmd'")) { 
		_generate `0' 
	} 
	else if "`cmd'" == substr("juxta", 1, length("`cmd'")) { 
		_juxta `0' 
	} 
	else if "`cmd'" == substr("super", 1, length("`cmd'")) { 
		_super `0' 
	}
	else if "`cmd'" == substr("bystyle", 1, length("`cmd'")) { 
		_bystyle `0' 
	}
	else if "`cmd'" == "clear" { 
		_clear `0' 
	} 
	else error 198 
end 
 
program _generate 
	version 8

	// check syntax 
	local opts fstub(str) xstub(str) n(int -1) ///
	MINimum(numlist min=1 max=1) MAXimum(numlist min=1 max=1) /// 
	BWidth(numlist >0) Kernel(str) area(passthru) trans(str)  ///
	labelwith(str) densitylabel(str)  

	capture syntax varlist(numeric max=1) [if] [in] [fweight aweight], ///
	by(varname) [ MISSing `opts'] 

	quietly if _rc == 0 { 
		marksample touse 
		if "`missing'" == "" markout `touse' `by', strok  

		count if `touse' 
		if r(N) == 0 error 2000 
		if r(N) == 1 error 2001

		tempname stub 
		separate `varlist' if `touse', generate(`stub') by(`by') veryshortlabel 
		local varlist `r(varlist)' 
	} 
	else { 
		syntax varlist(numeric) [if] [in] [fweight aweight] [, `opts' ] 
		marksample touse
 
		quietly count if `touse' 
		if r(N) == 0 error 2000 
		if r(N) == 1 error 2001
	}

	if `n' == -1 local n = min(_N, 100)  
	else if `n' > _N { 
		di "{p}`n' exceeds the number of observations" _N "; reset to " _N{p_end}" 
		local n = _N 
	}

	// warm up for loop over variables 
	local j = 0 

	if "`fstub'" == "" local fstub _density 
	if "`xstub'" == "" local xstub _x

	// a single kernel, or bandwidth, or transformation will be 
	// repeated for all variables 
	local nvars : word count `varlist' 

	if "`kernel'" != "" { 
		local nk : word count `kernel' 
		if `nk' == 1 local kernel : di  _dup(`nvars') "`kernel' " 
		if `nk' > 1 & `nvars' == 1 { 
			local varlist : di _dup(`nk') "`varlist' " 
			local nvars : word count `varlist' 
		} 
	}

	if "`bwidth'" != "" { 
		local nw : word count `bwidth' 
		if `nw' == 1 local bwidth : di _dup(`nvars') "`bwidth' "
 		if `nw' > 1 & `nvars' == 1 { 
			local varlist : di _dup(`nw') "`varlist' " 
			local nvars : word count `varlist' 
		} 
	}

	if "`trans'" != "" { 
		CheckTrans `trans'  
		local nt : word count `trans' 
		if `nt' == 1 local trans : di _dup(`nvars') "`trans' "
 		if `nt' > 1 & `nvars' == 1 { 
			local varlist : di _dup(`nt') "`varlist' " 
			local nvars : word count `varlist' 
		} 
	} 

	// now the loop over variables 
	foreach v of local varlist { 
		local ++j

		// safe copy 
		local orig `v' 

		// kernel and bandwidth 
		if "`kernel'" != "" { 
			local k : word `j' of `kernel' 
			local ke "kernel(`k')" 
		} 

		if "`bwidth'" != "" { 
			local w : word `j' of `bwidth'
			local bw "bw(`w')" 
		}

		// transformation -- if there is one 
		quietly if "`trans'" != "" { 
			local T : word `j' of `trans'

			if inlist("`T'", "@", "identity") { 
				local T identity 
			}
			else tempvar w
 
 			if inlist("`T'", "log", "ln") { 
				count if `v' <= 0 & `touse' 
				if r(N) > 0  { 
					di as err "logarithmic transformation invalid: " plural(r(N), "observation") " <= 0" 
					exit 498 
				} 
				gen double `w' = ln(`v')
				local T log  
			} 
			else if inlist("`T'", "root", "square_root", "1/2") { 
				count if `v' < 0 & `touse' 
				if r(N) > 0 { 
					di as err "root transformation invalid: " plural(r(N), "observation") " < 0"
					exit 498 
				} 
				gen double `w' = sqrt(`v')
				local T root  
			} 
			else if inlist("`T'", "cube_root", "1/3") { 
				gen double `w' = cond(`v' < 0, -(abs(`v')^(1/3)), `v'^(1/3))
				local T cube_root  
			} 
			else if inlist("`T'", "reciprocal", "-1") { 
				count if `v' <= 0 & `touse' 
				if r(N) > 0 { 
					di as err "reciprocal transformation invalid: " plural(r(N), "observation") " <=0" 
					exit 498 
				} 
				gen double `w' = 1/`v'
				local T reciprocal  
			} 
			else if "`T'" == "logit" { 
				count if (`v' <= 0 | `v' >= 1) & `touse'  
				if r(N) > 0 { 
					di as err "logit transformation invalid:" plural(r(N), "observation") " outside (0, 1)" 
					exit 498 
				} 
				gen double `w' = logit(`v') 
			}

			// if there was a transformation, use that version 
			capture confirm var `w' 
			if _rc == 0 { 
				_crcslbl `w' `v'
				local v `w'
			}  
		}
		
		// use sample minimum and maximum, or user-specified extremes if further out 
 		// NB this is on transformed scale if a transformation was used 
		su `v' if `touse', meanonly
		if "`minimum'" != "" local min = min(`minimum', r(min))
		else local min =  r(min)
 		if "`maximum'" != "" local max = max(`maximum', r(max))
		else local max =  r(max)

		// call up kdensity calculation 
		quietly twoway__kdensity_gen `v' if `touse' `weight' `exp',  ///
		range(`min' `max') n(`n') `ke' `bw' `area' ///
		generate(`fstub'`j' `xstub'`j', replace)

		// any transformed version has done its job
		capture drop `w' 

		// if there was a transformation, now finish the job 
		quietly { 
		if "`T'" == "log" { 
			replace `xstub'`j' = exp(`xstub'`j') 
			replace `fstub'`j' = `fstub'`j' / `xstub'`j' 
		}
		else if "`T'" == "cube_root" { 
			replace `xstub'`j' = `xstub'`j'^3 
			replace `fstub'`j' = (1/3) * `fstub'`j' / `xstub'`j'^(2/3) 
		} 
		else if "`T'" == "root" { 
			replace `xstub'`j' = `xstub'`j'^2 
			replace `fstub'`j' = (1/2) * `fstub'`j' / sqrt(`xstub'`j') 
		} 
		else if "`T" == "reciprocal" { 
			replace `xstub'`j' = 1/`xstub'`j' 
			replace `fstub'`j' = `fstub'`j' / `xstub'`j'^2 
		} 
		else if "`T'" == "logit" { 
			replace `xstub'`j' = invlogit(`xstub'`j') 
			replace `fstub'`j' = `fstub'`j' / (`xstub'`j' * (1 - `xstub'`j')) 
		}
		}  
	
		// save characteristics: kernel, bandwidth, transformation (if any) 
		if inlist(substr("`r(kernel)'", 1, 1), "e", "g", "p") { 
			char `fstub'`j'[kernel] "`= proper("`r(kernel)'")'"  
		} 
		else char `fstub'`j'[kernel] "`r(kernel)'"

		char `fstub'`j'[bwidth] "`r(width)'"  

		if "`trans'" != "" { 
			local T : subinstr local T "_" " ", all 
			char `fstub'`j'[trans] "`T'" 
		}
	
		// variable labels are 
		// 	variable labels of original variables 
		//      otherwise variable names if they do not exist 
		// 	otherwise group values if used -by()- option 
		//	otherwise whatever of kernel, bandwidth, transformation, variable information is asked here
		//      -variable- undocumented  
		if "`labelwith'" != "" {
			local label  
			foreach with of local labelwith { 
				local with = lower("`with'") 
				if "`with'" == substr("kernel", 1, length("`with'")) { 
					local label `label' `: char `fstub'`j'[kernel]' 
				}
				else if "`with'" == substr("bwidth", 1, length("`with'")) { 
					local label `label' `: char `fstub'`j'[bwidth]'
				} 
				else if "`with'" == substr("trans", 1, length("`with'")) { 
					local label `label' `: char `fstub'`j'[trans]'
				}
				else if "`with'" == substr("variable", 1, length("`with'")) { 
					if `"`: variable label `fstub'`j''"' != "" { 
						local label `label' `: variable label `fstub'`j'' 
					} 
					else local label `label' `fstub'`j' 
				} 
			}
			label var `xstub'`j' `"`label'"' 
		} 
		else { 
			local label : var label `orig' 
			if `"`label'"' == "" local label `orig' 
			label var `xstub'`j' `"`label'"' 
		}

		// all density variables have variable label "Density" unless overruled 
		if "`densitylabel'" != "" label var `fstub'`j' "`densitylabel'"
		else label var `fstub'`j' "Density" 
	}

	// clean up and show new variables 
	if "`by'" != "" capture drop `stub'* 
	describe `xstub'1-`fstub'`j' 
end 

program _juxta 
	// 20 distinct specifications more than can be requested comfortably 
	forval j = 1/20 { 
		local opts `opts' opt`j'(str asis)  
	}
	syntax [ , fstub(str) xstub(str) optall(str asis) `opts' recast(str) COMBINEopts(str asis) VERTical * ] 

	// check suitable variables are accessible 
	if "`fstub'" == "" local fstub _density 
	if "`xstub'" == "" local xstub _x 

	unab F : `fstub'* 
	local nf : word count `F'
	unab X : `xstub'*
	local nx : word count `X'  

	if `nf' == 0 & `nx' == 0 { 
		di as err "no variables found; run multidensity generate first?" 	
		exit 498 
	} 
	else if `nf' != `nx' { 
		local s1 = plural(`nf', "variable") 
		local s2 = plural(`nx', "variable") 
		di as err "`nf' `s1' found, but `nx' `s2'" 
		exit 498 
	} 

	// recast(area) the most obvious alternative 
	local plot = cond("`recast'" != "", "`recast'", "line") 

	// draw and name individual plots 
	forval j = 1/`nf' { 
		local f : word `j' of `F' 
		local x : word `j' of `X' 
 
		tempname this 
		if "`vertical'" != "" twoway `plot' `x' `f' if `f' > 0,  ///
		nodraw yla(, ang(h)) `optall' `opt`j'' `options' name(`this') 
		else twoway `plot' `f' `x' if `f' > 0 , ///
		nodraw yla(, ang(h)) `optall' `opt`j'' `options' name(`this') 

		local all `all' `this' 
	}

	// combine plots 
	graph combine `all', `combineopts' 
end  

program _super
	// 20 distinct specifications more than can be requested comfortably 
	forval j = 1/20 { 
		local opts `opts' opt`j'(str asis)  
	}
	syntax [ , fstub(str) xstub(str) optall(str asis) `opts' recast(str) VERTical addplot(str asis) * ] 

	// check suitable variables are accessible 
	if "`fstub'" == "" local fstub _density 
	if "`xstub'" == "" local xstub _x 

	unab F : `fstub'* 
	local nf : word count `F'
	unab X : `xstub'*
	local nx : word count `X'  

	if `nf' == 0 & `nx' == 0 { 
		di as err "no variables found; run multidensity generate first?" 		
		exit 498 
	} 
	else if `nf' != `nx' { 
		local s1 = plural(`nf', "variable") 
		local s2 = plural(`nx', "variable") 
		di as err "`nf' `s1' found, but `nx' `s2'" 
		exit 499 
	} 

	// recast(area) the most obvious alternative 
	local plot = cond("`recast'" != "", "`recast'", "line") 

	// write code for each density trace 
	forval j = 1/`nf' { 
		local f : word `j' of `F' 
		local x : word `j' of `X'

		if "`vertical'" != "" { 
			local call `call' || `plot' `x' `f' if `f' > 0, /// 
			`optall' `opt`j''  
		}
		else {   
			local call `call' || `plot' `f' `x' if `f' > 0, ///
			`optall' `opt`j''   
		}		
		local lgnd `lgnd' `j' `"`: var label `x''"' 
 	}  

	// combine plots 
	twoway `call' legend(order(`lgnd')) `options' ///
	|| `addplot' 
end  

program _bystyle 
	syntax [, fstub(str) xstub(str) recast(str) VERTical byopts(str asis) * ] 
	
	// check suitable variables are accessible 
	if "`fstub'" == "" local fstub _density 
	if "`xstub'" == "" local xstub _x

	unab F : `fstub'* 
	local nf : word count `F'
	unab X : `xstub'*
	local nx : word count `X'  

	if `nf' == 0 & `nx' == 0 { 
		di as err "no variables found; run multidensity generate first?" 		
		exit 498 
	} 
	else if `nf' != `nx' { 
		local s1 = plural(`nf', "variable") 
		local s2 = plural(`nx', "variable") 
		di as err "`nf' `s1' found, but `nx' `s2'" 
		exit 499 
	} 

	// need a temporary -reshape- 
	quietly { 
		preserve 
		keep `fstub'* `xstub'*
		keep if `fstub'1 < . 
		tempvar id which 
		gen `id' = _n

		local j = 0 
		foreach v of var `xstub'* { 
			local ++j 
			local lbl`j' : var label `xstub'`j'
		}

		reshape long `xstub' `fstub', i(`id') j(`which')

		forval k = 1/`j' { 
			label def `which' `k' "`lbl`k''", add 
		}
		label val `which' `which'
	}
	
	// recast(area) the most obvious alternative 
	local plot = cond("`recast'" != "", "`recast'", "line") 

	// draw graph 	
	if "`vertical'" != "" twoway `plot' `xstub' `fstub' if `fstub' > 0, ///
	yla(, ang(h)) by(`which', xrescale yrescale note("") `byopts')      ///
	xtitle(Density) ytitle("") `options' ///
	|| `addplot' 
	
	else twoway `plot' `fstub' `xstub' if `fstub' > 0, yla(, ang(h)) by(`which', ///
	xrescale yrescale note("") `byopts') xtitle("") ytitle(Density) `options'    /// 
	|| `addplot' 
end

program _clear 
	syntax [, fstub(str) xstub(str) ] 
	
	if "`fstub'" == "" local fstub _density 
	if "`xstub'" == "" local xstub _x 

	capture drop `fstub'* 
	capture drop `xstub'* 
end 

program CheckTrans 
	foreach t of local 0 { 
		local t = lower("`t'")
		local OK 0  

		if inlist("`t'", "identity", "@") { 
			local OK 1 
		} 
		else if inlist("`t'", "root", "square_root", "1/2") { 
			local OK 1 
		} 
		else if inlist("`t'", "cube_root", "1/3") { 
			local OK 1
		} 
		else if inlist("`t'", "log", "ln") { 
			local OK 1 
		} 
		else if "`t'" == "logit" { 
			local OK 1 
		} 
		
		if !`OK' { 
			di as err "`t' unrecognised transformation" 
			exit 498 
		}
	} 
end 
	
		
