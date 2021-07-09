program hodgesl, rclass
*! 1.0.0 Shenyang Guo 15May2009
 version 8.2
preserve
set seed 1000
use "`1'", clear
drop if `3'=="NA"
tempfile renamed_file
save `renamed_file', replace
collapse (mean) m_y=`2', by(`3')
sort `3'
tempfile r1
save `r1', replace

use `renamed_file', clear
collapse (mean) mean_y=`2' (count) n=`2', by(`3' `4')
quietly: sum n
gen mean_diff=((n+n[_n-1])/r(sum))*(mean_y-mean_y[_n-1]) if `4'==1
quietly: sum mean_diff
gen tx_effect=r(sum)
gen i=_n
sort i
drop if i>1
keep tx_effect i
tempfile r2
save `r2', replace

use `renamed_file', clear
collapse (mean) mean_y=`2' (count) n=`2', by(`3' `4')
keep `3' `4' mean_y n
save `5', replace

use `renamed_file', clear
collapse (count) m_or_n=`2', by(`3' `4')
sort `3' `4'
gen mi=m_or_n if `4'==0
replace mi=. if `4'==1
gen ni=m_or_n if `4'==1
replace ni=. if `4'==0
gen Ni=ni+mi[_n-1]
replace mi=mi[_n-1] if mi==.
drop if Ni==.
gen factor=(mi*ni)/(Ni*(Ni-1))
keep `3' factor
sort `3'
tempfile r3
save `r3', replace

use `renamed_file', clear
sort `3'
merge `3' using `r1'
gen dy=`2'-m_y
sort dy
gen rk=_n
sort `3'
drop _merge
tempfile r4
save `r4', replace
use `r4', clear
drop if `4'==0
collapse (sum) wsi=rk, by(`3')
tempfile r4a
save `r4a', replace
use `r4', clear
collapse (mean) ki_=rk, by(`3')
tempfile r5
save `r5', replace
use `r4', clear
drop if `4'==0
collapse (count) ni=`4', by(`3')
sort `3'
merge `3' using `r5'
gen E_wsi=ni*ki_
drop _merge
sort `3'
tempfile r6
save `r6', replace

use `r4', clear
sort `3'
merge `3' using `r5'
gen k=(rk-ki_)^2
collapse (sum) ss_kd_i=k, by (`3')
sort `3'
tempfile r7
save `r7', replace

use `r3', clear
sort `3'
merge `3' using `r7' `r6' `r4a'
gen var_wsi=factor*ss_kd_i
quietly: sum var_wsi
gen var=r(sum) 
quietly: sum E_wsi
gen sum_Ewsi=r(sum)
quietly: sum wsi
gen ws=r(sum) 
gen HL_mean=ws-sum_Ewsi
gen HL_se=sqrt(var)
gen z=HL_mean/HL_se
gen p=1-normal(abs(z))
keep HL_mean HL_se z p
format p %9.3f
drop if _n>1
gen i=_n
sort i
merge i using `r2'
gen set_name="`3'"
list set_name tx_effect HL_mean HL_se z p
return scalar tx_effect=tx_effect
return scalar p=p
return scalar z=z
return local DV_mset="`2'_`3'"
restore
end
