********************************************************************************
*! "pr_pred_cub", v.16, GCerulli, 10apr2020
********************************************************************************
prog pr_pred_cub , eclass
syntax varlist(min=1) [if] [in] [fweight pweight] , prob(name)
local y `varlist' 
tempvar p M R S
********************************************************************************
marksample touse
********************************************************************************
cub informat [`weight'`exp'] if `touse' , pi() xi() vce(oim) // esimates "cub00"
tempvar theta1
predict `theta1' , equation(pi_beta) 
tempvar theta2  
predict `theta2' , equation(xi_gamma)
local m=e(M) // number of categories
********************************************************************************
quietly generate double `p' = 1/(1+exp(-`theta1'))
local c = exp(lnfactorial(`m'-1))
mat cmb = J(`m',1,.)
forv i=1/`m' {
sca d = (exp(lnfactorial(`i'-1))*exp(lnfactorial(`m'-`i')))
mat cmb[`i',1] = `c'/d
}
qui gen double `M' = cmb[`y',1]
quietly generate double `R' = ((exp(-`theta2'))^(`y'-1))/((1+exp(-`theta2'))^(`m'-1))
quietly generate double `S' = 1/`m'
cap gen `prob' = (`p'*(`M'*`R'-`S')+`S')
end 
********************************************************************************

********************************************************************************
*! "gr_prob_cub", v.16, Cerulli, 10apr2020
********************************************************************************
* It produces the graph comparing the actual and the expected (or model)
* probabilities for "cub00"
********************************************************************************
cap program drop gr_prob_cub
program gr_prob_cub , eclass
syntax varlist(min=1) [if] [in] [fweight pweight] , prob(name) ///
[save_graph(string) outname(name) shelter(numlist max=1)]
marksample touse
local y `varlist'
cub `y' [`weight'`exp']  if `touse' ,  pi() xi() vce(oim) shelter(`shelter')
local m=e(M)
tempvar theta1 
predict `theta1' , equation(pi_beta)   
tempvar theta2 
predict `theta2' , equation(xi_gamma) 
********************************************************************************
tempvar p M R S
quietly generate double `p' = 1/(1+exp(-`theta1'))
local c = exp(lnfactorial(`m'-1))
mat cmb = J(`m',1,.)
forv i=1/`m' {
sca d = (exp(lnfactorial(`i'-1))*exp(lnfactorial(`m'-`i')))
mat cmb[`i',1] = `c'/d
}
qui gen double `M' = cmb[`y',1]
quietly generate double `R' = ((exp(-`theta2'))^(`y'-1))/((1+exp(-`theta2'))^(`m'-1))
quietly generate double `S' = 1/`m'
cap gen `prob' = (`p'*(`M'*`R'-`S')+`S')
********************************************************************************
preserve
contract `prob'
tempvar tot
egen `tot' = total(_freq) 
tempvar prob_real
cap gen `prob_real'=_freq/`tot'
gen _id=_n
la var `prob' "Expected probabilities"
la var `prob_real' "Actual probabilities"
set scheme s1mono
********************************************************************************
if ("`outname'"=="" & "`shelter'"==""){
tw (connected `prob' _id , xtitle("") xlabel(1(1)`m')) ///
(connected `prob_real' _id) , note("Outcome = `y'" "Shelter = Not specified") ///
name(gr_pred , replace) saving(`save_graph',replace)
}
if ("`outname'"=="" & "`shelter'"!=""){
tw (connected `prob' _id , xtitle("") xlabel(1(1)`m')) ///
(connected `prob_real' _id) , note("Outcome = `y'" "Shelter = `shelter'") ///
name(gr_pred , replace) saving(`save_graph',replace)
}
if ("`outname'"!="" & "`shelter'"==""){
tw (connected `prob' _id , xtitle("") xlabel(1(1)`m')) ///
(connected `prob_real' _id) , note("Outcome = `outname'" "Shelter = Not specified") ///
name(gr_pred , replace) saving(`save_graph',replace)
}
else if ("`outname'"!="" & "`shelter'"!=""){
tw (connected `prob' _id , xtitle("") xlabel(1(1)`m')) ///
(connected `prob_real' _id) , note("Outcome = `outname'" "Shelter = `shelter'") ///
name(gr_pred , replace) saving(`save_graph',replace)
}
restore
********************************************************************************
end
********************************************************************************
