*! sasexe Version 2.3 dan_blanchette@unc.edu 11Apr2012
*! the carolina population center, unc-ch
*  - added directory search for SAS 9.3 executable
*  sasexe Version 2.3 dan_blanchette@unc.edu 03Jun2011
*  - made it so that if the locations of savastata.sas and char2fmt.sas files
*     are set then -usesas- or -saswrapper- will use them.
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
*  sasexe Version 2.3 dan_blanchette@unc.edu 30Sep2010
*  - added (x86) dir paths for sas.exe on Win7
*  sasexe Version 2.2 dan.blanchette@duke.edu  04May2009
*  - added directory for SAS 9.2 executable
*  - stopped having it use -shortdir- and started returning wsas in double quotes
*  sasexe Version 2.1 dan.blanchette@duke.edu  16Mar2009
*  - made it so saswrapper can run it
*  sasexe Version 2.1 dan_blanchette@unc.edu  03Mar2008
*  research computing, unc-ch
*  - added a check for environment variable %MAINDIR% in foreach loop through users path
*    if this variable doesn't exist then don't look for sas.exe there.
*  - removed references to J: drive locations of SAS
*  - added error message that -sasexe- cannot be run in Stata batch in Windows
*  sasexe Version 2.0 dan_blanchette@unc.edu  06Sep2006
** the carolina population center, unc-ch
** - need to return what version of SAS is running
** - not only does sasexe look to see if sas executable file exists but also if it works
**   and figures out what version it is.
** - looks in environment variable PATH as a last ditch effort to find the SAS executable file
** - added search for the char2fmt SAS macro file char2fmt.mac
** sasexe Version 1.0 dan_blanchette@unc.edu  02Sep2004
/* updated on 02Sep2004: added new drive specification for UNC afs pc-pkg space SAS users */
/* updated on 11Mar2004: added message to UNIX users on how to
 *  find their sas executable file.  */
** sasexe Version 1.0 dan_blanchette@unc.edu  06Nov2003


program define sasexe, rclass
version 8

 *** SET LOCATION OF SAS EXECUTABLE HERE  ***
 *------------------------------------------*

  // set the macro var appropriate for your operating system
  //  and feel free to send me the location so that I can add it to the
  //  list of locations that -sasexe- searches through so that in future
  //  updates your executable location will already be set
   local wsas `""'   // location of windows sas executable file
   local usas `""'   // location of UNIX/Linux sas executable file
   local rver `""'   // version of sas you think you are running like v8, v9
   // local rver `"v9"'


 /* If you are using -savasas- and don't have SAS and just want to create a SAS program
  *  and temp data files set what version you think the SAS program will be run in here: */
   local nosasver= `""'    // this is not an option for -usesas-



 *** SET LOCATION OF SAVASTATA MACRO HERE FOR USESAS ***
 *-----------------------------------------------------*
  /** for example:
   local savastata "C:\ado\plus\s\savastata.sas"  **/
   local savastata ""
  ** note: if you set the location of savastata you must also set
   * the locaton of char2fmt

 *** SET LOCATION OF CHAR2FMT MACRO HERE FOR USESAS ***
 *-----------------------------------------------------*
  /** for example:
   local char2fmt "C:\ado\plus\c\char2fmt.sas"  **/
   local char2fmt ""
  ** note: if you set the location of char2fmt you must also set
   * the locaton of savastata


*****************************************************************
******* ! NO MORE EDITS SHOULD BE MADE AFTER THIS POINT ! *******
*****************************************************************

// the 2nd argument is the location of SAS executable if invoked by savas
if "`1'" == "savasas" & `"`2'"' != `""' & `"`2'"' != `"sascode"' {
   local usas `"`2'"'   // location of UNIX/Linux sas executable file
}

if `"`nosasver'"' == "" {
  if "`c(os)'" == "Windows" & !missing(`"`usas'"') {
    local usas = "" // set to missing for the logic of this program
  }
  else if "`c(os)'" != "Windows" & !missing(`"`wsas'"') {
    local wsas = "" // set to missing for the logic of this program
  }
 ** User set wsas or usas location so check it out                        **
 ** --------------------------------------------------------------------- **
  if `"`wsas'"' != "" | "`usas'" != "" /* & "`2'" == "" */ {  // sasexe tries to find sas executable otherwise
    if "`c(os)'" == "Windows" {
      if !missing(`"`wsas'"') {
        capture confirm file `"`wsas'"'
        if _rc==0 {
          // find out if this works and what version
          sasexe_ver, sasexe(`"`wsas'"')
          if "`r(rver)'" == ""  {
            // if version wasn't figured out then sas didn't work
            local wsas ""
          }
          else  {  // if rver is something then sas works
           local rver "v`= int(`r(rver)')'"
           di as res _n `"`1' has found the SAS executable file:"'
           di as res   `"`wsas'"'
         }
        }
      }
    }
    else {  // if os is not Windows (UNIX/Linux)
      if !missing(`"`usas'"') {
        capture confirm file `"`usas'"'
        if _rc==0 {
          // find out if this works and what version
          sasexe_ver, sasexe(`"`usas'"')
          if "`r(rver)'" == ""  {
            // if version wasn't figured out then sas didn't work
            local usas ""
          }
          else  {  // if rver is something then sas works
           local rver "v`= int(`r(rver)')'"
           di as res _n `"`1' has found the SAS executable file:"'
           di as res   `""`usas'""'
          }
        }
      }
    }
  }
}  // end of nosasver not set

** If above macros not set by user or set incorrectly **
** then have sasexe look in the usual locations       **
** ---------------------------------------------------**

   if ("`1'" == "usesas" | "`1'" == "saswrapper") & (`"`savastata'"' == "" | `"`char2fmt'"' == "") {
     foreach macro in savastata char2fmt {
      capture confirm file `"x:\software/`macro'.sas"'   /* network location */
      if _rc==0 {
        local `macro' `"x:\software/`macro'.sas"'
      }
      else {
        // local set_macro `"/bigtemp/sas_macros/`macro'.sas"'  /* CPC's location */
        local set_macro `"/afs/isis/pkg/stata/.install/common/ado/updates/`macro'.sas"'
        capture confirm file `"`set_macro'"'  /* UNIX box location */
        if _rc==0 {
         local `macro' `"`set_macro'"'
        }
        else {
          // find it in the adopath
          capture findfile `macro'.sas
          local cwd=`"`c(pwd)'"'
          local dir=substr(`"`r(fn)'"',1,index(`"`r(fn)'"',"`macro'.sas")-1)
          quietly cd `"`dir'"'
          capture confirm file "`macro'.sas"
          if _rc==0 {
            local `macro' `"`c(pwd)'`c(dirsep)'`macro'.sas"'
          }
          quietly cd `"`cwd'"'
        }
      }
     }
   } /* end of if savastata or char2fmt not set */


   // search even if sascode requested (`2' means sascode) since version (rver) can still be figured out
   if `"`nosasver'"' == "" & (`"`wsas'"' == "" | `"`usas'"' == "" ) /* & "`2'" == "" */ {  // sasexe tries to find sas executable otherwise
     if "`c(os)'"=="Windows" & `"`wsas'"'=="" {
      foreach sas in "C:\Program Files\SASHome\SASFoundation\9.3\sas.exe"  /// 9.3
                     "D:\Program Files\SASHome\SASFoundation\9.3\sas.exe"  /// 9.3
                     "C:\Program Files (x86)\SASHome\SASFoundation\9.3\sas.exe"  /// 9.3
                     "D:\Program Files (x86)\SASHome\SASFoundation\9.3\sas.exe"  /// 9.3
                     "C:\Program Files\SASHome\SASFoundation\9.3(32-bit)\sas.exe" /// 9.3
                     "d:\Program Files\SASHome\SASFoundation\9.3(32-bit)\sas.exe" /// 9.3
                     "C:\Program Files (x86)\SASHome\SASFoundation\9.3(32-bit)\sas.exe" /// 9.3
                     "D:\Program Files (x86)\SASHome\SASFoundation\9.3(32-bit)\sas.exe" /// 9.3
                     "C:\Program Files\SAS\SASFoundation\9.3\sas.exe"  /// 9.3
                     "D:\Program Files\SAS\SASFoundation\9.3\sas.exe"  /// 9.3
                     "C:\Program Files (x86)\SAS\SASFoundation\9.3\sas.exe"  /// 9.3
                     "D:\Program Files (x86)\SAS\SASFoundation\9.3\sas.exe"  /// 9.3
                     "C:\Program Files\SAS\SASFoundation\9.3(32-bit)\sas.exe" /// 9.3
                     "d:\Program Files\SAS\SASFoundation\9.3(32-bit)\sas.exe" /// 9.3
                     "C:\Program Files (x86)\SAS\SASFoundation\9.3(32-bit)\sas.exe" /// 9.3
                     "D:\Program Files (x86)\SAS\SASFoundation\9.3(32-bit)\sas.exe" /// 9.3
                     "D:\SAS\SASFoundation\9.3(32-bit)\sas.exe" /// 9.3
                     "D:\SASFoundation\9.3\sas.exe"  /// 9.3
                     "C:\Program Files\SAS\SAS9.3\sas.exe"  /// 9.3
                     "d:\sasv9~3\sas\sas.exe" /// 9.3
                     "c:\progra~1\sas\sasfou~1\9.2\sas.exe"  /// 9.2
                     "d:\progra~1\sas\sasfou~1\9.2\sas.exe"  /// 9.2
                     "c:\Program Files (x86)\SAS\SASFoundation\9.2\sas.exe"  /// 9.2
                     "d:\Program Files (x86)\SAS\SASFoundation\9.2\sas.exe"  /// 9.2
                     "C:\Program Files\SAS\SASFoundation\9.2(32-bit)\sas.exe" /// 9.2
                     "d:\Program Files\SAS\SASFoundation\9.2(32-bit)\sas.exe" /// 9.2
                     "C:\Program Files (x86)\SAS\SASFoundation\9.2(32-bit)\sas.exe" /// 9.2
                     "d:\Program Files (x86)\SAS\SASFoundation\9.2(32-bit)\sas.exe" /// 9.2
                     "d:\SAS\SASFoundation\9.2(32-bit)\sas.exe" /// 9.2
                     "d:\sasfou~1\9.2\sas.exe"  /// 9.2
                     "c:\progra~1\sas\sas9~2\sas.exe"  /// 9.2
                     "d:\sasv9~2\sas\sas.exe" /// 9.2
                     "Y:\SAS92_32\sas.exe.lnk" /// 9.2 for CPC 
                     "Y:\SASSER~1\v9\sas\sas.exe"  /// Win XP
                     "Y:\SAS_SE~1\V9\SAS\SAS.EXE" /// Win 2000
                     "c:\progra~1\sas\sas9~1.1\sas.exe"  ///
                     "C:\Program Files (x86)\SAS\SAS 9.1\sas.exe" /// 9.1 on Win7
                     "d:\Program Files (x86)\SAS\SAS 9.1\sas.exe" /// 9.1 on Win7
                     "c:\progra~1\sasins~1\sas\v9\sas.exe" ///
                     "d:\sasv9~1.1\sas\sas.exe" ///
                     /// now try version 8
                     "c:\progra~1\sasins~1\sas\v8\sas.exe" ///
                     "d:\sasv8~1\sas\sas.exe" ///
                     "Y:\SAS_SE~1\V8\SAS\SAS.EXE" /// Win 2000
                     "Y:\SASSER~1\V8\SAS\SAS.EXE" /* Win XP */  {
       capture confirm file "`sas'"
       if _rc==0 {  // success!
         local wsas `"`sas'"' /* for Windows */
         // find out if this works and what version
         sasexe_ver, sasexe(`"`wsas'"')
         if "`r(rver)'" == ""  {
           // if version wasn't figured out then sas didn't work
           local wsas ""
         }
         else  {  // if rver is something then sas works
           local rver "v`= int(`r(rver)')'"
           di as res _n `"`1' is going to run SAS `rver' executable: "`wsas'" "'
           continue, break  // stop looking
         }
       }
      } /* end of foreach loop */
     } /* end of if Windows */

     else if "`c(os)'"=="Unix" & "`usas'"=="" {
       if  "`c(machine_type)'" == "Sun Solaris" {
         foreach sas in "/opt/sas9.3/sas" "/opt/sas9.3/sas" {
           capture confirm file `"`sas'"'
           if _rc==0 {
             local usas "`sas'"
             local rver `"v9"'
             continue, break  // stop looking
           }
         }
       }
       else  { // for others
         capture confirm file `"/usr/bin/sas"'
         if _rc==0 {
           local usas "/usr/bin/sas"
           // let sasexe figure out what version of SAS
             sasexe_ver, sasexe(`"`usas'"')
             local rver "v`= int(`r(rver)')'"
         }
         else {
           foreach sas in "/nas02/apps/sas-9.3/sas" "/nas02/apps/sas-9.2/sas" {
             capture confirm file `"`sas'"'
             if _rc==0 {
                             /* in apps space */
               local usas `"`sas'"'
               local rver `"v9"'
               continue, break  // stop looking
             }
             else {
               capture confirm file `"/afs/isis/pkg/sas/sas"'
               if _rc==0 {
                               /* in pkg space */
                 local usas `"/afs/isis/pkg/sas/sas"'
                 local rver `"v9"'
               }
             }
           }
         }
       }  // end if not Sun Solaris box
     }  /* end of if UNIX */

     if `"`wsas'"'=="" & "`usas'"=="" { // if still not set
       // look in user's path
       local path  : environment PATH
       local delim ":"
       if "`c(os)'" == "Windows"  local delim ";"
        // allows for dirs to have spaces in the directory names
       foreach dir in "`: subinstr local path "`delim'" `"" ""', all'" {
         if `= index(`"`dir'"',"%MAINDIR%")' & `"`: environment MAINDIR'"' == ""  continue
         if "`c(os)'" == "Windows"  & `"`:  dir "`dir'" files sas.exe'"' == `""sas""' {
           capture confirm file `"`dir'\sas.exe"'
           if _rc==0 {
             local wsas  `"`dir'\sas.exe"'
             // find out if this works and what version
             sasexe_ver, sasexe(`"`wsas'"')
             if "`r(rver)'" == ""  {
               // if version wasn't figured out then sas didn't work
               local wsas ""
             }
             else  {  // if rver is something then sas works
               local rver "v`= int(`r(rver)')'"
               di as res _n `"`1' is going to run SAS `rver' executable: "`wsas'" "'
               continue, break  // leave loop once found sas executable
             }
           }
         }  // end of if Windows
         else if `"`:  dir "`dir'" files sas'"' == `""sas""'   {
           capture confirm file `"`dir'/sas"'
           if _rc==0 {
             local usas `"`dir'/sas"'
             sasexe_ver, sasexe(`"`usas'"')
             if "`r(rver)'" == ""  {
               // if version wasn't figured out then sas didn't work
               local usas ""
             }
             else {  // if rver is something then sas works
               local rver "v`= int(`r(rver)')'"
               di as res _n `"`1' is going to run SAS `rver' executable: "`usas'" "'
               continue, break  // leave loop once found sas executable
             }
           }
         }
       } // end of foreach dir

       if `"`wsas'"'=="" & "`usas'"==""  { // if _still_ not set
         di "{error}Edit your sasexe.ado file to set the location *"
         di "{error}of your SAS executable file. *"
         which sasexe
         di `" {stata adoedit sasexe:edit sasexe.ado} (click, to edit the sasexe.ado file, remember to save when done.)"'
         if "`1'"=="savasas" di "{error}or use the {res}sascode {error}option in `1'.  * "
         if "`1'"=="usesas" di "{error} {help usesas:usesas} requires that you have a working version of SAS on this computer. "
         if "`1'"=="saswrapper" di "{error} {help saswrapper:saswrapper} requires that you have a working version of SAS on this computer. "
         if "`c(os)'"=="Unix" {
           di `"{error} Your SAS executable is a file named "sas" not "sas.exe" and can be found by typing: *"'
           di `"{text} which sas *"'
           di `"{error} at a UNIX prompt.  You may want to inform your UNIX administrator that *"'
           di `"{error} you want to run SAS from Stata.  * "'
         }
         exit 499
       }  // end of if wsas and usas _still_ empty
     }  // end of if wsas and usas still empty

   } // end of if "`wsas'"=="" & "`usas'"==""   i.e. not set

 /*********  this block of code should not be needed anymore, it should not ever happen ****/
   // check that if wsas or usas was set by user that they did it correctly
   if `"`wsas'"'!="" & "`c(os)'"=="Windows" & "`2'"=="" { // `2' is if sascode requested
     capture confirm file `"`wsas'"'
     if _rc!=0 {
       di `"{error}This is not the correct location of your SAS executable: "'
       di `"{res}`wsas' "'
       di "{error}Edit your sasexe.ado file to set the location of your sas.exe file. "
       which sasexe
       di `" {stata adoedit sasexe:edit sasexe.ado} (click, to edit the sasexe.ado file, remember to save when done.)"'

       if "`1'"=="savasas" di "{error}or use the {res}sascode {error}option in `1'.  "
       exit 499
     }
   } /* end of if wsas not correctly set */
   else if "`usas'"!="" & "`c(os)'"=="Unix" & "`2'"=="" { // `2' is if sascode requested
     capture confirm file `"`usas'"'
     if _rc!=0 {
       di `"{error}This is not the correct location of your SAS executable:  *"'
       di `"{res}"`usas'"      *"'
       di "{error}Edit your sasexe.ado file to set the location *"
       di "{error}of your sas executable file.  *"
       which sasexe
       di `" {stata adoedit sasexe:edit sasexe.ado} (click, to edit the sasexe.ado file, remember to save when done.)"'
       if "`1'"=="savasas"  di "{error}or use the {res}sascode {error}option in `1'.  *"
       exit 499
     }
   } /* end of if usas not correctly set */
 /****** (end) this block of code should not be needed anymore, it should not ever happen **/

   if "`1'"=="usesas" | "`1'"=="saswrapper" {
     foreach macro in savastata char2fmt {
       capture confirm file `"``macro''"'
       if _rc!=0 {
        if `"``macro''"' != "" {
         di `"{error}This is not the correct location of your `macro' macro:  "'
         di `"{res}``macro'' "'
        }
        else di `"{error}The file `macro'.sas was not found.  {help `1':`1'} needs this file to run."'
         di "{error}Edit your sasexe.ado file to set the location of your `macro'.sas file. "
         which sasexe
         di `" {stata adoedit sasexe:edit sasexe.ado} (click, to edit the sasexe.ado file, remember to save when done.)"'
         exit 499
       }
       return local `macro' ``macro''
     }
   }

   // if person knows they don't have sas and chooses what version to run, and is using
   //  the sascode option then replace rver with nosasver
   if `"`nosasver'"' != "" & `"`2'"' != ""  local rver=`"`nosasver'"'

   // make sure v8.2 or v9.1.3 is not used as it's not necessary to be that exact
   if index("`rver'","8")   local rver = "v8"
   else if index("`rver'","9")   local rver = "v9"
   else if index("`rver'","10")   local rver = "v10"
   else if index("`rver'","11")   local rver = "v11"
   else if index("`rver'","12")   local rver = "v12"

   if "`rver'" == "" & "`2'" == "" { // `2' is if sascode requested
     di as error "`1' was unable to figure out what version of SAS you are running. *"
     di as error "Please edit your {stata adoedit sasexe:sasexe.ado} file and specify the location of your SAS *"
     di as error "executable file and the version of SAS you are running. *"
     if "`usas'" != "" & "`c(os)'" != "Windows"  {
       di as res `"`1' found your SAS executable file here: "`usas'""'
     }
     else if `"`wsas'"' != "" & "`c(os)'" == "Windows"  {
       di as res `"`1' found your SAS executable file here: "`wsas'""'
     }
     exit 499
   }  // end of if rver still empty
   else if "`rver'" == "" & "`2'" != ""  {  // `2' is if sascode requested
     local rver "v9"
     di as error _n `"{help savasas:savasas} is choosing to write code appropriate for SAS version 9. *"'
     di as error  `"If an alternate version of SAS is desired, please edit your {stata adoedit sasexe:sasexe.ado} file. *"'

   }

   return local rver "`rver'"
   return local wsas `"`""`wsas'""'"'
   return local usas `usas'

end


capture program drop sasexe_ver
program sasexe_ver, rclass
 version 8
 syntax, sasexe(string)
 if "`c(os)'"=="Windows" & "`c(mode)'" == "batch" {
   di as err "sasexe cannot be run in batch mode on Windows"
   exit  499
 }

  tempfile sas_ver
  quietly file open sasvfile using "`sas_ver'_version.sas", replace text write
  file write sasvfile `"** program to figure out if SAS works and what version is running **;"' _n ///
                      `" data _null_; "' _n `" file "`sas_ver'_version.do";"' _n ///
                      `" put "capture program drop sas_rver"; "' _n ///
                      `" put "program sas_rver, rclass"; "' _n ///
                      `" put "return local rver ""&sysver."""; "' _n ///
                      `" put "end";"' _n ///
                      `" run; "'
  file close sasvfile
  capture confirm file `"`sas_ver'_version.sas"'
  if _rc==0 {
    local nologo = "-nologo"
    // -nologo is not an option for UNIX/Linux SAS
    if "`c(os)'"=="Unix" /* or Linux */   local nologo = ""

    shell "`sasexe'" "`sas_ver'_version.sas" `nologo' -log "`sas_ver'_version.log"
    capture confirm file `"`sas_ver'_version.do"'
    if _rc==0 {
      run `"`sas_ver'_version.do"'
      sas_rver
      return local rver "`r(rver)'"
    }
      capture  erase `"`sas_ver'_version.sas"'
      capture  erase `"`sas_ver'_version.log"'
      capture  erase `"`sas_ver'_version.do"'
  }

end
