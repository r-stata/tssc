* version 2.0
* Maximo Sangiacomo 
* 201405
* Pesaran, Ullah and Yamagata (2008). "A bias-adjusted LM test of error cross-section independence."
* Econometrics Journal, volume 11, pp. 105–127.
program define xtcsi, rclass
version 9
syntax varlist [if] [in] , [ trend ]  

qui tsset
local id `r(panelvar)'
global time `r(timevar)'
tempfile _db_userfile b_resid
tempvar _id_aux _trend01 _const01 _resid01
qui egen `_id_aux' = group(`id')
qui gen `_const01' = 1
global id_aux `_id_aux'
global const01 `_const01'
qui save "`_db_userfile'"
local k : word count `varlist'
if "`trend'"!="" {
	local ++k
	qui bys `id': gen `_trend01' = _n
	global trend01 `_trend01'
}
marksample touse
markout `touse' $time
qui xtsum $time if `touse'
local N `r(n)'
local T `r(Tbar)'
if int(`T')*`N' ~= r(N) {
	di in red "panel must be balanced"
	error 198
}
if int(`T') <=  `k' + 8 {
	di in red "T must be > " `k' + 8
	error 198
}
qui xtmg `varlist' if `touse', `trend' res(`_resid01')
global resid01 `_resid01'
qui keep if e(sample)
qui save "`b_resid'"
qui sum $id_aux 
local N = r(max)
local N1 = `N'-1
qui {
	scalar pwc1 = 0
	scalar pwc2 = 0
	scalar pwc3 = 0
	scalar nidcorr = 0
}
foreach i of numlist 1/`N1' {
	local j = `i'+1
	foreach num of numlist `j'/`N' {
		use "`b_resid'"
		lmadjm `varlist', i(`i') num(`num') `trend'
		scalar tr_`i'`num' = scalar(tr)
		scalar tr_sq_`i'`num' = scalar(tr_sq)
		keep $id_aux $time $resid01 
		qui keep if ($id_aux==`i'|$id_aux==`num')
		qui reshape wide $resid01, i($time) j($id_aux)
		qui sum $resid01`i'
			if r(N) > `k' + 8 {
				if `i'==1 {
					scalar nidcorr = nidcorr + 1
				}
				qui matpwcorr $resid01`i' $resid01`num'
				scalar c_`i'`num' = corr[2,1]
				scalar csq_`i'`num' = scalar(c_`i'`num')^2
				scalar pv_`i'`num' = pv[2,1]

				qui correlate $resid01`i' $resid01`num'
				scalar n_`i'`num' = r(N)

				scalar a2t_`i'`num' =3*((((scalar(n_`i'`num')-`k'-8)*(scalar(n_`i'`num')-`k'+2)+24)/((scalar(n_`i'`num')-`k'+2)*(scalar(n_`i'`num')-`k'-2)*(scalar(n_`i'`num')-`k'-4)))^2)
				scalar a1t_`i'`num' = scalar(a2t_`i'`num')-(1/((scalar(n_`i'`num')-`k')^2))
				scalar vt_`i'`num'_sq = ((scalar(tr_`i'`num')^2)*scalar(a1t_`i'`num')+2*scalar(tr_sq_`i'`num'))*scalar(a2t_`i'`num')
				scalar vt_`i'`num' = scalar(vt_`i'`num'_sq)^(1/2)
				scalar ut_`i'`num' = (scalar(tr_`i'`num'))/(scalar(n_`i'`num')-`k')
				scalar csq_`i'`num'_210 = (((n_`i'`num'-`k')*csq_`i'`num')-scalar(ut_`i'`num'))/scalar(vt_`i'`num')
				scalar pwc1 = pwc1 + scalar(csq_`i'`num')
				scalar pwc2 = pwc2 + scalar(csq_`i'`num'_210)
				scalar pwc3 = pwc3 + scalar(c_`i'`num')


			}
			scalar pwc_lm = scalar(n_12)*pwc1
			scalar pwc_adj = ((2/((scalar(nidcorr)+1)*scalar(nidcorr)))^(1/2))*pwc2
			scalar pwc_cd = (((2*scalar(n_12))/((scalar(nidcorr)+1)*scalar(nidcorr)))^(1/2))*pwc3
	}
}

scalar p_lm_cd = 2*(1-normal(abs(scalar(pwc_cd))))
scalar p_lm_adj = 2*(1-normal(abs(scalar(pwc_adj))))
scalar p_lm = chi2tail(((scalar(nidcorr)+1)*scalar(nidcorr))/2,abs(scalar(pwc_lm)))

di in gr _n "Bias-adjusted LM test of error cross-section independence"
di in gr _n "{bf:H0:} Cov(uit,ujt) = 0 for all t and i!=j"

	di in smcl in gr "{hline 11}{c TT}{hline 30}"
	di in smcl in gr _col(5) "Test" _col(12) "{c |}" /*
	*/ _col(16) "Statistic" _col(30) "p-value" 
	di in smcl in gr "{hline 11}{c +}{hline 30}"
	di in smcl in gr "LM" _col(12) "{c |}" in ye /*
			*/ _col(16) %6.4g scalar(pwc_lm) /* 
			*/ _col(29) %8.4f scalar(p_lm)  
	di in smcl in gr "LM adj*" _col(12) "{c |}" in ye /*
			*/ _col(16) %6.4g scalar(pwc_adj) /* 
			*/ _col(29) %8.4f scalar(p_lm_adj)  
	di in smcl in gr "LM CD*" _col(12) "{c |}" in ye /*
			*/ _col(16) %6.4g scalar(pwc_cd) /* 
			*/ _col(29) %8.4f scalar(p_lm_cd) 
	di in smcl in gr "{hline 11}{c BT}{hline 30}"
	di in smcl in gr "*two-sided test"
	

*Results
return scalar p_lm_cd = scalar(p_lm_cd)
return scalar lm_cd = scalar(pwc_cd)
return scalar p_lm_adj = scalar(p_lm_adj)
return scalar lm_adj = scalar(pwc_adj)
return scalar p_lm = scalar(p_lm)
return scalar lm = scalar(pwc_lm)
return scalar N_g = scalar(nidcorr)+1

use "`_db_userfile'"
end

program define lmadjm, rclass
version 10
syntax varlist [if] [in], i(real) num(real) [ trend ]
gettoken v0 v1: varlist
if "`trend'"!="" {
	local v11 "$const01`v1' $trend01"
}
else {
	local v11 "$const01`v1'"
}
preserve
qui keep if ($id_aux==`i'|$id_aux==`num')
qui tsset $id_aux $time
qui sum $const
local n1 = r(N)/2
local n2 =`n1'+1
local nmax = r(N)
mata: st_view(X1=.,(1::`n1'),("`v11'"))
mata: st_view(X2=.,(`n2'::`nmax'),("`v11'"))
mata: H1 = X1*qrinv(X1'X1)*X1'
mata: H2 = X2*qrinv(X2'X2)*X2'
mata: I=I(`n1')
mata: M1=I-H1
mata: M2=I-H2
mata: st_numscalar("tr", trace(M1*M2))
mata: st_numscalar("tr_sq", trace((M1*M2)*(M1*M2)))
return scalar tr_12  = scalar(tr)
return scalar tr_sq_12  = scalar(tr_sq)
restore
end
