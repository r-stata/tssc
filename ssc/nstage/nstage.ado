*! nstage v4.0 28may2019. 				
*! based on stage2, v. 1.0.0 SB 17Mar2004.
* Allows for the specification of efficacy stopping bounds
* Amends the correlation structure with efficacy stopping bounds when I!=D
* Allows specification of binding/non-binding stopping boundaries
* Includes option to find the alphaJ which controls the FWER

cap program drop nstage
cap mata mata drop mvnprob()
set linesize 80

program define nstage, rclass

/*
	Determine number of events for stages 1 to n.
	Requires input of stage 1 to n-1 and stage n parameters.
	Determine time to given number of events assuming exponential survival.
	Hazard/median may have one or more values (latter for n stages).
	Tstop() (optional) is time of end of patient recruitment.

	Note that hidden option includedroppedarms is for compatibility
	with earlier versions of nstage (although the calculations have
	been updated in this release). The view is that reporting the actual
	number of events for the remaining arms is a better option than
	than trying to estimate how many events would have occurred in dropped
	arms.
	
	
	Main changes in v4.0
	--- Allow for the specification of efficacy boundaries in calculation of the error rates
		- Haybittle-Peto
		- O'Brien Fleming alpha-spending approximation
		- Custom p-values
	--- Choice of which stopping approach to take with efficacy boundaries
		- Separate stopping rule: Continue with remaining arms
		- Simultaneous stopping rule: Terminate trial
	--- Subroutine added for controlling the FWER at the specified level
	--- Option added to assume non-binding futility stopping boundaries in calculation of the error rates
	--- Re-formatted nstage output
*/


version 10.0
syntax , Nstage(int) ACcrue(string) ALpha(string) ARms(string) HR0(string) HR1(string) ///
 Omega(string) [ARAtio(string) corr(real 0.6) noIterate INCludedroppedarms ///
 PRobs S(string) T(string) TStop(real 0) TOl(real 0.005) TUnit(int 1) SIMcorr(string) seed(int -1) ///
 OUTfile(string) NOFwer fwerreps(int 250000) esb(string) NONBINDing FWERcontrol(string)]		
											
if `fwerreps'<1E5 {	
	di as err "fwerreps() should be at least 100,000"
	exit 198
}
						
/*
	Estimate c as in Royston et al 2009.
	`corr' is correlation between (log) HRs on I and D outcomes
	or the correlation between survival times on I (ignoring D) and
	D outcomes if -simcorr- is specified.
	Use of `c' attenuates correlation between HRs on I-outcome
	at intermediate stage and D-outcome at final stage.
*/
if `corr' < 0 | `corr' > 1 {
	di as err "invalid corr(`corr'), must be in range [0, 1]"
	exit 198
}
local c = 1.1 * `corr'


local title1 "n-stage trial design                    version 4.0.1, 2 Nov 2018"	
local title2 "based on Royston et al. (2011) Trials 12:81 and Blenkinsop et al."
local title3 "(2019) Clinical Trials 16(2)"

local hline = length("`title1'")

/*******************************************************************************
 Calculate sample size required
*******************************************************************************/

samplesize, nstage(`nstage') accrue(`accrue') alpha(`alpha') arms(`arms') hr0(`hr0') hr1(`hr1') ///
			omega(`omega') aratio(`aratio') s(`s') t(`t') tstop(`tstop') tunit(`tunit') seed(`seed') fwerreps(`fwerreps')
forvalues j=1/`nstage'{
	local armsS`j' = r(armsS`j')
	local accrueS`j' = r(accrueS`j')
	local hr0S`j' = r(hr0S`j')
	local hr1S`j' = r(hr1S`j')
	local lndelS`j' = r(lndelS`j')
	local tS`j' = r(tS`j')
	local etotS`j' = r(etotS`j')
	local eS`j' = r(eS`j')
	local eexpS`j' = r(eexpS`j')
	local ntotS`j' = r(ntotS`j')
	local nS`j' = r(nS`j')
	local nexpS`j' = r(nexpS`j')
	local alphaS`j' = r(alphaS`j')
	local zalphaS`j' = r(zalphaS`j')
	local omegaS`j' = r(omegaS`j')
	local zomegaS`j' = r(zomegaS`j')
	local acc0S`j' = r(acc0S`j')
	local oaccS`j' = r(oaccS`j')
	local eS`j'un = r(eS`j'un)
	local eS`j'star = r(eS`j'star)
}
	local median1 = r(median1)
	local median`nstage' = r(median`nstage')
	local have_D = r(have_D)
	local Rstar = r(Rstar)
	local fac = r(fac)
	
	return scalar deltaS1 = exp(`lndelS1')
	return scalar eS1un = `eS1un'
	return scalar eS1 = `eS1'
	return scalar eS1star = `eS1star'
	return scalar nS1 = `nS1'
	return scalar tS1 = `tS1'
	return scalar ntotS1 = `ntotS1'
	return scalar nexpS1 = `nexpS1'
	return scalar etotS1 = `etotS1'
	return scalar eexpS1 = `eexpS1'
	return scalar omegaS1 = `omegaS1'
if `nstage' == 1 exit

/*******************************************************************************
	Calculate between-stage correlation
*******************************************************************************/

tempname RH0 RH1

if "`esb'" != "" & `have_D' & "`simcorr'"==""{		// NEW - Add condition that forces simulated correlation if esb specified when I!=D, to ensure correlation is based on D-D outcomes
	local simcorr = 250
	local corr 0.6
}

if "`simcorr'" != "" & `have_D' {
	di as txt "Simulations are carried out to estimate the correlation structure."
	di as txt "Depending on the number of replicates, the results might take some minutes to appear."
	di as txt "Progress is shown below."
}

local sampl
local events
forvalues i = 1 / `nstage' {
	local sampl `sampl' `ntotS`i''
	local events `events' `eS`i''
}


if `nstage' == 2 {
	local rH0 = min(sqrt(`eS1' / `eS`nstage''), 1)
	if `have_D' {
		
		if "`simcorr'" != "" {
			hrcorrnstage, accrue(`accrue') hr0(`hr0') hr1(`hr1') n(`sampl') e(`events') t(`t') ///
				aratio(`Rstar') nstage(`nstage') rep(`simcorr') rho(`corr') seed(`seed') savehr(`outfile')
			forvalues k = 0/1 {	
				local rH`k' = r(corrln1`nstage'H`k')
				matrix `RH`k'' = (1, `rH`k'' \ `rH`k'', 1)
				if "`esb'" != ""{
					matrix `RH`k'' = r(Corrhr_EB`k')
					forvalues j = 0/1 {
						forvalues m = 1 / `nstage' {
							local d`m'`j' = r(d`m'`j')
							if `j'==0 return scalar D`m' = `d`m'`j''			// Store D-events at interim stages when I!=D
						}
					}
				}
			}
			local pwalpha = binormal(`zalphaS1', `zalphaS`nstage'', `rH0')	// overall pairwise alpha
			local pwomega = binormal(`zomegaS1', `zomegaS`nstage'', `rH1')	// overall pairwise power
			if "`esb'" == "" {
				local bindingpwer  = `pwalpha'
				local bindingomega = `pwomega'
			}
		}

		else {
			local i 1
			local rH0 = `rH0' * `c'
			local alphaI `alphaS1'
			local omegaI `omegaS1'
			local alpha_min = `alphaS1' * `alphaS`nstage''
			local alpha_max = min(`alphaI', `alphaS`nstage'')
			local omega_min = `omegaS1' * `omegaS`nstage''
			local omega_max = min(`omegaS1', `omegaS`nstage'')
			matrix `RH0' = (1, `rH0' \ `rH0', 1)
			local pwalpha = binormal(`zalphaS1', `zalphaS`nstage'', `rH0')	// overall pairwise alpha
			local pwomega = binormal(`zomegaS1', `zomegaS`nstage'', `rH0')	// overall pairwise power
			if "`esb'" == "" {
				local bindingpwer  = `pwalpha'
				local bindingomega = `pwomega'		
				//local pwalpha = `alphaS`nstage''		// CHECK
			}
		}
	}

	else {			
			local rH0 = sqrt(`eS1' / `eS`nstage'')
			matrix `RH0' = (1, `rH0' \ `rH0', 1)
			local pwalpha = binormal(`zalphaS1', `zalphaS`nstage'', `rH0')	// overall pairwise alpha
			local pwomega = binormal(`zomegaS1', `zomegaS`nstage'', `rH0')	// overall pairwise power
	}
}

else {
	matrix `RH0' = I(`nstage')
	matrix `RH1' = I(`nstage')
			
	if (`have_D') & ("`simcorr'" != "") {
		hrcorrnstage, accrue(`accrue') hr0(`hr0') hr1(`hr1') n(`sampl') e(`events') t(`t') aratio(`Rstar') ///
			nstage(`nstage') rep(`simcorr') rho(`corr') seed(`seed') savehr(`outfile')		
	}
		
	local ns1 = `nstage' - 1
	forvalues i = 1 / `ns1' {
		local i1 = `i' + 1
		forvalues j = `i1' / `nstage' {
			local rH0 = min(sqrt(`eS`i'' / `eS`j''), 1)	// could add line under here: if esb, rH0 = min(sqrt(di1/dj1),1)?
			local rH1 = `rH0'
			
			if (`have_D') & (`j' == `nstage') {
				
				if "`simcorr'" != "" {				
					forvalues k = 0/1 {	
						local rH`k' = r(corrln`i'`nstage'H`k')
					}
				}
				else {
					local rH0 = `rH0' * `c'
					local rH1 = `rH0'
				}
			}
			
			forvalues k = 0/1 {	
				matrix `RH`k''[`i', `j'] = `rH`k''
				matrix `RH`k''[`j', `i'] = `RH`k''[`i', `j']
			}	
		}
		if `have_D' & "`simcorr'" != "" & "`esb'" != ""{
			forvalues k = 0/1 {
				matrix `RH`k'' = r(Corrhr_EB`k')
			}
			forvalues l = 0/1 {
				forvalues m = 1 / `nstage' {
					local d`m'`l' = r(d`m'`l')
					if `l'==0 return scalar D`m' = `d`m'`l''			// Store D-events at interim stages when I!=D
				}
			}		
		}
	}

	tempname zalpha zomega
	local za `zalphaS1'
	local zo `zomegaS1'
	
	forvalues m = 2 / `nstage' {
		local za `za' , `zalphaS`m''
		local zo `zo' , `zomegaS`m''		
	}
	matrix `zalpha' = (`za')
	matrix `zomega' = (`zo')
	
	// Using 2000 replicates for GHK evaluation of MVN integral
	local rep 2000
	mata: mvnprob("`zalpha'", "`RH0'", `rep')
	local pwalpha = r(p)
	mata: mvnprob("`zomega'", "`RH1'", `rep')
	local pwomega = r(p)
	if `have_D' & "`esb'" == "" {
		local bindingpwer  = `pwalpha'
		local bindingomega = `pwomega'
		//local pwalpha 	   = `alphaS`nstage''
	}
}

/******************************************************************************* 
 Calculate the FWER and probabilities	
*******************************************************************************/
if !`have_D' & "`fwercontrol'"!=""{		// If I=D and FWER control specified, assume non-binding boundaries
	local nonbinding nonbinding
}

if "`nofwer'"=="" | "`probs'"!=""  {
	local K = `armsS1'-1			

	* 1 exp. arm -- calculate probs algebraically (unless efficacy boundaries or non-binding boundaries specified)
	if `K'==1 & "`esb'" == "" & "`nonbinding'" == ""{
		
		noi di "Algebraic evaluation of operating characteristics"
		if `nstage'==2 {
			local p11 = `alphaS1'
			local p10 = 1-`p11'
			
			local p21 = `pwalpha'
			local p20 = 1-`p21'
			local fwerate = `pwalpha'	// Added to allow FWERcontrol option for 2 stage, 1 arm trial
			if `have_D' local maxfwer = `alphaS`nstage''	// 2 stage, 2 arm design with I!=D, maxfwer is just equal to final stage alpha
		}
		
		else {
			
			forvalues j = 1/`nstage' {
				local jm1 = `j'-1
				
				tempname R`j' z`j'
				matrix `R`j'' = `RH0'[1..`j', 1..`j']
				
				local za `zalphaS1'
				forvalues m = 2 / `j' {
					local za `za' , `zalphaS`m''
				}
				matrix `z`j'' = (`za')
				
				mata: mvnprob("`z`j''", "`R`j''", `rep')
				local p`j'1 = r(p)
				local p`j'0 = 1-`p`j'1'
				local fwerate = `pwalpha'
				if `have_D' local maxfwer = `alphaS`nstage''
				if `have_D' local pwomega = `omegaS`nstage''	
			}	
		}
	}
	
	* Else use nstagefwer subroutine
	else {
		if `have_D' local ineqd ineqd
		if "`esb'" != "" {
		if `fwerreps'!=250000 local fwerreps `fwerreps'
		else local fwerreps 1000000
		nstagefwer, nstage(`nstage') arms(`armsS1') alpha(`alpha') omega(`omega') corr(`RH0') aratio(`Rstar') seed(`seed') ///
			reps(`fwerreps') `ineqd' esb(`esb') `nonbinding'
			local edrops = r(edrops)
			local esbstop = r(esbstop)
			if "`esbstop'"!="."{
				return local esbstop = "`esbstop'"
			}
		local pwalpha = r(pwer)
		local pwomega = r(pwomega)
		}
		else {
			nstagefwer, nstage(`nstage') arms(`armsS1') alpha(`alpha') omega(`omega') corr(`RH0') aratio(`Rstar') seed(`seed') ///
				reps(`fwerreps') `ineqd' `nonbinding'
		}
		local fwerate = r(fwer)
		local se_fwerate = r(se_fwer)
		local fwomega = r(fwomega)
		local allomega = r(allomega)
		if "`nonbinding'" != ""{
			local pwalpha = r(pwer)
			local pwomega = r(pwomega)
		}
		
		if `have_D' local maxpwomega = r(pwomega)
		if `have_D' local maxfwer = r(maxfwer)
		if `have_D' local mvnpmaxfwer = r(mvnpmaxfwer)
		if `have_D' local se_maxfwer = r(se_maxfwer)
		
		forvalues j = 1/`nstage' {
			if "`esb'" != "" {
				local E`j' = r(E`j')
				return scalar E`j' = `E`j''
				local lndelE`j' = ln(`hr1S`j'') + invnormal(`E`j'') * sqrt(`fac' / `eS`j'')
				return scalar deltaE`j' = exp(`lndelE`j'')
			}
						
			forvalues k = 0/`K' {
				local p`j'`k' = r(p`j'`k')
			}
		}	
	}
	
/******************************************************************************* 
 Control FWER
*******************************************************************************/
		if "`fwercontrol'" !=""{
			local fwercontrolpct = `fwercontrol'*100
			di as text "        "
			di as text "Searching for design which controls the FWER at `fwercontrolpct'%"
			if `have_D' local ineqd ineqd
			local targetfwer = `fwercontrol'
			local count 0
			
			local x1 = `alphaS`nstage''			
			
			if `have_D'	{
				local diff = `maxfwer' - `targetfwer'
				local y1 = `maxfwer'
			}
			else {
				local diff = `fwerate' - `targetfwer'
				local y1 = `fwerate'
			}
			local aJ = `targetfwer'/(2*`K') // Starting value for final-stage signficance level, aJ
			
			qui while `count'<3{
				local alpha = `alphaS1'
				local jm1 = `nstage' - 1
				forvalues j = 2/`jm1' {
					local alpha `alpha' `alphaS`j''
				}	
				local alpha `alpha' `aJ'
				samplesize, nstage(`nstage') accrue(`accrue') alpha(`alpha') arms(`arms') hr0(`hr0') hr1(`hr1') ///
							omega(`omega') aratio(`aratio') s(`s') t(`t') tstop(`tstop') tunit(`tunit') seed(`seed') fwerreps(`fwerreps')
				forvalues j=1/`nstage'{
					local armsS`j' = r(armsS`j')
					local accrueS`j' = r(accrueS`j')
					local hr0S`j' = r(hr0S`j')
					local hr1S`j' = r(hr1S`j')
					local lndelS`j' = r(lndelS`j')
					local tS`j' = r(tS`j')
					local etotS`j' = r(etotS`j')
					local eS`j' = r(eS`j')
					local eexpS`j' = r(eexpS`j')
					local ntotS`j' = r(ntotS`j')
					local nS`j' = r(nS`j')
					local nexpS`j' = r(nexpS`j')
					local alphaS`j' = r(alphaS`j')
					local zalphaS`j' = r(zalphaS`j')
					local omegaS`j' = r(omegaS`j')
					local zomegaS`j' = r(zomegaS`j')
					local acc0S`j' = r(acc0S`j')
					local oaccS`j' = r(oaccS`j')
					local eS`j'un = r(eS`j'un)
					local eS`j'star = r(eS`j'star)
				}
					local median1 = r(median1)
					local median`nstage' = r(median`nstage')
*______________________________________________________________________
				* Calculate Between-stage correlation *
				tempname RH0 RH1

				if "`esb'" != "" & `have_D' & "`simcorr'"==""{		// NEW - Add condition that forces simulated correlation if esb specified when I!=D, to ensure correlation is based on D-D outcomes
					local simcorr = 250
					local corr 0.6
				}

				if "`simcorr'" != "" & `have_D' {
					di as txt "Simulations are carried out to estimate the correlation structure."
					di as txt "Depending on the number of replicates, the results might take some minutes to appear."
					di as txt "Progress is shown below."
				}
				local sampl
				local events
				forvalues i = 1 / `nstage' {
					local sampl `sampl' `ntotS`i''
					local events `events' `eS`i''
				}

				if `nstage' == 2 {
					local rH0 = min(sqrt(`eS1' / `eS`nstage''), 1)
					if `have_D' {						
						if "`simcorr'" != "" {
							hrcorrnstage, accrue(`accrue') hr0(`hr0') hr1(`hr1') n(`sampl') e(`events') t(`t') ///
								aratio(`Rstar') nstage(`nstage') rep(`simcorr') rho(`corr') seed(`seed') savehr(`outfile')
							forvalues k = 0/1 {	
								local rH`k' = r(corrln1`nstage'H`k')
								matrix `RH`k'' = (1, `rH`k'' \ `rH`k'', 1)
								if "`esb'" != ""{
									matrix `RH`k'' = r(Corrhr_EB`k')
									forvalues j = 0/1 {
										forvalues m = 1 / `nstage' {
											local d`m'`j' = r(d`m'`j')
											if `j'==0 return scalar D`m' = `d`m'`j''
										}
									}
								}
							}
						}
						else {
							local i 1
							local rH0 = `rH0' * `c'
							matrix `RH0' = (1, `rH0' \ `rH0', 1)
						}
					}
					else {			
						local rH0 = sqrt(`eS1' / `eS`nstage'')
						matrix `RH0' = (1, `rH0' \ `rH0', 1)
					}
					local pwalpha = binormal(`zalphaS1', `zalphaS`nstage'', `rH0')	// overall pairwise alpha
					local pwomega = binormal(`zomegaS1', `zomegaS`nstage'', `rH0')	// overall pairwise power			
					if `have_D' & "`esb'" == "" {
						local bindingpwer  = `pwalpha'
						local bindingomega = `pwomega'
						//local pwalpha = `alphaS`nstage''		// CHECK
					}
				}
				else {		
					matrix `RH0' = I(`nstage')
					matrix `RH1' = I(`nstage')
							
					if (`have_D') & ("`simcorr'" != "") {
						hrcorrnstage, accrue(`accrue') hr0(`hr0') hr1(`hr1') n(`sampl') e(`events') t(`t') aratio(`Rstar') ///
									  nstage(`nstage') rep(`simcorr') rho(`corr') seed(`seed') savehr(`outfile')		
					}						
					local ns1 = `nstage' - 1
					forvalues i = 1 / `ns1' {
						local i1 = `i' + 1
						forvalues j = `i1' / `nstage' {
							local rH0 = min(sqrt(`eS`i'' / `eS`j''), 1)
							local rH1 = `rH0'
							if (`have_D') & (`j' == `nstage') {								
								if "`simcorr'" != "" {				
									forvalues k = 0/1 {	
										local rH`k' = r(corrln`i'`nstage'H`k')
									}
								}
								else {
									local rH0 = `rH0' * `c'
									local rH1 = `rH0'
								}
							}
							forvalues k = 0/1 {	
								matrix `RH`k''[`i', `j'] = `rH`k''
								matrix `RH`k''[`j', `i'] = `RH`k''[`i', `j']
							}	
						}
					}
					if `have_D' & "`simcorr'" != "" & "`esb'" != ""{
					forvalues k = 0/1 {
						matrix `RH`k'' = r(Corrhr_EB`k')
					}
					forvalues l = 0/1 {
						forvalues m = 1 / `nstage' {
							local d`m'`l' = r(d`m'`l')
							if `l'==0 return scalar D`m' = `d`m'`l''	
							}
						}	
					}
					tempname zalpha zomega
					local za `zalphaS1'
					local zo `zomegaS1'
					
					forvalues m = 2 / `nstage' {
						local za `za' , `zalphaS`m''
						local zo `zo' , `zomegaS`m''		
					}
					matrix `zalpha' = (`za')
					matrix `zomega' = (`zo')

					local rep 2000
					mata: mvnprob("`zalpha'", "`RH0'", `rep')
					local pwalpha = r(p)
					mata: mvnprob("`zomega'", "`RH1'", `rep')
					local pwomega = r(p)
					if `have_D' & "`esb'" == "" {
						local bindingpwer  = `pwalpha'
						local bindingomega = `pwomega'
					}
				}
*______________________________________________________________________
				* Call nstagefwer to calculate fwer using alphaJ *
				if "`esb'"!="" {	
					if `fwerreps'!=250000 local fwerreps `fwerreps'
					else local fwerreps 1000000
					nstagefwer, nstage(`nstage') arms(`armsS1') alpha(`alpha') omega(`omega') corr(`RH0') aratio(`Rstar') seed(`seed') ///
					reps(`fwerreps') `ineqd' esb(`esb') `nonbinding'
					local esbstop = r(esbstop)
					if "`esbstop'"!="."{
						return local esbstop = "`esbstop'"
					}
					local pwalpha = r(pwer)
					local pwomega = r(pwomega)
				}
				else{
					nstagefwer, nstage(`nstage') arms(`armsS1') alpha(`alpha') omega(`omega') corr(`RH0') aratio(`Rstar') seed(`seed') ///
					reps(`fwerreps') `ineqd' `nonbinding'
				}

				local fwerate = r(fwer)
				local se_fwerate = r(se_fwer)
				local fwomega = r(fwomega)
				local allomega = r(allomega)
				if "`nonbinding'" != ""{
					local pwalpha = r(pwer)
					local pwomega = r(pwomega)
				}
				if `have_D' local fwerate = r(maxfwer)
				if `have_D' local maxfwer = r(maxfwer)
				if `have_D' local mvnpmaxfwer = r(mvnpmaxfwer)
				if `have_D' local se_maxfwer = r(se_maxfwer)
				forvalues j = 1/`nstage' {
					if "`esb'" != "" {
						local E`j' = r(E`j')
						return scalar E`j' = `E`j''
						local lndelE`j' = ln(`hr1S`j'') + invnormal(`E`j'') * sqrt(`fac' / `eS`j'')
						return scalar deltaE`j' = exp(`lndelE`j'')
					}
					forvalues k = 0/`K' {
						local p`j'`k' = r(p`j'`k')
					}
				}	
				
				if `count'==0{	// Use linear interpolation to get close to aJ
					local x2 = `aJ'
					if `have_D'	{
						local y2 = `maxfwer'
					}
					else {
						local y2 = `fwerate'
					}
					
					local y3 = `targetfwer'
					local x3 = ((`y2'-`y3')*`x1'+(`y3'-`y1')*`x2')/(`y2'-`y1')

					local aJ = `x3'
				}
				if `count'==1{
					if `have_D' local diff = `targetfwer' - `maxfwer'
					else local diff = `targetfwer' - `fwerate'
					if `diff'>0 local ++count
					else local aJ = `aJ' + (`diff'/(`K'))
				}
				local ++count
			}
			return scalar aJ = `aJ'
		}
*__________________________________________________________________
		if "`probs'"!="" {
			local rownames
			local colnames
			
			forvalues j = 1/`nstage' {
				local rownames `rownames' pass_stage`j'
				
				local prb`j' `p`j'0'
				forvalues k = 1/`K' {
					local prb`j' `prb`j'', `p`j'`k''
				}
			}
			
			forvalues k = 0/`K' {
				local colnames `colnames' P(`k'arms)
			}
			
			local prb `prb1'
			forvalues j = 2/`nstage' {
				local prb `prb' \ `prb`j''
			}
			mat P = (`prb')
			mat rownames P = `rownames'
			mat colnames P = `colnames'
			return matrix P = P
		}	
	}

/*******************************************************************************
	Output
*******************************************************************************/
if "`esb'" != ""{
	local vw 7
	local vx 10
	local vy 6
	local vz 9
}
	local ww 9
	local sfl %-`ww's
	local sfc %~`ww's
	local sfr %`ww's

	local wx 14
	local sxl %-`wx's
	local sxc %~`wx's
	local sxr %`wx's

	local wy 5
	local syl %-`wy's
	local syc %~`wy's
	local syr %`wy's

	local wz 7
	local szl %-`wz's
	local szc %~`wz's
	local szr %`wz's

if "`esb'" != ""{	
	local nitem 10
	local dup = 80
}
else {
	local nitem 8
	local dup = (`nitem'-1) * `ww' + `wx'
}
local ww3 = `ww' * 3
local ww4 = `ww' * 4

di as text _n(2) "`title1'" _n "{hline `hline'}"
di as text "Sample size for a " as res "`armsS1'" as text "-arm " as res "`nstage'" as txt "-stage trial with time-to-event outcome"
di as text "`title2'" 
di as text "`title3'" _n "{hline `hline'}"


if `have_D' {
	local ss s
	di as text _n "Median survival time (I-outcome): " as res round(`median1', 0.1) as text " time units"
	di as text    "Median survival time (D-outcome): " as res round(`median`nstage'', 0.1) as text " time units"
}
else {
	di as text _n "Note: I outcome and D outcome are identical"
	di as text "Median survival time: " as res round(`median1', 0.1) as text " time units"
}

di as text _n "Operating characteristics"  _n "{hline `dup'}" 

if "`esb'" != ""{		// new
	di as text "Stage" _col(9) "Alpha" _col(16) "Alpha" _col(23) "Power" _col(30) "HR{c |}H0" ///
	_col(37) "HR{c |}H1" _col(45) "Crit.HR" _col(54) "Crit.HR" _col(64) "Length**" _col(74) "Time**"  
	di as text _col(8) "(LOB)*" _col(16) "(ESB)*" _col(46) "(LOB)" _col(55) "(ESB)" _n "{hline `dup'}"
}
else {
	di as text "Stage" _col(8) `syr' "Alpha(LOB)*" _col(23) "Power" _col(32) "HR{c |}H0" ///
	_col(41) "HR{c |}H1" `sfr' "Crit.HR" `sfr' "Length**" `sfr' "Time**" _n "{hline `dup'}" 
}

forvalues m = 1 / `nstage' {
	local m1 = `m' - 1
	if `m'==1 {
		local ts = `tS1'
	}
	else local ts = `tS`m'' - `tS`m1''
	if "`esb'" != "" {	
		di as text %-`vy's "`m'" %`vw'.4f `alphaS`m'' %`vw'.4f `E`m'' %`vw'.3f `omegaS`m'' ///
		%`vw'.3f as txt `hr0S`m'' %`vw'.3f as txt `hr1S`m'' as res %`vz'.3f ///
		exp(`lndelS`m'') %`vz'.3f as res exp(`lndelE`m'') %`vx'.3f as res `ts' %`vx'.3f as res `tS`m'' 
	}
	else {
		di as text `sfl' "`m'" %`ww'.4f `alphaS`m'' %`ww'.3f `omegaS`m'' ///
		%`ww'.3f as txt `hr0S`m'' %`ww'.3f as txt `hr1S`m'' as res %`ww'.3f ///
		exp(`lndelS`m'') %`ww'.3f as res `ts' %`ww'.3f as res `tS`m'' 
	}
}
if `nstage' > 1 {
	if `armsS1'>2 {
		
		di as text "{hline `dup'}"

		if `have_D' {
			if "`esb'"=="" di as text `sxl' "Pairwise Error Rate" _col(34) %`ww'.4f as res `pwalpha' _cont
			else di as text `sxl' "Max. Pairwise Error Rate" _col(34) %`ww'.4f as res `pwalpha' _cont
			di as text _col(55) "Pairwise Power" %`ww'.4f as res `pwomega'
			if "`nofwer'"=="" di as text "Max. Familywise Error Rate (SE)" _col(34) %`ww'.4f as res `maxfwer' as text " (" %5.4f as res `se_maxfwer' as text ")" _cont
			di _n as txt "{hline `dup'}"
		}
		else {
			di as text `sxl' "Pairwise Error Rate" _col(27) %`ww'.4f as res `pwalpha' _cont
			di as text _col(50) "Pairwise Power" %`ww'.4f as res `pwomega'
			if "`nofwer'"=="" di as text "Familywise Error Rate (SE)" _col(27) %`ww'.4f as res `fwerate' as text " (" %5.4f as res `se_fwerate' as text ")" _cont
			di _n as txt "{hline `dup'}"
		}
	}
	
	else {
		if `have_D' {
		di as text "{hline `dup'}"
		if "`esb'"=="" di as text `sxl' "Pairwise Error Rate" _col(21) %`ww'.4f as res `pwalpha'  _cont 
		else  di as text `sxl' "Max. Pairwise Error Rate" _col(34) %`ww'.4f as res `pwalpha'  _cont 
		if "`esb'"=="" di as text _col(42) "Pairwise Power" %`ww'.4f as res `bindingomega'
		else di as text _col(55) "Pairwise Power" %`ww'.4f as res `pwomega'
		if "`nofwer'"=="" & "`esb'"=="" di as text "Max. Error Rate" _col(21) %`ww'.4f as res `alphaS`nstage''
		else if "`nofwer'"=="" di as text "Max. Error Rate" _col(34) %`ww'.4f as res `maxfwer'
		}		
		else {
		di as text "{hline `dup'}"
		di as text `sxl' "Pairwise Error Rate" %`ww'.4f as res `pwalpha' _cont 
		di as text _col(37) "Pairwise Power" %`ww'.4f as res `pwomega'
		}	
		di as txt "{hline `dup'}"
	}
}


if `tstop'>0 {
	di as text "Note: patient accrual stopped at time " %6.3f `tstop'
} 

di as text " *   All alphas are one-sided"
if "`esbstop'"=="stop"{
	di as text "     Error rates assume trial is terminated once an efficacious arm is identified"
}
di as text " **  Length (duration of each stage) is expressed in " as res "`lperiod'" as txt " periods and"
di as text "     assumes survival times are exponentially distributed. Time is"
di as text "     expressed in cumulative periods."


*if `have_D' di as text " *** Calculated under global null hypothesis for I and D outcomes"

/*
di as txt " ** Correlations between hazard ratios estimated internally by the program"
if `have_D' {
	di as txt "    assuming corr(), correlation between survival times on I & D, is " as res %4.2f `corr'	
}
*/
di as text _n(1) "Sample size and number of events" 

local nitem 7
local dup = `nitem' * `ww'
local dup2 = int((`ww' * (`nitem' - 1) / 2 - length("Stage 1")) / 2 - 0.5)
local dup3 = 4 * `ww'
local dup4 = 2*`dup2' + length("Stage 1")
forvalues m = 1/`nstage' {
	di as text _dup(`dup2') _col(12) "{c -}" "Stage `m'" _dup(`dup2') "{c -}" 
	di as text _skip(`ww') `sfr' "Overall" `sfr' "Control" `sfr' "Exper." 
	di as text `sfl' "Arms"      as txt %`ww'.0f `armsS`m'' %`ww'.0f 1 %`ww'.0f `armsS`m''-1 
	di as text `sfl' "Acc. rate" as txt %`ww'.0f `oaccS`m'' %`ww'.0f `acc0S`m'' %`ww'.0f `acc0S`m''*(`armsS`m''-1)*`Rstar' 
	di as text `sfl' "Patients*" as res %`ww'.0f `ntotS`m'' %`ww'.0f `nS`m'' %`ww'.0f `nexpS`m'' 
	di as text `sfl' "Events**"  as res %`ww'.0f `etotS`m'' %`ww'.0f `eS`m'' %`ww'.0f `eexpS`m'' 	
}
	di as text _col(12) _dup(`dup4') "{c -}"

if `Rstar'!=1 {
	di as text "`Rstar' patients allocated to each E arm for every 1 to control arm."
}
di as text " *  Patients are cumulative across stages"
di as txt " ** Events are cumulative across stages, but are only displayed"
di as txt "    for those arms to which patients are still being recruited"
tempname nstage1
scalar `nstage1' = `nstage' - 1
if `nstage'==2 {
	if `have_D' {
		di as text " ** Events are for I-outcome at stage 1, D-outcome at stage 2"
	}
	else di as text " ** Events are for the same outcome at stages 1 and 2"
}
else {
	if `have_D' {
		di as text " ** Events are for I-outcome at stages 1 to " `nstage1' ", D-outcome at stage `nstage'"
	}
	else di as text " ** Events are for the same outcome at all `nstage' stages"
}
if "`iterate'" == "noiterate" {
	di as text _n "[Note: computations carried out under H0, sample sizes may be too low.]"
}

local wy 8
if "`probs'"!="" {
	local K = `armsS1'-1
	local dup2 = `wy' * (`armsS1' + 1)
	
	di as text _n "Probability of k experimental arms passing each stage under global null hypothesis"
	di as text _dup(`dup2') "{c -}"
	di as text %-`wy's "k(#arms)" _cont

	forvalues k = 0 / `K' {
		di as txt %`wy'.0f `k' _cont
	}
	di
	di as text _dup(`dup2') "{c -}" _cont
		
	forvalues j = 1 / `nstage' {

		di _n as text %-`wy's "Stage `j'" _cont
		forvalues k = 0 / `K' {
			di as res %`wy'.3f `p`j'`k'' _cont
		}
	}
	
	di _n as text _dup(`dup2') "{c -}"
}


forvalues i = 2 / `nstage' {
	return scalar deltaS`i' = exp(`lndelS`i'')
	return scalar eS`i'un = `eS`i'un'
	return scalar eS`i' = `eS`i''
	return scalar eS`i'star = `eS`i'star'
	return scalar nS`i' = `nS`i''
	return scalar tS`i' = `tS`i''
	return scalar ntotS`i' = `ntotS`i''
	return scalar nexpS`i' = `nexpS`i''
	return scalar etotS`i' = `etotS`i''
	return scalar eexpS`i' = `eexpS`i''
	return scalar omegaS`i' = `omegaS`i''
}

return scalar alpha = `pwalpha'
if "`pwomega'" == "" return scalar omega = `pwomega'
return matrix R = `RH0'
if `have_D' & "`esb'" == "" {
	return scalar bindingpwer  = `bindingpwer'
	return scalar bindingomega = `bindingomega'
}

if "`nofwer'"=="" & `armsS2'==2 {
	return scalar fwer = `fwerate'
	if "`nonbinding'"!="" return scalar se_fwer = `se_fwerate'
	return scalar pwomega = `pwomega'
	if `have_D' return scalar maxfwer = `maxfwer'
	if "`esb'"!="" if `have_D' return scalar se_maxfwer = `se_maxfwer'
}

if "`nofwer'"=="" & `armsS1'>2 {
	return scalar fwer = `fwerate'
	return scalar se_fwer = `se_fwerate'
	if `have_D' return scalar maxfwer = `maxfwer'
	if `have_D' return scalar mvnpmaxfwer = `mvnpmaxfwer'
	if `have_D' return scalar se_maxfwer = `se_maxfwer'
	return scalar pwomega = `pwomega'
	return scalar fwomega = `fwomega'
	return scalar allomega = `allomega'
}

noi di as txt "END OF NSTAGE"	
		
end

mata:
void mvnprob(string scalar xx, string scalar vv, real scalar reps)
{
/*
	Assumes Hammersley sequences are to be generated, without antithetics.
*/
	real vector opt
	x = st_matrix(xx)	// row or col vector of args at which probability is required
	V = st_matrix(vv)	// variance-covariance matrix
	opt = (2, reps, 1, 0)	// 2 for Hammersley
	p = ghk( x, V, opt, rank=.)
	st_numscalar("r(p)", p)
}
end

********************************************************************************************

********************************************************************************************


* v 1.0.0 PR 29aug2008.
* based on v 1.0.0 PR 02May2001.
cap program drop evfromtin4
program define evfromtin4, rclass
/*
	Determine number of events expected given time and hazard or median survival.
	Assumes exponential survival.
	Hazard/median may have one or more values (latter for two or more stages).
*/
version 7
syntax , Accrual(string) TImes(string) [ Hazard(string) Median(string) TStop(string) ]
if "`tstop'"!="" {
	confirm num `tstop'
	if `tstop' <= 0 {
		di as err "tstop() must be positive"
		exit 198
	}
}
if "`median'`hazard'" == "" {
	di as err "must supply hazard() or median()"
	exit 198
}
local nstage: word count `times'
forvalues i = 1 / `nstage' {
	local t`i': word `i' of `times'
	confirm number `t`i''
	local acc`i': word `i' of `accrual'
	confirm number `acc`i''
}
if "`tstop'" != "" {
	if `tstop' >= `t`nstage'' {
		di as txt "[tstop occurs after end of trial, ignored]"
		local tstop
	}
}
if `nstage' > 1 {
	 forvalues i = 1 / 2 {
		if "`hazard'" == "" {
			local median`i': word `i' of `median'
			local hazard`i' = ln(2) / `median`i''
		}
		else {
			local hazard`i': word `i' of `hazard'
			local median`i' = ln(2) / `hazard`i''
		}
	}
}
else {
	if "`hazard'" == "" {
		local median1: word 1 of `median'
		local hazard1 = ln(2) / `median1'
	}
	else {
		local hazard1: word 1 of `hazard'
		local median1 = ln(2) / `hazard1'
	}
}
/*
	d`j' = interval between time j and time j-1
	N`j' = number at risk at time t`j'
	e`j' = cumulative number of events by t`j'
	If tstop exists:
	a = stage number just before tstop (i.e. time t`a' < tstop). a could be 0, if tstop occurs in (0, t1].
	dstop = interval between tstop and t`a'
*/
local t0 0
local a -1
forvalues j = 1 / `nstage' {
	local j1 = `j' - 1
	local d`j' = `t`j'' - `t`j1''
	if `d`j'' < 0 {
		*di as err "Time `j' must not be less than time `j1'"
		local errmess "Time `j' must not be less than time `j1'"
		di as err `"`errmess'"'
		return local errmess `errmess'
		exit 198
	}
	if "`tstop'" != "" {
		if `tstop' > `t`j1'' & `tstop' <= `t`j'' {
			if reldif(`tstop', `t`j'') < 0.00001 {
				// stopping recruitment at `t`j''
				local a `j'
				local dstop 0
			}
			else {
				local a `j1'
				local dstop = `tstop' - `t`a''
			}
		}
	}
}
// Note that Stage 1 assumes hazard `hazard1'
if `nstage' == 1 {
	local haz `hazard1'
}
else local haz `hazard2'

// Find number of events by t`nstage'
local Nj1 0
local ej1 0
if `a'==0 {	// tstop <= t1
	F `dstop' `haz'
	local f = `tstop' - r(F) / `haz'
	local Ntstop = `acc1' * (`tstop' - `f')
	local etstop = `acc1' * `f'
	F "`t`nstage''-`tstop'" `haz'
	local e`nstage' = `etstop' + `Ntstop' * r(F)
	di "Stage `nstage': events = " %8.0g `e`nstage''
	return scalar e`nstage' = `e`nstage''
	return scalar atrisk = `Ntstop'
	exit
}
forvalues j = 1 / `nstage' {
	local j1 = `j' - 1
	F `d`j'' `haz'
	local F = r(F)								// F(d_j)
	local f = `d`j'' - `F' / `haz'					// f(d_j)
	local Nj = (1 - `F') * `Nj1' + `acc`j'' * (`d`j'' - `f')	// number at risk at t_j
	local ej = `ej1' + `acc`j'' * `f' + `Nj1' * `F'			// events at t_j
*if `j'==1 { noi di in red "j=1 ej=" `ej' " atrisk = " `Nj' }
	if `j' == `a' {
		// Recruitment stops at tstop
		if `dstop' > 0 {
			F `dstop' `haz'
			local F = r(F)
			local f = `dstop' - `F' / `haz'
			local jp1 = `j' + 1
			local Ntstop = `Nj' * (1 - `F') + `acc`jp1'' * (`dstop' - `f')
			local etstop = `ej' + `acc`jp1'' * `f' + `Nj' * `F'
		}
		else {
			local Ntstop `Nj'
			local etstop `ej'
		}
		F "`t`nstage''-`tstop'" `haz'
		local ej = `etstop' + `Ntstop' * r(F)
		local Nj1 = `Ntstop'
		continue, break
	}
	local Nj1 `Nj'
	local ej1 `ej'
}
di "Stage `nstage': events = " %8.0g `ej'
return scalar e`nstage' = `ej'
return scalar atrisk = `Nj1'
end






********************************************************************************************

********************************************************************************************


* v 1.0.3 PR 18may2009.
cap program drop timetoevn4
program define timetoevn4, rclass
/*
	Determine time to given number of events assuming exponential survival.
	Hazard/median may have one or two values (latter for two stages).
*/
version 7
syntax , Accrual(string) Events(string) [ Hazard(string) Median(string) Tol(real 0.0001) /*
 */ TStop(real 0) ]
if "`median'`hazard'" == "" {
	di as err "must supply hazard() or median()"
	exit 198
}

local nstage: word count `events'
forvalues i = 1 / `nstage' {
	local ev`i': word `i' of `events'
	local acc`i': word `i' of `accrual'
	cap confirm num `acc`i''
	if c(rc) {
		di as err `"invalid accrual value, "`acc`i''""'
		exit 198
	}
}

if `nstage' > 1 {
	 forvalues i = 1 / 2 {
		if "`hazard'" == "" {
			local median`i': word `i' of `median'
			local hazard`i' = ln(2) / `median`i''
		}
		else {
			local hazard`i': word `i' of `hazard'
			local median`i' = ln(2) / `hazard`i''
		}
	}
}
else {
	if "`hazard'" == "" {
		local median1: word 1 of `median'
		local hazard1 = ln(2) / `median1'
	}
	else {
		local hazard1: word 1 of `hazard'
		local median1 = ln(2) / `hazard1'
	}
}
// Stage 1 - initial guess at time 1 (t1) is median1
local g `ev1'
local t1 `median1'

// Newton-Raphson iterative scheme to find time corresponding to ev1 events
local i 0
quietly while abs(`g')>`tol' & `i'<100 { // `g' is difference between actual and target events
	if `tstop'==0 | `tstop' >= `t1' {
		cap evfromtin4, accrual(`acc1') times(`t1') hazard(`hazard1')
		if _rc {
			local errmess = r(errmess)
			di as err `"`r(errmess)'"'
			return local errmess `errmess'
			exit 498
		}
		local g = `ev1' - r(e1)
		F `t1' `hazard1'
		local gprime = -`acc1' * r(F)
	}
	else {
		cap evfromtin4, accrual(`acc1') times(`t1') hazard(`hazard1') tstop(`tstop')
		if _rc {
			local errmess = r(errmess)
			di as err `"`r(errmess)'"'
			return local errmess `errmess'
			exit 498
		}
		local g = `ev1' - r(e1)
		F `tstop' `hazard1'
		local Ntstop = `acc1' * r(F) / `hazard1'	// no. at risk at tstop
		F "`t1'-`tstop'" `hazard1'			// F(t1 - tstop)
		local gprime = -`Ntstop' * `hazard1' * (1 - r(F))
	}
	if abs(`gprime')<1e-10 {
		local errmess "design is infeasible - insufficient patients to accrue `ev1' events in stage 1"
		di as err `"`errmess'"'
		return local errmess `errmess'
		exit 198
	}
	local t1 = `t1' - `g'/`gprime'
	local ++i
}
return scalar t1 = `t1'
return scalar err1 = `g'
return scalar iter1 = `i'
di "Stage 1: t = " %8.0g `t1'
if `nstage' > 1 & `tstop' > 0 & `tstop' < `t1' {
	local errmess "design is infeasible - tstop occurs in stage 1 (too early - before final stage)"
	di as err `"`errmess'"'
	return local errmess `errmess'
	exit 198
}
if `nstage'==1  {
	exit
}
local accrueS
local tS
forvalues m = 2 / `nstage' {
	local m1 = `m' - 1
	local accrueS `accrueS' `acc`m1''
	local tS `tS' `t`m1''
	if `m' < `nstage' {
/*
	Computing t`m', assuming have just successfully computed times t1,...,t`m1'.

	Compute number of I-events in (0, t(m-1)] with accrual rates 1, ..., m-1.
	In this version, we don't handle the possibility that tstop occurs during
	the first m-1 stages.
*/
		// Get events up to stage m1 = `m'-1
		qui evfromtin4, accrual(`accrueS') times(`tS') hazard(`hazard1' `hazard1')
		local ev21 = r(e`m1')
		if `ev21' >= `ev`m'' {
			di "Stage `m': already expecting `ev21' events in (0," %8.0g `t`m1'' "]"
			local t`m' = `t`m1''
			return scalar t`m' = `t`m1''
			return scalar ev21 = `ev21'
			continue
			// exit doesn't exit the m loop!
		}
		local g `ev`m''
		local t`m' = `t`m1'' + 0.5 * `median1'
		local i 0
		quietly while abs(`g') > `tol' & `i' < 500 {
			local dt`m' = `t`m'' - `t`m1''
			if `dt`m'' <= 0 {
				local t`m' = 1.001 * `t`m1''
				local dt`m' = `t`m'' - `t`m1''
			}
			evfromtin4, accrual(`accrueS' `acc`m'') times(`tS' `t`m'') hazard(`hazard1' `hazard1')
			local atrisk = r(atrisk)	// no. at risk at stage `m1'
			local g = `ev`m'' - r(e`m') 	// discrepancy function whose solution for r(e`m') at g = 0 is sought
			F `dt`m'' `hazard1'
			local gprime = -`acc`m'' * r(F) - `atrisk' * `hazard1' * (1 - r(F))
			if abs(`gprime') < 1e-10 {
				local errmess "design is infeasible - insufficient patients to accrue `ev`m'' events in stage `m'"
				di as err `"`errmess'"'
				return local errmess `errmess'
				exit 498
			}
			local t`m' = `t`m'' - `g' / `gprime'
			local ++i
		}
		return scalar t`m' = `t`m''
		return scalar err`m' = `g'
		return scalar iter`m' = `i'
		di "Stage `m': t = " %8.0g `t`m''
		if `tstop' > 0 & `tstop' < `t`m'' {
			local errmess "design is infeasible - tstop occurs in stage `m' (too early - before final stage)"
			di as err `"`errmess'"'
			return local errmess `errmess'
			exit 498
		}
	}
	else /* `m' == `nstage' */ {
		// Get D-events up to stage m - 1 = `m1'
		qui evfromtin4, accrual(`accrueS') times(`tS') hazard(`hazard2' `hazard2')
		local ev21 = r(e`m1')
		if `ev21' >= `ev`m'' {
			di "Stage `m': already expecting `ev21' events in (0," %8.0g `t`m1'' ")"
			return scalar t`m' = `t`m1''
			return scalar ev21 = `ev21'
			return local enough enough
			continue, break
			// exit
		}
		local g `ev`m''
		local t`m' = `t`m1'' + 0.5 * `median2'	// starting value
		local i 0
		quietly while abs(`g') > `tol' & `i' < 500 {
			local dt`m' = `t`m'' - `t`m1''
			if `dt`m'' <= 0 {
				local t`m' = 1.001 * `t`m1''
				local dt`m' = `t`m'' - `t`m1''
			}
			if `tstop' == 0 | (`tstop' > 0 & `tstop' >= `t`m'') {
				evfromtin4, accrual(`accrueS' `acc`m'') times(`tS' `t`m'') hazard(`hazard2' `hazard2')
				local atrisk = r(atrisk)	// no. at risk at stage `m1'
				local g = `ev`m'' - r(e`m') 	// discrepancy function to be optimized to zero
				F `dt`m'' `hazard2'
				local gprime = -`acc`m'' * r(F) - `atrisk' * `hazard2' * (1 - r(F))
			}
			else { // recruitment ceases between stage m-1 and stage m
				evfromtin4, accrual(`accrueS' `acc`m'') times(`tS' `t`m'') hazard(`hazard2' `hazard2') tstop(`tstop')
				local g = `ev`m'' - r(e`m')
				local atrisk = r(atrisk)	// no. at risk at tstop
				F "`t`m'' - `tstop'" `hazard2'
				local gprime = -`atrisk' * `hazard2' * (1 - r(F))
			}
			if abs(`gprime') < 1e-10 {
				di as err "Design is infeasible - insufficient patients to accrue `ev`m'' events in stage `m'"
				exit 498
			}
			local t`m' = `t`m'' - `g' / `gprime'
			local ++i
		}
		return scalar t`m' = `t`m''
		return scalar err`m' = `g'
		return scalar iter`m' = `i'
		di "Stage `m': t = " %8.0g `t`m''
	}
}
end


********************************************************************************************

********************************************************************************************


cap program drop F
program define F, rclass
* Evaluate exponential distribution function at time t with hazard h
args t h
return scalar F=(1-exp(-(`h')*(`t')))
end




********************************************************************************************

********************************************************************************************


* hrcorrnstage for calculating between stage correlation using simulation
* v 1.3 BO/PR 10Oct13. 

cap program drop hrcorrnstage
program define hrcorrnstage, rclass
version 10.0

syntax, accrue(string) t(string) HR0(string) HR1(string) nstage(int) rep(int) ///
	[ARAtio(string) Rho(string) ALpha(string) Omega(string) n(string) e(string) seed(int -1) ///
	INToutcome(string) CI(int 95) savehr(string) HYPothesis(string)] 

if `seed'>0 set seed `seed'

if `nstage' <= 1 {
	di as err "nstage must be more than 1"
	exit 198
}

if `ci' >= 100 {
	di as err "ci must be smaller than 100"
	exit 198
}

if `"`rho'"' != "" {
	confirm num `rho'
	if `rho' > 1 {
		di as err "rho must be smaller than 1"
		exit 198
	}
}

if `"`alpha'"' == "" & `"`omega'"' == "" & `"`n'"' == ""  & `"`e'"' == ""   {
	di as err "specify alpha and omega or n and e"
	exit 198
}

if (`"`alpha'"' != "" & `"`omega'"' == "") | (`"`alpha'"' == "" & `"`omega'"' != "")   {
	di as err "omega and alpha must be specified together"
	exit 198
}

if (`"`n'"' != "" & `"`e'"' == "") | (`"`n'"' == "" & `"`e'"' != "")   {
	di as err "n and e must be specified together"
	exit 198
}

local arm 
forvalues k = 1 / `nstage' {
	local arm `arm' 2 
}

// Assign values of accrue n e for all stages
local opts accrue n e  
local nopts: word count `opts'
tokenize `opts'
forvalues i = 1 / `nopts' {
	local opt ``i''
	forvalues j = 1 / `nstage' {
		local stage S`j'
		local `opt'`stage': word `j' of ``opt''
		confirm number ``opt'`stage''
	}
}
forvalues k = 1 / `nstage' {
	local n`k' = ceil(`nS`k'')
	local e`k' = ceil(`eS`k'')
}


local item: word count `hr0'  
local opts2 t hr0 hr1
local nopts2: word count `opts2'
tokenize `opts2'
forvalues i = 1 / `nopts2' {
	local opt2 ``i''
	forvalues j = 1 / `item' {
		local stage `j'
		local `opt2'`stage': word `j' of ``opt2''
		confirm number ``opt2'`stage''
	}
}

* Rstar is allocation ratio to E arm: #pts to 1E for 1 pt to C
if "`aratio'" != "" {
	confirm num `aratio'
	local Rstar `aratio'
}
else local Rstar 1
local p = 1/(1+`Rstar')

local intstage = `nstage'-1

*local hrlist 
forvalues j = 0/1 {
	local hrlistH`j'
	forvalues k = 1 / `nstage' {
		local hrlistH`j' `hrlistH`j'' hr`k'H`j'
	}
}


*local hroslist 
forvalues j = 0/1 {
	local hroslistH`j'
	forvalues k = 1 / `intstage' {
		local hroslistH`j' `hroslistH`j'' hros`k'H`j'
	}
}

/*
if `"`hypothesis'"' == "H0" {
	forvalues i = 1/`item' {
		local hr1`i'=`hr0`i'' 
	}
}
*/
preserve

tempname tmp

tempfile output

tempvar x1H0 x2H0 x1H1 x2H1 x3H0 x3H1 y1H0 y1H1 y2H0 y2H1 group lamb10 lamb20 lamb11 lamb21 ///
	xtot1H0 xtot1H1 stage surid1H0 surid1H1 osH0 osH1 surid1_osH0 surid1_osH1 xtot1_x2H0 xtot1_x2H1 d10 d11
local current 0
local postf					
forvalues j=1/`nstage'{
	forvalues i=0/1 {
		local postf "`postf' d`j'`i'"
	}
}

postfile `tmp' `hrlistH0' `hrlistH1' `hroslistH0' `hroslistH1' `postf' using `"`output'"'
	qui forvalues i=1/`rep' {
		local aid `i'
		drop _all
		set obs `n1' 
		* STAGE 1 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		gen byte `group' = _n>(_N*`p') 

		local lambda20 = log(2)/`t2'
		local lambda30 = log(2)/`t1'
		local lambda21 = (log(2)*`hr12')/`t2'
		local lambda31 = (log(2)*`hr11')/`t1'


		if "`intoutcome'" == "" | "`intoutcome'"=="I" {

			local lo0 =`lambda30' - `lambda20'
			local hi0 =`lambda30'
	
			bisect hazmini X `lambda20' `rho'  returns exp Lambda=`lambda30' from `lo0' to `hi0'
			local lambda10 = $S_1 
	
			local lo1 =`lambda31'-`lambda21'
			local hi1 =`lambda31'
		
			bisect hazmini X `lambda21' `rho' returns exp Lambda=`lambda31' from `lo1' to `hi1'
			local lambda11 = $S_1 
			
			mkbilogn `lamb10' `lamb20',r(`rho') /* lamb10 and lamb20 are correlated lognormals */
			
				
			/*The following commands generate PS and OS under H0 and H1*/

			
			forval i = 1/2{
				gen `x`i'H0' = -ln(normal(ln(`lamb`i'0')))*(1/`lambda`i'0') /*Generating PS and OS under H0*/
			}				
	
			forval i = 1/2 {
				gen `x`i'H1' = -ln(normal(ln(`lamb`i'0')))*(1/`lambda`i'0') if `group' == 0
			}
			
			mkbilogn `lamb11' `lamb21',r(`rho') /* lamb11 and lamb21 are correlated lognormals */
				
			forval i = 1/2 {
				replace `x`i'H1' = -ln(normal(ln(`lamb`i'1')))*(1/`lambda`i'1') if `group' == 1 /*Generating PS and OS under H1*/
			}	
			
			forval i = 0/1 {
				gen `x3H`i'' = min(`x1H`i'',`x2H`i'')			/*Generating PFS and OS under H0 and H1*/
			}	
		}
		
		else if "`intoutcome'" == "D" {
			gen `x2H0' = -ln(1-uniform())/`lambda20' /* exp dist under H0*/
				
			gen `x2H1' = -ln(1-uniform())/`lambda20' if `group' == 0	/* exp dist with given hazard */
			replace `x2H1' = -ln(1-uniform())/`lambda21' if `group' == 1	/* exp dist with given hazard */
				
			forval i = 0/1 {
				gen `x3H`i''=`x2H`i'' /* It is needed for later stages because x3 will be modified later in stage 1 due to censoring*/ 
			}
		}

		gen `stage'=1
	
		forval i = 0/1 {
			gen `y1H`i'' = (`n1'/`accrueS1')*uniform() /*arrival times*/
			gen `xtot1H`i'' = `x3H`i'' + `y1H`i''
			sort `group' `xtot1H`i''
			local timeev1H`i' = `xtot1H`i''[`e1']
			
			gen byte `surid1H`i'' = (`xtot1H`i'') <= (`timeev1H`i'')
			replace `x3H`i'' = `timeev1H`i''-`y1H`i'' if `surid1H`i'' == 0 /*admin. censoring*/
			replace `x3H`i'' = 0 if `x3H`i'' < 0
			stset `x3H`i'', failure(`surid1H`i'')

			logranksb _t _d, by(`group') 
			local expec1 = r(expected2)
			local obs1 = r(observed2)
			local expec0 = r(expected1)
			local obs0 = r(observed1)
			local hr1H`i' = (`obs1'/`expec1')/(`obs0'/`expec0') 

			gen `osH`i'' = `x2H`i''
			gen `xtot1_x2H`i'' = `osH`i'' + `y1H`i''		
			gen byte `surid1_osH`i'' = (`xtot1_x2H`i'') <= (`timeev1H`i'')
			*Find corresponding # D events when interim triggered by I events *
			count if `surid1_osH`i''==1 & `group'==0
			local `d1`i'' = r(N)
			scalar d1`i' = r(N)
			***************************************************
			replace `osH`i'' = `timeev1H`i''-`y1H`i'' if `surid1_osH`i'' == 0 /*admin. censoring*/
			replace `osH`i'' = 0 if `osH`i'' < 0
			stset `osH`i'', failure(`surid1_osH`i'')

			logranksb _t _d, by(`group') 
			local expec1 = r(expected2)
			local obs1 = r(observed2)
			local expec0 = r(expected1)
			local obs0 = r(observed1)
			local hros1H`i' = (`obs1'/`expec1')/(`obs0'/`expec0') 
			
			gen `y2H`i'' = .
		}
		
		
	
		
		* STAGE 2 to the penultimate stage !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		* uses survival times simulated in Stage 1 but cuts off after a higher number of events and runs survival analysis
		* need to add extra patients accrued after Stage 1

		if `intstage'>1	{
		
			forvalues k = 2 / `intstage' {
			
				tempvar group2 x4H0 x4H1 x5H0 x5H1 la40 la50 la41 la51 y4H0 y4H1 y5H0 y5H1 stage2 xtot`k'H0 xtot`k'H1 ///
				surid`k'H0 surid`k'H1 osH0 osH1 surid`k'_osH0 surid`k'_osH1 xtot`k'_x2H0 xtot`k'_x2H1 d`k'0 d`k'1

				set obs `n`k''
				local j=`k'-1
				local ni`k'=`n`k''-`n`j''
				gen `group2' = 0 if _n < (`ni`k''*`p') | _n == (`ni`k''*`p')
				replace `group2' = 1 if _n < (`ni`k'') & _n > (`ni`k''*`p') | _n == (`ni`k'')

				if "`intoutcome'"=="" | "`intoutcome'"=="I" {
	
					local lam40 = `lambda10'
					local lam41 = `lambda11'
					local lam50 = `lambda20'
					local lam51 = `lambda21'

					mkbilogn `la40' `la50',r(`rho') /* la40 and la40 are correlated lognormals */
					
				
					/*The following commands generate PS and OS under H0 and H1*/

					
					forval i = 4/5{
						gen `x`i'H0' = -ln(normal(ln(`la`i'0')))*(1/`lam`i'0') /*Generating PS and OS under H0*/
					}					
					
					forval i=4/5{
						gen `x`i'H1' = -ln(normal(ln(`la`i'0')))*(1/`lam`i'0') if `group2' == 0
					}
			
					mkbilogn `la41' `la51',r(`rho') /* lamb10 and lamb20 are correlated lognormals */
			
					forval i=4/5{
						replace `x`i'H1' = -ln(normal(ln(`la`i'1')))*(1/`lam`i'1') if `group2' == 1
					}
					
					forval i = 0/1 {
						gen `y4H`i'' = `timeev`j'H`i''+((`ni`k''/`accrueS`k'')*uniform()) if _n<(`ni`k'') | _n == (`ni`k'')
						gen `y5H`i'' = . if _n < (`ni`k'') | _n == (`ni`k'')
					}
					
	
		
					gen `stage2' = `k' if _n < (`ni`k'') | _n == (`ni`k'')
	
					local nmax = max(`ni`k'',`n`j'')
		
					drop if _n > `nmax'

					if `n`j''>=`ni`k'' {
						stack `group' `x1H0' `x1H1' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage' ///
							 `group2' `x4H0' `x4H1' `x5H0' `x5H1' `y5H0' `y5H1' `y4H0' `y4H1' `stage2', ///
						 into(`group' `x1H0' `x1H1' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage') clear
					}
					else {
						stack `group2' `x4H0' `x4H1' `x5H0' `x5H1' `y5H0' `y5H1' `y4H0' `y4H1' `stage2' ///
							   `group' `x1H0' `x1H1' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage', ///
						 into(`group' `x1H0' `x1H1' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage') clear
					}
				
					drop if _n > `n`k''
					
					forval i = 0/1 {
						replace `y1H`i'' = `y2H`i'' if `y1H`i'' == .
						gen `x3H`i'' = min(`x1H`i'',`x2H`i'')			/*Generating PFS and OS under H0 and H1*/
					}
				
				}
				
				else if "`intoutcome'"=="D" {

					gen `x5H0' = -ln(1-uniform())/`lambda20'
					
					gen `x5H1' = -ln(1-uniform())/`lambda20' if `group2' == 0	/* exp dist with given hazard */
					replace `x5H1' = -ln(1-uniform())/`lambda21' if `group2' == 1	/* exp dist with given hazard */
					
					forval i = 0/1 {
						gen `y4H`i'' = `timeev`j'H`i''+((`ni`k''/`accrueS`k'')*uniform()) if _n<(`ni`k'') | _n == (`ni`k'')
						gen `y5H`i'' = . if _n<(`ni`k'') | _n==(`ni`k'')
					}
					
					gen `stage2'=`k' if _n<(`ni`k'') | _n == (`ni`k'')
	
					local nmax = max(`ni`k'',`n`j'')
					
					drop if _n > `nmax'

					if `n`j''>=`ni`k'' {
						stack `group' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage' ///
							 `group2' `x5H0' `x5H1' `y5H0' `y5H1' `y4H0' `y4H1' `stage2', ///
						 into(`group' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage') clear
					}
					else {
						stack `group2' `x5H0' `x5H1' `y5H0' `y5H1' `y4H0' `y4H1' `stage2' ///
							   `group' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage', ///
						 into(`group' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage') clear
					}
				
					drop if _n > `n`k''		
					
					forval i = 0/1 {
						replace `y1H`i'' = `y2H`i'' if `y1H`i'' == .
						gen `x3H`i'' = `x2H`i''	/* It is needed for later stages because x3 will be modified later in stage 1 due to censoring*/ 
					}					
				}
				
				forval i = 0/1 {
					gen `xtot`k'H`i'' = `x3H`i''+`y1H`i''
					sort `group' `xtot`k'H`i''
					local timeev`k'H`i' = `xtot`k'H`i''[`e`k'']

					gen byte `surid`k'H`i'' = (`xtot`k'H`i'') <= (`timeev`k'H`i'')
					replace `x3H`i'' = `timeev`k'H`i''-`y1H`i'' if `surid`k'H`i''==0 /*admin. censoring*/
				
					replace `x3H`i''=0 if `x3H`i''<0
					stset `x3H`i'', failure(`surid`k'H`i'')

					logranksb _t _d, by(`group') 
					local expec1 = r(expected2)
					local obs1 = r(observed2)
					local expec0 = r(expected1)
					local obs0 = r(observed1)
					local hr`k'H`i' = (`obs1'/`expec1')/(`obs0'/`expec0') 
					
					gen `osH`i''=`x2H`i''
					gen `xtot`k'_x2H`i'' = `osH`i''+`y1H`i''	
					gen byte `surid`k'_osH`i'' = (`xtot`k'_x2H`i'') <= (`timeev`k'H`i'')
					* Find corresponding # D-events when interim k triggered by I-events
					count if `surid`k'_osH`i''==1 & `group'==0
					local `d`k'`i'' = r(N)
					scalar d`k'`i' = r(N)
					***************************************************
					replace `osH`i'' = `timeev`k'H`i''-`y1H`i'' if `surid`k'_osH`i'' == 0 /*admin. censoring*/
					replace `osH`i'' = 0 if `osH`i'' < 0
					stset `osH`i'', failure(`surid`k'_osH`i'')

					logranksb _t _d, by(`group') 
					local expec1=r(expected2)
					local obs1=r(observed2)
					local expec0=r(expected1)
					local obs0=r(observed1)
					local hros`k'H`i' = (`obs1'/`expec1')/(`obs0'/`expec0') 
				}
			}
		}
		
************************ Last stage: anaylsis, i.e calculating the HR on primary outcome **********************

		tempvar group2 x5H0 x5H1 y4H0 y4H1 y5H0 y5H1 stage`nstage' xtot`nstage'H0 xtot`nstage'H1 surid`nstage'H0 surid`nstage'H1 d`nstage'0 d`nstage'1

		set obs `n`nstage''
		local nD = `n`nstage'' - `n`intstage''
		gen `group2' = 0 if _n < (`nD'*`p') | _n == (`nD'*`p')
		replace `group2' = 1 if _n < (`nD') & _n > (`nD'*`p') | _n == (`nD')
								
		gen `x5H0' = -ln(1-uniform())/`lambda20' /* exp dist under the null hypothesis */

		gen `x5H1' = -ln(1-uniform())/`lambda20' if `group2'==0	/* exp dist under the H1 */
		replace `x5H1' = -ln(1-uniform())/`lambda21' if `group2'==1	/* exp dist under the H1 */

		
		forval i = 0/1 {
			gen `y4H`i'' = `timeev`intstage'H`i''+((`nD'/`accrueS`nstage'')*uniform()) if _n < (`nD') | _n == (`nD')
			gen `y5H`i'' = . if _n < (`nD') | _n == (`nD')
		}
		
		gen `stage`nstage'' = `nstage' if _n < (`nD') | _n == (`nD')

		local nDmax = max(`n`intstage'',`nD')
		
		drop if _n > `nDmax'

		if `n`intstage'' >= `nD' {
			stack `group' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage' ///
				 `group2' `x5H0' `x5H1' `y5H0' `y5H1' `y4H0' `y4H1' `stage`nstage'', ///
			into(`group' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage') clear	 
		}
		
		else {
		
			stack `group2' `x5H0' `x5H1' `y5H0' `y5H1' `y4H0' `y4H1' `stage`nstage'' ///
				   `group' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage', ///
			  into(`group' `x2H0' `x2H1' `y1H0' `y1H1' `y2H0' `y2H1' `stage') clear		
		}

		
		drop if _n > `n`nstage''
		
		forval i = 0/1 {
		
			replace `y1H`i'' = `y2H`i'' if `y1H`i'' == .
			gen `xtot`nstage'H`i'' = (`y1H`i''+`x2H`i'')
			sort `group' `xtot`nstage'H`i''
			local timeev`nstage'H`i' = `xtot`nstage'H`i''[`e`nstage'']
			gen byte `surid`nstage'H`i'' = (`xtot`nstage'H`i'') <= (`timeev`nstage'H`i'')
			* # D-events at final stage - should equal eJ input by user/nstage*
			count if `surid`nstage'H`i''==1 & `group'==0
			local `d`nstage'`i'' = r(N)
			scalar d`nstage'`i' = r(N)
			***************************************************
			replace `x2H`i''=`timeev`nstage'H`i'' - `y1H`i'' if `surid`nstage'H`i''==0 /*admin censoring*/
			stset `x2H`i'', failure(`surid`nstage'H`i'')

			logranksb _t _d, by(`group')
			local chi31=r(chi2)
			local expec1=r(expected2)
			local obs1=r(observed2)
			local expec0=r(expected1)
			local obs0=r(observed1)
			local hr`nstage'H`i' = (`obs1'/`expec1')/(`obs0'/`expec0')

		}	
			
		*local hrsp 
		local par1 "(" 
		local par2 ")"
		forvalues j = 0/1 {	
			local hrspH`j'
			forvalues k = 1 / `nstage' {
				local hrspH`j' `hrspH`j'' `par1'`hr`k'H`j''`par2'
			}
		}
		
		*local hrossp 
		local par1 "(" 
		local par2 ")"
		forvalues j = 0/1 {	
			local hrosspH`j'
			forvalues k = 1 / `intstage' {
				local hrosspH`j' `hrosspH`j'' `par1'`hros`k'H`j''`par2'
			}
		}

		local to_post					// NEW
		forvalues j=1/`nstage'{
			forvalues i=0/1 {
				local to_post "`to_post' (d`j'`i')"
			}
		}
		di "to_post = " `to_post'		// NEW
		
		post `tmp' `hrspH0' `hrspH1' `hrosspH0' `hrosspH1' `to_post'			// NEW
		local aidperc = round(100*`aid'/`rep',0.5)
		*if mod(`aid', 500) == 0 noi di as txt ".. `aidperc'%", _cont
		
		if mod(`aidperc', 2) == 0 &  mod(`aidperc', 10) != 0 & `aidperc' != `current' {
			noi di as text . _cont
			local current = `aidperc'
		}
			
		if mod(`aidperc', 10) == 0 & `aidperc' != `current' {
			noi di as txt "`aidperc'%" _cont
			local current = `aidperc'
		}
		

		*noi di as text "." _cont
		
	}
	postclose `tmp'

use `"`output'"', clear /* need to see whether clear is needed or use preserve-restore command*/

* Get mean # OS events at each stage from postfile *
forvalues j=1/`nstage' {
	forvalues i=0/1 {
		summ d`j'`i', meanonly
		local d`j'`i' = r(mean)
		local d`j'`i' = ceil(`d`j'`i'')
	}
}

if "`savehr'" != "" {
	label var hr`nstage'H0 "Estimated HR on primary outcome at the final stage under H0"
	label var hr`nstage'H1 "Estimated HR on primary outcome at the final stage under H1"
	forvalues j=1/`intstage' {
		label var hr`j'H0 "Estimated HR on intermidate outcome at stage `j' under H0"
		label var hr`j'H1 "Estimated HR on intermidate outcome at stage `j' under H1"
		label var hros`j'H0 "Estimated HR on primary outcome at stage `j' under H0" 
		label var hros`j'H1 "Estimated HR on primary outcome at stage `j' under H1"
	}
	if "`intoutcome'"=="D" {
		drop `hroslistH0' `hroslistH1'
	}
	qui save "`savehr'", replace
}

forvalues j = 0/1 {	
	forvalues v = 1 / `nstage' {
		tempvar lnhr`v'H`j'
		gen `lnhr`v'H`j'' = log(hr`v'H`j')
	}
}

forvalues j = 0/1 {		
	local lnhrlistH`j' 
	forvalues w = 1 / `nstage' {
		local lnhrlistH`j' `lnhrlistH`j'' `lnhr`w'H`j''
	}
}
	
/*
tempname corrhr corrlnhr


qui corr `hrlist'
matrix `corrhr' = r(C)


forvalues z = 1 / `intstage' {
	local z1 = `z' + 1
	forvalues zz = `z1' / `nstage' {
		local cor`zz'`z' = `corrhr'[`zz',`z']
		local cor`z'`zz' = `cor`zz'`z''
	}
}

*/


forvalues j = 0/1 {		
	tempname corrhrH`j' corrlnhrH`j'
	qui cor `hrlistH`j''
	matrix `corrhrH`j'' = r(C)
	qui cor `lnhrlistH`j''
	matrix `corrlnhrH`j'' = r(C)

	forvalues h = 1 / `intstage' {
		local h1 = `h' + 1
		forvalues hh = `h1' / `nstage' {
		
			local cor`hh'`h'H`j' = `corrhrH`j''[`hh',`h']
			local cor`h'`hh'H`j' = `cor`hh'`h'H`j''		
		
			local corln`hh'`h'H`j' = `corrlnhrH`j''[`hh',`h']
			local corln`h'`hh'H`j' = `corln`hh'`h'H`j''
		}
	}
}
	
if "`intoutcome'"=="" | "`intoutcome'"=="I" {
	forvalues j = 0/1 {	
		forvalues f = 1 / `intstage' {
			qui corr hr`f'H`j' hros`f'H`j'
			local corrfix`f'H`j' = r(rho)
			local c`f'H`j' = (1.1*`corrfix`f'H`j'') /* This formula has been suggested in Royston et al (2009) MAMS Stop Guide Stat. Med. paper */
		}
	}	
}

forvalues j = 0/1 {
	tempname corrRIH`j'
	matrix `corrRIH`j'' = I(`nstage')
	forvalues m = 1 / `nstage' {
		return scalar d`m'`j' = `d`m'`j''					// Saves D-events at interim analyses based on I-events
		local m1 = `m'+1
		forvalues n = `m1' / `nstage' {
			local cor_RI`m'`n'H`j' = sqrt(`e`m''/`e`n'')  /* RI stands for Royston & Isham */
			matrix `corrRIH`j''[`n',`m'] = `cor_RI`m'`n'H`j''
			matrix `corrRIH`j''[`m',`n'] = `cor_RI`m'`n'H`j''
		}
		if ("`intoutcome'"=="" | "`intoutcome'"=="I") & `m'<`nstage' {
			matrix `corrRIH`j''[`nstage',`m']= `c`m'H`j''*`cor_RI`m'`nstage'H`j''
			matrix `corrRIH`j''[`m',`nstage']= `c`m'H`j''*`cor_RI`m'`nstage'H`j''
		}
	}
}


forvalues j = 0/1 {
	local loghrlistH`j'
	forvalues k = 1 / `nstage' {
		local loghrlistH`j' `loghrlistH`j'' loghr`k'H`j'
	}
}

forvalues j = 0/1 {
	matrix rownames `corrRIH`j'' = `hrlistH`j''
	matrix colnames `corrRIH`j'' = `hrlistH`j''
	matrix rownames `corrlnhrH`j'' = `loghrlistH`j''
	matrix colnames `corrlnhrH`j'' = `loghrlistH`j''
}

forvalues k = 0/1 {
	forvalues i = 1 / `intstage' {
		local i1 = `i' + 1
		forvalues j = `i1' / `nstage' {
			return scalar corr`i'`j'H`k' = `cor`i'`j'H`k''
			return scalar corrln`i'`j'H`k' = `corln`i'`j'H`k''
			if "`intoutcome'" == "D" {
				return scalar corr_RI`i'`j'H`k'=`cor_RI`i'`j'H`k''
			}	
			if "`intoutcome'" == "" | "`intoutcome'"=="I" {
				return scalar c`i'H`k'=`c`i'H`k''
			}
		}
	}	
}
	

* Generate correlation matrix based on D-events for ESB when I!=D *
if "`intoutcome'"=="" | "`intoutcome'"=="I" {
	forvalues j = 0/1 {
		tempname corrEB`j'
		matrix `corrEB`j'' = I(`nstage')
		forvalues m = 1 / `nstage' {
			local m1 = `m'+1
			forvalues n = `m1' / `nstage' {
				local cor_EB`m'`n'H`j' = sqrt(`d`m'`j''/`d`n'`j'')  /* RI stands for Royston & Isham */
				matrix `corrEB`j''[`n',`m'] = `cor_EB`m'`n'H`j''
				matrix `corrEB`j''[`m',`n'] = `cor_EB`m'`n'H`j''
			}
		}
	}
}
	
forvalues j = 0/1 {
	return matrix CorrhrH`j' = `corrhrH`j''
	return matrix CorrlnhrH`j' = `corrlnhrH`j''
	return matrix Corrhr_RIH`j' = `corrRIH`j''
	return matrix Corrhr_EB`j' = `corrEB`j''	//NEW
}

clear
erase `output'
restore
end



********************************************************************************************

********************************************************************************************


* version 1.0.0 PR 06mar2004.
cap program drop hazmin
program define hazmin, rclass
* Calculates hazard for minimum of 2 correlated exponentials with correlation rho in original bivariate normals
version 8
syntax , L1(string) L2(string) Rho(string) [Median]
tokenize `l1' `l2' `rho'
while "`1'"!="" {
	local 1=(`1')
	confirm number `1'
	mac shift
}
if `rho'<=0 | `rho'>=1 {
	di as err "rho() must be between 0 and 1"
	exit 198
}
if `l1'<=0 | `l2'<=0 {
	di as err "l1() and l2() must be positive"
	exit 198
}
tempname b0 b1 power beta lambda
scalar `b0'=8.848
scalar `b1'=-8.063
scalar `power'=0.1
if "`median'"!="" {	/* convert medians to hazards */
	forvalues j=1/2 {
		local l`j'=ln(2)/`l`j''
	}
}
if `l1'<`l2' {
	local lambda1 `l2'
	local lambda2 `l1'
}
else {
	local lambda1 `l1'
	local lambda2 `l2'
}
scalar `beta'=`b0'+`b1'*(`lambda2'/`lambda1')^`power'
scalar `lambda'=`lambda1'+`lambda2'*(1-`rho')^`beta'
di as text "Lambda (hazard) = " `lambda'
return scalar beta=`beta'
return scalar lambda=`lambda'
end


********************************************************************************************

********************************************************************************************


* version 1.0.0 PR 06mar2004.
cap program drop hazmini
program define hazmini
* Evaluates lambda (hazard of min of 2 correlated exponentials) for given l1, l2, rho, assuming nomedian.
* Args 1=l1, 2=l2, 3=rho. Stores result in scalar Lambda.
qui hazmin, l1(`1') l2(`2') rho(`3')
scalar Lambda=r(lambda)
end


********************************************************************************************

********************************************************************************************



* mkbilogn2 using mkbilogn.ado version 1.1.1 spj revised 27 Jan 98   STB-48 sg105
* Syntax: mkbilogn var1 var2, r(#) m1(#) s1(#) m2(#) s2(#)
*			 [defaults #=0.5,0,1,0,1; respectively]
cap program drop mkbilogn
prog def mkbilogn
	version 5.0
	local varlist "req new min(2) max(2)"
	local options "Rho(real 0.5) m1(real 0) m2(real 0) s1(real 1) s2(real 1)"
	parse "`*'"
	if `rho' < -1 | `rho' >= 1 {
		di in red "Need rho s.t. -1 <= rho < 1"
		exit 198    /* need rho ~= 1 or Cholesky fails */ 
	}
	if `s1' <=0 | `s2' <= 0 {
		di in red "Std. dev. must be positive"
		exit 198
	}
	parse "`varlist'", parse(" ")

	di "Creating 2 r.v.s X1 X2  s.t. x1=log(X1), x2=log(X2) are bivariate" 
	di " Normal with mean(x1) = `m1' ; mean(x2) = `m2' ; s.d.(x1) = `s1' ;"
	di " s.d.(x2) = `s2' ; corr(x1,x2) = `rho' "

	/* Method of creation based on Stata FAQ at
	 	http://www.stata.com/support/faqs/stat/mvnorm.html */

	tempname a1 a2 A P var1 var2 c1 c2 lnc1 lnc2

	matrix `P' = (1,`rho'\ `rho',1)
	matrix `A' = cholesky(`P')
	matrix colnames `A' = `lnc1' `lnc2'

	quietly {

	ge `c1' = exp(invnorm(uniform()))
	ge `c2' = exp(invnorm(uniform()))

	ge `lnc1' = ln(`c1')
	ge `lnc2' = ln(`c2')

	matrix `a1' = `A'[1,.]
	matrix score `var1' = `a1'
	matrix `a2' = `A'[2,.]
	matrix score `var2' = `a2'

	replace  `1' = exp(`s1'*`var1' + `m1')
	replace  `2' = exp(`s2'*`var2' + `m2')

	}
end

/*

Note:

mean,variances,corr refer to mean,variances,corr
of the log of the vbles.

Mean of lognormal distribution: exp[mu + (sig_sq/2)]
Variance of lognormal distribution:
	[exp(2*mu)]*[exp(2*sig_sq) - exp(sig_sq)]

*/



********************************************************************************************

********************************************************************************************



* version 1.0 SB 06Mar2004
* version 7.0.3  18sep2000
cap program drop logranksb
program define logranksb /* timevar [deadvar] [, by(group) t0(t0) id(tvid)] */, rclass
	version 6.0
	syntax varlist(min=1 max=2) [if] [in] [fw iw] [, /*
		*/ BY(varlist) CHECK Detail ID(varname) LOGRANK /*
		*/ MAT(string) T0(varname) noTItle /*
		*/ STrata(varlist) TVid(varname) trend]
	tokenize `varlist'

	if `"`tvid'"' != `""' {
		local id `"`tvid'"'
		local tvid
	}


	if `"`strata'"' != `""' {
		if `"`detail'"' != `""' {
			if `"`check'"' != `""' {
				tempname v V vi Vi
				local matopt `"mat(`vi' `Vi')"'
			}
			tempvar touse  sv j
			mark `touse' `if' `in' [`weight'`exp']
			markout `touse' `varlist' `t0'
			markout `touse' `by' `strata', strok
			sort `touse' `strata'
			qui {
				by `touse' `strata': /* 
				*/ gen `sv'=cond(_n==1 & `touse',1,0)
				replace `sv' = sum(`sv')
				qui gen long `j' = _n
				compress `j' `sv'
			}
			if `"`t0'"' != `""' {
				local t0opt `"t0(`t0')"'
			}
			if `"`id'"' != `""' {
				local idopt `"id(`id')"'
			}
			local nsv = `sv'[_N]
			Title `"`title'"' `"`strata'"'
			local i 1 
			while `i' <= `nsv' {
				qui sum `j' if `sv'==`i'
				local x = `strata'[_result(5)]
				di _n in gr `"-> `strata' = `x'"'
				logrank `varlist' [`weight'`exp'] /* 
				*/ if `touse' & `sv'==`i' /* 
				*/ , by(`by') `t0opt' `idopt' `matopt' notitle
				if `"`check'"' != `""' {
					if `i'==1 {
						mat `v' = `vi'
						mat `V' = `Vi'
					}
					else {
						mat `v' = `v' + `vi'
						mat `V' = `V' + `Vi'
					}
				}
				local i = `i' + 1
			}
			di 
			di in gr `"-> Total"'
			logrank `varlist' [`weight'`exp'] if `touse' /*
			*/ , by(`by') `t0opt' `idopt' strata(`strata') /*
			*/ `trend' notitle
			if `"`check'"' != `""' {
				mat `V' = syminv(`V')
				mat `V' = `v'*`V'
				mat `V' = `V'*`v' '
				di `"CHECK:  "' `V'[1,1]
				global S_7 = `V'[1,1]
			}
			exit
		}
	}

	local t1 `"`1'"'
	if `"`2'"'==`""' {
		tempvar dead
		qui gen byte `dead' = 1
	}
	else	local dead `"`2'"'

	tempvar touse
	mark `touse' `if' `in' [`weight'`exp']
	markout `touse' `t1' `dead'
	markout `touse' `by' `strata', strok

	if `"`t0'"'!=`""' & `"`id'"'!=`""' {
		local id
	}
	if `"`t0'"'==`""' & `"`id'"'==`""' {
		tempvar t0
		qui gen byte `t0' = 0
	}
	else if `"`t0'"' != `""' { 
		markout `touse' `t0'
	}
	else if `"`id'"'!=`""' {
		markout `touse' `id'
		quietly {
			sort `touse' `id' `t1'
			local ty : type `t1'
			by `touse' `id': gen `ty' `t0' = /*
				*/ cond(_n==1,0,`t1'[_n-1])
		}
		capture assert `t1'>`t0'
		if _rc {
			di in red `"repeated records at same `t1' within `id'"'
			exit 498
		}
	}

	capture assert `t1'>0 if `touse'
	if _rc { 
		di in red `"survival time `t1' <= 0"'
		exit 498
	}
	capture assert `t0'>=0 if `touse'
	if _rc { 
		di in red `"entry time `t0' < 0"'
		exit 498
	}
	capture assert `t1'>`t0' if `touse'
	if _rc {
		di in red `"entry time `t0' >= survival time `t1'"'
		exit 498
	}
	capture assert `dead'==0 if `touse'
	if _rc==0 { 
		di in red `"no test possible because there are no failures"'
		exit 2000
	}

	preserve 

	if `"`weight'"' != `""' { 
		tempvar w 
		quietly gen double `w' `exp' if `touse'
		local wv `"`w'"'
	}
	else	local w 1

	tempfile lister
	tempvar op g n d
	quietly { 
		keep if `touse'
		keep `wv' `t0' `t1' `by' `strata' `dead'

		sort `by'
		by `by': gen long `g' = 1 if _n==1
		replace `g' = sum(`g') 
		local ng = `g'[_N]
		save `"`lister'"'

		local N = _N
		expand 2 
		gen byte `op' = 3/*add*/ in 1/`N'
		replace `t1' = `t0' in 1/`N'
		drop `t0'
		local N = `N' + 1
		replace `op' = cond(`dead'==0,2/*cens*/,1/*death*/) in `N'/l

		if `"`strata'"'!=`""' {
			local bystr `"by `strata':"'
		}

		sort `strata' `t1' `op' `by'

		`bystr' gen double `n' = sum(cond(`op'==3,`w',-`w'))
		by `strata' `t1': gen `d' = sum(`w'*(`op'==1))

		local i 1
		while `i' <= `ng' { 
			tempvar ni di
			`bystr' gen double `ni' = /*
			*/ sum(cond(`g'==`i', cond(`op'==3,`w',-`w'), 0))
			by `strata' `t1': gen double `di' = /* 
			*/ sum(cond(`g'==`i', `w'*(`op'==1), 0))
			local nlist `"`nlist' `ni'"'
			local dlist `"`dlist' `di'"'
			local i = `i' + 1 
		}
		by `strata' `t1': keep if _n==_N
		tempvar newn
		`bystr' gen double `newn' = `n'[_n-1]
		drop `n' 
		rename `newn' `n'

		local i 1
		while `i' <= `ng' {
			local ni : word `i' of `nlist'
			`bystr' gen double `newn' = `ni'[_n-1] if _n>1
			drop `ni' 
			rename `newn' `ni'
			local i = `i' + 1
		}
		drop if `d'==0

		tempvar wi
		tempname w wo v
		mat `w' = J(1,`ng',0)
		mat `wo' = `w'
		local i 1
		while `i' <= `ng' {
			local ni : word `i' of `nlist'
			local di : word `i' of `dlist'
			gen double `wi' = sum(`ni'*`d'/`n')
			mat `w'[1,`i'] = `wi'[_N]
			drop `wi'
			summ `di'
			mat `wo'[1,`i'] = _result(18)
			local i = `i' + 1
		}
	}

	tempname V
	mat `V' = J(`ng',`ng',0)
	local i 1
	tempvar cons
	qui gen double `cons' = `d'*(`n'-`d')/(`n'*`n'*(`n'-1))
	
	while `i' <= `ng' {
		local ni : word `i' of `nlist'
		local di : word `i' of `dlist'
		gen double `wi' = sum( `ni'*(`n'-`ni')*`cons' )
		mat `V'[`i',`i'] = `V'[`i',`i'] + `wi'[_N]
		drop `wi'
		local j 1
		while `j' < `i' { 
			local nj : word `j' of `nlist'
			local dj : word `j' of `dlist'
			gen double `wi' = sum( -`ni'*`nj'*`cons')
			mat `V'[`i',`j'] = `V'[`i',`j'] + `wi'[_N]
			mat `V'[`j',`i'] = `V'[`i',`j']
			drop `wi'
			local j = `j' + 1
		}
		local i = `i' + 1
	}



	tempname v
	mat `v' = `w' - `wo'
	if `"`mat'"' != `""' {
		parse `"`mat'"', parse(`" "')
		mat `1' = `v'
		mat `2' = `V'
	}

	tempname mV mv
	mat `mV' = `V'
	mat `mv' = `v'
	/* `mV' is the covariate matrix */
	/* `mv' is Z matrix */

	mat `V' = syminv(`V')

	tempname wt
	mat `V' = `v' * `V'
	mat `V' = `V' * `v' '

	quietly { 
		use `"`lister'"', clear 
		by `by': keep if _n==1
		keep `g' `by'
		sort `g'
		tempvar grp X
		gen str50 `grp' = `""' 
		local second 0
		parse `"`by'"', parse(`" "')
		while `"`1'"' != `""' {
			if `second' { 
				local ttlsub = abbrev("`1'",8)
				local ttl `"`ttl', `ttlsub'"'
				local ttlsub
				replace `grp' = `grp' + `", "'
			}
			else {
				if `"`2'"'=="" {
					local ttl = abbrev(`"`1'"', 12)
				}
				else	local ttl = abbrev(`"`1'"', 8)
				local second 1
			}
			local ty : type `1'
			if substr(`"`ty'"',1,3)==`"str"' { 
				replace `grp' = `grp' + /*
				*/ trim(substr(trim(`1'),1,30))
			}
			else {
				local vlab : value label `1'
				if `"`vlab'"' != `""' { 
					decode `1', gen(`X') maxlen(30)
					replace `grp' = `grp' + trim(`X')
					drop `X'
				}
				else	replace `grp' = `grp'+trim(string(`1'))
			}
			mac shift
		}
		compress `grp'
	}
	local len1 = length(`"`ttl'"')
	local ty : type `grp'
	local len2 = substr(`"`ty'"',4,.)
	local len = max(`len1', `len2', 5) + 1

	Title `"`title'"' `"`strata'"'

        di in smcl in gr _n _col(`len') `" {c |}   Events         Events"'
	local pad = `len' - `len1'
	if `"`strata'"'==`""' { local dup `"   expected"' }
	else	local dup `"expected(*)"'
	di in smcl in gr `"`ttl'"' _skip(`pad') `"{c |}  observed    `dup'"'
	di in smcl in gr "{hline `len'}{c +}{hline 25}" 

	local sum 0
	local i 1 
	while `i' <= _N { 
		local x = `grp'[`i']
		local pad = `len' - length(`"`x'"')
		di in smcl in gr `"`x'"' _skip(`pad') "{c |}" in ye /* 
			*/ %10.0g `wo'[1,`i'] `"     "' %10.2f `w'[1,`i']
		ret scalar observed`i' = `wo'[1,`i']
		ret scalar expected`i' = `w'[1,`i']
		local sum = `sum' + `wo'[1,`i']
		local i = `i' + 1
	}
	di in smcl in gr "{hline `len'}{c +}{hline 25}" 
        local pad = `len' - 5
	di in smcl in gr `"Total"' _skip(`pad') `"{c |}"' in ye /* 
			*/ %10.0g `sum' `"     "' %10.2f `sum'

	if `"`strata'"' != `""' {
		di in gr _n `"(*) sum over calculations within `strata'"'	
	}

	local pad = `len' + 7
	ret scalar df = colsof(`w') - 1
	ret scalar chi2 = `V'[1,1]

	/* double save */
	global S_1 `"`by'"'
	global S_5 = colsof(`w') - 1
	global S_6 = `V'[1,1]
	/* double save ends */
	local pad1 = `pad' - ($S_5>=10)
	di _n in gr _col(`pad1') `"chi2($S_5) = "' in ye %10.2f `V'[1,1] 
	di in gr _col(`pad') `"Pr>chi2 = "' in ye %10.4f chiprob($S_5, `V'[1,1])
	if "`trend'"~="" {
		if _N<=2 {
			di in red "trend test requires 3 or more groups"
			exit 198
		}
		_sttrend `mV' `mv' `by' `pad1'  `pad'
		ret add
	}
end

cap program drop Title
program define Title /* <title mark> <strata> */
	local title `"`1'"'
	local strata `"`2'"'

	if `"`title'"' == `""' {
		if `"`strata'"'==`""' {
			di _n(2) in smcl in gr /*
*/ `"{title:Log-rank test for equality of survivor functions}"'
		}
		else	di _n(2) in smcl in gr /*
*/ `"{title:Stratified log-rank test for equality of survivor functions}"'
	}
end




********************************************************************************************

********************************************************************************************


* version 1.1.0  10/14/93              STB-16 ssi5
cap program drop bisect
program define bisect
	version 3.1
	parse "`*'", parse(" X=")

	local toload "exp1"
	while "`1'"!="=" & "`1'"!="returns" & "`1'"!="" {
		if "`1'"=="X" {
			if "`toload'"=="exp2" {
				di in red "X may be specifed only once"
				exit 198
			}
			local toload "exp2"
		}
		else {
			local `toload' "``toload'' `1'"
		}
		mac shift
	}
	if "`toload'"!="exp2" {
		di in red "X must be specified"
		exit 198
	}
	if "`1'"=="" { error 198 }
	if "`1'"=="returns" {
		if "`2'"=="macro" {
			local type "`3'"
			local rtnval
		}
		else if "`2'"=="exp" {
			local rtnval "`3'"
			local type
		}
		else	error 198
		mac shift 3
		local progttl "`exp1' X `exp2'"
		local inline "*"
	}
	else {
		local progttl = substr("`exp2'",2,.)
		local progttl "`exp1'X`progttl'"
		local callout "*"
	}
	if "`1'" != "=" { 
		di in red "=exp required"
		exit 198
	}
	mac shift
	local toload "mval"
	while "`1'"!="" {
		if "`1'"=="to" {
			local toload "mhi"
		}
		else if "`1'"=="from" {
			local toload "mlo"
		}
		else if "`1'"=="tol" {
			local toload "mtol"
		}
		else {
			local `toload' "``toload''`1'"
		}
		mac shift
	}
	if "`mval'"=="" { 
		di in red "= must be followed by expression"
		exit 198
	}
	if "`mhi'"=="" { 
		di in red "to specifier requried"
		exit 198 
	} 
	if "`mlo'"=="" { 
		di in red "from specifier required"
		exit 198 
	}
	tempname flo fhi val lo hi hold ftry tol
	if "`mtol'"=="" {
		scalar `tol' = 1e-6
	}
	else	scalar `tol' = `mtol'
	scalar `val' = `mval' 
	scalar `lo' = `mlo' 
	scalar `hi' = `mhi' 
	scalar `tol' = max(`tol'*abs(`val'),`tol')

	if `lo'>`hi' { 
		scalar `hold' = `lo'
		scalar `lo' = `hi'
		scalar `hi' = `hold'
	}

	local ttl : di "Find `progttl'=f() == c=" `val' ", |f()-c|<" `tol'
	local skip = int((72-length("`ttl'"))/2)
	di in gr _n _skip(`skip') "`ttl'" _n

	`callout' quietly `exp1' `lo' `exp2'
	`callout' scalar `flo' = ${`type'} `rtnval' - `val'
	`inline'  scalar `flo' = (`exp1' `lo' `exp2') - `val'

	`callout' quietly `exp1' `hi' `exp2'
	`callout' scalar `fhi' = ${`type'} `rtnval' - `val'
	`inline'  scalar `fhi' = (`exp1' `hi' `exp2') - `val' 

	di in gr /*
		*/ _col(17) "lower" _col(39) "upper" _n /*
		*/ "iteration" _col(17) "bound" _col(27) "f()-c" /*
		*/ _col(39) "bound" _col(49) "f()-c" /*
		*/ _col(59) "midpoint" _col(72) "f()-c" _n /*
		*/ _dup(76) "-"


	/* verify we bound the solution */
	if `flo'*`fhi'>0 | `flo'*`fhi'==. { 
		di in gr %8.0f 0 ".   " %9.0g `lo' " " %9.0g `flo' /*
			*/ "   " %9.0g `hi' " " %9.0g `fhi'
		display in red "range does not bound solution"
		exit 409
	}
	if `flo'==0 {
		scalar `fhi' = `flo'
		scalar `hi' = `lo'
	}
	else if `fhi'==0 {
		scalar `flo' = `fhi'
		scalar `lo' = `hi'
	}

	local try = (`lo'+`hi')/2
	`callout' quietly `exp1' `try' `exp2'
	`callout' scalar `ftry' = ${`type'} `rtnval' - `val'
	`inline'  scalar `ftry' = (`exp1' `try' `exp2') - `val' 

	local iter -1 
	while abs(`ftry')>`tol' { 
		local iter=`iter'+1
		di in gr %8.0f `iter' ".   " %9.0g `lo' " " %9.0g `flo' /*
			*/ "   " %9.0g `hi' " " %9.0g `fhi' "    " /*
			*/ in ye %9.0g `try' " " %9.0g `ftry'
		if `flo'*`ftry'<0 { 
			scalar `fhi' = `ftry'
			scalar `hi'=`try'
		}
		else {
			scalar `flo' = `ftry'
			scalar `lo' = `try'
		}
		local try = (`lo'+`hi')/2
		`callout' quietly `exp1' `try' `exp2'
		`callout' scalar `ftry' = ${`type'} `rtnval' - `val'
		`inline'  scalar `ftry' = (`exp1' `try' `exp2') - `val'
	}
	di in ye _col(58) %9.0g `try' " " %9.0g `ftry'
	global S_1 = `try'
end






********************************************************************************************

********************************************************************************************


* subroutine for calculating FWER
* DB v0.09
cap program drop nstagefwer

program def nstagefwer, rclass
version 10


/*
	Calculate familywise error rate (FWER) under global null
	of a multi-arm multi-stage trial
	
	v0.01 - I=D
	v0.02 - add correlation matrix to syntax & alter calculation to allow for I!=D
	v0.03 - use preserve and restore instead of tempvars
	v0.04 - calculate P(k arms reaching stage j) (see nstage probs option)
	v0.05 - calculate probs under H1, also P(k arms passing final stage)
	v0.06 - add set seed option
	v0.07 - remove probs calculation under H1 - not useful information
	v0.08 - output SE for FWER & make probs calculation default
	v0.09 - calculate maximum fwer when I!=D
	v0.10 - allow efficacy bounds with separate or simultaneous stopping rule
	      - estimate three measures of power for multi-arm designs
		  - allow calculation of operating characteristics under non-binding futility boundaries
*/

syntax, nstage(int) arms(int) alpha(string) omega(string) corr(name) aratio(real) ///
	[reps(int 250000) seed(int -1) ineqd esb(string) NONBINDing]

if `seed'>0 set seed `seed'
	
local J = `nstage'		// # stages
local Jm1 = `J'-1		// # interim stages
local K = `arms'-1	 	// # E arms
local A = `aratio'		// Allocation ratio
mat def S = `corr'		// correlation between stages under H0

// Stagewise sig. levels and power levels NEW
forvalues j = 1/`J' {
	local alpha`j' : word `j' of `alpha'
	local omega`j' : word `j' of `omega'
}

// Define efficacy boundaries (if specified by user)
if "`esb'"!=""{
	gettoken rule opts : esb, parse(" =,")	
	forvalues j = 1/`J' {
		local t`j' = S[`J',`j']^2				// Obtain information times for interim analyses
		return scalar t`j' = `t`j''
	}
	gettoken rule opts : esb, parse(" =,")	
	if "`rule'"=="hp" {
		if "`opts'"!="" {
			gettoken 1 2: opts, parse(",")
			if "`2'"=="stop" local esbstop = "`2'"
			if "`2'"!=""{
				local pval = "`1'"
				if "`pval'"=="," local pval = ""
				gettoken 1 2: 2, parse(" =,")
				if "`2'"=="stop" local esbstop = "`2'"
			}
			else { 
				local pval = "`1'"
			}
		}
		if "`pval'"!="" {					
			gettoken eq pval : pval, parse(" =")	
			forvalues j = 1/`J' {
				local E`j' `pval'			
			}
		}
		else {
			forvalues j = 1/`J' {
				local E`j' = 0.0005			
			}
		}
	}
	else if "`rule'"=="obf" {
		if "`opts'"!=""{
			gettoken 1 2: opts, parse(",")
			local esbstop = "`2'"
		}
		forvalues j = 1/`J' {
			local E`j'= 2*(1 - normal(invnormal(1 - `alpha`J''/2)/sqrt(`t`j'')))	// Approx. to O'Brien-Fleming rule - Lan & DeMets 1983
			if round(`E`j'',0.001)>round(`alpha`J'',0.001){
					di as error "Warning: efficacy boundary for stage `j' is larger than the final stage significance level"
			}
		}
	}
	else if "`rule'"=="custom" {
		if "`opts'"!=""{
			gettoken eq pval : opts, parse(" =")
			forvalues j = 1/`J' {
				local E`j' : word `j' of `pval'		
				if `j'!=`J'{ 
					capture confirm num `E`j''
					if c(rc) {
						di as error "no custom efficacy bound specified for stage `j'"
						exit 198
					}
				}
			}
			if "`E`J''"!=""{
				capture confirm num `E`J''
				if c(rc)==0 {
					di as error "cannot specify efficacy bound for final stage"
				}
			}
			capture confirm num `E`Jm1''
			if c(rc) {
				gettoken E`Jm1' stop : E`Jm1', parse(",")
				local esbstop = "stop"
			}
		}
		else di as error "p values for custom stopping rule must be specified"
	}
		else {
			di as error "efficacy boundary incorrectly specified"
			exit 198
		}
	forvalues j = 1/`Jm1' {	// Check efficacy bounds are non-decreasing
		local jm1 = `j'-1
		local E0 = 0
		if `E`j''<`E`jm1'' {
			di as error "p-values must be non-decreasing"
			exit 198
		}
		return scalar E`j' = `E`j''
	}
	return local esbstop = "`esbstop'"
}

// Correlation matrix between arms ( = A/A+1)
matrix A = I(`K')

forvalues j = 1/`K' {
	mat def A[`j',`j'] = 1
	
	forvalues k = 1/`K' {
		if `j'!=`k' mat def A[`j',`k'] = `A'/(`A'+1)
	}
}

// Generate correlated standard normal RVs

preserve
drop _all
forvalues k = 0/`K' {
	local X`k' x1`k'
	local sd 1

	forvalues j = 2/`J' {
		local X`k' `X`k'' x`j'`k'
		local sd `sd' \ 1
	}
		
	qui drawnorm `X`k'', corr(S) sd(`sd') n(`reps') double
}

forvalues j = 1/`J' {	
	forvalues k = 1/`K' {
		gen double z`j'`k' = sqrt(`A'/(`A'+1))*x`j'0+sqrt(1/(`A'+1))*x`j'`k'
	}
}

// Flag arms which pass each stage k and any which are dropped for efficacy
forvalues k = 1/`K' {
	scalar pass0`k'=1
	scalar powerpass0`k'=1			
	
	if "`esb'"!="" {
		scalar edrop0`k'=0																		 
	}
	
	forvalues j = 1/`J' {
		local jm1 = `j'-1
		gen byte pass`j'`k' = (z`j'`k'>invnormal(1-`alpha`j'') & pass`jm1'`k'==1)
		gen byte powerpass`j'`k' = (z`j'`k'>invnormal(1-`omega`j'') & powerpass`jm1'`k'==1)		
		if "`nonbinding'"!="" & `j'!=`J'{	
			qui replace pass`j'`k' = 1
			qui replace powerpass`j'`k' = 1
		}
		if "`esb'"!="" & `j'!=`J'{															
				qui gen byte edrop`j'`k' = cond(edrop`jm1'`k'==1, 1, ///
											cond(z`j'`k'>invnormal(1-`E`j'') & pass`jm1'`k'==1, 1, 0))	 
				qui replace pass`j'`k' = 0 if edrop`j'`k'==1 									
				qui replace powerpass`j'`k' = 0 if edrop`j'`k'==1		
		}
	}
}

// Apply simultaneous efficacy stopping rule if specified
if "`esbstop'"!=""{
	forvalues j=1/`Jm1'{
		forvalues i=`j'/`J'{
			forvalues k=1/`K'{
				forvalues l=1/`K'{
					if `l'!=`k'{
						qui replace pass`i'`l' = 0 if edrop`j'`k'==1
						qui replace powerpass`i'`l' = 0 if edrop`j'`k'==1
					}
				}
			}
		}
	}
}

// Count the number of arms which were dropped for efficacy at some stage prior to stage J
if "`esb'"!=""{
	local esum = 0
	forvalues k = 1/`K' {				
		qui count if edrop`Jm1'`k'==1	
		local esum = `esum'+r(N)		
		}
	return scalar esum = `esum'
	egen byte edrop`Jm1' = rowtotal(edrop`Jm1'*)
	qui count if edrop`Jm1'>0
	local edrops = r(N)
	return scalar edrops = `edrops'
}

// Number of arms passing stage j
forvalues j = 1/`J' {
	if "`esb'"!=""{
		egen byte npass`j' = rowtotal(pass`j'* edrop`jm1'*)
		egen byte powernpass`j' = rowtotal(powerpass`j'* edrop`jm1'*)
	}
	else {
		egen byte npass`j' = rowtotal(pass`j'*)
		egen byte powernpass`j' = rowtotal(powerpass`j'*)	
	}
}

// Probability of k arms passing stage j
forvalues j = 1/`J' {	
	forvalues k = 0/`K' {
		qui count if npass`j'==`k'
		local p`j'`k' = r(N)/`reps'
		return scalar p`j'`k' = `p`j'`k''
	}
}

// Pairwise type I error rate
local sum = 0
forvalues k = 1/`K' {
	qui count if pass`J'`k'==1
	local sum = `sum'+r(N)
}

local pwer = `sum'/(`K'*`reps')
if "`esb'"!="" local pwer = (`sum'+`esum')/(`K'*`reps')	// Recalculate pwer if dropping for efficacy specified
return scalar pwer = `pwer'

// FWER
qui count if npass`J'>0
local fwer = r(N)/`reps'

local se_fwer = sqrt(`fwer'*(1-`fwer')/`reps')
local ll_fwer = `fwer'-invnormal(0.975)*`se_fwer'
local ul_fwer = `fwer'+invnormal(0.975)*`se_fwer'

return scalar fwer = `fwer'
return scalar se_fwer = `se_fwer'
return scalar ll_fwer = `ll_fwer'
return scalar ul_fwer = `ul_fwer'

// Per-pair power		NEW
local sum = 0			
forvalues k = 1/`K' {
	qui count if powerpass`J'`k'==1				// # trials in which arm k passes final stage
	local sum = `sum'+r(N)						// Add totals for all arms
}

local pwomega = `sum'/(`K'*`reps')
if "`esb'"!="" {
	local pwomega = (`sum'+`esum')/(`K'*`reps')
}
return scalar pwomega = `pwomega'

// Any-pair power		NEW
qui count if powernpass`J'>0
local fwomega = r(N)/`reps'

local se_fwomega = sqrt(`fwomega'*(1-`fwomega')/`reps')
local ll_fwomega = `fwomega'-invnormal(0.975)*`se_fwomega'
local ul_fwomega = `fwomega'+invnormal(0.975)*`se_fwomega'

return scalar fwomega = `fwomega'
return scalar se_fwomega = `se_fwomega'
return scalar ll_fwomega = `ll_fwomega'
return scalar ul_fwomega = `ul_fwomega'

// All-pair power	NEW
qui count if powernpass`J'==`K'
local allomega = r(N)/`reps'
return scalar allomega = `allomega'

// ------------------ Maximum FWER if I not equal D
if "`ineqd'"!="" {
	cap drop edrop*
	cap drop pass*
	cap drop npass*
	cap drop power*
	
	forvalues k = 1/`K' {
		scalar pass0`k'=1
		scalar powerpass0`k'=1		
		if "`esb'"!="" {
			scalar edrop0`k'=0		
		}
		forvalues j = 1/`J' {
			local jm1 = `j'-1
			if `j'!=`J'{
				// Up to stage J, all arms pass every stage or are only checked against efficacy bounds (if specified)
				if "`esb'"!="" {
					qui gen byte edrop`j'`k' = cond(edrop`jm1'`k'==1, 1, ///
												cond(z`j'`k'>invnormal(1-`E`j'') & pass`jm1'`k'==1, 1, 0))	
					qui gen byte pass`j'`k' = 1 if edrop`j'`k'==0 					
					qui gen byte powerpass`j'`k' = 1 if edrop`j'`k'==0
				}
				else {
					qui gen byte pass`j'`k' = 1 					
					qui gen byte powerpass`j'`k' = 1
				}
			}
			else {	// At final stage J, only check against futility bound, conditional on arm having passed stage J-1
				qui gen byte pass`j'`k' = (z`j'`k'>invnormal(1-`alpha`j'') & pass`jm1'`k'==1)
				qui gen byte powerpass`j'`k' = (z`j'`k'>invnormal(1-`omega`j'') & powerpass`jm1'`k'==1)
			}
		}
		
	}
	
	if "`esb'"!=""{
		local Jm1 = `J'-1
		local esum = 0
		forvalues k = 1/`K' {	
			qui count if edrop`Jm1'`k'==1	
			local esum = `esum'+r(N)	
			}
		return scalar esum = `esum'	
		
		egen byte edrop`Jm1' = rowtotal(edrop`Jm1'*)	
		qui count if edrop`Jm1'>0						// # trials with >1 arm dropped for efficacy
		local edrops = r(N)
		return scalar edrops = `edrops'
	}
	
			// Max PWER
		local pwer = `alpha`J'' // No ESBs, max PWER = alphaJ
		if "`esb'"!=""{		// With ESBs, max PWER based on final stage simulation (plus arms dropped for efficacy early)
			local sum = 0
			forvalues k = 1/`K' {
				qui count if pass`J'`k'==1
				local sum = `sum'+r(N)
				local pwer = (`sum'+`esum')/(`K'*`reps')	// Recalculate pwer if stopping arms for efficacy allowed
			}
		}
		return scalar pwer = `pwer'
				
		// Max FWER
		if "`esb'"!="" egen byte npass`J' = rowtotal(pass`J'* edrop`Jm1'*)
		else egen byte npass`J' = rowtotal(pass`J'*)
		qui count if npass`J' > 0		// Count # arms that pass per trial & # trials with >1 arm reaching stage J
		local maxfwer = r(N)/`reps'		
		local se_maxfwer = sqrt(`maxfwer'*(1-`maxfwer')/`reps')
		return scalar maxfwer = `maxfwer'
		return scalar se_maxfwer = `se_maxfwer'
		
		// Any-pair power
		if "`esb'"!="" egen byte powernpass`J' = rowtotal(powerpass`J'* edrop`Jm1'*)
		else egen byte powernpass`J' = rowtotal(powerpass`J'*)
		qui count if powernpass`J'>0
		local fwomega = r(N)/`reps'
		return scalar fwomega = `fwomega'
		
		// Per-pair power
		local sum = 0
		forvalues k = 1/`K' {
			qui count if powerpass`J'`k'==1
			local sum = `sum'+r(N)	
		}
		local pwomega = `sum'/(`K'*`reps')
		if "`esb'"!=""{
			local pwomega = (`sum'+`esum')/(`K'*`reps')	// Recalculate pwer if dropping for efficacy specified
		}
		return scalar pwomega = `pwomega'

		// All-pair power
		qui count if powernpass`J'==`K'
		local allomega = r(N)/`reps'
		return scalar allomega = `allomega'

		restore
		
		local z = invnormal(1-`alpha`J'')
		// Vector of z values
		local z1ma `z'
		forvalues k = 2/`K' {
			local z1ma `z1ma', `z'
		}
		tempname Z
		matrix `Z' = (`z1ma')
		tempname A
		mat `A' = A
		local rep = 5000
		mata: mvnprob("`Z'", "`A'", `rep')	
		local mvnpmaxfwer = 1-r(p)
		return scalar mvnpmaxfwer = `mvnpmaxfwer'
}

end

********************************************************************************

********************************************************************************

* Subroutine for calculating the sample size

cap prog drop samplesize

program define samplesize, rclass

	syntax, Nstage(int) ACcrue(string) ALpha(string) ARms(string) HR0(string) HR1(string) ///
		 Omega(string) [ARAtio(string) S(string) T(string) TStop(real 0) TUnit(int 1) seed(int -1) fwerreps(int 1000000)]
****************************************************	

if "`t'"=="" {		
	di as err "must supply t(), the time for survival prob specified in s()"		
	exit 198		
}
if `tstop'>0 {
	local Tstop tstop(`tstop') 
}
else local Tstop
if `nstage' < 1 {
	di as err "nstage must be 1 or more"
	exit 198
}
* Rstar is allocation ratio to E arm: #pts to 1E for 1 pt to C
if "`aratio'"!="" {
	confirm num `aratio'
	local Rstar `aratio'
}
else local Rstar 1
if (`tunit'<1 | `tunit'>7) local tunit 7		
tokenize `""one year" "6 months" "one quarter (3 months)" "one month" "one week" "one day" "unspecified""'		
local lperiod ``tunit''		
// t, (optionally) s, hr0 and hr1 are provided for stages 1 and final. Fill in values for intermediate stages.

if "`s'" == "" {
	local s 0.5
}

// Tidy up check on number of parameters in each option
local maxval = cond(`nstage' > 1, 2, 1)
local nopt: word count `s'
local errcount 0
if `nopt' > `maxval' {
	local ++errcount
	local error`errcount' "too many items specified for s() - maximum is `maxval'"
}
if `nstage' > 1 & `nopt' < 2 {
	local s `s' 0.5
}
local opts hr0 hr1 t
local nopts: word count `opts'
tokenize `opts'
forvalues i = 1 / `nopts' {
	local opt ``i''
	local nopt: word count ``opt''
	if `nopt' > `maxval' {
		local ++errcount
		local error`errcount' "too many items specified for `opt'() - maximum is `maxval'"
	}
	if (`nopt' == 0) | (`nstage' > 1 & `nopt' < 2) {
		local ++errcount
		local error`errcount' "must specify `maxval' value(s) for `opt'()"
	}
	local stage S1
	local `opt'`stage': word 1 of ``opt''
	cap confirm number ``opt'`stage''
	if c(rc) {
		local ++errcount
		local error`errcount' "'``opt'`stage''' found where number expected"
	} 
	if "`opt'" == "t" {
		local surv : word 1 of `s'
		cap confirm number `surv'
		if c(rc) {
			local ++errcount
			local error`errcount' "'`surv'' found where number expected"
		} 
		else local hazard1 = -ln(`surv') / ``opt'`stage''
	}
	if `nstage' > 1 {
		local stage S`nstage'
		local `opt'`stage': word 2 of ``opt''
		cap confirm number ``opt'`stage''
		if c(rc) {
			local ++errcount
			local error`errcount' "'``opt'`stage''' found where number expected"
		} 
		else {
			if "`opt'" == "t" {
				local surv : word 2 of `s'
				confirm number `surv'
				local hazard`nstage' = -ln(`surv') / ``opt'`stage''
			}
			if `nstage' > 2 {
				local ns1 = `nstage' - 1
				forvalues j = 2 / `ns1' {
					if "`opt'" == "t" {
						local hazard`j' `hazard1'
					}
					else local `opt'S`j' ``opt'S1'
				}
			}
		}
	}
}
if `errcount' > 0 {
	forvalues i = 1 / `errcount' {
		di as err "`error`i''"
	}
	exit 198
}

// Determine if hazard ratio(s) are > 1, and set sign accordingly.					
forvalues i = 1 / `nstage' {														
	if (`hr1S`i'' > `hr0S`i'') local sign`i' -1
	else local sign`i' 1
}
local median1 = ln(2) / `hazard1'		
local median`nstage' = ln(2) / `hazard`nstage''
// Signal if have separate I- and D-outcomes according to equality of hazards
local have_D = reldif(`hazard1', `hazard`nstage'') > 0.0001

// Assign values of accrue alpha arms omega for all stages	
if `nstage' > 1 {		
	local es s		
}
****************************************	
local opts accrue alpha arms omega
local nopts: word count `opts'
tokenize `opts'
forvalues i = 1 / `nopts' {
	local opt ``i''
	local nopt: word count ``opt''
	if `nopt' > `nstage' {
		local ++errcount
		local error`errcount' "too many items specified for `opt'() - `nstage' value`es' required"
	}
	if `nopt'<`nstage' {
		local ++errcount
		local error`errcount' "must specify `nstage' value`es' for `opt'()"
	}
	forvalues j = 1 / `nstage' {
		local stage S`j'
		local `opt'`stage': word `j' of ``opt''
		cap confirm number ``opt'`stage''
		if c(rc) {
			local ++errcount
			local error`errcount' "'``opt'`stage''' found where number expected"
		}
	}
}
// New: Check number of arms in each stage is the same or less as the previous stage
forvalues i = 2 / `nstage' {
	local im1 = `i'-1
	if `armsS`i''>`armsS`im1''{
		local ++errcount
		local error`errcount' "number of arms in each stage must be strictly decreasing "
	}
}
if `errcount' > 0 {
	forvalues i = 1 / `errcount' {		
		di as err "`error`i''"		
	}		
	exit 198		
}		
** End of error checking and preliminary calculation **********
******************************************
// Compute control arm accrual from overall accrual, #arms and allocation ratio.
forvalues i = 1 / `nstage' {
	local A `accrueS`i''					// total accrual rate
	local K = `armsS`i'' - 1				// #exp arms
	local acc0S`i' = `A' / (1 + `Rstar' * `K') 	// control accrual rate		**
	local acc1S`i' = `Rstar'*`acc0S`i''			// exp. accrual rate		**	
	local oaccS`i' `A'					// overall accrual rate
}

local fac = 1 + 1 / `Rstar'	/* replaces factor 2 in expressions for eS1, eS`nstage' etc. */

// Compute e_S1 and initial e_S`nstage' from alpha1, HR0_0
local zalphaS1 = invnormal(`alphaS1')
local zomegaS1 = invnormal(`omegaS1')
local zomega = -`zomegaS1'

* Stage 1
* Compute initial est of control arm S1 I-events rounded up to nearest integer
local eS1 = int(1 + `fac' * ((`zomegaS1' - `zalphaS1')/(ln(`hr0S1') - ln(`hr1S1')))^2)

* Update eS1 and ln(deltaS1) to achieve desired power
local eS1un `eS1'
local haz0S1 = `hazard1' * `hr0S1'
local haz1S1 = `hazard1' * `hr1S1'
local iter 0
local done 0
quietly while !`done' {
	* Compute delta_S1
	local lndelS1 = ln(`hr0S1') + `sign1' * `zalphaS1' * sqrt(`fac' / `eS1')		
 
	* Compute time for stage 1
	cap timetoevn4, accrual(`acc0S1') events(`eS1') hazard(`hazard1') `Tstop'
	
	if _rc {
		local errmess = r(errmess)
		di as err `"`r(errmess)'"'
		return local errmess `errmess'
		exit 498
	}

	local tS1 = r(t1)
	if "`iterate'" == "noiterate" {
		* Calcs done under H0, no iteration necessary
		if `Rstar' == 1 {
			local eS1star `eS1'
			local zomega `zomegaS1'
		}
		else {
			local eS1star = int(1 + `Rstar' * `eS1')
			local zomega = `sign1' * (`lndelS1' - ln(`hr1S1'))/sqrt(1 / `eS1' + 1 / `eS1star')			
		}
		local done 1
	}
	else {
		* Compute I-events at end of stage 1 in experimental arm under H1.
		evfromtin4, accrual(`acc1S1') times(`tS1') hazard(`haz1S1') `Tstop'
		local eS1star = int(1+r(e1))			
		if "`olddef'" != "" {
			local zomega = `sign1' * (`lndelS1' - ln(`hr1S1')) / sqrt(4 / (`eS1' + `eS1star'))				
		}
		else {
			local zomega = `sign1' * (`lndelS1' - ln(`hr1S1')) / sqrt(1 / `eS1' + 1 / `eS1star')				
		}
		* Update eS1
		if `sign1'*`zomega' >= `sign1'*`zomegaS1' {						
			local done 1
		}
		else {
			local eS1 = `sign1' + `eS1'						
			local ++iter
		}
	}
}
local omegaS1=normal(`zomega')
local zomegaS1 = `zomega'

* nS1 is total number of control-arm patients, stage 1
if `tstop'>0 {
	local nS1 = `acc0S1' * min(`tstop',`tS1')
}
else {
	local nS1 = `acc0S1' * `tS1'
}
if `nS1' < `eS1' {
	di as err "Design infeasible, accrual period too short"
	exit 498
}

// Round off numbers of patients in experimental and control arms to nearest integer
local nS1 = round(`nS1')								// total patients, C
local nexpS1 = round(`nS1' *  (`armsS1' - 1) * `Rstar')	// total patients, all E
local ntotS1 = `nS1' + `nexpS1'							// total patients, C+all E
local etotS1 = `eS1' + (`armsS1' - 1) * `eS1star'		// total I-events, C+all E
local eexpS1 = `etotS1' - `eS1'							// total S1-events, all E

return scalar deltaS1 = exp(`lndelS1')
return scalar eS1un = `eS1un'
return scalar eS1 = `eS1'
return scalar eS1star = `eS1star'
return scalar nS1 = `nS1'
return scalar tS1 = `tS1'
return scalar ntotS1 = `ntotS1'
return scalar nexpS1 = `nexpS1'
return scalar etotS1 = `etotS1'
return scalar eexpS1 = `eexpS1'
return scalar omegaS1 = `omegaS1'

if `nstage' == 1 {		
	// FWER + 95% CI for 1-stage design		
	if "`nofwer'"=="" {		
		mat def R = (1)		
		nstagefwer, nstage(`nstage') arms(`armsS1') alpha(`alpha') omega(`omega') corr(R) aratio(`Rstar') ///		
					seed(`seed') reps(`fwerreps')		
		local fwerate = r(fwer)		
		local se_fwerate = r(se_fwer)		
		return scalar fwer = r(fwer)		
		return scalar se_fwer = r(se_fwer)		
	}		
			
	local ww 9		
	* left-justified string format		
	local sfl %-`ww's		
	* centered string format		
	local sfc %~`ww's		
	* right-justified string format		
	local sfr %`ww's		
	local nitem 6		
	local dup = `nitem' * `ww'		
			
				
	di as text _n "`title1'" _n "{hline `hline'}"		
	di as text "Sample size for a " as res "`armsS1'" as text "-arm " as res "1" as txt "-stage trial with time-to-event outcome"		
	di as text "`title2'" 
	di as text "`title3'" _n "{hline `hline'}"		
	di as text _n "Median survival time: " as res round(`median1', 0.1) as text " time units"		
	di as text _n "Operating characteristics" _n "{hline `dup'}"		
	di as text %`ww'.3f "Alpha(1S)" `sfr' "Power" _col(23) "HR{c |}H0" _col(32) "HR{c |}H1" `sfr' "Crit. HR" `sfr' "Duration" _n "{hline `dup'}"		
	di as text %`ww'.3f `alphaS1' %`ww'.3f `omegaS1' %`ww'.3f `hr0S1' %`ww'.3f `hr1S1' %`ww'.3f as res exp(`lndelS1') %`ww'.3f as res `tS1' _n as txt "{hline `dup'}"		
	if `tstop' > 0 {		
		di as text "Patient accrual stopped at time " %6.3f `tstop'		
	}		
	if "`nofwer'"=="" & `armsS1'>2 di as text "Familywise error rate (SE) = " as res %4.3f `fwerate' ///		
		as text " (" as res %4.3f `se_fwerate' as text ")" 		
	di _n as text "Duration is expressed in " as res "`lperiod'" as txt " periods and assumes"		
	di as text "assumes survival times are exponentially distributed. Time is"
	di as text "expressed in cumulative periods."
	local nitem 4		
	local dup = `nitem' * `ww'		
	di as text _n "Sample size and number of events" _n "{hline `dup'}"		
	di as text _skip(`ww') `sfr' "Overall" `sfr' "Control" `sfr' "Exper." _n "{hline `dup'}"		
	di as text `sfl' "Arms"      as txt %`ww'.0f `armsS1' %`ww'.0f 1 %`ww'.0f `armsS1'-1		
	di as text `sfl' "Acc. rate" as txt %`ww'.0f `oaccS1' %`ww'.0f `acc0S1' %`ww'.0f `acc0S1'*(`armsS1'-1)*`Rstar'		
	di as text `sfl' "Patients"  as res %`ww'.0f `ntotS1' %`ww'.0f `nS1' %`ww'.0f `nexpS1'		
	di as text `sfl' "Events"    as res %`ww'.0f `etotS1' %`ww'.0f `eS1' %`ww'.0f `eexpS1' as txt _n "{hline `dup'}"		
	if `Rstar' != 1 {		
		di as text "`Rstar' patients allocated to each E arm for every 1 to control arm."		
	}		
	if "`iterate'" == "noiterate" {		
		if `hr1S1'<1 di as text _n "[Note: computations carried out under H0. Sample sizes may be too low.]"		
		if `hr1S1'>1 di as text _n "[Note: computations carried out under H0. Sample sizes may be too high.]"			
	}		
	exit		
}
/*
	Stages 2 - n
	Update events and HR cutoffs to achieve desired power
*/
forvalues i = 2 / `nstage' {
	local zalphaS`i' = invnormal(`alphaS`i'')
	local zomegaS`i' = invnormal(`omegaS`i'')
	local zomega`i' = -`zomegaS`i''	// initialisation of achieved power to a low value
	local eS`i' = int(1 + `fac' * ((`zomegaS`i'' - `zalphaS`i'') / (ln(`hr0S`i'') - ln(`hr1S`i'')))^2)
	local eS`i'un `eS`i''
	local haz0S`i' = `hazard`i'' * `hr0S`i''
	local haz1S`i' = `hazard`i'' * `hr1S`i''
}
forvalues m = 2 / `nstage' {
	local acc0S
	local acc1S
	forvalues i = 1 / `m' {
		local acc0S `acc0S' `acc0S`i''
		local acc1S `acc1S' `acc1S`i''		
	}
	// Start iterative procedure to determine required control arm events
	local iter 0
	local done 0
	quietly while !`done' {
		// Compute log delta`m', HR threshold for stage `m'.
		local lndelS`m' = ln(`hr0S`m'') + `sign`m'' * `zalphaS`m'' * sqrt(`fac' / `eS`m'')						

		// Compute times to end of stages 1,...,`m' based on events in control arm (hazard haz0*)
		local eS
		forvalues i = 1 / `m' {
			local eS `eS' `eS`i''
		}
		
		cap timetoevn4, accrual(`acc0S') events(`eS') hazard(`hazard1' `hazard`m'') `Tstop'
		
		if _rc {
			di as err `"`r(errmess)'"'
			exit 498
		}
		if "`r(enough)'" == "enough" {
			// Got enough events at stage m-1. Upgrade power.
			local m1 = `m' - 1
			local eS`m' = r(ev21)
			local eS`m'star = int(1 + `Rstar' * `eS`m'')		// total events in 1 exp arm
			local tS`m' = r(t`m')
			local zomega`m' = `sign`m'' * (`lndelS`m'' - ln(`hr1S`m'')) / sqrt(1 / `eS`m'' + 1 / `eS`m'star')			
			noi di as txt _n "[Note: stage `m1' already provides " as res round(`eS`m'') ///
			 as txt " events, more than enough for stage " `m' "."
			noi di as txt "Upgrading power for stage `m' from " as res %5.3f `omegaS`m'' ///
			 as txt " to " as res %5.3f normal(`zomega`m'') ///
			 as txt ". Stage `m' has zero length.]"
			local done 1
		}
		else {
			local tS
			forvalues i = 1 / `m' {
				local tS`i' = r(t`i')
				local tS `tS' `tS`i''
			}
			if "`iterate'" == "noiterate" {
				* Calcs done under H0, no iteration necessary
				if `Rstar' == 1 {
					local eS`m'star `eS`m''
					local zomega`m' `zomegaS`m''
				}
				else {
					local eS`m'star = int(1+`Rstar' * `eS`m'')
					if "`olddef'"!="" {
						local zomega`m' = `sign`m'' * (`lndelS`m'' - ln(`hr1S`m'')) / sqrt(4 / (`eS`m'' + `eS`m'star'))				
					}
					else {
						local zomega`m' = `sign`m'' * (`lndelS`m'' - ln(`hr1S`m'')) / sqrt(1 / `eS`m'' + 1 / `eS`m'star')	
					}
				}
				local done 1
			}
			else {
				/*
					Compute eS`m'star, total events at end of stage `m' in experimental arm (hazard haz1*).
					(Events for stages 1,...,`m'-1 are not relevant, hence hazard is entered as ".").
				*/
				evfromtin4, accrual(`acc1S') times(`tS') hazard(. `haz1S`m'') `Tstop'
				local eS`m'star = int(1+r(e`m'))		// total events in 1 exp arm
				if "`olddef'"!="" {
					local zomega`m' = `sign`m'' * (`lndelS`m'' - ln(`hr1S`m'')) / sqrt(4 / (`eS`m'' + `eS`m'star'))				
				}
				else {
					local zomega`m' = `sign`m'' * (`lndelS`m'' - ln(`hr1S`m'')) / sqrt(1 / `eS`m'' + 1 / `eS`m'star')			
				}
				* Update eS`m'
				if `sign`m''*`zomega`m'' >= `sign`m''*`zomegaS`m'' {															
					local done 1
				}
				else {
					local eS`m' = `sign`m''+`eS`m''							
					local ++iter
				}
			}
		}
	}
	local omegaS`m' = normal(`zomega`m'')
	local zomegaS`m' = `zomega`m''
}



/*
	nS`nstage' is total number of control-arm patients, stage 1 + stage 2
	ntotS`nstage' is total patients, C + all E
	nexpS`nstage' is total patients, all E
	tSt`i' is accrual time in stage `i', i = 1 , ... , nstage
*/
local tSt1 `tS1'
forvalues i = 2 / `nstage' {
	local im1 = `i' - 1
	local tSt`i' = `tS`i'' - `tS`im1''
}
if `tstop'>0 {
	if `tstop'<`tS1' { 		// accrual stops in stage 1
		local tSt1 `tstop'
	}
	forvalues i = 2 / `nstage' {
		local im1 = `i' - 1
		if `tstop' < `tS`i'' {	// accrual stops in stage `i'
			local tSt`i' = max(0, `tstop' - `tS`im1'')
		}
	}
}

* Run for each stage
local nS1 = `acc0S1' * `tSt1'
local nexpS1 = `Rstar' * (`armsS1' - 1) * `acc0S1' * `tSt1'
forvalues i = 2 / `nstage' {
	local j = `i' - 1
	local nS`i' = `nS`j'' + `acc0S`i'' * `tSt`i''
	if `nS`i''<`eS`i'' {
		di as err "Design infeasible - fewer patients (`nS`i'') than events (`eS`i'') in stage `i'"
		exit 498
	}
	local nexpS`i' = `nexpS`j'' + `Rstar' * ((`armsS`i'' - 1) * `acc0S`i'' * `tSt`i'')
}

// Round off numbers of patients in experimental and control arms to nearest integer
forvalues i = 1 / `nstage' {
	local nexpS`i' = round(`nexpS`i'')
	local nS`i' = round(`nS`i'')
	local ntotS`i' = `nS`i'' + `nexpS`i''
}
/*
	Compute etotS`nstage' = total events in all experimental arms.
	First, compute e1S`nstage'drop = S`nstage'-events in 'dropped' arm (no accrual beyond stage 1)
*/
if `tstop'>0 {
	local ts = min(`tS1', `tstop')
}


forvalues m = 2 / `nstage' {
	local m1 = `m' - 1
	// Hazards are appropriate to experimental arms
	local haz `haz1S1' `haz1S`m''

	local acc1S
	local tS
	forvalues i = 1 / `m' {
		local acc1S `acc1S' `acc1S`i''
		local tS `tS' `tS`i''
	}
	local eexpS`m' 0	// no. of events in exp arm in stage `m'
	if "`includedroppedarms'" != "" {
/*
	Compute number of events in experimental "dropped" arms.
	This involves notionally stopping recruitment at end of stage 1, 2, ...
*/
		forvalues i = 1 / `m1' {
			local j = `i' + 1
			if `armsS`i'' > `armsS`j'' {
				qui evfromtin4, accrual(`acc1S') times(`tS') hazard(`haz') tstop(`tS`i'')
				local edrop`i' =  r(e`m')
				local eexpS`m' = `eexpS`m'' + (`armsS`i'' - `armsS`j'') * `edrop`i''
			}
		}
	}
	local eexpS`m' = `eexpS`m'' + (`armsS`m'' - 1) * `eS`m'star'
	local etotS`m' = `eS`m'' + `eexpS`m''		/* total S`nstage'-events, C+all E */
}

forvalues j=1/`nstage'{
	return scalar armsS`j' = `armsS`j''
	return scalar accrueS`j' = `accrueS`j''
	return scalar hr0S`j' = `hr0S`j''
	return scalar hr1S`j' = `hr1S`j''
	return scalar lndelS`j' = `lndelS`j''
	return scalar tS`j' = `tS`j''
	return scalar eS`j' = `eS`j''
	return scalar etotS`j' = `etotS`j''
	return scalar eexpS`j' = `eexpS`j''
	return scalar ntotS`j' = `ntotS`j''
	return scalar nS`j'	   = `nS`j''
	return scalar nexpS`j' = `nexpS`j''
	return scalar alphaS`j'  = `alphaS`j''
	return scalar omegaS`j'  = `omegaS`j''
	return scalar zalphaS`j' = `zalphaS`j''
	return scalar zomegaS`j' = `zomegaS`j''
	return scalar acc0S`j' = `acc0S`j''
	return scalar oaccS`j' = `oaccS`j''
	return scalar eS`j'un = `eS`j'un'
	return scalar eS`j'star = `eS`j'star'
}
	return scalar median1 = `median1'
	return scalar median`nstage' = `median`nstage''
	return scalar Rstar = `Rstar'
	return scalar have_D = `have_D'
	return scalar fac = `fac'

end
