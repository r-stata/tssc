*! version 1.2.0  21nov2014
program vselect, rclass
	version 11.1
	syntax varlist [if] [in]		/*
		*/ [fweight aweight pweight] [, /*   
		*/ NModels(string)		/*
		*/ fix(varlist fv ts)		/*
		*/ BEST				/*
		*/ BACKward			/*
		*/ FORward			/*
		*/ r2adj			/*
		*/ aic				/*
		*/ aicc				/*
		*/ bic]

	tempname prevest
	capture estimates store `prevest'
	//ensure fix and varlist don't contain same variables
	local kv: word count `varlist'
	local kf: word count `fix'
	forvalues i=1/`kv' {
		forvalues j=1/`kf' {
			local wv: word `i' of `varlist'
			local wf: word `j' of `fix'
			capture assert `"`wv'"' != `"`wf'"'
			if(_rc != 0) {
				di as error			 	///
				"{p 0 4 2} The fixed variables "	///
				"overlap with "			 	///
				"the predictors/response{p_end}"
				exit 198
			}
		}
	}
	if ("`best'" != "") {
		local x "backward forward c r2adj aic aicc bic"
		foreach lname of local x {
			capture assert "``lname''" == ""
			if (_rc != 0) {
				opts_exclusive "best `lname'"
			}
		}
		if "`nmodels'" != "" {
			capture assert `nmodels' >= 0 & ///
				round(`nmodels',1)==`nmodels'
			if _rc {
				di as error "option {bf:nmodels()} invalid;"
				di as error "only positive integers are " ///
					"allowed"
				exit 198
			}
		}
		else {
			local 0 `0' nmodels(1)
			local nmodels 1
		}   
		LeapsAndBounds `0'
		local k = r(k) 
		di as text "predictors for each model:" as result
		di ""
		forvalues i = 1/`k' {
			local j
			if `nmodels' > 1 {
				local j = 1
			}
			if "`r(best`i'`j')'" != "" {
				if(`i' < 10) {
					di as text "`i'  " ///
						as result `": `r(best`i'`j')'"'
				}		
				else {
					di as text "`i' " ///
						as result `": `r(best`i'`j')'"'
				}	
				return local best`i'`j' `"`r(best`i'`j')'"'
			}		
			if "`j'" != "" {
				local j = `j' + 1
				forvalues m = `j'/`nmodels' {
					if "`r(best`i'`m')'" != "" {
						if(`i' < 10) {
							local li= ///	
							length("`i'  ") + 1   
							di as result 	///
							_col(`li') 	///
							`": `r(best`i'`m')'"'
						}   
						else {
							local li= ///
							length("`i' ") + 1   
							di as result 	///
							_col(`li') 	///
							`": `r(best`i'`m')'"'
						}
						return local best`i'`m' ///
							`"`r(best`i'`m')'"'
					}
				}
			}
		}
		tempname info
		matrix `info' = r(info)
		return matrix info = `info'
		return local fix `"`fix'"'
		return local response `"`response'"'
		capture estimates restore `prevest'
	}
	else {
		if ("`backward'`forward'" == "") {
			di as error "{p 0 4 2} must specify exactly "	///
				"one of {bf:best}, {bf:backward}, or "	///
				"{bf:forward}{p_end}"
		}
		if ("`backward'" != "" & "`forward'" != "") {
				opts_exclusive "backward forward"	   
		}
		local x "`r2adj' `aic' `aicc' `bic'"
		local g: word count `x'
		capture assert `"`g'"' == "1"
		if (_rc != 0) {
			opts_exclusive "`r2adj' `aic' `aicc' `bic'"
			di as error "no information criteria specified"
			exit 198
		}
		StepCrit `0'
		return local predlist "`r(predlist)'"
	}
end

program StepCrit, rclass
	version 11.1
	syntax varlist [if] [in]			/*
		*/ [fweight  aweight  pweight] [,	/*
		*/ fix(varlist)				/*
		*/ BACKward				/*
		*/ FORward				/*
		*/ r2adj				/*
		*/ aic					/*
		*/ aicc					/*
		*/ bic]

	tokenize `varlist'
	capture assert "`2'" != ""
	if (_rc > 0) {
		noi di as error "varlist must have more than one predictor"
		exit 198
	}
	marksample touse
	if(`"`fix'"'!= "") {
		markout `touse' `fix'
	}
	// count missing values
	tempvar ifindic
	qui gen `ifindic' = 1 `if' `in'
	qui replace `ifindic' = 0 if `ifindic' == .
	qui count if `ifindic' == 1 & `touse'==0
	local b = r(N)
	if(`b' > 0) {
		noi di as text "{p 0 4 2}" `b' " observations containing " ///
			"missing predictor values{p_end}"
		noi di
	}
	noi di as text upper(`"`backward'`forward'"') " variable selection"
	noi di as text "Information Criteria: " ///
		upper(`"`r2adj'`aic'`aicc'`bic'"')
	noi di
	//set depvar to be dependent variable
	local depvar = "`1'"
	//and predlist to hold independent variables
	local predlist: subinstr local varlist "`depvar'" "", word all
	//and npreds as an index of the number of our predictors
	local npreds: word count `predlist'
	tokenize predlist
	qui reg `varlist' `fix' if `touse' [`weight' `exp']
	local totalmRSS = e(rss)/e(df_r)
	if ("`forward'" != "") {
		//prepredlist, hold predlist of previous iteration
		local prepredlist ""
		//list of predictors not used in previous iteration
		local prenirpredlist ""
		//no predictors initially in current
		local curpredlist ""
		local curnirpredlist "`predlist'"
		//preINFO, holds INFO of previous iteration
		local preINFO = .   
		//curINFO, holds INFO of current iteration
		//initialize curINFo with total regression
		qui reg `depvar' `fix' if `touse' [`weight' `exp']
		if ("`r2adj'" != "") {
			local curINFO = -e(r2_a)
		}
		else if ("`aic'" != "") {
			local curINFO = e(N)*ln(e(rss)/e(N)) +	 ///
				2*(e(N) - e(df_r)) +		 ///
				(e(N) + e(N)*ln(2*_pi))
		}
		else if ("`aicc'" != "") {
			local curINFO = e(N)*ln(e(rss)/e(N)) +  	///
					2*(e(N) - e(df_r)) +		///
					2*(e(df_m)+2)*(e(df_m)+3)/(	///
					e(N)- (e(df_m) + 2) - 1)  + (	///
					e(N) + e(N)*ln(2*_pi))
		}
		else if ("`bic'" != "") {
			local curINFO = e(N)*ln(e(rss)/e(N)) +		/// 
					ln(e(N))*(e(N) - e(df_r)) + 	///
					(e(N) + e(N)*ln(2*_pi))
		}
		local i = 0
		while (`curINFO' < `preINFO' & `i' < `npreds') {
			//reinitialize pre s
			local preINFO = `curINFO'
			local prepredlist "`curpredlist'"
			local prenirpredlist "`curnirpredlist'"
			//output previous iteration results to user
			noi di as text "{hline 78}"
			noi di "Stage `i' reg " subinstr(`"`depvar'"' +  ///
				" " + ltrim(`"`fix'"') + " " +	 	 ///
				ltrim(`"`curpredlist'"'),"  ", " ",.)	 ///
				" : " upper(`"`r2adj'`aic'`aicc'`bic'"') ///
				" " %9.0g `curINFO'
			noi di as text "{hline 78}"
			local i = `i' + 1
			//points to INFO for regression without 
			//variable at index
			//updated as min for each new regression performed
			local minINFO = .
			local minINFOindex = ""
			//search through curnirpredlist, doing regressions
			//with variable at index
			//update minINFO and minINFOindex
			foreach var of varlist `curnirpredlist' {
				local tempcurpredlist "`curpredlist' `var'"
				qui reg `depvar' `fix' `tempcurpredlist' ///
					if `touse' [`weight' `exp']
				if ("`r2adj'" != "") {
					local tempcurINFO = -e(r2_a)
				}
				else if ("`aic'" != "") {
					local tempcurINFO = e(N)*ln(e(rss)/ ///
						e(N)) +	2*(e(N) - e(df_r))  ///
						+ (e(N) + e(N)*ln(2*_pi))
				}
				else if ("`aicc'" != "") {
					local tempcurINFO = e(N)*ln(e(rss)/ ///
						e(N)) +	2*(e(N) - e(df_r))  ///
						+ 2*(e(df_m)+2)*(e(df_m)    ///
						+3)/ (e(N)-(e(df_m) + 2)    ///
						- 1) + (e(N) + e(N)*	    ///
						ln(2*_pi))
				}
				else if ("`bic'" != "") {
					local tempcurINFO = e(N)*ln(e(rss)/ ///
						e(N)) +	ln(e(N))*(e(N) -    ///
						e(df_r))  + (e(N) +	    ///
						e(N)*ln(2*_pi))
				}
				if (`minINFO' > `tempcurINFO') {
					local minINFO = `tempcurINFO'
					local minINFOindex = "`var'"
				}
				//show user affect of addition
				noi di upper(`"`r2adj'`aic'`aicc'`bic'"')  ///
					" "_column(7) %-9.0g `tempcurINFO' ///
					" :		 add " %10s "`var'"  
			}
			//update current to reflect search results
			local curINFO = `minINFO'
			local curpredlist "`curpredlist' `minINFOindex'"
			local curnirpredlist: subinstr local curnirpredlist ///
				"`minINFOindex'" "", word all
		}
		//output optimal results as estimates
		noi di ""
		noi di "Final Model"
		noi reg `depvar' `fix' `prepredlist' if ///
			`touse' [`weight' `exp']
		return local predlist `prepredlist'
	}
	if ("`backward'" != "") {
		//prepredlist, hold predlist of previous iteration
		local prepredlist ""
		//all predictors initially in
		local curpredlist "`predlist'"
		//preINFO, holds INFO of previous iteration
		local preINFO = .
		//curINFO, holds INFO of current iteration
		//initialize curINFO with total regression
		qui reg `varlist' `fix' if `touse' [`weight' `exp']
		if ("`r2adj'" != "") {
			local curINFO = -e(r2_a)
		}
		else if ("`aic'" != "") {
			local curINFO = e(N)*ln(e(rss)/e(N)) + 2*(e(N)	 ///
				- e(df_r)) + (e(N) + e(N)*ln(2*_pi))
		}
		else if ("`aicc'" != "") {
			local curINFO = e(N)*ln(e(rss)/e(N)) + 2*(e(N) - ///
				e(df_r)) + 2*(e(df_m)+2)*(e(df_m)+3)/(	 ///
				e(N)-(e(df_m) + 2) - 1)  + (e(N) + e(N)* ///
				ln(2*_pi))
		}
		else if ("`bic'" != "") {
			local curINFO = e(N)*ln(e(rss)/e(N)) + ln(e(N))*( ///
				e(N) - e(df_r)) + (e(N) + e(N)*ln(2*_pi))
		}
		local i = 0
		while (`curINFO' < `preINFO' & `i' < `npreds') {
   			//reinitialize preINFO
			local preINFO = `curINFO'
			//retinitialzie predpredlist
			local prepredlist "`curpredlist'"
			//output previous iteration results to user
			noi di as text "{hline 78}"
			noi di "Stage `i' reg " subinstr(`"`depvar'"' +   ///
				" " + ltrim(`"`fix'"') + " " + 		  ///	
				ltrim(`"`curpredlist'"'),"  ", " ",.)  	  ///
				" : "  upper(`"`r2adj'`aic'`aicc'`bic'"') ///
				" " %9.0g `curINFO'	
				noi di as text "{hline 78}"
			local i = `i' + 1
			//points to INFO for regression without variable
			//at index
			//updated as min for each new regression performed
			local minINFO = .
			local minINFOindex = ""
			//search through curpredlist, doing regressions
			//without variable at index
			//update minINFO and minINFOindex
			foreach var of varlist `curpredlist' {
				local tempcurpredlist: subinstr local ///
					curpredlist "`var'" "", word all
				qui reg `depvar' `fix' `tempcurpredlist' ///
					if `touse' [`weight' `exp']
				if ("`r2adj'" != "") {
					local tempcurINFO = -e(r2_a)
				}
				else if ("`aic'" != "") {
					local tempcurINFO = e(N)*ln(e(rss) ///
						/e(N)) + 2*(e(N)-e(df_r))  ///
						+ (e(N) + e(N)*ln(2*_pi))
				}
				else if ("`aicc'" != "") {
					local tempcurINFO = e(N)*ln(e(rss)/ ///
						e(N))+2*(e(N)-e(df_r)) +    ///
						2*(e(df_m)+2)*(e(df_m)+3)/  ///
						(e(N)-(e(df_m) + 2) - 1) +  ///
						(e(N) + e(N)*ln(2*_pi))
				}
				else if ("`bic'" != "") {
					local tempcurINFO = e(N)*ln(e(rss)/ ///
						e(N)) +	ln(e(N))*(e(N) -    ///
						e(df_r)) + (e(N) +	    ///
						e(N)*ln(2*_pi))
				}
				if (`minINFO' > `tempcurINFO') {
					local minINFO = `tempcurINFO'
					local minINFOindex = "`var'"
				}
				//show user affect of removal
				noi di upper(`"`r2adj'`aic'`aicc'`bic'"') ///
					" " _column(7) %-9.0g 		  ///
					`tempcurINFO' 			  ///
					" :		 remove " %10s	  ///
			 		"`var'"
			}
			//update current to reflect search results
			local curINFO = `minINFO'
			local curpredlist: subinstr local curpredlist ///
				"`minINFOindex'" "", word all
		}
		//output optimal results as estimates
		noi di ""
		noi di "Final Model"
		noi reg `depvar' `fix' `prepredlist' if ///
			`touse' [`weight' `exp']
		return local predlist `prepredlist'
	}
end


program LeapsAndBounds, rclass
	version 11.1
	syntax varlist [if] [in] 		/*
	*/	[fweight  aweight  pweight] [,	/*
	*/	fix(varlist fv ts)		/*
	*/	nmodels(string)			/*
	*/ 	best]
	preserve
	marksample touse
	if(`"`fix'"'!= "") {
		markout `touse' `fix'
	}
	// count missing values
	tempvar ifindic
	qui gen `ifindic' = 1 `if' `in'
	qui replace `ifindic' = 0 if `ifindic' == .
	qui count if `ifindic' == 1 & `touse'==0
	local b = r(N)
	if(`b' > 0) {
		noi di as text "{p 0 4 2}" `b' ///
		" observations containing missing predictor values{p_end}"
		noi di
	}
	tempvar weightvar
	if(`"`weight'"' != "") {
		//handle different types of weights
		if(`"`weight'"' == "fweight") {
			qui gen `weightvar' `exp'	   
		}
		if(`"`weight'"' == "aweight" | `"`weight'"' == "pweight") {
				qui gen `weightvar' `exp'   
			qui sum `weightvar'
			qui replace `weightvar' = r(N)*`weightvar'/	///
				(r(N)*r(mean))
		}
	}
	else {
		qui gen `weightvar' = 1
	}
	qui keep if `touse'
	// !! qui keep `varlist' `fix' `weightvar'
	return scalar N = _N
	//compressing things down for a moment
	//don't want to mess up our earlier preserve
	tempfile zefile
	qui save `zefile', replace
	local n : word count `varlist'
	//not counting the response or fixed
	local n = `n' - 1
	tokenize `varlist'
	local response "`1'"
	//order predictors by influence on regression sum of squares
	//1 is most influential
	//2 second
	//etc.
	qui reg `varlist' `fix'
	local x: word count "`varlist'"
	if (e(df_m) < `x') {
		di as error "design matrix not full rank"
		exit 198
	}
	forvalues i = 1/`n' {
		local j = `i' + 1
		qui test ``j'' = 0
		local var_`i'  "``j''"
		local zef_`i' = -r(F)
	}
	clear
	qui set obs `n'
	qui gen var = ""
	qui gen zef = .
	forvalues i = 1/`n' {
		qui replace var = "`var_`i''" if _n == `i'
		qui replace zef = `zef_`i'' if _n == `i'
	}
	sort zef
	local ordlist = ""
	forvalues i = 1/`n' {
		local a = var[`i']
		local ordlist "`ordlist' `a'"
	}
	qui use `zefile', clear

	local varlist "`response' `ordlist'"
	local predlist "`ordlist'"
	noi di 
	noi di as text `"Response :	        "' as result `"`response'"'
	if ("`fix'" != "") {
		noi di as text `"Fixed predictors :     "' as result `"`fix'"'
	}
	noi di as text `"Selected predictors:  "' as result `"`ordlist'"'
	fvexpand `fix'
	local expfix `r(varlist)'
	fvrevar `fix'
	local dfix `r(varlist)'
	local ffix
	local j = 1
	foreach lname of local dfix {
		local testf: word `j' of `expfix'
		_ms_parse_parts `testf'
		if ("`r(base)'" == "1" | "`r(omit)'" == "1") { 
			local lname 
		}
		local ffix `ffix' `lname'
		local j = `j' + 1
	}
	noi mata: leaps_bounds("`response'","`ffix'","`ordlist'", ///
		"`weightvar'",`nmodels')
	restore
end



mata:
struct node {
	//first subset of predictors
	rowvector p1
	//second subset of predictors
	rowvector p2
	//points to child nodes -
	//ith child has i-1 children
		//rules for getting predictors in children from previous work
			//first child of parent
			// subset 1 = parent's subset 2 - last predictor
			// subset 2 = parent's subset 2 - 2nd to last predictor
		//nth child of parent
		// subset 1 = (n-1)th child's subset 1 - last predictor
		// subset 2 = parent's subset 2 - (n+1) to last predictor
	pointer (struct node scalar) rowvector children
		//point to parent node
	pointer (struct node scalar) scalar parent
		//rss of subset 1 regression
	real scalar p1rss
		//X'X inverse for subset 1 regression
	real matrix p1i
		//rss of subset 2 regression
	real scalar p2rss
		//X'X inverse for subset 2 regression
	real matrix p2i
}

//returns a permutation matrix that will shift ith row/column to end
real matrix pm(real scalar i, real scalar n) {
	if(i != n) {
		Y = ((I(i-1),J(i-1,n-(i-1),0)) \ (J(1,n-1,0),1))
		Y = (Y \ (I(n-1)[i::(n-1),1::(n-1)],J(n-i,1,0)))
		return(Y)
	}
	else {
		return(I(n))
	}
}

real scalar nopossmiss(real matrix X, real scalar n)  {
	return(length(X) - missing(X) == n)
}

void leaps_bounds(string scalar response, string scalar fixlist,  ///
		  string scalar ordlist, string scalar weightvar, ///
		  real scalar nmodels) {
	w = st_data(.,weightvar)
	n = rows(w)
	tfixlist= tokens(fixlist)
	tf = cols(tfixlist)
	tordlist= tokens(ordlist)
	tk = cols(tordlist)
	intercCol = st_addvar("byte", st_tempname())
	st_store(.,intercCol,J(n,1,1))
	if (tf > 0) {
		D = st_data(.,(st_varindex(response), 	  ///
			intercCol, st_varindex(tfixlist), ///
			st_varindex(tordlist)))
	}
	else {
		D = st_data(.,(st_varindex(response), ///
			intercCol, st_varindex(tordlist)))
	}
	cm = cross(D,w,D)
	Best = J(tk,tk*nmodels,.)
	minRSS = J(tk,nmodels,.)
	fixXtXn1 = invsym(cross(D[.,2..(2+tf)],w,D[.,2..(tf+2)]))
	fixBeta = fixXtXn1* cross(D[.,2..(tf+2)],w,D[.,1])
	constRSS = cross((D[.,1]-cross(D[.,2..(tf+2)]',fixBeta)),	///
		w,(D[.,1]-cross(D[.,2..(tf+2)]',fixBeta)))
	fiINTtINT1 = invsym(cross(D[.,2],w,D[.,2]))
	intBeta =fiINTtINT1*cross(D[.,2],w,D[.,1])
	constRSSnofixed = cross((D[.,1]-cross(D[.,2]',intBeta)),w,	///
		(D[.,1]-cross(D[.,2]',intBeta)))
	run = 0
	//start through the tree
	struct node scalar root
	root.p2 = (1..tk)
	traverse(&root,&Best,&minRSS,&cm,.,constRSS,0,0,&run,tf,tk,nmodels)
	
	//models are ready now.
	stata("tokenize " + ordlist)
	// build model specification macros
	for(i=1;i<=tk;i++) {
		for(j=1;j<=tk;j++) {
			for(m=1;m<=nmodels;m++) {
				if (Best[i,j+(m-1)*tk] != 0 & ///
					Best[i,j+(m-1)*tk] !=.) {
					if(nmodels==1) {
						st_local("best" + 	///
						strofreal(i),st_local(	/// 
						"best" + strofreal(i)	///
						) + " " + 		///
						st_local(strofreal(Best[i,j])))
					}
					else {
						st_local("best" + 	  ///
							strofreal(i) + 	  ///
							strofreal(m), 	  ///
							st_local("best" + ///
							strofreal(i) + 	  ///
							strofreal(m)) 	  ///
							+ " " + st_local( ///
							strofreal(	  ///
							Best[i,j+(m-1)*tk])))
					}
				}
			}
 		}
	}
	//record information criteria
	fname = st_tempname()
	stata("tempfile " + fname)
	for(i=1;i<=nmodels;i++) {
		if (st_nobs() > tk) {
			stata("qui keep in 1/" + strofreal(tk))
		}
		else if (st_nobs() != tk) {
			stata("qui set obs " + strofreal(tk))
		}
		stata("capture drop npreds")
		stata("capture drop rss")
		stata("capture drop r2adj")
		stata("capture drop cp")
		stata("capture drop aic")
		stata("capture drop aicc")
		stata("capture drop bic")
		stata("capture drop nmodels")
		stata("qui gen byte nmodels = "+ strofreal(i))
		stata("qui gen byte npreds = _n")
		RSS = st_addvar("double","rss")
		st_store((1::tk),RSS,minRSS[,i])
		R2ADJ = st_addvar("double","r2adj")
		temp = (1::rows(minRSS)):+tf
		temp = (-temp) :+ n :- 1
		temp = (temp :^ -1) :* (n - 1)
		// fixed predictors shouldn't be used in constRSS
		// for R2adj calculation
		temp = (minRSS[,i]/constRSSnofixed):* temp
		temp = -temp :+ 1
		st_store((1::tk),R2ADJ,temp)
		C = st_addvar("double","cp")
		temp = (1::tk):+tf
		s2 = (minRSS[rows(minRSS),1]/(n-rows(minRSS)-tf-1))
		temp2 = temp :+ 1
		temp2 = temp2 :* 2
		temp2 = temp2 :- n
		temp3 = (minRSS[,i]:/s2)
		temp = temp2 :+ temp3
		mataC = temp
		st_store((1::tk),C,temp)
		AIC = st_addvar("double","aic")
		temp = (1::rows(minRSS)) :+tf
		temp = (-temp) :+ n :- 1
		temp = n*ln(minRSS[,i] :/ n) + (((-temp) ///
			:+ n) :*2)   :+ (n + n*ln(2*pi()))
		st_store((1::tk),AIC,temp)
		AICC = st_addvar("double","aicc")
		temp2 = (1::rows(minRSS)) :+tf
		temp2 = ((temp2 :+ 2) :* (temp2 :+ 3) :* 2) :/ ///
			(((temp2 :+ 2) :* -1) :+ n :- 1)
		temp = temp  :+  temp2
		st_store((1::tk),AICC,temp)
		BIC = st_addvar("double","bic")
		temp = (1::rows(minRSS)) :+ tf
		temp = (-temp) :+ n :- 1
		temp = n*ln(minRSS[,i] :/ n) + ln(n)*((-temp) ///
			:+ n) :+ (n + n*ln(2*pi()))
		st_store((1::tk),BIC,temp)
		if (i > 1) {
			stata("qui append using " + fname)
		}
		stata("qui save " + fname + ", replace")
	} 
	stata("sort npreds nmodels")
	stata("qui drop if rss == .")
	st_view(mataR2ADJ,.,"r2adj")
	st_view(mataC,.,"cp")	
	st_view(mataAIC,.,"aic")	
	st_view(mataAICC,.,"aicc")		
	st_view(mataBIC,.,"bic")
	st_view(matanpred,.,"npred")
	w=0
	maxindex(mataR2ADJ,1,matamaxR2ADJ,w)
	minindex(mataC,1,mataminC,w)
	minindex(mataAIC,1,mataminAIC,w)
	minindex(mataAICC,1,mataminAICC,w)
	minindex(mataBIC,1,mataminBIC,w)
	printf("\n{text}Optimal models: {result}\n\n")
	printf("   # Preds")
	printf("     R2ADJ")
	printf("         C")
	printf("       AIC")
	printf("      AICC")
	printf("       BIC\n")
	nobs = st_nobs()
	for(i=1; i <=nobs;i++) {
		//predictor size
		printf(" {result}%9.0g",matanpred[i,1])
		if(matamaxR2ADJ==i) {
			printf(" {result}%9.0g",mataR2ADJ[i,1])
		}
		else {
			printf(" {text}%9.0g",mataR2ADJ[i,1])
		}			
	   	printf(" {text}%9.0g",mataC[i,1])
		if(mataminAIC==i) {
			printf(" {result}%9.0g",mataAIC[i,1])
		}
		else {
			printf(" {text}%9.0g",mataAIC[i,1])
		}			
		if(mataminAICC==i) {
			printf(" {result}%9.0g",mataAICC[i,1])
		}
		else {
			printf(" {text}%9.0g",mataAICC[i,1])
		}			
		if(mataminBIC==i) {
			printf(" {result}%9.0g",mataBIC[i,1])
		}
		else {
			printf(" {text}%9.0g",mataBIC[i,1])
		}			
		printf("\n")
	}	   
	printf("\n")   
	for(i=1; i <= tk;i++) {
		if (nmodels > 1) {
			for(m=1;m<=nmodels;m++) {
			stata("return local best" + strofreal(i) + 	///
				strofreal(m) + " " + st_local("best" + 	///
				strofreal(i) + strofreal(m)))
			}
		}
		else {
			stata("return local best" + strofreal(i) + " " + ///
				char(34) + "`" + "best" + strofreal(i) + ///
				 "'" + char(34) )
		}
	}
	stata("return scalar k = " + strofreal(tk))
	stata("return scalar nmodels =" + strofreal(nmodels))
	baba = st_tempname()
	stata("mkmat npred rss r2adj cp aic aicc bic" + ///
		" in 1/" + strofreal(nobs) + ",matrix(" + baba + ")")
	stata("matrix colnames " + baba + "= k RSS R2ADJ C AIC AICC BIC")
	stata("return matrix info =" + baba)	
	stata("rm " + fname + ".dta")
}

//sn points current node,  we create nodes as we visit them in algorithm
//ONLY predictors of first and second subsets are initialized by parent
// traversal
//Best points to Best predictor list matrix (preds in row, padded with zeroes)
//minRSS points to the minimum RSS for predictor lists of size 1-p
//cm points to the correlation matrix of predictors and response
//(including intercept)
//	cm = (Y,X)'*(Y,X)
//cn is the child index of current node
//constRSS is the RSS for the regression on the intercept and fixed terms
//depth is the node depth
//forward = 0 indicates tree is being initialized with the root or first level.
//run is the iteration number of the tree search/generation algorithm
//tf number of fixed predictors
//	intercept is to the right of this
//tk number of predictors select on
void traverse(pointer(struct node scalar) scalar sn,	///
	pointer(real matrix) scalar Best, 		///
	pointer(real matrix) scalar minRSS, 		///
	pointer(real matrix) scalar cm, real scalar cn, ///
	real scalar constRSS, real scalar depth, 	///
	real scalar forward,				///   
	pointer (real scalar) scalar run, 		///
	real scalar tf,	real scalar tk, real scalar nmodels) {
	// 1.  Create node *sn and its information
	if(cn == .) {
		//root node
		//subset 1 is empty
		(*sn).p1 = J(1,0,.)
		//subset 2 is all predictors
		(*sn).p1rss = constRSS
		//X'X inverse, remember first row & column have 
		//response in them and then intercept and fixed predictors
		(*sn).p2i = invsym((*cm)[(2::cols(*cm)),(2::cols(*cm))])
		(*sn).p2rss = (*cm)[1,1] -((*cm)[(2::cols(*cm)),	///
			1])'*((*sn).p2i)*((*cm)[(2::cols(*cm)),1])
		(*sn).p2 = (1..rows(*minRSS))
	}
	else {
		//Child Node
		//Do first subset
		//ith child has i-1 children
		//rules for getting predictors in children from previous work
		//first child of parent
			//subset 1 = parent's subset 2 - last predictor
			//subset 2 = parent's subset 2 - 2nd to last predictor
		//nth child of parent
			//subset 1 = (n-1)th child's subset 1 - last predictor
			//subset 2 = parent's subset 2-(n+1) to last predictor
		//child node, predictor list already filled out
		//compute first subset's RSS and inverse
		if (cn == 1) {
			//first child
			//first subset predictors are from Parent second subset
				//by removing last predictor
			//so inverse is taken by corr. 2.2 LBOT
			X = (*((*sn).parent)).p2i
			xn = cols(X)			   
			(*sn).p1i = X[1::(xn-1),1::(xn-1)] - ///
				X[1::(xn-1),xn]*X[xn,1::(xn-1)]/X[xn,xn]
			//and RSS is y'Wy - etc.  (remember that y,
			//intercept start the matrix)
			//so adding two will make indices correspond correctly
			(*sn).p1rss = (*cm)[1,1] -		///
				(*cm)[((2..(tf+2)),((*sn).p1 :+ ///
				(tf+2))),1]' * ((*sn).p1i) *	///
				(*cm)[((2..(tf+2)),((*sn).p1 :+ ///
				(tf+2))),1]
		}
		else {
			//not first child
			//first subset predictors are from Parent second subset
				//by dropping the last (child # - 1) predictors
			//so inverse is direct application of corr. 2.2 LBOT
			X =(*((*sn).parent)).p2i
			(*sn).p1i = X[1::(cols(X)-cn),1::(cols(X)-cn)]-	 ///
				X[(1::(cols(X)-cn)),			 ///
				((cols(X)-cn+1)::cols(X))]* 		 ///
				invsym(X[((cols(X)-cn+1)::cols(X)),	 ///
				((cols(X)-cn+1)::cols(X))])*X[		 ///
				((cols(X)-cn+1)::cols(X)),(1::(cols(X)-cn))]
			//and RSS is y'Wy - etc. (remember that y, intercept
			//and fixed start the matrix)
			//so adding two will make indices correspond correctly
			(*sn).p1rss = (*cm)[1,1] -		 ///
				(*cm)[((2..(tf+2)),(*sn).p1 :+	 ///
				(tf+2)),1]' * (*sn).p1i*(*cm)[	 ///
				((2..(tf+2)),(*sn).p1 :+ (tf+2)),1]
		}
		//Do second subset
		//check second subset
			//compute second subset's RSS and inverse
		X = (*((*sn).parent)).p2i
		x = cols(X)
		Z = pm(x-cn,x)' * X * pm(x-cn,x)
		(*sn).p2i = Z[(1::(x-1)),(1::(x-1))] - ///
			Z[(1::(x-1)),x]*Z[(1::(x-1)),x]'/Z[x,x]
		(*sn).p2rss = (*cm)[1,1] -(*cm)[((2..(tf+2)),	///
			(*sn).p2 :+ (tf+2)),1]' * (*sn).p2i * 	///
			(*cm)[((2..(tf+2)),(*sn).p2 :+ (tf+2)),1]
	}
	//so first and second subset rss's are initialized
	//update minRSS and Best
	if (cols((*sn).p1) > 0) {
		potcols = min((comb((tk),(cols((*sn).p1))),nmodels))
		placed = 0
		for(i=1;i<=potcols;i++) {
			if (!placed & (*minRSS)[cols((*sn).p1),i] ///
				> (*sn).p1rss) {
				for(j=potcols;j>i;j--) {
					(*minRSS)[cols((*sn).p1),j] = ///
						(*minRSS)[cols((*sn).p1),j-1]
					(*Best)[cols((*sn).p1),		///
						(1+(j-1)*tk)::(tk+ 	///
						(j-1)*tk)] =		///
						(*Best)[cols((*sn).p1), ///
						(1+(j-2)*tk)::(tk+(j-2)*tk)]
				}
				(*minRSS)[cols((*sn).p1),i] = (*sn).p1rss
				(*Best)[cols((*sn).p1),			///
					(1+(i-1)*tk)::(tk+(i-1)*tk)] =  ///
					((*sn).p1,J(1,tk-cols((*sn).p1),0))
				placed = 1
			}
		}
	}
	placed = 0
	potcols = min((comb((tk),(cols((*sn).p2))),nmodels))
	for(i=1;i<=potcols;i++) {
		if (!placed & (*minRSS)[cols((*sn).p2),i] > (*sn).p2rss) {
			for(j=potcols;j>i;j--) {
				(*minRSS)[cols((*sn).p2),j] = ///
					(*minRSS)[cols((*sn).p2),j-1]
				(*Best)[cols((*sn).p2),(1+(j-1	///
					)*tk)::(tk+(j-1)*tk)] = ///
					(*Best)[cols((*sn).p2), ///
					(1+(j-2)*tk)::(tk+(j-2)*tk)]
			}
			(*minRSS)[cols((*sn).p2),i] = (*sn).p2rss
			(*Best)[cols((*sn).p2),(1+(i-1)*tk)::(	///
				tk+(i-1)*tk)] = 		///
				((*sn).p2,J(1,tk-cols((*sn).p2),0))
			placed = 1
		}
	}
	(*run) = (*run) + 2
	//2. 
	//create children of *sn
	//points to child nodes -
	//ith child has i-1 children
	//rules for getting predictors in children from previous work
	//first child of parent
	//	  subset 1 = parent's subset 2 - last predictor
	//	  subset 2 = parent's subset 2 - second to last predictor
	//nth child of parent
	//	  subset 1 = (n-1)th child's subset 1 - last predictor
	//	  subset 2 = parent's subset 2 - (n+1) to last predictor
	struct node children
	if(cn == .) {
		children = node(1,cols((*sn).p2)-1)
		(*sn).children = J(1,cols((*sn).p2)-1,NULL)
	}
	else if(cn > 1) {
		children  = node(1,cn-1)
		(*sn).children = J(1,cn-1,NULL)
	}
	if(cn != 1) {
		//we have children
		//first child predictor sets
		children[1,1].p1 = (*sn).p2[,(1::(cols((*sn).p2)-1))]
		if (cols((*sn).p2) > 2) {
			children[1,1].p2 = 				///
				(*sn).p2[,((1..(cols((*sn).p2)-2)),	///
				cols((*sn).p2))]
		}
		else {
			children[1,1].p2 = (*sn).p2[,cols((*sn).p2)]
		}
		//and parent
		children[1,1].parent = sn
		((*sn).children)[1,1] = &(children[1,1])
		//remaining child predictor sets, and parent
		for(i=2;i<=cols(children)-1;i++) {
			children[1,i].p1 = 		///
				(children[1,i-1]).p1[,	///
				(1::(cols(children[1,i-1].p1)-1))]
			children[1,i].p2 = (*sn).p2[,		///
				((1..(cols((*sn).p2)-		///
				(i+1))),((cols((*sn).p2)- 	///
				(i-1))..(cols((*sn).p2))))]
			children[1,i].parent = sn
			((*sn).children)[1,i] = &(children[1,i])
		}
		if (cols(children) > 1) {
			i = cols(children)
			children[1,i].p1 = 		///
				(children[1,i-1]).p1[,	///
				(1::(cols(children[1,i-1].p1)-1))]
			if(cols(children) == cols((*sn).p2)-1) {
				children[1,i].p2 = (*sn).p2[,	///
					(2::(cols((*sn).p2)))]
			}
			else {
				children[1,i].p2 = (*sn).p2[,		///
					((1..(cols((*sn).p2)-(i+1))), 	///
					((cols((*sn).p2)-(i-1))..(cols(	///
					(*sn).p2))))]
			}
			children[1,i].parent = sn
			((*sn).children)[1,i] = &(children[1,i])
		}
	}
	//things are setup, move to next stage
	if(cn==.) {
		// we are at root node, evaluate all child nodes
		for(i=1; i <= cols((*sn).children); i++) {
			traverse((*sn).children[1,i],Best,		///
				minRSS,cm,i,constRSS, depth+1,forward,	///
				run,tf,tk,nmodels)
		}
	}
	else {
		if (cols((*sn).children) > 0) {	 // we have children
			x = max((1, cols((*sn).p1)))
			potcols = min((comb((tk),(x)),nmodels))
			if (!nopossmiss((*minRSS)[x,],potcols) |
				(max((*minRSS)[x,]) > (*sn).p2rss)) {
				//we need to examine some of the 
				//descendants of the node, find the maximal 
				//k so that we can skip first k children
				//of the node
				ktoplim = cols((*sn).p2)-cols((*sn).p1) - 1
				maxk = 0
				for(k = 1; k <= ktoplim-1; k++) {
					potcols1 = min((comb((tk),	///
						(cols((*sn).p2)-k)),nmodels))
					potcols2 = min((comb((tk),	///
						(cols((*sn).p2)-k-1)),nmodels))
					if (k > maxk & 			///
						nopossmiss((*minRSS)[	///
						cols((*sn).p2)-k,],	///
						potcols1) & 		///
						max((*minRSS)[		///
						cols((*sn).p2)-k,]) <=  ///
						(*sn).p2rss &  		///
						nopossmiss((*minRSS)[	///
						cols((*sn).p2)-k-1,],	///
						potcols2) 		///
						& (*sn).p2rss < max(	///
						(*minRSS)[cols(		///
						(*sn).p2)-k-1,])) {
						maxk = k
					}
				}
				potcols1 = min((comb((tk),(cols((*sn).p2) ///
					-ktoplim)),nmodels))
				//handle k + 1 = cols((*sn).p2) case
				if (ktoplim > maxk &		///
					nopossmiss((*minRSS)[	///
					cols((*sn).p2)-ktoplim, ///
					],potcols1) & max(	///
					(*minRSS)[cols(		///
					(*sn).p2)-ktoplim,])	///
					<= (*sn).p2rss & 	///
					(*sn).p2rss < constRSS) {
					maxk = ktoplim
				}
				//we can skip the first maxk children
				// of the node
				for (i=maxk+1; i <= cols((*sn).children);i++) {
					traverse((*sn).children[1,i],Best, ///
						minRSS,cm,i, constRSS,	   ///
						depth+1,forward,run,tf,tk, ///
						nmodels)
				}
			}
			//kill all pointers in children
			for (i=1; i <=cols((*sn).children);i++) {
				(*((*sn).children[1,i])).parent = NULL
					((*sn).children)[1,i] = NULL
			}
		}
	}
}
end

exit


sysuse auto
vselect mpg weight trunk length foreign, best
vselect mpg weight trunk length foreign, best nmodels(1)
vselect mpg weight trunk length foreign, best nmodels(2)
vselect mpg weight trunk length foreign, best nmodels(3)
vselect mpg weight trunk length turn, best nmodels(4) fix(i.foreign)
