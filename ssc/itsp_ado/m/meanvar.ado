
*! meanvar v1.0.1  CFBaum 11aug2008
program meanvar
	version 10.1
	args lnf mu1 mu2 sigma1 sigma2
	qui replace `lnf' = ln(normalden($ML_y1, `mu1', `sigma1')) ///
	    if $subsample == 0
	qui replace `lnf' = ln(normalden($ML_y1, `mu2', `sigma2')) ///
	    if $subsample == 1
end
