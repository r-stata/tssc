*! version 0.0.6 -- jx 2010-01-20
*  make it compatible with test statistic of t
*   // ---> jxadd05 // ---> jxadd05 start // ---> jxadd05 end
*   // ---> jxchg05
*! version 0.0.4 -- jx
*  make global suffix become prefix 
*! version 0.0.3 -- jx
*  change "=" to "" for global and local at very end
*! version 0.0.2 -- jx
*  add lhs and display options
*  count significant coefficients
*  count significant coefficients

cap program drop sigcoef
program sigcoef, sclass
    version 10
    syntax varlist, [Replace Append Level(int $S_level) Clear DVSame DISPlay]
    
    *specify conditions:
    *1. replace and append cannot go together
    *2. clear and append cannot go together
    *3. clear and replace cannot go together
    *4. one of replace, append, or clear should appear
    if    ("`replace'"!="" & "`append'" !="")  |   ///
          ("`clear'"  !="" & "`append'" !="")  |   ///
          ("`clear'"  !="" & "`replace'"!="")  |   ///         
          ("`replace'"=="" & "`append'" =="" & "`clear'"=="")  {
      di in r "syntax error with replace, append, or clear options"
      exit 198
    }
    
    if "`dvsame'" != "" & "`append'"!="" {    
        if "`e(depvar)'" != "`s(lastdepvar)'"   {
            di _skip(1)
            di in y "This estimation is not counted because it has a different dependent variable"
            di in y "(`e(depvar)') than the one in your last estimation (`s(lastdepvar)'). "
            exit 198    
        }
    }

    tempname b z negz t negt tdf tst negtst
    loc nvar: word count `varlist'
  
    mat `b' = e(b)
    loc colnms: colnames(`b') // colnames(A)  
    *loc nrhs: word count `colnms'  
  
    *if one var is not rhs variable in last estimation
    *jump out of the loop.
    forval i= 1/`nvar'    {
        loc var`i': word `i' of `varlist'
        loc j = 0
        foreach var in `colnms' {
            if "`var'"=="`var`i''"  {
                loc ++j   
            }   
        }
        if `j'== 0  {
            di in r "`var`i'' is not rhs variable"
            exit    
        }  
    }
    
    *when use clear, it clears out any possible existing globals
    *and exit.
    if "`clear'" !=  ""   {
        forval i = 1/`nvar' {
            loc var`i': word `i' of `varlist'
            cap mac drop posnum`var`i'' negnum`var`i'' signum`var`i''   ///
                poslhs`var`i'' neglhs`var`i''
        }
        exit
    }
    
    *get positive z and negative z for level
    sca `z'     = -invnorm((1-(`level')/100)/2)
    sca `negz'  =  invnorm((1-(`level')/100)/2)
    
    // ---> jxadd05 start
    sca `tdf'   = e(N) - e(df_m)
    sca `t'     = invttail(`tdf', (1-(`level')/100)/2)
    sca `negt'  = -invttail(`tdf', (1-(`level')/100)/2)
    
    
    // other types of models that use t can be readily added as necessary
    if "`e(cmd)'"   ==  "regress"   {
        sca `tst'   =   `t'
        sca `negtst'=   `negt'
    }
    
    else {
        sca `tst'   =   `z'
        sca `negtst'=   `negz'  
    }
    // ---> jxadd05 end
    
    *loop through each var in varlist
    forval i = 1/`nvar' {
        loc var`i': word `i' of `varlist'
        
        *if replace, loc equal to 0
        *if append, loc equal to global in memory
        if "`replace'"!=""  {
            loc pos`var`i''     = 0 // significantly positive
            loc neg`var`i''     = 0 // significantly negative 
            loc poslhsadd`var`i'' = ""
            loc neglhsadd`var`i'' = "" 
        }       
        if "`append'"!=""   {
            loc pos`var`i''= ${posnum`var`i''}
            loc neg`var`i''= ${negnum`var`i''}
            loc poslhsadd`var`i'' "${poslhs`var`i''}"
            loc neglhsadd`var`i'' "${neglhs`var`i''}" 
        }
        
        *count sig tot, neg sig, pos sig for this round
        *for this variable
    cap {       
        loc cntpos = 0
            // ---> jxchg05 from `z' into `tst'
            if (_b[`var`i'']/_se[`var`i''])>`tst' { 
                loc ++cntpos  
                *global poslhsadd`var`i'' "${poslhsadd`var`i''} `e(depvar)'"
                loc cur_pos "`e(depvar)'"
            }   
            loc cntneg = 0
            // ---> jxchg05 from `negz' to `negtst'
            if (_b[`var`i'']/_se[`var`i''])<`negtst' { 
                loc ++cntneg
                *global neglhsadd`var`i'' "${neglhsadd`var`i''} `e(depvar)'"
                loc cur_neg "`e(depvar)'"
            }       
        }
        
        *if any mistakes reset locs to zero
        if _rc!=0   {   // variables not found
            loc cntpos =0
            loc cntneg =0   
        }
        
        *add current to previous count
        loc pos`var`i''         = `pos`var`i''' + `cntpos'
        loc neg`var`i''         = `neg`var`i''' + `cntneg'
        loc sigtot`var`i''      = `pos`var`i''' + `neg`var`i'''
        loc poslhsadd`var`i''   "`poslhsadd`var`i'''`cur_pos' "     
        loc neglhsadd`var`i''   "`neglhsadd`var`i'''`cur_neg' "
    
        *update the global
        global posnum`var`i''   = `pos`var`i'''
        global negnum`var`i''   = `neg`var`i'''
        global signum`var`i''   = `sigtot`var`i'''
        global poslhs`var`i''   "`poslhsadd`var`i'''"
        global neglhs`var`i''   "`neglhsadd`var`i'''"
        
        if "`display'"!=""  {
            di in y "posnum`var`i'' =" ${posnum`var`i''}
            di in y "negnum`var`i'' =" ${negnum`var`i''}
            di in y "signum`var`i'' =" ${signum`var`i''}
            di in y "poslhs`var`i'' =" ${poslhs`var`i''}
            di in y "neglhs`var`i'' =" ${neglhs`var`i''}
        }
        
        // for next round checking for same depvar
        sreturn loc lastdepvar "`e(depvar)'"
        
    }

end


  
  