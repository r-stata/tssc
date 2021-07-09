*!mkprofile Version 2.2 dan_blanchette@unc.edu 22Apr2010
*! the carolina population center, unc-ch
*- fixed a display command problem and made it so that directory names only end with one /
**Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
* mkprofile Version 2.1 dan.blanchette@duke.edu  25Feb2010
*- added a write test to make make sure the user can really create a file in that directory.
**mkprofile Version 1.1 dan.blanchette@duke.edu  25Feb2009
* mkprofile version 1.0 dan_blanchette@unc.edu 22Jul2005
*- made it so that it only conditionally cds when not run by console Stata
* mkprofile version 1.0 dan_blanchette@unc.edu 06Feb2005
* the carolina population center, unc-ch

program mkprofile, rclass
 version 8
 syntax [, MEMory(integer 40) VLabel(integer 12) edit cwd list NTHdir(integer 192) all ]

/****************************************************************************
 * From Stata's help file on profile.do  ( . whelp profile.do )
 * Stata looks for the file profile.do when it is invoked, and if it 
 *  finds it, executes the commands in it.
 *   (see help adopath).  We recommend you put profile.do in 
 *   your ado directory: $HOME/ado/  or c:\data\
 ****************************************************************************/

/* administrators: Uncomment out the setting for local pdir
 *  and modify the preferred directory you want your users to
 *  have -mkprofile- create the user's profile.do in:
 */
 if "`c(os)'" == "Windows" {
   // local pdir  "c:\ado/"
 }
 else {
   local home : environment HOME
   // local pdir  "`home'/ado/"
 }

 // directory where Stata is installed:
 local stata_dir `"`c(sysdir_stata)'"'
 // since users may be able to change the value of c(sysdir_stata) using -sysdir-, you can set it here.

***************************************************************
 *** ! NO MORE EDITS SHOULD BE REQUIRED AFTER THIS POINT ! ***
***************************************************************




if `vlabel' < 8 {
  di as err "variable label position needs to be >= 8 and <= 32 "
  exit 910
}
else if `vlabel' > 32 {
  di as err "variable label position needs to be >= 8 and <= 32 "
  exit 912
}

if `nthdir' == 192 {
   local nthdir= .
} 

local s_ado= lower(subinstr(`"$S_ADO"',";"," ",.))
local sdir_order  "`s_ado'"
local ndirs : word count `sdir_order'
// create a reverse order of directories to attempt to create profile.do
forvalues n= 1/`ndirs' {
  local sdir : word `n' of `sdir_order'
  if "`sdir'" == "." {
    continue  // since c(pwd) will be added to path later
  }
  else if inlist(`"`sdir'"',"updates","base","site")  {
    local adopath      `"`adopath';`c(sysdir_`sdir')'"'
  }
  else {
    local adopath      `"`adopath';`c(sysdir_`sdir')'"'
    local rev_uadopath `"`c(sysdir_`sdir')';`rev_uadopath'"'  
  }
}

// starting in Stata 10 sysprofile.do is found and run and then profile.do is found and run
// Stata 9 & earlier, once profile.do is found no more searching is done

// look for profile.do wherever Stata looks for it
local full_upath `"`: environment PATH'"'
if "`c(os)'" != "Windows" {
  local full_upath : subinstr local full_upath ":" ";" , all
}
// make sure full_upath is a unique list of directories:
gettoken first_dir : full_upath , parse(";")
while !missing(`"`first_dir'"') {
  gettoken first_dir full_upath : full_upath , parse(";")
  if `"`first_dir'"' == ";"  {
    continue
  }
  if "`first_dir'" == "." {
    local first_dir `"`c(pwd)'"'
  }
  local upath_dirs `"`upath_dirs' "`first_dir';""'
}
local upath_dirs : list uniq upath_dirs
// get rid of double quotes:
local full_upath : subinstr local upath_dirs `"""' "", all


if "`c(os)'" == "Windows"  {
   local full_path8 `"`c(pwd)';`full_upath';`: environment USERPROFILE';`stata_dir';`adopath';"'
   local full_path9 `"`stata_dir';`c(pwd)';`full_upath';`: environment USERPROFILE';`adopath';"'
   local user_path  `"`rev_uadopath';`: environment USERPROFILE';`c(pwd)';"'
}
else { // if inlist("`c(os)'","Unix","MacOSX")
   local home : environment HOME
   local full_upath : subinstr local full_upath ":" ";" , all
   local full_path8 `"`c(pwd)';`full_upath';`stata_dir';`adopath';"'
   local full_path9 `"`stata_dir';`c(pwd)';`full_upath';`adopath';"'
   local user_path  `"`rev_uadopath';`home';`c(pwd)';"'
}

foreach path in full_path8 full_path9 user_path {
  local `path' : subinstr local `path' ";;;" ";" , all
  local `path' : subinstr local `path' ";;" ";" , all
  local `path' : subinstr local `path' ";;" ";" , all
}

if `c(stata_version)' < 9  {
  local full_path `"`full_path8'"'
}
else {
  local full_path `"`full_path9'"'
}

local find_full_path `"`full_path'"'
gettoken first_dir : find_full_path, parse(";")
while !missing(`"`first_dir'"') {
  gettoken first_dir find_full_path: find_full_path, parse(";")
  if `"`first_dir'"' == ";" | missing(`"`first_dir'"') {
     continue
  }
  if "`c(os)'" != "Windows" {
    local first_dir : subinstr local first_dir "~" "`: environment HOME'"
  }
  capture confirm file `"`first_dir'/profile.do"'
  if _rc == 0 {
    local found_f `"`first_dir'/profile.do"'  // which includes the path
    local found_f : subinstr local found_f "///profile.do" "/profile.do", all
    local found_f : subinstr local found_f "//profile.do" "/profile.do", all
    local found_f : subinstr local found_f "\\/profile.do" "/profile.do", all
    local found_f : subinstr local found_f "\/profile.do" "/profile.do", all
    local found_f : subinstr local found_f "//profile.do" "/profile.do", all
    local permitted= 1
    local file_exists= 0
    // test if user can edit the found profile.do:
    tempname test1
    capture file open `test1' using `"`macval(found_f)'"', append text write
    if _rc != 0 {
       local permitted= 0
    }
    capture file close `test1'
    di as err `"Your {txt}"`macval(found_f)'" {error}already exists."'
    if "`edit'" == "edit" & `permitted' == 1 & missing("`list'") {
      if missing("`c(console)'") {
        di as err `"Click on the filename to edit it in your do-file editor "' ///
                   `"{stata `"doedit "`macval(found_f)'""' : "`macval(found_f)'"} and "'
      }
      else {
        di as err `"Open up "`macval(found_f)'" in your {helpb doedit:do-file editor} and "'
      }
      if "`vlabel'" != "" | "`memory'" != "" | "`cwd'" != ""  {
        di as input `"copy and paste your specified settings to your profile.do file: "' 
        di " "
        if !missing("`vlabel'")  di as text `"set varlabelpos `vlabel' "' 
        if !missing("`memory'")  di as text `"set memory `memory'm "'
        if !missing(`"`cwd'"')   di as text `"if "`c(console)'" != "console"  cd "`c(pwd)'""'  // this keeps savastata happy
        di " "
      }
      di as err "Remember to save your profile.do file."
      exit
    }
    else if `permitted' == 1 & missing("`list'") {
      di as err `"Use the {helpb mkprofile:mkprofile} {cmd:edit} option to edit your profile.do file in your {helpb doedit:do-file editor}."'
      exit 198
    }
    else {
      if `permitted' == 0 {
        di as err `"You do not have write permission to edit your profile.do file.  Talk to your administrator."'
      }
      if missing("`list'") {
        exit 603
      }
    }
  }
} // end of while loop searching for profile.do in Stata's search path


// list directories where profile.do may be able to be created:
if missing("`all'") {
  local path_list `"`user_path'"'
  local path_make `"`user_path'"'
}
else {
  local path_list `"`full_path'"'
  local path_make `"`full_path'"'
}
if !missing(`"`pdir'"') {
  local path_list `"`pdir'"'
  local path_make `"`pdir'"'
}

di as text "This is a list of the directories in the order that {helpb mkprofile:mkprofile} will attempt to create your profile.do file:"
local n= 1
gettoken first_dir : path_list, parse(";")
while !missing(`"`first_dir'"') {
  gettoken first_dir path_list : path_list, parse(";")
  if `"`first_dir'"' == ";" | missing(`"`first_dir'"') {
     continue
  }
  if "`c(os)'" != "Windows" {
    local first_dir : subinstr local first_dir "~" "`: environment HOME'"
  }
  if !missing(`nthdir') & `nthdir' == `n' {
    local nthdir_dir `"`first_dir'"'
  }
  di as result "  "%02.0f `n++' `") `first_dir'"'
}

if missing(`nthdir') {
  di as text _n "The {helpb mkprofile:mkprofile}'s {cmd:nthdir()} option allows you to specify which directory " ///
                 "to try to create your profile.do" _n
}
else {
  if !missing(`"`nthdir_dir'"') {
    di as text _n "{helpb mkprofile:mkprofile} will attempt to create your profile.do file in this directory"
    di as result "  "%02.0f `nthdir' `") `nthdir_dir'"'
    if missing("`all'") { 
      di as text    "with option {cmd:all} not specified and the {cmd:nthdir()} option specified as you did." 
    }
    else {
      di as text    "with option {cmd:all} specified and the {cmd:nthdir()} option specified as you did." 
    }
  }
  else {
    di as err _n "You have specified an inaccurate number for the {cmd:nthdir()} option.  Click here {helpb mkprofile:mkprofile} for help."
  }
}

if !missing("`list'") {
  exit 0
}

// else try to create profile.do
local n= 1
gettoken first_dir : path_make, parse(";")
while !missing(`"`first_dir'"') {
  gettoken first_dir path_make : path_make, parse(";")
  if `"`first_dir'"' == ";"  {
    continue
  }
  if !missing(`nthdir') & `n' != `nthdir' {
     local n= `n' + 1
     continue 
  }
  if "`c(os)'" != "Windows" {
    local first_dir : subinstr local first_dir "~" "`: environment HOME'"
  }
  local permitted= 1
  tempname test1
  capture confirmdir `"`first_dir'"' 
  if `r(confirmdir)' != 0  {
    if missing("`c(console)'") {
      if "`c(os)'" == "Windows" {
        capture shell mkdir "`first_dir'"  // can't use compound double quotes in shell
      }
      else {
        capture shell mkdir -p "`first_dir'" // can't use compound double quotes in shell
      }
      capture confirmdir `"`first_dir'"' 
      if _rc != 0 {
        continue
      }
    }
    else {
      di as error `"The directory "`first_dir'" does not exist.  Create it if you want. "'
    }
  }
  local profile_do `"`first_dir'/profile.do"'
  local profile_do : subinstr local profile_do "///profile.do" "/profile.do", all
  local profile_do : subinstr local profile_do "//profile.do" "/profile.do", all
  local profile_do : subinstr local profile_do "\\/profile.do" "/profile.do", all
  local profile_do : subinstr local profile_do "\/profile.do" "/profile.do", all
  local profile_do : subinstr local profile_do "//profile.do" "/profile.do", all

  capture file open `test1' using `"`profile_do'"', text write
  // found times when Stata will create an empty file despite not having write permissions
  if _rc != 0 {
     local permitted= 0
  }
  capture file close `test1'
  capture erase `"`profile_do'"'  // mkprofile had to have just created this file if at this point in program

  if `permitted' == 1 {
    quietly file open mkprofile using `"`profile_do'"', text write

    if !missing("`vlabel'")  file write mkprofile _n `"set varlabelpos `vlabel' "' _n
    if !missing("`memory'")  file write mkprofile _n `"set memory `memory'm "'  _n 
     // this keeps savastata happy:
    if !missing("`cwd'")     file write mkprofile _n `"if "`c(console)'" != "console" cd "`c(pwd)'" "'  _n   
  
    forval num= 4/12 {
      if `"`= subinstr("$ F`num'"," ","",.)'"' == ""  {
        file write mkprofile _n `"/* The following is an example of how to  "'  
        file write mkprofile _n `" * set up an F key to cd to your favorite directory: */ "'  _n 
        file write mkprofile _n `"global F`num' cd "`c(pwd)'" "'  _n 
        file write mkprofile _n `"/* ". macro list" shows what F keys are already assigned. */ "' _n 
        continue, break
      }
    }
    file close mkprofile 
    continue, break  
  }
  local n= `n' + 1
}

capture confirm file `"`profile_do'"'
if _rc == 0 {
  di as res  `"{helpb mkprofile:mkprofile} has successfully created your profile.do file."'
  if missing("`c(console)'") {
    di as text `"Click on the filename to _view_ it in the Stata {helpb viewer:viewer} "' ///
       `"{stata `"view   "`profile_do'""' : "`profile_do'"} "'
    di as text `"or: "'
    di as text `"click on the filename to _edit_ it in your {helpb doedit:do-file editor} "' ///
       `"{stata `"doedit "`profile_do'""' : "`profile_do'"} "'
  }
  else {
    di as text `"Feel free to edit or view: "`profile_do'" "'
  }
 
  di as text `"The settings in profile.do will take effect the next time you start-up a Stata session."'

  local return mkprofile `"`profile_do'"'
}
else if !missing(`nthdir') {
  di as err "{helpb mkprofile:mkprofile} could not create your profile.do file: "
  di as err `" "`profile_do'" "'
  di as text "Try a different directory or just don't use the {cmd:nthdir()} option."
  exit 198
}
else {
  di as err "{helpb mkprofile:mkprofile} could not create your profile.do file. Talk to your administrator"
  exit 198
}

end
 
