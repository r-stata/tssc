*! emc package v. 0.1.2
*! Support: Niels Henrik Bruun, nhbr@ph.au.dk
*! 2019-01-26	v0.1.1	All regressions allowed
* 2018-10-26	v0.1.1	Wrong upload
* 2018-10-14	v0.1.1	Help modified
* 2018-02-07	v0.1.0	Created
/*
cls
capture drop _*
capture program drop emc
capture mata mata drop emc_splines()
capture mata mata drop pct_knots()
capture mata mata drop is_zero_one()
*/
program define emc, rclass	// effect modification margins
	version 12

	if `c(version)' >= 13 set prefix emc

	sreturn clear
	_prefix_clear

	capture _on_colon_parse `0'
	
	local 0 `s(before)'
	syntax , /*
		*/at(numlist min=1 sort) /*
		*/[ /*
			*/Pctknots(numlist min=3 max=10 >0 <100 sort) /*
			*/Nknots(integer 4) /*
			*/Keepcubicsplines /*
			*/Eform /*
			*/emcnames(namelist min=4 max=4) /*
			*/CIlimits(numlist max=1 >50 <100) /*
			*/GRaph /*
			*/ *	/* Twoway graph options
		*/]
	
	mata: pct_knots("`pctknots'", "`nknots'")
	if "`cilimits'" == "" local cilimits 95
	local cilimits = `cilimits' / 200 + 0.5
	local graph_opt `options'
	
	_prefix_command emc: `s(after)'
	*return list
	local ifinwgt `"`r(if)' `r(in)' `r(wgt)'"'
	local cmd `s(cmdname)'
	/*
	if !inlist("`cmd'", "logit", "logistic", "clogit", "poisson", "binreg", ///
		"stcox", "regress", "glm") ///
		mata:  _error("Allowed regression commands are logit, logistic, clogit, poisson, binreg, stcox, regress, glm")
	*/
	local opt `s(options)'
	local 0 `s(anything)'
	if inlist("`cmd'", "stcox") {
		syntax varlist(min=2 numeric fv)
		tokenize "`varlist'"
		local outcome ""
		local exposure `1'
		local emname `2'
		local adjustments = subinstr("`varlist'", "`1' `2'", "",.)
	}
	else {
		syntax varlist(min=3 numeric fv)
		tokenize "`varlist'"
		if inlist("`cmd'", "logit", "logistic", "clogit") mata: is_zero_one("`1'")
		local outcome `1'
		local exposure `2'
		local emname `3'
		local adjustments = subinstr("`varlist'", "`1' `2' `3'", "",.)
	}
	mata: is_zero_one("`exposure'")
	if regexm("`exposure'", ".+\.(.+)") local exposure = regexs(1)

	local command `cmd' `outcome' `exposure' __`emname'0* __`emname'1* `adjustments' `ifinwgt', `opt'
	
	
	****************************************************************************
	*** Calculations ***********************************************************
	****************************************************************************
	
	mata: emc_splines( ///
		`"`command'"', ///
		"`exposure'", ///
		"`emname'", ///
		"`pctknots'", ///
		"`at'", ///
		"`emcnames'", ///
		"`keepcubicsplines'" != "", ///
		"`eform'" != "", ///
		`cilimits' ///
		)

	return add
	

	****************************************************************************
	*** Graph and data *********************************************************
	****************************************************************************
	tokenize `emnames'
	format `2' `3' `4' %20.3f
	list `1' `2' `3' `4' if !missing(`2'), noobs clean abbreviate(32)
	
	if ( "`graph_opt'" != "" | "`graph'" != "" ) {
		local xtitle "`:variable label `emname''"
		if "`eform'" != "" local ytitle "Exponentiated contrast and 95% CI"
		else local ytitle "Contrast and 95% CI"
		if "`xtitle'" == "" local xtitle "`emname'"
		_get_gropts , graphopts(`graph_opt') gettwoway
		local gr_cmd `"twoway (line `4' `3' `2' `1', lcolor(black black black) lpattern(- - solid)), legend(off) xtitle(`"`xtitle'"') ytitle(`"`ytitle'"') `s(twowayopts)'"'
		`gr_cmd'
		return local graph_cmd `"`gr_cmd'"'
	}
end


********************************************************************************
*** MATA ***********************************************************************
********************************************************************************
mata:
	mata set matastrict on
	mata set matalnum on
	
	void is_zero_one(string scalar varname) 
	{
		if ( regexm(varname, ".+\.(.+)") ) varname = regexs(1)
		if ( nhb_sae_unique_values(varname, "", "", 1) != (0,1) ) {
			_error(sprintf("Variable %s must be zero-one", varname))
		}
	}
	
	void pct_knots(string scalar pctknots, string scalar nknots)
	{
		real scalar nk
		string vector nknots_conversion
	
		if ( pctknots == "" ) {
			if ( (nk = strtoreal(nknots) - 2) < 6 ) {
				nknots_conversion =	"10 50 90",
									"5 35 65 95",
									"5 27.5 50 72.5 95",
									"5 23 41 59 77 95",
									"2.5 `=18+1/3' `=34+1/6' 50 `=65+5/6' `=81+2/3' 97.5"
				st_local("pctknots", nknots_conversion[nk])
			} else {
				_error("nknots must be an integer between 3 and 7")
			}
		}
	}
	
	void emc_splines(
		string scalar stata_command,
		string scalar exposure,
		string scalar eff_mod,
		string scalar pctknots,
		string scalar str_at_values,
		string scalar emcnames,
		real scalar keepcubicsplines,
		real scalar eform,
		real scalar cilimits
		)
	{
		real scalar e, rc, C, r, R, reg_constant
		real rowvector slct, slct_r
		real colvector v_exposure, v_pctknots, v_eff_mod, v_val, betas, at_values
		real matrix knots, cubic, regressors, covariance, pr_ci
		string rowvector names
		string colvector cnm
		class nhb_mc_splines scalar sp
		class nhb_mt_labelmatrix scalar lblm

		v_exposure = st_data(., exposure)
		v_eff_mod = st_data(., eff_mod)
		v_pctknots = strtoreal(tokens(pctknots))'
		at_values = strtoreal(tokens(str_at_values))'
		knots = v_pctknots
		regressors = J(rows(at_values),1,1)
		for(e = 0; e < 2; e++) {
			v_val =  v_eff_mod :/ (v_exposure :== e)
			knots = knots, nhb_mc_percentiles(v_val, v_pctknots)[.,2]
			sp.add_knots(knots[.,2+e]')
			regressors = regressors, (-1)^(e+1) * sp.restricted_cubic(at_values)
			cubic = editmissing(sp.restricted_cubic(v_val), 0)
			C = cols(cubic)
			names = sprintf("__%s%f", eff_mod, e) :+ strofreal((1..C))
			nhb_sae_addvars(names, cubic)
		}

		st_eclear()
		rc = nhb_sae_logstatacode(stata_command, 0, 1)
		betas = st_matrix("e(b)")'
		covariance = st_matrix("e(V)")
		st_rclear()

		st_global("r(command)", stata_command)
	
		lblm.values(knots[., 2..3])
		lblm.row_equations(eff_mod)
		lblm.row_names(knots[., 1])
		lblm.column_names(("Exposure(0)" \ "Exposure(1)"))
		lblm.to_matrix("r(knots)")

		lblm.values(regressors)
		lblm.row_equations(eff_mod)
		lblm.row_names(-regressors[., 2])
		lblm.column_equations("" \ "Exposure(" :+ strofreal((0 \ 1) # J(C,1,1)) :+ ")")
		lblm.column_names("Exposure" \ "Csp" :+ strofreal((1 \ 1) # (1::C)))
		lblm.to_matrix("r(regressors)")
		
		if ( !rc ) {
			if ( !keepcubicsplines ) st_dropvar(tokens(nhb_msa_unab(sprintf("__%s*", eff_mod))))
			slct = 1::(cols(regressors))
			reg_constant = cnm[rows(cnm=st_matrixcolstripe("e(b)")),2] == "_cons"
			pr_ci = nhb_mc_predictions(regressors, betas[slct], covariance[slct, slct], cilimits)
			if ( eform ) pr_ci = exp(pr_ci)

			lblm.values(pr_ci)
			lblm.column_equations("")
			lblm.row_names(-regressors[., 2])
			lblm.column_names(("Contrast", "Lower CI", "Upper CI")')
			lblm.to_matrix("r(predictions)")
			
			if ( emcnames != "" ) names = tokens(emcnames)
			else names = ("__" + eff_mod) :+ ("", "_contrast", "_lb", "_ub") 
			nhb_sae_addvars(names, (at_values, pr_ci))
			st_global("r(emnames)", invtokens(names))
			st_local("emnames", invtokens(names))	// format estimated variables
		}
	}
end
