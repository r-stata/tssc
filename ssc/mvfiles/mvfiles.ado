*! ---------------------------------------------------------------------------------------------------------------------------------
*! vs1.0 Lars Aengquist , 2012-01-04 
*!
*! program mvfiles
*!
*!		syntax	[anything]	[,	infolder(string) outfolder(string) match(string) subs(string) makedirs erase oldstx]			
*!
*! ---------------------------------------------------------------------------------------------------------------------------------

program mvfiles

		syntax	[anything]	[,	infolder(string) outfolder(string) match(string) subs(string) makedirs erase oldstx]			
					

   version 9


   * - Defaults for folder, (file) matching expression, and sign-replacement

   if "`infolder'"=="" {
      local infolder="."
   }

   if "`outfolder'"=="" {
      local outfolder="."
   }

   if "`match'"=="" {
      local match="*"
   }


   * - If both folders (in/out) are equal - create new default out-folder

   if "`infolder'"=="`outfolder'" {
      local outfolder="`outfolder'\\mvfiles"
      capture mkdir "`outfolder'"		//	create new out-folder (if possible, i.e. if not existing)
   }

   * - Put matched file, in selected in-folder, in local macro

   if "`oldstx'"=="" {
      local list : dir "`infolder'" files "`match'", respectcase
   }
   else {
      local list : dir "`infolder'" files "`match'"
   }


   if "`makedirs'"=="makedirs" {
      capture mkdir "`outfolder'"		//	create new out-folder (if possible, i.e. if not existing)
   }


   * - Looping over matched files

   foreach fname of local list {

      * - Copy matched files
 
      capture copy "`infolder'\\`fname'" "`outfolder'\\`fname'" 


      * - If option selected, and move was successful, erasing old files

      if (_rc==0 & "`erase'"=="erase") {
         capture erase "`infolder'\\`fname'"  
      }
   }


   * - If option selected, loop over possible subfolders

   if "`subs'"!="" {

      if "`oldstx'"=="" {
         capture local subdirs: dir "`infolder'" dirs "`subs'", respectcase
      }
      else{
         capture local subdirs: dir "`infolder'" dirs "`subs'"
      }

      foreach subdir of local subdirs {

         * - Recursive call...

	 mvfiles , infolder("`infolder'\\`subdir'") outfolder("`outfolder'") match("`match'") subs(`subs') `makedirs' `erase' `oldstx'	
      }

   }


end



