program define witch
*! version 1.0.1  TJS 19Sep2004
   version 8
   if "`1'" == "" {
     di _n as txt "  Syntax: " in wh "witch" in gr" filename [ " _c
     di in wh ", noa" in gr "ll " in wh "noallt" in gr "ypes ]"
     exit
   }
   syntax anything(name=filename id="file name") [, noAll noALLTypes]
   
   local dot = index("`filename'", ".")
   if `dot' {
      local name = substr("`filename'", 1, `dot'-1)
   }
   else {
      local name = "`filename'"
   }   
 
   if "`all'" != "noall" {
       local a ", all"
       di _n as txt "If more than one file of a type, first listed is active..."
   }    
  
   if `dot' {
       if "`all'" == "noall" di " "
       which `filename'`a'
       exit
   }
   if "`alltypes'" == "noalltypes" { 
       if "`all'" == "noall" di " "
       which `name'`a'
   }
   else {
     local type ".ado .hlp .dlg .idlg .class .scheme .style"
     local err 1
     foreach ext of local type {
       cap which `name'`ext'
       if _rc == 0 {
         di _n as txt "----- `ext' -----"
         if "`all'" == "noall" di " "
         which `name'`ext'`a'
         local err 0
       }
     }
     if `err' == 1 {
       di as err "file `name'.* not found along adopath"
       di in bl "r(111);"
     } 
   }
end
exit
