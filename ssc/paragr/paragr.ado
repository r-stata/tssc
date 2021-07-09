*! paragr 1.0.1 04Aug2009 by roywada@hotmail.com
*! parallel graphing of a coefficient across different equations

prog define paragr
version 8.0
syntax varlist(min=1 max=1) [, qfit QFIT2(str asis) SCATter(str asis) /*
	*/ gen(string) *]
local varname `varlist'

qui {

tempname b vc
tempname coefMat seMat
tempvar equation coefficient se se_high1 se_high2 se_low1 se_low2 

mat `b'=e(b)
mat `vc'=e(V)
mat `vc' = vecdiag(`vc')

local eqlist : coleq `b'
local eqlist: list clean local(eqlist)
local eqlist: list uniq local(eqlist)
local eqnum: word count `eqlist'

gen `equation'=_n
foreach var in coefficient se se_high1 se_low1 {
	gen ``var''=.
}

forval num=1/`eqnum' {
	local eqname: word `num' of `eqlist'
	
	* coef
	cap mat `coefMat'=`b'[1,"`eqname':`varname'"]
	if _rc==0 {
		local temp=`coefMat'[1,1]
		replace `coefficient'=`temp' in `num'
	}
	
	* se
	cap mat `seMat'=`vc'[1,"`eqname':`varname'"]
	if _rc==0 {
		local temp=`seMat'[1,1]
		replace `se'=`temp'^.5 in `num'
	}
	
	* quantile stuff
	if "`e(cmd)'"=="qreg" | "`e(cmd)'"=="iqreg" | "`e(cmd)'"=="sqreg" | "`e(cmd)'"=="bsqreg" {
		local quantileName`num'=subinstr("`eqname'","q",".",.)
		replace `equation'=`quantileName`num'' in `num'
	}
}

tempvar coefVal ci_lowVal coefEformVal seEformVal T_alpha seVal
tempvar ci_lowEformVal ci_highVal ci_highEformVal

tempvar df_r
local level 95

gen `coefVal'=`coefficient'
gen `seVal'=`se'
scalar `df_r'=.

* `T_alpha' for the Ci
if `df_r'==. {
	gen double `T_alpha' = invnorm( 1-(1-`level' /100)/2 )
}
else {
	* replacement for invt( ) function under version 6
	* note the absolute sign: invttail is flipped from invnorm
	gen double `T_alpha' = abs(invttail(`df_r', (1-`level' /100)/2))
}

* ci
gen double `ci_lowVal'=`coefVal'-`T_alpha'*`seVal'
gen double `ci_highVal'=`coefVal'+`T_alpha'*`seVal'
	
	* exponentiate beta and st_err
	gen double `coefEformVal' = exp(`coefVal')
	gen double `seEformVal' = `coefEformVal' * `seVal'
	gen double `ci_lowEformVal' = exp(`coefVal' - `seEformVal' * `T_alpha' / `coefEformVal')
	gen double `ci_highEformVal' = exp(`coefVal' + `seEformVal' * `T_alpha' / `coefEformVal')

* labels
label var `equation' "Equations"
if "`e(cmd)'"=="qreg" | "`e(cmd)'"=="iqreg" | "`e(cmd)'"=="sqreg" | "`e(cmd)'"=="bsqreg" {
	label var `equation' "Quantiles"
	tokenize "`eqlist'"
	forval i = 1/`eqnum' {
		local call `call' `quantileName`i'' "`quantileName`i''"
	}
}
else {
	* per Nick C. the x-axis labels
	tokenize "`eqlist'"
	forval i = 1/`eqnum' {
		local call `call' `i' "``i''" 
	}
}

local content: var label `varname'
label var `coefficient' "`content'"

if "`qfit'"=="" & "`qfit2'"=="" {
	twoway (scatter `coefficient' `equation' in 1/`eqnum', `scatter'), `options' xla(`call')
}
else {
	twoway (scatter `coefficient' `equation' in 1/`eqnum', `scatter') /*
	*/ (qfit `coefficient' `equation' in 1/`eqnum', `qfit2'), `options' xla(`call')
}


/*	* confidence intervals
	noi twoway (scatter `coefVal' `equation' in 1/`eqnum', `scatter') /*
	*/ (qfit `coefVal' `equation' in 1/`eqnum', `qfit2') /*
	*/ (qfit `ci_lowVal' `equation' in 1/`eqnum', `scatter') /*
	*/ (qfit `ci_highVal' `equation' in 1/`eqnum', `scatter') /*
	*/ , `options' xla(`call')
*/


* generate variables
if "`gen'"~="" {
	local N=_N
	replace `equation'=. in `=`eqnum'+1'/`N'
	gen `gen'eq=`equation'
	gen `gen'coef=`coefficient'
}

} /* quiet */
end
exit

* versions
1.0.1 04Aug2009 incorporates stuffs from Nick C

