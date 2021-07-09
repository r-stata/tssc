*! mtefe 20190513
* Author: Martin Eckhoff Andresen
* This program is part of the mtefe package.

cap program drop mtefe myivparse IsStop
{
	program define mtefe, eclass sortpreserve
		version 13.0
		syntax anything [if] [in] [fweight pweight], [ /*
		*/REStricted(varlist fv) 	/*	Control variables restricted to be the same in treated and untreated state
		*/POLynomial(integer 0) 	/* 	Specify degree of polynomial (semiparametric model 2)
		*/SPLines(numlist sort)		/*  Add splines for second-order and higher polynomial models with knots at numlist
		*/DEGree(string) 			/* 	Specify degree of local polynomial smooth (semiparametric model), overruled by polynomial option in semiparametric polynomial model
		*/YBWidth(real 0.2) 		/* 	Specify bandwidth of local polynomial smooth
		*/XBWidth(real 0) 			/*	Specify bandwidth of local polynomial smooth for use when residualizing the X. Used for semiparametric models. Default: lpoly's rule of thumb.
		*/SEMIparametric 			/*	Calculates semiparametric MTEs rather than parametric. Do not combine with fully semiparametric model.
		*/SEParate 					/*	Uses the separate approach to compute potential outcomes and the MTEs.
		*/MLIKelihood				/*	Uses maximum likelihood estimation - only appropriate for the joint normal model
		*/GRIDpoints(integer 0) 	/*	Use only with the fully semiparametric model. Runs the local polynomial regressions of X and XP on p at a specified grid of "grid" number of points rather than using the full and precise distribution of propensity scores.
		*/kernel(string) 			/*	Specifies the kernel used for semiparametric models.
		*/Link(string) 				/*	Choose link function probit, logit or lpm - default probit
		*/TRIMsupport(real 0) 		/*	Trims trim% of the sample from each of the treated and nontreated populations from the points with least support
		*/FULLsupport				/*	Estimate the MTE over the full unit interval even in semiparametric models - default is to only estimate it at points of common support in treated and untreated samples.
		*/firststageoptions(string) /*	Options accepted by regress, probit or logit, depending on first stage model. Use e.g. iterate(#) to control max number of iterations.
		*/NOPlot 					/*	Suppresses the display of common support and mte plots
		*/First 					/*	Display first stage results
		*/Second					/*	Display output of second stage estimating equation.
		*/vce(string)  				/* 	Vce options robust or cluster clustvar
		*/level(cilevel) 			/* 	Confidence level
		*/SAVEFirst(string) 		/* 	If specified, stores AND saves the results from the first stage as "string". Suboption "margins" saves average marginal effects rather than coefficients
		*/SAVEPropensity(string) 	/* 	If specified, saves the estimated propensity score in variable named "string"
		*/BOOTreps(integer 0) 		/* 	Bootstrap repetitions
		*/norepeat1 				/*	Turns off reestimation the propensity score, mean of X and weights for each bootstrap repetition
		*/saveweights(string) 		/*	Saves TT, TUT and LATE weights for X in variable with prefix string
		*/prte(varname) 			/*	Computes policy-relevant treatment effects for a policy that induces a shift in propensity score from the baseline to the p indicated in varname
		*/savekp 					/*	Saves the variables in K(p) with predetermined names (mills, mills0, p1, p2, p3, spline1_2, spline_1_3, spline2_2 etc) for use with predict
		*/bsopts(string)			/*  Other bootstrap options, see bootstrap
		*/norescale					/*	Does NOT rescale the weights of the treatment effect parameters to sum to 1 in situations with limited support
		*/]

		marksample touse
		qui {

			**************************
			* Control illegal inputs *
			**************************					
			if `bootreps'>0&"`weight'`exp'"!="" {
				noi di in red "Weights not supported with bootstrap."
				exit
			}

			if `polynomial'<0 {
				noi di in red "Polynomial must be nonnegative - 0 for normal or semiparametric."
				exit 
			}

			if `trimsupport'!=0 {
				if !inrange(`trimsupport',0,100) {
					noi di in red "Trimsupport must be a number between 0 and 100. "
					exit 
				}
			}
			if "`splines'"!=""&`polynomial'<2 {
				noi di in red "Splines option can only be specified when using the parametric or semiparametric polynomial model with degree >1."
				exit 
			}

			if "`splines'"!="" {
				local numknots: word count `splines'
				tokenize `splines'
				forvalues i=1/`numknots' {
					if !inrange(``i'',0,1) {
						display in red "Do not specify knots in splines option outside (0,1)."
						exit
					}
				}
			}
			else loc numknots=0

			if !inrange(`trimsupport',0,1) {
				noi di in red "Option trimsupport() takes values from 0 to 1, for example 0.01 to trim"
				noi di in red "off 1% of the tails of the treated and untreated sample."
				exit
				}
			foreach letter in x y {
				if !inrange(``letter'bwidth',0,1) {
					display in red "Error in `letter'bwidth option, must be between 0 and 1."
					exit
				}
			}

			if `xbwidth'==0 loc xbwidth

			if "`vce'"!="" {
				loc numvce: word count `vce'
				if `numvce'>2 {
					display in red "Error in vce() - specify only robust or cluster varname."
					exit
				}
				if `numvce'==2 {
					gettoken one two: vce
					capture confirm numeric variable `two'
					if "`one'"!="cluster"|_rc {
						display in red "Error in vce() - specify only robust or cluster varname."
						exit
					}
					else loc clustvar `two'
				}
				if `numvce'==1 {
					if "`vce'"!="robust" {
						display in red "Error in vce() - specify only robust or cluster varname."
						exit
					}
					if `bootreps'!=0 {
						display in red "Error in vce() - do not use robust standard errors with bootstrap."
						exit
					}
				}
			}

			if "`mlikelihood'"!="" {
				if  "`separate'"!="" {
					display in red "Do not specify both separate and mlikelihood."
					exit
				}
				if "`semiparametric'"!=""|`polynomial'>0 {
					display in red "Maximum likelihood estimation is only appropriate for the joint normal model."
					exit
				}
			}

			if `bootreps'<0 {
				display in red `"Bootstrap replications must be nonnegative."'
				exit
			}
			if "`savepropensity'"!="" {
				confirm new var `savepropensity'
			}

			if `gridpoints'!=0&`polynomial'!=0&"`semiparametric'"!="" {
				display in red `"Option "gridpoints" only for use with the full semiparametric model."'
				exit
			}		

			if "`kernel'"!=""&!inlist("`kernel'","epanechnikov","biweight","cosine","gaussian","parzen","rectangle","triangle") {
				display in red `"`kernel' is not a recognized kernel. Options are epanechnikov, biweight, cosine, gaussian, parzen, rectangle, and triangle."'
				exit
			}		

			if "`degree'"!="" {
				cap confirm integer number `degree'
				if _rc!=0 {
					display in red "Only positive integers accepted in option degree()."
					exit
				}
				if `polynomial'>0&"`semiparametric'"!=""&`degree'!=`=`polynomial'+1' {
					loc degree=`polynomial'
					noi di as text "Note: Degree of semiparametric smooth should not be different than"
					noi di as text "L+1 in the semiparametric polynomial moodel, where L is the degree"
					noi di as text "of the polynomial. Degree reset to `=`polynomial'+1'."
				}
			}

			else if "`semiparametric'"!="" {
				if `polynomial'>0 loc degree=`polynomial'+1
				else loc degree=2	
			}
			
			*******************
			* Parse arguments *
			*******************				

			myivparse `anything' if `touse'
			local y `s(lhs)'
			local d `s(endog)'
			local x `s(exog)'
			local z `s(inst)'

			if "`exp'"!=""	loc weightwar `=substr("`exp'",2,.)'
			if "`exp'"==""&"`vce'"==""&"`firststageoptions'"=="" {
				loc regress _regress
				loc vcefirst
				}
			else {
				loc regress regress
				loc vcefirst vce(`vce')
				}
			
			markout `touse' `y' `x' `d' `z' `clustvar' `weightvar'

			_fv_check_depvar `d'
			tab `d' if `touse'
			if `r(r)'!=2 {
				noi di in red "Only binary treatment variables allowed."
				exit 
			}

			//Further controls of input
			if "`link'"=="" loc link probit
				else if "`link'"=="lpm" loc link `regress'
				else if !inlist("`link'","logit","probit"/*,"sml"*/) {
				display in red "Link function can be only logit, probit/*, sml*/ or lpm."
				exit
			}

			
			if `polynomial'==0&"`semiparametric'"==""&"`link'"!="probit"{
				display in red `"When fitting the parametric normal model, use probit to fit the first stage - specify link(probit)."'
				exit
			}

			if "`semiparametric'"!=""&"`restricted'"==""&"`x'"==""&`polynomial'>0 {
				noi di as text "Note: With no covariates or variables in restricted(), the semiparametric polynomial model"
				noi di as text "is equivalent to the semiparametric model. Proceeding with the semiparametric model."
				loc polynomial=0
			}
			
			if "`restricted'"!="" {
				fvexpand `x' if `touse'
				loc xnames `r(varlist)'
				fvexpand `restricted' if `touse'
				loc restrictednames `r(varlist)'
				local newrestricted: list restrictednames - xnames
				if "`newrestricted'"!="`restrictednames'" {
					local probnames: list restrictednames & xnames
					noi di in red "Restricted variables `probnames' included also in main varlist. Do not include the"
					noi di in red "same control variable in restricted() option as in the main variable list."
					exit 
					}
				}
				
			if "`prte'"!="" {
				loc prtevar `prte'
				loc doprte prte
			}

			****************************************************
			* Estimate first stage and evaluate common support *
			****************************************************

			//margins suboption in savefirst
			if "`savefirst'"!="" {
				gettoken savefirst options: savefirst, parse(",")
				if "`options'"!="" {
					gettoken opt1 margins: options, parse(",")
					local numopts: word count `margins'
					if `numopts'>1|"`margins'"!=" margins" {
						noi di in red "Only option allowed in savefirst is margins."
						exit
					}
				}
			}

			if "`first'"!=""&"`margins'"!=" margins"&`trimsupport'==0 loc noi noi
			
			`noi' `link' `d' `z' `x' `restricted' [`weight'`exp'] if `touse', `vcefirst' `firststageoptions'
			tempname p gammaZ
			if `trimsupport'==0 predict double `gammaZ' if e(sample), xb
			predict double `p' if e(sample)
			count if `touse'&!e(sample)
			loc trimobs=0
			if r(N)>0 {
				loc trimobs=`r(N)'
				noi di as text "The following number of observations have been trimmed from the sample:"
				noi di as text "- `r(N)' obs. because observables predict treatment or non-treatment perfectly"
			}
			markout `touse' `p'
			if "`savefirst'"!=""&`trimsupport'==0 {
				if "`margins'"==" margins" {
					if "`first'"!="" loc noi noi
					`noi' margins, dydx(*) post
				}
				test `z'
				estadd scalar p_instruments=r(p)
				est save "`savefirst'", replace
			}
			replace `p'=1 if `p'>1&`touse'
			replace `p'=0 if `p'<0&`touse'

			//Calculate common support & trim
			tempname support support1 support0 h0 h1
			
			if `trimsupport'>0|"`semiparametric'"!="" {
				if `trimsupport'>0 {
					_pctile `p' [`weight'`exp'] if `touse'&`d'==0, percentiles(`=100*(1-`trimsupport')')
					loc max=`r(r1)'
					forvalues i=1/`=floor(100*`max')' {
						mat `support0'=[nullmat(`support0') \ `=round(`i'/100,0.01)']
						}
					_pctile `p' [`weight'`exp'] if `touse'&`d'==1, percentiles(`=100*`trimsupport'')
					loc min=`r(r1)'
					forvalues i=`=ceil(100*`min')'/99 {
						mat `support1'=[nullmat(`support1') \ `=round(`i'/100,0.01)']
						}
					}
				else if "`fullsupport'"=="" {
					forvalues i=0/1 {
						su `p' if `touse'&`d'==1
						forvalues s=`=ceil(100*`r(min)')'/`=floor(100*`r(max)')' {
							mat `support`i''=[nullmat(`support`i'') \ `=round(`s'/100,0.01)']
							}
						}
					}
				else {
						forvalues i=1/99 {
						matrix `support1' =[nullmat(`support1') \ `=round(`i'/100,0.01)']
						}
					mat `support0'=`support1'
					}
				if "`semiparametric'"!=""&"`fullsupport'"!="" {
					tempname cat h1 h0 tempsup1 tempsup

					egen `cat'=cut(`p'), at(-0.005(0.01)1.005) icodes
					forvalues i=0/1 {
						if `trimsupport'>0&`d'==1 loc check &`p'>=`min'
						if `trimsupport'>0&`d'==0 loc check &`p'<=`max'
						levelsof `cat' if `d'==`i'&`touse'&`check', local(vals)
						forvalues s=1/`=rowsof(`support`i'')' {
							if inlist(`s',`=subinstr("`vals'"," ",",",.)') mat `tempsup`i''=[nullmat(`tempsup`i'') \ `support`i''[`s',1] ]
							}					
						}
					}
				
				forvalues u0=1/`=rowsof(`support0')' {
							forvalues u1=1/`=rowsof(`support1')' {
								if `support0'[`u0',1]==`support1'[`u1',1] mat `support'=[nullmat(`support') \ `support0'[`u0',1] ]
						}
					}			
				}
				
			else {
				forvalues i=1/99 {
					matrix `support' =[nullmat(`support') \ `=round(`i'/100,0.01)']
				}
				matrix `support1' = `support'
				matrix `support0' = `support'
			}

			cap confirm matrix `support'
			if _rc!=0 {
				noi di in red "You generated no points of support in P(Z) to be evaluated, probably because"
				noi di in red "you specified a large value for trimsupport() which requires a lot of observations"
				noi di in red "for both treated and untreated samples for a particular value of P(Z) in order to"
				noi di in red "estimate the MTE. Try a smaller value of trimsupport(), for example 0.01 to trim 1%."
				noi di in red "of each sample."
				exit
			}



			//Draw common support plot
			if "`noplot'"!="" loc nodraw nodraw
			if `trimsupport'>0 {
				loc xlinemin xline(`min', lcolor(maroon) lpattern(dash)) 
				loc xlinemax xline(`max', lcolor(maroon) lpattern(dash))
				tempname trimlim
				mat `trimlim'=[`min',`max']
			}
			twoway	(histogram `p' if `d', width(0.01) fcolor(eltblue) lcolor(eltblue)  start(0)) ///
				(histogram `p' if !`d', width(0.01) fcolor(none) lcolor(black) start(0)) ///
				, xtitle("Propensity score") `xlinemin' `xlinemax' title("Common support") legend(label(1 "Treated") label(2 "Untreated")) ///
				`nodraw' `saving' scheme(s2mono) graphregion(color(white)) plotregion(lcolor(black)) name(CommonSupport, replace)


			//Set sample to drop observations outside common suport
			tempvar touse2 roundp
			if `trimsupport'>0 {
				mark `touse2' if (`p'<`max'&`d'==0)|(`p'>`min'&`d'==1)&`touse'
				count if `touse'
				loc N_full=r(N)
				count if `touse2'
				loc N_trim=r(N)
			}
			else gen `touse2'=`touse'
			if "`weight'"=="fweight" {
				su `=subinstr("`exp'","=","",1)' if `touse2'
				loc N=r(sum)
			}
			else {
				count if `touse2'
				loc N=r(N)
			}

			if `trimsupport'>0 {
				loc trimmedobs=`N_full'-`N_trim'
				if `trimmedobs'>0 {
					if `trimobs'==0  noi di as text "The following number of observations have been trimmed from the sample:"
					loc trimobs=`trimobs'+`trimmedobs'
					noi di as text "- `trimmedobs' obs. from the tails because of limited support and the trimsupport() option"
				}
			}

			//If trimming the sample, re-run the first stage on the trimmed sample

			if `trimsupport'>0 {
				if "`first'"!=""&"`margins'"!=" margins" loc noi noi
				`noi' `link' `d' `z' `x' `restricted' [`weight'`exp'] if `touse2', `vcefirst' `firststageoptions'
				drop `p'
				predict double `p' if e(sample)
				predict double `gammaZ' if e(sample), xb
				count if !e(sample)&`touse2'
				if r(N)>0 {
					if `trimobs'==0  noi di as text "The following number of observations have been trimmed from the sample:"
					else loc trimobs=`trimobs'+`trimmedobs'
					noi di as text "- `r(N)' obs. because observables predict treatment perfectly after trimming"
				}
				markout `touse2' `p'
				if "`savefirst'"!="" {
					if "`margins'"==" margins" {
						if "`first'"!="" loc noi noi
						`noi' margins, dydx(*) post
					}
					test `z'
					estadd scalar p_instruments=r(p)
					est save "`savefirst'", replace
				}
				replace `p'=1 if `p'>1&`touse2'
				replace `p'=0 if `p'<0&`touse2'
			}

			if `trimobs'>0 noi di as text "Continuing without these observations"
			
			//Check gridpoints option
			if `gridpoints'!=0 {
				if `gridpoints'>`N' {
					noi di as text "Note: Fewer observations used in the second stage than specified grid precision in option "
					noi di as text "gridpoints. Option gridpoints ignored, local polynomial regressions performed at precise "
					noi di as text "propensity scores."
					loc gridpoints=0
				}
			}

			//Check support of P(Z)
			tempvar groupp
			egen `groupp'=group(`p') if `touse2'
			su `groupp'
			loc numZvals=r(max)
			if "`semiparametric'"!=""&`numZvals'<=10 {
				noi di in red "The instrument, controls and variables in restricted() generate only `numZvals' points"
				noi di in red "of support for P(Z). This is very limited for estimating a semiparametric model. Specify"
				noi di in red "a parametric model or generate more variation in P(Z) through covariates and/or instruments."
				exit
			}
			else if "`semiparametric'"=="" {
				if `polynomial'==0 loc numparams=1
				else loc numparams=`polynomial'+`numknots'*(`polynomial'-1)
				if ((`numZvals'<`numparams'+1)&"`separate'`mlikelihood'"!="")|((`numZvals'<`numparams'+2)&"`separate'`mlikelihood'"=="") {
					noi di in red "The variables in X, Z and restricted() generate a total of `numZvals' points of"
					noi di in red "support for P(Z), and can identify a parametric MTE model with no more"
					noi di in red "than `=`numZvals'-1' parameter(s) when using the separate approach and `=`numZvals'-2' parameters"
					noi di in red "when using Local IV. Specify a simpler functional form for the MTE"
					noi di in red "or use more covariates or instruments to increase support of P(Z)."
					exit
				}
			}

			if "`savepropensity'"!="" gen double `savepropensity'=`p' if `touse'
			
			
			**********************************************
			* Initial values if using Maximum Likelihood *
			**********************************************
		
			if "`mlikelihood'"!="" {
				tempvar d0
				tempname init init0 init1 initgamma initsigma
				
				gen `d0'=1-`d'
				heckman `y' `x' `restricted' if `touse', select(`d0'=`z' `x' `restricted') two
				mat `init0'=e(b)
				mat `init0'=`init0'[1,"`y':"]
				mat coleq `init0'=`y'0
				if (abs(e(rho)) == 1)  loc rho = sign(e(rho))*(1-0.1D-8)
				else loc rho=e(rho)
				mat `initsigma'=ln(e(sigma)),atanh(`rho')
				
				heckman `y' `x' `restricted' if `touse', select(`d'=`z' `x' `restricted') two
				mat `init1'=e(b)
				mat `initgamma'=`init1'[1,"`d':"]
				mat `init1'=`init1'[1,"`y':"]
				mat coleq `init1'=`y'1
				mat coleq `initgamma'=`d'
				if (abs(e(rho)) == 1)  loc rho = sign(e(rho))*(1-0.1D-8)
				else loc rho=e(rho)
				mat `initsigma'=`initsigma'[1,1],ln(e(sigma)),`initsigma'[1,2],atanh(`rho')
				mat colnames `initsigma'=lns0:_cons lns1:_cons athrho0:_cons athrho1:_cons
				
				mat `init'=`init0',`init1',`initgamma',`initsigma'
				}

			************************************************
			* Calculate Treatment effect parameter weights *
			************************************************

			tempname dhat upsilon uweightslate uweightsatt uweightsatut xweightslate xweightsatt xweightsatut indicator covmat
			`regress' `d' `z' `x' `restricted' [`weight'`exp'] if `touse2'
			predict double `dhat' if `touse2'
			`regress' `dhat' `x' `restricted' [`weight'`exp'] if `touse2'
			predict double `upsilon' if `touse2', residuals
			mean `upsilon' [`weight'`exp'] if `touse2'
			loc upsilonbar=_b[`upsilon']
			mean `d' [`weight'`exp'] if `touse2'
			loc dbar=_b[`d']
			mat accum `covmat'=`d' `y' `upsilon'  [`weight'`exp'] if `touse2', deviations nocons
			mat `covmat'=`covmat'/(`N'-1)
			loc dVar=`covmat'[1,1]
			loc cov_du=`covmat'[3,1]
			loc cov_yu=`covmat'[3,2]
			loc iv=`=`cov_yu'/`cov_du''
			gen double `xweightslate'=((`d'-`dbar')*(`upsilon'-`upsilonbar'))/(`cov_du') if `touse2'
			mean `p' [`weight'`exp'] if `touse2'
			loc pbar=_b[`p']
			gen double `xweightsatt'=`p'/(`pbar') if `touse2'
			gen double `xweightsatut'=(1-`p')/((1-`pbar')) if `touse2'
			if "`prte'"!="" {
				tempname xweightsprte uweightsprte
				mean `prtevar' [`weight'`exp'] if `touse2'
				loc prtebar=_b[`prtevar']
				gen double `xweightsprte'=(`prtevar'-`p')/((`prtebar'-`pbar')) if `touse2'
			}
			gen `indicator'=.
			su `p' if `touse2'
			loc min=r(min)
			loc max=r(max)
			if "`prte'"!="" {
				su `prtevar' if `touse2'
				loc minpprte=r(min)
				loc maxpprte=r(max)
			}
			forvalues i=1/`=rowsof(`support')' {
				if `min'>=`support'[`i',1] loc prop=1
				else if `max'<=`support'[`i',1] loc prop=0
				else {
					replace `indicator'=`p'>`support'[`i',1] if `touse2'
					proportion `indicator' [`weight'`exp'] if `touse2'
					loc prop=_b[`indicator':1]
				}
				if `prop'>0 {
					mean `upsilon' [`weight'`exp'] if `p'>`support'[`i',1]&`touse2'
					loc eupsilon=_b[`upsilon']
					mat `uweightslate'=[nullmat(`uweightslate') \ `=(1/99)*(`prop'*(`eupsilon'-`upsilonbar'))/`cov_du'']
				}
				else mat `uweightslate'=[nullmat(`uweightslate') \ 0 ]
				mat `uweightsatt'=[nullmat(`uweightsatt') \ `=(1/99)*(`prop'/`pbar')']
				mat `uweightsatut'=[nullmat(`uweightsatut') \ `=(1/99)*(1-`prop')/(1-`pbar')']
				if "`prte'"!="" {
					if `minpprte'>=`support'[`i',1] loc propprte=1
					else if `maxpprte'<=`support'[`i',1] loc propprte=0
					else {
						replace `indicator'=`prtevar'>`support'[`i',1] if `touse2'
						proportion `indicator' [`weight'`exp'] if `touse2'
						loc propprte=_b[`indicator':1]
					}
					mat `uweightsprte'=[nullmat(`uweightsprte') \ `=(`propprte'-`prop')/(99*(`prtebar'-`pbar'))']
				}
			}
			
			if "`rescale'"!="norescale"&rowsof(`support')!=99 {
				tempname tescales sum
				mat `tescales'=rowsof(`support')/99
				foreach param in att atut late `doprte' {
					mat `sum'=J(1,rowsof(`uweights`param''),1)*`uweights`param''
					mat `uweights`param''=`uweights`param''/`sum'[1,1]
					mat `tescales'=`tescales',`sum'[1,1]
					}
				mat colnames `tescales'=ate att atut late `doprte'
				}

			//Calculate MPRTE weights
			tempname pcat temppden pden pmean fgammaZ fgammaZmean fv uweightsmprte1 uweightsmprte2 uweightsmprte3 xweightsmprte1
			egen `pcat'=cut(`p') if `touse2', at(0.005(0.01)0.995) icodes
			replace `pcat'=`pcat'+1
			proportion `pcat' [`weight'`exp'] if `touse2'
			mat `temppden'=e(b)
			mean `p' [`weight'`exp'] if `touse2'
			mat `pmean'=e(b)

			forvalues s=1/`=rowsof(`support')' {
				cap mat `pden'=[nullmat(`pden') \ `temppden'[1,"`pcat':`s'"] ]
				if _rc!=0 mat `pden'=[nullmat(`pden') \ 0]
			}

			if "`link'"=="probit" gen double `fgammaZ'=normalden(`gammaZ') if `touse2'
			else if "`link'"=="logit" gen double `fgammaZ'=exp(`gammaZ')/(1+exp(`gammaZ'))^2 if `touse2'
			else gen double `fgammaZ'=`gammaZ' if `touse2'
			mean `fgammaZ' [`weight'`exp'] if `touse2'
			mat `fgammaZmean'=e(b)
			gen double `xweightsmprte1'=`fgammaZ'/`fgammaZmean'[1,1]

			if "`link'"=="logit" mata: `fv'=exp(invlogit(st_matrix("`support'"))):/((J(`=rowsof(`support')',1,1)+exp(invlogit(st_matrix("`support'")))):^2)
			else if "`link'"=="probit" mata: `fv'=normalden(invnormal(st_matrix("`support'")))
			else mata: `fv'=st_matrix("`support'")

			mata: st_matrix("`uweightsmprte1'",(st_matrix("`pden'"):*`fv'):/st_matrix("`fgammaZmean'"))
			mat `uweightsmprte2'=`pden'
			mata: st_matrix("`uweightsmprte3'",(st_matrix("`pden'"):*st_matrix("`support'")):/st_matrix("`pmean'"))

			if "`saveweights'"!=""{
				foreach param in late att atut mprte1 `doprte' {
					gen double `saveweights'`param'=`xweights`param''
				}
			}

			///Calculate relevant mean of X for all treatment effect parameters
			tempname temp mtexs_ate mtexs_att mtexs_atut mtexs_late mtexs_prte mtexs_mprte1 mtexs_mprte2 mtexs_mprte3 mtexs_full temp

			if "`prte'"=="" loc end 7
			else loc end 8

			tokenize ate att atut late mprte1 mprte2 mprte3 `doprte'

			tempvar xweightsate xweightsmprte2 xweightsmprte3
			foreach param in ate mprte2 mprte3 {	
				gen `xweights`param''=1
			}
			
			fvexpand `x' if `touse2'
			local xnames `r(varlist)'
			forvalues i=1/`end' {
				mat accum `temp'=c.(`x')#c.`xweights``i''' [`weight'`exp'] if `touse2', means(`mtexs_``i''')
				mat `mtexs_``i'''=`mtexs_``i''''
				mat rownames `mtexs_``i'''=`xnames' _cons
			}
			if "`restricted'"!="" {
				fvexpand `restricted' if `touse2'
				local restrictednames `r(varlist)'
				mat accum `temp'=`restricted' [`weight'`exp'] if `touse2', means(`mtexs_full')
				if "`x'"!="" mat `mtexs_full'=`mtexs_ate'[1..`=rowsof(`mtexs_ate')-1',1] \ `mtexs_full''
				else mat `mtexs_full'=`mtexs_full''
				mat rownames `mtexs_full'=`xnames' _cons `restrictednames' 
			}
			else mat `mtexs_full'=`mtexs_ate'

			
			//Determine size and names of coefficient matrix
			local numX: word count `xnames'
			local numR: word count `restrictednames'
			foreach var in `xnames' {
				loc colnames0 `colnames0' beta0:`var'
				loc colnames1 `colnames1' beta1-beta0:`var'
				}
			foreach var in `restrictednames' {
				loc colnamesR `colnamesR' restricted:`var'
				}
			
			if "`semiparametric'"==""|"`semiparametric'"!=""&`polynomial'>0{	
				if `polynomial'==0 {
					if "`mlikelihood'`separate'"!="" loc colnames `colnames0' beta0:_cons k0:mills0 `colnames1' beta1-beta0:_cons k:mills `colnamesR'
					else loc colnames `colnames0' beta0:_cons `colnamesR' `colnames1' beta1-beta0:_cons k:mills
					}
				else {
					if "`separate'"!="" {
						forvalues k=1/`polynomial' {
							loc polynames1 `polynames1' k:p`k'
							loc polynames0 `polynames0' k0:p0`k'
							}
					if "`splines'"!="" {
						loc numsplines=(`polynomial'-1)*`numknots'
						loc numknots: word count `splines'
						loc num=0
						forvalues knot=1/`numknots' {
							forvalues k=2/`=`polynomial'' { 
								loc ++num
								loc splinenames0 `splinenames0' k0:spline0`knot'_`k' 
								loc splinenames1 `splinenames1' k:spline`knot'_`k' 
								}
							}
						}
					loc colnames `colnames0' beta0:_cons `polynames0' `splinenames0' `colnames1' beta1-beta0:_cons `polynames1' `splinenames1' `colnamesR'
					}
					else {
						forvalues k=1/`=`polynomial'' {
						loc polynames `polynames' k:p`k'
						}
					if "`splines'"!="" {
						loc num=0
						local numknots: word count `splines'
						forvalues knot=1/`numknots' {
							forvalues k=2/`=`polynomial'' { 
								loc ++num
								loc splinenames `splinenames' k:spline`knot'_`k'
								}
							}
						}
					
					loc colnames  `colnames0' beta0:_cons `colnamesR' `colnames1' beta1-beta0:_cons `polynames' `splinenames'
					} 
				}
			}
			else loc colnames `colnames0' `colnamesR' `colnames1'
			
			*******************************
			* Run the specified MTE model *
			*******************************

			if `bootreps'==0 {
				noi mtefe_secondstage `y' `x'  [`weight'`exp'] if `touse2', evalgrid(`support') evalgrid1(`support1') evalgrid0(`support0') /*
				*/ polynomial(`polynomial') splines(`splines') `rescale' gridpoints(`gridpoints') colnames(`colnames') numx(`numX') numr(`numR') init(`init')/*
				*/ propscore(`p') restricted(`restricted') ybwidth(`ybwidth') xbwidth(`xbwidth') degree(`degree')  `separate' prte(`prte')  `mlikelihood' /*
				*/ uweights(`uweightsatt' `uweightsatut' `uweightslate'	`uweightsmprte1' `uweightsmprte2' `uweightsmprte3'  `uweightsprte') `savekp' `semiparametric' kernel(`kernel') norepeat1 /*
				*/ vce(`vce') link(`link') gammaZ(`gammaZ') treatment(`d') instruments(`z') firststageoptions(`firststageoptions') `second' mtexs_ate(`mtexs_ate') mtexs_att(`mtexs_att') /*
				*/ mtexs_atut(`mtexs_atut') mtexs_late(`mtexs_late') mtexs_prte(`mtexs_prte') mtexs_mprte1(`mtexs_mprte1') mtexs_mprte2(`mtexs_mprte2') mtexs_mprte3(`mtexs_mprte3') mtexs_full(`mtexs_full')
			}


			else if `bootreps'>0 {
				count if `touse2'
				if r(N)!=_N {
					preserve
					keep if `touse2'
				}
				
				//If the cluster variable is also included as fixed effects, cluster on a temprary variable and then include idcluster as fixed effects instead.
				if "`clustvar'"!="" {
					if strpos("`x' `restricted'",".`clustvar'")>0 {
						tempvar tempclustvar tempclustvar2
						levelsof `clustvar', local(clustlevels)
						rename `clustvar' `tempclustvar'
						egen `clustvar'=group(`tempclustvar') if `touse2'
						gen `tempclustvar2'=`clustvar'
						loc idcluster idcluster(`clustvar')
						loc replace=1
					}	
				}

				noi bootstrap, reps(`bootreps') level(`level') cluster(`tempclustvar2') `bsopts' notable `idcluster': /*
				*/ mtefe_secondstage `y' `x' [`weight'`exp'], evalgrid(`support') evalgrid1(`support1') evalgrid0(`support0') numx(`numX') numr(`numR')/*
				*/ polynomial(`polynomial') splines(`splines') `rescale' gridpoints(`gridpoints') propscore(`p') restricted(`restricted') init(`init')/*
				*/ ybwidth(`ybwidth') xbwidth(`xbwidth') degree(`degree') kernel(`kernel')  `separate'  colnames(`colnames') clustlevels(`clustlevels') `idcluster' /*
				*/ `savekp' prte(`prte') uweights(`uweightsatt' `uweightsatut' `uweightslate'	`uweightsmprte1' `uweightsmprte2' `uweightsmprte3' `uweightsprte') `mlikelihood' `second' /*
				*/ `semiparametric' `repeat1' boot link(`link') gammaZ(`gammaZ') treatment(`d') instruments(`z') firststageoptions(`firststageoptions') /*
				*/ mtexs_ate(`mtexs_ate') mtexs_att(`mtexs_att') mtexs_atut(`mtexs_atut') mtexs_late(`mtexs_late') mtexs_prte(`mtexs_prte') mtexs_mprte1(`mtexs_mprte1') mtexs_mprte2(`mtexs_mprte2') mtexs_mprte3(`mtexs_mprte3') mtexs_full(`mtexs_full')

				ereturn local clustvar "`clustvar'"
				
				if "`replace'"!="" {
					drop `clustvar'
					rename `tempclustvar' `clustvar'
				}
			}

			******************************
			* Test heterogeneous effects *
			******************************

			if "`semiparametric'"=="" {
				test [k]
				loc p_unobshet=r(p)
			}
			else if `bootreps'>0  {
				tempname sup
				mat `sup'=e(support)
				forvalues i=1/`=rowsof(`sup')' {
					loc u=round(100*`sup'[`i',1])
					if `i'==1 loc test u`u'
					else loc test `test'=u`u'
				}
				test `test'
				loc p_unobshet=r(p)
			}

			if ("`semiparametric'"==""|`bootreps'>0)&"`x'"!="" {
				cap test [beta1-beta0]
				if _rc==0 loc p_obshet=r(p)
			}	

			if "`p_unobshet'"!="" 	ereturn local p_U=`p_unobshet'
			if "`p_obshet'"!=""		ereturn local p_X=`p_obshet'
			
			//save a few other results
			if rowsof(`support')!=99&"`rescale'"!="norescale" ereturn matrix tescales=`tescales'
			if `trimsupport'!=0 ereturn matrix trimminglimits=`trimlim'
			*******************
			* Display results *
			*******************
			local tmp: coleq e(b)
			loc num=0
			foreach token in `tmp' {
				loc ++num 
				if `num'==1|"`token'"!="`lasttoken'" loc neqlist `neqlist' `token'
				loc lasttoken `token'
			}
			loc neq: word count `neqlist'

			if "`link'"=="`regress'" loc link LPM
			else loc link `=proper("`link'")'

			ereturn local title2 "Treatment model: `link'"
			ereturn local cmdline 	"mtefe `0'"
			ereturn scalar iv=`iv'

			noi di _newline
			if `bootreps'==0 noi di as result "`e(title)'" _col(62) as text "Obs. : " as result %10.0fc e(N) 
			noi di as text "`e(title2)'"
			noi di as text "Estimation method: `e(method)'"
			noi ereturn display, level(`level') neq(`=`neq'-1') noemptycells nolstretch
			if "`semiparametric'"==""|`bootreps'>0 {
				if "`p_obshet'"!="" noi di "Test of observable heterogeneity, p-value {col 66} `: di %12.4f `p_obshet''"
				if "`p_unobshet'"!="" {
					noi di "Test of essential heterogeneity, p-value {col 66} `: di %12.4f `p_unobshet''"
				}
				noi di "{hline 78}"
			}
			if (("`semiparametric'"=="")|("`semiparametric'"!=""&`polynomial'>0))&`bootreps'==0 {
				if "`mlikelihood'"=="" {
					noi di as text 	"Note: Analytical standard errors ignore the facts that the propensity score,"
					noi di as text 	"the mean of X and the treatment effect parameter weights are estimated objects"
					noi di as text 	"when calculating standard errors. Consider using bootreps() to bootstrap the "
					noi di as text 	"standard errors."
				}
				if "`mlikelihood'"!="" {
					noi di as text 	"Note: Analytical standard errors ignore the fact that the mean of X and the"
					noi di as text 	"treatment effect parameter weights are estimated objects when calculating "
					noi di as text 	"standard errors for the treatment effect parameters and MTEs. Consider using"
					noi di as text  "bootreps() to bootstrap the standard errors."
				}
			}
			if rowsof(e(support))<99&"`rescale'"!="norescale" {
				noi di as text	"Note: Limited support. Regular, non-marginal treatment effect parameters (ATE, ATT,"
				noi di as text	"ATUT, LATE and PRTE) cannot be estimated. Instead, reported parameters are "
				noi di as text	"rescaled so that the treatment effect parameters weights sum to 1 within support." 
			}
			if rowsof(e(support))<99&"`rescale'"=="norescale" {
				noi di as text	"Note: Limited support. Regular, non-marginal treatment effect parameters (ATE, ATT,"	
				noi di as text	"ATUT, LATE and PRTE) cannot be estimated. Reported parameters are weighted "
				noi di as text	"averages within support, not rescaled so that weights sum to 1."
			}
			noi di _newline

			//Plot MTE
			if "`noplot'"=="" {
				if colsof(e(mte))<20 loc points points
				mtefeplot, level(`level') `points'
			}
		}	
	end
}

//adapted _iv_parse

program myivparse, sclass
	syntax anything [if] [in]
	noi di "`anything'"
	marksample touse
	local n 0

	gettoken lhs 0 : 0, parse(" ,[") match(paren) bind
	if (strpos("(",`"`lhs'"')) {
		fvunab lhs : `lhs'
		if `:list sizeof lhs' > 1 {
			gettoken lhs rest : lhs
			local 0 `"`rest' `0'"'
		}
	}
	IsStop `lhs'
	if `s(stop)' { 
		error 198 
	}  
	_fv_check_depvar `lhs'
	while `s(stop)'==0 {
		if "`paren'"=="(" {
			local n = `n' + 1
			if `n'>1 {
				capture noi error 198
				di as error `"syntax is "(all instrumented variables = instrument variables)""'
				exit 198
			}
			gettoken p lhs : lhs, parse(" =") bind
			while "`p'"!="=" {
				if "`p'"=="" {
					capture noi error 198
					di as error `"syntax is "(all instrumented variables = instrument variables)""'
					di as error `"the equal sign "=" is required"'
					exit 198
				}
				local end`n' `end`n'' `p'
				gettoken p lhs : lhs, parse(" =") bind
			}
			/* An undocumented feature is that we can specify
			   ( = <insts>) with GMM estimation to impose extra
			   moment conditions 
			*/ 
			if "`end`n''" != "" {
				fvunab end`n' : `end`n''
			}
			fvunab exog`n' : `lhs'
		}
		else {
			local exog `exog' `lhs'
		}
		gettoken lhs 0 : 0, parse(" ,[") match(paren) bind
		IsStop `lhs'
	}
	mata: st_local("0",strtrim(st_local("lhs")+ " " + st_local("0")))

	fvunab exog : `exog'
	// fvexpand `exog' if `touse'
	// local exog `r(varlist)'
	tokenize `exog'
	local lhs "`1'"
	local 1 " "
	local exog `*'

	// Eliminate vars from `exog1' that are in `exog'
	local inst : list exog1 - exog
	if ("`end1'" != "") {
		fvunab end1 : `end1'
		fvexpand `end1' if  `touse'
		local end1 `r(varlist)'
	}

	// `lhs' contains depvar, 
	// `exog' contains RHS exogenous variables, 
	// `end1' contains RHS endogenous variables, and
	// `inst' contains the additional instruments
	// `0' contains whatever is left over (if/in, weights, options)

	sret local lhs `lhs'
	sret local exog `exog'
	sret local endog `end1'
	sret local inst `inst'
	sret local zero `"`0'"'

end

// Borrowed from ivreg.ado      
program define IsStop, sclass

	if `"`0'"' == "[" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else {
		sret local stop 0
	}

end


