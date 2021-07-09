program _usespss
     version 8.2

     syntax [anything] [using/] [,SAVing(string)] [clear] ///
            [MEMory(real 0)] [LOWMEMory(real 1)] ///
            [iff(string)] [inn(string)]

   /* Written by Sergiy RADYAKIN
                 The World Bank
                 in January 2008
                 sradyakin(at)worldbank.org
      Version 1.0
      Requires UseSPSS.plu

      If you are getting a message:
        ----------------------------------------------------
        Could not load plugin: ***PATH***\U\UseSPSS.plu
        (error occurred while loading usespss.ado)
        r(9999);
        ----------------------------------------------------
      1. you might be using a 64-bit Stata - use 32-bit Stata instead
      2. the plugin is actually missing - check that the file UseSPSS.plu can be found along the ADOPATH
      3. your Stata version is too old and does not support plugins of the 2.0 specification
      4. the plugin can't be loaded for another reason - this might be a BUG (most probably mine)

   */

     local level=0   // Warning: do not change this value unless instructed to do so (Stata may crash, Worlds may collide, ...)

     if `"`using'"'=="" local file_name=`"`anything'"'
                   else local file_name `""`using'""'

     if `"`saving'"'=="" {
       tempfile saving
       local saving_to_temp=1
     }
     else {
       local saving_to_temp=0
     }

     gettoken file_name rest : file_name
     gettoken saving rest : saving

     if (`"`file_name'"'=="") | (`"`file_name'"'==" ") {
       display
       display as error "Error! Filename required!"
       display
       display as result "USESPSS Syntax: "  as text "usespss spss_file.sav [, saving(stata_file.dta) clear]
       display
       display as result "Note: " as text "Enclose filenames in quotes if they contain any spaces."
       error 198
     }
     else {

       confirm file `"`file_name'"'

       if (c(changed)==1) & (`"`clear'"'=="") & (`memory'==0) {
         error 4
       }

       /* we are ok to clear, either because memory was specified,
          or clear, or dataset was already saved before */

       drop _all

       if `saving_to_temp' {
         quietly {
           set obs 1
           gen a=0
           preserve, changed  // this mess is just to get the "changed" state. Unfortunately it will always be set, even if no import actually occured:(
           drop _all
         }
       }

       if `memory'!=0 {

         if `lowmemory'>`memory' {
           display as result "Hint: in most cases -lowmemory()- must be smaller than -memory()-"
           display as text "Current values are " ///
                   as result "`lowmemory'm" ///
                   as text " and " ///
                   as result "`memory'm" ///
                   as text " respectively"
           display
         }

         capture set memory `lowmemory'm
         if _rc {
           display as error "Attempt to temporarily set memory to `lowmemory'mb failed"
           display as error "Typically you do not need adjust memory settings unless working with large files"
           display as error "The default value of 1mb must be functional under most conditions"
           error _rc
         }
       }

       plugin call UseSPSSExternal, `"`file_name'"' `"`saving'"' `level' 0

       if `memory'!=0 {
         capture set memory `memory'm
         if _rc {
           display as error "Attempt to set memory to `memory'mb failed."
           display as error "Please check that you are normally able to allocate " as result "`memory'mb" as error " of memory"
           display
           error _rc
         }
       }

       capture confirm file `"`saving'"'
       if _rc {
         display
         display as error "Converted file was not found."
         display as error "Perhaps something went wrong during the conversion. Please examine all diagnostic messages above."
         display as error "Other possible reasons may be:"
         display as error "   1) The file was too large. "
         display as error "   2) Stata has claimed too much memory for itself,"
         display as error "      and the plugin can't allocate memory,"
         display as error "      In this case use the -memory()- and -lowmem()- options"
         display as error "Both may be reasons because UseSPSS is a 32-bit plugin and"
         display as error "it faces 2GB memory limit and other limits of the 32-bit processes."
         display as error "It is unlikely that this version will convert files larger than about 700mb."
         display as error "   3) Not enough disk space for a temporary file."
         display
         display as text  "The author of this program would really want to know about any bugs"
         display as text " or compatibility issues discovered in UseSPSS"
         display as text  "If you believe that you've encountered a bug, please let me [Sergiy RADYAKIN] know: "
         display as result "sradyakin(at)worldbank.org"
         display as text  "Sorry for any inconvenience"
         display

         error 999
       }

       if `"`iff'"'!="" local iff `"if `iff'"'
       if `"`inn'"'!="" local inn `"in `inn'"'

       use `"`saving'"' `iff' `inn', clear

       if !`saving_to_temp' {
         if (`"`iff'"'!="") | (`"`inn'"'!="") save `"`saving'"', replace
       }
       else restore // sets the changed flag

     }

end

program define UseSPSSExternal, plugin using("UseSPSS.plu")

// --- END OF FILE ---
