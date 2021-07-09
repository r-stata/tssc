*! baing v0.8 HNunez and JOtero 06jul2020


capture program drop baing
program define baing, rclass
version 14

syntax varlist(min=2 numeric ts fv) [if] [in] [, CRITeria(integer -1) MAXpc(integer -1) STAND PREfix(string)]

marksample touse
markout `touse' `tvar'
 
quietly tsreport if `touse'
if r(N_gaps) {
	display in red "sample may not contain gaps"
	exit
}

local numvars  : word count `varlist'
local var1 : word 1 of `varlist'

qui sum `var1' if `touse'
local nobs = r(N)
// display `numvars'
// display `nobs'	

if `maxpc'==-1 {
// maximum number of assumed principal components is the number of variables
   local maxpc = `numvars'
}

tempname matsigmasq
matrix `matsigmasq' = J(`numvars',`maxpc',.)

if "`stand'" == "stand" {
	forvalues i = 1/`numvars' {
	tempvar newvar
	local var`i' : word `i' of `varlist'
	qui sum `var`i'' if `touse'
	qui gen double `newvar' = (`var`i''-r(mean))/r(sd)
	local newvarlist `newvarlist' `newvar'
	}
mkmat `newvarlist' if `touse', matrix(X)
qui pca `newvarlist' if `touse', components(`maxpc')
qui predict _s* if `touse', score

forvalues i = 1/`numvars' {
	local chosen ""
	local var`i' : word `i' of `newvarlist'
	
	forvalues j = 1/`maxpc' {
		local chosen `chosen' _s`j'
		qui reg `var`i'' `chosen' if `touse', noc
		matrix `matsigmasq'[`i',`j'] = e(rss)/e(N)
	}
}
} 
else{
	mkmat `varlist' if `touse', matrix(X)
	qui pca `varlist' if `touse', components(`maxpc')
	qui predict _s* if `touse', score

	forvalues i = 1/`numvars' {
		local chosen ""
		local var`i' : word `i' of `varlist'
		forvalues j = 1/`maxpc' {
			local chosen `chosen' _s`j'
			qui reg `var`i'' `chosen' if `touse', noc
			matrix `matsigmasq'[`i',`j'] = e(rss)/e(N)
		}
	}
}

tempvar _vecsigmasq
qui g `_vecsigmasq' = .
// matrix list `matsigmasq'
mata: mata clear
mata: mmatsigmasq = st_matrix("`matsigmasq'")
// mata: mmatsigmasq
mata: avgsigmasqt = mean(mmatsigmasq)'
// mata: avgsigmasqt = avgsigmasq'; avgsigmasqt
mata: st_view(asig=.,.,st_local("_vecsigmasq"), .)
mata: asig[1..rows(avgsigmasqt),.] = avgsigmasqt
// su `_vecsigmasq'

// mata: avgsigmasqt
/*
mata: st_matrix("avgsigmasqt", avgsigmasqt)
// matrix list avgsigmasqt

svmat avgsigmasqt, names(_vecsigmasq)
*/

tempvar factors ic min_ic nfactors_ic
qui gen `factors' = .
qui gen `ic' = .

// IC criteria

if `criteria' == 2 {
	local scale = (`numvars'+`nobs')/(`numvars'*`nobs')*log(min(`numvars',`nobs'))
}
else if `criteria' == 3 {
    local scale = log(min(`numvars',`nobs'))/(min(`numvars',`nobs'))
} 
else {
	local criteria = 1
	local scale = (`numvars'+`nobs')/(`numvars'*`nobs')*log((`numvars'*`nobs')/(`numvars'+`nobs'))
} 


forvalues i = 1/`maxpc' {
	qui replace `factors' = `i' in `i'
	qui replace `ic' = log(`_vecsigmasq'[`i']) + `i'*`scale' in `i'
}
egen `min_ic' = min(`ic')
quietly gen `nfactors_ic' = `factors' if `min_ic' == `ic'
su `nfactors_ic', mean
display as result "Number of factors based on Bai & Ng (2002, Econometrica) IC"`criteria' " " r(mean)
// list _vecsigmasq `factors' `ic' `min_ic' `nfactors_ic' in 1/`maxpc'
return scalar baing_ic = r(mean)


// This is to compute and retrieve the common factors

if "`prefix'" != "" {
tempname T N

scalar `T' = rowsof(X)
scalar `N' = colsof(X)

	if `T'<`N' {
			matrix XX = X*X'/(`N'*`T')
			matrix U2 = .
			matrix s  = .
			matrix Vt = .
			mata: A = st_matrix("XX")
			mata: U2 = st_matrix("U2")
			mata: s = st_matrix("s")
			mata: Vt = st_matrix("Vt")

			mata: fullsvd(A,U2,s,Vt)

			mata: st_matrix("U2",U2)
			mata: st_matrix("s",s)
			mata: st_matrix("Vt",Vt)
		
			matrix lambda = U2[.,1..r(mean)]*sqrt(`T')
			matrix `prefix' = X*lambda/`T'
	}
	else {
			matrix XX = X'*X/(`N'*`T')
			matrix U2 = .
			matrix s  = .
			matrix Vt = .
			mata: A = st_matrix("XX")
			mata: U2 = st_matrix("U2")
			mata: s = st_matrix("s")
			mata: Vt = st_matrix("Vt")
			
			mata: fullsvd(A,U2,s,Vt)
			
			mata: st_matrix("U2",U2)
			mata: st_matrix("s",s)
			mata: st_matrix("Vt",Vt)

			matrix lambda = U2[.,1..r(mean)]*sqrt(`N')
			matrix `prefix' = X*lambda/`N'
	}	

svmat `prefix'
	
}

drop _s* // _vecsigmasq
end
