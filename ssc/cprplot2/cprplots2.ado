*! version 1.0.1  16sep2008  Ben Jann
program define cprplots2
    version 8.2

    _isfit cons anovaok
    syntax [anything(id="varlist")] [if] [in] [, RETRansform(string asis) ///
     YRETRansform(string asis) altshrink * ]
    local varlist `"`anything'"'

    _get_gropts , graphopts(`options') getcombine getallowed(plot)
    local options `"`s(graphopts)'"'
    local gcopts `"`s(combineopts)'"'
    if `"`s(plot)'"' != "" {
        di in red "option plot() not allowed"
        exit 198
    }

    if `"`varlist'"'=="" {
        if "`e(cmd)'" == "anova" {
            anova_terms
            local varlist `r(continuous)'
        }
        else _getrhs varlist
    }

    local transform `"`retransform'"'
    local ytransform `"`yretransform'"'
    local i 0
    foreach var of local varlist {
        local ++i
        if `:list sizeof retransform' > 1 {
            local transform: word `i' of `retransform'
        }
        if `:list sizeof yretransform' > 1 {
            local ytransform: word `i' of `yretransform'
        }
        tempname tname
        cprplot2 `var' `if' `in', retransform(`transform') yretransform(`ytransform') ///
         name(`tname') nodraw `options'
        capt graph describe `tname'
        if _rc di as txt `"`var': graph dropped"'
        else local names `names' `tname'
    }

    if "`names'"!="" {
        graph combine `names' , `gcopts' `altshrink'
        graph drop `names'
    }
end
