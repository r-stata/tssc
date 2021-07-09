*! version 1.0.3 February 14, 2020 @ 10:32:34
*! wraps putdocx a bit
program define putwrap
version 15

   syntax using/, [saving(str) replace defpar(str)]

   // saving is for the generated do-file
   // if the using file has a .do extension
   // the default value is
   //    base(`using')_conv.do
   // otherwise, it is base(using).do
   // it gets written putwrap looks through the file so that it can be
   //    debugged
   
   local putcmds "putpdf putdocx"

   if `"`saving'"'=="" {

      mata: st_local("using_ext", pathsuffix(st_local("using")))
      if `"`using_ext'"'==".do" {
         mata: st_local("saving",pathrmsuffix(st_local("using"))+"_conv.do")
         }
      else {
         mata: st_local("saving",pathrmsuffix(st_local("using"))+".do")
         }
      }

   if "`replace'"=="" {
      capture confirm file `"`saving'"'
      if !_rc {
         display as error `"file `saving' already exists"'
         exit 602
         }
      }

   tempname fhin fhout fhdebug
   file open `fhin' using `"`using'"', read
   file open `fhout' using `"`saving'"', write `replace'

   local wstate 0 // 1: writing to putxxx, 0: everything else
   local haveblank 0 // 1: prev line blank (for finding paragraphs)
   local triple 0 // 1: prev line contained ' ///', 0: otherwise
   

   // run through to find type (should be relatively near the top)
   file read `fhin' theLine
   while !r(eof) {
      gettoken word1 rest : theLine
      local putcmd : list word1 & putcmds
      if `"`putcmd'"'!="" {
         file seek `fhin' tof
         continue, break
         }
      file read `fhin' theLine
      }
   if `"`putcmd'"'=="" {
      display as error "Could not determine type of document!"
      exit 198
      }
      

   file read `fhin' theLine
   while !r(eof) {
      local continue 0 // default state
      if `triple' {
         if !`wstate' {
            local continue 1
            }
         else { // in write mode
            if `"`word1'"'==`"`putcmd'"' {
               local continue 1
               }
            }
         }
      if `continue' {
         file write `fhout' `"`macval(theLine)'"'
         file write `fhout' _n
         }
      else {
         gettoken word1 rest : theLine
         * allow *-style comments in front of lines
         if usubstr(`"`word1'"',1,1)!="*" {
            if `"`word1'"'==`"`putcmd'"' {
               gettoken subcmd rest : rest, parse(" ,")
               if `"`subcmd'"'=="pause" {
                  local wstate 0
*               local haveblank 0
                  }
               else if `"`subcmd'"'=="resume" {
                  local wstate 1
*               local haveblank 0
                  }
               else {
                  if `haveblank' {
                     if `"`subcmd'"'=="paragraph" {
                        local haveblank 0
                        }
                     }
                  if `haveblank' {
                     file write `fhout' `"`putcmd' paragraph, `defpar'"' _n
                     local haveblank 0
                     }
                  if `"`subcmd'"'=="begin" {
                     local wstate  1
                     local haveblank 0
                     }
                  file write `fhout' `"`macval(theLine)'"'
                  file write `fhout' _n
                  }
               } // end test for put command
            else {
               if `wstate' {
                  if ustrltrim(`"`theLine'"')=="" {
                     local haveblank 1
                     }
                  else {
                     if `haveblank' {
                        file write `fhout' `"`putcmd' paragraph, `defpar'"' _n
                        }
                     file write `fhout' "`putcmd' text (\`"
                     file write `fhout' `"""'
                     file write `fhout' `"`macval(theLine)'"'
                     if usubstr(`"`macval(theLine)'"',-1,1) != " " {
                     file write `fhout' " "
                     } 
                     file write `fhout' `"""'
                     file write `fhout' "')"
                     file write `fhout' _n
                     local haveblank 0
                     }
                  } // end of streaming write
               else {
                  file write `fhout' `"`macval(theLine)'"'
                  file write `fhout' _n
                  }
               }
            } // end of test for *-style comment
         } // end of test for continuing
      if ustrpos(`"`macval(theLine)'"',`" ///"') {
        local triple 1
         }
      else {
         local triple 0
         }
      file read `fhin' theLine
      }
   file close `fhin'
   file close `fhout'
   
end
