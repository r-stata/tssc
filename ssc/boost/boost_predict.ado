capture program drop boost_predict
program define boost_predict
*! version 1.2.0  May 9, 2020,  Matthias Schonlau

	version 15.0
	syntax anything(name = predict) [if][in] ,  [ class ]
	
	marksample touse, novarlist

	matrix pmatrix = e(predmat)
	local names : colnames pmatrix
	local predictlabels = e(predictlabels)
	local L = wordcount("`predictlabels'")
	
	tokenize `predict', parse(*)
	local predictname = "`1'"
	if "`L'" == "1" {
		matrix colnames pmatrix = `predict'
		svmat pmatrix, names(col)
		label var `predictname' "`predictlabels'"
		replace `predictname'=. if !`touse'
		//note: this does not test for distribution=bernoulli, because the info is not in ereturn
		if ("`class'"!="")  replace `predictname' = round(`predictname')  // round probabilities
	}
	else {
		svmat pmatrix, names("`1'")
		tokenize "`predictlabels'"
		foreach i of numlist 1/`L' {
			label var `predictname'`i' "``i''"
			replace `predictname'`i' =. if !`touse'
		}
		boost_multinomial_class, kgroups(`L') predictname(`predictname')
	}
	
	
	// decided not to remove the matrix predmat to allow multiple predict statements	
end
*******************************************************************************************
// multinomial boosting: generate single var `predictname' and fill with predicted class
program boost_multinomial_class
	version 15.0
	syntax ,   kgroups(int) predictname(str)
	
	// convert probabilities in `predictname'1 `predictname'2.. into a single variable with classes
	tempvar pred_max   // egen requires a newvar each time
	qui egen `pred_max'= rowmax(`predictname'1-`predictname'`kgroups')  //the hyphen assumes the variables appear in that sequence

	// put the class into `predictname'
	qui gen `predictname' = .
	label var `predictname'  "predicted class"
	foreach var of varlist `predictname'1-`predictname'`kgroups' {
		// boosting prediction variable label contains category name (variable label; not value label)
		qui replace `predictname'=`: var label `var'' if `pred_max'==`var' & `pred_max'!=.  
	}
	
end
*******************************************************************************************
/*
Revision history
Version date 
1.2.0   May 9 , 2020  If multinomial, create `predictname' variable with classes 
					   in addition to `predictname1'..`predictnamek'
1.1.0   Feb 18, 2019  Predict allows [if][in] option. Useful for crossvalidation.
original version   July 4, 2018
*/