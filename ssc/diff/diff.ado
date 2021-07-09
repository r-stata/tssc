capture program drop diff 
program define diff, rclass
*! 5.0.1 Dec2019
version 10.0

************************************************************
************************************************************
**** Program designer: Juan M. Villa					
**** Affiliation: Global Development Institute		
****              University of Manchester     		
************************************************************
************************************************************


#delimit ;
syntax varlist(min=1) 
[in] [if] [fw aw pw iw]
 , Period(string)
 Treated(string)
 [ Cov(varlist)
 id(string) 
 Kernel
 bw(real 0.06)
 KType(string)
 rcs
 QDid(real 0.0)
 PScore(string)
 LOgit
 SUPport
 ADDcov(varlist)
 test
 REPort
 NOStar
 bs
 Reps(integer 50)
 CLuster(string)
 robust
 ddd(string) ]
 ;
 #delimit cr 

**********************************
* Set output variable and sample *
**********************************
marksample touse
tokenize `varlist'
tempvar output
qui: gen `output' = `1'
capture drop _diff
********************
* Bootstrap prefix *
********************

if "`bs'" != "" {
	if `reps' != . {
		local rep ,reps(`reps')
	}
	local bsp noisily: bs `rep' notable noheader:
	if `qdid' == 0.0 {
		local est r(chi2)
		local inf z
	}
	else if `qdid' != 0.0 {
		local est r(chi2)
		local inf z
	}
}

else if "`bs'" == "" {
	local bsp ""
	local est r(F)
	local inf t
}

if "`cluster'" != "" {
	local clust cluster(`cluster')
}

************
* Warnings *
************

if "`period'" == "" {
	di as err "Option period() not specified"
	exit 198
}
else if "`treated'" == "" {
	di as err "Option treated() not specified"
	exit 198
}
if "`cov'" == "" & "`report'" != "" & "`pscore'" == "" {
	di as err "Option report works when cov(varlist) is specified"
	exit 198
}
if "`test'" != "" & "`cov'" == "" {
	di as err "No covariates specified in option cov()"
	exit 198
}
if "`kernel'" == "" & "`rcs'" != "" {
	di as err "Option rcs requires specification of kernel"
	exit 198
}
if "`kernel'" != "" & "`ddd'" != "" {
	di as err "Option kernel is not compatible with option ddd()"
	exit 198
}
if `qdid' != 0.0 & "`ddd'" != "" {
	di as err "Option qdid() is not compatible with option ddd()"
	exit 198
}
if "`test'" != "" & "`ddd'" != "" {
	di as err "Option test is not compatible with option ddd()"
	exit 198
}

********************************
********************************
** KERNEL OPTION CALCULATIONS **
********************************
********************************

if "`cov'" != "" & "`test'" == "" & "`ddd'" == "" {
	if "`kernel'" == "" & `qdid' == 0.0 {
		di in smcl in ye "{title:DIFFERENCE-IN-DIFFERENCES WITH COVARIATES}"
	}
	if "`kernel'" == "" & `qdid' != 0.0 {
		di in smcl in ye "{title:QUANTILE DIFFERENCE-IN-DIFFERENCES WITH COVARIATES}" _n 
	}
}
else if "`cov'" != "" & "`test'" == "" & "`ddd'" != "" {
	if "`kernel'" == "" & `qdid' == 0.0 {
		di in smcl in ye "{title:TRIPLE DIFFERENCE-IN-DIFFERENCES WITH COVARIATES}"
	}
}
***********
* Warning * 
***********

if "`kernel'" != "" {
	if "`id'" == "" & "`rcs'" == "" {
		di as err "id(varname) required with option kernel"
		exit 198
	}
	
	********************************
	* Delete previous calculations *
	********************************
	
	if "`pscore'" == "" {
		capture drop _ps 
	}
	capture drop _weights 
	capture drop _wght_
	capture drop _support
	capture drop _`1'
	capture drop _weights_rcs
	
	
	**********
	* Header *
	**********
	
	if "`test'" == "" & `qdid' == 0.0 {
		di in smcl in ye "{title:KERNEL PROPENSITY SCORE MATCHING DIFFERENCE-IN-DIFFERENCES}"
	}
	if "`test'" == ""  & `qdid' != 0.0 {
		di in smcl in ye "{title:KERNEL PROPENSITY SCORE MATCHING QUANTILE DIFFERENCE-IN-DIFFERENCES}"
	}
		if "`test'" == ""  & "`rcs'" != "" {
		di in smcl in ye "{pstd}Repeated Cross Section - rcs option{p_end}"
	}
	if "`test'" == ""  & "`support'" != "" {
		di in smcl in ye "{pstd}Estimation on common support{p_end}"
	}
	
	
	***********
	* Warning * 
	***********
	
	if "`cov'" == "" & "`kernel'" != "" & "`pscore'" == "" {
	di as err "No covariates specified in cov(varlist)"
	exit 198
	}

	*******************************
	* Propensity Score estimation * 
	*******************************	
	
	if "`report'" == "" {
		local repo qui:
	}
	if "`pscore'" == "" {
		if "`logit'" == "" {
			if "`report'" != "" {
				di in smcl in ye "{pstd}Report - Propensity score estimation with {cmd:probit} command{p_end}"
				di in smcl in ye "{pstd}Atention: {it:_pscore} is estimated at baseline{p_end}" 
			}	
		`repo' probit `treated' `cov' if `touse' & `period' == 0 [`weight'`exp']
		}
		if "`logit'" != "" {
			if "`report'" != "" {
			di in smcl in ye "{pstd}Report - Propensity score estimation with {cmd:logit} command{p_end}"
			di in smcl in ye "{pstd}Atention: {it:_pscore} is estimated at baseline{p_end}"
			}		
		`repo' logit `treated' `cov' if `touse' & `period' == 0 [`weight'`exp']
		}		
		qui: predict _ps if `touse' & `period' == 0, p
		label var _ps "Estimated Propensity Score (pscore)"
		if "`rcs'" == "" {
			local pscore _ps
		}
	}
	if "`pscore'" == "" & "`rcs'" != "" {
		if "`report'" != "" {
			di in smcl in ye "{pstd}Complementary propensity score estimation for repeated cross sections{p_end}"
		}	
		if "`logit'" == "" {
			if "`report'" != "" {
			di in smcl in ye "{pstd}Report - Propensity score estimation with {cmd:probit} command{p_end}"
			di in smcl in ye "{pstd}Atention: complementary {it:_pscore} is estimated at follow up{p_end}"
			}	
		`repo' probit `treated' `cov' if `touse' & `period' == 1 [`weight'`exp']
		}
		if "`logit'" != "" {
			if "`report'" != "" {
			di in smcl in ye "{pstd}Report - Propensity score estimation with {cmd:logit} command{p_end}"
			di in smcl in ye "{pstd}Atention: complementary {it:_pscore} is estimated at follow up{p_end}"
			}		
		`repo' logit `treated' `cov' if `touse' & `period' == 1 [`weight'`exp']
		}
		tempvar ps_rcs
		qui: predict `ps_rcs' if `touse' & `period' == 1, p
		qui: replace _ps = `ps_rcs' if `touse' & `period' == 1
		label var _ps "Estimated Propensity Score (pscore) for repeated cross section"
		local pscore _ps
	}

	
	******************
	* Common support * 
	******************
	
	if "`support'" != "" {
		tempvar common
		qui: gen `common' = `pscore'
		capture sort `id' `period'
		capture qui: bysort `id': replace `common' = `common'[_n-1] if `common' == .
		qui: summ `common' if `treated' == 1
		local supmin = r(min)
		qui: summ `common' if `treated' == 0
		local supmax = r(max)
		
		qui: gen _support = `common' >= `supmin' & `common' <= `supmax'
		label var _support "Common support of the Propensity Score"
		local comsup & _support
	}
	
	*******************************************
	* Kernel function estimation given the PS * 
	*******************************************	
	* ACKWNOLEGMENT: This section is based on the Kernel option of the command psmatch2 by Leuven and Sianesi.
	if "`rcs'" == "" {	
		qui: gen _weights = 0 // `treated' if `period' == 0 
		label var _weights "Weights from the Kernel function"
			
		qui: count if `treated' == 1 & `period' == 0 & `touse' `comsup'
		local N = r(N)
		
		tempvar wkernel dif kid
		gsort -`treated' `period' `id'
		qui: gen `kid' = _n if `treated' == 1 & `period' == 0 & `touse' `comsup'
		sort `kid'
		
		di in smcl in gr "{pstd}Matching iterations...{p_end}"
		local count = 1
		while `count' <= `N' {
			
			qui: gen `dif' = abs(`pscore'-`pscore'[`count']) if `period' == 0 & `touse' `comsup'
			if "`ktype'" == "" {
				qui: gen `wkernel'  = 1 - (`dif'/`bw')^2 if abs(`dif') <= `bw' 
				}
			else if "`ktype'" == "epanechnikov" {
				qui: gen `wkernel' = 1 - (`dif'/`bw')^2 if abs(`dif') <= `bw' 
				}
			else if "`ktype'" == "gaussian" {
				qui: gen `wkernel' = normalden(`dif'/`bw') 
				}
			else if "`ktype'" == "biweight" {
				qui: gen `wkernel' = (1 - (`dif'/`bw')^2)^2 if abs(`dif') <= `bw'
				}
			else if "`ktype'" == "uniform" {
				qui: gen `wkernel' = 1 if abs(`dif') <= `bw'
				}
			else if "`ktype'" == "tricube" {
				qui: gen `wkernel' = 1 - abs((`dif'/`bw')^3)^3 if abs(`dif') <= `bw'
				}			
					
			* Weights calculation
			qui: summ `wkernel'  if `treated' == 0 & `period' == 0 & `touse' `comsup', meanonly
			qui: replace `wkernel'  = `wkernel'/r(sum) 
			qui replace _weights = _weights + `wkernel'  if `period' == 0 & `wkernel' != . & `treated' == 0
			
			capture drop `wkernel' `dif'
			
			local count = `count' + 1
			
			di _continue in gr "." 
		}

		capture drop `kid'
		sort `id' `treated' `period'
		qui: bysort `id': replace _weights = _weights[_n-1] if `period' == 1
		
		qui: replace _weights = 1 if `treated' == 1 & `touse' `comsup'
		
		local krn [aw=_weights] 
	}

	******************************************************************************
	* Kernel function estimation given the PS - For Repeated Cross Section (rcs) * 
	******************************************************************************	
	* ACKWNOLEGMENT: This section is based on the Kernel option of the command psmatch2 by Leuven and Sianesi.
	if "`rcs'" != "" {	
		qui: gen _weights_rcs = 0 // `treated' if `period' == 0 
		label var _weights_rcs "Weights from the Kernel function for Repeated Cross Section"
		* Comparison at baseline	
		qui: count if `treated' == 1 & `period' == 0 & `touse' `comsup'
		local N = r(N)
		
		tempvar wkernel dif kid
		gsort -`treated' `period' `id'
		qui: gen `kid' = _n if `treated' == 1 & `period' == 0 & `touse' `comsup'
		sort `kid'
		
		di in smcl in gr "{pstd}Matching iterations: control group at base line...{p_end}"
		local count = 1
		while `count' <= `N' {
			
			qui: gen `dif' = abs(`pscore'-`pscore'[`count']) if `period' == 0 & `touse' `comsup'
			if "`ktype'" == "" {
				qui: gen `wkernel'  = 1 - (`dif'/`bw')^2 if abs(`dif') <= `bw' 
				}
			else if "`ktype'" == "epanechnikov" {
				qui: gen `wkernel' = 1 - (`dif'/`bw')^2 if abs(`dif') <= `bw' 
				}
			else if "`ktype'" == "gaussian" {
				qui: gen `wkernel' = normalden(`dif'/`bw') 
				}
			else if "`ktype'" == "biweight" {
				qui: gen `wkernel' = (1 - (`dif'/`bw')^2)^2 if abs(`dif') <= `bw'
				}
			else if "`ktype'" == "uniform" {
				qui: gen `wkernel' = 1 if abs(`dif') <= `bw'
				}
			else if "`ktype'" == "tricube" {
				qui: gen `wkernel' = 1 - abs((`dif'/`bw')^3)^3 if abs(`dif') <= `bw'
				}			
					
			* Weights calculation
			qui: summ `wkernel'  if `treated' == 0 & `period' == 0 & `touse' `comsup', meanonly
			qui: replace `wkernel'  = `wkernel'/r(sum) 
			qui replace _weights_rcs = _weights_rcs + `wkernel'  if `period' == 0 & `wkernel' != . & `treated' == 0
	
			capture drop `wkernel' `dif'
			
			local count = `count' + 1
			
			di _continue in gr "." 
		}
		capture drop `kid'
		
		* Comparison at follow-up
		qui: count if `treated' == 1 & `period' == 1 & `touse' `comsup'
		local N = r(N)
		
		tempvar wkernel dif kid
		gsort -`treated' `period' `id'
		qui: gen `kid' = _n if `treated' == 1 & `period' == 1 & `touse' `comsup'
		sort `kid'
		
		di in smcl in gr _n "{pstd}Matching iterations: control group at follow up...{p_end}"
		local count = 1
		while `count' <= `N' {
			
			qui: gen `dif' = abs(`pscore'-`pscore'[`count']) if `period' == 1 & `touse' `comsup'
			if "`ktype'" == "" {
				qui: gen `wkernel'  = 1 - (`dif'/`bw')^2 if abs(`dif') <= `bw' 
				}
			else if "`ktype'" == "epanechnikov" {
				qui: gen `wkernel' = 1 - (`dif'/`bw')^2 if abs(`dif') <= `bw' 
				}
			else if "`ktype'" == "gaussian" {
				qui: gen `wkernel' = normalden(`dif'/`bw') 
				}
			else if "`ktype'" == "biweight" {
				qui: gen `wkernel' = (1 - (`dif'/`bw')^2)^2 if abs(`dif') <= `bw'
				}
			else if "`ktype'" == "uniform" {
				qui: gen `wkernel' = 1 if abs(`dif') <= `bw'
				}
			else if "`ktype'" == "tricube" {
				qui: gen `wkernel' = 1 - abs((`dif'/`bw')^3)^3 if abs(`dif') <= `bw'
				}			
					
			* Weights calculation
			qui: summ `wkernel'  if `treated' == 0 & `period' == 1 & `touse' `comsup', meanonly
			qui: replace `wkernel'  = `wkernel'/r(sum) 
			qui replace _weights_rcs = _weights_rcs + `wkernel'  if `period' == 1 & `wkernel' != . & `treated' == 0
	
			capture drop `wkernel' `dif'
			
			local count = `count' + 1
			
			di _continue in gr "." 
		}
		capture drop `kid'
		* Treated at baseline
		qui: count if `treated' == 1 & `period' == 0 & `touse' `comsup'
		local N = r(N)
		
		tempvar wkernel dif kid
		gsort -`treated' `period' `id'
		qui: gen `kid' = _n if `treated' == 1 & `period' == 0 & `touse' `comsup'
		sort `kid'
		
		di in smcl in gr _n "{pstd}Matching iterations: treated group at baseline...{p_end}"
		local count = 1
		while `count' <= `N' {
			
			qui: gen `dif' = abs(`pscore'-`pscore'[`count']) if `period' == 0 & `touse' `comsup'
			if "`ktype'" == "" {
				qui: gen `wkernel'  = 1 - (`dif'/`bw')^2 if abs(`dif') <= `bw' 
				}
			else if "`ktype'" == "epanechnikov" {
				qui: gen `wkernel' = 1 - (`dif'/`bw')^2 if abs(`dif') <= `bw' 
				}
			else if "`ktype'" == "gaussian" {
				qui: gen `wkernel' = normalden(`dif'/`bw') 
				}
			else if "`ktype'" == "biweight" {
				qui: gen `wkernel' = (1 - (`dif'/`bw')^2)^2 if abs(`dif') <= `bw'
				}
			else if "`ktype'" == "uniform" {
				qui: gen `wkernel' = 1 if abs(`dif') <= `bw'
				}
			else if "`ktype'" == "tricube" {
				qui: gen `wkernel' = 1 - abs((`dif'/`bw')^3)^3 if abs(`dif') <= `bw'
				}			
					
			* Weights calculation
			qui: summ `wkernel'  if `treated' == 1 & `period' == 0 & `touse' `comsup', meanonly
			qui: replace `wkernel'  = `wkernel'/r(sum) 
			qui replace _weights_rcs = _weights_rcs + `wkernel'  if `period' == 0 & `wkernel' != . & `treated' == 1
	
			capture drop `wkernel' `dif'
			
			local count = `count' + 1
			
			di _continue in gr "." 
		}
		
		qui: replace _weights_rcs = 1 if `treated' == 1 & `period' == 1 & `touse' `comsup'
		local krn [aw=_weights_rcs] 
	}
}
*********************************
*********************************
**** BALANCING TEST - T TEST ****
*********************************
*********************************

***********
* Warning * 
***********

if "`test'" != "" & "`ddd'" == "" {
	if "`cov'" == "" & "`kernel'" == "" & "`pscore'" == "" {
		di as err "No covariates specified in cov(varlist)"
		exit 198
	}
	
	**************
	* Set sample *
	**************


	tempname totobs
	qui: summ `touse' if `touse'
	scalar `totobs' = r(N)
	tempname blo0
	qui: summ `touse' if `period' == 0 & `treated' == 0 & `touse'
	scalar `blo0' = r(N)
	tempname blo1
	qui: summ `touse' if `period' == 0 & `treated' == 1 & `touse'
	scalar `blo1' = r(N)
	tempname flo0
	qui: summ `touse' if `period' == 1 & `treated' == 0 & `touse'
	scalar `flo0' = r(N)
	tempname flo1
	qui: summ `touse' if `period' == 1 & `treated' == 1 & `touse'
	scalar `flo1' = r(N)
	return clear

	*************************************************************
	* Unweighted covariates (if kernel option is not specified) *
	*************************************************************
	
	if "`kernel'" == "" {
		preserve 
		qui: keep if `period' == 0
		di in smcl in ye "{title:TWO-SAMPLE T TEST}"
		di in gr _n "Number of observations (baseline):" in ye " " `blo0' + `blo1'
		di in gr "            Before         After    "
		di in gr "   Control:" in ye _col(13) `blo0' _col(28) "-" in gr _col(40) `blo0'
		di in gr "   Treated:" in ye _col(13) `blo1' _col(28) "-" in gr _col(40) `blo1'
		di _col(13) `blo0' + `blo1' in gr _col(28) "-" 

		#delimit ;
		di in smcl _n _col(0) in gr "t-test at period = 0:" ; 

		di in gr "{hline 94}";
		di	 in gr  
		" Variable(s)         {c |}   Mean Control   {c |} Mean Treated {c |}    Diff.   {c |}   |t|   {c |}"/*;
		*/"  Pr(|T|>|t|)" _n

		"{hline 21}{c +}{hline 18}{c +}{hline 14}{c +}{hline 12}{c +}{hline 9}{c +}"/*;
		*/"{hline 15}";
		
		*Outcome;
		if `period' == 0 {;
			qui: reg `output' `treated' `krn' `in' `if', `robust' `clust';
			tempname `output'_ttest_mc `output'_ttest_mt `output'_ttest_t `output'_ttest_p;
			scalar ``output'_ttest_mc' = _b[_cons];
			scalar ``output'_ttest_mt' = _b[_cons]+_b[`treated'];
			scalar ``output'_ttest_t' = _b[`treated']/_se[`treated'];
			qui: test _b[`treated'] = 0;
			scalar ``output'_ttest_p' = r(p);
				if ``output'_ttest_p' < 0.01 & "`nostar'" == "" {;
					local star`output' "***";
				};
				else if ``output'_ttest_p' > 0.01 & ``output'_ttest_p' < 0.05 & "`nostar'" == "" {;
					local star`output' "**";
				};
				else if ``output'_ttest_p' > 0.05 & ``output'_ttest_p' < 0.1 & "`nostar'" == "" {;
					local star`output' "*";
				};
			
			di in gr in wh abbrev("`1'",12)
			_col(22) in gr "{c |} " in wh %5.3f ``output'_ttest_mc'
			_col(41) in gr "{c |} " in wh %5.3f ``output'_ttest_mt'
			_col(56) in gr "{c |} " in wh %5.3f (``output'_ttest_mt'-``output'_ttest_mc')
			_col(69) in gr "{c |} " in wh %5.2f abs(``output'_ttest_t')
			_col(79) in gr "{c |} " in wh %5.4f ``output'_ttest_p' "`star`output''";
		
		* Covariates;
				
			foreach cov of var `cov' {;
				qui: reg `cov' `treated' `krn' if `touse' `comsup', `robust' `clust';
				tempname `cov'_ttest_mc `cov'_ttest_mt `cov'_ttest_t `cov'_ttest_p;
				scalar ``cov'_ttest_mc' = _b[_cons];
				scalar ``cov'_ttest_mt' = _b[_cons]+_b[`treated'];
				scalar ``cov'_ttest_t' = _b[`treated'] / _se[`treated'];
				qui: test _b[`treated'] = 0;
				scalar ``cov'_ttest_p' = r(p);
					if ``cov'_ttest_p' < 0.01 & "`nostar'" == "" {;
						local star`cov' "***";
					};
					else if ``cov'_ttest_p' >= 0.01 & ``cov'_ttest_p' < 0.05 & "`nostar'" == "" {;
						local star`cov' "**";
					};
					else if ``cov'_ttest_p' >= 0.05 & ``cov'_ttest_p' < 0.1 & "`nostar'" == "" {;
						local star`cov' "*";
					};
				
				di in ye abbrev("`cov'",12)
				_col(22) in gr "{c |} " in ye %5.3f ``cov'_ttest_mc'
				_col(41) in gr "{c |} " in ye %5.3f ``cov'_ttest_mt'
				_col(56) in gr "{c |} " in ye %5.3f (``cov'_ttest_mt'-``cov'_ttest_mc')
				_col(69) in gr "{c |} " in ye %5.2f abs(``cov'_ttest_t')
				_col(79) in gr "{c |} " in ye %5.4f ``cov'_ttest_p' "`star`cov''";
			};
		};

		else if "`'" != "" {;
			exit;
		};
		
		di in gr "{hline 94}{break}"
		in gr "*** p<0.01; ** p<0.05; * p<0.1{break}";
		#delimit cr	
		restore
		exit
	}
	
	*******************************************************
	* Weighted covariates (if kernel option is specified) *
	*******************************************************
	
	if "`kernel'" != "" {
		preserve 
		qui: keep if `period' == 0
		di in smcl in ye _n "{title:TWO-SAMPLE T TEST}" 
		
		if "`support'" != "" {
			di in smcl in ye "{pstd}Test on common support{p_end}"
		}
		
		di in gr _n "Number of observations (baseline):" in ye " " `blo0' + `blo1'
		di in gr "            Before         After    "
		di in gr "   Control:" in ye _col(13) `blo0' _col(28) "-" in gr _col(40) `blo0'
		di in gr "   Treated:" in ye _col(13) `blo1' _col(28) "-" in gr _col(40) `blo1'
		di _col(13) `blo0' + `blo1' in gr _col(28) "-"
		
		#delimit ;
		di in smcl _n _col(0) in gr "t-test at period = 0:" ; 

		di in gr "{hline 94}";
		di	 in gr  
		"Weighted Variable(s) {c |}   Mean Control   {c |} Mean Treated {c |}    Diff.   {c |}   |t|   {c |}"/*;
		*/"  Pr(|T|>|t|)" _n

		"{hline 21}{c +}{hline 18}{c +}{hline 14}{c +}{hline 12}{c +}{hline 9}{c +}"/*;
		*/"{hline 15}";

		*Outcome;
		qui: reg `output' `treated' `krn' `in' `if', `robust' `clust';
		tempname `output'_ttest_mc `output'_ttest_mt `output'_ttest_t `output'_ttest_p;
		scalar ``output'_ttest_mc' = _b[_cons];
		scalar ``output'_ttest_mt' = _b[_cons]+_b[`treated'];
		scalar ``output'_ttest_t' = _b[`treated']/_se[`treated'];
		qui: test _b[`treated'] = 0;
		scalar ``output'_ttest_p' = r(p);
			if ``output'_ttest_p' < 0.01 & "`nostar'" == "" {;
				local star`output' "***";
			};
			else if ``output'_ttest_p' > 0.01 & ``output'_ttest_p' < 0.05 & "`nostar'" == "" {;
				local star`output' "**";
			};
			else if ``output'_ttest_p' > 0.05 & ``output'_ttest_p' < 0.1 & "`nostar'" == "" {;
				local star`output' "*";
			};
		
		di in gr in wh abbrev("`1'",12)
		_col(22) in gr "{c |} " in wh %5.3f ``output'_ttest_mc'
		_col(41) in gr "{c |} " in wh %5.3f ``output'_ttest_mt'
		_col(56) in gr "{c |} " in wh %5.3f (``output'_ttest_mt'-``output'_ttest_mc')
		_col(69) in gr "{c |} " in wh %5.2f abs(``output'_ttest_t')
		_col(79) in gr "{c |} " in wh %5.4f ``output'_ttest_p' "`star`output''";
	
	* Covariates;
			
		foreach cov of var `cov' {;
			qui: reg `cov' `treated' `krn' if `touse' `comsup', `robust' `clust';
			tempname `cov'_ttest_mc `cov'_ttest_mt `cov'_ttest_t `cov'_ttest_p;
			scalar ``cov'_ttest_mc' = _b[_cons];
			scalar ``cov'_ttest_mt' = _b[_cons]+_b[`treated'];
			scalar ``cov'_ttest_t' = _b[`treated'] / _se[`treated'];
			qui: test _b[`treated'] = 0;
			scalar ``cov'_ttest_p' = r(p);
				if ``cov'_ttest_p' < 0.01 & "`nostar'" == "" {;
					local star`cov' "***";
				};
				else if ``cov'_ttest_p' >= 0.01 & ``cov'_ttest_p' < 0.05 & "`nostar'" == "" {;
					local star`cov' "**";
				};
				else if ``cov'_ttest_p' >= 0.05 & ``cov'_ttest_p' < 0.1 & "`nostar'" == "" {;
					local star`cov' "*";
				};
			
			di in ye abbrev("`cov'",12)
			_col(22) in gr "{c |} " in ye %5.3f ``cov'_ttest_mc'
			_col(41) in gr "{c |} " in ye %5.3f ``cov'_ttest_mt'
			_col(56) in gr "{c |} " in ye %5.3f (``cov'_ttest_mt'-``cov'_ttest_mc')
			_col(69) in gr "{c |} " in ye %5.2f abs(``cov'_ttest_t')
			_col(79) in gr "{c |} " in ye %5.4f ``cov'_ttest_p' "`star`cov''";
		};
	};

	else if "`'" != "" {;
		exit;
	};
	
	di in gr "{hline 94}{break}"
	in gr "*** p<0.01; ** p<0.05; * p<0.1{break}" 
	in gr "Attention: option kernel weighs variables in cov(varlist){break}" 
	in gr "Means and t-test are estimated by linear regression{break}";
	#delimit cr	
	restore 	
	exit
}

*********************************
*********************************
**** REGRESSIONS AND SCALARS **** DD
*********************************
*********************************
if "`ddd'" == "" {
	if "`cluster'" != "" {
		local clust cluster(`cluster')
	}
	****************	
	* Coefficients *
	****************

	quietly {
		tempvar interact
		gen _diff = `period' * `treated'
		label var _diff "Diff-in-diff"
		
		local slist "fc0 ft0 f0 fc1 ft1 f1 f11 sec0 se0 sec1 set0 set1 se1 se11 tc0 tt0 td0 tc1 tt1 td1 t11 pc0 pt0 p0 pc1 pt1 p1 p11"
		tempname `slist'
		if "`kernel'" == "" {
			if `qdid' == 0.0 {
				`bsp' reg `output' `period' `treated' _diff `cov' `if' `in' [`weight'`exp'], `robust' `clust'
				tempvar samp
				gen `samp' = e(sample)
			}
			else if `qdid' != 0.0 {
				if "`bs'" == "" {
					qreg `output' `period' `treated' _diff `cov' `if' `in' [`weight'`exp'], `robust' `clust' q(`qdid')
					tempvar samp
					gen `samp' = e(sample)
				}
				if "`bs'" != "" {
					noisily: bs, `clust' reps(`reps') notable noheader: bsqreg `output' `period' `treated' _diff `cov' `if' `in' [`weight'`exp'], q(`qdid') 
					tempvar samp
					gen `samp' = e(sample)
				}
			}
		}
		else if "`kernel'" != "" & "`ddd'" == "" {
			if `qdid' == 0.0 {
				if "`bs'" == "" {
					qui: reg `output' `period' `treated' _diff `addcov' `krn' if `touse' `comsup', `robust' `clust'
					tempvar samp
					gen `samp' = e(sample)
				}
				if "`bs'" != "" {
					noisily: di _n "Bootstrapping..."
					noisily: bootstrap "diffbs `output' `period' `treated' _diff `addcov' if `touse' `comsup'" _b, cluster(`clust') reps(`reps') dots noheader notable
					local cf b_
					local cc b
					tempvar samp
					gen `samp' = 1 if `touse' `comsup'
					}
			}
			else if `qdid' != 0.0 {
				if "`bs'" == "" {
					qreg `output' `period' `treated' _diff `addcov' `krn' if `touse' `comsup', `robust' `clust' q(`qdid')
					tempvar samp
					gen `samp' = e(sample)
				}
				if "`bs'" != "" {
					noisily: bs, `clust' reps(`reps') notable noheader: bsqreg `output' `period' `treated' _diff `addcov' if `touse' `comsup', q(`qdid')
					tempvar samp
					gen `samp' = e(sample)

				}
			}
		}
		
		
		local time _b[`cf'`period']
		local timetr _b[`cf'_diff]
		local control0 _b[`cc'_cons]
		local treat0 (_b[`cc'_cons]+_b[`cf'`treated'])
		local diff0 _b[`cf'`treated']
		local df e(df_r)
						
		local control1  (_b[`cc'_cons]+`time')
		local treatment1 (`control0'+`time'+`diff0'+`timetr')
		local diff1 (`diff0'+`timetr')
		
		*************
		* Base line *
		*************
		
		test `control0' == 0
		scalar `fc0' = `est'
		scalar `sec0' = abs(`control0') / sqrt(`fc0')
		scalar `tc0' = `control0' / `sec0'
		scalar `pc0' = r(p)

		test `treat0' == 0
		scalar `ft0' = `est'
		scalar `set0' = abs(`treat0') / sqrt(`ft0')
		scalar `tt0' = `treat0' / `set0'
		scalar `pt0' = r(p)
		
		test `diff0' == 0
		scalar `f0' = `est'
		scalar `se0' = abs(`diff0') / sqrt(`f0')
		scalar `td0' = `diff0' / `se0'
		scalar `p0' = r(p)
		
		* Stars p0
		if `p0' < 0.01 & "`nostar'" == "" {
			local starp0 "***"
		}
		else if `p0' >= 0.01 & `p0' < 0.05 & "`nostar'" == "" {
			local starp0 "**"
		}
		else if `p0' >= 0.05 & `p0' < 0.1 & "`nostar'" == "" {
			local starp0 "*"
		}
		
		*************
		* Follow up *
		*************
		
		test `control1' == 0
		scalar `fc1' = `est'
		scalar `sec1' = abs(`control1') / sqrt(`fc1')
		scalar `tc1' = `control1' / `sec1'
		scalar `pc1' = r(p)
		
		test `treatment1' == 0
		scalar `ft1' = `est'
		scalar `set1' = abs(`treatment1') / sqrt(`ft1')
		scalar `tt1' = `treatment1' / `set1'
		scalar `pt1' = r(p)
		
		test `diff1' == 0
		scalar `f1' = `est'
		scalar `se1' = abs(`diff1') / sqrt(`f1')
		scalar `td1' = `diff1' / `se1'
		scalar `p1' = r(p)
		
		* Stars p1
		if `p1' < 0.01 & "`nostar'" == "" {
			local starp1 "***"
		}
		else if `p1' >= 0.01 & `p1' < 0.05 & "`nostar'" == "" {
			local starp1 "**"
		}
		else if `p1' >= 0.05 & `p1' < 0.1 & "`nostar'" == "" {
			local starp1 "*"
		}
		
		*******
		* DID *
		*******
		
		test `timetr' == 0
		scalar `f11' = `est'
		scalar `se11' = abs(`timetr') / sqrt(`f11')
		scalar `t11' = `timetr' / `se11'
		scalar `p11' = r(p)
		
		*Stars p11
		if `p11' < 0.01 & "`nostar'" == "" {
			local starp11 "***"
		}
		else if `p11' >= 0.01 & `p11' < 0.05 & "`nostar'" == "" {
			local starp11 "**"
		}
		else if `p11' >= 0.05 & `p11' < 0.1 & "`nostar'" == "" {
			local starp11 "*"
		}
	}	


	****************************
	****************************
	**** TABLES AND REPORTS ****
	****************************
	****************************
	if `qdid' == 0.0 {
		local r2 e(r2)
	}
	else if `qdid' != 0.0 {
		local r2 = 1 - (e(sum_adev)/e(sum_rdev))
	}

	********************
	* Set observations *
	********************
	tempname totobs
	qui: summ `samp' if `samp'
	scalar `totobs' = r(N)
	tempname blo0
	qui: summ `samp' if `period' == 0 & `treated' == 0 & `samp'
	scalar `blo0' = r(N)
	tempname blo1
	qui: summ `samp' if `period' == 0 & `treated' == 1 & `samp'
	scalar `blo1' = r(N)
	tempname flo0
	qui: summ `samp' if `period' == 1 & `treated' == 0 & `samp'
	scalar `flo0' = r(N)
	tempname flo1
	qui: summ `samp' if `period' == 1 & `treated' == 1 & `samp'
	scalar `flo1' = r(N)
	return clear 

	di in smcl in gr _n "{title:DIFFERENCE-IN-DIFFERENCES ESTIMATION RESULTS}" 
	di in gr "{p}Number of observations in the DIFF-IN-DIFF:" in ye " " `totobs' "{p_end}"
	di in gr "            Before         After    "
	di in gr "   Control:" in ye _col(13) `blo0' _col(28) `flo0' in gr _col(40) `flo0' + `blo0'
	di in gr "   Treated:" in ye _col(13) `blo1' _col(28) `flo1' in gr _col(40) `flo1' + `blo1'
	di _col(13) `blo0' + `blo1' in gr _col(28) `flo0' + `flo1' 

	**********
	* Output *
	**********

	#delimit ;
	if "`report'" != "" & "`kernel'" == "" & "`cov'" != "" {;
		di in smcl in ye "{p}Report - Covariates and coefficients:{p_end}" ; 
		di in gr "{hline 21}{c -}{hline 12}{c -}{hline 11}{c -}{hline 9}{c -}"/*;
		*/"{hline 10}";
		di in gr  
		" Variable(s)         {c |}   Coeff.   {c |} Std. Err. {c |}    `inf'    {c |}"/*;
		*/"  P>|`inf'|" _n
		"{hline 21}{c +}{hline 12}{c +}{hline 11}{c +}{hline 9}{c +}"/*;
		*/"{hline 10}";

		/*;Report of covariates*/;
		foreach cov of var `cov' {;
			quietly: test _b[`cov'] == 0 ;
			di in ye  abbrev("`cov'",12)
			_col(22) in gr "{c |} " in ye %5.3f _b[`cov']
			_col(35) in gr "{c |} " in ye %5.3f _se[`cov']
			_col(47) in gr "{c |} " in ye %5.3f _b[`cov']/_se[`cov']
			_col(57) in gr "{c |} " in ye %5.3f r(p);
		};
		
		di in gr "{hline 21}{c -}{hline 12}{c -}{hline 11}{c -}{hline 9}{c -}"/*;
		*/"{hline 10}";
	};

	#delimit ; // additional covariates
	if "`report'" != "" & "`kernel'" != "" & "`addcov'" != "" {;
		di in smcl in ye "{p}Report - Additional covariates and coefficients:{p_end}" ; 
		di in gr "{hline 21}{c -}{hline 12}{c -}{hline 11}{c -}{hline 9}{c -}"/*;
		*/"{hline 10}";
		di in gr  
		" Variable(s)         {c |}   Coeff.   {c |} Std. Err. {c |}    `inf'    {c |}"/*;
		*/"  P>|`inf'|" _n
		"{hline 21}{c +}{hline 12}{c +}{hline 11}{c +}{hline 9}{c +}"/*;
		*/"{hline 10}";

		/*;Report of covariates*/;
		foreach cov of var `addcov' {;
			quietly: test _b[`cov'] == 0 ;
			di in ye  abbrev("`cov'",12)
			_col(22) in gr "{c |} " in ye %5.3f _b[`cov']
			_col(35) in gr "{c |} " in ye %5.3f _se[`cov']
			_col(47) in gr "{c |} " in ye %5.3f _b[`cov']/_se[`cov']
			_col(57) in gr "{c |} " in ye %5.3f r(p);
		};
		
		di in gr "{hline 21}{c -}{hline 12}{c -}{hline 11}{c -}{hline 9}{c -}"/*;
		*/"{hline 10}";
	};

	if "`bs'" != "" {;
		di in gr "{p}Bootstrapped Standard Errors{p_end}{break}";
	};

	di in gr "{hline 56}" _n 
	" Outcome var.   {c |} " in ye  abbrev("`1'",7) _col(27) in gr "{c |} S. Err. {c |}   |t|   {c |}"/*;
	*/"  P>|t|"_n

	"{hline 16}{c +}{hline 9}{c +}{hline 9}{c +}{hline 9}{c +}"/*;
	*/"{hline 9}"_n

	in gr "Before  " 
	_col(17) in gr "{c |} "  
	_col(27) in gr "{c |} "
	_col(37) in gr "{c |} "
	_col(47) in gr "{c |} " _n
	in gr "   Control"
	_col(17) in gr "{c |} " in wh %5.3f `control0'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Treated"
	_col(17) in gr "{c |} " in wh %5.3f `treat0'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Diff (T-C)"
	_col(17) in gr "{c |} " in ye %5.3f `diff0'
	_col(27) in gr "{c |} " in ye %4.3f `se0' 
	_col(37) in gr "{c |} " in ye %4.2f `td0' 
	_col(47) in gr "{c |} " in ye %4.3f `p0' "`starp0'" _n 

	in gr "After    " 
	_col(17) in gr "{c |} "  
	_col(27) in gr "{c |} "
	_col(37) in gr "{c |} "
	_col(47) in gr "{c |} " _n
	in gr "   Control"
	_col(17) in gr "{c |} " in wh %5.3f `control1'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Treated"
	_col(17) in gr "{c |} " in wh %5.3f `treatment1'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Diff (T-C)"
	_col(17) in gr "{c |} " in ye %5.3f `diff1'
	_col(27) in gr "{c |} " in ye %4.3f `se1'
	_col(37) in gr "{c |} " in ye %4.2f abs(`td1')
	_col(47) in gr "{c |} " in ye %4.3f `p1' "`starp1'" _n

	_col(17) in gr "{c |} "  
	_col(27) in gr "{c |} "
	_col(37) in gr "{c |} "
	_col(47) in gr "{c |} " _n

	in gr "Diff-in-Diff" 
	_col(17) in gr "{c |} " in ye %5.3f `timetr'
	_col(27) in gr "{c |} " in ye %4.3f `se11'
	_col(37) in gr "{c |} " in ye %4.2f abs(`t11')
	_col(47) in gr "{c |} " in ye %4.3f `p11' "`starp11'"  _n

	in gr "{hline 56}"
	;
	di in gr "R-square:" in ye %8.2f `r2';
	#delimit cr
			
	*********	
	* Notes *
	*********
	if `qdid' == 0.0 {
		di in gr "* Means and Standard Errors are estimated by linear regression"
	}
	if `qdid' != 0.0 {
		di in gr "* Values are estimated at the `qdid' quantile"
	}

	if "`robust'" != "" {
		di in gr "**Robust Std. Errors"
	}
	if "`cluster'" != "" {
		di in gr "**Clustered Std. Errors"
	}

	if "`nostar'" == "" {
		di in gr "**Inference: *** p<0.01; ** p<0.05; * p<0.1"
	}
}
*********************************
*********************************
**** REGRESSIONS AND SCALARS **** DDD
*********************************
*********************************
* Triple difference
if "`ddd'" != "" {
	if "`cluster'" != "" {
		local clust cluster(`cluster')
	}
	****************	
	* Coefficients *
	****************
	quietly	{
		tempvar t_ddd
		gen `t_ddd' = `treated' * `ddd'
		tempvar p_treated
		gen `p_treated' = `period' * `treated'
		tempvar p_ddd
		gen `p_ddd' = `period' * `ddd'
		gen _diff = `period' * `treated' * `ddd'
		label var _diff "DDD"
		
		local slist "fc0a fc0b ft0a ft0b f0 fc1a fc1b ft1a ft1b f1 f11 sec0a sec0b se0 sec1a sec1b set0a set0b set1a set1b se1 se11 tc0a tc0b tt0a tt0b td0 tc1a tc1b tt1a tt1b td1 t11 pc0a pc0b pt0a pt0b p0 pc1a pc1b pt1a pt1b p1 p11"
		
		tempname `slist'
		
		`bsp' reg `output' `period' `treated' `ddd' `t_ddd' `p_treated' `p_ddd' _diff `cov' `if' `in' [`weight'`exp'], `robust' `clust'
		tempvar samp
		gen `samp' = e(sample)
			

		local timetr _b[_diff]
		
		local control0a (_b[_cons]+_b[`ddd'])
		local control0b (_b[_cons])
		local treat0a (_b[_cons]+_b[`treated']+_b[`ddd']+_b[`t_ddd'])
		local treat0b (_b[_cons]+_b[`treated'])
		
		local diff0 (`treat0a'-`treat0b'-`control0a'+`control0b')
		local df e(df_r)
				
		local control1a  (_b[_cons]+_b[`ddd']+_b[`period']+_b[`p_ddd'])
		local control1b  (_b[_cons]+_b[`period'])
		local treatment1a (_b[_cons]+_b[`period']+_b[`treated']+_b[`ddd']+_b[`t_ddd']+_b[`p_treated']+_b[`p_ddd']+_b[_diff])
		local treatment1b (_b[_cons]+_b[`period']+_b[`treated']+_b[`p_treated'])
		
		local diff1 (`treatment1a'-`treatment1b'-`control1a'+`control1b')
		
		*************
		* Base line *
		*************

		test `control0a' == 0
		scalar `fc0a' = `est'
		scalar `sec0a' = abs(`control0a') / sqrt(`fc0a')
		scalar `tc0a' = `control0a' / `sec0a'
		scalar `pc0a' = r(p)

		test `control0b' == 0
		scalar `fc0b' = `est'
		scalar `sec0b' = abs(`control0b') / sqrt(`fc0b')
		scalar `tc0b' = `control0b' / `sec0b'
		scalar `pc0b' = r(p)

		test `treat0a' == 0
		scalar `ft0a' = `est'
		scalar `set0a' = abs(`treat0a') / sqrt(`ft0a')
		scalar `tt0a' = `treat0a' / `set0a'
		scalar `pt0a' = r(p)
		
		test `treat0b' == 0
		scalar `ft0b' = `est'
		scalar `set0b' = abs(`treat0b') / sqrt(`ft0b')
		scalar `tt0b' = `treat0b' / `set0b'
		scalar `pt0b' = r(p)
		
		test `diff0' == 0
		scalar `f0' = `est'
		scalar `se0' = abs(`diff0') / sqrt(`f0')
		scalar `td0' = `diff0' / `se0'
		scalar `p0' = r(p)
		
		* Stars p0
		if `p0' < 0.01 & "`nostar'" == "" {
			local starp0 "***"
		}
		else if `p0' >= 0.01 & `p0' < 0.05 & "`nostar'" == "" {
			local starp0 "**"
		}
		else if `p0' >= 0.05 & `p0' < 0.1 & "`nostar'" == "" {
			local starp0 "*"
		}
		
		*************
		* Follow up *
		*************
		
		test `control1a' == 0
		scalar `fc1a' = `est'
		scalar `sec1a' = abs(`control1a') / sqrt(`fc1a')
		scalar `tc1a' = `control1a' / `sec1a'
		scalar `pc1a' = r(p)
		
		test `control1b' == 0
		scalar `fc1b' = `est'
		scalar `sec1b' = abs(`control1b') / sqrt(`fc1b')
		scalar `tc1b' = `control1b' / `sec1b'
		scalar `pc1b' = r(p)
		
		test `treatment1a' == 0
		scalar `ft1a' = `est'
		scalar `set1a' = abs(`treatment1a') / sqrt(`ft1a')
		scalar `tt1a' = `treatment1a' / `set1a'
		scalar `pt1a' = r(p)
		
		test `treatment1b' == 0
		scalar `ft1b' = `est'
		scalar `set1b' = abs(`treatment1b') / sqrt(`ft1b')
		scalar `tt1b' = `treatment1b' / `set1b'
		scalar `pt1b' = r(p)
		
		test `diff1' == 0
		scalar `f1' = `est'
		scalar `se1' = abs(`diff1') / sqrt(`f1')
		scalar `td1' = `diff1' / `se1'
		scalar `p1' = r(p)
		
		* Stars p1
		if `p1' < 0.01 & "`nostar'" == "" {
			local starp1 "***"
		}
		else if `p1' >= 0.01 & `p1' < 0.05 & "`nostar'" == "" {
			local starp1 "**"
		}
		else if `p1' >= 0.05 & `p1' < 0.1 & "`nostar'" == "" {
			local starp1 "*"
		}
		
		*******
		* DDD *
		*******
		
		test `timetr' == 0
		scalar `f11' = `est'
		scalar `se11' = abs(`timetr') / sqrt(`f11')
		scalar `t11' = `timetr' / `se11'
		scalar `p11' = r(p)
		
		*Stars p11
		if `p11' < 0.01 & "`nostar'" == "" {
			local starp11 "***"
		}
		else if `p11' >= 0.01 & `p11' < 0.05 & "`nostar'" == "" {
			local starp11 "**"
		}
		else if `p11' >= 0.05 & `p11' < 0.1 & "`nostar'" == "" {
			local starp11 "*"
		}
	}	


	****************************
	****************************
	**** TABLES AND REPORTS ****
	****************************
	****************************
	if `qdid' == 0.0 {
		local r2 e(r2)
	}
	else if `qdid' != 0.0 {
		local r2 = 1 - (e(sum_adev)/e(sum_rdev))
	}

	********************
	* Set observations *
	********************
	tempname totobs
	qui: summ `samp' if `samp'
	scalar `totobs' = r(N)
	tempname blo0a
	qui: summ `samp' if `period' == 0 & `treated' == 0 & `ddd' == 1 & `samp'
	scalar `blo0a' = r(N)
	tempname blo0b
	qui: summ `samp' if `period' == 0 & `treated' == 0 & `ddd' == 0 & `samp'
	scalar `blo0b' = r(N)
	tempname blo1a
	qui: summ `samp' if `period' == 0 & `treated' == 1 & `ddd' == 1 & `samp'
	scalar `blo1a' = r(N)
	tempname blo1b
	qui: summ `samp' if `period' == 0 & `treated' == 1 & `ddd' == 0 & `samp'
	scalar `blo1b' = r(N)
	tempname flo0a
	qui: summ `samp' if `period' == 1 & `treated' == 0 & `ddd' == 1 & `samp'
	scalar `flo0a' = r(N)
	tempname flo0b
	qui: summ `samp' if `period' == 1 & `treated' == 0 & `ddd' == 0 & `samp'
	scalar `flo0b' = r(N)
	tempname flo1a
	qui: summ `samp' if `period' == 1 & `treated' == 1 & `ddd' == 1 & `samp'
	scalar `flo1a' = r(N)
	tempname flo1b
	qui: summ `samp' if `period' == 1 & `treated' == 1 & `ddd' == 0 & `samp'
	scalar `flo1b' = r(N)
	return clear 

	di in smcl in gr _n "{title:TRIPLE DIFFERENCE (DDD) ESTIMATION RESULTS}" 
	di in ye "Notation of DDD:"
	di in ye "   Control (A)" _col(20) in wh "`treated' = 0" in ye " and " in wh "`ddd' = 1"
	di in ye "   Control (B)" _col(20) in wh "`treated' = 0" in ye " and " in wh "`ddd' = 0"
	di in ye "   Treated (A)" _col(20) in wh "`treated' = 1" in ye " and " in wh "`ddd' = 1"
	di in ye "   Treated (B)" _col(20) in wh "`treated' = 1" in ye " and " in wh "`ddd' = 0" _n
	di in gr "{p}Number of observations in the DDD:" in ye " " `totobs' "{p_end}"
	di in gr "               Before      After    "
	di in gr "   Control (A):" in ye _col(16) `blo0a' _col(28) `flo0a' in gr _col(40) `flo0a' + `blo0a'
	di in gr "   Control (B):" in ye _col(16) `blo0b' _col(28) `flo0b' in gr _col(40) `flo0b' + `blo0b'
	di in gr "   Treated (A):" in ye _col(16) `blo1a' _col(28) `flo1a' in gr _col(40) `flo1a' + `blo1a'
	di in gr "   Treated (B):" in ye _col(16) `blo1b' _col(28) `flo1b' in gr _col(40) `flo1b' + `blo1b'
	di _col(16) `blo0a' + `blo0b' + `blo1a' + `blo1b' in gr _col(28) `flo0a' + `flo0b' + `flo1a' + `flo1b'

	**********
	* Output *
	**********

	#delimit ;
	if "`report'" != "" & "`kernel'" == "" & "`cov'" != "" {;
		di in smcl in ye "{p}Report - Covariates and coefficients:{p_end}" ; 
		di in gr "{hline 21}{c -}{hline 12}{c -}{hline 11}{c -}{hline 9}{c -}"/*;
		*/"{hline 10}";
		di in gr  
		" Variable(s)         {c |}   Coeff.   {c |} Std. Err. {c |}    `inf'    {c |}"/*;
		*/"  P>|`inf'|" _n
		"{hline 21}{c +}{hline 12}{c +}{hline 11}{c +}{hline 9}{c +}"/*;
		*/"{hline 10}";

		/*;Report of covariates*/;
		foreach cov of var `cov' {;
			quietly: test _b[`cov'] == 0 ;
			di in ye  abbrev("`cov'",12)
			_col(22) in gr "{c |} " in ye %5.3f _b[`cov']
			_col(35) in gr "{c |} " in ye %5.3f _se[`cov']
			_col(47) in gr "{c |} " in ye %5.3f _b[`cov']/_se[`cov']
			_col(57) in gr "{c |} " in ye %5.3f r(p);
		};
		
		di in gr "{hline 21}{c -}{hline 12}{c -}{hline 11}{c -}{hline 9}{c -}"/*;
		*/"{hline 10}";
	};

	#delimit ; // additional covariates
	if "`report'" != "" & "`kernel'" != "" & "`addcov'" != "" {;
		di in smcl in ye "{p}Report - Additional covariates and coefficients:{p_end}" ; 
		di in gr "{hline 21}{c -}{hline 12}{c -}{hline 11}{c -}{hline 9}{c -}"/*;
		*/"{hline 10}";
		di in gr  
		" Variable(s)         {c |}   Coeff.   {c |} Std. Err. {c |}    `inf'    {c |}"/*;
		*/"  P>|`inf'|" _n
		"{hline 21}{c +}{hline 12}{c +}{hline 11}{c +}{hline 9}{c +}"/*;
		*/"{hline 10}";

		/*;Report of covariates*/;
		foreach cov of var `addcov' {;
			quietly: test _b[`cov'] == 0 ;
			di in ye  abbrev("`cov'",12)
			_col(22) in gr "{c |} " in ye %5.3f _b[`cov']
			_col(35) in gr "{c |} " in ye %5.3f _se[`cov']
			_col(47) in gr "{c |} " in ye %5.3f _b[`cov']/_se[`cov']
			_col(57) in gr "{c |} " in ye %5.3f r(p);
		};
		
		di in gr "{hline 21}{c -}{hline 12}{c -}{hline 11}{c -}{hline 9}{c -}"/*;
		*/"{hline 10}";
	};

	if "`bs'" != "" {;
		di in gr "{p}Bootstrapped Standard Errors{p_end}{break}";
	};

	di in gr "{hline 56}" _n 
	" Outcome var.   {c |} " in ye  abbrev("`1'",7) _col(27) in gr "{c |} S. Err. {c |}   |t|   {c |}"/*;
	*/"  P>|t|"_n

	"{hline 16}{c +}{hline 9}{c +}{hline 9}{c +}{hline 9}{c +}"/*;
	*/"{hline 9}"_n

	in gr "Before  " 
	_col(17) in gr "{c |} "  
	_col(27) in gr "{c |} "
	_col(37) in gr "{c |} "
	_col(47) in gr "{c |} " _n
	in gr "   Control (A)"
	_col(17) in gr "{c |} " in wh %5.3f `control0a'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Control (B)"
	_col(17) in gr "{c |} " in wh %5.3f `control0b'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Treated (A)"
	_col(17) in gr "{c |} " in wh %5.3f `treat0a'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Treated (B)"
	_col(17) in gr "{c |} " in wh %5.3f `treat0b'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Diff (T-C)"
	_col(17) in gr "{c |} " in ye %5.3f `diff0'
	_col(27) in gr "{c |} " in ye %4.3f `se0' 
	_col(37) in gr "{c |} " in ye %4.2f abs(`td0') 
	_col(47) in gr "{c |} " in ye %4.3f `p0' "`starp0'" _n 

	in gr "After    " 
	_col(17) in gr "{c |} "  
	_col(27) in gr "{c |} "
	_col(37) in gr "{c |} "
	_col(47) in gr "{c |} " _n
	in gr "   Control (A)"
	_col(17) in gr "{c |} " in wh %5.3f `control1a'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Control (B)"
	_col(17) in gr "{c |} " in wh %5.3f `control1b'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Treated (A)"
	_col(17) in gr "{c |} " in wh %5.3f `treatment1a'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Treated (B)"
	_col(17) in gr "{c |} " in wh %5.3f `treatment1b'
	_col(27) in gr "{c |} " in wh %4.3f `'
	_col(37) in gr "{c |} " in wh %4.2f `'
	_col(47) in gr "{c |} " in wh %4.3f `' _n
	in gr "   Diff (T-C)"
	_col(17) in gr "{c |} " in ye %5.3f `diff1'
	_col(27) in gr "{c |} " in ye %4.3f `se1'
	_col(37) in gr "{c |} " in ye %4.2f abs(`td1')
	_col(47) in gr "{c |} " in ye %4.3f `p1' "`starp1'" _n

	_col(17) in gr "{c |} "  
	_col(27) in gr "{c |} "
	_col(37) in gr "{c |} "
	_col(47) in gr "{c |} " _n

	in gr "DDD" 
	_col(17) in gr "{c |} " in ye %5.3f `timetr'
	_col(27) in gr "{c |} " in ye %4.3f `se11'
	_col(37) in gr "{c |} " in ye %4.2f `t11' 
	_col(47) in gr "{c |} " in ye %4.3f `p11' "`starp11'"  _n

	in gr "{hline 56}"
	;
	di in gr "R-square:" in ye %8.2f `r2';
	#delimit cr
			
	*********	
	* Notes *
	*********
	if `qdid' == 0.0 {
		di in gr "* Means and Standard Errors are estimated by linear regression"
	}
	if `qdid' != 0.0 {
		di in gr "* Values are estimated at the `qdid' quantile"
	}

	if "`robust'" != "" {
		di in gr "**Robust Std. Errors"
	}
	if "`cluster'" != "" {
		di in gr "**Clustered Std. Errors"
	}

	if "`nostar'" == "" {
		di in gr "**Inference: *** p<0.01; ** p<0.05; * p<0.1"
	}
}
*********************************



***********************
***********************
**** SAVED RESULTS ****
***********************
***********************
if "`ddd'" == "" {
	return scalar mean_c0 = `control0'
	return scalar mean_t0 = `treat0'
	return scalar diff0 = `diff0'
	return scalar mean_c1 = `control1'
	return scalar mean_t1 = `treatment1'
	return scalar diff1 = `diff1'
	return scalar did = `timetr'
	return scalar se_c0 = `sec0'
	return scalar se_t0 = `set0'
	return scalar se_d0 = `se0'
	return scalar se_c1 = `sec1'
	return scalar se_t1 = `set1'
	return scalar se_d1 = `se1'
	return scalar se_dd = `se11'
	return scalar N = `totobs'
	return scalar N_t0 = `blo0' + `blo1'
	return scalar N_t1 = `flo0' + `flo1'
	return scalar R2 = `r2'
	return local depvar = "`1'"
}
else if "`ddd'" != "" {
	return scalar mean_c0a = `control0a'
	return scalar mean_c0b = `control0b'
	return scalar mean_t0a = `treat0a'
	return scalar mean_t0b = `treat0b'
	return scalar diff0 = `diff0'
	return scalar mean_c1a = `control1a'
	return scalar mean_c1b = `control1b'
	return scalar mean_t1a = `treatment1a'
	return scalar mean_t1b = `treatment1b'
	return scalar diff1 = `diff1'
	return scalar ddd = `timetr'
	return scalar se_c0a = `sec0a'
	return scalar se_c0b = `sec0b'
	return scalar se_t0a = `set0a'
	return scalar se_t0b = `set0b'
	return scalar se_d0 = `se0'
	return scalar se_c1a = `sec1a'
	return scalar se_c1b = `sec1b'
	return scalar se_t1a = `set1a'
	return scalar se_t1b = `set1b'
	return scalar se_d1 = `se1'
	return scalar se_dd = `se11'
	return scalar N = `totobs'
	return scalar N_t0a = `blo0a' + `blo0b' + `blo1a' + `blo1b' 
	return scalar N_t1 = `flo0a' + `flo0b' + `flo1a' + `flo1b'
	return scalar R2 = `r2'
	return local depvar = "`1'"
}
 	
end
