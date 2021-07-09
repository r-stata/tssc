capt program drop lomackinlay
*! version 1.0.7  14nov2007    C F Baum
*  from kpss 1.2.1, ipshin 1.0.8,
*  Lo & MacKinlay (LMK), A Non-Random Walk Down Wall Street (1999),
*  https://www.jstor.org/stable/j.ctt7tccx.9
*  Campbell, Lo, MacKinlay, Econometrics of Financial Markets (1997); 
*  Lo and MacKinlay, "Stock market prices do not follow random walks: evidence
*  from a simple specification test", Rev. Fin. Studies 1:1, 1988, 41-66; and
* "A small-sample overlapping variance-ratio test", Tse, Ng and Zhang, 2002
*  www.mysmu.edu/faculty/yktse/JTSA_R.pdf 
*
*  1.0.2: output formatting, handle numlist of q values
*  1.0.3: deal with gaps, add gaps option
*  1.0.4: rewrite using LMK notation
*  1.0.5: update for problems identified by Allin Cottrell 6804
*  1.0.6: update for problem with heteroskedastic correction (Brian Fryd 7B09)
*  1.0.7 correct inclusion of n*q term in delta_j and rs statistic

program define lomackinlay, rclass byable(recall)
	version 9.2

	syntax varname(ts) [if] [in] [ , Q(numlist int >0) Gaps Robust]  

   	marksample touse
			/* get time variables */
    _ts tvar panelvar if `touse', sort onepanel
	markout `touse' `timevar'
	tsreport if `touse' //, report
	if r(N_gaps) & "`gaps'"=="" {
		di in red "sample may not contain gaps"
		exit
	}

* require data to be tsset
	qui tsset
	local rts = r(tsfmt)
	local rtvar = r(timevar)
* if gaps option used, create new tsset variable
	if "`gaps'" ~= "" {
		tempvar timevar
		qui {
			gen `timevar' = _n  if `touse'
			tsset `timevar'
			local rts = r(tsfmt)
		}
	}
 			
	su `r(timevar)' if `touse', meanonly
	local n1 = r(min)
	local n2 = r(max)

	tempvar cd1x dx cdx dxl cdxl cd1x2 dprod
	tempname enn enn0 n vara varb mu qmu sumcdiff mult m v rs p vr 
	tempname deltanum deltaden vhatr type
	qui {
		gen double `dx' = .
		gen double `cdx' = .
	}	
* get q: span of differencing
	local nq: word count `q'
	local sq: list sort q
	if !`nq' {
		local sq 2 4 8 16
	}
* ensure that all calcs done on smallest indicated sample
	local nsq: word count `sq'
	local maxlag: word `nsq' of `sq'
	markout `touse' L(1/`maxlag').`varlist'
	
* output header
	di " "
	di as text "Lo-MacKinlay modified overlapping Variance Ratio statistic for `varlist'"
	di as text "["`rts' `n1' " - " `rts' `n2' " ]" _n
	di as text "q {col 10} N {col 20} VR {col 32} R_s {col 42} p>|z|" _n "{hline 50}"
	
* generate first-differenced series and its mean (mu) and center the series
* (LMK 3.2.3) 
	qui {
		capt drop `cd1x' `cd1x2'
		gen double `cd1x' = D.`varlist' if `touse'
		sum `cd1x', meanonly
		scalar `mu' = r(mean)
		replace `cd1x' = `cd1x' - `mu'
* and its variance with adjustment for bias (LMK 3.2.7a)
		sum `cd1x'
		scalar `vara' = r(Var)
* generate squares of that series and their sum for use in LMK 3.2.9c
		gen double `cd1x2' = `cd1x'^2
		sum `cd1x2', meanonly
		scalar `deltaden' = r(sum)
	}

foreach q of local sq {
* calculate n = int(N/q)
	sum `varlist' if `touse', meanonly
* total N available before differencing
	scalar `enn0' = r(N)
	scalar `n' = int(`enn0'/`q')

* generate q-differenced series
	qui	replace `dx' = `varlist' - L`q'.`varlist' if `touse'

* calculate N of q-differenced series
	sum `dx', meanonly
	scalar `enn' = r(N)
	scalar `qmu' = `mu'*`q'
* center q-differenced series and square (LMK 3.2.5)
	qui replace `cdx' = (`dx' - `qmu')^2
* sum of squares of q-differenced series 
	qui sum `cdx'
	scalar `sumcdiff' = r(sum) 
// di as err `sumcdiff'
* calculate multiplier with d.f. adjustment (3.2.7b)
	scalar `mult' = 1/(`q'*(`n'*`q'-`q'+1)*(1-`q'/(`n'*`q')))
// di as err `mult'
	scalar `varb' = `mult'*`sumcdiff'
* calculate VR_q and MR_q
	scalar `vr' = `varb'/`vara' 
	scalar `m' = `vr' -1
// di as err `m'
* and its variance V (3.2.6b)
	scalar `v' = (2*(2*`q'-1)*(`q'-1))/(3*`q')
	if "`robust'" == "" {
* standardized R statistic for homoskedastic case (LMK 3.2.6b)
* per Cottrell, should include product of sqrt(n q) where n refers
* to total N of series before differencing
		scalar `rs' = sqrt(`n'*`q')*`m'/sqrt(`v')
		local type homoskedastic
}
	else {
* for robust statistic, calculate delta_j sequence (3.2.9c)
		qui {
		capt drop `dxl' `cdxl' `dprod'
		gen double `dxl' = .
		gen double `cdxl' = .
		gen double `dprod' = .
		}
* set trace on
		scalar `vhatr' = 0
		local q1 = `q'-1
		forv j = 1/`q1' {
			local j1 = `j'-1
			qui	{
* per Cottrell, first term in numerator is squared centered D.x
*               second term in numerator is Jth lag of first term
				replace `cdxl' =  L`j'.`cd1x2' if `touse'
				replace `dprod' = `cd1x2'*`cdxl'
			}
			sum `dprod', meanonly
			scalar `deltanum' = r(sum)
* delta_j per 3.2.9b, including n*q multiplier
			local delta`j' = `n'*`q'*`deltanum' / (`deltaden'^2) 
* calculate vhat_q for robust case (3.2.9b)
			scalar `vhatr' = `vhatr' + (2*(`q'-`j')/`q')^2 * `delta`j''
		}
* standardized R statistic for heteroskedastic case (LMK 3.2.10b)
	scalar `rs' = sqrt(`n'*`q')*`m'/sqrt(`vhatr')
	local type heteroskedastic
}
* calculate normal tail prob
	scalar `p' = 2 * normprob(-abs(`rs'))
* display statistic
// di in r `vara' " " `varb' _n
	di "`q' {col 10}" `enn' "{col 20}" %5.3f `vr' "{col 30}" %8.4f `rs' "{col 42}" %5.4f `p' 
	
* set up returns
	return scalar N_`q' = `enn'
	return scalar q_`q' = `q'
	return scalar R_`q' = `rs'
	return scalar p_`q' = `p'
	return scalar v_`q' = `vr'
	
} // end q loop
	if "`robust'" != "" {
			di _n "Test statistics robust to heteroskedasticity" _n
	}
	return local type = "`type'"
	
* restore orig tsset if needed
	if "`gaps'" ~= "" {
		qui tsset `rtvar'
	}
	
	end
