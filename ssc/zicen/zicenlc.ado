program zicenlc
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

   if `e(classes)' == 2 {
	   tempvar probpost1 probpost0 max classi yhateq1
		
		quietly {
			predict `typlist' `yhateq1' `if' `in', equation(eq1) ystar
			
		   predict `typlist' `probpost1' `if' `in', equation(eq1) posterior
		   gen `probpost0' = 1- `probpost1'
			
         egen `max' = rowmax(`probpost0' `probpost1')
			
		   gen     `classi' = 0 if `max' == `probpost0'
			replace `classi' = 1 if `max' == `probpost1'	
      }
		if "`class'"=="class" {
		   qui gen `varlist' = `classi'
			label var `varlist' "Latent class - max of posterior probs"
		}
	   if "`prediction'"==="prediction" { 
	      qui gen     `varlist' = 0         if `classi'==0
         qui replace `varlist' = `yhateq1' if `classi'==1
			label var `varlist' "Prediction based on latent class membership"			
	   }
	}
	
	if `e(classes)' == 3 {
	   tempvar probpost1 probpost2 probpost0 max classi yhateq1 yhateq2
		
		quietly {
			predict `typlist' `yhateq1' `if' `in', equation(eq1) ystar
			predict `typlist' `yhateq2' `if' `in', equation(eq2) ystar		
			
		   predict `typlist' `probpost1' `if' `in', equation(eq1) posterior
		   predict `typlist' `probpost2' `if' `in', equation(eq2) posterior	
		   gen `probpost0' = 1- `probpost1' - `probpost2' 
			
         egen `max' = rowmax(`probpost0' `probpost1' `probpost2')
			
		   gen     `classi' = 0 if `max' == `probpost0'
			replace `classi' = 1 if `max' == `probpost1'
			replace `classi' = 2 if `max' == `probpost2'	
      }
		if "`class'"=="class" {
		   qui gen `varlist' = `classi'
			label var `varlist' "Latent class - max of posterior probs"
		}
	   if "`prediction'"==="prediction" { 
	      qui gen     `varlist' = 0         if `classi'==0
         qui replace `varlist' = `yhateq1' if `classi'==1
         qui replace `varlist' = `yhateq2' if `classi'==2
			label var `varlist' "Prediction based on latent class membership"			
	   }
	}				
end	
