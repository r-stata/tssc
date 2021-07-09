*! version 1.2.5 30jun2019 MJC

/*
History
30jun2019: version 1.2.5 - minor help file edits
						 - bug fix in predictions; cif with timevar and competing risks model caused an error when survival time was included in predictor
05jun2019: version 1.2.4 - some tidying
28may2019: version 1.2.3 - iterate() added to adaptopts(), help file for estimation updated 
24may2019: version 1.2.2 - exptorcs ado added which turns expected rates into a spline based merlin model, for Weibull et al. (Submitted)
						 - bug fix - "timevar() required" error message appeared when rcs(), fp() or bs() was specified, even when it wasn't required; now fixed
25mar2019: version 1.2.1 - bug fix; predict from a model with multiple outcomes and model specific ifs/ins errored out - now fixed
						 - bug fix; overall weights could've been specified but would have been ignored - now not allowed
18mar2019: version 1.2.0 - bug; poisson logl functions missed from build - now fixed
						 - weights() added to allow sampling weights
						 - at1() and at2() added to predict for difference predictions - h,s,cif,rmst,mu,eta difference options added
						 - bug; survival model using log time + interval censoring + left interval contained a 0, would error - now fixed
27feb2019: version 1.1.0 - bug fix; predict with ci and outcome() was ignored so defaulted to outcome(1) - now fixed
						 - doc fix for knots() with rp - does include boundary knots
						 - bug fix for starting values with gompertz which prevented fitting; now fixed
						 - family(logchazard) added for general models on the log cumulative hazard scale
						 - family(rcs) replaced with more general family(loghazard) for log hazard scale models
						 - interval censoring added -> linterval() option added to survival familys, only allowed in one model
						 - model-specific ifs or ins now allowed
07aug2018: version 1.0.7 - added error check for presence of * in predictor
						 - bug introduced in 1.0.6 stopped matching of timevar() with rcs() variable; now fixed
						 - error check on . caused merlin to error out when specifying decimal points in knots(); now fixed
27jul2018: version 1.0.6 - random now documented
						 - chazard and survival predictions missing for family(exp); now added
						 - note added to end of results table that baseline splines not shown
						 - when specifying only a random slope with no random intercept - an internal parsing error occurred; now fixed.
16may2018: version 1.0.5 - ltruncated() added for delayed-entry/left-truncation in survival models
06may2018: version 1.0.4 - bs() element added for B-spline functions
						 - minor edit to step size in numerical differentiation used in d?[] elements
						 - mf() displayed function name left over from development; now removed
						 - more error checks added
						 - bug fixes
30apr2018: version 1.0.3 - bug fix; at() was ignored in predict when ci was specified - now fixed
						 - predict, failure removed, cif is used instead
						 - predict, cif calculation improved for family(rp)
						 - predict, cif and rmst can be used with competing risks
						 - predict, ... causes() added for use with cif and rmst. If left unspecified, all survival 
						   models assumed to be cause-specific models which can be overriden by causes().
						 - predict, timelost added which is the integral of the cause-specific cif
						 - predict, totaltimelost added which is the integral of the sum of all cause-specific cifs
						 - numerical differentiation used internally improved, thanks to Mark Clements
						 - mjcerror left from megenreg
						 - documentation for adaptopts() had unavailable options - now removed
25apr2018: version 1.0.2 - predict, cif added for cumulative incidence function for competing risks models
						 - bug fix in predict, if neither fixedonly or marginal were specified, no prediction was produced
24apr2018: version 1.0.1 - predict, failure added
						 - predict, rmft added
						 - postestimation doc was incomplete for some statistics
23apr2018: version 1.0.0 - merlin released to SSC
						 - megenreg -> merlin
						 - bug fix with if statements - merlin_modeltouses_post_xb() creating tousei was giving missings not 0s. Now fixed.
						 - offset() added to fp() and rcs()
						 - error check added for . notation or ## in CLP
						 - handling of elements re-written -> @ only for constraints
						 - predict function added - fixedonly and margina allowed
						 - results help file
						 - EV now expected value of response, added XB for expected value of linear predictor
						 - random effects must be M#[]
						 - documented all utility functions
						 - results table greatly improved
						 - interactions between fp() and rcs() etc now allowed
16dec2017: version 0.1.8 - family(gamma) added
						 - bug fix in inverse links for EV functions
20nov2017: version 0.1.7 - bug fix in not documented links when using family(user)
						 - mf() element added = user-defined mata function
						 - family(rcs) added
						 - startval for @s changed from 0 to 0.0001
						 - ereturn list additions
27oct2017: version 0.1.6 - fixed output of bernoulli model, labelled equation cloglog when it should be logit (was still using logit)
						 - random effects in results table now transformed to sds and corrs, display much improved
						 - replay fixed
23oct2017: version 0.1.5 - added family(lquantile [, quantile(#)]) for linear quantile regression
						 - stable added to sort operations
20oct2017: version 0.1.4 - default cumulative hazard integration changed to 15-point Gauss-Kronrod
						 - loghfunction() added to family(user)
						 - improved error checks
19oct2017: version 0.1.3 - starting value for @ parameters changed to 0.1 in prev. release; put back to 0s
						 - minor improvements to the mlib
15oct2017: version 0.1.2 - constraints() fixed, family(null) now working with ob. level models
12oct2017: version 0.1.1 - restartvalues() added
08oct2017: version 0.1.0 - dev. release
*/

program merlin, eclass 
        version 14.2

        if replay() {
			if "`e(cmd)'" != "merlin" {
				error 301
			}
			Display `0'
			exit
        }
		
		tempname GML
        capture noisily Estimate `GML' `0'
        local rc = c(rc)
		if "`c(prefix)'"!="morgana" {
			capture mata: rmexternal("`GML'")
			capture drop `GML'*
		}
		else ereturn local object "`GML'"
		
        if (`rc') exit `rc'
        ereturn local cmdline `"merlin `0'"'
end

program Estimate, eclass
        version 14.2
        gettoken GML : 0

        `vv' `BY' Fit `0'		//!! should leave behind diopts

		mata: merlin_ereturn("`GML'")
		
        if "`c(prefix)'"!="morgana" {
			Display, `diopts'
		}
end

program Fit, eclass sortpreserve
        version 14.2
        gettoken GML 0 : 0

        tempname touse b
        merlin_parse `GML', touse(`touse') : `0'
		if "`r(predict)'"!="" | "`c(prefix)'"=="morgana" {
			exit
		}
        local mltype    `"`r(mltype)'"'
        local mleval    `"`r(mleval)'"'
        local mlspec    `"`r(mlspec)'"'
        local mlopts    `"`r(mlopts)'"'
        local mlvce     `"`r(mlvce)'"'
        local mlwgt     `"`r(mlwgt)'"'
		local mlcns		`"`r(constr)'"'
		local mlinitcns	`"`r(initconstr)'"'
        local nolog     `"`r(nolog)'"'
        local mlprolog  `"`r(mlprolog)'"'
		local mftodrop  `r(mftodrop)'
        c_local diopts  `"`r(diopts)'"'
		local mlfrom  `"`r(mlfrom)'"'
		local mlzeros	`"`r(mlzeros)'"'
		if "`mlcns'" != "" {
			local cnsopt constraint(`mlcns')
        }
		
        if "`mlfrom'"!="" {
			matrix `b' = r(b)
			local mlinit init(`b',copy)
		}
		
		di
		di as txt "Fitting full model:"

		cap n ml model `mltype' `mleval'              			///
								`mlspec'                        ///
								`mlwgt'                         ///
								if `touse',                     ///
								`mlopts'                        ///
								`mlvce'                         ///
								`mlprolog'                      ///
								`cnsopt'                        ///
								`mlinit'						///
								collinear                       ///
								maximize     	                ///
								missing    		                ///
								nopreserve   	                ///
								search(off)                     ///
								userinfo(`GML')	                ///
								wald(0)   	                    
														 
			if _rc>0 {
				if _rc==1400 & "`mlzeros'"=="" {
				
				di ""
				di as text "-> Starting values failed - trying zero vector"
			
				ml model `mltype' 	`mleval'              			///
									`mlspec'                        ///
									`mlwgt'                         ///
									if `touse',                     ///
									`mlopts'                        ///
									`mlvce'                         ///
									`mlprolog'                      ///
									`cnsopt'                        ///
									collinear                       ///
									maximize     	                ///
									missing    		                ///
									nopreserve   	                ///
									search(off)                     ///
									userinfo(`GML')	                ///
									wald(0)   	                    
				}
				else {
					exit _rc
				}
			}
		
        ereturn local predict   merlin_p
		ereturn local cmd merlin
		cap mata: mata drop `mftodrop'
end

program Display
        syntax [,       noHeader        ///
                        noDVHeader      ///
                        noLegend        ///
                        notable         ///
                        *               ///
        ]

        _get_diopts diopts, `options'
        if e(estimates) == 0 {
                local coefl coeflegend selegend
                local coefl : list diopts & coefl
                if `"`coefl'"' == "" {
                        local diopts `diopts' coeflegend
                }
        }
		
		local Nrelevels = `e(Nlevels)'-1
		
		local plus
		if "`e(Nres1)'"!="" {
			local plus plus
			local neq = `e(k_eq)'
			forval l=1/`Nrelevels' {
				local neq = `neq' - `e(Nreparams`l')'
			}
			local neq neq(`neq')
		}

		_coef_table_header
		_coef_table, neq(0) plus nocnsreport
		
		local spflag = 0
		
		forval mod=1/`e(Nmodels)' {
		
			local y : word 1 of `e(response`mod')'
			if "`y'"=="" {
				local y null
			}
			_diparm __lab__, label("`y':") eqlabel
			
			local Ncmps : word count `e(Nvars_`mod')'
			
			forval c = 1/`Ncmps' {
			
				local clab : word `c' of `e(cmplabels`mod')'
				local np : word `c' of `e(Nvars_`mod')'
				if `np'>1 {
					forval el=1/`np' {
						_diparm _cmp_`mod'_`c'_`el', label("`clab':`el'")
					}
				}
				else {
					_diparm _cmp_`mod'_`c'_1, label("`clab'")
				}
				
			}
			
			if `e(constant`mod')' {
				_diparm cons`mod', label("_cons")
			}
		
			if `e(ndistap`mod')'>0 & "`e(family`mod')'"!="rp" & "`e(family`mod')'"!="aft" {
				
				if "`e(family`mod')'"=="weibull" {
					_diparm dap`mod'_1, label("log(gamma)") 
				}
				else if "`e(family`mod')'"=="gompertz" {
					_diparm dap`mod'_1, label("gamma") 
				}
				else if "`e(family`mod')'"=="beta" {
					_diparm dap`mod'_1, label("log(s)") 
				}
				else if "`e(family`mod')'"=="negbinomial" {
					_diparm dap`mod'_1, label("log(alpha)") 
				}
				else if "`e(family`mod')'"=="gamma" {
					_diparm dap`mod'_1, label("log(s)") 
				}
				
				else if "`e(family`mod')'"=="gaussian" | "`e(family`mod')'"=="lquantile" {
					_diparm dap`mod'_1, label("sd(resid.)") exp
				}
				else if "`e(family`mod')'"=="ordinal" {
					forval a=1/`e(ndistap`mod')' {
						_diparm dap`mod'_`a', label("cut`a'")
					}
				}
				else {
					forval a=1/`e(ndistap`mod')' {
						_diparm dap`mod'_`a', label("dap:`a'")
					}
				}
			}

			if "`e(family`mod')'"=="rp" | "`e(family`mod')'"=="aft" {
				local spflag = 1
			}
		
			if `e(nap`mod')'>0 {
				forval a=1/`e(nap`mod')' {
					_diparm ap`mod'_`a', label("ap:`a'")
				}
			}
		
			if `mod'==`e(Nmodels)' & `e(Nlevels)'==1 {
				_diparm __bot__	
			}
			else {
				_diparm __sep__	
			}

		}		
		
		//VCV display
		if "`e(Nres1)'"!="" {
			
			forval i=1/`Nrelevels' {
				local lev : word `i' of `e(levelvars)'
				_diparm __lab__ , label("`lev':") eqlabel
				
				forval j=1/`e(Nreparams`i')' {
					local param : word `j' of `e(re_eqns`i')'
					local scale : word `j' of `e(re_ivscale`i')'
					local label : word `j' of `e(re_label`i')'
					_diparm `param', `scale' label(`label')
				}
				if `i'<`Nrelevels' {
					_diparm __sep__
				}
			}
			
			_diparm __bot__
		}
		
		if "`e(penalty)'"!="" {
			di as text " Estimation: Maximum Penalised Likelihood"
			di as text "    Penalty: `e(penalty)' with lambda = `e(lambda)'"
		}
		if `spflag' {
			di as text "    Warning: Baseline spline coefficients not shown - use ml display"
		}
		
end

exit
