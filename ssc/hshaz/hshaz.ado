*! version 1.2.0 Stephen P. Jenkins, December 2005
*!   corrected bug in SEs displayed for Prob(Types), 
*!   fixed help file reference to starting values for Prob(Types)
*! version 1.1.1 Stephen P. Jenkins, September 2004
*! Discrete time proportional hazard model with Heckman-Singer mass point heterogeneity


/*------------------------------------------------ playback request */
program define hshaz, eclass byable(onecall) sortpreserve
	version 8.2
	if replay() {
		if "`e(cmd)'" != "hshaz" {
			noi di as error "results for hshaz not found"
			exit 301
		}
		if _by() { 
			error 190 
		} 
		Display `0'
		exit `rc'
	}
	if _by() {
		by `_byvars'`_byrc0': Estimate `0'
	}
	else	Estimate `0'
end

/*------------------------------------------------ estimation */

program define Estimate, eclass byable(recall)

	syntax varlist(numeric) [if] [in] [fw iw] [,  			///
		Id(varname) Dead(varname numeric) Seq(varname numeric) 	///
		Nmp(integer 2) M2(real 1) P2(real .3) M3(real -1) P3(real .3) /// 
		M4(real .1) P4(real .1)	M5(real -.1) P5(real .1)		///
		NOCONS  noBeta0						///
		Level(integer $S_level) EForm   			///
		noLOG  * ]


	local title "Discrete time PH model, with discrete mixture"

	local option0 `options'

	local wtype `weight'
	local wtexp `"`exp'"'
	if "`weight'" != "" { 
		local wgt `"[`weight'`exp']"'  
	}

	if "`level'" != "" {
		local level "level(`level')"
	}
	
        local log = cond("`log'" == "", "noisily", "quietly") 
        local log2 = cond("`beta0'" == "", "noisily", "quietly")
	
	marksample touse 
	markout `touse' `varlist'  

	qui count if `touse'
	if r(N) == 0 {
		error 2000
	}

	mlopts mlopts, `options'

	set more off

		if "`id'" == "" {
			di as error "Variable identifying each person must "
			di as error " be specified in id(idvar) "
			exit 198
		}
	
		if "`dead'" == "" {
			di as error "Per-interval censoring indicator variable must "
			di as error "be specified in dead(deadvar):"
			di  "see -hshaz- help file"
			exit 198
		}

		capture assert `dead'==1 | `dead'==0
		if _rc~=0 {
			di as error "Per-interval censoring indicator variable must "
			di as error "equal one or zero: see -hshaz- help file"
			exit 198	
		}

		if "`seq'" == "" {
			di as error "Integer-valued variable identifying "
			di as error "spell time interval be specified " _c
			di as error "in seq(seqvar) "
			exit 198
		}

		capture assert (`nmp' == 2  | `nmp' == 3 | `nmp' == 4 | `nmp' == 5) 
		if _rc ~= 0   {
			di as error "Number of mass points must be 2 (default), 3, 4, or 5"
			exit 198
		}

		capture assert `m2' ~= 0 
		if _rc ~= 0   {
			di as error "Choose non-zero starting value for m2"
			exit 198
		}

		capture assert (`p2' > 0 & `p2' < 1) 
		if _rc ~= 0   {		
			di as error "p2 must be between 0 and 1"
			exit 198
		}


		if `nmp' == 2 {
			local m3 
			local p3
			local m4 
			local p4
			local m5 
			local p5
		}

		if `nmp' == 3 {
			local m4 
			local p4
			local m5 
			local p5
		}

		if `nmp' == 4 {
			local m5 
			local p5
		}


		if `nmp' > 2 {
			capture assert `m3' ~= 0 
			if _rc ~= 0   {
				di as error "Choose non-zero starting value for m3"
				exit 198
			}
			capture assert (`p3' > 0 & `p3' < 1) 
			if _rc ~= 0   {		
				di as error "p3 must be between 0 and 1"
				exit 198
			}

		}

		if `nmp' > 3 {
			capture assert `m4' ~= 0 
			if _rc ~= 0   {
				di as error "Choose non-zero starting value for m4"
				exit 198
			}
			capture assert (`p4' > 0 & `p4' < 1) 
			if _rc ~= 0   {		
				di as error "p4 must be between 0 and 1"
				exit 198
			}
		}

		if `nmp' > 4 {
			capture assert `m5' ~= 0 
			if _rc ~= 0   {
				di as error "Choose non-zero starting value for m5"
				exit 198
			}
			capture assert (`p5' > 0 & `p5' < 1) 
			if _rc ~= 0   {		
				di as error "p5 must be between 0 and 1"
				exit 198
			}
		}

		if `nmp' == 3 {
			capture assert (`p2' + `p3' < 1) 
			if _rc ~= 0   {		
				di as error "Must have p2 + p3 < 1"
				exit 198
			}
		}

		if `nmp' == 4 {
			capture assert (`p2' + `p3' + `p4' < 1) 
			if _rc ~= 0   {		
				di as error "Must have p2 + p3 + p4 < 1"
				exit 198
			}
		
		}

		if `nmp' == 5 {
			capture assert (`p2' + `p3' + `p4' + `p5' < 1) 
			if _rc ~= 0   {		
				di as error "Must have p2 + p3 + p4 + p5 < 1"
				exit 198
			}
		
		}

		tempvar mysamp 
		tempname b b0 b1 b2 lnf V mass2 logitp20 logitp2 ///
			mass3 logitp30 logitp3 mass4 logitp40 logitp4 ///
			mass5 logitp50 logitp5

		scalar `logitp20' = logit(`p2')
		
		if `nmp' >= 3 {
			scalar `logitp30' = logit(`p3')
		}

		if `nmp' >= 4 {
			scalar `logitp40' = logit(`p4')
		}
		if `nmp' >= 5 {
			scalar `logitp50' = logit(`p5')
		}



		set more off

 		_rmcoll `varlist' `wgt' if `touse', `nocons'
		local varlist `r(varlist)'

			/* get estimates of no-het model */
		
		if "`beta0'" == "" {
			di as txt "Discrete time PH model without frailty" 
		}
		`log2' glm `dead' `varlist' `wgt' if `touse', f(b) l(c) ///
			`level' `eform'  `nocons' nolog

	quietly {
		local LL1 = e(ll)

		matrix `b0' = e(b)
		matrix coleq `b0' = hazard

			// now pack out -b0- with starting
			//  value for mass point and logitp
			 

		matrix `mass2' = (`m2')
		matrix colnames `mass2' = m2:_cons
		matrix `logitp2' = (`logitp20')
		matrix colnames `logitp2' = logitp2:_cons

		if `nmp' >= 3 {
			matrix `mass3' = (`m3')
			matrix colnames `mass3' = m3:_cons
			matrix `logitp3' = (`logitp30')
			matrix colnames `logitp3' = logitp3:_cons
		}

		if `nmp' >= 4 {
			matrix `mass4' = (`m4')
			matrix colnames `mass4' = m4:_cons
			matrix `logitp4' = (`logitp40')
			matrix colnames `logitp4' = logitp4:_cons
		}

		if `nmp' >= 5 {
			matrix `mass5' = (`m5')
			matrix colnames `mass5' = m5:_cons
			matrix `logitp5' = (`logitp50')
			matrix colnames `logitp5' = logitp5:_cons
		}

		if `nmp' == 2 {
			matrix `b1' = `b0',`mass2',`logitp2'
			local eqq "(m2: ) (logitp2: ) "
		}

		if `nmp' == 3 {
			matrix `b1' = `b0',`mass2',`mass3',`logitp2',`logitp3'
			local eqq "(m2: ) (m3: ) (logitp2: ) (logitp3: ) "
		}

		if `nmp' == 4 {
			matrix `b1' = `b0',`mass2',`mass3',`mass4',`logitp2',`logitp3',`logitp4'
			local eqq "(m2: ) (m3: ) (m4: ) (logitp2: ) (logitp3: ) (logitp4: ) "
		}

		if `nmp' == 5 {
			matrix `b1' = `b0',`mass2',`mass3',`mass4', `mass5',`logitp2',`logitp3',`logitp4',`logitp5'
			local eqq "(m2: ) (m3: ) (m4: ) (m5: ) (logitp2: ) (logitp3: ) (logitp4: ) (logitp5: ) "
		}


			/* estimate full model */
		
		sort `id' `touse'  `seq'

		global S_E_id "`id'"
		global S_E_dd "`dead'"
		global S_E_nmp "`nmp'"

		
		`log' ml model d0 hshaz_ll (hazard: `dead' = `varlist', `nocons')  `eqq' ///
				`wgt' if `touse', maximize init(`b1') waldtest(0) search(off)		 ///
				collinear title(`title') `level' `mlopts' `stdopts' `modopts'
		
		tempname tag
		egen `tag' = tag(`id') if e(sample) 
		count if `tag' & e(sample)
		eret scalar N_spell = r(N) 

		eret local cmd "hshaz"
		eret local depvar "`dead'"
		eret local idvar "`id'"
		eret local seqvar "`seq'"

		eret scalar ll_nofr = `LL1'

		// prob(Type 2) = invlogit(logitp)
		// s.e.(prob) = s.e.(logitp) * invlogit(logitp) * invlogit(-logitp)

		eret scalar nmp = `nmp'
		eret scalar m1 = 0
		eret scalar m2 = [m2]_cons
		eret scalar se_m2 =   [m2]_se[_cons]
		eret scalar pr2 = invlogit( [logitp2]_cons )
		eret scalar se_pr2 =   [logitp2]_se[_cons] * invlogit( [logitp2]_cons) * invlogit( -[logitp2]_cons )

		if `nmp' > 2 {
			eret scalar m3 = [m3]_cons
			eret scalar se_m3 =   [m3]_se[_cons]
			eret scalar pr3 = invlogit( [logitp3]_cons )
			eret scalar se_pr3 =   [logitp3]_se[_cons] * invlogit( [logitp3]_cons) * invlogit( -[logitp3]_cons )
		}
		if `nmp' > 3 {
			eret scalar m4 = [m4]_cons
			eret scalar se_m4 =   [m4]_se[_cons]
			eret scalar pr4 = invlogit( [logitp4]_cons )
			eret scalar se_pr4 =   [logitp4]_se[_cons] * invlogit( [logitp4]_cons) * invlogit( -[logitp4]_cons )
		}

		if `nmp' > 4 {
			eret scalar m5 = [m5]_cons
			eret scalar se_m5 =   [m5]_se[_cons]
			eret scalar pr5 = invlogit( [logitp5]_cons )
			eret scalar se_pr5 =   [logitp5]_se[_cons] * invlogit( [logitp5]_cons) * invlogit( -[logitp5]_cons )
		}

		if `nmp' == 2 {
			eret scalar pr1 = 1 - `e(pr2)' 
		}
		if `nmp' == 3 {
			eret scalar pr1 = 1 - `e(pr2)'  - `e(pr3)'
		}
		if `nmp' == 4 {
			eret scalar pr1 = 1 - `e(pr2)'  - `e(pr3)'  - `e(pr4)' 
		}
		if `nmp' == 5 {
			eret scalar pr1 = 1 - `e(pr2)'  - `e(pr3)'  - `e(pr4)' - `e(pr5)' 
		}

	}

	Display, `level' `eform'

end

program define Display , eclass

	syntax [,Level(int $S_level) EForm *]
	local diopts "`options'"
	ml display, level(`level') `eform' plus
	if `level' < 10 | `level' > 99 {
		local level = 95
		}
	if `e(nmp)' == 2 {
		_diparm logitp2, level(`level') func(1-invlogit(@)) ///
			deriv( -invlogit(@)*(1-invlogit(@)) ) label("Prob. Type 1") prob ci(logit)
		eret scalar se_pr1 = r(se)
		_diparm logitp2, invlogit level(`level') label("Prob. Type 2") prob ci(logit)
	}
	if `e(nmp)' == 3 {
		_diparm logitp2 logitp3, level(`level') func(1-invlogit(@1)-invlogit(@2)) ///
			deriv(  -invlogit(@1)*(1-invlogit(@1))  ///
			        -invlogit(@2)*(1-invlogit(@2)) ) ///
			label("Prob. Type 1") prob ci(logit)
		eret scalar se_pr1 = r(se)
		_diparm logitp2, invlogit level(`level') label("Prob. Type 2") prob ci(logit)
		_diparm logitp3, invlogit level(`level') label("Prob. Type 3") prob ci(logit)
	}
	if `e(nmp)' == 4 {
		_diparm logitp2 logitp3 logitp4, level(`level') ///
			func(1-invlogit(@1)-invlogit(@2)-invlogit(@3)) ///
			deriv( 	-invlogit(@1)*(1-invlogit(@1)) ///
			 	-invlogit(@2)*(1-invlogit(@2)) ///
			       	-invlogit(@3)*(1-invlogit(@3))  ) ///
			label("Prob. Type 1") prob ci(logit)
		eret scalar se_pr1 = r(se)
		_diparm logitp2, invlogit level(`level') label("Prob. Type 2") prob ci(logit)
		_diparm logitp3, invlogit level(`level') label("Prob. Type 3") prob ci(logit)
		_diparm logitp4, invlogit level(`level') label("Prob. Type 4") prob ci(logit)
	}
	if `e(nmp)' == 5 {
		_diparm logitp2 logitp3 logitp4 logitp5, level(`level') ///
			func(1-invlogit(@1)-invlogit(@2)-invlogit(@3)-invlogit(@4)) ///
			deriv(  -invlogit(@1)*(1-invlogit(@1)) ///
				-invlogit(@2)*(1-invlogit(@2)) ///
			        -invlogit(@3)*(1-invlogit(@3)) ///
				-invlogit(@4)*(1-invlogit(@4)) ) ///
			label("Prob. Type 1") prob ci(logit)
		eret scalar se_pr1 = r(se)
		_diparm logitp2, invlogit level(`level') label("Prob. Type 2") prob ci(logit)
		_diparm logitp3, invlogit level(`level') label("Prob. Type 3") prob ci(logit)
		_diparm logitp4, invlogit level(`level') label("Prob. Type 4") prob ci(logit)
		_diparm logitp5, invlogit level(`level') label("Prob. Type 5") prob ci(logit)
	}

	di in smcl in gr "{hline 13}{c BT}{hline 64}"
	di in gr "Note: m1 = " as res "0"
	
end



