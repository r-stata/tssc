*! 1.1 11 Nov 2010 Austin Nichols
*! png2rtf 1.0 program to include a PNG file in an RTF doc
* 1.1 11 Nov 2010 changed append method, fixed needing replace to write header, check for graph option to avoid mata error
* 1.0 14 Oct 2010 first public version
prog png2rtf
version 11
syntax using/ [, author(string) company(string) Title(string) Width(int 548) Height(int 753) Graph(string) Append replace]
cap conf new file `"`graph'"'
if _rc==7 {
  di as err `"Graph option not specified"'
  error 601
  }
if _rc==0 {
  di as err `"Graph `graph' not found"'
  error 601
  }
cap conf new file `"`using'"'
if _rc==0 & "`append'"!="" {
  di as err `"File `using' not found, no append option necessary"'
  error 601
  }
foreach v in author company title {
 if `"``v''"'=="" loc `v' "."
 }
tempname i o a
if "`append'"!="" loc replace "read"
file open `o' using `"`using'"', write `replace' 
file open `a' using `"`using'"', read
if "`append'"!="" {
 file seek `o' eof
 file seek `o' query
 loc e=r(loc)
 file seek `o' `=`e'-1'
 file read `o' c1
 if "`force'"=="" {
  cap assert `"`c1'"'=="}"
  if _rc==0 loc loc=`e'-1
  if _rc {
   file seek `o' `=`e'-2'
   file read `o' c2
   cap assert `"`c2'"'=="}"
   if _rc==0 loc loc=`e'-2
   if _rc {
    file seek `o' `=`e'-3'
    file read `o' c3
    cap assert `"`c3'"'=="}"
    if _rc==0 loc loc=`e'-3
    if _rc {
     di as err `"File `using' does not end in a curly bracket }"'
     di as err "Not an RTF file?  Use option" as txt " force" as err " to force overwriting last character"
     error 603
     }
    }
   }
  }
 file seek `o' `loc'
* file write `o' "}" _n
 }
if "`append'"=="" {
loc hr=trim(substr(c(current_time),1,2))
loc min=trim(substr(c(current_time),4,2))
loc d=trim(substr(c(current_date),1,2))
loc y=trim(substr(c(current_date),8,4))
loc m=(strpos(c(Mons),substr(c(current_date),4,3))-1)/4+1
file write `o'  "{\rtf1\ansi\deff0 {\fonttbl{\f0\fnil Times New Roman;}}"
file write `o'  _n "{\info {\author `author'}{\company `company'}{\title `title'}{\creatim\yr`y'\mo`m'\dy`d'\hr`hr'\min`min'}}"
file write `o'  _n "\deflang1033\plain\fs24\margl720\margr720\margt720\margb720"
file write `o'  _n "{\footer\pard\qc\plain\f0\fs24\chpgn\par}"
}
file write `o'  _n "{\pict\pngblip\picw`width'\pich`height'" _n
file close `o'
mata:hexconv(`"`graph'"',`"`using'"')
file open  `o' using `"`using'"', write append
file write `o'  _n "}" _n "}" _n
file close `o'
di as txt `"File written to {browse `using'}"'
end
version 11
mata:
void hexconv(string scalar fread, string scalar fwrite)
 {
 fr = fopen(fread, "r")
 fa = fopen(fwrite, "a")
 i=0
 while ((c=fread(fr,1))!=J(0,0,"")) {
  fwrite(fa,(substr("0"+inbase(16,ascii(c)),strlen("0"+inbase(16,ascii(c)))-1,.)))
  i++
  if (mod(i,64)==0) {
   fput(fa,"")
   }
  }
 fclose(fr)
 fclose(fa)
 }
end
