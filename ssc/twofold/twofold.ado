*PERFORMS TWO-FOLD FULLY CONDITIONAL SPECIFICATION MULTIPLE IMPUATION ALGORITHM
*VERSION 3: RUNS MI IMPUTE CHAINED ONCE TO PRODUCE IMPUTATIONS
*Uses the mi impute chained options seed, savetrace, dryrun and force
*Runs if some time points are completely observed or completely missing
*Change imputation order for variables with missing data if necessary for conditional statements 

program define twofold
local default_seed=int(uniform()*100)
syntax, [WIDTH(integer 1) BA(integer 10) M(integer 5) BW(integer 5) CAT(string  ) BASE(string  ) INDOBS(string  ) DEPOBS(string  ) INDMIS(string  ) DEPMIS(string  ) OUTCOME(string  ) CONDITIONON(string  ) CONDVAR(string  )  CONDVAL(string  ) SAVING(string  ) SAVETRACE(string asis) CLEAR TABLE IM KEEPOUTSIDE SEED(integer `default_seed') DRYRUN FORCE OMIT(string ) ] TIMEIN(string) TIMEOUT(string) 


qui cap {

	version 12
	
	*DO NOT RUN IF DATA ALREADY IMPUTED
	cap confirm var _mi_m
	if !_rc {
		tab _mi_m
		if r(r)>0 {
			nois di as error "Data already imputed"
			error 1000
		}
	}
	
	*CREATE START AND END TIME POINTS
	cap confirm var `timein'
	if _rc {
		nois di as error "Variable `timein' in timein() option not recognoised"
		error 111
	}
	else {
		sum `timein'
		local start=r(min)
	}
	cap confirm var `timeout'
	if _rc {
		nois di as error "Variable `timeout' in timeout() option not recognoised"
		error 111
	}
	else {
		sum `timeout'
		local end=r(max)	
	}	
	
	*CHECK SAVING OPTIONS ARE CORRECTLY SPECIFIED
	if "`saving'"=="" & "`clear'"=="" {
		nois di as err "saving() and/or clear required"
		error 100
	}
	if `"`saving'"'!="" {
		tokenize `"`saving'"', parse(",")
		if `"`2'"'!="" {
			if `"`2'"'!="," | `"`4'"'!="" error 198
			if `"`3'"'!="" {
				if `"`3'"'!="replace" error 198
				local replace replace
			}
		}
		local using `1'

		if "`replace'"=="" {
			if substr(`"`using'"', -4, .) != ".dta" confirm new file `"`using'.dta"'
			else confirm new file `"`using'"'
		}	
	}	
	
	if `"`savetrace'"'!="" {
		tokenize `"`savetrace'"', parse(",")
		if `"`2'"'!="" {
			if `"`2'"'!="," | `"`4'"'!="" error 198
			if `"`3'"'!="" {
				if strpos(`"`3'"',"replace")>0 	local replace_savetrace replace
			}
		}
		local using_savetrace `1'
		local option_savetrace `3'

		if "`replace_savetrace'"=="" {
			if substr(`"`using_savetrace'"', -4, .) != ".dta" confirm new file `"`using_savetrace'.dta"'
			else confirm new file `"`using_savetrace'"'
		}	
		if substr(`"`using_savetrace'"', -4, .) != ".dta" local using_savetrace `"`using_savetrace'.dta"'	
	}


	if "`indmis'"=="" & "`depmis'"=="" {
		nois di as error "No variables with missing values specified using indmis or depmis"
		error 198
	}
	
	if "`indmis'"!="" & "`base'"=="" {
		nois di as error "Please specify a baseline time using base when imputing time-independent variables using indmis"
		error 198
	}	
	
	foreach i in indobs depmis depobs {
		if "``i''"!="" & "`indmis'"!="" {
			foreach v of varlist `indmis' {
				foreach x in ``i'' {
					if "`v'"=="`x'" {
						nois di as error "`v' is specified in indmis() and `i'()"
						error 198
					}
				}
			}
		}
	}
	
	if "`indobs'"!="" | "`depmis'"!="" {		
		foreach i in indobs depmis {
			if "``i''"!="" & "`depobs'"!="" {		
				foreach v in `depobs' {
					foreach x in ``i'' {
						if "`v'"=="`x'" {
							nois di as error "`v' is specified in `i'() and depobs()"
							error 198
						}
					}
				}	
			}
		}	
		foreach v in `indobs' {
			foreach x in `depmis' {
				if "`v'"=="`x'" {
					nois di as error "`v' is specified in indobs() and depmis()"
					error 198
				}
			}
		}	
	}
	
	if `end'<=`start' {
		nois di as error "The last time point, specified by `timeout', is before the first time point, specified by `timein'"
		error 198
	}	
		
	
	if `width'>=`end'-`start'+1 {
		nois di as error "The specified window width is the same/greater than the number of time points"
		nois di as error "Consider using an imputation model which includes measurements at each"
		nois di as error "time point as separate variables in the model or reduce the window width"
		error 198
	}
	
	*CONFIRM EACH OF THE SPECIFIED VARIABLES EXIST
	if "`indmis'"!="" | "`indobs'"!="" {		
		foreach v of varlist `indmis' `indobs' {
			set output error
			confirm variable `v'
		}
	}
	
	if "`depmis'"!="" | "`depobs'"!="" {
		foreach v in `depmis' `depobs' {
			forvalues i=`start'/`end' {
				set output error
				confirm variable `v'`i'
			}
		}
	}
	
	if "`base'"!="" {
		count if `base'<`timein' | `base'>`timeout' 
		if r(N)>0 {
			nois di as error "The baseline time points specified for some/all records are outside the follow-up time"
			error 198
		}
	}	
		
	*CHECK ALL COMPLETELY OBSERVED VARIABLES DO NOT HAVE ANY MISSING DATA
	if "`indobs'"!="" {
		foreach v of varlist `indobs' {
			count if missing(`v')
			if r(N)>0 {
				nois di as error "`v' is defined as a completely observed variable but has missing values"
				error 198
			}
		}
	}
	if "`depobs'"!="" {
	foreach v in `depobs' {
			forvalues i=`start'/`end' {
				count if missing(`v'`i') & inrange(`i',`timein',`timeout')
				if r(N)>0 {
					nois di as error "`v'`i' is defined as a completely observed variable but has missing values"
					error 198
				}
			}
		}
	}
	
	if `start'<0 {
		nois di as error "All time points must be positive"
		error 111
	}
	
	*CREATE TABLE OF MISSING VALUES
	if "`table'"!="" {
		qui {
			if "`indmis'"!="" {
				nois di _n in gr "Time-independent    {c |}"
				nois di in gr "variables           {c |}"		
				nois di in gr "with missing values {c |} Percentage of missing values"
				nois di in gr "{hline 20}{c +}{hline 30}"
				foreach v of varlist `indmis' {
					count if missing(`v')
					nois di in smcl in gr %19s abbrev("`v'",19) " {c |} " in ye %10.1f `"`=string(r(N)*100/`=_N',"%10.1f")'"'
				}		
			}
			if "`depmis'"!="" {
				nois di _n in gr "Time-dependent      {c |} Percentage of missing values"
				nois di in gr "variables           {c |} at each time point"
				local timepoints
				local i 1
				forvalues j=`start'/`end' {
					local timepoints `timepoints' _col(`=(`i'*8)+20') `j'
					local ++i
				}
				nois di in gr "with missing values {c |}   "`timepoints'
				noi di in gr "{hline 20}{c +}{hline `=8*(`end'-`start'+1.5)'}"

				foreach v in `depmis' {
					local output
					local i 1
					forvalues j=`start'/`end' {
						count if missing(`v'`j') 
						local output `output'  _col(`=(`i'*8)+20') `"`=string(r(N)*100/`=_N',"%5.1f")'"'
						local ++i
					}
					noi di in smcl in gr %19s abbrev("`v'",19) " {c |} " in ye `output' _n
				}	
			}
		}
	}
	
	
	*THE SAME NUMBER OF PARAMETERS MUST BE SPECIFIED FOR 
	*CONDITIONON CONDVAR CONDVAL
	if wordcount("`conditionon'")!=wordcount("`condvar'") | wordcount("`conditionon'")!=wordcount("`condval'") | wordcount("`condval'")!=wordcount("`condvar'") {
		nois di as error "Please specifiy each condition option separately"
		nois di as error "There should be the same number of parameters for condvar, condval & conditionon"
		error 198
	}
	
		*CHECK VARIABLES IN CONDVAR ALSO SPECIFIED IN INDMIS AND DEPMIS
		if "`condvar'"!="" | "`indmis'"!="" | "`depmis'"!="" {
			foreach cvar in `condvar' {
				local stop 0
				foreach i in `indmis' `depmis'{
					if "`i'"=="`cvar'" local stop 1
				}				
				if `stop'==0 {
					nois di as error "Variables defined using condvar not specified by indmis or depmis"
					error 198
				}
			}
		}	
	

		*CREATE IF STATEMENT FOR TIME-INDEPENDENT VARIABLES WITH CONDITION
		if "`condvar'"!="" & "`condval'"!="" & "`conditionon'"!="" {	
			local word=wordcount("`condvar'")
			forvalues k=1/`word' {
				tokenize `condvar'
				local cvar ``k''
				
				*CHECK CONDVAR IS A TIME-INDEPENDENT VARIABLE
				cap confirm variable `cvar'
				if _rc {
					continue, break
				}
				
				tokenize `condval'
				local cval ``k''
					
				tokenize `conditionon'
				local z ``k''
							
				local tostop 0
				if "`cat'"!="" {
					foreach c in `cat' {
						if strpos("`z'","`c'")>0 {
							*if conditioning variable is time independent
							foreach var in `indmis' `indobs' {
								if "`var'"=="`z'" {
									local if_`cvar' if `z'==`cval'
									local omit_`cvar' i.`z'
									local tostop 1
									continue, break
								}
							}
							*if conditioning variable is time dependent and time point not specified
							foreach var in `depmis' `depobs' {
								if "`var'"=="`z'" {
									nois di as error "Please Specify time point for variable `var' in condition option"
									error 111
								}
							}
							*if conditioning variable is time dependent and time point not specified
							foreach var in `depmis' `depobs' {
								forvalues j=1/`bw' {
									if "`var'`j'"=="`z'" {
										local if_`cvar' if `z'_`bw'==`cval'
										local omit_`cvar' i.`z'_`bw'
										local tostop 1
										continue, break
									}
								}
							}
						}
					}
				}
				
				if "`cat'"=="" | `tostop'==0 {
					*if conditioning variable is time independent
					foreach var in `indmis' `indobs' {
						if "`var'"=="`z'" {
							local if_`cvar' if `z'==`cval'
							local omit_`cvar' `z'
							local tostop 1
							continue, break
						}
					}
					*if conditioning variable is time dependent and time point not specified
					foreach var in `depmis' `depobs' {
						if "`var'"=="`z'" {
							if "`var'"=="`z'" {
								nois di as error "Please Specify time point for variable `var' in condition option"
								error 111
							}
						}
					}
					*if conditioning variable is time dependent and time point not specified
					foreach var in `depmis' `depobs' {
						forvalues t=1/`bw' {
							if "`var'`t'"=="`z'" {
								local if_`cvar' if `z'_`bw'==`cval'
								local omit_`cvar' `z'_`bw'
								local tostop 1
								continue, break
							}
						}
					}
				}
			}
		}
		forvalues i=`start'/`end' {	
			*CREATE IF STATEMENT FOR TIME-DEPENDENT VARIABLES WITH CONDITION
			if "`condvar'"!="" & "`condval'"!="" & "`conditionon'"!=""  {	
				local word=wordcount("`condvar'")
				forvalues k=1/`word' {
					tokenize `condvar'
					local cvar ``k''
					
					tokenize `condval'
					local cval ``k''
						
					tokenize `conditionon'
					local z ``k''
					
					forvalues j=1/`bw' {
					
						local tostop 0
						if "`cat'"!="" {
							foreach c in `cat' {
								if strpos("`z'","`c'")>0 {
								
									*if conditioning variable is time independent
									foreach var in `indmis' `indobs' {
										if "`var'"=="`z'" {
											local if_`cvar'`i'_`j' if `z'==`cval'
											local omit_`cvar'`i'_`j'  i.`z'
											local tostop 1
											continue, break
										}
									}
									*if conditioning variable is time dependent and time point not specified
									foreach var in `depmis' `depobs' {
										if "`var'"=="`z'" {
											nois di as error "Please Specify time point for variable `var' in condition option"
											error 111
										}
									}
									*if conditioning variable is time dependent and time point not specified
									foreach var in `depmis' `depobs' {
										forvalues t=1/`bw' {
											nois di as error "Please Specify time point for variable `var' in condition option"
											error 111
										}
									}							

								}								
							}
							if "`cat'"=="" | `tostop'==0 {
								cap confirm variable `z'
								if !_rc {
									local omit_`cvar'`i'_`j' `omit_`cvar'`i'_`j'' `z'
									local if_`cvar'`i' if `z'==`cval'
								}
								else {
									if local omit_`cvar'`i' `omit_`cvar'`i'_`j'' `z'`i'
									local if_`cvar'`i'_`j' if `z'`i'==`cval'
								}
							}
						}
					
						if "`cat'"=="" | `tostop'==0 {

							*if conditioning variable is time independent
							foreach var in `indmis' `indobs' {
								if "`var'"=="`z'" {
									local if_`cvar'`i'_`j' if `z'==`cval'
									local omit_`cvar'`i'_`j'  `z'
									local tostop 1
									continue, break
								}
							}
							*if conditioning variable is time dependent and time point not specified
							foreach var in `depmis' `depobs' {
								if "`var'"=="`z'" 		{						
									nois di as error "Please Specify time point for `var' in condition option"
									error 111
								}
							}
							*if conditioning variable is time dependent and time point not specified
							foreach var in `depmis' `depobs' {
								forvalues t=1/`bw' {
									if "`var'`t'"=="`z'" {
										local if_`cvar'`i'_`j' if `z'_`bw'==`cval'
										local omit_`cvar'`i'_`j' `z'_`bw'
										local tostop 1
										continue, break
									}
								}
							}
							

						}

					}
				}
			}		
		}
		
		*TIME-INDEPENDENT VARIABLES CONDITION ON BASELINE VARIABLES ONLY
		local missingvars 
		foreach i in `indmis' {
			local missingvars `missingvars' `i'
			foreach j in  `depmis' {
				forvalues t=`start'/`end' {
					local tostop 0
					if "`cat'"!="" {
						foreach c in `cat' {
							if "`j'"=="`c'" {
								if `t'==`base' local incl_`i' `incl_`i'' i.`j'`t'_`bw'
								local tostop 1
								continue, break
							}
						}
					}
					if "`cat'"=="" | `tostop'==0 {
						if `t'==`base' local incl_`i' `incl_`i'' `j'`t'_`bw'
					}
				}
			}
			foreach j in `depobs'  {
				forvalues t=`start'/`end' {
					local tostop 0
					if "`cat'"!="" {
						foreach c in `cat' {
							if "`j'"=="`c'" {
								if `t'!=`base' local omit_`i' `omit_`i'' i.`j'`t'
								local tostop 1
								continue, break
							}
						}
					}
					if "`cat'"=="" | `tostop'==0 {
						if `t'!=`base' local omit_`i' `omit_`i'' `j'`t'
					}
				}
			}			
		}
		

		*CREATE VARIABLES
		forvalues t=`start'/`end' {
			foreach var in `depmis' {
		
				count if missing(`var'`t')
				if r(N)==0 	local depmis_obsvar `depmis_obsvar' `var'`t'	
				else forvalues i=1/`bw' {
						gen `var'`t'_`i'=`var'`t'
				}
			}
		}

		local depvar		
		forvalues t=`start'/`end' {

			*IDENTIFY WHICH TIME POINTS FOR TIME-DEPENDENT VARIABLES ARE INCLUDED IN IMPUTATION MODEL
			local counter 1			
			forvalues i=1/`bw' {
				foreach var in `depmis' {
				
					count if missing(`var'`t')
					if r(N)!=0 & r(N)!=_N {				
				
						local depvar `depvar' `var'`t'_`i'
						local missingvars `missingvars' `var'`t'_`i'
						
						
						local tostop 0
						if "`cat'"!="" {
							foreach c in `cat' {
								if "`var'"=="`c'" {
									local number_`counter' i.`var'`t'_`i'
									continue, break
								}
								else {
									local number_`counter' `var'`t'_`i'
									continue, break
								}
							}
						}
						else {
							local number_`counter' `var'`t'_`i'
							continue, break
						}
					
						foreach j in `depmis' {
							forvalues x=`start'/`end' {
							
								count if missing(`j'`x')					
								if r(N)!=_N & r(N)!=0 {
									local tostop 0

									if "`cat'"!="" {
										foreach c in `cat' {					
											if "`j'"=="`c'" {
												if `x'<=`t'+`width' & `x'>=`t'-`width' & `x'!=`t'   local incl_`var'`t'_`i' `incl_`var'`t'_`i'' i.`j'`x'_`bw'
												if  `x'==`t' & `i'==1 & "`var'"!="`j'"  local incl_`var'`t'_`i' `incl_`var'`t'_`i'' i.`j'`x'_1
												
												local tostop 1
												continue, break										
											}
										}
									}
								
									if "`cat'"=="" | `tostop'==0 {
											if `x'<=`t'+`width' & `x'>=`t'-`width' & `x'!=`t' local incl_`var'`t'_`i' `incl_`var'`t'_`i'' `j'`x'_`bw'					
											if  `x'==`t' & `i'==1  & "`var'"!="`j'"   local incl_`var'`t'_`i' `incl_`var'`t'_`i'' `j'`x'_1	
									}
								}
								if r(N)==_N {
									local tostop 0

									if "`cat'"!="" {
										foreach c in `cat' {					
											if "`j'"=="`c'" {
												if `x'<=`t'+`width' & `x'>=`t'-`width' & `x'!=`t'   local incl_`var'`t'_`i' `incl_`var'`t'_`i'' i.`j'`x'
												if  `x'==`t' & `i'==1 & "`var'"!="`j'"  local incl_`var'`t'_`i' `incl_`var'`t'_`i'' i.`j'`x'
												
												local tostop 1
												continue, break										
											}
										}
									}
								
									if "`cat'"=="" | `tostop'==0 {
											if `x'<=`t'+`width' & `x'>=`t'-`width' & `x'!=`t' local incl_`var'`t'_`i' `incl_`var'`t'_`i'' `j'`x'					
											if  `x'==`t' & `i'==1  & "`var'"!="`j'"   local incl_`var'`t'_`i' `incl_`var'`t'_`i'' `j'`x'
									}
								}								
								
								
							
							}
							
						}
						local varnum wordcount("`depmis'")
						forvalues v=1/`=`varnum'-1' {
							if   `i'>1  local incl_`var'`t'_`i' `incl_`var'`t'_`i'' `number_`=`counter'-`v''' 
						}

						foreach v in `depobs' {
							local tostop 0
							forvalues x=`start'/`end' {
								if "`cat'"!="" {
									foreach c in `cat' {					
										if "`v'"=="`c'" {
											if (`x'>`t'+`width' & `x'<=`end')|(`x'<`t'-`width' & `x'>=`start') local omit_`var'`t'_`i' `omit_`var'`t'_`i'' i.`v'`x'
											local tostop 1
											continue, break
										}
									}
								}
								if "`cat'"=="" | `tostop'==0 {
									 if (`x'>`t'+`width' & `x'<=`end')|(`x'<`t'-`width' & `x'>=`start') local omit_`var'`t'_`i' `omit_`var'`t'_`i'' `v'`x'
								}
								
							}
						}	
						foreach v in `depmis_obsvar' {
							local tostop 0
							forvalues x=`start'/`end' {
								if "`cat'"!="" {
									foreach c in `cat' {					
										if "`v'"=="`c'`x'" {
											if (`x'>`t'+`width' & `x'<=`end')|(`x'<`t'-`width' & `x'>=`start') local omit_`var'`t'_`i' `omit_`var'`t'_`i'' i.`v'
											local tostop 1
											continue, break
										}
									}
								}
								if "`cat'"=="" | `tostop'==0 {
									 if (`x'>`t'+`width' & `x'<=`end')|(`x'<`t'-`width' & `x'>=`start') local omit_`var'`t'_`i' `omit_`var'`t'_`i'' `v'
									 continue, break
								}
								
							}
						}	
						
						
						foreach v in `indmis' {
							local tostop 0
							if "`cat'"!="" {
								foreach c in `cat' {					
									if "`v'"=="`c'" {
										local incl_`var'`t'_`i' `incl_`var'`t'_`i'' i.`v'
										local tostop 1
										continue, break
									}
								}
							}
							if "`cat'"=="" | `tostop'==0 {
								local incl_`var'`t'_`i' `incl_`var'`t'_`i'' `v'
							}
						
						}					
						local counter=`counter'+1
						*nois di "`var'`t'_`i': `incl_`var'`t'_`i''"	
					
	
					}
					
				}
			}
			
			foreach v in `depobs' {
				local depvar `depvar' `v'`t'
			}	
		}
		
		if "`condvar'"!="" {
			foreach i in `indmis'  {
				if strpos("`conditionon'","`i'")>0 & strpos("`condvar'","`i'")==0 {
					local iorder1 `iorder1' `i'
				}
				else if strpos("`conditionon'","`i'")>0 & strpos("`condvar'","`i'")>0 {
					local iorder2 `iorder2' `i'
				}
				else if strpos("`conditionon'","`i'")==0 & strpos("`condvar'","`i'")>0 {
					local iorder3 `iorder3' `i'
				}	
				else {
					local iorder4 `iorder4' `i'
				}
			}
			foreach i in `depmis' {
				if strpos("`conditionon'","`i'")>0 & strpos("`condvar'","`i'")==0 {
					local dorder1 `dorder1' `i'
				}				
				else if strpos("`conditionon'","`i'")>0 & strpos("`condvar'","`i'")>0 {
					local dorder2 `dorder2' `i'
				}
				else if strpos("`conditionon'","`i'")==0 & strpos("`condvar'","`i'")>0 {
					local dorder3 `dorder3' `i'
				}	
				else {
					local dorder4 `dorder4' `i'
				}
			}		
			if "`iorder1'"=="" & "`dorder1'"!="" {
				local order `iorder4' `depvar' `iorder2' `iorder3'
			}
			else {
				local order `iorder4' `iorder1' `iorder2' `depvar' `iorder3'
			}
		}
		else {
			local order `indmis' `depvar'
		}
	nois di "order `order'"
		*** CREATE SYNTAX FOR MI IMPUTE CHAINED COMMAND ***
		local vars_syntax
		local auxvarsind
		
		foreach var in  `order' `indobs' `outcome' `depmis_obsvar' {	
			if "`omit'"!="" {
				local word=wordcount("`omit'")
				forvalues k=1/`word' {
					tokenize `omit'
					local ovar ``k''
					if "`ovar'"!="`var'"  local omit_`var' `omit_`var'' `ovar'
					if "`ovar'"=="`var'"  {
						local tostop 0
						foreach v in `depmis_obsvar' {
							forvalues x=`start'/`end' {
								if "`cat'"!="" {
									foreach c in `cat' {					
										if "`v'"=="`c'`x'" {
											local omit_``k'' `omit_``k''' i.`v' 
											local tostop 1
											continue, break
										}
									}
								}
								if "`cat'"=="" | `tostop'==0 {
									 local omit_``k'' `omit_``k''' `v' 
									 continue, break
								}
							}
						}
					}
				}
			}
			
			if substr("`var'",1,2)=="i." {
				local sub=substr("`var'",3,.)
				count if missing(`sub')
				local miss=r(N)
			}
			else count if missing(`var')
			local miss=r(N)
			*DONT INCLUDE IN REGRESSION IF COMPLETELY MISSING OR COMPLETELY OBSERVED
			if `miss'>0 & `miss'!=_N {			
				local tostop 0
				if "`cat'"!="" {
					foreach c in `cat' {
						forvalues i=`start'/`end' {
							forvalues x=1/`bw' {
								if ("`var'"=="`c'" | "`var'"=="`c'`i'" | "`var'"=="`c'`i'_`x'" | "`var'"=="before`c'`i'" | "`var'"=="after`c'`i'") & `tostop'==0 {
									qui tab `var' `if_`var''
									if r(r)==2 {
										local vars_syntax `vars_syntax' (logit, cond(`if_`var'') omit(`omit_`var'') include(`incl_`var'') augment) `var'
										local tostop 1
										continue, break									
									}
									else {										
										local vars_syntax `vars_syntax' (mlogit, cond(`if_`var'') omit(`omit_`var'') include(`incl_`var'') augment) `var'
										local tostop 1
										continue, break
									}
								}	
							}
						}
					}
				}
				if "`cat'"=="" | `tostop'==0 {
					local vars_syntax `vars_syntax' (regress, cond(`if_`var'') omit(`omit_`var'') include(`incl_`var'')) `var'
				}
			}
			
			else if r(N)==0 {
				local tostop 0
			
					if "`cat'"!=""  {
						foreach c in `cat' {
							forvalues i=`start'/`end' {
								forvalues x=1/`bw' {
									if ("`var'"=="`c'" | "`var'"=="`c'`i'" | "`var'"=="`c'`i'_`x'") & `tostop'==0 {
										local auxvarsind `auxvarsind' i.`var'
										local tostop 1
									}
								}
							}
						}
						if `tostop'==0 {
							local auxvarsind `auxvarsind' `var'
							local tostop 1							
						}
					
					}
					else {
						local auxvarsind `auxvarsind' `var'
					}	
			}
		}
		
		
		
		mi set flong
		cap mi register imputed `missingvars' 
		if _rc {
			nois di as err "The variables defined in depmis and/or indmis have no missing values"
			error 198
			nois di "`=_rc'"
		}
		if "`im'"!="" nois di _n "mi impute chained `vars_syntax' = `auxvarsind', burnin(`ba')  orderasis chaindots add(`m') noimputed force rseed(`seed') `dryrun' `force'"
		if "`im'"!="" & `"`savetrace'"'!="" nois di "savetrace(`using_savetrace', `option_savetrace') "
		if `"`savetrace'"'=="" nois mi impute chained `vars_syntax' = `auxvarsind', burnin(`ba')  orderasis chaindots add(`m') noimputed force rseed(`seed') `dryrun' `force'
		else nois mi impute chained `vars_syntax' = `auxvarsind', burnin(`ba')  orderasis chaindots add(`m') noimputed force rseed(`seed') `dryrun' `force' savetrace(`"`using_savetrace'"', `option_savetrace') 
		
		if "`dryrun'"!="" {
			mi extract 0, clear
			foreach i in `depmis' {
				forvalues j=`start'/`end' {
					count if missing(`i'`j')
					if r(N)!=0 & r(N)!=_N {	
						forvalues w=1/`bw'{
							cap drop `i'`j'_`w'
						}
					}
				}
			}
		}
		else {
			foreach i in `depmis' {
				forvalues j=`start'/`end' {
					count if missing(`i'`j')
					if r(N)!=0 & r(N)!=_N {	
						replace `i'`j'=`i'`j'_`bw' if _mi_m>0 & missing(`i'`j')
						forvalues w=1/`bw'{
							drop `i'`j'_`w'
						}
					}	
				}
			}
			*DROP IMPUTED VALUES OUTSIDE OF FOLLOW-UP
			if "`keepoutside'"=="" {
				foreach v in `depmis'{
					forvalues j=`start'/`end' {
						replace `v'`j'=. if !inrange(`j',`timein',`timeout')
					}
				}
			}
			if "`using'"!="" & "`clear'"=="" {
				save `"`using'"', `replace'
				mi extract 0, clear
			}
			else if "`clear'"!="" & "`using'"=="" {
				*Keep the imputed dataset in memory		
				nois di as txt _n _n "[note: imputed dataset now loaded in memory]"
			}
			else {
				save `"`using'"', `replace'
				nois di as txt _n _n "[note: imputed dataset now loaded in memory]"
			}
		}
	}

	if _rc!=0 {
		local rc `=_rc'	
		*RESTORE ORIGINAL DATASET
		if `rc'!=1000 cap mi extract 0, clear
		foreach i in `depmis' {
			forvalues j=`start'/`end' {
				forvalues w=1/`bw'{
					cap drop `i'`j'_`w'
				}
			}
		}
		error `rc'
	}

	end

