*! version on 0.3 28March2009

/*
 grep <string>, [path(dir)] [filter(auto)]    
 Corrected some rebustness issues (spaces in names, aliasing the ls command 
 in unix, clobber failure etc). While working on them Dan Blanchette tought 
 me just the right stata sentence which took care of all the issues at once.
 Dan: Thanks. 
*/

program def grep, rclass 
version 9.0

syntax anything(name=string), [Path(string)] [Filter(string)]

if `"`path'"' == "" {
  local path `c(pwd)'
}

if `"`filter'"' == "" {
  local filter "*"
}


if regexm(`"`path'"',"`c(dirsep)'$") !=0 {
 local path =  substr(`"`path'"',1, length(`"`path'"')-1)
 di `"`path'"'
} 

if regexm(`"`filter'"',"\.dta$") ==0 {
 local filter = `"`filter'.dta"'
}  

local files :  dir `"`path'"' files `"`filter'"' , nofail
local nfiles : word count `files'
if `nfiles' == 0 {
  display as error "Sorry, no files found"
  return local no = 0
}
else{
 preserve
 display in g "RESULTS:"
 foreach d of local files {
   quietly {
     use using `"`path'`c(dirsep)'`d'"' if _n==1, clear 
     lookfor `string'
   }
   if length("`r(varlist)'") != 0 { 
    local linenum = `linenum' + 1
    return local no = `linenum'
    return local d`linenum' = `"`path'`d'"'
    local count = wordcount("`r(varlist)'")
    return local d`linenum'no = `count'
    tokenize "`r(varlist)'"
    forvalues j =1(1)`count'{
     return local d`linenum'v`j' = "``j''"
    }
    if "`c(console)'" != "console" { // if in gui Stata
      display in smcl `"dataset: {stata `"use "`path'`c(dirsep)'`d'""':use}/{stata `"describe using "`path'`c(dirsep)'`d'""':describe}. "' ///
       `" variables: {stata `"use `r(varlist)' using "`path'`c(dirsep)'`d'""':use}/{stata `"describe `r(varlist)' using "`path'`c(dirsep)'`d'""':describe}: "' ///
       `" `count' vars in "`d'""'
    }
    else {  // if in batch or non-gui Stata
      display `". describe `r(varlist)' using "`d'""'
      describe `r(varlist)' using "`d'"
    }
   } 
 }
 restore
 }

end

