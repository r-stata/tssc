*! version 1.4.1  02feb2005  by Marc-Andreas Muendler muendler@econ.ucsd.edu
*! option shvars() added to take varlist  01dec2002
capture program drop est2vec
program define est2vec
    version 7
    args matini
    local matini = subinstr("`matini'",",","",1)
    capture syntax newvarname [, Vars(string) SHVars(varlist) E(string) R(string) ADDto(string) RADDto(string) NAme(string) FORCE noKEEP REPLACE ]
    if _rc==111 {
        syntax [newvarname] [, Vars(string) SHVars(string) E(string) R(string) ADDto(string) RADDto(string) NAme(string) FORCE noKEEP REPLACE ]
        foreach name of local shvars {
            local name = subinstr("`name'","-"," ",.)
            capture confirm variable `name'
            if _rc~=198 { confirm variable `name' }
            }
        }
    if _rc==100 {
        syntax [newvarname] [, Vars(string) SHVars(varlist) E(string) R(string) ADDto(string) RADDto(string) NAme(string) FORCE noKEEP REPLACE ]
        if "`addto'"~=""  {local matini = "`addto'"}
        if "`raddto'"~="" {local matini = "`raddto'"}
        if "`matini'"=="" {disp as err "matrix name required" 
                           exit _rc}
        }
disp "`shvars'"        
    if _rc~=0 & _rc~=100 { error _rc }

    if "`matini'"=="`addto'" || "`matini'"=="`raddto'" {local keep = "nokeep"}

    /* Names of vectors */
    if "`keep'"=="nokeep" {tempname `matini'_b                /* temporary names */
                           tempname `matini'_se
                           tempname `matini'_e
                           tempname `matini'_r
                           }
    else                  {local `matini'_b  = "`matini'_b"   /* permanent vectors */
                           local `matini'_se = "`matini'_se"
                           local `matini'_e  = "`matini'_e"
                           local `matini'_r  = "`matini'_r"
                           }  

    if "`vars'"~="" { local shvars = "" }
    if "`addto'"=="" & "`raddto'"=="" & "`replace'"~="replace" {
            tempname chk
            if "`r'" == "" {
              foreach type in b se e {
                capture local `chk' = colsof(``matini'_`type'')
                if _rc==0 {
                  disp as err "no; matrix " in yellow "``matini'_`type''" in red " would be lost"
                  exit 4 
                  }
                }
              }
            else {
                capture local `chk' = colsof(``matini'_r')
                if _rc==0 {
                  disp as err "no; matrix " in yellow "``matini'_r'" in red " would be lost"
                  exit 4 
                  }
              }
        }
    if "`keep'"=="nokeep" & ("`addto'"=="" & "`raddto'"=="") {
            disp as err "nokeep without addto() or raddto() invalid"
            exit 198
            }
    if "`addto'"~="" & "`raddto'"~="" {
            disp as err "use of addto() and raddto() invalid"
            exit 198
            }
    if "`addto'"~="" {
        if "`vars'"~="" || "`shvars'"~="" || "`e'"~="" || "`r'"~="" {
            disp as err "use of addto() invalid in combination with other options"
            exit 198
            }
        tempname tst
        foreach type in b se e {
            local `tst' = colsof(`addto'_`type')
            }
        local colnames : colfullnames `addto'_b
        local colmax = colsof(`addto'_b)
        tokenize `colnames'
        forvalues i = 1/`colmax' {
            if "``i''"=="`name'" {
                disp as err "column name ``i'' not unique or already defined"
                exit 110
                }
            if "`name'"=="" & "``i''"=="`e(depvar)'" {
                disp as err "column name ``i'' not unique or already defined"
                exit 110
                }
            }
        }
    if "`raddto'"~="" {
        if "`vars'"~="" || "`shvars'"~="" || "`e'"~="" || "`r'"~="" {
            disp as err "use of raddto() invalid"
            exit 198
            }
        tempname tst
        local `tst' = colsof(`raddto'_r)
        local colnames : colfullnames `raddto'_r
        local colmax = colsof(`raddto'_r)
        tokenize `colnames'
        forvalues i = 1/`colmax' {
            if "``i''"=="`name'" {
                disp as err "column name ``i'' not unique or already defined"
                exit 110
                }
            if "`name'"=="" & "``i''"=="`e(depvar)'" {
                disp as err "column name ``i'' not unique or already defined"
                exit 110
                }
            }
        }
    if "`vars'"~="" & "`r'"~="" {
        disp as err "combination vars() and r() invalid"
        exit 198
        }
    if "`shvars'"~="" & "`r'"~="" {
        disp as err "combination shvars() and r() invalid"
        exit 198
        }
    if "`e'"~="" & "`r'"~="" {
        disp as err "combination e() and r() invalid"
        exit 198
        }
    if "`addto'"=="" & "`force'"=="force" {
            disp as err "use of force without addto() invalid"
            exit 198
            }
    if "`shvars'"~="" & "`force'"=="force" {
        disp as err "use of force with shvars() invalid"
        exit 198
        }

    /* Start working */

    local eqon = 0
    local roweq = ""
    if "`addto'"~="" {
        local vars : rowfullnames `addto'_b
        local e : rowfullnames `addto'_e
        local prveq : roweq `addto'_b
        tempname tmpchk
        matrix `tmpchk' = e(b)'
        local neweq : roweq `tmpchk'
        if "`neweq'" ~= "" {local eqon = 1}
        }
    if "`raddto'"~="" { local r : rowfullnames `raddto'_r }

    tempname tmpb tmpse tmpe tmpr
    if "`vars'" == "" & "`shvars'" == "" & "`r'"=="" {  /* If no vars spec.: use all regressors */
        matrix `tmpb' = e(b)'
        matrix `tmpse' = vecdiag(e(V))'
        local rownmb = rowsof(`tmpse')
        forvalues r = 1/`rownmb' { matrix `tmpse'[`r',1]=sqrt(`tmpse'[`r',1]) }
        }
    if "`vars'" ~= "" & "`r'"=="" {   /* If addto(), vars : rowfullnames `addto'_b */
        local varnum : word count `vars'
        matrix `tmpb'  = J(`varnum',1,-999)
        matrix rownames `tmpb' = `vars'
        matrix `tmpse' = J(`varnum',1,-999)
        matrix rownames `tmpse' = `vars'
        if "`force'" == "force" {matrix roweq `tmpb' = `neweq'
                                 matrix roweq `tmpse' = `neweq'
                                 local vars : rowfullnames `tmpb'}
        local i = 0
        foreach var of local vars {
            local i = `i' + 1
            tokenize "`var'", parse(":")
            if "`3'" == "" {local 3 = "`1'"
                            local 1 = "#1"}
            capture matrix `tmpb'[`i',1]  =  [`1']_b[`3']
            capture matrix `tmpse'[`i',1] =  [`1']_se[`3']
            if _rc~=0 & _rc~=111 & _rc~=303 { error _rc }
            }
        }
    if "`shvars'" ~= "" & "`r'"=="" {
        local varnum : word count `shvars'
        local varnum = `varnum' + 1
        matrix `tmpb'  = J(`varnum',1,-999)
        matrix rownames `tmpb' = `shvars' _cons
        matrix `tmpse' = J(`varnum',1,-999)
        matrix rownames `tmpse' = `shvars' _cons
        local i = 0
        foreach var of local shvars {
            local i = `i' + 1
            capture matrix `tmpb'[`i',1]  =  _b[`var']
            capture matrix `tmpse'[`i',1] =  _se[`var']
            if _rc~=0 & _rc~=111 & _rc~=303 {error _rc}
            }
        capture matrix `tmpb'[`varnum',1]  =  _b[_cons]
        capture matrix `tmpse'[`varnum',1] =  _se[_cons]
        if _rc~=0 & _rc~=111 & _rc~=303 {error _rc}
        }
    if "`r'"=="" {  /* Matrix replacement and naming, and treatment of e() */
        matrix ``matini'_b' = `tmpb'
        tokenize "`e(depvar)'"
        if "`name'"=="" {matname ``matini'_b'  `1' , columns(1) explicit}
        else            {matname ``matini'_b'  `name' , columns(1) explicit}
        matrix ``matini'_se' = `tmpse'
        if "`name'"=="" {matname ``matini'_se' `1' , columns(1) explicit}
        else            {matname ``matini'_se' `name' , columns(1) explicit}
        if `e(N)'~=. {matrix input `tmpe' = (`e(N)')}
        else {matrix input `tmpe' = (-999)}
        matrix ``matini'_e' = `tmpe'
        matname ``matini'_e' "e(N)" , rows(1) explicit
        if "`name'"=="" {matname ``matini'_e' `1' , columns(1) explicit}
        else            {matname ``matini'_e' `name' , columns(1) explicit}
        foreach savres in `e' {  
           if "`addto'"~="" {
                local savres = subinstr("`savres'","e(","",1)
                local savres = subinstr("`savres'",")","",1)
                } 
           if "`savres'" ~= "N" {  
             matrix drop `tmpe'
             matrix input `tmpe' = (-999)
             capture if `e(`savres')'~=.    {matrix input `tmpe' = (`e(`savres')')}
             capture if "`e(`savres')'"~="" {matrix input `tmpe' = (`e(`savres')')}
             matrix ``matini'_e'=``matini'_e' \ `tmpe'
             local rowid = rowsof(``matini'_e')
             matname ``matini'_e' "e(`savres')" , rows(`rowid') explicit
             } 
            }
        if "`addto'"~="" {   /* Addto routine */
            foreach type in b se e {
                capture matrix `addto'_`type' = `addto'_`type' , ``matini'_`type''
                if _rc==503 {
                       disp as err "conformability error in rows of `addto'_`type' and `matini'_`type'"
                       exit _rc
                }
                if _rc~=0 {error _rc}
                }
            }
    }
    else {  /* Treat r() */
        tempname `matini'_nwr
        matrix ``matini'_nwr' = (-999)
        matname ``matini'_nwr' "_todelete" , rows(1) explicit
        tokenize "`e(depvar)'"
        if "`name'"=="" {matname ``matini'_nwr' `1' , columns(1) explicit}
        else            {matname ``matini'_nwr' `name' , columns(1) explicit}       
        foreach savres in `r' {
           if "`raddto'"~="" {
                local savres = subinstr("`savres'","r(","",1)
                local savres = subinstr("`savres'",")","",1)
                } 
             capture matrix drop `tmpr'
             matrix input `tmpr' = (-999)
             capture if `r(`savres')'~=.    {matrix input `tmpr' = (`r(`savres')')}
             capture if "`r(`savres')'"~="" {matrix input `tmpr' = (`r(`savres')')}
             matrix ``matini'_nwr'=``matini'_nwr' \ `tmpr'
             local rowid = rowsof(``matini'_nwr')
             matname ``matini'_nwr' "r(`savres')" , rows(`rowid') explicit
           }
        if "`raddto'"~="" {
                matrix ``matini'_nwr' = ``matini'_nwr'[2..rowsof(``matini'_nwr'),1]
                capture matrix `raddto'_r = `raddto'_r , ``matini'_nwr'
                if _rc~=0 {
                    if _rc==503 {
                        disp as err "conformability error in rows of `raddto'_r and `matini'_r"
                        exit _rc
                        }
                    else {error _rc}
                }
            }
        else {matrix ``matini'_r' = ``matini'_nwr'[2..rowsof(``matini'_nwr'),1]}
        matrix drop ``matini'_nwr'
    }
end
