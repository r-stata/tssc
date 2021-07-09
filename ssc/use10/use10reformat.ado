program use10reformat
   version 9.2
   syntax , vformat(string) vname(string) vtype(string) vindex(real) vcount(real) 

   /*
    **************************************************************
     This is a user-changable function for recoding Stata formats
     It is called by use10 for each variable in the dataset
     It receives a string parameter "vformat" - format of the
     variable in the Stata 10 dataset and must return one result:
     local "newformat", which is the format to be used in Stata 9
     dataset. Additionally the procedure receives parameters "vname"
     (name of the variable), "vindex" (variable's index), and "vcount"
     (total number of variables). The procedure will probably never
     have to use them, but they are passed "just in case", e.g. for
     protocolling purposes, as illustrated.

     Default version replaces all date and time formats with a
     numeric format %15.0g, which is exactly what -saveold- in
     Stata does. However, in some cases one can do better and
     preserve at least some date formats.

    ***************************************************************

   */

   if (strpos(`"`vformat'"',"d") | strpos(`"`vformat'"',"t")) {
      global use10_newformat `"%15.0g"'        
   }
   else {
      global use10_newformat `"`vformat'"'
   }
   if (`vindex'==1) {
     display ""
     display as text "{break}{hline}"
     display as text _col(2) `"Variable name"' _col(37) as text "Type" _col(44) `"Format[New Format]"'
     display as text "{hline}"
   }
   display as error `"`=cond(`"`vformat'"'==`"$use10_newformat"'," ","*")'"' ///
           as result `"`vname'"' ///
           _col(37) as text "`vtype'" ///
           _col(44) `"`=cond(`"`vformat'"'==`"$use10_newformat"',`"`vformat'"',`"`vformat'[$use10_newformat]"')'"'
   if (`vindex'==`vcount') display as text "{hline}"

end

/* END OF FILE */