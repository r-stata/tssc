program _ltevaluator
version 12.0
	args lnf beta sigma q
	tempvar eps num den
	qui gen double `eps' = ln($ML_y1) - `beta'
	qui gen double `num' = -((lngamma(.5) + lngamma(`q') - lngamma(`q' + .5)) + (1/2)*(ln(2) + ln(`q') + 2*ln(`sigma')))
	qui gen double `den' = (`q' + .5)*ln(1 + (`eps'^2)/(2*`q'*`sigma'^2))
	qui replace `lnf'= `num' - `den'
end
