

capture program drop mtab2
program mtab2,rclass
version 14
syntax varlist(min=2 max=2)  [if] [in] [, Row  Col NOLabel Missing]
marksample touse, strok novarlist
tokenize `varlist'
capture mat drop R
capture mat drop C
capture mat drop F
capture mat drop P
capture mat drop rowP
capture mat drop colP

	
if "`row'"=="row"  {
      if "`nolabel'"=="nolabel" & "`missing'"=="missing" {
		    tab `1' `2' if `touse', matcell(F) row nol missing 
			qui tab `1' `2' if `touse', matcell(F) row nol missing  chi exact
			local pp =r(p)
			local ppp: display  round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display  round(`fp', 0.0001)
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			qui tab `1' if `touse', matcell(R) missing 
			local rNN=r(N)
			qui tab `2' if `touse', matcell(C) missing 
			local cNN=r(N)
	}
	
	if "`nolabel'"=="nolabel"  & "`missing'"=="" {
		    tab `1' `2' if `touse', matcell(F) `option' nolabel 
			qui tab `1' `2' if `touse', matcell(F) `option' nolabel chi exact
			local pp =r(p)
			local ppp: display  round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display  round(`fp', 0.0001)
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			capture confirm numeric variable `2'
			if _rc==0 {
					   qui tab `1' if `touse' & `2'!=., matcell(R) 
			}
			if _rc!=0 {
						qui tab `1' if `touse' & `2'!="", matcell(R) 
			}
			local rNN=r(N)
			capture confirm numeric variable `1'
			if _rc==0 {
					   qui tab `2' if `touse' & `1'!=., matcell(C) 
			}
			if _rc!=0 {
						qui tab `2' if `touse' & `1'!="", matcell(C) 
			}
			local cNN=r(N)
	}
	if "`nolabel'"==""  & "`missing'"=="missing" {
			tab `1' `2' if `touse', matcell(F) `option' missing
			qui tab `1' `2' if `touse', matcell(F) `option' missing chi exact
			local pp =r(p)
			local ppp: display  round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display  round(`fp', 0.0001)		
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			qui tab `1' if `touse', matcell(R) missing 
			local rNN=r(N)
			qui tab `2' if `touse', matcell(C) missing 
			local cNN=r(N)
	}	
	
	if "`nolabel'"==""  & "`missing'"=="" {
			tab `1' `2' if `touse', matcell(F) `option' 
			qui tab `1' `2' if `touse', matcell(F) `option' chi exact
			local pp =r(p)
			local ppp= round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp=  round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			capture confirm numeric variable `2'
			if _rc==0 {
					   qui tab `1' if `touse' & `2'!=., matcell(R) 
			}
			if _rc!=0 {
						qui tab `1' if `touse' & `2'!="", matcell(R) 
			}
			local rNN=r(N)
			capture confirm numeric variable `1'
			if _rc==0 {
					   qui tab `2' if `touse' & `1'!=., matcell(C) 
			}
			if _rc!=0 {
						qui tab `2' if `touse' & `1'!="", matcell(C) 
			}
			local cNN=r(N)
	}
     
}	

if "`col'"=="col" {
    
    local option "col"
    if "`nolabel'"=="nolabel" & "`missing'"=="missing" {
		    tab `1' `2' if `touse', matcell(F) `option' nol missing 
			qui tab `1' `2' if `touse', matcell(F) `option' nol missing chi exact
			local pp =r(p)
			local ppp: display round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display  round(`fp', 0.0001)
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			qui tab `1' if `touse', matcell(R) missing 
			local rNN=r(N)
			qui tab `2' if `touse', matcell(C) missing 
			local cNN=r(N)
	}
	
	if "`nolabel'"=="nolabel"  & "`missing'"=="" {
		    tab `1' `2' if `touse', matcell(F) `option' nolabel 
			qui tab `1' `2' if `touse', matcell(F) `option' nolabel chi exact
			local pp =r(p)
			local ppp: display round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display  round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			capture confirm numeric variable `2'
			if _rc==0 {
					   qui tab `1' if `touse' & `2'!=., matcell(R) 
			}
			if _rc!=0 {
						qui tab `1' if `touse' & `2'!="", matcell(R) 
			}
			local rNN=r(N)
			capture confirm numeric variable `1'
			if _rc==0 {
					   qui tab `2' if `touse' & `1'!=., matcell(C) 
			}
			if _rc!=0 {
						qui tab `2' if `touse' & `1'!="", matcell(C) 
			}
			local cNN=r(N)
	}
	if "`nolabel'"==""  & "`missing'"=="missing" {
			tab `1' `2' if `touse', matcell(F) `option' missing 
			qui tab `1' `2' if `touse', matcell(F) `option' missing chi exact
			local pp =r(p)
			local ppp: display round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			qui tab `1' if `touse', matcell(R) missing 
			local rNN=r(N)
			qui tab `2' if `touse', matcell(C) missing 
			local cNN=r(N)
	}	
	
	if "`nolabel'"==""  & "`missing'"=="" {
		    tab `1' `2' if `touse', matcell(F) `option'
		    qui tab `1' `2' if `touse', matcell(F) `option' chi exact
			local pp =r(p)
			local ppp: display  round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			capture confirm numeric variable `2'
			if _rc==0 {
					   qui tab `1' if `touse' & `2'!=., matcell(R) 
			}
			if _rc!=0 {
						qui tab `1' if `touse' & `2'!="", matcell(R) 
			}
			local rNN=r(N)
			capture confirm numeric variable `1'
			if _rc==0 {
					   qui tab `2' if `touse' & `1'!=., matcell(C) 
			}
			if _rc!=0 {
						qui tab `2' if `touse' & `1'!="", matcell(C) 
			}
			local cNN=r(N)
	}
     
}		
   
if "`row'"=="row" & "`col'"=="col" {
    
    local option "row col"
    if "`nolabel'"=="nolabel" & "`missing'"=="missing" {
		    tab `1' `2' if `touse', matcell(F) `option' nol missing 
			qui tab `1' `2' if `touse', matcell(F) `option' nol missing chi exact
			local pp =r(p)
			local ppp: display round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			qui tab `1' if `touse', matcell(R) missing 
			local rNN=r(N)
			qui tab `2' if `touse', matcell(C) missing 
			local cNN=r(N)
	}
	
	if "`nolabel'"=="nolabel"  & "`missing'"=="" {
		    tab `1' `2' if `touse', matcell(F) `option' nolabel 
			qui tab `1' `2' if `touse', matcell(F) `option' nolabel chi exact
			local pp =r(p)
			local ppp: display round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			capture confirm numeric variable `2'
			if _rc==0 {
					   qui tab `1' if `touse' & `2'!=., matcell(R) 
			}
			if _rc!=0 {
						qui tab `1' if `touse' & `2'!="", matcell(R) 
			}
			local rNN=r(N)
			capture confirm numeric variable `1'
			if _rc==0 {
					   qui tab `2' if `touse' & `1'!=., matcell(C) 
			}
			if _rc!=0 {
						qui tab `2' if `touse' & `1'!="", matcell(C) 
			}
			local cNN=r(N)
	}
	if "`nolabel'"==""  & "`missing'"=="missing" {
			tab `1' `2' if `touse', matcell(F) `option' missing 
			qui tab `1' `2' if `touse', matcell(F) `option' missing chi exact
			local pp =r(p)
			local ppp: display  round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display  round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			qui tab `1' if `touse', matcell(R) missing 
			local rNN=r(N)
			qui tab `2' if `touse', matcell(C) missing 
			local cNN=r(N)
	}	
	
	if "`nolabel'"==""  & "`missing'"=="" {
		tab `1' `2' if `touse', matcell(F) `option' 
		    qui tab `1' `2' if `touse', matcell(F) `option' chi exact
			local pp =r(p)
			local ppp: display  round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display  round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			capture confirm numeric variable `2'
			if _rc==0 {
					   qui tab `1' if `touse' & `2'!=., matcell(R) 
			}
			if _rc!=0 {
						qui tab `1' if `touse' & `2'!="", matcell(R) 
			}
			local rNN=r(N)
			capture confirm numeric variable `1'
			if _rc==0 {
					   qui tab `2' if `touse' & `1'!=., matcell(C) 
			}
			if _rc!=0 {
						qui tab `2' if `touse' & `1'!="", matcell(C) 
			}
			local cNN=r(N)
	}
}	   
	
if "`row'"=="" & "`col'"==""  {
    
    local option " "
    if "`nolabel'"=="nolabel" & "`missing'"=="missing" {
		    tab `1' `2' if `touse', matcell(F) `option' nol missing 
			qui tab `1' `2' if `touse', matcell(F) `option' nol missing chi exact
			local pp =r(p)
			local ppp: display round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			qui tab `1' if `touse', matcell(R) missing 
			local rNN=r(N)
			qui tab `2' if `touse', matcell(C) missing 
			local cNN=r(N)
	}
	
	if "`nolabel'"=="nolabel"  & "`missing'"=="" {
		    tab `1' `2' if `touse', matcell(F) `option' nolabel 
			qui tab `1' `2' if `touse', matcell(F) `option' nolabel  chi exact
			local pp =r(p)
			local ppp: display round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			capture confirm numeric variable `2'
			if _rc==0 {
					   qui tab `1' if `touse' & `2'!=., matcell(R) 
			}
			if _rc!=0 {
						qui tab `1' if `touse' & `2'!="", matcell(R) 
			}
			local rNN=r(N)
			capture confirm numeric variable `1'
			if _rc==0 {
					   qui tab `2' if `touse' & `1'!=., matcell(C) 
			}
			if _rc!=0 {
						qui tab `2' if `touse' & `1'!="", matcell(C) 
			}
			local cNN=r(N)
	}
	if "`nolabel'"==""  & "`missing'"=="missing" {
			tab `1' `2' if `touse', matcell(F) `option' missing 
			qui tab `1' `2' if `touse', matcell(F) `option' missing chi exact
			local pp =r(p)
			local ppp: display round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			qui tab `1' if `touse', matcell(R) missing 
			local rNN=r(N)
			qui tab `2' if `touse', matcell(C) missing 
			local cNN=r(N)
	}	
	
	if "`nolabel'"==""  & "`missing'"=="" {
		    tab `1' `2' if `touse', matcell(F) `option' 
		    qui tab `1' `2' if `touse', matcell(F) `option' chi exact
			local pp =r(p)
			local ppp: display  round(`pp', 0.0001)
			local fp=r(p_exact)	
			local fpp: display round(`fp', 0.0001)	
			mat Pv=(`ppp', `fpp' \ `pp', `fp') 
			capture confirm numeric variable `2'
			if _rc==0 {
					   qui tab `1' if `touse' & `2'!=., matcell(R) 
			}
			if _rc!=0 {
						qui tab `1' if `touse' & `2'!="", matcell(R) 
			}
			local rNN=r(N)
			capture confirm numeric variable `1'
			if _rc==0 {
					   qui tab `2' if `touse' & `1'!=., matcell(C) 
			}
			if _rc!=0 {
						qui tab `2' if `touse' & `1'!="", matcell(C) 
			}
			
			local cNN=r(N)
	}
}	


mat rownames Pv=RoundedPva ExactPva
mat colnames Pv=Chi2Pvalue FisherPvalue 

    mat list R
	mat list C

	local rn=rowsof(F)
	local cn=colsof(F)
	mat rowP=J(`rn',`cn',.)
	foreach r of numlist 1/`rn' {
	    foreach c of numlist 1/`cn' {
		    mat rowP[`r',`c']=(F[`r',`c']/R[`r',1])*100
		}
	    
	}
	
		mat colP=J(`rn',`cn',.)
	foreach c of numlist 1/`cn' {
	    foreach r of numlist 1/`rn' {
		    mat colP[`r',`c']=(F[`r',`c']/C[`c',1])*100
		}
	    
	}


display _newline(1)"***** Matrix for the frequencies *****"
mat list F, nohalf
display _newline(1)"***** Matrix for the row percentages *****"
mat list rowP, nohalf
display _newline(1)"***** Matrix for the column percentages *****"
mat list colP, nohalf
display _newline(1)"***** report P values both for Pearson's chi-squared test and Fisher's exact test *****"
mat list Pv, nohalf
	return mat frequency=F 
	return mat rowPercent=rowP
	return mat colPercent=colP
	return mat pvalue=Pv


end
