program regmain, eclass sortpreserve
version 12.0
	if replay() {
		display "Replay not implemented"
	}

	else {
		syntax varlist [, DISTribution(string) FAMily(string) ARCH(integer 0) GARCH(integer 0) VCE(passthru) NOGraph INITial(passthru) DIFficult TECHnique(passthru) ITERate(passthru) NOLog TRace GRADient showstep HESSian SHOWTOLerance NONRtolerance TOLerance(passthru) LTOLerance(passthru) NRTOLerance(passthru)] 
		local nvars: word count `varlist'
		local depvar: word 1 of `varlist'
		local regs: list varlist - depvar
		local nregs: word count `regs'
		if "`iterate'" == ""{
			loc iterate = "iter(1000)"
		}
		if "`family'" != ""{
			if "`distribution'" != ""{
				noi di as error "CANNOT SPECIFY DISTRIBUTION AND FAMILY" _newline "FOR ADDITIONAL HELP {help regmain: CLICK HERE}"
				exit
			}
			if "`family'" != "sgt" & "`family'" != "gb2"{
				noi di as error "INVALID DISTRIBUTION FAMILY SELECTION" _newline "PLEASE SELECT sgt OR gb2, FOR HELP {help regmain: CLICK HERE}"
				exit
			}
			else{
				if "`family'" == "sgt"{
					loc dlist = "sgt st gt sged ged slaplace snormal t scauchy laplace normal cauchy"
				}
				else if "`family'" == "gb2"{
					loc dlist = "gb2 gg lt lcauchy ln gamma weibull exponential"
				}
				di as result "Distribution:" _col(17) "Converged:" _col(30) "Log-Likelihood:" _col(48) "BIC:" _col(60) "AIC:"
				di as result "-----------------------------------------------------------------"
				foreach i in `dlist'{

					//cap `i'reg `depvar' `regs', `iterate' `vce' `difficult' `technique'`nolog' `trace' `gradient' `showstep' `hessian' `nonrtolerance' `showtolerance' `tolerance' `ltolerance' `nrtolerance' 
					cap `i'reg `depvar' `regs', arch(`arch') garch(`garch') `iterate' `vce' `difficult' `technique'`nolog' `trace' `gradient' `showstep' `hessian' `nonrtolerance' `showtolerance' `tolerance' `ltolerance' `nrtolerance' 
					if e(converged) == 1 & _rc == 0{
						loc ll = e(ll)
						mat RES = e(b)
						qui sum `depvar', meanonly
						loc N = r(N)
						loc k = colsof(RES)
						loc bic = ln(`N')*`k' - 2*`ll'
						loc aic = 2*`k' - 2*`ll' 
						loc con = "yes"
					}
					else{
						cap `i'reg `depvar' `regs', tech(bfgs) arch(`arch') garch(`garch') iter(500) `vce' `difficult' `nolog' `trace' `gradient' `showstep' `hessian' `nonrtolerance' `showtolerance' `tolerance' `ltolerance' `nrtolerance' 
						if e(converged) == 1 & _rc == 0{
							mat RES = e(b)
							loc ll = e(ll)
							qui sum `depvar', meanonly
							loc N = r(N)
							loc k = colsof(RES)
							loc bic = ln(`N')*`k' - 2*`ll'
							loc aic = 2*`k' - 2*`ll' 
							loc con = "yes"
						}
						else{
							loc ll = .
							loc bic = .
							loc aic = .
							loc con = "no"
						}
						
					}
					di as text "`i'" _col(17) "`con'" _col(30) %-10.2f `ll' _col(48) %-8.2f `bic' _col(60) %-8.2f `aic'
					
				}
				exit
			}
		}
			
		if "`distribution'" == "" | "`distribution'" == "ols" {
			reg `depvar' `regs'
			exit
		}
		else if "`distribution'" == "lad" {
			qreg `depvar' `regs'
			exit
		}
		**adding in gb familiy**
		
		else if inlist("`distribution'","gb2","gg","ln","exp","weibull","gamma","lcauchy","chi2","lt"){
			_`distribution'reg `depvar' `regs', `initial' garch(`garch') arch(`arch') `vce' `difficult' `technique' `iterate' `nolog' `trace' `gradient' `showstep' `hessian' `nonrtolerance' `showtolerance' `tolerance' `ltolerance' `nrtolerance' 		
			exit
		}
		else if inlist("`distribution'","sgt","gt","st","sged","ged","normal","t","cauchy","scauchy") | inlist("`distribution'","laplace","slaplace","snormal","egb2","segb2"){
			_`distribution'reg `depvar' `regs', `initial' garch(`garch') arch(`arch') `vce' `difficult' `technique' `iterate' `nolog' `trace' `gradient' `showstep' `hessian' `nonrtolerance' `showtolerance' `tolerance' `ltolerance' `nrtolerance' 		
			
			if "`nograph'" == ""{
				tempvar yhat resid
				qui predict double `yhat'
				qui gen double `resid' = `depvar' - `yhat'
				mat params = e(b)
				loc arch_var = 0
				forvalues i = 1/$arch {
					loc arch_var = `arch_var' + params[1,`nregs' + 2 + `i']
				}
				forvalues i = 1/$garch {
					loc arch_var = `arch_var' + params[1,`nregs' + $arch + 2 + `i']
				}
					
					
				

				loc dist_graph = "(line _`distribution'den_`resid' `resid')"
				
				if "${arch} " != "0 " | "${garch} " != "0 "{
					loc t1 = sqrt((params[1,`nregs'+2])/(1-`arch_var'))
				}
				else{
					loc t1 = (params[1,`nregs'+2])/(1-`arch_var')
				}
				loc t2 = params[1,`nregs'+ $arch + $garch +3]
				loc t3 = params[1,`nregs'+ $arch + $garch +4]
				loc t4 = params[1,`nregs'+ $arch + $garch +5]
				loc thetalist = "`t1' `t2' `t3' `t4'"
				qui capture drop _`distribution'den_`resid'
				
				if "`distribution'" == "normal"{
					gen _`distribution'den_`resid' = normalden(`resid', 0, `t1')
				}
				
				else{
					_`distribution'den `resid' 0 `thetalist'
				}
			}
			else{
				exit
			}
		}
		else{
			noi di as error "INVALID DISTRIBUTION SELECTION" _newline "FOR DISTRIBUTION OPTIONS {help regmain: CLICK HERE}"
			exit 503
		}
		
		sort `resid'
		qui sum `resid'
		local bw1 = 1.06*r(sd)*r(N)^-.2	//optimal bandwidth
		qui sum `depvar'
		local bw2 = 1.06*r(sd)*r(N)^-.2	//optimal bandwidth
		
		twoway (histogram `resid' ,width(`bw1')) `dist_graph' (kdensity `resid' ,kernel(triangle) bwidth(`bw1')), name(residuals, replace) nodraw title(Residuals) legend(label(2 "`estimation' Density")label(3 "Kernel Density")) ytitle("Probability") xtitle("Residuals")
		twoway (histogram `depvar', width(`bw2')), name(histo, replace) nodraw title(`depvar' Histogram) ytitle("Probability") xtitle(`depvar')
		qui drop _`distribution'den_`resid'
		graph combine residuals histo
		


	}
	end
	
	



























































