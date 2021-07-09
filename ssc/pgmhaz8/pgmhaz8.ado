*! version 2.1.1 Stephen P. Jenkins, September 2004
*! Prentice-Gloeckler-Meyer hazard model with Gamma unobserved heterogeneity
*! Syntax: pgmhaz8 <varlist> [if <exp>] [in <range>], id(idvar)
*!      dead(deadvar) seq(seqvar) lnvar0(#) [trace eform level(#) nolog nocons]


/*------------------------------------------------ playback request */
program define pgmhaz8, eclass byable(onecall) sortpreserve
	version 8.2
	if replay() {
		if "`e(cmd)'" != "pgmhaz8" {
			noi di as error "results for pgmhaz8 not found"
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
		LNVar0(real -1) NOCONS  noBeta0				///
		Level(integer $S_level) EForm   			///
		noLOG  * ]


	local title "PGM hazard model with gamma frailty"

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
			di  "see -pgmhaz8- help file"
			exit 198
		}

		capture assert `dead'==1 | `dead'==0
		if _rc~=0 {
			di as error "Per-interval censoring indicator variable must "
			di as error "equal one or zero: see -pgmhaz8- help file"
			exit 198	
		}

		if "`seq'" == "" {
			di as error "Integer-valued variable identifying "
			di as error "spell time interval be specified " _c
			di as error "in seq(seqvar) "
			exit 198
		}


		tempvar mysamp 
		tempname b b0 b1 b2 lnf V lnvar

		set more off

 		_rmcoll `varlist' `wgt' if `touse', `nocons'
		local varlist `r(varlist)'

			/* get estimates of no-het model */
		
		if "`beta0'" == "" {
			di as txt "PGM hazard model without gamma frailty" 
		}
		`log2' glm `dead' `varlist'  `wgt' if `touse', f(b) l(c) ///
			`level' `eform'  `nocons' nolog

	quietly {
		local LL1 = e(ll)

		matrix `b0' = e(b)
		matrix coleq `b0' = hazard

			// now pack out -b0- with starting
			//  value for lnvarg
			//  lnvarg is  set equal to minus one by default
                        //   i.e. varg = exp(lnvarg) = exp(-1) ~= .37 
			

		matrix `lnvar' = (`lnvar0')
		matrix colnames `lnvar' = ln_varg:_cons
		matrix `b1' = `b0',`lnvar'
			/* estimate full model */
		
		sort `id' `touse'  `seq'

		global S_E_id "`id'"
		global S_E_dd "`dead'"
		
		`log' ml model d0 pgmhaz8_ll (hazard: `dead' = `varlist', `nocons')  (ln_varg: ) ///
			`wgt' if `touse', maximize init(`b1') waldtest(0) search(off)		 ///
			collinear title(`title') `level' `mlopts' `stdopts' `modopts'

		tempname tag
		egen `tag' = tag(`id') if e(sample) 
		count if `tag' & e(sample)
		eret scalar N_spell = r(N) 

		eret local cmd "pgmhaz8"
		eret local depvar "`dead'"
		eret local idvar "`id'"
		eret local seqvar "`seq'"

		eret scalar ll_nofr = `LL1'


                // v = exp(lnvarg); s.e.(v) = v * s.e.(lnvarg) 
	        eret scalar gammav = exp( [ln_varg]_cons )
	        eret scalar se_gammav = `e(gammav)' * [ln_varg]_se[_cons] 

		eret scalar lltest = -2 * (`e(ll_nofr)' - `e(ll)' )
		eret scalar lltest_p = .5*chiprob(1,`e(lltest)')


	}

	Display, `level' `eform'

end

program define Display 

	syntax [,Level(int $S_level) EForm *]
	local diopts "`options'"
	ml display, level(`level') `eform' plus
	if `level' < 10 | `level' > 99 {
		local level = 95
		}
	_diparm ln_varg, exp level(`level') label("Gamma var.") prob
	di in smcl in gr "{hline 13}{c BT}{hline 64}"

	
	di as text "LR test of Gamma var. = 0: {help j_chibar:chibar2(01) = } " as res %8.6g `e(lltest)' _c
	di as text "  Prob.>=chibar2 = " as res  %8.6g  `e(lltest_p)'

end



