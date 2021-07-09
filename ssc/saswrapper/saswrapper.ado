*! saswrapper Version 1.3 dan_blanchette@unc.edu 04Mar2010
*! the carolina population center, unc-ch
*  - got rid of invalid error message when the usesas was not specified.
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
*  saswrapper Version 1.2 dan.blanchette@duke.edu  16Feb2010
*  saswrapper Version 1.1 dan.blanchette@duke.edu  08Jul2009
* -removed stray carriage return characters
*  saswrapper Version 1.1 dan.blanchette@duke.edu  04May2009
* -made it fail more gracefully when usesas option specified and sas code had an error in it 
*  saswrapper Version 1.0 dan.blanchette@duke.edu  26Feb2009

program define saswrapper, rclass
version 8
syntax [varlist] [using/ ] [if] [in]  [, PRE_sas_prog(string) POST_sas_prog(string)  MEssy savasas(string) ///
                          usesas NODATA clear QUotes CHeck float char2lab NOFORMATS rename ] 

/* log usage of saswrapper */
capture which usagelog
if _rc == 0 {
  usagelog , start type(savas) message(`"saswrapper using `using', `messy' `savasas' `usesas' `nodata' `clear' `quotes' `check' `float' `char2lab' `noformats' `rename' "') 
}


if "`c(os)'" == "Windows" & "`c(mode)'" == "batch" {
  di as err "{help saswrapper:saswrapper} cannot be run in batch mode on Windows"
  /* log usage of saswrapper */
  capture which usagelog
  if _rc == 0 {
    usagelog , type(savas) uerror(8) etime
  }
  exit  499
}
if `c(N)' == 0 & `"`savasas'"' != "" {
  di as err "no data in memory to save to SAS" _n
  capture which usagelog
  if _rc == 0 {
    usagelog , type(savas) uerror(8) etime
  }
  exit  499
}

if "`nodata'" != ""  & `"`savasas'"' != "" {
  di as err "cannot specify both nodata and savasas" _n
  capture which usagelog
  if _rc == 0 {
    usagelog , type(savas) uerror(8) etime
  }
  exit  499
}

if `c(N)' == 0 & "`nodata'" == "" {
  local nodata = "nodata"
}

if `"`usesas'"' != ""  & `c(N)' != 0 & "`clear'" == "" {
  di "{error} no, data in memory would be lost " 
  di "{error} use the {res}clear {error}option"
  /* log usage of saswrapper */
  capture which usagelog
  if _rc == 0 {
    usagelog , type(savas) uerror(1) etime
  }
  exit  4
}

local formats = "formats"
if "`noformats'" != ""  {
  local formats = ""
}


* CAPTURE USER'S LOG  
* ------------------
if int(`c(stata_version)') >= 9 quietly log query
local usrlog  `r(filename)' 

* FIGURE OUT WHERE THE SAS EXECUTABLE IS
* --------------------------------------
sasexe saswrapper

local wsas `r(wsas)'
local usas `r(usas)'
local savastata `r(savastata)'
local char2fmt `r(char2fmt)'
local rver `r(rver)'  // version of sas that's being run i.e. "v8", "v9" etc


local dirsep = "`c(dirsep)'"
if "`c(os)'" == "Windows" {
  local dirsep = "\"
}

local dir = "`c(pwd)'`dirsep'" 
if `"`using'"' != "" {
  // see if there is even one double quote in using
  local subtest : subinstr local using `"""' `""' , count(local cnt)
  if `cnt' != 0 {
    di `"{help saswrapper:saswrapper} {error}cannot handle directory or file names that contain double quotes. "'
    capture which usagelog
    if _rc == 0 {
      usagelog , type(savas) uerror(2) etime
    }
    exit 499
  }

  /* if filename is given with directory info too, 
   *  strip to just file name and to dir location */
  if "`c(os)'" == "Windows" {
    if index("`using'","/") {
      local using : subinstr local using "/" "\" , all
    }
  }
  if index("`using'","`dirsep'") { 
    local filen=substr("`using'",index("`using'","`dirsep'")+1,length("`using'"))
    while index("`filen'","`dirsep'") !=0 {
      local filen = substr("`filen'",index("`filen'","`dirsep'")+1,length("`filen'"))
    }
    local dir = substr("`using'",1,index("`using'","`filen'")-1)
  }
  else if index("`using'","\\\") == 1 {   /* Universal naming convention */
    local filen = substr("`using'",index("`using'","\\\")+2,length("`using'"))
    while index("`filen'","\") !=0 {
      local filen = substr("`filen'",index("`filen'","\")+1,length("`filen'"))
    }
    local dir = substr("`using'",1,index("`using'","`filen'")-1)
  }
  else {  /* no directory given */
    local filen = "`using'"
    local dir = "`c(pwd)'`dirsep'" 
  }


  /** extract file extension if there is one **/
  if index("`filen'",".") {
    local ext=substr("`filen'",index("`filen'","."),length("`filen'"))
    while index("`ext'",".") > 0 {
      local ext = substr("`ext'",index("`ext'",".")+1,length("`ext'"))
    }
    local ext = ".`ext'"
    local filen = substr("`filen'",1,index("`filen'",".")-1)
  }
 
  if lower("`ext'") == "" { // guess that the user is wanting to use a .sas file
    local using1 `"`using'.sas"'
    local ext ".sas"
    capture confirm file `"`using1'"'
    if _rc == 0 {
      capture confirm file `"`using'"'
      if _rc == 0 {
        di `"{error}The SAS file: "`using'" does exist, but so does the SAS file: "`using1'" '"'
        di as text `"SAS will choose to run "`using1'" since it has the file extension ".sas" "'
        /* log usage of saswrapper */
        capture which usagelog
        if _rc == 0 {
          usagelog , type(savas) uerror(3) etime
        }
        exit 601
      }
    }
    // only here if this file does exist
    local using `"`using'.sas"'
  }
  else if lower("`ext'") != ".sas" {
    di as error `" "`ext'" is an invalid file extension  "'
    di as error `"{help saswrapper:saswrapper} can only run SAS program files which have the file extension ".sas" "'
    /* log usage of saswrapper */
    capture which usagelog
    if _rc == 0 {
      usagelog , type(savas) uerror(3) etime
    }
    exit 601
  }
 
 
  capture confirm file `"`using'"'
  if _rc != 0 {
    di `"{error}The SAS file: `using' does not exist."'
    /* log usage of saswrapper */
    capture which usagelog
    if _rc == 0 {
      usagelog , type(savas) uerror(3) etime
    }
    exit 601
  }
} // end of if "using" != ""

local usasprog "`using'"

if "`usasprog'" == "" & `"`pre_sas_prog'"' == "" & `"`post_sas_prog'"' == "" {
  di as err `"no SAS code to run "' _n
  /* log usage of saswrapper */
  capture which usagelog
  if _rc == 0 {
    usagelog , type(savas) uerror(3) etime
  }
  exit 601
}

/* set where temp directory is */
tmpdir
local tmpdir `"`r(tmpdir)'"'

local tfn = subinstr("`c(current_time)'",":","",.)
local sysjobid = substr("`tfn'",length("`tfn'")-5,length("`tfn'"))
local temp `"`macval(tmpdir)'_`sysjobid'"'


if "`nodata'" == "" {
  if `"`savasas'"' == "" {
    local stata_data  `"`c(filename)'"'
    if `: length local stata_data' != 0 {
      capture _getfilename `"`stata_data'"'  // get error message if only dir in using
      local stata_data `"`r(filename)'"'  // make using just the filename
      local stata_data : subinstr local stata_data ".dta" ""  // drop file extension
      valid_dset_name, dset(`stata_data') `rename'
      local stata_data = "`r(valid_dset_name)'"
    }
    else if `: length local stata_data' == 0 {
      local stata_data = "stata_data"
    }
  }
  else if `"`savasas'"' != "" {
    valid_dset_name, dset(`savasas') `rename'
    local stata_data = "`r(valid_dset_name)'"
  }

  if "`stata_data'" == ""   local stata_data = "stata_data"

  if "`check'" != "" {
    di as result _n `"Compare results with SAS output that will be printed next "' 
    // no reason to set more off because if user quits no temp files have been written yet
    local five_n = 5
    if _N < 5 {
      local five_n = _N
    }
    summarize `varlist' `if' `in'
    describe `varlist'
    list `varlist' in 1/`five_n'
  }
  
  di as result _n "now running {help savasas:savasas} to save the dataset `stata_data' to the SAS WORK library "
  savasas `varlist' using "`temp'_statadata.sas7bdat" `if' `in' , `formats' `rename' `messy' ///
                                saswrapper saswrap_data(`stata_data') sysjobid(`sysjobid')  
}


* WRITE SASWPAPPER SAS PROGRAM
* ----------------------------
saswrapper_sas , dirsep("`dirsep'") dir("`dir'") tmpdir("`tmpdir'") temp("`temp'") filen(`filen') sysjobid(`sysjobid') ///
                 usasprog("`usasprog'") pre_sas_prog(`" `pre_sas_prog' "') post_sas_prog(`" `post_sas_prog' "')        ///
                 rver(`rver') savastata("`savastata'") `quotes' `check' `float' `char2lab' char2fmt("`char2fmt'")      /// 
                 stata_data(`stata_data') `usesas' `nodata'
              

* RUN SAS
* -------
if "`c(os)'" == "Unix" /* or Linux */ {
  shell "`usas'" "`temp'_saswrapper.sas" -log "`temp'_saswrapper.log" -print "`temp'_saswrapper.lst"
} /* end of if Unix */
else if "`c(os)'" == "Windows" /* Windows */ {
  shell `wsas' "`temp'_saswrapper.sas" -nologo -log "`temp'_saswrapper.log" -print "`temp'_saswrapper.lst"
} /* end of if Windows */

capture confirm file `"`temp'_sascoderr.sas7bdat"'
if _rc == 0 {
  tempfile saswrapper_output
  copy `"`temp'_saswrapper.txt"' `"`saswrapper_output'"', text
 
  capture confirm file `"`saswrapper_output'"'
  if _rc == 0 {
    di as error _n "the submitted SAS code has an error in it " _n
  }
  // set usesas to missing so that saswrapper will fail gracefully
  local usesas 
}
 
* LOOK AT ANY REPORT FROM SAS  
* ---------------------------
capture confirm file `"`temp'_report.log"'
if _rc == 0 {
  type `"`temp'_report.log"'
  if "`messy'" == "" {
    erase `"`temp'_report.log"'
  }
}


if "`usesas'" != "" {
  * CLEAR DATA OUT OF MEMORY 
  * ------------------------
  if "`clear'" != "" {
    drop _all
    label drop _all
  }

  * LOAD STATA DATASET INTO MEMORY  
  * ------------------------------
  capture confirm file `"`temp'_infile.do"'
  if _rc == 0 {
    di as result _n "now loading the most recently created SAS dataset in submitted SAS program "
    di as result " savastata SAS macro saved this dataset to Stata " _n
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
    di " " _n  // insert a blank space
  
    ** cd back to where you were **
    quietly cd "`cwd'"   
  } /* if infile.do file exists */
  else {
    di `"{error}{help saswrapper:saswrapper} failed."'
    capture confirm file `"`temp'_knerror.txt"'
    if _rc == 0 { 
      // savastata failed with a known error so just let report.log show the error 
      if "`c(os)'" != "Windows" {
        usesasdel `"`tmpdir'"' _`sysjobid'
      }
      if "`c(os)'" == "Windows" {
        local usesasdeldir : subinstr local tmpdir `":"' `"\\\`= char(58)'"', all
        usesasdel `"`usesasdeldir'"' _`sysjobid'
      }
    }
    else {
      di `"{error}If no error message above this one, then check out the SAS log file to see why. "'
      di `"  {view "`temp'_saswrapper.log"} "'
      di `"  and {view "`temp'_saswrapper.txt"} "'
      di `"{inp}Erase these temporary files created by {help saswrapper:saswrapper} when done with them:"'
      di `"{res}(files located in "`tmpdir'") "'
      ls "`temp'_*"   
      if "`c(console)'" != "console" {
        if "`c(os)'" != "Windows" {
          di `"{res} {stata usesasdel `"`tmpdir'"' _`sysjobid':Click here to erase them all.} "'
        }
        if "`c(os)'" == "Windows" {
          local usesasdeldir : subinstr local tmpdir `":"' `"\\\`= char(58)'"', all
          di `"{res} {stata usesasdel `"`usesasdeldir'"' _`sysjobid':Click here to erase them all.} "'
        }
      }
    }
  
    if "`usasprog'" != "" {
      di `""'
      if "`c(console)'" != "console" {
        di `"{inp}Click here to edit your SAS program and try it again. "'
        di `" {stata `"doedit "`usasprog'""':`usasprog'} "'
      }
      else di `"Edit your SAS program: "`usasprog'" and try it again."' _n
    }
    capture which usagelog
    if _rc == 0 {
      usagelog , type(savas) uerror(6) etime
    }
    exit 499
  }
} //end of if usesas


capture confirm file `"`temp'_saswrapper.txt"' 
if _rc == 0 {
  tempfile saswrapper_output
  copy `"`temp'_saswrapper.txt"' `"`saswrapper_output'"', text
}


* CLEAN UP TEMP FILES
* -------------------
if "`messy'"=="" {
  if "`c(os)'" != "Windows" {
    usesasdel `"`tmpdir'"' _`sysjobid'
  }
  if "`c(os)'" == "Windows" {
    local usesasdeldir : subinstr local tmpdir `":"' `"\\\`= char(58)'"', all
    usesasdel `"`usesasdeldir'"' _`sysjobid'
  }
} /* end of messy */
else {
  di "{res}You have requested {help saswrapper:saswrapper} not to delete the intermediary files" ///
      " created by {help saswrapper:saswrapper}:"
  dir "`temp'_*"
  di "{input}Files located here: "
  di `"{input}"`tmpdir'" "'

  if "`c(console)'" != "console" {
    if "`c(os)'" != "Windows" { 
      di `"{res} {stata usesasdel `"`tmpdir'"' _`sysjobid':Click here to erase them all.} "'
    }
    if "`c(os)'" == "Windows" { 
      local usesasdeldir : subinstr local tmpdir `":"' `"\\\`= char(58)'"', all 
      di `"{res} {stata usesasdel `"`usesasdeldir'"' _`sysjobid':Click here to erase them all.} "'
    }
  }
} // of if else if messy


// this is 2nd to last since user may break -more- which cancels saswrapper 
capture confirm file `"`saswrapper_output'"'
if _rc == 0 {
  di as result "the following is the results of the SAS program: " _n
  type `"`saswrapper_output'"'
}

// this is last since user may break -more- which cancels saswrapper 
if "`usesas'" != "" {  
  if "`check'" != "" {
    local gsfn : subinstr global S_FN ".dta" ""
    display as res _n " Compare these results with the results provided by SAS "
    display as res    " in the file `gsfn'_SAScheck.lst. " _n
    local five_n = 5
    if _N < 5 {
      local five_n = _N
    }
    summarize 
    describe 
    list in 1/`five_n'

    di _n "You have requested to have savastata provide a check file:"
    di `""`gsfn'_SAScheck.lst" "' _n 
  }
}

end /* end of saswrapper */


program define saswrapper_sas, nclass
syntax  [, dirsep(string) dir(string) tmpdir(string) temp(string) filen(string) sysjobid(string)  ///
           usasprog(string) pre_sas_prog(string) post_sas_prog(string)                            /// 
           rver(string) savastata(string) quotes check float char2lab char2fmt(string)            ///
           stata_data(string) usesas NODATA]
version 8   


quietly {
       file open sasfile using `"`temp'_saswrapper.sas"', replace text write

       file write sasfile `"* saswrapper SAS program *;                    "' _n _n ///
          `" options nonotes nofmterr nocenter linesize=`c(linesize)' source2;"' _n _n ///
            `"   ** need to create this file now as may only be able to *"' _n ///
            `"    *  erase it later. **;                                 "' _n ///
            `" libname _saswrap "`tmpdir'";                              "' 

       file write sasfile `"* sas error test *;                          "' _n _n ///
            `"   data _saswrap._`sysjobid'_sascoderr;                    "' _n ///
            `"    do i = 1 to 1;                                         "' _n ///
            `"      message="submitted SAS code has an error";           "' _n ///
            `"    end;                                                   "' _n ///
            `"   run;                                                    "' _n ///
            `"   %let syslast=;                                          "' _n


       if "`stata_data'" != "" { // put data (and formats catalog file) into WORK library
         capture confirm file `"`temp'_statadata.sas7bdat"'
         if _rc == 0 {
           file write sasfile `" proc datasets library= _saswrap; "'   _n ///
              `"   copy in= _saswrap out= work move;              "'   _n ///
              `"   select _`sysjobid'_statadata (memtype= data);  "'   _n ///
              `" run;                                             "'   _n _n 
           file write sasfile `" proc datasets library= work; "'                      _n ///
              `"   change _`sysjobid'_statadata = `stata_data' / memtype= data;   "'  _n ///
              `" run;                                                             "'  _n ///
              `" quit;                                                            "'  _n _n ///
              `" %let syslast=work.`stata_data';                                  "'  _n _n 
         }
         capture confirm file `"`temp'_statadata.sas7bcat"'
         if _rc == 0 {
           file write sasfile `" proc datasets library= _saswrap;   "' _n ///
              `"   copy in= _saswrap out= work move;                "' _n ///
              `"   select _`sysjobid'_statadata (memtype= catalog); "' _n ///
              `" run;                                               "' _n _n 

           file write sasfile `" proc datasets library= work;                      "' _n ///
              `"   change _`sysjobid'_statadata = formats / memtype= catalog;      "' _n ///
              `" run;                                                              "' _n ///
              `" quit;                                                             "' _n _n 
         }
       }

       file write sasfile `" proc printto print="`temp'_saswrapper.txt" log="`temp'_saswrapper.txt"; "' _n ///
          `" run;                                                                                    "' _n _n ///
          `" options notes;                                                                          "' _n _n

       if "`check'" != "" & "`nodata'" == "" {
         file write sasfile `"                                                           "' _n ///
            `" /****** THE FOLLOWING IS THE DATA CHECK YOU REQUESTED ******/             "' _n  

         file write sasfile  `"                                                          "' _n ///
            `" proc means    data=work.`stata_data';                                     "' _n ///
            `" run;                                                                      "' _n _n ///
            `" proc contents data=work.`stata_data';                                     "' _n ///
            `" run;                                                                      "' _n _n ///
            `" proc print    data=work.`stata_data' (obs=5);                             "' _n /// 
            `" run;                                                                      "' _n 

         file write sasfile `"                                                           "' _n ///
            `" /************ END OF THE DATA CHECK YOU REQUESTED **********/             "' _n  
       }

       if `"`pre_sas_prog'"' != "  " {   // two spaces because pre_sas_prog(`" `pre_sas_prog' "')
         file write sasfile `"                                                           "' _n _n ///
            `" /********* THE FOLLOWING IS YOUR pre_sas_prog CODE *********/             "' _n _n 

         local len_pre_sas_prog : length local pre_sas_prog
         if `len_pre_sas_prog' < 256 { // 256 is the max but there is a space at beginning and end 
           file write sasfile `" `pre_sas_prog' "' _n _n 
         } 
         else {
           tokenize `" `pre_sas_prog' "', parse(";")
           local orig_length : length local pre_sas_prog
           local nosemis : subinstr local pre_sas_prog ";" "", all
           local s_length : length local nosemis
           // tokenize puts the semicolons in the even numbered macro vars
           local n_semis = (`orig_length' - `s_length' ) * 2
  
           local odd = 1
           forval line = 1/`n_semis' {
             if `odd' == 3 {
               local odd = 1
             }
             if `odd' == 1  { // tokenize puts the semicolons in the even numbered macro vars
               file write sasfile `" ``line''; "' _n _n 
             }
             local odd = `odd' + 1
           }
         }
         //     the following semi-colon is there in case user forgot to end their code with one. 
         file write sasfile `" ;                                                         "' _n _n ///
            `" /************** END OF YOUR pre_sas_prog CODE **************/             "' _n _n 
       }

       if "`usasprog'" != "" {  /* user submitted a SAS program */
         file write sasfile `"                                                     "' _n _n ///
            `" /********* THE FOLLOWING IS YOUR SAS PROGRAM *********/             "' _n _n ///
            `"  %include"`usasprog'";                                              "' _n _n ///
            `" /************** END OF YOUR SAS PROGRAM **************/             "' _n _n 
       }

       if `"`post_sas_prog'"' != "  " { // two spaces because pre_sas_prog(`" `post_sas_prog' "')
         file write sasfile `"                                                            "' _n _n ///
            `" /********* THE FOLLOWING IS YOUR post_sas_prog CODE *********/             "' _n _n 
         local len_post_sas_prog : length local post_sas_prog
         if `len_post_sas_prog' < 256 {  // 256 is the max but there is a space at beginning and end
           file write sasfile `" `post_sas_prog' "' _n _n 
         } 
         else {
           tokenize `" `post_sas_prog' "', parse(";")
           local orig_length : length local post_sas_prog
           local nosemis : subinstr local post_sas_prog ";" "", all
           local s_length : length local nosemis
           // tokenize puts the semicolons in the even numbered macro vars
           local n_semis = (`orig_length' - `s_length' ) * 2
           local odd = 1
           forval line = 1/`n_semis' {
             if `odd' == 3 {
               local odd = 1
             }
             if `odd' == 1 { // tokenize puts the semicolons in the even numbered macro vars
               file write sasfile `" ``line''; "' _n _n
             }
             local odd = `odd' + 1
           }
         }
         file write sasfile `"                                                            "' _n _n ///
            `" /************** END OF YOUR post_sas_prog CODE **************/             "' _n _n 
       }

       //     the following semi-colon is there in case user forgot to end their code with one. 
       file write sasfile `" ; proc printto;                            "' _n  ///
          `" run;                                                       "' _n  ///
          `" quit;  ** close up anything they might have left going **; "' _n _n 

       if missing(`"`usesas'"') {
          file write sasfile  `" %let syslast1=&syslast.;                  "' _n _n ///
            `" proc datasets library= _saswrap;                            "' _n ///
            `"   copy in= _saswrap out= work move;                         "' _n ///
            `"   select _`sysjobid'_sascoderr (memtype= data);             "' _n ///
            `" run;                                                        "' _n _n ///
            `" quit;                                                       "' _n _n ///
            `" %let syslast=&syslast1.;                                    "' _n _n
       }
       else if !missing(`"`usesas'"') {
         file write sasfile `" %let sortedby=; ** leave in for now **;   "' _n _n ///
            `"%macro makework; ** make last dataset a work dataset **;   "' _n ///
            `"   run;          ** so that savastata works **;            "' _n ///
            `" %let nobs=%sysfunc(getoption(obs));                           "' _n ///
            `" %if &syserr.^=0 or &nobs.=0 or "&syslast."="_NULL_" %then %do;"' _n ///
            `"   %goto nevrmind;                                             "' _n ///
            `" %end;                                                         "' _n ///
            `" %let syslast1=&syslast.;                                      "' _n _n
         file write sasfile `" proc datasets library= _saswrap;            "' _n ///
            `"   copy in= _saswrap out= work move;                         "' _n ///
            `"   select _`sysjobid'_sascoderr (memtype= data);             "' _n ///
            `" run;                                                        "' _n _n ///
            `" quit;                                                       "' _n _n ///
            `" %let syslast=&syslast1.;                                    "' _n _n

         file write sasfile `"%if "&syslast." ^= "_NULL_" %then %do;       "' _n ///
            `"   %let ldset=%length(&syslast.);                            "' _n ///
            `"   %let decpos=%index(&syslast.,.);                          "' _n ///
            `"   %let llib=%substr(&syslast.,1,&decpos.-1);                "' _n ///
            `"   %let dset=%substr(&syslast.,&decpos.+1,&ldset.-&decpos.); "' _n ///
            `"   %let dset=%sysfunc(lowcase(%nrbquote(&dset.)));           "' _n _n
         file write sasfile  `"   data _null_;                             "' _n ///
            `"    dsid=open("&syslast.",'i');"' _n  `"    sortedby=attrc(dsid,'SORTEDBY'); "' _n   ///
            `"    call symput('sortedby',trim(sortedby));"' _n `"    rc=close(dsid);"' _n `"   run;"' _n _n 
         file write sasfile  `"   %if %index(%upcase(&sortedby.),DESCENDING) %then %do;  "' _n ///
            `"      %* this is how Stata treats descending sortedby  *;    "' _n ///
            `"      %let sortedby= %substr(&sortedby.,1,%index(%upcase(&sortedby.),DESCENDING)-1); "' _n ///
            `"   %end;"' _n _n 
         file write sasfile  `"   ** if not in work make it be in work **; "' _n ///
            `"   %if %index(%upcase(&syslast.),WORK)^=1 %then %do;         "' _n ///
            `"     data work.&dset.;                                       "' _n ///
            `"      set &syslast.;"' _n  `"     run;                       "' _n ///
            `"   %end; ** end of if syslast is not in WORK **;             "' _n _n ///
            `" %end; ** end of if syslast is _NULL_ **;                    "' _n _n


         file write sasfile `" %nevrmind: ;                             "' _n ///
           `"%mend makework;                                            "' _n ///
           `"%makework;                                                 "'
 
         if `c(stata_version)' < 9 & "`char2lab'" != "" {
           noisily {
             di as error `"option char2lab is not allowed prior to Stata 9."'
             di as error `"option will be ignored."'
             local char2lab ""  
           }
         }
         file write sasfile  _n _n ///
           `"%macro runit;                                                     "' _n _n ///
            `" %let nobs=%sysfunc(getoption(obs));                             "' _n ///
            `" %if &syserr.^=0 or &nobs.=0 or "&syslast." = "_NULL_" %then %do;"' _n ///
            `" proc printto log="`temp'_saswrapper.txt";                       "' _n ///
            `"      run;                                                       "' _n ///
            `"      %put %upcase(error:) no dataset in SAS to load into Stata; "' _n ///
            `"   %goto nevrmind;                                               "' _n ///
            `" %end;                                                           "' _n
            // need to put c(SE) and c(MP) in quotes since c(MP) doesn't exist in Stata 8
            // need to pass a zero or a one to savastata for SE or MP
         file write sasfile `" options nomprint nosource2;  "' _n _n  
         file write sasfile `" %include "`savastata'"; "' _n   ///            
            `" libname ___dir__ "`dir'" ; %* directory where _SAScheck.lst is saved to *;       "' _n  ///
            `" %let _dir=%nrbquote(%sysfunc(pathname(___dir__)));                               "' _n  ///
            `" /* &sortedby. is global because of:  call symput creates it */                   "' _n  ///
            `" %savastata("`tmpdir'",`quotes' `char2lab' `check' messy `float',&sortedby.,      "'     ///
            `"  `sysjobid',nosave,"&_dir.`dirsep'",`= ("`c(SE)'" == "1") + ("`c(MP)'" == "1")', "'     ///
            `"  version=`c(stata_version)');                                                    "' _n  ///
            `" %nevrmind: ;                                                                     "' _n  ///
           `"%mend runit;"' _n  `"%runit;"' _n
       } // end of if usesas
  
       file close sasfile
      
} /* end of quietly */
end


program valid_dset_name, rclass
syntax , dset(string) [rename]
 version 8   

local filen `dset'
    
local fc = substr("`filen'",1,1)

local swn = "0"
local hsc = "0"
if inlist("`fc'","0","1","2","3","4") | ///
   inlist("`fc'","5","6","7","8","9")  { // name starts with a number
  local swn = "1"
}

if  index("`filen'","~") | /// Has a bad character in name
    index("`filen'","!") | ///
    index("`filen'","@") | ///
    index("`filen'","#") | ///
    index("`filen'","$") | ///
    index("`filen'","%") | ///
    index("`filen'","^") | ///
    index("`filen'","&") | ///
    index("`filen'","*") | ///
    index("`filen'","(") | ///
    index("`filen'",")") | ///
    index("`filen'","-") | ///
    index("`filen'","+") | ///
    index("`filen'","=") | ///
    index("`filen'","[") | ///
    index("`filen'","]") | ///
    index("`filen'",":") | ///
    index("`filen'",";") | ///
    index("`filen'","'") | ///
    index("`filen'","<") | ///
    index("`filen'",">") | ///
    index("`filen'","?") | ///
    index("`filen'",",") | ///
    index("`filen'","|") | ///
    index("`filen'"," ") | ///
    index("`filen'","{") | ///
    index("`filen'","}") {
  local hsc = "1"
}

if "`swn'" == "1" | "`hsc'" == "1" {
  if "`rename'"=="" {
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
    foreach char in ~ ! @ # $ % ^ & * ( ) - + = [ ] : ; ' < > ? , | {
      local filen = subinstr("`filen'","`char'","_",.)
    }
    local filen = subinstr("`filen'","{","_",.)
    local filen = subinstr("`filen'","}","_",.)
    local filen = subinstr("`filen'"," ","_",.)

    if `"`: subinstr local filen "_" "" , all'"' == "" {  // if nothing left, meaning, person used all bad characters 
      local filen= "okpopeye"
    }
  } // end of contains bad character
  
  if "`swn'" == "1" { // name starts with a number
    if length("`filen'") == 32  {
      local filen = substr("`filen'",2,length("`filen'"))
      local filen = "_`filen'"
    }
    else {
      local filen ="_`filen'"
    }
  } // end of if started with number 
  if "`rename'" == "" {
    di `"{error}The {res}rename {error}option will rename it for you to be: {res}"`filen'" "'
    /* log usage of saswrapper */
    capture which usagelog
    if _rc==0 {
     usagelog , type(savas) uerror(6) etime
    }
    exit 198
  }
} /* if filen is not a valid SAS data file name */

return local valid_dset_name `filen'

end
