*! version 2.1.0 12feb2012
*! author: Partha Deb
* version 2.0.1 15may2009
* version 2.0.0 27aug2008
* version 1.2.1 29jul2008
* version 1.2.0 18jun2008
* version 1.0.0 06mar2007

program fmm, properties(ml_score svyb svyj svyr swml)
version 9.2

if replay() {
  if ("`e(cmd)'" != "fmm") error 301
  Replay `0'
  }
else Estimate `0'
end

program Estimate, eclass

// parse the command
syntax varlist [if] [in]							///
		[fweight pweight iweight]			///
		, COMPonents(string) MIXtureof(string)		///
		[PROBability(string)					///
		Robust CLuster(varname)	noCONStant		///
		OFFset(varname numeric)					///
		EXPosure(varname numeric)				///
		SHift(real 0.05) SEarch(string) FRom(string)	///
		DF(real 5) *]

	mlopts mlopts, `options'
	gettoken lhs rhs : varlist

	if "`search'"=="" local search "off"

	if "`cluster'" != "" {
		local clopt cluster(`cluster')
		}

	if "`weight'" != "" {
		tempvar wvar
		quietly gen double `wvar' `exp'
		local wgt "[`weight'=`wvar']"
		}
	
	if "`offset'" != "" {
		local offopt "offset(`offset')"
	}
	if "`exposure'" != "" {
		local expopt "exposure(`exposure')"
	}

	// mark the estimation sample
	marksample touse
	markout `touse' `wvar' `offset' `exposure'
	markout `touse' `probability'
	markout `touse' `cluster', strok

	global fmm_components = `components'
	global fmm_tdf = `df'

	// check syntax for number of components
	if "`components'"<"2" | "`components'">"9" {
		di in red "number of components, components(#), is a required option"
		di in red "# must be an integer greater than 1 and less than 10"
		exit 198
	}

	// check syntax for the distribution mixtureof
	if  "`mixtureof'"!=""						///
		& "`mixtureof'"!="gamma"			///
		& "`mixtureof'"!="lognormal" 		///
		& "`mixtureof'"!="negbin1"		///
		& "`mixtureof'"!="negbin2"		///
		& "`mixtureof'"!="normal" 		///
		& "`mixtureof'"!="poisson"		///
		& "`mixtureof'"!="studentt"		///
		{
		di in red "invalid syntax: component distribution, mixtureof(), incorrectly specified"
		exit 198
	}

	// test collinearity for component RHS variables
  _rmcoll `rhs' `wgt' if `touse', `constant'
  local rhs `r(varlist)'
  _rmcoll `probability' `wgt' if `touse', `constant'
  local probability `r(varlist)'

	// create density names and equations for ml model
	local fx `"`fx' (component1: `lhs' = `rhs', `constant' `offopt' `expopt')"'
	forvalues i=2/`components' {
		local fx `"`fx' (component`i': = `rhs', `constant' `offopt' `expopt')"'
	}

	if "`mixtureof'"=="gamma" {
		local densityname "Gamma"
		forvalues i=1/`components' {
			local scale `"`scale' /lnalpha`i'"'
		}
	}
	if "`mixtureof'"=="lognormal" {
		local densityname "Lognormal"
		forvalues i=1/`components' {
			local scale `"`scale' /lnsigma`i'"'
		}
	}
	if "`mixtureof'"=="negbin1" {
		local densityname "Negative Binomial-1"
		forvalues i=1/`components' {
			local scale `"`scale' /lndelta`i'"'
		}
	}
	if "`mixtureof'"=="negbin2" {
		local densityname "Negative Binomial-2"
		forvalues i=1/`components' {
			local scale `"`scale' /lnalpha`i'"'
		}
	}
	if "`mixtureof'"=="normal" {
		local densityname "Normal"
		forvalues i=1/`components' {
			local scale `"`scale' /lnsigma`i'"'
		}
	}
	if "`mixtureof'"=="poisson" {
		local densityname "Poisson"
	}
	if "`mixtureof'"=="studentt" {
		local densityname "Student-t"
		forvalues i=1/`components' {
			local scale `"`scale' /lnsigma`i'"'
		}
	}


	// SET UP MODELS WITH CONSTANT PROBABILITY SPECIFICATION
	if "`probability'"=="" {
		forvalues i=1/`=`components'-1' {
			local ilp`i' "/imlogitpi`i'"
			local ilp `" `ilp' `ilp`i'' "'
		}
		local Model `"`fx' `ilp' `scale' "'


		// GENERATE STARTING VALUES
		if "`from'"=="" {

			if "`components'"=="2" {
				tempname lln bn cbn sn bnincr s
				if "`mixtureof'"=="gamma" {
					// fit a glm gamma model
					qui glm `lhs' `rhs' `wgt' if `touse' `in', family(gamma) link(log) ///
						`constant' `offopt' `expopt'
					matrix `bn' = e(b)
					scalar `cbn' = colsof(`bn')
					matrix `sn' = 0
					matrix `s' = `bn', `sn'
					// fit a gamma regression model
					`quietly' display as txt _n "Fitting Gamma regression model:"
					ml model d2 gammareg_lf (`lhs'=`rhs', `constant' `offopt' `expopt' ) ///
						/lndelta `wgt' if `touse' `in' ///
						, `robust' `clopt' `mlopts' collinear missing init(`s', copy) ///
						maximize search(off)
					matrix `bn' = e(b)
					scalar `cbn' = colsof(`bn')
					matrix `sn' = `bn'[1,`cbn']
					matrix `bn' = `bn'[1,1..(`cbn'-1)]
					matrix `bnincr'=`bn'
					matrix `bnincr'[1,`cbn'-1] = `bnincr'[1,`cbn'-1]+`shift'
				}
				if "`mixtureof'"=="lognormal" {
					// fit an ols regression model
					tempvar loglhs
					qui gen `loglhs' = ln(`lhs')
					qui reg `loglhs' `rhs' `wgt' if `touse' `in', `constant'
					matrix `bn' = e(b)
					scalar `cbn' = colsof(`bn')
					matrix `sn' = ln(e(rmse))
					matrix `s' = `bn', `sn'
					// fit a loglinear regression model
					`quietly' display as txt _n "Fitting Logormal regression model:"
					ml model d2 lognormalreg_lf (`lhs'=`rhs', `constant' `offopt' `expopt') ///
						/lnsigma `wgt' if `touse' `in' ///
						, `robust' `clopt' `mlopts' collinear missing init(`s', copy) ///
						maximize search(off)
					matrix `bn' = e(b)
					scalar `cbn' = colsof(`bn')
					matrix `sn' = `bn'[1,`cbn']
					matrix `bn' = `bn'[1,1..(`cbn'-1)]
					matrix `bnincr'=`bn'
					matrix `bnincr'[1,`cbn'-1] = `bnincr'[1,`cbn'-1]*(1+`shift')
				}
				if "`mixtureof'"=="negbin1" {
					// fit a nbreg model
					`quietly' display as txt _n "Fitting Negative Binomial-1 model:"
					nbreg `lhs' `rhs' `wgt' if `touse' `in' , `robust' `clopt' ///
						dispersion(constant) nodisplay `constant' `offopt' `expopt'
					matrix `bn' = e(b)
					scalar `cbn' = colsof(`bn')
					matrix `sn' = `bn'[1,`cbn']
					matrix `bn' = `bn'[1,1..(`cbn'-1)]
					matrix `bnincr'=`bn'
					matrix `bnincr'[1,`cbn'-1] = `bnincr'[1,`cbn'-1]+`shift'
				}
				if "`mixtureof'"=="negbin2" {
					// fit a nbreg model
					`quietly' display as txt _n "Fitting Negative Binomial-2 model:"
					nbreg `lhs' `rhs' `wgt' if `touse' `in' , `robust' `clopt' ///
						dispersion(mean) nodisplay `constant' `offopt' `expopt'
					matrix `bn' = e(b)
					scalar `cbn' = colsof(`bn')
					matrix `sn' = `bn'[1,`cbn']
					matrix `bn' = `bn'[1,1..(`cbn'-1)]
					matrix `bnincr'=`bn'
					matrix `bnincr'[1,`cbn'-1] = `bnincr'[1,`cbn'-1]+`shift'
				}
				if "`mixtureof'"=="normal" {
					// fit an ols regression model
					qui reg `lhs' `rhs' `wgt' if `touse' `in', `constant'
					matrix `bn' = e(b)
					scalar `cbn' = colsof(`bn')
					matrix `sn' = ln(e(rmse))
					matrix `s' = `bn', `sn'
					// fit a linear regression model
					`quietly' display as txt _n "Fitting Normal regression model:"
					ml model d2 normalreg_lf (`lhs'=`rhs', `constant' `offopt' `expopt') ///
						/lnsigma `wgt' if `touse' `in' ///
						, `robust' `clopt' `mlopts' collinear missing init(`s', copy) ///
						maximize search(off)
					matrix `bn' = e(b)
					scalar `cbn' = colsof(`bn')
					matrix `sn' = `bn'[1,`cbn']
					matrix `bn' = `bn'[1,1..(`cbn'-1)]
					matrix `bnincr'=`bn'
					matrix `bnincr'[1,`cbn'-1] = `bnincr'[1,`cbn'-1]*(1+`shift')
				}
				if "`mixtureof'"=="poisson" {
					// fit a Poisson model
					`quietly' display as txt _n "Fitting Poisson model:"
					poisson `lhs' `rhs' `wgt' if `touse' `in' , `robust' `clopt' ///
						nodisplay `constant' `offopt' `expopt'
					matrix `bn' = e(b)
					scalar `cbn'=colsof(`bn')
					matrix `bnincr'=`bn'
					matrix `bnincr'[1,`cbn'] = `bnincr'[1,`cbn']+`shift'
					matrix `s' = `bn', `bnincr', 1
					local contin init(`s', copy) search(`search')
				}
				if "`mixtureof'"=="studentt" {
					// fit an ols regression model
					qui reg `lhs' `rhs' `wgt' if `touse' `in', `constant'
					matrix `bn' = e(b)
					scalar `cbn' = colsof(`bn')
					matrix `sn' = ln(e(rmse))
					matrix `s' = `bn', `sn'
					// fit a Student-t regression model
					`quietly' display as txt _n "Fitting Student-t regression model:"
					ml model d2 studenttreg_lf (`lhs'=`rhs', `constant' `offopt' `expopt') ///
						/lnsigma `wgt' if `touse' `in' ///
						, `robust' `clopt' `mlopts' collinear missing init(`s', copy) ///
						maximize search(off)
					matrix `bn' = e(b)
					scalar `cbn' = colsof(`bn')
					matrix `sn' = `bn'[1,`cbn']
					matrix `bn' = `bn'[1,1..(`cbn'-1)]
					matrix `bnincr'=`bn'
					matrix `bnincr'[1,`cbn'-1] = `bnincr'[1,`cbn'-1]*(1+`shift')
				}

				if "`mixtureof'"=="poisson" {
					matrix `s' = `bn', `bnincr', 1
				}
				else {
					matrix `s' = `bn', `bnincr', 1, `sn', `sn'
				}
				local contin init(`s', copy) search(`search')

			}  

			if "`components'">"2" {
				if "`e(cmd)'"!="fmm" | "`e(components)'"!="`=`components'-1'" ///
				| "`e(mixtureof)'"!="`mixtureof'" | "`e(probability)'"!="" {
					di in red "provide starting values or estimate `=`components'-1' component `mixtureof' model"
					di in red "with constant component probabilities"
					exit 198
				}

				if "`mixtureof'"=="poisson" {
					forvalues i=1/`components' {
						local tnames `" `tnames' b`i' "'
					}
					forvalues i=1/`=`components'-1' {
						local tnames `" `tnames' ipi`i' pi`i' "' 
					}

					tempname b cb cb1cl C incr den s sumpi `tnames' pi`components'
					matrix `b' = e(b)
					scalar `cb' = colsof(`b')
					scalar `cb1cl' = (1/(`components'-1))*(`cb'-`components'+2)
					forvalues i=1/`=`components'-1' {
						matrix `b`i''=`b'[1,((`i'-1)*`cb1cl'+1)..(`i'*`cb1cl')]
					}

					forvalues i=1/`=`components'-2' {
						scalar `ipi`i'' = `b'[1,`cb'-(`components'-2)+`i']
					}
					scalar `den' = 1
					forvalues i=1/`=`components'-2' {
						scalar `den' = `den' + exp(`ipi`i'')
					}
					scalar `sumpi' = 0
					forvalues i=1/`=`components'-2' {
						scalar `pi`i'' = exp(`ipi`i'')/`den'
						scalar `sumpi' = `sumpi' + `pi`i''
					}
					scalar `pi`=`components'-1'' = 1-`sumpi'

					matrix `b`components'' = `b1'
					local C 1
					matrix `incr'=J(1,`cb1cl',0)
					matrix `incr'[1,`cb1cl'] = `shift'
					forvalues i=2/`=`components'-1' {
						if `pi`i'' > `pi`=`i'-1''{
							local C `=`i''
							matrix `b`components'' = `b`i''
						}
					}
					scalar `pi`C'' = (1-`shift')*`pi`C''
					scalar `pi`components'' = `shift'*`pi`C''

					forvalues i=1/`=`components'-1' {
						scalar `ipi`i'' = ln(`pi`i''/`pi`components'')
					}

					forvalues i=1/`=`components'-1' {
						local bnames `" `bnames' `b`i'', "'
						local ipinames `" `ipinames', `ipi`i'' "'
					}
					matrix `s' = `bnames' `b`components''+`incr' `ipinames'
					local contin init(`s', copy) search(`search')
				}

				if "`mixtureof'"!="poisson" {
					forvalues i=1/`components' {
						local tnames `" `tnames' b`i' scale`i' "'
					}
					forvalues i=1/`=`components'-1' {
						local tnames `" `tnames' ipi`i' pi`i' "'
					}

					tempname b cb cb1cl C bcincr den s sumpi `tnames' pi`components'
					matrix `b' = e(b)
					scalar `cb' = colsof(`b')
					scalar `cb1cl' = (1/(`components'-1))*(`cb'-2*`components'+3)
					forvalues i=1/`=`components'-1' {
						matrix `b`i'' = `b'[1,((`i'-1)*`cb1cl'+1)..(`i'*`cb1cl')]
						scalar `scale`i'' = `b'[1,`cb'-`components'+1+`i']
					}
					forvalues i=1/`=`components'-2' {
						scalar `ipi`i'' = `b'[1,`cb'-2*`components'+3+`i']
					}
					scalar `den' = 1
					forvalues i=1/`=`components'-2' {
						scalar `den' = `den' + exp(`ipi`i'')
					}
					scalar `sumpi' = 0
					forvalues i=1/`=`components'-2' {
						scalar `pi`i'' = exp(`ipi`i'')/`den'
						scalar `sumpi' = `sumpi' + `pi`i''
					}
					scalar `pi`=`components'-1'' = 1-`sumpi'

					matrix `b`components'' = `b1'
					matrix `scale`components'' = `scale1'
					local C 1
					forvalues i=2/`=`components'-1' {
						if `pi`i'' > `pi`=`i'-1''{
							local C `=`i''
							matrix `b`components'' = `b`i''
							scalar `scale`components'' = `scale`i''
						}
					}
					matrix `bcincr'=`b`components''
					matrix `bcincr'[1,`cb1cl'] = `bcincr'[1,`cb1cl']*(1+`shift')
					scalar `pi`C'' = (1-`shift')*`pi`C''
					scalar `pi`components'' = `shift'*`pi`C''
					forvalues i=1/`=`components'-1' {
						scalar `ipi`i'' = ln(`pi`i''/`pi`components'')
					}

					forvalues i=1/`=`components'-1' {
						local bnames `" `bnames' `b`i'', "'
						local ipinames `" `ipinames', `ipi`i'' "'
					}
					forvalues i=1/`components' {
						local scalenames `" `scalenames', `scale`i'' "'
					}
					matrix `s' = `bnames' `bcincr' `ipinames' `scalenames'
					local contin init(`s', copy) search(`search')
				}
			}
		}

		// if starting values are provided
		if `"`from'"'!="" {
			local contin init(`from',copy) search(`search')
		}


		// fit the full model
		local title "`components' component `densityname' regression"
		`quietly' display as txt _n "Fitting `components' component `densityname' model:"
/*		ml model d2debug fmm_`mixtureof'_lf `Model' `wgt' if `touse' `in' ///
			, `contin' maximize */
		ml model d2 fmm_`mixtureof'_lf `Model' `wgt' if `touse' `in' ///
			, title(`title') `robust' `clopt' `mlopts' `contin' ///
			collinear missing waldtest(`components') maximize
		ereturn local cmd fmm
		ereturn local components "`components'"
		ereturn local mixtureof "`mixtureof'"
		ereturn local predict "fmm_`mixtureof'_p"
		if "`mixtureof'"=="poisson" {
			ereturn scalar k_aux = `components'-1
		}
		else {
			ereturn scalar k_aux = 2*`components'-1
		}

		Replay
	}

	// SET UP MODELS WITH REGRESSORS IN THE PROBABILITY SPECIFICATION
	if "`probability'"!="" {
		forvalues i=1/`=`components'-1' {
			local ilp `" `ilp' (imlogitpi`i': = `probability')"'
		}
		local Model `"`fx' `ilp' `scale' "'

		if "`from'"=="" {
			if "`e(cmd)'"!="fmm" | "`e(components)'"!="`=`components''" ///
				| "`e(mixtureof)'"!="`mixtureof'" | "`e(probability)'"!="" {
				di in red "provide starting values or estimate `components' component `densityname' model"
				di in red "with constant component probabilities"
				exit 198
			}

			// get starting values from prior LC model
			tempname s
			mat `s'= e(b)
			local contin init(`s') search(`search')
		}

		if `"`from'"'!="" {
			local contin init(`from',copy) search(`search')
		}

		// fit the full model
		local title `title'
		`quietly' display as txt _n "Fitting `components' component `densityname' model:"
		ml model d2 fmm_`mixtureof'_lf `Model' `wgt' if `touse' `in' ///
			, title(`title') `robust' `clopt' `mlopts' `contin' ///
			collinear missing waldtest(`components') maximize

		ereturn local cmd fmm
		ereturn local components "`components'"
		ereturn local mixtureof "`mixtureof'"
		ereturn local probability "`probability'"
		ereturn local predict "fmm_`mixtureof'_p"
		if "`mixtureof'"=="poisson" {
			ereturn scalar k_aux = 0
		}
		else {
			ereturn scalar k_aux = `components'
		}

		Replay
	}

end


program Replay, eclass

	ml display

	local components `e(components)'
	local mixtureof `e(mixtureof)'
	local probability `e(probability)'

	if "`mixtureof'"=="gamma" {
		local scale `"alpha"'
	}
	if "`mixtureof'"=="lognormal" {
		local scale `"sigma"'
	}
	if "`mixtureof'"=="negbin1" {
		local scale "delta"
	}
	if "`mixtureof'"=="negbin2" {
		local scale "alpha"
	}
	if "`mixtureof'"=="normal" {
		local scale `"sigma"'
	}
	if "`mixtureof'"=="studentt" {
		local scale `"sigma"'
	}

	if "`probability'"=="" {

		if `components'==2 {
			if "`mixtureof'"!="poisson" {
				_diparm ln`scale'1, exp label(`scale'1)
				ereturn scalar `scale'1_est = r(est)
				ereturn scalar `scale'1_se = r(se)
				_diparm ln`scale'2, exp label(`scale'2)
				ereturn scalar `scale'2_est = r(est)
				ereturn scalar `scale'2_se = r(se)
			}
			_diparm imlogitpi1, invlogit label(pi1)
			ereturn scalar pi1_est = r(est)
			ereturn scalar pi1_se = r(se)
			local prob2 diparm(imlogitpi1, func(1-exp(@)/(1+exp(@))) ///
							der(-exp(@)/((1+exp(@))^2)) label(pi2))
			_diparm imlogitpi1, func(1-exp(@)/(1+exp(@))) ///
							der(-exp(@)/((1+exp(@))^2)) label(pi2)
			ereturn scalar pi2_est = r(est)
			ereturn scalar pi2_se = r(se)
		}

		if `components'>=3 {
			if "`mixtureof'"!="poisson" {
				forvalues j=1/`components' {
					_diparm ln`scale'`j', exp label(`scale'`j')
					ereturn scalar `scale'`j'_est = r(est)
					ereturn scalar `scale'`j'_se = r(se)

				}
			}
			local den "1"
			forvalues i=1/`=`components'-1' {
				local den `"`den'+exp(@`i')"'
				local invml `"`invml' imlogitpi`i'"'
			}
			forvalues i=1/`=`components'-1' {
				local prob`i' `"_diparm `invml', func(exp(@`i')/(`den')) der("'
				forvalues j=1/`=`components'-1' {
					if `i'==`j' {
						local prod `"`den'-exp(@`i')"'
						local der`i'`j' `"+0+exp(@`i')*(`prod')/((`den')^2)"'
					}
					else {
						local der`i'`j' `"-exp(@`i')*exp(@`j')/((`den')^2)"'
					}
					local prob`i' `"`prob`i'' `der`i'`j''"'
				}
				local prob`i' `" `prob`i'' ) label(pi`i') ci(logit) "'
				`prob`i''
				ereturn scalar pi`i'_est = r(est)
				ereturn scalar pi`i'_se = r(se)

			}
			forvalues j=1/`=`components'-1' {
				forvalues i=1/`=`components'-1' {
					local sumder`j' `"`sumder`j''`der`i'`j''"'
				}
				local derivs `"`derivs'`sumder`j'' "'
			}
			_diparm `invml', func(1-(`den'-1)/(`den')) ///
				der(`derivs') label(pi`components')
			ereturn scalar pi`components'_est = r(est)
			ereturn scalar pi`components'_se = r(se)
		}
		_diparm __bot__
	}

	if "`probability'"!="" {
		if "`mixtureof'"!="poisson" {
			forvalues j=1/`components' {
				_diparm ln`scale'`j', exp label(`scale'`j')
				ereturn scalar `scale'`j'_est = r(est)
				ereturn scalar `scale'`j'_se = r(se)
			}
			_diparm __bot__
		}
	}

end
