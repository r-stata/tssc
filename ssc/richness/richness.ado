*! This version 2.0.0 (2008-11-18, A. Peichl)
******************************************************
******************************************************
********   measurement of richness:   *************
******************************************************
********  				 *************
********  Reference:
********  Peichl, Andreas; Schaefer, Thilo and Christoph Scheicher (2006): Measuring Richness and Poverty - 
********  A micro data application to Europe and Germany, IZA discussion paper No. 3790.
********  				 *************
******************************************************
********  				 *************
********  Author:
********  
********     Andreas Peichl 
********     IZA - Institute for the study of labor
********     Bonn, Germany
********     peichl@iza.org
********     www.iza.org
******** 
********  Previous version 1.2.1 (2007-02-23, A. Peichl & T. Schaefer)
*******   was based on :
********  Peichl, Andreas; Schaefer, Thilo and Christoph Scheicher (2006): Measuring Richness and Poverty - 
********  A micro data application to Germany and the EU-15, CPE discussion papers No. 06-11, University of Cologne.
********  Authors:
********     Andreas Peichl & Thilo Schaefer
********     Cologne Center for Public Economics
********     University of Cologne, Germany
********     a.peichl@uni-koeln.de, schaefer@fifo-koeln.de
********     www.cpe-cologne.de
********  	
********  				 *************
******************************************************
******************************************************


program define richness, rclass sortpreserve
  version 8.2
  syntax varlist(numeric) [if] [in] [fweight aweight] [, ///
  RLine(numlist min=0 max=1 >=0) ///
  RVal(string) ///
  RNumber(numlist min=0 max=1 int >=0) ///
  RLFix ///
*not used yet  RAlpha(numlist min=0 max=1 int >=0) /// 
  ]

if wordcount("`rval'") == 0  local rval = "median"
else if "`rval'" ~= "mean" & "`rval'" ~= "median" {
	di as error "only mean or median allowed in option rval()!"
	exit
	}	

quietly {
tempvar wi 

  if "`weight'" == "" gen `wi' = 1
	else gen `wi' `exp'

  
foreach var of local varlist {
  local pos : list posof "`var'" in local varlist
  
  tempvar reichtum badvar touse 

	mark `touse' `if' `in'
	markout `touse' `var' 
	lab var `touse' "All obs"
	lab def `touse' 1 " "
	lab val `touse' `touse'

	
	count if `var' < 0 & `touse'
	local ct = _result(1)
	if `ct' > 0 {
		noi di as text "Note: `var' has `ct' value(s) < 0." _c
		noi di as text " Not used in calculations."
	}
	count if `var' == 0 & `touse'
	local ct = _result(1)
	if `ct' > 0 {
		noi di as text "Note: `var' has `ct' value(s) = 0." _c
		noi di as text " Used in calculations."
	}

	gen `badvar' = 0
	replace `badvar' =. if `var' < 0
	markout `touse'  `badvar'
	


  * computation of richness line
  if wordcount("`rline'") == 0  { 
    if wordcount("`rnumber'") == 0 local rnumber = 200
    quietly sum `var'[w = `wi'] if `touse', d
    scalar r_mean = r(mean) 
    scalar r_median = r(p50) 
    scalar richline = `rnumber'/100*r_`rval' 
    scalar anzahl = r(sum_w)
  }
  else  {
    scalar richline = `rline'
    quietly sum `var' [w = `wi'] if `touse', d
    scalar anzahl = r(sum_w)
  }
  
  if wordcount("`rlfix'") ~= 0 {
  if `pos' == 1 scalar rlinefix = richline
  else scalar richline = rlinefix
  }
    
  
  * headcount
  quietly sum `var' [w = `wi'] if `var' > richline & `touse',d
  scalar anzahl_reiche = r(sum_w)
  scalar R_HCR= anzahl_reiche/anzahl	// AP*100
  
  
  **** intensity measures
  gen `reichtum'=0
  
  * R_alpha FGT concave
  foreach alpha of numlist 0.1 0.3 1 {
    local alphaname = `alpha' *100
    replace `reichtum'=(max((`var'-richline)/`var',0))^(`alpha') if `touse'
    quietly sum `reichtum' [w = `wi'] if `touse', meanonly
    scalar R_FGTT1_`alphaname'= r(sum)/anzahl	// AP*100
  }

    
  * R_beta Cha  concave
  foreach alpha of numlist 0.1 0.3 1 3 10 {
  local alphaname = `alpha' *100
    replace `reichtum'=(max(1-(richline/`var')^(`alpha'),0)) if `touse'
    quietly sum `reichtum' [w = `wi'] if `touse', meanonly
    scalar R_Cha_`alphaname'= r(sum)/anzahl	// AP*100
    *matrix define RResults = RResults, richness_`alphaname'
    *matrix colnames RResults = `coln_RR' R(`alphaname')
    *local coln_RR: colnames RResults
    *return scalar R`alphaname'_`var' = richness_`alphaname'
  }
  
  
  
  * R_alpha FGT convex
	    forval alpha = 1/2 {
	      replace `reichtum'=(max((`var'-richline)/richline,0))^(`alpha') if `touse'     // AP 
	      quietly sum `reichtum_`alpha'' [w = `wi'] if `touse', meanonly
	      scalar R_FGTT2_`alpha'= r(sum)/anzahl	// AP*100
	    }
  
  
  * R_Medeiros (absoulte)
  *alpha == 1 !!!
	      replace `reichtum'=(max((`var'-richline),0))^(1) if `touse'   // AP
	      quietly sum `reichtum' [w = `wi'] if `touse', meanonly
	      scalar R_Med= r(sum)/anzahl	// AP *100
	    


  * output
    matrix define RResults =(richline, R_HCR, R_FGTT1_10, R_FGTT1_30, R_FGTT1_100, R_Cha_10, R_Cha_30, R_Cha_100, R_Cha_300, R_Cha_1000, R_FGTT2_1, R_FGTT2_2, R_Med)
    matrix colnames RResults = RL HCR FGTT1(0,1) FGTT1(0,3) FGTT1(1) Cha(0,1) Cha(0,3) Cha(1) Cha(3) Cha(10) FGTT2(1) FGTT2(2) RMed
    matrix rownames RResults =  `var'
  
    if `pos' == 1 matrix ResultsR = RResults
    else matrix ResultsR = ResultsR\RResults
    
    return scalar Rline_`var' = richline
    foreach x in R_HCR R_FGTT1_10 R_FGTT1_30 R_FGTT1_100 R_Cha_10 R_Cha_30 R_Cha_100 R_Cha_300 R_Cha_1000 R_FGTT2_1 R_FGTT2_2 R_Med {
    return scalar `x'_`var' = `x'   
    }  
  
} // var

} // qui
noi di " "
noi di as text "Richness indices:"
matrix list ResultsR, noblank noheader nohalf
noi di as text "RL: richness line"
noi di as text "HCR: headcount index"
noi di as text "FGTT1(a): concave (T1 axiom) FGT richness indices"
noi di as text "Cha(b): concave (T1 axiom) Chakravaty richness indices"
noi di as text "FGTT2(a): convex (T2 axiom) FGT richness indices"
noi di as text "RMed: absolute Medeiros (2006) richness index"
return matrix RR = ResultsR

end
exit
