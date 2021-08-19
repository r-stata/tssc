**********************************************************************
** lmtest: LAGRANGE-MULTIPLIER TEST AFTER CONSTRAINED ML ESTIMATION **
**********************************************************************
*! version 1.5 2020-12-20 ht /* handling of variable containing nonselection hazard (heckman) */
*! version 1.4 2020-12-19 ht /* handling of vcetype */
*! version 1.3 2020-12-18 ht /* options df() and noomitted */
*! version 1.2 2020-12-17 ht /* handling of vcetype */
*! version 1.1 2020-12-15 ht /* display expanded constraints */
*! version 1.0 2020-12-14 ht
*! author Harald Tauchmann
*! Lagrange-Multiplier Test after Constrained ML Estimation
** DEFINE PROGRAM lmtest **
cap program drop lmtest
program lmtest, rclass
version 15
quietly {
    ** SYNTAX DEFINITION **
    syntax, [noTest] [noCNSReport] [Df(integer -7777)] [noOMITted] [FORCEVce]
	** DISPLAY-FORMAT for WARNINGS **
	local ls = c(linesize)-7
    ** TEMPORARY MATRICES and SCALARS **
	tempname _Cns _Cns1 _Cns2 _rank _cnsest _br _br2 _br3 _LM _V _V1 _V2 _V3    
	** CHECK FOR and STORE ESTIMATES **
	cap estimates store `_cnsest'
	if _rc != 0 {
		di as error "{p 0 2 2 `ls'}last estimation results not found{p_end}"
		exit 301 
	}
	** CHECK FOR e(gradient) **
	cap confirm matrix e(gradient)
	if _rc != 0 {
		di as error "{p 0 2 2 `ls'}not allowed after {bf:`e(cmd)'}{p_end}"
		exit 321 
	}
    ** CHECK FOR CONSTRAINTS TO BE TESTED **
	cap confirm matrix e(Cns)
    if _rc != 0 {	
		di as error "{p 0 2 2 `ls'}option {bf:constraints()} not specified in last model; no constraints to be tested{p_end}" 
		exit 111
	}
	else {	
        mat `_Cns' = e(Cns)
        ** CLEAN CONSTRAINTS MATRIX from BASE CATEGORIES **
        local cnsfn : colfullnames `_Cns'
		di "`cnsfn'"
		local count = 0
		foreach cn in `cnsfn' {
			local count = `count'+1
			if "`omitted'" == "noomitted" {
				local checkbase = strpos("`cn'","b.")+ strpos("`cn'","o.")
			}
			else {
				local checkbase = strpos("`cn'","b.")
			}
			if `checkbase' == 0 {
				cap confirm matrix `_Cns1'
				if _rc != 0 {
					mat `_Cns1' = `_Cns'[1...,`count']
				}
				else {
					mat `_Cns2' = `_Cns'[1...,`count']
					mat `_Cns1' =(`_Cns1',`_Cns2')
				}
			}
		}
        ** RANK of cleaned CONSTRAINTS MATRIX **
		mata : st_numscalar("`_rank'",rank(st_matrix("`_Cns1'")))
        if `_rank' < 1 {
		    local coldif = colsof(`_Cns')- colsof(`_Cns1')
			if `coldif' > 0 {
			    di as error "{p 0 2 2 `ls'}besides base-levels no constraints specified in last model; no constraints to be tested{p_end}"
			}
			else {
				di as error "{p 0 2 2 `ls'}no constraints specified in last model; no constraints to be tested{p_end}" 
			}
    		exit 111
        }
	}
	** CHECK DEGREES-OF-FREEDOM SPECIFICATION **
	if `df' != -7777 {
		if `df' < 1 {
			di as error "{p 0 2 2 `ls'}{bf:df(`df')} invalid; rank of e(Cns) used{p_end}" 
			local df = `_rank'
		}
		else {
			local udf = 1
		}
	}
	else {
			local df = `_rank'
	}
	** CHECK FOR VCE-TYPE **
	local ovce "`e(vce)'"
	if "`ovce'" != "oim" & "`ovce'" != "opg" {
		if "`forcevce'" != "forcevce" {
		    di as error "{p 0 2 2 `ls'}{bf:vcetype} {bf:oim} or {bf:opg} expected; specify option {bf:forcevce} to switch to {bf:e(V_modelbased)}{p_end}" 
			exit 101
		}
		else {
			cap confirm matrix e(V_modelbased)
			if _rc != 0 {
				di as error "{p 0 2 2 `ls'}{bf:vcetype} {bf:`ovce'} not allowed; {bf:e(V_modelbased)} not found{p_end}" 
				exit 321		    
			}
			else {
				noi di as txt "{p 0 2 2 `ls'}{bf:vcetype} {bf:`ovce'} not allowed; switched to {bf:e(V_modelbased)}{p_end}" 
			}
			local VCM "eVmb"
		}
	}
	else {
		local VCM "eV"
	}
	mat `_br' = e(b)
    ** PARSE COMMANDLINE ENTRY **
	local cmdlrest "`e(cmdline)'"
	gettoken cmdlcore cmdlrest : cmdlrest, parse(",")
	di "`cmdlcore'"
	di "`cmdlrest'"
	local count = 0
	local cmdlnew "`cmdlcore',"
	while "`cmdlrest'" != "" {
		local count = `count' +1
		gettoken tok`count' cmdlrest : cmdlrest, bind
		local checkcomma = strmatch("`tok`count''",",")
		local checkconst = strmatch("`tok`count''","constr*") + strmatch("`tok`count''","const(*")
		local checkiter = strmatch("`tok`count''","iter*") + strmatch("`tok`count''","iterate(*")
		local checkfrom = strmatch("`tok`count''","from(*")
		if "`forcevce'" != "forcevce" {
			local checkvce = strmatch("`tok`count''","vce(*")+ strmatch("`tok`count''","r*")+ strmatch("`tok`count''","cl*")
		} 
		else {
			local checkvce = 0
		}
		if `checkcomma' < 1 & `checkconst' < 1 & `checkiter' < 1 & `checkfrom' < 1 & `checkvce' < 1 {
			local cmdlnew "`cmdlnew' `tok`count''"
		}
		if `checkconst' >= 1 {
		    gettoken skip constlist : tok`count', parse("(")
			gettoken skip constlist : constlist, parse("(") 
			gettoken constlist skip : constlist, parse(")")
		}
	}
	** MODEL-SPECIFIC ADJUSTMENTS **
	** mlogit: EXCLUDE BASE OUTCOME FROM e(b) **
	local baselab "`e(baselab)'"
	if "`baselab'" != "" {
		local cnq : coleq `_br'
		local cnq : list uniq cnq
		local cnq : list cnq - baselab
		foreach qq in `cnq' {
			mat `_br3' = `_br'[1,"`qq':"]
			cap confirm matrix `_br2'
			if _rc != 0 {
				mat `_br2' = `_br3'
			}
			else {
				mat `_br2' = (`_br2',`_br3')
			}
		}
		mat `_br' = `_br2'
	}
	** heckman: DROP VARIABLE CONTAINIG NONSELECTION HAZARD **
	if "`e(mills)'" != "" & "`e(cmd)'" == "heckman" {
		cap drop `e(mills)'
	}
	** CALCULATE GRADIENT VECTOR FOR RESTRICTED MODEL ** 
	cap `cmdlnew' from(`_br') iterate(0)
	if _rc != 0 {
		if _rc == 110 {
			di as error "{p 0 2 2 `ls'}don't specify options that make `e(cmd)' generate new variable(s){p_end}"
		}
	    di as error "{p 0 2 2 `ls'}calculating score vector at restricted paramter values failed{p_end}"
		estimates restore `_cnsest'
		exit 480
	}
	** EXCLUDE BASE OUTCOME FROM e(V) FOR mlogit **
	if "`VCM'" == "eV" {
		mat `_V' = e(V)
	}
	else {
	    cap confirm matrix e(V_modelbased) 
		if _rc != 0 {
		    di as error "{p 0 2 2 `ls'}{bf:vcetype} {bf:`ovce'} not allowed; {bf:e(V_modelbased)} not found{p_end}" 
			estimates restore `_cnsest'
			exit 321 
		}
		else {	
			mat `_V' = e(V_modelbased)   
			local cfnV : colfullnames e(V)
 		    mat colnames `_V' = `cfnV'
 		    mat rownames `_V' = `cfnV'  
		}
	}
	if "`baselab'" != "" {
		local cnq : coleq `_br'
		local cnq : list uniq cnq
		foreach rr in `cnq' {	
			foreach qq in `cnq' {
				mat `_V3' = `_V'["`rr':","`qq':"]
				cap confirm matrix `_V2'
				if _rc != 0 {
					mat `_V2' = `_V3'
				}
				else {
					mat `_V2' = (`_V2',`_V3')
				}
			}
			cap confirm matrix `_V1'
			if _rc != 0 {
				mat `_V1' = `_V2'
			}
			else {
				mat `_V1' = (`_V1' \ `_V2')
			}
			mat drop `_V2'
		}
		mat `_V' = `_V1'
	}
	** CALCULATE LM-STATISTIC AND P-VALUE **
	mat `_LM' = e(gradient)*`_V'*(e(gradient))'
	local chi2stat = `_LM'[1,1]
	local pv = 1-chi2(`df',`chi2stat')
	** RESTORE RESTRICTED ESTIMATION RESULTS **
	estimates restore `_cnsest'
	** STORE RESULTS in r() **
	if "`udf'" == "1" {
		return scalar rank = `_rank'
	}
	return scalar df = `df'
	return scalar p = `pv'
	return scalar chi2 = `chi2stat'
	if "`VCM'" != "eV" {
		return local V_modelbased "modelbased"
	}
	** DISPLAY RESULTS **
	if "`test'" != "notest" {
        noi di _newline as text "LM test of constraints(`constlist')"
        if "`cnsreport'" != "nocnsreport" {
            ** DISPLAY CONSTRAINTS **
            noi dispconstr `_Cns1'
        }
		** (code borrowed from testnl.ado) **
	    noi di _newline as txt _col(12) "chi2(" %3.0f `df' ") =" as res %8.2f `chi2stat'
		noi di as txt _col(10) "Prob > chi2 =  " as res %8.4f `pv'		    
	}
}
end

*************************************************
** PROGRAM FOR DISPLAY OF EXPANDED CONSTRAINTS **
*************************************************
cap program drop dispconstr
program dispconstr, nclass
    syntax name
    cap confirm matrix `namelist'
    if _rc !=0 {	
		di as error "{p 0 2 2 `ls'}no constraintsmatrix{p_end}" 
		exit 111    
    }
    else {
        local noco = colsof(`namelist')
        local noro = rowsof(`namelist')
		local cnf : colfullnames `namelist'
        local ncoe = `noco'-1
		tokenize "`cnf'"
		local resnum = 0
		forvalues rr = 1(1)`noro' {
			local dispc`rr' ""
			forvalues cc = 1(1)`noco' {
				if `namelist'[`rr',`cc'] != 0 & `cc' < `noco' {
					local absc = abs(`namelist'[`rr',`cc'])
					if `absc' == 1 {
						local absc ""
					}
					else {
						local absc "`absc'*"
					}
					gettoken eqname rgname : `cc', parse(":")
                    if "`rgname'" != "" {
					   gettoken skip rgname : rgname, parse(":")
                    }
                    else {
                        gettoken eqname rgname : `cc', parse("/")
                    }
					if `namelist'[`rr',`cc'] > 0 {
						if "`dispc`rr''" == "" {
							local sign ""	
						}
						else {
							local sign "+ "							
						}
					}
					else {
						local sign "- "
					}
					local dispc`rr' "`dispc`rr'' `sign'`absc'[`eqname']`rgname'"
				}
				if "`dispc`rr''" != "" & `cc' == `noco' {
					local rval = `namelist'[`rr',`cc']
					local dispc`rr' "`dispc`rr'' = `rval'"
				}
			}
			local dispc`rr' : list retokenize dispc`rr'
			if "`dispc`rr''" != "" {
				local resnum = `resnum'+1
                if `resnum' == 1 {
                    local newl "_newline"
                }
                else {
                    local newl ""
                }
				di `newl' as text _col(2) "(" as text _col(4) "`resnum')" as result _col(9) "`dispc`rr''"
			}
		}
    }
end
