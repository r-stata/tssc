*! Version date 10nov2008 by Paul F. Visintainer, PhD

program define sampicc
version 8.0
syntax anything [, Alpha(real .05) Power(real .80) Sample(integer 0) Width(real 0) CI]
tokenize "`anything'"

if "`ci'"=="" & `width'>0 {
   di
   di in red "The WIDTH option may only be specified with CI"
   error 197
   }


if "`ci'"=="" {

local p1 `1'   /* the hypothesized value */
local p0 `2'   /* the null value */
local n  `3'   /* the number of replicates */

confirm number `p1'
confirm number `p0'
confirm integer number `n'

   if (`p1'<=0 | `p1'>=1.0) {
   	di in red "P1 must be greater than 0 and less than 1.0"
   	error 197
   	}

   if (`p0'<0 | `p0'>=1.0) {
   	di in red "Re-enter P0 as a number between 0 and .99"
   	error 197
   	}

   local C = (1+`n'*(`p0'/(1-`p0')))/(1+`n'*(`p1'/(1-`p1')))


*To compute sample size:
if `sample' ==0 {
   local num = 2*(invnormal(1-`alpha')+ invnormal(`power'))^2*`n'
   local den = ln(`C')^2*(`n'-1)
   
   if `n'==2 {
       local k = 1.5 +`num'/`den'
       }
   else {
       local k = 1+`num'/`den'
       }
   local intk=round(`k'+.45,1)

   di _newline(2)
   di in gr "  ****************************************************************
   di in ye "     Sample Size Estimate for a Single ICC against a Null Value
   di in gr "  ****************************************************************
   di
   di "   Given:"
   di in gr "                 Hypothesized Value (P1):  " in ye %4.2f `p1'
   di in gr "                         Null Value (P0):  " in ye %4.2f `p0'
   di in gr "                    Number of Replicates: " in ye %4.0f `n'
   di in gr "                             Alpha level:  " in ye %4.2f `alpha'
   di in gr "                                   Power:  " in ye %4.2f `power'
   di  
   di in gr "  ****************************************************************
   di 
   di in gr "                Estimated sample size is:  " in ye `intk'
   di
   di in gr "  ****************************************************************
   }

*To compute power:
if `sample' >0 {
   local est = sqrt(ln(`C')^2*(`n'-1)*(`sample'-1)/(2*`n'))- invnormal(1-`alpha')
   local PWR = round(normal(`est')*100,1)

   di _newline(2)
   di in gr "  ****************************************************************
   di in ye "       Power Estimate for a Single ICC against a Null Value
   di in gr "  ****************************************************************
   di
   di "   Given:"
   di in gr "               Hypothesized Value (P1):  " in ye %4.2f `p1'
   di in gr "                       Null Value (P0):  " in ye %4.2f `p0'
   di in gr "                  Number of Replicates: " in ye %4.0f `n'
   di in gr "                           Alpha level:  " in ye %4.2f `alpha'
   di in gr "                      Specified Sample: " in ye %4.0f `sample'
   di
   di in gr "  ****************************************************************
   di 
   di in gr "                    Estimated power is:  " in ye %3.0f `PWR' "%"
   di
   di in gr "  ****************************************************************
   }
}

*Sample size based on width of confidence interval

if "`ci'"!="" {

   local p1 `1'   /* the hypothesized value */
   local n  `2'   /* the number of replicates */

   confirm number `p1'
   confirm integer number `n'

   if (`p1'<=0 | `p1'>=1.0) {
   di
   di in red "P1 must be greater than 0 and less than 1.0"
   error 197
   }

   if `width'==0 & `sample'==0 {
   di
   di in red "Either the WIDTH or the SAMPLE option must be specified with CI"
   error 197
   }

   if `width'>0 & `sample'==0 {

      local w `width'
      confirm number `w'

      if (`w'<0 | `w'>=1.0) {
   	di in red "Re-enter width as a number between 0 and .99"
   	error 197
   	}

      local cilevel = (1-`alpha')*100

      local k_num = 8*(invnormal(1-`alpha'/2)^2)*(1-`p1')^2*((1+(`n'-1)*`p1'))^2
      local k_den = `w'^2*`n'*(`n'-1)
      local k = .5 + (`k_num'/`k_den')
      local intk = round(`k'+.49,1)

      di _newline(2)
      di in gr "  ****************************************************************
      di in ye "     Sample Size for the Width of a Confidence Interval for ICC
      di in gr "  ****************************************************************
      di
      di "   Given:"
      di in gr "                     Expected Value (P1):  " in ye %4.2f `p1'
      di in gr "                    Number of Replicates: " in ye %4.0f `n'
      di in gr "                                CI level: " in ye %4.0f `cilevel' "%"
      di in gr "                         Specified Width:  " in ye %4.2f `w'
      di
      di in gr "  ****************************************************************
      di 
      di in gr "                Esimtated sample size is:  " in ye %3.0f `intk'
      di
      di in gr "  ****************************************************************
   }

   if `width'==0 & `sample'>0 {
      di
      local w2_num = 8*(invnormal(1-`alpha'/2)^2)*(1-`p1')^2*((1+(`n'-1)*`p1'))^2
      local w2_den = (`sample'-.5)*`n'*(`n'-1)
      local w=sqrt(`w2_num'/`w2_den')

      local cilevel = (1-`alpha')*100

      di _newline(2)
      di in gr "  ****************************************************************
      di in ye "     Sample Size for the Width of a Confidence Interval for ICC
      di in gr "  ****************************************************************
      di
      di "   Given:"
      di in gr "                     Expected Value (P1):  " in ye %4.2f `p1'
      di in gr "                    Number of Replicates: " in ye %4.0f `n'
      di in gr "                                CI level: " in ye %4.0f `cilevel' "%"
      di in gr "                   Specified Sample Size: " in ye %4.0f `sample'
      di
      di in gr "  ****************************************************************
      di 
      di in gr "            Esimtated Width of the CI is:  " in ye %4.3f `w'
      di
      di in gr "  ****************************************************************
   }
}
end
