TITLE
 'rolling3': module to compute predicted values for rolling regressions

DESCRIPTION/AUTHOR(S)
Rolling3 generates predicted values for each rolling regression and saved them as new variables in original data file. It also allows user looping rolling predict command on data panels.

KW: Rolling regression
KW: Rolling forecast
KW: Predicted values
KW: Fitted values

Requires: Stata version 13
Distribution-Date: 20160328
      
Author: 
Muhammad Rashid Ansari, INSEAD Business School
Support: email rashid.ansari@insead.edu

*Version March 2016
--------------------
basic syntax:
rolling3, window(#) step(#) predict p(varname) saving (filename.dta, replace): rolling command

Description:
Rolling3 is modified version of stata default rolling command and supports all options available with stata default rolling command. It additionally computes predicted values for each rolling regression and save them as new variable in original data file. 
 
Note: The module reduces to default rolling command if user doesn’t export rolling regression output and use `clear’ option with rolling command.

Options:
predict: Stata default predict command for generating fitted values
p(varname): Variable stub for saving predicted values

Other rolling regression options as described in stata rolling regression help file

Examples:
----------
rolling3, window(36) step(1) predict p(fitted) saving (out.dta,replace): arima rate, arima(1,0,0)
rolling3, window(36) step(1) recursive predict p(fitted) saving (out.dta,replace): arima rate, arima(1,0,0)

*36 months rolling forecast (USD against EUR, CHF, GBP, JPY & SGD)
clear
use "forex.dta", clear

forvalues i=1(1)5{
rolling3 _b _se , window(36) step(1) predict p(yhat) saving (out.dta,replace): arima rate, arima(1,0,0), if id==`i'
}

*combine rolling regression output
preserve
clear
forvalues i=1(1)5{
qui append using "panel`i'.dta"
}
save "rolling_output.dta",replace
pwd
restore

Author:
Muhammad Rashid Ansari						
INSEAD Business School						
1 Ayer Rajah Avenue, Singapore 138676						
rashid.ansari@insead.edu
