*! radf     v1.6 CFBaum 14oct2020
*! radf     v1.4 CFBaum 10jul2020
*! radf     v1.3 CFBaum 07jul2020
*! radf     v1.2 CFBaum 27jun2020
*! radf     v1.1 CFBaum 01jun2020
*! radf     v1.0 JOtero 04apr2020

capture program drop radf0
mata: mata clear
program radf0, rclass // disable byable(recall)
version 13

syntax varname(ts) [if] [in] , [ PREfix(string) MAXLag(integer -1) ///
                                 CRITerion(string)   ///
								 WINdow(integer -1) ///
								 GRAPH PRINT]

marksample touse
_ts tvar panelvar `if' `in', sort onepanel
markout `touse' `tvar'
quietly tsreport if `touse'
if r(N_gaps) {
   display in red "sample may not contain gaps"
   exit
}
loc tsfmt `r(tsfmt)'

global fradf "`c(sysdir_plus)'r/radf.mtx"
global frsadf "`c(sysdir_plus)'r/rsadf.mtx"
global frgsadf "`c(sysdir_plus)'r/rgsadf.mtx"
global frball_sadf "`c(sysdir_plus)'r/rall_bsadf.mtx"

// validate variables created by the routine
if "`prefix'" != "" {
		confirm name `prefix'
}
loc vvv rolADF SADF BSADF
loc vvvv SADF BSADF
loc ttt 90 95 99
loc newvars
loc newvars2
loc cvv
local cmdline : copy local 0

tempvar en y trd 

// Generate a time trend, which starts in 1, regardless of the start of the sample period
quietly gen `trd' = sum(`touse')
qui count if `touse'
loc ntouse `r(N)'
local enobs  = `trd'[_N]  
// prefix, graph not available if enobs>600
loc nok = `enobs'<=600
if !`nok' {
	di _n "BSADF critical values and graphs not available for `enobs' observations"
	loc prefix
	loc graph
}
   if "`prefix'" != "" {
		foreach v of local vvv {
			confirm new var `prefix'`v'
		}
// also must validate BSADF 95%, indicator for exceedance
		confirm new var `prefix'BSADF_95
		confirm new var `prefix'Exceeding
    }
   loc i 0
   foreach v of local vvv { 
		tempvar `v'
		qui gen ``v'' = .
		loc newvars "`newvars' ``v''"
		loc i = `i' + 1
		if (`i'>1) {
			if "`prefix'" == "" {
				loc newvars2 "`newvars2' ``v''"
// disable graph if no prefix given
				loc graph
			}
		else {
				qui generate  `prefix'`v' = .
				loc newvars2 "`newvars2' `prefix'`v'"
			}
		}
   }
   loc i 0
   foreach t of local ttt {
		tempvar cv`t'
		qui gen `cv`t'' = .
		loc cvv "`cvv' `cv`t''"
		label var `cv`t'' " right-tail CV[`t'%]"
	}
if `maxlag'==-1 {
// use more conservative estimate from Schwert (1989, 2002)
   local maxlag = int(4*(`enobs'/100)^0.25)
//   di as res _n "maxlag = `maxlag'"
}
// remove trend option
local case 1
// local case = cond("`trend'" == "", 1, 2)

* Window size for rolling estimation; see Table 3 in Caspi (2017)
	loc wwidauto = floor(`enobs'*(0.01 + 1.8/sqrt(`enobs')))
if `window'==-1 {
//	loc wauto 1
	loc wwid = `wwidauto'
}
else {
//	loc wauto 0
	loc wwid `window'
}
// ensure sufficient data for lags so that dof>0; reset if window set automatically
if `wwid' <=`maxlag'+ (`case' + 1) {
	di as err _n "Error: `maxlag' too large for window  = `wwid'"
	loc maxlag = `wwid' - `case'
	di as err "Resetting maxlag to `maxlag'"
}
if "`criterion'" == "" | "`criterion'" == "fix" {
   local ncrit = 1 
} 
else if "`criterion'" == "aic" {
   local ncrit = 2 
}
else if "`criterion'" == "sic" {
   local ncrit = 3 
} 
else if "`criterion'" == "gts05" {
   local ncrit = 4 
}
else if "`criterion'" == "gts10" {
   local ncrit = 5 
} 
else {
	di "Error in specifying criterion: `criterion'"
	error 198
}
//  need to be able to define lags; do not apply touse
qui gen double `y' = `varlist' 
g `en' = _n
// do not reference the tsset var, but rather the trend
// must also deal with sum(touse) when it returns to 0
su `en' if `trd'>0 & !mi(`trd') & `touse', mean
// ensure sufficient observations to handle max lag order + differencing at begnning of sample
loc first = max(`r(min)',`maxlag'+2) 
loc LAST = `r(max)'
// di as err "*** `lastobs' `LAST'"
// l `tvar' `en' `touse' `varlist', noobs sep(0)
// add one to pick up last possible window
loc last = `LAST' - `wwid' + 1
// ensure sufficient observations 
if `first' > `last' {
	di as err _n "Insufficient observations for rolling analysis"
	error 198
}
loc crits FIX AIC SIC GTS05 GTS10
loc rets  fix aic sic gts05 gts10
loc crit : word `ncrit' of `crits'
loc retl : word `ncrit' of `rets'

// l `en' `tvar' `y' in `first'/`LAST', sep(0) noobs
//  di as err _n " first last  l-f+1   LAST   L-f+1  maxlag   criterion   wwid"
//  di as err "  `first' |  `last'  | `=`last'-`first'+1'  |  `LAST'  |  `=`LAST'-`first'+1' |    `maxlag'   |     `criteria'    |  `wwid'"

tempvar  dy ly
qui g `dy' = D.`y' if `touse'
qui g `ly' = L.`y' if `touse'
// di as err "dy, ly"
// l `dy' `ly' if `touse'
loc lagv
forv i=1/`maxlag' {
		tempvar ly`i'
		qui g `ly`i'' = DL`i'.`y'
		loc lagv "`lagv' `ly`i''"
}
// pass in entire series, ignoring touse
mata: lagadf(`first',`last',`wwid',`LAST',`case',`ncrit',`maxlag',"`touse'","`ly'","`dy'","`lagv'")
mata: psy(`enobs',`first',`last',`wwid',`LAST',`case',"`touse'","`ly'","`dy'","`lagv'","`newvars'")
loc tee = `LAST' - `first' + 1

di as res _n "Right-tail ADF statistics for `varlist' with first observations " `tsfmt' `tvar'[`first'] " - " `tsfmt' `tvar'[`last']  
di as res _n "Number of obs = `tee'  lag selection[`crit']  maxlag = `maxlag'  window = `wwid' periods"

di as res _n "ADF " _col(18) "= "  %8.4f __adfstat " `adf_s' Right-tail CVs:  90% "               %8.4f __adfcv[1,2]   " 95% "  %8.3f __adfcv[1,3]   "  99% "   %8.4f __adfcv[1,4]

di as res _n "SADF (PWY,2011) " _col(18)  "= " %8.4f __pwystat " `sadf_s' Right-tail CVs:  90% "  %8.4f __sadfcv[1,2]  " 95% "  %8.4f __sadfcv[1,3]  "  99% "   %8.4f __sadfcv[1,4]

di as res _n "GSADF (PSY,2015) " _col(18) "= " %8.4f __psystat " `gsadf_s' Right-tail CVs:  90% " %8.4f __gsadfcv[1,2] " 95% "  %8.4f __gsadfcv[1,3] "  99% "   %8.4f __gsadfcv[1,4]
if (`wwid' != `wwidauto') {
	loc winwarn "Note: critical values based on auto window width = `wwidauto', not specified width = `wwid'"
	di as res _n "`winwarn'"
	}
di _n	
/*
// base on supadf not missing
loc v1: word 2 of `newvars'
su `tvar' if !mi(`v1'), mean
loc fc0 = `r(min)' 
loc lc0 = `r(max)'
loc fd = `r(min)' - (`wwid' - 1)
loc ld = `r(max)' - (`wwid' - 1)
loc rstripe 
loc cstripe
forv j=`fd'/`ld' {
	loc lbl = string(`j',"`tsfmt'")
	loc rstripe "`rstripe' `lbl'"
}
forv j=`fc0'/`lc0' {
	loc lbl = string(`j',"`tsfmt'")
	loc cstripe "`cstripe' `lbl'"
}
su `en' if !mi(`v1'), mean
loc fr = `r(min)'  - (`wwid' - 1)
loc lr = `r(max)'  - (`wwid' - 1)
loc fc = `r(min)' 
loc lc = `r(max)'

matlist __results

tempname res2 opt2 nobs2
mat `res2' = __results[`fr'..`lr', `fc'..`lc']
mat rownames `res2' = `rstripe'
mat colnames `res2' = `cstripe'
mata: st_matrix("__optlag",optlag)
mat `opt2' = __optlag[`fr'..`lr', `fc'..`lc']
mat rownames `opt2' = `rstripe'
mat colnames `opt2' = `cstripe'
mat `nobs2' =  __nobs[`fr'..`lr', `fc'..`lc']
mat rownames `nobs2' = `rstripe'
mat colnames `nobs2' = `cstripe'

if (`nok') {
if "`prefix'" != "" {	
	mata: pwy(`tee',"`cvv'")
	loc frow = __to1
	loc lrow = __to2
//	if ("`print'" == "print") {
//		di _n "gensupADF CVs for 10, 5, 1"
//		l `cvv' in `frow'/`lrow', noobs sep(0)
//	}
	foreach v of local vvvv {
		qui replace `prefix'`v' = ``v''
	}
// add 5% CV for gensupadf to created variables
	qui g `prefix'BSADF_95 = `cv95' if !mi(`cv95')
	qui g `prefix'Exceeding = (`prefix'BSADF > `cv95') if !mi(`cv95')
	di as res _n "Labeled by endpoint of estimation window"
	l `tvar' `newvars2' `prefix'BSADF_95 `prefix'Exceeding in `fc'/`lc', sep(0) noobs abb(20)
}
if ("`print'" == "print") {
	matlist `res2', tit("Estimation window from rowdate to coldate, crit[`crit']")
	if (`ncrit'>1) {
		matlist `opt2', tit("Optimal lags, crit[`crit']") nohalf
	}
	else {
		di as res _n  "Computed with crit[FIX], `maxlag' lags"
	}
	matlist `nobs2', tit("Number of observations in test")
}
}
if (`nok') {
if "`graph'" != "" {
	lab var `tvar' " "
	loc i 0
	di _n
	foreach v of local newvars2 {
		loc i=`i'+1
		loc vn: word `i' of `newvars2'
		lab var `v' "`vn'"
		loc adfv
		loc note 
		if (`i' == 1) {
	// CVs for sadf, bsadf
		tempvar adf90 adf95 adf99
		loc j 1
		foreach l in 90 95 { // 1  {
			loc j = `j' + 1
			g `adf`l'' = __adfcv[1,`j']
			label var `adf`l'' " right-tail CV[`l'%]"
			loc adfv "`adfv' `adf`l''"
		}
		loc vti "Date-stamping explosive behavior of `varlist', SADF test"
		}
		else {
			loc adfv `cv90' `cv95'
			if (`wwid' != `wwidauto') {
				loc note "note("`winwarn'",size(vsmall))"
			}
		loc vti "Date-stamping explosive behavior of `varlist', BSADF test"
		}
		tsline `v' `adfv' if !mi(`v'), ylab(,angle(0) labs(small)) scheme(s2mono) graphregion(color(white)) ti("`vti'", size(medium)) ///
		 xlab(#6, labs(small)) legend(row(1) size(small) symxsize(medium) region(lcolor(white))) saving(`v', replace) ///
		 name(`v',replace) `note'
	}
}
}
*/
/*
mat rownames radfstats = ADF SADF GSADF
mat colnames radfstats = stat cv90 cv95 cv99
return local cmd = "radf"
return local cmdlne = "`cmdline'"
return local varname = "`varlist'"
return local first "`first'"
return local last "`last'"
return scalar nobs = `enobs'
return scalar N = `tee'
return scalar maxlag = `maxlag'
return scalar window = `wwid'
return local crit = "`criterion'" 
*/
return scalar adfstat = __adfstat
return scalar sadfstat = __pwystat
return scalar gsadfstat = __psystat
// DISABLE return matrix radfstats = radfstats
// return scalar ntests = __tests

end
// -----------------------------------------------------------------------------
version 13
mata:
mata set matastrict on
void  lagadf(real scalar  first,    ///
             real scalar  last,     ///
		     real scalar  wwid,     ///
		     real scalar  LAST,     ///
		     real scalar  kase,     ///
			 real scalar  krit,     ///
		     real scalar  maxlag,   ///
		     string scalar touse,   ///
		     string scalar lyy,     ///
		     string scalar dyy,     ///
		     string scalar lagvv)
				  
{
	external real matrix optlag
	
	st_view(ly=., ., tokens(lyy)) // touse)
	st_view(dy=., ., tokens(dyy)) // touse)
	st_view(lagd=., ., tokens(lagvv)) // touse)

// krit=1, just calc ADF for maxlag
	if (krit == 1) {
		optlag = J(LAST, LAST, maxlag)
		return
	}
// -----------------------------------------------------------------------------
// krit > 1	
		iota = J(LAST,1,1)
		trd = J(LAST,1,.)
// kase 2: include trd *DISABLE*
/*
		if (kase==2) {
			for(t=1;t<=LAST;t++){
				trd[t]=t
			}
			iota = iota, trd
		}
*/
		// reverse results matrix to contain subscripts for start, end of estimation window
		optlag = J(LAST, LAST, .)
// -----------------------------------------------------------------------------
// krit=2 (aic), estimate each and keep track of min value
	if (krit==2) {

	for(t=first;t<=last;t++) {
		wo = t + wwid - 1
		for(tt=wo;tt<=LAST;tt++) {
			minval = 1e10
			minlag = -1
// loop over lags for each combination of start/end
// calc standard DF, 0 lags
			X = (ly[t..tt],iota[t..tt,.])
			wye = dy[t..tt]
			xxinv = invsym(X'*X)
			beta = xxinv*(X'*wye)
			s = sqrt(((wye - X*beta)'*(wye - X*beta))/(rows(wye)-cols(X)))
			dful = beta[1]/(s * sqrt(xxinv[1,1]))
			if (dful<.) {
			rss = (wye - X*beta)'*(wye - X*beta)
			aic = log(rss/rows(wye)) + 2*(cols(X)-1)/rows(wye)
				if (aic < minval) {
					minval = aic
					minlag = 0
				}
			}
		for(i=1;i<=maxlag;i++) {
			X = (ly[t..tt],lagd[t..tt,1..i],iota[t..tt,.])
			xxinv = invsym(X'*X)
			beta = xxinv*(X'*wye)
			s = sqrt(((wye - X*beta)'*(wye - X*beta))/(rows(wye)-cols(X)))
			dful = beta[1]/(s * sqrt(xxinv[1,1]))
			if (dful<.) {
// aic = log(e(rss)/e(N)) + (2*(e(df_m)))/e(N)
// rss: resid sum sq 
// n: rows(wye)
// df_m: cols(X)-1
			rss = (wye - X*beta)'*(wye - X*beta)
			aic = log(rss/rows(wye)) + 2*(cols(X)-1)/rows(wye)
				if (aic < minval) {
					minval = aic
					minlag = i
				}
			}
// printf("t, tt %4.0f %4.0f lag = %4.0g dful= %10.3g aic = %10.5g minval, minlag = %10.5g %5.0f\n", t,tt, i, dful, aic, minval, minlag)
//		end loop over lags
			}
//      store optimal lag in results matrix			
			optlag[t,tt] = minlag
//	end loop over start/end			
			}
			}
// end for krit=2 (aic) 
		}
// -----------------------------------------------------------------------------		
// krit=3 (sic), estimate each and keep track of min value
	if (krit==3) {

	for(t=first;t<=last;t++) {
		wo = t + wwid - 1
		for(tt=wo;tt<=LAST;tt++) {
			minval = 1e10
			minlag = -1
// loop over lags for each combination of start/end
// add standard DF, 0 lags, unless crit==1
			X = (ly[t..tt],iota[t..tt,.])
			wye = dy[t..tt]
			xxinv = invsym(X'*X)
			beta = xxinv*(X'*wye)
			s = sqrt(((wye - X*beta)'*(wye - X*beta))/(rows(wye)-cols(X)))
			dful = beta[1]/(s * sqrt(xxinv[1,1]))
			if (dful<.) {
			rss = (wye - X*beta)'*(wye - X*beta)
			sic = log(rss/rows(wye)) + log(rows(wye))*(cols(X)-1)/rows(wye)
			if (sic < minval) {
				minval = sic
				minlag = 0
				}
			}
		for(i=1;i<=maxlag;i++) {
			X = (ly[t..tt],lagd[t..tt,1..i],iota[t..tt,.])
			xxinv = invsym(X'*X)
			beta = xxinv*(X'*wye)
			s = sqrt(((wye - X*beta)'*(wye - X*beta))/(rows(wye)-cols(X)))
			dful = beta[1]/(s * sqrt(xxinv[1,1]))
			if (dful<.) {
// sic = log(e(rss)/e(N)) + (log(e(N))*(e(df_m)))/e(N)
// rss: resid sum sq 
// n: rows(wye)
// df_m: cols(X)-1
			rss = (wye - X*beta)'*(wye - X*beta)
			sic = log(rss/rows(wye)) + log(rows(wye))*(cols(X)-1)/rows(wye)
			if (sic < minval) {
				minval = sic
				minlag = i
		//		printf("lag = %4.0g sic = %10.5g minval, minlag = %10.5g %5.0f\n", i, sic, minval, minlag)
			}
			}
//		end loop over lags
			}
//      store optimal lag in results matrix			
			optlag[t,tt] = minlag
//	end loop over start/end			
			}
			}
// end for krit=3 (sic)
		}
// -----------------------------------------------------------------------------		
// krit=4 (gts05), krit=5 (gts10): estimate each and keep track of max lag surpassing threshold

	if (krit==4 | krit==5) {
	crit05 = 0.05
	crit10 = 0.10
// "maxlag, wwid, first, last, LAST"
// maxlag, wwid, first, last, LAST
	for(t=first;t<=last;t++) {
		wo = t + wwid - 1
		for(tt=wo;tt<=LAST;tt++) {
		
			maxlag4 = 0
			maxlag5 = 0
// loop over lags for each combination of start/end
// add standard DF, 0 lags, unless crit==1
			X = (ly[t..tt],iota[t..tt,.])
			wye = dy[t..tt]
			xxinv = invsym(X'*X)
			beta = xxinv*(X'*wye)
			s = sqrt(((wye - X*beta)'*(wye - X*beta))/(rows(wye)-cols(X)))
			dful = beta[1]/(s * sqrt(xxinv[1,1]))
			if (dful<.) {
				pval = 2 * ttail((rows(wye)-cols(X)),abs(dful))
				if (pval < crit05) maxlag4 = 0
				if (pval < crit10) maxlag5 = 0
				}
		for(i=1;i<=maxlag;i++) {
			X = (ly[t..tt],lagd[t..tt,1..i],iota[t..tt,.])
			xxinv = invsym(X'*X)
			beta = xxinv*(X'*wye)
			s = sqrt(((wye - X*beta)'*(wye - X*beta))/(rows(wye)-cols(X)))
			dful = beta[1]/(s * sqrt(xxinv[1,1]))
			if (dful<.) {
				pval = 2 * ttail((rows(wye)-cols(X)),abs(dful))
				if (pval < crit05) maxlag4 = i
				if (pval < crit10) maxlag5 = i
				}
// 			end loop over lags
			}
// t,tt, maxlag4, maxlag5
//      store optimal lag in results matrix	
			if (krit==4) optlag[t,tt] = maxlag4
			if (krit==5) optlag[t,tt] = maxlag5
//		end loop over tt
			}
//	end loop over start/end			
		}
// end for krit=4,5			
	}

// end function
}

// -----------------------------------------------------------------------------
void  psy(real scalar  enobs,    ///
          real scalar  first,    ///
          real scalar  last,     ///
		  real scalar  wwid,     ///
		  real scalar  LAST,     ///
		  real scalar  kase,     ///
		  string scalar touse,   ///
		  string scalar lyy,     ///
		  string scalar dyy,     ///
		  string scalar lagvv,   ///
		  string scalar newvars) 
				  
{
	external real matrix optlag
	external real scalar adfstat, pwystat, psystat
	real rowvector adf, sadf, gsadf
	string scalar etoile
	real matrix sumstats

	st_view(ly=., ., tokens(lyy)) 
	st_view(dy=., ., tokens(dyy)) 
	st_view(lagd=., ., tokens(lagvv))
	st_view(rolsupgen=., ., tokens(newvars)) 

	iota = J(LAST,1,1)
//produce trd over full range
	trd = J(rows(ly),1,.)
	for(t=1;t<=rows(ly);t++){
		trd[t]=t
	}
	rolladf = J(LAST,1,.)
	// case 2: include trd *DISABLE*
//	if(kase==2) iota = iota, trd
	ntim=0
//	sumstats matrix contains the three stats and their CVS
	sumstats = J(3,4,.)
//  results matrix contains subscripts for start, end of estimation window
	results = J(LAST, LAST, .)
//  nobs matrix records number of observations in each estimation
	nobs = J(LAST, LAST, .)
// mark first defined row of results 
	fr=0
	for(t=first;t<=last;t++) {
		wo = t + wwid - 1
		for(tt=wo;tt<=LAST;tt++) {
			lord = optlag[t,tt]
// dfuller `yy' in `t'/`tt', lags(`r(lag_`retl')') `trend'
// 		qui regress D.`y'  L1.`y' L(1/`i')D.`y' `tt' if `touse'
// adjust for zero lags as optimal
			if (lord>0){
				X = (ly[t..tt],lagd[t..tt,1..lord],iota[t..tt,.])
			}
			else {
				X = (ly[t..tt],iota[t..tt,.])
			}
			wye = dy[t..tt]
			xxinv = invsym(X'*X)
			beta = xxinv*(X'*wye)
			s = sqrt(((wye - X*beta)'*(wye - X*beta))/(rows(wye)-cols(X)))
			dful = beta[1]/(s * sqrt(xxinv[1,1]))
// grab first test results for each t, label as element t for roladf
			if(tt==wo) rolladf[t] = dful
			results[t,tt] = dful
			nobs[t,tt] = rows(wye) 
			if (dful<.) {
				if (fr==0) {
					fr=t
				}
				ntim++
			}
 /*			
			t, tt, results[t,tt]
			"--"
			rows(wye)
			wye,X
			beta
			eps
			"dof"
			dof=(rows(wye)-cols(X)-1)
			dof
			s
			dful
 
	if(t==first & tt==LAST) {
		lord, t, tt, dful
		wye, X
	}
*/
		}
	}	
// access adf CVs
	fref = st_global("fradf")
	fk = fopen(fref, "r")
	adfcv = fgetmatrix(fk)
	fclose(fk)
// access sadf CVs
	fref = st_global("frsadf")
	fk = fopen(fref, "r")
	sadfcv = fgetmatrix(fk)
	fclose(fk)
// access gsadf CVs
	fref = st_global("frgsadf")
	fk = fopen(fref, "r")
	gsadfcv = fgetmatrix(fk)
	fclose(fk)
// base on full sample entering touse
	adf = cvret(adfcv, enobs)
	sadf = cvret(sadfcv, enobs)
	gsadf = cvret(gsadfcv, enobs)
	st_matrix("__adfcv",adf)
	st_matrix("__sadfcv",sadf)
	st_matrix("__gsadfcv",gsadf)
//	st_numscalar("__tests",ntim)
//	st_matrix("__results", results)
//	st_matrix("__nobs", nobs)
	adfstat = results[fr,LAST]
	st_numscalar("__adfstat",adfstat)
/*
	etoile="   "
	if (adfstat > adf[2]) etoile="*  "
	if (adfstat > adf[3]) etoile="** "
	if (adfstat > adf[4]) etoile="***"
	st_local("adf_s",etoile)
*/
	sumstats[1,1] = adfstat
	sumstats[1,2..4] = adf[2..4]
//  maximum of rolladf
	rollstat = colmax(rolladf)
	st_numscalar("__rollstat",rollstat)
// identify range of non-missing values in roladf
	e=colminmax(mm_which((rolladf:<.):*trd[1..rows(rolladf)]))
	fr1 = e[1,1]
	fr2 = e[2,1]
// identify range of non-missing values in supadf
	f=colminmax(mm_which((results[fr,.]':<.):*trd[1..LAST]))
	to1 = f[1,1]
	to2 = f[2,1]
//	frow = results[fr,.]'
// load supadf with transposed first row of results
	rolsupgen[1..to2,2] = results[fr,.]'
// adjust first column to align with 2d, 3d
	rolsupgen[to1..to2,1] = rolladf[fr1..fr2,1]
	pwystat = rowmax(results[fr,.])
	st_numscalar("__pwystat",pwystat)
/*
	etoile="   "
	if (pwystat > sadf[2]) etoile="*  "
	if (pwystat > sadf[3]) etoile="** "
	if (pwystat > sadf[4]) etoile="***"
	st_local("sadf_s",etoile)
*/
	sumstats[2,1] = pwystat
	sumstats[2,2..4] = sadf[2..4]
// reverse subscripts
	psyadf = colmax(results)'
// load genadf with psyadf vector 
	rolsupgen[1..to2,3] = psyadf
	psystat = colmax(psyadf)
	st_numscalar("__psystat",psystat)
/*
	etoile="   "
	if (psystat > gsadf[2]) etoile="*  "
	if (psystat > gsadf[3]) etoile="** "
	if (psystat > gsadf[4]) etoile="***"
	st_local("gsadf_s",etoile)
*/
	sumstats[3,1] = psystat
	sumstats[3,2..4] = gsadf[2..4]
	st_matrix("radfstats",sumstats)
// pass limits for use in pwy
	st_numscalar("__to1",to1)
	st_numscalar("__to2",to2)
}
// -----------------------------------------------------------------------------
real rowvector cvret(real matrix cvmat, ///
					 real scalar enobs)
{
	real scalar lrow, frac
	real rowvector cvl, cvh, cvnt
	if (enobs <= 600) {
		lrow = enobs - 5
		return(cvmat[lrow,.])
	}
// row 595: 600
// row 609: 2000
	if (enobs >= 2000) {
		return(cvmat[609,.])
	}
// T >600, <2000
	nh = floor(enobs/100) + 589
	frac = mod(enobs,100)/100
	cvl = cvmat[nh,.]
	cvh = cvmat[nh+1,.]
	cvnt = cvl + frac :* (cvh - cvl) 
	return(cvnt)
}	
// -----------------------------------------------------------------------------
void  pwy(real   scalar  tee,   ///
          string scalar  cvv)    
{	
	st_view(cvvars=., ., tokens(cvv)) 
	
	// access gensupADF CVs from bsadf
	fref = st_global("frball_sadf")
	fk = fopen(fref, "r")
	bscv = fgetmatrix(fk)
	fclose(fk)
	// locate rows with tee in col 5
	chunk = select(bscv, bscv[.,5]:==tee)[.,2..4]
	nr = rows(chunk)
	to1 = st_numscalar("__to1")
	to2 = st_numscalar("__to2")
	need = to2 - to1 + 1
	fr = to1 + (need-nr)
	cvvars[fr..to2,.] = chunk
}
// -----------------------------------------------------------------------------
end

