


*! ----------------------------------------------------------------------------------------------------------------------------
*! vs1.2 Lars Aengquist , 2011-12-22 (fixing version control-based bug, matched subs)
*! vs1.1 Lars Aengquist , 2011-10-25 (based on 'save9' instead of 'save')
*! vs1.0 Lars Aengquist , 2011-09-29 (based on do-file for TB)
*!
*! program use10save9
*!
*!	syntax	[anything]	[,	folder(string) match(string) subs(string) prefix(string) suffix(string) replace newstx]			
*!
*! -----------------------------------------------------------------------------------------------------------------------------



program use10save9

	syntax	[anything]	[,	folder(string) match(string) subs(string) prefix(string) suffix(string) replace newstx]			
					

   version 9


   * - Defaults for folder-to-use and (file) matching expression.

   if "`folder'"=="" {
      local folder="."
   }

   if "`match'"=="" {
      local match="*"
   }


   * - If using new output (sub)directory.

   if "`replace'"=="" {
      capture noisily mkdir "`folder'\\stata9"				//	creates new subdirectory
   }


   * - Put matched file, in selected folder, in local macro (syntax-dependent).

   if "`newstx'"=="" {
      local list : dir "`folder'" files "`match'.dta"
   }
   else {
      local list : dir "`folder'" files "`match'.dta", respectcase

   }

   * - Looping over matched files.

   foreach fname of local list {

      local fname=reverse(substr(reverse("`fname'"),5,.))

      capture noisily use10 `folder'\\`fname'				//	Open Stata 10-11 file

      if "`replace'"=="" {
         save9 "`folder'\\stata9\\`prefix'`fname'`suffix'", replace	//	Saving in older format (Stata 9)
      }
      else {
         save9 "`folder'\\`prefix'`fname'`suffix'", replace
      }           

   }


   * - If option selected, loop over possible subfolders (syntax-dependent).

   if "`subs'"!="" {

      if "`newstx'"=="" {
         local subdirs: dir "`folder'" dirs "`subs'"
      }
      else{
         local subdirs: dir "`folder'" dirs "`subs'", respectcase
      }

      foreach subdir of local subdirs {

         * - Recursive call...

         if "`subdir'"!="stata9" {
            use10save9 , folder("`folder'\\`subdir'") match("`match'") subs("`subs'") prefix("`prefix'") suffix("`suffix'") `replace' `newstx'
         }
      }
   }


end



