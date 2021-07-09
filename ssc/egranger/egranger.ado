*! egranger version 1.0.5  20Nov2012
*! author Mark Schaffer
* snippets of code used from dfuller.ado for Stata 9
* Version notes
* 1.0.4		Fixed bad bug in 2-step ECM - should have been including _lagged_ difference of x
* 1.0.5     Fixed another bad bag - was undercounting the number of cointegrated series by 1
*           Added saved value of number of series as macro NS
program define egranger, eclass
	version 9.0
	syntax varlist(ts) [if] [in] [, TRend QTRend Lags(int 0) REGress ecm ]

	tempname tempr
	capture _return drop `tempr'
	_return hold `tempr'
	
	marksample touse
	_ts tvar panelvar `if' `in', sort onepanel
	markout `touse' `tvar'
	tokenize `varlist'
	local y `1'
	macro shift
	local x `*'
	local NS : word count `varlist'
	if `NS' > 12 {
		di as err "Error: critical values not available for more than 12 cointegrated series"
		exit 198
	}
	if `NS' < 2 {
		di as err "too few variables specified"
		exit 102
	}

	sum `tvar' if `touse', meanonly
	local min = r(min)
	local N = r(N)

* Time variable t=0 in first period (lose this ob in 2nd step)
	if "`trend'`qtrend'" != "" {
		tempvar t
		gen long `t' = `tvar'-`min'
		local tv `t'
		if "`qtrend'" != "" {
			tempvar tsq
			gen `tsq' = `t'^2
			local qtv `tsq'
			local case "ctt"
		}
		else {
			local case "ct"
		}
	}
	else {
		local case "c"
	}

	local k1 : word count `y' `x' `tv' `qtv'
	qui _rmcoll `y' `x' `tv' `qtv'
	local k2 : word count `r(varlist)'
	if `k2' < `k1' {
		di as error "Error - perfect collinearity in specified variables"
		exit 198
	}

	if `lags' < 0 {
		di as error "Error - negative lags not allowed"
		exit 198
	}
	
	if `lags' > (`N'-1) {
		di as error "Error - number of lags exceeds number of observations"
		exit 198
	}

* Engle-Granger 1st step and residuals		
	qui reg `y' `x' `tv' `qtv' if `touse'

	local N1 = e(N)
* MacKinnon "T" is number of first-step observations minus 1 (lost first ob in 2nd step)
* Not clear from MacKinnon paper but assumed - additional obs lost because of augmentation
* with lags are not subtracted from T.
	local T = `N1'-1

	capture confirm variable _egresid
	if _rc == 0 {
		di in ye "Replacing variable _egresid..."
		capture drop _egresid
	}

	qui predict double _egresid if e(sample), resid

	if "`regress'" != "" {
		repost "`tv'" "_trend" "`qtv'" "_trend^2"
		est store _egranger1
	}

* Engle-Granger test
	if "`ecm'"=="" {
		if `lags' == 0 {
			qui reg D._egresid L._egresid if `touse', nocons
		}
		else {
			qui reg D._egresid L._egresid DL(1/`lags')._egresid if `touse', nocons
		}
		local N2 = e(N)
		qui test L._egresid
		local Zt = sign(_b[L._egresid])*sqrt(r(F))

		if "`regress'" != "" {
			est store _egrangert
		}

		GetCrit `case' `T' `NS'
		tempname cv1 cv5 cv10
		scalar `cv1'=r(cv1)
		scalar `cv5'=r(cv5)
		scalar `cv10'=r(cv10)
	
		if `lags' ~=0 {
			local aug "Augmented "
		}
		di in gr _n "`aug'Engle-Granger test for cointegration" /*
			*/	in gr _col(55) "N (1st step)  =" in ye %9.0f `N1'
		if `lags' ~= 0 {
			di in gr "Number of lags   = " in ye %2.0f `lags' _c
		}
		di _col(55) in gr "N (test)      =" in ye %9.0f `N2'
		if "`qtrend'" != "" {
			di in gr "1st step includes quadratic trend"
		}
		else if "`trend'" != "" {
			di in gr "1st step includes linear trend"
		}
		di in gr in smcl "{hline 78}"
	
	
		di in gr _col (19) "Test" /*
			*/ _col(32)  "1% Critical" /*
			*/ _col(50)  "5% Critical" /*
			*/ _col(67) "10% Critical"
		di in gr _col (16) "Statistic" /*
			*/ _col(36)  "Value" /*
			*/ _col(54)  "Value" /*
			*/ _col(72) "Value"
		di in gr in smcl "{hline 78}"
	
		di in gr " Z(t)" /*
			*/ _col(15) in ye %10.3f `Zt' /*
			*/ _col(33) %10.3f `r(cv1)' /*
			*/ _col(51) %10.3f `r(cv5)' /*
			*/ _col(69) %10.3f `r(cv10)'
	
		di
		di in gr "Critical values from MacKinnon (1990, 2010)"

		local title "Engle-Granger test regression"

		if "`regress'" != "" {
			di in gr in smcl "{hline 78}"
			qui est restore _egranger1
			di in ye "Engle-Granger 1st-step regression"
			ereturn display
			qui est restore _egrangert
			di in ye "`title'"
*			ereturn display		/* fails in Stata 9 and 10 */
			regress, noheader
			est drop _egranger1
			est drop _egrangert
* Oddly, est drop saves the names of dropped results in r(names)
		}
	
		eret scalar Zt     = `Zt'
		eret scalar cv1    = `cv1'
		eret scalar cv5    = `cv5'
		eret scalar cv10   = `cv10'
		eret scalar N1     = `N1'
		eret scalar N2     = `N2'
		eret scalar lags   = `lags'
		eret scalar NS     = `NS'
		eret local cmdline
		eret local title "`title'"
	}

* Engle-Granger 2nd step
	else {

		if `lags' == 0 {
			qui regress D.`y' L._egresid LD.(`x')
		}
		else {
			qui regress D.`y' L._egresid L(1/`lags')D.`y' L(1/`lags')D.(`x')
		}
		local N2 = e(N)
		est store _egranger2

		di in gr _n "Engle-Granger 2-step ECM estimation" /*
				*/	in gr _col(55) "N (1st step)  =" in ye %9.0f `N1'

		if `lags' ~= 0 {
			di in gr "Number of lags   = " in ye %2.0f `lags' _c
		}
		di _col(55) in gr "N (2nd step)  =" in ye %9.0f `N2'
		if "`qtrend'" != "" {
			di in gr "1st step includes quadratic trend"
		}
		else if "`trend'" != "" {
			di in gr "1st step includes linear trend"
		}

		if "`regress'" != "" {
			qui est restore _egranger1
			di _n in ye "Engle-Granger 1st-step regression"
			ereturn display
			est drop _egranger1
		}
		
		local title "Engle-Granger 2-step ECM"
		
		di _n in ye "`title'"
		qui est restore _egranger2
*		ereturn display		/* fails in Stata 9 and 10 */
		regress, noheader
		est drop _egranger2

		eret local cmdline
		eret local title "`title'"

	}
	_return restore `tempr'

end

program define repost, eclass

	args vntemp1 vn1 vntemp2 vn2

	tempvar esample
	tempname b V dof
	mat `b'=e(b)
	mat `V'=e(V)
	local N=e(N)
	local dof=e(df_r)
	local depname=e(depvar)
	if "`vntemp1'" ~= "" {
		local names : colnames `b'
		local names : subinstr local names "`vntemp1'" "`vn1'", all
		mat colnames `b' = `names'
		mat colnames `V' = `names'
		mat rownames `V' = `names'
	}
	if "`vntemp2'" ~= "" {
		local names : colnames `b'
		local names : subinstr local names "`vntemp2'" "`vn2'", all
		mat colnames `b' = `names'
		mat colnames `V' = `names'
		mat rownames `V' = `names'
	}
	ereturn post `b' `V', depname(`depname') obs(`N') dof(`dof')
	ereturn local cmd "repost"
end

program define GetCrit, rclass
	version 9.0
	args case T NS

* T is number of obs
* NS is number of cointegrating series
* Matrix columns are:
* 	NS	%sig	binf	b1		b2		b3
* CV = binf + b1/T + b2/T^2 + b3/T^3

	tempname cv cvtab

	if "`case'"=="nc" {		
		mat `cvtab' = (											/*
			*/	1, 1, -2.56574, -2.2358, -3.627, 0 \			/*
			*/	1, 5, -1.941, -0.2686, -3.365, 31.223 \			/*
			*/	1, 10, -1.61682, 0.2656, -2.714, 25.364	)
	}

	if "`case'"=="c" {		
		mat `cvtab' = (											/*
			*/	1, 1, -3.43035, -6.5393, -16.786, -79.433 \		/*
			*/	1, 5, -2.86154, -2.8903, -4.234, -40.04 \		/*
			*/	1, 10, -2.56677, -1.5384, -2.809, 0 \			/*
			*/	2, 1, -3.89644, -10.9519, -22.527, 0 \			/*
			*/	2, 5, -3.33613, -6.1101, -6.823, 0 \			/*
			*/	2, 10, -3.04445, -4.2412, -2.72, 0 \			/*
			*/	3, 1, -4.29374, -14.4354, -33.195, 47.433 \		/*
			*/	3, 5, -3.74066, -8.5631, -10.852, 27.982 \		/*
			*/	3, 10, -3.45218, -6.2143, -3.718, 0 \			/*
			*/	4, 1, -4.64332, -18.1031, -37.972, 0 \			/*
			*/	4, 5, -4.096, -11.2349, -11.175, 0 \			/*
			*/	4, 10, -3.8102, -8.3931, -4.137, 0 \			/*
			*/	5, 1, -4.95756, -21.8883, -45.142, 0 \			/*
			*/	5, 5, -4.41519, -14.0406, -12.575, 0 \			/*
			*/	5, 10, -4.13157, -10.7417, -3.784, 0 \			/*
			*/	6, 1, -5.24568, -25.6688, -57.737, 88.639 \		/*
			*/	6, 5, -4.70693, -16.9178, -17.492, 60.007 \		/*
			*/	6, 10, -4.42501, -13.1875, -5.104, 27.877 \		/*
			*/	7, 1, -5.51233, -29.576, -69.398, 164.295 \		/*
			*/	7, 5, -4.97684, -19.9021, -22.045, 110.761 \	/*
			*/	7, 10, -4.69648, -15.7315, -6.922, 67.721 \		/*
			*/	8, 1, -5.76202, -33.5258, -82.189, 256.289 \	/*
			*/	8, 5, -5.22924, -23.0023, -24.646, 144.479 \	/*
			*/	8, 10, -4.95007, -18.3959, -7.344, 94.872 \		/*
			*/	9, 1, -5.99742, -37.6572, -87.365, 248.316 \	/*
			*/	9, 5, -5.46697, -26.2057, -26.627, 176.382 \	/*
			*/	9, 10, -5.18897, -21.1377, -9.484, 172.704 \	/*
			*/	10, 1, -6.22103, -41.7154, -102.68, 389.33 \	/*
			*/	10, 5, -5.69244, -29.4521, -30.994, 251.016 \	/*
			*/	10, 10, -5.41533, -24.0006, -7.514, 163.049 \	/*
			*/	11, 1, -6.43377, -46.0084, -106.809, 352.752 \	/*
			*/	11, 5, -5.90714, -32.8336, -30.275, 249.994 \	/*
			*/	11, 10, -5.63086, -26.9693, -4.083, 151.427 \	/*
			*/	12, 1, -6.6379, -50.2095, -124.156, 579.622 \	/*
			*/	12, 5, -6.11279, -36.2681, -32.505, 314.802 \	/*
			*/	12, 10, -5.83724, -29.9864, -2.686, 184.116	 	/*
			*/	)
	}


	if "`case'"=="ct" {		
		mat `cvtab' =	(										/*
			*/	1, 1, -3.95877, -9.0531, -28.428, -134.155 \	/*
			*/	1, 5, -3.41049, -4.3904, -9.036, -45.374 \		/*
			*/	1, 10, -3.12705, -2.5856, -3.925, -22.38 \		/*
			*/	2, 1, -4.32762, -15.4387, -35.679, 0 \			/*
			*/	2, 5, -3.78057, -9.5106, -12.074, 0 \			/*
			*/	2, 10, -3.49631, -7.0815, -7.538, 21.892 \		/*
			*/	3, 1, -4.66305, -18.7688, -49.793, 104.244 \	/*
			*/	3, 5, -4.1189, -11.8922, -19.031, 77.332 \		/*
			*/	3, 10, -3.83511, -9.0723, -8.504, 35.403 \		/*
			*/	4, 1, -4.9694, -22.4694, -52.599, 51.314 \		/*
			*/	4, 5, -4.42871, -14.5876, -18.228, 39.647 \		/*
			*/	4, 10, -4.14633, -11.25, -9.873, 54.109 \		/*
			*/	5, 1, -5.25276, -26.2183, -59.631, 50.646 \		/*
			*/	5, 5, -4.71537, -17.3569, -22.66, 91.359 \		/*
			*/	5, 10, -4.43422, -13.6078, -10.238, 76.781 \	/*
			*/	6, 1, -5.51727, -29.976, -75.222, 202.253 \		/*
			*/	6, 5, -4.98228, -20.305, -25.224, 132.03 \		/*
			*/	6, 10, -4.70233, -16.1253, -9.836, 94.272 \		/*
			*/	7, 1, -5.76537, -33.9165, -84.312, 245.394 \	/*
			*/	7, 5, -5.23299, -23.3328, -28.955, 182.342 \	/*
			*/	7, 10, -4.95405, -18.7352, -10.168, 120.575 \	/*
			*/	8, 1, -6.00003, -37.8892, -96.428, 335.92 \		/*
			*/	8, 5, -5.46971, -26.4771, -31.034, 220.165 \	/*
			*/	8, 10, -5.19183, -21.4328, -10.726, 157.955 \	/*
			*/	9, 1, -6.22288, -41.9496, -109.881, 466.068 \	/*
			*/	9, 5, -5.69447, -29.7152, -33.784, 273.002 \	/*
			*/	9, 10, -5.41738, -24.2882, -8.584, 169.891 \	/*
			*/	10, 1, -6.43551, -46.1151, -120.814, 566.823 \	/*
			*/	10, 5, -5.90887, -33.0251, -37.208, 346.189 \	/*
			*/	10, 10, -5.63255, -27.2042, -6.792, 177.666 \	/*
			*/	11, 1, -6.63894, -50.4287, -128.997, 642.781 \	/*
			*/	11, 5, -6.11404, -36.461, -36.246, 348.554 \	/*
			*/	11, 10, -5.8385, -30.1995, -5.163, 210.338 \	/*
			*/	12, 1, -6.83488, -54.7119, -139.8, 736.376 \	/*
			*/	12, 5, -6.31127, -39.9676, -37.021, 406.051 \	/*
			*/	12, 10, -6.0365, -33.2381, -6.606, 317.776	)
	}


	if "`case'"=="ctt" {		
		mat `cvtab' =	(										/*
			*/	1, 1, -4.37113, -11.5882, -35.819, -334.047 \	/*
			*/	1, 5, -3.83239, -5.9057, -12.49, -118.284 \		/*
			*/	1, 10, -3.55326, -3.6596, -5.293, -63.559 \		/*
			*/	2, 1, -4.69276, -20.2284, -64.919, 88.884 \		/*
			*/	2, 5, -4.15387, -13.3114, -28.402, 72.741 \		/*
			*/	2, 10, -3.87346, -10.4637, -17.408, 66.313 \	/*
			*/	3, 1, -4.99071, -23.5873, -76.924, 184.782 \	/*
			*/	3, 5, -4.45311, -15.7732, -32.316, 122.705 \	/*
			*/	3, 10, -4.1728, -12.4909, -17.912, 83.285 \		/*
			*/	4, 1, -5.2678, -27.2836, -78.971, 137.871 \		/*
			*/	4, 5, -4.73244, -18.4833, -31.875, 111.817 \	/*
			*/	4, 10, -4.45268, -14.7199, -17.969, 101.92 \	/*
			*/	5, 1, -5.52826, -30.9051, -92.49, 248.096 \		/*
			*/	5, 5, -4.99491, -21.236, -37.685, 194.208 \		/*
			*/	5, 10, -4.71587, -17.082, -18.631, 136.672 \	/*
			*/	6, 1, -5.77379, -34.701, -105.937, 393.991 \	/*
			*/	6, 5, -5.24217, -24.2177, -39.153, 232.528 \	/*
			*/	6, 10, -4.96397, -19.6064, -18.858, 174.919 \	/*
			*/	7, 1, -6.00609, -38.7383, -108.605, 365.208 \	/*
			*/	7, 5, -5.47664, -27.3005, -39.498, 246.918 \	/*
			*/	7, 10, -5.19921, -22.2617, -17.91, 208.494 \	/*
			*/	8, 1, -6.22758, -42.7154, -119.622, 421.395 \	/*
			*/	8, 5, -5.69983, -30.4365, -44.3, 345.48 \		/*
			*/	8, 10, -5.4232, -24.9686, -19.688, 274.462 \	/*
			*/	9, 1, -6.43933, -46.7581, -136.691, 651.38 \	/*
			*/	9, 5, -5.91298, -33.7584, -42.686, 346.629 \	/*
			*/	9, 10, -5.63704, -27.8965, -13.88, 236.975 \	/*
			*/	10, 1, -6.64235, -50.9783, -145.462, 752.228 \	/*
			*/	10, 5, -6.11753, -37.056, -48.719, 473.905 \	/*
			*/	10, 10, -5.84215, -30.8119, -14.938, 316.006 \	/*
			*/	11, 1, -6.83743, -55.2861, -152.651, 792.577 \	/*
			*/	11, 5, -6.31396, -40.5507, -46.771, 487.185 \	/*
			*/	11, 10, -6.03921, -33.895, -9.122, 285.164 \	/*
			*/	12, 1, -7.02582, -59.6037, -166.368, 989.879 \	/*
			*/	12, 5, -6.50353, -44.0797, -47.242, 543.889 \	/*
			*/	12, 10, -6.22941, -36.9673, -10.868, 418.414	)
	}

	return scalar cv1 =		`cvtab'[(`NS'-1)*3+1,3] +			/*
						*/	`cvtab'[(`NS'-1)*3+1,4]/`T' +		/*
						*/	`cvtab'[(`NS'-1)*3+1,5]/(`T'^2) +	/*
						*/	`cvtab'[(`NS'-1)*3+1,6]/(`T'^3)
	return scalar cv5 =		`cvtab'[(`NS'-1)*3+2,3] +			/*
						*/	`cvtab'[(`NS'-1)*3+2,4]/`T' +		/*
						*/	`cvtab'[(`NS'-1)*3+2,5]/(`T'^2) +	/*
						*/	`cvtab'[(`NS'-1)*3+2,6]/(`T'^3)
	return scalar cv10 =	`cvtab'[(`NS'-1)*3+3,3] +			/*
						*/	`cvtab'[(`NS'-1)*3+3,4]/`T' +		/*
						*/	`cvtab'[(`NS'-1)*3+3,5]/(`T'^2) +	/*
						*/	`cvtab'[(`NS'-1)*3+3,6]/(`T'^3)

end
