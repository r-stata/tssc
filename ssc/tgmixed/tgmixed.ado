*! tgmixed  1.0.2   cfb A705
capt prog drop tgmixed
prog tgmixed, eclass byable(recall)
	version 11.2
	local cmd tgmixed
	if replay() {
			if `"`e(cmd)'"' != "tgmixed"  {
				error 301
		}
	di as res _n "Theil-Goldberger mixed estimates" 
	di _col(55) "Number of obs = "  %8.0f e(N)
	di _col(55) "R-squared     = "  %8.4f e(r2) 
	di _col(55) "Root MSE      = "  %8.5g e(rmse)
	ereturn display
	di "Theil compatibility statistic = " %7.4f e(compat) _col(55) " Pr > Chi2(" %3.0f e(vrank) ") = " ///
		%6.4f e(pvalue)
	}
	else {
// should handle ts and fv varlists
		syntax varlist(numeric min=2) [if] [in], PRIor(string) [COV(string) QUIetly]
		tempname s2 bols Vols Vprior mixb mixV rmsemix r2mix gamma Vrank frac_sample
		tempvar esmpl esmpl2 mixhat mixeps
		loc cmdline `0'
		loc depvar: word 1 of `varlist'
		loc rhs: list varlist - depvar
		marksample touse
		su `depvar' if `touse', mean
		if r(N) == 0 {
			error 2000
		}				
// regress to get estimate of sigma^2
		`quietly' di as res _n "Unconstrained OLS estimates"
		`quietly' reg `varlist' if `touse'
		loc nols = e(N)
		loc dfr = e(df_r)
		loc tss = e(mss) + e(rss)
		mat `bols' = e(b)
		loc bcol: colnames `bols'
		mat `Vols' = e(V)
		scalar `s2' = e(rmse)^2
		g byte `esmpl' = e(sample)
		g byte `esmpl2' = `esmpl'
		mat `Vprior' = J(rowsof(`Vols'), rowsof(`Vols'), .)
		mata: parse_prior("`depvar'", "`rhs'", "`s2'", "`esmpl'", "`prior'","`cov'", ///
		                  "`Vprior'","`bols'", "`gamma'", "`Vrank'", "`frac_sample'", ///
		                  "`mixb'", "`mixV'")
		mat rownames `mixb' = `depvar'
		mat colnames `mixb' = `bcol'
		mat rownames `mixV' = `bcol'
		mat colnames `mixV' = `bcol'
		mat rownames `Vprior' = `bcol'
		mat colnames `Vprior' = `bcol'
		di as res _n "Theil-Goldberger mixed estimates" 
		ereturn post `mixb' `mixV', depname(`depvar') esample(`esmpl') obs(`nols') dof(`dfr')
		qui predict double `mixhat' if `esmpl2', xb
		qui g double `mixeps' = (`depvar' - `mixhat')^2
		su `mixeps', mean
		scalar `rmsemix' = sqrt( r(sum) / `dfr' )
		scalar `r2mix' = 1 - (r(sum) / `tss')
		ereturn scalar rmse = `rmsemix'
		ereturn scalar r2 = `r2mix'
		ereturn scalar N = `nols'
		ereturn scalar df_r = `dfr'
		ereturn local prior "`prior'"
		ereturn matrix Vprior = `Vprior'
		ereturn local cmdline "tgmixed `cmdline'"
		ereturn local marginsok "XB default"
		ereturn local depvar "`depvar'"
// predict options xb and stdp available
		ereturn local predict "regres_p"
		di _col(55) "Number of obs = "  %8.0f `nols'
		di _col(55) "R-squared     = "  %8.4f `r2mix' 
		di _col(55) "Root MSE      = "  %8.5g `rmsemix'  
		ereturn loc cmd "tgmixed"
		ereturn display
		di "Theil compatibility statistic = " %7.4f `gamma' _col(55) " Pr > Chi2(" %3.0f `Vrank' ") = " ///
		%6.4f chi2tail(`Vrank', `gamma')
		di _n "Shares of posterior precision:   sample info = " %5.3f `frac_sample' ///
		"   prior info = " %5.3f (1-`frac_sample') 
		ereturn scalar compat = `gamma'
		ereturn scalar vrank = `Vrank'
		ereturn scalar pvalue = chi2tail(`Vrank', `gamma')
		ereturn scalar frac_sample = `frac_sample'
		ereturn scalar frac_prior = 1 - `frac_sample'
	}
end

mata: mata clear
version 11.2
mata:
// parse prior into triples of varname value s.e.
	void parse_prior(
		string scalar depvar,
		string scalar rhs,
		string scalar s2,
		string scalar esmpl,
		string scalar prior,
		string scalar cov,
		string scalar Vprior,
		string scalar bols,
		string scalar gammastr,
		string scalar Vrankstr,
		string scalar fsstr,
		string scalar mixb,
		string scalar mixV) 
	{	
		real matrix R, r, Vinv
		rhsv = tokens(rhs)
// assume constant is last element
		nrhs = cols(rhsv) + 1
		prstr = tokens(prior)
		npr = cols(prstr)
		if (mod(npr , 3) != 0) {
			"Error: prior() must be specified as triples (varname, value, s.e.)"
			exit(error(198))
		}
// check whether cov was provided
		cvstr = tokens(cov)
		ncv = cols(cvstr)
		if (mod(ncv , 3) != 0) {
			"Error: cov() must be specified as triples (varname1, varname2, value)"
			exit(error(198))
		}
// parse prior elements	
		R = J(nrhs, nrhs, 0)
		r = J(nrhs, 1, 0)
		V = J(nrhs, nrhs, 0)
		Vinv = J(nrhs, nrhs, 0)
// locate regressors named in prior in rhslist
// uses mm_posof() from Ben Jann's moremata, included below
		prstm = rowshape(prstr, npr/3)'
		for(i=1; i<=cols(prstm); i++) {
			nreg = mm_posof(rhsv, prstm[1, i])
			if (nreg == 0) {
				"Error: regressor listed in prior() not in model:"
				prstm[1, i]
				exit(error(198))
			}
			else {
// regressor located; fill in R, r, V elements
			R[nreg, nreg] = 1
			r[nreg] = strtoreal(prstm[2, i])
			V[nreg, nreg] = strtoreal(prstm[3, i]) ^2
			}
		}
// end prior parsing loop
		if (ncv) {
// cov parsing loop
			cvstm = rowshape(cvstr, ncv/3)'
			for(i=1; i<=cols(cvstm); i++) {
				nreg1 = mm_posof(rhsv, cvstm[1, i])
				nreg2 = mm_posof(rhsv, cvstm[2, i])
				if (nreg1 == 0 ) {
					"Error: regressor listed in cov() not in model"
					cvstm[1, i]
					exit(error(198))
				}
				if (nreg2 == 0 ) {
					"Error: regressor listed in cov() not in model"
					cvstm[2, i]
					exit(error(198))
				}
				if (nreg1 == nreg2) {
					"Error: regressor listed twice in cov()"
					cvstm[1,i]
					exit(error(198))
				}
				V[nreg1, nreg2] = strtoreal(cvstm[3, i])
				V[nreg2, nreg1] = strtoreal(cvstm[3, i])
			}
		}
// end cov parsing loop
		" "
		"Prior coefficient values and standard errors"
		prstm
		if (ncv) {
			" "
			"Prior covariances"
			cvstm
		}
// create views of y, X using e(sample)
		st_view(y=., ., depvar, esmpl)
		st_view(X=., ., rhsv, esmpl)
		X = X, J(rows(X), 1, 1)
// get OLS s2 for variance estimates
		sigma2 = st_numscalar(s2)
// tgmixed solution for b and VCE from Theil-Goldberger, 1961, (2.8)-(2.9)
// for now only allow scalar identity errors; easy extension to robust
		st_matrix(Vprior, V)
		Vinv = invsym(V)
		w = J(rows(X), 1, 1/sigma2) 
		Vb = invsym(quadcross(X, w, X) + R' * Vinv * R)
		b = Vb * (quadcross(X, w, y) + R' * Vinv * r)
		st_matrix(mixb, b')
		st_matrix(mixV, Vb)
// Theil compatibility statistic, JASA 1963, (3.3)
		betaols = st_matrix(bols)'
		discrep = (r - R * betaols)
		gamma = discrep' * invsym( sigma2 * R * invsym(quadcross(X, X)) * R' + V) * discrep
		st_numscalar(gammastr, gamma)
		st_numscalar(Vrankstr, rank(V))
// implement fraction of variance from prior info statistic from Theil 1963?
		frac_sample = 1/nrhs * trace(quadcross(X, w, X) * Vb)
		st_numscalar(fsstr, frac_sample)
	}
end
*! 
*! mm_posof.mata
*! version 1.0.0, Ben Jann, 24mar2006
version 9.0
mata:
real scalar mm_posof(transmorphic vector haystack, transmorphic scalar needle)
{
        real scalar i

        for (i=1; i<=length(haystack); i++) {
                if (haystack[i]==needle) return(i)
        }
        return(0)
}
end



