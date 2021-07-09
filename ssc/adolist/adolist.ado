*! version 1.1.0  23aug2007  Ben Jann

program adolist
    version 9.2
    syntax [anything(equalok everything)] [ , * ]
    gettoken subcmd rest : anything
    local length = length(`"`subcmd'"')
    if `"`subcmd'"'=="ssc" {
        adolist_ssc `rest' , `options'
    }
    else if `"`subcmd'"'==substr("describe",1,max(`length',1)) {
        adolist_describe `rest' , `options'
    }
    else if `"`subcmd'"'==substr("install",1,max(`length',3)) {
        adolist_install `rest' , `options'
    }
    else if `"`subcmd'"'==substr("update",1,max(`length',3)) {
        adolist_update `rest' , `options'
    }
    else if `"`subcmd'"'==substr("uninstall",1,max(`length',5)) {
        adolist_uninstall `rest' , `options'
    }
    else if `"`subcmd'"'=="dir" | `"`subcmd'"'=="" {
        adolist_query `rest' , `options'
    }
    else if `"`subcmd'"'==substr("query",1,max(`length',1)) { // old syntax
        adolist_query `rest' , `options'
    }
    else if `"`subcmd'"'==substr("store",1,max(`length',3)) {
        adolist_store `rest' , `options'
    }
    else if `"`subcmd'"'==substr("list",1,max(`length',2)) {
        adolist_check `rest' , `options'
    }
    else if `"`subcmd'"'=="check" { // old syntax
        adolist_check `rest' , `options'
    }
    else {
        di as err `"`subcmd' invalid subcommand"'
        exit 198
    }
end

/*-----------------------------------------------------------------*/

program adolist_ssc
    syntax [anything] [ , INStall * ]
    if "`install'"!="" {
        adolist_install `anything', ssc `options'
    }
    else if "`anything'"=="" {
        if `"`options'"'!="" {
            di as error `"`options' not allowed"'
            error 198
        }
        adolist_ssc_dir
    }
    else {
        adolist_describe `anything', ssc `options'
    }
end
program adolist_ssc_dir, rclass
    mata: adolist_ssc_dir()
    // parse stata.toc and get names
    return local names `"`names'"'
end

/*-----------------------------------------------------------------*/

prog adolist_install, rclass
    syntax anything(id="name") [ , ADOdir(str) ssc all Replace force FRom(str) ]
    if `:list sizeof anything'>1 {
        di as err `"`anything' invalid"'
        exit 198
    }
    gettoken anything : anything // get rid of possible surrounding quotes
    if "`force'"!="" local replace replace

// paths and names
    expand_adodir `adodir' // sets local adodir
    if `"`from'"'=="SSC" local ssc ssc
    else if `"`from'"'!="" {
        mata: st_local("anything", pathjoin(st_local("from"),st_local("anything")))
    }
    mata: path_and_name_of_pkl_file(st_local("anything"), st_local("ssc"))
     // => fullname[nos], pathname, basename[nos], namesuffix

// get list of previous packages
    mata: st_local("syspkgs", get_list_of_installed_packages())
    local syspkgs: list uniq syspkgs
    if "`replace'"!="" {
        capt mata: get_pkgs_from_pkl(st_local("basename"))
        capt mata: st_local("blacklist", ///
            tokens(get_pklentry_from_adoltrk(st_local("basename")))[6])
        local _pkgs : list _pkgs - blacklist
        local syspkgs: list syspkgs - _pkgs
    }

// get files
    mata: target_dir_for_pkl(st_local("basename"))
     // sets adosubdir, target_pkl, target_hlp
    qui copy `"`fullname'"' `"`target_pkl'"', text `replace'
    mata: get_pkgs_from_pkl(st_local("basename")) // sets local _pkgs; error if not a package list
    local blacklist : list syspkgs & _pkgs
    capt copy `"`fullnamenos'.hlp"' `"`target_hlp'"', text `replace'
    if _rc==602 {
        di as err `"file `target_hlp' already exists"'
        exit 602
    }
    else if _rc local hashlp 0
    else local hashlp 1

// open pkl file and get title
    tempname pkglist
    file open `pkglist' using `"`target_pkl'"', read text
    file read `pkglist' line // skip 1st line
    file read `pkglist' line
    get_dline `"`line'"'
    if `hasdline' {
        local title `"`dline'"'
        file read `pkglist' line
    }
    else local title

// update package list track file
    mata: update_adolist_trk(st_local("fullname"), 1)

// install packages
    net set ado `"`adodir'"'  // sets the adodir permanently!!!
    //file read `pkglist' line
    while r(eof)==0 {
        if trim(`"`line'"')=="" | substr(`"`line'"',1,1)=="*" {
            file read `pkglist' line
            continue
        }
        gettoken pkg rest : line
        gettoken url rest : rest
        mata: st_local("url",strtrim(st_local("url")))
        mata: st_local("pkgnos", pathrmsuffix(st_local("pkg")))
        capt n net install `pkg', `all' `replace' `force' from("`url'")
        if _rc==1 exit 1
        if _rc {
            di as txt "({hi:`pkgnos'} omitted)"
            local omitted: list omitted | pkgnos
        }
        else {
            local installed: list installed | pkgnos
            if "`replace'"!="" /// sets local nremoved
                mata: adolist_pkgrmdoubles(st_local("pkg"))
        }
        file read `pkglist' line
    }
    file close `pkglist'

// returns
    ret local omitted `"`omitted'"'
    ret local installed `"`installed'"'
end

/*-----------------------------------------------------------------*/

prog adolist_update, rclass
    syntax anything(id="name") [ , ADOdir(str) all force keep dropmost dropall ]
    if `:list sizeof anything'>1 {
        di as err `"`anything' invalid"'
        exit 198
    }

// names and paths
    expand_adodir `adodir' // sets local adodir
    mata: name_of_pkl_file(pathbasename(st_local("anything"))) // sets basename[nos], namesuffix
    mata: st_local("pkls", get_pkls_from_adolist_trk())
    if `:list basename in pkls'==0 {
        di as err `"`anything' package list not found"'
        exit 601
    }
    mata: st_local("pklentry", get_pklentry_from_adoltrk(st_local("basename")))
    mata: st_local("fullname", pathjoin(tokens(st_local("pklentry"))[3], st_local("basename")))

// get contents of current version
    if "`keep'"=="" {
    // get list of packages to be uninstalled
        capt n mata: get_pkgs_from_pkl(st_local("basename")) // sets local _pkgs
        local pkgs `"`_pkgs'"' // empty if get_pkgs_from_pkl() returns error

    // get blacklist
        if "`dropall'"=="" & "`dropmost'"=="" & `"`pkgs'"'!="" {
            capt mata: st_local("blacklist",tokens(st_local("pklentry"))[6])
            local pkgs: list pkgs - blacklist
        }

    // get list of packages from other package lists
        if "`dropall'"=="" & `"`pkgs'"'!="" {
            local otherpkls: list pkls - basename
            foreach pkl of local otherpkls {
                capt mata: get_pkgs_from_pkl(st_local("pkl")) // sets local _pkgs
                if _rc==0 {
                    local pkgs: list pkgs - _pkgs
                    if `:list sizeof pkgs'==0 continue, break
                }
            }
        }
    }

// install new version
    adolist_install `"`fullname'"', adodir(`adodir') `all' replace `force'
    return add

// uninstall discontinued packages
    if "`keep'"=="" {
        capt n mata: get_pkgs_from_pkl(st_local("basename")) // sets local _pkgs
        local newpkgs `"`_pkgs'"' // empty if get_pkgs_from_pkl() returns error
        local pkgs : list pkgs - newpkgs
        foreach pkg of local pkgs {
            mata: adolist_pkguninstall(st_local("pkg")) // sets local removedpkg
            local rmpkgs `rmpgks' `removedpkg'
        }
        return local uninstalled `rmpkgs'
    }
end

/*-----------------------------------------------------------------*/

prog adolist_uninstall, rclass
    syntax anything(id="name") [ , Keep ADOdir(str) force dropmost dropall warn ]
    if `:list sizeof anything'>1 {
        di as err `"`anything' invalid"'
        exit 198
    }
    if "`force'"!="" local dropall dropall // old syntax

// names
    expand_adodir `adodir' // sets local adodir
    mata: name_of_pkl_file(pathbasename(st_local("anything"))) // sets basename[nos], namesuffix

// warn
    if "`warn'"!="" {
        di as txt `"You are about to uninstall the {cmd:`basenamenos'}"' ///
            as txt " package list"
        di as txt "Press any key to continue, or Break to abort"
        more
    }

// get adolists and check if specific list is installed
    mata: st_local("pkls", get_pkls_from_adolist_trk())
    if `:list basename in pkls'==0 {
        di as err `"`anything' package list not found"'
        exit 601
    }

    if "`keep'"=="" {
// get list of packages to be uninstalled
        capt n mata: get_pkgs_from_pkl(st_local("basename")) // sets local _pkgs
        local pkgs `"`_pkgs'"' // empty if get_pkgs_from_pkl() returns error

    // get blacklist
        if "`dropall'"=="" & "`dropmost'"=="" & `"`pkgs'"'!="" {
            capt mata: st_local("blacklist",tokens( ///
                get_pklentry_from_adoltrk(st_local("basename")))[6])
            local pkgs: list pkgs - blacklist
        }

    // get list of packages from other package lists
        if "`dropall'"=="" & `"`pkgs'"'!="" {
            local otherpkls: list pkls - basename
            foreach pkl of local otherpkls {
                capt mata: get_pkgs_from_pkl(st_local("pkl")) // sets local _pkgs
                if _rc==0 {
                    local pkgs: list pkgs - _pkgs
                    if `:list sizeof pkgs'==0 continue, break
                }
            }
        }

// uninstall packages
        foreach pkg of local pkgs {
            mata: adolist_pkguninstall(st_local("pkg")) // sets local removedpkg
            local rmpkgs `rmpgks' `removedpkg'
        }
    }

// update adolist.trk and remove pkl files
    mata: update_adolist_trk(st_local("basename"), 0)
    mata: unlink_pklfile(st_local("basename"))
    return local names `"`rmpkgs'"'
end

/*-----------------------------------------------------------------*/

prog adolist_query, rclass
    syntax [ , ADOdir(str) ]

// get adolist track file
    if `"`adodir'"'!="" local o_adodir "o_adodir"
    expand_adodir `adodir' // sets local adodir
    if `"`o_adodir'"'!="" {
        local o_adodir `" adodir(`adodir')"'
        local comma ","
    }
    mata: st_local("trkfile", pathjoin(st_local("adodir"), "adolist.trk"))
    tempname fh
    capt file open `fh' using `"`trkfile'"', read
    if _rc {
        di as txt "(no package lists installed)"
        exit
    }

// display contents
    file read `fh' line
    mata: adolist_check_adoltrk(st_local("line"))
    di as txt "{hline}"
    di as txt _n "PACKAGE LISTS installed on your system:"
    //di _n as txt _col(12)  "Package list" _col(30) "From"
    //di as txt "{hline 76}"
    while r(eof)==0 {
        if substr(`"`line'"',1,1)=="*" {
            file read `fh' line
            continue
        }
        gettoken pkl    rest : line
        gettoken hashlp rest : rest
        gettoken url    rest : rest
        gettoken title  rest : rest
        //gettoken date   rest : rest
        //gettoken bllist rest : rest
        mata: st_local("pklname", rmpklsuffix(st_local("pkl")))
        mata: st_local("pklnamenos", pathrmsuffix(st_local("pkl")))
        local names: list names | pklname
        di as txt _col(5) `"{stata "adolist describe `pklname'`comma'`o_adodir'":`pklname'}"' ///
          _col(23) `"`title'"'
        file read `fh' line
    }
    di as txt "{hline}"
    di as txt "(type -{cmd:adolist describe} {it:pklname}{cmd:`comma'`o_adodir'}- " ///
        "for more information on {it:pklname})"

// return
    file close `fh'
    ret local names `"`names'"'
end

/*-----------------------------------------------------------------*/

prog adolist_describe
    syntax anything(id="name") [ , ssc from(passthru) ADOdir(passthru) ]
    if `:list sizeof anything'>1 {
        di as err `"`anything' invalid"'
        exit 198
    }
    gettoken anything : anything // get rid of possible surrounding quotes

    mata: st_local("basename",pathbasename(st_local("anything")))
    if `"`ssc'`from'"'!="" | `"`basename'"'!=`"`anything'"' {
        adolist_describe1 `anything', `ssc' `from' `adodir'
    }
    else {
        adolist_describe0 `anything', `adodir'
    }
end

/*-----------------------------------------------------------------*/

prog adolist_describe0, rclass
    syntax anything [ , ADOdir(str) ]

// names
    if `"`adodir'"'!="" local o_adodir "o_adodir"
    expand_adodir `adodir' // sets local adodir
    mata: name_of_pkl_file(pathbasename(st_local("anything"))) // sets basename[nos], namesuffix
    mata: st_local("pkls", get_pkls_from_adolist_trk())
    if `:list basename in pkls'==0 {
        capt findfile `basename', path(.) nodescend
        if _rc==0 {
            adolist_describe1 `anything'
            return add
            exit
        }
        di as err `"`anything' package list not found"'
        exit 601
    }
    mata: st_local("pklentry", get_pklentry_from_adoltrk(st_local("basename")))
    gettoken trkpkl    rest : pklentry
    gettoken trkhashlp rest : rest
    gettoken trkurl    rest : rest
    gettoken trktitle  rest : rest
    gettoken trkdate   rest : rest
    //gettoken trkbllist rest : rest
    qui findfile `"`basename'"', path(`"`adodir'"')
    tempname fh
    file open `fh' using `"`r(fn)'"', read
    file read `fh' line
    if substr(`"`line'"',1,21)!="*! Stata package list" {
        di as err `"`anything' is not a Stata package list"'
        file close `fh'
        exit 498
    }
    if `"`o_adodir'"'!="" {
        local o_adodir `" adodir(`adodir')"'
        local comma ","
    }

// display header
    di as txt "{hline}"
    di as txt "package list " _c
    if `trkhashlp' di "{helpb `basenamenos'}" _c
    else di "{cmd:`basenamenos'}" _c
    di `" from `trkurl'"'
    di as txt "{hline}"
    file read `fh' line
    get_dline `"`line'"'
    if `hasdline' {
        di as txt _n "{hi:TITLE}"
        di as txt "    " `"`dline'"'
        file read `fh' line
        get_dline `"`line'"'
        if `hasdline' {
            di as txt _n "{hi:DESCRIPTION}"
            while `hasdline' {
                di as txt "    " `"`dline'"'
                file read `fh' line
                get_dline `"`line'"'
            }
        }
    }
    tempname rhold
    _return hold `rhold'
    di as txt _n "{hi:SOURCE FILE(S)}"
    capt findfile `"`basename'"', path(`"`adodir'"')
    di as txt "    " `"{view `""`r(fn)'""':`basename'}"'
    if `trkhashlp' {
        capt findfile `"`basenamenos'.hlp"', path(`"`adodir'"')
        di as txt "    " `"{view `""`r(fn)'""':`basenamenos'.hlp}"'
    }
    _return restore `rhold'

// packages
    di _n as txt "{hi:PACKAGES}"
    local lastispkg 0
    while r(eof)==0 {
        if substr(trim(`"`line'"'),1,2)=="*!" {
            if `lastispkg' di as txt ""
            get_dline `"`line'"'
            di as txt "    " `"--- `dline' ---"'
            local lastispkg 0
            file read `fh' line
            continue
        }
        if trim(`"`line'"')=="" | substr(trim(`"`line'"'),1,1)=="*" {
            file read `fh' line
            continue
        }
        gettoken pkg   rest : line
        gettoken url   rest : rest
        gettoken title rest : rest
        mata: st_local("pkgname", pathrmsuffix(st_local("pkg")))
        local names: list names | pkgname
        di as txt _col(5) `"{help `pkgname'}"' ///
            _col(23) `"`title'"'
        local lastispkg 1
        file read `fh' line
    }

// installation date
    if "`trkdate'"!="" {
        di _n as txt "{hi:INSTALLED ON}"
        di as txt "    " "`trkdate'"
    }

// footer
    mata: st_local("pklname", rmpklsuffix(st_local("basename")))
    di as txt "{hline}"
    di `"(type -{bf:{stata `"adolist update `pklname'`comma'`o_adodir'"'}}- to update)"'
    di `"(type -{bf:{stata `"adolist uninstall `pklname', warn`o_adodir'"':adolist uninstall `pklname'`comma'`o_adodir'}}- to uninstall)"'

// return
    file close `fh'
    ret local names `"`names'"'
end

/*-----------------------------------------------------------------*/

prog adolist_describe1, rclass
    syntax anything [ , ssc FRom(str) ]

// set fullname[nos], pathname, basename[nos], namesuffix
    if `"`from'"'=="SSC" local ssc ssc
    else if `"`from'"'!="" {
        mata: st_local("anything", pathjoin(st_local("from"),st_local("anything")))
    }
    mata: path_and_name_of_pkl_file(st_local("anything"), st_local("ssc"))

// package list file and helpfile
    tempfile tmp
    capt copy `"`fullnamenos'.hlp"' `"`tmp'"', text replace
    if _rc local hashlp 0
    else local hashlp 1
    qui copy `"`fullname'"' `"`tmp'"', text replace
    tempname fh
    file open `fh' using `"`tmp'"', read
    file read `fh' line
    if substr(`"`line'"',1,21)!="*! Stata package list" {
        di as txt "`anything' is not a Stata package list"
        file close `fh'
        exit
    }

// display header
    di as txt "{hline}"
    di as txt `"package list {cmd:`basenamenos'} from `pathname'"'
    di as txt "{hline}"
    file read `fh' line
    get_dline `"`line'"'
    if `hasdline' {
        di as txt _n "{hi:TITLE}"
        di as txt "    " `"`dline'"'
        file read `fh' line
        get_dline `"`line'"'
        if `hasdline' {
            di as txt _n "{hi:DESCRIPTION}"
            while `hasdline' {
                di as txt "    " `"`dline'"'
                file read `fh' line
                get_dline `"`line'"'
            }
        }
    }
    di as txt _n "{hi:SOURCE FILE(S)}"
    di as txt "    " `"{view `""`fullname'""':`basename'}"'
    if `hashlp' {
        di as txt "    " `"{view `""`fullnamenos'.hlp""':`basenamenos'.hlp}"'
    }

// packages
    di _n as txt "{hi:PACKAGES}"
    local lastispkg 0
    while r(eof)==0 {
        if substr(trim(`"`line'"'),1,2)=="*!" {
            if `lastispkg' di as txt ""
            get_dline `"`line'"'
            di as txt "    " `"--- `dline' ---"'
            local lastispkg 0
            file read `fh' line
            continue
        }
        if trim(`"`line'"')=="" | substr(trim(`"`line'"'),1,1)=="*" {
            file read `fh' line
            continue
        }
        gettoken pkg   rest : line
        gettoken url   rest : rest
        gettoken title rest : rest
        mata: st_local("pkgname", pathrmsuffix(st_local("pkg")))
        local names: list names | pkgname
        di as txt _col(5) `"{net `"describe `pkg', from("`url'")"':`pkgname'}"' ///
            _col(23) `"`title'"'
        local lastispkg 1
        file read `fh' line
    }
    di as txt "{hline}"
    if "`ssc'"!="" {
        di as txt `"(type -{bf:{stata `"adolist ssc `anything', install"'}}- to install)"'
    }
    else {
        mata: st_local("pklname", rmpklsuffix(st_local("fullname")))
        di as txt `"(type -{bf:{stata `"adolist install "`pklname'""'}}- to install)"'
    }

// return
    file close `fh'
    ret local names `"`names'"'
end

/*-----------------------------------------------------------------*/

prog adolist_store, rclass
    capt syntax [anything(equalok)] using/ [ , * ]
    if _rc {
        syntax anything(id="name") [ , * ]
        if `:list sizeof anything'>1 {
            di as err `"`anything' invalid"'
            exit 198
        }
        local using0 `"`anything'"'
    }
    else {
        local using0 `"`using'"'
        local pkglist `"`anything'"'
    }
    local 0 `", `options'"'
    syntax [ , NOLocal Localonly noSort ADOdir(str) Replace ///
     TItle(str) DEScription(str asis) AUThor(str) Help Help2(str asis) ]
    if "`nolocal'"!="" & "`localonly'"!="" {
        di as error "nolocal and localonly not both allowed"
        exit 198
    }
    if `"`help2'"'!="" local help help
    local date: di %d d(`c(current_date)')
    expand_adodir `adodir' // sets local adodir
    mata: adolist_store()
    ret local names `"`names'"'
end

/*-----------------------------------------------------------------*/

prog adolist_check
    syntax [anything(equalok)] [ , Help * ]
    tempfile fn
    qui adolist_store `anything' using `"`fn'"', `options'
    if `"`r(names)'"'=="" di as txt "(no packages found)"
    else type `"`fn'"'
end

/*-----------------------------------------------------------------*/

prog expand_adodir
    if inlist(`"`0'"', "", "PLUS") c_local adodir `"`c(sysdir_plus)'"'
    else if `"`0'"'=="SITE"        c_local adodir `"`c(sysdir_site)'"'
    else if `"`0''"'=="PERSONAL"   c_local adodir `"`c(sysdir_personal)'"'
    else if `"`0''"'=="OLDPLACE"   c_local adodir `"`c(sysdir_oldplace)'"'
    else if `"`0''"'=="STATA"      c_local adodir `"`c(sysdir_stata)'"'
    else if `"`0''"'=="UPDATES"    c_local adodir `"`c(sysdir_updates)'"'
    else if `"`0''"'=="BASE"       c_local adodir `"`c(sysdir_base)'"'
    else                           c_local adodir `"`0'"'
end

/*-----------------------------------------------------------------*/

prog get_dline
    args line
    local line = ltrim(`"`line'"')
    if substr(`"`line'"',1,2)=="*!" {
        local line = ltrim(substr(`"`line'"',3,.))
        local hasdline 1
    }
    else if substr(`"`line'"',1,1)=="*" {
        local line = ltrim(substr(`"`line'"',2,.))
        local hasdline 1
    }
    else {
        local line ""
        local hasdline 0
    }
    c_local hasdline `hasdline'
    c_local dline `"`line'"'
end

/*-----------------------------------------------------------------*/

version 9.2

local   SSC_PATH           `""http://fmwww.bc.edu/repec/bocode/""'
//local   SSC_PATH  `""D:\Home\jannb\Projekte\Stata\tools\adolist\test""'
local   SSC_PKLDIR         `""0""'
local   PKL_SUFFIX         `"".pkl""'
local   PKG_SUFFIX         `"".pkg""'
local   PKLFILE_HEADER     `""*! Stata package list""'
local   ADOLIST_TRKFILE    `""adolist.trk""'
local   ADOLTRK_HEADER     `""*! adolist track file - do not erase or edit this file""'

mata:

/*-----------------------------------------------------------------*/

void adolist_ssc_dir()
{
    stata("net from "+pathjoin(`SSC_PATH',"0"))
    display("{txt}(type -{cmd:adolist ssc} {it:pklname}- for more "
     + "information on {it:pklname})")
}

/*-----------------------------------------------------------------*/

void path_and_name_of_pkl_file(string scalar fn, string scalar ssc)
{
    real scalar    abs
    string scalar  path, basename, suffix, fullname, fullnamenos, basenamenos

    basename = pathbasename(fn)
    abs = pathisabs(fn)
    if (abs) fullname = fn
    else if (ssc!="") {
        if (basename==fn)
             fullname = pathjoin(pathjoin(`SSC_PATH', `SSC_PKLDIR'), basename)
        else fullname = pathjoin(`SSC_PATH', fn)
    }
    else  fullname = pathjoin(pwd(), fn)
    pathsplit(fullname, path="", basename)
    suffix = pathsuffix(fn)
    if (suffix=="") {
        suffix = `PKL_SUFFIX'
        fullnamenos = fullname
        basenamenos = basename
        fullname = fullname + suffix
        basename = basename + suffix
    }
    else {
        fullnamenos = pathrmsuffix(fullname)
        basenamenos = pathrmsuffix(basename)
    }

    st_local("fullname", fullname)
    st_local("pathname", path)
    st_local("basename", basename)
    st_local("namesuffix", suffix)
    st_local("fullnamenos", fullnamenos)
    st_local("basenamenos", basenamenos)
}

/*-----------------------------------------------------------------*/

void name_of_pkl_file(string scalar fn)
{
    string scalar basename, basenamenos, suffix

    basename = fn
    suffix = pathsuffix(basename)
    if (suffix=="") {
        suffix = `PKL_SUFFIX'
        basenamenos = basename
        basename = basename + suffix
    }
    else basenamenos = pathrmsuffix(basename)

    st_local("basename", basename)
    st_local("namesuffix", suffix)
    st_local("basenamenos", basenamenos)
}

/*-----------------------------------------------------------------*/

string scalar rmpklsuffix(string scalar name)
{
    if (pathsuffix(name)==`PKL_SUFFIX')
        return(pathrmsuffix(name))
    return(name)
}

/*-----------------------------------------------------------------*/

void target_dir_for_pkl(string scalar basename)
{
    string scalar  subdir, adodir

    adodir = st_local("adodir")
    subdir = pathjoin(adodir, substr(basename, 1, 1))
//    if (direxists(adodir)==0) _error(170, adodir + " does not exist")
    if (direxists(adodir)==0) mkadodir(adodir)
    if (direxists(subdir)==0) mkdir(subdir)

    st_local("adosubdir", subdir)
    st_local("target_pkl", pathjoin(subdir, basename))
    st_local("target_hlp", pathjoin(subdir, pathrmsuffix(basename) + ".hlp"))
}
void mkadodir(string scalar adodir)
{
    real scalar      i
    string scalar    dir, sub
    string rowvector dirs

//    if (direxists(adodir)==1) return

    pathsplit(adodir, dir, sub)
    dirs = dirs, sub
    while (dir!="" & direxists(dir)==0) {
        pathsplit(dir, dir, sub)
        dirs = dirs, sub
    }
    if (dir=="" & pathisabs(adodir)) _error(693, "could not create ado directory")
    for (i=cols(dirs); i>=1; i--) {
        dir = pathjoin(dir, dirs[i])
        mkdir(dir)
    }
}

/*-----------------------------------------------------------------*/

void get_pkgs_from_pkl(string scalar pkl)
{
    string scalar    fn, res, pkg
    string colvector PKL
    real scalar      i

    st_local("_pkgs","")

    fn = pkl + (pathsuffix(pkl)=="" ? `PKL_SUFFIX' : "")
    fn = pathjoin(pathjoin(st_local("adodir"), substr(fn, 1, 1)), fn)

    PKL = cat(fn)

    if (rows(PKL)>0) pkg = PKL[1]
    if (substr(pkg,1,strlen(`PKLFILE_HEADER'))!=`PKLFILE_HEADER')
        _error(3498,pkl + " is not a Stata package list")

    for (i=1; i<=rows(PKL); i++) {
        pkg = strtrim(PKL[i])
        if (pkg=="" | substr(pkg,1,1)=="*") {
            PKL[i] = ""; continue
        }
        pkg = tokens(pkg)[1]
        pkg = pkg + (pathsuffix(pkg)=="" ? `PKG_SUFFIX' : "")
        PKL[i] = pkg
    }
    PKL = uniqrows(select(PKL, PKL:!=""))
    for (i=1; i<=rows(PKL); i++) {
        res = res + " " + PKL[i]
    }
    st_local("_pkgs",strtrim(res))
}

/*-----------------------------------------------------------------*/

void adolist_pkguninstall(string scalar pkg)
{
    real scalar      j
    real colvector   pos
    string scalar    remove, adodir
    string matrix    pkgs

    adodir = st_local("adodir")
    remove = pkg
    if (pathsuffix(remove)=="") remove = remove + `PKG_SUFFIX'
    pkgs = get_pkgs_from_statatrk(adodir)
    if (rows(pkgs)>0) {
        pos = select(1::rows(pkgs), pkgs[,2]:==remove)
        for (j=rows(pos); j>=1; j--) {
            stata("ado uninstall ["+strofreal(pos[j])+"], from("+`"""'+adodir+`"""'+")")
        }
        if (rows(pos)==0) remove = ""
    }
    st_local("removedpkg",remove)
}

/*-----------------------------------------------------------------*/

void adolist_pkgrmdoubles(string scalar pkg)
{
    real scalar      j
    real colvector   pos
    string scalar    remove, adodir
    string matrix    pkgs

    adodir = st_local("adodir")
    remove = pkg
    if (pathsuffix(remove)=="") remove = remove + `PKG_SUFFIX'
    pkgs = get_pkgs_from_statatrk(adodir)
    if (rows(pkgs)>0) {
        pos = select(1::rows(pkgs), pkgs[,2]:==remove)
        if (rows(pos)<2) pos = J(0,1,.)
        else pos = pos[|1 \ rows(pos)-1|]
        for (j=rows(pos); j>=1; j--) {
            stata("quietly ado uninstall ["+strofreal(pos[j])+
                "], from("+`"""'+adodir+`"""'+")")
        }
    }
    st_local("nremoved", strofreal(rows(pos)))
}

/*-----------------------------------------------------------------*/

string scalar get_pkls_from_adolist_trk()
{
    real scalar      i
    string scalar    pkl, trk, res, adodir
    string colvector pkls

    adodir = st_local("adodir")
    res = ""
    trk = pathjoin(adodir, "adolist.trk")
    if (fileexists(trk)==0) return(res)
    pkls = cat(trk)
    if (rows(pkls)<1)  return(res)
    adolist_check_adoltrk(pkls[1])
    if (rows(pkls)==1) return(res)
    pkls = pkls[|2 \ rows(pkls)|]
    res = tokens(pkls[1])[1]
    for (i=2; i<=rows(pkls); i++) {
        res = res + " " + tokens(pkls[i])[1]
    }
    return(res)
}

/*-----------------------------------------------------------------*/

string scalar get_pklentry_from_adoltrk(string scalar pkl)
{
    real scalar      i, pos
    string scalar    pkli, trk
    string colvector pkls

    trk = pathjoin(st_local("adodir"), "adolist.trk")
    if (fileexists(trk)==0) return("")
    pkls = cat(trk)
    if (rows(pkls)<1)       return("")
    adolist_check_adoltrk(pkls[1])
    if (rows(pkls)==1)      return("")
    pkls = pkls[|2 \ rows(pkls)|]
    for (i=1; i<=rows(pkls); i++) {
        if (pkl==tokens(pkls[i])[1]) return(pkls[i])
    }
    return("")
}

/*-----------------------------------------------------------------*/

void update_adolist_trk( // sets local hashlp if add==0
 string scalar pklname,
 real scalar add)
{
    real scalar      match, fh, i
    string scalar    pkl, url, trk, hashlp, title, date, adodir
    string colvector pkls

    adodir = st_local("adodir")
    if (add) {
        hashlp = st_local("hashlp")
        title  = st_local("title")
        date   = st_global("c(current_date)")
        bllist = st_local("blacklist")
    }

// read existing track file
    trk = pathjoin(adodir, "adolist.trk")
    if (fileexists(trk)) {
        pkls = cat(trk)
        if (rows(pkls)>0) {
            adolist_check_adoltrk(pkls[1])
            if (rows(pkls)>1) {
                pkls = pkls[|2 \ rows(pkls)|]
            }
            else pkls = J(0,1,"")
        }
        unlink(trk)
    }
    else if (add==0) _error(601,"adolist track file not found")

// add/remove
    if (add) { // add current pkl
        pathsplit(pklname, url="", pkl="")
        match = 0
        for (i=1; i<=rows(pkls); i++) {
            if (tokens(pkls[i])[1]==pkl) {
                match = 1
                pkls[i] = (pkl + " " + hashlp + " " + `"""'+url+`"""' + " " +
                    "`"+`"""'+title+`"""'+"'" + " " +`"""'+date+`"""' +
                    " " +`"""'+bllist+`"""')
                break
            }
        }
        if (match==0) {
            pkls = pkls \ (pkl + " " + hashlp + " " + `"""'+url+`"""' + " " +
                    "`"+`"""'+title+`"""'+"'" + " " +`"""'+date+`"""' +
                    " " +`"""'+bllist+`"""')
            _sort(pkls,1)
        }
    }
    else { // remove current pkl
        for (i=1; i<=rows(pkls); i++) {
            if (tokens(pkls[i])[1]==pklname) {
                st_local("hashlp", tokens(pkls[i])[2])
                if (rows(pkls)>1) pkls = select(pkls, (1::rows(pkls)):!=i)
                else pkls = J(0,1,"")
                break
            }
        }
    }

// write to file
    if (rows(pkls)>0) {
        fh = fopen(trk, "w")
        fput(fh, `ADOLTRK_HEADER')
        for (i=1; i<=rows(pkls); i++) {
            fput(fh, pkls[i])
        }
        fclose(fh)
    }
}

/*-----------------------------------------------------------------*/

void unlink_pklfile(string scalar pkl)
{
    string scalar path
    real scalar   rc

    path = pathjoin(st_local("adodir"), substr(pkl, 1, 1))
    rc = _unlink(pathjoin(path,pkl))
    if (st_local("hashlp")=="1") {
        rc = _unlink(pathjoin(path,pathrmsuffix(pkl)+".hlp"))
    }
}

/*-----------------------------------------------------------------*/

void adolist_check_adoltrk(string scalar s)
{
    if (substr(s,1,strlen(`ADOLTRK_HEADER'))!=`ADOLTRK_HEADER')
        _error(3498,"invalid adolist track file")
}

/*-----------------------------------------------------------------*/

void adolist_store()
{
    real scalar    i, j, jj, urlonly, npkg
    string scalar  tmpstr
    real colvector select
    string vector  list
    string matrix  pkgs

// get list of installed packages
    pkgs = get_pkgs_from_statatrk(st_local("adodir"))
// sort and remove duplicates
    pkgs = sortrmdups_pkgs(pkgs)
// add cols for author and heading
    pkgs = pkgs, J(rows(pkgs),2,"") // path pkg date number title author heading

// get specified packages and update pkgs
    list = tokens(st_local("pkglist"))
    list = mytokens(list,5)         // pkg path title author heading
    npkg = rows(pkgs)
    for (i=1; i<=rows(list); i++) {
        tmpstr = list[i,1]
        if (list[i,2]=="SSC") list[i,2] = pathjoin(`SSC_PATH', substr(tmpstr,1,1))
        if (tmpstr=="" | strpos(tmpstr,"*") | strpos(tmpstr,"?") | list[i,2]=="") continue
        for (j=1; j<=rows(pkgs); j++) {
            if (pkgs[j,2]==tmpstr | pathrmsuffix(pkgs[j,2])==tmpstr) {
                tmpstr = ""
                break
            }
        }
        if (tmpstr!="") {
            if (pathsuffix(tmpstr)=="") tmpstr = tmpstr + `PKG_SUFFIX'
            pkgs = pkgs \ (list[i,2],tmpstr,"","", list[|i,3 \ i,5|])
        }
    }

// select packages to be stored and update info (default: all)
    jj = 0
    if (rows(list)>0 & npkg>0) {
        select = J(rows(pkgs),1,0)
        for (i=1; i<=rows(list); i++) {
            tmpstr = list[i,1]
            for (j=1; j<=rows(pkgs); j++) {
                if (select[j]) continue
                if (strmatch(pkgs[j,2], tmpstr) |
                 strmatch(pathrmsuffix(pkgs[j,2]), tmpstr)) {
                    select[j] = ++jj
                    if (j<=npkg) {
                        if (list[i,2]!="") pkgs[j,1] = list[i,2] // update path
                        if (list[i,3]!="") pkgs[j,5] = list[i,3] // update title
                        if (list[i,4]!="") pkgs[j,6] = list[i,4] // update author
                        if (list[i,5]!="") pkgs[j,7] = list[i,5] // update heading
                    }
                }
            }
        }
        pkgs = select(pkgs, select)
        if (st_local("sort")!="") {
            pkgs = pkgs[invorder(select(select,select)),]
        }
    }
    if (st_local("sort")=="") _sort(pkgs,2)

// localonly / nolocal
    if (st_local("localonly")!="" | st_local("nolocal")!="") {
        urlonly = (st_local("nolocal")!="")
        select = J(rows(pkgs),1,0)
        for (i=1; i<=rows(pkgs); i++) {
            select[i] = select[i] + (pathisurl(pkgs[i,1])==urlonly)
        }
        pkgs = select(pkgs, select)
    }

// get rid of "'PKGNAME': " in SSC packages
    for (j=1; j<=rows(pkgs); j++) {
        tmpstr = "'" + strupper(pathrmsuffix(pkgs[j,2])) + "': "
        if (strpos(pkgs[j,5],tmpstr)==1) { // ==1 on purpose
            pkgs[j,5] = substr(pkgs[j,5], strlen(tmpstr)+1)
        }
    }

// package list file
    write_pkglist_to_file(pkgs)

// return
    tmpstr = ""
    for (i=1; i<=rows(pkgs); i++) {
        tmpstr = tmpstr+" "+pathrmsuffix(pkgs[i,2])
    }
    tmpstr = substr(tmpstr,2)
    st_local("names",tmpstr)
}

/*-----------------------------------------------------------------*/

void write_pkglist_to_file(string matrix pkgs)
{
    string scalar    fn, mode, date, title, author, fname, m
    string vector    descr
    real scalar      i, fh, length, length2

    fn      = st_local("using0")
    mode    = st_local("replace")
    date    = st_local("date")
    title   = st_local("title")
    descr   = st_local("description")
    help    = st_local("help")
    author  = st_local("author")

    fname = fn
    if (pathsuffix(fn)=="") fname = fname + ".pkl"
    m = "w"
    if (mode=="replace") unlink(fname)
    fh = fopen(fname, m)
    fput(fh, `PKLFILE_HEADER' + "  " + date)
    if (title!="") fput(fh, "*! "+title)
    if (descr=="") descr = J(1,0,"")
    else if (strpos(descr,`"""')) descr = tokens(descr)
    for (i=1; i<=length(descr); i++) {
        fput(fh, "*! "+descr[i])
    }
    if (author!="") {
        fput(fh, "*! ")
        fput(fh, "*! Assembled by: " + author)
    }
    fput(fh, "") // empty line
    length = colmax(strlen(pkgs[,2])) + 1
    length2 = colmax(strlen(pkgs[,1])) + 1
    for (i=1; i<=rows(pkgs); i++) {
        if (pkgs[i,7]!="") {
            if (i>1) fput(fh, "")
            fput(fh, "*! " + pkgs[i,7])
        }
        fput(fh, pkgs[i,2] + (length-strlen(pkgs[i,2]))*" " +
            `"""'+pkgs[i,1]+`"""' + (length2-strlen(pkgs[i,1]))*" " +
            "`"+`"""'+pkgs[i,5]+`"""'+"'" )
    }
    fclose(fh)
    displayas("txt")
    display("({view " + "`"+`"""'+`"""'+fname+`"""'+`"""'+"'" + ":" + fname +
        "} created; containing {res}"+strofreal(rows(pkgs))+"{txt} packages)")
    if (st_local("help")!="")
        write_hlp_for_pkglist(fname, pkgs, mode, date, title, descr, author)
}

/*-----------------------------------------------------------------*/

string matrix mytokens(string rowvector S, real scalar c)
{ // get frist c tokens
    real scalar      i, e
    string rowvector tmp
    string matrix    res

    res = J(length(S),c,"")
    for (i=1;i<=length(S);i++) {
        tmp = tokens(S[i])
        e = min((c,length(tmp)))
        if (e==0) continue
        res[|i,1 \ i,e|] = tmp[|1 \ e|]
    }
    return(res)
}

/*-----------------------------------------------------------------*/

void write_hlp_for_pkglist(
 string scalar fn,
 string matrix pkgs,
 string scalar mode,
 string scalar date,
 string scalar title,
 string vector descr,
 string scalar author)
{
    string scalar  name, fname, pname, m, pkgnm, pkgti, pkgau, suffix
    string vector  remarks
    real scalar    i, fh, pos, length

    remarks = st_local("help2")
    if (remarks=="")                remarks = J(1,0,"")
    else if (strpos(remarks,`"""')) remarks = tokens(remarks)

    pname   = pathbasename(fn)
    suffix  = pathsuffix(pname)
    name    = pathrmsuffix(pname)
    fname   = pathrmsuffix(fn) + ".hlp"
    m = "w"
    if (mode=="replace") unlink(fname)
    fh = fopen(fname, m)

// prolog
    fput(fh, "{smcl}")
    fput(fh, "{* " + date + "}{...}")
    fput(fh, "{hi:help " + name + "}{right:also see: {helpb adolist}}")
    fput(fh, "{hline}"); fput(fh, "")

// title
    fput(fh, "{title:Title}"); fput(fh, "")
    fput(fh, "{p 4 " + strofreal(8+strlen(name)) + " 2}{hi:" + name +
             "} {hline 2} " + (title!="" ? title : "Package list"))
    fput(fh, ""); fput(fh, "")

// description
    if (length(descr)>0) {
        fput(fh, "{title:Description}"); fput(fh, "")
        fput(fh, "{pstd}")
        for (i=1; i<=length(descr); i++) {
            if (i>1) {
                if (descr[i]!="" & descr[i-1]=="") fput(fh, "{pstd}")
                }
            fput(fh, descr[i])
        }
        fput(fh, ""); fput(fh, "")
    }

// packages
    fput(fh, "{title:Packages}"); fput(fh, "")
    length = colmax(strlen(pkgs[,2])) - 3 + 1
    for (i=1; i<=rows(pkgs); i++) {
        if (pkgs[i,7]!="") {
            if (i!=1) fput(fh, "")
            fput(fh, "{dlgtab:" + pkgs[i,7] + "}"); fput(fh, "")
        }
        pkgnm = pathrmsuffix(pkgs[i,2])
        pkgti = pkgs[i,5]
        if (pkgs[i,6]!="") {
            if (pkgti!="") pkgti = pkgti + " "
            pkgti = pkgti + "{it:by} " + pkgs[i,6]
        }
        //fput(fh, "{p 4 " + strofreal(4+length+3) + `" 2}{bf:{net "describe "' +
        //    pkgs[i,2] + ", from(" + pkgs[i,1] + `")":"' + pkgnm + "}}{space " +
        //    strofreal(length-strlen(pkgnm)) + "}")
        fput(fh, "{p 4 " + strofreal(4+length+3) + " 2}{helpb " +
            pkgnm + "}{space " + strofreal(length-strlen(pkgnm)) + "}")
        if (pkgti!="") fput(fh, pkgti)
        fput(fh, "{p_end}")
    }
    fput(fh, "")

// remarks
    for (i=1; i<=length(remarks); i++) {
        fput(fh, remarks[i])
    }
    fput(fh, "")

// source
    fput(fh, "{title:Package list source file}"); fput(fh, "")
    fput(fh, "{pstd} " + "{view " + pname + ", adopath asis:" + pname + "}")
    fput(fh, ""); fput(fh, "")

// author
    if (author!="") {
        fput(fh, "{title:Assembled by}"); fput(fh, "")
        fput(fh, "{pstd} " + author)
        fput(fh, ""); fput(fh, "")
    }

// also see
    fput(fh, "{title:Also see}"); fput(fh, "")
    fput(fh, "{psee} Online:  {helpb ado}, {helpb adoupdate}, {helpb ssc},")
    fput(fh, "{help sj}, {help stb}; {helpb adolist} (if installed)")
    fput(fh, "")

    fclose(fh)
    displayas("txt")
    display("({view " + "`"+`"""'+`"""'+fname+`"""'+`"""'+"'" + ":" + fname +
        "} created)")
}

/*-----------------------------------------------------------------*/

string matrix sortrmdups_pkgs(string matrix pkgs)
{
    real scalar    i
    real colvector p
    string matrix  res

    if (rows(pkgs)<1) return(pkgs)

// sort and remove doubles (use last in case of doubles)
    p = order(
      ((colmax(strlen(pkgs[,4])):-strlen(pkgs[,4])):*"0"+pkgs[,4], pkgs[,2]),
     (2,1))
    res = pkgs[p,]
    p = J(rows(res),1,1)
    for (i=rows(res)-1; i>=1; i--) {
        if (res[i,2]==res[i+1,2]) p[i] = 0
    }
    res = select(res,p)

    return(res)
}

/*-----------------------------------------------------------------*/

string matrix get_pkgs_from_statatrk(string scalar dir)
{
    real scalar     fh, i, j, N, D, U
    string scalar   line, stub
    string matrix   res, EOF

// open stata.trk
    if ((fh = _fopen(pathjoin(pathsubsysdir(dir=="" ? "PLUS" : dir),
     "stata.trk"), "r")) < 0) {
        return(J(0, 5, ""))
    }

// determine number of packages
    EOF = J(0, 0, "")
    i = 0
    while ((line=fget(fh))!=EOF) {
        if (substr(line,1,2)=="S ") {
            i++
        }
    }

// get list of packages
    res = J(i, 5, "")
    i = 0
    fseek(fh, i, -1)
    while ((line=fget(fh))!=EOF) {
        if (substr(line,1,2)=="S ") {
            ++i
            res[i,1] = substr(line,3,.) // url
            N = D = U = 0
            for (j=1; j<=3; j++) {
                line=fget(fh)
                stub = substr(line,1,2)
                if (stub=="N ") {
                    N = 1; res[i,2] = substr(line,3,.) // pkg
                }
                else if (stub=="D ") {
                    D = 1; res[i,3] = substr(line,3,.) // date
                }
                else if (stub=="U ") {
                    U = 1; res[i,4] = substr(line,3,.) // number
                }
            }
            if (!(N & D & U)) _error(3498,"invalid track file")
            line=fget(fh)
            if (substr(line,1,2)=="d ") res[i,5] = substr(line,3,.) // title
        }
    }
    fclose(fh)

    return(res)
}

/*-----------------------------------------------------------------*/

string scalar get_list_of_installed_packages()
{
    real scalar         i
    string scalar       res
    string colvector    pkgs

    pkgs = get_pkgs_from_statatrk(st_local("adodir"))[,2]
    if (rows(pkgs)>0) {
        res = pkgs[1]
        for (i=2;i<=rows(pkgs);i++) {
            res = res + " " + pkgs[i]
        }
    }
    return(res)
}

end
