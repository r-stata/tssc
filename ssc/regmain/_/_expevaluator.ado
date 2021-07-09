program _expevaluator
version 12.0
	args lnf beta 
	tempvar eps
	qui gen double `eps' = ln($ML_y1) - `beta'
	qui replace `lnf'= `eps' - exp(`eps')
end
