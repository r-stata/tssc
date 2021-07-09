*! runmlwin_mcmcdiag.ado, Chris Charlton and George Leckie, 19May2016
program runmlwin_mcmcdiag, rclass byable(recall)
	if _caller() >= 12 version 12.0
	if _caller() <= 9 version 9.0 

	#delimit ;
		syntax varlist [if] [in] [, 
		RLQUANT1(real 0.025) 
		RLQUANT2(real 0.975) 
		RLR(real 0.005) 
		RLS(real 0.95) 
		BDK(int 2) 
		BDAlpha(real 0.05) 
		KERNALPoints(int 1000) 
		MCSEPoints(int 1000)
		ACFPoints(int 100) 
		PACFPoints(int 10) 
		DELTA(real 0.001) 
		THINning(int 1)
		KSMOOth(real 1)
		MCSELl(real 0.5)
		MCSEUl(real 20)
		POSIT(int 0)
		PMean(real -9999)
		PVar(real -9999)
		Level(cilevel)
		Detail
		Eform
		* ];
	#delimit cr	
	
	tempname N
	quietly count `if' `in'
	scalar `N' = r(N)
	

	if "`detail'"=="" {
		//         1         2         3         4         5         6         7
		//1234567890123456789012345678901234567890123456789012345678901234567890123456789
		//-------------+-------------------------------------------------------------
		//   Parameter |       N       Mean  Std. Dev.      ESS  [95% Cred. Interval]
		//-------------+-------------------------------------------------------------
		//   parameter | #######  #########  #########  #######  #########  #########

		display _n(1)
		local c = length("`level'")
		display ///
			as txt _col(4) "Parameter" ///
			as txt _col(14) "{c |}" ///
			as txt _col(22) "N" ///
			as txt _col(30) "Mean" ///
			as txt _col(37) "Std. Dev." ///
			as txt _col(51) "ESS" ///
			as txt _col(`=58 -`c'') `"[`=strsubdp("`level'")'% Cred. Interval]"'	
		display as txt "{hline 13}{c +}{hline 61}"	
	}
	
	foreach parameter of local varlist {
	
		tempname mean
		scalar `mean' = .
		tempname sd
		scalar `sd' = .
		tempname mode
		scalar `mode' = .

		tempname quantiles
		local numquants = 11
		matrix `quantiles' = J(`numquants', 2, .)



		mat `quantiles'[1,1]   = .005 //  0.5%
		mat `quantiles'[2,1]   = .025 //  2.5%
		mat `quantiles'[3,1]   = .05  //    5%
		mat `quantiles'[4,1]   = .25  //  2.5%
		mat `quantiles'[5,1]   = .5   //   50%
		mat `quantiles'[6,1]   = .75  //   95%
		mat `quantiles'[7,1]   = .95  //   95%
		mat `quantiles'[8,1]   = .975 // 97.5%
		mat `quantiles'[9,1]   = .995 // 99.5%
		mat `quantiles'[10,1]  = .01*((100 - `level')/2)  // lb
		mat `quantiles'[11,1]  = .01*(100 - (100 - `level')/2) // ub

		tempname ESS
		scalar `ESS' = .	

		tempname RL1 // Raftery-Lewis Nhat1
		scalar `RL1' = .
		tempname RL2 // Raftery-Lewis Nhat2
		scalar `RL2' = .

		tempname BD // Brooks-Draper Nhat
		scalar `BD' = .

		tempname MEANMCSE // Brooks-Draper Nhat
		scalar `MEANMCSE' = .	

		tempname KD
		if `kernalpoints' > 0 {
			mata: st_matrix("`KD'", J(`kernalpoints',2,.))
		}

		tempname PRIOR
		if `kernalpoints' > 0 {
				mata: st_matrix("`PRIOR'", J(`kernalpoints',2,.))
		}
		

		tempname MCSE
		if `mcsepoints' > 0 {
			mata: st_matrix("`MCSE'", J(`mcsepoints',2,.))
		}

		tempname ACF
		if `acfpoints' > 0 {
			mata: st_matrix("`ACF'", J(`acfpoints',2,.))
		}

		tempname PACF
		if `pacfpoints' > 0 {
			mata: st_matrix("`PACF'", J(`pacfpoints',2,.))
		}

		// Do calculations
		plugin call runmlwin_mcmcdiagnostics `parameter' `if' `in', "`mean'" "`sd'" "`mode'" "`quantiles'" "`ESS'" "`RL1'" "`RL2'" "`BD'" "`KD'" "`MCSE'" "`ACF'" "`PACF'" "`MEANMCSE'" "`PRIOR'"

		
		local lb = `quantiles'[10,2]
		local ub = `quantiles'[11,2]
		
		matrix `quantiles' = `quantiles'[1..9,.]
		
		if "`detail'"~="" {
			//         1         2         3         4         5         6         7
			//1234567890123456789012345678901234567890123456789012345678901234567890123456789
			//-------------+-------------------------------------------------------------
			//   Parameter |       N       Mean  Std. Dev.      ESS  [95% Cred. Interval]
			//-------------+-------------------------------------------------------------
			//   parameter | #######  #########  #########   ######  #########  #########


			display _n(1) as res "`parameter'"
			display "-------------------------------------------------------------"
			display as text "Raftery-Lewis (quantile): Nhat = (" as result `RL1' as text "," as result `RL2' as text ")"
			display as text "when q = (`rlquant1', `rlquant2'), r = `rlr' and s = `rls'"
			display as text "Brooks-Draper (mean): Nhat = " as result `BD'
			display as text "when k = `bdk' and alpha = `bdalpha'"
			display as text "Column: `parameter', posterior mean = " as result `mean' as text "(" as result `MEANMCSE' as text ") SD = " as result `sd' as text " mode = " as result `mode'
			display as text "Quantiles:"
			forvalues i = 1/`numquants' {
				display as text `quantiles'[`i', 1]  as result _col(10) `quantiles'[`i', 2] 
			}
			display as text "`=_N * `thinning'' actual iterations. Effective Sample Size (ESS) = " as result `ESS'
		}
		else {
		
			local parname `=abbrev("`parameter'", 12)'
		
			local p = 13 - length("`parname'")
			display ///
				as txt _col(`p') "`parname'" ///
				as txt _col(14) "{c |}" ///
				as res _col(16) %7.0g `N' ///
				as res _col(25) %9.0g `mean' ///
				as res _col(36) %9.0g `sd' ///
				as res _col(48) %6.0g `ESS' ///
				as res _col(56) %9.0g `lb' ///
				as res _col(67) %9.0g `ub'
				local r = `r' + 1
			
		}
		
		local compval 0
		if "`eform'" ~= "" {
			local compval 1
		}
		
		if `mean' > `compval' {
			quietly count if `parameter' < `compval'
		}
		else {
			quietly count if `parameter' > `compval'
		}		
		local pvalmean = r(N) / `N'	
		
		if `kernalpoints' > `compval' {
			if `mode' > 0 {
				quietly count if `parameter' < `compval'
			}
			else {
				quietly count if `parameter' > `compval'
			}		
			local pvalmode = r(N) / `N'			
		}
		
		if `quantiles'[5, 2] > `compval' { // NOTE: This assumes this is always 50%
			quietly count if `parameter' < `compval'
		}
		else {
			quietly count if `parameter' > `compval'
		}		
		local pvalmedian = r(N) / `N'			
		
		return clear
		return scalar N = `N'
		return scalar mean = `mean'
		return scalar sd = `sd'
		return scalar lb = `lb'
		return scalar ub = `ub'
		return matrix quantiles = `quantiles'
		return scalar RL1 = `RL1'
		return scalar RL2 = `RL2'
		return scalar pvalmean = `pvalmean'
		return scalar pvalmedian = `pvalmedian'

		if `kernalpoints' > 0 {
			return matrix KD = `KD'
			if ("`pmean'" != "-9999" & "`pvar'" != "-9999") return matrix prior = `PRIOR'
			return scalar mode = `mode'
			return scalar pvalmode = `pvalmode'
		}
		if `acfpoints' > 0 {
			return matrix ACF = `ACF'
			return scalar ESS = `ESS'
			return scalar BD = `BD'
			if `mcsepoints' > 0 {
				return matrix MCSE = `MCSE'
				return scalar meanmcse = `MEANMCSE'
			}
			if `pacfpoints' > 0 {
				return matrix PACF = `PACF'
			}
		}
	}

end

program runmlwin_mcmcdiagnostics, plugin

******************************************************************************
exit
