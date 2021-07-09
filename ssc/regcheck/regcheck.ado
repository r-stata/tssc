*!cv version 1.0
*!Written 01Dec2014
*!Written by Mehmet Mehmetoglu
capture program drop regcheck
	program regcheck
	version 13.0
//quietly regress
//quietly ereturn list
local ecmd "e(cmd)"
if `ecmd' != "regress" {
	di in red "works only with -regress-"
	exit
	}	
tempname edfm
scalar `edfm' = e(df_m) 
if `edfm'==1 {
    di in red "works only with multiple regression"
	exit
	}	
di as smcl as txt  "{c TLC}{hline 110}{c TRC}"
di in yellow "     {bf:Regression assumptions:}{dup 20: }{c |} {bf: Test:}{dup 37: } We seek values"
di as smcl as txt "{c LT}{hline 110}{c RT}"	
/*assumption 1*/	
quietly hettest
//quietly return list
tempname rp
scalar `rp' = r(p)
if `rp' < 0.05 {
	display in red "  1) {bf:heterokedasticity problem}{dup 18: }{c |} {bf: Breusch-Pagan hettest}{dup 25: }{bf:> 0.05}"	
	}
else {
	display in green "  1) {bf:no heterokedasticity problem}{dup 15: }{c |} {bf: Breusch-Pagan hettest}{dup 25: }{bf:> 0.05}"
	}
	di "{dup 48: }{c |}  Chi2(`r(df)'): " %-12.3f `r(chi2)'
	di "{dup 48: }{c |}  p-value: " %-12.3f `rp'
di as smcl as txt "{c LT}{hline 110}{c RT}"	
/*assumption 2*/
quietly vif
//quietly return list
tempname rvif1
scalar `rvif1' = r(vif_1)     
	 if `rvif1' > 5 {
	display in red "  2) {bf:multicollinearity problem}{dup 18: }{c |}  {bf:Variance inflation factor}{dup 21: }{bf:< 5.00}"
	}
	else {
	 display in green "  2) {bf:no multicollinearity problem}{dup 15: }{c |}  {bf:Variance inflation factor}{dup 21: }{bf:< 5.00}" 
	 }
local ii=1
local names: r(macros)
local names: list sort names
foreach val of local names {
display "{dup 48: }{c |}  " r(`val') " : " %-12.2f r(vif_`ii')
local ++ii
}
di as smcl as txt "{c LT}{hline 110}{c RT}"	
/*assumption 3*/	
tempvar residualerx
quietly predict `residualerx',res
quietly swilk `residualerx'
//quietly return list
if `r(p)' < 0.01 {
	display in red "  3) {bf:residuals are not normally distributed}{dup 5: }{c |}  {bf:Shapiro-Wilk W normality test} {dup 16: }{bf:> 0.01}"
	}
	else {
	display in green "  3) {bf:residuals are normally distributed}{dup 9: }{c |}  {bf:Shapiro-Wilk W normality test} {dup 16: }{bf:> 0.01}" 
	}
	di "{dup 48: }{c |}  z: "%-12.3f `r(z)'
	di "{dup 48: }{c |}  p-value: "%-12.3f `r(p)'
di as smcl as txt "{c LT}{hline 110}{c RT}"
/*assumption 4*/	
quietly linktest
//quietly return list
tempname rt
scalar `rt' = r(t)
tempname rdf
scalar `rdf' = r(df)
tempname pval
scalar `pval' = 2*ttail(`rdf',`rt') 
tempname pval2
scalar `pval2' = 2*ttail(`rdf',-`rt') //puts minus for minus t-values
if `pval' < 0.05 {
	display in red "  4) {bf:specification problem}{dup 22: }{c |}  {bf:Linktest} {dup 36: }{bf: > 0.05}"
	}
	else {
	display in green "  4) {bf:no specification problem}{dup 19: }{c |}  {bf:Linktest} {dup 36: }{bf: > 0.05}"
	} 
	if `rt' < 0 {
di 	"{dup 48: }{c |}  t: "%-12.3f `rt'
di 	"{dup 48: }{c |}  p-value: "%-12.3f `pval2'
}
else {
di 	"{dup 48: }{c |}  t: "%-12.3f `rt'
di 	"{dup 48: }{c |}  p-value: "%-12.3f `pval'
}
di as smcl as txt "{c LT}{hline 110}{c RT}"	
*/
/*assumption 5*/
quietly ovtest
//quietly return list
tempname ordf
scalar `ordf'=r(df)
tempname ordfr 
scalar `ordfr'=r(df_r)
tempname orf 
scalar `orf'=r(F)
tempname pval3
scalar `pval3' = Ftail(`ordf',`ordfr',`orf')
if `pval3' < 0.05 {
	display in red "  5) {bf:functional form problem}{dup 20: }{c |}  {bf:Test for appropriate functional form} {dup 8: }{bf: > 0.05}"  
	}
	else {
	display in green "  5) {bf:appropriate functional form}{dup 16: }{c |}  {bf:Test for appropriate functional form} {dup 8: }{bf: > 0.05}"
	}
	display "{dup 48: }{c |}  F(`r(df)',`r(df_r)'):" %-12.3f `r(F)'  
	display "{dup 48: }{c |}  p-value: "%-12.3f `pval3' 
di as smcl as txt "{c LT}{hline 110}{c RT}"	
/*assumption 6*/
tempvar influerendex
quietly predict `influerendex', cook 
quietly sum `influerendex', meanonly 
//quietly return list
tempname maxval
scalar `maxval'=r(max)
if `maxval' >1 & `maxval'!=. {
	display in red "  6) {bf:influential observations}{dup 19: }{c |}  {bf:Cook's distance} {dup 29: }{bf: < 1.00}"
	di in red "{dup 48: }{c |} {bf: to see the influential obs, type:}"
	di in red "{dup 48: }{c |} {bf: .predict var, cook}"
	di in red "{dup 48: }{c |} {bf: .list var if var > 1 & var !=.}"
	}
	else{
	di in green "  6) {bf:no influential observations}{dup 16: }{c |}  {bf:Cook's distance} {dup 29: }{bf: < 1.00}"
	di in green "{dup 48: }{c |} {bf: no distance is above the cutoff}" 
	}	
di as smcl as txt "{c BLC}{hline 110}{c BRC}"
end



