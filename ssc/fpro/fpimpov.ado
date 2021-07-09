********************************************************************************
* fpimpov: 	command to compute impoverishing health payments                   *
*			from household expenditure surveys                                 *
*                                                                              *
* v 2.1 [12 January 2018]                                                        *
* by Patrick Eozenou and Adam Wagstaff                                         *
********************************************************************************
/// Define program FP-IMPOV ///

*** Preliminary program to install
cap ssc install conindex
cap ssc install tknz

capture program drop fpimpov
matrix drop _all

program fpimpov, rclass

version 13.1

syntax 	[, 											///
			TOTEXP(varlist min=1 max=1 numeric) 	///
			HEXP(varlist min=1 max=1 numeric)		///
			PLINE(varlist min=1 numeric)			///
			HHSIZE(varlist max=1 numeric)			///
			HHWEIGHT(varlist max=1 numeric)			///
			Quintile								///
			Export									///
		]

			
	* Check conditions
	*assert `totexp' <. & `totexp'>0
	*assert `hexp' <. & `hexp'>=0
	*assert `hhweight' <. & `hhweight'>0
	*assert `pline' <1 & `pline'>0
	*assert (`quintile'==1|`quintile'==2|`quintile'==3|`quintile'==4|`quintile'==5) 
	
	local f = 1
	
* Version locals
local vers "2.1"
local date "January 2018"	
********************************************************************************	
	if ("`pline'" != "") {
	
		tknz "`pline'", parse(" ")
		local n_pl = `s(items)'
	
		local i = 1
		
		* Result matrix
		matrix RESULTS = J(`n_pl',5,.)
			
		local nrows = `n_pl'*6
		matrix RESULTSq = J(`nrows',5,.)		
		
		while `i' <= `n_pl' {
			
			local pl`i' = ``i''
////////////////////////////////////////////////////////////////////////////////
			if ("`quintile'" == "") {
			
				if ("`hhweight'" == "") {
					local unweighted = 1
					local hhweight = 1
				}
				
				if ("`hhsize'" == "") {
					noi di as err "Specifying household size [hhsize()] is mandatory with fpimpov"
					break
					exit 21
				}
			
				* Temporary/local variables
				tempvar P0 P0net P1 P1net impov rkvar
				qui count
				local dfr = r(N)-1					
					
				* IMPOV indicators
				gen `P0' 	= cond((`totexp'/`hhsize')<`pl`i'',1,0)
				gen `P0net' = cond((`totexp'/`hhsize')-(`hexp'/`hhsize')<`pl`i'',1,0)
				gen `impov' = (`P0'==0 & `P0net'==1)
					
				gen `P1' = cond((`totexp'/`hhsize')<`pl`i'',(`pl`i''-(`totexp'/`hhsize'))/`pl`i'',0)
				gen `P1net' = cond(((`totexp'/`hhsize')-(`hexp'/`hhsize'))<`pl`i'',(`pl`i''-((`totexp'/`hhsize')-(`hexp'/`hhsize')))/`pl`i'',0)	
				
				* Population mean estimate
				return scalar PL`i' = `pl`i''				
				qui mean `impov' [aw=`hhsize'*`hhweight']
				matrix bpop = e(b)
				return scalar impov_pop_PL`i' = bpop[1,1]				
				
				* Concentration index
				gen `rkvar' = `totexp'/`hhsize'
				qui conindex `impov' [aw=`hhsize'*`hhweight'], bounded limit(0 1) rank(`rkvar')
				local t = r(CI)/r(CIse)
				local p = 2*ttail(`dfr',abs(`t'))				
				return scalar CI_PL`i' 		= r(CI)
				return scalar CIse_PL`i' 	= r(CIse)
				return scalar CIpv_PL`i' 	= `p'	

				
				* Display results
				if (`i'==1) {
				
					if ("`unweighted'" == "1") {
					
						noi  di as txt "{hline 70}"
						noi  di as txt "Version:" as res " `vers' (`date')"  as txt _col(70) "{c |}"
						noi  di as txt "{hline 70}"
						noi  di as txt "Note:" as res " The user did not specify sampling weights."  as txt _col(70) "{c |}"
						noi  di as res "Population estimates should be treated as sample proportions." as txt  _col(70) "{c |}"
					
					}
							
					noi  di as txt "{hline 70}"
					noi  di as txt _col(12) " -- INCIDENCE OF IMPOVERISHING PAYMENTS --"  _col(70) "{c |}"
					noi  di as txt "{hline 70}"
					noi  di as txt "Level:" _col(15) "{c |}" _continue
					noi  di as txt "Pov. line (LCU/cap/d):" _col(35) "{c |}" _continue
					noi  di as txt "Incidence (%):" _col(55) "{c |}" _continue
					noi  di as txt "CI (p-value):" _col(70) "{c |}"
					noi  di as txt "{hline 70}"
					
					noi  di as res _col(4) "Population" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
					noi  di as res _col(50) %5.2fc return(impov_pop_PL`i')*100 as txt _col(55) "{c |}" _continue
					noi  di as res _col(52) %5.1fc return(CI_PL`i') as txt " (" as res %3.2fc return(CIpv_PL`i') as txt ") " _continue
					noi  di as txt _col(70) "{c |}"
					noi  di as txt "{hline 70}"
					
					* Result matrix
					matrix RESULTS[`i',1] = 1
					matrix RESULTS[`i',2] = `pl`i''
					matrix RESULTS[`i',3] = bpop[1,1]
					matrix RESULTS[`i',4] = r(CI)
					matrix RESULTS[`i',5] = `p'					
					
				}
				
				else if `i'>1 {
				
					noi  di as res _col(4) "Population" as txt _col(15) "{c |}" _continue 
					noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
					noi  di as res _col(50) %5.2fc return(impov_pop_PL`i')*100 as txt _col(55) "{c |}" _continue
					noi  di as res _col(52) %5.2fc return(CI_PL`i') as txt " (" as res %3.2fc return(CIpv_PL`i') as txt ") " _continue
					noi  di as txt _col(70) "{c |}"
					noi  di as txt "{hline 70}"
					
					* Result matrix
					matrix RESULTS[`i',1] = 1
					matrix RESULTS[`i',2] = `pl`i''
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
					noi di as err "Specifying household size [hhsize()] is mandatory with fpimpov"
					break
					exit 21
				}
				
				* Temporary/local variables
				tempvar P0 P0net P1 P1net impov quint q1 q2 q3 q4 q5 rkvar
				qui count
				local dfr = r(N)-1	

				* Compute expenditure quintiles
				qui xtile `quint' = `totexp'/`hhsize' [aw=`hhsize'*`hhweight'], nq(5)
				qui tab `quint', generate(`q')
				
				* IMPOV indicators
				gen `P0' 	= cond((`totexp'/`hhsize')<`pl`i'',1,0)
				gen `P0net' = cond((`totexp'/`hhsize')-(`hexp'/`hhsize')<`pl`i'',1,0)
				gen `impov' = (`P0'==0 & `P0net'==1)
				
				gen `P1' = cond((`totexp'/`hhsize')<`pl`i'',(`pl`i''-(`totexp'/`hhsize'))/`pl`i'',0)
				gen `P1net' = cond(((`totexp'/`hhsize')-(`hexp'/`hhsize'))<`pl`i'',(`pl`i''-((`totexp'/`hhsize')-(`hexp'/`hhsize')))/`pl`i'',0)	
				
				* Population mean estimate
				return scalar PL`i' = `pl`i''				
				qui mean `impov' [aw=`hhsize'*`hhweight']
				matrix bpop = e(b)
				return scalar impov_pop_PL`i' = bpop[1,1]	
				
				* Concentration index
				gen `rkvar' = `totexp'/`hhsize'
				qui cap conindex `impov' [aw=`hhsize'*`hhweight'], bounded limit(0 1) rank(`rkvar')
				local t = r(CI)/r(CIse)
				local p = 2*ttail(`dfr',abs(`t'))				
				return scalar CI_PL`i' 		= r(CI)
				return scalar CIse_PL`i' 	= r(CIse)
				return scalar CIpv_PL`i' 	= `p'	
				
				* Result matrix
				local ii = (6*(`i'-1))+1
					
				matrix RESULTS[`i',1] = 1
				matrix RESULTS[`i',2] = `pl`i''
				matrix RESULTS[`i',3] = bpop[1,1]
				matrix RESULTS[`i',4] = r(CI)
				matrix RESULTS[`i',5] = `p'
					
				matrix RESULTSq[`ii',1] = 1
				matrix RESULTSq[`ii',2] = `pl`i''
				matrix RESULTSq[`ii',3] = bpop[1,1]
				matrix RESULTSq[`ii',4] = r(CI)
				matrix RESULTSq[`ii',5] = `p'
				
				
				* Population mean estimate, by quintiles
				local j = 1
				while `j' <= 5 {
					qui mean `impov' [aw=`hhsize'*`hhweight'] if `quint'==`j'
					matrix b_q`j' = e(b)
					return scalar impov_q`j'_PL`i' = b_q`j'[1,1]	
					
					* Concentration index
					cap gen `rkvar' = `totexp'/`hhsize'
					qui cap conindex `impov' [aw=`hhsize'*`hhweight']  if `quint'==`j', bounded limit(0 1) rank(`rkvar')
					local t = r(CI)/r(CIse)
					local p = 2*ttail(`dfr',abs(`t'))
					
					* Storing results in r()
					return scalar CI_q`j'_PL`i' 	= r(CI)
					return scalar CIse_q`j'_PL`i' 	= r(CIse)
					return scalar CIpv_q`j'_PL`i' 	= `p'	
					
					* Result matrix
					matrix RESULTSq[`ii'+`j',1] = 1+`j'
					matrix RESULTSq[`ii'+`j',2] = `pl`i''
					matrix RESULTSq[`ii'+`j',3] = b_q`j'[1,1]
					matrix RESULTSq[`ii'+`j',4] = r(CI)
					matrix RESULTSq[`ii'+`j',5] = `p'
					
					
				local ++j
				}
				

////////////////////////////////////////////////////////////////////////////////
				* Display results with quintiles
					if `i'==1 {
					
						if ("`unweighted'" == "1") {
						
							noi  di as txt "{hline 70}"
							noi  di as txt "Version:" as res " `vers' (`date')"  as txt _col(70) "{c |}"						
							noi  di as txt "{hline 70}"
							noi  di as txt "Note:" as res " The user did not specify sampling weights."  as txt _col(70) "{c |}"
							noi  di as res "Population estimates should be treated as sample proportions." as txt  _col(70) "{c |}"
						
						}
					
							noi  di as txt "{hline 70}"
							noi  di as txt _col(12) " -- INCIDENCE OF IMPOVERISHING PAYMENTS --"  _col(70) "{c |}"
							noi  di as txt "{hline 70}"
							noi  di as txt "Level:" _col(15) "{c |}" _continue
							noi  di as txt "Pov. line (LCU/cap/d):" _col(35) "{c |}" _continue
							noi  di as txt "Incidence (%):" _col(55) "{c |}" _continue
							noi  di as txt "CI (p-value):" _col(70) "{c |}"
							noi  di as txt "{hline 70}"
							
							noi  di as res _col(4) "Population" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_pop_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.1fc return(CI_PL`i') as txt " (" as res %5.2fc return(CIpv_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"
							
							noi  di as res _col(4) "Quintile 1" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_q1_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.2fc return(CI_q1_PL`i') as txt " (" as res %5.2fc return(CIpv_q1_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"
							
							noi  di as res _col(4) "Quintile 2" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_q2_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.2fc return(CI_q2_PL`i') as txt " (" as res %5.2fc return(CIpv_q2_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"
							
							noi  di as res _col(4) "Quintile 3" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_q3_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.2fc return(CI_q3_PL`i') as txt " (" as res %5.2fc return(CIpv_q3_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"
							
							noi  di as res _col(4) "Quintile 4" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_q4_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.2fc return(CI_q4_PL`i') as txt " (" as res %5.2fc return(CIpv_q4_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"
							
							noi  di as res _col(4) "Quintile 5" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_q5_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.2fc return(CI_q5_PL`i') as txt " (" as res %5.2fc return(CIpv_q5_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"		
							
							noi  di as txt "{hline 70}"
					}
										
					else if `i'>1 {
					
							noi  di as res _col(4) "Population" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_pop_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.1fc return(CI_PL`i') as txt " (" as res %5.2fc return(CIpv_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"
							
							noi  di as res _col(4) "Quintile 1" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_q1_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.2fc return(CI_q1_PL`i') as txt " (" as res %5.2fc return(CIpv_q1_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"
							
							noi  di as res _col(4) "Quintile 2" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_q2_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.2fc return(CI_q2_PL`i') as txt " (" as res %5.2fc return(CIpv_q2_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"
							
							noi  di as res _col(4) "Quintile 3" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_q3_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.2fc return(CI_q3_PL`i') as txt " (" as res %5.2fc return(CIpv_q3_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"
							
							noi  di as res _col(4) "Quintile 4" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_q4_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.2fc return(CI_q4_PL`i') as txt " (" as res %5.2fc return(CIpv_q4_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"
							
							noi  di as res _col(4) "Quintile 5" as txt _col(15) "{c |}" _continue 
							noi  di as res _col(26) %12.1fc return(PL`i') as txt _col(38) "{c |}" _continue 
							noi  di as res _col(50) %5.2fc return(impov_q5_PL`i')*100 as txt _col(55) "{c |}" _continue
							noi  di as res _col(52) %5.2fc return(CI_q5_PL`i') as txt " (" as res %5.2fc return(CIpv_q5_PL`i') as txt ") " _continue
							noi  di as txt _col(70) "{c |}"					
							
							noi  di as txt "{hline 70}"
							
						}	
				
////////////////////////////////////////////////////////////////////////////////							
			}
////////////////////////////////////////////////////////////////////////////////				
		local ++i					
		}
		
						noi  di in smcl "(" as res "All results are accessible by typing{stata return list: {it:{green:-return list-}}}" as txt ")" _c
						noi  di as txt _col(70) "{c |}"
						noi  di as txt "{hline 70}"			
////////////////////////////////////////////////////////////////////////////////	
	}	

preserve	
	if ("`export'" != "") &  ("`quintile'" == "") {
		clear
		svmat RESULTS
		rename RESULTS1 level
		rename RESULTS2 pline
		rename RESULTS3 incidence
		rename RESULTS4 CI
		rename RESULTS5 pval
		replace incidence = incidence*100
		la var level 		"Level"
		la var pline		"IMPOV poverty line (LCU/pc/d)"
		la var incidence 	"IMPOV incidence (%)"
		la var CI 			"Concentration index"
		la var pval 		"P-value for CI"
		la def lev 1 "Population" 2 "Q1" 3 "Q2" 4 "Q3" 5 "Q4" 6 "Q5"
		la val level lev 
		save CATAoutput, replace
		export excel using CATAoutput.xls, sheet("IMPOVraw") firstrow(variables) replace
	}
	
		if ("`export'" != "") &  ("`quintile'" != "") {
		clear
		svmat RESULTSq
		rename RESULTSq1 level
		rename RESULTSq2 pline
		rename RESULTSq3 incidence
		rename RESULTSq4 CI
		rename RESULTSq5 pval
		replace incidence = incidence*100
		la var level 		"Level"
		la var pline		"IMPOV poverty line (LCU/pc/d)"
		la var incidence 	"IMPOV incidence (%)"
		la var CI 			"Concentration index"
		la var pval 		"P-value for CI"
		la def lev 1 "Population" 2 "Q1" 3 "Q2" 4 "Q3" 5 "Q4" 6 "Q5"
		la val level lev 
		save IMPOVoutput, replace
		export excel using IMPOVoutput.xls, sheet("IMPOVraw") firstrow(variables) replace
	}
restore	

********************************************************************************	
end
********************************************************************************
