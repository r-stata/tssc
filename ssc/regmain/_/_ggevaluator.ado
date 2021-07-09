program _ggevaluator
version 12.0
	args lnf beta sigma p
	tempvar t d eps a
	qui gen double `a' = 1/`sigma'
	qui gen double `eps' = ln($ML_y1) - `beta'
	qui gen double `t' = ln(`a') + `a'*`p'*`eps' - exp(`a'*`eps')
	qui gen double `d' = lngamma(`p')
	qui replace `lnf'=  `t' - `d' - ln($ML_y1 )
end
