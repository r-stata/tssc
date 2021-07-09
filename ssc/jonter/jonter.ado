*! jonter.ado Version 2.4 2008-08-20 JRC
* Version 2.3 2007-03-07 JRC
* Version 2.2 2006-12-06 JRC
* Version 2.1 2006-11-23 JRC
* Version 2.0 2005-10-20 JRC
* touched by NJC 20 Oct 2005
* Version 1.0  2001.08.15 JRC
program define jonter, rclass sortpreserve  
    version 7.0
    syntax varname(numeric) [if] [in], BY(varname) [Verbose Jonly Continuity]
    confirm numeric variable `by' 
    marksample touse 
    markout `touse' `by'

    quietly count if `touse'
    if r(N) == 0 {
        error 2000
    }

    if "`verbose'" == "" {
        local verbose *
    }
    else {
        local verbose
    }

    tempvar group 
    bysort `touse' `by': generate byte `group' = (_n == 1) * `touse' 
    quietly by `touse': replace `group' = sum(`group') 
    summarize `group', meanonly 
    local max_grp = r(max)
    quietly count if !`touse' 
    local cum_n_grp = r(N)
    return scalar J = 0  
	
    forvalues grp = 1/`= `max_grp' - 1' { 
        quietly count if `group' == `grp' 
        local max_n_grp = `cum_n_grp' + r(N)
        local cum_n_nex = `max_n_grp' 
        forvalues nex = `=`grp' + 1'/`max_grp' { 
            quietly count if `group' == `nex' 
            local max_n_nex = `cum_n_nex' + r(N)
            local U = 0  
            forvalues n_grp = `=`cum_n_grp' + 1'/`max_n_grp' { 
                local Phi = 0 
                forvalues n_nex = `=`cum_n_nex' + 1'/`max_n_nex' { 
                    local phi = (`varlist'[`n_grp'] < `varlist'[`n_nex']) + 0.5 * (`varlist'[`n_grp'] == `varlist'[`n_nex']) 
                    local Phi = `Phi' + `phi' 
                }
                local U = `U' + `Phi' 
            }
            local cum_n_nex = `max_n_nex' 
            summarize `by' if `group' == `grp', meanonly
            local by1 = r(min)
            summarize `by' if `group' == `nex', meanonly
            local by2 = r(min) 
`verbose'   display in smcl as text "U`by1',`by2'  = " as result `U' 
            return scalar J = return(J) + `U' 
        }
        local cum_n_grp = `max_n_grp' 
    }

    if ("`jonly'" != "") {
        exit
    }
    display
    display in smcl as text "Jonckheere-Terpstra Test for Ordered Alternatives"
    display
    display in smcl as text "       J  = " as result return(J)
	
    tempvar work tj Atj Btj Ctj ni Ani Bni Cni
    tempname a b N At Bt Ct An Bn Cn NNM1
    by `touse' `by': generate long `work' = _N  * (_n == 1) * `touse' 
    summarize `work', meanonly 
    scalar define `N' = r(sum)
    quietly replace `work' = `work' * `work'
    summarize `work', meanonly
    scalar define `a' = r(sum)
* Correction of J* for tied values, if any
    preserve
    contract `varlist' if `touse', freq(`tj') nomiss
    capture assert (`tj' == 1)
    if _rc {
        generate double `Ctj' = `tj' * (`tj' - 1)
        generate double `Atj' = `Ctj' * (2 * `tj' + 5)
        generate double `Btj' = `Ctj' * (`tj' - 2)
        summarize `Atj', meanonly
        scalar define `At' = r(sum)
        summarize `Btj', meanonly
        scalar define `Bt' = r(sum)
        summarize `Ctj', meanonly
        scalar define `Ct' = r(sum)
        restore
        preserve
        contract `by' if `touse', freq(`ni')
        generate double `Cni' = `ni' * (`ni' - 1)
        generate double `Ani' = `Cni' * (2 * `ni' + 5)
        generate double `Bni' = `Cni' * (`ni' - 2)
        summarize `Ani', meanonly
        scalar define `An' = r(sum)
        summarize `Bni', meanonly
        scalar define `Bn' = r(sum)
        summarize `Cni', meanonly
        scalar define `Cn' = r(sum)
        restore
        scalar define `NNM1' = `N' * (`N' - 1)
        return scalar se_JH0 = sqrt( (`NNM1' * (2 * `N' + 5) - `An' - `At') / 72 + /*
          */ `Bn' * `Bt' / (36 * `NNM1' * (`N' - 2)) + /*
          */ `Cn' * `Ct' / (8 * `NNM1') )
        local tiescc (corrected for ties, with continuity correction)
        local ties (corrected for ties)
    }
    else {
        restore
        quietly by `touse' `by': replace `work' = `work' * (2 * _N + 3)
        summarize `work', meanonly 
        scalar define `b' = r(sum)
        return scalar se_JH0 = sqrt((`N' * `N' * (2 * `N' + 3) - `b') / 72)
        local tiescc (with continuity correction)
        local ties
    }
    return scalar JH0 = (`N' * `N' - `a') / 4 
* Continuity correction
    if "`continuity'" == "" {
        return scalar Jstar = ( return(J) - return(JH0) ) / return(se_JH0)
        display in smcl as text "       J* = " as result %05.3f return(Jstar) as text " `ties'"
    }
    else {
        return scalar Jstar = return(J) - return(JH0)
        return scalar Jstar = ( return(Jstar) - sign(return(Jstar)) / 2 ) / return(se_JH0)
        display in smcl as text "       J* = " as result %05.3f return(Jstar) as text " `tiescc'"
    }

    display in smcl _newline(1)
    return scalar p = 2 * norm(-abs(return(Jstar)))
    display in smcl as text "Pr(|Z| > |J*|) = " as result %06.4f return(p) as text " (ordered alternative in either direction)"

    return scalar p_l = norm(return(Jstar))
    display in smcl as text "    Pr(Z > J*) = " as result %06.4f return(p_l) as text " (descending ordered alternative)"

    return scalar p_u = norm(-(return(Jstar)))
    display in smcl as text "    Pr(Z < J*) = " as result %06.4f return(p_u) as text " (ascending ordered alternative)"

    return scalar N = `N'
end
