/*************************************************
example_testjfe.do illustrates the usage of the Stata command defined in
testjfe.ado. This do-file assumes that the example data file fake_data_for_testjfe.dta
is saved in the current working directory
**************************************************/

use fake_data_for_testjfe,clear

testjfe y d _Ijudge*,covariates(x1-x3) generate(eyj pj fit) graph