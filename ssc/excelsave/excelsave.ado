*! ------------------------------------------------------------------------------------------------------------------
*! vs1.0 Lars Aengquist , 2012-12-07
*!
*! program excelsave
*!
*!		syntax	[anything] [if] [in]	[,	vars(string) folder(string) match(string) subs(string) xls *]			
*!
*! ------------------------------------------------------------------------------------------------------------------

program excelsave

		syntax	[anything] [if] [in]	[,	vars(string) folder(string) match(string) subs(string) xls *]			
					

   version 12.1


   * - Defaults for folder, (file) matching expression, and sign-replacement

   if "`vars'"=="" {
      local vars="*"
   }

   if "`folder'"=="" {
      local folder="."
   }

   if "`match'"=="" {
      local match="*"
   }


   * - Put matched files in local macro

   local list : dir "`folder'" files "`match'.dta", respectcase


   * - Looping over matched files

   foreach fname of local list {
      use `vars' `if' `in' using "`folder'\\`fname'" , clear 				//	import Stata-dataset (accepts specified varlist and/or if/in-conditions)

      local fnameshort=reverse(substr(reverse("`fname'"),5,.))

      if "`xls'"!="" {
         export excel using "`folder'\\`fnameshort'.xls" , `options' 			//	export Stata --> Excel (xls), preserve excel-options (see 'help import excel')
      }
      else {   
         export excel using "`folder'\\`fnameshort'.xlsx" , `options' 			//	export Stata --> Excel (xlsx; default), preserve excel-options (see 'help import excel')
      }
   }


   * - If option selected, loop over possible subfolders

   if "`subs'"!="" {

      capture local subdirs: dir "`folder'" dirs "`subs'", respectcase

      foreach subdir of local subdirs {

         * - Recursive call...

         excelsave `if' `in' , vars("`vars'") folder("`folder'\\`subdir'") match("`match'") subs("`subs'") `xls' `options'			
      }
   }


end



