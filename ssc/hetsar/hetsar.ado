
*! version 1.2.0 - 15aug2021 - Federico Belotti
*! See the end for versioning

program hetsar, eclass
	version 11
	syntax varlist(min=1 fv) [if] [in] [pweight/], ///
		[ WMATrix(string) 		///
		  NOCONStant 			///
		  ITERations(integer 250) ///
		  ROBust	///
		  TECHnique(string) TRace(string) DIFFicult	///
		  POSTHessian POSTscores ///
		  DETailed ivarlag(varlist fv) TIMELAG(string) noDCONSTRaints ///
		  FROM(string) SAVE(string) ///
		  TOLerance(real 1e-6) ///
		  LTOLerance(real 1e-7) ///
		  NRTOLerance(real 1e-5) NOLOG ]


	capt findfile lmoremata.mlib
	if _rc {
	  di in yel "Installing dependence: package -moremata- ...", _cont
	  qui ssc install moremata
	  di in gre "done"
	}

	// Parse dep and indep variables
	gettoken lhs rhs: varlist
	loc k: word count `rhs'

	// Mark the sample using the temporary var "touse"
	marksample touse

	// Parse time lags
	if "`timelag'" != "" {
		ParseDynamic dynx dynwx dyny dynwy : "`timelag'"

		if !("`dyny'"=="" & "`dynwy'"=="") {
			if "`dconstraints'" != "nodconstraints" {
				local dconstraints dconstraints
			}
			else local dconstraints
		}
	}

	if "`ivarlag'"=="" & "`dynwx'"!="" {
		display as error "timelag(wx) cannot be specified if ivarlag() is missing"
    	error 198
	}

	// Check for panel setup
	_xt, trequired
	local id: char _dta[_TSpanel]
	local time: char _dta[_TStvar]
	tempvar temp_id temp_t Ti
	qui egen `temp_id'=group(`id')
	sort `temp_id' `time'
	qui by `temp_id': g `temp_t' = _n if `touse'==1
	qui replace `temp_id' = . if `temp_t'== .
	sort `temp_id' `time'

	// Parse wmatrix
	tempname _wmat
	capture confirm matrix `wmatrix'
	local _rc_mat_assert = _rc
	if `_rc_mat_assert' != 0 {
		capture mata: SPMAT_assert_object("`wmatrix'")
		local _rc_spmat_assert = _rc
		if `_rc_spmat_assert' != 0 {
			cap m _SPMATRIX_assert_object("`wmatrix'")
			if _rc != 0 {
				di as error "Only Stata matrices, {help spmat} or {help spmatrix} objects are allowed as wmatrix() argument"
				exit 198
			}
			else capture spmatrix matafromsp `_wmat' `id' = `wmatrix'
		}
		else capture spmat getmatrix `wmatrix' `_wmat'
	}
	else m `_wmat' = st_matrix("`wmatrix'")


	***********************************************************************
	*** Get temporary variable names and perform Factor Variables check ***
	***********************************************************************
	*** (Note: Also remove base collinear variables if fv are specified)

	local fvops = "`s(fvops)'" == "true"
	if `fvops' {
		if _caller() >= 11 {

	    	local vv_fv : di "version " string(max(11,_caller())) ", missing:"

			********* Factor Variables parsing ****
			`vv_fv' _fv_check_depvar `lhs'

			local fvars "rhs ivarlag"
			foreach l of local fvars {
				if "`l'"=="rhs" local fv_nocons "`nocons'"
				fvexpand ``l''
				local _n_vars: word count `r(varlist)'
				local rvarlist "`r(varlist)'"
				fvrevar `rvarlist'
				local _`l'_temp "`r(varlist)'"
				forvalues _var=1/`_n_vars'  {
					_ms_parse_parts `:word `_var' of `rvarlist''
					*** Get temporary names here
					if "`r(type)'"=="variable" {
						local _`l'_tempnames "`_`l'_tempnames' `r(name)'"
						local _`l'_ntemp "`_`l'_ntemp' `:word `_var' of `_`l'_temp''"
					}
					if "`r(type)'"=="factor" & `r(omit)'==0 {
						local _`l'_tempnames "`_`l'_tempnames' `r(op)'.`r(name)'"
						local _`l'_ntemp "`_`l'_ntemp' `:word `_var' of `_`l'_temp''"
					}
					if ("`r(type)'"=="interaction" | "`r(type)'"=="product") & `r(omit)'==0 {
						local _inter
						forvalues lev=1/`r(k_names)' {
							if `lev'!=`r(k_names)' local _inter "`_inter'`r(op`lev')'.`r(name`lev')'#"
							else local _inter "`_inter'`r(op`lev')'.`r(name`lev')'"
						}
						local _`l'_tempnames "`_`l'_tempnames' `_inter'"
						local _`l'_ntemp "`_`l'_ntemp' `:word `_var' of `_`l'_temp''"
					}
				}
				*** Remove duplicate names (Notice that collinear regressor other than fv base levels are removed later)
				local _`l'_names: list uniq _`l'_tempnames
				*** Update fvars components after fv parsing
				local `l' "`_`l'_ntemp'"
			}
		}
	}


	*** Test for missing values in dependent and independent variables
	local __check_missing "`lhs' `rhs' `ivarlag'"
  	egen _hetsar_missing_obs=rowmiss(`__check_missing') if `touse'
  	quietly sum _hetsar_missing_obs if `touse'
  	drop _hetsar_missing_obs
  	local nobs=r(N)
  	local nmissval=r(sum)

  	if `nmissval' > 0 {
    	display as error "Error - the panel data must be strongly balanced with no missing values"
    	error 198
  	}

	// Parse VCV
	if "`detailed'"!="" {
		if "`robust'"!="" {
        	local vcetype "Robust"
			local crittype "negative log-pseudolikelihood"
    	}
		else if "`robust'"=="" {
			local vcetype "oim"
			local crittype "negative log-likelihood"
		}
	}
	else {
		local vce "mg"
		local crittype "negative log-likelihood"
	}

	if regexm("`vce'", "clust") {
		di as error "vce(cluster ...) is not allowed"
		error 198
	}

	*** Remove collinearity
	if "`rhs'"!="" {
		_rmcollright `rhs' if `touse' [`weight' `__equal' `exp'], `noconstant'
		local rhs "`r(varlist)'"
		if "`ivarlag'"!="" {
			_rmcollright `ivarlag' if `touse' [`weight' `__equal' `exp'], `noconstant'
			local ivarlag "`r(varlist)'"
		}
	}

	if `fvops'==0 {
		local _rhs_names "`rhs'"
		local _ivarlag_names "`ivarlag'"
	}

	// Create some locals
	// if constant term is needed
	if "`noconstant'"=="" {
		local cons 1
		local nocons
		local _cons _cons
	}
	else {
		local cons 0
		local nocons noconstant
		local _cons
	}


	// Sort spatial data by cross-section
	sort `temp_t' `temp_id'

	// Collect data
	// Put them in _hetsar_bag()
	m r = _hetsar_getdata("`temp_id'", "`temp_t'", "`lhs'", "`rhs'", "`ivarlag'", "`touse'", `_wmat', `cons', "`dyny'", "`dynwy'", "`dynx'", "`dynwx'", "`dconstraints'",  "`weight'", "`exp'", "`save'")

	if "`dyny'`dynwy'`dynx'`dynwx'"!="" {
		// markout touse if dynamic
		// This is needed for correct final esample and predict
		qui xtset
		tempvar lagy
		qui gen `lagy' = l.`lhs'
		markout `touse' `lagy'
		drop `lagy'
	}

	// Naming of coeffs in the estimated vector
	loc __n = __n
	loc __k = __k
	if "`detailed'"!="" {
		forv i = 1/`__n' {
			loc hetcoeffs "`hetcoeffs' `id'`i'"
			// These are coleqs
			local Wy "`Wy' Wy"
			local Alpha "`Alpha' Alpha"
			if "`dyny'"!="" local y_1 "`y_1' l.y"
			if "`dynwy'"!="" local Wy_1 "`Wy_1' l.Wy"

			/*if "`dynamic'" != "" local X_1 "`X_1' X_1"
			if "`dynamic'" != "" local WX "`WX' WX"
			if "`dynamic'" != "" local WX_1 "`WX_1' WX_1"*/
			local sigmasq "`sigmasq' Sigmasq"
		}
		if `cons'==0 local Alpha ""

		// These are coleqs
		foreach v of local _rhs_names {
			forv i = 1/`__n' {
				local X "`X' `v'"
			}
		}
		if "`ivarlag'"!="" {
			// These are coleqs
			foreach v of local _ivarlag_names {
				forv i = 1/`__n' {
					if regexm("`v'", "\.") local DX "`DX' `=subinstr("`v'", ".", ".W", .)'"
					else local DX "`DX' W`v'"
				}
			}
		}

		if "`dynx'" != "" | "`dynwx'" != "" {
			// These are coleqs
			if "`dynx'"!="" {
				foreach v of local _rhs_names {
					forv i = 1/`__n' {
						if regexm("`v'", "\.") local X_1 "`X_1' `=subinstr("`v'", ".", "l.", .)'"
						else local X_1 "`X_1' l.`v'"
					}
				}
			}
			if "`dynwx'"!="" {
				// These are coleqs
				foreach v of local _ivarlag_names {
					forv i = 1/`__n' {
						if regexm("`v'", "\.") local DX_1 "`DX_1' `=subinstr("`v'", ".", "l.W", .)'"
						else local DX_1 "`DX_1' l.W`v'"
					}
				}
			}
		}

		forv kk = 1/`__k' {
			local _colnames "`_colnames' `hetcoeffs'"
		}

		if "`dyny'"=="" loc y_1
		if "`dynx'"=="" loc X_1
		if "`dynwy'"=="" loc Wy_1
		if "`dynwx'"=="" loc DX_1
		loc _eqnames "`Wy' `Alpha' `y_1' `Wy_1' `X' `DX' `X_1' `DX_1' `sigmasq'"
		*noi di "`_eqnames'"
	}
	else {
		if "`save'"!="" {
			forv i = 1/`__n' {
				loc _save_hetcoeffs "`_save_hetcoeffs' `id'`i'"
				// These are coleqs
				local _save_Wy "`_save_Wy' Wy"
				local _save_Alpha "`_save_Alpha' Alpha"
				if "`dyny'"!="" local _save_y_1 "`_save_y_1' l.y"
				if "`dynwy'"!="" local _save_Wy_1 "`_save_Wy_1' l.Wy"

				/*if "`dynamic'" != "" local X_1 "`X_1' X_1"
				if "`dynamic'" != "" local WX "`WX' WX"
				if "`dynamic'" != "" local WX_1 "`WX_1' WX_1"*/
				local _save_sigmasq "`_save_sigmasq' Sigmasq"
			}
			if `cons'==0 local _save_Alpha ""

			// These are coleqs
			foreach v of local _rhs_names {
				forv i = 1/`__n' {
					local _save_X "`_save_X' `v'"
				}
			}
			if "`ivarlag'"!="" {
				// These are coleqs
				foreach v of local _ivarlag_names {
					forv i = 1/`__n' {
						if regexm("`v'", "\.") local _save_DX "`_save_DX' `=subinstr("`v'", ".", ".W", .)'"
						else local _save_DX "`_save_DX' W`v'"
					}
				}
			}

			if "`dynx'" != "" | "`dynwx'" != "" {
				// These are coleqs
				if "`dynx'"!="" {
					foreach v of local _rhs_names {
						forv i = 1/`__n' {
							if regexm("`v'", "\.") local _save_X_1 "`_save_X_1' `=subinstr("`v'", ".", "l.", .)'"
							else local _save_X_1 "`_save_X_1' l.`v'"
						}
					}
				}
				if "`dynwx'"!="" {
					// These are coleqs
					foreach v of local _ivarlag_names {
						forv i = 1/`__n' {
							if regexm("`v'", "\.") local _save_DX_1 "`_save_DX_1' `=subinstr("`v'", ".", "l.W", .)'"
							else local _save_DX_1 "`_save_DX_1' l.W`v'"
						}
					}
				}
			}

			forv kk = 1/`__k' {
				local _save_colnames "`_save_colnames' `_save_hetcoeffs'"
			}

			if "`dyny'"=="" loc _save_y_1
			if "`dynx'"=="" loc _save_X_1
			if "`dynwy'"=="" loc _save_Wy_1
			if "`dynwx'"=="" loc _save_DX_1
			loc _save_eqnames "`_save_Wy' `_save_Alpha' `_save_y_1' `_save_Wy_1' `_save_X' `_save_DX' `_save_X_1' `_save_DX_1' `_save_sigmasq'"
		}

		if "`dyny'"!="" loc y_1 "l.y"
		if "`dynwy'"!="" loc Wy_1 "l.Wy"

		foreach v of local _rhs_names {
			if regexm("`v'", "\.") local X_1 "`X_1' `=subinstr("`v'", ".", "l.", .)'"
			else local X_1 "`X_1' l.`v'"
		}
		if "`dynx'"=="" local X_1

		if "`ivarlag'"!="" {
			foreach v of local _ivarlag_names {
				if regexm("`v'", "\.") local DX "`DX' `=subinstr("`v'", ".", ".W", .)'"
				else local DX "`DX' W`v'"
				if "`dynwx'"!="" {
					if regexm("`v'", "\.") local DX_1 "`DX_1' `=subinstr("`v'", ".", "l.W", .)'"
					else local DX_1 "`DX_1' l.W`v'"
				}
			}
		}
		if "`dynwx'"==""  local DX_1

		local _colnames "Wy `_cons' `y_1' `Wy_1' `_rhs_names' `DX' `X_1' `DX_1' sigmasq"
	}


	// Collect user-defined starting values
	// Put them in _hetsar_sv()
	tempname init_theta
	if "`from'" != "" {
		local arg `from'
		`vv' _mkvec `init_theta', from(`arg') /*colnames(`_colfullnames')*/ error("from()")
	}
	else m st_matrix("`init_theta'", J(1,`=`__k'*`__n'',0))

	local _params_list "init_theta"
	scalar np = wordcount("`_params_list'")
	/// This struct has been used in the case of multiparameters/equations
	/// Structure definition for initialisation
	m s = J(1, st_numscalar("np"), _hetsar_sv())
	local pp 1
	foreach p of local _params_list {
		m s = _hetsar_getsv("``p''", `pp', s)
		//m liststruct(s)
		local pp =`pp'+1
	}


	// Init options (parsing)
	local eval "_hetsar_fn"
	local evaltype "d1"
	*local evaltype "d1debug"
	if "`technique'" == "" local technique "bfgs"
	if "`difficult'" != "" local difficult "hybrid"
	scalar iter = `iterations'
	scalar ptol = `tolerance'
	scalar vtol = `ltolerance'
	scalar nrtol = `nrtolerance'

	// Collect init options
	// Put them in _hetsar_init()
	m i = _hetsar_init_opt()
	//m liststruct(i)

	// Collect post options
	// Put them in _hetsar_post()
	m p = _hetsar_post_anc()
	//m liststruct(p)

	// QML estimation
	m M = _hetsar_est(r, s, i, p)

	// Assign names to sensible objects
	mat colnames _theta = `_colnames'
	mat colnames _Vtheta = `_colnames'
	mat rownames _Vtheta = `_colnames'
	if "`detailed'"!="" {
		mat coleq _theta = `_eqnames'
		mat coleq _Vtheta = `_eqnames'
		mat roweq _Vtheta = `_eqnames'
	}

	// Post RESULTS
	ereturn post _theta _Vtheta, depname(`lhs') esample(`touse')

	// Scalars
	ereturn scalar N_g = __n
	ereturn scalar N = __N
	ereturn scalar T = __T
	if "`detailed'"=="" {
		ereturn scalar k_mg = `__k'
		ereturn scalar mean_group = 1
	}
	ereturn scalar k = `__k'*`__n'
	ereturn scalar converged = __converged
	ereturn scalar iterations = __iter
	ereturn scalar ll = __ll

	// Locals
	ereturn local cmd "hetsar"
	ereturn local predict "hetsar_p"
	ereturn local vcetype "`vcetype'"
	ereturn local vce "`vce'"

	di ""
	if "`dyny'`dynwy'`dynx'`dynwx'"!="" {
		loc dyntit "Dynamic "
		eret scalar dynamic = 1
	}
	else eret scalar dynamic = 0
	loc title "`dyntit'SAR model with heterogenous coefficients"
	_coef_table_header, ti(`title')
	if "`detailed'"=="" di in yel "Mean-group estimator"
	_coef_table

	_scalar_Destructor __iter __ll __T __N __converged iter np __n __k ptol vtol nrtol

	//m liststruct(r)
	_struct_Destructor M i p s

	if "`save'"!="" {
		if "`_note_'"!="" di ""
		gettoken savename saveopt: save, parse(",")
		if "`savename'" == "" | "`savename'" == "," {
			di as error "Missing filename in option save()."
			exit 198
		}
		_hetsar_ParseSAVE `saveopt'
		local save_replace "`s(save_replace)'"

		loc _k_det = rowsof(__save_result)
		tempname __save_result
		mat `__save_result' = __save_result
		if "`detailed'"=="" {
			mat rownames `__save_result' = `_save_colnames'
			mat roweq `__save_result' = `_save_eqnames'
		}
		else {
			mat rownames `__save_result' = `_colnames'
			mat roweq `__save_result' = `_eqnames'
		}
		mat drop __save_result
		_hetsar_mat2csv, mat(`__save_result') saving(`"`savename'"') `save_replace'

	}

	** This deletes _hetsar_ParseSAVE macros
	cap sreturn clear

end

/* ****************** */
/* Ancillary programs */
/* ****************** */

program define _hetsar_ParseSAVE, sclass
	syntax [, REPLACE ]

	if "`replace'"!="" sret local save_replace "`replace'"

end

/* ****************** */

program define ParseDynamic
	args returmac returmac1 returmac2 returmac3 colon dyn

	local 0 ", `dyn'"
	syntax [, X Y WY WX ]

	local wc : word count `x' `y' `wy' `wx'

	if `wc' == 0 {
		di as error "Option timelag() is misspecified."
		exit 198
	}
	else {
		c_local `returmac' "`x'"
		c_local `returmac1' "`wx'"
		c_local `returmac2' "`y'"
		c_local `returmac3' "`wy'"
	}

end

/* ****************** */

prog define _scalar_Destructor
syntax namelist

 foreach nn of local namelist {
	 sca drop `nn'
 }

end

/* ****************** */

prog define _struct_Destructor
syntax namelist

 foreach nn of local namelist {
	 m mata drop `nn'
 }

end

/* ****************** */

** This is adapted from the mat2csv.ado file by Johannes F. Schmieder
program define _hetsar_mat2csv
version 9
syntax , Matrix(name) SAVing(str) [ REPlace APPend Title(str) SUBTitle(str) Format(str) NOTe(str) SUBNote(str) ROWlabels(string asis)]
* if "`format'"=="" local format "%10.0g"
local formatn: word count `format'
local saving: subinstr local saving "." ".", count(local ext)
if !`ext' local saving "`saving'.csv"

tempname myfile
loc saving = trim("`saving'")
if "`replace'"!="" cap erase "`saving'"
file open `myfile' using "`saving'", write text `append'

local nrows=rowsof(`matrix')
local ncols=colsof(`matrix')

_hetsar_mat2csvQuotedFullnames `matrix' row
_hetsar_mat2csvQuotedFullnames `matrix' col

local colnames "Coef_name Coef Std_err"

if `"`rowlabels'"'!="" {
  local rownames `rowlabels'
}

if "`title'"!="" {
        file write `myfile' `"="`title'""' _n
}
if "`subtitle'"!="" {
        file write `myfile' `"="`subtitle'""' _n
}

file write `myfile' `""'
loc i 1
foreach colname of local colnames {

        if `i'>1 file write `myfile' `","`colname'""'
		else file write `myfile' `""`colname'""'
		loc i=`i'+1
}
file write `myfile' _n
forvalues r=1/`nrows' {
        local rowname: word `r' of `rownames'
        file write `myfile' `""`rowname'""'
        forvalues c=1/`ncols' {
                if `c'<=`formatn' local fmt: word `c' of `format'
		  file write `myfile' `","'
                file write `myfile' `fmt' (`matrix'[`r',`c'])
		  file write `myfile' `""'
        }
        file write `myfile' _n
}
if "`note'"!="" {
file write `myfile' `"="`note'""' _n
}
if "`subnote'"!="" {
file write `myfile' `"="`subnote'""' _n
}
file close `myfile'
end

/* ****************** */

** This is taken from the mat2csvQuotedFullnames program by Johannes F. Schmieder
program define _hetsar_mat2csvQuotedFullnames
        args matrix type
        tempname extract
        local one 1
        local i one
        local j one
        if "`type'"=="row" local i k
        if "`type'"=="col" local j k
        local K = `type'sof(`matrix')
        forv k = 1/`K' {
                mat `extract' = `matrix'[``i''..``i'',``j''..``j'']
                local name: `type'names `extract'
                local eq: `type'eq `extract'
                if `"`eq'"'=="_" local eq
                else local eq `"`eq':"'
                local names `"`names'`"`eq'`name'"' "'
        }
        c_local `type'names `"`names'"'
end

exit

* version 1.0.0 - 3sep2020 - start up
* version 1.0.1 - 17feb2021 - first sharable version allowing for dynamic model. Only Stata matrices are allowed.
* version 1.1.0 - 21mar2021 - durbin and dynamic models can now be estimated. Stata matrices, spmat and spmatrix objects are allowed. MG estimator coded. Still d1 evaluator.
* version 1.1.1 - 26may2021 - Corrected a bug affecting the computation of the MG estimator's VCV, and allowed the use of the command from Stata 11 onwards.
* version 1.1.2 - 22jun2021 - Solved a bug preventing the estimation of the model without covariates (thanks to Kit). New options added: -dconstraints- allows to set box constraints [-0.95, 0.95] for the parameters of l.y and l.Wy (the time lag of y and the time/spatial lag of y). The new option -timelag()- substitutes the option dynamic. -timelag()- has 4 args: y, wy, x, wx. They are not mutually exclusive and allows to get a specific dynamic/distributed lags model specification.
* version 1.1.3 - 14jul2021 - -dconstraints- has been substituted by -nodconstraints-. From now-on the user needs to specify -nodconstraints- if she doesn't want to contraint the parameters related to l.y and l.Wy in a dynamic specification. Remember, the parameters related to Wy are always constrained in [-0.95,0.95]. Added: option -save()- allows to save detailed results regardless of option -detailed-
* version 1.2.0 - 15aug2021 - Small bug fixes, most representative is the correct naming of indepvars and durb_varlist in presence of factor variables. Help files (also for postestimation) have been updated.
