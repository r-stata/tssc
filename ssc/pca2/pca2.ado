capture program drop gmm_style_Ltrunc
program define gmm_style_Ltrunc
version 9.0

syntax varlist [if] [in] [, nt(varlist numeric max=2) GMMLiv(numlist integer >=0) *]

*capture drop _GMML_*
local nindeces : list sizeof nt
*di as result "Number of indeces for observations in your data-set: `nindeces'"
*di as result "General description of the dataset"
if `nindeces'==0 {
di as error "You cannot create GMM-style IVs with cross-section data. Use nt() option to set time series or panel data."
exit 198
}
if `nindeces'==1 {
di as text "You are creating GMM-style IVs in levels for a time series"
tokenize `nt'
local time="`1'"
qui tsset `1' 
*return list
local nperiods=r(tmax)-r(tmin)+1
local time_min=r(tmin)
local time_max=r(tmax)
*di as text "time variable: `time'"
*di as text "first year: `time_min'"
*di as text "last year: `time_max'"
}
if `nindeces'==2 {
di as text "You are creating GMM-style IVs in levels for a panel"
tokenize `nt'
local time="`2'"
qui tsset `1' `2'
*return list
local nperiods=r(tmax)-r(tmin)+1
local time_min=r(tmin)
local time_max=r(tmax)
*di as text "time variable: `time'"
*di as text "first year: `time_min'"
*di as text "last year: `time_max'"
}
tokenize `varlist'
local i 1
while "``i''"!="" {

di in blue "_____ variable: ``i'' _____"

if "`gmmliv'" != "" {
local nlag : list sizeof gmmliv
*di as result "Elements in GMML(): `nlag'"

if `nlag'==1 {
*local optname gmmliv()
local primo_lag =`gmmliv'
di as result "Lag selection in GMML(): from t-`primo_lag' to the last available lag"
if `primo_lag'==0 {
*di as text "Are you sure that the first IV is t (exogenous variables)?"
}
if `primo_lag'==1 {
*di as text "Are you sure that the first IV is t-1 (predetermined variables)?"
}
if `primo_lag'==2 {
*di as text "Are you sure that the first IV is t-2 (endogenous variables)?"
}
forvalues tau=`=`time_min'+`primo_lag'' / `time_max' {
    forvalues lag = `primo_lag' / `=`tau'-`time_min'' {
        qui g _GMML_``i''_`tau'L`lag' = L`lag'.``i'' if `time' == `tau'
qui summ _GMML_``i''_`tau'L`lag' 
if r(N)==0  {
drop _GMML_``i''_`tau'L`lag'
}
else if r(N)!=0 { 
qui recode _GMML_``i''_`tau'L`lag' (.=0)
}
    } /* IV generation */
	} /* for each year */
	} /* one lag */

if `nlag'==2 {
*local optname gmmliv()
tokenize `gmmliv'
local primo_lag `1'
local ultimo_lag `2'
di as result "Lag selection in GMML(): from t-`primo_lag' to t-`ultimo_lag'"
if `primo_lag'==0 {
*di as text "Are you sure that the first IV is t (exogenous variables)?"
}
if `primo_lag'==1 {
*di as text "Are you sure that the first IV is t-1 (predetermined variables)?"
}
if `primo_lag'==2 {
*di as text "Are you sure that the first IV is t-2 (endogenous variables)?"
}
if `primo_lag'>`ultimo_lag' {
di as error "This procedure uses lags as IV, not forewards (use GMM_style_Ftrunc procedure)"
exit 198
}
tokenize `varlist' 
forvalues tau=`=`time_min'+`primo_lag'' / `time_max' {
	*di "`tau' `time_min' `primo_lag' `time_max'" 
	forvalues lag = `primo_lag' / `ultimo_lag' {
	*di "`primo_lag' `ultimo_lag' `time'"
		qui g _GMML_``i''_`tau'L`lag' = L`lag'.``i'' if `time' == `tau'
qui summ _GMML_``i''_`tau'L`lag' 
if r(N)==0  {
drop _GMML_``i''_`tau'L`lag'
}
else if r(N)!=0 { 
qui recode _GMML_``i''_`tau'L`lag' (.=0)
}
	} /* IV generation */
	} /* for each year  */
} /* two lags */ 
}  /* gmmliv != missing */

if "`gmmliv'" == "" {
di as error "You must select lag(s) for GMM-style IVs in levels; use the gmml() option"
exit 198
}

local i=`i'+1
} /* close varlist */

end
**********************************************
* `1' individuals
* `2' years 
* `3' variables
* gmml() lags selection
* COMMAND: gmm_style_Ltrunc list_of_variables, nt(id year) gmml() 
* 1 index --> from t-index to the last available lag
* 2 index --> from t-index1 to t-index2
*(example from abdata and panel_dynamic_application)  
* it creates the matrix of GMM-style IVs so that also ivreg2 or other similar commands could operate like xtabond2 gmm 
* IVs in levels, for eq(diff) *
*******************************
*******************************

capture program drop gmm_style_Dtrunc
program define gmm_style_Dtrunc

version 9.0

syntax varlist [if] [in] [, nt(varlist numeric max=2) GMMDiv(numlist >=0) *]

*capture drop _GMMD_*
local nindeces : list sizeof nt
di as result "Number of indeces for observations in your data-set: `nindeces'"
if `nindeces'==0 {
di as error "You cannot create GMM-style IVs with cross-section data. Use nt() option to set time series or panel data."
exit 198
}
if `nindeces'==1 {
di as text "You are creating GMM-style IVs in first-differences for a time series"
tokenize `nt'
local time="`1'"
qui tsset `1' 
*return list
local nperiods=r(tmax)-r(tmin)+1
local time_min=r(tmin)
local time_max=r(tmax)
di as text "time variable: `time'"
di as text "first year: `time_min'"
di as text "last year: `time_max'"
}
if `nindeces'==2 {
di as text "You are creating GMM-style IVs in first-differences for a panel"
tokenize `nt'
local time="`2'"
qui tsset `1' `2'
*return list
local nperiods=r(tmax)-r(tmin)+1
local time_min=r(tmin)
local time_max=r(tmax)
di as text "time variable: `time'"
di as text "first year: `time_min'"
di as text "last year: `time_max'"
}

tokenize `varlist'
local i 1
while "``i''"!="" {

di in blue "_____ variable: ``i'' _____ "

if "`gmmdiv'" != "" {
local nlag : list sizeof gmmdiv
*di as result "Elements in GMMD(): `nlag'"

if `nlag'==1 {
*local optname gmmdiv()
local primo_lag =`gmmdiv'
di as result "Lag selection in GMMD(): from t-`primo_lag' to the last available lag"
if `primo_lag'==0 {
*di as text "Are you sure that the first IV is t (exogenous variables)?"
}
if `primo_lag'==1 {
*di as text "Are you sure that the first IV is t-1 (predetermined variables)?"
}
if `primo_lag'==2 {
*di as text "Are you sure that the first IV is t-2 (endogenous variables)?"
}
forvalues tau=`=`time_min'+`primo_lag'' / `time_max' {
    forvalues lag = `primo_lag' / `=`tau'-`time_min'' {
        qui g _GMMD_``i''_`tau'L`lag' = D.L`lag'.``i'' if `time' == `tau'
        qui summ _GMMD_``i''_`tau'L`lag' 
if r(N)==0  {
drop _GMMD_``i''_`tau'L`lag'
}
else if r(N)!=0 { 
qui recode _GMMD_``i''_`tau'L`lag' (.=0)
}
	} /* IV generation */
	} /* for each year */
	} /* one lag */

if `nlag'==2 {
*local optname gmmdiv()
tokenize `gmmdiv'
local primo_lag `1'
local ultimo_lag `2'
di as result "Lag selection in GMMD(): from t-`primo_lag' to t-`ultimo_lag'"
if `primo_lag'==0 {
*di as text "Are you sure that the first IV is t (exogenous variables)?"
}
if `primo_lag'==1 {
*di as text "Are you sure that the first IV is t-1 (predetermined variables)?"
}
if `primo_lag'==2 {
*di as text "Are you sure that the first IV is t-2 (endogenous variables)?"
}
if `primo_lag'>`ultimo_lag' {
di as error "This procedure uses lags as IV, not forewards (use GMM_style_Ftrunc procedure)"
exit 198
}
tokenize `varlist' 
forvalues tau=`=`time_min'+`primo_lag'' / `time_max' {
	*di "`tau' `time_min' `primo_lag' `time_max'" 
	forvalues lag = `primo_lag' / `ultimo_lag' {
	*di "`primo_lag' `ultimo_lag' `time'"
		qui g _GMMD_``i''_`tau'L`lag' = D.L`lag'.``i'' if `time' == `tau'
        qui summ _GMMD_``i''_`tau'L`lag' 
if r(N)==0  {
drop _GMMD_``i''_`tau'L`lag'
}
else if r(N)!=0 { 
qui recode _GMMD_``i''_`tau'L`lag' (.=0)
}
	} /* IV generation */
	} /* for each year  */
} /* two lags */ 
}  /* gmmdiv != missing */

if "`gmmdiv'" == "" {
di as error "You must select lag(s) for GMM-style IVs in first-differences; use the gmmd() option"
exit 198
}

local i=`i'+1
} /* close varlist */

end
**********************************************
* `1' individuals
* `2' years 
* `3' variables
* gmmd() lags selection
* COMMAND: gmm_style_Dtrunc id year list_of_variables, gmmd() 
* 1 index --> from t-index to the last available lag
* 2 index --> from t-index1 to t-index2
*(example from abdata and panel_dynamic_application)  
* it creates the matrix of GMM-style IVs so that also ivreg2 or other similar commands could operate like xtabond2 gmm 
* IVs in first-differences, for eq(level) *
*******************************
*****************************    MAIN PROGRAM *****************************************************************
*****************************************************************************************************************
*********************************************************************************************************************
capture program drop pca2
program define pca2, rclass

version 9.0

syntax varlist [if] [in] [, nt(varlist numeric max=2) VARiance(numlist integer >0 <=100) AVG COVariance PREfix(string) SEE /*
*/                          TOGVar TOGLD GMMLiv(numlist integer >=0 missingokay)  GMMDiv(numlist integer >=0 missingokay)  RETain *]

set more off
/*
local m 1
	local l = length(`"`nt'"')
 	while `m' <= `l' {
		local char`m' = substr(`"`nt'"', `m', 3)
		if substr(`"`nt'"', `m', 3) == " " {
			local char`m' " "
		}
		local m = `m' + 1*
	}
di `char1' 
di `char2'
*/	
	
local nvars : list sizeof varlist
local varlistpca `varlist'
tokenize `varlist'
local firstvar `1'
local lastvar ``nvars''
*di "`firstvar' `lastvar' `nvars'" "
/*
tempname   s_trace s_ExplainedVarVar s_RetainedEigenCountVar s_trace_PV_perc s_ExplainedVarVar_var  /*
*/         l_SecondIndex           /*
*/         s_RetainedEigenCountAvg s_ExplainedVarAvg s_ExplainedVarAvg_var s_RetainedPC       /*
*/		   primo_lag1D ultimo_lag1D 
*/
tempname   s_trace l_SecondIndex primo_lag1D ultimo_lag1D 


**** TYPE OF DATA *******
local nindeces : list sizeof nt
*di as result "Number of indeces for observations of your data-set: `nindeces'"
di as result "General description of the dataset"
if `nindeces'==0 {
di as text "Is your data-set a cross-section?"
}
if `nindeces'==1 {
di as text "Is your data-set a time-series?"
tokenize `nt'
local time_var ="`1'"
*di as result "time var: `time_var'"
tsset `time_var'
local nperiods=r(tmax)-r(tmin)+1
local time_min=r(tmin)
local time_max=r(tmax)
}
if `nindeces'==2 {
*di as text "Is your data-set a panel?"
tokenize `nt'
local ind_var = "`1'"
local time_var = "`2'"
*di as result "panel var: `ind_var'" "		" "time var: `time_var'"
tsset `ind_var' `time_var'
*return list
local nperiods=r(tmax)-r(tmin)+1
local time_min=r(tmin)
local time_max=r(tmax)
}

**** NAME FOR SCORES *******
* by default, if the name of the prefix is not esplicitly indicated by option pre(),
* the _BM_ prefix is used
if `"`prefix'"' == "" {
		local prefix1 = "_BM_"
    	di as result "The prefix is: `prefix1'"
* Change the default prefix if variables called by the same name already exist:
capture descr `prefix1'*
*di _rc
*di "`prefix1'"
if _rc==0&r(N)!=. {
           di as error "Variables starting with the default `prefix1' already exist in your data-set: please use the pre() option"
           *capture drop `prefix'*
		   exit 198
		   }               
		}   /* end prefix */
* Verify the validity of the selected prefix:
if `"`prefix'"' != "" {
		local prefix1 = "_`prefix'_"
		di as result "The prefix is: `prefix1'"
* Change the selected prefix if variables called by the same name already exist:
capture descr `prefix1'*
di _rc
*di "`prefix1'"
if _rc==0&r(N)!=. {
           di as error "Variables starting with the selected `prefix1' already exist in your data-set: please use the pre() option to select another name"
           exit 198
		   }               
		}   /* end prefix */

marksample touse, novarlist

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
********** GMM LEV DIFFERENT LAGS VAR BY VAR & TOGVAR ***************************
*********************************************************************************	
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
local lagslgroups 0
*di "START LOOP LAGSL: lagslgroups: `lagslgroups'"
local 0, `options'
local _optlagsl `options'
*local 0, `_optlagsl'
*di " opzioni: `0'"
*di "START LOOP LAGSL: _optlagsl: `_optlagsl'"

syntax [, LAGSL(string) *]
while "`lagsl'" != "" {
	   
	   if "`gmmliv'"!=""  {
	   di as error "Either use gmml or lagsl"
	   exit 198
	   }
		
		local optionsarg `options'
		*di "optionsarg: `optionsarg'"
		local 0 `lagsl'
		*di "lagsl : `lagsl'"
		local _optlagsl `lagsl'
		*di "_optlagsl: `_optlagsl'"
        capture syntax varlist, [Ll(string)]
		/*
		if _rc {
			di as err _n "lags(`0') invalid."
			exit 198
		}
		*/
		local nbasevarsl : list sizeof varlist
		local basevarsl `varlist'
		*di "varlist originally in lagsl:`varlist'"
		*di "varlist derived from lagsl:`basevarsl'"
		*di "varlist in pca2 syntax   :`varlistpca'"
		*di "nbasevarsl: `nbasevarsl'"
		
			foreach lag of numlist `lagslgroups' {
				if "`ll'" == "" {
				di as err _n `"ll(`ll') must have at least one argument."'
				exit 198
			    }
			if `:word count `ll'' == 1 {
				di "ONE LAG in ll()"
			    local lagliml1`lag' = `: word 1 of `ll'' + 0
				*di "lag in ll(): `lagliml1`lag''"
				if `lagliml1`lag'' == . { 
			    di as error "Lags can not be missing"
			    exit 198
			    } 
			    local lagslgroups = `lagslgroups' + 1
		        local lagslvars "`lagslvars' `basevarsl'"
		        *di "lagslgroups: `lagslgroups'"
		        *di "lagslvars: `lagslvars'"
		        local nlagslvars : list sizeof lagslvars
		        *di "nlagslvars: `nlagslvars'"
		
				gmm_style_Ltrunc `basevarsl', nt(`ind_var' `time_var') gmml(`lagliml1`lag'')
			    
			    }  /* ONE LAG */
			else {
				if `:word count `ll'' == 2 {
				di "TWO LAGS in rit()"
				forvalues a = 1/2 {
				    *di "how many lags?`a'"
					capture local lagliml`a'`lag' = `: word `a' of `ll'' + 0
					if _rc {
						di as err _n `"ll(`ll') invalid."'
						exit 198
					    }
				} /* chiude il loop*/
				} /* word count */
			    if `lagliml1`lag'' == . { 
			    di as error "Lags can not be missing"
			    exit 198
			    } 
			    if `lagliml2`lag'' == . { 
			    di as error "Lags can not be missing"
			    exit 198
			    } 
			    *di "First lag in rit(): `lagliml1`lag''"
			    *di "Second lag in rit(): `lagliml2`lag''"
			local lagslgroups = `lagslgroups' + 1
		    local lagslvars "`lagslvars' `basevarsl'"
		    *di "lagslgroups: `lagslgroups'"
		    *di "lagslvars: `lagslvars'"
		    local nlagslvars : list sizeof lagslvars
		    *di "nlagslvars: `nlagslvars'"
				
		    gmm_style_Ltrunc `basevarsl', nt(`ind_var' `time_var') gmml(`lagliml1`lag'' `lagliml2`lag'')
		    } /* TWO LAGS */
			} /* for each lagslgroup */

		
		local 0, `optionsarg'
		syntax [, LAGSL(string) *]
} /* chiude while lags */	

local lagslgroups 0
local _optlagsl 0

	
if "`nlagslvars'"!=""&"`gmmdiv'"=="" {
if `nlagslvars'<`nvars' {
		di as error "The number of variables in pca2 command is different from the number of variables in the options"
		exit 198
		}		
		}		

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
********** GMM DIF DIFFERENT LAGS VAR BY VAR & TOGVAR ***************************
*********************************************************************************	
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
local lagsdgroups 0
*di "START LOOP LAGSD: lagsdgroups: `lagsdgroups'"
local 0, `options'
local _optlagsd `options'
*di "START LOOP LAGSD: _optlagsd: `_optlagsd'"

syntax [, LAGSD(string) *]
	while "`lagsd'" != "" {
	   
	   if "`gmmdiv'"!=""  {
	   di as error "Either use gmmd or lagsd"
	   exit 198
	   }
				
		local optionsarg `options'
		*di "optionsarg: `optionsarg'"
		local 0 `lagsd'
		*di "lagsd : `lagsd'"
		local _optlagsd `lagsd'
		*di "_optlagsd: `_optlagsd'"
		capture syntax varlist, [Ll(string)]
		
		local nbasevarsd : list sizeof varlist
		local basevarsd `varlist'
		*di "varlist originally in lagsd: `varlist'"
		*di "varlist derived from lagsd: `basevarsd'"
		*di "varlist in pca2 syntax   :`varlistpca'"
		*di "nbasevarsd: `nbasevarsd'"
		
		  foreach lag of numlist `lagsdgroups' {
			if "`ll'" == "" {
				di as err _n `"ll(`ll') must have at least one argument."'
				exit 198
			}
			if `:word count `ll'' == 1 {
			    di "ONE LAG in rit()"
				local laglimd1`lag' = `: word 1 of `ll'' + 0
				*di "lag in rit(): `laglimd1`lag''"
				if `laglimd1`lag'' == . {
				di as error "Lags can not be missing"
				exit 198
				}
				local lagsdgroups = `lagsdgroups' + 1
		        local lagsdvars "`lagsdvars' `basevarsd'"
		        di "lagsdgroups: `lagsdgroups'"
				di "lagsdvars: `lagsdvars'"
		        local nlagsdvars : list sizeof lagsdvars
		        *di "nlagsdvars: `nlagsdvars'"
		
				gmm_style_Dtrunc `basevarsd', nt(`ind_var' `time_var') gmmd(`laglimd1`lag'')
			    } /* ONE LAG */
			else {
				if `:word count `ll'' == 2 {
				di "TWO LAGS in rit()"
				forvalues a = 1/2 {
				    *di "how many lags?`a'"
					capture local laglimd`a'`lag' = `: word `a' of `ll'' + 0
					if _rc {
						di as err _n `"ll(`ll') invalid."'
						exit 198
					}
				} /* chiude il loop*/
				} /* word count */
			    if `laglimd1'`lag' == . { 
			    di as error "Lags can not be missing"
			    exit 198
			    } 
			    if `laglimd2'`lag' == . { 
			    di as error "Lags can not be missing"
			    exit 198
			    } 
			    *di "First lag in rit(): `laglimd1`lag''"
			    *di "Second lag in rit(): `laglimd2`lag''"
			local lagsdgroups = `lagsdgroups' + 1
		    local lagsdvars "`lagsdvars' `basevarsd'"
		    di "lagsdgroups: `lagsdgroups'"
			di "lagsdvars: `lagsdvars'"
		    local nlagsdvars : list sizeof lagsdvars
		    *di "nlagsdvars: `nlagsdvars'"
		
		    gmm_style_Dtrunc `basevarsd', nt(`ind_var' `time_var') gmmd(`laglimd1`lag'' `laglimd2`lag'')
		    } /* TWO LAGS */	
			} /* for each lagsdgroups */
		
					
        local 0, `optionsarg'
		syntax [, LAGSD(string) *]
 } /* close while lags */

 if "`nlagsdvars'"!=""&"`gmmliv'"=="" {
 if `nlagsdvars'<`nvars' {
		di as error "The number of variables in pca2 command is different from the number of variables in the options"
		exit 198
		}
		}
			

			
		
			
			
			
			
			
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&		
		
	*** START PCA ***	
************** PCA VAR BY VAR LEV ******************
 if "`togvar'"=="" & "`nlagslvars'"!="" {
 foreach var of varlist `lagslvars' {
 di "_____ PCA LEV VAR BY VAR: `var'"
 local newvarlistl_`var' _GMML_`var'_*
 local newvarlistldl_`var' _GMML_`var'_*
 local newvarlistldllags_`var' _GMML_`var'_*

 if "`togld'"=="" {
 di as text "You are applying PCA to GMM-style LEV lags of more than one variable,"
 di as text "keeping the variables separated with different lags structure"
 
	 if "`covariance'"=="" {
	  if "`see'"=="" {
	  qui pca `newvarlistl_`var'' if `touse'
	  }
	  if "`see'"!="" {
	  pca `newvarlistl_`var'' if `touse'
	  }
	 }
	if "`covariance'"!="" {
	  if "`see'"=="" {
	  qui pca `newvarlistl_`var'' if `touse', covariance
	  }
	  if "`see'"!="" {
	  pca `newvarlistl_`var'' if `touse', covariance
	  }
	 }
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels for `var' __________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLEV`var'N1-`prefix1'varscoreLEV`var'N`l_SecondIndex', score
			 }			
		else {
		    qui predict double `prefix1'varscoreLEV`var'N1, score
		    }

ret scalar var_byvar_LEV_`var'  = s_ExplainedVarVar_var
ret scalar nscores_byvar_LEV_`var'   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
                }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		        }
        }
		scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLEV`var'N1-`prefix1'avgscoreLEV`var'N`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLEV`var'N1, score
		     }

ret scalar var_byavg_LEV_`var'   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LEV_`var'   = s_RetainedEigenCountAvg	 
}   /*close option mean */

 } /* close togld==""  */
 
 } /* close for each var */

*if "`retain'"=="" {
*	capture drop _GMML_*_*
*	}

 } /* close if togvar=="" */	
	
************ PCA VARTOG LEV *********************
 if 	"`togvar'"!="" &"`nlagslvars'"!="" {
 di "_____ PCA LEV VAR TOGETHER: `lagslvars'"
 local newvarlistl_tog _GMML_*_*
 local newvarlistldl_tog _GMML_*_*
 local newvarlistldllags_tog _GMML_*_*
  if "`togld'"=="" {
di as text "You are applying PCA to GMM-style LEV lags of more than one variable," 
di as text "keeping the variables together with different lags structure"
 
    if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistl_tog' if `touse'
	 }
	if "`see'"!="" {
	 pca `newvarlistl_tog' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistl_`var'' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistl_`var'' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels for the variables `varlistpca' together"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		 if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLEVtog1-`prefix1'varscoreLEVtog`l_SecondIndex', score
			}			
         else {
		    qui predict double `prefix1'varscoreLEVtog1, score
		    }

ret scalar var_byvar_LEV_tog  = s_ExplainedVarVar_var
ret scalar nscores_byvar_LEV_tog  = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
                }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
	     	    }
        }
		scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLEVtog1-`prefix1'avgscoreLEVtog`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLEVtog1, score
		    }

ret scalar var_byavg_LEV_tog   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LEV_tog   = s_RetainedEigenCountAvg	 
}   /*close option mean */
}   /*close togld=="" */

*if "`retain'"=="" {
*    capture drop _GMML_*_*
*	}
    
} /*chiude if togvar!="" */


	
****************** PCA VAR BY VAR DIF *************************
   if "`togvar'"=="" & "`nlagsdvars'"!="" {
   foreach var of varlist `lagsdvars' {
   di "_____ PCA DIF VAR BY VAR: `var'"
   local newvarlistd_`var' _GMMD_`var'_*
   local newvarlistldd_`var' _GMMD_`var'_*
   local newvarlistlddlags_`var' _GMMD_`var'_*
   
   if "`togld'"=="" {
   di as text "You are applying PCA to GMM-style DIF lags of more than one variable,"
   di as text "keeping the variables separated with different lags structure"
	
	if "`covariance'"=="" {
	if "`see'"=="" {
	qui pca `newvarlistd_`var'' if `touse'
	}
	if "`see'"!="" {
	pca `newvarlistd_`var'' if `touse'
	}
   }
	if "`covariance'"!="" {
	if "`see'"=="" {
	qui pca `newvarlistd_`var'' if `touse', covariance
	}
	if "`see'"!="" {
	pca `newvarlistd_`var'' if `touse', covariance
	}
   }
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in first_differences for `var' __________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreDIF`var'N1-`prefix1'varscoreDIF`var'N`l_SecondIndex', score
             }			
		else {
     		qui predict double `prefix1'varscoreDIF`var'N1, score
	    	}

ret scalar var_byvar_DIF_`var' = s_ExplainedVarVar_var
ret scalar nscores_byvar_DIF_`var'   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
                }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
	     	    }
        }
		scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreDIF`var'N1-`prefix1'avgscoreDIF`var'N`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreDIF`var'N1, score
		     }

ret scalar var_byavg_DIF_`var'   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_DIF_`var'   = s_RetainedEigenCountAvg	 
}   /*close option mean */

 } /* close togld=="" */
 } /* close for each var */

* if "`retain'"==""  {
*	capture drop _GMMD_*_*
*	}

 } /* close if togvar=="" */
	
******************** PCA VARTOG DIF ****************************
if "`togvar'"!="" & "`nlagsdvars'"!=""{
di "_____ PCA DIF VAR TOGETHER: `lagsdvars'"
local newvarlistd_tog _GMMD_*_*
local newvarlistldd_tog _GMMD_*_*
local newvarlistlddlags_tog _GMMD_*_*

 if "`togld'"=="" {
 di as text "You are applying PCA to GMM-style DIF lags of more than one variable,"
 di as text "keeping the variables together with different lags structure"	
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistd_tog' if `touse'
	 }
	 if "`see'"!="" {
	 pca `newvarlistd_tog' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistd_`var'' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistd_`var'' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in first-differences for the variables `varlistpca' together"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
    	scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreDIFtog1-`prefix1'varscoreDIFtog`l_SecondIndex', score
			 }			
    	else {
		qui predict double `prefix1'varscoreDIFtog1, score
	    	}

ret scalar var_byvar_DIF_tog  = s_ExplainedVarVar_var
ret scalar nscores_byvar_DIF_tog   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
                 }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		        }
          }
		scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreDIFtog1-`prefix1'avgscoreDIFtog`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreDIFtog1, score
		    }

ret scalar var_byavg_DIF_tog  = s_ExplainedVarAvg_var
ret scalar nscores_byavg_DIF_tog   = s_RetainedEigenCountAvg	 
}   /*close option mean */
}   /*close togld=="" */

*if "`retain'"==""  {
*	capture drop _GMMD_*_*
*	}

} /* chiude il togvar!="" */
	

************ PCA VAR BY VAR LEV & DIF TOGETHER ********************
if "`togld'"!="" & "`nlagslvars'"!="" & "`nlagsdvars'"!="" {
if "`togvar'"=="" { 
foreach var of varlist `varlistpca'  {
di "_____ PCA LEV&DIF VAR BY VAR: `var'"
local newvarlistld_`var' "`newvarlistldl_`var'' `newvarlistldd_`var''"
di "`newvarlistld_`var''"
di as text "You are applying PCA to GMM-style LEV & DIF lags of more than one variable,"
di as text "keeping the variables separated with different lags structure"
   if "`covariance'"=="" {
	if "`see'"=="" {
	qui pca `newvarlistld_`var'' if `touse'
	}
	if "`see'"!="" {
	pca `newvarlistld_`var'' if `touse'
	}
   }
   if "`covariance'"!="" {
	if "`see'"=="" {
	qui pca `newvarlistld_`var'' if `touse', covariance
	}
	if "`see'"!="" {
	pca `newvarlistld_`var'' if `touse', covariance
	}
   }
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels & first_differences together for `var' _________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLD`var'N1-`prefix1'varscoreLD`var'N`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreLD`var'N1, score
		     }

ret scalar var_byvar_LD_`var' = s_ExplainedVarVar_var
ret scalar nscores_byvar_LD_`var'  = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
            }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		         }
        }
        scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLD`var'N1-`prefix1'avgscoreLD`var'N`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLD`var'N1, score
		     }

ret scalar var_byavg_LD_`var'  = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LD_`var'  = s_RetainedEigenCountAvg	 
}   /*close option mean */

	} /* close for each var */
   } /* close if  togvar=="" */
   
****************** PCA VARTOG LEV & DIF TOGETHER ****************
if "`togvar'"!="" { 
di "_____ PCA LEV&DIF VAR TOGETHER: `varlistpca'"
local newvarlistld_tog "`newvarlistldl_tog' `newvarlistldd_tog'"
di "`newvarlistld_tog'"
di as text "You are applying PCA to GMM-style LEV & DIF lags of more than one variable,"
di as text "keeping the variables together with different lags structure"
   if "`covariance'"=="" {
	if "`see'"=="" {
	qui pca `newvarlistld_tog' if `touse'
	}
	if "`see'"!="" {
	pca `newvarlistld_tog' if `touse'
	}
   }
   if "`covariance'"!="" {
	if "`see'"=="" {
	qui pca `newvarlistld_tog' if `touse', covariance
	}
	if "`see'"!="" {
	pca `newvarlistld_tog' if `touse', covariance
	}
   }
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels & first_differences together for the variables `varlistpca' together _________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		*di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLDtog1-`prefix1'varscoreLDtog`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreLDtog1, score
		     }

ret scalar var_byvar_LD_tog = s_ExplainedVarVar_var
ret scalar nscores_byvar_LD_tog  = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
            }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		         }
        }
        scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLDtog1-`prefix1'avgscoreLDtog`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLDtog1, score
		     }

ret scalar var_byavg_LD_tog  = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LD_tog  = s_RetainedEigenCountAvg	 
}   /*close option mean */
   
  } /* close togvar!="" */
 }  /* close togld!="" */

* POSSO TOGLIERLO?
* if "`retain'"==""  {
*	capture drop _GMM*_*_*
*	}
 
 
 
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
********** GMM LEV SAME LAGS VAR BY VAR & TOGVAR ********************************
*********************************************************************************	
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
if "`gmmliv'"!=""  {
    /*
    if `nvars'==1  {
	di as text "You are applying PCA to GMM-style lags of one variable."
	}
	*/
	*else if `nvars'>1 {  }
    
	if "`nlagslvars'"!=""  {
	di as error "Either use gmml or lagsl"
	exit 198
	}
	local nlag1 : list sizeof gmmliv
	*di as result "Elements in GMML(): `nlag1'"
	if `nlag1'==1 {
	local primo_lag1l =`gmmliv'
	gmm_style_Ltrunc `varlistpca', nt(`ind_var' `time_var') gmml(`primo_lag1l')
	}
	if `nlag1'==2 {
	tokenize `gmmliv'
	local primo_lag1l `1'
	local ultimo_lag1l `2'
	*tokenize `varlist'
	gmm_style_Ltrunc `varlistpca', nt(`ind_var' `time_var') gmml(`primo_lag1l' `ultimo_lag1l')
	}
} /* close gmmliv !"== */
	

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
********** GMM DIF SAME LAGS VAR BY VAR & TOGVAR ********************************
*********************************************************************************	
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
if "`gmmdiv'"!=""  {
 
    if "`nlagsdvars'"!=""  {
	di as error "Either use gmmd or lagsd"
	exit 198
	}
	local nlag1 : list sizeof gmmdiv
	*di as result "Elements in GMMD(): `nlag1'"
	if `nlag1'==1 {
	local primo_lag1d =`gmmdiv'
	gmm_style_Dtrunc `varlistpca', nt(`ind_var' `time_var') gmmd(`primo_lag1d')
	}
	if `nlag1'==2 {
	tokenize `gmmdiv'
	local primo_lag1d `1'
	local ultimo_lag1d `2'
	*tokenize `varlist'
	gmm_style_Dtrunc `varlistpca', nt(`ind_var' `time_var') gmmd(`primo_lag1d' `ultimo_lag1d')
	}
} /* close gmmdiv !"== */


	
	
************** PCA VAR BY VAR LEV SAME LAGS *******************	
if "`togvar'"=="" & "`gmmliv'"!=""  {	
	foreach var of varlist `varlistpca' {
	di "_____ PCA LEV VAR BY VAR: `var'"
 	local newvarlistl_`var' _GMML_`var'_*
	local newvarlistldl_`var' _GMML_`var'_*
	local newvarlistldlgmm_`var' _GMML_`var'_*
	
 if "`togld'"==""  {	
	di as text "You are applying PCA to GMM-style LEV lags of one or more than one variable,"
	di as text "keeping the variables separated with the same lags structure"
		
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistl_`var'' if `touse'
	 }
	 if "`see'"!="" {
	 pca `newvarlistl_`var'' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistl_`var'' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistl_`var'' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels for `var' __________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLEV`var'N1-`prefix1'varscoreLEV`var'N`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreLEV`var'N1, score
		     }

ret scalar var_byvar_LEV_`var'  = s_ExplainedVarVar_var
ret scalar nscores_byvar_LEV_`var'   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
                 }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		         }
        }
		scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLEV`var'N1-`prefix1'avgscoreLEV`var'N`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLEV`var'N1, score
		    }

ret scalar var_byavg_LEV_`var'   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LEV_`var'   = s_RetainedEigenCountAvg	 
}   /*close option mean */

}  /* close togld=="" */
}  /* close for each var =="" */

*if "`retain'"==""  {
*	capture drop _GMML_`var'_*
*	}

} /* close if togvar=="" */

************** PCA TOGVAR LEV SAME LAGS *******************	
if "`togvar'"!="" & "`gmmliv'"!=""  {	
di "_____ PCA LEV VAR TOGETHER: `varlistpca'"
local newvarlistl_tog _GMML_*_*
local newvarlistldl_tog _GMML_*_*
local newvarlistldlgmm_tog _GMML_*_*

 if "`togld'"==""  {	
	di as text "You are applying PCA to GMM-style LEV lags of one or more than one variable,"
	di as text "keeping the variables together with the same lags structure"
	
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistl_tog' if `touse'
	 }
	 if "`see'"!="" {
	 pca `newvarlistl_tog' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistl_`var'' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistl_`var'' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels for the variables `varlistpca' together"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLEVtog1-`prefix1'varscoreLEVtog`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreLEVtog1, score
		     }

ret scalar var_byvar_LEV_tog  = s_ExplainedVarVar_var
ret scalar nscores_byvar_LEV_tog  = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
            }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		         }
            }
        scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLEVtog1-`prefix1'avgscoreLEVtog`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLEVtog1, score
             }

ret scalar var_byavg_LEV_tog   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LEV_tog   = s_RetainedEigenCountAvg	 
}   /*close option mean */

}   /*close togld=="" */

*if "`retain'"==""  {
*	capture drop _GMML_*_*
*	}
	
} /* close if togvar!="" */



************** PCA VAR BY VAR DIF SAME LAGS *******************	
if "`togvar'"=="" & "`gmmdiv'"!=""  {	
	foreach var of varlist `varlistpca' {
	di "_____ PCA DIF VAR BY VAR: `var'"
 	local newvarlistd_`var' _GMMD_`var'_*
	local newvarlistldd_`var' _GMMD_`var'_*
	local newvarlistlddgmm_`var' _GMMD_`var'_*
	
 if "`togld'"==""  {	
	di as text "You are applying PCA to GMM-style DIF lags of one or more than one variable,"
	di as text "keeping the variables separated with the same lags structure"
		
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistd_`var'' if `touse'
	 }
	 if "`see'"!="" {
	 pca `newvarlistd_`var'' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistd_`var'' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistd_`var'' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in first-differences for `var' __________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreDIF`var'N1-`prefix1'varscoreDIF`var'N`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreDIF`var'N1, score
		     }

ret scalar var_byvar_DIF_`var'  = s_ExplainedVarVar_var
ret scalar nscores_byvar_DIF_`var'   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
                 }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		         }
        }
		scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreDIF`var'N1-`prefix1'avgscoreDIF`var'N`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreDIF`var'N1, score
		    }

ret scalar var_byavg_DIF_`var'   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_DIF_`var'   = s_RetainedEigenCountAvg	 
}   /*close option mean */

}  /* close togld=="" */
}  /* close for each var =="" */

*if "`retain'"==""  {
*	capture drop _GMMD_`var'_*
*	}

} /* close if togvar=="" */

************** PCA TOGVAR DIF SAME LAGS *******************	
if "`togvar'"!="" & "`gmmdiv'"!=""  {	
di "_____ PCA DIF VAR TOGETHER: `varlistpca'"
local newvarlistd_tog _GMMD_*_*
local newvarlistldd_tog _GMMD_*_*
local newvarlistlddgmm_tog _GMMD_*_*

 if "`togld'"==""  {	
	di as text "You are applying PCA to GMM-style DIF lags of one or more than one variable,"
	di as text "keeping the variables together with the same lags structure"
	
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistd_tog' if `touse'
	 }
	 if "`see'"!="" {
	 pca `newvarlistd_tog' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistd_`var'' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistd_`var'' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in first-differences for the variables `varlistpca' together"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreDIFtog1-`prefix1'varscoreDIFtog`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreDIFtog1, score
		     }

ret scalar var_byvar_DIF_tog  = s_ExplainedVarVar_var
ret scalar nscores_byvar_DIF_tog  = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
            }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		         }
            }
        scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreDIFtog1-`prefix1'avgscoreDIFtog`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreDIFtog1, score
             }

ret scalar var_byavg_DIF_tog   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_DIF_tog   = s_RetainedEigenCountAvg	 
}   /*close option mean */

}   /*close togld=="" */

*if "`retain'"==""  {
*	capture drop _GMMD_*_*
*	}
	
} /* close if togvar!="" */





************************** PCA LEV & DIF TOGETHER SAME LAGS VAR BY VAR & TOGVAR  *****************
if "`togld'"!="" & "`gmmliv'"!="" & "`gmmdiv'"!="" {
if "`togvar'"=="" {
foreach var of varlist `varlistpca' {
di "_____ PCA LEV&DIF VAR BY VAR: `var'"
local newvarlistld_`var' "`newvarlistldl_`var'' `newvarlistldd_`var''"
di "`newvarlistld_`var''"
di as text "You are applying PCA to GMM-style LEV & DIF lags of more than one variable,"
di as text "keeping the variables separated with the same lags structure"
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_`var'' if `touse'
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_`var'' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_`var'' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_`var'' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels & first_differences together for `var' __________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLD`var'N1-`prefix1'varscoreLD`var'N`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreLD`var'N1, score
		     }

ret scalar var_byvar_LD_`var'  = s_ExplainedVarVar_var
ret scalar nscores_byvar_LD_`var'   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
            }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		        }
            }
        scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLD`var'N1-`prefix1'avgscoreLD`var'N`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLD`var'N1, score
     		}

ret scalar var_byavg_LD_`var'   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LD_`var'   = s_RetainedEigenCountAvg	 
}   /*close option mean */

}  /* close for each var */
}  /*close if togvar=="" */

******* PCA LEV & DIF SAME LAGS TOGVAR ***************************
if "`togvar'"!="" {
di "_____ PCA LEV&DIF VAR TOGETHER: `varlistpca'"
local newvarlistld_tog "`newvarlistldl_tog' `newvarlistldd_tog'"
di "`newvarlistld_tog'"
di as text "You are applying PCA to GMM-style LEV & DIF lags of more than one variable,"
di as text "keeping the variables together with the same lags structure"
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_tog' if `touse'
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_tog' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_tog' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_tog' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels & first_differences together for the variables `varlistpca' together __________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLDtog1-`prefix1'varscoreLDtog`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreLDtog1, score
		     }

ret scalar var_byvar_LD_tog  = s_ExplainedVarVar_var
ret scalar nscores_byvar_LD_tog   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
            }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		        }
            }
        scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLDtog1-`prefix1'avgscoreLDtog`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLDtog1, score
     		}

ret scalar var_byavg_LD_tog   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LD_tog   = s_RetainedEigenCountAvg	 
}   /*close option mean */

}  /*close if togvar!="" */
}  /*close if togld!="" */

* POSSO TOGLIERLO?
*if "`retain'"==""  {
*  capture drop _GMM*_*_*
*   }


   
************************** PCA LEV & DIF TOGETHER DIFFERENT LAGS VAR BY VAR & TOGVAR  *****************
if "`togld'"!="" & "`gmmliv'"!="" & "`nlagsdvars'"!="" {
if "`togvar'"=="" {
foreach var of varlist `varlistpca' {
di "_____ PCA LEV&DIF VAR BY VAR: `var'"
local newvarlistld_`var' "`newvarlistldlgmm_`var'' `newvarlistlddlags_`var''"
di "`newvarlistld_`var''"
di as text "You are applying PCA to GMM-style LEV & DIF lags of more than one variable," 
di as text "keeping the variables separated"
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_`var'' if `touse'
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_`var'' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_`var'' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_`var'' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels & first_differences together for `var' __________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLD`var'N1-`prefix1'varscoreLD`var'N`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreLD`var'N1, score
		     }

ret scalar var_byvar_LD_`var'  = s_ExplainedVarVar_var
ret scalar nscores_byvar_LD_`var'   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
            }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		        }
            }
        scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLD`var'N1-`prefix1'avgscoreLD`var'N`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLD`var'N1, score
     		}

ret scalar var_byavg_LD_`var'   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LD_`var'   = s_RetainedEigenCountAvg	 
}   /*close option mean */

}  /* close for each var */
}  /*close if togvar=="" */

******* PCA LEV & DIF SAME LAGS TOGVAR ***************************
if "`togvar'"!="" {
di "_____ PCA LEV&DIF VAR TOGETHER: `varlistpca'"
local newvarlistld_tog "`newvarlistldlgmm_tog' `newvarlistlddlags_tog'"
di "`newvarlistld_tog'"
di as text "You are applying PCA to GMM-style LEV & DIF lags of more than one variable," 
di as text "keeping the variables together"
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_tog' if `touse'
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_tog' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_tog' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_tog' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels & first_differences together for the variables `varlistpca' together __________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLDtog1-`prefix1'varscoreLDtog`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreLDtog1, score
		     }

ret scalar var_byvar_LD_tog  = s_ExplainedVarVar_var
ret scalar nscores_byvar_LD_tog   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
            }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		        }
            }
        scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLDtog1-`prefix1'avgscoreLDtog`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLDtog1, score
     		}

ret scalar var_byavg_LD_tog   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LD_tog   = s_RetainedEigenCountAvg	 
}   /*close option mean */

}  /*close if togvar!="" */
}  /*close if togld!="" */

* POSSO TOGLIERLO?
*if "`retain'"==""  {
*  capture drop _GMM*_*_*
*   }   
   
   
   
   
 ************************** PCA LEV & DIF TOGETHER DIFFERENT LAGS VAR BY VAR & TOGVAR  *****************
if "`togld'"!="" & "`gmmdiv'"!="" & "`nlagslvars'"!="" {
if "`togvar'"=="" {
foreach var of varlist `varlistpca' {
di "_____ PCA LEV&DIF VAR BY VAR: `var'"
local newvarlistld_`var' "`newvarlistldllags_`var'' `newvarlistlddgmm_`var''"
di "`newvarlistld_`var''"
di as text "You are applying PCA to GMM-style LEV & DIF lags of more than one variable," 
di as text "keeping the variables separated"
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_`var'' if `touse'
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_`var'' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_`var'' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_`var'' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels & first_differences together for `var' __________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLD`var'N1-`prefix1'varscoreLD`var'N`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreLD`var'N1, score
		     }

ret scalar var_byvar_LD_`var'  = s_ExplainedVarVar_var
ret scalar nscores_byvar_LD_`var'   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
            }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		        }
            }
        scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLD`var'N1-`prefix1'avgscoreLD`var'N`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLD`var'N1, score
     		}

ret scalar var_byavg_LD_`var'   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LD_`var'   = s_RetainedEigenCountAvg	 
}   /*close option mean */

}  /* close for each var */
}  /*close if togvar=="" */

******* PCA LEV & DIF SAME LAGS TOGVAR ***************************
if "`togvar'"!="" {
di "_____ PCA LEV&DIF VAR TOGETHER: `varlistpca'"
local newvarlistld_tog "`newvarlistldllags_tog' `newvarlistlddgmm_tog'"
di "`newvarlistld_tog'"
di as text "You are applying PCA to GMM-style LEV & DIF lags of more than one variable," 
di as text "keeping the variables together"
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_tog' if `touse'
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_tog' if `touse'
	 }
	}
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `newvarlistld_tog' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `newvarlistld_tog' if `touse', covariance
	 }
	}
	***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about PCA of IV in levels & first_differences together for the variables `varlistpca' together __________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscoreLDtog1-`prefix1'varscoreLDtog`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscoreLDtog1, score
		     }

ret scalar var_byvar_LD_tog  = s_ExplainedVarVar_var
ret scalar nscores_byvar_LD_tog   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
            }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		        }
            }
        scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscoreLDtog1-`prefix1'avgscoreLDtog`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscoreLDtog1, score
     		}

ret scalar var_byavg_LD_tog   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_LD_tog   = s_RetainedEigenCountAvg	 
}   /*close option mean */

}  /*close if togvar!="" */
}  /*close if togld!="" */

if "`retain'"==""  {
   capture drop _GMM*_*_*
   }   
     


*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
*********** FINALLY ******************************************************
**** Classical IVs or different variables taken together *****************
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
if "`gmmdiv'"=="" & "`gmmliv'"==""  & "`nlagslvars'"==""  & "`nlagsdvars'"=="" {
    if `nvars'==1  {
	di as error "You have only one variable: you cannot apply PCA on it"
	di as error "Use gmm() and/or lags() options if you want GMM-style lags of a variable taken alone"
	exit 198
	}
	else if `nvars'>1 { 
	di as text "You are applying PCA to different variables or to standard lags of the same variable(s)," 
	di as text "taken together."
	if "`covariance'"=="" {
	 if "`see'"=="" {
	 qui pca `varlistpca' if `touse'
	 }
	 if "`see'"!="" {
	 pca `varlistpca' if `touse'
	 }
	} 
	if "`covariance'"!="" {
	 if "`see'"=="" {
	 qui pca `varlistpca' if `touse', covariance
	 }
	 if "`see'"!="" {
	 pca `varlistpca' if `touse', covariance
	 }
	} 
	} /* close nvars>1 */ 
	
		***** COMPUTATION OF SCORES AFTER PCA
di as text " _________ Some information about standard PCA for the variables `varlistpca' __________"
scalar `s_trace'=e(trace)	
di as result "Trace of the matrix: " _col(80) `s_trace'

if "`variance'"!="" {
        local optname variance()
		local PV=`variance'
		di as result "Percentage of selected variability to be explained: "  _col(80) `PV' "%"
        }		
if `"`PV'"' == "" {
		local PV = 90
		di as result "By default percentage of selected variability to be explained: "  _col(80) `PV'  "%"
        }
        * variability criterion *
		scalar s_ExplainedVarVar=0
		scalar s_RetainedEigenCountVar=0
		local s_trace_PV_perc = (`PV'/100)*`s_trace'
		*di as result "Percentage of trace due to the selected variability:" _col(80) `s_trace_PV_perc'
		while ( s_ExplainedVarVar < `s_trace_PV_perc' ) {
			scalar s_RetainedEigenCountVar = s_RetainedEigenCountVar+1
			scalar s_ExplainedVarVar       = s_ExplainedVarVar  + ( el( e(Ev), 1, s_RetainedEigenCountVar) )
        }
		*di as result "Sum of eigenvalues corresponding to the retained eigenvectors: "  _col(80) s_ExplainedVarVar 
		scalar s_ExplainedVarVar_var = (s_ExplainedVarVar / `s_trace')*100
		di as result "Percentage of variance explained by the variability criterion: "  _col(80) s_ExplainedVarVar_var "%"
		di as result "Number of retained scores according to the variability criterion: "  _col(80) s_RetainedEigenCountVar
		if s_RetainedEigenCountVar >1 {
			local l_SecondIndex = scalar(s_RetainedEigenCountVar)           		
			qui predict double `prefix1'varscorepca1-`prefix1'varscorepca`l_SecondIndex', score
			 }			
		else {
		qui predict double `prefix1'varscorepca1, score
		     }

ret scalar var_byvar_togvar  = s_ExplainedVarVar_var
ret scalar nscores_byvar_togvar   = s_RetainedEigenCountVar 

if "`avg'"!=""  {
		* average criterion *
		scalar s_RetainedEigenCountAvg = 0
		scalar s_ExplainedVarAvg     = 0
		forvalues p=1/`e(f)' {
			* this is a trick to find if the eigenvalue is greater that avg(eigenvalues)
            scalar delta         = ( el(e(Ev),1,`p'))-(`s_trace' / `e(f)')
            if delta > 0 {
			    * autovalore oltre la media
                scalar s_RetainedEigenCountAvg = s_RetainedEigenCountAvg+1
				scalar s_ExplainedVarAvg      = s_ExplainedVarAvg + el(e(Ev),1,`p')
            }
            else {
			    * ho esaurito gli autovalori > media quindi esco dal loop forvalues
			    continue, break
		        }
            }
        scalar s_RetainedPC      = s_RetainedEigenCountAvg
		scalar s_ExplainedVarAvg_var = (s_ExplainedVarAvg / `s_trace')*100
		di as result "Percentage of variance explained by the average criterion: " _col(80) s_ExplainedVarAvg_var "%"
	    di as result "Number of retained scores according to the average criterion: "  _col(80) s_RetainedEigenCountAvg
		if s_RetainedEigenCountAvg>1 {
			local l_ThirdIndex = scalar(s_RetainedEigenCountAvg)
			quietly predict double `prefix1'avgscorepca1-`prefix1'avgscorepca`l_ThirdIndex', score         				
			}
		else {
			quietly predict double `prefix1'avgscorepca1, score
		     }

ret scalar var_byavg_togvar   = s_ExplainedVarAvg_var
ret scalar nscores_byavg_togvar   = s_RetainedEigenCountAvg	 
}   /*close option mean */

}  /* pca together without gmm/lags */


end
**************************
