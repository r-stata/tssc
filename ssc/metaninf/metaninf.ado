*! 1.0.2 TJS 29 Feb 2004  Saves jackknived estimates
*  1.0.1 TJS 20 Jul 2001
*  1.0.0 TJS 22 May 2001
*! based on: metainf 3.0.0 AT Mar 2000 (STB-56: sbe26.1)

program define metaninf
   version 6.0
   syntax varlist(min=2 max=6 numeric) [if] [in] [, id(varname) noGRAPH /*
     */ LABEL(string) SAVe(string) t1(str) t2(str) Format(str) noTABLE `options' *]
   tokenize `varlist'

*   preserve
  
   local est = "`1'"
   
   if "`label'" != "" {
      parse "`label'", parse("=,")
      while "`1'" != "" {
         cap confirm var `3'
         if _rc != 0 {
            di in re "Variable `3' not defined"
            exit _rc
         }
         local `1' "`3'"
         mac shift 4
      }
   }
   tempvar code
   qui {
      if "`namevar'" != "" {
         local lbnvl : value label `namevar'
         if "`lbnvl'" != ""  { quietly decode `namevar', gen(`code') }
         else {
            gen str10 `code' = ""
            cap confirm string variable `namevar'
            if      _rc == 0 { replace `code' = `namevar' }
            else if _rc == 7 { replace `code' = string(`namevar') }
         }
      }
      else { gen str3 `code' = string(_n) }
      if "`yearvar'" != ""  {
         local yearvar "`yearvar'"
         cap confirm string variable `yearvar'
         if _rc == 7 { local str "string" }
         if "`namevar'" == "" { replace `code' = `str'(`yearvar') }
         else { replace `code' = `code' + " (" + `str'(`yearvar') + ")" }
      }
   }
   local id "`code'"

   preserve


* Dealing with if and in options
   if ("`if'" != "") { qui keep `if' }
   if ("`in'" != "") { qui keep `in' }
   if _N <= 1 { error 2001 }

* Overall estimates
   tempvar so
   qui gen `so' = _n
   qui metan `varlist', nograph `options'
   local ove = $S_1
   local ll  = $S_3
   local ul  = $S_4
   sort `so'

* Meta-analysis estimate omiting one study each step
   tempvar theta setheta ulth llth
   qui sum `1', detail
   local n = _result(1)
   qui {
      gen `theta'   = .
      gen `setheta' = .
      gen `ulth'    = .
      gen `llth'    = .
      label var `theta' "Estimate"
      label var `llth'  "Lower CI Limit"
      label var `ulth'  "Upper CI Limit"
   }

   local i = 1
   tempvar s
   qui gen `s' = _n
   while (`i' <= `n') {
      qui {
         metan `varlist' if `s' != `i', `options' nograph
         sort `so'
         replace `theta' = $S_1 in `i'
         replace `llth'  = $S_3 in `i'
         replace `ulth'  = $S_4 in `i'
      }
      local i = `i' + 1
   }

* Maximum and minimum CI values
   qui sum `llth', detail
   local mnx = r(min)
   qui sum `ulth', detail
   local mxx = r(max)

* Labeling plot
   if "`t2'" == "" { local t2 `""' }
   if "`t1'" == "" { local t1 "Meta-analysis estimates, given named study is omitted" }

* Numeric format
   if "`format'" == "" { local format "%5.2f" }

* Print option
   if "`table'" != "notable" {
      di
      di in gr "------------------------------------------------------------------------------"
      di in gr _col(2) "Study omitted" _col(20) "|" _col(24) "Estimate" _col(39) "[95%  Conf.  Interval]"
      di in gr "-------------------+----------------------------------------------------------"
      local i = 1
      while `i' <= `n' {
         if "`id'" == "" { local a =  `s' in `i' }
         else            { local a = `id' in `i' }
         local b = `theta' in `i'
         local c = `llth'  in `i'
         local d = `ulth'  in `i'
         di _col(2) "`a'" _col(20) in gr "|" in ye _col(24) `b' _col(39) `c' _col(52) `d'
         local i=`i'+1
      }
      di in gr "-------------------+----------------------------------------------------------"
      di _col(2) "Combined" _col(20) in gr "|" in ye _col(24) `ove' _col(39) `ll' _col(52) `ul'
      di in gr "------------------------------------------------------------------------------"
   }

* Display plot
   if "`graph'" != "nograph" {
      mhplot `llth' `theta' `ulth', r sy(|o|) l("`id'") t1(`t1') t2(`t2') /*
        */ f(`format') xline(`ove',`ll',`ul') xlab(`mnx',`ove',`ll',`ul',`mxx') /*
        */ xti(`ove',`ll',`ul') xscale(`mnx',`mxx')
   }

if "`save'" != "" {
   local c = index("`save'",",")
   if `c' != 0 {
     local save = substr("`save'",1,`c'-1) + " " + substr("`save'",`c'+1, .)
   }
   local save1 : word 1 of `save'
   local replace : word 2 of `save'
   if "`replace'" == "replace" { 
     capture drop `save1'
   }
   capture confirm new var `save1'
   if _rc {
     local rc = _rc
     di in re "`save1' exists. Use 'replace' option: save(save_var, replace)."
     exit `rc'
   }
   qui {
      gen `save1' = `theta'
      sort `id'
      tempfile saved
      save `saved'
      restore
      sort `id'
      merge `id' using `saved', keep(`save1') update replace nokeep
      drop if _merge==2
     drop _merge
   }
   label var `save1' "jackknifed `est' (metaninf)"

end
