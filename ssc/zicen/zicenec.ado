/*
  
  This one uses the estimated probabilities to classify rather than 
  the posterior probabilities
  
  Changed so by default it is the censored prediction

*/ 


program zicenec
   version 12 
	syntax anything(id="newvarname") [if] [in] [, CLAss PREdiction]
	syntax newvarname [if] [in] [, * ]

	if ("`e(cmd)'" != "zicen") error 301
	
	if "`class'"=="class" & "`prediction'"=="prediction" {
	   di as error "Only one option can be specified"
		exit 198
	}

     if "`class'"=="" & "`prediction'"=="" {
	   di as error "One option must be specified"
		exit 198
	}

	// two classes
   if `e(classes)' == 2 {
	   tempvar prob1 prob0 max classi yhateq1
		
		quietly {
		   * predicted values
			predict `typlist' `yhateq1' `if' `in', equation(eq1) ystar
			
		   * predicted estimated probabilities by component
		   predict `typlist' `prob1' `if' `in', equation(imlogitp1) prob
		   gen `prob0' = 1- `prob1'
			
			* choose highest
         egen `max' = rowmax(`prob0' `prob1')
			
			* classify
		   gen     `classi' = 0 if `max' == `prob0'
			replace `classi' = 1 if `max' == `prob1'	
      }
		if "`class'"=="class" {
		   qui gen `varlist' = `classi'
			label var `varlist' "Class - max of estimated probs"
		}
	   if "`prediction'"==="prediction" { 
	      qui gen     `varlist' = 0         if `classi'==0
         qui replace `varlist' = `yhateq1' if `classi'==1
			label var `varlist' "Prediction based on estimated class membership"			
	   }
	}
	
	// three classes
	if `e(classes)' == 3 {
	   tempvar prob1 prob2 prob0 max classi yhateq1 yhateq2
		
		quietly {
		   * predicted values
			predict `typlist' `yhateq1' `if' `in', equation(eq1) ystar
			predict `typlist' `yhateq2' `if' `in', equation(eq2) ystar		
			
		   * predicted probabilities by component
		   predict `typlist' `prob1' `if' `in', equation(eq1) prob
		   predict `typlist' `prob2' `if' `in', equation(eq2) prob	
		   gen `prob0' = 1- `prob1' - `prob2' 
			
			* choose highest
         egen `max' = rowmax(`prob0' `prob1' `prob2')
			
			* classify
		   gen     `classi' = 0 if `max' == `prob0'
			replace `classi' = 1 if `max' == `prob1'
			replace `classi' = 2 if `max' == `prob2'	
      }
		if "`class'"=="class" {
		   qui gen `varlist' = `classi'
			label var `varlist' "Class - max of estimated probs"
		}
	   if "`prediction'"==="prediction" { 
	      qui gen     `varlist' = 0         if `classi'==0
         qui replace `varlist' = `yhateq1' if `classi'==1
         qui replace `varlist' = `yhateq2' if `classi'==2
			label var `varlist' "Prediction based on estimated class membership"			
	   }
	}				
end	
