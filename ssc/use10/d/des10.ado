program des10, rclass

   version 9.2

   /* Sergiy Radyakin 2:38 PM 8/19/2008 */

   syntax using/
   capture confirm file `"`using'"'
   if _rc {
     capture confirm file `"`using'.dta"'
     if _rc error 601
     local using `"`using'.dta"'
   }

   mata des10(`"`using'"')

   display ""
   display as text "Contains data from " as result `"`using'"'
   display as text " obs:             " as result `N' _col(60) as result "`comment'"
   display as text "vars:             " as result `K' _col(60) as result "`datetime'"
   display as text "size:             " as result (`width'+4)*`N'

   display as text "{hline}"

   display as text "                                storage  display   value"
   display as text "Variable name                     type   format    label   variable label"
   display as text "{hline}"

   forvalues i=1/`K' {
      display as result          `"`name_`i''"'      ///
              as text   _col(35) `"`type_`i''"'      ///
              as text   _col(42) `"`format_`i''"'    ///
              as text   _col(50) `"`val_label_`i''"' ///
              as result _col(60) `"`var_label_`i''"'
   }
   display "{hline}"

   display as text "Sorted by: " as result `"`sortlist'"'

   return scalar Version   = `version'
   return scalar ByteOrder = `byteorder'
   return scalar N         = `N'
   return scalar K         = `K'
   return scalar width     = `width'
   return local varlist      `varlist'
   return local sortlist     `sortlist'

end
/*      ~~~ END OF FILE ~~~     */
