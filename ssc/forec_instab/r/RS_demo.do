// This file demonstrates the capabilities of the rosssekh Stata command, which is based on the
// Rossi-Sekhposyan (2016, Journal of Applied Econometrics) forecast rationality test

set more off

* change path according to the location of the file test_data1_new.csv
insheet using rosssekh_test_data.csv, clear
generate year = int(pdate)
generate quarter = (pdate - int(pdate))*4 + 1 
generate tq = yq(year, quarter)
format tq %tq
tsset tq

* window size is 60 observations long, significance level is 0.05, lag length set to 3
* Test applied to Greenbook forecasts
rosssekh realiz forc, window(60) alpha(0.05) nw(3)
dis "The value of the test statistic is " r(tstat_sup)
dis "The critical value is " r(cv) " at significance level " r(level)
graph save RS_demo_1, asis replace


* automatic lag length selection, integer part of window^0.25
rosssekh realiz forc, window(60) alpha(0.05) nw(0)
dis "The value of the test statistic is " r(tstat_sup)
dis "The critical value is " r(cv) " at significance level " r(level)
graph save RS_demo_2, asis replace

