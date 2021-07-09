*! Adding the missing data labels to all of the variables
program define labelmiss
   version 7
   syntax anything , modify
   
   * syntax: varlist label list
   * vefifying `anything' really contains the labels

   * strip anything into varlist and label list

   local done 0
   local lablist `anything'
   
   while `"`lablist'"' ~= `""' {
     gettoken mval lablist : lablist
     if index("`mval'",".") {
       * this is a missing value
       local done 1
       * and the next token is the accompanying label
       gettoken mlab lablist : lablist , parse(`"""')
       local labline `labline' `mval' "`mlab'"
     }
     else {
       * this is not a missing value; either a part of varlist if ~`done',
       * or a desired label if `done', or an option
       if ~`done' {
         * not `done' yet, so it is a part of varlist
         local varlist `varlist' `mval'
       }
       else {
         * we are `done' with varlist, yet this is not a dot
         * may be it is an option?
         if index("`mval'",",") {
            * yes, it has a comma, so it must be an option
            local 0 `mval' `lablist'
            * never, ever do that in your programs!
            
            continue, break
         }
         else {
           di as err "Something unexpected happened; check your syntax"
           di "mval: `mval'; lablist: `lablist'"
           exit 198
         }
       }
     }

   }
   
*   syntax , modify
   
   if "`varlist'" == "" { 
     local varlist _all
   }
   
   local misslab : label misslab maxlength
   if `misslab' {
      * already defined!
      di as text "Warning: redefining the value label misslab"
      label drop misslab
   }
   
   lab def misslab `labline'
   
   foreach x of varlist `varlist' {
      * verify numeric
      cap confirm numeric variable `x'
      if _rc {
        di as text "Warning: `x' is not a numeric variable, skipping"
        continue
      }
      
      * getting the current label
      local vallab : value label `x'
      if "`vallab'" == "" {
         * default label
         lab val `x' misslab
      }
      else {      
         if "`vallab'" == "misslab" {
           * already misslab, do nothing
           di as text "Warning: `x' is already labelled with misslab"
         }
         else {
           * updating the label
           lab def `vallab' `labline', `modify'
         }
      }
   }
   
end
