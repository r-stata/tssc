* This program computes welfare or WTP measures.
*! Author PWJ
*! March 2007

program wtpmeasure, rclass
	version 9.2
	syntax varlist [if] [in], bvec(name) MODel(string) [MYMean(name) EXPOnential MEANList]
	marksample touse
	tempname wtp alpha beta sigma sigmapi
	loc k = colsof(`bvec')	
	if `k'==2 {
		di in y "Warning: Model with only the bid amount as covariate"
		di		
		sca `alpha'=`bvec'[1,2]
		sca `beta'=`bvec'[1,1]
		sca `wtp'=-`alpha'/`beta'	
		if `"`exponential'"' == "" ret sca meanwtp=`wtp'
		else {
			ret sca medianwtp=exp(`wtp')
			sca `sigma'=-1/`beta' // Assuming that the model is WTP=alpla+ beta*bid_amount where beta is negative when estimated
			if `"`model'"'=="logit" {
			 	if `sigma'>1 {					
					di in y "Warning: Sigma =", `sigma',">1, Mean WTP is undefined for exponential logit" 
					ret sca meanwtp=.
				}
				else { 
					sca `sigmapi'=`sigma'*_pi 
					ret sca meanwtp=exp(`wtp')*(`sigmapi'/sin(`sigmapi'))
				}
			}
			else ret sca meanwtp=exp(`wtp' + .5*`sigma'^2)
		}	
	}	
	else {  		

		tempname b1 bx bprice mx1 mx2 mat const mx meanv stdbeta
		matrix `b1'=`bvec'
		scalar `bprice'=`b1'[1,1]  // get the bid coefficient assuming this is the first variable the user specifies in varlist
		matrix `bx'=`b1'[1,2..`k'] // get the covariate estimated coefficients
		local nv: word count `varlist'
		local i=1
		matrix `meanv'=J(1,`nv',0)
		matrix `mx'=J(1,`nv'-1,0)
		foreach var of varlist `varlist' {
			sum `var' if `touse', meanonly
			scalar m`var'=r(mean)
			matrix `meanv'[1,`i']=r(mean)
			local i= `i'+1
		}	      
		local t=colsof(`meanv')
		matrix `mx'=`meanv'[1, 2..`t']
		matrix `const'=(1)
		matrix `stdbeta' = -`bx' / `bprice'		
		if `"`mymean'"' != "" {  // if one wants to use Census data, for example, instead of a sample mean vector
			mat `mat'=`mymean'
			mat `mx2'=`mat',`const'
			mat `wtp'= `mx2'*`stdbeta''
		}
		else {
			mat `mx1'=`mx',`const'
			mat `wtp'= `mx1'*`stdbeta''
		}
		loc gamaZ = `wtp'[1,1]
		if `"`exponential'"'=="" return scalar meanwtp=`gamaZ' 		
		else {
			ret sca medianwtp=exp(`gamaZ')
			sca `sigma'=-1/`bprice'			
			if `"`model'"'=="logit" {
				if `sigma'>1 {	
					di
					di in y "Warning: Sigma = " `sigma' ">1, Mean WTP is undefined for exponential logit"
					ret sca meanwtp=.
				}
 				else {
					sca `sigmapi'=`sigma'*_pi 
					ret sca meanwtp=exp(`gamaZ')*(`sigmapi'/sin(`sigmapi'))
				}
			}	
			else ret sca meanwtp=exp(`gamaZ'+.5*`sigma'^2)			
		}
		if `"`meanlist'"'!="" ret mat meanvar = `mx' // return the mean vector of the variables used in calculation

	 }
end




