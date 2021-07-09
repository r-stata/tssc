*! version 1.1.1 02apr2019 daniel klein
program elabel_cmd_remove
    version 11.2
    
    elabel parse [ anything ] [ , NOT noMEMory ] : `0'
    elabel parse elblnamelist(`memory') : `anything'
    local lblnamelist : list uniq lblnamelist
    
    elabel protectr
    
    if ("`not'"=="not") {
        quietly elabel dir , `memory'
        local alllbl `r(names)' `r(undefined)'
        local lblnamelist : list alllbl - lblnamelist
        if ("`lblnamelist'"=="") exit
    }
    
    local clanguage : char _dta[_lang_c]
    
    preserve
    
    foreach lbl of local lblnamelist {
        quietly elabel list `lbl' , varlist `memory'
        if ("`r(varlist)'"!="") label values `r(varlist)' .
        if (r(k_languages) & ("`r(lvarlists)'"!="")) {
            local lvars `r(lvarlists)'
            while ("`lvars'"!="") {
                gettoken vars  lvars : lvars , match(par)
                gettoken lname vars  : vars
                quietly label language `lname'
                label values `vars' .
            }
            quietly label language `clanguage'
        }
        if (r(exists)) elabel drop `lbl'
    }
    
    restore , not
end
exit

/* ---------------------------------------
1.1.1 02apr2019 fix bug with lblname _all
1.1.0 09feb2019 new options -not- and -nomemory-
1.0.0 02nov2018 first version
