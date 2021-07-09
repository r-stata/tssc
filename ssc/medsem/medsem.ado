*!medsem version 1.0
*!Written 13Apr2016
*!Written by Mehmet Mehmetoglu
capture program drop medsem
program medsem, rclass
version 10
//set trace on
syntax, [indep(string) med(string) dep(string) mcreps(numlist max=1) stand zlc rit rid]

//bk is the default


local moi `med':`indep'
//di "`moi'"
local dom `dep':`med'
//di "`dom'"
local doi `dep':`indep'
//di "`doi'"

if "`stand'" == "" {
qui ereturn list
local nlyvars = wordcount("`e(lyvars)'")
//di in red `nlyvars'
local nlxvars = wordcount("`e(lxvars)'")
//di in red `nlxvars'
tempname numoflatv
scalar `numoflatv' = `nlyvars'+`nlxvars'
//di in red `numoflatv'

mat V = e(V)
//mat list V
mat corrmoidom = V["`moi'","`dom'"]
//mat list corrmoidom
tempname corrmoidom2
scalar `corrmoidom2' = corrmoidom[1,1]
//di in green "The correlation between the coefficients: " `corrmoidom2'  
/*to make the corr value absolute*/
tempname corrmoidom3 corrmoidom4
scalar `corrmoidom3' = `corrmoidom2'^2
//di in red `corrmoidom3'
scalar `corrmoidom4' = sqrt(`corrmoidom3')
//di in red `corrmoidom4'

//UNSTANDARDISED INDIRECT
qui sem
qui return list
mat coef_s_z_pv = r(table) 
//mat list coef_s_z_pv
tempname coef_moi se_moi var_moi
scalar `coef_moi' = _b[`moi']
scalar `se_moi' = _se[`moi']  
scalar `var_moi' = _se[`moi']^2
//di in white "coef_moi: " `coef_moi' 
//di in white "se: " `se_moi'  
//di in white "var: " `var_moi'
tempname coef_dom se_dom var_dom
scalar `coef_dom' = _b[`dom']
scalar `se_dom' = _se[`dom']  
scalar `var_dom' = _se[`dom']^2
//di in white "coef_dom: " `coef_dom' 
//di in white "se: " `se_dom'  
//di in white "var: " `var_dom'
tempname prodterm
scalar `prodterm' = `coef_moi'*`coef_dom'
//di in green "indirect effect: " `prodterm'

//SOBEL METHOD
tempname sobel_se sobel_z sobel_pv 
scalar `sobel_se' = sqrt(((`coef_dom')^2)*`var_moi' + ((`coef_moi')^2)*`var_dom')
scalar `sobel_z' = `prodterm'/`sobel_se'
scalar `sobel_pv' =  2*(1-normal(abs(`sobel_z')))
//di in green "sobel se: " `sobel_se'
//di in green "sobel z: " `sobel_z'
//di in green "sobel p: " %9.3f `sobel_pv' 
tempname sobel_lci sobel_uci
scalar `sobel_lci' = `prodterm' - 1.959964*`sobel_se'
scalar `sobel_uci' = `prodterm' + 1.959964*`sobel_se'
//di "sobel lower ci: " %9.3f `sobel_lci' " and " "sobel upper ci: " %9.3f `sobel_uci'
/*here I use normal theory confidence limits, however according
to MacKinnon on page 97, these may not always be precise, however
in the DELTA METHOD below, it seems like normaly theory limits
are used there as well, that is 1.959964 is used*/

//DELTA METHOD
tempname delta_var delta_se delta_z delta_pv
qui nlcom _b[`moi']*_b[`dom']
//di in white "indirect effect: " `prodterm'
qui return list
mat v = r(V)
//mat list v
scalar `delta_var' = v[1,1]
scalar `delta_se' = sqrt(`delta_var')
//di in white "delta se: "`delta_se'
scalar `delta_z' = `prodterm'/`delta_se'
//di in white "delta_z: " `delta_z'
scalar `delta_pv' =  2*(1-normal(abs(`delta_z')))
//di in white "delta p: " %9.3f `delta_pv'
tempname delta_lci delta_uci
scalar `delta_lci' = `prodterm' - 1.959964*`delta_se'
scalar `delta_uci' = `prodterm' + 1.959964*`delta_se'
//di "delta lower ci: " %9.3f `delta_lci' " and " "delta upper ci: " %9.3f `delta_uci'
//di ""

//MONTE CARLO
qui count
qui return list
local nobs=r(N)
//di `nobs'
if "`mcreps'" =="" { 
tempvar coefx2 coefe2 prodt2
qui set obs `nobs'
qui set seed 456321
mat  me = (_b[`moi'], _b[`dom'])
mat sdt = (_se[`moi'], _se[`dom'])
mat  co = (1, `corrmoidom2' \ `corrmoidom2', 1) 
//mat list co
drawnorm `coefx2' `coefe2', means(me) sds(sdt) corr(co) 
generate `prodt2' = `coefx2'*`coefe2'
_pctile `prodt2', p(2.5 97.5)
qui return list	
qui sum `prodt2'
//return list
tempname montc2_prod montc2_se montc2_z montc2_pv
scalar `montc2_prod' = r(mean)
scalar `montc2_se' = r(sd)
scalar `montc2_z' = `montc2_prod'/`montc2_se'
scalar `montc2_pv' =  2*(1-normal(abs(`montc2_z')))
//di in yellow "Monte carlo indirect effect: " %9.3f `montc2_prod'
//di in yellow "Monte carlo se: " %9.3f `montc2_se'
//di in yellow "Monte carlo z: " %9.3f `montc2_z'
//di in yellow "Monte carlo pv: " %9.3f `montc2_pv'
_pctile `prodt2', p(2.5 97.5)
qui return list
tempname montc2_lci montc2_uci
scalar `montc2_lci' = r(r1)
scalar `montc2_uci' = r(r2)
//di "monte lower ci: " %9.3f `montc2_lci' " and " "monte upper ci: " %9.3f `montc2_uci'               
di ""
di in green "  Significance testing of indirect effect (unstandardised)"                   
di as smcl as txt  "{c TLC}{hline 74}{c TRC}"
display in green "{bf:  Estimates}{dup 10: }{c |}{bf:     Delta}{dup 7: }{c |} {bf:    Sobel}{dup 7: }{c |}{bf:  Monte Carlo}"
di as smcl as txt "{c LT}{hline 74}{c RT}"     
display in yellow "  Indirect effect"_col(22) "{c |} " %9.3f `prodterm' _col(40) "{c |} " %9.3f `prodterm' _col(58) "{c |} " %9.3f `montc2_prod' 
di ""
display in yellow "  Std. Err."_col(22) "{c |} " %9.3f `delta_se' _col(40) "{c |} " %9.3f `sobel_se' _col(58) "{c |} " %9.3f `montc2_se' 
di ""
display in yellow "  z-value"_col(22) "{c |} " %9.3f `delta_z' _col(40) "{c |} " %9.3f `sobel_z' _col(58) "{c |} " %9.3f `montc2_z' 
di ""
display in yellow "  p-value"_col(22) "{c |} " %9.3f `delta_pv' _col(40) "{c |} " %9.3f `sobel_pv' _col(58) "{c |} " %9.3f `montc2_pv' 
di "" 
display in yellow "  Conf. Interval"_col(22) "{c |} " %4.3f `delta_lci' " , " %4.3f `delta_uci' _col(40) "{c |} " %4.3f `sobel_lci' " , " %4.3f `sobel_uci' _col(58) "{c |} " %4.3f `montc2_lci' " , " %4.3f `montc2_uci' 
di as smcl as txt "{c LT}{hline 74}{c RT}"     
}
else {
if `mcreps' >= `nobs' { 
qui set obs `mcreps'
qui set seed 456132
mat  me = (_b[`moi'], _b[`dom'])
mat sdt = (_se[`moi'], _se[`dom'])
mat  co = (1, `corrmoidom2' \ `corrmoidom2', 1) 
//mat list co
tempvar coefx2 coefe2 prodt2
drawnorm `coefx2' `coefe2', means(me) sds(sdt) corr(co) 
generate `prodt2' = `coefx2'*`coefe2'
_pctile `prodt2', p(2.5 97.5)
qui return list	
qui sum `prodt2'
//return list
tempname montc2_prod montc2_se montc2_z montc2_pv
scalar `montc2_prod' = r(mean)
scalar `montc2_se' = r(sd)
scalar `montc2_z' = `montc2_prod'/`montc2_se'
scalar `montc2_pv' =  2*(1-normal(abs(`montc2_z')))
//di in yellow "Monte carlo indirect effect: " %9.3f `montc2_prod'
//di in yellow "Monte carlo se: " %9.3f `montc2_se'
//di in yellow "Monte carlo z: " %9.3f `montc2_z'
//di in yellow "Monte carlo pv: " %9.3f `montc2_pv'
_pctile `prodt2', p(2.5 97.5)
qui return list
tempname montc2_lci montc2_uci
scalar `montc2_lci' = r(r1)
scalar `montc2_uci' = r(r2)
//di "monte lower ci: " %9.3f `montc2_lci' " and " "monte upper ci: " %9.3f `montc2_uci'               
di ""
di in green "  Significance testing of indirect effect (unstandardised)"                   
di as smcl as txt  "{c TLC}{hline 74}{c TRC}"
display in green "{bf:  Estimates}{dup 10: }{c |}{bf:     Delta}{dup 7: }{c |} {bf:    Sobel}{dup 7: }{c |}{bf:  Monte Carlo}"
di as smcl as txt "{c LT}{hline 74}{c RT}"     
display in yellow "  Indirect effect"_col(22) "{c |} " %9.3f `prodterm' _col(40) "{c |} " %9.3f `prodterm' _col(58) "{c |} " %9.3f `montc2_prod' 
di ""
display in yellow "  Std. Err."_col(22) "{c |} " %9.3f `delta_se' _col(40) "{c |} " %9.3f `sobel_se' _col(58) "{c |} " %9.3f `montc2_se' 
di ""
display in yellow "  z-value"_col(22) "{c |} " %9.3f `delta_z' _col(40) "{c |} " %9.3f `sobel_z' _col(58) "{c |} " %9.3f `montc2_z' 
di ""
display in yellow "  p-value"_col(22) "{c |} " %9.3f `delta_pv' _col(40) "{c |} " %9.3f `sobel_pv' _col(58) "{c |} " %9.3f `montc2_pv' 
di "" 
display in yellow "  Conf. Interval"_col(22) "{c |} " %4.3f `delta_lci' " , " %4.3f `delta_uci' _col(40) "{c |} " %4.3f `sobel_lci' " , " %4.3f `sobel_uci' _col(58) "{c |} " %4.3f `montc2_lci' " , " %4.3f `montc2_uci' 
di as smcl as txt "{c LT}{hline 74}{c RT}"     
}
else {
if `mcreps' < `nobs' { 
qui set obs `nobs'
qui set seed 456132
mat  me = (_b[`moi'], _b[`dom'])
mat sdt = (_se[`moi'], _se[`dom'])
mat  co = (1, `corrmoidom2' \ `corrmoidom2', 1) 
//mat list co
tempvar coefx2 coefe2 prodt2
drawnorm `coefx2' `coefe2', means(me) sds(sdt) corr(co) 
generate `prodt2' = `coefx2'*`coefe2'
_pctile `prodt2', p(2.5 97.5)
qui return list	
qui sum `prodt2'
//return list
tempname montc2_prod montc2_se montc2_z montc2_pv
scalar `montc2_prod' = r(mean)
scalar `montc2_se' = r(sd)
scalar `montc2_z' = `montc2_prod'/`montc2_se'
scalar `montc2_pv' =  2*(1-normal(abs(`montc2_z')))
//di in yellow "Monte carlo indirect effect: " %9.3f `montc2_prod'
//di in yellow "Monte carlo se: " %9.3f `montc2_se'
//di in yellow "Monte carlo z: " %9.3f `montc2_z'
//di in yellow "Monte carlo pv: " %9.3f `montc2_pv'
_pctile `prodt2', p(2.5 97.5)
qui return list
tempname montc2_lci montc2_uci
scalar `montc2_lci' = r(r1)
scalar `montc2_uci' = r(r2)
//di "monte lower ci: " %9.3f `montc2_lci' " and " "monte upper ci: " %9.3f `montc2_uci'               
di ""
di in green "  Significance testing of indirect effect (unstandardised)"                   
di as smcl as txt  "{c TLC}{hline 74}{c TRC}"
display in green "{bf:  Estimates}{dup 10: }{c |}{bf:     Delta}{dup 7: }{c |} {bf:    Sobel}{dup 7: }{c |}{bf:  Monte Carlo*}"
di as smcl as txt "{c LT}{hline 74}{c RT}"     
display in yellow "  Indirect effect"_col(22) "{c |} " %9.3f `prodterm' _col(40) "{c |} " %9.3f `prodterm' _col(58) "{c |} " %9.3f `montc2_prod' 
di ""
display in yellow "  Std. Err."_col(22) "{c |} " %9.3f `delta_se' _col(40) "{c |} " %9.3f `sobel_se' _col(58) "{c |} " %9.3f `montc2_se' 
di ""
display in yellow "  z-value"_col(22) "{c |} " %9.3f `delta_z' _col(40) "{c |} " %9.3f `sobel_z' _col(58) "{c |} " %9.3f `montc2_z' 
di ""
display in yellow "  p-value"_col(22) "{c |} " %9.3f `delta_pv' _col(40) "{c |} " %9.3f `sobel_pv' _col(58) "{c |} " %9.3f `montc2_pv' 
di "" 
display in yellow "  Conf. Interval"_col(22) "{c |} " %4.3f `delta_lci' " , " %4.3f `delta_uci' _col(40) "{c |} " %4.3f `sobel_lci' " , " %4.3f `sobel_uci' _col(58) "{c |} " %4.3f `montc2_lci' " , " %4.3f `montc2_uci' 
di as smcl as txt "{c LT}{hline 74}{c RT}"     
di "  *You typed in mcreps < #of obs, your mcreps is however set to #of obs!"
}
}
}
//BARON and KENNY mediation testing 
//adjusted to SEM by Iacobucci et al. 
if "`bk'" == "" {
di ""
qui sem
qui return list
mat coef_s_z_pv = r(table) 
// X -> M
tempname coef_moi moi_pval
mat coef_doi_m = coef_s_z_pv[1,"`moi'"]
//mat list coef_doi_m 
scalar `coef_moi'=coef_doi_m[1,1]
//di %-5.3f `coef_moi'
mat moi_p = coef_s_z_pv[4,"`moi'"]
scalar `moi_pval' = moi_p[1,1]
//di %-5.3f `moi_pval'
// M -> Y
tempname coef_dom dom_pval
mat coef_dom_m = coef_s_z_pv[1,"`dom'"]
scalar `coef_dom'=coef_dom_m[1,1] 
mat dom_p = coef_s_z_pv[4,"`dom'"]
//mat list dom_p
scalar `dom_pval' = dom_p[1,1]
//di in white %-5.3f `dom_pval' 
//di in white %-5.3f `coef_dom'
tempname coef_doi doi_pval
mat coef_doi_m = coef_s_z_pv[1,"`doi'"]
scalar `coef_doi'=coef_doi_m[1,1] 
mat doi_p = coef_s_z_pv[4,"`doi'"]
//mat list doi_p
scalar `doi_pval' = doi_p[1,1]
//di in white %-5.3f `doi_pval' // pval for the direct effect of x on y (c)
//di in white %-5.3f `coef_doi'
di in green "  Baron and Kenny approach to testing mediation"
if `moi_pval' > 0.05 | `dom_pval' > 0.05 {
di in yellow "  STEP 1 - " "`moi'" " (X -> M) with " "B=" %-5.3f `coef_moi' " and " "p=" %-5.3f `moi_pval' 
di in yellow "  STEP 2 - " "`dom'" " (M -> Y) with " "B=" %-5.3f `coef_dom' " and " "p=" %-5.3f `dom_pval' 
di in green "           As either STEP 1 or STEP 2 (or both) are not significant," 
di in green "           there is no mediation!"
}
else {
if `moi_pval' < 0.05 & `dom_pval' < 0.05 & `sobel_pv' < 0.05 & `doi_pval' > 0.05 {
di in yellow "  STEP 1 - " "`moi'" " (X -> M) with " "B=" %-5.3f `coef_moi' " and " "p=" %-5.3f `moi_pval' 
di in yellow "  STEP 2 - " "`dom'" " (M -> Y) with " "B=" %-5.3f `coef_dom' " and " "p=" %-5.3f `dom_pval' 
di in yellow "  STEP 3 - " "`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval'
di in green "           As STEP 1, STEP 2 and the Sobel's test above are significant "   
di in green            "           and STEP 3 is not significant the mediation is complete!" 
}
else {
if `moi_pval' < 0.05 & `dom_pval' < 0.05 & `sobel_pv' < 0.05 & `doi_pval' < 0.05 {
di in yellow "  STEP 1 - " "`moi'" " (X -> M) with " "B=" %-5.3f `coef_moi' " and " "p=" %-5.3f `moi_pval' 
di in yellow "  STEP 2 - " "`dom'" " (M -> Y) with " "B=" %-5.3f `coef_dom' " and " "p=" %-5.3f `dom_pval' 
di in yellow "  STEP 3 - " "`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval'
di in green "           As STEP 1, STEP 2 and STEP 3 as well as the Sobel's test above"   
di in green            "           are significant the mediation is partial!" 
}
else {
if `moi_pval' < 0.05 & `dom_pval' < 0.05 & `sobel_pv' > 0.05 & `doi_pval' < 0.05 {
di in yellow "  STEP 1 - " "`moi'" " (X -> M) with " "B=" %-5.3f `coef_moi' " and " "p=" %-5.3f `moi_pval' 
di in yellow "  STEP 2 - " "`dom'" " (M -> Y) with " "B=" %-5.3f `coef_dom' " and " "p=" %-5.3f `dom_pval' 
di in yellow "  STEP 3 - " "`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval'
di in green "           As STEP 1, STEP 2 and STEP 3 are all significant and the"   
di in green            "           Sobel's test above is not significant the mediation is partial!" 
}
else {
if `moi_pval' < 0.05 & `dom_pval' < 0.05 & `sobel_pv' > 0.05 & `doi_pval' > 0.05 {
di in yellow "  STEP 1 - " "`moi'" " (X -> M) with " "B=" %-5.3f `coef_moi' " and " "p=" %-5.3f `moi_pval' 
di in yellow "  STEP 2 - " "`dom'" " (M -> Y) with " "B=" %-5.3f `coef_dom' " and " "p=" %-5.3f `dom_pval' 
di in yellow "  STEP 3 - " "`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval'
di in green "           As STEP 1 and STEP 2 are significant and neither STEP 3 nor"   
di in green            "           the Sobel's test above is significant the mediation is partial!" 
}
}
}
}
}
}
//ZHAO et al. mediation testing
if "`zlc'" == "zlc" {
di ""
qui sem
qui return list
mat coef_s_z_pv = r(table) 
//mat list coef_s_z_pv
tempname coef_doi doi_pval
mat coef_doi_m = coef_s_z_pv[1,"`doi'"]
scalar `coef_doi'=coef_doi_m[1,1] 
mat doi_p = coef_s_z_pv[4,"`doi'"]
//mat list doi_p
scalar `doi_pval' = doi_p[1,1]
//di in white %-5.3f `doi_pval' // pval for the direct effect of x on y (c)
//di in white %-5.3f `coef_doi'
tempname axbxc 
scalar `axbxc' = `coef_moi'*`coef_dom'*`coef_doi'  // a*b*c
//di in white `axbxc'
di in green "  Zhao, Lynch & Chen's approach to testing mediation"
if `montc2_pv' < 0.05 & `doi_pval' > 0.05 {
di in yellow "  STEP 1 - ""`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval' 
di in green "           As the Monte Carlo test above is significant and STEP 1 is not"  
di in green "           significant you have indirect-only mediation (full mediation)!"
}
else {
if `montc2_pv' > 0.05 & `doi_pval' < 0.05 {
di in yellow "  STEP 1 - ""`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval' 
di in green "           As the Monte Carlo test above is not significant and STEP 1 is"  
di in green "           significant you have direct-only nonmediation (no mediation)!"
}
else {
if `montc2_pv' > 0.05 & `doi_pval' > 0.05 {
di in yellow "  STEP 1 - ""`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval' 
di in green "           As the Monte Carlo test above is not significant and STEP 1 is"  
di in green "           not significant you have no effect nonmediation (no mediation)!"
}
else {
if `montc2_pv' < 0.05 & `doi_pval' < 0.05 & `axbxc' > 0 {
di in yellow "  STEP 1 - ""`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval' 
di in green "           As the Monte Carlo test above is significant, STEP 1 is"  
di in green "           significant and their coefficients point in same direction,"
di in green "           you have complementary mediation (partial mediation)!" 
}
else {
if `montc2_pv' < 0.05 & `doi_pval' < 0.05 & `axbxc' < 0 {
di in yellow "  STEP 1 - ""`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval' 
di in green "           As the Monte Carlo test above is significant, STEP 1 is"  
di in green "           significant and their coefficients point in opposite"
di in green "           direction, you have competitive mediation (partial mediation)!"  
}
}
}
}
}
}
if "`rit'" == "rit" {
di ""
qui sem
qui return list
mat coef_s_z_pv = r(table) 
//mat list coef_s_z_pv
tempname coef_doi doi_pval
mat coef_doi_m = coef_s_z_pv[1,"`doi'"]
scalar `coef_doi'=coef_doi_m[1,1] 
mat doi_p = coef_s_z_pv[4,"`doi'"]
//mat list doi_p
scalar `doi_pval' = doi_p[1,1]
//di in white %-5.3f `doi_pval' // pval for the direct effect of x on y (c)
//di in white %-5.3f `coef_doi'
tempname totef rit
scalar `totef' = `prodterm' + `coef_doi'
//di %-5.3f `totef' 
tempname pr2 tot2 pr3 tot3
scalar `pr2'=`prodterm'*`prodterm'
scalar `pr3'=sqrt(`pr2')
scalar `tot2'=`totef'*`totef'
scalar `tot3'=sqrt(`tot2')
//di `tot3'
scalar `rit' = (`pr3'/`tot3')
di in green "  RIT  =   (Indirect effect / Total effect)"
di in yellow "           " "(" %-5.3f `pr3' " / " %-5.3f `tot3' ")" " = " %-5.3f `rit' 
di in green "           Meaning that about" %3.0f `rit'*100 " % " "of the effect of " "`indep'"
di in green "           " "on " "`dep'" " is mediated by " "`med'" "!" 
if "`rid'" == "rid" {
di ""
tempname coefdoi2
scalar `coefdoi2' = `coef_doi'*`coef_doi'
tempname coefdoi3
scalar `coefdoi3' = sqrt(`coefdoi2')
tempname rid
scalar `rid' = `pr3'/`coefdoi3'
di in green "  RID  =   (Indirect effect / Direct effect)"
di in yellow "           " "(" %-5.3f `pr3' " / " %-5.3f `coefdoi3' ")" " = " %-5.3f `rid' 
di in green "           That is, the mediated effect is about " %3.1f `rid' " times as"
di in green "           large as the direct effect of " "`indep'" " on " "`dep'" "!" 
}
}
}







****************************************************************************************************
**************STANDARDISED VERSION OF MEDSEM STARTING HERE******************************************
****************************************************************************************************
if "`stand'" != "" {
*****************LATENT VARIABLES***************************		
qui ereturn list
local nlyvars = wordcount("`e(lyvars)'")
//di in red `nlyvars'
local nlxvars = wordcount("`e(lxvars)'")
//di in red `nlxvars'
tempname numoflatv
scalar `numoflatv' = `nlyvars'+`nlxvars'
//di in red `numoflatv'

mat V = e(V)
//mat list V
mat corrmoidom = V["`moi'","`dom'"]
//mat list corrmoidom
tempname corrmoidom2
scalar `corrmoidom2' = corrmoidom[1,1]
//di in green "The correlation between the coefficients: " `corrmoidom2'  
/*to make the corr value absolute*/
tempname corrmoidom3 corrmoidom4
scalar `corrmoidom3' = `corrmoidom2'^2
//di in red `corrmoidom3'
scalar `corrmoidom4' = sqrt(`corrmoidom3')
//di in red `corrmoidom4'

//STANDARDISED INDIRECT
qui sem, stand
qui return list
tempname coef_moi se_moi var_moi
mat coef_s_z_pv1 = r(table)
//mat list coef_s_z_pv1
mat coefmat_moi = coef_s_z_pv1[1,"`moi'"]
//mat list coefmat_moi
scalar `coef_moi' = coefmat_moi[1,1]
//di in red `coef_moi'
mat semat_moi = coef_s_z_pv1[2,"`moi'"]
//mat list semat_moi
scalar `se_moi' = semat_moi[1,1]
//di in red `se_moi'
scalar `var_moi' = `se_moi'^2
//di `var_moi'
tempname coef_dom se_dom var_dom
mat coefmat_dom = coef_s_z_pv1[1,"`dom'"]
//mat list coefmat_dom
scalar `coef_dom' = coefmat_dom[1,1]
//di `coef_dom'
mat semat_dom = coef_s_z_pv1[2,"`dom'"]
//mat list semat_dom
scalar `se_dom' = semat_dom[1,1]
//di in red `se_dom'
scalar `var_dom' = `se_dom'^2
//di `var_dom'
tempname prodterm
scalar `prodterm' = `coef_moi'*`coef_dom'
//di in green "indirect effect: " `prodterm'

//SOBEL METHOD
tempname sobel_se sobel_z sobel_pv 
scalar `sobel_se' = sqrt(((`coef_dom')^2)*`var_moi' + ((`coef_moi')^2)*`var_dom')
scalar `sobel_z' = `prodterm'/`sobel_se'
scalar `sobel_pv' =  2*(1-normal(abs(`sobel_z')))
//di in green "sobel se: " `sobel_se'
//di in green "sobel z: " `sobel_z'
//di in green "sobel p: " %9.3f `sobel_pv' 
tempname sobel_lci sobel_uci
scalar `sobel_lci' = `prodterm' - 1.959964*`sobel_se'
scalar `sobel_uci' = `prodterm' + 1.959964*`sobel_se'
//di "sobel lower ci: " %9.3f `sobel_lci' " and " "sobel upper ci: " %9.3f `sobel_uci'
/*here I use normal theory confidence limits, however according
to MacKinnon on page 97, these may not always be precise, however
in the DELTA METHOD below, it seems like normaly theory limits
are used there as well, that is 1.959964 is used*/

//DELTA METHOD
tempname delta_var delta_se delta_z delta_pv
qui estat stdize: nlcom _b[`moi']*_b[`dom']
//di in white "indirect effect: " `coef_moi'*`coef_dom'
qui return list
mat v = r(V)
//mat list v
scalar `delta_var' = v[1,1]
scalar `delta_se' = sqrt(`delta_var')
//di in white "delta se: "`delta_se'
scalar `delta_z' = `prodterm'/`delta_se'
//di in white "delta_z: " `delta_z'
scalar `delta_pv' =  2*(1-normal(abs(`delta_z')))
//di in white "delta p: " %9.3f `delta_pv'
tempname delta_lci delta_uci
scalar `delta_lci' = `prodterm' - 1.959964*`delta_se'
scalar `delta_uci' = `prodterm' + 1.959964*`delta_se'
//di "delta lower ci: " %9.3f `delta_lci' " and " "delta upper ci: " %9.3f `delta_uci'
//di ""

//monte carlo  
qui count
qui return list
local nobs=r(N)
//di `nobs'
if "`mcreps'" =="" { 
tempvar coefx2 coefe2 prodt2
qui set obs `nobs'
qui set seed 456321
mat  me = (`coef_moi', `coef_dom')
mat sdt = (`se_moi', `se_dom')
mat  co = (1, `corrmoidom2' \ `corrmoidom2', 1) 
//mat list co
drawnorm `coefx2' `coefe2', means(me) sds(sdt) corr(co) 
generate `prodt2' = `coefx2'*`coefe2'
_pctile `prodt2', p(2.5 97.5)
qui return list	
qui sum `prodt2'
//return list
tempname montc2_prod montc2_se montc2_z montc2_pv
scalar `montc2_prod' = r(mean)
//di `montc2_prod'
scalar `montc2_se' = r(sd)
scalar `montc2_z' = `montc2_prod'/`montc2_se'
scalar `montc2_pv' =  2*(1-normal(abs(`montc2_z')))
//di in yellow "Monte carlo indirect effect: " %9.3f `montc2_prod'
//di in yellow "Monte carlo se: " %9.3f `montc2_se'
//di in yellow "Monte carlo z: " %9.3f `montc2_z'
//di in yellow "Monte carlo pv: " %9.3f `montc2_pv'
_pctile `prodt2', p(2.5 97.5)
qui return list
tempname montc2_lci montc2_uci
scalar `montc2_lci' = r(r1)
scalar `montc2_uci' = r(r2)
//di "monte lower ci: " %9.3f `montc2_lci' " and " "monte upper ci: " %9.3f `montc2_uci'               
di ""
di in green "  Significance testing of indirect effect (standardised)"                   
di as smcl as txt  "{c TLC}{hline 74}{c TRC}"
display in green "{bf:  Estimates}{dup 10: }{c |}{bf:     Delta}{dup 7: }{c |} {bf:    Sobel}{dup 7: }{c |}{bf:  Monte Carlo}"
di as smcl as txt "{c LT}{hline 74}{c RT}"     
display in yellow "  Indirect effect"_col(22) "{c |} " %9.3f `prodterm' _col(40) "{c |} " %9.3f `prodterm' _col(58) "{c |} " %9.3f `montc2_prod' 
di ""
display in yellow "  Std. Err."_col(22) "{c |} " %9.3f `delta_se' _col(40) "{c |} " %9.3f `sobel_se' _col(58) "{c |} " %9.3f `montc2_se' 
di ""
display in yellow "  z-value"_col(22) "{c |} " %9.3f `delta_z' _col(40) "{c |} " %9.3f `sobel_z' _col(58) "{c |} " %9.3f `montc2_z' 
di ""
display in yellow "  p-value"_col(22) "{c |} " %9.3f `delta_pv' _col(40) "{c |} " %9.3f `sobel_pv' _col(58) "{c |} " %9.3f `montc2_pv' 
di "" 
display in yellow "  Conf. Interval"_col(22) "{c |} " %4.3f `delta_lci' " , " %4.3f `delta_uci' _col(40) "{c |} " %4.3f `sobel_lci' " , " %4.3f `sobel_uci' _col(58) "{c |} " %4.3f `montc2_lci' " , " %4.3f `montc2_uci' 
di as smcl as txt "{c LT}{hline 74}{c RT}"     
}
else {
if `mcreps' >= `nobs' { 
qui set obs `mcreps'
qui set seed 456132
mat  me = (`coef_moi', `coef_dom')
mat sdt = (`se_moi', `se_dom')
mat  co = (1, `corrmoidom2' \ `corrmoidom2', 1) 
//mat list co
tempvar coefx2 coefe2 prodt2
drawnorm `coefx2' `coefe2', means(me) sds(sdt) corr(co) 
generate `prodt2' = `coefx2'*`coefe2'
_pctile `prodt2', p(2.5 97.5)
qui return list	
qui sum `prodt2'
//return list
tempname montc2_prod montc2_se montc2_z montc2_pv
scalar `montc2_prod' = r(mean)
scalar `montc2_se' = r(sd)
scalar `montc2_z' = `montc2_prod'/`montc2_se'
scalar `montc2_pv' =  2*(1-normal(abs(`montc2_z')))
//di in yellow "Monte carlo indirect effect: " %9.3f `montc2_prod'
//di in yellow "Monte carlo se: " %9.3f `montc2_se'
//di in yellow "Monte carlo z: " %9.3f `montc2_z'
//di in yellow "Monte carlo pv: " %9.3f `montc2_pv'
_pctile `prodt2', p(2.5 97.5)
qui return list
tempname montc2_lci montc2_uci
scalar `montc2_lci' = r(r1)
scalar `montc2_uci' = r(r2)
//di "monte lower ci: " %9.3f `montc2_lci' " and " "monte upper ci: " %9.3f `montc2_uci'               
di ""
di in green "  Significance testing of indirect effect (standardised)"                   
di as smcl as txt  "{c TLC}{hline 74}{c TRC}"
display in green "{bf:  Estimates}{dup 10: }{c |}{bf:     Delta}{dup 7: }{c |} {bf:    Sobel}{dup 7: }{c |}{bf:  Monte Carlo}"
di as smcl as txt "{c LT}{hline 74}{c RT}"     
display in yellow "  Indirect effect"_col(22) "{c |} " %9.3f `prodterm' _col(40) "{c |} " %9.3f `prodterm' _col(58) "{c |} " %9.3f `montc2_prod' 
di ""
display in yellow "  Std. Err."_col(22) "{c |} " %9.3f `delta_se' _col(40) "{c |} " %9.3f `sobel_se' _col(58) "{c |} " %9.3f `montc2_se' 
di ""
display in yellow "  z-value"_col(22) "{c |} " %9.3f `delta_z' _col(40) "{c |} " %9.3f `sobel_z' _col(58) "{c |} " %9.3f `montc2_z' 
di ""
display in yellow "  p-value"_col(22) "{c |} " %9.3f `delta_pv' _col(40) "{c |} " %9.3f `sobel_pv' _col(58) "{c |} " %9.3f `montc2_pv' 
di "" 
display in yellow "  Conf. Interval"_col(22) "{c |} " %4.3f `delta_lci' " , " %4.3f `delta_uci' _col(40) "{c |} " %4.3f `sobel_lci' " , " %4.3f `sobel_uci' _col(58) "{c |} " %4.3f `montc2_lci' " , " %4.3f `montc2_uci' 
di as smcl as txt "{c LT}{hline 74}{c RT}"     
}
else {
if `mcreps' < `nobs' { 
qui set obs `nobs'
qui set seed 456132
mat  me = (`coef_moi', `coef_dom')
mat sdt = (`se_moi', `se_dom')
mat  co = (1, `corrmoidom2' \ `corrmoidom2', 1) 
//mat list co
tempvar coefx2 coefe2 prodt2
drawnorm `coefx2' `coefe2', means(me) sds(sdt) corr(co) 
generate `prodt2' = `coefx2'*`coefe2'
_pctile `prodt2', p(2.5 97.5)
qui return list	
qui sum `prodt2'
//return list
tempname montc2_prod montc2_se montc2_z montc2_pv
scalar `montc2_prod' = r(mean)
scalar `montc2_se' = r(sd)
scalar `montc2_z' = `montc2_prod'/`montc2_se'
scalar `montc2_pv' =  2*(1-normal(abs(`montc2_z')))
//di in yellow "Monte carlo indirect effect: " %9.3f `montc2_prod'
//di in yellow "Monte carlo se: " %9.3f `montc2_se'
//di in yellow "Monte carlo z: " %9.3f `montc2_z'
//di in yellow "Monte carlo pv: " %9.3f `montc2_pv'
_pctile `prodt2', p(2.5 97.5)
qui return list
tempname montc2_lci montc2_uci
scalar `montc2_lci' = r(r1)
scalar `montc2_uci' = r(r2)
//di "monte lower ci: " %9.3f `montc2_lci' " and " "monte upper ci: " %9.3f `montc2_uci'               
di ""
di in green "  Significance testing of indirect effect (standardised)"                   
di as smcl as txt  "{c TLC}{hline 74}{c TRC}"
display in green "{bf:  Estimates}{dup 10: }{c |}{bf:     Delta}{dup 7: }{c |} {bf:    Sobel}{dup 7: }{c |}{bf:  Monte Carlo*}"
di as smcl as txt "{c LT}{hline 74}{c RT}"     
display in yellow "  Indirect effect"_col(22) "{c |} " %9.3f `prodterm' _col(40) "{c |} " %9.3f `prodterm' _col(58) "{c |} " %9.3f `montc2_prod' 
di ""
display in yellow "  Std. Err."_col(22) "{c |} " %9.3f `delta_se' _col(40) "{c |} " %9.3f `sobel_se' _col(58) "{c |} " %9.3f `montc2_se' 
di ""
display in yellow "  z-value"_col(22) "{c |} " %9.3f `delta_z' _col(40) "{c |} " %9.3f `sobel_z' _col(58) "{c |} " %9.3f `montc2_z' 
di ""
display in yellow "  p-value"_col(22) "{c |} " %9.3f `delta_pv' _col(40) "{c |} " %9.3f `sobel_pv' _col(58) "{c |} " %9.3f `montc2_pv' 
di "" 
display in yellow "  Conf. Interval"_col(22) "{c |} " %4.3f `delta_lci' " , " %4.3f `delta_uci' _col(40) "{c |} " %4.3f `sobel_lci' " , " %4.3f `sobel_uci' _col(58) "{c |} " %4.3f `montc2_lci' " , " %4.3f `montc2_uci' 
di as smcl as txt "{c LT}{hline 74}{c RT}"     
di "  *You typed in mcreps < #of obs, your mcreps is however set to #of obs!"
}
}
}
//BARON and KENNY mediation testing 
//adjusted to SEM by Iacobucci et al. 
if "`bk'" == "" {
di ""
qui sem,stand
qui return list
mat coef_s_z_pv = r(table) 
// X -> M
tempname coef_moi moi_pval
mat coef_doi_m = coef_s_z_pv[1,"`moi'"]
//mat list coef_doi_m 
scalar `coef_moi'=coef_doi_m[1,1]
//di %-5.3f `coef_moi'
mat moi_p = coef_s_z_pv[4,"`moi'"]
scalar `moi_pval' = moi_p[1,1]
//di %-5.3f `moi_pval'
// M -> Y
tempname coef_dom dom_pval
mat coef_dom_m = coef_s_z_pv[1,"`dom'"]
scalar `coef_dom'=coef_dom_m[1,1] 
mat dom_p = coef_s_z_pv[4,"`dom'"]
//mat list dom_p
scalar `dom_pval' = dom_p[1,1]
//di in white %-5.3f `dom_pval' 
//di in white %-5.3f `coef_dom'
tempname coef_doi doi_pval
mat coef_doi_m = coef_s_z_pv[1,"`doi'"]
scalar `coef_doi'=coef_doi_m[1,1] 
mat doi_p = coef_s_z_pv[4,"`doi'"]
//mat list doi_p
scalar `doi_pval' = doi_p[1,1]
//di in white %-5.3f `doi_pval' // pval for the direct effect of x on y (c)
//di in white %-5.3f `coef_doi'
di in green "  Baron and Kenny approach to testing mediation"
if `moi_pval' > 0.05 | `dom_pval' > 0.05 {
di in yellow "  STEP 1 - " "`moi'" " (X -> M) with " "B=" %-5.3f `coef_moi' " and " "p=" %-5.3f `moi_pval' 
di in yellow "  STEP 2 - " "`dom'" " (M -> Y) with " "B=" %-5.3f `coef_dom' " and " "p=" %-5.3f `dom_pval' 
di in green "           As either STEP 1 or STEP 2 (or both) are not significant," 
di in green "           there is no mediation!"
}
else {
if `moi_pval' < 0.05 & `dom_pval' < 0.05 & `sobel_pv' < 0.05 & `doi_pval' > 0.05 {
di in yellow "  STEP 1 - " "`moi'" " (X -> M) with " "B=" %-5.3f `coef_moi' " and " "p=" %-5.3f `moi_pval' 
di in yellow "  STEP 2 - " "`dom'" " (M -> Y) with " "B=" %-5.3f `coef_dom' " and " "p=" %-5.3f `dom_pval' 
di in yellow "  STEP 3 - " "`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval'
di in green "           As STEP 1, STEP 2 and the Sobel's test above are significant "   
di in green            "           and STEP 3 is not significant the mediation is complete!" 
}
else {
if `moi_pval' < 0.05 & `dom_pval' < 0.05 & `sobel_pv' < 0.05 & `doi_pval' < 0.05 {
di in yellow "  STEP 1 - " "`moi'" " (X -> M) with " "B=" %-5.3f `coef_moi' " and " "p=" %-5.3f `moi_pval' 
di in yellow "  STEP 2 - " "`dom'" " (M -> Y) with " "B=" %-5.3f `coef_dom' " and " "p=" %-5.3f `dom_pval' 
di in yellow "  STEP 3 - " "`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval'
di in green "           As STEP 1, STEP 2 and STEP 3 as well as the Sobel's test above"   
di in green            "           are significant the mediation is partial!" 
}
else {
if `moi_pval' < 0.05 & `dom_pval' < 0.05 & `sobel_pv' > 0.05 & `doi_pval' < 0.05 {
di in yellow "  STEP 1 - " "`moi'" " (X -> M) with " "B=" %-5.3f `coef_moi' " and " "p=" %-5.3f `moi_pval' 
di in yellow "  STEP 2 - " "`dom'" " (M -> Y) with " "B=" %-5.3f `coef_dom' " and " "p=" %-5.3f `dom_pval' 
di in yellow "  STEP 3 - " "`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval'
di in green "           As STEP 1, STEP 2 and STEP 3 are all significant and the"   
di in green            "           Sobel's test above is not significant the mediation is partial!" 
}
else {
if `moi_pval' < 0.05 & `dom_pval' < 0.05 & `sobel_pv' > 0.05 & `doi_pval' > 0.05 {
di in yellow "  STEP 1 - " "`moi'" " (X -> M) with " "B=" %-5.3f `coef_moi' " and " "p=" %-5.3f `moi_pval' 
di in yellow "  STEP 2 - " "`dom'" " (M -> Y) with " "B=" %-5.3f `coef_dom' " and " "p=" %-5.3f `dom_pval' 
di in yellow "  STEP 3 - " "`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval'
di in green "           As STEP 1 and STEP 2 are significant and neither STEP 3 nor"   
di in green            "           the Sobel's test above is significant the mediation is partial!" 
}
}
}
}
}
di ""
}
//ZHAO et al. mediation testing
if "`zlc'" == "zlc" {
di ""
qui sem,stand
qui return list
mat coef_s_z_pv = r(table) 
//mat list coef_s_z_pv
tempname coef_doi doi_pval
mat coef_doi_m = coef_s_z_pv[1,"`doi'"]
scalar `coef_doi'=coef_doi_m[1,1] 
mat doi_p = coef_s_z_pv[4,"`doi'"]
//mat list doi_p
scalar `doi_pval' = doi_p[1,1]
//di in white %-5.3f `doi_pval' // pval for the direct effect of x on y (c)
//di in white %-5.3f `coef_doi'
tempname axbxc 
scalar `axbxc' = `coef_moi'*`coef_dom'*`coef_doi'  // a*b*c
//di in white `axbxc'
di in green "  Zhao, Lynch & Chen's approach to testing mediation"
if `montc2_pv' < 0.05 & `doi_pval' > 0.05 {
di in yellow "  STEP 1 - ""`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval' 
di in green "           As the Monte Carlo test above is significant and STEP 1 is not"  
di in green "           significant you have indirect-only mediation (full mediation)!"
}
else {
if `montc2_pv' > 0.05 & `doi_pval' < 0.05 {
di in yellow "  STEP 1 - ""`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval' 
di in green "           As the Monte Carlo test above is not significant and STEP 1 is"  
di in green "           significant you have direct-only nonmediation (no mediation)!"
}
else {
if `montc2_pv' > 0.05 & `doi_pval' > 0.05 {
di in yellow "  STEP 1 - ""`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval' 
di in green "           As the Monte Carlo test above is not significant and STEP 1 is"  
di in green "           not significant you have no effect nonmediation (no mediation)!"
}
else {
if `montc2_pv' < 0.05 & `doi_pval' < 0.05 & `axbxc' > 0 {
di in yellow "  STEP 1 - ""`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval' 
di in green "           As the Monte Carlo test above is significant, STEP 1 is"  
di in green "           significant and their coefficients point in same direction,"
di in green "           you have complementary mediation (partial mediation)!" 
}
else {
if `montc2_pv' < 0.05 & `doi_pval' < 0.05 & `axbxc' < 0 {
di in yellow "  STEP 1 - ""`doi'" " (X -> Y) with " "B=" %-5.3f `coef_doi' " and " "p=" %-5.3f `doi_pval' 
di in green "           As the Monte Carlo test above is significant, STEP 1 is"  
di in green "           significant and their coefficients point in opposite"
di in green "           direction, you have competitive mediation (partial mediation)!"  
}
}
}
}
}
di ""
}
if "`rit'" == "rit" {
di ""
qui sem,stand
qui return list
mat coef_s_z_pv = r(table) 
//mat list coef_s_z_pv
tempname coef_doi doi_pval
mat coef_doi_m = coef_s_z_pv[1,"`doi'"]
scalar `coef_doi'=coef_doi_m[1,1] 
mat doi_p = coef_s_z_pv[4,"`doi'"]
//mat list doi_p
scalar `doi_pval' = doi_p[1,1]
//di in white %-5.3f `doi_pval' // pval for the direct effect of x on y (c)
//di in white %-5.3f `coef_doi'
tempname totef rit
scalar `totef' = `prodterm' + `coef_doi'
//di %-5.3f `totef' 
tempname pr2 tot2 pr3 tot3
scalar `pr2'=`prodterm'*`prodterm'
scalar `pr3'=sqrt(`pr2')
scalar `tot2'=`totef'*`totef'
scalar `tot3'=sqrt(`tot2')
//di `tot3'
scalar `rit' = (`pr3'/`tot3')
di in green "  RIT  =   (Indirect effect / Total effect)"
di in yellow "           " "(" %-5.3f `pr3' " / " %-5.3f `tot3' ")" " = " %-5.3f `rit' 
di in green "           Meaning that about" %3.0f `rit'*100 " % " "of the effect of " "`indep'"
di in green "           " "on " "`dep'" " is mediated by " "`med'" "!" 
di ""
if "`rid'" == "rid" {
di ""
tempname coefdoi2
scalar `coefdoi2' = `coef_doi'*`coef_doi'
tempname coefdoi3
scalar `coefdoi3' = sqrt(`coefdoi2')
tempname rid
scalar `rid' = `pr3'/`coefdoi3'
di in green "  RID  =   (Indirect effect / Direct effect)"
di in yellow "           " "(" %-5.3f `pr3' " / " %-5.3f `coefdoi3' ")" " = " %-5.3f `rid' 
di in green "           That is, the mediated effect is about " %3.1f `rid' " times as"
di in green "           large as the direct effect of " "`indep'" " on " "`dep'" "!" 
di ""
}
}
}
di as smcl as txt  "{c BLC}{hline 74}{c BRC}"
di in smcl "  Note: to read more about this package" `"{stata "help medsem": help medsem}"'
end










