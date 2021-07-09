*! Date    : 4 March 2013
*! Version : 1.0
*! Author  : Adrian Mander and Lynne Cresswell
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk
*! A sensitivity analysis on imputing observations based on published results

/*
v 1.00  4Mar13  The command is born
*/

*! Order is treated then control 
*! command called simpute  sensitivity imputation on published results
*! simpute, m(7.5 6.2) v(`=2.6^2' `=2.9^2') n(57 50) p(`=52/57' `=47/50') r(-2(2)6)

pr simpute,rclass
version 12.1
preserve
syntax , Means(numlist min=2 max=2) Variances(numlist min=2 max=2) Ns(numlist min=2 max=2) Ps(numlist min=2 max=2) Range(numlist) [saving(string)]
clear
/* TAKE all the options and put them into macros*/
local i 1
foreach p of local ps {
  local p`i++' = `p'
}
local i 1
foreach n of local ns {
  local n`i++' =`n'
}
local i 1
foreach v of local variances {
  local v`i++' =`v'
}
local i 1
foreach x of local means {
  local x`i++' =`x'
}
/* Create a dataset the size of the imputed square grid*/
local size: list sizeof range
qui set obs `=`size'^2'
qui gen dt = .
qui gen dc = .
local line 1
foreach imp1 of local range {
foreach imp2 of local range {
  qui replace dt = `imp1' in `line'
  qui replace dc = `imp2' in `line++'
}
}

di
di "{txt}Handling missing data in Published Results: A sensitivity analysis"
di "{dup 66:{c -}}"
di " The observed results are"
di "                {col 33}Trt    {col 42}Control"
di "{txt}Mean response   {col 33}{res}`x1'   {col 42}`x2'"
di "{txt}Variances     {col 33}{res}`v1'  {col 42}`v2'"
di "{txt}Planned sample sizes  {col 33}{res}`n1'  {col 42}`n2'"
di "{txt}Proportion of missing outcomes  {col 33}{res}" %5.3f `p1' "{txt}  {col 42}{res}" %5.3f `p2'
di
/*Generate the new values of each treatment effect*/
qui gen x1adj1 = `x1'*`p1'+(1-`p1')*dt
qui gen x2adj1 = `x2'*`p2'+(1-`p2')*dc
qui gen v1adj1 = ((`n1'*`p1'-1)*`v1'+`p1'*(1-`p1')*`n1'*(dt-`x1')^2)/(`n1'-1)
qui gen v2adj1 = ((`n2'*`p2'-1)*`v2'+`p2'*(1-`p2')*`n2'*(dc-`x2')^2)/(`n2'-1)
qui gen vcomb1 = ((`n1'-1)*v1adj1+(`n2'-1)*v2adj1)/(`n1'+`n2'-2)
qui gen t1 = (x1adj1-x2adj1)/sqrt(vcomb1*((1/`n1')+(1/`n2')))

qui gen x1adj2=`x1'*`p1'+(1-`p1')*dt
qui gen x2adj2=`x2'*`p2'+(1-`p2')*dc
qui gen v1adj2=(`v1'*(`n1'+`p1'-2)+`p1'*(1-`p1')*`n1'*(dt-`x1')^2)/(`n1'-1)
qui gen v2adj2=(`v2'*(`n2'+`p2'-2)+`p2'*(1-`p2')*`n2'*(dc-`x2')^2)/(`n2'-1)
qui gen vcomb2=((`n1'-1)*v1adj2+(`n2'-1)*v2adj2)/(`n1'+`n2'-2)
qui gen t2=(x1adj2-x2adj2)/sqrt(vcomb2*((1/`n1')+(1/`n2')))

lab var t1 "Test statistic"
lab var t2 "Expected test statistic"
lab var dc "Imputed intervention value"
lab var dt "Imputed reference value"

/*Create the graph to display the options*/
tempfile t1
tempfile t2
tempfile t3
tempfile t4
qui line t1 dc if dt==dc, ytitle(Test statistic) xtitle(Imputed value) yline(1.96, lp(dash)) legend(off) nodraw saving("`t1'")
qui twoway contour t1 dc dt, ccuts(0.7 1 1.3 1.6 1.96 2.3 2.6 2.9) cc(blue blue*.6 blue*.4 blue*.2 pink*.1 pink*.3 pink*.6 pink*.8) ecolor(pink) nodraw saving("`t2'") fxsize(75)
qui line t2 dc if dt==dc, ytitle(Expected test statistic)  xtitle(Imputed value) yline(1.96, lp(dash)) legend(off) nodraw saving("`t3'")
qui twoway contour t2 dc dt, ccuts(0.7 1 1.3 1.6 1.96 2.3 2.6 2.9) cc(blue blue*.6 blue*.4 blue*.2 pink*.1 pink*.3 pink*.6 pink*.8) ecolor(pink) nodraw saving("`t4'") fxsize(75)
if "`saving'"~="" graph combine "`t1'" "`t2'" "`t3'" "`t4'" , saving(`saving')
else   graph combine "`t1'" "`t2'" "`t3'" "`t4'"
restore
end
