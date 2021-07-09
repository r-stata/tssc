!* Fractional response for endogenous count variable model
!* Version 1.0.5 - Minh Nguyen & Hoa Nguyen - June 2010
!* mnguyen3@worldbank.org / nguye147@msu.edu
// History:
// 2 Jan 09: add improved gradient approximation
// 5 Jun 09: add non-collinearity
//           simulated maximum likelihood (testing only)

cap program drop frcount
program define frcount, eclass byable(recall) sortpreserve
		 if replay() {
		 		 syntax [anything]		 		 
		 		 ereturn display
		 } 
		 else {
		 		 version 10, missing
		 		 local version : di "version " string(_caller()) ", missing:"		 
		 		 syntax varlist [if] [in] [aw pw fw], endog(varlist max=1) iv(varlist) quad(integer) [QMLE NLS noCONStant APEVCE(passthru)]
		 		 local cmdline: copy local 0
		 		 if ("`qmle'"!="") + ("`nls'"!="") >1 { 
						di in red "choose only one method: qmle or nls"
						exit 198 
		         }		      
		 		 if "`:list iv & endog'"!="" {
		 		 		 di as err "Variables `:list iv & endog' cannot be both exogenous and endogenous"
		 		 		 error 198
		 		 }
		 		 if "`:list varlist & iv'"!="" {
		 		 		 di as err "Variables `:list varlist & iv' cannot be both exogenous in iv and varlist"
		 		 		 error 198
		 		 }
				 local nocns "`constant'"
		 		 marksample touse				 
				 local flist `"`varlist' `endog' `iv'"'
				 markout `touse' `flist' 
		 		 gettoken lhs varlist: varlist
		 		 _rmcoll `varlist' if `touse'
		 		 local okvarlist `r(varlist)'
		 		 local zvar  `"`okvarlist' `iv'"'
		 		 local temp1 `"`endog' `okvarlist'"'
		 		 local temp2 `"`lhs' `endog' `okvarlist' `iv'"'
		 		 tempvar x w
		 		 tempname nodes wt
		 		 ghquad double(`x' `w'), n(`quad')
		 		 // Stata command: _GetQuad, avar(a) wvar(w) quad(5)
		 		 local j = `quad'
		 		 mkmat `x', mat(`nodes') nomissing
		 		 mat `nodes' = `nodes'[1..`j',1]
		 		 mkmat `w', mat(`wt') nomissing
		 		 mat `wt' = `wt'[1..`j',1]
		 		 local k =`:word count `temp1''+1		 		 		 		 		 		 
		 		 tempname b b1 b2 b2a b3 b4 b5 bFRM V V1 scale vh
				 local names `temp1'
				 local apenames `"`endog' "`endog'_01" "`endog'_12" "`endog'_23" `okvarlist'"'
		 		 mat `b2' = J(1,`k',0)
		 		 mat `V'  = J(`k',`k',1)
		 		 if ("`nocns'"=="") {
					local names `names' _cons
					local apenames `apenames' _cons
					mat `V'  = J(`k'+1,`k'+1,1)
				 }
				 local names `names' eta1
				 
		 		 // getting intital parameters
		 		 qui reg `endog' `zvar' if `touse', `nocns'
		 		 mat `b1' = e(b)
		 		 qui ivregress gmm `lhs' `okvarlist' (`endog' = `iv'), `nocns'
		 		 mat `b2' = e(b), 0.5				 
		 		 // getting initial values for frcount ml
		 		 di in green "Getting Initial Values:"
		 		 mata: _neg_unobs("`endog'", "`zvar'", "`touse'", "`b1'")
		 		 
		 		 if (`"`qmle'"'!=`""' | `"`qmle'"'==`""' & `"`nls'"'==`""') { 
		 		 		 di ""
		 		 		 di in gr "Fitting Quasi-MLE Model:"
		 		 		 mata: _frcount("`lhs'", "`endog'", "`okvarlist'", "`iv'", "`touse'", "`b2'","`V'","`nocns'")
						 ereturn local method "qmle"
		 		 }
		 		 else if `"`nls'"'!=`""' {
						 di ""
		 		 		 di in gr "Fitting Full NLS Model:"
		 		 		 mata: _frnls("`lhs'", "`endog'", "`okvarlist'", "`iv'", "`touse'", "`b2'","`V'", "`nocns'")
						 ereturn local method "nls"
		 		 }

		 		 qui count if `touse'
		 		 local N = r(N)
		 		 di ""
				 
		 		 mat rownames `V' = `names'
		 		 mat colnames `V' = `names'
		 		 mat rownames `b2' = `lhs'
		 		 mat colnames `b2' = `names'
				 
				 ereturn scalar errcode = __errcode[1,1]				 
				 if e(errcode) ==0 {
					ereturn post `b2' `V', esample(`touse') depname(`lhs')
					ereturn scalar N = `N'
					ereturn scalar n_quad = `quad'
					ereturn local depvar "`lhs'"	
					ereturn local iv "`iv'"
					ereturn local exog "`okvarlist'"
					ereturn local endog "`endog'"		
					ereturn local version "1.0.5"
					ereturn local cmd "frcount"
					ereturn local cmdline `"`cmdline'"'		 
					ereturn local vcetype "Robust"	
					ereturn local properties "b V"
					ereturn scalar llog = __llog[1,1]
					ereturn scalar converge = __converge[1,1]
					ereturn scalar errcode = __errcode[1,1]
					ereturn display		 		 
		 		 
					if `"`apevce'"' != "" {
						// get options for APEVCE as robust or bootstrap		 		 		 
						local options "`apevce'"
						gettoken left options: options, parse("(")
						gettoken left options: options, parse("(")
						gettoken methods options: options, parse(")")
						if "`methods'" == "robust" {
		 		 		 		//di "robust method"
		 		 		 		mata: apefrm = _APEendo(st_matrix("e(b)"))
		 		 		 		mata: varape = _APEVCE(st_matrix("e(b)"))
								di "" 
								di in gr "Average Partial Effects of Fractional Reponse Model: robust method" 
								di ""
								mat rownames _VAPE_en = `apenames'
								mat colnames _VAPE_en = `apenames'
								mat rownames  _APE_en_all = `lhs'
								mat colnames  _APE_en_all = `apenames'
								ereturn post _APE_en_all _VAPE_en, depname(`lhs')
								ereturn local vcetype "Robust"	
								ereturn display 		 
						 }
						 else if "`methods'" ~= "robust" {						 
						 if "`methods'" == "bootstrap" {
						 		local bsopt reps(50) seed(123455) nowarn
						 }
						 else if "`methods'" ~= "bootstrap" {
								local t1 = strpos("`apevce'", "bootstrap")
								local t1 = `t1'+9
								local t2 = length("`apevce'")
								local bsopt = substr("`apevce'", `t1' ,`t2'-17)
						 }
		 		 		 		//di "bootstrap method"
								di "" 
								di in gr "Average Partial Effects of Fractional Reponse Model: bootstraping method" 
								local bscmd = e(cmdline)
								local sape = strpos("`bscmd'", "apevce")
								global bsrun = substr("`bscmd'",1,`sape'-1)		
								global bscons `nocns'
								bootstrap _b, `bsopt' ti(Average Partial Effects): frcount_bs
		 		 		 }
					}	
				 }	 		 		 		 
		 }     // end of else replay()
end

/*
		 Routines that compute weights and points for Gaussian-Hermite
		 quadrature follow: ghquad double(`x' `w'), n(`quadrat')
		 Copy from rftobit.ado
*/

* version 1.0.1  29jun1995
capture program drop ghquad 
program define ghquad
		 version 4.0
		 local varlist "req new min(2) max(2)"
		 local options "N(integer 10)"
		 parse "`*'"
		 parse "`varlist'", parse(" ")
		 local x "`1'"
		 local w "`2'"
		 if `n' + 2 > _N  {
		 		 di in red  /*
		 		 */ "`n' + 2 observations needed to compute quadrature points"
		 		 exit 2001
		 }
		 tempname xx ww
		 local i 1
		 local m = int((`n' + 1)/2)
		 while `i' <= `m' {
		 		 if `i' == 1 {
		 		 		 scalar `xx' = sqrt(2*`n'+1)-1.85575*(2*`n'+1)^(-1/6)
		 		 }
		 		 else if `i' == 2 { scalar `xx' = `xx'-1.14*`n'^0.426/`xx' }
		 		 else if `i' == 3 { scalar `xx' = 1.86*`xx'-0.86*`x'[1] }
		 		 else if `i' == 4 { scalar `xx' = 1.91*`xx'-0.91*`x'[2] }
		 		 else { scalar `xx' = 2*`xx'-`x'[`i'-2] }
		 		 hermite `n' `xx' `ww'
		 		 qui replace `x' = `xx' in `i'
		 		 qui replace `w' = `ww' in `i'
		 		 local i = `i' + 1
		 }
		 if mod(`n', 2) == 1 { qui replace `x' = 0 in `m' }
		 qui replace `x' = -`x'[`n'+1-_n] in `i'/`n'
		 qui replace `w' =  `w'[`n'+1-_n] in `i'/`n'
end

capture program drop hermite  
program define hermite  /* integer n, scalar x, scalar w */
		 version 4.0
		 local n "`1'"
		 local x "`2'"
		 local w "`3'"
		 local last = `n' + 2
		 tempvar p
		 tempname i
		 qui gen double `p' = . 
		 scalar `i' = 1
		 while `i' <= 10 {
		 		 qui replace `p' = 0 in 1
		 		 qui replace `p' = _pi^(-0.25) in 2
		 		 qui replace `p' = `x'*sqrt(2/(_n-2))*`p'[_n-1] /*
		 		 */		 - sqrt((_n-3)/(_n-2))*`p'[_n-2] in 3/`last'
		 		 scalar `w' = sqrt(2*`n')*`p'[`last'-1]
		 		 scalar `x' = `x' - `p'[`last']/`w'
		 		 if abs(`p'[`last']/`w') < 3e-14 {
		 		 		 scalar `w' = 2/(`w'*`w')
		 		 		 exit
		 		 }
		 		 scalar `i' = `i' + 1
		 }
		 di in red "hermite did not converge"
		 exit 499
end
