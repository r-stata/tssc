* 9/30/2012
* non-Bayes Non-MC version rewritten for Mplus 7
* non-Bayes Non-MC version uses file read instead of loading out as data
* F12.5 handling for version 7
capture program drop runmplus_load_savedata 
program define runmplus_load_savedata , rclass

syntax , out(string) [clear debug m(string) ]
* m option - number of imputations

qui {

   
   tempname fh
   local linenum = 0
   file open `fh' using `"`out'"', read
   file read `fh' line
   while r(eof)==0 {
      * Mplus version ------------------------------
      if regexm(lower(`"`macval(line)'"'),"mplus version")==1 {
         local mplusversion : word 3 of `macval(line)'
         if "`debug'"=="debug" {
            noisily di  "local mplusversion -> `mplusversion'"
         }
      }
      * idvariable ---------------------------------
      if regexm(lower(`"`macval(line)'"'),"idvariable")==1 {
         local idvariableis : word 3 of `macval(line)'
         if "`debug'"=="debug" {
            noisily di  "local idvariableis -> `idvariableis'"
         }
      }
      * savefile ------------------------------------
      if lower(trim("`line'"))=="save file" {
         file read `fh' line
         local filenameis  `"`macval(line)'"'
         *if regexm("`filenameis'",".")==1 { // no suffix is provided
         *   copy `filenameis' `filenameis'.raw , replace public
         *   cap erase `filenameis'
         *}
         if "`debug'"=="debug" {
            noisily di  "local filenameis -> `filenameis'"
         }
      }
      * variables are -------------------------------
      if lower(trim("`line'"))=="order and format of variables" {
         file read `fh' line // skip a line
         file read `fh' line // read first variable
         local j=0
         while trim("`line'")~="" {
            local w`++j' : word count `macval(line)'
            if `w`j''==2 {
               local v`j' : word 1 of `macval(line)'
               local f`j' : word 2 of `macval(line)'
            }
            if `w`j''>2 {
               local f`j' : word `w`j'' of `macval(line)'
               local v`j' "`macval(line)'"
               local v`j' : list v`j' - f`j'
               local v`j' =itrim("`v`j''")
               local v`j' =subinstr("`v`j''"," ","_",.)
               local v`j' =subinstr("`v`j''","%","",.)
               local v`j' =subinstr("`v`j''",".","",.)
            }               
            file read `fh' line // read next variable
            if "`debug'"=="debug" {
               noisily di "local v`j' (and f`j') -> `v`j'' (`f`j'')"
            }
            local v`j' = lower("`v`j''")
            local f`j' : subinstr local f`j' "F10.3" "str10"
            local f`j' : subinstr local f`j' "F12.5" "str12"
            local f`j' : subinstr local f`j' "I" "str"
         }
      }
      file read `fh' line
   }
   file close `fh'
   tempfile dct
   file open `fh' using `dct' , write
   file write `fh' "dictionary using `filenameis' { " _n
   forvalues i = 1/`j' {
      * loop if imputation variable
      if "`debug'"=="debug" {
         di "`v`i'' <- local v`i'"
      }
      if substr("`v`i''",1,1)=="+" {
         lstrfun v`i' , subinstr("`v`i''","+","",1)
         if "`m'"=="" {
            noisily di in red "Must specify number of imputations in m"
            qui table #kill
         }
         local M=`m'
         forvalues m=1/`M' {
            file write `fh' "   `f`i'' `v`i''m`m' " _n
         }
      }
      else {
         file write `fh' "   `f`i'' `v`i'' " _n
      }
   }
   file write `fh' "}" _n
   file close `fh'
   
   cap erase `dct'.dct
   filefilter `dct' `dct'.dct , from("#") to("_c")
   cap erase `dct'
   if "`debug'"=="debug" {
      noisily di "dct file is -> `dct'.dct" _n
      noisily type `dct'.dct
   }
   if "`clear'"~="clear" {
      infile using "`dct'.dct"  
   }
   if "`clear'"=="clear" {
      clear
      infile using "`dct'.dct"  
   }
   foreach var of varlist _all {
      destring `var' , replace force
   }
}

end





