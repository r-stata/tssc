*! version 1.0.0  07apr2014
program gvselect, rclass
	version 11.2
	gettoken cmd rest : 0, parse(" <,")
	local l = strlen("`cmd'")
	if ("`cmd'"=="<") {
		tempname prevest
		capture estimates store `prevest'
		gvselect_prefix `0'
		local k = r(k)
		local nmodels = r(nmodels)
		di ""
		forvalues i = 1/`k' {
			local j
			if `nmodels' > 1 {
				local j = 1
			}
			if "`r(best`i'`j')'" != "" {
				if(`i' < 10) {
					di as text "{p 0 4 2}`i'  " ///
					as result `":`r(best`i'`j')'{p_end}"'
				}               
				else {
					di as text "{p 0 4 2}`i' " ///
					as result `":`r(best`i'`j')'{p_end}"'
				}       
			}               
			if "`j'" != "" {
				local j = `j' + 1
				forvalues m = `j'/`nmodels' {
					if "`r(best`i'`m')'" != "" {
						if(`i' < 10) {
							di as text 	 ///
							"{p 0 4 2}`i'  " ///						
							as result 	 ///
						     `":`r(best`i'`m')'{p_end}"'
						}   
						else {
							di as text 	///
							"{p 0 4 2}`i' " ///
							as result 	///
						     `":`r(best`i'`m')'{p_end}"'										
						}
					}
				}
			}			
		}
		return add
		capture estimates restore `prevest'
		exit
	}
	di as error "{p 0 4 2}syntax is {bf:gvselect <}{it:term}{bf:>} " ///
		"{bf:,} {it:options} {bf::} {it:est_cmd}{p_end}"
	exit 198
end

program gvselect_prefix, rclass
	local fullcmd `"gvselect `0'"'
	mata: _parse_colon("hadcolon", "estcmd")
	if (!`hadcolon') {
		di as err "syntax error"
		di as err "{p 4 4 2}"
		di as err "Colon not found."
		di as err "{p_end}"
		exit 198
	}
	syntax anything(id=term name=term everything) [, ///
		NModels(numlist min=1 max=1)]
	if "`nmodels'" == "" {
		local nmodels = 1
	}
	else {
		capture confirm integer number `nmodels'
		if _rc {
			di as error "{bf:nmodels()} must be a positive integer"
			exit 198
		}
		if `nmodels' < 1 {
			di as error "{bf:nmodels()} must be a positive integer"
			exit 198
		}
	}
	parse_term termname varnames : `"`term'"'
	local fullrun = subinstr(`"`estcmd'"',`"<`termname'>"',`"`varnames'"',.)
	gv_perform_run, cmd(`fullrun')
	tempname fullb fullV
	matrix `fullb' = e(b)
	matrix `fullV' = e(V)
	tempname llf aicf bicf
	scalar `llf' = e(ll)
	qui estat ic
	tempname tempmat
	matrix `tempmat' = r(S)
	scalar `aicf' = `tempmat'[1,5]
	scalar `bicf' = `tempmat'[1,6]
	capture drop _sample
	gen byte _sample = e(sample)
	label variable _sample "gvselect estimation sample"
	tempname prevest
	estimates store `prevest'
	preserve	
	local b = _N
	qui drop if !_sample
	if(`b'-_N > 0) {
		local a = `b' - _N
		noi di as text "{p 0 4 2}" `a' " observations containing " ///
			"missing predictor values{p_end}"
		noi di
	}
	tokenize `varnames'
	local w = wordcount("`varnames'")
	local rc = 0
	forvalues i = 1/`w' {
		capture qui test ``i'' = 0
		if (_rc) {
			local rc = _rc
			continue, break
		}		
		local test_`i' = -r(chi2)
		local varl `varl' ``i''
		local testl `testl' `test_`i''
	}
	if (!`rc') {
		sortit, wc(`w') varl("`varl'") testl("`testl'")
		local ordlist `r(ordlist)'
	}
	else {
		local ordlist 1/`w'
		numlist `ordlist', integer
		local ordlist `r(numlist)'
	}
	local initrun = subinstr(`"`estcmd'"',`"<`termname'>"',`"`ordlist'"',.)
	qui `initrun'
	tempname ll0 aic0 bic0
	scalar `ll0' = e(ll)
	qui estat ic
	matrix `tempmat' = r(S)
	scalar `aic0' = `tempmat'[1,5]
	scalar `bic0' = `tempmat'[1,6]
	mata: leaps_bounds("`ordlist'", `w', 			///
			"`ll0'", "`aic0'", "`bic0'", 		///
			"`llf'", "`aicf'", "`bicf'", `nmodels', ///
			"`termname'","`ordlist'","`estcmd'",	///
			"`fullb'","`fullV'","`e(vce)'")
	return add		
	local k = `w'
	di as text "predictors for each model:" as result
	restore
	capture estimates restore `prevest'			
end

program gv_perform_run
	syntax, cmd(string)
        ereturn clear
	mata: exit(_stata(`"qui `cmd'"')) 
	local w = word("`cmd'",1)
	if ("`e(cmd2)'"=="") {
		if ("`e(cmd)'"=="") {
			mata: error_not_eclass("`w'")
		}
	}
	mata: checkV("`w'") 
        if ("`e(vcetype)'"=="Jackknife") {
                capture noi error_cmd_notallowed jackknife pre
                exit 190
        }
        if ("`e(vcetype)'"=="Bootstrap") {
                capture noi error_cmd_notallowed bootstrap pre
                exit 190
        }
	mata: checkll("`w'")
end

program sortit, rclass 
	syntax, wc(string) varl(string) testl(string)
	preserve
	clear
	qui set obs `wc'
	qui gen var = ""
	qui gen testchi2 = .

	forvalues i = 1/`wc' {
		local var = word("`varl'",`i')
		local testchi2 = word("`testl'",`i')
		qui replace var = "`var'" if _n == `i'
		qui replace testchi2 = `testchi2' if _n == `i'
	}
	sort testchi2
	local ordlist = ""
	forvalues i = 1/`wc' {
		local a = var[`i']
		local ordlist "`ordlist' `a'"
	}
	restore
	return local ordlist `ordlist'
end

program parse_term
	args termnamemac varnamemac colon input nothing
	assert `"`nothing'"' == ""
	assert `"`colon'"' == ":"

	local input = strtrim(`"`input'"')
	if (substr(`"`input'"', 1, 1) != "<") {
		error_badterm `"`input'"'
	}
	local i = strpos(`"`input'"', ">")
	if (`i'==0) {
		error_badterm `"`input'"'
	}
	local termname = substr(`"`input'"', 2, `i'-2)
	capture fvexpand `termname'
	if (!_rc) {
		if ("`r(fvops)'" == "true") {
			di as error ///
				"factor variables not allowed for {it:term}"
			exit 198
		}
	}
	capture _ms_parse_parts `termname'
	if (!_rc) {
		if ("`r(ts_op)'" != "") {
			di as error ///
			"time-series operators not allowed for {it:term}"
			exit 198
		}
	}
	if wordcount("`termname'") > 1 {
		di as error ///
		"{p 0 1 2} only one word may be specified for {it:term}" ///
		" in {bf:<}{it:term}{bf:>}{p_end}"
		exit 198
	}
	capture confirm name `termname'
	local varnames = substr(`"`input'"',`i'+1,.)
	capture confirm numeric variable `varnames'	
	local 0 `varnames'
	syntax varlist
	c_local `termnamemac' "`termname'"
	c_local `varnamemac'  "`varnames'"
end

program error_badterm 
	args contents
	di as err `"{bf:`contents'} invalid"'
	di as err "    The syntax for a {it:term} is"
	di as err 
	di as err "         {bf:<}{it:termname}{bf:>}"
	di as err 
	di as err "    or"
	di as err 
	di as err ///
	"         {bf:<}{it:termname}{bf:>}{bf:(}{it:varname}{bf:)}"
	exit 198
end

program fitmodel, rclass
	syntax, [prednumlist(string)]	///
			termname(string) 		///
			varnames(string)		///
			estcmd(string)			///
			fullb(string)			///
			fullV(string)			///
			[vce(string)]			///
			npredlist(string)
	local predlist
	foreach lname of local prednumlist {
		local pred= word(`"`varnames'"',`lname')
		local predlist `predlist' `pred'
	}
	local zerolist: list npredlist - predlist
	tempname initb
	local run = subinstr(`"`estcmd'"',`"<`termname'>"',`"`predlist'"',.)
	ereturn clear
	if `"`vce'"' == "oim" {
		tempname init_b
		init_b `zerolist', fullb(`fullb') fullV(`fullV') ///
			initb(`init_b')
		capture qui `run', from(`init_b', skip)
		if _rc {
			capture qui `run' from(`init_b',skip)
		}
		if _rc {
			qui `run'
		}
		tempname eb eV
		matrix `eb' = e(b)
		matrix `eV' = e(V)
		return matrix b = `eb'
		return matrix V = `eV'
	}
	else {
		qui `run'
	}
	return scalar ll = e(ll)
	qui estat ic
	tempname tempmat
	matrix `tempmat' = r(S)
	return scalar aic = `tempmat'[1,5]
	return scalar bic = `tempmat'[1,6]
	return local npredlist `predlist'
end

program init_b
	syntax varlist, fullb(string) fullV(string) initb(string)
	local fnames: colnames `fullb'
	local n = colsof(`fullb')
	local zeroindices
	local oneindices
	local j = 1
	local k = 0
	foreach lname of local fnames {
		local there: list lname & varlist
		if "`there'" != "" {
			local zeroindices `zeroindices', `j'
		}
		else {
			local oneindices `oneindices', `j'
			local k = `k' + 1
		}
		local j = `j' + 1
	}
	local oneindices = substr("`oneindices'",2,.)
	local indices `oneindices'`zeroindices'
	tempname reordb reordV b1 b2 c12 c22n
	mata: st_matrix("`reordb'",st_matrix("`fullb'")[1,(`indices')])
	mata: st_matrix("`reordV'",	///
		st_matrix("`fullV'")[(`indices'),(`indices')])
	mata: st_matrix("`b1'",st_matrix("`reordb'")[1,(1..`k')]')
	mata: st_matrix("`c12'",	///
		st_matrix("`reordV'")[(1..`k'),((`k'+1)..(`n'))])
	mata: st_matrix("`c22n'",				///
		invsym(st_matrix("`reordV'")[((`k'+1)..(`n')),	///
			((`k'+1)..(`n'))]))
	mata: st_matrix("`b2'",st_matrix("`reordb'")[1,((`k'+1)..`n')]')	
	matrix `initb' = `b1' - `c12'*`c22n'*`b2'
	matrix `initb' = (`initb'\J(`n'-`k',1,0))'
	local fcnames: colfullnames `fullb'
	mata: st_matrix("`initb'",	///
		st_matrix("`initb'")[1, invorder((`indices'))])
	matrix colnames `initb' = `fcnames'
end
program error_cmd_notallowed
        args cmd pre
	di ""
        di as err "{bf:gvselect}: may not be combined with {bf:`cmd'}"
        di as err "{p 4 4 2}"
        if ("`pre'" != "") {
                di as err ///
      `""{bf:gvselect} ...{bf:: `cmd'}  ...{bf::} {it:est_cmd} ..." is not allowed."'
        }
        else {
                di as err ///
              `""{bf:gvselect} ...{bf:: `cmd'}  ..." is not allowed."'
        }
        di as err "{p_end}"
        exit 190
end

mata:

real scalar nopossmiss(real matrix X, real scalar n)  {
	return(length(X) - missing(X) == n)
}

void error_not_eclass(string scalar cmdname)
{
	errprintf("command " + cmdname + "not e-class\n")
	errprintf("It did not save estimation results in e().\n")
	errprintf("{p_end}\n")
	exit(301)
}

void checkV(string scalar cmdname) {
        if (st_matrix("e(V)")==J(0,0,.)) {
                errprintf("{p 0 0 2}\n")
                errprintf("estimation command {bf: ") 
                errprintf(cmdname)
                errprintf("} did not set {bf:e(V)}\n") 
                errprintf("{p_end}")
                exit(498)
        }
}

void checkll(string scalar cmdname) {
        if (st_numscalar("e(ll)") == J(0,0,.)) {
                errprintf("{bf:e(ll)} not reported by {bf:"+cmdname+"}\n")
                exit(498)
        }
}

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
		//neg log likelihood of subset 1 regression
	real scalar p1nll
		//aic for subset 1 regression
	real scalar p1aic
		//bic for subset 1 regression
	real scalar p1bic
		//neg log likelihood of subset 2 regression
	real scalar p2nll
		//aic for subset 2 regression
	real scalar p2aic
		//bic for subset 2 regression
	real scalar p2bic
}

struct gv {
	string scalar termname
	string scalar varnames
	string scalar estcmd
}

void leaps_bounds(string scalar ordlist, real scalar tk,		///
			string scalar ll0, string scalar aic0,		/// 
			string scalar bic0, string scalar llf,		///
			string scalar aicf, string scalar bicf,		///
			real scalar nmodels, string scalar termname, 	///
			string scalar varnames, string scalar estcmd,	///
			string scalar fullb, string scalar fullV,	///
			string scalar vce) {
	run = 0
	struct gv scalar gvs
	gvs.termname = termname
	gvs.varnames = varnames
	gvs.estcmd = estcmd
	//start through the tree
	struct node scalar root
	//root node
	//subset 1 is empty
	root.p1 = J(1,0,.)
	root.p1nll = -st_numscalar(ll0)
	root.p1aic = st_numscalar(aic0)
	root.p1bic = st_numscalar(bic0)
	//subset 2 is all predictors
	root.p2 = (1..tk)
	root.p2nll = -st_numscalar(llf)
	root.p2aic = st_numscalar(aicf)
	root.p2bic = st_numscalar(bicf)
	Best = J(tk,tk*nmodels,.)
	minnLL = J(tk,nmodels,.)
	minnLLAIC = J(tk,nmodels,.)
	minnLLBIC = J(tk,nmodels,.)
	traverse(&root,&Best,st_numscalar(ll0),&minnLL,&minnLLAIC, ///
		&minnLLBIC,0,&run,tk,nmodels,&gvs,.,fullb,fullV,vce,varnames)							
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
		stata("capture drop ll")
		stata("capture drop aic")
		stata("capture drop bic")
		stata("capture drop nmodels")
		stata("qui gen byte nmodels = "+ strofreal(i))
		stata("qui gen byte npreds = _n")
		LL = st_addvar("double","ll")
		st_store((1::tk),LL,-minnLL[,i])
		AIC= st_addvar("double","aic")
		st_store((1::tk),AIC,minnLLAIC[,i])
		BIC= st_addvar("double","bic")
		st_store((1::tk),BIC,minnLLBIC[,i])
		if (i > 1) {
			stata("qui append using " + fname)
		}
		stata("qui save " + fname + ", replace")
	} 
	stata("sort npreds nmodels")
	stata("qui drop if ll == .")
	st_view(mataLL,.,"ll")
	st_view(mataAIC,.,"aic")	
	st_view(mataBIC,.,"bic")
	st_view(matanpred,.,"npred")
	w=0
	maxindex(mataLL,1,matamaxLL,w)
	minindex(mataAIC,1,mataminAIC,w)
	minindex(mataBIC,1,mataminBIC,w)
	printf("\n{text}Optimal models: {result}\n\n")
	printf("   # Preds")
	printf("        LL")
	printf("       AIC")
	printf("       BIC\n")
	nobs = st_nobs()
	for(i=1; i <=nobs;i++) {
		printf(" {result}%9.0g",matanpred[i,1])
		printf(" {text}%9.0g",mataLL[i,1])
		if(mataminAIC==i) {
			printf(" {result}%9.0g",mataAIC[i,1])
		}
		else {
			printf(" {text}%9.0g",mataAIC[i,1])
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
	baba = st_tempname()
	stata("mkmat npred ll aic bic" + ///
		" in 1/" + strofreal(nobs) + ",matrix(" + baba + ")")
	stata("matrix colnames " + baba + "= k LL AIC BIC")
	st_rclear()
	stata("tokenize " + ordlist)
	// build model specification macros
	for(i=1;i<=tk;i++) {
		for(j=1;j<=tk;j++) {
			for(m=1;m<=nmodels;m++) {
				if (Best[i,j+(m-1)*tk] != 0 & ///
					Best[i,j+(m-1)*tk] !=.) {
					if(nmodels==1) {
						st_global("r(best" + 	///
						strofreal(i)+")",
						st_global("r(best" + 	///
						strofreal(i)+")") + " " +
						st_local(strofreal(Best[i,j])))
					}
					else {
						st_global("r(best" + 	  ///
							strofreal(i) + 	  ///
							strofreal(m)+")", ///	
							st_global("r(best" + ///
							strofreal(i) + 	  ///
							strofreal(m)+")") +  ///
							" " + st_local( ///
							strofreal(	  ///
							Best[i,j+(m-1)*tk])))
					}
				}
			}
 		}
	}
	st_matrix("r(info)",st_matrix(baba))
	st_matrixcolstripe("r(info)", ///
		(("","","","")',("k", "LL" ,"AIC", "BIC")'))
	stata("rm " + fname + ".dta")
	st_numscalar("r(k)",tk)
	st_numscalar("r(nmodels)",nmodels)
}

void fitmodel(real rowvector preds,				///
		pointer(struct gv scalar) scalar gvn,		///
		string scalar fullb, string scalar fullV,	///
		string scalar vce, string scalar npredlist) {
	string scalar predstr
	real scalar res
	if (length(preds) != 0) {
		predstr = invtokens(strofreal(preds))
	}
	else {
		predstr = ""
	}
	predstr = "fitmodel, prednumlist(" + predstr + ") termname(" + 	///
		(*gvn).termname + ") varnames(" + (*gvn).varnames + 	///
		") estcmd(" + (*gvn).estcmd + ") fullb(" + fullb + 	///
		") fullV(" + fullV + ") vce(" + vce + 			///
		") npredlist(" + npredlist + ")"
	res=_stata(predstr)
	if (res > 0) {
		exit(res)
	}
}

void traverse(pointer(struct node scalar) scalar sn,	///
		pointer(real matrix) scalar Best, 	///
		real scalar ll0,			///
		pointer(real matrix) scalar minnLL, 	///
		pointer(real matrix) scalar minnLLAIC, 	///
		pointer(real matrix) scalar minnLLBIC, 	///
		real scalar depth, 			///
		pointer (real scalar) scalar run, 	///
		real scalar tk, 			///
		real scalar nmodels,			///
		pointer(struct gv scalar) scalar gvn,	///
		real scalar cn, string scalar fullb,	///
		string scalar fullV, string scalar vce, ///
		string scalar npredlist) {
	nfullb = fullb
	nfullV = fullV
	// 1.  Create node *sn and its information
	if (cn != .) {
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
			fitmodel((*sn).p1,gvn,fullb,fullV,"",npredlist)
			(*sn).p1nll = -st_numscalar("r(ll)")
			(*sn).p1aic = st_numscalar("r(aic)")
			(*sn).p1bic =st_numscalar("r(bic)")
		}
		else {
			//not first child
			//first subset predictors are from Parent second subset
				//by dropping the last (child # - 1) predictors
			fitmodel((*sn).p1,gvn,fullb,fullV,"",npredlist)
			(*sn).p1nll = -st_numscalar("r(ll)")
			(*sn).p1aic = st_numscalar("r(aic)")
			(*sn).p1bic =st_numscalar("r(bic)")
		}
		//Do second subset
		fitmodel((*sn).p2,gvn,fullb,fullV,vce,npredlist)
		nfullb = st_tempname()
		nfullV = st_tempname()
		stata("matrix " + nfullb + "= r(b)")
		stata("matrix " + nfullV + "= r(V)")
		npredlist = st_global("r(npredlist)")
		(*sn).p2nll = -st_numscalar("r(ll)")
		(*sn).p2aic = st_numscalar("r(aic)")
		(*sn).p2bic =st_numscalar("r(bic)")
	}
	//so first and second subset ll's and ic's are initialized
	//update minnLL, minnLLAIC, minnLLBIC and Best
	if (cols((*sn).p1) > 0) {
		potcols = min((comb((tk),(cols((*sn).p1))),nmodels))
		placed = 0
		for(i=1;i<=potcols;i++) {
			if (!placed & (*minnLL)[cols((*sn).p1),i] ///
				> (*sn).p1nll) {
				for(j=potcols;j>i;j--) {
					(*minnLL)[cols((*sn).p1),j] = ///
						(*minnLL)[cols((*sn).p1),j-1]
					(*minnLLAIC)[cols((*sn).p1),j] = ///
						(*minnLLAIC)[cols((*sn).p1),j-1]
					(*minnLLBIC)[cols((*sn).p1),j] = ///
						(*minnLLBIC)[cols((*sn).p1),j-1]
					(*Best)[cols((*sn).p1),		///
						(1+(j-1)*tk)::(tk+ 	///
						(j-1)*tk)] =		///
						(*Best)[cols((*sn).p1), ///
						(1+(j-2)*tk)::(tk+(j-2)*tk)]
				}
				(*minnLL)[cols((*sn).p1),i] = (*sn).p1nll
				(*minnLLAIC)[cols((*sn).p1),i] = (*sn).p1aic
				(*minnLLBIC)[cols((*sn).p1),i] = (*sn).p1bic
				//(*Best)				
				(*Best)[cols((*sn).p1),			///
					(1+(i-1)*tk)::(tk+(i-1)*tk)] =  ///
					((*sn).p1,J(1,tk-cols((*sn).p1),0))
				//(*Best)	
				placed = 1
			}
		}
	}
	placed = 0
	potcols = min((comb((tk),(cols((*sn).p2))),nmodels))
	for(i=1;i<=potcols;i++) {
		if (!placed & (*minnLL)[cols((*sn).p2),i] > (*sn).p2nll) {
			for(j=potcols;j>i;j--) {
				(*minnLL)[cols((*sn).p2),j] = ///
					(*minnLL)[cols((*sn).p2),j-1]
				(*minnLLAIC)[cols((*sn).p2),j] = ///
					(*minnLLAIC)[cols((*sn).p2),j-1]
				(*minnLLBIC)[cols((*sn).p2),j] = ///
					(*minnLLBIC)[cols((*sn).p2),j-1]
				(*Best)[cols((*sn).p2),(1+(j-1	///
					)*tk)::(tk+(j-1)*tk)] = ///
					(*Best)[cols((*sn).p2), ///
					(1+(j-2)*tk)::(tk+(j-2)*tk)]
			}
			(*minnLL)[cols((*sn).p2),i] = (*sn).p2nll
			(*minnLLAIC)[cols((*sn).p2),i] = (*sn).p2aic
			(*minnLLBIC)[cols((*sn).p2),i] = (*sn).p2bic
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
			children[1,i].p1 = 			///
				(children[1,i-1]).p1[,		///
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
			traverse((*sn).children[1,i],Best,ll0, 	///	
				minnLL,minnLLAIC,minnLLBIC,	///
				depth+1,run,tk,nmodels,gvn,i,	///
				nfullb,nfullV,vce,npredlist)
		}
	}
	else {
		if (cols((*sn).children) > 0) {	 // we have children
			x = max((1, cols((*sn).p1)))
			potcols = min((comb((tk),(x)),nmodels))
			if (!nopossmiss((*minnLL)[x,],potcols) |
				(min((*minnLL)[x,]) > (*sn).p2nll)) {
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
						nopossmiss((*minnLL)[	///
						cols((*sn).p2)-k,],	///
						potcols1) & 		///
						max((*minnLL)[		///
						cols((*sn).p2)-k,]) <=  ///
						(*sn).p2nll &  		///
						nopossmiss((*minnLL)[	///
						cols((*sn).p2)-k-1,],	///
						potcols2) 		///
						& (*sn).p2nll < max(	///
						(*minnLL)[cols(		///
						(*sn).p2)-k-1,])) {
						maxk = k
					}
				}
				potcols1 = min((comb((tk),(cols((*sn).p2) ///
					-ktoplim)),nmodels))
				//handle k + 1 = cols((*sn).p2) case
				if (ktoplim > maxk &		///
					nopossmiss((*minnLL)[	///
					cols((*sn).p2)-ktoplim, ///
					],potcols1) & min(	///
					(*minnLL)[cols(		///
					(*sn).p2)-ktoplim,])	///
					<= (*sn).p2nll & 	///
					(*sn).p2nll < ll0) {
					maxk = ktoplim
				}
				//we can skip the first maxk children
				//of the node
				for (i=maxk+1; i <= cols((*sn).children);i++) {
				traverse((*sn).children[1,i],		///
					Best,ll0, minnLL,minnLLAIC,	///
					minnLLBIC, depth+1,run,tk,	///
					nmodels,gvn,i,nfullb,nfullV,	///
					vce,npredlist)
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
