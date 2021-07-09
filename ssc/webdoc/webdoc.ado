*! version 1.2.8  11nov2019  Ben Jann

program webdoc
    version 10.1
    gettoken subcmd 0 : 0, parse(",: ")
    local length = length(`"`subcmd'"')
    if `"`subcmd'"'==substr("write", 1, max(`length', 1)) {
        if `"${WebDoc_docname}"'=="" {
            di as txt "(webdoc not initialized; nothing to do)"
            exit
        }
        _webdoc_write write`macval(0)'
        exit
    }
    if `"`subcmd'"'=="put" {
        if `"${WebDoc_docname}"'=="" {
            di as txt "(webdoc not initialized; nothing to do)"
            exit
        }
        _webdoc_put put`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("append", 1, max(`length', 1)) {
        webdoc_append`macval(0)'
        exit
    }
    if `"`subcmd'"'=="append_snippet" {
        webdoc_append_snippet`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("local", 1, max(`length', 3)) {
        if `"${WebDoc_docname}"'=="" { // webdoc not initialized
            c_local`macval(0)'
            exit
        }
        if `"${WebDoc_stfilename0}"'=="" {
            di as txt "(no stlog name available; skipping backup)"
            c_local`macval(0)'
            exit
        }
        gettoken mname 0 : 0, parse(" =:")
        if `"${WebDoc_stnodo}"'=="" {
            local meval`macval(0)'
            webdoc_local_put `mname' `"`macval(meval)'"'
        }
        else {
            capt webdoc_local_get `mname'
            if _rc di as txt "(backup of `mname' not found)"
        }
        c_local `mname' `"`macval(meval)'"'
        exit
    }
    if `"`subcmd'"'=="set" {
        if `"${WebDoc_dofile}"'=="" {
            di as txt "(webdoc do not running; nothing to do)"
            exit
        }
        webdoc_set`macval(0)'
        exit
    }
    if `"`subcmd'"'=="toc" {
        webdoc_toc`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("substitute", 1, max(`length', 3)) {
        webdoc_substitute`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("init", 1, max(`length', 1)) {
        webdoc_init`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("close", 1, max(`length', 1)) {
        if `"${WebDoc_ststatus}"'!="" {
            di as err "webdoc close not allowed within stlog section"
            di as err "type {stata webdoc stlog close} to close the stlog section"
            exit 499
        }
        webdoc_close`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("stlog", 1, max(`length', 1)) {
        local caller : di _caller()
        version `caller': webdoc_stlog`macval(0)'
        exit
    }
    if `"`subcmd'"'==substr("graph", 1, max(`length', 2)) {
        webdoc_graph`macval(0)'
        exit
    }
    if `"`subcmd'"'=="strip" {
        webdoc_strip`macval(0)'
        exit
    }
    if `"`subcmd'"'=="do" {
        if `"${WebDoc_ststatus}"'!="" {
            di as err "webdoc do not allowed within stlog section"
            di as err "type {stata webdoc stlog close} to close the stlog section"
            exit 499
        }
        local caller : di _caller()
        local do_globals snippets replace append md logdir logdir2 noprefix ///
            prefix prefix2 stpath stpath2 logall nodo nolog cmdlog dosave ///
            nokeep custom plain raw cmdstrip lbstrip gtstrip matastrip ///
            nooutput noltrim gropts grdir mark tag certify linesize ///
            dodir header header2
        local set_globals stlog _stlog stcmd _stcmd sthlp _sthlp ///
             stinp _stinp stres _stres stcmt _stcmt stoom stcnp ///
             figure _figure fcap flink _flink img _img svg _svg
        local init_globals nodo nolog cmdlog dosave nokeep custom plain raw ///
            cmdstrip lbstrip gtstrip matastrip nooutput noltrim gropts grdir ///
            mark tag certify linesize dodir stpath prefix prefix0 logdir path0 ///
            path logall footer md basename docname0 docname docname_FH substitute
        local st_globals nodo nolog cmdlog dosave nokeep custom plain raw ///
            cmdstrip lbstrip gtstrip matastrip nooutput noltrim indent ///
            grcounter filename filename0 webname webname0 id name0 name mark ///
            tag certify linesize linesize0 status loc
        local nested = `"${WebDoc_dofile}"'!=""
        if `nested' { // backup current settings
            local do_dofile `"${WebDoc_dofile}"'
            foreach g of local do_globals {
                mata: st_local("do_`g'", st_global("WebDoc_do_`g'"))
            }
            foreach g of local set_globals {
                mata: st_local("set_`g'", st_global("WebDoc_set_`g'"))
            }
            local init_stcounter `"${WebDoc_stcounter}"'
            foreach g of local init_globals {
                mata: st_local("init_`g'", st_global("WebDoc_`g'"))
            }
            foreach g of local st_globals {
                mata: st_local("st_`g'", st_global("WebDoc_st`g'"))
            }
        }
        _webdoc_do_parse`macval(0)' // returns cd
        if "`cd'"!="" {
            local pwd `"`c(pwd)'"'
        }
        nobreak {
            capt n break {
                version `caller': webdoc_do`macval(0)'
            }
            if _rc {
                local rc = _rc
                _webdoc_cleanup
                _webdoc_cleanup_do
                if "`cd'"!="" {
                    qui cd `pwd'
                    di as txt `"(cd `pwd')"'
                }
                exit `rc'
            }
            if `nested' {
                mata: rmexternal("WebDoc_do_snippets")
                if `"${WebDoc_docname}"'=="" {
                    // docname closed (or not yet initialized): skip webdoc 
                    // close and restore previous settings
                    global WebDoc_stcounter `"`init_stcounter'"'
                    foreach g of local st_globals {
                        global WebDoc_st`g' `"`macval(st_`g')'"'
                    }
                }
                else if `"`init_docname'"'==`"${WebDoc_docname}"' {
                    // still same docname: skip webdoc close, keep stcounter 
                    // and settings from last stlog, but restore stloc
                    global WebDoc_stloc `"`macval(st_loc)'"'
                }
                else if `"${WebDoc_docname}"'!="" {
                    // docname has been (re)initialized: apply webdoc close 
                    // and restore previous settings
                    webdoc_close
                    global WebDoc_stcounter `"`init_stcounter'"'
                    foreach g of local st_globals {
                        global WebDoc_st`g' `"`macval(st_`g')'"'
                    }
                }
                // reset init globals
                foreach g of local init_globals {
                    global WebDoc_`g' `"`macval(init_`g')'"'
                }
                // reset set globals
                foreach g of local set_globals {
                    global WebDoc_set_`g' `"`macval(set_`g')'"'
                }
                // reset webdoc do globals
                global WebDoc_dofile `"`do_dofile'"'
                foreach g of local do_globals {
                    global WebDoc_do_`g' `"`macval(do_`g')'"'
                }
            }
            else {
                if `"${WebDoc_docname}"'!="" {
                    webdoc_close
                }
                _webdoc_cleanup_do
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

program _webdoc_do_parse
    _parse comma fn 0 : 0
    syntax [, cd * ]
    c_local cd `cd'
end

program _webdoc_cleanup
    // clear webdoc stlog globals
    _webdoc_cleanup_stlog
    // close file handle
    capture mata: webdoc_closeout_fh(${WebDoc_docname_FH}) 
    // clear webdoc init globals
    foreach g in nodo nolog cmdlog dosave nokeep custom plain raw cmdstrip ///
        lbstrip gtstrip matastrip nooutput noltrim gropts grdir mark tag ///
        certify linesize dodir stcounter stpath prefix prefix0 logdir path0 ///
        path logall footer md basename docname0 docname docname_FH substitute {
        global WebDoc_`g' ""
    }
end

program _webdoc_cleanup_stlog
    // clear webdoc stlog globals
    foreach g in nodo nolog cmdlog dosave nokeep custom plain raw ///
        cmdstrip lbstrip gtstrip matastrip nooutput noltrim indent ///
        grcounter filename filename0 webname webname0 id name0 name mark ///
        tag certify linesize linesize0 status loc {
        global WebDoc_st`g' ""
    }
end

program _webdoc_cleanup_do
    // close log if still open
    capt log close WebDoc_stlog
    // clear webdoc set globals
    foreach s in stlog _stlog stcmd _stcmd sthlp _sthlp stinp _stinp ///
        stres _stres stcmt _stcmt stoom stcnp figure _figure fcap ///
        flink _flink img _img svg _svg {
        global WebDoc_set_`s' ""
    }
    // clear webdoc do globals
    foreach g in snippets replace append md logdir logdir2 noprefix prefix ///
        prefix2 stpath stpath2 logall nodo nolog cmdlog dosave nokeep custom ///
        plain raw cmdstrip lbstrip gtstrip matastrip nooutput noltrim ///
        gropts grdir mark tag certify linesize dodir header header2 {
        global WebDoc_do_`g' ""
    }
    global WebDoc_dofile ""
    mata: rmexternal("WebDoc_do_snippets")
end

program _webdoc_makelink
    args fn
    if c(os)=="Unix" {
        c_local openlink `"stata `"!xdg-open "`fn'" >& /dev/null &"'"'
    }
    // else if c(os)=="MacOSX" {
    //     c_local openlink `"stata `"!open "`fn'""'"'
    // }
    // else if c(os)=="Windows" {
    //     c_local openlink `"stata `"!start "`fn'""'"'
    // }
    else {
        c_local openlink `"browse `"`fn'"'"'
    }
end

program _webdoc_write
    mata: fwrite(${WebDoc_docname_FH}, substr(st_local("0"), 7, .))
end

program _webdoc_put
    mata: fput(${WebDoc_docname_FH}, substr(st_local("0"), 5, .))
end

program webdoc_append
    if `"${WebDoc_docname}"'=="" {
        di as txt "(webdoc not initialized; nothing to do)"
        exit
    }
    local 0 `"using `macval(0)'"'
    syntax using/ [, SUBstitute(str asis) drop(numlist >0 integer) ]
    nobreak {
        capt n break {
            mata: webdoc_instance_fh("fh")
            mata: webdoc_append(${WebDoc_docname_FH}, `fh'=.)
        }
        local rc = _rc
        capture mata: webdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
    di as txt `"(`using' appended)"'
end

program webdoc_append_snippet
    if `"${WebDoc_docname}"'=="" | `"${WebDoc_dofile}"'=="" {
        exit
    }
    nobreak {
        capt n break {
            mata: webdoc_instance_fh("fh")
            mata: webdoc_append_snippet(${WebDoc_docname_FH}, `fh'=.)
        }
        local rc = _rc
        capture mata: webdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
end

program webdoc_local_put
    args mname meval
    nobreak {
        capt n break {
            mata: webdoc_instance_fh("fh")
            mata: webdoc_local_put(`fh'=.)
        }
        local rc = _rc
        capture mata: webdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
end

program webdoc_local_get
    args mname
    nobreak {
        capt n break {
            mata: webdoc_instance_fh("fh")
            mata: webdoc_local_get(`fh'=.)
        }
        local rc = _rc
        capture mata: webdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
    c_local meval `"`macval(meval)'"'
end

program webdoc_set
    if `"`0'"'=="" { // set defaults
        global WebDoc_set_stlog   <pre id="\`id'" class="stlog"><samp>
        global WebDoc_set__stlog  </samp></pre>
        global WebDoc_set_stcmd   <pre id="\`id'" class="stcmd"><code>
        global WebDoc_set__stcmd  </code></pre>
        global WebDoc_set_sthlp   <pre id="\`id'" class="sthlp">
        global WebDoc_set__sthlp  </pre>
        global WebDoc_set_stinp   <span class="stinp">
        global WebDoc_set__stinp  </span>
        global WebDoc_set_stres   <span class="stres">
        global WebDoc_set__stres  </span>
        global WebDoc_set_stcmt   <span class="stcmt">
        global WebDoc_set__stcmt  </span>
        global WebDoc_set_stoom   <span class="stoom">(output omitted)</span>
        global WebDoc_set_stcnp   <span class="stcnp" style="page-break-after:always">/*
                                */<br/>(continued on next page)<br/></span>
        global WebDoc_set_figure  <figure id="\`macval(id)'">
        global WebDoc_set__figure </figure>
        global WebDoc_set_fcap    <figcaption>\`macval(caption)'</figcaption>
        global WebDoc_set_flink   <a href="\`webname'\`suffix'">
        global WebDoc_set__flink  </a>
        global WebDoc_set_img   `"<img alt="\`macval(alt)'"\`macval(title)' src=""'
        global WebDoc_set__img  `""\`macval(attributes)'/>"'
        global WebDoc_set_svg     <span\`macval(title)'\`macval(attributes)'>
        global WebDoc_set__svg    </span>
        exit
    }
    gettoken set def : 0
    local rc 1
    foreach s in stlog _stlog stcmd _stcmd sthlp _sthlp  stinp _stinp ///
        stres _stres stcmt _stcmt stoom stcnp figure _figure fcap ///
        flink _flink img _img svg _svg {
        if `"`set'"'=="`s'" {
            local rc 0
            continue, break
        }
    }
    if `rc' {
        di as err `"`set' not allowed"'
        exit 198
    }
    global WebDoc_set_`set' `macval(def)'
end

program webdoc_toc
    if `"${WebDoc_docname}"'=="" {
        di as txt "(webdoc not initialized; nothing to do)"
        exit
    }
    syntax [anything] [, Numbered md ]
    gettoken level anything : anything
    gettoken offset anything : anything
    if `"`anything'"'!="" error 198
    if `"`offset'"'!="" {
        capt confirm integer number `offset'
        if _rc error 198
        if (`offset'<0 | `offset'>5) {
            di as err "offset must be in [0,5]"
            exit 198
        }
    }
    else local offset 0
    if `"`level'"'!="" {
        capt confirm integer number `level'
        if _rc error 198
        if (`level'<1 | `level'>(6-`offset')) {
            di as err "level must be in [1,6-offset]"
            exit 198
        }
    }
    webdoc_append_snippet 2
end

program webdoc_substitute
    syntax [anything(equalok everything)] [, Add ]
    if `"${WebDoc_docname}"'=="" exit
    mata: webdoc_substitute()
end

program webdoc_init
    if `"${WebDoc_dofile}"'=="" {
        di as txt "(webdoc do not running; nothing to do)"
        exit
    }
    if `"${WebDoc_ststatus}"'!="" {
        di as err "webdoc init not allowed within stlog section"
        di as err "type {stata webdoc stlog close} to close the stlog section"
        exit 499
    }
    syntax [anything(id="document name")] [, MD ///
        Replace Append NOLOGDIR logdir LOGDIR2(str) NOLOGALL LOGALL ///
        NOPrefix Prefix Prefix2(str) NOSTPATH stpath STPATH2(str) ///
        NODO DO NOLOG LOG NOCMDLog CMDLog NODOSave DOSave NOKeep Keep ///
        NOCustom Custom NOPLAIN PLAIN NORAW RAW NOCMDStrip CMDStrip NOLBStrip ///
        LBStrip NOGTStrip GTStrip NOMatastrip Matastrip NOOutput Output ///
        NOLTRIM LTRIM GRopts(str asis) grdir(str) mark(str asis) tag(str asis) ///
        NOCERTify CERTify LInesize(numlist int max=1 >=40 <=255) ///
        dodir(str) HEADer HEADer2(str) ]
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
    foreach opt in logdir prefix stpath {
        if "``opt''``opt'2'"!="" & "`no`opt''"!="" {
            di as err "`opt'() and no`opt' not both allowed"
            exit 198
        }
    }
    foreach opt in logall do log cmdlog dosave keep custom plain raw ///
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
        // read global defaults if -webdoc do- is running
        local prefix0
        if `"${WebDoc_dofile}"'!=""{
            if "`md'"=="" {
                local md `"${WebDoc_do_md}"'
            }
            if `"`replace'`append'"'=="" {
                local replace `"${WebDoc_do_replace}"'
                local append `"${WebDoc_do_append}"'
            }
            if `"`nologdir'`logdir'`logdir2'"'=="" {
                local logdir `"${WebDoc_do_logdir}"'
                local logdir2 `"${WebDoc_do_logdir2}"'
            }
            if `"`noprefix'`prefix'`prefix2'"'=="" {
                local noprefix `"${WebDoc_do_noprefix}"'
                local prefix `"${WebDoc_do_prefix}"'
                local prefix2 `"${WebDoc_do_prefix2}"'
            }
            if `"`noprefix'`prefix'`prefix2'"'!="" local prefix0 prefix0
            if `"`nostpath'`stpath'`stpath2'"'=="" {
                local stpath `"${WebDoc_do_stpath}"'
                local stpath2 `"${WebDoc_do_stpath2}"'
            }
            foreach opt in do log keep output ltrim {
                if "``opt''`no`opt''"=="" local no`opt' `"${WebDoc_do_no`opt'}"'
            }
            foreach opt in logall cmdlog dosave custom cmdstrip plain raw ///
                lbstrip gtstrip matastrip certify {
                if "``opt''`no`opt''"=="" local `opt' `"${WebDoc_do_`opt'}"'
            }
            if `"`grdir'"'==""   local grdir   `"${WebDoc_do_grdir}"'
            if `"`dodir'"'==""   local dodir   `"${WebDoc_do_dodir}"'
            if `"`header'"'==""  local header  `"${WebDoc_do_header}"'
            foreach opt in gropts mark tag linesize header2 {
                if `"`macval(`opt')'"'=="" {
                    mata: st_local("`opt'", st_global("WebDoc_do_`opt'"))
                }
            }
        }
        // initialize globals
        _webdoc_cleanup_stlog
        mata: webdoc_init()
        // initialize webdoc output file
        // - prepare file
        tempname fh
        qui file open `fh' using `"${WebDoc_docname}"', write `replace' `append'
        file close `fh'
        di as txt `"(webdoc output file is ${WebDoc_docname0})"'
        // - provide Mata file handle in global macro
        mata: st_global("WebDoc_docname_FH", ///
            strofreal(fopen(st_global("WebDoc_docname"), "a")))
    }
    else if `"${WebDoc_docname}"'!="" {
        // update globals
        if `"`prefix'`prefix2'`noprefix'"'!="" {
            local prefix0 prefix0
            global WebDoc_prefix0 "prefix0"
        }
        else {
            local prefix0 `"${WebDoc_prefix0}"'
        }
        if `"`logdir'`logdir2'`nologdir'"'!="" {
            if `"`prefix0'"'=="" {
                if `"${WebDoc_logdir}"'=="" {
                    if `"`logdir2'`logdir'"'!="" local noprefix noprefix
                }
                else {
                    if "`nologdir'"!="" local prefix prefix
                }
            }
            if (`"`logdir2'"'!="")      global WebDoc_logdir `"`logdir2'"'
            else if ("`logdir'"!="") {
                mata: st_global("WebDoc_logdir", ///
                    pathrmsuffix(st_global("WebDoc_basename")))
            }
            else                        global WebDoc_logdir ""
            if `"${WebDoc_logdir}"'!="" {
                mata: webdoc_mkdir(pathjoin(st_global("WebDoc_path"), ///
                    st_global("WebDoc_logdir")))
            }
        }
        if `"`prefix'`prefix2'`noprefix'"'!="" {
            if ("`noprefix'"!="")       global WebDoc_prefix ""
            else if (`"`prefix2'"'!="") global WebDoc_prefix `"`prefix2'"'
            else {
                mata: st_global("WebDoc_prefix", ///
                    pathrmsuffix(st_global("WebDoc_basename")) + "_")
            }
        }
        if "`stpath'`stpath2'`nostpath'"!="" {
            if (`"`stpath2'"'!="")      global WebDoc_stpath `"`stpath2'"'
            else if ("`stpath'"!="")    global WebDoc_stpath `"${WebDoc_path0}"'
            else                        global WebDoc_stpath ""
        }
        foreach opt in do log keep output ltrim {
            if "``opt''`no`opt''"!="" global WebDoc_no`opt' `no`opt''
        }
        foreach opt in logall cmdlog dosave custom plain raw ///
            cmdstrip lbstrip gtstrip matastrip certify {
            if "``opt''`no`opt''"!="" global WebDoc_`opt' ``opt''
        }
        if `"`grdir'"'!=""  global WebDoc_grdir `"`grdir'"'
        if `"${WebDoc_grdir}"'!="" {
            mata: webdoc_mkdir(pathjoin(st_global("WebDoc_path"), ///
                st_global("WebDoc_grdir")))
        }
        foreach opt in gropts mark tag linesize {
            if `"``opt''"'!="" {
                global WebDoc_`opt' `"`macval(`opt')'"'
            }
        }
        if `"`dodir'"'!=""  global WebDoc_dodir `"`dodir'"'
        if `"${WebDoc_dodir}"'!="" {
            mata: webdoc_mkdir(pathjoin(st_global("WebDoc_path"), ///
                st_global("WebDoc_dodir")))
        }
    }
    else {
        di as txt "(webdoc not initialized; nothing to do)"
        exit
    }
    // write a header if requested
    if `"`header'`macval(header2)'"'!="" {
        _webdoc_header , `macval(header2)'
    }
    // clear s-returns (will be filled by webdoc close)
    sreturn clear
end

program _webdoc_header
    syntax [, Title(str) Author(str) date(str) DEScription(str) Keywords(str) ///
        Language(str) CHARset(str) BStheme BStheme2(str) INCLude(str) ///
        STscheme(str) Width(str) NOFOOTer ]
    if `"`macval(title)'"'==""    local title `"${WebDoc_basename}"'
    if `"`macval(language)'"'=="" local language "en"
    if `"`macval(charset)'"'=="" {
        local charset "utf-8"
        if c(stata_version)<14 {
            if c(os)=="MacOSX" local charset "mac"
            else               local charset "iso-8859-1"
        }
    }
    if `"`bstheme'`bstheme2'"'!="" {
        _webdoc_header_bstheme `bstheme2'
    }
    if `"`stscheme'"'!="" {
        _webdoc_header_stscheme, `stscheme'
    }
    if "`nofooter'"=="" {
        if "`jscript'"!="" global WebDoc_footer jscript`selfcontained'
        else               global WebDoc_footer footer
    }
    nobreak {
        capt n break {
            mata: webdoc_instance_fh("fh")
            mata: webdoc_header(${WebDoc_docname_FH}, `fh'=.)
        }
        local rc = _rc
        capture mata: webdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
end

program _webdoc_header_bstheme
    syntax [anything] [, Selfcontained JScript ]
    if `"`anything'"'=="" local anything default
    c_local bstheme `"`anything'"'
    c_local selfcontained "`selfcontained'"
    c_local jscript "`jscript'"
end

program _webdoc_header_stscheme
    syntax [, Standard STUdio Classic Desert Mountain Ocean  /// 
        SImple bg(str) fg(str) rfg(str) cfg(str) rbf cbf LCom ]
    local stscheme `standard' `studio' `classic' `desert' `mountain' ///
        `ocean' `simple'
    if `:list sizeof stscheme'>1 {
        di as err "stscheme(): only one of standard, studio, classic, " _c
        di as err "desert, mountain, ocean, or simple allowed"
        exit 198
    }
    if "`stscheme'"=="standard" {
        if  `"`bg'"'=="" local bg  "#FFFFFF" // white
        if  `"`fg'"'=="" local fg  "#000000" // black
        if `"`rfg'"'=="" local rfg "#000000" // black
        if `"`cfg'"'=="" local cfg "#000000" // black
        if   "`rbf'"=="" local rbf rbf
        if   "`cbf'"=="" local cbf cbf
    }
    else if "`stscheme'"=="studio" {
        if  `"`bg'"'=="" local bg  "#FFFFFF" // white
        if  `"`fg'"'=="" local fg  "#000000" // black
        if `"`rfg'"'=="" local rfg "#000080" // blue
        if `"`cfg'"'=="" local cfg "#000000" // black
        if   "`rbf'"=="" local rbf 
        if   "`cbf'"=="" local cbf cbf
    }
    else if "`stscheme'"=="classic" {
        if  `"`bg'"'=="" local bg  "#000000" // black
        if  `"`fg'"'=="" local fg  "#00FF00" // green
        if `"`rfg'"'=="" local rfg "#FFFF00" // yellow
        if `"`cfg'"'=="" local cfg "#FFFFFF" // white
        if   "`rbf'"=="" local rbf 
        if   "`cbf'"=="" local cbf 
    }
    else if "`stscheme'"=="desert" {
        if  `"`bg'"'=="" local bg  "#FBF9F7" // almost white
        if  `"`fg'"'=="" local fg  "#000000" // black
        if `"`rfg'"'=="" local rfg "#804000" // brown
        if `"`cfg'"'=="" local cfg "#000000" // black
        if   "`rbf'"=="" local rbf 
        if   "`cbf'"=="" local cbf cbf
    }
    else if "`stscheme'"=="mountain" {
        if  `"`bg'"'=="" local bg  "#FFFFFF" // white
        if  `"`fg'"'=="" local fg  "#000000" // black
        if `"`rfg'"'=="" local rfg "#005000" // green
        if `"`cfg'"'=="" local cfg "#000000" // black
        if   "`rbf'"=="" local rbf 
        if   "`cbf'"=="" local cbf cbf
    }
    else if "`stscheme'"=="ocean" {
        if  `"`bg'"'=="" local bg  "#F0F3F9" // blue
        if  `"`fg'"'=="" local fg  "#000000" // black
        if `"`rfg'"'=="" local rfg "#324F58" // blue
        if `"`cfg'"'=="" local cfg "#000000" // black
        if   "`rbf'"=="" local rbf 
        if   "`cbf'"=="" local cbf cbf
    }
    else if "`stscheme'"=="simple" {
        if  `"`bg'"'=="" local bg  "#FFFFFF" // white
        if  `"`fg'"'=="" local fg  "#464646" // gray
        if `"`rfg'"'=="" local rfg "#000000" // black
        if `"`cfg'"'=="" local cfg "#000000" // black
        if   "`rbf'"=="" local rbf 
        if   "`cbf'"=="" local cbf cbf
    }
    if   `"`bg'"'!="" c_local st_bg  `"background-color: `bg'; "'
    if   `"`fg'"'!="" c_local st_fg  `"color: `fg'; "'
    if  `"`rfg'"'!="" c_local st_rfg `"color: `rfg'; "'
    if  `"`cfg'"'!="" c_local st_cfg `"color: `cfg'; "'
    if  `"`rbf'"'!="" c_local st_rbf `"font-weight: bold; "'
    if  `"`cbf'"'!="" c_local st_cbf `"font-weight: bold; "'
    c_local st_lcom `lcom'
end

program webdoc_close, sclass
    if `"${WebDoc_docname}"'=="" {
        di as txt "(webdoc not initialized; nothing to do)"
        exit
    }
    if `"`macval(0)'"'!="" error 198
    if `"${WebDoc_footer}"'!="" {
        if `"${WebDoc_footer}"'=="jscript" {
            _webdoc_put put <script src="https://code.jquery.com/jquery-1.12.4.min.js" /*
                */integrity="sha256-ZosEbRLbNQzLpnKIkEdrPv7lOy9C27hHQ+Xp8a4MxAQ=" /*
                */crossorigin="anonymous"></script>
            _webdoc_put put <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" /*
                */integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" /*
                */crossorigin="anonymous"></script>
        }
        else if `"${WebDoc_footer}"'=="jscriptselfcontained" {
            if c(stata_version)>=13 local protocol "https://"
            else                    local protocol "http://"
            _webdoc_put put <script>
            webdoc_append `"`protocol'code.jquery.com/jquery-1.12.4.js"'
            _webdoc_put put </script>
            _webdoc_put put <script>
            webdoc_append `"`protocol'maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.js"'
            _webdoc_put put </script>
        }
        _webdoc_put put </body>
        _webdoc_put put </html>
    }
    _webdoc_makelink `"${WebDoc_docname}"' // returns local openlink
    di as txt `"(webdoc output written to {`openlink':${WebDoc_docname0}})"'
    sreturn clear
    foreach s in certify nokeep custom cmdlog dosave nooutput noltrim gtstrip ///
        lbstrip cmdstrip matastrip raw plain nolog nodo linesize gropts grdir ///
        mark tag dodir stpath prefix logdir path logall md basename docname {
        mata: st_local("`s'", st_global("WebDoc_`s'"))
        sreturn local `s' `"`macval(`s')'"'
    }
    _webdoc_cleanup
end

program webdoc_stlog
    version 10.1
    local caller : di _caller()
    gettoken subcmd args : 0, parse(",: ")
    local length = length(`"`subcmd'"')
    if `"`subcmd'"'==substr("close",1,max(`length',1)) {
        version `caller': webdoc_stlog_close`macval(args)'
    }
    else if `"`subcmd'"'==substr("oom",1,max(`length',1)) {
        version `caller': webdoc_stlog_oom 1`macval(args)'
    }
    else if `"`subcmd'"'==substr("quietly",1,max(`length',1)) {
        version `caller': webdoc_stlog_oom 0`macval(args)'
    }
    else if `"`subcmd'"'=="cnp" {
        webdoc_stlog_cnp`macval(args)'
    }
    else {
        version `caller': webdoc_stlog_open `macval(0)'
    }
end

program webdoc_stlog_open
    version 10.1
    local caller : di _caller()
    if `"${WebDoc_docname}"'=="" {
        di as txt "(webdoc not initialized; nothing to do)"
        exit
    }
    if `"${WebDoc_ststatus}"'!="" {
        di as err "webdoc stlog not allowed within stlog section"
        di as err "type {stata webdoc stlog close} to close the stlog section"
        exit 499
    }
    _webdoc_cleanup_stlog
    // colon syntax
    capt _on_colon_parse `macval(0)'
    if !_rc {
        local hascolon 1
        mata: st_local("command", st_global("s(after)"))
        mata: st_local("0", st_global("s(before)"))
    }
    else local hascolon 0
    // parse syntax and update settings
    syntax [anything(name=name0)] [using/] [, nostop NOSTHLP STHLP STHLP2(str asis) ///
        NODO DO NOLOG LOG NOCMDLog CMDLog NODOSave DOSave NOKeep Keep ///
        NOCustom Custom NOPLAIN PLAIN NORAW RAW NOCMDStrip CMDStrip NOLBStrip LBStrip ///
        NOGTStrip GTStrip NOMatastrip Matastrip NOOutput Output NOLTRIM LTRIM ///
        mark(str asis) tag(str asis) NOCERTify CERTify ///
        LInesize(numlist int max=1 >=40 <=255) ]
    if `"`using'"'=="" & "`stop'"!="" {
        di as err "nostop only allowed with webdoc stlog using"
        exit 198
    }
    if `"`using'"'!="" {
        mata: st_local("suffix", pathsuffix(st_local("using")))
        if "`nosthlp'"=="" {
            if `"`suffix'"'==".hlp" | `"`suffix'"'==".sthlp" {
                local sthlp sthlp
            }
        }
    }
    if `"`sthlp'`sthlp2'"'!="" {
        if `"`using'"'=="" {
            di as err "sthlp only allowed with webdoc stlog using"
            exit 198
        }
        if "`nosthlp'"!="" {
            di as err "sthlp and nosthlp not both allowed"
            exit 198
        }
        if "`nolog'"!="" {
            di as err "nolog not allowed with sthlp"
            exit 198
        }
        if "`cmdlog'"!="" {
            di as err "cmdlog not allowed with sthlp"
            exit 198
        }
        if "`dosave'"!="" {
            di as err "dosave not allowed with sthlp"
            exit 198
        }
        local nocmdlog nocmdlog
        local log log
        local nodosave nodosave
    }
    if "`nolog'"!="" & "`cmdlog'"!="" {
        di as err "nolog and cmdlog not both allowed"
        exit 198
    }
    if "`nolog'"!=""  local nocmdlog nocmdlog
    if "`cmdlog'"!="" local log log
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
        if "``opt''`no`opt''"=="" local no`opt' ${WebDoc_no`opt'}
        global WebDoc_stno`opt' `no`opt''
    }
    foreach opt in cmdlog dosave custom plain raw cmdstrip ///
        lbstrip gtstrip matastrip certify {
        if "``opt''"!="" & "`no`opt''"!="" {
            di as err "`opt' and no`opt' not both allowed"
            exit 198
        }
        if "``opt''`no`opt''"=="" local `opt' ${WebDoc_`opt'}
        global WebDoc_st`opt' ``opt''
    }
    foreach opt in mark tag {
        if `"`macval(`opt')'"'=="" {
            mata: st_local("`opt'", st_global("WebDoc_`opt'"))
        }
        global WebDoc_st`opt' `"`macval(`opt')'"'
    }
    if "`linesize'"=="" {
        local linesize ${WebDoc_linesize}
    }
    if "`linesize'"!="" {
        global WebDoc_stlinesize0 `"`c(linesize)'"'
        set linesize `linesize'
    }
    else {
        local linesize `"`c(linesize)'"'
    }
    global WebDoc_stlinesize `"`linesize'"'
    // determine base name and id of output section (name0)
    if `"`name0'"'!="" {
        gettoken name0 rest : name0 // get rid of quotes around filename
        if `"`rest'"'!="" error 198
        global WebDoc_stname0 `"`name0'"'
        global WebDoc_stid `"stlog-`name0'"'
    }
    else {
        global WebDoc_stcounter = ${WebDoc_stcounter} + 1
        global WebDoc_stid `"stlog-${WebDoc_stcounter}"'
        local name0 `"${WebDoc_prefix}${WebDoc_stcounter}"'
        global WebDoc_stname0 `"`name0'"'
    }
    global WebDoc_stgrcounter 0
    // generate variations of name and path
    mata: st_local("name", pathjoin(st_global("WebDoc_logdir"), st_local("name0")))
    mata: st_local("filename0", pathjoin(st_global("WebDoc_path"), st_local("name")))
    mata: st_local("webname0", pathjoin(st_global("WebDoc_stpath"), st_local("name")))
    if c(os)=="Windows" {   // use forward slash in include path
        local webname0: subinstr local webname0 "\" "/", all
    }
    local filename `"`filename0'.log"'
    local webname  `"`webname0'.log"'
    global WebDoc_stname      `"`name'"'
    global WebDoc_stfilename0 `"`filename0'"'
    global WebDoc_stfilename  `"`filename'"'
    global WebDoc_stwebname0  `"`webname0'"'
    global WebDoc_stwebname   `"`webname'"'
    // erase -webdoc local- backup and turn stlog status on
    if "`nodo'"=="" {
        capt erase `"`filename0'.stloc"'
    }
    global WebDoc_ststatus "on"
    // handle sthlp 
    if `"`sthlp'`sthlp2'"'!="" {
        _parse comma sthlp2 sthlpopts : sthlp2
        _webdoc_stlog_open_sthlpopts `sthlpopts' // returns sthlpnoid
        if "`nodo'"=="" {
            if "`plain'`raw'"=="" {
                // backup current r-returns
                tempname rcurrent
                _return hold `rcurrent'
                // translate file
                qui log webhtml `"`using'"' `"`filename'"', ///
                    ll(`linesize') replace yebf whbf
                // restore r-returns
                _return restore `rcurrent'
            }
            else {
                qui translate `"`using'"' `"`filename'"', ///
                    translator(smcl2log) replace linesize(`linesize')
            }
            if "`raw'"=="" {
                nobreak {
                    capt n break {
                        mata: webdoc_instance_fh("fh")
                        mata: webdoc_stripsthlp(`fh'=.)
                    }
                    local rc = _rc 
                    capture mata: webdoc_closeout_fh(`fh')
                    capture mata: mata drop `fh'
                    if `rc' exit `rc'
                }
            }
        }
        version `caller': webdoc_stlog_close, _sthlp
        exit
    }
    // open log file
    if "`nolog'`nodo'`cmdlog'"=="" {
        // backup current r-returns
        tempname rcurrent
        _return hold `rcurrent'
        // open log
        di as txt `"(opening webdoc stlog `name')"'
        qui log using `"`filename0'.smcl"', replace smcl name(WebDoc_stlog)
        // restore r-returns
        _return restore `rcurrent'
    }
    // run command if colon syntax
    if `hascolon' {
        if "`nodo'"=="" {
            version `caller': `macval(command)'
        }
        if "`dosave'"!="" {
            tempfile dosopt
            nobreak {
                capt n break {
                    mata: webdoc_instance_fh("fh")
                    mata: webdoc_fput(st_local("dosopt"), `fh'=., ///
                        substr(st_local("command"),1,1)==" " ?    ///
                        substr(st_local("command"),2,.) :         ///
                        st_local("command"), "w", 0)
                }
                local rc = _rc 
                capture mata: webdoc_closeout_fh(`fh')
                capture mata: mata drop `fh'
                if `rc' exit `rc'
            }
            local dosopt `", _dosave0(`dosopt')"'
        }
        version `caller': webdoc_stlog_close`dosopt'
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
        local dosopt
        if "`dosave'"!="" {
            if "`cmdlog'"!="" local dosopt ", _dosave"
            else {
                local dosopt `", _dosave0(`using')"'
            }
        }
        version `caller': webdoc_stlog_close`cmdlogopt'`dosopt'
    }
end

program _webdoc_stlog_open_sthlpopts
    syntax [, noid ]
    c_local sthlpnoid `id'
end

program webdoc_stlog_oom
    version 10.1
    local caller : di _caller()
    gettoken message 0 : 0
    if `"${WebDoc_docname}"'=="" {
        version `caller': `macval(0)'
        exit
    }
    if `"${WebDoc_ststatus}"'=="" {
        version `caller': `macval(0)'
        exit
    }
    version `caller': quietly `macval(0)'
    if `message' di as txt "\WebDoc_OOM"
end

program webdoc_stlog_cnp
    if `"`macval(0)'"'!="" error 198
    if `"${WebDoc_docname}"'=="" exit
    if `"${WebDoc_ststatus}"'=="" exit
    di as txt "\WebDoc_CNP"
end

program webdoc_stlog_close, sclass
    version 10.1
    local caller : di _caller()
    if `"${WebDoc_docname}"'=="" {
        di as txt "(webdoc not initialized; nothing to do)"
        exit
    }
    if `"${WebDoc_ststatus}"'=="" {
        di as txt "(no stlog open; nothing to do)"
        exit
    }
    global WebDoc_ststatus ""
    syntax [, _sthlp _cmdlog(str) _cmdlog0(str) ///
        _DOSAVE _DOSAVE2(str) _dosave0(str) _indent(int 0) ]
    // read settings
    foreach opt in nodo nolog cmdlog dosave nokeep custom plain raw ///
        cmdstrip lbstrip gtstrip matastrip nooutput noltrim certify ///
        grcounter filename filename0 webname webname0 id name0 name {
        local `opt' ${WebDoc_st`opt'}
    }
    foreach opt in mark tag linesize linesize0 {
        mata: st_local("`opt'", st_global("WebDoc_st`opt'"))
    }
    if `"`linesize0'"'!="" {
        set linesize `linesize0'
    }
    // copy dofile
    if `"`_dosave'`_dosave2'`_dosave0'"'!="" {
        if `"`_dosave2'`_dosave0'"'=="" {
            local _dosave2 `"`_cmdlog'"'
            local _dosave0 `"`_cmdlog0'"'
        }
        if `"`_dosave2'`_dosave0'"'!="" local _dosave _dosave
        else                            local _dosave
    }
    if "`_dosave'"!="" {
        local doname `"${WebDoc_dodir}"'
        if `"`doname'"'=="" {
            local doname `"${WebDoc_logdir}"'
        }
        mata: st_local("doname", pathjoin(st_local("doname"), st_local("name0")))
        local doname `"`doname'.do"'
        mata: st_local("doname0", pathjoin(st_global("WebDoc_path"), st_local("doname")))
        nobreak {
            capt n break {
                mata: webdoc_instance_fh("fh")
                mata: webdoc_dostrip(`fh'=.)
            }
            local rc = _rc 
            capture mata: webdoc_closeout_fh(`fh')
            capture mata: mata drop `fh'
            if `rc' exit `rc'
        }
    }
    // backup current r-returns
    tempname rcurrent
    _return hold `rcurrent'
    // process cmdlog
    if "`cmdlog'"!="" {
        if `"`_cmdlog'"'!="" {
            nobreak {
                capt n break {
                    mata: webdoc_instance_fh("fh")
                    mata: webdoc_stripcmdlog(`fh'=.)
                }
                local rc = _rc 
                capture mata: webdoc_closeout_fh(`fh')
                capture mata: mata drop `fh'
                if `rc' exit `rc'
            }
            if "`nokeep'"=="" {
                mata: st_local("logname", pathjoin(st_global("WebDoc_path0"), st_local("name")))
                _webdoc_makelink `"`filename'"' // returns local openlink
                di as txt `"(log-file written to {`openlink':`logname'.log})"'
            }
        }
        else { // can only happen in interactive mode
            // do nothing
        }
    }
    // process log file
    else if "`nolog'`nodo'"=="" {
        if "`_sthlp'"=="" {
            qui log close WebDoc_stlog
            tempfile tmplog
            if "`plain'`raw'"=="" {
                qui log html `"`filename0'.smcl"' `"`tmplog'"', ///
                    ll(`linesize') replace yebf
            }
            else {
                qui translate `"`filename0'.smcl"' `"`tmplog'"', ///
                    translator(smcl2log) replace linesize(`linesize')
            }
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
                    mata: webdoc_instance_fh("fh")
                    mata: webdoc_striplog(`fh'=.)
                }
                local rc = _rc 
                capture mata: webdoc_closeout_fh(`fh')
                capture mata: mata drop `fh'
                if `rc' exit `rc'
            }
        }
        if "`nokeep'"=="" {
            mata: st_local("logname", pathjoin(st_global("WebDoc_path0"), st_local("name")))
            _webdoc_makelink `"`filename'"' // returns local openlink
            di as txt `"(log-file written to {`openlink':`logname'.log})"'
        }
    }
    // dosave message
    if "`_dosave'"!="" {
        _webdoc_makelink `"`doname0'"' // returns local openlink
        mata: st_local("doname0", pathjoin(st_global("WebDoc_path0"), st_local("doname")))
        di as txt `"(do-file written to {`openlink':`doname0'})"'
        mata: st_local("doname", pathjoin(st_global("WebDoc_stpath"), st_local("doname")))
    }
    else local doname
    // write markup insert (unless -nolog- or -custom-)
    if "`nolog'`custom'"=="" {
        if "`_sthlp'"!="" {
            mata: st_local("starttag", st_global("WebDoc_set_sthlp"))
            mata: st_local("closetag", st_global("WebDoc_set__sthlp"))
        }
        else if "`cmdlog'"!="" {
            mata: st_local("starttag", st_global("WebDoc_set_stcmd"))
            mata: st_local("closetag", st_global("WebDoc_set__stcmd"))
        }
        else {
            mata: st_local("starttag", st_global("WebDoc_set_stlog"))
            mata: st_local("closetag", st_global("WebDoc_set__stlog"))
        }
        _webdoc_write write `starttag'
        capt confirm file `"`filename'"'
        if _rc di as txt `"(`filename' not found)"'
        else {
            quietly webdoc_append `"`filename'"'
        }
        _webdoc_put put `closetag'
        if "`nokeep'"!="" {
            capt erase `"`filename'"'
        }
    }
    // s-returns
    mata: st_local("indent", " " * `_indent')
    sreturn clear
    foreach s in certify nokeep custom cmdlog dosave nooutput noltrim ///
        gtstrip lbstrip cmdstrip matastrip raw plain nolog nodo linesize ///
        indent mark tag doname webname0 webname filename0 filename id ///
        name0 name {
        sreturn local `s' `"``s''"'
    }
    // restore r-returns
    _return restore `rcurrent'
end

program webdoc_graph
    if `"${WebDoc_docname}"'=="" {
        di as txt "(webdoc not initialized; nothing to do)"
        exit
    }
    // determine base name and path of graph
    syntax [anything(name=grname)] [, * ]
    gettoken grname rest : grname // get rid of quotes around filename
    if `"`rest'"'!="" error 198
    if `"${WebDoc_ststatus}"'!="" {  // inside stlog section
        if `"`grname'"'=="" {        // get name from stlog
            local grname `"${WebDoc_stname0}"'
            mata: st_local("id", "fig"+substr(st_global("WebDoc_stid"), 6, .))
            if ${WebDoc_stgrcounter}>0 {
                local grname `"`grname'_${WebDoc_stgrcounter}"'
                local id     `"`id'_${WebDoc_stgrcounter}"'
            }
            global WebDoc_stgrcounter = ${WebDoc_stgrcounter} + 1
        }
        else {
            local id `"fig-`grname'"'
        }
        local export = (`"${WebDoc_stnodo}"'=="")
    }
    else {                             // outside stlog section
        if `"${WebDoc_stname0}"'=="" { // no results from webdoc stlog available
            if `"`grname'"'=="" {
                di as err "no stlog available;" _c
                di as err " need to specify a name for the graph"
                exit 499
            }
            local id `"fig-`grname'"'
            local export 1
        }
        else {
            if `"`grname'"'=="" {    // get name from previous stlog
                local grname `"${WebDoc_stname0}"'
                mata: st_local("id", "fig"+substr(st_global("WebDoc_stid"), 6, .))
                if ${WebDoc_stgrcounter}>0 {
                    local grname `"`grname'_${WebDoc_stgrcounter}"'
                    local id     `"`id'_${WebDoc_stgrcounter}"'
                }
            }
            else {
                local id `"fig-`grname'"'
            }
            local export = (`"${WebDoc_stnodo}"'=="")
        }
    }
    if `"${WebDoc_grdir}"'!="" {
        mata: st_local("grname", pathjoin(st_global("WebDoc_grdir"), st_local("grname")))
    }
    else {
        mata: st_local("grname", pathjoin(st_global("WebDoc_logdir"), st_local("grname")))
    }
    mata: st_local("filename", pathjoin(st_global("WebDoc_path"), st_local("grname")))
    mata: st_local("webname", pathjoin(st_global("WebDoc_stpath"), st_local("grname")))
    if c(os)=="Windows" {   // use forward slash in include path
        local webname: subinstr local webname "\" "/", all
    }
    mata: st_local("grname", pathjoin(st_global("WebDoc_path0"), st_local("grname")))
    // parse options and read defaults
    _webdoc_graph_syntax, `macval(options)'
    mata: st_local("opt_options", st_global("WebDoc_gropts"))
    _webdoc_graph_syntax opt_, `macval(opt_options)'
    foreach opt in as attributes alt title caption width height name {
        if `"`macval(`opt')'"'=="" {
            local `opt' `macval(opt_`opt')'
        }
    }
    foreach opt in link figure {
        if "``opt''`no`opt''"=="" {
            local no`opt' `opt_no`opt''
            local `opt'   `opt_`opt''
            local `opt'2  `macval(opt_`opt'2)'
        }
        if "``opt''"!="" & `"``opt'2'"'=="" {
            local `opt'2 `macval(opt_`opt'2)'
        }
    }
    foreach opt in hardcode keep custom {
        if `"``opt''`no`opt''"'=="" {
            local `opt'   `opt_`opt''
            local no`opt' `opt_no`opt''
        }
    }
    if "`cabove'`cbelow'"=="" {
        local cabove `opt_cabove'
        local cbelow `opt_cbelow'
    }
    if `"`options'"'=="" local options `opt_options'
    // strip options with arguments
    _webdoc_graph_syntax2, `as' `macval(attributes)' `macval(alt)' ///
        `macval(title)' `link2' `macval(caption)' `macval(figure2)' ///
        `width' `height' `name'
    // set defaults
    if `"`macval(figure2)'"'!="" {
        local id `"`macval(figure2)'"'
    }
    if `"`as'"'=="" local as "png"
    local isuffix: word 1 of `as'
    local isuffix `".`isuffix'"'
    if `"`name'"'!="" local name name(`name')
    // export graph
    if `export' {
        foreach ff of local as {
            local grsize `width' `height'
            if `"`grsize'"'=="" {
                if inlist(`"`ff'"', "png", "tif", "gif", "jpg") {
                    local grsize width(500)
                }
            }
            qui graph export `"`filename'.`ff'"', replace `name' `grsize' `options'
            if !("`hardcode'"!="" & "`nokeep'"!="") {
                _webdoc_makelink `"`filename'.`ff'"' // returns local openlink
                di as txt `"(graph written to {`openlink':`grname'.`ff'})"'
            }
        }
        if "`hardcode'"!="" {
            if inlist("`isuffix'", ".png", ".jpg", ".gif") {
                nobreak {
                    capt n break {
                        mata: webdoc_instance_fh("fh")
                        mata: webdoc_instance_fh("fh2")
                        mata: webdoc_graph_b64(`fh'=., `fh2'=.)
                    }
                    local rc = _rc
                    capture mata: webdoc_closeout_fh(`fh')
                    capture mata: mata drop `fh'
                    capture mata: webdoc_closeout_fh(`fh2')
                    capture mata: mata drop `fh2'
                    if `rc' exit `rc'
                }
            }
            else if "`isuffix'"==".svg" {
                // do nothing
            }
            else {
                di as err "hardcode not supported with `isuffix'"
                exit 498
            }
        }
    }
    // include graph in document
    if `"`attributes'"'!="" local attributes `" `macval(attributes)'"'
    if `"`alt'"'==""        local alt        `"`webname'`isuffix'"'
    if `"`title'"'!=""      local title      `" title="`macval(title)'""'
    if "`cabove'`cbelow'"=="" local cbelow cbelow    // cbelow is default
    if "`custom'"!="" exit
    if "`nofigure'"=="" {
        _webdoc_put put ${WebDoc_set_figure}
    }
    if "`cabove'"!="" & `"`caption'"'!="" {
        _webdoc_put put ${WebDoc_set_fcap}
    }
    if ("`hardcode'"!="" & "`link'"!="") | "`hardcode'`nolink'"=="" {
        if `"`link2'"'=="" local suffix `"`isuffix'"'
        else               local suffix `".`link2'"'
        mata: st_local("link_start", st_global("WebDoc_set_flink"))
        mata: st_local("link_stop", st_global("WebDoc_set__flink"))
    }
    _webdoc_write write `link_start'
    if "`hardcode'"!="" & "`isuffix'"==".svg" {
        // special case: embedded svg
        _webdoc_put put ${WebDoc_set_svg}
        quietly webdoc_append `"`filename'`isuffix'"', drop(1 3)
        _webdoc_write write ${WebDoc_set__svg}
        if "`nokeep'"!="" {
            capt erase `"`filename'`isuffix'"'
        }
    }
    else {
        // standard case: use the img tag
        _webdoc_write write ${WebDoc_set_img}
        if "`hardcode'"!="" {
            capt confirm file `"`filename'.base64"'
            if _rc {
                di as txt `"(`filename'.base64 not found)"'
                _webdoc_write write `webname'`isuffix'
            }
            else {
                _webdoc_put put data:image/`=substr("`isuffix'",2,.)';base64,
                quietly webdoc_append `"`filename'.base64"'
            }
            if "`nokeep'"!="" {
                capt erase `"`filename'`isuffix'"'
                capt erase `"`filename'.base64"'
            }
        }
        else {
            _webdoc_write write `webname'`isuffix'
        }
        _webdoc_write write ${WebDoc_set__img}
    }
    _webdoc_put put `link_stop'
    if "`cbelow'"!="" & `"`caption'"'!="" {
        _webdoc_put put ${WebDoc_set_fcap}
    }
    if "`nofigure'"=="" {
        _webdoc_put put ${WebDoc_set__figure}
    }
end

program _webdoc_graph_syntax
    syntax [anything(name=prefix)] [,                                       ///
        as(passthru) ATTributes(passthru) alt(passthru) Title(passthru)     ///
        NOLink Link Link2(passthru) CAPtion(passthru) CAbove CBelow         ///
        NOFigure Figure Figure2(passthru)                                   ///
        NOHardcode Hardcode NOKeep keep NOCUSTOM custom                     ///
        Width(passthru) Height(passthru) name(passthru) * ]
    if "`cabove'"!="" & "`cbelow'"!="" {
        di as err "cabove and cbelow not both allowed"
        exit 198
    }
    if `"`link2'"'!="" local link link
    if `"`figure2'"'!="" local figure figure
    if "`custom'"!="" & "`hardcode'"!="" {
        di as err "custom and hardcode not both allowed"
        exit 198
    }
    if "`custom'"!=""   local nohardcode nohardcode
    if "`hardcode'"!="" local nocustom nocustom
    foreach opt in link figure hardcode keep custom {
        if "``opt''"!="" & "`no`opt''"!="" {
            di as err "`opt' and no`opt' not both allowed"
            exit 198
        }
    }
    foreach opt in as attributes alt title caption cabove cbelow   ///
        nolink link link2 nofigure figure figure2 nohardcode hardcode  ///
        nokeep keep nocustom custom width height name options {
        c_local `prefix'`opt' `"`macval(`opt')'"'
    }
end

program _webdoc_graph_syntax2
    syntax [, as(str) attributes(str) alt(str) title(str) link2(str) ///
        caption(str) figure2(str) width(passthru) height(passthru) name(str) ]
    foreach opt in as attributes alt title link2 caption figure2 width ///
        height name {
        c_local `opt' `"`macval(`opt')'"'
    }
end

program webdoc_strip
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
            mata: webdoc_instance_fh("fh")
            mata: webdoc_strip(`fh'=.)
        }
        local rc = _rc 
        capture mata: webdoc_closeout_fh(`fh')
        capture mata: mata drop `fh'
        if `rc' exit `rc'
    }
    _webdoc_makelink `"`out'"' // returns local openlink
    di as txt `"(output written to {`openlink':`out'})"'
end

program webdoc_do
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
    if `"${WebDoc_docname}"'=="" & "`noinit'"=="" local doinit doinit
    if  `"`init2'"'=="" & "`init'`doinit'"!="" {
        mata: webdoc_do_init2() // sets local init2
    }
    _webdoc_do, `macval(options)' // set global defaults
    if `"${WebDoc_dofile}"'=="" {
        // set default HTML tags (unless nested)
        webdoc_set
    }
    if `"${WebDoc_docname}"'!="" & `"`init'"'=="" {
        // update globals if document already open
        webdoc_init, `macval(options)'
    }
    mata: webdoc_add_suffix("dofile", ".do")
    confirm file `"`dofile'"'
    mata: webdoc_add_abspath("dofile")
    global WebDoc_dofile `"`dofile'"'
    if "`cd'"!="" {
        mata: webdoc_get_path(st_local("dofile")) // returns local path
        qui cd `"`path'"'
        di as txt `"(cd `path')"'
    }
    // preprocess do-file
    tempfile dobuf
    nobreak {
        capt n break {
            mata: webdoc_instance_fh("fh")
            mata: webdoc_do(`fh'=.)
        }
        local rc = _rc
        capture mata: webdoc_closeout_fh(`fh')
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

program _webdoc_do
    syntax [, Replace Append MD NOLOGDIR logdir LOGDIR2(str) NOLOGALL LOGALL ///
        NOPrefix Prefix Prefix2(str) NOSTPATH stpath STPATH2(str) ///
        NODO DO NOLOG LOG NOCMDLog CMDLog NODOSave DOSave NOKeep Keep ///
        NOCustom Custom NOPLAIN PLAIN NORAW RAW NOCMDStrip CMDStrip NOLBStrip ///
        LBStrip NOGTStrip GTStrip NOMatastrip Matastrip NOOutput Output ///
        NOLTRIM LTRIM GRopts(str asis) grdir(str) mark(str asis) tag(str asis) ///
        NOCERTify CERTify LInesize(numlist int max=1 >=40 <=255) ///
        dodir(str) HEADer HEADer2(str) ]
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
    foreach opt in logdir prefix stpath {
        if "``opt''``opt'2'"!="" & "`no`opt''"!="" {
            di as err "`opt'() and no`opt' not both allowed"
            exit 198
        }
    }
    foreach opt in logall do log cmdlog dosave keep custom plain raw ///
        cmdstrip lbstrip gtstrip matastrip output ltrim certify {
        if "``opt''"!="" & "`no`opt''"!="" {
            di as err "`opt' and no`opt' not both allowed"
            exit 198
        }
    }
    // read global defaults if nested
    if `"${WebDoc_dofile}"'!="" {
        local md `"${WebDoc_do_md}"'
        if `"`replace'`append'"'=="" {
            local replace `"${WebDoc_do_replace}"'
            local append `"${WebDoc_do_append}"'
        }
        if `"`nologdir'`logdir'`logdir2'"'=="" {
            local logdir `"${WebDoc_do_logdir}"'
            local logdir2 `"${WebDoc_do_logdir2}"'
        }
        if `"`noprefix'`prefix'`prefix2'"'=="" {
            local noprefix `"${WebDoc_do_noprefix}"'
            local prefix `"${WebDoc_do_prefix}"'
            local prefix2 `"${WebDoc_do_prefix2}"'
        }
        if `"`nostpath'`stpath'`stpath2'"'=="" {
            local stpath `"${WebDoc_do_stpath}"'
            local stpath2 `"${WebDoc_do_stpath2}"'
        }
        foreach opt in do log keep output ltrim {
            if "``opt''`no`opt''"=="" local no`opt' `"${WebDoc_do_no`opt'}"'
        }
        foreach opt in logall cmdlog dosave custom plain raw ///
            cmdstrip lbstrip gtstrip matastrip certify {
            if "``opt''`no`opt''"=="" local `opt' `"${WebDoc_do_`opt'}"'
        }
        if `"`grdir'"'==""   local grdir   `"${WebDoc_do_grdir}"'
        foreach opt in gropts mark tag linesize {
            if `"`macval(`opt')'"'=="" {
                mata: st_local("`opt'", st_global("WebDoc_do_`opt'"))
            }
        }
        if `"`dodir'"'==""   local grdir   `"${WebDoc_do_dodir}"'
        if `"`header'"'==""  local header  `"${WebDoc_do_header}"'
        if `"`macval(header2)'"'=="" {
            mata: st_local("header2", st_global("WebDoc_do_header2"))
        }
    }
    foreach opt in replace append md logdir logdir2 noprefix prefix prefix2 ///
        stpath stpath2 logall nodo nolog cmdlog dosave nokeep custom plain ///
        raw cmdstrip lbstrip gtstrip matastrip nooutput noltrim gropts grdir ///
        mark tag certify linesize dodir header header2 {
        global WebDoc_do_`opt' `"`macval(`opt')'"'
    }
end

version 10.1
mata:
mata set matastrict on

/*---------------------------------------------------------------------------*/
/* webdoc append                                                             */
/*---------------------------------------------------------------------------*/

// add contents of file to output document, after applying substitutions
void webdoc_append(real scalar fh, real scalar fh2)
{
    real scalar      i, l
    real colvector   ldrop, p
    string colvector f
    string rowvector sub
    
    f = _webdoc_catnl(st_local("using"), fh2)
    l = length(f)
    if (l<1) {  // empty file
        _webdoc_fwrite(fh, f)
        return
    }
    // line selection
    ldrop = strtoreal(tokens(st_local("drop"))')
    if (length(ldrop)>0) {
        p = J(l, 1, 1)
        for (i=1; i<=length(ldrop); i++) {
            if (ldrop[i]<=l) p[ldrop[i]] = 0
        }
        f = select(f, p)
    }
    // substitutions
    sub = tokens(st_local("substitute"))
    if (mod(length(sub), 2)) sub = (sub, "")
    for (i=1; i<=(length(sub)/2); i++) {
        f = subinstr(f, sub[(i-1)*2+1], sub[i*2])
    }
    // write to output file
    _webdoc_fwrite(fh, f)
}

// read snippet, apply substitutions, and append to output document
void webdoc_append_snippet(real scalar fh, real scalar fh2)
{
    _webdoc_fput(fh, webdoc_snippet_mexp(
        webdoc_snippet_get(fh2, strtoreal(st_local("0"))), fh2))
}

// read snippet; restores snippet collection if it has been destroyed
string colvector webdoc_snippet_get(real scalar fh, real scalar n)
{
    pointer scalar   p
    
    p = findexternal("WebDoc_do_snippets")
    if (p==NULL) {
        p = crexternal("WebDoc_do_snippets")
        fh = fopen(st_global("WebDoc_do_snippets"), "r")
        *p = fgetmatrix(fh)
        fclose(fh)
    }
    return(*(*p)[n])
}

// apply macro substitutions in snippet
string colvector webdoc_snippet_mexp(string colvector s, real scalar fh)
{
    real scalar   i
    string scalar fn, mname
    string matrix S
    
    // substitutions from -webdoc substitute-
    if ((S=st_global("WebDoc_substitute"))!="") {
        S = tokens(S)
        for (i=1; i<=(length(S)/2); i++) {
            s = subinstr(s, S[(i-1)*2+1], S[i*2])
        }
    }
    // substitutions from -webdoc local-
    fn = st_global("WebDoc_stloc")
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
/*  webdoc local                                                             */
/*---------------------------------------------------------------------------*/

void webdoc_local_put(real scalar fh)
{
    string scalar fn, mname, meval
    string matrix S
    
    mname = st_local("mname")
    meval = st_local("meval")
    fn = st_global("WebDoc_stfilename0") + ".stloc"
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
    webdoc_fopen_replace(fn, fh, "w")
    fputmatrix(fh, S)
    fclose(fh)
    st_global("WebDoc_stloc", fn)
}

void webdoc_local_get(real scalar fh)
{
    string scalar fn, mname
    string matrix S
    
    mname = st_local("mname")
    fn = st_global("WebDoc_stfilename0") + ".stloc"
    fh = fopen(fn, "r")
    S = fgetmatrix(fh)
    fclose(fh)
    if (anyof(S[,1], mname)) {
        st_local("meval", S[select(1::rows(S), S[,1]:==mname), 2])
    }
    else _error(3499)
    st_global("WebDoc_stloc", fn)
}

/*---------------------------------------------------------------------------*/
/*  webdoc substitute                                                        */
/*---------------------------------------------------------------------------*/

void webdoc_substitute()
{
    string scalar s, s0
    
    s = st_local("anything")
    if (mod(length(tokens(s)), 2)) s = s + " " + `""""'
    if (st_local("add")!="") {
        if (s!="") {
            s0 = st_global("WebDoc_substitute")
            st_global("WebDoc_substitute", (s0!="" ? s0 + " " : "") + s)
        }
    }
    else st_global("WebDoc_substitute", s)
}

/*---------------------------------------------------------------------------*/
/* webdoc init                                                               */
/*---------------------------------------------------------------------------*/

// set webdoc init globals
void webdoc_init()
{
    string scalar fn, path, path0, fname
    pragma unset  path
    pragma unset  fname
    
    fn = st_local("anything")
    pathsplit(fn, path, fname)
    path0 = path
    if (pathisabs(path)) webdoc_mkdir(path)
    else {
        webdoc_mkdir(path)
        path = pathjoin(pwd(), path)
    }
    if (pathsuffix(fname)=="") {
        if (st_local("md")!="") fname = fname + ".md"
        else                    fname = fname + ".html"
    }
    fn = pathjoin(path, fname)
    if (fn==st_global("WebDoc_dofile")) {
        display("{err}init docname must be different from source do-file")
        exit(error(498))
    }
    st_global("WebDoc_docname",       fn)       // filename with abs. path
    st_global("WebDoc_docname0",      pathjoin(path0, fname))
    st_global("WebDoc_basename",      fname)
    st_global("WebDoc_md",            st_local("md"))
    st_global("WebDoc_path",          path)     // absolute path
    st_global("WebDoc_path0",         path0)    // path as specified
    if (st_local("logdir2")!="")      st_global("WebDoc_logdir", st_local("logdir2"))
    else if (st_local("logdir")!="")  st_global("WebDoc_logdir", pathrmsuffix(fname))
    else                              st_global("WebDoc_logdir", "")
    if (st_global("WebDoc_logdir")!="") {
        webdoc_mkdir(pathjoin(path0, st_global("WebDoc_logdir")))
    }
    if (st_local("noprefix")!="")     st_global("WebDoc_prefix", "")
    else if (st_local("prefix2")!="") st_global("WebDoc_prefix", st_local("prefix2"))
    else if (st_local("prefix")!="")  st_global("WebDoc_prefix", pathrmsuffix(fname) + "_")
    else if (st_global("WebDoc_logdir")!="") st_global("WebDoc_prefix", "")
    else                              st_global("WebDoc_prefix", pathrmsuffix(fname) + "_")
    if (st_local("stpath2")!="")      st_global("WebDoc_stpath", st_local("stpath2"))
    else if (st_local("stpath")!="")  st_global("WebDoc_stpath", path0)
    else                              st_global("WebDoc_stpath", "")
    st_global("WebDoc_stcounter",     "0")
    st_global("WebDoc_prefix0",       st_local("prefix0"))
    st_global("WebDoc_logall",        st_local("logall"))
    st_global("WebDoc_nodo",          st_local("nodo"))
    st_global("WebDoc_nolog",         st_local("nolog"))
    st_global("WebDoc_cmdlog",        st_local("cmdlog"))
    st_global("WebDoc_dosave",        st_local("dosave"))
    st_global("WebDoc_nokeep",        st_local("nokeep"))
    st_global("WebDoc_custom",        st_local("custom"))
    st_global("WebDoc_plain",         st_local("plain"))
    st_global("WebDoc_raw",           st_local("raw"))
    st_global("WebDoc_cmdstrip",      st_local("cmdstrip"))
    st_global("WebDoc_lbstrip",       st_local("lbstrip"))
    st_global("WebDoc_gtstrip",       st_local("gtstrip"))
    st_global("WebDoc_matastrip",     st_local("matastrip"))
    st_global("WebDoc_nooutput",      st_local("nooutput"))
    st_global("WebDoc_noltrim",       st_local("noltrim"))
    st_global("WebDoc_certify",       st_local("certify"))
    st_global("WebDoc_grdir",         st_local("grdir"))
    if (st_global("WebDoc_grdir")!="") {
        webdoc_mkdir(pathjoin(path0, st_global("WebDoc_grdir")))
    }
    st_global("WebDoc_gropts",        st_local("gropts"))
    st_global("WebDoc_mark",          st_local("mark"))
    st_global("WebDoc_tag",           st_local("tag"))
    st_global("WebDoc_linesize",      st_local("linesize"))
    st_global("WebDoc_dodir",         st_local("dodir"))
    if (st_global("WebDoc_dodir")!="") {
        webdoc_mkdir(pathjoin(path0, st_global("WebDoc_dodir")))
    }
    st_global("WebDoc_substitute",    "")
}

// write header
void webdoc_header(real scalar fh, real scalar fh2) 
{
    string scalar    theme, css, width, integrity
    string rowvector cc
    
    width = st_local("width")
    fput(fh,  "<!DOCTYPE html>")
    fput(fh, `"<html lang=""' + st_local("language") + `"">"')
    fput(fh,  "<head>")
    // meta
    fput(fh, `"<meta charset=""' + st_local("charset") + `"">"')
    fput(fh, `"<meta http-equiv="X-UA-Compatible" content="IE=edge">"')
    fput(fh, `"<meta name="viewport" content="width=device-width, initial-scale=1">"')
    fput(fh, `"<meta name="format-detection" content="telephone=no">"')
    fput(fh,  "<title>" + st_local("title") + "</title>")
    if (st_local("author")!="") {
        fput(fh, `"<meta name="author" content=""' + st_local("author") + `"">"')
    }
    if (st_local("date")!="") {
        fput(fh, `"<meta name="date" content=""' + st_local("date") + `"">"')
    }
    if (st_local("description")!="") {
        fput(fh, `"<meta name="description" content=""' + st_local("description") + `"">"')
    }
    if (st_local("keywords")!="") {
        fput(fh, `"<meta name="keywords" content=""' + st_local("keywords") + `"">"')
    }
    // theme
    theme = st_local("bstheme")
    if (theme!="") {
        css = "maxcdn.bootstrapcdn.com/"
        if (theme=="default") css = css + "bootstrap/3.3.7/css/bootstrap"
        else                  css = css + "bootswatch/3.3.7/" + theme + "/bootstrap"
        if (st_local("selfcontained")!="") {
            if (stataversion()>=1300) css = "https://" + css
            else                      css = "http://" + css
            fput(fh, "<style>")
            _webdoc_fwrite(fh, _webdoc_catnl(css+".css", fh2))
            fput(fh, "</style>")
        }
        else {
            css = "https://" + css
            if      (theme=="default")   integrity = "sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u"
            else if (theme=="cerulean")  integrity = "sha384-zF4BRsG/fLiTGfR9QL82DrilZxrwgY/+du4p/c7J72zZj+FLYq4zY00RylP9ZjiT"
            else if (theme=="cosmo")     integrity = "sha384-h21C2fcDk/eFsW9sC9h0dhokq5pDinLNklTKoxIZRUn3+hvmgQSffLLQ4G4l2eEr"
            else if (theme=="cyborg")    integrity = "sha384-D9XILkoivXN+bcvB2kSOowkIvIcBbNdoDQvfBNsxYAIieZbx8/SI4NeUvrRGCpDi"
            else if (theme=="darkly")    integrity = "sha384-S7YMK1xjUjSpEnF4P8hPUcgjXYLZKK3fQW1j5ObLSl787II9p8RO9XUGehRmKsxd"
            else if (theme=="flatly")    integrity = "sha384-+ENW/yibaokMnme+vBLnHMphUYxHs34h9lpdbSLuAwGkOKFRl4C34WkjazBtb7eT"
            else if (theme=="journal")   integrity = "sha384-1L94saFXWAvEw88RkpRz8r28eQMvt7kG9ux3DdCqya/P3CfLNtgqzMnyaUa49Pl2"
            else if (theme=="lumen")     integrity = "sha384-gv0oNvwnqzF6ULI9TVsSmnULNb3zasNysvWwfT/s4l8k5I+g6oFz9dye0wg3rQ2Q"
            else if (theme=="paper")     integrity = "sha384-awusxf8AUojygHf2+joICySzB780jVvQaVCAt1clU3QsyAitLGul28Qxb2r1e5g+"
            else if (theme=="readable")  integrity = "sha384-Li5uVfY2bSkD3WQyiHX8tJd0aMF91rMrQP5aAewFkHkVSTT2TmD2PehZeMmm7aiL"
            else if (theme=="sandstone") integrity = "sha384-G3G7OsJCbOk1USkOY4RfeX1z27YaWrZ1YuaQ5tbuawed9IoreRDpWpTkZLXQfPm3"
            else if (theme=="simplex")   integrity = "sha384-C0X5qw1DlkeV0RDunhmi4cUBUkPDTvUqzElcNWm1NI2T4k8tKMZ+wRPQOhZfSJ9N"
            else if (theme=="slate")     integrity = "sha384-RpX8okQqCyUNG7PlOYNybyJXYTtGQH+7rIKiVvg1DLg6jahLEk47VvpUyS+E2/uJ"
            else if (theme=="spacelab")  integrity = "sha384-L/tgI3wSsbb3f/nW9V6Yqlaw3Gj7mpE56LWrhew/c8MIhAYWZ/FNirA64AVkB5pI"
            else if (theme=="superhero") integrity = "sha384-Xqcy5ttufkC3rBa8EdiAyA1VgOGrmel2Y+wxm4K3kI3fcjTWlDWrlnxyD6hOi3PF"
            else if (theme=="united")    integrity = "sha384-pVJelSCJ58Og1XDc2E95RVYHZDPb9AVyXsI8NoVpB2xmtxoZKJePbMfE4mlXw7BJ"
            else if (theme=="yeti")      integrity = "sha384-HzUaiJdCTIY/RL2vDPRGdEQHHahjzwoJJzGUkYjHVzTwXFQ2QN/nVgX7tzoMW3Ov"
            else _error(theme + ": invalid bstheme")
            fput(fh, `"<link href=""' + css + ".min.css" + 
                `"" rel="stylesheet" integrity=""' + integrity + 
                `"" crossorigin="anonymous">"')
        }
        // some additional settings
        fput(fh, "<style>")
        if (st_local("width")!="") {
            _webdoc_fput(fh, "body { " \
                             "  max-width: " + width + ";" \
                             "  margin: 0 auto; padding: 0 15px;" \
                             "}")
        }
        fput(fh, "img { max-width: 100%; height: auto; }")
        //fput(fh, "code, pre, samp { font-family: Courier, monospace; }")
        fput(fh, "pre { word-break: normal; word-wrap: normal; }")
        cc = ("inherit", "#F5F5F5")
        if (theme=="cyborg")         cc[1] =  "#282828"
        else if (theme=="darkly")    cc    = ("#303030", "#EBEBEB")
        else if (theme=="slate")     cc[1] =  "#3A3F44"
        else if (theme=="superhero") cc[1] =  "#333333"
        fput(fh, "code { color: " + cc[1] + "; background-color: " + cc[2] + "; }")
        fput(fh, "pre code, pre samp { white-space: pre; }")
        fput(fh, "</style>")
    }
    // some standard definitions if no theme selected
    else {
        _webdoc_fput(fh, 
            `"<style>"'                                                        \
            `"html { -webkit-text-size-adjust: 100%; }"'                       \
            `"body {"'                                                         \
            `"  font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;"' \
            `"  font-size: 14px; line-height: 1.428;"')
        if (st_local("width")!="") fput(fh, `"  max-width: "' + width + ";")
        _webdoc_fput(fh, 
            `"  margin: 0 auto; padding: 0 15px;"'                             \
            `"}"'                                                              \
            `"h1, h2, h3, h4, h5, h6 { margin: 20px 0 10px; }"'                \
            `"h1 { font-size: 28px; } h2 { font-size: 24px; }"'                \
            `"h3 { font-size: 18px; } h4 { font-size: 16px; }"'                \
            `"h5 { font-size: 14px; } h6 { font-size: 12px; }"'                \
            `"a { color: #337AB7; text-decoration: none; }"'                   \
            `"a:hover { text-decoration: underline; }"'                        \
            `"img { max-width: 100%; height: auto; }"'                         \
            `"ul, ol { padding-left: 30px; }"'                                 \
            `"pre, code, samp {"'                                              \
            `"  font-size: 13px;"'                                             \
            `"  font-family: Courier, monospace;"'                             \
            `"}"'                                                              \
            `"code, samp {"'                                                   \
            `"  background-color: #F5F5F5;"'                                   \
            `"  border-radius: 3px; padding: 3px;"'                            \
            `"}"'                                                              \
            `"pre code, pre samp {"'                                           \
            `"  white-space: pre; background: transparent;"'                   \
            `"  border: none; padding: 0;"'                                    \
            `"}"'                                                              \
            `"pre {"'                                                          \
            `"  line-height: 1.33; background-color: #F5F5F5;"'                \
            `"  border: 1px solid #CCCCCC; border-radius: 3px;"'               \
            `"  padding: 8px; overflow: auto;"'                                \
            `"}"'                                                              \
            `"</style>"')
    }
    // include
    if (st_local("include")!="") {
        _webdoc_fwrite(fh, _webdoc_catnl(st_local("include"), fh2))
    }
    // Stata style
    fput(fh, `"<style>"')
    if (st_local("stscheme")!="") {
        fput(fh, ".stlog { " + st_local("st_fg") + st_local("st_bg") + "}")
        fput(fh, ".stres { " + st_local("st_rbf") + st_local("st_rfg") + "}")
        fput(fh, ".stinp { " + st_local("st_cbf") + st_local("st_cfg") + "}")
    }
    fput(fh, ".stcmd .stcmt { font-style: italic; opacity: 0.5; }")
    if (st_local("st_lcom")!="") {
        fput(fh, ".stlog .stcmt { font-style: italic; opacity: 0.5; }")
    }
    fput(fh, ".stoom, .stcnp { font-style: italic; }")
    fput(fh, "@media screen { .stcnp { display: none; }}")
    fput(fh, "</style>")
    // close header
    fput(fh, "</head>")
    fput(fh, "<body>")
}

/*---------------------------------------------------------------------------*/
/* webdoc stlog                                                              */
/*---------------------------------------------------------------------------*/

// substitute HTML characters (&, <, >)
void _webdoc_htmlchars(string colvector f)
{
    f = subinstr(subinstr(subinstr(f, "&", "&amp;"), "<", "&lt;"), ">", "&gt;")
}

// process sthlp file
void webdoc_stripsthlp(real scalar fh)
{
    real scalar      i, noid
    string scalar    fn, id, cmd, path, href0, href1, href2
    string colvector f
    string rowvector sub
    pragma unset     path
    
    fn  = st_local("filename")
    if (st_local("plain")!="") {
        f = _webdoc_cat(fn, fh)
        _webdoc_htmlchars(f)
        webdoc_fput(fn, fh, f, "w", 1)
        return
    }
    id  = st_global("WebDoc_stid")
    noid = st_local("sthlpnoid")!=""
    sub = tokens(st_local("sthlp2"))
    if (mod(length(sub), 2)) sub = (sub, "")
    cmd = st_local("using")
    pathsplit(cmd, path, cmd)
    cmd = pathrmsuffix(cmd)
    href0 = `"<a href="/help.cgi?"'
    href1 = `"<a href="#"'
    href2 = `"<a href="http://www.stata.com/help.cgi?"'
    if (noid==0) sub = 
        "<p>", "",                                 // remove <p> tags 
        `"<a name=""', `"<a name=""' + id + `"-"', // local id tags
        sub,                                       // user substitutions
        href0 + cmd + `"""', href1 + id + `"""',   // main internal link
        href0 + cmd + `"#"', href1 + id + `"-"',   // other internal links
        href0, href2                               // remaining links
    else sub = 
        "<p>", "",                                 // remove <p> tags 
        sub,                                       // user substitutions
        href0 + cmd + `"""', href1 + id + `"""',   // main internal link
        href0 + cmd + `"#"', href1,                // other internal links
        href0, href2                               // remaining links
    f = _webdoc_cat(fn, fh)
    f = f[| 2 \ rows(f)-1|]         // remove leading <pre> and closing </pre>
    for (i=1; i<=(length(sub)/2); i++) {
        f = subinstr(f, sub[(i-1)*2+1], sub[i*2])
    }
    _webdoc_striplog_mark(f, st_local("mark"))
    _webdoc_striplog_tag(f, st_local("tag"))
    webdoc_fput(fn, fh, f, "w", 1)
}

// process log file
void webdoc_striplog(real scalar fh)
{
    real scalar      i, i0, r, a, c, inmata, wd, plain, lgt,
                     lbstrip, gtstrip, matastrip, cmdstrip
    real colvector   p
    string scalar    s, indent, gt, stinp, _stinp, stres, _stres, stcmt, _stcmt
    string rowvector f

    stinp     = st_global("WebDoc_set_stinp")
    _stinp    = st_global("WebDoc_set__stinp")
    stres     = st_global("WebDoc_set_stres")
    _stres    = st_global("WebDoc_set__stres")
    stcmt     = st_global("WebDoc_set_stcmt")
    _stcmt    = st_global("WebDoc_set__stcmt")
    plain     = (st_local("plain")!="" | st_local("raw")!="")
    lbstrip   = (st_local("lbstrip")!="")
    gtstrip   = (st_local("gtstrip")!="")
    matastrip = (st_local("matastrip")!="")
    cmdstrip  = (st_local("cmdstrip")!="")
    f = _webdoc_cat(st_local("tmplog"), fh)
    if (st_local("raw")!="") gt = "> "
    else {
        if (plain) _webdoc_htmlchars(f)
        gt = "&gt; "
    }
    lgt = strlen(gt)
    r = rows(f)
    p = J(r,1,1)
    i0 = 1
    if (r>0) {
        if (plain) {
            if (f[i0]=="") {   // first line
                p[i0] = 0; i0++
            }
        }
        else {
            if (f[i0]=="<pre>") {   // first line
                p[i0] = 0; i0++
            }
            if (f[i0]=="<p>") {     // second line
                p[i0] = 0; i0++
            }
            if (f[r]=="</pre>") {  // last line
                p[r] = 0; r--
            }
        }
    }
    c = inmata = 0
    for (i=i0; i<=r; i++) {
        s = f[i]
        if (s=="") {
            c = 0
            continue
        }
        if (s=="<p>") {
            f[i] = ""
            c = 0
            continue
        }
        if (inmata) {
            if (substr(s,1,2)!=": ") {
                if (plain==0) _webdoc_striplog_res(f, i, stres, _stres)
                continue
            }
        }
        else {
            if (s=="\WebDoc_OOM") {
                f[i] = st_global("WebDoc_set_stoom")
                c = 0
                continue
            }
            if (s=="\WebDoc_CNP") {
                _webdoc_striplog_cnp(f, p, i, r)
                c = 0
                continue
            }
            if (substr(s,1,2)!=". ") {
                if (c==0) {
                    if (plain==0) _webdoc_striplog_res(f, i, stres, _stres)
                    continue
                }
                // check for "  #. " command line
                if (_webdoc_striplog_check_numcmd(f, i, c)==0) {
                    if (c>1) {
                        if (plain==0) _webdoc_striplog_res(f, i, stres, _stres)
                        c = 0
                        continue
                    }
                    c++ // loops start with 2, not with 1
                    if (_webdoc_striplog_check_numcmd(f, i, c)==0) {
                        if (plain==0) _webdoc_striplog_res(f, i, stres, _stres)
                        c = 0
                        continue
                    }
                }
                c++
            }
            else if (c==0) c = 1 // can contain subsequent "  #. " lines
        }
        // end of dofile (-webdoc stlog using-)
        if (i==(r-1)) {
            if (f[i]==". " & f[i+1]=="end of do-file") {
                p[|i \ r|] = J(r-i+1, 1, 0)
                break   // end of logfile
            }
        }
        // read command line
        a = i
        s = _webdoc_striplog_read_cmd(f, i, r, inmata, lbstrip, gt, lgt)
        // handle mata ending
        if (inmata) {
            if (strtrim(s)=="end") {
                inmata = 0
                if (matastrip) {
                    _webdoc_striplog_mata_end(f, i, r)
                    p[|a \ i|] = J(i-a+1, 1, 0)
                    matastrip = 0
                    continue
                }
            }
            if (cmdstrip) p[|a \ i|] = J(i-a+1, 1, 0)
            else {
                if (plain==0) webdoc_tag_comments(f, a, i, inmata, 1, stcmt, _stcmt)
                _webdoc_striplog_com(f, a, i, plain, gtstrip, lgt, 0, stinp, _stinp)
            }
            continue
        }
        // handle mata opening
        if (anyof(("mata","mata:","mata :"), stritrim(strtrim(s)))) {
            inmata = 1
            if (matastrip) {
                if (a==i0) { // remove mata opening
                    _webdoc_striplog_mata(f, i, r, gt, lgt)
                    p[|a \ i|] = J(i-a+1, 1, 0)
                    continue
                }
                matastrip = 0
            }
            if (cmdstrip) p[|a \ i|] = J(i-a+1, 1, 0)
            else {
                if (plain==0) webdoc_tag_comments(f, a, i, inmata, 1, stcmt, _stcmt)
                _webdoc_striplog_com(f, a, i, plain, gtstrip, lgt, 0, stinp, _stinp)
            }
            continue
        }
        // handle webdoc commands
        if (strrtrim(substr(strltrim(s), 1, 7))=="webdoc") {  // webdoc ...
            wd = strlen(s)
            s = strltrim(s)
            indent = (wd - strlen(s)) * " "
            s = tokens(substr(s, 8, .), ", ")
            if (i>=r) {
                if (webdoc_cmdmatch(s, ("stlog", "close"), (1, 1))) {
                    p[|a \ r|] = J(r-a+1, 1, 0)
                    break   // end of logfile
                }
            }
            if (webdoc_cmdmatch(s, ("stlog", "cnp"), (1, 3))) {
                p[|a \ i|] = J(i-a+1, 1, 0)
                continue
            }
            if (webdoc_cmdmatch(s, ("stlog", "oom"), (1, 1))) {
                i = webdoc_cut(f, p, a, i, "oom", 1, indent, lgt+1) - 1
                continue
            }
            if (webdoc_cmdmatch(s, ("stlog", "quietly"), (1, 1))) {
                i = webdoc_cut(f, p, a, i, "quietly", 1, indent, lgt+1) - 1
                continue
            }
            // remove all other webdoc commands
            while (1) { // capture output
                if (i==r) break
                if (substr(f[i+1],1,2)==". ") break
                i++
            }
            p[|a \ i|] = J(i-a+1, 1, 0)
            continue
        }
        if (cmdstrip) p[|a \ i|] = J(i-a+1, 1, 0)
        else {
            if (plain==0) webdoc_tag_comments(f, a, i, inmata, 1, stcmt, _stcmt)
            _webdoc_striplog_com(f, a, i, plain, gtstrip, lgt, c, stinp, _stinp)
        }
    }
    if (rows(f)>0) f = select(f, p)
    if (rows(f)>1) {
        if (f[rows(f)]=="") f = f[|1 \ rows(f)-1|] // remove empty line at end
    }
    _webdoc_striplog_mark(f, st_local("mark"))
    _webdoc_striplog_tag(f, st_local("tag"))
    webdoc_fput(st_local("filename"), fh, f, "w", 1+(st_local("certify1")!=""))
}

// check whether line start with "  #. "
real scalar _webdoc_striplog_check_numcmd(string colvector f, real scalar i, 
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
string scalar _webdoc_striplog_read_cmd(string colvector f, real scalar i,
    real scalar r, real scalar inmata, real scalar lbstrip, 
    string scalar gt, real scalar lgt) 
{
    real scalar   lb, cb, l
    string scalar s, stmp
    
    lb = cb = 0; l = 2
    stmp = substr(f[i],l+1,.)
    s = webdoc_strip_comments(stmp, lb, cb, inmata)
    while (1) {
        if (lbstrip) {
            if (lb) {
                lb = webdoc_locate_lb(stmp, cb)
                if (lb<.) f[i] = substr(f[i],1,l) + substr(stmp, 1, lb)
            }
        }
        if (i==r) break
        l = lgt
        if (substr(f[i+1],1,l)!=gt) break
        i++
        stmp = substr(f[i],l+1,.)
        s = s + webdoc_strip_comments(substr(f[i],l+1,.), lb, cb, 1)
    }
    return(s)
}

// add html decoration to output line
void _webdoc_striplog_res(string colvector f, real scalar i, 
    string scalar start, string scalar stop)
{
    f[i] = subinstr(f[i], "<b>", start)
    f[i] = subinstr(f[i], "</b>", stop)
}

// add html decoration to command lines; remove "> " if requested
void _webdoc_striplog_com(string colvector f, real scalar a, real scalar b,
    real scalar plain, real scalar gtstrip, real scalar lgt, real scalar c,
    string scalar start, string scalar stop)
{
    real scalar cpos
    
    if (gtstrip) {
        if (b>a) {
            f[|a+1 \ b|] = "  " :+ substr(f[|a+1 \ b|], lgt+1, .)
        }
    }
    if (plain==0) {
        cpos = 0
        if (c>1) cpos = strpos(f[a],". ")
        if (cpos<4) f[a] = start + f[a]
        else f[a] = substr(f[a],1,cpos-1) + start + substr(f[a],cpos,.)
        f[b] = f[b] + stop
    }
}

// add a page break
void _webdoc_striplog_cnp(string colvector f, real colvector p, 
    real scalar i, real scalar r)
{
    real scalar i0

    i0 = i
    while (i0>1) {
        i0--
        if (p[i0]!=0) break
    }
    f[i0] = f[i0] + st_global("WebDoc_set_stcnp")
    p[i] = 0
    if (i<r) {
        if (anyof(("", "<p>"), f[i+1])) { // remove next line
            p[++i] = 0
        }
    }
}

// remove Mata opening output --- mata (...) ---
void _webdoc_striplog_mata(string colvector f, real scalar i, real scalar r,
    string scalar gt, real scalar lgt)
{
    if (i<r) {
        if (substr(f[i+1],1,1)=="-") {
            i++
            if (i<r) { 
                if (substr(f[i+1],1,1)=="-" |
                    substr(f[i+1],1,lgt)==gt) {
                    i++
                }
            }
        }
    }
}

// remove Mata ending output
void _webdoc_striplog_mata_end(string colvector f, real scalar i, 
    real scalar r)
{
    if (i<r) {
        if (substr(f[i+1],1,1)=="-") {
            i++
            if (i<r) {
                if (anyof(("", "<p>"), f[i+1])) {
                    i++
                }
            }
        }
    }
}

// add <mark> to specified tokens
void _webdoc_striplog_mark(string colvector f, string scalar mark)
{
    real scalar i
    
    if (mark=="") return
    mark = tokens(mark)
    for (i=1; i<=length(mark); i++) {
        f = subinstr(f, mark[i], `"<mark>"' + mark[i] + "</mark>")
    }
}

// add tags to specified tokens; last two tokens are the start and end tags
void _webdoc_striplog_tag(string colvector f, string scalar tag)
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
            else         start = _webdoc_striplog_tag_noquotes(tag[j+1])
            if ((j+2)>l) stop  = ""
            else         stop  = _webdoc_striplog_tag_noquotes(tag[j+2])
            for (i=i0; i<=(j-1); i++) {
                s = _webdoc_striplog_tag_noquotes(tag[i])
                f = subinstr(f, s, start + s + stop)
            }
            j = j + 2
            i0 = j + 1
        }
    }
}
string scalar _webdoc_striplog_tag_noquotes(string scalar s)
{
    if      (substr(s, 1, 1)==`"""')       s = substr(s, 2, strlen(s)-2)
    else if (substr(s, 1, 2)=="`" + `"""') s = substr(s, 3, strlen(s)-4)
    return(s)
}

// process command log file (cmdlog option)
void webdoc_stripcmdlog(real scalar fh)
{
    real scalar      i, j, r, a, wd, lbstrip, matastrip, inmata, plain
    real colvector   p
    string scalar    s, indent
    string rowvector f, stcmt, _stcmt

    stcmt     = st_global("WebDoc_set_stcmt")
    _stcmt    = st_global("WebDoc_set__stcmt")
    plain     = (st_local("plain")!="" | st_local("raw")!="")
    lbstrip   = (st_local("lbstrip")!="")
    matastrip = (st_local("matastrip")!="")
    
    if (st_local("_cmdlog")=="") f = _webdoc_cat(st_local("_cmdlog0"), fh)
    else f = webdoc_snippet_get(fh, strtoreal(st_local("_cmdlog")))
    if (st_local("raw")=="") _webdoc_htmlchars(f)
    r = rows(f)
    p = J(r,1,1)
    inmata = 0
    for (i=1; i<=r; i++) {
        if (f[i]=="") continue
        a = i
        s = _webdoc_stripcmdlog_read_cmd(f, i, r, inmata, lbstrip)
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
        else if (anyof(("mata","mata:","mata :"), strtrim(stritrim(s)))) {
            inmata = 1
            if (a==1 & matastrip) {
                p[|a \ i|] = J(i-a+1, 1, 0) // remove mata opening
                continue
            }
            matastrip = 0
        }
        if (strrtrim(substr(strltrim(s), 1, 7))=="webdoc") {  // webdoc ...
            wd = strlen(s)
            s = strltrim(s)
            indent = (wd - strlen(s)) * " "
            s = tokens(substr(s, 8, .), ", ")
            if (webdoc_cmdmatch(s, ("stlog", "oom"), (1, 1))) {
                j = webdoc_cut(f, p, a, i, "oom", 1, indent, 0)
                if (plain==0) webdoc_tag_comments(f, j, i, inmata, 0, stcmt, _stcmt)
            }
            else if (webdoc_cmdmatch(s, ("stlog", "quietly"), (1, 1))) {
                j = webdoc_cut(f, p, a, i, "quietly", 1, indent, 0)
                if (plain==0) webdoc_tag_comments(f, j, i, inmata, 0, stcmt, _stcmt)
            }
            else if (webdoc_cmdmatch(s, ("stlog", "cnp"), (1, 3))) {
                _webdoc_stripcmdlog_cnp(f, p, a, i)
            }
            else {
                p[|a \ i|] = J(i-a+1, 1, 0)
            }
            continue
        }
        if (plain==0) webdoc_tag_comments(f, a, i, inmata, 0, stcmt, _stcmt)
    }
    if (rows(f)>0) f = select(f, p)
    _webdoc_striplog_mark(f, st_local("mark"))
    _webdoc_striplog_tag(f, st_local("tag"))
    webdoc_fput(st_local("filename"), fh, f, "w", 1)
}

// read command line and optionally strip line break comments
string scalar _webdoc_stripcmdlog_read_cmd(string colvector f,
    real scalar i, real scalar r, real scalar inmata, real scalar lbstrip) 
{
    real scalar   lb, cb
    string scalar s, stmp
    
    lb = cb = 0
    stmp = subinstr(f[i], char(9), " ")
    s = webdoc_strip_comments(stmp, lb, cb, inmata)
    while (lb | cb) {
        if (lbstrip) {
            if (lb) {
                lb = webdoc_locate_lb(stmp, cb)
                if (lb<.) f[i] = substr(f[i], 1, lb)
            }
        }
        if (i==r) break
        i++
        stmp = subinstr(f[i], char(9), " ")
        s = s + webdoc_strip_comments(stmp, lb, cb, 1)
    }
    return(s)
}

// add a page break
void _webdoc_stripcmdlog_cnp(string colvector f, real colvector p, 
    real scalar a, real scalar i)
{
    real scalar i0
    
    i0 = i
    p[|a \ i|] = J(i-a+1, 1, 0)
    while (i0>1) {
        i0--
        if (p[i0]!=0) break
    }
    f[i0] = f[i0] + st_global("WebDoc_set_stcnp")
}

// remove webdoc commands from stlog dofile
void webdoc_dostrip(real scalar fh)
{
    real scalar      i, i0, r, wd
    real colvector   p
    string rowvector s, indent
    string colvector f

    if (st_local("_dosave2")=="") f = _webdoc_cat(st_local("_dosave0"), fh)
    else f = webdoc_snippet_get(fh, strtoreal(st_local("_dosave2")))
    r = rows(f)
    p = J(r,1,1)
    for (i=1; i<=r; i++) {
        i0 = i
        s = webdoc_read_cmd(f, i, r, 0)
        if (strrtrim(substr(strltrim(s), 1, 7))=="webdoc") {  // webdoc ...
            wd = strlen(s)
            s = strltrim(s)
            indent = (wd - strlen(s)) * " "
            s = tokens(substr(s, 8, .), ", ")
            if (webdoc_cmdmatch(s, ("stlog", "oom"), (1, 1))) {
                (void) webdoc_cut(f, p, i0, i, "oom", 1, indent, 0)
                // (i not changed; do not reread stripped cmd)
            }
            else if (webdoc_cmdmatch(s, ("stlog", "quietly"), (1, 1))) {
                (void) webdoc_cut(f, p, i0, i, "quietly", 1, indent, 0)
            }
            else p[|i0 \ i|] = J(i-i0+1, 1, 0)
        }
    }
    if (r>0) f = select(f, p)
    else     f = ""
    webdoc_fput(st_local("doname0"), fh, f, "w", 1)
}

/*---------------------------------------------------------------------------*/
/* webdoc strip                                                              */
/*---------------------------------------------------------------------------*/

// remove webdoc elements from file
void webdoc_strip(real scalar fh)
{
    real scalar      i, r, markup, tl, stlog, lb, cb, a
    real colvector   p
    string scalar    in, out, start, stop, webdocexit, indent
    string rowvector s
    string colvector f

    in = st_local("in"); out = st_local("out")
    webdocexit = "// webdoc exit"
    start = "/***"
    stop  = "***/"
    tl    = 5
    markup = stlog = lb = cb = 0
    f = _webdoc_cat(in, fh)
    r = rows(f)
    if (r<1) return
    p = J(r,1,1)
    for (i=1; i<=r; i++) {
        if (lb==0 & cb==0) {                        // new command line
            s = subinstr(f[i], char(9), " ")        // expand tabs
            if (markup) {                           // process markup block
                p[i] = 0
                s = strtrim(s)
                if (markup<.) {
                    if (strrtrim(substr(s,1,tl))==start) markup++
                }
                else markup = 1
                if ((strlen(s)>=tl ? strltrim(substr(s,-tl,.)) : s)==stop) markup--
                continue
            }
            if (stlog==0) {                         // start of markup block
                if (strrtrim(substr(strltrim(s),1,tl))==start) {
                    p[i] = 0
                    markup = .
                    i-- // closing tag may be on same line
                    continue
                }
            }
            if (strtrim(stritrim(s))==webdocexit) { // end of input
                p[|i \ .|] = J(r-i+1, 1, 0)
                break
            }
            a = i
            s = webdoc_strip_comments(s, lb, cb, 0)
        }
        else {                                      // continued command line
            s = s + webdoc_strip_comments(subinstr(f[i], char(9), " "), 
                    lb, cb, 0)
        }
        if (lb | cb) continue                       // command not complete yet
        indent = (strlen(s) - strlen(strltrim(s))) * " "
        s = strtrim(stritrim(s))
        if (strrtrim(substr(s, 1, 7))=="webdoc") {  // webdoc ...
            s = tokens(substr(s, 8, .), ",: ")
            if (webdoc_cmdmatch(s, "stlog", 1)) {  // webdoc stlog ...
                if (webdoc_cmdmatch(s, ("stlog", "close"), (1, 1))) {
                    stlog = 0
                    p[|a \ i|] = J(i-a+1, 1, 0)
                }
                else if (webdoc_cmdmatch(s, ("stlog", "oom"), (1, 1))) {
                    (void) webdoc_cut(f, p, a, i, "oom", 1, indent, 0)
                }
                else if (webdoc_cmdmatch(s, ("stlog", "quietly"), (1, 1))) {
                    (void) webdoc_cut(f, p, a, i, "quietly", 1, indent, 0)
                }
                else if (webdoc_cmdmatch(s, ("stlog", "cnp"), (1, 3))) {
                    p[|a \ i|] = J(i-a+1, 1, 0)
                }
                else {
                    if (anyof(s, ":")) {            // webdoc stlog ... : ...
                        (void) webdoc_cut(f, p, a, i, ":", 1, indent, 0)
                        continue
                    }
                    if (_webdoc_strip_using(s)) {   // webdoc stlog using
                        _webdoc_strip_cutopts(f, p, webdoc_cut(f, p, a, i, 
                            "using", 5, indent+"do ", 0), i)
                        continue
                    }
                    stlog = 1
                    p[|a \ i|] = J(i-a+1, 1, 0)
                }
            }
            else if (webdoc_cmdmatch(s, "local", 3)) {
                (void) webdoc_cut(f, p, a, i, "webdoc", 6, indent, 0)
            }
            else if (webdoc_cmdmatch(s, "do", 2)) {
                _webdoc_strip_cutopts(f, p, webdoc_cut(f, p, a, i, 
                    "webdoc", 6, indent, 0), i)
            }
            else p[|a \ i|] = J(i-a+1, 1, 0)    // other webdoc command
        }
    }
    webdoc_fput(out, fh, select(f, p), (st_local("append")!="" ? "a" : "w"), 
        st_local("replace")!="")
}

real scalar _webdoc_strip_using(string rowvector s) 
{
    real scalar l
    
    l = length(s)
    if (l<2) return(0)
    if (s[2]=="using") return(1)
    if (l<3) return(0)
    if (s[3]=="using") return(1)
    return(0)
}

void _webdoc_strip_cutopts(string colvector f, real colvector p, real scalar a,
    real scalar b)
{
    real scalar i, j, cb, par

    cb = par = 0
    for (j=a; j<=b; j++) {
        i = webdoc_locate_comma(subinstr(f[j], char(9), " "), cb, par)
        if (i<.) {
            f[j] = substr(f[j], 1, i)
            if (j<b) {
                p[|j+1 \ b|] = J(b-j, 1, 0)
            }
        }
    }
}

/*---------------------------------------------------------------------------*/
/* webdoc graph                                                              */
/*---------------------------------------------------------------------------*/

// convert PNG graph file to Base64
void webdoc_graph_b64(real scalar fh, real scalar fh2)
{
    real scalar      i, j, k
    real rowvector   b
    string scalar    s
    string rowvector idx
    
    idx = ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
           "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
           "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
           "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
           "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/")
    fh  = fopen(st_local("filename")+st_local("isuffix"), "r")      // input
    webdoc_fopen_replace(st_local("filename")+".base64", fh2, "w")  // output
    b = J(1, 24, 0)     // temporary 24 bit vector
    i = 0               // input character counter
    j = 0               // output character counter
    while ((s=fread(fh, 1))!=J(0,0,"")) {
        k = mod(i, 3) * 8
        i++
        _webdoc_graph_b64_bit(b, k, ascii(s))
        if (k==16) {
            _webdoc_graph_b64(fh2, j, b, idx)
            b = b*0     // reset bit vector
        }
    }
    if (k<16) {         // handle end of file
        _webdoc_graph_b64(fh2, j, b, idx)
        if (k<8) {
            fseek(fh2,-2,0)
            fwrite(fh2, "=")
        }
        else fseek(fh2,-1,0)
        fwrite(fh2, "=")
    }
    fclose(fh)
    fclose(fh2)
}

// append input ascii code to 24 bit vector
void _webdoc_graph_b64_bit(real rowvector b, real scalar k, real scalar c0)
{
    real scalar   i, c
    
    //if (c0!=floor(c0) | c0<0 | c0>255) _error(3300)
    c = c0
    i = k + 8
    while (c>0) {
        if (mod(c,2)) b[i] = 1
        c = floor(c/2)
        i--
    }
}

// convert 24 bit vector to 4 Base64 characters and write to file (using a 
// line width of 100 characters)
void _webdoc_graph_b64(real scalar fh, real scalar j, real rowvector b, 
    string rowvector idx)
{
    real scalar   i, k, d
    
    d = 0; k = 6
    for (i=1; i<=24; i++) {
        if (b[i]==1) d = d + 2^(k-i)
        if (mod(i,6)==0) {
            if (j>0 & mod(j,100)==0) fput(fh,"")
            fwrite(fh, idx[1+d])
            j++
            d = 0; k = k + 6
        }
    }
}

/*---------------------------------------------------------------------------*/
/* webdoc do                                                                 */
/*---------------------------------------------------------------------------*/

// create name for output document from name of dofile
void webdoc_do_init2()
{
    string scalar fn
    
    fn = st_local("dofile")
    if (st_local("cd")!="") fn = pathbasename(fn)
    fn = pathrmsuffix(fn)
    st_local("init2", fn)
}

// add default suffix to filename if it has no suffix
void webdoc_add_suffix(string scalar macname, string scalar suffix)
{
    string scalar fn
    
    fn = st_local(macname)
    if (pathsuffix(fn)=="") fn = fn + suffix
    st_local(macname, fn)
}

// add absolute path if path is relative
void webdoc_add_abspath(string scalar macname)
{
    string scalar fn
    
    fn = st_local(macname)
    if (pathisabs(fn)==0) fn = pathjoin(pwd(), fn)
    st_local(macname, fn)
}

// return path from filename in local cd
void webdoc_get_path(string scalar fn)
{
    string scalar path, basename
    pragma unset path
    pragma unset basename
    
    pathsplit(fn, path, basename)
    st_local("path", path)
}

// main function to parse the dofile
void webdoc_do(real scalar fh)
{
    real colvector   t, init
    string colvector f
    pointer vector   S
    
    // read file and initialize dictionary
    f = _webdoc_cat(st_local("dofile"), fh)
    t = J(rows(f), 1, 0)
    /*  codes in t:
        0 nothing to do                         markup sections:
        1 webdoc init docname                   -1 /*** .... ***/
        2 webdoc init (without docname)         -2 /*** ...
        3 webdoc close                          -3 ... ***/
        4 webdoc stlog using / webdoc stlog :
        5 webdoc stlog (without using or colon)
        6 webdoc stlog oom/quietly
        7 webdoc stlog cnp
        8 webdoc stlog close
        9 webdoc toc
       10 webdoc graph
       11 webdoc local
       99 other webdoc command
        . extra lines of command
    */
    init = 0
    // analyze dofile
    webdoc_do_analyze(f, t, init)
    // add init command if necessary
    if (init==0 & st_local("doinit")!="") {
        f = "webdoc init " + "`" + `"""' + st_local("init2") + `"""' + "'" \ f
        t = 1 \ t
    }
    // initialize pointer vector to collect snippets
    S = &2, &(J(0,1,"")), J(1,100,NULL)
    // strip markup sections
    webdoc_do_markup(f, t, S)
    // insert extra stlog commands if needed (logall option)
    webdoc_do_logall(f, t)
    // parse stlog sections
    webdoc_do_stlog(f, t, S)
    // post snippets to external global
    _webdoc_post_snippets(fh, S)
    // return processed do-file
    webdoc_fput(st_local("dobuf"), fh, f, "w", 0)
}

// add snippet to collection of markup snippets and return counter
real scalar _webdoc_add_snippet(pointer vector S, string colvector s)
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
void _webdoc_post_snippets(real scalar fh, pointer vector S)
{
    string scalar    fn
    pointer scalar   p

    if ((p = findexternal("WebDoc_do_snippets"))==NULL) {
        p = crexternal("WebDoc_do_snippets")
    }
    *p = S
    fn = st_tempfilename()
    st_global("WebDoc_do_snippets", fn)
    fh = fopen(fn, "w")
    fputmatrix(fh, S)
    fclose(fh)
}

// analyze dofile
void webdoc_do_analyze(string colvector f, real colvector t, real scalar init)
{
    real scalar      i, i0, r, k, stlog, tl
    string scalar    s, webdocexit, start, stop
    
    webdocexit = "// webdoc exit"   // end of webdoc do-file
    start = "/***"                  // markup section start tag
    tl    = 5                       // tag length
    stop  = "***/"                  // markup section stop tag
    k     = 0                       // markup section nesting level
    stlog = 0                       // stlog section
    r = rows(f)
    for (i=1; i<=r; i++) {
        i0 = i
        s = strtrim(subinstr(f[i], char(9), " ")) // expand tabs
        // look for end of markup section
        if (k) {
            if (strrtrim(substr(s,1,tl))==start) k++
            if ((strlen(s)>=tl ? strltrim(substr(s,-tl,.)) : s)==stop) k--
            if (k==0) {
                t[i] = -3
                continue
            }
            if (stritrim(s)==webdocexit) { // end of input
                f = f[|1 \ i-1|]; t = t[|1 \ i-1|]
                return
            }
            continue
        }
        // look for start of markup section (unless within stlog section)
        if (stlog==0) {
            if (strrtrim(substr(s,1,tl))==start) k = 1
            if (k) {
                t[i] = -1
                if (strltrim(substr(s,-tl,.))==stop) k = 0
                if (k) t[i] = t[i] - 1
                continue
            }
        }
        // end of input
        if (stritrim(s)==webdocexit) {
            if (i>1) {
                f = f[|1 \ i-1|]; t = t[|1 \ i-1|]
            }
            else {
                f = J(0,1,""); t = J(0,1,.)
            }
            return
        }
        // look for webdoc commands
        s = strltrim(webdoc_read_cmd(f, i, r, 0))
        if (strrtrim(substr(s, 1, 7))=="webdoc") {
            s = tokens(substr(s, 8, .), ",: ")
            // webdoc init
            if (webdoc_cmdmatch(s, "init", 1)) {
                if (_webdoc_init_docname(s)==0) t[i0] = 2 // without docname
                else {                                    // with docname
                    init = 1; t[i0] = 1
                }
            }
            // webdoc close
            else if (webdoc_cmdmatch(s, "close", 1)) t[i0] = 3
            // webdoc stlog close
            else if (webdoc_cmdmatch(s, ("stlog", "close"), (1, 1))) {
                stlog = 0
                t[i0] = 8
            }
            // webdoc stlog oom
            else if (webdoc_cmdmatch(s, ("stlog", "oom"), (1, 1))) t[i0] = 6
            // webdoc stlog quietly
            else if (webdoc_cmdmatch(s, ("stlog", "quietly"), (1, 1))) t[i0] = 6
            // webdoc stlog cnp
            else if (webdoc_cmdmatch(s, ("stlog", "cnp"), (1, 3))) t[i0] = 7
            // webdoc stlog
            else if (webdoc_cmdmatch(s, "stlog", 1)) {
                if (_webdoc_stlog_using(s)) t[i0] = 4
                else if (anyof(s, ":"))     t[i0] = 4
                else {
                    t[i0] = 5
                    stlog = 1
                }
            }
            // webdoc toc
            else if (webdoc_cmdmatch(s, "toc", 3)) t[i0] = 9
            // webdoc graph
            else if (webdoc_cmdmatch(s, "graph", 2)) t[i0] = 10
            // webdoc local
            else if (webdoc_cmdmatch(s, "local", 3)) t[i0] = 11
            // other webdoc command
            else t[i0] = 99
            // handle extra lines of command
            if (i>i0) t[|i0+1 \ i|] = J(i-i0, 1, .)
        }
    }
}

// check whether docname specified with webdoc init
real scalar _webdoc_init_docname(string rowvector s)
{
    if (length(s)<2) return(0) // no arguments
    if (s[2]!=",")   return(1) // docname specified
    return(0)                  // only options specified
}

// check whether command has -using-
real scalar _webdoc_stlog_using(string rowvector s)
{
    real scalar j

    for (j=2; j<=length(s); j++) {
        if (s[j]=="using") return(1)
        if (s[j]==",") return(0)
    }
    return(0)
}

// handle markup sections
void webdoc_do_markup(string colvector f, real colvector t, pointer vector S)
{
    real scalar      i, i0, a, b, init, r, stlog, tl, 
                     toc, otoc, ntoc, itoc, mdtoc
    real colvector   p
    real rowvector   ctoc
    string scalar    start, stop
    string colvector snip

    start = "/***"                  // markup section start tag
    tl    = 5                       // tag length
    stop  = "***/"                  // markup section stop tag
    r = rows(f)
    p = J(r, 1, 1)
    init  = (st_global("WebDoc_docname")!="") // (nested webdoc do)
    stlog = toc = otoc = ntoc = itoc = mdtoc = 0
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
        // get toc status
        if (toc==0 & t[i]==9) {
            _webdoc_toc_init(f, i, r, toc, otoc, ntoc, mdtoc)
            ctoc = J(1, toc, 0)
            continue
        }
        if (t[i]>=0) continue
        // strip markup section
        i0 = i
        if (t[i]==-2) {
            for (;i<=r; i++) {
                if (t[i]==-3) break
            }
        }
        // remove start tag
        f[i0] = substr(f[i0], strpos(f[i0], start) + tl, .)
        // remove stop tag (unless file ends prematurely)
        if (i<=r) f[i] = substr(f[i], 1, _webdoc_strrpos(f[i], stop) - 2)
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
        // store markup snippet and insert webdoc append command
        if (a<=r) snip = f[|a \ b|]
        else      snip = "" // file ended with "/***"
        if (toc) _webdoc_toc(S, snip, toc, otoc, ntoc, ctoc, itoc, mdtoc)
        f[i] = "webdoc append_snippet " + 
            strofreal(_webdoc_add_snippet(S, snip))
        t[i] = 99 // mark webdoc command
        // disable unneeded lines
        if (i>i0) p[|i0 \ i-1|] = J(i-i0, 1, 0)
    }
    if (toc) {
        for (; itoc>0; itoc--) {
            *S[2] = *S[2] \ "</li>"
            *S[2] = *S[2] \ "</ul>"
        }
    }
    // update file and post snippets to external global
    f = select(f, p)
    t = select(t, p)
}

// find rightmost position of s in s0; needed because strrpos() not available
// prior to Stata 14
real scalar _webdoc_strrpos(string scalar s0, string scalar s)
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

void _webdoc_toc_init(string colvector f, real scalar i, real scalar r,
    real scalar toc, real scalar otoc, real scalar ntoc, real scalar mdtoc) 
{
    string rowvector s
    
    s = tokens(webdoc_read_cmd(f, i, r, 0), ", ")
    if (length(s)<3) {
        toc = 3; otoc = 0; ntoc = 0; mdtoc = 0
        return
    }
    toc = strtoreal(s[3])
    if (toc<1 | toc>6) toc = 3
    if (length(s)<4) {
        otoc = 0; ntoc = 0; mdtoc = 0
        return
    }
    otoc = strtoreal(s[4])
    if (otoc<0 | otoc>5) otoc = 0
    if (toc>(6-otoc)) toc = 6-otoc
    ntoc = _webdoc_hasopt(s, "numbered", 1)
    mdtoc = _webdoc_hasopt(s, "md")
}

// look for headings
void _webdoc_toc(pointer vector S, string colvector f, real scalar toc, 
    real scalar otoc, real scalar ntoc, real rowvector ctoc, real scalar itoc, 
    real scalar mdtoc)
{
    real scalar   i, j, d, md
    string scalar s, s1, id, num, hnum
    
    for (i=1; i<=rows(f); i++) {
        md = 0
        s = f[i]
        s1 = strltrim(subinstr(s, char(9), " ")) // allow white space
        for (d=1; d<=toc; d++) {
            if (substr(s1,1,3)==("<h" + strofreal(d+otoc))) break
            if (mdtoc) {
                if (substr(s,1,(d+otoc)+1)==((d+otoc)*"#"+" ")) {
                    md = 1
                    break
                }
            }
        }
        if (d>toc) continue
        ctoc[d] = ctoc[d] + 1
        if (d<itoc) {
            for (; itoc>d; itoc--) {
                *S[2] = *S[2] \ "</li>" \ "</ul>"
            }
            *S[2] = *S[2] \ "</li>"
        }
        else if (ctoc[d]==1) {
            for (; itoc<d; itoc++) {
                *S[2] = *S[2] \ "<ul>"
            }
        }
        else {
            *S[2] = *S[2] \ "</li>"
        }
        if (d<toc) ctoc[|d+1 \ toc|] = ctoc[|d+1 \ toc|] * 0
        num = invtokens(strofreal(ctoc[|1 \ d|]))
        id =  "h-" + subinstr(num, " ", "-")
        if (ntoc) {
            num  = subinstr(num, " ", ".") + "&nbsp;"
            hnum = `"<span class="heading-secnum">"' + num + "</span> "
            num  = `"<span class="toc-secnum">"' + num + "</span> "
        }
        else {
            num = hnum = ""
        }
        if (md) {
            s = substr(s, d+2,. )
            f[i] = "<h" + strofreal(d+otoc) + `" id=""' + id + `"">"' + hnum + 
                   s + "</h" + strofreal(d+otoc) + ">"
        }
        else {
            j = strpos(s, ">") // end of <h#...>
            if (regexm(substr(s,1,j), `"<.+id *= *"(.+)".*>"')) { // parse id="..."
                id = regexs(1)
                f[i] = substr(f[i],1,j) + hnum + substr(f[i],j+1,.)
            }
            else {
                f[i] = substr(f[i],1,j-1) + `" id=""' + id + `"">"' + hnum + 
                       substr(f[i],j+1,.)
            }
            s = substr(s, j+1, .)
            j = strpos(s, "</h" + strofreal(d+otoc) + ">") // closing </h#>
            if (j>0) s = substr(s, 1, j-1)
        }
        *S[2] = *S[2] \ `"<li><a href="#"' + id + `"">"' + num + s + "</a>"
    }
}

// insert extra stlog commands if needed (logall option)
void webdoc_do_logall(string colvector f, real colvector t)
{
    real scalar      i, i0, r, a, b, init, stlog, logall, add
    real colvector   p
    
    r = rows(f)
    p = J(r, 1, 0)
    stlog = add = 0
    init   = (st_global("WebDoc_docname")!="") // (nested webdoc do)
    logall = (init ? st_global("WebDoc_logall")!="" : 0)
    a = (logall ? 1 : .)
    for (i=1; i<=r; i++) {
        // update init status
        if (stlog==0) {
            if (t[i]==1) init = 1    // webdoc init
        }
        if (init==0)  continue       // not initialized
        if (t[i]<=0)  continue       // no webdoc command
        if (t[i]>=.)  continue       // no webdoc command
        if (t[i]==6)  continue       // webdoc stlog oom/quietly
        if (t[i]==7)  continue       // webdoc stlog cnp
        if (t[i]==11) continue       // webdoc local
        // skip to last line of command
        i0 = i
        while (i<r) {
            if (t[i+1]<.) break
            i++
        }
        // existing stlog section
        if (stlog) {
            if (t[i0]==8) { // webdoc stlog close 
                stlog = 0
                if (logall) a = i + 1
            }
            continue
        }
        if (t[i0]==5) stlog = 1
        // mark lines where webdoc stlog commands have to be inserted
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
                p[a] = 1  // insert webdoc stlog
                p[b] = 2  // insert webdoc stlog close
            }
        }
        // webdoc close
        if (t[i]==3) {
            init = 0; a = .
            continue
        }
        // update logall status
        if (t[i0]==1 | t[i0]==2) { // webdoc init (with or without docname)
            i = i0
            _webdoc_init_logall(webdoc_tokens(webdoc_read_cmd(f, i, r, 0)), logall)
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
                f = f \ "webdoc stlog close"
                p = p \ 0
                t = t \ 8
            }
        }
    }
    // add extra extra stlog commands
    if (add==0) return
    _webdoc_do_logall(f, t, p, add)
}
void _webdoc_do_logall(string colvector f, real colvector t, 
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
            f[j] = "webdoc stlog"
            t[j] = 5
            j++
        }
        else if (p[i]==2) {
            f[j] = "webdoc stlog close"
            t[j] = 8
            j++
        }
        f[j] = f0[i]
        t[j] = t0[i]
    }
}

// check whether logall option was specified
void _webdoc_init_logall(string rowvector s, real scalar logall)
{
    if (length(s)<3) return // no arguments
    if (s[3]!=",") {        // docname specified
        logall = (st_global("WebDoc_do_logall")!="")
    }
    if (logall) {
        if (_webdoc_hasopt(s, "nologall")) logall = 0
    }
    else {
        if (_webdoc_hasopt(s, "logall")) logall = 1
    }
}

// check whether option 'opt' was specified
real scalar _webdoc_hasopt(string rowvector s, string scalar opt,
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
void webdoc_do_stlog(string colvector f, real colvector t, pointer vector S)
{

    real scalar      r, i, i0, init, indent, add,
                     cmdl0, dos0, nolog0, nodo0, nolt0, noout0,
                     cmdl, n, dos, nodo, nolt, noout
    real colvector   p
    string scalar    s
    pragma unset     indent
    pragma unset     cmdl
    pragma unset     dos
    pragma unset     nodo
    pragma unset     nolt
    pragma unset     noout

    // read settings in case already initialized (nested webdoc do)
    init    = st_global("WebDoc_docname")!=""
    cmdl0   = (init ? st_global("WebDoc_cmdlog")!=""   : 0)
    dos0    = (init ? st_global("WebDoc_dosave")!=""   : 0)
    nolog0  = (init ? st_global("WebDoc_nolog")!=""    : 0)
    nodo0   = (init ? st_global("WebDoc_nodo")!=""     : 0)
    nolt0   = (init ? st_global("WebDoc_noltrim")!=""  : 0)
    noout0  = (init ? st_global("WebDoc_nooutput")!="" : 0)
    add = 0
    r = rows(f)
    p = J(r, 1, 1)
    for (i=1; i<=r; i++) {
        // update init status
        if (t[i]==1)      init = 1  // webdoc init
        else if (t[i]==3) init = 0  // webdoc close
        if (init==0) continue       // not initialized
        if (!anyof((1,2,5), t[i])) continue // irrelevant line
        // read command line
        i0 = i
        s = webdoc_tokens(webdoc_read_cmd(f, i, r, 0))
        // webdoc init (t=1 or t=2): update default settings
        if (anyof((1,2), t[i0])) {
            _webdoc_init_stopts(s, cmdl0, dos0, nolog0, nodo0, nolt0, noout0)
            continue
        }
        // webdoc stlog (t=5): read options
        _webdoc_stlog_stopts(s, cmdl0, dos0, nodo0, nolt0, noout0, 
                                cmdl, dos, nodo, nolt, noout) 
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
                if (t[i]==10 | t[i]==11) { // webdoc graph or webdoc local
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
                f[|i0 \ i-1|] = _webdoc_do_ltrim(f[|i0 \ i-1|], indent)
            }
            else indent = 0
        }
        else indent = 0
        // save stlog lines to tempfile
        if (cmdl | dos) {
            if (i0==i) n = _webdoc_add_snippet(S, J(0, 1, ""))
            else       n = _webdoc_add_snippet(S, f[|i0 \ i-1|])
        }
        // skip to last line of webdoc stlog close command
        i0 = i
        while (i<r) {
            if (t[i+1]<.) break
            i++
        }
        // exit if file ends prematurely
        if (i>r) break
        // update webdoc stlog close (unless file ends prematurely)
        if (indent | cmdl | dos) {
            f[i0] = "webdoc stlog close,"
            if (i>i0) { // remove extra lines
                p[|i0+1 \ i|] = J(i-i0, 1, 0)
            }
            if (cmdl) {
                f[i0] = f[i0] + " _cmdlog(" + strofreal(n) + ")"
            }
            if (dos) {
                if (cmdl) f[i0] = f[i0] + " _dosave"
                else      f[i0] = f[i0] + " _dosave(" + strofreal(n) + ")"
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
        _webdoc_do_stlog(f, p, add)
    }
    // return result
    f = select(f, p)
}
void _webdoc_do_stlog(string colvector f, real colvector p, real scalar add)
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
string colvector _webdoc_do_ltrim(string colvector s, real scalar indent)
{
    real colvector l
    
    l = strlen(strltrim(subinstr(s, char(9), " ")))
    indent = min(select(strlen(s) :- l, l))
    if (indent>=.) indent = 0 // happens if all lines only contain white space
    if (indent<1) return(s)
    return(substr(s, indent+1, .))
}

// update stlog defaults from webdoc init
void _webdoc_init_stopts(string rowvector s, real scalar cmdl, real scalar dos,
    real scalar nolog, real scalar nodo, real scalar nolt, real scalar noout)
{
    if (length(s)<3) return // no arguments
    if (s[3]!=",") {        // docname specified
        cmdl   = (st_global("WebDoc_do_cmdlog")!="")
        dos    = (st_global("WebDoc_do_dosave")!="")
        nolog  = (st_global("WebDoc_do_nolog")!="")
        nodo   = (st_global("WebDoc_do_nodo")!="")
        nolt   = (st_global("WebDoc_do_noltrim")!="")
        noout  = (st_global("WebDoc_do_nooutput")!="")
    }
    if (noout) noout = (_webdoc_hasopt(s, "output", 1)==0)
    else       noout = _webdoc_hasopt(s, "nooutput", 3)
    if (nolt)  nolt  = (_webdoc_hasopt(s, "ltrim")==0)
    else       nolt  = _webdoc_hasopt(s, "noltrim")
    if (nodo)  nodo  = (_webdoc_hasopt(s, "do")==0)
    else       nodo  = _webdoc_hasopt(s, "nodo")
    if (nolog) nolog = ((_webdoc_hasopt(s, "log")==0) &
                        (_webdoc_hasopt(s, "cmdlog", 4)==0))
    else       nolog = _webdoc_hasopt(s, "nolog")
    if (cmdl)  cmdl  = ((_webdoc_hasopt(s, "nocmdlog", 6)==0) &
                        (_webdoc_hasopt(s, "nolog")==0))
    else       cmdl  = _webdoc_hasopt(s, "cmdlog", 4)
    if (dos)   dos   = (_webdoc_hasopt(s, "nodosave", 5)==0)
    else       dos   = _webdoc_hasopt(s, "dosave", 3)
}

// read local stlog settings
void _webdoc_stlog_stopts(string rowvector s, real scalar cmdl0, 
    real scalar dos0, real scalar nodo0, real scalar nolt0, 
    real scalar noout0, real scalar cmdl, real scalar dos, 
    real scalar nodo, real scalar nolt, real scalar noout)
{
    if (length(s)<=3) { // no arguments
        cmdl = cmdl0; dos = dos0; nodo = nodo0; nolt = nolt0; noout = noout0
    }
    if (noout0) noout = (_webdoc_hasopt(s, "output", 1)==0)
    else        noout = _webdoc_hasopt(s, "nooutput", 3)
    if (nolt0)  nolt  = (_webdoc_hasopt(s, "ltrim")==0)
    else        nolt  = _webdoc_hasopt(s, "noltrim")
    if (nodo0)  nodo  = (_webdoc_hasopt(s, "do")==0)
    else        nodo  = _webdoc_hasopt(s, "nodo")
    if (cmdl0)  cmdl  = ((_webdoc_hasopt(s, "nocmdlog", 6)==0) &
                        (_webdoc_hasopt(s, "nolog")==0))
    else        cmdl  = _webdoc_hasopt(s, "cmdlog", 4)
    if (dos0)   dos   = (_webdoc_hasopt(s, "nodosave", 5)==0)
    else        dos   = _webdoc_hasopt(s, "dosave", 3)
}

/*---------------------------------------------------------------------------*/
/* helper function for processing Stata command lines                        */
/*---------------------------------------------------------------------------*/

// tokenize with "," as parsing character and "(...)" bound together
string rowvector webdoc_tokens(string scalar s)
{
    transmorphic t
    
    t = tokeninit(" ", ",", (`""""', `"`""'"', "()"), 0, 0)
    tokenset(t, s)
    return(tokengetall(t))
}

// check whether the words in s match m, where l specifies the minimum 
// abbreviation
real scalar webdoc_cmdmatch(string rowvector s, string rowvector m,
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
string scalar webdoc_read_cmd(
    string colvector f,
    real scalar i,
    real scalar r,
    real scalar inmata) 
{
    real scalar   lb, cb
    string scalar s
    
    lb = cb = 0
    s = webdoc_strip_comments(subinstr(f[i], char(9), " "), lb, cb, inmata)
    while (lb | cb) {
        if (i==r) break
        i++
        s = s + webdoc_strip_comments(subinstr(f[i], char(9), " "), 
                lb, cb, 1)
    }
    return(s)
}

// preprocessor for Stata command line: strips from s all comments ("* ...", 
// "/* ... */", "//...", "///...") taking account of quotes ("...", `"..."')
string scalar webdoc_strip_comments(
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
real scalar webdoc_cut(
    string colvector f,      // colvector containing source
    real colvector   p,      // selection vector for lines of f
    real scalar      a,      // first line of command
    real scalar      b,      // last line of command
    string scalar    t,      // target token after which to cut command
    real scalar      l,      // minimum length of t (abbreviation)
    string scalar    prefix, // prefix (indentation)
    real scalar      log)    // input is log file (length of log prefix)
{
    string scalar s, tok
    real scalar   j, i, cb, par, hit

    cb = par = hit = 0; tok = ""
    for (j=a; j<=b; j++) {
        if (log) s = substr(f[j], log, .)
        else     s = subinstr(f[j], char(9), " ")
        i = webdoc_locate_next(s, t, l, tok, cb, par, hit)
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
real scalar webdoc_locate_next(
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
real scalar webdoc_locate_lb(string scalar s, real scalar cb)
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
real scalar webdoc_locate_comma(string scalar s, real scalar cb, real scalar par)
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

// insert comment tags into command line
void webdoc_tag_comments(string colvector f, real scalar a0, real scalar i,
    real scalar mata, real scalar log, string scalar start, 
    string scalar stop)
{
    real scalar lb, cb, a

    lb = cb = 0
    for (a=a0; a<=i; a++) {
        _webdoc_tag_comments(f, a, lb, cb, (a==a0? mata : 1), log + log*(a>a0), 
            start, stop)
    }
}
void _webdoc_tag_comments(string colvector f, real scalar a, real scalar lb,
    real scalar cb, real scalar nostar, real scalar log, string scalar start,
    string scalar stop)
{
    real scalar     i, j, wd, dq, cdq
    string scalar   c, s, SL, ST, BL, DQ, BQ, EQ
    
    lb = dq = cdq = 0
    // setup
    if (log) { 
        if (log==1) j = strpos(f[a],". ") + 1 // first line starts with . " or "  #. "
        else        j = 5 // following lines start with "&gt; "
        s = substr(f[a], j+1, .)
    }
    else {
        j = 0
        s = subinstr(f[a], char(9), " ")
    }
    // handle comment-only lines
    if (!cb) {
      c = strltrim(s)
      // check whether line starts with "*..."
      if (!nostar) {
          if (substr(c,1,1)=="*") {
              j = strpos(f[a],"*")
              f[a] = substr(f[a], 1, j-1) + start + substr(f[a], j, .) + stop
              return
          }
      }
      // check whether line starts with "//..." or "///..."
      if (substr(c,1,2)=="//") {
          if (substr(c,3,1)=="/") lb = 1
          j = strpos(f[a],"/")
          f[a] = substr(f[a], 1, j-1) + start + substr(f[a], j, .) + stop
          return
      }
    }
    // insert start tag if open inline comment
    else {
        f[a] = substr(f[a], 1, j) + start + substr(f[a], j+1, .)
        j = j + strlen(start)
    }
    // handle rest    
    SL = "/"; ST = "*"; BL = " "; DQ = `"""'; BQ = "`"; EQ = "'"
    wd = strlen(s)
    for (i=1; i<=wd; i++) {
        j++
        c = substr(s,i,1)
        // within /*...*/
        if (cb) {
            // look for end tag
            if (c==ST) {
                if (substr(s,i+1,1)==SL) {
                    i++; j++; cb--
                    if (!cb) {  // insert stop tag
                        f[a] = substr(f[a], 1, j) + stop + substr(f[a], j+1, .)
                        j = j + strlen(stop)
                    }
                }
            }
            // look for nested start tag
            else if (c==SL) {
                if (substr(s,i+1,1)==ST) {
                    i++; j++; cb++
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
                f[a] = substr(f[a], 1, j-1) + start + substr(f[a], j, .)
                j = j + strlen(start)
                i++; j++; cb++; continue
            }
            // look for // or ///
            else if (substr(s,i-1, 1)==BL) {
                if (substr(s,i+1,1)==SL) {
                    if (substr(s,i+2,1)==SL) lb = 1
                    f[a] = substr(f[a], 1, j-1) + start + 
                           substr(f[a], j, .) + stop
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
    if (cb) f[a] = f[a] + stop
}

/*---------------------------------------------------------------------------*/
/* file I/O helper functions                                                 */
/*---------------------------------------------------------------------------*/

// create a Mata global to be used as file handle later on; based on 
// suggestion by W. Gould; allows closing open file handles on error or break
void webdoc_instance_fh(string scalar macname)
{
    real scalar   i
    string scalar fullname
    
    for (i=1; 1; i++) {
        fullname = sprintf("%s%g", "WebDoc_fh_", i)
        if (crexternal(fullname) != NULL) {
            st_local(macname, fullname)
            return
        }
    }
}

// close file handle if existing
void webdoc_closeout_fh(real scalar fh)
{
    if (fh!=.) (void) _fclose(fh)
}

// create folder
void webdoc_mkdir(string scalar path)
{
    if (direxists(path)==0) {
        mkdir(path)
        printf("{txt}(directory '%s' created)\n", path)
    }
}

// read file; simplified cat() with file handle argument
string colvector _webdoc_cat(string scalar filename, real scalar fh)
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
string colvector _webdoc_catnl(string scalar filename, real scalar fh)
{       // same as _webdoc_cat(), but does not remove new-line characters
        // explanation: fget() breaks lines longer than 32,768 characters into 
        //              multiple lines; to make an exact copy of a file with 
        //              long lines, read the file by _webdoc_catnl() and then 
        //              write it out by _webdoc_fwrite(); using _webdoc_cat()
        //              followed by _webdoc_put() would result in a file with 
        //              broken lines
        real scalar             i, n
        string matrix           EOF
        string colvector        res
        string scalar           line

        EOF = J(0, 0, "")
        fh  = fopen(filename, "r")
        // count lines
        i = 0
        while (1) {
            if (fgetnl(fh)==EOF) break
            i++ 
        }
        res = J(n = i, 1, "")
        // read file
        fseek(fh, 0, -1)
        for (i=1; i<=n; i++) {
                if ((line=fgetnl(fh))==EOF) {
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
void webdoc_fput(string scalar fn, real scalar fh, string colvector s, 
    string scalar mode, real scalar replace)
{   // replace: 1=replace, 2=certify
    if (replace) {
        if (replace==2) webdoc_fput_certify(fn, fh, s)
        webdoc_fopen_replace(fn, fh, mode)
    }
    else fh = fopen(fn, mode)
    _webdoc_fput(fh, s)
    fclose(fh)
}
void _webdoc_fput(real scalar fh, string colvector s)
{
    real scalar i
    
    for (i=1; i<=rows(s); i++) {
        fput(fh, s[i])
    }
}
void _webdoc_fwrite(real scalar fh, string colvector s)
{   // to be used if s contains new-line characters
    real scalar i
    
    for (i=1; i<=rows(s); i++) {
        fwrite(fh, s[i])
    }
}

// check whether preexisting file is identical to new file
void webdoc_fput_certify(string scalar fn, real scalar fh, string colvector s)
{
    if (s!=_webdoc_cat(fn, fh)) {
        webdoc_fput(fn+"_new", fh, s, "w", 1)
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
void webdoc_fopen_replace(string scalar fn, real scalar fh, string scalar mode)
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
