*! version 2.1.0 11nov2019 daniel klein
program which_version // , sclass
    version 11.2
    
    syntax anything(everything) [ , FIRSTVERSion ASSERTVERSion(string asis) ]
    gettoken fname invalid : anything , quotes
    if (`"`invalid'"' != "") {
        display as err `"invalid `invalid'"'
        exit 198
    }
    
    mata : which_version()
end

version 11.2

local re "^(v|v\.)?[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?$"
local ro "(>=|<=|>|<|==|!=|~=)"

mata :

mata set matastrict on

void which_version()
{
    string scalar opt_reqvv, fname, vv
    real scalar   opt_first, rc
    
    if ((opt_reqvv=st_local("assertversion")) != "") parse_reqvv(opt_reqvv)
    
    if (pathsuffix((fname=st_local("fname"))) == "") fname = (fname+".ado")
    opt_first = (st_local("firstversion") == "firstversion")
    
    pragma unset vv
    if ((fname=findfile(fname)) != "") readfile(fname, opt_first, vv)
    else if ( (rc=_stata("which " + st_local("fname"))) )    exit(rc)
    
    if (vv == "") 
        printf("{%s}unknown version\n", (opt_reqvv=="") ? "txt" : "err")
    
    st_global("s(version)", vv)
    st_global("s(fn)",   fname)
    
    if (opt_reqvv != "") assert_version(opt_reqvv, vv)
}

void parse_reqvv(string       scalar opt_reqvv, 
               | transmorphic matrix     relop, 
                 transmorphic matrix     reqvv)
{
    if ( regexm((reqvv=strtrim(opt_reqvv)), "^`ro'(.*)$") ) {
        relop = regexs(1)
        reqvv = strtrim(regexs(2))
    }
    
    if ( regexm(reqvv, "`re'") ) 
        if ( regexm(reqvv, "^[0-9]") ) return
    
    errprintf("option assertversion() invald\n")
    exit(198)
}

void readfile(string scalar fname, real scalar opt_first, string scalar vv)
{
    real   scalar fh, brk
    string scalar line
    
    if ( (fh=_fopen(fname, "r")) ) exit( error(-fh) )
    
    brk = setbreakintr(0)
    
    printf("{txt}%s\n", fname)
    
    while ((line=_fget(fh)) != J(0, 0, "")) {
        if (substr(line, 1, 2) != "*!") continue
        else       printf("{res}%s{txt}\n", line)
        if ((vv!="") & opt_first)       continue
        else                   readline(line, vv)
    }
    
    (void) _fclose(fh)
    (void) setbreakintr(brk)
}

void readline(string scalar line, string scalar vv)
{
    string rowvector _line
    
    _line = strlower(substr(subinstr(line, char(9), char(32)), 3, .))
    if ( !cols((_line=tokens(_line, " ,:;"))) )                return
    if ( !cols((_line=select(_line, regexm(_line, "`re'")))) ) return
    readversion(subinstr(subinstr(_line[1], "v.", ""), "v", ""), vv)
}

void readversion(string scalar _vv, string scalar vv)
{
    string scalar _vv4, vv4
    
    if (vv != "") {
        align_v4((_vv4=_vv), (vv4=vv))
        if (vv4 >= _vv4) return
    }
    
    vv = _vv
}

void align_v4(string rowvector _vv, string rowvector vv)
{
    string rowvector _vv4, vv4
    real   scalar    i
    
    _vv4 = convert_v4(_vv)
     vv4 = convert_v4( vv)
    _vv4 = ((strlen( vv4)-strlen(_vv4)):*"0" + _vv4)
     vv4 = ((strlen(_vv4)-strlen( vv4)):*"0" +  vv4)
    for (i=2; i<=cols(_vv4); ++i) {
        _vv4[1] = (_vv4[1] + _vv4[i])
         vv4[1] = ( vv4[1] +  vv4[i])
    }
    _vv = _vv4[1]
     vv =  vv4[1]
}

string rowvector convert_v4(string scalar v)
{
    string rowvector v4
    
    v4 = tokens(v, ".")
    return( (v4, J(1, (7-cols(v4))/2, (".", "0"))) )
}

void assert_version(string scalar opt_reqvv, string scalar vv)
{
    string scalar relop, reqvv
    
    if (vv == "") exit(6)
    
    pragma unset reqvv
    parse_reqvv(opt_reqvv, (relop="=="), reqvv)
    align_v4(reqvv, vv)
    
    if ( _stata(sprintf(`"assert "%s" %s "%s""', vv, relop, reqvv)) ) 
        exit(9)
}

end
exit

/* ---------------------------------------
2.1.0 11nov2019 new option assertversion()
2.0.0 23oct2019 improved regular expression matching
                rewrite Mata subroutines
1.0.0 17oct2019 initial release on SSC
