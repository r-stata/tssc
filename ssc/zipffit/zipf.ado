capture program drop zipf
  program zipf
  version 12.1
  args lnf zalpha
	tempname H
	quietly {
	/* calculate the harmonic number */
	egen double `H'=total(1/((MLrankML)^`zalpha'))	
	/* calculate the contribution to log-likelihood */
	replace `lnf'=(-1)*MLfreqML*`zalpha'*log(MLrankML)-MLfreqML*log(`H')
	}
	end
exit