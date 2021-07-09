*! version 0.0.0  ??????2018

program merlin_p, sortpreserve
        version 14.1
        local vv : display "version " string(_caller()) ":"

        tempname tname
        capture noisily `vv' Predict `tname' `0'
        local rc = c(rc)
        capture drop `tname'*
        capture mata: rmexternal("`tname'")
        exit `rc'
end

program Predict
        version 14.1
        gettoken GML 0 : 0
        syntax  newvarname      						///
                [if] [in] [,                            ///
														///
				OUTcome(string)							///
														/// statistics
                MU                                      ///
                ETA                                     ///
                SURVival                                ///
				CIF										///	
				Hazard									///
				CHazard									///
				LOGCHazard								/// NOTDOC
				RMST									///
				TIMELost								///
				TOTALTIMELost							///
				CAUSES(string)							///
				TRANSPROB(numlist max=1)				/// NOTDOC
				LOS(numlist max=1)						/// NOTDOC
														///
                FIXEDonly                               ///
                MARGinal                                ///
														///
				CI										///
				TIMEvar(varname)						///
				AT(string)								///
														///
				AT1(string)								///
				AT2(string)								///
				SDIFFerence								///
				HDIFFerence								///
				CIFDIFFerence							///
				RMSTDIFFerence							///
				MUDIFFerence							///
				ETADIFFerence							///
														///
                INTPoints(numlist int max=1 >0) 		///
														///
				TRANSMATrix(string)						///	NOTDOC
				DEBUG									///	NOTDOC
				DEVCODE1(passthru)						///						
				DEVCODE2(passthru)						///
				DEVCODE3(passthru)						///
				DEVCODE4(passthru)						///
				DEVCODE5(passthru)						///
				DEVCODE6(passthru)						///
				DEVCODE7(passthru)						///
        ]

		local anything `varlist'
		local devcodes `devcode1' `devcode2' `devcode3' `devcode4' `devcode5' `devcode6' `devcode7'
		
        if "`intpoints'" == "1" {
                di as err "invalid intpoints() option;"
                di as err "intpoints(1) is not allowed by predict"
                exit 198
        }
		
		if "`debug'"!="" {
			local noisily noisily
		}
		
        // parse statistics
		if "`transprob'"!="" {
			local tprob tprob
		}
		if "`los'"!="" {
			local tlos tlos
		}
        local STAT      `mu'            	///
                        `eta'           	///
                        `survival'      	///
						`cif'				///
                        `hazard'      		///
						`chazard'      		///
						`logchazard'		///				
                        `rmst'		    	///
						`timelost'			///
						`totaltimelost'		///
						`sdifference'		///
						`hdifference'		///
						`cifdifference'		///
						`rmstdifference'	///
						`mudifference'		///
						`etadifference'		///
						`tprob'				///
						`tlos'				
        opts_exclusive "`STAT'"

        if "`STAT'" == "" {
                di as txt "(option {bf:mu} assumed)"
                local STAT mu
        }

		if "`marginal'"!="" & "`e(levelvars)'"=="" {
			di as error "No random effects to marginalise over"
			exit 1986
		}
		
		if "`ltruncation'"!="" & ("`STAT'"!="survival" | "`timevar'"=="") {
			di as error "ltruncation() only allowed with survival and timevar()"
			exit 198
		}
		
		if ("`STAT'"=="mudifference" | "`STAT'"=="etadifference" | "`STAT'"=="sdifference" | "`STAT'"=="hdifference" | "`STAT'"=="cifdifference" | "`STAT'"=="rmstdifference") & ("`at1'"=="" | "`at2'"=="") {
			di as error "at1() and at2() required with ?difference predictions"
			exit 198
		}
		
		if "`outcome'"!="" & "`STAT'"=="tprob" {
			di as error "outcome() not allowed with transprob()/los()"
			exit 198
		}
		
        // parse options
        
        opts_exclusive "`fixedonly' `ebmeans' `marginal'"
		local xbtype "`fixedonly'`ebmeans'`marginal'"
		if "`xbtype'"=="" {
			local xbtype "fixedonly"
		}
		
		if "`outcome'"=="" {
			local outcome = 1
		}
		
		// postestimation sample

        tempname touse
        mark `touse' `if' `in'

		if "`timevar'"!="" {
			markout `touse' `timevar'
			local ptvar ptvar(`timevar')					//merlin_build_touses() updated on this
		}
		
		//integration method
		
		if "`e(levelvars)'"!="" {
			local Nrelevels = e(Nlevels) - 1
			forval k=1/`Nrelevels' {
				local ims `ims' `e(intmethod`k')'
				if "`intpoints'"=="" {
					local ips `ips' `e(intpoints`k')'
				}
				else {
					local ips `ips' `intpoints'
				}
			}
			mata: st_local("ims",subinstr(st_local("ims"),"mvaghermite","ghermite"))
			local intmethods intmethod(`ims')
			local intpoints intpoints(`imp')
		}
		
		if "`e(transmatrix)'"!="" | "`transmatrix'"!="" {
			if "`e(transmatrix)'"!="" {
				tempname tmat
				matrix `tmat' = e(transmatrix)
				local passtmat transmatrix(`tmat')
			}
			else {
				local passtmat transmatrix(`transmatrix')
			} 
		}
		
		//====================================================================================================================//
		
		//Preserve data for out of sample prediction etc.
		tempfile newvars 
		preserve	
		
		//Out of sample predictions using at()
		if "`at'" != "" {
			tokenize `at'
			while "`1'"!="" {
				unab 1: `1'
				cap confirm var `2'
				if _rc {
					cap confirm num `2'
					if _rc {
						di in red "invalid at(... `1' `2' ...)"
						exit 198
					}
				}
				qui replace `1' = `2' if `touse'
				mac shift 2
			}
		}	
		
		if "`ci'"=="" {
			
			if "`STAT'"!="mudifference" & "`STAT'"!="etadifference" & "`STAT'"!="sdifference" & "`STAT'"!="hdifference" & "`STAT'"!="cifdifference" & "`STAT'"!="rmstdifference" {
			
				//get coefficients and refill struct
				tempname best
				mat `best' = e(b)
				
				//remove any options
				local cmd `e(cmdline)'
				gettoken merlin cmd : cmd
				gettoken cmd rhs : cmd, parse(",") bind

				//recall merlin
				tempname tousem
				quietly `noisily' merlin_parse `GML'	, touse(`tousem') : `cmd'		///
														, 								///
															predict 					///
															nogen 						///
															from(`best') 				///
															`intmethods' 				///
															`intpoints' 				///
															`ptvar'						///
															`passtmat'					///
															`devcodes'

				mata: merlin_predict("`GML'","`anything'","`touse'","`STAT'","`xbtype'")
				
			}
			else {
				
				local diff survival
				if "`STAT'"=="hdifference" {
					local diff hazard
				}
				else if "`STAT'"=="cifdifference" {
					local diff cif
				}
				else if "`STAT'"=="rmstdifference" {
					local diff rmst
				}
				else if "`STAT'"=="mudifference" {
					local diff mu
				}
				else if "`STAT'"=="etadifference" {
					local diff eta
				}
				
				predictnl double `anything' = 																///
						predict(`diff' `xbtype' outcome(`outcome') at(`at1') timevar(`timevar') `devcodes') ///
					- 	predict(`diff' `xbtype' outcome(`outcome') at(`at2') timevar(`timevar') `devcodes')
				
			}
			MISSMSG `anything'

		}
		else {
			local Sflag = "`STAT'"=="survival"
			if `Sflag' {
				local STAT logchazard
			}
			if "`STAT'"=="tprob" {
				local STAT transprob(`transprob')
				local outcome 
			}
			if "`STAT'"=="tlos" {
				local STAT los(`los')
				local outcome 
			}

			predictnl double `anything' = 	predict(`STAT' `xbtype' outcome(`outcome') 						///
											at(`at') at1(`at1') at2(`at2') timevar(`timevar') `devcodes' 	///
											`passtmat')														///
											if `touse', ci(`anything'_lci `anything'_uci)
			
			if `Sflag' {
				qui replace `anything' 		= exp(-exp(`anything'))
				qui replace `anything'_lci 	= exp(-exp(`anything'_lci))
				qui replace `anything'_uci 	= exp(-exp(`anything'_uci))
				qui rename `anything'_lci _tempmerlinname
				qui rename `anything'_uci `anything'_lci
				qui rename _tempmerlinname `anything'_uci 
			}
		}
		
		
        // The following predictions use empirical Bayes' estimates.

//         local log = "`log'" != ""

//         if _caller() < 14.2 {
//                 capture checkestimationsample
//                 if c(rc) {
//                         di as err "{p 0 0 2}"
//                         di as err "data have changed since estimation;{break}"
//                         di as err ///
// "prediction of empirical Bayes `EBTYPE' requires the original " ///
// "estimation data"
//                         di as err "{p_end}"
//                         exit 459
//                 }
//                 tempname esample
//                 quietly gen byte `esample' = e(sample)
//         }
//         else {
//                 local esample : copy local touse
//         }

//         mata: _gsem_predict_latent(     "`TNAME'",              ///
//                                         "double `TNAME'_*",     ///
//                                         "",                     ///
//                                         "`esample'",            ///
//                                         "`EBTYPE'",             ///
//                                         "",                     ///
//                                         "`intpoints'",          ///
//                                         "`iterate'",            ///
//                                         "`tolerance'",          ///
//                                         `log')
//         if _caller() < 14.2 {
// 			capture assert `touse' == `esample'
// 			if c(rc) {
// 				FILL `touse' `VARLIST'
// 			}
//         }
//         local LATENT : copy local VARLIST

//         if "`sortlist'" != "" {
//                 sort `sortlist'
//         }


//         if "`STAT'" == "survival" {
//                 mata: _gsem_predict_lsurv("`TNAME'",            ///
//                                         "`anything'",           ///
//                                         "`touse'",              ///
//                                         `offset',               ///
//                                         "`outcome'",            ///
//                                         "`LATENT'")
//                 MISSMSG `VARLIST'
//                 exit
//         }

	//====================================================================================================================================================//
	// Restore original data and merge in new variables 
	
		
		local keep `anything'

		if "`ci'" != "" { 
			local keep `keep' `anything'_lci `anything'_uci 
		}
		
		keep `keep'
		qui save `newvars'
		restore
		merge 1:1 _n using `newvars', nogenerate noreport

end

program MISSMSG
        tempname touse
        quietly gen byte `touse' = 1
        markout `touse' `0'
        quietly count if !`touse'
        if r(N) {
                di as txt "(`r(N)' missing values generated)"
        }
end

program FILL
        gettoken touse 0 : 0
        foreach var of local 0 {
                local gvars : char `var'[gvars]
                if "`gvars'" != "" {
                        quietly bysort `gvars' (`var') : ///
                        replace `var' = `var'[1] if `touse'
                }
                quietly replace `var' = . if !`touse'
        }
end

exit
