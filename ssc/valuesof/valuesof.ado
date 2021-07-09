*! version 1.0.2  Ben Jann  20may2008
program valuesof
    version 9.1, born(20Jan2006)
    capt mata mata which mm_invtokens()
    if _rc {
        di as error "mm_invtokens() from -moremata- is required; type {stata ssc install moremata}"
        error 499
    }
    syntax varname [if] [in] [, Format(str) MISSing ]
    mata: st_rclear()
    if `"`missing'"'=="" marksample touse, strok
    else marksample touse, strok nov
    capt confirm string var `varlist'
    if _rc {
        local dp = c(dp)
        set dp period
        if `"`format'"'=="" local format "%18.0g"
        else confirm format `format'
        mata: st_global("r(values)", ///
         mm_invtokens(strofreal(st_data(.,"`varlist'","`touse'")', `"`format'"')))
        set dp `dp'
    }
    else {
        mata: st_global("r(values)", ///
         mm_invtokens(st_sdata(.,"`varlist'","`touse'")'))
    }
    di `"`r(values)'"'
end
