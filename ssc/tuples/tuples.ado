*! 4.0.1 Joseph N. Luchman, daniel klein, & NJC 16 May 2020
*  4.0.0 Joseph N. Luchman, daniel klein, & NJC 1 May 2020
*  3.4.1 Joseph N. Luchman, daniel klein, & NJC 14 January 2020
*  3.4.0 Joseph N. Luchman, daniel klein, & NJC 9 January 2020
*  3.3.1 Joseph N. Luchman, daniel klein, & NJC 20 December 2018
*  3.3.0 Joseph N. Luchman, daniel klein, & NJC 17 February 2016
*  3.2.1 Joseph N. Luchman 3 March 2015
*  3.2.0 Joseph N. Luchman 16 January 2015
*  3.1.0 Joseph N. Luchman 20 March 2014
*  3.0.1 NJC 1 July 2013
*  3.0.0 Joseph N. Luchman & NJC 22 June 2013
*  2.1.0 NJC 26 January 2011 
*  2.0.0 NJC 3 December 2006 
*  1.0.0 NJC 10 February 2003
*  all subsets of 1 ... k distinct selections from a list of k items 
program tuples
    version 8
    
    if (c(stata_version) >= 10) {
        version 10
        local version10_options                                  ///
              CONDitionals(string)                               ///
              NCR /* or */ CVP /* or */ KRONECKER /* or */ NAIVE ///
              noMata                                             ///
              SEEMATA                                       // debug
        if (c(stata_version) >= 16) {
            version 16                
            tuples_assert_python // puts python path into py_path
            if (`"`py_path'"' == "") local python nopython
            /* not else */ local version16_options noPYthonopt
            // yes, we call it -noPYthonOPT; see comment below
        }
        else local python nopython
    }
    else {
        local python nopython
        local mata   nomata
    }
    
    syntax anything(id = "list")     ///
    [ ,                              ///
        ASIS /* or */ VARlist        ///
        MAX(numlist max=1 integer>0) ///
        MIN(numlist max=1 integer>0) ///
        DIsplay                      ///
        noSort                       ///
        LMACNAME(name local)         /// not documented
        `version10_options'          ///
        `version16_options'          ///
    ]
    
    tuples_opts_incompatible `asis' `varlist'
    tuples_opts_incompatible `sort' `kronecker' `cvp' `ncr'
    tuples_opts_incompatible `mata' `naive' `kronecker' `cvp' `ncr'
    
    if ( ("`naive'" != "") & ("`sort'" != "nosort") ) {
        display as err "option nosort required"
        exit 198
    }
    
    if (`"`conditionals'"' != "") {
        tuples_opts_incompatible conditionals() `mata' `naive'
        mata : tuples_assert_conditionals()
    }
    
    if ("`asis'" == "") {
        if ("`varlist'" == "") local capture capture
        `capture' unab anything : `anything'
    }
    
    tokenize `"`anything'"'
    local n : word count `anything'
    
    if ("`max'" == "") local max = `n'
    else if (`max' > `n') {
        display as txt "maximum reset to number of items " as res `n'
        local max = `n'
    }
    
    if ("`min'" == "") local min = 1
    else if (`min' > `max') {
        display as txt "minimum reset to maximum " as res `max'
        local min = `max'
    }
    
    if ("`ncr'`cvp'`kronecker'`naive'" != "") local python nopython
    
    /* 
        option nopythonopt was included so that users of version 16
        may specify option -nopython- regardless of whether they 
        have a -python script--able version of Python installed
    */
    if ("`pythonopt'" == "nopythonopt") local python nopython
    
    if ("`lmacname'" == "") local lmacname tuple
    else if ( (`"`py_path'"' != "") & ("`python'" != "nopython") ) {
        display as err "option lmacname() not allowed"
        exit 198
    }
    else confirm name _n`lmacname's
    
    
    if ("`python'" != "nopython") {
        python script `"`py_path'"' ///
            , args(`min' `max' "`conditionals'" "`sort'" "`display'" `anything')                   
        // done
    }

    else if ("`mata'" != "nomata") {
        mata : tuples()
        // done
    }
    
    else {
        // Stata based implemenation
        if ("`display'" == "") local continue continue
        local N = 2^`n'-1
        local k = 0
        if ("`sort'" == "nosort") {
            // faster variation of original algorithm
            forvalues i = 1/`N' {
                quietly inbase 2 `i'
                local indicators : display %0`n'.0f `r(base)'
                local one 0
                local tuple // void
                forvalues j = 1/`n' {
                    if (substr("`indicators'", `j', 1) == "1") {
                        if (`++one'>`max') continue , break
                        if (`one'>1) local tuple `"`tuple' ``j''"'
                        else         local tuple         `"``j''"'
                    }
                }
                if (`one'<`min') | (`one'>`max') continue
                c_local `lmacname'`++k' `"`tuple'"'
                `continue'
                display as res "`lmacname'`k': " as txt `"`tuple'"'
            }
            // the number of tuples is returned below
        }
        else {
            // original algorithm
            forval I = `min'/`max' { 
                forval i = 1/`N' { 
                    qui inbase 2 `i'
                    local which `r(base)' 
                     local nzeros = `n' - `: length local which' 
                    local zeros : di _dup(`nzeros') "0" 
                    local which `zeros'`which'  
                    local which : subinstr local which "1" "1", all count(local n1) 
                    if `n1' == `I' {
                        local out
                        local space // void
                        forval j = 1 / `n' { 
                            local char = substr("`which'",`j',1) 
                            if `char' {
                                local out `"`out'`space'``j''"'
                                local space " "
                            }
                        }
                        c_local `lmacname'`++k' `"`out'"'
                        `continue'
                        display as res "`lmacname'`k': " as txt `"`out'"'
                    }   
                }
            } // end original algorithm
        } // Stata based implementation
        c_local n`lmacname's `k'
    }
end

program tuples_assert_python
    tempname rr
    _return hold `rr'
    capture python query
    if ( !_rc ) { 
        capture findfile st_tuples_py.py 
        local py_path `"`r(fn)'"'
    }
    _return restore `rr'
    c_local py_path : copy local py_path
end

program tuples_opts_incompatible
    if ( mi("`2'") ) exit
    display as err "options `1' and `2' may not be combined"
    exit 198
end

if (c(stata_version) < 10) exit

version 10

local Tuples  struct tuples__ scalar

local RS      real   scalar
local RM      real   matrix
local RR      real   rowvector

local SS      string scalar
local SR      string rowvector

local Boolean `RS'

mata :

mata set matastrict on

struct tuples__ {
    `SR'      list
    `RS'      min
    `RS'      max
    `SS'      conditionals
    `Boolean' is_display
    `Boolean' is_ncr    
    `Boolean' is_cvp
    `Boolean' is_kronecker
    `Boolean' is_naive
    `Boolean' is_sort
    `Boolean' is_debug
    `SS'      lmacname
    `RS'      n
    `RM'      indicators
    `RS'      ntuples
}

void tuples()
{
    `Tuples' T
    
    T.list         = tokens(st_local("anything"))
    T.min          = strtoreal(st_local("min"))
    T.max          = strtoreal(st_local("max"))
    T.conditionals = st_local("conditionals")
    T.is_display   = st_local("display")=="display"
    T.is_sort      = st_local("sort")!="nosort"
    T.is_ncr       = st_local("ncr")=="ncr"
    T.is_cvp       = st_local("cvp")=="cvp"
    T.is_kronecker = st_local("kronecker")=="kronecker"
    T.is_naive     = st_local("naive")=="naive"
    T.is_debug     = st_local("seemata")=="seemata"
    T.lmacname     = st_local("lmacname")
    T.n            = cols(T.list)
    T.ntuples      = 0
    
    if ( T.is_naive )                    tuples_naive( T )
    else if ( T.is_ncr ) {
        if (T.conditionals == "")          tuples_ncr( T )
        else                          tuples_ncr_cond( T )
    }
    else {
        if ( T.is_kronecker )        tuples_kronecker( T )
        else if ( T.is_cvp)                tuples_cvp( T )
        else                           tuples_default( T )
        if (T.conditionals != "") tuples_conditionals( T )
        tuples_return( T )
    }
}

void tuples_default(`Tuples' T)
{
    `RS' N, i, csum
    
    if ( T.is_debug ) tuples_debug_print_begin("default")
    
    T.indicators = J(T.n, (N=2^T.n), .)
    for (i=1; i<=T.n; ++i) {
            T.indicators[i, ] = J(1, 2^(i-1), (J(1, (N=N/2), 0), J(1, N, 1)))
            if (T.is_debug) T.indicators
    }
    if ( (T.min>1)|(T.max<T.n) ) {
        csum = colsum(T.indicators)
        T.indicators = select(T.indicators, (csum:>=T.min:&csum:<=T.max))
    }
    else T.indicators = T.indicators[|., 2\ ., .|]
    if ( (T.n>2)&(T.is_sort) ) {
        T.indicators = (colsum(T.indicators)\ T.indicators)'
        T.indicators = sort(T.indicators, (1..cols(T.indicators)))
        T.indicators = T.indicators[|1, 2\ ., .|]'
    }
    
    if ( !T.is_debug ) return
    T.indicators
    tuples_debug_print_end("default")
}

void tuples_cvp(`Tuples' T)
{
    `RS'                i, j
    `RM'                base, combin
    transmorphic scalar info
    
    if ( T.is_debug ) tuples_debug_print_begin("cvp")
    
    for (i=T.min; i<=T.max; ++i) {
        base = J(i, 1, 1)\ J(T.n-i, 1, 0)
        info = cvpermutesetup(base)
        for (j=1; j<=comb(T.n, i); ++j) {
            combin = cvpermute(info)
            if ( (j>1)|(i>T.min) ) T.indicators = (T.indicators, combin)
            else                   T.indicators =                combin
            if ( T.is_debug ) T.indicators
        }
    }
    if ( T.is_debug ) tuples_debug_print_end("cvp")
}

void tuples_kronecker(`Tuples' T)
{
    `RM' base, combin, OneComb_x_Base, CombOne_x_Base
    `RS' i
    
    if ( T.is_debug ) tuples_debug_print_begin("kronecker")

    base = combin = I(T.n)
    if (T.min==1) T.indicators = uniqrows(base) 
    for (i=2; i<=T.max; ++i) {
        if (i < T.n) {
            OneComb_x_Base = J(1, cols(combin), 1)#base
            CombOne_x_Base = combin#J(1, cols(base), 1)
            combin = uniqrows((
                         select(  OneComb_x_Base:+CombOne_x_Base, 
                         !colsum((OneComb_x_Base:+CombOne_x_Base):==2) )
                     )')'
        }
        else combin = J(T.n, 1, 1)
        if (i > T.min) T.indicators = (T.indicators, combin)
        else           T.indicators =                combin
        if ( T.is_debug ) T.indicators
    }
    if ( !T.is_debug ) return
    T.indicators
    tuples_debug_print_end("kronecker")
}

void tuples_return(`Tuples' T)
{
    `RS' i
    
    if ( T.is_debug ) {
        tuples_debug_print_begin("return")
        T.indicators
        T.list
    }
    T.ntuples = cols(T.indicators)
    for (i=1; i<=T.ntuples; ++i) {
        tuples_c_local(T, i, select(T.list, T.indicators[, i]'))
    }
    tuples_c_local_ntuples( T )
    
    if ( !T.is_debug ) return
    tuples_debug_print_end("return")
}

void tuples_naive(`Tuples' T)
{
    `RS' N, i, len, rsum
    `SR' b
    
    if ( T.is_debug ) tuples_debug_print_begin("naive")
    
    N = 2^T.n-1
    for (i=1; i<=N; ++i) {
        b = inbase(2, i)
        if ( (len=T.n-strlen(b)) ) b = ("0"*len+b)
        b = subinstr(subinstr(b, "1", " 1 "), "0", " 0 ")
        T.indicators = strtoreal(tokens(b))
        if ( (T.min>1)|(T.max<T.n) ) {
            rsum = rowsum(T.indicators)
            if ( (rsum<T.min)|(rsum>T.max) ) continue
        }
        if ( T.is_debug ) T.indicators
        tuples_c_local(T, ++T.ntuples, select(T.list, T.indicators))
    }
    tuples_c_local_ntuples( T )
    
    if ( T.is_debug ) tuples_debug_print_end("naive")
}

void tuples_ncr(`Tuples' T)
{
    `RS' ntuples, r, nmr, i
    `RR' j
    
    T.ntuples = ntuples = rowsum(comb(T.n, (T.max..T.min)))
    
    r = T.max
    while (r >= T.min) {
        nmr = T.n-r
        j = ((i=1)..r)
        while ( i ) {
            while (i < r) j[i+1] = j[i++] + 1
            tuples_c_local(T, ntuples--, T.list[j])
            i = r
            while (j[i] >= nmr + i) if ( !(--i) ) break
            if ( i ) j[i] = j[i] + 1
        }
        --r
    }
    tuples_c_local_ntuples( T )
}

void tuples_ncr_cond(`Tuples' T)
{
    `RS' r, nmr, i
    `RR' j
    `RM' Tindicators
    `SS' Tconditionals
    
    Tindicators   = J(T.n, 1, 0)
    Tconditionals = T.conditionals
    
    r = T.max
    while (r >= T.min) {
        nmr = T.n-r
        j = ((i=1)..r)
        while ( i ) {
            while (i < r) j[i+1] = j[i++] + 1
            T.indicators    = J(T.n, 1, 0)
            T.indicators[j] = J(r, 1, 1)
            tuples_conditionals( T )
            Tindicators = (Tindicators, T.indicators)
            T.conditionals = Tconditionals
            i = r
            while (j[i] >= nmr + i) if ( !(--i) ) break
            if ( i ) j[i] = j[i] + 1
        }
        --r
    }
    T.indicators = Tindicators[, cols(Tindicators)..2]
    tuples_return( T )
}

void tuples_conditionals(`Tuples' T)
{
    `RR' nums
    `RS' x
    
    if ( T.is_debug ) {
        tuples_debug_print_begin("conditionals")
        T.conditionals
    }
    
    nums = J(1, cols(T.indicators), 1)
    T.conditionals = tokens(T.conditionals)
    for(x = 1; x <= cols(T.conditionals); x++) {
        if ( T.is_debug ) T.conditionals[x]
        nums = tuples_parse_condition(T, T.conditionals[x]):*nums
    }
    
    T.indicators = select(T.indicators, nums)
    
    if ( T.is_debug ) tuples_debug_print_end("conditionals")
}

`RR' tuples_parse_condition(`Tuples' T, `SS' conditions)
{

    `RR'                changes
    `SR'                condition
    `RS'                x, real_cond 
    transmorphic scalar t

    if ( T.is_debug ) tuples_debug_print_begin("parse_condition")
    
    t = tokeninit("", ("(", ")"))
    tokenset(t, conditions)
    condition = tokengetall(t)
    
    if (sum(strmatch(condition, "("):+strmatch(condition, ")")) == 1) { 
        errprintf("option conditionals() invalid\n")
        errprintf("{p 4 4 2}")
        errprintf("Illegal use of parentheses. Perhaps there are")
        errprintf(" extra spaces in a parentetical statement.")
        errprintf("{p_end}")
        exit(198)
    }

    if ((condition[1] == "(") & (condition[cols(condition)] == ")")) {
        conditions = invtokens(condition[2..cols(condition)-1])
    }
    
    t = tokeninit("", ("&", "!", "|"), ("()"))
    tokenset(t, conditions)
    condition = tokengetall(t)
    condition = select(condition, condition:!=" ")
        
    if (
        (max(editmissing(strtoreal(condition), -1))>rows(T.indicators)) 
        | (sum(strtoreal(condition):==0))
       ) {
        errprintf("option conditionals() invalid\n")
        errprintf("Statement '%s' ", invtokens(condition))
        errprintf("contains an illegal list element reference.\n")
        exit(198)
    }
    
    if ( T.is_debug ) condition
    
    if ( (cols(condition)>1) & T.is_debug ) {
        condition[1]
        printf("{txt}#1\n")
    }
    
        // first (and possibly only) column
    if (regexm(condition[1], "^\(")) {
        if ( T.is_debug ) {
            if   (cols(condition) == 1) printf("{txt}only one, pass..\n")
            else                        printf("{txt}..pass..\n")
        }
        changes = tuples_parse_condition(T, condition) // pass all columns
    }
    else if (regexm(condition[1], "[0-9]+")) {
        if (T.is_debug) printf("{txt}digit(s)\n")
        changes = T.indicators[strtoreal(condition[1]), .]
        if ( T.is_debug ) changes
    }
    else {
        changes = J(1, cols(T.indicators), 1)
        if ( T.is_debug ) changes
    }
    
    if (cols(condition) == 1) return(changes)
        
        // columns 2, 3, ...
    for(x = 2; x <= cols(condition); x++) {
        real_cond = strtoreal(condition[x])
        if ( T.is_debug ) {
            condition[x]
            printf("{txt}>#1\n")
        }
        if (regexm(condition[x], "^\(")) {
            if ( T.is_debug ) printf("{txt}pass!\n")
            if (condition[x-1] != "!") 
                changes = tuples_parse_condition(T, condition[x]):*changes
            else 
                changes = !tuples_parse_condition(T, condition[x]):*changes
            if ( T.is_debug ) changes
        }
        else if (regexm(condition[x], "[0-9]+")) {
            if ( T.is_debug ) printf("{txt}digit(s)\n")
            if ( T.is_debug ) condition[x-1]
            if (condition[x-1] == "&") {
                if ( T.is_debug ) printf("{txt}&\n")
                changes = T.indicators[real_cond, .]:*changes
                if ( T.is_debug ) changes
            }
            else if (condition[x-1] == "|") {
                if ( T.is_debug ) printf("{txt}|\n")
                changes = sign(T.indicators[real_cond, .]:+changes)
                if ( T.is_debug ) changes
            }
            else if (condition[x-1] == "!") {
                if ( T.is_debug ) printf("{txt}!\n")
                if (x >= 3) {
                    if (condition[x-2] == "&") {
                        if ( T.is_debug ) printf("{txt}&\n")
                        changes = !T.indicators[real_cond, .]:*changes
                        if ( T.is_debug ) changes
                    }
                    else if (condition[x-2] == "|")  {
                        if ( T.is_debug ) printf("{txt}|\n")
                        changes = sign(!T.indicators[real_cond, .]:+changes)
                        if ( T.is_debug ) changes
                    }
                }
                else {
                    if ( T.is_debug ) printf("{txt}!\n")
                    changes = !T.indicators[real_cond, .]
                    if ( T.is_debug ) changes
                }
            }
        }
    }
    
    if ( T.is_debug ) tuples_debug_print_end("parse_condition")
    
    return(changes)
}

void tuples_c_local(`Tuples' T, `RS' i, `SR' el)
{
    st_local(T.lmacname, invtokens(el))
    stata(sprintf("c_local %s%f : copy local %s", T.lmacname, i, T.lmacname))
    if ( !T.is_display ) return
    printf("{res}%s%f: {txt}%s\n", T.lmacname, i, st_local(T.lmacname))
}

void tuples_c_local_ntuples(`Tuples' T)
{
    stata(sprintf("c_local n%ss %f", T.lmacname, T.ntuples))
}

void tuples_debug_print_begin(`SS' fcn)
{
    printf("{txt}{hline 1} begin tuples_%s() {hline}\n", fcn)
}

void tuples_debug_print_end(`SS' fcn)
{
    printf("{txt}{hline 1} end tuples_%s() {hline}\n", fcn)
}

void tuples_assert_conditionals()
{
    `RS' checksum
    checksum = sum(
                   J(16, 1, ascii(st_local("conditionals")))
                   :==(ascii(" 0123456789()!&|")')
                  )
    if (checksum == strlen(st_local("conditionals"))) return
    errprintf("option conditionals() invalid\n")
    errprintf("{p 4 4 2}")
    errprintf("You specified illegal characters. Only digits ")
    errprintf("({bf:0123456789}), spaces ( ), ampersands ({bf:&}), ")
    errprintf("vertical bars ({bf:|}), exclamation marks ({bf:!}), ")
    errprintf("and parentheses ({bf:()}) are allowed.")
    errprintf("{p_end}")
    exit(198)
}

end
exit
