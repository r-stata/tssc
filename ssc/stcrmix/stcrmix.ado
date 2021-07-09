********************************************************************************
*! stcrmix: Estimation of Mixtures of Generalized Gamma Models for Competing Risks
* Perry Kuo, Usama Bilal, Alvaro Munoz
*! version 1.5 Oct 14 2018
********************************************************************************

program define stcrmix, eclass
	local vv : di "version " string(_caller()) ", missing:"
	version 13, missing
	syntax [varlist(default=none)] [if] [in], cr1(numlist) cr2(numlist) cru(numlist) ///
		failure(varname) enter(varname) time(varname) uppertime(varname) ///   
		distribution(string) ///
		[cr1loc(varlist) cr1anc1(varlist) cr1anc2(varlist) ///
		cr2loc(varlist) cr2anc1(varlist) cr2anc2(varlist) ///
		wt(varlist)]
	marksample touse

	local failurevar = "`failure'"
	local covmix =  "`varlist'"
	display as text _dup(59) "-"
	display _newline as text "Event indicator is : " as res "`failurevar'"
	display as text "Entry variable : " as res "`enter'"
	display as text "Exit variable : " as res "`time'"
	display as text "Upperexit variable : " as res "`uppertime'"
	display as text "Competing event 1 : " as res "`cr1'"
	display as text "Competing event 2 : " as res "`cr2'"
	capture drop _tempvar_event1
	capture drop _tempvar_event2
	capture drop _tempvar_event_type
	egen _tempvar_event1=anymatch(`failurevar'), values(`cr1')
	egen _tempvar_event2=anymatch(`failurevar'), values(`cr2')
	gen _tempvar_event_type=_tempvar_event1+2*_tempvar_event2
	display as text "Competing event (unknown) : " as res "`cru'"	
	display as text "Allowing different pi's by " as res "`covmix'"
	display as text "The distribution is a " as res "`distribution'" as text " distribution"
	
	
	

	if "`cr1loc'" != ""{
		display as text "Location (beta) of competing event 1 : " as res "`cr1loc'"
		}
	else {
		display as text "Location (beta) of competing event 1 : " as res "Not Specified"
		}
	if "`cr1anc1'" != ""{
		display as text "Scale (logsigma) of competing event 1 : " as res "`cr1anc1'"
		}
	else {
		display as text "Scale (logsigma) of competing event 1 : " as res "Not Specified"
		}
	if "`cr1anc2'" != ""{
		display as text "Shape (kappa) of competing event 1 : " as res "`cr1anc2'"
		}
	else {
		display as text "Shape (kappa) of competing event 1 : " as res "Not Specified"
		}
	if "`cr2loc'" != ""{
		display as text "Location (beta) of competing event 2 : " as res "`cr2loc'"
		}
	else {
		display as text "Location (beta) of competing event 2 : " as res "Not Specified"
		}
	if "`cr2anc1'" != ""{
		display as text "Scale (logsigma) of competing event 2 : " as res "`cr2anc1'"
		}
	else {
		display as text "Scale (logsigma) of competing event 2 : " as res "Not Specified"
		}
	if "`cr2anc1'" != ""{
		display as text "Shape (kappa) of competing event 2 : " as res "`cr2anc2'"	
		}
	else {
		display as text "Shape (kappa) of competing event 2 : " as res "Not Specified"	
		}
	if "`wt'" != ""{
		display as text "The analysis will be weighted by " as res "`wt'"	
		}
	else {
		display as text "Weights not assigned for this analysis" as res " "	
		}	

	display as text _dup(59) "-"
	
	
	capture drop comp1
	capture drop comp2
	capture drop compu
	capture drop entrytime
	capture drop exittime
	capture drop upperexittime
	capture drop failureglobe
	capture drop stweight
	global comp1 = 1
	global comp2 = 2
	global compu = 0
	global entrytime = "`enter'"
	global exittime = "`time'"
	global upperexittime = "`uppertime'"
	global failureglobe= "_tempvar_event_type"
	
	if "`wt'" != ""{
		global stweight = "`wt'"
		}
	else {
		global stweight = 1
		}	


	
	if "`cru'" == "" {
		global compu = "998"
		} 
	else {
		global compu = `cru'
		}
	

			


	local l = length("`distribution'")
	if substr("gamma",1,max(1,`l')) == "`distribution'" | substr("ggamma",1,max(1,`l')) == "`distribution'"  /// 
	| substr("Gamma",1,max(1,`l')) == "`distribution'" | substr("Ggamma",1,max(1,`l')) == "`distribution'"  ///
	| substr("GGamma",1,max(1,`l')) == "`distribution'" {
		
			*************  Here, I FORCE program run 1-3-3 first! *********************************
			*************  This can be technique used for passing from one dist to the other  *****
			quietly{
				
				count if _tempvar_event_type==1 & `touse'
				local n_event1 = r(N)
				count if _tempvar_event_type==2 & `touse'
				local n_event2 = r(N)
				global logitpi = log(`n_event1' / `n_event2')
	
				stset $exittime if `touse' , enter($entrytime)
				streg if _tempvar_event_type==1, d(gamma)	/*<Trick: put gamma instead of ggamma directly>*/
				global beta1_initial= _b[_cons]
				global logsigma1_initial= _b[/ln_sig]
				global kappa1_initial= _b[/kappa]
				
				stset $exittime if `touse' , enter($entrytime)
				streg if _tempvar_event_type==2, d(gamma)	/*<Trick: put gamma instead of ggamma directly>*/
				global beta2_initial= _b[_cons]
				global logsigma2_initial= _b[/ln_sig]
				global kappa2_initial= _b[/kappa]
				
				
				ml model lf GGmixtureLEandUC_loglik   (logitpi: ) ///
				(beta1: ) (logsigma1: ) (kappa1: ) (beta2: ) (logsigma2: ) (kappa2: )    if `touse' 
				ml init $logitpi $beta1_initial $logsigma1_initial $kappa1_initial $beta2_initial $logsigma2_initial $kappa2_initial, copy /*initial values*/
				set more off
				ml maximize
		
				global logitpi_m133= [logitpi]_cons
				global beta1_m133= [beta1]_cons
				global logsigma1_m133= [logsigma1]_cons
				global kappa1_m133= [kappa1]_cons
				global beta2_m133= [beta2]_cons
				global logsigma2_m133= [logsigma2]_cons
				global kappa2_m133= [kappa2]_cons
				} 
		local var1 `covmix'
		local var11 `cr1loc'
		local var12 `cr1anc1'
		local var13 `cr1anc2'
		local var21 `cr2loc'
		local var22 `cr2anc1'
		local var23 `cr2anc2'		
		
		local nvar1 : word count `var1'
		local nvar11 : word count `var11'
		local nvar12 : word count `var12'
		local nvar13 : word count `var13'
		local nvar21 : word count `var21'
		local nvar22 : word count `var22'
		local nvar23 : word count `var23'

		local ini1 = ""
		forvalues i=1(1)`nvar1'{
			local ini1 = "`ini1'" + " 0" 
		}
		local inib1 = ""
		forvalues i=1(1)`nvar11'{
			local inib1 = "`inib1'" + " 0" 
		}
		local inis1 = ""
		forvalues i=1(1)`nvar12'{
			local inis1 = "`inis1'" + " 0" 
		}
		local inik1 = ""
		forvalues i=1(1)`nvar13'{
			local inik1 = "`inik1'" + " 0" 
		}
		local inib2 = ""
		forvalues i=1(1)`nvar21'{
			local inib2 = "`inib2'" + " 0" 
		}
		local inis2 = ""
		forvalues i=1(1)`nvar22'{
			local inis2 = "`inis2'" + " 0" 
		}
		local inik2 = ""
		forvalues i=1(1)`nvar23'{
			local inik2 = "`inik2'" + " 0" 
		}
		
		
		
		ml model lf GGmixtureLEandUC_loglik   (logitpi: `var1' ) ///
		(beta1: `var11') (logsigma1: `var12' ) (kappa1: `var13') /// 
		(beta2: `var21') (logsigma2: `var22') (kappa2: `var23')   if `touse' , waldtest(7)
		ml init `ini1' $logitpi_m133 `inib1' $beta1_m133 `inis1' $logsigma1_m133 /// 
		`inik1' $kappa1_m133 `inib2' $beta2_m133 `inis2' $logsigma2_m133 ///
		`inik2' $kappa2_m133 , copy 
		set more off
		ml maximize
		quietly{
			est stat 
		}
		
***************************************************************
****************** Output ***************************
***************************************************************
		matrix b = r(S)
		local AIC = b[1,5]
		local df = b[1,4]
		local loglikelihood = b[1,3]
		local Obs = b[1,1]		
		local click = "Mixture of GG"
			
	}
	
	
	
	/*** Exponential: sigma = 1, kappa = 1 ***/
	else if substr("Exponential",1,max(1,`l')) == "`distribution'" | substr("exponential",1,max(1,`l')) == "`distribution'" /// 
	| substr("EXPONENTIAL",1,max(1,`l')) == "`distribution'" {
	
			*************  Here, I FORCE program run 1-1-1 first! *********************************
			quietly{
			
				count if _tempvar_event_type==1 & `touse'
				local n_event1 = r(N)
				count if _tempvar_event_type==2 & `touse'
				local n_event2 = r(N)
				global logitpi = log(`n_event1' / `n_event2')
	
				stset $exittime if `touse' , enter($entrytime)
				streg if _tempvar_event_type==1, d(exponential)	
				global beta1_initial= _b[_cons]
				
				stset $exittime if `touse' , enter($entrytime)
				streg if _tempvar_event_type==2, d(exponential)	
				global beta2_initial= _b[_cons]
				
				ml model lf EXPmixtureLEandUC_loglik (logitpi: ) (beta1: ) (beta2: )    if `touse' 
				ml init $logitpi $beta1_initial $beta2_initial, copy /*initial values*/				
				set more off
				ml maximize
	
				global logitpi_m111= [logitpi]_cons
				global beta1_m111= [beta1]_cons
				global beta2_m111= [beta2]_cons
				}
		local var1 `covmix'
		local var11 `cr1loc'
		local var12 `cr1anc1'
		local var13 `cr1anc2'
		local var21 `cr2loc'
		local var22 `cr2anc1'
		local var23 `cr2anc2'		
		
		local nvar1 : word count `var1'
		local nvar11 : word count `var11'
		local nvar12 : word count `var12'
		local nvar13 : word count `var13'
		local nvar21 : word count `var21'
		local nvar22 : word count `var22'
		local nvar23 : word count `var23'


	
		
		local ini1 = ""
		forvalues i=1(1)`nvar1'{
			local ini1 = "`ini1'" + " 0" 
		}
		
		local inib1 = ""
		forvalues i=1(1)`nvar11'{
			local inib1 = "`inib1'" + " 0" 
		}
		
		if "`var12'" != ""{
			display as error "Error: under an exponential distribution, sigma and kappa are fixed to be 1."  
			display as res "Please reduce parameters or change distribution."
			exit
			}
		else {
			local inis1 ""
			}
		if "`var13'" != ""{
			display as error "Error: under an exponential distribution, sigma and kappa are fixed to be 1."  
			display as res "Please reduce parameters or change distribution."
			exit
			}
		else {
			local inik1 ""
			}
		
		local inib2 = ""
		forvalues i=1(1)`nvar21'{
			local inib2 = "`inib2'" + " 0" 
		}
		
		if "`var22'" != ""{
			display as error "Error: under an exponential distribution, sigma and kappa are fixed to be 1." 
			display as res "Please reduce parameters or change distribution."
			exit
			}
		else {
			local inis2 ""
			}
		if "`var23'" != ""{
			display as error "Error: under an exponential distribution, sigma and kappa are fixed to be 1." 
			display as res "Please reduce parameters or change distribution."
			exit
			}
		else {
			local inik2 ""
			}
		
		
		ml model lf EXPmixtureLEandUC_loglik (logitpi: `var1' ) ///
		(beta1: `var11') (beta2: `var21')     if `touse' , waldtest(3)
		ml init `ini1' $logitpi_m111 `inib1' $beta1_m111 /// 
		`inib2' $beta2_m111 , copy 
		set more off
		ml maximize
		
***************************************************************
****************** Build our output. ***************************
***************************************************************
		quietly{
			est stat 
		}
		matrix b = r(S)
		local AIC = b[1,5]
		local df = b[1,4]
		local loglikelihood = b[1,3]
		local Obs = b[1,1]		
		local click = "Mixture of Exponential"

	}
	
	/*** Weibull: kappa = 1 ***/
	else if substr("Weibull",1,max(1,`l')) == "`distribution'" | substr("weibull",1,max(1,`l')) == "`distribution'"  /// 
	| substr("WEIBULL",1,max(1,`l')) == "`distribution'" {
			
			*************  Here, I FORCE program run 1-2-2 first! *********************************
			quietly{
				
				display "event indicator is " = "`eventindicator'"
				display "entry indicator is " = "`entrylocal'"
				display "competing event 1 " = "`event1'"
				display "competing event 2 " = "`event2'"
		
				count if _tempvar_event_type==1 & `touse'
				local n_event1 = r(N)
				count if _tempvar_event_type==2 & `touse'
				local n_event2 = r(N)
				global logitpi = log(`n_event1' / `n_event2')
	
				stset $exittime if `touse' , enter($entrytime)
				streg if _tempvar_event_type==1, d(weibull)	
				global beta1_initial= _b[_cons]
				global logsigma1_initial= -(_b[/ln_p])         /*<check: 1/p? which is better? Or else?>*/
				
				
				stset $exittime if `touse' , enter($entrytime)
				streg if _tempvar_event_type==2, d(weibull)	
				global beta2_initial= _b[_cons]
				global logsigma2_initial= -(_b[/ln_p])  /*<check: 1/p? which is better? Or else?>*/
				
						
				ml model lf WEmixtureLEandUC_loglik   (logitpi: ) ///
				(beta1: ) (logsigma1: ) (beta2: ) (logsigma2: )    if `touse' , waldtest(5)
				*ml init 0 2.4 0 1 2.4 0 1, copy 
				ml init $logitpi $beta1_initial $logsigma1_initial $beta2_initial $logsigma2_initial, copy /*initial values*/
				set more off
				ml maximize
		
				global logitpi_m122= [logitpi]_cons
				global beta1_m122= [beta1]_cons
				global logsigma1_m122= [logsigma1]_cons
				global beta2_m122= [beta2]_cons
				global logsigma2_m122= [logsigma2]_cons
				}


		local var1 `covmix'
		local var11 `cr1loc'
		local var12 `cr1anc1'
		local var13 `cr1anc2'
		local var21 `cr2loc'
		local var22 `cr2anc1'
		local var23 `cr2anc2'	
		
		local nvar1 : word count `var1'
		local nvar11 : word count `var11'
		local nvar12 : word count `var12'
		local nvar13 : word count `var13'
		local nvar21 : word count `var21'
		local nvar22 : word count `var22'
		local nvar23 : word count `var23'
		
		local ini1 = ""
		forvalues i=1(1)`nvar1'{
			local ini1 = "`ini1'" + " 0" 
		}
		
		local inib1 = ""
		forvalues i=1(1)`nvar11'{
			local inib1 = "`inib1'" + " 0" 
		}
		
		local inis1 = ""
		forvalues i=1(1)`nvar12'{
			local inis1 = "`inis1'" + " 0" 
		}
		
		if "`var13'" != ""{
			display as error "Error: under an Weibull distribution, kappa is fixed to be 1."  
			display as res "Please reduce parameters or change distribution."
			exit
			}
		else {
			local inik1 ""
			}
			
		local inib2 = ""
		forvalues i=1(1)`nvar21'{
			local inib2 = "`inib2'" + " 0" 
		}
		local inis2 = ""
		forvalues i=1(1)`nvar22'{
			local inis2 = "`inis2'" + " 0" 
		}
		if "`var23'" != ""{
			display as error "Error: under an Weibull distribution, kappa is fixed to be 1."  
			display as res "Please reduce parameters or change distribution."
			exit
			}
		else {
			local inik2 ""
			}
		
		
		ml model lf WEmixtureLEandUC_loglik  (logitpi: `var1' ) ///
		(beta1: `var11') (logsigma1: `var12' )  /// 
		(beta2: `var21') (logsigma2: `var22')    if `touse' , waldtest(5) 
		ml init `ini1' $logitpi_m122 `inib1' $beta1_m122 `inis1' $logsigma1_m122 /// 
		`inib2' $beta2_m122 `inis2' $logsigma2_m122 , copy 
		set more off
		ml maximize
		
***************************************************************
****************** Build our output. ***************************
***************************************************************
		quietly{
			est stat 
		}
		matrix b = r(S)
		local AIC = b[1,5]
		local df = b[1,4]
		local loglikelihood = b[1,3]
		local Obs = b[1,1]		
		local click = "Mixture of Weibull" 
			
	}
	
	/*** Lognormal: kappa = 0 ***/
	else if substr("Lognormal",1,max(1,`l')) == "`distribution'" | substr("lognormal",1,max(1,`l')) == "`distribution'"  /// 
	| substr("LOGNORMAL",1,max(1,`l')) == "`distribution'" {
			
			*************  Here, I FORCE program run 1-2-2 first! *********************************
			quietly{
				
				display "event indicator is " = "`eventindicator'"
				display "entry indicator is " = "`entrylocal'"
				display "competing event 1 " = "`event1'"
				display "competing event 2 " = "`event2'"

				count if _tempvar_event_type==1 & `touse'
				local n_event1 = r(N)
				count if _tempvar_event_type==2 & `touse'
				local n_event2 = r(N)
				global logitpi = log(`n_event1' / `n_event2')
	
				stset $exittime if `touse' , enter($entrytime)
				streg if _tempvar_event_type==1, d(lognormal)	
				global beta1_initial= _b[_cons]
				global logsigma1_initial= _b[/ln_sig]         /*<check: /ln_sig?  sigma? which is better? Or else?>*/
						
				stset $exittime if `touse' , enter($entrytime)
				streg if _tempvar_event_type==2, d(lognormal)	
				global beta2_initial= _b[_cons]
				global logsigma2_initial= _b[/ln_sig]   /*<check: /ln_sig?  sigma? which is better? Or else?>*/
				
				ml model lf LNmixtureLEandUC_loglik   (logitpi: ) ///
				(beta1: ) (logsigma1: ) (beta2: ) (logsigma2: )    if `touse', waldtest(5) 
				ml init $logitpi $beta1_initial $logsigma1_initial $beta2_initial $logsigma2_initial, copy /*initial values*/
				set more off
				ml maximize
		
				global logitpi_m122= [logitpi]_cons
				global beta1_m122= [beta1]_cons
				global logsigma1_m122= [logsigma1]_cons
				global beta2_m122= [beta2]_cons
				global logsigma2_m122= [logsigma2]_cons

				}
				
		local var1 `covmix'
		local var11 `cr1loc'
		local var12 `cr1anc1'
		local var13 `cr1anc2'
		local var21 `cr2loc'
		local var22 `cr2anc1'
		local var23 `cr2anc2'		
		
				
		local nvar1 : word count `var1'
		local nvar11 : word count `var11'
		local nvar12 : word count `var12'
		local nvar13 : word count `var13'
		local nvar21 : word count `var21'
		local nvar22 : word count `var22'
		local nvar23 : word count `var23'
		
		local ini1 = ""
		forvalues i=1(1)`nvar1'{
			local ini1 = "`ini1'" + " 0" 
		}
		local inib1 = ""
		forvalues i=1(1)`nvar11'{
			local inib1 = "`inib1'" + " 0" 
		}
		local inis1 = ""
		forvalues i=1(1)`nvar12'{
			local inis1 = "`inis1'" + " 0" 
		}
		if "`var13'" != ""{
			display as error "Error: under an log-normal distribution, kappa is fixed to be 0."  
			display as res "Please reduce parameters or change distribution."
			exit
			}
		else {
			local inik1 ""
			}
		local inib2 = ""
		forvalues i=1(1)`nvar21'{
			local inib2 = "`inib2'" + " 0" 
		}
		local inis2 = ""
		forvalues i=1(1)`nvar22'{
			local inis2 = "`inis2'" + " 0" 
		}
		if "`var23'" != ""{
			display as error "Error: under an log-normal distribution, kappa is fixed to be 0."  
			display as res "Please reduce parameters or change distribution."
			exit 
			}
		else {
			local inik2 ""
			}
		
		
		ml model lf LNmixtureLEandUC_loglik  (logitpi: `var1' ) ///
		(beta1: `var11') (logsigma1: `var12' )  /// 
		(beta2: `var21') (logsigma2: `var22')    if `touse' , waldtest(5)
		ml init `ini1' $logitpi_m122 `inib1' $beta1_m122 `inis1' $logsigma1_m122 /// 
		`inib2' $beta2_m122 `inis2' $logsigma2_m122 , copy 
		set more off
		ml maximize
		
***************************************************************
****************** Build our output. ***************************
***************************************************************
		quietly{
			est stat 
		}
		matrix b = r(S)
		local AIC = b[1,5]
		local df = b[1,4]
		local loglikelihood = b[1,3]
		local Obs = b[1,1]		
		local click = "Mixture of Lognormal"
	}
		
***************************************************************
****************** Print our output. **************************
***************************************************************
		di _n ///
		"Loglikelihood (ll) and Akaike's information criterion (AIC) "
		display _n as txt "{hline 25}{c +}{hline 63}"
		display as txt "            Model        {c |}       Obs    df         ll           AIC "
		display as txt "{hline 25}{c +}{hline 63}"

		display as txt "{ralign 25:`click'}"         ///
		          _col(26) "{c |}"              ///
		   as res _col(26) %10.0fc `Obs'             ///
		          _col(37)  %6.0f  `df'  			 ///
		          _col(48)  %9.0g  `loglikelihood'   ///
		          _col(60)  %9.0g  `AIC'	
	
		capture drop _tempvar_event1
		capture drop _tempvar_event2
		capture drop _tempvar_event_type
		
	else {
		display as error "Please change distribution"
		exit
	}
end
