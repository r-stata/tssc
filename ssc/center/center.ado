*! version 1.10, Ben Jann, 13apr2017
*! - now also allows iweights and pweights
*! - now displays note about modified/generated variables
*! - conflict between inplace and replace fixed
*! - addlabel("") now removes the default label suffix
*! version 1.09, Ben Jann, 31jan2014
*! - option inplace: now replaces all obs within [if] and [in] even if casewise
*!   is specified
*! version 1.08, Ben Jann, 01sep2013
*! - option inplace added
*! version 1.07, Ben Jann, 22feb2006
program define center, byable(onecall) sortpreserve
    version 7.0
    syntax varlist(numeric) [if] [in] [aw iw pw fw/] [, PREfix(string) /*
        */ noLabel Addtolabel(string asis) Replace Double Standardize /*
        */ MEANsave MEANsave2(string) SDsave SDsave2(string) Casewise /*
        */ THeta(string) Generate(string) Inplace ]
    
    /* inplace, generate, prefix */
    if "`inplace'"!="" {
        if `"`prefix'"'!="" {
            di as error "prefix() not allowed with inplace"
            exit 198
        }
        if `"`generate'"'!="" {
            di as error "generate() not allowed with inplace"
            exit 198
        }
        local prefix
    }
    else if `"`generate'"'!="" {
        if `"`prefix'"'!="" {
            di as error "prefix() not allowed if generate() is specified"
            exit 198
        }
        local nvars: word count `varlist'
        if `nvars'>1 {
            di as error "too many variables specified"
            exit 103
        }
        confirm name `generate'
        local prefix `"`generate'"'
    }
    else if `"`prefix'"'!="" {
        confirm name `prefix'
    }
    else {
        local prefix "c_"
    }

    /* theta option */
    if `"`theta'"'!="" {
        capture confirm number `theta'
        if _rc {
            capture confirm numeric variable `theta'
            if _rc {
                di as error "invalid specification of theta()"
                exit 198
            }
        }
    }
    else {
        local theta 1
    }
    
    /* meansave and sdsave */
    if "`meansave'"!="" {
        local meansave "m_`generate'"
    }
    if "`meansave2'"!="" {
        local meansave "`meansave2'"
    }
    if "`meansave'"!="" {
        confirm name `meansave'
    }
    if "`sdsave'"!="" {
        local sdsave "sd_`generate'"
    }
    if "`sdsave2'"!="" {
        local sdsave "`sdsave2'"
    }
    if "`sdsave'"!="" {
        if "`standardize'"=="" {
            di as error "sdsave not allowed unless standardize is specified"
            exit 198
         }
         confirm name `sdsave'
    }

    /* check variable names */
    local xpre=cond("`inplace'"=="","prefix","")
    local mpre=cond("`meansave'"!="","meansave","")
    local sdpre=cond("`sdsave'"!="","sdsave","")
    foreach name of local varlist {
        if "`generate'"=="" {
            local nname `name'
        }
        foreach pre in `xpre' `mpre' `sdpre' {
        capture confirm new variable ``pre''`nname'
            if _rc {
                if "`replace'"!=""{
                    drop ``pre''`nname'
                }
                else {
                    di as error "``pre''`nname' already defined or invalid name"
                    exit 110
                }
            }
         }
    }

    /* addtolabel option */
    if "`label'"=="" {
        if `"`addtolabel'"'==`""""' {
            local addtolabel
        }
        else if `"`addtolabel'"'==`""' {
            if "`standardize'"!="" {
                local addtolabel " (standardized)"
            }
            else {
                local addtolabel " (centered)"
            }
        }
        else {
            stripquotes_from_addtolabel, addtolabel(`addtolabel')
        }
        local llength=80-length(`"`addtolabel'"')
    }

    /* mark sample */
    if "`casewise'"=="" {
        marksample touse, novarlist
    }
    else {
        marksample touse
    }

    /* weights and standardize option */
    if "`exp'"=="" {
        local exp "\`name'!=."
    }
    if "`standardize'"!="" {
        if inlist("`weight'", "fweight", "iweight") {
            local exp2 "`exp'"
        }
        else {
            local exp2 "\`name'!=."
         }
         tempvar sd
    }
    else {
        local sd 1
    }

    /* generate centered/standardized variables */
    tempvar mean
    local newvars
    local modvars
    sort `touse' `_byvars'
    foreach name of local varlist {
        if "`generate'"=="" {
            local nname `name'
        }
        quietly {
            by `touse' `_byvars': gen `double' `mean' = /*
                */ sum((`exp')*`name') / sum((`exp')*(`name'!=.)) if `touse'
            by `touse' `_byvars': replace `mean' = `mean'[_N]
            if "`standardize'"!="" {
                by `touse' `_byvars': gen `double' `sd' = /*
                    */ sum((`exp')*(`name'!=.)) - sum((`exp')*(`name'!=.)) /*
                    */ / sum((`exp2')*(`name'!=.)) if `touse'
                by `touse' `_byvars': replace `sd' = /*
                    */ sum((`exp')*(`name'-`mean')^2) / `sd' if `touse'
                by `touse' `_byvars': replace `sd' = sqrt(`sd'[_N])
            }
            if "`inplace'"!="" {
                replace `name' = (`name' - `theta'*`mean') / `sd' `if' `in' /*!*/
                local modvars `modvars' `name'
            }
            else {
                gen `double' `prefix'`nname' = (`name' - `theta'*`mean') /*
                    */ / `sd' if `touse'
                local newvars `newvars' `prefix'`nname'
            }
        }
        if "`meansave'"!="" {
            qui replace `mean'=. if `name'==.
            rename `mean' `meansave'`nname'
            local newvars `newvars' `meansave'`nname'
        }
        else {
            drop `mean'
        }
        if "`sdsave'"!="" {
            qui replace `sd'=. if `name'==.
            rename `sd' `sdsave'`nname'
            local newvars `newvars' `sdsave'`nname'
        }
        else if "`standardize'"!="" {
            drop `sd'
        }
        if "`label'"=="" {
            local lab: var l `name'
            if `"`lab'"'=="" {
                local lab `name'
            }
            local lab=substr(`"`lab'"',1,`llength')
            lab var `prefix'`nname' `"`lab'`addtolabel'"'
            if "`meansave'"!="" {
                lab var `meansave'`nname' `"mean(s) of `name'"'
            }
            if "`sdsave'"!="" {
                lab var `sdsave'`nname' `"std. deviation(s) of `name'"'
            }
        }
    }
    
    /* output note */
    if `"`modvars'"'!="" {
        di as txt `"(modified variables: `modvars')"'
    }
    if `"`newvars'"'!="" {
        di as txt `"(generated variables: `newvars')"'
    }
end

program stripquotes_from_addtolabel
    syntax [ , addtolabel(string) ]
    c_local addtolabel `"`addtolabel'"'
end
