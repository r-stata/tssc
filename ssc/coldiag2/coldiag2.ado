*! version 2.0, 01Dec2004, John_Hendrickx@yahoo.com

/*
Version 2.0
December 1, 2004
Can be used after a -regress- command like -vif-
If a varlist is specified, an intercept term is added by default
A "noconstant" option can be used to analyse without an intercept
Missing values are automatically deleted listwise
The default is now "full", i.e. variance decomposition proportions
are printed by default. Use nofull to suppress this.
"Singular values" are referred to now as "condition indexes"
Singular values (condition indexes)are no longer printed by default
since these values also reported with the variance decomposition
proportions
There is an option to print the eigenvalues
Saved result r(v) is the matrix of eigenvalues
Program -prnt_cx- is called by colldiag2 for printing condition indexes
and variance decomposition proportions
Options "fuzz" and "char" have been added to suppress printing of
small variance decomposition proportions.
Options "force" and "space" have been added for compact printing

Modified June 2004 by John Hendrickx <John_Hendrickx@yahoo.com>
* uses -symeigen- of X'X instead of -svd-, permits larger datasets
* with more cases than the -matsize- limit
* scaling is done in the data step rather than a matrix operation
* option to use a correlation matrix for similar results to -collin-
* options to specify print width and decimal places
* scaled condition index saved as r(sv)
* variance decomposition proportions saved as r(pi)
*/
/*
This program calculates condition number, singular values,
and pi matrix of variance decomposition portions according
to Belsey, Kuh and Welsch 1980
Adapted from program by Jeroen Weesie/ICS  STB-39 dm49
code was modelled after -cond- in Matlab 4.0
Note: this program may only work with small matrices -
ie smaller than 800 rows/columns in version 5.0
*/

cap prog drop coldiag2
program define coldiag2, rclass
	version 7.0
	syntax [varlist(default=none)] [if] [in] /*
	*/ [, noFull noScale Corr noCONstant Eigenval /*
	*/ w(integer 12) d(integer 2) Space(integer 1) FUzz(real 0) FOrce Char(string)]
	preserve
	tempname sscp v X Phi phi Pi cx Y

	if `"`varlist'"' == "" {
		capture _getrhs varlist cons
		capture if `cons' == 0 {local constant="noconstant"}
		quietly keep if e(sample)
	}
	else {
		marksample touse
		quietly keep if `touse'
	}

	* if `varlist' is still empty then something went wrong
	if `"`varlist'"' == "" {
		display as error "Use {cmd:coldiag2} after a {cmd:regress} command or specify a {it:varlist}"
		exit
	}

	if "`corr'" != "" {
		local dev "deviations"
		local scale "noscale"
		local constant "noconstant"
	}

	if "`constant'" ~= "noconstant" {
		tempvar icpt
		gen `icpt' = 1
		local varlist `"`icpt' `varlist'"'
	}

	if "`scale'" == "" {
		local i 0
		foreach var of varlist `varlist' {
			local i=`i'+1
			tempvar x`i'
			quietly gen double `x`i'' = sum(`var'^2) `if' `in'
			local ssq=`x`i''[_N]
			quietly replace `x`i'' = `var'/sqrt(`ssq')
		}
		local vlist="`x1'-`x`i''"
		local scale "scaled"
	}
	else {
		local vlist "`varlist'"
		local scale "unscaled"
	}

	quietly matrix accum `sscp'=`vlist' `if' `in', noconstant `dev'
	if "`corr'" != "" {
		matrix `sscp'=corr(`sscp')
		local scale "standardized"
	}
	matrix symeigen `X' `v' = `sscp'

	* condition number is ratio of largest to smallest singular value
	local nw = colsof(`v')
	matrix `cx'=`v'
	local rnms=""
	forval i=1/`nw' {
		capture matrix define `cx'[1,`i']=sqrt(`v'[1,1]/`v'[1,`i'])
		local rnms="`rnms' `i'"
	}

	display _newline as text "Condition number using `scale' variables = " /*
	*/ %`w'.`d'f as result `cx'[1,`nw']

	if "`full'" == "nofull" {
		exit
	}

	matrix `cx'=`cx''
	matrix rownames `cx'=`rnms'
	matrix colnames `cx'=" "
	matrix rownames `v'=" "
	matrix colnames `v'=`rnms'

	if "`eigenval'" == "eigenval" {
		if "`corr'" == "corr" {
			display _newline as text "Eigenvalues of the correlation matrix"
		}
		else {
			display _newline as text "Eigenvalues of the `scale' SSCP matrix"
		}
		tempname v2
		matrix `v2'=`v''
		matrix list `v2', noheader noblank format(%12.4f)
	}

	capture matrix `Phi'=`X'
	matrix `phi'=J(1,`nw',0)
	forvalues i=1/`nw' {
		forvalues j=1/`nw' {
			matrix `Phi'[`i',`j']= `Phi'[`i',`j']^2/`v'[1,`j']
			matrix `phi'[1,`i']= `phi'[1,`i']+ `Phi'[`i',`j']
		}
	}

	matrix `Pi'=J(`nw',`nw',0)
	forvalues i=1/`nw' {
		forvalues j=1/`nw' {
			matrix `Pi'[`j',`i']= `Phi'[`i',`j']/`phi'[1,`i']
		}
	}
	local vnames "`varlist'"
	if "`constant'" ~= "noconstant" {
		local vnames : subinstr local vnames "`icpt'" "_cons"
	}

	matrix colnames `Pi'=`vnames'
	matrix colnames `cx'=CX
	matrix `Y'=`cx',`Pi'

	prnt_cx, matname(`Y') w(`w') d(`d') space(`space') fuzz(`fuzz') char(`"`char'"') `force'

	return matrix pi `Pi'
	return matrix cx `cx'
	return matrix v `v'
	restore
end

