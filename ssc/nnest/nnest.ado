*! nnest.ado version 3.0 Gregorio Impavido (gimpavido@imf.org) 08Nov2011 
*! nnest.ado version 2.0 Gregorio Impavido (gimpavido@worldbank.org) 15Aug2001
*! nnest.ado version 1.0 Gregorio Impavido (gimpavido@worldbank.org) 29June1998
* Now for version 9
*
prog drop _all
* Description : This program performs the Davidson and MacKinnon (1981) J test
* 				and the [[xxxx]] after an ols regression
program define nnest, rclass
version 9
syntax 	varlist(min=1 numeric ts)
// check that regress has been inputted
if "`e(cmd)'" != "regress" {
	display in red ///
	"You can only run nnest after an OLS regression"
	error 301
}
// check that the depvar exists
capture confirm variable `e(depvar)'
if _rc {
	display in red ///
	"Rerun original regression before nnest"
	confirm variable `e(depvar)'
}
*********************************
* The ingredients for the tests *
*********************************
local depvar "`e(depvar)'"
// identify the right sample
tempvar es1
gen byte `es1' = e(sample)		
// find the common obs with the regressors in model 2
markout `es1' `varlist' 
		
// ingredients from model 1
// estract wights from command line in model 1 (if any)
local m1 "`e(cmdline)'"  // this saves model 1
gettoken left right : m1, parse("[") 
// di "`left'"
// di "`right'"
gettoken wgts right : right, parse("]")  // this saves 1st part of the weights
// di "`wgts'"
// di "`right'"
gettoken brkt right : right, parse("]")  // this saves the weights
// di "`brkt'"
local wgts `wgts'`brkt' 
gettoken left optsm1 : m1, parse(",") 
// gen the list of regressors from m1 (with no const and not omitted)
matrix B = e(b)
// put in `1' the column names of e(b)
tokenize "`: colnames e(b)'"
local xm1 
forval j = 1/`= colsof(B)' {
	if B[1, `j'] != 0 & "``j''" != "_cons" {
		local xm1 `xm1' ``j''
		// di "`xm1'"
	}
}
quietly {
// reestimate model 1 taking any unavailable obs into account
regress `depvar' `xm1' if `es1' `wgts' `optsm1'
tempvar yhatm1
// fitted values for model 1
predict double `yhatm1' if `es1', xb
// rss/N from model 1 (Cox is an asymptitic test, so don't divide by n-k)
local s2m1 = e(rss)/e(N)

// ingredients from model 2
local xm2 "`varlist'"
regress `depvar' `xm2' if `es1' `wgts' `optsm1' // this is model 2
tempvar yhatm2 
predict double `yhatm2' if `es1' , xb // fitted values for model 2
// rss/N from model 2 (Cox is an asymptitic test, so don't divide by n-k) 
local s2m2 = e(rss)/e(N)
	
****************************************		
* Davidson and MacKinnon (1981) J test *
****************************************
// aux regression from model 2
regress `depvar' `xm2' `yhatm1' if `es1' `wgts' `optsm1'
local obsm2 = e(N)
// t coeff in the aux regression
local tcm2  = _b[`yhatm1']/_se[`yhatm1']  
// d.f. from aux regression of model 2
local dfm2 = e(df_r)
// p value from aux regression of model 2
local tsigm2 = tprob(`dfm2', `tcm2')

// aux regression for model 1
regress `depvar' `xm1' `yhatm2' if `es1' `wgts' `optsm1'
local obsm1 = e(N)
// t coeff in the aux regression
local tcm1  = _b[`yhatm2']/_se[`yhatm2']
// d.f. from aux regression for model 1
local dfm1 = e(df_r)
// p value from aux regression of model 1
local tsigm1 = tprob(`dfm1', `tcm1')
	
******************	
* Cox Statistics *
******************
// aux regression from model 1
regress `yhatm1' `xm2' if `es1'  // `wgts' `optsm1'
local s2m2m1 = `s2m1' + e(rss)/e(N)
tempvar uhatm2aux
predict double `uhatm2aux' if `es1', resid
regress `uhatm2aux' `xm1' if `es1'  // `wgts' `optsm1'
local c12 = (e(N)/2)*ln(`s2m2'/`s2m2m1')
local vc12 = `s2m1'*e(rss)/(`s2m2m1'^2)
local qm1 = `c12'/sqrt(`vc12')
local qsigm1 = 1 - normal(abs(`qm1'))

regress `yhatm2' `xm1' if `es1'  // `wgts' `optsm1'
local s2m1m2 = `s2m2' + e(rss)/e(N)
tempvar uhatm1aux
predict double `uhatm1aux' if `es1', resid
regress `uhatm1aux' `xm2' if `es1'  // `wgts' `optsm1'
local c21 = (e(N)/2)*ln(`s2m1'/`s2m1m2')
local vc21 = `s2m2'*e(rss)/(`s2m1m2'^2)
local qm2 = `c21'/sqrt(`vc21')
local qsigm2 = 1 - normal(abs(`qm2'))
}	
// to force to rerun M1 before you can change M2 in nnest
ereturn clear
	
****************	
* show results *
****************
di _n _skip(2) %~50s "Competing Models"   
di    _skip(2) _dup(50) "-"	
di    _skip(2) "M1 : Y = [`depvar']"
di    _skip(2) "     X = [`xm1']"
di    _skip(2) "M2 : Y = [`depvar']"
di    _skip(2) "     Z = [`xm2']"
di    _skip(2) _dup(50) "-"	

di    _skip(2) %~50s "J test for non-nested models" 
di    _skip(2) _dup(50) "-"	
di    _skip(2) _col(21) "Dist" _col(34) "Stat" ///
		_col(44) "P>|Stat|"
di    _skip(2) "H0:M1 / H1:M2" _col(20) "t(`dfm1')" ///
      _col(30) %8.2f `tcm1' _col(45) %4.3f `tsigm1'
di	  _skip(2) "H0:M2 / H1:M1" _col(20) "t(`dfm2')" ///
	  _col(30) %8.2f `tcm2' _col(45) %4.3f `tsigm2'
di    _skip(2) _dup(50) "-"	

di     _skip(2) %~50s "Cox-Pesaran test for non-nested models" 
di    _skip(2) _dup(50) "-"	
di    _skip(2) _col(21) "Dist" _col(34) "Stat" ///
		_col(44) "P>|Stat|"
di    _skip(2) "H0:M1 / H1:M2" _col(20) "N(0,1)" ///
      _col(30) %8.2f `qm1' _col(45) %4.3f `qsigm1'
di	  _skip(2) "H0:M2 / H1:M1" _col(20) "N(0,1)" ///
	  _col(30) %8.2f `qm2' _col(45) %4.3f `qsigm2'
di    _skip(2) _dup(50) "-"	


**************************************
* return information for further use *
**************************************
// scalars in J test and Cox stat
ret scalar nobsm1 = `obsm1'
ret scalar nobsm2 = `obsm2'
// scalars in J test
ret scalar tcm1 = `tcm1'
ret scalar tcm2 = `tcm2'
ret scalar tsigm1 = `tsigm1'
ret scalar tsigm2 = `tsigm2'
// scalars in Cox stat
ret scalar qm1 = `qm1'
ret scalar qm2 = `qm2'
ret scalar qsigm1 = `qsigm1'
ret scalar qsigm2 = `qsigm2'
// locals for J and Cox
ret local optsm1 `optsm1'
ret local wgts `wgts'
ret local regm2 `xm2'
ret local regm1 `xm1'
ret local depvar `depvar'
ret local cmd nnest 

end
