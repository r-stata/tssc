cap program drop _ex_adecomp

program define _ex_adecomp, rclass

syntax, example(numlist)

preserve

if ( "`example'" == "1") {

	use exdata_adecomp.dta, clear
	
	adecomp ipcf_ppp ila_ppp itran_ppp ijubi_ppp icap_ppp others [w=pondera], by(ano) eq(c1+c2+c3+c4+c5) varpl(lp_2usd_ppp) in(fgt0 fgt1 fgt2 gini theil)
	
	mat result = r(b)

	mat colnames  result = indicator effect rate

	qui drop _all
	
	svmat double result, n(col)

	label define indicator 0 "FGT0" 1 "FGT1" 2 "FGT2" 3 "Gini" 4 "Theil"
	label values indicator indicator


	label define effect ///
		1 "Labor" ///
		2 "Transfer" ///
		3 "Pension" ///
		4 "Capital" ///
		5 "Others" ///
		6 "Total change"
	label values effect effect

	local total 6
	qui gen aux=rate if  effect==`total'
	qui egen total_effect=sum(aux) , by(indicator)
	qui drop aux
	qui gen share_effect= -100*rate/abs(total_effect)
	
	qui keep if effect!=6
	
	graph bar share_effect , over(effect, label(labsize(*0.6))) by(indicator)  ytitle(Share of the component effect in the total change)
}
restore

end
