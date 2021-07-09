*! ivreg2hdfe v1.0.0 | Dany Bahar | dbaharc@gmail.com | 15May2014

cap prog drop ivreg2hdfe
program ivreg2hdfe, eclass
// program reg2hdfe, eclass
version 10.1

syntax [if], DEpvar(varname num) ENdog(varlist num) iv(varlist num) [EXog(varlist num)] id1(varname max=1) id2(varname max=1) [cluster(varname max=1)] [gmm2s]
marksample touse
tmpdir returns r(tmpdir):
local tdir  `r(tmpdir)'

qui cd "`tdir'"
local tempfiles : dir . files "*.dta"
foreach f in `tempfiles' {
	erase `f'
}

preserve

if "`if'"~="" {
	qui keep `if' 
}

bys `id1':gen NN=_N
qui drop if NN==1
drop NN

tempvar clustervar ctrans
if "`cluster'"~="" {
	capture confirm string variable `cluster'
    if !_rc {
    	gen `ctrans' = `cluster'
    	capture encode `ctrans', g(`clustervar')
	}
	else {
		gen double `clustervar'=`cluster'
	}
	qui reg2hdfe `depvar' `endog' `exog' `iv',  id1(`id1') id2(`id2') cluster(`clustervar') out("`tdir'") noregress 
	}
else {
	qui reg2hdfe `depvar' `endog' `exog' `iv',  id1(`id1') id2(`id2') out("`tdir'") noregress 
}


/* From reg2hdfe.ado */
tempfile tmp1 tmp2 tmp3 readdata
quietly {
	use _ids, clear
	sort __uid
	qui save "`tmp1'", replace
	if "`cluster'"!="" {
		merge __uid using _clustervar
		if r(min)<r(max) { 
			di "Fatal Error"
			error 198
		}
		drop _merge
		sort __uid
		rename __clustervar `clustervar'
		qui save "`tmp1'", replace
		}
	

* Now read the original variables
	foreach var in `depvar' `endog' `exog' `iv' {
		merge __uid using _`var'
		sum _merge, meanonly
		if r(min)<r(max) { 
			di "Fatal Error"
			error 198
		}
		drop _merge
		drop __fe2*
		drop __t_*
		sort __uid
		qui save "`tmp2'", replace
	}
	foreach var in `depvar' `endog' `exog' `iv' {
		rename __o_`var' `var'
	}
	sum `depvar', meanonly
	tempvar yy sy
	gen double `yy'=(`depvar'-r(mean))^2
	gen double `sy'=sum(`yy')
	local tss=`sy'[_N]
	drop `yy' `sy'
	qui save "`readdata'", replace
	use `tmp1', clear
	foreach var in `depvar' `endog' `exog' `iv'  {
		merge __uid using _`var'
		sum _merge, meanonly
		if r(min)<r(max) { 
			di "Fatal Error."
			error 198
		}
		drop _merge
		drop __fe2*
		drop __o_*
		sort __uid
		qui save "`tmp3'", replace
	}
        
	foreach var in `depvar' `endog' `exog' `iv' {
		rename __t_`var' `var'
	}
}   

* Create group variable
tempvar group
qui makegps, id1(`id1') id2(`id2') groupid(`group')

* Calculate Degrees of Freedom	
qui count
local N = r(N)
local k : word count `endog' `exog' `iv' //Check whether here I need also the instruments or not
sort `id1'
qui count if `id1'!=`id1'[_n-1]
local G1 = r(N)
sort `id2'
qui count if `id2'!=`id2'[_n-1]
local G2 = r(N)
sort `group'
qui count if `group'!=`group'[_n-1]
local M = r(N)
local kk = `k' + `G1' + `G2' - `M'
local dof = `N' - `kk'	
local G = `G2'-1

tempname name1 name2
if "`cluster'"=="" {
	//regress `depvar' `endog' `exog' `iv', nocons dof(`dof')
	ivreg2 `depvar' (`endog'=`iv') `exog' , `gmm2s' nocons dofminus(`G1') sdofminus(`G') //dof(`dof')
	estimates store `name1'
	local r=1-e(rss)/`tss'
        local KP = e(widstat)
        ereturn scalar df_m = `kk'-1
	ereturn scalar mss=`tss'-e(rss)
	ereturn scalar r2=`r'
	ereturn scalar r2_a=1-(e(rss)/e(df_r))/(`tss'/(e(N)-1))
	ereturn scalar F=(`r'/(1-`r'))*(e(df_r)/(`kk'-1))
	ereturn scalar widstat = `KP' 
	ereturn local cmdline "ivreg2hdfe `0'"
	ereturn local cmd "ivreg2hdfe"
	ereturn local predict ""
	ereturn local estat_cmd ""
	estimates store `name1'
}
else {
	sort `clustervar'
	qui count if `clustervar'!=`clustervar'[_n-1]
	local Nclust = r(N)
	//regress `depvar' `endog' `exog' `iv', nocons cluster(`clustervar') // mse1
	ivreg2 `depvar' (`endog'=`iv') `exog' , `gmm2s' nocons dofminus(`G1') sdofminus(`G') cluster(`clustervar') 
	estimates store `name2'
	tempname b V
	matrix `V'=e(V)
	matrix `b'=e(b)
	local rss=e(rss)
	local r=1-`rss'/`tss'
	local nobs=e(N)
        local KP = e(widstat)
	tempvar res
	predict double `res', residual
	_robust `res', v(`V') minus(`kk') cluster(`clustervar')
	ereturn scalar Mgroups = `M'
	//ereturn post `b' `V', depname(`depvar') obs(`nobs') dof(`kk')
	ereturn local eclustvar "`cluster'"
	ereturn local vce "cluster"
	ereturn local vcetype "Robust"
	ereturn local cmdline "ivreg2hdfe `0'"
	ereturn local depvar "y"
	ereturn local cmd "ivreg2hdfe"
	ereturn scalar N_clust=`Nclust'
	ereturn scalar r2=`r'
	ereturn scalar rss=`rss'
	ereturn scalar mss=`tss'-`rss'
	ereturn scalar widstat = `KP' 
	estimates store `name2'
}

restore
end


/* This routine is from Amine Quazad's a2reg program */
/* It establishes the connected groups in the data */
*Find connected groups for normalization
capture program drop makegps
program define makegps
version 9.2
syntax [if] [in], id1(varname) id2(varname) groupid(name)
marksample touse
markout `touse' `id1' `id2'
confirm new variable `groupid'
sort `id1' `id2'
preserve
*Work with a subset of the data consisting of all id1-id2 combinations
keep if `touse'
collapse (sum) `touse', by(`id1' `id2')
sort `id1' `id2'
*Start by assigning the first id1 value to group 1, then iterate to fill this out
tempvar group newgroup1 newgroup2
gen double `group'=`id1'
local finished=0
local iter=1
while `finished'==0 {
quietly {
bysort `id2': egen double `newgroup1'=min(`group')
bysort `id1': egen double `newgroup2'=min(`newgroup1')
qui count if `newgroup2'~=`group'
local nchange=r(N)
local finished=(`nchange'==0)
replace `group'=`newgroup2'
 drop `newgroup1' `newgroup2'
}
di in yellow "On iteration `iter', changed `nchange' assignments"
local iter=`iter'+1
}
sort `group' `id1' `id2'
tempvar nobs complement
by `group': egen double `nobs'=sum(`touse')
replace `nobs'= -1*`nobs'
egen double `groupid'=group(`nobs' `group')
keep `id1' `id2' `groupid'
sort `id1' `id2'
tempfile gps
save `gps'
restore
tempvar mrg2group
merge `id1' `id2' using `gps', uniqusing _merge(`mrg2group')
assert `mrg2group'~=2
assert `groupid'<. if `mrg2group'==3
assert `groupid'==. if `mrg2group'==1
drop `mrg2group'
end  
