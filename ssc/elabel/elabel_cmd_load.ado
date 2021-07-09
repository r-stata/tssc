*! version 1.4.0 18jun2020 daniel klein
program elabel_cmd_load
    version 11.2
    
    if (_caller() >= 16) local f f
    elabel parse [ anything ] [ if`f' ] [ using ] ///
    [ , Add                                       ///
        MODIFY                                    /// 
        REPLACE                                   /// 
        noFIX                             /// ignored
        LNAME(name)                               ///
        VALUE(name)                               ///
        LABEL(name)                               ///
        AS(string)                 /// not documented
    ] : `0'
    
    if ("`add'`modify'" != "") {
        if ("`replace'" != "") {
            display as err "option replace may not " ///
            "be combined with option add or option modify"
            exit 198
        }
        if ("`modify'" != "") local add // void
    }
    local option `add' `modify' `replace'
    if ( mi("`option'") ) local option none
    
    if ("`fix'" != "") display as txt "note: option nofix ignored"
    
    if ("`lname'`value'`label'" != "") {
        if ( !inlist(`"`as'"', "", "dta") ) {
            display as err "option as() invalid"
            exit 198
        }
        local as dta
    }
    else local trunc trunc
    
    if ( !inlist(`"`as'"', "", "dta", "do") ) {
        display as err "option as() invalid"
        exit 198
    }
    if (`"`as'"' != "") local suffix .`as'
    
    if ( mi(`"`using'"') ) {
        gettoken using anything : anything
        if ( mi(`"`using'"') | (`"`anything'"'!="") ) {
            display as err "using required"
            exit 100
        }
        local using using `"`using'"'
    }
    
    get_suffix `using' , suffix("`suffix'")
    
    elabel protectr
    
    preserve
    
    label drop _all
    
    if ("`suffix'" == ".dta") {
        if ("`lname'" == "") local lname lname
        if ("`value'" == "") local value value
        if ("`label'" == "") local label label
        load_uselabel `lname' `value' `label' `trunc' `using'
    }
    else if ("`suffix'" == ".do") {
        gettoken usingword using : using
        run `using'
    }
    else assert 0 // unexpected error
    
    quietly label dir
    if ( mi("`r(names)'") ) {
        display as txt "no value labels found"
        exit // done
    }
    
    tempfile tmp
    quietly elabel save `anything' `if`f'' using "`tmp'" , option(`option')
    
    restore , preserve
    
    run "`tmp'"
    
    restore , not
end

program get_suffix
    syntax using/ [ , SUFFIX(string) ]
    
    if (`"`using'"' != ".") {
        mata : st_local("pathsuffix", pathsuffix(st_local("using")))
        if ( ("`pathsuffix'" == ".do") & ("`suffix'" == ".dta") ) {
            display as err `"`using' not Stata format"'
            exit 698
        }
    }
    else {
        if ( !inlist("`suffix'", "", ".dta") ) {
            display as err "option as() invalid"
            exit 198
        }
        local pathsuffix .dta
    }
    
    if ("`suffix'" != "") exit
    
    if ( !inlist("`pathsuffix'", ".dta", ".do") ) {
        capture describe using `"`using'"'
        local pathsuffix = cond(_rc, ".do", ".dta")
    }
    
    c_local suffix : copy local pathsuffix
end

program load_uselabel
    syntax namelist using/
    
    gettoken lname namelist : namelist
    gettoken value namelist : namelist
    gettoken label namelist : namelist
    gettoken trunc namelist : namelist
    if ("`namelist'" != "") assert 0 // unexpected error
    
    if (`"`using'"' != ".") local using_filename using `"`using'"'
    
    quietly describe `using_filename' , varlist
    if ("`r(varlist)'" != "lname value label trunc") {
        if ("`trunc'" == "trunc") display as err ""       _continue
        else                      display as txt "note: " _continue
        display `"file "`using'" not created by {bf:uselabel}"'
        if ("`trunc'" == "trunc") exit 698
    }
    local sortlist `r(sortlist)'
    
    if (`"`using'"' != ".") quietly use `"`using'"' , clear
    confirm string  variable `lname' `label'
    confirm numeric variable `value'
    if ("`sortlist'" != "`lname' `value'") sort `lname' `value'
    
    mata : load_uselabel()
    drop _all
end

version 11.2

mata :

mata set matastrict on

void load_uselabel()
{
    string       colvector lname, label
    real         colvector value
    real         matrix    info
    transmorphic scalar    v
    real         scalar    i
    
    pragma unset lname
    pragma unset label
    pragma unset value
    
    st_sview(lname, ., st_local("lname"))
    st_sview(label, ., st_local("label"))
    st_view( value, ., st_local("value"))
    info = panelsetup(lname, 1)
    
    for (i=1; i<=rows(info); ++i) {
        v = elabel_vlinit(panelsubmatrix(lname, i, info)[1], 
                          panelsubmatrix(value, i, info),
                          panelsubmatrix(label, i, info)   )
        elabel_vldefine(v)
    }
}

end
exit

/* ---------------------------------------
1.4.0 18jun2020 do not save current file as temporary file
                changes to/deletion of subroutines
1.3.0 27may2020 new options -lname()-, -value()-, and -label()-
                filename may be . meaning current file; not documented
1.2.0 23oct2019 option nofix ignored; no longer documented
1.1.1 15jul2019 set matastrict on
1.1.0 03jun2019 use -iff- in place of -if-
1.0.0 02apr2019 first version
