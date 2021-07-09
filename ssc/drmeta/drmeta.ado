*! 3may19  minor changes in the help file
*! 17mar19  change initial values for par (ml, reml)
*! 16jan19  allow drmeta to return fitted cases
*! N.Orsini v.1.0.0 10oct18
  
capture program drop drmeta
program drmeta, eclass
version 13

	if replay() {

		if "`e(cmd)'"!="drmeta" {
			`e(cmd)' `0'
			error 301
		}	

		display_result `0'
		exit
	}

syntax varlist (min=2) [if] [in] , [ ///
    Se(varname numeric)  ///
	Data(varlist numeric min=2) ///
	or rr hr md smd ///
	Id(varname) ///
	Type(varname) ///
	Level(integer $S_level) ///
	eform ///
	vwls  ///
	ACov(varlist max=1) MCov(string) VCov(varlist) ///
	Hamling ///
	fixed reml ml mm ///
	2stage ///
	NORETable  ///
	STDDEViations ///
	NOLRt ///
] 

 
local random "fixed"
if  ("`ml'"!="" | "`reml'" != "" | "`mm'" != "") local random "random" 

local stage "One-stage"
if "`2stage'" != "" local stage "Two-stage"

// check that the two-stage method is specified with multiple studies

if "`id'" == "" & "`2stage'" != "" {
	di as err "specifies the option id()"
	exit 198
	} 
	
// Check estimation options

	local mvopt "fixed"

	if "`ml'" != "" local mvopt "ml"
	if "`reml'" != "" local mvopt "reml"
	if "`mm'" != "" local mvopt "mm"

// Check the method for estimating the covariance  

   local covmethod "GL"
   if "`hamling'" != "" local covmethod "H"
  
	if  "`hr'"!="" { 
 		local ptcohort = "ptcohort"
	} 	

	if  "`or'"!="" { 
 		local casecontrol = "casecontrol"
	} 	

	if  "`rr'"!="" { 
 		local pecohort = "pecohort"
	} 
	
	if  "`md'"!="" { 
 		local meandiff = "meandiff"
	} 
	
	if  "`smd'"!="" { 
 		local stdmeandiff = "stdmeandiff"
	} 
	
// check level 

	if `level' < 10 | `level' > 99 {
		di in red "level() must be between 10 and 99 inclusive"
		exit 198
	}

	tempname levelci 

	global levelp  = `level'/100
	scalar `levelci' = `level' * 0.005 + 0.50
 	global levelci = `level' * 0.005 + 0.50

// to use the option if/in  
	
	marksample touse, strok novarlist

    global touse = `touse'

// check observation
 
	qui count if `touse'
	local nobs = r(N)

		if `nobs'== 0 {
				di in red "no observations"
				exit 2000
		}
		 
		if `nobs'== 1 {
				di in red "insufficient number of observations"
				exit 2001
		}

// Check options for covariances

	if "`data'" != "" & "`acov'" != "" {
			di as err "choose either data() or acov()"
			exit 198
	}
	
	if "`data'" != "" & "`mcov'" != "" {
			di as err "choose either data() or mcov()"
			exit 198
	}
	
	if "`data'" != "" & "`vcov'" != "" {
			di as err "choose either cov() or vcov()"
			exit 198
	}
	
	if "`acov'" != "" & "`mcov'" != "" {
			di as err "choose either acov() or mcov()"
			exit 198
	}
	
// Parsing input variables

		tempvar  n case control v 
		
quietly {
	 	tokenize `varlist'
		local depname = "`1'"
        mac shift
        local xname `*'
		local ncov : word count  `xname' 

	    
		/*qui count if `se' == . 
		if r(N) != 0 {
					di as err "std error cannot be missing"
					exit 198
		}
		*/
		// qui gen double `v' = `se'^2 if `touse'
		tempvar order
		gen `order' = _n
		
// check number of covariates and number of observations

	qui count if `touse'

	local nobstouse = r(N)-1

	if `ncov' > `nobstouse' {
				 di in r "number of covariates greater than the number of observations"
				 exit 198
	}

// get the variables required to  

	if "`data'"!=""  { 
            parse "`data'" , parse(" ")
			gen double `n' = `1' if `touse'
			gen double `case' = `2' if `touse'
			capture confirm numeric var  `n'
			capture confirm numeric var  `case'
	}
	
	local multiple = 0
	
	if ("`id'"!="")  { 
			tempvar  typestudy // id
		
			clonevar `typestudy' = `type' if `touse'
			capture confirm numeric var  `id'
			
			tab `typestudy' if `touse'
			qui tab `id' if `touse'
			local nstudies = r(r)
			if `nstudies' > 1 local multiple = 1
			
			capture confirm numeric var  `typestudy'
			capture assert (`typestudy' == 1) | (`typestudy' == 2) | (`typestudy' == 3) | (`typestudy' == 4) | (`typestudy' == 5) if `touse'
            
			if _rc != 0 {
				di _n as err "variable `type' can take value 1 (odds ratio), 2 (hazard ratio), 3 (risk ratio), 4 (mean difference), or 5 (std mean difference)" 
			}
	
			// Center the design matrix about the referent with multiple studies
			// The lowest std error is zero for the chosen referent
			foreach x of local xname {
			    capture drop _c_`x'
				bysort `id' (`se'): gen _c_`x' =  `x'- `x'[1]  if `touse'
				local xnamec "`xnamec' _c_`x'" 
			}
		  local varlist "`depname' `xnamec'" 
	}

	// sort `order' 
	// For the 2stage approach, 
	// check that the number of regression coefficients to be estimated is at least 
	// as great as the number of observations (except ref) for each study. 
	tempvar nobss tagnobss

	if "`2stage'" != "" {
			
			if "`id'" == "" {
				di as err "specify the option id()"
				exit 198
			}
			
			bysort `id': gen `nobss' = _N-1 if `touse'
			gen `tagnobss' = `nobss'>=`ncov' if `touse'
			qui count if `tagnobss' == 0
			if r(N) > 0 {
				di as err _n "Nr. of coefs greater than available data for one or more study"
				exit 198
			}		
	}
	
	// Center the design matrix with a single study
	if ("`id'"=="")  {
			foreach x of local xname {
			    capture drop _c_`x'
				qui su `x' if `se' == 0 & `touse'
				gen _c_`x' =  `x'- r(mean)
				local xnamec "`xnamec' _c_`x'" 
			}
		  local varlist "`depname' `xnamec'" 
	}
	
} // end quietly


// Multiple studies 

if ("`id'"!="") {

	local i = 1
	qui levelsof `id' if `touse', local(studies)
	qui count if `touse'
	local obs = `r(N)' - `nstudies'
	local countstudy = 1

foreach study of local studies {    

	 if "`acov'"=="" & "`mcov'"=="" & "`vcov'"=="" {
		qui drmeta_cov `varlist' if `id' == `study' & `touse' , s(`se') tot(`n') c(`case') ///
		 ts(`typestudy')  `vwls'  ecovmethod(`covmethod')
	}
	
	if "`acov'"!="" {
		qui drmeta_cov `varlist' if `id' == `study' & `touse' , s(`se')   ///
		 ts(`typestudy')   `vwls'  meancov(`acov')
	}

	// With multiple studies the user can specify the a list of covariance matrix following the order of the studies.
		
	local passm : word `countstudy++' of `mcov'

	if "`mcov'"!="" {
		qui drmeta_cov `varlist' if `id' == `study' & `touse' , s(`se')   ///
		 ts(`typestudy')   `vwls'   matrixcov(`passm') 
	}

	if "`vcov'"!="" {
		qui drmeta_cov `varlist' if `id' == `study' & `touse' , s(`se')   ///
		 ts(`typestudy')   `vwls'   varlistcov(`vcov') 
	}
 
	// required step for the two-stage meta-analysis
	
    tempname M_bc M_vc  
		
	* get study-specific estimates of the parameters
		
	mat `M_bc' = e(BC)
	mat `M_vc' = e(VB)	
 
	scalar sltb`study' =  `M_bc'[1,1]
	scalar sltvar`study' =  `M_vc'[1,1]
 
	mat _G`study' = e(C)
	scalar col`study' = colsof(_G`study')
	
	mat _VS`study' = e(VB)
	mat _BS`study' = e(BC)
	mat _ZS`study' = colsof(_BS`study')
	
	mat _X`study' = e(Z)
	mat _C`study' = e(C)
	mat _B`study' = e(B)
	
	local i = `i' + 1
}

	tempvar ids 
	tempname X Y G ID
	sort `id', stable
	mkmat `xnamec' if `depname' != 0 & `touse', matrix(`X')
	mkmat `depname'  if `depname' != 0 & `touse', matrix(`Y')
	mkmat `id' if `depname' != 0 & `touse', matrix(`ID') 
	
	* create a block-diagonal matrix using my blockaccum mata function

	local i = 1

    foreach study of local studies {   

	if `i' == 1 {
			mat PG = _G`study'
			}

	if `i' != 1 {		
			mata: blockaccum("PG","_G`study'")
			mat PG = r(CACC)
			}
	local ++i
	}

	mat `G' = PG
	mat drop PG 
	
	// Generalized Least Squares Estimation  (Pool-first approach)

	tempvar b 
	tempname  V BETAS b COV tau2 Q ll R2 D p_D

	// Pool-first approach or one-stage approach, GLS fixed-effects
	
	mata: glsest("`Y'", "`X'", "`G'")
	
	mat `G' = r(COVAR)
	mat `V' =  r(VB)
	mat `b'  = r(BC)'
	
	mata: id = st_matrix("`ID'")
    mata: _C_ = cholesky(st_matrix("`G'"))
	mata: ystar = luinv(_C_)*st_matrix("`Y'")
    mata: Xstar = luinv(_C_)*st_matrix("`X'")
	mata: _ydev = st_matrix("`Y'")
	mata: _Xdev = st_matrix("`X'")
	mata: _bdev = st_matrix("`b'")
	
	mata: D = (_ydev:-_Xdev*_bdev')'*invsym(st_matrix("`G'"))*(_ydev:-_Xdev*_bdev')
    mata: _b_ = invsym(Xstar'*Xstar)*Xstar'*ystar
    mata: ypred = Xstar*_b_
	mata: tresidual = ystar-ypred
    mata: R2=1-sum((ystar-ypred):^2)/sum(ystar:^2)
	
    mata: st_numscalar("`D'", D)
    mata: st_numscalar("`R2'", R2)
	scalar `p_D' = chi2tail(rowsof(`Y')-colsof(`X'), `D') 
   
    tempname ty tX tres tpred
	mata: st_matrix("`ty'", ystar)
	mata: st_matrix("`tX'", Xstar)
	mata: st_matrix("`tpred'", ypred)
	mata: st_matrix("`tres'", tresidual)

	local i = 1
    foreach study of local studies {   
		tempname R2_`study'
		mata: _bs = st_matrix("_BS`study'") 
		mata: ypred = select(Xstar, id:==`study')*_bs
	    mata: R2=1-sum((select(ystar,id:==`study'):-ypred):^2)/sum(select(ystar, id:==`study'):^2)
        mata: st_numscalar("`R2_`study''", R2)
	   * mata: estar = invsym(st_matrix("_G`l'") )*(select(_ydev, id:==`l')-select(_Xdev, id:==`l')*_bdev')
	*	mata: select(_ydev, id:==`l'), estar
	   }
 
	scalar `Q' = r(Q)
	local  Q =  `Q' 
	
	if ("`2stage'" == "" & "`ml'" == "" & "`reml'" == "") {
			mata:	X = st_matrix("`X'")
			mata:	y = st_matrix("`Y'")
			mata:	C = st_matrix("`G'")
			mata:	id = st_matrix("`ID'")
			mata:   Z = X
			mata:   nvc = cols(Z)*(cols(Z)+1)/2
            mata:   parf = J(1,nvc,0)
			quietly mata:   est = glsfit_fixed(X, Z, y, C, parf, id) 
			mata:   loglik = *est[8]
			mata:   beta =  *est[6]'
			mata:   vcov =  *est[7]
			mata: st_matrix("r(b)",  beta)
			mata: st_matrix("r(V)", vcov)
			mata: st_matrix("r(V)", vcov)
			mata: st_numscalar("r(loglik)", loglik)
			mata: st_numscalar("r(aic)", -2*loglik+2*cols(beta))

			matrix `b' = r(b)
			matrix `V' = r(V)
    }
	
	if "`ml'" != "" & "`2stage'" == "" {
			mata:	X = st_matrix("`X'")
			mata:	y = st_matrix("`Y'")
			mata:	C = st_matrix("`G'")
			mata:	id = st_matrix("`ID'")
			mata:   Z = X
			mata:   nvc = cols(Z)*(cols(Z)+1)/2
			mata:	  init = J(1,nvc,.5) 
			mata:	  S = optimize_init()
			mata:	  optimize_init_evaluator(S, &mlprof_fn())
			mata:	  optimize_init_evaluatortype(S, "v0")
			mata:	  optimize_init_argument(S, 1, X)
			mata:	  optimize_init_argument(S, 2, Z)
			mata:	  optimize_init_argument(S, 3, y)
			mata:	  optimize_init_argument(S, 4, C)
			mata:	  optimize_init_argument(S, 5, id)
			mata:	  optimize_init_params(S, init)
			mata:	  optimize_init_which(S,"max")
		    quietly  mata: parf = optimize(S)
			mata:    S = .
		    mata:	 est = glsfit_ml(X, Z, y, C, parf, id) 
			mata:	 loglik = *est[8]
			mata:   beta =  *est[6]'
			mata:   vcov =  *est[7]
			mata: st_matrix("r(b)",  beta)
			mata: st_matrix("r(V)", vcov)	
			mata: st_numscalar("r(loglik)", loglik)
			mata: st_matrix("r(Psi)", par2Psi(parf, cols(Z)))
			mata: st_numscalar("r(aic)", -2*loglik+2*(cols(beta)+cols(parf)))
		    mata: st_numscalar("r(nre)", cols(parf))
			// get log-likelihood setting all var/cov equal to zero
			mata: parf = J(1, cols(parf), 0)
			mata: est = glsfit_ml(X, Z, y, C, parf, id) 
			mata: st_numscalar("r(loglik0)", *est[8])
			matrix `b' = r(b)
			matrix `V' = r(V)
			}
 
	if "`reml'" != "" & "`2stage'" == "" {
			mata:	X = st_matrix("`X'")
			mata:	y = st_matrix("`Y'")
			mata:	C = st_matrix("`G'")
			mata:	id = st_matrix("`ID'")
			mata:   Z = X
			mata:   nvc = cols(Z)*(cols(Z)+1)/2
		    mata:	init = J(1,nvc,0.5) 
			mata:	S = optimize_init()
			mata:	optimize_init_evaluator(S, &remlprof_fn())
			mata:	optimize_init_evaluatortype(S, "v0")
			mata:	optimize_init_argument(S, 1, X)
			mata:	optimize_init_argument(S, 2, Z)
			mata:	optimize_init_argument(S, 3, y)
			mata:	optimize_init_argument(S, 4, C)
			mata:	optimize_init_argument(S, 5, id)
			mata:	optimize_init_params(S, init)
			mata:	optimize_init_which(S,"max")
 			quietly  mata:	parf = optimize(S)
    		mata:	est = glsfit_reml(X, Z, y, C, parf, id) 
			mata:	loglik = *est[8]
			mata:   beta =  *est[6]'
			mata:   vcov =  *est[7]
			mata:   S = .
			mata: 	st_matrix("r(b)",  beta)
			mata: 	st_matrix("r(V)", vcov)
			mata: 	st_numscalar("r(loglik)", loglik)
			mata: 	st_matrix("r(Psi)", par2Psi(parf, cols(Z)))
			mata: st_numscalar("r(aic)", -2*loglik+2*(cols(beta)+cols(parf)))
		    mata: st_numscalar("r(nre)", cols(parf))
			// get log-likelihood setting all var/cov equal to zero
			mata: parf = J(1, cols(parf), 0)
			mata: est = glsfit_reml(X, Z, y, C, parf, id) 
			mata: st_numscalar("r(loglik0)", *est[8])
			matrix `b' = r(b)
			matrix `V' = r(V)
	}
	
	tempname loglik loglik0 Psi aic nvcp  k_f k 
	scalar `loglik' = r(loglik)
	scalar `loglik0' = r(loglik0)
	matrix `Psi' = r(Psi)
	scalar `aic' = r(aic)
	scalar `nvcp' = r(nre)
	scalar `k_f' = colsof(`b')
	scalar `k' = `k_f' + `nvcp'
	
	// two-stage approach

	if ("`2stage'" != "")   {
	
		qui tab `id' if `touse'
		local nstudies = r(r)
		if (`nstudies'==1) {
					di _n as err "more than one study is needed for the two-stage approach"
					exit 198
		}
	
		// call mvmeta command		
		quietly capture which mvmeta
        if _rc != 0 qui net install  st0156_2, from(http://www.stata-journal.com/software/sj15-4) 

		if "`acov'"=="" & "`mcov'"=="" & "`vcov'"=="" {
			 qui mvmeta_make  drmeta_cov `varlist' , s(`se') tot(`n') c(`case') ts(`typestudy')  `crudes'  `vwls'  ecovmethod(`covmethod') ///
			 saving(_glst_mvmeta_est) replace by(`id')  names(b V) 
		}

		if "`acov'"!="" {
			 qui mvmeta_make  drmeta_cov `varlist' , s(`se') ts(`typestudy')  `vwls'  meancov(`acov') ///
			 saving(_glst_mvmeta_est) replace by(`id')  names(b V) 
		}

		// With multiple studies the user can specify the a list of covariance matrix following the order of the studies.
			
		local passm : word `countstudy' of `mcov'

		if "`mcov'"!="" {
			 qui mvmeta_make drmeta_cov `varlist'  , s(`se') ts(`typestudy')   `vwls'   matrixcov(`passm') ///
			 saving(_glst_mvmeta_est) replace by(`id')  names(b V) 
		}

		if "`vcov'"!="" {
			 qui mvmeta_make drmeta_cov `varlist'  , s(`se') ts(`typestudy')   `vwls'   varlistcov(`vcov') ///
			 saving(_glst_mvmeta_est) replace by(`id')  names(b V) 
		}
		
		preserve
			qui use _glst_mvmeta_est, clear
			if "`mvopt'" != "fixed"   capture quietly  mvmeta b V , bscovariance(unstructured) `mvopt' 
			else capture quietly  mvmeta b V  , `mvopt'		     
			capture estimates save _glst_mvmeta_results ,   replace
		restore 
		tempname getb getV getSigma nvcp Q Q_df Q_p
		mat `getSigma' = e(Sigma)
		matrix `Psi' = `getSigma'
		scalar `nvcp' = (colsof(`getSigma')*(colsof(`getSigma')-1))/2 + colsof(`getSigma')
		mat `getb' = e(b)
		if "`mvopt'" != "fixed" local pickeq "Overall_mean:"
		else local pickeq "Overall:"
		mat `b' = `getb'[1, "`pickeq'"] 
		mat `getV' = e(V)
		matrix `V' = `getV'["`pickeq'", "`pickeq'"]
		local df_m = e(df_m)
		local df = `nstudies'-1
		tempname loglik loglik0 aic k_f k
		if "`mvopt'" != "fixed" scalar `loglik' = e(ll)
		else scalar `loglik' = e(ll0)
		scalar `loglik0' = e(ll0)
		scalar `k_f' = e(fixedparms)
		scalar `k' = `k_f' + `nvcp'
		scalar `aic' = -2*`loglik' + 2*`k'  	
		scalar `Q' = e(Qscalar_chi2)
		scalar `Q_df' =  e(Qscalar_df)
		scalar `Q_p' = chi2tail(`Q_df', `Q')
	}
} // end multiple studies
 

// Single study

if "`id'" == "" {

		if "`acov'"=="" & "`mcov'"=="" & "`vcov'"=="" {
			drmeta_cov `varlist' `if' `in' , s(`se') tot(`n') c(`case') ///
			`pecohort' `ptcohort' `casecontrol' `meandiff' `stdmeandiff' `crudes'  `vwls' ecovmethod(`covmethod')
			tempname A B
			mat  `A' = e(cases)
			mat  `B' = e(noncases)	
		}
		
		if "`acov'"!="" {
			drmeta_cov `varlist' `if' `in' , s(`se')  ///
			`crudes'  `vwls' meancov(`acov')  
		}

		if "`mcov'"!="" {
			drmeta_cov `varlist' `if' `in' , s(`se')  ///
			 `crudes'  `vwls'  matrixcov(`mcov')  
		}

		if "`vcov'"!="" {
			drmeta_cov `varlist' `if' `in' , s(`se')  ///
			`crudes'  `vwls'  varlistcov(`vcov')  
		}
		
	tempname b V COV R k k_f k_r R2 D p_D

	local obs = e(N)
	mat `COV' = e(C)
	mat `R' = e(R)
 
	mat `b' = e(BC)'
	mat `V' = e(VB)  
    local loglik = r(LL)
	local aic = -2*r(LL)+2*colsof(`b')
    local nstudies = 1
	scalar `k' = colsof(`b')
	scalar `k_f' = colsof(`b')
	scalar `k_r' = 0
	scalar `R2' = .
	scalar `D' = .
	scalar `p_D' = .
   
} // End Single study

// Saved results
 
	mat rownames `b' = `depname'
	mat colnames `b' = `xname'

	mat rownames `V' = `xname'
	mat colnames `V' = `xname'

    if "`mvopt'" != "fixed" {
		mat rownames `Psi' = `xname'
		mat colnames `Psi' = `xname'
	}
	mat coleq `b' = ""
	mat roweq `V' = ""	
	mat coleq `V' = ""
    tempname _bcombined
    matrix `_bcombined' = `b'
	local df = `obs' - rowsof(`V')
	tempvar tousecopy 
	gen `tousecopy' = `touse'
	ereturn post `b' `V' , dep(`depname') obs(`obs') esample(`touse')   

	if "`id'" == "" {
		ereturn matrix Sigma = `COV'
		ereturn matrix R = `R'
		
		if "`acov'"=="" & "`mcov'"=="" & "`vcov'"=="" {
			ereturn matrix FC = `A'
			ereturn matrix FNC = `B'
		}

	}
	else {
		ereturn matrix Sigma = `G'
	}

ereturn scalar k = `k'
ereturn scalar k_f = `k_f'
if "`id'" != "" & "`mvopt'" != "fixed" ereturn scalar k_r = `nvcp'
else  ereturn scalar k_r = 0
ereturn scalar aic = `aic'
ereturn scalar ll = `loglik'
if "`id'" != "" & "`mvopt'" != "fixed"  ereturn scalar ll_c = `loglik0'
else ereturn scalar ll_c = .
ereturn local cmd = "drmeta"
ereturn local depvar = "`depname'"
ereturn local se = "`se'"
if "`mvopt'" == "fixed" ereturn local method "gls" 
else ereturn local method "`mvopt'"
ereturn local cmdline "drmeta `0'"
ereturn local dm "`xname'"
ereturn local type `random'
ereturn local proc `stage'
ereturn local predict "drmeta_predict"
ereturn local id "`studies'"
if "`id'" != "" {
ereturn scalar r2 = `R2'
ereturn scalar D = `D'
ereturn scalar p_D = `p_D' 
ereturn matrix ty = `ty'
ereturn matrix tX = `tX'
ereturn matrix tres = `tres'
ereturn matrix tpred = `tpred'
}

if ("`2stage'" != "")   {
	ereturn scalar Q = `Q'
	ereturn scalar Q_df = `Q_df'
	ereturn scalar Q_p = `Q_p'
}

if "`e(type)'" == "random" {
	foreach study of local studies { 
		matrix S`study' = _X`study'*matrix(`Psi')*_X`study'' + _C`study'
		matrix blup`study' = matrix(`Psi')*_X`study''*invsym(S`study')*(_B`study'-_X`study'*`_bcombined'')
		matrix blup`study' = blup`study''
		mat rownames blup`study' = "blup_`study'"
		mat colnames blup`study' = `xname'
		matrix xbu`study' = `_bcombined' + blup`study'
		mat rownames xbu`study' = "xb_blup_`study'"
		mat colnames xbu`study' = `xname'
		ereturn matrix xbu`study' = xbu`study'
		ereturn matrix blup`study' = blup`study'
		ereturn matrix Sigma`study' = _C`study'
		ereturn matrix X`study' = _X`study'
		mat _BS`study' = _BS`study''
		mat rownames _BS`study' = "gls_`study'"
		mat colnames _BS`study' = `xname'
		mat rownames _VS`study' = `xname'
		mat colnames _VS`study' = `xname'
		ereturn matrix bs`study' = _BS`study'
		ereturn matrix vs`study' = _VS`study'
		ereturn scalar r2_`study' = `R2_`study''
	}
}

if "`e(type)'" != "random" {
	foreach study of local studies { 
		ereturn matrix Sigma`study' = _C`study'
		ereturn matrix X`study' = _X`study'
		ereturn matrix bs`study' = _BS`study'
		ereturn matrix vs`study' = _VS`study'
		ereturn scalar r2_`study' = `R2_`study''
	}
}

if ("`id'"!= "") {
                 if "`mvopt'" != "fixed" {	
											tempname PsiC copyPsi tagPsi copyPsiC
											matrix `copyPsi' = `Psi'
											matrix `tagPsi' = J(rowsof(`Psi'), rowsof(`Psi'),0)
											matrix `PsiC' = corr(`Psi')
										    matrix `copyPsiC' = `PsiC'
											ereturn matrix Psi = `Psi'
											ereturn matrix PsiC = `PsiC'
											}
				 ereturn local idname "`id'"
				 }
*ereturn scalar chi2_gf = r(Q)

if ("`2stage'"!= "") &  (`ncov'==1) ereturn scalar chi2_gf = `Q'

// Q-test heterogeneity

 	if `df' > 0 {
		 if "`id'" == "" eret scalar chi2_gf = r(chi2_gf2)
		}
		else {
			eret scalar chi2_gf = .
		}

/* compute test of indepvars = 0 */

qui testparm  `xname' 
 
eret scalar df_m = r(df)
eret scalar chi2 = r(chi2)
eret scalar p = r(p)

eret scalar N_s = `nstudies'

sort `order'

display_result, level(`level') `eform'   `vwls' nv(`ncov')  

if "`noretable'" == "" & "`mvopt'" != "fixed" {
 
    di as txt "{hline 29}{c TT}{hline 15}
	di as txt _col(3) "Random-effects parameters" _col(30) "{c |}" _col(34) "Estimate" 
	di as txt "{hline 29}{c +}{hline 15}
	
	* diagonal elements
	local i = 1
	foreach v of local xname {
			 if "`stddeviations'" == "" di as txt "var(" abbrev("`v'", 12) "," abbrev("`v'", 12) ")" _col(30) "{c |}" as res _col(34)  %9.0g `copyPsi'[`i', `i']
		     else di as txt "std(" abbrev("`v'", 12) "," abbrev("`v'", 12) ")" _col(30) "{c |}" as res _col(34)  %9.0g sqrt(`copyPsi'[`i', `i'])
			 local i = `i' + 1
	}
	
	* out-of-diagonal elements
	local i = 1
	foreach v of local xname {
		local j = 1
		foreach s of local xname {
				if (`i' != `j') & (`tagPsi'[`j', `i']!=1) & ("`stddeviations'" == "") di as txt "cov(" abbrev("`v'", 12) "," abbrev("`s'", 12) ")" _col(30) "{c |}" as res _col(34) %9.0g `copyPsi'[`i', `j']
				if (`i' != `j') & (`tagPsi'[`j', `i']!=1) & ("`stddeviations'" != "") di as txt "corr(" abbrev("`v'", 12) "," abbrev("`v'", 12) ")" _col(30) "{c |}" as res _col(34)  %9.0g `copyPsiC'[`i', `j']
				mat `tagPsi'[`i', `j'] = 1
				local j = `j' + 1
		}
	  local i = `i' + 1
	}
	di as txt "{hline 29}{c BT}{hline 15}
}

if "`nolrt'" == "" & "`mvopt'" != "fixed" {
     di as txt "{help j_mixedlr##|_new:LR test} vs. no random-effects model = " as res 2*abs(`e(ll)'-`e(ll_c)')  _col(55) as txt "Prob >= chi2(" as res `e(k_r)' as txt ") = " _col(73) as res %6.4f chi2tail(`e(k_r)', 2*abs(`e(ll)'-`e(ll_c)'))
	 ereturn scalar lrt_c = 2*abs(`e(ll)'-`e(ll_c)')
	 ereturn scalar df_c = `e(k_r)'
	 ereturn scalar p_c = chi2tail(`e(k_r)', 2*abs(`e(ll)'-`e(ll_c)'))
	 } 		
	
/*
	if "`undetermined'" != "" {
		di as txt _n "{p 0 6 2}Note: The reported degrees of freedom "
		di as txt "assumes the null hypothesis is not on the "
		di as txt "boundary of the parameter space.  If this is not "
		di as txt "true, then the reported test is "
		di as txt "{help j_mixedlr##|_new:conservative}.{p_end}"
	}
	*/
// drop global used 
macro drop  loglik levelci levelp
capture drop `xnamec'
sort `order'

if "`id'" != "" {
	local i = 1
	qui levelsof `id' , local(studies) 
	foreach study of local studies { 
			capture mat drop _VS`i'
	        capture mat drop _BS`i'  
	        capture mat drop _ZS`i' 
			capture mat drop _X`i' 
			capture mat drop _C`i' 
			capture mat drop _B`i' 
			capture mat drop _ZS`i'
			capture mat drop _G`i'
			local i = `i' + 1
	}
}	
capture mat drop R
capture mat drop C
capture mat drop cases
capture mat drop noncases
	
end

capture program drop display_result
program define display_result
version 13
	syntax [, Level(integer $S_level) eform type(string) proc(string) stage vwls nv(string) ]
	if `level' < 10 | `level' > 99 {
		di in red "level() must be between 10 and 99 inclusive"
		exit 198
	}

	tempname pgf pm
	if e(df_gf) > 0 {
		scalar `pgf' = chiprob(e(df_gf), e(chi2_gf))
	}
	else scalar `pgf' = .
	scalar `pm' = chiprob(e(df_m), e(chi2))
 
di _n as txt "`e(proc)' `e(type)'-effect dose-response model" _col(50) "Number of studies = " _col(72)  as res %7.0g e(N_s) 
di  as txt "Optimization   = " as res "`e(method)'"     _col(54) as txt "Number of obs = " _col(72) as res %7.0g e(N)
di as txt  "           AIC = "  as res %5.2f `e(aic)'       _col(54) as txt "Model chi2(" as res e(df_m) as txt ") = " _col(72)  as res %7.2f e(chi2)
di  as txt "Log likelihood = " as res e(ll)   _col(56) as txt "Prob > chi2 = " _col(72) as res %7.4f `pm' 	

if "`eform'" == "" ereturn display, level(`level') 
		else ereturn display, level(`level') eform(exb(b)) 	
end

mata
function blockaccum(string scalar a, string scalar b) 
{	
	real matrix A, B, GA
	A = st_matrix(a)
	B = st_matrix(b)
	GA = blockdiag(A,B)
	st_matrix("r(CACC)", GA)
}

function glsest(string scalar y, string scalar x, string scalar cov)
{
	real matrix Y, X, C, BC, VB
	real scalar Q, LL 
	Y = st_matrix(y)
	X = st_matrix(x)
	C = st_matrix(cov)
 
// Variance and betas

	VB = invsym(X'*invsym(C)*X)
	BC = invsym(X'*invsym(C)*X)*X'*invsym(C)*Y
 
// Q goodness of fit

 	Q = (Y-X*BC)'*invsym(C)*(Y-X*BC)
	C2 = diag(C)

// log-likelihood

	LL =  -.5*rows(Y)*log(2*pi())-.5*log(det(C))-.5*Q

	st_matrix("r(BC)", BC)
	st_matrix("r(VB)", VB)
	st_numscalar("r(Q)", Q)
	st_numscalar("r(LL)", LL)
	st_matrix("r(COVAR)", C)
}

real matrix par2Psi(par, q){
    L = J(q,q,0)
	T = lowertriangle(J(q,q,.)):!=0
	k = 1
		for (i=1; i<=q; i++) {			       
				for (j=1; j<=q; j++) {
			        if (T[i,j]==1) {
					               L[i,j] = par[1,k]
					               k = k + 1
					}
				 }
        }
L=lowertriangle(L)
return(L*L')
}

function glsfit_fixed(X, Z, y, C, par, id){
		pointer vector info
		n = rows(uniqrows(id))
		q = cols(Z)
		nall = rows(y)
        Psi = par2Psi(par,q)
        idn = uniqrows(id)
		for (i=1; i<=n; i++) {
			Zi = select(Z, id:==idn[i]) 
			Si = select(select(C, (id:==idn[i])), (id:==idn[i])')
			Sigmalisti = makesymmetric(Si + Zi*Psi*Zi')
			Ulist = cholesky(Sigmalisti)'	
			invUlist  = luinv(Ulist)
			yi = select(y, id:==idn[i])
			invtUylist = invUlist'*yi
			Xi = select(X, id:==idn[i])
			invtUXlist = invUlist'*Xi
			tXWXlist = invtUXlist'*invtUXlist

			if (i==1) 	{
					invtUy =   invtUylist
					invtUX =   invtUXlist
					diagUlist = ln(diagonal(Ulist))
					tXWXtot = tXWXlist
				}
				else {
					invtUy  = invtUy \ invtUylist
					invtUX  = invtUX \ invtUXlist
					diagUlist = diagUlist \ ln(diagonal(Ulist))
					tXWXtot = tXWXtot :+ tXWXlist
					}
					
			}
		
		  coef = qrsolve(invtUX, invtUy)

		  Q = R = .
		  qrd(invtUX, Q, R)		  
		  R= R[|1,1\q,q|]
		  vcov = solveupper(R, diag(J(q,q,1))) * solveupper(R, diag(J(q,q,1)))'
		  pconst = -0.5 * nall * log(2 * pi())
		  pres = -0.5*(invtUy - invtUX*coef)'*(invtUy - invtUX*coef)
		  pdet1 = -sum(diagUlist)
		  pdet2 = -sum(log(diagonal(cholesky(tXWXtot))))
	      
		  lf = (pconst + pdet1 + pres) 

		  Psip = &Psi
		  invtUXp = &invtUX 
		  invtUyp = &invtUy 
		  diagUlistp = &diagUlist
		  tXWXtotp = &tXWXtot 
		  coefp = &coef
		  vcovp = &vcov
		  lfp = &lf
		 		  
		  info = (invtUXp, invtUyp, diagUlistp, tXWXtotp, Psip, coefp, vcovp, lfp)
		  return(info)	
}

function glsfit_reml(X, Z, y, C, par, id){
		pointer vector info
		n = rows(uniqrows(id))
		q = cols(Z)
		nall = rows(y)
		Psi = par2Psi(par,q)
		idn = uniqrows(id)

		for (i=1; i<=n; i++) {
		
			Zi = select(Z, id:==idn[i]) 
			Si = select(select(C, (id:==idn[i])), (id:==idn[i])')
			Sigmalisti = makesymmetric(Si + Zi*Psi*Zi')
			Ulist = cholesky(Sigmalisti)'	
			invUlist  = luinv(Ulist)
			yi = select(y, id:==idn[i])
			invtUylist = invUlist'*yi
			Xi = select(X, id:==idn[i])
			invtUXlist = invUlist'*Xi
			tXWXlist = invtUXlist'*invtUXlist
			
			if (i==1) 	{
					invtUy =   invtUylist
					invtUX =   invtUXlist
					diagUlist = ln(diagonal(Ulist))
					tXWXtot = tXWXlist
				}
				else {
					invtUy  = invtUy \ invtUylist
					invtUX  = invtUX \ invtUXlist
					diagUlist = diagUlist \ ln(diagonal(Ulist))
					tXWXtot = tXWXtot :+ tXWXlist
					}
					
		  }
		  coef = qrsolve(invtUX, invtUy)
		  
		  Q = R = .
		  qrd(invtUX, Q, R)		  
		  R= R[|1,1\q,q|]
		  vcov = solveupper(R, diag(J(q,q,1))) * solveupper(R, diag(J(q,q,1)))'
		  pconst = -0.5 * (nall - q) * log(2 * pi())
		  pres = -0.5*(invtUy - invtUX*coef)'*(invtUy - invtUX*coef)
		  pdet1 = -colsum(diagUlist)
		  pdet2 = -colsum(log(diagonal(cholesky(tXWXtot))))
		
		  lf = (pconst + pdet1 + pdet2 + pres) 
	
		  Psip = &Psi
		  invtUXp = &invtUX 
		  invtUyp = &invtUy 
		  diagUlistp = &diagUlist
		  tXWXtotp = &tXWXtot 
		  coefp = &coef
		  vcovp = &vcov
		  lfp = &lf
		 		  
		  info = (invtUXp, invtUyp, diagUlistp, tXWXtotp, Psip, coefp, vcovp, lfp)
		  return(info)	
}

function glsfit_ml(X, Z, y, C, par, id){
		pointer vector info
		n = rows(uniqrows(id))
	    idn = uniqrows(id)
		q = cols(Z)
		nall = rows(y)
		Psi = par2Psi(par,q)
		for (i=1; i<=n; i++) {
			Zi = select(Z, id:==idn[i]) 
			Si = select(select(C, (id:==idn[i])), (id:==idn[i])')
			Sigmalisti = makesymmetric(Si + Zi*Psi*Zi')
			Ulist = cholesky(Sigmalisti)'	
			invUlist  = luinv(Ulist)
			yi = select(y, id:==idn[i])
			invtUylist = invUlist'*yi
			Xi = select(X, id:==idn[i])
			invtUXlist = invUlist'*Xi
			tXWXlist = invtUXlist'*invtUXlist


			if (i==1) 	{
					invtUy =   invtUylist
					invtUX =   invtUXlist
					diagUlist = ln(diagonal(Ulist))
					tXWXtot = tXWXlist
				}
				else {
					invtUy  = invtUy \ invtUylist
					invtUX  = invtUX \ invtUXlist
					diagUlist = diagUlist \ ln(diagonal(Ulist))
					tXWXtot = tXWXtot :+ tXWXlist
					}
					
			}
		  coef = qrsolve(invtUX, invtUy)
		  
		  Q = R = .
		  qrd(invtUX, Q, R)		  
		  R= R[|1,1\q,q|]
		  vcov = solveupper(R, diag(J(q,q,1))) * solveupper(R, diag(J(q,q,1)))'
		  pconst = -0.5 * nall * log(2 * pi())
		  pres = -0.5*(invtUy - invtUX*coef)'*(invtUy - invtUX*coef)
		  pdet1 = -sum(diagUlist)
		  pdet2 = -sum(log(diagonal(cholesky(tXWXtot))))

		  lf = (pconst + pdet1 + pres) 
		  
		  Psip = &Psi
		  invtUXp = &invtUX 
		  invtUyp = &invtUy 
		  diagUlistp = &diagUlist
		  tXWXtotp = &tXWXtot 
		  coefp = &coef
		  vcovp = &vcov
		  lfp = &lf
		 		  
		  info = (invtUXp, invtUyp, diagUlistp, tXWXtotp, Psip, coefp, vcovp, lfp)
		  return(info)	
}

void remlprof_fn(todo, par, X, Z, y, C, id, lf, g, H){ 
		q = cols(Z)
		nall = rows(y)
		Psi = par2Psi(par,q)
		get_gls = glsfit_reml(X, Z, y, C, par, id)
		lf = *get_gls[8]
}

void mlprof_fn(todo, par, X, Z, y, C, id, lf, g, H){ 
		q = cols(Z)
		nall = rows(y)
		Psi = par2Psi(par,q)
		get_gls = glsfit_ml(X, Z, y, C, par, id)
		lf = *get_gls[8]
}

end
