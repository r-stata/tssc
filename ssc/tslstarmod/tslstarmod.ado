*! tslstarmod version 1.0.1
*! Performs Logistic Smooth Transition 
*! Autoregressive Regression (LSTAR)
*! Diallo Ibrahima Amadou
*! All comments are welcome, 18Sep2019



/* Main Program */
capture program drop tslstarmod
program tslstarmod, eclass byable(onecall) sortpreserve properties(swml)
    version 15.1
    if _by() {
			local by "by `_byvars' `_byrc0':"
    }
	if replay() {
		    if (`"`e(cmd)'"' != "tslstarmod") error 301
                    if _by() {
							error 190
                    }
		    Replay `0'
	}
	else  `by' Estimate `0'
end


/* Estimation Program */
program Estimate, eclass byable(recall) sortpreserve
	syntax varlist(ts) [if] [in] 		///
		, thresv(varname numeric ts)    ///
		[	        					///
		vce(passthru)					///
		noLOg							///
		noCONStant						///
		noLRTEST						///
		OFFset(varname numeric)			///
		EXPosure(varname numeric)		///
        Level(cilevel)					///
		EForm							///
        init          					///
		*								///
	]
	mlopts mlopts, `options'
	local cns `s(constraints)'
    local title "title("Logistic Smooth Transition Autoregressive Model (LSTAR)")"
	gettoken lhs rhs : varlist
	if "`log'" != "" {
		local qui quietly
	}
	local diparm diparm(lngamma, exp label("gamma"))  ///
            diparm(lnsigma, exp label("sigma"))
	if "`offset'" != "" {
		local offopt "offset(`offset')"
	}
	if "`exposure'" != "" {
		local expopt "exposure(`exposure')"
	}
	marksample touse
	markout `touse' `offset' `exposure' `thresv'
	_vce_parse `touse', opt(Robust oim opg)		///
		argopt(CLuster): , `vce'		
	quietly tsset
	global MZHAWA_ZVAR "`thresv'"
	quietly {
			if "`init'" != "" {
								tslstarmod_initvals `varlist' `if' `in', thresv(`thresv')
								tempname b0vect
								matrix define `b0vect' = e(b)
								local initopt "init(`b0vect', copy)"
			}
	}	
	`qui' di as txt _n "Fitting full model:"
	ml model lf tslstarmod_ll						///
		(Regime1: `lhs' = `rhs',                    ///
                    `constant' `offopt' `expopt')	///
		(Regime2: `rhs', 							/// 
                    `constant' `offopt' `expopt')	///
		(lngamma: )		        					///
		(cpar:)                              		///
		(lnsigma:)                              	///
		if `touse',									///
		`vce'										///
		`log'										///
		`mlopts'									///
		`initopt'                             		///
		`diparm'									///
        missing										///
		maximize                               	    ///
		`title'
	ereturn scalar k_aux = 3
	ereturn local thresva "`thresv'"
	ereturn local predict tslstarmod_p
	ereturn local cmd tslstarmod
	ereturn local  cmdline "tslstarmod `0'"
	Replay , level(`level') `eform'
end


/* Replay Program */
program Replay
	syntax [, Level(cilevel) EForm ]
	ml display , level(`level') `eform'
end


