*! 1.0.0 Ariel Linden 14Aug2020 // this version has dfbeta()

program define metapred, rclass
version 16.0

		if "`e(cmd)'"  != "meta regress" {
			di as err "You must first run {bf:meta regress} before calling {bf:metapred}"
			exit
		}
		
		local cmdline = "`e(cmdline)'"
		local model = "`e(model)'"
		local method = "`e(method)'"
	
		local myopts "RSTAndard RSTUdent DFIts Cooksd Welsch COVratio DFBeta(string)"
		_pred_se "`myopts'" `0'
		
		local typ `s(typ)'
		local varn `s(varn)'
		local 0    `"`s(rest)'"'
	
		syntax [if][in] [, `myopts' ]


		marksample touse

        local oplist "`rstandard' `rstudent' `dfits' `cooksd' `welsch' `covratio' `dfbeta(string)'"
		opts_exclusive "`oplist'"
		local type "`rstandard'`rstudent'`dfits'`cooksd'`welsch'`covratio'`dfbeta'"
		if "`type'" == "" {
			di as err "one of the available options must be specified"
			exit 198
		}
		

		***************
		** rstandard **
		***************
		else if "`type'" == "rstandard"  {
			_rsta "`typ'" "`varn'" "`touse'"
		}
		
		***************
		** rstudent **
		***************
		else if "`type'" == "rstudent" {	/* restricted to e(sample) */
			_rstu "`typ'" "`varn'" "`touse'" "`cmdline'"
		} // end rstudent
 
 
 		***************
		** dfits **
		***************
 		else if "`type'" == "dfits" {	/* restricted to e(sample) */
			tempvar hh t
			qui predict double `hh' if `touse', hat
			qui metapred `t' if `touse', rstudent
			gen `typ' `varn' = `t'*sqrt(`hh'/(1-`hh')) if `touse'
			label var `varn' "DFITS"
		}
		
		***************
		** cooksd **
		***************
		else if "`type'"=="cooksd" {
			tempvar resid resid_se stdp rsta
			if "`e(model)'" == "random" {	
				predict double `resid' if `touse', residuals fixedonly se(`resid_se', marginal)
			} // end random
			else if "`e(model)'" == "fixed" {
				predict double `resid' if `touse', residuals se(`resid_se')
			} // end fixed
			
			local k = colsof(e(b))
			qui predict `stdp' if `touse', stdp
			qui metapred `rsta' if `touse', rstand
			qui gen `typ' `varn'= (`rsta'^2 * (`stdp'/`resid_se')^2)/`k' if `touse'
			label var `varn' "Cook's D"
		}
		
		***************
		** welsch **
		***************
		else if "`type'" == "welsch" {	/* restricted to e(sample) */
			tempvar hh t
			qui predict double `hh' if `touse', hat
			qui metapred `t' if `touse', rstudent
			qui gen `typ' `varn'=(`t'*sqrt(`hh'/(1-`hh')))* /*
				*/ sqrt((e(N)-1)/(1-`hh')) if `touse'
			label var `varn' "Welsch distance"
        }
		
		***************
		** covratio **
		***************
		else if "`type'" == "covratio" { /* restricted to e(sample) */
			tempvar hh rsta 
			qui predict double `hh' if `touse', hat
			qui metapred `rsta' if `touse', rstandard
			local k = colsof(e(b))
			local N = e(N)
			qui gen `typ' `varn' = ((1)/(1-`hh')) * ((`N'-`k'-`rsta'^2) / (`N'-`k'- 1))^`k'
			label var `varn' "COVRATIO"
		}

		***************
		** dfbeta **
		***************
		if "`dfbeta'"!="" {	/* restricted to e(sample) */
			DFBeta "`typ'" "`varn'" "`touse'" "`dfbeta'" "`model'" "`method'"
        }
		
end


program define DFBeta /* "`typ'" "`varn'" "`touse'" "`dfbeta'" */
		version 16
		args type newvar touse var model method
		_ms_extract_varlist `var'
		local varlist `"`r(varlist)'"'
		if `:list sizeof varlist' > 1 {
			di as err "invalid dfbeta() option;"
			di as err "too many variables specified"
			exit 103
		}

		tempname b

		matrix `b' = e(b)
		local dim = colsof(`b')
		local pos = colnumb(`b', "`var'")

		local rhs : colnames `b'
		mat drop `b'
		local USCONS _cons
		if `:list USCONS in rhs' {
			local rhs : list rhs - USCONS
			local --dim
		}

		fvrevar `rhs'
		local rrhs `"`r(varlist)'"'
		forval i = 1/`dim' {
				gettoken X rhs : rhs
				if `i' == `pos' {
					gettoken y rrhs : rrhs
					local Y : copy local X
				}
				else {
					gettoken x rrhs : rrhs
					local xvars `xvars' `x'
				}
		}

		tempvar HAT RSTU lest RES SRES RESULT
		qui metapred `RSTU' if `touse', rstud
		qui predict double `HAT' if `touse', hat
		version 16: _est hold `lest', restore
		if "`model'" == "random" {
			meta regress `y' `xvars' if `RSTU'<., nocons random(`method') // we need to manually drop constant from meta regress
		}
		else {
			meta regress `y' `xvars' if `RSTU'<., nocons fixed // we need to manually drop constant from meta regress
		}
		qui predict double `RES' if `RSTU'<., res
		version 16: _est unhold `lest'
		quietly gen double `SRES'=sum(`RES'^2)
		qui gen `type' `newvar'=`RSTU'*`RES'/sqrt((1-`HAT')*`SRES'[_N])
		label var `newvar' "DFBETA `Y'"
end



capture program drop _rsta
program _rsta, rclass
        version 16
		args type newvar touse 
		
		qui {
			if "`e(model)'" == "random" {	
				tempvar resid resid_se
				predict double `resid' if `touse', residuals fixedonly se(`resid_se', marginal)
			} // end random
			
			else if "`e(model)'" == "fixed" {
				tempvar resid resid_se
				predict double `resid' if `touse', residuals se(`resid_se')
			} // end fixed
			
			* gen standardized residuals
			gen `type' `newvar' = `resid' / `resid_se'
			label var `newvar' "Standardized residuals"
		} // end quietly

end		
		

capture program drop _rstu
program _rstu, rclass
        version 16
		args type newvar touse cmdline

			qui {
				tempvar sample indho resid rse
				* account for touse from original meta regress estimation 
				gen `sample' = e(sample)
				* indicator for hold out study
				gen `indho' = .
				count if `sample'==1
				local N = r(N)

				gen double `resid' =.
				gen double `rse' = .
				gen double `type' `newvar' = .
				label var `newvar' "Studentized residuals"
				
				// sort so that all touse is at top
				gsort -`sample'
			
				// block to extract options from command line
				local cmdlne = "`e(cmdline)'"
				local right = reverse("`cmdlne'")
				local right = substr("`right'", 1, strpos("`right'", ",") - 1)
				local right = reverse("`right'")
	
				// run LOO loop
				forval i = 1/`N' {
				    replace `indho' = cond(_n==`i',1,0)
					`e(cmd)' `e(indepvars)' `indho' if `sample' == 1, `right'
	
					* save table of estimates as matrix 
					qui matrix b = r(table)
					* retrieve estimate and SE for the indicator for the holdout study 
					local est = b[1,colnumb(matrix(b),"`indho'")]
					local se = b[2,colnumb(matrix(b),"`indho'")]
	
					replace `resid' = `est' if `touse' & _n==`i'
					replace `rse' = `se' if `touse' & _n==`i'
					replace `type' `newvar' = `est' / `se' if `touse' & _n==`i'
				}
				// reset meta regress
				`cmdline'
				
				// resort by trial number
				sort _meta_id
			} // end quietly		
			
end

