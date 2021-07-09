

************** Start of program

capture program drop calibrate
*! calibrate V2.1 JCD'Souza 2Feb2011
program define calibrate, rclass
version 10.1
syntax  , MARginals(varlist) POPTot(string) ENTrywt(string) EXITwt(string) ///
 [PRInt(string) GRAPHs(string) QVar(string) METHod(string)  ///
 SAMPvars(varlist) outc(string) TOLerance(real 0.000001) maxit(int 15) UBound(real 5) LBound(real 0.2)]



************** Check the input is correctly defined


* The marginals and entrywt should be numeric
confirm numeric variable `marginals' `entrywt' 


* Check poptot is a matrix and print, graphs, and method  take correct values
capture confirm matrix `poptot'
if _rc!=0 {
	display in red  "Matrix required for poptot"
	exit _rc
}

if "`print'" != "" & "`print'" != "all" & "`print'" != "final" & "`print'" != "none" {
	display in red  "Options for print are all, final or none"
	exit 
}


if "`graphs'" != "" & "`graphs'" != "all" & "`graphs'" != "final" & "`graphs'" != "none" {
	display in red  "Options for graphs are all, final or none"
	exit 
}


if "`method'" != "" & "`method'" != "linear" & "`method'" != "logistic" & ///
"`method'" != "nrSS" & "`method'" != "nr2A" & "`method'" != "nr2B" & "`method'" != "nr2C" &"`method'" != "blinear" {
	display in red  "Options for method are linear, logistic, blinear, nrSS, nr2A, nr2B or nr2C "
	exit 
}

if "`method'" == "nrSS" | "`method'" == "nr2A" | "`method'" == "nr2B" | "`method'" == "nr2C" {
	if "`sampvars'"=="" | "`outc'"=="" {
		display in red  "Nonresponse methods require the options sampvars and outc"
		exit
	}
	confirm numeric variable `sampvars'
	capture assert `outc'==1 | `outc'== 0    
	if _rc!=0{
		display in red  "`outc' must be binary"
		exit 	
	}
}



* If qvar is present it should be a numerical variable. Otherwise set it to 1.
if "`qvar'" != "" {
	confirm numeric variable `qvar'
	}
	else {
		tempvar qvar
		qui: gen double `qvar'=1
}


* If method = blinear then ubound must be >1 and lbound must be <1
if "`method'" == "blinear" & (`lbound'>=1 | `ubound'<=1) {
	display in red "lbound must be < 1 and ubound must be > 1"
	exit
}


* Check that the entry weight is non-negative
capture assert (`entrywt'>=0 )
if _rc!=0{
	display in red  "Note: `entrywt' is not a non-negative variable"
	exit
}




************** Set up variables

tempname M delta sampest selest est Phat entdeff exitdeff sclmin sclmax sclsd result InvM det nrows ncols
tempvar entryq tempwt 

qui: gen double `tempwt'=`entrywt'


* Count the number of star variables (using Sarndal's terminology)
local nstar: word count `marginals' 

* Check that the dimensions of the matrix are consistent with the number of marginals

scalar `nrows'=rowsof(`poptot')
scalar `ncols'=colsof(`poptot')

if (`nstar'!=`ncols' | `nrows'!=1) {
	display in red  "`poptot' is the wrong size"
	exit _rc
}







************** Method = linear
if ("`method'" == "") | ("`method'" =="linear") { 
	qui: gen double `entryq'=`entrywt'*`qvar'	
	qui: matrix accum `M'=`marginals' [iweight=`entryq'], noconstant   // Make the matrix

	qui: matrix vecaccum `Phat'=`entrywt' `marginals', noconstant    // P-hat is the matrix of estimates 
	matrix `InvM'=invsym(`M')
	scalar `det'=det(`InvM')
	if `det'==0 {
		display in red "Matrix is singular -- check results carefully"
	}


	matrix `delta'=(`InvM')'*(`poptot' - `Phat')' 		// Change in estimate

	local i=1
	foreach x of local marginals {
		qui: replace `tempwt'=`tempwt'+`qvar'*`entrywt'*`delta'[`i',1]*`x'
	local i=`i'+1
	}						// Calculates new weight variables
}







************** Method = blinear
if "`method'" =="blinear" { 
	tempvar wt_cur wt_old qvar2 iterate change
	qui: gen `qvar2'=`qvar'

	qui: gen double `wt_old'=`entrywt'				// Weight at start of iteration
	qui: gen double `wt_cur'=`entrywt'				// Current weight

	scalar `iterate'=1			// Number of the iteration
	scalar `change'=0



	local i=1
	foreach x of local marginals {
		qui: summ `x' [iweight=`entrywt']
		if abs(`poptot'[1,`i'])>1 {
			scalar `change'=max(`change',abs((r(sum)-`poptot'[1,`i'])/`poptot'[1,`i']))
		}
		else {
			scalar `change'=max(`change',abs(r(sum)))		
		}
	local i=`i'+1
	}

if "`print'"=="all" {
	display in white "Original tolerance is " `change'
}


	while (`iterate'<=`maxit' & `change'>`tolerance') {
		qui: replace `wt_old'=`wt_cur'

		calibrate, entrywt(`wt_old') exitwt(`wt_cur') poptot(`poptot') marginals(`marginals') qvar(`qvar2') print(none) 
		qui: replace `qvar2'=0 if (`wt_cur'< `entrywt'*`lbound' | `wt_cur'> `entrywt'*`ubound')	
		qui: replace `wt_cur'=`entrywt'*`ubound' if `wt_cur'> `entrywt'*`ubound'
 		qui: replace `wt_cur'=`entrywt'*`lbound' if `wt_cur'< `entrywt'*`lbound'

		scalar `change'=0
		local i=1
		foreach x of local marginals {
			qui: summ `x' [iweight=`wt_cur']
			if abs(`poptot'[1,`i'])>1 {
				scalar `change'=max(`change',abs((r(sum)-`poptot'[1,`i'])/`poptot'[1,`i']))
			}
			else {
				scalar `change'=max(`change',abs(r(sum)))		
			}
		local i=`i'+1
		}



		* Display result of the iteration
		if "`print'"=="all" {
			display  in white "Iteration = " `iterate' " Tolerance = " `change'
			local j=1
			display in white "Variable" _column(20) "Pop total" _column(35) "Previous iteration" _column(55) "Current iteration" 
			foreach x of local marginals {
				egen `sampest'=total(`wt_cur'*`x')
				egen `selest'=total(`wt_old'*`x')
				scalar `est' = `poptot'[1,`j']
				display as result "`x'" _column(20) as result `est' _column(35) as result `selest' _column(55) as result `sampest' 
				drop `sampest' `selest' 
				local j=`j'+1
			}
		}
	scalar `iterate'=`iterate'+1
}

* This ends the iteration

if `change'>`tolerance' {
	display in red "Program has not converged after `maxit' iterations"
}

qui: replace `tempwt'=`wt_cur'
}





************** Non-response methods

if "`method'" == "nrSS" | "`method'" == "nr2A" |"`method'" == "nr2B" |"`method'" == "nr2C"  {	
	tempname sow rsow Pmoon PstarC poptotA poptotB delta
	tempvar entrywtA  exitwtA

	confirm numeric variable `sampvars' 
	matrix vecaccum `Pmoon' = `entrywt' `sampvars', noconstant	// Matrix of moon totals
	matrix vecaccum `PstarC' = `entrywt' `marginals', noconstant	// Matrix of star totals restricted to sample
	matrix `poptotA' = `poptot', `Pmoon'			// Matrix of star and moon totals
	matrix `poptotB' = `PstarC', `Pmoon'			// Matrix of star and moon totals with star restricted to the sample
	egen `sow'=total(`entrywt')		// sum of selection weights
	egen `rsow'=total(`outc'*`entrywt')	// sum of selection weights of responders
	qui: gen double `entrywtA'=`entrywt'*`outc'*`sow'/`rsow'	// Scales entrywt of responders, non-responders put to 0
}



************** Method = nrSS
if ("`method'" == "nrSS") { 
	qui: calibrate , entrywt(`entrywtA') exitwt(`exitwtA') marginals(`marginals' `sampvars') poptot(`poptotA') method(linear) qvar(`qvar')
	qui: replace `tempwt'=`exitwtA'
	matrix `delta'=r(Bhat)
}



************** Method = nr2A
if ("`method'" == "nr2A") { 
	qui: calibrate , entrywt(`entrywtA') exitwt(`exitwtA') marginals(`sampvars') poptot(`Pmoon') method(linear) qvar(`qvar')
	qui: replace `tempwt'=`exitwtA'
	qui: replace `tempwt'=0 if `tempwt'<0	
	qui: calibrate , entrywt(`tempwt') exitwt(`exitwtA') marginals(`marginals' `sampvars') poptot(`poptotA') method(linear) qvar(`qvar')
	qui: replace `tempwt'=`exitwtA'
	matrix `delta'=r(Bhat)	
}





************** Method = nr2B
if ("`method'" == "nr2B") { 
	qui: calibrate , entrywt(`entrywtA') exitwt(`exitwtA') marginals(`sampvars') poptot(`Pmoon') method(linear) qvar(`qvar')
	qui: replace `tempwt'=`exitwtA'	
	qui: replace `tempwt'=0 if `tempwt'<0	
	qui: calibrate , entrywt(`tempwt') exitwt(`exitwtA') marginals(`marginals') poptot(`poptot') method(linear) qvar(`qvar')
	qui: replace `tempwt'=`exitwtA'
	matrix `delta'=r(Bhat)	
}



************** Method = nr2C
if ("`method'" == "nr2C") { 
	qui: calibrate , entrywt(`entrywtA') exitwt(`exitwtA') marginals(`marginals' `sampvars') poptot(`poptotB') method(linear) qvar(`qvar')
	qui: replace `tempwt'=`exitwtA'
	qui: replace `tempwt'=0 if `tempwt'<0		
	qui: calibrate , entrywt(`tempwt') exitwt(`exitwtA') marginals(`marginals') poptot(`poptot') method(linear) qvar(`qvar')
	qui: replace `tempwt'=`exitwtA'	
	matrix `delta'=r(Bhat)	
}






************** Method = logistic
if "`method'" =="logistic" { 
	tempname iterate change flambda min max delta2
	tempvar wt_cur wt_old  entryq lnwt_cur

	qui: gen double `wt_old'=`entrywt'				// Weight at start of iteration
	qui: gen double `wt_cur'=`entrywt'				// Current weight
	qui: gen double `lnwt_cur'=ln(`wt_cur')			// Log of curreent wt
	qui: gen double `entryq'=`entrywt'*`qvar'
	matrix `delta'=J(`ncols',1,0)

* Begin the iteration


scalar `iterate'=1			// Number of the iteration

scalar `change'=0

local i=1
foreach x of local marginals {
	qui: summ `x' [iweight=`entrywt']
	if abs(`poptot'[1,`i'])>1 {
		scalar `change'=max(`change',abs((r(sum)-`poptot'[1,`i'])/`poptot'[1,`i']))
	}
	else {
		scalar `change'=max(`change',abs(r(sum)))		
	}
local i=`i'+1
}

if "`print'"=="all" {
	display in white "Original tolerance is " `change'
}

while (`iterate'<=`maxit' & `change'>`tolerance') {
	qui: replace `wt_old'=`wt_cur'
	qui: replace `entryq'=`wt_cur'*`qvar'
	qui: matrix accum `M'=`marginals' [iweight=`entryq'], noconstant
			// M= Matrix used in Newton-Raphson
	matrix vecaccum `Phat'=`wt_cur' `marginals', noconstant    // P-hat is the matrix of estimates 
	matrix `flambda'= `Phat' - `poptot'	// flambda = estimate minus calibration total
	matrix `InvM'=invsym(`M')
	scalar `det'=det(`InvM')
	if `det'==0 {
		display in red "Matrix is singular -- check results carefully"
	}

	matrix `delta2'=-(`InvM')*`flambda'' 		// Change in estimate
	matrix `delta'=`delta'+`delta2'

	qui: replace `lnwt_cur'=ln(`wt_cur')
	local i=1
	foreach x of local marginals {
		qui: replace `lnwt_cur'=`lnwt_cur'+(`qvar'*`delta2'[`i',1]*`x')
	local i=`i'+1
	}
	qui: replace `wt_cur'=exp(`lnwt_cur')						

	scalar `change'=0
	local i=1
	foreach x of local marginals {
		qui: summ `x' [iweight=`wt_cur']
		if abs(`poptot'[1,`i'])>1 {
			scalar `change'=max(`change',abs((r(sum)-`poptot'[1,`i'])/`poptot'[1,`i']))
		}
		else {
			scalar `change'=max(`change',abs(r(sum)))		
		}
	local i=`i'+1
	}


	* Display result of the iteration
	if "`print'"=="all" {
		display  in white "Iteration = " `iterate' " Tolerance = " `change'
		local j=1
		display in white "Variable" _column(20) "Pop total" _column(35) "Previous iteration" _column(55) "Current iteration" 
		foreach x of local marginals {
			egen `sampest'=total(`wt_cur'*`x')
			egen `selest'=total(`wt_old'*`x')
			scalar `est' = `poptot'[1,`j']
			display as result "`x'" _column(20) as result `est' _column(35) as result `selest' _column(55) as result `sampest' 
			drop `sampest' `selest' 
			local j=`j'+1
		}
	}
	scalar `iterate'=`iterate'+1
}
* This ends the iteration


if `change'>`tolerance' {
	display in red "Program has not converged after `maxit' iterations"
}

qui: replace `tempwt'=`wt_cur'
}







************* Making the final weight, with any warnings

* Now call tempwt exitwt

capture confirm new variable `exitwt'
if _rc!=0 {
	qui: replace `exitwt'=`tempwt'
}
else {
	qui: gen `exitwt'=`tempwt'
}

if "`method'" == "nrSS" | "`method'" == "nr2A" |"`method'" == "nr2B" |"`method'" == "nr2C"  {	
	qui: replace `exitwt'=. if `outc'==0 
}

* Count the number of negative weights and give a warning
tempname negwt
qui: count if `exitwt'<0
scalar `negwt'=r(N)
if `negwt'>=1 {
	display in red "Warning: " `negwt' " negative weight(s) are present"
}







*********** Printing


if "`print'" == "all" | "`print'"=="final" {
	di _newline
	di in smcl in gr "Totals" 
	if "`method'" == "linear" | "`method'"=="" | "`method'"=="logistic" {
		local j=1
		di in smcl in gr "{hline 18}{c TT}{hline 80}"
		di in smcl in gr "Variable" _col(19) %1s "{c |}" _column(20) "Pop total" _column(35) "Weighted (entrywt)" _column(55) "Weighted (exitwt)" _column(75) "R"
		di in smcl in gr "{hline 18}{c +}{hline 80}"
		foreach x of local marginals {
			egen `sampest'=total(`exitwt'*`x')
			egen `selest'=total(`entrywt'*`x')
			scalar `est' = `poptot'[1,`j']
			scalar `result' = `delta'[`j',1]
			di in smcl in gr "`x'" _column(19) "{c |}" in ye `est' _column(35)  `selest' _column(55)  `sampest' _column(75)  `result'
			drop `sampest' `selest' 
			local j=`j'+1
		}
		di in smcl in gr "{hline 18}{c BT}{hline 80}"
	}
	else if "`method'" == "blinear" {
		local j=1
		di in smcl in gr "{hline 18}{c TT}{hline 80}"
		di in smcl in gr "Variable" _col(19) %1s "{c |}" _column(20) "Pop total" _column(35) "Weighted (entrywt)" _column(55) "Weighted (exitwt)" 
		di in smcl in gr "{hline 18}{c +}{hline 80}"		
		foreach x of local marginals {
			egen `sampest'=total(`exitwt'*`x')
			egen `selest'=total(`entrywt'*`x')
			scalar `est' = `poptot'[1,`j']
			di in smcl in gr "`x'" _column(19) "{c |}" _column(20) in ye  `est' _column(35) `selest' _column(55)  `sampest' 
			drop `sampest' `selest' 
			local j=`j'+1
		}
		di in smcl in gr "{hline 18}{c BT}{hline 80}"
	}
	else  {
		local j=1
		di in smcl in gr "{hline 18}{c TT}{hline 80}"
		di in smcl in gr "Variable" _col(19) %1s "{c |}" _column(20) "Pop total" _column(35) "Weighted (entrywt)" _column(55) "Weighted (exitwt)" _column(75) "R"
		di in smcl in gr "{hline 18}{c +}{hline 80}"		
		foreach x of local marginals {
			egen `sampest'=total(`exitwt'*`x')
			egen `selest'=total(`entrywt'*`x')
			scalar `est' = `poptot'[1,`j']
			scalar `result' = `delta'[`j',1]
			di in smcl in gr "`x'" _column(19) "{c |}" _column(20) in ye  `est' _column(35)  `selest' _column(55)  `sampest' _column(75) as result `result'
			drop `sampest' `selest' 
			local j=`j'+1
		}
		local j=`nstar'+1
		di in smcl in gr "{hline 18}{c TT}{hline 80}"
		foreach x of local sampvars {
			egen `sampest'=total(`exitwt'*`x')
			egen `selest'=total(`entrywt'*`x')
			scalar `est' = `poptot'[1,`j']
			scalar `result' = `delta'[`j',1]
			di in smcl in gr "`x'" _col(19) %1s "{c |}" _column(20) in ye  `est' _column(35)  `selest' _column(55)  `sampest' _column(75) as result `result'
			drop `sampest' `selest' 
			local j=`j'+1
		}
		di in smcl in gr "{hline 18}{c BT}{hline 80}"
	}
}







********** Graphs **********************


if "`graphs'" == "final" {
	graph twoway hist `exitwt', ysc(off)  title("Exit weights") 
}

if "`graphs'" == "all" {
	tempname scatterplot combine final gph
	graph twoway hist `exitwt',  ysc(off) title("Exit weights") name(`final') nodraw 
	graph twoway scatter `exitwt' `entrywt',  ylabel(,ang(0)) title("Exit weight v Entry weight") name(`scatterplot') nodraw
	if "`method'" == "logistic" {
		tempvar lnratio
		qui: gen double `lnratio'=`exitwt'/`entrywt'
		label var `lnratio' "ln(ratio)"
		graph twoway  hist `lnratio',  ysc(off) title("Log of the ratio: exit weight to entry weight") name(`gph') nodraw
	}
	else {
		tempvar ratio
		qui: gen double `ratio'=`exitwt'/`entrywt'
		label var `ratio' "Ratio"
		graph twoway  hist `ratio',  ysc(off) title("Ratio of exit weight to entry weight") name(`gph') nodraw
	}
	graph combine `final' `scatterplot' `gph'
}





********** Return list  **********************

qui: summ `entrywt'
scalar `entdeff'=1+r(Var)/(r(mean)^2)
return scalar entdeff=`entdeff'



if "`method'" == "nrSS" | "`method'" == "nr2A" |"`method'" == "nr2B" |"`method'" == "nr2C"  {	
	preserve
	qui: keep if `outc'==1
		qui: summ `exitwt'
		return scalar mean=r(mean)
		return scalar N=r(N)
		return scalar min=r(min)
		return scalar max=r(max)
		scalar `exitdeff'=1+r(Var)/(r(mean)^2)
		scalar `sclmax'=r(max)/r(mean)
		scalar `sclmin'=r(min)/r(mean)
		scalar `sclsd'=r(sd)/r(mean)
		return scalar exitdeff=`exitdeff'
		return scalar sclmin=`sclmin'
		return scalar sclmax=`sclmax'
		return scalar sclsd=`sclsd'
		return matrix Bhat=`delta'
	restore
}
else {
	qui: summ `exitwt'
	return scalar mean=r(mean)
	return scalar N=r(N)
	return scalar min=r(min)
	return scalar max=r(max)
	scalar `exitdeff'=1+r(Var)/(r(mean)^2)
	scalar `sclmax'=r(max)/r(mean)
	scalar `sclmin'=r(min)/r(mean)
	scalar `sclsd'=r(sd)/r(mean)
	return scalar exitdeff=`exitdeff'
	return scalar sclmin=`sclmin'
	return scalar sclmax=`sclmax'
	return scalar sclsd=`sclsd'
	if ("`method'" != "blinear" ) {
		return matrix Bhat=`delta'
	}
}

end



