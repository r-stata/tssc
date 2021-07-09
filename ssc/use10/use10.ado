program use10, rclass
   /*   By Sergiy RADYAKIN, 31Aug2008   */
   version 9.2
   capture syntax [anything] [if] [in] using/, [saving(string)] [replace] [*]
   
   if _rc {
     capture syntax anything [if] [in] , [saving(string)] [replace] [*]
     local using `anything'
     local anything ""
   }
   capture confirm file `"`using'"'
   if _rc {
     capture confirm file `"`using'.dta"'
     if _rc error 601
     local using `"`using'.dta"'
   }

   capture findfile "use10reformat.ado"
   local use10reformat_path `r(fn)'

   if (`"`saving'"'=="") tempfile file9 
                    else local file9 `"`saving'"'
   if (`"`saving'"'!="") & (`"`replace'"'=="replace") capture erase `"`file9'"'
   capture noisily mata use10(`"`using'"',`"`file9'"')
   if (`version'==114) {
     use `anything' using `"`file9'"' `if' `in', `options'
   }
   else {
     display as result "Warning: file does not conform to Stata-10 specification (file signature 114)"
     use `anything' using `"`using'"' `if' `in', `options'
     if (`"`saving'"'=="") save `"`saving'"', `replace'
   }

   if (`"`saving'"'=="") return local fn `"`using'"'
                    else return local fn `"`saving'"'

end
//END OF FILE
