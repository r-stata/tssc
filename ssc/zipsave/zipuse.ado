pr de zipuse
* Open a zipped dataset 
*! 0.1 HS, Jan 6, 2006
*! 0.2 HS, May 4, 2006 Improved filename allocation
*! 0.3 HS, Apr 2, 2008 Support for archives with multiple files
*! 0.4 HS, Sep 7, 2009 Allow filenames enclosed in quotes
*! 0.5 HS, Oct 16, 2009 Allow alternative syntax with using and subsets
*! 0.6 HS, Sep 12, 2011 Bug fix to allow many using variables
version 9.2

local allargs `"`0'"'

gettoken first allargs: allargs
while  (`"`first'"' != "using" & `"`first'"' != "") {
  gettoken first allargs: allargs
}
if `"`first'"' == "using" {
  gettoken first 0: 0
  
  while (`"`first'"' != "using" & `"`first'"' != "") {
    local initlist "`initlist' `first'"
    gettoken first 0: 0
  }
  local usind = "using"
}

syntax anything(name=zipfile) [, clear dtafile(str asis) *]
qui {

  _gfn, filename(`zipfile') extension(.dta.zip)
  local zipfile = r(fileout)

  if `"`dtafile'"' ~= "" {
    _gfn, filename(`dtafile') extension(.dta)
    local dtafile = r(fileout)
  }

  _ok2use, filename(`zipfile') `clear'

  tempfile tmpdat

  if "`dtafile'" == "" {
    shell unzip -p "`zipfile'" > `tmpdat'
  }
  else {
    shell unzip -p "`zipfile'" "`dtafile'" > `tmpdat'
  }

  use `initlist' `usind' `tmpdat', clear `options'
  if "`dtafile'" == "" {
    global S_FN = "`zipfile'"
  }
  else {
    global S_FN = "`dtafile'"
  }

}
end
* Create filename to use with compressed save/use (gzsave and zipsave)
*! 0.1 HS, Oct 1, 2009
pr de _gfn, rclass
version 9.2
syntax , filename(string asis) extension(string)

* Only check for punctuation in filename, not in path
_getfilename `filename'

* Remove opening and closing quotes, if any, from filename
if strpos(`"`filename'"', char(34)) ~= 0 {
  local filename = subinstr(`filename', char(34), "", .)
}

if index(r(filename), ".") == 0 {
  local filename "`filename'`extension'"
}
return local fileout `"`filename'"'


end

  
* OK to open filename with compressed use? (gzsave and zipsave)
*! 0.1 HS, Oct 1, 2009
pr de _ok2use
version 9.2
syntax , filename(string asis) [clear]

  /* We want to break off if the file to use doesn't exist */

  capture confirm file `"`filename'"'
  if _rc ~= 0 {
    noi error _rc
  }

  /* We want to break off before decompression if data have changed and thus
  the subsequent -use- would be disallowed without a -clear- */

  if "`clear'" == "" {
    if c(changed) == 1 {
      noi error 4
    }
  }
end

  
