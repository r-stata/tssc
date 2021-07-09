*! ndbci v 1.0.0 fw 8/17/04 Enhanced version of CI for use with exposures.
*! keywords: ci exposure 

program define ndbci, sortpreserve
   version 8.2
   syntax varlist [if], Exposure(string) [Per(integer 1) Format(string) /// 
      Bygroup(varname) Level(integer 95) (Outcome(string) Group(string) ///
      col1(int 0) col2(int 0)]

   local grspace 7
   if "`group'" == "" local group "Group"
   local glength = length("`group'") - 5
   local grspace = `grspace' - `glength'
   cap assert "`per'" == "1" | "`per'" == "10" | "`per'" == "100" | "`per'" == "1000" ///
      | "`per'" == "10000" | "`per'" == "100000"
   if _rc != 0 {
      di in red "Illegal per() specification. Must be 1, 10, 100, 1000, 10000, 100000"
   error 
   }
   local plength = length("`per'")
   local spaces = 6 - `plength'
   
   local cN = 36 + `col1'
   local cmean = 47 + `col2'
   local clb = 58 + `col2'
   local cub = 68 + `col2'
   local ofmt `format'
   if "`format'" == "" local ofmt "%9.2f"
   di
   di in smcl in gr _col(36) "   Years {space `spaces'}  `per' yr   {hline 2}Poisson  Exact {hline 2}"
   #delimit ;
   di in smcl in gr 
   "  Outcome    {c |}  `group'{space `grspace'}Count   Exposure     Rate    [`level'% Conf. Interval]"
   _n "{hline 13}{c +}{hline 63}" ;
   #delimit cr
   
   if "`bygroup'" != ""{
      qui levels `bygroup',local(levels)
   
   foreach cat of local levels {
   if "`if'" == "" qui ci `varlist' if `bygroup' == `cat',exposure(`exposure') level(`level')
   else qui ci `varlist' `if' & `bygroup' == `cat',exposure(`exposure') level(`level')
   local lname: label (`bygroup') `cat'
   local slname = substr("`lname'",1,8)
   
   
   local events = r(mean) * r(N)  // number of cases
   *local N = r(N) / `per'        // patient-time
   local N = r(N)                 // patient-time
   local mean = r(mean) * `per'   // rate in patient-time
   local lb = r(lb) * `per'       // LCI
   local ub = r(ub) * `per'       // UCI      
   if "`outcome'" == "" local outcome `varlist'
   di in smcl in gr %~12s abbrev("`outcome'",12) " {c |}" ///
   _col(16) in yellow %8s "`slname'" ///
   _col(23) %9.0f `events' ///
   _col(`cN') `ofmt' `N' ///
   _col(`cmean') `ofmt' `mean' ///
   _col(`clb') `ofmt' `lb' ///
   _col(`cub') `ofmt' `ub' in gr "`mark'"
   }
   }
   
   else {
   qui ci `varlist' `if',exposure(`exposure') level(`level')
   local events: di %9.0f r(mean) * r(N)   
   local events = r(mean) * r(N)  // number of cases
   local N = r(N)                 // patient-time
   local mean = r(mean) * `per'   // rate in patient-time
   local lb = r(lb) * `per'       // LCI
   local ub = r(ub) * `per'       // UCI
   if "`outcome'" == "" local outcome `varlist'
   di in smcl in gr %~12s abbrev("`outcome'",12) " {c |}" ///
   _col(16) in yellow %8s " All " ///
   _col(23) %9.0f `events' ///
   _col(`cN') `ofmt' `N' ///
   _col(`cmean') `ofmt' `mean' ///
   _col(`clb') `ofmt' `lb' ///
   _col(`cub') `ofmt' `ub' in gr "`mark'"
   }
end
 