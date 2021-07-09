quietly{		
		tempname pre_
		
		foreach v of varlist *{
			rename `v' `pre_'`v'
		}
 
		foreach v in  STDP RMSE STDFtemp p STDF set original_event_date returns dif marketreturns predicted_return special1 special2 cum_periods est_window MAreturns cum_returns cum_marketreturns cum_factor1 cum_factor2 cum_factor3 cum_factor4 cum_factor5 cum_factor6 cum_factor7 cum_factor8 cum_factor9 cum_factor10 cum_factor11 cum_factor12 cum_factor13 cum_factor14 cum_factor15 factor1 factor2 factor3 factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11 factor12 factor13 factor14 factor15{
			if "${`v'}" != ""{
				local `v' = "`pre_'" + "${`v'}"
			}
			display "``v''"
		}
		
		
		foreach v in j archoption garchoption architerate model garch {
			if "${`v'}" != ""{
				local `v' =  "${`v'}"
			}
			display "``v''"
		}
		
		gen original_event_date = `original_event_date'
		
		tempname O
		tempvar zero
		tempname j
		tempname z 
		tempname U
		tempvar t_arch
		tempvar cum_intercept
		tempvar ____id_p
		
		egen `____id_p'  = group(`special1' `set') 

		summarize `____id_p' 
		
		scalar `O' = r(max) 
		
		sort `____id_p'  `special2', stable

		gen `STDF' = .
		
		gen `cum_intercept' = 1/sqrt(`cum_periods')
		
		
		
		if "`model'" == "FM" & "`garch'" == "garch"{
			tempfile __beforearch
		}
		
		if "`model'" != "BHAR" & "`model'" != "BHAR_raw" {
			gen `zero' = 0
			
			if "`model'" == "MA" {
				replace `cum_returns' = `cum_returns' - `cum_marketreturns'
				replace `returns' = `returns' - `marketreturns'
			}
		
			scalar `j' = 1
			while `j' <= `O' { 
				ereturn clear

				if "`model'" == "RAW" {
					capture: reg `cum_returns' `zero' if `____id_p'  == `j' & `est_window' == 1, nocons
				}						
				if "`model'" == "COMEAN" {
					capture: reg `cum_returns' `cum_intercept' `zero'  if `____id_p'  == `j' & `est_window' == 1, nocons
				}
				if "`model'" == "MA" {
					capture: reg `cumreturns' `zero'  if `____id_p'  == `j' & `est_window' == 1, nocons
				}
				if "`model'" == "FM" & "`garch'" != "garch"{	
					capture: reg `cum_returns' `cum_intercept' `cum_marketreturns' `cum_factor1' `cum_factor2' `cum_factor3' `cum_factor4' `cum_factor5' `cum_factor6' `cum_factor7' `cum_factor8' `cum_factor9' `cum_factor10' `cum_factor11' `cum_factor12' `cum_factor13' `cum_factor14' `cum_factor15' if `____id_p'  == `j' & `est_window' == 1, nocons
				
					if _rc == 0{
						capture: replace _BETA = _b[`cum_marketreturns'] if `____id_p' == `j'
					}
				
				}
				
				if "`model'" == "FM" & "`garch'" == "garch"{
					save `__beforearch', replace
						keep if `____id_p'  == `j' 
						sort `special2'
						gen `t_arch' = _n
						tsset `t_arch'
						set seed 1
						capture: arch `cum_returns' `cum_intercept' `cum_marketreturns' `cum_factor1' `cum_factor2' `cum_factor3' `cum_factor4' `cum_factor5' `cum_factor6' `cum_factor7' `cum_factor8' `cum_factor9' `cum_factor10' `cum_factor11' `cum_factor12' `cum_factor13' `cum_factor14' `cum_factor15'  if `est_window' == 1, nocons arch(`archoption') garch(`garchoption') iterate(`architerate')
				}
				
				foreach v in returns marketreturns factor1 factor2 factor3 factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11 factor12 factor13 factor14 factor15{
					capture: gen save`cum_`v'' = `cum_`v''
					capture: replace `cum_`v'' = `cum_`v'' * sqrt(`cum_periods') 																	
				}
				
				gen save`cum_intercept' = `cum_intercept'
																								
				replace `cum_intercept' = `cum_intercept' * sqrt(`cum_periods') 
				
				tsset `____id_p'  `special2'
				
				capture: predict `p' if `____id_p'  ==`j'
				capture: replace `predicted_return' = `p' if `____id_p' ==`j' & e(N) 

				if "`garch'" != "garch"{
					capture: predict `STDFtemp' if `____id_p' ==`j', stdf 
					capture: replace `STDF'= `STDFtemp' if `____id_p' ==`j'  & e(N) 
					capture: drop `STDFtemp'
					
					foreach v in returns marketreturns factor1 factor2 factor3 factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11 factor12 factor13 factor14 factor15{
						capture: replace `cum_`v'' = save`cum_`v'' 
					}																						
					capture: replace `cum_intercept' = save`cum_intercept'
					drop save*
				}
				else{
					capture: predict `STDP' if `____id_p' ==`j', stdp
					local df_m = e(df_m)
					capture: rmse `p' `cum_returns', df_m(`df_m')
					capture: gen `RMSE' = r(`cum_returns') 
					capture: destring `RMSE', replace force
					capture: gen `STDFtemp' = sqrt(`STDP'^2+`RMSE'^2) if `____id_p' ==`j'
					capture: replace `STDF'= `STDFtemp' if `____id_p' ==`j'  & e(N) 
					capture: drop `STDFtemp' `RMSE' `STDP'
					capture: drop `p'
					local `z' = `j'
					tempfile __file_``z''
					capture: save `__file_``z''', replace empty
					use `__beforearch', clear
							
				}
				
				capture: drop `p'
				noisily: display `j' " out of " `O' " events completed."
				scalar `j' = `j' + 1
			}
			
			if "`garch'" == "garch"{
				clear
				local `U' = `O'
				forvalues i = 1/``U'' {
					capture: append using `__file_`i''
				}
				forvalues i = 1/``U'' {
					capture: erase `__file_`i''
				}
			}
		}

		if "`model'" == "BHAR" {
			replace `predicted_return' = `marketreturns'
		}

		if "`model'" == "BHAR_raw"{
			replace `predicted_return' = 0
		}

		gen AR = `returns' - `predicted_return' 
	
		drop `____id_p' 
		
		capture: drop `t_arch'
		capture: drop `zero'
		capture: drop `cum_intercept'
				
		rename `pre_'* *
}
		
