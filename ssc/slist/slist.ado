*! slist.ado  writes smart lists as compact as possible.
*! slist is a modification by Svend Juul of wlist.ado by John Gallup and Jens M. Lauritsen, July 2001
*! 2.0   11mar2003   Svend Juul   sj@ph.au.dk + John Gallup and Jens M. Lauritsen
*! 3.0   10apr2020   Svend Juul - Now also working with Unicode

program define slist
  syntax [varlist] [if] [in] [, Label noObs Decimal(numlist >=0) Id(varlist) ]
  version 11      // Also tested with version 16

  if c(stata_version)>13.9 {    // Unicode?
     local u = "u"
  }

  preserve                      // Modifications to data are temporary

  if "`varlist'" != "" { 
     local varlist `id' `varlist'
  }
  quietly compress `varlist'

* value labels are not shown by default 
     if "`label'" == "" {
        local nolabel "nolabel"
     }
     else {
        local nolabel ""
     } 
	 
* NEEDED WIDTH FOR EACH VARIABLE. MODIFY FORMAT
foreach V of local varlist {                  // V: variable name 
     local T : type `V'                       // T: variable type 
     local F : format `V'                     // F: format (string, date, time) 
	 local FT
     local SIGN = 1                           // SIGN: Sign in format
     if index("`F'","-") {
        local SIGN = -1
     }
     local WN = `u'strlen("`V'")              // WN: Width variable name
	 
     * If labels are shown, then modify WN with max length of label
     if "`nolabel'" == "" {
        local WVL : label (`V') maxlength     // WVL: length of longest value label
        local WN=max(`WN',`WVL')              // WN: Max length of name or value label
     }

     * STRING FORMATS: 
     if index("`T'","str") {  
        local WD = real(`u'substr("`T'",4,.))    // WD: Data width
        local W = `SIGN' * max(`WD',`WN')        // W: Max width name, data
        format `V' %`W's                         // String format
     }  // End string formats

     * FLOATING POINTS: 
     if inlist("`T'","float","double") {
        if "`decimal'" == "" {                      // DECIMALS NOT SPECIFIED
           local WD = 9 + (inlist("`T'","double"))
           local W = `SIGN' * max(`WD',`WN')        // Max width name, data
           format `V' %`W'.0g                       // General format
        }
        else {                                      // DECIMALS SPECIFIED
           summarize `V' `if' `in' , meanonly
           if "`r(min)'" == "" {
              local W1 = 1
           }
           else {
              local W1 = abs(int(`r(min)'))
              local W1 = `u'strlen("`W1'") + (`r(min)'<0)
	       }

           if "`r(max)'" == "" {
              local W2 = 1
           }
           else {
              local W2 = int(`r(max)')
              local W2 = `u'strlen("`W2'")
           }
           local WD = max(`W1',`W2') + `decimal' + (`decimal'>0)
           if `WD' < max(11,`WN') {
              local W = `SIGN' * max(`WD',`WN')     // Max width name, data
              format `V' %`W'.`decimal'f            // Fixed format
           }
           else {
              local W = `SIGN' * max(10,`WN')       // LARGE NUMBERS:
              format `V' %`W'.0g                    // General format
           }
        }
     } // End floating points

     * INTEGERS:
     if inlist("`T'","byte","int","long") {
        summarize `V' `if' `in' , meanonly
        if "`r(min)'" == "" {
           local W1 = 1
        }
        else {
           local W1 = `u'strlen("`r(min)'")
        }
 
        if "`r(max)'" == "" {
           local W2 = 1
        }
        else {
           local W2 = `u'strlen("`r(max)'")
        }

        local W = `SIGN' * max(`W1',`W2',`WN')      // Max width name, data
        format `V' %`W'.0f                          // Integer format
     } // End integers
	 
     * DATE AND TIME FORMATS
     if strpos("`F'", "%t") | strpos("`F'", "%d") {
	 	local WD = strlen(string(-1,"`F'"))
		local W = max(`WD',`WN')
		format `V' `F'
	 } // End date and time formats.

  } // End foreach V of varlist

* Following: slightly modified from wlist.ado (John Gallup, Jens M. Lauritsen)
* REMOVE ID VARIABLES FROM VARLIST?
   if "`id'" != "" {
      local outlist ""
      foreach idvar of local id {
         foreach avar of local varlist {
            if "`idvar'" !="`avar'" {
               local outlist "`outlist'`avar' "
            }
         }  // Now id variable has been cut out of varlist
         local varlist "`outlist'"
         local outlist ""
      }
   } 

* GENERATE LIST
   Varwidth `varlist', `obs' id(`id')
   local pages `r(pages)'
   forvalues p = 1/`pages' {
      local varlist`p' `"`r(varlist`p')'"'
      list `id' `varlist`p'' `if' `in', nodisplay `nolabel' `obs' clean abbreviate(20)
   }

restore

end  // program slist

****************************************************************************
* Program Varwidth: DETERMINE WIDTH AND PLACEMENT OF VARIABLE COLUMNS
****************************************************************************
program define Varwidth, rclass
   syntax varlist, [noobs id(varlist)]

  if c(stata_version)>13.9 {    // Unicode?
     local u = "u"
  }

   if "`obs'" == ""  {
       local obswidth = `u'strlen(string(_N)) + 3
   }
   else {
       local obswidth = 4    // **************** test
   }

   local totwidth = `obswidth'
   foreach avar of local varlist {
      local fmt : format `avar'
      local n1 = cond(index("`fmt'", "-"),3,2)
      local dotn = index("`fmt'", ".")

      if `dotn' { 
	      local n2 =  `dotn' - `n1' 
	  }
	  else { 
	      local n2 = index("`fmt'", "s") - `n1'
	  }

      if index("`fmt'","%d") | index("`fmt'","%t") {       // date and time
         local varw = `u'strlen(string(-1,"`fmt'"))       // series formats
	  }  
      else {
	      local varw = `u'substr("`fmt '", `n1', `n2')
	  }

      local varw = `varw' + 2
      local widthlist "`widthlist' `varw'"
      local totwidth = `totwidth' + `varw'  // total width of variable columns
   }
   
   local winwidth : set linesize  // get width of user's result window

   * MAKE ROOM FOR ID VARIABLE
   foreach idvar of local id {  // subtract width of id variable   
      local fmt : format `idvar'
      local n1 = cond(index("`fmt'", "-"),3,2)
      local dotn = index("`fmt'", ".")
      if `dotn' {
	      local n2 =  `dotn' - `n1' 
	  }
      else {
	      local n2 = index("`fmt'", "s") - `n1'
	  }
	  
      if index("`fmt'","d") | index("`fmt'","t") {       // date and time
	     local varw = `u'strlen(string(-1,"`fmt'"))         // series formats
	  }
      else { 
	      local varw = `u'substr("`fmt '", `n1', `n2')
	  }
      local varw = `varw' + 2
      local winwidth = `winwidth' - `varw'  // width variable columns minus id field
   }

   * NEW PAGE ?
   if `totwidth' <= `winwidth' {
      local pages 1
      local varlist1 `"`varlist'"'
   }
   else {
      local p 1
      local newwidth = `obswidth' 
      foreach w of local widthlist {
         local newwidth = `newwidth' + `w'
         gettoken avar varlist : varlist

         if `newwidth' <= `winwidth' { 
		     local varlist`p' "`varlist`p'' `avar'"
		 }
         else {
            local p = `p' + 1
            local newwidth = `obswidth' + `w'
            local varlist`p' "`avar'"
         }

	  }
      local pages = `p'
   }

   return local pages `pages'
   forvalues p = 1/`pages' {
       return local varlist`p' "`varlist`p''" 
   }
end // Varwidth

