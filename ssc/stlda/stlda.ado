*! version 1.1.1 30may2013

/*
History  
30may2013: version 1.1.1
*/ 

pr stlda, rclass
	version 12.1
	syntax varlist(numeric min=3 max=3) [if] [in] [, ///
		Method(string) ///
		Level(numlist >0 <100 max=1) ///
		Plot	///
	]
	marksample touse
	tokenize `varlist'
	loc cells `1'
	loc n `2'
	loc neg `3'
	// check input data errors
	tempvar err1
	gen `err1' = `n' < `neg'
	if sum(`err1') > 0 { 
		di as err "Invalid data: the number of replicate cultures (second variable) cannot be smaller than the number of negative cultures (third variable)"
		exit 198
	}
	capt mata mata which mm_root()	
	if _rc {
		di as err "mm_root() from -moremata- is required; type -ssc install moremata- to install it"
		exit 499
	}
	if "`method'" != "" & "`method'" != "wald1" & "`method'" != "wald2"  & "`method'" != "prlik" {
		di as err "Unknown method. Valid values: wald1, wald2, prlik"
		exit 198
	}
	if "`level'" != "" {
		if `level' < 1 di as err "Warning: confidence level too small (N.B.: it is interpreted as a percentage)"
	}
	if "`method'" == "" loc method "wald1"
	if "`level'" == "" loc level 95
	tempvar pos lcells 
	gen `pos' = `n' - `neg'
	gen `lcells' = log(`cells') 
	qui glm `pos' if `touse', family(binomial `n') link(cloglog) offset(`lcells')
	sca deviance = e(deviance)
	sca pearson = e(deviance_p)
	sca df = e(df)
	mat coef = e(b)
	mat var = e(V)
	sca lambda = coef[1, 1]
	sca se_lambda = sqrt(var[1, 1])
	estimates store mod
	// extended model for testing single-hit hypothesis
	qui glm `pos' `lcells' if `touse', family(binomial n) link(cloglog)
	mat coef2 = e(b)
	mat var2 = e(V)
	sca slope = coef2[1, 1]
	sca se_slope = sqrt(var2[1, 1])
	// LR test
	qui lrtest mod .
	mata: ldamata("`varlist'", "`touse'", "`method'", `level')
	if "`plot'" != "" {
		tempvar pred_neg_prop pred_neg_ul pred_neg_ll neg_prop
		gen `pred_neg_prop' = exp(-exp(lambda) * `cells')
		gen `pred_neg_ul' = exp(-ci_ul * `cells')
		gen `pred_neg_ll' = exp(-ci_ll * `cells')
		gen `neg_prop' = `neg' / `n'
		loc freq_title1 = round(exp(lambda), 1e-9)
		loc freq_title2 = round(1/exp(lambda))
   	graph twoway (line `pred_neg_prop' `pred_neg_ul' `pred_neg_ll' `cells' if `touse', yscale(log) ylabel(#10) ytitle("Fraction of negative cultures") /// 
				xlabel(#10) xtitle("Cells") lcolor(blue blue blue) lpattern(solid dash dash) legend(off) ///
				title("Estimated frequency = `freq_title1' = 1 / `freq_title2'", size(*0.8))) ///
			(scatter `neg_prop' `cells' if `touse', mcolor(red))
	} 
	ret sca p_lr_slope = r(p)
	ret sca lr_slope = r(chi2)
	ret sca p_score = chi2tail(1, score_slope) 
	ret sca score_slope = score_slope
	ret sca p_wald = chi2tail(1, wald_slope) 
	ret sca wald_slope = wald_slope
	ret sca slope = slope
	ret sca df = df
	ret sca p_pearson = chi2tail(df, pearson) 
	ret sca pearson = pearson
	ret sca p_deviance = chi2tail(df, deviance) 
	ret sca deviance = deviance
	ret sca ci_ul = ci_ul
	ret sca ci_ll = ci_ll
	ret sca freq = exp(lambda)
	estimates clear
end

version 12.1
mata:

function ldamata(varlist, touse, method, level) {
	X	= .
	st_view(X, ., tokens(varlist), touse)
	cells = X[, 1]
	n = X[, 2]
	neg = X[, 3]
	pos = n - neg
	lcells = log(cells)
	deviance = st_numscalar("deviance")
	pearson = st_numscalar("pearson")
	df = st_numscalar("df")
	lambda = st_numscalar("lambda")
	se_lambda = st_numscalar("se_lambda")
	pi = exp(-exp(lambda :+ lcells))
	// score (derivatives of the loglikelihood)
	sc = (sum((neg :- n :* pi) :* log(pi) :/ (1 :- pi)) \ sum((neg :- n :* pi) :* cells :* log(pi) :/ (1 :- pi)))
	// inversa of covariance matrix
	design_t = (J(1, rows(X), 1) \ cells')
	matcov = invsym(design_t * diag(n :* pi :* (log(pi)):^2 :/ (1 :- pi)) * design_t')
   // score test
   sc_chi = sc' * matcov * sc
	st_numscalar("score_slope", sc_chi)
	// LR test
	lr_chi = st_numscalar("r(chi2)")
	// Wald test 
	slope = st_numscalar("slope")
	se_slope = st_numscalar("se_slope")	
	wald_chi = ((slope - 1)/se_slope)^2
	st_numscalar("wald_slope", wald_chi)
	// CI
	ci = CIcompute(lambda, se_lambda, n, neg, cells, method, level/100)
	st_numscalar("ci_ll", ci[1])
	st_numscalar("ci_ul", ci[2])	
	print(lambda, ci, level, method, deviance, pearson, df, slope, sc_chi, lr_chi, wald_chi)
}

function CIcompute(lambda, se_lambda, n, neg, cells, method, level) {
	if(method == "prlik") {
		rc = mm_root(r = ., &prof_lik(), 0.00001, exp(lambda), 0, 1000, n, neg, cells, exp(lambda), level)
		if (rc != 0) r = . 
		lower = r
		rc = mm_root(r = ., &prof_lik(), exp(lambda), exp(lambda + 3 * se_lambda), 0, 1000, n, neg, cells, exp(lambda), level)
		if (rc != 0) r = . 
		upper = r
		return((lower, upper))
	}
	else {
		z_value = invnormal(1-(1-level)/2)
		if(method == "wald1") return((exp(lambda - z_value * se_lambda), exp(lambda + z_value * se_lambda)))
		else if(method == "wald2") return((exp(lambda) - z_value * exp(lambda) * se_lambda, exp(lambda) + z_value * exp(lambda) * se_lambda))
	}
}
function prof_lik(phi, n, neg, cells, maxlik, ci_level) {
	return(2*(loglik(phi, n, neg, cells) - loglik(maxlik, n, neg, cells)) + invchi2(1, ci_level))
}

function loglik(x, n, neg, cells) {
	return(sum(log(comb(n, neg)) :- neg :* x :* cells :+ (n :- neg) :* log(1 :- exp(-x :* cells))))
}

function print(lambda, ci, level, method, deviance, pearson, df, slope, sc_chi, lr_chi, wald_chi){
   name_method = methodname(method)
	printf("{txt}\n{space 1}Frequency\t\t\t\t= {res}%g\n", exp(lambda))
	printf("{txt}{space 1}(or approx. {res}1 / %g)\n\n", round(1/exp(lambda)))
	printf("{txt}{space 1}%g%% Confidence interval (%s):\n", level, name_method)
	printf("{txt}{space 11}Lower limit\t\t\t= {res}%g\n", ci[1])
	printf("{txt}{space 11}Upper limit\t\t\t= {res}%g\n\n", ci[2])
	printf("{txt}{space 1}Goodness-of-fit tests\n")
	printf("{space 1}{hline 56}\n")
	printf("{txt}{space 1}%-21s%13s%8s%13s\n", "Test", "Chi-squared", "df", "p-value")
	printf("{space 1}{hline 56}\n")
	printf("{txt}{space 1}%-21s{res}%13.4g%8.0g%13.4g\n", "Deviance", deviance, df, chi2tail(df, deviance))
	printf("{txt}{space 1}%-21s{res}%13.4g%8.0g%13.4g\n", "Pearson", pearson, df, chi2tail(df, pearson))
   printf("{txt}{space 1}H0: Slope = 1 (*)\n")
	printf("{txt}{space 5}%-17s{res}%13.4g%8s%13.4g\n", "Wald", wald_chi, "1", chi2tail(1, wald_chi))
	printf("{txt}{space 5}%-17s{res}%13.4g%8s%13.4g\n", "Score", sc_chi, "1", chi2tail(1, sc_chi))
	printf("{txt}{space 5}%-17s{res}%13.4g%8s%13.4g\n", "Likelihood ratio", lr_chi, "1", chi2tail(1, lr_chi))
	printf("{space 1}{hline 56}\n")
	printf("{txt}{space 1}(*) Slope estimate\t\t\t= {res}%6.4g\n", slope)
}

function	methodname(method) {
   if (method == "wald1") return("Wald type 1")
	else { 
		if (method == "wald2") return("Wald type 2")
		else if (method == "prlik") return("Profile likelihood")
	}
}

end
