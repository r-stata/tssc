*! 1.0.0 06Jun2020  // Ariel Linden, Chuck Huber, Geoffrey T. Wodtke 

program define rwrmed, eclass
	
	version 14	

	syntax varlist(min=1 numeric) [if][in] [pweight],		 	///
		avar(varname numeric)									/// 
		mvar(varname numeric)									///
		a(real) 												/// 
		astar(real) 											/// 
		m(real)													/// 
		[ mreg(string) 											/// default is regress
		cvar(varlist numeric)									/// 
		CAT(varlist numeric)									/// specify categorical variables
		cxa														/// interaction between cvar and avar
		cxm														/// interaction between cvar and mvar
		lxm														/// interaction between lvar and mvar
		NOIsily													/// display SEM output (not available for bootstrap)
		NOINTERaction											/// no interaction between treatment and mediator
		BOOTstrap BOOTstrap2(string) * ]									
							

		qui {
			marksample touse
			count if `touse'
			if r(N) == 0 error 2000
			local N = r(N)
			replace `touse' = -`touse'
		}

		* parse to get yvar and lvars 
		gettoken yvar lvar : varlist

		* parse and assess whether vce() has been specified, and if not, set vce(robust)
        gettoken before after : 0, parse(",") bind match(par) quotes
        
		if regexm("`after'","vce") == 0 {
			local vcetype "vce(robust)"
		}

		* set default mediator model to regress
		if "`mreg'" == "" local mreg regress
				
		* verify correct model is chosen
		local mregtypes regress logit poisson
		if !inlist(substr("`mreg'", 1, 3), "reg", "log", "poi") {
				display as error "Error: mreg must be chosen from: `mregtypes'."
				exit 198		
		}

		****************
		// if Bootstrap
		****************
		
		if `"`bootstrap'`bootstrap2'"' != ""  {
			
			local bootstrap `", `bootstrap2'"'
			parse_bootstrap_options `bootstrap'
		
			type_text , mreg(`mreg')
			local NDE "e(`r(NDEtype)')"
			local NIE "e(`r(NIEtype)')"
			local ATE "e(`r(ATEtype)')"
			
			type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')	
			bootstrap CDE=e(CDE) `r(NDEtype)'=`NDE' `r(NIEtype)'=`NIE' `r(ATEtype)'=`ATE',  `s(bsoptions)' : ///
				rwrmed_calc `varlist' if `touse' [`weight' `exp'], avar(`avar') mvar(`mvar') a(`a') astar(`astar') ///
					m(`m') mreg(`mreg') cvar(`cvar') cat(`cat') `cxa' `cxm' `lxm' `nointeraction' `options'

			type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
			di as txt "CDE:  controlled direct effect at m=`m'"
			di as txt "`r(NDEtext)'"
			di as txt "`r(NIEtext)'"
			di as txt "`r(ATEtext)'"
				
		}
		
		********************
		// If not bootstrap
		********************
		if `"`bootstrap'`bootstrap2'"' == ""  {

			rwrmed_margins `varlist' if `touse' [`weight' `exp'], avar(`avar') mvar(`mvar') a(`a') astar(`astar') m(`m') mreg(`mreg') ///
				cvar(`cvar') cat(`cat') `cxa' `cxm' `lxm' `noisily' `nointeraction' `vcetype' `options'
	
		} // end not bootstrap
	
		ereturn local cmdline `"rwrmed `0'"'

end


capture program drop rwrmed_margins
program define rwrmed_margins, eclass
	
	version 14	

	syntax varlist(min=1 numeric) [if][in] [pweight],		 	///
		avar(varname numeric)									/// 
		mvar(varname numeric)									///
		a(real) 												/// 
		astar(real) 											/// 
		m(real)													/// 
		[ mreg(string) 											/// default is regress
		cvar(varlist numeric)									/// 
		CAT(varlist numeric)									/// specify categorical variables
		cxa														/// interaction between cvar and avar
		cxm														/// interaction between cvar and mvar
		lxm														/// interaction between lvar and mvar
		NOIsily													/// display SEM output (not available for bootstrap)
		NOINTERaction * ]										/// no interaction between treatment and mediator


		qui {
			marksample touse
			count if `touse'
			if r(N) == 0 error 2000
			local N = r(N)
			replace `touse' = -`touse'
		}
		
		gettoken yvar lvar : varlist
		
		* set default mediator model to regress
		if "`mreg'" == "" local mreg regress
				
		* verify model name
		local mregtypes regress logit poisson
		if !inlist(substr("`mreg'", 1, 3), "reg", "log", "poi") {
				display as error "Error: mreg must be chosen from: `mregtypes'."
				exit 198		
		}
		
		// generate treatment X mediator interaction
		if "`nointeraction'" == "" {
			tempvar inter
			qui gen `inter' = `avar'*`mvar' if `touse'
		}
		// residualize pre-treatment covariates 
		qui if "`cvar'"!="" {	
			foreach c in `cvar' {
				local ctest : list c in cat
				* categorical variables
				if `ctest' == 1 {
					levelsof `c' if `touse', local(levels)
					local levcnt: word count `levels'
					if `levcnt' < 2 { 
                        di as err "`c' must have at least 2 levels."
						exit 198
					} 
					* binary 
					else if `levcnt' == 2 {
						regress `c' [`weight' `exp'] if `touse'
						tempvar `c'_r
						predict ``c'_r' if e(sample), resid
						* residualized cvars
						local cvar_r `cvar_r' ``c'_r'
						* revised cvars
						local cvarlist `cvarlist' `c'
					}
					* else multicategorical
					else if `levcnt' > 2 {
						sum `c' if `touse', meanonly
						local min = `r(min)'
						levelsof `c' if `c' > `min' & `touse', local(levels)
						foreach i of local levels {
							tempvar `c'`i'
							gen ``c'`i'' = (`c'==`i') if `touse'
							regress ``c'`i'' [`weight' `exp'] if `touse'
							tempvar `c'_r`i'
							predict ``c'_r`i'' if e(sample), resid
							* residualized cvars
							local cvar_r `cvar_r' ``c'_r`i'' 
							* revised cvars
							local cvarlist `cvarlist' ``c'`i''
						} // foreach
					} // end levcnt > 2 
				} // end ctest == 1
				* else continuous
				else {
					regress `c' [`weight' `exp'] if `touse'
					tempvar `c'_r
					predict ``c'_r' if e(sample), resid
					* residualized cvars
					local cvar_r `cvar_r' ``c'_r'
					* revised cvars
					local cvarlist `cvarlist' `c'
				} // end ctest == 0
			} // end foreach
		} // end if cvar
		
		// generate avar X cvar interactions
		if "`cxa'"!="" {	
			foreach c in `cvar_r' {
				tempvar `avar'X`c'
				gen ``avar'X`c'' = `avar' * `c' if `touse'
				local cxa_r `cxa_r'  ``avar'X`c''
			}
		}
	
		// generate mvar X cvar interactions
		if "`cxm'"!="" {	
			foreach c in `cvar_r' {
				tempvar `mvar'X`c'
				gen ``mvar'X`c'' = `mvar' * `c' if `touse'
				local cxm_r `cxm_r'  ``mvar'X`c''
			}
		}
		
		// residualize post-treatment covariates
		qui if "`lvar'"!="" {	
			foreach l in `lvar' {
				local ltest : list l in cat
				if `ltest' == 1 {
					levelsof `l' if `touse', local(levels)
					local levcnt: word count `levels'
					if `levcnt' == 2 {
						capture logit `l' `avar' `cvarlist' `cxa_r' [`weight' `exp'] if `touse'
						capture assert e(rank) == e(k)
						if _rc==9 {
							display "`l' has values that lead to perfect prediction, and thus observations were dropped"
						}
						tempvar `l'_r
						predict ``l'_r' if e(sample), pr
						replace ``l'_r' = `l' - ``l'_r' if `touse'
						local lvar_r `lvar_r' ``l'_r'
					}
					else if `levcnt' > 2 {
						sum `l' if `touse', meanonly
						local min = `r(min)'
						levelsof `l' if `l' > `min' & `touse', local(levels)
						foreach i of local levels {
							tempvar `l'`i'
							gen ``l'`i'' = (`l'==`i') if `touse'
							capture logit ``l'`i'' `avar' `cvarlist' `cxa_r' [`weight' `exp'] if `touse'
							if _rc==430 {
								noisily di _n
								di as err "A model could not converge when residualizing level `i' of `l'."
								di as err "Consider either collapsing this variable into fewer categories, or treat it as a continuous variable" 
								exit 430
							}	
							capture assert e(rank) == e(k)
							if _rc==9 {
								noisily di _n
								di as err "When residualing level `i' of `l', the model had values that lead to perfect prediction, and thus observations were dropped."
								di as err "Consider either collapsing `l' into fewer categories, or treat it as a continuous variable" 
							}
							tempvar `l'_r`i'
							predict ``l'_r`i'' if e(sample), pr
							replace ``l'_r`i'' = ``l'`i'' - ``l'_r`i'' if `touse'
							local lvar_r `lvar_r' ``l'_r`i''
						} // foreach
					} // end levcnt > 2 
				} // end ltest == 1
				else {
					regress `l' `avar' `cvarlist' `cxa_r' [`weight' `exp'] if `touse'
					tempvar `l'_r
					predict ``l'_r' if e(sample), resid
					local lvar_r `lvar_r' ``l'_r'
				} // end ltest == 0
			} // end foreach
		} // end if lvar
		
		// generate mvar X lvar interactions
		if "`lxm'"!="" {	
			foreach l in `lvar_r' {
				tempvar `mvar'X`l'
				gen ``mvar'X`l'' = `mvar' * `l' if `touse'
				local lxm_r `lxm_r'  ``mvar'X`l''
			}
		}
	
		// display SEM table (works with nlcom only)
		if "`noisily'" == ""  {
		    local qui "quietly"			
		}
		
		
		*******************************
		// block 1: mreg=regress // 
		*******************************
		if substr("`mreg'", 1, 3) == "reg" {
		
			// no interaction
			if "`nointeraction'" != "" {
	
				`qui' gsem (`yvar' <- `avar' `mvar' `cvar_r' `lvar_r' `cxa_r' `cxm_r' `lxm_r' [`weight' `exp'] if `touse', regress) ///
							(`mvar' <- `avar' `cvar_r' `cxa_r' , regress), `options'
				
				estimates store gsem
			
				local CDE  "_b[`yvar':`avar'] * (`astar'-`a')"
				local NDE  "_b[`yvar':`avar'] * (`astar'-`a')"
				local NIE  "_b[`mvar':`avar'] * _b[`yvar':`mvar'] *(`astar'-`a')"
				local ATE "(`NDE') + (`NIE')"
			
				qui {
					*CDE
					margins, expression(`CDE') vce(unconditional) post
					matrix cdeB = e(b)
					matrix cdeV = e(V)
					scalar aS = cdeV[1,1]
					mat colname cdeB = CDE

					* NDE
					estimates restore gsem
					margins, expression(`NDE') vce(unconditional) post
					matrix ndeB = e(b)
					matrix ndeV = e(V)
					scalar bS = ndeV[1,1]
					matrix colname ndeB = NDE

					* NIE
					estimates restore gsem
					margins, expression(`NIE') vce(unconditional) post
					matrix nieB = e(b)
					matrix nieV = e(V)
					scalar cS = nieV[1,1]
					mat colname nieB = NIE

					* ATE
					estimates restore gsem
					margins, expression(`ATE') vce(unconditional) post
					matrix ateB = e(b)
					matrix ateV = e(V)
					scalar dS = ateV[1,1]
					matrix colname ateB = ATE

					matrix b = cdeB, ndeB, nieB, ateB
					matrix V = (aS,0,0,0\0,bS,0,0\0,0,cS,0\0,0,0,dS)

					type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
					matrix colname b = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix rowname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix colname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"

				} // end quietly
				estimates drop gsem
				ereturn post b V
				ereturn display
						
				type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
				di as txt "CDE:  controlled direct effect at m=`m'"
				di as txt "`r(NDEtext)'"
				di as txt "`r(NIEtext)'"
				di as txt "`r(ATEtext)'"

			} // end nointeraction
			
			else if "`nointeraction'" == "" {
					
				`qui' gsem  (`yvar' <- `avar' `mvar' `inter' `cvar_r' `lvar_r' `cxa_r' `cxm_r' `lxm_r' [`weight' `exp'] if `touse', regress) ///
							(`mvar' <- `avar' `cvar_r' `cxa_r', regress) , `options'
					
				estimates store gsem
				
				local CDE  "(_b[`yvar':`avar'] + _b[`yvar':`inter'] * `m') * (`astar'-`a')"
				local NDE  "(_b[`yvar':`avar'] + _b[`yvar':`inter'] * (_b[`mvar':_cons] + _b[`mvar':`avar'] * `a')) * (`astar'-`a')"
				local NIE  "_b[`mvar':`avar'] * (_b[`yvar':`mvar'] + _b[`yvar':`inter'] * `astar') * (`astar'-`a')"
				local ATE "(`NDE') + (`NIE')"
			
				qui {
					*CDE
					margins, expression(`CDE') vce(unconditional) post
					matrix cdeB = e(b)
					matrix cdeV = e(V)
					scalar aS = cdeV[1,1]
					mat colname cdeB = CDE

					* NDE
					estimates restore gsem
					margins, expression(`NDE') vce(unconditional) post
					matrix ndeB = e(b)
					matrix ndeV = e(V)
					scalar bS = ndeV[1,1]
					matrix colname ndeB = NDE

					* NIE
					estimates restore gsem
					margins, expression(`NIE') vce(unconditional) post
					matrix nieB = e(b)
					matrix nieV = e(V)
					scalar cS = nieV[1,1]
					mat colname nieB = NIE

					* ATE
					estimates restore gsem
					margins, expression(`ATE') vce(unconditional) post
					matrix ateB = e(b)
					matrix ateV = e(V)
					scalar dS = ateV[1,1]
					matrix colname ateB = ATE

					matrix b = cdeB, ndeB, nieB, ateB
					matrix V = (aS,0,0,0\0,bS,0,0\0,0,cS,0\0,0,0,dS)

					type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
					matrix colname b = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix rowname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix colname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"

				} // end quietly
				estimates drop gsem
				ereturn post b V
				ereturn display
						
				type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
				di as txt "CDE:  controlled direct effect at m=`m'"
				di as txt "`r(NDEtext)'"
				di as txt "`r(NIEtext)'"
				di as txt "`r(ATEtext)'"
							
			} // end with interaction 
		} // end mreg == regress

	
		**************************
		// block 2: mreg=logit // 
		**************************
		if substr("`mreg'", 1, 3) == "log" {
			
			// no interaction
			if "`nointeraction'" != "" {
					
				`qui' gsem  (`yvar' <- `avar' `mvar' `cvar_r' `lvar_r' `cxa_r' `cxm_r' `lxm_r' [`weight' `exp'] if `touse', regress) ///
					(`mvar' <- `avar' `cvar_r' `cxa_r', logit) , `options'

				estimates store gsem
			
				local CDE  "_b[`yvar':`avar'] * (`astar'-`a')"
				local NDE  "_b[`yvar':`avar'] * (`astar'-`a')"
				local NIE `""_b[`yvar':`mvar'] * ((exp(_b[`mvar':_cons] + _b[`mvar':`avar'] * `astar') / (1 + exp(_b[`mvar':_cons] + _b[`mvar':`avar'] * `astar'))) - (exp(_b[`mvar':_cons]""'
				local NIE `"`NIE' " + _b[`mvar':`avar'] *`a') / (1 + exp(_b[`mvar':_cons] + _b[`mvar':`avar'] * `a'))))""'
				local ATE "(`NDE') + `NIE'"
			
				qui {
					*CDE
					margins, expression(`CDE') vce(unconditional) post
					matrix cdeB = e(b)
					matrix cdeV = e(V)
					scalar aS = cdeV[1,1]
					mat colname cdeB = CDE

					* NDE
					estimates restore gsem
					margins, expression(`NDE') vce(unconditional) post
					matrix ndeB = e(b)
					matrix ndeV = e(V)
					scalar bS = ndeV[1,1]
					matrix colname ndeB = NDE

					* NIE
					estimates restore gsem
					margins, expression(`NIE') vce(unconditional) post
					matrix nieB = e(b)
					matrix nieV = e(V)
					scalar cS = nieV[1,1]
					mat colname nieB = NIE

					* ATE
					estimates restore gsem
					margins, expression(`ATE') vce(unconditional) post
					matrix ateB = e(b)
					matrix ateV = e(V)
					scalar dS = ateV[1,1]
					matrix colname ateB = ATE

					matrix b = cdeB, ndeB, nieB, ateB
					matrix V = (aS,0,0,0\0,bS,0,0\0,0,cS,0\0,0,0,dS)

					type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
					matrix colname b = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix rowname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix colname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"

				} // end quietly
				estimates drop gsem
				ereturn post b V
				ereturn display
						
				type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
				di as txt "CDE:  controlled direct effect at m=`m'"
				di as txt "`r(NDEtext)'"
				di as txt "`r(NIEtext)'"
				di as txt "`r(ATEtext)'"	
		
			} // end nointeraction  

			// with interaction
			if "`nointeraction'" == "" {

				`qui' gsem  (`yvar' <- `avar' `mvar' `inter' `cvar_r' `lvar_r' `cxa_r' `cxm_r' `lxm_r' [`weight' `exp'] if `touse', regress) ///
					(`mvar' <- `avar' `cvar_r' `cxa_r', logit) , `options'

				estimates store gsem
			
				local CDE  "(_b[`yvar':`avar'] + _b[`yvar':`inter'] * `m')  *  (`astar'-`a')"
				local NDE  "(_b[`yvar':`avar'] + _b[`yvar':`inter'] * (exp(_b[`mvar':_cons] + _b[`mvar':`avar'] *`a') / (1 + exp(_b[`mvar':_cons] + _b[`mvar':`avar'] * `a')))) * (`astar'-`a')"
				local NIE  `""(_b[`yvar':`mvar'] + _b[`yvar':`inter'] * `astar') * ((exp(_b[`mvar':_cons] + _b[`mvar':`avar'] * `astar') / (1 + exp(_b[`mvar':_cons] + _b[`mvar':`avar'] * ""'
				local NIE `"`NIE' " `astar'))) - (exp(_b[`mvar':_cons] + _b[`mvar':`avar'] *`a') / (1 + exp(_b[`mvar':_cons] + _b[`mvar':`avar'] * `a'))))""'
				local ATE "(`NDE') + `NIE'"
			
				qui {
					*CDE
					margins, expression(`CDE') vce(unconditional) post
					matrix cdeB = e(b)
					matrix cdeV = e(V)
					scalar aS = cdeV[1,1]
					mat colname cdeB = CDE

					* NDE
					estimates restore gsem
					margins, expression(`NDE') vce(unconditional) post
					matrix ndeB = e(b)
					matrix ndeV = e(V)
					scalar bS = ndeV[1,1]
					matrix colname ndeB = NDE

					* NIE
					estimates restore gsem
					margins, expression(`NIE') vce(unconditional) post
					matrix nieB = e(b)
					matrix nieV = e(V)
					scalar cS = nieV[1,1]
					mat colname nieB = NIE

					* ATE
					estimates restore gsem
					margins, expression(`ATE') vce(unconditional) post
					matrix ateB = e(b)
					matrix ateV = e(V)
					scalar dS = ateV[1,1]
					matrix colname ateB = ATE

					matrix b = cdeB, ndeB, nieB, ateB
					matrix V = (aS,0,0,0\0,bS,0,0\0,0,cS,0\0,0,0,dS)

					type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
					matrix colname b = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix rowname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix colname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"

				} // end quietly
				estimates drop gsem
				ereturn post b V
				ereturn display
						
				type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
				di as txt "CDE:  controlled direct effect at m=`m'"
				di as txt "`r(NDEtext)'"
				di as txt "`r(NIEtext)'"
				di as txt "`r(ATEtext)'"	

			} // end nointeraction
		} // end mreg == logit

		****************************
		// block 3: mreg=poisson // 
		****************************
		if substr("`mreg'", 1, 3) == "poi" {
			
			// no interaction
			if "`nointeraction'" != "" {

				`qui' gsem  (`yvar' <- `avar' `mvar' `cvar_r' `lvar_r' `cxa_r' `cxm_r' `lxm_r' [`weight' `exp'] if `touse', regress) ///
					(`mvar' <- `avar' `cvar_r' `cxa_r', poisson), `options'

				estimates store gsem
			
				local CDE  "(_b[`yvar':`avar'] * (`astar'-`a'))"
				local NDE  "(_b[`yvar':`avar'] * (`astar'-`a'))"
				local NIE  "(_b[`yvar':`mvar'] * ((exp(_b[`mvar':_cons] + _b[`mvar':`avar'] * `astar')) - (exp(_b[`mvar':_cons] + _b[`mvar':`avar'] * `a'))))"
				local ATE "(`NDE') + (`NIE')"
			
				qui {
					*CDE
					margins, expression(`CDE') vce(unconditional) post
					matrix cdeB = e(b)
					matrix cdeV = e(V)
					scalar aS = cdeV[1,1]
					mat colname cdeB = CDE

					* NDE
					estimates restore gsem
					margins, expression(`NDE') vce(unconditional) post
					matrix ndeB = e(b)
					matrix ndeV = e(V)
					scalar bS = ndeV[1,1]
					matrix colname ndeB = NDE

					* NIE
					estimates restore gsem
					margins, expression(`NIE') vce(unconditional) post
					matrix nieB = e(b)
					matrix nieV = e(V)
					scalar cS = nieV[1,1]
					mat colname nieB = NIE

					* ATE
					estimates restore gsem
					margins, expression(`ATE') vce(unconditional) post
					matrix ateB = e(b)
					matrix ateV = e(V)
					scalar dS = ateV[1,1]
					matrix colname ateB = ATE

					matrix b = cdeB, ndeB, nieB, ateB
					matrix V = (aS,0,0,0\0,bS,0,0\0,0,cS,0\0,0,0,dS)

					type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
					matrix colname b = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix rowname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix colname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"

				} // end quietly
				estimates drop gsem
				ereturn post b V
				ereturn display
						
				type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
				di as txt "CDE:  controlled direct effect at m=`m'"
				di as txt "`r(NDEtext)'"
				di as txt "`r(NIEtext)'"
				di as txt "`r(ATEtext)'"	
					
			} // end no interaction

			// with interaction
			if "`nointeraction'" == "" {
		
				`qui' gsem  (`yvar' <- `avar' `mvar' `inter' `cvar_r' `lvar_r' `cxa_r' `cxm_r' `lxm_r' [`weight' `exp'] if `touse', regress) ///
					(`mvar' <- `avar' `cvar_r' `cxa_r', poisson), `options'

				estimates store gsem
			
				local CDE  "(_b[`yvar':`avar'] + _b[`yvar':`inter'] * `m')  *  (`astar'-`a')"
				local NDE  "(_b[`yvar':`avar'] + _b[`yvar':`inter'] * (exp(_b[`mvar':_cons] + _b[`mvar':`avar'] * `a'))) * (`astar'-`a')"
				local NIE  `""(_b[`yvar':`mvar'] + _b[`yvar':`inter'] * `astar') * ((exp(_b[`mvar':_cons] + _b[`mvar':`avar'] * `astar')) - (exp(_b[`mvar':_cons]""' 
				local NIE `"`NIE' " + _b[`mvar':`avar'] * `a')))""'
				local ATE "(`NDE') + `NIE'"
		
			
				qui {
					*CDE
					margins, expression(`CDE') vce(unconditional) post
					matrix cdeB = e(b)
					matrix cdeV = e(V)
					scalar aS = cdeV[1,1]
					mat colname cdeB = CDE

					* NDE
					estimates restore gsem
					margins, expression(`NDE') vce(unconditional) post
					matrix ndeB = e(b)
					matrix ndeV = e(V)
					scalar bS = ndeV[1,1]
					matrix colname ndeB = NDE

					* NIE
					estimates restore gsem
					margins, expression(`NIE') vce(unconditional) post
					matrix nieB = e(b)
					matrix nieV = e(V)
					scalar cS = nieV[1,1]
					mat colname nieB = NIE

					* ATE
					estimates restore gsem
					margins, expression(`ATE') vce(unconditional) post
					matrix ateB = e(b)
					matrix ateV = e(V)
					scalar dS = ateV[1,1]
					matrix colname ateB = ATE

					matrix b = cdeB, ndeB, nieB, ateB
					matrix V = (aS,0,0,0\0,bS,0,0\0,0,cS,0\0,0,0,dS)

					type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
					matrix colname b = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix rowname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"
					matrix colname V = CDE "`r(NDEtype)'"  "`r(NIEtype)'"  "`r(ATEtype)'"

				} // end quietly
				estimates drop gsem
				ereturn post b V
				ereturn display
						
				type_text , mreg(`mreg') lvar(`lvar') cvar(`cvar')
				di as txt "CDE:  controlled direct effect at m=`m'"
				di as txt "`r(NDEtext)'"
				di as txt "`r(NIEtext)'"
				di as txt "`r(ATEtext)'"		
		
			} // end with interaction
		} // end mreg == poisson

end


capture program drop parse_bootstrap_options
program parse_bootstrap_options, sclass
    version 14
    syntax [varlist(default=none)]        ///
           [, reps(integer 50) * ]
            
    local bsoptions "reps(`reps') noheader nowarn `options'"
    sreturn clear
    sreturn local bsoptions `bsoptions'
end


capture program drop type_text
program type_text, rclass
    version 14
    syntax [varlist(default=none)] [, mreg(string) lvar(string) cvar(string) ]

		* regress
		if substr("`mreg'", 1, 3) == "reg" {
		
			// text to accompany estimates
			if "`lvar'"=="" {
			    local NDEtype "NDE"
				local NDEtext NDE: natural direct effect
				local NIEtype "NIE"
				local NIEtext NIE: natural indirect effect
				local ATEtype "ATE"
				local ATEtext ATE: average total effect
			}
			else {
				local NDEtype "RNDE"
				local NDEtext RNDE: randomized intervention analogue of the natural direct effect
				local NIEtype "RNIE"
				local NIEtext RNIE: randomized intervention analogue of the natural indirect effect
				local ATEtype "RATE"
			    local ATEtext RATE: randomized intervention analogue of the total effect
			}
		} // mregs = regress
	
		* logit
		if substr("`mreg'", 1, 3) == "log" {
				
			// text to accompany estimates
			if "`cvar'"=="" & "`lvar'"=="" {
				local NDEtype NDE
				local NDEtext NDE: natural direct effect
				local NIEtype NIE
				local NIEtext NIE: natural indirect effect
				local ATEtype ATE
				local ATEtext ATE: average total effect
			}
			else if "`cvar'"=="" & "`lvar'"!="" {
			    local NDEtype RNDE
				local NDEtext RNDE: randomized intervention analogue of the natural direct effect
				local NIEtype RNIE
				local NIEtext RNIE: randomized intervention analogue of the natural indirect effect
				local ATEtype RATE
			    local ATEtext RATE: randomized intervention analogue of the total effect
			}
			else if "`cvar'"!="" & "`lvar'"=="" {
			    local NDEtype NDEc
				local NDEtext NDEc: natural direct effect at sample means of cvars
				local NIEtype NIEc
				local NIEtext NIEc: natural indirect effect at sample means of cvars
				local ATEtype ATEc
				local ATEtext ATEc: total effect at sample means of cvars
			}
			else {
				local NDEtype RNDEc
				local NDEtext RNDEc: randomized intervention analogue of the natural direct effect at sample means of cvars
				local NIEtype RNIEc
				local NIEtext RNIEc: randomized intervention analogue of the natural indirect effect at sample means of cvars
				local ATEtype RATEc
			    local ATEtext RATEc: randomized intervention analogue of the total effect at sample means of cvars
			}
		} // mregs = logit	

		* poisson
		if substr("`mreg'", 1, 3) == "poi" {
		
			// text to accompany estimates
			if "`cvar'"=="" & "`lvar'"=="" {
				local NDEtype NDE
				local NDEtext NDE: natural direct effect
				local NIEtype NIE
				local NIEtext NIE: natural indirect effect
				local ATEtype ATE
				local ATEtext ATE: average total effect
			}
			else if "`cvar'"=="" & "`lvar'"!="" {
			    local NDEtype RNDE
				local NDEtext RNDE: randomized intervention analogue of the natural direct effect
				local NIEtype RNIE
				local NIEtext RNIE: randomized intervention analogue of the natural indirect effect
				local ATEtype RATE
			    local ATEtext RATE: randomized intervention analogue of the total effect
			}
			else if "`cvar'"!="" & "`lvar'"=="" {
			    local NDEtype NDEc
				local NDEtext NDEc: natural direct effect at sample means of cvars
				local NIEtype NIEc
				local NIEtext NIEc: natural indirect effect at sample means of cvars
				local ATEtype ATEc
			    local ATEtext ATEc: total effect at sample means of cvars
			}
			else {
				local NDEtype RNDEc
				local NDEtext RNDEc: randomized intervention analogue of the natural direct effect at sample means of cvars
				local NIEtype RNIEc
				local NIEtext RNIEc: randomized intervention analogue of the natural indirect effect at sample means of cvars
				local ATEtype RATEc
			    local ATEtext RATEc: randomized intervention analogue of the total effect at sample means of cvars
			}	
		} // mregs = poisson					
		
		*return clear
		return local NDEtype `NDEtype'
		return local NDEtext `NDEtext'
		return local NIEtype `NIEtype'
		return local NIEtext `NIEtext'
		return local ATEtype `ATEtype'
		return local ATEtext `ATEtext'
end



			





