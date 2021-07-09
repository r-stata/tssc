*! dmexogxt from dmexog V1.4.3 4618   C F Baum and Steve Stillman
*  with help from Mark Schaffer
* Ref: Davidson & MacKinnon, Estimation and Inference in Econometrics, p.239
* V1.2   : mod to disable robust, aweight, iweight per VLW
* V1.35  : correction for inst list handling
* V1.3.6 : adds support for xtivreg, fe 
* V1.3.7 : add generalized test for ivreg, per D-M p 241-242
* V1.3.9 : subinstr needs word option to prevent mangling vnames
* V1.3.10: parallel generalized test for xtivreg, allow ts ops in 
*          ivreg endog list; xtreg can't cope with that
* V1.4.0 : support only xtivreg, fe
* V1.4.1 : _cons bugfix
* V1.4.2 : further _cons bugfix
* V1.4.3 : allow ts ops in original inst list as well

program define dmexogxt, rclass
	version 7.0
	syntax [anything]
	local xvarlist `anything'
	
	if "`e(cmd)'" ~= "xtivreg"  {
		di in r "dmexogxt only works after xtivreg, fe"
		error 301
	}
	
	if "`e(cmd)'" == "xtivreg" & "`e(version)'" < "1.1.4"  {	
		di in red "dmeoxgxt requires version 1.1.4 or later of xtivreg"	
		di in red "type -update query- and follow the instructions" /*	
			*/ " to update your Stata"	
		exit 198	
	}	
	if "`e(cmd)'" == "xtivreg" & "`e(model)'" ~= "fe" {	
		di in red "test is only valid with fixed effects models"	
		exit 198	
	}	
	
	tempname touse depvar inst incrhs nin b varlist i word regest weight
	tempname rhadd idvar
	
			/* idvar in fixed effect model */
   	local idvar `e(ivar)'
			/* mark sample */
	gen byte `touse' = e(sample)
			/* dependent variable */
	local depvar `e(depvar)'
   			/* instrument list */
	local inst `e(insts)'
	tsrevar `inst', sub
	local inst `r(varlist)'
			/* included RHS endog list */
	local incrhs `e(instd)'
	local nendog : word count `e(instd)'
			/* get regressorlist of original model; 
			collinearity between included/excluded exog should already be handled */
    	mat `b' = e(b)
    	local varlist : colnames `b'
* 1.4.2: careful to zap separate word _cons
    	local varlist : subinstr local varlist " _cons" " "
			/* get weights setting of original model */
	local weight ""
	if "`e(wexp)'" != "" {
                local weight "[`e(wtype)'`e(wexp)']"
        }
* 1.3.7: check if xvarlist is populated, if so validate entries
	local ninc 0
	local rem 0
	if "`xvarlist'" ~= "" {
		local nexog : word count `xvarlist'
		local rem = `nendog' - `nexog'
		local nincrhs `incrhs'
			foreach v of local xvarlist {
* should make ts operators case-insensitive (per VLW)
				local nincrhs: subinstr local nincrhs "`v'" "", word count(local zap)
				if `zap' ~= 1 {
					di in r _n "Error: `v' is not an endogenous variable"
					exit 198
					}
				}
* remove nincrhs from varlist if rem>0 and load xvarlist in incrhs
			if `rem' > 0 {
				foreach v of local nincrhs {
				local varlist: subinstr local varlist "`v'" "", word
				}
			local incrhs `xvarlist'
			}
* incrhs now contains the pruned list of vars assumed exogenous
* nincrhs contains the remaining included endogenous
* varlist contains the included exogenous 
			local ninc : word count `incrhs'
			}
*	noi capture {
* deal with ts operators in endog list
		tsrevar `incrhs', sub
		local incrhs `r(varlist)'
		local rhadd ""
	
			estimates hold `regest'	
			foreach word of local incrhs {
				qui xtreg `word' `inst' `weight' if `touse', fe i(`idvar')
				tempvar v_`word'
* 		as double
				qui predict double `v_`word'', e
				local rhadd "`rhadd' `v_`word''"
				}
			if (`ninc' == 0  | `rem' == 0) {	
				qui xtreg `depvar' `varlist' `rhadd' `weight' if `touse', fe i(`idvar')
				qui test `rhadd'
				return scalar df = r(df)
				return scalar df_r = r(df_r)
				return scalar dmexog = r(F)
				return scalar p = r(p)
				di in gr _n "Davidson-MacKinnon test of exogeneity: "   /*
		*/ 	in ye %9.0g return(dmexog) in gr            /* 
		*/ 	in gr "  F(" %2.0f in ye return(df) "," return(df_r) /*
		*/ 	in gr ")  P-value = " in ye %6.0g return(p)					
				}
			else {
				qui xtivreg `depvar' `varlist' `rhadd' (`nincrhs' = `inst') `weight' /*
*/ 				if `touse', fe i(`idvar')
				qui test `rhadd'
				return scalar df = r(df)
				return scalar dmexog = r(chi2)
				return scalar p = r(p)
				di in gr _n "Davidson-MacKinnon test of exogeneity: "   /*
		*/ in ye %7.3f return(dmexog) in gr            /* 
		*/ in gr "  Chi-sqr(" %2.0f in ye return(df)  /*
		*/ in gr ")  P-value = " in ye %6.0g return(p)	
			}	
		estimates unhold `regest'	
end
exit


