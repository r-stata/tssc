

capture program drop mtab
program mtab1,rclass
version 14
syntax varlist(min=1 max=1)  [if]  [in] [, NOLabel Missing]

marksample touse, strok novarlist
tokenize `varlist'
capture mat drop F
capture mat drop P


   	
	if "`nolabel'"=="nolabel" & "`missing'"=="missing" {
		    tab `1' if `touse', matcell(F) nol missing 
	}
	
	if "`nolabel'"=="nolabel"  & "`missing'"=="" {
		    tab `1' if `touse', matcell(F) nolabel 
	}
	if "`nolabel'"==""  & "`missing'"=="missing" {
			tab `1' if `touse', matcell(F) missing 
	}	
	
	if "`nolabel'"==""  & "`missing'"=="" {
		tab `1' if `touse', matcell(F) 
	}

mat colnames F=frequencies


	local NN=r(N)
	local rn=rowsof(F)
	mat P=J(`rn',1,.)
	mat colnames P=percentages
	foreach r of numlist 1/`rn' {
	    mat P[`r',1]=(F[`r',1]/`NN')*100
	}

display _newline(1)"***** Matrix for the frequencies *****"
mat list F
display _newline(1)"***** Matrix for the percentages *****"
mat list P
	return mat frequency=F 
	return mat percent=P

capture drop temp

end

