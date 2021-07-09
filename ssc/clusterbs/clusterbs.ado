capture program drop clusterbs
program define clusterbs, eclass

version 9.0									/* Ensures that the Stata version is 9.0 or above to run Mata and bootstrap */
	
gettoken modname 0 : 0                    	/* Strips the model name from the input (may not be needed) */
	
syntax varlist(ts) [, fe(string) cluster(name) reps(int 1000) seed(int 54321) festruc(string)] 		/* Gets the variable list, model name and cluster variable from the input */
	
gettoken depvar rhsvars : varlist				/* Strips the variables into right and left hand sides (may not be needed) */
	
local cmdline `modname' `depvar' `rhsvars'  	/* Sets `cmdline' to be the model specification */
	
set matsize 800								/* Increases the matrix size for bigger models (max for Stata IC is 800) */

preserve

if substr("`modname'", 1, 2) == "xt" {
	display "Program clusterbs will not work with models using the xt- prefix.  To run fixed effects models, specify fe() as an option."
	display "See the help file for how to use fixed effects properly with this program."
}
else { 
	quietly `cmdline', cluster(`cluster')  			/* Runs the initial model with robust clustered SEs */
}       

capture drop flag
qui gen flag = e(sample)				/* Marks the observations actually used in the model */
	
set more off

/* Save sigma_u, sigma_e, rho */

display "Cluster variable is " "`cluster'"

/* Sorting and counting the number of clusters */
	quietly drop if flag==0								/* Drops all observations not used in the initial model */
	
	capture drop neworder
	generate neworder = _n
	
	sort `cluster' neworder 					/* Sorts by cluster for dataset */
	
	capture drop ucluster
    by `cluster': gen ucluster = _n == 1 	/* Gives a 1 to the first observation in each cluster */
    
    sort neworder								/* Sorts the data back as it was */
    
	capture drop cluster_num
	gen cluster_num = sum(ucluster)				/* Gives a increasing number to each observation in each unique cluster */

	capture drop ucluster
	capture drop neworder  
	
	capture drop total_clusters
	egen total_clusters = max(cluster_num)  	/* Counts the total number of clusters */
    local clustnum = total_clusters[1]			/* Stores this variable as local clustnum */
   	capture drop total_clusters
    	
	display "Number of clusters for model is " `clustnum'

if ("`fe'" == "external" | "`fe'" == "inside") {

		capture drop new_fe
		if "`fe'" == "external" {
			quietly egen new_fe = group(`festruc')
			quietly xtset new_fe
		}
		if "`fe'" == "inside" {
			quietly egen new_fe = group(`festruc' cluster_num)
			quietly xtset new_fe
		}
		
	if "`modname'" == "regress" {
		quietly xtreg `depvar' `rhsvars', fe vce(cluster `cluster')
		local sigma_u = e(sigma_u)
		local sigma_e = e(sigma_e)
		local rho = e(rho)
	}

	if "`modname'" == "logit" {
		quietly xtlogit `depvar' `rhsvars', fe
		local sigma_u = e(sigma_u)
		local sigma_e = "NA"
		local rho = e(rho)
	}

	if "`modname'" == "poisson" {
		quietly xtpoisson `depvar' `rhsvars', fe
		local sigma_u = "NA"
		local sigma_e = "NA"
		local rho = "NA"
	}

	if "`modname'" == "nbreg" {
		quietly xtnbreg `depvar' `rhsvars', fe
		local sigma_u = "NA"
		local sigma_e = "NA"
		local rho = "NA"
	}
	
	if ("`modname'" != "regress" & "`modname'" != "logit" & "`modname'" != "poisson" & "`modname'" != "nbreg") {
		display "Error: Cluster fixed effects can only be used with the following models:"
		display "regress, logit, poisson, and nbreg"
		exit
	}
}
else {
	if "`fe'" == "cluster" {						/* If the model uses fixed effects, then it runs */
											/* the model as an xt- model and saves the estimates */
		quietly xtset `cluster'
	
		if "`modname'" == "regress" {
			quietly xtreg `depvar' `rhsvars', fe vce(cluster `cluster')
			local sigma_u = e(sigma_u)
			local sigma_e = e(sigma_e)
			local rho = e(rho)
		}

		if "`modname'" == "logit" {
			quietly xtlogit `depvar' `rhsvars', fe
			local sigma_u = e(sigma_u)
			local sigma_e = "NA"
			local rho = e(rho)
		}

		if "`modname'" == "poisson" {
			quietly xtpoisson `depvar' `rhsvars', fe
			local sigma_u = "NA"
			local sigma_e = "NA"
			local rho = "NA"
		}

		if "`modname'" == "nbreg" {
			quietly xtnbreg `depvar' `rhsvars', fe
			local sigma_u = "NA"
			local sigma_e = "NA"
			local rho = "NA"
		}
	
		if ("`modname'" != "regress" & "`modname'" != "logit" & "`modname'" != "poisson" & "`modname'" != "nbreg") {
			display "Error: Cluster fixed effects can only be used with the following models:"
			display "regress, logit, poisson, and nbreg"
			exit
		}
	}
	else {
		quietly `cmdline', cluster(`cluster')         /* Runs the initial model with robust clustered SEs */
		local sigma_u = "NA"
		local sigma_e = "NA"
		local rho = "NA"
	}
}

matrix estimates = e(b)
local beta_names : colfullnames(estimates)
local num_betas = wordcount("`beta_names'")

matrix main_est = J(`num_betas', 3, .)
matrix rownames main_est = `beta_names'
matrix colnames main_est = Coef StdErr t-value

if ("`sigma_u'"	== "NA" & "`sigma_e'" == "NA" & "`rho'" == "NA") {
	matrix final = J(`num_betas', 4, .)
	matrix rownames final = `beta_names'
	matrix colnames final = Coefficient Prob>|t| 95%_CI_low 95%_CI_high
}
else {
	if "`sigma_e'" == "NA" {
		matrix final = J((`num_betas' + 2), 4, .)
		local row_names = "`beta_names'" + " sigma_u rho"
		matrix rownames final = `row_names'
		matrix colnames final = Coefficient Prob>|t| 95%_CI_low 95%_CI_high
		matrix final[(`num_betas' + 1), 1] = `sigma_u'
		matrix final[(`num_betas' + 2), 1] = `rho'
	}
	else {
		matrix final = J((`num_betas' + 3), 4, .)
		local row_names = "`beta_names'" + " sigma_u sigma_e rho"
		matrix rownames final = `row_names'
		matrix colnames final = Coefficient Prob>|t| 95%_CI_low 95%_CI_high
		matrix final[(`num_betas' + 1), 1] = `sigma_u'
		matrix final[(`num_betas' + 2), 1] = `sigma_e'
		matrix final[(`num_betas' + 3), 1] = `rho'
	}
}

if _N < `reps' {
	qui set obs `reps'
}

local b = 1	
while `b' < (`num_betas' + 1) {					/* Runs a loop over the number of parameters */
	if `b' < `num_betas' gettoken var`b' beta_names: beta_names				/* Gets the variable name for each variable from betanames */
	else gettoken var`b': beta_names

	matrix main_est[`b', 1] = _b[`var`b'']
	matrix main_est[`b', 2] = _se[`var`b'']
	matrix main_est[`b', 3] = abs(_b[`var`b''] / _se[`var`b''])
	
	matrix final[`b', 1] = _b[`var`b'']
	
	if substr("`var`b''", 1, 2) == "o." {
		display "Error: Please remove variables that are collinear with the fixed effects "
		display "and re-run the model."
		exit
	}
	
	capture drop w_`var`b''	
	capture drop beta_`var`b''
	quietly {
		gen w_`var`b'' = .									/* Generates a new variable for each IV to store the w bootstrap estimates */
		gen beta_`var`b'' = .								/* Generates a new variable for each IV to store the beta bootstrap estimates */
	}
	local ++b														/* Iterates the loop */
}


tempfile main
quietly save `main', replace				/* Saves the original data for use later */

capture drop new_clustnum

di "Starting `reps' Bootstrap Replications"

set seed `seed'

forvalues k = 1/`reps' {
	di "." _continue
	
	quietly {
		
		bsample, cluster(`cluster') idcluster(new_clustnum)	  /* Creates a pairs cluster bootstrap sample with a new cluster variable name */
		
		if ("`fe'" == "external" | "`fe'" == "inside") {
			
			capture drop new_fe
			if "`fe'" == "external" {
				quietly gen new_fe = `festruc'
				quietly xtset new_fe
			}
			if "`fe'" == "inside" {
				quietly egen new_fe = group(`festruc' new_clustnum)
				quietly xtset new_fe
			}
			
			if "`modname'" == "regress" {
					capture xtreg `depvar' `rhsvars', fe vce(cluster new_clustnum)
				}

				if "`modname'" == "logit" {
					capture xtlogit `depvar' `rhsvars', fe
				}

				if "`modname'" == "poisson" {
					capture xtpoisson `depvar' `rhsvars', fe
				}

				if "`modname'" == "nbreg" {
					capture xtnbreg `depvar' `rhsvars', fe
				}
		}
		else {
			if "`fe'" == "cluster" {							/* This section resets the xtset using the new clustering indicator for each sample */
				quietly xtset new_clustnum
		
				if "`modname'" == "regress" {
					capture xtreg `depvar' `rhsvars', fe vce(cluster new_clustnum)
				}

				if "`modname'" == "logit" {
					capture xtlogit `depvar' `rhsvars', fe
				}

				if "`modname'" == "poisson" {
					capture xtpoisson `depvar' `rhsvars', fe
				}

				if "`modname'" == "nbreg" {
					capture xtnbreg `depvar' `rhsvars', fe
				}
			}
			else {
				quietly `cmdline', cluster(new_clustnum)         /* Runs the initial model with robust clustered SEs */
			}
		}
	}
	
	local b = 1
	while `b' < (`num_betas' + 1) {					/* Runs a loop over the number of parameters */
		if _rc != 0 {							/* If the model didn't run, this should store null values so the itration isn't counted */
			local beta_`var`b''_`k' = .					
			local w_`var`b''_`k' = .
		}
		else {
			capture {
				local beta_`var`b''_`k' = _b[`var`b'']					/* Quietly executes so that if a variable is excluded, it continues */	
				local w_`var`b''_`k' = (_b[`var`b''] - main_est[`b', 1]) / _se[`var`b''] 
			}
			if _rc != 0 {						/* Stores a null for the all the coefficients if any one variable is excluded from the model... */
				local q = 1						/* this should act to simply exclude any "bad" iterations of the bootstrapping */
				while `q' < (`num_betas' + 1) {
					local beta_`var`q''_`k' = .
					local w_`var`q''_`k' = .
					local ++q
				}
				continue, break					/* Breaks the loop over the variables (b) and continues to the constant and next iteration of k */
			}	
		}	
		local ++b														/* Iterates the loop */
	}	
	quietly use `main', replace					/* Restores the initial dataset */
}
di ""
di "Bootstrap iterations completed.  Now storing model results..."

forvalues k = 1/`reps' {
	local b = 1
	
	while `b' < (`num_betas' + 1) {
		quietly {
			replace beta_`var`b'' = `beta_`var`b''_`k'' in `k'			/* Stores the beta for each iteration and variable */
			replace w_`var`b'' = abs(`w_`var`b''_`k'') in `k'			/* Takes the absolute value of the w (t) statistic for each iteration and variable and stores it */
		}																
		local ++b
	}															
}

qui count if (w__cons != .)
local iter = r(N)
local fail = `reps' - `iter'

di "The model ran succesfully and stored results in `iter' bootstrap iterations."
if `fail' != 0 {
	di "`fail' bootstrap iterations failed to store results."
	di "If more than 10% of iterations failed, consider using a different model or method."
}

local b = 1
while `b' < (`num_betas' + 1) {
	
	qui count if (w_`var`b'' > main_est[`b', 3] & w_`var`b''!=.)
	local percent = r(N)
	
	local pval_`var`b'' = `percent' / `iter'			/* Generates the p-value comparing the initial model's w to the bootstrapped distribution of w */
	
	matrix final[`b', 2] = `pval_`var`b'''
	
	quietly {
		_pctile w_`var`b'', p(95)							/* Generates percentiles for the bootstrapped w__cons variable to obtain 95% CI */
		local par_`var`b'' = main_est[`b', 1]
		local low_`var`b'' = `par_`var`b''' - (r(r1) * main_est[`b', 2])			/* Calculates 95% CIs using the bootstrap-t method given in http://www.stata-journal.com/sjpdf.html?articlenum=st0073 (pp. 315-16) */
		local high_`var`b'' = `par_`var`b''' + (r(r1) * main_est[`b', 2])			/* and in http://kurt.schmidheiny.name/teaching/bootstrap2up.pdf (pp. 5-7) */
	}
	
	matrix final[`b', 3] = `low_`var`b'''
	matrix final[`b', 4] = `high_`var`b'''
	
	local ++b
}

capture estout matrix(final, fmt(%10.0g %12.1f %10.0g %10.0g))
if _rc != 0 {
	display "******************************* ERROR ********************************"
	display "Program estout.ado not found.  This program is needed to display results."
	display "To download estout, type in command line: SSC install estout"
}


if `iter' <= 500 estout matrix(final, fmt(%10.0g %12.1f %10.0g %10.0g)), style(smcl) title("Model Results") mlabels("", none) modelwidth(12 8 12 12) 
else {
	if `iter' <= 1000 estout matrix(final, fmt(%10.0g %12.2f %10.0g %10.0g)), style(smcl) title("Model Results") mlabels("", none) modelwidth(12 8 12 12)
	else {
		if `iter' <= 5000 estout matrix(final, fmt(%10.0g %12.3f %10.0g %10.0g)), style(smcl) title("Model Results") mlabels("", none) modelwidth(12 8 12 12)
		else estout matrix(final, fmt(%10.0g %12.4f %10.0g %10.0g)), style(smcl) title("Model Results") mlabels("", none) modelwidth(12 8 12 12)
	}
}


if "`fe'" == "cluster"	di "NOTE: Model estimated with fixed effects for the clusters (not shown)."
if "`fe'" == "external" di "NOTE: Model estimated with fixed effects for variable `festruc' (not shown)."
if "`fe'" == "inside" {
	di "NOTE: Model estimated with fixed effects for the interaction of the "
	di "cluster variable with `festruc' (not shown)."
}

di "The t-statistics and 95% confidence intervals are generated from the pairs "
di "cluster bootstrap-t procedure and are robust to clustering with a small number "
di "of sampling units.  Please note that the accuracy of the t-statistics and CIs "
di "is conditional on the number of bootstrap replications that were used to " 
di "calculate the distribution of t. For p < .05 significance tests, specify reps(500)"
di " or more. For p < .01 level, specify reps(1000) or more. For p < .001 level, specify "
di "reps(5000) or more.  More iterations will also yield more accurate confidence "
di "intervals.  Post-estimation procedures should not be run on this model."

restore

end
