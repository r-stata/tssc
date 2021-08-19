/*
Plot the kdensity of the coefficient estimates according to user specifications.
*/
program multivrs_plot, rclass
syntax [,normal nozero plotbs bs(string)]
	local intvar `"`r(intvar)'"'
	local prefb `"`r(prefb)'"'
	local weights `"`r(weights)'"'
	if ("`weights'" == "no" | "`weights'" == "uniform") local weights_option ""
	else local weights_option "[aweight=wt_`weights']"
	
	return add
	if "`bs'" == "" quietly sum b_intvar
	else quietly sum b_intvar if i_bs == 1
	if "`rmal'" != "" local normal_opt || function normalden(x,`r(mean)',`r(sd)'), range(b_intvar)  legend(label(2 "normal density"))
	else local normal_opt ""
	if "`zero'" != "" local zero_opt ""
	else local zero_opt xscale(range(0)) xlabel(#6)
	if "`prefb'" != "" local pref_opt xline(`prefb')
	else local pref_opt ""
	if "`plotbs'" != "" local kd_bs (kdensity b_bs)
	graph twoway `kd_bs' (kdensity b_intvar `weights_option' ), ytitle("Density") xtitle("Coefficient on `intvar'") `normal_opt' `zero_opt' `pref_opt'	

end
