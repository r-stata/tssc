*! version 0.0.2  2011-02-28 jx
*   add probit and cloglog
*  version 0.0.1  2009-12-28 jx


// Compute averaged marginal effects between groups in binary regression models

// TO DO LIST:


capture program drop grdiame     
program define grdiame, rclass     
    version 10.0     
    tempname    z                                           ///
                b                                           ///
                I                                           ///
                xvec                                        ///
                xb                                          ///
                sxb                                         ///
                prob pdf dfdl grad                          ///
                g1gradsum g0gradsum avggraddif              ///
                marg avgmarg g1margsum g0margsum avgmargdif avgmargdifse avgmargdiflo avgmargdifhi  ///
                V tobase
    tempvar     touse     
    tempfile     
         
    syntax [if] [in],   ///
            [x(passthru) rest(passthru) level(integer $S_level) all     /// 
             noBAse                                                     ///
             Group(string)]                                             // 

//  MODELS APPLIED
    
        if "`e(cmd)'"=="logistic" | ///
           "`e(cmd)'"=="logit"    | ///
           "`e(cmd)'"=="probit"    | ///
           "`e(cmd)'"=="cloglog"    {
            local io = "typical binary"
        }
        
   
        if "`io'"=="" {
            di in r "this grcompare command does not work for the last type of model estimated."
            exit
    }             
    
    matrix `b' = e(b)
    // command from SPost, get base values
    _pebase `if' `in', `x' `rest' `all'
    mat `tobase' = r(pebase)
    loc rhsnms    "`r(rhsnms)'" 
    loc nrhs `r(nrhs)'
    mat `I' = I(`nrhs'+1)
    
    sca `z' = -invnorm((1-`level'/100)/2)
    mark `touse' if e(sample)
    
    qui count
    loc totobs = r(N)
    
    // decompose groupvar into three
    gettoken grpvar group: group, parse(" ")    // group variable name
    gettoken grp0 group: group, parse(" ")      // group 0 group value
    gettoken grp1: group, parse(" ")            // group 1 group value
    
    if "`grp0'"=="" | "`grp1'"=="" {
        di in r "You need to specify values for the two comparisons in the group opion!"
        exit
    }
    // group 1 group value: group 1 - group 0
    /*
    di in y "grpvar=`grpvar'"
    di in g "grp0=`grp0'"
    di in r "grp1=`grp1'"
    */
    
    // command from SPost for group size counts
    _pecats `grpvar'
    loc numcats = r(numcats)
    loc catvals "`r(catvals)'"
    forvalues i = 1 /   `numcats'   {        
        loc crtval: word `i' of `catvals'
        tempname catcnt_`crtval'
        qui count if `grpvar'==`crtval' & `touse'
        // counts of each category for averaging late
        sca `catcnt_`crtval'' = r(N)
    }
    
    // establish the null matrices for marginal sum, gradient sum for two groups
    mat `g1margsum' = J(1, `nrhs'+1, 0)
    mat `g1gradsum' = J(`nrhs'+1, `nrhs'+1, 0)
    mat `g0margsum' = J(1, `nrhs'+1, 0)
    mat `g0gradsum' = J(`nrhs'+1, `nrhs'+1, 0)
    
    
    forvalues k= 1/`totobs'    {
        // check if an observation is in the estimation sample or not
        loc sampchk = `touse'[`k']
        if `sampchk'==0 {
            continue
        }
        // otherwise, take that into computation
        else    {
            cap mat drop `xvec'
            forvalues m = 1 / `nrhs'{
                tempname varval`m'
                loc crtvar: word `m' of `rhsnms'
                sca `varval`m'' = `crtvar'[`k']
                mat `xvec' = nullmat(`xvec'), `varval`m''          
            }
            // add constant one
            mat `xvec' = `xvec',J(1,1,1)
            *mat list `xvec'
            *mat list `b'
            // get matrix linear predictor
            mat `xb' = `xvec' * `b''

            *local nb = colsof(`b') - 1
            *matrix `b' = `b'[1,1..`nb'] /* get rid of _con */
            
            // construct marginal effect and gradient for each observation
            sca `sxb' = `xb'[1,1]
            if "`e(cmd)'"=="logit" | "`e(cmd)'"=="logistic" {
                sca `prob' = exp(`sxb')/(1+exp(`sxb'))
                sca `pdf' = `prob'*(1-`prob')
                sca `dfdl' = (1-2*`prob')*`prob'*(1-`prob')        
            }
            
            else if "`e(cmd)'"=="probit" {
            sca `prob' = normprob(`sxb')
            sca `pdf'  = exp(-`sxb'*`sxb'/2)/sqrt(2*_pi)
            sca `dfdl' = -`sxb'*`pdf'
            }
            
            else if "`e(cmd)'"=="cloglog"   {
            sca `prob' = 1- exp(-exp(`sxb'))
            sca `pdf' = (`prob'-1)*ln(1-`prob')
            sca `dfdl'= `pdf'*(ln(1-`prob')+1)
            }            
            
            mat `marg' = `pdf'*`b'
            mat `grad' = `pdf'*`I'+`dfdl'*(`b')'*(`xvec')
            // grab the group value from the groupvar
            loc yesno= `grpvar'[`k']
            
            /*
            di in r "yesno=`yesno'  `grpvar'[`k']"
            mat list `marg'
            mat list `grad'
            di in y "========================"
            */
            //computation for sum of marginal effects and gradient for group 1 and 0
            if "`yesno'" == "`grp1'" {
                mat `g1margsum' = `g1margsum' + `marg'
                mat `g1gradsum' = `g1gradsum' + `grad'
            }
            if "`yesno'" == "`grp0'" {
                mat `g0margsum' = `g0margsum' + `marg'
                mat `g0gradsum' = `g0gradsum' + `grad'       
            }
            /*
            di in y "matrice marg and grad"
            mat list `marg'
            mat list `grad'
            */
            
            /*
            di in y "matricex g1margsum and g0margsum"
            mat list `g1margsum'
            mat list `g0margsum'
            */
        } 
    }
    // sum and average
    mat `avgmargdif' = `g1margsum'/`catcnt_`grp1'' - `g0margsum'/`catcnt_`grp0''
    mat `avggraddif' = `g1gradsum'/`catcnt_`grp1'' - `g0gradsum'/`catcnt_`grp0''
    
    /*
    mat list `g1margsum'
    mat list `g0margsum'
    mat list `avggraddif'
    */
    // variance of difference in average marginal effect
    mat `V' = (`avggraddif') * e(V) * (`avggraddif')'
    
    // get s.e. for marginal effect
    mat `avgmargdifse' = vecdiag(cholesky(diag(vecdiag(`V')))) 
    mat `avgmargdiflo' = `avgmargdif' - `z'*`avgmargdifse'
    mat `avgmargdifhi' = `avgmargdif' + `z'*`avgmargdifse'
    
    mat `avgmargdif'= `avgmargdiflo' \ `avgmargdif' \ `avgmargdifhi'
    mat `avgmarg'   = `g0margsum' / `catcnt_`grp0'' \ `g1margsum' / `catcnt_`grp1''
    mat rownames `avgmarg' = group0 group1
    mat rownames `avgmargdif' = diflo g1-g0 difhi
    
    mat list `avgmargdif', noheader
    ret mat avgmargdif = `avgmargdif'
    ret mat avgmarg    = `avgmarg'
    
end
 