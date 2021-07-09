capture program drop treatoprobit
version 10.0
program define treatoprobit, eclass sortpreserve 
*!version 1.0.0 cagregory
	if replay() {
		if ("`e(cmd)'" != "treatobprobit") error 301
		Replay `0'
		}
	else Estimate `0'
end

program define Estimate, eclass

syntax anything(equalok) [if] [in] [pweight iweight fweight], treat(varlist) ///
 	[vce(string) level(integer 95)  ]

*parse
gettoken depvar2 indvar2: anything
gettoken depvar1 indvar1: treat
local indvar2 "`indvar2' `depvar1'"


*options
mlopts mlopts, `options' //ml options
gettoken firstvce restvce: vce

if "`vce'"!= " " {
if "`firstvce'" == "cluster"  {
		local clopt "vce(cluster `restvce')"
		di "`clopt'"
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
probit `depvar1' `indvar1' `wgt' if `touse', nocoef iter(30)
qui predict `ystar', xb
mat `b_trt' = e(b)

*outcome eq: ordered probit
di in gr _newline "Estimating Ordered Outcome Equation"
oprobit `depvar2' `indvar2' `wgt' if `touse', nocoef
tempname b b_out cuts zstar 
qui predict `zstar', xb
mat `b' = e(b)
local j = colsof(`b')
mat `b_out' =`b'[1,1..`j'-$ncut]
*cutpoints
mat `cuts'= `b'[1,(`j'-$ncut)+1..`j']

*rho
qui corr `zstar' `ystar'
local rho_init = min(r(rho),.5)

*starting values
mat `startmat' = `b_trt', `b_out', `rho_init', `cuts'


local cutpts
forvalues i = 1/$ncut {
	local cutpts "`cutpts' /cut`i'"
	}
qui levelsof(`depvar2')
global nchoices: word count `r(levels)'


*displaying ancilliary parameters
local athrho diparm(atanh_rho)
local rho diparm(atanh_rho, tanh label("rho"))
local di_cuts
forv i = 1/$ncut {
	local di_cuts "`di_cuts' diparm(cut`i') " 
	}
local di_cuts "`di_cuts' diparm(__sep__)"
*full model
constraint 1 _b[cut1:_cons] = 0
di in gr _newline "Estimating Full Model"
ml model lf2 treatoprobit_work ("`depvar1'": `depvar1' = `indvar1')              ///
                               ("`depvar2'": `depvar2' = `indvar2', noconstant) ///
                               /atanh_rho `cutpts' if `touse'               ///
							   `wgt' ///
								 , ///
							    title("Treatment Effects Ordered Probit Regression") ///
							    init(`startmat', copy) ///
							    search(off)            ///
							    maximize               ///
							    `clopt'                ///
							    `mlopts'			    ///
							    `robustopt'               ///
							   `di_cuts'               ///
								`athrho'                ///
								technique(nr)           ///
								nonrtol                   ///
								`rho'

*ml init `startmat', copy 
//ml check
*ml maximize, nonrtol difficult  

tempname lrtest pval
ereturn local marginsnotok _ALL
ereturn local weight `wvar'
ereturn scalar k_aux = $ncut+2
ereturn local cmd    "treatoprobit"
ereturn local depvar "`depvar1' `depvar2'"
ereturn local treatx "`indvar1'"
ereturn scalar cuts = $ncut
ereturn local predict "treatoprobit_p"
ereturn local indvarout `indvar2'
treatoprobit_replay , level(95)

end

program define treatoprobit_replay
syntax [,level(integer 95)]

ml display, level(`level') neq(2) noomitted
tempname lrtest pval
qui test _b[atanh_rho:_cons]=0
local `lrtest' = round(r(chi2),.01)
local `pval' = round(r(p),.01)
di in gr `"{p} Test of independent equations = ``lrtest''. Probability of independent equations ``pval''.{p_end}"'



end //end parsing and calling command



