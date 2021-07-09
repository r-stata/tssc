//Copyright 2007 by Daniel Lawson
program bitobit_ll
	args lnf Rhat Dhat sigmaR sigmaD rho
	quietly replace `lnf' = ln(normden($ML_y2,`Dhat',`sigmaD')*normden($ML_y1,`Rhat'+`sigmaR'/`sigmaD'*(2/_pi*atan(`rho'))*($ML_y2-`Dhat'),`sigmaR'*sqrt(1-(2/_pi*atan(`rho'))^2)))  if $bitobit_1censor == 0 & $bitobit_2censor == 0
	quietly replace `lnf' = ln(normden($ML_y1,`Rhat',`sigmaR')*(1-norm(($ML_y2-`Dhat'-(2/_pi*atan(`rho'))*`sigmaD'/`sigmaR'*($ML_y1-`Rhat'))/(`sigmaD'*sqrt(1-(2/_pi*atan(`rho'))^2))))) if  $bitobit_1censor == 0 & $bitobit_2censor == 1
	quietly replace `lnf' = ln(normden($ML_y2,`Dhat',`sigmaD')*(1-norm(($ML_y1-`Rhat'-(2/_pi*atan(`rho'))*`sigmaR'/`sigmaD'*($ML_y2-`Dhat'))/(`sigmaR'*sqrt(1-(2/_pi*atan(`rho'))^2))))) if  $bitobit_1censor == 1 & $bitobit_2censor == 0
	quietly replace `lnf' = ln(normden($ML_y1,`Rhat',`sigmaR')*(norm(($ML_y2-`Dhat'-(2/_pi*atan(`rho'))*`sigmaD'/`sigmaR'*($ML_y1-`Rhat'))/(`sigmaD'*sqrt(1-(2/_pi*atan(`rho'))^2))))) if  $bitobit_1censor == 0 & $bitobit_2censor == -1
	quietly replace `lnf' = ln(normden($ML_y2,`Dhat',`sigmaD')*(norm(($ML_y1-`Rhat'-(2/_pi*atan(`rho'))*`sigmaR'/`sigmaD'*($ML_y2-`Dhat'))/(`sigmaR'*sqrt(1-(2/_pi*atan(`rho'))^2))))) if  $bitobit_1censor == -1 & $bitobit_2censor == 0
	quietly replace `lnf' = ln(binorm(($ML_y1-`Rhat')/`sigmaR'*(-$bitobit_1censor),($ML_y2-`Dhat')/`sigmaD'*(-$bitobit_2censor),(2/_pi*atan(`rho')))) if $bitobit_1censor != 0 & $bitobit_2censor != 0
end
