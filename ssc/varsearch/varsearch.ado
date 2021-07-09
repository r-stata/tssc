*! varsearch
*! Version 1.4
*! 09 Dec 2005
*! by Jeff Arnold, jeffrey DOT arnold At ny DOT frb DOT org

program define varsearch, rclass
version 9
syntax [varlist],               ///
    find(string)                ///
    [ label ]                   ///

    foreach var of local varlist {

        if "`label'" == "" {
            local match = regexm("`var'","`find'")
        }
        else {
            local lbl : variable label `var'
            local match = regexm("`lbl'","`find'")
        }

        if `match' == 1 {
            local matchvar "`matchvar'`var' "
        }
    }

    * Variables returned to screen

    di 
    di as text `"Variables matching search of "`find'""'
    di

    if "`matchvar'" != "" {
        d `matchvar' 
    }
    else {
        di as res `"No variables found"'
    }

    return local varlist `"`matchvar'"'

end
