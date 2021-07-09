*! version 1.00 25-mar-2020
*! authors Pedro Albarran, Raquel Carrasco & Jesus Carro



capture program drop mgf_unbal
program def mgf_unbal, rclass prop(xt)
    version 13.0

	syntax [if] [in] [aw fw iw pw], ///
			dydx(string) [val0(numlist max=1) val1(numlist max=1)]

	if ("`e(cmd)'"!="xtprobitunbal") {
       	di as err "Last (xtprobitunbal) estimates not found"
		exit 301
	}

	local controls = e(controls)

	di " "
	local islagged=0
	if ("`dydx'"=="lag") {
        local isdiscrete=1
        local islagged=1

		if ("`val0'"!="" | "`val1'"!="") {
        	di as err "Unnecessary Option. Values for the discrete change of the lag of the (binary) dependent variable are automatically set."
        }

        local val0=0
    	local val1=1

        di "Computing marginal effect of a discrete change from `val0' to `val1' for the lag of the dependent variable `e(depvar)'."

	}
	else if (substr("`dydx'",1,2)!="c." & substr("`dydx'",1,2)!="d.") {
		di as err "You must specificy a valid option in dydx: 'lag' for the marginal effect of the lagged dependent variable, 'c.varname' for a continuous change the explanatory variable 'varname' o 'd.varname' for a discrete change of 'varname'."
        exit
	}
	else {
		local varlist = substr("`dydx'",3,strlen("`dydx'")-2)

		// check that variable exist in dataset
		confirm variable `varlist'

		// check that variable is in the model
		local novarname=0
		foreach x of local controls {
			if ("`x'"=="`varlist'") {
				local novarname=1
			}
		}

		if (`novarname'==0) {
			di as err "Variable `varlist' is not an explanatory variable in the estimated model"
			exit
		}

		// Continuous or Discrete change
		if  (substr("`dydx'",1,2)=="c.") {
	        local isdiscrete=0
	        if ("`val0'"!="" | "`val1'"!="") {
        		di as err "Unnecessary Option. No values are required for a continuous change."
        	}
	        di "Computing marginal effect of a continuous change for `varlist'"

		}
		else if (substr("`dydx'",1,2)=="d.") {
			local isdiscrete=1
	        if ("`val0'"=="") local val0=0
            if ("`val1'"=="") local val1=1

            di "Computing marginal effect of a discrete change from `val0' to `val1' for `varlist'."
		}

	}

	local meansvars = e(meansvars)

	local totvar= wordcount("`controls' `meansvars'")
	local nvars = wordcount("`controls'")
	local nmeds = wordcount("`meansvars'")

	local ncomon=1+`nvars'

	local tot= 1 + `nvars'  + 1  +`nmeds'+ 1     + 1
		// lag + x vars + IC + means + const + varianza error

	tempvar sum_ind_x index1 index0 g1 g0 mevar
	tempvar y0 LY anno_i
	tempname SP

	//--- Generate initial condition
	xtset
	sort `r(panelvar)' `r(timevar)'
	qby `r(panelvar)': gen `y0'=`e(depvar)'[1]

	//---- Generate means (first observation not included in mean)
	sort `r(panelvar)' `r(timevar)'
	qby `r(panelvar)': gen int `anno_i'=_n

	quietly foreach j of local meansvars {
		tempvar mm_`j'
		egen `mm_`j'' = mean(`j') if `anno_i'!=1, by(`r(panelvar)')
		replace  `mm_`j''=`mm_`j''[_n+1] if `mm_`j''==.
		local xxmean = "`xxmean' `mm_`j''"
	}

	quietly xtset 

	local RF "`y0' `xxmean'"

	local dd=`tot'-`ncomon'         // numero de parametros NO comunes
	local pos=`tot'*(`e(nsubp)')           // numero total de parametros antes de MD
	local puniq=`ncomon'+`dd'*(`e(nsubp)')  // numero total de parametros despues de MD

	mat finalB=e(finalB)
	mat finalV=e(finalV)

	quietly gen `sum_ind_x' = 0
	quietly gen `index1'    = .
	quietly gen `index0'    = .
	quietly gen `mevar'     = .
	quietly gen `g1'    = .
	quietly gen `g0'    = .

	/* ----- Jacobians ----- */
	forvalues k=1/`puniq' {
		tempvar JJac`k'
		quietly gen `JJac`k''= .
	}

    matrix A=J(`puniq',1,0)

    //----- define the subpanels --------
	tempvar SP
	gen `SP'=`e(subpn_var)'

	local used_subps = "`e(subpsN)'"

	local X = 1
	quietly foreach SSS of local used_subps {

		if "`if'"!="" {
			local myif = " `if' & _touse_xtprobitunbal == 1 & `SP'==`SSS'"
		}
		else {
			local myif = " if _touse_xtprobitunbal==1 & `SP'==`SSS'"
		}

		local pnc0=`ncomon'+(`X'-1)*`dd'+1
		local pnc1=`ncomon'+(`X'-1)*`dd'+`dd'

		// --------- Marginal Effect

        local alpha=finalB[1,1]     /*parametro de l.export */

        if (`isdiscrete'==0 | (`isdiscrete'==1 & `islagged'==0)) {
            replace `sum_ind_x'= `alpha'*l.`e(depvar)'  `myif'
        }

        local Ind_var = 0

        local s = 0
 	    local b = 2
		foreach x of local controls {
            replace `sum_ind_x'=`sum_ind_x'+ finalB[`b',1]*`x'  `myif'

            if (`s'==0) {
                if ("`varlist'"=="`x'") {
                    local s = 1
                    local Ind_var = `b'
                    if (`isdiscrete'==1 & `islagged'==0) {
                        replace `sum_ind_x'=`sum_ind_x'- finalB[`b',1]*`x'+ finalB[`b',1]*`val0' `myif'
                    }
                }
            }

		    local b= `b'+1
        }

		local b=`pnc0'
		foreach x of local RF {
			replace `sum_ind_x' = `sum_ind_x' + finalB[`b',1]*`x' `myif'
			local b= `b'+1
		}

		local mu0=finalB[`pnc1'-1,1]       /* parameter for the constant */
		local sigma2_eta=finalB[`pnc1',1]  /* variance of the individual effect distribution */

        // ----------------- Marginal Effect

        replace `index0' = `mu0'   + `sum_ind_x' `myif'

        if (`isdiscrete'==0) {
            replace `mevar'=normalden(1/sqrt(1+`sigma2_eta')*`index0')*1/sqrt(1+`sigma2_eta')*finalB[`Ind_var',1]  `myif'
        }
        else if (`isdiscrete'==1) {
            if (`islagged'==1) {
		        replace `index1' = `alpha' + `index0'    `myif'
            }
            else if (`islagged'==0) {
		        replace `index1' =  finalB[`Ind_var',1]*(`val1' - `val0') + `index0'    `myif'
            }
	        replace `mevar'=normal(1/sqrt(1+`sigma2_eta')*`index1')-normal(1/sqrt(1+`sigma2_eta')*`index0')  `myif'
        }

	// --------- Jacobians

        if (`isdiscrete'==0) {
            replace `g0'=-1/sqrt(1+`sigma2_eta')*`index0'*normalden(1/sqrt(1+`sigma2_eta')*`index0')*1/sqrt(1+`sigma2_eta')*finalB[`Ind_var',1]  `myif'
        }
        else if (`isdiscrete'==1) {
		    replace `g1'=normalden(1/sqrt(1+`sigma2_eta')*`index1') `myif'
		    replace `g0'=normalden(1/sqrt(1+`sigma2_eta')*`index0') `myif'
        }

		// Jacobian (for each individual)

        // alpha + control variables
        if (`isdiscrete'==1) {
            if (`islagged'==1) {
                replace `JJac1'=`g1'*1/sqrt(1+`sigma2_eta')  `myif'
            }
            else {
		        replace `JJac1'=(`g1'-`g0')*1/sqrt(1+`sigma2_eta')*l.`e(depvar)'  `myif'
            }
            local b=2
            foreach x of local controls {
                if (`b'!=`Ind_var') {
			        replace `JJac`b''= (`g1'-`g0')*1/sqrt(1+`sigma2_eta')*`x'  `myif'
                }
                if (`b'==`Ind_var') {
         		    replace `JJac`b''= `g1'*1/sqrt(1+`sigma2_eta')*`val1'-`g0'*1/sqrt(1+`sigma2_eta')*`val0' `myif'
                }
                local b= `b'+1
            }
        }

        if (`isdiscrete'==0) {
            replace `JJac1'=`g0'*1/sqrt(1+`sigma2_eta')*l.`e(depvar)'  `myif'

            local b=2
            foreach x of local controls {
			    replace `JJac`b''= `g0'*1/sqrt(1+`sigma2_eta')*`x'  `myif'
                    if (`b'==`Ind_var') {
         			    replace `JJac`b''= `JJac`b'' + normalden(1/sqrt(1+`sigma2_eta')*`index0')*1/sqrt(1+`sigma2_eta')  `myif'
                    }
			local b= `b'+1
		    }
        }

        // means
		local b=`pnc0'
		foreach x of local RF {

            if (`isdiscrete'==1) {
                replace `JJac`b''= (`g1'-`g0')*1/sqrt(1+`sigma2_eta')*`x'  `myif'
             }

            if (`isdiscrete'==0) {
	    		replace `JJac`b''= `g0'*1/sqrt(1+`sigma2_eta')*`x'  `myif'
            }
			quietly count if `JJac`b''!=.
			if r(N)==0 {
				matrix T = 0
			}
			if r(N)>=1 {
				matrix vecaccum T = `JJac`b'' `myif'
			}

			matrix A[`b',1] = T

			local b= `b'+1
		}

        // constant
		local b=`pnc1'-1

        if (`isdiscrete'==1) {
            replace `JJac`b''=(`g1'-`g0')*1/sqrt(1+`sigma2_eta')  `myif'
        }

        if (`isdiscrete'==0) {
		    replace `JJac`b''=`g0'*1/sqrt(1+`sigma2_eta')  `myif'
        }

			quietly count if `JJac`b''!=.
			if r(N)==0 {
				matrix T = 0
			}
			if r(N)>=1 {
				matrix vecaccum T = `JJac`b'' `myif'
			}

			matrix A[`b',1] = T

        // variance
		local b=`pnc1'
        if (`isdiscrete'==1) {
            replace `JJac`b''=(`g1'*`index1'-`g0'*`index0')*(-1/2*(1+`sigma2_eta')^(-3/2))   `myif'
        }

        if (`isdiscrete'==0) {
		    replace `JJac`b''=`g0'*`index0'*(-1/2*(1+`sigma2_eta')^(-3/2))+ ///
                            normalden(1/sqrt(1+`sigma2_eta')*`index0')*(-1/2*(1+`sigma2_eta')^(-3/2))*finalB[`Ind_var',1]  `myif'
        }

			quietly count if `JJac`b''!=.
			if r(N)==0 {
				matrix T = 0
			}
			if r(N)>=1 {
				matrix vecaccum T = `JJac`b'' `myif'
			}

			matrix A[`b',1] = T

		local X = `X' + 1
	}
//------ end loop

	forvalues j=1/`ncomon' {
		matrix vecaccum T = `JJac`j''  `if'
		mat A[`j',1] = T
	}

///----- PRINTING

    quietly sum `mevar' 
 	scalar ame=r(mean)
    local nnn=r(N)

	quietly xtsum `mevar'
	local n_g=r(n)

    matrix VAR=A'/`nnn'*finalV*A/`nnn'

	local SEmgfx = sqrt(VAR[1,1])
	local zstat  = `r(mean)' / `SEmgfx'
	local pvalue = 2*normal(-abs(`zstat'))
	local IClow = `r(mean)' - 1.959964*`SEmgfx'
	local IChig = `r(mean)' + 1.959964*`SEmgfx'
 
	if ("`dydx'"=="lag") local varlist= "l.`e(depvar)'" 

 	di " "
	di "Number of observations = "  /*
 			*/	as result %8.0f `nnn' " " _skip(14) /*
   */ "Number of groups  = "  /*
 			*/	as result %10.0f `n_g'
	di " "

	di "--------------------------------------------------------------------------------"
	di "             |             Delta-method                                         "
	di "             |     AME       Std. Err.      z      P>|z|    [95% Conf. Interval]"
	di "-------------+------------------------------------------------------------------"
	//  12345678901234567890123456789012345678901234567890123456789012345678901234567890

	di as text  %12s abbrev("`varlist'",12)   ///
	_column(14)  "| "                         ///
	as result                                 ///
	%9.0g `r(mean)'   _skip(4)  ///
	%9.0g `SEmgfx'    _skip(4)  ///
	%6.0g `zstat'     _skip(4)  ///
	%5.4f `pvalue'    _skip(3)  ///
	%9.0g `IClow'     _skip(2)  ///
	%9.0g `IChig'

	di "--------------------------------------------------------------------------------"
	
	return local pval_AME `pvalue' 
	return local zst_AME `zstat'

	return local seAME `SEmgfx'
	return local AME  `r(mean)'

	return local ngr_AME `n_g'
	return local nobsAME `nnn'

end

