   // Take consecutive states, in wide format, return a matrix of
   // per-period transition probabilities
   // Default to 7-wide moving average window

   capture program drop maketrpr
   
program define maketrpr, rclass
   syntax varlist(min=2), MATrix(string) [MA(int 3)]
   tempvar month idvar statenext tvar n rowtot of ofma block js 
   
   preserve
   
   gen `idvar'=_n
   
   qui ds `varlist'
   local expvars `r(varlist)'
   local expvar1: word 1 of `expvars'
   
   local state = regexr(`"`expvar1'"',"[0-9]+$","")

   // Reshape into long format
   reshape long `state', i(`idvar') j(`tvar')
   
   // Generate the "next" state
   by `idvar': gen `statenext' = `state'[_n+1]
   /* keep if !missing(sl) */
   
   // Reduce to m_i times m_{i+1} times time-var cases
   sort `tvar' `state' `statenext'
   keep if !missing(`statenext')
   gen `n' = 1
   collapse (sum) `n', by(`tvar' `state' `statenext')
   fillin `tvar' `state' `statenext'
   replace `n' = 0 if _fillin
   
   // Generate raw outflow
   by `tvar' `state': egen `rowtot' = sum(`n')
   gen `of' = `n'/`rowtot'
   
   // sort into consecutive time-series within m_i times m_{i+1} blocks
   sort `state' `statenext' `tvar'
   
   // Moving average
   qui su `state'
   local nels r(max)
   return scalar nstates = `nels'

   gen `block' = (`state'-1)*`nels' + `statenext'
   gen `js' = `tvar'*`nels' + `state'
   su `block' `tvar'
   tsset `block' `tvar'
   if (`ma'==1) {
      gen `ofma' = `of'
      }
   else {
      tssmooth ma `ofma'=`of', window(`ma' 1 `ma')
      }
   
   drop _fillin `block'
   reshape wide `n' `of' `ofma', i(`js') j(`statenext')
   mkmat `ofma'*, matrix(`matrix')
   
   restore
end
   
