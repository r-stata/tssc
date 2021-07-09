  ** mvport package v2
  * holdingrets command 
  * Author: Alberto Dorantes, July, 2016
  * cdorante@itesm.mx
  
capture program drop holdingrets
program define holdingrets, rclass
syntax varlist [if] [in]

tempname matret nrows
   marksample touse
   qui su `varlist' if `touse'
   if r(N)>0 {
   mata:st_view(r=.,.,tokens("`varlist'"), "`touse'")
   mata: matret= r[rows(r),.] :/ r[1,.] - J(1,cols(r),1)
   mata: matret=matret'
   mata:st_matrix("`matret'",matret)
   mata:st_numscalar("`nrows'",rows(r))
   foreach v of varlist `varlist' {
	   local nomvar "`nomvar' `v'"
   } 
   matrix rownames `matret' = `nomvar'
   matrix colnames `matret' = "Return"
   display "It is assumed that the data is sorted chronologically and the variable(s) is(are) price(s)"
   display "The holding return of each price variable for the specified period was:"
   matlist `matret', rowtitle(Price variable) noblank twidth(30) border
   display `nrows' " observations/periods were used for the calculation (casewise deletion was applied)" 
   return matrix holdingrets=`matret' 
   return scalar N=`nrows'
   }

end

