*! cisd1 ver 1.1 15Jan2014
*! Estimates standard deviation with confidence interval
*! from one sample from the normal distribution.
*! Authors: Morten Frydenberg, Svend Juul, Dept. of Public Health, Aarhus University

program cisd1 
version 11
syntax varlist(min=1 max=1 numeric) [if] [in] [, Level(cilevel) Zero]

if "`level'" == "" {
   local level = c(level)
}

quietly summarize `varlist' `if' `in'

if "`zero'" != "" {
   local SD = sqrt(((r(N)-1)*r(sd)^2+r(sum)*r(mean))/r(N))
   local DF = r(N)
}
else {
   local SD = r(sd)
   local DF = r(N)-1
}
  
local LOW    = `SD'*sqrt(`DF'/invchi2(`DF',(100+`level')/200))
local HIGH   = `SD'*sqrt(`DF'/invchi2(`DF',(100-`level')/200))

display
if "`zero'" != "" {
   display as res "Assuming mean zero"
}

display as res "SD(`varlist'): " `SD'
display as res "(`level'% CI: " `LOW' " ; " `HIGH'   " ) "

if "`zero'" != "" {
   display
   display as res "If  `varlist'  is the difference between two exchangeable"
   display as res "variables having the same mean and SD (same measurement error):"
   display as res "SD(measurement error): " `SD'/sqrt(2)
   display as res "`level'% CI: ( " `LOW'/sqrt(2) " ; " `HIGH'/sqrt(2)  " ) "
}	

end
