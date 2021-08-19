
** Author: Federico Belotti
*! version 3.1.4 - 8apr2021
*! See the end of ado file for versioning

capture program drop outdetect
program define outdetect, rclass byable(recall, noheader) sortpreserve

syntax varlist(max=1) [if] [in] [pw aw/] [, ///
							REWeight ///
							noZero noNegative ///
							REPLACE noGenerate ///
						    NORMalize(string) BESTnormalize SEEBEST ///
							OUTliers(string) Graph(string) EXCEL(string)  ///
						    ZSCORE(string) PLINE(string) ///
						    noPERCent Alpha(real 3) MADFactor(real 1.4826022) SFormat(string) IFormat(string) ///
						    SFactor(real 1.1926) QFactor(real 2.2219) ///
						    NOI FORCE FORCEFraction(real 0.5) TIMER ]

version 15


loc cutoff `alpha'
if "`timer'"!="" timer clear
if "`timer'"!="" timer on 1

loc working_version 1

*** Set formats for table display
if "`sformat'"=="" loc sfmt %9.2f
else loc sfmt "`sformat'"
if "`iformat'"=="" loc ifmt %9.4f
else loc ifmt "`iformat'"

if "`replace'"!="" & "`generate'"!="" {
	di as error "replace and nogenerate options are mutually exclusive"
	error 198
}

/*
capt findfile erepost.ado
if _rc {
	di in yel "Installing dependence: package -erepost- ...", _cont
    qui ssc install erepost
    di in gre "done"
}
*/

capt findfile lmoremata.mlib
if _rc {
	di in yel "Installing dependence: package -moremata- ...", _cont
    qui ssc install moremata
    di in gre "done"
}

*** Get sample of interest
marksample touse

*** From now-on j contains the varname
local j "`varlist'"

**********************************
***** Parsing of svy settings ****
**********************************

tempvar wvar
loc svyyes 0
loc weightyes 0
qui svyset
if ("`r(wvar)'"!="" & "`weight'"=="") | ///
   ("`r(wvar)'"!="" & "`weight'"!="") ///
 {
	if ("`r(wvar)'"!="" & "`weight'"!="") {
		di in gr "Warning: survey settings are currently specified via {help svyset}.
		di _col(10) in gr "Option {help weight} is ignored."
	}
	loc svyyes 1
	loc wvar_name "`r(wvar)'"
	qui gen double `wvar'=`r(wvar)' if `touse'
	loc weight_type "`r(wtype)'"
	if "`r(strata1)'"!="" loc _strata "`r(strata1)'"
	if "`r(strata2)'"!="" {
		di as error "outdetect cannot handle multiple-stage sampling designs."
		error 198
	}
}
else if "`r(wvar)'"=="" & "`weight'"!="" {
	qui clonevar `wvar'=`exp' if `touse'
	loc weight_type "`weight'"
	loc wvar_name "`exp'"
	loc weightyes 1
}
else if "`r(wvar)'"=="" & "`weight'"=="" {
	qui gen byte `wvar'= 1 if `touse'
	loc weight_type ""
}

*****************************************
******** Parsing of normalization *******
*****************************************

ParseNorm normalize : `"`normalize'"'

************************************
******** Parsing of outliers *******
************************************

ParseOut _out_type : `"`outliers'"'

**********************************
******** Parsing of bysort *******
**********************************

if "`_byvars'"!="" {
	loc _nby: word count `_byvars'
	if `_nby'>1 {
		noi di as error "Only one byvariable is allowed"
		error 198
	}
	else {
		qui levelsof `_byvars' /*if `touse'*/
		*noi di "`r(levels)'"
		loc levels_by "`r(levels)'"
		di in smcl as text "{hline `=c(linesize)-1'}"
		loc _byind = _byindex()
		loc _bylev :word `_byind' of `levels_by'
		di as text "-> `_byvars' = `_bylev'"
	}
}

**********************************
***** Parsing of graph() *********
**********************************

gettoken graph gph_options : graph, parse(",")
ParseG, `graph'
** Get s(macros) from parsing
if "`s(itc)'"!="" loc _itc_trim_extent `s(itc)'
if "`s(qqplot)'"!="" loc _qqplot "`s(qqplot)'"
if "`s(plinevar)'"!= "" local _g_plinevar "`s(plinevar)'"
if "`_g_plinevar'"=="" local _g_plinevar 0
if "`s(pline)'"!="" loc _g_pline "`s(pline)'"
if "`s(_table_note)'"!= "" local _g_table_note "`s(_table_note)'"
if "`s(itc_stat)'"!= "" local _itc_stat "`s(itc_stat)'"
if "`s(itc_abs)'"!= "" local _itc_abs "`s(itc_abs)'"
if "`_itc_abs'"=="abs" local _itc_abs 1
else local _itc_abs 0

***********************************************
****** Parsing of method() and zscore() *******
***********************************************

gettoken stat1 stat2: zscore
ParseLoc loc : `"`stat1'"'
ParseMeth method : `"`stat2'"'

/**********************************
***** Parsing of dplotopt() ******
**********************************
** Make backup of touse due to the synatx below
loc back_touse `touse'

gettoken path_and_name ploptions: dplotopt, parse(",")
loc path_and_name = strtrim("`path_and_name'")
loc ploptions = subinstr("`ploptions'", ",", "",.)
loc 0 `", `ploptions'"'
syntax [, KDENSity QNorm GScheme(string) COMBINE REPLACE KDOPTions(string) QNOPTions(string) ]

if "`dplotopt'"!="" & "`kdensity'" == "" & "`qnorm'" == "" {
	di as error "At least one between -kdensity- and -qnorm- must be specified"
	error 198
}

if "`combine'"!="" & !("`kdensity'" == "" & "`qnorm'" == "") {
	di as error "-combine- requires both -kdensity- and -qnorm- options"
	error 198
}

if "`timer'"!="" timer off 1

** Get back the touse
loc touse `back_touse'
*/



if "`_itc_trim_extent'" == "" {

	/* Initialize _out variable */
	/* Check before if -clear- has been specified */
	cap confirm v _out`_bylev', exact
	if _rc == 0 & "`replace'"=="" & "`generate'"=="" {
		di as error "_out variable altready exists. Use the " in yel "replace " as error "or the " in yel "nogenerate" as error " options"
		exit 198
	}
	else if _rc == 0 & "`replace'"!="" {
		cap drop _out`_bylev'
		tempvar _out`_bylev'
		qui gen byte `_out`_bylev'' = .
	}
	else if _rc == 0 & "`generate'"!=""{
		tempvar _out`_bylev'
		qui gen byte `_out`_bylev'' = .
	}
	else if _rc != 0 {
		tempvar _out`_bylev'
		qui gen byte `_out`_bylev'' = .
	}

	// Give warnings on data here
	// Also implement nozero and nonegative options
	qui count if missing(`j')==1
	if `r(N)'>0 di in gr "Warning: `j' has `r(N)' missing value(s)."

	qui count if `j'==0
	loc AreThereZeroValues `r(N)'
	if `r(N)'>0 & "`zero'" == "" di in gr "Warning: `j' has `r(N)' zero values. Used in calculations."
	else if (`r(N)'>0 & "`zero'" != "") {
		di in gr "Warning: `j' has `r(N)' zero values. NOT used in calculations."
		*** Update touse variable to discard zero values
		tempvar touseup
		qui gen `touseup'=1
		qui replace `touseup' = . if `j'==0
		markout `touse' `touseup'
	}

	qui count if `j'<0 & missing(`j')==0
	loc AreThereNegValues `r(N)'
	if `r(N)'>0 & "`negative'" == "" di in gr "Warning: `j' has `r(N)' negative value(s). Used in calculations."
	else if (`r(N)'>0 & "`negative'" != "") {
		di in gr "Warning: `j' has `r(N)' negative value(s). NOT used in calculations."
		*** Update touse variable to discard zero values
		tempvar touseup
		qui gen `touseup'=1
		qui replace `touseup' = . if `j'<0 & missing(`j')==0
		markout `touse' `touseup'
	}

	if "`weight_type'"!="" {
		qui count if missing(`wvar')==1
		if `r(N)'>0 {
			di in gr "Warning: `wvar_name' has `r(N)' missing values. NOT used in calculations."
			*** Update touse variable to discard missing wgt values
			tempvar touseup
			qui gen `touseup'=1
			qui replace `touseup' = . if missing(`wvar')==1
			markout `touse' `touseup'
		}
	}

	mata: _hhb_MADn("`j'","`touse'",`madfactor',0,"`weight_type'","`wvar'")
	if `_meth_value_'==0 & "`force'" == "" {
		di as error "MAD/S/Q of `j' are equal to 0. 50% or more of the observations have the same value."
		di as error "Use option -force- to exclude the block of duplicate values which are causing the issue."
		error 198
	}
	else if `_meth_value_'>0 & "`force'" == "" {
		tempvar tag
		qui duplicates tag `j' if `touse', gen(`tag')
		sum `tag' if `touse', mean
		loc __max__ = r(max)+1
		loc __n__ = r(N)
		loc __frac__ = `__max__'/`__n__'*100

		if `__frac__'>30 {
			di in yel "Warning: `j' has more than 30% (" %4.2f `__frac__' "%) obs duplicated ..."
			di in yel "You can use option -forcefraction(#)- to exclude the block of duplicate values for detection purposes."
		}

		if `__frac__'>`=`forcefraction'*100' {
		di as result "You are forcing by excluding " %4.2f `__frac__' "% duplicate values for detection purposes."
		tempvar tag
		qui duplicates tag `j' if `touse', gen(`tag')
		sum `tag' if `touse', mean
		loc __core_duplicates__ = r(max)
		tempvar __mark_duplicates__
		qui gen `__mark_duplicates__' = 0 if `touse'
		qui replace `__mark_duplicates__'=. if `touse' & `tag'==`__core_duplicates__'
		qui markout `touse' `__mark_duplicates__'


		}

	}
	else if `_meth_value_'==0 & "`force'" != "" {
		di as result "MAD/S/Q of `j' are equal to 0. 50% or more of the observations have the same value."
		di as result "You are forcing by excluding the block of duplicate values which are causing the issue."
		tempvar tag
		qui duplicates tag `j' if `touse', gen(`tag')
		sum `tag' if `touse', mean
		loc __core_duplicates__ = r(max)
		tempvar __mark_duplicates__
		qui gen `__mark_duplicates__' = 0 if `touse'
		qui replace `__mark_duplicates__'=. if `touse' & `tag'==`__core_duplicates__'
		qui markout `touse' `__mark_duplicates__'
	}

/// QUIETLY FROM NOW ON
	qui {

	/// Get original label of the variable of interest
	loc lab_`j': var lab `j'

	/// Compute welfare indicators (pre-detection)

	/// For all other computation use data from _out_getdata()
	noi m _od = _out_getdata("`j'", "`wvar'", "`weight_type'", "`touse'")

	// Here the gini function needs to stay on its own due to the sort, stable
	// Actually we pass the _od structure to collect info
	// that can be used in subsequent functions
	preserve
	sort `j', stable
	noi m _od = _out_gini("`j'", "`wvar'", "`weight_type'", "`touse'", _od, "no")
	restore

	// Compute MLD family of indicators
	noi m _out_MLD(_od, 0, "no")
	sca _out_mld0 = _out_mld
	noi m _out_MLD(_od, 1, "no")
	sca _out_mld1 = _out_mld
	noi m _out_MLD(_od, 2, "no")
	sca _out_mld2 = _out_mld

	// Compute Atkinson's indicators
	noi m _out_Atkinson(_od, 0.125, "no")
	sca _out_atk125 = _out_atk
	noi m _out_Atkinson(_od, 1, "no")
	sca _out_atk1 = _out_atk
	noi m _out_Atkinson(_od, 2, "no")
	sca _out_atk2 = _out_atk

	// Compute quantile and share ratios indicators
	noi m _out_perc_shares(_od, 0.9, 0.1, "no")

	// Compute other base stats
	noi m _od = _out_other_stats(_od, "no")

	// Compute poverty indicators if required
	if "`pline'"!="" {
		cap confirm v `pline', exact
		if _rc!=0 {
			loc _povmata _out_pov
			loc _table_note "Poverty line: `pline'"
		}
		else {
			loc _povmata _out_povv
			qui sum `pline'
			if `r(sd)' == 0 loc _table_note "Poverty line: `r(mean)' (`pline')"
			else loc _table_note "Poverty line: `pline'"
		}
		noi m `_povmata'(_od, 0, "`pline'", "no")
		sca _out_hc = _out_pov
		noi m `_povmata'(_od, 1, "`pline'", "no")
		sca _out_pg = _out_pov
		noi m `_povmata'(_od, 2, "`pline'", "no")
		sca _out_pg2 = _out_pov
		local pov ", _out_hc, _out_pg, _out_pg2"
		local povlab `""H" "PG" "PG2""'
		local poveqlab `""Poverty" "Poverty" "Poverty""'
	}

	**** Collect results on raw data
	#del ;
	mat __ind_pre_s`_bylev' = _out_mu, /* summary stats */
				_out_p50,
				_out_sd,
				_out_cv,
				_out_iqr;


	mat __ind_pre_ss`_bylev' = _out_gini, /* inequality */
				_out_mld0,
				_out_mld1,
				_out_mld2,
				_out_atk125,
				_out_atk1,
				_out_atk2,
				_out_dr`pov';

	mat colnames __ind_pre_s`_bylev' = "Mean" "Median" "SD" "CV" "IQR";

	mat colnames __ind_pre_ss`_bylev' = "Gini" "MLD" "Theil" "CV2" "A(0.125)" "A(1)" "A(2)" "p90/p10" `povlab';

	mat rownames __ind_pre_s`_bylev' = "Raw";
	mat rownames __ind_pre_ss`_bylev' = "Raw";
	mat coleq __ind_pre_s`_bylev' = "Summary stats" "Summary stats" "Summary stats" "Summary stats" "Summary stats";

	mat coleq __ind_pre_ss`_bylev' = "Inequality" "Inequality" "Inequality" "Inequality" "Inequality" "Inequality"
								  "Inequality" "Inequality" `poveqlab';
	#del cr

	loc todrop_and_rename 0

	if "`zero'"!="" loc AreThereZeroValues 0
	if "`negative'"!="" loc AreThereNegValues 0

	if "`bestnormalize'"!="" | "`normalize'"!="none" {
		if `AreThereNegValues' > 0 {
			if "`bestnormalize'"!="" {
				loc atransf "log asinh yj"
				noi di in gr "The best normalization will be selected among: log, asinh and yj"
			}
			else {
				if inlist("`normalize'", "log", "asinh", "yj")==0 {
					noi di as error "normalize(`normalize') cannot be used with negative value(s). Possible choices are: log, asinh, yj"
					exit 198
				}
			}
		}
		if `AreThereZeroValues' > 0 {
			if "`bestnormalize'"!="" {
				if `AreThereNegValues' == 0 {
					local atransf "log asinh sqrt yj"
					noi di in gr "The best normalization will be selected among: log, asinh, yj and sqrt"
				}
			}
			else {
				if inlist("`normalize'", "log", "asinh", "yj", "sqrt")==0 {
					noi di as error "normalize(`normalize') cannot be used with zero value(s). Possible choices are: log, asinh, sqrt, yj"
					exit 198
				}
			}
		}
	}

	if "`bestnormalize'"=="" {
		if "`normalize'"!="none" {
			tempvar jj jjj
			cap clonevar `jj'=`j'
			noi _out_normalize `jj' if `touse', transformation(`normalize') outputvar(`jjj')

			markout `touse' `jjj'
			loc todrop_and_rename 1
			loc transf "`r(transf)'"
			loc transftitle "`r(transftitle)'"
			// This is important to get into the structure _od the normalized variable
			noi m _od = _out_getdata("`jjj'", "`wvar'", "`weight_type'", "`touse'")
	 	}
		else if "`normalize'"=="none" {
			tempvar jj jjj
			clonevar `jj'=`j'
			clonevar `jjj'=`j'
			loc transftitle "none"
		}
	}
	else {

		if "`atransf'" == "" {
			local atransf "ln bcox sqrt"
			noi di in gr "The best normalization will be selected among: ln, bcox and sqrt"
		}

		noi di in gr "Finding best normalization ..."
		m _P_d_dfs = J(0,1,.)
		m _Transf = J(0,1,"")
		m _Transf_ti = J(0,1,"")
		foreach tr of local atransf  {
			tempvar jj jjj_`tr'
			cap clonevar `jj'=`j'
			noi _out_normalize `jj' if `touse', transformation(`tr') outputvar(`jjj_`tr'')
			loc see_transftitle "`r(transftitle)'"
			m _Transf_ti = _Transf_ti \ "`see_transftitle'"
			putmata `jjj_`tr'' if `touse', replace
			noi m _out_pearson_test(`jjj_`tr'')
			if "`seebest'" != "" {
				loc _P_d_df = _P_d_df
				noi di in gr "`see_transftitle'" in gr " = " in yel %4.3f `_P_d_df'
			}
			m _P_d_dfs = _P_d_dfs \ st_numscalar("_P_d_df")
			m _Transf = _Transf \ "`tr'"
		}
		noi m _out_bestnorm_sel(_P_d_dfs,_Transf,_Transf_ti)
		noi di as res "`_bestt'" in gr " is the best (Pearson/df = " %6.3f _best_p_def ")"
		tempvar jjj
		clonevar `jjj' = `jjj_`_bestt''
		local normalize "`_bestt'"

		markout `touse' `jjj'
		loc todrop_and_rename 1
		loc transf "`_bestt'"
		loc transftitle "`_bestt_ti'"
		// This is important to get into the structure _od the normalized variable
		noi m _od = _out_getdata("`jjj'", "`wvar'", "`weight_type'", "`touse'")
	}



	/// Compute required robust scale measure
	if ("`method'"=="q") noi mata: _hhb_Qn("`jjj'","`touse'",`qfactor',1,"`weight_type'","`wvar'")
	if ("`method'"=="s") noi mata: _hhb_Sn("`jjj'","`touse'",`sfactor',1,"`weight_type'","`wvar'")
	if ("`method'"=="mad") noi mata: _hhb_MADn("`jjj'","`touse'",`madfactor',1,"`weight_type'","`wvar'")


	/* ======================================================= */
	/* ======================================================= */
	/* ======================================================= */
	/* ================= OUTDETECT IN ACTION ================= */
	/* ======================================================= */
	/* ======================================================= */
	/* ======================================================= */

	*noi m liststruct(_od)
	/// Compute the z score and the _out (0,1,2) var
	noi m _out_score(_od, "`touse'", "`_out`_bylev''", "`loc'", "`method'", `cutoff', "`_out_type'")
	*noi m liststruct(_od)

	**********************************
	***** Get detection results ******
	**********************************

	count if `touse'
	loc _n_ = r(N)
	mat _out_detected`_bylev' = J(3,3,0)
	count if `_out`_bylev'' == 1 & `touse'
	mat _out_detected`_bylev'[1,1] = r(N)
	count if `_out`_bylev'' == 2 & `touse'
	mat _out_detected`_bylev'[2,1] = r(N)
	mat _out_detected`_bylev'[1,2] = _out_detected`_bylev'[1,1]/`_n_'*100
	mat _out_detected`_bylev'[2,2] = _out_detected`_bylev'[2,1]/`_n_'*100
	mat _out_detected`_bylev'[3,1] = _out_detected`_bylev'[1,1] + _out_detected`_bylev'[2,1]
	mat _out_detected`_bylev'[1,3] = _out_detected`_bylev'[1,1]/_out_detected`_bylev'[3,1]*100
	mat _out_detected`_bylev'[2,3] = _out_detected`_bylev'[2,1]/_out_detected`_bylev'[3,1]*100
	mat _out_detected`_bylev'[3,2] = _out_detected`_bylev'[3,1]/`_n_'*100
	mat _out_detected`_bylev'[3,3] = 100.0
	mat colnames _out_detected`_bylev' = "Freq." "Percent" "Share"
	mat rownames _out_detected`_bylev' = "Bottom" "Top" "Total"

/* OLD code - probably will be recovered
	if `todrop_and_rename'==1 {
		// restore original situa
		if "`generate'" != "" {
			if `_transf_replace'==1 cap drop `j'_`transf'
			clonevar `j'_`transf' = `jjj'
			label var `j'_`transf' "`lab_`j''"
			*label var `j' "`lab_`j''"
		}
	}
*/

	*loc _stats_colnames "`_stats_colnames' `j'"
	*if `=length("`j'")' > 3 loc _fmt "`_fmt' %`=length("`j'")'.`sfmt'f &"
	*else loc _fmt "`_fmt' %`=length("`j'")+3'.`sfmt'f &"

	/// Compute welfare indicators (post-detection)

	// Re-compute the weight variable according to the svy settings
	// taking into account the observations now considered as outliers

	sum `_out`_bylev'', mean
	tempvar sumwt osumwt twvar
	if `r(mean)'>0 & (`svyyes'==1 | `weightyes'==1) {
		if "`_strata'"!="" {
			bys `_strata': egen double `osumwt' = total(`wvar') if `touse' & `_out`_bylev''==0
			bys `_strata': egen double `sumwt' = total(`wvar') if `touse'
		}
		else {
			egen double `osumwt' = total(`wvar') if `touse' & `_out`_bylev''==0
			egen double `sumwt' = total(`wvar') if `touse'
		}
		gen double `twvar' = `wvar'*`sumwt'/`osumwt' if `touse' & `_out`_bylev''==0

		/// Generate post-detection weights
		if "`reweight'" != "" {
			gen double `wvar_name'_adj = `twvar'
			label var `wvar_name'_adj "Post-detection weights"
		}
	}
	else  gen double `twvar' = `wvar'


	*** Update touse variable to trim data
	tempvar touseup touse_raw
	gen `touseup'=1
	replace `touseup' = . if inlist(`_out`_bylev'',1,2)==1
	gen `touse_raw' = (`touse'==1)
	markout `touse' `touseup'

	/// For all other computation use data from _out_getdata()
	noi m _odt = _out_getdata("`j'", "`twvar'", "`weight_type'", "`touse'")

	// Here the gini function needs to stay on its own due to the sort, stable
	// Actually we pass the _od structure to collect info
	/// that can be used in subsequent functions
	preserve
	sort `j', stable
	noi m _odt = _out_gini("`j'", "`twvar'", "`weight_type'", "`touse'", _odt, "no")
	restore

	// Compute MLD family of indicators
	noi m _out_MLD(_odt, 0, "no")
	sca _out_mld0 = _out_mld
	noi m _out_MLD(_odt, 1, "no")
	sca _out_mld1 = _out_mld
	noi m _out_MLD(_odt, 2, "no")
	sca _out_mld2 = _out_mld

	// Compute Atkinson's indicators
	noi m _out_Atkinson(_odt, 0.125, "no")
	sca _out_atk125 = _out_atk
	noi m _out_Atkinson(_odt, 1, "no")
	sca _out_atk1 = _out_atk
	noi m _out_Atkinson(_odt, 2, "no")
	sca _out_atk2 = _out_atk

	// Compute quantile and share ratios indicators
	noi m _out_perc_shares(_odt, 0.9, 0.1, "no")

	// Compute other base stats
	noi m _odt = _out_other_stats(_odt, "no")

	// Compute poverty indicators (if required)
	if "`pline'"!="" {
		noi m `_povmata'(_odt, 0, "`pline'", "no")
		sca _out_hc = _out_pov
		noi m `_povmata'(_odt, 1, "`pline'", "no")
		sca _out_pg = _out_pov
		noi m `_povmata'(_odt, 2, "`pline'", "no")
		sca _out_pg2 = _out_pov
		local pov ", _out_hc, _out_pg, _out_pg2"
		local povlab `""H" "PG" "PG2""'
		local poveqlab `""Poverty" "Poverty" "Poverty""'
	}

	**** Collect results on trimmed data
	#del ;
	mat __ind_trim_s`_bylev' = _out_mu, /* summary stats */
				_out_p50,
				_out_sd,
				_out_cv,
				_out_iqr;


	mat __ind_trim_ss`_bylev' = _out_gini, /* inequality */
				_out_mld0,
				_out_mld1,
				_out_mld2,
				_out_atk125,
				_out_atk1,
				_out_atk2,
				_out_dr`pov';

	mat colnames __ind_trim_s`_bylev' = "Mean" "Median" "SD" "CV" "IQR";

	mat colnames __ind_trim_ss`_bylev' = "Gini" "MLD" "Theil" "CV2" "A(0.125)" "A(1)" "A(2)" "p90/p10" `povlab';

	mat rownames __ind_trim_s`_bylev' = "Trimmed";
	mat rownames __ind_trim_ss`_bylev' = "Trimmed";
	mat coleq __ind_trim_s`_bylev' = "Summary stats" "Summary stats" "Summary stats" "Summary stats" "Summary stats";

	mat coleq __ind_trim_ss`_bylev' = "Inequality" "Inequality" "Inequality" "Inequality" "Inequality" "Inequality"
								  "Inequality" "Inequality" `poveqlab';
	#del cr


	} /* close qui */
	/// NOISILY FROM NOW ON

	************************************
	****** Create _out if needed *******
	************************************

	if "`generate'"=="" {
			qui clonevar _out`_bylev' = `_out`_bylev''

			*** Label _out var
			if "`_bylev'"=="" label var _out "Outliers detected (zscore = `j'-`loc'/`method', `=uchar(945)'=`cutoff')"
			else label var _out`_bylev' "Outliers detected (-> `_byvars' = `_bylev', zscore = `j'-`loc'/`meth3od', `=uchar(945)'=`cutoff')"

			cap label drop _out`_bylev'
			label define _out`_bylev' 0 "No outliers" 1 "Small outliers" 2 "Large outliers"
			label values _out`_bylev' _out`_bylev'
	}

	******************************
	****** DISPLAY RESULTS *******
	******************************

	// Get fraction of outliers
	/// Display setup
	di in smcl "{hline 64}"
	di "{ul: {help outdetect} set-up}:"
	*di in smcl "{hline 64}"
	di ""
	di in yel "  Normalization: " in gr "`transftitle'"
	di in yel "  Z-score: " in gr "(x-`loc')/`method'"
	di in yel "  `=uchar(945)' = " in gr "`cutoff'"
	*di in yel "  Outliers: " in gr "`_out_type'"
	loc _out_typen "`_out_type'"
	if "`_out_type'"=="both" loc _out_typen "top and bottom"
	di in yel "  Outlier detection target: " in gr "`_out_typen'
	di _col(3) in yel "(`_n_' observations are used)"
	di ""

	/// Display tables
	di in smcl "{hline 64}"
	matlist _out_detected`_bylev', cspec(& %13s | %9.0g & %9.2f & %9.2f &) rspec(&-&-&) /*row(Outliers)*/ tind(1) title("{ul: Incidence of outliers}:") noblank

	mat __ind_pre_s`_bylev' = __ind_pre_s`_bylev''
	mat __ind_pre_ss`_bylev' = __ind_pre_ss`_bylev''
	mat __ind_trim_s`_bylev' = __ind_trim_s`_bylev''
	mat __ind_trim_ss`_bylev' = __ind_trim_ss`_bylev''
	mat __ind_s`_bylev' = __ind_pre_s`_bylev',__ind_trim_s`_bylev'
	mat __ind_ss`_bylev' = __ind_pre_ss`_bylev',__ind_trim_ss`_bylev'

	di ""
	di in smcl "{hline 64}"
	matlist __ind_s`_bylev', format(`sfmt') twidth(13) border(b) aligncolnames(center) /*row(Statistics)*/ tind(1) title("{ul: Statistics for raw and trimmed `j'}:") noblank
	*di _col(15) in smcl "{c |}" /* Here we need 13 blanks */

	matlist __ind_ss`_bylev', format(`ifmt') twidth(13) border(b) nam(r) noblank
	if "`_table_note'"!="" di as text "`_table_note'"

	*** Collect output for posting purposes
	mat __ind`_bylev' = __ind_s`_bylev' \ __ind_ss`_bylev'

	***** Here excel() option in action
	*** todo: allow excel() when by is used. Multiple sheets?
	if "`excel'"!="" {
		gettoken savename replace: excel, parse(",")
		local savename = subinstr("`savename'", " ", "", .)
		local replace = subinstr("`replace'", ",", "", .)
		local replace = strtrim("`replace'")
		m _out_excel("`savename'", "`replace'")
	}

	******************************
	******** POST RESULTS ********
	******************************

	return local cmd "outdetect"
	return mat b`_bylev' = __ind`_bylev'
	return mat out`_bylev' = _out_detected`_bylev'
	return sca alpha = `alpha'
	ret local normalization "`transf'"
	if "`bestnormalize'"!="" {
		ret scalar bestnormalize = 1
		ret scalar pearson_df = _best_p_def
	}
	else ret scalar bestnormalize = 0


	qui count if `touse_raw'==1
	return scalar N_raw = r(N)
	qui count if `touse'==1
	return scalar N_trimmed = r(N)

	if "`_qqplot'" != "" {
		if "`normalize'"!="none" loc qqplot_ti "Normalized `j'"
		else loc qqplot_ti "`j'"
		if "`gph_options'"=="" {
			loc gph_options ", yti("`qqplot_ti'") aspectratio(1) graphregion(fcolor(white)) ylab(, grid angle(360) labsi(*.8) glwidth(vthin)) ms(oh) mcol(red*1.25) rlopts(lc(black))  ytit(, si(*.8)) xlab(, grid labsi(*.8)) xtit(, si(*.8))"
		}
		qui swilk `jjj' if `touse'
		loc _test_swilk `r(p)'
		qui sfrancia `jjj' if `touse'
		loc _test_sfrancia `r(p)'
		qui sktest `jjj' if `touse'
		loc _test_sfrancia `r(P_chi2)'
		qnorm `jjj' if `touse' `gph_options' ///
		note(" " "Normality tests (p-value):" "Shapiro-Wilk: `: di %4.3f `_test_swilk''" ///
			 "Shapiro-Francia: `: di %4.3f `_test_sfrancia''" ///
			 "D'Agostino, Belanger, and D'Agostino: `: di %4.3f `_test_sfrancia''")
	}

} /* close trimming() */
else {

	tempvar touse_raw
	gen `touse_raw' = (`touse'==1)

	/* Why is this here ? muted
	// Check if MAD is 0. This is crucial.
	// If it is 0, (eventually) remove the block of duplicate values for detection purposes
	mata: _hhb_MADn("`j'","`touse'",`madfactor',0,"`weight_type'","`wvar'")
	if `_meth_value_'==0 & "`force'" == "" {
		di as error "MAD/S/Q of `j' are 0. Cannot compute robust scale measures for this variable."
		di as error "Use option -force- to exclude the block of duplicate values which are causing the issue."
		error 198
	}
	else if `_meth_value_'>0 & "`force'" == "" {
		tempvar tag
		qui duplicates tag `j' if `touse', gen(`tag')
		sum `tag' if `touse', mean
		loc __max__ = r(max)+1
		loc __n__ = r(N)
		loc __frac__ = `__max__'/`__n__'*100

		di as result "`j' has " %4.2f `__frac__' "% obs duplicated ..."
	}
	else if `_meth_value_'==0 & "`force'" != "" {

		tempvar tag
		qui duplicates tag `j' if `touse', gen(`tag')
		sum `tag' if `touse', mean
		loc __core_duplicates__ = r(max)
		tempvar __mark_duplicates__
			gen `__mark_duplicates__' = 0 if `touse'
			replace `__mark_duplicates__'=. if `touse' & `tag'==`__core_duplicates__'
			markout `touse' `__mark_duplicates__'
	}
	*/

	// Give warnings on data here
	// Also implement nozero and nonegative options
	qui count if missing(`j')==1
	if `r(N)'>0 di in gr "Warning: `j' has `r(N)' missing value(s)."

	qui count if `j'==0
	if `r(N)'>0 & "`zero'" == "" di in gr "Warning: `j' has `r(N)' zero values. Used in calculations."
	else if (`r(N)'>0 & "`zero'" != "") {
		di in gr "Warning: `j' has `r(N)' zero values. NOT used in calculations."
		*** Update touse variable to discard zero values
		tempvar touseup
		qui gen `touseup'=1
		qui replace `touseup' = . if `j'==0
		markout `touse' `touseup'
	}

	qui count if `j'<0 & missing(`j')==0
	if `r(N)'>0 & "`negative'" == "" di in gr "Warning: `j' has `r(N)' negative value(s). Used in calculations."
	else if (`r(N)'>0 & "`negative'" != "") {
		di in gr "Warning: `j' has `r(N)' negative value(s). NOT used in calculations."
		*** Update touse variable to discard zero values
		tempvar touseup
		qui gen `touseup'=1
		qui replace `touseup' = . if `j'<0 & missing(`j')==0
		markout `touse' `touseup'
	}

	if "`weight_type'"!="" {
		qui count if missing(`wvar')==1
		if `r(N)'>0 {
			di in gr "Warning: `wvar_name' has `r(N)' missing values. NOT used in calculations."
			*** Update touse variable to discard missing wgt values
			tempvar touseup
			qui gen `touseup'=1
			qui replace `touseup' = . if missing(`wvar')==1
			markout `touse' `touseup'
		}
	}

	/// QUIETLY FROM NOW ON
		qui {

	/// Compute welfare indicators (pre-detection)

	/// Here we need to sort stable for gini se computation
	/// Only Gini computations have their own data input strategy
	/// For all other computation use data from _out_getdata()
	noi m _od = _out_getdata("`j'", "`wvar'", "`weight_type'", "`touse'")

	// Here the trimiming() function needs to stay on its own due to the sort, stable needed for gini
	// Actually we pass the _od structure to collect info
	// that can be used in subsequent functions though. Think about adding Atkinson and other indicators

	/// Move out top extreme values
	preserve
	sort `j', stable
	tempvar sort_index
	gen `sort_index' = _n if `touse'
	gsort -`sort_index'

	noi m  _top_extremes = _out_trimming("`j'", "`wvar'", "`weight_type'", "`touse'", _od, "no", `_itc_trim_extent', "`sort_index'", "`_itc_stat'", `_itc_abs', "`_g_pline'", `_g_plinevar')
	restore

	/// Move out bottom extreme values
 	preserve
	sort `j', stable
	tempvar sort_index
	gen `sort_index' = _n if `touse'

	noi m  _bottom_extremes = _out_trimming("`j'", "`wvar'", "`weight_type'", "`touse'", _od, "no", `_itc_trim_extent', "`sort_index'", "`_itc_stat'", `_itc_abs', "`_g_pline'", `_g_plinevar')
	restore

	tempvar _top_extremes _bottom_extremes _psample_t _psample_b
	getmata (`_top_extremes' `_psample_t') = _top_extremes  (`_bottom_extremes' `_psample_b') = _bottom_extremes, force


	if `_itc_abs' == 1 {
		label var `_psample_t' "Discarded observations"
		//
		if `_itc_trim_extent'<3 loc _gxlab "1(1)`_itc_trim_extent', glwidth(vthin) labsi(*.8)"
		else loc _gxlab ", glwidth(vthin) labsi(*.8)"
		loc _itc_tab_rowtitle " Discarded obs"
	}
	else {
		label var `_psample_t' "Discarded observations (%)"
		loc _gxlab ", grid glwidth(vthin) labsi(*.8)"
		loc _itc_tab_rowtitle " Discarded obs (%)"
	}

	if "`_itc_stat'" != "mean" local _mult100 "100*"
	replace `_top_extremes' = `_mult100' `_top_extremes'
	label var `_top_extremes' "Top outliers"
	replace `_bottom_extremes' = `_mult100' `_bottom_extremes'
	label var `_bottom_extremes' "Bottom outliers"



	} /* close qui */

	// Display table
	tempname do_select _top_extremes_tab _bottom_extremes_tab _itc_table round_perc itcdiff min_itcdiff

	cap gen `round_perc' = round(`_psample_t') if `_psample_t'!=.
	cap gen double `itcdiff' = abs(`_psample_t' - `round_perc') if `_psample_t'!=.
	cap bys `round_perc': egen double `min_itcdiff' = min(`itcdiff') if `_psample_t'!=.
	cap gen `do_select' = (`min_itcdiff' == `itcdiff') if `_psample_t'!=.

	mkmat `_top_extremes' if `do_select'==1, mat(`_top_extremes_tab')
	mkmat `_bottom_extremes' if `do_select'==1, mat(`_bottom_extremes_tab')

	mat _itc_table = `_bottom_extremes_tab', `_top_extremes_tab'
	mat colnames _itc_table = "Bottom" "Top"
	forv rr = 0/`_itc_trim_extent' {
		loc _ict_table_rowlab "`_ict_table_rowlab' `rr'"
	}
	mat rownames _itc_table = `_ict_table_rowlab'
	if inlist("`_itc_stat'", "mean", "gini", "theil") mat coleq _itc_table = `"`=proper("`_itc_stat'")'"' `"`=proper("`_itc_stat'")'"'
	else if inlist("`_itc_stat'", "atk0")  mat coleq _itc_table = "A(0.125)" "A(0.125)"
	else if inlist("`_itc_stat'", "atk1")  mat coleq _itc_table = "A(1)" "A(1)"
	else if inlist("`_itc_stat'", "atk2")  mat coleq _itc_table = "A(2)" "A(2)"
	else mat coleq _itc_table = `"`=upper("`_itc_stat'")'"' `"`=upper("`_itc_stat'")'"'

	// Get and adjust the table's format
	if "`_itc_stat'"!="mean" {
		gettoken sfmt_int sfmt_dec: sfmt, parse(".")
		if regexm("`sfmt_dec'", "2")==1 loc sfmt %6`sfmt_dec'
		else if regexm("`sfmt_dec'", "3")==1 loc sfmt %7`sfmt_dec'
		else if regexm("`sfmt_dec'", "4")==1 loc sfmt %8`sfmt_dec'
		*di "`sfmt'"
	}
	di ""
	matlist _itc_table, format(`sfmt') twidth(18) border(b) aligncolnames(center) /*row(Statistics)*/ tind(1) title("{ul: Incremental trimming curve for `j'}:") noblank  row("`_itc_tab_rowtitle'") showcoleq(c)

	if "`gph_options'" == "" {

		if "`_itc_stat'"=="gini" loc _ytit "Gini coefficient (%)"
		if "`_itc_stat'"=="mean" loc _ytit "Mean"
		if "`_itc_stat'"=="h" loc _ytit "Poverty headcount ratio (%)"
		if "`_itc_stat'"=="pg" loc _ytit "Poverty gap index (%)"
		if "`_itc_stat'"=="pg2" loc _ytit "Poverty gap squared index (%)"
		if "`_itc_stat'"=="mld" loc _ytit "Mean logarithmic deviation index (%)"
		if "`_itc_stat'"=="theil" loc _ytit "Theil index (%)"
		if "`_itc_stat'"=="cv2" loc _ytit "Squared coefficient of variation (%)"
		if "`_itc_stat'"=="atk0" loc _ytit "Atkinson index (%) - A(0.125)"
		if "`_itc_stat'"=="atk1" loc _ytit "Atkinson index (%) - A(1)"
		if "`_itc_stat'"=="atk2" loc _ytit "Atkinson index (%) - A(2)"

		twoway line `_top_extremes' `_bottom_extremes' `_psample_t', sort ///
			lc(red*1.25 black) lw(medthick medthick) lp(solid -) ///
			graphregion(fcolor(white)) legend(col(2) size(*.8)) ///
			ylab(,angle(h) format(%12.0gc) grid glwidth(vthin) labsi(*.8)) ///
			ytit(`_ytit', si(*.8)) ///
			xlab(`_gxlab') ///
			xtit(, si(*.8)) note("`_g_table_note'", size(*.7) span)
	}
	else {
		twoway line `_top_extremes' `_bottom_extremes' `_psample_t' `gph_options'
	}

	***** Here excel() option in action
	*** todo: allow excel() when by is used. Multiple sheets?
	if "`excel'"!="" {
		gettoken savename replace: excel, parse(",")
		local savename = subinstr("`savename'", " ", "", .)
		local replace = subinstr("`replace'", ",", "", .)
		local replace = strtrim("`replace'")
		m _out_excel("`savename'", "`replace'", "yes")
	}

	******************************
	******** POST RESULTS ********
	******************************

	return local cmd "outdetect"
	*return mat b`_bylev' = __ind`_bylev'
	return mat out = _itc_table

	qui count if `touse_raw'==1
	return scalar N_raw = r(N)

}


******************************
********* DESTRUCTOR *********
******************************

loc _mat_ "__ind_pre`_bylev' __ind_trim`_bylev' __ind`_bylev' _out_detected`_bylev' _vv _aa _itc_table __ind_ss`_bylev' __ind_s`_bylev' __ind_trim_ss`_bylev' __ind_trim_s`_bylev' __ind_pre_ss`_bylev' __ind_pre_s`_bylev'"
foreach _m of local _mat_ {
	cap matrix drop `_m'
}
loc _sca_ "_out_mu _out_p50 _out_sd _out_cv _out_iqr _out_gini _out_mld0 _out_mld1 _out_mld2 _out_atk125 _out_atk1 _out_atk2 _out_dr _out_hc _out_pg _out_pg2 _out_pov _out_atk _out_mld _out_kurt _out_skew _best_p_def _P_d_df _P_nclasses _P_df _P _q_value_ _s_value_ _kurt_ _skew_ _sd_value_ _meth_value_ _mad_value_ _out_lambda_ _converged_"
foreach _s of local _sca_ {
	cap scalar drop `_s'
}

cap mata mata drop _od
cap mata mata drop _odt
cap mata mata drop _bottom_extremes
cap mata mata drop _top_extremes

end



/* ----------------------------------------------------------------- */
/* ---------------------- Ancillary programs ----------------------- */
/* ----------------------------------------------------------------- */

program define ParseG, sclass
	syntax [, ITCccc ITC(string) QQplot * ]

	if "`itcccc'"!="" local itc "10:gini"

	if "`itc'"!="" {
		gettoken itc itc_options : itc, parse(":")
		cap confirm n `itc'
		if _rc != 0 {
			if "`itc_options'"=="" & "`itc'"!="" loc itc_options "`itc'"
			loc itc 10
		}
		if "`itc_options'"!="" local itc_options = subinstr("`itc_options'", ":", "", .)
		ParseITC, `itc_options'
	}
	if `"`options'"' != "" {
		di as error "Specified graph option is not allowed"
		exit 198
	}
	local wc : word count `itc' `qqplot'

	if `wc' > 1 {
		di as error "graph() invalid, only " /*
			*/ "one gr_type can be specified"
		exit 198
	}

	if "`itc'"!="" sret local itc = `itc'
	if "`qqplot'"!="" sret local qqplot "`qqplot'"

end

program define ParseITC, sclass
	syntax [, ABSolute Mean GIni MLD THeil CV2 ATK0 ATK1 ATK2 H PG PG2 PLINE(string) ]

	local wc : word count `mean' `gini' `mld' `theil' `cv2' `h' `pg' `pg2' `atk0' `atk1' `atk2'
	if `wc' > 1 {
		di as error "itc() invalid, only " /*
			*/ "one stat can be specified"
		exit 198
	}

	local stat `mean' `gini' `h' `pg' `pg2' `mld' `theil' `cv2' `atk0' `atk1' `atk2'
	if "`stat'"=="" local stat gini

	if inlist("`stat'", "h", "pg", "pg2")==1 {
		if "`pline'"!="" {
			cap confirm v `pline', exact
			if _rc!=0 {
				sret loc plinevar 0
				loc note_pline: di %12.0gc `pline'
				sret loc _table_note "Poverty line: `note_pline'"
				sret loc pline `pline'
			}
			else {
				sret loc plinevar 1
				qui sum `pline'
				if `r(sd)' == 0 {
					loc note_pline: di %12.0gc `r(mean)'
					sret loc _table_note "Poverty line: `r(mean)' (`pline')"
				}
				else sret loc _table_note "Poverty line: `pline'"
				sret loc pline `pline'
			}
		}
		else {
			di as error "option pline() required"
			exit 198
		}
	}
	else {
		if "`pline'"!="" {
			cap confirm v `pline', exact
			if _rc!=0 {
				sret loc plinevar 0
				loc note_pline: di %12.0gc `pline'
				sret loc _table_note "Poverty line: `note_pline'"
				sret loc pline `pline'
			}
			else {
				sret loc plinevar 1
				qui sum `pline'
				if `r(sd)' == 0 {
					loc note_pline: di %12.0gc `r(mean)'
					sret loc _table_note "Poverty line: `r(mean)' (`pline')"
				}
				else sret loc _table_note "Poverty line: `pline'"
				sret loc pline `pline'
			}
			loc stat "h"
		}
	}

	sret local itc_stat "`stat'"
	if "`absolute'"!= "" sret local itc_abs "abs"


end


/* ----------------------------------------------------------------- */

program define ParseOut
	args retmac colon outl

	local 0 ", `outl'"
	syntax [, Bottom Top Both * ]

	if `"`options'"' != "" {
		di as error "Specified outliers option is not allowed"
		exit 198
	}
	local wc : word count `bottom' `top' `both'

	if `wc' > 1 {
		di as error "outliers() invalid, only " /*
			*/ "one method can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `retmac' "both"
	}
	else c_local `retmac' `bottom' `top' `both'

end

/* ----------------------------------------------------------------- */

program define ParseLoc
	args retmac colon stat1

	local 0 ", `stat1'"
	syntax [, Mean MEDian * ]

	if `"`options'"' != "" {
		di as error "Specified method is not allowed"
		exit 198
	}
	local wc : word count `mean' `median'

	if `wc' > 1 {
		di as error "stat1 invalid, only " /*
			*/ "one method can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `retmac' "median"
	}
	else c_local `retmac' `mean' `median'

end

/* ----------------------------------------------------------------- */

program define ParseMeth
	args retmac colon stat2

	local 0 ", `stat2'"
	syntax [, Q IQR S MAD STD * ]

	if `"`options'"' != "" {
		di as error "Specified method is not allowed"
		exit 198
	}
	local wc : word count `q' `iqr' `s' `mad' `std'

	if `wc' > 1 {
		di as error "method() invalid, only " /*
			*/ "one method can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `retmac' "q"
	}
	else c_local `retmac' `q' `iqr' `s' `mad' `std'

end

/* ----------------------------------------------------------------- */

program define _out_normalize, rclass

	syntax varname [if] [in], transformation(string) outputvar(string)

	marksample touse

	tempname lambda diff

	local normalize "`transformation'"

	if "`normalize'" == "bcox" {
		cap boxcox `varlist' if `touse', iter(500)
		if _rc == 0 {
			scalar `lambda' = _b[theta:_cons]
			scalar `diff' = reldif(`lambda', 0.0)
			if (`diff' > 1e-3) {
				qui gen double `outputvar' = (`varlist'^`lambda' - 1)/`lambda'
			}
			else qui gen double `outputvar' = log(`varlist')
			local _lambda_ = `lambda'
			return scalar lambda = `lambda'
			local _ttitle "Box and Cox (1964)"
		}
		else {
			di as error "Box-cox transformation failed."
			error 430
		}
	}
	else if "`normalize'" == "yj" {
		cap _out_yj_lambda `varlist' if `touse'
		if _rc == 0 & _converged_ == 1{
			scalar `lambda' = `r(_out_lambda)'
			qui m: _out_yj_trans("`varlist'", st_numscalar("`lambda'"),"`touse'","`outputvar'")
			local _lambda_ = `lambda'
			return scalar lambda = `lambda'
			local _ttitle "Yeo and Johnson (2000)"
		}
		else {
			di as error "Yeo and Johnson transformation failed."
			error 430
		}
	}
	else if "`normalize'" == "asinh" {
		qui gen double `outputvar' = asinh(`varlist')  if `touse'
		loc _ttitle "inverse hyperbolic sine"
	}
	else if "`normalize'" == "ln" {
		qui gen double `outputvar' = ln(`varlist')  if `touse'
		loc _ttitle "natural logarithm"
	}
	else if "`normalize'" == "log" {
		qui sum `varlist' if `touse', mean
		//min_a <- max(0, -(min(x) - eps))
		local a = max(`=-(`r(min)'-0.001)',0)
		qui gen double `outputvar' = log(`varlist' + `a')  if `touse'
		loc _ttitle "ln(x + a) with a = max(0, -(min(x) - 0.0001))"
	}
	else if "`normalize'" == "log10" {
		qui sum `varlist' if `touse', mean
		//min_a <- max(0, -(min(x) - eps))
		local a = max(`=-(`r(min)'-0.001)',0)
		qui gen double `outputvar' = log10(`varlist' + `a') if `touse'
		loc _ttitle "log10(x + a) with a = max(0, -(min(x) - 0.0001))"
	}
	else if "`normalize'" == "sqrt" {
		qui sum `varlist' if `touse', mean
		//min_a <- max(0, -min(x))
		local a = max(`=-`r(min)'',0)
		qui gen double `outputvar' = sqrt(`varlist' + `a') if `touse'
		local _ttitle "Square root"
	}

	/*qui sum `outputvar'
	if `r(sd)'<0.0001 & inlist("`normalize'","yj","bcox")==1 {
		di in yel "Warning: `normalize' normalization is based on `=uchar(955)' = " %4.3f  `_lambda_'
		di in yel "         The std.dev. of the normalized variable is less than 0.0001."
	}*/

	return local transf "`normalize'"
	return local transftitle "`_ttitle'"

end

/* ----------------------------------------------------------------- */

program define ParseNorm
	args retmac colon norm

	local 0 ", `norm'"
	syntax [, LOG LOG10 LN YJ BCox ASinh Sqrt NONE * ]

	if `"`options'"' != "" {
		di as error "Specified normalization method is not allowed"
		exit 198
	}
	local wc : word count `log' `log10' `ln' `yj' `bcox' `asinh' `sqrt' `none'

	if `wc' > 1 {
		di as error "normalize() invalid, only " /*
			*/ "one normalization method can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `retmac' "yj"
	}

	else {
		if "`asinh'" == "asinh" c_local `retmac' "asinh"
		if "`ln'" == "ln" c_local `retmac' "ln"
		if "`log'" == "log" c_local `retmac' "log"
		if "`log10'" == "log10" c_local `retmac' "log10"
		if "`yj'" == "yj" c_local `retmac' "yj"
		if "`bcox'" == "bcox" c_local `retmac' "bcox"
		if "`sqrt'" == "sqrt" c_local `retmac' "sqrt"
		if "`none'" == "none" c_local `retmac' "none"
	}

end

/* ----------------------------------------------------------------- */

program define _out_yj_lambda, rclass
	version 14
	syntax varname [if] [in]

	marksample touse

	m: st_numscalar("_out_lambda_", _out_yj_lambda("`varlist'", "`touse'"))

	return scalar _converged_ = _converged_
	return scalar _out_lambda = _out_lambda_
end


exit

** version 1.0.0 - 24apr2018 - First version
** version 1.0.1 - 15may2019 - Included z-score and option ALL
							 - Now the report, when ALL is specified, reports all scores with related fractions of detected outliers
** version 1.0.2 - 16may2019 - Implemented options for percentage/fraction of outliers reporting, to control format of results
							 - The command is now byable(recall), for now just for one by variable
** version 1.1.0 - 15oct2019 - The command now allows for different transformation via the R package bestNormalize
** version 1.1.1 - 6dec2019 - Huge update: now pre and post outlier detection inequality indicators are computed and displayed, with their standard errors. weights are now allowed only via -svyset-
** version 2.0.0 - 4jan2020 - Restyling of the old ado following the new vision for outdetect.ado: no std.errs >> new table of results showing key indicators for raw and trimmed data(todo: treated (median imputation)).
** version 2.0.1 - 14jan2020 - Post results to r() and added destructor
** version 3.0.0 - 23oct2020 - New outdetect concept: only mata based function for all including normalization, standard errors in, new options.
** version 3.0.1 - 29oct2020 - Added options: nozero, nogenerate, replace, graph(). Restyling and some improvement.
** version 3.0.2 - 15nov2020 - Added options: restyled graph() options, added new indicators for the incremental trimming curve (mean, h, pg, pg2) and absolute option.
** version 3.0.3 - 7jan2021 - Bug fixed (exact option of confirm)
** version 3.0.4 - 17jan2021 - Added option "reweight" to create the post-detection adjusted weight variable
** version 3.0.4 - 17jan2021 - Added warning foir "missing" weight variable
** version 3.1.0 - 13mar2021 - Added bestnormalize option
** version 3.1.1 - 27mar2021 - Bug fixes and certifications checks
** version 3.1.2 - 4apr2021 - excel() now works also after graph(itc) and the latter produces a table with the results reported in the plot
** version 3.1.3 - 7apr2021 - Now also mld, theil and cv2 indicator can be exploited for ITC. Fixed some labels for itc plots and tables.
** version 3.1.4 - 8apr2021 - Now also Atkinson class can be exploited for ITC.
