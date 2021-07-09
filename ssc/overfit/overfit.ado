capture program drop overfit
program overfit, rclass

	* Calculates Bilger and Manning (2015) overfitting statistics
	
	version 11.2

    ********************************************************************* Syntax *********************************************************************		
	
	gettoken 0 cmdest : 0, parse(":") bind quotes
	
	* if there is nothing before the colon, 0 = empty string
    if `"`0'"'==":" {
        local 0 ""
    }
    else {
	* take the colon out of cmdest
        gettoken colon cmdest : cmdest, parse(":")
        if `"`colon'"' != ":" {
                di as err "'colon' found were ':' expected"
                exit 198
        }
    }

    syntax [ anything(name=anyof) ]   [, predopt(string) nbgrp(integer 10) splitnorand nbiter(integer 100) seed(integer 1) efficient ///
										noiterbar noresults hist(string asis) showmod showslopes  ///
										savemod(string asis) savepred(string asis) procnb(integer 1)]

										
    ******************************************************** Parse arguments *******************************************************
	
	* Separate the options from the estimation command
	gettoken cmdest cmdopt : cmdest, parse(",") bind quotes
	
	* Do not allow if, in and using conditions, nor weights.
	noifinusingweight `cmdest'
	
	* Find out which estimation method was used
	gettoken method vlist: cmdest
	
	* Separate dependant variable from covariates 
	gettoken y xlist: vlist
	
	* Result of parsing:
		* cmdest: estimation command including dependent variable Y and regressors X1,...XK, without options.
		* cmdopt: any option passed to the estimation command.
			* method: estimation command used, e.g. glm.
			* vlist: list of all variables used, that is the dependent variable Y and all regressors X1,...XK.
				* y: dependent variable.
				* xlist: all regressors X1,...XK.

    ******************************************************** Check options *******************************************************
	
	* predopt: options to pass to the predict command so that it predicts the expectation of y
	if ("`predopt'" != "") {
		local predopt ", `predopt'"
	}
	
	* nbgrp: number of sub-samples to be randomly split from the whole sample (default: 100)
	if (`nbgrp' < 2) {
		di as err "Option nbgrp must be an integer greater than 1."
        exit 198
    }
	
	* splitnorand: observations are assigned to the groups on a non-random basis but according to their order.
		* The first n/nbgrp observation are assigned to group 1, and so on.

	* nbiter: number of repetitions of the multi-way Copas (default: 1)
	if (`nbiter' <= 0) {
		di as err "Option nbiter must be a strictly positive integer."
        exit 198
    }
	
	* if option splinorand is specified, all iterations would produce the same result and nbiter is set a 1.
	if ("`splitnorand'" != "") {
		local nbiter = 1
	}
	
	* seed: initialize the seed number for the random splits, and restore the initial seed number before exiting. Must be a positive integer.
	if (`seed' <= 0) {
		di as err "Option seed must be a strictly positive integer."
		exit 198
	}
	
	* efficient: requires that the more efficient method B, default is method A
		* Method A
		* In-sample prediction in only one group at a time
		* Only uses a fraction of the possible in-sample predictions
		* Outofsample and Insample have a smiliar precision
		
		* Method B
		* In-sample prediction in all groups left out when estimating the model
		* Uses all possible in-sample predictions
		* Insample more precisely estimated, which also improves Overfit
		* WARNING: this method can be untractable as estimating the slopes requires setting nobs at sample size * nbgrp
		* This method is for use with small data sets where efficiency is an issue.
	
	* noiterbar: prevents overfit from showing the iteration progress.
	
	* noresults: prevents overfit from displaying the results.
	
	* hist: displays histograms of the shrinkage statistics and saves them into file {it:string}.gph on current directory.
	
	* Creates temporary files ___outofsample.gph, insample.gph, and overfit.gph which need to be erased manually.

	* showmod, showslopes: displays the estimations of the model and of the slope statistics
	
	* savemod: save the estimated models into file string.dta
	
	* showmod: display model estimations
	if ("`showmod'"!="") {
		local showmod "noisily"
	}
	
	* showslopes: display slope estimations
	if ("`showslopes'"!="") {
		local showslopes "noisily"
	}
	
	* showpred: displays summary statistics of the predictions
	
	* procnb: processor number that will be added in front to the name of the temporary datasets. This allows multiprocessing.
		* Must be positive a positive integer. Default is 1.
	if (`procnb'<0) {
		di as err "Option procnb must be a positive integer."
		exit 198
	}
	else {
		local procnb "`procnb'_"
	}

	***************************************************** Local variables ******************************************************

	tempvar u group
	* u: uniformely distributed random numbers used to split the sample
	* group: categorical variable indicating the group
	
	tempvar yhat 
	* yhat: raw scale predictions

	tempname overfit crashes iota overfit_mean overfit_sd
	matrix `overfit' = J(`nbiter',3,.)
	matrix colnames `overfit' = "out-of-sample bias" "in-sample bias" overfitting 
	local rownames ""
	forvalues i = 1/`nbiter' {
		local rownames "`rownames' iter`i'"
	}
	matrix rownames `overfit' = `rownames'
	* matrix crashes: gives for each iteration how many estimations have crashed
	matrix `crashes' = J(`nbiter',3,0)
	matrix rownames `crashes' = `rownames'
	matrix colnames `crashes' = model delta alpha
	* iota: vector of ones
	matrix `iota' = J(`nbiter',1,1)
	* overfit_mean: average slopes over nbiter
	* overfit_sd: standard deviation of the slopes over nbiter
	
	if (`"`savemod'"' != "") {
		tempname nbrows
		* nbrows: number of estimations which have succeeded
	}
	
	quietly {
	
		**************************************************** Body *******************************************************

		* Save the initial seed number
		local initialseed = c(seed)
		
		* Set the seed number
		set seed `seed'
			
		********** METHOD A *********** 
		if ("`efficient'" == "") {
			
			* Initialization for method A only
			tempvar yhat_in yhat_out
			gen double `yhat_in' = .
			gen double `yhat_out' = .
			* yhat_in: in-sample raw scale predictions
			* yhat_out: out-of-sample raw scale predictions
			
			* uniform random number
			gen double `u' = _n
			
			* If the estimated coefficients need to be saved, save a copy of the data set
			if (`"`savemod'"' != "") {
				save ___`procnb'tempdata, replace
			}
		
			forvalues it = 1/`nbiter' {

				* Assign groups
				if ("`splitnorand'"=="") {
					replace `u' = uniform()
				}
				xtile `group' = `u', nq(`nbgrp')

				* Estimation of the model and prediction
				forvalues gp = 1/`nbgrp' {
			
					* Estimation on nbgrp-1 subsamples
					capture `showmod' `cmdest' if `gp' != `group' `cmdopt'

					if (_rc==0) {
					
						* Save the estimated coefficients
						if (`"`savemod'"' != "") {
							if (`gp'==1) {
								matrix _beta_ = (`gp',e(b))
							}
							else {
								matrix _beta_ = (_beta_ \ `gp',e(b))
							}
						}
			
						* Raw scale prediction		
						predict double `yhat' `predopt'
						
						* Assign the out-of-sample prediction to the current group
						replace `yhat_out' = `yhat' if `group' == `gp' 

						* Assign the in-sample predictions 
							* Only use the predictions for one group (the group after or the first group if the last group is being considered)
						if (`gp' != `nbgrp') {
							replace `yhat_in' = `yhat' if `group' == `gp'+1
						}
						else {
							replace `yhat_in' = `yhat' if `group' == 1
						}
						
						* Save predictions
						if (`"`savepred'"'!="") {
						
							save ___`procnb'tempdata2, replace
						
							if (`gp'==1) {
								gen obs_id = _n
								lab var obs_id "position of the observation in the original data set"
								gen iter = `it'
								lab var iter "iteration number"
								gen estnb = `gp'
								lab var estnb "estimation number for a given iteration"
								gen group = `group'
								lab var group "group to which the observation has been affected"
								rename `y' y
								lab var y "dependent variable"
								rename `yhat' yhat`gp'
								lab var yhat`gp' "raw scale prediction"
								
								keep obs_id iter estnb group y yhat`gp'
								order obs_id iter estnb group y yhat`gp'
								save ___`procnb'tempdata3, replace
							}
							else if (`gp'>1 & `gp'<`nbgrp') {
								gen obs_id = _n
								lab var obs_id "position of the observation in the original data set"
								rename `yhat' yhat`gp'
								lab var yhat`gp' "raw scale prediction using model `gp'"
								
								keep obs_id yhat`gp'
								merge 1:1 obs_id using ___`procnb'tempdata3
								order yhat`gp', last
								drop _merge
								save ___`procnb'tempdata3, replace	
							}
							else {
								gen obs_id = _n
								lab var obs_id "position of the observation in the original data set"
								rename `yhat' yhat`gp'
								lab var yhat`gp' "raw scale prediction"
								
								keep obs_id yhat`gp'
								merge 1:1 obs_id using ___`procnb'tempdata3
								order yhat`gp', last
								drop _merge
								
								if (`it'==1) {
									save `"`savepred'"', replace
								}
								else {
									append using `"`savepred'"'
									save `"`savepred'"', replace
								}
							}	
							use ___`procnb'tempdata2, clear
						}
		
						* Reinitialization
						drop `yhat'
					}
					else if (_rc==1) {
						exit 1
					}
					else {
						matrix `crashes'[`it',1] = `crashes'[`it',1] + 1
					}
				}
	
			
				*** Estimation of the slope statistics ***
					
				* Out-of-sample shrinkage
				capture `showslopes' reg `y' `yhat_out'	
				if (_rc==0) {
					matrix `overfit'[`it',1] =  100*(1-_b["`yhat_out'"])
				}
				else if (_rc==1) {
					exit 1
				}
				else {
					matrix `crashes'[`it',2] = 1
				}

				* In-sample shrinkage	
				capture `showslopes' reg `y' `yhat_in'
				if (_rc==0) {
					matrix `overfit'[`it',2] =  100*(1-_b["`yhat_in'"])
				}
				else if (_rc==1) {
					exit 1
				}
				else {
					matrix `crashes'[`it',3] = 1
				}
			
				* Overfitting
				matrix `overfit'[`it',3] = 100*(1 - (100-`overfit'[`it',1]) / (100-`overfit'[`it',2]))	
				
				* Reinitialization
				replace `yhat_in' = .
				replace `yhat_out' = .
				
				if (`"`savemod'"' == "") {
					drop `group'
				}
				
				* Save the estimated coefficients into file `savemod'.dta
				if (`"`savemod'"' != "") {
	
					scalar `nbrows' = rowsof(_beta_)
					local nbr = `nbrows'
					svmat _beta_
					rename _beta_1 estnb
					lab var estnb "estimation number for a given iteration"
					gen iter = `it'
					lab var iter "iteration number"
	
					keep iter estnb _beta_*
					order iter estnb _beta_*
											
					drop if _n > `nbr'
					
					if (`it'==1) {
						save `"`savemod'"', replace
					}
					else {
						append using `"`savemod'"'
						save `"`savemod'"', replace
					}
				
					* Coefficient names
					if (`it'==`nbiter') {	
						local coefnames: colfullnames _beta_
						gettoken tok coefnames: coefnames
						local i = 2
						foreach name of local coefnames {
							local name: subinstr local name ":" "_", all
							rename _beta_`i' `name'
							local ++i
						}
						save `"`savemod'"', replace
					}	
					
					use ___`procnb'tempdata, clear
				}
				
				* Display progress
				if ("`iterbar'" != "noiterbar") {
					noisily displayIter `it' 50
				}
			}
		}
		
		
		********** METHOD B **********	
		else {
		
			* Initialization for method B only
			
			* Save sample size
			local ssize = _N
		
			* Local variables for estimation and raw scale predictions
			forvalues gp = 1/`nbgrp' {
				tempvar yhat_`gp'
			}
			
			* Local variable that records the estimation number
			tempvar estnb
			gen int `estnb' = 1
				
			* Save data set (the user will have to remove it manually)
			save ___`procnb'tempdata, replace
			
			forvalues it = 1/`nbiter' {
			
				* Assign groups
				if ("`splitnorand'"=="") {
					gen `u' = uniform()
				}
				else {
					gen `u' = _n
				}
				xtile `group' = `u', nq(`nbgrp')

				* Estimation of the model and prediction
				forvalues gp = 1/`nbgrp' {
			
					* Estimation on nbgrp-1 subsamples
					capture `showmod' `cmdest' if `gp' != `group' `cmdopt'
			
					* Estimation scale prediction
					if (_rc==0) {
				
						* Save the estimated coefficients
						if (`"`savemod'"' != "") {
							if (`gp'==1) {
								matrix _beta_ = (`gp',e(b))
							}
							else {
								matrix _beta_ = (_beta_ \ `gp',e(b))
							}
						}

						* Raw scale prediction
						predict double `yhat_`gp'' `predopt'

					}
					else if (_rc==1) {
						exit 1
					}
					else {
						gen `yhat_`gp'' = .
						matrix `crashes'[`it',1] = `crashes'[`it',1] + 1
					}
				}
									
				* Only keep relevant variables
				keep `estnb' `group' `y' `yhat_1'-`yhat_`nbgrp''
				
				* Save predictions
				if (`"`savepred'"'!="") {
					
					save ___`procnb'tempdata2, replace
					
					gen obs_id = _n-int((_n-1)/`ssize')*`ssize'
					lab var obs_id "position of the observation in the original data set"		
					gen iter = `it'
					lab var iter "iteration number"
					rename  `estnb' estnb
					lab var estnb "estimation number for a given iteration"
					rename  `group' group
					lab var group "group to which the observation has been affected"
					rename `y' y
					lab var y "dependent variable"
					
					forvalues gp = 1/`nbgrp' {
						rename `yhat_`gp'' yhat`gp' 
						lab var yhat`gp' "raw scale prediction using model `gp'"
					}
	
					order obs_id iter estnb group y
									
					if (`it'==1) {
						save `"`savepred'"', replace
					}
					else {
						append using `"`savepred'"'
						save `"`savepred'"', replace
					}
					
					use ___`procnb'tempdata2, replace
				}	

				
				* Save predictions of the first estimation
				gen double `yhat' = `yhat_1'		
				drop `yhat_1'
				
				* Pile up all the predictions
				forvalues gp = 2/`nbgrp' {
					local newssize = `gp' * `ssize'
					set obs `newssize'
					
					replace `estnb' = `gp' if _n > (`gp'-1)*`ssize' & _n <= `gp'*`ssize'
					
					replace `group' = `group'[_n-(`gp'-1)*`ssize'] if _n > (`gp'-1)*`ssize' & _n <= `gp'*`ssize'
					replace `y' = `y'[_n-(`gp'-1)*`ssize'] if _n > (`gp'-1)*`ssize' & _n <= `gp'*`ssize'
					
					replace `yhat' = `yhat_`gp''[_n-(`gp'-1)*`ssize'] if _n > (`gp'-1)*`ssize' & _n <= `gp'*`ssize'		
					drop `yhat_`gp''
				}
								
				* Estimation of the slope statistics
						
				* Out-of-sample
				capture `showslopes' reg `y' `yhat' if `estnb' == `group'	
				if (_rc==0) {
					matrix `overfit'[`it',1] = 100*(1-_b["`yhat'"])
				}
				else if (_rc==1) {
					exit 1
				}
				else {
					matrix `crashes'[`it',2] = 1
				}

				* In-sample slope	
				capture `showslopes' reg `y' `yhat' if `estnb' != `group'
				if (_rc==0) {
					matrix `overfit'[`it',2] = 100*(1-_b["`yhat'"])
				}
				else if (_rc==1) {
					exit 1
				}
				else {
					matrix `crashes'[`it',3] = 1
				}	
			
				* Overfitting slope
				matrix `overfit'[`it',3] = 100*(1 - (100-`overfit'[`it',1]) / (100-`overfit'[`it',2]))
				
						
				* Save the estimated coefficients into file `savemod'.dta
				if (`"`savemod'"' != "") {
		
					scalar `nbrows' = rowsof(_beta_)
					local nbr = `nbrows'
					svmat _beta_
					rename _beta_1 estnb
					lab var estnb "estimation number for a given iteration"
					gen iter = `it'
					lab var iter "iteration number"
	
					keep iter estnb _beta_*
					order iter estnb _beta_*
					drop if _n > `nbr'
					
					if (`it'==1) {
						save `"`savemod'"', replace
					}
					else {
						append using `"`savemod'"'
						save `"`savemod'"', replace
					}
					
					* Coefficient names
					if (`it'==`nbiter') {	
						local coefnames: colfullnames _beta_
						gettoken tok coefnames: coefnames
						local i = 2
						foreach name of local coefnames {
							local name: subinstr local name ":" "_", all
							rename _beta_`i' `name'
							local ++i
						}	
						save `"`savemod'"', replace
					}
				}
				
				* Reinitialization
				use ___`procnb'tempdata, clear
				
				* Show progress
				if ("`iterbar'" != "noiterbar") {
					noisily displayIter `it' 50
				}
			}
		}
		
		
		
		*********** Compute the average and standard deviation of the shrinkage statistics **********
		
		* All shrinkage statistics
		if (`nbiter'==1) {
			tempname missing
			matrix `missing' = J(1,3,.)
			matrix `overfit_mean' = (`overfit' \ `missing')
		}
		else {
			matrix `overfit_mean' = `iota'' * `overfit' / `nbiter'
			matrix `overfit_sd' = vecdiag((`overfit' - `iota'*`overfit_mean')' * (`overfit' - `iota'*`overfit_mean') / `nbiter')
			forvalues i = 1/3 {
				matrix `overfit_sd'[1,`i'] = sqrt(`overfit_sd'[1,`i'])
			}
			matrix `overfit_mean' = (`overfit_mean' \ `overfit_sd')
		}
		matrix rownames `overfit_mean' = estimate se
		matrix colnames `overfit_mean' = "out-of-sample bias" "in-sample bias" overfitting 
			
		* All non-missing shrinkage statistics 
		tempname missingvalues iota3  nbcrashes overfit_nomissing
		* missingvalues: equals 1 if there is at least one missing value in the shrinkage statistics, and 0 otherwise
		scalar  `missingvalues' = matmissing(`overfit')
		* iota3: vector of 3 ones
		matrix `iota3' = J(3,1,1)
		* nbcrashes: number of crashes that occured for each iteration.
		matrix `nbcrashes' = `iota''*`crashes'*`iota3'
		scalar `nbcrashes' = `nbcrashes'[1,1]
		* overfit_nomissing: mean and standard deviation of all non missing statistics

		if (`missingvalues' == 1 | `nbcrashes' > 0) {

			tempname overfit_mis0 notmissing nbnotmissing val
			* overfit_mis0: shrinkage statistics with missing values replaced by zeros.
			* notmissing: matrix containing one if a shrinkage statistic is not missing, and 0 otherwise.
			* nbnotmissing: matrix containing the number of non-missing shrinkage statistics (dim: 1x4)
			* val: value of a given shrinkage statistic

			matrix `overfit_mis0' = `overfit'
			matrix `notmissing' = J(`nbiter',3,1)
			forvalues it = 1/`nbiter' {
			
				forvalues j = 1/3 {
					scalar `val' = `overfit'[`it',`j']
					if (`val'==.) {
						matrix `overfit_mis0'[`it',`j'] = 0
						matrix `notmissing'[`it',`j'] = 0
					}	
				}		
			}
			
			* Compute mean and standard deviation
				
			matrix `nbnotmissing' = `iota''*`notmissing'
			
			capture matrix `overfit_nomissing' = `iota''*`overfit_mis0' * inv(diag(`nbnotmissing'))
			
			* When there is a division by 0, do it manually to prevent stata from crashing:
			if (_rc!=0) {
				tempname nbnotm
				matrix `overfit_nomissing' = `iota''*`overfit_mis0'
				forvalues j=1/3 {
					scalar `nbnotm' = `nbnotmissing'[1,`j']
					if (`nbnotm' != 0) {
						matrix `overfit_nomissing'[1,`j'] = `overfit_nomissing'[1,`j']/`nbnotm'
					}
					else {
						matrix `overfit_nomissing'[1,`j'] = .
					}
				}
			}
			
			capture matrix `overfit_sd' = vecdiag((`overfit_mis0' - `notmissing'*diag(`overfit_nomissing'))' * ///
										(`overfit_mis0' - `notmissing'*diag(`overfit_nomissing')) * inv(diag(`nbnotmissing')))

			* When there is a division by 0, do it manually to prevent stata from crashing:
			if (_rc!=0) {
				matrix `overfit_sd' = J(1,3,.)
				tempname nbnotm
				forvalues j=1/3 {
				
					scalar `nbnotm' = `nbnotmissing'[1,`j']	
					if (`nbnotm' != 0) {	
						matrix `overfit_sd'[1,`j'] = (`overfit_mis0'[1..`nbiter',`j']-`notmissing'[1..`nbiter',`j']*`overfit_nomissing'[1,`j'])' * ///
													(`overfit_mis0'[1..`nbiter',`j']-`notmissing'[1..`nbiter',`j']*`overfit_nomissing'[1,`j']) / `nbnotm'
					}
				}
			}		
			
			forvalues i = 1/3 {
				matrix `overfit_sd'[1,`i'] = sqrt(`overfit_sd'[1,`i'])
			}
			
			matrix `overfit_nomissing' = (`overfit_nomissing' \ `overfit_sd' \ `nbnotmissing')
			matrix rownames `overfit_nomissing' = estimate se n
			matrix colnames `overfit_nomissing' = "out-of-sample bias" "in-sample bias" overfitting 		
		}
		
		* All shrinkage statistics not involving any crash
		
		tempname overfit_nocrash
		* overfit_nocrash: mean and standard deviation of all shrinkage statistics that involve no crash

		if (`nbcrashes' > 0) {

			tempname nocrashes nbnocrashes crash1 crash2 crash3
			* nocrashes: matrix containing one if there was no crash when computing a shrinkage statistic, and 0 otherwise
			* nbnocrashes: matrix containing the number of iterations with no crash
			* crash1: number of crashes occuring in the estimation command
			* crash2: equals 1 if a crash occured when estimating the outofsample statistic
			* crash3: equals 1 if a crash occured when estimating the insample statistic
			
			matrix `nocrashes' = J(`nbiter',3,1)
			forvalues it = 1/`nbiter' {
			
				scalar `crash1' = `crashes'[`it',1]		
				scalar `crash2' = `crashes'[`it',2]
				scalar `crash3' = `crashes'[`it',3]
					
				* outofsample
				if (`crash1'>0 | `crash2'==1) {
						matrix `nocrashes'[`it',1] = 0
				}		
				* insample
				if (`crash1'>0 | `crash3'==1) {
						matrix `nocrashes'[`it',2] = 0
				}	
				* overfit
				if (`crash1'>0 | `crash2'==1 | `crash3'==1) {
						matrix `nocrashes'[`it',3] = 0
				}		
			}
			
			* Compute mean and standard deviation
			
			matrix `nbnocrashes' = `iota''*`nocrashes'
			
			capture matrix `overfit_nocrash' = vecdiag(`nocrashes''*`overfit_mis0' * inv(diag(`nbnocrashes')))
			* When there is a division by 0, do it manually to prevent stata from crashing:
			if (_rc!=0) {
				tempname nbnoc
				matrix `overfit_nocrash' = J(1,3,.)
				forvalues j=1/3 {
					scalar `nbnoc' = `nbnocrashes'[1,`j']
					if (`nbnoc' != 0) {
						matrix `overfit_nocrash'[1,`j'] = `nocrashes'[1..`nbiter',`j']'*`overfit_mis0'[1..`nbiter',`j']/`nbnoc'
					}
				}
			}
			
			capture matrix `overfit_sd' = vecdiag((`overfit_mis0' - `nocrashes'*diag(`overfit_nocrash'))' * (`overfit_mis0' - `nocrashes'*diag(`overfit_nocrash')) * inv(diag(`nbnocrashes')))
			
			* When there is a division by 0, do it manually to prevent stata from crashing:
			if (_rc!=0) {
				matrix `overfit_sd' = J(1,3,.)
				tempname nbnoc
				forvalues j=1/3 {
				
					scalar `nbnoc' = `nbnotmissing'[1,`j']	
					if (`nbnoc' != 0) {	
						matrix `overfit_sd'[1,`j'] = (diag(`nocrashes'[1..`nbiter',`j'])*`overfit_mis0'[1..`nbiter',`j']-`nocrashes'[1..`nbiter',`j']*`overfit_nocrash'[1,`j'])' * ///
													(diag(`nocrashes'[1..`nbiter',`j'])*`overfit_mis0'[1..`nbiter',`j']-`nocrashes'[1..`nbiter',`j']*`overfit_nocrash'[1,`j']) / `nbnoc'
					}
				}
			}		
		
			forvalues i = 1/3 {
				matrix `overfit_sd'[1,`i'] = sqrt(`overfit_sd'[1,`i'])
			}
			matrix `overfit_nocrash' = (`overfit_nocrash' \ `overfit_sd' \ `nbnocrashes')
			matrix rownames `overfit_nocrash' = estimate se n
			matrix colnames `overfit_nocrash' = "out-of-sample bias" "in-sample bias" overfitting 	
		}
		

		* Display estimation results
		if ("`results'" != "noresults") {
			if (`nbcrashes' == 0) {
				noisily di _newline(2) as result "Shrinkage statistics (expressed in percent)"
				noisily matrix list `overfit_mean', noheader format(%18.2f)
			}
			else {
			
				if (`nbcrashes' == 1) {
					noisily di _newline(2) as error "Warning: " `nbcrashes' " crash has occurred when estimating the model or the shrinkage statistics during an iteration. "
				}
				else {
					noisily di _newline(2) as error "Warning: " `nbcrashes' " crashes have occurred when estimating the model or the shrinkage statistics for one or more iterations. "
				}
				noisily di "See matrix r(crashes) for details."
				
				/*
				noisily di _newline(2) as result "Shrinkage statistics averaged on all non-missing iterations"
				noisily di as result "(expressed in percent)"
				noisily matrix list `overfit_nomissing', noheader format(%18.2f)
				*/
				
				noisily di _newline(2) as result "Shrinkage statistics averaged over the (n) crash-free iterations"
				noisily di as result "(expressed in percent)"
				noisily matrix list `overfit_nocrash', noheader format(%18.2f)
				
				* Only returns the no-crash averages
				matrix `overfit_mean' = `overfit_nocrash'
			}
		}
	
		
		* Draw histograms
		if (`"`hist'"' != "") {
			* Create shrinkage variables
			svmat `overfit'
				
			hist `overfit'1, xtitle("out-of-sample bias") color(edkblue)
			graph save ___`procnb'_outofsample, replace
			hist `overfit'2, xtitle("in-sample bias") color(eltblue)
			graph save ___`procnb'_insample, replace
			hist `overfit'3, xtitle("overfitting") ytitle("") color(midblue)
			graph save ___`procnb'_overfit, replace
			
			graph combine ___`procnb'_outofsample.gph ___`procnb'_insample.gph ___`procnb'_overfit.gph, xcommon ycommon
			graph save `"`hist'"', replace
			
			drop `overfit'1 `overfit'2 `overfit'3
		}
		
	
		* Return results
		return matrix shrinkage_iter = `overfit', copy
		return matrix shrinkage_mean = `overfit_mean', copy
		return matrix crashes = `crashes', copy
			
		return scalar missingvalues = `missingvalues'
		return scalar nbcrashes = `nbcrashes'

	}
	
	* Restores the initial seed number
	set seed `initialseed'
	
	* Delete temporary files
	capture erase ___`procnb'*

end


* Program that does not allow if, in and using conditions neither weights in the estimation command
capture program drop noifinusingweight
program noifinusingweight

	version 11.2

	syntax [anything(name=anyof)]
	
end

************************************************************************
* Program that displays a bar showing the number of completed iterations.
capture program drop displayIter
program displayIter

	version 11.2

	args it itergrp
	
	if (`it' == 1) {
		di _newline(1) "Iterations"
		di "." _continue
	}
	else if (`it' != int(`it'/`itergrp')*`itergrp') {
		di "." _continue
	}
	else {
		* Number of columns to skip to indent iteration numbers
		local nbcol = int(log(10*`itergrp'/`it')/log(10))
		di ". " _skip(`nbcol') "`it'" 
	}
	
end









