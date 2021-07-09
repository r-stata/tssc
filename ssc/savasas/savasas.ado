*! savasas Version 2.5 dan_blanchette@unc.edu 12Jun2012
*! the carolina population center, unc-ch
** - handles variables with %tc formats but users will have to divide that variable
**    by 1,000 to make it equivalent to Stata's date time format %tc.
** savasas Version 2.5 dan_blanchette@unc.edu 25Jan2012
** - now creates more unique temporary file names.
** savasas Version 2.4 dan_blanchette@unc.edu 13May2011
** - added compress option so that if user does want their SAS dataset to be as small as
**    as possible then they can specify that, otherwise -compress- will not slow down -savasas-
** savasas Version 2.3 dan_blanchette@unc.edu 16Aug2010
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
** - fixed date formats to handle dates that start with %t 
**   and added a test of -capture- since -capture- can fail due to the dataset having
**   a number of long string variables.
** savasas Version 2.2 dan.blanchette@duke.edu  12Mar2009
** - made it so when run on Linux/Unix and SAS filename is not all lowercase savasas
**    will still display that file was successfully saved.
** savasas Version 2.1 dan.blanchette@duke.edu  12Mar2009
** - made savasas able to be run by saswrapper
** - added some date formats, and made it so that any date format will be kept at least as
**    mmddyy10. format in SAS
** savasas Version 2.0 dan_blanchette@unc.edu  03Jul2008
** research computing, unc-ch
** - created check to make sure user is not trying to create a SAS datafile named with
**    more than 32 characters in the name.
** - created a check to make sure SAS ran without errors.  If not, then messy option is turned on.
** - fixed the string comparison that generated the the "too many literals" error message 
**    when saving long value labels as user-defined SAS formats
** - fixed all long string comparisons 
** - fixed it so savas does not accidently find an error message in the savasas log
** - added dataset label saying savasas created dataset on date
** - added error message that -savasas- cannot be run in Stata batch in Windows
** - made it so that variable labels can contain macro var references etc.
** - no longer dealing with sortedby vars since SAS and Stata sort orders are different
**    depending on missing values and DESCENDING sorts
** savasas Version 1.4 dan_blanchette@unc.edu  29May2007
** - fixed ability to save special missing values with value label as SAS formats
** - now label values of negative numbers are also saved as SAS formats
** - fixed dataset filenames when using the sascode option  
** savasas Version 1.3 dan_blanchette@unc.edu  08Aug2006
** - fixed it so that vars with non-existent value labels don't throw things off.
** - fixed situation where value labels with invalid SAS format names were not
**    haiving the rename format assigned to all variables.
** - added ability to tell savasas where the SAS executable is, but for non-windows os's only.
** savasas Version 1.2 dan_blanchette@unc.edu  05Aug2005
** - updated to allow for up to 32 character format value names now possible with SAS 9
**    and maintain Stata 9 value labels up to 32,000 characters to SAS 9 as well.
** - totally changed how value label names are checked
** - now using -labvalclone- by Nick Cox included at bottom of file
** - no longer using -uselabel-
** - now only trimming off trailing blanks for string variables (no longer trimming leading blanks)
** savasas Version 1.1 dan_blanchette@unc.edu  04Nov2004
** - added ability to save data when directory path provided but no SAS file name provided
** - now allows for SAS file to be saved in a directory using universal filenaming convention e.g."\\\MyServer\sys1\projects\sasf.sas7bdat"
** - fixed check option so that it only checks the vars and obs specified in the "if and in" if one or both were specified
** savasas Version 1.1 dan_blanchette@unc.edu  10Sep2004
** - SAS 9 doesn't support .sd7 as a file extension so -savasas- no longer does for any version of SAS
** savasas Version 1.1 dan_blanchette@unc.edu  13Jul2004
** savasas Version 1.1 dan_blanchette@unc.edu  15Nov2003
** - fixed "keep if in" to select subset of observations
**  and sortedby varnames when longer than 8 characters
** savasas Version 1.0 dan_blanchette@unc.edu  27Oct2003
** the carolina population center, unc-ch

program define savasas, rclass
 version 8.1  /* using fdasave */
syntax [varlist] [using/] [in] [if] [, replace sascode Type(string) FORmats udir(string)  ///
                                        MEssy CHeck REName script usas(string) saswrapper ///
                                        saswrap_data(string) sysjobid(string) compress ]  



/* log usage of savasas */
capture which usagelog
if _rc == 0 { 
 usagelog , start type(savas) message(`"savasas using `using' `in' `if' , `replace' `sascode' type(`type')  `formats' `messy' `check' `rename' "') `script'
 usagelog , type(savas) message("Input Stata dataset has `c(N)' obs and `c(k)' vars")
}

if "`c(os)'" == "Windows" & "`c(mode)'" == "batch" {
  di as err "{help savasas:savasas} cannot be run in batch mode on Windows"
  /* log usage of savasas */
  capture which usagelog
  if _rc == 0 {
   usagelog , type(savas) uerror(8) etime
  }
  exit  499
}


capture which fdasave
if _rc != 0 {
 di `"{error}You need to update Stata 8 to run {browse "http://www.cpc.unc.edu/research/tools/data_analysis/sas_to_stata/savasas.html":savasas}.  {help savasas:savasas} {error}uses the {help fdasave:fdasave} {error}command."'

 /* log usage of savasas */
 capture which usagelog
 if _rc == 0 { 
  usagelog , type(savas) uerror(1) etime
 }
 exit _rc
}

 
* FIGURE OUT WHERE SAS EXECUTABLE IS
* ----------------------------------
if "`saswrapper'" != "" {
 local quietly quietly  
}
`quietly' sasexe savasas `sascode' `usas'

local wsas `r(wsas)'
local usas `r(usas)'
local rver `r(rver)'  // version of sas that's being run i.e. "v8", "v9" etc


* FIGURE OUT FILENAME and DIRECTORY
* ---------------------------------
// see if there is even one double quote in using
local subtest : subinstr local using `"""' `""' , count(local cnt)
if `cnt' != 0 {
 di `"{help savasas} {error}cannot handle directory or file names that contain double quotes. "'
  capture which usagelog
 if _rc == 0 {
  usagelog , type(savas) uerror(2) etime
 }
 exit 499
}

if `: length local using' == 0 {   // using is empty so try c(filename)
  local filename "`c(filename)'"
  if `: length local filename' != 0 {
   local subtest :  subinstr local filename `"http://"' `""' , count(local cnt)
   if `cnt' != 0  {
     capture _getfilename `"`filename'"'  // get error message if only dir in using
     local using `"`r(filename)'"'  // make using just the filename
   }
   else {  // use the file name and directory of the Stata dataset in memory 
     local using="`filename'"  
   }
  }
  else if `: length local filename' == 0 {
   di "{error}No file name provided to save data."
   /* log usage of savasas */
   capture which usagelog
   if _rc == 0 { 
    usagelog , type(savas) uerror(4) etime
   }
   exit 198
  }
}
  
// now process using 
/* `: length local using' != 0  */

local subtest : subinstr local using `"/"' `""' , count(local cnt) 
if `cnt' != 0 & "`c(os)'" == "Windows" {
   local using : subinstr local using "/" "\" , all
}
if "`c(os)'" == "Windows" {
  local dirsep="\"
}
else {
  local dirsep="`c(dirsep)'"
}

** if file name is given with directory info too,
 *  strip to just file name and to dir location 
// see if using contains directory info 
local subtest : subinstr local using `"`dirsep'"' `""' , count(local cnt)
if `cnt' != 0 {   // Universal naming convention okay here 
  capture _getfilename `"`using'"'  // get error message if only dir in using
  local filen `"`r(filename)'"'
  if "`filen'" != "" {    // dir and filename in using
    local dir : subinstr local using `"`filen'"' `""'      
  }
  else if `: length local using' != 0 {  // only directory in using
    local dir `"`using'"'
    _getfilename `"`c(filename)'"'
    local filen `"`r(filename)'"'
  }
}
else {  // no directory given 
       local filen="`using'"
       local dir ="`c(pwd)'`dirsep'" 
}

local filen= lower("`filen'")  // filen has to be less than 32 chars and does not contain dir info

local subtest : subinstr local dir `"/"' `""' , count(local cnt) 
if `cnt' != 0 & "`c(os)'" == "Windows" {
   local dir : subinstr local dir "/" "\" , all
}
confirmdir `"`dir'"'
if _rc != 0 {
  local rc _rc
  di `"{error}The directory "`dir'" does not exist."'
   /* log usage of savasas */
   capture which usagelog
   if _rc == 0 {
    usagelog , type(savas) uerror(16) etime
   }
  exit `rc'
}


// filen could still be empty
if `"`filen'"' == `""' {
   di "{error}No file name provided to save data."
   /* log usage of savasas */
   capture which usagelog
   if _rc == 0 {
    usagelog , type(savas) uerror(14) etime
   }
   exit 198
}


* Data will be changed during program so preserve it so that it will
*  be restored after program finishes running
preserve


* FIX TYPE
* --------
if lower("`type'") == "" | index(lower("`type'"), "sas7") ///
                         | index(lower("`type'"), "sas8") /// 
                         | index(lower("`type'"), "sas9")  {
  local type "sas"
 }
else if lower("`type'") == "ssd01" | lower("`type'") == "sas6" | lower("`type'") == "sd2"  {
  local type "sas6"
 }
else if index(lower("`type'"), "x") | index(lower("`type'"), "tran")  {
  local type "sasx"
 }


* IF/IN
* -----

if `: length local if' != 0 | `: length local in' != 0 {
  quietly keep `if' `in'
}


keep `varlist'

if `c(N)' == 0 {
 di as error "{help savasas:savasas} cannot save your dataset because it has no observations. *"
 /* log usage of savasas */
 capture which usagelog
 if _rc == 0 { 
  usagelog , type(savas) uerror(5) etime
 }
 exit 2000 
}

di _n "{txt}Selected dataset contains {result}`c(N)' {txt}observations and {result}`c(k)' {txt}variables. *"

// because savasas needs to test that vars are all unique -rename- is used which
//  temporarily creates the new var plus a tempvar so that adds 2 variables for a bit
if `c(k)' > 32765 {
  di as error "{help savasas:savasas} can only handle datasets up to 32,765 variables"
  di as error "Your dataset has `c(k)' variables."
 /* log usage of savasas */
 capture which usagelog
 if _rc == 0 { 
  usagelog , type(savas) uerror(17) etime
 }
 exit 103 
}
if `c(k)' > 1000 | `c(N)' > 50000 {
 di _n "{txt}This may take a few minutes.        *"
}


* DATA LIST
* ---------

 //  extract file extension if there is one 
if index("`filen'", ".sas7bdat") & index("`filen'", ".sas7bdat") == length("`filen'") - 8 {
 local ext= ".sas7bdat"
 local type= "sas"
}
else if index("`filen'", ".sd7") & index("`filen'", ".sd7") == length("`filen'") - 3 {
 if "`c(os)'" == "Windows" {
  local ext= ".sas7bdat"
  di "{error}Starting with SAS 9 short filename extensions are no longer supported."
  di "{error}Your output SAS datafile will end in .sas7bdat instead of .sd7."
  di "{error}If you are still using an earlier version of SAS, rename the file after it is saved if you like." 
  local type= "sas"
  /* local shortfileext="shortfileext" */
 }
 else {
  local ext= ".sas7bdat"
  local type= "sas"
 }
}
else if index("`filen'", ".ssd01") & index("`filen'", ".ssd01") == length("`filen'") - 5 /*
      */ & "`c(os)'" == "Unix" & "`c(machine_type)'" != "PC" {
 local ext= ".ssd01"
 local type= "sas6"
}
else if index("`filen'", ".ssd02") & index("`filen'", ".ssd02") == length("`filen'") - 5 /*
      */ & "`c(os)'" == "Unix" & "`c(machine_type)'" == "PC" {
 local ext= ".ssd02"
 local type= "sas6"
}
else if index("`filen'", ".sd2") & index("`filen'", ".sd2") == length("`filen'") - 3  /* 
      */ & "`c(os)'" == "Windows" & "`c(machine_type)'" == "PC" {
 local ext= ".sd2"
 local type= "sas6"
}
else if index("`filen'", ".xpt") &  index("`filen'", ".xpt") == length("`filen'") - 3 {
 local ext= ".xpt"
 local type= "sasx"
}
else if index("`filen'", ".xport") & index("`filen'", ".xport") == length("`filen'") - 5 {
 local ext= ".xport"
 local type= "sasx"
}
else if index("`filen'", ".export") & index("`filen'", ".export") == length("`filen'") - 6 {
 local ext= ".export"
 local type= "sasx"
}
else if index("`filen'", ".expt") & index("`filen'", ".exp") == length("`filen'") - 3 {
 local ext= ".exp"
 local type= "sasx"
}
else if index("`filen'", ".v5x") & index("`filen'", ".v5x") == length("`filen'") - 3 {
 local ext= ".v5x"
 local type= "sasx"
}
else if index("`filen'", ".v6x") & index("`filen'", ".v6x") == length("`filen'") - 3 {
 local ext= ".v6x"
 local type= "sasx32 "
}
else if index("`filen'", ".") {
 local ext= substr("`filen'", index("`filen'", "."), length("`filen'"))
 while index("`ext'", ".") > 0 {
  local ext= substr("`ext'", index("`ext'", ".") + 1, length("`ext'"))
 }
 local ext=".`ext'"
}
if index("`filen'", ".") {
 local middle=substr("`filen'", 1, index("`filen'", "`ext'") - 1) /* middle will not end in a period */
 local filen=substr("`filen'", 1, index("`filen'", ".") - 1)
 local middle=substr("`middle'", length("`filen'")+1, length("`middle'"))
}

 if `"`filen'"' == `""' {
    // This should never be the case, but leave in just as a catch
    di `"{error} you have to specify the SAS file name when specifying a file location"'
  /* log usage of savasas */
  capture which usagelog
  if _rc == 0 {
   usagelog , type(savas) uerror(15) etime
  }
  exit 198
 }
      

****** Check for invalid SAS data file name ************
local fc= substr("`filen'", 1, 1)
// have to use inlist() since the first char is likely a letter
//  and have to split it into two since it can't handle 11 arguments!
local swn= "0"
local hsc= "0"
if inlist("`fc'", "0", "1", "2", "3", "4") | ///
   inlist("`fc'", "5", "6", "7", "8", "9")  { // name starts with a number
  local swn= "1"
}

if  index("`filen'", "~") | /// Has a bad character in name
    index("`filen'", "!") | ///
    index("`filen'", "@") | ///
    index("`filen'", "#") | ///
    index("`filen'", "$") | ///
    index("`filen'", "%") | ///
    index("`filen'", "^") | ///
    index("`filen'", "&") | ///
    index("`filen'", "*") | ///
    index("`filen'", "(") | ///
    index("`filen'", ")") | ///
    index("`filen'", "-") | ///
    index("`filen'", "+") | ///
    index("`filen'", "=") | ///
    index("`filen'", "[") | ///
    index("`filen'", "]") | ///
    index("`filen'", ":") | ///
    index("`filen'", ";") | ///
    index("`filen'", "'") | ///
    index("`filen'", "<") | ///
    index("`filen'", ">") | ///
    index("`filen'", "?") | ///
    index("`filen'", ",") | ///
    index("`filen'", "|") | ///
    index("`filen'", " ") | ///
    index("`filen'", "{") | ///
    index("`filen'", "}") {
  local hsc= "1"
}

if "`swn'" == "1" | "`hsc'" == "1" {
  if "`rename'" == "" {
    di `"{error}File name {res}"`filen'" {error}is not a valid SAS file name. *"'
    if "`swn'" == "1" {
      di `"{error}SAS file names cannot start with a number.  *"'
    }
    if "`hsc'" == "1" {
      di `"{error}SAS file names cannot contain special characters.  *"'
    }
  }
  if "`hsc'" == "1" {  
    // remove bad characters 
    foreach char in ~ ! @ # $ % ^ & * ( ) - += [ ] : ; ' < > ? , | {
      local filen= subinstr("`filen'", "`char'", "_", .)
    }
    local filen= subinstr("`filen'", "{", "_", .)
    local filen= subinstr("`filen'", "}", "_", .)
    local filen= subinstr("`filen'", " ", "_", .)

    if `"`: subinstr local filen "_" "" , all'"' == "" {  // if nothing left, meaning, person used all bad characters 
      local filen= "okpopeye"
    }
  } // end of contains bad character
  
  if "`swn'" == "1" { // name starts with a number
    if length("`filen'") == 32  {
      local filen= substr("`filen'", 2, length("`filen'"))
      local filen= "_`filen'"
    }
    else {
      local filen= "_`filen'"
    }
  } // end of if started with number 
  if "`rename'" == "" {
    di `"{error}The {res}rename {error}option will rename it for you to be: {res}"`filen'" "'
    /* log usage of saswrapper */
    capture which usagelog
    if _rc == 0 {
     usagelog , type(savas) uerror(6) etime
    }
    exit 198
  }
} /* if filen is not a valid SAS data file name */


if "`type'" == "sasx" {
 if !("`ext'" == ".xpt"    | /*
  */  "`ext'" == ".xport"  | /*
  */  "`ext'" == ".export" | /*
  */  "`ext'" == ".expt"   | /*
  */  "`ext'" == ".trans"  | /*
  */  "`ext'" == ".exp"    | /*
  */  "`ext'" == ".sasx"   | /*
  */  "`ext'" == ".v5x"    | /*
  */  "`ext'" == ".v6x")  {
  local middle= "`middle'`ext'"
  local ext= ".xpt"
  }
 if length("`filen'") > 8 & "`rename'" == "" {
  di `"{error}File name {res}"`filen'" {error}is not a valid SAS xport file name. *"'
  di `"{error}SAS xport file names have to be 8 or less characters long.  *"'
  local filen= substr("`filen'", 1, 8)
  di `"{error}The {res}rename {error}option will rename it for you to be: {res}"`filen'" {error}*"'
  /* log usage of savasas */
  capture which usagelog
  if _rc == 0 { 
   usagelog , type(savas) uerror(7) etime
  }
  exit 198
 }
 else if length("`filen'") > 8 & "`rename'" != "" {
  local filen= substr("`filen'", 1, 8)
 }

 if "`middle'" == ".dta" {
  local middle= ""
 }
 local using= "`macval(dir)'`filen'`middle'"
 local filen= "`filen'"+"`middle'"
} /* end of if type=sasx */
else {
 local using= "`macval(dir)'`filen'"
 local ext= ".sas7bdat"
 if "`type'" == "sas6" & "`c(os)'" == "Unix" & "`c(machine_type)'" != "PC" {
  local ext= ".ssd01"
 }
 else if "`type'" == "sas6" & "`c(os)'" == "Unix" & "`c(machine_type)'" == "PC" {
  local ext= ".ssd02"
 }
 else if "`type'" == "sas6" & "`c(os)'" == "Windows" {
  local ext= ".sd2"
 }
}
if "`type'" == "sas6" { 
 if length("`filen'") > 8 & "`rename'" == "" {
  di `"{error}File name {res}"`filen'" {error}is not a valid SAS version 6 file name. *"'
  di `"{error}SAS version 6 file names have to be 8 or less characters long.  *"'
  local filen= substr("`filen'", 1, 8)
  di `"{error}The {res}rename {error}option will rename it for you to be: {res}"`filen'" {error}*"'
  /* log usage of savasas */
  capture which usagelog
  if _rc == 0 { 
   usagelog , type(savas) uerror(8) etime
  }
  exit 198
 }
 else if length("`filen'") > 8 & "`rename'" != "" {
  local filen= substr("`filen'", 1, 8)
 }
}
if "`type'" != "sasx" | "`type'" != "sas6"  { 
 if length("`filen'") > 32 & "`rename'" == "" {
  di `"{error}File name {res}"`filen'" {error}is not a valid SAS file name. *"'
  di `"{error}SAS file names have to be 32 or less characters long.  *"'
  local filen= substr("`filen'", 1, 32)
  di `"{error}The {res}rename {error}option will rename it for you to be: {res}"`filen'" {error}*"'
  /* log usage of savasas */
  capture which usagelog
  if _rc == 0 { 
   usagelog , type(savas) uerror(8) etime
  }
  exit 198
 }
 else if length("`filen'") > 32 & "`rename'" != "" {
  local filen= substr("`filen'", 1, 32)
 }
}




if "`replace'" == "" & "`sascode'" == ""  {
  if index(`"`macval(dir)'"', "\") == 1 {  // Universal naming  doesn't seem to be a problem      
    capture confirm file `"`macval(dir)'`filen'`ext'"'
  }
  else {
   capture confirm file `"`macval(dir)'`filen'`ext'"'
  }
  if _rc == 0 {
    di `"{error}The SAS file: "`macval(dir)'`filen'`ext'" already exists."'
    di "{error}Use the {res}replace {error}option if you really want to replace it."
    /* log usage of savasas */
    capture which usagelog
    if _rc == 0 { 
      usagelog , type(savas) uerror(9) etime 
    }
    exit 602
  }
} // end of if replace option not used 

if "`script'" == "" {
 /* set where temp directory is */
 tmpdir 
 local tmpdir `"`r(tmpdir)'"'
 
 tempfile ddd
 if "`c(os)'" == "Windows" {
   local tfn= substr("`ddd'", length("`tmpdir'") + 1, . ) 
   local tfn= substr("`tfn'", 1, length("`tfn'") - 4 )  // remove file extension ".tmp"
   local sysjobid= substr("`tfn'", length("`tfn'") - 6, .)
   local sysjobid= "_`sysjobid'"
 }
 else {   // Unix has odd file extensions to tempfiles
   local tfn= substr("`ddd'", length("`tmpdir'") + 2, . )
   local sysjobid= substr("`tfn'", strpos("`tfn'", ".") - 6, . )
   local sysjobid= substr("`sysjobid'", 1, strpos("`sysjobid'", ".") - 1)
   local sysjobid= "_`sysjobid'"
 }
}
else if "`script'" != ""  local tmpdir `"`udir'"'

if  "`type'" == "sasx" {
 if `c(k)' > 9999 {
  di _n "{error}SAS Xport/Transport files can only handle up to 9,999 variables.        *"
  /* log usage of savasas */
  capture which usagelog
  if _rc == 0 { 
   usagelog , type(savas) uerror(10) etime
  }
  exit 103
 }
} /* end of if sasx */


* TEST FOR UNIQUE VARNAMES
* ------------------------

** test that vars will work in SAS transport and version 6 files **
local j= 1
local srenamed= 0
local verror= 0
local k= 0
local stop= 0
local sasvars ""
foreach var of varlist _all {
 local ovar= "`var'"
 local valid= upper("`var'")  /* make all renamed vars uppercase */
 ** Test for invalid SAS varnames and ** 
 ** test if variables are not unique for SAS since SAS is case insensitive ** 
 if  upper("`var'") == "_ERROR_" |      /*  invalid SAS names
  */ upper("`var'") == "_N_" |          /*
  */ upper("`var'") == "_NUMERIC_" |    /*
  */ upper("`var'") == "_CHARACTER_" |  /*
  */ upper("`var'") == "_ALL_"  { 
  local verror= 1
 } /* end of if var is an invalid SAS varname */
 if ("`type'" == "sasx" | "`type'" == "sas6") & length("`var'") > 8 {
   local verror= 1
 }
 if "`var'" != upper("`var'") {  /* don't check vars that are already upper case */
  capture rename `var' `valid'
  if _rc != 0 {
    local verror= 2
  }
  else {
   local var="`valid'"
  }
 } /* end of don't check if var already upper case */
 if "`rename'" == "" & `verror' >= 1 {
  if `j' == 1 {
   di "{error}Not all Stata variables are valid SAS variables.  *"
   di "{error}Specify the {res}rename {error}option for {help savasas:savasas} {error}to rename them. *" 
   di "{error}List of variables that need to be renamed: * "
   local stop= 1
   local j= `j'+1   
  }
  di "{res}`ovar'  *"
 } /* end of if "`rename'" == "" & verror >= 1 */
 else if "`rename'" != "" & `verror' >= 1 {
  local k= 0
  while length("`k'") < 6  {   /* make up to 99,999 attempts to rename the variable */
   if ("`type'" == "sasx" | "`type'" == "sas6") & length("`var'") > 8 {
    if `k' == 0 {  /* take first 8 characters */
     local valid= upper(substr("`var'", 1, 8))
    }
    else {
     local valid= upper(substr("`var'", 1, 8 - length("`k'"))) + "`k'"
    }
   }  /* end if sasx or sas6 */
   else {
    if `k' == 0 {
     local k= 1
    }
    local valid= upper(substr("`var'", 1, 32 - length("`k'"))) + "`k'"
   }
   capture rename `var' `valid'
   if _rc != 0 & length("`k'") == 6 {
     local verror= 1
   }
   else if _rc == 0 {
    if `j' == 1  {
     noi di "The following variables were renamed to valid SAS variable names:  * " 
     local srenamed= 1 
     local j= `j' + 1   
    }
    noi di "{res}`ovar' {txt}-> {res}`valid'    *"
    local k= "success!"
   }  /* end of if _rc == 0 */
   if "`k'" != "success!" {
    local k= `k'+1   /* count attempts to rename vars */ 
   }
  } /* end of while length(k) < 6 */
 } /* end of if rename and verror */
 if `srenamed' == 0 {   /* make sure all vars are valid */
  capture rename `var' `valid'
 }
 if `stop' == 0 {
  if `verror' == 0 {
   local sasvars "`sasvars' `ovar'"  /* keep list of vars that have original case if possible */
  }
  else if `verror' >= 1 {
   local sasvars "`sasvars' `valid'"  /* keep list of vars that have original case if possible */
  }
 } /* if foreach not stopped */
 local verror= 0
 local srenamed= 0
} /* end of foreach */

if `stop' == 1 {   /* This should not be possible. */
 if "`rename'" != "" {
  noi di "{error}ERROR: {help savasas:savasas} was unable to rename variables uniquely to shorter names. *"
 }
 /* log usage of savasas */
 capture which usagelog
 if _rc == 0 { 
  usagelog , type(savas) uerror(11) etime
 }
 exit 499
} /* end of if verror=1 */

/* rename all vars so that fdasave won't have to */
local k= 0
local stop= 0
local cvars ""
foreach valid of varlist _all {
 if length("`valid'") > 8 {
  local k= 0
  while length("`k'") < 6 {   /* make up to 99,999 attempts to rename the variable */
   if `k' == 0 {  /* take first 8 characters */
    local xptvar= upper(substr("`valid'", 1, 8))
   }
   else {
    local xptvar= upper(substr("`valid'", 1, 8 - length("`k'"))) + "`k'"
   }
   capture rename `valid' `xptvar'
   if _rc == 0  {
    local k= "success!"
   }  /* end of if _rc == 0 */
   else {
    local k= `k'+1   /* count attempts to rename vars */
   }
  } /* end of while length(k) < 6 */
 }  /* end if valid varname > 8 */
 if length("`valid'") <= 8 {
  local xptvar= "`valid'"
 }
 local vt : type `xptvar'
 if index("`vt'", "str") {
  local cvars "`cvars' `xptvar'"
 }  
} /* end of foreach */


* FIX STRING VARS
* ---------------
// remove trailing blanks in string data 
if "`cvars'" != "" {
 local i= 1
 foreach var of varlist `cvars' {
  if  `c(maxstrvarlen)' > 80 {
   capture compress `var' 
   if _rc != 0 {
     noisily {
       display as error "{helpb savasas} uses {helpb compress} and {helpb compress} failed." 
       if c(SE) & c(maxvar) < 32767 {
         display as error "increase your {helpb maxvar} setting to see if that makes {helpb compress} work."
         exit 1010
       }
       else {
         display as error "try dropping some of the long string variables."
         exit 902
       }
     }
   }
   local vt : type `var'
   if real(substr(rtrim("`vt'"), 4, length("`vt'"))) > 200 {
    if `i' == 1 {
     // because xport files have a 200 character limit and savasas uses fdasave there is a 200 character limit 
     noi di "{help savasas:savasas} {error}can only store the first 200 characters in string variables. *"
     noi di "{error}List of string variables reduced to 200:   *"
     local i= `i' + 1
    }
    noi di "{res} `var'   *"
   } /* if length > 200 */
  } /* end of if SE dataset */
  quietly replace `var'= substr(rtrim(`var'), 1, 200)  // trim off trailing blanks for all string vars 
 } /* end of foreach */
}  /* end of if there are cvars in dataset */

local xfilen= substr("`filen'", 1, 6)
if `c(k)' > 9999 {
 local vars1 ""
 local vars2 ""
 local vars3 ""
 local vars4 ""
 local i= 0
 local files= 1
 foreach var of varlist _all {
  local i= `i' + 1
  if `i' <= 9999 {
   local vars1 "`vars1' `var'"
  }
  if `i' > 9999 & `i' <= 19998 {
   local vars2 "`vars2' `var'"
  }
  else if `i' > 19998 & `i' <= 29997 {
   local vars3 "`vars3' `var'"
  }
  else if `i' > 29997 {
   local vars4 "`vars4' `var'"
  }
 }  /* end of foreach */
 local sysjobid1= "`sysjobid'1"
 local xfilen1= substr("`filen'", 1, 6) + "1"
 if `i' > 9999  {
  local files= 2
  local sysjobid2= "`sysjobid'2"
  local xfilen2= substr("`filen'", 1, 6) + "2"
 }
 if `i' > 19998  {
  local files= 3
  local sysjobid3= "`sysjobid'3"
  local xfilen3= substr("`filen'", 1, 6) + "3"
 }
 if `i' > 29997  {
  local files= 4
  local sysjobid4= "`sysjobid'4"
  local xfilen4= substr("`filen'", 1, 6) + "4"
 }
}  /* if > 9999 vars */

if "`type'" == "sas" {
  local eng= "`rver'"
}
else if "`type'" == "sas6" {
 local eng= "v6"
}
else if "`type'" == "sasx" {
 local eng= "xport"
}

if "`files'" == "" {
 local temp `"`macval(tmpdir)'`sysjobid'"'
 if "`sascode'" == "" {  /* save xpt file to temp dir */
  local raw `"`macval(temp)'"'
 }
 else {  /* save xpt file to using dir */
  local raw `"`macval(dir)'`filen'"'
  local raw0 `"`macval(dir)'`xfilen'"'
 }
}
else {
 foreach file of numlist 1/`files' {
  local temp `"`macval(tmpdir)'`sysjobid'"'
  local raw`file' `"`macval(tmpdir)'`sysjobid`file''"'
  local raw `"`macval(tmpdir)'`sysjobid'"'
  if "`sascode'" != ""  {  /* save xpt file to using dir */
   local raw`file' `"`macval(dir)'`xfilen`file''"'
   local raw       `"`macval(dir)'_`xfilen'"'
  }
 } /* end of foreach file */
} /* end of else multiple files */


* RUN CHECK REPORT
* ----------------
  if "`check'" != "" {
    tempfile xpt_ready 
    quietly save "`xpt_ready'"
    restore, preserve   /* do check on original data */
     if "`script'" == "script" {  
       if "`eng'" == "`xport'" {
         /* if xport file then filen may have periods in it */
         local filenx=substr("`filen'", 1, index("`filen'", ".") - 1)
         log using `"`macval(dir)'`filenx'_STATAcheck.log"', replace
       }
       else if "`eng'" != "`xport'" {
        log using `"`macval(dir)'`filen'_STATAcheck.log"', replace
       }
     } /* if running savasas from script */
     if "`eng'" == "`xport'" {
       di `"Compare results with SAS output: `macval(dir)'`filenx'_SAScheck.lst "'
       global S_FN= "`filenx'"
     }
     else if "`eng'" != "`xport'" {
       di `"Compare results with SAS output: `macval(dir)'`filen'_SAScheck.lst "'
       global S_FN= "`filen'"
     }
     if `srenamed' == 1  { /* if any vars were renamed */
       di "NOTE: The Stata variables here may not match the SAS variables "
       di "      because the SAS variables may have been renamed. "
     }
     local five_n= 5
     if _N < 5 {
       local five_n= _N
     }  
     // no reason to set more off because if user quits no temp files have been written yet
     // data already subset
     summarize 
     describe 
     list in 1/`five_n' 
     if "`script'" == "script" {  
       log close
     }
     use `xpt_ready', clear  // though no reason to have to clear since data didn't change!
  } /* end of if check */


* WRITE SAS PROGRAM TO READ IN DATA
* ---------------------------------
savasas_sas , dir(`dir') sysjobid(`sysjobid') filen(`filen') raw(`raw') ext(`ext')                   ///
                          engine(`eng') rver(`rver') `check' `sascode' `formats' middle(`middle')    ///
                          sysjobid1(`sysjobid1')  sysjobid2(`sysjobid2') sasvars(`sasvars')          ///
                          sysjobid3(`sysjobid3') sysjobid4(`sysjobid4') files(`files')               ///
                          raw0(`raw0') raw1(`raw1') raw2(`raw2') raw3(`raw3') raw4(`raw4')           ///
                          `shortfileext' xfilen(`xfilen') xfilen1(`xfilen1') xfilen2(`xfilen2')      ///
                          xfilen3(`xfilen3') xfilen4(`xfilen4')                                      ///   
                          vars1(`vars1') vars2(`vars2') vars3(`vars3') vars4(`vars4') messy(`messy') ///
                          `saswrapper' saswrap_data(`saswrap_data')
		

* SAVE DATA
* ---------
/* min and max values will be tested by fdasave */
if "`files'" == "" {
  if "`sascode'" == "" {
   quietly fdasave "`raw'", rename vallabfile(none) replace
  }
  else {
   quietly fdasave "`raw0'", rename vallabfile(none) replace
  }
}
else if "`files'" != "" {
 foreach file of numlist 1/`files' {
  local nvars : word count "`vars`file''"
  quietly fdasave `vars`file'' using "`raw`file''", rename vallabfile(none) replace
 }
}

if "`sascode'" == "" {
 // if replacing SAS file then see if user has permission to do so 
 if index(`"`macval(dir)'"', "\") == 1 {  // Universal naming doesn't seem to be a problem       
    capture confirm file `"/`macval(dir)'`filen'`ext'"'
 }
 else {
   capture confirm file `"`macval(dir)'`filen'`ext'"'
 }
 if _rc == 0 {
   if "`script'" == "" {
     capture erase `"`macval(dir)'`filen'`ext'"'
   }
   if _rc != 0 {
     di ""
     di `"{error}The SAS file: `macval(dir)'`filen'`ext' cannot be replaced."'
     di `"{error}Check your directory/folder permissions and file permissons."'
     /* log usage of savasas */
     capture which usagelog
     if _rc == 0 { 
      usagelog , type(savas) uerror(13) etime
     }
     exit 608 
   }
 } /* end of if file exists */

 * RUN SAS
 * -------
 if "`c(os)'" == "Unix" /* or Linux */ {
  shell "`usas'" "`temp'_infile.sas"       -log "`temp'_infile.log"
  run "`temp'_infile_report.do"
 } /* end of if Unix */
 else if "`c(os)'" == "Windows" /* Windows */ {
  shell `wsas' "`temp'_infile.sas" -nologo -log "`temp'_infile.log"
  run "`temp'_infile_report.do"
 } /* end of if Windows */
 sas_rep  /* run the SAS report */
 if "`r(sas_rep_error)'" != "" {
   local messy "messy"
 }
 if "`messy'" == "" {
  capture erase "`temp'_infile.sas"
  capture erase "`temp'_infile.log"
  capture erase "`temp'_infile_report.do"
  capture erase "`temp'_formats.txt"
  if "`files'" == "" {  // if only 1 xpt file created
   capture erase "`temp'.xpt"   
  }
  else {
   foreach file of numlist 0/`files' { // if multiple xpt files created
    capture erase "`raw`file''.xpt"
   }
  } /* end of else */
 } /* end of messy */
 else  if "`messy'" != "" & "`script'" == "" {
  di _n "{res}You have requested {help savasas:savasas} not to delete the intermediary files created by savasas:"
  di _n `"in directory: `tmpdir'"'
  dir `"`temp'*"'
  if "`files'" != "" {
    dir `"`raw'*.xpt"'
  }

  if "`c(console)'" == "" {  // not in console mode or batch mode
    if "`c(os)'" != "Windows" {  // sysjobid starts with an underscore in savasas
      di `"{res} {stata usesasdel `"`tmpdir'"' `sysjobid' :Click here to erase them all.} "'
    }
    if "`c(os)'" == "Windows" {
      local usesasdeldir : subinstr local tmpdir `":"' `"\\\`= char(58)'"', all
                                // sysjobid starts with an underscore in savasas
      di `"{res} {stata usesasdel `"`usesasdeldir'"' `sysjobid' :Click here to erase them all.} "'
    }
  }  // not in console or batch mode

 }
} /* end of if not wanting only sascode */
else if "`sascode'" == "sascode" {  
 if "`files'" == "" {  // if only 1 xpt file created
   if index("`raw0'", "\") == 1 {  // Universal naming doesn't seem to be a problem    
    capture confirm file `"/`macval(raw0)'.xpt"'
   }
   else {
    capture confirm file "`raw0'.xpt"
   }
   if _rc == 0 { 
    di `"{txt}The xport data file you requested is:  *"'
    di `"{res} "`raw0'.xpt"  *"'
   }
   else if _rc != 0 {
    di `"{help savasas:savasas} {error}did not save:  *"'
    di `"{txt} "`raw0'.xpt" * "'
   }
 }
 else { // more than one xpt file created
   foreach file of numlist 1/`files' {
     if index("`raw`file''", "\") == 1 {  // Universal naming doesn't seem to be a problem    
       capture confirm file `"/`macval(raw`file')'.xpt"'
     }
     else {
       capture confirm file "`raw`file''.xpt"
     }
     if _rc == 0 { 
       if `file' == 1  di `"{txt}The xport data files you requested are:  *"'
       di `"{res} "`raw`file''.xpt"  *"'
     }
     else if _rc != 0 {
       if `file' == 1  di `"{help savasas:savasas} {error}did not save:  *"'
       di `"{txt} "`raw`file''.xpt" * "'
     }
   }
 }
 if index("`raw'", "\") == 1 {  // Universal naming  doesn't seem to be a problem 
  capture confirm file "/`macval(raw)'_infile.sas" 
 }
 else capture confirm file "`raw'_infile.sas"
 if _rc == 0 { 
  di `"{txt}The SAS program to read in the xport data file is: *"'
  di `"{res} "`raw'_infile.sas"  *"'
 }
 else if _rc != 0 {
  di `"{help savasas:savasas} {error}did not save:"'
  di `"{txt} "`raw'_infile.sas" * "'
 }
} /* end of if sascode=sascode */

return local sasfile `"`macval(dir)'`filen'`ext'"'

restore 

/* log usage of savasas */
capture which usagelog
if _rc == 0 {
 usagelog , type(savas) uerror(0) etime
}

end /* end of savasas */


program define savasas_sas
syntax [varlist]  [, engine(string) rver(string) dir(string) sysjobid(string) ext(string) files(string)  ///
                      sascode filen(string) CHeck FORmats raw(string) middle(string)                     ///
                      sysjobid1(string) sysjobid2(string) sysjobid3(string) sysjobid4(string)            ///
                      raw0(string) raw1(string) raw2(string) raw3(string) raw4(string) sasvars(string)   ///
                      xfilen(string) xfilen1(string) xfilen2(string) xfilen3(string) xfilen4(string)     /// 
                      vars1(string) vars2(string) vars3(string) vars4(string) shortfileext messy(string) ///
                      saswrapper saswrap_data(string) ] 
 version 8

quietly {
	file open sasfile using "`raw'_infile.sas", replace text write
	* DATA LIST
	* ---------
   
        if "`sascode'" == "" { 
          local in_dset `"`raw'.xpt"'
        }
        else {
          local in_dset `"`raw0'.xpt"'
        }

        file write sasfile _n `"/********************************************************"' /*
                        */ _n `"** program: `raw'_infiles.sas  "'                           /*
                        */ _n `"** programmer: savasas  "'                                  /*
                        */ _n `"** date: `c(current_date)' "'                               /*
                        */ _n `"** comments: SAS program to read and label:  "'             /*
                        */ _n `"**  `in_dset' "'                                            /*
                        */ _n `"**           which contains data from a Stata dataset"'     /*
                        */ _n `"********************************************************/"' /*
                        */ _n _n `"options nofmterr nocenter linesize=max;"'   _n _n             
        
        file write sasfile _n `" ** this version of _infile_report.do will be overwritten if all goes well. **; "'   
        file write sasfile _n `" data _null_;"' _n `"file "`raw'_infile_report.do"; "'   ///
           _n `" put "capture program drop sas_rep"; "'   ///
           _n `" put "program define sas_rep, rclass"; "'  ///
           _n `" put "di as err "" SAS failed to create `filen' "" "; "'  ///
           _n `" put "di as err "" Look at {view `raw'_infile.log:`raw'_infile.log} to see what error occurred. "" "; "'  
        if "`messy'" == "" { 
          file write sasfile _n `" put "di as err "" The {help savasas:savasas} option messy is now on. "" "; "'  
        } 
        file write sasfile _n `" put "local sas_rep_error= 1 "; "' ///
           _n `" put "return local sas_rep_error ""\`sas_rep_error\'"" "; "' ///
           _n `" put "end"; "'


       if "`engine'" == "v6" {
        file write sasfile _n _n `"libname library v6 "`dir'" `shortfileext';  "' _n _n 
        file write sasfile _n _n `"options fmtsearch=(out.`filen');  "' _n _n 
       }
       else {
        file write sasfile _n _n `"libname library `engine' "`dir'" `shortfileext';  "' _n _n 
        file write sasfile `"options fmtsearch=(out.`filen');  "' _n _n 
       }

       if "`engine'" == "`rver'" | "`engine'" == "v6"  {
         file write sasfile `"libname out `engine' "`dir'" `shortfileext' ;  "' _n _n 
       }
       else if "`engine'" == "xport" {
         file write sasfile `"libname out xport "`macval(dir)'`filen'`ext'";  "' _n _n 
          /* if xport file then filen may have periods in it then get rid of them
           *  since filen no longer needs them now that libname out defined */
         if index("`filen'", ".") {
          local filen=substr("`filen'", 1, index("`filen'", ".")-1)
         }
       }

     if `c(k)' <= 9999 { 
       if "`sascode'" == "" {
        file write sasfile `"libname raw xport "`raw'.xpt";  "' _n _n
       }
       else {
        file write sasfile `"libname raw xport "`raw0'.xpt";  "' _n _n
       }
     }  /* if <= 9999 vars */
     else if `c(k)' > 9999 { 
      foreach file of numlist 1/`files' {
       file write sasfile _n _n `"libname raw`file' xport "`raw`file''.xpt";  "' _n  _n
      } /* end of foreach file */
      if "`sascode'" == "" {
        file write sasfile `" /* do observational merge to create one big file */  "'  /*
        */ _n `" data `sysjobid'; "'  /*
        */ _n `"  merge raw1.`sysjobid1' raw2.`sysjobid2' "'
       if `c(k)' > 19998 { 
        file write sasfile `" raw3.`sysjobid3' "' 
         if `c(k)' > 29997 { 
          file write sasfile `" raw4.`sysjobid4' "' 
         } /* end of if > 29997 vars */
        } /* end of if > 19998 vars */
       file write sasfile `";"' _n `"run;"'
      } /* end of if not sascode  */
      else {
        file write sasfile `" /* do observational merge to create one big file */  "'  /*
        */ _n `" data `xfilen'; "'  /*
        */ _n `"  merge raw1.`xfilen1' raw2.`xfilen2' "'
       if `c(k)' > 19998 {
        file write sasfile `" raw3.`xfilen3' "'
         if `c(k)' > 29997 {
          file write sasfile `" raw4.`xfilen4' "'
         } /* end of if > 29997 vars */
        } /* end of if > 19998 vars */
       file write sasfile `";"' _n `"run;"'
      } /* end of if sascode  */
     } /* end of if > 9999 vars */



   * CREATE USER-DEFINED FORMATS FROM VALUE LABELS
   * ---------------------------------------------
    local hasvl 0
    if "`formats'" != "" {
      label dir 
      if "`r(names)'" != "" {  // dataset has value labels but not sure if they are used in data
        local names `"`r(names)'"'
        local hasvl= 1
        /* establish what is the max length of a user-defined format name
         *  based on what version of SAS datafile is desired */
        if index("`engine'", "v8") | ///
           index("`engine'", "v6") | ///
           index("`engine'", "xport")   local ml= 8
        else local ml= 32

        // create a list of all value labels used in data set that are defined
        //  a variable can be assigned a label that has not been defined...this is not good
        local all_vlabs `""'
        // create a list of all variables with value labels associated to them 
        //  that are actually defined
        local lvvars `""'
        foreach var of varlist `varlist' {
          local lbl : value label `var'
          if `"`lbl'"' != "" {  // if variable has value label associated to it
            capture label list `lbl'  // check to see if exists as defined label  
            // if it doesn't give up and move on!
            if _rc == 111 {  // label isn't defined
              local lbl ""
              // remove association of label to variable since it isn't defined
              label value `var'
            }
            else {   // var has label that is defined
              // all vars with defined labels need to be sent to sav_lvchk
              local lvvars `"`lvvars' `var'"'  // create list of vars with value labels
              // label exists and not already listed 
              if `: list posof `"`lbl'"' in local(all_vlabs)' == 0  { 
                local all_vlabs `"`all_vlabs' `lbl'"'
              }
            }
          }
        } // end of foreach var

        // drop defined labels that are not associated to variables in current dataset
        foreach lbl of local names {
          if `: list posof `"`lbl'"' in local(all_vlabs)' == 0  { 
             label drop `lbl'
          }
        }
        // re-create local macro names now that it's cleaned up
        label dir
        local names `"`r(names)'"'
      } /* end of if dataset has value labels */
      else { 
        local hasvl 0 
      }

      if "`r(names)'" != "" {  // if dataset really has value labels
        // check and rename value labels if necessary 
        capture noisily sav_lvchk, ml(`ml') vars(`lvvars')

        if _rc == 499 {  /* value labels were not uniquely named */
          if "`script'" == "" {
            erase "`raw'_infile.sas"
          }
          /* log usage of savasas */
          capture which usagelog
          if _rc == 0 { 
            usagelog , type(savas) uerror(12) etime
          }
          capture file close sasfile 
          exit 499
        }


        if `= real(substr("`rver'", 2, length("`rver'")))' > 8 {
          file write sasfile _n `"options NoQuoteLenMax;"' // new option in SAS 9	
	}
	else if `c(version)' >= 9   {
	  noi di as res _n `"WARNING: Value labels longer than 200 characters may be truncated. *"' _n
	}

        sav_labs_data `varlist', fhandle(sasfile) ml(`ml') filen(`filen') raw(`"`raw'"') 

      } /* end of if dataset really has value labels */
      else { 
        local hasvl 0 
      }
    }   /* end of if formats to be created from value labels */

       if "`engine'" != "xport" { 
        file write sasfile  _n _n `"data out.`filen' "' ///
           `" (label= "-savasas- created dataset on %sysfunc(date(), date9.)" "' 
        if "`engine'" != "v6" {
         file write sasfile `" rename=("' _n
         local i= 1
         tokenize "`sasvars'"  /* good SAS variable names */
         foreach var of varlist _all {
          file write sasfile `" `var'= ``i''"' 
          if mod(`i', 5) == 0 {
           file write sasfile  _n
          }
          local i= `i' + 1
         } /* end of foreach */
         file write sasfile  _n `" ));"' _n `" length "'  
        } /* if not v6 engine */
        else if "`engine'" == "v6" {  /* no need to rename vars for v6 files */
         file write sasfile  _n `");"' _n `" length "'  
        }
       }
       else if "`engine'" == "xport" {  /* don't need vars renamed or sort info */
        file write sasfile  _n _n `"data out.`filen' "' ///
        `" (label= "-savasas- created dataset on %sysfunc(date(), date9.)" );"' _n `" length "'
       }

     if "`compress'" != ""  {
       * SET VARS TO MINIMUM DATATYPE
       * ----------------------------
       /*  -compress- needs to be run after str vars are truncated to 200 chars because otherwise 
        *    -fdasave- will still see them as too long to be saved as a SAS xport file. */
       capture compress   /* so says Loren */
       if _rc != 0 {
         noisily {
           display as error "{helpb savasas} uses {helpb compress} and {helpb compress} failed." 
           if c(SE) & c(maxvar) < 32767 {
             display as error "increase your {helpb maxvar} setting to see if that makes {helpb compress} work."
             capture file close sasfile 
             exit 1010
           }
           else {
             display as error "try dropping some of the long string variables."
             capture file close sasfile 
             exit 902
           }
         }
       }
     }  // end of if compress option specified


     local j 1
     local verror= 0
     foreach var of varlist `varlist' { 
      local storage : type `var'
      if index("`storage'", "str") == 0 { 
       if ("`storage'" == "float") |  ("`storage'" == "double") { 
        local len= 8 
       }
       else if "`storage'" == "byte" { 
        local len= 3 
       }
       else if "`storage'" == "int" { 
        local len= 4 
       }
       else if "`storage'" == "long" { 
        local len= 6 
       }
       file write sasfile `" `var' `len'"' 
      }  /* end of if not string */
      else if index("`storage'", "str") == 1 { 
       local len= substr("`storage'", 4, length("`storage'"))
       file write sasfile `" `var' $`len'"' 
      }
      if (mod(`j', 8) == 0) {  /* print 8 vars per line */
       file write sasfile _n
      }
      local j= `j' + 1
     }  /* end of foreach */
     if `verror' == 1 {
      file close sasfile
      exit 499
     }
     if `c(k)' <= 9999 {
      if "`sascode'" == "" {
        file write sasfile _n `"  ;;;"' _n `" set raw.`sysjobid'; "' _n
      }
      else {
        file write sasfile _n `"  ;;;"' _n `" set raw.`xfilen'; "' _n
      }
     }
     else if `c(k)' > 9999 {
      if "`sascode'" == "" {
        file write sasfile _n `"  ;;;"' _n `" set `sysjobid';"' _n
      }
      else {
        file write sasfile _n `"  ;;;"' _n `" set `xfilen';"' _n
      }
     }

	* VARIABLE LABEL
	* --------------

	file write sasfile _n _n " LABEL "
	foreach var of varlist `varlist' {
         local varlab : variable label `var'
         // add spaces around varlab so that varlab can start with a right quote and contain a right parentheses
         local varlab= trim(`" `varlab' "')  
         if `"`varlab'"' != "" {
          // add spaces around varlab so that varlab can start with a right quote and contain a right parentheses
          if index(`" `varlab' "', `"'"') {
          /* substitute 2 single quotes for one single quote */
          local varlab= subinstr(`" `varlab' "', `"'"', `"''"', .)
          }
          //  enclosing the var label in single quotes keeps macro vars or calls 
          //   to macros from happening
          if index(`" `varlab' "', "'") == 2 {
           /* if varlab starts with a single right quote, add space 
            * before it so that it doesn't end the left compound quote in the 
            * file write of varlabel. escaping it doesn't escape it */
            file write sasfile _n (upper("`var'")) `"=' `varlab' ' "'
          } 
          else if substr(`"`varlab'"', length(`"`varlab'"'), 1) == `"""' {
           // add a space at the end to separate the last double quote and the right quote
           file write sasfile _n (upper("  `var'")) `"='`varlab' ' "'
          }
          else {
           file write sasfile _n (upper("  `var'")) `"='`varlab'' "'
          }
	 } /* end of if varlab exists */
        } /* end of foreach */
	file write sasfile _n " ;;;"
  
	* ASSIGN VALUE LABELS
	* -------------------
	if `hasvl' == 1 { 
 	 file write sasfile _n _n "format "
         local j 1
         foreach var of varlist `varlist' {
          local lbl : value label `var'
          capture label list `lbl'  // check to see if exists as defined label  
          // if it doesn't, then give up and move on!
          if _rc == 111  local lbl ""
          if `"`lbl'"' != "" {
	   file write sasfile " `var' `lbl'."
           if (mod(`j', 5) == 0) {  /* print 5 vars per line */
            file write sasfile _n
           }
          local j= `j' + 1
          } /* end of if var has label */
         } /* end foreach */

	 file write sasfile _n " ;;;"
	}  /* end of if variables have value labels */


	* NON-USER DEFINED FORMATS
	* ------------------------ 

	 file write sasfile _n _n "format "

       local j 1
       foreach var of varlist `varlist' {
        local storage : type `var'
        local fmt : format `var'
        local fmt= trim("`fmt'")
        if "`formats'" != "" {   
         local lbl : value label `var'
         capture label list `lbl'  // check to see if exists as defined label
         // if it doesn't give up and move on!
         if _rc == 111  local lbl ""
        }
        local format= ""
        /* only assign formats to vars with no value label */
        if !index("`storage'"', "str") & `"`fmt'"' != "" & `"`lbl'"' == ""  {

         if substr(`"`fmt'"', length(`"`fmt'"'), 1) == "f" {
          local format= substr("`fmt'", 2, length("`fmt'") - 2)
          if ![regexm(`"`format'"', "[a-zA-Z]") | missing("`format'")] {
            if `format' > 18 {
             local format= "18."
            }
            local format= "`format'"
          }
         }
         else if substr(`"`fmt'"', length(`"`fmt'"')-1, 2) == "0g" {
          local format= substr(`"`fmt'"', 2, strpos(`"`fmt'"', ".") - 2) + "."
          if ![regexm(`"`format'"', "[a-zA-Z]") | missing("`format'")] {
            if `format' > 18 {
             local format= "18."
            }
            local format= "BEST" + "`format'"
          }
         }
         else if substr(`"`fmt'"', length(`"`fmt'"'), 1) == "c" {
          local format= substr(`"`fmt'"', 2, length(`"`fmt'"', ".") - 3)
          if ![regexm(`"`format'"', "[a-zA-Z]") | missing("`format'")] {
            if regexm(`"`format'"', "-") {
              local format= regexr("`format'", "-", "") 
            }
            if `format' > 18 {
             local format= "18."
            }
            local format= "COMMA" + "`format'" 
          }
         }
         /* old way: else if inlist(`"`fmt'"', "%dDlY", "%dDmY", "%dDMY",  "%ddlY", "%ddmY", "%ddMY")   {  **/
         else if regexm(`"`fmt'"', "^%tdDl(y|Y)$|^%tdDm(y|Y)$|^%tdDM(y|Y)$|^%tddl(y|Y)$|^%tddm(y|Y)$|^%tddM(y|Y)$") ///
               | regexm(`"`fmt'"', "^%dDl(y|Y)$|^%dDm(y|Y)$|^%dDM(y|Y)$|^%ddl(y|Y)$|^%ddm(y|Y)$|^%ddM(y|Y)$") { 
          local format= "DATE7." 
         }
         /** old way: else if inlist(`"`fmt'"', "%dDlCY", "%dDmCY", "%dDMCY",  "%ddlCY", "%ddmCY", "%ddMCY")   {   **/ 
         else if regexm(`"`fmt'"', "^%tdDl(cy|Cy|cY|CY)$|^%tdDm(cy|Cy|cY|CY)$|^%tdDM(cy|Cy|cY|CY)$|^%tddl(cy|Cy|cY|CY)$|^%tddm(cy|Cy|cY|CY)$|^%tddM(cy|Cy|cY|CY)$") ///   
               | regexm(`"`fmt'"', "^%dDl(cy|Cy|cY|CY)$|^%dDm(cy|Cy|cY|CY)$|^%dDM(cy|Cy|cY|CY)$|^%ddl(cy|Cy|cY|CY)$|^%ddm(cy|Cy|cY|CY)$|^%ddM(cy|Cy|cY|CY)$") {
          local format= "DATE9." 
         }
         else if inlist(`"`fmt'"', "%tdD/N/Y", "%tdD/N/y", "%dD/N/Y", "%dD/N/y") { 
          local format= "DDMMYY8." 
         }
        /** old way: else if `"`fmt'"' == "%dD/N/CY" {  **/
         else if regexm(`"`fmt'"', "^%tdD/N/(cy|Cy|cY|CY)$|^%dD/N/(cy|Cy|cY|CY)$") { 
          local format= "DDMMYY10." 
         }
         else if inlist(`"`fmt'"', "%tdN/D/Y", "%tdN/D/y", "%dN/D/Y", "%dN/D/y") { 
          local format= "MMDDYY8." 
         }
         /** old way: else if `"`fmt'"' == "%dN/D/CY" {  **/
         else if regexm(`"`fmt'"', "^%tdN/D/(cy|Cy|cY|CY)$|^%dN/D/(cy|Cy|cY|CY)$") { 
          local format= "MMDDYY10." 
         }
         else if inlist(`"`fmt'"', "%tdYND", "%tdyND", "%dYND", "%dyND") { 
          local format= "YYMMDD6." 
         }
         else if inlist(`"`fmt'"', "%tdY-N-D", "%tdy-N-D", "%dY-N-D", "%dy-N-D") { 
          local format= "YYMMDD10." 
         }
         else if regexm(`"`fmt'"', "^%td(cy|Cy|cY|CY)-N-D$|^%d(cy|Cy|cY|CY)-N-D$") { 
          local format= "YYMMDD10." 
         }
         else if inlist(`"`fmt'"', "%tdd", "%dd") { 
          local format= "DAY." 
         }
         else if inlist(`"`fmt'"', "%tdl", "%dl") { 
          local format= "MONTH." 
         }
         else if inlist(`"`fmt'"', "%tdY", "%tdy", "%dY", "%dy") { 
          local format= "YEAR2." 
         }
         else if regexm(`"`fmt'"', "^%td(cy|Cy|cY|CY)$|^%d(cy|Cy|cY|CY)$") { 
          local format= "YEAR4." 
         }
         else if inlist(`"`fmt'"', "%tdM", "%dM") { 
          local format= "MONNAME." 
         }
         else if inlist(`"`fmt'"', "%tdlY", "%tdly", "%dlY", "%dly") { 
          local format= "MONYY5." 
         }
         else if regexm(`"`fmt'"', "^%tdl(cy|Cy|cY|CY)$|^%dl(cy|Cy|cY|CY)$") { 
          local format= "MONYY7." 
         }
         else if inlist(`"`fmt'"', "%tdD", "%dD") { 
          local format= "WEEKDAY." 
         }
         else if inlist(`"`fmt'"', "%td", "%d") { 
          local format= "WORDDATE." 
         }
         else if inlist(`"`fmt'"', "%tdYl", "%tdyl", "%dYl", "%dyl") { 
          local format= "YYMON5." 
         }
         /** old way: else if `"`fmt'"' == "%dCYl"    {  **/
         else if regexm(`"`fmt'"', "^%td(cy|Cy|cY|CY)l$|^%d(cy|Cy|cY|CY)l$") { 
          local format= "YYMON7." 
         }
         else if regexm(`"`fmt'"', "^%td(cy|Cy|cY|CY)-q$|^%d(cy|Cy|cY|CY)-q$|^%td(cy|Cy|cY|CY)/q$|^%d(cy|Cy|cY|CY)/q$") { 
          local format= "YYQR." 
         }
         else if strpos(`"`fmt'"', "%td") == 1 | strpos(`"`fmt'"', "%d") == 1  {   // the catch-all date format
          local format= "MMDDYY10." 
         }

	 file write sasfile " `var' `format'"
         if (mod(`j', 5) == 0) {  /* print 5 vars per line */
          file write sasfile _n
         }
         local j= `j' + 1
        } /* end of if var has a format */
       } /* end foreach */

       file write sasfile _n "  ;;; " _n "run;" _n ///
        " %let lib_error=&syserr.; " _n _n 


   * CHECK SAS DATA
   * --------------
       if "`check'" != "" {
        noi di " "
        noi di `" You have requested savasas to generate a check file from SAS. * "'
        if "`engine'" == "xport" {
         noi di `"  The file is: "{res}`macval(dir)'`filen'`middle'_SAScheck.lst" * "'
        }
        else {
         noi di `"  The file is: "{res}`macval(dir)'`filen'_SAScheck.lst" * "'
        }
        noi di " "
        if "`engine'" == "xport" {
         file write sasfile _n `"proc printto print= "`macval(dir)'`filen'`middle'_SAScheck.lst" new; "' ///
            _n _n `" title "data= `macval(dir)'`filen'`middle': Compare results with Stata output."; "'   
        }
        else if "`engine'" != "xport" {
         file write sasfile _n `"proc printto print= "`macval(dir)'`filen'_SAScheck.lst" new; "' ///
            _n _n `" title "data= `macval(dir)'`filen': Compare results with Stata output."; "'   
        }
        file write sasfile  _n _n `" proc means    data= out.`filen'; run;"'      ///
            _n _n `" proc contents data= out.`filen'; run;"'      ///
            _n _n `" proc print    data= out.`filen' (obs=5); run; "'  ///
            _n _n `" proc printto; run; "' _n
       } /* end of checking */
  
   if "`sascode'" == "" {
      local out= "out."
      if "`engine'" == "xport" {
        file write sasfile _n `"data `filen';"' _n `" set out.`filen'; "' _n "run;" _n
        local out="work."
      }

       file write sasfile _n `"data test;"' _n `"call symput("N", compress(put(___lo___, 10.)));"'  ///
           _n `" stop; "' _n `"set `out'`filen' nobs=___lo___; "'  _n `" run; "' _n               ///
           _n `"proc contents data= test out= contents noprint ;"' _n `"run; "' _n                  ///
           _n `"data _null_;"' _n `"call symput("nvars", compress(put(___lo___, 5.)));"'            ///
           _n `"stop;"' _n `"set contents nobs=___lo___;"' _n `"run; "' _n                        ///
           _n _n `"data _null_;"' _n `"file "`raw'_infile_report.do"; "'                          ///
           _n `" put "capture program drop sas_rep"; "'                                           ///
           _n `" put "program define sas_rep"; "'

      if "`engine'" == "`rver'" {
         local ext= ".sas7bdat"
      }
      else if "`engine'" == "v6" {
       if "`c(os)'" == "Unix" & "`c(machine_type)'" != "PC" {  /* Unix */
         local ext= ".ssd01"
        }
       if "`c(os)'" == "Unix" & "`c(machine_type)'" == "PC" {  /* Linux */
         local ext= ".ssd02"
        }
       else {
        local ext= ".sd2"  /* Windows */
       }
      } /* end of if v6 */
      else if "`engine'" == "xport" {
        local filen= "`filen'" + "`middle'"
      } /* end of if xport */
    
      if index("`macval(dir)'", "\") == 1 {  // Universal naming is an issue here since 
       // this code writes code.  Stata sees / as a dir separator no matter the OS.
       // so add / since one \ will be lost
       local cdir `"/`macval(dir)'"'  
       file write sasfile _n /* 
        */ _n `"put "capture confirm file ""`macval(cdir)'`filen'`ext'"" "; "'  _n                       
      }                    
      else {              
       file write sasfile _n /* 
       */ _n `"put "capture confirm file ""`macval(dir)'`filen'`ext'"" "; "'   _n 
      }               
       file write sasfile _n ///
          _n `"put " if _rc == 0 { "; "'  _n                                                           ///
          _n `"put " di ""{help savasas:savasas} {txt}successfully saved the SAS file: *"""; "'_n    
      if "`saswrapper'" == "" {
         file write sasfile _n ///
          _n `"put " di ""    {res}`macval(dir)'`filen'`ext'   {txt}  *"""; "'   _n                  
      }
      else {
         file write sasfile _n ///
          _n `"put " di ""    {res}`saswrap_data' in the SAS WORK library """; "'   _n                  
      }
       file write sasfile _n ///
          _n `"put " di ""{res}SAS &sysver. {txt}reports that the dataset has {res}&N {txt}observations "' _n ///
                        `"and {res}&nvars {txt}variables.     *"" "; "'   _n                         ///
          _n `"put "capture which usagelog"; "'   _n                                                 ///
          _n `"put " if _rc == 0 {"; "'  _n                                                            ///
          _n `"put "  usagelog , type(savas) message(""&sysuserid.  Output SAS dataset has &N obs and &nvars vars"")"; "' _n ///
          _n `"put " }"; "'  _n                                                                      ///
          _n `"put "}"; "' _n

          
        file write sasfile _n `" put "end"; "' _n  `"run;"' _n
   }  /* end of if sascode not wanted */


  * CLOSE SASFILE
  * -------------
       file close sasfile
       if `hasvl' == 1 & "`saswrapper'" == "" {
	noi di _n "{txt}SAS formats catalog file has been created:       *"
        if "`engine'" == "`rver'" & "`shortfileext'" == "" {
         noi di " {res}`macval(dir)'`filen'.sas7bcat  *"
        }
        else if "`engine'" == "v8" & "`shortfileext'" != "" {
         noi di " {res}`macval(dir)'`filen'.sc7  *"
        }
        else if "`engine'" == "v6" & "`c(os)'" == "Windows" {
         noi di " {res}`macval(dir)'`filen'.sc2  *"
        }
        else if "`engine'" == "v6" & "`c(os)'" == "Unix" & "`c(machine_type)'" == "PC" {  /* Linux */
         noi di " {res}`macval(dir)'`filen'.sct02  *"
        }
        else if "`engine'" == "v6" & "`c(os)'" == "Unix" & "`c(machine_type)'" != "PC" {  /* Unix */
         noi di " {res}`macval(dir)'`filen'.sct01  *"
        }
	noi di "{txt}Add the following SAS statements to the SAS program that    *"
        noi di "{txt}uses {res}`macval(dir)'`filen'`ext' {txt}:  * "
	noi di `"{res} libname in `engine' "`macval(dir)'" `shortfileext';  {txt}*"'
	noi di `"{res} options fmtsearch=(in.`filen');  {txt}*"'
       }
} /* end of quietly */
		
end




* CHECK THAT STATA VALUE LABEL NAMES CAN BE MADE INTO SAS FORMAT NAMES
* IF SO, THEN RENAME 
* --------------------------------------------------------------------

program sav_lvchk
version 8
syntax , ml(integer) vars(varlist)

        local ren 0
        local flag5= 0
        local bad_labs `" "'
        local names `"`r(names)'"'
        local renamed "" 
        local orig_names ""


        foreach var of varlist `vars' {
          local lbl : value label `var'
          local nlbl= ""  
          // check if that label has not already been renamed
          if `: list posof "`lbl'" in orig_name' == 0  { 
            // check if label ends in a number--illegal in SAS 
            if length("`lbl'") <= `= `ml'-1' &   (           ///
                  substr("`lbl'", length("`lbl'"), 1) == "1" | ///
                  substr("`lbl'", length("`lbl'"), 1) == "2" | ///
                  substr("`lbl'", length("`lbl'"), 1) == "3" | ///
                  substr("`lbl'", length("`lbl'"), 1) == "4" | ///
                  substr("`lbl'", length("`lbl'"), 1) == "5" | ///
                  substr("`lbl'", length("`lbl'"), 1) == "6" | ///
                  substr("`lbl'", length("`lbl'"), 1) == "7" | ///
                  substr("`lbl'", length("`lbl'"), 1) == "8" | ///
                  substr("`lbl'", length("`lbl'"), 1) == "9" | ///
                  substr("`lbl'", length("`lbl'"), 1) == "0") {
              local nlbl= "`lbl'_"
            }
            else if length("`lbl'") == `ml'  { 
              if substr("`lbl'", `ml', 1) == "1" {
                local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "z"
              } 
              else if substr("`lbl'", `ml', 1) == "2" {
                local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "y"
              } 
              else if substr("`lbl'", `ml', 1) == "3" {
                local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "x"
              } 
              else if substr("`lbl'", `ml', 1) == "4" {
                local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "w"
              } 
              else if substr("`lbl'", `ml', 1) == "5" {
                local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "v"
              } 
              else if substr("`lbl'", `ml', 1) == "6" {
                local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "u"
              } 
              else if substr("`lbl'", `ml', 1) == "7" {
                local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "t"
              } 
              else if substr("`lbl'", `ml', 1) == "8" {
                local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "s"
              } 
              else if substr("`lbl'", `ml', 1) == "9" {
                local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "r"
              }
              else if substr("`lbl'", `ml', 1) == "0" {
                local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "q"
              }
            } // end of if label `ml' characters long and ends in a number 
            else if length("`lbl'") > `ml' { 
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            // check that defined value label not a valid SAS format
            else if inlist(lower("`lbl'"),     ///
     "best"    , "binary"  , "comma"   , "commax"  , "d"       , "date"    , "datetime")  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),     ///
     "dateampm", "day"     , "ddmmyy"  , "dollar"  , "dollarx" , "downame" , "e"       )  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),     ///
     "eurdfdd" , "eurdfde" , "eurdfdn" , "eurdfdt" , "eurdfdwn", "eurdfmn" , "eurdfmy" )  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),      ///
     "eurdfwdx", "eurdfwkx", "float"   , "fract"   , "hex"     , "hhmm"    , "hour"    )  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),     ///
     "ib"      , "ibr"     , "ieee"    , "julday"  , "julian"  , "percent" , "minguo"  )  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),     ///
     "mmddyy"  , "mmss"    , "mmyy"    , "monname" , "month"   , "monyy"   , "negparen")  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),     ///
     "nengo"   , "numx"    , "octal"   , "pd"      , "pdjulg"  , "pdjuli"  , "pib"     )  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),     ///
     "pibr"    , "pk"      , "pvalue"  , "qtr"     , "qtrr"    , "rb"      , "roman"   )  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),     ///
     "s370ff"  , "s370fib" , "s370fibu", "s370fpd" , "s370fpdu", "s370fpib", "s370frb" )  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),     ///
     "s370fzd" , "s370fzdl", "s370fzds", "s370fzdt", "s370fzdu", "ssn"     , "time"    )  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),     ///
     "timeampm", "tod"     , "weekdate", "weekdatx", "weekday" , "worddate", "worddatx")  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),     ///
     "wordf"   , "words"   , "year"    , "yen"     , "yymm"    , "yymmdd"  , "yymon"   )  {
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
            else if inlist(lower("`lbl'"),     ///
     "yyq"     , "yyqr"    , "z"       , "zd", "f") { 
              local nlbl= substr("`lbl'", 1, `= `ml' - 1') + "_"
            }
  
            // re-assign value labels using SAS-ok value label names
	    if `"`nlbl'"' != "" & `"`nlbl'"' != `"`lbl'"' {
              local ren= `ren' + 1   // count ones needed to be renamed
              if `: list posof "`nlbl'" in names' > 0 {  // nlbl already an existing label
                local flag5= 1
                // make a list of bad value label names 
                if `: list posof "`nlbl'" in bad_labs' == 0 {  // add if not already in list
                  local bad_labs `"`bad_labs'`nlbl' "'
                }
              }
              else {  // label okay to be renamed
                // assign new label to variable
                label value `var' `nlbl'
                if `ren' == 1 { 
                  noi di _n "{txt}NOTE: SAS format names cannot be more than `ml' characters long, *"
                  noi di "      {txt}cannot end in a number, nor be a SAS reserved format name.  *"
                  noi di "{txt}NOTE: {res}The following value label(s) will have the following *"
                  noi di "      SAS format value name: *"
                  noi di as result `"Original"' _col(20)`"Renamed *"'
                  noi di as result `"--------"' _col(20)`"------- *"'
                }
                if `: list posof "`nlbl'" in renamed' == 0 {  // if not already listed 
                  noi di as result `"`lbl'"' _col(20)`"`nlbl' *"'
                  local orig_names "`orig_names'`lbl' "  // add to list
                  local renamed "`renamed'`nlbl' "  //  add to list
	          // Use Nick Cox's labvalclone command to do just that!
	          labvalclone `lbl' `nlbl'
                }
              }
            }
          }  // end of if value label has not already been renamed
          else {
            // use existing label
            local nlbl "`: word `: list posof "`lbl'" in orig_name' of `renamed''"
            label `var' `nlbl'
          }
          
        } /* end of foreach */
        // now that all vars have been processed, drop the labels that were cloned
        foreach lbl of local orig_names {
	  label drop `lbl'
        }
        if `flag5' == 1 {
          foreach lab of local bad_labs {
            noi di "{error}NOTE: {res}value label `lab' {error}could not be uniquely renamed.  *"
          }
          noi di "{help savasas:savasas} {error}has stopped processing. *"

          file close sasfile 

          error 499 
        }
end 


* WRITE OUT USER-DEFINED FORMATS AS A SAS DATASET SO THAT LONG FORMATS ARE NOT A PROBLEM
* -------------------------------------------------------------------------------------- 

program sav_labs_data, rclass
version 8
syntax [varlist], fhandle(string) ml(integer) filen(string)  raw(string) 

 // need to re-create r(names) since sav_lvchk may have renamed labels
 label dir  
 if "`r(names)'" != "" {  // dataset has value labels.  the check before sav_lvchk
                          //  has assured that they are used in data  
  
   if `ml' == 8  local maxlablen= 256
   else  local maxlablen= 32000
   local lrecl =`maxlablen' + 75

   tempfile test 
   file write `fhandle' _n `"data formats;"'
   file write `fhandle' _n `"length fmtname $`ml' start end 8 label $`maxlablen';"'
   file write `fhandle' _n `"infile "`raw'_formats.txt" lrecl=`lrecl' truncover ; "'
   file write `fhandle' _n `"input fmtname 1-32 start 34-53 end 55-74 label 76-`maxlablen';"'

   file open sas_formats using "`raw'_formats.txt", replace text write   
   local lab2long= 0  
    
   local names `r(names)'
   foreach lab of local names {
     tempname lab_in
     tempfile lab_file
     label save `lab' using `"`lab_file'"', replace 
     file open `lab_in' using `"`lab_file'"', r  // read-only
     file read `lab_in' lab_line  // load first line of file to local macro var lab_line
     local lvs ""
     local n_lvs= 0 // number of label values
     // read lab_file one line at a time
     //  and count how many lines there are
     while r(eof) == 0 {
       local lv : word 4 of `lab_line'
       if `lv' < .  local n_lvs= `n_lvs' + 1
       // collect label values into one macro
       local lvs `"`lvs' `lv'"'
       file read `lab_in' lab_line 
     } // end of while eof loop
     file close `lab_in' 
     label list `lab' // just to figure out if has special missings or not
     if `r(min)' == . &  `r(max)' == .  {   // only has special missing values
       local fora `"each lv in `c(alpha)'"'  // really: "foreach lv in `c(alpha)'"
       local fors `"fora"'
     }
     else if `r(hasemiss)' == 1   {  // has both
       local forn `"val lvn= 1/`n_lvs'"'    // really: "forval lvn= 1/`n_lvs'"
       local fora `"each lv in `c(alpha)'"'  // really: "foreach lv in `c(alpha)'"
       local fors `"forn  fora"'
     }
     else if `r(min)' != . &  `r(max)' != .  { // has no special missing values
       local forn `"val lvn= 1/`n_lvs'"'     // really: "forval lvn= 1/`n_lvs'"
       local fors `"forn"'
     }
     foreach each_val of local fors {
       local multi_l= 0
       local write_lab= 0
       // this only works if there is always a loop to process
       for``each_val'' {  // adding the "for" help Stata not freak out when this section isn't run
         if "`each_val'" == "forn" {  // for numeric lists look for ranges
           local lv : word `lvn' of `lvs' 
           local label : label `lab' `lv'
           // `label' equals the number if no label assigned
           //  which shouldn't happen now that only processing label values
           if `: list local(label) == local(lv)' == 0  {  // if value has a label
             local nlv : word `= `lvn'+1' of `lvs' 
             local nlabel ""  // no label by default
             if `= `lvn'+1' <= `n_lvs' {  // : word > n words of string is invalid syntax
               local nlabel : label `lab' `nlv' 
             }
             local plabel ""  // no label by default
             if `lvn' != 1 {  // : word 0 of string is invalid syntax
               local plv : word `= `lvn'-1' of `lvs' 
               local plabel : label `lab' `plv' 
             }
             local npl= 0
             if `: list local(label) == local(nlabel)' == 1  { 
               if `: list local(label) == local(plabel)' == 0  { 
                 if ( "`= `lv'+1'" == "`nlv'" )  {   // nlv is in quotes since it might= " "
                   local multi_l= 1
                   local start= `lv'
                   local npl= 1
                 }
               } 
             }
             if `npl' == 0 & `: list local(label) == local(nlabel)' == 0  {
               if `multi_l' == 1  {
                 local write_lab= 1
                 local multi_l= 0
               }
               else {  // no range 
                 local write_lab= 1
                 local start= `lv' 
               }
             }
             else if `: list local(label) == local(nlabel)' == 1  & ///  {
                ( "`= `lv'+1'" != "`nlv'" )  { // no range because not continuous values
               local write_lab= 1
               local start= `lv' 
             }  // end of checking for ranges
             if `write_lab' == 1 {
               local write_lab= 0
               if `: length local label' > `maxlablen'  {
                 local lab2long= 1
               }
                                   // `macval(label)' keeps dollar signs or `something'
                                   //  from being evaluated, $ being more likely
                                              // fmtname    start   end    label
               file write sas_formats _n _col(0)`"`lab'"' _col(34)`"`start'"' _col(57)`"`lv'"' _col(81)`"`macval(label)'"'
             }
           } // end of if value has a label
         }  // end of if for is forn
         else  {  // process fora list which is only special missings
           local label : label `lab' .`lv'
           // `label' equals the special missing value if no label assigned
           // ( there is length issue here since only checking for ".a", ".b" etc
           if "`label'" != ".`lv'" {   // if value has a label
             if `: length local label' > `maxlablen'  {
               local lab2long= 1
             }
                                   // `macval(label)' keeps dollar signs or `something'
                                   //  from being evaluated, $ being more likely
                                            // fmtname    start   end   label
             file write sas_formats _n _col(0)`"`lab'"' _col(34)`".`lv'"' _col(57)`".`lv'"' _col(81)`"`macval(label)'"'
           }
         }  // end if fora loop
       }  // end of for``each_val'' loop
     } // end of fors loop
   } // end foreach lab of local names


   file write `fhandle' _n `"run; "' _n
   file write `fhandle' _n _n  `"proc format library= library.`filen' cntlin= work.formats(where= (fmtname ^= ""));"' 
   file write `fhandle' _n `"run; quit;"'
   // macro tests if SAS could create new formats catalog and erases it and does it again if SAS 
   //  initially is not able to due to catalog file having been created for a different OS 
   file write `fhandle' _n _n  `"%macro redo;"'
   file write `fhandle' _n     `" ** Check for this error message:"'
   file write `fhandle' _n     `"  * upcase(error:) File LIBRARY.`filen'.CATALOG was created for a different operating system. **;"'
   file write `fhandle' _n     `" %if &syserr.= 3000 %then %do;"'
   file write `fhandle' _n     `"   proc datasets library= library "'
   file write `fhandle' _n     `"                 memtype= catalog "'
   file write `fhandle' _n     `"                 nodetails nolist nowarn;"'
   file write `fhandle' _n     `"     delete `filen';"'
   file write `fhandle' _n     `"   run;"'
   file write `fhandle' _n     `"   ** now try it! **;"'
   file write `fhandle' _n     `"   proc format library= library.`filen' cntlin= work.formats(where= (fmtname ^= ""));"' 
   file write `fhandle' _n     `"   run; quit;"'
   file write `fhandle' _n     `" %end;"'
   file write `fhandle' _n     `"%mend redo;"'
   file write `fhandle' _n     `"%redo;"'
   
   if `lab2long' == 1  {
     di as error "WARNING: at least one value label was truncated because it was longer than `maxlablen' characters"
   }
   // capture file close sas_formats since "``for'' {" throws stata off but this is now fixed so not a problem?
   capture file close sas_formats  
 } // end of if dataset has value labels   (condition is probably not needed)

end


*! NJC 1.1.1 3 Nov 2002 
* NJC 1.1.0 1 Nov 2002 
program def labvalclone
	version 7 
	args old new garbage 
	if "`old'" == "" | "`new'" == "" | "`garbage'" != "" { 
		di as err "syntax is: " /* 
		*/ as txt "labvalclone {it:vallblname newvallblname}" 
		exit 198 
	} 
	if "`old'" == "label" | "`old'" == "define" { 
		di as err "won't work if {txt:`old'} is existing value label name" 
		exit 198 
	}	
        capture label list `new'  // check to see if exists as defined label
	if _rc == 0 { 
		di as err "value labels {txt:`new'} already exist" 
		exit 198
	} 
	
	tempfile file1 file2
	tempname in out 

	qui label save `old' using `"`file1'"' 
	file open `in' using `"`file1'"', r
	file open `out' using `"`file2'"', w
	file read `in' line
	
	while r(eof) == 0 {
		local line: subinstr local line "`old'" "`new'"
		file write `out' `"`line'"' _n
		file read `in' line
	}
	file close `out'
	
	qui do `"`file2'"'   
end 

