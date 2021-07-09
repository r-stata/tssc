*! version 2.0.1  27jul2013  Michael Stepner, stepner@mit.edu

/* CC0 license information:
To the extent possible under law, the author has dedicated all copyright and related and neighboring rights
to this software to the public domain worldwide. This software is distributed without any warranty.

This code is licensed under the CC0 1.0 Universal license.  The full legal text as well as a
human-readable summary can be accessed at http://creativecommons.org/publicdomain/zero/1.0/
*/

* Why did I include a formal license? Jeff Atwood gives good reasons: http://www.codinghorror.com/blog/2007/04/pick-a-license-any-license.html


program define vam
	
	version 10.1

	set more off

	syntax varname(ts fv), teacher(varname) year(varname) class(varname) [ ///
		by(varlist) ///
		controls(varlist ts fv) absorb(varname) tfx_resid(varname) ///
		data(string) output(string) output_addvars(varlist) ///
		driftlimit(integer -1) ///
		QUASIexperiment]

	* Error checks
	local depvar `varlist'
	
	capture confirm variable score_r, exact
	if (_rc==0) {
		di as error "The dataset loaded in memory when vam is run cannot have a variable named score_r."
		exit 110
	}
	
	capture confirm variable tv, exact
	if (_rc==0) {
		di as error "The dataset loaded in memory when vam is run cannot have a variable named tv."
		exit 110
	}
	
	if ("`quasiexperiment'"!="") {
		capture confirm variable tv_2yr_l, exact
		if (_rc==0) {
			di as error "The dataset loaded in memory when vam is run cannot have a variable named tv_2yr_l."
			exit 110
		}
		
		capture confirm variable tv_2yr_f, exact
		if (_rc==0) {
			di as error "The dataset loaded in memory when vam is run cannot have a variable named tv_2yr_f."
			exit 110
		}
		
		capture confirm variable tv_ss, exact
		if (_rc==0) {
			di as error "The dataset loaded in memory when vam is run cannot have a variable named tv_ss."
			exit 110
		}
	}
	
	local merge_tv=0
	local merge_resid=0
	if ("`data'"=="") local data="preserve"
	else {
		if !inlist("`data'","preserve","tv","merge tv","merge score_r","merge tv score_r","merge score_r tv","variance") {
			di as error "Not a valid argument for data. Choose either 'preserve', 'tv', 'merge [tv AND/OR score_r]', or 'variance'."
			exit 198
		}
		else {
			tokenize "`data'"
			if ("`1'")=="merge" {
				if ("`2'"=="tv") | ("`3'"=="tv") local merge_tv=1
				if ("`2'"=="score_r") | ("`3'"=="score_r") local merge_resid=1
			}
		}
	}	
	
	if "`tfx_resid'"!="" & "`absorb'"!="" {
		di as error "Cannot specify an absorb variable and a tfx_resid variable simultaneously."
		exit 198
	}
	
	* If output was left blank, set a tempfile for the tv output
	if `"`output'"'=="" {
		tempfile output
		local nooutput=1
	}
	else local nooutput=0
	
	* Start log
	if (`nooutput'!=1) log using `"`output'_log"', replace
	
	* Process by variables
	if ("`by'"!="") {
		tempvar byvar
		egen `byvar'=group(`by'), label
		sum `byvar', meanonly
		local by_vals=`r(max)'
	}
	else local by_vals=1

	****************
	
	preserve
	
	*** Run through separately for each by-value.
	local firstloop=1
	forvalues l=1/`by_vals' {
	
		if (`firstloop'!=1) restore, preserve
		
		*** Print heading (with by-variable identifier if applciable)
		di "{txt}{hline}"
		if ("`by'"!="") {
			local bylabel : label `byvar' `l', strict
			di "{bf:-> by variables:} `by' = `bylabel'"
		}

		*** Drop invalid observations ***
		qui drop if missing(`teacher',`year',`class')

		*** Keep only the correct by-value
		if ("`by'"!="") qui keep if `byvar'==`l'
		
		*** Run regression
		
		* If absorb or tfx_resid is not empty (only one is non-empty, otherwise an error was thrown), use areg 
		if "`absorb'"!="" | "`tfx_resid'"!="" {
			qui areg `depvar' `controls' , absorb(`absorb'`tfx_resid')
		}
		* If absorb and tfx_resid are both empty, run regular regression
		else {
			qui reg `depvar' `controls'
		}
		
		*** Predict residuals
		
		* If tfx_resid is empty, predict residuals
		if "`tfx_resid'"=="" {
			qui predict score_r if e(sample),r 
		}
		* If tfx_resid was specified, predict residuals + absorbed teacher fixed effects
		else {
			qui predict score_r if e(sample), dresiduals
		}
		
		*** Save residuals to a dataset if merging them later
		if `merge_resid'==1 {
			tempfile resid_data_`l'			
			qui save `"`resid_data_`l''"', replace
		}

		*** Save number of parameters
		
		tempname num_obs num_par
		
		scalar `num_obs' = e(N)

		* If absorb is not empty (and tfx_resid is), save (number of slopes + number of clusters + 1)
		if "`absorb'"!="" {
			scalar `num_par' = e(df_m) + e(df_a) + 1
		}
		* Otherwise, save (number of slopes + 1)
		else {
			scalar `num_par' = e(df_m) + 1
		}

		*** Create var for number of students in class
		tempvar n_tested
		qui bys `teacher' `year' `group' `class': egen `n_tested' = count(score_r)

		*** Compute total variance ***
		tempvar class_mean index
		qui by `teacher' `year' `group' `class': egen `class_mean' = mean(score_r) 
		qui by `teacher' `year' `group' `class': g `index' = _n

		tempname var_total
		qui sum score_r
		scalar `var_total' = r(Var)*((`num_obs' - 1)/(`num_obs' - `num_par'))
		
		*** Compute individual variance (i.e. within class variance)
		*--> note that we use rmse instead of direct variance of residuals here to deal with fact that class effects have not been shrunk
		tempname num_class var_ind var_class

		tempvar individual_dev_from_class
		qui gen `individual_dev_from_class' = score_r - `class_mean'
		
		qui count if `index'==1 & `n_tested'!=0
		scalar `num_class' = r(N)

		qui sum `individual_dev_from_class'
		scalar `var_ind' = r(Var)*((`num_obs' - 1)/(`num_obs' - `num_class' - `num_par' + 1))


		********** Collapse to class-level data **********
		
		qui by `teacher' `year' `group' `class': keep if _n==1

	
		*** Estimate covariance of two classes taught by same teacher in the same year
		set seed 9827496
		tempvar rand classnum
		g `rand'=uniform()
		bys `teacher' `year' (`rand'): gen `classnum'=_n
		
		* If there are multiple classes per teacher-year cell, compute the covariance.
		* Otherwise set to 0. Will display as missing in output, but internally set to 0 because it will never appear in the VCV, but the way things are coded requires that it be non-missing.
		tempname cov_sameyear corr_sameyear obs_sameyear
		qui sum `classnum'
		if (r(max)==1) {
			local missing_sameyear=1
			scalar `cov_sameyear'=0
		}
		else {
			local missing_sameyear=0
			tempvar identifier
			egen `identifier'=group(`teacher' `year')
			qui tsset `identifier' `classnum'/*, noquery*/
			qui corr `class_mean' f.`class_mean' [aw=`n_tested'+f.`n_tested'], cov
			scalar `cov_sameyear'=r(cov_12)
			scalar `corr_sameyear'=r(cov_12) / ( sqrt(r(Var_1)) * sqrt(r(Var_2)) )
			scalar `obs_sameyear'=r(N)
		}
		
		*** Compute the variance of the class-level shock.  Hits all kids in the class in the same way, but is unrelated across classes even taught by the same teacher in the same year.
		scalar `var_class' = `var_total' - `var_ind' - `cov_sameyear'
		if (`var_class'<0) {
			di as error "Note: var_class has been computed as being less than 0."
			di "var_class is defined as = var_total - var_ind - cov_sameyear."
			di "Computed variances: var_total, var_ind, cov_sameyear, var_class"
			di `var_total',`var_class',`var_ind',`cov_sameyear'
			di "This negative variance can occur because cov_sameyear is calculated using only the subsample of observations that teach multiple classes per year (in the same by-group)."
		}
		
		tempvar weight
		qui g `weight'=1/(`var_class' + `var_ind'/`n_tested')
		
		*** Keep teacher-years which have no weight
		
		tempvar excess_weight
		qui gen `excess_weight'=(missing(`weight'))

		qui replace `weight'=1 if missing(`weight')
		* note: adding this weight doesn't affect the class_mean, because missing observations are not included in the mean computation.  it only affects the rawsum of weight, and so we remove it afterward.

		
		********** Collapse to teacher-year level data using precision weights **********
		collapse (mean) `class_mean' (rawsum) `weight' `n_tested' `excess_weight' [aw=`weight'], by(`teacher' `year' `by') fast
		
		* Remove the excess weight used to keep missing scores
		qui replace `weight'=`weight'-`excess_weight'
		
		*** Estimate the covariance of years t and t+i for every i, and store in vector m
		qui tsset `teacher' `year'/*, noquery*/
		
		tempvar minyear maxyear diff validyear minvalidyear maxvalidyear diffvalid
		
		qui bys `teacher': egen `minyear'=min(`year')
		qui by `teacher': egen `maxyear'=max(`year')
		qui g `diff'=`maxyear'-`minyear'
		qui sum `diff'
		local maxspan=`r(max)'
		
		qui gen `validyear'=`year' if !missing(`class_mean')
		qui by `teacher': egen `minvalidyear'=min(`validyear')
		qui by `teacher': egen `maxvalidyear'=max(`validyear')
		qui g `diffvalid'=`maxvalidyear'-`minvalidyear'
		qui sum `diffvalid'
		local maxscorespan=`r(max)'
		
		if (`maxscorespan'<`maxspan') & (`driftlimit'<=0) {
			di as error _n	"error: The maximum lags of teacher data is `maxspan', but the maximum lags of teacher data with class scores is `maxscorespan'."
			di as error		"       You must either set driftlimit() <= `maxscorespan', or drop observations so that the spans are no longer mismatched."
			exit 499
		}
		if (`driftlimit'>`maxscorespan') {
			di as error "error: driftlimit(`driftlimit') was specified, which is greater than the number of lags (`maxscorespan') in the data."
			exit 499
		}
		
		mata:CC=compute_cov_corr("`class_mean'","`n_tested'",`maxscorespan',"`teacher'")
		
		if (`driftlimit'>0)	mata:m=create_m(CC[.,1],st_numscalar("`cov_sameyear'"),`maxspan',`driftlimit')
		else				mata:m=create_m(CC[.,1],st_numscalar("`cov_sameyear'"))
		
		*** Print estimated variances and covariances		
		di "Standard deviations: total, classes, students, teachers same year"
		if (`missing_sameyear'==0) di sqrt(`var_total'),sqrt(`var_class'),sqrt(`var_ind'),sqrt(`cov_sameyear')
		else di sqrt(`var_total'),sqrt(`var_class'),sqrt(`var_ind'),.
		
		di "Covariances (left), correlations (middle), observations (right).  Row i indicates the relation between year t and t+i:"
		mata:CC[.,1..3]
		
		if (`driftlimit'>0) {
			di "Drift limit specified:"
			di `driftlimit'
			
			di "Covariances used for VA computations:"
			mata: m[2..length(m)]'
		}
		
		mata:check_m_nomissing(m)
		
		*** Accumulate the estimated variances/covariances/correlations across by-vals
		if (`firstloop'==1) {
			mata:cov_lag_accum= CC[.,1]
			mata:corr_lag_accum= CC[.,2]
			mata:obs_lag_accum= CC[.,3]
			mata:cov_se_lag_accum= CC[.,4]
			mata:var_total_accum=	st_numscalar("`var_total'")
			mata:var_class_accum=	st_numscalar("`var_class'")
			mata:var_ind_accum=	st_numscalar("`var_ind'")
			
			if (`missing_sameyear'==1) {
				mata:cov_sameyear_accum=.
				mata:corr_sameyear_accum=.
				mata:obs_sameyear_accum=0
			}
			else {
				mata:cov_sameyear_accum=st_numscalar("`cov_sameyear'")
				mata:corr_sameyear_accum=st_numscalar("`corr_sameyear'")
				mata:obs_sameyear_accum=st_numscalar("`obs_sameyear'")
			}
		}
		else {
			mata:cov_lag_accum=		rightAppendMatrices(cov_lag_accum,CC[.,1])
			mata:corr_lag_accum=	rightAppendMatrices(corr_lag_accum,CC[.,2])
			mata:obs_lag_accum=		rightAppendMatrices(obs_lag_accum,CC[.,3])
			mata:cov_se_lag_accum=	rightAppendMatrices(cov_se_lag_accum,CC[.,4])
			mata:var_total_accum=	var_total_accum,st_numscalar("`var_total'")
			mata:var_class_accum=	var_class_accum,st_numscalar("`var_class'")
			mata:var_ind_accum=		var_ind_accum,st_numscalar("`var_ind'")
			
			if (`missing_sameyear'==1) {
				mata:cov_sameyear_accum= cov_sameyear_accum,.
				mata:corr_sameyear_accum= corr_sameyear_accum,.
				mata:obs_sameyear_accum= obs_sameyear_accum,.
			}
			else {
				mata:cov_sameyear_accum=cov_sameyear_accum,st_numscalar("`cov_sameyear'")
				mata:corr_sameyear_accum=corr_sameyear_accum,st_numscalar("`corr_sameyear'")
				mata:obs_sameyear_accum=obs_sameyear_accum,st_numscalar("`obs_sameyear'")
			}
		}
		
		*********
			
		* Count the number of obs for each teacher
		sort `teacher' `year'
		tempvar obs_teacher
		by `teacher': egen `obs_teacher'=count(`teacher')

		* Compute teacher VA
		qui gen float tv=.
		
		if "`quasiexperiment'"!="" {
			qui gen float tv_2yr_l=.
			qui gen float tv_2yr_f=.
			qui gen float tv_ss=.
			
			mata: driftcalclist(vectorToStripeDiag(m), "`teacher'", "`year'", "`class_mean'", "`weight'", "`obs_teacher'", "tv", "tv_2yr_l", "tv_2yr_f", "tv_ss")
		}
		else mata:driftcalclist(vectorToStripeDiag(m), "`teacher'", "`year'", "`class_mean'", "`weight'", "`obs_teacher'", "tv")
		
	
		* Save the VA estimates to a dataset
		if ("`quasiexperiment'"=="") keep `teacher' `year' `by' tv
		else keep `teacher' `year' `by' tv tv_2yr_l tv_2yr_f tv_ss
		
		if (`firstloop'!=1) append using `"`output'"', nolabel
		qui save `"`output'"', replace

		* Turn firstloop counter off
		local firstloop=0
	}
	
	di "{txt}{hline}"
	
	* Save VA estimates
	if "`output_addvars'"!="" quietly {
		restore, preserve
		keep `teacher' `year' `by' `output_addvars' 
		bys `teacher' `year' `by' `output_addvars': keep if _n==1
		merge m:1 `teacher' `year' `by' using `"`output'"', nogen nolabel
	}
	sort `teacher' `year' `by'
	qui save `"`output'"', replace
	
	* Save "variances / covariances / correlations" dataset to csv
	if ("`by'"!="") {
		local bylabels=""
		forvalues i=1/`by_vals' {
			local bylabel : label `byvar' `i', strict
			local bylabel=subinstr("`bylabel'"," ","_",.)
			local bylabels `bylabels' _`bylabel'
		}
		mata:saveVariancesToDataset(cov_lag_accum, corr_lag_accum, obs_lag_accum, cov_se_lag_accum, var_total_accum, var_class_accum, var_ind_accum, cov_sameyear_accum, corr_sameyear_accum, obs_sameyear_accum, tokens(st_local("bylabels")))
	}
	else mata:saveVariancesToDataset(cov_lag_accum, corr_lag_accum, obs_lag_accum, cov_se_lag_accum, var_total_accum, var_class_accum, var_ind_accum, cov_sameyear_accum, corr_sameyear_accum, obs_sameyear_accum, "")
	if (`nooutput'!=1) qui outsheet using `"`output'_variance.csv"', comma replace
	
	* Load the correct output dataset
	tokenize "`data'"
	if inlist("`1'","preserve","merge") {
		restore
		
		if (`merge_resid'==1) {
			if ("`byvar'"!="") qui keep if missing(`teacher',`year',`class',`byvar')
			else qui keep if missing(`teacher',`year',`class')
			forvalues l=1/`by_vals' {
				append using `"`resid_data_`l''"', nolabel
			}
		}
		if (`merge_tv'==1) qui merge m:1 `teacher' `year' `by' `output_addvars' using `"`output'"', nogen nolabel
		/* else "`data'"=="preserve", and that is already loaded. */		
	}
	else {
		restore, not
		
		if ("`data'"=="tv") use `"`output'"', clear
		/* else "`data'"=="variance", and that is already loaded. */		
	}
	
	* Close log
	if (`nooutput'!=1) log close

end


version 11
set matastrict on

mata:
real rowvector computeweights(real matrix M, real scalar i, real colvector c, | real colvector weights) {
	
	// construct matrix A which is used to select the relevant elements of M in constructing the VCV matrix
	real matrix temp
	real matrix A
	temp=designmatrix(c)
	A = temp, J(rows(c),cols(M)-cols(temp),0)
	
	// use A to select elements of M and build the VCV.  The second term adjusts the diagonal elements of the VCV matrix to account for the class-level and individual-level shocks
	real matrix vcv
	if (args()==4) vcv=A*M*A' + diag(1:/weights)
	else vcv=A*M*A'
	
	// phi is the vector of autocovariances, selected correctly using the matrix A.
	real rowvector phi
	phi=M[i,.]*A'
	
	// return the vector of weights
	return (phi*invsym(vcv))
	
}

real matrix compute_cov_corr(string scalar scores_var, string scalar weight_var, real scalar dim, string scalar teacher_var) {
	
	// pre-allocate matrix
	real matrix CC
	CC = J(dim,4,.)
	
	// Fill cov's and corr's: between time t and t+i
	real scalar i
	real scalar tstat
	for (i=1; i<=dim; i++) {
		// check that there are >=2 obs, in order to compute covariance
		stata(invtokens(("quietly count if !missing(",scores_var,",f",strofreal(i),".",scores_var,")"),""))
		if (st_numscalar("r(N)")>1) {
			stata(invtokens(("quietly corr ",scores_var," f",strofreal(i),".",scores_var," [aw=",weight_var,"+f",strofreal(i),".",weight_var,"], cov"),""))
			CC[i,1]=st_numscalar("r(cov_12)")
			CC[i,2]=CC[i,1] / ( sqrt(st_numscalar("r(Var_1)")) * sqrt(st_numscalar("r(Var_2)")) )
		}
		CC[i,3]=st_numscalar("r(N)")
		
		// Compute SE for covariance estimate
		if (st_numscalar("r(N)")>1) {
			stata(invtokens(("quietly reg ",scores_var," f",strofreal(i),".",scores_var," [aw=",weight_var,"+f",strofreal(i),".",weight_var,"], cluster(",teacher_var,")"),""))
			tstat=st_matrix("e(b)")[1,1] / sqrt( st_matrix("e(V)")[1,1] )
			CC[i,4]=abs(CC[i,1]/tstat)
		}
	}

	return (CC)
}

real rowvector create_m(real colvector lag_covariances, real scalar cov_sameyear, | real scalar lagdim, real scalar driftlimit) {

	real rowvector m

	if (args()==2)	m=cov_sameyear,lag_covariances'
	else {
		if (length(lag_covariances)<driftlimit) _error("driftlimit specified is higher than the number of lags in the dataset")
		m=cov_sameyear,lag_covariances'[1..driftlimit],J(1,lagdim-driftlimit,lag_covariances[driftlimit])
	}
	
	return (m)
}

void check_m_nomissing(real rowvector m) {
	if (missing(m)>0) _error("covariance vector contains missing values")
}

real matrix vectorToStripeDiag(real vector m) {
	real scalar dim
	dim = length(m)
	
	// pre-allocate matrix M
	real matrix M
	M=J(dim,dim,.)
	
	// fill lower triangle of M
	real scalar i
	real scalar j
	for (i=1; i<=dim; i++) {
		for (j=i; j<=dim; j++) {
			M[j,i]=m[j-i+1]
		}
	}
	
	_makesymmetric(M)
	return (M)
}

real matrix rightAppendMatrices(real matrix A, real matrix B) {
	real scalar rA
	real scalar rB
	rA=rows(A)
	rB=rows(B)
	
	if (rA==rB)		return (A,B)
	else if (rA<rB)	return ( ( A \ J(rB-rA,cols(A),.) ) , B )
	else			return ( A , ( B \ J(rA-rB,cols(B),.) ) )
}

void saveVariancesToDataset(real matrix cov_lag_accum, real matrix corr_lag_accum, real matrix obs_lag_accum, real matrix cov_se_lag_accum, real rowvector var_total_accum, real rowvector var_class_accum, real rowvector var_ind_accum, real rowvector cov_sameyear_accum, real rowvector corr_sameyear_accum, real rowvector obs_sameyear_accum, string rowvector suffixes) {

	stata("clear")
	
	// count number of lags, create correct number of obs, generate variable for number of lags
	real scalar n_lags
	n_lags=rows(cov_lag_accum)
	
	real scalar null
	null=st_addvar("int","lag")
	
	st_addobs(n_lags)
	stata("qui replace lag=_n")
	st_addobs(1)
	
	// generate output variables
	st_store(1::n_lags, st_addvar("float", "cov_lag":+suffixes), cov_lag_accum)
	st_store(1::n_lags, st_addvar("float", "corr_lag":+suffixes), corr_lag_accum)
	st_store(1::n_lags, st_addvar("float", "obs_lag":+suffixes), obs_lag_accum)
	st_store(1::n_lags, st_addvar("float", "cov_se_lag":+suffixes), cov_se_lag_accum)
	st_store(n_lags+1, st_addvar("float", "var_total":+suffixes), var_total_accum)
	st_store(n_lags+1, st_addvar("float", "var_class":+suffixes), var_class_accum)
	st_store(n_lags+1, st_addvar("float", "var_ind":+suffixes), var_ind_accum)
	st_store(n_lags+1, st_addvar("float", "cov_sameyear":+suffixes), cov_sameyear_accum)
	st_store(n_lags+1, st_addvar("float", "corr_sameyear":+suffixes), corr_sameyear_accum)
	st_store(n_lags+1, st_addvar("float", "obs_sameyear":+suffixes), obs_sameyear_accum)
}

real scalar driftcalc(real matrix M, real scalar i, real colvector c, real colvector weights, real colvector scores) {

	// b is the vector of weights
	real rowvector b
	b=computeweights(M, i, c, weights)
	
	// return the computed tv estimate
	return (b*scores)
	
}

void driftcalclist(real matrix M, string scalar teacher_var, string scalar time_var, string scalar scores_var, string scalar weights_var, string scalar teacherobs_var, string scalar va_var, | string scalar va_2yr_l_var, string scalar va_2yr_f_var, string scalar va_ss_var) {

	real scalar quasi
	if (args()==7) quasi=0
	else if (args()==10) quasi=1
	else _error("The mata command driftcalclist must either be called with no quasi-experiment variables or the full set of 3 quasi-experiment variables.)")

	real scalar nobs
	nobs=st_nobs()
	
	// get variable indices for the variables referenced in the loop (referring by index speeds up the loop)
	real scalar teacher_var_ind
	real scalar time_var_ind
	real scalar teacherobs_var_ind
	real scalar va_var_ind
	teacher_var_ind=st_varindex(teacher_var)
	time_var_ind=st_varindex(time_var)
	teacherobs_var_ind=st_varindex(teacherobs_var)
	va_var_ind=st_varindex(va_var)
	if (quasi==1) {
		real scalar va_2yr_l_var_ind
		real scalar va_2yr_f_var_ind
		real scalar va_ss_var_ind
		va_2yr_l_var_ind=st_varindex(va_2yr_l_var)
		va_2yr_f_var_ind=st_varindex(va_2yr_f_var)
		va_ss_var_ind=st_varindex(va_ss_var)
	}
	
	// create views of the variables we need
	real matrix Z
	st_view(Z=.,.,(teacher_var,time_var,weights_var,scores_var))
	
	
	// Declarations
	real scalar obs
	real scalar teacher
	real scalar obs_teacher
	real scalar time
	real scalar new_teacher
	real scalar new_time
	real scalar year_index
	real matrix Z_teacher
	real matrix Z_obs
	real matrix Z_quasi
	
	// set missing b/c referenced in first loop's if statement
	teacher=.
	time=.
	
	// Loop over all observations
	for (obs=1; obs<=nobs; obs++) {
	
		new_teacher=_st_data(obs,teacher_var_ind)
		new_time=_st_data(obs,time_var_ind)
	
		// Only perform calculations if we've reached a new teacher-year
		if (new_time != time | new_teacher != teacher) {
	
			// save new time id
			time=new_time
		
			// If we've reached a new teacher
			if (new_teacher != teacher) {
			
				// save new teacher id
				teacher=new_teacher
				
				// save number of observations for that teacher
				obs_teacher=_st_data(obs,teacherobs_var_ind)
				
				// select subview of Z, Z_teacher, which only contains the correct teacher's data
				st_subview(Z_teacher=., Z, (obs,obs+obs_teacher-1), .)
				
				// define teacher-specific scalar which indexes first year of teaching at 1
				year_index=min(Z_teacher[.,2])-1
				
			}
		
			// remove the rows of Z_teacher corresponding to current year
			Z_obs=select(Z_teacher, Z_teacher[.,2]:!=time)
					
			// remove rows of Z_obs that do not have score data
			Z_obs=select(Z_obs, Z_obs[.,4]:!=.)
			
			// if there are actually observations in other years, compute VA
			if (rows(Z_obs) > 0) {	
				st_store(obs,va_var_ind,driftcalc(M,time-year_index,Z_obs[.,2]:-year_index,Z_obs[.,3],Z_obs[.,4]))
			}
			
			if (quasi==1) {
				// remove the rows of Z_obs corresponding to the previous year
				Z_quasi=select(Z_obs, Z_obs[.,2]:!=time-1)
				if (rows(Z_quasi) > 0) {
					st_store(obs,va_2yr_l_var_ind,driftcalc(M,time-year_index,Z_quasi[.,2]:-year_index,Z_quasi[.,3],Z_quasi[.,4]))
				}
				
				// remove the rows of Z_obs corresponding to the next year
				Z_quasi=select(Z_obs, Z_obs[.,2]:!=time+1)
				if (rows(Z_quasi) > 0) {
					st_store(obs,va_2yr_f_var_ind,driftcalc(M,time-year_index,Z_quasi[.,2]:-year_index,Z_quasi[.,3],Z_quasi[.,4]))
				}
				
				// remove the rows of Z_obs corresponding to {t-2,t-1,t+1,t+2}
				Z_quasi=select(Z_obs, (Z_obs[.,2]:>time+2)+(Z_obs[.,2]:<time-2))
				if (rows(Z_quasi) > 0) {
					st_store(obs,va_ss_var_ind,driftcalc(M,time-year_index,Z_quasi[.,2]:-year_index,Z_quasi[.,3],Z_quasi[.,4]))
				}
			}		
		}
	}
}
end
