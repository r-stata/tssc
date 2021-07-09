*! NJC 1.0.0 15 Dec 2006 
program invgammafit_lf
	version 8.1
	args lnf alpha beta 
	qui replace `lnf' = ///
	-(`alpha' + 1) * ln($S_MLy) - (`beta' / $S_MLy) ///
	- (lngamma(`alpha') -`alpha' * ln(`beta'))
end 		
