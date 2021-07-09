*! Convert a range of an Excel file to a row-vector: Stas Kolenikov
program define xls2row
	syntax name using/ , cellrange(passthru) sheet(passthru) over(varlist numeric min=1 max=1) [verbose scale(real 0)]
	
	preserve
	
	* get the data from Excel
	import excel `"`using'"' , `sheet' `cellrange' clear
	qui destring *, force replace
	if "`verbose'"!="" list
	
	* convert into a row vector
	mata : dta2row( "`namelist'", "`verbose'", `scale' )
	
	restore
	
	* label the resulting matrix
	qui levelsof `over', local( overlist )
	
	cap matrix colnames `namelist' = `overlist'
	if _rc {
		di "{err}Conformability error; see analysis below"
		di "{txt}Levels of {res}`over'{txt}: "_n 
		levelsof `over'
		di "{txt}The current matrix:"
		mat li `namelist'
		exit (503)
	}
	matrix rownames `namelist' = `over'
	matrix coleq    `namelist' = _one
	
	matrix list `namelist'
	
end

mata 

void dta2row( string scalar matname, string scalar verbose, real scalar scale ) {
	st_view( X=., ., .)
	VX = vec( X[,] )
	VX = select( VX, !rowmissing(VX) )	
	if (verbose!="") VX
	if (sum(VX)!=scale ) printf("\n{txt}Sum of values = {res}%10.0g\n\n", sum(VX) )
	if (scale!=0) st_matrix( matname, VX'*scale/sum(VX) )
	else st_matrix( matname, VX' )
}

end // of Mata

exit
