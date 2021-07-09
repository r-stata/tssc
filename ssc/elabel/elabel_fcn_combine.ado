*! version 1.5.0 18jun2020 daniel klein
program elabel_fcn_combine , properties(elabel_vvl elabel_aa elabel_mm)
    version 11.2
    
    elabel fcncall define define args  : `0'
    
    elabel parse elblnamelist(newlblnamelist varvaluelabel) : `define'
    local define : copy local lblnamelist
    
    if (_caller() >= 16) local f f
    elabel parse elblnamelist [ if`f' ] ///
    [ ,                                 ///
        Add                             ///
        MODIFY                          ///
        REPLACE                         ///
        APPEND                          ///
        MERGE(passthru)                 ///
        noFIX                           ///
        UPDATE                          ///
        SEParator(string asis)          ///
    ] : `args'
    
    local nlbl : word count `lblnamelist'
    tokenize                `lblnamelist'
    
    if (`"`separator'"' != "") {
        gettoken discard void : separator
        if (`"`void'"' != "") {
            display as err "option separator() invalid"
            exit 198
        }
        local update update
    }
    
    if ( mi("`update'") ) local range `nlbl'(-1)1
    else                  local range    1/`nlbl'
    
    tempname tmplbl
    forvalues i = `range' {
        elabel copy ``i'' `tmplbl' `if`f'' , modify merge(`separator')
    }
    foreach lbl of local define {
        elabel copy `tmplbl' `lbl' ///
            , `add' `modify' `replace' `append' `merge' `fix'
    }
    elabel varvaluelabel `varvaluelabel' , `fix'
end
exit

/* ---------------------------------------
1.5.0 18jun2020 new option -separator()-
                support option -merge-; properties elabel_mm
1.4.0 01feb2020 re-rename -join- -append-; properties elabel_aa 
1.3.2 11dec2019 program properties elabel_jn
1.3.1 14nov2019 rename option -append- -join-
1.3.0 23oct2019 support option -append-
1.2.0 02aug2019 support varname:elblname
1.1.0 03jun2019 use -iff- in place of -if-
1.0.1 24may2019 bug fix fcn must be called by -elabel define-
                rewrite code changing order of lblnamelist
1.0.0 02apr2019 first version
