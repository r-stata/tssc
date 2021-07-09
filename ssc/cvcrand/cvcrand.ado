*!version2.1 31JAN2020

/* -----------------------------------------------------------------------------
** PROGRAM NAME: CVCRAND
** VERSION: 2.1
** DATE: JANUARY 31, 2020
** -----------------------------------------------------------------------------
** CREATED BY: JOHN GALLIS, LIZ TURNER, FAN LI, HENGSHI YU
** -----------------------------------------------------------------------------
** PURPOSE: THIS PROGRAM ALLOWS THE USER TO PERFORM COVARIATE CONSTRAINED RANDOMIZATION, 
	WHICH IS PARTICULARLY WELL SUITED TO CLUSTER RANDOMIZED TRIALS WITH A SMALL
	NUMBER OF CLUSTERS
** -----------------------------------------------------------------------------
** OPTIONS: SEE HELP FILE
** -----------------------------------------------------------------------------
** MODIFIED: APRIL 16, 2018 - MINOR CODE FIX TO REMOVE OUTPUT OF NUMBER FROM ST_ADDVAR
** -----------------------------------------------------------------------------
** MODIFIED: MARCH 11, 2019 - NUMSCHEMES OPTION WASN'T NECESSARILY GIVING REPRODUCIBLE OUTPUT
								WITH BALANCE SCORE TIES; FIXED BY ADDING ROW NUMBER TO SORT() FUNCTION
							- ALSO ADDED A SEPARATE SORT ON ROW NUMBER AFTER SUBSETTING WHEN USING NUMSCHEMES OPTION,
								IN ORDER TO MATCH RESULTS BETWEEN PERCENTILE CUTOFFS AND NUMBER OF SCHEMES CUTOFFS
** -----------------------------------------------------------------------------
** MODIFIED: APRIL 08, 2019 - ADDED A CHECK FOR VALIDITY
							- REMOVED SUMMARIES USING "TABLE1".  USER CAN PRODUCE THEIR OWN SUMMARY STATISTICS AFTER THE FACT
							- CONSTRAINED DATA IS NOW AUTOMATICALLY SAVED.  USER CAN NO LONGER "OPT OUT" OF SAVING THIS DATA.
								- THIS DATASET NOW CONTAINS INFORMATION ON THE ROW OF THE RANDOMIZATION SPACE AND BSCORE
** -----------------------------------------------------------------------------
** MODIFIED: JANUARY 31, 2020 - MADE THE CHECK FOR VALIDITY OPTIONAL
** -----------------------------------------------------------------------------
*/

program define cvcrand, rclass
	version 14
	
	di "`clustername'"
	#delimit ;
	syntax varlist(min=1),
		ntotal_cluster(integer) ntrt_cluster(integer) [clustername(varname) categorical(varlist) stratify(varlist) balancemetric(string) cutoff(real 0.1) 
													numschemes(integer 0) NOsim size(integer 50000)  
													weights(numlist) seed(integer 12345) directory(string) savedata(string) savebscores(string) validitycheck]
	;
	
	#delimit cr
	
	marksample touse, novarlist
	quietly count if `touse'

	/* error if there are no observations in the dataset */
	if `r(N)' == 0 {
		error 2000
	}
	
	capt mata mata which mm_subsets()
	if _rc {
    di as error "mm_subsets() from -moremata- is required; click this link to install: {stata ssc install moremata:auto-install moremata} "
		exit 499
	}
	
	local controlnum =`ntotal_cluster' - `ntrt_cluster'
	/* message about number assigned to treatment and control */
	di as result "Number of clusters assigned to treatment is `ntrt_cluster'; number assigned to control is `controlnum'"
	di as result " "
	
	
	/* check if total number of clusters specified is equal to total number of observations in dataset */
	if `r(N)' != `ntotal_cluster' {
		di as err "Error: Number of observations in dataset does not equal number of clusters specified"
		exit 198
	}
	
	/* set default string; l2 is the default balance metric */
	if "`balancemetric'" == "" local balancemetric "l2"	
	
	
	/* set default dataset name for saved constrained space */
	if "`savedata'" == "" local savedata "constrained_space"	
	
	/* code to check if continuous and categorical variables are properly specified */
	local contlist : list varlist - categorical	
	local ncontvars: word count `contlist'
		tokenize `contlist'
		forval i=1/`ncontvars' {
			*http://www.stata.com/statalist/archive/2010-01/msg00814.html
			/* check if variable is numeric */
			capture confirm numeric variable ``i''
			if !_rc {
			}
			else {
				di as err "Error: Please specify string variable as categorical"
				exit 198
			}
			/* check number of levels the variable has */
			quietly tabulate ``i''
			if r(r) <= 4 {
				di as text "Warning: Variable ``i'' specified as continuous has 4 or fewer levels.  Are you sure this is a continuous variable?"
			}
		}
			
	/* check if cutoff is a proportion */
	if `cutoff' < 0 | `cutoff' > 1 {
		di as err "Error: Cutoff out of range"
		exit 198
	}	
	
	/* check to make sure number in treatment clusters is less than total number of clusters */
	if `ntrt_cluster' >= `ntotal_cluster' {
		di as err "Error: Number of clusters in treatment greater than or equal to total number of clusters"
		exit 198
	}

	/* add error if user enters a categorical variable without specifying in varlist */
	 local checkcat: list categorical in varlist
	  if `checkcat'==0 {
		di as err "Error: Please specify categorical variable in varlist"
		exit 198
	}
	
	/* warnings about position of categorical variables */
	if "`categorical'" != "" {
		local length: list sizeof varlist
		local lengthcat: list sizeof categorical
		local checks
		local ncatvars: word count `categorical'
		tokenize `categorical'
		forvalues i=1/`ncatvars' {
			local pos: list posof "``i''" in varlist
			local checks "`checks' `pos'"
		}
		local finalcheck: list length in checks
		if `finalcheck' == 0 {
			di as err "Error: Please specify all categorical variables last in varlist"
			exit 198
		}
	}
	
	/* code to create dummy variables from categorical variables */
	if "`categorical'"!="" {
		local ncatvars: word count `categorical'
		tokenize `categorical'
		
		forval i=1/`ncatvars' {
			/* generate dummy variables */
			quietly tabulate ``i'', gen(``i''_)
			/* give warning if variable only has one level */
			if r(r) == 1 {
				di as text "--"
				di as text "Warning: variable ``i'' only has one level. It will not be used in the program"
				di as text "--"
			}
			/* drop one of the dummy variables */
			drop ``i''_1
			/* count number of dummy variables */
			local ``i''_num=r(r) - 1
			forval j=1/```i''_num' {
				local k=`j'+1
				local add "``i''_`k'"
				/* code that adds the dummy variables to `varlist' */
				local varlist : list varlist | add
			
			}
			/* code that removes categorical variables from varlist */
			local varlist : list varlist-categorical
		
		}
	}

	
	/* code to check that number of weights specified equals number of variables */
	if "`weights'"!="" {
		di "Note: when weights are used, all continuous variables should be specified in varlist before categorical variables"
		local varcnt: word count `varlist'
		local wtcnt: word count `weights'
		
		if "`varcnt'" != "`wtcnt'" {
			di as err "Error: Number of user-defined weights not equal to number of columns. Replicate weights for categorical variables with 3+ levels"
			exit 198
		}
	}
	
	/* code to check if stratification variables are specified as a categorical variables */
	local stratcheck: list stratify in categorical
	if `stratcheck' == 0 {
		di as err "Error: stratification variables must be specified as categorical"
		exit 198
	}
	
	if "`stratify'" != "" & "`weights'" != "" {
		di as err "Error: cannot specify both weights option and stratify option"
		exit 198
	}
	
	/* code to process stratification variables */
	if "`stratify'" != "" {
		di as err "You have specified the stratify option.  Please be sure the stratification variables are placed at the end of the overall variable list," 
		di as err "and last in the variable list of the categorical option."
		di " "
		local nstratvars: word count `stratify'
		tokenize `stratify'
		
		local A
		local newvarlist: list varlist - A
		
		/* obtain a list of stratification dummy variables */
		preserve
		forval i=1/`nstratvars' {		
			drop ``i''_*
			quietly tabulate ``i'', gen(``i''_)
			local ``i''_num=r(r) - 1
			drop ``i''_1
			
			forval j=1/```i''_num' {
				local k=`j'+1
				local addstrat "``i''_`k'"
				local newvarlist: list newvarlist - addstrat
			}
		}
		
		local stratvarlist: list varlist - newvarlist
		restore
		
		/* count the number of variables that aren't stratified */
		local nnostrat: word count `newvarlist'
		/* count the number of variables that are stratified */
		local nstrat: word count `stratvarlist'
		
		local weights
		
		/* create a numlist of weights, with weights of 1000 for stratification variables */
		forval i=1/`nnostrat' {
			local wtnostrat = 1 
			if `i' == 1 {
				local weights "`wtnostrat'"
			}
			else {
				local weights "`weights' `wtnostrat'"
			}
		}
		forval i=1/`nstrat' {
			local wtstrat = 1000
			local weights "`weights' `wtstrat'"
		}
	}
	
	/* force program not to simulate, regardless of the total number of clusters */
	if "`nosim'"=="nosim" {
		local sim=1
	}
	else {
		local sim=0
	}
	
	
	if "`balancemetric'" == "l2" {
		di as result "Using the l2 (squared) balance metric"
		di " "
	}
	else if "`balancemetric'" == "l1" {
		di as result "Using the l1 (absolute value) balance metric"
		di " "
	}
	else {
		di as err "Error: Invalid balance metric specification; specify either l1 or l2"
		exit 198
	}
	
	/* user-specified weights */
	if "`weights'"!="" {
		local wt=1
	}
	else {
		local wt=0
		local weights=0
	}
	
	local weights: subinstr local weights " " ", ", all
	
	if "`clustername'"!="" {
	}
	else {
		capture drop clustname
		gen clustname = _n
		tostring clustname, replace force
		local clustername "clustname"
	}
	
		if "`directory'"!="" {
			quietly cd "`directory'"
		}
		
		
	capture drop _allocation
	
	mata: constrained("`varlist'","`balancemetric'",`size',`ntotal_cluster',`ntrt_cluster',`cutoff',`sim',`seed',`wt',`numschemes',(`weights'))
	
	local cname "`clustername'"
	list `cname' _allocation, abb(20)
		
	if "`savebscores'" != "" {
		preserve
		local newvarname: di "Bscores"
		mata: bscoreout("`newvarname'","`varlist'","`balancemetric'",`size',`ntotal_cluster',`ntrt_cluster',`cutoff',`sim',`seed',`wt',`numschemes',(`weights'))
		if "`numschemes'" == "0" {
			local centilesnew = `cutoff'*100
		}
		else {
			count
			local centilesnew: di %6.2f `numschemes'/`r(N)'*100
			
		}
			/* only output histogram if weights are not specified */
			if "`weights'" == "0" & "`stratify'" == "" {
				if "`balancemetric'" == "l2" {
					quietly centile Bscores, centile(`centilesnew')
					local forplot = r(c_1)
					quietly count
					local max = r(N)/11
					qui hist Bscores, xlab(0(15)150) frequency addplot(pci 0 `forplot' `max' `forplot') legend(label(1 "Balance Scores") label(2 "Cutoff"))
				}
				else if "`balancemetric'" == "l1" {
					quietly centile Bscores, centile(`centilesnew')
					local forplot = r(c_1)
					quietly count
					local max = r(N)/15
					qui hist Bscores, xlab(0(5)25) frequency addplot(pci 0 `forplot' `max' `forplot') legend(label(1 "Balance Scores") label(2 "Cutoff"))
				}
			}
		
		qui save "`savebscores'.dta", replace
		restore
	}
		
		/* create a local macro containing names for the columns, which equals the total number of clusters */
		forvalues i=1/`ntotal_cluster' {
			local numclust`i': di "col`i'"
		}
		
		
		local clustnum: di `ntotal_cluster'-1
		forvalues i=1/`ntotal_cluster' {
			*local j=`i'+1
			local numclust: list numclust | numclust`i'
		}
		
		local alloc: di "chosen_scheme"
		local numclust: list numclust | alloc
		
		/* APRIL 8, 2019 - ADDING BSCORES ONTO CONSTRAINED SPACE DATASET */
		local spacerow: di "RzSpaceRow"
		local numclust: list numclust | spacerow
		
		local bscore: di "Bscores"
		local numclust: list numclust | bscore

	preserve
	mata: datout("`numclust'","`varlist'","`balancemetric'",`size',`ntotal_cluster',`ntrt_cluster',`cutoff',`sim',`seed',`wt',`numschemes',(`weights'))
	rename col* cluster*
	qui save "`savedata'.dta", replace
	restore
	
	/* APRIL 8, 2019 - VALIDITY CHECK |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
	*JAN 31, 2020 - MAKING IT OPTIONAL
	if "`validitycheck'" == "validitycheck" {
		preserve
		use "`savedata'.dta", clear
		qui des, short
		local totclust = r(k)- 3
		qui count
		local totrows = r(N)
			unab myvars: cluster1-cluster`totclust'
			local j=1
			foreach var1 of varlist cluster1-cluster`totclust' {
				local myvars : list myvars - cluster1
				
				local k=1
				foreach var2 of local myvars { 
					if `k' > `j' {
						quietly {
							gen `var1'`var2' = `var1' - `var2'
							gen samecount`j'`k' = 2 if `var1'`var2' != 0
							replace samecount`j'`k' = 1 if `var1'`var2' == 0
							replace samecount`j'`k' = 0 if samecount`j'`k' == 2
							gen sameprop`j'`k' = samecount`j'`k'
							
							gen diffcount`j'`k' = 1 if `var1'`var2' != 0
							replace diffcount`j'`k' = 0 if `var1'`var2' == 0
							gen diffprop`j'`k' = diffcount`j'`k'
							
							gen clustercombo`j'`k' = "`j'_`k'"
							drop `var1'`var2'
						}	
					}
				local ++k
				}
			local ++j
			}
			
		quietly {
			drop chosen_scheme cluster1-cluster`totclust'
			collapse (sum) samecount* diffcount* (mean) sameprop* diffprop* (first) clustercombo*
			gen id = 1
			reshape long samecount diffcount sameprop diffprop clustercombo, i(id) j(j)
			drop i j
			order clustercombo samecount sameprop diffcount diffprop
		}
		di "                                "
		di " ****************************** "
		di " ******* VALIDITY CHECKS ****** "
		di " ****************************** "
		di " "
		di "sameprop: Proportion of times in the constrained space clusters are paired together"
		di "diffprop: Proportion of times in the constrained space clusters are not paired"
		di " "
		tabstat sameprop diffprop, stat(mean sd min p25 med p75 max) col(stat) long format(%9.2f)
		
		qui save "`savedata'_vc.dta", replace
		restore
	}

	
	/* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
	
	
	/* drop dummy variables from the dataset */
	if "`categorical'"!="" {
		local ncatvars: word count `categorical'
		tokenize `categorical'
		
		forval i=1/`ncatvars' {
			quietly tabulate ``i'',
			local ``i''_num=r(r) - 1
			forval j=1/```i''_num' {
				local k=`j'+1
				local add "``i''_`k'"
				/* code that drops the dummy variables  */
				drop `add'
			}
			
		}
	}
end


/* ///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////// mata program: BSCOREOUT /////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////// */
mata:
matrix bscoreout(string scalar Bscores, string scalar varlist, string scalar metric,  scalar s,scalar cln, scalar trt, scalar cut, scalar nosims, scalar seed, scalar wt, scalar numschemes, real vector weights) {
combn=comb(cln,trt)
if (combn<50000 | nosims==1) {
		// matrix of 0's 
		pmt=J(combn,cln,0)
		
		combn_mat=mm_subsets(cln,trt)'

		for (i=1; i<=combn; i++) {
			for (k=1; k<=cols(combn_mat); k++) {
				pmt[i,combn_mat[i,k]]=1
			}
		}
		
		x=st_data(.,tokens(varlist))
		
		st_dropvar(.) 
		
		covarmeans=mean(x)
		y=covarmeans
		for (i=2; i<=cln; i++) {
			y=y\covarmeans[1,.]
		}
		
		numerator=x:-y
		
		if (wt==1) {
			p=weights
			numerator2=numerator*diag(p)
		}
		
		covarsds=sqrt(diagonal(quadvariance(x)))'
		z=covarsds
		for (i=2; i<=cln; i++) {
			z=z\covarsds[1,.]
		}
		
		denominator=z
		
		if (metric=="l2") {
			if (wt==1) {
			Bscore=((1::rows(combn_mat)),rowsum((pmt*(numerator2:/denominator)):^2))
			qbscore = mm_quantile(rowsum((pmt*(numerator2:/denominator)):^2),2,cut)
		
			}
			else {
			Bscore=((1::rows(combn_mat)),rowsum((pmt*(numerator:/denominator)):^2))
			
			qbscore = mm_quantile(rowsum((pmt*(numerator:/denominator)):^2),2,cut)
			}
		}
		
		else if (metric=="l1") {
			if (wt==1) {
			Bscore=((1::rows(combn_mat)),rowsum(abs(pmt*(numerator2:/denominator))))

			qbscore = mm_quantile(rowsum(abs(pmt*(numerator2:/denominator))),2,cut)
		
			}
			else {
			Bscore=((1::rows(combn_mat)),rowsum(abs(pmt*(numerator:/denominator))))
	
			qbscore = mm_quantile(rowsum(abs(pmt*(numerator:/denominator))),2,cut)
			}
		}
		if (numschemes<=0) {
			subset_bscore=select(Bscore,Bscore[.,2]:<=qbscore)
		}
		else if (numschemes>0) {
			sortB=sort(Bscore,(2,1))
			subset_bscore2=sortB[1..numschemes,.]
			subset_bscore=sort(subset_bscore2,1)
		}
		
		
		final=pmt[subset_bscore[.,1],]
		

		final3=Bscore[.,2]
			
		st_addobs(rows(Bscore))
	
		varidx = st_addvar("double", tokens(Bscores))
		st_store(.,varidx,final3)
	}
	else {

		pmt=J(s,cln,0)
		
		cl=(1..cln)'
		
		rseed(seed)
		for (i=1; i<=s; i++) {
			trtmnt=mm_srswor(trt,rows(cl))'
			for (k=1; k<=cols(trtmnt); k++) {
				pmt[i,trtmnt[1,k]]=1
			}
		}
		
		if (mm_nuniqrows(pmt) < s) pmt2=uniqrows(pmt)
		else pmt2=pmt
		
		x=st_data(.,tokens(varlist))
		
		st_dropvar(.) 
		
		covarmeans=mean(x)
		y=covarmeans
		for (i=2; i<=cln; i++) {
			y=y\covarmeans[1,.]
		}
		
		numerator=x:-y
		
		// one weight for each column
		if (wt==1) {
			p=weights
			numerator2=numerator*diag(p)
		}
		
		
		covarsds=sqrt(diagonal(quadvariance(x)))'
	
		z=covarsds
		for (i=2; i<=cln; i++) {
			z=z\covarsds[1,.]
		}
		
		denominator=z
		
		// l2
		// adding an "id" column to the Bscore matrix
		// only need this code if we keep the code which outputs the row of the matrix
		if (metric=="l2") {
			if (wt==1) {
			Bscore=((1::rows(pmt2)),rowsum((pmt2*(numerator2:/denominator)):^2))

			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum((pmt2*(numerator2:/denominator)):^2),2,cut)
		
			}
			else {
			Bscore=((1::rows(pmt2)),rowsum((pmt2*(numerator:/denominator)):^2))
			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum((pmt2*(numerator:/denominator)):^2),2,cut)
			}
		}
		//l1: Absolute value
		else if (metric=="l1") {
			if (wt==1) {
			Bscore=((1::rows(pmt2)),rowsum(abs(pmt2*(numerator2:/denominator))))

			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum(abs(pmt2*(numerator2:/denominator))),2,cut)
		
			}
			else {
			Bscore=((1::rows(pmt2)),rowsum(abs(pmt2*(numerator:/denominator))))
			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum(abs(pmt2*(numerator:/denominator))),2,cut)
			}
		}
		
		
		// subset the dataset to those observations below the quantile 
		if (numschemes<=0) {
			subset_bscore=select(Bscore,Bscore[.,2]:<=qbscore)
		}
		
		// subset based on number of schemes
		else if (numschemes>0) {
			sortB=sort(Bscore,(2,1))
			subset_bscore2=sortB[1..numschemes,.]
			subset_bscore=sort(subset_bscore2,1)
		}
		
		
		final=pmt2[subset_bscore[.,1],]

		choice=mm_srswor(1,rows(subset_bscore))'
		

		final3=Bscore[.,2]
		
			
		st_addobs(rows(Bscore))

		varidx = st_addvar("double", "Bscores")
		
		st_store(.,varidx,final3)
	
		
	}
}
end
/* /////////////////////////////////////////////////////////////////////////////////////////////////// */

/* ///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////// mata program: DATOUT ///////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////// */
mata:
matrix datout(string scalar numclust,string scalar varlist, string scalar metric,  scalar s,scalar cln, scalar trt, scalar cut, scalar nosims, scalar seed, scalar wt, scalar numschemes, real vector weights) {
combn=comb(cln,trt)
if (combn<50000 | nosims==1) {
		// matrix of 0's 
		pmt=J(combn,cln,0)
		
		combn_mat=mm_subsets(cln,trt)'

		for (i=1; i<=combn; i++) {
			for (k=1; k<=cols(combn_mat); k++) {
				pmt[i,combn_mat[i,k]]=1
			}
		}
		
		x=st_data(.,tokens(varlist))
		
		st_dropvar(.) 
		
		covarmeans=mean(x)
		y=covarmeans
		for (i=2; i<=cln; i++) {
			y=y\covarmeans[1,.]
		}
		
		numerator=x:-y
		
		if (wt==1) {
			p=weights
			numerator2=numerator*diag(p)
		}
		
		covarsds=sqrt(diagonal(quadvariance(x)))'
		z=covarsds
		for (i=2; i<=cln; i++) {
			z=z\covarsds[1,.]
		}
		
		denominator=z
		
		if (metric=="l2") {
			if (wt==1) {
			Bscore=((1::rows(combn_mat)),rowsum((pmt*(numerator2:/denominator)):^2))
			qbscore = mm_quantile(rowsum((pmt*(numerator2:/denominator)):^2),2,cut)
		
			}
			else {
			Bscore=((1::rows(combn_mat)),rowsum((pmt*(numerator:/denominator)):^2))
			
			qbscore = mm_quantile(rowsum((pmt*(numerator:/denominator)):^2),2,cut)
			}
		}
		
		else if (metric=="l1") {
			if (wt==1) {
			Bscore=((1::rows(combn_mat)),rowsum(abs(pmt*(numerator2:/denominator))))

			qbscore = mm_quantile(rowsum(abs(pmt*(numerator2:/denominator))),2,cut)
		
			}
			else {
			Bscore=((1::rows(combn_mat)),rowsum(abs(pmt*(numerator:/denominator))))
	
			qbscore = mm_quantile(rowsum(abs(pmt*(numerator:/denominator))),2,cut)
			}
		}
		if (numschemes<=0) {
			subset_bscore=select(Bscore,Bscore[.,2]:<=qbscore)
		}
		else if (numschemes>0) {
			sortB=sort(Bscore,(2,1))
			subset_bscore2=sortB[1..numschemes,.]
			subset_bscore=sort(subset_bscore2,1)
		}
		
		final=pmt[subset_bscore[.,1],]
		
		rseed(seed)
		choice=mm_srswor(1,rows(subset_bscore))'
		
		// add a column to the final matrix with an indicator of
		//choice of randomization scheme.  Needed for later analysis 
		indmat=J(rows(final),1,0)
		indmat[choice,1]=1
		final3=(final,indmat,subset_bscore)
		
		st_addobs(rows(final3))
		varidx = st_addvar("double", tokens(numclust))
		st_store(.,varidx,final3)
	}
	else {

		pmt=J(s,cln,0)
		
		cl=(1..cln)'
		
		rseed(seed)
		for (i=1; i<=s; i++) {
			trtmnt=mm_srswor(trt,rows(cl))'
			for (k=1; k<=cols(trtmnt); k++) {
				pmt[i,trtmnt[1,k]]=1
			}
		}
		
		if (mm_nuniqrows(pmt) < s) pmt2=uniqrows(pmt)
		else pmt2=pmt
		
		x=st_data(.,tokens(varlist))
		
		st_dropvar(.)
		
		covarmeans=mean(x)
		y=covarmeans
		for (i=2; i<=cln; i++) {
			y=y\covarmeans[1,.]
		}
		
		numerator=x:-y
		
		// one weight for each column
		if (wt==1) {
			p=weights
			numerator2=numerator*diag(p)
		}
		
		
		covarsds=sqrt(diagonal(quadvariance(x)))'
	
		z=covarsds
		for (i=2; i<=cln; i++) {
			z=z\covarsds[1,.]
		}
		
		denominator=z
		
		// l2
		// adding an "id" column to the Bscore matrix
		// only need this code if we keep the code which outputs the row of the matrix
		if (metric=="l2") {
			if (wt==1) {
			Bscore=((1::rows(pmt2)),rowsum((pmt2*(numerator2:/denominator)):^2))

			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum((pmt2*(numerator2:/denominator)):^2),2,cut)
		
			}
			else {
			Bscore=((1::rows(pmt2)),rowsum((pmt2*(numerator:/denominator)):^2))
			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum((pmt2*(numerator:/denominator)):^2),2,cut)
			}
		}
		//l1: Absolute value
		else if (metric=="l1") {
			if (wt==1) {
			Bscore=((1::rows(pmt2)),rowsum(abs(pmt2*(numerator2:/denominator))))

			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum(abs(pmt2*(numerator2:/denominator))),2,cut)
		
			}
			else {
			Bscore=((1::rows(pmt2)),rowsum(abs(pmt2*(numerator:/denominator))))
			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum(abs(pmt2*(numerator:/denominator))),2,cut)
			}
		}
		
		
		// subset the dataset to those observations below the quantile 
		if (numschemes<=0) {
			subset_bscore=select(Bscore,Bscore[.,2]:<=qbscore)
		}
		
		// subset based on number of schemes
		else if (numschemes>0) {
			sortB=sort(Bscore,(2,1))
			subset_bscore2=sortB[1..numschemes,.]
			subset_bscore=sort(subset_bscore2,1)
		}
		
		
		final=pmt2[subset_bscore[.,1],]

		choice=mm_srswor(1,rows(subset_bscore))'
		
		// add a column to the final matrix with an indicator of
		//choice of randomization scheme.  Needed for later analysis 
		indmat=J(rows(final),1,0)
		indmat[choice,1]=1
	
		final3=(final,indmat,subset_bscore)
		
		st_addobs(rows(final3))
		varidx = st_addvar("double", tokens(numclust))
		st_store(.,varidx,final3)
		
	}
}
end
/* /////////////////////////////////////////////////////////////////////////////////////////////////// */
	
/* ///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////// mata program: CONSTRAINED //////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////// */
mata:
matrix constrained(string scalar varlist, string scalar metric,  scalar s,scalar cln, scalar trt, scalar cut, scalar nosims, scalar seed, scalar wt, scalar numschemes, real vector weights) {
	
//////////////////////////////////////////////////////////////////////////////////////	
// ENUMERATION ///////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
	combn=comb(cln,trt)
	if (combn<50000 | nosims==1) {
	
		// matrix of 0's ////////////////////////////////////////////
		pmt=J(combn,cln,0)
		
		// matrix of unique combinations ////////////////////////////
		combn_mat=mm_subsets(cln,trt)'
		

		// replace 0's with 1 based on unique combination ///////////
		for (i=1; i<=combn; i++) {
			for (k=1; k<=cols(combn_mat); k++) {
				pmt[i,combn_mat[i,k]]=1
			}
		}
		
		// read in data /////////////////////////////////////////////
		x=st_data(.,tokens(varlist))
		
		// obtain row means and replicate down column ///////////////
		covarmeans=mean(x)
		y=covarmeans
		for (i=2; i<=cln; i++) {
			y=y\covarmeans[1,.]
		}
		
		// numerator for the balance score ///////////////////////////
		numerator=x:-y
		
		// user-defined weights //////////////////////////////////////
		if (wt==1) {
			p=weights
			numerator2=numerator*diag(p)
		}
		
		// obtain row standard deviations and replicate down column //
		covarsds=sqrt(diagonal(quadvariance(x)))'
		z=covarsds
		for (i=2; i<=cln; i++) {
			z=z\covarsds[1,.]
		}
		
		// denominator for the balance score /////////////////////////
		denominator=z
		
		///////////////////////////////////////////////////////////////////
		// compute l2 balance metric //////////////////////////////////////
		///////////////////////////////////////////////////////////////////
		if (metric=="l2") {
			// weighted ///////////////////////////////////////////////////////////
			if (wt==1) {
			Bscore=((1::rows(combn_mat)),rowsum((pmt*(numerator2:/denominator)):^2))

			// obtain the "cutoff" quantile of the bscore distribution ////////////
			qbscore = mm_quantile(rowsum((pmt*(numerator2:/denominator)):^2),2,cut)
		
			}
			// unweighted //////////////////////////////////////////////////////////
			else {
			Bscore=((1::rows(combn_mat)),rowsum((pmt*(numerator:/denominator)):^2))
			
			// obtain the "cutoff" quantile of the bscore distribution /////////////
			qbscore = mm_quantile(rowsum((pmt*(numerator:/denominator)):^2),2,cut)
			}
		}
		
		///////////////////////////////////////////////////////////////////
		// compute l1 balance metric //////////////////////////////////////
		///////////////////////////////////////////////////////////////////
		else if (metric=="l1") {
			// weighted ///////////////////////////////////////////////////////////
			if (wt==1) {
			Bscore=((1::rows(combn_mat)),rowsum(abs(pmt*(numerator2:/denominator))))

			// obtain the "cutoff" quantile of the bscore distribution ////////////
			qbscore = mm_quantile(rowsum(abs(pmt*(numerator2:/denominator))),2,cut)
		 
			}
			// unweighted //////////////////////////////////////////////////////////
			else {
			Bscore=((1::rows(combn_mat)),rowsum(abs(pmt*(numerator:/denominator))))
	
			// obtain the "cutoff" quantile of the bscore distribution /////////////
			qbscore = mm_quantile(rowsum(abs(pmt*(numerator:/denominator))),2,cut)
			}
		}
		
		// subset the dataset to those observations below the quantile //
		// if not based on number of schemes ////////////////////////////
		if (numschemes<=0) {
			subset_bscore=select(Bscore,Bscore[.,2]:<=qbscore)
		}
		// subset based on number of schemes ////////////////////////////
		else if (numschemes>0) {
			sortB=sort(Bscore,(2,1))
			subset_bscore2=sortB[1..numschemes,.]
			subset_bscore=sort(subset_bscore2,1)
		}
		
	
		
			
		// take a random sample of the ones below the cutoff ////////////
		rseed(seed)
		choice=mm_srswor(1,rows(subset_bscore))'
		
		printf("{txt}Summary Stats{space 1}{c |}  Balance Score \n")
		printf("{hline 14}{c +}{hline 20}\n")
		printf("{txt}%13s {c |} {res}%9.2f\n","Mean", mean(Bscore[.,2]))
		printf("{txt}%13s {c |} {res}%9.2f\n","Std. Dev.", sqrt(quadvariance(Bscore[.,2])))
		printf("{txt}%13s {c |} {res}%9.2f\n","Min", colmin(Bscore[.,2]))
		printf("{txt}%13s {c |} {res}%9.2f\n","p5", mm_quantile(Bscore[.,2], 1, 0.05))
		printf("{txt}%13s {c |} {res}%9.2f\n","p10", mm_quantile(Bscore[.,2], 1, 0.10))
		printf("{txt}%13s {c |} {res}%9.2f\n","p20", mm_quantile(Bscore[.,2], 1, 0.20))
		printf("{txt}%13s {c |} {res}%9.2f\n","p25", mm_quantile(Bscore[.,2], 1, 0.25))
		printf("{txt}%13s {c |} {res}%9.2f\n","p30", mm_quantile(Bscore[.,2], 1, 0.30))
		printf("{txt}%13s {c |} {res}%9.2f\n","p50", mm_quantile(Bscore[.,2], 1, 0.50))
		printf("{txt}%13s {c |} {res}%9.2f\n","p75", mm_quantile(Bscore[.,2], 1, 0.75))
		printf("{txt}%13s {c |} {res}%9.2f\n","p95", mm_quantile(Bscore[.,2], 1, 0.95))
		printf("{txt}%13s {c |} {res}%9.2f\n","Max", colmax(Bscore[.,2]))
		
		printf(" \n")	
		
		if (numschemes<=0) {
			printf("Cutoff value = %9.2f\n",qbscore)
		}
		else if (numschemes>0) {
			printf("Cutoff value = %9.2f\n",colmax(subset_bscore[.,2]))
		}
		
		printf(" \n")
		printf("Value of selected balance score = %9.2f\n",subset_bscore[choice,2])
		
		printf(" \n")
		printf("Row of constrained matrix = %9.0f\n",choice)
		
		
		// output the row from the pmt matrix that this sampled scheme is //////
		final=pmt[subset_bscore[choice,1],]'
		
		// add "Final Scheme" back onto the dataset for reporting //////////////
		(void) st_addvar("float", ("_allocation"))
		st_store(., ("_allocation"),final[.,1] )
	}
	
//////////////////////////////////////////////////////////////////////////////////////	
// SIMULATION ///////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
	else {

		pmt=J(s,cln,0)
		cl=(1..cln)'
		
		rseed(seed)
		for (i=1; i<=s; i++) {
			trtmnt=mm_srswor(trt,rows(cl))'
			for (k=1; k<=cols(trtmnt); k++) {
				pmt[i,trtmnt[1,k]]=1
			}
		}
		
		if (mm_nuniqrows(pmt) < s) pmt2=uniqrows(pmt)
		else pmt2=pmt	
		
		
		x=st_data(.,tokens(varlist))
		
		covarmeans=mean(x)
		y=covarmeans
		for (i=2; i<=cln; i++) {
			y=y\covarmeans[1,.]
		}
		
		numerator=x:-y
		
		// one weight for each column
		if (wt==1) {
			p=weights
			numerator2=numerator*diag(p)
		}
		
		
		covarsds=sqrt(diagonal(quadvariance(x)))'
	
		z=covarsds
		for (i=2; i<=cln; i++) {
			z=z\covarsds[1,.]
		}
		
		denominator=z
		
		// l2
		// adding an "id" column to the Bscore matrix
		// only need this code if we keep the code which outputs the row of the matrix
		if (metric=="l2") {
			if (wt==1) {
			Bscore=((1::rows(pmt2)),rowsum((pmt2*(numerator2:/denominator)):^2))

			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum((pmt2*(numerator2:/denominator)):^2),2,cut)
		
			}
			else {
			Bscore=((1::rows(pmt2)),rowsum((pmt2*(numerator:/denominator)):^2))
			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum((pmt2*(numerator:/denominator)):^2),2,cut)
			}
		}
		//l1: Absolute value
		else if (metric=="l1") {
			if (wt==1) {
			Bscore=((1::rows(pmt2)),rowsum(abs(pmt2*(numerator2:/denominator))))

			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum(abs(pmt2*(numerator2:/denominator))),2,cut)
		
			}
			else {
			Bscore=((1::rows(pmt2)),rowsum(abs(pmt2*(numerator:/denominator))))
			// obtain the "cutoff" quantile of the bscore distribution
			// default right now is 0.2
			qbscore = mm_quantile(rowsum(abs(pmt2*(numerator:/denominator))),2,cut)
			}
		}
		
		
		// subset the dataset to those observations below the quantile 
		if (numschemes<=0) {
			subset_bscore=select(Bscore,Bscore[.,2]:<=qbscore)
		}
		
		// subset based on number of schemes
		else if (numschemes>0) {
			sortB=sort(Bscore,(2,1))
			subset_bscore2=sortB[1..numschemes,.]
			subset_bscore=sort(subset_bscore2,1)
		}
			
		
		// take a random sample of the ones below this subset 
		choice=mm_srswor(1,rows(subset_bscore))'
		
		
		printf("{txt}Summary Stats{space 1}{c |}  Balance Score \n")
		printf("{hline 14}{c +}{hline 20}\n")
		printf("{txt}%13s {c |} {res}%9.2f\n","Mean", mean(Bscore[.,2]))
		printf("{txt}%13s {c |} {res}%9.2f\n","Std. Dev.", sqrt(quadvariance(Bscore[.,2])))
		printf("{txt}%13s {c |} {res}%9.2f\n","Min", colmin(Bscore[.,2]))
		printf("{txt}%13s {c |} {res}%9.2f\n","p5", mm_quantile(Bscore[.,2], 1, 0.05))
		printf("{txt}%13s {c |} {res}%9.2f\n","p10", mm_quantile(Bscore[.,2], 1, 0.10))
		printf("{txt}%13s {c |} {res}%9.2f\n","p20", mm_quantile(Bscore[.,2], 1, 0.20))
		printf("{txt}%13s {c |} {res}%9.2f\n","p25", mm_quantile(Bscore[.,2], 1, 0.25))
		printf("{txt}%13s {c |} {res}%9.2f\n","p30", mm_quantile(Bscore[.,2], 1, 0.30))
		printf("{txt}%13s {c |} {res}%9.2f\n","p50", mm_quantile(Bscore[.,2], 1, 0.50))
		printf("{txt}%13s {c |} {res}%9.2f\n","p75", mm_quantile(Bscore[.,2], 1, 0.75))
		printf("{txt}%13s {c |} {res}%9.2f\n","p95", mm_quantile(Bscore[.,2], 1, 0.95))
		printf("{txt}%13s {c |} {res}%9.2f\n","Max", colmax(Bscore[.,2]))
		
		printf(" \n")		
		
		if (numschemes<=0) {
			printf("Cutoff value = %9.2f\n",qbscore)
		}
		else if (numschemes>0) {
			printf("Cutoff value = %9.2f\n",colmax(subset_bscore[.,2]))
		}
		
		printf("Value of selected balance score = %9.2f\n",subset_bscore[choice,2])
		
		
		printf(" \n")
		printf("Row of constrained matrix = %9.0f\n",choice)
		
		// output the row from the pmt matrix that this sampled scheme is
		final=pmt2[subset_bscore[choice,1],]'
		
		(void) st_addvar("float", ("_allocation"))
		st_store(., ("_allocation"),final[.,1] )
		
		
		display("Note: The result is based on simulations")
	}
}
end
