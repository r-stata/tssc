*! version 1.0.0 August 7, 2014 @ 16:43:32
*! turns a smcl log file into a do-file
program define smcl2do
version 11.2
   syntax using/ [, saving(str) replace all clean ]
   parsefilename using `"`using'"', defext(smcl)
   local usingbase `"`s(sbase)'"'
   local usingext `"`s(sext)'"'
   if `"`saving'"'!="" {
      parsefilename using `"`saving'"', defext(do)
      local savingbase `"`s(sbase)'"'
      local savingext `"`s(sext)'"'
      }
   else {
      local savingbase `"`usingbase'"'
      local savingext ".do"
      }
   local using `"`usingbase'`usingext'"'
   confirm file `"`using'"'
   local saving `"`savingbase'`savingext'"'
   if "`replace'"=="" {
      confirm new file `"`saving'"'
      }
   else {
      capture confirm file `"`saving'"'
      local newreplace = _rc
      }

   tempfile splitFile

   tempname lastreturns
   _return hold `lastreturns'

   capture noisily {
      if "`all'"!="" {
         // if all commands are wanted, just need one pass
         quietly splitlog using `"`using'"', saving(`"`splitFile'"')  ///
           strip(3) cmdonly nonumber
         quietly translate `"`splitFile'"' `"`saving'"', `replace' translator(smcl2log) linesize(255)
         if "`replace'"!= "" {
            if `newreplace' {
               display as text `"(note: file `saving' not found)"'
               }
            }
         }
      else {
         // otherwise need two passes and mata
         quietly splitlog using `"`using'"', saving(`"`splitFile'"')  ///
           strip(3) cmdonly
         local errcmd "`r(errcmd)'"
         local lastcmd "`r(lastcmd)'"
         tempfile interimDo finalDo
         quietly translate `"`splitFile'"' `"`interimDo'"',  translator(smcl2log) linesize(255)
         
         mata: smcl2do_process_file("`interimDo'","`finalDo'","`errcmd'","`clean'")
         copy `finalDo' `"`saving'"', `replace'
         }
      display as text `"file `saving' saved"'
      }
   _return restore `lastreturns'
   if _rc {
      if _rc==610 {
         exit 610
         }
      else {
         error _rc
         }
      }
end

// needed for processing -log- commands
program define LogStack, rclass
   syntax [anything(name=logany id="log subcommand")] [using] [, append replace text smcl name(string) ]
   local closing 0
   if `"`using'"'!="" {
      if "`name'"!="" {
         return local logname="`name'"
         }
      else {
         return local logname="<unnamed>"
         }
      }
   else { // not using a new file
      gettoken subcmd logany : logany, parse(" ,")
      if `"`subcmd'"'=="close" {
         if `"`logany'"'=="" {
            return local logname="<unnamed>"
            }
         else {
            return local logname=`"`logany'"' // careful: spaces not stripped
            }   
         local closing 1
         }
      }
   return local closing = `closing'
end

version 11.2
mata:
   void smcl2do_process_file(string scalar infile, string scalar outfile, string scalar errcmd, string scalar clean) {
      // file handles
      real scalar inh, outh
      // bookkeeping vars
      real scalar cmdnum, writing, firstline, skipper, nextErr
      // lines from the file
      string scalar curline, firstword
      // tokenizing objects
      transmorphic errList, split_spc_comma
      // tracking logs opened and closed
      string vector lognames
      string scalar logname
      string scalar closing
      
      cmdnum=1
      writing=0
      firstline=0
      lognames=("")
      errList=tokeninit()
      tokenset(errList, errcmd)
      split_spc_comma=tokeninit(" ",(",:"))
      
      nextErr=strtoreal(tokenget(errList))
      
      inh=fopen(infile,"r")
      outh=fopen(outfile,"w")
      
      while( (curline=fget(inh))!=J(0,0,"") ) {
         if (!writing) {
            if (curline=="/*** Begin command number: " + strofreal(cmdnum) + " ***/") {
               if (cmdnum != nextErr) {
                  writing=1
                  firstline=1
                  }
               else {
                  nextErr=strtoreal(tokenget(errList))
                  cmdnum++
                  }
               }
            } // end of not writing
         else {
            skipper = (curline == "/*** End command number: " + strofreal(cmdnum) + " ***/")
            if (clean!="") {
               if (firstline & !skipper) {
                  tokenset(split_spc_comma,curline)
                  firstword = tokenget(split_spc_comma)
                  // check to see if firstword is -quietly- or -noisily-;
                  //   -capture- is enough to leave the command in
                  if (any(strmatch(firstword,("qui","quie","quiet","quietl","quietly","n","no","noi","nois","noisi","noisil","noisily")))) {
                     firstword = tokenget(split_spc_comma)
                     if (firstword==":") {
                        firstword = tokenget(split_spc_comma)
                        }
                     }
                  skipper = any(strmatch(firstword,("h","he","hel","help","search","ed","edi","edit","findit","br","bro","brow","brows","browse","doed","doedi","doedit","projman","projmana","projmanag","projmanage","projmanager","varm","varma","varman","varmana","varmanag","varmanage","view","viewsource","db")))
                  if (!skipper) {
                     if (firstword == "log") {
                        // printf("stripperlog " + tokenrest(split_spc_comma) + "\n")
                        stata("LogStack " + tokenrest(split_spc_comma))
                        closing=strtoreal(st_global("r(closing)"))
                        // OK because stata names cannot have leading space
                        logname=strtrim(st_global("r(logname)"))
                        // printf("*** here is logname: ->" + logname + "<-\n")
                        if (closing) {
                           if (logname=="_all") {
                              if (lognames=="") {
                                 skipper=1
                                 }
                              else {
                                 lognames=("")
                                 }
                              }
                           else if (any(strmatch(logname,lognames))) {
                              lognames=lognames[lognames!=logname]
                              }
                           else {
                              skipper=1
                              }
                           } // end closing
                        else { // opening a log
                           lognames=lognames,logname
                           }
                        } // end checking for logfiles
                     } // end extra skipper test
                  }
               } // end clean test
            if (skipper) {
               writing=0
               cmdnum++
               }
            else {
               fput(outh,curline)
               firstline=0
               }
            }
         } // end of looping through file
      fclose(inh)
      fclose(outh)
      }
end

exit

Limitations:

Using -mata:- (note the colon) will cause problems if there is a
  mata error, because there will be no -end- statement. Workaround:
  use -mata:- only for one-liners  

Using a {com} directive cleverly can fool this...but {com} directives are
  supposed to be for Stata output routines only; users should always
  use {cmd}.

Using -do- within loops is bad; use -quietly do- instead.

!! When used on a logfile from an interactive session, the trailing
   -log close- gets left in the do-file unless the -clean- option is
   specified. This is not desirable, so something should be fixed.
