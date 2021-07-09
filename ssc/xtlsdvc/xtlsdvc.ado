*! xtlsdvc V1.0.4   06sep05
*! Giovanni S.F. Bruno, Universita' Bocconi, Milan, Italy
*! giovanni.bruno@unibocconi.it
 
*  Version history
*  1.0.4 fixed a bug causing a wrong selection of variables when the predetermined
*        is found collinear with the exogenous regressors and dropped out.
*  1.0.3 fixed two bugs found by Ivan Marinovic: 1) the call to -simulate- can now 
*        handle commands with double quotes; 2) an error message is issued if option 
*        -initial(estimator)- is not specified according to the syntax.	    	
*  1.0.2 -_rmcoll- without -noconstant- filtered away time dummies potentially 
*        important in the initial first-differenced regressions. This is now fixed.  
*  1.0.1 fixed a bug causing xtlsdvc to break down in the presence of 
*	 time-invariant variables. Now, explanatory time-invariant are detected and
*	 automatically discarded with a message issued.  	


program define xtlsdvc,  eclass
version 8.0

if !replay() {

syntax varlist [if]  , Initial(string) [Bias(integer 1) Vcov(integer 0) ///
Level(integer `c(level)') Lsdv First] 
marksample touse
 
local options initial(`initial') bi(`bias') `lsdv' `first'
local opt_sim initial(`initial') bi(`bias') 

/* check that data is tsset */

	capture tsset
	

	capture local ivar "`r(panelvar)'"
	if "`ivar'"=="" {
		di as err "must tsset data and specify panelvar"
		exit 459
	}
	capture local tvar "`r(timevar)'"
	if "`tvar'" == "" {
		di as err "must tsset data and specify timevar"
		exit 459
	}

	if `bias'>3 {
		di as err "the maximum number of bias components allowed is 3"
		exit 198
	}
	
	if `vcov'==1 {
		di as err "the number of bootstrap iteration may be either 0 or >1"
		exit 198
	}	
	
	if ("`initial'"!="ab"&"`initial'"!="ah"&"`initial'"!="bb"&"`initial'"!="my") {
		di as err "`initial' not allowed as an initial estimator"
		exit 198
	}	
set type double

tokenize `varlist'
local depn="`1'"

/* check if the dependent is time invariant */

markout `touse' L.`1'
capture assert D.`1'==0 if `touse'
if _rc==0 {
	   di as err "the dependent variable may not be time-invariant"
		exit 198 
	}

/* get rid of time invariant variables in the exogenous regressor list */


local dim=2
while "``dim''"!="" {
		capture assert D.``dim''==0 if `touse'
		if _rc==0 {
		di as text "note: variable ``dim'' is time-invariant over the 
		di as text "      estimation sample and has been discarded"
		local dim=`dim'+1
			}
		else       {
		local xvar "`xvar' ``dim''"
		local dim=`dim'+1
				}
			}


/* check for perfect collinearity in the exogenous regressor list */
 
_rmcoll   `xvar' if `touse',noconstant
local ldep "L.`1'"

/* check for perfect collinearity in the complete regressor list 
(excluding the constant term) */

local rhsvars `ldep' `r(varlist)' 
qui _rmcoll `rhsvars' if `touse',noconstant

local rhsvars_ct: word count  `rhsvars'
local rhsvars1_ct: word count  `r(varlist)'

tokenize `r(varlist)'

if (`rhsvars_ct' >`rhsvars1_ct')&("`1'"=="`ldep'") {
		_rmcoll `rhsvars' if `touse',noconstant
		macro shift 1
		local xvar "`*'"
	}	

else if (`rhsvars_ct' >`rhsvars1_ct') {
	di as error "`ldep' collinear with the exogenous regressors"
	exit 459
	}

else  {
	macro shift 1
	local xvar "`*'"
	}



// LSDVC regression (via subroutine xtlsdvc_1)

tokenize `varlist'

xtlsdvc_1 `1'  `xvar' `if', `options'

 

tempname bc
mat `bc'=e(b)


local vars: colnames `bc'
tokenize "`vars'"

local dim=2
local g ""
		while  "``dim''"!="" { 
				local xvar_eff "`xvar_eff' ``dim''"
				local g	"`g' r(``dim'')"
				local dim=`dim'+1
				}

// Bootstrap procedure (through iteration of xtlsdvc_b)
 
if `vcov'!=0  { 
		qui preserve
		mat coeff=e(b)
		sca sigma=e(sigma)
		set seed 12345
		tokenize `varlist'
		qui simulate `"xtlsdvc_b `1' `xvar' `if',`opt_sim'"' r(`depn'_1)  `g', /*
				*/ reps(`vcov')  double 
		sca drop sigma
		mat drop coeff
		tempname V0 V
		qui mat acc `V0'=_sim_*,d noco
		qui mat `V'=`V0'/(`vcov'-1)
		restore
		mat rownames `V'=L.`1' `xvar_eff' 
		mat colnames `V'=L.`1' `xvar_eff'
		qui xtlsdvc_1 `1'  `xvar' `if', `options'
		ereturn repost V=`V'
		di as text "LSDVC dynamic regression"
		di as text "(bootstrapped SE)" 
				}

else 		{
		di as text "LSDVC dynamic regression" 
		di as text "(SE not computed)"
			}
	ereturn local cmd "xtlsdvc"
		}

else { //replay
	if "`e(cmd)'" != "xtlsdvc"  error 301 /* last estimates not found */
	if _by() error 190  /* request may not be combined with by */
	syntax [, Level(integer `c(level)')] 
	}		
if `level'<10 | `level'>99 {
	di as error "level() must be between 10 and 99 inclusive"
	exit 198
	}	
	
ereturn display, level(`level')
end







			
