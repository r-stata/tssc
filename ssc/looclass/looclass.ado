*! 2.3.0 Ariel Linden 24Dec2018 	// Added "sort touse" before LOO loop to ensure that LOO properly captures if/in criteria
*! 2.2.0 Ariel Linden 20Aug2018 	// Added -svmachines- and -boost- as model options
									// Added p-value to table to compare full with test data
*! 2.0.0 Ariel Linden 15Nov2017 // Added the model option and included randomforest as choice of model
*! 1.1.0 Ariel Linden 15Nov2017 // Added the "save" option
*! 1.0.1 Ariel Linden 05Oct2017 // cleaned up the locals for roc1 and roc2, changed train to full, changed version to 11 from 13
*! 1.0.0 Ariel Linden 06Jun2015

program define looclass, rclass
version 11.0

	syntax varlist(min=2 numeric fv) [if] [in] 		///
				[fweight iweight pweight]  ,  		///
				MODel(string)						///
				[CUToff(real 0.50) 					///
				SAve								///
				FIGure *]                               


	quietly {
	
	// Get Y and X variables
	gettoken dvar xvar : varlist
	
	marksample touse
	count if `touse'
	if r(N) == 0 error 2000
	local N = r(N)
	replace `touse' = -`touse'

	// Verify that depvar is binary //
	tabulate `dvar' if `touse' 
	if r(r) != 2 { 
		di as err "`dvar' must have exactly two values (coded 0 or 1)."
		exit 420  
	} 
    else if r(r) == 2 { 
		capture assert inlist(`dvar', 0, 1) if `touse' 
		if _rc { 
			di as err "`dvar' must be coded as either 0 or 1."
			exit 450 
			}
	}

	
	if `cutoff'<0 | `cutoff'>1 { 
                di in red `"cutoff() must be between 0 and 1"'
                exit 198
    }

	tempvar full1 full2 yhat1 yhat2 test
	
	************************
	// Full data
	************************
	
	// run model on full sample
	if "`model'" == "probit" {
		probit `dvar' `xvar' if `touse' [`weight' `exp'], `options'
		predict `full2' if `touse'
	}
	else if "`model'" == "logit" {
		logit `dvar' `xvar' if `touse' [`weight' `exp'], `options'
		predict `full2' if `touse'
	}
	else if "`model'" == "randomforest" {
		randomforest `dvar' `xvar' if `touse', type(class) `options'
		predict `full1' `full2' if `touse', pr
	}
	else if "`model'" == "boost" {
		boost `dvar' `xvar' if `touse', distribution(logistic) predict(`full2') `options'
		replace `full2' = . if !`touse'
	}
	else if "`model'" == "svmachines" {
		tempvar dvar2
		gen byte `dvar2' = `dvar' // replicate dvar to avoid value labels
		svmachines `dvar2' `xvar' if `touse', prob `options'
		predict fullSVM if `touse', prob // hardcoded variables are needed for predictions in svmachines
		local full2 fullSVM_1
	}
	local full `full2'
	
	// collect cell values for classification
	count if `dvar' !=0 & `full' >= `cutoff' & `touse'
	local a1 = r(N)
                
	count if `dvar' ==0 & `full' >= `cutoff' & `touse'
	local b1 = r(N)
                
	count if `dvar' !=0 & `full' <`cutoff' & `touse'
	local c1 = r(N)
                
	count if `dvar' ==0 & `full' <`cutoff' & `touse'
	local d1 = r(N)
	
	
	************************
	// test (LOO) data
	************************
		
	// run chosen model on test (loo) sample
	gen `test'=.
	} //end quietly
	
	// fancy setup for dots
	di _n
    di as txt "Iterating across (" as res `N' as txt ") observations"
	di as txt "{hline 4}{c +}{hline 3} 1 " "{hline 3}{c +}{hline 3} 2 " "{hline 3}{c +}{hline 3} 3 " "{hline 3}{c +}{hline 3} 4 " "{hline 3}{c +}{hline 3} 5 "
	
	//loop through observations
	sort `touse'
	forval i = 1/`N' {
		_dots `i' 0

		quietly {
		
			if "`model'" == "probit" {
				probit `dvar' `xvar' if _n!=`i' & `touse' [`weight' `exp'], `options'
				predict `yhat2' if _n==`i' & `touse'
			}
			else if "`model'" == "logit" { 
				logit `dvar' `xvar' if _n!=`i' & `touse' [`weight' `exp'], `options'
				predict `yhat2' if _n==`i' & `touse'
			}
			else if "`model'" == "randomforest" { 
				randomforest `dvar' `xvar' if _n!=`i' & `touse', type(class) `options'
				predict `yhat1' `yhat2' if _n==`i' & `touse', pr
				drop `yhat1'
			}
			else if "`model'" == "boost" {
				boost `dvar' `xvar' if _n!=`i' &`touse', distribution(logistic) predict(`yhat2') `options'
				replace `yhat2' = . if !`touse' & _n!=`i' 
			}
			else if "`model'" == "svmachines" {
				svmachines `dvar2' `xvar' if _n!=`i' &`touse', prob `options'
				predict yhatSVM if _n==`i', prob
				local yhat2 yhatSVM_1
				drop yhatSVM yhatSVM_0
			}
			replace `test' = `yhat2' if _n==`i' & `touse'
			drop `yhat2'

		} //end quietly
	} // end forval
	
	
	quietly {
	// collect cell values for classification
		count if `dvar' !=0 & `test' >=`cutoff' & `touse'
		local a2 = r(N)
                
		count if `dvar' ==0 & `test' >= `cutoff' & `touse'
		local b2 = r(N)
                
		count if `dvar' !=0 & `test' <`cutoff' & `touse'
		local c2 = r(N)
                
		count if `dvar' ==0 & `test' <`cutoff' & `touse'
		local d2 = r(N)

		// collect values for ROC area
		roctab `dvar' `full'
		local roc1 : di %05.4f r(area)
	
		roctab `dvar' `test'
		local roc2 : di %05.4f r(area)
		
		roccomp `dvar' `full' `test'
		local rocp : di %05.4f r(p)
	} // end quietly
	
	* Graph the ROC curves
	if "`figure'" != "" {
		roccomp `dvar' `full' `test' , graph legend(rows(2) order(1 2 3)  label(1 "Full ROC area: `roc1'") label(2 "Test ROC area: `roc2'") label(3 "Reference") )
	}

	if "`save'" != "" {
	gen full = `full'
	label var full "Full-sample predictions"
	gen test = `test'
	label var test "Test-sample predictions"
	}
	
	
	/* double save in S_# and r() */
    
	* for full data
	ret scalar P_corr_1 = ((`a1'+`d1')/(`a1'+`b1'+`c1'+`d1'))*100 /* correctly classified */
	ret scalar P_p1_1 = (`a1'/(`a1'+`c1'))*100     				/* sensitivity          */
	ret scalar P_n0_1 = (`d1'/(`b1'+`d1'))*100     				/* specificity          */
	ret scalar P_p0_1 = (`b1'/(`b1'+`d1'))*100     				/* false + given ~D     */
	ret scalar P_n1_1 = (`c1'/(`a1'+`c1'))*100     				/* false - given D      */
	ret scalar P_1p_1 = (`a1'/(`a1'+`b1'))*100     				/* + pred value         */
	ret scalar P_0n_1 = (`d1'/(`c1'+`d1'))*100     				/* - pred value         */
	ret scalar P_0p_1 = (`b1'/(`a1'+`b1'))*100     				/* false + given +      */
	ret scalar P_1n_1 = (`c1'/(`c1'+`d1'))*100     				/* false - given -      */
	ret scalar roc1 = `roc1'									/* roc curve 		    */
	* for test data
	ret scalar P_corr_2 = ((`a2'+`d2')/(`a2'+`b2'+`c2'+`d2'))*100 /* correctly classified */
	ret scalar P_p1_2 = (`a2'/(`a2'+`c2'))*100     				/* sensitivity          */
	ret scalar P_n0_2 = (`d2'/(`b2'+`d2'))*100     				/* specificity          */
	ret scalar P_p0_2 = (`b2'/(`b2'+`d2'))*100     				/* false + given ~D     */
	ret scalar P_n1_2 = (`c2'/(`a2'+`c2'))*100     				/* false - given D      */
	ret scalar P_1p_2 = (`a2'/(`a2'+`b2'))*100     				/* + pred value         */
	ret scalar P_0n_2 = (`d2'/(`c2'+`d2'))*100     				/* - pred value         */
	ret scalar P_0p_2 = (`b2'/(`a2'+`b2'))*100     				/* false + given +      */
	ret scalar P_1n_2 = (`c2'/(`c2'+`d2'))*100     				/* false - given -      */
	ret scalar roc2 = `roc2'									/* roc curve 		    */
	ret scalar rocp = `rocp'									/* diff between curves  */
	
	if "`model'" == "svmachines" { 
		drop fullSVM fullSVM_1 fullSVM_0
	}
	
    #delimit ; 
 	di _n ;	
	di _n in gr `"Classification Table for Full Data:"' ;
		
		
	di _n in smcl in gr _col(15) "{hline 8} True {hline 8}" _n
                    `"Classified {c |}"' _col(22) `"D"' _col(35) 
                    `"~D  {c |}"' _col(46) `"Total"' ;
    di    in smcl in gr "{hline 11}{c +}{hline 26}{c +}{hline 11}"  ;
    di    in smcl in gr _col(6) "+" _col(12) `"{c |} "'
              in ye %9.0g `a1' _col(28) %9.0g `b1'
              in gr `"  {c |}  "'
              in ye %9.0g `a1'+`b1' ;
    di    in smcl in gr _col(6) "-" _col(12) "{c |} "
              in ye %9.0g `c1' _col(28) %9.0g `d1'
              in gr `"  {c |}  "'
              in ye %9.0g `c1'+`d1' ;
    di    in smcl in gr "{hline 11}{c +}{hline 26}{c +}{hline 11}"  ;
    di    in smcl in gr `"   Total   {c |} "'
              in ye %9.0g `a1'+`c1' _col(28) %9.0g `b1'+`d1'
              in gr `"  {c |}  "'
              in ye %9.0g `a1'+`b1'+`c1'+`d1' ;
        
	di _n ;	
    di _n in gr `"Classification Table for Test Data:"' ;
		
		
	di _n in smcl in gr _col(15) "{hline 8} True {hline 8}" _n
                    `"Classified {c |}"' _col(22) `"D"' _col(35) 
                    `"~D  {c |}"' _col(46) `"Total"' ;
    di    in smcl in gr "{hline 11}{c +}{hline 26}{c +}{hline 11}"  ;
    di    in smcl in gr _col(6) "+" _col(12) `"{c |} "'
              in ye %9.0g `a2' _col(28) %9.0g `b2'
              in gr `"  {c |}  "'
              in ye %9.0g `a2'+`b2' ;
    di    in smcl in gr _col(6) "-" _col(12) "{c |} "
              in ye %9.0g `c2' _col(28) %9.0g `d2'
              in gr `"  {c |}  "'
              in ye %9.0g `c2'+`d2' ;
    di    in smcl in gr "{hline 11}{c +}{hline 26}{c +}{hline 11}"  ;
    di    in smcl in gr `"   Total   {c |} "'
              in ye %9.0g `a2'+`c2' _col(28) %9.0g `b2'+`d2'
              in gr `"  {c |}  "'
              in ye %9.0g `a2'+`b2'+`c2'+`d2' ;		
		
	di _n ;	
	di _n in gr `"Classified + if predicted Pr(D) >= `cutoff'"' _n
                    `"True D defined as `y' != 0"' ;
        
	di    in gr _col(45) `"Full"' _col(58) `"Test"';
	di    in smcl in gr "{hline 64}" ;
    di    in gr `"Sensitivity"' _col(33) `"Pr( +| D)"'
              in ye %8.2f return(P_p1_1) `"%"' _col(55) in ye %8.2f return(P_p1_2) `"%"' _n
              in gr `"Specificity"' _col(33) `"Pr( -|~D)"'
              in ye %8.2f return(P_n0_1) `"%"' _col(55) in ye %8.2f return(P_n0_2) `"%"' _n
              in gr `"Positive predictive value"' _col(33) `"Pr( D| +)"'
              in ye %8.2f return(P_1p_1) `"%"' _col(55) in ye %8.2f return(P_1p_2) `"%"' _n
              in gr `"Negative predictive value"' _col(33) `"Pr(~D| -)"'
              in ye %8.2f return(P_0n_1) `"%"' _col(55) in ye %8.2f return(P_0n_2) `"%"' ;
    di    in smcl in gr "{hline 64}"  ;
    di    in gr `"False + rate for true ~D"' _col(33) `"Pr( +|~D)"'
              in ye %8.2f return(P_p0_1) `"%"' _col(55) in ye %8.2f return(P_p0_2) `"%"' _n
              in gr `"False - rate for true D"' _col(33) `"Pr( -| D)"'
              in ye %8.2f return(P_n1_1) `"%"'  _col(55) in ye %8.2f return(P_n1_2) `"%"' _n
              in gr `"False + rate for classified +"' _col(33) `"Pr(~D| +)"'
              in ye %8.2f return(P_0p_1) `"%"' _col(55) in ye %8.2f return(P_0p_2) `"%"' _n
              in gr `"False - rate for classified -"' _col(33) `"Pr( D| -)"'
              in ye %8.2f return(P_1n_1) `"%"' _col(55) in ye %8.2f return(P_1n_2) `"%"';
    di    in smcl in gr "{hline 64}"  ;
    di    in gr `"Correctly classified"' _col(42) 
              in ye %8.2f return(P_corr_1) `"%"' _col(55) in ye %8.2f return(P_corr_2) `"%"' ;
    di    in smcl in gr "{hline 64}"  ;
	di    in gr `"ROC area"' _col(42)
			  in ye %9.4f return(roc1)  _col(55) in ye %9.4f return(roc2)  ;
	di    in smcl in gr "{hline 64}"  ;
	di    in gr `"p-value for Full vs Test ROC areas"' _col(42)
			  _col(55) in ye %9.4f return(rocp)  ;
	di    in smcl in gr "{hline 64}"  ;
	

end ;

