program testjfe, rclass
	version 13
	local version
	/*
	PROGRAM: testjfe.ado
	PROGRAMMER: Brigham Frandsen
	DATE: August 9, 2018
	PURPOSE: implement semiparametric version of judge fixed effects test
	
	*/
	
	syntax varlist (min=3 numeric) [if] [in], [numknots(integer 3) COVariates(varlist numeric) CRossvalidate DISPgamma FITweight(real .5) GRaph GENerate(namelist min=3 max=3)]
	
	* varlist should be: depvar treatvar excludedinstruments
	tokenize `varlist'
	local y "`1'"
	macro shift
	local d "`1'"
	macro shift
	local w "`*'"
	
	if "`generate'"!="" | "`graph'"!="" {
		if "`generate'"!="" {
			confirm new variable `generate'
			tokenize `generate'
			local eyjvar `1'
			local pjvar `2'
			local fitvar `3'		
		}
		else {
			tempvar eyjvar pjvar fitvar
		}
		tempvar judge
		egen `judge'=group(`w')
	
	}
	
	tempfile goback
	tempvar phat vhat constant zeros uuhat uhat phatorth
	tempname slopevar psi1 psi2 Sigma augknotvector survivingplus survivingminus corrmat ztrans0 ztrans pvalue2 stem dstem knotvector bhat gammahat deltahat Qx Qxinv Qw Qwinv X W Deltamat Deltadeltahat ///
	G G1 G2 S1 S21 S22 S2 S varhat Omegahat Gamma quadform phatfreqs Aorth numesses mylist means rmsecurr rmsemin
	
	* quadratic b-spline: "order" 3
	local m = 3
	local degree=`m'-1
	* number of internal knots:
	local N = `numknots'
	* number of normal draws to simulate slope-based test statistic
	local numsims=9999
	* weight for fit vs slope
	local weight1 =`fitweight'
	local weight2 = 1-`weight1'
	display "weight1 = `weight1', weight2 = `weight2'"
	
	
	marksample touse
	preserve
	qui keep if `touse'
	qui _rmcoll `covariates',forcedrop
	local covariates `r(varlist)'
	qui _rmcoll `w' `covariates',forcedrop
	local wcovs `r(varlist)'
	local wnew : list wcovs - covariates
	local w `wnew'
	
	
	local n = _N
	*get Lipschitz constant:
	qui sum `y'
	local lip=r(max)-r(min)
	* define restricted instrument set
	local k=0
	foreach var of varlist `w' {
		local ++ k
		local w`k' `var'
	}
	
	* generate propensities
	qui reg `d' `w' `covariates'
	qui predict `phat'
	qui replace `phat'=max(0,min(1,`phat'))
	predict `vhat',resid
	
	* prepare judge-level propensities for graphing and saving
	if "`graph'"!="" | "`generate'"!="" {
		tempvar xbd
		gen `xbd'=0
		foreach var of varlist `covariates' {
			qui replace `xbd'=`xbd'+`var'*_b[`var']
		}
		qui sum `xbd'
		qui gen `pjvar'=`d'-`xbd'+r(mean)
	}
	
	qui save `goback',replace

	collapse `y',by(`phat')

	local numphats = _N
	use `goback',clear
	local Nmax=min(`numphats'-`m',`k'-1)

	
	
	if "`crossvalidate'"!="" {
		display "performing cross validation"
		
		* cross validate to see the number of terms that minimizes RMSE
		scalar `rmsemin'=.
		forvalues knots=1/`Nmax' {
			* generate splineterms
			* get list of quantiles
			local lb=100/(`knots'+1)
			local step = 100/(`knots'+1)
			local ub = 100*`knots'/(`knots'+1)
			qui centile `phat' if `phat'>=.01 & `phat'<=.99,centile(`lb'(`step')`ub')
			local newterm = r(c_1)
			matrix `knotvector' = `newterm'
			local knotlist `newterm'
			forvalues i = 2/`knots' {
				local newterm = r(c_`i')
				matrix `knotvector' = `knotvector',`newterm'
				local knotlist `knotlist' `newterm'
			}
			mybspline `phat' `degree' `knotvector' `stem'
			
			capture qui crossfold reg `y' `covariates' `stem'*
			if _rc==199 {
				display "crossfold required in order to cross-validate the spline fit; please run ssc install crossfold"
				error 199
			}
			mata st_numscalar("`rmsecurr'",mean(st_matrix("r(est)")))
			if `rmsecurr'<`rmsemin' {
				scalar `rmsemin'=`rmsecurr'
				local mcv = `knots'
			}
			display "number of knots = `knots', rmse = " `rmsecurr'
			drop `stem'*
		}
		display "cross-validated number of knots is `mcv'"
		local N = `mcv'
	}
	local origN=`N'
	forvalues currN =`origN'(-1)1 {
		local N = `currN'
		local lb=100/(`N'+1)
		local step = 100/(`N'+1)
		local ub = 100*`N'/(`N'+1)
		qui centile `phat' if `phat'>=.01 & `phat'<=.99,centile(`lb'(`step')`ub')
		local newterm = r(c_1)
		matrix `knotvector' = `newterm'
		local knotlist `newterm'
		forvalues i = 2/`N' {
			local newterm = r(c_`i')
			matrix `knotvector' = `knotvector',`newterm'
			local knotlist `knotlist' `newterm'
		}
		mybspline `phat' `degree' `knotvector' `stem'
		mybspline `phat' `degree' `knotvector' `dstem' deriv
		local splineseries
		local Delta
		local topterm = `N'+`degree'
		forvalues j = 0/`topterm' {
			local splineseries `splineseries' `stem'`j'
			local Delta `Delta' `dstem'`j'
		}
		* degree of "overidentification"
		local ktilde = `k'-`N'-`degree'
		
		* get number of covariates (if any)
		local numcovs=0
		if "`covariates'"!= "" {
			foreach var of varlist `covariates' {
				local ++ numcovs
			}
		}
		
	
		*main regression:
		qui reg `y' `covariates' `splineseries',noconst
		local regvars: colnames e(b)
		local numvar: word count `regvars'
		
		if "`graph'"!="" | "`generate'"!="" {
			tempname splinecoeffs
			matrix `splinecoeffs'=0
			foreach var of varlist `splineseries' {
				matrix `splinecoeffs'= _b[`var'],`splinecoeffs'
			}
		}
		
		* find series terms actually included
		local splineseries
		local numsplineseries=0
		local collinearity=0
		local start=`numcovs'+1
		local end=`numcovs'+`N'+`m'
		forvalues ctr = `start'/`end' {
			local var :word `ctr' of `regvars'
			if substr("`var'",1,2)=="o." {
				local collinearity=1
				continue,break
			}
			local splineterm`numsplineseries' `var'
			local ++ numsplineseries
			local splineseries `splineseries' `var'
		}
		if `collinearity'==0 continue,break
		else {
			display "collinearity with number of knots specified; reducing number of knots by one"
			drop `stem'* `dstem'*
		}		
	}
	display "Number of knots = `N'"
	gen `constant'=1
	if `numsplineseries'< `N'+`m' {
		display "Numerical collinearity in spline; changing number of terms to `numsplineseries'"
	}
	
	qui reg `y' `covariates' `splineseries',noconst
	predict `uhat',resid
	mat `deltahat' = e(b)
	mat `deltahat' = `deltahat''
	mat `deltahat' = `deltahat'[`numcovs'+1..`numcovs'+`numsplineseries',1]
	
	qui reg `uhat' `w' `covariates'
	
	if "`graph'"!="" | "`generate'"!="" {
		tempvar xbu
		gen `xbu'=0
		foreach var of varlist `covariates' {
			qui replace `xbu'=`xbu'+`var'*_b[`var']
		}
		qui sum `xbu'
		gen `eyjvar' = `uhat'-`xbu'+r(mean)
	}
	
	predict `uuhat',resid
	mat `bhat'=e(b)
	mat `bhat'=`bhat''
	mat `gammahat'=`bhat'[1..`k',1]
	if "`dispgamma'"!="" {
		display "judge dummy coefficients:"
		mat li `gammahat'
	}
	qui mat accum `Qx' = `covariates' `splineseries',noconst
	mat `Qxinv'=invsym(`Qx')
	
	qui mat accum `Qw' = `w' `covariates'
	mat `Qwinv'=invsym(`Qw')
	// bring in variables as vectors and matrices
	mata `X'=(st_data(.,"`covariates' `splineseries'"))
	mata `uhat'=st_data(.,"`uhat'")
	mata `uuhat'=`uhat'
	mata `W'=st_data(.,"`w' `covariates' `constant'")
	mata `vhat'=st_data(.,"`vhat'")
	mata `Deltamat'=st_data(.,"`Delta'")
	mata `Qwinv'=st_matrix("`Qwinv'")
	mata `Qxinv'=st_matrix("`Qxinv'")
	mata `deltahat'=st_matrix("`deltahat'")
	
	mata `Deltadeltahat'=`Deltamat'*`deltahat'
	mata mata drop `deltahat'
	mata `G1' = (`W':*`Deltadeltahat')'*`W'
	
	mata `G2' = (`X')'*`W'
	
	mata `G'=((`W':*`Deltadeltahat'),`X')'*`W'
	mata mata drop `Deltadeltahat'
	mata `S1'=`W':*`uuhat'
	mata mata drop `uuhat'
	mata `S21'=(`W':*`vhat')*`Qwinv''
	mata `S22'=(`X':*`uhat')*`Qxinv''
	
	*mata `S2' = (`S21',`S22')*`G'
	mata `S2' = (`S21'*`G1')+(`S22'*`G2')
	mata mata drop `G1' `G2'
	
		mata `S'=`S1'-`S2'
	
	
	mata `means'=mean(`S',1)
	mata `varhat'=quadcrossdev(`S',`means',`S',`means')
	mata `Omegahat'=`Qwinv'*`varhat'*`Qwinv''
	mata _makesymmetric(`Omegahat')
	mata st_matrix("`Omegahat'",`Omegahat')	

	mat `Gamma' = I(`k'),J(`k',`numcovs'+1,0)
	mat `quadform'=(`Gamma'*`bhat')'*invsym(`Gamma'*`Omegahat'*`Gamma'')*`Gamma'*`bhat'
	
	* calculate pvalue
	local teststat = abs(`quadform'[1,1])
	if float(`quadform'[1,1])<float(`teststat') {
		display "Warning: numerical precision issues may make test unreliable " `quadform'[1,1]
		return local numericalissues = 1
	}
	else return local numericalissues = 0
	local pvalue1=1-chi2(`ktilde',`teststat')
	local pfitstr= "fit-based p-value: " +string(`pvalue1',"%5.3f")
	* get slope-based p-value
	mata `S1'=`X':*`uhat'
	mata mata drop `X' `uhat'
	mata `S21'=rowsum((`W'*`Qwinv'):*`W')
	mata mata drop `W' `Qwinv'
	mata `S22'=(J(`n',`numcovs',0),`Deltamat'):*`S21'
	mata mata drop `Deltamat' `S21'
	mata `S2' = `S22':*`vhat'
	mata `S'=`S1'-`S2'
	mata mata drop `S1' `S2' `S22' `vhat'
	mata `means'=mean(`S',1)
	
	mata `varhat'=quadcrossdev(`S',`means',`S',`means')
	mata mata drop `S'
	mata `Sigma'=`Qxinv'*`varhat'*`Qxinv''
	mata mata drop `Qxinv' `varhat' `means'
	mata _makesymmetric(`Sigma')
	mata st_matrix("`Sigma'",`Sigma')
	* transform into the varcov matrix of the estimated slopes
	mata `psi1' = J(`N'+`m'-1,`numcovs'+1,0),I(`N'+`m'-1)
	mata `psi2' = J(`N'+`m'-1,`numcovs',0),I(`N'+`m'-1),J(`N'+`m'-1,1,0)
	mata `slopevar'=(`psi1'-`psi2')*`Sigma'*(`psi1'-`psi2')'
	mata mata drop `psi1' `psi2'
	mata _makesymmetric(`slopevar')
	* generalized moment selection:
	* augment internal knots with 0 and 1:
	matrix `augknotvector' = 0,0,0,`knotvector',1,1,1
	local topterm = `N'+3
	local mmm=0
	mata `survivingplus'= J(1,0,.)
	mata `survivingminus'=J(1,0,.)
	forvalues i = 2/`topterm' {
		local im1=`i'-1
		local im2 = `i'-2
		local slope`i'=2/(`augknotvector'[1,`i'+1+1]-`augknotvector'[1,`i'-1+1])*(`deltahat'[`im1'+1,1]-`deltahat'[`im2'+1,1])
		local ind1 = `numcovs'+`im2'+1
		local ind2 = `numcovs'+`im1'+1
		local se`i' = 2/(`augknotvector'[1,`i'+1+1]-`augknotvector'[1,`i'-1+1])*sqrt(`Sigma'[`ind2',`ind2']+`Sigma'[`ind1',`ind1']-2*`Sigma'[`ind1',`ind2'])
		local minust`i' = (`lip'-`slope`i'')/`se`i''
		if `minust`i'' <= 0 local mmm=`mmm'+(`minust`i'')^2
		mata `survivingminus'=`survivingminus',`minust`i'' <= sqrt(ln(`n'))
		local plust`i' = (`lip'+`slope`i'')/`se`i''
		if `plust`i'' <= 0 local mmm=`mmm'+(`plust`i'')^2
		mata `survivingplus'=`survivingplus',`plust`i'' <= sqrt(ln(`n'))
	}
	mata mata drop `Sigma'
	* create correlation matrix
	mata `corrmat' = sqrt(diag(1:/diagonal(`slopevar')))*`slopevar'*sqrt(diag(1:/diagonal(`slopevar')))
	* simulate a gaussian vector with given correlation:
	mata `ztrans0' = rnormal(`numsims',`N'+2,0,1)*cholesky(`corrmat')'
	mata mata drop `corrmat' `slopevar'
	mata `ztrans'=select(`ztrans0',`survivingminus'),-select(`ztrans0',`survivingplus')
	mata `pvalue2'=mean(rowsum((`ztrans':*(`ztrans':<0)):^2):>=`mmm')
	mata mata drop `ztrans' `ztrans0' `survivingplus' `survivingminus'
	mata st_numscalar("`pvalue2'",`pvalue2')
	local pslopestr="slope-based p-value: " +string(`pvalue2',"%5.3f")
	
	if "`graph'"!="" | "`generate'"!="" {
		collapse `pjvar' `eyjvar',by(`judge')
		drop `judge'
		mybspline `pjvar' `degree' `knotvector' `stem'
		local splineseries
		local topterm = `N'+`degree'
		forvalues j = 0/`topterm' {
			local splineseries `splineseries' `stem'`j'
		}
		gen `fitvar'=0
		local ii=0
		foreach var of varlist `splineseries' {
			local ++ ii
			qui replace `fitvar'=`fitvar'+`var'*`splinecoeffs'[1,`ii']
		}
		qui replace `eyjvar' = `eyjvar'+`fitvar'
		sort `pjvar'
		if "`graph'"!="" {
			twoway (scatter `eyjvar' `pjvar') (line `fitvar' `pjvar'),title("Average outcome by treatment propensity") xtitle("treatment propensity") legend(order(1 "average outcomes" 2 "spline fit"))
		}
		tempfile fits
		qui save `fits'
	}
	
	restore
	local pvalue = min(`pvalue1'/`weight1',`pvalue2'/(1-`weight1'),1)
	return scalar pval = `pvalue'
	return scalar chi2 = `teststat'
	return scalar df = `ktilde'
	
	local pvalstr="combined p-value = " + string(`pvalue',"%5.3f") 
	local tsstr="fit test statistic = " +string(`teststat',"%5.3f")
	local dfstr="fit degrees of freedom = " +string(`ktilde',"%5.3f")
	display _n
	display "Monotonicity and Exclusion Test Results" _n
	display "`pfitstr'" _n
	display "`pslopestr'" _n
	display "`pvalstr'"
	
	if "`generate'"!="" {
		qui merge 1:1 _n using `fits'
		drop _merge
		label variable `eyjvar' "(generated by testjfe) instrument-level residualized average outcome"
		label variable `pjvar' "(generated by testfje) instrument-level residualized treatment propensity"
		label variable `fitvar' "(generated by testjfe) spline fit of average outcomes on treatment propensity"

	}
	
end

/*START HELP FILE

title[Test for instrument validity in the judge fixed effects design]

desc[
{cmd:testjfe} jointly tests the exclusion and monotonicity assumptions invoked in instrumental variables estimation of treatment effects when treatment is a binary indicator and the instruments are a set of mutually exclusive dummy variables. 
Stata command crossfold must be installed.
]

opt[numknots() specifies the number of knots in a the quadratic spline specification of the relationship between the outcome and the instrument propensity]
opt[covariates() specifies variables to be added as linear controls to the regressions calculating instrument propensities and the reduced from regression of outcomes on the instruments]
opt[crossvalidate specifies that the number of knots should be chosen by cross validation]
opt[dispgamma specifies that the reduced form coefficients on the instrument dummies should be displayed]
opt[fitweight() specifies the relative weight that should be placed on the fit component of the test as opposed to the slope component of the test. For designs with many judges, higher weight on fit will yield a more powerful test.]
opt[generate() specifies that judge-level average outcomes, propensities, and the spline-based fit be generated, and gives the names of the variables to be generated. Three variable names are required, in the following order: average outcome, propensity, fit. These variables should not already exist in the data in memory.]
opt[graph specifies that a graph be produced showing judge-level average outcomes by judge-level propensity, with the spline-based fit superimposed.]

example[
testjfe outcome treatment judgeid*, covariates(x*) fitweight(1) generate(ybar pbar yfit) graph
]

author[Dr. Brigham Frandsen]
institute[Brigham Young University]
email[frandsen@byu.edu]

return[pval p-value]
return[chi2 chi-squared test statistic from the fit component of the test]
return[df degrees of freedom from the fit component of the test]

seealso[
{help crossfold} (if installed)  {stata ssc install crossfold} (to install this command)
]


references[
Frandsen, Brigham R., Lars Lefgren, Emily Leslie (2020). Judging Judge Fixed Effects. NBER Working Paper No. 25528.
]

END HELP FILE
*/
