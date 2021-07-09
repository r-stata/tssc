* This line loads the plugin if not already loaded
program boost_plugin, plugin

***********************************************************************************************
program define boost, eclass
*! version 1.3.2  May, 2020 Matthias Schonlau

 version 8.1
 syntax [varlist] [if] [in], DISTribution(str)  [ INfluence maxiter(int 20000)  /*
  	*/ PREDict(str) TRAINfraction(real 0.8)	/*	
	*/ shrink(real 0.01) bag(real 0.5)  INTERaction(int 5) /* 
	*/ seed(int 0) ] 
	
 version 16: marksample touse , novarlist
  		
 local k : word count `varlist' 
 if `k'<2  {
   di as error " Error: need at least 2 variables" 
   exit
 }
 local y : word 1 of `varlist'
 local xvarlist: list varlist -y


 local kgroups=1
 if ("`distribution'"=="multinomial") {
	qui tab `y' `if' `in'  // only training data 
	local kgroups=r(r)
	multinom_check_categories `y' `if' `in'
 } 

 *prepare matrix to transport `kgroups' values per variable back from c++ program
 tempname influence_mat
 tempname A

 
 matrix `A'=(-1)
 while (colsof(`A')<`kgroups') {
	matrix `A'= `A' , -1
 }

 matrix  `influence_mat'= `A'
  while (rowsof(`influence_mat')< `k'-1) {
 	 matrix `influence_mat' = `influence_mat' \ `A'
  }
 
 matrix rownames `influence_mat' = `xvarlist'



 *prepare matrix to transport one value per iteration back from c++ program
 tempname lltrain_mat
 tempname lltest_mat
 tempname B
 matrix `B'=(-1)
 matrix `lltrain_mat'= `B'
 matrix `lltest_mat'= `B'
 * 40 is the default maximum matrix size
 while (rowsof(`lltrain_mat')< 40) { 
	matrix `lltrain_mat' = `lltrain_mat' \ `B'
	matrix `lltest_mat' = `lltest_mat' \ `B'
 }

 if (length("`distribution'")==0) {
	local distribution="normal"
 }
 if ("`distribution'"!="poisson" & "`distribution'"!="logistic" & "`distribution'"!="normal" & "`distribution'"!="multinomial" & "`distribution'" != "bernoulli") {
      di as error "Error: Distribution must be one of: normal, logistic/bernoulli, poisson, multinomial"
	exit
 }

 * prepare prediction; compute number of prediction variables needed (kgroups) 
 if (length("`predict'")==0) {
	local predict="nopredict"
 }

 foreach i of numlist 1/`kgroups' {
	tempvar temp_predict`i'
	qui gen `temp_predict`i''=.
 }


 local influence = "`influence'" != ""
 if (`influence'==1) {
	di "influence"
 }
 
 di  "Distribution=`distribution'"
 if ("`distribution'"=="multinomial") {
 	di "	Number of categories (in training data): `kgroups'"
 }
 di  "predict=`predict'"
 di  "Trainfraction=`trainfraction' Shrink=`shrink' Bag=`bag' maxiter=`maxiter' Interaction=`interaction'"
 local nleafs=`interaction'+1
 
 if ("`distribution'" == "bernoulli") {
 	local distribution = "logistic"
 }
 
 // to enable the predict statement after boost, the predict needs to be set always
 // the "predict" option of boost is preserved and re-activated just below the plugin call
 local preserve_predict = "`predict'"  
 local predict = "predict"
 plugin call boost_plugin `varlist' `temp_predict1'-`temp_predict`kgroups'' `if' `in',  /*
       	*/ `maxiter' `nleafs' `shrink' `bag' `distribution' /*
 	*/ `trainfraction'  `influence' `predict' `influence_mat' `seed' /*
  	*/ `lltrain_mat' `lltest_mat' `kgroups'
 
 local predict = "`preserve_predict'"
 ereturn clear
 
 
 di as res "bestiter= " iter
 ereturn scalar bestiter = iter
 
 *di as res "test ll0= " test_ll0
 ereturn scalar test_ll0 = test_ll0
 
 *di as res "test ll1= " test_ll1
 ereturn scalar test_ll1 = test_ll1
 
 di as res "Test R2= " test_R2
 ereturn scalar test_R2 = test_R2
 
 di as res "trainn= " trainn
 ereturn scalar trainn = trainn
 
 *di as res "train ll0= " train_ll0
 ereturn scalar train_ll0 = train_ll0
 
 *di as res "train ll1= " train_ll1
 ereturn scalar train_ll1 = train_ll1
 
 di as res "Train R2= " train_R2
 ereturn scalar train_R2 = train_R2
 
 
 if (`influence') {
  if ("`distribution'"=="multinomial") {
  	matrix colnames `influence_mat' = `colnames'
  }
  if (wordcount("`varlist'") < 22) {
  display as result "Influence of each variable (Percent):"
  matrix list `influence_mat', noblank noheader
 }
  ereturn matrix influence =  `influence_mat' 
 }
 /////////////////////////////////////////////////
 //Add at July 2018. Seperate the predict file.
 local temppredlist = ""
 foreach i of numlist 1/`kgroups' {
 	local temppredlist = "`temppredlist' `temp_predict`i''"
 }
 mata: pred_matrix("`temppredlist'", "pmatrix")
 ereturn matrix predmat = pmatrix
 ereturn local predict "boost_predict"
 /////////////////////////////////////////////////
 if ("`predict'"!="nopredict") {
 	* for regular predictions use the variable name supplied by user
 	if `kgroups'==1 {
 		gen `predict'=`temp_predict1'
 	}
 	else {
 		* for multinomial use append  1..kgroups to name; label variable
 		foreach i of numlist 1/`kgroups' {
 			gen `predict'`i'=`temp_predict`i''
 			label var `predict'`i' "`predlabel`i''"
 		}
 	}
 }
 //store the predict labels names to ereturn for the separate predict variables
 local predictlabels = ""
 foreach i of numlist 1/`kgroups' {
 		local predictlabels = "`predictlabels' `predlabel`i''"
 }
 ereturn local predictlabels = "`predictlabels'"
 /////////////////////////////////////////////////////
 // compute mse (normal, poisson), accuracy (bernoulli, multinomial) for test and train data
 // the c++ program copies all data that satisfy [if][in] into a new data matrix. The first trainn observations of the new data matrix are used for fitting.
 // i.e. take the first trainn among those that are `touse' 

 if ("`predict'"!="nopredict") {
     // id predict statement was specified
	
	// create a counter like _n , but only for `touse'
	tempvar  _n_touse order
	qui gen `_n_touse'=.
	qui gen `order' = _n
	sort `touse', stable
	by `touse': replace `_n_touse'= _n
	qui replace `_n_touse'=. if !`touse'
	sort `order'  // restore original sort order ; stable not needed (no duplicates)
	
 	if ("`distribution'"=="normal" || "`distribution'"=="poisson") {
	    // `_n_touse'<=scalar(trainn)  excludes obs for which `_n_touse'==.
 		compute_mse  if (`_n_touse'<=scalar(trainn) & `touse'),  pred(`predict') true(`y')
 		ereturn scalar train_mse = r(mse)
 		compute_mse  if (`_n_touse'>scalar(trainn) & `touse'),  pred(`predict') true(`y')
 		ereturn scalar test_mse = r(mse)
 	}
 	else if ("`distribution'"=="bernoulli" | "`distribution'"=="logistic") {
	    // predicted values are probabilities; needs rounding
 		compute_acc if (`_n_touse'<=scalar(trainn) & `touse'),  pred(round(`predict')) true(`y')
 		ereturn scalar train_accuracy = r(accuracy)
 		compute_acc if (`_n_touse'>scalar(trainn) & `touse'),  pred(round(`predict')) true(`y')
 		ereturn scalar test_accuracy = r(accuracy)
 	}
	else {
		// multinomial with `kgroups'
		// need to create a variable that predicts the group; not just probabilities
		qui gen `predict'_class=.
		egen `predict'=rowmax(`predict'1-`predict'`kgroups')
		foreach var of varlist `predict'1-`predict'`kgroups' {
			replace `predict'_`class'=`: var label `var'' if `predict'==`var'
		}
 		compute_acc if (`_n_touse'<=scalar(trainn) & `touse'), pred(`predict'_`class') true(`y')
 		ereturn scalar train_accuracy = r(accuracy)
 		compute_acc if (`_n_touse'>scalar(trainn) & `touse'),  pred(`predict'_`class') true(`y')
 		ereturn scalar test_accuracy = r(accuracy)

	}

 }
end 
**********************************************************************************************
* if distribution=multinomial, check whether the training data and the test data have the same 
*  number of categories
* training data are data restricted through if/in
* test data are the remaining data ignoring the if/in
program define multinom_check_categories
	version 13.0

	syntax varlist(min=1 max=1) [if] [in]
	qui tab `varlist' `if' `in'   // not all codes may be in the training data
	local n_codes=r(r)

	qui tab `varlist'  // all data
	local n_testcodes=r(r)
	if (`n_codes'!=`n_testcodes') {
		di as error "Warning: The number of categories in training data (restricted to [if][in])and full data differ"
		di as error "	Training data  `n_codes'" 	
		di as error "	Full data      `n_testcodes'"
		di as res   "" // switches back to black output
	}
end
***********************************************************************************************
// create a matrix of varlist in Mata and copy  to Stata
// Mata can have matrices of size larger than 11,000; a limitation of stata matrices.
// Interestingly, a mata matrix of size (e.g.) 12,000 in Mata can be copied successfully to Stata (version 15).
version 15.0
mata:
void pred_matrix(string varlist, string mname) {
	V = st_varindex(tokens(varlist))
    Data = st_data(.,V)
	st_matrix(mname, Data)
}
end
***********************************************************************************************
// computes accuracy of predictions
program  compute_acc, rclass
    version 16.0
    syntax  [if] [in] , pred(str) true(str) 

        //  obs excluded by [if] [in]
        marksample touse , novarlist
        qui count if `touse' 
        if r(N) == 0 { 
           error 2000 
        } 
        preserve 
        qui drop if !`touse'

        tempvar correct
        qui gen `correct'= `pred' == `true'
        qui sum `correct'
        local acc= r(mean)
 
        restore
        return scalar accuracy = `acc'
end
***********************************************************************************************
// computes mse of predictions
program compute_mse, rclass
    version 16
    syntax  [if] [in] , pred(str) true(str) 

        //  obs excluded by [if] [in]
        marksample touse , novarlist
        qui count if `touse' 
        if r(N) == 0 { 
           error 2000 
        } 
        preserve 
        qui drop if !`touse'

        tempvar  res_sqr
        qui gen `res_sqr'= (`pred' - `true')^2
        qui sum `res_sqr'
        local mse= r(mean)
 
        restore
        return scalar mse = `mse'
end
***********************************************************************************************
/*
Revision history
Version date 
1.3.2   May  9, 2020  boost_predict now generates var with predicted class in addition to 
                      vars with predicted probabilites
1.3.1   Dec  1, 2019  Added e(mse*),e(acc*). For multinomial distribution, new var `predict'_class  
			Improved output in influence_delete
1.3.0   Jul  4, 2018 Enabled predict after the boost command (in addition to predict option)
1.2.0   May 16, 2018  Added Linux and Mac, also influence_delete and influence_barchart
1.1.2   Jun 28, 2016 Allow partial trees (Three need not be fully grown)
1.1.1   Aug 16, 2013 add multinom_check_categories
1.1.0	May 27, 2013 add multinomial boosting (also predvars, kgroups, prediction and influence labels)
1.0.0   Feb 16,2012 cosmetic changes
0.0.9  	Aug18,2005  added rownames to influence_mat
0.0.8	Jun23,2005  number of iterations =min(maxiter,bestiter+100)
0.0.7   May 2,2005  remove crossvalidate, add trainfraction
0.0.6 	Jun20,2004  pass random generator into boosting model (affects bagging only), bagging tested
0.0.5   Jun2,2004   pseudoR2 defined as 1-L1/L0, affects crossvalidation non normal data
0.0.4	Mar8,2004   bugfix: graceful exit when cross validation and <5 obs
		    bugfix: graceful exit when fitting fails because of 
			tree fully extended within Cross validation
0.0.3   Mar3,2004   bugfix: graceful exit when cross validation with missing x-values
		      def of interaction changed (now 1=main effect, 2=2 way interact)
0.0.2   Feb6,2004   cosmetic changes
0.0.1   Feb5,2004   option bag not yet tested, specify bag(1) always
*/

