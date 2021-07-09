*! splitvallabels.ado v1.1.2 Nicholas Winter/Ben Jann 14aug2008
program define splitvallabels, rclass
    version 8.2
    syntax varname [if] [in], [ Length(int 15) local(string) NOBreak ///
        Vals(numlist) Recode ]

    if `"`vals'"'=="" {
        qui levels `varlist' `if' `in', local(vals)
    }
    local labname : value label `varlist'
    if "`labname'"!="" {
        local j 0
        foreach val of local vals {
            local ++j
            local lab : label `labname' `val'
            if "`recode'"!="" {
                local chunk `"`j' `" "'
            }
            else {
                local chunk `"`val' `" "'
            }
            local i 1
            local part : piece `i' `length' of `"`lab'"' , `nobreak'
            while `"`part'"'!="" {
                local chunk `"`chunk'`"`part'"' "'
                local i=`i'+1
                local part : piece `i' `length' of `"`lab'"' , `nobreak'
                if `i'==2 & `"`part'"'=="" local chunk `"`chunk'"" "'
            }
            local newstring `"`newstring' `chunk'"'"'
        }
        *local newstring `"relabel(`newstring')"'
    }

    return local relabel `"`newstring'"'
    if "`local'"!="" {
        c_local `local' `newstring'
    }
end
