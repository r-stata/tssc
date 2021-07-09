*!  version 1.0.8 Ho Fai Chan 22Mar2017

cap program drop thsearch
program define thsearch, rclass 

	version 7
	syntax varlist [if] [in] , ///
		THVAR(varname numeric) /// Specify the variable which threshold(s) to be determined 
		[INTVAR(varlist numeric)] /// optional: Specify the independent variable for construction of the interaction term
		THNUM(numlist >0 <7 integer) /// Specify number of threshold value, e.g. 1 = 2 groups; maximum is 6
		EMODEL(string) /// Specify [estimation] model to use (put estimation options after a comma, should support all estimation options (need to pay attention whether it affects the calculation of the IC))
		[Stepsize(real 1)] /// optional: Specify the interval in which the threshold increase, default is 1
		[CRIteria(string)] /// optional: Criteria for model selection, default BIC
		[SAVEfile(string)] /// optional: Name and location of the output
		[REPLACE] ///
		[MINth(numlist min=1)] /// optional: Specify the minimum threshold value
		[MAXth(numlist min=1)] /// optional: Specify the maximum threshold value
		
	marksample touse 
	
	preserve

	// Define outcome variable and set of controls
	gettoken lhs rhs : varlist 
	gettoken emodel eoption: emodel, parse(",")
	gettoken next eoption: eoption, parse(",")
	// Keeping variables listed
	qui keep if `touse'
	qui keep `lhs' `rhs' `thvar' `intvar' `touse'
	
	// Check if threshold variable has more level than number of BP specified
	/*
	qui levelsof `thvar' if `touse' 
	if `thnum' >= wordcount("`r(levels)'") {
		di as err "Too many break points specified"
		exit 198
	}
	*/
	// Check if thnum is correctly specified [positive value]
	if `thnum' <= 0 {
		di as err "Please specify positive number for break point value"
		exit 198		
	}
	// Check if Stepsize is correctly specified [positive value]
	if "`stepsize'" != "" {
		if `stepsize' <= 0 {
			di as err "Please specify positive number for break point value"
			exit 198		
		}
	}
	
	// If intvar is not specified at all; i.e. no interaction
	if "`intvar'" == "" {
		tempvar all1s 
		gen `all1s' = 1
		local intvar = `all1s'
	}
	// Obtain the lower and upper bound of the threshold variable
	qui sum `thvar' if `touse' 
	local lowb = `r(min)'
	local upb = `r(max)'
	// If lowest threshold value is specified
	if "`minth'" != "" {
		local lowb = `minth'
	}
	// If highest threshold value is specified
	if "`maxth'" != "" {
		local upb = `maxth'
	}
	
	// Post estimation results to data file 
	forval b = 1/`thnum' {
		local thnumlist `thnumlist' tau_`b'
	}
	
	if "`savefile'" == "" {
		tempfile tsavefile
		tempname resultlog
		postfile `resultlog' str20 emodel bic aic aicc hqic num_threshold `thnumlist' using `tsavefile', `replace'

	}
	else if "`savefile'" != "" {
		tempname resultlog
		postfile `resultlog' str20 emodel bic aic aicc hqic num_threshold `thnumlist' using `savefile', `replace'
	}
	// estiamte maximum number of iterations
	local uniquelv = round((`upb' - `lowb')/`stepsize')
	local maxint = comb(`uniquelv',`thnum')
	
	// Start main routine
	di as txt _newline
	di as txt "{hline}"
	di "Start main routine: maximum number of iterations = `maxint'"
	di as txt "{hline}"
	nois _dots 0, title(Progress) 
	global dotcounter = 0
	local ii = 0 // re-numbering so initial can be in negative values
	forval i = `lowb'(`stepsize')`upb' {
		if `i' < `upb' {
			tempvar d1_`ii' int1_`ii' int0_`ii'
			gen `d1_`ii'' = `thvar' <= `i' // First thnum
			gen `int1_`ii'' = `d1_`ii''*`intvar' // Dummy*Main intvar
			local skipiteration = 0 // if two dummies are the same, skip this iteration
			if `ii' > 0 { 
				tempvar d1_`ii'a int1_`ii'a 
				gen `d1_`ii'a' = `thvar' <= `i'-`stepsize'
				gen `int1_`ii'a' = `d1_`ii'a'*`intvar' 
				cap assert `int1_`ii'' == `int1_`ii'a' 
				if _rc == 0 {
					local skipiteration = 1
				}
			}
			cap drop `d1_`ii'a' `int1_`ii'a'
			if `skipiteration' == 0 {
				if `thnum' == 1 {
					gen `int0_`ii'' = (1-`d1_`ii'')*`intvar' // 1-Dummy*Main intvar
					// Run model and store results
					local intlist `int1_`ii'' `int0_`ii''
					_estmodel `emodel' `lhs' `rhs' `intlist', eoption(`eoption')
					// Post results
					post `resultlog' (["`emodel'"]) ([`r(bic)']) ([`r(aic)']) ([`r(aicc)']) ([`r(hqic)']) ([`thnum']) ([`i'])  
				}
				else {
					local jj = 0
					forval j = `i'(`stepsize')`upb' {
						if `j' > `i' & `j' < `upb' {
							tempvar d2_`jj' int2_`jj' 
							gen `d2_`jj'' = `thvar' <= `j'
							gen `int2_`jj'' = (`d2_`jj''-`d1_`ii'')*`intvar'
							local skipiteration = 0 // if two dummies are the same, skip this iteration
							if `jj' == 0 {
								cap assert `int2_`jj'' == `int1_`ii''
								if _rc == 0 {
									local skipiteration = 1
								}
							}
							if `jj' > 0 { 
								tempvar d2_`jj'a int2_`jj'a 
								gen `d2_`jj'a' = `thvar' <= `j'-`stepsize'
								gen `int2_`jj'a' = `d2_`jj'a'*`intvar' 
								cap assert `int2_`jj'' == `int2_`jj'a'
								if _rc == 0 {
									local skipiteration = 1
								}
							}
							cap drop `d2_`jj'a' `int2_`jj'a'
							if `skipiteration' == 0 {
								if `thnum' == 2 {
									gen `int0_`ii'' = (1-`d2_`jj'')*`intvar'					
									// Run model and store results
									local intlist `int1_`ii'' `int2_`jj'' `int0_`ii'' 
									_estmodel `emodel' `lhs' `rhs' `intlist', eoption(`eoption') 
									// Post results
									post `resultlog' (["`emodel'"]) ([`r(bic)']) ([`r(aic)']) ([`r(aicc)']) ([`r(hqic)']) ([`thnum']) ([`i']) ([`j'])  
									cap drop `d2_`jj'' `int2_`jj'' `int0_`ii''
								}
								else {
									local kk = 0
									forval k = `j'(`stepsize')`upb' {
										if `k' > `j' & `k' < `upb'{
											tempvar d3_`kk' int3_`kk' 
											gen `d3_`kk'' = `thvar' <= `k'
											gen `int3_`kk'' = (`d3_`kk''-`d2_`jj'')*`intvar'
											local skipiteration = 0 // if two dummies are the same, skip this iteration
											if `kk' == 0 {
												cap assert `int3_`kk'' == `int2_`jj''
												if _rc == 0 {
													local skipiteration = 1
												}
											}											
											if `kk' > 0 { 
												tempvar d3_`kk'a int3_`kk'a 
												gen `d3_`kk'a' = `thvar' <= `k'-`stepsize'
												gen `int3_`kk'a' = `d3_`kk'a'*`intvar'
												cap assert `int3_`kk'' == `int3_`kk'a' 
												if _rc == 0 {
													local skipiteration = 1
												}
											}
											cap drop `d3_`kk'a' `int3_`kk'a' 
											if `skipiteration' == 0 {											
												if `thnum' == 3 {
													gen `int0_`ii'' = (1-`d3_`kk'')*`intvar'
													// Run model and store results
													local intlist `int1_`ii'' `int2_`jj'' `int3_`kk'' `int0_`ii''
													_estmodel `emodel' `lhs' `rhs' `intlist', eoption(`eoption') 
													// Post results
													post `resultlog' (["`emodel'"]) ([`r(bic)']) ([`r(aic)']) ([`r(aicc)']) ([`r(hqic)']) ([`thnum']) ([`i']) ([`j']) ([`k'])
													cap drop `d3_`kk'' `int3_`kk'' `int0_`ii''
												}
												else {
													local ll = 0
													forval l = `k'(`stepsize')`upb' {
														if `l' > `k' & `l' < `upb' {
															tempvar d4_`ll' int4_`ll' 
															gen `d4_`ll'' = `thvar' <= `l'
															gen `int4_`ll'' = (`d4_`ll''-`d3_`kk'')*`intvar'
															local skipiteration = 0 // if two dummies are the same, skip this iteration
															if `ll' == 0 {
																cap assert `int4_`ll'' == `int3_`kk''
																if _rc == 0 {
																	local skipiteration = 1
																}
															}											
															if `ll' > 0 { 
																tempvar d4_`ll'a int4_`ll'a 
																gen `d4_`ll'a' = `thvar' <= `l'-`stepsize'
																gen `int4_`ll'a' = `d4_`ll'a'*`intvar' 
																cap assert `int4_`ll'' == `int4_`ll'a' 
																if _rc == 0 {
																	local skipiteration = 1
																}
															}
															cap drop `d4_`ll'a' `int4_`ll'a' 
															if `skipiteration' == 0 {														
																if `thnum' == 4 {
																	gen `int0_`ii'' = (1-`d4_`ll'')*`intvar'
																	// Run model and store results
																	local intlist `int1_`ii'' `int2_`jj'' `int3_`kk'' `int4_`ll'' `int0_`ii'' 
																	_estmodel `emodel' `lhs' `rhs' `intlist', eoption(`eoption') 
																	// Post results
																	post `resultlog' (["`emodel'"]) ([`r(bic)']) ([`r(aic)']) ([`r(aicc)']) ([`r(hqic)']) ([`thnum']) ([`i']) ([`j']) ([`k']) ([`l'])
																	cap drop `d4_`ll'' `int4_`ll'' `int0_`ii''
																}
																else {
																	local mm = 0
																	forval m = `l'(`stepsize')`upb' {
																		if `m' > `l' & `m' < `upb' {
																			tempvar d5_`mm' int5_`mm'
																			gen `d5_`mm'' = `thvar' <= `m'
																			gen `int5_`mm'' = (`d5_`mm''-`d4_`ll'')*`intvar'
																			local skipiteration = 0 // if two dummies are the same, skip this iteration
																			if `mm' == 0 {
																				cap assert `int5_`mm'' == `int4_`ll''
																				if _rc == 0 {
																					local skipiteration = 1
																				}
																			}
																			if `mm' > 0 { 
																				tempvar d5_`mm'a int5_`mm'a 
																				gen `d5_`mm'a' = `thvar' <= `m'-`stepsize'
																				gen `int5_`mm'a' = `d5_`mm'a'*`intvar'
																				cap assert `int5_`mm'' == `int5_`mm'a' 
																				if _rc == 0 {
																					local skipiteration = 1
																				}
																			}
																			cap drop `d5_`mm'a' `int5_`mm'a'
																			if `skipiteration' == 0 {
																				if `thnum' == 5 {
																					gen `int0_`ii'' = (1-`d5_`mm'')*`intvar'
																					// Run model and store results
																					local intlist `int1_`ii'' `int2_`jj'' `int3_`kk'' `int4_`ll'' `int5_`mm'' `int0_`ii'' 
																					_estmodel `emodel' `lhs' `rhs' `intlist', eoption(`eoption') 
																					// Post results
																					post `resultlog' (["`emodel'"]) ([`r(bic)']) ([`r(aic)']) ([`r(aicc)']) ([`r(hqic)']) ([`thnum']) ([`i']) ([`j']) ([`k']) ([`l']) ([`m'])
																					cap drop `d5_`mm'' `int5_`mm'' `int0_`ii''
																				}
																				else {
																					local nn = 0
																					forval n = `m'(`stepsize')`upb' {
																						if `n' > `m' & `n' < `upb' {
																							tempvar d6_`nn' int6_`nn' 
																							gen `d6_`nn'' = `thvar' <= `n'
																							gen `int6_`nn'' = (`d6_`nn''-`d5_`mm'')*`intvar'
																							local skipiteration = 0 // if two dummies are the same, skip this iteration
																							if `nn' == 0 {
																								cap assert `int6_`nn'' == `int5_`mm''
																								if _rc == 0 {
																									local skipiteration = 1
																								}
																							}
																							if `nn' > 0 { 
																								tempvar d6_`nn'a int6_`nn'a 
																								gen `d6_`nn'a' = `thvar' <= `n'-`stepsize'
																								gen `int6_`nn'a' = `d6_`nn'a'*`intvar'
																								cap assert `int6_`nn'' == `int6_`nn'a' 
																								if _rc == 0 {
																									local skipiteration = 1
																								}
																							}
																							cap drop `d6_`nn'a' `int6_`nn'a'
																							if `skipiteration' == 0 {
																								if `thnum' == 6 {
																									gen `int0_`ii'' = (1-`d6_`nn'')*`intvar'
																									// Run model and store results
																									local intlist `int1_`ii'' `int2_`jj'' `int3_`kk'' `int4_`ll'' `int5_`mm'' `int6_`nn'' `int0_`ii'' 
																									_estmodel `emodel' `lhs' `rhs' `intlist', eoption(`eoption') 
																									// Post results
																									post `resultlog' (["`emodel'"]) ([`r(bic)']) ([`r(aic)']) ([`r(aicc)']) ([`r(hqic)']) ([`thnum']) ([`i']) ([`j']) ([`k']) ([`l']) ([`m']) ([`n'])
																									cap drop `d6_`nn'' `int6_`nn'' `int0_`ii''
																								}
																								else {
																									di as err "Too many threshold"
																									exit 198
																								}
																							}
																							local ++nn
																						}
																						cap drop `d6_`nn'' `int6_`nn'' 
																					}
																				}
																			}
																			local ++mm
																		}
																		cap drop `d5_`mm'' `int5_`mm''
																	}
																}
															}
															local ++ll
														}
														cap drop `d4_`ll'' `int4_`ll'' 
													}
												}
											}
											local ++kk
										}
										cap drop `d3_`kk'' `int3_`kk''
									}
								}
							}
							local ++jj
						}
						cap drop `d2_`jj'' `int2_`jj'' 
					}
				}
			}
			local ++ii
		}
		cap drop `d1_`ii'' `int1_`ii'' `int0_`ii''
	}	
	
	postclose `resultlog'
	restore
	
	// Print results 
	preserve
	
	if "`savefile'" == "" {
		use `tsavefile', clear
	}
	else if "`savefile'" != "" {
		use `savefile', clear
	}
	
	if "`criteria'" == "" {
		local criteria "bic"
	}
	sort `criteria'
	egen min`criteria'=min(`criteria')

	// Store results
	return local emodel = "`emodel'"
	return local cri = "`criteria'"
	qui sum `criteria' if `criteria'==min`criteria' 
	local mincri = `r(min)'
	return local mincri = `mincri'
	forval b = 1/`thnum' {
		qui sum tau_`b' if `criteria'==min`criteria' 
		local tau_`b' = `r(min)'
		return local tau_`b' = `r(min)'
		local blist `blist' `tau_`b''
	}
	
	di as txt _newline
	di as txt "{hline}"
	di as txt "Threshold Search Model"
	di as txt "{hline}"
	di as txt "Regression method: {cmd:`emodel'}"
	di as txt "Optimal threshold value(s) of -`thvar'- at {cmd:`blist'}"
	di as txt "Information criteria selected: {cmd:`criteria'} with lowest value {cmd:`mincri'}"
	di as txt "Total number of regressions performed: {cmd:${dotcounter}}"
	di as txt "{hline}"

	restore
	
	// Re-estimate model with the minimum IC 
	cap drop int*_th`thnum'
	qui sum `thvar' if `touse' 
	*local lowb = `r(min)'
	forval b = 1/`thnum' {
		tempvar d`b'
		gen `d`b'' = `thvar' <= `tau_`b''
	}
	gen int1_th`thnum' = `d1'*`intvar'
	forval b = 2/`thnum' {
		local a = `b'-1
		gen int`b'_th`thnum' = (`d`b''-`d`a'')*`intvar'
	}
	gen int0_th`thnum' = (1-`d`thnum'')*`intvar'
	
	// Rename variable to meaningful name for dummy only and interaction terms
	local nvlist ""
	if "`intvar'" != "1" {
		forval b = 1/`thnum' {
			cap drop `thvar'X`intvar'_`b'_th`thnum'
			rename int`b'_th`thnum' `thvar'X`intvar'_`b'_th`thnum'
			label var `thvar'X`intvar'_`b'_th`thnum' "tau`b' at `tau_`b''"
			local nvlist `nvlist' `thvar'X`intvar'_`b'_th`thnum'
		}
		cap drop `thvar'X`intvar'_0_th`thnum'
		rename int0_th`thnum' `thvar'X`intvar'_0_th`thnum'
		label var `thvar'X`intvar'_0_th`thnum' "Basline"
		local nvlist `nvlist' `thvar'X`intvar'_0_th`thnum'
	}
	else if "`intvar'" == "1" {
		cap drop int0_th`thnum'
		forval b = 1/`thnum' {
			cap drop `thvar'_D`b'_th`thnum'
			rename int`b'_th`thnum' `thvar'_D`b'_th`thnum'
			label var `thvar'_D`b'_th`thnum' "tau`b' at `tau_`b''"
			local nvlist `nvlist' `thvar'_D`b'_th`thnum'
		}
	}
	
	di _newline
	di as txt "{hline}"
	di as text "Regression model with lowest IC: " _newline "{cmd:`emodel' `lhs' `nvlist' `rhs'`next'`eoption'}"
	di as txt "{hline}"
	
	`emodel' `lhs' `nvlist' `rhs' if `touse', `eoption'
	
	di as txt _newline

end

// Sub-rotuine _estmodel for estimation and storing IC
cap program drop _estmodel
program _estmodel, rclass
	version 13.1
	syntax namelist, [eoption(string)]
	gettoken emodel vars: namelist
	// Run model 
	qui `emodel' `vars', `eoption'
	
	// Ordered probit
	if "`emodel'" == "oprobit" {
		// Store and calculate IC
		local n		=e(N)
		local lnn	=log(`n')
		local llnn	=log(`lnn')
		local np2	=e(k_aux)
		local np3	=e(df_m)
		local np4	=`np2'+`np3'
		local l1	=e(ll)
		local ll2	=-2*e(ll)
		local aic	=`ll2'+ 2*`np4'
		local np5	=`np4'+1
		local bic	=`ll2'+(`np4'*`lnn')
		local aicc	=`ll2'+(`np4'*(1+`lnn'))
		local hqic	=`ll2'+(`np4'*(2*`llnn'))						
	}
	// Probit
	if "`emodel'" == "probit" {
		// Store and calculate IC
		local n		=e(N)
		local lnn	=log(`n')
		local llnn	=log(`lnn')
		local np3	=e(df_m)+1
		local np4	=`np3'
		local l1	=e(ll)
		local ll2 	=-2*e(ll)
		local aic	=`ll2'+ 2*`np4'
		local np5	=`np4'+1
		local bic	=`ll2'+(`np4'*`lnn')
		local aicc	=`ll2'+(`np4'*(1+`lnn'))
		local hqic	=`ll2'+(`np4'*(2*`llnn'))
	}
	// Linear model
	if regexm("`emodel'", "^ *reg(ress)? *$") == 1 | (regexm("`emodel'", "^ *xtreg *$") == 1 & regexm("`eoption'", "^ *fe") == 1) {
		// Store and calculate IC
		local n		=e(N)
		local lnn	=log(`n')
		local llnn	=log(`lnn')
		*local np2	=e(k_aux)
		local np3	=e(df_m)+1
		local np4	=`np3'
		local l1	=e(ll)
		local ll2 	=-2*e(ll)
		local aic	=`ll2'+ 2*`np4'
		local np5	=`np4'+1
		local bic	=`ll2'+(`np4'*`lnn')
		local aicc	=`ll2'+(`np4'*(1+`lnn'))
		local hqic	=`ll2'+(`np4'*(2*`llnn'))
	}
	// Other models (using -estimates stats- for BIC and AIC)
	/*
	else { 
		// Store and calculate IC
		qui estimates stats
		mat b = r(S)
		local bic=b[1,6]
		local aic=b[1,5]
		local aicc=.
		local hqic=.
	}
	*/
	return local bic = `bic'
	return local aic = `aic'
	return local aicc = `aicc'
	return local hqic = `hqic'
	
	global dotcounter = ${dotcounter} + 1 
	nois _dots ${dotcounter} 0
	
end
 
********************************************************************************************************************************************

/*Routine end*/

