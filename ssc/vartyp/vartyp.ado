*! version 2.0  26JUL2004
capture program drop vartyp
program define vartyp, rclass
version 8

   syntax [varlist] [, Set(string) List(string)]
   
   if  "`set'" == "" & "`list'" == ""{
      local list = "all"
   }
  
   if "`set'" != "" {
      if "`set'" != "disc" & "`set'" != "cont" & "`set'" != "date" & /*
          */ "`set'" != "id" & "`set'" != "ord" & "`set'" != "clear" & "`set'" != "appx" {
         di in red "Valid types are: disc (discrete), cont (continuous), ord (ordinal), date, id, appx (appendix) clear"
         exit
      }
      if "`set'" == "clear" { 
      	local set = "" 
      }
      di 
      di in ye _col(5) "Variable" _col(20) "Type" _col(30) "Label"
      di in gr _col(5) "{hline 30}
      foreach var of local varlist{
         local lab : variable label `var'
         char `var'[typ] `set'
         di in gr _col(5) "`var'  "  in ye _col(20) "``var'[typ]'" in gr _col(30) "`lab'"
         local vars "`var' `vars'"
      }
   }
   
   if "`list'" != "" {
     di
      if "`list'" != "disc" & "`list'" != "cont" & "`list'" != "date" & "`list'" != "appx" & /*
         */ "`list'" != "id"  & "`list'" != "ord" & "`list'" != "all" & "`list'" != "undef" {
         di in red "Valid types are: disc (discrete), cont (continuous), ord (ordinal), date, id, all, undef"
         exit
      }
     di in ye _col(5) "Variable" _col(20) "Type" _col(30) "Label"
     di in gr _col(5) "{hline 30}
     if "`list'" != "all" & "`list'" != "undef" {
        foreach var of local varlist{
          if "``var'[typ]'" == "`list'"{
             local lab : variable label `var'
             di in gr _col(5) "`var'  "  in ye _col(20) "``var'[typ]'" in gr _col(30) "`lab'"
             local vars "`var' `vars'"
          }
        }
     }
     if "`list'" == "all" {
        foreach var of local varlist{
             local lab : variable label `var'
             di in gr _col(5) "`var'  "  in ye _col(20)  "``var'[typ]'" in gr _col(30) "`lab'"
             local vars "`var' `vars'"
        }
     }
     if "`list'" == "undef" {
        foreach var of local varlist{
          if "``var'[typ]'" == ""{
             local lab : variable label `var'
             di in gr _col(5) "`var'  "  in ye _col(20)  "``var'[typ]'" in gr _col(30) "`lab'"
             local vars "`var' `vars'"
          }
        }
        
     }
   }
   if ("`vars'" == ""){
	return local numvars 0
   }
   return local varlist "`vars'"
end   
   
