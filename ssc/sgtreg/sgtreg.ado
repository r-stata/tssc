program sgtreg, eclass
version 12.0
	if replay() {
		display "Replay not implemented"
	}
	else {
		syntax varlist(min=2) [, INITial(numlist) DIFficult TECHnique(passthru) ITERate(passthru) nolog TRace GRADient showstep HESSian SHOWTOLerance TOLerance(passthru) LTOLerance(passthru) NRTOLerance(passthru)] 
		local nvars: word count `varlist'
		local depvar: word 1 of `varlist'
		local regs: list varlist - depvar
		local nregs: word count `regs'
		if ("`initial'" == "") {
			local initial
			qui reg `depvar' `regs'
			foreach vari in `regs' _cons {
				local temp = _b[`vari']
				local initial `initial' `temp'
			}
			forval i = 1/`nregs' {
				local initial `initial' 0 
			}
			local temp = ln(e(rmse)) + ln(2)/2
			local initial `initial' `temp'
			forval i = 1/`nvars' {
				local initial `initial' 0 
			}
			local initial `initial' 2 100
		}
		local initiallen: word count `initial'
		if (`initiallen' != `nvars'*3+2) {
			di as err "initial does not have the correct amount of numbers"
			exit 503
		}
		ml model lf sgtevaluator (beta: `depvar' = `regs') (gamma: `regs') (delta: `regs') /p /q, `technique'
		ml init `initial', copy
		ml maximize, showeqns `difficult' `iterate' `log' `trace' `gradient' `showstep' `hessian' `showtolerance' `tolerance' `ltolerance' `nrtolerance'
		qui ereturn list
	}
end
