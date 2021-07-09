pr de zipappend
* Append a zipped dataset 
*! 0.1 HS, Oct 15, 2009
version 9.2
qui {

  gettoken first 0: 0
  if (`"`first'"' != "using") {
    di as err "using required"
    exit 100
  }

  syntax anything(name=zipfile) [, dtafile(str asis) *]

  _gfn, filename(`zipfile') extension(.dta.zip)
  local zipfile = r(fileout)

  if `"`dtafile'"' ~= "" {
    _gfn, filename(`dtafile') extension(.dta)
    local dtafile = r(fileout)
  }

  /* We want to break off if the file to append doesn't exist */

  capture confirm file `"`zipfile'"'
  if _rc ~= 0 {
    noi error _rc
  }

  tempfile tmpdat

  if "`dtafile'" == "" {
    shell unzip -p "`zipfile'" > `tmpdat'
  }
  else {
    shell unzip -p "`zipfile'" "`dtafile'" > `tmpdat'
  }

  append using `tmpdat', `options'

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

  
