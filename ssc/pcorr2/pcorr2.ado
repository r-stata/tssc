*! pcorr2 version 1.1
*! Adapted by Richard Williams from pcorr version 2.2.8  08sep2000
*! Semipartial correlations added in V. 1.0
*! Squared partial and semipartial correlations added in V. 1.1
*! Last Modified 14Feb2004
program define pcorr2, byable(recall)
	version 6
	syntax varlist(min=3) [aw fw] [if] [in]
	marksample touse
	local weight "[`weight'`exp']"
	quietly reg `varlist' `weight' if `touse'
	if (e(N)==0 | e(N)==.) { error 2000 }
      di
	di in gr "(obs=" e(N) in gr ")"
	local NmK = e(df_r)
	tokenize `varlist'
	di _n in gr "Partial and Semipartial correlations of `1' with" _n
	di in smcl in gr "    Variable {c |}     Partial      SemiP    Partial^2     SemiP^2       Sig." _n /*
	*/ "{hline 13}{c +}{hline 60}
	mac shift
	while ("`1'"!="") { 
		quietly test `1'
		if (r(F)==.) {
		       di in smcl in gr %12s abbrev("`1'",12) " {c |} (dropped)"
		}
		else {
			local s "1"
			if (_b[`1']<0) { local s "-1" }
			di in smcl in gr %12s abbrev("`1'",12) " {c |}" in ye/* 
			*/ %12.4f `s'*sqrt(r(F)/(r(F)+`NmK')) /*
			*/ %12.4f `s'*sqrt(r(F)* ((1-e(r2))/`NmK')) /*
			*/ %12.4f (r(F)/(r(F)+`NmK')) /*
			*/ %12.4f (r(F)* ((1-e(r2))/`NmK')) /*
			*/ in yel %12.3f tprob(`NmK',sqrt(r(F)))
		}
		mac shift
	}
end
