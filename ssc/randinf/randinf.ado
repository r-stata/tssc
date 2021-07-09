***Randinf********************************************
***by John Ternovski, S3 R&D Lab, Harvard University**
***Version 1.7****************************************
********version history
******1.7 minor fixes based on CK's comments
******1.6 added onesided p-value option
******1.5 fixed bug excluding strata when covars are specified and normalizing rank
******1.4 added ability to specify custom residuals 
******1.3 using tempnames for all locals
******1.2 added ability to specify custom covars 
program define randinf, eclass

version 12
syntax [if] [in], TReat(varname) STRata(varname) [iter(real 1000)] OUTcome(varname) [GRANularity(real .05)] [MIss] [COVars(string)] [DIsplayprogress] [resid(string)] [ONEsided] [NOFigure]

***************check if required packages exist******
cap which shufflevar 
if _rc {
	ssc install shufflevar 
}

*****************error checking******
qui tab `treat'
if `r(r)'!=2 {
	disp as error "ERROR: Treatment variable must be binary."
	exit
}

******************keep just the specified data
preserve
if "`in'"!="" {
	qui keep `in'
}
if "`if'"!="" { 
	qui keep `if'
}


****************setting up variables*****
//generating variables that will be used in the "p-value"" vs. "treatment effects" output graph 
tempvar treatgroup pvalueforgraph tauforgraph counterforgraph
qui egen `treatgroup'=group(`treat')
qui replace `treatgroup'=`treatgroup'-1
qui gen `pvalueforgraph'=.
qui gen `tauforgraph'=.
qui gen `counterforgraph'=.


//setting up strata you can use both string and numeric strata 
tempvar stratanum
qui egen `stratanum'=group(`strata') 

//drop strata with missing values unless miss is specified 
if "`miss'"=="" {
	cap drop if `stratanum'==.
}

//makes sure youre limiting just to those assigned treatment conditions 
qui drop if `treatgroup'==.


//setting up data to accommodate distribution of test statistics in null distribution
cap set obs `iter' //need a variable to be as long as the number of iterations 


//setting up locals
tempname innull donegativenow counter tau
local `innull'=1 //while-loop breaker
local `donegativenow'=0 //look at negative treatment effects
local `counter'=1 //counter 
local `tau'=0 //tau = treatment effect, start with 0 then add iteratively
******************************************
 
*********generating residuals*************
if "`resid'"=="" {
	//if using custom covars...
	if "`covars'"!="" {
		if "`displayprogress'"!="" {
			xi: areg `outcome' `covars', absorb(`stratanum')
		}
		else {
			qui xi: areg `outcome' `covars', absorb(`stratanum') 
		}
	}
	else {
		if "`displayprogress'"!="" {
			xi: reg `outcome' i.`stratanum' 
		}
		else {
			qui xi: reg `outcome' i.`stratanum' 
		}
	}
	tempvar resid
	qui predict `resid', residuals
}	
******************************************

tempname finalpvalue
********running randomizaiton inference***
while "``innull''"=="1" {
	//setting up locals now for each randomization loop 
	tempvar y0 rank synthstat
	tempname controlrankmean treatrankmean actualstat fakestatindiv meansynthstat pvalue 

	//generating y0 (null distribution) from residuals 
	qui gen `y0'=`resid' if `treatgroup'==0
	qui replace `y0'=(`resid'-``tau'') if `treatgroup'==1 
	//generating rank 
	qui egen `rank'=rank(`y0') 
	qui count if `rank'!=.
	qui replace `rank'=`rank'-((`r(N)'+1)/2) //normalize ranks
	qui sum `rank' if `treatgroup'==0
	local `controlrankmean'=`r(mean)'
	qui sum `rank' if `treatgroup'==1
	local `treatrankmean'=`r(mean)'

	//using absolute difference in ranks as test statistic
	local `actualstat'=``treatrankmean''-``controlrankmean''
	local `actualstat'=``actualstat''
	qui drop `rank'
	


	//generating null distribution by randomly permuting treatment assignment within strata
	qui gen `synthstat'=.
	forval qp=1/`iter' {
		qui shufflevar `treatgroup', cluster(`stratanum') //custom shufflevar package
		
		qui egen `rank'=rank(`y0')
		qui count if `rank'!=.
		qui replace `rank'=`rank'-((`r(N)'+1)/2) //normalize ranks
		qui sum `rank' if `treatgroup'_shuffled==0
		local `controlrankmean'=`r(mean)'
		qui sum `rank' if `treatgroup'_shuffled==1
		local `treatrankmean'=`r(mean)'
		local `fakestatindiv'=``treatrankmean''-``controlrankmean''
		local `fakestatindiv'=``fakestatindiv''
		qui replace `synthstat'=``fakestatindiv'' in `qp'
		qui drop `rank' `treatgroup'_shuffled 
	}

	qui sum `synthstat'
	local `meansynthstat'=`r(mean)' //now taking the mean of the statistic variable 
	//now see where our y0 statistic rests in comparison to the synthetic distribution
	if "`onesided'"=="onesided" {
		if ``actualstat''<0 {
			qui count if `synthstat'>``actualstat'' & `synthstat'!=. 
		}
		else {
			qui count if `synthstat'<``actualstat'' & `synthstat'!=.
		}
	}
	else {
		qui count if `synthstat'<abs(``actualstat'') & `synthstat'!=.
	}
	local `pvalue'=1-`r(N)'/`iter' //and convert that count to p-value 
	if ``counter''==1 {
		local `finalpvalue'=``pvalue''  //this is the p-value that tells us how likely we are to see the observed result as compared to the synthetic null distribution
	}
	*sum `synthstat', det
	*disp "``actualstat''"

	if "`displayprogress'" !="" { //if we display progress we show the p-values of every possible treatment effect 
		disp in green "Counter: " in yellow "``counter''"
		disp in green "Treatment Effect: " in yellow "``tau''" 
		disp in green "P-value: " in yellow "``pvalue''"
		disp "-------------------"
	}
	

	qui replace `pvalueforgraph'=``pvalue'' in ``counter'' //recording the pvalues and treatment effects for output graph
	qui replace `tauforgraph'=``tau'' in ``counter''
	qui replace `counterforgraph'=``counter'' in ``counter''
	
	if ``pvalue''!=0 & ``donegativenow''==0 { //we first start iteratively adding the specified value to possible treatment effects 
		local `tau'=``tau''+`granularity' 
		local `counter'=``counter''+1
	}
	if ``pvalue''==0 & ``donegativenow''==0 { //once the observed result is outside the synthetic distribution, we stop and start generating synthetic distributions for negative treatment effects
		local `donegativenow'=1
		local `pvalue'=1
		local `tau'=0
	}

	if ``donegativenow''==1 & ``pvalue''!=0 { //here we geneate the negative treatment effect distributions 
		local `tau'=``tau''-`granularity'	
		local `counter'=``counter''+1
	}
	if ``donegativenow''==1 & ``pvalue''==0 { 
		local `innull'=0 //once the observed result is outside the negative treatment effect synthetic distributions, we stop 
	}
}
//defining final output variables and macros 
tempname round_length optimaltau uppercounter upperbound lowercounter lowerbound lowtreat hightreat formatlabel roundedtaulabel roundedplabel
tempvar under95

//determine significant figures for graphs and output 
local `round_length'=1/(10^length("`granularity'"))
disp "rounding to the ``round_length''"
qui sum `pvalueforgraph'
qui sum `tauforgraph' if substr(string(`pvalueforgraph'),1,5)==substr(string(`r(max)'),1,5) //this handles weird long values 
local `optimaltau'=`r(mean)'


//identify confidence interval 
gen `under95'=`pvalueforgraph'<.05
gsort `under95' - `tauforgraph'
local `uppercounter' "`counterforgraph'[1]" 
local `upperbound'=``uppercounter''
gsort `under95' + `tauforgraph'
local `lowercounter'= "`counterforgraph'[1]"
local `lowerbound'=``lowercounter''
sort `counterforgraph'
local `lowtreat'="`tauforgraph'[``lowerbound'']"
local `hightreat'="`tauforgraph'[``upperbound'']"

//generating main output 

disp in green "-------------------"
disp in green `"Final Treatment Effect: "' in yellow round(``optimaltau'',``round_length'')
disp in green "-------------------"
disp in green `"Final p-value: "' in yellow round(``finalpvalue'',``round_length'')
disp in green "-------------------"
disp in green `"Final 95% Confidence Interval: ("' in yellow round(``lowtreat'', ``round_length'') `","' round(``hightreat'', ``round_length'') `")"'
disp in green "-------------------"

//creating output graph  
local `formatlabel'=length("``round_length''")-1 
local `roundedtaulabel'=string(``optimaltau'', "%12.``formatlabel''f")

local `roundedplabel'=string(``finalpvalue'', "%12.``formatlabel''f")

if "`nofigure'"=="" {
	twoway line `pvalueforgraph' `tauforgraph', xtitle("treatment effect") ytitle("probability that this is the effect") sort(`tauforgraph') title("Treatment effect: ``roundedtaulabel''") subtitle("p-value: ``roundedplabel''") 
}
//storing treatment variable and p-value 
ereturn scalar tau=``optimaltau''
ereturn scalar pvalue = ``finalpvalue''

restore

	
end


   