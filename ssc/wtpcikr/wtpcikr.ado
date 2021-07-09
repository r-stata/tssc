* This program computes mean and/or median WTP along with confidence interval based on the Krinsky and Robb's procedure, 
* achieved significance level, and relative efficiency measure.
*! Author PWJ
* March 2007
* Updated September 2008
* Version 1.1
program define wtpcikr, rclass
	version 9.2	
	syntax varlist [if] [in] [, REPS(integer 5000) SEED(integer 032007) Level(integer 95) MYMean(name) BMat(name) VMat(name) ///
	EQuation(string) EXPOnential MEANList DOTS SAving(string)]				   
	marksample touse
	tempname v b c upay model ul ll mean
      if "`saving'" != "" { 
                tokenize "`saving'", parse(",") 
                local tpfile "`1'" 
                local subopts "`3'"		
      }
	else {
		tempfile simdat
		loc tpfile `simdat'
	}
	if `"`bmat'"'!="" mat `b'=`bmat'
	else {
		cap mat `b'=e(b)
		if c(rc)==301 {
			di
			di as err "WTPCIKR finds no estimates, please estimate a model or re-estimate the model"
			di
			e 301
		}
	}
	if `"`vmat'"' !="" mat `v'=`vmat'
	else	mat `v'=e(V)
	_estimates hold `model', copy
	
	if (`"`e(cmd)'"' != "probit" & `"`e(cmd)'"' != "logit" & `"`e(cmd)'"' != "biprobit") {
		di
		di in y "You are responsable as to whether WTP formulas apply for the command `e(cmd)'"		
	}
	global est_cmd "`e(cmd)'"

	/* If there are multiple equations as in bivariate probit or commands or programs which estimate	
 	ancillary parameters, use the first one, unless equation is specified */
	if "`equation'"=="" { 
		loc nv: word count `varlist' 
		mat `b'=`b'[1,1..`nv'+1]
		mat `v'=`v'[1..`nv'+1,1..`nv'+1]
		local eq ""
  	}	
	if "`equation'" != "" {
            mat `v' = `v'["`equation':","`equation':"]  
            mat rownames `v' = :
            mat colnames `v' = :
            mat `b' = `b'[1,"`equation':"] 
            mat colnames `b' = :
		local equ " and Equation: `equation'"
      }	
	loc k = colsof(`b')
	if `k'==2 & (`"`mymean'"'!="" | `"`meanlist'"'!="") {
		di as err "Option MYMEAN or MEANLIST not allowed in a constant-only model"
		e 198
	}
	if `"`mymean'"' !="" & `"`meanlist'"' !=""  {
		di as err "Options MYMEAN and  MEANLIST may not be combined."
		e 184
	}
	wtpmeasure `varlist' if `touse', bvec(`b') model($est_cmd) mym(`mymean') `exponential' `meanlist' 
	if `"`meanlist'"' !="" matrix meanlist=r(meanvar) // will disappear if not captured here 	
	if `"`exponential'"' =="" local mean=r(meanwtp)  
	else {
		loc mean=r(meanwtp)
		loc median=r(medianwtp)
	}
	preserve
	if `"`dots'"' !="" local showdots ""
	else loc showdots "nodots"
	set seed `seed' // To ensure replicability of results
	cap simulate, reps(`reps') `showdots' nol saving(`tpfile', `subopts'): wtpkrinsky `varlist', b(`b') v(`v') mod($est_cmd) mym(`mymean') `exponential'
	if c(rc)==602 {
		di
		di as err "The file `tpfile' already exists, please specify the REPLACE sub-option with SAVING option"
		di
     		_estimates unhold `model' 
		e 602
	}
	if `"`exponential'"'=="" {	
		* Achieved significant level (ASL)
		gen indicator= (meanwtp<=0) // Since the alternative hypothesis is meanwtp>0
		sum indicator, meanonly
		local asl=r(mean)
		* Now confidence interval
		so meanwtp
		sca `c'=((100-`level')/2)/100
		qui drop if _n<=round(`c'*`reps')  // dropping the top 2.5%
		qui drop if _n>=_N-round(`c'*`reps')+1 // dropping the bottom 2.5%
		local ll=meanwtp[1]
		loc ul=meanwtp[_N]
		local cimean=(`ul'-`ll')/`mean'
		mat `upay'=J(1,5,0)
		loc i=1
		loc val `mean' `ll' `ul' `asl' `cimean'
		foreach s of loc val {
			matrix `upay'[1,`i']=`s'
			local i=`i'+1
		}
		mat colnames `upay' = WTP LB UB ASL* CI/MEAN
		mat rownames `upay' = MEAN/MEDIAN
		di
		matlist `upay', title(Krinsky and Robb (`level' %) Confidence Interval for WTP measures (Nb of reps: `reps'`equ')) border(rows) ///
		rowtitle(MEASURE) cspec(| %12s | %8.2f | %12.2f | %12.2f | %8.4f | %8.2f |) rspec(---)
		di as txt "*: Achieved Significance Level for testing H0: WTP<=0 vs. H1: WTP>0"
		di as txt "LB: Lower bound; UB: Upper bound"
		ret sca mean_WTP=`mean'
		ret sca mean_LB = `ll'
		ret sca mean_UB = `ul'
		ret sca CI_Mean = `cimean'
	}
	else {
		loc measure mean median
		qui {
			foreach var of local measure {
				u `tpfile', clear						
				if `var'==. gen ind`var'=.
				else gen ind`var'= (`var'<=0)
				sum ind`var', meanonly
				loc asl`var'=r(mean)							
				so `var'
				sca `c'=((100-`level')/2)/100
				drop if _n<=round(`c'*`reps')  // dropping the top 2.5%
				drop if _n>=_N-round(`c'*`reps')+1 // dropping the bottom 2.5%
				local ll`var'=`var'[1]
				local ul`var'=`var'[_N]				
				local ci`var'=(`ul`var''-`ll`var'')/``var'' // note double quoting
				local al`var' ``var'' `ll`var'' `ul`var'' `asl`var'' `ci`var'' // ``var'' contains the local macros `mean' and `median'
			}
		}
		mat `upay'=J(2,5,0)
		loc i=1
		loc j=1
		foreach s of local almean {
			matrix `upay'[1,`i']=`s'
			loc i=`i'+1
		}
		foreach r of local almedian {
			matrix `upay'[2,`j']=`r'
			local j=`j'+1
		}
		mat colnames `upay' = WTP LB UB ASL* CI/MEAN
		mat rownames `upay' = MEAN MEDIAN		
		di
		matlist `upay', title(Krinsky and Robb (`level' %) Confidence Interval for WTP measures (Nb of reps: `reps'`equ')) rowtitle(MEASURES) ///
		cspec(| %12s | %8.2f | %12.2f | %12.2f | %8.4f | %8.2f |) rspec(----)
		di as txt "*: Achieved Significance Level for testing H0: WTP<=0 vs. H1: WTP>0"
		di as txt "LB: Lower bound; UB: Upper bound"
		ret sca mean_WTP=`mean'
		ret sca mean_LB = `llmean'
		ret sca mean_UB = `ulmean'
		ret sca CI_Mean = `cimean'
		ret sca median_WTP=`median'
		ret sca median_LB = `llmedian'
		ret sca median_UB = `ulmedian'
		ret sca CI_Median = `cimedian'		
	}
	if `"`meanlist'"'!="" {
		gettoken bidv xvars: varlist
		mat colnames meanlist = `xvars'
		mat rownames meanlist = Mean
		di
		matlist meanlist, for(%8.5f) border(rows) title(Sample mean of the explanatory variables used in the computation)
	}	
	restore
     _estimates unhold `model' 
	 
end


