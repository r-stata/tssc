


*! ------------------------------------------------------------------------------------------------------------------------------------------------------
*! vs1.0 Lars Aengquist , 2013-09-25 (based on use10save9)
*!
*! program use13save12
*!
*!	syntax	[anything]	[,	folder(string) match(string) subs(string) prefix(string) suffix(string) movenew(string) moveold(string) saveold]			
*!
*! ------------------------------------------------------------------------------------------------------------------------------------------------------



program use13save12

	syntax	[anything]	[,	folder(string) match(string) subs(string) prefix(string) suffix(string) movenew(string) moveold(string) saveold]			
					

   version 10


	   * --------------------------------------------  
	   * - Defaults and pre-prepared subfolder naming
	   * --------------------------------------------
	
   if "`folder'"=="" {										//	default folder
      local folder="."
   }

   if "`match'"=="" {										//	default matching string
      local match="*"
   }

   if "`moveold'"=="vs" {									//	added folder names if string "vs" (old files)
      local moveold="stata13"
   }


   if _caller()>=13 & "`movenew'"=="vs" {							//	added folder names if string "vs" (new files)
      local movenew="stata11-12"
   }
   else if _caller()>=12 & "`movenew'"=="vs" {
      if "`saveold'"=="" {
         local movenew="stata11-12"
      }
      else {
         local movenew="stata8-10"
      }
   }
   else if _caller()>=11 & "`movenew'"=="vs" {
      if "`saveold'"=="" {
         local movenew="stata10-11"
      }
      else {
         local movenew="stata8-9"
      }
   }
   else if _caller()>=10 & "`movenew'"=="vs" {
      if "`saveold'"=="" {
         local movenew="stata10"
      }
      else {
         local movenew="stata8-9"
      }
   }

	* ---------------------------------------
	* - Create new subdirectories (if needed)
	* ---------------------------------------

   if "`moveold'"!="" {										//	for old files
      capture noisily mkdir "`folder'/`moveold'"	   
   }

   if "`movenew'"!="" {										//	for new files
      capture noisily mkdir "`folder'/`movenew'"				
   }


	* ---------------
	* - Syntax errors
	* ---------------

   if _caller()>=13 & "saveold"=="" {								//	Doesn't make sense to save Stata 13-files as Stata13-files
      display as error "Note! Must use 'saveold' option when running on Stata 13" 
      display _newline
      error 119
   }

   if "`movenew'"=="`moveold'" & "`movenew'"!="vs" & "`prefix'"=="" & "`suffix'"=="" {		//	Cannot save new file sin the same directory if no prefix and/or suffix is added
      display as error "Note! Cannot save original and edited files in the same directory"
      display as error "   unless the edited ones get either prefixes or suffixes!" 
      display _newline
      error 119

   }


	* ---------------------------------------
	* - Matching; looping over matched files
	* ---------------------------------------

   local list : dir "`folder'" files "`match'.dta", respectcase					//	Matching, in selected folder, store as local macro 


   foreach fname of local list {

      local fname=reverse(substr(reverse("`fname'"),5,.))					//	Get name without '.dta'

      if _caller()<13 {
         capture noisily use13 "`folder'/`fname'.dta" , clear					//	Open Stata 13 file (from Stata 10-12)
      }
      else {
         capture noisily use "`folder'/`fname'.dta" , clear					//	Open Stata 13 file (from Stata 13)
      }


      if _rc!=610 {										//	If Stata 13-file

         if "`moveold'"!="" {									//	If selected, move old files 
            copy "`folder'/`fname'.dta" "`folder'/`moveold'/`fname'.dta" , replace
            erase "`folder'/`fname'.dta"
         }

         if "`saveold'"=="" {
            capture noisily save "`folder'/`movenew'/`prefix'`fname'`suffix'.dta"		//	Saving in current format 
         }
         else {
            capture noisily saveold "`folder'/`movenew'/`prefix'`fname'`suffix'.dta"		//	Saving in older format 
         }
      }
   }

	* ---------------------------------------------------
	* - If option selected, loop over possible subfolders 
	* ---------------------------------------------------

   if "`subs'"!="" {

      local subdirs: dir "`folder'" dirs "`subs'", respectcase

      foreach subdir of local subdirs {

		* - Recursive call...

         if "`subdir'"!="`moveold'" & "`subdir'"!="`movenew'"  {
            use13save12 , folder("`folder'/`subdir'") match("`match'") subs("`subs'") prefix("`prefix'") suffix("`suffix'") moveold("`moveold'") movenew("`movenew'") `saveold'
         }
      }
   }


end



