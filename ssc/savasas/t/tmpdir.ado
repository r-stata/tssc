*! tmpdir Version 1.1 dan_blanchette@unc.edu 22Jan2009
*! the carolina population center, unc-ch
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
* tmpdir Version 1.1 dan_blanchette@unc.edu  16Jan2008
* research computing, unc-ch
** - minor code updating to improve efficiency of this program
**    and added check to make sure a Linux/UNIX tmpdir does not
**    contain spaces.
** tmpdir Version 1.0 dan_blanchette@unc.edu  08Oct2003
** the carolina population center, unc-ch

program define tmpdir, rclass
args short
 version 8

 /***************************************************************************************
    Stata uses the directory that is set by your computer to be the temporary directory
     by default.  The environment variable STATATMP can be set to specific directory that
     Stata should use for the temporary directory. If you want to have certain programs
     that call -tmpdir- to use yet another directory for temporary files you can set 
     the location of that temporary directory here with the local macro variable tmpdir.

    If for some reason tmpdir.ado was unable to figure out what the pathname is,
    enter the name without spaces in the name.  For example:
     local tmpdir=`"c:\Documents and Settings\dan\Local Settings\temp"'
    should be set using short file names (first 6 characters, plus "~1" or "~2" , etc. :
     local tmpdir=`"c:\Docume~1\dan\LocalS~1\temp"'
  ****************************************************************************************/

 local tmpdir=`""'

 *****************************************************************
 ******* ! NO MORE EDITS SHOULD BE MADE AFTER THIS POINT ! *******
 *****************************************************************
 confirmdir `"`tmpdir'"'
 if `"`tmpdir'"'=="" | `r(confirmdir)'!=0  {  /* tmpdir is not set or not set correctly */
  tempfile temp
  _getfilename `"`temp'"'
  local tfilen `"`r(filename)'"'

  local tmpdir : subinstr local temp `"`tfilen'"' ""

  local subtest : subinstr local tmpdir " " "" , count(local cnt)
    if `cnt' != 0 {
      if "`c(os)'"=="Windows" {  /* make sure directory structure has no spaces */
       shortdir using `"`tmpdir'"' , `short'
       local tmpdir `"`r(shortdir)'\"'
      } /* end of windows */
      else {
        di "{error}Your temporary directory contains spaces."
        di "{error}You need to set the location of your temporary directory " _n ///
           "to a directory that does not contain spaces."
        di "{error}Edit your tmpdir.ado file to set the location of your Stata temporary file: "
        which tmpdir
        if "`c(console)'" == "" {
          di `"It's as easy as: "'
          di `" {stata adoedit tmpdir: (click here, to edit the tmdpir.ado file}, remember to save when done.)"'
        }
        exit 499
      }
    } // end of if tmpdir contains spaces
  capture confirmdir "`macval(tmpdir)'"
  if `r(confirmdir)'!=0  {
   di "{error}The setting for your temporary directory: {res}`tmpdir' {error}is not correct."
   di "{error}You need to set the location of your temporary directory."
   di "{error}Edit your tmpdir.ado file to set the location of your Stata temporary file: "
   which tmpdir
   if "`c(console)'" == "" {
     di `"It's as easy as: "'
     di `" {stata adoedit tmpdir: (click here, to edit the tmdpir.ado file}, remember to save when done.)"'
   }
   exit 499
  }
 } /* end of tmpdir not set or not set correctly */

 return local tmpdir "`tmpdir'"

end
 
 
   

