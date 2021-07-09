program imbalance, rclass
*! 1.0.0 Shenyang Guo 15May2009
  version 8.2
preserve
use "`1'", clear

//dx
collapse (mean) m_x=`2' (sd) sd_x=`2', by(`3')
gen mxt=m_x if `3'==1
gen mxc=m_x[_n-1] if `3'==1
gen s2xt=sd_x*sd_x if `3'==1
gen s2xc=(sd_x[_n-1])*(sd_x[_n-1]) if `3'==1
gen sx=sqrt((s2xt+s2xc)/2) if `3'==1
drop if `3'==0
gen dx=abs(mxt-mxc)/sx
keep dx sx
gen i=_n
sort i
tempfile d1
save `d1', replace

//dxm
use "`1'", clear
collapse (mean) m_x=`2' (sd) sd_x=`2' (count) n=`2', by(`4' `3')
quietly: sum m_x if `3'==0
//Mxc=r(mean) from the above summarize
gen mxc=r(mean)
quietly: sum m_x if `3'==1
gen mxt=r(mean)
gen dxm_num=abs(mxt-mxc)
keep dxm_num
drop if _n>1
gen i=1
sort i
merge i using `d1'
drop _merge
gen dxm=dxm_num/sx
gen name="`2'_`4'"
keep name dx dxm
save `5', replace
list
return scalar dx=dx
return scalar dxm=dxm
return local var_mset=name
restore
end

