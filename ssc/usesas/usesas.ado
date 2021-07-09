*! usesas Version 2.3 dan_blanchette@unc.edu 26Jan2012
*! the carolina population center, unc-ch
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
** - now creates more unique temporary file names.
** usesas Version 2.2 dan_blanchette@unc.edu 03Jan2011
** - now handles SPSS files  
** usesas Version 2.2 dan.blanchette@duke.edu  07Dec2010
** - now directories with single quotes in the name are allowed. 
** usesas Version 2.2 dan.blanchette@duke.edu  04Feb2010
** - made it work with Stata 8 again.
** usesas Version 2.1 dan.blanchette@duke.edu  15Apr2009
** - made it so that the describe option returns scalars as promised in the help file.
** usesas Version 2.1 dan.blanchette@duke.edu  26Feb2009
** - made usesas fail gracefully when there was no SAS dataset in &SYSLAST. when using a SAS program
**    instead of a dataset
** usesas Version 2.0 dan.blanchette@duke.edu  24Nov2008
** - added ".tpt" as a known file extension for SAS transport file since NEBER uses that file extension
** usesas Version 2.0 dan_blanchette@unc.edu  25Mar2008
** research computing, unch-ch
** - added describe option that loads the metadata of the using dataset into memory
**    and displays a Stata-like -describe- description of the using data.
** - made it so that when used with Stata MP savastata treats data like Stata SE
** - fixed it when usesas uses sas programs and the SAS program's last SAS dataset
**    is a permanent one then it deletes that file and doesn't fail with odd errors.
** - made it so that when savastata fails by a known error usesas deletes whatever
**    intermediary files were created.
** - added error message that -usesas- cannot be run in Stata batch in Windows
** - removed efforts to keep sortedby vars since descending sorts in SAS mess up Stata
**    as well as missing values mess up sort order...left it in for --usesas describe--
** usesas Version 1.4 dan_blanchette@unc.edu  17Apr2007
** - made it so that if a format catalog file was created for a different OS
**    would provide a message to user that that was the case and that the
**    SAS formats would not be used to create Stata value labels
** - fixed it so that if in console mode you are not suggested to click something.
** usesas Version 1.4 dan_blanchette@unc.edu  24Aug2006
** - corrected how the SAS check name was displayed.
**  usesas Version 1.4 dan_blanchette@unc.edu  09Nov2005
** - made usesasdel it's own ado-file
** usesas Version 1.4 dan_blanchette@unc.edu  28Sep2005
** - stopped savastata from closing user's log if one was open
** usesas Version 1.3 dan_blanchette@unc.edu  04Aug2005
** - in non-console mode when messy option used, you can now delete all files 
** - for Stata 9 new option char2lab that uses my SAS macro char2fmt that converts 
**    long SAS character variables to numeric with value labels like -encode- does.
** - allow datasets created by proc cport 
**   NOTE: SAS's CIMPORT procedure will not open a datafile created in later version of SAS
** - use rver() to control sas engine type  
** - now passing Stata version to savastata 
** - sort order preserved, though data never lost sort order, Stata needs to sort data to know its sort order
** - added float option to allow user to save space with numeric vars that would otherwise
**    require being stored in 8-byte double.
** usesas Version 1.2 dan_blanchette@unc.edu  06Jan2005
** - now accepts an xport file that has a different internal dataset name 
** usesas Version 1.1 dan_blanchette@unc.edu  11Nov2004
** - fixed it so that if() can contain code with double quotes
**    e.g: if(`" var="A" "')
** - fixed it so that when a user submitts a SAS program
**    only their program is printed in the *_usesas.log file 
**    and not the whole sasvastata macro code as before
** - deletes non-work SAS dataset created by user's SAS program
** - fix code related to "if" option
** - reduced usage of subinstr to help allow for directory paths and if conditions 
**    to be longer than 80 characters
** usesas Version 1.0 dan_blanchette@unc.edu  13Jul2004
** - added mprint and source2 so that user submitted programs
**    would appear in the *_usesas.log file
** usesas Version 1.0 dan_blanchette@unc.edu  17Nov2003
** usesas Version 1.0 dan_blanchette@unc.edu  27Oct2003
** the carolina population center, unc-ch


program define usesas, rclass
 version 8  
syntax using/  [, MEssy FORmats xport clear QUotes char2lab CHeck float ///
                   KEep(string) DEscribe listnot if(string) in(string) ] 

/* log usage of usesas */
capture which usagelog
if _rc==0 {
 usagelog , start type(savas) message(`"usesas using `using', `messy' `formats' `xport' `clear' `quotes' `char2lab' `check' keep(`keep') `describe' `listnot' if(`if') in(`in') "') 
}

if "`c(os)'"=="Windows" & "`c(mode)'" == "batch" {
  di as err "{help usesas:usesas} cannot be run in batch mode on Windows"
  /* log usage of usesas */
  capture which usagelog
  if _rc==0 {
   usagelog , type(savas) uerror(8) etime
  }
  exit  499
}

if "`listnot'" != ""  & "`describe'" == "" {
  di as err "listnot option only allowed when using the descibe option"
  /* log usage of usesas */
  capture which usagelog
  if _rc==0 {
   usagelog , type(savas) uerror(8) etime
  }
  exit  499
}

di `"{txt}The {help usesas:usesas} {txt}command uses the {browse "http://www.cpc.unc.edu/research/tools/data_analysis/sas_to_stata/savastata.html":savastata} {txt}SAS macro to load the SAS dataset into memory."'
di "{txt}Large datasets may take a few minutes."

if `c(N)'!=0 & "`clear'"=="" {
 di "{error} no, data in memory would be lost" 
 di "{error} use the {res}clear {error}option"
 /* log usage of usesas */
 capture which usagelog
 if _rc==0 {
  usagelog , type(savas) uerror(1) etime
 }
 exit  4
}

* CAPTURE USER'S LOG 
* ------------------
if int(`c(stata_version)') >= 9 quietly log query
local usrlog  `r(filename)'

* FIGURE OUT WHERE SAS EXECUTABLE IS
* ----------------------------------
sasexe usesas 

local wsas `r(wsas)'
local usas `r(usas)'
local savastata `r(savastata)'
local char2fmt `r(char2fmt)'
local rver `r(rver)'  // version of sas that's being run i.e. "v8", "v9" etc


if index(`"`using'"',`"""')  /* "' */ {
 di `"{help usesas} {error}cannot handle directory or file names that contain double quotes. "'
  capture which usagelog
 if _rc==0 {
  usagelog , type(savas) uerror(2) etime
 }
 exit 499
}

/* if filename is given with directory info too, 
    strip to just file name and to dir location */
 if "`c(os)'"=="Windows" {
  local dirsep="\"
  if index("`using'","/") {
   local using : subinstr local using "/" "\" , all
  }
 }
 else {
  local dirsep="`c(dirsep)'"
 }
 if index("`using'","`dirsep'") { 
  local filen=substr("`using'",index("`using'","`dirsep'")+1,length("`using'"))
  while index("`filen'","`dirsep'") !=0 {
   local filen=substr("`filen'",index("`filen'","`dirsep'")+1,length("`filen'"))
  }
  local dir=substr("`using'",1,index("`using'","`filen'")-1)
 }
 else if index("`using'","\\\")==1 {   /* Universal naming convention */
  local filen=substr("`using'",index("`using'","\\\")+2,length("`using'"))
  while index("`filen'","\") !=0 {
   local filen=substr("`filen'",index("`filen'","\")+1,length("`filen'"))
  }
  local dir=substr("`using'",1,index("`using'","`filen'")-1)
 }
 else {  /* no directory given */
  local filen="`using'"
  local dir ="`c(pwd)'`dirsep'" 
 }


 /** extract file extension if there is one **/
if index("`filen'",".") {
 local ext=substr("`filen'",index("`filen'","."),length("`filen'"))
 while index("`ext'",".") > 0 {
  local ext=substr("`ext'",index("`ext'",".")+1,length("`ext'"))
 }
 local ext=".`ext'"
 local middle=substr("`filen'",1,index("`filen'","`ext'")-1) /* middle will not end in a period */
 local filen=substr("`filen'",1,index("`filen'",".")-1)
 local middle=substr("`middle'",length("`filen'")+1,length("`middle'"))
}

if lower("`ext'")==".sas7bdat" {
 local type="sas"
}
else if lower("`ext'")==".sd7" {
 local type="sas"
 local shortfileext="shortfileext"
}
else if lower("`ext'")==".ssd01" {
 local type="sas6"
}
else if lower("`ext'")==".ssd02" {
 local type="sas6"
}
else if lower("`ext'")==".sd2" {
 local type="sas6"
}
else if lower("`ext'")==".sas" {
 local type="sasprogram"
}
else if lower("`ext'")==".por" {
 local type="spss"
}
else if lower("`ext'")==".xpt"    | ///
        lower("`ext'")==".xport"  | ///
        lower("`ext'")==".export" | ///
        lower("`ext'")==".expt"   | ///
        lower("`ext'")==".exp"    | ///
        lower("`ext'")==".trans"  | ///
        lower("`ext'")==".tpt"    | ///
        lower("`ext'")==".cport"  | ///
        lower("`ext'")==".ssp"    | ///
        lower("`ext'")==".stx"    | ///
        lower("`ext'")==".sasx"   | ///
        lower("`ext'")==".v5x"    | ///
        lower("`ext'")==".v6x"  {
 local type="sasx"
}
else if "`xport'"=="xport" {  // else no file extension
 local type="sasx"
}
else {  // guess that the user is wanting to use a .sas7bdat file
 local using1 `"`using'.sas7bdat"'
 local ext ".sas7bdat"
 local type="sas"
 capture confirm file `"`using1'"'
 if _rc != 0 {
  di `"{error}The SAS file: `using1' does not exist."'
  // check that user is not expecting file extention but forgot to use xport option
  capture confirm file `"`using'"'
  if _rc == 0 {
   di `"{error}But the SAS file: `using' does exist."'
   di as text `"Use the xport option as it is likely this file is a transport/xport file."'
  }
  /* log usage of usesas */
  capture which usagelog
  if _rc==0 {
   usagelog , type(savas) uerror(3) etime
  }
  exit 601
 }
 // only here if this file does exist
 local using `"`using'.sas7bdat"'
}

capture confirm file `"`using'"'
if _rc != 0 {
 di `"{error}The SAS file: `using' does not exist."'
 /* log usage of usesas */
 capture which usagelog
 if _rc==0 {
  usagelog , type(savas) uerror(3) etime
 }
 exit 601
}

if "`type'"=="" {
 di "{error}Is `using' a SAS transport/xport data file?"
 di "{error}If so then use the {res}xport {error}option."
 /* log usage of usesas */
 capture which usagelog
 if _rc==0 {
  usagelog , type(savas) uerror(4) etime
 }

 exit 499
}


if "`type'"=="sas" {
  local engine="`rver'"  // whatever version of SAS that's being used
}
else if "`type'"=="sas6" {
 local engine="v6"
}
else if "`type'"=="sasprogram" {
 local sasprogram="sasprogram"
}
else if "`type'"=="sasx" {
 local engine="xport"
}
else if "`type'"=="spss" {
 local engine="spss"
}

/* set where temp directory is */
tmpdir
local tmpdir="`r(tmpdir)'"

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

local temp `"`macval(tmpdir)'_`sysjobid'"'
local raw `"`macval(tmpdir)'_`sysjobid'_usesas"'
local xpt "`macval(dir)'`filen'`middle'`ext'"


* MAKE "IF" AND "IN" INTO SAS CODE 
* -------------------------------- 
local firstobs = upper(substr("`in'",1,index("`in'","/")-1))
if "`firstobs'" == "F" | index("`firstobs'","-") {
  di `"{error}Your 'in()' option cannot use f/F or negative values. "'
  exit 100
}
local obs = upper(substr("`in'",index("`in'","/")+1,length("`in'")))
if "`obs'" == "L" {
  di `"{error}Your 'in()' option cannot use l/L. "'
  exit 100
}

if `"`if'"'!=`""' {
 local iflen : length local if
 if `iflen'>247 {  // 255-6-wiggle room = 247 
  // 'if()' option needs to be less than 255 characters for SAS to process, it is limited to max length of string
  di `"{error}Your 'if()' option is longer than max length of 247. "'
  exit 100
 }
 else { // okay to process 
  if index(`"`if'"',"==") {
   local if : subinstr local if "==" "=" , all
  }
  if lower(substr(`"`if'"',1,3)) != `"if "' &  lower(substr(`"`if'"',1,6)) != `"where "' {
   local if `"where `if'"'
  }
  else if lower(substr(`"`if'"',1,3)) == `"if "' {  
   di `"{error}Your 'if()' option starts with "if".  The "if" is assumed, do not type it."'
   exit 100
  }
  /* now make sure if has only one 'if' or 'where' in it */
  if index(lower(`"`if'"')," if ") | index(lower(`"`if'"')," inrange(") | /*
  */ index(lower(`"`if'"')," inlist(")  |  index(lower(`"`if'"')," where ")>1 {
   di `"{error}Invalid SAS 'if' condition."'
   capture which usagelog
   if _rc==0 {
    usagelog , type(savas) uerror(5) etime
   }
   exit 499
  }
 }  // 'if()' is less than 247 chars
}



* WRITE SAS PROGRAM TO READ IN DATA
* ---------------------------------
usesas_sas , rver(`rver') dirsep("`dirsep'") dir("`dir'") tmpdir("`tmpdir'") filen(`filen') raw("`raw'") engine(`engine') /// 
            `shortfileext' `quotes' `check' `formats' sysjobid(`sysjobid') ext(`ext') middle(`middle') xpt("`xpt'") ///
            savastata("`savastata'")  if(`"`if'"') firstobs(`firstobs')  obs(`obs') keep(`"`keep'"') ///
            `char2lab' char2fmt("`char2fmt'") `sasprogram' `describe' `listnot'
            

 * RUN SAS
 * -------
  if "`c(os)'"=="Unix" /* or Linux */ {
   shell "`usas'" "`temp'_usesas.sas" -log "`temp'_usesas.log" -print "`temp'_usesas.lst"
  } /* end of if Unix */
  else if "`c(os)'"=="Windows" /* Windows */ {
     ** do not add -icon option since that pop-up window is not a big deal and could tell user important info **
   shell `wsas' "`temp'_usesas.sas" -nologo -log "`temp'_usesas.log" -print "`temp'_usesas.lst"
  } /* end of if Windows */
 
* LOOK AT ANY REPORT FROM SAS
* ---------------------------
capture confirm file `"`temp'_report.log"'
if _rc==0 {
 type `"`temp'_report.log"'
 if "`messy'"=="" {
  erase `"`temp'_report.log"'
 }
}

* CLEAR DATA OUT OF MEMORY 
* ------------------------
 if "`clear'"!="" {
  drop _all
  label drop _all
 }


* LOAD STATA DATASET INTO MEMORY
* ------------------------------
 capture confirm file `"`tmpdir'_`sysjobid'_infile.do"'
 if _rc == 0 {
  if `"`usrlog'"' != "" {
   quietly log close 
  }
  local cwd "`c(pwd)'"
  ** cd to where infile.do is **
  quietly cd "`tmpdir'"
   run `"_`sysjobid'_infile.do"'
  if `"`usrlog'"' != "" {
   quietly log using `"`usrlog'"' , append
  }

  * SET DATASET NAME 
  * ----------------
  if index("$S_FN","`dirsep'") == 1 {
    global S_FN : subinstr global S_FN "`dirsep'" ""
  }
  global S_FN `"`macval(dir)'$S_FN"'

  // run savastata_report to see if SAS and Stata agree how many obs and vars there are
  savastata_report

  if "`check'" != "" {
    local gsfn : subinstr global S_FN ".dta" ""
    display as res _n " Compare these results with the results provided by SAS "
    display as res    " in the file `gsfn'_SAScheck.lst. " _n
    summarize 
    describe 
    list in 1/5

    di _n "You have requested to have savastata provide a check file:"
    di `""`gsfn'_SAScheck.lst" "'
  }


  ** cd back to where you were **
  quietly cd "`cwd'"   
 } /* if infile.do file exists */
 else {
  di `"{error}{help usesas:usesas} failed."'
  capture confirm file `"`tmpdir'_`sysjobid'_knerror.txt"'
  if _rc ==0 { 
    // savastata failed with a known error so just let report.log show the error 
    if "`c(os)'" != "Windows" {
      usesasdel `"`tmpdir'"' _`sysjobid'_
    }
    if "`c(os)'" == "Windows" {
      local usesasdeldir : subinstr local tmpdir `":"' `"\\\`= char(58)'"', all
      usesasdel `"`usesasdeldir'"' _`sysjobid'_
    }
  }
  else {
    di `"{error}If no error message above this one, then check out the SAS log file to see why. "'
    di `"  {view "`temp'_usesas.log"} "'
    di `"{inp}Erase these temporary files created by {help usesas:usesas} when done with them:"'
    di `"{res}(files located in "`tmpdir'") "'
    ls "`temp'_*"   
    if "`c(console)'" != "console" {
     if "`c(os)'" != "Windows" {
      di `"{res} {stata usesasdel `"`tmpdir'"' _`sysjobid'_:Click here to erase them all.} "'
     }
     if "`c(os)'" == "Windows" {
      local usesasdeldir : subinstr local tmpdir `":"' `"\\\`= char(58)'"', all
      di `"{res} {stata usesasdel `"`usesasdeldir'"' _`sysjobid'_:Click here to erase them all.} "'
     }
    }
  }

  if "`sasprogram'"!="" {
   di `""'
   if "`c(console)'" != "console" {
     di `"{inp}Click here to edit your SAS program and try it again. "'
     di `" {stata `"doedit "`xpt'""':`xpt'} "'
   }
   else di `"Edit your SAS program: "`xpt'" and try it again."'
   di `""'
  }
  capture which usagelog
  if _rc==0 {
   usagelog , type(savas) uerror(6) etime
  }
  exit 499
 }

if "`describe'" == "describe" {  
  di as res `"Contains data from "`using'" "'
  di as res `"   obs:  `=string(nobs,"%32.0fc")' "' memlabel
  di as res `"  vars:  `=string(_N,"%32.0fc")' "' 
  if ( _N > 2047 & "$S_StataSE"=="" & "$S_StataMP" == "" ) |  ///
     ( _N > 32767 )  {
    di as err "Your version of Stata will not read this entire dataset"
  if ( _N > 2047 & "$S_StataSE"=="" & "$S_StataMP" == "" )   ///
    di as err " as it has more than 2,047 variables."
  else if ( _N > 32767 )  ///
    di as err " as it has more than 32,767 variables."
  } // this message is repeated after all vars are listed  
  local name_len = `= substr("`: type name'",index("`: type name'","r")+1,2)'
  if `name_len' < 13 recast str13 name 
  recast str12 type
  char define name[varname] "variable name"
  char define type[varname] "storage type"
  char define label[varname] "variable label"
  order varnum name type format label
  if "`listnot'" == ""  {
    list name type format label, nocompress noobs subvarname
  }
  capture confirm file `"`macval(temp)'_usesas.txt"'
  if _rc ==0 { 
    file open sortedby using `"`temp'_usesas.txt"' , read text 
    file read sortedby sortedby // creates local sortedby
    file close sortedby
    // clear sortedby if no vars in it, it ends up being a double quote
    if `"`sortedby'"' == `"""'   local sortedby ""
  }
  di as res `"Sorted by: `sortedby'"'
  if "`listnot'" == ""  {
    if ( _N > 2047 & "$S_StataSE"=="" & "$S_StataMP" == "" ) |  ///
       ( _N > 32767 )  {
      di as err "Your version of Stata will not read this entire dataset"
    if ( _N > 2047 & "$S_StataSE"=="" & "$S_StataMP" == "" )   ///
      di as err " as it has more than 2,047 variables."
    else if ( _N > 32767 )  ///
      di as err " as it has more than 32,767 variables."
   } // this message is made first before all vars are listed
  }
  // these vars do not vary by obs so just drop 'em
  quietly drop memlabel // nobs dropped at end of usesas
  di as res _n _dup(`c(linesize)') "-"
  di as res `" Now the dataset in memory is just the description of "`using'" "'
  di as res `" Use the {stata describe :describe} command to see what you have and use "'
  di as res `" whatever data manipulation you like to create variable lists for "'
  di as res `" your actual invocation of {help usesas :usesas} if you want."'
  if "`c(console)'" != "console" {
    di as res `" Otherwise, {stata clear :Click here to clear out the dataset from memory}. "'
  }
  else {
    di as res `" Otherwise, use the clear command to clear out the dataset from memory. "'
  }
  di as res _dup(`c(linesize)') "-"
}


* CLEAN UP TEMP FILES
* -------------------
 if "`messy'"=="" {
   if "`c(os)'" != "Windows" {
    usesasdel `"`tmpdir'"' _`sysjobid'_
   }
   if "`c(os)'" == "Windows" {
    local usesasdeldir : subinstr local tmpdir `":"' `"\\\`= char(58)'"', all
    usesasdel `"`usesasdeldir'"' _`sysjobid'_
   }
 } /* end of messy=="" */
 else {
  di "{res}You have requested {help usesas:usesas} not to delete the intermediary files created by {help usesas:usesas}:"
  dir "`temp'_*"
  di "{input}Files located here: "
  di `"{input}"`tmpdir'" "'

  if "`c(console)'" != "console" {
   if "`c(os)'" != "Windows" { 
    di `"{res} {stata usesasdel `"`tmpdir'"' _`sysjobid'_:Click here to erase them all.} "'
   }
   if "`c(os)'" == "Windows" { 
    local usesasdeldir : subinstr local tmpdir `":"' `"\\\`= char(58)'"', all 
    di `"{res} {stata usesasdel `"`usesasdeldir'"' _`sysjobid'_:Click here to erase them all.} "'
   }
  }
 } // of if else if messy



/* log usage of usesas */
capture which usagelog
if _rc==0 {
  if `c(N)' == 0 & `c(k)' == 0 {
    usagelog , type(savas) uerror(7) message(no data) etime
  }
  else {
    local obs=`c(N)'
    local vars=`c(k)'
    usagelog , type(savas) uerror(0) message(Input Stata dataset has `obs' obs and `vars' vars) etime
  }
}
if "`describe'" == "describe" {
  local varlist = ""
  local vlen=0 
  forvalues n = 1/`= _N' {
    local vlen = `vlen' + length(trim("`= name[`n']'")) + 1 
    if `n' == 1  local varlist = trim("`= name[`n']'")
    else local varlist  `"`varlist' `= trim("`= name[`n']'")'"'
  }
  if `vlen' > `c(max_macrolen)' {
    di as err "not all the variables are in r(varlist) since there are too many "
  }
  return local varlist  "`varlist'"
  return local sortlist "`sortedby'"
  return scalar k = _N
  return scalar N = `= nobs[1]'
  drop nobs
}


end /* end of usesas */


program define usesas_sas, nclass
syntax  [, QUotes engine(string) rver(string) dirsep(string) dir(string) tmpdir(string) filen(string) ///
         shortfileext  xpt(string) replace raw(string) FORmats sysjobid(string) CHeck ext(string) middle(string)  ///
         savastata(string) if(string) firstobs(string) obs(string) keep(string) sasprogram ///
         char2lab char2fmt(string) float describe listnot ]
 version 8   


quietly {
	file open sasfile using `"`raw'.sas"', replace text write

	* DATA LIST
	* ---------

        file write sasfile `"* SAS program to read file and output Stata dataset *;"' ///
           _n _n `"options nofmterr nocenter linesize=250;"' ///
	   _n _n `"%let badx =0; ** if proc cimport has trouble with xport file **; "' _n  _n ///
	   _n _n `"%include "`savastata'";  "' _n  _n
          
        if "`char2lab'" != ""  {
	   file write sasfile   `"%include "`char2fmt'";  "' _n  _n
        }

       if "`sasprogram'"!="" {  /* user submitted a SAS program */
        file write sasfile `"options mprint source2;                     "' _n _n ///
            `" /*************** THE FOLLOWING IS YOUR PROGRAM ***************/ "' _n _n ///
            `"  %include"`xpt'";                                         "' _n _n ///
            `" /*************** END OF YOUR PROGRAM ***************/     "' _n _n ///
            `"options nomprint nosource2;                                "' _n _n 
        file write sasfile `" %let sortedby=; ** leave in for now **;    "' _n _n ///
            `"%macro makework;                                           "' _n ///
            `" %if &syserr.^=0 %then %goto nevrmind;                     "' _n ///
            `" %if &syslast.=_NULL_ %then %goto nevrmind;                "' _n ///
            `" %let ldset=%length(&syslast.);                            "' _n ///
            `" %let decpos=%index(&syslast.,.);                          "' _n ///
            `" %let llib=%substr(&syslast.,1,&decpos.-1);                "' _n ///
            `" %let dset=%substr(&syslast.,&decpos.+1,&ldset.-&decpos.); "' _n ///
            `" %let dset=%sysfunc(lowcase(%nrbquote(&dset.)));           "' _n _n
        file write sasfile  `" data _null_;                              "' _n ///
            `"  dsid=open("&syslast.",'i');"' _n  `"  sortedby=attrc(dsid,'SORTEDBY'); "' _n   ///
            `"  call symput('sortedby',trim(sortedby));"' _n `"  rc=close(dsid);"' _n `"run;"' _n _n 
        file write sasfile  `" %if %index(%upcase(&sortedby.),DESCENDING) %then %do;  "' _n ///
            `"    %* this is how Stata treats descending sortedby  *;      "' _n ///
            `"    %let sortedby= %substr(&sortedby.,1,%index(%upcase(&sortedby.),DESCENDING)-1); %end;"' _n _n 
        file write sasfile  `" ** if not in work make it be in work **;  "' _n ///
            `" %if %index(%upcase(&syslast.),WORK)^=1 %then %do;         "' _n ///
            `" data work.&dset.;                                          "' _n ///
            `"  set &syslast.;"' _n  `" run;                              "' _n ///
            `" proc datasets library=&llib.;"' _n `"  delete &dset.;"' _n `" run; quit;"' _n ///
            `"%end; ** end of if syslast is not in WORK **;              "' _n _n
        if "`keep'"!="" |  "`firstobs'"!="" | length(`"`if'"')>5 {
          /** apply subsetting to work dataset **/
         file write sasfile `" data work.&dset."' _n 
          if "`keep'"!="" {
           file write sasfile `" (keep=`keep' &sortedby.) "'
          }
          file write sasfile `";;;                                         "' _n ///
              `"  set &dset."'
          if "`firstobs'"!="" {
           file write sasfile `"(firstobs=`firstobs' obs=`obs')"' _n
          }
          file write sasfile `";;; "' _n
          if length(`"`if'"')>5 /* b/c "where" has 5 letters */ { 
           file write sasfile `" `if';  "' _n 
          } 
          file write sasfile `"run;                                        "' _n 
        } 
         file write sasfile `" %nevrmind: ;                              "' _n /*
         */ `"%mend;                                                     "' _n /*
         */ `"%makework;                                                 "'
       }
       else if "`sasprogram'"=="" {  /* write SAS program to feed SAS data set into savastata */
        if "`formats'"!="" {
         if "`engine'"=="v6" {
          file write sasfile `"libname library v6 "`dir'" ;  "'_n _n
         }
         else {
          file write sasfile `"libname library `engine' "`dir'" `shortfileext';  "'_n _n
         }
        }
        if "`engine'"=="`rver'" | "`engine'"=="v6"  {
         file write sasfile `"libname ___in___ `engine' "`dir'" `shortfileext' ;  "'_n _n 
          // preserve sort order
          // Transport datasets cannot be opened and they do not save sort info anyway
          file write sasfile `"%let sortedby=; "' _n _n `"data _null_;"' _n `" dsid=open('___in___.`filen'','i');"' _n  ///
            `" sortedby=attrc(dsid,'SORTEDBY'); "' _n  `" call symput('sortedby',trim(sortedby));"' _n `" rc=close(dsid);"' _n `"run;"' _n _n ///
        `" %macro __sort; %if %index(&sortedby.,DESCENDING) %then %sysfunc(tranwrd(&sortedby.,%str(DESCENDING ),-)); "' ///
        `" %mend __sort; %__sort; "'
        }  // end of normal SAS dataset
        else if "`engine'"=="xport" {    // test xport file to see if created by cimport  
          // Transport datasets cannot be opened and they do not save sort info anyway
         file write sasfile `"%let sortedby=; "' 
         file write sasfile `"filename ___in___ "`xpt'";  "' _n _n   ///
         `"%macro ___xt___ ;"' _n `" data _null_; "' _n `"  infile ___in___ ; "' _n `"  input  xt $ 1-6; "' _n ///
         `"  call symput('header',xt); "' _n `"  if _n_ = 1 then stop; "' _n `" run; "' _n  
         file write sasfile `" %if %index(&header.,HEAD) ^= 0 %then %do; "' _n _n   ///
        `"  libname ___in___ xport "`xpt'";  "' _n _n  
         file write sasfile `"  data _null_;"' _n   `"   set sashelp.vmember;  "' _n  ///
         `"   if upcase(libname)="___IN___" and upcase(memtype)="DATA" then call symput("filen",memname); "' _n  
         file write sasfile `"  run;"' _n _n `"  data `filen'; "' _n `"   set ___in___.&filen.;"' _n ///
         `"  run; "' _n `" %end; "' _n 
         file write sasfile `" %else %do;"' _n `"   proc cimport data=`filen' infile=___in___; "' _n ///
         `"   run; "' _n `" %if &syserr. ^=0 %then %do; "' _n ///
         `"   proc printto log="`tmpdir'_`sysjobid'_report.log"; options nonotes; "' _n ///
         `"   data _null_; "' _n ///
         `" put "ERROR: SAS could not open `filen' because it was created in a newer version of SAS *"; "' _n /// 
         `" put " or there is not just a data set named `filen' in the file.    *"; "' _n /// 
         `"  run; proc printto; ** end printing to *_report.log "' _n ///
         `" %let badx=1;  %end; "' _n `"%end; "' _n `"%mend ___xt___;"' _n _n `"%___xt___; ** now run macro ___xt___ ***; "' ///
         _n _n 

        }

        if "`engine'"!="spss" {
         if "`formats'"!="" {
          /* look for datasetname.formatscatalog file */ 
          local rc=1
          if ("`engine'"=="`rver'" | "`engine'"=="xport") & "`shortfileext'"=="" {
           capture confirm file `"`macval(dir)'`filen'.sas7bcat"'
           if _rc ==0 { 
            local rc=0
           }
          }
          else if ("`engine'"=="`rver'" | "`engine'"=="xport") & "`shortfileext'"!="" {
           capture confirm file `"`macval(dir)'`filen'.sc7"'
           if _rc ==0 { 
            local rc=0
           }
          }
          else if "`engine'"=="v6" & "`c(os)'"=="Unix" {
           capture confirm file `"`macval(dir)'`filen'.sct01"'
           if _rc ==0 { 
            local rc=0
           }
          }
          else if "`engine'"=="v6" & "`c(os)'"=="Windows" {
           capture confirm file `"`macval(dir)'`filen'.sc2"'
           if _rc ==0 { 
            local rc=0
           }
          }
          if `rc'==0 { 
           file write sasfile _n `"%macro __fmt__;"' ///
               `" %if %sysfunc(cexist(LIBRARY.`filen')) = 1 %then %do;"'   _n ///
               `"  options fmtsearch=(library.`filen' library.formats); "' _n _n /// 
               `"  proc datasets; "'                                       _n    ///
               `"   copy in=library out=work memtype=catalog; "'           _n    ///
               `"   select `filen';  "'                                    _n    ///
               `"   change `filen'=formats;"'                              _n    ///
               `"  run; quit;"'                                            _n    ///
               `" %end; "'                                                 _n    ///
               `" %else %do; "'                                            _n    ///
               `"   proc printto log="`tmpdir'_`sysjobid'_report.log"; options nonotes; "' _n ///
               `"   data _null_; "' _n ///
               `"   put "ERROR:  File LIBRARY.`filen'.CATALOG was created for a different operating system. *" ; "'   _n    ///
               `"   put "ERROR:  -usesas- did not create Stata value labels from SAS formats.  *"; "'  _n    ///
               `"   run; proc printto; ** end printing to *_report.log "'  _n    ///
               `" %end; "'                                                 _n    ///
               `"%mend __fmt__; "'                                         _n    ///
               `"%__fmt__; "'                                              _n    
            
          } /* if filen.catalog file exists */
         }  /* end of if "`formats'"!="" */

         file write sasfile  _n `"data `filen'"' 
         if "`keep'"!="" {
           file write sasfile `" (keep=`keep' &sortedby.) "'  
         }
         if "`engine'" == "xport" {  
       	  file write sasfile `";;;"' _n  `" set work.`filen' "' // 08Apr2005 use `filen' in work lib

         }
         else {
           file write sasfile `";;;"' _n  `" set ___in___.`filen' "' 
         }

         if "`firstobs'"!="" {
          file write sasfile `"(firstobs=`firstobs' obs=`obs')"' _n
         }
         file write sasfile `";;; "' _n
         if length(`"`if'"')>5 /* b/c "where" has 5 letters */ {
          file write sasfile `" `if';  "' _n // 
         }
	  file write sasfile `"run;  "' _n 
        }
        else {
         file write sasfile `"filename spss "`xpt'";  "' _n _n    /*
         */ `"proc convert spss=spss out=`filen'; "' _n           /*
         */ `"run; "'                                             
         file write sasfile _n `"data `filen'"' 
         if "`keep'"!="" {
           file write sasfile `" (keep=`keep') "'  
         }
	 file write sasfile `";;;"' _n  `" set `filen' "' 
         if "`firstobs'"!="" {
          file write sasfile `"(firstobs=`firstobs' obs=`obs')"' _n
         }
         file write sasfile `";;; "' _n
         if length(`"`if'"')>5 /* b/c "where" has 5 letters */ {
          file write sasfile `" `if';  "' _n // 
         }
	  file write sasfile `"run;  "' _n 
        }
       } /* end of if no sas program submitted */

         if `c(stata_version)' < 9 & "`char2lab'" != "" {
          noisily {
            di as error `"option char2lab is not allowed prior to Stata 9."'
            di as error `"option will be ignored."'
            local char2lab ""  
          }
         }
	 file write sasfile  _n _n ///
          `"%macro runit;"' _n `"  %if &badx.=0 %then %do;  "'
	 if "`describe'" == "describe" {
          file write sasfile  _n ///
            _n `" proc contents data=`filen' out=`filen'(keep=name varnum type label format "' ///
               `"        nobs length memlabel) noprint; run; "' 
          file write sasfile  _n ///
            _n `"  data `filen'(drop=type rename=(stype=type)); "' 
          // truncate long string vars just to make life simple
          if `c(stata_version)' < 9.2 & "$S_StataSE" == "" & "$S_StataMP" == ""  { 
           file write sasfile _n `"   length label memlabel $80;  "' 
          }
          else {
           file write sasfile _n `"   length label memlabel $244;  "' 
          }
          file write sasfile   ///
            _n `"   set `filen';  "' ///
            _n `"    if type = 1 then stype= "numeric";  "' ///
            _n `"    if type = 2 then stype= "string ";  "' ///
            _n `"    label stype= "Variable Type"; "' ///
            _n `"  run; "' 
          file write sasfile   ///
            _n `"  data _null_; "'   ///
            _n `"   file "`tmpdir'_`sysjobid'_usesas.txt"; "'   ///
            _n `"   put "%trim(&sortedby.)"; "'   ///
            _n `"  run;"'
          
          file write sasfile  _n ///
           _n  `"  proc sort data=`filen'; by varnum; run; "' 
          file write sasfile  _n ///
           _n  `" %let sortedby=varnum;  "'
           
         }  // end of if describe
           // need to put c(SE) and c(MP) in quotes since c(MP) doesn't exist in Stata 8
           // need to pass a zero or a one to savastata for SE or MP
	 file write sasfile `" libname ___dir__ "`dir'" ;                                     "' _n  ///
          `" %let _dir=%nrbquote(%sysfunc(pathname(___dir__)));                               "' _n  ///
          `" /* &sortedby. is global because of:  call symput creates it */                   "' _n  ///
          `" %let sortedby=; %* for now make sure sortedby is empty *;                        "'  _n ///
          `" %savastata("`tmpdir'",`quotes' `char2lab' `check' messy `float', &sortedby.,     "' ///
          `"  `sysjobid',nosave,"&_dir.`dirsep'",`= ("`c(SE)'" == "1") + ("`c(MP)'" == "1")', "' ///
          `"  version=`c(stata_version)');                                                    "' _n ///
          `"%end; %* if &badx.=0 *;  %mend runit;"' _n  `" %runit;"' _n _n
  
        file close sasfile
      
} /* end of quietly */
end

exit

