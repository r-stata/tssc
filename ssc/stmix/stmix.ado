*! version 1.0.3 06oct2016 MJC

/*
History
MJC 06oct2016 version 1.0.3 - likelihoods now comparable to streg
MJC 13jul2012 version 1.0.2 - linear predictor changed to include nocons, Replay tidied, initmat() and noinit options added
MJC 21Nov2011 version 1.0.1 - added nolog and keepcons options. Additional user defined constraints can now be used.
MJC 07Oct2011 version 1.0.0
*/

program stmix, eclass byable(onecall)
	version 11.2
	if _by() {
		local by "by `_byvars'`_byrc0':"
	}
	if replay() {
		syntax  , [DISTribution(string) *]
		if "`distribution'" != "" {
			`by' Estimate `0'
		}
		else {
			if "`e(cmd)'" != "stmix" {
				error 301
			}
	                if _by() {
        	                error 190
	                }
			Replay `0'
		}
		exit
	}
	`by' Estimate `0'
end


program Estimate, eclass byable(recall)
	st_is 2 analysis
	syntax [varlist(default=empty)] [if] [in] 	[,										///
													DISTribution(string)				///
													LAMBDA1(varlist)					///
													GAMMA1(varlist)						///
													LAMBDA2(varlist)					///
													GAMMA2(varlist)						///
													PMIX(varlist)						///
																						///
													NOHR								///
													SHOWCons							///
													KEEPCons							///
													SHOWINIT							///
																						///
													PMIXConstraint(real 0)				///
													Level(cilevel)						///
													NOLOG								///
													NOINIT								///
													INITMAT(string)						///		
													COPY								///
													SKIP								///
													*									///
												]

	//======================================================================================================================================//
	// Error checks
																							
		if "`weight'" != "" {
			display as err "weights not allowed"
			exit 198
		}
		local wt: char _dta[st_w]       
		if "`wt'" != "" {
			display as err "weights not allowed"
			exit 198
		}
		
		// Factor variables not allowed 
		fvexpand `varlist' `lambda1' `gamma1' `lambda2' `gamma2' `pmix'
		if "`r(fvops)'" != "" {
			display as error "Factor variables not allowed. Create your own dummy varibles."
			exit 198
		}

	//======================================================================================================================================//
	// Preliminaries 

		marksample touse
		markout `touse' `lambda1' `gamma1' `lambda2' `gamma2' `pmix'
		qui replace `touse' = 0 if _st==0
		
		mlopts mlopts , `options'	/* Extract any ml options to pass to ml model */
		local extra_constraints `s(constraints)'

		if "`distribution'"=="" {
			local dist "ww"
		}
		else {
			local l = length("`distribution'")
			if substr("weibexp",1,max(5,`l')) == "`distribution'" | "we" == "`distribution'" {
				local dist "we"
			}
			else if substr("weibweib",1,max(5,`l')) == "`distribution'" | "ww" == "`distribution'" {
				local dist "ww"
			}
			else {
				di as error "Unknown distribution"
				exit 198
			}
		}			
		
		if "`dist'"=="ww" {
			local geqn "(ln_gamma2: =`gamma2')"
			local text "Weibull-Weibull"
		}
		else {
			local text "Weibull-exponential"
		}
	
		local showin "quietly"
		if "`showinit'"!="" {
			local showin
		}
				
		if "`dist'"=="we" & "`gamma2'"!="" {
			di as error "gamma2 invalid when distribution is weibexp"
			exit 198
		}
		
		if "`varlist'"=="" {
			global xbeqn no		
		}
		else {
			local linpred "(xb: _t _d _t0= `varlist',nocons)"
			global xbeqn yes
		}
		
		/* Check Time Origin */
		qui summ _t0 if `touse', meanonly
		if r(max)>0 {
			display in green  "note: delayed entry models are being fitted"
			global del_entry = 1
		}
		else {
			global del_entry = 0
		}
	
	//======================================================================================================================================//
	// Obtain initial values
	
		constraint free
		constraint `r(free)' [logit_p_mix][_cons] = `pmixconstraint'
		local cons "`r(free)'"
		local conslist "`r(free)'"
		
		local dropconslist `conslist'
		// If further constraints are listed then remove this from mlopts and add to conslist
		if "`extra_constraints'" != "" {
			local mlopts : subinstr local mlopts "constraints(`extra_constraints')" "",word
			local conslist `conslist' `extra_constraints'
			local conslist2 `conslist2' `extra_constraints'
		}
			
		if "`noinit'"=="" & "`initmat'"=="" {
			local constopts "constraints(`conslist')"
			di in green "Obtaining initial values:"
			di ""
			`showin' ml model lf stmix_lf_`dist'							///
							`linpred'										///
							(logit_p_mix: =`pmix')	 						///
							(ln_lambda1: =`lambda1')						/// 
							(ln_gamma1: =`gamma1') 							///
							(ln_lambda2: =`lambda2')						///
							`geqn'	 										///
							if `touse',										///
							`constopts'										///
							`mlopts'										///
							`nolog'											///
							iters(100)										///
							maximize
			
			`showin' ml display
			
			/* Extract initial values for final estimation */
			tempname startinitmat
			mat `startinitmat' = e(b)
			local initmatchoice "init(`startinitmat', `copy' `skip')"
			local searchopt "search(off)"
		}
		
		if "`initmat'"!="" {
			local initmatchoice "init(`initmat',`copy' `skip')"
			local searchopt "search(off)"
		}
		
	//======================================================================================================================================//
	// Final estimation

		di in green "Fitting full model:"
		ml model lf stmix_lf_`dist'										///
						`linpred'										///
						(logit_p_mix: =`pmix')	 						///
						(ln_lambda1: =`lambda1')						/// 
						(ln_gamma1: =`gamma1') 							///
						(ln_lambda2: =`lambda2')						///
						`geqn'	 										///
						if `touse',										///
						`mlopts'										///
						`searchopt'										///
						waldtest(0)										///
						`initmatchoice'									///
						`nolog'											///
						maximize

		ereturn local title "Mixture `text' proportional hazards regression"
		ereturn local cmd stmix
		ereturn local predict stmix_pred
		ereturn local distribution "`dist'"
		ereturn local varlist `varlist'
		ereturn local lambda1 `lambda1'
		ereturn local gamma1 `gamma1'
		ereturn local lambda2 `lambda2'
		ereturn local gamma2 `gamma2'
		ereturn local pmix `pmix'
		
		if "`keepcons'" == "" {
			constraint drop `dropconslist'
		}
		else {
			ereturn local sp_constraints `dropconslist'
		}
		
		Replay, level(`level') `showcons' `nohr'
		
end

program Replay
	syntax [, Level(cilevel) SHOWCons NOHR]
		
	if "`showcons'"!="" {
		local constdi
	}
	else {
		local constdi "nocnsreport"
	}
	
	if "`nohr'"=="" & "`e(lambda1)'"=="" & "`e(lambda2)'"=="" & "`e(gamma1)'"=="" & "`e(gamma2)'"=="" & "`e(pmix)'"=="" & "`e(varlist)'"!="" {
		local hr hr
	}
	
	ml display, `constdi' `hr' level(`level')

end
