*! version 1.2 Yutong Duan, Paul von Hippel
*! Updated on 05/12/2016
*! personal
capture prog drop mgbe Est aic_selection bic_selection weighted_ic inequality GB2_quantile GG_quantile P_quantile LN_quantile


/************************************************************************/
/* Next are quantile functions for some distributions in the GB family. */
/* Modified on Mar. 27, 2016 by Yutong */

program GB2_quantile, eclass
 args a b p q
 forv x=1/999 {
  local ib = invibeta(`p',`q',`x'/1000)
  cap eret scalar p`x' =  `b'* (`ib'/(1-`ib'))^(1/`a')
 }
 
 end

program GG_quantile, eclass
	args a b p
	forv x=1/999 {
	local invg = invgammap(`p', `x'/1000)
	eret scalar p`x' =  `invg' ^(1/`a') * `b'
	}
end

prog P_quantile, eclass 
args b q
 forv x=1/999 {
  eret scalar p`x' = `b'*((1-`x'/1000)^(-1/`q')-1)
 }
 end

program LN_quantile, eclass
 args b p
 forv x=1/999 {
  eret scalar p`x' = exp(`b' + `p'*invnormal(`x'/1000) )
 }
 
 end
 
 
/***************************************************************************************/
/* Now define the mgbe command */

prog define mgbe, nclass byable(recall) 
// sortpreserve

/* don't need for the alternative reshape*/
/*
cap findfile _ggini.ado

if _rc != 0 {
         di as txt "user-written package egen_inequal needs to be installed first;"
         di as txt "use -ssc install egen_inequal- to do that"
         exit 498
}

cap findfile savesome.ado

if _rc != 0  {
         di as txt "user-written package savesome needs to be installed first;"
         di as txt "use -ssc install savesome- to do that"
         exit 498
}
*/
syntax varlist(min=3 max=3 numeric) [if] [in] [, DISTribution(string asis) AIC BIC AVERAGE SAVing(string asis) BY(varlist)] 
/*
if "`e(cmd)'" != "mgbe" {
   noi di as error "results for mgbe not found"
   exit 301
  }
*/
set more off

// preserve 
marksample touse, novarlist
qui keep if `touse'==1
tokenize `varlist'
local n `1'
local z1 `2'
local z2 `3'


local new_var a b p q converged  k ll AIC BIC mean_defined var_defined w mean_param var_param sd_param ///
	  nonzero_bins model_identified iterations all_bin s_ln s_ln_last df j P sum_w
			  
foreach v in `new_var' {
qui gen `v' = .
}

qui {
 expand 2, generate(dist)
 tostring dist, replace
 replace dist = "loglog" if dist =="1"
 expand 2 if(dist =="0"), gen(dist1)
 replace dist = "pareto2" if dist1 ==1
 drop dist1
 expand 2 if(dist =="0"), gen(dist1)
 replace dist = "gamma" if dist1 ==1
 drop dist1
 expand 2 if(dist =="0"), gen(dist1)
 replace dist = "ln" if dist1 ==1
 drop dist1
 expand 2 if(dist =="0"), gen(dist1)
 replace dist = "dagum" if dist1 ==1
 drop dist1
 expand 2 if(dist =="0"), gen(dist1)
 replace dist = "sm" if dist1 ==1
 drop dist1
 expand 2 if(dist =="0"), gen(dist1)
 replace dist = "beta2" if dist1 ==1
 drop dist1
 expand 2 if(dist =="0"), gen(dist1)
 replace dist = "gg" if dist1 ==1
 drop dist1
 expand 2 if(dist =="0"), gen(dist1)
 replace dist = "gb2" if dist1 ==1
 drop dist1
 replace dist = "wei" if dist =="0"
}




forvalues i = 1/999 {
 qui gen P`i' = .
}



global S_mln "`n'"
global S_mlz1 "`z1'"
global S_mlz2 "`z2'"

global aic `aic'
global bic `bic'
global average `average' 
global by `by'
global saving `saving'

/*
local n =1
foreach b of varlist `by' {
 // global b`n' `b'
 local b`n' `b'
 local n = `n' + 1  
 
 // di "2. `by1' `by2'"
}

di "`b1'"  "`b2'"
*/
local dist wei loglog pareto2 gamma ln dagum sm beta2 gg gb2 
if "`distribution'" != "" {
local distribution lower("`distribution'")
 foreach d in `dist' {
 if regexm(`distribution', "`d'") == 1 local `d' "`d'"
 /* 
 else {
 di "please check distribution"
 exit 198
 }
 */
 }
}
else {
 foreach d in `dist' {
 local `d' "`d'"
 }
}

  
if "`by'" != "" {
qui{
  sort `by' dist
  qui by `by' dist:  gen count_all = sum(`n' ) if `touse'
  sort `by' dist count_all
  qui by `by' dist:  replace count_all = count_all[_N] if `touse'
}
}
else {
qui {
 sort dist `z1' `z2'
 by dist: gen count_all = sum(`n') if `touse'
 su count_all, meanonly
 qui replace count_all = r(max) if `touse'
}
}

qui drop if `n' == 0 & `touse'
qui count if ( `z1' > `z2')  & `touse'
 if r(N) > 0 {
di as txt "`r(N)' observations `z1' > `z2', please check input"
exit 498
 }
 

foreach v in `z1' `z2' {
 conf numeric var `v'
 su `v' if `touse', meanonly
 if r(min)<0 {
  di as err "No boundary may be negative"
  exit 198
  }
 }



constraint define 1 [a]_cons=1 if ( "`beta2'" != "" | "`pareto2'" != "" | "`gamma'" != "" )
constraint define 3 [p]_cons=1 if("`sm'" !="" | "`pareto2'" !="" | "`wei'" !="" | "`loglog'" != "")
constraint define 4 [q]_cons=1 if ("`dagum'" != "" | "`loglog'" != "")

tempfile mgbe_running_data mgbe_running_results mgbe_quantiles
qui save `mgbe_running_data', replace


if "`by'" != "" qui levelsof `by' , local(identifiers)

else { 
local by `1'
local identifiers `1'
}

su `by' , meanonly 
local level_min `r(min)'

di "Distributions selected: `wei' `loglog' `pareto2' `gamma' `ln' `dagum' `sm' `beta2' `gg' `gb2'"
if "`average'" == "" {
if "`bic'" != ""{
di "Model selection by BIC"
}
else di "Model selection by AIC"
}
else {
if "`bic'" != ""{
di "weighted model averaging by BIC"
}
else di "weighted model averaging by AIC"
}

foreach id of local identifiers {

if "$by" != "" di "$by = `id'"
 use `mgbe_running_data', clear

qui replace `touse' = 0 if `by' != `id'
qui replace `touse' = 1 if `by' ==`id'
qui keep if `touse' == 1

if "$by" == "" | ("$by" != "" & `id' == `level_min') {
qui count if `z2' == .
 if r(N) > 10 {
di as txt "only the rightmost bound can be missing, please check input"
exit 498
 }
}
qui count if  `n' >= 0
qui replace all_bin = r(N)/10 

qui count if `n' > 0
qui replace nonzero_bin = r(N)/10 

local dist `wei' `loglog' `pareto2' `gamma' `ln' `dagum' `sm' `beta2' `gg' `gb2'

foreach d in `dist' {
global S_dist "`d'"

if "`d'" == "gb2" {
// di "running gb2"

if nonzero_bins >= 5 {
 qui replace model_identified = 1 if dist ==  "`d'"
 ml model lf mgbe_ll (a: ) (b:)  (p:) (q:), technique(dfp 5 nr 5) 
 }
 else {
 di "number of populated bins is smaller than the number of parameters plus 1, GB2 not fitted"
 qui replace model_identified = 0 if dist ==  "`d'"
 
 }
}

if "`d'" == "dagum" {
// di "running dag"
if nonzero_bins >= 4  {
 qui replace model_identified = 1  if dist == "`d'"
 ml model lf mgbe_ll (a: ) (b: )  (p: ) (q:), constraint(4) ///
 init(a:_cons=3 b:_cons = 70000 p:_cons = .4)  technique(dfp 5 nr 5)  
  }
 else {
 di "number of populated bins is smaller than the number of parameters plus 1, DAGUM not fitted"
 qui replace model_identified = 0 if dist == "`d'"

 }
}

if "`d'" == "sm" {
// di "running sm"
if nonzero_bins >= 4 {
 qui replace model_identified = 1 if dist == "`d'"
 
 ml model lf mgbe_ll (a: ) (b: )  (p: ) (q:), constraint(3) ///
 init(a:_cons=1.6 b:_cons = 166950  p:_cons = 1 q:_cons =  5.7)  technique(dfp 5 nr 5)  
}
 else {
 di "number of populated bins is smaller than the number of parameters plus 1, SM not fitted"
 qui replace model_identified = 0 if dist == "`d'"

 }
}

if "`d'" == "beta2" {
// di "running beta2"
if nonzero_bins >= 4 {
 qui replace model_identified = 1 if dist == "`d'"
 
 ml model lf mgbe_ll (a: ) (b: )  (p: ) (q:) , constraint(1) ///
 init(b:_cons=1e+15  p:_cons=2 q:_cons=8e+12) technique(dfp 5 nr 5)  
}
 else {
 di "number of populated bins is smaller than the number of parameters plus 1, BETA2 not fitted"
 qui replace model_identified = 0 if dist == "`d'"

 }
}

if "`d'" == "loglog" {
// di "running loglog"
if nonzero_bins >= 3 {
 qui replace model_identified = 1 if dist == "`d'"
 
 ml model lf mgbe_ll (a: ) (b: )  (p: ) (q:), constraint(3 4) ///
 init(a:_cons=2 b:_cons = 40000 p:_cons = 1 q:_cons = 1)  technique(dfp 5 nr 5)  
}
 else {
 di "number of populated bins is smaller than the number of parameters plus 1, Log-Logistic not fitted"
 qui replace model_identified = 0 if dist == "`d'"

 }
 }
if "`d'" == "gg" {
// di "running gg"
if nonzero_bins >= 4 {
 qui replace model_identified = 1  if dist == "`d'"
 ml model lf mgbe_ll (a: ) (b: ) (p: ) , init(a:_cons=1 b:_cons = 60000 p:_cons = 2) technique(dfp 5 nr 5) 
}
 else {
 di "number of populated bins is smaller than the number of parameters plus 1, GG not fitted"
 qui replace model_identified = 0 if dist == "`d'"

 }
 }
if "`d'" == "gamma" {
// di "running gamma"
if nonzero_bins >= 3 {
 qui replace model_identified = 1 if dist == "`d'"
 ml model lf mgbe_ll (a: ) (b: ) (p: ), constraint(1) init(a:_cons = 1 b:_cons = 60000 p:_cons = 2)  
}	
 else {
 di "number of populated bins is smaller than the number of parameters plus 1, Gamma not fitted"
 qui replace model_identified = 0 if dist == "`d'"

 }
 }
 
if "`d'" == "wei" {
// di "running wei"
if nonzero_bins >= 3 {
 qui replace model_identified = 1 if dist == "`d'"
 ml model lf mgbe_ll (a: ) (b: ) (p: ) , constraint(3) init(a:_cons=2 b:_cons = 60000 p:_cons = 1)   
}
 else {
 di "number of populated bins is smaller than the number of parameters plus 1, Weibull not fitted"
 qui replace model_identified = 0 if dist == "`d'"

 }
 }

if "`d'" == "ln" {
// di "running ln"
if nonzero_bins >= 3 {
 qui replace model_identified = 1 if dist == "`d'"
 ml model lf mgbe_ll  (b: ) (p: ) 
}
 else {
 di "number of populated bins is smaller than the number of parameters plus 1, log-normal not fitted"
 qui replace model_identified = 0 if dist == "`d'"

 }
}

if "`d'" == "pareto2" {
// di "running pareto"
if nonzero_bins >= 3 {
 qui replace model_identified = 1 if dist == "`d'"
 ml model lf mgbe_ll  (b: ) (q: ) , technique(dfp 5 nr 5)
}
 else {
 di "number of populated bins is smaller than the number of parameters plus 1, Pareto 2 not fitted"
 qui replace model_identified = 0 if dist == "`d'"

 }
}


capture ml max, nrtolerance(1e-3) difficult
if _rc != 0 {
	if _rc == 430 {
		di "convergence not achieved for `d' "
		qui replace converged = 0 if dist == "`d'"
		ereturn clear
		exit
	}
	else {
		di "error "_rc " , no estimates for `d'"
		qui replace converged = 0 if dist == "`d'"
	    ereturn clear
	   // exit	
	}
}
else {
	qui replace iterations = e(ic) if dist == "`d'"
	qui replace converged = 1 if dist == "`d'"
	qui	replace ll=e(ll) if dist == "`d'"
	mat b = e(b)
	
	/*  -------  LOGNORMAL  ------  */
	if "`d'" == "ln" {
	local b = b[1,1]
	local p = b[1,2]
	qui {
	replace b = `b' if dist == "`d'"
	replace p = `p' if dist == "`d'"
	replace k = 2 if dist == "`d'"
	replace mean_param = exp( b + .5*p^2 ) if dist == "`d'"
	replace var_param = exp(2*(b+p^2))-exp(2*b+p^2) if dist == "`d'"
	replace sd_param = sqrt(var_param) if dist == "`d'"
	replace ll=e(ll) if dist == "`d'"
	replace mean_defined = 1 if dist == "`d'"
	replace var_defined = 1 if dist == "`d'"
	}
	} 
	
	/*  -------  PARETO2  ------  */
	else if "`d'" == "pareto2" {
	local b = b[1,1]
	local q = b[1,2]
	qui {
	replace b = `b' if dist == "`d'"
	replace q = `q' if dist == "`d'"
	replace k = 2 if dist == "`d'"
	replace mean_param =  b / (q-1) if dist == "`d'"
	replace var_param =b^2*q/((q-1)^2*(q-2)) if dist == "`d'"
	replace sd_param = sqrt(var_param) if dist == "`d'"
	replace mean_defined = (q > 1) if dist == "`d'"
	replace var_defined = (q > 2) if dist == "`d'"
	}
	} 
	/*  -------  GG/GAMMA/WEIBULL  ------  */
	else if  "`d'" == "gg" | "`d'" == "gamma" | "`d'" == "wei" { 
	local a = b[1,1]
	local b = b[1,2]
	local p = b[1,3]
	qui {
	replace a = `a' if dist == "`d'"
	replace b = `b' if dist == "`d'"
	replace p = `p' if dist == "`d'"
	replace mean_param = b * exp(lngamma(p + 1/a)) / exp(lngamma(p)) if dist == "`d'"
	replace var_param = b^2 * exp(lngamma(p + 2/a)) / exp(lngamma(p)) - ///
		 exp(2*lngamma(p + 1/a))/exp(2*lngamma(p)) if dist == "`d'"
		replace sd_param = sqrt(var_param) if dist == "`d'"
	replace k = 2 if dist == "gamma" | dist == "wei"
	replace k = 3 if dist == "gg"
	replace mean_defined = (p>-1/a) if dist == "`d'"
	replace var_defined = (p>-2/a) if dist == "`d'"
	}
	 }
	/*  -------  GB2/DAG/SM/LOGLOG/BETA2  ------  */
	else {
	local a = b[1,1]
	local b = b[1,2]
	local p = b[1,3]
	local q = b[1,4]
	qui {
	replace a = `a' if dist == "`d'"
	replace b = `b' if dist == "`d'"
	replace p = `p' if dist == "`d'"
	replace q = `q' if dist == "`d'"
	replace mean_param = b * exp(lngamma(p+1/a)) * exp(lngamma(q-1/a)) ///
	  /( exp(lngamma(p))*exp(lngamma(q))) if dist == "`d'"
	replace var_param = b*b*exp(lngamma(p+2/a))*exp(lngamma(q-2/a)) ///
	  /( exp(lngamma(p))*exp(lngamma(q)) )- mean_param^2 if dist == "`d'"
	  
	replace sd_param = sqrt(var_param) if dist == "`d'"
	
	replace k = 4 if  dist == "gb2" 
	replace k = 3 if  dist  == "dagum" | dist  == "sm" |dist ==  "beta2"
	replace k = 2 if dist  == "loglog"
	replace mean_defined = ((-p<1/a) & (1/a<q)) if dist == "`d'"
	replace var_defined = ((-p<2/a) & (2/a<q)) if dist == "`d'"
  
	}
	}
	
	qui{
	 replace AIC = -2*ll + k*2 if dist == "`d'"
	 replace BIC = -2*ll + k*ln(count_all) if dist == "`d'"
	 replace var_param = . if (!var_defined & dist == "`d'")
	 replace mean_param = . if (!mean_defined & dist == "`d'") |( var_param ==. & dist == "`d'") 
	 }
	 if "`d'" == "ln" LN_quantile `b' `p' 
	 else if "`d'" == "pareto2" P_quantile `b' `q' 
	 else if "`d'" == "gg" | "`d'" == "gamma" | "`d'" == "wei" GG_quantile  `a' `b' `p'
	 else GB2_quantile  `a' `b' `p' `q'
	 forvalues i = 1/999 {
	  qui replace P`i' = e(p`i') if dist == "`d'"
	 }
	
} //end generate estimates 
}

 
qui replace df = min(nonzero_bin, all_bin-1)-k 

qui bysort dist: replace s_ln = sum(`n' * (ln(`n' / count_all)))


qui gsort dist -s_ln
qui by dist: replace s_ln_last  = s_ln[_N]
qui by dist: keep if _n == _N

qui tab dist
if r(r) > 1 {
// qui keep if mean_defined == 1 & var_defined == 1 
gsort -var_defined
qui gen dist_num = _n if var_defined == 1
if "$average" == "" {
if "$bic" != "" bic_selection `0'
else aic_selection `0'

 // end AIC BIC selection
 /* ===========    save quantiles   =============*/

if "$by" != "" {
preserve 
qui keep $by dist P1-P999
if `id' != `level_min'{
	qui append using `mgbe_quantiles'
	 }
qui save `mgbe_quantiles',replace
restore 
}

else {
preserve 
qui keep dist P1-P999
qui save `mgbe_quantiles',replace
restore 
}
/* =================    reshape and calculate inequality statistics  ======================*/

qui expand 999
qui replace j =_n
forv i = 1/999 {
	qui replace P = P`i' in `i'
	}
} // end 'not averaging model'

else { // averaging model
qui expand 999
qui bysort dist_num: replace j =_n
forv i = 1/999 {
	qui bysort dist_num: replace P`i' = . if j !=`i'
	}
qui drop P
qui egen P = rowmean(P1-P999)
weighted_ic `0'
}

} // end 'more than 1 dist'

else { 
qui gen dist_num = _n
qui expand 999
qui replace j =_n
forv i = 1/999 {
	qui replace P = P`i' in `i'
	}
	
}

inequality `0'

if "$by" != "" {
if `id' != `level_min'{
qui append using `mgbe_running_results'
  }
qui save `mgbe_running_results',replace
 }
 
} // end county loop



qui gen G2 = -2*(ll-s_ln_last )
qui gen pval = chi2tail(df, G2) 
order df G2 pval, after(dist)

/* =================    collapse data  ======================*/
collapse_data `0'


if "$average" == "" {
if "$by" != "" merge 1:1 $by dist using `mgbe_quantiles', noreport
else merge 1:1 dist using `mgbe_quantiles', noreport
qui drop _merge
qui drop if converged ==.
}


if "$saving" != ""{
   qui save "$saving", replace
   di "saving results to $saving "
  }
  
if "$average" == "" qui drop P*
list,compress 
end



program inequality

// drop $S_mln $S_mlz1 $S_mlz2 

// by dist, sort: egen median = median(P)
local inequality mean median sd rmd cov sdl gini mehran piesch kakwani theil mld entropy half
 foreach stat in `inequality' {
   qui egen `stat' =`stat'(P), by(dist_num)
  }
qui keep if j == 1
qui drop P P1-P999 j
qui gen var = sd^2
end

/*

if "$average" != "" {

di "reshape begin"
if "$by" != ""{
 qui reshape long P, i("$by" dist)
 qui by $by dist, sort: egen median = median(P)
}
else {
 qui reshape long P, i(dist)
 qui egen median = median(P)
}

di "reshape end, calculating inequality statistics"
local distribution gb2 dagum wei loglog pareto2 gamma ln sm beta2 gg
local inequality rmd cov sdl gini mehran piesch kakwani theil mld entropy half

foreach d in `distribution' {
 foreach stat in `inequality' {
  tempvar P_`d' `stat'_`d'
  qui gen `P_`d'' = P if dist == "`d'"
  if "$by" !="" qui egen ``stat'_`d'' =`stat'(`P_`d''), by("$by")
  else qui egen ``stat'_`d'' =`stat'(`P_`d'')
  qui replace ``stat'_`d'' = 0 if dist != "`d'"
  qui replace ``stat'_`d'' = . if var ==.
  }
}



foreach stat in `inequality' {
 qui gen `stat' = ``stat'_gb2' + ``stat'_dagum' + ``stat'_wei' + ``stat'_loglog' + ///
 ``stat'_pareto2' + ``stat'_gamma' +``stat'_ln'  +``stat'_sm' +``stat'_beta2' +``stat'_gg'  
}
qui keep if _j == 1
qui drop P
if "$by"!= "" merge 1:1 $by dist using `mgbe_noquantiles', noreport
else merge 1:1 dist using `mgbe_noquantiles', noreport
}


*/

program aic_selection
su AIC if var_defined==1 & mean_defined==1, meanonly
qui keep if AIC == r(min)
end

program bic_selection
su BIC if var_defined==1 & mean_defined==1, meanonly
qui keep if BIC == r(min)

end


prog weighted_ic
 if ("$aic" != "") | ("$aic" == "" & "$bic" == ""){
   qui {
    su AIC if var_defined==1 & mean_defined==1, meanonly
    replace w = exp(.5*(`r(min)'-AIC)) 
	replace sum_w = sum(w)
	replace w = w/sum_w 
	replace w = 0 if w ==.
   }
}

if "$bic" != "" {
 qui {
    su BIC if var_defined==1 & mean_defined==1, meanonly
    replace w = exp(.5*(`r(min)'-BIC))
	replace sum_w = sum(w)
	replace w = w/sum_w
	replace w = 0 if w ==.
 }
}
/*
local dist gb2 dagum wei loglog pareto2 gamma ln sm beta2 gg
 foreach d in `dist' {
  qui gen w_`d' =.
   if "$by" != "" qui by $by : replace w_`d' = w if dist == "`d'"
   else qui replace w_`d' = w if dist == "`d'"
 }
 */
end


prog collapse_data 

if  "$average" == "" {
if "$by" != ""  {

 qui collapse (first) dist a b p q ll converged count_all AIC BIC ///
 mean var sd  median rmd cov sdl gini mehran piesch kakwani theil mld entropy half ///
 nonzero_bins model_identified mean_defined var_defined iterations all_bin df G2 pval, by("$by") 
}
else {
 qui collapse (first) dist a b p q ll converged count_all AIC BIC ///
 mean var sd median rmd cov sdl gini mehran piesch kakwani theil mld entropy half ///
 nonzero_bins model_identified mean_defined var_defined iterations all_bin df G2 pval

}

}


if "$average" != "" {

 qui d,s
 if  r(N) >1 & model_identified==1 {
	if "$by" != "" {
	qui collapse (mean) mean var sd median rmd cov sdl gini mehran piesch ///
	kakwani theil mld entropy half (max) all_bin nonzero_bins count_all [iw=w], cw by("$by") 
	}
	else {
	qui collapse \(mean) mean var sd median rmd cov sdl gini mehran piesch ///
	kakwani theil mld entropy half (max) all_bin nonzero_bins count_all [iw=w], cw
	}
	}
 else qui drop *_param dist $S_mlz1 $S_mlz2 __*  s_ln* sum_w 
 }
// label var count_all "all cases in bin"
end



