*! version 4.3  22jul2020  Cliff Zhu
capture program drop grsftest
program define grsftest, rclass
	version 13
	syntax varlist(min=1 numeric) [if], factor(varlist min=1 numeric) [Details]
	
** Get Parameters
	qui count `if'
	local T= `r(N)'
	local N: word count `varlist'
	local K: word count `factor'
	matrix b_Alpha  =J(`N',1,.)
	matrix se_Alpha =J(`N',1,.)
	matrix R2 =J(`N',1,.)
	matrix R2_adj =J(`N',1,.)
** Fit Factor Models
	local i=1
	quietly foreach var of varlist `varlist' {
		tempvar res`i' 
		reg `var' `factor' `if'
		matrix b_Alpha[`i',1] = _b[_cons]
		matrix se_Alpha[`i',1]= _se[_cons]
		matrix R2[`i',1]= e(r2)
		matrix R2_adj[`i',1]= e(r2_a)
		predict double `res`i'' if e(sample), residuals
		local reslist `reslist' `res`i''
		local i=`i'+1
	}
** Prepare Factor Models Results
	matrix ALPHA= (b_Alpha,se_Alpha,R2,R2_adj)
	matrix U =J(rowsof(ALPHA),1,1)
	matrix Amean= U'*ALPHA /rowsof(ALPHA)
	matrix colnames ALPHA = "Estimate" "Std.Err." "R2" "R2_adj"
	matrix rownames ALPHA = `varlist'
	matrix colnames Amean = "Mean alpha" "Mean SE" "Mean R2" "Mean R2_adj"
	matrix rownames Amean = "`N' Assets"
	qui tabstat `factor' `if', stat(mean) col(stat) save
	matrix Fmean= r(StatTotal)' 
	qui matrix accum RR = `reslist' ,deviations noconstant
	matrix RCOV= RR/(`T'-`K'-1)
	qui mkmat `factor' `if', matrix(rp) 
	matrix FCOV= (rp'*rp)/(`T')
	matrix LAMBDA= FCOV - Fmean * Fmean'
	qui tabstat `varlist' `factor' `if', stat(n mean sd min median max) col(stat) save
	matrix STATS= r(StatTotal)'
	
** GRS test Formula (Kamstra and Shi 2020, eq8)
	matrix tm1= (`T'*(`T'-`N'-`K')) / (`N'*(`T'-`K'-1))
	matrix tm2= (1 + Fmean' * invsym(LAMBDA) * Fmean)
	matrix tm3= (b_Alpha' * invsym(RCOV) * b_Alpha)
	local ftest_KS= tm1[1,1] * tm3[1,1] / tm2[1,1] 
	local pval_KS= 1 - F(`N',`T'-`N'-`K', `ftest_KS')
	
** Results
	display " "
	display "{title: GRS Test Results}"
	display "{hline 30}"
	display " Number of Obs.  : " %9.0f `T'
	display " Number of Asset : " %9.0f `N'
	display " Number of Factor: " %9.0f `K'
	display " Results"
	display "       GRS_F-test =" %9.6f `ftest_KS'
	display "       GRS_pvalue =" %9.6f `pval_KS' 
	display "{hline 30}"
	if ~missing("`details'"){
		matrix list Amean , format(%9.6f) title("Factor Model Results (On Average)")
		matrix list ALPHA , format(%9.6f) title("Factor Model Results (By Asset)")
		tabstat `varlist' `factor' `if', stat(n mean sd min median max) col(stat) long
	}
	return matrix summary STATS
	return matrix alphas ALPHA
	matrix drop b_Alpha se_Alpha R2 R2_adj U Amean Fmean RR RCOV rp FCOV LAMBDA tm1 tm2 tm3

end

