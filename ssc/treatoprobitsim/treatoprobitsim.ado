program define treatoprobitsim, sortpreserve 
*! v.1.0.0 cagregory 3 26 14
	if replay() {
		if ("`e(cmd)'" != "treatoprobit_lf") error 301
		Replay `0'
		}
	else Estimate `0'
end	

program Estimate, eclass

syntax varlist [if] [in] [pweight iweight fweight] , TREATment(string) ///
 	SIMulationdraws(integer) [FACDENSity(string) FACSCale(real 1) ///
 	FACSKew(real 2) STARTpoint(integer 5) FACMEAN(real 2) vce(string) ///
 	sesim(integer 100) mixpi(real 50) ]
	
*parse
gettoken lhs rhs: varlist
gettoken tlhs treatment : treatment, parse("=")
gettoken equal trhs : treatment, parse("=")
	if "`equal'" != "=" {
		di in red "invalid syntax: equal sign is needed in the selection equation"
		exit 198
		}

local rhs `rhs' `tlhs'

if `mixpi'<=0 | `mixpi'>=100 {
	di in red "Mixing parameter must be between 0 and 100"
	exit 
	}



local pi1 = `mixpi'/100

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
		//local awgt "[aw=`wvar']"
		}



*mark sample
marksample touse 
markout `touse' `lhs'
markout `touse' `rhs'
markout `touse' `tlhs'
markout `touse' `trhs'
markout `touse' `cluster'



*test collinearity
_rmcoll `rhs' `wgt' if `touse', `constant'
local rhs `r(varlist)'
_rmcoll `trhs' `wgt' if `touse', `constant'
local trhs `r(varlist)'


*get startvals
qui levelsof(`lhs') if `touse'
local t: word count `r(levels)'
global ncut = `t'-1


*treatment eq: probit
tempname b_trt startmat ystar
di in gr _newline "Estimating Treatment equation"
probit `tlhs' `trhs' `wgt' if `touse', nocoef iter(30)
qui predict `ystar', xb
mat `b_trt' = e(b)

*outcome eq: ordered probit
di in gr _newline "Estimating Ordered Outcome Equation"
oprobit `lhs' `rhs' `wgt' if `touse', nocoef
tempname b b_out cuts zstar 
qui predict `zstar', xb
mat `b' = e(b)
local j = colsof(`b')
mat `b_out' =`b'[1,1..`j'-$ncut]
*cutpoints
mat `cuts'= `b'[1,(`j'-$ncut)+1..`j']

*lambda 
qui corr `zstar' `ystar'
local lambda_init = min(r(rho),.5)

*starting values
mat `startmat' = `b_trt', `b_out', `lambda_init', `cuts'

local cutpts
forvalues i = 1/$ncut {
	local cutpts "`cutpts' /cut`i'"
	}
qui levelsof(`depvar2')
global nchoices: word count `r(levels)'

*displaying ancilliary parameters
local lambda diparm(lambda)
local di_cuts
forv i = 1/$ncut {
	local di_cuts "`di_cuts' diparm(cut`i') " 
	}
local di_cuts "`di_cuts' diparm(__sep__)"

qui sum `touse'
local nobs = r(sum)
scalar sim = `simulationdraws'
scalar se_sim = `sesim'
local start init(`startmat',copy) search(off)

	
	if "`facdensity'"=="" {
		local facdensity = "normal"
	}
	
	
	mata: _treatoprobit_S=st_numscalar("sim")
	if "`facdensity'"=="normal" {
		mata: _treatoprobit_rnd = `facscale'* ///
								invnormal(halton(`nobs'*_treatoprobit_S,1,`startpoint',0))
		
		}
		if "`facdensity'"=="uniform" {
			mata: _treatoprobit_rnd = `facscale'*sqrt(12)* ///
									((halton(`nobs'*_treatoprobit_S,1,`startpoint',0)):-0.5)
		}
		if "`facdensity'"=="chi2" {
			local k = `=8/(`facskew'*`facskew')'
			local sgn = `=sign(`facskew')'
			mata: _treatoprobit_rnd = `facscale'/sqrt(2*`k')*`sgn'* ///
									(invchi2(`k',halton(`nobs'*_treatoprobit_S, 1,`startpoint',0)):-`k')
		}
		if "`facdensity'"=="gamma"{
			mata: _treatoprobit_rnd = invgammap(`facmean', halton(`nobs'*_treatoprobit_S,1, `startpoint',0)):-`facmean'
			
		}
		if "`facdensity'"=="logit" {
			mata: _treatoprobit_rnd= `facscale'*logit(halton(`nobs'*_treatoprobit_S,1,`startpoint',0))
		}
		if "`facdensity'"=="lognormal"{
			mata: _treatoprobit_rnd = exp(`facscale'*invnormal(halton(`nobs'*_treatoprobit_S,1,`startpoint',0)))
			mata: _treatoprobit_mean = mean(_treatoprobit_rnd)
			//mata: _switchoprobit_mean
			mata: _treatoprobit_rnd = _treatoprobit_rnd:-_treatoprobit_mean
			}
		if "`facdensity'"=="mixture" {
			tempvar p1 p2
			qui g double `p1' = runiform()<`pi1'
			qui g double `p2' = 1-`p1'
			local pi `p1' `p2'
			mata: st_view(p=.,.,tokens(st_local("pi")))
			mata: p1 = p[.,1]
			mata: p2 = p[.,2]
			mata: _treatoprobit_c1 = invnormal(halton(`nobs'*_treatoprobit_S,1,`startpoint',0))
			mata: _treatoprobit_c2 = `facmean':+`facscale'*invnormal(halton(`nobs'*_treatoprobit_S,1,`startpoint',0))
			mata: _treatoprobit_c1 = colshape(_treatoprobit_c1,  _treatoprobit_S)
			mata: _treatoprobit_c2 = colshape(_treatoprobit_c2, _treatoprobit_S)
			mata: _treatoprobit_rnd = p1:*_treatoprobit_c1:+p2:*_treatoprobit_c2
			
			}
					
		mata: _treatoprobit_rnd=colshape(_treatoprobit_rnd,_treatoprobit_S)
		//mata: _treatoprobit_rnd[|1,1\5,cols(_treatoprobit_rnd)|]
		local title "Treatment-effects Latent Factor Ordered Probit Regression"
		di " "
		di in green _newline "Fitting full model for treatment and outcome:"
		ml model lf2 treatoprobitsim_work (`tlhs': `tlhs' = `trhs') ///
			(`lhs': `lhs' = `rhs', noconstant) /lambda `cutpts' if `touse' ///
			`wgt' ///
			, ///
			title(`title') ///
			`robustopt'       ///
			`clopt'        /// 
			`mlopts'       ///
			`start'        /// 
			`di_cuts'      ///
			`lambda'       ///
			missing        ///
			technique(nr)  ///
			nonrtol       ///
			maximize       //waldtest(2)
ereturn local marginsnotok _ALL
ereturn scalar k_aux = $ncut+1
ereturn scalar simulationdraws = scalar(sim)
ereturn local xvarout `rhs'
ereturn local treatrhs `trhs'
ereturn local cmd treatoprobit_lf
ereturn local facdensity `facdensity'
ereturn local facscale `facscale'
ereturn local facmean `facmean'
ereturn local facskew `facskew'
ereturn local predict "treatoprobitsim_p"
if "`facdensity'"=="chi2" {
		ereturn local facskew `facskew'
	}
ereturn local depvar "`tlhs' `lhs'"
ereturn scalar cuts = $ncut
ereturn scalar startpt = `startpoint'
ereturn scalar sesim = scalar(se_sim)
treatoprobitlf_replay , level(95)

end

program define treatoprobitlf_replay
syntax [,level(integer 95)]

ml display, level(`level') neq(2) noomitted
tempname lrtest pval
qui test _b[lambda:_cons]=0
local `lrtest' = round(`r(chi2)',.01)
local `pval' = round(`r(p)',.01)
di in yellow `"{p}Notes:{p_end}"'
	di in gr `"{p}1. `e(simulationdraws)' Halton sequence-based quasirandom draws per observation{p_end}"'
	di in gr `"{p}2. Latent factor density is `e(facdensity)'{p_end}"'
	di in gr `"{p}3. Standard deviation of factor density is `e(facscale)'{p_end}"'
	di in gr `"{p}4. Test of independent equations = ``lrtest''. Probability of independent equations ``pval''.{p_end}"'



end




