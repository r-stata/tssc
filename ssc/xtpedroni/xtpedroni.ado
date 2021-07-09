*! Timothy Neal -- 20/07/13
*! This is the first public version of xtpedroni, used to conduct panel cointegration analysis with Pedroni's panel 
*! cointegration test statistics, and his group mean Panel Dynamic OLS. If there are any questions, issues, or comparatibility
*! problems with this procedure, please email timothy.neal@unsw.edu.au. 
program define xtpedroni, rclass
	version 11
	syntax varlist [if] [in] [, NOTDUM LAGS(integer 2) ADFLAGS(integer -2) MLAGS(integer -2) LAGSELECT(string) TREND B(integer 0) NOPDOLS NOTEST FULL EXTRAOBS AVERAGE(string) ]

*! PART 1 of the procedure: Establish data series, panel information, set up critical value tables, 
*! and set up the lists used in the main loop.

	*! Mark the sample that is usable, identify the panel and time variable, and other panel statistics.
	marksample touse
	qui {
		xtset
		local ivar `r(panelvar)'
		local tvar `r(timevar)'
		quie levels `ivar' if `touse', local(ids)
		global iis "`ids'"
		tempname is g2 m
		quie count if `touse'
		local m=wordcount("`varlist'")-1
		local is=wordcount("$iis")
		scalar `g2'=r(N)/`is'
	}
	
	*! Error checking options
	if "`lagselect'" != "" & "`lagselect'" != "aic" & "`lagselect'" != "bic" & "`lagselect'" != "hqic" {
		di in smcl as error "Lag criterion must be aic, bic, or hqic."
		exit 198
	}
	
	if "`average'" != "" & "`average'" != "simple" & "`average'" != "sqrt" & "`average'" != "precision" {
		di in smcl as error "Group mean averaging methodology must be simple, sqrt, or precision."
		exit 198
	}
	
	if `m' > 7 {
		di in smcl as error "The number of regressors can't exceed seven."
	}

	*! Loop to time-demean the variables (if applicable)
	if "`notdum'" != "" {
		tokenize `varlist'
		global Ys `1'
		mac shift
		global Xs `*'
	}
	
	else  {
		foreach x in `varlist' {
			local names "`x'_td"
			if "`extraobs'" != "" {
				bysort `tvar': egen timemeans = mean(`x')
			}
			else {
				bysort `tvar': egen timemeans = mean(`x') if `touse'
			}
			sort `ivar' `tvar'
			qui gen `names' = `x' - timemeans 
			drop timemeans
			local tildelist `tildelist' `names'
			tokenize `tildelist'
			global Ys `1'
			mac shift
			global Xs `*'
		}
	}
	*! Loop to difference the variables (which may have been previously time-demeaned)
	local names "depvar_diff_xtpedroni"
	quietly generate `names' = d.$Ys
	foreach x in $Xs {
		local names "`x'_diff"
		sort `ivar' `tvar'
		quietly generate `names' = d.`x'
		local difflist `difflist' `names'
	}
	
	*! Loop to demean the differenced data and set up a time trend (if specified) 
	foreach x in `difflist' {
		local names "`x'_demean"
		bysort `ivar': egen imeans = mean(`x')
		sort `ivar' `tvar'
		quietly generate `names' = `x' - imeans 
		drop imeans
		local demeanlist `demeanlist' `names'
	}
	if "`trend'" != "" {
		tempvar t
		bys `ivar': gen `t' = _n
	}
	
	*! Set up hypothetised null beta vector
	if "`b'"=="" {
		matrix b0 = J(`m',1,0)
	}
	else {
		matrix b0 = J(`m',1,`b')
	}
	
	*! Set up Adjustment matrices (for panel cointegration test statistics)
	tempname MEANadjustment VARIANCEadjustment
	if "`trend'" != "" {
		matrix `MEANadjustment' = ( 17.86, -10.54, -2.29, -13.65, -2.53  \ 21.162, -14.011, -2.648, -17.359, -2.872  \ 24.556, -17.600, -2.967, -21.116, -3.179  \ 28.046, -21.287, -3.262, -24.930, -3.464  \ 31.738, -25.130, -3.545, -28.849, -3.737  \ 35.537, -28.981, -3.806, -32.716, -3.986 \ 39.231, -32.756, -4.047, -36.494, -4.217 ) 
		matrix `VARIANCEadjustment' = ( 101.68, 39.52, 0.66, 50.91, 0.56 \ 160.249, 64.219, 0.690, 66.387, 0.555 \ 198.167, 83.815, 0.686, 81.832, 0.548 \ 239.425, 103.905, 0.688, 97.362, 0.543 \ 276.997, 124.613, 0.686, 113.145, 0.538 \ 310.982, 138.227, 0.654, 127.989, 0.530 \ 348.217, 154.378, 0.638, 140.756, 0.518 ) 
	}
	else {
		matrix `MEANadjustment' = ( 8.62, -6.02, -1.73, -9.05, -2.03  \ 11.754, -9.495, -2.177, -12.938, -2.453  \ 15.197, -13.256, -2.576, -16.888, -2.827  \ 18.910, -17.163, -2.930, -20.841, -3.157  \ 22.715, -21.013, -3.241, -24.775, -3.452  \ 26.603, -24.944, -3.531, -28.720, -3.726  \ 30.457, -28.795, -3.795, -32.538, -3.976 ) 
		matrix `VARIANCEadjustment' = ( 60.75, 31.27, 0.93, 35.98, 0.66 \ 104.546, 57.610, 0.964, 51.49, 0.618 \ 151.094, 81.772, 0.923, 67.123, 0.585 \ 190.661, 99.331, 0.843, 81.835, 0.560 \ 231.864, 119.546, 0.800, 98.278, 0.553 \ 270.451, 134.341, 0.750, 113.131, 0.542 \ 293.431, 144.615, 0.685, 126.059, 0.525 ) 
	}

	*! Set up empty matrices (for PDOLS estimation)
	tempname pdlbsum1 pdlbsum2 pdlbsum3 pdltsum pdlvsum1 pdlvsum2 pdlhsum2 pdlhsum3
	matrix pdlbsum1= J(`m',1,0)
	matrix pdlbsum2= J(`m',1,0)
	matrix pdlbsum3= J(`m',1,0)
	matrix pdltsum= J(`m',1,0)
	matrix pdlvsum1= J(`m',`m',0)
	matrix pdlvsum2= J(`m',`m',0)
	matrix pdlhsum2= J(`m',`m',0)
	matrix pdlhsum3= J(`m',`m',0)
	
	*! Set up temporary variables
	tempvar r e utest n l2 lede le2
	qui {
		gen `r'=.
		gen `e'=.
		gen `utest'=.
		gen `n'=.
		gen `l2'=.
		gen `lede'=.
		gen `le2'=.
	}
	
	*! Set up temporary scalars
	local sigma = 0
	local rhodiv = 0
	local tdiv = 0
	local sstar = 0
	local adfdiv = 0
	local lambda = 0
	local ledelambdarho = 0
	local ledelambdat = 0
	local suml2e2 = 0
	local suml2e2rho = 0
	local S3adf = 0
	local D3adf = 0
	local N3adf = 0
	
	di _newline
	di "Please Wait: Calculating Statistics"
	
*! PART 2 of the procedure: Main loop that goes through each individual panel unit,
*! calculating statistics for each member.

	qui foreach i of global iis {
		tempvar u`i' gamu`i' gamutest`i' gamn`i' utest`i' e`i' n`i'  
		tempname Nadf`i' Dadf`i' adflag XXt`i' XX2`i' XX3`i' pdlb`i' pdlv`i' pdl`i'results dd`i' Vinv`i'
		tempname LRV`i' subinvxx`i' invxx`i' XX`i' b`i' tnum`i'
		
		if "`nopdols'" == "" {
			*! PDOLS section:
			
			*! DOLS Regression for individual i, save important results (PDOLS)
			regress $Ys $Xs l(`lags'/-`lags')(`demeanlist') if `ivar'==`i'
			predict `u`i'' if e(sample), resid
			matrix b`i' = e(b)
			local T2`i' = e(N)+(`lags'*2)
			local Tused`i' = e(N)
			
			*! Lags for Bartlett Kernel
			if `mlags' < 0 {
				local mlags1 = round(4*(`T2`i''/100)^(2/9))
			}
			else {
				local mlags1 = `mlags'
			}
			
			*! Newey-West long run variance of the residuals using the Bartlett kernel
			gen double `gamu`i'' = `u`i'' * `u`i'' if e(sample)
			sum `gamu`i''
			local sumgamu`i' = r(sum)
			local gam0`i' = `sumgamu`i''/(`T2`i'')
			local lam`i' = `gam0`i''
			local l = 1
			while `l' <= `mlags1' {
				replace `gamu`i'' = `u`i''*L`l'.`u`i'' if e(sample)
				sum `gamu`i''
				local sumgamu`i' = r(sum)
				local gam`l'`i' = `sumgamu`i''/(`T2`i'')
				local factor`i' = 2*(1-`l'/(`mlags1'+1))
				local lam`i' = `lam`i'' + `factor`i''*`gam`l'`i''
				local l = `l'+1
			}
			matrix accum XX`i' = $Xs l(`lags'/-`lags')d.($Xs) if `ivar'==`i' 
			matrix invXX`i' = inv(XX`i')
			matrix subinvXX`i' = invXX`i'[1..`m',1..`m']
			matrix LRV`i' = `lam`i''*subinvXX`i'
			matrix Vinv`i' = inv(LRV`i')
			matrix dd`i' = inv(cholesky(diag(vecdiag(LRV`i'))))
			
			*! Setting up combined matrices
			matrix pdlb`i' = b`i'[1,1..`m']
			matrix pdlv`i' = dd`i'
			matrix pdlbsum1 = pdlbsum1 + b`i'[1,1..`m']'
			matrix pdlbsum2 = pdlbsum2 + (dd`i' * b`i'[1,1..`m']')
			matrix pdlbsum3 = pdlbsum3 + (Vinv`i' * b`i'[1,1..`m']')
			matrix pdlvsum1 = pdlvsum1 + LRV`i'
			matrix pdlvsum2 = pdlvsum2 + (dd`i' * LRV`i' * dd`i')
			matrix pdlhsum2 = pdlhsum2 + dd`i'
			matrix pdlhsum3 = pdlhsum3 + Vinv`i'
			
			*! t-statistic derivation and combined matrix
			local c = 1
			while `c'<=`m' {
				tempvar `c'
				matrix tdols`i'`c' = (b`i'[1,`c'] - b0[`c',1]) * dd`i'[`c',`c']
				matrix `tnum`i'' = nullmat(`tnum`i'') \ tdols`i'`c'
				local c=`c'+1
			}
			matrix pdltsum = pdltsum +`tnum`i''
			matrix pdl`i'results = pdlb`i'',`tnum`i''
			
			noi if "`full'" != "" {
				 *! Store individual DOLS results and display
				matrix colnames pdl`i'results = Beta t-stat
				di _newline
				di in gr "DOLS regression for panel unit: `i'"
				di in gr "Lags and leads: `lags'" _col(37) "Lags used in kernel: `mlags1'"
				di in gr "" _col(37) "Number of obs: `Tused`i''"
				matlist pdl`i'results, border(rows) rowtitle(Variables) left(4) twidth(14) format(%9.4g)
				
			}
		
		}
		
		*! Cointegration test section:
		
		if "`notest'" == "" {
			*! Do standard regression to get ehat
			if "`trend'" != "" {
				regress $Ys $Xs `t' if `touse' & `ivar'==`i'
			}
			else {
				regress $Ys $Xs if `touse' & `ivar'==`i'

			}
			predict double `e`i'' if e(sample), resid
			replace `e' = `e`i'' if e(sample)
			local T4`i' = e(N) 
			
			*! Calculate lags for ADF test, and then the ADF statistics
			if `adflags' < 0 {
				local maxlag = int(12*((0.01*`T4`i'')^(0.25)))
			}
			else {
				local maxlag = `adflags'
			}
			
			if "`lagselect'" == "aic" | "`lagselect'" == "" {
				xtunitroot llc `e' if `touse' & `ivar'==`i', lags(aic `maxlag') noconstant
			}
			if "`lagselect'" == "bic" {
				xtunitroot llc `e' if `touse' & `ivar'==`i', lags(bic `maxlag') noconstant
			}			
			if "`lagselect'" == "hqic" {
				xtunitroot llc `e' if `touse' & `ivar'==`i', lags(hqic `maxlag') noconstant
			}

			scalar `adflag' = r(adf_lagm)
			local adflag2 = `adflag'

			if `adflag' == 0 {
				regress `e' l.`e' if `touse' & `ivar'==`i', noconstant
				matrix accum `XXt`i'' = d.`e' l.`e' if `touse' & `ivar'==`i', noconstant
				matrix `XX2`i'' = `XXt`i''
				scalar Nadf`i' = `XX2`i''[2,1]
				scalar Dadf`i' = `XX2`i''[2,2]
			}
			if `adflag' == 1 {
				regress `e' l.`e' l(1)d.`e' if `touse' & `ivar'==`i', noconstant
				matrix accum `XXt`i'' = d.`e' l.`e' l(1)d.`e' if `touse' & `ivar'==`i', noconstant
				matrix `XX2`i'' = sweep(`XXt`i'',3)
				scalar Nadf`i' = `XX2`i''[2,1]
				scalar Dadf`i' = `XX2`i''[2,2]
			}
			if `adflag' > 1 {
				regress `e' l.`e' l(`adflag2'/1)d.`e' if `touse' & `ivar'==`i', noconstant
				matrix accum `XXt`i'' = d.`e' l.`e' l(`adflag2'/1)d.`e' if `touse' & `ivar'==`i', noconstant
				matrix `XX2`i'' = sweep(`XXt`i'',3) 
				local extra = 1
				while `extra' < `adflag2' {
				    local sweepnumber = 3 + `extra'
					matrix `XX2`i'' = sweep(`XX2`i'',`sweepnumber')
					local extra = `extra' + 1
				}
				scalar Nadf`i' = `XX2`i''[2,1]
				scalar Dadf`i' = `XX2`i''[2,2]
			}
			matrix `XX3`i'' = sweep(`XX2`i'',2)		
			local sstar`i' = `XX3`i''[1,1]/(`T4`i''-(`adflag'*2)-2)
			
			*! Lags for Bartlett Kernel
			if `mlags' < 0 {
				local mlags2 = round(4*(`T4`i''/100)^(2/9))
			}
			else {
				local mlags2 = `mlags'
			}

			*! Autoregressive of ehat to get uhat2
			regress `e`i'' L.`e`i'' if `touse' & `ivar'==`i', noconstant 
			predict double `utest`i'' if e(sample), resid 
			replace `utest' = `utest`i'' if `touse' & `ivar'==`i'
			
			*! Newey-West long run variance of uhat
			gen `gamutest`i'' = `utest`i'' * `utest`i'' if e(sample)
			sum `gamutest`i''
			local sumgamutest`i' = r(sum)
			local gamu0test`i' = `sumgamutest`i''/(`T4`i''-1)
			local lamutest`i' = `gamu0test`i''
			local l = 1
			while `l' <= `mlags2' {
				replace `gamutest`i'' = `utest`i''*L`l'.`utest`i'' if e(sample)
				sum `gamutest`i''
				local sumgamutest`i' = r(sum)
				local gamutest`l'`i' = `sumgamutest`i''/(`T4`i''-1)
				local factorutest`i' = 2*(1-`l'/(`mlags2'+1))
				local lamutest`i' = `lamutest`i'' + `factorutest`i''*`gamutest`l'`i''
				local l = `l'+1
			}
			
			*! Do regression on differences to get nhat
			regress depvar_diff_xtpedroni `difflist' if `touse' & `ivar'==`i', noconstant
			predict double `n`i'' if `touse' & `ivar'==`i', resid		
			replace `n' = `n`i'' if `touse' & `ivar'==`i'		
			
			*! Newey-West long run variance of nhat
			gen double `gamn`i'' = `n`i'' * `n`i'' if e(sample) 
			sum `gamn`i''
			local sumgamn`i' = r(sum)
			local gamn0`i' = `sumgamn`i''/(`T4`i''-1)
			local lamn`i' = `gamn0`i''
			local l = 1
			while `l' <= `mlags2' {
				replace `gamn`i'' = `n`i''*L`l'.`n`i'' if e(sample)
				sum `gamn`i''
				local sumgamn`i' = r(sum)
				local gamn`l'`i' = `sumgamn`i''/(`T4`i''-1)
				local factorn`i' = 2*(1-`l'/(`mlags2'+1))
				local lamn`i' = `lamn`i'' + `factorn`i''*`gamn`l'`i''
				local l = `l'+1
			}
			replace `l2' = `lamn`i'' if e(sample)
			
			*! Individual statistics used to calculate test statistics
			local lambda = 0.5*(`lamutest`i''-`gamu0test`i'')
			local sigma = `sigma' + (`lamutest`i''/`lamn`i'')
			replace `lede' = L1.`e' * d.`e' if `touse' & `ivar'==`i'
			summarize `lede' if `touse' & `ivar'==`i', meanonly
			local sumlede = r(sum)
			replace `le2' = L1.`e' * L1.`e' if `touse' & `ivar'==`i'
			summarize `le2' if `touse' & `ivar'==`i', meanonly
			local sumle2 = r(sum)
			local suml2e2 = `suml2e2' + ((`sumle2'/`lamn`i'')/((`T4`i'')^2))
			local suml2e2rho = `suml2e2rho' + (`sumle2'/`lamn`i'')
			local ledelambdarho = `ledelambdarho' + (((`sumlede' - (`lambda'*`T4`i''))/`lamn`i'')*(`T4`i''))
			local ledelambdat = `ledelambdat' + ((`sumlede' - (`lambda'*`T4`i''))/`lamn`i'')
			local rhodiv = `rhodiv' + (((`sumlede' - (`lambda'*`T4`i''))/`sumle2')*(`T4`i''))
			local tdiv = `tdiv' + ((`sumlede' - (`lambda'*`T4`i''))/sqrt(`sumle2'*`lamutest`i''))
			
			*! Individual statistics for adf tests
			local N3adf`i' = Nadf`i'/`lamn`i''
			local D3adf`i' = Dadf`i'/`lamn`i''
			local S3adf`i' = `sstar`i''/`lamn`i''
			local S3adf = `S3adf' + `S3adf`i''
			local N3adf = `N3adf' + `N3adf`i''
			local D3adf = `D3adf' + `D3adf`i''
			local adfdiv = `adfdiv' + `N3adf`i''/sqrt(`D3adf`i''*`S3adf`i'')
			
		}
		
	}
*! PART 3 of procedure: Calculate standardised group mean statistics, display the aggregate
*! panel results, and drop matrices.
	
	*! Cointegration test results
	if "`notest'" == "" {
	
		*! Calculating statistics
		scalar panelv = sqrt(`is'^3)/(`suml2e2')
		scalar panelrho = ((sqrt(`is'))*`ledelambdarho') /`suml2e2rho' 
		scalar sigmal2e2 = (`sigma'/`is')*`suml2e2rho'
		scalar panelt = `ledelambdat' / sqrt(sigmal2e2)
		scalar paneladf = `N3adf'/sqrt(`D3adf'*(`S3adf'/`is'))
		scalar grouprho = (`rhodiv')/sqrt(`is') 
		scalar groupt = `tdiv'/sqrt(`is') 
		scalar groupadf = `adfdiv'/sqrt(`is')
		
		*! Adjusting test statistics
		scalar panelvadj = (panelv - (`MEANadjustment'[`m',1] * sqrt(`is')))/sqrt(`VARIANCEadjustment'[`m',1])
		scalar panelrhoadj = (panelrho - (`MEANadjustment'[`m',2] * sqrt(`is')))/sqrt(`VARIANCEadjustment'[`m',2])
		scalar paneltadj = (panelt - (`MEANadjustment'[`m',3] * sqrt(`is')))/sqrt(`VARIANCEadjustment'[`m',3])
		scalar paneladfadj = (paneladf - (`MEANadjustment'[`m',3] * sqrt(`is')))/sqrt(`VARIANCEadjustment'[`m',3])
		scalar grouprhoadj = (grouprho - (`MEANadjustment'[`m',4] * sqrt(`is')))/sqrt(`VARIANCEadjustment'[`m',4])
		scalar grouptadj = (groupt - (`MEANadjustment'[`m',5] * sqrt(`is')))/sqrt(`VARIANCEadjustment'[`m',5])
		scalar groupadfadj = (groupadf - (`MEANadjustment'[`m',5] * sqrt(`is')))/sqrt(`VARIANCEadjustment'[`m',5])
		tempname resultstats
		matrix `resultstats' = ( panelvadj, . \ panelrhoadj, grouprhoadj \ paneltadj, grouptadj \ paneladfadj, groupadfadj )
		matrix colnames `resultstats' = Panel Group
		matrix rownames `resultstats' = v rho t adf
		*! Displaying Results
		foreach i of global iis {
			local Ttotal1 = `Ttotal1' + `T4`i''
		}
		local Tavg1 = round(`Ttotal1' / `is')
		
		di _newline
		di in gr "{bf:Pedroni's cointegration tests:}"
		di in gr "No. of Panel units: `is'" _col(30) "Regressors: `m'"
		di in gr "No. of obs.: `Ttotal1'" _col(30) "Avg obs. per unit: `Tavg1'"
		if "`notdum'" != "" {
			di in gr "Data has not been time-demeaned."
		}
		else {
			di in gr "Data has been time-demeaned."
		}
		if "`trend'" != ""{
			di in gr "A time trend has been included."
		}
		matlist `resultstats', border(rows) rowtitle(Test Stats.) left(4) twidth(14) format(%9.4g)
		di in gr "All test statistics are distributed N(0,1), under a null of no cointegration,"
		di in gr "and diverge to negative infinity (save for panel {it:v})."
	}
	
	*! PDOLS Results
	if "`nopdols'" == "" {
		
		*! Standardise the combined matrices
		if "`average'" == "sqrt" {
			matrix pdlbsum1 = inv(pdlhsum2)*pdlbsum2
			matrix pdlvsum1 = inv(pdlhsum2)*pdlvsum2*inv(pdlhsum2)
		}
		if "`average'" == "precision" {
			matrix pdlbsum1 = inv(pdlhsum3)*pdlbsum3
			matrix pdlvsum1 = inv(pdlhsum3)
		}
		else {
			matrix pdlbsum1 = (1/`is')*pdlbsum1
			matrix pdlvsum1 = ((1/`is')^2)*pdlvsum1
		}
		matrix pdltsum = (1/sqrt(`is'))*pdltsum
		matrix pdlmeanresults = pdlbsum1,pdltsum 

		*! Display results for group mean
		foreach i of global iis {
			local Ttotal = `Ttotal' + `Tused`i''
		}
		local Tavg = round(`Ttotal' / `is')
		matrix colnames pdlmeanresults = Beta t-stat
		di _newline
		di in gr "{bf:Pedroni's PDOLS (Group mean average):}"
		di in gr "No. of Panel units: `is'" _col(30) "Lags and leads: `lags'"
		di in gr "Number of obs: `Ttotal'" _col(30) "Avg obs. per unit: `Tavg'"
		if "`notdum'" != "" {
			di in gr "Data has not been time-demeaned."
		}
		else {
			di in gr "Data has been time-demeaned."
		}
		matlist pdlmeanresults, border(rows) rowtitle(Variables) left(4) twidth(14) format(%9.4g)
		
		*! Saving results to r()
			*! Saved matrices
			if "`nopdols'" == "" {
				return matrix b pdlbsum1
				return matrix V pdlvsum1
			}
			
			*! Saved scalars
			
	}
	
	*! Purge variables
	if "`notdum'" == "" {
		drop `tildelist'
	}
	drop depvar_diff_xtpedroni
	drop `difflist'
	drop `demeanlist'
	
end
