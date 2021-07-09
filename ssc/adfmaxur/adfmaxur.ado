*! adfmaxur v1.0 JOtero 09dec2016
*!          v1.1 CFBaum 24mar2017 Mata logic added
*!          v1.2 CFBaum 25mar2017 reverse logic corrected, onepanel enabled
*!          v1.3 CFBaum 26jan2018 guard against rounding values in alphas
*!          v1.3 CFBaum 02apr2018 fix to guard against very low test statistics for which p-value approximation may not be good
capture program drop adfmaxur
program adfmaxur, rclass 
version 13

syntax varname(ts) [if] [in] [, TREND MAXLag(integer -1) noPRINT]
loc qq qui
preserve
marksample touse
_ts tvar panelvar `if' `in', sort onepanel
markout `touse' `tvar'
 
quietly tsreport if `touse'
if r(N_gaps) {
   display in red "sample may not contain gaps"
   exit
}
global fileref "`c(sysdir_plus)'a/adfmaxur.mtx"

tempvar y yr trd trdr sspl

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

local p1t1 = (`maxlag'/`t')
local p2t2 = (`maxlag'/`t')^2
local p3t3 = (`maxlag'/`t')^3
local p4t4 = (`maxlag'/`t')^4

local firstobs = `maxlag'+1

local case = cond("`trend'" == "", 1, 2)

// cfb add if qualifier
quietly gen double `y' = `varlist' if `touse'
// Generate the reverse realisation of the time series before markout for lags
qui gen double `yr' = .
mata: st_view(y=.,.,"`y'","`touse'"); st_view(yr=.,.,"`yr'","`touse'"); yr[.,.]=y[rows(y)..1,.]

qui gen byte `sspl' = 1 if `touse'
markout `touse' L(1/`firstobs').`sspl' 

tempvar lag pval adff adfr adfmax
tempvar aic    min_aic   lag_aic 
tempvar sic    min_sic   lag_sic  
tempvar gts05  max_gts05 lag_gts05 
tempvar gts10  max_gts10 lag_gts10 
tempname res

quietly gen `lag'    = .
quietly gen `aic'    = .
quietly gen `sic'    = .
quietly gen `pval'   = .
quietly gen `adff'   = . 
quietly gen `adfr'   = . 
quietly gen `adfmax' = . 

qui tsset
loc tv `r(timevar)'
local rts `r(tsfmt)'
su `tv' if `touse', mean
loc fp `r(min)'
loc lp `r(max)'
loc minp = string(`fp',"`rts'")
loc maxp = string(`lp',"`rts'")

// Determine the optimal number of lags
// Run the adfmax regression with no lags
// Store adf forward, reverse and max t-statistics

// Case 1: Model includes constant
if `case'==1 {
	`qq' regress D.`y'  L1.`y' if `touse'
	quietly replace `lag'   = 0                                                 in 1
	quietly replace `pval'  = 0                                                 in 1
	quietly replace `aic'   = log(e(rss)/e(N)) + (2*(e(df_m)))/e(N)             in 1
	quietly replace `sic'   = log(e(rss)/e(N)) + (log(e(N))*(e(df_m)))/e(N)     in 1
	quietly replace `adff'  = _b[L1.`y']/_se[L1.`y']                            in 1

	`qq' regress D.`yr'  L1.`yr' if `touse'
	quietly replace `adfr'   = _b[L1.`yr']/_se[L1.`yr']                         in 1
	quietly replace `adfmax' = max(`adff',`adfr')                               in 1
}

// Case 2: Model includes constant and trend
else if `case'==2 {
	`qq' regress D.`y'  L1.`y' `trd' if `touse'
	quietly replace `lag'   = 0                                                 in 1
	quietly replace `pval'  = 0                                                 in 1
	quietly replace `aic'   = log(e(rss)/e(N)) + (2*(e(df_m)))/e(N)             in 1
	quietly replace `sic'   = log(e(rss)/e(N)) + (log(e(N))*(e(df_m)))/e(N)     in 1
	quietly replace `adff'  = _b[L1.`y']/_se[L1.`y']                            in 1

	`qq' regress D.`yr'  L1.`yr' `trd' if `touse'
	quietly replace `adfr'   = _b[L1.`yr']/_se[L1.`yr']                         in 1
	quietly replace `adfmax' = max(`adff',`adfr')                               in 1
}

// Run the adfmax regression augmented with lags (model includes constant)

if `maxlag'>0 {

forvalues i=1/`maxlag' {
   
   local ii = `i' + 1

   // Case 1: Model includes constant
	if `case'==1 {
		`qq' regress D.`y'  L1.`y' L(1/`i')D.`y' if `touse'
		quietly replace `lag'   = `i'                                                     in `ii'
		quietly replace `pval'  = (2 * ttail(e(df_r), abs(_b[L`i'D.`y']/_se[L`i'D.`y']))) in `ii'
		quietly replace `aic'   = log(e(rss)/e(N)) + (2*(e(df_m)))/e(N)                   in `ii'
		quietly replace `sic'   = log(e(rss)/e(N)) + (log(e(N))*(e(df_m)))/e(N)           in `ii'
		quietly replace `adff'  = _b[L1.`y']/_se[L1.`y']                                  in `ii'

		`qq' regress D.`yr'  L1.`yr' L(1/`i')D.`yr' if `touse'
		quietly replace `adfr'   = _b[L1.`yr']/_se[L1.`yr']                               in `ii'
		quietly replace `adfmax' = max(`adff',`adfr')                                     in `ii'
}
   // Case 2: Model includes constant and trend
	else if `case'==2 {
		`qq' regress D.`y'  L1.`y' L(1/`i')D.`y' `trd' if `touse'
		quietly replace `lag'   = `i'                                                     in `ii'
		quietly replace `pval'  = (2 * ttail(e(df_r), abs(_b[L`i'D.`y']/_se[L`i'D.`y']))) in `ii'
		quietly replace `aic'   = log(e(rss)/e(N)) + (2*(e(df_m)))/e(N)                   in `ii'
		quietly replace `sic'   = log(e(rss)/e(N)) + (log(e(N))*(e(df_m)))/e(N)           in `ii'
		quietly replace `adff'  = _b[L1.`y']/_se[L1.`y']                                  in `ii'

		`qq' regress D.`yr'  L1.`yr' L(1/`i')D.`yr' `trd' if `touse'
		quietly replace `adfr'   = _b[L1.`yr']/_se[L1.`yr']                               in `ii'
		quietly replace `adfmax' = max(`adff',`adfr')                                     in `ii'
}
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

local adfmaxm1 = `adfmax'[`store_fix'+1]
local adfmaxm2 = `adfmax'[`store_aic'+1]
local adfmaxm3 = `adfmax'[`store_sic'+1]
local adfmaxm4 = `adfmax'[`store_gts05'+1]
local adfmaxm5 = `adfmax'[`store_gts10'+1]

// Compute the 1, 5 and 10% critical values along with the associated p-value of the adfmax statistic.
// For alpha<=0.004 and alpha>=0.996, we use the actual quantile and the 14 observations closest to the
// desired quantile, as there will not be seven observations on either side.

// Response surface coefficients are retrieved from the Stata file "adfmaxur.mtx"

   loc qhl 1 `t1' `t2' `t3' `t4' `p1t1' `p2t2' `p3t3' `p4t4'

   loc adfmaxv `adfmaxm1' `adfmaxm2' `adfmaxm3' `adfmaxm4' `adfmaxm5'
 
   mata: adfmaxur1("`qhl'", "`adfmaxv'")
   mat `res' = ___res
   loc lbl fix aic sic gts05 gts10
   loc i = 0
   foreach w of local lbl  {
		loc i = `i' + 1
		mat `res'[`i',1] = `store_`w''
		mat `res'[`i',2] = `adfmax'[`store_`w''+1]
	}

if "`print'" != "noprint" {

display as result _n "Leybourne (1995) test results for `minp' - `maxp'"
display as result "Variable name: `varlist'"
display as result "Ho: Unit root"
display as result "Ha: Stationarity"

if `case'==1 {
   display "Model includes constant" 
   loc treat "constant"
}
else if `case'==2 {
   display "Model includes constant and trend" 
   loc treat "constant and trend"
}
display as text "{hline 74}"
display "Criteria{col 12}Lags{col 20}ADFmax stat.{col 33}p-value{col 45}1% cv{col 57}5% cv{col 66} 10% cv"
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
mat colnames `res' = Lags adfmax_stat p-value critval01 critval05 critval10
return matrix results = `res'
return scalar maxp = `lp'
return scalar minp = `fp'
return local tsfmt "`rts'"
return local treat "`treat'"
return scalar N = `lp' - `fp' + 1
return local varname = "`varlist'"
restore
end

mata: mata clear
version 13
mata
void adfmaxur1(string scalar consts,
            string scalar adfmaxv)
{
fref = st_global("fileref")
fk = fopen(fref, "r")
adfmaxur = fgetmatrix(fk)
// vl = fget(fk)
// vars = tokens(vl)'
fclose(fk)
alphas = adfmaxur[.,1]
fix_inormal = invnormal(alphas)
kon = strtoreal(tokens(consts))'
adfmax = strtoreal(tokens(adfmaxv))
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
	c1_fix_cb = adfmaxur[.,(fc..lc)]
	fix_qhat = c1_fix_cb * kon
	fix_qhat2 = fix_qhat:^2
	fix_dist = abs(fix_qhat :- adfmax[c1])
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
//  fix to guard against very low test statistics for which p-value approximation may not be good
	pv_fix = 0
	if (adfmax[c1] > fix_qhat[1]) {
		y = fix_inormal[fix_start..fix_end]
		iota = J(fix_end - fix_start + 1, 1, 1)
		x = fix_qhat[fix_start..fix_end],fix_qhat2[fix_start..fix_end], iota
		beta = invsym(quadcross(x,x)) * quadcross(x,y)
		kon2 = adfmax[c1] , adfmax[c1]^2 , 1
		fix_inormalhat = kon2 * beta
		pv_fix = normal(fix_inormalhat)
	}
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
