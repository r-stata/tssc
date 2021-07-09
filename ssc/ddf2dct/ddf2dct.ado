*! ddf2dct 1.1 10 March 2008 austinnichols@gmail.com
*! program to convert DDF files describing e.g. US Census data
*! to Stata dct and do files
* ddf2dct 1.0 31 January 2008 austinnichols@gmail.com
* 10 March 2008 fixed keep option parsing in macro list directive
program define ddf2dct
 version 8.2
 syntax using/ [, dct(str) do(str) data(str) str(str) drop(str) keep(str) replace noinfile]
 if `"`dct'"'=="" loc dct "`using'.dct"
 if `"`do'"'==""  loc do "`using'.do"
 tempname fh dc1 do1
 local linenum = 0
 file open `fh' using `"`using'"', read
 file open `dc1' using `"`dct'"', write `replace'
 file write `dc1' "dictionary "
 if `"`data'"'!="" file write `dc1' `" using `data' "'
 file write `dc1' "{"
 file open `do1' using `"`do'"', write `replace'
 if "`infile'"=="" file write `do1' "qui infile using `dct'"
 file read `fh' line
 qui while r(eof)==0 {
  local linenum = `linenum' + 1
  loc line: subinstr local line "`: di _char(39)'" "`: di _char(146)'", all
  loc line: subinstr local line "`: di _char(96)'" "`: di _char(145)'", all
  loc line: subinstr local line `"`: di _char(34)'"' "`: di _char(148)'", all
  *D lines are var names, followed by var and value labels
  if substr(`"`line'"',1,2)=="D " {
   local v: word 2 of `line'
   local lngth: word 3 of `line'
   local pos: word 4 of `line'
   loc v2: subinstr local v "$" "d", all
   loc v2: subinstr local v2 "%" "p", all
   loc v2: subinstr local v2 "-" "_", all
   loc v2=lower("`v2'")
   loc j=1
   loc vu `v2'
   while "`:list vu-already'"=="" {
    loc vu `v2'`j++'
    }
   loc v2 `vu'
   loc already `already' `v2'
   if "`:list v2-drop'"=="" local ok=0
   else {
    if "`:list v-drop'"=="" local ok=0
    else loc ok=1
    } 
   if "`keep'"!="" {
    if "`:list v2-keep'"=="" local ok=1
    else {
     if "`:list v-keep'"=="" local ok=1
     else loc ok=0
     }
    }
   if "`:list v2-str'"!="" {
    loc type
    cap if `lngth'>7 loc type "double"
    if _rc==0 {
     if `lngth'<3 loc type "byte"
     if `ok'==1 file write `dc1' _n "_column(`pos') `type' `v2' %`lngth'f"
     }
    }
   else {
    cap if `lngth'>7 loc type "double"
    if _rc==0 & `ok'==1 file write `dc1' _n "_column(`pos') str`lngth' `v2' %`lngth's"
    }
   if "`v2'"!="" file write `do1' _n `"cap la val `v2' `v2'"'
   loc next 1
   local lastval
   local lastline
   }
  if substr(`"`line'"',1,2)!="D " & "`next'"=="1" {
    if `ok'==1 file write `dc1' `" "`=trim(itrim(`"`line'"'))'""'
    local next
    }
  file write `do1' _n `"cap note `v2': `line'"'
  *V lines are value labels, which we want if valid
  if substr(`"`line'"',1,2)=="V " {
   gettoken h line : line
   gettoken val line : line
   loc line: subinstr local line " ." "", all
   if real(`"`val'"')<. & substr(`"`val'"',1,1)!="." file write `do1' _n `"cap la def `v2' `val' "`line'", modify"'
   if substr(`"`val'"',1,1)!="." local lastval `val'
   if substr(`"`val'"',1,1)=="." local lastline=trim(itrim(`"`lastline' `=substr(`"`val'"',2,.)'`line'"'))
   if substr(`"`val'"',1,1)=="." file write `do1' _n `"cap la def `v2' `lastval' "`lastline'", modify"'
   else local lastline `"`line'"'
   }
  file read `fh' line
 }
 file close `fh'
 file write `dc1' _n "}" _n
 file write `do1' _n "set more 1" _n "labelbook, problems" 
 file write `do1' _n "foreach v in " _char(96) "r(notused)" _char(39) "{"
 file write `do1' _n "cap la val " _char(96) "v" _char(39) _n "}"
 file write `do1' _n "cap la drop " _char(96) "r(notused)" _char(39)
 file write `do1' _n "exit" _n
 file close `dc1'
 di as res `"Saved dictionary file `dct'"'
 file close `do1'
 di as res `"Saved do file `do'"'
end
