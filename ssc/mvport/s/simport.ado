  ** mvport package v2
  * simport command 
  * Author: Alberto Dorantes, July, 2016
  * cdorante@itesm.mx
  
capture program drop simport
program simport, rclass
  version 11.0
  syntax varlist(min=2 numeric) [if] [in], nport(real) [CASEwise]
  marksample touse
    qui count if `touse'	
    local nnmissing1=r(N)
	if "`casewise'"=="" {
	  marksample touse, novarlist
	}
  local nvar : word count `varlist'

  if `nport'<3 { 
	  display("nport must be greater than 2")
	  exit 
	}  
    mata: matriz=m_simport("`varlist'", `nport', "`touse'", "`casewise'")

preserve
clear
quietly set obs `r(numobs)'
quietly local numvars=r(numvars)
forvalues i=1/`numvars' {
  quietly gen w`i'=.
}
quietly gen R=.
quietly gen SD=.
mata: st_store(., ., matriz)
display "Random portfolios were generated with no negative weights."
display "Descriptive statistics of the set of portfolio returns are below: "
su R 
quietly gsort SD
display "Random portfolio with the minimum variance had a return of : " R[1] " and a standard deviation of " SD[1]
display "Weights of this random portfolio:"
list w* in 1/1, noobs 
label variable R "All possible Returns"
label variable SD "Portolio Risk"
twoway (scatter R SD, sort) 
restore
end
