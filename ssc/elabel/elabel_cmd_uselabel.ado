*! version 1.0.0 15jul2019 daniel klein
program elabel_cmd_uselabel
    version 11.2
    
    if (c(stata_version) >= 16) local f f
    elabel parse [ elblnamelist ] [ if`f' ] [ , CLEAR ] : `0'
    
    if ( c(changed) & ("`clear'"!="clear") ) error 4
    gettoken iffword iff : if`f'
    
    preserve
    mata : elabel_cmd_uselabel()
    if ( c(N) ) quietly compress
    restore , not
end

version 11.2

mata :

mata set matastrict on

void elabel_cmd_uselabel()
{
    string       rowvector lblnames
    real         matrix    val
    string       matrix    txt
    real         scalar    i, k
    transmorphic scalar    vl
    real         colvector len
    string       rowvector strtype

    if ( !cols((lblnames=auniq(tokens(st_local("lblnamelist"))))) )
        lblnames = elabel_dir()'
    
    val = .
    txt = J(1, 2, "")

    for (i=1; i<=cols(lblnames); ++i) {
        vl = elabel_vlinit(lblnames[i])
        elabel_vlmarkiff(vl, st_local("iff"))
        if ( !(k=elabel_vlk(vl)) ) continue
        val = (val\ elabel_vlvalues(vl))
        txt = (txt\ (J(k, 1, lblnames[i]), elabel_vllabels(vl)) )
    }
    
    stata("clear")
    
    if ( !(rows(val)-1) ) {
        printf("{txt}no value labels found\n{sf}")
        return
    }
    
    val = val[(2::rows(val))]
    txt = txt[(2::rows(txt)), ]
    
    if (stataversion() < 1300) {
        val     = (val, ((len=strlen(txt[, 2])):>244))
        strtype = sprintf("str%f", min((max(len), 244)))
    }
    else {
        val     = (val, J(rows(val), 1, 0))
        if ( (len=max(strlen(txt[, 2]))) > 2045 ) strtype = "strL"
        else                       strtype = sprintf("str%f", len)
    }
    strtype = (sprintf("str%f", max(strlen(txt[, 1]))), strtype)
    
    st_addobs(rows(val))
    (void) st_addvar( (strtype[1], "long", strtype[2], "byte"), 
                      ("lname", "value", "label", "trunc") )
    st_sstore(., (1, 3), txt)
    st_store(., (2, 4), val)
}

end
exit
