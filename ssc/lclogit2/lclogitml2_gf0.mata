*! Author: Hong Il Yoo (h.i.yoo@durham.ac.uk) 
*! HIY 1.1.0 24 February 2019
version 13.1
mata:
void lclogitml2_gf0(M, todo, b, lnfj, S, H)
{
	//*******************************
	// Step 1. get things from Stata 
	//*******************************
	
	// [N x 1] vectors
	external id // subject id 
	external group // choice set id

	// scalars 
	external nclasses // # of classes	
	//external k_rand // # of random preference coefs
	//external k_membership // # of class share coefs (excl. const)
	external k_fix // # of fixed preference coefs	
	
	k_eq = 1 // scalar to keep running total of # of equations
	
	// [N x 1] vector of dependent variable
	Y = moptimize_util_depvar(M,1)
	
	// [N x nclasses] matrices of class-specific linear indices
	// Random preference indices	
	Xb_rand = moptimize_util_xb(M,b,k_eq) 
	k_eq = k_eq + 1
	for (c=2; c<=nclasses; c++) {
		Xb_rand = Xb_rand, moptimize_util_xb(M,b,k_eq)
		k_eq = k_eq + 1
	}	
	
	// Class share indices
	Xb_share = moptimize_util_xb(M,b,k_eq):*J(rows(id),1,1)
	k_eq = k_eq + 1
	if (nclasses > 2) {
		for (c=2; c<=nclasses-1; c++) {
			Xb_share = Xb_share, moptimize_util_xb(M,b,k_eq):*J(rows(id),1,1)
			k_eq = k_eq + 1 
		}	
	}
	Xb_share = Xb_share, J(rows(id),1,0) // index for last class's share is 0 (i.e. it's the base class) 
	
	// Fixed preference indices
	if (k_fix > 0) {
		Xb_fix = moptimize_util_xb(M,b,k_eq) :* J(rows(id),nclasses,1)
		k_eq = k_eq + 1
	}	
	k_eq = k_eq - 1 // subtract redundant 1 to get the correct total # of equations 
	
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

	//********************************
	// Step 3. Compute log-likelihood 
	//********************************
	// set up panel information: input is [N x 1] vector "id", and output is [N_subject x 2] matrix "subject"
	subject = panelsetup(id,1)

	// # of panel units (subjects), identified by number of rows in "panel"
	N_subject = panelstats(subject)[1]
	
	// initialise [N_subject x 1] vector of each subject's log-likelihood 
	lnfj = J(N_subject,1,.)
	
	// tell Stata that log-likelihood is computed at subject level
	moptimize_init_by(M,id)	
	
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
		
		// [1 x nclasses] vector of the likelihood of actual choice sequence
		ProbSeq_n = exp(quadcolsum(ln(Prob_n) :* Y_n,1))
	
		// compute subject n's log-likelihood
		lnfj[n,1] = ln(ProbSeq_n * Share_n[1,.]')
	}
}
mata mosave lclogitml2_gf0(), replace
end	

exit
