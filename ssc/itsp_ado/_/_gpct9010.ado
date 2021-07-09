

*! _gpct9010 v1.0.1  CFBaum 11aug2008
	program _gpct9010 
	version 10.1
	syntax newvarname =/exp [if] [in] [, *]
	tempvar touse p90 p10
	mark `touse' `if' `in'
	quietly { 
		egen double `p90' = pctile(`exp') if `touse', `options' p(90)
		egen double `p10' = pctile(`exp') if `touse', `options' p(10)
		generate `typlist' `varlist' = `p90' - `p10' if `touse'
	}
end
