*! version 2.2.0 10nov2016 daniel klein

pr guttmanl // , rclass
	vers 11.2
	
	tempname g rr
	_ret hold `rr'
	.`g' = .guttmanl_class.new `0'
	_ret res `rr'
	.`g'.guttmanl_main
end
e

2.2.0	10nov2016	new guttmanl_class (1.0.1)
2.1.0	14feb2016	quantile lambda 4 coefficients
					user specified splits in varlist
					additional output
					additional results
					new guttmanl_class.class (1.0.0)
					new lguttmanl.mlib (2.0.0)
2.0.0	27jan2016	first version on SSC
1.0.0	06jan2016	rudimentary version posted to Statalist
