****************************************************
* export and format covariate balance table to Excel
****************************************************

local rows = `r(varcnt)' + 3 // this gets the count of covariates and adds 3 rows to account for the header


* Exporting table to Excel in workbook named "covbal" into a sheet named "table"
putexcel set covbal.xlsx, sheet("table", replace) modify
 
putexcel A3 = "Variable"
putexcel B3 = "Mean"
putexcel C3 = "Variance"
putexcel D3 = "Skewness"
putexcel E3 = "Mean"
putexcel F3 = "Variance"
putexcel G3 = "Skewness"
putexcel H3 = "Standardized diff"
putexcel I3 = "Variance ratio"
putexcel C2 = "Treated"
putexcel F2 = "Control"
putexcel H2 = "Balance"

putexcel (A2:I2), border(top)
putexcel (A3:I3), border(bottom)
putexcel (A2:A`rows'), border(right)
putexcel (D2:D`rows'), border(right)
putexcel (G2:G`rows'), border(right)
putexcel (A`rows':I`rows'), border(bottom)
putexcel (H2:I2), merge hcenter

matrix table = r(table)
putexcel A4 = matrix(table), rownames nformat(number_d3)
