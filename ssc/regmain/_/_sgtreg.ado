program _sgtreg, eclass
version 12.0
	if replay() {
		display "Replay not implemented"
	}
	else {
		syntax varlist [,ARCH(integer 0) GARCH(integer 0) INITial(numlist) DIFficult TECHnique(passthru) ITERate(passthru) nolog TRace GRADient showstep HESSian NONRtolerance SHOWTOLerance TOLerance(passthru) LTOLerance(passthru) NRTOLerance(passthru) VCE(passthru)] 
		local nvars: word count `varlist'
		local depvar: word 1 of `varlist'
		local regs: list varlist - depvar
		local nregs: word count `regs'
		if "`arch'" != "0" | "`garch'" != "0"{
			global gg = `garch'
			global aa = `arch'
			qui normalreg `depvar' `regs'
			qui mat sig = e(b)
			global insig = sig[1,1+`nvars']
			local arch = $aa
			loc garch = $gg
		}
		local in = "`initial'"
		if ("`initial'" == "") {
			local initial
			qui reg `depvar' `regs'
			foreach vari in `regs' _cons {
				local temp = _b[`vari']
				local initial `initial' `temp'
			}	

			local initial `initial' 1
		}	
		global g1 = ""
		global g3 = ""
		global t1 = ""
		global t3 = ""
		
		if "`arch'" != "0"{
			global t1 = "a0"
			global t3 = "/a0"
			forvalues i = 1/`arch' {
				global t1 "$t1 a`i'"
				global t3 "$t3 /a`i'"
				if "`in'" == ""{
					local initial `initial' .1
				}
			}
		}
		global arch = `arch'
		global garch = `garch'
						
		if "`garch'" != "0"{

			forvalues i = 1/`garch' {
				global g1 "$g1 b`i'"
				global g3 "$g3 /b`i'"
				if "`in'" == ""{
					local initial `initial' .1
				}
			}
		}
		if "`in'" == ""{
			local initial `initial' 0 2 100
		}
		local initiallen: word count `initial'
		if (`initiallen' != `nvars'+4 + `arch' + `garch') {
			di as err "initial does not have the correct amount of numbers"
			exit 503
		}	
		
		if "`arch'" != "0" | "`garch'" != "0"{
			global sigma = ""
			ml model lf _sgtevaluator (beta: `depvar' = `regs') ${t3} ${g3} /lambda /p /q  , `technique' `vce'
		}
		else{
			global sigma = "sigma"
			ml model lf _sgtevaluator (beta: `depvar' = `regs') /sigma /lambda /p /q  , `technique' `vce'
		}

		ml init `initial', copy
		//ml check
		ml maximize, showeqns `difficult' `iterate' `log' `trace' `gradient' `showstep' `hessian' `nonrtolerance' `showtolerance' `tolerance' `ltolerance' `nrtolerance' 
		
		qui ereturn list
	}
end

