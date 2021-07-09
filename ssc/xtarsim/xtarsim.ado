*! xtarsim V1.0.0   31may05
*! Giovanni S.F. Bruno, Universita' Bocconi, Milan, Italy
*! giovanni.bruno@unibocconi.it




program define xtarsim
version 8.2
 
preserve
drop _all
set type double

syntax newvarlist (min=3 max=4 numeric), Nid(integer) Time(integer) Gamma(real) /*
*/ Beta(real)  Rho(real) SNratio(real) [Sigma(real 1) ONEway(string) TWOway(string) /*
*/ Unbd(string) SEED(string)]



tokenize `varlist' 

	if "`twoway'"=="" & "`4'"!="" {
		di as error "The number of newvars must" 
		di as error "equal three for a one-way model"
		exit 198
		}

	else if "`twoway'"!="" & "`4'"==""  {
		di as error "The number of newvars must"
		di as error "equal four for a two-way model"
		exit 198
		}

 
if "`seed'"!="" set seed `seed' 

local nobs=`nid'*`time'


local ss=`snratio'^0.5

local gr=`gamma'+`rho'
local gxr=`gamma'*`rho'

// sd of epsx as determined by model params and the sn_ratio

local sx ((`ss'^2-(`gamma'^2)/(1-`gamma'^2))*(1+/*
*/`gr'^2*(`gxr'-1)/(1+`gxr')-`gxr'^2)/`beta'^2)^0.5

	if `sx'==. {
		di as error "parameters not compatible with a 
        	di as error "finite positive variance for epsx"
		exit 411 
		}

local var_phi=(1+(`gr'^2/(1+`gxr'))*(-1+`gxr')-`gxr'^2)^(-1)
local cor_tt1=`gr'/(1+`gxr')
local cor_tt2=(`gr'^2/(1+`gxr'))-`gxr'

	qui {
		set obs `nobs'

		/* gen individual groups */

		tempvar eta theta  epsx epsy ps ph mmx mx mxt

 		egen int ivar=seq(), from(1) to(`nobs') block(`time')
 		sort ivar

		/* gen time var */

 		by ivar: gen int tvar=_n
 		tsset ivar tvar

 		gen `epsx'=`sx'*invnorm(uniform())
 		gen `epsy'=`sigma'*invnorm(uniform())

		
 		// gen x as AR1
		 
		gen `2'=`epsx'*(1-`rho'^2)^(-0.5)
 		 
		replace `2'=`rho'*L.`2' + `epsx' if tvar>1 

		// gen individual effects 
			
			// random and sd=1-`gamma' (default)
			if "`oneway'"=="" {
					gen `eta'=(1-`gamma')*invnorm(uniform()) if tvar==1
 					bysort ivar: gen `3'=`eta'[1]
				}
			else   	        {
					tokenize `oneway' 
					if "`1'"!="corr"&"`1'"!="rand" {
					di as error "`1' not allowed"
					exit 198
					}
					if "`2'"=="" {
					di as error "both effect_type and load must be provided" 
					exit 198
					}
					local ie "`1'"
					local load `2'
					tokenize `varlist'
					
					// correlated
					if "`ie'"=="corr" {  
						bysort ivar: egen `mx'=mean(`2')
						egen `mmx'=mean(`mx')
						gen `3'=`load'*(1-`gamma')*(`mx'-`mmx'+1)
						}
					
					// random and sd=`load'*(1-`gamma')
					if "`ie'"=="rand"  { 	
					gen `eta'=`load'*(1-`gamma')*invnorm(uniform()) if tvar==1
					bysort ivar: gen `3'=`eta'[1]
				}
			}
			
		// gen time effects 
			
			if "`twoway'"!="" {
			
			// correlated
			tokenize `twoway'
			if "`1'"!="corr"&"`1'"!="rand" {
					di as error "`1' not allowed"
					exit 198
				}
			if "`2'"=="" {
				di as error "both effect_type and load must be provided" 
				exit 198
				}
			local te "`1'"
			local load `2'
			tokenize `varlist'
			
				if "`te'"=="corr" { 
					bysort tvar: egen `mxt'=mean(`2')
					gen `4'=`load'*(1-`gamma')*(`mxt'-`mxt'[1])	
						}
			
			// random
			
				if "`te'"=="rand"  { 	
					sort tvar ivar
					gen `theta'=`load'*(1-`gamma')*invnorm(uniform()) if ivar==1
					bysort tvar (ivar): gen `4'=`theta'[1]
				}
			}

 		// gen ph as AR2
		sort ivar tvar
 		gen `ph'=`epsx'*(`var_phi'^0.5) 
 		replace `ph'=L.`ph'*`cor_tt1'+`epsx'*`var_phi'^0.5*(1-`cor_tt1'^2)^0.5 if tvar>1
 		replace `ph'=`gr'*L.`ph' - `gxr'*L2.`ph' + `epsx' if tvar>2
	 

		// gen ps as AR1



 		gen `ps'=`epsy'*(1-`gamma'^2)^(-0.5)
 		replace `ps'=`gamma'*L.`ps' + `epsy' if tvar>1
			
		if "`twoway'"!="" gen `1'=`beta'*`ph' +`ps'+(`3'+`4')/(1-`gamma')
 		else gen `1'=`beta'*`ph' +`ps'+`3'/(1-`gamma')

		// define unbalanced design 
		// drop the last `2' observations for the first `1' individuals
			
		if "`unbd'"!="" {
				tokenize `unbd'
				if `time'-`2'<1 { 
				noisily di as error "the number of time periods discarded may not"
					di as error "exceed the total number of time periods"
				exit 411	    		
				}
				drop if (ivar<=(`1')&tvar>(`time'-`2'))
			}
		} 

	tokenize `varlist' 
 
	label var ivar "panel variable"
	label var tvar "time variable"
	label var `1'  "dependent variable"
	label var `2'  "exogenous regressor"
	label var `3'  "individual effect"
	if "`4'"!="" label var `4'  "time effect"

	order ivar tvar `1' `2' `3' `4'
restore, not
end





