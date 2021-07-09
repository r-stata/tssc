*! version 1.0 - Sept 2013
*! Marcelo Coca Perraillon - mcoca@uchicago.edu
*! Provide starting values

program zicen0
   version 12
	if replay() { 
	   if ("`e(cmd)'" != "zicen") error 301
		Replay `0'
	}
	else Estimate `0'
end

program Estimate, eclass sortpreserve
   syntax varlist(fv) [if] [in], [CLasses(string) ///
  	Level(cilevel) ///
	PROBability(varlist fv) ///
	noCONStant ///
	* ]

	mlopts mlopts rest, `options'  
	gettoken lhs rhs : varlist
   _fv_check_depvar `lhs'
			
	marksample touse
	markout `touse' `probability'
	
	if ("`classes'" != "2" & "`classes'" != "3") | "`classes'" == "" {
	   di as error "Option classes must be either 2 or 3"
		exit 198
	} 	

	if "`classes'" == "2" {
		if "`probability'"=="" {
		   di as text "Mixture with two classes"
		   ml model d0 zicen2_lf (eq1:`lhs'=`rhs', `constant') /imlogitp1 /lnsigma1 ///
										 if `touse', ///
										 `mlopts' ///
										 `rest' ///
										 missing nopreserve ///
										 maximize
	   	ereturn local cmd zicen
		   ereturn local classes "`classes'"
		   ereturn local predict "zicen2_p" 
			Replay
		}
		else {
		   di as text "Mixture with two classes with covariates in probability"
		   ml model d0 zicen2_lf (eq1:`lhs'=`rhs', `constant') (imlogitp1:`probability') ///
			                      /lnsigma1 if `touse', ///
										 `mlopts' ///
										 `rest' ///
										 missing nopreserve ///
										 maximize
			
		   ereturn local probability "`probability'"
			ereturn local cmd zicen
   		ereturn local classes "`classes'"
	   	ereturn local predict "zicen2_p"
			Replay
		}
	}
	
	if "`classes'" == "3" { 		
		if "`probability'"=="" {
		   di as text "Mixture with three classes"
		   ml model d0 zicen3_lf (eq1:`lhs'=`rhs', `constant') (eq2:`lhs'=`rhs', `constant') ///
			                      /imlogitp1 /imlogitp2 /lnsigma1 /lnsigma2 ///
										 if `touse', ///
										 `mlopts' ///
										 `rest' ///
										 missing nopreserve ///
										 maximize
   	   ereturn local cmd zicen	
	   	ereturn local classes "`classes'"
		   ereturn local predict "zicen3_p"				 
	      Replay									 
		}  
		else {
		   di as text "Mixture with three classes and covariates in probability"
		   ml model d0 zicen3_lf (eq1:`lhs'=`rhs', `constant') (eq2:`lhs'=`rhs', `constant') ///
			               (imlogitp1:`probability') (imlogitp2:`probability') /lnsigma1 /lnsigma2 ///
								if `touse', ///
								`mlopts' ///
								`rest' ///
								missing nopreserve ///
								maximize
			ereturn local probability "`probability'"
		   ereturn local cmd zicen	
   		ereturn local classes "`classes'"
	   	ereturn local predict "zicen3_p"
	      Replay									 
	   }	
		
	}	
end

program Replay, eclass 
   syntax [, Level(cilevel)]
	
	local probability `e(probability)'
   local classes      `e(classes)' 
	
	if "`classes'"=="3" {
	   if "`probability'"=="" {	
         ml display, neq(2) pl level(`level')
	      _diparm imlogitp1, label(/imlogitp1)
	      _diparm imlogitp2, label(/imlogitp2) 
	      _diparm __sep__
	      local den "(1+exp(@1)+exp(@2))"
	      _diparm imlogitp1 imlogitp2, label(p0) ci(logit) f(1-exp(@1)/(`den')-exp(@2)/(`den')) ///
	           d(-exp(@1)/(`den')^2 -exp(@2)/(`den')^2)                                                                                                   
         ereturn scalar p0_est = r(est)
	      ereturn scalar p0_se = r(se)	  

	      _diparm imlogitp1 imlogitp2, label(p1) ci(logit) f(exp(@1)/(`den'))	///
	           d(exp(@1)/`den'-exp(@1)^2/(`den')^2 -exp(@1)/(`den')^2*exp(@2))
	      ereturn scalar p1_est = r(est)
	      ereturn scalar p1_se = r(se)	  
	
         _diparm imlogitp2 imlogitp1, label(p2) ci(logit) f(exp(@1)/(`den'))	///
	           d(exp(@1)/`den'-exp(@1)^2/(`den')^2 -exp(@1)/(`den')^2*exp(@2))	  
         ereturn scalar p2_est = r(est)
	      ereturn scalar p2_se = r(se)	  
	   } 
	
	   else {
	       ml display, /*neq(4)*/ pl level(`level')
   	}
	
	   _diparm lnsigma1, exp label(sigma1)
	   ereturn scalar sigma1_est = r(est)
	   ereturn scalar sigma1_se = r(se)
	
	   _diparm lnsigma2, exp label(sigma2)
	   ereturn scalar sigma2_est = r(est)
	   ereturn scalar sigma2_se = r(se)
			
	   _diparm __bot__	
	}
	
	if "`classes'"=="2" {
	   if "`probability'"=="" {	
	      ml display, pl neq(1) level(`level')
			
	      _diparm imlogitp1, label(/imlogitp1)
			_diparm __sep__
		
  	      _diparm imlogitp1, invlogit label(p1)
	      ereturn scalar p1_est = r(est)
	      ereturn scalar p1_se = r(se)
		
	      _diparm imlogitp1, func(1-exp(@)/(1+exp(@))) ///
			   		der(-exp(@)/((1+exp(@))^2)) label(p0)
	      ereturn scalar p0_est = r(est)
	      ereturn scalar p0_se = r(se)
      }	
		else {
			ml display, pl level(`level')
			
		}
	   _diparm lnsigma1, exp label(sigma1)
	   ereturn scalar sigma1_est = r(est)
	   ereturn scalar sigma1_se = r(se)		
		
		_diparm __bot__
	}
end
