*! version 0.0.1 2009-12-28 jx

// Compute difference in difference in predicted probabilities in binary regression models
// useful for comparing the effects of nominal level independent variables across groups
// TO DO LIST:


capture program drop grdidip     
program define grdidip, rclass     
    version 10.0     
    tempname    V           /// variance of difference in difference
                didip       /// prediction
                se          /// standard error
                didip_lo    ///
                didip_hi    ///
                didipmat    ///
                didipp1s    ///
                z           // z score associated with confidence level
    tempvar     
    tempfile     
         
    syntax [if] [in], x1(string) x2(string) x3(string) x4(string)   ///
                    [rest(passthru) level(integer $S_level) all     ///
                    noBAse] 

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
    
    di _skip(1)
    di in g         "Computational Note for Difference in Difference"    ///
        _newline    "==============================================="    ///
        _newline    "  {P(x*b|x4)-P(x*b|x3)}-{P(x*b|x2)-P(x*b|x1)}"
    
    sca `z' = -invnorm((1-`level'/100)/2) 
    // create tempnames for four bases
    forvalues i=1/4 { 
        tempname    xbase`i'    /// xbase without 1
                    xbase1`i'   /// xbase with 1
                    matp1`i'    /// matrix probability of 1
                    matxb`i'    /// matrix linear predictors
                    p1`i'       /// probabilities of 1
                    xb`i'       //  linear predictors
        // command from SPost, get base values
        _pebase `if' `in', x(`x`i'') `rest' `all' 
        *mat list r(pebase)
        mat `xbase`i'' = r(pebase)
        mat `xbase1`i''= `xbase`i'', 1
        mat PE_in = `xbase`i''
        // command from SPost
        // predictions for predicted probability
        // predictions for linear predictor
        _pepred, level(`level') 
        mat `matp1`i''=r(p1)
        mat `matxb`i''=r(xb)
        sca `p1`i''= `matp1`i''[1,1]
        sca `xb`i''= `matxb`i''[1,1]        
    }
    
    // prediction of the comparison statistic
    sca `didip' = (`p14'-`p13') - (`p12'-`p11')
    
    // VAR(G(XB)) = VAR{(P(x*b|x4)-P(x*b|x3))-(P(x*b|x2)-P(x*b|x1))}
    //            = dG(XB)/dB' * VAR(B) * dG(XB)/dB
    
    // compute variance/covariance matrix
    mat `V' =       ((`p14'*(1-`p14')*`xbase14'-`p13'*(1-`p13')*`xbase13')        ///
                -   (`p12'*(1-`p12')*`xbase12'-`p11'*(1-`p11')*`xbase11'))        ///
               *    e(V)                                                        ///
               *    ((`p14'*(1-`p14')*(`xbase14')'-`p13'*(1-`p13')*(`xbase13')')  ///
               -    (`p12'*(1-`p12')*(`xbase12')'-`p11'*(1-`p11')*(`xbase11')'))
    
    *mat list `V'
    // standard error of this statistic
    mat `se' = vecdiag(cholesky(diag(`V')))' 
    sca `se' = `se'[1,1]
    sca `didip_lo' = `didip'-`z'*`se'
    sca `didip_hi' = `didip'+`z'*`se'
    mat `didipmat' = `didip_lo', `didip', `didip_hi'
    mat `didipp1s' = `p11', `p12', `p13', `p14'
    mat colnames `didipmat' = didip_lo didip didip_hi
    mat list `didipmat', noheader
    
    ret mat didipmat = `didipmat'
    ret mat didipp1s = `didipp1s'

    
    if "`base'"!="nobase" {  
    
        forvalues i=1/4 { 
            mat rownames `xbase`i'' = "x`i'="
            mat list `xbase`i'', noheader
        }   
    
    }
    
end
