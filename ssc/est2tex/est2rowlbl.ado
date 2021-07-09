*! version 1.0.2  29oct2004  by Marc-Andreas Muendler muendler@ucsd.edu
capture program drop est2rowlbl
program define est2rowlbl
  version 7
  syntax [varlist] [, ADDto(string) REPLACE Saving DROPALL Path(string)]

  if "$S_OS" == "MacOS" {
    local dirsep = ":"
    }
  else {
    local dirsep = "/"
    }  
  if (substr("`path'",-1,1)~="\" & substr("`path'",-1,1)~="/" & substr("`path'",-1,1)~=":") & "`path'"~="" {
    local path="`path'"+"`dirsep'"
    }
  local file = "`path'" + "`addto'_rowlbl.dta"
  if "`replace'"~="replace" {
    confirm new file "`file'"
    }
  if "`addto'"=="" {
    disp as err "File addto expected"
    error 7
    }

  local i = 1
  local maxlen = 0
  foreach var in `varlist' {
    capture confirm variable `var'
    if _rc==0 { 
      if length("`var'") > `maxlen' {
        local maxlen = length("`var'")
        local lenvar = length("`var'")
        }
      local L`i' : variable label `var' 
      }
    if "`L`i''"=="" { 
      local L`i' = "`var'" 
      }
    local i = `i' + 1
    }

  local currN = _N
  if `currN'>0 & "`saving'"~="saving" & "`dropall'"~="dropall" {
    error 4
    exit
    }
  local saved 0
  if "`saving'"=="saving" & `currN'>0 {
    local dropall = ""
    tempfile tmp
    quietly save `tmp'
    local saved 1
    disp in green "data in memory will be removed temporarily, and restored later"
    disp in green "Press any key to continue, or Break to abort"
    more
    drop _all
    }
  if "`dropall'"=="dropall" & `currN'>0 {
    disp in green "data in memory will be dropped"
    disp in green "Press any key to continue, or Break to abort"
    more
    drop _all
    }
  capture {
    qui gen str`lenvar' _rowname = ""
    qui gen str32 _rowlbl = ""
    qui set obs `i'
    local i = 1
    foreach var in `varlist' {
      qui replace _rowname = "`var'" in `i'
      qui replace _rowlbl = "`L`i''" in `i'
      local i = `i' + 1
      }
    drop if _rowname == ""
    qui replace _rowname = subinstr(_rowname,"_","-",.)
    sort _rowname
    compress
    save "`file'", replace
    }
  if _rc==0 {
    disp in green "list of row labels " in yellow "`addto'_rowlbl.dta" in green " saved"
    }
  if `saved' {
    use `tmp', clear
    disp in green "data in memory restored"
    }
end
