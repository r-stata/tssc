*! Date    : 8 Jun 2020
*! Version : 2.12
*! Author  : Adrian Mander
*! Email   : mandera@cardiff.ac.uk
*!  Make help files 

/*
27Mar07 v1.5  The old version of makehlp for Stata9
 3Jul12 v1.06 Update this very old program
11Dec12 v1.07 Changed message on the replace, allow /// to define end of line, sorted out real and integer
 2Nov15 v1.08 BUG: need to handle quotes in comments before syntax line
21May18 v2.0  Integrating ado file descriptions into creation of makehlp
 8Jun18 v2.01 BUG fixes that I hadn't considered..
16Jul18 v2.02 BUG fix on default values
18Jul18 v2.03 Removed need to have () brackets in opt[] text
14Aug18	v2.04 removed bugs and allowed * as an option
 4Sep18 v2.05 handles tabs in syntax line replacing them with spaces, also handles noTOTal options
 5Oct18 v2.06 remove bugs found from Sven-Kristjan Bormann needed to change macro line to mh_line!
13Mar19 v2.07 removing a bug found by Grayling about tabs and lacking new lines
14Mar19 v2.08 found bug on return lists..
19Jun19 v2.09 sorted out bug because I used the word syntax in helpfile!
12Nov19 v2.10 a bug on references titles.
17Apr20 v2.11 introduce optional and  required  options
 8Jun20 v2.12 handles the word syntax in the middle of lines and outputs a latex file of the help file
 */

program define makehlp
 /* Allow use on earlier versions of stata that have not been fully tested */
 local version = _caller()
 if `version' < 16.1 {
    di "{err}WARNING: Tested only for Stata version 16.1 and higher."
    di "{err}Your Stata version `version' is not officially supported."
 }
 else {
   version 16.1
 }
 syntax [varlist], File(string) [ Replace DEBUG ME LATEX]
 local comm "`file'"
/*******************************************************************************************
 * Want to read in ado file to find all the help file elements before looking at the syntax
 *  line
 *******************************************************************************************/

 tempname fh
 file open `fh' using `"`file'.ado"',read
 file read `fh' mh_line
 local i 1
 local nohelpfiletext 0
 while ( strpos(`"`mh_line'"', "START HELP FILE")==0 & r(eof)==0) { /* get to start of help text*/
   file read `fh' mh_line 
 }
 if (r(eof)==1) { /* if START HELP FILE not found then close file and proceed to later parts*/
   file close `fh'
   di "{err} WARNING: text START HELP FILE not found"
   local nohelpfiletext 1
 }
 local authi 1
 local institi 1
 local emaili 1
 local seei 1
 
 /* Process the HELP FILE text, keep reading file until end of helpfile* */
   
 while (strpos(`"`mh_line'"',"END HELP FILE")==0 & !`nohelpfiletext' & r(eof)==0 ) {
   /* Handling the title text */
   //di `"LINE `mh_line'"'
   if strpos(`"`mh_line'"',"syntax")~=0 {
     di "{err}WARNING: the word syntax appears in the helpfile... this needs to be changed"   
   }
   if strpos(`"`mh_line'"', "title[")~=0 {
     local tit_line 1
     if (strpos(`"`mh_line'"', "]")==0) local title_text`tit_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"title[")+6, .)
     else local title_text`tit_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"title[")+6, strpos(`"`mh_line'"',"]")-7)
     local `tit_line++'
     while strpos(`"`mh_line'"',"]")==0 { /* this is for multiple lines*/
       file read `fh' mh_line
       if (strpos(`"`mh_line'"',"[")>0) {
         di "{err}WARNING you have probably used symbols [] in the description... ] stops the title!{txt}"
       }
       if strpos(`"`mh_line'"',"]") ==0 {
         local title_text`tit_line' `"`mh_line'"'	 
         local `tit_line++'
       }
       else if (strlen(strtrim(`"`mh_line'"'))>1) {
         local title_text`tit_line' = substr(`"`mh_line'"', 1, strpos(`"`mh_line'"',"]")-1)
       }
       else {
         local `tit_line--'
       }
     }
   }

   /* This part handles the options text, note that it is split into opt[] and opt2[]*/
   if strpos(`"`mh_line'"', "opt[")~=0 {
     local te = substr(`"`mh_line'"', strpos(`"`mh_line'"',"opt[")+4, .) /* strip out start of line */
     if (word(`"`te'"',1)~="*") local optname = word(`"`te'"',1)  /* word 1 should be the option name */
     else local optname "star" /* using * causes problems */
     if strpos("`optname'","(") ~=0 { /* if there is a bracket in optname get rid of them*/
       local optname = substr("`optname'", 1, strpos("`optname'","(")-1) /* strips out () if they exist in the name */
     }
     local optnamelen = length(word(`"`te'"',1))
 // di "{txt}Processing option `optname'"
	 
     local `optname'_line 1
     if (strpos(`"`mh_line'"', "]")==0) {
       local `optname'_txt1 = substr(`"`te'"',`optnamelen'+1, .)
     }
     else {
       local `optname'_txt``optname'_line' = substr(`"`te'"', `optnamelen'+1, strpos(`"`te'"', "]")-`optnamelen'-1)
       if ustrtrim("``optname'_txt``optname'_line''")=="" di "{err}WARNING: empty description for `optname'"
     }
     local `optname'_line = ``optname'_line'+1
     while strpos(`"`mh_line'"',"]")==0 { /* this is for multiple lines*/
       file read `fh' mh_line
       if (strpos(`"`mh_line'"',"[")>0) {
         di "{err}WARNING you have probably used symbols [] in the option... ] stops the option text!{txt}"
       }
       if strpos(`"`mh_line'"',"]") ==0 {
         local `optname'_txt``optname'_line' `"`mh_line'"'	 
         local `optname'_line = ``optname'_line'+1
       }
       else if (strlen(strtrim(`"`mh_line'"'))>1) {
         local `optname'_txt``optname'_line' = substr(`"`mh_line'"', 1, strpos(`"`mh_line'"',"]")-1)
       }
       else {
         local `optname'_line = ``optname'_line'-1
       }
     }
   }
  
   /* This part handles opt2 options from multiple lines*/
   if strpos(`"`mh_line'"', "opt2[")~=0 { /* this is the multiple line version*/
     local te = substr(`"`mh_line'"', strpos(`"`mh_line'"',"opt2[")+5, .)
     if (word(`"`te'"',1)~="*") local a = word(`"`te'"',1)  /* this should be the option name */
     else local a "star" /* using * causes problems */
     if strpos("`a'","(") ~=0 {
       local a = substr("`a'", 1, strpos("`a'","(")-1) /* strips out () if they exist in the name */
     }
     local optnamelen = length(word(`"`te'"',1))
     
     local `a'2_line 1
     if (strpos(`"`mh_line'"', "]")==0) {
       local `a'2_txt1 = substr(`"`te'"',`optnamelen'+1, .)
     }
     else {
       local `a'2_txt``a'2_line' = substr(`"`te'"', `optnamelen'+1, strpos(`"`te'"', "]")-`optnamelen'-1)
     }
     local `a'2_line = ``a'2_line'+1
     while strpos(`"`mh_line'"',"]")==0 { /* this is for multiple lines*/
       file read `fh' mh_line
       if (strpos(`"`mh_line'"',"[")>0) {
         di "{err}WARNING you have probably used symbols [] in the description... ] stops the description!{txt}"
       }
       if strpos(`"`mh_line'"',"]") ==0 {
         local `a'2_txt``a'2_line' `"`mh_line'"'	 
         local `a'2_line = ``a'2_line'+1
       }
       else if (strlen(strtrim(`"`mh_line'"'))>1) {
         local `a'2_txt``a'2_line' = substr(`"`mh_line'"', 1, strpos(`"`mh_line'"',"]")-1)
       }
       else {
         local `a'2_line = ``a'2_line'-1
       }
     }  
   }
  
   /* The description part of the help file*/
   if strpos(`"`mh_line'"', "desc[")~=0 {
     local desc_line 1
     /* find name of description */
     if (strpos(`"`mh_line'"', "]")==0) local desc_text`desc_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"desc[")+5, .)
     else local desc_text`desc_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"desc[")+5, strpos(`"`mh_line'"',"]")-6)
     local `desc_line++'
       while strpos(`"`mh_line'"',"]")==0 { /* this is for multiple lines*/
         file read `fh' mh_line
         if (strpos(`"`mh_line'"',"[")>0) {
           di "{err}WARNING you have probably used symbols [] in the description... ] stops the description!{txt}"
         }
	 if strpos(`"`mh_line'"',"]") ==0 {
           local desc_text`desc_line' `"`mh_line'"'	 
           local `desc_line++'
         }
         else if (strlen(strtrim(`"`mh_line'"'))>1) {
           local desc_text`desc_line' = substr(`"`mh_line'"', 1, strpos(`"`mh_line'"',"]")-1)
         }
         else {
           local `desc_line--'
         }
     }
   }
    /* AUTHOR handling */  
   if strpos(`"`mh_line'"', "author[")~=0 {
     /* find name of option */
     local author`authi'_text = substr(`"`mh_line'"', strpos(`"`mh_line'"',"author[")+7, .)
     local author`authi'_text = substr(`"`author`authi'_text'"', 1, strpos(`"`author`authi'_text'"',"]")-1)
     local `authi++'
   }
   /* INSTITUTE handling*/
   if strpos(`"`mh_line'"', "institute[")~=0 {
     /* find name of option */
     local institute`institi'_text = substr(`"`mh_line'"', strpos(`"`mh_line'"',"institute[")+10, .)
     local institute`institi'_text = substr(`"`institute`institi'_text'"', 1, strpos(`"`institute`institi'_text'"',"]")-1)
     local `institi++'
   }
   
   /* The part to handle the return descriptions in the help part */
   if strpos(`"`mh_line'"', "return[")~=0 {
     /* find name of option */
     local te = substr(`"`mh_line'"', strpos(`"`mh_line'"',"return[")+7, .)
     local retname = word(`"`te'"',1)
     local retnamelen = length(word(`"`te'"',1))
     local ret`retname' = substr(`"`te'"',`retnamelen'+1, strpos(`"`te'"',"]")-1-`retnamelen')
   }
   
   /*the references*/
   if strpos(`"`mh_line'"', "references[")~=0 {
     local ref_line 1
     /* find name of description */
     if (strpos(`"`mh_line'"', "]")==0) local ref_text`ref_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"references[")+11, .)
     else local ref_text`ref_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"references[")+11, strpos(`"`mh_line'"',"]")-12)
     local `ref_line++'
     while strpos(`"`mh_line'"',"]")==0 { /* this is for multiple lines*/
       file read `fh' mh_line
       if (strpos(`"`mh_line'"',"[")>0) {
         di "{err}WARNING you have probably used symbols [] in the references... ] stops the references text!{txt}"
       }
       if strpos(`"`mh_line'"',"]") ==0 {
         local ref_text`ref_line' `"`mh_line'"'	 
         local `ref_line++'
       }
       else if (strlen(strtrim(`"`mh_line'"'))>1) {
         local ref_text`ref_line' = substr(`"`mh_line'"', 1, strpos(`"`mh_line'"',"]")-1)
       }
       else {
          local `ref_line--'
       }
     }
   }
   
   /*the free text section*/
   if strpos(`"`mh_line'"', "freetext[")~=0 {
     local free_line 1
     /* find name of description */
     if (strpos(`"`mh_line'"', "]")==0) local free_text`free_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"freetext[")+9, .)
     else local free_text`free_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"freetext[")+9, strpos(`"`mh_line'"',"]")-10)
     local `free_line++'
     while strpos(`"`mh_line'"',"]")==0 { /* this is for multiple lines*/
       file read `fh' mh_line
       if (strpos(`"`mh_line'"',"[")>0) {
         di "{err}WARNING you have probably used symbols [] in the freetext section... ] stops the  text!{txt}"
       }
       if strpos(`"`mh_line'"',"]") ==0 {
         local free_text`free_line' `"`mh_line'"'	 
         local `free_line++'
       }
       else if (strlen(strtrim(`"`mh_line'"'))>1) {
         local free_text`free_line' = substr(`"`mh_line'"', 1, strpos(`"`mh_line'"',"]")-1)
       }
       else {
          local `free_line--'
       }
     } 
   }
   
   /* Handle the email text */
   if strpos(`"`mh_line'"', "email[")~=0 {
     local email`emaili'_text = substr(`"`mh_line'"', strpos(`"`mh_line'"',"email[")+6, .)
     local email`emaili'_text = substr(`"`email`emaili'_text'"', 1, strpos(`"`email`emaili'_text'"',"]")-1)
     local `emaili++'
   }

   /* Handle the example text*/
   if strpos(`"`mh_line'"', "example[")~=0 {
     local eg_line 1
     if (strpos(`"`mh_line'"', "]")==0) local eg_text`eg_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"example[")+8, .)
     else local eg_text`eg_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"example[")+8, strpos(`"`mh_line'"', "]")-9)
     local `eg_line++'
     while strpos(`"`mh_line'"',"]")==0 { /* this is for multiple lines*/
       file read `fh' mh_line
       if (strpos(`"`mh_line'"',"[")>0) {
         di "{err}WARNING you have probably used symbols [] in the examples... ] stops the examples section!{txt}"
       }
       if strpos(`"`mh_line'"',"]") ==0 {
         local eg_text`eg_line' `"`mh_line'"'	 
         local `eg_line++'
       }
       else if (strlen(strtrim(`"`mh_line'"'))>1) {
         local eg_text`eg_line' = substr(`"`mh_line'"', 1, strpos(`"`mh_line'"',"]")-1)
       }
       else {
         local `eg_line--'
       }
     }
   }

   /* Handle the see also text*/
   if strpos(`"`mh_line'"', "seealso[")~=0 {
     local see_line 1
     if (strpos(`"`mh_line'"', "]")==0) local see_text`see_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"seealso[")+8, .)
     else local see_text`see_line' = substr(`"`mh_line'"', strpos(`"`mh_line'"',"seealso[")+8, strpos(`"`mh_line'"', "]")-9)
     local `see_line++'
     while strpos(`"`mh_line'"',"]")==0 { /* this is for multiple lines*/
       file read `fh' mh_line
       if (strpos(`"`mh_line'"',"[")>0) {
         di "{err}WARNING you have probably used symbols [] in the see also section... and ] stops the section!{txt}"
       }
       if strpos(`"`mh_line'"',"]") ==0 {
         local see_text`see_line' `"`mh_line'"'	 
         local `see_line++'
       }
       else if (strlen(strtrim(`"`mh_line'"'))>1) {
         local see_text`see_line' = substr(`"`mh_line'"', 1, strpos(`"`mh_line'"',"]")-1)
       }
       else {
         local `see_line--'
       }
     }
   }

   file read `fh' mh_line
 }
 if (!`nohelpfiletext') file close `fh'

/**********************************************
 * FINDING the SYNTAX line
 *  Read in file 
 *  Go line by line until syntax is found
 *  Then stop reading lines once we 
 *  haven't got an end comment
 *********************************************/
 
 /* This checks whether the help file has the word syntax in it*/
 tempname fh
 file open `fh' using `"`file'.ado"',read
 file read `fh' mh_line
 while ( strpos(`"`mh_line'"', "START HELP FILE")==0 & r(eof)==0) { /* get to start of help text*/
   file read `fh' mh_line 
 }
 while (strpos(`"`mh_line'"',"END HELP FILE")==0 & r(eof)==0 ) {
   /* Handling the title text */
   if strpos(`"`mh_line'"',"syntax")~=0 {
     di "{err}WARNING: the word syntax appears in the helpfile... this may need to be changed"   
   }
   file read `fh' mh_line
  }
 tempname fh

 /************************************************************************************
  * First find out what type of command the ado-file is i.e. rclass, eclass, sclass
  * Then find all the return values of the stata command and make a list of them 
  ************************************************************************************/

 file open `fh' using `"`file'.ado"',read
 file read `fh' mh_line
 /* NOTE -- occassionally this function tries to evaluate a macro in the read statement... */
 while(r(eof)==0 & strpos(`"`mh_line'"',"pr `comm'")==0 & strpos(`"`mh_line'"',"program define `comm'")==0 & strpos(`"`mh_line'"',"prog def `comm'")==0 ///
    & strpos(`"`mh_line'"',"program de `comm'")==0 & strpos(`"`mh_line'"',"pr de `comm'")==0 & strpos(`"`mh_line'"',"program `comm'")==0) {
   file read `fh' mh_line
 }
 if strpos(`"`mh_line'"',"rclass")~=0 {
   local rclass 1
 }
 if strpos(`"`mh_line'"',"sclass")~=0 {
   local sclass 1
 }
 if strpos(`"`mh_line'"',"eclass")~=0 {
  local eclass 1
 }
 file close `fh'
 
 /* Now create all the returnscalarlist etc....*/
 file open `fh' using `"`file'.ado"',read
 file read `fh' mh_line
 local stopclass 0
 while( r(eof)==0 ) {
  if (`"`macval(mh_line)'"'=="end") local stopclass 1  /* I will stop looking at the first end line i.e. only main program ends..*/
   if (!`stopclass') {
    if strpos(`"`macval(mh_line)'"',"return sca")~=0 {
     if strpos(`"`macval(mh_line)'"',"return scalar")~=0 local retbit = substr(`"`macval(mh_line)'"', strpos(`"`macval(mh_line)'"',"return scalar")+14,.)
     else local retbit = substr(`"`macval(mh_line)'"', strpos(`"`macval(mh_line)'"',"return sca")+11,.)
     if strpos(word(`"`retbit'"',1),"=")~=0 {
       local retslist =`"`retslist' "'+ substr(word(`"`retbit'"',1),1,strpos(word(`"`retbit'"',1),"=")-1)
     }
     else local retslist =`"`retslist' "'+word(`"`retbit'"',1)
    }
    if strpos(`"`macval(mh_line)'"',"return loc")~=0 {
      if strpos(`"`macval(mh_line)'"',"return local")~=0 local retbit = substr(`"`macval(mh_line)'"', strpos(`"`macval(mh_line)'"',"return local")+13,.)
      else local retbit = substr(`"`macval(mh_line)'"', strpos(`"`macval(mh_line)'"',"return loc")+11,.)
      if strpos(word(`"`retbit'"',1),"=")~=0 {
        local retllist =`"`retllist' "'+ substr(word(`"`retbit'"',1),1,strpos(word(`"`retbit'"',1),"=")-1)
      }
      else local retllist =`"`retllist' "'+word(`"`retbit'"',1)
    }
    if strpos(`"`macval(mh_line)'"',"return mat")~=0 {
      if strpos(`"`macval(mh_line)'"',"return matrix")~=0 local retbit = substr(`"`macval(mh_line)'"', strpos(`"`macval(mh_line)'"',"return matrix")+14,.)
      else local retbit = substr(`"`macval(mh_line)'"', strpos(`"`macval(mh_line)'"',"return mat")+11,.)
      if strpos(word(`"`retbit'"',1),"=")~=0 {
        local retmlist =`"`retmlist' "'+ substr(word(`"`retbit'"',1),1,strpos(word(`"`retbit'"',1),"=")-1)
      }
      else local retmlist ="`retmlist' "+word(`"`retbit'"',1)
    }
   }
   file read `fh' mh_line
 }
 file close `fh'

 /* Removing repeated values in lists.. just in case there are conditional return lines */
 local mylist: list uniq retllist
 local retllist "`mylist'"
 local mylist: list uniq retmlist
 local retmlist "`mylist'"
 local mylist: list uniq retslist
 local retslist "`mylist'"
 
 /****************************************************************
  * NOW process the syntax line 
  ****************************************************************/
  file open `fh' using `"`file'.ado"',read
  file read `fh' mh_line
  local i 1
  while (index(`"`mh_line'"', "syntax")==0 & r(eof)==0) { /* keep reading until syntax */
    file read `fh' mh_line 
    /* Need to quickly check whether syntax is in the middle of the line... */
    local check 1
    while(`check' & r(eof)==0) {
      if (index(`"`mh_line'"', "syntax")~=0 ) {
        if  index(ustrtrim(`"`mh_line'"'), "syntax")~=1 {
          di `"{err}Note: Found the word syntax in the middle of a line `mh_line', this line is ignored"'
          file read `fh' mh_line 
        }
        else local check 0
      }
      else local check 0
    }
  }

 local line = subinstr("`mh_line'", "`=char(9)'", " ", .) /*swapping tabs? for spaces*/
 if (r(eof)==1) {
   di "{err}WARNING: At the moment the makehlp command only works for ado files with a {ul:syntax} line"
   exit(196)
 }
 local line`i++' "`mh_line'"
 while (index(`"`mh_line'"', "/*")~=0) | (index(`"`mh_line'"', "///")~=0) { /* more than one line */
   file read `fh' mh_line /* read next line*/
   local line = subinstr("`mh_line'", "`=char(9)'", " ", .)
   local line`i++' = ustrtrim(stritrim("`mh_line'"))
 }
/* Displays the  syntax lines
 forv j=1/`=`--i''{
   di "{txt}Syntax line"
   di "`line`j''"
 }
*/
 local nlines `i'
/*********************************************************************
 * Put all the lines together into synt, hopefully it isn't too long! 
 * I also strip out the comments before creating the syntax macro
 * need to use ustrltrim to remove the initial tabs...

  I used to do subinstr.. to remove these comments but I need to delete rest of line

 
 *********************************************************************/
  local synt ""
  forv ii=1/`nlines' {
    while (index("`line`ii''", "*/")~=0) {
      local inde = index("`line`ii''", "*/")
      local inds = index("`line`ii''", "\*")
      local line`ii' =substr("`line`ii''", 0, `inds') + substr("`line`ii''",`inde'+2,.)
    }
    if (index("`line`ii''","///")~=0) {
      local line`ii' = ustrltrim(strtrim(substr("`line`ii''", 1, index("`line`ii''","///")-1 ) ))
    }
    if (index("`line`ii''","/*")~=0) {
      local line`ii' =ustrltrim(strtrim(substr("`line`ii''", 1, index("`line`ii''","/*")-1 )))
    }
    local synt "`synt' `line`ii''" 
  }
  local new = stritrim(`"`synt'"')
 
/*******************************************************************
 * Split the syntax line into components Create the options list 
 * opts has the position of the ,
 * opt has the options 
 * preopt has everything up to the comma
 *******************************************************************/
 local opts = index("`synt'",",")
 if "`opts'"=="0" di as error "WARNING: There are NO options"
 local opt = substr("`synt'",index("`synt'",",")+1,.)
 local preopt = substr("`synt'",1,index("`synt'",",")-1)

/******************************************************************************
 * Strip out the bracket ] at the end of the options
 * if no trailing bracket then everything required (not handled yet)
 ******************************************************************************/
 if index("`opt'","]")~=0 { /* there are optional options */
   local opt = substr("`opt'", 1, index("`opt'","]")-1) 
    if index("`opt'","[")~= 0 { /* splitting options into required and optional */
      local req_opt = substr("`opt'", 1, index("`opt'","[")-1)
      local opt_opt = substr("`opt'", index("`opt'","[")+1,.)
      local opt ""
    }
 }
  else { /* all options  are required */
    local req_opt "`opt'"
    local opt ""
  }
  if index("`opt_opt'","[")~=0 | index("`req_opt'","[")~=0{
    di "{error}ERROR: there are too many [ brackets in the options"
  }

/******************************************************************************************
 * an in loop later on requires that the list in preopt doesn't end in an open bracket...
 * A leading [ bracket occurs when every option is optional
 ******************************************************************************************/
 // BUG not sure the first one is needed

if index(reverse("`preopt'"),"[")>index(reverse("`preopt'"),"]") & index(reverse("`preopt'"),"]")==0 {
  di "{error}Warning: Stripping out a trailing [ bracket prior to comma"
  local preopt = substr("`preopt'",1,index("`preopt'","[")-1)+substr("`preopt'",index("`preopt'","[")+1,.) 
} 
if index(reverse("`preopt'"),"[")<index(reverse("`preopt'"),"]") & index(reverse("`preopt'"),"]")>0 {
  di as error "Warning: Stripping out a trailing [ bracket prior to comma"
//OLD  local preopt = substr("`preopt'",1,index("`preopt'","[")-1)+substr("`preopt'",index("`preopt'","[")+1,.) 
  local preopt = reverse(substr( reverse("`preopt'"), strpos(reverse("`preopt'"), "[")+1,.))
}

/***************************************************************************************
 * The options could have  opt(string asis)  and need to join the words 
 * by using quotes  i.e. opt(string asis) becomes "opt(string asis)" , one word
 ***************************************************************************************/

 local oopt_opt ""
di "{txt}Optional `opt_opt'"
 foreach word in `opt_opt' {
   if index("`word'","(")~=0 & index("`word'",")")~=0 local oopt_opt `"`oopt_opt' `word'"'
   else if index("`word'","(")~=0 local oopt_opt `"`oopt_opt' "`word'"'
   else if index("`word'",")")~=0 local oopt_opt `"`oopt_opt' `word'""'
   else local oopt_opt `"`oopt_opt' `word' "'
 }
 local oreq_opt ""
di "{txt}Required `req_opt'"
 foreach word in `req_opt' {
   if index("`word'","(")~=0 & index("`word'",")")~=0 local oreq_opt `"`oreq_opt' `word'"'
   else if index("`word'","(")~=0 local oreq_opt `"`oreq_opt' "`word'"'
   else if index("`word'",")")~=0 local oreq_opt `"`oreq_opt' `word'""'
   else local oreq_opt `"`oreq_opt' `word' "'
 }

di `"AFTER `oreq_opt'"'

/************************************************************************
 * CREATING the help file
 ************************************************************************/
 tempname fhw
 local hfile "`comm'.sthlp"   /* Error checking follows on file existence*/
 cap confirm file `hfile'
 if _rc==0 {
   di as error "WARNING: File `hfile' already exists"
   if "`replace'"~=""  {
     di " About to replace this file..."
     qui file open `fhw' using `hfile',replace write
   }
   else exit(198)
 }
 else {
   di as text "Creating file `hfile'..."
   qui file open `fhw' using `hfile', write
 }


 file  write `fhw' "{smcl}" _n
 file  write `fhw' "{* *! version 1.0 `c(current_date)'}{...}" _n
 file  write `fhw' `"{vieweralsosee "" "--"}{...}"' _n
 file  write `fhw' `"{vieweralsosee "Install command2" "ssc install command2"}{...}"' _n
 file  write `fhw' `"{vieweralsosee "Help command2 (if installed)" "help command2"}{...}"' _n
 file  write `fhw' `"{viewerjumpto "Syntax" "`comm'##syntax"}{...}"' _n
 file  write `fhw' `"{viewerjumpto "Description" "`comm'##description"}{...}"' _n
 file  write `fhw' `"{viewerjumpto "Options" "`comm'##options"}{...}"' _n
 file  write `fhw' `"{viewerjumpto "Remarks" "`comm'##remarks"}{...}"' _n
 file  write `fhw' `"{viewerjumpto "Examples" "`comm'##examples"}{...}"' _n
 file  write `fhw' `"{title:Title}"' _n
 file  write `fhw' `"{phang}"' _n

 /* Create the title text*/
 file  write `fhw' "{bf:`comm'} {hline 2} "
 if ("`tit_line'"~="") {
   forvalues ti = 1/`tit_line' {
     file  write `fhw' `"`title_text`ti''"' 
   }
 }
 else file write `fhw' "<Insert title>"

 file write `fhw' _n _n 
 file  write `fhw' "{marker syntax}{...}" _n
 file  write `fhw' "{title:Syntax}" _n
 file  write `fhw' "{p 8 17 2}" _n
 file  write `fhw' `"{cmdab:`comm'}"' _n

 foreach pre in `preopt' {
   if index("`pre'","syntax")~=0 continue
   else if index("`pre'","[in]")~=0 file  write `fhw' "[{help in}]" _n
   else if index("`pre'","[if]")~=0 file  write `fhw' "[{help if}]" _n
   else if index("`pre'","[varlist]")~=0 file  write `fhw' "[{help varlist}]" _n
   else file  write `fhw' "`pre'" _n
 }

 file write `fhw' "[{cmd:,}" _n
 file write `fhw' "{it:options}]" _n _n
 file write `fhw' "{synoptset 20 tabbed}{...}" _n
 file write `fhw' "{synopthdr}" _n
 file write `fhw' "{synoptline}" _n
  if `"`oreq_opt'"'~="" file write `fhw' "{syntab:Required }" _n

/*********************************************************************************
 * Processing the ?REQUIRED options for the syntax options table  
 *   lower(real 2)  function(string)  etc.. to create the default values in text
 *  this is not an exhaustive list and needs extending.
 *********************************************************************************/

 foreach option in `oreq_opt' {
   local dd ""
   if index("`option'","*")~=0 {  /* * is a special option and is handled separately */
     file  write `fhw' "{synopt:{opt *}} `star_txt1'{p_end}" _n
     continue
   }
   if index("`option'","(")~=0 {  /* check if it is a bracketed option() */
     local name = substr("`option'",1,index("`option'","(")-1) /*create name*/
     local inse = substr("`option'",index("`option'","(")+1,.) 
     local inse = substr("`inse'",1,index("`inse'",")")-1) /* find inner bit*/
     /* handle the integer and real options properly and get the default values */
     if index("`inse'","real")~=0 {
       if trim(substr("`inse'",index("`inse'","real")+4,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","real")+4,.)+"." 
       local inse "#"
     }    
     if ((index("`inse'","integer")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","integer")+7,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","integer")+7,.)+"."  
       local inse "#"
     }
     if ((index("`inse'","int")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","int")+3,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","int")+3,.)+"."  
       local inse "#"
     }
     local xx "(`inse')"
   }
   else {
     local name `"`option'"'
     local xx ""
   }

   /* Now split the name into lower and upper BUT remember noADEquate is allowed!*/
   if "`name'"~=lower("`name'") {
     if index("`name'","no")~=0 {
       local name = upper(substr("`name'",1,2))+substr("`name'",3,.)
     }
     local newname ""
     local split 0
     forv i=1/`=length("`name'")' {
       if lower(substr("`name'",`i',1))~=substr("`name'",`i',1) & !`split' local newname="`newname'"+lower(substr("`name'",`i',1))
       else if lower(substr("`name'",`i',1))==substr("`name'",`i',1) & !`split' {
         local split 1
         local newname="`newname':"+substr("`name'",`i',1)
       }
       else local newname="`newname'"+substr("`name'",`i',1)
     }
   }
   else local newname `"`name'"'

   local name = lower("`name'") /* take lower case as macro has text*/  
   /* if there are multiple lines then split the writing into the number of lines*/
   if `"``name'_txt1'"'=="" {
     if "`newname'"~="star" file  write `fhw' `"{synopt:{opt `newname'`xx'}} ``name'' `dd'{p_end}"' _n /* need to handle stars */
     else file  write `fhw' "{opt *} `star_txt1' {p_end}"  _n
   }
   else {
     if "`newname'"~="star" file  write `fhw' `"{synopt:{opt `newname'`xx'}} "'
     else  file  write `fhw' "{opt *} "
     if "``name'_line'"~="" {
       forvalues opti = 1/``name'_line' {
       if (strtrim(`"``name'_txt`opti''"')=="") {
         file write `fhw' _n "{pstd}" _n
       }
       else file  write `fhw' `"``name'_txt`opti''"' _n
       }
       file  write `fhw' "{p_end}" _n
     }
   }
 }

 
  if `"`oopt_opt'"'~="" file write `fhw' "{syntab:Optional}" _n

/*********************************************************************************
 * Processing the OPTIONAL options for the syntax options table  
 *   lower(real 2)  function(string)  etc.. to create the default values in text
 *  this is not an exhaustive list and needs extending.
 *********************************************************************************/
 foreach option in `oopt_opt' {
   local dd ""
   if index("`option'","*")~=0 {  /* * is a special option and is handled separately */
     file  write `fhw' "{synopt:{opt *}} `star_txt1'{p_end}" _n
     continue
   }
   if index("`option'","(")~=0 {  /* check if it is a bracketed option() */
     local name = substr("`option'",1,index("`option'","(")-1) /*create name*/
     local inse = substr("`option'",index("`option'","(")+1,.) 
     local inse = substr("`inse'",1,index("`inse'",")")-1) /* find inner bit*/
     /* handle the integer and real options properly and get the default values */
     if index("`inse'","real")~=0 {
       if trim(substr("`inse'",index("`inse'","real")+4,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","real")+4,.)+"." 
       local inse "#"
     }    
     if ((index("`inse'","integer")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","integer")+7,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","integer")+7,.)+"."  
       local inse "#"
     }
     if ((index("`inse'","int")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","int")+3,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","int")+3,.)+"."  
       local inse "#"
     }
     local xx "(`inse')"
   }
   else {
     local name `"`option'"'
     local xx ""
   }

   /* Now split the name into lower and upper BUT remember noADEquate is allowed!*/
   if "`name'"~=lower("`name'") {
     if index("`name'","no")~=0 {
       local name = upper(substr("`name'",1,2))+substr("`name'",3,.)
     }
     local newname ""
     local split 0
     forv i=1/`=length("`name'")' {
       if lower(substr("`name'",`i',1))~=substr("`name'",`i',1) & !`split' local newname="`newname'"+lower(substr("`name'",`i',1))
       else if lower(substr("`name'",`i',1))==substr("`name'",`i',1) & !`split' {
         local split 1
         local newname="`newname':"+substr("`name'",`i',1)
       }
       else local newname="`newname'"+substr("`name'",`i',1)
     }
   }
   else local newname `"`name'"'

   local name = lower("`name'") /* take lower case as macro has text*/  
   /* if there are multiple lines then split the writing into the number of lines*/
   if `"``name'_txt1'"'=="" {
     if "`newname'"~="star" file  write `fhw' `"{synopt:{opt `newname'`xx'}} ``name'' `dd'{p_end}"' _n /* need to handle stars */
     else file  write `fhw' "{opt *} `star_txt1' {p_end}"  _n
   }
   else {
     if "`newname'"~="star" file  write `fhw' `"{synopt:{opt `newname'`xx'}} "'
     else  file  write `fhw' "{opt *} "
     if "``name'_line'"~="" {
       forvalues opti = 1/``name'_line' {
       if (strtrim(`"``name'_txt`opti''"')=="") {
         file write `fhw' _n "{pstd}" _n
       }
       else file  write `fhw' `"``name'_txt`opti''"' _n
       }
       file  write `fhw' "{p_end}" _n
     }
   }
 }


 file  write `fhw' "{synoptline}" _n
 file  write `fhw' "{p2colreset}{...}" _n
 file  write `fhw' "{p 4 6 2}" _n
 file  write `fhw' _n "{marker description}{...}" _n
 
 /* The description can allow for multiple lines*/
 file  write `fhw' "{title:Description}" _n 
 file  write `fhw' "{pstd}" _n

 if "`desc_line'"~="" {
   forvalues desci = 1/`desc_line' {
     if (strtrim(`"`desc_text`desci''"')=="") {
       file write `fhw' _n "{pstd}" _n
     }
     else file  write `fhw' `"`desc_text`desci''"' _n
   }
 }

 file  write `fhw' _n "{marker options}{...}" _n
 file  write `fhw' "{title:Options}" _n
 file  write `fhw' "{dlgtab:Main}" _n

/*******************************************************************************
 * Writing the longer descriptions of the options
 *  the longer descriptions should be specified in opt2[] syntax but if that is
 *  blank then it should default to the opt[] syntax
 *******************************************************************************/

 foreach option in `oopt_opt' `oreq_opt' {
   local dd ""
   if index("`option'","(")~=0 { /* if the option contains brackets */
     local name = substr("`option'",1,index("`option'","(")-1)
     local inse = substr("`option'",index("`option'","(")+1,.) 
     local inse = substr("`inse'",1,index("`inse'",")")-1)
     /* handle the integer and real options properly */
     if index("`inse'","real")~=0 {
       if trim(substr("`inse'",index("`inse'","real")+4,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","real")+4,.) 
       local inse "#"
     }
     if ((index("`inse'","integer")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","integer")+7,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","integer")+7,.)  
       local inse "#"
     }    
     if ((index("`inse'","int")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","int")+3,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","int")+3,.)  
       local inse "#"
     }
     local xx "(`inse')"
   }
   else {
     if "`option'"~= "*" local name "`option'"
     else local name "star"
     local xx ""
   }
  /* Now split the name into lower and upper */
   if "`name'"~=lower("`name'") {
     if index("`name'","no")~=0 {
       local name = upper(substr("`name'",1,2))+substr("`name'",3,.)
     }
     local newname ""
     local split 0
     forv i=1/`=length("`name'")' {
       if lower(substr("`name'",`i',1))~=substr("`name'",`i',1) & !`split' local newname="`newname'"+lower(substr("`name'",`i',1))
       else if lower(substr("`name'",`i',1))==substr("`name'",`i',1) & !`split' {
         local split 1
         local newname="`newname':"+substr("`name'",`i',1)
       }
       else local newname="`newname'"+substr("`name'",`i',1)
     }
   }
   else local newname "`name'"

   local name = lower("`name'") /* take lower case as macro has text*/  
   file  write `fhw' "{phang}" _n
   
   /* this is the part that does the text writing for the option first checking if*/
   if "``name'2_txt1'"=="" {
     if "`newname'"~="star" {
       file  write `fhw' `"{opt `newname'`xx'} ``name''   "'
       if "``name'_line'"~="" {
         forvalues opti = 1/``name'_line' {
           if (strtrim(`"``name'_txt`opti''"')=="") {
             file write `fhw' _n "{pstd}" _n
           }
           else file  write `fhw' `"``name'_txt`opti''"' _n
         }
       }     
       file  write `fhw' "{p_end}" _n
     }
     else file  write `fhw' "{opt *} `star_txt1' {p_end}" _n
   }
   else {
     if "`newname'"~="star" file  write `fhw' `"{opt `newname'`xx'} "'
     else  file  write `fhw' "{opt *} "
     if "``name'2_line'"~="" {
       forvalues opti = 1/``name'2_line' {
         if (strtrim(`"``name'2_txt`opti''"')=="") {
           file write `fhw' _n "{pstd}" _n
         }
         else file  write `fhw' `"``name'2_txt`opti''"' _n
       }
     }
     file  write `fhw' "{p_end}" _n
   }
 }

 file write `fhw' _n _n "{marker examples}{...}" _n
 file write `fhw' "{title:Examples}" _n
 file  write `fhw' "{pstd}" _n
 if "`eg_line'"~="" {
   forvalues egi = 1/`eg_line' {
     if (strtrim(`"`eg_text`egi''"')=="") {
       file write `fhw' _n "{pstd}" _n
     }
     else file  write `fhw' `"`eg_text`egi''"' _n
   }
 }
/*******************************************************************
 * If we know it is a rclass,sclass or eclass function 
 *******************************************************************/
 
 if ("`rclass'"=="1" | "`sclass'"=="1" | "`eclass'"=="1") {
   if ("`rclass'"=="1") local rrr "r("
   if ("`sclass'"=="1") local rrr "s("
   if ("`eclass'"=="1") local rrr "e("
   
   file write `fhw' _n "{title:Stored results}" _n
   file write `fhw' _n "{synoptset 15 tabbed}{...}" _n
  
   if "`retslist'"~="" {
     file write `fhw' "{p2col 5 15 19 2: Scalars}{p_end}" _n
     foreach ret of local retslist {
       file write `fhw' `"{synopt:{cmd:`rrr'`ret')}} `ret`ret'' {p_end}"' _n
     }
   }
   if "`retllist'"~="" {
     file write `fhw' "{p2col 5 15 19 2: Locals}{p_end}" _n
     foreach ret of local retllist {
       file write `fhw' `"{synopt:{cmd:`rrr'`ret')}} `ret`ret'' {p_end}"' _n
     }
   }
   if "`retmlist'"~="" {
     file write `fhw' "{p2col 5 15 19 2: Matrices}{p_end}" _n
     foreach ret of local retmlist {
       file write `fhw' `"{synopt:{cmd:`rrr'`ret')}} `ret`ret'' {p_end}"' _n
     }
   }
 }

 /* The references can allow for multiple lines*/
 if "`ref_line'"~="" {
   file  write `fhw' _n _n "{title:References}" _n 
   file  write `fhw' "{pstd}" _n
   if "`ref_line'"~="" {
     forvalues refi = 1/`ref_line' {
       if (strtrim(`"`ref_text`refi''"')=="") {
         file write `fhw' _n "{pstd}" _n
       }
       else file  write `fhw' `"`ref_text`refi''"' _n
     }
   }
 }
 
  /* The free text section can allow for multiple lines*/
 if "`free_line'"~="" {
   if "`free_line'"~="" {
     forvalues freei = 1/`free_line' {
       if (strtrim(`"`free_text`freei''"')=="") {
         file write `fhw' _n "{pstd}" _n
       }
       else file  write `fhw' `"`free_text`freei''"' _n
     }
   }
 }

file write `fhw' _n _n "{title:Author}" _n
file write `fhw' "{p}" _n
if "`me'"~="" {
  file write `fhw' "{p_end}" _n
  file write `fhw' "{pstd}" _n
  file write `fhw' "Adrian Mander, MRC Biostatistics Unit, Cambridge, UK." _n
  file write `fhw' _n "{pstd}" _n
  file write `fhw' `"Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}"' _n
}
else {
  forvalues ai = 1/`authi' {
    if "`institute`ai'_text'"~="" file write `fhw' _n `"`author`ai'_text', `institute`ai'_text'."' _n
    else file write `fhw' _n `"`author`ai'_text'"' _n
    if "`email`ai'_text'"~="" file write `fhw' _n `"Email {browse "mailto:`email`ai'_text'":`email`ai'_text'}"' _n
  }
}

if "`see_line'"~="" {
  file write `fhw' _n "{title:See Also}" _n
  file write `fhw' "Related commands:" _n
  forvalues seei = 1/`see_line' {
//    if (strtrim(`"`see_text`seei''"')=="") {
//      file write `fhw' _n "{pstd}" _n
//    }
//    else file  write `fhw' "`see_text`seei''" _n
    file  write `fhw' `"`see_text`seei''"' _n
  }
}

file close `fhw'

/*******************************************************************************
 *
 * Write the LATEX version 
 *
 ******************************************************************************/

if "`latex'"~="" {
  tempname fhw
  local hfile "`comm'.tex"   /* Error checking follows on file existence*/
  cap confirm file `hfile'
  if _rc==0 {
    di as error "WARNING: File `hfile' already exists"
    if "`replace'"~=""  {
      di " About to replace this file..."
      qui file open `fhw' using `hfile',replace write
    }
    else exit(198)
  }
  else {
    di as text "Creating file `hfile'..."
    qui file open `fhw' using `hfile', write
  }
 file write `fhw' "\documentclass[times,english,doublespace]{article}" _n
 file write `fhw' "\begin{document}" _n
 file write `fhw' "\section{The command `comm'}" _n
 file write `fhw' _n
 file  write `fhw' "\subsection{Syntax}" _n
 file  write `fhw' `"{\tt `comm' "'

 foreach pre in `preopt' {
   if index("`pre'","syntax")~=0 continue
   else if index("`pre'","[in]")~=0 file  write `fhw' " [in]" 
   else if index("`pre'","[if]")~=0 file  write `fhw' " [if]"
   else if index("`pre'","[varlist]")~=0 file  write `fhw' " [varlist]" 
   else file  write `fhw' " `pre'" 
 }

 file write `fhw' "," _n

/*********************************************************************************
 * Processing the ?REQUIRED options for the syntax options table  
 *   lower(real 2)  function(string)  etc.. to create the default values in text
 *  this is not an exhaustive list and needs extending.
 *********************************************************************************/

 foreach option in `oreq_opt' {
   local dd ""
   if index("`option'","*")~=0 {  /* * is a special option and is handled separately */
     file  write `fhw' " * `star_txt1' \\" _n
     continue
   }
   if index("`option'","(")~=0 {  /* check if it is a bracketed option() */
     local name = substr("`option'",1,index("`option'","(")-1) /*create name*/
     local inse = substr("`option'",index("`option'","(")+1,.) 
     local inse = substr("`inse'",1,index("`inse'",")")-1) /* find inner bit*/
     /* handle the integer and real options properly and get the default values */
     if index("`inse'","real")~=0 {
       if trim(substr("`inse'",index("`inse'","real")+4,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","real")+4,.)+"." 
       local inse "\#"
     }    
     if ((index("`inse'","integer")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","integer")+7,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","integer")+7,.)+"."  
       local inse "\#"
     }
     if ((index("`inse'","int")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","int")+3,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","int")+3,.)+"."  
       local inse "\#"
     }
     local xx "(`inse')"
   }
   else {
     local name `"`option'"'
     local xx ""
   }

   /* Now split the name into lower and upper BUT remember noADEquate is allowed!*/
   if "`name'"~=lower("`name'") {
     if index("`name'","no")~=0 {
       local name = upper(substr("`name'",1,2))+substr("`name'",3,.)
     }
     local newname ""
     local split 0
     forv i=1/`=length("`name'")' {
       if lower(substr("`name'",`i',1))~=substr("`name'",`i',1) & !`split' local newname="`newname'"+lower(substr("`name'",`i',1))
       else if lower(substr("`name'",`i',1))==substr("`name'",`i',1) & !`split' {
         local split 1
         local newname="\underline{`newname'}"+substr("`name'",`i',1)
       }
       else local newname="`newname'"+substr("`name'",`i',1)
     }
   }
   else local newname `"`name'"'

   local name = lower("`name'") /* take lower case as macro has text*/  
   /* if there are multiple lines then split the writing into the number of lines*/
    if "`newname'"~="star" {
      file  write `fhw' `" `newname'`xx' "' _n 
    }
    else file  write `fhw' " *  "  _n

 }

/*********************************************************************************
 * Processing the OPTIONAL options for the syntax options table  
 *   lower(real 2)  function(string)  etc.. to create the default values in text
 *  this is not an exhaustive list and needs extending.
 *********************************************************************************/
 foreach option in `oopt_opt' {
   local dd ""
   if index("`option'","*")~=0 {  /* * is a special option and is handled separately */
     file  write `fhw' " * `star_txt1' \\" _n
     continue
   }
   if index("`option'","(")~=0 {  /* check if it is a bracketed option() */
     local name = substr("`option'",1,index("`option'","(")-1) /*create name*/
     local inse = substr("`option'",index("`option'","(")+1,.) 
     local inse = substr("`inse'",1,index("`inse'",")")-1) /* find inner bit*/
     /* handle the integer and real options properly and get the default values */
     if index("`inse'","real")~=0 {
       if trim(substr("`inse'",index("`inse'","real")+4,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","real")+4,.)+"." 
       local inse "\#"
     }    
     if ((index("`inse'","integer")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","integer")+7,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","integer")+7,.)+"."  
       local inse "\#"
     }
     if ((index("`inse'","int")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","int")+3,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","int")+3,.)+"."  
       local inse "\#"
     }
     local xx "(`inse')"
   }
   else {
     local name `"`option'"'
     local xx ""
   }

   /* Now split the name into lower and upper BUT remember noADEquate is allowed!*/
   if "`name'"~=lower("`name'") {
     if index("`name'","no")~=0 {
       local name = upper(substr("`name'",1,2))+substr("`name'",3,.)
     }
     local newname ""
     local split 0
     forv i=1/`=length("`name'")' {
       if lower(substr("`name'",`i',1))~=substr("`name'",`i',1) & !`split' local newname="`newname'"+lower(substr("`name'",`i',1))
       else if lower(substr("`name'",`i',1))==substr("`name'",`i',1) & !`split' {
         local split 1
         local newname="\underline{`newname'}"+substr("`name'",`i',1)
       }
       else local newname="`newname'"+substr("`name'",`i',1)
     }
   }
   else local newname `"`name'"'
   local name = lower("`name'") /* take lower case as macro has text*/  

    if "`newname'"~="star" file  write `fhw' `" `newname'`xx' "'
    else  file  write `fhw' " * "
   
 }

 file  write `fhw' "}" _n /* end of tt text */
 
 
 /* The description can allow for multiple lines*/
 file  write `fhw' "\section{Description}" _n 
 file  write `fhw' "" _n

 if "`desc_line'"~="" {
   forvalues desci = 1/`desc_line' {
     if (strtrim(`"`desc_text`desci''"')=="") {
       file write `fhw' _n
     }
     else file  write `fhw' `"`desc_text`desci''"' _n
   }
 }

 file  write `fhw' "\section{Options}" _n




/*******************************************************************************
 * Writing the longer descriptions of the options
 *  the longer descriptions should be specified in opt2[] syntax but if that is
 *  blank then it should default to the opt[] syntax
 *******************************************************************************/

 foreach option in `oopt_opt' `oreq_opt' {
   local dd ""
   if index("`option'","(")~=0 { /* if the option contains brackets */
     local name = substr("`option'",1,index("`option'","(")-1)
     local inse = substr("`option'",index("`option'","(")+1,.) 
     local inse = substr("`inse'",1,index("`inse'",")")-1)
     /* handle the integer and real options properly */
     if index("`inse'","real")~=0 {
       if trim(substr("`inse'",index("`inse'","real")+4,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","real")+4,.) 
       local inse "\#"
     }
     if ((index("`inse'","integer")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","integer")+7,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","integer")+7,.)  
       local inse "\#"
     }    
     if ((index("`inse'","int")~=0 ) & (index("`inse'","numlist")==0)) {
       if trim(substr("`inse'",index("`inse'","int")+3,.))~="" local dd ="Default value is"+substr("`inse'",index("`inse'","int")+3,.)  
       local inse "\#"
     }
     local xx "(`inse')"
   }
   else {
     if "`option'"~= "*" local name "`option'"
     else local name "star"
     local xx ""
   }
  /* Now split the name into lower and upper */
   if "`name'"~=lower("`name'") {
     if index("`name'","no")~=0 {
       local name = upper(substr("`name'",1,2))+substr("`name'",3,.)
     }
     local newname ""
     local split 0
     forv i=1/`=length("`name'")' {
       if lower(substr("`name'",`i',1))~=substr("`name'",`i',1) & !`split' local newname="`newname'"+lower(substr("`name'",`i',1))
       else if lower(substr("`name'",`i',1))==substr("`name'",`i',1) & !`split' {
         local split 1
         local newname="\underline{`newname'}"+substr("`name'",`i',1)
       }
       else local newname="`newname'"+substr("`name'",`i',1)
     }
   }
   else local newname "`name'"

   local name = lower("`name'") /* take lower case as macro has text*/  
   
   /* this is the part that does the text writing for the option first checking if*/
   if "``name'2_txt1'"=="" {
     if "`newname'"~="star" {
       file  write `fhw' `" {\tt `newname'`xx'} ``name''   "' 
       if "``name'_line'"~="" {
         forvalues opti = 1/``name'_line' {
           if (strtrim(`"``name'_txt`opti''"')=="") {
           }
           else file  write `fhw' `"``name'_txt`opti''"'
         }
       }     
     }
     else file  write `fhw' "* `star_txt1' " 
   }
   else {
     if "`newname'"~="star" file  write `fhw' `" `newname'`xx' "'
     else  file  write `fhw' " * "
     if "``name'2_line'"~="" {
       forvalues opti = 1/``name'2_line' {
         if (strtrim(`"``name'2_txt`opti''"')=="") {
         }
         else file  write `fhw' `"``name'2_txt`opti''"' 
       }
     }
   }
   file  write `fhw' "\\" _n
 }

 file write `fhw' "\section{Examples}" _n
 file  write `fhw' _n
 if "`eg_line'"~="" {
   forvalues egi = 1/`eg_line' {
     if (strtrim(`"`eg_text`egi''"')=="") {
       file write `fhw' _n
     }
     else {
      local temp = subinstr(`"`eg_text`egi''"', "%", "\%",.)
      file  write `fhw' `"`temp'"' _n
     }
   }
 }
/*******************************************************************
 * If we know it is a rclass,sclass or eclass function 
 *******************************************************************/
 
 if ("`rclass'"=="1" | "`sclass'"=="1" | "`eclass'"=="1") {
   if ("`rclass'"=="1") local rrr "r("
   if ("`sclass'"=="1") local rrr "s("
   if ("`eclass'"=="1") local rrr "e("
   
   file write `fhw' _n "\subsection{Stored results}" _n
  
   if "`retslist'"~="" {
     file write `fhw' "\subsubsection{Scalars}" _n
     foreach ret of local retslist {
       file write `fhw' `"`rrr'`ret'  `ret`ret'' \\"' _n
     }
   }
   if "`retllist'"~="" {
     file write `fhw' "\subsubsection{Locals}" _n
     foreach ret of local retllist {
       file write `fhw' `"`rrr'`ret' `ret`ret'' \\"' _n
     }
   }
   if "`retmlist'"~="" {
     file write `fhw' "\subsubsection{Matrices}" _n
     foreach ret of local retmlist {
       file write `fhw' `"`rrr'`ret' `ret`ret'' \\"' _n
     }
   }
 }

 /* The references can allow for multiple lines*/
 if "`ref_line'"~="" {
   file  write `fhw' _n _n "{title:References}" _n 
   file  write `fhw' "{pstd}" _n
   if "`ref_line'"~="" {
     forvalues refi = 1/`ref_line' {
       if (strtrim(`"`ref_text`refi''"')=="") {
         file write `fhw' _n "{pstd}" _n
       }
       else file  write `fhw' `"`ref_text`refi''"' _n
     }
   }
 }
 
  /* The free text section can allow for multiple lines*/
 if "`free_line'"~="" {
   if "`free_line'"~="" {
     forvalues freei = 1/`free_line' {
       if (strtrim(`"`free_text`freei''"')=="") {
         file write `fhw' _n _n
       }
       else file  write `fhw' `"`free_text`freei''"' _n
     }
   }
 }

file write `fhw' _n _n "\subsection{Author}" _n
file write `fhw' _n
if "`me'"~="" {
  file write `fhw' "Adrian Mander, Cardiff University, Cardiff, Wales." _n
  file write `fhw' `"Email: mandera@cardiff.ac.uk"' _n
}
else {
  forvalues ai = 1/`authi' {
    if "`institute`ai'_text'"~="" file write `fhw' _n `"`author`ai'_text', `institute`ai'_text'."' _n
    else file write `fhw' _n `"`author`ai'_text'"' _n
    if "`email`ai'_text'"~="" file write `fhw' _n `"Email:`email`ai'_text'"' _n
  }
}

if "`see_line'"~="" {
  file write `fhw' _n "\subsecdtion{See Also}" _n
  file write `fhw' "Related commands:" _n
  forvalues seei = 1/`see_line' {
//    if (strtrim(`"`see_text`seei''"')=="") {
//      file write `fhw' _n "{pstd}" _n
//    }
//    else file  write `fhw' "`see_text`seei''" _n
    file  write `fhw' `"`see_text`seei''"' _n
  }
}

  file write `fhw' "\end{document}"

  file close `fhw'

} /* end of if latex */

end
