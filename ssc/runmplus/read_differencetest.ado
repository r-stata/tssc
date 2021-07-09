* Read in Mplus output file and display Difference Test results

version 10.0

capture program drop read_differencetest
program define read_differencetest , rclass


syntax , out(string) 

preserve

set more off

qui infix str line 1-85 ///
      str name 11-29 ///
      str value 43-50 ///
      using `out' , clear
format line %85s



* IDENTIFY START AND END OF Difference Testing
qui gen linenum=_n
qui gen x1=_n if (ltrim(line)=="Chi-Square Test for Difference Testing")
qui summarize x1
if r(min)>0 & r(N)>0 {
   qui drop if linenum<=(r(min)+1)
   qui drop if linenum>=(r(min)+5)
}
else {
   di in red "Chi-Square Test for Difference Testing not found"
   exit
}
qui drop x1

local chi2 = value[1]
local df = value[2]
di "  "
di in green " Chi-Square Test for Difference Testing "
di " The Chi-Square value is `chi2' with `df' d.f. "
di "  "
return local chi2 = `chi2'
return local df = `df'


end
