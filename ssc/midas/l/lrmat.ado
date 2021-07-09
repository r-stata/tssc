
program define lrmat, rclass byable(recall) sortpreserve
version 9

syntax varlist(min=2 max=2) [if] [in], SUM1(numlist min=3 max=3) SUM2(numlist min=3 max=3)[LEVEL(integer 95)  *]


tokenize `varlist'
local var1 `1'
local var2 `2'    
tokenize `sum1'
local mvar1 `1' 
local mvar1lo `2'
local mvar1hi `3'
tokenize `sum2'
local mvar2 `1' 
local mvar2lo `2'
local mvar2hi `3'
 tempvar pid
gen `pid'= _n
qui{
local note11: di "LUQ: Exclusion & Confirmation"
local note11b: di "LRP>10, LRN<0.1"
local note12: di "RUQ: Confirmation Only"
local note12b: di "LRP>10, LRN>0.1"
local note13: di "LLQ: Exclusion Only"
local note13b: di "LRP<10, LRN<0.1"
local note14: di "RLQ: No Exclusion or Confirmation"
local note14b: di "LRP<10, LRN>0.1"
               
#delimit;
twoway (scatter `var1' `var2', sort mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O)) 
(scatteri `mvar1' `mvar2', msymbol(D) msize(large) clcol(black) clwidth (medium))
(scatteri `mvar1' `mvar2lo' `mvar1' `mvar2hi', recast(line) clcol(black) clpat(solid) clwidth (medium))
(scatteri `mvar1lo' `mvar2' `mvar1hi' `mvar2', recast(line) clcol(black) clpat(solid) clwidth (medium))
(scatter `var1' `var2', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)), 
xtitle("Negative Likelihood Ratio", size(*.90)) xsc(log) xlab(0.1 "0.1"  1) 
xmticks(.02(0.01).09 .2(.1).9) ylab(1 10 100, angle(horizontal))ymticks(2(1)9 20(10)90) 
xline(0.1, lpattern(shortdash) lwidth(vthin)) ytitle("Positive Likelihood Ratio", size(*.90))
 ysc(log) yline(10, lpattern(shortdash) lwidth(vthin)) xsize(`hsize') plotregion(margin(zero)) 
legend(order(3 "`note11'"  "`note11b'"  "`note12'" "`note12b'" 4 "`note13'"  "`note13b'"  "`note14'" 
  "`note14b'" 2 "Summary LRP & LRN for Index Test" "With `level' % Confidence Intervals") 
 pos(2) symxsize(0) forcesize rowgap(1) col(1) size(*.75)) 
name(ScatterMatrix, replace); 
#delimit cr
}
end



 