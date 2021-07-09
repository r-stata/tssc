*! 1.0.2 NJC 11 April 2015
* 1.0.1 NJC 9 April 2015
* 1.0.0 NJC 19 March 2015
program localp 
	version 10 
	syntax varlist(min=2 max=2 numeric) [fweight aweight] [if] [in] ///
	[, Kernel(str) BWidth(str) DEGree(int 1) AT(str) Msymbol(str)   ///
	GENerate(passthru) * ] 

	tokenize "`varlist'"
	args yvar xvar 

	if "`kernel'" == "" local kernel "biweight"
	
	if "`bwidth'" == "" { 
		su `xvar' `if' `in', meanonly
		local bwidth = 0.2 * (r(max) - r(min))
		local factor = 10^floor(log10(`bwidth')) 
		local bwidth = floor(`bwidth' / `factor') * `factor' 
	} 

	if "`at'" == "" local at `xvar' 

	quietly { 
		tempvar ypred

		lpoly `yvar' `xvar' `if' `in' [`weight' `exp'], ///
		k(`kernel') bw(`bwidth') at(`at') deg(`degree') ///
		nograph gen(`ypred') 

		reg `yvar' `ypred' [`weight' `exp'] 
		local rsq  : di %04.3f `e(r2)'
		local rmse : di %5.4g `e(rmse)' 
		if c(stata_version) < 11 {
			local text "R-sq = `rsq', RMSE = `rmse'" 
		}
		else local text "{it:R}{sup:2} = `rsq', RMSE = `rmse'"
	} 

	if "`msymbol'" == "" local msymbol "Oh" 

	local word : word `= `degree' + 1' of ///
	mean linear quadratic cubic quartic quintic 
	if "`word'" != "" local title "local `word' smooth" 
	else local title "local polynomial smooth" 

	lpoly `yvar' `xvar' `if' `in' [`weight' `exp'],           ///
	k(`kernel') bw(`bwidth') at(`at') deg(`degree')           ///
	msymbol(`msymbol') `generate'                             ///
	subtitle("`text'", size(medsmall) place(w))               ///
	title(`title', size(medium) place(w)) yla(, ang(h)) `options' 
end 
 
