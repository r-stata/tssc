* LogitToRisk version 1.0 - 01 December 2020
* Authors: Luis Furuya-Kanamori (luis.furuya-kanamori@anu.edu.au) & Suhail AR Doi

program define logittorisk, rclass
version 14

syntax [, r0(numlist max=1) cat(numlist max=1)] 

preserve

quietly{

*Check required packages
	foreach package in indeplist {
	capture which `package'
	if _rc==111 ssc install `package'
	}

	
*Capture output from logistic regression
	mat __output=r(table)
		matrix list __output
	
	indeplist
	gen __var_list = r(X)
	split __var_list, parse("") gen(__var_exp)
	split __var_list, parse(".") limit(1) gen(__var_cat) destring
		cap confirm numeric variable __var_cat
		gen __var_type = _rc
	local variable = __var_exp1[1]

	
*Error/warning messages
	*Model selection
	if "`e(cmd)'" !="logit" & "`e(cmd)'" !="logistic"{
	di as error "logittorisk can only be used after logit or logistic"
	error 198
	}
	
	*Eform selection
	if "`e(cmd)'" =="logit" & (__output[9,1]) == 0{
	di as error "specify the option 'or' in the logit regression"
	error 198
	}
	
	if "`e(cmd)'" =="logistic" & (__output[9,1]) == 0{
	di as error "dont specify the option 'coef' in the logistic regression"
	error 198
	}
		
	*Baseline 
	if "`r0'"!="" {
	local r0_check `r0'
		cap assert `r0_check'>=0 & `r0_check'<=1
		if _rc {
		di as error "r0 outside the range (0 to 1)"
		exit 198
		}
	}
		
	
*Odds to risks
	if "`r0'"=="" {
		gen __odds0 = exp(_b[_cons])
		gen __r0 = __odds0/(1+__odds0)
	}
	
	if "`r0'"!="" {
		local r0 `r0'
		gen __r0 = `r0'
		gen __odds0 = __r0/(1-__r0)
	}
		
	*Exp var no i.
	if __var_type!=0{
	gen __odds1_coeff = _b[`variable']
		gen __odds1 = (exp(__odds1_coeff)) * __odds0
	gen __odds1_se = _se[`variable']
	gen __odds1_lci_coeff = __odds1_coeff - 1.96*__odds1_se
		gen __odds1_lci = (exp(__odds1_lci_coeff)) * __odds0
	gen __odds1_uci_coeff = __odds1_coeff + 1.96*__odds1_se
		gen __odds1_uci = (exp(__odds1_uci_coeff)) * __odds0
	}
		
	*Exp var ib#. or i. 
	if __var_type==0 {
		*cat not specified
			if "`cat'"==""{
				gen __odds1_coeff = _b[`variable']
					gen __odds1 = (exp(__odds1_coeff)) * __odds0
				gen __odds1_se = _se[`variable']
				gen __odds1_lci_coeff = __odds1_coeff - 1.96*__odds1_se
					gen __odds1_lci = (exp(__odds1_lci_coeff)) * __odds0
				gen __odds1_uci_coeff = __odds1_coeff + 1.96*__odds1_se
					gen __odds1_uci = (exp(__odds1_uci_coeff)) * __odds0
			}
		*cat specified
			if "`cat'"!=""{
				gen __location = `cat'
				tostring __location, replace
					
				gen __dot = "."
					
				split __var_exp1, p(.)
				egen __var_exposure = concat(__location __dot __var_exp12)
					replace __var_exp1 = __var_exposure
					
				local variable2 = __var_exp1[1]
				gen __odds1_coeff = _b[`variable2']
					gen __odds1 = (exp(__odds1_coeff)) * __odds0
				gen __odds1_se = _se[`variable2']
				gen __odds1_lci_coeff = __odds1_coeff - 1.96*__odds1_se
					gen __odds1_lci = (exp(__odds1_lci_coeff)) * __odds0
				gen __odds1_uci_coeff = __odds1_coeff + 1.96*__odds1_se
					gen __odds1_uci = (exp(__odds1_uci_coeff)) * __odds0
			}
	}
	
	gen __r1 = __odds1/(1+__odds1)
	gen __r1_lci = __odds1_lci/(1+__odds1_lci)
	gen __r1_uci = __odds1_uci/(1+__odds1_uci)
	
	gen __rr = __r1/__r0
	gen __rr_lci = __r1_lci/__r0
	gen __rr_uci = __r1_uci/__r0
	
	gen __rd = __r1-__r0
	gen __rd_lci = __r1_lci-__r0
	gen __rd_uci = __r1_uci-__r0
	
	gen __nnt = 1/__rd
	gen __nnt_lci = 1/__rd_uci
	gen __nnt_uci = 1/__rd_lci
		cap quietly gen __nnt_di=.	
			cap quietly replace __nnt_di = ceil(__nnt) if __nnt>=0
			cap quietly replace __nnt_di = floor(__nnt) if __nnt<0
		cap quietly gen __nnt_lci_di=.
			cap quietly replace __nnt_lci_di = ceil(__nnt_lci) if __nnt_lci>=0
			cap quietly replace __nnt_lci_di = floor(__nnt_lci) if __nnt_lci<0
		cap quietly gen __nnt_uci_di=.
			cap quietly replace __nnt_uci_di = ceil(__nnt_uci) if __nnt_uci>=0
			cap quietly replace __nnt_uci_di = floor(__nnt_uci) if __nnt_uci<0
}


*Re-run the model
	if __odds1==.{
	di as error "re-run logit or logistic before logittorisk"
	error 198
	}


*Display results
di ""
if __var_type!=0{
	di as text "Ratios and differences of risk for variable " __var_exp1[1]
}
if __var_type==0{
	di as text "Ratios and differences of risk for variable-category " __var_exp1[1]
}

di in smcl as txt "{hline 9}{c TT}{hline 40}"
di in smcl as txt "{col 10}{c |}      Estimate      95% Conf. Interval"
di in smcl as txt "{hline 9}{c +}{hline 40}"
di as text "r1" as txt "{col 10}{c |}" ///
	"{col 20}" round(__r1[1],0.001)
di as text "r0" as txt "{col 10}{c |}" ///
	"{col 20}" round(__r0[1],0.001)
di in smcl as txt "{hline 9}{c +}{hline 40}"
di as text "RR" as txt "{col 10}{c |}" ///
	"{col 20}" round(__rr[1],0.001) ///
	"{col 32}" round(__rr_lci[1],0.001) ///
	"{col 42}" round(__rr_uci[1],0.001) 
di as text "RD" as txt "{col 10}{c |}" ///
	"{col 20}" round(__rd[1],0.001) ///
	"{col 32}" round(__rd_lci[1],0.001) ///
	"{col 42}" round(__rd_uci[1],0.001) 
di as text "NNT" as txt "{col 10}{c |}" ///
	"{col 20}" (__nnt_di[1]) ///
	"{col 32}" (__nnt_lci_di[1]) ///
	"{col 42}" (__nnt_uci_di[1]) 
di in smcl as txt "{hline 9}{c BT}{hline 40}"
	
	
*Scalars
	return scalar nnt_uci = __nnt_uci[1]
	return scalar nnt_lci = __nnt_lci[1]
	return scalar nnt = __nnt[1]
	return scalar rd_uci = __rd_uci[1]
	return scalar rd_lci = __rd_lci[1]
	return scalar rd = __rd[1]
	return scalar rr_uci = __rr_uci[1]
	return scalar rr_lci = __rr_lci[1]
	return scalar rr = __rr[1]
	return scalar r0 = __r0[1]
	return scalar r1 = __r1[1]
	

*Restore data and exit
restore 
end
exit

