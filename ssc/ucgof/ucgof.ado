*! 1.0.0 Univariate categorical GOF tests with Bonferroni post-hoc
* Author: Brent D. Hill (North Dakota State University)
* This program was adapted from the following packages:
* - tab_chi/chitest (N. J. Cox, 1999)
* - csgof (Statistical Consulting Group - UCLA, 2015)

program def ucgof, rclass
	version 10.0
	syntax varlist [, model(numlist min=2) freq ]

	preserve

	if ("`freq'" == "freq") {
		display _newline(0)
		display as text "--- Data in aggregate (tabular) format ---"
		sort `varlist'
		quietly tabulate `varlist' [fw=_freq]
		local J = `r(r)'
		local n = `r(N)'
	}

	if ("`freq'" != "freq") {
		quietly tabulate `varlist'
		local J = `r(r)'
		local n = `r(N)'
	}

	if ("`model'" == "") {
		local percexp = round(100/`J', .001)
		forvalues i = 1 / `J' {
			local model `percexp' `model'
		}
	}

	local expcat : word count `model'
	if (`expcat' != `J') {
		display in red "*** The variable `varlist' has `J' categories, but the specified model has `expcat' values, `model'."
		display in red "*** Please supply `J' values in the model() option or omit that option altogether."
		exit
	}

	if ("`freq'" != "freq") {
		quietly table `varlist', replace
		quietly rename table1 Obs_Freq
		sort `varlist'
	}
	if ("`freq'" == "freq") {
		//quietly table `varlist' [fw=Obs_Freq], replace
		quietly rename _freq Obs_Freq
		sort `varlist'
	}

	local i = 0
	local totperc = 0
	quietly generate Exp_Freq = .
	quietly generate model = .
	quietly generate Zres = .

	foreach percent of local model {
		local i = `i' + 1
		local totperc = `totperc' + `percent'
		quietly replace model = `percent' in `i'
		quietly replace Exp_Freq = round((`percent'/100)*`n', .001) in `i'
	}

	if abs(`totperc' - 100) > 1 {
		display in red "*** The specified model (null) percentages do not total to 100%."
		display in red "*** The sum of `model' is `totperc'."
		display in red "*** Please supply percentages that sum to 100%."
		exit
	}

	tempvar pearson1 pearson2 lrchisq1 lrchisq2
	quietly gen `pearson1' = (Obs_Freq - Exp_Freq)^2 / Exp_Freq
	quietly gen `pearson2' = sum(`pearson1')
	quietly gen `lrchisq1' = Obs_Freq*ln(Obs_Freq/Exp_Freq)
	quietly gen `lrchisq2' = 2*sum(`lrchisq1')

	local df = `J' - 1
	local osl_pearson = chi2tail(`df', `pearson2'[_N])
	local osl_lrchisq = chi2tail(`df', `lrchisq2'[_N])
	quietly replace Zres = (Obs_Freq-Exp_Freq)/sqrt(`n'*.01*model*(1-.01*model))
	quietly gen p = `J'*2*(1-normal(abs(Zres)))
	quietly replace p = 1 if p>1
	quietly gen Model = string(model) + "%"
	quietly drop model
	quietly format %9.2f Exp_Freq
	quietly format %9.0f Obs_Freq
	quietly format %9.2f Zres
	quietly format %4.3f p

	display _newline(0)
	display as text "  Chi-squared GOF tests (df = " as result "`df'" as text "):" _newline(1)
	display as text "  Likelihood-ratio = " as result %4.3f round(`lrchisq2'[_N], .001) as text ", p = " as result %5.4f round(`osl_lrchisq', 0.0001)
	display as text "           Pearson = " as result %4.3f round(`pearson2'[_N], .001) as text ", p = " as result %5.4f round(`osl_pearson', 0.0001)
	list `varlist' Model Exp_Freq Obs_Freq Zres p, noobs sep(0)
	display as text "  Note: P-values have been adjusted using the Bonferroni method."

end
