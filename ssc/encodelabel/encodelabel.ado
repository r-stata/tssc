*! version 1.2.0 daniel klein 06nov2020
program encodelabel
    version 11.2
    
    syntax varname(string) [ if ] [ in ] ///
    , Label(name) [ Generate(name) REPLACE MIN(integer 1) noSORT ]
    
    if ("`replace'" == "replace") {
        if ("`generate'" != "") {
            display as err "only one of generate() or replace allowed"
            exit 198
        }
        tempvar generate
    }
    else if ( mi("`generate'") ) {
        display as err "option generate() or replace required"
        exit 198
    }
    else confirm new variable `generate'
    
    tempname tmplbl
    label copy `label' `tmplbl'
    
    marksample touse , strok
    
    capture noisily {
        mata : encodelabel("`varlist'", "`touse'", "`label'", `min', "`sort'")
        encode `varlist' if `touse' , generate(`generate') label(`label')
    }
    if ( _rc ) {
        label copy `tmplbl' `label' , replace
        exit _rc
    }
    
    if ("`replace'" != "replace") exit
    
    nobreak {
        order `generate' , after(`varlist')
        drop `varlist'
        rename `generate' `varlist' 
    }
end

version 11.2

mata :

mata set matastrict on

void encodelabel(string scalar vname, 
                 string scalar touse, 
                 string scalar lname,
                 real   scalar count,
                 string scalar nosort)
{
    string       colvector levels
    real         colvector values
    string       colvector labels
    real         scalar    i
    
    levels = st_sdata(., vname, touse)
    if (nosort != "nosort") levels = uniqrows(levels)
    
    pragma unset values
    pragma unset labels
    
    st_vlload(lname, values, labels)
    values = select(values, ((values:>=count) :& (values:<.)))
    
    for (i=1; i<=rows(levels); ++i) {
        if (st_vlsearch(lname, levels[i]) != .) continue
        while ( anyof(values, count) ) count++
        st_vlmodify(lname, count++, levels[i])
    }
    
    if (--count > c("max_N_theory")) {
        errprintf("may not label %f\n", count)
        exit(198)
    }
}

end
exit

/* ---------------------------------------
1.2.0 06nov2020 add option -nosort-
                preserve value label
                rewrite Mata code
1.1.0 30oct2020 add option -replace-
1.0.1 16oct2020 bug fix multiple nullstrings
1.0.0 15oct2020 posted to Statalist
