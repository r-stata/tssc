*! NJC 1.0.0 7 Nov 2003 
program gumbelfit_lf
	version 8.1
	args lnf alpha xi 
	qui replace `lnf' = ///
	-ln(`alpha') - (($S_MLy - `xi') / `alpha') - exp(-($S_MLy - `xi')/`alpha')
end 		
