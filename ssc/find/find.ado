*! 1.01 22Apr2009 Austin Nichols austinnichols@gmail.com
*! -find- 
*! program to find text in specified files 
*!  and optionally display relevant lines.
*! syntax is:
*!    find [filelist] [, match(string) show zero ]
*! for an example, try:
*!    cd `c(sysdir_base)'a
*!    loc t : dir . file "*.ado"
*!    find `t', m(version 8) s
prog find
version 8.2
syntax [anything] [, Match(string asis) Show Zero ]
loc hid 0
if "`zero'"!="" loc zero "=0"
else loc zero "0"
if `"`match'"'=="" {
 di as err "no match string specified; " _c
 di as err "all files will be shown, but no matches." _n
 loc zero "=0"
 loc hid 1
 loc show
 }
if `"`anything'"'=="" {
 di as err "No files specified; " _c
 di as err "all files in current directory" _c
 di as err " will be searched." _n
 loc anything : dir . file "*"
 }
loc w:subinstr local anything "*" "", all count(local wc)
if `wc'>0 {
 loc a
 foreach f of local anything {
   loc ap : dir . file "`f'"
   loc a `"`a' `ap'"'
   }
 loc anything `"`a'"'
 }
foreach f of local anything {
 tempfile t
 cap filefilter `"`f'"' `t', from(`"`match'"') to("")
 loc n=r(occurrences)
 if `n'>`zero' & `n'<. {
  if `hid'!=1 di as txt "`n' matches found in " _c
  di as txt `"`f'"'
  if "`show'"!="" {
   loc l
   tempname h
   file open `h' using `"`f'"', read
   file read `h' line
   while r(eof)==0 {
    local l = `l' + 1
    loc s:subinstr local line `"`match'"' "", all count(local c)
    loc s:subinstr local line "`:di _char(96)'" "`:di _char(145)'", all 
    loc s:subinstr local s `"`:di _char(39)'"' "`:di _char(146)'", all
    if `c'>0 display as txt "line " %1.0f `l' _asis `": `s'"'
    file read `h' line
   }
   file close `h'
   di
   }
  }
 }
end

 
