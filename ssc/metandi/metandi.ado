*! version 2.0 April 15, 2008 @ 21:11:42
*! Author: Roger Harbord, University of Bristol

	/* bivariate meta-analysis of diagnostic accuracy
		- wrapper for gllamm binomial-binormal model

		Changes since v0.4 :
		1.00 uses -xtmelogit- in Stata10 instead of -gllamm-
		     & ereturns estimates for bivariate & hsroc
		0.45 fixed plot option bug (if `touse' -> `if' `in' )
		0.44: changed "Summary point" to "... pt." so "Copy Table" works better.
		0.43: fixed "dataset has changed since last saved" after -metandi-,
		changed -error nnn- to -exit nnn- where appropriate.
		0.42: fixed -by- bug
		(-by: metandi ...- fitted model repeatedly to all data)
*/

program define metandi, byable(onecall) sortpreserve
version 8.2

	if _by() {
		local BY `"by `_byvars'`_byrc0':"'
		}

	local version: di "version " string(_caller()) ":"
	
	if replay() {
		if "`e(cmd)'" != "metandi"  ///
		  error 301        // last estimates not found
		if _by() error 190 // request may not be combined with by
		Display `0'
		exit
		}
	
   `version' `BY' Estimate `0'
end
	
	
program define Estimate, eclass byable(recall)
version 8.2
	syntax varlist(min=4 max=4) [if] [in] ///
	  [, Plot IP(string) NIp(int -1)  ///
	  Detail Level(real `c(level)') ///
	  TRace noLOg  Gllamm ///
	  noBivariate noHsroc noSummarypt ///
	  /* undocumented: */ NIPUni(int 9) clear  allc ]

	marksample touse
	tokenize `varlist'
	local true1  `1'
	local false0 `2'
	local false1 `3'
	local true0  `4'

	/* xtmelogit or gllamm ? */
	capture which xtmelogit
	if _rc != 0 {
		local gllamm gllamm
		}

	if "`gllamm'" != "" {
		capture which gllamm
		if _rc != 0 {
			di as error "command gllamm not found"
			di as error "Try -ssc install gllamm-"
			exit 111
			}
		if "`detail'" == "" {
			local nodis nodisplay
			local unilog nolog
			}
		}



	/** Parse ip() and nip() **/
	if ~inlist("`ip'","", "g", "m") {
		di as error "ip option can only be ip(g) or ip(m)"
		exit 198
		}
	if "`ip'" == "m" {
		if "`gllamm'" == "" {
			di as error  ///
			  "ip(m) has no effect unless option gllamm is specified"
			exit 198
			}
		if `nip' == -1 local nip 9
		/* exit early if ip(m) with unimplemented nip() */
		else if  !inlist(`nip', 5, 7, 9, 11, 15) {
			di as error "nip must be 5, 7, 9, 11 or 15 with ip(m)"
			//  - else fitting bivariate model in gllamm will give this error
			exit 198
			}
		}
	else if `nip' == -1 local nip 5
	
	/* this sidesteps oversight in gllamm version < 2.3.13 (11 nov 2006)
	where explicitly specifying ip(g) gave an error message */
	if "`ip'" == "g" {
		local ip // 
		}

	/* allc implies display */
	if "`allc'" != "" local nodis

	qui count if `touse'
	if r(N) < 4 {
		di as error "metandi requires a minimum of four studies"
		exit 2001 // insufficient observations
		}

	/** end parsing ***/


	if "`clear'" =="" preserve
	/** reshape data to long format suitable for gllamm **/
	qui {
		gen long _metandi_i = _n
		gen long _metandi_n1 = `true1' +`false1' if `touse'
		gen long _metandi_n0 = `true0' + `false0' if `touse'
		gen long _metandi_true1 = `true1' 
		gen long _metandi_true0 = `true0'

		/* d1 is diseased (sensitivity) d0 is nondiseased (specificity) */
		reshape long _metandi_n _metandi_true, i(_metandi_i) j(_metandi_d1)
		sort _metandi_i _metandi_d1
		gen byte _metandi_d0 = 1 - _metandi_d1 
		} // end quietly
	
	if "`gllamm'" != "" {


		eq eq1: _metandi_d1
		eq eq0: _metandi_d0
		
		/*** run univariate models to get good starting values ***/
		foreach g of numlist 1 0 {
			if `g'==1 local ss Sensitivity, Se
			else      local ss Specificity, Sp
			/* use Sum(true)/Sum(n) as starting value for summary proportion */
			summ _metandi_true if _metandi_d`g' & `touse', meanonly
			local sumtrue = r(sum)
			summ _metandi_n if _metandi_d`g' & `touse', meanonly
			matrix b0uni = ( logit( `sumtrue' / r(sum) ), 0.5 )
		
			if "`log'" == "" {
				di as txt _n "Fitting univariate model for " _c
				di as txt "`ss' = " as res "`true`g''" as txt" / ("  ///
				  as res "`true`g''" as txt" + " as res "`false`g''" as txt ")"
				}

			gllamm _metandi_true _metandi_d`g' if _metandi_d`g' & `touse', ///
			  nocons i(_metandi_i) nrf(1) eqs(eq`g') ///
			  family(binomial) denom(_metandi_n) link(logit) from(b0uni) copy ///
			  `nodis' `unilog' `allc' `trace' `dots' nip(`nipuni')  ///
			  noadapt // ip(g) always. ip(m) is not appropriate for 1 dimension.

			matrix b`g' = e(b)
			qui gllapred _metandi_u`g' if `touse', u
			drop _metandi_u`g's1
			}

	

		/*** construct starting values ***/
		qui bysort _metandi_i (_metandi_d1) :  ///
		  replace _metandi_u0m1 = _metandi_u0m1[_n-1] if mi(_metandi_u0m1) & `touse'
		if "`detail'" !="" {
			di as txt "Covariance of posterior mean logits:"
			correlate _metandi_u1m1 _metandi_u0m1 if `touse', covariance
			}
		qui correlate _metandi_u1m1 _metandi_u0m1 if `touse'
		drop _metandi_u1m1 _metandi_u0m1
		if "`detail'" !="" di as txt "..giving correlation " as res %7.4f r(rho)
		scalar cov = r(rho) * b1[1,2] * b0[1,2] 
		matrix v0 = ( b1[1,2]^2, cov \ cov, b0[1,2]^2 )
		matrix b00 = cholesky(v0)
		matrix b0 = ( b1[1,1], b0[1,1], b00[1,1], b00[2,2], b00[2,1] )

		/*** fit full model ***/
		if "`log'" == "" {
			di as txt _n "Fitting bivariate model:"
			}

		gllamm _metandi_true _metandi_d1 _metandi_d0 if `touse', ///
		  nocons i(_metandi_i) nrf(2) eqs(eq1 eq0) ///
		  family(binomial) denom(_metandi_n) link(logit) from(b0) copy  ///
		  `log' `allc' `trace' `dots' nip(`nip') ip(`ip') adapt `nodis'

		capture _estimates drop _metandi
		_estimates hold _metandi, copy
	
		tempname ll
		scalar `ll' = e(ll) // log-likelihood
		
		// c22 v small -> corrlogits=+/-1 & numerical problem if include in nlcom
		local c22term "[_me1_2]_b[_metandi_d0]^2"
		if abs([_me1_2]_b[_metandi_d0]) < c(epsfloat) local c22term 0
		qui nlcom ///
		  ( muA: _b[_metandi_d1] ) ///
		  ( muB: _b[_metandi_d0] ) ///
		  ( s2A: [_me1_1]_b[_metandi_d1]^2 ) /// c11^2
		  ( s2B: [_me1_2_1]_b[_cons]^2 + `c22term' ) /// c12^2 + c22^2
		  ( sAB: [_me1_1]_b[_metandi_d1] * [_me1_2_1]_b[_cons] ) /// c11 * c21
		  , post
		
		}   // endif gllamm


	
	else { // xtmelogit
		if "`detail'" == ""  ///
		  local xtmeopts "noretable nofetable noheader nogroup nolrtest"
		xtmelogit _metandi_true _metandi_d1 _metandi_d0, nocons ///
		  || _metandi_i: _metandi_d1 _metandi_d0, nocons covariance(un) ///
		  binomial(_metandi_n) ///
		  intp(`nip') refineopts(iterate(3)) /// default 2 fails with CT data
		  `xtmeopts' `log' `trace'

		capture _estimates drop _metandi
		_estimates hold _metandi, copy

		tempname ll
		scalar `ll' = e(ll) // log-likelihood

		// c22 v small -> corrlogits=+/-1 & numerical problem if include in nlcom
		local corrterm "tanh([atr1_1_1_2]_b[_cons])"
		if [atr1_1_1_2]_b[_cons] < -4 local corrterm "(-1)"
		if [atr1_1_1_2]_b[_cons] >  4 local corrterm "1"
		
		qui nlcom ///
		  ( muA: _b[_metandi_d1]              ) ///
		  ( muB: _b[_metandi_d0]              ) ///
		  ( s2A: exp(2 * [lns1_1_1]_b[_cons]) ) /// 
		  ( s2B: exp(2 * [lns1_1_2]_b[_cons]) ) /// 
		  ( sAB: exp([lns1_1_1]_b[_cons]) * exp([lns1_1_2]_b[_cons])  ///
		  * `corrterm'                        ) ///
		  , post


		}

	if "`clear'" == "" restore
	
	tempname biv bhsroc Vhsroc

	
	_estimates hold `biv', copy

	local s2alphaterm  "2*( sqrt(_b[s2A] * _b[s2B])  + _b[sAB] )"
	local s2thetaterm ".5*( sqrt(_b[s2A] * _b[s2B])  - _b[sAB] )"
	if "`c22term'"=="0" | "`corrterm'"=="(-1)" | "`corrterm'"=="1" {
		if _b[sAB] < 0 local s2alphaterm 0
		else           local s2thetaterm 0
		}
	
	qui nlcom ///
	  ( Lambda:     ( _b[s2B] / _b[s2A] )^(.25) * _b[muA] ///
	  + ( _b[s2A] / _b[s2B] )^(.25) * _b[muB]               ) ///
	  ( Theta: .5*( ( _b[s2B] / _b[s2A] )^(.25) * _b[muA] ///
	  - ( _b[s2A] / _b[s2B] )^(.25) * _b[muB] )             ) ///
	  ( beta:  .5*log(_b[s2B] / _b[s2A])                    ) ///
	  ( s2alpha: `s2alphaterm'  ) ///
	  ( s2theta: `s2thetaterm'  ) ///
	  , post 

	matrix `bhsroc' = e(b)
	matrix `Vhsroc' = e(V)

	_estimates unhold `biv'

	ereturn repost, esample(`touse')
	ereturn matrix b_hsroc `bhsroc'
	ereturn matrix V_hsroc `Vhsroc'
	ereturn local cmd "metandi"
	ereturn local predict metandi_p
	ereturn scalar N =e(N)/2
	ereturn scalar ll = `ll'
	/* store varlist (e.g. tp fp fn tn) for use by metandi_p */
	ereturn local tpfpfntn "`varlist'"
	if "`gllamm'" == "" ereturn local method "xtmelogit"
	else ereturn local method "gllamm"
	ereturn local title "Meta-analysis of diagnostic accuracy"


	Display, level(`level') `bivariate' `hsroc' `summarypt'

	if "`plot'" != "" metandiplot `e(tpfpfntn)' `if' `in'
	/* NB not -if `touse'- as `touse' var now deleted - see -help ereturn-. */

end   // program Estimate


	
program define Display, eclass
	syntax [, Level(real `c(level)') noBivariate noHsroc noSummarypt]

	/* Header */
	di as txt _n e(title) _n
	di as txt "Log likelihood   = " as res e(ll)  ///
	  _col(51) as txt "Number of studies = " as res %8.0f e(N)
// di as txt "Condition number = " as res  e(cn)
	di in smcl as txt "{hline 13}{c TT}{hline 64}"
	di in smcl as txt "{col 14}{c |}      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]"

	tempname biv b V
	_estimates hold `biv', copy


	/*** Bivariate parameters ***/
	RenamePost b V  ///
	  "muA:_cons muB:_cons s2A:_cons s2B:_cons sAB:_cons"
	/*  Corr(logits) */
	local corr = [sAB]_b[_cons] / sqrt( [s2A]_b[_cons] * [s2B]_b[_cons] )

	if "`bivariate'" == "" {
		di in smcl as txt "{hline 13}{c +}{hline 64}"
		di in smcl as res "Bivariate" as txt "{col 14}{c |}"
		_diparm muA, label(E(logitSe)) noprob level(`level')
		_diparm muB, label(E(logitSp)) noprob level(`level')
		/* Var(logitSe), Var(logitSp) */
		_diparm s2A s2B, label(Var(logitSe)) ci(log) noprob level(`level') f(@1) d(1 0)
		_diparm s2B s2A, label(Var(logitSp)) ci(log) noprob level(`level') f(@1) d(1 0)
		
		if abs(`corr')>0.995 /// SE & CI incalculable
		  di in smcl as txt "Corr(logits){col 14}{c |}" ///
		  as res "{col 17}" %9.0f `corr' "{col 36}.{col 66}.{col 78}."
		else _diparm sAB s2A s2B, label(Corr(logits)) ci(atanh) noprob  ///
		  level(`level') f(@1/sqrt(@2*@3))  ///
		  d(1/sqrt(@2*@3)  -.5*@1/sqrt(@2^3*@3)  -.5*@1/sqrt(@2*@3^3))
		}

	/*** HSROC parameters: Lambda, Theta, beta, sigma^2_alpha, sigma^2_theta ***/
	_estimates unhold `biv'
	_estimates hold `biv', copy

	if "`hsroc'" == "" {
		RenamePost b_hsroc V_hsroc ///
		  "Lambda:_cons Theta:_cons beta:_cons s2alpha:_cons s2theta:_cons"
		di in smcl as txt "{hline 13}{c +}{hline 64}"
		di in smcl as res "HSROC" as txt "{col 14}{c |}"
		_diparm Lambda, label(Lambda) noprob level(`level')
		_diparm Theta, label(Theta) noprob level(`level')
		_diparm beta, label(beta) level(`level')
		
		if `corr'< -0.995  ///s2alpha is (virtually) 0 and SE and CI incalculable
		  di in smcl as txt %12s "s2alpha" "{col 14}{c |}"  ///
		  as res "{col 17}" %9.7g [s2alpha]_b[_cons] "{col 36}.{col 66}.{col 78}."
		else _diparm s2alpha beta,  ///
		  label(s2alpha) ci(log) noprob level(`level') f(@1) d(1 0)
		
		if `corr'> 0.995  /// s2theta is (virtually) 0 and SE and CI incalculable
		  di in smcl as txt %12s "s2theta" "{col 14}{c |}"  ///
		  as res "{col 17}" %9.7g [s2theta]_b[_cons] "{col 36}.{col 66}.{col 78}."
		else _diparm s2theta beta,  ///
		  label(s2theta) ci(log) noprob level(`level') f(@1) d(1 0)
		}

	/****** Se, Sp, DOR, LR+, LR- ******/
	_estimates unhold `biv'
	_estimates hold `biv', copy

	if "`summarypt'" == "" {
		RenamePost b V "muA:_cons muB:_cons s2A:_cons s2B:_cons rAB:_cons"
		di in smcl as txt "{hline 13}{c +}{hline 64}"
		di in smcl as res "Summary pt." as txt "{col 14}{c |}"
		_diparm muA   , label(Se) invlogit 
		_diparm muB   , label(Sp) invlogit 
		_diparm muA muB, label(DOR) ci(log) f( exp(@1+@2) ) d( exp(@1+@2) exp(@1+@2) )
		_diparm muA muB, label(LR+) ci(log) f( invlogit(@1)/(1-invlogit(@2)) ) ///
		  d( exp(@2-@1)*invlogit(@1)^2/invlogit(@2)  exp(@2)*invlogit(@1)  )	  
		_diparm muA muB, label(LR-) ci(log) f( (1-invlogit(@1))/invlogit(@2) ) ///
		  d( exp(-@1)*invlogit(@1)^2/invlogit(@2)  exp(-@1-@2)*invlogit(@1)  )  
		_diparm muA muB, label(1/LR-) ci(log) f( invlogit(@2)/(1-invlogit(@1)) ) ///
		  d( exp(@1)/(1+exp(-@2))  exp(@1-@2)*(1+exp(-@1))/(1+exp(-@2))^2  )
		}
	
	di in smcl as txt "{hline 13}{c BT}{hline 64}"
		
	/* Cov(mu_A, mu_B) (needed to draw confidence and prediction regions) */
	if "`bivariate'" == "" {
		tempname vmu
		matrix `vmu' = e(V)
		di as txt "Covariance between estimates of E(logitSe) & E(logitSp)  "  ///
		  as res %9.0g `vmu'[1,2]
		}

	_estimates unhold `biv'
	
	
end

program define RenamePost, eclass
	tempname b V
	matrix `b' = e(`1')
	matrix `V' = e(`2')
	matrix colnames `b' = `3'
	matrix colnames `V' = `3'
	matrix rownames `V' = `3'
	ereturn post `b' `V'
end

	
	exit

