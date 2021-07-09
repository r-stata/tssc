*! version 1.2.1 14nov2019 daniel klein
program elabel_cmd_compare // , rclass
    version 11.2
    
    if (_caller() >= 16) local f f
    elabel parse elblnamelist [ if`f' ] [ , ASSERTIDENTICAL ] : `0'
    
    tokenize `lblnamelist'
    if (("`2'"=="") | ("`3'"!="")) {
        local fewmany = cond("`2'"=="", "few", "many")
        display as err "too `fewmany' names specified"
        exit 198
    }
    
    gettoken ifword iff : if`f'
    
    mata : elabel_cmd_compare()
end

version 11.2

if (c(stata_version)>=14) local ud ud

local TS transmorphic                scalar
local SR string                      rowvector
local RC real                        colvector
local RR real                        rowvector
local RS real                        scalar
local SS string                      scalar
local EC struct elabel_cmd_compare__ rowvector

mata :

mata set matastrict on

struct elabel_cmd_compare__ 
{
    `TS' vl
    `SR' maps
    `RC' tag
}

void elabel_cmd_compare()
{
    `EC' ec
    
    ec = elabel_cmd_compare__(2)
    elabel_cmd_compare_load(ec)
    
    elabel_cmd_compare_assert(ec)
    
    elabel_cmd_compare_stats(ec)
    if (ec[1].maps!=ec[2].maps) {
        elabel_cmd_compare_diffs(ec[1], ec[2])
        elabel_cmd_compare_diffs(ec[2], ec[1])
        elabel_cmd_compare_joint(ec)
    }
    else {
        printf("{txt}  value labels {res}%s{txt}" , elabel_vlname(ec[1].vl))
        printf(" and {res}%s{txt} are identical\n", elabel_vlname(ec[2].vl))
    }
    
    elabel_cmd_compare_return(ec)
}

void elabel_cmd_compare_load(`EC' ec)
{
    `RS' i
    for (i=1; i<=2; ++i) {
        ec[i].vl = elabel_vlinit(st_local(strofreal(i)))
        elabel_vlmarkif(ec[i].vl, st_local("iff"))
        ec[i].maps = (strofreal(elabel_vlvalues(ec[i].vl)) +
                                elabel_vllabels(ec[i].vl))'
    }
}

void elabel_cmd_compare_assert(`EC' ec)
{
    if (st_local("assertidentical") == "") return
    st_rclear()
    st_global("r(name1)", elabel_vlname(ec[1].vl))
    st_global("r(name2)", elabel_vlname(ec[2].vl))
    st_numscalar("r(identical)", (ec[1].maps==ec[2].maps))
    if (ec[1].maps==ec[2].maps) exit(0) // NotReached
    errprintf("value labels {bf}%s{sf} and ", elabel_vlname(ec[1].vl))
    errprintf("{bf}%s{sf} are not identical\n", elabel_vlname(ec[2].vl))
    exit(9)
}

void elabel_cmd_compare_stats(`EC' ec)
{
    `RR' len
    `RS' col
    `SS' fmt
    
    len = (max((6, `ud'strlen(elabel_vlname(ec[1].vl)))),
           max((6, `ud'strlen(elabel_vlname(ec[2].vl)))))
    col = rowsum(len)+3
    fmt = sprintf("%%%fs%%%fs", (len[1]+1), (len[2]+2))
    
    printf("\n{txt}  {hline 10}{c TT}{hline %f}", col)
    printf("\n{col 13}{c |}")
    printf(fmt, elabel_vlname(ec[1].vl), elabel_vlname(ec[2].vl))
    printf("\n{txt}  {hline 10}{c +}{hline %f}", col)
    printf("\n{txt}{col 9}min {c |}{res}")
    printf(fmt, strofreal(min(elabel_vlvalues(ec[1].vl))),
                strofreal(min(elabel_vlvalues(ec[2].vl))))
    printf("\n{txt}{col 9}max {c |}{res}")
    printf(fmt, strofreal(max(elabel_vlvalues(ec[1].vl))), 
                strofreal(max(elabel_vlvalues(ec[2].vl))))
    printf("\n{txt}{col 5}missing {c |}{res}")
    printf(fmt, strofreal(elabel_vlnemiss(ec[1].vl)),
                strofreal(elabel_vlnemiss(ec[2].vl)))
    printf("\n{txt}{col 11}k {c |}{res}")
    printf(fmt, strofreal(elabel_vlk(ec[1].vl)), 
                strofreal(elabel_vlk(ec[2].vl)))
    printf("\n{txt}  {hline 10}{c BT}{hline %f}\n", col)
}

void elabel_cmd_compare_diffs(`EC' a, `EC' b)
{
    `TS' avl
    
    if (!any(a.tag=(!_aandb(a.maps, b.maps))')) return
    
    printf("\n{txt}  only defined in {res}%s{txt}\n", elabel_vlname(a.vl))
    pragma unset avl
    elabel_vlcopy(a.vl, avl)
    elabel_vlmark(avl, a.tag)
    elabel_vllistmappings(avl)
}

void elabel_cmd_compare_joint(`EC' ec)
{
    `TS' vl
    
    if (!any(!ec[1].tag)) return
    
    printf("\n{txt}  defined in both {res}%s{txt} and {res}%s{txt}\n", 
                   elabel_vlname(ec[1].vl), elabel_vlname(ec[2].vl))
    pragma unset vl
    elabel_vlcopy(ec[1].vl, vl)
    elabel_vlmark(vl, !ec[1].tag)
    elabel_vllistmappings(vl)
}

void elabel_cmd_compare_return(`EC' ec)
{
    `TS' vl
    `SS' v, t
    `RS' k, i
    
    pragma unset vl
    pragma unset v
    pragma unset t
    
    st_rclear()
    if ((ec[1].maps==ec[2].maps) | (any(!ec[1].tag))) {
        elabel_vlcopy(ec[1].vl, vl)
        if (any(!ec[1].tag)) elabel_vlmark(vl, !ec[1].tag)
        elabel_vllist(vl, v, t, 0)
        k = elabel_vlk(vl)
        st_global("r(labels)", t)
        st_global("r(values)", v)
    }
    for (i=1; i<=2; ++i) {
        st_numscalar(sprintf("r(min%f)", i), min(elabel_vlvalues(ec[i].vl)))
        st_numscalar(sprintf("r(max%f)", i), max(elabel_vlvalues(ec[i].vl)))
        st_numscalar(sprintf("r(nemiss%f)", i), elabel_vlnemiss(ec[i].vl))
        st_numscalar(sprintf("r(k%f)", i), elabel_vlk(ec[i].vl))
        st_global(sprintf("r(name%f)", i), elabel_vlname(ec[i].vl))
        if (!any(ec[i].tag)) continue
        elabel_vlcopy(ec[i].vl, vl)
        elabel_vlmark(vl, ec[i].tag)
        elabel_vllist(vl, v, t, 0)
        st_global(sprintf("r(labels%f)", i), t)
        st_global(sprintf("r(values%f)", i), v)
    }
    st_numscalar("r(k)", (missing(k) ? 0 : k))
    st_numscalar("r(identical)", (ec[1].maps==ec[2].maps))
}

end
exit

/* ---------------------------------------
1.2.1 14nov2019 use new vl.listmappings()
1.2.0 23oct2019 new option -assertidentical-
1.1.1 15jul2019 respect matastrict setting
1.1.0 03jun2019 use -iff- in place of -if-
1.0.1 24may2019 allow identical label names
1.0.0 09feb2019 first version
