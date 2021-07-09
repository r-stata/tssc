capture program drop switchoprobit
version 10
program define switchoprobit, eclass sortpreserve 
*!version 1.0.0 cagregory
	if replay() {
		if ("`e(cmd)'" != "switchoprobit") error 301
		Replay `0'
		}
	else Estimate `0'
end

program define Estimate, eclass

syntax anything(equalok) [if] [in] [pweight iweight fweight], treat(varlist) ///
 	[vce(string) level(integer 95)]

*parse
gettoken depvar2 indvar2: anything
gettoken depvar1 indvar1: treat
*local indvar2 "`indvar2' `depvar1'"

*options
mlopts mlopts, `options' //ml options

gettoken firstvce restvce: vce

if "`vce'"!=" " {
if "`firstvce'" == "cluster"  {
		local clopt "vce(cluster `restvce')"
		}
if "`firstvce'" == "robust" {
		local robustopt "vce(robust)"
		di "`robustopt'"
		}
}
if "`weight'" != "" {
		tempvar wvar
		quietly gen double `wvar' `exp'
		local wgt "[`weight'=`wvar']"
		local awgt "[aw=`wvar']"
		}

if "`level'"!="" {
	tempname cilevel
	global cilevel = `level'
}


*mark sample
marksample touse 
markout `touse' `depvar1'
markout `touse' `depvar2'
markout `touse' `indvar1'
markout `touse' `indvar2'
markout `touse' `cluster'



*get startvals
qui levelsof(`depvar2') if `touse'
local t: word count `r(levels)'
global ncut = `t'-1


*treatment eq: probit
tempname b_trt startmat ystar
di in gr _newline "Estimating Treatment equation"
probit `depvar1' `indvar1' `wgt' if `touse', nocoef iter(20)
qui predict `ystar', xb
mat `b_trt' = e(b)

*outcome eq: ordered probit, treated
di in gr _newline "Estimating Ordered Outcome Equation for Treatment Group"
oprobit `depvar2' `indvar2' `wgt' if `depvar1' & `touse' , nocoef
tempname b b_out_t cuts_t zstar_t 
qui predict `zstar_t', xb
mat `b' = e(b)
local j = colsof(`b')
mat `b_out_t' =`b'[1,1..`j'-$ncut]
*cutpoints
mat `cuts_t'= `b'[1,(`j'-$ncut)+1..`j']

*outcome eq: ordered probit, untreated
di in gr _newline "Estimating Ordered Outcome Equation for Untreated Group"
oprobit `depvar2' `indvar2' `wgt' if `depvar1'==0 & `touse' , nocoef
tempname b_u b_out_u cuts_u zstar_u 
qui predict `zstar_u', xb
mat `b_u' = e(b)
local j = colsof(`b_u')
mat `b_out_u' =`b_u'[1,1..`j'-$ncut]
*cutpoints
mat `cuts_u'= `b_u'[1,(`j'-$ncut)+1..`j']


*rho
qui corr `zstar_t' `ystar'
local rho1_init = min(r(rho),.5)
qui corr `zstar_u' `ystar'
local rho0_init = min(r(rho),.5)

*starting values
mat `startmat' = `b_trt', `b_out_u', `b_out_t', `rho0_init', `rho1_init', `cuts_u', `cuts_t'
*mat list `startmat'

local cutpts1
local cutpts0
forvalues i = 1/$ncut {
	local cutpts1 "`cutpts1' /cut_1`i'"
	local cutpts0 "`cutpts0' /cut_0`i'"
	}
qui levelsof(`depvar2')
global nchoices: word count `r(levels)'


*displaying ancilliary parameters
local athrho diparm(atanh_rho0)
local athrho "`athrho' diparm(atanh_rho1) diparm(__sep__)"
local rho diparm(atanh_rho0, tanh label("rho0"))
local rho "`rho' diparm(atanh_rho1, tanh label("rho1")) diparm(__sep__)" 
local di_cuts1
local di_cuts0
forv i = 1/$ncut {
	local di_cuts1 "`di_cuts1' diparm(cut_1`i')" 
	local di_cuts0 "`di_cuts0' diparm(cut_0`i')"
	}
local di_cuts "`di_cuts0' `di_cuts1' diparm(__sep__)"


*full model
di in gr _newline "Estimating Full Model"
ml model lf0 switchoprobit_work ("`depvar1'": `depvar1' = `indvar1')              ///
                               ("`depvar2'_0": `depvar2' = `indvar2', noconstant) ///
							    ("`depvar2'_1": `depvar2' = `indvar2', noconstant) ///
                          /atanh_rho0 /atanh_rho1 `cutpts0' `cutpts1' if `touse' ///
							   `wgt' ///
								 , ///
							    title("Ordered Probit Switching Regression") ///
							    init(`startmat', copy) ///
							    search(off)            ///
							    technique(nr)        ///
							    nonrtol                ///
							    maximize               ///
							    `clopt'                ///
							    `mlopts'			   ///
							    `robustopt'               ///
							   `di_cuts'               ///
							   `athrho'                ///
							   `rho'

*ml init `startmat', copy 
*ml check
*ml maximize, nonrtol difficult  
ereturn local marginsnotok _ALL
ereturn scalar cuts = $ncut
ereturn scalar k_aux = 2*($ncut+2)
ereturn local treatx "`indvar1'"
ereturn local rhsout "`indvar2'"
ereturn local cmd    "switchoprobit"
ereturn local depvar "`depvar1' `depvar2'_0 `depvar2'_1 "
ereturn local predict "switchoprobit_p"

*ereturn display

switchoprobit_replay

end //end parsing and calling command

program define switchoprobit_replay

ml display, level($cilevel) neq(3) noomitted
tempname lrtest pval
qui test _b[atanh_rho1:_cons]=_b[atanh_rho0:_cons]
local `lrtest' = round(r(chi2),.01)
local `pval' = round(r(p),.0001)
di in gr `"{p} LR test of distinct regimes = ``lrtest''. Probability of identical regimes for treated and untreated states ``pval''.{p_end}"'



end //end display



