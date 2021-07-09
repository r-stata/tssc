*!regcoef version 1.0
*!Written 10Dec2014
*!Written by Mehmet Mehmetoglu
capture program drop regcoef
program regcoef
version 13.1	
local ecmd "e(cmd)"
if `ecmd' != "regress" {
	di in red "works only with -regress-"
	exit
	}	
tempname edfm
scalar `edfm' = e(df_m) 
if `edfm'==1 {
    di in red "works only with multiple regression"
	exit
	}	

tokenize `e(cmdline)'
	local command `1'        
	macro shift
	local depvar `2'       
	macro shift
	local rest `*'  
	local firstreg qui reg `e(depvar)' `rest'
	

quietly matrix b = e(b)
//quietly matrix list b

qui sum `e(depvar)' if e(sample)
tempname sddep 
scalar `sddep' = r(sd)
//di `sddep'

local i=0

local listt `rest' 

capture confirm numeric variable `rest'
if _rc {
di in red "factor variables are not allowed"
exit
}
else {

di in green "{dup 37: }{bf: Coefficients for regression models}"
di as smcl as txt  "   {c TLC}{hline 100}{c TRC}"	
di in yellow "       {bf:Predictor}{dup 4: }{c |}{bf: Unstandardised}{dup 2: }{c |} {bf:Standardised}{dup 3: }{c |} {bf:Semipartial}{dup 3: }{c |} {bf: Level}{dup 8: } {c |} {bf: Structure}{dup 4: }"
di in yellow "{dup 20: }{c |}{bf: coefficients}{dup 4: }{c |}{bf: coefficients}{dup 3: }{c |} {bf:corr squared}{dup 2: }{c |}  {bf:coefficients}{dup 2: }{c |}{bf:  coefficients}"
di in yellow "{dup 20: }{c |}{it:       (b)}{dup 7: }{c |}{it:     (beta)}{dup 5: }{c |} {it:   (sr2)}{dup 6: }{c |}  {it:   (lc)}{dup 7: }{c |}{it:     (sc)}"
di as smcl as txt  "   {c BLC}{hline 100}{c BRC}"	

foreach valz of local listt {
    
	tempname coef
	scalar `coef' = b[1, `++i']
	//di `coef'
	
	sum `valz' if e(sample),meanonly
	tempname meann
	scalar `meann' = r(mean) 
	//di `meann'
	
	qui xi: corr `valz' `e(depvar)' if e(sample)
	tempname core
	scalar `core' = r(rho)
	tempname dcoef
	scalar `dcoef' = sqrt(`e(r2)')
	tempname struc
	scalar `struc' = `core'/`dcoef'
	//di `struc'
	
	tempname levelcoef
	scalar `levelcoef' = `coef'*`meann'
	
	qui sum `valz' if e(sample)
	tempname sddev
	scalar `sddev' = r(sd)
	//di `sddev'
	
	tempname beta
	scalar `beta'=`coef'*(`sddev'/`sddep')
	//di `beta'
	
   local remaining : subinstr local listt  "`valz'" ""
   qui reg `valz' `remaining' if e(sample)
   capture drop r`valz'
   qui predict r`valz', residuals
   `firstreg'
   qui xi: corr r`valz' `e(depvar)' if e(sample)
   tempname semip
   scalar `semip' = `r(rho)'*`r(rho)'
   //di `semip'
   
   di as txt "    " %12s abbrev("`valz'",12) "{dup 4: }{c |}" "  "%9.2f `coef' "{dup 6: }{c |}"" " %9.2f `beta' "{dup 6: }{c |}" "" %9.2f `semip' "{dup 6: }{c |}""  " %9.2f `levelcoef' "{dup 5: }{c |}" %9.2f `struc' "{dup 5: }" 
   drop r`valz'
}
   di as smcl as txt  "   {c BLC}{hline 100}{c BRC}"
   }
end


