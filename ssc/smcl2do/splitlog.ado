*! version 1.0.1 August 24, 2016 @ 21:34:18
*! splitlog is a utility for marking up smcl files which could then be postprocessed
program define splitlog, rclass
version 11.2
   syntax using/ [, replace strip(int 0) saving(str) ///
     CMDonly RESonly noNUMber ///
     commandname(str) resultname(str) orphanname(str) ///
     commandnumberingname(str) resultnumberingname(str) orphannumberingname(str) ///
     commandbeginprefix(str) commandbeginsuffix(str) ///
     commandendprefix(str)   commandendsuffix(str) ///
     resultbeginprefix(str)  resultbeginsuffix(str) ///
     resultendprefix(str)    resultendsuffix(str) ///
     orphanbeginprefix(str)  orphanbeginsuffix(str) ///
     orphanendprefix(str)    orphanendsuffix(str) ///
     ]
   // make sure that only one of cmdonly and resonly is specified
   if "`cmdonly'"!="" & "`resonly'"!="" {
      display as error "Only one of cmdonly and resonly may be specified!"
      exit 198
      }
   parsefilename using `"`using'"', defext(smcl)
   local usingbase `"`s(sbase)'"'
   local usingext `"`s(sext)'"'
   local using `"`usingbase'`usingext'"'
   confirm file `"`using'"'
   if `"`saving'"'!="" {
      parsefilename using `"`saving'"', defext(smcl)
      local savingbase `"`s(sbase)'"'
      local savingext `"`s(sext)'"'
      }
   else {
      local savingbase `"`usingbase'_split"'
      local savingext ".smcl"
      }
   local saving `"`savingbase'`savingext'"'
   if "`replace'"=="" {
      confirm new file `"`saving'"'
      }
   // fixing polarity of 'number' to be non-empty when numbering is used
   if "`number'"=="" {
      local number "number"
      }
   else {
      local number ""
      }
   // endless output options
   if `"`commandname'"'=="" local commandname "command"
   if `"`commandbeginprefix'"'=="" local commandbeginprefix "/*** Begin "
   if `"`commandbeginsuffix'"'=="" local commandbeginsuffix " ***/"
   if `"`commandendprefix'"'=="" local commandendprefix "/*** End "
   if `"`commandendsuffix'"'=="" local commandendsuffix "`commandbeginsuffix'"
   if `"`commandnumberingname'"'=="" local commandnumberingname " number: "

   if `"`resultname'"'==""  local resultname  "result"
   if `"`resultbeginprefix'"'=="" local resultbeginprefix "/***** Begin "
   if `"`resultbeginsuffix'"'=="" local resultbeginsuffix " *****/"
   if `"`resultendprefix'"'=="" local resultendprefix "/***** End "
   if `"`resultendsuffix'"'=="" local resultendsuffix "`resultbeginsuffix'"
   if `"`resultnumberingname'"'=="" local resultnumberingname " number: "

   if `"`orphanname'"'==""  local orphanname  "orphan"
   if `"`orphanbeginprefix'"'=="" local orphanbeginprefix "/******* Begin "
   if `"`orphanbeginsuffix'"'=="" local orphanbeginsuffix " *******/"
   if `"`orphanendprefix'"'=="" local orphanendprefix "/******* End "
   if `"`orphanendsuffix'"'=="" local orphanendsuffix "`orphanbeginsuffix'"
   if `"`orphannumberingname'"'=="" local orphannumberingname " number: "
   
   tempfile outfile
   // these are needed to close file handles if Mata errors out
   scalar mataInHandle = -1
   scalar mataOutHandle = -1

   capture noisily mata: splitlog_process_file(`"`using'"',"`outfile'")

   nobreak {
      local rc = _rc
      if `rc' {
         if mataInHandle>=0 {
            mata: fclose(st_numscalar("mataInHandle"))
            }
         if mataOutHandle>=0 {
            mata: fclose(st_numscalar("mataOutHandle"))
            }
         exit `rc'
         }
      }
   
   copy `"`outfile'"' `"`saving'"', `replace'
   return local errcmd "`errcmd'"
   return local cmdnum "`cmdnum'"
   return local orphannum "`orphannum'"
end

version 11.2
mata:
   void _splitlog_writeln(real scalar fh, string scalar curline, real scalar state, real scalar firstline, real scalar cmdpos) {
      // most interesting things are in local macros in Stata
      real scalar strip 
      // initialization
      strip = strtoreal(st_local("strip"))
      
      if (state==1) {
         if (firstline) {
            if ( (strip==2) & (cmdpos>1) ){
               curline=substr(curline,cmdpos-5) // 5 == length("{com}")
               }
            else if ( (strip==3) ) { // cmdpos had best be > 0
               curline = substr(curline,2+cmdpos)
               }
            }
         else if (state==1 & strip >= 1) {
            if (substr(curline,1,1)==">") {
               curline=substr(curline,2)
               }
            }
         }
      fput(fh,curline)
      }

   void splitlog_process_file( string scalar infile, string scalar outfile) {
      // file handles
      real scalar inh, outh
      // container for current line
      string scalar theLine
      // state information
      real scalar state // 0: start, 1: cmd, 2: results, 3: orphan
      real scalar laststate
      // something which eventually could be used for flexible marking of
      //    input and results
      string vector stateName
      string vector stateBeginPrefix
      string vector stateBeginSuffix
      string vector stateEndPrefix
      string vector stateEndSuffix
      string vector stateNumberingName
      pointer(real scalar) vector stateCounters

      // bookkeeping
      real scalar ins6hlp, firstline, lasterr, cmdpos
      real scalar blankLine, lastBlankLine
      real scalar stataSaysCmd, lastStataSaysCmd, stataSaysUpdated
      // counters
      real scalar cmdnum, orphannum, dodepth
      // chunks of commands
      string scalar firstchar
      // list of commands generating errors
      string scalar errcmd
      // things which are Stata locals
      // things derived from Stata locals
      real scalar number
      real scalar writecmd
      real scalar writeres
      real scalar writeorp

      lasterr=.
      state=3
      firstline=1
      laststate=0
      orphannum=0
      dodepth=0
      cmdnum=0
      ins6hlp=0
      errcmd=""
      stataSaysCmd=0
      lastStataSaysCmd=0

      stateName = (st_local("commandname"), st_local("resultname"), st_local("orphanname"))
      stateBeginPrefix = (st_local("commandbeginprefix"),st_local("resultbeginprefix"),st_local("orphanbeginprefix"))
      stateBeginSuffix = (st_local("commandbeginsuffix"),st_local("resultbeginsuffix"),st_local("orphanbeginsuffix"))
      stateEndPrefix = (st_local("commandendprefix"),st_local("resultendprefix"),st_local("orphanendprefix"))
      stateEndSuffix = (st_local("commandendsuffix"),st_local("resultendsuffix"),st_local("orphanendsuffix"))
      stateNumberingName = (st_local("commandnumberingname"),st_local("resultnumberingname"),st_local("orphannumberingname"))
      stateCounters=(&cmdnum,&cmdnum,&orphannum)

      number=st_local("number")!=""
      writecmd=st_local("resonly")==""
      writeres=st_local("cmdonly")==""
      writeorp=writecmd & writeres
      
      inh=fopen(infile,"r")
      st_numscalar("mataInHandle",inh) // needed in case of error
      // debug:  printf("Just opened mataInHandle: %2.0f\n",inh)
      theLine=fget(inh)
      if (strtrim(theLine)!="{smcl}") {
         fclose(inh)
         st_numscalar("mataInHandle",-1)
         errprintf("smcl files start with {smcl}, but\n  " + infile + "\nstarts with\n  " + theLine + "\n")
         exit(610)
         }
      outh=fopen(outfile,"w")
      st_numscalar("mataOutHandle",outh) // needed in case of error
      // debug:  printf("Just opened mataOutHandle: %2.0f\n",outh)
      // debug:  errprintf("Bwuahahaahahah!\n")
      // debug:  exit(666)     
      // go back to the start
      fseek(inh,0,-1)
      while( (theLine=fget(inh))!=J(0,0,"") ) {
         // initialize to no command found
         cmdpos=0
         stataSaysUpdated=0
         firstchar=substr(theLine,1,1)
         blankLine= strltrim(theLine)==""
         if (!blankLine) {
            if (substr(theLine,1,7)=="{s6hlp}") {
               ins6hlp=1
               }
            // ins6hlp can have lines starting with . which are not commands
            if (!ins6hlp) {
               if (regexm(theLine,"{search r\([1-9]+[0-9]*\)(, local)?:r\([1-9]+[0-9]*\);}")) {
                  // it's possible to think there are many errors if a do-file dies
                  if (lasterr!=cmdnum) {
                     lasterr=cmdnum
                     errcmd = errcmd + " " + strofreal(cmdnum)
                     }
                  }
               // need to look for command start independently of input state
               //   because of do-files
               if (firstchar=="." | firstchar==":") {
                  cmdpos=1
                  }
               else if ( cmdpos=max((strpos(theLine,"{com}."), strpos(theLine,"{com}:"))) ) {
                  cmdpos=cmdpos+5           //  length("{com}") == 5
                  }                         // end of test for command start
               // check what Stata thinks the state is to help with lazy markup
               if (regexm(strreverse(strtrim(theLine)),"}(txt|moc|ser){")) {
                  stataSaysCmd= (strreverse(regexs(1))=="com")
                  stataSaysUpdated=1
                  }
               }
            }
         if (state==1) { // already in a command
            if (firstchar==">") { // continuation in command
               firstline=0
               }
            else { // command over
               firstline=1
               if (cmdpos) {
                  state=1
                  }
               else { // switching to results
                  state=2
                  }
               }
            } // end command mode
         else { // result or orphan mode
            if ( dodepth>0 ) {
               firstline = 0
               if (lasterr==cmdnum) {
                  dodepth = dodepth - (theLine=="end of do-file")
                  }
               else {
                  dodepth = dodepth - (theLine=="{txt}end of do-file")
                  }
               // just be sure that dodepth does not become negative
               dodepth=max((0,dodepth))
               }
            else {
               if ((cmdpos>1) | (lastStataSaysCmd & (cmdpos==1))) {
                  // stay in orphan mode if command starts with right curly brace
                  //  cannot remember how this ever happens...
                  if ( (state==3) & (substr(strltrim(substr(theLine,cmdpos+1)),1,6)=="{c )-}") ) {
                     firstline=0
                     }
                  else {
                     state=1
                     firstline=1
                     ins6hlp=0
                     }
                  }
               else if (ins6hlp) {
                  firstline=0
                  if ((substr(theLine,1,6)=="{smcl}")) {
                     ins6hlp=0
                     }
                  }
               else if ((substr(theLine,1,6)=="{smcl}")) { 
                  state=3 // orphan mode
                  firstline=1
                  orphannum++
                  }
               else {
                  firstline=0
                  }
               }
            } // end result mode
         // check first line of command for . do WITH TRAILING SPACE
         if (cmdpos) {
            dodepth = dodepth+ (substr(strltrim(substr(theLine,cmdpos+1)),1,3)=="do ")
            }
         if (firstline) {
            // check for blank result and lazy smcl state change
            if (number) {
               if ((laststate==1 & writecmd) | (laststate==2 & writeres) | (laststate==3 & writeorp)) {
                  if (laststate) { // laststate = 0 at start
                     fput(outh,stateEndPrefix[laststate]+stateName[laststate]+stateNumberingName[laststate]+strofreal(*(stateCounters[laststate]))+stateEndSuffix[laststate])
                     }
                  }
               if (laststate==1 & state==1 & writeres) {
                  fput(outh,stateBeginPrefix[2]+stateName[2]+stateNumberingName[2]+strofreal(*(stateCounters[2]))+stateEndSuffix[2])
                  fput(outh,stateEndPrefix[2]+stateName[2]+stateNumberingName[2]+strofreal(*(stateCounters[2]))+stateEndSuffix[2])
                  }
               }
            if (state==1) {
               cmdnum++
               }
            if (number) {
               if ((state==1 & writecmd) | (state==2 & writeres) | (state==3 & writeorp)) {
                  fput(outh,stateBeginPrefix[state]+stateName[state]+stateNumberingName[state]+strofreal(*(stateCounters[state]))+stateBeginSuffix[state])
                  }
               }
            }
         if ((state==1 & writecmd) | (state==2 & writeres) | (state==3 & writeorp)) {
            _splitlog_writeln(outh,theLine,state,firstline,cmdpos)
            }
         lastBlankLine = blankLine
         laststate=state
         if (stataSaysUpdated) {
            lastStataSaysCmd=stataSaysCmd
            }
//         fput(outh,"!!stataSaysCmd is "+ strofreal(stataSaysCmd))
//         fput(outh,"!!stataSaysUpdated is "+ strofreal(stataSaysUpdated))
//         fput(outh,"!!lastStataSaysCmd is "+ strofreal(lastStataSaysCmd))
         } // end of processing loop
      // closing off last block
      if (number & ((state==1 & writecmd) | (state==2 & writeres) | (state==3 & writeorp))) {
         fput(outh,stateEndPrefix[state]+stateName[state]+stateNumberingName[state]+strofreal(*(stateCounters[state]))+stateEndSuffix[state])
         }
      fclose(inh)
      fclose(outh)
      st_local("errcmd",errcmd)
      st_local("cmdnum",strofreal(cmdnum))
      st_local("orphannum",strofreal(orphannum))
      }
end

exit
strip == 0: commands look like they do in a log file
strip == 1: strips continuation markers (>)
strip == 2: also strips numbering inside of loops
strip == 3: also strips out prompts

Limitations:
Leaves an extra orphan at the bottom of the file because of the
  way that log close puts in an extra bunch of worthless smcl stuff

Using a {com} directive cleverly can fool this...but {com} directives are
  supposed to be for Stata output routines only; users should write
  always use {cmd}.

Using -do- within loops is destined for problems, because the commands
  do not get echoed, and hence there is no way to track when control goes
  from one do-file to the next

!!Has problems with smcl files created by running a do-file in batch
  mode (console or GUI) without the -q (squelch ascii art) option,
  because the header includes a -do whatever- line. This prevents
  splitlog from ever getting out of orphan mode. Will have to think
  about whether orphan mode prevents adding to the do counter (and
  then what to do with the orphaned end-of-do file 
