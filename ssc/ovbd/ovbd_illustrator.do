*! ovbd_illustrator.do Version 1.0 2007-02-27 JRC
clear
set more off
set seed `=date("2007-02-27", "ymd")'
*
* Constant means (50%) and correlation coefficient (50%)
*
matrix define M = J(1, 10, 0.5)
matrix define C = J(10, 10, 0.5)
forvalues i = 1/10 {
    matrix define C[`i', `i'] = 1 // Not especially necessary. -ovbd- ignores the diagonals
}
ovbd , stub(rsp) means(M) corr(C) n(250) clear
summarize rsp*, separator(0)
pwcorr rsp*
tetrachoric rsp* // Compare rho from -xtprobit-
generate int pid = _n
quietly reshape long rsp, i(pid) j(tim)
xtgee rsp tim, i(pid) t(tim) family(binomial) link(logit) corr(unstructured) nolog
xtcorr
xtgee rsp tim, i(pid) t(tim) family(binomial) link(logit) corr(exchangeable) nolog
xtcorr, compact
xtlogit rsp tim, i(pid) re intmethod(aghermite) intpoints(30) nolog
*
* Same mean vector, but 25% compound symmetric correlation matrix
*
matrix define C = J(10, 10, 0.25)
forvalues i = 1/10 {
    matrix define C[`i', `i'] = 1
}
ovbd , stub(rsp) means(M) corr(C) n(250) clear
summarize rsp*, separator(0)
pwcorr rsp*
tetrachoric rsp*
generate int pid = _n
quietly reshape long rsp, i(pid) j(tim)
xtgee rsp tim, i(pid) t(tim) family(binomial) link(logit) corr(unstructured) nolog
xtcorr
xtgee rsp tim, i(pid) t(tim) family(binomial) link(logit) corr(exchangeable) nolog
xtcorr, compact
xtlogit rsp tim, i(pid) re intmethod(aghermite) intpoints(30) nolog
*
* Varying means with 50% constant correlation coefficient
*
matrix define M = J(1, 10, 0.5)
forvalues i = 1/10 {
    matrix define M[1,`i'] = M[1,`i'] - (`i' - 5) / 30
}
matrix list M
matrix define C = J(10, 10, 0.5)
forvalues i = 1/10 {
    matrix define C[`i', `i'] = 1
}
ovbd , stub(rsp) means(M) corr(C) n(250) clear
summarize rsp*, separator(0)
pwcorr rsp*
tetrachoric rsp*
generate int pid = _n
quietly reshape long rsp, i(pid) j(tim)
xtgee rsp tim, i(pid) t(tim) family(binomial) link(logit) corr(unstructured) nolog
xtcorr
xtgee rsp tim, i(pid) t(tim) family(binomial) link(logit) corr(exchangeable) nolog
xtcorr, compact
xtlogit rsp tim, i(pid) re intmethod(aghermite) intpoints(30) nolog
*
* Varying means and first-order autoregresive correlation coefficient (75%)
*
matrix define C = J(10, 10, 0.75)
forvalues i = 2/10 {
    forvalues j = 1/`=`i'-1' {
        matrix define C[`i',`j'] = C[`i',`j']^abs(`i' - `j')
        matrix define C[`j',`i'] = C[`i',`j']
    }
}
forvalues i = 1/10 {
    matrix define C[`i', `i'] = 1
}
matrix list C
ovbd , stub(rsp) means(M) corr(C) n(250) clear
summarize rsp*, separator(0)
pwcorr rsp*
tetrachoric rsp* // This the luck of the draw, but beware:  option -forcepsd- not used in call to -drawnorm-
generate int pid = _n
quietly reshape long rsp, i(pid) j(tim)
xtgee rsp tim, i(pid) t(tim) family(binomial) link(logit) corr(unstructured) nolog
xtcorr
xtgee rsp tim, i(pid) t(tim) family(binomial) link(logit) corr(ar 1) nolog
xtcorr, compact
*
* Underdispersion
*
matrix define M = J(1, 2, 0.5)
matrix define C = J(2, 2, -0.5)
forvalues i = 1/2 {
    matrix define C[`i', `i'] = 1
}
ovbd , stub(rsp) means(M) corr(C) n(250) clear
summarize rsp*, separator(0)
pwcorr rsp*
tetrachoric rsp*
exit
