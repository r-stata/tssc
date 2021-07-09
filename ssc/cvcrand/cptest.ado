*!version2.1 27Mar2020

/* -----------------------------------------------------------------------------
** PROGRAM NAME: CPTEST
** VERSION: 2.1
** DATE: March 27, 2020
** -----------------------------------------------------------------------------
** CREATED BY: JOHN GALLIS, LIZ TURNER, FAN LI, HENGSHI YU
** -----------------------------------------------------------------------------
** PURPOSE: PERFORM CLUSTERED PERMUTATION TEST
** -----------------------------------------------------------------------------
** UPDATES: March 23, 2020 - Fixed error where program was not removing extraneous rows from constrained matrix
**						   - Program now allows for factor variables in the regression
**						   - Program now allows for count outcomes
**						   - Program now returns p-value to r(pval)
**						   - Updated Marksample so that missing values are removed
** 			March 27, 2020 - Minor update to give more detailed warning when string variable is included as a predictor
** -----------------------------------------------------------------------------
*/

capture program drop cptest
program define cptest, rclass
	version 14
	
	#delimit ;
	syntax varlist(fv min=1),
		 clustername(varname) directory(string) cspacedatname(string) outcometype(string)
	;
	
	#delimit cr
	
	marksample touse
	quietly count if `touse'
	
	preserve
    qui keep if `touse'
	
	/* error if there are no observations in the dataset or to use */
	if `r(N)' == 0 {
		di as error "There are no observations to use."
		di as error "Check if any of the predictors are coded as string variables.  If so, use the encode command to recode them as numeric."
		error 2000
	}
	
	if "`outcometype'" == "" {
		di as err "Error: Specify outcometype as continuous or binary"
		exit 198
	}

	di " "
	di " "
	di as error "Note: Make sure the ordering of clusters matches the ordering during randomization!"
	
	
	/* for error checking */
	local outcome `: word 1 of `varlist''
	
	capture drop _resid
	if "`outcometype'" == "continuous" | "`outcometype'" == "Continuous" {
		quietly tab `outcome'
		if `r(r)' <= 1 {
			di as error "Error: Outcome does not have enough variability!"
			exit 198
		}
		if `r(r)'== 2 {
			di as result "Warning: Outcome specified as continuous but has two levels"
		}
		quietly regress `varlist'
		predict double _resid, residuals
		di as result "Linear regression was performed"
	}
	else if "`outcometype'" == "binary" | "`outcometype'" == "Binary" {
		quietly tab `outcome'
		if `r(r)' <= 1 {
			di as error "Error: Outcome does not have enough variability!"
			exit 198
		}
		if `r(r)' != 2 {
			di as err "Error: Outcome specified as binary but does not have two levels"
			exit 198
		}
		quietly logit `varlist'
		predict double _resid, residuals
		di as result "Logistic regression was performed"
	}
	else if "`outcometype'" == "count" | "`outcometype'" == "Count" {
		quietly tab `outcome'
		if `r(r)' <= 1 {
			di as error "Error: Outcome does not have enough variability!"
			exit 198
		}
		quietly poisson `varlist'
		predict double _resid, residuals
		di as result "Poisson regression was performed"
	}
	else {
		di as err "Error: Invalid outcometype specification; must be either continuous, binary, or count"
		exit 198
	}
	
	qui tempfile _temp
    qui save "`_temp'"
	local nvar: word count `clustername'
	tokenize `clustername'
	/* average residual by cluster */
	forval i=1/`nvar' {
		bys ``i'': egen _residmn = mean(_resid)
		egen _tag = tag(``i'')
	}
	
	quietly tab _tag
	if `r(r)' == 1 {
		di as err "Error: Data is at the cluster-level!  cptest requires individual-level data"
		exit 198
	}
	
	quietly keep if _tag == 1
	keep _residmn
	
	
	local spacedat "use `cspacedatname', clear"
	
	quietly cd "`directory'"

	mata: ptest("`spacedat'")
	use "`_temp'", clear
	
	return scalar pval=pval[1,1]
	
	/* drop residuals */
	capture drop _resid _residmn
	
	restore
	
end


capture mata: mata drop ptest()
mata:
matrix ptest(string scalar spacedat) {

//stata(resdat)
res=st_data(.,.,0)

stata(spacedat)
stata("drop chosen_scheme RzSpaceRow Bscores")
stata("quietly recode * (0=-1)")
st_view(cspace=.,.,.)

// column matrix of test statistics
teststat=abs(cspace*res)

stata(spacedat)
stata("quietly keep if chosen_scheme==1")
stata("quietly drop chosen_scheme RzSpaceRow Bscores")
chosen=st_data(1,.)'
printf("Final chosen scheme used by the cptest program:")
printf(" \n")
printf(" \n")
chosen

stata(spacedat)
stata("quietly keep chosen_scheme")
stata("gen obs=_n")
stata("quietly keep if chosen_scheme==1")
stata("quietly keep obs")
cspacerow=st_data(.,.)

// null test statistic, based on chosen scheme
null = teststat[cspacerow,.]
indmat = teststat :> null

pval = mean(indmat)
printf(" \n")
printf("Clustered permutation test p-value = %9.4f\n",pval)
printf("Note: test may be anti-conservative if number of intervention clusters does not equal number of control clusters")

st_matrix("pval",pval)

}
end

