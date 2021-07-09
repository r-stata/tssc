*! version 1.6 12sep2016 

* See end of file for version history

program define xsmle_p, sortpreserve
	
	version 10

	syntax [anything] [if] [in] [, 			   ///
			RForm 				   ///  default
			LImited 			   ///
			FUll					///
			NAive				   ///
			xb					/// /*prediction when the model is sem or gspre*/
			A            /// /* alpha_i, the fixed or random-effect */
			RFTransform(string)	/* not documented (yet) */	   ///  
			NOIE /// individual effects will be excluded from the prediction
			DIRECT ///
			INDIRECT ///
			TOTAL ///
			DIRECTLR ///
			INDIRECTLR ///
			TOTALLR ///
			]
	
	/* RFTransform documentation
	{synopt :{opt rft:ransform(real matrix T)}}user-provided (I-{it:rho}*W)^(-1){p_end}}
	{phang}
	{opt rftransform()} tells {cmd:predict} use the user-specified inverse of
	(I-{it:rho}*W).  The matrix {it:T} should reside in Mata memory.
	This option is available only with the reduced-form predictor.
	*/
	
	local vvcheck = max(10,c(stata_version))

	marksample touse 	// this is not e(sample)
	
	tempvar esample
	qui gen byte `esample' = e(sample)
	
    *** Check for panel setup                
	_xt, trequired 
	local id: char _dta[_TSpanel]
	local time: char _dta[_TStvar]
	tempvar temp_id temp_t Ti
	qui egen `temp_id'=group(`id') 
	sort `temp_id' `time'
	qui by `temp_id': g `temp_t' = _n if `touse'==1
	qui replace `temp_id' = . if `temp_t'== .
	sort `temp_id' `time'
	
	*** Count panels and original panel length (before any transformation of the data) 
	qui by `temp_id': gen long `Ti' = _N if _n==_N & `touse'==1
	qui summ `Ti' if `touse'==1, mean
	local t_orig = r(max)
	qui count if `Ti'<.
	local N_g = r(N)
	
	// Parsing of spatial weight matrices 
	
	ParseSpatMat, cwmat(`e(wmatrix)') cemat(`e(ematrix)') cdmat(`e(dmatrix)') crft(`rftransform')
	if "`r(wmatrix)'"!="" {
		local wmatrix "`r(wmatrix)'"
		local _wmatspmatobj 0
	}
	else {
		local wmatrix "`r(o_wmatrix)'"
		local _wmatspmatobj "`r(_wmatspmatobj)'"
	}
	
	if "`r(ematrix)'"!="" {
		local ematrix "`r(ematrix)'"
		local _ematspmatobj 0
	}
	else {
		local ematrix "`r(o_ematrix)'"
		local _ematspmatobj "`r(_ematspmatobj)'"
	}
	
	if "`r(dmatrix)'"!="" {
		local dmatrix "`r(dmatrix)'"
		local _dmatspmatobj 0
	}
	else {
		local dmatrix "`r(o_dmatrix)'"
		local _dmatspmatobj "`r(_dmatspmatobj)'"
	}
	
	if "`r(rftmatrix)'"!="" {
		local rftmatrix "`r(rftmatrix)'"
		local _rftmatspmatobj 0
	}
	else {
		local rftmatrix "`r(o_rftmatrix)'"
		local _rftmatspmatobj "`r(_rftmatspmatobj)'"
	}
	
	// parse anything 
	local words : word count `anything'	
	if (`words'<1 | `words'>3) {
		di "{err}invalid syntax"
		exit 198
	}
	
	// parse predict options
			
	local stat "`rform'`limited'`full'`naive'`xb'`a'`direct'`indirect'`total'`directlr'`indirectlr'`totallr'"
	local words : word count `stat'
	
	*** Parsing model
	ParseMod modtype : `"`e(model)'"'
	
	if ("`stat'"=="limited" | "`stat'"=="full") & `modtype'!=4 {
		di "{err}Limited-information predictor is not allowed after `e(model)' model"
		exit 198
	}
	if ("`stat'"!="xb" & "`stat'"!="") & (`modtype'==3 | `modtype'==5) {
		di "{err}Only X*beta predictor is allowed after `e(model)' model"
		exit 198
	}

	if `words'==0 {
		if "`e(cmd)'"=="xsmle" {		
			di "{txt}(option rform assumed)"
			local stat rform
		}
	}
	
	if `words'>1 {
		di "{err}only one statistic is allowed"
		exit 198
	}
	
	if "`a'" != "" & "`e(effects)'"=="fe" & "`e(type)'"!="ind" {
		di "{err}Fixed-effects can be post-estimated only when -type(ind)-."
		exit 198
	}
	if "`a'" != "" & "`noie'"!="" {
		di "{err}-noie- option is conflicting with the -a- option."
		exit 198
	}
	
	gettoken type pvar : anything
	if regexm("`pvar'", "__marg_pvar_") local margins 1
	else {
		local margins 0
		if inlist("`stat'","direct","indirect","total","directlr","indirectlr","totallr") == 1 {
			di as error "option -`stat'- is not allowed."
			exit 198
		}
	}
	qui generate `type' `pvar' = .
	if "`pvar'"=="" local pvar `type'
	
	if "`e(dlag)'"=="no" {
		local dlag 0
		local dlag_type 0
	}
	else {
		local dlag 1
		local dlag_type `e(dlag_type)'
	}
	
	*** Get parameters estimates
	/// Initialize and fill estimate vectors 
	tempname __b _bbeta _bbbeta _bbetaa _ttheta _tttheta _spat _rho _lambda _sigma2
	mat `__b' = e(b) 
	mat `_bbeta' = `__b'[1,"Main:"]
	mat `_bbetaa' = `_bbeta'

	if `modtype'==2 {
		mat `_ttheta' = `__b'[1,"Wx:"]
		mat `_bbetaa' = (`_bbeta',`_ttheta')
	}
	else mat `_ttheta' = J(1,colsof(`_bbeta'),0)
	if (`modtype'==1 | `modtype'==2) mat `_rho' = `__b'[1,"Spatial:"]
	if `modtype'==3 mat `_lambda' = `__b'[1,"Spatial:"]
	if `modtype'==4 {
		mat `_spat' = `__b'[1,"Spatial:"]
		mat `_rho' = `_spat'[1,1]
		mat `_lambda' = `_spat'[1,2]
	}
	if `modtype'==5 {
		mat `_spat' = `__b'[1,"Spatial:"]
		mat `_lambda' = `_spat'[1,2]
	}
	
	if `dlag' == 1 {
		tempname _tau _psi
		if `dlag_type'==1 {
			mat `_tau' = `_bbeta'[1,1]
			mat `_psi' = 0
			mat `_bbeta' = `_bbeta'[1,2...]
		}
		if `dlag_type'==2 {
			mat `_tau' = 0
			mat `_psi' = `_bbeta'[1,1]
			mat `_bbeta' = `_bbeta'[1,2...]
		}
		if `dlag_type'==3 {
			mat `_tau' = `_bbeta'[1,1]
			mat `_psi' = `_bbeta'[1,2]
			mat `_bbeta' = `_bbeta'[1,3...]	
		}
	}
	
	local _bbetanames_temp: colnames `_bbeta'
	local _n_bbetanames: word count `_bbetanames_temp'

	forvalues _name=1/`_n_bbetanames'  {

		if `vvcheck'>=11 {
			`vv_fv' _ms_parse_parts `:word `_name' of `_bbetanames_temp''
			local rtype "`r(type)'"
		}
		else local rtype "variable"
		
		if "`rtype'"=="variable" local _bbetanames "`_bbetanames' `r(name)'"		
		if "`r(type)'"=="factor" & "`r(omit)'"=="0" local _bbetanames "`_bbetanames' `r(op)'.`r(name)'"
		if ("`r(type)'"=="interaction" | "`r(type)'"=="product") & "`r(omit)'"=="0" {
			local _inter
			forvalues lev=1/`r(k_names)' {
				if `lev'!=`r(k_names)' local _inter "`_inter'`r(op`lev')'.`r(name`lev')'#"
				else local _inter "`_inter'`r(op`lev')'.`r(name`lev')'"
			}
			local _bbetanames "`_bbetanames' `_inter'"						
		}			
	}
	
	/// Check and remove constant in RE models
	local _posofcons: list posof "_cons" in _bbetanames
	if "`_posofcons'" != "0" {
		local __cons _cons
		local _bbetanames: list _bbetanames - __cons
		mat `_bbeta' = `_bbeta'[1,1..`=`_posofcons'-1']
	}
	
	if `modtype'==2 {
		local _tthetanames_temp: colnames `_ttheta'
		local _n_tthetanames: word count `_tthetanames_temp'

		forvalues _name=1/`_n_tthetanames'  {

			if `vvcheck'>=11 {
				`vv_fv' _ms_parse_parts `:word `_name' of `_tthetanames_temp''
				local rtype "`r(type)'"
			}
			else local rtype "variable"
	
			if "`rtype'"=="variable" local _tthetanames "`_tthetanames' `r(name)'"		
			if "`r(type)'"=="factor" & "`r(omit)'"=="0" local _tthetanames "`_tthetanames' `r(op)'.`r(name)'"
			if ("`r(type)'"=="interaction" | "`r(type)'"=="product") & "`r(omit)'"=="0" {
				local _inter
				forvalues lev=1/`r(k_names)' {
					if `lev'!=`r(k_names)' local _inter "`_inter'`r(op`lev')'.`r(name`lev')'#"
					else local _inter "`_inter'`r(op`lev')'.`r(name`lev')'"
				}
				local _tthetanames "`_tthetanames' `_inter'"						
			}					
		}
		
		local _what: list _bbetanames | _tthetanames
		foreach _v of local _what {
			local __posbeta: list posof "`_v'" in _bbetanames
			if "`__posbeta'"!="0" mat `_bbbeta'  = nullmat(`_bbbeta' ), `_bbeta'[1,`__posbeta']
			else mat `_bbbeta'  = nullmat(`_bbbeta' ), 0
			local __postheta: list posof "`_v'" in _tthetanames
			if "`__postheta'"!="0" mat `_tttheta' = nullmat(`_tttheta'), `_ttheta'[1,`__postheta']
			else mat `_tttheta' = nullmat(`_tttheta'), 0	
		}
		// Flag for extra Wx vars
		local _flag_NULL: list _tthetanames - _bbetanames
	}
	else {
		mat `_bbbeta' = `_bbeta'
		mat `_tttheta' = J(1,colsof(`_bbeta'),0)
		local _flag_NULL 
	}
	
	*** Sort data for the estimation of spatial panel data models
	sort `temp_t' `temp_id'
	
	mata: _xsmle_predict("`pvar'","`touse'","`esample'", "`temp_id'", "`temp_t'",`modtype',"`e(effects)'","`e(depvar)'","`e(rhsvar)'","`e(drhsvar)'",`e(noconst)', "`stat'","`rftmatrix'","`wmatrix'","`ematrix'","`dmatrix'",`dlag',`dlag_type', "`_bbetaa'","`_bbbeta'","`_tttheta'","`_rho'","`_lambda'","`_tau'","`_psi'", _FrOm_SpMaT_oBj, "`noie'", `margins', "`_flag_NULL'")

	// label new variable	
	local stat = trim("`stat'")
	if "`noie'"=="" local noie_lab " + a[`id']"
	else local noie_lab ""
	if "`stat'"=="naive" label var `pvar' "Naive prediction`noie_lab'"
	if "`stat'"=="rform" label var `pvar' "Reduced form prediction`noie_lab'"
	if "`stat'"=="limited" label var `pvar' "Limited information prediction`noie_lab'"
	if "`stat'"=="full" label var `pvar' "Full information prediction`noie_lab'"
	if "`stat'"=="xb" label var `pvar' "Linear prediction`noie_lab'"
	
	if "`stat'"=="a" & "`e(effects)'" == "fe" label var `pvar' "Fixed-effects prediction"
	if "`stat'"=="a" & "`e(effects)'" == "re" label var `pvar' "Random-effects prediction"
	
end


/* ----------------------------------------------------------------- */

program define ParseSpatMat, rclass
	syntax [, CWMATrix(string) CEMATrix(string) CDMATrix(string) CRFT(string) ]

mata: st_rclear()
ret local rcmd "ParseSpatMat"

local wmatrix `cwmatrix'
local ematrix `cematrix'
local dmatrix `cdmatrix'
local rftmatrix `crft'

// Notice that the structure has 4 columns instead of 3 for allowing the inclusion of undocumented rftmatrix 
m _FrOm_SpMaT_oBj = J(1, 4, _mata_matrices_xsmle())


if ("`wmatrix'"=="" & "`ematrix'"=="") {
	display as error "At least one of wmatrix() and ematrix() must be specified"
	error 198
}
if ("`wmatrix'" != "") {
	local n_wmatrix: word count `wmatrix'
	if `n_wmatrix'!=1 {
		display as error "Only one spatial weighting matrix `wmatrix' is allowed"
	    error 198
	}
	capture confirm matrix `wmatrix'
	local _rc_mat_assert = _rc
	if `_rc_mat_assert' != 0 {
		capture mata: SPMAT_assert_object("`wmatrix'")
		local _rc_spmat_assert = _rc
		if `_rc_spmat_assert' == 3499 {
			capt findfile spmat.ado
		    if _rc {
		        di as error "Only stata matrix and -spmat- objects are allowed as argument of -wmat()-."
				di as error "You can install -spmat- by typing {stata net install sppack}."
		        error 499
		    }
		}
		if `_rc_spmat_assert' != 0 {
			di "{inp}`wmatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		capture mata: SPMAT_check_if_banded("`wmatrix'",1)
		if _rc !=0 {
			di as error "xsmle does not support banded matrices"
			exit 498
		}
		
		tempname wmatrix_new
		capture spmat getmatrix `wmatrix' `wmatrix_new'
		if _rc {
			di "{inp}`wmatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		else {
			tempname _wmatspmatobj
			m st_numscalar("rww", rows(`wmatrix_new'))
			m st_numscalar("rcw", cols(`wmatrix_new'))
			m _FrOm_SpMaT_oBj = _GeT_FrOm_SpMaT_oBj(`wmatrix_new',1,_FrOm_SpMaT_oBj)
			//mata: st_matrix("`_wmatspmatobj'", `wmatrix_new')
			m `wmatrix_new'=.
			//local rww=rowsof(`_wmatspmatobj')
		    //local rcw=colsof(`_wmatspmatobj')
		    if rww != rcw {
			    display as error "Spatial weighting matrix `wmatrix' is not square"
			    error 198
		    }
			return local wmatrix ""
			return local o_wmatrix "`wmatrix'"
			return local _wmatspmatobj 1
		}
	}
	if `_rc_mat_assert' == 0 {
    	local rww=rowsof(`wmatrix')
    	local rcw=colsof(`wmatrix')
    	if `rww' != `rcw' {
	    	display as error "Spatial weighting matrix `wmatrix' is not square"
	    	error 198
    	}
		return local wmatrix "`wmatrix'"
	}
}

if ("`ematrix'" != "") {
	local n_ematrix: word count `ematrix'
	if `n_ematrix'!=1 {
		display as error "Only one spatial weighting matrix `ematrix' is allowed"
	    error 198
	}
	capture confirm matrix `ematrix'
	local _rc_mat_assert = _rc
	if `_rc_mat_assert' != 0 {
		capture mata: SPMAT_assert_object("`ematrix'")
		local _rc_spmat_assert = _rc
		if `_rc_spmat_assert' == 3499 {
			capt findfile spmat.ado
		    if _rc {
		        di as error "Only stata matrix and -spmat- objects are allowed as argument of -emat()-."
				di as error "You can install -spmat- by typing {stata net install sppack}."
		        error 499
		    }
		}
		if `_rc_spmat_assert' != 0 {
			di "{inp}`ematrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		capture mata: SPMAT_check_if_banded("`ematrix'",1)
		if _rc !=0 {
			di as error "xsmle does not support banded matrices"
			exit 498
		}
		
		tempname ematrix_new
		capture spmat getmatrix `ematrix' `ematrix_new'
		if _rc {
			di "{inp}`ematrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		else {
			tempname _ematspmatobj
			m st_numscalar("rww", rows(`ematrix_new'))
			m st_numscalar("rcw", cols(`ematrix_new'))
			m _FrOm_SpMaT_oBj = _GeT_FrOm_SpMaT_oBj(`ematrix_new',2,_FrOm_SpMaT_oBj)
			//mata: st_matrix("`_ematspmatobj'", `ematrix_new')
			m `ematrix_new'=.
			//local rww=rowsof(`_ematspmatobj')
		    //local rcw=colsof(`_ematspmatobj')
		    if rww != rcw {
			    display as error "Spatial weighting matrix `ematrix' is not square"
			    error 198
		    }
			return local ematrix ""
			return local o_ematrix "`ematrix'"
			return local _ematspmatobj 1
		}
	}
	if `_rc_mat_assert' == 0 {
    	local rww=rowsof(`ematrix')
    	local rcw=colsof(`ematrix')
    	if `rww' != `rcw' {
	    	display as error "Spatial weighting matrix `ematrix' is not square"
	    	error 198
    	}
		return local ematrix "`ematrix'"
	}
}

if ("`dmatrix'" != "") {
	local n_dmatrix: word count `dmatrix'
	if `n_dmatrix'!=1 {
		display as error "Only one spatial weighting matrix `dmatrix' is allowed"
	    error 198
	}
	capture confirm matrix `dmatrix'
	local _rc_mat_assert = _rc
	if `_rc_mat_assert' != 0 {
		capture mata: SPMAT_assert_object("`dmatrix'")
		local _rc_spmat_assert = _rc
		if `_rc_spmat_assert' == 3499 {
			capt findfile spmat.ado
		    if _rc {
		        di as error "Only stata matrix and -spmat- objects are allowed as argument of -dmat()-."
				di as error "You can install -spmat- by typing {stata net install sppack}."
		        error 499
		    }
		}
		if `_rc_spmat_assert' != 0 {
			di "{inp}`dmatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		capture mata: SPMAT_check_if_banded("`dmatrix'",1)
		if _rc !=0 {
			di as error "xsmle does not support banded matrices"
			exit 498
		}
		
		tempname dmatrix_new
		capture spmat getmatrix `dmatrix' `dmatrix_new'
		if _rc {
			di "{inp}`dmatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		else {
			tempname _dmatspmatobj
			m st_numscalar("rww", rows(`dmatrix_new'))
			m st_numscalar("rcw", cols(`dmatrix_new'))
			m _FrOm_SpMaT_oBj = _GeT_FrOm_SpMaT_oBj(`dmatrix_new',3,_FrOm_SpMaT_oBj)
			//mata: st_matrix("`_dmatspmatobj'", `dmatrix_new')
			m `dmatrix_new'=.
			//local rww=rowsof(`_dmatspmatobj')
		    //local rcw=colsof(`_dmatspmatobj')
		    if rww != rcw {
			    display as error "Spatial weighting matrix `dmatrix' is not square"
			    error 198
		    }
			return local dmatrix ""
			return local o_dmatrix "`dmatrix'"
			return local _dmatspmatobj 1
		}
	}
	if `_rc_mat_assert' == 0 {
    	local rww=rowsof(`dmatrix')
    	local rcw=colsof(`dmatrix')
    	if `rww' != `rcw' {
	    	display as error "Spatial weighting matrix `dmatrix' is not square"
	    	error 198
    	}
		return local dmatrix "`dmatrix'"
	}
}

if ("`rftmatrix'" != "") {
	local n_rftmatrix: word count `rftmatrix'
	if `n_rftmatrix'!=1 {
		display as error "Only one spatial weighting matrix `rftmatrix' is allowed"
	    error 198
	}
	capture confirm matrix `rftmatrix'
	local _rc_mat_assert = _rc
	if `_rc_mat_assert' != 0 {
		capture mata: SPMAT_assert_object("`rftmatrix'")
		local _rc_spmat_assert = _rc
		if `_rc_spmat_assert' == 3499 {
			capt findfile spmat.ado
		    if _rc {
		        di as error "Only stata matrix and -spmat- objects are allowed as argument of -rftmat()-."
				di as error "You can install -spmat- by typing {stata net install sppack}."
		        error 499
		    }
		}
		if `_rc_spmat_assert' != 0 {
			di "{inp}`rftmatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		capture mata: SPMAT_check_if_banded("`rftmatrix'",1)
		if _rc !=0 {
			di as error "xsmle does not support banded matrices"
			exit 498
		}
		
		tempname rftmatrix_new
		capture spmat getmatrix `rftmatrix' `rftmatrix_new'
		if _rc {
			di "{inp}`rftmatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		else {
			tempname _rftmatspmatobj
			m st_numscalar("rww", rows(`rftmatrix_new'))
			m st_numscalar("rcw", cols(`rftmatrix_new'))
			m _FrOm_SpMaT_oBj = _GeT_FrOm_SpMaT_oBj(`rftmatrix_new',4,_FrOm_SpMaT_oBj)
			m `rftmatrix_new'=.
		    if rww != rcw {
			    display as error "Spatial weighting matrix `rftmatrix' is not square"
			    error 198
		    }
			return local rftmatrix ""
			return local o_rftmatrix "`rftmatrix'"
			return local _rftmatspmatobj 1
		}
	}
	if `_rc_mat_assert' == 0 {
    	local rww=rowsof(`rftmatrix')
    	local rcw=colsof(`rftmatrix')
    	if `rww' != `rcw' {
	    	display as error "Spatial weighting matrix `rftmatrix' is not square"
	    	error 198
    	}
		return local rftmatrix "`rftmatrix'"
	}
}

end

/* ----------------------------------------------------------------- */

program define ParseMod
	args returmac colon model

	local 0 ", `model'"
	syntax [, SAR SDM SEM SAC GSPRE * ]

	if `"`options'"' != "" {
		di as error "model(`options') not allowed"
		exit 198
	}
	
	local wc : word count `sar' `sdm' `sem' `sac' `gspre'

	if `wc' > 1 {
		di as error "model() invalid, only " /*
			*/ "one model can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `returmac' 1
	}
	else {
		if ("`sar'"=="sar") local modtype=1
		if ("`sdm'"=="sdm") local modtype=2
		if ("`sem'"=="sem") local modtype=3
		if ("`sac'"=="sac") local modtype=4
		if ("`gspre'"=="gspre") local modtype=5
		c_local `returmac' `modtype' 		
	}	

end

/* ----------------------------------------------------------------- */

program define ParseType
	args returmac colon type

	local 0 ", `type'"
	syntax [, Ind Time Both * ]

	if `"`options'"' != "" {
		di as error "type(`options') not allowed"
		exit 198
	}
	
	local wc : word count `ind' `time' `both'

	if `wc' > 1 {
		di as error "type() invalid, only " /*
			*/ "one type can be specified"
		exit 198
	}
	if `wc' == 0 {
		c_local `returmac' 1
	}
	else {
		if ("`ind'"=="ind") local _efftype=1
		if ("`time'"=="time") local _efftype=2
		if ("`both'"=="both") local _efftype=3
		c_local `returmac' `_efftype' 		
	}	

end



exit

*! version 1.0 10oct2012
*! version 1.1 23jan2013 - Bug fixes
*! version 1.2 12feb2013 - Check for banded matrices added
*! version 1.3 14may2013 - The command gives now an error when fixed-effects postestimation and type(time) or type(both)
*! version 1.4 10may2016 - Added -full- option to compute full information prediction aftre SAC
*! version 1.5 27jun2016 - Added -noie- to allow predictions without individual effects
*! version 1.6 12sep2016 - Not documented: Added direct, indirect and total (also in lr versions) to allow delta-method se computation







