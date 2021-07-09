*! -------------------------------------------------------------------------------------------------------------------
*! vs1.0 Lars Aengquist , 2011-12-22 
*!
*! program rmfiles
*!
*!		syntax	[anything]	[,	folder(string) match(string) subs(string) rmdirs oldstx]			
*!
*! --------------------------------------------------------------------------------------------------------------------

program rmfiles

		syntax	[anything]	[,	folder(string) match(string) subs(string) rmdirs oldstx]			
					

   version 9


   * - Defaults for folder, (file) matching expression, and sign-replacement.

   if "`folder'"=="" {
      local folder="."
   }

   if "`match'"=="" {
      local match="*"
   }


   * - Put matched file, in selected folder, in local macro (syntax-dependent).

   if "`oldstx'"=="" {
      local list : dir "`folder'" files "`match'", respectcase
   }
   else {
      local list : dir "`folder'" files "`match'"
   }

   * - Looping over matched files.

   foreach fname of local list {

      * - Erase matched files.
 
      capture erase "`folder'\\`fname'" 
   }

   if "`rmdirs'"=="rmdirs" {
      capture rmdir "`folder'"		//	remove directory as well (if possible, i.e. if dir is empty)
   }

   * - If option selected, loop over possible subfolders (syntax-dependent).

   if "`subs'"!="" {

      if "`oldstx'"=="" {
         capture local subdirs: dir "`folder'" dirs "`subs'", respectcase
      }
      else{
         capture local subdirs: dir "`folder'" dirs "`subs'"
      }

      foreach subdir of local subdirs {

         * - Recursive call...

	 rmfiles , folder("`folder'\\`subdir'") match("`match'") subs(`subs') `rmdirs' `oldstx'	
      }
   }


end



