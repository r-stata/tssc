*! frontierhtail version 1.0.0
*! Performs stochastic frontier regression
*! for heavy tail data
*! Diallo Ibrahima Amadou
*! All comments are welcome, 14oct2011


/* Main Program */
capture program drop frontierhtail
program frontierhtail, eclass byable(onecall) sortpreserve properties(swml)
        version 11
        if _by() {
                  local by "by `_byvars' `_byrc0':"
        }
	if replay() {
		    if (`"`e(cmd)'"' != "frontierhtail") error 301
                    if _by() {
                              error 190
                    }
		    Replay `0'
	}
	else  `by' Estimate `0'
end


/* Estimation Program */
program Estimate, eclass byable(recall) sortpreserve
	syntax varlist(fv) [if] [in] 		///
		[fweight pweight ] [,	        ///
		vce(passthru)			///
		noLOg				///
		noCONStant			///
		HETero(varlist fv)              ///
		noLRTEST			///
		OFFset(varname numeric)		///
		EXPosure(varname numeric)	///
                Level(cilevel)			///
		EForm				///
                init(passthru)                  ///
		*				///
	]
	mlopts mlopts, `options'
	local cns `s(constraints)'
        local title "title("Stochastic Frontier For Heavy Tail Data")"
	gettoken lhs rhs : varlist
	_fv_check_depvar `lhs'
	if "`weight'" != "" {
		local wgt "[`weight'`exp']"
	}
	if "`log'" != "" {
		local qui quietly
	}
	if `"`hetero'"' == "" {
		local diparm diparm(lnsigma, exp label("sigma"))  ///
                             diparm(lntheta, exp label("theta"))
	}
	if "`offset'" != "" {
		local offopt "offset(`offset')"
	}
	if "`exposure'" != "" {
		local expopt "exposure(`exposure')"
	}
	if "`init'" == "" {
	                   quietly regress `lhs'
	                   local bc0=_b[_cons]
	                   local initopt "init(/xb=`bc0' /lnsigma=0 /lntheta=0) repeat(5)"
        }
        else {
              local initopt "`init'"
        }
	marksample touse
	markout `touse' `hetero' `offset' `exposure'
	_vce_parse `touse', opt(Robust oim opg)		///
		argopt(CLuster): `wgt' , `vce'		
	if "`constant'" == "" {
		`qui' di as txt _n "Fitting constant-only model:"
               ml model lf frontierhtail_lf		///
		  (xb: `lhs' =, `offopt' `expopt' ) 	///
		  (lnsigma: `hetero')		        ///
		  (lntheta:)                            ///
		  `wgt' if `touse',			///
		  `log'					///
		  `mlopts'				///
		  `initopt'                             ///
		   nocnsnotes				///
		   missing				///
		   maximize                             ///
	           `title'
		if "`lrtest'" == "" {
			local contin continue search(off)
		}
		else {
			tempname b0
			mat `b0' = e(b)
			local contin init(`b0') search(off)
		}
		`qui' di as txt _n "Fitting full model:"
	}
	ml model lf1 frontierhtail_lf1			///
		(xb: `lhs' = `rhs',                     ///
                      `constant' `offopt' `expopt')	///
		(lnsigma: `hetero')		        ///
		(lntheta:)                              ///
		`wgt' if `touse',			///
		`vce'					///
		`log'					///
		`mlopts'				///
		`contin'				///
		`diparm'				///
                 missing				///
		 maximize                               ///
		 `title'
	if "`hetero'" == "" {
		ereturn scalar k_aux = 2
	}
	else	ereturn scalar k_aux = 0
	ereturn local predict frontierhtail_p
	ereturn local cmd frontierhtail
	ereturn local  cmdline "frontierhtail `0'"
	Replay , level(`level') `eform'
end


/* Replay Program */
program Replay
	syntax [, Level(cilevel) EForm ]
	ml display , level(`level') `eform'
end
