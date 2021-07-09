/******************************
* cgmwildboot
* Regression with wild cluster
* bootstrap standard errors as
* in Cameron, Gelbach and Miller
* (2008 ReStat)
* Updates 2013-09-06:
* - Changed p-value computation to base p-values for negative coefficients on
*   the lower tail of the bootstrap distribution and for positive coefficients
*   on the upper tail of the bootstrap distribution
*
* - Changed covariance matrix entries to deal with extreme p-values of 0 or 1,
*   which can occur if initial-tstat is the larger or smaller than any of the
*   bootstrap t-stats. The covariance matrix now puts maxfloat() for a p-value
*   of one (approximately infinite variance, which will give a p-value of 1)
*   and 1/maxfloat() for a p-value of zero (approximately zero variance, which
*   will give a p-value of zero)
* Updates 2013-10-15
* - Added check for the "unique" command
*
* Updates 2013-10-18
* - Corrected number of t-stats divisor for the t-statistic
* - Corrected computation of confidence interval
*
* Updates 2014-02-04
* - Added adjusted R2 and R2 labels
* - Updated cgmreg (does not modify this ado file, but affects results from it)
*
* Updates 2014-02-19
* - Added code to deal with dropped variables (e.g., fixed effects dropped due to collinearity)
* - Similar updates to cgmreg (does not modify this ado file, but affects results from it)
*
* Updates 2014-03-26
* - Corrected error with confidence interval (force negative coefficients to look at
*   lower tail for p-values, and force positive to look at upper tail)
*
* Updates 2015-03-10
* - Corrected confidence interval (again) - Put code to avoid p-values greater than one
*   when, for example, the coefficient is positive and lies within the bottom half of
*   the bootstrap sample (previously, if t-stat on positive coefficient was at the, say
*   25th percentile, the p-value would be 2*(1 - 0.25) = 1.5; this puts it to 1)
*
******************************/


program define cgmwildboot, eclass byable(onecall) sortpreserve
	syntax varlist [if] [in] [aweight fweight iweight pweight /], Cluster(varlist) bootcluster(varlist min=1 max=1) [null(string) reps(integer 1000) seed(numlist integer >=0) maxbad(integer 10) *]

	/* Temporary variables, etc */
	tempname depvar numx numxc tmpi tmpj tmpv b covmat depv xnull xlist xlistc tmpx tmpb tmpb tmpp opt tmat imat bmat e_NC e_S nbad numt p ig iy c1 c2 c3 c4 c5 ///
		bsb cH cL cN e_N e_df_m e_df_r e_title e_properties e_predict e_model e_estat_cmd e_r2 e_r2_a gmat nreps matnames colnames omit colN kC
	tempvar tmpy tmp pos we wy yhat ehat tmpx n regvar clusvar bootvar
	tempfile data

	capture which unique
	if _rc != 0 {
		di as error `"You need the unique command. You can obtain it by typing "findit unique" in Stata."'
		exit
		}

	
	preserve

	qui query memory
	if r(matsize)<2*`reps' {
		qui set matsize `=2*`reps''
		}

	/* Mark sample */
	marksample touse
	qui egen `regvar'=rowmiss(`varlist')
	qui egen `clusvar'=rowmiss(`cluster')
	qui egen `bootvar'=rowmiss(`bootcluster')
	qui replace `touse'=(`touse' & `regvar'==0 & `clusvar'==0 & `bootvar'==0)


	/* deal with weights */
	if "`weight'"~="" {
		local weight "[`weight'=`exp']"
	} 
	else {
		local weight ""
	}




	/* Clean up options */
	local `opt' "`options'"
	while ( regexm("``opt''","robust")==1 ) {

		di " -> Removing string 'robust' from your options line: it's unnecessary as an option,"
		di "    but it can cause problems if we leave it in."
		di "    If some variable in your options list contains the string 'robust', you will"
		di "    have to rename it."
		di 
		local `opt' = regexr("``opt''", "robust", "")

		} 



	while regexm("``opt''","cluster")==1 {
		local `opt'=regexr("``opt''","cluster","")
		}

	while regexm("``opt''","bootcluster")==1 {
		local `opt'=regexr("``opt''","bootcluster","")
		}


	/* Remove boot cluster from cluster list */

	while regexm("`cluster'","`bootcluster'")==1 {
		local cluster=regexr("`cluster'","`bootcluster'","")
		}

	scalar `e_NC'=wordcount("`cluster' `bootcluster'")

	/* Get regression coefficients */

	capture cgmreg `varlist' if `touse' `weight', cluster(`cluster' `bootcluster') ``opt''


	if _rc != 0 {
		di as error "Initial estimtation does not work with cgmreg. Try"
		di as error "cgmreg by itself to see what the problem is."
		exit
		}


	mat `b'=e(b)
	local `tmpx' : colnames `b'
	local `xlistc' : colnames `b'

	_ms_omit_info `b'
	matrix `omit' = r(omit) // Identify omitted variables

	/* Identify regressors */
	local `xlist' : subinstr local `tmpx' " _cons" ""

	local `numx' : word count ``xlist''

	if "`noconstant'"=="" {
		scalar `numxc'=``numx''+1
		}
	else {
		di as error "Sorry, this program does not allow the noconstant option."
		exit
		}


	/* Check for null hypothesis list */

	matrix `xnull'=J(1,`numxc',.)
	if "`null'" != "" {
		if wordcount("`null'") == ``numx'' {
			forvalues k=1(1)``numx'' {
				matrix `xnull'[1,`k']=real(word("`null'",`k'))
				}
			}
		else {
			di as error "Incorrect elements for null. Must contain ``numx''"
			di as error "elements, use missing (.) for regressors without null."
			exit
			}
		}



	mat `covmat'=J(`numxc',`numxc',0)
	mat rownames `covmat'= ``tmpx''
	mat colnames `covmat'= ``tmpx''
	scalar `e_df_r'=e(df_r)
	scalar `e_df_m'=e(df_m)
	local `depvar'=e(depvar)
	scalar `e_N'=e(N)
	scalar `e_S'=e(S)
	local `e_title'=e(title)
	local `e_properties'=e(properties)
	local `e_predict'=e(predict)
	local `e_model'=e(model)
	local `e_estat_cmd'=e(estat_cmd)
	scalar `e_r2'=e(r2)
	scalar `e_r2_a'=e(r2_a)


	/* Write initial t-stats */

	scalar `tmpi'=`numxc'+3
	matrix `tmat'=[1,0,1,J(1,`numxc',.)]
	matrix colnames `tmat'=iter src type ``xlistc''
	matrix `bmat'=`tmat'
	matrix `bmat'[1,3]=0
	
	forvalues j=1(1)`=`numxc'' {
		local `tmpj' : word `j' of ``xlistc''
		if missing(`xnull'[1,`j']) matrix `tmat'[1,`j'+3]=`b'[1,`j']/_se[``tmpj'']
		else matrix `tmat'[1,`j'+3]=(`b'[1,`j']-`xnull'[1,`j'])/_se[``tmpj'']

		matrix `bmat'[1,`j'+3]=`b'[1,`j']
		}

	/*
	* Generate variables with null imposed 
	* - The variable tmpx contains the imposed null
	* - The local tmpx contains the variables without an imposed null
	*/


	qui gen `tmpy'=``depvar''
	qui gen `tmpx'=0
	local `tmpx'=""
	forvalues k=1(1)``numx'' {
		local `tmpv' : word `k' of ``xlist''
		if missing(`xnull'[1,`k']) local `tmpx' "``tmpx'' ``tmpv''"
		else {
			qui replace `tmpy'=`tmpy'-`xnull'[1,`k']*``tmpv''
			qui replace `tmpx'=`tmpx'+`xnull'[1,`k']*``tmpv''
			}
		}

	qui reg `tmpy' ``tmpx'' if `touse' `weight', ``opt''
	qui predict `yhat' if `touse', xb
	qui predict `ehat' if `touse', resid
	qui replace `yhat'=`yhat'+`tmpx' if `touse'

	qui sort `bootcluster'
	qui save `data'


	/* Get number of clusters */

	scalar `tmpi'=wordcount("`cluster' `bootcluster'")
	matrix `gmat'=J(1,`tmpi',.)
	scalar `tmpi'=0
	foreach k in `cluster' `bootcluster' {
		scalar `tmpi'=`tmpi'+1
		qui unique `k' if `touse'
		matrix `gmat'[1,`tmpi']=_result(18)
		}


	/*  Begin bootstrap */

	scalar `nreps'=1
	_dots 0, title("Bootstrap reps") reps(`reps')
	_dots 1 0
	if "`seed'" ~= "" set seed `seed'
	scalar `nbad'=0
	scalar `tmpi' = 2
	while `=`tmpi''<=`reps' {
		qui use `data', replace
		qui by `bootcluster': gen `tmp'=uniform()
		qui by `bootcluster': gen `pos'=(`tmp'[1]<0.5)
		qui gen `we'=`ehat'*(2*`pos'-1)
		qui gen `wy'=`yhat'+`we'
		capture cgmreg `wy' ``xlist'' if `touse' `weight', ``opt'' cluster(`cluster' `bootcluster')
		if _rc==0 {
			scalar `tmpi' = `tmpi'+1
			_dots `tmpi' 0
			scalar `nreps'=`nreps'+1
			local `tmpx' : colnames e(b)
			matrix `tmat'=[`tmat' \ `nreps' ,1,1,J(1,`numxc',.)]
			matrix `bmat'=[`bmat' \ `nreps' ,1,0,J(1,`numxc',.)]
			forvalues j=1(1)`=`numxc'' {
				local `tmpj' : word `j' of ``tmpx''
				if missing(`xnull'[1,`j']) matrix `tmat'[`nreps',`j'+3]=(_b[``tmpj'']-`b'[1,`j'])/_se[``tmpj'']
				else matrix `tmat'[`nreps',`j'+3]=(_b[``tmpj'']-`xnull'[1,`j'])/_se[``tmpj'']
				matrix `bmat'[`nreps',`j'+3]=_b[``tmpj'']
				}
			scalar `nbad'=0
			}
		else if `nbad'<`maxbad' scalar `nbad'=`nbad'+1
		else {
			di as error "Number of failed regressions exceeded `maxbad' in a row"
			exit
			}

		qui drop `we' `wy'
		}


	
	/* End of bootstrap */

	/* Summarize and display results */
	matrix `tmat'=`tmat'[1..`nreps',1...]
	matrix `bmat'=`bmat'[1..`nreps',1...]
	matrix `tmat'=[ `tmat' \ `bmat' ]

	qui drop _all

	local `matnames' : colnames `tmat'

	foreach k of local `matnames' {
		_ms_parse_parts `k'
		if length("`r(level)'")==0 local `colN' `"`=r(name)'"'
		else local `colN' `"`=r(name)'_`r(level)'"
		local `colN' : subinstr local `colN' "_cons" "cons"
		local `colnames' "``colnames'' ``colN''"
		}

	*noisily di "``colnames''"


	matrix colnames `tmat' = ``colnames''

	qui svmat `tmat', names(col)


	/*

	Matrix has columns
		iter				Bootstrap iteration
		src				Original (0) or bootstrapped (1)
		type				Coefficient (0) or t-stat (1)
		<variable names>	Either coefficient or t-stat, depending on type

	*/

	local `ig' "in green"
	local `iy' "in yellow"
	local `c1' "_col(16) %10.0g"
	local `c2' "_col(28) %10.0g"
	local `c3' "_col(40) %10.0g"
	local `c4' "_col(52) %10.0g"
	local `c5' "_col(64) %10.0g"
	


	di
	di ``ig'' "Regress with clustered SEs/Wild bootstrap (" ``iy'' `=`nreps'' ``ig'' " successful resamples)"
	di ``ig'' "Number of clustvars" _column(20) "=" _column(21) %5.0f ``iy'' `=`e_NC'' ///
		``ig'' _col (50) "Number of obs" _col(64) "=" _column(66) %8.0f ``iy'' `=`e_N''
   	di ``ig'' "Num combinations" _column(20) "=" _column(21) %5.0f in yellow `=`e_S'' ///
		``ig'' _column(50) "R-squared" _column(64) "=" _column(66) %8.4f ``iy'' `=`e_r2''
	di ``ig'' _column(50) "Adj R-squared" _column(64) "=" _column(66) %8.4f ``iy'' `=`e_r2_a''

	if "`if'"~="" di in green _column(50) "If condition" _column(64) "= `if'"
	if "`in'"~="" di in green _column(50)     "In condition" _column(64) "= `in'"
	if "`weight'"~="" di in green _column(50) "Weights are" _column(64) "= `weight'"

	scalar `tmpi'=0
	foreach k in `cluster' `bootcluster' {
		scalar `tmpi' = `tmpi' + 1
		di _column(50) ``ig'' "G(`k')" _column(64) "=" _column(66) %8.0f ``iy'' `gmat'[1,`tmpi']
		tempname N_`=`tmpi'' NM_`=`tmpi''
		local `NM_`=`tmpi''' "`k'"
		scalar `N_`=`tmpi''' = `gmat'[1,`tmpi']
		} /* end getting num obs by cluster var */
	di _column(50) ``ig'' "(Bootstrapped)"


	di ``ig'' "{hline 12}{c TT}{hline 60}"
	di ``ig'' %12s abbrev("``depvar''",12) "{c |}" %12s "Coef." %12s "Null" %12s "p-value" %24s "[95% Conf. Interval]"
	di ``ig'' "{hline 12}{c +}{hline 60}"

	qui gen `n'=.

	forvalues k=1(1)`=`numxc'' {
		local `kC' = `k'+3
		local `tmpv' : word ``kC'' of ``colnames''

		if `omit'[1,`k']==0 {

			qui summ ``tmpv'' if type==1
			scalar `numt'=r(N)
			qui sort type ``tmpv''
			qui by type: replace `n'=_n
			/* Average observations if several close to observed t-stat */
			qui summ ``tmpv'' if type==1 & src==0
			scalar `tmpi'=r(mean)

			qui summ `n' if abs(``tmpv''-`tmpi') < 0.000001 & type==1
			scalar `p'=2*cond(`tmpi'<0,min(r(mean)/`numt',0.5),cond(`tmpi'>0,min(1-r(mean)/`numt',0.5),1,.),.)


			/* Fake covariance matrix and (real) confidence interval */
			/* Pick biggest/smallest if no match */
			qui summ ``tmpv'' if type==0 & src==0
			scalar `tmpi'=r(mean)
			mat `covmat'[`k',`k']=cond(`p'==0,1/maxfloat(),cond(`tmpi'==0 | `p'==1,maxfloat(),(`tmpi'/invttail(`e_df_r',`p'/2))^2,.),.)


			if `covmat'[`k',`k']==. mat `covmat'[`k',`k']=0
			qui summ `n' if type==0 & ~missing(``tmpv'')
			scalar `cL'=r(min)
			scalar `cH'=r(max)
			scalar `cN'=r(max)-r(min)+1
			qui summ ``tmpv'' if type==0 & `n'==floor(`cL'+0.025*(`cN'))
			if r(N)==0 {
				qui summ ``tmpv'' if type==0
				scalar `cL'=r(min)
				}
			else scalar `cL'=r(mean)
	
			qui summ ``tmpv'' if type==0 & `n'==ceil(`cH'-0.025*(`cN'))
			if r(N)==0 {
				qui summ ``tmpv'' if type==0
				scalar `cH'=r(max)
				}
			else scalar `cH'=r(mean)
			di ``ig'' %12s abbrev("``tmpv''",12) "{c |}" ``iy'' ``c1'' `b'[1,`k'] ``c2'' `xnull'[1,`k'] ``c3'' `p' ``c4'' `cL' ``c5'' `cH'
			}
		else {
			di ``ig'' %12s abbrev("``tmpv''",12) "{c |}" ``c1'' "(dropped)"
			}
		}

	di ``ig'' "{hline 12}{c BT}{hline 60}"


	/* Post results */
	qui use `data', clear

	ereturn post `b' `covmat', e(`touse') depname(``depvar'')

	ereturn scalar N		= `e_N'
	ereturn scalar df_m	= `e_df_m'
	ereturn scalar df_r	= `e_df_r'
	ereturn scalar r2		= `e_r2'
	ereturn scalar r2_a	= `e_r2_a'
	ereturn scalar nreps	= `nreps'
	ereturn scalar NC		= `e_NC'
	ereturn scalar S		= `e_S'
	forvalues k=1(1)`=`e_NC'' {
		ereturn scalar N_``NM_`k''' = `N_`k''
		}
	
	ereturn local title		= "``e_title''"
	ereturn local depvar		= "``depvar''"
	ereturn local cmd			= "cgmwildboot"
	ereturn local properties	= "``e_properties''"
	ereturn local predict		= "``e_predict''"
	ereturn local model		= "``e_model''"
	ereturn local estat_cmd		= "``e_estat_cmd''"
	ereturn local vcetype		= "FAKE"
	ereturn local clustvar		= trim("`cluster' `bootcluster'")
	ereturn local bootclust		= "`bootcluster'"

	ereturn matrix bootresults=`tmat'

	restore

end
