*! ksur v1   JOtero & JSmith 07dec2016
*! ksur v1.1 Includes Mata logic (suggested by CFBaum) 24aug2017
*! ksur v1.2 Onepanel added, returns modified (suggested by CFBaum) 24aug2017
*! ksur v1.3 Guard against rounding values in alphas (suggested by CFBaum) 26jan2018

capture program drop ksur
program ksur, rclass
version 13

// syntax varname(ts) [if] [in], CASE(integer) [, MAXLag(integer -1) noPRINT]

syntax varname(ts) [if] [in] [, TREND MAXLag(integer -1) noPRINT]

preserve
marksample touse
_ts tvar panelvar `if' `in', sort onepanel
markout `touse' `tvar'
 
quietly tsreport if `touse'
if r(N_gaps) {
   display in red "sample may not contain gaps"
   exit
}
 
global fileref "`c(sysdir_plus)'k/ksur.mtx"

tempname cbar rhobar
tempvar  glsy y y3 trd glstrd glscons sspl

// Generate a time trend, which starts in 1, regardless of the start of the sample period
quietly gen `trd' = sum(`touse')

// Determine the number of observations "t" that is used in the response surfaces,
// which is equal to the number of observations of the variable of interest minus one

local lastobs  = `trd'[_N]    

local t=`lastobs'-1

if `maxlag'==-1 {
   local maxlag = int(12*(`lastobs'/100)^0.25)
}

// compute regressors of the response surfaces

local t1 = 1/`t'
local t2 = 1/`t'^2
local t3 = 1/`t'^3
local t4 = 1/`t'^4

local p1t = (`maxlag')/`t'
local p2t = (`maxlag'^2)/`t'
local p3t = (`maxlag'^3)/`t'
local p4t = (`maxlag'^4)/`t'

local firstobs = `maxlag'+1

local case = cond("`trend'" == "", 1, 2)

// Case 1: GLS demeaned data
if `case'==1 {
   local cbar -9
   local rhobar = 1+`cbar'/`lastobs'
   
   quietly gen double `glscons' = 1                           if `trd'==1
   quietly replace    `glscons' = 1 -`rhobar'                 if `trd'>1
   
   quietly gen double `glsy' = `varlist'                      if `trd'==1
   quietly replace    `glsy' = `varlist'-`rhobar'*L.`varlist' if `trd'>1

   quietly regress    `glsy' `glscons' if `touse' , noconstant
   quietly gen double `y' = `varlist' - _b[`glscons']
   
   quietly gen double `y3' = `y'^3
   
   local treat "demeaned"
}

// Case 2: GLS detrended data
else if `case'==2 {
   local cbar -17.5
   local rhobar = 1+`cbar'/`lastobs'
   
   quietly gen double `glscons' = 1                           if `trd'==1
   quietly replace    `glscons' = 1 -`rhobar'                 if `trd'>1
   
   quietly gen double `glstrd' = `trd'                        if `trd'==1
   quietly replace    `glstrd' = `trd' -`rhobar'*L.`trd'      if `trd'>1
      
   quietly gen double `glsy' = `varlist'                      if `trd'==1
   quietly replace    `glsy' = `varlist'-`rhobar'*L.`varlist' if `trd'>1

   quietly regress    `glsy' `glscons' `glstrd' if `touse' , noconstant
   quietly gen double `y' = `varlist' - _b[`glscons'] - _b[`glstrd']*`trd'
    
   quietly gen double `y3' = `y'^3
   
   local treat "detrended"
}

qui gen byte `sspl' = 1 if `touse'
markout `touse' L(1/`firstobs').`sspl' 
tempvar lag pval ks

tempvar aic    min_aic   lag_aic 
tempvar sic    min_sic   lag_sic  
tempvar gts05  max_gts05 lag_gts05 
tempvar gts10  max_gts10 lag_gts10 
tempname res

quietly gen `lag'   = .
quietly gen `aic'   = .
quietly gen `sic'   = .
quietly gen `pval'  = .
quietly gen `ks'    = . 

qui tsset
loc tv `r(timevar)'
local rts `r(tsfmt)'
su `tv' if `touse', mean
loc fp `r(min)'
loc lp `r(max)'
loc minp = string(`fp',"`rts'")
loc maxp = string(`lp',"`rts'")

// Determine the optimal number of lags
// Run the ks regression with no lags (no deterministic components necessary)

quietly regress D.`y'  L1.`y3' if `touse', noconstant
quietly replace `lag'  = 0                                                 in 1
quietly replace `pval' = 0                                                 in 1
quietly replace `aic'  = log(e(rss)/e(N)) + (2*(e(df_m)))/e(N)             in 1
quietly replace `sic'  = log(e(rss)/e(N)) + (log(e(N))*(e(df_m)))/e(N)     in 1
quietly replace `ks'  = _b[L1.`y3']/_se[L1.`y3']                           in 1

// Run the ks regression augmented with lags (no deterministic components necessary)

if `maxlag'>0 {

forvalues i=1/`maxlag' {
   quietly regress D.`y'  L1.`y3' L(1/`i')D.`y' if `touse', noconstant
   local ii = `i' + 1
   quietly replace `lag'  = `i'                                                       in `ii'
   quietly replace `pval' = (2 * ttail(e(df_r), abs(_b[L`i'D.`y']/_se[L`i'D.`y'])))   in `ii'
   quietly replace `aic'  = log(e(rss)/e(N)) + (2*(e(df_m)))/e(N)                     in `ii'
   quietly replace `sic'  = log(e(rss)/e(N)) + (log(e(N))*(e(df_m)))/e(N)             in `ii'
   quietly replace `ks'  = _b[L1.`y3']/_se[L1.`y3']                                   in `ii'
   }
}
    
local store_fix = `maxlag'
  
// Determine the number of lags based on aic and sic

egen `min_aic' = min(`aic')
egen `min_sic' = min(`sic')

quietly gen `lag_aic' = `lag' if `min_aic' == `aic'
quietly gen `lag_sic' = `lag' if `min_sic' == `sic'

su `lag_aic', mean
local store_aic = r(mean)
su `lag_sic', mean
local store_sic = r(mean)

// Determines the number of lags based on gts05 and gts10

quietly gen     `gts05' = .
quietly gen     `gts10' = .
quietly replace `gts05' = .     if `lag' == .
quietly replace `gts10' = .     if `lag' == .
quietly replace `gts05' = `lag' if `pval'<=0.05 
quietly replace `gts10' = `lag' if `pval'<=0.10
quietly replace `gts05' = `lag' if `lag' == 0
quietly replace `gts10' = `lag' if `lag' == 0

egen    `max_gts05' = max(`gts05')
egen    `max_gts10' = max(`gts10')

quietly gen `lag_gts05'  = `max_gts05' if `lag' !=.
quietly gen `lag_gts10'  = `max_gts10' if `lag' !=.

su `lag_gts05', mean
local store_gts05 = r(mean)
su `lag_gts10', mean
local store_gts10 = r(mean)

local ksm1 = `ks'[`store_fix'+1]
local ksm2 = `ks'[`store_aic'+1]
local ksm3 = `ks'[`store_sic'+1]
local ksm4 = `ks'[`store_gts05'+1]
local ksm5 = `ks'[`store_gts10'+1]

// Compute the 1, 5 and 10% critical values along with the associated p-value of the ks statistic.
// For alpha<=0.004 and alpha>=0.996, we use the actual quantile and the 14 observations closest to the
// desired quantile, as there will not be seven observations on either side.

// Response surface coefficients are retrieved from the Stata file "ksur.mtx"

   loc qhl 1 `t1' `t2' `t3' `t4' `p1t' `p2t' `p3t' `p4t'

   loc ksv `ksm1' `ksm2' `ksm3' `ksm4' `ksm5'
 
   mata: ksur1("`qhl'", "`ksv'")
   mat `res' = ___res
   loc lbl fix aic sic gts05 gts10
   loc i = 0
   foreach w of local lbl  {
		loc i = `i' + 1
		mat `res'[`i',1] = `store_`w''
		mat `res'[`i',2] = `ks'[`store_`w''+1]
	}

if "`print'" != "noprint" {

display as result _n "Kapetanios & Shin (2008) test results for `minp' - `maxp'"
display as result "Variable name: `varlist'"
display as result "Ho: Unit root"
display as result "Stationary nonlinear ESTAR model"

if `case'==1 {
   display "GLS demeaned data" // (case 1)"
}
else if `case'==2 {
   display "GLS detrended data" // (case 2)"
}
display as text "{hline 74}"
display "Criteria{col 12}Lags{col 20}KS stat.{col 33}p-value{col 45}1% cv{col 57}5% cv{col 66} 10% cv"
display as text "{hline 74}"
display as result "FIXED{col 13}" `res'[1,1] "{col 18}" %9.3fc `res'[1,2] "{col 31}" %9.3fc `res'[1,3] "{col 42}" %9.3fc `res'[1,4] "{col 54}" %9.3fc `res'[1,5] "{col 65}" %9.3fc `res'[1,6]
display as result "  AIC{col 13}" `res'[2,1] "{col 18}" %9.3fc `res'[2,2] "{col 31}" %9.3fc `res'[2,3] "{col 42}" %9.3fc `res'[2,4] "{col 54}" %9.3fc `res'[2,5] "{col 65}" %9.3fc `res'[2,6]
display as result "  SIC{col 13}" `res'[3,1] "{col 18}" %9.3fc `res'[3,2] "{col 31}" %9.3fc `res'[3,3] "{col 42}" %9.3fc `res'[3,4] "{col 54}" %9.3fc `res'[3,5] "{col 65}" %9.3fc `res'[3,6]
display as result "GTS05{col 13}" `res'[4,1] "{col 18}" %9.3fc `res'[4,2] "{col 31}" %9.3fc `res'[4,3] "{col 42}" %9.3fc `res'[4,4] "{col 54}" %9.3fc `res'[4,5] "{col 65}" %9.3fc `res'[4,6]
display as result "GTS10{col 13}" `res'[5,1] "{col 18}" %9.3fc `res'[5,2] "{col 31}" %9.3fc `res'[5,3] "{col 42}" %9.3fc `res'[5,4] "{col 54}" %9.3fc `res'[5,5] "{col 65}" %9.3fc `res'[5,6]
di as text "{hline 74}"
}

loc lblu = upper("`lbl'")
mat rownames `res' = `lblu'
mat colnames `res' = Lags KS_stat p-value critval01 critval05 critval10
return matrix results = `res'
return scalar maxp = `lp'
return scalar minp = `fp'
return local tsfmt "`rts'"
return local treat "`treat'"
return scalar N = `t'
return local varname = "`varlist'"
restore
end

mata: mata clear
version 13
mata
void ksur1(string scalar consts,
           string scalar ksv)

{
fref = st_global("fileref")
fk = fopen(fref, "r")
ksur = fgetmatrix(fk)
// vl = fget(fk)
// vars = tokens(vl)'
fclose(fk)
alphas = ksur[.,1]
fix_inormal = invnormal(alphas)
kon = strtoreal(tokens(consts))'
ks = strtoreal(tokens(ksv))
trd = st_local("trend")
//  cases 1,2: 5 rows for fix, aic, sic, gts05, gts10
colmtx1 = J(10,2,.)
colmtx1 = (2, 10 \ 56, 64 \ 74, 82 \ 20, 28 \ 38, 46 \
          11, 19 \ 65, 73 \ 83, 91 \ 29, 37 \ 47, 55)
off = (trd != "" ? 5 : 0) 
// result matrix, including 2 additional columns for labels
    res = J(5,6,.)
for(c1=1; c1<=5; c1++) {
	fc = colmtx1[c1+off,1]
	lc = colmtx1[c1+off,2]
	c1_fix_cb = ksur[.,(fc..lc)]
	fix_qhat = c1_fix_cb * kon
	fix_qhat2 = fix_qhat:^2
	fix_dist = abs(fix_qhat :- ks[c1])
	minindex(fix_dist, 1, fix_place, w)
// guard against rounding
//	if (alphas[fix_place] <= 0.004) {
    if (fix_place <= 7) {
		fix_start = 1
		fix_end   = 15
	} 
//	else if (alphas[fix_place] >= 0.996) {
    else if (fix_place >= 215) {
		fix_start = 207
		fix_end   = 221
	}
	else {
		fix_start = fix_place - 7
		fix_end   = fix_place + 7
	}
	y = fix_inormal[fix_start..fix_end]
	iota = J(fix_end - fix_start + 1, 1, 1)
	x = fix_qhat[fix_start..fix_end],fix_qhat2[fix_start..fix_end], iota
	beta = invsym(quadcross(x,x)) * quadcross(x,y)
	kon2 = ks[c1] , ks[c1]^2 , 1
	fix_inormalhat = kon2 * beta
	pv_fix = normal(fix_inormalhat)
	cvfix_01 = fix_qhat[13]
    cvfix_05 = fix_qhat[21]
    cvfix_10 = fix_qhat[31]	
	res[c1,3] = pv_fix
	res[c1,4] = cvfix_01
	res[c1,5] = cvfix_05
	res[c1,6] = cvfix_10
	}
	st_matrix("___res", res)
}
end
