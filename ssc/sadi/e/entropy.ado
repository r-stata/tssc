*Version  January 2019
program drop _all
program define entropy
version 12
syntax varlist(max=1) [, alpha(real 0) gen by(varlist)] 

marksample touse

local alpha2 : display round(`alpha', .001)

if `alpha' >999 {
display as error "Alpha value not too large"
                exit 198
                    }
if `alpha' <0 {
display as error "Negative alpha value not allowed"
                exit 198
                    }
					
					
tempvar pi logvalue piq piq_sum h hc1 dis shannon renyi hill hct

scalar q=round(`alpha', .001)
scalar one_q =1/(1-q)
scalar q_one =(q-1)^-1
qui egen `pi'=pc(`varlist'), prop by(`by')

*Shannon (1948) - summation_i (pi* logpi)
qui gen `logvalue'=`pi'*log(`pi')
qui egen `shannon'=sum((`logvalue')*-1), by(`by')
qui label var `shannon' "Shannon"

*Rényi-Entropy (1961)
qui gen `piq'=`pi'^q
qui egen `piq_sum'=sum(`piq'), by(`by')
qui gen `renyi'=ln(`piq_sum')*one_q
qui label var `renyi' "Renyi(q=`alpha2')"

*Hill Numbers =[summation_i(p^q)]^ {1/(1-q)} Hill (1973)
qui egen `h'=sum(`piq'), by(`by')
qui gen `hill'=`h'^one_q
qui label var `hill' "Hills(q=`alpha2')"

*HCT = (q-1)^-1 *[1-summation_i(p^q)  Havrda and Charvát (1967); Tsallis (1988)
qui gen `hc1'=1-`h'
qui gen `hct'=`hc1'*q_one
qui label var `hct' "HCT(q=`alpha2')"

qui capture gen `dis'=`by'
capture if _rc!=. {
capture label values `dis' `: value label `by''
lab var `dis' `by'
}
qui capture gen `dis'="Overall"
qui capture label var `dis' "Group"

qui replace `renyi'=`shannon' if `alpha2'==1 & `renyi'==.
qui replace `hct'=`shannon' if `alpha2'==1 & `hct'==.
qui replace `hill'=exp(`shannon') if `alpha2'==1 & `hill'==.

di in gr " "
di in ye "Shannon, Renyi, Havrda/Tsallis(HCT), Hill Numbers"
tabdisp `dis', cell(`shannon' `renyi' `hct' `hill') format(%4.3f)
di in w "Renyi, Havrda/Tsallis & Hill Numbers parameterized for alpha(" (q) ")"

if "`gen'"=="gen" { 
rename (`shannon' `renyi' `hct' `hill') (`varlist'_shannon `varlist'_renyi `varlist'_hct `varlist'_hill )
label var `varlist'_shannon "Shannon entropy"
label var `varlist'_renyi "Renyi entropy (q=`alpha')"
label var `varlist'_hct "Havrda, Charvat & Tsallis entropy (q=`alpha')"
label var `varlist'_hill "Hill Numbers (q=`alpha')"
}

scalar drop _all

end
