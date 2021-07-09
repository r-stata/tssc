program pddami, rclass sortpreserve 
version 9
syntax anything, [SUM1(numlist min=3 max=3) SUM2(numlist min=3 max=3) pred(numlist min=2 max=2) LEVEL(integer 95)*]
	tempname contpr contprse contprlo contprhi 
	tempname contnr contnrse contnrlo contnrhi  
	tempname sigma1 uppv uppvlo uppvhi 
	tempname sigma2 unpv unpvlo unpvhi

	qui{
	tokenize "`anything'"
	scalar `contpr' = `1'
	scalar `contprse' = `2'
	scalar `contnr' = `3'
	scalar `contnrse' = `4'
	
	tokenize `sum1'
          local convar1 `1' 
          local convar1lo `2'
          local convar1hi `3'
          tokenize `sum2'
          local convar2 `1' 
          local convar2lo `2'
          local convar2hi `3'
	tokenize `pred'
	local c1 `1'
	local c2 `2'

       	if `level' < 10 | `level' > 99 {
	di as error "level() must be between 10 and 99"
	exit 198
		}
          
          if `c1' < 0 | `c2' > 1.0 {
	di as error "c1-c2 must be between 0 and 1"
	exit 198
		}
		
          if `c1' > `c2' {
	di as error "c1 must always be less than c2 must be between 0 and 1"
	exit 198
		}
          
          local alph = (100-`level')/200
          tempvar PPP1 PPN1 x1 x2
          twoway__function_gen y= `convar1' * x/(1- x * (1 - `convar1')), r(0 1) x(x) gen(`PPP1' `x1', replace) n(1000) 
          twoway__function_gen y= `convar2' * x /(1 - x * (1 - `convar2')), r(0 1) x(x) gen(`PPN1' `x2', replace) n(`c(N)') 
          local note1a: di "LR+ =" %4.2f `convar1' " [" %4.2f `convar1lo' " - " %4.2f `convar1hi' "]"               
          local note2a: di "LR- =" %4.2f `convar2' " [" %4.2f `convar2lo' " - " %4.2f `convar2hi' "]"
 

          
          *estimate unconditional positive or negative predictive values and the 95% confidence intervals 
          *assuming Uniform distribution for prior from zero to one. 
          *It can be easily adjusted for other uniform priors (by modifying the values of `c1' and `c2')

	scalar `contprlo' = `contpr'-invnorm(1-`alph')*`contprse'
	scalar `contprhi' = `contpr'+invnorm(1-`alph')*`contprse'
	scalar `contnrlo' = `contnr'-invnorm(1-`alph')*`contnrse'
	scalar `contnrhi' = `contnr'+invnorm(1-`alph')*`contnrse'

   	scalar `uppv' = `contpr'/(`contpr'+`contnr'-1)-`contpr'*(1-`contnr')*log((`c2'*`contpr'+(1-`c2')*(1-`contnr'))/(`c1'*`contpr'+(1-`c1')*(1-`contnr')))/((`c2'-`c1')*(`contpr'+`contnr'-1)^2)
   	scalar `sigma1' = (1/(`contpr'+`contnr'-1)^4)*((`contprse')^2*(`contnr'-1-`contpr'*(1-`contnr')^2/((`c2'*`contpr'+(1-`c2')*(1-`contnr'))*(`c1'*`contpr'+(1-`c1')*(1-`contnr')))-((1-`contnr')*(`contnr'-1-`contpr')/((`c2'-`c1')*(`contnr'-1+`contpr')))*log((`c2'*`contpr'+(1-`c2')*(1-`contnr'))/(`c1'*`contpr'+(1-`c1')*(1-`contnr'))))^2+(`contnrse')^2*(-`contpr'-(`contpr'^2)*(1-`contnr')/((`c2'*`contpr'+(1-`c2')*(1-`contnr'))*(`c1'*`contpr'+(1-`c1')*(1-`contnr')))+(`contpr'*(`contpr'-`contnr'+1)/((`c2'-`c1')*(`contpr'+`contnr'-1)))*log((`c2'*`contpr'+(1-`c2')*(1-`contnr'))/(`c1'*`contpr'+(1-`c1')*(1-`contnr'))))^2)
   	scalar `uppvlo' = `uppv'-invnorm(1-`alph')*sqrt(`sigma1')
   	scalar `uppvhi' = `uppv'+invnorm(1-`alph')*sqrt(`sigma1')
     
   	scalar `unpv' = `contnr'/(`contpr'+`contnr'-1)-`contnr'*(1-`contpr')*log(((1-`c1')*`contnr'+`c1'*(1-`contpr'))/((1-`c2')*`contnr'+`c2'*(1-`contpr')))/((`c2'-`c1')*(`contpr'+`contnr'-1)^2)
	scalar `sigma2' = (1/(`contnr'+`contnr'-1)^4)*((`contnrse')^2*(`contnr'-1-`contnr'*(1-`contnr')^2/((`c2'*`contnr'+(1-`c2')*(1-`contnr'))*(`c1'*`contnr'+(1-`c1')*(1-`contnr')))-((1-`contnr')*(`contnr'-1-`contnr')/((`c2'-`c1')*(`contnr'-1+`contnr')))*log((`c2'*`contnr'+(1-`c2')*(1-`contnr'))/(`c1'*`contnr'+(1-`c1')*(1-`contnr'))))^2+(`contnrse')^2*(-`contnr'-(`contnr'^2)*(1-`contnr')/((`c2'*`contnr'+(1-`c2')*(1-`contnr'))*(`c1'*`contnr'+(1-`c1')*(1-`contnr')))+(`contnr'*(`contnr'-`contnr'+1)/((`c2'-`c1')*(`contnr'+`contnr'-1)))*log((`c2'*`contnr'+(1-`c2')*(1-`contnr'))/(`c1'*`contnr'+(1-`c1')*(1-`contnr'))))^2) 
   	scalar `unpvlo' = `unpv'-invnorm(1-`alph')*sqrt(`sigma2')
   	scalar `unpvhi' = `unpv'+invnorm(1-`alph')*sqrt(`sigma2')
   	
   	*returned results
   	return scalar contpr = `contpr'
   	return scalar tprlo = `contprlo'
	return scalar tprhi =  `contprhi'
	return scalar contnr = `contnr'
	return scalar tnrlo = `contnrlo'
	return scalar tnrhi = `contnrhi'
   	return scalar uppv = `uppv' 
  	return scalar uppvlo = max(0,`uppvlo')
  	return scalar uppvhi = min(1,`uppvhi')
  	return scalar unpv = `unpv' 
  	return scalar unpvlo = max(0,`unpvlo')
  	return scalar unpvhi = min(1, `unpvhi')
  	return scalar c1 = `c1'
  	return scalar c2 = `c2'

local cp1=return(c1) 
local cp2=return(c2)
local ppv1=return(unpv) 
local ppv1lo=return(unpvlo) 
local ppv1hi=return(unpvhi) 
local ppv2=return(uppv)  
local ppv2lo=return(uppvlo)
local ppv2hi=return(uppvhi)   
 
local notep: di "Uniform Prior Distribution =" " [" %3.2f `cp1' " - " %3.2f `cp2' "]" 
local nnote: di "Unconditional NPV =" %4.2f `ppv1' " [" %4.2f `ppv1lo' " - " %4.2f `ppv1hi' "]"               
local pnote: di "Unconditional PPV =" %4.2f `ppv2' " [" %4.2f `ppv2lo' " - " %4.2f `ppv2hi' "]"               



     #delimit;
	nois twoway (line `PPP1' `x1', sort clpat(dash) clwidth(medium) connect(direct ) clcolor(black))
	(line `PPN1' `x2', sort clpat(shortdash_dot) clcolor(black) clwidth(medium) connect(direct ))
 	(function y=x, sort range(0 1)clcolor(black) clpat(solid) clwidth(vthin) connect(direct)), 
 	ytitle("Posterior Probability", size(*.90)) yscale(range(0 1)) plotregion(margin(zero)) 
 	ylabel( 0(.2)1,  angle(horizontal) format(%3.1f)) xtitle("Prior Probability", size(*.90)) 
 	xscale(range(0 1)) xlabel(0(.2)1, format(%3.1f)) legend(order(1 "Positive Test Result" "`note1a'" 
	2 "Negative Test Result" "`note2a'") pos(2) symxsize(6) forcesize col(1) size(*.85))aspect(1) 
	note("Prevalence Heterogeneity" "`notep'" "`nnote'" "`pnote'", justification(center) position(6)) ;
	#delimit cr

}
end


   