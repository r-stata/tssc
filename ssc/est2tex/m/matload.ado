*! version 1.1.9  02feb2005  by Marc-Andreas Muendler: muendler@ucsd.edu
program define matload
    version 7
    args matname
    capture syntax newvarname [, Saving DROPALL Path(string) Missing(integer -999) ROWname(string) OVERwrite]
    if _rc==100 {
       disp as err "matrix and file name required" 
       exit _rc
       }
    if _rc~=0 { 
      error _rc 
      exit
      }

    global err_mssg = ""
    local rc 0
    local matname= subinstr("`matname'",",","",1)
    if "$S_OS" == "MacOS" {
      local dirsep = ":"
      }
    else {
      local dirsep = "/"
      }
    if (substr("`path'",-1,1)~="\" & substr("`path'",-1,1)~="/" & substr("`path'",-1,1)~=":") & "`path'"~="" {local path="`path'"+"`dirsep'"}
    local currN = _N
    if `currN'>0 & "`saving'"~="saving" & "`dropall'"~="dropall" {
             error 4
             exit
             }
    local file = "`path'" + "`matname'.dta"
    confirm file "`file'"
    tempname chk
    capture local `chk' = colsof(`matname')
    if _rc==0 & "`overwrite'"=="" {
               disp as err "no; matrix " in yellow "`matname'" in red " would be lost"
               exit 4 
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
    capture use "`file'", clear
        if "`rowname'"=="" {
            capture confirm variable _rowname
            if _rc~=0 {local rc = _rc
                       global err_mssg = "_rowname not found"}
            qui count
            if `r(N)'==0 {local rc = _rc
                          global err_mssg = "Data set empty or not Stata format"}
            }
        else {
            capture confirm variable `rowname'
            if _rc~=0 {local rc = _rc
                       global err_mssg = "`rowname' not found"}
            else {rename `rowname' _rowname}
            qui count
            if `r(N)'==0 {local rc = _rc
                          global err_mssg = "Data set empty or not Stata format"}
            }
        capture confirm new variable `matname'
        if _rc~=0 {local rc = _rc
                   global err_mssg = "matrix `matname' contains variable `matname'"}
    if _rc==0 {
        capture {
        local j 1
            while `j' <= _N {
                local rownm`j'=_rowname[`j']
                local j = `j'+1
            }
        drop _rowname
        }
        if _rc~=0 & "${err_mssg}" == "" {
                   local rc = _rc
                   global err_mssg = "error (before mkmat was applied)"
                   }
        if `missing'~=15127 & _N > 0 { 
            foreach var of varlist * { 
                capture qui replace `var'=`missing' if `var'==. 
                if _rc~=0 & "${err_mssg}" == "" {
                           local rc = _rc
                           global err_mssg = "file `matname'.dta contains string variables"
                           }
                }
            } 
        capture mkmat _all, matrix(`matname')
        if _rc~=0 & "${err_mssg}" == "" {
                    local rc = _rc
                    global err_mssg = "error (as mkmat was applied)"
                    }
        capture {
        local j 1
        while `j' <= _N {
            matname `matname' `rownm`j'', rows(`j') explicit
            local j = `j'+1
            }
        local cnam : colfullnames `matname'
        tokenize "`cnam'"
        local j 1
        while `j' <= colsof(`matname') {
            local `j'=subinword("``j''","__cons","_cons",1)
            local `j'=subinword("``j''","__b","_b",1)
            local `j'=subinword("``j''","__coef","_coef",1)
            matname `matname' ``j'' , columns(`j') explicit
          local j=`j'+1
        }
        drop _all
        }
    }
    if _rc~=0 & "${err_mssg}" == "" {
                local rc = _rc
                global err_mssg = "error (after mkmat was applied)"
                }
    if _rc==0 & `rc'==0 {disp in green "matrix " in yellow "`matname'" in green " loaded"}
    if `saved' {use `tmp', clear
                disp in green "data in memory restored"
                }
    if `rc'~=0 {
                disp as err "${err_mssg}"
                error `rc'
                }
    global err_mssg = ""
    exit `rc'
end
