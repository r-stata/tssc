*! version 1.0.0 ?????2015 MJC

/*
Notes
-> constraints for tvcs in parsecmd
-> needs starting values from separate models!!
-> check tprob works when no covariates
-> rcsbase terms incorrect in eret list
*/

/*
History
log(t) in log hazard added so likelihood comparable with streg models

MJC ?????2015: version 1.0.0
*/

program stms, sortpreserve properties(st)
	version 12.1
	/*if replay() {
		if (`"`e(cmd)'"' !="stms") error 301
		Replay `0'
	}
	else*/
	Estimate `0'
end

program define Estimate, sortpreserve properties(st) eclass
						
					
	//================================================================================================================================================//
	// Preliminaries
	
		local core_OPTS						BHazard(varname)					//


		//Results display options
		local di_OPTS						SHOWINIT							///
											SHOWCons							///			-Show spline constraints-
											KEEPCons							///			-Do not drop constraints used in ml routine-
											Level(cilevel)						//			-Statistical significance level-

		//add ml opts
        local MAXOPTS                       					                ///
									/// maximize options
											DIFficult                           ///
											TECHnique(string)                   ///
											ITERate(numlist integer >=0)        ///
											TOLerance(numlist max=1 >=0)        ///
											LTOLerance(numlist max=1 >=0)       ///
											NRTOLerance(numlist max=1 >=0)      ///
									///  reporting
											noLOg                               ///
											TRace                               ///
											GRADient                            ///
											showstep                            ///
											HESSian                             ///
											SHOWTOLerance                       //

		cap confirm variable _trans
		if _rc {
			di as error "data must be msset"
			exit 198
		}
		
		local global_OPTS_noml `core_OPTS' `di_OPTS' 
		local global_OPTS `global_OPTS_noml' `MAXOPTS'
		
		local copy0 `0'
		
		_parse expand cmd glob : 0, common(`global_OPTS')
		local Ntrans = `cmd_n'
		
		local 0 `", `glob_op'"'
        syntax [ , `global_OPTS_noml' *]
		mlopts mlopts, `options'
		local extra_constraints `s(constraints)'
		
		if "`showinit'"!="" local noisily noisily
		
		tempname inittemp initmat
		di ""
		di in green "Obtaining intial values"
		
		//parse model syntax and get inital values
		forvalues i=1/`Ntrans' {
			
			tempvar touse`i'
			
			//delentry
			tempvar t0touse`i'
			_stms_parsecmd `cmd_`i'' `noisily' tousevar(`touse`i'') modelindex(`i') transvar(_trans)
			mat `inittemp' = r(inits)
			if `i'==1 {
				mat `initmat' = `inittemp'
			}
			else {
				mat `initmat' = `initmat',`inittemp'
			}

			local tousevars `tousevars' `touse`i''
			local model`i' `r(model)'
			local models `models' `model`i''
			local mleqns `mleqns' `r(mleqn)'
			local conslist `conslist' `r(constraints)'
			local varlist`i' `r(varlist)'
			local ancillary`i' `r(ancillary)'
			local anc2`i' `r(anc2)'
			if "`r(model)'"=="stpm2" {
				if "`orthog`i''"=="orthog" {
					tempname R_bh`i'
					mat `R_bh`i'' = r(R_bh`i')
					if "`tvc`i''"!="" {
						foreach var in `tvc`i'' {
							tempname R_`var'`i'
							mat `R_`var'`i'' = r(R_`var'`i')
						}
					}
				}
			}
			qui gen byte `t0touse`i'' = (_t0>0 & `touse`i''==1)
			qui count if `t0touse`i''==1 	//rclass, keep here
			local del =`r(N)'>0
			local delentry `delentry' `del'

		}

		/* If further constraints are listed then remove this from mlopts and add to conslist */
        if "`extra_constraints'" != "" {
			local mlopts : subinstr local mlopts "constraints(`extra_constraints')" "",word
			local conslist `conslist' `extra_constraints'
        }		
		
		mata: stms_setup()

		di ""
		di in green "Fitting full model"

		ml model lf0 stms_lf()	`mleqns'							///
								/*if `touse'*/	                    ///
								`wt',                               ///
								`mlopts'                            ///
								userinfo(`stms_struct')        		///
								waldtest(0)                         ///
								`nolog'                             ///
								`searchopt'                         ///
								`initopt'                           ///
								init(`initmat',copy)				///
								constraints(`conslist')				///
								collinear							///
								search(off)							///
								missing								///
								maximize
								
								
		//ereturn
		ereturn local models `models'
		ereturn local cmd stms
		ereturn local delentry `delentry'
		forvalues i=1/`Ntrans' {
			ereturn local varlist`i' `varlist`i''
			ereturn local ancillary`i' `ancillary`i''
			ereturn local anc2`i' `anc2`i''
			
			ereturn local noconstant`i' `nocons`i''
			if "`model`i''"=="stpm2" {
			
				ereturn local orthog`i' `orthog`i''
				ereturn local scale`i' `scale`i''
				ereturn local rcsbaseoff`i' `rcsbaseoff`i''
				ereturn local rcsterms_base`i' `rcsterms_base`i''
				ereturn local ln_bhknots`i' `ln_bhknots`i''
				ereturn local boundary_knots`i' `boundary_knots`i''
				if "`orthog`i''"=="orthog" {
					ereturn matrix R_bh`i' = `R_bh`i''
				}
				ereturn local tvc`i' `tvc`i''
				foreach var in `tvc`i'' {
					ereturn local boundary_knots_`var'`i' `boundary_knots_`var'`i''
					ereturn local ln_tvcknots_`var'`i' `ln_tvcknots_`var'`i''
					if "`orthog`i''"=="orthog" {
						ereturn matrix R_`var'`i' = `R_`var'`i''
					}
				}
			}
			
		}
		
		
	cap constraint drop `conslist'
	Replay
	//Done

end

program Replay
	
	ml display, nocnsreport

end

