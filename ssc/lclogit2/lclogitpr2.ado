*! Author: Hong Il Yoo (h.i.yoo@durham.ac.uk) 
*! HIY 1.1.0 24 February 2019

program define lclogitpr2, sortpreserve
	version 13.1	
	if ("`e(cmd)'" != "lclogitml2")&("`e(cmd)'" != "lclogit2") error 301
	
	syntax newvarname [if] [in] [, CLass(numlist >=1 <=`=e(nclasses)') pr0 pr up cp ] 
	
	** Check whether specified options are valid **
	if ("`class'" != "") & ("`pr0'" != "") {
		display as error "class() and pr0 cannot be specified at the same time."
		exit 184
	}	
	
	local check : word count `pr0' `pr' `up' `cp'
	if (`check' > 1) {
		display as error "only one of pr0, pr, up and cp can be specified at a time." 
		exit 184
	}
	
	** Check that group, id and other explanatory variables are numeric **
	foreach v of varlist `e(group)' `e(id)' `e(indepvars)' `e(indepvars2)' {
		capture confirm numeric variable `v'
		if _rc != 0 {
			display as error "variable `v' is not numeric."
			exit 498
		}
	}
	
	if ("`class'" == "") {
		forvalues c = 1/`=e(nclasses)' {
			local class `class' `=int(`c')'
		}
	}
		
	** Mark the prediction sample **
	marksample touse, novarlist
	
	** Define temporary objects **
	tempvar one
	qui gen `one' = 1 if `touse'
	
	** Define variables ** 
	forvalues c = 1/`=e(nclasses)' {
		tempvar pr_`c'
		// temporary variable to hold some kind of probability for class c
		qui gen double `pr_`c'' = .
		local pr_all `pr_all' `pr_`c''  
	}
	if ("`up'" == "" & "`cp'" == "") {
		tempvar pr 
		// temporary variable to hold average choice probability over classes
		qui gen double `pr' = . 
		local pr_all `pr' `pr_all'
	}
	if ("`up'" != "") local pr_type = 1
	else if ("`cp'" != "") local pr_type = 2
	else local pr_type = 3
	
	** Define macros **
	local id `e(id)'
	local group `e(group)'
	
	local nclasses = e(nclasses)
	local k_fix = e(k_fix)
	local k_rand = e(k_rand)
	local k_membership = e(k_share)
	
	local depvar `e(depvar)'
	local rand `e(indepvars_rand)'
	local membership `e(indepvars_share)'
	if (`k_fix' > 0) local fix `e(indepvars_fix)'
	
	// send basic information to Mata
	sort `id' `group' 
	mata: st_view(id=.,.,st_local("id"),st_local("touse"))  // subject id
	mata: st_view(group=.,.,st_local("group"),st_local("touse")) // choice set id
	mata: nclasses = strtoreal(st_local("nclasses")) // # of classes	
	mata: k_fix = strtoreal(st_local("k_fix")) // # of fixed preference coefs
	mata: k_rand = strtoreal(st_local("k_rand")) // # of random preference coefs	
	mata: k_membership = strtoreal(st_local("k_membership")) // # of class share coefs (excl. const)
	
	// send data to Mata
	mata: st_view(Y=.,.,"`depvar'",st_local("touse"))
	mata: st_view(X_rand=.,.,"`rand'",st_local("touse"))
	mata: st_view(X_share=.,.,"`membership' `one'",st_local("touse"))
	if ("`fix'" != "") mata: st_view(X_fix=.,.,"`fix'",st_local("touse"))			
	
	// compute predicted probabilities
	mata: lclogitml2pr(st_matrix("e(b)"),"`pr_all'", "`touse'", `=int(`pr_type')')
	
	// keep predicted probabilities 
	if ("`pr0'" == "") {
		foreach c of numlist `class' {
			gen `typlist' `varlist'`c' = `pr_`c'' if `touse'
			if ("`up'" == "") label variable `varlist'`c' "prior probability of being in class `c'"
			if ("`cp'" == "") label variable `varlist'`c' "posterior probability of being in class `c'"
			if ("`pr'" == "") label variable `varlist'`c' "probability of choice if in class `c'"
		}
	}
	if ("`up'" == "" & "`cp'" == "") {
		gen `typlist' `varlist' = `pr' if `touse'
		label variable `varlist' "probability of choice unconditional on class"
	}
end

version 13.1
mata:
function lclogitml2pr(real rowvector b, string rowvector pr_all, string scalar touse, real scalar pr_type) 
{
	//*******************************
	// Step 1. get things from Stata 
	//*******************************
	
	// initialise matrix of predicted probabilities 
	// [N x nclasses] for pr_type = 1 (unconditional membership prob) or 2 (conditional membership prob)
	// [N x (1+nclasses)] for pr_type = 3 (choice prob)
	st_view(PR=.,.,pr_all,touse)	
	
	// [N x 1] vectors
	external id // subject id 
	external group // choice set id

	// scalars 
	external nclasses // # of classes	
	external k_rand // # of random preference coefs
	external k_membership // # of class share coefs (excl. const)
	external k_fix // # of fixed preference coefs	

	k_coef = 0 // scalar to keep running total of # of coefficients

	// [N x 1] vector of dependent variable
	external Y
	
	// [N x # of coefs] matrices of regressors 
	external X_rand
	external X_share
	if (k_fix > 0) external X_fix
	
	// break down b into parameter blocks
	b_rand = b[1,1..k_rand*nclasses]
	k_coef = k_coef + k_rand*nclasses 	
	b_share = b[1,(k_coef+1)..(k_coef+(k_membership+1)*(nclasses-1))]
	k_coef = k_coef + (k_membership+1)*(nclasses-1)	
	if (k_fix > 0) {
		b_fix = b[1,(k_coef+1)..(k_coef+k_fix)]
		k_coef = k_coef + k_fix
	}	
	
	// [N x nclasses] matrices of class-specific linear indices
	// Random preference indices	
	Xb_rand = X_rand * b_rand[1,1..k_rand]' 
	for (c=2; c<=nclasses; c++) {
		Xb_rand = Xb_rand, X_rand * b_rand[1,k_rand*(c-1)+1..k_rand*c]'
	}	
	
	// Class share indices
	Xb_share = X_share * b_share[1,1..(k_membership+1)]' 
	if (nclasses > 2) {
		for (c=2; c<=nclasses-1; c++) {
			Xb_share = Xb_share, X_share * b_share[1,(k_membership+1)*(c-1)+1..(k_membership+1)*c]' 
		}	
	}
	Xb_share = Xb_share, J(rows(id),1,0) // index for last class's share is 0 (i.e. it's the base class) 
	
	// Fixed preference indices
	if (k_fix > 0) Xb_fix = (X_fix * b_fix'):* J(rows(id),nclasses,1)
	
	//**********************************
	// Step 2. transform linear indices 
	//**********************************
	// [N x nclasses] matrices of transformed indices
	// EXP : exp(sig*v) where sig is the scale function and v is the preference index 
	if (k_fix == 0) Xb_pref = Xb_rand
	else Xb_pref = Xb_rand + Xb_fix
	
	EXP = exp(Xb_pref)
	
	// Share: class shares 
	Share = exp(Xb_share) :/ quadrowsum(exp(Xb_share),1) 

	// fill in class shares in case option up (pr_type = 1) has been specified 
	if (pr_type == 1) PR[.,.] = Share
	
	//**************************************************************
	// Step 3. Compute conditional probabilities and log-likelihood
	//**************************************************************
	// set up panel information: input is [N x 1] vector "id", and output is [N_subject x 2] matrix "subject"
	subject = panelsetup(id,1)

	// # of panel units (subjects), identified by number of rows in "panel"
	N_subject = panelstats(subject)[1]
	
	// initialise [N_subject x 1] vector of each subject's log-likelihood 
	//lnfj = J(N_subject,1,.)
	
	// loop over subjects
	for(n=1; n<=N_subject; n++) {
		// read in data rows pertaining to subject n & store in a matrix suffixed _n
		Y_n = panelsubmatrix(Y,n,subject)
		EXP_n = panelsubmatrix(EXP,n,subject)
		Share_n = panelsubmatrix(Share,n,subject)
		group_n = panelsubmatrix(group,n,subject) 
	
		// set up panel information where each panel unit refers to a choice set 
		task_n = panelsetup(group_n,1)
		
		// # of choice sets for subject n
		N_task_n = panelstats(task_n)[1]
		
		// initialise [N_n x nclasses] matrix of choice probabilities where N_n is # of data rows for subject n
		Prob_n = J(rows(Y_n),nclasses,.)
		
		// loop over choice sets
		for(t=1; t<=N_task_n; t++) {
			// read in data rows pertaining to choice set t
			EXP_nt = panelsubmatrix(EXP_n,t,task_n)
			
			// fill in choice probabilities	
			Prob_n[task_n[t,1]..task_n[t,2],.] = EXP_nt :/ quadcolsum(EXP_nt,1)
		}
		// fill in subjet n's predicted choice probabilities in case option pr or pr0 (pr_type = 3) has been specified
		if (pr_type == 3) PR[subject[n,1]..subject[n,2],.] = quadrowsum(Prob_n :* Share_n,1), Prob_n
		
		// [1 x nclasses] vector of the likelihood of actual choice sequence
		ProbSeq_n = exp(quadcolsum(ln(Prob_n) :* Y_n,1))
	
		// compute subject n's log-likelihood
		//lnfj[n,1] = ln(ProbSeq_n * Share_n[1,.]')
		
		// fill in subject n's conditional membership probabilities in case option cp (pr_type = 2) has been specified
		if (pr_type == 2) PR[subject[n,1]..subject[n,2],.] = (ProbSeq_n :* Share_n[1,.])/(ProbSeq_n * Share_n[1,.]') :* J(rows(Y_n),nclasses,1)
	}
	
	// return [1 x 1] sample log-likelihood 
	//return(quadcolsum(lnfj,1)) 	
}
end	
