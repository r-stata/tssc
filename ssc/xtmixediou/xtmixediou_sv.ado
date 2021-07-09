* svdata DERIVES PARAMETER ESTIMATES BASED ON THE VARIANCE OF RESIDUALS GENERATED USING regress
* RETURNS A ROW VECTOR OF STARTING VALUES 
	* sv_thetastar = (vech(logcholGstar)',aLpha,taustar)

*! xtmixediou_sv: V2; Rachael Hughes; 26th June 2017; generates starting values for xtmixediou
capture program drop xtmixediou_sv
program xtmixediou_sv, rclass
	version 11
	args y fevars reffects id time svmethod Rparameterization
	
	tempname sv_G sv_Wvalues sv_Wstarvalues sv_Gstar sv_cholGstar sv_theta sv_thetastar 
	
	quietly svmethod`svmethod' `y' "`fevars'" "`reffects'" "`id'" "`time'" `Rparameterization'
	local sv_sigma = r(sv_sigma)
	matrix `sv_G' = r(sv_G)
	matrix `sv_Wvalues' = r(sv_Wvalues)
	matrix `sv_Wstarvalues' = r(sv_Wstarvalues)
	
	* IF G IS POSITIVE DEFINITE THEN SO TO IS (1/sigma^2)*:G
	mata: interfacePD("`sv_G'")
	local isPositiveDefinite = r(isPositiveDefinite)
	if `isPositiveDefinite' == -1 {	// MISSING ENTRIES	
		di as error "Starting values of RE covariance matrix contains one or more missing values"
		error 504
	}
	matrix `sv_G' = r(pdMatrix)		// UNCHANGED IF ORIGINAL sv_G IS PD
	matrix `sv_Gstar' = (1/(`sv_sigma'^2))*`sv_G'
	matrix `sv_cholGstar' = cholesky(`sv_Gstar')

	local numRE: list sizeof reffects
	forvalues row=1(1)`numRE' {
		matrix `sv_theta' = (nullmat(`sv_theta'),`sv_G'[`row',`row'])
		matrix `sv_thetastar' = (nullmat(`sv_thetastar'),log(`sv_cholGstar'[`row',`row']))
		
		local rowplus1 = `row' + 1
		forvalues column=`rowplus1'(1)`numRE' {
			matrix `sv_theta' = (nullmat(`sv_theta'),`sv_G'[`row',`column'])
			matrix `sv_thetastar' = (nullmat(`sv_thetastar'),`sv_cholGstar'[`row',`column'])
		}
	}
	matrix `sv_theta' = (`sv_theta',`sv_Wvalues',`sv_sigma')
	matrix `sv_thetastar' = (`sv_thetastar',`sv_Wstarvalues')	
	
	return matrix sv_theta `sv_theta'	
	return matrix sv_thetastar `sv_thetastar'	
end

capture program drop svmethod1
program svmethod1, rclass
	version 11
	args y fevars reffects id time Rparameterization

	tempname e_b sv_G sv_Wvalues sv_Wstarvalues

	capture noisily xtmixed `y' `fevars', noconstant || `id': `reffects', noconstant emonly reml var covariance(unstructured) 
	local rc _rc 
	if `rc'!=0 {
		di as error "Starting values method 1: EM estimation using xtmixed has failed"
		error `rc'
	}	
	
capture {	
	* DERIVE G AND sigma
	local numFE = e(k_f)
	local numParameters = e(k)	
	local numRE: list sizeof reffects
	matrix `e_b' = e(b) 
	local entry = `numFE'+`numRE'

	local sv_sigma = exp(`e_b'[1,`numParameters'])	
	
	matrix `sv_G' = J(`numRE',`numRE',0)
	forvalues row=1(1)`numRE' {
		matrix `sv_G'[`row',`row'] = exp(2*`e_b'[1,`numFE'+`row'])

		local rowplus1 = `row'+1
		forvalues column=`rowplus1'(1)`numRE' {
			local entry = `entry' + 1
			matrix `sv_G'[`row',`column'] = (tanh(`e_b'[1,`entry'])*exp(`e_b'[1,`numFE'+`row'])*exp(`e_b'[1,`numFE'+`column']))
			matrix `sv_G'[`column',`row'] = `sv_G'[`row',`column']
		}		
	}
	if `Rparameterization' >=8 {	// BROWNIAN-MOTION	
		local phi 0.001
		matrix `sv_Wvalues' = (`phi')
		matrix `sv_Wstarvalues' = (`phi'/`sv_sigma'^2)
	}
	else {							// IOU
		matrix `sv_Wvalues' = (1,0.01)	// i.e., omega = 0.1
		matrix `sv_Wstarvalues' = (1,0.01/`sv_sigma')
	}	
} // END OF capture
	
	local rc _rc 
	if `rc'!=0 {
		di as error "Starting values method 1: Error when retrieving variance parameters from Stata RE covariance matrix and sigma"
		error `rc'
	}	
	
	return local sv_sigma `sv_sigma'
	return matrix sv_G `sv_G'
	return matrix sv_Wvalues `sv_Wvalues'
	return matrix sv_Wstarvalues `sv_Wstarvalues'
end	

capture program drop svmethod2
program svmethod2, rclass
	version 11
	args y fevars reffects id time Rparameterization

	tempname obs sv_G sv_Wvalues sv_Wstarvalues
	tempvar residuals record time1 time2 timediff targetTime obsvar varhat obsvar obstime obscov1t
	tempfile initial temporary
	
	quietly save `initial', replace
	
	// IS THE RANDOM INTERCEPT SPECIFIED FIRST OR LAST 
	local RIposition 1
	foreach var of local reffects {
		quietly summarize `var'
		if r(sd) == 0 continue, break
		
		local RIposition = `RIposition' + 1
	} 
	di "Random intercept is effect number `RIposition'"
	
	// TWO RANDOM EFFECTS SPECIFIED AND ONE OF THEM IS NOT A RANDOM INTERCET
	if `RIposition' == 3 {
		di as error "option svdataderived requires a random intercept and/or a random linear slope"
		exit(198)
	}
	
	if `Rparameterization' >=8 {
		local svstring "sv2_BM"
	}
	else {
		local svstring "sv2_IOU"
	}
		
	local numRE : list sizeof reffects
	if `numRE' == 1 {
		if `RIposition' == 1 local svstring = "`svstring'" + "_ri `obsvar' `obstime' `obscov1t'"
		else { 	// ONE RANDOM EFFECT SPECIFIED AND IT IS NOT A RANDOM INTERCEPT NOR A RANDOM LINEAR SLOPE
			if "`reffects'" != "`time'" {
				di as error "option svdataderived requires a random intercept and/or a random linear slope"
				exit(198)
			}
			local svstring = "`svstring'" + "_rs `obsvar' `obstime'"			
		}	
	}
	else { // `numRE' == 2
		if `numRE'-`RIposition' == 1 local REslope = word("`reffects'",2)	// "intercept slope"
		else local REslope = word("`reffects'",1)	// "slope intercept"
	
		// TWO RANDOM EFFECTS SPECIFIED BUT DOES NOT INCLUDE A RANDOM LINEAR SLOPE
		if "`REslope'" != "`time'" {
			di as error "option svdataderived requires a random intercept and/or a random linear slope"
			exit(198)
		}
		local svstring = "`svstring'" + "_un `obsvar' `obstime' `obscov1t' `RIposition'"
	}
		
	/********************************************************************
	  DETERMINE THE MEDIAN TIME INTERVAL BETWEEN CONSECUTIVE MEASUREMENTS
	*********************************************************************/
quietly {
	sort `id' `time', stable
	egen `record' = seq(), by(`id')
	rename `time' `time1'
	keep `id' `record' `time1'
	save `temporary', replace
	
	quietly drop if `record'==1
	drop `record'
	sort `id' `time1', stable
	quietly egen `record' = seq(), by(`id')
	rename `time1' `time2'
	
	quietly merge 1:1 `id' `record' using `temporary'
	gen `timediff' = `time2' - `time1'
	quietly summarize `timediff', detail
	local medianInterval = r(p50)
	
	// ROUND MEDIAN INTERVAL TO 2 SIGNIFICANT PLACES
	local numSF 2
	local t = ceil(log10(`medianInterval')) - `numSF'
	local rounding = 10^`t'
	local interval = round(`medianInterval', `rounding')
	di as text "The median interval is `interval'"

	/**********************************************************************
	 OBTAIN THE RESIDUALS 
	 LOOK AT THE VARIANCE STRUCTURE AFTER ACCOUNTING FOR THE MEAN STRUCTURE  
	***********************************************************************/
	quietly use `initial', clear
	capture regress `y' `fevars', nocons
	local rc _rc 
	if `rc'!=0 {
		di as error "Starting values method 2: obtaining residuals using regress has failed"
		error `rc'
	}	
	predict `residuals', residuals
	
	/*************************
	  RETANGULARIZE THE DATA
	*************************/
	sort `id' `time'

	keep `residuals' `id' `time'
	gen `record' = round(`time'/`interval')
	drop if `record' < 0
	
	drop if `residuals'==.
	drop if `time'==.
	
	duplicates drop `id' `record', force
	
	save `temporary', replace
	
	collapse (count)`residuals', by(`record')
	
	* DROP ANY RECORDS WITH LESS THAN 25 PATIENTS
	drop if `residuals' < 25
	
	quietly count
	local numrecords = r(N)
	di as text "The number of records is `numrecords'"
	
	drop `residuals'
	quietly merge 1:m `record' using `temporary'
	quietly keep if _merge==3
	drop _merge
	
	summarize `record'
	local min_ni = r(min)
	local max_ni = r(max)
	di as text "The first record is `min_ni' and the last record is `max_ni'"
	
	reshape wide `residuals' `time', i(`id') j(`record')
	
	/***********************************
	  CALCULATE MEANS AND CORRELATIONS
	************************************/
	matrix `obs' = J(`numrecords',3,.)
	
	local row 0
	forvalues t=`min_ni'(1)`max_ni' {
		*di "t=`t'"
		quietly summarize `residuals'`t'
		if r(N) > 0 { 
			local row = `row' + 1
			matrix `obs'[`row',1] = r(Var)
			quietly summarize `time'`t'
			matrix `obs'[`row',2] = r(mean)
			capture correlate `residuals'`min_ni' `residuals'`t', cov
			if _rc==0 matrix `obs'[`row',3] = r(cov_12)
		}
	}
	
	quietly clear
	quietly svmat `obs'
	rename `obs'1 `obsvar'
	rename `obs'2 `obstime'
	rename `obs'3 `obscov1t'
	quietly replace `obscov1t' = . in 1

}	// END OF QUIETLY

	/**************************************************
	  DERIVE STARTING VALUES BASED ON MINIMIZING ESS
	**************************************************/
	`svstring'
	
	matrix `sv_G' = r(sv_G)	
	matrix `sv_Wvalues' = r(sv_Wvalues)	
	matrix `sv_Wstarvalues' = r(sv_Wstarvalues)	
	local sv_sigma = r(sv_sigma)
	
	return local sv_sigma `sv_sigma'
	return matrix sv_G `sv_G'
	return matrix sv_Wvalues `sv_Wvalues'
	return matrix sv_Wstarvalues `sv_Wstarvalues'
end	

// ASSUMES RANDOM CONSTANT ONLY AND IOU
capture program drop sv2_IOU_ri
program sv2_IOU_ri, rclass
	args obsvar obstime obscov1t

	version 11
	
	tempname alphaValues omegaValues gammaValues sigmaSqValues sum_ess G Wvalues Wstarvalues	
	tempvar varhat ess exp_time_1 exp_obstime gammahat sigmaSqhat row 

	local obsvar_1 = `obsvar' in 1
	local time_1 = `obstime' in 1
	
	quietly gen `varhat' = .
	quietly gen `ess' = .
	quietly gen `exp_time_1' = .
	quietly gen `exp_obstime' = .
	quietly gen `gammahat' = .
	quietly gen `sigmaSqhat' = .
	matrix `alphaValues' = (1\2\3\4\5\10\15\20)  
	local finish = rowsof(`alphaValues')
	matrix `omegaValues' = J(`finish',1,.)
	matrix `gammaValues' = J(`finish',1,.)
	matrix `sigmaSqValues' = J(`finish',1,.)
	matrix `sum_ess' = J(`finish',1,.)
	
	forvalues j=1(1)`finish' {
		local alphahat = `alphaValues'[`j',1]
	
		quietly replace `exp_time_1' = exp(-`alphahat'*`time_1')
		quietly replace `exp_obstime' = exp(-`alphahat'*`obstime')
		
		// exp_absdiff DROPPED DUE TO COLLINEARITY
			// gen exp_absdiff = exp(-20.7*(abs(obstime-`time_1')))
		quietly regress `obsvar' `obstime' `exp_obstime'
		local omegahat = abs(_b[`obstime'])
		matrix `omegaValues'[`j',1] = `omegahat'
		
		// varhat = obsVar[time_1] + estimated Var[time] - estimated Var[time_1]
		quietly replace `varhat' = `obsvar_1' + `omegahat'*(`obstime'-`time_1') + (`omegahat'/`alphahat')*(`exp_obstime'-`exp_time_1')
		quietly replace `ess' = (`varhat'-`obsvar')^2
		quietly summarize `ess'
		matrix `sum_ess'[`j',1] = r(sum)
		
		// gammahat = obscov1t - IOUcov[time,time_1]
		quietly replace `gammahat' = `obscov1t' - /// 
			(`omegahat'/(2*`alphahat'))*(2*`alphahat'*`time_1' + `exp_time_1' + `exp_obstime' - 1 - exp(-`alphahat'*abs(`obstime'-`time_1')))
		quietly summarize `gammahat', detail
		local ave_gammahat = abs(r(p50))
		matrix `gammaValues'[`j',1] = `ave_gammahat'
		
		// sigmaSqhat = obsvar - gammahat - IOUvar[time]
		quietly replace `sigmaSqhat' = abs(`obsvar' - ///
		              `ave_gammahat' - (`omegahat'/`alphahat')*(`alphahat'*`obstime' + `exp_obstime' - 1))
		quietly summarize `sigmaSqhat', detail
		local ave_sigmaSqhat = abs(r(p50))
		matrix `sigmaSqValues'[`j',1] = `ave_sigmaSqhat'
	}
	
	quietly clear
	quietly svmat `sum_ess'	
	quietly svmat `alphaValues'
	quietly svmat `omegaValues'
	quietly svmat `gammaValues'
	quietly svmat `sigmaSqValues'
	
	egen `row' = seq()
	quietly summarize `sum_ess'
	quietly summarize `row' if `sum_ess'==r(min), detail
	local selectedRow = r(min)
	local gamma = `gammaValues' in `selectedRow'
	local aLpha = `alphaValues' in `selectedRow'
	local omega = `omegaValues' in `selectedRow'
	local tau = sqrt(`omega')*`aLpha'
	local sigmaSq = `sigmaSqValues' in `selectedRow'
	local sigma = sqrt(`sigmaSq')
	
	di "gamma is " %4.3f `gamma' "; alpha is " %4.3f `aLpha' "; omega is " %4.3f `omega' "; sigma is " %4.3f `sigma'
	
	matrix `G' = (`gamma')
	matrix `Wvalues' = (`aLpha',`tau')
	matrix `Wstarvalues' = (`aLpha',`tau'/`sigma')
	
	return matrix sv_G `G'
	return matrix sv_Wvalues `Wvalues'
	return matrix sv_Wstarvalues `Wstarvalues'
	return local sv_sigma `sigma'
end

// ASSUMES RANDOM CONSTANT ONLY AND BROWNIAN MOTION
capture program drop sv2_BM_ri
program sv2_BM_ri, rclass
	args obsvar obstime obscov1t

	version 11
	
	tempname G Wvalues Wstarvalues
	tempvar gammavalues sigmaSqvalues 
	
	* ESTIMATE phihat
    quietly regress `obsvar' `obstime'
	local phihat = abs(_b[`obstime'])
	
	* ESTIMATE gammahat
		* gammahat = obscov1t - phihat*time_1
	local time_1 = `obstime' in 1
	quietly gen `gammavalues' = `obscov1t' - `phihat'*`time_1'
	quietly summarize `gammavalues', detail
	local gammahat = abs(r(p50))
	
	* sigmaSqhat = obsvar - gammahat - phihat*obstime
	quietly gen `sigmaSqvalues' = `obsvar' - `gammahat' - `phihat'*`obstime'
	quietly summarize `sigmaSqvalues', detail
	local sigmaSqhat = abs(r(p50))
	local sigmahat = sqrt(`sigmaSqhat')

	di "gamma is " %4.3f `gammahat' "; phi is " %4.3f `phihat' "; sigma is " %4.3f `sigmahat'
	
	matrix `G' = (`gammahat')
	matrix `Wvalues' = (`phihat')
	matrix `Wstarvalues' = (`phihat'/`sigmaSqhat')
	
	return matrix sv_G `G'
	return matrix sv_Wvalues `Wvalues'
	return matrix sv_Wstarvalues `Wstarvalues'
	return local sv_sigma `sigmahat'
end	

// ASSUMES RANDOM SLOPE AND IOU
capture program drop sv2_IOU_rs
program sv2_IOU_rs, rclass
	args obsvar obstime

	version 11
	
	tempname sum_ess gammaValues sigmaSqValues G Wvalues Wstarvalues alphaValues omegaValues 
	tempvar varhat ess obstimeSquared exp_time_1 exp_obstime row sigmaSqhat 
	
	local obsvar_1 = `obsvar' in 1
	local time_1 = `obstime' in 1
	quietly gen `varhat' = .
	quietly gen `ess' = .
	quietly gen `obstimeSquared' = `obstime'^2
	quietly gen `exp_time_1' = .
	quietly gen `exp_obstime' = .
	quietly gen `sigmaSqhat' = .
	
	matrix `alphaValues' = (1\2\3\4\5\10\15\20)   
	local finish = rowsof(`alphaValues')
	matrix `sum_ess' = J(`finish',1,.)
	matrix `omegaValues' = J(`finish',1,.)
	matrix `gammaValues' = J(`finish',1,.)
	matrix `sigmaSqValues' = J(`finish',1,.)
	forvalues j=1(1)`finish' {
		local alphahat = `alphaValues'[`j',1]
	
		quietly replace `exp_time_1' = exp(-`alphahat'*`time_1')
		quietly replace `exp_obstime' = exp(-`alphahat'*`obstime')
		
		// exp_absdiff DROPPED DUE TO COLLINEARITY
			// gen exp_absdiff = exp(-20.7*(abs(obstime-`time_1')))
		quietly regress `obsvar' `obstime' `obstimeSquared' `exp_obstime'
		local gammahat = abs(_b[`obstimeSquared'])
		matrix `gammaValues'[`j',1] = `gammahat'
		local omegahat = abs(_b[`obstime'])
		matrix `omegaValues'[`j',1] = `omegahat'
		
		// varhat = obsVar[time_1] + estimated Var[time] - estimated Var[time_1]
		quietly replace `varhat' = `obsvar_1' + `gammahat'*(`obstimeSquared'-`time_1'^2)  + `omegahat'*(`obstime'-`time_1') ///
		    				       + (`omegahat'/`alphahat')*(`exp_obstime'-`exp_time_1')
		quietly replace `ess' = (`varhat'-`obsvar')^2
		quietly summarize `ess'
		matrix `sum_ess'[`j',1] = r(sum)

		// sigmaSqhat = obsvar - gammahat*time^2 - IOUvar[time]
		quietly replace `sigmaSqhat' = `obsvar' - `gammahat'*`obstimeSquared' - ///
		                               (`omegahat'/`alphahat')*(`alphahat'*`obstime' + `exp_obstime' - 1)
		quietly summarize `sigmaSqhat', detail
		local ave_sigmaSqhat = abs(r(p50))
		matrix `sigmaSqValues'[`j',1] = `ave_sigmaSqhat'
	}

	quietly clear
	quietly svmat `sum_ess'	
	quietly svmat `alphaValues'
	quietly svmat `omegaValues'
	quietly svmat `gammaValues'
	quietly svmat `sigmaSqValues'
	
	egen `row' = seq()
	quietly summarize `sum_ess'
	quietly summarize `row' if `sum_ess'==r(min), detail
	local selectedRow = r(min)
	local gamma = `gammaValues' in `selectedRow'
	local aLpha = `alphaValues' in `selectedRow'
	local omega = `omegaValues' in `selectedRow'
	local tau = sqrt(`omega')*`aLpha'
	local sigmaSq = `sigmaSqValues' in `selectedRow'
	local sigma = sqrt(`sigmaSq')
	
	di "gamma is " %4.3f `gamma' "; alpha is " %4.3f `aLpha' "; omega is " %4.3f `omega' "; sigma is " %4.3f `sigma'
	
	matrix `G' = (`gamma')
	matrix `Wvalues' = (`aLpha',`tau')
	matrix `Wstarvalues' = (`aLpha',`tau'/`sigma')
	
	return matrix sv_G `G'
	return matrix sv_Wvalues `Wvalues'
	return matrix sv_Wstarvalues `Wstarvalues'	
	return local sv_sigma `sigma'
end	

// ASSUMES RANDOM SLOPE AND BROWNIAN-MOTION
capture program drop sv2_BM_rs
program sv2_BM_rs, rclass
	args obsvar obstime

	version 11
	
	tempname G Wvalues Wstarvalues
	tempvar obstimeSquared sigmaSqvalues   
	
	quietly gen `obstimeSquared' = `obstime'^2
	
	* obsvar = gammahat*timeSquared + phi*time + sigmaSquared
	quietly regress `obsvar' `obstimeSquared' `obstime'
	local gammahat = abs(_b[`obstimeSquared'])
	local phihat = abs(_b[`obstime'])
	
	* sigmaSqhat = obsvar - gammahat*obstimeSquared - phihat*obstime
	quietly gen `sigmaSqvalues' = `obsvar' - `gammahat'*`obstimeSquared' - `phihat'*`obstime'
	quietly summarize `sigmaSqvalues', detail
	local sigmaSqhat = abs(r(p50))
	local sigmahat = sqrt(`sigmaSqhat')

	di "gamma is " %4.3f `gammahat' "; phi is " %4.3f `phihat' "; sigma is " %4.3f `sigmahat'
	
	matrix `G' = (`gammahat')
	matrix `Wvalues' = (`phihat')
	matrix `Wstarvalues' = (`phihat'/`sigmaSqhat')
	
	return matrix sv_G `G'
	return matrix sv_Wvalues `Wvalues'
	return matrix sv_Wstarvalues `Wstarvalues'
	return local sv_sigma `sigmahat'
end	

* ASSUMES A RANDOM INTERCEPT, RANDOM SLOPE AND IOU
capture program drop sv2_IOU_un
program sv2_IOU_un, rclass
	args obsvar obstime obscov1t RIposition

	version 11
	
	tempname gamma1Values gamma2Values gamma3Values sigmaSqValues sum_ess G Wvalues Wstarvalues alphaOmegaValues
	tempvar obstimeSquared varhat exp_obstime exp_time_1 ess row sigmaSqhat gamma1hat alphaValues omegaValues
	
	quietly gen `obstimeSquared' = `obstime'^2	
	
	local obsvar_1 = `obsvar' in 1
	local time_1 = `obstime' in 1
	quietly gen `varhat' = .
	quietly gen `ess' = .
	quietly gen `exp_time_1' = .
	quietly gen `exp_obstime' = .
	quietly gen `gamma1hat' = .
	quietly gen `sigmaSqhat' = .
	foreach aLpha of numlist 1 2 3 4 5 10 15 20 {
		foreach omega of numlist 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 {
			matrix `alphaOmegaValues' = (nullmat(`alphaOmegaValues')\ `aLpha', `omega')
		}
	}
	local end = rowsof(`alphaOmegaValues')
	matrix `sum_ess' = J(`end',1,.)
	matrix `gamma1Values' = J(`end',1,.)
	matrix `gamma2Values' = J(`end',1,.)
	matrix `gamma3Values' = J(`end',1,.)
	matrix `sigmaSqValues' = J(`end',1,.)
	forvalues j=1(1)`end' {
		local alphahat = `alphaOmegaValues'[`j',1]
		local omegahat = `alphaOmegaValues'[`j',2]
		quietly replace `exp_time_1' = exp(-`alphahat'*`time_1')
		quietly replace `exp_obstime' = exp(-`alphahat'*`obstime')
	
		// exp_absdiff DROPPED DUE TO COLLINEARITY
			// gen exp_absdiff = exp(-20.7*(abs(obstime-`time_1')))
		quietly regress `obsvar' `obstimeSquared' `obstime' `exp_obstime'
		local gamma3hat = abs(_b[`obstimeSquared'])
		matrix `gamma3Values'[`j',1] = `gamma3hat'
		
		// exp_absdiff DROPPED DUE TO COLLINEARITY
		quietly regress `obscov1t' `obstime' `exp_obstime'
		local gamma2hat = _b[`obstime'] - `time_1'*`gamma3hat'
		matrix `gamma2Values'[`j',1] = `gamma2hat'
		
		// varhat = obsVar[time_1] + estimated Var[time] - estimated Var[time_1]
			// estimated Var[time] = gamma1 + 2*time*gamma2 + time*time*gamma3 + IOUvar[time] + sigmaSq 
		quietly replace `varhat' = `obsvar_1' + (2*`gamma2hat' + `omegahat')*(`obstime'-`time_1') + `gamma3hat'*(`obstimeSquared'-`time_1'^2) + (`omegahat'/`alphahat')*(`exp_obstime' - exp(-`alphahat'*`time_1'))
		quietly replace `ess' = (`varhat'-`obsvar')^2
		quietly summarize `ess'
		matrix `sum_ess'[`j',1] = r(sum)

		// gamma1hat = obscov1t - IOUcov[time,time_1]
		quietly replace `gamma1hat' = `obscov1t' - `gamma2hat'*(`time_1' + `obstime') - `gamma3hat'*`time_1'*`obstime' - ///                     
										 (`omegahat'/(2*`alphahat'))*(2*`alphahat'*`time_1' + `exp_time_1' + `exp_obstime' - 1 - exp(-`alphahat'*abs(`obstime'-`time_1')))
		quietly summarize `gamma1hat', detail
		local ave_gamma1hat = abs(r(p50))
		matrix `gamma1Values'[`j',1] = `ave_gamma1hat'
		
		// sigmaSqhat = obsvar - gamma3hat*time^2 -2*gamma2hat*time - gamma1hat - IOUvar[time]
		quietly replace `sigmaSqhat' = `obsvar' - `ave_gamma1hat' - 2*`gamma2hat'*`obstime' - `gamma3hat'*`obstimeSquared' - ///		
									  (`omegahat'/`alphahat')*(`alphahat'*`obstime' + `exp_obstime' - 1)
		quietly summarize `sigmaSqhat', detail
		local ave_sigmaSqhat = abs(r(p50))
		matrix `sigmaSqValues'[`j',1] = `ave_sigmaSqhat'
	}

	quietly clear
	quietly svmat `sum_ess'	
	quietly svmat `alphaOmegaValues'
	rename `alphaOmegaValues'1 `alphaValues'
	rename `alphaOmegaValues'2 `omegaValues'
	quietly svmat `gamma1Values'
	quietly svmat `gamma2Values'
	quietly svmat `gamma3Values'
	quietly svmat `sigmaSqValues'
		
	quietly egen `row' = seq()
	quietly summarize `sum_ess'
	quietly summarize `row' if `sum_ess'==r(min), detail
	local selectedRow = r(min)
	local gamma1 = `gamma1Values' in `selectedRow'
	local gamma2 = `gamma2Values' in `selectedRow'
	local gamma3 = `gamma3Values' in `selectedRow'
	if `RIposition'==1 {	// INTERCEPT WAS SPECIFIED FIRST
		matrix `G' = (`gamma1',`gamma2' \ `gamma2',`gamma3') 
	}
	else {
		matrix `G' = (`gamma3',`gamma2' \ `gamma2',`gamma1') 
	}
	local aLpha = `alphaValues' in `selectedRow'
	local omega = `omegaValues' in `selectedRow'
	local tau = sqrt(`omega')*`aLpha'
	local sigmaSq = `sigmaSqValues' in `selectedRow'
	local sigma = sqrt(`sigmaSq')
	
	di "gamma1 is " %4.3f `gamma1' "; gamma2 is " %4.3f `gamma2' "; gamma3 is " %4.3f `gamma3' "; alpha is " %4.3f `aLpha' "; omega is " %4.3f `omega' "; sigma is " %4.3f `sigma'
	
	matrix `Wvalues' = (`aLpha',`tau')	
	matrix `Wstarvalues' = (`aLpha',`tau'/`sigma')
	
	return matrix sv_G `G'
	return matrix sv_Wvalues `Wvalues'
	return matrix sv_Wstarvalues `Wstarvalues'
	return local sv_sigma `sigma'
end	

* ASSUMES A RANDOM INTERCEPT, RANDOM SLOPE AND BROWNIAN MOTION
capture program drop sv2_BM_un
program sv2_BM_un, rclass
	args obsvar obstime obscov1t RIposition

	version 11
	
	tempname G Wvalues Wstarvalues
	tempvar obstimeSquared gamma1values sigmaSqvalues 
	
	quietly gen `obstimeSquared' = `obstime'^2	
	local obstime_1 = `obstime' in 1

	* varhat = gamma1hat + 2*gamma2hat*time + gamma3hat*timeSquared + phi*time + sigmaSquared
	quietly regress `obsvar' `obstimeSquared' `obstime'
	local gamma3hat = abs(_b[`obstimeSquared'])
	local A = _b[`obstime']				// A = 2*gamma2hat + phi	

	* cov1t = gamma1hat + gamma2hat*(time+time_1) + gamma3hat*time*time_1 + phihat*time_1
	*       = constant + (gamma2hat + gamma3hat*time_1)*time
	quietly regress `obscov1t' `obstime'
	local B = _b[`obstime']				// B = gamma2hat + gamma3hat*time_1
	
	local gamma2hat = `B'-`gamma3hat'*`obstime_1'
	local phihat = abs(`A'-2*`gamma2hat')

	* gamma1hat = obscov1t - gamma2hat*(obstime+time_1) - gamma3hat*time_1*obstime - phihat*time_1 
	quietly gen `gamma1values' = `obscov1t' - `gamma2hat'*(`obstime'+`obstime_1') - `gamma3hat'*`obstime_1'*`obstime' ///
	                             - `phihat'*`obstime_1'
	quietly summarize `gamma1values', detail
	local gamma1hat = abs(r(p50))

	* sigmaSqhat = obsvar - gamma1hat - 2*gamma2hat*time - gamma3hat*timeSquared - phihat*time
	gen `sigmaSqvalues' = `obsvar' - `gamma1hat' - 2*`gamma2hat'*`obstime' - `gamma3hat'*`obstimeSquared' - `phihat'*`obstime'
	quietly summarize `sigmaSqhat', detail
	local sigmaSqhat = abs(r(p50))
	local sigmahat = sqrt(`sigmaSqhat')

	if `RIposition'==1 {	// INTERCEPT WAS SPECIFIED FIRST
		matrix `G' = (`gamma1hat',`gamma2hat' \ `gamma2hat',`gamma3hat') 
	}
	else {
		matrix `G' = (`gamma3hat',`gamma2hat' \ `gamma2hat',`gamma1hat') 
	}
	
	matrix `Wvalues' = (`phihat')
	matrix `Wstarvalues' = (`phihat'/`sigmaSqhat')
	
	di "gamma1 is " %4.3f `gamma1hat' "; gamma2 is " %4.3f `gamma2hat' "; gamma3 is " %4.3f `gamma3hat' "; phi is " %4.3f `phihat' "; sigma is " %4.3f `sigmahat'
	
	return matrix sv_G `G'
	return matrix sv_Wvalues `Wvalues'
	return matrix sv_Wstarvalues `Wstarvalues'
	return local sv_sigma `sigmahat'
end	
