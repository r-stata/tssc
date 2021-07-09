*! version 1.5.0 18jun2020 daniel klein
program elabel_fcn_levels , properties(elabel_vvl elabel_aa elabel_mm)
    version 11.2
    
    elabel fcncall define lblnames 0  : `0'
    syntax varlist(max=2) [ if ] [ in ] ///
    [ ,                                 ///
        Add MODIFY REPLACE noFIX        ///
        APPEND MERGE(passthru)          ///
        SEParator(string asis)          ///
        UNIQue FORCE                    ///
    ]
    
    marksample touse , novarlist
    
    if (`: word count `varlist'' == 2) {
        if ("`unique'" != "") {
            display as err "option uniq not allowed"
            exit 198
        }
        gettoken values varlist : varlist
        confirm_integer_variable `values' if `touse'
    }
    
    gettoken labels varlist : varlist
    capture noisily confirm string variable `labels'
    if (_rc) exit 109
    
    if (`"`separator'"' != "") local force force
    
    tempname tmplbl
    mata : elabel_fcn_levels()
    
    elabel parse elblnamelist(newlblnamelist varvaluelabel) : `lblnames'
    foreach lbl of local lblnamelist {
        elabel copy `tmplbl' `lbl' ///
            , `add' `modify' `replace' `append' `merge' `fix'
    }
    elabel varvaluelabel `varvaluelabel' , `fix'
end

program confirm_integer_variable
    syntax varname(numeric) [ if ]
    capture assert (`varlist'==trunc(`varlist')) `if'
    if (!_rc) {
        capture assert (`varlist'!=.) `if'
        if (!_rc) exit
        local bad system missing
    }
    else local bad noninteger
    display as err "`varlist' may not contain `bad' values"
    exit 498
end

version 11.2

mata :

mata set matastrict on

void elabel_fcn_levels()
{
    string colvector    labels
    real   colvector    values
    string rowvector    sep
    transmorphic scalar vl
    
    labels = st_sdata(., st_local("labels"), st_local("touse"))
    if (st_local("unique") == "unique") labels = auniq(labels')'
    values = (st_local("values") == "") ? (1::rows(labels)) :
              st_data(., st_local("values"), st_local("touse"))
    if (st_local("force") != "force") 
        elabel_fcn_levels_uniq(values, labels)    
    if ( cols((sep=tokens(st_local("separator")))) ) {
        if (cols(sep) > 1) {
            errprintf("option separator() invalid\n")
            exit(198)
        }
        vl = elabel_vlinit(st_local("tmplbl"), values, labels, sep)
        values = elabel_vlvalues(vl)
        labels = elabel_vllabels(vl)
    }
    st_vlmodify(st_local("tmplbl"), values, labels)
}

void elabel_fcn_levels_uniq(real colvector values, string colvector labels)
{
    string matrix    vlab
    real   colvector dups
    
    vlab = (strofreal(values), labels)
    dups = (_distinctrowsof(vlab) - _distinctrowsof(values))
    if (!any(dups)) return
    errprintf("value %f", select(values, dups)[1])
    errprintf(" mapped to more than one label\n")
    exit(498)
}

end
exit

/* ---------------------------------------
1.5.0 18jun2020 new option -separator()-
                support option -merge-; properties elabel_mm
1.4.0 01feb2020 re-rename -join- -append-; properties elabel_aa
1.3.2 11nov2019 program properties elabel_jn
1.3.1 14nov2019 rename option -append- -join-
1.3.0 23oct2019 support option -append-
1.2.0 02aug2019 support varname:elblname
1.1.1 15jul2019 set matastrict on
1.1.0 24may2019 bug fix fcn must be called by -elabel define-
                new option -uniq-
1.0.0 02apr2019 first version
