*! version 3.8.0 18jun2020 daniel klein
// -------------------------------------- elabel.mata
version 11.2

// -------------------------------------- elabel version
local elabel_version 3.8.0
local stata_version  `c(stata_version)'
local date_time      "`c(current_date)' `c(current_time)'"

// -------------------------------------- Mata type declarations
local S            scalar
local R            rowvector
local C            colvector
local M            matrix
local V            vector

local TS           transmorphic `S'
local TR           transmorphic `R'
local TC           transmorphic `C'
local TM           transmorphic `M'
local TV           transmorphic `V'

local RS           real `S'
local RR           real `R'
local RC           real `C'
local RM           real `M'
local RV           real `V'

local SS           string `S'
local SR           string `R'
local SC           string `C'
local SM           string `M'
local SV           string `V'

local Boolean      `RS'
local BooleanR     `RR'
local BooleanC     `RC'
local BooleanM     `RM'
local BooleanV     `RV'
local True           1
local False          0

local voidTS       `TM'
local voidTR       `TM'
local voidTC       `TM'
local voidTM       `TM'
local voidRS       `TM'
local voidRR       `TM'
local voidRC       `TM'
local voidRM       `TM'
local voidSS       `TM'
local voidSR       `TM'
local voidSC       `TM'
local voidSM       `TM'
local voidBoolean  `TM'
local voidBooleanC `TM'
local voidBooleanR `TM'
local voidBooleanM `TM'
local voidBooleanV `TM'

// -------------------------------------- hidden/historical r()
if (c(stata_version) > 11.2) {
    local amp_sca_hcat , &st_numscalar_hcat(name[i])
    local amp_mac_hcat , &st_global_hcat(name[i])
    local amp_mat_hcat , &st_matrix_hcat(name[i])
    local ast_sca_hcat , (*(*rr.sca[i])[3])
    local ast_mac_hcat , (*(*rr.mac[i])[3])
    local ast_mat_hcat , (*(*rr.mat[i])[5])
}

// -------------------------------------- Mata settings
mata :

mata set matastrict   on
mata set mataoptimize on

end

// -------------------------------------- Mata class declarations
mata :

// -------------------------------------- Elabel Utilities
class Elabel_Utilities
{
    public :
        void                 final u_assert0()
        `voidBoolean'        final u_assert_lblname()
        `voidBoolean'        final u_assert_name()
        `voidBoolean' static final u_assert_newfile()
        `voidBoolean'        final u_assert_newlblname()
        `voidBoolean' static final u_assert_nosysmiss()
        `voidBoolean' static final u_assert_uniq()
        
        `SM'          static final u_bslsq()
        
        void          static final u_err_alreadydefined()
        void          static final u_err_expected()
        void          static final u_err_fewmany()
        void          static final u_err_notallowed()
        void          static final u_err_notfound()
        void          static final u_err_numlist()
        void          static final u_err_required()
        void          static final u_err_unbalanced()
        void          static final u_exerr()
        
        void          static final u_fput()
        
        `SS'                 final u_get_varvaluelabel()
        `SS'                 final u_get_varlabel()
        
        `SS'          static final u_invtoken()
        `Boolean'     static final u_iseexp()
        `Boolean'            final u_isgmappings()
        `Boolean'            final u_ispfcn()
        
        `TM'          static final u_selectnm()
        void          static final u_st_exe()
        void          static final u_st_syntax()
        `SS'          static final u_strip_wildcards()
        `SR'          static final u_st_numvarlist()
        
        `SS'                 final u_tokenget_inpar()
        `SR'          static final u_tokensq()
        
        `Boolean'     static final u_unabbr()
}
    
    // ---------------------------------- a
void Elabel_Utilities::u_assert0(| `SS' where)
{
    if (args())     where = sprintf(" in %s", where)
    u_exerr(42, "elabel: unexpected error%s", where)
}

`voidBoolean' Elabel_Utilities::u_assert_lblname(`SR' lblnamelist, | `RS' rc)
{
    `RS' n, i
    
    if ( (!(n=cols(lblnamelist)))|(lblnamelist=="") ) {
        if (!rc)                   return(`False') 
        u_exerr(7, "'' found where name expected")
    }
    for (i=1; i<=n; ++i) {
        if (rc)   u_assert_name(lblnamelist[i])
        else if ( !u_assert_name(lblnamelist[i], `False') ) return(`False')
        if ( st_vlexists(lblnamelist[i]) ) continue
        if (!rc)                           return(`False')
        u_err_notfound(lblnamelist[i])
    }
    if (!rc) return(`True')
}

`voidBoolean' Elabel_Utilities::u_assert_name(`SR' namelist, | `RS' rc)
{
    `RS' n, i
    
    if ( (!(n=cols(namelist)))|(namelist=="") ) {
        if (!rc)                   return(`False')
        u_exerr(7, "'' found where name expected")
    }
    for (i=1; i<=n; ++i) {
        if ( st_isname(namelist[i]) ) continue
        if (!rc)                      return(`False')
        u_exerr(198, "%s invalid name", namelist[i])
    }
    if (!rc) return(`True')
}

`voidBoolean' Elabel_Utilities::u_assert_newfile(`SS' filename, 
                                                 `RS' replace, 
                                               | `RS' rc)
{
    if (!rc) return( (!fileexists(filename)) | replace )
    if ( !fileexists(filename) & replace )
        printf("{txt}(note: file %s not found)\n", filename)
    else if ( fileexists(filename) & !replace) 
        u_exerr(602, "file %s already exists", filename)
}

`voidBoolean' Elabel_Utilities::u_assert_newlblname(`SR' lblnamelist, 
                                                  | `RS' rc)
{
    `RS' i
    
    if ( (!cols(lblnamelist))|(lblnamelist=="") ) {
        if (!rc)                   return(`False') 
        u_exerr(7, "'' found where name expected")
    }
    
    if (cols(lblnamelist) == 1) {
        if (rc) u_assert_name(lblnamelist)
        else if ( !u_assert_name(lblnamelist, `False') ) return(`False')
        if ( st_vlexists(lblnamelist) ) {
            if (!rc) return(`False')
            u_err_alreadydefined(lblnamelist)
        }
        if (!rc) return(`True')
    }
    else if (rc) {
        u_assert_uniq(lblnamelist, "new label")
        for (i=1; i<=cols(lblnamelist); ++i) 
            u_assert_newlblname(lblnamelist[i])
    }
    else {
        if ( !u_assert_uniq(lblnamelist, `False') ) return(`False')
        for (i=1; i<=cols(lblnamelist); ++i) {
            if ( !u_assert_newlblname(lblnamelist[i], `False') ) 
                return(`False')
        }
        return(`True')
    }
}

`voidBoolean' Elabel_Utilities::u_assert_nosysmiss(`RV' x, | `RS' rc)
{
    if (!rc) return( !anyof(x, .) )
    if ( anyof(x, .) ) exit(error(180))
}

`voidBoolean' Elabel_Utilities::u_assert_uniq(`SR' caller_list, | `TS' scnd)
{
    `SR' dup
    
    dup = adups(select(caller_list, (strtrim(caller_list):!="")))
    if (scnd == 0) return( !cols(dup) )
    if ( cols(dup) ) {
        if ( isstring(scnd) ) errprintf("%s ", scnd)
        errprintf("%s mentioned more than once\n", dup[1])
        exit( isstring(scnd) ? 110 : 198)
    }
}

    // ---------------------------------- b
`SM' Elabel_Utilities::u_bslsq(`SM' s)
{
    return( subinstr(s, char(96), char((92, 96))) )
}

    // ---------------------------------- e 
void Elabel_Utilities::u_err_alreadydefined(`SS' item, | `SS' what)
{
    if (args() < 2) what = "value label"
    errprintf("%s %s already defined\n", what, item)
    exit(110)
}

void Elabel_Utilities::u_err_expected(`SS' expected, | `SS' found)
{
    if (args() > 1) found = sprintf("'%s' found where ", found)
    errprintf("%s%s expected\n", found, expected)
    exit(198)
}

void Elabel_Utilities::u_err_fewmany(`RS' fewmany, `SS' what)
{
    if (!fewmany) return
    errprintf("too %s %s specified\n", ((fewmany<0) ? "few" : "many"), what)
    exit(198)
}

void Elabel_Utilities::u_err_notallowed(`SS' item, | `SS' what)
{
    if (item == "") return
    u_exerr(101, "%s not allowed", ((args()<2) ? item : what))
}

void Elabel_Utilities::u_err_notfound(`SS' item, | `SS' what)
{
    if (args() < 2) what = "value label"
    errprintf("%s %s not found\n", what, item)
    exit(111)
}

void Elabel_Utilities::u_err_numlist(| `RS' rc, `SS' nlist)
{
    if (args() < 1) rc = 121
    if (args() > 1) errprintf("%s -- ", nlist)
    exit(error(rc))
}

void Elabel_Utilities::u_err_required(`SS' item, `SS' what)
{
    if (item != "") return
    u_exerr(100, "%s required", what)
}

void Elabel_Utilities::u_err_unbalanced(`SS' par)
{
    if (!anyof(("(", ")"), par)) _error(3300)
    errprintf("unmatched %s parenthesis\n", (par == ")") ? "close" : "open")
    exit(132)
}

void Elabel_Utilities::u_exerr(`RS' rc, `SS' msg, | `TS' arg)
{
    if (args() < 3) errprintf("%s\n", msg)
    else          errprintf(msg+"\n", arg)
    exit(rc)
}

    // ---------------------------------- f
void Elabel_Utilities::u_fput(`RS' fh, `SS' s)
{
    `RS' rc
    if ( !(rc=_fput(fh, s)) ) return
    (void) _fclose(fh)
    exit( error(abs(rc)) )
}

    // ---------------------------------- g
`SS' Elabel_Utilities::u_get_varlabel(`TS' var, | `SS' lang)
{
    if (lang == "") return( st_varlabel(var) )
    
    u_assert_name(lang)
    if ( isstring(var) ) {
        if (_st_varindex(var) == .) u_err_notfound(var, "variable")
        return( st_global(sprintf("%s[_lang_v_%s]", var, lang)) )
        // NotReached
    }
    
    if ( !isreal(var) ) _error(3255)
    if ( (var<0) | (var>st_nvar()) ) _error(3300)
    
    return( st_global(sprintf("%s[_lang_v_%s]", st_varname(var), lang)) )
}

`SS' Elabel_Utilities::u_get_varvaluelabel(`TS' var, | `SS' lang)
{
    if (lang == "") return( st_varvaluelabel(var) )
    
    u_assert_name(lang)
    if ( isstring(var) ) {
        if (_st_varindex(var) == .) u_err_notfound(var, "variable")
        return( st_global(sprintf("%s[_lang_l_%s]", var, lang)) )
        // NotReached
    }
    
    if ( !isreal(var) ) _error(3255)
    if ( (var<0) | (var>st_nvar()) ) _error(3300)
    
    return( st_global(sprintf("%s[_lang_l_%s]", st_varname(var), lang)) )
}

    // ---------------------------------- i
`SS' Elabel_Utilities::u_invtoken(`SM' s)
{
    if (rows(s) > 1) _error(3202) 
    return( (cols(s) ? invtokens(u_selectnm(s, `False')) : "") )
}

`Boolean' Elabel_Utilities::u_iseexp(`SS' m, | `TM' r1)
{
    if ( !regexm(m, "^[ ]*=(.*)$") ) return(`False')
    r1 = regexs(1)
    return(`True')
}

`Boolean' Elabel_Utilities::u_isgmappings(`SS' m, | `TM' r1, `TM' r2)
{
    `TS' t
    `RS' rc
    
    if ( !regexm(m, "^[ ]*\(.*\)[ ]*\(.*\)[ ]*$") ) return(`False')
    
    pragma unset rc
    t = tokeninit()
        tokenset(t, m)
    r1 = u_tokenget_inpar(t, `False', rc)
    if (!rc) r2 = u_tokenget_inpar(t, `False', rc)
    if ( !rc & (strtrim(tokenrest(t))=="") ) return(`True')  
    r1 = r2 = J(1, 1, "")
    return(`False')
}

`Boolean' Elabel_Utilities::u_ispfcn(`SS' m,       `TM' fcn, 
                                     `TM' fargs, | `TM' rest)
{
    `TS' t
    `RS' rc
    
    if ( !regexm(m, "^[ ]*=[ ]*([_0-9A-Za-z]+)\(.*\)") ) return(`False')
    fcn = regexs(1)
    
    t =    tokeninit("", "(")
           tokenset(t, m)
    (void) tokenget(t)
    
    pragma unset rc
    fargs = u_tokenget_inpar(t, `False', rc)
    if (rc) {
        fcn = fargs = rest = J(1, 1, "")
        return(`False')
    }
    if ((rest=tokenrest(t)) != "") {
        if (args() < 4) fargs = (fargs+char(32)+rest)
        else if ( !(regexm(rest, "^[ ]*(if|iff)[ \(]+") |
                    regexm(rest, "^[ ]*(in |,)")) ) 
        u_exerr(198, "invalid %s", strtrim(rest))
    }
    
    if (!_stata("program list elabel_fcn_" + fcn, `True')) return(`True')
    if (!_stata("which elabel_fcn_"        + fcn, `True')) return(`True')
    
    u_exerr(133, "unknown elabel (pseudo-)function %s()", fcn)
}

    // ---------------------------------- s
`TM' Elabel_Utilities::u_selectnm(`TM' x, | `RS' asvec)
{
    if ( (cols(x)>1) & (rows(x)>1) )   _error(3201)
    if ( !cols(x) ) return( J(1, 0, missingof(x)) )
    if ( !rows(x) ) return( J(0, 1, missingof(x)) )
    if ( (!asvec & (x==missingof(x))) )   return(x)
    return( select(x, (x:!=missingof(x))) )
}

void Elabel_Utilities::u_st_exe(`SS' cmd, | `RS' nooutput)
{
    `RS' rc
    
    if (args() < 2) nooutput = 0
    if ( rc=_stata(cmd, nooutput) ) exit(rc)
}

void Elabel_Utilities::u_st_syntax(`SS' zero, 
                                 | `SS' descr_of_syntax, 
                                   `TM' rc)
{
    `SS' st_zero
    
    st_zero = st_local("0")
    st_local("0", zero)
    rc = _stata(("syntax "+descr_of_syntax), (args()>2))
    st_local("0", st_zero)
    if (args() > 2) return
    else if (rc)  exit(rc)
}

`SS' Elabel_Utilities::u_strip_wildcards(`SS' name, | `TM' haswc)
{
    `SS' valid
    valid = subinstr(subinstr(subinstr(name, "*", ""), "~", ""), "?", "_")
    if (args() > 1) haswc = (name != valid)
    return( valid )
}

`SR' Elabel_Utilities::u_st_numvarlist(`SS' varlist)
{
    `RS' rc
    
    pragma unset rc
    u_st_syntax(varlist, "varlist(numeric)", rc)
    if (!rc) return(tokens(st_local("varlist")))
    if (rc == 109) exit(error(181))
    u_st_syntax(varlist, "varlist(numeric)") // error
}

    // ---------------------------------- t
`SS' Elabel_Utilities::u_tokenget_inpar(`TS' t, | `RS' keeppar, `TM' rc)
{
    `SR' tchars
    `RS' popen
    `SS' c, inpar
    
    if (eltype(t) != "struct") _error(3261)
    
    tchars = (tokenwchars(t), tokenpchars(t))
    tokenwchars(t, " ")
    tokenpchars(t, ("(", ")"))
    
    inpar = ""
    if ( !(rc=((-1)*!(popen=(tokenpeek(t)=="(")))) ) {
        inpar = tokenget(t)
        tokenwchars(t, "")
        while ( (c=tokenget(t)) != "" ) {
            inpar = ( inpar + c )
            if      (c == "(") ++popen
            else if (c == ")") --popen
            if ( !(rc=popen) )   break
        }
        if ( !(rc|keeppar) ) inpar = substr(inpar, 2, (strlen(inpar)-2))
    }
    else if (args() < 3) 
        _error(3498, sprintf("%s found where ( expected", tokenpeek(t)))
        
    tokenwchars(t, tchars[1])
    if (cols(tchars) > 1) tokenpchars(t, tchars[|2\ .|])
    
    if ( (rc=sign(rc)*132) & (args()<3) ) u_err_unbalanced("(")
    
    return(inpar)
}

`SR' Elabel_Utilities::u_tokensq(`SS' s)
{
    `TS' t
    t = tokeninit(" ", J(1, 0, ""), J(1, 0, ""))
        tokenset(t, s)
    return( tokengetall(t) )
}

    // ---------------------------------- u
`Boolean' Elabel_Utilities::u_unabbr(`SS' abbr, `SS' full)
{
    `RS' len
    
    if ( !(len=strpos(full, ":")) ) return( (abbr==full) )
    return( (abbr==substr(subinstr(full, ":", "", 1), 
             1, (max(((--len), strlen(abbr)))))) )
}

// -------------------------------------- Elabel Options
class Elabel_Options__
{
    public :
            void      new()
            void      st_get()
            void      st_get_aa()
            void      st_get_mm()
            void      st_get_options()
            
            `Boolean' add()
            `Boolean' modify()
            `Boolean' replace()         
            `Boolean' fixfmt()
            `Boolean' nomem()
            `Boolean' current()
            `SS'      st_options()
            `SS'      printamrnf()
            `SS'      print_opts()
            `Boolean' aa()
            `Boolean' mm()
            `SS'      sep()
    
    private `Boolean' add
    private `Boolean' modify
    private `Boolean' replace    
    private `Boolean' fixfmt    
    private `Boolean' nomem
    private `Boolean' current
    private `SS'      st_options
    private `Boolean' aa
    private `Boolean' mm
    private `SR'      sep
}

void Elabel_Options__::new()
{
    add = modify = replace = `False'
    fixfmt                 = `True'
    nomem = current        = `False'
    aa = mm                = `False'
}

    // ---------------------------------- public functions
void Elabel_Options__::st_get()
{
    add        = (st_local("add")     == "add"     )
    modify     = (st_local("modify")  == "modify"  )
    replace    = (st_local("replace") == "replace" )
    fixfmt     = (st_local("fix")     != "nofix"   )
    nomem      = (st_local("memory")  == "nomemory")
    current    = (st_local("current") == "current" )
    
    if ( (add|modify) & replace ) {
        errprintf("option replace may not be combined")
        errprintf(" with option add or option modify\n")
        exit(198)
    }    
    
    add   = (add*(!modify))
    nomem = (nomem|current)
    
    st_get_options()
}

void Elabel_Options__::st_get_aa()
{
    if ( !(aa=(st_local("append") == "append")) ) return
    
    if (modify | replace) {
            errprintf("option append may not be combined ")
            errprintf("with option modify or option replace\n")
            exit(198)
    }
    else if ( !add ) {
            errprintf("option add required\n")
            exit(198)
    }
}

void Elabel_Options__::st_get_mm()
{
    mm  = (st_local("merge0") == "merge0")
    sep = tokens(st_local("merge"))
    if (mm & !cols(sep)) sep = char(32)
    else if (cols(sep) == 1) mm = `True'
    else if (cols(sep) ) {
        errprintf("option merge() invalid\n")
        exit(198)
    }
    
    if ( !mm ) return
    
    if ( replace ) {
        errprintf("option merge may not be combined with option replace\n")
        exit(198)
    }
    else if ( !modify ) {
        errprintf("option modify required\n")
        exit(198)
    }
}

void Elabel_Options__::st_get_options() st_options = st_local("options")

`Boolean' Elabel_Options__::add()     return( add     )
`Boolean' Elabel_Options__::modify()  return( modify  )
`Boolean' Elabel_Options__::replace() return( replace )
`Boolean' Elabel_Options__::fixfmt()  return( fixfmt  )
`Boolean' Elabel_Options__::nomem()   return( nomem   )
`Boolean' Elabel_Options__::current() return( current )

`SS' Elabel_Options__::st_options(| `RS' comma) 
{
    if (st_options == "") return(st_options)
    return( ((", "*(comma!=0)) + st_options) )
}

`SS' Elabel_Options__::printamrnf(| `RS' comma)
{    
    `SS' options
    if ( !(add|modify|replace|(!fixfmt)) )        return(J(1, 1, ""))
    options = (("add"*add) + ("modify"*modify) + ("replace"*replace))
    options = ( options + (" "*(options!="")) + ("nofix"*(!fixfmt)) )
    return( ((", "*(comma!=0)) + options) )
}

`SS' Elabel_Options__::print_opts(| `RS' comma)
{    
    if ( !(add|modify|replace|(!fixfmt)|(st_options!="")) ) return("")
    if ( !(add|modify|replace|(!fixfmt)) ) return( st_options(comma) )
    if (st_options=="")                    return( printamrnf(comma) )
    return( (printamrnf(comma) + char(32) + st_options(`False')) )
}

`Boolean' Elabel_Options__::aa()  return( aa  )
`Boolean' Elabel_Options__::mm()  return( mm  )
`SS'      Elabel_Options__::sep() return( sep )

// -------------------------------------- Elabel Rules
class Elabel_Rules__ extends Elabel_Utilities
{
    public :
            `voidSS'   set()
            `RC'       from()
            `RC'       to()
            `SC'       text()
            `BooleanC' null()
            `SS'       rules()
    
    private void       parse()
    private void       get_lhs()
    private void       get_rhs()
    private void       get_rhs_values()
    private void       get_rhs_labels()
    private void       test()
    
    private `SS'       zero
    private `RC'       from
    private `RC'       to
    private `SC'       text
    private `BooleanC' null
    private `SS'       rules
    
    private `TS'       t
    private `TS'       trhs
    private `RS'       nlhs
    private `RS'       nrhs
    private `Boolean'  parsed
}

    // ---------------------------------- public fuctions
`voidSS' Elabel_Rules__::set(| `SS' caller_rules)
{
    if ( !args() ) return(zero)
    
    zero   = caller_rules
    from   = J(0, 1, .z)
    to     = J(0, 1, .z)
    text   = J(0, 1, "")
    null   = J(0, 1, .z)
    rules  = J(1, 1, "")
    t      = tokeninit()
             tokenset(t, zero)
    trhs   = tokeninit("") 
    nlhs   = 0
    nrhs   = 0
    parsed = `False'
}

`RC' Elabel_Rules__::from()
{
    parse()
    return(from)
}

`RC' Elabel_Rules__::to()
{
    parse()
    return(to)
}

`SC' Elabel_Rules__::text()
{
    parse()
    return(text)
}

`BooleanC' Elabel_Rules__::null()
{
    parse()
    return(null)
}

`SS' Elabel_Rules__::rules()
{
    parse()
    if ( (rules=="") & (nlhs) & (nrhs) ) 
        rules = u_invtoken(("(":+strofreal(from):+"=":+strofreal(to):+")")')
    return(rules)
}

    // ---------------------------------- private functions        
void Elabel_Rules__::parse()
{
    if (parsed) return
    
    while (tokenpeek(t) != "") {
        get_lhs()
        get_rhs()
    }
    
    test()
    parsed = `True'
}

void Elabel_Rules__::get_lhs()
{
    `RS' vals
    `SS' lpar, lhs, eqs
    `RS' rc
   
    pragma unset vals
   
    tokenpchars(t, "(")
    if ((lpar=tokenget(t)) != "(") u_err_expected("(", lpar)
   
    tokenwchars(t, "")
    tokenpchars(t, "=")
    
    lhs = tokenget(t)
    if ((eqs=tokenget(t)) != "=")          u_err_expected("=", eqs)
    if ( (rc=_elabel_numlist(vals, lhs)) ) u_err_numlist(rc, lhs)
    if ( !(nlhs=rows(vals)) )              u_err_numlist(122, lhs)
    from = (from\ vals)
   
    tokenwchars(t, " ")
    tokenpchars(t, "")
}

void Elabel_Rules__::get_rhs()
{
    `RS' rc
    `SS' rhs
    
    pragma unset rc
    
    tokenset(t, ("("+tokenrest(t)))
    rhs = u_tokenget_inpar(t, `False', rc)
    if (rc) u_exerr(132, "%s\nunmatched open parenthesis", rhs)
    
    tokenset(trhs, rhs)
    get_rhs_values(trhs)
    get_rhs_labels(trhs)
}

void Elabel_Rules__::get_rhs_values(`TS' trhs)
{
    `RS' rc
    `RC' vals
    
    pragma unset vals
    
    tokenwchars(trhs, "")
    if ( (rc=_elabel_numlist(vals, tokenpeek(trhs))) ) {
        tokenwchars(trhs, " ")
        if ( (rc=_elabel_numlist(vals, tokenpeek(trhs))) )
            u_err_numlist(rc, tokenget(trhs))
    }
    
    if ( ((nrhs=rows(vals))!=1) & (nrhs!=nlhs) ) 
        u_err_numlist(122+(nrhs>nlhs), tokenget(trhs))
    (void) tokenget(trhs)
    to = (to\ ((nrhs==1) ? J(nlhs, 1, vals) : vals))
}

void Elabel_Rules__::get_rhs_labels(`TS' trhs)
{
    `RS'       offset
    `SC'       _text
    `BooleanC' _null
    
    pragma unset _text
    pragma unset _null
    
    tokenwchars(trhs, " ")
    offset = tokenoffset(trhs)
    while (tokenpeek(trhs) != "") {
        _null = (_null\ anyof((`""""', `"`""'"'), tokenpeek(trhs)))
        _text = (_text\ invtokens(tokens(tokenget(trhs))))
    }
    tokenoffset(trhs, offset)
    
    if ( !rows(_text) ) {
        _text = J(nlhs, 1, "")
        _null = J(nlhs, 1, `False')
    }
    else if (rows(_text) == 1) {
        _text = J(nlhs, 1, _text)
        _null = J(nlhs, 1, _null)
    }
    else if (rows(_text) < nrhs) 
        u_exerr(198, "%s\ntoo few labels specified", tokenrest(trhs))
    else if (rows(_text) > nrhs)
        u_exerr(198, "%s\ntoo many labels specified", tokenrest(trhs))
    
    text = (text\ _text)
    null = (null\ _null)    
}

void Elabel_Rules__::test()
{
    `RC' uniq
    `RS' nrow, i
    
    if ( (nrow=rows((uniq=uniqrows(from)))) != rows(from) ) {
        for (i=1; i<=nrow; ++i) {
            if (rows(uniqrows(select(to, (from:==uniq[i]))))==1) continue
            u_exerr(198, "value %f mapped to more than one value", uniq[i])
        }
    }
    if ( (nrow=rows((uniq=uniqrows(to)))) != rows(to) ) {
        for (i=1; i<=nrow; ++i) {
            if (rows(uniqrows(select(text, (to:==uniq[i]))))==1) continue
            u_exerr(198, "value %f mapped to more than one label", uniq[i])
        }
    }
}

// -------------------------------------- Elabel eExp
class Elabel_eExp extends Elabel_Utilities
{
    public :
              void      new()
        
              `voidTC'  eexp()
              void      wildcards()
              `RC'      hash()
              `SC'      at()
              `SC'      atbs()
              `Boolean' hashash()
              `Boolean' hasat()

              `SS'      eexp_asis()
              `RS'      get_rc()

    private   void      set_eexp()
    private   `TC'      get_eexp()
    private   `TS'      get_eexp_scalar()
    
    private   `RC'      hash
    private   `SC'      at
    private   `SC'      atbs
    private   `Boolean' hashash
    private   `Boolean' hasat
    private   `SS'      asis
    protected `SR'      eexp_vector
    private   `TC'      eexp_expand
}

void Elabel_eExp::new()
{
    hash        = .
    at = atbs   = ("")
    hashash     = `False'
    hasat       = `False'
    eexp_vector = J(1, 0, "")
    eexp_expand = J(0, 1, .z)
}

    // ---------------------------------- public functions
`voidTC' Elabel_eExp::eexp(| `SS' caller_eexp)
{
    if      ( args() )             set_eexp(caller_eexp)
    else if (  rows(eexp_expand) ) return(eexp_expand)
    else if ( !cols(eexp_vector) ) return( (eexp_expand="") )
    else                           return( get_eexp() )
}

void Elabel_eExp::wildcards(`RC' caller_hash, `SC' caller_at)
{
    `RR' Rows
    
    Rows = (rows(caller_hash), rows(caller_at))
    if ( !all(Rows) )                          _error(3300)
    if ( (Rows[1]!=Rows[2]) & (min(Rows)!=1) ) _error(3200)
    
    hash = (Rows[1]>1) ? caller_hash : J(Rows[2], 1, caller_hash)
    at   = (Rows[2]>1) ? caller_at   : J(Rows[1], 1, caller_at  )
    atbs = u_bslsq(at)
    
    eexp_expand = J(0, 1, .z)
}

`RC'      Elabel_eExp::hash()      return(hash)
`SC'      Elabel_eExp::at()        return(at)
`SC'      Elabel_eExp::atbs()      return(atbs)
`Boolean' Elabel_eExp::hashash()   return(hashash)
`Boolean' Elabel_eExp::hasat()     return(hasat)
`SS'      Elabel_eExp::eexp_asis() return(asis)

`RS' Elabel_eExp::get_rc()
{
    `RS' i, rc
    
    if ( !cols(eexp_vector) ) return(`False')
    i = (rows(hash)+1)
    while (--i) if ( (rc=get_eexp_scalar(i, `False')) ) break
    return(rc)
}

    // ---------------------------------- private functions
void Elabel_eExp::set_eexp(`SS' caller_eexp)
{
    `TS' t
    
    t = tokeninit(" ", ("#", "@"))
        tokenset(t, caller_eexp)
    eexp_vector = tokengetall(t)
    hashash     = anyof(eexp_vector, "#")
    hasat       = anyof(eexp_vector, "@")
    asis        = caller_eexp
    
    eexp_expand = J(0, 1, .z)
}

`TC' Elabel_eExp::get_eexp()
{
    `RS' i
    eexp_expand = J( (i=rows(hash)), 1, get_eexp_scalar(i))
    while ( --i ) eexp_expand[i] = get_eexp_scalar(i)
    return(eexp_expand)
}

`TS' Elabel_eExp::get_eexp_scalar(`RS' i, | `RS' err)
{
    `RS' rc
    `SS' ex, tmp
    
    ex = invtokens(
                   regexr(regexr(eexp_vector, 
                   "^#$", char(32)+strofreal(hash[i])), 
                   "^@$", sprintf(`"`"%s"'"', atbs[i]))
                  )
    if ( rc=_stata("scalar "+(tmp=st_tempname())+" = "+ex, (!err)) ) {
        eexp_expand = J(0, 1, .z)
        if (err) exit(rc)
    }
    if (!err) return(rc)
    return( length(st_numscalar(tmp)) ? 
                   st_numscalar(tmp)  : 
                   st_strscalar(tmp)  )
}

    // ------------------------------ retained; not documented
// -------------------------------------- Elabel_Expr
class Elabel_Expr extends Elabel_eExp
{
    public :
        `voidTC'      expr()
        `SS'          expr_asis()
        `SS'          expr_retok()
        `voidBoolean' rc0()
        `RS'          _rc()
    
    private :
        `Boolean'     rc0
        `RS'          Rc
}

void Elabel_Expr::new()
{
    rc0 = `False'
    Rc  = 0
}

    // ---------------------------------- public functions
`voidTC' Elabel_Expr::expr(| `SS' caller_expr)
{
    if ( args() ) eexp(caller_expr)
    else           return( eexp() )
}

`SS' Elabel_Expr::expr_asis()  return( eexp_asis() )
`SS' Elabel_Expr::expr_retok() return( invtokens(eexp_vector) )

`voidBoolean' Elabel_Expr::rc0(| `Boolean' caller_rc0)
{
    if ( !args() ) return(rc0)
    rc0 = (caller_rc0!=0)
}

`RS' Elabel_Expr::_rc() return( get_rc() )

// -------------------------------------- Elabel Dir
class Elabel_Dir extends Elabel_Utilities
{
    public :
            void          new()
               
            `SC'          rnames()
            `SC'          attached()
            `SC'          get_names()   // retained; not documented
            `SC'          nonexistent()
            `SC'          undefined()
            `SC'          orphans()
            `SC'          notused()
            `SC'          used()
            `SC'          allnames()
        
            `SS'          clang()
            `SC'          langs()
        
            `voidBoolean' mlang()
            void          resetnames()
        
    private void          reset()
    private void          separate()        
        
    private `Boolean'     mlang
        
    private `SC'          rnames
    private `SC'          attached
    private `SC'          orphans
    private `SC'          nonexistent
    private `SC'          used
        
    private `SS'          clang
    private `SC'          langs
    private `SC'          clangs
}

void Elabel_Dir::new()
{
    mlang = `True'
    reset()
}

    // ---------------------------------- public functions
`SC' Elabel_Dir::rnames()
{
    `Boolean' brk
    `SS'      tmp
    
    if ( !rows(rnames) ) {
        brk    = setbreakintr(`False')
        tmp    = st_tempname()
        (void) _stata("_return hold " + tmp)
        (void) _stata("_label dir", `True')
        rnames = tokens(st_global("r(names)"))'
        (void) _stata("_return restore " + tmp)
        (void) setbreakintr(brk)
    }
    return(rnames)
}

`SC' Elabel_Dir::attached()
{    
    `SS' lname
    `RS' k, l
    
    if ( (!rows(attached)) & ((k=st_nvar()+1)-1) ) {
        while ( k-- ) {
            if ( st_isstrvar(k) ) continue
            if ((lname=st_varvaluelabel(k)) != "") 
                if ( !anyof(attached, lname) ) attached = (attached\ lname)
            if ( !mlang ) continue
            for (l=1; l<=rows(langs()); ++l) {
                if ((lname=u_get_varvaluelabel(k, langs()[l])) != "")
                    if ( !anyof(attached, lname) ) attached = (attached\ lname)
            }
        }
    }
    return(attached)
}

`SC' Elabel_Dir::get_names() return( attached() ) // retained; not documented

`SC' Elabel_Dir::nonexistent()
{
    if ( !rows(nonexistent) ) separate()
    return(nonexistent)
}

`SC' Elabel_Dir::undefined() return( nonexistent() )

`SC' Elabel_Dir::orphans()
{
    if ( !rows(orphans) ) separate()
    return(orphans)
}

`SC' Elabel_Dir::notused() return( orphans() )

`SC' Elabel_Dir::used()
{
    if ( !rows(used) ) separate()
    return(used)
}

`SC' Elabel_Dir::allnames() return( ( attached()\ orphans() ) )

`SS' Elabel_Dir::clang()
{
    if (clang == "") {
        clang = st_global("_dta[_lang_c]")
        if (clang == "") clang = "default"
    }
    return(clang)
}

`SC' Elabel_Dir::langs(| `Boolean' exclude)
{
    if ( !rows(clangs) ) {
        clangs = tokens(st_global("_dta[_lang_list]"))'
        if ( !rows(clangs) ) clangs = clang()
        if (clangs != clang()) langs = select(clangs, (clangs:!=clang()))
    }
    return( exclude ? langs : clangs )
}

`voidBoolean' Elabel_Dir::mlang(| `Boolean' caller_mlang)
{
    if ( !args() ) return(mlang)
    reset()
    mlang = (caller_mlang!=0)
}

void Elabel_Dir::resetnames() reset()

    // ---------------------------------- private functions
void Elabel_Dir::reset()
{
    rnames      = J(0, 1, "")
    attached    = J(0, 1, "")
    orphans     = J(0, 1, "")
    nonexistent = J(0, 1, "")
    used        = J(0, 1, "")
    clang       = J(1, 1, "")
    langs       = J(0, 1, "")
    clangs      = J(0, 1, "")    
}

void Elabel_Dir::separate()
{
    nonexistent = anotb(attached()', rnames()')'
    orphans     = anotb(rnames()', attached()')'
    used        = aandb(rnames()', attached()')'
}

// -------------------------------------- Elabel Unab
class Elabel_Unab extends Elabel_Dir // Elabel_Utilities
{
    public :
            void          new()
        
            `SR'          unab()
            `voidBoolean' nomem()
            `voidBoolean' mlang() // overwrite Elabel_Dir
            `voidBoolean' abbrv()
            `voidBoolean' nonamesok()
               
            void          resetnames() // overwrite Elabel_Dir         
    
    private void          get_allnames()
    private void          assert_pattern()
        
    private `Boolean'     nomem
    private `Boolean'     abbrv
    private `Boolean'     nonamesok
    private `Boolean'     tilde
        
    private `SC'          allnames
    private `SR'          lblnames
}

void Elabel_Unab::new()
{
    nomem     = `False'
    abbrv     = `False'
    nonamesok = `True'
    tilde     = `False'
    allnames  = J(0, 1, "")
    lblnames  = J(1, 0, "")
}

    // ---------------------------------- public functions
`SR' Elabel_Unab::unab(`SS' caller_pattern, | `TM' newlblname)
{
    `SS'       pattern
    `BooleanC' match
    
    if (args() > 1) newlblname = J(1, 0, "")
    
    if ( !rows(allnames) ) get_allnames()
    assert_pattern(caller_pattern)
    
    pattern = subinstr(caller_pattern, "~", "*")
    match   = strmatch(allnames, pattern)
    if ( !any(match) ) {
        if (caller_pattern == "_all") match = J(rows(allnames), 1, 1)
        else if ( (!any(strpos(pattern, ("*", "?")))) & abbrv ) {
            tilde = `True'
            match = strmatch(allnames, (pattern+"*"))
        }
    }
    
    if ( !any(match) ) {
        if      (args() < 2)                 u_err_notfound(caller_pattern)
        else if (!st_isname(caller_pattern)) u_err_notfound(caller_pattern)
        newlblname = caller_pattern
        return( J(1, 0, "") )
    }
    else if ( (tilde) & (colsum(match)>1) ) 
        u_exerr(111, "%s ambiguous abbreviation", caller_pattern)
    return( (lblnames=select(allnames, match)') )
}

`voidBoolean' Elabel_Unab::nomem(| `RS' val)
{
    if ( !args() ) return(nomem)
    nomem = (val!=0)
    allnames = J(0, 1, "")
}

`voidBoolean' Elabel_Unab::mlang(| `RS' val)
{
    if ( !args() ) return( super.mlang() )
    super.mlang(val)
    allnames = J(0, 1, "")
}

`voidBoolean' Elabel_Unab::abbrv(| `RS' val)
{
    if ( !args() ) return(abbrv)
    abbrv = (val!=0)
}

`voidBoolean' Elabel_Unab::nonamesok(| `RS' val)
{
    if ( !args() ) return(nonamesok)
    nonamesok = (val!=0)
    allnames = J(0, 1, "")
}

void Elabel_Unab::resetnames()
{
    super.resetnames()
    allnames = J(0, 1, "")
}

    // ---------------------------------- private functions
void Elabel_Unab::get_allnames()
{
    mlang(mlang())
    allnames = nomem ? allnames() : rnames()
    if ( rows(allnames) ) return
    if (nonamesok) allnames = J(1, 1, "")
    else u_exerr(111, "no value labels found")
}

void Elabel_Unab::assert_pattern(`SS' c_pattern)
{
    `SS'      valid
    `Boolean' haswc
    
    if (c_pattern == "") u_exerr(100, "value label name required") 
    
    pragma unset haswc
    valid = u_strip_wildcards(c_pattern, haswc)
    if (haswc) {
        if ( (tilde=strpos(c_pattern, "~")) & 
            any(strpos(c_pattern, ("*", "?"))) ) 
        {
            errprintf("%s: may not combine ~ and *-or-? notation", c_pattern)
            exit(198)
        }
        if ((valid == "") | !st_isname(valid) ) valid = ("_"+valid)
    }
    if ( !st_isname(valid) ) u_exerr(198, "%s invalid name", c_pattern)
}

// -------------------------------------- Elabel Syntax
class Elabel_Syntax extends Elabel_Unab // Elabel_Dir; Elabel_Utilities
{
    public :
            void          new()
        
            `voidSS'      set()
            `voidBoolean' newlblnameok()
            `voidBoolean' newlblnamesok()
            `voidBoolean' varvaluelabelok()
            `voidBoolean' anythingok()
            `voidSR'      iffword()
            `voidSS'      usingword()
            `voidBoolean' strict()
            `voidBoolean' broadmappings()
        
            `SR'          lblnamelist()
            `SR'          newlblnamelist()
            `SR'          labelnamelist()
            `SR'          varvaluelabel()
            `SS'          anything()
            `SS'          mappings()
            `SS'          iff_eexp()
            `SS'          filename()
            `SS'          options()
    
    private void          reset()
        
    private void          parse()
    private void          get_options()
    private void          get_filename()
    private void          get_iff_eexp()
    private void          get_verbatim()
    private void          get_namelist()
    private `Boolean'     get_varvaluelabel()
    private void          get_lblnames()
    private void          get_pvarlist()
        
    private `Boolean'     ismapping()
        
    private `TS'          t
    private `Boolean'     ismapping
    private `Boolean'     parsed
        
    private `SS'          zero
    private `Boolean'     newlblnameok
    private `Boolean'     varvaluelabelok
    private `Boolean'     anythingok
    private `SR'          iffword
    private `SS'          usingword
    private `Boolean'     strict
    private `Boolean'     broadmappings
        
    private `SR'          lblnamelist
    private `SR'          newlblnamelist
    private `SR'          varvaluelabel
    private `SR'          vvl
    private `SS'          mappings
    private `SS'          iff_eexp
    private `SS'          filename
    private `SS'          options
}

void Elabel_Syntax::new()
{
    newlblnameok    = `False'
    varvaluelabelok = `False'
    anythingok      = `False'
    iffword         = (statasetversion()<1600) ? ("if", "iff") : "iff"
    usingword       = ("")
    strict          = `False'
    broadmappings   = `False'
    
    reset()
}

    // ---------------------------------- public functions
`voidSS' Elabel_Syntax::set(| `SS' caller_zero)
{
    if ( !args() ) return(zero)
    zero = caller_zero
    reset()
}

`voidBoolean' Elabel_Syntax::newlblnameok(| `RS' val)
{
    if ( !args() ) return(newlblnameok)
    if ((val!=0) == newlblnameok) return
    newlblnameok = (val!=0)
    if (parsed) reset()
}

`voidBoolean' Elabel_Syntax::newlblnamesok(| `RS' val)
{
    if ( !args() ) return(newlblnameok)
    newlblnameok(val)
}

`voidBoolean' Elabel_Syntax::varvaluelabelok(| `RS' val)
{
    if ( !args() ) return(varvaluelabelok)
    if ((val!=0) == varvaluelabelok) return
    varvaluelabelok = (val!=0)
    if (parsed) reset()
}

`voidBoolean' Elabel_Syntax::anythingok(| `RS' val)
{
    if ( !args() ) return(anythingok)
    if ((val!=0) == anythingok) return
    anythingok = (val!=0)
    if (parsed) reset()
}

`voidSR' Elabel_Syntax::iffword(| `SR' caller_iffword)
{
    if ( !args() ) return(iffword)
    if (caller_iffword == iffword) return
    iffword = caller_iffword
    if (parsed) reset()
}

`voidSS' Elabel_Syntax::usingword(| `SR' caller_usingword)
{
    if ( !args() ) return(usingword)
    if (caller_usingword == usingword) return
    usingword = caller_usingword
    if (parsed) reset()
}

`voidBoolean' Elabel_Syntax::strict(| `RS' val)
{
    if ( !args() ) return(strict)
    if ((val!=0) == strict) return
    strict = (val!=0)
    if (parsed) reset()
}

`voidBoolean' Elabel_Syntax::broadmappings(| `RS' val)
{
    if ( !args() ) return(broadmappings)
    if ((val!=0) == broadmappings) return
    broadmappings = (val!=0)
    if (parsed) reset()
}

`SR' Elabel_Syntax::lblnamelist(| `RS' nonempty)
{
    parse()
    if (anythingok)        return( J(1, 0, "") )
    if (!nonempty)         return( lblnamelist )
    if (lblnamelist == "") return( J(1, 0, "") )
    return( u_selectnm(lblnamelist) )
}

`SR' Elabel_Syntax::newlblnamelist(| `RS' nonempty)
{
    parse()
    if (anythingok)           return( J(1, 0, "") )
    if (!nonempty)            return( newlblnamelist )
    if (newlblnamelist == "") return( J(1, 0, "") )
    return( u_selectnm(newlblnamelist) )
}

`SR' Elabel_Syntax::labelnamelist()
{
    parse()
    if ( !newlblnameok )     return( lblnamelist(`False')  )
    return( (lblnamelist(`False')+newlblnamelist(`False')) )
}

`SR' Elabel_Syntax::varvaluelabel()
{
    parse()
    return( varvaluelabel )
}

`SS' Elabel_Syntax::anything()
{
    parse()
    return( (anythingok & cols(lblnamelist)) ? strtrim(lblnamelist) : "" )
}

`SS' Elabel_Syntax::mappings(| `RS' strtrim)
{
    parse()
    return( (strtrim ? strtrim(mappings) : mappings) )
}

`SS' Elabel_Syntax::iff_eexp(| `RS' noiffword)
{
    parse()
    if ( (iff_eexp=="") | noiffword ) return(iff_eexp)
    return( (iffword[1]+char(32)+iff_eexp) )
}

`SS' Elabel_Syntax::filename(| `RS' nousingword)
{
    parse()
    if ( (filename=="") | nousingword ) return(filename)
    return( (usingword+char(32)+filename) )
}

`SS' Elabel_Syntax::options(| `RS' comma)
{
    parse()
    if ( (options=="") | (!comma) ) return(options)
    return( (", " + options) )
}

    // ---------------------------------- private functions
void Elabel_Syntax::reset()
{
    t              = tokeninit(" ", (",", "(", ")", "="))
                     tokenset(t, zero)
                     
    lblnamelist    = J(1, (anythingok), "")
    newlblnamelist = J(1, 0, "")
    varvaluelabel  = J(1, 0, "")
    mappings       = ("")
    iff_eexp       = ("")
    filename       = ("")
    options        = ("")
    vvl            = J(1, 0, "")
    
    ismapping      = `False'
    parsed         = `False'
}

void Elabel_Syntax::parse()
{
    `SS' tok
    
    if (parsed) return
    
    while ( (tok=tokenpeek(t)) != "" ) {
        if      (tok == ")")            u_err_unbalanced("(")
        else if (tok == ",")            get_options()
        else if (tok == usingword)      get_filename()
        else if ( anyof(iffword, tok) ) get_iff_eexp()
        else if ( ismapping() )         get_verbatim(&mappings)
        else if (anythingok)            get_verbatim(&lblnamelist)
        else                            get_namelist()
    }
    
    if ( cols(u_selectnm(newlblnamelist)) ) 
        u_assert_newlblname(u_selectnm(newlblnamelist))
    if (varvaluelabelok) u_assert_uniq(vvl, "variable")
    
    parsed = `True'
}

void Elabel_Syntax::get_options() 
{
    (void)    tokenget(t) // known to be ,
    options = tokenrest(t)
    (void)    tokengetall(t) // clear rest
}

void Elabel_Syntax::get_filename()
{
    if (filename != "") u_exerr(101, "using not allowed")
    
    (void)     tokenget(t) // known to be usingword
    filename = tokenget(t)
    if ( anyof(("", ","),filename) )
        u_exerr(198, "invalid file specification")
    if ( !anyof(("", ",", iffword), tokenpeek(t)) )
        u_exerr(198, "invalid %s", tokenpeek(t))
}

void Elabel_Syntax::get_iff_eexp()
{
    `SR'                  tchars
    class Elabel_eExp `S' e
    
    if (iff_eexp != "") u_exerr(101, "%s not allowed", tokenget(t))
    
    (void) tokenget(t) // known to be iffword
    
    tchars = (tokenwchars(t), tokenpchars(t))
    tokenwchars(t, "")
    tokenpchars(t, (" ", tokenpchars(t)))
    
    while ( !anyof(("", ",", usingword), tokenpeek(t)) ) {
        iff_eexp = iff_eexp + ( (tokenpeek(t) == "(") ?
                    u_tokenget_inpar(t) : tokenget(t) )
    }
    
    if (strtrim(iff_eexp) == "") exit(error(198))
    
    tokenwchars(t, tchars[1])
    tokenpchars(t, tchars[|2\ .|])
    
    e.eexp(iff_eexp)
    if ( !isreal(e.eexp()) ) exit(error(109))
}

void Elabel_Syntax::get_verbatim(pointer(string) `S' p)
{
    `SR' tchars
    
    tchars = (tokenwchars(t), tokenpchars(t))
    tokenwchars(t, "")
    tokenpchars(t, (" ", "(", ")", ",", "="))
    
    while (tokenpeek(t) == " ") (*p) = (*p) + tokenget(t)
    (*p) = (*p) + ( (tokenpeek(t) == "(") ? 
        u_tokenget_inpar(t) : tokenget(t) )
    
    tokenwchars(t, tchars[1])
    tokenpchars(t, tchars[|2\ .|])
}

void Elabel_Syntax::get_namelist()
{
    `Boolean' isvarvaluelabel
    `RS'      col
    `SR'      lblname
    
    if ( (isvarvaluelabel=get_varvaluelabel()) ) {
        if (tokenpeek(t) == "") 
            u_exerr(198, "too few label names specified")
        if ( anyof((iffword, usingword), tokenpeek(t)) )
            u_exerr(198, "invalid %s", tokenpeek(t))
        col = cols(lblnamelist) // >= cols(newlblnamelist)
    }
    
    if (tokenpeek(t) == "(") get_pvarlist()
    else                     get_lblnames()

    if ( !isvarvaluelabel ) return
    
    lblname = lblnamelist[++col..cols(lblnamelist)]
    if ( newlblnameok ) 
        lblname = (lblname + newlblnamelist[col..cols(newlblnamelist)])
    u_err_fewmany((cols((lblname=u_selectnm(lblname)))-1), "label names")
    varvaluelabel[cols(varvaluelabel)] = 
        (varvaluelabel[cols(varvaluelabel)]+char(32)+lblname)
}

`Boolean' Elabel_Syntax::get_varvaluelabel()
{
    `SR'      tchars
    `RS'      offset
    `SR'      varlist
    
    if ( !varvaluelabelok ) return(`False')
    
    tchars = (tokenwchars(t), tokenpchars(t))
    tokenwchars(t, " ")
    tokenpchars(t, (",", "(", ")", "=", ":"))
    offset = tokenoffset(t)
    
    if (tokenpeek(t) != "(") varlist = tokenget(t) 
    else    varlist = u_tokenget_inpar(t, `False')
    
    if (tokenpeek(t) != ":") {
        tokenoffset(t, offset)
        tokenwchars(t, tchars[1])
        tokenpchars(t, tchars[|2\ .|])
        return(`False')
    }
    
    vvl = (vvl, (varlist=auniq(u_st_numvarlist(varlist))))
    varvaluelabel = (varvaluelabel, invtokens(varlist))
    
    (void) tokenget(t) // known to be :
    tokenwchars(t, tchars[1])
    tokenpchars(t, tchars[|2\ .|])
        
    return(`True')
}

void Elabel_Syntax::get_pvarlist()
{
    `SS'      st_local_strict, st_local_uniq
    `SR'      varlist, nonuniq
    `Boolean' opt_strict, opt_uniq
    `RS'      i
    `SS'      lblname
    
    st_local_strict = st_local("strict")
    st_local_uniq   = st_local("uniq")
    u_st_syntax(u_tokenget_inpar(t, `False'), "varlist [ , Strict UNIQ ]")
    varlist    = tokens(st_local("varlist"))
    opt_strict = (st_local("strict") == "strict")
    opt_uniq   = (st_local("uniq")   ==   "uniq")
    st_local("strict", st_local_strict)
    st_local("uniq",     st_local_uniq)
    
    pragma unset nonuniq
    for (i=1; i<=cols(varlist); ++i) {
        lblname = st_varvaluelabel(varlist[i])
        if (lblname != "") {
            if (opt_uniq) {
                if ( anyof(nonuniq, lblname) ) continue
            }
            nonuniq = (nonuniq, lblname)
            if ( anyof((nomem() ? allnames() : rnames()), lblname) ) {
                lblnamelist = (lblnamelist, lblname)
                if (newlblnameok) newlblnamelist = (newlblnamelist, "")
            }
            else if (newlblnameok) {
                newlblnamelist = (newlblnamelist, lblname)
                lblnamelist    = (lblnamelist, "")
            }
            else u_exerr(111, "value label %s not found", lblname)
        }
        else if ( !(opt_strict|strict) ) {
            u_exerr(111, "variable %s has no value label attached", varlist[i])
        }
        else { // empty value label
            lblnamelist = (lblnamelist, lblname)
            if (newlblnameok) newlblnamelist = (newlblnamelist, lblname)
        }
    }
}

void Elabel_Syntax::get_lblnames()
{
    `SS' tok
    `SR' lblname, newname
    
    pragma unset newname
    
    tok = tokenget(t)
    lblname = newlblnameok ? unab(tok, newname) : unab(tok)
    if ( !cols(lblname) )  lblname = J(1, cols(newname), "")
    else if (newlblnameok) newname = J(1, cols(lblname), "")
    lblnamelist    = (lblnamelist,    lblname)
    newlblnamelist = (newlblnamelist, newname)
}

`Boolean' Elabel_Syntax::ismapping()
{
    `SR'      tchars
    `RS'      offset
    `Boolean' wcc
    `SS'      tok
    
    if (ismapping) return(`True')
    
    tchars = (tokenwchars(t), tokenpchars(t))
    tokenwchars(t, " ")
    tokenpchars(t, ("(", ")", "[", "]", "/", "="))
    offset = tokenoffset(t)
    
    while ( (tok=tokenget(t) ) == "(") { }
    tokenoffset(t, offset)
    tokenwchars(t, tchars[1])
    tokenpchars(t, tchars[|2\ .|])
    
    ismapping = ( (tok=="=") | (!_strtoreal(tok, offset)) )
    
    if ( (!ismapping) & (broadmappings) ) {
        tchars = (tokenwchars(t), tokenpchars(t))
        offset = tokenoffset(t)
        tokenwchars(t, " ")
        tokenpchars(t, ("(", ")", "-"))
        if (tokenpeek(t) == "(") {
            (void) tokenget(t)
            tokenpchars(t, (")", "-"))
        }
        wcc = anyof(("*", "~"), substr( (tok=tokenget(t)), 1, 1) )
        tokenoffset(t, offset)
        tokenwchars(t, tchars[1])
        tokenpchars(t, tchars[|2\ .|])       
        tok = u_strip_wildcards(tok)
        if (wcc) ismapping = !( (tok=="") | st_islmname(tok) )
        else     ismapping = !st_isname(tok)
    }
    
    return(ismapping)
}

// -------------------------------------- Elabel_ValueLabel
class Elabel_ValueLabel extends Elabel_Utilities
{
    public :
            void       setup()
            void       reset()
            void       mark()
            void       markiff()
            void       markall()
        
            `voidSS'   name()
            `RC'       vvec()
            `SC'       tvec()
            `BooleanC' null()
            `BooleanC' touse()
        
            `RS'       k()
            `RS'       K()
            `RS'       nemiss()
            `Boolean'  sysmiss()
            `SR'       usedby()
        
            void       define()
            void       modify()
            void       append()
            
            void       assert_add()
            void       list()
            void       _list()
        
    private `SS'       name
    private `RC'       vvec
    private `SC'       tvec
    private `BooleanC' touse
    private `SR'       usedby
    
    private `RS'       breakintr
        
    private void       keep_last()
    private void       define_null()
}

    // ---------------------------------- public functions
void Elabel_ValueLabel::setup(`SS' caller_name, 
                            | `RC' caller_vvec,
                              `SC' caller_tvec,
                              `SS'         sep)
{
    name(caller_name)
    
    if (args() == 1) st_vlload(name, vvec, tvec)
    else {
        if ( rows(caller_vvec)!=rows(caller_tvec) ) _error(3200)
        vvec = caller_vvec
        tvec = caller_tvec
        (void) (args() < 4) ? keep_last() : keep_last(sep)
    }
    
    mark(J(rows(vvec), 1, `True'))
}

void Elabel_ValueLabel::reset(| `RC' caller_vvec, 
                                `SC' caller_tvec)
{
    if (args() == 1) _error(3001)
    setup(name(), caller_vvec, caller_tvec)
}

void Elabel_ValueLabel::mark(`RC' caller_touse)
{
    if (rows(caller_touse)!=rows(vvec /* not vvec() */ )) _error(3200)
    touse = (caller_touse:!=0)
}

void Elabel_ValueLabel::markiff(`SS' elabel_eexp)
{
    class Elabel_eExp `S' e
    
    if (elabel_eexp == "") return
    
    e.eexp(elabel_eexp)
    if ( e.get_rc() )        _error(3300)
    if ( !isreal(e.eexp()) ) _error(3253)
    
    if (!rows(vvec /* not vvec() */ )) return
    
    e.wildcards(vvec /* not vvec() */, tvec /* not tvec() */ )
    mark( e.eexp() )
}

void Elabel_ValueLabel::markall() mark(J(K(), 1, `True'))

`voidSS' Elabel_ValueLabel::name(| `SS' caller_name) 
{
    if ( !args() ) return(name)
    u_assert_name(caller_name)
    name = caller_name
}

`RC' Elabel_ValueLabel::vvec()
{
    return( any(touse()) ? select(vvec, touse()) : J(0, 1, .) )
}

`SC' Elabel_ValueLabel::tvec()
{
    return( any(touse()) ? select(tvec, touse()) : J(0, 1, "") )
}

`BooleanC' Elabel_ValueLabel::null()    return( (tvec():=="") )
`BooleanC' Elabel_ValueLabel::touse()   return(touse)
`RS'       Elabel_ValueLabel::k()       return( colsum(touse()) )
`RS'       Elabel_ValueLabel::K()       return( rows(touse()) )
`RS'       Elabel_ValueLabel::nemiss()  return( colsum((vvec():>.)) )
`Boolean'  Elabel_ValueLabel::sysmiss() return( anyof(vvec(), .) )

`SR' Elabel_ValueLabel::usedby(| `Boolean' update)
{
    `RS' k
    if (update) {
        usedby = J(1, 0, "")
        for (k=1; k<=st_nvar(); ++k) {
            if (st_varvaluelabel(k)!=name()) continue
            usedby = (usedby, st_varname(k))
        }
    }
    return(usedby)
}

void Elabel_ValueLabel::define(| `Boolean' replace, `Boolean' fixfmt)
{
    if ( !args() ) replace = 0
    breakintr = setbreakintr(`False')
    if (replace) st_vldrop( name() )
    else u_assert_newlblname( name() )
    st_vlmodify(name(), vvec(), tvec())
    define_null(fixfmt)
    (void) setbreakintr(breakintr)
}

void Elabel_ValueLabel::modify(| `Boolean' add, `Boolean' fixfmt)
{
    `BooleanC' Touse
    
    if ( (add = (args() ? add : 0)) ) assert_add()
    breakintr = setbreakintr(`False')
    mark( !((Touse=touse()):*(k() ? null() : k())) )
    st_vlmodify(name(), vvec(), tvec())
    mark(Touse)
    define_null(fixfmt)
    (void) setbreakintr(breakintr)
}

void Elabel_ValueLabel::append(| `Boolean' fixfmt, `SS' sep)
{
    `RC' vals
    `SC' text
    `RC' idx
    `RS' i
    
    if ( st_vlexists(name()) ) {
        pragma unset vals
        pragma unset text
        st_vlload(name(), vals, text)
        if ( k() ) idx = select((1::K()), touse())
        for (i=1; i<=k(); ++i) {
            if ( !anyof(vals, vvec()[i]) ) continue
            if ((text=st_vlmap(name(), vvec()[i])) == tvec()[i]) continue
            if (args() < 2) exit( error(180) )
            if (text == "") tvec[idx[i]] = tvec()[i]
            else tvec[idx[i]] = text + sep*(tvec()[i]!="") + tvec()[i]
        }
    }
    modify(`False', fixfmt)
}

void Elabel_ValueLabel::assert_add()
{
    `RC' vv, vals
    `SC' text
    `RS' nrow
    
    if ( !st_vlexists(name()) ) return
    if ( !(nrow=rows((vv=select(vvec(), !null())))) ) return
    
    pragma unset vals
    pragma unset text
    st_vlload(name(), vals, text)
    while ( nrow ) if ( anyof(vals, vv[nrow--]) ) exit(error(180))
}

void Elabel_ValueLabel::list(| `TM' vals, `TM' text, `RS' noisily)
{
    `RS' i
    
    if ( !args() ) {
        _list()
        return
    }
    
    vals = text = J(1, 0, "")
    if (noisily) printf("{txt}%s%s\n", name(), (":"*(name()!="")))
    for (i=1; i<=k(); ++i) {
        vals = (vals, strofreal(vvec()[i]))
        text = (text, (
                       (strpos(tvec()[i], char(34))                 ?
                       (char((96, 34)) + tvec()[i] + char((34, 39))):
                       (char(     34)  + tvec()[i] + char( 34    ))))
               )
        if (noisily) 
            printf("{res}{asis}%12.0g %s{smcl}\n", vvec()[i], tvec()[i])
    }
    vals = invtokens(vals)
    text = invtokens(text)
}

void Elabel_ValueLabel::_list(| `RS' _name)
{
    `RS' i
    
    if ( _name ) printf("{txt}%s%s\n", name(), (":"*(name()!="")))
    for (i=1; i<=k(); ++i) 
        printf("{res}{asis}%12.0g %s{smcl}\n", vvec()[i], tvec()[i])
}

    // ---------------------------------- private functions
void Elabel_ValueLabel::keep_last(| `SS' sep)
{
    `RS'       k, j
    `BooleanC' keep, seq
    
    if (rows(vvec) < 2) return
    
    keep = J((k=rows(vvec)), 1, `True')
    seq  = order((vvec, (1::k)), (1, 2))
    vvec = vvec[seq]
    if ( !args() ) while ( --k ) keep[k] = (vvec[k]!=vvec[k+1])
    else {
        for (j=1; j<k; ++j) {
            if ( (keep[j]=(vvec[j]!=vvec[j+1])) ) continue
            if (tvec[seq[j]] == "")               continue
            if (tvec[seq[j+1]] == "") tvec[seq[j+1]] = tvec[seq[j]] 
            else tvec[seq[j+1]] = (tvec[seq[j]] + sep + tvec[seq[j+1]])
        }
    }
    vvec = select(vvec, keep)
    tvec = select(tvec[seq], keep)
}

void Elabel_ValueLabel::define_null(| `Boolean' fixfmt)
{
    `SR' mappings
    
    if ( !any((null()\ fixfmt)) ) return
    
    mappings = u_invtoken((strofreal(select(vvec(), null())'):+`" """'))
    (void) _stata(sprintf("_label define %s %s , modify %s", 
            name(), mappings, (fixfmt ? "" : "nofix")) )
}

// -------------------------------------- Elabel (main)
struct Elabel_RR__
{
    pointer(pointer(`S')  `S') `R' sca
    pointer(pointer(`SS') `S') `R' mac
    pointer(pointer(`TM') `S') `R' mat
    `Boolean'                      protectr
}

class Elabel extends Elabel_Utilities
{
    public :
                   void                    new()
                   void                    main()
        
    private        class Elabel_Syntax     `S' syntax
    private        class Elabel_Options__  `S' option
    private        class Elabel_ValueLabel `V' vallbl
        
        // elabel commands
    private        void                    cmd_data()
    
    private        void                    cmd_variable()
    private        `Boolean'               cmd_variable_gmappings()
    private        `Boolean'               cmd_variable_pseudofcn()
    private        void                    cmd_variable_alternate()
    private        void                    cmd_variable_eexp()
    private        void                    cmd_variable_labels()
    
    private        void                    cmd_define()
    private        `Boolean'               cmd_define_pseudofcn()
    private        `Boolean'               cmd_define_is_recode()
    private        void                    cmd_define_recode()
    private        `Boolean'               cmd_define_gmappings()
    private        void                    cmd_define_eexp()
    private        void                    cmd_define_st_define()
    private        void                    cmd_define_onefitsall()
    private        void                    cmd_define_oneforeach()
    
    private        void                    cmd_values()
    private        `Boolean'               cmd_values_gmappings()
    private        void                    cmd_values_values()
    
    private        void                    cmd_dir()
    private static void                    cmd_dir_match()
    private        void                    cmd_dir_print()
    
    private        void                    cmd_list()
    private        void                    cmd_list_print()
    private        void                    cmd_list_rvars()
    
    private        void                    cmd_copy()

    private        void                    cmd_drop()
    private        void                    cmd_drop_labels()
    
    private        void                    cmd_save()
    private        void                    cmd_save_elabel()
    private        `SS'                    cmd_save_option()
    
    private        void                    cmd_language()
    private        void                    cmd_language_saving()
    
    private        void                    cmd_passthru()
    
    private        void                    cmd_c_locals()
    
    private        void                    cmd_cmd()
    
    private        void                    cmd_confirm()
    
    private        void                    cmd_duplicates()
    private        void                    cmd_duplicates_remove()    
    private        void                    cmd_duplicates_get()
    private        void                    cmd_duplicates_of()    
    private        void                    cmd_duplicates_report()
    private static void                    cmd_duplicates_rm()    
    private static `Boolean'               cmd_duplicates_key()
    
    private        void                    cmd_fcncall()
    
    private        void                    cmd_numlist()
    
    private        void                    cmd_parse()
    private        void                    cmd_parse_descr_of_str()
    private static void                    cmd_parse_descr_of_str_element()
    private        void                    cmd_parse_descr_of_str_lblspec()
    private static void                    cmd_parse_descr_of_str_mapspec()
    private        void                    cmd_parse_str_to_parse()
    
    private        void                    cmd_parsefcn()
    
    private        void                    cmd_protectr()
    
    private        void                    cmd_query()
    private static void                    cmd_query_assert_version()
    
    private        void                    cmd_rename()
    private        `Boolean'               cmd_rename_old_new()
    
    private        void                    cmd_unab()
    
    private        void                    cmd_varvaluelabel()
    
    private        void                    cmd__icmd()
    
    private        void                    cmd__u_gmappings()
    
    private        void                    cmd__u_parse_rules()
    
    private        void                    cmd__u_usedby()    
        
        // internal commands
    private static void                    breakoff()
    private        void                    breakreset()
    private static void                    c_locals()
    private        void                    call_fcn()
    private static void                    clearlocals()
    private        void                    outsource()
    private        void                    rr_get()
    private        void                    rr_set()
    private        void                    rr_reset()
    private static `SS'                    st_local0()
    private        void                    varvaluelabel()
    
    private        `SS'                    cmdline
    private        `TS'                    t_zero
    private        `SS'                    subcmd
    private        `SS'                    zero
    
    private        `Boolean'               brkintr
    private static `SR'                    clmacnames
    private static struct Elabel_RR__ `S'  rr
}

void Elabel::new()
{
    brkintr = querybreakintr()
    vallbl  = Elabel_ValueLabel()
}

    // ---------------------------------- public functions
void Elabel::main(`SS' st_cmdline)
{
    t_zero = tokeninit(" ", (",", ":"))
             tokenset(t_zero, (cmdline=st_cmdline))
    subcmd = tokenget(t_zero)
    zero   = tokenrest(t_zero)
    
    if      (subcmd == "")                         exit( error(198) )
    else if ( u_unabbr(subcmd, "da:ta")          ) cmd_data()    
    else if ( u_unabbr(subcmd, "var:iables")     ) cmd_variable()
    else if ( u_unabbr(subcmd, "de:fine")        ) cmd_define()
    else if ( u_unabbr(subcmd, "val:ues")        ) cmd_values()
    else if ( u_unabbr(subcmd, "di:r")           ) cmd_dir()
    else if ( u_unabbr(subcmd, "l:ist")          ) cmd_list()
    else if ( u_unabbr(subcmd, "copy")           ) cmd_copy()
    else if ( u_unabbr(subcmd, "drop")           ) cmd_drop()
    else if ( u_unabbr(subcmd, "save")           ) cmd_save()
    else if ( u_unabbr(subcmd, "lang:uage")      ) cmd_language()
    else if ( u_unabbr(subcmd, "keep")           ) cmd_drop(`False')
    else if ( u_unabbr(subcmd, "c_local:s")      ) cmd_c_locals()
    else if ( u_unabbr(subcmd, "cmd")            ) cmd_cmd()
    else if ( u_unabbr(subcmd, "conf:irm")       ) cmd_confirm()
    else if ( u_unabbr(subcmd, "dup:licates")    ) cmd_duplicates()
    else if ( u_unabbr(subcmd, "fcncall")        ) cmd_fcncall()
    else if ( u_unabbr(subcmd, "numlist")        ) cmd_numlist()
    else if ( u_unabbr(subcmd, "parse")          ) cmd_parse()
    else if ( u_unabbr(subcmd, "parsefcn")       ) cmd_parsefcn()
    else if ( u_unabbr(subcmd, "protectr")       ) cmd_protectr()
    else if ( u_unabbr(subcmd, "q:uery")         ) cmd_query()
    else if ( u_unabbr(subcmd, "ren:ame")        ) cmd_rename()
    else if ( u_unabbr(subcmd, "unab")           ) cmd_unab()
    else if ( u_unabbr(subcmd, "varvaluelabel:s")) cmd_varvaluelabel()
    else if ( u_unabbr(subcmd, "_icmd")          ) cmd__icmd()
    else if ( u_unabbr(subcmd, "_u_gmappings")   ) cmd__u_gmappings()
    else if ( u_unabbr(subcmd, "_u_parse_rules") ) cmd__u_parse_rules()
    else if ( u_unabbr(subcmd, "_u_usedby")      ) cmd__u_usedby()
    else                                           cmd_passthru()
}

    // ---------------------------------- elabel subcommands

        // ------------------------------ cmd_data
void Elabel::cmd_data()
{
    `SS'                  eexp
    class Elabel_eExp `S' e

    pragma unset eexp    
    if ( !u_iseexp(zero, eexp) ) {
        u_st_exe("_label " + cmdline)
        return
    }
    e.eexp(eexp)
    if ( e.hashash() ) u_exerr(198, "# not allowed in {it:eexp}")
    u_st_exe("local dtalabel : data label")
    e.wildcards(., st_local("dtalabel"))
    if ( isreal(e.eexp()) ) exit(error(109))
    u_st_exe(sprintf(`"_label data "%s""', u_bslsq(e.eexp())))
}

        // ------------------------------ cmd_variable
void Elabel::cmd_variable()
{
    `SS' mappings
    
    syntax.anythingok(`True')
    syntax.iffword("")
    syntax.set(zero)
    
    mappings = strtrim(syntax.anything()+char(32)+syntax.mappings())
    if (mappings == "") u_exerr(100, "varname required")
    if ( !st_nvar() )   u_exerr(111, "no variables defined")
    
    if      ( cmd_variable_gmappings(mappings) ) return
    else if ( cmd_variable_pseudofcn()         ) return
    else      cmd_variable_alternate( tokengetall(t_zero) )
}

`Boolean' Elabel::cmd_variable_gmappings(`SS' mappings)
{
    `SR' varnames, varlabels
    `SS' eexp
    
    pragma unset varnames
    pragma unset varlabels
    pragma unset eexp
    
    if ( !u_isgmappings(mappings, varnames, varlabels) ) return(`False')
    
    u_st_syntax((varnames+syntax.options()), "varlist")
    u_assert_uniq( (varnames=tokens(st_local("varlist"))), "variable" )
    if ( u_iseexp(varlabels, eexp) ) cmd_variable_eexp(varnames, eexp)
    else cmd_variable_labels( varnames, tokens(invtokens(varlabels)) )
    
    return(`True')
}

`Boolean' Elabel::cmd_variable_pseudofcn()
{
    `SS' fcn, fargs, rest, varlist
    
    pragma unset fcn
    pragma unset fargs
    pragma unset rest
    
    if ( !u_ispfcn(syntax.mappings(), fcn, fargs, rest) ) return(`False')
    
    u_st_syntax(syntax.anything(), "varlist")
    u_assert_uniq(tokens((varlist=st_local("varlist"))), "variable")
    
    call_fcn("variable", fcn, varlist, fargs, rest+syntax.options())
    
    return(`True')
}

void Elabel::cmd_variable_alternate(`SR' mappings)
{
    `SR' varnames, varlabels
    
    varnames = select(mappings, mod((1..cols(mappings)), 2))
    if ( anyof(varnames, "_all") ) u_exerr(101, "_all not allowed")
    u_st_syntax(invtokens(varnames), "varlist")
    varnames = subinstr(varnames, "~", "")
    if ( cols((varnames=u_selectnm(varnames))) ) u_assert_name(varnames)
    varnames = tokens(st_local("varlist"))
    
    varlabels = select(mappings, !mod((1..cols(mappings)), 2))
    varlabels = (!cols(varlabels)) ? "" : tokens(invtokens(varlabels))
    if ( cols(varlabels)<cols(varnames) ) varlabels = (varlabels, "")
    
    cmd_variable_labels(varnames, varlabels)
}

void Elabel::cmd_variable_eexp(`SR' varnames, `SS' eexp)
{
    class Elabel_eExp `S' e
    `RS'                  i
    `TS'                  varlabel
    
    e.eexp(eexp)
    if ( e.hashash() ) u_exerr(198, "# not allowed in {it:eexp}")
    
    breakoff()
    for (i=1; i<=cols(varnames); ++i) {
        e.wildcards(., st_varlabel(varnames[i]))
        if ( isreal((varlabel=e.eexp())) ) varlabel = strofreal(varlabel)
        st_varlabel(varnames[i], varlabel)
    }
    breakreset()
}

void Elabel::cmd_variable_labels(`SR' varnames, `SR' varlabels)
{
    `RS' ncol, i
    
    breakoff()
    if ((ncol=cols(varlabels)) == 1) {
        for (i=1; i<=cols(varnames); ++i) st_varlabel(varnames[i], varlabels)
    }
    else {
        u_err_fewmany((ncol-cols(varnames)), "variable labels")
        for (i=1; i<=ncol; ++i) st_varlabel(varnames[i], varlabels[i])
    }
    breakreset()
}

        // ------------------------------ cmd_define
void Elabel::cmd_define()
{
    syntax.newlblnameok(`True')
    syntax.varvaluelabelok(`True')
    syntax.iffword("")
    syntax.set(zero)
    
    u_st_syntax(syntax.options(), "[ , Add MODIFY REPLACE noFIX * ]")
    option.st_get()
    
    u_err_required(u_invtoken(syntax.labelnamelist()), "label name")
    
    if ( !option.replace() ) {
        u_assert_uniq(syntax.lblnamelist(), "label")
        if ( !(option.modify()|option.add()) ) 
            u_assert_newlblname( syntax.labelnamelist() )
    }
    
    u_err_required(syntax.mappings(), `"# "label" ..."')
    
    if ( cmd_define_pseudofcn() ) return
    
    if ( cmd_define_is_recode() ) return
    
    if (option.st_options() != "") {
        u_st_syntax(option.st_options(), 
        "[ , APPEND MERGE0 MERGE(string asis) ]")
        option.st_get_aa()
        option.st_get_mm()
    }
    
    if ( cmd_define_gmappings() ) return
    
    cmd_define_st_define()
}

`Boolean' Elabel::cmd_define_pseudofcn()
{
    `SS' fcn, fargs, rest, elblnamelist
    
    pragma unset fcn
    pragma unset fargs
    pragma unset rest
    
    if ( !u_ispfcn(syntax.mappings(), fcn, fargs, rest) ) return(`False')
    
    stata("local pp : properties elabel_fcn_" + fcn)
    if ( anyof(tokens(st_local("pp")), "elabel_aa") ) {
        u_st_syntax(option.st_options(), "[ , APPEND * ]")
        option.st_get_aa()
    }
    if ( anyof(tokens(st_local("pp")), "elabel_mm") ) {
        u_st_syntax(option.st_options(), "[ , MERGE0 MERGE(string asis) * ]")
        option.st_get_mm()
        if ( option.mm() ) {
            st_local("options", st_local("options") + ///
            sprintf(`" merge(`"%s"')"', u_bslsq(option.sep())) )
            option.st_get_options()
        }
    }
    
    if ( cols(syntax.varvaluelabel()) ) {
        if ( anyof(tokens(st_local("pp")), "elabel_vvl") )
            syntax.anythingok(`True')
        else 
            syntax.varvaluelabelok(`False')
        elblnamelist = syntax.anything()
    }
    else elblnamelist = u_invtoken(syntax.labelnamelist())
    
    rest = (rest + option.print_opts())
    call_fcn("define", fcn, elblnamelist, fargs, rest)
    
    return(`True')
}

`Boolean' Elabel::cmd_define_is_recode()
{
    `TS' t
    `RS' popen
    `SS' tok
    `SR' opt_sep
    
    if ( !(popen=substr(syntax.mappings(), 1, 1)=="(") ) return(`False')
    t = tokeninit(" ", ("=", "(", ")"))
        tokenset(t, syntax.mappings())
    (void) tokenget(t) // known to be (
    if ( anyof(("", "="), tokenpeek(t)) ) return(`False')
    while ((tok=tokenget(t)) != "") {
        if      (tok == "(")     ++popen
        else if (tok == ")")     --popen
        if ( (tok=="=")|(!popen) ) break
    }
    if (tok != "=") return(`False')
    
    u_st_syntax(option.st_options(), 
    "[ , APPEND MERGE0 MERGE(string asis) noRETURN SEParator(string asis) ]")
    option.st_get_aa()
    option.st_get_mm()
    
    if ( cols(syntax.newlblnamelist()) )
        u_exerr(198, "recoding rules not allowed")
    
    if (cols((opt_sep=tokens(st_local("separator")))) > 1)
        u_exerr(198, "option separator() invalid")
    
    cmd_define_recode((st_local("return")!="noreturn"), opt_sep)
    
    return(`True')
}

void Elabel::cmd_define_recode(`Boolean' returnrules, `SR' opt_sep)
{
    `SR'                        lblnamelist
    `BooleanR'                  sel
    class Elabel_Rules__    `S' r
    `RC'                        vals
    `SC'                        text
    `RS'                        i, j
    `BooleanC'                  to, from, s
    
    lblnamelist = auniq( u_selectnm(syntax.lblnamelist()) )
    sel         = J(1, cols(lblnamelist), `True')
    
    vallbl = Elabel_ValueLabel( cols(lblnamelist) )
    r.set( syntax.mappings() )
    
    pragma unset vals
    pragma unset text
    
    for (i=1; i<=cols(lblnamelist); ++i) {
        st_vlload(lblnamelist[i], vals, text)
        to   = J(rows(r.from()), 1, `True')
        from = J(rows(r.from()), 1, `False')
        
        for (j=1; j<=rows(to); ++j) to[j] = anyof(vals, r.from()[j])
        if ( !(sel[i]=any(to)) ) continue
        
        vals = select(r.to(),   to)
        text = select(r.text(), to)
        
        if ( anyof(text, "") ) text = (text :+
            st_vlmap(lblnamelist[i], select(r.from(), to))
            :*(text:==""):*(!select(r.null(), to)) )
        
        if ( !option.replace() ) {
            if ( cols(opt_sep) ) {
                s = (select(r.text(), to) :== "")
                vallbl[i].setup(lblnamelist[i], 
                    select(vals, s), select(text, s), opt_sep)
                vals = (vallbl[i].vvec()\ select(vals, !s))
                text = (vallbl[i].tvec()\ select(text, !s))
            }
            for (j=1; j<=rows(from); ++j) 
                from[j] = ( !anyof(vals, r.from()[j]) )
            if ( any((from=(from:*to))) ) {
                vals = (vals\ select(r.from(), from))
                text = (text\ J(colsum(from), 1, ""))
            }
        }
        
        vallbl[i].setup(lblnamelist[i], vals, text)
        if ( option.add() & !option.aa() ) vallbl[i].assert_add()
    }
    
    vallbl = select(vallbl, sel)
    cmd_define_oneforeach()
    
    if (returnrules & (r.rules()!="")) {
        if (strlen(r.rules()) >= c("macrolen")) 
            u_exerr(920, "macro length exceeded")
        st_rclear()
        st_global("r(rules)", r.rules())
    }
}

`Boolean' Elabel::cmd_define_gmappings()
{
    `TS'      vspec, lspec
    `Boolean' is_veexp, is_leexp
    `RS'      rv, rl
    
    pragma unset vspec
    pragma unset lspec
    
    if ( !u_isgmappings(syntax.mappings(), vspec, lspec) ) return(`False')
    
    if ( !(is_veexp=u_iseexp(vspec, vspec)) ) vspec = elabel_numlist(vspec)
    if ( !(is_leexp=u_iseexp(lspec, lspec)) ) lspec = tokens(lspec)'
    
    if ( !(is_veexp|is_leexp) ) {
        if ((rv=rows(vspec)) != (rl=rows(lspec))) {
            if (rl != 1) u_err_fewmany((rl-rv), "labels")
            lspec = J(rv, 1, lspec)
        }
        cmd_define_onefitsall(vspec, lspec)
    }
    else cmd_define_eexp(vspec, is_veexp, lspec, is_leexp)              
    
    return(`True')
}

void Elabel::cmd_define_eexp(`TC' vspec, `Boolean' is_veexp,
                             `TC' lspec, `Boolean' is_leexp)
{
    class Elabel_eExp `S'       e
    `SR'                        lblnamelist
    `BooleanR'                  sel
    `RS'                        i
    `RC'                        vals
    `SC'                        text
    
    if (is_veexp) {
        e.eexp(vspec)
        if ( !anyof((0, 109), e.get_rc()) ) e.eexp()
        if ( !isreal(e.eexp()) )    exit(error(109))
        if ( cols(syntax.newlblnamelist()) & e.hashash() )
            u_exerr(198, "# not allowed in {it:eexp}")
    }
    if (is_leexp) {
        e.eexp(lspec)
        if ( !anyof((0, 109), e.get_rc()) ) e.eexp()
        if ( !isstring(e.eexp()) )  exit(error(109))
        if ( cols(syntax.newlblnamelist()) & e.hasat() )
            u_exerr(198, "@ not allowed in {it:eexp}")
    }
    if ( cols(syntax.newlblnamelist()) & (is_veexp&is_leexp) )
        u_exerr(198, "{it:eexp} not allowed in {it:valspec}")
    
    lblnamelist = auniq( u_selectnm(syntax.labelnamelist()) )
    sel         = J(1, cols(lblnamelist), `True')
    
    vallbl = Elabel_ValueLabel( cols(lblnamelist) )
    
    if ( (!is_veexp) & is_leexp ) {     // (numlist) (=eexp)
        u_assert_nosysmiss(vspec)
        for (i=1; i<=cols(lblnamelist); ++i) {
            e.wildcards(vspec, st_vlmap(lblnamelist[i], vspec))
            e.eexp(lspec)
            vallbl[i].setup(lblnamelist[i], vspec, e.eexp())
            if ( option.add() & (!option.aa()) ) vallbl[i].assert_add()
        }
    }
    else if ( is_veexp & (!is_leexp) ) { // (=eexp) (lblspec)
        for (i=1; i<=cols(lblnamelist); ++i) {
            e.wildcards(st_vlsearch(lblnamelist[i], lspec), lspec)
            e.eexp(vspec)
            vallbl[i].setup(lblnamelist[i], e.eexp(), lspec)
            if ( vallbl[i].sysmiss() ) exit(error(180))
            if ( option.add() & (!option.aa()) ) vallbl[i].assert_add()
        }
    }
    else if ( is_veexp & is_leexp ) {    // (=eexp) (=eexp)
        pragma unset vals
        pragma unset text
        for (i=1; i<=cols(lblnamelist); ++i) {
            st_vlload(lblnamelist[i], vals, text)
            if ( !(sel=(rows(vals)|rows(text))) ) continue
            e.wildcards(vals, text)
            e.eexp(vspec)
            vals = e.eexp()
            e.eexp(lspec)
            vallbl[i].setup(lblnamelist[i], vals, e.eexp())
            if ( vallbl[i].sysmiss() ) exit(error(180))
            if ( option.add() & (!option.aa()) ) vallbl[i].assert_add()
        }
        vallbl = select(vallbl, sel)
    }
    else u_assert0("cmd_define_eexp()")
    
    cmd_define_oneforeach()
}

void Elabel::cmd_define_st_define()
{
    `SS' lblname
    `RC' vspec
    `RS' nc
    `SR' map
    
    if ( !(option.aa()|option.mm()) ) {
        if (cols((lblname=u_selectnm(syntax.labelnamelist()))) == 1) {
            u_st_exe( sprintf("_label define %s %s%s", lblname, 
                syntax.mappings(`False'), option.printamrnf()) )
            varvaluelabel(syntax.varvaluelabel(), option.fixfmt())
            return
        }
    }
    
    pragma unset vspec
    if ( mod((nc=cols(map=tokens(syntax.mappings()))), 2) ) exit(error(198))
    if ( _strtoreal(select(map, mod((1..nc), 2))', vspec) ) exit(error(198))
    u_assert_nosysmiss(vspec)
    cmd_define_onefitsall(vspec, select(map, !mod((1..nc), 2))')
}

void Elabel::cmd_define_onefitsall(`RC' vspec, `SC' lspec)
{
    `SR' lblnamelist
    `RS' i
    
    vallbl.setup("name", vspec, lspec)
    
    if ( option.add() & !option.aa() ) {
        lblnamelist = u_selectnm(syntax.lblnamelist())
        for (i=1; i<=cols(lblnamelist); ++i) {
            vallbl.name(syntax.lblnamelist()[i])
            vallbl.assert_add()
        }
    }
    
    lblnamelist = u_selectnm(syntax.labelnamelist())
    
    breakoff()
    if ( option.aa() ) {
        for (i=1; i<=cols(lblnamelist); ++i) {
            vallbl.name(lblnamelist[i])
            vallbl.append(option.fixfmt())
        }
    }
    else if ( option.mm() ) {
        for (i=1; i<=cols(lblnamelist); ++i) {
            vallbl.name(lblnamelist[i])
            vallbl.append(option.fixfmt(), option.sep())
        }
    }
    else if ( option.add()|option.modify() ) {
        for (i=1; i<=cols(lblnamelist); ++i) {
            vallbl.name(lblnamelist[i])
            vallbl.modify(option.add(), option.fixfmt())
        }
    }
    else {
        for (i=1; i<=cols(lblnamelist); ++i) {
            vallbl.name(lblnamelist[i])
            vallbl.define(option.replace(), option.fixfmt())
        }
    }
    breakreset()
    
    varvaluelabel(syntax.varvaluelabel(), option.fixfmt())
}

void Elabel::cmd_define_oneforeach()
{
    `RS' nc, i
    
    if ( !(nc=cols(vallbl)) ) return
    
    breakoff()
    if ( option.aa() )
        for (i=1; i<=nc; ++i) vallbl[i].append(option.fixfmt())
    else if ( option.mm() )
        for (i=1; i<=nc; ++i) vallbl[i].append(option.fixfmt(), option.sep())
    else if ( option.add()|option.modify() )
        for (i=1; i<=nc; ++i) vallbl[i].modify(option.add(), option.fixfmt())
    else 
        for (i=1; i<=nc; ++i) vallbl[i].define(option.replace(), option.fixfmt())
    breakreset()
    
    varvaluelabel(syntax.varvaluelabel(), option.fixfmt())
}

        // ------------------------------ cmd_values
void Elabel::cmd_values()
{    
    u_st_syntax(zero, "anything(id = varlist) [ , noFIX ]")
    option.st_get()
    
    if ( cmd_values_gmappings(st_local("anything")) ) return
    
    cmd_values_values(st_local("anything"))
}

`Boolean' Elabel::cmd_values_gmappings(`SS' mappings)
{
    `SR'      varlist, lbllist
    `SS'      lblname, tok
    `TS'      t
    `RS'      i
    
    pragma unset varlist
    pragma unset lblname
    pragma unset lbllist
    
    if ( !u_isgmappings(mappings, varlist, lblname) ) return(`False')
    
    varlist = u_st_numvarlist(varlist)
    
    syntax.newlblnameok(`True')
    t = tokeninit(" ", " .", "()")
        tokenset(t, (char(32)+lblname))
    while ((tok=tokenget(t)) != "") {
        if      (tok == ".")       lbllist = (lbllist, "")
        else if ( st_isname(tok) ) lbllist = (lbllist, tok)
        else {
            syntax.set(tok)
            u_err_notallowed(syntax.options(), "options")
            u_err_notallowed(syntax.iff_eexp(),    "iff")
            if (syntax.mappings() != "") 
                u_assert_name( tokens(syntax.mappings())[1] )
            lbllist = (lbllist, u_selectnm(syntax.labelnamelist(), `False'))
        }
    }
    
    u_err_fewmany(((i=cols(lbllist))-cols(varlist)), "label names")
    
    breakoff()
    if ( !option.fixfmt() ) 
        while (i) st_varvaluelabel(varlist[i], lbllist[i--])
    else {
        tok = sprintf("_label values %%s %%s")
        while (i) (void) _stata(sprintf(tok, varlist[i], lbllist[i--]))
    } 
    breakreset()
    
    return(`True')
}

void Elabel::cmd_values_values(`SS' mappings)
{
    `TS'      t
    `RS'      ncol, i
    `SR'      varlist
    `SS'      lblname, stcmd
    
    t = tokeninit(" ", "-", "()")
        tokenset(t, mappings)
    if ( (ncol=cols((varlist=tokengetall(t)))) > 1 ) {
        if (varlist[ncol-1] != "-") {
            lblname = varlist[ncol]
            varlist = varlist[(1..(ncol-1))]
        }
        if (lblname == ".") lblname = ""
    }
    
    if ( any(regexm(varlist, "^(\(.*\))$")) ) 
        u_exerr(198, "%s invalid name", regexs(1))
    
    varlist = u_st_numvarlist(invtokens(varlist))

    if (lblname != "") {
        syntax.newlblnameok(`True')
        syntax.set(lblname)
        u_err_notallowed(syntax.options(), "options")
        u_err_notallowed(syntax.iff_eexp(),    "iff")
        if (syntax.mappings() != "") 
            u_assert_name( tokens(syntax.mappings())[1] )
        if (cols(u_selectnm(syntax.labelnamelist())) > 1)
            u_exerr(198, "too many label names specified")
        lblname = u_selectnm(syntax.labelnamelist(), `False')
    }    
    
    breakoff()
    i = cols(varlist)
    if ( !option.fixfmt() ) while ( i ) st_varvaluelabel(varlist[i--], lblname)
    else {
        stcmd = sprintf("_label values %%s %s", lblname)
        while (i) (void) _stata(sprintf(stcmd, varlist[i--]))
    }
    breakreset()
}

        // ------------------------------ cmd_dir
void Elabel::cmd_dir()
{
    `SS'         ptrn
    `SC'         undef, orphans, used, rnames
    
    if ( anyof(("", ","), strtrim(zero)) ) {
        (void) _stata("_label dir")
        return
    }
    
    ptrn = ( (tokenpeek(t_zero)!=",") ? tokenget(t_zero) : "" )
    u_st_syntax(tokenrest(t_zero), "[ , noMEMory CURrent ]")
    option.st_get()
    
    pragma unset undef
    pragma unset orphans
    pragma unset used
    
    elabel_dir( undef, orphans, used, !option.current() )
    
    cmd_dir_match(ptrn, undef, orphans, used)
    cmd_dir_print( (rnames=(used\ orphans)), undef )
    
    st_rclear()
    if (option.nomem()) {
        st_global("r(orphans)"  , u_invtoken(orphans'))
        st_global("r(undefined)", u_invtoken(undef'))
        st_global("r(used)"     , u_invtoken(used'))
    }
    st_global("r(names)", u_invtoken(rnames'))
}

void Elabel::cmd_dir_match(`SS' ptrn, `SC' undef, `SC' orphans, `SC' used)
{
    if (ptrn == "")       return
    if (  rows(undef) )   undef   = select(undef, strmatch(undef, ptrn))
    if ( !rows(undef) )   undef   = J(0, 1, "")
    if (  rows(orphans) ) orphans = select(orphans, strmatch(orphans, ptrn))
    if ( !rows(orphans) ) orphans = J(0, 1, "")
    if (  rows(used) )    used    = select(used, strmatch(used, ptrn))
    if ( !rows(used) )    used    = J(0, 1, "")
}

void Elabel::cmd_dir_print(`SC' rnames, `SC' undef)
{
    `RS' i
    
    if ( !c("noisily") ) return
    for (i=1; i<=rows(rnames); ++i) printf("{res}%s\n", rnames[i])
    if ( !(option.nomem() & rows(undef)) ) return
    for (i=1; i<=rows(undef); ++i) printf("{res}%s{txt}*\n", undef[i])
    printf("\n{txt}Note: * indicates value label is not stored in memory\n")
}

        // ------------------------------ cmd_list
void Elabel::cmd_list()
{
    `Boolean' opt_varlist
    `SR'      lblnamelist
    `RS'      ncol
    `SS'      values, labels
    
    syntax.anythingok(`True')
    syntax.set(zero)
    u_st_syntax(syntax.options(), "[ , VARlists noMEMory CURrent ]")
    u_err_notallowed( syntax.mappings() )
    opt_varlist = (st_local("varlists") == "varlists")
    option.st_get()
    
    syntax.anythingok(`False')
    if ( option.nomem() ) {
        syntax.nomem( option.nomem() )
        syntax.mlang( !option.current() )
    }
    
    if ( !cols((lblnamelist=syntax.lblnamelist())) )
        lblnamelist = syntax.nomem() ? syntax.allnames()' : syntax.rnames()'
    
    if ( !(ncol=cols(lblnamelist)) ) return
    
    if ( c("noisily") & (ncol>1) ) cmd_list_print(lblnamelist, ncol)
        
    pragma unset values
    pragma unset labels
    
    vallbl.setup(lblnamelist[ncol])
    vallbl.markiff( syntax.iff_eexp() )
    vallbl.list(values, labels, c("noisily"))
    
    st_rclear()
    
    st_numscalar("r(min)",      min( vallbl.vvec() ) )
    st_numscalar("r(max)",      max( vallbl.vvec() ) )
    st_numscalar("r(hasemiss)", (vallbl.nemiss() > 0))
    st_numscalar("r(nemiss)",   vallbl.nemiss()      )
    st_numscalar("r(k)",        vallbl.k()           )
    
    if (vallbl.name() == "")    return
    
    if (opt_varlist) {
        cmd_list_rvars()
        st_global("r(varlist)", u_invtoken( vallbl.usedby() ))
    }
    
    if ( option.nomem() ) 
        st_numscalar("r(exists)", st_vlexists(vallbl.name()))
    
    st_global("r(labels)", labels)
    st_global("r(values)", values)
    st_global("r(name)",   vallbl.name())
}

void Elabel::cmd_list_print(`SR' lblnamelist, `RS' ncol)
{
    `RS' i    
    if ( (syntax.iff_eexp()!="")|(option.nomem()) ) {
        for (i=1; i<ncol; ++i) {
            vallbl.setup(lblnamelist[i])
            vallbl.markiff( syntax.iff_eexp() )
            vallbl._list()
        }
    }
    else (void) _stata("_label list "+u_invtoken(lblnamelist[(1..(ncol-1))]))
}

void Elabel::cmd_list_rvars()
{
    `RS'      i, k
    `SR'      vars
    `SS'      lvar
    
    st_numscalar("r(k_languages)", rows( syntax.langs() ))
    
    if ( !rows(syntax.langs()) ) return
    
    lvar = ("")
    for (i=1; i<=rows(syntax.langs()); ++i) {
        vars = J(1, 0, "")
        for (k=1; k<=st_nvar(); ++k) {
            if ( u_get_varvaluelabel(k, syntax.langs()[i]) == vallbl.name() )
                vars = (vars, st_varname(k))
        }
        if ( cols(vars) ) lvar = sprintf("%s (%s %s)", 
            lvar, syntax.langs()[i], u_invtoken(vars) )
    }
    
    st_global("r(languages)", u_invtoken(syntax.langs()'))
    st_global("r(language)",  syntax.clang())
    st_global("r(lvarlists)", strltrim(lvar))
}

        // ------------------------------ cmd_copy
void Elabel::cmd_copy()
{
    `SR' lblnames
    
    syntax.newlblnameok(`True')
    syntax.varvaluelabelok(`True')
    syntax.set(zero)
    u_st_syntax(syntax.options(), 
    "[ , Add MODIFY REPLACE APPEND MERGE0 MERGE(string asis) noFIX ]")
    option.st_get()
    option.st_get_aa()
    option.st_get_mm()
    u_err_notallowed( syntax.mappings() )
    
    lblnames = u_selectnm(syntax.labelnamelist())
    
    u_err_fewmany((cols(lblnames)-2), "names")
    u_assert_lblname(lblnames[1])
    
    vallbl.setup(lblnames[1])
    vallbl.markiff( syntax.iff_eexp() )
    vallbl.setup(lblnames[2], vallbl.vvec(), vallbl.tvec() )
    if ( option.aa() ) 
        vallbl.append( option.fixfmt() )
    else if ( option.mm() ) 
        vallbl.append( option.fixfmt(), option.sep() )
    else if (option.add()|option.modify()) 
        vallbl.modify( option.add(), option.fixfmt() )
    else vallbl.define( option.replace(), option.fixfmt() )
    
    varvaluelabel(syntax.varvaluelabel(), option.fixfmt())
}

        // ------------------------------ cmd_drop
void Elabel::cmd_drop(| `RS' drop)
{
    syntax.set(zero)
    if (drop) u_err_notallowed(syntax.options(),  "options")
    else {
        syntax.varvaluelabelok(`True')
        u_st_syntax(syntax.options(), "[ , noFIX ]")
    }
    u_err_notallowed( syntax.mappings() )
    u_err_notallowed(syntax.iff_eexp(), "iff")
    if ( !rows(syntax.rnames()) & (syntax.set()!="") ) return 
    if ( !cols(syntax.lblnamelist()) ) u_exerr(100, "name or _all required")
    
    if (drop) cmd_drop_labels( syntax.lblnamelist() )
    else {
        cmd_drop_labels( anotb(syntax.rnames()', syntax.lblnamelist()) )
        varvaluelabel(syntax.varvaluelabel(), (st_local("fix")!="nofix"))
    }
}

void Elabel::cmd_drop_labels(`SR' lblnamelist)
{
    `RS' i
    
    if ( !cols(lblnamelist) ) return
    breakoff()
    for (i=1; i<=cols(lblnamelist); ++i) st_vldrop(lblnamelist[i])
    breakreset()
}

        // ------------------------------ cmd_save
void Elabel::cmd_save()
{
    syntax.usingword("using")
    syntax.set(zero)
    u_st_syntax(syntax.options(), "[ , REPLACE OPTION(string asis) ]")
    u_err_notallowed( syntax.mappings() )
    u_err_required(syntax.filename(), "using")
    
    if ( (syntax.iff_eexp()=="") & (st_local("option")=="") ) {
        u_st_exe(sprintf("_label save %s using %s%s", 
            u_invtoken( syntax.lblnamelist() ), 
            syntax.filename(), syntax.options())    )
    }
    else cmd_save_elabel()
}

void Elabel::cmd_save_elabel()
{
    `SS'               option, filename
    `SR'               lblnamelist
    `RS'               rc, fh, i, k
    
    option = cmd_save_option()
    
    filename = u_invtoken(tokens( syntax.filename() ))
    if (pathsuffix(filename) == "") filename = (filename + ".do")
    u_assert_newfile(filename, (st_local("replace")=="replace"))
    
    if ( !cols((lblnamelist=syntax.lblnamelist())) ) 
        lblnamelist = syntax.rnames()'
    
    breakoff()
    if ( fileexists(filename) ) { 
        if ( (rc=_unlink(filename)) ) exit(error(abs(rc)))
    }
    if ((fh=_fopen(filename, "w")) < 0) exit(error(abs(fh)))
    for (i=1; i<=cols(lblnamelist); ++i) {
        vallbl.setup(lblnamelist[i])
        vallbl.markiff( syntax.iff_eexp() )
        for (k=1; k<=vallbl.k(); ++k) {
            u_fput(fh, sprintf(`"label define %s %f `"%s"'%s"', 
            vallbl.name(), vallbl.vvec()[k], u_bslsq(vallbl.tvec()[k]), 
            ((k>1)&(option!=", add") ? ", modify" : option)) )
        }
    }
    fclose(fh)
    breakreset()
    printf("{txt}file %s saved\n", filename)
}

`SS' Elabel::cmd_save_option()
{
    `SR' option
    if (cols((option=tokens(st_local("option")))) < 2) {
        if ( (!cols(option)) | (option=="modify") ) return(", modify")
        if (option == "none")                       return("")
        if ( u_unabbr(option, "a:dd") )             return(", add")
        if (option == "replace")                    return(", replace")
    }
    errprintf("invalid option()\n%s not allowed\n", option[cols(option)])
    exit(198)
}

        // ------------------------------ cmd_language
void Elabel::cmd_language()
{
    `SS' option, lname, filename
    `RS' rc, fh
    
    u_st_syntax(zero, "[ name ] [ , SAVing(passthru) * ]")    
    if (st_local("saving") == "") {
        u_st_exe("_label language " + zero)
        return
    }
        
    u_st_syntax(zero, "[ name ] , SAVing(string asis) [ OPTION(string asis) ]")
    option = cmd_save_option()
    if ((lname=st_local("namelist")) == "") lname = syntax.clang()
    else if ( !anyof(syntax.langs(`False'), lname) )
        u_exerr(111, "language %s not defined", lname)
    
    u_st_syntax("using " + st_local("saving"), "using/ [ , REPLACE ]")
    if (pathsuffix((filename=st_local("using"))) == "") 
        filename = (filename + ".do")
    u_assert_newfile(filename, (st_local("replace")=="replace"))
    
    breakoff()
    if (fileexists(filename)) 
        if (rc=_unlink(filename)) exit(error(abs(rc)))
    if ((fh=_fopen(filename, "w")) < 0) exit(error(abs(fh)))
    u_fput(fh, sprintf("label language %s, new", lname))
    cmd_language_saving(fh, (lname==syntax.clang() ? "" : lname), option)
    fclose(fh)
    breakreset()
    printf("{txt}file %s saved\n", filename)
}

void Elabel::cmd_language_saving(`RS' fh, `SS' lname, `SS' option)
{
    `TS' A
    `RC' v
    `SC' t
    `SS' label, varname
    `RS' rc, k, kk
    
    A = asarray_create()
    
    pragma unset v
    pragma unset t
    
    if (lname == "") {
        (void) _stata("local datalabel : data label")
        label = st_local("datalabel")
    }
    else label = st_global(sprintf("_dta[_lang_v_%s]", lname))
    fput(fh, sprintf(`"label data `"%s"'"', u_bslsq(label)))
    
    for (k=1; k<=st_nvar(); ++k) {
        label = u_bslsq(u_get_varlabel((varname=st_varname(k)), lname))
        u_fput(fh, sprintf(`"label variable %s `"%s"'"', varname, label))
        if ( st_isstrvar(k) ) continue
        label = u_get_varvaluelabel(varname, lname)
        u_fput(fh, sprintf("label values %s %s", varname, label))
        if ( (label=="") | asarray_contains(A, label) ) continue
        st_vlload(label, v, t)
        for (kk=1; kk<=rows(v); ++kk) {
            u_fput(fh, sprintf(`"label define %s %f `"%s"'%s"', 
                                  label, v[kk], u_bslsq(t[kk]), 
            ((kk>1)&(option!=", add") ? ", modify" : option)) ) 
        }
        asarray(A, label, `True')
    }
}

        // ------------------------------ cmd_passthru
void Elabel::cmd_passthru()
{
    if ( !(_stata("program list elabel_cmd_" + subcmd, `True')) )
        outsource("elabel_cmd_" + cmdline)
    else if ( !(_stata("which elabel_cmd_" + subcmd, `True')) )
        outsource("elabel_cmd_" + cmdline)
    else {
        if ( (statasetversion()>1600) & c("noisily") )  
            printf("{inp}{asis}. label %s{smcl}\n{sf}", cmdline)
        outsource("label " + cmdline)
    }
}

        // ------------------------------ cmd_c_locals
void Elabel::cmd_c_locals()
{
    `SR' lmacnames
    if (tokenpeek(t_zero) == "") exit(error(198))
    u_assert_name( ("_":+(lmacnames=tokens(zero))) )
    clmacnames = (clmacnames, lmacnames)
}

        // ------------------------------ cmd_cmd
void Elabel::cmd_cmd() outsource("elabel_cmd_" + strltrim(zero))

        // ------------------------------ cmd_confirm
void Elabel::cmd_confirm()
{
    `TS'                  t
    `SR'                  tok
    `SS'                  att
    `RS'                  n, i
    `Boolean'             uniq
    class Elabel_Unab `S' u
    
    u_st_syntax(zero, "[ anything(equalok everything) ] [ , EXact ]")
    
    t = tokeninit(" ", ",")
        tokenset(t, st_local("anything"))
        
    pragma unset n
    if ( !(_strtoreal(tokenpeek(t), n)) ) {
        if ( (n>=.) | (n<0) | (n!=trunc(n)) ) exit(error(198))
        (void) tokenget(t)
        if ( (uniq=u_unabbr(tokenpeek(t), "uniq:ue")) ) (void) tokenget(t)
    }
    else uniq = `False'
    
    if ( anyof(("new", "used"), (tok=att=tokenget(t))) ) tok = tokenget(t)
    if ( !u_unabbr(tok, "lbl:names") )                    exit(error(198))
    tok = tokengetall(t)
    
    if (att == "new") u_assert_newlblname(tok)
    else if (att == "used") {
        if ( !cols(tok) ) u_exerr(7, "'' found where name expected")
        for (i=1; i<=cols(tok); ++i) {
            u_assert_name(tok[i])
            if ( anyof(u.attached(), tok[i]) ) continue
            u_exerr(498, "value label %s not used by any variable", tok[i])
        }
    }
    else if (st_local("exact") != "exact") u_assert_lblname(tok)
    else {
        u_assert_name(tok)
        (void) elabel_unab(tok)
    }
    
    if (n < .)  u_err_fewmany((cols(tok)-n), "label names")
    if ( uniq ) u_assert_uniq(tok, "value label")
}

        // ------------------------------ cmd_duplicates
void Elabel::cmd_duplicates()
{
    `SR'      lblnamelist
    `TS'      A
    
    subcmd = tokenget(t_zero)
    zero   = tokenrest(t_zero)
    
    if      ( u_unabbr(subcmd, "rep:ort") ) subcmd = "report"
    else if ( u_unabbr(subcmd, "remove")  ) subcmd = "remove"
    else if ( u_unabbr(subcmd, "retain")  ) subcmd = "retain"
    else if ( u_unabbr(subcmd, "sel:ect") ) subcmd = "retain"
    else u_exerr(198, "elabel duplicates invalid subcommand %s", subcmd)
    
    syntax.iffword("")
    syntax.set(tokenrest(t_zero))
    if (subcmd == "report" ) u_st_syntax(syntax.options(), "[ , List ]")
    else u_err_notallowed(syntax.options(), "options")
    u_err_notallowed( syntax.mappings() )
    
    if ( !cols(lblnamelist=syntax.lblnamelist()) ) {
        if (subcmd == "report") lblnamelist = syntax.rnames()'
        else u_exerr(100, "label name required")
    }
    
    A = asarray_create()
    
    if (subcmd == "remove") {
        breakoff()
        cmd_duplicates_remove(lblnamelist, A)
        breakreset()
        return
    }
    
    cmd_duplicates_get(lblnamelist, A, (subcmd=="retain"))
    breakoff()
    if ( (cols(lblnamelist)<2) | (subcmd=="retain") ) 
        cmd_duplicates_of(A, (subcmd=="retain"))
    if (subcmd == "report") 
        cmd_duplicates_report(A, (st_local("list")=="list"))
    breakreset()
}

void Elabel::cmd_duplicates_of(`TS' A, `Boolean' rm)
{
    `RS' i
    `SS' key
    
    pragma unset key
    
    for (i=1; i<=rows(syntax.rnames()); ++i) {
        if ( asarray_contains(A, syntax.rnames()[i]) )         continue
        if ( !cmd_duplicates_key(key, A, syntax.rnames()[i]) ) continue
        if ( rm ) cmd_duplicates_rm(asarray(A, key), syntax.rnames()[i])
        else      asarray(A, key, (asarray(A, key), syntax.rnames()[i]))
    }
}

void Elabel::cmd_duplicates_get(`SR' lblnamelist, `TS' A, `Boolean' nodup)
{
    `RS' i
    `SS' key
    
    pragma unset key
    
    for (i=1; i<=cols(lblnamelist); ++i) {
        if ( asarray_contains(A, lblnamelist[i]) ) continue
        if ( cmd_duplicates_key(key, A, lblnamelist[i]) ) {
            if ( nodup ) {
                errprintf("value labels %s ", asarray(A, key))
                errprintf("and %s are identical\n", lblnamelist[i])
                exit(498)            
            }
            asarray(A, key, (asarray(A, key), lblnamelist[i]))
        }
        else asarray(A, key, lblnamelist[i])
    }
}

void Elabel::cmd_duplicates_report(`TS' A, `Boolean' listopt)
{
    `RS' i, n
    `TM' loc
    `SC' cnt
    
    st_rclear()
    
    i = 0
    for (loc=asarray_first(A); loc!=NULL; loc=asarray_next(A, loc)) {
        if ((n=cols(cnt=asarray_contents(A, loc))) < 2) continue
        printf("\n{txt}value label {res:%s} has ", cnt[1])
        printf("{res:%f} duplicate%s: ", --n, ((n>1) ? "s" : ""))
        printf("{res:%s}", invtokens(cnt[2..++n]))
        st_numscalar(sprintf("r(n_duplicates%f)", ++i), n)
        st_global(sprintf("r(duplicates%f)", i), invtokens(cnt))
        if ( !listopt ) continue
        printf("\n")
        vallbl.setup(cnt[1])
        vallbl.list()
    }
    if ( i & (!listopt) ) printf("\n")
    st_numscalar("r(N_duplicates)", i)
}

void Elabel::cmd_duplicates_remove(`SR' lblnamelist, `TS' A)
{
    `RS' i
    `SS' key
    
    pragma unset key
    
    for (i=1; i<=cols(lblnamelist); ++i) {
        if ( asarray_contains(A, lblnamelist[i]) ) continue
        if ( !cmd_duplicates_key(key, A, lblnamelist[i]) ) 
            asarray(A, key, lblnamelist[i])
        else cmd_duplicates_rm(asarray(A, key), lblnamelist[i])
    }
}

void Elabel::cmd_duplicates_rm(`SS' keepname, `SS' dropname)
{
    st_vldrop(keepname)
    elabel_rename(dropname, keepname, `False', `False')
    printf("{txt}value label {res:%s} removed;", dropname)
    printf(" retained value label {res:%s}\n",   keepname)        
}

`Boolean' Elabel::cmd_duplicates_key(`TS' key, `TS' A, `SS' lblname)
{
    `RC' v
    `SC' t
    
    asarray(A, lblname, lblname)
    
    pragma unset v
    pragma unset t
    
    st_vlload(lblname, v, t)
    key = invtokens(strofreal(v)') + invtokens(t')
    
    return( asarray_contains(A, key) )
}

        // ------------------------------ cmd_fcncall
void Elabel::cmd_fcncall()
{
    `SS' callercmd, lmacname1, lmacname2, lmacname3, names, ccmd, tok
    
    tokenpchars(t_zero, ":")
    
    if ((callercmd=tokenget(t_zero)) != "*") {
        if ( u_unabbr(callercmd, "var:iables")   ) callercmd = "variable"
        else if ( u_unabbr(callercmd, "de:fine") ) callercmd = "define"
        else                                       exit( error(197) )
    }
    
    lmacname1 = tokenget(t_zero)
    lmacname2 = tokenget(t_zero)
    lmacname3 = tokenget(t_zero)
    
    if ( anyof((":", ""), (tok=lmacname3)) ) {
        lmacname3 = lmacname2
        lmacname2 = lmacname1
    }
    
    if ( !u_assert_name( ("_":+(lmacname1, lmacname2, lmacname3)), 0 ) ) 
        exit( error(197) )
    
    if (tok != ":") {
        if ( (tok=tokenget(t_zero)) != ":" ) {
            if ( (statasetversion()<1600) | (tok!="") ) exit( error(197) )
            tokenset(t_zero, st_local0()) 
        }
    }
    
    if ( !anyof(("variable", "define"), (ccmd=tokenget(t_zero))) ) 
        u_exerr(497, "'%s' found where variable or define expected", ccmd)
    
    if ( !anyof(("*", ccmd), callercmd) ) 
        u_exerr(198, "elabel %s: unknown (pseudo-) function", ccmd)
    
    tokenwchars(t_zero,  "")
    tokenpchars(t_zero, "=")
    names = tokenget(t_zero)
    if ((tok=tokenget(t_zero)) != "=") 
        u_exerr(497, "'%s' found where = expected", tok)
    
    st_local(lmacname1, strtrim(ccmd))
    st_local(lmacname2, strtrim(names))
    st_local(lmacname3, strltrim(tokenrest(t_zero)))
    c_locals( (lmacname1, lmacname2, lmacname3) )
}

        // ------------------------------ cmd_numlist
void Elabel::cmd_numlist()
{
    `SR'      caller_nlist
    `TM'      nlist
    `Boolean' intonly, nosysmiss
    
    u_st_syntax(zero, "[ anything(equalok everything) ]"  +
    "[ , REALokay SYSMISsokay Local(name local) DISPLAY ]")
    
    caller_nlist = tokens(st_local("anything"))
    if (cols(caller_nlist) != 1) exit( error(198) )
    intonly   = (st_local("realokay")    != "realokay")
    nosysmiss = (st_local("sysmissokay") != "sysmissokay")
    
    nlist = elabel_numlist(caller_nlist, intonly, nosysmiss)
    nlist = u_invtoken(strofreal(nlist'))
    if (strlen(nlist) >= c("macrolen")) u_exerr(920, "macro length exceeded")
    
    if (st_local("local") != "") {
        st_local(st_local("local"), nlist)
        c_locals(st_local("local"))
    }
    else {
        st_rclear()
        st_global("r(numlist)", nlist)
    }
    
    if (st_local("display") == "display") printf("{txt}%s\n", nlist)
}

        // ------------------------------ cmd_parse
struct Elabel_DoS_
{
    `Boolean' elblnamelist
    `Boolean' newlblnamelist
    `Boolean' anything
    `Boolean' mappings
    `Boolean' iff_eexp
    `SS'      iffword
    `Boolean' filename
    `SS'      options
    
    `Boolean' vvlbl
    `Boolean' nomem
    `Boolean' mlang
    `Boolean' abbrv
    `Boolean' split
    `Boolean' broad
}

void Elabel::cmd_parse()
{
    struct Elabel_DoS_ `S' dos
    
    tokenwchars(t_zero,  "")
    tokenpchars(t_zero, ":")
    
    if (tokenpeek(t_zero) != ":") cmd_parse_descr_of_str(dos)
    else (void) tokenget(t_zero)
    cmd_parse_str_to_parse(dos)
}

void Elabel::cmd_parse_descr_of_str(struct Elabel_DoS_ `S' dos)
{
    `TS'      t
    `SS'      tok
    `Boolean' opt
    
    t = tokeninit(" ", (",", "[", "]"), (`""""', `"`""'"', "()"))
        tokenset(t, tokenget(t_zero))
    
    if ((tok=tokenget(t_zero)) != ":") {
        if ( (statasetversion()<1600) | (tok!="") ) exit( error(197) )
        tokenset(t_zero, st_local0())
    }
    
    while ((tok=tokenget(t)) != "") {
        if ( (opt=(tok=="[")) ) tok = tokenget(t)
        if ( tok == ",") {
            dos.options = (("["*opt)+" , "+tokenrest(t))
            break
        }
        else if ( u_unabbr(tok, "elbl:namelist") ) {
            cmd_parse_descr_of_str_element(dos.elblnamelist, opt)
            cmd_parse_descr_of_str_lblspec(dos, t)
        }
        else if ( u_unabbr(tok, "newlbl:namelist") ) {
            cmd_parse_descr_of_str_element(dos.newlblnamelist, opt)
            cmd_parse_descr_of_str_lblspec(dos, t)
        }
        else if ( u_unabbr(tok, "anything") ) {
            cmd_parse_descr_of_str_element(dos.anything, opt)
        }
        else if ( u_unabbr(tok, "map:pings") ) {
            cmd_parse_descr_of_str_element(dos.mappings, opt)
            cmd_parse_descr_of_str_mapspec(dos, t)
        }
        else if (tok == "iff") {
            cmd_parse_descr_of_str_element(dos.iff_eexp, opt)
            dos.iffword = "iff"
        }
        else if (tok == "using") {
            cmd_parse_descr_of_str_element(dos.filename, opt)
        }
        else if ( (statasetversion()<1600) & (tok=="if") ) {
            cmd_parse_descr_of_str_element(dos.iff_eexp, opt)
            dos.iffword = "if"
        }
        else exit(error(197))
        if ( !opt ) continue
        if (tokenget(t) != "]") exit(error(197))
    }
    
    if (  missing(dos.anything)       ) return
    if ( !missing(dos.elblnamelist)   ) exit(error(197))
    if ( !missing(dos.newlblnamelist) ) exit(error(197))
}

void Elabel::cmd_parse_descr_of_str_element(`Boolean' el, `Boolean' opt)
{
    if ( !missing(el) ) exit(error(197))
    el = (!opt)
}

void Elabel::cmd_parse_descr_of_str_lblspec(struct Elabel_DoS_ `S' dos,
                                            `TS'                     t)
{
    `SR' spec
    `RS' i
    
    if ( !regexm(tokenpeek(t), "^\((.*)\)$") ) return
    spec = tokens(regexs(1))
    for (i=1; i<=cols(spec); ++i) {
        if ( u_unabbr(spec[i], "varval:uelabels") ) 
            dos.vvlbl = `True'
        else if ( u_unabbr(spec[i], "nomem:ory") ) 
            dos.nomem = `True'
        else if ( u_unabbr(spec[i], "cur:rent") ) {
            dos.nomem = `True'
            dos.mlang = `False'
        }
        else if ( u_unabbr(spec[i], "abbrev:okay") ) 
            dos.abbrv = `True'
        else if ( u_unabbr(spec[i], "newlbl:namelistok") ) {
            cmd_parse_descr_of_str_element(dos.newlblnamelist, `True')
            dos.split = `False'
        }
        else if ( u_unabbr(spec[i], "elbl:namelist") ) {
            cmd_parse_descr_of_str_element(dos.elblnamelist, `True')
            dos.split = `False'
        }
        else exit(error(197))
    }
    (void) tokenget(t)
}

void Elabel::cmd_parse_descr_of_str_mapspec(struct Elabel_DoS_ `S' dos,
                                            `TS'                     t)
{
    `SS' spec
    
    if ( !regexm(tokenpeek(t), "^\((.*)\)$") ) return
    if ( (spec=strtrim(regexs(1))) != "" )
        if ( !(dos.broad=(spec=="broad")) ) exit(error(197))
    (void) tokenget(t)
}

void Elabel::cmd_parse_str_to_parse(struct Elabel_DoS_ `S' dos)
{
    `SR' lblnamelist, newlblnamelist, varvaluelabel
    
    clearlocals()
    
    if ( !missing(dos.filename)       ) c_locals("using",          `False')
    if ( !missing(dos.iff_eexp)       ) c_locals(dos.iffword,      `False')
    if ( !missing(dos.mappings)       ) c_locals("mappings",       `False')
    if ( !missing(dos.anything)       ) c_locals("anything",       `False')
    if ( !missing(dos.vvlbl)          ) c_locals("varvaluelabel",  `False')
    if ( !missing(dos.newlblnamelist) ) c_locals("newlblnamelist", `False')
    if ( !missing(dos.elblnamelist)   ) c_locals("lblnamelist",    `False')
    
    syntax.newlblnameok( !missing(dos.newlblnamelist) )
    syntax.anythingok( !missing(dos.anything) )
    syntax.usingword("using")
    
    if (dos.iffword == "iff" ) syntax.iffword("iff")
    if ( !missing(dos.vvlbl) ) syntax.varvaluelabelok(dos.vvlbl)
    if ( !missing(dos.mlang) ) syntax.mlang(dos.mlang)
    if ( !missing(dos.nomem) ) syntax.nomem(dos.nomem)
    if ( !missing(dos.abbrv) ) syntax.abbrv(dos.abbrv)
    if ( !missing(dos.broad) ) syntax.broadmappings(dos.broad)
    
    syntax.set( tokenrest(t_zero) )

    newlblnamelist = u_invtoken( syntax.newlblnamelist() )
    if (!dos.split) lblnamelist = u_invtoken( syntax.labelnamelist() )
    else            lblnamelist = u_invtoken( syntax.lblnamelist() )

    varvaluelabel = u_invtoken("(":+syntax.varvaluelabel():+")")
    if (strlen(varvaluelabel)>c("macrolen")) 
        u_exerr(920, "macro length exceeded")
    
    u_st_syntax(syntax.options(), dos.options)
    
    if ( missing(dos.filename) ) 
        u_err_notallowed(syntax.filename(), "using")
    else if (dos.filename)
        u_err_required(syntax.filename(), "using")
        
    if ( missing(dos.iff_eexp) ) 
        u_err_notallowed(syntax.iff_eexp(), syntax.iffword()[1])
    else if (dos.iff_eexp)
        u_err_required(syntax.iff_eexp(), dos.iffword)
        
    if ( missing(dos.mappings) ) 
        u_err_notallowed(syntax.mappings(), "mappings")
    else if (dos.mappings)
        u_err_required(syntax.mappings(), "mappings")
        
    if ( missing(dos.anything) ) 
        u_err_notallowed(syntax.anything(), "anything")
    else if (dos.anything)
        u_err_required(syntax.anything(), "something")
    
    if ( missing(dos.newlblnamelist) ) 
        u_err_notallowed(newlblnamelist, "newlblnamelist")
    else if (dos.newlblnamelist)
        u_err_required(newlblnamelist, "newlblnamelist")
        
    if ( missing(dos.elblnamelist) ) 
        u_err_notallowed(lblnamelist, "elblnamelist")
    else if (dos.elblnamelist)
        u_err_required(lblnamelist, "elblnamelist")
    
    st_local("0", "")
    st_local("using",             syntax.filename(`False') )
    st_local(syntax.iffword()[1], syntax.iff_eexp(`False') )
    st_local("mappings",          syntax.mappings()        )
    st_local("anything",          syntax.anything()        )
    st_local("varvaluelabel",     varvaluelabel            )
    st_local("newlblnamelist",    newlblnamelist           )
    st_local("lblnamelist",       lblnamelist              )
    
    c_locals()
}

        // ------------------------------ cmd_parsefcn
void Elabel::cmd_parsefcn()
{
    zero = (" * " + zero)
    cmd_fcncall()
}

        // ------------------------------ cmd_protectr
void Elabel::cmd_protectr()
{
    u_st_syntax(zero, "[ , NOT ]")
    if (st_local("not") == "not") rr_reset()
    else rr_get()
}

        // ------------------------------ cmd_query
void Elabel::cmd_query()
{
    u_st_syntax(zero, "[ , VERSion(string asis) * ]")
    if (st_local("version") != "") {
        u_st_syntax(zero, ", VERSion(string asis)")
        cmd_query_assert_version(strtrim(st_local("version")))
        return
    }
    
    u_st_syntax(zero, "[ , DATETIME RECOMPILE ]")
    
    st_sclear()
    if (st_local("datetime") == "datetime") 
        st_global("s(datetime)", "`date_time'")
    st_global("s(stata_version)", "`stata_version'")
    st_global("s(elabel_version)", "`elabel_version'")
    if ( !c("noisily") ) return    
    elabel_about( (st_local("datetime") == "datetime") )
    if (st_local("recompile") == "recompile")
        printf("\noption recompile is no longer supported\n")
}

void Elabel::cmd_query_assert_version(`SS' caller_version)
{
    `RR' cv, ev
    `RS' i
    
    if ( !regexm(caller_version, "^[0-9]+(\.[0-9]+)?(\.[0-9]+)?$") ) 
        exit(error(198))
    ev = strtoreal(tokens("`elabel_version'", "."))
    cv = strtoreal(tokens(caller_version, "."))
    for (i=1; i<=cols(cv); i=i+2) {
        if      (cv[i] <  ev[i]) return
        else if (cv[i] == ev[i]) continue
        errprintf("this is version %s of elabel; ", "`elabel_version'")
        errprintf("it cannot run version %s programs\n", caller_version)
        exit(error(9))
    }
}

        // ------------------------------ cmd_rename
void Elabel::cmd_rename()
{
    `Boolean' nomem, force
    
    u_st_syntax(zero, 
        "[ anything(id=lblname equalok everything) ] [ , noMEMory FORCE * ]")
    nomem = (st_local("memory") == "nomemory")
    force = (st_local("force")  != "force")
    
    if (st_local("options") == "") {
        if ( cmd_rename_old_new(st_local("anything"), nomem, force) ) return
    }
    
    u_st_exe("elabel_cmd_rename "+zero)
}

`Boolean' Elabel::cmd_rename_old_new(`SS'      zero, 
                                     `Boolean' nomem, 
                                     `Boolean' force)
{
    `SR'      names
    `SS'      valid
    `Boolean' haswc
    
    if (cols(names=u_tokensq(zero)) != 2) return(`False')
    if ( !st_isname(names[2]) )           return(`False')
    
    pragma unset haswc
    valid = u_strip_wildcards(names[1], haswc)
    if ( haswc & ((valid=="")|!st_isname(valid)) ) valid = ("_"+valid)
    if ( !st_isname(valid) )              return(`False')
    
    elabel_rename(names[1], names[2], nomem, force)
    return(`True')
}

        // ------------------------------ cmd_unab
void Elabel::cmd_unab()
{
    `SS'           lmacname
    `SR'           lblnames
    `Boolean'      opt_elbl, opt_abbr
    
    tokenpchars(t_zero, ":")
    if ( !st_islmname((lmacname=tokenget(t_zero))) ) 
        u_exerr(198, "%s invalid name", lmacname)
    if (tokenget(t_zero)!=":") exit(error(198))
    
    u_st_syntax(tokenrest(t_zero), "anything(id=lblnamelist) "
        + "[ , noMEMory CURrent ELBLnamelist ABBREVokay ]")
    lblnames = st_local("anything")
    opt_elbl = (st_local("elblnamelist") == "elblnamelist")
    opt_abbr = (st_local("abbrevokay")   ==   "abbrevokay")    
    option.st_get()
    
    c_locals(lmacname, `False')
    
    if (!opt_elbl) {
        st_local(lmacname, u_invtoken(elabel_unab(tokens(lblnames), 
                 option.nomem(), !option.current(), opt_abbr) ) )
    }
    else {
        syntax.iffword("")
        syntax.mlang( !option.current() )
        syntax.nomem(  option.nomem() )
        syntax.abbrv(  opt_abbr )
        syntax.set(lblnames)
        if (syntax.mappings() != "") 
            u_assert_name( tokens(syntax.mappings())[1] )
        st_local(lmacname, u_invtoken( syntax.lblnamelist() ))
    }
    
    c_locals(lmacname)
}

        // ------------------------------ cmd_varvaluelabel
void Elabel::cmd_varvaluelabel()
{
    `TS' t
    `SR' tok
    `SR' varvaluelabel
    
    u_st_syntax(zero, "[ anything(id = varname) ] [ , noFIX ]")
    option.st_get()
    
    t = tokeninit(" ", ("(", ")"))
        tokenset(t, st_local("anything"))
    
    pragma unset varvaluelabel
    while (tokenpeek(t) != "") {
        if (tokenpeek(t) != "(") exit(error(198))
        tok = u_tokensq(u_tokenget_inpar(t, `False'))
        if (cols(tok) < 2) exit(error(198))  
        u_assert_name(tok)
        varvaluelabel = (varvaluelabel, u_invtoken(tok))
    }
    
    varvaluelabel(varvaluelabel, option.fixfmt())
}

        // ------------------------------ cmd__icmd()
void Elabel::cmd__icmd()
{
    `SS' cmdname, fn
    `RS' fh
    
    if (zero == "") {
        printf("\n{col 5}{txt}Syntax\n\n {col 8} {cmd}elabel _icmd")
        printf(" {it:cmdname} {txt}[ {cmd}elabel {txt} ] {it:...}\n")
        return
    }
    
    if ( !st_isname((cmdname=tokenget(t_zero))) ) exit( error(198) )
    
    if ( !(_stata("program list elabel_cmd_" + cmdname, `True')) ) {
        stata("local pp : properties elabel_cmd_" + cmdname)
        if ( anyof(tokens(st_local("pp")), "elabel__icmd") ) 
            u_st_exe("program drop elabel_cmd_" + cmdname)
    }
    
    if (tokenpeek(t_zero) == "elabel") (void) tokenget(t_zero)
    
    if ((fh=_fopen((fn=st_tempfilename()), "w")) < 0) exit( error(-fh) )
    fwrite(fh, sprintf("program elabel_cmd_%s", cmdname))
    fwrite(fh, sprintf(" , properties(elabel__icmd)\n"))
    fwrite(fh, sprintf("    elabel %s\n", strltrim(tokenrest(t_zero))))
    fwrite(fh, sprintf("end\n"))
    (void) _fclose(fh)
    
    u_st_exe(sprintf("run %s", fn))
    printf("\n")
}

        // ------------------------------ cmd__u_gmappings
void Elabel::cmd__u_gmappings()
{
    `SS' lmacname1, lmacname2, valspec, lblspec
    `RS' OK
    
    tokenpchars(t_zero, ":")
    
    if ( !st_islmname((lmacname1=tokenget(t_zero))) ) exit( error(197) )
    if ( !st_islmname((lmacname2=tokenget(t_zero))) ) exit( error(197) )
    if ( tokenget(t_zero) != ":")                     exit( error(197) )
    
    pragma unset valspec
    pragma unset lblspec
    
    OK = u_isgmappings(tokenrest(t_zero), valspec, lblspec)
    
    st_local(lmacname1, valspec)
    st_local(lmacname2, lblspec)
    c_locals( (lmacname1, lmacname2) )
    
    if ( !OK ) u_exerr(498, "invalid mappings")
}

        // ------------------------------ cmd__u_parse_rules
void Elabel::cmd__u_parse_rules()
{
    `RC'      from, to, null
    `SC'      text
    `SS'      rr
    `RS'      i
    
    pragma unset from
    pragma unset to
    pragma unset text
    pragma unset null
    pragma unset rr
    
    tokenpchars(t_zero, ",")
    if (tokenpeek(t_zero) == ",") {
        (void) tokenget(t_zero)
        tokenpchars(t_zero, ":")
        if (strtrim(tokenget(t_zero)) != "norules") exit( error(197) )
        if (tokenget(t_zero) != ":")                exit( error(197) )
        elabel_u_parse_rules(tokenrest(t_zero), from, to, text, null)
    }
    else {
        tokenpchars(t_zero, ":")
        if (tokenpeek(t_zero) == ":") (void) tokenget(t_zero)
        elabel_u_parse_rules(tokenrest(t_zero), from, to, text, null, rr)
        if (strlen(rr) >= c("macrolen")) u_exerr(920, "macro length exceeded")
    }
    
    st_sclear()
    st_global("s(rules)", rr)
    st_global("s(n_rules)", strofreal((i=rows(from)+1)-1))
    while (--i) {
        st_global(sprintf("s(null%f)", i), strofreal(null[i]))
        st_global(sprintf("s(text%f)", i),            text[i])
        st_global(sprintf("s(to%f)", i),     strofreal(to[i]))
        st_global(sprintf("s(from%f)", i), strofreal(from[i]))
    }
}

        // ------------------------------ cmd__u_usedby
void Elabel::cmd__u_usedby()
{
    `SS' lmacname
    `SR' lblnames
    
    if ( !st_islmname((lmacname=tokenget(t_zero))) ) exit( error(197) )    
    if ( tokenget(t_zero) != ":")                    exit( error(197) )
    
    elabel_u_assert_name( lblnames=tokens(tokenrest(t_zero)) )
    
    st_local(lmacname, invtokens(elabel_u_usedby(lblnames)))
    c_locals(lmacname)
}

    // ---------------------------------- internal commands/functions
void Elabel::breakoff()   (void) setbreakintr(`False')
void Elabel::breakreset() (void) setbreakintr(brkintr)

void Elabel::c_locals(| `SR' lmacname, `RS' noclear)
{
    `RS' i
    if ( !args() ) lmacname = st_dir("local", "macro", "*")'
    if (!noclear) {
        for(i=1; i<=cols(lmacname); ++i) st_local(lmacname[i], "")
    }
    for (i=1; i<=cols(lmacname); ++i) {
        (void) _stata(sprintf("c_local %s : copy local %s", 
                                 lmacname[i], lmacname[i]))
    }
}

void Elabel::call_fcn(`SS' subcmd, `SS' fcn, 
                      `SS' names,  `SS' fargs, `SS' rest)
{
    (void) _stata("preserve")
    outsource(sprintf("elabel_fcn_%s %s %s = %s %s", 
                      fcn, subcmd, names, fargs, rest))
    (void) _stata("restore , not")
}

void Elabel::clearlocals()
{
    `SR' lmacname
    `RS' i
    lmacname = st_dir("local", "macro", "*")'
    for (i=1; i<=cols(lmacname); ++i) st_local(lmacname[i], "")
}

void Elabel::outsource(`SS' passthru)
{
    `SR'                   clmacnames_copy
    struct Elabel_RR__ `S' rr_copy
    `RS'                   rc
    
    clmacnames_copy = clmacnames
    clmacnames      = J(1, 0, "")
    clearlocals()
    
    rr_copy = rr
    rr_reset()
    
    rc = _stata(passthru)
    
    breakoff()
    if ( rr.protectr ) rr_set()
    rr_reset(rr_copy)
    if ( !rc ) {
        c_locals()
        if ( cols(clmacnames) ) c_locals( clmacnames )
        clmacnames = clmacnames_copy
    }
    breakreset()
    if ( rc ) exit( rc )
}

void Elabel::rr_get()
{
    `SC' name
    `RS' i
    
    rr_reset()
    
    name = st_dir("r()", "numscalar", "*", `True')
    for (i=1; i<=rows(name); ++i) 
        rr.sca = (rr.sca, &(&name[i], &st_numscalar(name[i])`amp_sca_hcat'))
    
    name = st_dir("r()", "macro", "*", `True')
    for (i=1; i<=rows(name); ++i) 
        rr.mac = (rr.mac, &(&name[i], &st_global(name[i])`amp_mac_hcat'))
    
    name = st_dir("r()", "matrix", "*", `True')
    for (i=1; i<=rows(name); ++i) {
        rr.mat = (rr.mat, &(&name[i], &st_matrix(name[i]), 
                             &st_matrixrowstripe(name[i]), 
                             &st_matrixrowstripe(name[i])`amp_mat_hcat'))
    }
    
    rr.protectr = `True'
}

void Elabel::rr_set()
{
    `RS' i
    
    st_rclear()
    for (i=1; i<=cols(rr.sca); ++i) 
        st_numscalar(*(*rr.sca[i])[1], *(*rr.sca[i])[2]`ast_sca_hcat')
    for (i=1; i<=cols(rr.mac); ++i) 
        st_global(*(*rr.mac[i])[1], *(*rr.mac[i])[2]`ast_mac_hcat')
    for (i=1; i<=cols(rr.mat); ++i) {
        st_matrix(*(*rr.mat[i])[1], *(*rr.mat[i])[2]`ast_mat_hcat')
        st_matrixrowstripe(*(*rr.mat[i])[1], *(*rr.mat[i])[3])
        st_matrixcolstripe(*(*rr.mat[i])[1], *(*rr.mat[i])[4])
    }
}

void Elabel::rr_reset(| struct Elabel_RR__ rr_copy)
{
    if ( !args() ) {
        rr.sca = rr.mac = rr.mat = J(1, 0, NULL)
        rr.protectr = `False'    
    }
    else {
        rr = rr_copy
        rr_copy.sca = rr_copy.mac = rr_copy.mat = J(1, 0, NULL)
    }
}

`SS' Elabel::st_local0() return( st_c_local("0") )

void Elabel::varvaluelabel(`SR' varvaluelabel, | `RS' fixfmt)
{
    `RS' i, j, J
    `SR' vv
    `SS' stcmd
    
    if ( !(i=cols(varvaluelabel)) ) return
    
    breakoff()
    if ( !fixfmt ) {
        stcmd = sprintf("label values %%s , nofix")
        while (i) if (_stata(sprintf(stcmd, varvaluelabel[i--]), `True')) {
            J = j = cols((vv=tokens(varvaluelabel[i+1])))
            while (--j) st_varvaluelabel(vv[j], vv[J])
        }
    }
    else {
        while (i) if (_stata("label values " + varvaluelabel[i--], `True')) {
            j = cols((vv=tokens(varvaluelabel[i+1])))
            stcmd = sprintf("_label values %%s %s", vv[j])
            while (--j) (void) _stata(sprintf(stcmd, vv[j]), `True')
        }
    }
    breakreset()
}

end

// -------------------------------------- Mata functions

// -------------------------------------- elabel (main)
mata :

void elabel()
{
    class Elabel `S' elabel
    elabel.main( st_local("0") )
}

end

// -------------------------------------- Mata elabel functions
mata :

    // ---------------------------------- elabel_about()
void elabel_about(| `RS' datetime, `TM' v)
{
    printf("{txt}version %s", "`elabel_version'")
    if ( datetime ) printf(" %s", "`date_time'")
    printf("\n")
    printf("compiled under Stata version %s\n", "`stata_version'")
    if (args() == 2) v = ("`elabel_version'")
}

    // ---------------------------------- elabel_dir()
`voidSC' elabel_dir(| `TM' frst, `TM' scnd, `TM' thrd, `TM' caller_mlang)
{
    class Elabel_Dir scalar d

    if      ( !args() )   return(d.rnames())
    else if (args() == 2) caller_mlang = scnd
    
    if ( (args() == 2) | (args() == 4) ) {
        if (eltype(caller_mlang)  != "real"  ) _error(3253)
        if (orgtype(caller_mlang) != "scalar") _error(3204)
        d.mlang(caller_mlang)
    }
    
    frst = d.attached()
    
    if (args() > 2) {
        frst = d.nonexistent()
        scnd = d.orphans()
        thrd = d.used()
    }    
}

    // ---------------------------------- elabel_ldir()
`voidSC' elabel_ldir(| `TM' clang, `TM' langs, `Boolean' exclude)
{
    class Elabel_Dir scalar d
    if ( !args() ) return( d.langs(`False') )
    clang = d.clang()
    langs = d.langs(exclude)
}

    // ---------------------------------- elabel_numlist()
`RC' elabel_numlist(`SS' caller_nlist, 
                  | `Boolean' integeronly,
                    `Boolean' nosysmiss)
{
    `RC' nlist
    `RS' rc
    
    pragma unset nlist
    if ( (rc=_elabel_numlist(nlist, caller_nlist, integeronly, nosysmiss)) ) 
        exit(error(rc))
    return(nlist)
}

    // ---------------------------------- _elabel_numlist()
`RS' _elabel_numlist(`TC' nlist, 
                     `SS' caller_nlist,
                   | `Boolean' integeronly,
                     `Boolean' nosysmiss)
{
    `TS' t
    `SS' clean_nlist, tok
    `SR' nxt
    `RS' a, b, d
    `RC' R, enumlist
    
    clean_nlist = subinstr(caller_nlist, "[", "(")
    clean_nlist = subinstr(clean_nlist , "]", ")")
    clean_nlist = subinstr(clean_nlist , " to ", ":")
    
    t = tokeninit(" ", ("/", "(", ")", ":", ","))
    tokenset(t, clean_nlist)
    
    a = b = d = .
    nlist = R = enumlist = J(0, 1, .)
    
    while ((tok=tokenget(t)) != "") {
        if (_strtoreal(tok, a)) return(121)
        nxt = tokenpreview(t, (1..4))
        if (nxt[1] == "/") {
            // next 2 are / #    
            if (_strtoreal(nxt[2], b)|_range_mv(R, a, b)) return(121)
            tokendiscard(t, 2)
        }
        else if (nxt[1] == "(") {
            // next 4 are ( # ) #
            if ((nxt[3] != ")")       | 
                _strtoreal(nxt[2], d) | 
                _strtoreal(nxt[4], b) |
                _range_mv(R, a, b, d)
            ) return(121)
            tokendiscard(t, 4)
        }
        else if ((nxt[2]==":") | (nxt[(1, 3)]==(",", ":"))) {
            // next 3[4] are [,]# : #
            if (nxt[1] == ",") {
                tokendiscard(t, 1)
                nxt = nxt[(2..4)]
            }
            if (_strtoreal(nxt[1], d)|_strtoreal(nxt[3], b)) return(121)
            d = (d - a)
            if ((a==b)                |
                (((a+d)<a)&(b>a))     |
                (((a+d)>a)&(b<a))     |
                (((a+d)>a)&((a+d)>=b))|
                (((a+d)<a)&((a+d)<=b))|
                 _range_mv(R, a, b, d)
            ) return(121)
            tokendiscard(t, 3)
        }
        else R = a
        enumlist = (enumlist\ R)
        if ((tokenpreview(t, 1)==",") & (tokenpreview(t, 2)!="")) 
            tokendiscard(t, 1)
    }
    if (integeronly) {
        if (enumlist!=trunc(enumlist)) return(126) 
    }
    if (nosysmiss) {
        if (anyof(enumlist, .)) return(127)
    }
    nlist = enumlist
    return(0)
}

    // ---------------------------------- elabel_rename()
void elabel_rename(`SS' oldname, 
                   `SS' newname, 
                 | `Boolean' nomemold,
                   `Boolean' nomemnew)
{
    class Elabel_Unab       `S' u      
    class Elabel_ValueLabel `S' l
    `Boolean'                   brk
    `RS'                        i, k
    
    if (args() < 4) nomemnew = `True'
    if (args() < 3) nomemold = `False'
    
    u.nomem( nomemold )
    oldname = u.unab(oldname)
    if (cols(oldname)>1) u.u_exerr(198, "too many names specified")
    if (oldname == newname) return
    u.u_assert_newlblname(newname)
    if ( (nomemnew) & (anyof(u.attached(), newname)) ) 
        u.u_exerr(110, "label %s already attached to variables", newname)
    
    l.setup(oldname)
    
    brk = setbreakintr(`False')
    if ( !anyof(u.orphans(), oldname) ) {
        for (i=1; i<=rows(u.langs()); ++i) {
            (void) _stata("_label language "+u.langs()[i], `True')
            k = cols( l.usedby() )
            while ( k ) st_varvaluelabel(l.usedby(`False')[k--], newname)
        }
        if ( rows(u.langs()) ) 
            (void) _stata("_label language "+u.clang(), `True')
        k = cols( l.usedby() )
        while ( k ) st_varvaluelabel(l.usedby(`False')[k--], newname)
    }
    if ( st_vlexists(oldname) ) {
        l.name(newname)
        l.define()
        st_vldrop(oldname)
    }
    (void) setbreakintr(brk)
}

    // ---------------------------------- elabel_u*()
`voidBoolean' elabel_u_assert_lblname(`SR' lblnamelist, | `RS' rc)
{
    class Elabel_Utilities `S' u
    return( u.u_assert_lblname(lblnamelist, rc) )
}

`voidBoolean' elabel_u_assert_name(`SR' namelist, | `RS' rc)
{
    class Elabel_Utilities `S' u
    return( u.u_assert_name(namelist, rc) )
}

`voidBoolean' elabel_u_assert_newlblname(`SR' lblnamelist, | `RS' rc)
{
    class Elabel_Utilities `S' u
    return( u.u_assert_newlblname(lblnamelist, rc) )
}

`voidBoolean' elabel_u_assert_uniq(`SR' list, | `TS' scnd)
{
    class Elabel_Utilities `S' u    
    if (scnd == 0) return( u.u_assert_uniq(list, `False') )
    u.u_assert_uniq(list, scnd)
}

`TC' elabel_u_eexp(`SS' eexp, `RC' hash, `SC' at)
{
    class Elabel_eExp `S' e
    e.eexp(eexp)
    e.wildcards(hash, at)
    return( e.eexp() )
}

`SS' elabel_u_get_varlabel(`TS' var, | `SS' lang)
{
    class Elabel_Utilities `S' u
    if (lang == "") return( st_varlabel(var) )
    return( u.u_get_varlabel(var, lang) )
}

`SS' elabel_u_get_varvaluelabel(`TS' var, | `SS' lang)
{
    class Elabel_Utilities `S' u
    if (lang == "") return( st_varvaluelabel(var) )
    return( u.u_get_varvaluelabel(var, lang) )
}

`Boolean' elabel_u_iseexp(`SS' m, | `TM' r1)
{
    class Elabel_Utilities `S' u
    return( u.u_iseexp(m, r1) )
}

`Boolean' elabel_u_isgmappings(`SS' m, | `TM' r1, `TM' r2)
{
    class Elabel_Utilities `S' u
    return( u.u_isgmappings(m, r1, r2) )
}

void elabel_u_parse_rules(`SS' rules, 
                          `TM' from,
                          `TM' to,
                          `TM' text,
                        | `TM' null,
                          `TM' rrules)
{
    class Elabel_Rules__ `S' r
    r.set(rules)
    from   = r.from()
    to     = r.to()
    text   = r.text()
    null   = (args()>4) ? r.null()  : J(0, 1,  .)
    rrules = (args()>5) ? r.rules() : J(0, 1, "")
}

void elabel_u_st_syntax(`SS' zero, | `SS' dos, `TM' rc)
{
    class Elabel_Utilities `S' u
    if (args() < 3) u.u_st_syntax(zero, dos)
    else        u.u_st_syntax(zero, dos, rc)
}

`SS' elabel_u_tokenget_inpar(`TS' t, | `RS' keeppar, `TM' rc)
{
    class Elabel_Utilities `S' u
    if (args() < 3) return( u.u_tokenget_inpar(t, keeppar) )
    return( u.u_tokenget_inpar(t, keeppar, rc) )
}

`SR' elabel_u_tokensq(`SS' s)
{
    class Elabel_Utilities `S' u
    return( u.u_tokensq(s) )
}

`SR' elabel_u_usedby(`SR' lblnamelist, | `RS' mlang)
{
    `BooleanR'           s
    class Elabel_Dir `S' d
    `RS'                 k, i
    `SS'                 lblname
    
    s = J(1, (k=st_nvar()+1)-1, 0)
    
    while ( k-- ) {
        if ( !(s[k]=st_isnumvar(k)) )                         continue
        if ( (s[k]=anyof(lblnamelist, st_varvaluelabel(k))) ) continue 
        if ( !mlang )                                         continue
        for (i=1; i<=rows(d.langs()); ++i) {
            lblname = elabel_u_get_varvaluelabel(k, d.langs()[i])
            if ( (s[k]=anyof(lblnamelist, lblname)) )       break
        }
    }
    
    if ( !any(s) ) return( J(1, 0, "") )
    
    return( st_varname(select((1..st_nvar()), s)) )
}

        // ------------------------------ retained; not documented
`voidBoolean' elabel_u_assert_usedlblname(`SR' lblnamelist, | `RS' rc)
{
    class Elabel_Dir `S' d
    `RS'                 i
    
    if (!cols(lblnamelist)) {
        if (!rc) return(`False')
        d.u_exerr(7, "'' found where name expected")
    }
    for (i=1; i<=cols(lblnamelist); ++i) {
        if (rc) d.u_assert_name(lblnamelist[i])
        else if ( !d.u_assert_name(lblnamelist[i], `True') ) return(`False')
        if ( anyof(d.attached(), lblnamelist[i]) ) continue
        if (!rc) return(`False')
        errprintf("value label %s not used by any variable\n", lblnamelist[i])
        exit(498)
    }
    if (!rc) return(`True')
}

`SS' elabel_u_bslsq(`SS' s) return(subinstr(s, char(96), char((92, 96)), .))

`TC' elabel_u_expr(`SS' eexp, `RC' hash, `SC' at)
{
    return( elabel_u_eexp(eexp, hash, at) )
}

`SS' elabel_u_elabel_version() return("`elabel_version'")
`SS' elabel_u_stata_version()  return("`stata_version'")

`SR' elabel_u_tokens(`SS' s) return( elabel_u_tokensq(s) )

    // ---------------------------------- elabel_unab()
`SR' elabel_unab(`SR' lblnamelist,
               | `Boolean' nomem,
                 `Boolean' mlang,
                 `Boolean' abbrv)
{
    class Elabel_Unab `S' u
    `SR'                  labelnamelist
    `RS'                  i
    
                    u.nonamesok(`False')
    if (args() > 3) u.abbrv(abbrv)
    if (args() > 2) u.mlang(mlang)
    if (args() > 1) u.nomem(nomem)
    
    labelnamelist = u.unab(lblnamelist[1])
    for (i=2; i<=cols(lblnamelist); ++i) {
        labelnamelist = (labelnamelist, u.unab(lblnamelist[i]))
    }
    return(labelnamelist)
}

    // ---------------------------------- elabel_vl*()
`TS' elabel_vlinit(`SS' name, | `RC' vvec, `SC' tvec, `SS' sep)
{
    class Elabel_ValueLabel `S' l
    if      (args() < 2) l.setup(name)
    else if (args() < 3)  _error(3100)
    else if (args() < 4) l.setup(name, vvec, tvec)
    else                 l.setup(name, vvec, tvec, sep)
    return(l)
}

void elabel_vlcopy(class Elabel_ValueLabel `S' l, `TS' l2)
{
    l2 = elabel_vlinit(l.name(), l.vvec(), l.tvec())
}

void elabel_vlset(class Elabel_ValueLabel `S' l, `RC' vvec, `SC' tvec)
{
    l.reset(vvec, tvec)
}

void elabel_vlmark(class Elabel_ValueLabel `S' l, `RC' touse) l.mark(touse)

void elabel_vlmarkiff(class Elabel_ValueLabel `S' l, `SS' eexp) {
    l.markiff(eexp)
}

void elabel_vlmarkif(class Elabel_ValueLabel `S' l, `SS' eexp) {
    l.markiff(eexp)
}

void elabel_vlmarkall(class Elabel_ValueLabel `S' l) l.markall()

void elabel_vldefine(class Elabel_ValueLabel `S' l, 
                               | `Boolean' replace, 
                                  `Boolean' fixfmt)
{
    if (args() < 2) replace = 0
    l.define(replace, fixfmt)
}

void elabel_vlmodify(class Elabel_ValueLabel `S' l, 
                                   | `Boolean' add, 
                                  `Boolean' fixfmt)
{
    if (args() < 2) add = 0
    l.modify(add, fixfmt)
}

void elabel_vlappend(class Elabel_ValueLabel `S' l, 
                                | `Boolean' fixfmt,
                                  `SS'   separator)
{
    if (args() < 3) l.append(fixfmt)
    else l.append(fixfmt, separator)
}

`voidSS' elabel_vlname(class Elabel_ValueLabel `S' l, | `SS' newname)
{
    if (args() < 2) return( l.name() )
    l.name(newname)
}

`RC' elabel_vlvalues(class Elabel_ValueLabel `S' l)  return( l.vvec()    )
`SC' elabel_vllabels(class Elabel_ValueLabel `S' l)  return( l.tvec()    )
`RC' elabel_vlnull(class Elabel_ValueLabel `S' l)    return( l.null()    )
`RC' elabel_vltouse(class Elabel_ValueLabel `S' l)   return( l.touse()   )
`RS' elabel_vlk(class Elabel_ValueLabel `S' l)       return( l.k()       )
`RS' elabel_vlK(class Elabel_ValueLabel `S' l)       return( l.K()       )
`RS' elabel_vlnemiss(class Elabel_ValueLabel `S' l)  return( l.nemiss()  )
`RS' elabel_vlsysmiss(class Elabel_ValueLabel `S' l) return( l.sysmiss() )
`SR' elabel_vlusedby(class Elabel_ValueLabel `S' l)  return( l.usedby()  )

void elabel_vllist(class Elabel_ValueLabel `S' l, 
                 | `TM' values, 
                   `TM' text, 
                   `RS' noisily)
{
    if      (args() < 2)     l._list()
    else if (args() < 3)  _error(3100)
    else l.list(values, text, noisily)
}

void elabel_vllistmappings(class Elabel_ValueLabel `S' l) l._list( `False' )

void elabel_vlassert_add(class Elabel_ValueLabel `S' l) l.assert_add()

end

// -------------------------------------- Mata programming functions
mata :

// -------------------------------------- a*b()

    // ---------------------------------- aandb()
`TR' aandb(`TR' a, `TR' b)
{
    `TR' r
    r = select(a, _aandb(a, b))
    return( cols(r) ? r : J(1, 0, a) )
}

    // ---------------------------------- _aandb()
`BooleanR' _aandb(`TR' a, `TR' b)
{
    `BooleanR' v
    `RS'       na, nb, i, j, jj
    `RC'       o
    `TC'       idx, sb
    
    if (!(isreal(a)|isstring(a))) _error(3255)
    if (!(isreal(b)|isstring(b))) _error(3255)
    
    if (a==b) return(J(1, cols(a), `True'))
    
    v = J(1, (na=cols(a)), `False')
    
    if (!(na & (nb=cols(b)) & (eltype(a)==eltype(b)))) return(v)
    
    idx = (1::na)
    if (isstring(a)) 
        idx = strofreal(idx, sprintf("%%0%g.0f", floor(log10(na))+1))
    o  = order((a', idx), (1, 2))
    sb = sort(b', 1)
    for (i=jj=1; i<=na; ++i) {
        j=jj
        while (a[o[i]]>sb[j++]) if (j>nb) break
        if ((v[o[i]]=(a[o[i]]==sb[j-1]))) if ((jj=j)>nb) break
    }
    
    return(v)
}

    // ---------------------------------- adups()
`TR' adups(`TR' a)
{
    `TR' r
    r = select(a, !_auniq(a))
    return( cols(r) ? r : J(1, 0, a) )
}

    // ---------------------------------- aequivb()
`Boolean' aequivb(`TR' a, `TR' b)
{
    if (!(isreal(a)|isstring(a))) _error(3255)
    if (!(isreal(b)|isstring(b))) _error(3255)
    if (cols(a)!=cols(b))         return(`False')
    return( (all(_aandb(b, a))|(!cols(a))) )
}

    // ---------------------------------- ainb()
`Boolean' ainb(`TR' a, `TR' b) return( (all(_aandb(a, b))|(!cols(a))) )

    // ---------------------------------- anotb()
`TR' anotb(`TR' a, `TR' b)
{
    `TR' r
    if (cols((r=a))) r = a[cols(a)..1]
    r = select(r, !_aandb(r, b))
    return( cols(r) ? r[cols(r)..1] : J(1, 0, a) )
}

    // ---------------------------------- aorb()
`TR' aorb(`TR' a, `TR' b) return( (a, anotb(b, a)) )

    // ---------------------------------- aposb()
`RR' aposb(`TR' a, `TR' b, | `RS' d)
{
    `BooleanR' v
    return( any((v=_aposb(a, b, d))) ? select((1..cols(b)), v) : 0 )
}

    // ---------------------------------- _aposb()
`BooleanR' _aposb(`TR' a, `TR' b, | `RS' d)
{
    `RS'       n, na, i
    `BooleanR' v
    
    if (!(isreal(a)|isstring(a))) _error(3255)
    if (!(isreal(b)|isstring(b))) _error(3255)
    
    if (a==b) 
        return((n=cols(b)) ? (`True', J(1,(n-1),`False')) : J(1,n,`True'))
    
    v = J(1, (n=cols(b)), `False')
    
    if (eltype(a)!=eltype(b)) return(v)
    if ((na=cols(a))<2)       return( na ? (a:==b) : v )
    if ((na--)>n)             return(v)
    
    n = (n-na)
    if (!d) for (i=1; i<=n; ++i) (v[i]=(a==b[i..(i+na)]))
    else for (i=1; i<=n; ++i) if (v[i]=(a==b[i..(i+na)])) i=(i+na)
    
    return(v)
}

    // ---------------------------------- auniq()
`TV' auniq(`TV' a) return( select(a, _auniq(a)) )

    // ---------------------------------- _auniq()
`BooleanV' _auniq(`TV' a)
{
    `BooleanV' v
    `RS'       n, i
    `TS'       A
    
    if ( !(isreal(a)|isstring(a)) ) _error(3255)
    
    v = J(rows(a), cols(a), `True')
    
    if ((n=length(a)) < 2) return( v )
    
    A = asarray_create(eltype(a))
    
    for (i=1; i<=n; ++i) {
        if ( !asarray_contains(A, a[i]) ) asarray(A, a[i], `True')
        else v[i] = `False'
    }
    
    return( v )
}

// -------------------------------------- distinctrowsof()
`TM' distinctrowsof(`TM' X) return( select(X, _distinctrowsof(X)) )

    // ---------------------------------- _distinctrowsof()
`BooleanC' _distinctrowsof(`TM' X)
{
    `RS' n, i
    `TC' idx
    `RC' v, o
    
    if ((n=rows(X))<2) return(J(n, 1, n))
    
    idx = (1::n)
    if (isstring(X)) 
        idx = strofreal(idx, sprintf("%%0%g.0f", floor(log10(n))+1))
    
    o = order((X, idx), (1..cols(X)+1))
    v = J(n, 1, `True')
    for (i=2; i<=n; ++i) v[o[i]] = (X[o[i-1],]!=X[o[i],])
    return(v)
}

    // ---------------------------------- _duplicaterowsof()
`TM' duplicaterowsof(`TM' X) return( select(X, !_distinctrowsof(X)) )

// -------------------------------------- range_mv()
`RC' range_mv(`RS' a, `RS' b, | `RS' d) 
{
    `RC' R
    `RS' rc
    
    if (args() < 3) d = 1
    
    pragma unset R
    if (rc = _range_mv(R, a, b, d)) _error(rc)
    
    return(R)
}

    // ---------------------------------- _range_mv()
`RS' _range_mv(`TM' R, `RS' a, `RS' b, | `RS' d)
{
    `RC' mvc
    
    R = J(0, 1, .)
    
    if      (args() < 4) d = 1
    else if (missing(d)) return(3351)
    else if (!d)         return(3300)
    
    if (a == b) {
        R = a
        return(0)
    }
    
    if (!missing((a, b))) {
        R = (d == 1) ? (a::b) : (0::trunc((b - a)/abs(d))) :* abs(d) :+ a
        return(0)
    }
    
    if (all((a, b) :>= .)) {
        mvc = (.\ strtoreal("." :+ tokens(c("alpha")))')
        a     = select((1::rows(mvc)), (mvc :== a))
        b     = select((1::rows(mvc)), (mvc :== b))
        R     = (d == 1) ? mvc[a::b] : mvc[range_mv(a, b, d)]
        return(0)
    }
    
    return(3351)
}

// -------------------------------------- tokenpreview()
`SR' tokenpreview(`TM' t, | `RR' v)
{
    `RS' colsv, offset, ntokall, i
    `SR' tokall, toks
    
    if (eltype(t) != "struct") _error(3261)
        
    if (args() < 2) v = .
    colsv = cols(v)
    
    if ((colsv != 1) & missing(v)) _error(3351)
    
    offset = tokenoffset(t)
    tokall = tokengetall(t)
    tokenoffset(t, offset)
    
    if (missing(v)) return(tokall)
    
    ntokall = cols(tokall)
    if (!ntokall) return(J(1, colsv, ""))
    
    v = (v :+ (v:<0):*ntokall :+ (v:<0))
    toks = J(1, colsv, "")
    for (i=1; i<=colsv; ++i) {
        if ((v[i] > 0) & (v[i] <= ntokall)) toks[i] = tokall[v[i]]
    }
    return(toks)
}

// -------------------------------------- tokendiscard()
void tokendiscard(`TS' t, `RS' i)
{
    if (!(i=abs(i))) return
    while (--i & (tokenget(t)!="")) { }
}

end
exit

/* ---------------------------------------
3.8.0 18jun2020 Elabel_Options__() class has new members
                Elabel_Options2__() class removed
                Elabel_ValueLabel() has new -sep- argument
                -elabel define- has new option merge[(char)]
                -elabel language , saving()- has new option -option()-
                update elabel_cmd_load
                update elabel_cmd_recode
                update elabel_fcn_{combine|copy|levels}
                update help files
3.7.0 27may2020 bug fix -elabel define- with rules exeeding macro length
                bug fix -elabel rename- always set _dta[_lang_*]
                update elabel_cmd_load new options
                update elabel_cmd_recode optionally returns r(varlist)
                update elabel_cmd_rename; see bug report above
                update -elabel numlist-; new option -local()-
                new -elabel duplicates {report|remove|retain}-
                new -elabel _u_gmappings-
                new -elabel _u_parse_rules-
                new -elabel _u_usedby-
                new -elabel _icmd-; not documented
                new u_get_var{value}label(), elabel_u_get_var{value}label()
                new elabel_u_usedby()
                revised code for _auniq() and auniq()
                revised code for class Elabel_Dir and cmd_list
                updated help files
3.6.0 02apr2020 bug fix r(hasemiss) in -elabel list- with one missing
                new/extended syntax for -parse- and -fcncall- (Stata 16)
3.5.0 01feb2020 option -join- re-renamed again to -append- (final)
                bug fix option -append- not working in -define-
                update elabel_fcn_combine
                update elabel_fcn_copy
                update elabel_fcn_levels
                new option -version()- for -elabel query- (not documented)
                change minimal abbreviation in -elabel unab- abbrev:okay
                update help files
3.4.0 11dec2019 change initial parser; parse on , and : 
                -elabel parse- optionally allows abbreviated value labels
                -elabel confirm- has new arguments # [uniq]
                update elabel_fcn_combine
                update elabel_fcn_copy
                update elabel_fcn_levels
                elabel define fcns accept properties elabel_jn
                update help files
                minor code polish
3.3.1 14nov2019 bug fix ignore smcl when listing value labels
                new Elabel_ValueLabel::_list()
                new elabel_vllistmappings()
                option -append- renamed -join-; still not documented
                update elabel_cmd_compare
                update elabel_fcn_combine
                update elabel_fcn_copy
                update elabel_fcn_levels
3.3.0 23oct2019 bug fix pseudo-fcns now only allow {if[f]|in|,} after fcn()
                new option -append- for -define- and -copy-; not documented
                new option -abbrevok- for -elabel unab-; not documented
                update elabel_cmd_compare
                update elabel_cmd_load
                update elabel_cmd_recode
                update elabel_fcn_combine
                update elabel_fcn_copy
                update elabel_fcn_levels
                update various help files
                code polish
                never released
3.2.0 08sep2019 bug fix -elabel fcncall- error message missing equals sign
                include and re-compile Mata code in elabel.ado
                reinstate hidden and historical r()
                new -elabel_about()-
                update some help files
                minor code polish
3.1.0 02aug2019 bug fix Elabel_Syntax; allowed undefined labels in (varname)
                bug fix -elabel parse- anything would never be required
                bug fix -elabel parse- ignored broad mappings
                bug fix -elabel values- with mappings
                bug fixes related to (hasnolabel hasnolabel ... , strict)
                bug fixes related to syntax.labelnamelist()
                bug fix u_isgmappings("(a b c) ((d e) f)")
                changed -elabel language , saving()-; keeps missing labels
                extended syntax for -elabel values-
                Elabel_Syntax now supports varname:lblname
                -elabel parse- supports varname:lblname
                -define-, -copy-, and -recode- support varname:lblname
                -keep- supports varname:lblname; not documented
                new -elabel varvaluelabel-; convenience
                update elabel_cmd_rename
                update elabel_fcn_*: combine(), copy(), levels()
                new u_invtoken() and u_selectnm(); introduced to fix bugs
                update various help files
3.0.0 15jul2019 complete rewrite internal code
                discontinue class Elabel_Expr; well, almost
                discontinue most elabel_u*() functions; again: almost 
                discontinue recompiling source code
                ignore hidden and historical properties in r()
                bug fix overlapping recoding rules
                complete rewrite elabel_cmd_rename
                update elabel_cmd_compare
                update elabel_cmd_load
                update elabel_cmd_recode
                update elabel_fcn_levels
                new internal command data; not documented
                new internal command cmd; not documented
                new elabel_cmd_uselabel; not documented
                -elabel preserver- now works for elabel_fcn_*.ado
                elabel_fcn_*.ado can now set locals in the caller
                revised help files
2.0.1 17jun2019 bug fix in elabel_fcn_regexse
                updated help files
                submitted to SJ
2.0.0 03jun2019 change syntax -iff- in place of -if-; version controlled
                bug fix -elabel rename- with two valid names and options
                rewrite all elabel_*.ado to use -iff- in place of -if-
                revise all help files
1.2.1 24may2019 bug fix error message for type mismtach in elabel_expr
                update elabel_cmd_compare
                update elabel_cmd_rename
                update elabel_fcn_copy
                update elabel_fcn_combine
                update elabel_fcn_levels
                new elabel_fcn_regexse; not documented
                new -elabel fcncall- replaces -elabel parsefcn-
                updated help files
1.2.0 02apr2019 bug fix Elabel_Unab(); *{#} would not qualify as name
                bug fix elabel_rename(); names with wildcards
                bug fix -elabel list , nomemory- omitted undefined labels
                bug fix Elabel_Rules__(); unmatched parentheses in labels
                bug fix Elabel_Syntax(); broadmappings with wildcards
                bug fix Elabel_Syntax(); keeporder with abbreviations
                bug fix Elabel_Syntax(); parse anything/mappings verbatim
                Elabel_Syntax() no longer allows repeated newlblnames
                extended -elabel define- now allows lblnamelist = fcn()
                extended -elabel variable- allows (varlist) = fcn()
                extended -elabel save- has new option option(...)
                new options for -elabel rename-
                new -elabel parsefcn-
                new elabel_cmd_load.ado
                new elabel_fcn_combine.ado
                new elabel_fcn_levels.ado
                new elabel_fcn_copy.ado
                new -elabel language languagename , saving(filename)-
1.1.0 09feb2019 bug fix -elabel define- with numlist and only one label
                bug fix -elabel parse- no longer sets local 0 in caller
                bug fix Elabel_Syntax(); strict() default now `False'
                bug fix Elabel_Syntax(); -uniq- applies to one (varlist)
                bug fix -elabel numlist- when nothing followed
                bug fix elabel_u_parse_rules() fifth argument
                new r(exists) for -elabel list , {nomem|current}-
                additional r(*language*) for -elabel list , varlist-
                extended -elabel save- now allows -if expr-
                new options for -elabel remove-
                recoding rules may contain numlists with parentheses
                extended -elabel parse- {e|new}lblnamelist(...)
                new subcommand -elabel compare- (elabel_cmd_compare.ado)
                new Mata functions aandb(), distinctrowsof()
                new Mata functions *u_assert_uniq(), *u_pmappings()
                revised help files
1.0.0 02nov2018 fix various bugs in various routines
                changed behavior of -(varname)- in elblnamelist 
                changed behavior of -elabel values-
                changed returned results of -elabel list , varlist-
                changed behavior and new options for -elabel rename-
                changed behavior and new arguments for elabel_rename()
                new subcommand -elabel recode- (elabel_cmd_recode.ado)
                new subcommand -elabel remove- (elabel_cmd_remove.ado)
                new subcommand -elabel unab-
                new subcommand -elabel protectr-
                new elabel_cmd_rename.ado
                new optional argument for all elabel_u_assert*()
                rewrite Elabel_Expr()
                rewrite elabel_cmd_define()
                document extended syntax of -elabel rename-
                revised help files
                first release on SSC
0.9.1 05oct2018 change command name to -elabel-
                fix bugs and enhance elabel_rename()
                code polish
                resubmitted to SJ
0.9.0 01oct2018 submitted to SJ as -elab-
