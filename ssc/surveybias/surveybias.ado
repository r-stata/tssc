/* surveybias.ado --- 
 * 
 * Filename: surveybias.ado
*! Author: Kai Arzheimer & Jocelyn Evans
*! 1.4 Aug 07 2015
 * URL: 
 * Keywords: 
 * Compatibility: 
 * 
 */

/* Commentary: 
 * 
 * 
 * 
 */

/* Change log:
 * 
 * 
 */

/* Code: */


*! Calculate A, A', B and Chi-2

program define surveybias, eclass byable(recall) properties(svyb svyj svyr)
version 11
	if !replay() {
		syntax varname(numeric)  [if] [in] [fweight pweight iweight aweight], POPvalues(numlist min=2) [VERBose] [prop] [NUMerical] [Level(cilevel)] [VCE(passthru)] [subpop(passthru)] [CLuster(passthru)] [svy]
* prop is a synonym for option previously known as numerical
		if "`prop'" != "" {
			local numerical "numerical"
			}
		marksample touse
		local commandline   "surveybias `*'"
* switch to svy if subpop-Option set & check that var exists & is unambiguous
		if "`subpop'" != "" {
			local checkvar : subinstr local subpop "subpop(" ""
			local checkvar : subinstr local checkvar ")" ""
			confirm var `checkvar'
			local svy "svy"
			}
		if "`svy'" != "" {
			display "Using survey characteristics of your data" _n
			local setsurveyprefix "svy , `subpop' : "
			if "`numerical'" == "" {
				local numerical "numerical"
				local complex "complex"
				}
			}
		if "`cluster'" != "" | "`vce'" != "" {
* Does clustering variable exist? Is it unambiguous? 
			if "`cluster'" != "" {
				local checkvar : subinstr local cluster "cluster(" ""
				local checkvar : subinstr local checkvar ")" ""
				confirm var `checkvar'
				}
			if "`numerical'" == "" {
				}
			local numerical "numerical"
			local complex "complex"
			}
* Take care of weights
		if "`weight'" != "" {
			local weighting "[`weight' `exp']"
			}
		if "`weight'" == "pweight" & "`numerical'" == "" {
			local numerical "numerical"
			local complex "complex"
			}
		if "`weight'" == "aweight" {
			if "`cluster'" != "" | "`vce'" != "" {
				display as error _n "You may not combine aweights with complex variance estimators" _n
				error 406
				}
			if "`numerical'" != "" {
				display  "Switching to analytical methods"
				local numerical ""
				local complex "complex"
				}
			}

* unique values + integer values
		qui inspect `varlist' if `touse'
		local nunique=r(N_unique)
		tempname intvalues
		scalar `intvalues' = r(N_posint) + r(N_negint)
* Min/max
		qui summarize `varlist' if `touse'
		local mincode=`r(min)' 
		local maxcode=`r(max)'

* Test for problems with variable
	
		if `nunique' <2 {
			display as error "There is no variation in `varlist'" _newline
			error 409
			* No variation in variable
		}
		else if `nunique' >12 {
			display "Warning: `varlist' has many (`nunique') unique values" _newline
    		display "combining values/recoding `varlist' is strongly recommended" _newline
		}
		else if `r(N)' > `intvalues' {
			display as error "`varlist' has non-integer values" _newline
			exit 498
			}
		else if `nunique' > (`maxcode' - `mincode' +1) {
			display "Warning: category codes non-consecutive"
			}

* Test for problems with numlist
		local listnum : word count `popvalues'
		if `listnum' != `nunique' {
			display as error "Number of categories in  sample (`nunique') and population (`listnum') do not match" _newline
			exit 498
			}

* Test for non-positive values in numlist
		foreach value of local popvalues  {
			if `value'  <=0 {
				display as error "All proportions must be strictly positive" _newline
				error 125
				}
			}
		
		if "`verbose'" != "" {
			dis as txt "Information on `varlist'"	
			codebook `varlist'	
			dis as txt "Please make sure that `varlist' is correctly labelled, and that"
			dis as txt "the sequence of population values matches `varlist' "
			dis _n
			}
* Normalise information on population to proportions

* Calculate sum
		local popvalsum = subinstr("`popvalues'"," "," + ",.)
* Force evaluation of sum	
		local popvalsum = `popvalsum'
* Normalise
		local normpopvalues = ""
		foreach v of local popvalues {
			local normedval =  `v' / `popvalsum'
			local normpopvalues `normpopvalues' `normedval'
			}

* Is there a significant difference between the distribution in the sample and the known distribution in the population?
* Calculate empirical proportions.
* Run a chi-square test further down the line
		tempname observed
		if "`weight'" == "pweight" {
			qui tab `varlist' if `touse' ,matcell(`observed')
			}
		else {
			qui tab `varlist' `weighting' if `touse' ,matcell(`observed')
			}
		local cases = r(N)
		matrix `observed' = `observed''

* Collect labels/numbers in macro
			qui levelsof `varlist',local(surveycats)
			foreach s of local surveycats {
			local valueorlabel : label (`varlist') `s' 12
* Limit length of label and sanitize (chomp spaces)
			local valueorlabel : subinstr local valueorlabel " " "", all
			local surveycatlabels `surveycatlabels' A':`valueorlabel'
				}



		
/*****************************************************************/
/* Major branch ahead:														  */
/* Analytical solution (new in version 1.2 and now default) vs	  */
/* prop/logit solution (default in previous versions)	     */
/*****************************************************************/

* Share code over both branches
* Build vector of v-components (v/(1-v))
			tempname vcomponent pcomponent v p missmat 
			matrix `vcomponent' = J(1,`listnum',0)
			matrix `v' = J(1,`listnum',0)
			forvalues index = 1/`listnum' {
				local thispopval : word `index' of `normpopvalues'
				matrix `vcomponent'[1,`index'] = (1- `thispopval') / `thispopval'
* Keep untransformed population proportions as vector v
				matrix `v'[1,`index'] = `thispopval'
				}
* Create vector for As
			matrix aprimes = J(1,`listnum',0)

		
		if "`numerical'" == "" {
* Not numerical: Direct estimation starts here
* Create vector of p-components (p/1-p)
			matrix `p' = `observed' / `cases'
			matrix `pcomponent' = `p'
			forvalues i = 1 / `listnum' {
				matrix `pcomponent'[1,`i'] = `pcomponent'[1,`i'] / (1- `pcomponent'[1,`i'])
				matrix aprimes[1,`i'] = ln(`pcomponent'[1,`i'] * `vcomponent'[1,`i'])
				}		

* Build the Jacobian (k*k)
			matrix Jac = J(`listnum',`listnum',0)
			forvalues i =  1/`listnum'  {
			matrix Jac[`i',`i'] = 1 / (`p'[1,`i'] * ( 1 - `p'[1,`i']))
				}


* Next: analytical derivation of variance-covariance matrix
* Sigma_theta for variation of Parameters in theta space (proportions in multinomial distribution)
* Matrix is k*k where k = number of categories = `listnum'
			matrix sigmatheta = J(`listnum',`listnum',0)
* Calculate diagonal elements
			forvalues i =  1/`listnum'  {
				matrix sigmatheta[`i',`i'] = `p'[1,`i']  * (1 -  `p'[1,`i']) / `cases'
				}
* Do off-diagonal elements
			forvalues r = 1/`listnum' {
				local rstart = `r' + 1
				forvalues c = `rstart' / `listnum' {
					matrix sigmatheta[`r',`c'] = -1 * `p'[1,`r'] * `p'[1,`c'] / `cases'
					* symmetric
					matrix sigmatheta[`c',`r']  = sigmatheta[`r',`c'] 
					}
				}
			matrix covs = Jac * sigmatheta * Jac'
			matrix rownames aprimes=A'

			}

		else {

* prop/mlogit procedure starts here

* Estimate proportions (to get SEs)
		 capture `setsurveyprefix' proportion `varlist' `weighting' if `touse',  `cluster' `vce'
* Save number of complete cases
		local cases = e(N)
* proportion gives names to equations if var has val-label, so we cannot use surveycats
   	local propnames = e(namelist)	
* Create vector of p-components (p/1-p)
			matrix `p' = e(b)
			matrix `pcomponent' = `p'
			forvalues i = 1 / `listnum' {
				matrix `pcomponent'[1,`i'] = `pcomponent'[1,`i'] / (1- `pcomponent'[1,`i'])
				matrix aprimes[1,`i'] = ln(`pcomponent'[1,`i'] * `vcomponent'[1,`i'])
				}		

* Build the Jacobian (k*k)
			matrix Jac = J(`listnum',`listnum',0)
			forvalues i =  1/`listnum'  {
			matrix Jac[`i',`i'] = 1 / (`p'[1,`i'] * ( 1 - `p'[1,`i']))
				}

			
* Categories need not be consecutive, so we cannot simply loop from 1 to n but need an index
	
		qui levelsof `varlist',local(surveycats)
			matrix covs = e(V) 
			matrix covs = Jac * covs * Jac'





			}

* Relabel matrices
		local surveycatlabels `surveycatlabels' B:B
		local surveycatlabels `surveycatlabels' B:B_w
	   mata: calcbandbw()
		matrix rownames aprimes=A'
		matrix colnames aprimes=`surveycatlabels'
* Expand covariance matrix to hold missing values for B, B_w
* From v 1.2, we do no longer calculate pseudo SEs for these two
		matrix missmat = J(`listnum',2,0)
		matrix covs = covs , missmat
		matrix missmat = J(2, `listnum'+2,0)
		matrix covs = covs \ missmat 
		matrix rownames covs=`surveycatlabels'
		matrix colnames covs=`surveycatlabels'
		
* Complete chi-square calculations (matrix with observed frequencies calculated above)
* This is only valid for simple variance estimator/no weights
* local complex is a switch - if it's triggered, perform Wald Test instead		
		tempname df
		scalar `df' = `nunique' - 1
		if "`complex'" == "" {
			tempname chisqp
			tempname chisqlr
			tempname pp
			tempname plr
			mata: calcchisquare()
			scalar `pp' = chi2tail(`df',`chisqp')
			scalar `plr' = chi2tail(`df',`chisqlr')
			}
		else {
			}		


* Prepare for posting

		ereturn post aprimes covs,depname(`varlist') esample(`touse') obs(`cases')


* Once more, branch: Chi-Square or Wald?
		if "`complex'" == "" {
* Pearson Chi-2
			ereturn scalar chi2p =  `chisqp'
			ereturn scalar pp = `pp'
* LR Chi-2
			ereturn scalar chi2lr =  `chisqlr'
			ereturn scalar plr = `plr'
			}
*Wald-Land
		else {
			qui test [A']
			tempname chisqwald
			tempname pwald
			scalar `chisqwald' = r(chi2)
			scalar `pwald' = r(p)
			ereturn scalar chi2wald = `chisqwald'
			ereturn scalar pwald = `pwald'
			}
		ereturn scalar df = `df'
		ereturn local cmdline `commandline'
		ereturn local cmd "surveybias"
		}
	else { //replay
		syntax [, Level(cilevel)]
		local cases = e(N)
		}
	ereturn display, level(`level')
	display as text " "
	display as text _col(5) "Ho: no bias"

	display as text _continue _col(5) "Degrees of freedom: "
	display as result  _col(25) e(df)

	if "`complex'" == "" {
		display as text _continue _col(5) "Chi-square (Pearson) = "
		display as result  _col(26) e(chi2p)
		display as text _continue _col(5) "Pr (Pearson) = "
		display as result _col(18) e(pp)

		display as text _continue _col(5) "Chi-square (LR) = "
		display as result   _col(20) e(chi2lr)
		display as text _continue _col(5) "Pr (LR) = "
		display as result _col(13) e(plr)
		}
	else {
		display as text _continue _col(5) "Chi-square (Wald) = "
		display as result   _col(20) e(chi2wald)
		display as text _continue _col(5) "Pr (Wald) = "
		display as result _col(13) e(pwald)
		}

* Small sample size?

	if `cases' < 100 {
		display _n "Warning: The effective sample size is very small (n=`cases')."
		display "Chi square values may be unreliable."
		display "Consider using mgof (ssc describe mgof) for exact tests."
		}

end
mata:
	void calcchisquare()
	{
		myvalidcases = strtoreal(tokens(st_local("cases")))
		expected = strtoreal(tokens(st_local("normpopvalues")))*myvalidcases
		tempstring = st_local("observed")
		/* get observed values */
		observed = st_matrix(tempstring)
		/* calculate Pearson chisquare and LR chisquare */
		chisqp = sum(((observed :- expected):^2) :/ expected)
		chisqlr = 2*sum(ln(observed :/ expected):*observed)
		/* return chisq in temp macro */
		chitempstringp = st_local("chisqp")
		chitempstringlr = st_local("chisqlr")
		st_numscalar(chitempstringp,chisqp)
		st_numscalar(chitempstringlr,chisqlr)
		}
	
	end

* Calculate B and B_w from vector aprimes, append them 	

	mata:
		void calcbandbw()
		{
		/* Get Matrix/Vector auf As from Stata */
		myaprimes = st_matrix("aprimes")
		/* Take absolute values			 */
		myabsprimes = abs(myaprimes)
		/* Get number of categories */
		k = strtoreal(tokens(st_local("listnum")))
		/* Define vectors fuer simple/weighted average */
		simple=J(1,k,1/k)
		/* Calculate b and append */
		b= simple * myabsprimes'
		myaprimes = myaprimes , b
		/* Convert list of normalised proportions in the population to vector of weights */
		v = strtoreal(tokens(st_local("normpopvalues")))
		/* Calculate bw and append  */
		bw = v * myabsprimes'
		myaprimes = myaprimes, bw
		/* Return matrix to Stata-space */
		st_matrix("aprimes",myaprimes)
		}

	end

/* surveybias.ado ends here */
