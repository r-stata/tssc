*! version 2.0 April 15, 2008 @ 21:12:57
*! Author: Roger Harbord, University of Bristol


	/*
		Plot probability contour ellipse on ROC plot
		with Rutter-Gatsonis axes,
		then corresponding probability contour on SROC plot.
		Also plot SROC line / curve from R-G model.
*/

	/* parameters from gllamm estimates as run in bivariate.ado */
	/* NB variance-covariance of (thetaa,thetab) added to variance params 
	to give predictive variance */ 

	
program define metandiplot, rclass
version 8.2
	syntax [varlist(min=0 max=4 default=none)] [if] [in]  ///
	  [aweight fweight pweight] ///
	  [, Npoints(integer 500)  ///
	  Level(real `c(level)')   ///
	  noTRuncate ///
	  PREDLevel(numlist  max=5 >=10 <=99.99 sort) ///
	  CUrveopts(string asis) SUmmopts(string asis) COnfopts(string asis)  ///
	  PRedopts(string asis)  STudyopts(string asis)  ///
	  XSIZe(real 4) YSIZe(real 5)  ///
	  addplot(string) by(string) ///
	  * ]	// any other options passed on to end of twoway

	tempvar n sens spec curve x curve phi
	tempvar confA confB confsens confspec n

	marksample touse

	if inrange( `: word count `varlist'', 1, 3) error 102  ///
	  // Too few variables specified
	
	capture assert e(cmd) == "metandi"
	if _rc !=0 error 301 /* last estimates not found */

	if "`by'" != "" {
		di as error "option by() not allowed"
		exit 198 // invalid syntax
		}

	preserve
	quietly {
		
		/* initialise legend counter */
		local li 1

		if "`varlist'" != "" { // varlist given containing 2x2 table vars
			tokenize `varlist'
			local tp `1'
			local fp `2'
			local fn `3'
			local tn `4'

			/* study circles */
			if "`studyopts'" == "off" local studyopts
			else {
				if "`weight'" == "" {
					gen `n' = `tp'+`fp'+`fn'+`tn' if `touse'
					local exp "= `n'"
					}
				gen `sens' = `tp' / (`tp'+`fn') if `touse'
				label var `sens' "Sensitivity"
				gen `spec' = `tn' / (`tn'+`fp') if `touse'
				label var `spec' "Specificity"
				local studyplot `"scatter `sens' `spec' if `touse' [aw `exp']"'
				local studyplot "`studyplot', msym(oh) mlcol(gray) mlwidth(thin)"
				local studyplot `"`studyplot' `studyopts' ||"'
				local legend `"`legend' label(`li' "Study estimate")"'
				local order "`order' `li++'"
//				local ++li
				}
			
			} // if "`varlist'" != ""
		
		tempname covmuAB sAB rconfAB sepredA sepredB rpredAB
		matrix V = e(V)
		scalar `covmuAB' = V[1,2]
		scalar `sAB' = _b[sAB]

		/* derived params */
		scalar `rconfAB' = `covmuAB'/(_se[muA]*_se[muB])
		scalar `sepredA' = sqrt(_b[s2A]+_se[muA]^2)
		scalar `sepredB' = sqrt(_b[s2B]+_se[muB]^2)
		scalar `rpredAB' = (`sAB'+`covmuAB')/(`sepredA'*`sepredB')

		if "`confopts'" !="off" | "`predopts'" != "off" ///
		  range `phi' 0 `=2*c(pi)' `npoints'


		/* summary point */
		if `"`summopts'"' == "off" local summopts
		else {
			local sensbar = invlogit(_b[muA])
			local specbar = invlogit(_b[muB])
			local summplot `"scatteri `sensbar' `specbar', ms(S) msiz(*1.4) `summopts' ||"'
			local legend `"`legend' label(`li' "Summary point")"'
			local order "`order' `li++'"
			}


		/* HSROC summary curve */
		if `"`curveopts'"' == "off" local curveopts
		else {
			tempname b Lambda minse
			scalar `b' = (_b[s2B]/_b[s2A])^.25
			scalar `Lambda' = _b[muA]*`b' + _b[muB]/`b'
			range `x' 0 1 `npoints'
			gen `curve' = invlogit( ( -logit(`x') /`b' + `Lambda') / `b' )
			replace `curve' = 0 if `x' == 1
			replace `curve' = 1 if `x' == 0
		
			/* truncate curve outside region of data if given */
			if "`varlist'" != "" & "`truncate'" == "" { 
				summ `sens' , meanonly
				scalar `minse' = r(min)
				summ `spec' , meanonly
				replace `x' = . if `x' < r(min) | `curve' < `minse'
				}
			
			local curveplot `"line `curve' `x', clpatt(solid) `curveopts' ||"'
			local legend `"`legend' label(`li' "HSROC curve")"'
			local order "`order' `li++'"
			}
		
		/*
			/* truncate curve outside prediction region */
			replace `x' = . if ///
			( ( logit(`x') - _b[muB] ) / `sepredB' )^2 + ///
			( ( logit(`curve') - _b[muA]) / `sepredA' )^2 - ///
			2 * (`rpredAB') *  ///
			( logit(`x') - _b[muB] ) * ( logit(`curve') - _b[muA])  / ///
			( `sepredB' * `sepredA' ) ///
			> `croot'^2 * (1 -(`rpredAB')^2)
*/


		/* confidence region */
		if `"`confopts'"' == "off" local confopts
		else {
		// const. for contour level 
			tempname croot
			scalar `croot' = sqrt(2*invF(2,e(N)-2,`level'/100))
			gen `confB' = _b[muB] + _se[muB] * `croot' * cos(`phi')
			gen `confA' = _b[muA] + _se[muA] * `croot' * cos(`phi' + acos(`rconfAB'))
			gen `confsens' = invlogit(`confA')
			gen `confspec' = invlogit(`confB')
			local confplot `"line `confsens' `confspec',clpatt(dash) `confopts' ||"'
			local legend `"`legend' label(`li' "`level'% confidence" "region")"'
			local order "`order' `li++'"
			}
		

		/* prediction region */
		if `"`predopts'"' == "off" local predopts
		else {
			if "`predlevel'" == "" local predlevel `level'
			foreach pl of local predlevel {
				local i = `i' + 1
				tempvar predA`i' predB`i' predsens`i' predspec`i'
				local croot = sqrt(2*invF(2,e(N)-2,`pl'/100))
				gen `predB`i'' = _b[muB] + `sepredB' * `croot' * cos(`phi')
				gen `predA`i'' = _b[muA] + `sepredA' * `croot' *  ///
				  cos(`phi' + acos(`rpredAB'))
				gen `predsens`i'' = invlogit(`predA`i'')
				gen `predspec`i'' = invlogit(`predB`i'')
				local predplot  ///
				  `"`predplot' line `predsens`i'' `predspec`i'' ,clpatt(shortdash) `predopts' ||"'
				local legend `"`legend' label(`li' "`pl'% prediction" "region")"'
			local order "`order' `li++'"
				}
			}

		
		} // end quietly

	twoway `studyplot' `summplot' `curveplot' `confplot' `predplot'  `addplot' ///
	  || , aspect(1) xsc(range(0 1) rev) ysc(range(0 1))  ///
	  xla(0(.2)1, nogrid) yla(0(.2)1, nogrid) ///
	  xti(Specificity) yti(Sensitivity)  ///
	  legend(  ///
	  /// colfirst  position(6) cols(2) ///
	  /// order(`order' ) ///
	  `legend' ///
	  ) ///
	  xsize(`xsize') ysize(`ysize') ///
	  `options' ///
	  /* plotregion(margin(zero)) */
	
	restore

end

	exit
	
	
	
	
	
	
	
	
