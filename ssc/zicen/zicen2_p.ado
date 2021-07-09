program zicen2_p
   version 12 
	syntax anything(id="newvarname") [if] [in] [, POSterior EQuation(string) PRob YStar ]
	syntax newvarname [if] [in] [, * ]
	
	if "`equation'" != "" & "`posterior'" == "posterior" & "`prob'" == "prob" & "`ystar'"=="ystar" {
	   di as error "Not all options can be specified together"
		exit
	}
	
	if "`ystar'" == "ystar" & "`equation'" == "" & "`posterior'" == "" & "`prob'" == "" {
	   di as error "Option ystar requires option equation"
		exit
	}

	quietly { 
  		tempvar  xb1 xbc1 lpr1 pr0 pr1 lnsigma1 sigma1 denom
		_predict `typlist' `xb1' `if' `in', equation(eq1)
		_predict `typlist' `lnsigma1' `if' `in', equation(lnsigma1)
		gen double `sigma1' = exp(`lnsigma1')
		gen double `xbc1' = normal(`xb1'/`sigma1')*(`xb1'+`sigma1'* ///
		                             normalden(-`xb1'/`sigma1')/normal(`xb1'/`sigma1'))
		_predict `typlist' `lpr1' `if' `in', equation(imlogitp1)
		gen double `denom' = 1+exp(`lpr1')
		gen double `pr1' = exp(`lpr1')/`denom'
		gen double `pr0' = 1-`pr1'
   }
		
	if "`equation'" != "" & "`posterior'" == "" & "`prob'" == "" & "`ystar'" == "" {
		_predict `typlist' `varlist' `if' `in', equation(`equation')
		label variable `varlist' "Predicted (latent) mean for equation `equation'"
		di as text "No options; latent variable prediction"
		exit
	}
	
	if "`equation'" != "" & "`posterior'" == "" & "`prob'" == "" & "`ystar'" == "ystar" {
		if "`equation'" == "eq1" {
		   gen `typlist' `varlist' `if' `in' = `xbc1'
		}						  
		label variable `varlist' "Predicted (censored) mean for equation `equation'"		
		exit
	}		
	   
	if "`equation'" == "" & "`posterior'" == "" & "`ystar'" == "" & "`prob'" == "" {
	   di as text "Mean (censored) prediction weighted by estimated probabilities"
		gen `typlist' `varlist' `if' `in' = `pr0'*0+`pr1'*`xbc1' 		
		label variable `varlist' "Predicted (censored) mean weighted by estimated probabilities"
		exit
	}
	
	if "`prob'" == "prob" {
	   if "`equation'" == ""  {
	      di as error "Option prob requires equation" 
		   exit 
	   }
		
	   if "`equation'" != "eq1" & "`equation'" != "eq2"   {
	      di as error "Option equation must be eq1 or eq2" 
		   exit 
	   }

		quietly {
		   tempvar  lpr1 pr1 denom
		   _predict `typlist' `lpr1' `if' `in', equation(imlogitp1)
		   gen double `denom' = 1+exp(`lpr1')
		   gen double `pr1' = exp(`lpr1')/`denom'
	   }
	   if  "`equation'" == "eq1" { 
   		gen `typlist' `varlist' `if' `in' = `pr1' 		
	   	label variable `varlist' "Predicted estimated probability for eq(imlogitp1)"
		   exit
		} 
	}
	
	if "`posterior'" == "posterior" {
	   if "`equation'" == ""  {
	      di as error "Option posterior requires equation" 
		   exit 
	   }
  	   if "`equation'" != "eq1" & "`equation'" != "eq2"   {
	      di as error "Option equation must be eq1 or eq2" 
		   exit 
	   }

   tempvar denomprob0 denomprobg0

	local yvar = word(e(depvar), 1)
			
	qui gen double `denomprob0' = `pr0'+`pr1'*normal(-`xb1'/`sigma1') if `yvar'==0												
	qui gen double `denomprobg0'= `pr1'*normalden(`yvar',`xb1',`sigma1') if `yvar'>0
		
	if "`equation'" == "eq1" {
	   qui gen      `typlist' `varlist'= .
		qui replace `varlist' =(`pr1'*normal(-`xb1'/`sigma1'))/`denomprob0' ///
			                      if `yvar'==0
		qui replace `varlist' =(`pr1'*normalden(`yvar',`xb1',`sigma1'))/`denomprobg0' ///
			                      if `yvar'>0										 
	}										 										 
		
	label variable `varlist' "Posterior probability for `equation'"
	exit
	}		
end	
