program define allsubsets

*! version 0.2
*! thomas_trikalinos@brown.edu

version 8


syntax varlist(numeric min=2 max=2) [in] [if] , save(string) ///
       [replace maxstudies(integer 20)]
    marksample touse

    preserve
        qui keep if `touse'==1
        qui keep `varlist'
        local es = word("`varlist'", 1)
        local var = word("`varlist'", 2)
    
        qui rename `es' study_ES
        qui rename `var' study_var
    
        qui count 
        local nStudies = r(N)
        local nSubsets = 2^`nStudies'-1

        if (`nStudies' >`maxstudies') {
            noi di as error "Too many possible subsets (`nSubsets')"
            exit -1
        }

        if (`nStudies' ==0 ) {
            noi di as error "No studies selected"
            exit -1
        }

        qui gen es_fem =.
        qui gen var_fem =.
        qui gen es_rem =. 
        qui gen var_rem =. 
        qui gen df= .
        qui gen Q= .
        qui gen I2 =. 
        qui gen tau2 =. 
        qui gen subset = `"                                                                                "'
    
        qui set obs `nSubsets' 
    
        plugin call allsubsetsmeta study_ES study_var ///
            es_fem var_fem es_rem var_rem ///
            df Q I2 tau2 subset , `nStudies'  

        replace subset = trim(subset)
        qui compress

        qui gen pFem_z= 2* norm(-abs(es_fem/sqrt(var_fem)))
        qui gen pRem_z= 2* norm(-abs(es_rem/sqrt(var_rem)))
        qui gen p_het = chi2tail(df, Q) if df>0
        save `"`save'"', `replace' 
    restore 
end


if (lower("`c(os)'") == "unix") {
    local platform "nix"
}
if (lower("`c(os)'") == "windows") {
    local platform "win"
}
if (lower("`c(os)'") == "macosx") {
    local platform "osx"
}

program define allsubsetsmeta, plugin using(allsubsetsmeta_`platform'.plugin)
