*! version 1.1.7  24oct2004  by Marc-Andreas Muendler: muendler@ucsd.edu
program define matsave
     version 7
     global err_mssg = ""
     local rc 0
     args matname
     capture syntax newvarname [, REPLACE Saving DROPALL Path(string) Type(string)]
     if _rc==100 {
        disp as err "matrix name required" 
        exit _rc}
     if _rc~=0 {error _rc
                exit}
     local matname= subinstr("`matname'",",","",1)
     if "$S_OS" == "MacOS" {
       local dirsep = ":"
       }
     else {
       local dirsep = "/"
       }  
     if (substr("`path'",-1,1)~="\" & substr("`path'",-1,1)~="/" & substr("`path'",-1,1)~=":") & "`path'"~="" {
       local path="`path'"+"`dirsep'"
       }
     if lower("`type'")~="" & lower("`type'")~="byte" & lower("`type'")~="int" & lower("`type'")~="long" & lower("`type'")~="float" & lower("`type'")~="double" {
       di in green "storage type reset to " in yellow "float"
       local type = "float"
       }
     tempname tst
     local tst = colsof(`matname')
     local currN = _N
     if `currN'>0 & "`saving'"~="saving" & "`dropall'"~="dropall" {
       error 4
       exit
       }
     local file = "`path'" + "`matname'.dta"
     if "`replace'"~="replace" {
       confirm new file "`file'"
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
     local chgflg =0
     local cnam : colfullnames `matname'
     tokenize "`cnam'"
     local i 1
     while `i' <= colsof(`matname') {
         local `i' = subinstr("``i''",":","_",.)
         if "``i''" == "_cons" | "``i''" == "_b" | "``i''" == "_coef" {
            local chgflg 1
            local `i' = "_" + "``i''"
            }
         matname `matname' :``i'', columns(`i') explicit
         local i = `i' + 1   
         }  
     local dosv=1
     * set more off
     }
     if _rc~=0 {local rc = _rc
                global err_mssg = "error (before svmat was applied)"}
     capture svmat `type' `matname', names(col)
     if _rc~=0 & "${err_mssg}" == "" {
                local rc = _rc
                global err_mssg = "error (as svmat was applied)"}
     capture {
     * set more on
     local i 1
     if `chgflg' {
         while `i' <= colsof(`matname') {
             matname `matname' ``i'', columns(`i') explicit
             local i = `i' +1   
             }  
     }  
     local rnam : rowfullnames `matname'
     tokenize "`rnam'"
     local maxlen= 0
     local j 1
     while `j' <= rowsof(`matname') {
         if length("``j''") > `maxlen' {local maxlen = length("``j''")}
         local j=`j'+1
         }
     if `maxlen' >80 {local maxlen = 80}
     quietly gen str`maxlen' _rowname=""
     local j 1
     while `j' <= rowsof(`matname') {
         quietly replace _rowname = "``j''" in `j'
         local j=`j'+1
         }
     order _rowname
     if "`replace'"=="replace" {save "`file'", replace}
     else {save "`file'"}
     }
     if _rc~=0 & "${err_mssg}" == "" {
                local rc = _rc
                global err_mssg = "error (after svmat was applied)"}
     if _rc==0 & `rc'==0 {disp in green "matrix " in yellow "`matname'" in green " saved"}
     if `saved' {use `tmp', clear
                 disp in green "data in memory restored"}
     if `rc' == 110 {
        disp as error "new variables cannot be uniquely named or already defined"
        error `rc'
        exit
     }
     if `rc'~=0 {disp as err "${err_mssg}"}
     global err_mssg = ""
     error `rc'
end
