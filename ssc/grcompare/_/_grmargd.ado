* ! version 0.0.1 2009-12-28 jx

// Low level utility to compute marginal effects and compare differences in binary regression models using delta

// TO DO: not in planning at this point
capture program drop _grmargd
program define _grmargd, rclass

    version 8.0
    tempname b xvec xb sxb prob marg pdf tobase z I   
    tempname    dfdl grad                                           ///
                margvar margse margci marglo marghi                 /// 
                dmargci dmarg dmargse dmargvar  dmarglo dmarghi     //
                  

//  DECODE SYNTAX

    syntax [if] [in] [, x(passthru) rest(passthru) choices(varlist) level(integer $S_level) ///
                        noBAse          ///
                        dydxmat(string) ///
                    all Save Diff]

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
    // command from SPost, get all base values
    _pebase `if' `in', `x' `rest' `all'
    loc rhsnms  =   "`r(rhsnms)'"
    matrix `xvec' = PE_base // PE_base or r(pebase)
    mat `tobase' = r(pebase)
    sca `z' = invnorm(1-(100-`level')/200)
    
    //  create the identify matrix used for construcing d(delta)/d(b)
    loc nrhs= `r(nrhs)'
    mat `I' = I(`nrhs'+1)
    
    // compute linear predictor
    matrix `xvec' = `xvec',J(1,1,1)
    matrix `xb' = `xvec' * `b''
    *local nb = colsof(`b') - 1
    *matrix `b' = `b'[1,1..`nb'] /* get rid of _con */
    scalar `sxb' = `xb'[1,1]
    
    // compute cdf, pdf, and dfdl=d(pdf)/d(xb)
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
    *mat list `marg'
    if "`dydxmat'"!=""  {
        mat `marg' = `marg' * (`dydxmat')
    }
    mat colnames `marg' = `rhsnms' _cons
    mat rownames `marg' = dp/dx

    
    * mat list `marg'
    // compute gradient
    mat `grad' = `pdf'*`I'+`dfdl'*(`b')'*(`xvec')
    mat `margvar'  = `grad'*e(V)*(`grad')'
    // get s.e. for marginal effect
    mat `margse' = vecdiag(cholesky(diag(vecdiag(`margvar')))) 
    mat `marglo' = `marg' - `z'*`margse'
    mat `marghi' = `marg' + `z'*`margse'
    mat `margci' = (`marglo' \ `marg' \ `marghi')'
    mat colnames `margci' = dltlo marg dlthi
    mat rownames `margci' = `rhsnms' _cons
    *mat list `marg', noheader
    di _skip(2)
    di in g "Marginal Effects"
    mat list `margci', noheader

    if "`diff'"!="" {
        // take difference in marginal effects
        // compute the variance for the differences in marginal effects
        mat `dmarg'     =   `marg' - MargSave
        mat `dmargvar' =    `grad'*e(V)*(`grad')' + MargGradSave*e(V)*(MargGradSave)' ///
                       -`grad'*e(V)*(MargGradSave)' - MargGradSave*e(V)*(`grad')'
        
        // get s.e. for difference in marginal effect
        mat `dmargse'= vecdiag(cholesky(diag(vecdiag(`dmargvar'))))                    
        mat `dmarglo' = `dmarg' - `z'*`dmargse'
        mat `dmarghi' = `dmarg' + `z'*`dmargse'
        mat `dmargci' = (`dmarglo'  \ `dmarg' \ `dmarghi')'
        mat colnames `dmargci' = dltlo dmarg dlthi
        mat rownames `dmargci' = `rhsnms' _cons
        *mat list `dmarg', noheader
        di _skip(2)
        di in g "Differences in Marginal Effects"
        mat list `dmargci', noheader        
        ret mat dmarg   `dmarg'
        ret mat dmargci `dmargci'
    }
    
    
    // save important matrices for next round of diff
        
    if "`save'"!="" {
        mat MargSave = `marg'
        mat MargGradSave = `grad'
        mat _GRSavebase = `tobase'
        
    }
    
    ret mat marg        `marg'  
    ret mat margci      `margci'
    ret mat margvar     `margvar'   // Var/Cov Matrix of marginal effects
    ret mat margse      `margse'
    
// adding base values    
    if "`base'"!="nobase" {

        mat rownames `tobase' = "x="
        if "`diff'"=="" {
            mat _GRtemp = `tobase'
            _peabbv _GRtemp
            mat list _GRtemp, noheader
        }   
        else {
            local tmp1: colnames `tobase'
            local tmp2: colnames _GRSavebase
            
            if "`tmp1'"=="`tmp2'" {
                mat _GRtemp = (`tobase' \ _GRSavebase \ (`tobase' - _GRSavebase))
                mat rownames _GRtemp = "Current=" "Saved=" "Diff="
                _peabbv _GRtemp 
                mat list _GRtemp, noheader
            }
            else {
                mat rownames `tobase' = "Current="
                mat rownames _GRSavebase =  "  Saved="
                mat _GRtemp = `tobase'
                _peabbv _GRtemp
                mat list _GRtemp, noheader
                mat _GRtemp = _GRSavebase
                _peabbv _GRtemp
                mat list _GRtemp, noheader
            }
        }    
    }

end

