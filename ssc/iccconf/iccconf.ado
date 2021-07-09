*! November 5, 2008 by Paul F. Visintainer, PhD

program define iccconf
version 8.0 
syntax anything [, level(real .95)]
tokenize "`anything'"

local icc `1'
local k `2'      /* number of observations */
local reps `3'


confirm number `icc'
confirm integer number `k'
confirm integer number `reps'

if `icc'<=0 | `icc'>=1 {
    di
    di in red "RE-enter " in ye "ICC" in red " between 0 and 1"
    error 197
    }

if `level' >=1.0 {
   di
   di in red " Confidence level must be between 0 and 1"
   error 197
   }

* Defining the components of the test
local alpha = 1 - `level'
local N = `k'*`reps'
local df1 = `k' - 1
local df2 = `N' - `k'
local F = ((`icc'*`reps') - `icc' + 1)/(1-`icc')
local lFcrit = invF(`df1',`df2',(1-`alpha'/2))
local uFcrit = invF(`df1',`df2',(`alpha'/2))

*Compute confidence limits based on Rosner, "Fundamental of Bios, 6th", pg. 615 

local ul = (`F'/`uFcrit'-1)/(`reps'+(`F'/`uFcrit')-1)
local ll = (`F'/`lFcrit'-1)/(`reps'+(`F'/`lFcrit')-1)


di
di in gr "  ******************************************************************************* "
di in ye "                Confidence Interval for the INTRACLASS COEFFICIENT "
di in gr "  ******************************************************************************* "
di
di in gr "                The ICC with " in ye %3.0f `level'*100 "% " in gr "CI is:   " %3.2f in ye `icc' " (" %3.2f in ye `ll' ", " %3.2f in ye `ul' ")"
di
di in gr "              The number of subjects is: "  %5.0f in ye `k'
di 
di in gr "  The number of repeated assessments is:    " %2.0f in ye `reps'

end
