*! version 2.1.0 14MAr2014  -- Ph. Van Kerm  
* edit ref to del Rio et al. + calculate absolute and relative indices
* version 2.0.0 03sep2009  -- Ph. Van Kerm   
* - remove the -by- feature -- many problems with the -gen-, -tip*- options
* version 1.1 27aug2009  -- Ph. Van Kerm   
* version 1.0 7sep2004  -- Ph. Van Kerm   

program define wdiscrim , rclass sortpreserve

  version 9.2

  syntax varlist(min=2 max=2 ts) [if] [in] [fweight aweight] /*
        */ [, ///
        Format(passthru) ///
        GENerate(string) ///
        COORDinates(string) ///
        RDGC ///
        ADGC ///
        Rindex ///
        INSTall                 ///
         ]

    // parse varlist
    tempvar y r // do this to handle time-series operators (that conflict with -glcurve-)
    qui generate double `y' =  `1' 
    qui generate double `r' =  `2' 
    local yvar `1'
    local rvar `2'
    
    // --- check dependencies on user-written packages and prompt to install missing packages
    if ("`install'"!="") _check_dependencies 
    
    marksample touse 
         
    // options
    if ("`generate'"!="") {
      _my_parse_genvar generate `generate'
      if (`:word count `generate'' != 1 ) {
        di as error "option generate() invalid"
        exit 198	
      }
    }  

    if ("`coordinates'"!="") {
      _my_parse_genvar coordinates `coordinates'
      if (`:word count `coordinates'' !=4 ) {
        di as error "option coordinates() invalid"
        exit 198	
      }
    }
    if "`format'"=="" loc format "format(%4.3f)"
    
    
    capture assert `y'>0 & `r'>0 if `touse'
    if (_rc~=0) {
      count if (`y'<=0 | `r'<=0) & `touse'
      di in blue "There are negative wages. " r(N) " observations discarded!!" 
      qui replace `touse' = 0 if (`y'<=0 | `r'<=0) & `touse'
      }

            
    tempvar dis diff logdiff relgap rgap0 rgap1 rgap2 rgap3 agap0 agap1 agap2 agap3 
    qui gen byte   `dis'     = ((`r'-`y')>0) if `touse'
    qui gen double `diff'    = `r'-`y' if `touse'
    qui gen double `logdiff' = ln(`r') - ln(`y')  if `touse'
    qui gen double `relgap'    = exp(ln(`r') - ln(`y')) - 1  if `touse'
    
    qui gen double `rgap1' = max(0,((`r'-`y')/`r')) if `touse'
    if ("`rdgc'"!="") {
      qui gen double `rgap0' = sqrt(`rgap1')
      qui gen double `rgap2' = ((`rgap1')^(1.5))
      qui gen double `rgap3' = ((`rgap1')^2)
    }  
    qui gen double `agap1' = max(0,(`r'-`y')) if `touse'
    if ("`adgc'"!="") {
      qui gen double `agap0' = sqrt(`agap1')
      qui gen double `agap2' = ((`agap1')^(1.5))
      qui gen double `agap3' = ((`agap1')^2)
    }  
    
   
    * Use NJC's makematrix to compute means and percentiles of diff et log diff
    tempname Res1 
    qui makematrix `Res1' , from(r(mean) r(p10) r(p25) r(p50) r(p75) r(p90)) : su `diff' `logdiff' `relgap' `agap1' `rgap1' if `touse' [`weight'`exp'] , d 
    matrix rownames `Res1' = `"Difference [r-y]"' `"Diff of logs [log(r)-log(y)]"' `"Rel diff [exp(log(r)-log(y))-1]"' `"Max(r-y,0)"' `"Max(1-y/r,0)"'

    if ("`adgc'"!="") {
       tempname Res2 Res3 
       * Use NJC's makematrix to compute means of variaous gaps -- that's the dgc indices
       qui makematrix `Res2' , from(r(mean)) vector : su `agap0' `agap1' `agap2' `agap3' if `touse' [`weight'`exp']  
       matrix rownames `Res2' = a(1/2) a(1) a(3/2) a(2) 
   
       * Compute the EDE formulation of the indices and append to matrix of results
       matrix `Res3' = J(4,1,0)
       matrix `Res3'[1,1] = (`Res2'[1,1])^2 
       matrix `Res3'[2,1] = (`Res2'[2,1]) 
       matrix `Res3'[3,1] = (`Res2'[3,1])^(2/3) 
       matrix `Res3'[4,1] = sqrt(`Res2'[4,1]) 
       matrix `Res2' = `Res2',`Res3'
       matrix colnames `Res2' = P EDE
    }
    if ("`rdgc'"!="") {
       tempname Res22 Res33 
       * Use NJC's makematrix to compute means of variaous gaps -- that's the dgc indices
       qui makematrix `Res22' , from(r(mean)) vector : su `rgap0' `rgap1' `rgap2' `rgap3' if `touse' [`weight'`exp']  
       matrix rownames `Res22' = a(1/2) a(1) a(3/2) a(2) 
   
       * Compute the EDE formulation of the indices and append to matrix of results
       matrix `Res33' = J(4,1,0)
       matrix `Res33'[1,1] = (`Res22'[1,1])^2 
       matrix `Res33'[2,1] = (`Res22'[2,1]) 
       matrix `Res33'[3,1] = (`Res22'[3,1])^(2/3) 
       matrix `Res33'[4,1] = sqrt(`Res22'[4,1]) 
       matrix `Res22' = `Res22',`Res33'
       matrix colnames `Res22' = P EDE
    }

    
    * Get proportion of women discmirninated
    qui su `dis' if `touse' [`weight'`exp']  
    loc prop = r(mean)
    loc N = r(N)

    * Jenkins' J index:
      * Compute some additional variables:
      tempvar d d0 d1 d2 d3 d4 d5 d6 w
      qui su `y' if `touse' [`weight'`exp'] 
      loc ybar = r(mean)
      qui gen `w' = `y'/`ybar' if `touse'
      qui su `r' if `touse' [`weight'`exp'] 
      qui gen `d' = 1 + (abs(`r'-`y')/r(mean)) if `touse'
      qui gen `d0' = 0
      qui gen `d1' = `w'*(1-((`d')^-.25))
      qui gen `d2' = `w'*(1-((`d')^-.5))
      qui gen `d3' = `w'*(1-((`d')^-1))
      qui gen `d4' = `w'*(1-((`d')^-2))
      qui gen `d5' = `w'*(1-((`d')^-5))
      qui gen `d6' = `w'*(1-((`d')^-10))
      * Use NJC's makematrix to compute means of various gaps
      tempname Res4  Res5 ones
      qui makematrix `Res4' , from(r(mean)) vector : su `d0' `d1' `d2' `d3' `d4' `d5' `d6' if `touse' [`weight'`exp']  
      matrix `ones' = J(7,1,1)      
      matrix `Res5' = `ybar'*(`ones' - `Res4')
      matrix `Res4' = `Res4',`Res5'
      matrix rownames `Res4' = a(0) a(1/4) a(1/2) a(1) a(2) a(5) a(10) 
      matrix colnames `Res4' = J-index W
    
    if ("`rindex'"!="") {
      * Jenkins' R index:
        tempvar 
        loc j 0
        foreach v of numlist -10 -5 -2 -1 -0.5 -0.25 0.25 0.5 1 2 5 10 {
          tempvar r`++j'
          qui gen `r`j'' = `w'*((`d')^(`v') - 1) / `v'
        }  
        tempvar r0
        qui gen `r0' = `w'*log(`d')
        * Use NJC's makematrix to compute means of various measures
        tempname Res6
        qui makematrix `Res6' , from(r(mean)) vector : su `r1' `r2' `r3' `r4' `r5' `r6' `r0' `r7' `r8' `r9' `r10' `r11' `r12' if `touse' [`weight'`exp']  
        matrix rownames `Res6' = u(-10) u(-5) u(-2) u(-1) u(-1/2) u(-1/4) u(0) u(1/4) u(1/2) u(1) u(2) u(5) u(10) 
        matrix colnames `Res6' = R-index
     }        

    * Display:
    di as text _newline " Distribution of individual-level differentials:"
    mat list `Res1' , noblank nohal noheader nodotz `format'
    di as text _newline " Proportion discriminated: " in yellow %3.2f `prop' 
    di as text _newline " J(alpha) indices (Jenkins, 1994):" 
    mat list `Res4' , noblank nohal noheader nodotz `format'
    if ("`rindex'"!="") {
      di as text _newline " R(upsilon) indices (Jenkins, 1994):" 
      mat list `Res6' , noblank nohal noheader nodotz `format'
    }
    if ("`adgc'"!="") {
      di as text _newline " Absolute 'FGT' discrimination indices (del Rio et al., 2011):" 
      mat list `Res2' , noblank nohal noheader nodotz `format'
    }  
    if ("`rdgc'"!="") {
      di as text _newline " Relative 'FGT' discrimination indices (del Rio et al., 2011):" 
      mat list `Res22' , noblank nohal noheader nodotz `format'
    }  

   
    *  save generate:
    if "`generate'"!=""  {
      qui gen `generate' = `relgap' if `touse' 
      label variable `generate' "Relative earnings gap [exp(ln(`rvar') - ln(`yvar')) - 1]"
      return local generate "`generate'"
      } 
    if ("`coordinates'"!="")  {
      loc pvar   : word 1 of `coordinates'
      loc glyvar : word 2 of `coordinates'
      loc glrvar : word 3 of `coordinates'
      loc gldvar : word 4 of `coordinates'
      tempvar absdiff
      qui glcurve `y' if `touse' [`weight'`exp'] , gl(`glyvar') p(`pvar') nograph
      qui glcurve `r' if `touse' [`weight'`exp'] , sortvar(`pvar') gl(`glrvar') nograph
      qui gen double `absdiff' = abs(`r' - `y') if `touse'
      qui glcurve `absdiff' if `touse' [`weight'`exp'] , sortvar(`pvar') gl(`gldvar') nograph
      cap label variable `pvar' "Population share (ranked by y)"
      cap label variable `glyvar' "Gen. Lorenz curve for y"
      cap label variable `glrvar' "Gen. Conc. curve for r"
      cap label variable `gldvar' "Gen. Conc. curve for |r-y|"
      
      return local pvar "`pvar'"
      return local glyvar "`glyvar'"
      return local glrvar "`glrvar'"
      return local gldvar "`gldvar'"
      } 
      
    * Return results:
    return scalar N = `N'
    return matrix desc = `Res1'
    if ("`adgc'"!="")    return matrix adgcindex = `Res2'
    if ("`rdgc'"!="")    return matrix rdgcindex = `Res22'
    return matrix jindex = `Res4'
    if ("`rindex'"!="") return matrix rindex = `Res5'
    return scalar prop = `prop'
    return local actvar "`yvar'"
    return local refvar "`rvar'"
      

end

program define _my_parse_genvar
    version 9.2
    gettoken locname 0 : 0
    gettoken genvar genopts : 0 , parse(",")
    gettoken  comma genopts : genopts  , parse(",")
    if (trim("`genopts'")=="")  confirm new variable `genvar'
    else {
      if (trim("`genopts'")=="replace") cap drop `genvar'
      else {
        di as error "`0'  invalid"
        exit 198
      }
    }
    c_local `locname' "`genvar'"
end


pr def _check_dependencies
    di ""
    cap which makematrix 
    if (_rc>0) {
      di as text `"[1] Package {stata "findit makematrix":makematrix} by N.J. Cox missing. "' _c
      di as text `"[{stata "ssc install makematrix":click to download and install}]"'
      loc stop 1
    }
    else  di as text "[1] Package {help makematrix} by N.J. Cox already installed."

    cap which glcurve
    if (_rc>0) {
      di as text `"[2] Package {stata "findit glcurve":glcurve} by S.P. Jenkins and P. Van Kerm missing. "' _c
      di as text `"[{stata "ssc install glcurve":click to download and install}]"'
      loc stop 1
    }  
    else  di as text "[2] Package {help glcurve} by S.P. Jenkins and P. Van Kerm already installed"    
    
    if ("`stop'"=="1") {
      di 
      di as text "Some required user-written package not installed."
      exit 
    }  
end

exit

--
Philippe Van Kerm
CEPS/INSTEAD
Luxembourg
