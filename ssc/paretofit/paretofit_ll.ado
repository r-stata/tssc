*! paretofit_ll.ado, 0.0.1, Stephen P. Jenkins & Philippe Van Kerm, 2007-03-14
*! Called by paretofit.ado
program define paretofit_ll
	version 8.2
	args lnf a 
	quietly replace `lnf' = ln(`a') - (`a'+1)*ln($S_mlinc) + (`a')*ln($S_x0)  
end

