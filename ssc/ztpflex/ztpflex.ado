*!version 1.0 Helmut Farbmacher

program define ztpflex
	version 9.0
	if replay() {
		if (`"`e(cmd)'"'!= "ztpflex") error 301
		else {
			Replay `0'
		}
	}
	else 	Estimate `0'
end

***********************************************************************

program define Estimate, eclass

	syntax varlist [if] [in], [INTPoints(integer 30) 			///
			IRr								///
			NONadaptive						///
			vce(passthru)					///
			CLuster(varname) 				///
			Robust							///
			NOCONstant						///
			VUONG							///
			STARTing * ]				
	gettoken yvar xvars : varlist

	mlopts mlopts, `options'

	marksample touse

	global R `intpoints'

/* Count obs and check for negative or zero values of `yvar'. */

	summarize `yvar' if `touse', meanonly

	if r(N) == 0  error 2000 
	if r(N) == 1  error 2001 

	if r(min) < 1 {
		di in red "`yvar' must be greater than zero"
		exit 459
	}

/* Check whether `yvar' is integer-valued. */

	capture assert `yvar' == int(`yvar') if `touse'
		if _rc {
			di in blu "note: you are responsible for " /*
			*/ "interpretation of noncount dep. variable"
		}

/* Vuong test: Fitting alternative ztnb-model*/

	if "`vuong'" != "" {
			qui { 
				noi dis as txt _n "Vuong test: Fitting ztnbp"
				tempname ll_ztpnm ll_ztnb lnalpha m p
				tempvar xb_ztnb lnf_ztnb
				ztnbp `yvar' `xvars' if `touse', `noconstant' `mlopts'
				sca `ll_ztnb' = e(ll)
				_predict double `xb_ztnb' if `touse', xb
				
				sca `p'=[P]_b[_cons]				
				sca `lnalpha' = [lnalpha]_b[_cons]
				
				gen double `m' = exp((2-`p')*`xb_ztnb'-`lnalpha')
				gen double `lnf_ztnb'  = lngamma(`m'+`yvar') - lngamma(`yvar'+1) /*
					*/ - lngamma(`m') + `m' * ln(`m'/(`m'+exp(`xb_ztnb'))) /*
					*/ + `yvar' * ln(exp(`xb_ztnb')/(`m'+exp(`xb_ztnb'))) /*
					*/ - ln(1 - (`m'/(`m'+exp(`xb_ztnb')))^(`m')) if `touse'
			}
		}

/* Estimation */
	
	dis as txt _n "Getting starting values from zero-truncated Poisson:"
	ztp `yvar' `xvars' if `touse', `noconstant' nodisplay
	tempname b0
	mat `b0' = (e(b),0,0)

	if "`starting'"!="" {
		mat li `b0'
	}

	dis as txt _n "Fitting zt-Poisson mixture model:"
	
	if "`nonadaptive'"!="" {
		preserve
		qui keep if `touse'

		tempvar lnf_ztpnm f_ztpnm
		qui gen `f_ztpnm' = .
		global f `f_ztpnm'		/*for vuong test*/

		ml model lf ztpflex_ll (`yvar' = `xvars', `noconstant') /lnsigma /lntheta		///
			if `touse', `mlopts' `vce' cluster(`cluster')  			///
			`robust' init(`b0',copy) /*search(off)*/ max difficult

		if "`vuong'" != "" {
			sca `ll_ztpnm' = e(ll)
			qui {
				gen `lnf_ztpnm' = ln(`f_ztpnm')
			/*calculate vuong test statistic - ztpnm is on top*/
				tempname first second omega vuong
				tempvar diff diff2 
				gen `diff' = `lnf_ztpnm' - `lnf_ztnb'
				gen `diff2' = `diff'*`diff'
				sum `diff2', meanonly
				sca `first' =  r(mean)
				sum `diff', meanonly
				sca `second' = (r(mean))^2
				sca `omega' = sqrt(`first'-`second') 
				sca `vuong' = 1/sqrt(_N) * (`ll_ztpnm' - `ll_ztnb') / `omega'
			}
			ereturn scalar vuong=`vuong'
		}

		ereturn local intmethod "non-adaptive"	
	}
	else {
		preserve										
		qui keep if `touse'	

		/* Initialization of adaptive quadrature */
		tempvar ipoisnm_tau2 ipoisnm_tau ipoisnm_mu
		qui gen double `ipoisnm_tau2'=1
		qui gen double `ipoisnm_tau'=sqrt(`ipoisnm_tau2')
		qui gen double `ipoisnm_mu'=0

		qui poisson `yvar' `xvars' if `touse', `noconstant'
		tempname b0adapt
		mat `b0adapt' = (e(b),0)							

		tempvar i we xb logFc
		qui gen `i'=_n
		qui gen `we'=1
		mat score `xb' = `b0'
		qui gen double `logFc' = -exp(`xb')+`yvar'*`xb'-lngamma(`yvar'+1)	

		_GetAdap `yvar' `xvars', i(`i')					///
			shat(`ipoisnm_tau2') hh(`ipoisnm_mu')		///
			b(`b0adapt') poisson logF(`logFc')	

		qui replace `ipoisnm_tau'=sqrt(`ipoisnm_tau2')

		global ml_mu `ipoisnm_mu'
		global ml_tau `ipoisnm_tau'

		tempvar lnf_ztpnm f_ztpnm
		qui gen `f_ztpnm' = .
		global f `f_ztpnm'		/*for vuong test*/
		
		ml model lf ztpflex_ada_ll (`yvar' = `xvars', `noconstant') /lnsigma /lntheta 	///
			 if `touse', `mlopts' `vce' cluster(`cluster') 			///
			`robust' init(`b0',copy) /*search(off)*/ max difficult

		if "`vuong'" != "" {
			sca `ll_ztpnm' = e(ll)
			qui {
				qui gen `lnf_ztpnm' = ln(`f_ztpnm')
			/*calculate vuong test statistic - ztpnm is on top*/
				tempname first second omega vuong
				tempvar diff diff2 
				gen `diff' = `lnf_ztpnm' - `lnf_ztnb'
				gen `diff2' = `diff'*`diff'
				sum `diff2', meanonly
				sca `first' =  r(mean)
				sum `diff', meanonly
				sca `second' = (r(mean))^2
				sca `omega' = sqrt(`first'-`second') 
				sca `vuong' = 1/sqrt(_N) * (`ll_ztpnm' - `ll_ztnb') / `omega'
			}
			ereturn scalar vuong=`vuong'
		}

		ereturn local intmethod "adaptive"
	}

	ereturn scalar sigma = exp([lnsigma]_b[_cons])
	ereturn local title "Zero-truncated Poisson mixture model"
	ereturn local quad "`intpoints'"
	ereturn scalar k_aux = 1	
	ereturn local cmd "ztpflex"
	
	if "`quadcheck'"=="" {
		if "`vuong'" != "" {
			Replay, vuong `irr'
		}
		else Replay, `irr'
	}			
	
	if "`quadcheck'"!="" {
		if "`quadoutput'"!="" {
			if "`vuong'" != "" {
				Replay, vuong `irr'
			}
			else Replay, `irr' 
		}
	}

	if "`quadcheck'"!="" {
		est store qpoints_`intpoints'
		`quadcheck' `0'
	}

	restore

end

***********************************************************************

program define Replay
	syntax, [vuong irr]

	if "`irr'"!="" {
		local eopt "eform(IRR)"
	}

			dis as txt _n "Number of quadrature points: " as res e(quad)
			ml display, `eopt'
			_diparm lnsigma, exp pr label("sigma")
			_diparm lntheta, exp pr label("theta")

			if "`vuong'" != "" {
				dis as txt "**************"
				DispV
			}

end

***********************************************************************

program define DispV
	di in green "Vuong test of ztpnm vs. ztnb: " /* 
		    */ in green "z = "in ye %8.2f e(vuong) /*
		    */ in green "  Pr>z = " /*
		    */ in ye %6.4f normprob(-e(vuong))

end


