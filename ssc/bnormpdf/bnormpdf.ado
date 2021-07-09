*! 1.1.0 GML 08 January 2004
*  1.0.0 GML 10 January 2002
pro def bnormpdf
    version 8
    syntax varlist(min=2 max=2) [if] [in], Dens(string) [ M1(real 0) M2(real 0) /*
      */   S1(real 1) S2(real 1) Rho(real 0) REPLACE DOUble ]
    tokenize `varlist'
    local x1 "`1'"
    local x2 "`2'"
    marksample touse
    cap assert `s1' > 0 & `s2' > 0
    if _rc~=0 {
        di as error "args to s1() and s2() must be > 0"
        error _rc
    }
    cap assert abs(`rho') < 1
    if _rc~=0 {
        di as error "arg to rho() must be between -1 and 1"
        error _rc
    }
    if "`dens'"!=`""' {
        local varnum : word count `dens'
        cap assert `varnum' == 1
        if _rc~=0 {
            di as error "more than one newvar name in dens( ) option"
            error _rc
        }
    }
    if `"`replace'"'!=`""' {
        cap drop `dens'
    }
    else {
        cap confirm new variable `dens'
        if _rc~=0 {
            di as error "variable `dens' already exists,"
            di as error `"  use "replace" option to replace `dens'"'
            error _rc
        }
    }
    /* it seems Stata matrix size limitations won't allow calculating this using
       matrix notation , i.e. can't calc the quadratic form:
         (X - mu)Sigma_inverse(X - mu)'  ?
       The following form is from Bickel and Doksum, p.23-4
    */
    #delimit ;
    gen `double' `dens' = (1.0/(2.0*_pi*`s1'*`s2'*sqrt(1.0 - `rho'^2)))  *
                 exp( (-1/(2*(1.0-`rho'^2))) *
                      (   (((`x1'-`m1')/`s1')^2)
                        - (2 *`rho'* ((`x1'-`m1')/`s1') * ((`x2'-`m2')/`s2'))
                        + (((`x2'-`m2')/`s2')^2)
                      )
                    )
         if `touse'
    ;
    #delimit cr
end
