*! version 0.1.2 31jul2017 MJC

/*
History
MJC 31jul2017: version 0.1.2 - af prediction fixed for tvcs
							 - matrix printed out when noorthog was used, now fixed
MJC 26jun2017: version 0.1.1 - rcsgen2.ado was missing, xb bug fix in staft_pred.ado
MJC 23jun2017: version 0.1.0

Development
-> main help file done
-> se's for predictions hard coded in Mata using delta method
-> note TVC's are included in stpm2 starting values, but zeros are passed to initmat
--> only need starting values for baseline splines, but using rcs vars that stpm2 calculates in ml equarions
-> was a mistake in starting values when tvc's present -> greatly improved now
-> df(1) needs log bknots extracted explicitly, as they're not in e(ln_bknots) from stpm2 when df=1
-> if no covariates and no tvc's are specified it fits stpm2 with a message saying this
-> tvc added to a markout call, incase tvc vars not in varlist
*/

/*
To do
-> sync with other constraints
-> initmat - override initial values but still do stpm2 iter(0) to get splines etc.
-> label final spline vars
-> check set obs missing problem
*/

program staft, eclass sortpreserve properties(st)
	version 12.1
	
	 if replay() {
			syntax  [, DF(string) KNOTS(string) *]
			if "`df'`knots'" != "" {
				Estimate `0'
				ereturn local cmdline `"staft `0'"'
			}
			else {
				if "`e(cmd)'" != "staft" {
						error 301
				}
				if _by() {
					error 190
				}
				Replay `0' 
			}       
			exit
	}
	Estimate `0'
	ereturn local cmdline `"staft `0'"'
end

program Estimate, eclass
	st_is 2 analysis	
	syntax [varlist(default=empty)] [fw pw iw aw] [if] [in] 								///
																							///
													[,										///
														DF(passthru) 						///	-degrees of freedom for the baseline-
														KNOTS(passthru)						///	-knots for the baseline-
														BKnots(passthru)					/// -boundary knots for the baseline- 
																							///
														BKNOTSTVC(passthru)					///	-boundary knots for time-dependent effects-
														TVC(varlist)						///	-varlist of time-dependent effects-
														DFTVC(passthru)						///	-degrees of freedom for time-dependent effects-
														KNOTSTVC(passthru)					///	-knots for time-dependent effects-
														NOORTHog 							///	-do not orthogonalise splines-
																							///	
													/* Results display options */			///
														EFORM								///	-Exponentiate first ml equation-
														SHOWINITial							///	-Show output from fitting initial value models-
														Level(cilevel)						///	-Statistical significance level-
																							///
													/* Maximisation options	*/				///
														* 									///	-ML options-
																							///
														ADAPT								///	-undocumented-	
														LININIT								///
														MLMETHOD(string)					///
													] 
	
	//===================================================================================================================================================//
	// Error checks and preliminaries //
		
		// Check stpm2 and rcsgen are installed 
		capture which stpm2
		if _rc >0 {
			display in yellow "You need to install the command stpm2. This can be installed using,"
			display in yellow ". {stata ssc install stpm2}"
			exit  198
		}
		capture which rcsgen
		if _rc >0 {
			display in yellow "You need to install the command rcsgen. This can be installed using,"
			display in yellow ". {stata ssc install rcsgen}"
			exit  198
		}

		//  Weights //!!not done
		if "`weight'" != "" {
			display as err "weights must be stset"
			exit 101
		}
		local wt: char _dta[st_w]	
		local wtvar: char _dta[st_wv]
		if "`wt'" != "" {
			local fw fw(`wtvar')
		}
			
		// Marksample and mlopts
		marksample touse
		markout `touse' `tvc'
		qui replace `touse' = 0  if _st==0 | `touse'==.

		qui count if `touse'
		local N `r(N)'
		if `r(N)' == 0 {
			display in red "No observations"
			exit 2000
		}
		
		qui count if `touse' & _d
		if `r(N)' == 0 {
			display in red "No failures"
			exit 198
		}

		if "`mlmethod'"=="" {
			local mlmethod lf2
		}
		
		if "`showinitial'"!="" {
			local noisily noisily
		}
						
		// Check time origin for delayed entry models 
		local delentry = 0
		qui summ _t0 if `touse', meanonly
		if r(max)>0 {
			display in green  "Note: delayed entry models are being fitted"
			di ""
			local delentry = 1
			tempvar t0ind index
			qui egen `index' = seq() if `touse'==1
			qui gen byte `t0ind' = (_t0>0 & `touse'==1)
			qui replace `t0ind'=0 if `t0ind'==.
		}
		
		// temp timevars -> used in rcsgen calls from lnl evaluator
		tempvar lntxb
		qui gen double `lntxb' = log(_t) if `touse'
		if `delentry' {
			tempvar lnt0xb
			qui gen double `lnt0xb' = log(_t0) if `t0ind'
		}
		
		//if no covariates or tvc's then exit after stpm2 model
		local stpm2 = 0
		if "`varlist'"=="" & "`tvc'"=="" {
			di in green "No covariates have been specified -> fitting stpm2 model"
			local noisily noisily 		//makes sure stpm2 is shown
			local stpm2 = 1
		}
	
	//=======================================================================================================================================================//
	// Starting values 
	
		if !`stpm2' {
			di as txt "Obtaining initial values:"
			local ncovs : word count `varlist'
			
			//starting values for covariate effects	
			tempname initmat1 initmat2
			
			qui `noisily' streg `varlist', dist(weib) time level(`level')
			mat `initmat1' = e(b)
			mat `initmat1' = `initmat1'[1,1..`ncovs']
			
			//starting values for splines, and creates splines
			qui `noisily' stpm2, scale(h) `df' `knots' `noorthog' level(`level') `bknots' `bknotstvc' tvc(`tvc') `dftvc' `knotstvc' `knscale' failconvlininit
			
			local Nsplines : word count `e(rcsterms_base)'
			local ln_bknots `e(ln_bhknots)'										//all log baseline knots including boundary knots
			if "`ln_bknots'"=="" {	//this is empty when df(1)
				local ln_bknots `=log(`: word 1 of `e(boundary_knots)'')'
				local ln_bknots `ln_bknots' `=log(`: word 2 of `e(boundary_knots)'')'
			}
			
			if "`noorthog'"=="" {
				tempname rmat
				mat `rmat' = e(R_bh)
				local rmatopt rmatrix(`rmat')
			}
					
			local tvc `e(tvc)'
			if "`tvc'"!="" {
				foreach tvcvar in `tvc' {
					local rcsterms_`tvcvar' `e(rcsterms_`tvcvar')'
					local tvcvars `tvcvars' `rcsterms_`tvcvar''
					local drcsterms_`tvcvar' `e(drcsterms_`tvcvar')'
					local dtvcvars `dtvcvars' `drcsterms_`tvcvar''
					local ln_tvcknots_`tvcvar' `e(ln_tvcknots_`tvcvar')'
					local boundary_knots_`tvcvar' `e(boundary_knots_`tvcvar')'
					if "`nooorthog'"=="" {
						tempname R_`tvcvar'
						mat `R_`tvcvar'' = e(R_`tvcvar')
					}
					local ind = 1
					foreach tvar in `e(rcsterms_`tvcvar')' {
						local dtvar : word `ind' of `e(drcsterms_`tvcvar')'
						constraint free
						constraint `r(free)' [xb][`tvar'] = [dxb][`dtvar']
						local conslist `conslist' `r(free)'
						local `++ind'
					}
				}

				local Ntvcvars : word count `tvcvars'
				mat `initmat1' = `initmat1',J(1,`=2*`Ntvcvars'',0)
				
				if `delentry' {				
					foreach tvcvar in `tvc' {
						local s0rcsterms_`tvcvar' : subinstr local rcsterms_`tvcvar' "_rcs" "_s0_rcs", all 
						local s0tvcvars `s0tvcvars' `s0rcsterms_`tvcvar''
						local ind = 1
						foreach tvar in `e(rcsterms_`tvcvar')' {
							local s0tvar : word `ind' of `s0rcsterms_`tvcvar''
							constraint free
							constraint `r(free)' [xb][`tvar'] = [s0xb][`s0tvar']
							local conslist `conslist' `r(free)'
							local `++ind'
						}
					}
					foreach nontvcvar in `varlist' {
						constraint free
						constraint `r(free)' [xb][`nontvcvar'] = [s0xb][`nontvcvar']
						local conslist `conslist' `r(free)'
					}
					
					//initmat needs non tvc covariate starting values and tvc zeros
					mat `initmat1' = `initmat1',`initmat1'[1,1..`ncovs'],J(1,`Ntvcvars',0)
				}
				local constraints constraints(`conslist')			
			}
			
			//starting values for splines (skipping any tvc's to get intercept)
			tempname initmat2
			mat `initmat2' = e(b)
			mat `initmat2' = `initmat2'[1,"xb:"]
			mat `initmat1' = `initmat1',`initmat2'[1,1..`Nsplines'],`initmat2'[1,colsof(`initmat2')]	
			
		}
		else {
			//stpm2 and exit
			qui `noisily' stpm2, scale(h) `df' `knots' `noorthog' level(`level') `bknots' `bknotstvc' tvc(`tvc') `dftvc' `knotstvc' `knscale'
			exit
		}
		di ""
		
		
	//=======================================================================================================================================================//
	// ML equations
	
		local mleqns (xb: `varlist' `tvcvars', nocons)
		if "`tvc'"!="" {
			local mleqns `mleqns' (dxb: `dtvcvars',nocons)
			if `delentry' {
				local mleqns `mleqns' (s0xb: `varlist' `s0tvcvars', nocons)
			}
		}
		forvalues i=1/`Nsplines' {
			local mleqns `mleqns' /rcs`i'
		}
		local mleqns `mleqns' /cons

		
	//=======================================================================================================================================================//
	// Maximisation

		if "`adapt'"!="" {
			local dprolog derivprolog(staft_prolog())
		}		
		
		local initopt init(`initmat1',copy)
		
		if "`lininit'"!="" {
			quietly staft `varlist', df(1) `adapt'
			mat `initmat1' = e(b)
			
			local Nvars : word count `varlist'
			mat `initmat1' = `initmat1'[1,1..`=`Nvars'+1'],J(1,`=`Nsplines'-1',0),`initmat1'[1,colsof(`initmat1')]
			local initopt init(`initmat1',copy)
		}
		
		mata: staft_setup()

		di as txt "Fitting full model:"
		ml model `mlmethod' staft_lf2() `mleqns'						///
										if `touse'						///
										`wt',							///
										init(`initmat1',copy)			///
										`options' 						///
										waldtest(0) 					///
										search(off)						///
										userinfo(`staft_struct')        ///
										`searchopt'						///
										`dprolog'						///
										`collinopt'						///
										`constraints'					///
										`nolog'							///
										maximize
		
		constraint drop `conslist'

		//Tidy up and create final _rcs splines
		
		tempvar lntxbfinal
		qui predictnl double `lntxbfinal' = log(_t * exp(-xb(xb))) if `touse'
		forvalues i=1/`Nsplines' {
			cap drop _rcs`i'
			cap drop _d_rcs`i'
		}		
		qui rcsgen `lntxbfinal' if `touse', gen(_rcs) knots(`ln_bknots') dgen(_d_rcs) `rmatopt'
		
		ereturn local rcsterms `r(rcslist)'
		ereturn local drcsterms `r(drcslist)'

		if `delentry' & "`tvc'"!="" {
			tempvar lnt0xbfinal
			qui predictnl double `lnt0xbfinal' = log(_t0 * exp(-xb(s0xb))) if `touse'
			forvalues i=1/`Nsplines' {
				cap drop _s0_rcs`i'
				cap drop _d_s0_rcs`i'
			}		
			qui rcsgen `lnt0xbfinal' if `touse', gen(_s0_rcs) knots(`ln_bknots') dgen(_d_s0_rcs) `rmatopt'		
			
			ereturn local s0rcsterms `r(rcslist)'
			ereturn local ds0rcsterms `r(drcslist)'
		}
		
		ereturn local predict staft_pred
		ereturn local title "Restricted cubic spline accelerated failure time model"
		ereturn local cmd staft
		ereturn local varlist `varlist'
		ereturn local tvc `tvc'
		ereturn local ln_bknots `ln_bknots'
		ereturn local noorthog `noorthog'
		if "`noorthog'"=="" {
			ereturn matrix R = `rmat'
		}
		ereturn local delentry = `delentry'
		
		if "`tvc'"!="" {
			foreach tvcvar in `tvc' {
				ereturn local rcsterms_`tvcvar' `rcsterms_`tvcvar''
				ereturn local drcsterms_`tvcvar' `drcsterms_`tvcvar''
				ereturn local ln_tvcknots_`tvcvar' `ln_tvcknots_`tvcvar''
				ereturn local boundary_knots_`tvcvar' `boundary_knots_`tvcvar''
				if "`noorthog'"=="" {
					ereturn matrix R_`tvcvar' = `R_`tvcvar''
				}
			}
		}
		
		ereturn scalar dev = -2*e(ll)
        ereturn scalar AIC = -2*e(ll) + 2 * e(rank) 
        qui count if `touse' == 1 & _d == 1
        ereturn scalar BIC = -2*e(ll) + ln(r(N)) * e(rank)
		
		Replay, level(`level') `showcons' `variance' `eform'
end

program Replay
		syntax [, Level(cilevel) EFORM]
		ml display, level(`level') `eform'
end


