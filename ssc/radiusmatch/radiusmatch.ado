*! radiusmatch 1.1.1 Andreas Steinmayr 18mar2014  
* Version 1.1.1
* - corrects a bug that p-values are not returned when "notstat" option is chosen

* Version 1.1
* - weights are normalized to equal the sum of treated/non-treated observations in the support (needed if pstest is used for balance tests)
* - allow clustered bootstrap
* - better warning if tknz package is not installed
* - caliper is returned in a scalar
* - capture errors due to zero common support in a bootstrap replication

*  Version 1.0.2
* - return estimation results in macro
* - logit bias correction only when variation in binary variable in observations with POSITIVE weights
* - option to avoid the calculation of analytical standard errors in each replication (saves computation time)
* - predict pscore only for observations that are selected by the if-statement

program define radiusmatch, rclass sortpreserve
	version 11.0
	#delimit ;
	syntax varlist(fv min=1) [if] [in] [,
	OUTcome(varlist)
	Pscore(varname numeric)
	CQUantile(real 90)
	CPErcent(real 300)
	MAHALanobis(varlist)
	SCOREweight(real 5)
	NOCommon
	MWEight(real 100)
	LOGIT
	INDEX
	DESCending
	ATE
	BC(integer 1)
	W(string)
	KNN
	BOOTstrap(integer 0)
	CLUSTER(varlist)
	BOOST
	BFile(string)
	NOTstat
	];
	#delimit cr

	// clear saved results
	return clear
	
	// Note: tknz needs to be installed
	capture which tknz
	if _rc==111 {
		display as error "Radiusmatch requires installation of the tknz command!"
		display as error "Type: ssc install tknz"
		exit
	}
	
	// determine subset we work on
	marksample touse
	capture markout `touse' `outcome' `control' `mahalanobis'
	
	if `bootstrap' == 0 {
		matchcore `varlist', out(`outcome') pscore(`pscore') cqu(`cquantile') cpe(`cpercent') mwe(`mweight') `knn' ///
		mahal(`mahalanobis') score(`scoreweight') touse(`touse') `index' `logit' `nocommon' `ate' bc(`bc') `boost' `notstat'
		_mktab, `ate' bc(`bc')
		return add

	}
	else if `bootstrap' > 0 {
		if ("`bfile'"=="") tempfile bfile
		tempname resfile res effeffbc
		
		/* 1. run in original sample */
		matchcore `varlist', out(`outcome') pscore(`pscore') cqu(`cquantile') cpe(`cpercent') mwe(`mweight') `knn' ///
		mahal(`mahalanobis') score(`scoreweight') touse(`touse') `index' `logit' `nocommon' `ate' bc(`bc') `boost' `notstat'
		
		matrix anyeff = r(effect)
		matrix anyeff_bc = r(effect_bc)
		matrix anyse = r(stderr)
		
		if ("`ate'"=="") matrix `res' = (r(atet), r(seatet), r(y1_atet), r(y0_atet))
		else matrix `res' = (r(atet), r(atent), r(ate), r(seatet), r(seatent), r(seate), r(y1_atet), r(y1_atent), r(y1_ate), r(y0_atet), r(y0_atent), r(y0_ate))
		local colnum = colsof(`res')
		local efname : coleq `res'
		local varname : colnames `res'
		return add
		
		tknz "`efname'", stub(tip)
		tknz "`varname'", stub(ovar)
		forvalues k = 1(1)`colnum' { 
			local elem = "`tip`k''" + "_" + "`ovar`k''"
			local vars `vars' `elem'
			local results `results' (`elem')
			scalar `elem' = `res'[1,`k']
		}
		capture: postfile `resfile' `vars' using "`bfile'", replace
		post `resfile' `results'
		
		display _newline
		_dots 0, title(Bootstrap replications) reps(`bootstrap')
		
		forvalues i = 1(1)`bootstrap' {
			timer on 4
			preserve
			bsample if `touse', cluster(`cluster')
			timer off 4
			quietly: matchcore `varlist', out(`outcome') pscore(`pscore') cqu(`cquantile') cpe(`cpercent') mwe(`mweight') `knn' ///
			mahal(`mahalanobis') score(`scoreweight') touse(`touse') `index' `logit' `nocommon' `ate' bc(`bc') `boost' `notstat' rep
			timer on 4

			if ("`ate'"=="") matrix `res' = (r(atet_rep), r(seatet_rep), r(y1_atet_rep), r(y0_atet_rep))
			else matrix `res' = (r(atet_rep), r(atent_rep), r(ate_rep), r(seatet_rep), r(seatent_rep), r(seate_rep), r(y1_atet_rep), r(y1_atent_rep), r(y1_ate_rep), r(y0_atet_rep), r(y0_atent_rep), r(y0_ate_rep))
			forvalues k = 1(1)`colnum' { 
				local elem = "`tip`k''" + "_" + "`ovar`k''"
				scalar `elem' = `res'[1,`k']
			}
			post `resfile' `results'
			if (r(nosup)==1) _dots `i' 1
			else if (`r(converged)'==0) _dots `i' 3
			else _dots `i' 0
			restore
			timer off 4
		}
		postclose `resfile'
		_dots `boostrap'
		display _newline
		
		/**********End of Estimation*************/
		
		
		//estimate t-statistics and generate output after bootstrap
		preserve
		use "`bfile'", clear
		mata : est_tstat(`colnum', "`notstat'")
		
		// create output tables
		_mk_bstab `outcome', effect("atet") bc(`bc') `notstat'
		return add
		if ("`ate'"!="") {
				_mk_bstab `outcome', effect("atent") bc(`bc') `notstat'
				return add
				_mk_bstab `outcome', effect("ate") bc(`bc') `notstat'
				return add
		}

		restore
	}
	
	// Normalize the weights so the sum equals the number of treated/non-treated (relevant for pstest)
	quietly count if _treated==1 & _support==1
	capture replace _weightt = _weightt * r(N)
	quietly count if _treated==0 & _support==1
	capture replace _weightut = _weightut * r(N)
	
end	
	
/**************************************************************************************************************
This is the real matching program
**************************************************************************************************************/
	
	
program define matchcore, rclass sortpreserve
	#delimit ;
	syntax varlist(fv min=1) [if] [in] [,
	OUTcome(varlist)
	Pscore(varname numeric)
	CQUantile(real 90)
	CPErcent(real 300)
	MAHALanobis(varlist)
	SCOREweight(real 5)
	NOCommon
	MWEight(real 100)
	LOGIT
	INDEX
	DESCending
	ATE
	BC(integer 1)
	REP
	W(string)
	KNN
	BOOST
	NOTstat
	TOUSE(varname)
		];
	#delimit cr	
	
	
	timer on 1
	
	// record sort order
	tempvar order _t _ut _pscore2 _pscore_os _mdif _yzero _nn
	g long `order' = _n

	// use the orginal pscore in case the pscore can not be estimated in a bootstrap replication.
	if ("`rep'" != "") qui g `_pscore_os' = _pscore
		
	// clean up data
	foreach v in base _treated _untreated _t _ut _support _weightt _weightut _pscore _pscore2 _id _pdif _yzero { 
		cap drop `v'
	}

	global OUTVAR `outcome'
	if ("`outcome'"!="") {
		foreach v of varlist `outcome' {
			cap drop _`v'
			local moutvar `moutvar' _`v'
		}
	}

	// separate treatment indicator from varlist
	tokenize `varlist'
	local treat `1'
	macro shift
	local varlist "`*'"
	local k : word count `varlist'

	// determine matching metric
	local metric = "mahalanobis"

	qui count if `treat'==0
	local nullen = r(N)
	qui count if `treat'==1
	local einsen = r(N)
	qui count if `treat'<.
	if (`nullen'+`einsen'!=r(N)) {
		di as error "treatvar is not a binary (0/1) variable."
		exit 198
	}
	if (`k'==0 & "`pscore'"=="" & "`metric'"=="pscore") {
		di as error "You should either specify a " as input "varlist" as error " or " as input "propensity score"
		exit 198
	}
	if (`k'>0 & "`pscore'"!="") {
		di as error "You cannot specify both a " as input "varlist" as error " AND a " as input "propensity score"
		exit 198
	}


	// estimate propensity score
	timer on 10
	if ("`varlist'"!="") {
		if ("`logit'"=="") local estim probit
		else local estim logit
		`estim' `treat' `varlist' if `touse', nolog col iter(50)
		if (`e(converged)'==1) {
			qui predict double _pscore if `touse', `index'
		}
		else if (`e(converged)' == 0 & "`rep'"!="") {
			qui g double _pscore = `_pscore_os' if `touse'
		}
		return scalar converged = `e(converged)'
		//qui g double _pscore = `pscore' if `touse'
		qui g double `_pscore2' = _pscore^2 if `touse'
		label var _pscore "radiusmatch: Propensity Score"
	}
	else { 
		qui g double _pscore = `pscore'
		qui g double `_pscore2' = _pscore^2
		label var _pscore "radiusmatch: Propensity Score"
	}
	capture markout `touse' _pscore
	timer off 10
	
	// create treatment indicator variable
	qui g byte _treated = `treat' if `touse'
	qui g byte _untreated = 1-`treat' if `touse'
	label variable _treated "radiusmatch: Treatment assignment"
	label variable _untreated "radiusmatch: Inverted treatment assignment"
	cap label drop _treated
	label define _treated 0 "Untreated" 1 "Treated"
	label value _treated _treated

	
	// common support if requested
	if (("`nocommon'"=="") & ("`varlist'"=="" & "`pscore'"=="")) {
		di as error "With option 'common' a propensity score is needed. Provide one"
		di as error "with option 'pscore()' or estimate one. See the help file for more details."
		exit 198
	}
	qui g byte _support = 1 if `touse'
	label variable _support "radiusmatch: Common support"
	cap label drop _support
	label define _support 0 "Off support" 1 "On support"
	label value _support _support
	if (("`nocommon'"=="") & ("`varlist'"!="" | "`pscore'"!="")) {
		qui _Support_ _pscore, `ate'
		qui _Support_weight _pscore, maxshare(`mweight') `index' `logit'
	}
	
	display as text _newline(2) "Common support statistics"
	tab _treated _support

	// test whether there is any common support
	sum _treated if _support==1, mean
	if (r(mean)==0 | r(mean)==1 | r(N)==0) {
		if "`rep'"=="" {
			display as error "No common support"
			exit
		}
		else {
			return scalar nosup = 1
		}
	}
	else {
		// create vars we will need
		qui g double _weightt = _treated if _support==1 
		char _weightt[Type] "iweight"
		label var _weightt "radiusmatch: weight of matched controls for treated"
		
		if "`ate'"!="" {
			qui g double _weightut = _untreated if _support==1
			char _weightut[Type] "iweight"
			label var _weightut "radiusmatch: weight of matched controls for untreated"
		}
	
	
		// difference for mahalonobis matching
		qui g double `_mdif' = . 
	
		if ("`mahalanobis'" != "") local mahalanobis = "_pscore `mahalanobis'"
		else local mahalanobis = "_pscore"

		// sort data on treatment status and pscore and create id
		tempvar msup
		qui g byte `msup' = - _support
			if ("`descending'"=="") {
				sort `msup' _treated _pscore `order'
			}
			else {
				tempvar mps
				qui g double `mps' = - _pscore
				sort `msup' _treated `mps' `order'
			}

		qui g _id = _n
		label var _id "radiusmatch: Identifier (ID)"
		qui compress _id
		local idtype : type _id
	
**************************************************************************************************************	
		// Loop for ATET and ATENT
	
		if ("`ate'"=="") local runs = 1
		else local runs = 2
	
		forvalues ka = 1(1)`runs' {
		
			if (`ka'==1) { // switch treated and controls to estimate ATENT
				qui g byte _t = _treated==1 if _support==1 & `touse'
				qui replace _t = 0 if _t==.
				qui g byte _ut = _untreated==1 if _support==1 & `touse' 
				qui replace _ut = 0 if _ut==.
				local treat "t"
			}
			else {
				capture drop base
				qui replace _t = _untreated if _support==1 & `touse'
				qui replace _t = 0 if _t==.
				qui replace _ut = _treated if _support==1 & `touse' 
				qui replace _ut = 0 if _ut==.
				local treat "ut"
			}
		
			// calculate within sample covariance matrix if necessary	
			if ("`mahalanobis'" != "_pscore") {
				tempname XX0 w
				qui mat accum `XX0' = `mahalanobis' if _ut==1, dev noc
				qui count if _ut==1 
				mat `w' = syminv((`XX0')/(r(N)-1)) // estimate covariance matrix only in untreated sample
				mat `w'[1,1] = `w'[1,1] * `scoreweight'
				local matchon `mahalanobis'
			}
		
			else local matchon _pscore
	**************************************************************************************************************
		// STEP 3.1: GET DISTANCE TO NEIGHBORS

			local noreplace 0
			timer on 5
			if ("`mahalanobis'" == "_pscore")	mata: find_mdif_pscore ("`boost'")
			else 								mata: find_mdif("`w'", "`mahalanobis'", "`boost'")
			
			timer off 5
						
		// STEP 3.2: MATCH USING RADIUS MATCHING AND THE MAXIMUM RADIUS OBTAINED IN 3.1 x caliper
			if (`cquantile' > 100 | `cquantile'<=0) local `cquantile'==100
			qui centile `_mdif' if _t==1, centile(`cquantile')
			scalar bwidth =  r(c_1) * `cpercent'/100 
			if (bwidth==0) scalar bwidth = bwidth + 0.0000000001 
			
			if "`rep'"=="" return scalar caliper = bwidth

			local bw = bwidth
			scalar drop bwidth

			timer on 2
			mata: match_kernel ("`matchon'", `bw', "`w'", "`treat'", "`boost'")
			timer off 2
			
			local warn=r(warn)
			if `warn'==1 {
				di as res _newline "Nearest neighbors are not unique."
				di as res "The sort order of the data could affect your results." _newline
			}
			local warn=0
		}	
**************************************************************************************************************	
	
		// generate results
		if ("`outcome'"!="") {
			_estresults `outcome', `ate' p2(`_pscore2') m(`mahalanobis') touse(`touse') `rep' bc(`bc') `knn' `notstat'
		}
		return add
		macro drop OUTVAR
	
		capture drop _t _ut base
		timer off 1
	}
end

***************************************************************************************************************************************

// COMMON SUPPORT FUNCTIONS
program define _Support_
	syntax varname [, untreated ate]
		sum `varlist' if _treated==0, mean
		replace _support = 0 if (`varlist'>r(max)) & _treated==1
		if ("`ate'"!="") { // ATET may be different if estimated with the option ATE as we cut at the upper and lower limit
			sum `varlist' if _treated==1, mean
			replace _support = 0 if (`varlist'<r(min)) & _treated==0
		}
end

program define _Support_weight
	syntax varname [, maxshare(real 6) index logit]
	tempvar prb ipw e cup clow
	local maxshare = `maxshare' / 100

	if ("`index'" != "") { // if we use the score, we have to transform it into a prob
		if ("`logit'"=="") qui gen `prb' = normal(`varlist')
		else if ("`logit'"=="logit") qui gen `prb' = exp(`varlist')/(1+exp(`varlist'))
	}
	else {
		gen `prb' = `varlist'
	}
	* untreated
	gen double `ipw' = `prb'/(1-`prb') if _support==1
	qui sum `ipw' if _treated==0 & _support==1
	replace `ipw' = `ipw'/r(sum) if _treated==0 & _support==1
	sum `prb' if `ipw'>`maxshare' & _treated==0 & _support==1
	scalar `cup' = r(min)
	* treated
	replace `ipw' = (1-`prb')/`prb' if _treated==1 & _support==1
	qui sum `ipw' if _treated==1 & _support==1
	replace `ipw' = `ipw'/r(sum) if _treated==1 & _support==1
	sum `prb' if `ipw'>`maxshare' & _treated==1 & _support==1
	scalar `clow' = r(max)
	replace _support = 0 if `prb' > `cup' & `cup'!=.
	replace _support = 0 if `prb' < `clow' & `clow'!=.
	
end	

* Calculate conditional variance using kernel regression
program define _variance_kernel, rclass
	syntax varname , weigh(varname) ut(varname) [ate]
	tempvar smooth wpos lvar var_y

	gen `wpos' = `weigh' if `ut'==1
	sum `wpos'
	local N = r(N)
	replace `wpos' = `wpos'/r(sum)	// normalise weights
	sum `wpos', detail
	local sigma= min(r(sd),((r(p75)-r(p25))/1.349))
	local bw = max(2.34*`sigma'*r(N)^(-1/5), 0.00001) 
	count if `varlist'==1 & `ut'==1
	local N1=r(N)
	count if `varlist'==0 & `ut'==1
	local N0=r(N)

	lpoly `varlist' `wpos' if `ut'==1, nograph at(`wpos') gen(`smooth') bwidth(`bw')
	if (`N0'+`N1'==`N') {
		gen `var_y'=`smooth'*(1-`smooth')
	}
	else {
		gen `lvar' = ((`varlist'-`smooth')^2)
		lpoly `lvar' `wpos', nograph at(`wpos') gen(`var_y') bwidth(`bw') 
	}
	replace `var_y' = `var_y'*(`wpos'^2)
	sum `var_y'
	return scalar variance = r(sum)
end

version 11.0
mata:

// calculates x'Wx used by mahalanobis metric, needs to be done only once
void _Dif_mbase(string xvars, string base, string wmatrix)
{
	real matrix W
	real scalar j
	j = st_addvar("double", base) 
	st_view(X=., ., tokens(xvars))
	W = st_matrix(wmatrix)
	for (i = 1; i<=st_nobs(); ++i) {
		_st_store(i, j, X[i,.]*W*X[i,.]')
	}
}

void match_kernel(string xvars, real bwidth, string wmatrix, string treat, string boost)
{
	string base
	pointer() matrix p
	real matrix dist, WEIGHTS, X, XT, XUT, XWXT, XWXUT
	real colvector help, helptest, inradtest, weighttest, weight, N1T, IDUT, ind
	real scalar obs, obsut, i, j, inrad, warn
	st_view(WEIGHTS, ., "_weight"+treat, "_ut")
	st_view(IDUT, ., "_id", "_ut")
	st_view(X, ., tokens(xvars))
	st_view(XT, ., tokens(xvars), "_t") 
	st_view(XUT, ., tokens(xvars), "_ut")
	
	id = st_data(.,"_id", "_ut")   
	
	if (xvars!= "_pscore") {
		W = st_matrix(wmatrix)
		st_view(XWXT, ., "base", "_t")
		st_view(XWXUT, ., "base", "_ut")
	}
	
	obs=rows(XT)
	obsut=rows(XUT)
	
	warn = 0

	if (boost!="") p = findexternal("disttest")

	for (i = 1; i<=obs; i++) {
		if (boost=="") {
			if (xvars == "_pscore")	dist = (XT[i] :- XUT):^2 
			else 					dist = XWXUT - 2*XUT*(W*XT[i,.]') :+ XWXT[i,.] 
		}
		else dist = (*p)[.,i]
		
		help = dist:<=bwidth
		inrad = colsum(help)
		if (inrad==1) {
			weight = help // 1:1 matching if only 1 observation
		}
		else if (inrad>1) {
			dist = dist :* (dist:>0) :+ ((dist :<= 0) :* 0.0000000001)
			dist = dist / bwidth
			weight = (1 :/ abs(dist)) :* help
		}
		else {
			dist = dist, id
			minindex(dist[.,1],1,ind,nix) 
			if (nix[1,2]>1) warn = 1
			// give equal weights to neighbors if they are not unique
			weight = J(obsut, 1, 0)
			weight[ind] = weight[ind] :+ (1/rows(ind))
		}
		// normalize sum of weights to 1
		weight = weight :/ colsum(weight)
		WEIGHTS[.,.] = WEIGHTS :+ weight
	}
	st_numscalar("r(warn)", warn)
	if (boost!="") rmexternal("disttest")
}	

real find_mdif_pscore(string boost)
{
	external real matrix disttest
	real colvector PST, PSUT, N1T, IDUT, MDIF, dist
	real scalar obs, obsut, i, minut, maxut, warn
	
	st_view(PST, ., "_pscore", "_t") 
	st_view(PSUT, ., "_pscore", "_ut")
	st_view(IDUT, ., "_id", "_ut")
	st_view(MDIF, ., st_local("_mdif"), "_t")
	
	obs  =rows(PST)
	obsut=rows(PSUT)
	warn = 0
	if (boost!="") {
		disttest = (J(1,obsut,PST)' - J(1,obs,PSUT)):^2
		MDIF[|1,1\obs,1|] = (colmin(disttest))'
	}
	else {
		for (i = 1; i<=obs; i++) {
			dist = (PST[i] :- PSUT):^2 
			dist = dist, IDUT
			minindex(dist[.,1],1,ind,nix) // could be optimized by using the fact that data is sorted
			if (nix[1,2]>1) warn = 1
			MDIF[i] = dist[ind[1],1]
		}
	}
}
	
real find_mdif(string wmatrix, string xvars, string boost)
{
	string base
	external real matrix disttest
	real matrix dist, X, XT, XUT, XWXT, XWXUT
	real colvector help, weight, N1T, IDUT, id, ind, MDIF
	real scalar obs, i, j, inrad
	
	W = st_matrix(wmatrix)
	st_view(X, ., tokens(xvars))
	st_view(XT, ., tokens(xvars), "_t") 
	st_view(XUT, ., tokens(xvars), "_ut")
	st_view(MDIF, ., st_local("_mdif"), "_t")
	
	if (boost=="") id = st_data(.,"_id", "_ut")   // we want a copy
	
	_Dif_mbase(xvars, "base", wmatrix)
	
	st_view(XWXT, ., "base", "_t")
	st_view(XWXUT, ., "base", "_ut")
	
	obs=rows(XT)
	warn = 0
	if (boost!="") {
		disttest = XWXUT :- 2*XUT*(W*XT') :+ XWXT'
		MDIF[|1,1\obs,1|] = (colmin(disttest))'
	}
	else {
		for (i = 1; i<=obs; i++) {
			dist = XWXUT - 2*XUT*(W*XT[i,.]') :+ XWXT[i,.]
			
			dist = dist, id
			minindex(dist[.,1],1,ind,nix)
			MDIF[i] = dist[ind[1],1]
		}
	}
}

void est_tstat (real mcols, string notstat)
{
	real matrix eff, ste, b_eff, b_se, t, t_bs, ind, r1, rb
	
	st_view(r1, 1, .) // obtain first row with effects in original sample
	st_view(rb, (2,.), .) // obtain rows 2 to . with bootstrap replications

	eff = r1[|.,1\.,(mcols/4)|]
	b_eff = rb[|.,1\.,(mcols/4)|]
	//if (notstat=="") {
		ste = r1[|.,(mcols/4+1)\.,(mcols/2)|]
		b_se = rb[|.,(mcols/4+1)\.,(mcols/2)|]

		t = abs(eff :/ (ste))
		t_bs = abs((b_eff :- eff) :/ (b_se))
		ind = t_bs :> t
	//}
		
	st_matrix("p_bs", colsum(ind)/rows(ind))
}

void total_weights (string v, string treat, string weigh)
{
	real colvector  t, w, w2, w1
	real matrix x, x0, x1, B, w0_new, w1_new, tm
	real scalar min_k, k, N, i, start, ende, var_y_pot
	
	st_view(t,.,tokens(treat),"_support")
	st_view(x,.,tokens(v), "_support")
	st_view(w,.,tokens(weigh), "_support")
	
	st_select(w2,w,(1:-t))	
	w2[.,.]=w2/sum(w2)
	st_select(w1,w,t)	
	w1[.,.]=w1/sum(w1)
	
	x0 = select(x,(1:-t))
	x1 = select(x,t)
	x0 = J(rows(x0),1,1),x0
	x1 = J(rows(x1),1,1),x1
	B  = sqrt(w2):*x0
	if (rank(B)>=cols(x0)) {
		B=invsym(B'B)
		if (B[1,1]!=.) {
			w0_new =((w2'*x0) * B * (w2:*x0)')'
			w1_new = (mean(x1)* B * (w2:*x0)')'
	
			w2[.,.] = w2 - w0_new + w1_new
		}
	}	
}

void variance_match_knn (string v, string treat, string weigh)
{
	real colvector e_y_x, var_y_x
	real matrix y, w
	real scalar min_k, k, N, i, start, ende, var_y_pot
	
	y = sort(st_data(., (v, weigh), treat),2)
	y = select(y,y[.,2]:<.) // select observations with non-missing weights
	y = select(y,y[.,2]) // select observations with positive weights
	N = rows(y)
	min_k = 10
	k = round(sqrt(N)*2)
	if (k < min_k) k = min_k
	if (N < k) k = N
	e_y_x   = range(1, N, 1)
	var_y_x = range(1, N, 1)

	var_y_x[|1,1\k,1|]     = J(k,1,variance(y[|1,1\2*k,1|]))
	var_y_x[|N-k+1,1\N,1|] = J(k,1,variance(y[|N-k+1,1\N,1|]))
	
	for (i=k+1; i<=N-k; i++) {
		start = i - k + 1
		ende = start + 2 * k -1
		var_y_x[i] = variance(y[|start,1\ende,1|])
	}
	
	w = y[.,2]/colsum(y[.,2])
	var_y_pot = ((w :^2)' * var_y_x) 
	
	st_numscalar("r(variance)", var_y_pot)
}


end

****************************************************************************************************************
****************************************************************************************************************

// Estimate results
program define _estresults, rclass
syntax varlist [, ate m(string) p2(string) touse(string) postid(string) rep bc(integer 1) knn NOTstat]

local numoutvars = 0

// create body and return results
foreach v of varlist `varlist' {
	
	local numoutvars = `numoutvars' + 1
	if ("`ate'"=="") local runs = 1
	else local runs = 2

	tempname m1t_t m1t_ut m0t_t m0t_ut att_t att_ut m0u m1u var0 var1 var0_t var0_ut var1_t var1_ut ate1 m1ate m0ate
	tempname yzero0 yzero1 bias attbc m0tbc att atu seatt seatt_t seatt_ut seate seate1 t_t t_ut p_t_t p_t_ut
		

	forvalues ka = 1(1)`runs' {
		
		capture drop _t _ut
		
		if (`ka'==1) { // switch treated and controls to estimate ATENT
				qui g byte _t = _treated==1 if _support==1 
				qui replace _t = 0 if _t==. & _support==1
				qui g byte _ut = _untreated==1 if _support==1 
				qui replace _ut = 0 if _ut==. & _support==1
				local short "_t"
				local treat "_treated"
				*local untreat "_untreated"
				local weigh "_weightt"
				local itreat 1
		}
		else {
		 		qui g byte _t = _untreated if _support==1
				qui replace _t = 0 if _t==. & _support==1
				qui g byte _ut = _treated if _support==1
				qui replace _ut = 0 if _ut==. & _support==1
				local short "_ut"
				local treat "_untreated"
				*local untreat "_treated"
				local weigh "_weightut"
				local itreat 0
		}

		qui sum `v' if `treat'==1 & _support==1 [iw=`weigh'], mean
		scalar `m1t`short'' = r(mean)
		local N1 = r(N)
		qui sum `v' if `treat'==0 & _support==1 [iw=`weigh'], mean
		scalar `m0t`short'' = r(mean)
		scalar `att`short'' = `m1t`short'' - `m0t`short''
		
		
	// Bias correction 
		// weighted regression to estimate the bias of the estimator
		if (`bc'==1) { // only linear bias correction
			tempvar _yzero
			qui reg `v' `m' `p2' [iw=`weigh'] if `treat'==0 & _support==1
			qui predict `_yzero' if _support==1
			qui sum `_yzero' if `treat'==1, mean
			scalar `yzero1' = r(mean)
			qui sum `_yzero' if `treat'==0 [iw=`weigh'], mean
			scalar `yzero0' = r(mean)
			scalar `bias' = `yzero1' - `yzero0'
			scalar `m0t`short'' = `m0t`short'' + `bias'
			scalar `att`short'' = `att`short'' - `bias'
		}
		
		if (`bc'==2) { // linear and logit bias correction
			tempvar _yzero
			qui count if `v' ==0 & `treat'==0 & _support==1 & `weigh'!=0
			local nullen = r(N)
			qui count if `v' ==1 & `treat'==0 & _support==1 & `weigh'!=0
			local einsen = r(N)
			qui count if `treat'==0 & _support==1 & `weigh'!=0
			if `nullen'+`einsen'==r(N) & (`nullen'>0 & `nullen'<r(N)) { // check whether variable is binary and there is variation in this variable
				capture qui logit `v' `m' `p2' [iw=`weigh'] if `treat'==0 & _support==1, iterate(1000) nolog 
				// No bias correction if probit does not converge
				if (`e(converged)'==0) qui reg `v' [iw=`weigh'] if `treat'==0 & _support==1 
			}
			else{
				qui reg `v' `m' `p2' [iw=`weigh'] if `treat'==0 & _support==1 
			}
			qui predict `_yzero' if _support==1
			qui sum `_yzero' if `treat'==1, mean
			scalar `yzero1' = r(mean)
			qui sum `_yzero' if `treat'==0 [iw=`weigh'], mean
			scalar `yzero0' = r(mean)
			scalar `bias' = `yzero1' - `yzero0'
			scalar `m0t`short'' = `m0t`short'' + `bias'
			scalar `att`short'' = `att`short'' - `bias'
		}
		
		* Adjust the weights (makes changes in the weight variables)
		mata: total_weights("`m' `p2'","`treat'", "`weigh'")
					
	// calculate s.e.'s
		if ("`rep'"=="" | ("`rep'"=="rep" & "`notstat'"=="")) {
			tempname wtot number effect
			tempvar w2 smooth wpos lvar
			if ("`knn'"=="knn")	mata: variance_match_knn("`v'", "_ut", "`weigh'")
			else quietly: _variance_kernel `v', weigh(`weigh') ut(_ut)

			scalar `var0`short'' = r(variance)
			qui sum `v' if `treat'==1 & _support==1
			scalar `var1`short'' = r(Var)/r(N)
			scalar `seatt`short'' = sqrt(`var1`short'' + `var0`short'')
		}
		else scalar `seatt`short'' = .
 	}
		
	/******************* Estimate ATE ***********************************/
	if ("`ate'"!="") {
			
			tempvar _t1 _ut1 weighate
			qui gen `_t1' = _treated==1 if _support==1
			qui replace `_t1' = 0 if `_t1' == .
			qui gen `_ut1' = _untreated==1 if _support==1 
			qui replace `_ut1' = 0 if `_ut1' == .
			qui sum _treated if _support==1, mean
			local st = r(mean)
			scalar `att_ut' = (-1)*`att_ut'
			scalar `ate1' = `att_t'*`st' + `att_ut'*(1-`st')
			scalar `m1ate' = `m1t_t'*`st' + `m0t_ut'*(1-`st')
			scalar `m0ate' = `m0t_t'*`st' + `m1t_ut'*(1-`st')
			
			if ("`rep'"=="" | ("`rep'"=="rep" & "`notstat'"=="")) {
				qui gen `weighate'=_weightt+_weightut 
				if ("`knn'"=="knn")	mata: variance_match_knn("`v'", "`_ut1'", "`weighate'")
				else quietly: _variance_kernel `v', weigh(`weighate') ut(`_ut1') ate
				scalar `var0' = r(variance)
				
				if ("`knn'"=="knn")	mata: variance_match_knn("`v'", "`_t1'", "`weighate'")
				else quietly: _variance_kernel `v', weigh(`weighate') ut(`_t1') ate
				scalar `var1' = r(variance)			
				scalar `seate1' = sqrt(`var1' + `var0')
			}
			else scalar `seate1' = .
		}
	// be aware, that we have to change signs for the atu
	
	if ("`ate'"=="") {
		matrix atet_r   			= J(1,1,`att_t')
		matrix seatet_r     		= J(1,1,`seatt_t')
		matrix y1_atet_r			= J(1,1,`m1t_t')
		matrix y0_atet_r			= J(1,1,`m0t_t')
		matrix coleq atet_r			= atet
		matrix coleq seatet_r		= seatet
		matrix coleq y1_atet_r		= y1atet
		matrix coleq y0_atet_r		= y0atet
		matrix colnames atet_r		= `v'
		matrix colnames seatet_r 	= `v'	
		matrix colnames y1_atet_r 	= `v'	
		matrix colnames y0_atet_r 	= `v'	
	}
	else {
		matrix atet_r   			= J(1,1,`att_t')
		matrix seatet_r     		= J(1,1,`seatt_t')
		matrix y1_atet_r			= J(1,1,`m1t_t')
		matrix y0_atet_r			= J(1,1,`m0t_t')
		matrix coleq atet_r			= atet
		matrix coleq seatet_r		= seatet
		matrix coleq y1_atet_r		= y1atet
		matrix coleq y0_atet_r		= y0atet
		matrix colnames atet_r		= `v'
		matrix colnames seatet_r 	= `v'
		matrix colnames y1_atet_r 	= `v'	
		matrix colnames y0_atet_r 	= `v'
		
		
		matrix atent_r   			= J(1,1,`att_ut')
		matrix seatent_r     		= J(1,1,`seatt_ut')
		matrix y1_atent_r			= J(1,1,`m0t_ut')
		matrix y0_atent_r			= J(1,1,`m1t_ut')
		matrix coleq atent_r		= atent
		matrix coleq seatent_r		= seatent
		matrix coleq y1_atent_r		= y1atent
		matrix coleq y0_atent_r		= y0atent
		matrix colnames atent_r		= `v'
		matrix colnames seatent_r 	= `v'
		matrix colnames y1_atent_r 	= `v'	
		matrix colnames y0_atent_r 	= `v'
		
		matrix ate_r   				= J(1,1,`ate1')
		matrix seate_r     			= J(1,1,`seate1')	
		matrix y1_ate_r				= J(1,1,`m1ate')
		matrix y0_ate_r				= J(1,1,`m0ate')
		matrix coleq ate_r			= ate
		matrix coleq seate_r		= seate
		matrix coleq y1_ate_r		= y1ate
		matrix coleq y0_ate_r		= y0ate
		matrix colnames ate_r		= `v'
		matrix colnames seate_r		= `v'
		matrix colnames y1_ate_r 	= `v'	
		matrix colnames y0_ate_r 	= `v'
		
	}
	

	if (`numoutvars'==1) {
		matrix atet			= atet_r
		matrix seatet		= seatet_r
		matrix y1_atet		= y1_atet_r
		matrix y0_atet		= y0_atet_r
		if ("`ate'"!="") {
			matrix atent	= atent_r
			matrix seatent	= seatent_r
			matrix y1_atent	= y1_atent_r
			matrix y0_atent	= y0_atent_r
			matrix ate		= ate_r
			matrix seate	= seate_r
			matrix y1_ate	= y1_ate_r
			matrix y0_ate	= y0_ate_r
		}
	}
	else {
		matrix atet			= (atet, atet_r)
		matrix seatet		= (seatet, seatet_r)
		matrix y1_atet		= (y1_atet, y1_atet_r)
		matrix y0_atet		= (y0_atet, y0_atet_r)
		if ("`ate'"!="") {
			matrix atent	= (atent, atent_r)
			matrix seatent	= (seatent, seatent_r)
			matrix y1_atent = (y1_atent, y1_atent_r)
			matrix y0_atent = (y0_atent, y0_atent_r)
			matrix ate		= (ate, ate_r)
			matrix seate	= (seate, seate_r)
			matrix y1_ate	= (y1_ate, y1_ate_r)
			matrix y0_ate	= (y0_ate, y0_ate_r)
		}
	}
}
	if ("`rep'"=="") {	
		return matrix atet = atet, copy
		return matrix seatet = seatet, copy
		return matrix y1_atet = y1_atet, copy
		return matrix y0_atet = y0_atet, copy
		if ("`ate'"!="") {
			return matrix atent = atent, copy
			return matrix seatent = seatent, copy
			return matrix y1_atent = y1_atent, copy
			return matrix y0_atent = y0_atent, copy
			return matrix ate = ate, copy
			return matrix seate = seate, copy
			return matrix y1_ate = y1_ate, copy
			return matrix y0_ate = y0_ate, copy
		}
	}
	else {
		return matrix atet_rep = atet, copy
		return matrix seatet_rep = seatet, copy
		return matrix y1_atet_rep = y1_atet, copy
		return matrix y0_atet_rep = y0_atet, copy
		if ("`ate'"!="") {
			return matrix atent_rep = atent, copy
			return matrix seatent_rep = seatent, copy
			return matrix y1_atent_rep = y1_atent, copy
			return matrix y0_atent_rep = y0_atent, copy
			return matrix ate_rep = ate, copy
			return matrix seate_rep = seate, copy
			return matrix y1_ate_rep = y1_ate, copy
			return matrix y0_ate_rep = y0_ate, copy
		}
	}	
end

**********************************************************************************************************

program define _mktab
syntax [, ate bc(integer 1)]

	// create header output table
	di as text _newline(2) "ATET - Average Treatment Effect on the Treated" _newline(1) 
	di as text "{hline 20}{c TT}{hline 68}"
	di as text "Variable            {c |}    Treated     Controls   Difference         S.E.   T-stat  P-value"
	di as text "{hline 20}{c +}{hline 68}"

	local colnum = colsof(r(atet))
	local outvars: colnames r(atet)
	tknz "`outvars'", stub(ovar)
	
	forvalues i = 1(1)`colnum' {
		local var = "`ovar`i''" 
		noi di as text abbrev("`var'",20) _col(20) " {c |}" as result %11.0g y1_atet[1,`i'] "  " %11.0g y0_atet[1,`i'] "  " %11.0g atet[1,`i']	"  " %11.0g seatet[1,`i'] "  " %7.2f atet[1,`i']/seatet[1,`i'] "  " %7.2f 2*ttail(_N,abs(atet[1,`i']/seatet[1,`i']))
	}
	noi di as text "{hline 20}{c BT}{hline 68}"
	if (`bc'==1) di as text "Linear bias correction"
	else if (`bc'==2) di as text "Linear and logit bias correction"
	else di as text "No bias correction" _newline(1)
	
	if ("`ate'"!="") {
		// Table for ATENT
		di as text _newline(2) "ATENT - Average Treatment Effect on the Non-Treated" _newline(1)
		di as text "{hline 20}{c TT}{hline 68}"
		di as text "Variable            {c |}    Treated     Controls   Difference         S.E.   T-stat  P-value"
		di as text "{hline 20}{c +}{hline 68}"

		forvalues i = 1(1)`colnum' {
			local var = "`ovar`i''" 
			noi di as text abbrev("`var'",20) _col(20) " {c |}" as result %11.0g y1_atent[1,`i'] "  " %11.0g y0_atent[1,`i'] "  " %11.0g atent[1,`i']	"  " %11.0g seatent[1,`i'] "  " %7.2f atent[1,`i']/seatent[1,`i'] "  " %7.2f 2*ttail(_N,abs(atent[1,`i']/seatent[1,`i']))
		}
		noi di as text "{hline 20}{c BT}{hline 68}"
		if (`bc'==1) di as text "Linear bias correction"
		else if (`bc'==2) di as text "Linear and logit bias correction"
		else di as text "No bias correction"
		
		// Table for ATE
		di as text _newline(2) "ATE - Average Treatment Effect" _newline(1) 
		di as text "{hline 20}{c TT}{hline 68}"
		di as text "Variable            {c |}    Treated     Controls   Difference         S.E.   T-stat  P-value"
		di as text "{hline 20}{c +}{hline 68}"

		forvalues i = 1(1)`colnum' {
			local var = "`ovar`i''" 
			noi di as text abbrev("`var'",20) _col(20) " {c |}" as result %11.0g y1_ate[1,`i'] "  " %11.0g y0_ate[1,`i'] "  " %11.0g ate[1,`i']	"  " %11.0g seate[1,`i'] "  " %7.2f ate[1,`i']/seate[1,`i'] "  " %7.2f 2*ttail(_N,abs(ate[1,`i']/seate[1,`i']))
		}
		noi di as text "{hline 20}{c BT}{hline 68}"
		if (`bc'==1) di as text "Linear bias correction"
		else if (`bc'==2) di as text "Linear and logit bias correction"
		else di as text "No bias correction"
	}			
end	

* Table for bootstrap results
program define _mk_bstab, rclass
syntax namelist [, effect(string) bc(integer 2) NOTstat]

		local nvars: list sizeof namelist
		if ("`effect'" == "atet") {
			di as text _newline(2) "ATET - Average Treatment Effect on the Treated" _newline(1)
			local i 1
		}
		else if ("`effect'" == "atent") {
			di as text _newline(2) "ATENT - Average Treatment Effect on the Non-Treated" _newline(1)
			local i = `nvars'+1
		}
		
		else if ("`effect'" == "ate") {
			di as text _newline(2) "ATE - Average Treatment Effect" _newline(1)
			local i = (`nvars'*2)+1
		}
		
		matrix bse`effect' = J(1,`nvars',.)
		//matrix bsp`effect' = J(1,`nvars',.)
		local stop = `i'+`nvars'-1
		if ("`notstat'"=="") matrix bsp`effect' = p_bs[1,`i'..`stop']
		else matrix bsp`effect' =  J(1,`nvars',.)
		di as text "{hline 18}{c TT}{hline 86}"
		di as text "  Variable        {c |}   Theta    b_mean     b_std  b_pval     0.025     0.050     0.500     0.950     0.975"
		di as text "{hline 18}{c +}{hline 86}"
			
		local j 1
		foreach var in `namelist' {
				qui centile `effect'_`var' in 2/l, centile(0.5 2.5 5 50 95 97.5 99.5)
				local 1lo = r(c_1)
				local 5lo = r(c_2)
				local 10lo = r(c_3)
				local med = r(c_4)
				local 10up = r(c_5)
				local 5up = r(c_6)
				local 1up = r(c_7)
				
				qui sum `effect'_`var' in 1/1, mean
				local coeff = r(mean)
				qui sum `effect'_`var' in 2/l
				if ("`notstat'"=="") local p = p_bs[1,`i']
				else {
					local p = 2*ttail(_N,abs(`coeff'/r(sd)))
					matrix bsp`effect'[1,`j'] = `p'
				}
				display as text %-16s abbrev("`var'",16) "  {c |} " as result %7.0g `coeff' "   " %7.0g `r(mean)' "   " %7.0g `r(sd)' "   " %5.3f `p' "   " %7.0g `5lo' "   " %7.0g `10lo'  "   " %7.0g `med' "   " %7.0g `10up' "   " %7.0g `5up'
				matrix bse`effect'[1,`j'] = r(sd)
				local j = `j' + 1
				local i = `i' + 1

			}
			noi di as text "{hline 18}{c BT}{hline 86}"
			if (`bc'==1) di as text "Linear bias correction"
			else if (`bc'==2) di as text "Linear and logit bias correction"
			else di as text "No bias correction"
			
			if ("`notstat'"=="") di as text "b_pval calculated by bootstrapping the t-statistic"
			else if ("`notstat'"=="notstat") di as text "b_pval based on normal t-statistic (theta/b_std)"
			
			return matrix b_se`effect' = bse`effect'
			return matrix b_p`effect' = bsp`effect'
end
