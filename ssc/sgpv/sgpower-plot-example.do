*!sgpower_plot_example.do
*!Contains the code to reproduce plotting the power curve
*!Based on the same example for the R-code.
preserve
clear
range theta -10 10 `=(10--10)/0.1' // generate a variable with values from -10 to 10 in 0.1 steps
local se = 5/sqrt(20)
gen power = .
forvalues i=1/`=_N'{
qui sgpower, true(`=theta[`i']') nulllo(-1) nullhi(1) inttype(confidence) intlevel(0.05) stderr(`se')
qui replace power = `r(poweralt)' in `i'
}
twoway line power theta, ytitle("Power")
restore
