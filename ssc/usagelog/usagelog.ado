*! usagelog Version 2.1 dan_blanchette@unc.edu 22Jan2009
*! the carolina population center, unc-ch
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
*  usagelog Version 2.1 dan_blanchette@unc.edu  01Feb2008
*  research computing, unc-ch
*  - made it so that Windows can delete the usage log
** usagelog Version 2.0 dan_blanchette@unc.edu  05Aug2006
*  - made it so that usagelog be installed in a central 
*    location and be run by multiple machines which log to 
*    to different directories locations or to one central location.
*  usagelog Version 1.1 dan_blanchette@unc.edu  01Aug2005
*  - added USERNAME to print to usagelog file
*  usagelog Version 1.0 dan_blanchette@unc.edu  08Oct2004
*  - fixed it so that compound quotes used throughout
* usagelog Version 1.0 dan_blanchette@unc.edu  20Oct2003
** the carolina population center, unc-ch

program define usagelog
 syntax [, start type(string) message(string) ETime UError(string) script ]
 version 8


 /* set location of the (type)_usage.log file */

 local usagelog  `"c:\temp\"'
 
 if index(upper(trim("`c(os)'")),"WIN") != 1 { 
   if index(lower(trim("`: environment HOSTNAME'")),"gromit") == 1  ///
    | index(lower(trim("`: environment HOSTNAME'")),"sig") == 1     ///
    | index(lower(trim("`: environment HOSTNAME'")),".cpc.") != 0   { 
     local usagelog = "/backups/usage/" 
   }
    /* since now starting a new usagelog file whenever it gets larger
     *  than 500,000 bytes keep log of usage in pkg space 
     *  Since Stata requires users to have write permissions to this 
     *  directory...write to it! */
   else local usagelog = "/backups/usage/" 
 }

 *****************************************************************
 ******* ! NO MORE EDITS SHOULD BE MADE AFTER THIS POINT ! *******
 *****************************************************************
 
 capture confirm file `"`macval(usagelog)'`type'_usage.log"'
 if _rc==0 {  // if log file exists then add to it 
  ** check to see if the usage log file is too big and if so delete it
   *  and start a new one.
  quietly checksum `"`macval(usagelog)'`type'_usage.log"'
  if `r(filelen)' > 500000   {
    if index(upper(trim("`c(os)'")),"WIN") != 1 { 
      shell rm -f `"`macval(usagelog)'`type'_usage.log"';
    }
    else {
      shell del /F `"`macval(usagelog)'`type'_usage.log"';
    }
    shell echo "file started on: `date`"  > `macval(usagelog)'`type'_usage.log
    shell echo " "  >> `macval(usagelog)'`type'_usage.log
    if index(upper(trim("`c(os)'")),"WIN") != 1 { 
      shell chmod 666 `macval(usagelog)'`type'_usage.log
    }
  }
  capture which etime 
  if _rc==0 { 
   if `"`start'"' == "start" {
    quietly etime, start
   }
   if `"`etime'"' == "etime" {
    quietly etime
   }
  }
  file open usagelog using `"`macval(usagelog)'`type'_usage.log"', write text append 

  if `"`start'"'=="start" { /* first call to usagelog */
   if `"`script'"'=="" { 
    local username : environment USERNAME
    if "`username'" == ""  local username : environment USER
    file write usagelog _n `"  `username'  `c(current_date)'  `c(current_time)' `c(pwd)' "' _n `"   `message'"'  _n
   }
   else if `"`script'"'=="script" { 
    file write usagelog    `"  `script' `message'"'  _n
   }
  }
  if `"`start'"'=="" & `"`message'"'!="" { /* additional message being sent to usagelog */
    file write usagelog  `"   `message' "'  _n
  }
  if `"`uerror'"'!="" { /* error code being passed to usagelog */
    file write usagelog  `"   error=`uerror' "'  _n
  }
  if `"`etime'"'=="etime" {
   file write usagelog   `"   Elapsed time is `s(etime)' "' _n  
  }
  file close usagelog
 } // end of if usage log file exists
end 

