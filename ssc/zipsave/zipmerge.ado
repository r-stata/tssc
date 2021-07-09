pr de zipmerge
* Merge a zipped dataset 
*! 0.1 HS, Oct 15, 2009
version 9.2
qui {

  gettoken first 0: 0
  
  while (`"`first'"' != "using" & `"`first'"' != "") {
    local vlist "`vlist' `first'"
    gettoken first 0: 0
  }
  
  if "`vlist'" != "" {
    unab vlist : `vlist'
    foreach var of local vlist {
      capture confirm variable `var'
      if _rc {
        di as err "variable `var' not found"
        exit 111
      }
    }
  }

  if (`"`first'"' != "using") {
    di as err "using required"
    exit 100
  }
  else {
    syntax anything(id="zipfilelist") [, dtafile(str asis) *]
  }
  local anything2 `"`anything'"'

  if `"`dtafile'"' ~= "" {
    _gfn, filename(`dtafile') extension(.dta)
    local dtafile = r(fileout)
    local onezipfile = 1
  }
  else {
    local onezipfile = 0
  }

  gettoken zipfile anything: anything
  while (`"`zipfile'"' ~= "") {
    _gfn, filename("`zipfile'") extension(.dta.zip)
    local zipfile = r(fileout)
    
    /* We want to break off if the file to append doesn't exist */
    
    capture confirm file `"`zipfile'"'
    if _rc ~= 0 {
      noi error _rc
    }
    gettoken zipfile anything: anything
    if `"`zipfile'"' ~= "" & `onezipfile' == 1 {
      di as err "Only one zip-archive file allowed with option dtafile"
      exit 100
    }
  }

  local fn = 0
  gettoken zipfile anything2: anything2
  while (`"`zipfile'"' ~= "") {
    _gfn, filename("`zipfile'") extension(.dta.zip)
    local zipfile = r(fileout)
    
    tempfile tmpdat`fn'
    if "`dtafile'" == "" {
      shell unzip -p "`zipfile'" > `tmpdat`fn''
    }
    else {
      shell unzip -p "`zipfile'" "`dtafile'" > `tmpdat`fn''
    }
    
    local filelist = "`filelist' `tmpdat`fn''"
    local fn = `fn' + 1
    
    gettoken zipfile anything2: anything2
  }

  merge `vlist' using `filelist', `options'
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

  
