program _ggreg, eclass
version 12.0
	if replay() {
		display "Replay not implemented"
	}
	else {
		syntax varlist(min=2) [, INITial(numlist) SIGMAvars(varlist) DIFficult TECHnique(passthru) ARCH(passthru) GARCH(passthru) ITERate(passthru) nolog TRace GRADient showstep HESSian SHOWTOLerance TOLerance(passthru) LTOLerance(passthru) NRTOLerance(passthru)] 
		local nvars: word count `varlist'
		local depvar: word 1 of `varlist'
		local regs: list varlist - depvar
		local nregs: word count `regs'
		marksample touse 
        quietly{ 
                  count if `depvar' < 0 & `touse'
                  local n =  r(N) 
                  if `n' > 0 {
                        noi di " "
                        noi di as txt " {res:`depvar'} has `n' values < 0;" _c
                        noi di as text " not used in calculations"
                  }

                  count if `depvar' == 0 & `touse'
                  local n =  r(N) 
                  if `n' > 0 {
                        noi di " "
                        noi di as txt " {res:`depvar'} has `n' values = 0;" _c
                        noi di as text " not used in calculations"
                  }

          replace `touse' = 0 if `depvar' <= 0
        }
		if ("`initial'" == "") {
			local initial
			qui reg `depvar' `regs'
			foreach vari in `regs' _cons {
				local temp = _b[`vari']
				local initial `initial' `temp'
			}

			local temp = ln(e(rmse)) + ln(2)/2
			local initial `initial' `temp'
			local initial `initial' 100 1 
		}
		local initiallen: word count `initial'

		tempvar lnd
			qui gen double `lnd' = ln(`depvar')
		ml model lf _ggevaluator (beta: `depvar' = `regs') (sigma: `sigmavars') /p if `touse', `technique'
		*ml init `initial', copy
		ml maximize, showeqns search(on) `difficult' `iterate' `log' `trace' `gradient' `showstep' `hessian' `showtolerance' `tolerance' `ltolerance' `nrtolerance'
		qui ereturn list
	}
end
