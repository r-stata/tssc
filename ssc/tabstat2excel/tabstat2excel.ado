program define tabstat2excel
version 14.2

*Set program parameters

syntax varlist(numeric) [if] [in], filename(string)

tempvar touse 
mark `touse' `if' `in'

* Generate Matrix
tabstat `varlist' if `touse', save statistics(n mean median min max)

matrix define x	 = r(StatTotal)'

* Set the Excel file
putexcel clear
putexcel set "`filename'", sheet("Summary Statistics") modify 

* Matrix
putexcel (A1) =matrix(x), 	names nformat(number_d2) 

* Headers
putexcel B1=("Observations") C1=("Mean") D1=("Median") E1=("Min") F1=("Max"), vcenter hcenter bold border(bottom)

* Var labels
local i = 2
foreach var of varlist `varlist' {
  local varlabel : variable label `var'
  putexcel A`i'= ("`varlabel'")
  local i = `i' + 1 
  }

end


