// This file demonstrates the capabilities of the rosssekh Stata command, which is based on the
// Giacomini-Rossi (2010, Journal of Applied Econometrics) forecast fluctuation test

set more off

* change path according to the location of the file test_data1_new.csv
insheet using giacross_test_data.csv, clear
generate year = int(pdate)
generate quarter = (pdate - int(pdate))*4 + 1 
generate tq = yq(year, quarter)
format tq %tq
tsset tq


* lag length set to 3, default 2-sided test
giacross realiz forc spf, window(60) alpha(0.05) nw(3)
dis "The value of the test statistic is " r(tstat_sup)
dis "The critical value is " r(cv) " at significance level " r(level)
graph save GR_demo_1, asis replace


* automatic lag length selection based on Schwert criterion, one-sided test
giacross realiz forc spf, window(60) alpha(0.05) side(1)
dis "The value of the test statistic is " r(tstat_sup)
dis "The critical value is " r(cv) " at significance level " r(level)
graph save GR_demo_2, asis replace

