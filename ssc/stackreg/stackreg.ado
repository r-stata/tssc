********************************************************************************************************************************
** STACKED REGRESSION ANALYSIS for MULTIPLE TESTING (Michael Oberfichtner & Harald Tauchmann) **********************************
********************************************************************************************************************************
*! version 1.3.2 2020-04-18 /*  minimal editing to zero of varaiance-covariance matrix */ 
*! version 1.3.1 2020-02-20 /* fix for matrix-functions under Stata < 16 */
*! version 1.3 2020-01-27 /* constrained estimation */
*! version 1.2.4 2020-01-16 /* option sreshape */
*! version 1.2.3 2019-11-12 /* renaming equations for more than 10 depvars fixed */
*! version 1.2.2 2019-11-05 /* revised option df() */
*! version 1.2.1 2019-11-03 /* revised degrees-of-freedom correction */
*! version 1.2 2019-10-18 /* option fe: within-transformation */
*! version 1.1.1 2019-10-17 /* degrees-of-freedom correction */
*! version 1.1 2019-10-09 /* cgmreg as alt. to regress */
*! version 1.0 2019-09-17
cap program drop stackreg
program stackreg, eclass
** CHECK VERSION (For Handling Unicode Variables) **
if `c(stata_version)' < 14 {
    local subinstr "subinstr"
    local strlen "strlen"
    local strpos "strpos"
    local strrpos "strrpos"
    version 12
}
else {
    local subinstr "subinstr"
    local strlen "ustrlen"
    local strpos "ustrpos"
    local strrpos "ustrrpos"
    version 14
}
if !replay() {
		quietly {	
    		** STORE COMMANDLINE ENTRY **
    		local cmd "stackreg"
    		local cmdline "`cmd' `*'"
    		** DISPLAY-FORMAT for WARNINGS **
    		local ls = c(linesize)-7
    		** SYNTAX **
    		syntax anything(equalok) [if/] [in] [pweight fweight aweight iweight/], [CLUster(varlist)] [DEPName(string asis)] [noCONStant] [noCOMmon] [FE] [DF(string asis)] [Wald] [SReshape] [FAVORSpace(integer 0)] [Constraints(numlist integer)] [EDITtozero(real 1)] /*
    		*/ [LEVel(real `c(level)')] [noci] [noPValues] [OMITted] [EMPTYcells] [VSQUISH] [BASElevels] [ALLBASElevels] [noFVLABel] [fvwrap(passthru)] [fvwrapon(passthru)] [CFORMAT(passthru)] [PFORMAT(passthru)] [SFORMAT(passthru)] [nolstretch]   
    		** TEMPORARY VARIABLES **    
    		tempvar _one _tempw _depname _exp _tempid _esamp _clust
    		** TEMPORARY OBJECTS **
    		tempname _bb _VV _dofeq _rank _VVk _Cns _Mcns _tVV _tbb _tdfc
            ** TEMPFILES **
    		tempfile _esampfile 
            if "`fe'" == "fe" {
               tempfile _nowitrans _witrans _witransk 
               tempvar _tag
            }
            ** PARSE ANYTHING **
            tokenize `anything', parse("=")
            if "`4'" != "" | ("`2'" != "=" & "`2'" != "==") | "`1'" == "" | "`3'" == "" {
    			noi di as error "{p 0 2 2 `ls'}invalid syntax, check how '{bf:=}' enters command{p_end}"
    			exit 198
    		}
            local lhsvars "`1'"
            local rhsvars "`3'"
            ** CHECK THAT lhsvars AND rhsvars ARE MUTUALLY EXCLUSIVE **
            local exclul : list lhsvars & rhsvars
            if "`exclul'" != "" {
                noi di as error "{p 0 2 2 `ls'}{bf:`exclul'} element of depvars and indepvars, must be mutually exclusive{p_end}"
				exit 198
            }
            ** HANDLE OPTION DF() **
            if "`df'" == "" {
                local df "adjust"
            }
            if "`df'" != "adjust" & "`df'" != "raw" & "`df'" != "areg" {
                noi di as error "{p 0 2 2 `ls'}dftype {bf:`df'} not allowed{p_end}"
				exit 198            
            } 
			** HANDLE OPTION DEPNAME **
			if "`depname'" == "" {
				local depname "__x"
			}
			** CONFIRM THAT POTENTIAL VARIABLE NAMES DO NOT CAUSE PROBLEMS **
			local _varabbrev = c(varabbrev)
			set varabbrev on
			capture unab varnew: `depname'*
			if _rc == 0 {
				noi di as error "{p 0 2 2 `ls'}data must not contain variables starting with prefix `depname'. Please specify alternative prefix using the option depname.{p_end}"
				exit 198
			}
			set varabbrev `_varabbrev'
            ** HANDLE OPTION NOCONSTANT **
            if "`constant'" != "noconstant" {
                local consn "_cons"
                local consv "_one"
                local consr "c."
            }
            ** HANDLE OPTIONS EMPTYCELLS OMITTED **
            if "`emptycells'" == "" {
                local emptycells "noemptycells"
            }
            if "`omitted'" == "" {
                local omitted "noomitted"
            }
            ** HANDLE OPTION FAVORSPACE **
            if "`sreshape'" == "sreshape" {
                if `favorspace' < 0 | `favorspace' > 4 {
                    local favorspace = 0
                }
            }     
            ** SAVE TEMPORARY ID-VARIABLE **
            gen double `_tempid' = _n
            ** STORE ORIGINAL DATA **
    		preserve
    		** MANAGE OPTION if
    		if "`if'" != "" {
    			local iff "if `if'"
    		}
    		else {
    			local iff ""
    		}	
    		** MANAGE OPTION in
    		if "`in'" != "" {
    			local inn "in `in'"
    		}
    		else {
    			local inn ""
    		}
    		** MANAGE WEIGHT **
    		if "`exp'" != "" {
    			gen `_tempw' = `exp'
    			local wvar "`_tempw'"
    			local wexp "[`weight' = `_tempw']"
    		}
            ** CHECK PANEL-DATA DECLARATION if OPTION FE is SPECIFIED **
            if "`fe'" == "fe" {
                _xt
                local ivar "`r(ivar)'"
                local tvar "`r(tvar)'"
                if "`cluster'" == "" & "`df'" != "areg" {
                    local cluster "`ivar'"
                } 
            }
            ** MANAGE OPTION CLUSTER **
             if "`cluster'" == "" {
                local cluster "`_tempid'"
            }
            confirm variable `cluster'
            local kclust : list sizeof local(cluster) 
            if `kclust' == 1 {
                local estimator "regress"
                local max ""
            }
            else {
                cap which cgmreg
                if _rc != 0 {
                    noi display as error "{p 0 2 2 `ls'}multi-way clustering reqires cgmreg.ado to be installed{p_end}"
                    exit 198
                }
                else {
                    local estimator "cgmreg"
                }
            }
            ** CHECK OPTION FOR OPTION-CLASH: CONSTRAINTS vs. CLUSTER **
            if "`constraints'" != "" {
                if "`estimator'" == "cgmreg" {
                    noi display as error "{p 0 2 2 `ls'}option constraints() cannot be combined with multi-way clustering{p_end}"
                    exit 198
                }
                else {
                    local estimator "cnsreg"
                }
            }
            else {
                local dropconst "noconstant"
            }
    		** CHECK IF lhs-VARIABLES ARE SPECIFIED **
    		if "`lhsvars'" == "" {
    			noi di as error "{p 0 2 2 `ls'}at least one x variable must be specified{p_end}"
    			exit 102
    		}
            ** GENERATE CONSTANT **
            cap gen byte `_one' = 1
    		** CHECK IF LHSVARS INCLUDES TS or FV VARIABLES **
            fvrevar `lhsvars' `iff' `inn', list
            local blhsvars "`r(varlist)'"
            local fv : list local(lhsvars) === local(blhsvars)
    		** IF VARLIST does NOT INCLUDE FACTOR-VARIABLES **
    		if `fv' == 1 {
                local cnl "`lhsvars'"
                local cnl : list retokenize cnl
    			local cc 0
    			local xkeep ""
    			foreach vv of varlist `lhsvars' {
    				local cc = `cc'+1
    				rename `vv' `_depname'`cc'
    				local xkeep "`xkeep' `_depname'`cc'"
    			}
    		}
    		** IF FACTOR-VARIABLES INCLUDED in LHSVARS **
    		if `fv' == 0 { 
    			** HANDLE FACTORVARIABLES **
                fvexpand `lhsvars' `iff' `inn'
                local cnl "`r(varlist)'"
                local cnl : list retokenize cnl
                fvrevar `lhsvars' `iff' `inn'
                local tlhsvars "`r(varlist)'"
    			local cc 0
    			local xkeep ""
    			foreach vv of varlist `tlhsvars' {
    				local cc = `cc'+1
    				rename `vv' `_depname'`cc'
    				local xkeep "`xkeep' `_depname'`cc'"
    			}
    		}
    		** NUMBER of LHS-VARIABLES **
    		local kk: list sizeof local(cnl) 
    		** CHECK IF RHS-VARS INCLUDES TS or FV VARIABLES **
            fvrevar `rhsvars' `iff' `inn', list
            local brhsvars "`r(varlist)'"
            local fv : list local(rhsvars) === local(brhsvars)
            if `fv' == 1 {
                local cnr "`rhsvars' `consn'"
                local cnr : list retokenize cnr
                local rhskeep "`rhsvars'"
            }
            else {
                fvexpand `rhsvars' `iff' `inn'
                local cnr "`r(varlist)' `consn'"
                local cnr : list retokenize cnr
                fvrevar `rhsvars' `iff' `inn', list
                local rhskeep "`r(varlist)'"
            }
    		** NUMBER of RHS-VARIABLES **
    		local jj : list sizeof local(cnr)
    		** KEEP ONLY REQUIRED OBSERVATIONS **
    		if "`if'" != "" | "`in'" != "" {
    			keep `iff' `inn'
    		}
    		** KEEP ONLY REQUIRED VARIABLES **
            if "`fe'" != "fe" {
                keep `_tempid' `xkeep' `rhskeep' `wvar' `_one' `cluster'
            }
            else {
                keep `_tempid' `xkeep' `rhskeep' `wvar' `_one' `cluster' `ivar' `tvar'
            }
            ** DROP OBS. WITH ANY MISSINGS in RHS (WEIGHT, CLUSTER and PANEL) VARIABLES ** 
            foreach vv of varlist `rhskeep' `wvar' `cluster' `_one' `r(ivar)' {
                local rhscom "`rhscom' & `vv' <."
            }
            keep if `_tempid' <. `rhscom'
    		** DROP OBS WITH ANY MISSINGS in LHS VARIBALES IF OPT. COMMON and DETERMINE ORG. SAMPLE-SIZE **
            if "`common'" != "nocommon" {
                local bool "&"
            }
            else {
                local bool "|"
            }
            foreach vv of varlist `xkeep' {
                local lhscom "`lhscom' `bool' `vv' <."
            }
            if "`common'" != "nocommon" {
                keep if `_tempid' <. `lhscom'
                local norg = _N 
            }
            else {
                count if `_tempid' >. `lhscom'
                local norg = r(N)
            }
    		** EXPAND ESTIMATION-SAMPLE using RESHAPE or SRESHAPE and KEEPING ONLY OBS. WITH NON-MISSING INOERMATION IN DEPVAR **
            if "`sreshape'" == "sreshape" {
                cap which sreshape
                if _rc == 0 & `c(stata_version)' >= 13 {
                    sreshape long `_depname', i(`_tempid') j(`_exp') missing(drop all) nopreserve favorspace(`favorspace')
                }
                else {
                    if _rc != 0 {
                        noi display as error "{p 0 2 2 `ls'}option sreshape reqires sreshape.ado to be installed; option sreshape ignored{p_end}"
                    }
                    if `c(stata_version)' < 13 {
                        noi display as error "{p 0 2 2 `ls'}sreshape.ado reqires stata version 13 or higher; option sreshape ignored{p_end}"
                    }
                    reshape long `_depname', i(`_tempid') j(`_exp')
                    keep if `_depname' <.               
                }
                else {
                    sreshape long `_depname', i(`_tempid') j(`_exp') missing(drop all) nopreserve favorspace(`favorspace')
                }            
            }
            else {
                reshape long `_depname', i(`_tempid') j(`_exp')
                keep if `_depname' <.
            }
            ** COMPRESS WORKING-DATA **
            compress
            if "`fe'" == "fe" {
                ** SORT (FOR LATER MERGE) IF WITHIN-TRANSORMATION IS APPLIED **
                sort `_exp' `_tempid'
            }
            ** FVVAR-SYNTAX FOR ESTIMATION **
            forvalues ss = `kk'(-1)1 {
                fvexpand i(`ss')`_exp'#c.(`rhsvars' `consr'``consv'')
                local regnamesk "`r(varlist)'"
                fvrevar i(`ss')`_exp'#c.(`rhsvars' `consr'``consv'')
                local reglistk "`r(varlist)'"   
                ** EUQATION-SPECIFIC OBSERVATION NUMBERS **
                if "`common'" == "nocommon" {
                    count if `_exp' == `ss'
                    local n_`ss' = r(N) 
                    if "`estimator'" != "cgmreg" {
                        egen `_clust' = tag(`cluster') if `_exp' == `ss' 
                        count if `_clust' 
                        local m_`ss' = r(N) 
                        cap drop `_clust'
                    }
                    else {
                        local m_`ss' =.
                        foreach vv of varlist `cluster' {
                            egen `_clust' = tag(`cluster') if `_exp' == `ss' 
                            count if `_clust' 
                            local m_`ss' = min(`m_`ss'',r(N)) 
                            cap drop `_clust'                        
                        }
                    }
                    if `ss' != `kk' & "`hetn'" != "1" {
                        local ssp = `ss'+1
                        if `n_`ss'' != `n_`ssp'' {
                            local hetn = 1 
                        }
                    }               
                }
                ** WITHIN-TRANSFORMATION **
                if "`fe'" == "fe" {
                    save `_nowitrans', replace 
                    keep if `_exp' == `ss'
                    egen `_tag' = tag(`ivar')
                    count if `_tag' 
                    local dffen = r(N)
                    if "`common'" == "nocommon" {
                        local i_`ss' = r(N)
                    }
                    local maxg = `dffen' 
                    xtdata `_depname' `reglistk', fe clear
                    if `ss' == `kk' {
                        local dffe = `dffen'
                        save `_witrans', replace
                    }
                    else {
                        local dffe = `dffe'+ `dffen'
                        local maxg = max(`dffen',`maxg') 
                        append using `_witrans'
                        save `_witrans', replace
                    }
                    use `_nowitrans', clear 
                }
                tokenize `reglistk'
                local reglistk ""
                local vv = 0
                foreach ww in `regnamesk' {
                    local vv = `vv'+1
                    **if (`strpos'("`ww'","b.") > 0 | `strpos'("`ww'","o.") > 0 | `strpos'("`ww'","bo.") > 0) & (`strpos'("`ww'","#") > 0 & `strpos'("`ww'","#") == `strrpos'("`ww'","#")) {
                    local zz "`ww'"
                    foreach gg in b. o. bo. {
                        local zz : `subinstr' local zz "`gg'" " ", all  
                    }
                    local uu : `subinstr' local ww "#" " ", all
                    if wordcount("`zz'") >= wordcount("`uu'") {
                        local reglistk "`reglistk' o.``vv''"                
                    }
                    else {
                        local reglistk "`reglistk' ``vv''"
                    }
                }
                local regnames "`regnamesk' `regnames'"
                local reglist "`reglistk' `reglist'"
            }
            ** REPLACE EXPANDED VARS. BY WITHIN-TRANSFORMED COUNTERPARTs **
            if "`fe'" == "fe" {
                merge 1:1 _n using `_witrans', replace update nogenerate 
            }
            ** TRANSLATE CONSTRAINTS if SPECIFIED **
            if "`constraints'" != "" {
                foreach cc in `constraints' {
                    constraint get `cc'
                    if `r(defined)' == 0 {
                        continue
                    }
                    local cnss "`r(contents)'"
                    ** SET SPACES **
                    foreach char in = + - * / ( ) {
                        local cnss : `subinstr' local cnss "`char'" " `char' ", all
                    }
                    local cnss : list retokenize cnss                    
                    local cnss : `subinstr' local cnss "[ " "[", all
                    local cnss : `subinstr' local cnss " ]" "]", all
                    tokenize `cnl'
                    local tvns "`reglist'"
                    foreach mm in `regnames' {
                        gettoken tvs tvns : tvns
                        local tvns : list local(tvns) - local(tvs)
                        gettoken eqnc regc: mm, parse(".")
                        local eqnm "``eqnc''"
                        gettoken hash regc: regc, parse("#")
                        gettoken hash regc: regc, parse("#")
                        local regc : `subinstr' local regc "c." "", all
                        local vcns "[`eqnm']`regc'"
                        local cnss : `subinstr' local cnss "`vcns'" "`tvs'", word
                    }
                    constraint free
                    constraint `r(free)' `cnss'
                    local cnstrans "`cnstrans' `r(free)'"
                }
                if "`constant'" != "noconstant" {
                    local reglist : list local(reglist) - local(tvs)
                }
                else {
                    local dropconst "noconstant"
                }
                local cnssyntax "constraints(`cnstrans')"
            }
    		** RUN STACKED REGRESSION with CLUSTER-ROBUST STANDARD-ERRORS **
            cap `estimator' `_depname' `reglist' `wexp', cluster(`cluster') level(`level') `dropconst' `max' `cnssyntax'
            if _rc != 0 {
                if "`estimator'" == "cnsreg" {
                    noi di as error "{p 0 2 2 `ls'}constrained estimation failed; check specified constraints{p_end}"
                    ereturn clear
                    exit 111
                }
                else {
                    noi di as error "{p 0 2 2 `ls'}stacked regression failed{p_end}"  
                    ereturn clear
                    exit 198              
                }
            } 
            ** STORE e(V) AND e(b) AS TMP-MATRICES (required for stata versions < 16)
            matrix `_tbb' = e(b)
            matrix `_tVV' = e(V)  
            local df_m_hand = colsof(`_tbb')-diag0cnt(`_tVV')
            ** DETERMINE EQUATION-SPECIFIC NUMBER OF CONSTRAINTS & EQUATION-SPECIFIC RANKS **
            if "`estimator'" == "cnsreg" {
                mata : st_numscalar("`_rank'",rank(st_matrix("`_tVV'")))
                local df_m = `_rank'
                local step = colsof(`_tbb')/`kk'
                local fi = 1
                local la = `step'
                matrix `_Cns' = e(Cns)
                forvalues mm = 1(1)`kk' {
                    matrix `_Mcns' = (`_Cns'[1...,`fi'..`la'])*(`_Cns'[1...,`fi'..`la'])'
                    local rank_`mm' = `step'- (colsof(`_Mcns')- diag0cnt(`_Mcns')) 
                    local fi = `fi'+ `step'
                    local la = `la'+ `step'
                }            
            }
            ** DEGREES-OF-FREEDOM ADJUSTMENT **
            if "`df'" == "raw" {
                **matrix `_VV' = `_tVV'
                mata : st_matrix("`_VV'",edittozero(st_matrix("`_tVV'"),`edittozero'))
            }
            else {
                ** HOMOGENEOUS NUMBERS OF OBSERVATIONS & NO CONSTRAINTS **
                if ("`common'" != "nocommon" | ("`hetn'" != "1" & "`n_1'" == "`e(N)'")) & ("`cnssyntax'" == "") {
                    ** EXPANSION DEGREES-OF-FREEDOM ADJUSTMENT **
                    local dofcor = (`norg'-1)/(`norg' -1/`kk')
                    ** WITHIN-TRANSFORMATION DEGREES-OF-FREEDOM ADJUSTMENT **
                    if "`fe'" == "fe" {
                        local doffecor = (`norg' -(`df_m_hand')/`kk')/(`norg' -`dffe'/`kk' -(`df_m_hand')/`kk'+1) 
                    }
                    else {
                        local doffecor = 1
                    }
                    ** XTREG ANALOGUE DEGREES-OF-FREEDOM ADJUSTMENT **  
                    if "`fe'" == "fe" & "`df'" != "areg" {
                        local dofxtcor = (`norg' -`dffe'/`kk' -(`df_m_hand')/`kk' +1)/(`norg' -(`df_m_hand')/`kk') 
                    }
                    else {
                        local dofxtcor = 1
                    }
                    scalar `_tdfc' = `dofxtcor'*`doffecor'*`dofcor'
                    mata : st_matrix("`_VV'",edittozero(st_numscalar("`_tdfc'")*st_matrix("`_tVV'"),`edittozero'))
                }
                ** HETEROGENEOUS NUMBERS OF OBSERVATIONS or CONSTRAINTS **
                else {
                    if "`estimator'" != "cgmreg" {
                        local N_clust = e(N_clust)
                    }
                    else {
                        local N_clust =.
                        foreach vv of varlist `cluster' {
                            local N_clust = min(`N_clust',e(N_clus_`vv'),e(N_`vv'))      
                        }
                    }
                    if "`estimator'" != "cnsreg" {
                        local df_m = e(df_m)
                        if ("`fe'" != "fe" ) | ("`cluster'" == "`_tempid'") {
                            forvalues ss = 1(1)`kk' {
                                local gdf_`ss' = e(df_m)/`kk'
                            }
                        }
                        else {
                            forvalues ss = 1(1)`kk' {
                                local gdf_`ss' = (`df_m_hand')/`kk'
                            }
                        }
                    }
                    else {
                        forvalues ss = 1(1)`kk' {
                            local gdf_`ss' = `rank_`ss''
                        }                      
                        if "`common'" != "nocommon" {
                            forvalues ss = 1(1)`kk' {
                                local n_`ss' = e(N)/`kk'
                                if "`cluster'" != "`_tempid'" {
                                    local m_`ss' = e(N_clust)
                                }
                            }
                        }
                    }
                    matrix `_dofeq' = J(1,`kk',.)
                    forvalues ss = 1(1)`kk' {
                        ** EXPANSION DEGREES-OF-FREEDOM ADJUSTMENT **
                        if "`fe'" != "fe" {
                            if "`cluster'" == "`_tempid'" {
                                local dofcor = ((e(N)-`df_m')/(e(N)-1))*((`N_clust'-1)/`N_clust')*(`n_`ss''/(`n_`ss'' -`gdf_`ss''))
                            }
                            else {
                                local dofcor = ((e(N)-`df_m')/(e(N)-1))*((`N_clust'-1)/`N_clust')*(((`n_`ss''-1)/(`n_`ss'' -`gdf_`ss''))*(`m_`ss'')/(`m_`ss''-1))
                            }
                        }
                        else {
                            ** XTREG ANALOGUE DEGREES-OF-FREEDOM ADJUSTMENT **  
                            if "`cluster'" == "`_tempid'" {
                                local dofcor = ((e(N)-`df_m')/(e(N)-1))*((`N_clust'-1)/`N_clust')*(`n_`ss''/(`n_`ss'' -`i_`ss'' -`gdf_`ss'' +1)) 
                                if "`df'" != "areg" { 
                                    local dofcor = (`n_`ss'' -`i_`ss'' -`gdf_`ss''+1)/(`n_`ss'' -`gdf_`ss'')*`dofcor'
                                }
                            }
                            else {
                                local dofcor = ((e(N)-(`df_m_hand'))/(e(N)-1))*((`N_clust'-1)/`N_clust')*((`n_`ss''-1)/(`n_`ss'' -`i_`ss'' -`gdf_`ss''+1))*(`m_`ss''/(`m_`ss''-1))  
                                if "`df'" != "areg" { 
                                    local dofcor = (`n_`ss'' -`i_`ss'' -`gdf_`ss''+1)/(`n_`ss'' -`gdf_`ss'')*`dofcor'
                                }
                            }
                        }
                        matrix `_dofeq'[1,`ss'] = `dofcor'
                    }
                    matrix `_dofeq' = (vecdiag(diag(`_dofeq')#I(colsof(`_tbb')/`kk')))'*vecdiag(diag(`_dofeq')#I(colsof(`_tbb')/`kk'))
                    mata : st_matrix("`_VV'",edittozero((st_matrix("`_dofeq'"):^0.5):*st_matrix("`_tVV'"),`edittozero'))
                }
            }          
    		matrix `_bb' = `_tbb'
            tokenize `cnl' 
            ** RENAME COLUMNS of e(b): EQUATIONNAMES **
            forvalues mm = `kk'(-1)1 {
                foreach vv in `mm' `mm'b `mm'bn `mm'o `mm'bo `mm'bno {
                    local regnames : `subinstr' local regnames "`vv'.`_exp'#" "``mm'':", all
                }
            }
            if "`constant'" != "noconstant" {
                local regnames : `subinstr' local regnames "``consv''" "`consn'", all
                if "`constraints'" != "" {
                    local regnames : `subinstr' local regnames "``kk'':c._cons" "_cons", word
                }
            }
            matrix colnames `_bb' = `regnames'
            matrix rownames `_bb' = `_depname'
            matrix colnames `_VV' = `regnames'
            matrix rownames `_VV' = `regnames'
            ** MANAGE CONSTRAINTS **
            if "`constraints'" != "" {
                matrix colnames `_Cns' = `regnames' r
                local ecns "`_Cns'"
                constraint drop `cnstrans'
            }
            ** SCALARS TO BE STORED **
            local N_clust = e(N_clust)
            local N_stack = e(N)
            ** RESTORE ORG. SAMPLE and MERGE WITH e(sample) INDICATOR **
            gen `_esamp' = 1 if e(sample)
            keep `_tempid' `_esamp'
            sort `_tempid'
            keep if `_tempid' != `_tempid'[_n-1] | _n == 1
    		save `_esampfile'
            restore
            merge 1:1 `_tempid' using `_esampfile', nogenerate update replace force
            replace `_esamp' = 0 if `_esamp' != 1
            ** POST RESULTS **
            ereturn post `_bb' `_VV' `ecns', properties(b V) obs(`norg') esample(`_esamp') findomitted
            ** MACROS **
            ereturn local cmd `cmd'
            ereturn local cmdline `cmdline'
            ereturn local title "Stacked Regression"
            ereturn local predict "reg3_p"
            ereturn local marginsok "default XB E(passthru)"
            ereturn local depvar "`cnl'"
            ereturn local eqnames "`cnl'"
            foreach eq in `cnl' {
                local marginsdefault "`marginsdefault'predict(xb equation(`eq')) "
            }
            ereturn local marginsdefault "`marginsdefault'"
            if "`cluster'" != "`_tempid'" {
                ereturn local clustvar "`cluster'"
                if "`estimator'" == "cgmreg" {
                    ereturn local clusvar  "`cluster'"
                }
            }
            ereturn local vcetype "Clust. Robust"
    		if "`weight'" != "" {			
                ereturn local wexp  "=`exp'"
                ereturn local wtype "`weight'"
    		}
            ereturn local estimator "`estimator'"
            if "`fe'" == "fe" {
                ereturn local model "fe"
            }
            else {
                ereturn local model "ols"            
            }
            if "`hetn'" == "1" & "`n_1'" != "`norg'" {
                ereturn local common "nocommon"
            }
            else {
                ereturn local common "common"            
            }
            ** SCALARS **
            mata : st_numscalar("`_rank'",rank(st_matrix("e(V)")))
            ereturn scalar N = `norg'
            ereturn scalar k_eq = `kk'
            if "`fe'" == "fe" {
                ereturn scalar N_g = `maxg'
            }
            ereturn scalar rank = `_rank'
            if "`estimator'" != "cgmreg" {
                ereturn scalar N_clust = `N_clust'
            }
            ereturn scalar N_stack = `N_stack'
            ** EQUATION-SPECIFIC e(N), e(rank), e(df_r), and e(df_m) **
            matrix `_VV' = e(V)
            local grank = 0
            forvalues gg = 1(1)`kk' {
                if "`estimator'" != "cnsreg" {
                    local rf = (`gg'-1)*(colsof(`_VV')/`kk')+1
                    local rl =     `gg'*(colsof(`_VV')/`kk')
                    matrix `_VVk' = `_VV'[`rf'..`rl',`rf'..`rl']
                    mata : st_numscalar("`_rank'",rank(st_matrix("`_VVk'")))
                    local rank_`gg' = `_rank'
                }
                if ("`hetn'" == "1" & "`n_1'" != "`norg'") | ("`estimator'" == "cnsreg") {
                    if ("`hetn'" == "1" & "`n_1'" != "`norg'") {
                        ereturn scalar N_`gg' = `n_`gg''
                    }
                    ereturn scalar rank_`gg' = `rank_`gg''
                    if ("`wald'" != "wald") & ("`hetn'" == "1" & "`n_1'" != "`norg'") {
                        ereturn scalar df_r_`gg' = `m_`gg'' -1
                    }
                    if "`constant'" == "noconstant" {
                        ereturn scalar df_m_`gg' = `rank_`gg''
                    }
                    else {
                        ereturn scalar df_m_`gg' = `rank_`gg'' -1
                    }
                }
                local grank = max(`grank',`_rank') 
            }
            ** OVERALL e(df_r), and e(df_m) **
            if ("`common'" != "nocommon" | ("`hetn'" != "1" & "`n_1'" == "`norg'")) & ("`estimator'" != "cnsreg") { 
                if "`wald'" != "wald" & "`estimator'" != "cgmreg" {
                    ereturn scalar df_r = `N_clust'-1
                }
                if "`constant'" == "noconstant" {
                    ereturn scalar df_m = `grank'
                }
                else {
                    ereturn scalar df_m = `grank' -1
                }
            }
            ereturn scalar level = `level'
    	}
    }
	** DISPLAY RESULTS **
    if "`e(estimator)'" != "cnsreg" {
        local name "Stacked"
        local name2 "regression"
    }
    else {
        local name "Constrained stacked"
        if "`e(model)'" != "fe" {
            local name2 "regression"
        }
        else {
            local name2 "reg."
        }
    }
    local skip2 = 52
	local skip3 = floor(`e(N)')
	local skip3 = `strlen'("`skip3'")-1
    if "`e(model)'" == "fe" {
        di _newline as text "`name' within-transformed linear `name2'"     _column(`skip2')  "Number of obs    = " _column(`skip3') as result as result %8.0fc `e(N)'  
        di          as text                                                _column(`skip2')  "Number of groups = " _column(`skip3') as result as result %8.0fc `e(N_g)' _newline
    }
    else {
	   di _newline as text "`name' linear `name2'" _column(`skip2')  "Number of obs    = " _column(`skip3') as result as result %8.0fc `e(N)' _newline 
    }
    ** di _skip as text "(Std. Err. adjusted for " as result `e(N_clust)' as text " clusters in `e(clustvar)')"
    if replay() {
        syntax, [LEVel(real `e(level)')] [noci] [noPValues] [OMITted] [EMPTYcells] [VSQUISH] [BASElevels] [ALLBASElevels] [noFVLABel] [fvwrap(passthru)] [fvwrapon(passthru)] [CFORMAT(passthru)] [PFORMAT(passthru)] [SFORMAT(passthru)] [nolstretch]  
        ** HANDLE OPTIONS EMPTYCELLS OMITTED for REPLAY **
        if "`emptycells'" == "" {
            local emptycells "noemptycells"
        }
        if "`omitted'" == "" {
            local omitted "noomitted"
        }      
    }
    ereturn display, level(`level') `ci' `pvalues' `omitted' `vsquish' `emptycells' `baselevels' `allbaselevels' `fvlabel' `fvwrap' `fvwrapon' `fvdisp' `cformat' `pformat' `sformat' `lstretch'          
end
