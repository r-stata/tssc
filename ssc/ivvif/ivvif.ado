*! version 1.0.3 20feb2007 by David Roodman, Center for Global Development, www.cgdev.org
*! Based almost entirely on Stata command vif
*! mod 31mar2014 cfb to allow use after ivregress with David Roodman's approval

cap program drop ivvif
program define ivvif, rclass sort
	version 7.0
 
*	_isfit cons
 
      if "`e(cmd)'" != "ivreg" & "`e(cmd)'" != "ivreg2" & "`e(cmd)'" != "regress" & "`e(cmd)'" != "ivregress" {
            di as err "This command only works after -reg-, -ivreg-, -ivregress- and -ivreg2-."
            exit 301
      }
 
	if `"`0'"' != "" { 
		error 198 
	}
 
	tempvar touse
	qui gen byte `touse' = e(sample)
 
	_getrhs varlist
	local if	"if `touse'"
	local wgt	`"`e(wtype)'"'
	local exp	`"`e(wexp)'"'
 
	local wtexp = `""'
	if `"`wgt'"' != `""' & `"`exp'"' != `""' {
		local wtexp = `"[`wgt'`exp']"'
	}
 
	/* added code for IV */
      tempname b
      mat `b' = e(b)
      local xvars : colnames(`b')
	quietly if "`e(cmd)'" != "regress" {
	      local endog `e(instd)'
	      local insts `e(insts)'
	      tempvar x y 
	      local xvars : colnames(`b')
	      local xvars : subinstr local xvars "_cons" "", count (local n)
	      if `n' == 0 {
	             local consopt nocons
	      } 
		else {
			if  _b[_cons]==0 {
	            	local consopt nocons
			}
		}

		foreach var of varlist `xvars' {
			if _b[`var']==0 {
				local xvars : subinstr local xvars "`var'" "", word
				local varlist : subinstr local varlist "`var'" "", word
			}
		}
	 
	      local exog `xvars'
	      local xvarsi `xvars' /* instrumented X vars */
		if `"`endog'"' != "" {
			foreach var of varlist `endog' {
	            	local exog : subinstr local exog "`var'" "", word all
			}
	      }
	
	      /* make instrumented versions */

		if `"`endog'"' != "" {
			tempname ehold
			estimate hold `ehold'
			tsrevar `endog'
			foreach var of varlist `r(varlist)' {
		            tempvar `var'i
		            regress `var' `exog' `insts' if `touse', `consopt'
		            predict double ``var'i' if e(sample)
				local xvarsi : subinstr local xvarsi "`var'" "``var'i'", word all
		      }
			estimate unhold `ehold'
			local varlist `xvarsi'
		}
	}
	/* end of bulk of added code */
	
	tokenize `varlist'
	local ovars `""'
	local ovars_display `""' /* added */
	local i 1 
	while `"``i''"' != `""' {
		local found 0
		foreach item of local ovars {
			if "`item'" == "``i''" {
				local found 1
			}
		}
		if !`found' & _b[`: word `i' of `xvars''] { /* edited */
			local ovars `"`ovars' ``i'' "'
			local ovars_display `"`ovars_display' `: word `i' of `xvars''"' /* added */
		}
		local i = `i'+1
	}
	local nvif : word count `ovars'
	tempname ehold vif mvif 
	scalar `mvif' = 0.0
	quietly {
		noi di
		noi di in smcl in gr /*
		*/ "    Variable {c |}       VIF       1/VIF  "
		noi di in smcl in gr "{hline 13}{c +}{hline 22}"
		local i 1
		local nv 0
		estimate hold `ehold'
 
		tempname nms vvv
		gen str8 `nms' = `""'
		gen `vvv' = .
		capture {
			while `i' <= `nvif' {
				tokenize `ovars'
				local ind
				local vc 1
				while `vc' < `i' {
					local ind `"`ind' ``vc''"'
					local vc = `vc'+1
				}
				local vc = `i'+1
				while `vc' <= `nvif' {
					local ind `"`ind' ``vc''"'
					local vc = `vc'+1
				}
				local dep `"``i''"'
			
				regress `dep' `ind' `if' `in' `wtexp', `consopt'
				replace `vvv' = 1/(1-e(r2)) in `i'
				replace `nms' = `"`: word `i' of `ovars_display''"' in `i'  /* edited */
				scalar `mvif' = `mvif'+`vvv'[`i']
				local nv = `nv'+1
				local i = `i'+1
			}

			* preserve
			gsort -`vvv' `nms'
			local i 1
			tempname vifmat temp /* added */
			while `i' <= `nv' {
				noi di in smcl in gr /*
				*/ %12s abbrev(`nms'[`i'],12) /*
				*/ `" {c |} "' in ye %9.2f `vvv'[`i'] /*
				*/ `"    "' in ye %8.6f 1/`vvv'[`i']
				global S_`i' = `vvv'[`i']
				ret local name_`i' = `nms'[`i']
				ret scalar vif_`i' = `vvv'[`i'] 
				mat `temp' = `vvv'[`i']   /* added */
				mat rownames `temp' = "`=`nms'[`i']'"   /* added */
				mat `vifmat' = nullmat(`vifmat') \ `temp'   /* added */
				local i = `i'+1
			}
			mat colnames `vifmat' = "vif"   /* added */
			ret mat vif = `vifmat'   /* added */
			noi di in smcl in gr "{hline 13}{c +}{hline 22}"
			noi di in smcl in gr `"    Mean VIF {c |} "' /*
			*/ in ye %9.2f `mvif'/`nv'
			* restore
		}
		estimate unhold `ehold'
	}
	error _rc
end

