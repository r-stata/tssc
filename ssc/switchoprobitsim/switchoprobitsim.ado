capture program drop switchoprobitsim
program define switchoprobitsim, sortpreserve 
*! v.1.0.0 cagregory 3 26 14
	if replay() {
		if ("`e(cmd)'" != "switchoprobitsim") error 301
		Replay `0'
		}
	capture program drop Estimate
	else Estimate `0'
end	

program Estimate, eclass

syntax varlist [if] [in] [pweight iweight fweight] , TREATment(string) ///
 	SIMulationdraws(integer) [FACDENSity(string) FACSCale(real 1) ///
 	FACSKew(real 2) STARTpoint(integer 1) FACMean(real 0) ///
	mixpi(real 50) vce(string) SESIMulations(integer 100)  ]


*parse
gettoken lhs rhs: varlist
gettoken tlhs treatment : treatment, parse("=")
gettoken equal trhs : treatment, parse("=")
	if "`equal'" != "=" {
		di in red "invalid syntax: equal sign is needed in the selection equation"
		exit 198
		}

	
*local rhs `rhs' `tlhs'

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
probit `tlhs' `trhs' `wgt' if `touse', nocoef iter(20)
qui predict `ystar', xb
mat `b_trt' = e(b)

*outcome eq: ordered probit, treated
di in gr _newline "Estimating Ordered Outcome Equation for Treatment Group"
oprobit `lhs' `rhs' `wgt' if `tlhs' & `touse' , nocoef
tempname b b_out_t cuts_t zstar_t 
qui predict `zstar_t', xb
mat `b' = e(b)
local j = colsof(`b')
mat `b_out_t' =`b'[1,1..`j'-$ncut]
*cutpoints
mat `cuts_t'= `b'[1,(`j'-$ncut)+1..`j']

*outcome eq: ordered probit, untreated
di in gr _newline "Estimating Ordered Outcome Equation for Untreated Group"
oprobit `lhs' `rhs' `wgt' if `tlhs'==0 & `touse' , nocoef
tempname b_u b_out_u cuts_u zstar_u 
qui predict `zstar_u', xb
mat `b_u' = e(b)
local j = colsof(`b_u')
mat `b_out_u' =`b_u'[1,1..`j'-$ncut]
*cutpoints
mat `cuts_u'= `b_u'[1,(`j'-$ncut)+1..`j']

*lambda 
qui corr `zstar_t' `ystar'
local lambda1_init = 1.5
qui corr `zstar_u' `ystar'
local lambda0_init = -1.5


*starting values
mat `startmat' = `b_trt', `b_out_u', `b_out_t', `lambda0_init', `lambda1_init', `cuts_u', `cuts_t'

local cutpts1
local cutpts0
forvalues i = 1/$ncut {
	local cutpts1 "`cutpts1' /cut_1`i'"
	local cutpts0 "`cutpts0' /cut_0`i'"
	}
local cutpts "`cutpts0' `cutpts1'"
local lambdap "/lambda0 /lambda1"

qui levelsof(`lhs')
global nchoices: word count `r(levels)'


*displaying ancilliary parameters
local lambda diparm(lambda0, label("lambda0"))
local lambda "`lambda' diparm(lambda1, label("lambda1")) diparm(__sep__)"
//local atlambda diparm(atanh_lambda0, tanh label("lambda0"))
//local atlambda "`atlambda' diparm(atanh_lambda1, tanh label("lambda1")) diparm(__sep__)"
local di_cuts1
local di_cuts0
forv i = 1/$ncut {
	local di_cuts1 "`di_cuts1' diparm(cut_1`i')" 
	local di_cuts0 "`di_cuts0' diparm(cut_0`i')"
	}
local di_cuts "`di_cuts0' `di_cuts1' diparm(__sep__)"

qui  sum `touse'
local nobs = r(sum)
scalar sim = `simulationdraws'
scalar sesim = `sesimulations'
local start init(`startmat',copy) search(off)
tempvar p1 p2
qui g `p1' = runiform()<`pi1' if `touse'
qui g double `p2' = 1-`p1' if `touse'
local pi `p1' `p2'	

	mata:  fmean = strtoreal(st_local("facmean"))
	
	mata: _switchoprobit_y2 = st_data(., "`lhs'","`touse'")
	mata: _switchoprobit_y1 = st_data(., "`tlhs'","`touse'")	
	
	
	if "`facdensity'"=="" {
		local facdensity = "normal"
	}
	
	
	mata: _switchoprobit_S=st_numscalar("sim")
	if "`facdensity'"=="normal" {
		mata: _switchoprobit_rnd = `facscale'* ///
								invnormal(halton(`nobs'*_switchoprobit_S,1,`startpoint',0))
		
		}
		if "`facdensity'"=="uniform" {
			mata: _switchoprobit_rnd = `facscale'*sqrt(12)* ///
									((halton(`nobs'*_switchoprobit_S,1,`startpoint',0)):-0.5)
		}
		if "`facdensity'"=="chi2" {
			local k = `=8/(`facskew'*`facskew')'
			local sgn = `=sign(`facskew')'
			mata: _switchoprobit_rnd = `facscale'/sqrt(2*`k')*`sgn'* ///
									(invchi2(`k',halton(`nobs'*_switchoprobit_S,1,`startpoint',0)):-`k')
		    
		}
		
		if "`facdensity'"=="gamma" {
		
			mata: _switchoprobit_rnd = `facscale'*(invgammap(`facmean', halton(`nobs'*_switchoprobit_S,1,`startpoint',0)):-`facmean')
			
			
		}
		if "`facdensity'"=="logit" {
			mata: _switchoprobit_rnd= `facscale'*(logit(halton(`nobs'*_switchoprobit_S,1,`startpoint',0)):-`facmean')
			
				}
		if "`facdensity'"=="lognormal"{
			mata: _switchoprobit_rnd = exp(`facscale'*invnormal(halton(`nobs'*_switchoprobit_S,1,`startpoint',0)))
			mata: _switchoprobit_mean = mean(_switchoprobit_rnd)
			mata: _switchoprobit_rnd = _switchoprobit_rnd:-_switchoprobit_mean
			
			}
		if "`facdensity'"=="mixture" {
			mata: f = tokens(st_local("pi"))
			mata: p = st_data(.,tokens(st_local("pi")), "`touse'")
			mata: p1 = p[.,1]
			mata: p2 = p[.,2]
			mata: _switchoprobit_c1 = invnormal(halton(`nobs'*_switchoprobit_S,1,`startpoint',0))
			mata: _switchoprobit_c2 = `facmean':+`facscale'*invnormal(halton(`nobs'*_switchoprobit_S,1,`startpoint',0))
			mata: _switchoprobit_c1 = colshape(_switchoprobit_c1, _switchoprobit_S)
			mata: _switchoprobit_c2 = colshape(_switchoprobit_c2, _switchoprobit_S)
			mata: _switchoprobit_rnd = p1:*_switchoprobit_c1:+p2:*_switchoprobit_c2
			
			}
			
					
		mata: _switchoprobit_rnd=colshape(_switchoprobit_rnd,_switchoprobit_S)
		
		
		local title "Latent Factor Ordered Probit Switching Regression"
		di " "
		di in green _newline "Fitting full model for treatment and outcome:"
		ml model lf2 switchoprobitsim_work (`tlhs': `tlhs' = `trhs') ///
			("`lhs'_0": `lhs' = `rhs', noconstant) ("`lhs'_1": `lhs' = `rhs', noconstant) ///
			 `lambdap' `cutpts' if `touse' ///
			`wgt' ///
			, ///
			title(`title') ///
			`robustopt'       ///
			`clopt'       /// 
			`mlopts'       ///
			`start'        /// 
			`di_cuts'      ///
			`lambda'       ///
			missing        ///
			technique(nr)  ///
			nonrtol        ///
			maxiter(10)   /// 
			maximize       //waldtest(2)
            
ereturn local marginsnotok _ALL
ereturn scalar k_aux = 2*($ncut+1)
ereturn scalar simulationdraws = scalar(sim)
ereturn local rhsout `rhs'
ereturn local treatrhs `trhs'
ereturn local cmd switchoprobitsim
ereturn local facdensity `facdensity'
ereturn local facscale `facscale'
ereturn local startpoint `startpoint'
ereturn local facmean `facmean'
ereturn local predict "switchoprobitsim_p"
if "`facdensity'"=="chi2" {
		ereturn local facskew `facskew'
	}
ereturn local depvar "`tlhs' `lhs'_0 `lhs'_1 `lhs' "
ereturn scalar cuts = $ncut
ereturn scalar sedraws = scalar(sesim)
ereturn local mixpi `mixpi'

switchoprobitlf_replay , level(95)

end

program define switchoprobitlf_replay
syntax [,level(integer 95)]
ml display, level(`level') neq(3) noomitted
tempname lrtest pval
qui test _b[lambda1:_cons]=_b[lambda0:_cons]
local `lrtest' = round(`r(chi2)',.01)
local `pval' = round(`r(p)',.01)
tempname lrtest1 pval1
qui test _b[lambda1:_cons]=0
local `lrtest1' = round(`r(chi2)',.01)
local `pval1' = round(`r(p)',.01)
tempname lrtest0 pval0
qui test _b[lambda0:_cons]=0
local `lrtest0' = round(`r(chi2)',.01)
local `pval0' = round(`r(p)',.1)
di in yellow `"{p}Notes:{p_end}"'
	di in gr `"{p}1. `e(simulationdraws)' Halton sequence-based quasirandom draws per observation.{p_end}"'
	di in gr `"{p}2. Latent factor density is `e(facdensity)'.{p_end}"'
	di in gr `"{p}3. Scale of factor density is `e(facscale)'.{p_end}"'
	di in gr `"{p}4. Test of independent treatment and outcome, treated group = ``lrtest1''. Probability = ``pval1''.{p_end}"'
	di in gr `"{p}5. Test of independent treatment and outcome, untreated group = ``lrtest0''. Probability = ``pval0''.{p_end}"'
	di in gr `"{p}6. Test of distinct regimes = ``lrtest''. Probability of identical treatment regimes ``pval''.{p_end}"'



end




