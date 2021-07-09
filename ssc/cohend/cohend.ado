capture program drop cohend
*! Cohen's D v1.0.1 DRTannenbaum 12Sept2013 . 
program define cohend, rclass byable(recall)
version 9.1

syntax varlist(min=2 max=2 numeric) [if] [in]

*ENSURES N > 0
     marksample touse
     quietly count if `touse'
     if `r(N)' == 0 {
          error 2000
     }

quietly ttest `1' if `touse', by(`2')
     
*Define temporary variables
local res num1 denom1 num2 denom2 dvalue effeciency dcorrected gcorrected rvalue gvalue rcorrected
tempname `res'

	scalar `num1' = (r(N_1)+r(N_2))/2
	scalar `denom1' = 2/((1/r(N_1))+(1/r(N_2)))
	scalar `dvalue' = (2*r(t))/(sqrt(r(df_t)))
	scalar `gvalue' = (2*r(t))/(sqrt(r(N_1)+r(N_2)))
	scalar `effeciency' = sqrt(`num1'/`denom1')
	scalar `dcorrected' = `dvalue'*`effeciency'
	scalar `gcorrected' = `gvalue'*`effeciency'
	scalar `num2' = r(t)^2
	scalar `denom2' = `num2'+r(df_t)
	scalar `rvalue' = r(t)/(sqrt(`denom2'))
	scalar `rcorrected' = `gvalue'/(sqrt((`gvalue'^2)+(4*(`num1'/`denom1'))*(r(df_t)/(r(N_1)+r(N_2)))))
	
*Displays Results
di ""
display as result "(1) Cohen's {it:d} and (2) Cohen's {it:d} corrected for uneven groups"
di ""
di as txt "(1) "`dvalue'
di as txt "(2) " `dcorrected'
di ""
di ""
display as result "(3) Hedges' {it:g} and (4) Hedges' {it:g} corrected for uneven groups"
di ""
di as txt "(3) " `gvalue'
di as txt "(4) " `gcorrected'
di ""
di ""
display as result "(5) Effect size {it:r} and (6) Effect size {it:r} corrected for uneven groups"
di ""
di as txt "(5) " `rvalue'
di as txt "(6) " `rcorrected'

     return scalar N = r(N)
     return scalar Cd = `dvalue'
     return scalar Cd2 = `dcorrected'
     return scalar Cg = `gvalue'
     return scalar Cg2 = `gcorrected'
     return scalar Cr = `rvalue'
     return scalar Cr2 = `rcorrected'

end
