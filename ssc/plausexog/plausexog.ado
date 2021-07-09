*! plausexog: Estimating bounds with a plausibly exogenous exclusion restriction  
*! Version 3.1.1 June 24, 2018 @ 16:53:30
*! Author: Damian Clarke (application of code and ideas of Conley et al., 2012)
*! Much of the heart of this code comes from the Conley et al implementation
*! Contact: damian.clarke@usach.cl

/*
version highlights:
0.1.0: UCI and LTZ working.  No graphing
0.2.1: Graphing added
1.0.0: Completed beta testing.  Output complete. SSC v 1.0.0
1.0.1: Minor change to graph label options.
1.1.0: Weighting incorporated
1.2.0: Bug fix: very long names passed through syntax
2.0.0: Now Allowing for all arbitrary distributions with simulation algorithm
2.0.1: Graph issue when direct effect is negative for UCI (github issue #2)
2.1.0: Updating for Stata version 11.0 (requires mvtnorm)
3.0.0: Allows use in IC and Small Stata with simulations.  Simplification of syntax.
3.1.0: Bug fix on confidence interval calculation (norm vs t) Chapman/Batini
*/

cap program drop plausexog
program plausexog, eclass
version 11.0
#delimit ;

syntax anything(name=0 id="variable list")
[if] [in]
[fweight pweight aweight iweight]
[,
 grid(real 2)
 gmin(numlist)
 gmax(numlist)
 level(real 0.95)
 omega(numlist min=1)
 mu(numlist min=1)
 GRAph(varlist)
 GRAPHOMega(numlist min=2 max=22)
 graphmu(numlist min=2 max=22)
 graphdelta(numlist)
 VCE(string)
 DISTribution(string)
 seed(numlist min=1 max=1)
 iterations(integer 5000) 
 *
 ]
;
#delimit cr

preserve
********************************************************************************
*** (1) Unpack arguments, check for valid syntax, general error capture
********************************************************************************
local 0: subinstr local 0 "=" " = ", count(local equal)
local 0: subinstr local 0 "(" " ( ", count(local lparen)
local 0: subinstr local 0 ")" " ) ", count(local rparen)

tokenize `0'

local method `1'
macro shift
	
if "`method'"!="uci"&"`method'"!="ltz"&"`method'"!="upwci" {
    dis as error "Method of estimation must be specified."
    dis "Re-specify using uci, ltz or upcwi (see help file for more detail)"
    exit 200
}

if `equal'!=1|`lparen'!=1|`rparen'!=1 {
    dis as error "Specification of varlist is incorrect."
    dis as error "Ensure that syntax is: method yvar [exog] (endog=iv), [opts]"	
    exit 200
}

if `level'<=0|`level'>=1 {
    dis as error "Confidence level was requested as `level'"
    dis as error "The confidence level must be between 0 and 1. default is level(0.95)"
    exit 200
}

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

foreach list in varlist1 varlist2 varlist_iv {
    fvexpand ``list''
    local `list' `r(varlist)'
}

local allout `varlist1' `varlist2' constant
local allexog `varlist1' `varlist_iv' constant

local count1     : word count `varlist1'
local count2     : word count `varlist2'
local count_iv	 : word count `varlist_iv' 
local count_all  : word count `allout'
local count_exog : word count `allexog'
local countmin   : word count `gmin'
local countmax   : word count `gmax'

if `count2'>`count_iv' {
    dis as error "Specify at least as many instruments as endogenous variables"
    exit 200	
}

if "`method'"=="uci" {
    if `countmin'!=`count_iv'|`countmax'!=`count_iv' {
        dis as error "You must define as many gamma values as instrumental variables"
        dis "If instruments are believed to be valid, specify gamma=0 for gmin and gmax"
        exit 200	
    }
    
    foreach item in min max {
        local count=1
        foreach num of numlist `g`item'' {
            local g`count'`item'=`num'
            local ++count
        }
    }
}
if "`method'"=="ltz" & length("`distribution'")==0 {
    if length("`omega'")==0|length("`mu'")==0 {
        dis as error "For ltz, omega and mu values must be provided"
        exit 200
    }
    local count_omega: word count `omega'
    local count_mu   : word count `mu'
    if `count_omega'!=`count_iv' {
        dis as error "Variance assumptions for each plausibly exogenous IV should be provided"
        dis as error "`count_iv' IVs are included, so ensure that omega has `count_iv' elements"
        exit 200
    }
    if `count_mu'!=`count_iv' {
        dis as error "Mean assumptions for each plausibly exogenous IV should be provided"
        dis as error "`count_iv' IVs are included, so ensure that mu has `count_iv' elements"
        exit 200
    }
}

local derr1 "Simulation-based estimates require the user-written ado mvtnorm."
local derr2 "To use this method, please first install mvtnorm from the SSC"
local derr3 "(ssc install mvtnorm)."
if length("`distribution'")!=0 {
    cap which rmvnormal
    if _rc!= 0 {
	dis as error "`derr1' `derr2' `derr3'"
	error 200
    }

    if "`method'"!="ltz" {
        dis as error "The distribution option can only be specified with ltz"
        error 200
    }
    if length("`omega'")!=0|length("`mu'")!=0 {
        dis as error "Omega and mu should not be used with the distribution option"
        error 200
    }
    local distribution: subinstr local distribution "," " , ", all
    local distcnt : list sizeof distribution
    
    local jj=1
    foreach j of numlist 1(1)`distcnt' {
        local dist`jj': word `j' of `distribution'
        local dist`jj': subinstr local dist`jj' "," ""        
        if "`dist`jj''"!="" local ++jj
    }
    local expD = 2+2*`count_iv'
    local expS = 2+1*`count_iv'
    local cntD = 2*`count_iv'
    local cntS = 1*`count_iv'    

    local derr1  "If specifying a distribution with"
    local derrb  "and `count_iv' instrument(s)"
    local derr2  "parameter(s) must be specified"
    local accept "normal, uniform, chi2, poisson, t, gamma, special"
    if "`dist1'"=="normal" {
        if `jj'!=`expD' {
            dis as error "`derr1' normal `derrb', `cntD' `derr2' (mean and std dev)."
            exit 200
        }
        foreach ivn of numlist 1(1)`count_iv' {
            local ivl = `ivn'*2
            local ivh = `ivn'*2+1
            local gammaCall`ivn' rnormal(`dist`ivl'', `dist`ivh'')
        }
    }
    else if "`dist1'"=="uniform" {
        if `jj'!=`expD' {
            dis as error "`derr1' uniform `derrb', `cntD' `derr2' (min and max)."
            exit 200
        }
        foreach ivn of numlist 1(1)`count_iv' {
            local ivl = `ivn'*2
            local ivh = `ivn'*2+1
            local gammaCall`ivn' `dist`ivl''+(`dist`ivh''-`dist`ivl'')*runiform()
        }
    }
    else if "`dist1'"=="chi2" {
        if `jj'!=`expS' {
            dis as error "`derr1' chi2 `derrb', `cntS' `derr2' (degrees of freedom)."
            exit 200
        }
        foreach ivn of numlist 1(1)`count_iv' {
            local ivl = `ivn'+1
            if `dist`ivl''<1 {
                dis as error "At least 1 degree of freedom must be specified for chi2"
                exit 200
            }
            local gammaCall`ivn' rchi2(`dist`ivl'')
        }
    }
    else if "`dist1'"=="poisson" {
        if `jj'!=`expS' {
            dis as error "`derr1' poisson `derrb', `cntS' `derr2' (distribution mean)."
            exit 200
        }
        foreach ivn of numlist 1(1)`count_iv' {
            local ivl = `ivn'+1
            if `dist`ivl''<1 {
                dis as error "At least a mean of 1 must be specified for poisson"
                exit 200
            }
            local gammaCall`ivn' rpoisson(`dist`ivl'')
        }
    }
    else if "`dist1'"=="t" {
        if `jj'!=`expS' {
            dis as error "`derr1' t `derrb', `cntS' `derr2' (degrees of freedom)."
            exit 200
        }
        foreach ivn of numlist 1(1)`count_iv' {
            local ivl = `ivn'+1
            if `dist`ivl''<1 {
                dis as error "At least 1 degree of freedom must be specified for t"
                exit 200
            }
            local gammaCall`ivn' rt(`dist`ivl'')
        }
    }
    else if "`dist1'"=="gamma" {
        if `jj'!=`expD' {
            dis as error "`derr1' gamma `derrb', `cntD' `derr2' (shape and scale)."
            exit 200
        }
        foreach ivn of numlist 1(1)`count_iv' {
            local ivl = `ivn'*2
            local ivh = `ivn'*2+1
            if `dist`ivl''<=0|`dist`ivh''<=0 {
                dis as error "The shape and scale parameter for gamma must be > 0"
                exit 200
            }
            local gammaCall`ivn' rgamma(`dist`ivl'',`dist`ivh'')
        }
    }
    else if "`dist1'"=="special" {
        local sperr1 "To define your own distribution you must specify"
        local sperr2 "valid variable with the empirical distribution for each IV"
        if `jj'!=`expS' {
            dis as error "`sperr1' one `sperr2'"
            exit 200
        }
        foreach ivn of numlist 1(1)`count_iv' {
            local ivl = `ivn'+1
            cap sum `dist`ivl''
            if _rc!=0 {
                dis as error "`sperr1' a `sperr2'"
                exit 200
            }
        }
    }
    else {
        dis as error "The distribution option can only specify: `accept'"
        error 200
    }
}

dis "Estimating Conely et al.'s `method' method"
dis "Exogenous variables: `varlist1'"
dis "Endogenous variables: `varlist2'"
dis "Instruments: `varlist_iv'"


********************************************************************************
*** (2) Estimate model under assumption of gamma=0
********************************************************************************
local cEx   : word count `varlist1'
local cEn   : word count `varlist2'
local cIV   : word count `varlist_iv'

*dis "Trying to run intial reg with `cEx' exog vars `cEn' endog and `cIV' insts"	
qui ivregress 2sls `yvar' `varlist1' (`varlist2'=`varlist_iv') `if' `in'  /*
*/ [`weight' `exp'], vce(`vce')
qui estimates store __iv

if length("`graph'")!=0 {
    local CI    = -invnormal((1 - `level')/2)
    local lcomp = _b[`graph'] - `CI'*_se[`graph']
    local ucomp = _b[`graph'] + `CI'*_se[`graph']
}

********************************************************************************
*** (3) Union of Confidence Intervals approach (uci)
***     Here we are creating a grid and testing for each possible gamma combo:
***     ie - {g1min,g2min,g3min}, {g1max,g2min,g3min}, ..., {g1max,g2max,g3max}
***     This conserves much of the original (Conley et al.) code, which does 
***	  this in quite a nice way.
********************************************************************************
if "`method'"=="uci" {
    
    local points=1
    foreach gnum of numlist 1(1)`points' {
        local cRatio =	`gnum'/`points'
        foreach item in min max {
            local count=1
            foreach num of numlist `g`item'' {
                local g`count'`item'l=`num'*`cRatio'
                local ++count
            }
        }
        **************************************************************************
        *** (3a) Iterate over iter, which is each possible combination of gammas
        **************************************************************************
        local iter=1
        while `iter' <= (`grid'^`count_iv') {
            local R=`iter'-1
            local w=`count_iv'
            
            **Create weighting factor to grid gamma.  If grid==2, gamma={max,min}
            while `w'>0 {
                local a`w'     = floor(`R'/(`grid'^(`w'-1)))
                local R        = `R'-(`grid'^(`w'-1))*`a`w''
                local gamma`w' = `g`w'minl' + ((`g`w'maxl'-`g`w'minl')/(`grid'-1))*`a`w''
                
                local --w
            }
            
            tempvar Y_G
            qui gen `Y_G'=`yvar'
            
            
            local count=1
            foreach Z of local varlist_iv {
                qui replace `Y_G'=`Y_G'-`Z'*`gamma`count''
                local ++count
            }
            
            ***********************************************************************
            *** (3b) Estimate model based on assumed gammas, memoize conf intervals
            ***********************************************************************
            qui ivregress 2sls `Y_G' `varlist1' (`varlist2'=`varlist_iv') `if' /*
            */ `in' [`weight' `exp'], vce(`vce')
            
            ***********************************************************************
            *** (3c) Check if variable is not dropped (ie dummies) and results
            ***********************************************************************
            mat b2SLS   = e(b)
            mat cov2SLS = e(V)

            local vars_final
            local counter=0
            foreach item in `e(exogr)' `e(instd)' _cons {
                if _b[`item']!=0|_se[`item']!=0 {
                    local vars_final `vars_final' `item'
                    local ++counter
                }
            }
            ereturn scalar numvars = `counter'
            
            mat b2SLSf   = J(1,`counter',.)
            mat se2SLSf  = J(`counter',`counter',.)
            tokenize `vars_final'
            
            foreach num of numlist 1(1)`counter' {
                mat b2SLSf[1,`num']=_b[``num'']
                mat se2SLSf[`num',`num']=_se[``num'']
            }
            mat CI    = -invnormal((1 - `level')/2)
            mat ltemp = vec(b2SLSf) - CI*vec(vecdiag(se2SLSf))
            mat utemp = vec(b2SLSf) + CI*vec(vecdiag(se2SLSf))
            
            ***********************************************************************
            *** (3d) Check if CI from model is lowest/highest in union (so far)
            ***********************************************************************
            foreach regressor of numlist 1(1)`counter' {
                if `iter'==1 {
                    local l`regressor'=.
                    local u`regressor'=.	
                }
                local l`regressor' = min(`l`regressor'',ltemp[`regressor',1])
                local u`regressor' = max(`u`regressor'',utemp[`regressor',1])
            }
            local ++iter
        }
        
        if `gnum'==`points' {
            dis in yellow _newline
            dis "Conley et al (2012)'s UCI results" _col(55) "Number of obs =      " e(N)
            dis in yellow in smcl "{hline 78}"
            dis "Variable" _col(13) "Lower Bound" _col(29) "Upper Bound"
            dis in yellow in smcl "{hline 78}"
            
            tokenize `vars_final'
            
            foreach regressor of numlist 1(1)`counter' {
                if `l`regressor''>`u`regressor''{
                    dis in green "``regressor''" _col(13) `u`regressor'' _col(29) `l`regressor''
                }
                else {
                    dis in green "``regressor''" _col(13) `l`regressor'' _col(29) `u`regressor''
                }
                foreach var of local varlist2 {
                    if `"`var'"'==`"``regressor''"' {
                        if `l`regressor''>`u`regressor''{
                            ereturn scalar lb_`var'=`u`regressor''
                            ereturn scalar ub_`var'=`l`regressor''
                        }
                        else {
                            ereturn scalar lb_`var'=`l`regressor''
                            ereturn scalar ub_`var'=`u`regressor''
                        }
                    }
                }
            }
            dis in yellow in smcl "{hline 78}"
        }
    }

    if length("`graph'")!=0 {
        if `count_iv'>1 {
            dis as error "Graphing with UCI only supported with 1 plausibly exogenous variable"
            exit 200
        }
        local points=7
        matrix __graphmat = J(`points',4,.)
        
        if (`g1max'<=0&`g1min'<=0)|(`g1max'>=0&`g1min'>=0) {
            local range = `g1max'-`g1min'

            local jj=0
            while `jj'<=`points'-1 {
                local cRatio = (`jj'/(`points'-1))*`range'
                local gammaC = `cRatio'+`g1min'
                local ++jj
            
                tempvar Y_G
                qui gen `Y_G'=`yvar'
            
                qui replace `Y_G'=`Y_G'-`varlist_iv'*`gammaC'
            
                qui ivregress 2sls `Y_G' `varlist1' (`varlist2'=`varlist_iv') `if' /*
                */ `in' [`weight' `exp'], vce(`vce')

                local CI = -invnormal((1 - `level')/2)
                local ltemp = _b[`graph'] - `CI'*_se[`graph']
                local utemp = _b[`graph'] + `CI'*_se[`graph']
                if `jj'==1 {
                    local l`regressor'=`lcomp'
                    local u`regressor'=`ucomp'
                }
                local l`regressor' = min(`l`regressor'',`ltemp')
                local u`regressor' = max(`u`regressor'',`utemp')

                matrix __graphmat[`jj',1]=`gammaC'
                matrix __graphmat[`jj',3]=`l`regressor''
                matrix __graphmat[`jj',4]=`u`regressor''
            }
        }
        else {
            local range = `g1max'-0

            local jj=3
            while `jj'<=`points'-1 {
                local cRatio = (`jj'-3)/(`points'-4)*`range'
                local gammaC = `cRatio'+0
                local ++jj
                
                tempvar Y_G
                qui gen `Y_G'=`yvar'
            
                qui replace `Y_G'=`Y_G'-`varlist_iv'*`gammaC'
            
                qui ivregress 2sls `Y_G' `varlist1' (`varlist2'=`varlist_iv') `if' /*
                */ `in' [`weight' `exp'], vce(`vce')

                local CI = -invnormal((1 - `level')/2)
                local ltemp = _b[`graph'] - `CI'*_se[`graph']
                local utemp = _b[`graph'] + `CI'*_se[`graph']
                if `jj'==4 {
                    local l`regressor'=`lcomp'
                    local u`regressor'=`ucomp'
                }
                local l`regressor' = min(`l`regressor'',`ltemp')
                local u`regressor' = max(`u`regressor'',`utemp')
                
                matrix __graphmat[`jj',1]=`gammaC'
                matrix __graphmat[`jj',3]=`l`regressor''
                matrix __graphmat[`jj',4]=`u`regressor''
            }
            local range = `g1min'-0
            
            local jj=0
            while `jj'<=`points'-5 {
                local cRatio = (`jj'+1)/(`points'-4)*`range'
                local gammaC = 0+`cRatio'
                local ++jj
                
                tempvar Y_G
                qui gen `Y_G'=`yvar'
            
                qui replace `Y_G'=`Y_G'-`varlist_iv'*`gammaC'
            
                qui ivregress 2sls `Y_G' `varlist1' (`varlist2'=`varlist_iv') `if' /*
                */ `in' [`weight' `exp'], vce(`vce')

                local CI = -invnormal((1 - `level')/2)
                local ltemp = _b[`graph'] - `CI'*_se[`graph']
                local utemp = _b[`graph'] + `CI'*_se[`graph']
                if `jj'==1 {
                    local l`regressor'=`lcomp'
                    local u`regressor'=`ucomp'
                }
                local l`regressor' = min(`l`regressor'',`ltemp')
                local u`regressor' = max(`u`regressor'',`utemp')
                
                matrix __graphmat[`jj',1]=`gammaC'
                matrix __graphmat[`jj',3]=`l`regressor''
                matrix __graphmat[`jj',4]=`u`regressor''
            }
        }
    }
}


********************************************************************************
*** (5) Local to Zero approach (ltz)
********************************************************************************    
if "`method'"=="ltz" {
    tempvar const
    qui gen `const'=1
    if length("`distribution'")!=0&length("`graph'")!=0 {
        dis as error "Graphing is not enabled with the distribution option"   
        dis as error "For graphing and LTZ, omega and mu must be used"
        exit 200
    }
    
    *****************************************************************************
    *** (5a) Remove any colinear elements to ensure that matrices are invertible
    *** For the case of the Z vector, this requires running the first stage regs	
    *****************************************************************************		
    if `count1'!=0 {
        unab testvars: `varlist1'		
        local usevars1
        foreach var of local testvars {
            cap dis _b[`var']
            if _rc!=0 continue
            if _b[`var']!=0 local usevars1 `usevars1' `var'
        }
    }

    unab testvars: `varlist2'
    local usevars2
    foreach var of local testvars {
        cap dis _b[`var']
        if _rc!=0 continue
        if _b[`var']!=0 local usevars2 `usevars2' `var'
    }
    
    *****************************************************************************
    *** (5b) Form moment matrices: ZX and ZZ
    *****************************************************************************
    mat ZX = J(1,`count_all',.)
    mat ZZ = J(1,`count_exog',.)


    unab allvars: `varlist_iv' `usevars1' `const'
    tokenize `allvars'
    mat vecaccum a = `1' `usevars2' `usevars1' `if' `in'
    mat ZX = a
    while length("`2'")!= 0 {		
        mat vecaccum a = `2' `usevars2' `usevars1' `if' `in'
        mat ZX         = ZX\a
        macro shift		
    }
    
    tokenize `allvars'
    mat vecaccum a = `1' `varlist_iv' `usevars1' `if' `in'
    mat ZZ = a
    
    while length("`2'")!= 0 {	
        mat vecaccum a = `2' `varlist_iv' `usevars1' `if' `in'
        mat ZZ         = ZZ\a
        macro shift
    }
    
    scalar s1=rowsof(ZZ)
    scalar s2=rowsof(ZX)
    
    if length("`distribution'")==0 {
        tempname omega_in mu_in
        matrix `omega_in'= J(s1,s1,0)
        matrix `mu_in'= J(s1,1,0)
        local vv=1
        foreach val of numlist `mu' {
            matrix `mu_in'[`vv',1]    =`val'
            local ++vv
        }
        local vv=1
        foreach val of numlist `omega' {
            matrix `omega_in'[`vv',`vv'] =`val'
            local ++vv
        }
    }
    *****************************************************************************
    *** (5c) Form estimates if non-normal distribution
    ***      Coded based on the algorithm described on page 265 of REStat
    ****************************************************************************
    if length("`distribution'")!=0 {
        if c(flavor)=="Small" {
            dis "The distribution option should be used with care with Small Stata"
            dis "In this case bounds are calculated based on a maximum of 100 simulations"
            dis "It may be preferable to use a Guassian (exact) prior via mu() and omega()"
            local iterations=100
        }
        else if c(flavor)=="IC"&c(SE)==0&c(MP)==0 {
            set matsize 800
            local iterations=800
            dis "The distribution option should be used with care with Stata IC"
            dis "In this case bounds are calculated based on a maximum of 800 simulations"
            dis "It may be preferable to use a Guassian (exact) prior via mu() and omega()"
        }
        else {
            set matsize 10000
        }
    if length("`seed'")!= 0 {
        set seed `seed'
    }
    if "`dist1'"=="special" {
        local distvars
        foreach ivn of numlist 1(1)`count_iv' {
            local dv = `ivn'+1
            local distvars `distvars' `dist`dv''
        }
        mkmat `distvars', matrix(specialgamma) nomissing
        matrix mnsp = rowsof(specialgamma)
        local nsp   = mnsp[1,1]
        matrix gammaDonors = J(`iterations',`count_iv',.)
        foreach ivn of numlist 1(1)`count_iv' {
            local gd=1
            while `gd'<`iterations' {
                matrix gammaDonors[`gd',`ivn']=specialgamma[ceil(runiform()*`nsp'),`ivn']
                local ++gd
            }
        }
    }
    qui estimates restore __iv
    qui estat vce
    matrix varcovar = r(V)
    
    mata: st_matrix("betas", select(st_matrix("e(b)"), st_matrix("e(b)") :!=0))
    matrix mnvars = colsof(betas)
    local nvars   = mnvars[1,1]
    local betas 
    local zeros
    foreach num of numlist 1(1)`nvars' {
        local betas `betas' `=betas[1,`num']'
	local zeros `zeros' 0
    }
    
    
    **matrix gamma  = J(`nvars',1,0)
    matrix gamma  = J(`count_exog',1,0)
    matrix A      = inv(ZX'*inv(ZZ)*ZX)*ZX'
    dis "Simulating `iterations' iterations.  This may take a moment."

    foreach num of numlist 1(1)`nvars' {
        matrix betasSim = J(`iterations',`nvars',.)
    }

    local iter = 1
    while `iter' <= `iterations' {
        foreach ivn of numlist 1(1)`count_iv' {
            if "`dist1'"=="special" local gammaCall`ivn' = gammaDonors[`iter',`ivn']
            matrix gamma[`ivn',1]=`gammaCall`ivn''
        }
        matrix F = A*gamma
        qui rmvnormal, mean(`zeros') sigma(varcovar)
        matrix gsims = r(rmvnormal)
        foreach num of numlist 1(1)`nvars' {
            local input = gsims[1,`num']
            matrix betasSim[`iter',`num'] = `input'+F[`num',1] 
        }
        local ++iter
    }


    foreach num of numlist 1(1)`nvars' {
        mata : st_matrix("betasSim", sort(st_matrix("betasSim"), `num'))

        local lbci = 1-(1-`level')/2
        local ubci = (1-`level')/2        
        local l`num' = betas[1,`num']-betasSim[round(`iterations'*`lbci'),`num']
        local u`num' = betas[1,`num']-betasSim[round(`iterations'*`ubci'),`num']
        *local lowerbound = betasSim[round(`iterations'*0.025),`num']
        *local upperbound = betasSim[round(`iterations'*0.975),`num']
        *dis "Bound for variable `num' is [`lowerbound',`upperbound']"
    }

    local Cint "Conley et al (2012)'s LTZ results"
    dis in yellow _newline
    dis "`Cint' (Non-Gaussian)" _col(55) "Number of obs =      " e(N)
    dis in yellow in smcl "{hline 78}"
    dis "Variable" _col(13) "Lower Bound" _col(29) "Upper Bound"
    dis in yellow in smcl "{hline 78}"

    local vars_final
    local counter=0
    foreach item in `e(instd)' `e(exogr)' _cons {
        if _b[`item']!=0|_se[`item']!=0 {
            local vars_final `vars_final' `item'
            local ++counter
        }
    }
    tokenize `vars_final'

    foreach regressor of numlist 1(1)`nvars' {
        dis in green "``regressor''" _col(13) `l`regressor'' _col(29) `u`regressor''
        foreach var of local varlist2 {
            if `"`var'"'==`"``regressor''"' {
                ereturn scalar lb_`var'=`l`regressor''
                ereturn scalar ub_`var'=`u`regressor''
            }
        }
    }
    dis in yellow in smcl "{hline 78}"
    exit
}
*****************************************************************************
*** (5di) Form augmented var-covar and coefficient matrices for graphing
*****************************************************************************
if length("`graph'")!=0 {
    local Nomegas  : word count `graphomega'	
    local Nmus     : word count `graphmu'
    local Gerr1    "graphmu and graphomega"
    
    if `Nomegas'==0|`Nmus'==0 {
        dis as error "When specifing graph and ltz, the `Gerr1' options are required"
        exit 272
    }
    if `Nomegas'!=`Nmus' {
        dis as error "`Gerr1' must take the same number of elements"
        exit 272
    }
    matrix __graphmatLTZ = J(`Nomegas',4,.)
    
    local countdelta   : word count `graphdelta'
    if `countdelta'!=0 {
        local j=1	
        foreach num of numlist `graphdelta' {
            matrix __graphmatLTZ[`j',1]=`num'
            local ++j
        }
    }
    
    tempname omegaC muC
    tokenize `graphmu'

    local j=1
    foreach item in `graphomega' {
        matrix `omegaC'=J(s1,s1,0)
        matrix `omegaC'[1,1]=`item'
        matrix `muC'=J(s1,1,0)
        matrix `muC'[1,1]=``j''
                
        qui estimates restore __iv
        
        mat Vc = e(V) +  inv(ZX'*inv(ZZ)*ZX)*ZX' * `omegaC' * ZX*inv(ZX'*inv(ZZ)*ZX)
        mat bc = e(b) - (inv(ZX'*inv(ZZ)*ZX)*ZX' * `muC')'

        ereturn post bc Vc
        matrix CI = -invnormal((1-`level')/2)

        if `countdelta'==0 {
            scalar delta=`omegaC'[1,1]
            matrix __graphmatLTZ[`j',1]=delta
        }		
        matrix __graphmatLTZ[`j',2]=_b[`graph']
        matrix __graphmatLTZ[`j',3]=_b[`graph']-_se[`graph']*CI
        matrix __graphmatLTZ[`j',4]=_b[`graph']+_se[`graph']*CI

        local ++j
        }
    }
    *****************************************************************************
    *** (5dii) Form augmented var-covar and coefficient matrices (see appendix)
    *****************************************************************************
    qui estimates restore __iv
    mat V1 = e(V) +  inv(ZX'*inv(ZZ)*ZX)*ZX' * `omega_in' * ZX*inv(ZX'*inv(ZZ)*ZX)
    mat b1 = e(b) - (inv(ZX'*inv(ZZ)*ZX)*ZX' * `mu_in')'

    *****************************************************************************
    *** (5e) Determine lower and upper bounds
    *****************************************************************************
    mat CI  = -invnormal((1-`level')/2)
    mat lb  = b1 - vecdiag(cholesky(diag(vecdiag(V1))))*CI
    mat ub  = b1 + vecdiag(cholesky(diag(vecdiag(V1))))*CI

    dis _newline	
    dis "Conley et al. (2012)'s LTZ results" _col(55) "Number of obs =    " e(N)

    local lev=`level'*100
    set level `lev'
    ereturn post b1 V1
    ereturn display
    local CI    = -invnormal((1 - `level')/2)
    foreach var of local varlist2 {
        ereturn scalar lb_`var'=_b[`var']-`CI'*_se[`var']
        ereturn scalar ub_`var'=_b[`var']+`CI'*_se[`var']
    }
    set level 95
}

********************************************************************************
*** (6) Visualise as per Conely et al., (2012) Figures 1-2
********************************************************************************
if length("`graph'")!=0 {
    if "`method'"=="uci" {
        svmat __graphmat	
        
        if length("`options'")==0 {
            local options ytitle("Estimated Beta for `graph'") scheme(s1color) /*
            */ xtitle("{&delta}") title("Union of Confidence Interval Approach") /*
            */ note("Methodology described in Conley et al. (2012)") /*
            */ legend(order(1 "Upper Bound (UCI)" 2 "Lower Bound (UCI)")) 
        }
                
        sort __graphmat1 
        twoway line __graphmat3 __graphmat1, lpattern(dash) lcolor(black) || ///
        line        __graphmat4 __graphmat1, lpattern(dash) lcolor(black)     ///
        `options'
    }

    if "`method'"=="ltz" {
        svmat __graphmatLTZ
        
        if length("`options'")==0 {
            local options ytitle("{&beta}") xtitle("{&delta}") /*
                  */ title("Local to Zero Approach") /*
                  */ note("Methodology described in Conley et al. (2012)") /*
		  */ legend(order(1 "Point Estimate (LTZ)" 2 "CI (LTZ)"))
        }
			
        twoway line __graphmatLTZ2 __graphmatLTZ1,                        || ///
        line  __graphmatLTZ3 __graphmatLTZ1, lpattern(dash) lcolor(black) || ///
        line  __graphmatLTZ4 __graphmatLTZ1, lpattern(dash) lcolor(black)    ///
        `options'  
    }
    
    cap drop __graphmat*
}


********************************************************************************
*** (7) Clean up
********************************************************************************
estimates drop __iv
restore
end
