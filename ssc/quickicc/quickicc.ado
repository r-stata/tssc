*! version 1.0  04-05-11
// After an xtmixed command with two levels this program calcuates the ICC and standard error 
// of the ICC.

program quickicc, rclass
	version 11.1
	tempname cs l2vc l1vc tv icc ns m N bsum csum2 denom numer se
	tempvar select
	if e(cmd) == "xtmixed" {
		if e(revars) == "_cons" {
			scalar `cs' = colsof(e(N_g))
			capture assert `cs' == 1
			if _rc == 9 {
				display as error "this command is only for two-level models"
				exit _rc
			}
			local j = e(ivars)
			confirm variable `j'
			preserve
			local y = e(depvar)
			gen `select' = e(sample)
			quietly : _diparm lns1_1_1, exp
			scalar `l2vc' = r(est) * r(est)
			quietly : _diparm lnsig_e, exp
			scalar `l1vc' = r(est) * r(est)
			scalar `tv' = `l1vc' + `l2vc'
			scalar `icc' = `l2vc' / `tv'
			matrix `ns' = e(N_g)
			scalar `m' = `ns'[1,1]
			scalar `N' = e(N)
			collapse (sum) n = `select', by(`j')			
			gen V = 1 + ((n-1)*(`icc'^2))
			gen W = 1 + ((n-1)*`icc')
			gen a = n*(n-1)
			gen b = a * V * (W^-2)
			quietly : sum b
			scalar `bsum' = r(sum)
			gen c = a * (W^-1)
			quietly : sum c
			scalar `csum2' = r(sum)^2
			scalar `numer' = 2*`N'*((1-`icc')^2)
			scalar `denom' = (`N'*`bsum')-((`icc'^2)*(`csum2'))
			scalar `se' = (`numer'/`denom')^.5
			display as text "{hline 13}" "{c TT}" "{hline 20}"
			display as text _col(14) "{c |}" _col(18) "ICC" _col(25) "Std. Err."
			display as text "{hline 13}" "{c +}" "{hline 20}"
			display as text as text %12s abbrev("`y'",12) _col(14) "{c |}" ///
			_col(15) as result %7.3f `icc' _col(24) as result %8.3f `se' 
			display as text "{hline 13}" "{c BT}" "{hline 20}"
			return local model = e(cmdline)
			return scalar l1vc = `l1vc'
			return scalar l2vc = `l2vc'
			return scalar tv = `tv'
			return scalar N = `N'
			return scalar m = `m'
			return scalar se = `se'
			return scalar icc = `icc'			
			restore
		}
		else {
			display as error "only _cons can have random effect"
			exit 9
		}
	}
	else {
		display as error "can't find last xtmixed estimations"
		exit 301
	}
end


