*! usesasdel Version 2.0 dan_blanchette@unc.edu 16Mar2009
*! the carolina population center, unc-ch
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
** shortdir Version 2.0 dan_blanchette@unc.edu  17Jan2008
** research computing, unc-ch
* - added check that if forward slashes used as dir separators
*    then that is handled by converting them to back slashes
* - uses Nick Cox's way of loading a text file line by line
*    into a local macro instead of reading it in as a dataset
** shortdir Version 1.1 dan_blanchette@unc.edu  28Oct2004 
* - added test that directory actually exists
** shortdir Version 1.0 dan_blanchette@unc.edu  09Oct2003 
** the carolina population center, unc-ch  

program define shortdir, rclass 
version 8
syntax using/ [, SHort ]

 confirmdir "`using'"
 if _rc !=0 {
  di `"{error}The directory "`using'" does not exist."'
  exit _rc
 }

if "`c(os)'"=="Windows" {
 preserve
 local cwd "`c(pwd)'`macval(\\\)'"
 if "`using'"=="." {
  local using "`macval(cwd)'"
 }
 if "`using'"=="`cwd'" {
  quietly cd ..
 }
 // check if forward slashes used and replace them if so
 local subtest : subinstr local using `"/"' `""' , count(local cnt)
 if `cnt' != 0 {
   local using : subinstr local using "/" "\" , all
 }
 tokenize "`using'" , parse("\")
 local i=1
 while "``i''" !="" {
  if `i'==1 {
   local path "`1'"
  }
  else {
   if "`short'"=="short" {  /* create macro that conditionally checks 
                             * for longer than 8 letter directory names  */
     local gt8=(length("``i''")>8)
     local gt8="| `gt8'" 
   }
   if index("``i''"," ") `gt8' {  /* if sub dir name has space in name or maybe longer than 8 */
    tempfile temp
    _getfilename "`temp'"
    local tfilen "`r(filename)'"
  
    local tfileh=substr("`tfilen'",1,index("`tfilen'",".")-1)  /* create file handle */
    quietly {
      cd "`path'\"
      // options /x and /a create a short directory listing 
      //  so `temp' is a very small, short file
      ! dir /x /a "``i''"* > "`temp'"
      tempname in
      file open `in' using `"`temp'"', r
      file read `in' line
      local dline "" 
      local dir "<DIR>" 
      while r(eof) == 0 {
        // local line: subinstr local line "`old'" "`new'"
        file read `in' line
        if `: list local(dir) in local(line) ' {
          local dline `"`line'"'
        }
      }
      local gotit = 0
      local shortname ""
      local n = 1
      while `gotit' == 0 {
        local shortname : word `n' of `dline'
        if `: list local(shortname) == local(dir) ' {
           // the shortname of the subdir is the next word after "<DIR>"
           local shortname : word `= `n' + 1' of `dline'
           local gotit = 1
        }
        local n = `n' + 1
      }
    }
    local sdir`i'=trim(substr(`"`shortname'"',1,10)) 
   }  /* end of if directory has a space */
   else {
    local sdir`i' "``i''"
   }
   if "``i''"!="\" {
    local path "`macval(path)'\\`sdir`i''"
   }
  } /* if not the beginning of the path, like c:  */
  local i=`i'+1
 } /* end of while loop */
 quietly cd "`macval(cwd)'\\\"
 local shortdir="`path'"+"\"
 return local shortdir `shortdir'
}  /* end of if windows */
else {
 di "{error}shortdir only works in Windoze."
 exit
}

end 
