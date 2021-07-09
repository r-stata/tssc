program _gb2evaluator
version 12.0
	args lnf beta sigma p q
	tempvar a eps top bottom
	qui gen double `a' = 1/`sigma'
	qui gen double `eps' = ln($ML_y1 ) - `beta'
	qui gen double `top' = ln(`a') + `eps'*`a'*`p'
	qui gen double `bottom' = lngamma(`p') + lngamma(`q') - lngamma(`p' + `q') + (`p'+`q')*ln(1 + exp(`a'*`eps'))
	qui replace `lnf' = `top' - `bottom' - ln($ML_y1 )
	
	
	
end
