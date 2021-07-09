program _gammareg, eclass
version 12.0
	if replay() {
		display "Replay not implemented"
	}
	else{
		syntax varlist(min=2) [, INITial(numlist) DIFficult TECHnique(passthru) ITERate(passthru) ARCH(passthru) GARCH(passthru) nolog TRace GRADient showstep HESSian SHOWTOLerance TOLerance(passthru) LTOLerance(passthru) NRTOLerance(passthru)] 
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



		ml model lf _gammaevaluator (beta: `depvar' = `regs') /p if `touse', `technique'
		*ml init `initial', copy
		ml maximize, showeqns search(on) `difficult' `iterate' `log' `trace' `gradient' `showstep' `hessian' `showtolerance' `tolerance' `ltolerance' `nrtolerance'
		qui ereturn list
	}
end
