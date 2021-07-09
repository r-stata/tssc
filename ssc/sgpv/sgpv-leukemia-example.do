*!leukemia-example.do
*!Example code how to calculate SGPVs and Bonus Statistics for the leukemia dataset without modifying the existing code.
*!The leukemia dataset does not contain missing values/ rows or columns with no usuable information
*!You have to make sure that this condition holds for your own large matrix or dataset.
preserve
sysuse leukstats, clear
sort p_value // To show the results the same way they are shown in the example for plotsgpv
mata: final =J(1,5,.)
* Partition the observations into chunks of the size of c(matsize), the maximum allowed matrix size
forvalues i=1/`=ceil(_N/c(matsize))'{
	tempname part`i' res`i' final
	* Get the start and end observations of the variables
	local start = (`i'-1)*c(matsize)+1
	local end = `i'*c(matsize)
	if `end'>`=_N' local end l
	mkmat estimate se  t_stat p_value ci_lo ci_hi in `start'/`end', matrix(`part`i'')
	mat `part`i'' = `part`i'''
	mat rownames `part`i'' = b se t pvalue ll ul
	qui sgpv,m(`part`i'') 
	mat `res`i'' = r(comparison)
	mata: res=st_matrix("`res`i''")
	mata: final= final \ res
} 
mata: st_matrix("`final'",final)

matlist `final' ,title("Comparison of ordinary P-Values and Second Generation P-Values") rowtitle(Variables)
mat leukemia_result = `final'
restore

