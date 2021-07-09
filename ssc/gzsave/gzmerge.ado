pr de gzmerge
* Merge a gzipped dataset
*! 0.1 HS, Oct 13, 2009
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
    syntax anything(id="gzfilelist") [, *]
  }
  local anything2 `"`anything'"'
  
  gettoken gzfile anything: anything
  while (`"`gzfile'"' ~= "") {
    
    _gfn, filename("`gzfile'") extension(.dta.gz)
    local gzfile = r(fileout)
    
    /* We want to break off if the file to merge with doesn't exist */
      
    capture confirm file `"`gzfile'"'
    if _rc ~= 0 {
      noi error _rc
    }
    gettoken gzfile anything: anything
  }

  local fn = 0
  gettoken gzfile anything2: anything2
  while (`"`gzfile'"' ~= "") {
    
    _gfn, filename("`gzfile'") extension(.dta.gz)
    local gzfile = r(fileout)
    
    tempfile tmpdat`fn'
    shell gzip -dc "`gzfile'" > `tmpdat`fn''
    local filelist = "`filelist' `tmpdat`fn''"
    local fn = `fn' + 1
    
    gettoken gzfile anything2: anything2
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

  
