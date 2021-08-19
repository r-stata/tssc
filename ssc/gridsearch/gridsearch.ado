// search over a grid of tuning parameters for an estimation command and compute the best criterion
// evaluation criteria: rmse, mse , accuracy, AUC
// output: gridsearch matrix 
///////////////////////////////////////////////////////////////////////////////////////////////
cap program drop gridsearch
program define gridsearch , rclass
*! version 1.0.0  Oct 27, 2020,  changed to rclass
	version 14.0 
	
	// parse the estimation command
	gettoken estimator 0 : 0
	//  estimators starting with discrim have two words
	if "`estimator'"=="discrim"  gettoken estimator2 0 : 0
	// parse the rest 
	//   group() is specifically to catch the option in "discrim knn, group()"
	//   distribution() is specifically to catch the option in boost, distribution(multinomial)
	syntax varlist(fv) [if] [in] , par1name(str) par1list(numlist) CRITerion(str) method(str) ///
	    [ par2name(str) par2list(numlist)  nogrid  verbose ///
		 predictoptions(str) group(varlist numeric min=1 max=1) DISTribution(str) * ]  

	tokenize `varlist' 
    local y : word 1 of `varlist'
	checksorted `y'
	if (r(sorted)!=0)  { 
		di as error "Warning: The data are in ascending order of the response variable. "
		di as error "Warning: This is likely incorrect. Put the data into random sort order first."	
		exit 459
	}
	if "`estimator'"=="discrim" local y="`group'"  //exception for discrim knn xvars , group(y)

	
	//special processing of "no" prefix: `grid'=="" or `grid'=="nogrid"
	local grid= "`grid'"!="nogrid"
	
	// criterion
	if ("`criterion'"!="accuracy" & "`criterion'"!="mse" & "`criterion'"!="rmse" & "`criterion'"!="AUC") {
		di as error("unknown criterion: `criterion'")
		exit 198 
	}
	
		// deal with if/in
	preserve 
	if "`if'"!="" | "`in'" !="" {
		qui keep `if' `in'
	}
	
	parse_method, method(`method')
	local method=r(method)  // this overrides the original `method'="str1 str2"
	local methodarg=r(methodarg)

	// train data
	tempvar train
	if ("`method'"=="trainfraction") {
		qui gen `train'=0
		qui replace `train'=1 if _n <= `methodarg'*_N
	}
	else if ("`method'"=="trainvar") {
		local train= "`methodarg'"
	}
    else if("`method'"=="cv") {
		qui gen `train'=0  // not used for crossvalidation but needed for evaluation of criteria: all predicted values are test data
	}

	tempvar  tune1 tune2 evaluation time
	qui gen `tune1'=.			// tuning parameter 1
	label var `tune1' "`par1name'"
	qui gen `tune2'=. 			// tuning parameter 2
	label var `tune2' "`par2name'"
	qui gen `evaluation'=.   	// results: one value for each tuning combination
	qui gen `time'=.       		// computational time
	label var `time' "seconds"
	timer clear

	// if !grid and par1list and par2list are of unequal length: there is currently no warning
	
	// avoid crash when secpmd tuning param not specified
	local empty=.
	if ("`par2list'"=="") local par2list=`empty'
	
	tempvar predvar		
	timer clear
	local counter1=0   // need to create lists when "grid" option is not specified
	foreach ii of numlist `par1list'  {
		local counter1=`counter1'+1
		local counter2=0
		foreach jj of numlist `par2list'  {
			local counter2=`counter2'+1
			di as text "counter `counter1' `counter2'" as res ""
			// Go into grid mode (as opposed to list mode) , if a) grid specified,		
			//	b) if second tuning parameter not specified (because I want to run all combinations)
			//  c) if list mode only continue if non-empty parameter and indeces are (1,1),(2,2)(3,3) ...
			//			if ("`grid'"!="" | "`par2list'"=="`empty'" | ("`par2list'"!="`empty'" &`counter1'==`counter2')) {
			if (`grid' | "`par2list'"=="`empty'" | ("`par2list'"!="`empty'" &`counter1'==`counter2')) {
				timer clear
				timer on 1 
				local counter=`counter'+1
				local par1= `ii'
				local par2= `jj'   // might be empty
				
				// if active, specify par2
				// don't need error checking on par1: both par1name and par1list are not optional
				if "`par2name'"!="" {
					if "`par2list'"!="`empty'" 	local par2paren=`"`par2name'(`par2')"'  
					else di as error "par2name(`par2name') specified, but par2list unspecified." 
				}
				if ("`estimator'"=="boost") {
		            if ("`method'"=="trainvar") {
						di as error "The method trainvar is not implemented for boost (only trainfraction and cv)."		
						exit 198
					}
					else if ("`method'"=="cv" & "`distribution'"=="multinomial") { 
						di as error "The combination "multinomial" and "cv" is not implemented for boost"
						// might not be hard to implement now 
						// note: option boost,trainfraction  is not accessible, because it is conflated with gridsearch, trainfraction
						//   	 By default, "boost,trainfraction(0.8)"
						// For each fold, boost would use 80% of the data to determine the best number of trees, bestiter. 
						// but need to erase `predvar'1... `predvar'k for crossvalidation with multinomial boost?
						exit 198
					}
					if "`distribution'"==""  {
						di as error `"Boost requires option "distribution"."'
						exit 198
					}
					// erase any existing boost prediction variables if they exist
					if ("`distribution'"=="multinomial")  erase_predvars, predvar(`predvar') 
 
					local addstuff= `"distribution("`distribution'") "'
				}
				else if ("`estimator'"=="discrim") local addstuff = `"group(`group')"'
				else if "`distribution'"!=""  {
					di as error `"Unexpected option "distribution" specified."'
					exit 198
				}	
				if ("`criterion'"=="AUC" & ("`estimator'"=="discrim" | "`method'"=="cv")) {
					//only criterion that requires probabilitiy predictions
					di as error "AUC has not yet been implemented for estimator==discrim and method==cv" as res ""
					exit 198
				}
				
				cap drop `predvar'  
				// multiple variable prediction not implemented (except for boosting with trainfraction where there is no single var prediction)
				
				local eval=0  
				if ("`method'"!="cv") { 
				    // trainfraction or trainvar: estimation and prediction
					// `options' must come before par1 and par2 (in case options specifies the same pars they are overwritten)
					if ("`verbose'"!="" & `counter1'==1  & `counter2'==1) ///
						di `" `estimator' `estimator2' `varlist' if `train',  `options' `par1name'(`par1') `par2paren' `addstuff' "'	
					`estimator' `estimator2' `varlist' if `train', `options' `par1name'(`par1') `par2paren' `addstuff'					
 
					local DEBUG=0
					if (`DEBUG' & `counter1'==1  & `counter2'==1)  list_included, y("`y'") train("`train'")

					//single variable prediction, could be a probability or a class 
					predict `predvar' , `predictoptions' 
					
					// identical predictions likely indicate a problem. 
					qui sum `predvar'
					if (r(sd)==0) di as error "Warning: Predicted values are all identical or missing (standard deviation=0)"  as res "" //`as res\ switches color back

					if ("`estimator'"=="boost" & "`criterion'"!="AUC"  & ("`distribution'"=="bernoulli"  | "`distribution'"=="logistic"))  {
						qui replace `predvar' = round(`predvar')  // round probabilities, could potentially move this to "boost_predict, class"
					}
					//if ("`estimator'"=="svmachines" & ("`predictoptions'"=="prob" | "`predictoptions'"=="probability" ))  {
					//	//***untested ; this statement is risky; what if multi-class?
					//    replace  `predvar'= `predvar'_1  // probability
					//} 
					evaluate_crit  if !`train', pred(`predvar') y(`y') criterion(`criterion') evaluation(`evaluation') 
					local eval=r(eval)
				}
				else {
				// crossvalidation
					if ("`verbose'"!="" & `counter1'==1  & `counter2'==1) ///
						di `" crossvalidate `predvar' `estimator' `estimator2' `varlist' , folds(`methodarg') `options' `par1name'(`par1') `par2paren' `addstuff' "'
					// for CV we do not specify "if train"
					cap drop folds
					crossvalidate `predvar' `estimator' `estimator2' `varlist' , folds(`methodarg') gen(folds) ///
						`options' `par1name'(`par1') `par2paren' `addstuff'	
					
					// identical predictions likely indicate a problem. 
					qui sum `predvar'
					if (r(sd)==0) di as error "Warning: Predicted values are all identical or missing (standard deviation=0)"  as res "" //`as res\ switches color back

					if ("`estimator'"=="boost" & "`criterion'"!="AUC" & ("`distribution'"=="bernoulli"  | "`distribution'"=="logistic"))  {
						qui replace `predvar' = round(`predvar')  // round probabilities, could potentially move this to "boost_predict, class"
					}
					evaluate_crit_av  if !`train', pred(`predvar') y(`y') criterion(`criterion') evaluation(`evaluation') nfolds(`methodarg') folds(folds)	
					local eval=r(eval_av)
				}
				
				timer off 1
				qui timer list   // required to generate r() codes
				local temp= r(t1)
				
				// save values 
				qui replace `time'= `temp' in `counter'
				qui replace `tune1'= `par1' in `counter'
				qui replace `tune2'= `par2' in `counter'
				qui replace `evaluation'= `eval' in `counter'
				//di "par1=`par1' par2=`par2' `evaluation'=`eval' `time'=`temp' "
			}
		}
	}

		  
	// gsort does not have a "stable option". Ties in gsort use random resources, this may cause seemingly "random" behaviour.
	// this changes sort order ; but restore later also restores sort order
	tempvar tempsort 
	qui gen `tempsort'= `evaluation'   // find the smallest mse /rmse
	if ("`criterion'"=="accuracy" | "`criterion'"=="AUC"  )  replace `tempsort'=  -`evaluation'  // find largest accuracy
    sort `tempsort', stable

	
	// advanced syntax needed for list, subvarname
	char `evaluation'[varname] "`: variable label `evaluation''"
	char `tune1'[varname] "`: variable label `tune1''"
	char `tune2'[varname] "`: variable label `tune2''"
	char `time'[varname] "`: variable label `time''"
	// list tune2 and tune 3 only if specified
	if "`par2name'"!=""    	list `evaluation' `tune1' `tune2'  `time'  in 1 , subvarname
	else     				list `evaluation' `tune1'          `time'  in 1 , subvarname
	
	if "`par2name'"!=""  	mkmat `tune1' `tune2' `evaluation' `time'  in 1/`counter', matrix(gridsearch)
	else 			  		mkmat `tune1' 		  `evaluation' `time'  in 1/`counter', matrix(gridsearch)
	
	// variable label of tune2 is empty if "`par2name'"==""
	local colnames  `:variable label `tune1'' `:variable label `tune2'' `:variable label `evaluation''  seconds
	matrix colnames gridsearch = `colnames'
	return matrix gridsearch = gridsearch
	
	local one=`tune1' in 1
	local two=`tune2' in 1
	return scalar  tune1 =`one'
	return scalar tune2 =`two'
	
	restore 
end
//////////////////////////////////////////////////////////////////////////////////////
// evaluate criterion "accuracy" when a single variable is given. 
// pred could be  an indicator, multinomial, or a probability.
// This program does not handle the case where multiple multinomial probabilities are given .

// pred  variable of predicted values
// res   variable ; 1 if pred=y , 0 if not.
// y  	 variable with true values
// train training data variable
cap program drop critaccuracy
program define critaccuracy, rclass
	version 14.0
	syntax [if] [in],  pred(str) y(str)
	
	tempvar result
	qui gen `result'=.   
	qui sum `pred'
	if (r(min)<0) {
		di as error `"Some predictions are negative. "'
		di as error `"Criterion "accuracy" requires  classifications (0,1,2,..,n_categories) or probabilities."'  
		exit 411
	}	
	else if r(max)<=1  {
		// if values are in the range of [0,1] and there are more than two levels, these are probabilities 
		qui tab `pred'   // caution : tab might break when the number of levels is very, very large. 
		if r(r)>2 {
			di as error "Predictions are probabilities. Please supply classes (0/1) to assess criterion accuracy" as res "" 
			exit 99
			//	di as res "Predictions are probabilities. Rounding probabilities to assess criterion accuracy"
			//	qui replace `pred'=round(`pred')
		}
	}
	
	qui replace `result'= `pred'==`y'    `if' `in'   //  if included

	qui sum `result' // sum ignores missing
	local eval=r(mean)

	return local eval `eval'
end 
//////////////////////////////////////////////////////////////////////////////////////////////
cap program drop critmse
program define critmse, rclass
	version 14.0
	syntax [if][in] ,  pred(str) y(str) 
	tempvar res_sqr
	qui gen `res_sqr'=.
	qui replace `res_sqr'= (`y' - `pred')^2   `if' `in'   // if included

	qui sum `res_sqr'  // sum ignores missing
	local mse = r(mean)
	local rmse= sqrt(r(mean))
	
	return local rmse `rmse'
	return local mse `mse'
end
//////////////////////////////////////////////////////////////////////////////////////////////
// Find out whether the variable is in  increasing sort order
cap program drop checksorterror
program define checksorted , rclass
    version 14.0
	syntax varlist(min=1 max=1 numeric) 
	
	local y `varlist'
	tempvar diff
	// difference of two successive values
	qui gen `diff'=.
	qui replace `diff'= `y'- `y'[_n-1] if _n>1
	qui sum `diff'
	if (r(min)>0) {
		return scalar sorted = 1   // ascending
	}
	else {
		return scalar sorted = 0 
	}
end
/////////////////////////////////////////////////////////////////////////////////////////////////
//average over the folds
// nfolds: number of folds
// folds: variables with values 1..nfolds
cap program drop evaluate_crit_av
program define evaluate_crit_av , rclass
	version 16.0
	syntax [if] [in] , pred(str) y(str) criterion(str) evaluation(str) nfolds(int) folds(str)
	
	// check nfolds is consistent with folds
	qui sum `folds'
	assert r(min)==1
	assert r(max)==`nfolds'

	local eval=0 // av evaluation in fold
	foreach i of numlist  1/`nfolds' {
		evaluate_crit if `folds'==`i', pred("`pred'") y(`y') criterion(`criterion') ///
			evaluation(`evaluation')
		local eval= `eval' + r(eval)
	}
	local eval= `eval' / `nfolds'

	return scalar eval_av=`eval'
end
/////////////////////////////////////////////////////////////////////////////////////////////////
//evaluate criterion
cap program drop evaluate_crit
program define evaluate_crit , rclass
	version 14.0
	syntax [if] [in] , pred(str) y(str) criterion(str) evaluation(str)
											
	if ("`criterion'"=="accuracy") {
		label var `evaluation' "accuracy"
		critaccuracy `if' `in', pred(`pred') y(`y') 
		local eval=r(eval)
	}
	else if ("`criterion'"=="mse") {
		label var `evaluation' "mse"
		critmse `if' `in', pred(`pred') y(`y') 
		local eval=r(mse)
	}
	else if ("`criterion'"=="rmse") {
		label var `evaluation' "rmse"
		critmse `if' `in', pred(`pred') y(`y') 
		local eval=r(rmse)
	}
	else if ("`criterion'"=="AUC") {
		label var `evaluation' "AUC"
		qui tab `pred'
		if r(r)==2 {
			di as error "Warning: Predictions have only two distinct values." 
			di as error "To compute an AUC, need a score or probability." as res ""
		}
		qui roctab `y' `pred' `if' `in'
		local eval=r(area)
	}
	else {
		di as error("unknown criterion: `criterion'")
		exit 198
	} 
	return scalar eval=`eval'
end
/////////////////////////////////////////////////////////////////////////////////////////////////
// debugging program that lists observations in training data. 
//  Obs exluded by [if][in] are not listed.
cap program drop list_included
program define list_included
	version 14.0
	syntax , y(str) train(str)
	
	// use "sum `y'" as a kind of checksum
	sum `y' if `train'
	tempvar include id
	gen `id'=_n
	gen `include'=0
	replace `include'=1 if `train' 
	list `id' `include'
end
/////////////////////////////////////////////////////////////////////////////////////////////////
//Purpose : erase predictions from previous boost runs if they exist. 
// Overview boost predictions with pred() option: 
// multinomial variables: pred1 ... predk; e(predictlabels) "0.00000 1.000000"; e(predmat) n*k (no column names)
//		boost_predict x: creates vars  x1...xk (with labels)
// bernoulli variables: pred; e(predictlabels) not supplied; predmat  n*1
//		boost_predict x: creates var   x (without label)
cap program drop erase_predvars
program define erase_predvars
	version 14.0
	syntax , predvar(str)
	
	cap drop `predvar'  // redundant because later erase anyways; but may as well
	// if multinomial boosting erase `predvar'1, `predvar'2, .... while they exist
	local i=0
	while (`i'==0 | _rc==0) {
		local i=`i'+1
		capture confirm variable `predvar'`i'
		if _rc==0   drop `predvar'`i'
	}
end 
/////////////////////////////////////////////////////////////////////////////////////////////////
// Purpose: parse "method(str1 str2)"   str1=`method' str2=`methodarg'
cap program drop parse_method
program parse_method, rclass
  version 15.0
  syntax , method(str)

  tokenize `method'
  if ("`1'"=="trainfraction")   confirm number `2'
  else if ("`1'"=="trainvar")   confirm existence `2'
  else if ("`1'"=="cv")   		confirm integer number `2'
  else { 
		di as err "Invalid method"
		exit 198
  }
  
  // check cv to be positive
  if ("`1'"=="cv" & `2'<=0)  {
	di as err "method(cv arg) : arg must be positive" as res "" 
	exit 198 
  }
  // check fraction to be between 0 and 1
  if ("`1'"=="trainfraction" & (`2'<=0 | `2'>1))  {
	di as err "method(trainfraction arg) : arg must be 0<arg<=1" as res "" 
	exit 198 
  }
  
  // check trainvar variable has 0/1's 
  if ("`1'"=="trainvar") {
    confirm numeric variable `2'
    qui sum `2'
	if r(min)!=0 {
		di as error "`2' minimal value is not 0. `2' must be a 0/1 indicator variable and 0s must occur."
		exit 198
	}
	if r(max)!=1 {
		di as error "`2' max value is not 1. `2' must be a 0/1 indicator variable and 1s must occur."
		exit 198
	}
  }

  return local method ="`1'"
  return local methodarg ="`2'"
end 
/////////////////////////////////////////////////////////////////////////////////////////////////
/*
 version 0.1.0  June, 2017
 version 0.1.1  Oct 21, 2018,  made sort stable
 version 0.1.2  Nov 19, 2018,  revise critmse, added rmse criterion
 version 0.1.3  Nov 21, 2018,  support factor variables (fv)
 version 0.2.0  Apr 22, 2020,  trainvar 
 version 0.2.1  Apr 22, 2020,  [if][in]
 version 0.2.2  May 5,  2020,  crossvalidation
 version 0.2.3  May 9,  2020,  rewrote handling of boosting
 version 0.2.4  May 16, 2020,  new method option replacing 3 others
 version 0.2.5  May 20, 2020,  catch invalid `trainvar' values
 version 0.2.6  May 22, 2020,  criterion AUC
 version 0.2.7  Jun 22, 2020,  average criterion over folds, not over obs
 version 1.0.0  Oct 27, 2020,  changed to rclass
*/
