capture program drop clustse
program define clustse, eclass
version 11.0									/* Ensures that the Stata version is 11.0 or above to run Mata and bootstrap */
	
gettoken modname 0 : 0                    	/* Strips the model name from the input (may not be needed) */
	
syntax varlist(ts) [, cluster(name) reps(int 1000) seed(int 54321) method(string) force(string) truncate(string) fe(string) festruc(string)] 
	/* Gets the variable list, model name and cluster variable from the input */
	
gettoken depvar rhsvars : varlist				/* Strips the variables into right and left hand sides (may not be needed) */
	
local cmdline `modname' `depvar' `rhsvars'  	/* Sets `cmdline' to be the model specification */
	
set matsize 800								/* Increases the matrix size for bigger models (max for Stata IC is 800) */

quietly `cmdline'          					/* Runs the model initially */

capture drop flag
quietly gen flag = e(sample)				/* Marks the observations actually used in the model */
	

/* The stripped model name might be used in future versions of this program in order to have the program perform different procedures on
different models.  The stripped dependent variable could be used to check that there is variance in each cluster before running the loop */

set more off

display "Cluster variable is " "`cluster'"

/* Sorting and counting the number of clusters */
preserve
	
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
    	
display "Number of clusters is " `clustnum'

tempfile main
quietly save `main', replace				/* Saves the original data for use later */

if "`fe'" == "yes" {
	capture drop new_fe
	quietly egen new_fe = group(`festruc')
	quietly xtset new_fe
	
	if "`modname'" == "regress" {
		quietly xtreg `depvar' `rhsvars', fe
		local sigma_u = e(sigma_u)
		if `sigma_u' == . local sigma_u = "NA"
		local sigma_e = e(sigma_e)
		if `sigma_e' == . local sigma_e = "NA"
		local rho = e(rho)
		if `rho' == . local rho = "NA"
	}

	if "`modname'" == "logit" {
		quietly xtlogit `depvar' `rhsvars', fe
		local sigma_u = e(sigma_u)
		if `sigma_u' == . local sigma_u = "NA"
		local sigma_e = "NA"
		local rho = e(rho)
		if `rho' == . local rho = "NA"
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
		display "Error: Fixed effects can only be used with the following models:"
		display "regress, logit, poisson, and nbreg"
		exit
	}
}
else {
	local sigma_u = "NA"
	local sigma_e = "NA"
	local rho = "NA"
}

matrix estimates = e(b)
local beta_names : colfullnames(estimates)
local num_betas = wordcount("`beta_names'")

capture drop matrix betas
matrix betas = J(`clustnum', `num_betas', .)		/* Generates a blank matrix "betas" from the number of variables by the number of clusters */

capture drop to_use
gen to_use = 0

capture drop matrix clusters
matrix clusters = J(`clustnum', 3, .)					/* Designed to track the cluster progress */

capture drop matrix betas
matrix betas = J(`clustnum', `num_betas', .)			/* Matrix for storing the coefficients for each cluster */

if "`method'" == "pairs" {
	if "`fe'" == "yes" {
		display "To run fixed effects with the pairs cluster bootstrap-t procedure, you need "
		display "to use the clusterbs.ado program directly.  It has different options for "
		display "fixed effects.  See the clusterbs help file for more information."
		exit
		}
	else {
		capture clusterbs `cmdline', cluster(`cluster') reps(1) seed(`seed') 						/* Checks to see if clusterbs.ado is installed */
		if _rc != 0 {
			display "******************************* ERROR ********************************"
			display "Program clusterbs.ado (or related program estout.ado) not found.  Please download from SSC."
			display "Type in command line: SSC install clusterbs"
			display "If clusterbs is already installed and this does not resolve the issue,"
			display "Type in command line: SSC install estout"
		}
		else {
			clusterbs `cmdline', cluster(`cluster') reps(`reps') seed(`seed')		/* Runs the pairs cluster bootstrap-t procedure  */
		}
	}
}
else {
	if "`method'" == "wild" {
		if ("`modname'" == "regress" | "`modname'" == "reg") {
			capture cgmwildboot `depvar' `rhsvars', cluster(`cluster') bootcluster(`cluster') reps(1) seed(`seed')		/* Checks to see if cgmwildboot.ado is installed */
			if _rc != 0 {
				display "******************************* ERROR ********************************"
				display "Program cgmwildboot.ado not found.  Please download from https://sites.google.com/site/judsoncaskey/data"
				display "You will also need to install program unique.ado to run the wild cluster bootstrap-T."
				display "Type in command line: SSC install unique"
			}
			else {
				cgmwildboot `depvar' `rhsvars', cluster(`cluster') bootcluster(`cluster') reps(`reps') seed(`seed')		/* Runs the wild cluster bootstrap-t procedure */
			}
		}
		else {
			display "The wild cluster boostrap-t procedure can only be performed with linear models."
			display "Please specify a different estimation method and re-run the program."
			exit
		}
	}
	else {							/* if the method is not specified or is "case", then it attempts to run the CASE procedure */
			


/* Now, this part of the program will run a loop to use the clusters' observations to run each model and store the coefficients */

di "Starting CATs Procedure and attempting to run the model in each cluster"
if ("`force'" == "no" | "`force'" == "") {
local i = 1
while `i' < (`clustnum' + 1) {
	di "." _continue			/* Displays a dot for each iteration step */
						
	quietly replace to_use = 1 if cluster_num == `i'	/* Selects just the observations from the cluster to be used */

   	capture drop clust_obs
   	bysort cluster_num: gen clust_obs = _n 				/* Counts the observations in the cluster and stores them in variable clust_obs */
   	
   	local obs_to_use = 1
   	local k = 1
   	while `k' < (_N + 1) {
   		if cluster_num[`k'] == `i' { 
   			local obs_to_use = clust_obs[`k'] 			/* Sets local obs_to_use to the max # of observations in the cluster (this works because
   														the data is already sorted, so it will store the highest observation # in the cluster) */
   		} 
   		local ++k
   	}
   		
   	matrix clusters[`i', 1] = `i'						/* Tracks the progress of the loop through the clusters */
	matrix clusters[`i', 2] = `obs_to_use'				/* Records the number of observations for the cluster */
	
   	if `obs_to_use' > `num_betas'  {					/* If the # of observations in the cluster > the # of coefficients to estimate, then: */
  		if "`fe'" == "yes" {
			
			if "`modname'" == "regress" {
				capture xtreg `depvar' `rhsvars' if to_use == 1, fe
			}

			if "`modname'" == "logit" {
				capture xtlogit `depvar' `rhsvars' if to_use == 1, fe
			}

			if "`modname'" == "poisson" {
				capture xtpoisson `depvar' `rhsvars' if to_use == 1, fe
			}

			if "`modname'" == "nbreg" {
				capture xtnbreg `depvar' `rhsvars' if to_use == 1, fe
			}
			if ("`modname'" != "regress" & "`modname'" != "logit" & "`modname'" != "poisson" & "`modname'" != "nbreg") {
				display "Error: Cluster fixed effects can only be used with the following models:"
				display "regress, logit, poisson, and nbreg"
				exit
			}
		}
		else {
			capture `cmdline' if to_use == 1				/* This runs the model on just the selected observations */  
  		}
	/* Here there's a potential problem-- what if there's no variance on the DV or IV for the cluster observations? */	

  		if _rc != 0 {										/* This statement should fix the problem */
  		  		matrix tempbetas = J(1, `num_betas', .) 	/* This stores nulls for the coefficients */
  				matrix clusters[`i', 3] = 0					/* Records that this cluster is not used for a model */
		}
  		else {
  			matrix tempbetas = e(b)	    				/* Pulls the estimated coefficients and stores them in a temporary matrix */
  			matrix clusters[`i', 3] = 1					/* Records that this cluster is used for a model */		
  		}
  	}
  		
  	else { 											/* If the number of observations in the cluster is too small, then: */
  		matrix tempbetas = J(1, `num_betas', .) 	 /* This stores nulls for the coefficients */
  		matrix clusters[`i', 3] = 0					/* Records that this cluster is not used for a model */
  	}	

    local j = 1
    while `j' < (`num_betas' + 1) {					/* This loop fills in the matrix "betas" from the coefficient estimates from the cluster */
    	
    	if (tempbetas[1, `j'] == . | tempbetas[1, `j'] == 0) {					/* Any estimates not found are stored in "betas" as nulls */
    		matrix betas[`i', `j'] = .
     	}
    	else {												/* If the conditions above do not apply (the model successfully store coefficients, then: */
    		matrix betas[`i', `j'] = tempbetas[1, `j']		/* This places the coefficient estimates from matrix "tempbetas" into matrix "betas" */
    	}

    	local ++j
    }
  	
  	quietly replace to_use = 0

  	local ++i    										/* Iterates the while loop over the clusters */
}
}
else {    				/* this part will run if the force() option equals anything other than "no" or unspecified (designed for force(yes))  */
local i = 1
while `i' < (`clustnum' + 1) {
	di "." _continue			/* Displays a dot for each iteration step */
						
	quietly replace to_use = 1 if cluster_num == `i'	/* Selects just the observations from the cluster to be used */

   	capture drop clust_obs
   	bysort cluster_num: gen clust_obs = _n 				/* Counts the observations in the cluster and stores them in variable clust_obs */
   	
   	local obs_to_use = 1
   	local k = 1
   	while `k' < (_N + 1) {
   		if cluster_num[`k'] == `i' { 
   			local obs_to_use = clust_obs[`k'] 			/* Sets local obs_to_use to the max # of observations in the cluster (this works because
   														the data is already sorted, so it will store the highest observation # in the cluster) */
   		} 
   		local ++k
   	}
   		
   	matrix clusters[`i', 1] = `i'						/* Tracks the progress of the loop through the clusters */
	matrix clusters[`i', 2] = `obs_to_use'				/* Records the number of observations for the cluster */
	
   	if `obs_to_use' > `num_betas'  {					/* If the # of observations in the cluster > the # of coefficients to estimate, then: */
  		if "`fe'" == "yes" {
		
			if "`modname'" == "regress" {
				capture xtreg `depvar' `rhsvars' if to_use == 1, fe
			}

			if "`modname'" == "logit" {
				capture xtlogit `depvar' `rhsvars' if to_use == 1, fe
			}

			if "`modname'" == "poisson" {
				capture xtpoisson `depvar' `rhsvars' if to_use == 1, fe
			}

			if "`modname'" == "nbreg" {
				capture xtnbreg `depvar' `rhsvars' if to_use == 1, fe
			}
			if ("`modname'" != "regress" & "`modname'" != "logit" & "`modname'" != "poisson" & "`modname'" != "nbreg") {
				display "Error: Cluster fixed effects can only be used with the following models:"
				display "regress, logit, poisson, and nbreg"
				exit
			}
		}
		else {
			capture `cmdline' if to_use == 1				/* This runs the model on just the selected observations */  
  		}
  		
	/* Here there's a potential problem-- what if there's no variance on the DV or IV for the cluster observations? */
  		if _rc != 0 {										/* This statement should fix the problem */
  		  		matrix tempbetas = J(1, `num_betas', .) 	/* This stores nulls for the coefficients */
  				matrix clusters[`i', 3] = 0					/* Records that this cluster is not used for a model */
   		}
  		else {
  			matrix tempbetas = e(b)	    				/* Pulls the estimated coefficients and stores them in a temporary matrix */
  			matrix clusters[`i', 3] = 1					/* Records that this cluster is used for a model */		
  		}
  	}
  		
  	else { 											/* If the number of observations in the cluster is too small, then: */
  		matrix tempbetas = J(1, `num_betas', .) 	 /* This stores nulls for the coefficients */
  		matrix clusters[`i', 3] = 0					/* Records that this cluster is not used for a model */
   	}	
    
    local j = 1
    while `j' < (`num_betas' + 1) {					/* This loop fills in the matrix "betas" from the coefficient estimates from the cluster */
    	
    	if tempbetas[1, `j'] == . {					/* Any estimates not found are stored in "betas" as zeros (converted to null later) */
    		matrix betas[`i', `j'] = 0					/* And all the coefficient estimates for the cluster will not be used in the calculations */
    		matrix clusters[`i', 3] = 0				/* Records that this cluster is not used for a model */
    	}
    	else {
    	    if tempbetas[1, `j'] == 0 {					/* Any omitted variables' estimates (recorded as 0) are stored as zeros (converted to null later) */
     			matrix betas[`i', `j'] = 0					/* And all the coefficient estimates for the cluster will not be used in the calculations */
    			matrix clusters[`i', 3] = 0				/* Records that this cluster is not used for a model */
    		}
			else {												/* If the conditions above do not apply (the model successfully store coefficients, then: */
    			matrix betas[`i', `j'] = tempbetas[1, `j']		/* This places the coefficient estimates from matrix "tempbetas" into matrix "betas" */
    		}
    	}
    	
    	local ++j
    }
    
	local j = 1    
    while `j' < (`num_betas' + 1) {
    	if betas[`i', `j'] == 0 {
    		local q = 1
    		while `q' < (`num_betas' + 1) {
    			matrix betas[`i', `q'] = 0			/* This code ensures that all variables' coefficient estimates are not used if some variables 
    													are not found or were omitted in a cluster */
    			local ++q
    		}
    	}
    	local ++j 
    }
  	
  	quietly replace to_use = 0

  	local ++i    										/* Iterates the while loop over the clusters */
}
}

capture drop to_use

mata : st_matrix("clustsum", colsum(st_matrix("clusters")))				/* Gets column sums from the clusters matrix */

local num_used = clustsum[1, 3]											/* Stores the column sums in local num_used */

display ""
display "The model ran successfully in " `num_used' " clusters out of a possible " `clustnum' "."
if `num_used' < `clustnum' display "If the model failed in a high proportion of clusters, consider using another method."


if (`clustnum' > `num_used' & ("`force'" == "no" | "`force'" == "")) {									/* If the model did not run in every cluster, then it tries other procedures */
	display "These data have too few observations per cluster or too little variation"
	display "on the variables within clusters to run the model in each cluster."
	display "The Ibragimov-Muller cluster-adjusted t-statistics procedure will not work without"
	display "using the force(yes) option to run the model in only successful clusters."
	display "You can try using the wild or pairs cluster bootstrap-t procedures, or try to"
	display "use the force(yes) option.  If forcing the procedure, pay attention to how many"
	display "clusters the model fails in."
	
	if "`fe'" == "yes" {
		display "Keep in mind that the wild cluster bootstrap-t procedure will not work with"
		display "fixed effects.  The pairs cluster bootstrap-t procedure will only run fixed"
		display "effects by calling it directly through the program clusterbs.ado."
		display "For more info on using fixed effects with the pairs cluster bootstrap-t, see"
		display "the clusterbs help file."
	}
}
else {

 	if "`fe'" == "yes" {
		if "`modname'" == "regress" {
			capture xtreg `depvar' `rhsvars', fe
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
		if ("`modname'" != "regress" & "`modname'" != "logit" & "`modname'" != "poisson" & "`modname'" != "nbreg") {
			display "Error: Cluster fixed effects can only be used with the following models:"
			display "regress, logit, poisson, and nbreg"
			exit
		}
	}
	else {
		quietly `cmdline'				/* Runs the model to get the estimation results for e() */
  	}				
	
	estimates store original_est											/* Stores the original estimates for later use */
	
	matrix org_betas = e(b)												/* Stores the original coefficients to be retrieved later */
	matrix avg_betas = org_betas
	
	/* This code will create a new matrix "demeaned" that is (beta - the mean of each column of beta) */
	matrix U = J(`clustnum', 1, 1)								/* Makes a uniform matrix for later operations */
	matrix sum = U' * betas										/* Multiplies U' by the betas to sum each row and store in a matrix */
	matrix means = sum / `num_used'								/* Calculates the mean for each row by dividing by the # in the row */
	matrix mean_mat = U * means									/* Multiplies the means by U to make a matrix with same dimensions as betas */

// NEW SECTION TO TRUNCATE OUTLIERS
	if "`truncate'" == "yes" {
		local num_truncated = 0
		local d = 1
		while `d' < (`num_betas' + 1) {
			capture drop var__`d'
			qui gen var__`d' = .
			
			local f = 1
			while `f' < (`clustnum' + 1) {
				if betas[`f', `d'] == 0 {
					qui replace var__`d' = . in `f'
				}
				else {
					qui replace var__`d' = betas[`f', `d'] in `f'
				}
				local ++f
			}
			
			_pctile var__`d', p(25 50 75)
			local iqr = r(r3) - r(r1)				/* Calculates the inter-quartile range */
			local iqr = abs(`iqr')
			local betamean = r(r2)
			local betamean = abs(`betamean')
			
			local f = 1
			while `f' < (`clustnum' + 1) {
				local betafd = betas[`f', `d']
				if abs(`betafd') > (`betamean' + (6 * `iqr')) {
					matrix clusters[`f', 3] = 0						/* Excludes clusters if any estimate is > (mean + 6 * IQR) */
					local num_used = `num_used' - 1
					local num_truncated = `num_truncated' + 1
				}
				local ++f
			}
			
			capture drop var__`d'
			local ++d
		}
		
		local f = 1
		while `f' < (`clustnum' + 1) {
			if clusters[`f', 3] == 0 {
				local d = 1
				while `d' < (`num_betas' + 1) {
					matrix betas[`f', `d'] = .
					local ++d
				}	
			}
			local ++f
		}
		
		if `num_truncated' > 0 di "WARNING: " `num_truncated' " cluster estimates were truncated due to outlying variable estimates."
	}

	
	/* The omitted variables' and failed models' estimates were stored as zeros to allow the above matrix multiplications to work, but now we
	 need to get rid of the zeros in the betas matrix now so that they aren't used in calculations--the following loop does that: */
	local i = 1
	while `i' < (`clustnum' + 1) {
		if betas[`i' , 1] == 0 {
			local j = 1
			while `j' < (`num_betas' + 1) {
				matrix betas[`i', `j'] = .
				local ++j
			}
		}
		local ++i
	}
	
	matrix demeaned = betas - mean_mat							/* Subtracts the means from betas to get the differenced "demeaned" betas */
	
	/* This code will square the elements of matrix "demeaned" and store them as matrix "squared" */
	matrix squared = demeaned									/* Creates the matrix to store the squared differences */
	local i = 1
	while `i' < (`num_betas' + 1) {
		local j = 1
		while `j' < (`clustnum' + 1) {
			local tbs = demeaned[`j', `i']						/* This local `tbs' is the amount to be squared */
			matrix squared[`j', `i'] = `tbs' * `tbs'			/* This squares `tbs' and places it in the "squared" matrix */
			local ++j									/* Iterates the loop over rows */
		}
		if means[1, `i'] !=. matrix avg_betas[1, `i'] = means[1, `i']				/* Stores the the average betas from the regressions */
		else matrix avg_betas[1, `i'] = 0
		local ++i									/* Iterates the loop over columns */
	}
	
	/* This code will divide the elements of matrix "squared" by the number of elements */
	mata : st_matrix("squaredsums", colsum(st_matrix("squared")))				/* Gets column sums (sum of squared differences) */
	matrix var_betas = squaredsums
	matrix var_mean = squaredsums
	
	local i = 1
	while `i' < (`num_betas' + 1) {
		matrix var_betas[1, `i'] = squaredsums[1, `i'] / (`num_used' - 1)			/* This divides the column sums (sum of squared differences for each */
		matrix var_mean[1, `i'] = var_betas[1, `i'] / `num_used'						/* coefficient) by (the number of coefficient estimates - 1) to get the 
																					variance of each coefficient, then by the number of coefficient estimates again
																					to get the variance of the mean of the betas */
		local ++i														/* Iterates the loop */
	}
	 /* Matrix "variance" now stores the variance (over the cluster estimates) of each coefficient in the model */
	
	matrix vcv = e(V)									/* Creates a new matrix to store the updated variances in the VCV */
	
	local i = 1
	while `i' < (`num_betas' + 1) {
		matrix vcv[`i', `i'] = var_mean[1, `i']			/* Replaces the diagonal of the vcv matrix with the cluster coefficient variances */
		local ++i										/* Iterates the loop */
	}
		
	local dof = `num_used' - 1							/* This replaces the degress of freedom for the t-statistic to be equal to (the number of clusters - 1) */
		
	ereturn post avg_betas vcv, dof(`dof') depname(`depvar')		/* This replaces the original VCV in e() with the new covariance matrix, while also replacing
																	the coefficient estimates with the average betas from all the cluster regressions. 
																	The test statistics are now forced to be t-tests with the corrected degrees of freedom. */
	
	display "Conducting Wald test against null hypotheses: "	
	test (`rhsvars'), constant

	ereturn display										/* Displays the results of the model with the adjusted SEs, t-tests, and 95% CIs */
	
	estimates restore original_est						/* Restores the original estimates for getting model statistics */
	
	display "Calculating model statistics: "
	estat ic											/* Returns the AIC and BIC of the model */
	
	ereturn clear										/* Clears estimated results to prevent any problematic postestimation using the wrong VCV */
	
	display "Note that the coefficients in the table are the average of regressions"
	display "within each cluster.  They are not the same as the pooled model coefficients."
	display "The original model's coefficients are given in the table below:"
	
	matrix list org_betas
	if ("`sigma_u'"	!= "NA" | "`sigma_e'" != "NA" | "`rho'" != "NA") {
		if "`sigma_e'" == "NA" {
			di "sigma u = " "`sigma_u'"
			di "rho = " "`rho'"
		}
		else {
			di "sigma u = " "`sigma_u'"
			di "sigma e = " "`sigma_e'"
			di "rho = " "`rho'"
		}
	}
	display "Please note that post-estimation predictions and statistics"
	display "cannot be run on this model."
	
}	/* Closes the "else" command of (if `clustnum' > `num_used') that uses the CASE estimates to report the results */

}	/* Closes the "else" command of (if "`method'" == "pairs") that causes it to run the wild bootstrap or CASE procedure */

}	/* Closes the "else" command of (if "`method'" == "wild") that causes it to run the CASE procedure */

restore

end
