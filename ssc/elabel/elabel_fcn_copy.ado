*! version 1.5.0 18jun2020 daniel klein
program elabel_fcn_copy , properties(elabel_vvl elabel_aa elabel_mm)
    version 11.2
    elabel fcncall * subcmd names 0 : `0'
    version `= _caller()' : copy_`subcmd' (`names') `0'
end

program copy_variable
    gettoken variables 0 : 0 , match(p)
    syntax varname
    local label : variable label `varlist'
    elabel variable (`variables') (`"`macval(label)'"')
end

program copy_define
    gettoken define 0 : 0 , match(p)
    elabel parse elblnamelist(newlblnamelist varvaluelabel) : `define'
    local define : copy local lblnamelist
    if (_caller() >= 16) local f f
    elabel parse elblnamelist [ if`f' ] ///
        , [ Add MODIFY REPLACE APPEND MERGE(passthru) noFIX ] : `0'
    local iff : copy local if`f'
    local   0 : copy local lblnamelist
    syntax name(id = "elblname")
    foreach d of local define {
        elabel copy `lblnamelist' `d' `iff' ///
            , `add' `modify' `replace' `append' `merge' `fix'
    }
    elabel varvaluelabel `varvaluelabel' , `fix'
end
exit

/* ---------------------------------------
1.5.0 18jun2020 support option -merge-; properties elabel_mm
1.4.0 01feb2020 re-rename -join- -append-; properties elabel_aa
1.3.2 11dec2019 bug fix Stata < 16 ignored -iff-
                program properties elabel_jn
1.3.1 14nov2019 rename option -append- -join-
1.3.0 23oct2019 support option -append-
1.2.0 02aug2019 support varname:elblname
1.1.0 03jun2019 use -iff- in place of -if-
1.0.1 24may2019 bug fixes
1.0.0 02apr2019 first version
