*! etime Version 1.2 dan_blanchette@unc.edu 10Nov2010
*! the carolina population center, unc-ch
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
** - made -etime- able to work if -macro drop _all- was run 
**    and s(startime) and s(stardate) exist which makes -etime- work when -cscript- is run
** etime Version 1.1 dan.blanchette@duke.edu  22Jan2009
** - made -etime- able to run after Stata commands that use
**   -sreturn clear- in them by duplicating the scalars returned
**   by -etime- with global macros with names that start with:
**   etime_*
** research computing, unc-ch
** - made etime give error message if the first time it's invoked
**    is not with the start option.
** etime Version 1.0 dan_blanchette@unc.edu  23Jun2004 
** - fixed display when lasts longer than a day
** etime Version 1.0 dan_blanchette@unc.edu  30Sep2003
** the carolina population center, unc-ch

program define etime, sclass
 syntax [, Start  Datestart(string) Timestart(string) ]
 version 8

 if ("`start'" == "start") | ( "`datestart'" != "" | "`timestart'" != "") {
   if ("`start'" == "start") {
     local stardate= date("`c(current_date)'","dmy")
     local startime= "`c(current_time)'"
   }
   else if ( "`datestart'" != "" | "`timestart'" != "") {
     if "`datestart'" == ""  {
       local stardate= date("`c(current_date)'","dmy")
     }
     else  local stardate= date("`datestart'","dmy")
  
     if "`timestart'" == "" {
       display as error "invoking {help etime:etime} by specifying a date but not a time doesn't make sense."     
       exit 499
     }
     else  local startime= "`timestart'"
   }
   
   gettoken t startime : startime, parse(":")
   local i=1
   while `"`t'"' != "" {
     if "`t'" != ":" {
       local s`i'= "`t'"
       local i= `i' + 1
     }
     gettoken t startime : startime, parse(":")
   }
   local startime= (`s1' * 60 * 60) + (`s2' * 60) + `s3'
   sreturn local stardate `stardate'
   global etime_stardate_ `stardate'
   sreturn local startime `startime'
   global etime_startime_ `startime'
 }
 
 if "`start'" == ""  {
   if (`"`s(stardate)'"' == "" & `"$etime_stardate_"' == "") | (`"`s(startime)'"' == "" & `"$etime_startime_"' == "") {
     display as error "the first time you invoke {help etime:etime} you need to use the start option or "     
     display as error " the datestart() and timestart() options or "
     display as error " just the timestart() option "
     exit 499
   } 
   if `"`s(stardate)'"' != "" & `"$etime_stardate_"' == "" {
     global etime_stardate_ `s(stardate)'
   }
   if `"`s(startime)'"' != "" & `"$etime_startime_"' == "" {
     global etime_startime_ `s(startime)'
   }
   local endate= date("`c(current_date)'","dmy")
 
   local endtime= "`c(current_time)'"
   gettoken t endtime : endtime, parse(":")
   local i= 1
   while `"`t'"' != "" {
     if "`t'" != ":" {
       local e`i'= "`t'"
       local i= `i' + 1
     }
     gettoken t endtime : endtime, parse(":")
   }
   local endtime= (`e1'*60*60)+(`e2'*60) + `e3'
   local edays= `endate'-$etime_stardate_
   if (`endate' >= $etime_stardate_) & (`e1' == 0) {
     local e1= 24
   }
   local endtime= (`edays' * 24 * 60 * 60) + `endtime'
   local etime= `endtime' - $etime_startime_
 
   local edays= int(`etime' / (24 * 60 * 60))
   local ehr= int((`etime' - (`edays' * 24 * 60 * 60)) / (60 * 60))
   local emin= int((`etime' - (`ehr' * 60 * 60) - (`edays' * 24 * 60 * 60)) / 60)
   local esec= int((`etime' - (`ehr' * 60 * 60)) - (`emin' * 60) - (`edays' * 24 * 60 * 60))
 
   local esecs= `etime'
   local etime= "`edays':`ehr':`emin':`esec'"
 
   sreturn local stardate $etime_stardate_
   global etime_stardate_ $etime_stardate_
   sreturn local startime $etime_startime_
   global etime_startime_ $etime_startime_
   sreturn local endate `endate'
   sreturn local endtime `endtime'
   sreturn local etime `etime'
   sreturn local esecs `esecs'
 
   if `edays' > 0 {
     local dayl= length("`edays'") + int(length("`edays'") / 3)
     local dayf "%`dayl'.0fc"
     local edays= string(`edays',"`dayf'")
     display `"{res}Elapsed time is `edays' days `ehr' hours `emin' minutes `esec' seconds "'
   }
   else if `ehr' > 0 {
     display `"{res}Elapsed time is `ehr' hours `emin' minutes `esec' seconds "'
   }
   else if `emin' > 0 {
     display `"{res}Elapsed time is `emin' minutes `esec' seconds "'
   }
   else  {
     display `"{res}Elapsed time is `esec' seconds "'
   }
 }
 

end

