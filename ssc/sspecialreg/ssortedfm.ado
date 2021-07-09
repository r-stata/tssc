mata: mata clear
cap pro drop _all

*! ssortedfm  cfb B526  from sortedf.ado  SimpleStata2010
*! 1.1.0: rewritten for Mata
*! 1.2.0: Mata routine reworked by Ben Jann
pro def ssortedfm
version 11
syntax varname(numeric) [if], GEN(string)

marksample touse
confirm new var `gen'
qui g double `gen' = . 
mata: sddens_bj("`varlist'", "`gen'", "`touse'")
end

version 11
mata:
// routine rewritten by Ben Jann
void sddens_bj(
    string scalar X,
    string scalar F,
    string scalar touse
    )
{
    real vector u, f, p, sortu, puniq, uniqu, sdd
    real scalar i, en2, ns
    
    st_view(u, ., X, touse)
    st_view(f, ., F, touse)

    // create lookup permutation vector
    p = order(u,1)
    sortu = u[p]
    puniq = J(rows(u),1,1)
    for (i=2;i<=rows(u);i++) {
        puniq[i] = puniq[i-1]
        if (sortu[i-1]!=sortu[i]) puniq[i] = puniq[i] + 1
    }

    // compute sdd
    uniqu = uniqrows(u)
    en2 = 2 / rows(u)
    ns = rows(uniqu)
    sdd = (uniqu[2] - uniqu[1]) \ 
          (uniqu[|3 \ ns|] - uniqu[|1 \ ns-2|]) \ 
          (uniqu[ns] - uniqu[ns-1])
    sdd = en2 :/ sdd
    
    // store results
    f[p] = sdd[puniq]
}
end


