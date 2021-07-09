*! version 1.2.5  Ben Jann  30may2015

version 9.2

* The following locals define some constants used by the mata
* functions below.

local NOBREAK      "0"
local COLWIDTH     "11"

local LBL_VALID    `""Valid""'
local LBL_MISSING  `""Missing""'
local LBL_TOTAL    `""Total""'
local LBL_FREQ     `""Freq.""'
local LBL_PERC     `""Percent""'
local LBL_VALPERC  `""Valid""'
local LBL_CUMPERC  `""Cum.""'

local SMCL_TISEP   `"" {hline 2} ""'
local SMCL_DOTS    `"":""'

local TAB_TISEP    `"char(9)"'
local TAB_DOTS     `"":""'
local TAB_COLSEP   `"char(9)"'

local TEX_TISEP    `"" --- ""'
local TEX_DOTS     `""\vdots""'
local TEX_COLSEP   `"" & ""'
local TEX_EOL      `"" \\""'
local TEX_RULE     `""\hline""'
local TEX_TBEGIN   `""\begin{tabular}{"+miss*"l"+nlblcol*"l"+(3+miss)*"r"+"}\hline""'
local TEX_TEND     `""\hline\end{tabular}""'


prog fre, byable(onecall)
    syntax [varlist] [if] [in] [using/] [fw aw iw] [, Replace Append Order * ]
    local by
    if "`_byvars'"!="" local by "by `_byvars'`_byrc0': "
    if (`"`by'"'!="" | `:list sizeof varlist'>1) & `"`using'"'!="" {
        mata: fre_prepare_append()
    }
    if `"`using'"'!="" {
        local uusing `"using `"`using'"'"'
    }
    if "`order'"!="" { // suggested by Fred Wolfe
        local varlist: list sort varlist
    }
    foreach var of local varlist {
        `by'_fre `var' `if' `in' `uusing' [`weight'`exp'] , `replace' `append' `options'
        local append append
    }
    if `"`using'"'!="" {
        di `"{txt}(output written to {res}{browse `using'}{txt})"'
    }
end

prog _fre, byable(recall)
    version 9.2
//syntax
    syntax varname [if] [in] [using/] [fw aw iw] [, ///
        /// general
        Format(int 2) FFormat(str) noMISsing ///
        Tabulate(str) Rows(str) all ///
        noLabel noValue noName noTItle noWrap TRUNCate ///
        Includelabeled Include2(numlist integer missingok sort) subpop(passthru) ///
        Width(int 50) MINWidth(int 0) AScending DEscending ///
        SUBStitute(str asis) ///
        /// export
        Replace Append tex tab BODYonly COMbine pre(str asis) post(str asis) ///
     ]
    if `"`rows'"'!="" {
        capt local rows = int((`rows')/2)
        if _rc {
            di as err "option rows() incorrectly specified"
            exit 198
        }
    }
    if `"`tabulate'"'!="" {
        capt local tabulate = int(`tabulate')
        if _rc {
            di as err "option tabulate() incorrectly specified"
            exit 198
        }
    }
    else if `"`rows'"'!="" {
        local tabulate `rows'
    }
    else local tabulate 20
    if `format'<0 local format "0"
    local format "%11.`format'f"
    if `"`fformat'"'!="" {
        capt confirm numeric format `fformat'
        if _rc {
            di as err "option fformat() incorrectly specified"
            exit _rc
        }
    }
    else local fformat "%9.0g"
    if "`missing'"=="" local missing missing
    else local missing
    local wrap = ("`wrap'"=="")
    local label = ("`label'"=="")
    local value = ("`value'"=="")
    local name = ("`name'"=="")
    local title = ("`title'"=="")
    if `label'==0 & `value'==0 {
        di as err "novalue and nolabel not both allowed"
        exit 198
    }
    if "`ascending'"!="" & "`descending'"!="" {
        di as err "ascending and descending not both allowed"
        exit 198
    }
    if "`replace'"!="" & "`append'"!="" {
        di as err "replace and append not both allowed"
        exit 198
    }
    if "`tex'"!="" & "`tab'"!="" {
        di as err "tex and tab not both allowed"
        exit 198
    }
    local strvar: type `varlist'
    local strvar = (substr("`strvar'",1,3)=="str")
    if `tabulate'<1 local tabulate .
    if "`all'"!=""  local tabulate .
// compute frequencies
    tempvar touse
    mark `touse' `if' `in' [`weight'`exp']
    if `strvar' {
        tempname count
        tabulate `varlist' if `touse' [`weight'`exp'], `missing' `subpop' nofreq matcell(`count')
    }
    else {
        tempname count val
        tabulate `varlist' if `touse' [`weight'`exp'], `missing' `subpop' nofreq matcell(`count') matrow(`val')
    }
    if r(r)==0 {
        if `"`using'"'!="" {
            mata: fre_write_empty()
        }
        _return_zeroN `varlist' `label'
        exit
    }
    if `strvar'==0 & ( "`includelabeled'`include2'"!="" ) {
        _fillin_zeros `varlist' `count' `val' "`includelabeled'" "`include2'" `missing'
    }
// variable label
    local tilab
    if `label' local tilab : var lab `varlist'
// display/export table
    mata: fre_display_or_export()
end

prog _return_zeroN, rclass
    args varlist label
    if `label' {
        ret local label: var lab `varlist'
    }
    ret local depvar "`varlist'"
    ret scalar N_missing = 0
    ret scalar N_valid = 0
    ret scalar N = 0
end

prog _fillin_zeros
    args varlist count val uselabels values missing
    if "`uselabels'"!="" _get_values_from_labdef `varlist'
    local values: list values | labvals
    if "`values'"=="" exit
    mata: fre_fillin_zeros()
end

prog _get_values_from_labdef
    args varlist
    local labdef: value label `varlist'
    if `"`labdef'"'=="" {
        c_local labvals
        exit
    }
    tempfile fn
    qui label save `labdef' using `"`fn'"'
    tempname fh
    file open `fh' using `"`fn'"', read
    file read `fh' line
    local values
    while r(eof)==0 {
        gettoken value line : line // label
        gettoken value line : line // define
        gettoken value line : line // `labdef'
        gettoken value line : line // value
        local values "`values'`value' "
        file read `fh' line
    }
    file close `fh'
    c_local labvals "`values'"
end

mata:
void fre_prepare_append()
{
    fn = st_local("using")
    append = st_local("append")
    replace = st_local("replace")
    if (replace!="") unlink(fn)
    else if (append=="") {
        if (fileexists(fn)) _error(602,"file "+fn+" already exists")
    }
    st_local("replace","")
}

void fre_display_or_export()
{
    wrap   = (st_local("wrap")!="0")
    miss   = (st_local("missing")!="")
    strvar = (st_local("strvar")=="1")
    subst  = st_local("substitute")
    colwd  = `COLWIDTH'
    nobr   = `NOBREAK'
// get counts and labels and determine N and k
    count = st_matrix(st_local("count"))
    if (strvar) {
        lbls = uniqrows(st_sdata(., st_local("varlist"), st_local("touse")))
        if (miss==0) lbls = select(lbls, lbls:!="")
    }
    else {
        vals = st_matrix(st_local("val"))
        lbls = fre_getlabels(st_local("varlist"), vals, st_local("label")=="1")
    }
    if (rows(lbls)>0 & subst!="") fre_substitute(lbls, subst)
    N = colsum(count)
    if (miss) {
        if (strvar) m = (lbls:=="")
        else        m = rowmissing(vals)
        Nv = colsum(count:*!m)
        kv = colsum(!m)
        Nm = colsum(count:*m)
        km = colsum(m)
    }
    else {
        Nv = N; kv = length(count); Nm = km = 0
    }
    haslbls2 = 0
    numlbls  = 0
    if (strvar==0) {
        if (rows(lbls)==0) {
            lbls = fre_sprintf(vals, st_varformat(st_local("varlist")))
//          numlbls = 1
        }
        else if (st_local("value")=="0")
            lbls = fre_sprintf(vals, st_varformat(st_local("varlist"))):*(lbls:=="") + lbls
        else if (st_local("combine")!="")
            lbls = fre_sprintf(vals, st_varformat(st_local("varlist"))) + " ":*(lbls:!="") + lbls
        else {
            lbls = fre_sprintf(vals, st_varformat(st_local("varlist"))), lbls
            haslbls2 = 1
        }
    }
// move missings to end in case of strvar
    if (strvar & km>0 & kv>0) {
        count = count[|2 \ .|] \ count[1] // only 1 missing possible ("")
        lbls = lbls[|2 \ .|] \ lbls[1]
    }
// sort table
    sort = (st_local("ascending")!="" ? 1 : (st_local("descending")!="" ? 2 : 0))
    if (sort & kv>0) {
        if (sort==1) p = order((count[|1 \ kv|],(1::kv)),(1,2))
        if (sort==2) p = revorder(order((count[|1 \ kv|],(kv::1)),(1,2)))
        count[|1 \ kv|] = count[p]
        lbls[|1,1 \ kv,.|] = lbls[p,.]
    }
// prepare title
    tilab = st_local("tilab")
    if (tilab!="" & subst!="") fre_substitute(tilab, subst)
    vname = ( st_local("name")!="0" | tilab=="" ? st_local("varlist") : "" )
// compile header
    header = (J(1,1+cols(lbls),""),`LBL_FREQ',`LBL_PERC',`LBL_VALPERC',`LBL_CUMPERC')
    if (wrap | st_local("using")=="") { // always wrap for SMCL display
        npieces = fre_npieces(header, colwd, nobr)
        r = max(npieces)
        header = J(r-1,cols(header),"") \ header
        for (i=1; i<=cols(header); i++) {
            if (npieces[i]<2) continue
            header[|r-npieces[i]+1,i \ r,i|] = fre_pieces(header[r,i], colwd, nobr)'
        }
    }
// compile body
    addfwd = max((strlen(sprintf(st_local("fformat"),1))-colwd+1,0))
    sw = miss ? max(fre_udstrlen((`LBL_VALID',`LBL_MISSING',`LBL_TOTAL'))) : 0
    maxw = (st_local("using")=="" ? st_numscalar("c(linesize)") -
     ( sw + 3 + (3+miss)*colwd + addfwd) - 1 : .)
    if (haslbls2) {
        wd = J(1,2,.)
        wd[1] = max(fre_udstrlen(lbls[,1]))
        maxw = maxw - wd[1] - 1
        wd[2] = min((strtoreal(st_local("width"))-wd[1]-1,max(fre_udstrlen(lbls[,2])),maxw))
        wd[2] = max((wd[2], min((strtoreal(st_local("minwidth"))-wd[1]-1,maxw)),
              fre_udstrlen(`LBL_TOTAL')-wd[1]-1,2))
    }
    else {
        wd = min((strtoreal(st_local("width")),max(fre_udstrlen(lbls)), maxw))
        wd = max((wd, min((strtoreal(st_local("minwidth")),maxw)), fre_udstrlen(`LBL_TOTAL')))
    }
    if (st_local("truncate")!="") {
        if (stataversion()>=1400 & wd[cols(wd)]==1) { // keep at least one char
            lbls[,cols(lbls)] = fre_usubstr(lbls[,cols(lbls)],1,1)
        }
        else lbls[,cols(lbls)] = fre_udsubstr(lbls[,cols(lbls)],1,wd[cols(wd)])
    }
    if (wrap) npieces = fre_npieces(lbls[,cols(lbls)], wd[cols(wd)], nobr)
    else      npieces = J(rows(lbls),1,1)
    body  = J(km+kv+(km>1)+(kv>1)+(kv>0&km>0)+sum(npieces)-rows(lbls),5+cols(lbls),"")
    format = st_local("format")
    fformat = st_local("fformat")
    i0 = 1
    cum = 0
    for (i=1;i<=rows(lbls);i++) {
        if (wrap) {
            body[|i0,1+cols(lbls) \ i0+npieces[i]-1,1+cols(lbls)|] =
             fre_pieces(lbls[i,cols(lbls)], wd[cols(wd)] , nobr)'
            if (cols(lbls)==2) body[i0,2] = lbls[i,1]
        }
        else body[|i0,2 \ i0,2+cols(lbls)-1|] = lbls[i,]
        if (i<=kv) {
            if (i==1) body[i0,1] = `LBL_VALID'
            body[i0,cols(lbls)+2..cols(body)] = fre_sprintf(count[i], fformat), fre_sprintf((count[i]/N*100,
             count[i]/Nv*100, (cum = cum + count[i])/Nv*100), format)
            if (kv>1 & i==kv) body[(i0++)+npieces[i],2..cols(body)-1] =
             (`LBL_TOTAL', J(1,cols(lbls)-1,""), fre_sprintf(Nv, fformat), fre_sprintf((Nv/N*100, Nv/Nv*100), format))
        }
        else {
            if (i==kv+1) body[i0,1] = `LBL_MISSING'
            body[i0,cols(lbls)+2..cols(body)-2] = fre_sprintf(count[i], fformat), fre_sprintf(count[i]/N*100, format)
            if (km>1 & i==kv+km) body[(i0++)+npieces[i],2..cols(body)-2] =
             (`LBL_TOTAL', J(1,cols(lbls)-1,""), fre_sprintf(Nm, fformat), fre_sprintf(Nm/N*100, format))
        }
        i0 = i0 + npieces[i]
    }
    if (kv>0&km>0) body[i0,1..cols(body)-2] =
     (`LBL_TOTAL', J(1,cols(lbls),""), fre_sprintf(N, fformat), fre_sprintf(N/N*100, format))
// remove left stub and valid percent column if no missing
    if (miss==0) {
        header = header[.,(2..1+cols(lbls)+2,cols(body))]
        body = body[.,(2..1+cols(lbls)+2,cols(body))]
    }
// output
    if (st_local("using")=="") {
        wd[cols(wd)] = max((min((strtoreal(st_local("minwidth")),maxw))
         \ min((max(fre_udstrlen(body[.,miss+cols(lbls)])),wd[cols(wd)]))
         \ fre_udstrlen(`LBL_TOTAL')-wd[1]-1))
        fre_display_smcl(vname, tilab, header, body, sw, wd, numlbls,
         (kv==0 ? J(0,1,.) : npieces[|1 \ kv|]))
    }
    else fre_export_tab_or_tex(vname, tilab, header, body, cols(lbls),
     (kv==0 ? J(0,1,.) : npieces[|1 \ kv|]), miss)
//returns
    st_rclear()
    if (cols(lbls)==2) lbls = lbls[,1] + " ":*(lbls[,2]:!="")+ lbls[,2]
    if (km>0) {
        st_matrix("r(missing)",count[|kv+1 \ .|])
        st_global("r(lab_missing)",fre_invtokens(lbls[|kv+1 \ .|]))
    }
    if (kv>0) {
        st_matrix("r(valid)",count[|1 \ kv|])
        st_global("r(lab_valid)",fre_invtokens(lbls[|1 \ kv|]))
    }
    st_numscalar("r(N)",N)
    st_numscalar("r(N_valid)",Nv)
    st_numscalar("r(N_missing)",Nm)
    st_numscalar("r(r)",kv+km)
    st_numscalar("r(r_valid)",kv)
    st_numscalar("r(r_missing)",km)
    st_global("r(label)", tilab)
    st_global("r(depvar)",st_local("varlist"))
}

string matrix fre_sprintf(real matrix X, string scalar fmt)
{
    real scalar     i, j, R, C
    string matrix   S

    if (length(X)==1) return(fre_ustrltrim(sprintf(fmt, X)))
    S = J(R=rows(X), C=cols(X), "")
    if (C==1) {
        for (i=1; i<=R; i++) {
            S[i,1] = fre_ustrltrim(sprintf(fmt, X[i,1]))
        }
        return(S)
    }
    if (R==1) {
        for (j=1; j<=C; j++) {
            S[1,j] = fre_ustrltrim(sprintf(fmt, X[1,j]))
        }
        return(S)
    }
    for (i=1; i<=R; i++) {
        for (j=1; j<=C; j++) {
            S[i,j] = fre_ustrltrim(sprintf(fmt, X[i,j]))
        }
    }
    return(S)
}

void fre_substitute(string colvector lbls, string scalar subst)
{
    sub = tokens(subst)
    if (mod(length(sub),2)) sub = (sub, "") // last "to" is empty
    for (i=1; i<=length(sub); i=i+2) {
        lbls = subinstr(lbls, sub[i], sub[i+1])
    }
}

void fre_display_smcl(
 string scalar vname,
 string scalar tilab,
 string matrix header,
 string matrix body,
 real scalar sw,
 real rowvector wd,
 real scalar numlbls,
 real vector npieces)
{
    if (stataversion()>=1400) ud = "ud"
    else                      ud = ""
    hasls   = (sw>0)
    if (hasls) swd = "%-"+strofreal(sw)+ud+"s"
    else {
        body[,1] = " " :+ body[,1]
        wd[1] = wd[1]+1
    }
    hasl2   = (cols(wd)==2)
    lwd = "%"+"-"*(numlbls==0)+strofreal(wd[1])+ud+"s"
    if (hasl2) lwd2 = "%-"+strofreal(wd[2])+ud+"s"
    tisep   = `SMCL_TISEP'
    ntab    = trunc(strtoreal(st_local("tabulate")))
    ntabmax = (ntab*2+1)
    kv      = length(npieces)
    dcol    = cols(body)-1-hasl2-hasls
    cwd     = J(1, dcol, "%`COLWIDTH'"+ud+"s")
    addfwd  = max((strlen(sprintf(st_local("fformat"),1))-`COLWIDTH'+1,0))
    cwd[1]  = "%" + strofreal(`COLWIDTH'+addfwd) + ud + "s" 
    display("")
    if (st_local("title")!="0")
        display("{txt}" + vname + (vname!=""&tilab!="" ? tisep : "") + tilab)
    display("{txt}{hline "+strofreal(sw+hasls+sum(wd)+hasl2)+
            "}{hline 1}{c TT}{hline "+strofreal(dcol*`COLWIDTH'+addfwd)+"}")
    for (i=1;i<=rows(header);i++) {
        printf("{txt}")
        if (hasls) printf(swd+" ", header[i,1])
        printf("{txt}"+lwd, header[i,hasls+1])
        if (hasl2) printf(" "+lwd2, header[i,hasls+2])
        printf(" {c |}")
        for (l=1;l<=dcol;l++) printf(cwd[l], header[i,hasls+1+hasl2+l])
        printf("\n")
    }
    display("{txt}{hline "+strofreal(sw+hasls+sum(wd)+hasl2)+
            "}{hline 1}{c +}{hline "+strofreal(dcol*`COLWIDTH'+addfwd)+"}")
    if (stataversion()>=1400 & wd[cols(wd)]==2) { // keep at least one char
        body[.,hasls+1+hasl2] = fre_usubstr(body[.,hasls+1+hasl2], 1, 2)
    }
    else body[.,hasls+1+hasl2] = fre_udsubstr(body[.,hasls+1+hasl2],1,wd[cols(wd)])
    j = 1
    r = 1
    for (i=1;i<=rows(body);i++) {
        if (kv>ntabmax & r==ntab+1) { // skip middle part of table
            printf("{txt}")
            if (hasls) printf(swd+" ", "")
            printf(lwd, !hasls*" "+`SMCL_DOTS')
            if (hasl2) printf(" "+lwd2, "")
            printf(" {c |}")
            for (l=1;l<=dcol;l++) printf(cwd[l], `SMCL_DOTS')
            printf("\n")
            i = i + sum(npieces[|r \ kv-ntab|])-1
            r = kv-ntab+1
            continue
        }
        printf("{txt}")
        if (hasls) printf(swd+" ", body[i,1])
        if (hasl2) {
            if (body[i,hasls+1]==!hasls*" "+`LBL_TOTAL' & body[i,hasls+2]=="")
             printf("%-"+strofreal(sum(wd)+1)+"s", body[i,hasls+1])
            else printf(lwd+" "+lwd2, body[i,hasls+1], body[i,hasls+2])
        }
        else printf(lwd, body[i,hasls+1])
        printf(" {c |}{res}")
        for (l=1;l<=dcol;l++) printf(cwd[l], body[i,hasls+1+hasl2+l])
        printf("\n")
        if (r<kv) {
            if (j++==npieces[r]) {
                j = 1; r ++
            }
        }
    }
    display("{txt}{hline "+strofreal(sw+hasls+sum(wd)+hasl2)+
            "}{hline 1}{c BT}{hline "+strofreal(dcol*`COLWIDTH'+addfwd)+"}")
}

void fre_export_tab_or_tex(
 string scalar vname,
 string scalar tilab,
 string matrix header,
 string matrix body,
 real scalar nlblcol,
 real vector npieces,
 real scalar miss)
{
    fn     = st_local("using")
    type   = st_local("tab")+st_local("tex")
    if (type=="") {
        if (pathsuffix(fn)==".tex") type = "tex"
        else type = "tab"
    }
    append   = (st_local("append")!="" ? "a" : "w")
    replace  = (st_local("replace")!="")
    bodyonly = (st_local("bodyonly")!="")
    pre      = st_local("pre")
    if (strpos(pre,`"""'))  pre  = tokens(pre)
    post     = st_local("post")
    if (strpos(post,`"""')) post = tokens(post)
    if (type=="tex") {
        tisep  = `TEX_TISEP'
        dots   = `TEX_DOTS'
        colsep = `TEX_COLSEP'
        eol    = `TEX_EOL'
        rule   = `TEX_RULE'
        tbegin = `TEX_TBEGIN'
        tend   = `TEX_TEND'
        wd = colmax(fre_udstrlen(header)\fre_udstrlen(body)\J(1,cols(body),fre_udstrlen(dots)))
        header = (wd:-fre_udstrlen(header)):*" " + header
        body   = (wd:-fre_udstrlen(body)):*" " + body
        thevname = subinstr(vname,"_","\_")
    }
    else /*if (type=="tab")*/ {
        tisep  = `TAB_TISEP'
        dots   = `TAB_DOTS'
        colsep = `TAB_COLSEP'
        eol    = ""
        rule   = ""
        tbegin = ""
        tend   = ""
        wd = J(1,cols(body),0)
        thevname = vname
    }
    ntab    = trunc(strtoreal(st_local("tabulate")))
    ntabmax = (ntab*2+1)
    kv      = length(npieces)
    fe      = fileexists(fn)
    if (replace) unlink(fn)
    fh = fopen(fn, append)
    if (append=="a" & fe) fput(fh,"")
    for (i=1;i<=length(pre);i++) fput(fh,pre[i])
    if (st_local("_byindex")!="") {
        fput(fh, fre_bymsg())
        fput(fh,"")
    }
    if (bodyonly==0) {
        if (st_local("title")!="0") {
            fput(fh, thevname + (vname!=""&tilab!="" ? tisep : "") + tilab)
            fput(fh,"")
        }
        if (tbegin!="") fput(fh,tbegin)
        for (i=1;i<=rows(header);i++) {
            for (j=1;j<=cols(header);j++) {
                fwrite(fh, header[i,j])
                if (j<cols(header)) fwrite(fh, colsep)
                else fput(fh, eol)
            }
        }
        if (rule!="") fput(fh,rule)
    }
    j = 1
    r = 1
    for (i=1;i<=rows(body);i++) {
        if (kv>ntabmax & r==ntab+1) { // skip middle part of table
            for (l=1;l<=cols(body);l++) {
                if (l==1 | (l==3&nlblcol==2)) fwrite(fh, wd[l]*" ")
                else fwrite(fh,  (wd[l]-fre_udstrlen(dots))*" "+dots)
                if (l<cols(body)) fwrite(fh, colsep)
                else fput(fh, eol)
            }
            i = i + sum(npieces[|r \ kv-ntab|])-1
            r = kv-ntab+1
            continue
        }
        for (l=1;l<=cols(body);l++) {
            fwrite(fh, body[i,l])
            if (l<cols(body)) fwrite(fh, colsep)
            else fput(fh, eol)
        }
        if (r<kv) {
            if (j++==npieces[r]) {
                j = 1; r ++
            }
        }
    }
    if (bodyonly==0) {
        if (tend!="") fput(fh,tend)
    }
    for (i=1;i<=length(post);i++) fput(fh,post[i])
    fclose(fh)
}

void fre_write_empty()
{
    fn     = st_local("using")
    type   = st_local("tab")+st_local("tex")
    if (type=="") {
        if (pathsuffix(fn)==".tex") type = "tex"
        else type = "tab"
    }
    append  = (st_local("append")!="" ? "a" : "w")
    replace = (st_local("replace")!="")
    if (replace) unlink(fn)
    fh = fopen(fn, append)

    fclose(fh)
}

real matrix fre_npieces(string matrix S, real scalar w, | real scalar nobreak)
{
    real scalar  i, j
    real matrix  res

    res = J(rows(S),cols(S),1)
    if (w>=.) return(res)
    for (i=1; i<=rows(S); i++) {
        for (j=1; j<=cols(S); j++) {
            res[i,j] = _fre_npieces(S[i,j], w, (args()>2 ? nobreak : 0))
        }
    }
    return(res)
}

real scalar _fre_npieces(string scalar s, real scalar w, | real scalar nobreak)
{
    real scalar   i, j, k, n, l, b, nobr
    string scalar c

    nobr = ( args()>2 ? nobreak : 0 )
    l = fre_udstrlen(s)
    if (l<2 | w>=l) return(1)
    l = fre_ustrlen(s)
    j = k = n = 0
    b = 1
    for (i=1; i<=l; i++) {
        c = fre_usubstr(s, i, 1)
        if (j<1) { // skip to first nonblank character
            if (fre_ustrtrim(c)=="") continue
        }
        j = j + fre_udstrlen(c)
        if (i==l) {
            if (w>1 & !nobr) { // add extra row if last char is ud
                if (j>w) n++
            }
            n++
        }
        else {
            if (fre_ustrtrim(c)=="") k = i
            if (j>=w) {
                if (k<1) {
                    if (nobr) continue
                    if (i>b & j>w) k = i-1
                    else           k = i
                }
                else {
                    if (fre_ustrtrim(fre_usubstr(s, i+1, 1))=="") k = i
                }
                n++
                j = fre_udstrlen(fre_usubstr(s, k+1, i-k))
                b = k + 1
                k = 0
            }
        }
    }
    if (n==0) n++
    return(n)
}

string rowvector fre_pieces(string scalar s, real scalar w, | real scalar nobreak)
{
    real scalar         i, j, k, n, l, b, nobr
    string scalar c
    string rowvector    res

    nobr = ( args()>2 ? nobreak : 0 )
    l = fre_ustrlen(s)
    if (l<2 | w>=l) return(fre_ustrtrim(s))
    res = J(1, _fre_npieces(s, w, nobr), "")
    l = fre_ustrlen(s)
    j = k = n = 0
    b = 1
    for (i=1; i<=l; i++) {
        c = fre_usubstr(s, i, 1)
        if (j<1) { // skip to first nonblank character
            if (fre_ustrtrim(c)=="") {
                b++
                continue
            }
        }
        j = j + fre_udstrlen(c)
        if (i==l) {
            if (w>1 & !nobr) { // add extra row if last char is ud
                if (j>w) {
                    res[++n] = fre_ustrtrim(fre_usubstr(s, b, i-b))
                    b = i
                }
            }
            res[++n] = fre_ustrtrim(fre_usubstr(s, b, .))
        }
        else {
            if (fre_ustrtrim(c)=="") k = i
            if (j>=w) {
                if (k<1) {
                    if (nobr) continue
                    if (i>b & j>w) k = i-1
                    else           k = i
                }
                else {
                    if (fre_ustrtrim(fre_usubstr(s, i+1, 1))=="") k = i
                }
                res[++n] = fre_ustrtrim(fre_usubstr(s, b, k-b+1))
                j = fre_udstrlen(fre_usubstr(s, k+1, i-k))
                b = k + 1
                k = 0
            }
        }
    }
    return(res)
}

void fre_fillin_zeros()
{
    val = st_matrix(st_local("val"))
    addval = strtoreal(tokens(st_local("values")))'
    p = J(rows(addval),1,0)
    j = 1
    for (i=1;i<=rows(addval);i++) {
        while (j<rows(val)) {
            if (val[j]<addval[i]) j++
            else break
        }
        if (val[j]!=addval[i]) p[i] = 1
    }
    addval = select(addval, p)
    if (length(addval)==0) return
    val = val \ addval
    count = st_matrix(st_local("count")) \ J(rows(addval),1,0)
    if (st_local("missing")=="") {
        count = select(count, val:<.)
        val = select(val, val:<.)
    }
    p = order(val,1)
    st_matrix(st_local("count"), count[p])
    st_matrix(st_local("val"), val[p])
}

string scalar fre_invtokens(string vector In)
{
    string scalar Out
    real scalar i

    Out = ""
    for (i=1; i<=length(In); i++) {
        Out = Out + (i>1 ? " " : "") + "`" + `"""' + In[i] + `"""' + "'"
    }
    return(Out)
}

string colvector fre_getlabels(string scalar var, real colvector vals,
    real scalar label)
{
    real scalar         r
    string scalar       vlab, lab
    string colvector    res

    if (label==0) return(J(0, 1, ""))
    vlab = st_varvaluelabel(var)
    if (vlab=="") return(J(0, 1, ""))
    //if (st_vlexists(vlab)==0) return(J(0, 1, ""))
    return(st_vlmap(vlab, vals))
}

string scalar fre_bymsg()
{
    real scalar         i
    string scalar       bymsg, var, vlab, lab
    string rowvector    byvars
    transmorphic scalar val

    byvars = tokens(st_local("_byvars"))
    if (length(byvars)<1) return("")
    bymsg = "-> "
    for (i=1;i<=length(byvars);i++) {
        if (i>1) bymsg = bymsg + ", "
        var = byvars[i]
        val = st_data(strtoreal(st_macroexpand("`"+"=_byn1()"+"'")), var)
        if (isstring(val)) lab = val
        else {
            lab = ""
            vlab = st_varvaluelabel(var)
            if (vlab!="") {
                if (st_vlexists(vlab)) lab = st_vlmap(vlab, val)
            }
            if (lab=="") lab = strofreal(val)
        }
        bymsg = bymsg + var + " = " + lab
    }
    return(bymsg)
}

// support for unicode (Stata 14 or newer)
real matrix fre_udstrlen(string matrix s)
{
    if (stataversion()>=1400) return(_fre_udstrlen(s))
    return(strlen(s))
}
real matrix _fre_udstrlen(string matrix s)
{
    return(udstrlen(s))
}

real matrix fre_ustrlen(string matrix s)
{
    if (stataversion()>=1400) return(_fre_ustrlen(s))
    return(strlen(s))
}
real matrix _fre_ustrlen(string matrix s)
{
    return(ustrlen(s))
}

string matrix fre_udsubstr(string matrix s, real matrix b, | real matrix l)
{
    if (args()<3) l = .
    if (stataversion()>=1400) return(_fre_udsubstr(s, b, l))
    return(substr(s, b, l))
}
string matrix _fre_udsubstr(string matrix s, real matrix b, real matrix l)
{
    return(udsubstr(s, b, l))
}

string matrix fre_usubstr(string matrix s, real matrix b, | real matrix l)
{
    if (args()<3) l = .
    if (stataversion()>=1400) return(_fre_usubstr(s, b, l))
    return(substr(s, b, l))
}
string matrix _fre_usubstr(string matrix s, real matrix b, real matrix l)
{
    return(usubstr(s, b, l))
}

string matrix fre_ustrtrim(string matrix s)
{
    if (stataversion()>=1400) return(_fre_ustrtrim(s))
    return(strtrim(s))
}
string matrix _fre_ustrtrim(string matrix s)
{
    return(ustrtrim(s))
}

string matrix fre_ustrltrim(string matrix s)
{
    if (stataversion()>=1400) return(_fre_ustrltrim(s))
    return(strltrim(s))
}
string matrix _fre_ustrltrim(string matrix s)
{
    return(ustrltrim(s))
}

end
