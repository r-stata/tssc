  ** mvport package v2
  * cbacktest command 
  * Author: Alberto Dorantes, July, 2016
  * cdorante@itesm.mx

capture program drop cbacktest

program define cbacktest, rclass
version 11.0
syntax varlist(numeric) [if] [in], Weights(string) Generate(string) Timevar(string) [NOGraph]
marksample touse
tempvar bhr
tempname nr W numvariables
local numvariables: word count `varlist'

capture matrix `W' = `weights'
if (_rc!=0) {
	    display as error "The weight Matrix `weights' does not exist; define a Stata Matrix for the portfolio weights"
	    exit
}
else if (rowsof(`weights')!=`numvariables' | colsof(`weights')!=1) {
	    display as error "The weight Matrix must have 1 column and the number of rows has to be equal to the number of assets of the portfolio"
		exit
}
    capture tsset `timevar'
	if _rc!=0 { 
	  display as error "The time-series variable `timevar' might not exist or is not numeric. The dataset was not sorted"
	}  
  capture gen `bhr'=.
  local nr=_N
forvalues i=1/`nr' {
  qui backtest `varlist' if (_n<=`i' & `touse'), weights(`weights')
  qui replace `bhr'=r(retport) if _n==`i' & `touse'  
}
  capture drop `generate'
  capture gen double `generate'=`bhr'
  display "The portfolio weights used were: " 
  matlist `weights', noblank twidth(30) border
  
  display "The variable `generate' was generated, and it has the cumulative holding return of the portfolio"
  if "`nograph'"==""  {
      tsline `generate' `if' `in'
  }
end
