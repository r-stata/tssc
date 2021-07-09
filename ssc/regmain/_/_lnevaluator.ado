program _lnevaluator
version 12.0
	args lnf beta sigma
	qui replace `lnf'=  -((ln($ML_y1) - `beta')^2)/(2*`sigma'^2) - ln(`sigma') - .5*ln(2*_pi) - ln($ML_y1 ) 
end
