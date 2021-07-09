********************************************************************************
* fpcata: 	command to compute catastrophic          health payments           *
*			from household expenditure surveys                                 *
*                                                                              *
* v 2.1 [12 January 2018]                                                        *
* by Patrick Eozenou and Adam Wagstaff                                         *
********************************************************************************
/// Define program FP-CATA ///

*** Preliminary program to install
cap ssc install conindex
cap ssc install tknz

capture program drop fpcata
matrix drop _all

program fpcata, rclass

version 13.1

syntax 	[, 											///
			TOTEXP(varlist min=1 max=1 numeric) 	///
			HEXP(varlist min=1 max=1 numeric)		///
			THRESH(numlist)							///
			HHSIZE(varlist max=1 numeric)			///
			HHWEIGHT(varlist max=1 numeric)			///
			Quintile								///
			Export									///
		]

			
	* Check conditions
	*assert `totexp' <. & `totexp'>0
	*assert `hexp' <. & `hexp'>=0
	*assert `hhweight' <. & `hhweight'>0
	*assert `thresh' <1 & `thresh'>0
	*assert (`quintile'==1|`quintile'==2|`quintile'==3|`quintile'==4|`quintile'==5) 

* Version locals
local vers "2.1"
local date "January 2018"
********************************************************************************	
	if ("`thresh'" != "") {
	
		tknz "`thresh'", parse(" ")
		local n_tr = `s(items)'
		
			local i = 1
			
			* Result matrix
			matrix RESULTS = J(`n_tr',5,.)
			
			local nrows = `n_tr'*6
			matrix RESULTSq = J(`nrows',5,.)
			
			while `i' <= `n_tr' {
			
				local tr`i' = ``i''
////////////////////////////////////////////////////////////////////////////////
				if ("`quintile'" == "") {
				
					if ("`hhweight'" == "") {
						local unweighted = 1
						local hhweight = 1
						local hhsize = 1
					}
					
					if ("`hhweight'" != "") & ("`hhsize'" == "") {
						noi di as err "Specifying household size [hhsize()] is mandatory with fpcata if you include sampling weights."
						break
						exit 21
					}
					
					if ("`hhsize'" == "") {
						local hhsize = 1
					}
				
					* Temporary/local variables
					tempvar cata rkvar
					qui count
					local dfr = r(N)-1
					local tr`i's = ``i''*100
					local tr "`tr`i's'"					

					* CATA indicators
					qui gen `cata' = cond(`hexp'/`totexp'>`tr`i'',1,0)
									
					* Population mean estimate
					qui mean `cata' [aw=`hhsize'*`hhweight']
					matrix bpop = e(b)
					return scalar cata_pop_`tr' = bpop[1,1]
					
					* Concentration index
					gen `rkvar' = `totexp'/`hhsize'
					qui conindex `cata' [aw=`hhsize'*`hhweight'], bounded limit(0 1) rank(`rkvar')
					local t = r(CI)/r(CIse)
					local p = 2*ttail(`dfr',abs(`t'))
					return scalar CI_`tr' 		= r(CI)
					return scalar CIse_`tr' 	= r(CIse)
					return scalar CIpv_`tr' 	= `p'
					
////////////////////////////////////////////////////////////////////////////////				
					* Display results
					if (`i'==1) {
					
						if ("`unweighted'" == "1") {
						
							noi  di as txt "{hline 66}"
							noi  di as txt "Version:" as res " `vers' (`date')"  as txt _col(66) "{c |}"
							noi  di as txt "{hline 66}"
							noi  di as txt "Note:" as res " The user did not specify sampling weights."  as txt _col(66) "{c |}"
							noi  di as res "Population estimates should be treated as sample proportions." as txt  _col(66) "{c |}"
						
						}
					
						noi  di as txt "{hline 66}"
						noi  di as txt _col(12) " -- INCIDENCE OF CATASTROPHIC PAYMENTS --"  _col(66) "{c |}"
						noi  di as txt "{hline 66}"
						noi  di as txt "Level:" _col(15) "{c |}" _continue
						noi  di as txt "Threshold:" _col(30) "{c |}" _continue
						noi  di as txt "Incidence (%):" _col(50) "{c |}" _continue
						noi  di as txt "CI (p-value):" _col(66) "{c |}"
						noi  di as txt "{hline 66}"
						
						noi  di as res _col(4) "Population" as txt _col(15) "{c |}" _continue 
						noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
						noi  di as res _col(44) %5.2fc return(cata_pop_`tr')*100 as txt _col(50) "{c |}" _continue
						noi  di as res _col(52) %5.2fc return(CI_`tr') as txt " (" as res %3.2fc return(CIpv_`tr') as txt ") " _continue
						noi  di as txt _col(66) "{c |}"
						noi  di as txt "{hline 66}"
						
						* Result matrix
						matrix RESULTS[`i',1] = 1
						matrix RESULTS[`i',2] = `tr`i''
						matrix RESULTS[`i',3] = bpop[1,1]
						matrix RESULTS[`i',4] = r(CI)
						matrix RESULTS[`i',5] = `p'
						
					}
					
					else if `i'>1 {
					
						noi  di as res _col(4) "Population" as txt _col(15) "{c |}" _continue 
						noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
						noi  di as res _col(44) %5.2fc return(cata_pop_`tr')*100 as txt _col(50) "{c |}" _continue
						noi  di as res _col(52) %5.2fc return(CI_`tr') as txt " (" as res %3.2fc return(CIpv_`tr') as txt ") " _continue
						noi  di as txt _col(66) "{c |}"
						noi  di as txt "{hline 66}"
						
						* Result matrix
						matrix RESULTS[`i',1] = 1
						matrix RESULTS[`i',2] = `tr`i''
						matrix RESULTS[`i',3] = bpop[1,1]
						matrix RESULTS[`i',4] = r(CI)
						matrix RESULTS[`i',5] = `p'
					
					}
					
				}
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////			
				if ("`quintile'" != "") {
				
					if ("`hhweight'" == "") {
						local unweighted = 1
						local hhweight = 1
					}
					
					if ("`hhsize'" == "") {
						noi di as err "Specifying household size [hhsize()] is mandatory with fpcata if you call the Quintile option"
						break
						exit 21
					}
					
					* Temporary/local variables
					tempvar cata quint rkvar
					qui count
					local dfr = r(N)-1
					local tr`i's = ``i''*100
					local tr "`tr`i's'"						
			
					* Compute expenditure quintiles
					qui xtile `quint' = `totexp'/`hhsize' [aw=`hhsize'*`hhweight'], nq(5)
					qui tab `quint', generate(`q')
					
					* CATA indicators
					qui gen `cata' = cond(`hexp'/`totexp'>`tr`i'',1,0)
				
					* Population mean estimate
					qui mean `cata' [aw=`hhsize'*`hhweight']
					matrix bpop = e(b)
					return scalar cata_pop_`tr' = bpop[1,1]
					
					* Concentration index
					gen `rkvar' = `totexp'/`hhsize'
					qui conindex `cata' [aw=`hhsize'*`hhweight'], bounded limit(0 1) rank(`rkvar')
					local t = r(CI)/r(CIse)
					local p = 2*ttail(`dfr',abs(`t'))
					return scalar CI_`tr' 		= r(CI)
					return scalar CIse_`tr' 	= r(CIse)
					return scalar CIpv_`tr' 	= `p'	
					
					* Result matrix
					local ii = (6*(`i'-1))+1
					
					matrix RESULTS[`i',1] = 1
					matrix RESULTS[`i',2] = `tr`i''
					matrix RESULTS[`i',3] = bpop[1,1]
					matrix RESULTS[`i',4] = r(CI)
					matrix RESULTS[`i',5] = `p'
					
					matrix RESULTSq[`ii',1] = 1
					matrix RESULTSq[`ii',2] = `tr`i''
					matrix RESULTSq[`ii',3] = bpop[1,1]
					matrix RESULTSq[`ii',4] = r(CI)
					matrix RESULTSq[`ii',5] = `p'					
			
					* Population mean estimate, by quintiles
					local j = 1
					while `j' <= 5 {
						qui mean `cata' [aw=`hhsize'*`hhweight'] if `quint'==`j'
						matrix b_q`j' = e(b)
						return scalar cata_q`j'_`tr' = b_q`j'[1,1]
						
						* Concentration index
						cap gen `rkvar' = `totexp'/`hhsize'
						qui conindex `cata' [aw=`hhsize'*`hhweight']  if `quint'==`j', bounded limit(0 1) rank(`rkvar')
						local t = r(CI)/r(CIse)
						local p = 2*ttail(`dfr',abs(`t'))
						
						* Storing results in r()
						return scalar CI_q`j'_`tr' 		= r(CI)
						return scalar CIse_q`j'_`tr' 	= r(CIse)
						return scalar CIpv_q`j'_`tr' 	= `p'	
						
						* Result matrix
						matrix RESULTSq[`ii'+`j',1] = 1+`j'
						matrix RESULTSq[`ii'+`j',2] = `tr`i''
						matrix RESULTSq[`ii'+`j',3] = b_q`j'[1,1]
						matrix RESULTSq[`ii'+`j',4] = r(CI)
						matrix RESULTSq[`ii'+`j',5] = `p'	
						
					local ++j
					}
////////////////////////////////////////////////////////////////////////////////
				* Display results with quintiles
					if `i'==1 {
				
					if ("`unweighted'" == "1") {
					
						noi  di as txt "{hline 66}"
						noi  di as txt "Version:" as res " `vers' (`date')"  as txt _col(66) "{c |}"
						noi  di as txt "{hline 66}"
						noi  di as txt "Note:" as res " The user did not specify sampling weights."  as txt _col(66) "{c |}"
						noi  di as res "Population estimates should be treated as sample proportions." as txt  _col(66) "{c |}"
					
					}
				
					noi  di as txt "{hline 66}"
					noi  di as txt "Version:" as res " `vers' (`date')"  as txt _col(66) "{c |}"
					noi  di as txt "{hline 66}"
					noi  di as txt _col(12) " -- INCIDENCE OF CATASTROPHIC PAYMENTS --"  _col(66) "{c |}"
					noi  di as txt "{hline 66}"
					noi  di as txt "Level:" _col(15) "{c |}" _continue
					noi  di as txt "Threshold:" _col(30) "{c |}" _continue
					noi  di as txt "Incidence (%):" _col(50) "{c |}" _continue
					noi  di as txt "CI (p-value):" _col(66) "{c |}"
					noi  di as txt "{hline 66}"
					
					noi  di as res _col(4) "Population" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_pop_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_`tr') as txt " (" as res %5.2fc return(CIpv_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"
					
					noi  di as res _col(4) "Quintile 1" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_q1_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_q1_`tr') as txt " (" as res %5.2fc return(CIpv_q1_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"
					
					noi  di as res _col(4) "Quintile 2" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_q2_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_q2_`tr') as txt " (" as res %5.2fc return(CIpv_q2_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"
					
					noi  di as res _col(4) "Quintile 3" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_q3_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_q3_`tr') as txt " (" as res %5.2fc return(CIpv_q3_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"	
					
					noi  di as res _col(4) "Quintile 4" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_q4_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_q4_`tr') as txt " (" as res %5.2fc return(CIpv_q4_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"	
					
					noi  di as res _col(4) "Quintile 5" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_q5_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_q5_`tr') as txt " (" as res %5.2fc return(CIpv_q5_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"				
					
					noi  di as txt "{hline 66}"

				}
				
				else if `i'>1 {
				
					noi  di as res _col(4) "Population" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_pop_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_`tr') as txt " (" as res %5.2fc return(CIpv_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"
					
					noi  di as res _col(4) "Quintile 1" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_q1_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_q1_`tr') as txt " (" as res %5.2fc return(CIpv_q1_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"
					
					noi  di as res _col(4) "Quintile 2" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_q2_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_q2_`tr') as txt " (" as res %5.2fc return(CIpv_q2_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"
					
					noi  di as res _col(4) "Quintile 3" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_q3_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_q3_`tr') as txt " (" as res %5.2fc return(CIpv_q3_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"	
					
					noi  di as res _col(4) "Quintile 4" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_q4_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_q4_`tr') as txt " (" as res %5.2fc return(CIpv_q4_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"	
					
					noi  di as res _col(4) "Quintile 5" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) "`tr`i's'%" as txt _col(30) "{c |}" _continue 
					noi  di as res _col(44) %5.2fc return(cata_q5_`tr')*100 as txt _col(50) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_q5_`tr') as txt " (" as res %5.2fc return(CIpv_q5_`tr') as txt ") " _continue
					noi  di as txt _col(66) "{c |}"				
					
					noi  di as txt "{hline 66}"
				
				}
			
			}
////////////////////////////////////////////////////////////////////////////////
			
			local ++i
			}

						noi  di in smcl "(" as res "All results are accessible by typing{stata return list: {it:{green:-return list-}}}" as txt ")" _c
						noi  di as txt _col(66) "{c |}"
						noi  di as txt "{hline 66}"			
	}
preserve	
	if ("`export'" != "") &  ("`quintile'" == "") {
		clear
		svmat RESULTS
		rename RESULTS1 level
		rename RESULTS2 threshold
		rename RESULTS3 incidence
		rename RESULTS4 CI
		rename RESULTS5 pval
		replace threshold = threshold*100
		replace incidence = incidence*100
		la var level 		"Level"
		la var threshold 	"CATA threshold (%)"
		la var incidence 	"CATA incidence (%)"
		la var CI 			"Concentration index"
		la var pval 		"P-value for CI"
		la def lev 1 "Population" 2 "Q1" 3 "Q2" 4 "Q3" 5 "Q4" 6 "Q5"
		la val level lev 
		save CATAoutput, replace
		export excel using CATAoutput.xls, sheet("CATAraw") firstrow(variables) replace
	}
	
		if ("`export'" != "") &  ("`quintile'" != "") {
		clear
		svmat RESULTSq
		rename RESULTSq1 level
		rename RESULTSq2 threshold
		rename RESULTSq3 incidence
		rename RESULTSq4 CI
		rename RESULTSq5 pval
		replace threshold = threshold*100
		replace incidence = incidence*100
		la var level 		"Level"
		la var threshold 	"CATA threshold (%)"
		la var incidence 	"CATA incidence (%)"
		la var CI 			"Concentration index"
		la var pval 		"P-value for CI"
		la def lev 1 "Population" 2 "Q1" 3 "Q2" 4 "Q3" 5 "Q4" 6 "Q5"
		la val level lev 
		save CATAoutput, replace
		export excel using CATAoutput.xls, sheet("CATAraw") firstrow(variables) replace
	}
restore
********************************************************************************	
end
********************************************************************************
