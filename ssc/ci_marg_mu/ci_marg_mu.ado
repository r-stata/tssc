program define ci_marg_mu
*! version 1.3 SRH 18 Oct 2008
version 10.0
syntax newvarlist(min=2 max=2) [if] [in] [, DOTS Level(int $S_level) Reps(int 1000)]
    if "`e(cmd)'" != "gllamm" {
          di in red  "gllamm was not the last command"
          error 301
    }

    local n200 = `reps'/200
    if floor(`n200')<`reps'/200{
        disp in re "reps must be a multiple of 200"
        exit 198
    }
    tempname p b v bc vc T a cholv
    tempvar idno
    gen long `idno' = _n
    
    /* number of observation in tails */
    local extreme = `n200'*(200-2*`level')

    timer clear 6
    timer on 6

    /* deal with if and in */
    tempvar touse
    mark `touse' `if' `in'
    preserve
    qui keep if `touse'

    /* deal with estimates and constraints*/
    matrix `b'=e(b)
    matrix `v'=e(V)
    if `e(const)'==1{
        matrix `T'=e(T)
        matrix `a'=e(a)
    }
    else{
        matrix `T'=I(colsof(`b'))
        matrix `a'=J(1,colsof(`b'),0)
    }
    matrix `vc' = `T''*`v'*`T'
    matrix `cholv' = cholesky(`vc')
    matrix `bc' = (`b'-`a')*`T'

    local vlist
    forvalues i=1/`extreme' {
        tempvar pm`i'
        local vlist `vlist' `pm`i''
        mata: mf_sample_p()
        qui gllapred `pm`i'' if `touse', mu marg fsample from(`p')
        if "`dots'"!="" noi di in gr "." _c
    }
    if "`dots'"!="" noi disp " "
    timer off 6
    quietly timer list 6
    if "`dots'"!="" noi disp in gr r(t6) " seconds = " r(t6)/60 " minutes = " r(t6)/3600 " hours"

    if "`dots'"!="" noi disp " "

    timer clear 6
    timer on 6
    local extremep = `extreme' + 1
    forvalues j=`extremep'/`reps'{
        tempvar new
        mata: mf_sample_p()
        qui gllapred `new' if `touse', mu marg fsample from(`p')
        if "`dots'"!="" noi di in gr "." _c

        mata: rowshuffle(`extreme',"`touse'","`vlist' `new'")

        drop `new'
    }

    if "`dots'"!="" noi disp " "
    timer off 6
    quietly timer list 6
    if "`dots'"!="" noi disp in gr r(t6) " seconds = " r(t6)/60 " minutes = " r(t6)/3600 " hours"

    tokenize `varlist'
    local y "`1'"
    
    local lhalf = `extreme'/2
    local uhalf = `lhalf' + 1

    rename `pm`lhalf'' `1'
    rename `pm`uhalf'' `2'

    local lp = round((100-`level')/2,.1)
    local up = round(100-`lp',.1)
    label var `1' "`lp' percentile for gllapred, mu marg "
    label var `2' "`up' percentile for gllapred, mu marg "
 
    /* restore data */
    tempfile file
    qui keep `idno' `1' `2'
    sort `idno'
    qui save "`file'", replace
    restore
    tempvar mrge
    sort `idno'
    qui merge `idno' using "`file'", _merge(`mrge')
end

version 10.0
mata:
void rowshuffle(numeric scalar num, string scalar touse, string scalar varlist)
{
    veclabs = tokens(varlist)
    // veclabs

    st_view(V,.,veclabs,touse)


    // sort rows and delete 26th element

    uptoi = num/2
    fromi = uptoi + 2
    nump = num + 1 
    for (i=1;i<=rows(V);i++){
        newrow=sort(V[i,]',1)'
        newrow=newrow[1..uptoi],newrow[fromi..nump]
        V[i,1..num]=newrow
    }
}

void mf_sample_p()
{
    cholV = st_matrix(st_local("cholv"))
    p = st_matrix(st_local("bc")) + (cholV * rnormal(cols(cholV), 1, 0, 1))'
    p = p*st_matrix(st_local("T"))' + st_matrix(st_local("a"))
    st_matrix(st_local("p"),p )
}
end
