*! NJC 1.0.0 6 Nov 2003 
program gammafit_lf
	version 8.1
	args lnf alpha beta 
	qui replace `lnf' = ///
	-(`alpha') * ln(`beta') - lngamma(`alpha') ///
	+ (`alpha' - 1) * ln($S_MLy) - ($S_MLy / `beta') 
end 		
