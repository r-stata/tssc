program _gammaevaluator
version 12.0
	args lnf beta p
	tempvar eps
	qui gen double `eps' = ln($ML_y1) - `beta'
	qui replace `lnf'= `eps'*`p' - exp(`eps') - lngamma(`p')
end
