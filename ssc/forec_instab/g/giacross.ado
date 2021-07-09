program giacross, rclass
	
	capture drop cvlowgraph1 
	capture drop cvhigraph1
	capture drop cvgraph1
	capture drop FluctuationTest1 
	capture drop cvlo
	capture drop cvhi
	capture drop  FlucTest
	* Clearly impose the syntax for the program
	syntax varlist(min = 3) [if] [in], window(integer) alpha(real) [nw(integer 0) side(integer 2) *]
	disp " "
	disp " "
	disp as text "Running the Giacomini - Rossi (2010) test for forecast comparison..."
	disp " "
	disp "REMINDER"
	disp "First forecast: " regexr("`2'", ",","") 
	disp "Second forecast: " regexr("`3'", ",","") 
	disp "Actual series: " regexr("`1'", ",","") 
	disp " "
	if `nw' > 0 {
	disp "Newey - West HAC estimator bandwidth: " `nw'
	disp " "
	}
	else {
	disp "Newey - West HAC estimator bandwidth chosen automatically with the Schwert criterion."
	disp " "
	}
	* Matrix of critical values for the test
	
	if `side'==2{
		matrix critvalu = (0.1, 3.393, 3.170\0.2, 3.179, 2.948\ 0.3, 3.012, 2.766\ 0.4, 2.890, 2.626\ 0.5, 2.779, 2.500\ 0.6, 2.634, 2.356\ 0.7, 2.560, 2.252\ 0.8, 2.433, 2.130\ 0.9, 2.248, 1.950)
	}
	else if `side==1'{
		matrix critvalu = (0.1, 3.176, 2.928\0.2, 2.938, 2.676\ 0.3, 2.770, 2.4282\ 0.4, 2.624, 2.334\ 0.5, 2.475, 2.168\ 0.6, 2.352, 2.030\ 0.7, 2.248, 1.904\ 0.8, 2.080, 1.740\ 0.9, 1.975, 1.600)
	}
	
	* Rolling D-M test
	local P = _N
	set matsize `P'
	mat FluctuationTest = J(`P' - `window' + 1,1,1)
	forvalues j = `window'(1)`P'{ 
		local start = `j'-`window'+1
		local end = `j'
		local command = "`varlist'" + " in " + "`start'" + "/" + "`end'"
		if `nw' > 0 {
		qui dmariano `command', kernel(bartlett) maxlag(`nw')
		mat FluctuationTest[`j' - `window'+1,1] = r(s1)
		}
		else {
		qui dmariano `command', kernel(bartlett)
		mat FluctuationTest[`j' - `window'+1,1] = r(s1)
		local maxlag = r(maxlag)
		} 
		}
	local T = rowsof(FluctuationTest)
	
	* Get critical values
	if `alpha'==0.05{
		local r=2
	}
	else if `alpha==0.10'{
	local r=3
	}
	local mu = (ceil((`window'/`P')*10))/10
	local i = `mu'*10
	local cv = critvalu[`i',`r']
	*disp as text "Lower and upper critical values for the test: " `cv' 
	
	if `side'==2{
		mat cvlowgraph = -1*`cv'*J(`T',1,1)
		mat cvhigraph = `cv'*J(`T',1,1)
		}
	else if `side==1'{
		mat cvgraph = `cv'*J(`T',1,1)
	}
	

	disp "NOTE: the program generates the following variables for plotting:"
	disp "2 sided alternative: cvlo and cvhi, which contain the lower and upper critical values"
	disp "1 sided alternative: cvone, which contains the one-sided critical value"
	disp "FlucTest, which contains the sequence of rolling Giacomini - Rossi test statistics"
	disp " "
	disp " "
	disp " "
	disp " "
	if `side'==2{
		svmat cvlowgraph, names(cvlowgraph) 
		capture generate cvlo = cvlowgraph1[_n - `window' + 1]
		svmat cvhigraph, names(cvhigraph)
		capture generate cvhi = cvhigraph1[_n - `window' + 1]
		}
	else if `side==1'{
		svmat cvgraph, names(cvgraph) 
		capture generate cvone = cvgraph1[_n - `window' + 1]
		}
	
	svmat FluctuationTest, names(FluctuationTest)
	capture generate FlucTest = FluctuationTest1[_n - `window' + 1]
	qui tsset 
	local timevariable = r(timevar)
	
	
	
	if `side'==2{
		line cvlo cvhi FlucTest `timevariable' in `window'/`P', /// 
		legend(order(1 3) label(1 "Critical values") label(3 "G-R test stat.")) ///
		lpattern(dash dash solid) ///
		color(red red blue) ///
		caption("Giacomini and Rossi's (2010) Fluctuation test") ///
	xtitle(Time) ///
	xlabel(,labsize(small)) ///
	ylabel(,labsize(small)) ///
	title(Giacomini - Rossi Fluctuation Test)
		}
	else if `side==1'{
		line cvone FlucTest `timevariable' in `window'/`P', /// 
		legend(label(1 "Critical value") label(2 "G-R test stat.")) ///
		lpattern(dash solid) ///
		color(red blue) ///
		caption("Giacomini and Rossi's (2010) Fluctuation test") ///
	xtitle(Time) ///
	xlabel(,labsize(small)) ///
	ylabel(,labsize(small)) ///
	title(Giacomini - Rossi Fluctuation Test)
		}
	
	if `side'==2{
	qui gen foo = abs(FlucTest)
	}
	else if `side==1'{
	qui gen foo = FlucTest
	}
	qui sum foo
	local tstat_inf = r(min)
	local tstat_sup = r(max)
	qui drop foo

	
	
	disp "Giacomini and Rossi's (2010) test rejects the null hypothesis of equal predictive ability when the test statistic is outside the band lines (2 sided alternative) or above the band line (1 sided alternative)."
	disp "When using the two sided test: when the test statistic is below the lowest band line, the first model forecasts significantly better."
	disp "When using the one sided test: when the test statistic is above the critical value line, the first model forecasts significantly worse."
	disp "Done!"
	
	if `side'==2{
		return matrix RollStat FluctuationTest
		return scalar level = `alpha'
		return scalar cv=`cv'
		return scalar tstat_sup = `tstat_sup'
		local testtype="Two-sided"		
		return local testtype "Two-sided"
		return local cmdline `"`0'"'
		return local cmd "giacross"
		}
	else if `side==1'{
		return matrix RollStat FluctuationTest
		return scalar level = `alpha'
		local cv=`cv'
		return scalar cv=`cv'
		return scalar tstat_sup = `tstat_sup'
		local testtype="One-sided"		
		return local testtype "One-sided"
		return local cmdline `"`0'"'
		return local cmd "giacross"
		}
	
	/*
	capture drop cvlowgraph1 
	capture drop cvhigraph1
	capture drop cvgraph1 
	capture drop FluctuationTest1
*/
	
end
