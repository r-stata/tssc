*! version 1.0.0 17oct2019 daniel klein
program rqrs
    version 11.2
    
    syntax namelist(max = 2) [ , ALL REPLACE FRom(string asis) INStall SKIP ]
    
    if ( mi(`"`from'"') ) local ssc_net ssc
    else {
        gettoken ssc_net void : from , quotes
        if ( !inlist(`"`ssc_net'"', "ssc", "net") ) {
            if ( regexm(`"`ssc_net'"', "^sj[0-9]+\-[0-9]+$") ) {
                local from "http://www.stata-journal.com/software/`ssc_net'"
            }
            else if ( regexm(`"`ssc_net'"', "^stb[0-9]+$") ) {
                local from "http://www.stata.com/stb/`ssc_net'"
            }
            local ssc_net net
            local from    from(`from')
        }
        else if ( mi(strtrim(`"`void'"')) ) local from // void 
        else {
            display as err "option from() incorrectly specified"
            exit 198
        }
    }
    
    gettoken command namelist : namelist
    gettoken pkgname namelist : namelist
    if ( mi("`pkgname'") ) local pkgname : copy local command
    
    capture noisily which `command'
    if ( !_rc ) exit
    
    if ( mi("`install'") ) {
        capture window stopbox rusure "Do you want to install `pkgname'?"
        if ( _rc ) exit 111*( mi("`skip'") )
    }
    
    `ssc_net' install `pkgname' , `all' `replace' `from'
end
exit
