program define cf3
*! version 2.1.9 26mar2001 matches on id's - cf3
*  version 2.1.7  7apr2000 added id option - cf2
*  version 2.1.6  3jun1999 - cf2
*! version 2.1.3 was StataCorp's cf.ado
   version 6
   syntax varlist using/ , ID(varname) [noVerbose]
   local obs = _N
   local dif "0"
   local qv = cond("`verbose'" == "", "noisily", "*") 
   di
   local flag 0
   quietly describe using "`using'"
   if (r(N) != _N) { 
      di in gr "master has " in ye "`obs'" in gr " obs., " /*
      */ "using " in ye r(N)
      di in ye ">>> " in gr "files have different observation counts"
      local flag 1
   }
   tempvar dup mdup
   sort `id'
   by `id': gen `dup' = _n
   egen `mdup' = max(`dup')
      if `mdup' > 1 {
      di in ye ">>> " in gr "id var, " in ye "`id'" /*
      */ in gr ", not unique in master file"
      local flag 1
      }
   local first 1
   tempfile tempcfm
   quietly {
      tokenize `varlist'
      while "`1'" != "" {
         preserve
         keep `1' `id'
         sort `id'
         save `"`tempcfm'"', replace 
         use `"`using'"', clear 
         capture confirm variable `1'
         if _rc {
            noisily di in gr "`1':" _col(12) in ye /* 
            */ "does not exist in using"
            local dif "9"
         }
         else {
            if `first' {
               tempvar dup mdup
               sort `id'
               by `id': gen `dup' = _n
               egen `mdup' = max(`dup')
               if `mdup' > 1 {
                  noi di in ye ">>> " in gr "id var, " in ye "`id'" /*
                  */ in gr ", not unique in using file"
                  local flag 1
               }
               local first 0
               if `flag' {
                  noi di _n in ye "the above errors will cause " /*
                               */ "mismatches; fix first"
                  if "`qv'" == "*" { noi di }
               }
            }
            keep `1' `id'
            rename `1' _cf
            if "`1'" == "`id'" { 
              local tm : type _cf
              gen `tm' `id' = _cf
            }
            sort `id'
            merge `id' using `"`tempcfm'"'
            capture count if _cf != `1'
            if _rc {
               local tm : type `1'
               local tu : type _cf
               noisily di in gr "`1':" _col(12) /*
               */ in ye "`tm'" in gr " in master but " /*
               */ in ye "`tu'" in gr " in using"
               local dif "9"
            }
            else if r(N) == 0 {
               `qv' di _n in gr "`1':" _col(12) "match"
            }
            else {
               `qv' di
               noisily di in gr "`1':" _col(12) /*
               */ in ye r(N) in gr " mismatches"
               local dif "9"
* rename _cf as _varname in "using" dataset, 
*    where "varname" is the first 7 characters
*    of the variable name in the "master" dataset
               local name = "_" + substr("`1'", 1, 7)
               rename _cf `name'
               local fmt : format `1'
               format `name' `fmt'
* use format to define _skip() spacing for column headers
               local t = substr("`fmt'", 2, 1)
               local dash = 0
               if "`t'" == "-" {      /* left justified  */
                  local dash = 1
                  local t = substr("`fmt'", 3, 1)
               }
               if "`t'" == "d" {      /* date formats    */
                  _dl `fmt'
                  local vdig = r(lngth)
               }
               if "`t'" == "t" {      /* time-series     */
                  _tl `fmt'
                  local vdig = r(lngth)
               }
               if "`t'" != "t" & "`t'" != "d" {  
                  /* numeric & strings */
                  local vdig = index("`fmt'", ".")
                  if `vdig' == 0 { local vdig = length("`fmt'") }
                  local vdig = real(substr("`fmt'", 2 + `dash', /*
                                      */   `vdig' - 2 - `dash'))
               }  
               /* space for obs # */
               local ndig = max(3, int(1 + log10(_N)))
               local v1 = `vdig' - 6 + `ndig'
               local v2 = `vdig' - 4
               if `dash' == 1 {   /* left justified  */
                  local v2 = `v1'
                  local v1 = `ndig' - 1
               }
* list the disparate data
               `qv' di "obs" _skip(`v1') "using" _skip(`v2') /* 
                    */ "master    id..." _c
               `qv' list `name' `1' `id' if `name' != `1'
            }
         }
         mac shift
         restore
      }
   }
   exit `dif'
end

program define _dl, rclass
*  version 1.0.0  3jun1999
*  returns # of print characters from a date format
version 6
local fmt `1'
local t = substr("`fmt'", 2, 1)
local dash = 0  /* left justification ? */
if "`t'" == "-" { local dash = 1 } 
local len = length("`fmt'")

local i = 3 + `dash' 
local c 0
while `i' <= `len' {
   local k = substr("`fmt'", `i' ,1)
   if      "`k'" == "!" {
                          local c = `c' + 1
                          local i = `i' + 1
                        }
   else if "`k'" == "c" { local c = `c' + 2 }
   else if "`k'" == "C" { local c = `c' + 2 }
   else if "`k'" == "y" { local c = `c' + 2 }
   else if "`k'" == "Y" { local c = `c' + 2 }
   else if "`k'" == "m" { local c = `c' + 3 }
   else if "`k'" == "M" { local c = `c' + 9 }
   else if "`k'" == "l" { local c = `c' + 3 }
   else if "`k'" == "L" { local c = `c' + 9 }
   else if "`k'" == "n" { local c = `c' + 2 }
   else if "`k'" == "N" { local c = `c' + 2 }
   else if "`k'" == "d" { local c = `c' + 2 }
   else if "`k'" == "D" { local c = `c' + 2 }
   else if "`k'" == "j" { local c = `c' + 3 }
   else if "`k'" == "J" { local c = `c' + 3 }
   else if "`k'" == "w" { local c = `c' + 2 }
   else if "`k'" == "W" { local c = `c' + 2 }
   else                 { local c = `c' + 1 }
   local i = `i' + 1
}

if `c' == 0 { local c 9 }  /* handle default %d */

global S_1 = `c'
return scalar lngth = `c'
end

program define _tl, rclass
*  version 1.0.0  3jun1999
*  returns # of print characters from a time-series format
version 6
local fmt `1'
local t = substr("`fmt'", 2, 1)
local dash = 0  /* left justification ? */
if "`t'" == "-" { local dash = 1 }
local t = substr("`fmt'", 3 + `dash', 1)
local len = length("`fmt'")

local i = 4 + `dash' 
local c 0
while `i' <= `len' {
   local k = substr("`fmt'", `i' ,1)
   if      "`k'" == "!" {
                          local c = `c' + 1
                          local i = `i' + 1
                        }
   else if "`k'" == "c" { local c = `c' + 2 }
   else if "`k'" == "C" { local c = `c' + 2 }
   else if "`k'" == "y" { local c = `c' + 2 }
   else if "`k'" == "Y" { local c = `c' + 2 }
   else if "`k'" == "m" { local c = `c' + 3 }
   else if "`k'" == "M" { local c = `c' + 9 }
   else if "`k'" == "l" { local c = `c' + 3 }
   else if "`k'" == "L" { local c = `c' + 9 }
   else if "`k'" == "n" { local c = `c' + 2 }
   else if "`k'" == "N" { local c = `c' + 2 }
   else if "`k'" == "d" { local c = `c' + 2 }
   else if "`k'" == "D" { local c = `c' + 2 }
   else if "`k'" == "j" { local c = `c' + 3 }
   else if "`k'" == "J" { local c = `c' + 3 }
   else if "`k'" == "w" { local c = `c' + 2 }
   else if "`k'" == "W" { local c = `c' + 2 }
   else                 { local c = `c' + 1 }
   local i = `i' + 1
}

if `c' == 0 {  /* handle default %t_ formats */
   if "`t'" == "d" { local c 9 }
   if "`t'" == "w" { local c 7 }
   if "`t'" == "m" { local c 7 }
   if "`t'" == "q" { local c 6 }
   if "`t'" == "h" { local c 6 }
   if "`t'" == "y" { local c 4 }
   if "`t'" == "g" { local c 9 }
}

global S_1 = `c'
return scalar lngth = `c'
end
