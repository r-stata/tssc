********************************************************************************************************************************
** Adjusted First-Differences Estimation of the Linear Discrete-Time Hazard Model **********************************************
********************************************************************************************************************************
*! version 1.1.1 2019-09-12 ht (Impropved Hadeling of Factor-Varibales)
*! version 1.1 2019-03-14 ht (Higher-Order Differences considered)
*! version 1.0 2019-01-29 ht
*! author Harald Tauchmann 
*! Linear Fixed-Effexts Discrete-Time Hazard Estimation
cap program drop xtlhazard
program xtlhazard, eclass
version 12
if !replay() {
	quietly {	
		** STORE COMMANDLINE ENTRY **
		local cmd "xtlhazard"
		local cmdline "`cmd' `*'"
		** DISPLAY-FORMAT for WARNINGS **
		local ls = c(linesize)-7
        ** SYNTAX **
		syntax varlist(ts fv) [if/] [in] [pweight fweight aweight iweight/], [Difference(integer 1)] [noABSORBing] [Robust] [CLuster(varname)] [VCE(string)] [IEffects(name)] [TOLerance(real 3)] [edittozero(real 0)] [noEOMITted] /*
        */ [LEVel(real `c(level)')] [noci] [noPValues] [noOMITted] [VSQUISH] [noEMPTYcells] [BASElevels] [ALLBASElevels] [noFVLABel] [fvwrap(integer 1)] [fvwrapon(string asis)] [CFORMAT(string asis)] [PFORMAT(string asis)] [SFORMAT(string asis)] [nolstretch]  
        ** TEMPNAMES and TEMPVARS **		
        tempname _borg _Vorg _wmat _empvec _bfdc _Vfdc _XdXd _XdXl _XdXdw _iadj _mataadj _adj _Adj _iAdj _bsm _bsmcopy _Vsm _adjrank _matr2 _matr2fd _wald _mgs
		tempvar _ly _fail _one _zero _fdesamp _fdfsamp _ww _resi _ife _iprob _diprob _iprob2 _groups _lhs
		** CHECK IF VARLIST INCLUDES TS or FV VARIABLES **
        fvrevar `varlist' `iff' `inn', list
        local exvarlist "`r(varlist)'"
        local fv : list local(varlist) === local(exvarlist)
        ** IDENTIFY lhs VARIABLE **
        tokenize "`varlist'"
        local lhs "`1'"
        tokenize "`lhs'", parse(".")
        if "`2'" != "" {
            noi di as error "{p 0 2 2 `ls'}factor-variable and time-series operators not allowed for depvar{p_end}"
            exit 101
        }
        ** CHECK PANEL-DATA DECLARATION
		_xt, treq
		local ivar "`r(ivar)'"
		local tvar "`r(tvar)'"
        ** CHECK IF RHS-VARIABLES ARE SPECIFIED **
        tokenize "`varlist'"
        if "`2'" == "" {
			noi di as error "{p 0 2 2 `ls'}at least one indepvar must be specified{p_end}"
			exit 102
        }
		** MANAGE IF
		if "`if'" != "" {
			local iff "if (`if')"
		}
		else {
			local iff "if (1==1)"
		}
		** MANAGE WEIGHT **
		if "`exp'" != "" {
			local eqs "="
		}
        ** MANAGE OPTION DIFFERENCE **
        if `difference' < 1 {
			noi di as error "{p 0 2 2 `ls'}option {bf: dif()} needs to be a strictly positive integer{p_end}"
			exit 198
        }
        ** MANAGE OPTION IEFFECTS **
        if "`ieffects'" != "" {
            confirm new variable `ieffects'
        }
        ** MANAGE DEFAULT VCE OPTION **
		if "`robust'" == "" & "`cluster'" == "" & "`vce'" == "" {
			local vce "robust"
		}
        ** MANAGE OPTIONS ROBUST and CLUSTER **
        if "`robust'" == "r" | "`robust'" == "ro" | "`robust'" == "rob" | "`robust'" == "robu" | "`robust'" == "robus" | "`robust'" == "robust" {
            local vce "robust"
        }
        if "`cluster'" != "" {
            local vce "cluster `cluster'"
        }
		local vce : list retokenize local(vce)
        tokenize "`vce'"
        if "`1'" == "cluster" | "`1'" == "cluste" | "`1'" == "clust" | "`1'" == "clus" | "`1'" == "clu" | "`1'" == "cl" {
            local clustvar "`2'"
        }
		** MANAGE OPTION VCE(MODEL) ** 
		local vce : subinstr local vce " ," ","
		tokenize "`vce'", parse(",")
		if ("`1'" == "mo" | "`1'" == "mod" | "`1'" == "mode" | "`1'" == "model") & "`3'" == "" {
			local vce "model"			
		}
		if ("`1'" == "mo" | "`1'" == "mod" | "`1'" == "mode" | "`1'" == "model") & ("`3'" == "f" | "`3'" == "fo" | "`3'" == "for" | "`3'" == "forc" | "`3'" == "force") {
			local vce "model, force"
		}
		if ("`1'" == "mo" | "`1'" == "mod" | "`1'" == "mode" | "`1'" == "model") & ("`3'" == "f" & "`3'" == "fo" & "`3'" != "for" & "`3'" != "forc" & "`3'" != "force" & "`3'" != "") {
			ereturn clear
			noi di as error "{p 0 2 2 `ls'}option vce(model, `3') not allowed{p_end}"
			exit 198
		}
        if "`vce'" == "model" | "`vce'" == "model, force" | ("`weight'" == "pweight" & "`vce'" == "ols") {
            local vceo "" 
        }
        else {
            local vceo "`vce'"        
        } 
		** CHECK WETHER lhs VAR IS BINARY **
        egen byte `_lhs' = group(`lhs') /*`in' `iff'*/ 
        replace `_lhs' = `_lhs'-1
        sum `_lhs'
        if `r(min)' != 0 | `r(max)' != 1 {
			noi di as error "{p 0 2 2 `ls'}depvar {bf: `lhs'} not binary{p_end}" 
			mata : st_rclear()
			exit 2000        
        }
		** CHECK ABSORBING STATE **
		gen byte `_ly' = l.`_lhs' `iff' & !missing(`_lhs') `in'
		count `iff' & (`_lhs' == 0 & `_ly' == 1) `in'
		if r(N) > 0 {
			count `iff' & (`_lhs' == 1 & `_ly' == 0) `in'
			if r(N) == 0 {
				noi di as error "{p 0 2 2 `ls'}recode depvar as ({bf: 1-`lhs'}){p_end}" 
				mata : st_rclear()
				exit 2000				
			}
			else {
				noi di as error "{p 0 2 2 `ls'}variable {bf: `lhs'} does not indicate an absorbing state{p_end}" 
				if "`absorbing'" != "noabsorbing" {
					mata : st_rclear()
					exit 198
				}
                else {
                    local irregular = 1
                }
			}
		}
        ** CHECK CODING of ABSORBING STATE **
        if "`absorbing'" != "noabsorbing" {
            gen byte `_fail' = 0
            replace `_fail' = 1 if (`_lhs' == 1 & `_ly' == 1)
        }
        else {
            gen byte `_fail' = 0
        }  
        local nfail  "& (`_fail' != 1)"
        ** DE-FACTOR-VARIABLERIZE VARLIST **
        local rhsvars : list local(varlist) - local(lhs)
        fvexpand `rhsvars' `iff' `nfail' `inn'
        local cn "`r(varlist)' _cons"
        local cn : list retokenize cn
        if `fv' == 0 {
            fvrevar `rhsvars' `iff' `nfail' `inn'
            local auxx "`r(varlist)'"
        }
        else {
            local auxx "`rhsvars'"
        }        
        local kko : list sizeof local(cn)
		** GENERATE AUXIALLARY VARS 1 and 0 **
		gen byte `_one' = 1
		gen byte `_zero' = 0
		** RUN UNADJUSTED FIRST-DIFFERENCED REGRESSION **
		cap reg D`difference'.(`_lhs' `auxx') `iff' `nfail' `in' [`weight' `eqs' `exp'], vce(`vceo')
		if _rc != 0 {
			cap noisily reg D`difference'.(`_lhs' `auxx') `iff' `nfail' `in' [`weight' `eqs' `exp'], vce(`vceo')
			ereturn clear
			exit 198
		}
		mat `_bfdc' = e(b)'
        ** CHECK FOR OMITTED VARIABLES **
        local cc = 0
        foreach vv in `auxx' _cons {
    	   local cc = 1 + `cc'
            if `_bfdc'[`cc',1] != 0 {
				local cnr "`cnr' `vv'"
				local noomc "`noomc' `cc'"
				if "`vv'" != "_cons" {
					local auxxr  "`auxxr' `vv'"
				}
            }     
        }
        if "`auxxr'" == "" {
    		noi di as error "{p 0 2 2 `ls'}no indepvar exhibits variation over time{p_end}" 
			ereturn clear
			exit 409        
        }
        ** RE-RUN UNADJUSTED FIRST-DIFFERENCED REGRESSION **
        local dlist : list local(auxx) - local(auxxr)
        if "`dlist'" != "" {
            local auxx "`auxxr'"
    		cap reg D`difference'.(`_lhs' `auxx') `iff' `nfail' `in' [`weight' `eqs' `exp'], vce(`vceo')
    		if _rc != 0 {
    			cap noisily reg D`difference'.(`_lhs' `auxx') `iff' `nfail' `in' [`weight' `eqs' `exp'], vce(`vceo')
    			ereturn clear
    			exit 198
    		}
    		mat `_bfdc' = e(b)'
        }
		mat `_Vfdc' = e(V)
		gen byte `_fdesamp' = 0
        replace `_fdesamp' = 1 if e(sample)
		local mssfd = e(mss) 
        local rssfd = e(rss) 
		local nobs = e(N)
		local cnfd : colfullnames `_bfdc'
        ** ISSUE WARNING IF OBS AFTER FAILURE ENTER ANALYSIS **
        if "`absorbing'" == "noabsorbing" {
            count if  `_fdesamp' == 1 & (`_lhs' == 1 & `_ly' == 1)
            if r(N) > 0 {
                noi di as error "{p 0 2 2 `ls'}obs. after absorbing state has been reached enter estimation sample; dorp option {bf: noabsorbing}{p_end}"  
                local aabs = 1
            }
        }
        ** CALCULATE NUMB of GROUPS WEIGHT-SUM and NUMB of CLUSTERS **
        by `ivar': egen `_groups' = total(`_one') if `_fdesamp' == 1
        replace `_groups' = 1/`_groups'
        tabstat `_groups' if `_fdesamp' == 1, statistics(sum) save
        mat `_mgs' = r(StatTotal)
        if "`weight'" != "" {
            gen `_ww' = `exp'
            tabstat `_ww' if `_fdesamp' == 1, stat(sum) save
            mat `_wmat' = r(StatTotal)
        } 
        if "`clustvar'" != "" {
            local N_clust = e(N_clust)
        }
		** CALCULATE ADJUSTMENT MATRIX **
		matrix accum `_XdXd' = D`difference'.(`auxx') `_one'                        if `_fdesamp' == 1 [`weight' `eqs' `exp'], noconst
		local kk = colsof(`_XdXd')
		local kk1 = 1+`kk'
		local kk2 = 2*`kk'
        if `difference' == 1 {
    		matrix accum `_XdXl' = D`difference'.(`auxx') `_one' L.(`auxx') `_zero' if `_fdesamp' == 1 [`weight' `eqs' `exp'], noconst
        }
        else {
            local gld ""
            foreach vv of varlist `auxx' {
                tempvar _gld`vv'
                gen `_gld`vv'' = `vv'- D`difference'.`vv'
                local gld "`gld' `_gld`vv''"
            }
            matrix accum `_XdXl' = D`difference'.(`auxx') `_one' `gld' `_zero' if `_fdesamp' == 1 [`weight' `eqs' `exp'], noconst
        }
    	matrix `_XdXl' = `_XdXl'[`kk1'..`kk2',1..`kk']
        mata : st_matrix("`_iadj'",edittozero(I(`kk')+luinv(st_matrix("`_XdXd'"), `tolerance')*st_matrix("`_XdXl'")',`edittozero')) 
		** EXIT IF ADJUSTMENT-MATRIX DOES NOT EXSIST **
		mata : st_matrix("`_adjrank'",rank(st_matrix("`_iadj'"), `tolerance'))
		if `_adjrank'[1,1] != `kk' {
            if `difference' == 1 {
                noi di as error "{p 0 2 2 `ls'}(I+inv(d.X'd.X)*d.X'l.X) singular; change model specification or specify option {bf: tolerance()}; try {bf: tolerance(0)} for figuring out which variables cause the problem{p_end}" 
            }
            else {
                noi di as error "{p 0 2 2 `ls'}(I+inv(d`difference'.X'd`difference'.X)*d`difference'.X'(X-d`difference'.X')) singular; change model specification or specify option {bf: tolerance()}; try {bf: tolerance(0)} for figuring out which variables cause the problem{p_end}" 
            }	
			ereturn clear
			mata : st_rclear()
			exit 506
		}
		mata : st_matrix("`_adj'",edittozero(luinv(st_matrix("`_iadj'"), `tolerance'),`edittozero')) 
		mat `_bsm' = (`_adj'*`_bfdc')'
		mat `_Vsm' = `_adj'*`_Vfdc'*`_adj''
		** GENERATE RESIDUAL **
		mat colnames `_bsm' = `auxx' `_one'
		mat `_bsmcopy' = `_bsm'
        mat colnames `_bsmcopy' = `auxx' _cons
		ereturn repost b = `_bsmcopy', rename
		predict `_iprob', xb
		gen `_resi' = `_lhs'- `_iprob'
		** CALCULATE R-SQUARED (X-LEVEL) **
		tabstat `_lhs' if `_fdesamp' == 1, statistics(variance) save
		mat `_matr2' = r(StatTotal)
		tabstat `_iprob' if `_fdesamp' == 1, statistics(variance) save
		mat `_matr2' = invsym(`_matr2')*r(StatTotal)
		local scar2 = `_matr2'[1,1]
		local scaadjr2 = 1-((`nobs'-1)/(`nobs'-`kk'))*(1-`scar2')
		** CALCULATE R-SQUARED (X-FIRST-DIFFERENCES) **
        sum D`difference'.`_lhs' if `_fdesamp' == 1
        local tss = r(Var)
        gen `_diprob' = D`difference'.`_iprob' + _b[_cons]
        sum `_diprob' if `_fdesamp' == 1
		local scar2fd = r(Var)/`tss'
		local scaadjr2fd = 1-((`nobs'-1)/(`nobs'-`kk'))*(1-`scar2fd')
		** ESTIMATE INDIVIDAUL FIXED EFFECTS **
		if "`ieffects'" != "" | "`vce'" == "model" | "`vce'" == "model, force" {
            local fdf "`_fdesamp' == 1"
            forvalues ff = 1(1)`difference' {
                local fdf "`fdf' | F`ff'.`_fdesamp' == 1"
            }
			gen byte `_fdfsamp' = (`fdf') 
			by `ivar': egen `_ife' = mean(`_resi') if `_fdfsamp' == 1 			
			replace `_ife' = `_ife'+ `_bsm'[1,`kk'] if `_fdfsamp' == 1
			if "`ieffects'" != "" {
				gen `ieffects' = `_ife' if `_fdfsamp' == 1
                label variable `ieffects' "estimated individual fixed effect"
			}
			** CALCULATE VCE(MODEL) VARIANCE **
			if "`vce'" == "model" | "`vce'" == "model, force" {
				replace `_iprob' = `_iprob'-`_bsm'[1,`kk']+ `_ife' if `_fdesamp' == 1
				gen `_iprob2' = (`_iprob')*(1-`_iprob') if `_fdesamp' == 1	
				sum `_iprob2' if `_fdesamp' == 1
				if r(min) < 0 & "`vce'" == "model" {
					noi di as error "{p 0 2 2 `ls'}variance estimates ouside valide range; do not use option {bf: vce(model)}{p_end}"
					ereturn clear
					mata : st_rclear()
					exit 402
				}
				else {
					replace `_iprob2' = max(0,`_iprob2')
					noi di as error "{p 0 2 2 `ls'}warning: variance estimates ouside valide range; inalid variances set to zero{p_end}"
                    if "`fv'" == "fv" {
    				    foreach vv in `auxx' {
    						tempvar _nvd
    						gen `_nvd' = (`_iprob2')^0.5*(D`difference'.`vv')
    						replace `vv' = `_nvd'
    						cap drop `_nvd'
    					}
                    }
                    else {
                        local cc = 0
    					foreach vv in `auxx' {
                            local cc = `cc'+1
                            tempvar _x`cc'
                            gen `_x`cc'' = (`_iprob2')^0.5*(D`difference'.`vv')
                            local auxx2 "`auxx2' `_x`cc''"
                        } 
                        local auxx "`auxx2'"
                    }
					replace `_one' = (`_iprob2')^0.5*`_one'
					matrix accum `_XdXdw' = `auxx' `_one' if `_fdesamp' == 1 [`weight' `eqs' `exp'], noconst
					mat `_Vsm' = (r(N)/`nobs')*`_adj'*invsym(`_XdXd')*(`_XdXdw')*invsym(`_XdXd')*`_adj''
				}
			}
		}
		** WRITE NON-ZERO ENTRIES TO e(b) AND Var(b) **
        mat `_adj' = `_adj''
        mat `_iadj' = `_iadj''
        if "`eomitted'" != "noeomitted" {
            mat `_borg' = J(1,`kko',0)
            mat colnames `_borg' = `cn'
            mat `_Vorg' = J(`kko',`kko',0)
            mat colnames `_Vorg' = `cn'
            mat rownames `_Vorg' = `cn'
            mat `_Adj' = J(`kko',`kko',0)
            mat colnames `_Adj' = `cn'
            mat rownames `_Adj' = `cn'
            mat `_iAdj' = J(`kko',`kko',0)
            mat colnames `_iAdj' = `cn'
            mat rownames `_iAdj' = `cn'
    		local ii = 0
    		foreach cc in `noomc' {
    			local jj = 0
    			local ii = `ii' +1
    			mat `_borg'[1,`cc'] = `_bsm'[1, `ii']
    			foreach rr in `noomc' {
    				local jj = `jj' +1
    				mat `_Vorg'[`rr',`cc'] = `_Vsm'[`jj', `ii']
                    mat `_Adj'[`rr',`cc'] = `_adj'[`jj', `ii']
                    mat `_iAdj'[`rr',`cc'] = `_iadj'[`jj', `ii']
    			}
            }
        }
        ** CHANGE ROW AND COLUMNAMES OF ADJUSTMENT MATRIX **
        else {
            tokenize `cn'		
            foreach cc in `noomc' {
                local scn "`scn' ``cc''"
            }
            mat `_borg'  = `_bsm'
            mat colnames `_borg' = `scn'
            mat `_Vorg' = `_Vsm'
            mat colnames `_Vorg' = `scn'
            mat rownames `_Vorg' = `scn'
            mat `_Adj' = `_adj'
            mat colnames `_Adj' = `scn'
            mat rownames `_Adj' = `scn'
            mat `_iAdj' = `_iadj'
            mat colnames `_iAdj' = `scn'
            mat rownames `_iAdj' = `scn'
        }
		** CARRY OUT WALD TEST **
		local kkm = `kk'-1
		mat `_bsm' = `_bsm'[1,1..`kk'-1]
		mat `_Vsm' = `_Vsm'[1..`kk'-1,1..`kk'-1]
        mata : st_matrix("`_wald'",st_matrix("`_bsm'")*qrinv(st_matrix("`_Vsm'"), `tolerance')*st_matrix("`_bsm'")')
		local chi2 = `_wald'[1,1]
		local p = chi2tail(`kk'-1,`chi2')
		** POST RESULTS TO e() **
		ereturn post `_borg' `_Vorg', properties(b V) obs(`nobs') esample(`_fdesamp')
		** SCALARS in e() **
        ereturn scalar N = round(`nobs')
        ereturn scalar N_g = round(`_mgs'[1,1])
        ereturn scalar difference = `difference'
		ereturn scalar chi2 = `chi2'
		ereturn scalar p = `p'
		ereturn scalar r2 = `scar2fd'
		ereturn scalar r2_a = `scaadjr2fd'
		ereturn scalar r2_lev = `scar2'
		ereturn scalar r2_a_lev = `scaadjr2'
		ereturn scalar df_m = `kk'-1
		ereturn scalar rank = `_adjrank'[1,1]
		ereturn scalar tolerance = `tolerance'
        ereturn scalar level = `level'
        if "`absorbing'" == "noabsorbing" {
            if "`irregular'" == "1" {
                ereturn scalar irregular = 1
            }
            else {
                if "`aabs'" == "1" {
                    ereturn scalar irregular = -1
                }
                else {
                    ereturn scalar irregular = 0
                }
            }
        }
        ** MATRICES in e() **
        ereturn matrix invAdjust = `_iAdj'
        ereturn matrix Adjust = `_Adj'
		** MACROS in e() **
		ereturn local cmd `cmd'
		ereturn local cmdline `cmdline'
		ereturn local title "Adjusted first-differences linear discrete-time hazard estimation"
		if "`weight'" != "" {			
            ereturn local wexp  "=`exp'"
            ereturn local wtype "`weight'"
            ereturn scalar wgtsum = `_wmat'[1,1]
		}
        if "`vce'" == "robust" | ("`weight'" == "pweight" & "`vce'" == "ols") {
			ereturn local vcetype "Robust"
			ereturn local vcest "robust"
        }
        if "`clustvar'" != "" {
			ereturn local vcetype "Clustered"
			ereturn local vcest "cluster"
            ereturn local clustvar "`clustvar'"
            ereturn scalar N_clust = round(`N_clust')
        }
        if "`vce'" == "model" | "`vce'" == "model, force" {
			ereturn local vcetype "Model"
			ereturn local vcest "model"
            if "`vce'" == "model, force" {
                ereturn local force "force"
            }
        }
        if "`vce'" == "ols" & "`weight'" != "pweight" {
			ereturn local vcetype "OLS"
			ereturn local vcest "ols"
        }
        ereturn local depvar "`lhs'"
        ereturn local chi2type "Wald"
        ereturn local predict "regres_p"
        ereturn local marginsok "XB default"
        ereturn local ivar "`ivar'"
        ereturn local tvar "`tvar'"
        **ereturn local header1 "Linear discrete-time hazard model"
        **ereturn local header2 "Adjusted first-differences estimation"
	}
    ** DISPLAY RESULTS **
    local statskip = 46
    local equalskip = 68
    local statend = 70
    ** FV-DISPLAY OPTIONS DEPENDING ON STATA VERSION **
    if `c(stata_version)' < 14 {
        local fvdisp ""
    }
    else {
        local fvdisp `"`fvlabel' fvwrap(`fvwrap') fvwrapon(`fvwrapon')"'
    }
    if "`e(wtype)'" != "" {
       di as text "(sum of wgt is" as text %10.7e `e(wgtsum)' as text ")"
    }
    ** DISPLAY ORDER of DIFFERENCE IN OUTPUT **
    local r2d = `e(difference)'
    if `e(difference)' == 1 {
        local odiff `"as text "first""'
        local r2d "f"
    }
    if `e(difference)' == 2 {
        local odiff `"as result `e(difference)' as text "nd""'
    }
    if `e(difference)' == 3 {
        local odiff `"as result `e(difference)' as text "rd""'
    }
    if `e(difference)' >= 4 {
        local odiff `"as result `e(difference)' as text "th""'
    }   
    di _newline as text "Linear discrete-time hazard model" _continue
    di          _column(`statskip') as text "Number of obs"                                      _column(`equalskip') as text  "=" _column(`statend') as result %9.0gc `e(N)'
    di as text "Adjusted " `odiff' as text "-differences estimation" _continue
    di          _column(`statskip') as text "Number of groups"                                   _column(`equalskip') as text  "=" _column(`statend') as result %9.0gc `e(N_g)'
    if "`e(irregular)'" == "1" {
        di      as text "depvar" as error " inconsistent" as text " with hazard model" _continue
    }
    if "`e(irregular)'" == "-1" {
        di      as error "obs. after abs. state reached considered" _continue
    }
    di          _column(`statskip') as text "Wald chi2(" as result %1.0f `e(df_m)' as text ")"   _column(`equalskip') as text  "=" _column(`statend') as result %9.2f  `e(chi2)'
    di          _column(`statskip') as text "Prob > chi2"                                        _column(`equalskip') as text  "=" _column(`statend') as result %9.3f  `e(p)'
    di          _column(`statskip') as text "Pseudo R-sq (`r2d'd)"                               _column(`equalskip') as text  "=" _column(`statend') as result %9.3f  `e(r2))' 
    di          _column(`statskip') as text "Pseudo R-sq (level)"                                _column(`equalskip') as text  "=" _column(`statend') as result %9.3f  `e(r2_lev))' _newline
    ereturn display, level(`level') `ci' `pvalues' `omitted' `vsquish' `emptycells' `baselevels' `allbaselevels' `fvdisp' cformat(`cformat') pformat(`pformat') sformat(`sformat') `lstretch'
}
** REPLAY RESULTS **
else {
	if "`e(cmd)'" != "xtlhazard" {
		error 301
	}
    else {
        syntax, [LEVel(real `e(level)')] [noci] [noPValues] [noOMITted] [VSQUISH] [noEMPTYcells] [BASElevels] [ALLBASElevels] [noFVLABel] [fvwrap(integer 1)] [fvwrapon(string asis)] [CFORMAT(string asis)] [PFORMAT(string asis)] [SFORMAT(string asis)] [nolstretch]  
     
        ** DISPLAY RESULTS **
        local statskip = 46
        local equalskip = 68
        local statend = 70
        ** FV-DISPLAY OPTIONS DEPENDING ON STATA VERSION **
        if `c(stata_version)' < 14 {
            local fvdisp ""
        }
        else {
            local fvdisp `"`fvlabel' fvwrap(`fvwrap') fvwrapon(`fvwrapon')"'
        }
        if "`e(wtype)'" != "" {
           di as text "(sum of wgt is" as text %10.7e `e(wgtsum)' as text ")"
        }
        ** DISPLAY ORDER of DIFFERENCE IN OUTPUT **
        local r2d = `e(difference)'
        if `e(difference)' == 1 {
            local odiff `"as text "first""'
            local r2d "f"
        }
        if `e(difference)' == 2 {
            local odiff `"as result `e(difference)' as text "nd""'
        }
        if `e(difference)' == 3 {
            local odiff `"as result `e(difference)' as text "rd""'
        }
        if `e(difference)' >= 4 {
            local odiff `"as result `e(difference)' as text "th""'
        }   
        di _newline as text "Linear discrete-time hazard model" _continue
        di          _column(`statskip') as text "Number of obs"                                      _column(`equalskip') as text  "=" _column(`statend') as result %9.0gc `e(N)'
        di as text "Adjusted " `odiff' as text "-differences estimation" _continue
        di          _column(`statskip') as text "Number of groups"                                   _column(`equalskip') as text  "=" _column(`statend') as result %9.0gc `e(N_g)'
        if "`e(irregular)'" == "1" {
            di      as text "depvar" as error " inconsistent" as text " with hazard model" _continue
        }
        if "`e(irregular)'" == "-1" {
            di      as error "obs. after abs. state reached considered" _continue
        }
        di          _column(`statskip') as text "Wald chi2(" as result %1.0f `e(df_m)' as text ")"   _column(`equalskip') as text  "=" _column(`statend') as result %9.2f  `e(chi2)'
        di          _column(`statskip') as text "Prob > chi2"                                        _column(`equalskip') as text  "=" _column(`statend') as result %9.3f  `e(p)'
        di          _column(`statskip') as text "Pseudo R-sq (`r2d'd)"                               _column(`equalskip') as text  "=" _column(`statend') as result %9.3f  `e(r2))' 
        di          _column(`statskip') as text "Pseudo R-sq (level)"                                _column(`equalskip') as text  "=" _column(`statend') as result %9.3f  `e(r2_lev))' _newline
        ereturn display, level(`level') `ci' `pvalues' `omitted' `vsquish' `emptycells' `baselevels' `allbaselevels' `fvdisp' cformat(`cformat') pformat(`pformat') sformat(`sformat') `lstretch'
    }
}
end
