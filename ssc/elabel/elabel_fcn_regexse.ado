*!version 1.0.1 17jun2019 daniel klein

/*
    Syntax
            elabel {define|variable} ... = regexse(rexp, exp) [ , modify ]
            
    where rexp: regular expression to match; possibly with subexpressions
          exp:  exp; possibly including # referring to subexpressions
    
    Example
            elabel define foo = regexse("o(o)$", "XX" + strupper(1))
    
    technically the above is translated to "XX" + strupper(regexs(1))
*/

program elabel_fcn_regexse
    version 11.2
    elabel fcncall * subcmd names 0 : `0'
    gettoken regex 0 : 0 , parse(" ,") qed(q)
    gettoken comma   : 0 , parse(",")  quotes
    if (`"`comma'"' == ",") gettoken comma 0 : 0 , parse(",")
    if (!`q') error 198
    mata : regexse_build("0")
    regexse_`subcmd' (`names') (`regex') `0'
end

program regexse_variable
    gettoken varlist 0 : 0 , match(p)
    gettoken regex   0 : 0 , match(p)
    if (c(stata_version)>=14) local ustr ustr
    foreach var of local varlist {
        local lbl : variable label `var'
        local match = `ustr'regexm(`"`macval(lbl)'"', `"`macval(regex)'"')
        if      (!`match')  continue
        else if (`match'<0) error 498
        local lbl = `0' // max. length 80 characters
        mata : st_varlabel("`var'", st_local("lbl"))
    }
end

program regexse_define
    gettoken lblnamelist 0 : 0 , match(p)
    gettoken regex       0 : 0 , match(p)
    syntax anything(id="exp" everything) , MODIFY [ noFIX ]
    if (c(stata_version)>=14) local ustr ustr
    elabel protectr
    foreach lbl of local lblnamelist {
        quietly elabel list `lbl' if (`ustr'regexm(@, `"`macval(regex)'"'))
        if (!r(k)) continue
        tokenize `r(values)'
        mata : st_local("labels", st_global("r(labels)"))
        local k 0
        foreach l of local labels {
            local match = `ustr'regexm(`"`macval(l)'"', `"`macval(regex)'"')
            if      (!`match')  continue
            else if (`match'<0) error 498
            capture noisily mata : st_local("l", `anything')
            if (_rc) exit(498)
            mata : st_vlmodify("`lbl'", ``++k'', st_local("l"))
            if ("`fix'"!="nofix") _label define `lbl' , modify
        }
    }
end

version 11.2

if (c(stata_version)>=14) local ustr ustr

mata :

mata set matastrict on

void regexse_build(string scalar lmacname)
{
    transmorphic scalar t
    string       scalar s, tok
    real         scalar x, rc
    
    t = tokeninitstata()
        tokenwchars(t, "")
        tokenpchars(t, (" ", tokenpchars(t)))
        tokenset(t, st_local(lmacname))
    
    pragma unset s
    pragma unset x
    
    while ((tok=tokenget(t)) != "") {
        if (!_strtoreal(tok, x)) {
            if      ((x<0)|(x>9)) rc = 125
            else if (x!=trunc(x)) rc = 126
            else if (missing(x))  rc = 127
            else                  rc =   0
            if (rc) exit(error(rc))
            tok = sprintf("`ustr'regexs(%s)", tok)
        }
        s = (s + tok)
    }
    st_local(lmacname, s)
}

end
exit

/* ---------------------------------------
1.0.1 17jun2019 bug changed values in value labels
1.0.0 24may2019 first version; not documented
