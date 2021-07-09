cap program drop heabs
program heabs, rclass
	version 8.2
		syntax varlist(min=2 max=4 numeric) ,		///
		INTervention(varname numeric)				/// 
		RESponse(string) 							/// 
		[w2p(real 0) ] 

		
		
local vars : word count `varlist'
if `vars' == 3 {
di in red "Error: Must input 2 or 4 variables, not 3."
exit
}		
		
tokenize `varlist'		


 qui count if `intervention' == 0
local zeroes = r(N)
qui count if `intervention' == 1
local ones = r(N)
if `ones' + `zeroes' != _N {
di in red "Error: intervention var contains missing data, or values that are not 0 or 1."
exit
}
 
 
 if "`response'" != "detr" & "`response'" != "bene" {
	di in red "Error: 'response' must be either 'bene' or 'detr'"
	exit
}
 if `w2p' < 0 {
	di in red "Error: Willing-to-Pay level must not be negative."
	exit
}

	
if `vars'==2 {
qui count if `intervention'==0
 local numberA = r(N)
qui count if `intervention'==1
 local numberB = r(N)		

       foreach var of varlist `1' `2' {
 
 qui count if missing(`var')
	local missing`var' = r(N)
	if `missing`var'' != 0 {
		di in red "Error: Missing Data detected in `var'"
		exit 456
	} 
	}
	
qui summarize `1' if `intervention'==0
local meanCost1A = r(mean)
local sdCost1A = r(sd)
local seCost1A = `sdCost1A'/sqrt(`numberA')
qui summarize `1' if `intervention'==1
local meanCost1B = r(mean)
local sdCost1B = r(sd)
local seCost1B = `sdCost1B'/sqrt(`numberB')

qui summarize `2' if `intervention'==0
local meanEff1A = r(mean)
local sdEff1A = r(sd)
local seEff1A = `sdEff1A'/sqrt(`numberA')
qui summarize `2' if `intervention'==1
local meanEff1B = r(mean)
local sdEff1B = r(sd)
local seEff1B = `sdEff1B'/sqrt(`numberB')

qui correlate `1' `2' if `intervention'==0
local corr1A = r(rho)
qui correlate `1' `2' if `intervention'==1
local corr1B = r(rho)


local nbse1 = sqrt((`w2p'^2)*(`seEff1A'^2 + `seEff1B'^2) + (`seCost1A'^2 + `seCost1B'^2) + ///
							2*`w2p'*`corr1A'* `seCost1A'*`seEff1A' + ///
							2*`w2p'*`corr1B'* `seCost1B'*`seEff1B') 

							
	 local incCost1 = `meanCost1B' - `meanCost1A'
	 
if      "`response'" == "detr"{	 
	 local incEffect1 = `meanEff1A' - `meanEff1B' 
	}
 if "`response'" == "bene"{
	 local incEffect1 = `meanEff1B' - `meanEff1A' 
 }
	local icer1 = `incCost1'/`incEffect1'
	local NB1 = `w2p' * `incEffect1' - `incCost1'
	local NBupCI1 = `NB1' + 1.96*`nbse1'
	local NBloCI1 = `NB1' - 1.96*`nbse1'
	
	return scalar upCINB1 = `NBupCI1'
	return scalar loCINB1 = `NBloCI1'
	return scalar seNB1 = `nbse1'
	return scalar NB1 = `NB1'
	return scalar ICER1 = `icer1'				//				ICER	
	return scalar outcome1 = `incEffect1'
	return scalar cost1 = `incCost1'
	
	local icer1a = cond(`icer1'<0,0, `icer1')
	di ""
		di "{hline 9}{c TT}{hline 12}{c TT}{hline 12}{c TT}{hline 12}{c TT}{hline 12}{c TT}{hline 12}{c TRC}"
	di "" "{col 10}{c |} Cost"  "{col 23}{c |}  Effect" "{col 36}{c |} Inc Cost" "{col 49}{c |} Inc Effect" "{col 62}{c |} ICER" "{col 75}{c |}"
	di "{hline 9}{c +}{hline 12}{c +}{hline 12}{c +}{hline 12}{c +}{hline 12}{c +}{hline 12}{c RT}"
	di "  Int0" "{col 10}{c |}" %10.3f `meanCost1A' "{col 23}{c |}" %10.3f `meanEff1A' "{col 36}{c |}"  /// 
			"{col 49}{c |}" "{col 62}{c |}" "{col 75}{c |}"
	di  "{col 10}{c |}"  "{col 23}{c |}"  "{col 36}{c |}" %10.3f `incCost1' "{col 49}{c |}" %10.3f `incEffect1' "{col 62}{c |}" %10.3f `icer1a' "{col 75}{c |}"			
	di "  Int1" "{col 10}{c |}" %10.3f `meanCost1B' "{col 23}{c |}" %10.3f `meanEff1B' "{col 36}{c |}"   /// 
			"{col 49}{c |}" "{col 62}{c |}" "{col 75}{c |}"
	di "{hline 9}{c BT}{hline 12}{c BT}{hline 12}{c BT}{hline 12}{c BT}{hline 12}{c BT}{hline 12}{c BRC}"
	di ""
	
	di ""
		di "{hline 13}{c TT}{hline 13}{c TT}{hline 13}{c TRC}"
	di "" "{col 14}{c |} INB"  "{col 28}{c |}  INB SE" "{col 42}{c |}"
	di "{hline 13}{c +}{hline 13}{c +}{hline 13}{c RT}"
	di "  Net Ben Results" "{col 14}{c |}"   %10.3f `NB1' "{col 28}{c |}"   %10.3f `nbse1' "{col 42}{c |}"
	di "{hline 13}{c BT}{hline 13}{c BT}{hline 13}{c BRC}"
	di ""
	
	 if `icer1a' <= 0 {
	di in red "Warning: Dominant ICER detected!"
		di in red "Please check cost effectiveness table carefully before reporting results"
}
	
}	
*	
	
if `vars'==4 {	
	
qui count if `intervention'==0
 local numberA = r(N)
qui count if `intervention'==1
 local numberB = r(N)		

       foreach var of varlist `1' `2' `3' `4' {
 
 qui count if missing(`var')
	local missing`var' = r(N)
	if `missing`var'' != 0 {
		di in red "Error: Missing Data detected in `var'"
		exit 456
	} 
	}
	
qui summarize `1' if `intervention'==0
local meanCost1A = r(mean)
local sdCost1A = r(sd)
local seCost1A = `sdCost1A'/sqrt(`numberA')
qui summarize `1' if `intervention'==1
local meanCost1B = r(mean)
local sdCost1B = r(sd)
local seCost1B = `sdCost1B'/sqrt(`numberB')

qui summarize `2' if `intervention'==0
local meanEff1A = r(mean)
local sdEff1A = r(sd)
local seEff1A = `sdEff1A'/sqrt(`numberA')
qui summarize `2' if `intervention'==1
local meanEff1B = r(mean)
local sdEff1B = r(sd)
local seEff1B = `sdEff1B'/sqrt(`numberB')




qui summarize `3' if `intervention'==0
local meanCost2A = r(mean)
local sdCost2A = r(sd)
local seCost2A = `sdCost2A'/sqrt(`numberA')
qui summarize `3' if `intervention'==1
local meanCost2B = r(mean)
local sdCost2B = r(sd)
local seCost2B = `sdCost2B'/sqrt(`numberB')

qui summarize `4' if `intervention'==0
local meanEff2A = r(mean)
local sdEff2A = r(sd)
local seEff2A = `sdEff2A'/sqrt(`numberA')
qui summarize `4' if `intervention'==1
local meanEff2B = r(mean)
local sdEff2B = r(sd)
local seEff2B = `sdEff2B'/sqrt(`numberB')

qui correlate `1' `2' if `intervention'==0
local corr1A = r(rho)
qui correlate `1' `2' if `intervention'==1
local corr1B = r(rho)
qui correlate `3' `4' if `intervention'==0
local corr2A = r(rho)
qui correlate `3' `4' if `intervention'==1
local corr2B = r(rho)	

local nbse1 = sqrt((`w2p'^2)*(`seEff1A'^2 + `seEff1B'^2) + (`seCost1A'^2 + `seCost1B'^2) + ///
							2*`w2p'*`corr1A'* `seCost1A'*`seEff1A' + ///
							2*`w2p'*`corr1B'* `seCost1B'*`seEff1B') 
local nbse2 = sqrt((`w2p'^2)*(`seEff2A'^2 + `seEff2B'^2) + (`seCost2A'^2 + `seCost2B'^2) + ///
							2*`w2p'*`corr2A'* `seCost2A'*`seEff2A' + ///
							2*`w2p'*`corr2B'* `seCost2B'*`seEff2B') 


							
	 local incCost1 = `meanCost1B' - `meanCost1A'
	 local incCost2 = 	`meanCost2B' - `meanCost2A'
	 
if      "`response'" == "detr"{	 
	 local incEffect1 = `meanEff1A' - `meanEff1B' 
	 local incEffect2 = `meanEff2A' - `meanEff2B' 
	}
 if "`response'" == "bene"{
	 local incEffect1 = `meanEff1B' - `meanEff1A' 
	 local incEffect2 = `meanEff2B' - `meanEff2A' 
 }
	
	
	local icer1 = `incCost1'/`incEffect1'
	local icer2 = `incCost2'/`incEffect2'
	local NB1 = `w2p' * `incEffect1' - `incCost1'
    local NB2 = `w2p' * `incEffect2' - `incCost2' 
	local NBupCI1 = `NB1' + 1.96*`nbse1'
	local NBloCI1 = `NB1' - 1.96*`nbse1'
	local NBupCI2 = `NB2' + 1.96*`nbse2'
	local NBloCI2 = `NB2' - 1.96*`nbse2'
	local diffNB = `NB2' - `NB1'
	
	
	
qui correlate `1' `3' if `intervention'==0, covariance
local covCostA = r(cov_12)
qui correlate `1' `3' if `intervention'==1, covariance
local covCostB = r(cov_12)

local covDeltaCost = `covCostA' + `covCostB'

qui correlate `2' `4' if `intervention'==0, covariance
local covEffA = `w2p'*`w2p'*r(cov_12)

qui correlate `2' `4' if `intervention'==1, covariance
local covEffB = `w2p'*`w2p'*r(cov_12)

qui correlate `1' `4' if `intervention' == 0, covariance
local cov1C2EA = `w2p'*r(cov_12)
qui correlate `2' `3' if `intervention' == 0, covariance
local cov1E2CA = `w2p'*r(cov_12)

qui correlate `1' `4' if `intervention' ==1, covariance
local cov1C2EB = `w2p'*r(cov_12)
qui correlate `2' `3' if `intervention' == 1, covariance
local cov1E2CB = `w2p'*r(cov_12)

local covDeltaEff = `covEffA' + `covEffB'

local covDeltaCostEffD1 = - ( `cov1C2EA' + `cov1C2EB' )
local covDeltaCostEffD2 = - ( `cov1E2CA' + `cov1E2CB' )

local NB1 = `w2p' * `incEffect1' - `incCost1' 
local NB2 = `w2p' * `incEffect2' - `incCost2' 

qui correlate `1' `2' if `intervention'==0, covariance
local covD1A = r(cov_12)
qui correlate `1' `2' if `intervention'==1, covariance
local covD1B = r(cov_12)
local sdNB1 = sqrt( `w2p'*`w2p'*(`sdEff1A'^2 + `sdEff1B'^2) + `sdCost1A'^2 + `sdCost1B'^2 + ///
					2 * `w2p' *(`covD1A' + `covD1B'))
qui correlate `3' `4' if `intervention'==0, covariance
local covD2A = r(cov_12)
qui correlate `3' `4' if `intervention'==1, covariance
local covD2B = r(cov_12)
local sdNB2 = sqrt( `w2p'*`w2p'*(`sdEff2A'^2 + `sdEff2B'^2) + `sdCost2A'^2 + `sdCost2B'^2 + ///
					2 * `w2p' *(`covD2A' + `covD2B'))
local covNB = `covDeltaEff' - `covDeltaCostEffD1' - `covDeltaCostEffD2' + `covDeltaCost'
local rhoNB = `covNB' / (`sdNB1' * `sdNB2')
local mucccNB = `diffNB' / sqrt(`sdNB1' * `sdNB2')
local cbNB = 2*`sdNB1'*`sdNB2' / (abs(`diffNB')^2 + `sdNB1'^2 + `sdNB2'^2)
local cccNB = `rhoNB' * `cbNB'
local zcccNB = 0.5*log((1+`cccNB')/(1-`cccNB'))

return scalar zcccNB = `zcccNB'
return scalar cccNB = `cccNB' 							//						Lin's CCC
return scalar ICER2 = `icer2'
return scalar ICER1 = `icer1'				//				ICER	
return scalar diffNB =   `diffNB' 							// 				NB Difference
return scalar upCINB2 = `NBupCI2'
return scalar loCINB2 = `NBloCI2'
return scalar seNB2 = `nbse2'
return scalar NB2 = `NB2'
return scalar upCINB1 = `NBupCI1'
return scalar loCINB1 = `NBloCI1'	
return scalar seNB1 = `nbse1'
return scalar NB1 = `NB1'
return scalar outcome2 = `incEffect2'
return scalar cost2 = `incCost2'
return scalar outcome1 = `incEffect1'
return scalar cost1 = `incCost1'


	di ""
		di "{hline 9}{c TT}{hline 12}{c TT}{hline 12}{c TT}{hline 12}{c TT}{hline 9}{c TT}{hline 12}{c TRC}"
	di "" "{col 10}{c |} ICER"  "{col 23}{c |}  INB" "{col 36}{c |} INB SE" "{col 49}{c |}  CCC" "{col 59}{c |} Diff INB" "{col 72}{c |}"
	di "{hline 9}{c +}{hline 12}{c +}{hline 12}{c +}{hline 12}{c +}{hline 9}{c +}{hline 12}{c RT}"
	di "  DATA 1" "{col 10}{c |}" %10.3f `icer1' "{col 23}{c |}" %10.3f `NB1' "{col 36}{c |}"  %10.3f `nbse1'  /// 
			"{col 49}{c |}"  "{col 59}{c |}" "{col 72}{c |}" 
	di  "{col 10}{c |}" "{col 23}{c |}"  "{col 36}{c |}" "{col 49}{c |}" %7.3f `cccNB' "{col 59}{c |}" %10.3f `diffNB' "{col 72}{c |}" 
	di "  DATA 2" "{col 10}{c |}" %10.3f `icer2' "{col 23}{c |}" %10.3f `NB2' "{col 36}{c |}" %10.3f `nbse2'  /// 
			"{col 49}{c |}" "{col 59}{c |}" "{col 72}{c |}"
	di "{hline 9}{c BT}{hline 12}{c BT}{hline 12}{c BT}{hline 12}{c BT}{hline 9}{c BT}{hline 12}{c BRC}"
	di ""
	
	local icer1a = cond(`icer1'<0,0, `icer1')
	local icer2a = cond(`icer2'<0,0, `icer2')
	
	if `icer1a' <= 0 {
	di in red "Warning: Dominant ICER detected in data 1!"
		di in red "Please check cost effectiveness table carefully before reporting results"
		}
	if `icer2a' <= 0 {
	di in red "Warning: Dominant ICER detected in data 2!"
		di in red "Please check cost effectiveness table carefully before reporting results"	
	}
*return scalar covDeltaEff = `covDeltaEff'
*return scalar covDeltaCostEffD1 = `covDeltaCostEffD1'
*return scalar covDeltaCostEffD2 =`covDeltaCostEffD2'
*return scalar covDeltaCost = `covDeltaCost'
}
end
cap program drop heabs
program heabs, rclass
	version 8.2
		syntax varlist(min=2 max=4 numeric) ,		///
		INTervention(varname numeric)				/// 
		RESponse(string) 							/// 
		[w2p(real 0) ] 

		
		
local vars : word count `varlist'
if `vars' == 3 {
di in red "Error: Must input 2 or 4 variables, not 3."
exit
}		
		
tokenize `varlist'		


 qui count if `intervention' == 0
local zeroes = r(N)
qui count if `intervention' == 1
local ones = r(N)
if `ones' + `zeroes' != _N {
di in red "Error: intervention var contains missing data, or values that are not 0 or 1."
exit
}
 
 
 if "`response'" != "detr" & "`response'" != "bene" {
	di in red "Error: 'response' must be either 'bene' or 'detr'"
	exit
}
 if `w2p' < 0 {
	di in red "Error: Willing-to-Pay level must not be negative."
	exit
}

	
if `vars'==2 {
qui count if `intervention'==0
 local numberA = r(N)
qui count if `intervention'==1
 local numberB = r(N)		

       foreach var of varlist `1' `2' {
 
 qui count if missing(`var')
	local missing`var' = r(N)
	if `missing`var'' != 0 {
		di in red "Error: Missing Data detected in `var'"
		exit 456
	} 
	}
	
qui summarize `1' if `intervention'==0
local meanCost1A = r(mean)
local sdCost1A = r(sd)
local seCost1A = `sdCost1A'/sqrt(`numberA')
local mincost1A = r(min)
local maxcost1A = r(max)
local n1A = r(N)

qui summarize `1' if `intervention'==1
local meanCost1B = r(mean)
local sdCost1B = r(sd)
local seCost1B = `sdCost1B'/sqrt(`numberB')
local mincost1B = r(min)
local maxcost1B = r(max)
local n1B = r(N)

qui summarize `2' if `intervention'==0
local meanEff1A = r(mean)
local sdEff1A = r(sd)
local seEff1A = `sdEff1A'/sqrt(`numberA')
local mineff1A = r(min)
local maxeff1A = r(max)

qui summarize `2' if `intervention'==1
local meanEff1B = r(mean)
local sdEff1B = r(sd)
local seEff1B = `sdEff1B'/sqrt(`numberB')
local mineff1B = r(min)
local maxeff1B = r(max)

qui correlate `1' `2' if `intervention'==0
local corr1A = r(rho)
qui correlate `1' `2' if `intervention'==1
local corr1B = r(rho)


local nbse1 = sqrt((`w2p'^2)*(`seEff1A'^2 + `seEff1B'^2) + (`seCost1A'^2 + `seCost1B'^2) + ///
							2*`w2p'*`corr1A'* `seCost1A'*`seEff1A' + ///
							2*`w2p'*`corr1B'* `seCost1B'*`seEff1B') 

							
	 local incCost1 = `meanCost1B' - `meanCost1A'
	 
if      "`response'" == "detr"{	 
	 local incEffect1 = `meanEff1A' - `meanEff1B' 
	}
 if "`response'" == "bene"{
	 local incEffect1 = `meanEff1B' - `meanEff1A' 
 }
	local icer1 = `incCost1'/`incEffect1'
	local NB1 = `w2p' * `incEffect1' - `incCost1'
	local NBupCI1 = `NB1' + 1.96*`nbse1'
	local NBloCI1 = `NB1' - 1.96*`nbse1'
	
	return scalar upCINB1 = `NBupCI1'
	return scalar loCINB1 = `NBloCI1'
	return scalar seNB1 = `nbse1'
	return scalar NB1 = `NB1'
	return scalar ICER1 = `icer1'				//				ICER	
	return scalar outcome1 = `incEffect1'
	return scalar cost1 = `incCost1'
	
	local icer1a = cond(`icer1'<0,0, `icer1')
	di ""
	di "{col 4} Summary:" "{col 24} Int 0" "{col 40} Int 1"
	di "{col 8}N" "{col 24}" `n1A' "{col 40}" `n1B'
	di "{col 8}Min Cost" "{col 24}" `mincost1A' "{col 40}" `mincost1B'
	di "{col 8}Max Cost" "{col 24}" `maxcost1A' "{col 40}" `maxcost1B'
	di "{col 8}Min Effect" "{col 24}" `mineff1A' "{col 40}" `mineff1B'
	di "{col 8}Max Effect" "{col 24}" `maxeff1A' "{col 40}" `maxeff1B'
	di ""
		di "{hline 9}{c TT}{hline 12}{c TT}{hline 12}{c TT}{hline 12}{c TT}{hline 12}{c TT}{hline 12}{c TRC}"
	di "" "{col 10}{c |} Cost"  "{col 23}{c |}  Effect" "{col 36}{c |} Inc Cost" "{col 49}{c |} Inc Effect" "{col 62}{c |} ICER" "{col 75}{c |}"
	di "{hline 9}{c +}{hline 12}{c +}{hline 12}{c +}{hline 12}{c +}{hline 12}{c +}{hline 12}{c RT}"
	di "  Int 0" "{col 10}{c |}" %10.3f `meanCost1A' "{col 23}{c |}" %10.3f `meanEff1A' "{col 36}{c |}"  /// 
			"{col 49}{c |}" "{col 62}{c |}" "{col 75}{c |}"
	di  "{col 10}{c |}"  "{col 23}{c |}"  "{col 36}{c |}" %10.3f `incCost1' "{col 49}{c |}" %10.3f `incEffect1' "{col 62}{c |}" %10.3f `icer1a' "{col 75}{c |}"			
	di "  Int 1" "{col 10}{c |}" %10.3f `meanCost1B' "{col 23}{c |}" %10.3f `meanEff1B' "{col 36}{c |}"   /// 
			"{col 49}{c |}" "{col 62}{c |}" "{col 75}{c |}"
	di "{hline 9}{c BT}{hline 12}{c BT}{hline 12}{c BT}{hline 12}{c BT}{hline 12}{c BT}{hline 12}{c BRC}"
	di ""
	
		di "{hline 13}{c TT}{hline 13}{c TT}{hline 13}{c TRC}"
	di "" "{col 14}{c |} INB"  "{col 28}{c |}  INB SE" "{col 42}{c |}"
	di "{hline 13}{c +}{hline 13}{c +}{hline 13}{c RT}"
	di "  INB Results" "{col 14}{c |}"   %10.3f `NB1' "{col 28}{c |}"   %10.3f `nbse1' "{col 42}{c |}"
	di "{hline 13}{c BT}{hline 13}{c BT}{hline 13}{c BRC}"
	di ""
	
	 if `icer1a' <= 0 {
	di in red "Warning: Dominant ICER detected!"
		di in red "Please check cost effectiveness table carefully before reporting results"
}
	
}	
*	
	
if `vars'==4 {	
	
qui count if `intervention'==0
 local numberA = r(N)
qui count if `intervention'==1
 local numberB = r(N)		

       foreach var of varlist `1' `2' `3' `4' {
 
 qui count if missing(`var')
	local missing`var' = r(N)
	if `missing`var'' != 0 {
		di in red "Error: Missing Data detected in `var'"
		exit 456
	} 
	}
	
qui summarize `1' if `intervention'==0
local meanCost1A = r(mean)
local sdCost1A = r(sd)
local seCost1A = `sdCost1A'/sqrt(`numberA')
local mincost1A = r(min)
local maxcost1A = r(max)
local n1A = r(N)

qui summarize `1' if `intervention'==1
local meanCost1B = r(mean)
local sdCost1B = r(sd)
local seCost1B = `sdCost1B'/sqrt(`numberB')
local mincost1B = r(min)
local maxcost1B = r(max)
local n1B = r(N)

qui summarize `2' if `intervention'==0
local meanEff1A = r(mean)
local sdEff1A = r(sd)
local seEff1A = `sdEff1A'/sqrt(`numberA')
local mineff1A = r(min)
local maxeff1A = r(max)

qui summarize `2' if `intervention'==1
local meanEff1B = r(mean)
local sdEff1B = r(sd)
local seEff1B = `sdEff1B'/sqrt(`numberB')
local mineff1B = r(min)
local maxeff1B = r(max)



qui summarize `3' if `intervention'==0
local meanCost2A = r(mean)
local sdCost2A = r(sd)
local seCost2A = `sdCost2A'/sqrt(`numberA')
local mincost2A = r(min)
local maxcost2A = r(max)
local n2A = r(N)
qui summarize `3' if `intervention'==1
local meanCost2B = r(mean)
local sdCost2B = r(sd)
local seCost2B = `sdCost2B'/sqrt(`numberB')
local mincost2B = r(min)
local maxcost2B = r(max)
local n2B = r(N)

qui summarize `4' if `intervention'==0
local meanEff2A = r(mean)
local sdEff2A = r(sd)
local seEff2A = `sdEff2A'/sqrt(`numberA')
local mineff2A = r(min)
local maxeff2A = r(max)
qui summarize `4' if `intervention'==1
local meanEff2B = r(mean)
local sdEff2B = r(sd)
local seEff2B = `sdEff2B'/sqrt(`numberB')
local mineff2B = r(min)
local maxeff2B = r(max)

qui correlate `1' `2' if `intervention'==0
local corr1A = r(rho)
qui correlate `1' `2' if `intervention'==1
local corr1B = r(rho)
qui correlate `3' `4' if `intervention'==0
local corr2A = r(rho)
qui correlate `3' `4' if `intervention'==1
local corr2B = r(rho)	

local nbse1 = sqrt((`w2p'^2)*(`seEff1A'^2 + `seEff1B'^2) + (`seCost1A'^2 + `seCost1B'^2) + ///
							2*`w2p'*`corr1A'* `seCost1A'*`seEff1A' + ///
							2*`w2p'*`corr1B'* `seCost1B'*`seEff1B') 
local nbse2 = sqrt((`w2p'^2)*(`seEff2A'^2 + `seEff2B'^2) + (`seCost2A'^2 + `seCost2B'^2) + ///
							2*`w2p'*`corr2A'* `seCost2A'*`seEff2A' + ///
							2*`w2p'*`corr2B'* `seCost2B'*`seEff2B') 


							
	 local incCost1 = `meanCost1B' - `meanCost1A'
	 local incCost2 = 	`meanCost2B' - `meanCost2A'
	 
if      "`response'" == "detr"{	 
	 local incEffect1 = `meanEff1A' - `meanEff1B' 
	 local incEffect2 = `meanEff2A' - `meanEff2B' 
	}
 if "`response'" == "bene"{
	 local incEffect1 = `meanEff1B' - `meanEff1A' 
	 local incEffect2 = `meanEff2B' - `meanEff2A' 
 }
	
	
	local icer1 = `incCost1'/`incEffect1'
	local icer2 = `incCost2'/`incEffect2'
	local NB1 = `w2p' * `incEffect1' - `incCost1'
    local NB2 = `w2p' * `incEffect2' - `incCost2' 
	local NBupCI1 = `NB1' + 1.96*`nbse1'
	local NBloCI1 = `NB1' - 1.96*`nbse1'
	local NBupCI2 = `NB2' + 1.96*`nbse2'
	local NBloCI2 = `NB2' - 1.96*`nbse2'
	local diffNB = `NB2' - `NB1'
	
	
	
qui correlate `1' `3' if `intervention'==0, covariance
local covCostA = r(cov_12)
qui correlate `1' `3' if `intervention'==1, covariance
local covCostB = r(cov_12)

local covDeltaCost = `covCostA' + `covCostB'

qui correlate `2' `4' if `intervention'==0, covariance
local covEffA = `w2p'*`w2p'*r(cov_12)

qui correlate `2' `4' if `intervention'==1, covariance
local covEffB = `w2p'*`w2p'*r(cov_12)

qui correlate `1' `4' if `intervention' == 0, covariance
local cov1C2EA = `w2p'*r(cov_12)
qui correlate `2' `3' if `intervention' == 0, covariance
local cov1E2CA = `w2p'*r(cov_12)

qui correlate `1' `4' if `intervention' ==1, covariance
local cov1C2EB = `w2p'*r(cov_12)
qui correlate `2' `3' if `intervention' == 1, covariance
local cov1E2CB = `w2p'*r(cov_12)

local covDeltaEff = `covEffA' + `covEffB'

local covDeltaCostEffD1 = - ( `cov1C2EA' + `cov1C2EB' )
local covDeltaCostEffD2 = - ( `cov1E2CA' + `cov1E2CB' )

local NB1 = `w2p' * `incEffect1' - `incCost1' 
local NB2 = `w2p' * `incEffect2' - `incCost2' 

qui correlate `1' `2' if `intervention'==0, covariance
local covD1A = r(cov_12)
qui correlate `1' `2' if `intervention'==1, covariance
local covD1B = r(cov_12)
local sdNB1 = sqrt( `w2p'*`w2p'*(`sdEff1A'^2 + `sdEff1B'^2) + `sdCost1A'^2 + `sdCost1B'^2 + ///
					2 * `w2p' *(`covD1A' + `covD1B'))
qui correlate `3' `4' if `intervention'==0, covariance
local covD2A = r(cov_12)
qui correlate `3' `4' if `intervention'==1, covariance
local covD2B = r(cov_12)
local sdNB2 = sqrt( `w2p'*`w2p'*(`sdEff2A'^2 + `sdEff2B'^2) + `sdCost2A'^2 + `sdCost2B'^2 + ///
					2 * `w2p' *(`covD2A' + `covD2B'))
local covNB = `covDeltaEff' - `covDeltaCostEffD1' - `covDeltaCostEffD2' + `covDeltaCost'
local rhoNB = `covNB' / (`sdNB1' * `sdNB2')
local mucccNB = `diffNB' / sqrt(`sdNB1' * `sdNB2')
local cbNB = 2*`sdNB1'*`sdNB2' / (abs(`diffNB')^2 + `sdNB1'^2 + `sdNB2'^2)
local cccNB = `rhoNB' * `cbNB'
local zcccNB = 0.5*log((1+`cccNB')/(1-`cccNB'))

return scalar zcccNB = `zcccNB'
return scalar cccNB = `cccNB' 							//						Lin's CCC
return scalar ICER2 = `icer2'
return scalar ICER1 = `icer1'				//				ICER	
return scalar diffNB =   `diffNB' 							// 				NB Difference
return scalar upCINB2 = `NBupCI2'
return scalar loCINB2 = `NBloCI2'
return scalar seNB2 = `nbse2'
return scalar NB2 = `NB2'
return scalar upCINB1 = `NBupCI1'
return scalar loCINB1 = `NBloCI1'	
return scalar seNB1 = `nbse1'
return scalar NB1 = `NB1'
return scalar outcome2 = `incEffect2'
return scalar cost2 = `incCost2'
return scalar outcome1 = `incEffect1'
return scalar cost1 = `incCost1'

di ""
	di "{col 2} Summary:" "{col 26}Data 1" "{col 58}Data 2"
	di "{col 18} Int 0" "{col 34} Int 1" "{col 50} Int 0" "{col 66} Int 1"
	di "{col 4}N" "{col 18}" `n1A' "{col 34}" `n1B' "{col 50}" `n2A' "{col 66}" `n2B'
	di "{col 4}Min Cost" "{col 18}" `mincost1A' "{col 34}" `mincost1B' "{col 50}" `mincost2A' "{col 66}" `mincost2A'
	di "{col 4}Max Cost" "{col 18}" `maxcost1A' "{col 34}" `maxcost1B' "{col 50}" `maxcost2A' "{col 66}" `maxcost2A'
	di "{col 4}Min Effect" "{col 18}" `mineff1A' "{col 34}" `mineff1B' "{col 50}" `mineff2A' "{col 66}" `mineff2B'
	di "{col 4}Max Effect" "{col 18}" `maxeff1A' "{col 34}" `maxeff1B' "{col 50}" `maxeff2A' "{col 66}" `maxeff2B'

	di ""
		di "{hline 9}{c TT}{hline 12}{c TT}{hline 12}{c TT}{hline 12}{c TT}{hline 9}{c TT}{hline 12}{c TRC}"
	di "" "{col 10}{c |} ICER"  "{col 23}{c |}  INB" "{col 36}{c |} INB SE" "{col 49}{c |}  CCC" "{col 59}{c |} Diff INB" "{col 72}{c |}"
	di "{hline 9}{c +}{hline 12}{c +}{hline 12}{c +}{hline 12}{c +}{hline 9}{c +}{hline 12}{c RT}"
	di "  DATA 1" "{col 10}{c |}" %10.3f `icer1' "{col 23}{c |}" %10.3f `NB1' "{col 36}{c |}"  %10.3f `nbse1'  /// 
			"{col 49}{c |}"  "{col 59}{c |}" "{col 72}{c |}" 
	di  "{col 10}{c |}" "{col 23}{c |}"  "{col 36}{c |}" "{col 49}{c |}" %7.3f `cccNB' "{col 59}{c |}" %10.3f `diffNB' "{col 72}{c |}" 
	di "  DATA 2" "{col 10}{c |}" %10.3f `icer2' "{col 23}{c |}" %10.3f `NB2' "{col 36}{c |}" %10.3f `nbse2'  /// 
			"{col 49}{c |}" "{col 59}{c |}" "{col 72}{c |}"
	di "{hline 9}{c BT}{hline 12}{c BT}{hline 12}{c BT}{hline 12}{c BT}{hline 9}{c BT}{hline 12}{c BRC}"
	di ""
	
	local icer1a = cond(`icer1'<0,0, `icer1')
	local icer2a = cond(`icer2'<0,0, `icer2')
	
	if `icer1a' <= 0 {
	di in red "Warning: Dominant ICER detected in data 1!"
		di in red "Please check cost effectiveness table carefully before reporting results"
		}
	if `icer2a' <= 0 {
	di in red "Warning: Dominant ICER detected in data 2!"
		di in red "Please check cost effectiveness table carefully before reporting results"	
	}
*return scalar covDeltaEff = `covDeltaEff'
*return scalar covDeltaCostEffD1 = `covDeltaCostEffD1'
*return scalar covDeltaCostEffD2 =`covDeltaCostEffD2'
*return scalar covDeltaCost = `covDeltaCost'
}
end



