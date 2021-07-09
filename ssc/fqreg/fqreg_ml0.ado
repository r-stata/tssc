program fqreg_ml0
  version 11
	args lnf fit gamma
	tempvar _p
	quietly gen double `_p' = max(0,((1 + `gamma')*(exp(`fit')/(1 + exp(`fit')))-`gamma'))
	quietly replace `lnf' = -10*($ML_y1 - `_p')*(_alpha[1]-(($ML_y1 - `_p')<0))/_N
	end                            
