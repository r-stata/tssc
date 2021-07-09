*! imperfectiv: Estimating bounds with Nevo and Rosen's Imperfect IV procedure
*! Version 1.1.0 Dec 26, 2018 @ 12:12:12
*! Authors: Benjamin Matta and Damian Clarke

/*
Version highlights
 0.1.0 Original SSC finds reports 95% CI end points
 1.0.0 Updating based on Adam Rosen's comments.  Implements moment selection
 1.1.0 Bug fix line 275 stripped out due to non-standard character
*/

cap program drop imperfectiv
program imperfectiv, eclass
version 8.0

#delimit ;

syntax anything(name=0 id="variable list")
    [if] [in]
    [fweight pweight aweight iweight]
    [,
     Ncorr 
     Prop5
     NOASsumption4
     Level(cilevel)
     vce(string)
     verbose
     bootstraps(integer 50)
     seed(numlist min=1 max=1)
     exogvars(varlist fv ts)
     ]
;
#delimit cr

*-------------------------------------------------------------------------------
*-- (1) Unpack arguments, check for valid syntax, general error capture
*-------------------------------------------------------------------------------
local 0: subinstr local 0 "=" " = ", count(local equal)
local 0: subinstr local 0 "(" " ( ", count(local lparen)
local 0: subinstr local 0 ")" " ) ", count(local rparen)

local rops  `if' `in' [`weight' `exp']
if length("`vce'")!=0 local rops  `if' `in' [`weight' `exp'], vce(`vce')

if `equal'!=1|`lparen'!=1|`rparen'!=1 {
    dis as error "Specification of varlist is incorrect."
    dis as error "Ensure that syntax is: method yvar [exog] (endog=iv), [opts]"
    exit 200
}

tokenize `0'

local yvar `1'
macro shift

local varlist1
while regexm(`"`1'"', "\(")==0 {
    local varlist1 `varlist1' `1'
    macro shift
}

local varlist2
while regexm(`"`1'"', "=")==0 {
    local var=subinstr(`"`1'"', "(", "", 1)
    local varlist2 `varlist2' `var'
    macro shift
}

local varlist_iv
while regexm(`"`1'"', "\)")==0 {
    local var=subinstr(`"`1'"', "=", "", 1)
    local varlist_iv `varlist_iv' `var'
    macro shift
}
macro shift

if length("`1'")!=0 {
    dis as error "Specification of varlist is incorrect."
    dis as error "Ensure that syntax is: imperfectiv yvar [exog] (endog=iv)"
    exit 200
}

local ci=(100-`level')/200


local kEx   : word count `varlist1'
local kEn   : word count `varlist2'
local kIV   : word count `varlist_iv'

if `kEn'!=1 {
    dis as error "One endogenous variable must be specified. Currently `kEn'."
    exit 200
}
if length(`"`exogvars'"')!=0 {
    local m1 "included in exogvars(), but not included as exogenous variable"
    local m2 "Please include all exogenous variables in model and re-estimate."
    if `kEx'==0 {
        dis as error "Variables `m1' in model."
        dis as error "`m2'"
        exit `vcheck'
    }
    foreach var1 of varlist `exogvars' {
        local vcheck = 200
        foreach var2 of varlist `varlist1' {
            if `"`var1'"'==`"`var2'"' local vcheck = 0
        }
        if `vcheck'!=0 {
            dis as error "`var1' `m1' in model."
            dis as error "`m2'"
            exit `vcheck'
        }
    }
}
    
*-------------------------------------------------------------------------------
*-- (2) Regressions used to construct bounds
*-------------------------------------------------------------------------------
foreach var of varlist `varlist2' `exogvars' {
    local b_l_`var'
    local b_u_`var'
    local se_l_`var'
    local se_u_`var'
}
local model_upper
local model_lower

local i=1
foreach iv of varlist `varlist_iv' {
    if length("`noassumption4'")!=0{
        if `i'==1 {
            **MODEL 1: OLS [Considered max 1 time.  Invariant to diff IVs.]
            qui: reg `yvar' `varlist1' `varlist2' `rops'
            local model m1
            foreach var of varlist `varlist2' `exogvars' {
                local beta_v_`var'= _b[`var']
                local se_v_`var'  = _se[`var']
            }
        }
        else {
            foreach var of varlist `varlist2' `exogvars' {
                local beta_v_`var'
                local se_v_`var'
            }
        }
    }
    else{
        qui: sum `varlist2'
        local endogSD = r(sd)
        qui: sum `iv'
        local ivSD    =r(sd)
        tempvar v_var_`iv'
        qui gen `v_var_`iv''=`endogSD'*`iv'-`ivSD'*`varlist2'
        
        **MODEL 2: Each IV based on transformed instrument where lambda=1
        qui: ivregress 2sls `yvar' `varlist1' (`varlist2'=`v_var_`iv'') `rops'
        local model m2_`iv'
        foreach var of varlist `varlist2' `exogvars' {
            local beta_v_`var'= _b[`var']
            local se_v_`var'  = _se[`var']
        }
    }

    **MODEL 3: Each IV based on original IV
    qui: ivregress 2sls `yvar' `varlist1' (`varlist2'=`iv') `rops'
    tempvar estsample
    qui gen `estsample'=e(sample)
    local N=e(N)
    
    foreach var of varlist `varlist2' `exogvars' {
        local beta_iv_`var'= _b[`var']
        local se_iv_`var'  = _se[`var']
    }

    ****In what follows, select bound candidates based on correlations
    if `kEx'==0 | length("`noassumption4'")!=0{
        qui corr `varlist2' `iv'
        if r(rho)<0{
            if length("`ncorr'")!=0{
                foreach var of varlist `varlist2' `exogvars' {
                    local b_l_`var'  `b_l_`var'' `beta_v_`var''
                    local b_u_`var'  `b_u_`var'' `beta_iv_`var''
                    local se_l_`var' `se_l_`var'' `se_v_`var''
                    local se_u_`var' `se_u_`var'' `se_iv_`var''
                }
                local model_lower `model_lower' `model'
                local model_upper `model_upper' m3_`iv'
            }
            else {
                foreach var of varlist `varlist2' `exogvars' {
                    local b_l_`var'  `b_l_`var'' `beta_iv_`var''
                    local b_u_`var'  `b_u_`var'' `beta_v_`var''
                    local se_l_`var' `se_l_`var'' `se_iv_`var''
                    local se_u_`var' `se_u_`var'' `se_v_`var''
                }
                local model_lower `model_lower' m3_`iv'
                local model_upper `model_upper' `model'
            }
        }
        else{
            if length("`ncorr'")!=0{
                foreach var of varlist `varlist2' `exogvars' {
                    local b_l_`var'  `b_l_`var''  `beta_iv_`var'' `beta_v_`var''
                    local se_l_`var' `se_l_`var'' `se_iv_`var'' `se_v_`var''
                }
                local model_lower `model_lower' m3_`iv' `model'
            }
            else {
                foreach var of varlist `varlist2' `exogvars' {
                    local b_u_`var'  `b_u_`var''  `beta_iv_`var'' `beta_v_`var''
                    local se_u_`var' `se_u_`var'' `se_iv_`var'' `se_v_`var''
                }
                local model_upper `model_upper' m3_`iv' `model'
            }
        }
    }
    else{
        qui: reg `varlist2' `varlist1' `rops'
        tempvar x2
        predict `x2', residuals
        qui: corr `varlist2' `x2', covariance

        local endogCOV = r(cov_12) 
        qui: corr `iv' `x2', covariance   
        local ivCOV   = r(cov_12) 
        local Q1 = (`endogCOV'*`ivSD'-`ivCOV'*`endogSD')*`ivCOV'
        if length("`ncorr'")!=0 local ivCOV = (-1)*`ivCOV'
                
        if `Q1'<0{
            if `ivCOV'<0{
                foreach var of varlist `varlist2' `exogvars' {
                    local b_l_`var'  `b_l_`var'' `beta_iv_`var''
                    local b_u_`var'  `b_u_`var'' `beta_v_`var''
                    local se_l_`var' `se_l_`var'' `se_iv_`var''
                    local se_u_`var' `se_u_`var'' `se_v_`var''
                }
                local model_lower `model_lower' m3_`iv'
                local model_upper `model_upper' `model'
            }
            else {
                foreach var of varlist `varlist2' `exogvars' {
                    local b_l_`var'  `b_l_`var'' `beta_v_`var''
                    local b_u_`var'  `b_u_`var'' `beta_iv_`var''
                    local se_l_`var' `se_l_`var'' `se_v_`var''
                    local se_u_`var' `se_u_`var'' `se_iv_`var''
                }
                local model_lower `model_lower' `model'
                local model_upper `model_upper' m3_`iv'
            }
        }
        else{
            if `ivCOV'>0{
                foreach var of varlist `varlist2' `exogvars' {
                    local b_u_`var'  `b_u_`var''  `beta_iv_`var'' `beta_v_`var''
                    local se_u_`var' `se_u_`var'' `se_iv_`var'' `se_v_`var'' 
                }
                local model_upper `model_upper' m3_`iv' `model'
            }
            else {
                foreach var of varlist `varlist2' `exogvars' {
                    local b_l_`var'  `b_l_`var''  `beta_iv_`var'' `beta_v_`var''   
                    local se_l_`var' `se_l_`var'' `se_iv_`var'' `se_v_`var'' 
                }
                local model_lower `model_lower' m3_`iv' `model'
            }
        }
    }
    local ++i
    local model
}

if `kIV'>1 & length("`prop5'")!=0 {
    tokenize `varlist_iv' 
    tempvar omega
    *qui gen `omega'=0.5*`1'-0.5*`2'
    qui gen `omega'=0.5*`2'-0.5*`1'
    
    **MODEL 4: IV based on generated instrument from better and worse IV
    qui: ivregress 2sls `yvar' `varlist1' (`varlist2'=`omega') `rops'    
    foreach var of varlist `varlist2' `exogvars' {
        local beta_omega_`var'= _b[`var']
        local se_omega_`var'  =_se[`var']
    }
    local num_lo : word count `model_lower'
    local num_up : word count `model_upper'

    if `num_lo'==0  {
        foreach var of varlist `varlist2' `exogvars' {
            local b_l_`var'  `beta_omega_`var''
            local se_l_`var' `se_omega_`var''
        }
        local model_lower `model_lower' m4 
    }
    if `num_up'==0 {
        foreach var of varlist `varlist2' `exogvars' {
            local b_u_`var'  `beta_omega_`var''
            local se_u_`var' `se_omega_`var''
        }
        local model_upper `model_upper' m4 
    }
    if length("`noassumption4'")==0 {
        qui: sum `varlist2'
        local endogSD = r(sd)        
        qui: sum `omega' 
        local omegaSD = r(sd)

        tempvar omega_var
        qui gen `omega_var'=`endogSD'*`omega'-`omegaSD'*`varlist2'
        **MODEL 5: IV based on generated instrument from better and worse IV with omega
        qui: ivregress 2sls `yvar' `varlist1' (`varlist2'=`omega_var') `rops'
        foreach var of varlist `varlist2' `exogvars' {
            local beta_omega_var_`var'= _b[`var']
            local se_omega_var_`var'  =_se[`var']
        }
        
        if `num_lo'==0  {
            foreach var of varlist `varlist2' `exogvars' {
                local b_u_`var'  `b_u_`var'' `beta_omega_var_`var''
                local se_u_`var' `se_u_`var'' `se_omega_var_`var''
            }
            local model_upper `model_upper' m5
        }
        
        if `num_up'==0 {
            foreach var of varlist `varlist2' `exogvars' {
                local b_l_`var'   `b_l_`var''  `beta_omega_var_`var''
                local se_l_`var'  `se_l_`var'' `se_omega_var_`var''
            }
            local model_lower `model_lower' m5
        }
    }
}

*-------------------------------------------------------------------------------
*-- (3) Find betas and max SEs
*-------------------------------------------------------------------------------
local num_lo : word count `model_lower'
local num_up : word count `model_upper'
if `num_lo'>1 {
    foreach var of varlist `varlist2' `exogvars' {
        tokenize `se_l_`var''
        local maxSEl_`var'=0
        local j = 1
        foreach beta of local b_l_`var' {
            if `j'==1 {
                local maxLB_`var' = `beta'
                local maxLBse_`var' = ``j''
            }
            if `beta'>`maxLB_`var'' {
                local maxLB_`var' = `beta'
                local maxLBse_`var' = ``j''
            }
            if ``j''>`maxSEl_`var'' local maxSEl_`var' = ``j''
            local ++j
        }
    }
}
else if `num_lo'==1 {
    foreach var of varlist `varlist2' `exogvars' {
        local maxLB_`var' = `b_l_`var''
        local maxLBse_`var' = `se_l_`var''
    }
}

if `num_up'>1 {
    foreach var of varlist `varlist2' `exogvars' {
        tokenize `se_u_`var''
        local maxSEu_`var'=0
        local minUB_`var'=.
        foreach beta of local b_u_`var' {
            if `beta'<`minUB_`var'' {
                local minUB_`var' = `beta'
                local minUBse_`var' = `1'
            }
            if `1'>`maxSEu_`var''   local maxSEu_`var' = `1'
            macro shift
        }
    }
}
else if `num_up'==1 {
    foreach var of varlist `varlist2' `exogvars' {
        local minUB_`var' = `b_u_`var''
        local minUBse_`var' = `se_u_`var''
    }
}

*-------------------------------------------------------------------------------
*-- (4) Determine contact set for inference (only necessary if >1 candidate)
*-------------------------------------------------------------------------------
local c=2
if `num_lo'>1 {
    foreach var of varlist `varlist2' `exogvars' {
        local contactLower_`var'
        local contactLowerB_`var'
        local contactLowerSE_`var'
        foreach num of numlist 1(1)`num_lo' {
            tokenize `b_l_`var''
            local beta = ``num''
            tokenize `se_l_`var''
            local se   = ``num''
            tokenize `model_lower'
            local model  "``num''"
            
            if `beta'>=(`maxLB_`var''-(`c'*`maxSEl_`var''*sqrt(log(`N')))) {
                local contactLower_`var'   `contactLower_`var''   `model'
                local contactLowerB_`var'  `contactLowerB_`var''  `beta'
                local contactLowerSE_`var' `contactLowerSE_`var'' `se'
            }    
        }
    }
}

if `num_up'>1 {
    foreach var of varlist `varlist2' `exogvars' {
        local contactUpper_`var'
        local contactUpperB_`var'
        local contactUpperSE_`var'
        foreach num of numlist 1(1)`num_up' {
            tokenize `b_u_`var''
            local beta = ``num''
            tokenize `se_u_`var''
            local se   = ``num''
            tokenize `model_upper'
            local model  "``num''"
    
            if `beta'<=(`minUB_`var''+(`c'*`maxSEu_`var''*sqrt(log(`N')))) {
                local contactUpper_`var'   `contactUpper_`var''   `model'
                local contactUpperB_`var'  `contactUpperB_`var''  `beta'
                local contactUpperSE_`var' `contactUpperSE_`var'' `se'
            }    
        }
    }
}
        
*-------------------------------------------------------------------------------
*-- (5) Bootstrap to create the Omega matrices (only necessary if >1 candidate)
*-------------------------------------------------------------------------------
local nmods = 0
local bootmodels
foreach var of varlist `varlist2' `exogvars' {
    local num_up_`var' : word count `contactUpper_`var''
    local num_lo_`var' : word count `contactLower_`var''
    if `num_lo_`var''>1 local bootmodels_`var' `contactLower_`var''
    if `num_up_`var''>1 local bootmodels_`var' `bootmodels_`var'' `contactUpper_`var''
    local nmods_`var' : word count `bootmodels_`var''
    foreach model_donor in `bootmodels_`var'' {
        local added = 0
        foreach model_total in `bootmodels' {
            if `"`model_donor'"' == `"`model_total'"' local ++added
        }
        if `added' == 0 local bootmodels `bootmodels' `model_donor'
        if `added' == 0 local ++nmods
    }
}

if length("`seed'")!=0 set seed `seed'

local addsamples=0
if `nmods'>0 {
    foreach var of varlist `varlist2' `exogvars' {
        foreach model in `bootmodels_`var'' {
            tempvar `model'_`var'
            qui gen ``model'_`var''=.
        }
    }
    
    cap set obs `bootstraps'
    if _rc==0 local addsamples=1 
    if length(`"`verbose'"')>0 dis "Various candidates for upper or lower bounds"
    if length(`"`verbose'"')>0 dis "Bootstrap models will be listed below"
    forvalues samp=1/`bootstraps' {
        preserve
        bsample if `estsample'==1

        foreach model in `bootmodels' {
            if `"`model'"'=="m1" {
                if length(`"`verbose'"')>0&`samp'==1 dis "Original OLS"
                qui: reg `yvar' `varlist1' `varlist2' `rops'
                foreach var of varlist `varlist2' `exogvars' {
                    local m1b_`var' = _b[`var']
                }
            }
            foreach iv of varlist `varlist_iv' {
                if `"`model'"'=="m2_`iv'" {
                    if length(`"`verbose'"')>0&`samp'==1 dis "Lambda=1 IV (with `iv')"
                    qui: ivregress 2sls `yvar' `varlist1' (`varlist2'=`v_var_`iv'') `rops'
                    foreach var of varlist `varlist2' `exogvars' {
                        local m2_`iv'b_`var' = _b[`var']
                    }
                }
                if `"`model'"'=="m3_`iv'" {
                    if length(`"`verbose'"')>0&`samp'==1 dis "Original IV (with `iv')"
                    qui: ivregress 2sls `yvar' `varlist1' (`varlist2'=`iv') `rops'
                    foreach var of varlist `varlist2' `exogvars' {
                        local m3_`iv'b_`var' = _b[`var']
                    }
                }
            }
            if `"`model'"'=="m4" {
                if length(`"`verbose'"')>0&`samp'==1 dis "Better/Worse IV"
                qui: ivregress 2sls `yvar' `varlist1' (`varlist2'= `omega') `rops'
                foreach var of varlist `varlist2' `exogvars' {
                    local m4b_`var' = _b[`var']
                }
            }
            if `"`model'"'=="m5" {
                if length(`"`verbose'"')>0&`samp'==1 dis "Better/Worse Lambda=1 IV"
                qui: ivregress 2sls `yvar' `varlist1' (`varlist2'=`omega_var') `rops'
                foreach var of varlist `varlist2' `exogvars' {
                    local m5b_`var' = _b[`var']
                }
            }
        }
        restore
        foreach var of varlist `varlist2' `exogvars' {
            foreach model in `bootmodels_`var'' {
                qui replace ``model'_`var''=``model'b_`var'' in `samp'
            }
        }
        if length(`"`verbose'"')>0 dis "Bootstrap replication `samp' complete."
    }
}

foreach var of varlist `varlist2' `exogvars' {
    if `num_lo_`var''>1 {
        local OMEGAl_`var'
        foreach m of local contactLower_`var' {
            local OMEGAl_`var' `OMEGAl_`var'' ``m'_`var''
        }
        qui corr `OMEGAl_`var''
        matrix OMEGAl_`var' = r(C)
    }

    if `num_up_`var''>1 {
        local OMEGAu_`var'
        foreach m of local contactUpper_`var' {
            local OMEGAu_`var' `OMEGAu_`var'' ``m'_`var''
        }
        qui corr `OMEGAu_`var''
        matrix OMEGAu_`var' = r(C)
    }

    foreach model in `bootmodels_`var'' {
        qui drop ``model'_`var''
    }
}
local N1 = `N'+1
if `addsamples'==1 qui drop in `N1'/`bootstraps'

*-------------------------------------------------------------------------------
*-- (6) Generate bounds on endogenous variable (parameter and CI)
*-------------------------------------------------------------------------------
local ii=1
foreach var of varlist `varlist2' `exogvars' {
    if `num_lo_`var''<=1 {
        tokenize `b_l_`var''
        if length(`"`1'"')==0 {
            if `ii'==1{
                if length(`"`verbose'"')>0 dis "No candidates for Lower Bounds."
                local ++ii
            }
            local maxLB_`var' .
            local lowerbound_`var' .
        }
        else {
            local lowerbound_`var'=`maxLB_`var''-invnormal(1-`ci')*`maxLBse_`var''
        }
    }
    if `num_up_`var''<=1 {
        tokenize `b_u_`var''
        if length(`"`1'"')==0 {
            if `ii'==1{
                if length(`"`verbose'"')>0 dis "No candidates for Upper Bounds."
                local ++ii
            }
            local minUB_`var' .
            local upperbound_`var' .
        }
        else {
            local upperbound_`var' = `minUB_`var''+invnormal(1-`ci')*`minUBse_`var''
        }
    }

    if `num_up_`var''!=0&`num_lo_`var''!=0 {
        local Delta = abs(`minUB_`var''-`maxLB_`var'')
        local pn    = 1-(normal(log(`N')*`Delta')*`ci')
    }    
    else local pn   = 1-`ci'

    local R     = 10000
    local seed  = round(runiform()*10000)
    
    if `num_lo_`var''>1 {
        mata: st_numscalar("pkl",genQuantP(st_matrix("OMEGAl_`var'"),`num_lo_`var'',`R',`seed',`pn'))
        tokenize `contactLowerSE_`var''
        local j = 1
        foreach beta of local contactLowerB_`var' {
            local LB = `beta'-``j''*pkl
            if `j'==1 {
                local lowerbound_`var' = `LB'
            }
            if `LB'>`lowerbound_`var'' local lowerbound_`var' = `LB'
            local ++j
        }
    }
    if `num_up_`var''>1 {
        mata: st_numscalar("pku",genQuantP(st_matrix("OMEGAu_`var'"),`num_up_`var'',`R',`seed',`pn'))
        local upperbound_`var' .
        tokenize `contactUpperSE_`var''
        foreach beta of local contactUpperB_`var' {
            local UB = `beta'+`1'*pku
            if `UB'<`upperbound_`var'' local upperbound_`var' = `UB'
            macro shift
        }
    }
}


*-------------------------------------------------------------------------------
*-- (7) Return
*-------------------------------------------------------------------------------
local NR "Nevo and Rosen (2012)"
local exolong  : word count `exogvars'
matrix M_bounds = J(`exolong'+1,4,.)
local j=1
foreach var of varlist `varlist2' `exogvars' {
    matrix M_bounds[`j',2] = `maxLB_`var''
    matrix M_bounds[`j',3] = `minUB_`var''
    matrix M_bounds[`j',1] = `lowerbound_`var''
    matrix M_bounds[`j',4] = `upperbound_`var''
    local ++j
}
matrix colnames M_bounds = ci_LB  LB UB ci_UB
matrix rowname  M_bounds = `varlist2' `exogvars'

#delimit ;
dis _newline;
dis "`NR''s Imperfect IV bounds" _col(55) "Number of obs =    " e(N);
dis in yellow in smcl "{hline 78}";
dis "Variable" _col(18) "Lower Bound(CI) " _col(32) " LB(Estimator) " _col(46)
    "UB(Estimator) "  _col(60) "Upper Bound(CI)";
dis in yellow in smcl "{hline 78}";
#delimit cr

foreach var of varlist `varlist2' `exogvars' {
    local eLB = `maxLB_`var''
    local eCIlb = `lowerbound_`var''
    local eCIub = `upperbound_`var''
    local eUB = `minUB_`var''
    #delimit ;
    dis in green "`var' " _col(20) "["`eCIlb' _col(36) "("`eLB'
    _col(50) `eUB' ")" _col(65) `eCIub' "]";
    #delimit cr
}
if `"`eCIlb'"'=="."|`"`eCIub'"'=="." {
    dis in yellow in smcl "{hline 78}"
    dis "Note: One sided bounds only are returned. Refer to `NR' "
    dis "for situations in which two-sided bounds are possible."
}
else dis in yellow in smcl "{hline 78}"

foreach var of varlist `varlist2' {
    ereturn scalar lb_`var'=`maxLB_`var''
    ereturn scalar ub_`var'=`minUB_`var''
    ereturn scalar CIlb_`var'=`lowerbound_`var''
    ereturn scalar CIub_`var'=`upperbound_`var''
    ereturn matrix LRbounds M_bounds
}



end

*-------------------------------------------------------------------------------
*-- (8) Mata functions for generating analytical quantile bound
*-------------------------------------------------------------------------------
cap mata: mata drop genQuantP()
mata:
    function genQuantP(OMEGA,dimOm,R,seed,p) {
        rseed(seed)
        Z  = cholesky(OMEGA)*rnormal(dimOm,R,0,1)
       pk = sort(colmax(Z)',1)[round(R*p),1]

       return(pk)
    }
end
