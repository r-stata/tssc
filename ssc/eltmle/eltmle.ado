*! version 2.2.4  24.July.2019
*! ELTMLE: Stata module for Ensemble Learning Targeted Maximum Likelihood Estimation
*! by Miguel Angel Luque-Fernandez [cre,aut]
*! Bug reports:
*! miguel-angel.luque at lshtm.ac.uk

/*
Copyright (c) 2019  <Miguel Angel Luque-Fernandez>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

***************************************************************************
** MIGUEL ANGEL LUQUE FERNANDEZ
** mluquefe at hsph.havard.edu // miguel-angel.luque at lshtm.ac.uk
** TMLE ALGORITHM IMPLEMENTATION IN STATA FOR BINARY OR CONTINUOUS 
** OUTCOME AND BINARY TREATMENT FOR MAC and WINDOWS USERS 
** This program requires R to be installed in your computer
** June 2019
****************************************************************************

* Improved the output including potential outcomes and propensity score 
* Included estimation for continuous outcomes 
* Included marginal odds ratio
* Improved estimation of the clever covariate for both H1W and H0W
* Included Influence curve (IC) estimation for the marginal OR
* Improved IC estimation  
* Update globals to locals where possible
* Just one ado file for both Mac and Windows users
* Included additive effect for continuous outcomes
* Fixed ATE 95%CI for additive risk difference 15.10.2018
* Included HAW as a sampling weight in MLE for targerted step (gain in efficiency) for the ATE
* Updated as a rclass programm: returning scalars for ATE, ATE 95%CI, ATE SE, CRR, MOR and CRR, MOR SEs
* Improved the output display 

capture program drop eltmle
program define eltmle
		 syntax varlist(min=3) [if] [pw] [, tmle tmlebgam tmleglsrf] 
         version 13.2
         marksample touse
         local var `varlist' if `touse'
         tokenize `var'
         local yvar = "`1'" 
         global flag = cond(`yvar'<=1,1,0)
         qui sum `yvar'
         global b = `r(max)'
         global a = `r(min)'
         qui replace `yvar' = (`yvar' - `r(min)') / (`r(max)' - `r(min)') if `yvar'>1
         local dir `c(pwd)'
         cd "`dir'"
		 tempfile data
		 qui save "`data'.dta", replace 
         qui export delimited `var' using "data.csv", nolabel replace 
         if "`tmlebgam'" == "" & "`tmleglsrf'" == "" {
                tmle `varlist'  
                }
         else if "`tmlebgam'" == "tmlebgam" {
                tmlebgam `varlist'
                }
         else if "`tmleglsrf'" == "tmleglsrf" {
                tmleglsrf `varlist'
                }
end

program tmle, rclass 
// Write R Code dependencies: foreign Surperlearner 
set more off
qui: file close _all
qui: file open rcode using SLS.R, write replace
qui: file write rcode ///
        `"set.seed(123)"' _newline ///
        `"list.of.packages <- c("foreign","SuperLearner")"' _newline ///
        `"new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]"' _newline ///
        `"if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')"' _newline ///
        `"library(SuperLearner)"' _newline ///
        `"library(foreign)"' _newline ///
        `"data <- read.csv("data.csv", sep=",")"' _newline ///
        `"attach(data)"' _newline ///
        `"SL.library <- c("SL.glm","SL.step","SL.glm.interaction")"' _newline ///
        `"n <- nrow(data)"' _newline ///
        `"nvar <- dim(data)[[2]]"' _newline ///
        `"Y <- data[,1]"' _newline ///
        `"A <- data[,2]"' _newline ///
        `"X <- data[,2:nvar]"' _newline ///
        `"W <- data[,3:nvar]"' _newline ///
        `"X1 <- X0 <- X"' _newline /// 
        `"X1[,1] <- 1"' _newline ///
        `"X0[,1] <- 0"' _newline ///
        `"newdata <- rbind(X,X1,X0)"' _newline /// 
        `"Q <- try(SuperLearner(Y = data[,1] ,X = X, SL.library=SL.library, family = "binomial", newX=newdata, method ="method.NNLS"), silent=TRUE)"' _newline ///
        `"Q <- as.data.frame(Q[[4]])"' _newline ///
        `"QAW <- Q[1:n,]"' _newline ///
        `"Q1W <- Q[((n+1):(2*n)),]"' _newline ///
        `"Q0W <- Q[((2*n+1):(3*n)),]"' _newline ///
        `"g <- suppressWarnings(SuperLearner(Y = data[,2], X = W, SL.library = SL.library, family = "binomial", method = "method.NNLS"))"' _newline ///
        `"ps <- g[[4]]"' _newline ///
        `"ps[ps<0.025] <- 0.025"' _newline ///
        `"ps[ps>0.975] <- 0.975"' _newline ///
        `"data <- cbind(data,QAW,Q1W,Q0W,ps,Y,A)"' _newline ///
        `"write.dta(data, "data2.dta")"'  
qui: file close rcode

	if "`c(os)'" == "MacOSX" {
	// Run R (you have to specify the path of your R executable file)
	//shell "C:\Program Files\R\R-3.3.2\bin\x64\R.exe" CMD BATCH SLSTATA.R 
	shell "/usr/local/bin/r" CMD BATCH SLS.R 
	}
	else{
	// Write bacth file to find R.exe path and R version
	set more off
	qui: file close _all
	qui: file open bat using setup.bat, write replace
	qui: file write bat ///
	`"@echo off"' _newline ///
	`"SET PATHROOT=C:\Program Files\R\"' _newline ///
	`"echo Locating path of R..."' _newline ///
	`"echo."' _newline ///
	`"if not exist "%PATHROOT%" goto:NO_R"' _newline ///
	`"for /f "delims=" %%r in (' dir /b "%PATHROOT%R*" ') do ("' _newline ///
			`"echo Found %%r"' _newline ///
			`"echo shell "%PATHROOT%%%r\bin\x64\R.exe" CMD BATCH SLS.R > runr.do"' _newline ///
			`"echo All set!"' _newline ///  
			`"goto:DONE"' _newline ///
	`")"' _newline ///
	`":NO_R"' _newline ///
	`"echo R is not installed in your system."' _newline ///
	`"echo."' _newline ///
	`"echo Download it from https://cran.r-project.org/bin/windows/base/"' _newline ///
	`"echo Install it and re-run this script"' _newline ///
	`":DONE"' _newline ///
	`"echo."' _newline ///
	`"pause"'
	qui: file close bat
	//Run batch
	shell setup.bat 
	//Run R 
	do runr.do
	}

// Read Revised Data Back to Stata
clear
quietly: use "data2.dta", clear
tempvar logQAW logQ1W logQ0W HAW H1W H0W eps1 eps2 eps ATE ICrr ICor
// Q to logit scale
gen `logQAW' = log(QAW / (1 - QAW))
gen `logQ1W' = log(Q1W / (1 - Q1W))
gen `logQ0W' = log(Q0W / (1 - Q0W))
 
// Clever covariate HAW
gen  `HAW' = (A / ps) - ((1 - A) / (1 - ps))
gen  `H1W' = A / ps
gen  `H0W' = (1 - A) / (1 - ps)

// Estimation of the substitution parameter (Epsilon)
qui glm Y `H1W' `H0W', fam(binomial) offset(`logQAW') robust noconstant
mat a= e(b)
gen `eps1' = a[1,1]
gen `eps2' = a[1,2]

qui glm Y `HAW', fam(binomial) offset(`logQAW') robust noconstant
mat a= e(b)
gen `eps' = a[1,1]


// Targeted ATE, update from Q̅^0 (A,W) to Q̅^1 (A,W)
gen double Qa0star = exp(`H0W'*`eps' + `logQ0W')/(1 + exp(`H0W'*`eps' + `logQ0W'))
gen double Qa1star = exp(`H1W'*`eps' + `logQ1W')/(1 + exp(`H1W'*`eps' + `logQ1W'))

gen double Q0star = exp(`H0W'*`eps2' + `logQ0W')/(1 + exp(`H0W'*`eps2' + `logQ0W'))
gen double Q1star = exp(`H1W'*`eps1' + `logQ1W')/(1 + exp(`H1W'*`eps1' + `logQ1W'))

gen double cin = ($b - $a)

gen double POM1 = cond($flag == 1, Qa1star, Qa1star * cin, .)
gen double POM0 = cond($flag == 1, Qa0star, Qa0star * cin, .)

summ POM1 POM0 ps

// Estimating the updated targeted ATE binary outcome
gen double ATE = cond($flag == 1, (Qa1star - Qa0star), (Qa1star - Qa0star) * cin, .)
qui sum ATE
return scalar ATEtmle = r(mean)

// Relative risk
qui sum Q1star
local Q1 = r(mean)
qui sum Q0star
local Q0 = r(mean)

// Relative risk and Odds ratio 
local RRtmle = `Q1'/`Q0'
local logRRtmle = log(`Q1') - log(`Q0')
local ORtmle = (`Q1' * (1 - `Q0')) / ((1 - `Q1') * `Q0')

// Statistical inference (Efficient Influence Curve)
gen d1 = cond($flag == 1,(A * (Y - Q1star) / ps) + Q1star - `Q1',(A * (Y - Qa1star) / ps) + Qa1star - `Q1' ,.)
gen d0 = cond($flag == 1,(1 - A) * (Y - Q0star) / (1 - ps) + Q0star - `Q0',(1 - A) * (Y - Qa0star) / (1 - ps) + Qa0star - `Q0' ,.)
gen IC = cond($flag == 1,(d1 - d0),(d1 - d0) * cin, .)
qui sum IC
return scalar ATE_SE_tmle = sqrt(r(Var)/r(N))

// Statistical inference ATE 
return scalar ATE_pvalue =  2 * (normalden(abs(return(ATEtmle) / (return(ATE_SE_tmle)))))
return scalar ATE_LCIa   =  return(ATEtmle) - 1.96 * return(ATE_SE_tmle)
return scalar ATE_UCIa   =  return(ATEtmle) + 1.96 * return(ATE_SE_tmle)

// Statistical inference RR
gen `ICrr' = (1/`Q1' * d1) + ((1/`Q0') * d0)
qui sum `ICrr'
local varICrr = r(Var)/r(N)

local LCIrr =  exp(`logRRtmle' - 1.96 * sqrt(`varICrr'))
local UCIrr =  exp(`logRRtmle' + 1.96 * sqrt(`varICrr'))

// Statistical inference OR
gen `ICor' = ((1 - `Q0') / `Q0' / (1 - `Q1')^2) * d1 - (`Q1' / (1 - `Q1') / `Q0'^2) * d0 
qui sum `ICor'
local varICor = r(Var)/r(N)

local LCIOr =  `ORtmle' - 1.96 * sqrt(`varICor')
local UCIOr =  `ORtmle' + 1.96 * sqrt(`varICor')

// Display Results 

return scalar CRR = `RRtmle'
return scalar SE_log_CRR  = sqrt(`varICrr')
return scalar MOR = `ORtmle'
return scalar SE_log_MOR  = sqrt(`varICor')

if $flag==1 {
disp as text "{hline 32}"
di "TMLE: Average Treatment Effect"
disp as text "{hline 32}"
disp as text "ATE:      " "{c |}" %7.4f as result return(ATEtmle)
disp as text "SE:       " "{c |}" %7.4f as result return(ATE_SE_tmle)
disp as text "P-value:  " "{c |}" %7.4f as result return(ATE_pvalue)
disp as text "95%CI:    " "{c |}" %7.4f as result return(ATE_LCIa) ","  %7.4f as result return(ATE_UCIa)
disp as text "{hline 32}"
}
else if $flag!=1{
disp as text "{hline 32}"
di "TMLE: Average Treatment Effect"
disp as text "{hline 32}"
disp as text "ATE:      " "{c |}" %7.1f as result return(ATEtmle)
disp as text "SE:       " "{c |}" %7.1f as result return(ATE_SE_tmle)
disp as text "P-value:  " "{c |}" %7.4f as result return(ATE_pvalue)
disp as text "95%CI:    " "{c |}" %7.1f as result return(ATE_LCIa) ","  %7.1f as result return(ATE_UCIa)
disp as text "{hline 32}"
}

local rrbin ""CRR: "%4.2f `RRtmle'  "; 95%CI:("%3.2f `LCIrr' ", "%3.2f `UCIrr' ")""
local orbin ""MOR: "%4.2f `ORtmle'  "; 95%CI:("%3.2f `LCIOr' ", "%3.2f `UCIOr' ")""

disp as text "{hline 29}"
di "TMLE: Causal Risk Ratio (CRR)" 
disp as text "{hline 29}"
di `rrbin'
disp as text "{hline 29}"
disp as text "{hline 31}"
di "TMLE: Marginal Odds Ratio (MOR)" 
disp as text "{hline 31}"
di `orbin'
disp as text "{hline 31}"

label var POM1 "Potential Outcome Y(1)"
label var POM0 "Potential Otucome Y(0)"
label var ps "Propensity Score"

drop d1 d0 POM1 POM0 ps QAW Q1W Q0W Q1star Qa1star Q0star Qa0star ATE IC Y A cin

// Clean up
quietly: rm SLS.R
quietly: rm SLS.Rout
quietly: rm data2.dta
quietly: rm data.csv
quietly: rm .RData
end

program tmlebgam, rclass 
// Write R Code dependencies: foreign Surperlearner 
set more off
qui: file close _all
qui: file open rcode using SLS.R, write replace
qui: file write rcode ///
		`"set.seed(123)"' _newline ///
        `"list.of.packages <- c("foreign","SuperLearner","gam","arm")"' _newline ///
        `"new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]"' _newline ///
        `"if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')"' _newline ///
        `"library(SuperLearner)"' _newline ///
        `"library(foreign)"' _newline ///
        `"data <- read.csv("data.csv", sep=",")"' _newline ///
        `"attach(data)"' _newline ///
        `"SL.library <- c("SL.glm","SL.step","SL.glm.interaction","SL.gam","SL.bayesglm")"' _newline ///
        `"n <- nrow(data)"' _newline ///
        `"nvar <- dim(data)[[2]]"' _newline ///
        `"Y <- data[,1]"' _newline ///
        `"A <- data[,2]"' _newline ///
        `"X <- data[,2:nvar]"' _newline ///
        `"W <- data[,3:nvar]"' _newline ///
        `"X1 <- X0 <- X"' _newline /// 
        `"X1[,1] <- 1"' _newline ///
        `"X0[,1] <- 0"' _newline ///
        `"newdata <- rbind(X,X1,X0)"' _newline /// 
        `"Q <- try(SuperLearner(Y = data[,1] ,X = X, SL.library=SL.library, family = "binomial", newX=newdata, method ="method.NNLS"), silent=TRUE)"' _newline ///
        `"Q <- as.data.frame(Q[[4]])"' _newline ///
        `"QAW <- Q[1:n,]"' _newline ///
        `"Q1W <- Q[((n+1):(2*n)),]"' _newline ///
        `"Q0W <- Q[((2*n+1):(3*n)),]"' _newline ///
        `"g <- suppressWarnings(SuperLearner(Y = data[,2], X = W, SL.library = SL.library, family = "binomial", method = "method.NNLS"))"' _newline ///
        `"ps <- g[[4]]"' _newline ///
        `"ps[ps<0.025] <- 0.025"' _newline ///
        `"ps[ps>0.975] <- 0.975"' _newline ///
        `"data <- cbind(data,QAW,Q1W,Q0W,ps,Y,A)"' _newline ///
        `"write.dta(data, "data2.dta")"'    
qui: file close rcode

	if "`c(os)'" == "MacOSX" {
	// Run R (you have to specify the path of your R executable file)
	//shell "C:\Program Files\R\R-3.3.2\bin\x64\R.exe" CMD BATCH SLSTATA.R 
	shell "/usr/local/bin/r" CMD BATCH SLS.R 
	}
	else{
	// Write bacth file to find R.exe path and R version
	set more off
	qui: file close _all
	qui: file open bat using setup.bat, write replace
	qui: file write bat ///
	`"@echo off"' _newline ///
	`"SET PATHROOT=C:\Program Files\R\"' _newline ///
	`"echo Locating path of R..."' _newline ///
	`"echo."' _newline ///
	`"if not exist "%PATHROOT%" goto:NO_R"' _newline ///
	`"for /f "delims=" %%r in (' dir /b "%PATHROOT%R*" ') do ("' _newline ///
			`"echo Found %%r"' _newline ///
			`"echo shell "%PATHROOT%%%r\bin\x64\R.exe" CMD BATCH SLS.R > runr.do"' _newline ///
			`"echo All set!"' _newline ///  
			`"goto:DONE"' _newline ///
	`")"' _newline ///
	`":NO_R"' _newline ///
	`"echo R is not installed in your system."' _newline ///
	`"echo."' _newline ///
	`"echo Download it from https://cran.r-project.org/bin/windows/base/"' _newline ///
	`"echo Install it and re-run this script"' _newline ///
	`":DONE"' _newline ///
	`"echo."' _newline ///
	`"pause"'
	qui: file close bat
	//Run batch
	shell setup.bat 
	//Run R 
	do runr.do
	}

// Read Revised Data Back to Stata
clear
quietly: use "data2.dta", clear
tempvar logQAW logQ1W logQ0W HAW H1W H0W eps1 eps2 eps ATE ICrr ICor
// Q to logit scale
gen `logQAW' = log(QAW / (1 - QAW))
gen `logQ1W' = log(Q1W / (1 - Q1W))
gen `logQ0W' = log(Q0W / (1 - Q0W))
 
// Clever covariate HAW
gen  `HAW' = (A / ps) - ((1 - A) / (1 - ps))
gen  `H1W' = A / ps
gen  `H0W' = (1 - A) / (1 - ps)

// Estimation of the substitution parameter (Epsilon)
qui glm Y `H1W' `H0W', fam(binomial) offset(`logQAW') robust noconstant
mat a= e(b)
gen `eps1' = a[1,1]
gen `eps2' = a[1,2]

qui glm Y `HAW', fam(binomial) offset(`logQAW') robust noconstant
mat a= e(b)
gen `eps' = a[1,1]


// Targeted ATE, update from Q̅^0 (A,W) to Q̅^1 (A,W)
gen double Qa0star = exp(`H0W'*`eps' + `logQ0W')/(1 + exp(`H0W'*`eps' + `logQ0W'))
gen double Qa1star = exp(`H1W'*`eps' + `logQ1W')/(1 + exp(`H1W'*`eps' + `logQ1W'))

gen double Q0star = exp(`H0W'*`eps2' + `logQ0W')/(1 + exp(`H0W'*`eps2' + `logQ0W'))
gen double Q1star = exp(`H1W'*`eps1' + `logQ1W')/(1 + exp(`H1W'*`eps1' + `logQ1W'))

gen double cin = ($b - $a)

gen double POM1 = cond($flag == 1, Qa1star, Qa1star * cin, .)
gen double POM0 = cond($flag == 1, Qa0star, Qa0star * cin, .)

summ POM1 POM0 ps

// Estimating the updated targeted ATE binary outcome
gen double ATE = cond($flag == 1, (Qa1star - Qa0star), (Qa1star - Qa0star) * cin, .)
qui sum ATE
return scalar ATEtmle = r(mean)

// Relative risk
qui sum Q1star
local Q1 = r(mean)
qui sum Q0star
local Q0 = r(mean)

// Relative risk and Odds ratio 
local RRtmle = `Q1'/`Q0'
local logRRtmle = log(`Q1') - log(`Q0')
local ORtmle = (`Q1' * (1 - `Q0')) / ((1 - `Q1') * `Q0')

// Statistical inference (Efficient Influence Curve)
gen d1 = cond($flag == 1,(A * (Y - Q1star) / ps) + Q1star - `Q1',(A * (Y - Qa1star) / ps) + Qa1star - `Q1' ,.)
gen d0 = cond($flag == 1,(1 - A) * (Y - Q0star) / (1 - ps) + Q0star - `Q0',(1 - A) * (Y - Qa0star) / (1 - ps) + Qa0star - `Q0' ,.)
gen IC = cond($flag == 1,(d1 - d0),(d1 - d0) * cin, .)
qui sum IC
return scalar ATE_SE_tmle = sqrt(r(Var)/r(N))

// Statistical inference ATE 
return scalar ATE_pvalue =  2 * (normalden(abs(return(ATEtmle) / (return(ATE_SE_tmle)))))
return scalar ATE_LCIa   =  return(ATEtmle) - 1.96 * return(ATE_SE_tmle)
return scalar ATE_UCIa   =  return(ATEtmle) + 1.96 * return(ATE_SE_tmle)

// Statistical inference RR
gen `ICrr' = (1/`Q1' * d1) + ((1/`Q0') * d0)
qui sum `ICrr'
local varICrr = r(Var)/r(N)

local LCIrr =  exp(`logRRtmle' - 1.96 * sqrt(`varICrr'))
local UCIrr =  exp(`logRRtmle' + 1.96 * sqrt(`varICrr'))

// Statistical inference OR
gen `ICor' = ((1 - `Q0') / `Q0' / (1 - `Q1')^2) * d1 - (`Q1' / (1 - `Q1') / `Q0'^2) * d0 
qui sum `ICor'
local varICor = r(Var)/r(N)

local LCIOr =  `ORtmle' - 1.96 * sqrt(`varICor')
local UCIOr =  `ORtmle' + 1.96 * sqrt(`varICor')

// Display Results 

return scalar CRR = `RRtmle'
return scalar SE_log_CRR  = sqrt(`varICrr')
return scalar MOR = `ORtmle'
return scalar SE_log_MOR  = sqrt(`varICor')

if $flag==1 {
disp as text "{hline 32}"
di "TMLE: Average Treatment Effect"
disp as text "{hline 32}"
disp as text "ATE:      " "{c |}" %7.4f as result return(ATEtmle)
disp as text "SE:       " "{c |}" %7.4f as result return(ATE_SE_tmle)
disp as text "P-value:  " "{c |}" %7.4f as result return(ATE_pvalue)
disp as text "95%CI:    " "{c |}" %7.4f as result return(ATE_LCIa) ","  %7.4f as result return(ATE_UCIa)
disp as text "{hline 32}"
}
else if $flag!=1{
disp as text "{hline 32}"
di "TMLE: Average Treatment Effect"
disp as text "{hline 32}"
disp as text "ATE:      " "{c |}" %7.1f as result return(ATEtmle)
disp as text "SE:       " "{c |}" %7.1f as result return(ATE_SE_tmle)
disp as text "P-value:  " "{c |}" %7.4f as result return(ATE_pvalue)
disp as text "95%CI:    " "{c |}" %7.1f as result return(ATE_LCIa) ","  %7.1f as result return(ATE_UCIa)
disp as text "{hline 32}"
}

local rrbin ""CRR: "%4.2f `RRtmle'  "; 95%CI:("%3.2f `LCIrr' ", "%3.2f `UCIrr' ")""
local orbin ""MOR: "%4.2f `ORtmle'  "; 95%CI:("%3.2f `LCIOr' ", "%3.2f `UCIOr' ")""

disp as text "{hline 29}"
di "TMLE: Causal Risk Ratio (CRR)" 
disp as text "{hline 29}"
di `rrbin'
disp as text "{hline 29}"
disp as text "{hline 31}"
di "TMLE: Marginal Odds Ratio (MOR)" 
disp as text "{hline 31}"
di `orbin'
disp as text "{hline 31}"

label var POM1 "Potential Outcome Y(1)"
label var POM0 "Potential Otucome Y(0)"
label var ps "Propensity Score"

drop d1 d0 POM1 POM0 ps QAW Q1W Q0W Q1star Qa1star Q0star Qa0star ATE IC Y A cin

// Clean up
quietly: rm SLS.R
quietly: rm SLS.Rout
quietly: rm data2.dta
quietly: rm data.csv
quietly: rm .RData
end

program tmleglsrf, rclass 
// Write R Code dependencies: foreign Surperlearner 
set more off
qui: file close _all
qui: file open rcode using SLS.R, write replace
qui: file write rcode ///
		`"set.seed(123)"' _newline ///
        `"list.of.packages <- c("foreign","SuperLearner","glmnet","randomForest")"' _newline ///
        `"new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]"' _newline ///
        `"if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')"' _newline ///
        `"library(SuperLearner)"' _newline ///
        `"library(foreign)"' _newline ///
        `"data <- read.csv("data.csv", sep=",")"' _newline ///
        `"attach(data)"' _newline ///
        `"SL.library <- c("SL.glm","SL.step","SL.glm.interaction","SL.gam","SL.glmnet","SL.randomForest")"' _newline ///
        `"n <- nrow(data)"' _newline ///
        `"nvar <- dim(data)[[2]]"' _newline ///
        `"Y <- data[,1]"' _newline ///
        `"A <- data[,2]"' _newline ///
        `"X <- data[,2:nvar]"' _newline ///
        `"W <- data[,3:nvar]"' _newline ///
        `"X1 <- X0 <- X"' _newline /// 
        `"X1[,1] <- 1"' _newline ///
        `"X0[,1] <- 0"' _newline ///
        `"newdata <- rbind(X,X1,X0)"' _newline /// 
        `"Q <- try(SuperLearner(Y = data[,1] ,X = X, SL.library=SL.library, family = "binomial", newX=newdata, method ="method.NNLS"), silent=TRUE)"' _newline ///
        `"Q <- as.data.frame(Q[[4]])"' _newline ///
        `"QAW <- Q[1:n,]"' _newline ///
        `"Q1W <- Q[((n+1):(2*n)),]"' _newline ///
        `"Q0W <- Q[((2*n+1):(3*n)),]"' _newline ///
        `"g <- suppressWarnings(SuperLearner(Y = data[,2], X = W, SL.library = SL.library, family = "binomial", method = "method.NNLS"))"' _newline ///
        `"ps <- g[[4]]"' _newline ///
        `"ps[ps<0.025] <- 0.025"' _newline ///
        `"ps[ps>0.975] <- 0.975"' _newline ///
        `"data <- cbind(data,QAW,Q1W,Q0W,ps,Y,A)"' _newline ///
        `"write.dta(data, "data2.dta")"'  
qui: file close rcode

	if "`c(os)'" == "MacOSX" {
	// Run R (you have to specify the path of your R executable file)
	//shell "C:\Program Files\R\R-3.3.2\bin\x64\R.exe" CMD BATCH SLSTATA.R 
	shell "/usr/local/bin/r" CMD BATCH SLS.R 
	}
	else{
	// Write bacth file to find R.exe path and R version
	set more off
	qui: file close _all
	qui: file open bat using setup.bat, write replace
	qui: file write bat ///
	`"@echo off"' _newline ///
	`"SET PATHROOT=C:\Program Files\R\"' _newline ///
	`"echo Locating path of R..."' _newline ///
	`"echo."' _newline ///
	`"if not exist "%PATHROOT%" goto:NO_R"' _newline ///
	`"for /f "delims=" %%r in (' dir /b "%PATHROOT%R*" ') do ("' _newline ///
			`"echo Found %%r"' _newline ///
			`"echo shell "%PATHROOT%%%r\bin\x64\R.exe" CMD BATCH SLS.R > runr.do"' _newline ///
			`"echo All set!"' _newline ///  
			`"goto:DONE"' _newline ///
	`")"' _newline ///
	`":NO_R"' _newline ///
	`"echo R is not installed in your system."' _newline ///
	`"echo."' _newline ///
	`"echo Download it from https://cran.r-project.org/bin/windows/base/"' _newline ///
	`"echo Install it and re-run this script"' _newline ///
	`":DONE"' _newline ///
	`"echo."' _newline ///
	`"pause"'
	qui: file close bat
	//Run batch
	shell setup.bat 
	//Run R 
	do runr.do
	}

// Read Revised Data Back to Stata
clear
quietly: use "data2.dta", clear
tempvar logQAW logQ1W logQ0W HAW H1W H0W eps1 eps2 eps ATE ICrr ICor
// Q to logit scale
gen `logQAW' = log(QAW / (1 - QAW))
gen `logQ1W' = log(Q1W / (1 - Q1W))
gen `logQ0W' = log(Q0W / (1 - Q0W))
 
// Clever covariate HAW
gen  `HAW' = (A / ps) - ((1 - A) / (1 - ps))
gen  `H1W' = A / ps
gen  `H0W' = (1 - A) / (1 - ps)

// Estimation of the substitution parameter (Epsilon)
qui glm Y `H1W' `H0W', fam(binomial) offset(`logQAW') robust noconstant
mat a= e(b)
gen `eps1' = a[1,1]
gen `eps2' = a[1,2]

qui glm Y `HAW', fam(binomial) offset(`logQAW') robust noconstant
mat a= e(b)
gen `eps' = a[1,1]


// Targeted ATE, update from Q̅^0 (A,W) to Q̅^1 (A,W)
gen double Qa0star = exp(`H0W'*`eps' + `logQ0W')/(1 + exp(`H0W'*`eps' + `logQ0W'))
gen double Qa1star = exp(`H1W'*`eps' + `logQ1W')/(1 + exp(`H1W'*`eps' + `logQ1W'))

gen double Q0star = exp(`H0W'*`eps2' + `logQ0W')/(1 + exp(`H0W'*`eps2' + `logQ0W'))
gen double Q1star = exp(`H1W'*`eps1' + `logQ1W')/(1 + exp(`H1W'*`eps1' + `logQ1W'))

gen double cin = ($b - $a)

gen double POM1 = cond($flag == 1, Qa1star, Qa1star * cin, .)
gen double POM0 = cond($flag == 1, Qa0star, Qa0star * cin, .)

summ POM1 POM0 ps

// Estimating the updated targeted ATE binary outcome
gen double ATE = cond($flag == 1, (Qa1star - Qa0star), (Qa1star - Qa0star) * cin, .)
qui sum ATE
return scalar ATEtmle = r(mean)

// Relative risk
qui sum Q1star
local Q1 = r(mean)
qui sum Q0star
local Q0 = r(mean)

// Relative risk and Odds ratio 
local RRtmle = `Q1'/`Q0'
local logRRtmle = log(`Q1') - log(`Q0')
local ORtmle = (`Q1' * (1 - `Q0')) / ((1 - `Q1') * `Q0')

// Statistical inference (Efficient Influence Curve)
gen d1 = cond($flag == 1,(A * (Y - Q1star) / ps) + Q1star - `Q1',(A * (Y - Qa1star) / ps) + Qa1star - `Q1' ,.)
gen d0 = cond($flag == 1,(1 - A) * (Y - Q0star) / (1 - ps) + Q0star - `Q0',(1 - A) * (Y - Qa0star) / (1 - ps) + Qa0star - `Q0' ,.)
gen IC = cond($flag == 1,(d1 - d0),(d1 - d0) * cin, .)
qui sum IC
return scalar ATE_SE_tmle = sqrt(r(Var)/r(N))

// Statistical inference ATE 
return scalar ATE_pvalue =  2 * (normalden(abs(return(ATEtmle) / (return(ATE_SE_tmle)))))
return scalar ATE_LCIa   =  return(ATEtmle) - 1.96 * return(ATE_SE_tmle)
return scalar ATE_UCIa   =  return(ATEtmle) + 1.96 * return(ATE_SE_tmle)

// Statistical inference RR
gen `ICrr' = (1/`Q1' * d1) + ((1/`Q0') * d0)
qui sum `ICrr'
local varICrr = r(Var)/r(N)

local LCIrr =  exp(`logRRtmle' - 1.96 * sqrt(`varICrr'))
local UCIrr =  exp(`logRRtmle' + 1.96 * sqrt(`varICrr'))

// Statistical inference OR
gen `ICor' = ((1 - `Q0') / `Q0' / (1 - `Q1')^2) * d1 - (`Q1' / (1 - `Q1') / `Q0'^2) * d0 
qui sum `ICor'
local varICor = r(Var)/r(N)

local LCIOr =  `ORtmle' - 1.96 * sqrt(`varICor')
local UCIOr =  `ORtmle' + 1.96 * sqrt(`varICor')

// Display Results 

return scalar CRR = `RRtmle'
return scalar SE_log_CRR  = sqrt(`varICrr')
return scalar MOR = `ORtmle'
return scalar SE_log_MOR  = sqrt(`varICor')

if $flag==1 {
disp as text "{hline 32}"
di "TMLE: Average Treatment Effect"
disp as text "{hline 32}"
disp as text "ATE:      " "{c |}" %7.4f as result return(ATEtmle)
disp as text "SE:       " "{c |}" %7.4f as result return(ATE_SE_tmle)
disp as text "P-value:  " "{c |}" %7.4f as result return(ATE_pvalue)
disp as text "95%CI:    " "{c |}" %7.4f as result return(ATE_LCIa) ","  %7.4f as result return(ATE_UCIa)
disp as text "{hline 32}"
}
else if $flag!=1{
disp as text "{hline 32}"
di "TMLE: Average Treatment Effect"
disp as text "{hline 32}"
disp as text "ATE:      " "{c |}" %7.1f as result return(ATEtmle)
disp as text "SE:       " "{c |}" %7.1f as result return(ATE_SE_tmle)
disp as text "P-value:  " "{c |}" %7.4f as result return(ATE_pvalue)
disp as text "95%CI:    " "{c |}" %7.1f as result return(ATE_LCIa) ","  %7.1f as result return(ATE_UCIa)
disp as text "{hline 32}"
}

local rrbin ""CRR: "%4.2f `RRtmle'  "; 95%CI:("%3.2f `LCIrr' ", "%3.2f `UCIrr' ")""
local orbin ""MOR: "%4.2f `ORtmle'  "; 95%CI:("%3.2f `LCIOr' ", "%3.2f `UCIOr' ")""

disp as text "{hline 29}"
di "TMLE: Causal Risk Ratio (CRR)" 
disp as text "{hline 29}"
di `rrbin'
disp as text "{hline 29}"
disp as text "{hline 31}"
di "TMLE: Marginal Odds Ratio (MOR)" 
disp as text "{hline 31}"
di `orbin'
disp as text "{hline 31}"

label var POM1 "Potential Outcome Y(1)"
label var POM0 "Potential Otucome Y(0)"
label var ps "Propensity Score"

drop d1 d0 POM1 POM0 ps QAW Q1W Q0W Q1star Qa1star Q0star Qa0star ATE IC Y A cin

// Clean up
quietly: rm SLS.R
quietly: rm SLS.Rout
quietly: rm data2.dta
quietly: rm data.csv
quietly: rm .RData
end
