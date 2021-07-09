*! nlabel.ado v 1.0.3 20jul05 fw
*! keywords: label tlabel note clabel
program define nlabel
   syntax varname [, Label(string) Add(string) Note(string asis) Vlabel(string) /// 
      Shortlabel(string) Tlabel(string) CLear CTlabel Uselabel]
   if "`uselabel'" != "" {
   cap local label: variable label `varlist' 
   }
   if "`label'" != "" {
      lab var `varlist' "`label'"
   }
   if "`clear'" == "clear" {
      char `varlist'[tlabel] ""   
      char `varlist'[varname] ""      
   }      
   if "`add'" != ""  & "`label'" != "" & "`tlabel'" ==""{
      char `varlist'[tlabel] "`label' `add'"
   }
   if "`tlabel'" != "" {
      char `varlist'[tlabel] "`tlabel'"
   }
   if "`tlabel'" == "" & "`add'" == "" & "`ctlabel'" == "ctlabel" {
      char `varlist'[tlabel] "`label'"
   }
   if "`note'" != "" {
      cap notes drop `varlist'
      note `varlist' : "`note'"
   }
   if "`vlabel'" != "" {
      cap lab values `varlist' `vlabel'
   }
   if "`shortlabel'" != "" {
      cap char `varlist'[varname] "`shortlabel'"
   }
   if "`label'" == "" & "`note'" == "" & "`vlabel'" == "" & "`shortlabel'" == "" /// 
      & "`tlabel'" == "" { 
      di as text "variable: " as result "`varlist'" as text " label: " as result "`:variable label `varlist'' " as text "tlabel: " as result "`:char `varlist'[tlabel]' " as text "clabel: " as result "`:char `varlist'[varname]' " as text "value label: " as result "`:value label `varlist'' 
      local notenum: char `varlist'[note0]'
      if "`notenum'" != "" {
         di as result "Notes on" _c 
         notes `varlist'
      }
   }
end

   