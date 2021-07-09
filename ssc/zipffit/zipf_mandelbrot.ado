program define zipf_mandelbrot
  version 12.1
  args lnf zmalpha zmbeta
	tempname H
	quietly {
	/* calculate the harmonic number */
	egen double `H'=total(1/((MLrankML+`zmbeta')^`zmalpha'))	
	/* calculate the contribution to log-likelihood */
	replace `lnf'=(-1)*MLfreqML*`zmalpha'*log(MLrankML+`zmbeta')-MLfreqML*log(`H')
	}
end
exit