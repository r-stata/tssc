*! outfixt creates a fixed-format ASCII text file with support for long lines
*! outfixt 1.1 9 Dec 2006 Austin Nichols fixed -format- option, added -dct- option
* outfixt 1.0 7 Feb 2006 Austin Nichols
program def outfixt
 version 8.2
 syntax varlist(min=1) [if] [in] using/ , Cols(numlist asc int >0) [ Format flist(string) replace cap dct(string asis) ]
 local nvars : word count `varlist'
 local ncols : word count `cols'
 if `"`flist'"'!="" {
   local nfmts : word count `flist'
   }
 else local nfmts=`nvars'
 if `nvars' != `ncols' | `nvars' != `nfmts' {
   di as err "match number of variables, columns, formats"
   exit 198
 }
 tempvar out touse
 mark `touse' `if' `in'
 file open `out' using "`using'", write `replace'
 loc lrecl=0
 forv i = 1/`=_N' {
   if `touse'[`i'] {
    file write `out' _n
    `cap' di
    forv j = 1/`nvars' {
      local cj : word `j' of `cols'
      local vj : word `j' of `varlist'
      local fj : word `j' of `flist'
      cap di `fj' `vj'[`i']
      if ("`fj'"=="." | _rc | "`format'"!="") local fj : format `vj'
      file write `out' _col(`cj') "`: di `fj' `vj'[`i']'"
      `cap' di as txt _col(`cj') `fj' `vj'[`i'] _c
      if `j'==`nvars' loc lrecl=max(`lrecl',`cj'+length("`: di `fj' `vj'[`i']'"))
      }
   }
 }
file close `out'
if `"`dct'"'!="" {
 gettoken dct dctopt: dct, p(",")
 loc dctopt: subinstr loc dctopt "," ""
 file open `out' using "`dct'", `dctopt' write
 file write `out' "dictionary {" 
 forv j = 1/`nvars' {
      local cj : word `j' of `cols'
      local vj : word `j' of `varlist'
      local fj : word `j' of `flist'
      local cj1 : word `=`j'+1' of `cols'
      if "`cj1'"=="" loc cj1 `lrecl'
      loc l=`cj1'-`cj'
      loc t: type `vj'
      if substr("`t'",1,3)=="str" {
       loc s "s"
       }
      else {
       loc s "f"
       }
      file write `out' _n `"_column(`cj') `t' `vj' %`l'`s' "`:var label `vj''" "'
      }
 file write `out' _n "}" _n
 file close `out'
 }
end
