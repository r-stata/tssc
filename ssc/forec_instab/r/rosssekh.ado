program rosssekh, rclass
	
	capture drop cvgraph1
	capture drop cvrs
	capture drop RollingTestStat1
	capture drop RollingTestStat
	capture drop RossSekhTest
	
	syntax varlist(min = 2) [if] [in], window(integer) alpha(real) [nw(integer -1) *]
	
	* Count the number of forecasts to be tested
	local narg = 1               
	while "``narg''" != "" {
		local ++narg
	}
	if `nw' > 0 {
	local narg = `narg' - 5
	}
	else if `nw' == 0 {
	local narg = `narg' - 5
	}
	else if `nw' == -1 {
	local narg = `narg' - 4
	}
	*	
	

	* Clear the variables that have already been created if the test has been run before...
	capture drop forecasterror
	capture drop forecasterrortemp
	local vartemp = 1
	while "``vartemp''" != "" & `vartemp' <= `narg' {
		local ++vartemp
		local errorname = "forecasterror"+regexr("``vartemp''", ",","")
		capture drop `errorname'
	}
	*
	disp " "
	disp " "
	disp as text "Running the Rossi - Sekhposyan (2016) forecast rationality test..."
	disp " "
	*disp "REMINDER" 
	*disp "Forecast: " regexr("`2'", ",","") 
	*disp "Actual series: " regexr("`1'", ",","") 
	*disp " "
	
	if `nw' == -1{
	disp "WARNING"
	disp "When no bandwidth is specified using the nw(.) option, the test statistics are NOT calculated using HAC variance estimators. " 
	disp " "
	}
	*
	
	* Matrix of critical values for the test
	
	if `alpha'==0.01{
		matrix critvalu = (0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9\1,15.0484,14.0966,12.0133,12.5257,11.2177,10.5051,9.4237,8.5435,8.203\2,18.5865,15.9096,16.8898,14.1998,14.0067,14.1862,12.5407,12.8689,10.4675\3,22.2589,18.461,18.1309,16.6749,16.6152,16.6209,15.182,14.2981,12.7461\4,23.2931,22.6241,20.4215,20.1829,18.5263,18.7161,17.1985,16.8407,15.3503\5,25.9859,24.9017,22.113,22.3233,22.0671,19.2611,19.5215,17.5694,18.9347\6,28.3701,27.1948,25.1033,24.2014,24.8307,22.2983,20.9119,19.108,18.074\7,31.4425,28.9881,27.1075,26.9725,24.3925,24.0897,24.2268,21.7648,20.5248\8,32.4669,29.5149,28.6144,28.1559,26.8484,26.2502,25.2785,23.0942,22.8633\9,33.7114,35.2864,31.3305,29.5492,29.0904,28.217,25.6922,26.0238,24.8479\10,36.6704,33.1601,32.265,32.6074,30.0138,31.1782,27.3047,25.9979,26.2313)
	}
	else if `alpha==0.05'{
		matrix critvalu = (0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9\1,11.829,10.5637,8.9252,8.1468,8.1409,7.2803,6.4978,6.0837,5.4695\2,14.9966,13.0846,12.8141,10.9084,11.1314,9.9386,9.1724,9.0589,7.8305\3,17.6768,15.7548,15.0608,13.4383,13.2113,12.6018,10.9597,10.8426,9.4727\4,19.8434,17.6051,17.0158,16.3186,15.1404,14.7573,13.5928,13.1087,10.8243\5,21.7091,20.4659,18.7186,18.2152,17.1092,15.6317,15.4842,13.9418,13.6335\6,24.2721,22.487,20.9717,20.2839,20.2971,17.8602,16.5583,15.4633,14.4789\7,26.2869,24.2644,22.8543,21.6818,20.5974,20.12,19.0697,17.7064,15.9126\8,28.303,25.7461,24.3315,23.4497,22.4328,21.1563,20.3632,19.144,18.1475\9,29.5489,27.9249,26.8101,25.2662,24.251,22.7821,21.7109,20.2745,19.7147\10,31.7548,29.4709,27.598,27.0357,25.3011,25.325,23.4556,22.618,21.6647)
	}
	else if `alpha==0.10'{
		matrix critvalu = (0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9\1,10.0909,8.8274,7.7116,6.9555,6.4272,5.841,4.9404,4.8508,4.0096\2,13.2456,11.4773,10.7955,9.6482,9.3648,8.3442,7.7478,7.4669,6.2243\3,15.9915,14.2049,13.3396,11.6461,11.4939,10.4839,9.39,8.9699,7.9423\4,18.4447,15.5897,15.1254,13.8661,13.2415,12.7312,11.5331,10.7335,9.3509\5,19.969,18.2447,16.719,15.7116,15.0672,14.1355,13.1798,12.1317,11.4857\6,22.3413,20.3183,19.1924,18.0867,17.3395,15.6658,14.764,13.4408,12.3823\7,24.3462,22.3182,21.0891,20.0822,18.4705,17.7375,16.8276,15.6473,13.922\8,26.593,23.8825,22.407,21.6763,20.1078,18.7631,18.1456,17.0475,15.8832\9,27.8409,26.0117,24.504,23.3912,21.4939,20.6265,19.2173,18.056,17.2398\10,29.2933,27.1103,25.8483,24.6502,23.4647,22.5659,20.667,20.0081,18.402)
	}
	

		
	* Create variable(s) containing forecast error
	local vartemp = 1
	while "``vartemp''" != "" & `vartemp' <= `narg' {
		local ++vartemp
		local errorname = "forecasterror"+regexr("``vartemp''", ",","") // the name where the forecast error is stored.
		local command = regexr("`1'", ",","")+"-"+regexr("``vartemp''", ",","") // The command used by stata to compute the forecast error.
		generate forecasterrortemp = `command'
		rename forecasterrortemp `errorname'
	}
	*
		
	* Get critical value for the test
	qui count if `1' !=.
	local P = r(N)
	set matsize `P'
	local mu =`window'/`P'
	local cvcol = round(`mu'*10)+1
	if `cvcol' == 1 {
	`cvcol' = 2
	}
	if `cvcol' > 10 {
	`cvcol' = 10
	}
	local nreg = `narg' + 1
	local cv = critvalu[`nreg' + 1,`cvcol'] 
	disp as text "Critical value for the test: " `cv'
	
	* Rolling ols regression: regressing the forecast error on reference forecasts
	local T = _N
	local nlag = int(`window'^(1/4))
	mat RollingTestStat = J(`T' - `window' + 1,1,1)
	forvalues j=`window'(1)`P'{
	if `nreg' == 1 {
	*
	}
	else {
	local start = `j'-`window'+1
	local end = `j'		
	local command = "`errorname'" + " " + regexr("`2'", ",","") + " in " + "`start'" + "/" + "`end'"
	if `nw' > 0 {
	qui newey `command', lag(`nw') force // regression with Newey-West standard errors, lag length is given by user
	}
	else if `nw' == 0{
	qui newey `command', lag(`nlag') force // regression with Newey-West standard errors, lag length is round(w^0.25)
	}
	else if `nw' == -1{
	qui reg `command' // regression without Newey-West standard errors
	}
	mat foo = e(b)*inv(e(V))*e(b)'
	mat RollingTestStat[`j' - `window'+1,1] = foo[1,1]
	*
	}
	}
	mat cvgraph = `cv'*J(`P',1,1)
	svmat cvgraph, names(cvgraph) 
	capture generate cvrs = cvgraph1[_n - `window' + 1]
	svmat RollingTestStat, names(RollingTestStat)
	capture generate RossSekhTest = RollingTestStat1[_n - `window' + 1]
	disp as text "NOTE: the program generates two variables for plotting:"
	disp "           - cvrs, which contains the critical values"
	disp "           - RossSekhTest, which contains the sequence of rolling Rossi - Sekhposyan test statistics"
	disp " "
	disp " "
	disp " "
	disp " "
	
	capture drop cvgraph1
	capture drop RollingTestStat1
	capture drop `errorname'
	
	qui sum RossSekhTest
	local tstat_inf = r(min)
	local tstat_sup = r(max)
	
	
	qui tsset 
	local timevariable = r(timevar)
	line cvrs RossSekhTest `timevariable' in `window'/`T', ///
	legend(order(1 2) label(1 "Critical value") label(2 "R-S test stat.")) ///
	lpattern(dash solid) ///
	color(red blue) ///
	xtitle(Time) ///
	xlabel(,labsize(small)) ///
	ylabel(,labsize(small)) ///
	title(Rossi - Sekhposyan Forecast Rationality Test)
	
	* ereturn post
			
	
	/* Results to return */
	return scalar cv = `cv'
	return matrix CV critvalu
	return matrix RollStat RollingTestStat
	return local cmdline `"`0'"'
	return local cmd "rosssekh"
	return scalar tstat_sup = `tstat_sup'
	return scalar level = `alpha'

	disp "Rossi and Sekhposyan's (2016) test rejects the null hypothesis of forecast rationality when the test statistic is above the critical value line."
	disp "Done!"
	
end 
