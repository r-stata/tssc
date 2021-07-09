program tolerance, rclass 
	version 8.2
	syntax varname [if] [in] ///
	[, p(numlist >0.5 <1 max=1) Gamma(numlist >0.5 <1 max=1) ]
	
	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000
	local N = r(N) 

	if "`p'" == "" local p = 0.95 
	if "`gamma'" == "" local gamma = 0.90 
	
	tempname zp chi2 kpg low upp 
	scalar `zp' = invnorm(1 - (1 - `p')/2) 
	scalar `chi2' = invchi2(`N' - 1,1 - `gamma')
	
	noisily su `varlist' if `touse' 
	scalar `kpg' = `zp' * sqrt(1 + 1/`N') * ///
	sqrt((`N' - 1)/`chi2') 
/* sqrt(1 + (`N' - 3 - `chi2')/2/(`N' + 1)) - This is a correction factor that ///
I can't seem to recover.  The constant found with the formula without the correction ///
factor agrees with tabled values */
	scalar `low' = r(mean) - `kpg' * r(sd) 
	scalar `upp' = r(mean) + `kpg' * r(sd) 
	
	di _n as txt "Confidence level     " as res `p' ///
	_n as txt "Coverage probability " as res `gamma' 
	di    as txt "Tolerance multiplier " as res %6.0g `kpg' 
	local LOW = `low' 
	local LOW = trim("`: di `: format `varlist'' `LOW''")  
	local UPP = `upp' 
	local UPP = trim("`: di `: format `varlist'' `UPP''")  
	di as txt    "Tolerance limits     " as res "`LOW', `UPP'"             

	return scalar kpg = `kpg' 
	return scalar low = `low' 
	return scalar upp = `upp' 
end
