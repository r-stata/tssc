*! version 2.4.0  13apr2018  Ben Jann

program texdoc
    version 10.1
    gettoken subcmd 0 : 0, parse(",: ")
    local length = length(`"`subcmd'"')
    if `"`subcmd'"'==substr("write", 1, max(`length', 1)) {
        if `"${TeXdoc_docname}"'=="" {
            di as txt "(texdoc not initialized; nothing to do)"
            exit
        }
        texdoc_write write`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("_write", 1, max(`length', 2)) {
        if `"${TeXdoc_docname}"'=="" {
            di as txt "(texdoc not initialized; nothing to do)"
            exit
        }
        _texdoc_write write`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("append", 1, max(`length', 1)) {
        texdoc_append`macval(0)'
        exit
    }
    if `"`subcmd'"'=="append_snippet" {
        texdoc_append_snippet`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("local", 1, max(`length', 3)) {
        if `"${TeXdoc_docname}"'=="" { // texdoc not initialized
            c_local`macval(0)'
            exit
        }
        if `"${TeXdoc_stfilename0}"'=="" {
            di as txt "(no stlog available; skipping backup)"
            c_local`macval(0)'
            exit
        }
        gettoken mname 0 : 0, parse(" =:")
        if `"${TeXdoc_stnodo}"'=="" {
            capt n local meval`macval(0)'
            if _rc local meval "ERROR"
            texdoc_local_put `mname' `"`macval(meval)'"'
        }
        else {
            capt n texdoc_local_get `mname'
            if _rc di as txt "(backup of `mname' not found)"
        }
        c_local `mname' `"`macval(meval)'"'
        exit
    }
    if `"`subcmd'"'==substr("substitute", 1, max(`length', 3)) {
        texdoc_substitute`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("init", 1, max(`length', 1)) {
        capt n texdoc_init`macval(0)'
        local rc = _rc
        if `rc' _texdoc_cleanup
        exit `rc'
    }
    if `"`subcmd'"'==substr("close", 1, max(`length', 1)) {
        if `"${TeXdoc_ststatus}"'!="" {
            di as err "texdoc close not allowed within stlog section"
            di as err "type {stata texdoc stlog close} to close the stlog section"
            exit 499
        }
        texdoc_close`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("stlog", 1, max(`length', 1)) {
        local caller : di _caller()
        version `caller': texdoc_stlog`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("graph", 1, max(`length', 2)) {
        texdoc_graph`macval(0)'
        exit
    }
    if `"`subcmd'"'=="strip" {
        texdoc_strip`macval(0)'
        exit
    }
    if `"`subcmd'"'=="do" {
        if `"${TeXdoc_ststatus}"'!="" {
            di as err "texdoc do not allowed within stlog section"
            di as err "type {stata texdoc stlog close} to close the stlog section"
            exit 499
        }
        local caller : di _caller()
        local do_globals snippets replace append logdir logdir2 noprefix ///
            prefix prefix2 stpath stpath2 logall nodo nolog cmdlog beamer ///
            verbatim hardcode nokeep custom cmdstrip lbstrip gtstrip ///
            matastrip nooutput noltrim gropts grdir alert tag certify linesize
        local init_globals nodo nolog cmdlog beamer verbatim hardcode nokeep custom ///
            cmdstrip lbstrip gtstrip matastrip nooutput noltrim gropts grdir ///
            alert tag certify linesize stpath prefix prefix0 logdir path0 path ///
            logall basename docname0 docname docname_FH substitute
        local st_globals nodo nolog cmdlog beamer verbatim hardcode nokeep custom cmdstrip ///
            lbstrip gtstrip matastrip nooutput noltrim indent grcounter filename ///
            filename0 texname texname0 name0 name alert tag certify linesize ///
            linesize0 status loc
        local nested = `"${TeXdoc_dofile}"'!=""
        if `nested' { // backup current settings
            local do_dofile `"${TeXdoc_dofile}"'
            foreach g of local do_globals {
                mata: st_local("do_`g'", st_global("TeXdoc_do_`g'"))
            }
            local init_stcounter `"${TeXdoc_stcounter}"'
            foreach g of local init_globals {
                mata: st_local("init_`g'", st_global("TeXdoc_`g'"))
            }
            foreach g of local st_globals {
                mata: st_local("st_`g'", st_global("TeXdoc_st`g'"))
            }
        }
        _texdoc_do_parse`macval(0)' // returns cd
        if "`cd'"!="" {
            local pwd `"`c(pwd)'"'
        }
        nobreak {
            capt n break {
                version `caller': texdoc_do`macval(0)'
            }
            if _rc {
                local rc = _rc
                _texdoc_cleanup
                _texdoc_cleanup_do
                if "`cd'"!="" {
                    qui cd `pwd'
                    di as txt `"(cd `pwd')"'
                }
                exit `rc'
            }
            if `nested' {
                mata: rmexternal("TeXdoc_do_snippets")
                if `"${TeXdoc_docname}"'=="" {
                    // docname closed (or not yet initialized): skip texdoc 
                    // close and restore previous settings
                    global TeXdoc_stcounter `"`init_stcounter'"'
                    foreach g of local st_globals {
                        global TeXdoc_st`g' `"`macval(st_`g')'"'
                    }
                }
                else if `"`init_docname'"'==`"${TeXdoc_docname}"' {
                    // still same docname: skip texdoc close, keep stcounter 
                    // and settings from last stlog, but restore stloc
                    global TeXdoc_stloc `"`macval(st_loc)'"'
                }
                else if `"${TeXdoc_docname}"'!="" {
                    // docname has been (re)initialized: apply texdoc close 
                    // and restore previous settings
                    texdoc_close
                    global TeXdoc_stcounter `"`init_stcounter'"'
                    foreach g of local st_globals {
                        global TeXdoc_st`g' `"`macval(st_`g')'"'
                    }
                }
                // restore init globals
                foreach g of local init_globals {
                    global TeXdoc_`g' `"`macval(init_`g')'"'
                }
                // restore texdoc do globals
                global TeXdoc_dofile `"`do_dofile'"'
                foreach g of local do_globals {
                    global TeXdoc_do_`g' `"`macval(do_`g')'"'
                }
            }
            else {
                if `"${TeXdoc_docname}"'!="" {
                    texdoc_close
                }
                _texdoc_cleanup_do
            }
            if "`cd'"!="" {
                qui cd `pwd'
                di as txt `"(cd `pwd')"'
            }
        }
        exit
    }
    di as err `"`subcmd' invalid subcommand"'
    exit 198
end

program _texdoc_do_parse
    _parse comma fn 0 : 0
    syntax [, cd * ]
    c_local cd `cd'
end

program _texdoc_cleanup
    // clear texdoc stlog globals
    _texdoc_cleanup_stlog
    // close file handle
    capture mata: texdoc_closeout_fh(${TeXdoc_docname_FH})
    // clear texdoc init globals
    foreach g in nodo nolog cmdlog beamer verbatim hardcode nokeep custom cmdstrip ///
        lbstrip gtstrip matastrip nooutput noltrim gropts grdir alert tag ///
        certify linesize stcounter stpath prefix prefix0 logdir path0 path ///
        logall basename docname0 docname docname_FH substitute {
        global TeXdoc_`g' ""
    }
end

program _texdoc_cleanup_stlog
    // clear texdoc stlog globals
    foreach g in nodo nolog cmdlog beamer verbatim hardcode nokeep custom cmdstrip ///
        lbstrip gtstrip matastrip nooutput noltrim indent grcounter filename ///
        filename0 texname texname0 name0 name alert tag certify linesize ///
        linesize0 status loc {
        global TeXdoc_st`g' ""
    }
end

program _texdoc_cleanup_do
    // close log if still on
    capt log close TeXdoc_stlog
    // clear texdoc do globals
    foreach g in snippets replace append logdir logdir2 noprefix prefix ///
        prefix2 stpath stpath2 logall nodo nolog cmdlog beamer verbatim hardcode ///
        nokeep custom cmdstrip lbstrip gtstrip matastrip nooutput noltrim ///
        gropts grdir alert tag certify linesize {
        global TeXdoc_do_`g' ""
    }
    global TeXdoc_dofile ""
    mata: rmexternal("TeXdoc_do_snippets")
end

program _texdoc_makelink
    args fn
    if c(os)=="Unix" {
        c_local link `"stata `"!xdg-open "`fn'" >& /dev/null &"'"'
    }
    // else if c(os)=="MacOSX" {
    //     c_local link `"stata `"!open "`fn'""'"'
    // }
    // else if c(os)=="Windows" {
    //     c_local link `"stata `"!start "`fn'""'"'
    // }
    else {
        c_local link `"browse `"`fn'"'"'
    }
end

program texdoc_write // usage: texdoc_write write ...
    mata: fput(${TeXdoc_docname_FH}, substr(st_local("0"), 7, .))
end

program _texdoc_write // usage: _texdoc__write write ...
    mata: fwrite(${TeXdoc_docname_FH}, substr(st_local("0"), 7, .))
end

program texdoc_append
    if `"${TeXdoc_docname}"'=="" {
        di as txt "(texdoc not initialized; nothing to do)"
        exit
    }
    local 0 `"using `macval(0)'"'
    syntax using/ [, SUBstitute(str asis) ]
    nobreak {
        capt n break {
            mata: texdoc_instance_fh("fh")
            mata: texdoc_append(${TeXdoc_docname_FH}, `fh'=.)
        }
        local rc = _rc
        capture mata: texdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
    di as txt `"(`using' appended)"'
end

program texdoc_append_snippet
    if `"${TeXdoc_docname}"'=="" | `"${TeXdoc_dofile}"'=="" {
        exit
    }
    nobreak {
        capt n break {
            mata: texdoc_instance_fh("fh")
            mata: texdoc_append_snippet(${TeXdoc_docname_FH}, `fh'=.)
        }
        local rc = _rc
        capture mata: texdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
end

program texdoc_local_put
    args mname meval
    nobreak {
        capt n break {
            mata: texdoc_instance_fh("fh")
            mata: texdoc_local_put(`fh'=.)
        }
        local rc = _rc
        capture mata: texdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
end

program texdoc_local_get
    args mname
    nobreak {
        capt n break {
            mata: texdoc_instance_fh("fh")
            mata: texdoc_local_get(`fh'=.)
        }
        local rc = _rc
        capture mata: texdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
    c_local meval `"`macval(meval)'"'
end

program texdoc_substitute
    syntax [anything(equalok everything)] [, Add ]
    if `"${TeXdoc_docname}"'=="" exit
    mata: texdoc_substitute()
end

program texdoc_init
    syntax [anything] [, force *]
    if `"${TeXdoc_dofile}"'=="" & "`force'"=="" {
        di as txt "(texdoc do not running; nothing to do)"
        exit
    }
    if `"${TeXdoc_ststatus}"'!="" {
        di as err "texdoc init not allowed within stlog section"
        di as err "type {stata texdoc stlog close} to close the stlog section"
        exit 499
    }
    syntax [anything(id="document name")] [, force ///
        Replace Append NOLOGDIR logdir LOGDIR2(str) NOLOGALL LOGALL ///
        NOPrefix Prefix Prefix2(str) NOSTPATH stpath STPATH2(str) ///
        NODO DO NOLOG LOG NOCMDLog CMDLog NOBEAMER BEAMER NOVERBatim VERBatim ///
        NOHardcode Hardcode NOKeep Keep NOCustom Custom NOCMDStrip CMDStrip ///
        NOLBStrip LBStrip NOGTStrip GTStrip NOMatastrip Matastrip ///
        NOOutput Output NOLTRIM LTRIM GRopts(str asis) grdir(str) ///
        alert(str asis) tag(str asis) NOCERTify CERTify ///
        LInesize(numlist int max=1 >=40 <=255) ]
    if "`replace'"!="" & "`append'"!="" {
        di as err "replace and append not both allowed"
        exit 198
    }
    if "`nolog'"!="" & "`cmdlog'"!="" {
        di as err "nolog and cmdlog not both allowed"
        exit 198
    }
    if "`nolog'"!=""  local nocmdlog nocmdlog
    if "`cmdlog'"!="" local log log
    if "`custom'"!="" & "`hardcode'"!="" {
        di as err "custom and hardcode not both allowed"
        exit 198
    }
    if "`custom'"!=""   local nohardcode nohardcode
    if "`hardcode'"!="" local nocustom nocustom
    foreach opt in logdir prefix stpath {
        if "``opt''``opt'2'"!="" & "`no`opt''"!="" {
            di as err "`opt'() and no`opt' not both allowed"
            exit 198
        }
    }
    foreach opt in logall do log cmdlog beamer verbatim hardcode keep custom ///
        cmdstrip lbstrip gtstrip matastrip output ltrim certify {
        if "``opt''"!="" & "`no`opt''"!="" {
            di as err "`opt' and no`opt' not both allowed"
            exit 198
        }
    }
    if `"`anything'"'!="" {
        gettoken anything rest : anything // get rid of quotes around filename
        if `"`rest'"'!="" error 198
        if `"`anything'"'=="" error 198
        // read global defaults if -texdoc do- is running
        local prefix0
        if `"${TeXdoc_dofile}"'!=""{
            if `"`replace'`append'"'=="" {
                local replace `"${TeXdoc_do_replace}"'
                local append `"${TeXdoc_do_append}"'
            }
            if `"`nologdir'`logdir'`logdir2'"'=="" {
                local logdir `"${TeXdoc_do_logdir}"'
                local logdir2 `"${TeXdoc_do_logdir2}"'
            }
            if `"`noprefix'`prefix'`prefix2'"'=="" {
                local noprefix `"${TeXdoc_do_noprefix}"'
                local prefix `"${TeXdoc_do_prefix}"'
                local prefix2 `"${TeXdoc_do_prefix2}"'
            }
            if `"`noprefix'`prefix'`prefix2'"'!="" local prefix0 prefix0
            if `"`nostpath'`stpath'`stpath2'"'=="" {
                local stpath `"${TeXdoc_do_stpath}"'
                local stpath2 `"${TeXdoc_do_stpath2}"'
            }
            foreach opt in do log keep output ltrim {
                if "``opt''`no`opt''"=="" local no`opt' `"${TeXdoc_do_no`opt'}"'
            }
            foreach opt in logall cmdlog beamer verbatim hardcode custom cmdstrip ///
                lbstrip gtstrip matastrip certify {
                if "``opt''`no`opt''"=="" local `opt' `"${TeXdoc_do_`opt'}"'
            }
            if `"`grdir'"'==""  local grdir  `"${TeXdoc_do_grdir}"'
            foreach opt in gropts alert tag linesize {
                if `"`macval(`opt')'"'=="" {
                    mata: st_local("`opt'", st_global("TeXdoc_do_`opt'"))
                }
            }
        }
        // initialize globals
        _texdoc_cleanup_stlog
        mata: texdoc_init()
        // initialize texdoc output file
        // - prepare file
        tempname fh
        qui file open `fh' using `"${TeXdoc_docname}"', write `replace' `append'
        file close `fh'
        di as txt `"(texdoc output file is ${TeXdoc_docname0})"'
        // - provide Mata file handle in global macro
        mata: st_global("TeXdoc_docname_FH", ///
            strofreal(fopen(st_global("TeXdoc_docname"), "a")))
    }
    else if `"${TeXdoc_docname}"'!="" {
        // update globals
        if `"`prefix'`prefix2'`noprefix'"'!="" {
            local prefix0 prefix0
            global TeXdoc_prefix0 "prefix0"
        }
        else {
            local prefix0 `"${TeXdoc_prefix0}"'
        }
        if `"`logdir'`logdir2'`nologdir'"'!="" {
            if `"`prefix0'"'=="" {
                if `"${TeXdoc_logdir}"'=="" {
                    if `"`logdir2'`logdir'"'!="" local noprefix noprefix
                }
                else {
                    if "`nologdir'"!="" local prefix prefix
                }
            }
            if (`"`logdir2'"'!="")      global TeXdoc_logdir `"`logdir2'"'
            else if ("`logdir'"!="") {
                mata: st_global("TeXdoc_logdir", ///
                    pathrmsuffix(st_global("TeXdoc_basename")))
            }
            else                        global TeXdoc_logdir ""
            if `"${TeXdoc_logdir}"'!="" {
                mata: texdoc_mkdir(pathjoin(st_global("TeXdoc_path"), ///
                    st_global("TeXdoc_logdir")))
            }
        }
        if `"`prefix'`prefix2'`noprefix'"'!="" {
            if ("`noprefix'"!="")       global TeXdoc_prefix ""
            else if (`"`prefix2'"'!="") global TeXdoc_prefix `"`prefix2'"'
            else {
                mata: st_global("TeXdoc_prefix", ///
                    pathrmsuffix(st_global("TeXdoc_basename")) + "_")
            }
        }
        if "`stpath'`stpath2'`nostpath'"!="" {
            if (`"`stpath2'"'!="")      global TeXdoc_stpath `"`stpath2'"'
            else if ("`stpath'"!="")    global TeXdoc_stpath `"${TeXdoc_path0}"'
            else                        global TeXdoc_stpath ""
        }
        foreach opt in do log keep output ltrim {
            if "``opt''`no`opt''"!="" global TeXdoc_no`opt' `no`opt''
        }
        foreach opt in logall cmdlog beamer verbatim hardcode custom cmdstrip ///
            lbstrip gtstrip matastrip certify {
            if "``opt''`no`opt''"!="" global TeXdoc_`opt' ``opt''
        }
        if `"`grdir'"'!=""  global TeXdoc_grdir `"`grdir'"'
        if `"${TeXdoc_grdir}"'!="" {
            mata: texdoc_mkdir(pathjoin(st_global("TeXdoc_path"), ///
                st_global("TeXdoc_grdir")))
        }
        foreach opt in gropts alert tag linesize {
            if `"``opt''"'!="" {
                global TeXdoc_`opt' `"`macval(`opt')'"'
            }
        }
    }
    else {
        di as txt "(texdoc not initialized; nothing to do)"
        exit
    }
    // clear s-returns (will be filled by texdoc close)
    sreturn clear
end

program texdoc_close, sclass
    if `"${TeXdoc_docname}"'=="" {
        di as txt "(texdoc not initialized; nothing to do)"
        exit
    }
    if `"`macval(0)'"'!="" error 198
    _texdoc_makelink `"${TeXdoc_docname}"' // returns local link
    di as txt `"(texdoc output written to {`link':${TeXdoc_docname0}})"'
    sreturn clear
    foreach s in certify custom nokeep hardcode alert tag verbatim cmdlog beamer ///
        nooutput noltrim gtstrip lbstrip cmdstrip matastrip nolog nodo linesize ///
        gropts grdir stpath prefix logdir path logall basename docname {
        mata: st_local("`s'", st_global("TeXdoc_`s'"))
        sreturn local `s' `"`macval(`s')'"'
    }
    _texdoc_cleanup
end

program texdoc_stlog
    version 10.1
    local caller : di _caller()
    gettoken subcmd args : 0, parse(",: ")
    local length = length(`"`subcmd'"')
    if `"`subcmd'"'==substr("close",1,max(`length',1)) {
        version `caller': texdoc_stlog_close`macval(args)'
    }
    else if `"`subcmd'"'==substr("oom",1,max(`length',1)) {
        version `caller': texdoc_stlog_oom 1`macval(args)'
    }
    else if `"`subcmd'"'==substr("quietly",1,max(`length',1)) {
        version `caller': texdoc_stlog_oom 0`macval(args)'
    }
    else if `"`subcmd'"'=="cnp" {
        texdoc_stlog_cnp`macval(args)'
    }
    else {
        capt noi version `caller': texdoc_stlog_open `macval(0)'
        local rc = _rc
        if `rc' _texdoc_cleanup_stlog
        exit `rc'
    }
end

program texdoc_stlog_open
    version 10.1
    local caller : di _caller()
    if `"${TeXdoc_docname}"'=="" {
        di as txt "(texdoc not initialized; nothing to do)"
        exit
    }
    if `"${TeXdoc_ststatus}"'!="" {
        di as err "texdoc stlog not allowed within stlog section"
        di as err "type {stata texdoc stlog close} to close the stlog section"
        exit 499
    }
    _texdoc_cleanup_stlog
    // colon syntax
    capt _on_colon_parse `macval(0)'
    if !_rc {
        local hascolon 1
        mata: st_local("command", st_global("s(after)"))
        mata: st_local("0", st_global("s(before)"))
    }
    else local hascolon 0
    // parse syntax and update settings
    syntax [anything(name=name0)] [using/] [, nostop ///
        NODO DO NOLOG LOG NOCMDLog CMDLog NOBEAMER BEAMER NOVERBatim VERBatim ///
        NOHardcode Hardcode NOKeep Keep NOCustom Custom NOCMDStrip CMDStrip ///
        NOLBStrip LBStrip NOGTStrip GTStrip NOMatastrip Matastrip ///
        NOOutput Output NOLTRIM LTRIM ///
        alert(str asis) tag(str asis) NOCERTify CERTify ///
        LInesize(numlist int max=1 >=40 <=255) ]
    if `"`using'"'=="" & "`stop'"!="" {
        di as err "nostop only allowed with texdoc stlog using"
        exit 198
    }
    if "`nolog'"!="" & "`cmdlog'"!="" {
        di as err "nolog and cmdlog not both allowed"
        exit 198
    }
    if "`nolog'"!=""  local nocmdlog nocmdlog
    if "`cmdlog'"!="" local log log
    if "`custom'"!="" & "`hardcode'"!="" {
        di as err "custom and hardcode not both allowed"
        exit 198
    }
    if "`custom'"!=""   local nohardcode nohardcode
    if "`hardcode'"!="" local nocustom nocustom
    if `hascolon' {
        if  `"`using'"'!="" {
            di as err "using not allowed with colon syntax"
            exit 198
        }
        if "`cmdlog'"!="" {
            di as err "cmdlog not allowed with colon syntax"
            exit 198
        }
        local nocmdlog nocmdlog
    }
    foreach opt in do log keep output ltrim {
        if "``opt''"!="" & "`no`opt''"!="" {
            di as err "`opt' and no`opt' not both allowed"
            exit 198
        }
        if "``opt''`no`opt''"=="" local no`opt' ${TeXdoc_no`opt'}
        global TeXdoc_stno`opt' `no`opt''
    }
    foreach opt in cmdlog beamer verbatim hardcode custom cmdstrip lbstrip ///
        gtstrip matastrip certify {
        if "``opt''"!="" & "`no`opt''"!="" {
            di as err "`opt' and no`opt' not both allowed"
            exit 198
        }
        if "``opt''`no`opt''"=="" local `opt' ${TeXdoc_`opt'}
        global TeXdoc_st`opt' ``opt''
    }
    foreach opt in alert tag {
        if `"`macval(`opt')'"'=="" {
            mata: st_local("`opt'", st_global("TeXdoc_`opt'"))
        }
        global TeXdoc_st`opt' `"`macval(`opt')'"'
        
    }
    if "`linesize'"=="" {
        local linesize ${TeXdoc_linesize}
    }
    if "`linesize'"!="" {
        global TeXdoc_stlinesize0 `"`c(linesize)'"'
        set linesize `linesize'
    }
    else {
        local linesize `"`c(linesize)'"'
    }
    global TeXdoc_stlinesize `"`linesize'"'
    // determine base name of output section (name0)
    if `"`name0'"'!="" {
        gettoken name0 rest : name0 // get rid of quotes around filename
        if `"`rest'"'!="" error 198
        global TeXdoc_stname0 `"`name0'"'
    }
    else {
        global TeXdoc_stcounter = ${TeXdoc_stcounter} + 1
        local name0 `"${TeXdoc_prefix}${TeXdoc_stcounter}"'
        global TeXdoc_stname0 `"`name0'"'
    }
    global TeXdoc_stgrcounter 0
    // generate variations of name and path
    mata: st_local("name", pathjoin(st_global("TeXdoc_logdir"), st_local("name0")))
    mata: st_local("filename0", pathjoin(st_global("TeXdoc_path"), st_local("name")))
    mata: st_local("texname0", pathjoin(st_global("TeXdoc_stpath"), st_local("name")))
    if c(os)=="Windows" {   // use forward slash in include path
        local texname0: subinstr local texname0 "\" "/", all
    }
    local filename `"`filename0'.log.tex"'
    local texname  `"`texname0'.log.tex"'
    global TeXdoc_stname      `"`name'"'
    global TeXdoc_stfilename0 `"`filename0'"'
    global TeXdoc_stfilename  `"`filename'"'
    global TeXdoc_sttexname0  `"`texname0'"'
    global TeXdoc_sttexname   `"`texname'"'
    // erase -texdoc local- backup and turn stlog status on
    if "`nodo'"=="" {
        capt erase `"`filename0'.stloc"'
    }
    global TeXdoc_ststatus "on"
    // open log file (unless -nolog-, -nodo-, or -cmdlog-)
    if "`nolog'`nodo'`cmdlog'"=="" {
        // backup current r-returns
        tempname rcurrent
        _return hold `rcurrent'
        // open log
        di as txt `"(opening texdoc stlog `name')"'
        qui log using `"`filename0'.smcl"', replace smcl name(TeXdoc_stlog)
        // restore r-returns
        _return restore `rcurrent'
    }
    // run command if colon syntax
    if `hascolon' {
        if "`nodo'"=="" {
            version `caller': `macval(command)'
        }
        version `caller': texdoc_stlog_close
        exit
    }
    // run do-file if -using-
    if `"`using'"'!="" {
        if "`nodo'"=="" {
            if "`stop'"!="" local nostop ", nostop"
            else            local nostop
            version `caller': do `"`using'"'`nostop'
        }
        local cmdlogopt
        if "`cmdlog'"!="" {
            local cmdlogopt `", _cmdlog0(`using')"'
        }
        version `caller': texdoc_stlog_close`cmdlogopt'
        exit
    }
end

program texdoc_stlog_oom
    version 10.1
    local caller : di _caller()
    gettoken message 0 : 0
    if `"${TeXdoc_docname}"'=="" {
        version `caller': `macval(0)'
        exit
    }
    if `"${TeXdoc_ststatus}"'=="" {
        version `caller': `macval(0)'
        exit
    }
    version `caller': quietly `macval(0)'
    if `message' di _n as txt "\TeXdoc_OOM"
end

program texdoc_stlog_cnp
    if `"`macval(0)'"'!="" error 198
    if `"${TeXdoc_docname}"'=="" exit
    if `"${TeXdoc_ststatus}"'=="" exit
    di as txt "\TeXdoc_CNP"
end

program texdoc_stlog_close, sclass
    version 10.1
    local caller : di _caller()
    if `"${TeXdoc_docname}"'=="" {
        di as txt "(texdoc not initialized; nothing to do)"
        exit
    }
    if `"${TeXdoc_ststatus}"'=="" {
        di as txt "(no stlog open; nothing to do)"
        exit
    }
    global TeXdoc_ststatus ""
    syntax [, _cmdlog(str) _cmdlog0(str) _indent(int 0) ]
    // read settings
    foreach opt in nodo nolog cmdlog beamer verbatim hardcode nokeep custom cmdstrip ///
        lbstrip gtstrip matastrip nooutput noltrim certify grcounter filename ///
        filename0 texname texname0 name0 name {
        local `opt' ${TeXdoc_st`opt'}
    }
    foreach opt in alert tag linesize linesize0 {
        mata: st_local("`opt'", st_global("TeXdoc_st`opt'"))
    }
    if `"`linesize0'"'!="" {
        set linesize `linesize0'
    }
    if "`beamer'"!="" local beamer "[beamer]"
    // backup current r-returns
    tempname rcurrent
    _return hold `rcurrent'
    // process cmdlog
    if "`cmdlog'"!="" {
        if `"`_cmdlog'`_cmdlog0'"'!="" {
            if `"`_cmdlog0'"'!="" {
                qui copy `"`_cmdlog0'"' `"`filename'"', replace
            }
            else { // get cmdlog from snippet collection
                nobreak {
                    capt n break {
                        mata: texdoc_instance_fh("fh")
                        mata: texdoc_stripcmdlog_getsnippet(`fh'=.)
                    }
                    local rc = _rc 
                    capture mata: texdoc_closeout_fh(`fh')
                    capture mata: mata drop `fh'
                    if `rc' exit `rc'
                }
            }
            if "`verbatim'"=="" {
                qui log using `"`filename0'.smcl"', replace smcl name(TeXdoc_stlog)
                type `"`filename'"'
                qui log close TeXdoc_stlog
                qui log texman `"`filename0'.smcl"' `"`filename'"', ///
                    ll(`linesize') replace
                capt erase `"`filename0'.smcl"'
            }
            nobreak {
                capt n break {
                    mata: texdoc_instance_fh("fh")
                    mata: texdoc_stripcmdlog(`fh'=.)
                }
                local rc = _rc 
                capture mata: texdoc_closeout_fh(`fh')
                capture mata: mata drop `fh'
                if `rc' exit `rc'
            }
            if !("`hardcode'"!="" & "`nokeep'"!="") {
                mata: st_local("logname", pathjoin(st_global("TeXdoc_path0"), st_local("name")))
                _texdoc_makelink `"`filename'"' // returns local link
                di as txt `"(log-file written to {`link':`logname'.log.tex})"'
            }
        }
        else { // can only happen in interactive mode
            // do nothing
        }
    }
    // process log file
    else if "`nolog'`nodo'"=="" {
        qui log close TeXdoc_stlog
        tempfile tmplog
        qui log texman `"`filename0'.smcl"' `"`tmplog'"', ///
            ll(`linesize') replace
        capt erase `"`filename0'.smcl"'
        local certify1 "`certify'"
        if "`certify1'"!="" {
            capt confirm file `"`filename'"'
            if _rc==601 {
                di as txt "(certify: no previous version found)"
                local certify1 ""
            }
        }
        nobreak {
            capt n break {
                mata: texdoc_instance_fh("fh")
                mata: texdoc_striplog(`fh'=.)
            }
            local rc = _rc 
            capture mata: texdoc_closeout_fh(`fh')
            capture mata: mata drop `fh'
            if `rc' exit `rc'
        }
        if !("`hardcode'"!="" & "`nokeep'"!="") {
            mata: st_local("logname", pathjoin(st_global("TeXdoc_path0"), st_local("name")))
            _texdoc_makelink `"`filename'"' // returns local link
            di as txt `"(log-file written to {`link':`logname'.log.tex})"'
        }
    }
    // write tex insert (unless -nolog- or -custom-)
    if "`nolog'`custom'"=="" {
        // copy log to main document if -hardcode-
        if "`hardcode'"!="" {
            if "`cmdlog'"!="" & "`verbatim'"!="" {
                texdoc_write write \begin{stverbatim}
                texdoc_write write \begin{verbatim}
            } 
            else texdoc_write write \begin{stlog}`beamer'
            capt confirm file `"`filename'"'
            if _rc di as txt `"(`filename' not found)"'
            else {
                quietly texdoc_append `"`filename'"'
                di as txt `"(texdoc stlog `name' appended)"'
            }
            if "`cmdlog'"!="" & "`verbatim'"!="" {
                texdoc_write write \end{verbatim}
                texdoc_write write \end{stverbatim}
            } 
            else texdoc_write write \end{stlog}
            if "`nokeep'"!="" {
                capt erase `"`filename'"'
            }
        }
        // include link to log file
        else {
            if "`cmdlog'"!="" & "`verbatim'"!="" {
                texdoc_write write \begin{stverbatim}
                texdoc_write write \verbatiminput{`texname'}
                texdoc_write write \end{stverbatim}
            }
            else if strpos(`"`texname'"', "-") { // "-" causes problem for \input{}
                texdoc_write write {\def\TeXdocstname{`texname'}
                texdoc_write write \begin{stlog}`beamer'\input{\TeXdocstname}\end{stlog}}
            }
            else {
                texdoc_write write \begin{stlog}`beamer'\input{`texname'}\end{stlog}
            }
        }
    }
    // s-returns
    mata: st_local("indent", " " * `_indent')
    sreturn clear
    foreach s in certify custom nokeep hardcode tag alert verbatim cmdlog beamer ///
        nooutput noltrim gtstrip lbstrip cmdstrip matastrip nolog nodo ///
        linesize indent texname0 texname filename0 filename name0 name {
        sreturn local `s' `"``s''"'
    }
    // restore r-returns
    _return restore `rcurrent'
end

program texdoc_graph
    if `"${TeXdoc_docname}"'=="" {
        di as txt "(texdoc not initialized; nothing to do)"
        exit
    }
    // determine base name and path of graph
    syntax [anything(name=grname)] [, * ]
    gettoken grname rest : grname // get rid of quotes around filename
    if `"`rest'"'!="" error 198
    if `"${TeXdoc_ststatus}"'!="" {  // inside stlog section
        if `"`grname'"'=="" {        // get name from stlog
            local grname `"${TeXdoc_stname0}"'
            if ${TeXdoc_stgrcounter}>0 {
                local grname `"`grname'_${TeXdoc_stgrcounter}"'
            }
            global TeXdoc_stgrcounter = ${TeXdoc_stgrcounter} + 1
        }
        local export = (`"${TeXdoc_stnodo}"'=="")
    }
    else {                             // outside stlog section
        if `"${TeXdoc_stname0}"'=="" { // no results from texdoc stlog available
            if `"`grname'"'=="" {
                di as err "no stlog available;" _c
                di as err " need to specify a name for the graph"
                exit 499
            }
            local export 1
        }
        else {
            if `"`grname'"'=="" {    // get name from previous stlog
                local grname `"${TeXdoc_stname0}"'
                if ${TeXdoc_stgrcounter}>0 {
                    local grname `"`grname'_${TeXdoc_stgrcounter}"'
                }
            }
            local export = (`"${TeXdoc_stnodo}"'=="")
        }
    }
    if `"${TeXdoc_grdir}"'!="" {
        mata: st_local("grname", pathjoin(st_global("TeXdoc_grdir"), st_local("grname")))
    }
    else {
        mata: st_local("grname", pathjoin(st_global("TeXdoc_logdir"), st_local("grname")))
    }
    mata: st_local("filename", pathjoin(st_global("TeXdoc_path"), st_local("grname")))
    mata: st_local("texname", pathjoin(st_global("TeXdoc_stpath"), st_local("grname")))
    if c(os)=="Windows" {   // use forward slash in include path
        local texname: subinstr local texname "\" "/", all
    }
    mata: st_local("grname", pathjoin(st_global("TeXdoc_path0"), st_local("grname")))
    // parse options and read defaults
    _texdoc_graph_syntax, `macval(options)'
    mata: st_local("opt_options", st_global("TeXdoc_gropts"))
    _texdoc_graph_syntax opt_, `macval(opt_options)'
    foreach opt in as optargs name {
        if `"`macval(`opt')'"'=="" {
            local `opt' `macval(opt_`opt')'
        }
    }
    if "`figure'`nofigure'"=="" {
        local nofigure `opt_nofigure'
        local figure   `opt_figure'
        local figure2  `macval(opt_figure2)'
    }
    if "`figure'"!="" & `"`macval(figure2)'"'=="" {
        local figure2 `macval(opt_figure2)'
    }
    foreach opt in epsfig suffix center custom {
        if `"``opt''`no`opt''"'=="" {
            local `opt'   `opt_`opt''
            local no`opt' `opt_no`opt''
        }
    }
    foreach opt in caption label {
        if `"`macval(`opt')'"'=="" {
            local `opt'   `macval(opt_`opt')'
        }
    }
    if "`cabove'`cbelow'"=="" {
        local cabove `opt_cabove'
        local cbelow `opt_cbelow'
    }
    if `"`options'"'=="" local options `opt_options'
    // strip outer quotes from options with arguments
    _texdoc_graph_syntax2, `as' `macval(optargs)' `macval(figure2)' ///
        `macval(caption)' `macval(label)' `name'
    // set defaults
    if "`nocenter'"==""         local center center    // center is default
    if "`cabove'`cbelow'"==""   local cbelow cbelow    // cbelow is default
    if `"`macval(caption)'`macval(label)'"'!="" & "`nofigure'"=="" {
        local figure figure                 // center and label imply figure
    }
    if `"`as'"'=="" {
        if "`epsfig'"!="" local as "eps"
        else              local as "pdf"
    }
    if "`nosuffix'"=="" {
        if `:list sizeof as'==1 {
            local suffix `".`as'"'
        }
        else {
            if "`suffix'"!="" {
                local suffix: word 1 of `as'
                local suffix `".`suffix'"'
            }
        }
    }
    else local suffix
    if `"`name'"'!="" local name name(`name')
    // export graph
    if `export' {
        foreach ff of local as {
            qui graph export `"`filename'.`ff'"', replace `name' `options'
            _texdoc_makelink `"`filename'.`ff'"' // returns local link
            di as txt `"(graph written to {`link':`grname'.`ff'})"'
        }
    }
    // include link in document
    if "`custom'"!="" exit
    local indent
    if "`figure'"!="" {
        if "`figure2'"!="" {
            local figure2 `"[`macval(figure2)']"'
        }
        texdoc_write write \begin{figure}`macval(figure2)'
        local indent "    "
        if "`center'"!="" {
            texdoc_write write `indent'\centering
        }
    }
    else if "`center'"!="" {
        texdoc_write write \begin{center}
        local indent "    "
    }
    if "`cabove'"!="" {
        if `"`caption'"'!="" {
            texdoc_write write `indent'\caption{`macval(caption)'}
        }
        if `"`label'"'!=""     {
            texdoc_write write `indent'\label{`macval(label)'}
        }
    }
    if "`epsfig'"!="" {
        if `"`optargs'"'!="" {
            local includegr `"\epsfig{file=`texname'`suffix',`macval(optargs)'}"'
        }
        else local includegr `"\epsfig{file=`texname'`suffix'}"'
    }
    else {
        if `"`optargs'"'!="" {
            local includegr `"\includegraphics[`macval(optargs)']{`texname'`suffix'}"'
        }
        else local includegr `"\includegraphics{`texname'`suffix'}"'
    }
    texdoc_write write `indent'`includegr'
    if "`cbelow'"!="" {
        if `"`caption'"'!="" {
            texdoc_write write `indent'\caption{`macval(caption)'}
        }
        if `"`label'"'!=""     {
            texdoc_write write `indent'\label{`macval(label)'}
        }
    }
    if "`figure'"!="" {
        texdoc_write write \end{figure}
    }
    else if "`center'"!="" {
        texdoc_write write \end{center}
    }
end

program _texdoc_graph_syntax
    syntax [anything(name=prefix)] [,                           ///
        as(passthru) Optargs(passthru) NOSuffix Suffix          ///
        NOEPSFIG epsfig NOCenter Center                         ///
        NOFigure Figure Figure2(passthru) NOCUSTOM custom       ///
        CAPtion(passthru) Label(passthru) CAbove CBelow         ///
        name(passthru) * ]
    if "`cabove'"!="" & "`cbelow'"!="" {
        di as err "cabove and cbelow not both allowed"
        exit 198
    }
    if `"`macval(figure2)'"'!="" local figure figure
    foreach opt in suffix epsfig center figure custom {
        if "``opt''"!="" & "`no`opt''"!="" {
            di as err "`opt' and no`opt' not both allowed"
            exit 198
        }
    }
    foreach opt in as optargs nosuffix suffix noepsfig epsfig   ///
        nocenter center nofigure figure figure2 nocustom custom ///
        caption label cabove cbelow name options {
        c_local `prefix'`opt' `"`macval(`opt')'"'
    }
end

program _texdoc_graph_syntax2
    syntax [, as(str) optargs(str) figure2(str) caption(str) ///
        label(str) name(str) ]
    foreach opt in as optargs figure2 caption label name {
        c_local `opt' `"`macval(`opt')'"'
    }
end

program texdoc_strip
    syntax [anything] [, Replace Append ]
    if "`replace'"!="" & "`append'"!="" {
        di as err "replace and append not both allowed"
        exit 198
    }
    gettoken in out : anything
    gettoken out rest : out
    if `"`rest'"'!="" error 198
    if `"`in'"'=="" | `"`out'"'==""  {
        di as err "must specify input filename and output filename"
        exit 198
    }
    if `"`replace'`append'"'=="" confirm new file `"`out'"'
    nobreak {
        capt n break {
            mata: texdoc_instance_fh("fh")
            mata: texdoc_strip(`fh'=.)
        }
        local rc = _rc 
        capture mata: texdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
    _texdoc_makelink `"`out'"' // returns local link
    di as txt `"(output written to {`link':`out'})"'
end

program texdoc_do
    version 10.1
    local caller : di _caller()
    // options and settings
    _parse comma dofile 0 : 0
    syntax [, NOInit Init Init2(str) cd nostop * ]
    gettoken dofile args : dofile
    if `"`dofile'"'=="" {
        di as err "filename required"
        exit 100
    }
    if `"`init2'"'!="" local init init
    if "`noinit'"!="" & "`init'"!="" {
        di as err "init() and noinit not both allowed"
        exit 198
    }
    local doinit
    if `"${TeXdoc_docname}"'=="" & "`noinit'"=="" local doinit doinit
    if  `"`init2'"'=="" & "`init'`doinit'"!="" {
        mata: texdoc_do_init2() // sets local init2
    }
    _texdoc_do, `macval(options)' // set global defaults
    if `"${TeXdoc_docname}"'!="" & `"`init'"'=="" {
        // update globals if document already open
        texdoc_init, `macval(options)'
    }
    mata: texdoc_add_suffix("dofile", ".do")
    confirm file `"`dofile'"'
    mata: texdoc_add_abspath("dofile")
    global TeXdoc_dofile `"`dofile'"'
    if "`cd'"!="" {
        mata: texdoc_get_path(st_local("dofile")) // returns local path
        qui cd `"`path'"'
        di as txt `"(cd `path')"'
    }
    // preprocess do-file
    tempfile dobuf
    nobreak {
        capt n break {
            mata: texdoc_instance_fh("fh")
            mata: texdoc_do(`fh'=.)
        }
        local rc = _rc
        capture mata: texdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
    // run do-file
    if "`stop'"!="" {
        version `caller': do `"`dobuf'"' `macval(args)', nostop
    }
    else {
        version `caller': do `"`dobuf'"' `macval(args)'
    }
end

program _texdoc_do
    syntax [, Replace Append NOLOGDIR logdir LOGDIR2(str) NOLOGALL LOGALL ///
        NOPrefix Prefix Prefix2(str) NOSTPATH stpath STPATH2(str) ///
        NODO DO NOLOG LOG NOCMDLog CMDLog NOBEAMER BEAMER NOVERBatim VERBatim ///
        NOHardcode Hardcode NOKeep Keep NOCustom Custom NOCMDStrip CMDStrip ///
        NOLBStrip LBStrip NOGTStrip GTStrip NOMatastrip Matastrip ///
        NOOutput Output NOLTRIM LTRIM GRopts(str asis) grdir(str) ///
        alert(str asis) tag(str asis) NOCERTify CERTify ///
        LInesize(numlist int max=1 >=40 <=255) ]
    if "`replace'"!="" & "`append'"!="" {
        di as err "replace and append not both allowed"
        exit 198
    }
    if "`nolog'"!="" & "`cmdlog'"!="" {
        di as err "nolog and cmdlog not both allowed"
        exit 198
    }
    if "`nolog'"!=""  local nocmdlog nocmdlog
    if "`cmdlog'"!="" local log log
    if "`custom'"!="" & "`hardcode'"!="" {
        di as err "custom and hardcode not both allowed"
        exit 198
    }
    if "`custom'"!=""   local nohardcode nohardcode
    if "`hardcode'"!="" local nocustom nocustom
    foreach opt in logdir prefix stpath {
        if "``opt''``opt'2'"!="" & "`no`opt''"!="" {
            di as err "`opt'() and no`opt' not both allowed"
            exit 198
        }
    }
    foreach opt in logall do log cmdlog beamer verbatim hardcode keep custom ///
        cmdstrip lbstrip gtstrip matastrip output ltrim certify {
        if "``opt''"!="" & "`no`opt''"!="" {
            di as err "`opt' and no`opt' not both allowed"
            exit 198
        }
    }
    // read global defaults if nested
    if `"${TeXdoc_dofile}"'!=""{
        if `"`replace'`append'"'=="" {
            local replace `"${TeXdoc_do_replace}"'
            local append `"${TeXdoc_do_append}"'
        }
        if `"`nologdir'`logdir'`logdir2'"'=="" {
            local logdir `"${TeXdoc_do_logdir}"'
            local logdir2 `"${TeXdoc_do_logdir2}"'
        }
        if `"`noprefix'`prefix'`prefix2'"'=="" {
            local noprefix `"${TeXdoc_do_noprefix}"'
            local prefix `"${TeXdoc_do_prefix}"'
            local prefix2 `"${TeXdoc_do_prefix2}"'
        }
        if `"`nostpath'`stpath'`stpath2'"'=="" {
            local stpath `"${TeXdoc_do_stpath}"'
            local stpath2 `"${TeXdoc_do_stpath2}"'
        }
        foreach opt in do log keep output ltrim {
            if "``opt''`no`opt''"=="" local no`opt' `"${TeXdoc_do_no`opt'}"'
        }
        foreach opt in logall cmdlog beamer verbatim hardcode custom cmdstrip ///
            lbstrip gtstrip matastrip certify {
            if "``opt''`no`opt''"=="" local `opt' `"${TeXdoc_do_`opt'}"'
        }
        if `"`grdir'"'==""  local grdir `"${TeXdoc_do_grdir}"'
        foreach opt in gropts alert tag linesize {
            if `"`macval(`opt')'"'=="" {
                mata: st_local("`opt'", st_global("TeXdoc_do_`opt'"))
            }
        }
    }
    foreach opt in replace append logdir logdir2 noprefix prefix prefix2 stpath ///
        stpath2 logall nodo nolog cmdlog beamer verbatim hardcode nokeep custom ///
        cmdstrip lbstrip gtstrip matastrip nooutput noltrim gropts grdir ///
        alert tag certify linesize {
        global TeXdoc_do_`opt' `"`macval(`opt')'"'
    }
end

version 10.1
mata:
mata set matastrict on

/*---------------------------------------------------------------------------*/
/*  texdoc append                                                            */
/*---------------------------------------------------------------------------*/

// add contents of file to latex document, after applying substitutions
void texdoc_append(real scalar fh, real scalar fh2)
{
    real scalar      i
    string colvector f
    string rowvector sub
    
    f = _texdoc_cat(st_local("using"), fh2)
    sub = tokens(st_local("substitute"))
    if (mod(length(sub), 2)) sub = (sub, "")
    for (i=1; i<=(length(sub)/2); i++) {
        f = subinstr(f, sub[(i-1)*2+1], sub[i*2])
    }
    _texdoc_fput(fh, f)
}

// read snippet and append to latex document; restore snippet collection
// if it has been destroyed
void texdoc_append_snippet(real scalar fh, real scalar fh2)
{
    real scalar      n
    pointer scalar   p
    
    p = findexternal("TeXdoc_do_snippets")
    if (p==NULL) {
        p = crexternal("TeXdoc_do_snippets")
        fh2 = fopen(st_global("TeXdoc_do_snippets"), "r")
        *p = fgetmatrix(fh2)
        fclose(fh2)
    }
    n = strtoreal(st_local("0"))
    _texdoc_fput(fh, texdoc_append_snippet_subst(*(*p)[n], fh2))
}

// apply macro substitutions in snippet
string colvector texdoc_append_snippet_subst(string colvector s, real scalar fh)
{
    real scalar   i
    string scalar fn
    string matrix S
    
    // substitutions from -texdoc substitute-
    if ((S=st_global("TeXdoc_substitute"))!="") {
        S = tokens(S)
        for (i=1; i<=(length(S)/2); i++) {
            s = subinstr(s, S[(i-1)*2+1], S[i*2])
        }
    }
    // substitutions from -texdoc local-
    fn = st_global("TeXdoc_stloc")
    if (fn=="") return(s)
    fh = fopen(fn, "r")
    S = fgetmatrix(fh)
    fclose(fh)
    for (i=1; i<=rows(S); i++) {
        s = subinstr(s, "`" + S[i,1] + "'", S[i,2])
    }
    return(s)
}

/*---------------------------------------------------------------------------*/
/*  texdoc local                                                             */
/*---------------------------------------------------------------------------*/

void texdoc_local_put(real scalar fh)
{
    string scalar fn, mname, meval
    string matrix S
    
    mname = st_local("mname")
    meval = st_local("meval")
    fn = st_global("TeXdoc_stfilename0") + ".stloc"
    if (fileexists(fn)) {
        fh = fopen(fn, "r")
        S = fgetmatrix(fh)
        fclose(fh)
        if (anyof(S[,1], mname)) {
            S[select(1::rows(S), S[,1]:==mname), 2] = meval
        }
        else S = S \ (mname, meval)
    }
    else S = (mname, meval)
    texdoc_fopen_replace(fn, fh, "w")
    fputmatrix(fh, S)
    fclose(fh)
    st_global("TeXdoc_stloc", fn)
}

void texdoc_local_get(real scalar fh)
{
    string scalar fn, mname
    string matrix S
    
    mname = st_local("mname")
    fn = st_global("TeXdoc_stfilename0") + ".stloc"
    fh = fopen(fn, "r")
    S = fgetmatrix(fh)
    fclose(fh)
    if (anyof(S[,1], mname)) {
        st_local("meval", S[select(1::rows(S), S[,1]:==mname), 2])
    }
    else _error(3499)
    st_global("TeXdoc_stloc", fn)
}

/*---------------------------------------------------------------------------*/
/*  texdoc substitute                                                        */
/*---------------------------------------------------------------------------*/

void texdoc_substitute()
{
    string scalar s, s0
    
    s = st_local("anything")
    if (mod(length(tokens(s)), 2)) s = s + " " + `""""'
    if (st_local("add")!="") {
        if (s!="") {
            s0 = st_global("TeXdoc_substitute")
            st_global("TeXdoc_substitute", (s0!="" ? s0 + " " : "") + s)
        }
    }
    else st_global("TeXdoc_substitute", s)
}

/*---------------------------------------------------------------------------*/
/* texdoc init                                                               */
/*---------------------------------------------------------------------------*/

// set texdoc init globals
void texdoc_init()
{
    string scalar fn, path, path0, fname
    pragma unset  path
    pragma unset  fname
    
    fn = st_local("anything")
    pathsplit(fn, path, fname)
    path0 = path
    if (pathisabs(path)) texdoc_mkdir(path)
    else {
        texdoc_mkdir(path)
        path = pathjoin(pwd(), path)
    }
    if (pathsuffix(fname)=="") fname = fname + ".tex"
    fn = pathjoin(path, fname)
    if (fn==st_global("TeXdoc_dofile")) {
        display("{err}init docname must be different from source do-file")
        exit(error(498))
    }
    st_global("TeXdoc_docname",       fn)       // filename with abs. path
    st_global("TeXdoc_docname0",      pathjoin(path0, fname))
    st_global("TeXdoc_basename",      fname)
    st_global("TeXdoc_path",          path)     // absolute path
    st_global("TeXdoc_path0",         path0)    // path as specified
    if (st_local("logdir2")!="")      st_global("TeXdoc_logdir", st_local("logdir2"))
    else if (st_local("logdir")!="")  st_global("TeXdoc_logdir", pathrmsuffix(fname))
    else                              st_global("TeXdoc_logdir", "")
    if (st_global("TeXdoc_logdir")!="") {
        texdoc_mkdir(pathjoin(path0, st_global("TeXdoc_logdir")))
    }
    if (st_local("noprefix")!="")     st_global("TeXdoc_prefix", "")
    else if (st_local("prefix2")!="") st_global("TeXdoc_prefix", st_local("prefix2"))
    else if (st_local("prefix")!="")  st_global("TeXdoc_prefix", pathrmsuffix(fname) + "_")
    else if (st_global("TeXdoc_logdir")!="") st_global("TeXdoc_prefix", "")
    else                              st_global("TeXdoc_prefix", pathrmsuffix(fname) + "_")
    if (st_local("stpath2")!="")      st_global("TeXdoc_stpath", st_local("stpath2"))
    else if (st_local("stpath")!="")  st_global("TeXdoc_stpath", path0)
    else                              st_global("TeXdoc_stpath", "")
    st_global("TeXdoc_stcounter",     "0")
    st_global("TeXdoc_prefix0",       st_local("prefix0"))
    st_global("TeXdoc_logall",        st_local("logall"))
    st_global("TeXdoc_nodo",          st_local("nodo"))
    st_global("TeXdoc_nolog",         st_local("nolog"))
    st_global("TeXdoc_cmdlog",        st_local("cmdlog"))
    st_global("TeXdoc_beamer",        st_local("beamer"))
    st_global("TeXdoc_verbatim",      st_local("verbatim"))
    st_global("TeXdoc_hardcode",      st_local("hardcode"))
    st_global("TeXdoc_nokeep",        st_local("nokeep"))
    st_global("TeXdoc_custom",        st_local("custom"))
    st_global("TeXdoc_cmdstrip",      st_local("cmdstrip"))
    st_global("TeXdoc_lbstrip",       st_local("lbstrip"))
    st_global("TeXdoc_gtstrip",       st_local("gtstrip"))
    st_global("TeXdoc_matastrip",     st_local("matastrip"))
    st_global("TeXdoc_nooutput",      st_local("nooutput"))
    st_global("TeXdoc_noltrim",       st_local("noltrim"))
    st_global("TeXdoc_certify",       st_local("certify"))
    st_global("TeXdoc_grdir",         st_local("grdir"))
    if (st_global("TeXdoc_grdir")!="") {
        texdoc_mkdir(pathjoin(path0, st_global("TeXdoc_grdir")))
    }
    st_global("TeXdoc_gropts",        st_local("gropts"))
    st_global("TeXdoc_alert",         st_local("alert"))
    st_global("TeXdoc_tag",           st_local("tag"))
    st_global("TeXdoc_linesize",      st_local("linesize"))
    st_global("TeXdoc_substitute",    "")
}

/*---------------------------------------------------------------------------*/
/* texdoc stlog                                                              */
/*---------------------------------------------------------------------------*/

// process log file
void texdoc_striplog(real scalar fh)
{
    real scalar      i, i0, r, a, c, inmata, wd,
                     lbstrip, gtstrip, matastrip, cmdstrip
    real colvector   p
    string scalar    s, indent
    string rowvector f

    lbstrip = (st_local("lbstrip")!="")
    gtstrip = (st_local("gtstrip")!="")
    matastrip = (st_local("matastrip")!="")
    cmdstrip = (st_local("cmdstrip")!="")
    f = _texdoc_cat(st_local("tmplog"), fh)
    r = rows(f)
    if (r<1) return
    p = J(r,1,1)
    if (r>1) {
        if (f[|r-1 \ .|]==(". ", "end of do-file")') {
            p[|r-1 \ .|] = J(2, 1, 0)    // if -texdoc stlog using-
            r = r - 2
            if (r<1) return
        }
    }
    i0 = 1
    if (f[1]=="{\smallskip}") { // strip first line
        p[1] = 0; i0 = 2
    }
    c = inmata = 0
    for (i=i0; i<=r; i++) {
        s = f[i]
        if (inmata) {
            if (substr(s,1,2)!=": ") continue
        }
        else {
            if (s=="\\TeXdoc_OOM") {
                f[i] = "\oom"
                c = 0
                continue
            }
            if (s=="\\TeXdoc_CNP") {
                f[i] = "\cnp"
                c = 0
                continue
            }
            if (substr(s,1,2)!=". ") {
                if (c==0) continue
                // check for "  #. " command line
                if (_texdoc_striplog_check_numcmd(f, i, c)==0) {
                    if (c>1) {
                        c = 0
                        continue
                    }
                    c++ // loops start with 2, not with 1
                    if (_texdoc_striplog_check_numcmd(f, i, c)==0) {
                        c = 0
                        continue
                    }
                }
                c++
            }
            else if (c==0) c = 1 // can contain subsequent "  #. " lines
        }
        // read command line
        a = i
        s = _texdoc_striplog_read_cmd(f, i, r, inmata, lbstrip, gtstrip)
        // handle mata ending
        if (inmata) {
            if (strtrim(s)=="end") {
                inmata = 0
                if (matastrip) {
                    _texdoc_striplog_mata_end(f, i, r)
                    p[|a \ i|] = J(i-a+1, 1, 0)
                    matastrip = 0
                    continue
                }
            }
            if (cmdstrip) p[|a \ i|] = J(i-a+1, 1, 0)
            continue
        }
        // handle mata opening
        if (anyof(("mata","mata:","mata :"), stritrim(strtrim(s)))) {
            inmata = 1
            if (matastrip) {
                if (a==i0) { // remove mata opening
                    _texdoc_striplog_mata(f, i, r) // capture ---mata ()---
                    p[|a \ i|] = J(i-a+1, 1, 0)
                    continue
                }
                matastrip = 0
            }
            if (cmdstrip) p[|a \ i|] = J(i-a+1, 1, 0)
            continue
        }
        // handle texdoc commands
        if (strrtrim(substr(strltrim(s), 1, 7))=="texdoc") {  // texdoc ...
            wd = strlen(s)
            s = strltrim(s)
            indent = (wd - strlen(s)) * " "
            s = tokens(substr(s, 8, .), ", ")
            if (i==r) {
                if (texdoc_cmdmatch(s, ("stlog", "close"), (1, 1))) {
                    p[|a \ .|] = J(r-a+1, 1, 0)
                    break   // end of logfile
                }
            }
            if (texdoc_cmdmatch(s, ("stlog", "cnp"), (1, 3))) {
                p[|a \ i|] = J(i-a+1, 1, 0)
                continue
            }
            if (texdoc_cmdmatch(s, ("stlog", "oom"), (1, 1))) {
                i = texdoc_cut(f, p, a, i, "oom", 1, indent, 1) - 1
                continue
            }
            if (texdoc_cmdmatch(s, ("stlog", "quietly"), (1, 1))) {
                i = texdoc_cut(f, p, a, i, "quietly", 1, indent, 1) - 1
                continue
            }
            // remove all other texdoc commands
            while (1) { // capture output
                if (i==r) break
                if (substr(f[i+1],1,2)==". ") break
                i++
            }
            p[|a \ i|] = J(i-a+1, 1, 0)
            continue
        }
        if (cmdstrip) p[|a \ i|] = J(i-a+1, 1, 0)
    }
    f = select(f, p)
    _texdoc_striplog_alert(f, st_local("alert"))
    _texdoc_striplog_tag(f, st_local("tag"))
    texdoc_fput(st_local("filename"), fh, f, "w", 1+(st_local("certify1")!=""))
}

// check whether line starts with "  #. "
real scalar _texdoc_striplog_check_numcmd(string colvector f, real scalar i, 
    real scalar c)
{
    real scalar   l, w
    string scalar n
    
    n = strofreal(c)
    l = strlen(n)
    w = max((0, 3-l))
    return(substr(f[i],1,l+w+2)==(w*" "+n+". "))
}

// read command line and optionally strip line break comments
string scalar _texdoc_striplog_read_cmd(string colvector f, real scalar i,
    real scalar r, real scalar inmata, real scalar lbstrip, 
    real scalar gtstrip) 
{
    real scalar   lb, cb
    string scalar s, stmp
    
    lb = cb = 0
    stmp = substr(f[i],3,.)
    s = texdoc_strip_comments(stmp, lb, cb, inmata)
    while (1) {
        if (lbstrip) {
            if (lb) {
                lb = texdoc_locate_lb(stmp, cb)
                if (lb<.) f[i] = substr(f[i],1,2) + substr(stmp, 1, lb)
            }
        }
        if (i==r) break
        if (substr(f[i+1],1,2)!="> ") break
        i++
        stmp = substr(f[i],3,.)
        s = s + texdoc_strip_comments(stmp, lb, cb, 1)
        if (gtstrip) f[i] = "  " + stmp
    }
    return(s)
}

// remove Mata opening output
void _texdoc_striplog_mata(string colvector f, real scalar i, real scalar r)
{
    if (i<r) {
        if (substr(f[i+1],1,4)=="\HLI") {
            i++
            if (i<r) { 
                if (substr(f[i+1],1,4)=="\HLI" |
                    substr(f[i+1],1,2)=="> ") {
                    i++
                }
            }
        }
    }
}

// remove Mata ending output
void _texdoc_striplog_mata_end(string colvector f, real scalar i, 
    real scalar r)
{
    if (i<r) {
        if (substr(f[i+1],1,4)=="\HLI") {
            i++
            if (i<r) { 
                if (f[i+1]=="{\smallskip}") {
                    i++
                }
            }
        }
    }
}

// add \alert{} to specified tokens
void _texdoc_striplog_alert(string colvector f, string scalar alert)
{
    real scalar i
    
    if (alert=="") return
    alert = tokens(alert)
    for (i=1; i<=length(alert); i++) {
        f = subinstr(f, alert[i], "\alert{" + alert[i] + "}")
    }
}

// add tags to specified tokens; last two tokens are the start and end tags
void _texdoc_striplog_tag(string colvector f, string scalar tag)
{
    transmorphic     t
    real scalar      i, i0, j, l
    string scalar    start, stop, s
    
    if (tag=="") return
    t = tokeninit()
    tokenpchars(t,"=")
    tokenset(t, tag)
    tag = tokengetall(t)
    l = length(tag)
    i0 = 1
    for (j=1; j<=l; j++) {
        if (tag[j]=="=") {
            if (j==i0) continue // first element in list is "="
            if ((j+1)>l) start = ""
            else         start = _texdoc_striplog_tag_noquotes(tag[j+1])
            if ((j+2)>l) stop  = ""
            else         stop  = _texdoc_striplog_tag_noquotes(tag[j+2])
            for (i=i0; i<=(j-1); i++) {
                s = _texdoc_striplog_tag_noquotes(tag[i])
                f = subinstr(f, s, start + s + stop)
            }
            j = j + 2
            i0 = j + 1
        }
    }
}
string scalar _texdoc_striplog_tag_noquotes(string scalar s)
{
    if      (substr(s, 1, 1)==`"""')       s = substr(s, 2, strlen(s)-2)
    else if (substr(s, 1, 2)=="`" + `"""') s = substr(s, 3, strlen(s)-4)
    return(s)
}

// process command log file (cmdlog option)
void texdoc_stripcmdlog(real scalar fh)
{
    real scalar      i, r, a, wd, lbstrip, matastrip, inmata, verb
    real colvector   p
    string scalar    fn, s, indent
    string rowvector f

    fn = st_local("filename")
    lbstrip = (st_local("lbstrip")!="")
    matastrip = (st_local("matastrip")!="")
    verb = (st_local("verbatim")!="")
    f = _texdoc_cat(fn, fh)
    r = rows(f)
    if (r<1) return
    p = J(r,1,1)
    inmata = 0
    for (i=1; i<=r; i++) {
        a = i
        s = _texdoc_stripcmdlog_read_cmd(f, i, r, inmata, lbstrip, verb)
        if (inmata) {
            if (strtrim(s)=="end") {
                inmata = 0
                if (matastrip) {
                    p[|a \ i|] = J(i-a+1, 1, 0) // remove mata ending
                    matastrip = 0
                    continue
                }
            }
        }
        else if (anyof(("mata","mata:","mata :"), stritrim(strtrim(s)))) {
            inmata = 1
            if (a==1 & matastrip) {
                p[|a \ i|] = J(i-a+1, 1, 0) // remove mata opening
                continue
            }
            matastrip = 0
        }
        if (strrtrim(substr(strltrim(s), 1, 7))=="texdoc") {  // texdoc ...
            wd = strlen(s)
            s = strltrim(s)
            indent = (wd - strlen(s)) * " "
            s = tokens(substr(s, 8, .), ", ")
            if (texdoc_cmdmatch(s, ("stlog", "oom"), (1, 1))) {
                (void) texdoc_cut(f, p, a, i, "oom", 1, indent, 0)
                // (i not changed; do not reread stripped cmd)
            }
            else if (texdoc_cmdmatch(s, ("stlog", "quietly"), (1, 1))) {
                (void) texdoc_cut(f, p, a, i, "quietly", 1, indent, 0)
            }
            else if (verb==0 & texdoc_cmdmatch(s, ("stlog", "cnp"), (1, 3))) {
                f[i] = "\cnp"
                if (i>a) p[|a \ i-1|] = J(i-a, 1, 0)
            }
            else {
                p[|a \ i|] = J(i-a+1, 1, 0)
            }
        }
    }
    f = select(f, p)
    _texdoc_striplog_alert(f, st_local("alert"))
    _texdoc_striplog_tag(f, st_local("tag"))
    texdoc_fput(fn, fh, f, "w", 1)
}

// read command line and optionally strip line break comments
string scalar _texdoc_stripcmdlog_read_cmd(string colvector f,
    real scalar i, real scalar r, real scalar inmata, real scalar lbstrip, 
    real scalar verb) 
{
    real scalar   lb, cb
    string scalar s, stmp
    
    lb = cb = 0
    if (verb) stmp = subinstr(f[i], char(9), " ")
    else      stmp = f[i]
    s = texdoc_strip_comments(stmp, lb, cb, inmata)
    while (lb | cb) {
        if (lbstrip) {
            if (lb) {
                lb = texdoc_locate_lb(stmp, cb)
                if (lb<.) f[i] = substr(f[i], 1, lb)
            }
        }
        if (i==r) break
        i++
        if (verb) stmp = subinstr(f[i], char(9), " ")
        else      stmp = f[i]
        s = s + texdoc_strip_comments(stmp, lb, cb, 1)
    }
    return(s)
}

// read snippet and write to filename; restore snippet collection
// if it has been destroyed
void texdoc_stripcmdlog_getsnippet(real scalar fh)
{
    real scalar      n
    pointer scalar   p
    
    p = findexternal("TeXdoc_do_snippets")
    if (p==NULL) {
        p = crexternal("TeXdoc_do_snippets")
        fh = fopen(st_global("TeXdoc_do_snippets"), "r")
        *p = fgetmatrix(fh)
        fclose(fh)
    }
    n = strtoreal(st_local("_cmdlog"))
    texdoc_fput(st_local("filename"), fh, *(*p)[n], "w", 1)
}

/*---------------------------------------------------------------------------*/
/* texdoc strip                                                              */
/*---------------------------------------------------------------------------*/

// remove texdoc elements from file
void texdoc_strip(real scalar fh)
{
    real scalar      i, r, texmode, tl, stlog, lb, cb, a
    real colvector   p
    string scalar    in, out, tex1, tex2, texstart, texstop, texdocexit, indent
    string rowvector s
    string colvector f
    pragma unset     tl
    pragma unset     texstart
    pragma unset     texstop

    in = st_local("in"); out = st_local("out")
    texdocexit = "// texdoc exit"
    tex1 = "/*tex"
    tex2 = "/***"
    texmode = stlog = lb = cb = 0
    f = _texdoc_cat(in, fh)
    r = rows(f)
    if (r<1) return
    p = J(r,1,1)
    for (i=1; i<=r; i++) {
        if (lb==0 & cb==0) {                        // new command line
            s = subinstr(f[i], char(9), " ")        // expand tabs
            if (texmode) {                          // process tex block
                p[i] = 0
                s = strtrim(s)
                if (texmode<.) {
                    if (strrtrim(substr(s,1,tl))==texstart) texmode++
                }
                else texmode = 1
                if ((strlen(s)>=tl ? strltrim(substr(s,-tl,.)) : s)==texstop) {
                    if (_texdoc_line_has_texcomments(s)==0) texmode--
                } 
                continue
            }
            if (stlog==0) {                         // start of tex block
                if (strrtrim(substr(strltrim(s),1,6))==tex1) {
                    texstart = "/*tex"
                    texstop  = "tex*/"
                    tl = 6
                    p[i] = 0
                    texmode = .
                    i-- // closing tag may be on same line
                    continue
                }
                if (strrtrim(substr(strltrim(s),1,5))==tex2) {
                    texstart = "/***"
                    texstop  = "***/"
                    tl = 5
                    p[i] = 0
                    texmode = .
                    i-- // closing tag may be on same line
                    continue
                }
            }
            if (strtrim(stritrim(s))==texdocexit) { // end of input
                p[|i \ .|] = J(r-i+1, 1, 0)
                break
            }
            a = i
            s = texdoc_strip_comments(s, lb, cb, 0)
        }
        else {                                      // continued command line
            s = s + texdoc_strip_comments(subinstr(f[i], char(9), " "), 
                    lb, cb, 0)
        }
        if (lb | cb) continue                       // command not complete yet
        indent = (strlen(s) - strlen(strltrim(s))) * " "
        s = strtrim(stritrim(s))
        if (strrtrim(substr(s, 1, 4))=="tex") {     // tex ...
            p[|a \ i|] = J(i-a+1, 1, 0)
            continue
        }
        if (strrtrim(substr(s, 1, 7))=="texdoc") {  // texdoc ...
            s = tokens(substr(s, 8, .), ",: ")
            if (texdoc_cmdmatch(s, "stlog", 1)) {  // texdoc stlog ...
                if (texdoc_cmdmatch(s, ("stlog", "close"), (1, 1))) {
                    stlog = 0
                    p[|a \ i|] = J(i-a+1, 1, 0)
                }
                else if (texdoc_cmdmatch(s, ("stlog", "oom"), (1, 1))) {
                    (void) texdoc_cut(f, p, a, i, "oom", 1, indent, 0)
                }
                else if (texdoc_cmdmatch(s, ("stlog", "quietly"), (1, 1))) {
                    (void) texdoc_cut(f, p, a, i, "quietly", 1, indent, 0)
                }
                else if (texdoc_cmdmatch(s, ("stlog", "cnp"), (1, 3))) {
                    p[|a \ i|] = J(i-a+1, 1, 0)
                }
                else {
                    if (anyof(s, ":")) {            // texdoc stlog ... : ...
                        (void) texdoc_cut(f, p, a, i, ":", 1, indent, 0)
                        continue
                    }
                    if (_texdoc_strip_using(s)) {   // texdoc stlog using
                        _texdoc_strip_cutopts(f, p, texdoc_cut(f, p, a, i, 
                            "using", 5, indent+"do ", 0), i)
                        continue
                    }
                    stlog = 1
                    p[|a \ i|] = J(i-a+1, 1, 0)
                }
            }
            else if (texdoc_cmdmatch(s, "local", 3)) {
                (void) texdoc_cut(f, p, a, i, "texdoc", 6, indent, 0)
            }
            else if (texdoc_cmdmatch(s, "do", 2)) {
                _texdoc_strip_cutopts(f, p, texdoc_cut(f, p, a, i, 
                    "texdoc", 6, indent, 0), i)
            }
            else p[|a \ i|] = J(i-a+1, 1, 0)
        }
    }
    texdoc_fput(out, fh, select(f, p), (st_local("append")!="" ? "a" : "w"), 
        st_local("replace")!="")
}

real scalar _texdoc_strip_using(string rowvector s) 
{
    real scalar l
    
    l = length(s)
    if (l<2) return(0)
    if (s[2]=="using") return(1)
    if (l<3) return(0)
    if (s[3]=="using") return(1)
    return(0)
}

void _texdoc_strip_cutopts(string colvector f, real colvector p, real scalar a,
    real scalar b)
{
    real scalar i, j, cb, par

    cb = par = 0
    for (j=a; j<=b; j++) {
        i = texdoc_locate_comma(subinstr(f[j], char(9), " "), cb, par)
        if (i<.) {
            f[j] = substr(f[j], 1, i)
            if (j<b) {
                p[|j+1 \ b|] = J(b-j, 1, 0)
            }
        }
    }
}

/*---------------------------------------------------------------------------*/
/* texdoc do                                                                 */
/*---------------------------------------------------------------------------*/

// create name for latex document from name of dofile
void texdoc_do_init2()
{
    string scalar fn
    
    fn = st_local("dofile")
    if (st_local("cd")!="") fn = pathbasename(fn)
    fn = pathrmsuffix(fn)
    st_local("init2", fn + ".tex")
}

// add default suffix to filename if it has no suffix
void texdoc_add_suffix(string scalar macname, string scalar suffix)
{
    string scalar fn
    
    fn = st_local(macname)
    if (pathsuffix(fn)=="") fn = fn + suffix
    st_local(macname, fn)
}

// add absolute path if path is relative
void texdoc_add_abspath(string scalar macname)
{
    string scalar fn
    
    fn = st_local(macname)
    if (pathisabs(fn)==0) fn = pathjoin(pwd(), fn)
    st_local(macname, fn)
}

// return path from filename in local path
void texdoc_get_path(string scalar fn)
{
    string scalar path, basename
    pragma unset path
    pragma unset basename
    
    pathsplit(fn, path, basename)
    st_local("path", path)
}

// main function to parse the dofile
void texdoc_do(real scalar fh)
{
    real colvector   t, init
    string colvector f
    pointer vector   S
    
    // read file and initialize dictionary
    f = _texdoc_cat(st_local("dofile"), fh)
    t = J(rows(f), 1, 0)
    /*  codes in t:
        0 nothing to do                              tex sections:
        1 texdoc init docname                        -1 /*** .... ***/
        2 texdoc init (without docname)              -2 /*** ...
        3 texdoc close                               -3 ... ***/
        4 texdoc stlog using / texdoc stlog :        -4 /*tex ... tex*/
        5 texdoc stlog (without using or colon)      -5 /*tex ...
        6 texdoc stlog oom/quietly                   -6 ... tex*/
        7 texdoc stlog cnp
        8 texdoc stlog close
       10 texdoc graph
       11 texdoc local
       99 other texdoc command
        . extra lines of command
    */
    init = 0
    // analyze dofile
    texdoc_do_analyze(f, t, init)
    // add init command if necessary
    if (init==0 & st_local("doinit")!="") {
        f = "texdoc init " + "`" + `"""' + st_local("init2") + `"""' + "'" \ f
        t = 1 \ t
    }
    // initialize pointer vector to collect snippets
    S = &1, J(1,100,NULL)
    // strip tex sections
    texdoc_do_tex(f, t, S)
    // insert extra stlog commands if needed (logall option)
    texdoc_do_logall(f, t)
    // parse stlog sections
    texdoc_do_stlog(f, t, S)
    // post snippets to external global
    _texdoc_post_snippets(fh, S)
    // return processed do-file
    texdoc_fput(st_local("dobuf"), fh, f, "w", 0)
}

// add snippet to collection of latex snippets and return counter
real scalar _texdoc_add_snippet(pointer vector S, string colvector s)
{
    real scalar n

    n = *S[1]
    n++
    if (n>length(S)) S = S, J(1, 100, NULL)
    S[n]  = &.   // create address
    *S[n] = s    // copy snippet
    *S[1] = n    // update counter
    return(n)
}

// post snippet collection as external global and backup in tempfile
void _texdoc_post_snippets(real scalar fh, pointer vector S)
{
    string scalar    fn
    pointer scalar   p

    if ((p = findexternal("TeXdoc_do_snippets"))==NULL) {
        p = crexternal("TeXdoc_do_snippets")
    }
    *p = S
    fn = st_tempfilename()
    st_global("TeXdoc_do_snippets", fn)
    fh = fopen(fn, "w")
    fputmatrix(fh, S)
    fclose(fh)
}

// analyze dofile
void texdoc_do_analyze(string colvector f, real colvector t, real scalar init)
{
    real scalar      i, i0, r, k, ti, stlog
    real rowvector   tl
    string scalar    s, texdocexit
    string rowvector start, stop
    
    texdocexit = "// texdoc exit"   // end of texdoc do-file
    start = ("/***", "/*tex")       // tex section start tags
    tl    = (5, 6)                  // tag lengths
    stop  = ("***/", "tex*/")       // tex section stop tags
    ti    = .                       // index of active tag
    k     = 0                       // tex section nesting level
    stlog = 0                       // stlog section
    r = rows(f)
    for (i=1; i<=r; i++) {
        i0 = i
        s = strtrim(subinstr(f[i], char(9), " ")) // expand tabs
        // look for end of tex section
        if (k) {
            if (strrtrim(substr(s,1,tl[ti]))==start[ti]) k++
            if ((strlen(s)>=tl[ti] ? strltrim(substr(s,-tl[ti],.)) : s)==stop[ti]) {
                if (_texdoc_line_has_texcomments(s)==0) k--
            }
            if (k==0) {
                t[i] = -(ti*3)
                continue
            }
            if (stritrim(s)==texdocexit) { // end of input
                f = f[|1 \ i-1|]; t = t[|1 \ i-1|]
                return
            }
            continue
        }
        // look for start of tex section (unless within stlog section)
        if (stlog==0) {
            if (strrtrim(substr(s,1,tl[1]))==start[1]) {
                ti = 1; k = 1
            }
            else if (strrtrim(substr(s,1,tl[2]))==start[2]) {
                ti = 2; k = 1
            }
            if (k) {
                t[i] = -((ti-1)*3 + 1)
                if (strltrim(substr(s,-tl[ti],.))==stop[ti]) {
                    if (_texdoc_line_has_texcomments(s)==0) k = 0
                }
                if (k) t[i] = t[i] - 1
                continue
            }
        }
        // end of input
        if (stritrim(s)==texdocexit) {
            if (i>1) {
                f = f[|1 \ i-1|]; t = t[|1 \ i-1|]
            }
            else {
                f = J(0,1,""); t = J(0,1,.)
            }
            return
        }
        // look for texdoc commands
        s = strltrim(texdoc_read_cmd(f, i, r, 0))
        if (strrtrim(substr(s, 1, 7))=="texdoc") {
            s = tokens(substr(s, 8, .), ",: ")
            // texdoc init
            if (texdoc_cmdmatch(s, "init", 1)) {
                if (_texdoc_init_docname(s)==0) t[i0] = 2 // without docname
                else {                                    // with docname
                    init = 1; t[i0] = 1
                }
            }
            // texdoc close
            else if (texdoc_cmdmatch(s, "close", 1)) t[i0] = 3
            // texdoc stlog close
            else if (texdoc_cmdmatch(s, ("stlog", "close"), (1, 1))) {
                stlog = 0
                t[i0] = 8
            }
            // texdoc stlog oom
            else if (texdoc_cmdmatch(s, ("stlog", "oom"), (1, 1))) t[i0] = 6
            // texdoc stlog quietly
            else if (texdoc_cmdmatch(s, ("stlog", "quietly"), (1, 1))) t[i0] = 6
            // texdoc stlog cnp
            else if (texdoc_cmdmatch(s, ("stlog", "cnp"), (1, 3))) t[i0] = 7
            // texdoc stlog
            else if (texdoc_cmdmatch(s, "stlog", 1)) {
                if (_texdoc_stlog_using(s)) t[i0] = 4
                else if (anyof(s, ":"))     t[i0] = 4
                else {
                    t[i0] = 5
                    stlog = 1
                }
            }
            // texdoc graph
            else if (texdoc_cmdmatch(s, "graph", 2)) t[i0] = 10
            // texdoc local
            else if (texdoc_cmdmatch(s, "local", 3)) t[i0] = 11
            // other texdoc command
            else t[i0] = 99
            // handle extra lines of command
            if (i>i0) t[|i0+1 \ i|] = J(i-i0, 1, .)
        }
    }
}

// check whether a line has latex comments
real scalar _texdoc_line_has_texcomments(string scalar s)
{
    real scalar p, p1
    
    p = strpos(s,"%")
    if (p==0) return(0)
    while (1) {
        if (substr(s, p-1, 1)!="\") return(1)
        p1 = strpos(substr(s, p+1, .), "%")
        if (p1==0) return(0)
        p = p + p1
    }
}

// check whether docname specified with texdoc init
real scalar _texdoc_init_docname(string rowvector s)
{
    if (length(s)<2) return(0) // no arguments
    if (s[2]!=",")   return(1) // docname specified
    return(0)                  // only options specified
}

// check whether command has -using-
real scalar _texdoc_stlog_using(string rowvector s)
{
    real scalar j
    
    for (j=2; j<=length(s); j++) {
        if (s[j]=="using") return(1)
        if (s[j]==",") return(0)
    }
    return(0)
}

// handle tex sections
void texdoc_do_tex(string colvector f, real colvector t, pointer vector S)
{
    real scalar      i, i0, a, b, ti, init, r, stlog
    real rowvector   tl
    real colvector   p
    string rowvector start, stop
    
    start = ("/***", "/*tex")       // tex section start tags
    tl    = (5, 6)                  // tag lengths
    stop  = ("***/", "tex*/")       // tex section stop tags
    ti    = .                       // index of active tag
    r     = rows(f)
    p     = J(r, 1, 1)
    init  = (st_global("TeXdoc_docname")!="") // (nested texdoc do)
    stlog = 0
    for (i=1; i<=r; i++) {
        // update stlog status
        if (stlog) {
            if (t[i]==8) stlog = 0
            continue
        }
        if (init) {
            if (t[i]==5) {
                stlog = 1
                continue
            }
        }
        // update init status
        if (t[i]==1) {
            init = 1; continue
        }
        if (t[i]==3) {
            init = 0; continue
        }
        if (init==0) continue
        if (t[i]>=0) continue
        // strip tex section
        i0 = i
        if (t[i]==-1) ti = 1
        else if (t[i]==-2) {
            ti = 1
            for (;i<=r; i++) {
                if (t[i]==-3) break
            }
        }
        else if (t[i]==-4) ti = 2
        else if (t[i]==-5) {
            ti = 2
            for (;i<=r; i++) {
                if (t[i]==-6) break
            }
        }
        // remove start tag
        f[i0] = substr(f[i0], strpos(f[i0], start[ti]) + tl[ti], .)
        // remove stop tag (unless file ends prematurely)
        if (i<=r) f[i] = substr(f[i], 1, _texdoc_strrpos(f[i], stop[ti]) - 2)
        // omit first and last line if empty
        a = i0; b = i
        if (a<b & i<=r) {
            if (strtrim(f[i])=="") b--
        }
        if (a<b) {
            if (strtrim(f[i0])=="") a++
        }
        // update index if file ends prematurely
        if (i>r) {
            b--; i--
        }
        // store tex snippet and insert texdoc append command
        f[i] = "texdoc append_snippet " + strofreal(_texdoc_add_snippet(S, f[|a \ b|]))
        t[i] = 99 // mark texdoc command
        // disable unneeded lines
        if (i>i0) p[|i0 \ i-1|] = J(i-i0, 1, 0)
    }
    // update file
    f = select(f, p)
    t = select(t, p)
}

// find rightmost position of s in s0; needed because strrpos() not available
// prior to Stata 14
real scalar _texdoc_strrpos(string scalar s0, string scalar s)
{
    real scalar p, p1, l

    p1 = strpos(s0, s)
    if (p1==0) return(0)
    l = strlen(s)
    if (l==0) return(1)
    p = p1 + l
    while (1) {
        p1 = strpos(substr(s0, p, .), s)
        if (p1==0) return(p-l)
        p = p + (p1-1) + l
    }
}

// insert extra stlog commands if needed (logall option)
void texdoc_do_logall(string colvector f, real colvector t)
{
    real scalar      i, i0, r, a, b, init, stlog, logall, add
    real colvector   p
    
    r = rows(f)
    p = J(r, 1, 0)
    stlog = add = 0
    init   = (st_global("TeXdoc_docname")!="") // (nested texdoc do)
    logall = (init ? st_global("TeXdoc_logall")!="" : 0)
    a = (logall ? 1 : .)
    for (i=1; i<=r; i++) {
        // update init status
        if (stlog==0) {
            if (t[i]==1) init = 1    // texdoc init
        }
        if (init==0)  continue       // not initialized
        if (t[i]<=0)  continue       // no texdoc command
        if (t[i]>=.)  continue       // no texdoc command
        if (t[i]==6)  continue       // texdoc stlog oom/quietly
        if (t[i]==7)  continue       // texdoc stlog cnp
        if (t[i]==11) continue       // texdoc local
        // skip to last line of command
        i0 = i
        while (i<r) {
            if (t[i+1]<.) break
            i++
        }
        // existing stlog section
        if (stlog) {
            if (t[i0]==8) { // texdoc stlog close 
                stlog = 0
                if (logall) a = i + 1
            }
            continue
        }
        if (t[i0]==5) stlog = 1
        // mark lines where texdoc stlog commands have to be inserted
        // (skipping sections that only contain white space)
        if (a<i0) {
            b = i0
            while (a<b) {
                if ((strtrim(subinstr(f[a], char(9), " ")))=="") {
                    a++
                }
                else break
            }
            while (a<b) {
                if ((strtrim(subinstr(f[b-1], char(9), " ")))=="") {
                    b--
                }
                else break
            }
            if (a<b) {
                add = add + 2
                p[a] = 1  // insert texdoc stlog
                p[b] = 2  // insert texdoc stlog close
            }
        }
        // texdoc close
        if (t[i]==3) {
            init = 0; a = .
            continue
        }
        // update logall status
        if (t[i0]==1 | t[i0]==2) { // texdoc init (with or without docname)
            i = i0
            _texdoc_init_logall(texdoc_tokens(texdoc_read_cmd(f, i, r, 0)), logall)
            if (logall==0) a = .
        }
        if (logall) a = i + 1
    }
    // handle end of file
    if (a<=r) {
        b = r + 1
        while (a<b) {
            if ((strtrim(subinstr(f[a], char(9), " ")))=="") {
                a++
            }
            else break
        }
        while (a<b) {
            if ((strtrim(subinstr(f[b-1], char(9), " ")))=="") {
                b--
            }
            else break
        }
        if (a<b) {
            add++
            p[a] = 1
            if (b<=r) {
                add++
                p[b] = 2
            }
            else {
                f = f \ "texdoc stlog close"
                p = p \ 0
                t = t \ 8
            }
        }
    }
    // add extra extra stlog commands
    if (add==0) return
    _texdoc_do_logall(f, t, p, add)
}
void _texdoc_do_logall(string colvector f, real colvector t, 
    real colvector p, real scalar add)
{
    real scalar      i, j, r
    real colvector   t0
    string colvector f0
    
    r = rows(f)
    f0 = J(r+add, 1, "")
    t0 = J(r+add, 1, 0)
    swap(f0, f); swap(t0, t)
    j = 0
    for (i=1; i<=r; i++) {
        j++
        if (p[i]==1) {
            f[j] = "texdoc stlog"
            t[j] = 5
            j++
        }
        else if (p[i]==2) {
            f[j] = "texdoc stlog close"
            t[j] = 8
            j++
        }
        f[j] = f0[i]
        t[j] = t0[i]
    }
}

// check whether logall option was specified
void _texdoc_init_logall(string rowvector s, real scalar logall)
{
    if (length(s)<3) return // no arguments
    if (s[3]!=",") {        // docname specified
        logall = (st_global("TeXdoc_do_logall")!="")
    }
    if (logall) {
        if (_texdoc_hasopt(s, "nologall")) logall = 0
    }
    else {
        if (_texdoc_hasopt(s, "logall")) logall = 1
    }
}

// check whether option 'opt' was specified
real scalar _texdoc_hasopt(string rowvector s, string scalar opt,
    | real scalar abbrev)
{
    real scalar i, l

    l = length(s)
    for (i=3; i<=l; i++) {
        if (s[i]==",") {
            i++; break
        }
    }
    if (i>l) return(0)
    if (args()==2) return(anyof(s[|i \ l|], opt))
    for (; i<=l; i++) {
        if (s[i]==substr(opt, 1, max((abbrev, strlen(s[i]))))) return(1)
    }
    return(0)
}

// handle stlog sections
void texdoc_do_stlog(string colvector f, real colvector t, pointer vector S)
{
    real scalar      r, i, i0, init, indent, add,
                     cmdl0, nolog0, nodo0, nolt0, noout0,
                     cmdl, n, nodo, nolt, noout
    real colvector   p
    string scalar    s
    pragma unset     indent
    pragma unset     cmdl
    pragma unset     nodo
    pragma unset     nolt
    pragma unset     noout

    // read settings in case already initialized (nested texdoc do)
    init    = st_global("TeXdoc_docname")!=""
    cmdl0   = (init ? st_global("TeXdoc_cmdlog")!=""   : 0)
    nolog0  = (init ? st_global("TeXdoc_nolog")!=""    : 0)
    nodo0   = (init ? st_global("TeXdoc_nodo")!=""     : 0)
    nolt0   = (init ? st_global("TeXdoc_noltrim")!=""  : 0)
    noout0  = (init ? st_global("TeXdoc_nooutput")!="" : 0)
    add = 0
    r = rows(f)
    p = J(r, 1, 1)
    for (i=1; i<=r; i++) {
        // update init status
        if (t[i]==1)      init = 1  // texdoc init
        else if (t[i]==3) init = 0  // texdoc close
        if (init==0) continue       // not initialized
        if (!anyof((1,2,5), t[i])) continue // irrelevant line
        // read command line
        i0 = i
        s = texdoc_tokens(texdoc_read_cmd(f, i, r, 0))
        // texdoc init (t=1 or t=2): update default settings
        if (anyof((1,2), t[i0])) {
            _texdoc_init_stopts(s, cmdl0, nolog0, nodo0, nolt0, noout0)
            continue
        }
        // texdoc stlog (t=5): read options
        _texdoc_stlog_stopts(s, cmdl0, nodo0, nolt0, noout0, 
                                cmdl, nodo, nolt, noout)
        // mark line for -set output inform-
        if (noout & cmdl==0) {
            p[i0] = 2; add++
        }
        // skip to end of stlog section; disable commands if nodo
        i++
        i0 = i
        for (; i<=r; i++) {
            if (t[i]==8) break
            if (nodo) {
                if (t[i]==10 | t[i]==11) { // texdoc graph or texdoc local
                    for (; i<r; i++) {
                        if (t[i+1]<.) break
                    }
                }
                else p[i] = 0
            }
        }
        // left trim commands
        if (nolt==0) {
            if (i>i0) {
                f[|i0 \ i-1|] = _texdoc_do_ltrim(f[|i0 \ i-1|], indent)
            }
            else indent = 0
        }
        else indent = 0
        // save stlog lines to tempfile
        if (cmdl) {
            if (i0==i) n = _texdoc_add_snippet(S, J(0, 1, ""))
            else       n = _texdoc_add_snippet(S, f[|i0 \ i-1|])
        }
        // skip to last line of texdoc stlog close command
        i0 = i
        while (i<r) {
            if (t[i+1]<.) break
            i++
        }
        // exit if file ends prematurely
        if (i>r) break
        // update texdoc stlog close (unless file ends prematurely)
        if (indent | cmdl) {
            f[i0] = "texdoc stlog close,"
            if (i>i0) { // remove extra lines
                p[|i0+1 \ i|] = J(i-i0, 1, 0)
            }
            if (cmdl) {
                f[i0] = f[i0] + " _cmdlog(" + strofreal(n) + ")"
            }
            if (indent) {
                f[i0] = f[i0] + " _indent(" + strofreal(indent) + ")"
            }
        }
        // mark line for -set output proc-
        if (noout & cmdl==0) {
            p[i] = 3; add++
        }
    }
    // insert -set output- lines
    if (add) {
        _texdoc_do_stlog(f, p, add)
    }
    // return result
    f = select(f, p)
}
void _texdoc_do_stlog(string colvector f, real colvector p, real scalar add)
{
    real scalar      i, j, r
    real colvector   p0
    string colvector f0
    
    r = rows(f)
    f0 = J(r+add, 1, "")
    p0 = J(r+add, 1, 0)
    swap(f0, f); swap(p0, p)
    j = 0
    for (i=1; i<=r; i++) {
        j++
        if (p0[i]==2) {
            f[j] = "set output inform"
            p[j] = 1 
            j++
        }
        f[j] = f0[i]
        p[j] = p0[i]
        if (p0[i]==3) {
            j++
            f[j] = "set output proc"
            p[j] = 1
        }
    }
}

// left-trim stlog section and return size if indentation
string colvector _texdoc_do_ltrim(string colvector s, real scalar indent)
{
    real colvector l
    
    l = strlen(strltrim(subinstr(s, char(9), " ")))
    indent = min(select(strlen(s) :- l, l))
    if (indent>=.) indent = 0 // happens if all lines only contain white space
    if (indent<1) return(s)
    return(substr(s, indent+1, .))
}

// update stlog defaults from texdoc init
void _texdoc_init_stopts(string rowvector s, real scalar cmdl,
    real scalar nolog, real scalar nodo, real scalar nolt, real scalar noout)
{
    if (length(s)<3) return // no arguments
    if (s[3]!=",") {        // docname specified
        cmdl   = (st_global("TeXdoc_do_cmdlog")!="")
        nolog  = (st_global("TeXdoc_do_nolog")!="")
        nodo   = (st_global("TeXdoc_do_nodo")!="")
        nolt   = (st_global("TeXdoc_do_noltrim")!="")
        noout  = (st_global("TeXdoc_do_nooutput")!="")
    }
    if (noout) noout = (_texdoc_hasopt(s, "output", 1)==0)
    else       noout = _texdoc_hasopt(s, "nooutput", 3)
    if (nolt)  nolt  = (_texdoc_hasopt(s, "ltrim")==0)
    else       nolt  = _texdoc_hasopt(s, "noltrim")
    if (nodo)  nodo  = (_texdoc_hasopt(s, "do")==0)
    else       nodo  = _texdoc_hasopt(s, "nodo")
    if (nolog) nolog = ((_texdoc_hasopt(s, "log")==0) &
                        (_texdoc_hasopt(s, "cmdlog", 4)==0))
    else       nolog = _texdoc_hasopt(s, "nolog")
    if (cmdl)  cmdl  = ((_texdoc_hasopt(s, "nocmdlog", 6)==0) &
                        (_texdoc_hasopt(s, "nolog")==0))
    else       cmdl  = _texdoc_hasopt(s, "cmdlog", 4)
}

// read local stlog settings
void _texdoc_stlog_stopts(string rowvector s, real scalar cmdl0,
    real scalar nodo0, real scalar nolt0, real scalar noout0, 
    real scalar cmdl, real scalar nodo, real scalar nolt, real scalar noout)
{
    if (length(s)<=3) { // no arguments
        cmdl = cmdl0; nodo = nodo0; nolt = nolt0; noout = noout0
    }
    if (noout0) noout = (_texdoc_hasopt(s, "output", 1)==0)
    else        noout = _texdoc_hasopt(s, "nooutput", 3)
    if (nolt0)  nolt  = (_texdoc_hasopt(s, "ltrim")==0)
    else        nolt  = _texdoc_hasopt(s, "noltrim")
    if (nodo0)  nodo  = (_texdoc_hasopt(s, "do")==0)
    else        nodo  = _texdoc_hasopt(s, "nodo")
    if (cmdl0)  cmdl  = ((_texdoc_hasopt(s, "nocmdlog", 6)==0) &
                        (_texdoc_hasopt(s, "nolog")==0))
    else        cmdl  = _texdoc_hasopt(s, "cmdlog", 4)
}

/*---------------------------------------------------------------------------*/
/* helper function for processing Stata command lines                        */
/*---------------------------------------------------------------------------*/

// tokenize with "," as parsing character and "(...)" bound together
string rowvector texdoc_tokens(string scalar s)
{
    transmorphic t
    
    t = tokeninit(" ", ",", (`""""', `"`""'"', "()"), 0, 0)
    tokenset(t, s)
    return(tokengetall(t))
}

// check whether the words in s match m, where l specifies the minimum 
// abbreviation
real scalar texdoc_cmdmatch(string rowvector s, string rowvector m,
    real rowvector l)
{   
    real scalar i, c

    c = length(s)
    for (i=1; i<=length(m); i++) {
        if (c<i) return(0)
        if (s[i]!=substr(m[i], 1, max((l[i], strlen(s[i]))))) return(0)
    }
    return(1)
}

// read a command line taking line breaks into account and remove comments
string scalar texdoc_read_cmd(
    string colvector f,
    real scalar i,
    real scalar r,
    real scalar inmata) 
{
    real scalar   lb, cb
    string scalar s
    
    lb = cb = 0
    s = texdoc_strip_comments(subinstr(f[i], char(9), " "), lb, cb, inmata)
    while (lb | cb) {
        if (i==r) break
        i++
        s = s + texdoc_strip_comments(subinstr(f[i], char(9), " "), 
                lb, cb, 1)
    }
    return(s)
}

// preprocessor for Stata command line: strips from s all comments ("* ...", 
// "/* ... */", "//...", "///...") taking account of quotes ("...", `"..."')
string scalar texdoc_strip_comments(
    string scalar s,    // command line to be parsed
    real scalar lb,     // will be set to 1 if line ends in " ///..."
    real scalar cb,     // will be set to nesting level of /*...*/
    real scalar nostar) // do not parse "*..."
{
    real scalar     i, wd, dq, cdq, a, b
    string scalar   c, snew, SL, ST, BL, DQ, BQ, EQ
    
    lb = dq = cdq = 0
    // A: handle comment-only lines
    if (!cb) {
      c = strltrim(s)
      // check whether line starts with "*..."
      if (!nostar) {
          if (substr(c,1,1)=="*") return(substr(s,1,strpos(s,"*")-1))
      }
      // check whether line starts with "//..." or "///..."
      if (substr(c,1,2)=="//") {
          if (substr(c,3,1)=="/") lb = 1
          return(substr(s,1,strpos(s,"//")-1))
      }
    }
    // B: handle other lines
    SL = "/"; ST = "*"; BL = " "; DQ = `"""'; BQ = "`"; EQ = "'"
    wd = strlen(s); a = 1; b = 0; snew = ""
    for (i=1; i<=wd; i++) {
        c = substr(s,i,1)
        // within /*...*/
        if (cb) {
            // look for end tag
            if (c==ST) {
                if (substr(s,i+1,1)==SL) {
                    i++; cb--
                    if (!cb) {
                        a = i + 1; b = i
                    }
                }
            }
            // look for nested start tag
            else if (c==SL) {
                if (substr(s,i+1,1)==ST) {
                    i++; cb++
                }
            }
            continue
        }
        // within `"..."'
        else if (cdq) {
            // look for end tag
            if (c==DQ) {
                if (substr(s,i+1,1)==EQ) {
                    if (substr(s,i-1,1)!=BQ) cdq--
                }
            }
            // look for nested start tag
            else if (c==BQ) {
                if (substr(s,i+1,1)==DQ) cdq++
            }
        }
        // within "..."
        else if (dq) {
            if (c==DQ) dq--
        }
        // look for comments
        else if (c==SL) {
            // look for /*...*/
            if (substr(s,i+1,1)==ST) {
                snew = snew + substr(s,a,b-a+1)
                i++; cb++; continue
            }
            // look for // or ///
            else if (substr(s,i-1, 1)==BL) {
                if (substr(s,i+1,1)==SL) {
                    if (substr(s,i+2,1)==SL) lb = 1 // => line break
                    break
                }
            }
        }
        // look for `"..."'
        else if (c==BQ) {
            if (substr(s,i+1,1)==DQ) cdq++
        }
        // look for "..."
        else if (c==DQ) dq++
        // character is not comment, so keep it
        b++
    }
    if (a==1 & b==wd) return(s)
    else if (cb) return(snew)
    else return(snew + substr(s,a,b-a+1))
}

// cut command after the specified token and delete first part; 
// returns the line number on which the edited command begins
real scalar texdoc_cut(
    string colvector f,      // colvector containing source
    real colvector   p,      // selection vector for lines of f
    real scalar      a,      // first line of command
    real scalar      b,      // last line of command
    string scalar    t,      // target token after which to cut command
    real scalar      l,      // minimum length of t (abbreviation)
    string scalar    prefix, // prefix (indentation)
    real scalar      log)    // input is log file
{
    string scalar s, tok
    real scalar   j, i, cb, par, hit

    cb = par = hit = 0; tok = ""
    for (j=a; j<=b; j++) {
        if (log) s = substr(f[j], 3, .)
        else     s = subinstr(f[j], char(9), " ")
        i = texdoc_locate_next(s, t, l, tok, cb, par, hit)
        if (i<.) {
            if (log) f[j] = ". " + prefix + substr(s, i, .)
            else     f[j] = prefix + substr(f[j], i, .)
            return(j)
        }
        p[j] = 0
    }
    if (hit==0) { // target token not found
        p[|a \ b|] = J(b-a+1, 1, 1)
    }
    return(j)
}

// find a target token (possibly abbreviated) and return the position of the
// next non-comment/non-blank character after the token;
// takes account of comments, quotes, and parentheses; tokens are delimited
// by blanks, commas, or colons; commas and colons are separate tokens;
// returns missing if the target character is not found
real scalar texdoc_locate_next(
    string scalar s,    // search string
    string scalar t,    // target token
    real scalar   l,    // minimum length of t (abbreviation)
    string scalar tok,  // container for current token
    real scalar   cb,   // inline-comment nesting level
    real scalar   par,  // parentheses nesting level
    real scalar   hit)  // set to one if token is found
{
    real scalar     i, wd, dq, cdq
    string scalar   c, SL, ST, BL, DQ, BQ, EQ, BP, EP, pchars, tchars
    
    dq = cdq = 0
    SL = "/"; ST = "*"; BL = " "; DQ = `"""'; BQ = "`"; EQ = "'"
    BP = "("; EP = ")"; pchars = (" ", ",", ":"); tchars = (",", ":")
    wd = strlen(s)
    for (i=1; i<=wd; i++) {
        c = substr(s,i,1)
        // within /*...*/
        if (cb) {
            // look for end tag
            if (c==ST) {
                if (substr(s,i+1,1)==SL) {
                    i++; cb--
                }
            }
            // look for nested start tag
            else if (c==SL) {
                if (substr(s,i+1,1)==ST) {
                    i++; cb++
                }
            }
            continue
        }
        // within `"..."'
        else if (cdq) {
            // look for end tag
            if (c==DQ) {
                if (substr(s,i+1,1)==EQ) {
                    if (substr(s,i-1,1)!=BQ) cdq--
                }
            }
            // look for nested start tag
            else if (c==BQ) {
                if (substr(s,i+1,1)==DQ) cdq++
            }
        }
        // within "..."
        else if (dq) {
            if (c==DQ) dq--
        }
        // look for comments
        else if (c==SL) {
            // look for /*...*/
            if (substr(s,i+1,1)==ST) {
                i++; cb++; continue
            }
            // look for // or ///
            else if (i==1 | substr(s,i-1, 1)==BL) {
                if (substr(s,i+1,1)==SL) break
            }
        }
        // look for `"..."'
        else if (c==BQ) {
            if (substr(s,i+1,1)==DQ) cdq++
        }
        // look for "..."
        else if (c==DQ) dq++
        // look for (...)
        else if (c==BP) par++
        else if (c==EP) par--
        // look for next character after the token
        if (hit) {
            if (c!=BL) return(i)
            continue
        }
        // update current token (within quotes/parentheses)
        if (par | cdq | dq) tok = tok + c
        // look for match/update current token (outside quotes/parentheses)
        else {
            // look for match
            if (anyof(pchars, c)) {
                if (tok!="") {
                    if (tok==substr(t, 1, max((l, strlen(tok))))) {
                        hit = 1
                        if (c!=BL) return(i)
                        continue
                    }
                    tok = ""
                }
                if (anyof(tchars, c)) {
                    tok = c
                    if (tok==t) {
                        hit = 1; continue
                    }
                    tok = ""
                }
            }
            // handle end of line
            else if (i==wd) {
                tok = tok + c
                if (tok==substr(t, 1, max((l, strlen(tok))))) {
                    hit = 1; continue
                }
            }
            // update token
            else tok = tok + c
        }
    }
    return(.) // token not found
}

// find line break comment; ignores inline comments and binds quotes; 
// returns the position of the last character before the line break comment; 
// returns missing if not found
real scalar texdoc_locate_lb(string scalar s, real scalar cb)
{
    real scalar     i, wd, dq, cdq
    string scalar   c, SL, ST, BL, DQ, BQ, EQ
    
    dq = cdq = 0
    SL = "/"; ST = "*"; BL = " "; DQ = `"""'; BQ = "`"; EQ = "'"
    wd = strlen(s)
    for (i=1; i<=wd; i++) {
        c = substr(s,i,1)
        // within /*...*/
        if (cb) {
            // look for end tag
            if (c==ST) {
                if (substr(s,i+1,1)==SL) {
                    i++; cb--
                }
            }
            // look for nested start tag
            else if (c==SL) {
                if (substr(s,i+1,1)==ST) {
                    i++; cb++
                }
            }
            continue
        }
        // within `"..."'
        else if (cdq) {
            // look for end tag
            if (c==DQ) {
                if (substr(s,i+1,1)==EQ) {
                    if (substr(s,i-1,1)!=BQ) cdq--
                }
            }
            // look for nested start tag
            else if (c==BQ) {
                if (substr(s,i+1,1)==DQ) cdq++
            }
        }
        // within "..."
        else if (dq) {
            if (c==DQ) dq--
        }
        // look for comments
        else if (c==SL) {
            // look for /*...*/
            if (substr(s,i+1,1)==ST) {
                i++; cb++; continue
            }
            // look for // or ///
            else if (i==1 | substr(s,i-1, 1)==BL) {
                if (substr(s,i+1,1)==SL) {
                    if (substr(s,i+2,1)==SL) return(max((0,i-2)))
                    break
                }
            }
        }
        // look for `"..."'
        else if (c==BQ) {
            if (substr(s,i+1,1)==DQ) cdq++
        }
        // look for "..."
        else if (c==DQ) dq++
    }
    return(.) // not found
}

// find unbound comma (i.e. not within comments, quotes, or parentheses);
// returns the position of the last character before the comma; 
// returns missing if not found
real scalar texdoc_locate_comma(string scalar s, real scalar cb, real scalar par)
{
    real scalar     i, wd, dq, cdq
    string scalar   c, SL, ST, BL, DQ, BQ, EQ, BP, EP, CO
    
    dq = cdq = 0
    SL = "/"; ST = "*"; BL = " "; DQ = `"""'; BQ = "`"; EQ = "'"
    BP = "("; EP = ")"; CO = ","
    wd = strlen(s)
    for (i=1; i<=wd; i++) {
        c = substr(s,i,1)
        // within /*...*/
        if (cb) {
            // look for end tag
            if (c==ST) {
                if (substr(s,i+1,1)==SL) {
                    i++; cb--
                }
            }
            // look for nested start tag
            else if (c==SL) {
                if (substr(s,i+1,1)==ST) {
                    i++; cb++
                }
            }
            continue
        }
        // within `"..."'
        else if (cdq) {
            // look for end tag
            if (c==DQ) {
                if (substr(s,i+1,1)==EQ) {
                    if (substr(s,i-1,1)!=BQ) cdq--
                }
            }
            // look for nested start tag
            else if (c==BQ) {
                if (substr(s,i+1,1)==DQ) cdq++
            }
        }
        // within "..."
        else if (dq) {
            if (c==DQ) dq--
        }
        // look for comments
        else if (c==SL) {
            // look for /*...*/
            if (substr(s,i+1,1)==ST) {
                i++; cb++; continue
            }
            // look for // or ///
            else if (i==1 | substr(s,i-1, 1)==BL) {
                if (substr(s,i+1,1)==SL) break
            }
        }
        // look for `"..."'
        else if (c==BQ) {
            if (substr(s,i+1,1)==DQ) cdq++
        }
        // look for "..."
        else if (c==DQ) dq++
        // look for (...)
        else if (c==BP) par++
        else if (c==EP) par--
        // look for comma
        else if (c==CO) {
            if (par==0) return(i-1)
        }
    }
    return(.) // not found
}

/*---------------------------------------------------------------------------*/
/* file I/O helper functions                                                 */
/*---------------------------------------------------------------------------*/

// create a Mata global to be used as file handle later on; based on 
// suggestion by W. Gould; allows closing open file handles on error or break
void texdoc_instance_fh(string scalar macname)
{
    real scalar   i
    string scalar fullname
    
    for (i=1; 1; i++) {
        fullname = sprintf("%s%g", "TeXdoc_fh_", i)
        if (crexternal(fullname) != NULL) {
            st_local(macname, fullname)
            return
        }
    }
}

// close file handle if existing
void texdoc_closeout_fh(real scalar fh)
{
    if (fh!=.) (void) _fclose(fh)
}

// create folder
void texdoc_mkdir(string scalar path)
{
    if (direxists(path)==0) {
        mkdir(path)
        printf("{txt}(directory '%s' created)\n", path)
    }
}

// read file; simplified cat() with file handle argument
string colvector _texdoc_cat(string scalar filename, real scalar fh)
{
        real scalar             i, n
        string matrix           EOF
        string colvector        res
        string scalar           line

        EOF = J(0, 0, "")
        fh  = fopen(filename, "r")
        // count lines
        i = 0
        while (1) {
            if (fget(fh)==EOF) break
            i++ 
        }
        res = J(n = i, 1, "")
        // read file
        fseek(fh, 0, -1)
        for (i=1; i<=n; i++) {
                if ((line=fget(fh))==EOF) {
                        /* unexpected EOF -- file must have changed */
                        fclose(fh)
                        if (--i) return(res[|1\i|])
                        return(J(0,1,""))
                }
                res[i] = line
        }
        fclose(fh)
        return(res)
}

// write multiple lines to file
void texdoc_fput(string scalar fn, real scalar fh, string colvector s, 
    string scalar mode, real scalar replace)
{   // replace: 1=replace, 2=certify
    if (replace) {
        if (replace==2) texdoc_fput_certify(fn, fh, s)
        texdoc_fopen_replace(fn, fh, mode)
    }
    else fh = fopen(fn, mode)
    _texdoc_fput(fh, s)
    fclose(fh)
}
void _texdoc_fput(real scalar fh, string colvector s)
{
    real scalar i
    
    for (i=1; i<=rows(s); i++) {
        fput(fh, s[i])
    }
}

// check whether preexisting file is identical to new file
void texdoc_fput_certify(string scalar fn, real scalar fh, string colvector s)
{
    if (s!=_texdoc_cat(fn, fh)) {
        texdoc_fput(fn+"_new", fh, s, "w", 1)
        printf("{err}certify: ")
        printf(`"file {browse "%s":%s} already exists and is different\n"', 
            fn, pathbasename(fn))
        printf(`"new version saved as {browse "%s":%s}\n"', 
            fn+"_new", pathbasename(fn)+"_new")
        exit(error(499))
    }
    else {
        display("{txt}(certify: equivalence confirmed)")
    }
}

// robust unlink()->fopen(); based on suggestion by W. Gould; the problem is
// that, on Windows, fopen() may fail if applied directly after unlink() 
// (usually caused by a virus scanner); the function below retries
// to open the file until a maximum delay of 100 milliseconds
void texdoc_fopen_replace(string scalar fn, real scalar fh, string scalar mode)
{
    real scalar cnt
    
    if (fileexists(fn)) {
        unlink(fn)
        for (cnt=1; (fh=_fopen(fn, mode))<0; cnt++) {
            if (cnt==10) {
                fh = fopen(fn, mode)
                break
            }
            stata("sleep 10")
        }
        return
    }
    fh = fopen(fn, mode)
}

end
