*! version 1.3.0 27may2020 daniel klein
program elabel_cmd_rename
    version 11.2
    mata : elabel_cmd_rename()
end

version 11.2

// -------------------------------------- Mata type declarations
local S        scalar
local R        rowvector
local C        colvector
local M        matrix

local TS       transmorphic `S'

local RS       real         `S'

local SS       string       `S'
local SR       string       `R'
local SC       string       `C'
local SM       string       `M'

local Boolean              `RS'
local BooleanR real         `R'
local True                   1
local False                  0

local Rename struct ElabelRename_ `S'

// -------------------------------------- unicode support
if (c(stata_version) >= 14) {
    local ustr ustr
    local ud   ud
}

// -------------------------------------- Mata
mata :

mata set matastrict on

struct ElabelRename_OldPattern_
{
    `RS' ncard
    `SR' wcard
    `SR' names
    `SM' match
}

struct ElabelRename_
{
    `Boolean'                       nomem
    `Boolean'                       force
    `Boolean'                       dryrun
    `Boolean'                       rclass
    `SR'                            oldin
    `SR'                            newin
    `SS'                            eexp
    struct ElabelRename_OldPattern_ oldp
    `RS'                            ipat
    `Boolean'                       newvalid
    `SR'                            oldnames
    `SR'                            newnames
    `SR'                            oldisnew
    `BooleanR'                      oldexist
}

    // ---------------------------------- main
void elabel_cmd_rename()
{
    `SS'     input
    `Rename' r
    
    elabel_u_st_syntax(st_local("0"), 
    "[ anything(id=lblname equalok everything) ]"
    + "[ , noMEMory FORCE Dryrun Return DEBUG * ]")
    
    input = st_local("anything")
    recase_opts(input, st_local("options"))
    
    r.nomem    = (st_local("memory") == "nomemory")
    r.force    = (st_local("force")  == "force")
    r.dryrun   = (st_local("dryrun") == "dryrun")
    r.rclass   = (st_local("return") == "return")
    
    split_input(input, r)
    
    if ( rename_eexp(r) ) return
    
    rename_pattern(r)
}

        // ------------------------------ recase options
void recase_opts(`SS' input, `SS' options)
{
    `SR' fcn
    
    if (options == "") return
    
    elabel_u_st_syntax((", "+options), "[ , Upper Lower Proper Title ]")
    if (st_local("title") == "title") st_local("proper", "proper")
    fcn = (st_local("upper"), st_local("lower"), st_local("proper"))
    if (cols((fcn=select(fcn, (fcn:!="")))) > 1) {
        errprintf("options %s and %s", fcn[1], fcn[2])
        errprintf(" cannot be specified together\n")
        exit(198)
    }
    
    if ((stataversion()>=1400) & (fcn=="proper")) fcn = "title"
    
    if ( !regexm(input, "^[ ]*\(.+\)") ) input = ("("+input+")")
    input = sprintf("%s (=`ustr'%s(@))", input, fcn)
}

        // ------------------------------ split_input
void split_input(`SS' input, `Rename' r)
{
    `TS' t
    
    t = tokeninit(" ", "(")
        tokenset(t, input)
    
    if (tokenpeek(t) != "(") {
        tokenpchars(t, J(1, 0, ""))
        r.oldin = tokenget(t)
        tokenpchars(t, "(")
    }
    else r.oldin = elabel_u_tokenget_inpar(t, `False')
    if ( !cols((r.oldin=elabel_u_tokensq(r.oldin))) ) exit(error(198))
    
    if (tokenpeek(t) != "(") {
        tokenpchars(t, J(1, 0, ""))
        r.newin = tokenget(t)
    }
    else {
        r.newin = elabel_u_tokenget_inpar(t, `False')
        (void) elabel_u_iseexp(r.newin, r.eexp)
    }
    if ( !cols((r.newin=elabel_u_tokensq(r.newin))) ) exit(error(198))
    
    if (tokenrest(t) != "") exit(error(198))
}

        // ------------------------------ (oldlblnamelist) (=eexp)
`Boolean' rename_eexp(`Rename' r)
{
    class Elabel_eExp `S' e
    `RS'                  i
    
    if ( !strpos(r.eexp, "@") ) return(`False')
    
    e.eexp(r.eexp)
    if ( e.hashash() ) {
        errprintf("# character not allowed in {it:eexp}\n")
        exit(198)
    }
    
    if ( any(regexm(r.oldin, "#")) ) {
        r.oldp = ElabelRename_OldPattern_( cols(r.oldin) )
        r.newvalid = `True'
        for (i=1; i<=cols(r.oldin); ++i) parse_oldp(r, i)
    }
    else r.oldnames = elabel_unab(r.oldin, r.nomem)
    
    e.wildcards(., r.oldnames')'
    r.newnames = e.eexp()'
    
    rename_exe(r)
    
    return(`True')
}

        // ------------------------------ (oldpattern) (newpattern)
void rename_pattern(`Rename' r)
{
    `RS' nnew, nold
    
    if ( (!(r.newvalid=elabel_u_assert_name(r.newin, `False'))) |
          any(regexm(r.oldin, "#")) ) parse_pattern(r)
    else {
        r.oldnames = elabel_unab(r.oldin, r.nomem)
        r.newnames = r.newin
    }
    
    if ((nnew=cols(r.newnames)) != (nold=cols(r.oldnames))) 
        ErrNewNames( ((nnew<nold) ? "few" : "many") )
    
    rename_exe(r)
}

void parse_pattern(`Rename' r)
{
    `RS' i
    
    r.oldp = ElabelRename_OldPattern_( cols(r.oldin) )
    r.ipat = 0
    
    for (i=1; i<=cols(r.oldp); ++i) {
        parse_oldp(r, i)
        match_newp(r, i)
    }
    
    if (r.ipat < cols(r.newin)) ErrNewNames("many")
}

void parse_oldp(`Rename' r, `RS' i)
{
    `RS' c, k
    `SS' ch, pat, rex
    
    c   = r.oldp[i].ncard = 0
    pat = rex             = ""
    
    while ((ch=substr(r.oldin[i], ++c, 1)) != "") {
        if ( !anyof(("*", "?", "~", "#", "(", ")"), ch) ) {
            pat = (pat + ch)
            rex = (rex + ch)
        }
        else if ( anyof(("*", "?", "~", "#", "("), ch) ) {
            (void) ++r.oldp[i].ncard
            if ( !anyof(("#", "("), ch) ) {
                pat = (pat + ch)
                rex = ( rex + "(" + ((substr(r.oldin[i], (c+1), 1) != "#") ? 
                                   "." : "[^0-9]") + ("*"*(ch!="?")) + ")" )
            }
            else if (ch == "#") {
                pat = (pat + "?*")
                rex = (rex + "([0-9]+)")
            }
            else if (ch == "(") {
                rex = (rex + ch)
                while ((ch=substr(r.oldin[i], ++c, 1)) == "#") {
                    pat = (pat + "?")
                    rex = (rex + "[0-9]")
                }
                if (ch != ")") ErrTooMany("'('", r.oldin[i], 132)
                rex = (rex + ch)
                ch = "#"
            }
            r.oldp[i].wcard = (r.oldp[i].wcard, ch)
        }
        else if (ch==")") ErrTooMany("')'", r.oldin[i], 132)
        else ERR("parse_oldp()")
    }
    if (r.oldp[i].ncard > 9) ErrTooMany("wildcards", r.oldin[i])
    
    rex = ("^" + rex + "$")
    
    r.oldp[i].names = elabel_unab(pat, r.nomem)
    r.oldp[i].names = select(r.oldp[i].names, 
            `ustr'regexm(r.oldp[i].names, rex))
    if ( !cols(r.oldp[i].names) ) {
        errprintf("value label %s not found\n", r.oldin[i])
        exit(111)
    }
    
    r.oldnames = (r.oldnames, r.oldp[i].names)
    
    if (r.newvalid) return
    
    r.oldp[i].match = J(r.oldp[i].ncard, cols(r.oldp[i].names), "")
    for (c=1; c<=cols(r.oldp[i].names); ++c) {
        if ( !(`ustr'regexm(r.oldp[i].names[c], rex)) ) continue
        for (k=1; k<=r.oldp[i].ncard; ++k) 
            r.oldp[i].match[k, c] = `ustr'regexs(k)
    }
}

void match_newp(`Rename' r, `RS' i)
{
    `RS' c, idx, ncard
    `RR' dig
    `SC' newnames
    `SS' ch
    
    if (r.ipat < cols(r.newin)) (void) ++r.ipat
    if ( st_isname(r.newin[r.ipat]) ) {
        r.newnames = (r.newnames, r.newin[r.ipat])
        for (c=2; c<=cols(r.oldp[i].names); ++c) {
            if (  (++r.ipat) > cols(r.newin) ) ErrNewNames("few")
            if ( !st_isname(r.newin[r.ipat]) ) ErrNewNames("few")
            r.newnames = (r.newnames, r.newin[r.ipat])
        }
        return
    }
    
    c = ncard = 0
    newnames  = J(1, cols(r.oldp[i].names), "")
    
    while ((ch=substr(r.newin[r.ipat], ++c, 1)) != "") {
        if ( !anyof(("*", "?", "#", ".", "(", ")", "="), ch) ) 
            newnames = (newnames :+ ch)
        else if ( anyof(("*", "?", "#", ".", "("), ch) ) {
            dig = 0
            if (ch == "(") {
                while ((ch=substr(r.newin[r.ipat], ++c, 1)) == "#")  
                    (void) ++dig
                if ((ch!=")")|(!dig)) ErrTooMany("'('", r.newin[r.ipat], 132)
                ch = "#"
            }
            if ( (substr(r.newin[r.ipat], (c+1), 1) == "[") & (ch!=".") ) 
                idx = get_idx(r, i, ++c)
            else if ((idx=(++ncard)) > r.oldp[i].ncard) 
                ErrTooMany("wildcards", r.newin[r.ipat])
            if (ch == ".") continue
            if (ch != "*") {
               if (r.oldp[i].wcard[idx] != ch) {
                   errprintf("wildcard %s in %s", ch, r.newin[i])
                   errprintf(" not compatibale with wildcard ")
                   errprintf("%s in %s\n", r.oldp[i].wcard[idx], r.oldin[i])
                   exit(198)
               }
            }
            if ( !dig ) newnames = ( newnames :+ r.oldp[i].match[idx, ] )
            else newnames = ( newnames :+ rfmt(r.oldp[i].match[idx, ], dig) )
        }
        else if (ch == "=") newnames = (newnames :+ r.oldp[i].names)
        else if (ch == ")") ErrTooMany("')'", r.newin[r.ipat], 132)
        else ERR("match_newp()")
    }
    r.newnames = (r.newnames, newnames)
}

`RS' get_idx(`Rename' r, `RS' i, `RS' c)
{
    `TS' idx
    `SS' ch
    
    idx = ""
    while ((ch=substr(r.newin[r.ipat], ++c, 1)) != "]") {
        if (anyof(("", " "), ch)) break
        idx = (idx + ch)
    }
    if (ch != "]") ErrTooMany("'['", r.newin[r.ipat], 132)
    idx = strtoreal(idx)
    if ( !(missing(idx)|(idx<1)|(idx!=trunc(idx))|(idx>r.oldp[i].ncard)) )
        return(idx)
    errprintf("invalid subscript in %s\n", r.newin[r.ipat])
    if (idx > r.oldp[i].ncard) {
        errprintf("there are only %f wildcards in %s\n", 
                       r.oldp[i].ncard, r.oldin[r.ipat])
    }
    exit(198)
}

`SR' rfmt(`SR' match, `RS' dig)
{
    return( strofreal(strtoreal(match), sprintf("%%0%f.0f", dig)) )
}

        // ------------------------------ rename
void rename_exe(`Rename' r)
{
    class Elabel_ValueLabel `R' l
    `SS'                        clang
    `SC'                        langs
    `RS'                        brk, i
    
    pragma unset l
    select_labels(r, l)
    
    if (r.rclass) rename_return(r)
    
    if (r.dryrun) {
        rename_dryrun(r)
        return
    }
    
    if ( !cols(r.oldnames) ) return
    
    pragma unset clang
    pragma unset langs
    elabel_ldir(clang, langs)
    
    brk = setbreakintr(`False')
    for (i=1; i<=rows(langs); ++i) {
        (void) _stata("_label language "+langs[i], `True')
        rename_values(r)
    }
    if ( rows(langs) ) (void) _stata("_label language "+clang, `True')
    rename_values( r )
    for (i=1; i<=cols(r.oldnames); ++i) st_vldrop(r.oldnames[i])
    for (i=1; i<=cols(r.newnames); ++i) if (r.oldexist[i]) l[i].define()
    (void) setbreakintr(brk)
}

void rename_values(`Rename' r)
{
    `RS' k
    `SS' lblname
    
    for (k=1; k<=st_nvar(); ++k) {
        if ( !anyof(r.oldnames, (lblname=st_varvaluelabel(k))) ) continue
        st_varvaluelabel(k, select(r.newnames, (lblname:==r.oldnames)))
    }
}

void select_labels(`Rename' r, class Elabel_ValueLabel `R' l)
{
    `SM'        old_to_new
    `BooleanR'  old_is_new
    `RS'                 i
    class Elabel_Dir `S' d
    
    old_to_new = distinctrowsof( (r.oldnames\ r.newnames)' )'
    r.oldnames = old_to_new[1, ]
    r.newnames = old_to_new[2, ]
    
    old_is_new = (r.oldnames :== r.newnames)
    r.oldisnew = select(r.oldnames,  old_is_new)
    r.oldnames = select(r.oldnames, !old_is_new)
    r.newnames = select(r.newnames, !old_is_new)
    
    if ( !cols(r.oldnames) ) return
    
    elabel_u_assert_uniq(r.oldnames, "oldlblname")
    elabel_u_assert_uniq(r.newnames, "newlblname")
    
    l = Elabel_ValueLabel( cols(r.oldnames) )
    for (i=1; i<=cols(r.oldnames); ++i) {
        if ( !anyof(r.oldnames, r.newnames[i]) ) {
            elabel_u_assert_newlblname(r.newnames[i])
            if ( !r.force ) {
                if ( anyof(d.attached(), r.newnames[i]) ) {
                    errprintf("label %s", r.newnames[i])
                    errprintf("already attached to variables\n")
                    exit(110)
                }
            }
        }
        r.oldexist = (r.oldexist, st_vlexists(r.oldnames[i]))
        l[i].setup(r.oldnames[i])
        l[i].name(r.newnames[i])
    }
}

void rename_return(`Rename' r)
{
    st_rclear()
    if ( cols(r.oldisnew) ) 
        st_global("r(samelblname)", invtokens(r.oldisnew))
    if ( cols(r.newnames) )
        st_global("r(newlblnames)", invtokens(r.newnames))
    if ( cols(r.newnames) )
        st_global("r(oldlblnames)", invtokens(r.oldnames))
}

void rename_dryrun(`Rename' r)
{
    `RS' col, i
    `SS' fmt
    
    if ( !cols(r.oldnames) ) {
        printf("{txt}  (all {it:newlblnames}=={it:oldlblnames})\n")
        return
    }
    
    col = rowmax((strlen(r.oldnames), strlen(r.newnames), 8))+4
    fmt = sprintf("%%%g`ud's", col)
    printf("{txt}{it}\n")
    printf(fmt, "oldlblname")
    printf(" {c |} newlblname{sf}\n")
    printf("  {hline %g}{c +}{hline %g}\n", col-1, col-1)
    for (i=1; i<=cols(r.oldnames); ++i) {
        printf(fmt, r.oldnames[i])
        printf(" {c |} %s\n", r.newnames[i])
    }
    
    if ( !cols(r.oldisnew) ) return
    printf("  {hline %g}{c BT}{hline %g}", col-1, col-1)
    col = cols(r.oldisnew)
    printf("\n  Note: %f value label name%s ", col, ("s"*(col>1)))
    printf("omitted because %s would ", ((col>1) ? "they" : "it"))
    printf("be renamed to %s.\n", ((col>1) ? "themselevs" : "itself"))
}

        // ------------------------------ error messages
void ErrTooMany(`SS' what, `SS' where, | `RS' rc)
{
    errprintf("%s: too many %s\n", where, what)
    exit( ((args()<3) ? 198 : rc) )
}

void ErrNewNames(`SS' fewmany)
{
    errprintf("{it:oldlblname}-{it:newlblname} mismatch\n")
    errprintf("too %s newlblnames specified or implied\n", fewmany)
    exit(198)
}

void ERR(| `SS' where)
{
    errprintf("elabel_cmd_rename: unexpected error %s\n", where)
    exit(42)
}

end
exit

/* ---------------------------------------
1.3.0 27may2020 bug fix: do not set _dta[_lang_*] for one language
                new recase option -title- as synonym for -proper-
                adjust output newname longer than oldname 
1.2.2 08sep2019 corrected typo
1.2.1 02aug2019 bug fix Mata error for rename old old , return 
1.2.0 15jul2019 complete rewrite
                bug fixes Mata errors
1.1.1 24may2019 fix output for dryrun
1.1.0 02apr2019 add recase options {upper|lower|proper}
1.0.1 09feb2019 code polish
1.0.0 02nov2018 first version
