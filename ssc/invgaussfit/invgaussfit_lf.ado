*! NJC 1.0.0 7 Dec 2006 
program invgaussfit_lf
	version 8.1
	args lnf mu lambda 
	qui replace `lnf' = ///
	0.5 * ln(`lambda') - ln(2 * _pi) - 3 * ln($S_MLy) ///
	- (`lambda'/(2 * `mu'^2 * $S_MLy) * ($S_MLy - `mu')^2)
end 		
