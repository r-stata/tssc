*! version 1.0.1  26feb2009  Ben Jann

program tr
    version 8.2
    local caller : di _caller()

    foreach c in trace tracedepth tracesep traceindent ///
        traceexpand tracenumber tracehilite {
        local `c' `"`c(`c')'"'
    }
    if `"`tracehilite'"'!="" {
        // c(tracehilite) does not include the search string in quotes, which
        // causes problems; below is a fix that works unless the string
        // expression length limit is exceeded or the search string
        // ends with ", word"
        if substr(`"`tracehilite'"',-6,.)==", word" local hihasword 1
        else local hihasword 0
        if `hihasword' {
            local l = length(`"`tracehilite'"')
            local tracehilite = substr(`"`tracehilite'"', 1, `l'-6)
            local tracehilite `"`"`tracehilite'"', word"'
        }
        else {
            local tracehilite `"`"`tracehilite'"'"'
        }
    }

    nobreak {
        capture break noisily version `caller': _trace `macval(0)'
        local rc = _rc

        foreach c in trace tracedepth tracesep traceindent ///
            traceexpand tracenumber tracehilite {
            capt set `c' ``c''
        }
    }
    if `rc' {
        exit `rc'
    }
end

program _trace
    version 8.2
    local caller : di _caller()

    // syntax
    gettoken 0 cmdline : 0, parse(":") bind quotes
    if `"`0'"'==":" {
        local 0 ""
    }
    else {
        gettoken colon cmdline : cmdline, parse(":")
        if `"`colon'"' != ":" {
                di as err "'' found were ':' expected"
                exit 198
        }
    }
    syntax [ anything(name=depth id="tracedepth") ] [ , ///
        NOMore More                                     ///
        NOExpand Expand NOSep Sep NOIndent Indent       ///
        NONumber Number NOHilite Hilite(str asis) ]

    // set trace and run command
    if `"`depth'"'!="" {
        set tracedepth `depth'
    }
    foreach c in sep indent expand number {
        if "`no`c''"!="" {
            if "``c''"!="" {
                di as err "no`c' and `c' not both allowed"
                exit 198
            }
            set trace`c' off
        }
        if "``c''"!="" {
            set trace`c' on
        }
    }
    if "`nohilite'"!="" {
        if `"`macval(hilite)'"'!="" {
            di as err "nohilite and hilite() not both allowed"
            exit 198
        }
        set tracehilite ""
    }
    if `"`macval(hilite)'"'!="" {
        capt set tracehilite `macval(hilite)'
        if _rc {
            di as err "hilite() invalid"
            exit 198
        }
    }
    if "`nomore'"!="" {
        if "`more'"!="" {
            di as err "nomore and more not both allowed"
            exit 198
        }
        set more off
    }
    if "`more'"!="" {
        set more on
    }
    version `caller'
    set trace on
    `macval(cmdline)'
end
