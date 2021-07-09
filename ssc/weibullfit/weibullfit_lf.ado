*! NJC 1.0.0 9 Nov 2007 
program weibullfit_lf
	version 8.1
	args lnf b c 
	qui replace `lnf' = ///
	ln(`c') - ln(`b') + (`c' - 1) * (ln($S_MLy) - ln(`b')) - ($S_MLy / `b')^`c' 
end 		
