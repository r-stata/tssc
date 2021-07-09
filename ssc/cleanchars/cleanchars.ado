

*! -----------------------------------------------------------------------------------------------------
*! vs1.0 Lars Aengquist , 2013-10-08
*!
*! program cleanchars
*!
*!	syntax	[anything]	,	in(string) [out(string)	vname vlab vval values lower]								
*!
*! -----------------------------------------------------------------------------------------------------



program cleanchars

	syntax	[anything]	,	in(string) [out(string) vname vlab vval values lower]			
					

   version 10


	   * -----------------------------  
	   * - Initializations of defaults
	   * -----------------------------

   if "`vname'`vlab'`vval'`values'"=="" {								
      local vname="vname"
      local vlab="vlab"
      local vval="vval"
      local values="values"
   }


	   * --------------------------------------------  
	   * - Check that 'in' and 'out' inputs seem OK.
	   * --------------------------------------------
	

   local m=wordcount("`in'")						
   local n=wordcount("`out'")

   if `m'!=`n' & `n'>1 {

      display as error "If 'out' holds >1 strings then this number must equal the number in 'in'!!!"
      display _newline
 
      error 198
   }

	   * -----------------------------------  
	   * - Changing strings based on options
	   * -----------------------------------

   if "`vlab'"!="" {								//	replace: variable labels

      forvalues i=1/`m' {

         local a=word("`in'",`i')

         if `n'>1 {
            local b=word("`out'",`i')
         }
         else if `n'==1 {
           local b=word("`out'",1)
         }
         else if `n'==0 {
           local b=""
         }
         
         foreach var of varlist _all {							
            local tmp : var label `var'    
            local tmp=subinstr("`tmp'","`a'","`b'",.)   
            label var `var' "`tmp'"
         }
      }
   }


   if "`vval'"!="" {								//	replace: variable values (string variables only)

      ds _all , has(type string)
      local strvars "`r(varlist)'"

      forvalues i=1/`m' {

         local a=word("`in'",`i')

         if `n'>1 {
            local b=word("`out'",`i')
         }
         else if `n'==1 {
           local b=word("`out'",1)
         }
         else if `n'==0 {
           local b=""
         }
         
         foreach strvar of local strvars{					
            replace `strvar'=subinstr(`strvar',"`a'","`b'",.)
         }
      }
   }


   if "`values'"!="" {								//	replace: value labels (names + levels)

      forvalues i=1/`m' {

         local a=word("`in'",`i')

         if `n'>1 {
            local b=word("`out'",`i')
         }
         else if `n'==1 {
           local b=word("`out'",1)
         }
         else if `n'==0 {
           local b=""
         }
         
         foreach var of varlist _all {							

            local tmp : val label `var'    

            display "`var': `tmp'"

            if "`tmp'"!="" {

               local newlbl=subinstr("`tmp'","`a'","`b'",.)   				//	...names

               label list `tmp'
               local min=r(min)
               local max=r(max)

               forvalues i=`min'/`max' {
  
                  local lvl : label `tmp' `i'						//	...levels
                  local lvl=subinstr("`lvl'","`a'","`b'",.)   
  
                  if "`lvl'"!="`i'" {
                     label def `newlbl' `i' "`lvl'" , modify
                  }
               }

               label val `var' `newlbl'

               if "`tmp'"!="`newlbl'" {
                  local dropvars "`dropvars' `tmp'"
               }
            }
         }
         capture noisily label drop `dropvars'
      }
   }



   if "`vname'"!="" {								//	replace: variable names

      forvalues i=1/`m' {

         local a=word("`in'",`i')

         if `n'>1 {
            local b=word("`out'",`i')
         }
         else if `n'==1 {
           local b=word("`out'",1)
         }
         else if `n'==0 {
           local b=""
         }
         
         renvars _all , subst("`a'" "`b'")						
      }
   }


   if "`lower'"!="" {									
      renvars , lower								//	to lower case		
   }

end



