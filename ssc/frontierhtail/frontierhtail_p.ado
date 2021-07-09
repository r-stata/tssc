*! version 1.0.0
*! Predict program for the command frontierhtail
*! Diallo Ibrahima Amadou
*! All comments are welcome, 14oct2011


capture program drop frontierhtail_p
program frontierhtail_p
        version 11
	syntax anything(id="newvarname") [if] [in] [, LNSigma SIGma LNTheta THEta inef teff mode RESiduals * ]
	if "`lnsigma'" != "" {
		syntax newvarname [if] [in] [, LNSigma ]
		_predict `typlist' `varlist' `if' `in', equation(lnsigma)
		label variable `varlist' "predicted ln(sigma)"
		exit
	}
	if "`sigma'" != "" {
		syntax newvarname [if] [in] [, SIGma ]
		_predict `typlist' `varlist' `if' `in', equation(lnsigma)
		quietly replace `varlist' = exp(`varlist')
		label variable `varlist' "predicted sigma"
		exit
	}
	if "`lntheta'" != "" {
		syntax newvarname [if] [in] [, LNTheta ]
		_predict `typlist' `varlist' `if' `in', equation(lntheta)
		label variable `varlist' "predicted ln(theta)"
		exit
	}
	if "`theta'" != "" {
		syntax newvarname [if] [in] [, THEta ]
		_predict `typlist' `varlist' `if' `in', equation(lntheta)
		quietly replace `varlist' = exp(`varlist')
		label variable `varlist' "predicted theta"
		exit
	}
	local newlist `"`inef' `teff' `mode'"'
	if  "`newlist'" != ""      {
	                            matrix bc = e(b)
                                    matrix cv=bc[1, "lnsigma:"]
                                    local lescolb = colsof(cv)
                                    if "`lescolb'" == "1" {
                                                       if "`inef'" != "" {
                                                                       syntax newvarname [if] [in] [, inef  ]
                                                                       tempvar hf vxb resids1 lnsigmav1 sigmav1 rsig
                                                                       _predict double `vxb', equation(xb)
                                                                       _predict double `lnsigmav1', equation(lnsigma)
                                                                       local depvars = "`e(depvar)'"
                                                                       quietly {
                                                                                gen double `sigmav1' = exp(`lnsigmav1')
                                                                                gen double `resids1'  = `depvars' - `vxb'
                                                                                gen double `rsig'    = `resids1'/`sigmav1'
                                                                                gen double `hf'      = normalden(`rsig')/(1-normal(`rsig'))
                                                                                gen `typlist' `varlist'  = `sigmav1'*(`hf'-`rsig') `if' `in'
                                                                       }
                                                                       label variable `varlist' "predicted inefficiency"
                                                                       exit
                                                       }
                                                       if "`mode'" != "" {
                                                                        syntax newvarname [if] [in] [, mode  ]
                                                                        tempvar vxb2 resids2 lntheta1 theta1 modvar
                                                                        _predict double `vxb2', equation(xb)
                                                                        _predict double `lntheta1', equation(lntheta)
                                                                        local depvars2 = "`e(depvar)'"
                                                                        quietly {
                                                                                 gen double `theta1' = exp(`lntheta1')
                                                                                 gen double `resids2'  = `depvars2' - `vxb2'
                                                                                 gen double `modvar' = .
                                                                                 replace `modvar' = `theta1' if `resids2' < -`theta1'
                                                                                 replace `modvar' = -`resids2' if  -`theta1' <= `resids2' & `resids2' < 0
                                                                                 replace `modvar' = 0 if `resids2' >= 0
                                                                                 gen `typlist' `varlist' = `modvar' `if' `in'
                                                                        }
                                                                        label variable `varlist' "predicted inefficiency via the mode"
                                                                        exit
                                                       }
                                                       if "`teff'" != "" {
                                                                        syntax newvarname [if] [in] [, teff  ]
                                                                        tempvar vxb3 resids3 lnsigma3 sigma3 lntheta3 theta3 te2
                                                                        tempvar num1 num2 den1 den2 fact1
                                                                        _predict double `vxb3', equation(xb)
                                                                        _predict double `lnsigma3', equation(lnsigma)
                                                                        _predict double `lntheta3', equation(lntheta)
                                                                        local depvars3 = "`e(depvar)'"
                                                                         quietly {
                                                                                  gen double `sigma3'   = exp(`lnsigma3')
                                                                                  gen double `theta3'   = exp(`lntheta3')
                                                                                  gen double `resids3'  = `depvars3' - `vxb3'
                                                                                  gen double `num1'     = normal((`resids3'+`theta3')/`sigma3'+`sigma3')
                                                                                  gen double `num2'     = normal(`resids3'/`sigma3'+`sigma3')
                                                                                  gen double `den1'     = normal((`theta3'+`resids3')/`sigma3')
                                                                                  gen double `den2'     = normal(`resids3'/`sigma3')
                                                                                  gen double `fact1'    = exp(`resids3'+((`sigma3')^2)/2)
                                                                                  gen double `te2'      = (`fact1')*((`num1'-`num2')/(`den1'-`den2'))
                                                                                  gen `typlist' `varlist'  = `te2'  `if' `in'
                                                                        }
                                                                        label variable `varlist' "predicted technical efficiency"
                                                                        exit
                                                       }
                                    }
                                    else  {
                                          di as err "You cannot calculate efficiency when the hetero option is specified"
                                          exit 321
                                    }
        }
        if "`residuals'" != "" {
                                syntax newvarname [if] [in] [, RESiduals  ]
                                tempvar vxb4
                                _predict double `vxb4', equation(xb)
                                local depvars4 = "`e(depvar)'"
                                quietly gen `typlist' `varlist'  = `depvars4' - `vxb4'  `if' `in'
                                label variable `varlist' "Residuals"
                                exit
        }
	ml_p `0'
end
