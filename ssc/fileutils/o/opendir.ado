*! version 1.0.1 October 16, 2017 @ 11:44:52
*! opens up a directory (defaulting to the working directory)
program define opendir
version 12.1
   ** 1.0.1: removed quietly, so that when ~ expansion fails, the user sees the warning
   local self opendir
   syntax [anything(name=theDir id="folder or directory name")] [, Sysdir(string)]
   if `"`sysdir'"'!="" {
      if "`theDir'"!="" {
         display as error "[`self']: You may not specify both a directory/folder and the sysdir option"
         exit 198
         }
      local theDir `c(sysdir_`=lower(`"`sysdir'"')')'
      if `"`theDir'"'=="" {
         display as error "[`self']: sysdir option incorrectly specified: "
         display as error `"`sysdir'"'
         exit 198
         }
      }
   if `"`theDir'"'=="" {
      local theDir .
      }
   if "`c(os)'"=="Windows" {
      // need to change /'s to \'s
      local theDir : subinstr local theDir "/" "\", all
      local cmd "winexec explorer"
      }
   else {
      // make life easier for quoted ~ chars, as they don't get expanded in Unix
      if strpos(`"`theDir'"',`"""') {  // " for string highlighting
         if ustrpos(ustrtrim(usubstr(`"`theDir'"',2,.)),"~")==1 {
            local theDir = usubinstr(`"`theDir'"',"~","\$HOME",1)
            }
         }
      if "`c(os)'"=="MacOSX" {
         local cmd "! open"
         }
      else {
         else { // linux
            local cmd "! xdg-open"
            }
         }
      }
*   display `macval(theDir)'
   `cmd' `macval(theDir)'
end
