

capture program drop mest
program mest,rclass
version 14
syntax [namelist]  [,   Col(numlist) ] 
tokenize `namelist'
capture mat drop A
capture mat drop E

	mat A=r(table)
		local r=1 
	foreach x in `col' {
	    capture mat drop E`r'
		mat E`r'=J(1,3,.)
		mat E`r'[1,1]= A[1,`x']
		mat E`r'[1,2]= A[5,`x']
		mat E`r'[1,3]= A[6,`x']
		local r=`r' + 1
		
	}





mat E=E1 

local maxc=`r'-1

if `maxc'>1 {
foreach x of numlist 2/`maxc' {
	mat E=E\E`x'
	matrix drop E`x'
}
}

mat colnames E= Estmation Low Up
display _newline(1)"***** Matrix for the the estimation and 95 confidence intervals *****"
mat list E

return matrix coefficient=E
return matrix table=A
end
