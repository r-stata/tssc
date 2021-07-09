*! version 1.1  Updated June 2018. Issues with Capital letters in variable names fixed (Thanks to Ranmini Vithanagama). Performance improved. 
program checkrob
	version 9
	// parse before/after colon
	_on_colon_parse `0'
	local command `"`s(after)'"'
	local 0 `"`s(before)'"'


	// get number of k_var and x_var
	gettoken kvar 0 : 0
	gettoken xvar 0 : 0

	local fil "result.txt"
	local quietly "quietly"

	local no_e=0
	local i=1
	
	while (wordcount("`0'")>2 | ( wordcount("`0'")==2 & ///
			cond(strpos("`0'",".txt"),1,0)*cond(strpos("`0'","noisily"),1,0)==0 ) | ( wordcount("`0'")==1 & ///
			cond(strpos("`0'",".txt"),1,0)+cond(strpos("`0'","noisily"),1,0)==0 ) ) {
		local ++no_e
		gettoken e_`i' 0 : 0
		local e_option = "`e_option' " + "`e_`i''"
		local ++i
	}

	
	if trim("`0'")=="" {
		local fil "result.txt"
		local quietly "quietly"
	}

	while (trim("`0'")~="") {
		gettoken tmp 0 : 0
		if trim("`tmp'")=="noisily" {
			local quietly "noisily"
		}
		if strpos(trim("`tmp'"),".txt")>0 {
			local fil "`tmp'"
		}
	}	

	// check if file name already exists and - if so - abort
	cap confirm new file `fil'
	if _rc==602 {
		noi disp _n
		noi disp in red "{p 6 6 2}Filename `fil' already exists - specify another name"
		exit
	}
	
	// check for comma and options
	if strpos("`command'",",")~=0 {
		local c_opt = substr("`command'",strpos("`command'",","),.)
		local command = substr("`command'",1,strpos("`command'",",")-1)
	}	
	
	// use gettoken to split up the expression
	gettoken com command : command
	gettoken dep_var command : command

	forvalues i=1/`kvar' {
		gettoken tmp command : command
		local kvars = "`kvars' " + "`tmp'"		
	}
	
	forvalues i=1/`xvar' {
		gettoken tmp command : command
		local xvars = "`xvars' " + "`tmp'"		
	}

	local opt `command'

		// display commands on screen
		disp _n
		disp in green "{p 6 6}See the help file for explanations.{p_end}"
		disp in green "{p 6 6}Number of core variables: `kvar'; number of testing variables: `xvar' (=`=2^`xvar'' regressions){p_end}"
		disp in green "{p 6 6}Output file: `fil'; Table file: table_`fil'{p_end}" _n
		disp in green "{p 6 6}Method: `com'{p_end}"
		disp in green "{p 6 6}Dependent var: `dep_var'{p_end}"
		disp in green "{p 6 6}Core variables: `kvars'{p_end}"
		disp in green "{p 6 6}Testing variables: `xvars'{p_end}"
		disp in green "{p 6 6}Options/additionals added to all regressions: `opt' `c_opt'{p_end}"
		disp in green "{p 6 6}Additional output options: `e_option'{p_end}" _n
		
		

		// write heading to file
		cap	file open result using `fil', write replace
		file write result "no"
		forvalues i=1/`kvar' {
			file write result ",b_" "`=word("`kvars'",`i')'" 
			file write result ",se_" "`=word("`kvars'",`i')'"
		}
		forvalues i=1/`xvar' {
			file write result ",b_" "`=word("`xvars'",`i')'" 
			file write result ",se_" "`=word("`xvars'",`i')'" 
		}
		forvalues i=1/`no_e' {
			file write result ",`e_`i''"
		}
		
		file write result _n
		
		file close result

	`quietly' {
	
		// control progress indicator
		local progress=1
		noi disp in green "{p 6 6 2}Reg. no.: 1{p_end}"

		tempname tmp1 tmp2
		
		// make regressions
		local comb = 2^`xvar'
	
			forvalues i=1/`comb' {
			
				local sekv = " "
				local regstr = " "
				
				forvalues j=0/`=`xvar'-1' {
					local sekv = "`sekv' " + string(mod(int( (`i'-1) / (2^`j') ),2))
				}
				disp _n
				disp in green "`sekv'"
	
				forvalues k=1/`xvar' {
					local tmp=word("`sekv'",`k')
					if `tmp'==1 {
						local regstr = "`regstr' " + word("`xvars'",`k')
					}
				}
	
			`com' `dep_var' `kvars' `regstr' `opt' `c_opt'
	
				// write results to file 
				cap	file open result using `fil', write append
				file write result "`i'"
				forvalues j=1/`kvar' {
					capture {
						scalar `tmp1' = _b[`=word("`kvars'",`j')']
						scalar `tmp2' = _se[`=word("`kvars'",`j')']
						// check if coefficient are exactly zero (then they have been dropped)
						if (_b[`=word("`kvars'",`j')']==0 & _se[`=word("`kvars'",`j')']==0) {
							scalar `tmp1' = .
							scalar `tmp2' = .
						}
					}
					if _rc~=0 {
						scalar `tmp1' = .
						scalar `tmp2' = .
					}
	
					file write result ", `=`tmp1''"
					file write result ", `=`tmp2''"
				}
	
				forvalues j=1/`xvar' {
					capture {
						scalar `tmp1' = _b[`=word("`xvars'",`j')']
						scalar `tmp2' = _se[`=word("`xvars'",`j')']
						// check if coefficient is exactly zero (then it has been dropped)
						if (_b[`=word("`xvars'",`j')']==0 & _se[`=word("`xvars'",`j')']==0) {
							scalar `tmp1' = .
							scalar `tmp2' = .
						}
					}
	
					// check if coefficient are exactly zero (then they have been dropped)
					if _rc~=0 {
						scalar `tmp1' = .
						scalar `tmp2' = .
					}
	
					file write result ", `=`tmp1''"
					file write result ", `=`tmp2''"
				}

				forvalues j=1/`no_e' {
					file write result ", ``e_`j'''"
				}
				
				file write result _n
				file close result

				// write progress output
				if mod(`i',`=`progress'*50')==0 {
					noi disp in green "{p 6 6 2}Reg. nb.: `i'{p_end}"
					local ++progress
				}
				
			// end of regressions
			}
			
		}

	preserve

		// read file
		quietly {
			clear
			insheet using `fil'
	
			file open restab using table_`fil', write replace
			file write restab "Core var,Max,Min,Mean,AvgSTD,PercSigni,Perc+,Perc-,AvgT,Obs"
				forvalues j=1/`no_e' {
					file write restab ", `e_`j''"
				}
			file write restab _n

			tempvar dum tdum pdum mdum tvalue
			gen `dum'=0
			gen `tdum'=0
			gen `pdum'=0
			gen `mdum'=0
			gen `tvalue'=0
			foreach v of local kvars {

				sum b_`=strlower("`v'")', meanonly
				file write restab "`v'" "," "`r(max)'" "," "`r(min)'" "," "`r(mean)'" ","
				sum se_`=strlower("`v'")', meanonly
				file write restab "`r(mean)'" ","
				replace `tdum'=(abs((b_`=strlower("`v'")')/(se_`=strlower("`v'")'))>1.96 & b_`=strlower("`v'")'~=.)
				replace `tdum'=. if b_`=strlower("`v'")'==.
				sum `tdum', meanonly
				file write restab "`r(mean)'" ","
				replace `pdum'=(b_`=strlower("`v'")'>0)
				replace `pdum'=. if b_`=strlower("`v'")'==.
				sum `pdum', meanonly
				file write restab "`r(mean)'" ","
				replace `mdum'=(b_`=strlower("`v'")'<0)
				replace `mdum'=. if b_`=strlower("`v'")'==.
				sum `mdum', meanonly
				file write restab "`r(mean)'" ","
				replace `tvalue'=abs(b_`=strlower("`v'")'/se_`=strlower("`v'")')
				replace `tvalue'=. if b_`=strlower("`v'")'==.
				sum `tvalue', meanonly
				file write restab "`r(mean)'" "," "`r(N)'"
				forvalues j=1/`no_e' {
					local q=strpos("`e_`j''","(")
					local p=strpos("`e_`j''",")")
					local tmp_str = "e" + lower(substr("`e_`j''",`=`q'+1',`=`p'-`q'-1'))
					replace `dum'=`tmp_str' if b_`=strlower("`v'")'~=.
					replace `dum'=. if b_`=strlower("`v'")'==.
					sum `dum', meanonly
					file write restab ", `r(mean)'"
				}

				file write restab _n
			}
	
			file write restab "T-var,Max,Min,Mean,AvgSTD,PercSigni,Perc+,Perc-,AvgT,Obs" _n
			
			foreach v of local xvars {
				sum b_`=strlower("`v'")', meanonly
				file write restab "`v'" "," "`r(max)'" "," "`r(min)'" "," "`r(mean)'" ","
				sum se_`=strlower("`v'")', meanonly
				file write restab "`r(mean)'" ","
				replace `tdum'=(abs((b_`=strlower("`v'")')/(se_`=strlower("`v'")'))>1.96 & b_`=strlower("`v'")'~=.)
				replace `tdum'=. if b_`=strlower("`v'")'==.
				sum `tdum', meanonly
				file write restab "`r(mean)'" ","
				replace `pdum'=(b_`=strlower("`v'")'>0 & b_`=strlower("`v'")'~=. )
				replace `pdum'=. if b_`=strlower("`v'")'==.
				sum `pdum', meanonly
				file write restab "`r(mean)'" ","
				replace `mdum'=(b_`=strlower("`v'")'<0 & b_`=strlower("`v'")'~=.)
				replace `mdum'=. if b_`=strlower("`v'")'==.
				sum `mdum', meanonly
				file write restab "`r(mean)'" ","
				replace `tvalue'=abs((b_`=strlower("`v'")')/(se_`=strlower("`v'")'))
				replace `tvalue'=. if b_`=strlower("`v'")'==.
				sum `tvalue', meanonly
				file write restab "`r(mean)'" "," "`r(N)'"

				forvalues j=1/`no_e' {
					local q=strpos("`e_`j''","(")
					local p=strpos("`e_`j''",")")
					local tmp_str = "e" + lower(substr("`e_`j''",`=`q'+1',`=`p'-`q'-1'))
					replace `dum'=`tmp_str' if b_`=strlower("`v'")'~=.
					replace `dum'=. if b_`=strlower("`v'")'==.
					sum `dum', meanonly
					file write restab ", `r(mean)'"
				}

				file write restab _n

			}

			file close restab
		}

	restore		
	noi disp in green "{p 6 6 2}Checkrob completed"

end
		
