********************************************************************************************************************************
** LEE (2009) TREATMENT EFFECT BOUNDS ******************************************************************************************
********************************************************************************************************************************

*! version 1.5 2013-07-17 ht
*! author Harald Tauchmann
*! Lee (2009) Treatment Effect Bounds 

capture program drop leebounds
program leebounds, eclass
version 11.1
if !replay() {
		quietly {
			local cmd "leebounds"
			local cmdline "`cmd' `*'"
			syntax varlist(min=2 max=2) [if] [in] [pweight fweight iweight/], [SELect(varname)] [TIGht(varlist)] [CIEffect] [VCE(string asis)] [LEVel(real 10)] 
			** TOKENIZE VARLIST **
			tokenize `varlist'
			local yy "`1'"
			local tr "`2'"
			** MANAGE MORE **
			local moreold `c(more)'
			set more off
			** MANGE LEVEL **
			local clevel = `c(level)'
			if `level' >= 50 & `level' < 100 {
				local level = round(`level',0.01)
				set level `level'
			}
			else {
				set level `clevel'
				local level = `clevel'			
			}
			** MANAGE IF **
			if "`if'" == "" {
				local if2 = "if"
			}
			else {
				local if2 = "`if' & "			
			}
			** TEMPORARY NAMES **
			tempvar  __tempsel __tempt __cesamp __esamp __zz __wwsc __wwusc __tempid
			tempname __selcat __res __resV __bb __bsq __mis __Vtest __csize __mcsize __micsize __macsize
			tempfile __bsfile 
			** CHECK and GENERATE SELECTION INDICATOR **
			if "`select'" != "" {
				if "`weight'" == "" {
					sum `select' `if2' `yy'<. 
				}
				else {
					sum `select' `if2' `yy'<. & `exp' >=0 & `exp' <. [iw=`exp']				
				}
				local cssel = r(sum)
				tab `select' `if' `in', matrow(`__selcat')
				if r(r) == 1 {
    				display as error "no variation in selection indicator `select'"
					exit 109
				}
				if r(r) > 2 | `__selcat'[1,1] !=0 | `__selcat'[2,1] !=1 | `cssel' == 0 {
					display as error "selection indicator `select' incorrectly specified"
					exit 109
				}
				gen `__tempsel' = `select' `in' `if2' (`select' == 1 | `select' == 0)
				local ss "`__tempsel'"
			}
			else {
				gen `__tempsel' = `yy' <. `in' `if'
				local ss "`__tempsel'"
				if "`weight'" == "" {
					sum `__tempsel' `in' `if'  
				}
				else {
					sum `__tempsel' `in' `if2' `exp' >=0 & `exp' <. [iw=`exp']				
				}
				if r(mean) == 1 {
    				display as error "all observations selected"
					exit 109
				}
				if r(mean) == 0 {
    				display as error "no observations selected"
					exit 2000
				}
			}
			** GENERATE DUMMY WEIGHTS **
			if "`exp'" == "" {
				local exp "1"
				local dw "pw"
			}
			else {
				local dw "`weight'"			
			}
			** CHECK TREATMENT INDICATOR **
			egen `__tempt' = group(`tr') `in' `if' 
			replace `__tempt' = `__tempt'-1
			tab `__tempt'
			if r(r) != 2 {
				display as error "treatment indicator `tr' not binary"
				exit 149
			}
			** CHECK SPECIFICATION OF OPTION VCE **
			if "`vce'" == "" {
				local reps = 0
			}
			else {
				tokenize `"`vce'"', parse(",")
				if "`4'" != "" {
					di as error "option vce() incorrectly specified"
					exit 198	
				}
				local 1 : list retokenize 1
				local 2 : list retokenize 2
				local 3 : list retokenize 3
				if "`1'" == "analytic" | "`1'" == "analyti" | "`1'" == "analyt" | "`1'" == "analy" | "`1'" == "anal" | "`1'" == "ana" {
					local reps = 0
				}
				else {
					if "`1'" == "bootstrap" | "`1'" == "bootstra" | "`1'" == "bootstr" | "`1'" == "bootst" | "`1'" == "boots" | "`1'" == "boot" {
						if "`2'" == "" & "`3'" == "" {
							local reps = 50
							local dots "dots"
						}
						else {
							if "`2'" == "," & ("`3'" == "dots" | "`3'" == "nodots" ) {
								local reps = 50
								local dots "dots"
								if "`3'" == "nodots" {
									local dots ""
								}
							}
							else {
								if "`2'" == "," & "`3'" != "" {
									local dots "dots"
									local cdot "nodots"
									local cdot2 : list cdot in 3
									if `cdot2' == 1 {
										local dots ""
										local 3 : list 3 - cdot
										local 3 : list retokenize 3
									}
									local cdot "dots"
									local cdot2 : list cdot in 3
									if `cdot2' == 1 {
										local dots "dots"
										local 3 : list 3 - cdot
										local 3 : list retokenize 3
									}
									tokenize `"`3'"', parse("(")
									if ("`2'" == "(") & ("`1'" == "reps" | "`1'" == "rep" |"`1'" == "re" |"`1'" == "r") {
										tokenize `"`3'"', parse(")")
										local rr = real("`1'")
										if `rr' <. & `rr' > 1 & `rr'-floor(`rr') == 0 {
											local reps = `1'
										}
										else {
											di as error "suboption reps() incorrectly specified; must be integer > 1"
											exit 126
										}
										if "`3'" != "" {
											di as error "only suboptions reps() and nodots allowed for vce(bootstrap)"
											exit 198						
										}
									}
									else {
										di as error "only suboption reps() and nodots allowed for vce(bootstrap)"
										exit 198
									}
								}
								else {
									di as error "suboption reps() incorrectly specified"
									exit 198
								}
							}
						}
					}
					else {
						di as error "option vce() incorrectly specified; only vce(analytic) and vce(bootstrap) allowed"
						exit 198
					}
				}
			}
			** SELECT RELEVANT SAMPLE FOR TIGHTENED BOUNDS **
			if "`tight'" != "" {
				gen `__cesamp' = 1 `in' `if' 
				if "`select'" == "" {
					gen `__esamp' = (`yy' !=. | (`yy' ==. & `ss' == 0)) & (`__tempt' == 1 | `__tempt' == 0) & (`ss' == 1 | `ss' == 0) & `__cesamp' == 1 
				}
				else {
					gen `__esamp' = (`yy' !=. | (`yy' ==. & `ss' == 0)) & (`__tempt' == 1 | `__tempt' == 0) & (`ss' == 1 | `ss' == 0) & (`__tempsel' == 1 | `__tempsel' == 0) & `__cesamp' == 1 				
				}
				** GENERATE WEIGHTS **
				gen `__wwusc' = `exp'
				replace `__esamp' = 0 if `__wwusc' >=. | `__wwusc' < 0
				preserve 
				keep if `__esamp' == 1
				** RESCALE WEIGHTS
				sum `__wwusc'
				local wsumusc = r(sum)
				gen `__wwsc' = `__wwusc'/r(mean)
				sum `__wwsc'
				** WEIGHT CORRECTION FACTOR
				if "`weight'" == "fweight" | "`weight'" == "iweight" {
					local wcf =  `wsumusc'/r(sum)
				}
				else {
					local wcf =  1
				}
				sum `ss' [iweight = `__wwsc']
				local samps = round(`wcf'*r(sum_w))
				local nsel = round(`wcf'*r(mean)*r(sum_w),1)
                ** RE-CHECK TREATMENT INDICATOR **
                mean `ss' [pweight = `__wwsc'], over(`__tempt') 
    			if _b[0] == 0 {
    				display as error "no information on `yy' for control group"
    				exit 2000
    			}
    			if _b[1] == 0 {
    				display as error "no information on `yy' for treatment group"
    				exit 2000
    			}
    			if _b[0] == _b[1] {
    				noisily: display as result "selection proportion exactly equal for both groups, no bounds computed" 
    				exit 498
    			}
    			if _b[0] > _b[1] {
    				replace `__tempt' = (`__tempt'-1)^2
                    local trimmed "control"
                }
                else {
                    local trimmed "treatment"
        		}
				** CREATE CELLS **
				unab tight : `tight'
				egen `__zz' = group(`tight')
				** CHECK CELL SIZE **
				tab `__zz' `__tempt' [iweight = `__wwsc'], matcell(`__csize')
				mata: st_numscalar("`__mcsize'", min(st_matrix("`__csize'")))
				if `__mcsize' <= 0 {
					display as error "cells without variation in treatment; change varlist specified by tight()"
					restore
					exit 2000				
				}
				mean `ss'  [pweight = `__wwsc'], over(`__tempt' `__zz')
				mat `__csize' = e(b)
				mata: st_numscalar("`__micsize'", min(st_matrix("`__csize'")))
				if `__micsize' <= 0 {
					display as error "cells without information on `yy' for one group; change varlist specified by tight()"
					restore
					exit 2000				
				}
                ** CHECK FOR HOMOGENEOUS SELECTION DIRECTION ACROSS CELLS **
                mat `__csize' = `__csize'[1,1..colsof(`__csize')/2]- `__csize'[1,1+colsof(`__csize')/2..colsof(`__csize')]
                mata: st_numscalar("`__micsize'", min(st_matrix("`__csize'")))
                mata: st_numscalar("`__macsize'", max(st_matrix("`__csize'")))
				if `__micsize' < 0 & `__macsize' > 0 {
					display as error "warning: heterogenous selection direction across cells; thightening may fail"
					local cellsel "hetero"
				}
                else {
                    local cellsel "homo"
                }
				** CALCULATE TIGHTENED LEE-BOUNDs
				leetbound `yy' `__tempt' `ss' `__zz' `trimmed' `__wwusc'
				mat `__res' = e(b)
				mat `__resV' = e(V)/`wcf'
				local otrim = e(trim)
				local ocells = e(cells)
				local cno : colfullnames `__res'
				** BOOTSTRAPPING **
				if `reps' > 1 {
					keep `yy' `__tempt' `ss' `__zz' `__wwusc'
					gen `__tempid' = _n
					save `__bsfile'
					local count = 0
					forvalues rr = 1/`reps' {
						wbsample `__tempid' `__wwusc' `__tempt' `__bsfile' `exp'
						capture leetbound `yy' `__tempt' `ss' `__zz' `trimmed'  __tempw
						mat `__mis' = matmissing(e(b))
						local mis = `__mis'[1,1]
						local cnb : colfullnames e(b)
						if _rc != 0 | `mis' != 0 | "`cnb'" != "`cno'" {
							if "`dots'" == "dots" {
								if `rr' == 1 {
									noisily: display ""
								}
								if `rr'/50 == round(`rr'/50) | `rr' == `reps' {
									noisily: display as error "x" as text " `rr'"
								}
								else {
									noisily: display as error "x" _continue
								}
							}
							if `rr' < `reps' {
								continue
							}
							else {
								local finalerror "finalerror"
							}
						}
						if "`dots'" == "dots" & "finalerror" != "`finalerror'" {
							if `rr' == 1 {
								noisily: display ""
							}
							if `rr'/50 == round(`rr'/50) | `rr' == `reps' {
								noisily: display as text ". `rr'"
							}
							else {
								noisily: display as text "." _continue
							}
						}
						if "finalerror" != "`finalerror'" {
							local count = `count'+1
							if `count' == 1 {
								mat `__bb' = e(b)
								mat `__bsq' = e(b)'*e(b)
							}
							else {
								mat `__bb' = `__bb' + e(b)
								mat `__bsq' = `__bsq'+ e(b)'*e(b)
							}
						}
						if `rr' == `reps' {
							if `count' > 1 {
								mat `__bb' = `__bb'/`count'
								mat `__bsq' = `__bsq'/(`count'-1)
								mat `__resV' = `__bsq' - `__bb''*`__bb'*(`count'/(`count'-1))
								mat `__resV' = `__resV'/`wcf'
							}
							else {
								mat `__resV' = J(2,2,0)
								mat colnames `__resV' = `cno'
								mat rownames `__resV' = `cno'
							}
						} 
					}
				}
				restore
				mat coleq `__res' = `tr'
				mat coleq `__resV' = `tr'
				mat roweq `__resV' = `tr'
				ereturn post `__res' `__resV', depname(`yy') properties(b V) esample(`__esamp')
			}
			** SELECT RELEVANT SAMPLE FOR SIMPLE BOUNDS **
			else {
				gen `__cesamp' = 1 `if' `in'
				if "`select'" == "" {
					gen `__esamp' = (`yy' !=. | (`yy' ==. & `ss' == 0)) & (`__tempt' == 1 | `__tempt' == 0) & (`ss' == 1 | `ss' == 0) & `__cesamp' == 1 
				}
				else {
					gen `__esamp' = (`yy' !=. | (`yy' ==. & `ss' == 0)) & (`__tempt' == 1 | `__tempt' == 0) & (`ss' == 1 | `ss' == 0) & (`__tempsel' == 1 | `__tempsel' == 0) & `__cesamp' == 1 				
				}
				gen `__wwusc' = `exp'
				** GENERATE WEIGHTS **
				replace `__esamp' = 0 if `__wwusc' >=. | `__wwusc' < 0
				preserve 
				keep if `__esamp' == 1
				** RESCALE WEIGHTS
				sum `__wwusc'
				local wsumusc = r(sum)
				gen `__wwsc' = `__wwusc'/r(mean)
				sum `__wwsc'
				** WEIGHT CORRECTION FACTOR
				if "`weight'" == "fweight" | "`weight'" == "iweight" {
					local wcf =  `wsumusc'/r(sum)
				}
				else {
					local wcf =  1
				}
				sum `ss' [iweight = `__wwsc']
				local samps = round(`wcf'*r(sum_w))
				local nsel = round(`wcf'*r(mean)*r(sum_w))
                ** RE-CHECK TREATMENT INDICATOR **
                mean `ss' [pweight = `__wwsc'], over(`__tempt') 
    			if _b[0] == 0 {
    				display as error "no information on `yy' for control group"
    				exit 2000
    			}
    			if _b[1] == 0 {
    				display as error "no information on `yy' for treatment group"
    				exit 2000
    			}
    			if _b[0] == _b[1] {
    				noisily: display as result "selection proportion exactly equal for both groups, no bounds computed" 
    				exit 498
    			}
    			if _b[0] > _b[1] {
    				replace `__tempt' = (`__tempt'-1)^2
                    local trimmed "control"
                }
                else {
                    local trimmed "treatment"
        		}
				** CALCULATE SIMPLE LEE-BOUNDs
				leesbound `yy' `__tempt' `ss' `trimmed' `__wwusc'
				mat `__res' = e(b)
				mat `__resV' = e(V)/`wcf'
				local otrim = e(trim)
				local cno : colfullnames `__res'
				** BOOTSTRAPPING **
				if `reps' > 1 {
					keep `yy' `__tempt' `ss' `__wwusc'
					gen `__tempid' = _n
					save `__bsfile'
					local count = 0
					forvalues rr = 1/`reps' {
						wbsample `__tempid' `__wwusc' `__tempt' `__bsfile' `exp'
						capture leesbound `yy' `__tempt' `ss' `trimmed' __tempw
						mat `__mis' = matmissing(e(b))
						local mis = `__mis'[1,1]
						local cnb : colfullnames e(b)
						if _rc != 0 | `mis' != 0 | "`cnb'" != "`cno'" {
							if "`dots'" == "dots" {
								if `rr' == 1 {
									noisily: display ""
								}
								if `rr'/50 == round(`rr'/50) | `rr' == `reps' {
									noisily: display as error "x" as text " `rr'"
								}
								else {
									noisily: display as error "x" _continue
								}
							}
							if `rr' < `reps' {
								continue
							}
							else {
								local finalerror "finalerror"
							}
						}
						if "`dots'" == "dots" & "finalerror" != "`finalerror'" {
							if `rr' == 1 {
								noisily: display ""
							}
							if `rr'/50 == round(`rr'/50) | `rr' == `reps' {
								noisily: display as text ". `rr'"
							}
							else {
								noisily: display as text "." _continue
							}
						}
						if "finalerror" != "`finalerror'" {
							local count = `count'+1
							if `count' == 1 {
								mat `__bb' = e(b)
								mat `__bsq' = e(b)'*e(b)
							}
							else {
								mat `__bb' = `__bb' + e(b)
								mat `__bsq' = `__bsq'+ e(b)'*e(b)
							}
						}
						if `rr' == `reps' {
							if `count' > 1 {
								mat `__bb' = `__bb'/`count'
								mat `__bsq' = `__bsq'/(`count'-1)
								mat `__resV' = `__bsq' - `__bb''*`__bb'*(`count'/(`count'-1))
								mat `__resV' = `__resV'/`wcf'
							}
							else {
								mat `__resV' = J(2,2,0)
								mat colnames `__resV' = `cno'
								mat rownames `__resV' = `cno'
							}
						} 
					}
				}
				restore
				mat coleq `__res' = `tr'
				mat coleq `__resV' = `tr'
				mat roweq `__resV' = `tr'
				ereturn post `__res' `__resV', depname(`yy') properties(b V) esample(`__esamp') 
			}
			** POST RESULTS **
			ereturn scalar N = `samps'
			ereturn scalar Nsel = `nsel'
			if "`tight'" != "" { 
				ereturn scalar cells = `ocells'
			}
			ereturn scalar trim = `otrim'
			ereturn scalar level = `c(level)'
			if "`weight'" != "" {			
              ereturn local wexp  "= `exp'"
              ereturn local wtype "`weight'"
			}
			ereturn local trimmed "`trimmed'"
			ereturn local treatment "`tr'"
            if "`select'" != "" {
                ereturn local select "`select'"
            }
			ereturn local covariates "`tight'"
			if "`tight'" != "" { 
				ereturn local cellsel "`cellsel'"
			}
			if `reps' > 1 {
				ereturn scalar N_reps = `count'
				ereturn local vcetype "Bootstrap"
				ereturn local vce "bootstrap"
			}
			if `reps' == 0 {
				ereturn local vce "analytic"
			}
			ereturn local title "Lee (2009) treatment effect bounds"
			ereturn local cmdline `cmdline'
			ereturn local cmd `cmd'		
			capture mat `__Vtest' = inv(e(V))
			if "`cieffect'" == "cieffect" {
				if _rc == 0 {
					leebci
					ereturn scalar  cilower = cilower
					ereturn scalar  ciupper = ciupper
					scalar drop ciupper cilower
				}
				else {
					ereturn local  cilower "."
					ereturn local  ciupper "."
				}
			}
		}
	set level `clevel'
	set more `moreold'
	}
    else {
        if "`e(cmd)'" != "leebounds" {
			error 301
		}
		else {
			syntax, [LEVel(real `e(level)')]
		}
    }
	** DISPLAY RESULTS **
	if "`e(covariates)'" != "" {
		display _newline as text "Tightened Lee (2009) treatment effect bounds"
        display _newline as text "Number of obs." _skip(20) as text  " =   " as result `e(N)'
        display as text "Number of selected obs." _skip(11) as text " =   " as result `e(Nsel)'
        display as text "Number of cells" _skip(19) as text " =   " as result `e(cells)' 
        display as text "Overall trimming porportion" _skip(7) as text " =   " as result %-06.4f `e(trim)' 
	}
	else {
		display _newline as text "Lee (2009) treatment effect bounds"
        display _newline as text "Number of obs." _skip(20) as text  " =   " as result `e(N)'
        display as text "Number of selected obs." _skip(11) as text " =   " as result `e(Nsel)'
        display as text "Trimming porportion" _skip(15) as text " =   " as result %-06.4f `e(trim)' 
	}
	if "`e(cilower)'" != "" | "`e(ciupper)'" != "" {
		if `e(cilower)' > 0 {
			local psk "_skip(1)"
		}
		display as text "Effect `e(level)'% conf. interval" _skip(9) as text " : [" `psk' as result %-06.4f `e(cilower)' _skip(2) as result %-06.4f `e(ciupper)' as text "]" 
	}
	display ""
	ereturn display, level(`level')
end

*****************************************************************************
** Compute Tightened Lee (2009) Bounds **************************************
capture program drop leetbound
program leetbound, eclass
version 11.2
args yy tt ss zz cc ww
	tempvar __esamp __ysq __st __sit __group __wws
	tempname __res __resV __ctst __vres __instfreq
	** Rescale Weights
	gen `__wws' = `ww'
	sum `__wws'
	replace `__wws' = `__wws'/r(mean)
	gen `__ysq' = (`yy')^2
	** Cells **
	capture drop _instcat*
	tab `zz', g(_instcat)
	local ncat = r(r)
	** Overall Trimmed Means & Number of Trimmed Observations  
	mean `ss' [pweight = `__wws'], over(`tt') 
	local trim = 100*(_b[1]-_b[0])/_b[1]
	local qtrim = `trim'/100
	local otrim = `qtrim'
	_pctile `yy' if `ss' == 1 & `tt' == 1 [pweight = `__wws'], percentiles(`trim')
	local uth = r(r1)
	sum `__wws' if `ss' == 1 & `tt' == 1 & `yy' == `uth' 
	if r(sum) == 0 {
		sum `yy' if `ss' == 1 & `tt' == 1 & `yy' >= `uth' [iweight = `__wws']
		local tubov = r(mean)	
	}
	else {
		local neth = r(sum) 
		sum `yy' if `ss' == 1 & `tt' == 1 & `yy' > `uth' [iweight = `__wws']
		local nbth = r(sum_w)
		local sbth = r(sum)
		sum `__wws' if `ss' == 1 & `tt' == 1 & `yy' !=.
		local ntall = r(sum)
		local stie = (`ntall'*(1-`qtrim')-`nbth')/`neth'
		local tubov = (`sbth'+`stie'*`neth'*`uth')/(`nbth'+`stie'*`neth')
	}
	local itrim = 100-`trim'
	_pctile `yy' if `ss' == 1 & `tt' == 1 [pweight = `__wws'], percentiles(`itrim')
	local lth = r(r1)
	sum `__wws' if `ss' == 1 & `tt' == 1 & `yy' == `lth' 
	if r(sum) == 0 {
		sum `yy' if `ss' == 1 & `tt' == 1 & `yy' <= `lth' [iweight = `__wws']
		local lubov = r(mean)
	}
	else {
		local neth = r(sum)
		sum `yy' if `ss' == 1 & `tt' == 1 & `yy' < `lth' [iweight = `__wws']
		local nbth = r(sum_w)
		local sbth = r(sum)
		sum `__wws' if `ss' == 1 & `tt' == 1 & `yy' !=.
		local ntall = r(sum)
		local stie = (`ntall'*(1-`qtrim')-`nbth')/`neth'
		local lubov = (`sbth'+`stie'*`neth'*`lth')/(`nbth'+`stie'*`neth')
	}
	** BY CELL **
	forvalues instv = 1/`ncat' {
		tab `ss' `tt' if _instcat`instv' == 1 [iweight = `__wws'], matcell(`__ctst')
		local nall = r(N)
		mat `__ctst' = `__ctst'/`nall'
		local est   = `__ctst'[2,2]
		local esnt  = `__ctst'[2,1]
		local et    = `__ctst'[1,2]+`__ctst'[2,2]
		local oddsc = `__ctst'[1,1]/`__ctst'[2,1]
		local oddst = `__ctst'[1,2]/`__ctst'[2,2]
        ** Estimate Cell's Weight
        sum `yy' if `ss' == 1 & `tt' == 0 & _instcat`instv' == 1 [iweight = `__wws']
		local __instfreql = r(sum_w)
		local __instfrequ = r(sum_w)
        ** Trimming Proportion
		mean `ss' if _instcat`instv' == 1 [pweight = `__wws'], over(`tt')  
		local trim = 100*(_b[1]-_b[0])/_b[1]
		local qtrim = `trim'/100
		if `trim' > 0 & `trim' < 100 {
			_pctile `yy' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 [iweight = `__wws'], percentiles(`trim')
			local uth = r(r1)
		}
		else {
			sum `yy' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 [iweight = `__wws']
			if `trim' <= 0 {
				local uth = r(min)
			}
			if `trim' >= 100 {
				local uth = r(max)
			}
		}
		sum `__wws' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 & `yy' == `uth'
		if r(sum) == 0 {
			sum `yy' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 & `yy' >= `uth' [iweight = `__wws']
			local tub`instv' = r(mean)
			** Analytic Variance
			local vp = (1-`qtrim')^2*(`oddst'/(`et'*`nall')+`oddsc'/((1-`et')*`nall'))
			local vb1 = r(Var)/r(sum_w)
			local vb2 = (`uth'-`tub`instv'')^2*((`qtrim')/(1-`qtrim'))/(`est'*`nall')
			local vb3 = ((`uth'-`tub`instv'')/(1-`qtrim'))^2*`vp'
			local vub`instv' = `vb1'+`vb2'+`vb3'
		}
		else {
			local neth = r(sum)
			sum `yy' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 & `yy' > `uth' [iweight = `__wws']
			local nbth = r(sum_w)
			local sbth = r(sum)
			sum `__wws' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 & `yy' !=.
			local ntall = r(sum)
			local stie = (`ntall'*(1-`qtrim')-`nbth')/`neth'
			local tub`instv' = (`sbth'+`stie'*`neth'*`uth')/(`nbth'+`stie'*`neth')
			** Analytic Variance
			sum `__ysq' if `ss' == 1 & `tt' == 1 & `yy' > `uth' & _instcat`instv' == 1 [iweight = `__wws'] 
			local vp = (1-`qtrim')^2*(`oddst'/(`et'*`nall')+`oddsc'/((1-`et')*`nall'))
			local vb1 = ((r(sum)+`stie'*`neth'*(`uth')^2)/(`nbth'+`stie'*`neth')-(`tub`instv'')^2)/(`nbth'+`stie'*`neth')
			local vb2 = (`uth'-`tub`instv'')^2*(`qtrim')/((1-`qtrim')*`est'*`nall')
			local vb3 = ((`uth'-`tub`instv'')/(1-`qtrim'))^2*`vp'
			local vub`instv' = `vb1'+`vb2'+`vb3'
		}
		local itrim = 100-`trim'
		if `itrim' > 0 & `itrim' < 100 {
			_pctile `yy' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 [pweight = `__wws'], percentiles(`itrim') 
			local lth = r(r1)
		}
		else {
			sum `yy' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 [iweight = `__wws']
			if `itrim' <= 0 {
				local lth = r(min)
			}
			if `itrim' >= 100 {
				local lth = r(max)
			}
		}
		sum `__wws' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 & `yy' == `lth' 
		if r(sum) == 0 {
			sum `yy' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 & `yy' <= `lth' [iweight = `__wws']
			local lub`instv' = r(mean)
			** Analytic Variance
			local vp = (1-`qtrim')^2*(`oddst'/(`et'*`nall')+`oddsc'/((1-`et')*`nall'))
			local vb1 = r(Var)/r(sum_w)
			local vb2 = (`lth'-`lub`instv'')^2*((`qtrim')/(1-`qtrim'))/(`est'*`nall')
			local vb3 = ((`lth'-`lub`instv'')/(1-`qtrim'))^2*`vp'
			local vlb`instv' = `vb1'+`vb2'+`vb3'
		}
		else {
			local neth = r(sum)
			sum `yy' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 & `yy' < `lth' [iweight = `__wws']
			local nbth = r(sum_w)
			local sbth = r(sum)
			sum `__wws' if `ss' == 1 & `tt' == 1 & _instcat`instv' == 1 & `yy' !=.
			local ntall = r(sum)
			local stie = (`ntall'*(1-`qtrim')-`nbth')/`neth'
			local lub`instv' = (`sbth'+`stie'*`neth'*`lth')/(`nbth'+`stie'*`neth')
			** Analytic Variance
			sum `__ysq' if `ss' == 1 & `tt' == 1 & `yy' < `lth' & _instcat`instv' == 1 [iweight = `__wws']
			local vp  = (1-`qtrim')^2*(`oddst'/(`et'*`nall')+`oddsc'/((1-`et')*`nall'))
			local vb1 = ((r(sum)+`stie'*`neth'*(`lth')^2)/(`nbth'+`stie'*`neth')-(`lub`instv'')^2)/(`nbth'+`stie'*`neth')
			local vb2 = (`lth'-`lub`instv'')^2*(`qtrim')/((1-`qtrim')*`est'*`nall')
			local vb3 = ((`lth'-`lub`instv'')/(1-`qtrim'))^2*`vp'
			local vlb`instv' = `vb1'+`vb2'+`vb3'
		}
		** Weighted Sum **
		if `instv' == 1 {
			local uwsum = `__instfrequ'
			local lwsum = `__instfreql'
			local ubttreat = `__instfrequ'*`tub`instv''
			local lbttreat = `__instfreql'*`lub`instv''
			local ubttreat_sq = `__instfrequ'*(`tub`instv'')^2
			local lbttreat_sq = `__instfreql'*(`lub`instv'')^2
			local vub = (`__instfrequ')^2*(`vub`instv'')
			local vlb = (`__instfreql')^2*(`vlb`instv'')
		}
		else {
			local uwsum = `uwsum'+`__instfrequ'
			local lwsum = `lwsum'+`__instfreql'
			local ubttreat = `ubttreat'+`__instfrequ'*`tub`instv''
			local lbttreat = `lbttreat'+`__instfreql'*`lub`instv''
			local ubttreat_sq = `ubttreat_sq'+`__instfrequ'*(`tub`instv'')^2
			local lbttreat_sq = `lbttreat_sq'+`__instfreql'*(`lub`instv'')^2
			local vub = `vub'+(`__instfrequ')^2*(`vub`instv'')
			local vlb = `vlb'+(`__instfreql')^2*(`vlb`instv'')
		}
		if `instv' == `ncat' {
			sum `yy' if `tt' == 0 & `ss' == 1 [iweight = `__wws']
			local vc = r(Var)/r(sum_w)
			local vub = `vub'/(`uwsum')^2+((`ubttreat_sq'/`uwsum')-(`ubttreat'/`uwsum')^2)/`ntall'+`vc'
			local vlb = `vlb'/(`lwsum')^2+((`lbttreat_sq'/`lwsum')-(`lbttreat'/`lwsum')^2)/`ntall'+`vc'
			local ubttreat = `ubttreat'/`uwsum'-r(mean)
			local lbttreat = `lbttreat'/`lwsum'-r(mean)			
		}
	}
	if "`cc'" != "control" {
		matrix `__res' =    (`lbttreat', `ubttreat')
	}
	else {
		matrix `__res' = -1*(`ubttreat', `lbttreat')
	}
	local varmis = matmissing(`__res')
	if `varmis' == 1 {
		display as error "cannot compute tightened bounds; change varlist specified by tight()"
		capture restore
		exit 2000				
	}
	matrix colnames `__res' =  `tt':lower `tt':upper
	local cn : colfullnames `__res'
	if "`cc'" != "control" {
		matrix `__vres' = (`vlb',`vub')
	}
	else {
		matrix `__vres' = (`vub',`vlb')
	}
	matrix `__resV' = diag(`__vres')
	local varmis = matmissing(`__resV')
	if `varmis' == 1 {
		matrix `__resV' = J(2,2,0)
		display as error "warning: cannot compute analytic variance; change varlist specified by tight()"
	}
	matrix colnames `__resV' = `cn'
	matrix rownames `__resV' = `cn'
	ereturn post `__res' `__resV', depname(`yy') properties(b V)
	ereturn scalar cells = `ncat'
	ereturn scalar trim = `otrim'
end

*****************************************************************
** Basic Lee (2005) Bounds **************************************
capture program drop leesbound
program leesbound, eclass
version 11.2
args yy tt ss cc ww
	tempvar __esamp __ysq __st __sit __wws
	tempname __res __resV __ctst __vres
	** RESCALING WEIGHTS **
	gen `__wws' = `ww'
	sum `__wws'
	replace `__wws' = `__wws'/r(mean)
	gen `__ysq' = (`yy')^2
	tab `ss' `tt' [iweight = `__wws'], matcell(`__ctst') 
	local nall = r(N)
	mat `__ctst' = `__ctst'/`nall'
	local est   = `__ctst'[2,2]
	local esnt  = `__ctst'[2,1]
	local et    = `__ctst'[1,2]+`__ctst'[2,2]
	local oddsc = `__ctst'[1,1]/`__ctst'[2,1]
	local oddst = `__ctst'[1,2]/`__ctst'[2,2]
	mean `ss' [pweight = `ww'], over(`tt')  
	local trim = 100*(_b[1]-_b[0])/_b[1]
	local qtrim = `trim'/100
	local nall = round(`nall')
	_pctile `yy' if `ss' == 1 & `tt' == 1 [pweight = `__wws'], percentiles(`trim')
	local uth = r(r1)
	sum `__wws' if `ss' == 1 & `tt' == 1 & `yy' == `uth' 
	if r(sum) == 0 {
		sum `yy' if `ss' == 1 & `tt' == 1 & `yy' >= `uth' [iweight = `__wws']
		local tub = r(mean)
		** Analytic Variance
		local vp = (1-`qtrim')^2*(`oddst'/`et'+`oddsc'/(1-`et'))
		local vb1 = r(Var)/r(sum_w)
		local vb2 = (`uth'-`tub')^2*(`qtrim')*(`est'*(1-`qtrim'))^-1
		local vb3 = ((`uth'-`tub')/(1-`qtrim'))^2*`vp'
		sum `yy' if `ss' == 1 & `tt' == 0
		local vc = r(Var)/`esnt'
		local vub = `vb1'+(`vb2'+`vb3'+`vc')/`nall'
	}
	else {
		local neth = r(sum)
		sum `yy' if `ss' == 1 & `tt' == 1 & `yy' > `uth' [iweight = `__wws']
		local nbth = r(sum_w)
		local sbth = r(sum)
		sum `__wws' if `ss' == 1 & `tt' == 1& `yy' !=.
		local ntall = r(sum)
		local stie = (`ntall'*(1-`qtrim')-`nbth')/`neth'
		local tub = (`sbth'+`stie'*`neth'*`uth')/(`nbth'+`stie'*`neth')
		** Analytic Variance
		local vp = (1-`qtrim')^2*(`oddst'/`et'+`oddsc'/(1-`et'))
		sum `__ysq' if `ss' == 1 & `tt' == 1 & `yy' > `uth' [iweight = `__wws']
		local vb1 = ((r(sum)+`stie'*`neth'*(`uth')^2)/(`nbth'+`stie'*`neth')-(`tub')^2)/(`nbth'+`stie'*`neth')
		local vb2 = (`uth'-`tub')^2*(`qtrim')*(`est'*(1-`qtrim'))^-1
		local vb3 = ((`uth'-`tub')/(1-`qtrim'))^2*`vp'
		sum `yy' if `ss' == 1 & `tt' == 0 [iweight = `__wws']
		local vc = r(Var)/`esnt'
		local vub = `vb1'+(`vb2'+`vb3'+`vc')/`nall'
	}
	sum `yy' if `ss' == 1 & `tt' == 0 [iweight = `__wws']
	local  ubtreat = `tub'-r(mean)
	local itrim = 100-`trim'
	_pctile `yy' if `ss' == 1 & `tt' == 1  [pweight = `__wws'], percentiles(`itrim')
	local lth = r(r1)
	sum `__wws' if `ss' == 1 & `tt' == 1 & `yy' == `lth' 
	if r(sum) == 0 {
		sum `yy' if `ss' == 1 & `tt' == 1 & `yy' <= `lth'  [iweight = `__wws']
		local lub = r(mean)
		** Analytic Variance
		local vp = (1-`qtrim')^2*(`oddst'/`et'+`oddsc'/(1-`et'))
		local vb1 = r(Var)/r(sum_w) 
		local vb2 = (`lth'-`lub')^2*(`qtrim')*(`est'*(1-`qtrim'))^-1
		local vb3 = ((`lth'-`lub')/(1-`qtrim'))^2*`vp'
		sum `yy' if `ss' == 1 & `tt' == 0 [iweight = `__wws']
		local vc = r(Var)/`esnt'
		local vlb = `vb1'+(`vb2'+`vb3'+`vc')/`nall'
	}
	else {
		local neth = r(sum)
		sum `yy' if `ss' == 1 & `tt' == 1 & `yy' < `lth' [iweight = `__wws']
		local nbth = r(sum_w)
		local sbth = r(sum)
		sum `__wws' if `ss' == 1 & `tt' == 1 & `yy' !=.
		local ntall = r(sum)
		local stie = (`ntall'*(1-`qtrim')-`nbth')/`neth'
		local lub = (`sbth'+`stie'*`neth'*`lth')/(`nbth'+`stie'*`neth')
		** Analytic Variance
		local vp = (1-`qtrim')^2*(`oddst'/`et'+`oddsc'/(1-`et'))
		sum `__ysq' if `ss' == 1 & `tt' == 1 & `yy' < `lth' [iweight = `__wws']
		local vb1 = ((r(sum)+`stie'*`neth'*(`lth')^2)/(`nbth'+`stie'*`neth')-(`lub')^2)/(`nbth'+`stie'*`neth')
		local vb2 = (`lth'-`lub')^2*(`qtrim')*(`est'*(1-`qtrim'))^-1
		local vb3 = ((`lth'-`lub')/(1-`qtrim'))^2*`vp'
		sum `yy' if `tt' == 0 & `ss' == 1  [iweight = `__wws']
		local vc = r(Var)/`esnt'
		local vlb = `vb1'+(`vb2'+`vb3'+`vc')/`nall'
	}
	sum `yy' if `ss' == 1 & `tt' == 0 [iweight = `__wws']
	local  lbtreat = `lub'-r(mean)
	if "`cc'" != "control" {
		matrix `__res' = (`lbtreat' , `ubtreat')
	}
	else {
		matrix `__res' = -1*(`ubtreat', `lbtreat')
	}
	local varmis = matmissing(`__res')
	if `varmis' == 1 {
		display as error "cannot compute bounds"
		capture restore
		exit 2000				
	}
	matrix colnames `__res' =  `tt':lower `tt':upper
	local cn : colfullnames `__res'
	if "`cc'" != "control" {
		matrix `__vres' = (`vlb',`vub')
	}
	else {
		matrix `__vres' = (`vub',`vlb')
	}
	matrix `__resV' = diag(`__vres')
	local varmis = matmissing(`__resV')
	if `varmis' == 1 {
		matrix `__resV' = J(2,2,0)
		display as error "warning: cannot compute analytic variance"
	}
	matrix colnames `__resV' = `cn'
	matrix rownames `__resV' = `cn'
	ereturn post `__res' `__resV', depname(`yy') properties(b V)
	ereturn scalar trim = `qtrim'
end

**********************************************************************
** Confidence Intervals for Bounds ***********************************
capture program drop leebci
program leebci, rclass
version 11.2
	local cs = invnormal(1-(100-`c(level)')/100) 
	local ce = invnormal(1-(100-`c(level)')/200)
	local qd = 10^15
	forvalues cc = `cs'(0.001)`ce' {
		local qdn = ((normal(`cc'+(_b[upper]-_b[lower])/max(_se[lower], _se[upper]))-normal(-`cc')) - (1-(100-`c(level)')/100))^2
		if `qdn' < `qd' {
			local qd = `qdn'
			local cnn = `cc'
		}
	}
	scalar cilower = _b[lower]-_se[lower]*`cnn'
	scalar ciupper = _b[upper]+_se[upper]*`cnn'
end

*********************************************************************
** Weighted Bootstrap ***********************************************
capture program drop wbsample
program wbsample, nclass
version 11.1
	args id ww gg ff wexp 
	** TEMPORARY NAMES **
	tempvar  __ww2 __repl __fww0 __fww1
	if "`wexp'" == "1" {
		capture drop __tempw
		gen __tempw =.			
		bsample, strata(`gg') weight(__tempw)
	}
	else {
		sum `ww' if `ww' > 0
		gen `__ww2' = floor(`ww'/r(min))
		replace `__ww2' = `__ww2'+ rbinomial(1,(`ww'/r(min))-floor(`ww'/r(min))) if (`ww'/r(min))-floor(`ww'/r(min)) != 0
		keep `id' `__ww2' `gg'
		expand `__ww2', gen(`__repl')
		sort `id' `__repl'
		capture drop `__fww0' __tempw `__fww1'
		gen `__fww0' =.
		sum `__repl' if `gg' == 0
		local on = round((1-r(mean))*r(N))
		bsample `on' if `gg' == 0 & `__ww2' > 0 & `__ww2' <., weight(`__fww0')
		by `id', sort: egen __tempw = total(`__fww0')
		capture drop `__fww0'
		gen `__fww0' =.
		sum `__repl' if `gg' == 1
		local on = round((1-r(mean))*r(N))
		bsample `on' if `gg' == 1 & `__ww2' > 0 & `__ww2' <., weight(`__fww0') 
		by `id', sort: egen `__fww1' = total(`__fww0')
		replace __tempw = __tempw+`__fww1'
		keep if `__repl' == 0
		keep `id' __tempw
		sort `id'
		merge 1:1 `id' using `ff'
	}
end 
