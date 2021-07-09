*! N.Orsini v.1.0.0 16June2005

capture program drop eclpci  
program eclpci, rclass
version 8

syntax  anything  [ ,  Level(int $S_level)  Format(string) Normal NCCorr rb chi2 chi2c]
 
// count and get arguments

local wc : word count `anything'

local step 0

if  `wc' == 1 {
		local step = 1
		tokenize "`*'", parse(" ,")
		confirm integer number `1'
		tempname obs 
		scalar `obs' = `1'

		if `obs' < 0 {
			di in r "Number of observed events #obs must be >= 0"
			exit 198
		}

		} 

if `wc' == 2  {
		local step = 2
		tokenize "`*'", parse(" ,")

		confirm integer number `1'
		confirm  number `2'

		tempname obs exp
		scalar `obs' = `1'
		scalar `exp' = `2'

	if `obs'<0 | `exp'<0 { 
		di in red "negative numbers invalid"
		exit 198
	}

/*
	if `obs' > `exp' {
			di in r "Number of observed events must be less than or equal to the expected"
			exit 198
	}

*/

}

if `wc' > 2  {
			di in r "specify maximum 2 numbers"
			exit 198
		}

* to calculate the exact confidence limits for a Poisson count
* http://www.doh.wa.gov/Data/Guidelines/ConfIntguide.htm#tth_sEc4.3

// check level

if `level' <10 | `level'>99 { 
di in red "level() invalid"
exit 198
}   

// get format

if "`format'" == "" {
local format = "%4.3f"
}   
else {
local format = "`format'"
}


// check options

if "`normal'" != "" & "`nccorr'" != ""  & "`rb'" != ""  {
	di in r "choose one method"
	exit 198
}

if "`normal'" != "" & "`nccorr'" == ""  & "`rb'" != ""  {
	di in r "choose one method"
	exit 198
}

if "`normal'" == "" & "`nccorr'" != ""  & "`rb'" != ""  {
	di in r "choose one method"
	exit 198
}

if "`normal'" '!= "" & "`nccorr'" != ""  & "`rb'" == ""  {
	di in r "choose one method"
	exit 198
}

if "`normal'" '!= "" & "`nccorr'" == ""  & "`rb'" != ""  {
	di in r "choose one method"
	exit 198
}

if "`normal'" '!= "" & "`nccorr'" != ""  & "`rb'" == ""  {
	di in r "choose one method"
	exit 198
}

if  "`chi2'" != "" & "`chi2c'" != "" {
	di in r "choose one method"
	exit 198
}



// get the confidence level 

tempname levelci mlevelci levelp

scalar `levelp'  = `level'/100
scalar `levelci' = `level' * 0.005 + 0.50
scalar `mlevelci' = 1- `levelci'

// calculate confidence limits for #obs with different methods

* exact poisson

if "`normal'" == "" & "`nccorr'" == ""  & "`rb'" == ""  {

	tempname lb ub

	if `obs' > 0 { 
		scalar `lb' = invgammap( `obs' , (1-`levelp')/2 )
		scalar `ub' = invgammap((`obs'+ 1) , (1+`levelp')/2 )
	}

	if `obs' == 0 {
		scalar `lb' = 0
		scalar `ub' = -log(1-`levelp')
	}

}

* normal approximation (Daly, 1992)

if "`normal'" != "" {

tempname lb ub

scalar `lb' =  `obs'-invnorm(`levelci')*sqrt(`obs')
scalar `ub' = `obs'+invnorm(`levelci')*sqrt(`obs')

}

* normal approximation with a continuity correction  (Daly, 1992)  

if "`nccorr'" != ""   {

tempname lb ub
scalar `lb' = ( sqrt(`obs')-.5*invnorm(`levelci') )^2
scalar `ub' = ( sqrt(`obs')+.5*invnorm(`levelci') )^2
}


* Approximate limits (Rothman and Boice, 1979, Breslow and Day, 1987 pag.69 ), recommended if #obs >= 100

if "`rb'" != ""   {

tempname lb ub

scalar `lb' = (1- (1/(9*`obs')) - (invnorm(`levelci')/(3*sqrt(`obs'))) )^3*(`obs') 
scalar `ub' = (1- (1/(9*(`obs'+1))) + (invnorm(`levelci')/(3*sqrt(`obs'+1))) )^3*(`obs'+1)  

}

* chi-square with a continuity correction  (Breslow and Day, 1987, p.69 eq 2.12)  

tempname chi2v pvalc

/*  standard chi-square (not implemented)
if "`chi2'" != ""   {
scalar `chi2v' = (`obs'-`exp')^2/`exp'
scalar `pvalc' = chiprob(1, `chi2v')
}
*/

* chi-square with simple continuity correction (eq. 2.10 pag. 68 of Breslow and Day 1987)

if "`chi2'" != ""   {
scalar `chi2v' = (abs(`obs'-`exp')-.5)^2/`exp'
scalar `pvalc' = chiprob(1, `chi2v')
}

* chi-square with a better approximation to the exact Poisson test (eq. 2.12 pag. 69 of Breslow and Day 1987)

if "`chi2c'" != ""   {
scalar `chi2v' = (2*(sqrt(`obs')-sqrt(`exp')))^2
*scalar `pvalc' = (1- norm(abs(`chi2v')))* 2 
scalar `pvalc' = chiprob(1, `chi2v')
}
 
* display results

if `step' == 1 {
di in g _n   "Observed counts: " in y `obs'  in g  "  `level'% CI[" in y `format' `lb' in g ", " in y `format' `ub' in g "]"
}

if `step' == 2  {
di _n in g "SMR: " in y `format' `obs'/`exp' in g  "  `level'% CI[" in y `format' `lb'/`exp' in g ", " in y  `format' `ub'/`exp' in g "]"
}

if "`chi2'" != ""   {
di in g  "Chi-square: " in y `format' `chi2v' in g "  p-value (1 d.f.): " in y `format' `pvalc'
}

if "`chi2c'" != ""   {
di in g  "Chi-square: " in y `format' `chi2v' in g "  p-value (1 d.f.): " in y `format' `pvalc'
}

* save results

return local cmd = "eclpci"
return scalar obs = `obs'

if `step' == 1   {
	return scalar lb = `lb'
	return scalar ub = `ub'
}

if  `step' == 2   {
	return scalar lb = `lb'/`exp'
	return scalar ub = `ub'/`exp'

}

if "`chi2'" != "" | "`chi2c'" != "" {
	return scalar chi2 = `chi2v'
	return scalar pval = `pvalc'
	}

end

