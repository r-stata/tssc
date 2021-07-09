*! version 1.1.6  26jun2002  by Marc-Andreas Muendler muendler@econ.ucsd.edu
program define est2one
    version 7
    args vecname
    local vecname= subinstr("`vecname'",",","",1)
    capture syntax newvarname [, MULTSE(string) HORIzontal CUT ]
    if _rc==100 {
       disp as err "matrix initial required" 
       exit _rc
       }
    if _rc~=0 {error _rc} 

    tempname chk
    capture local `chk' = colsof(`vecname'_tbl)
    if _rc==0 {
      disp as err "no; matrix " in yellow "`vecname'_tbl" in red " would be lost"
      exit 4 
      }
    if "`multse'" ~= "" {
        tokenize "`multse'"
        local msenum : word count `multse'
        forvalues i = 1/`msenum' {
            capture confirm integer number ``i''
            if _rc~=0 {disp as err "``i'' found where integer exected in multse()"
                       exit _rc}
            }
        }
    if "`horizontal'"=="horizontal" {local cut = "cut"}

    /* Check existence and conformability */
    local colmax = colsof(`vecname'_b)
    if "`multse'"==""  {local try    = colsof(`vecname'_se)}
    else {
      foreach mse in `multse' {
         local try    = colsof(`vecname'_se`mse')
      }
    }
    local e_exist 0
    local r_exist 0
    capture local try = colsof(`vecname'_e)
    if _rc==0 {local e_exist 1}
    capture local try = colsof(`vecname'_r)
    if _rc==0 {local r_exist 1}
    macro drop try
    if "`multse'"==""  {
        capture matrix _tmp= `vecname'_b , `vecname'_se
        if _rc==503 {
                    disp as err "conformability error in rows of `vecname'_b and `vecname'_se"
                    exit _rc
                    }
        if _rc~=0 {error _rc}
        capture matrix _tmp= `vecname'_b \ `vecname'_se
        if _rc==503 {
                    disp as err "conformability error in columns of `vecname'_b and `vecname'_se"
                    exit _rc
                    }
        if _rc~=0 {error _rc}
    }
    else {
      foreach mse in `multse' {
        capture matrix _tmp= `vecname'_b , `vecname'_se`mse'
        if _rc==503 {
                    disp as err "conformability error in rows of `vecname'_b and `vecname'_se`mse'"
                    exit _rc
                    }
        if _rc~=0 {error _rc}
        capture matrix _tmp= `vecname'_b \ `vecname'_se`mse'
        if _rc==503 {
                    disp as err "conformability error in columns of `vecname'_b and `vecname'_se`mse'"
                    exit _rc
                    }
        if _rc~=0 {error _rc}
      }
    }
    matrix drop _tmp

    /* Transpose if option horizontal is chosen */
    if "`horizontal'" == "horizontal" {
        matrix `vecname'_b = `vecname'_b '
        if "`multse'"==""  {matrix `vecname'_se = `vecname'_se '}
        else {
            foreach mse in `multse' {
                matrix `vecname'_se`mse' = `vecname'_se`mse' '
            }       
        }
    }
    
    /* Create vertical master table */
    local msenum : word count `multse'
    local msfact = `msenum'+1
    if "`multse'"==""  {matrix `vecname'_tbl = J(rowsof(`vecname'_b)*2,colsof(`vecname'_b),-999)}
    else {matrix `vecname'_tbl = J(rowsof(`vecname'_b)*`msfact',colsof(`vecname'_b),-999)}
    local colname : colfullnames `vecname'_b
    matrix colnames `vecname'_tbl = `colname'
    local coleq : coleq `vecname'_b
    matrix coleq `vecname'_tbl = `coleq'
    
    local rowname : rowfullnames `vecname'_b
    tokenize "`rowname'"
    local rowmax = rowsof(`vecname'_b)
    local colmax = colsof(`vecname'_b)
    if "`multse'"==""  {
      forvalues colj = 1/`colmax' {
        forvalues rowi = 1/`rowmax' {
            matrix `vecname'_tbl[`rowi'*2-1,`colj'] =  `vecname'_b[`rowi',`colj']
            local rowrepl = `rowi'*2-1
            matname `vecname'_tbl ``rowi'' , rows(`rowrepl') explicit
            matrix `vecname'_tbl[`rowi'*2  ,`colj'] = `vecname'_se[`rowi',`colj']
            local rowrepl = `rowi'*2
            matname `vecname'_tbl _se , rows(`rowrepl') explicit
            if `vecname'_b[`rowi',`colj']==0 & `vecname'_se[`rowi',`colj']==0 { matrix `vecname'_tbl[`rowi'*2-1,`colj'] = -999 }
            if `vecname'_se[`rowi',`colj']==0 { matrix `vecname'_tbl[`rowi'*2,`colj'] = -999 }
        }
      }
    }
    else {
      forvalues colj = 1/`colmax' {
        forvalues rowi = 1/`rowmax' {
            matrix `vecname'_tbl[`rowi'*`msfact'-`msenum',`colj'] =  `vecname'_b[`rowi',`colj']
            local rowrepl = `rowi'*`msfact'-`msenum'
            matname `vecname'_tbl ``rowi'' , rows(`rowrepl') explicit
            local msecnt = 0
            foreach mse in `multse' {
                local msecnt = `msecnt'+1
                matrix `vecname'_tbl[`rowi'*`msfact'-(`msenum'-`msecnt'),`colj'] = `vecname'_se`mse'[`rowi',`colj']
                local rowrepl = `rowi'*`msfact'-(`msenum'-`msecnt')
                matname `vecname'_tbl _se`mse' , rows(`rowrepl') explicit
                if `vecname'_b[`rowi',`colj']==0 & `vecname'_se`mse'[`rowi',`colj']==0 {
                    matrix `vecname'_tbl[`rowi'*`msfact'-`msenum',`colj'] = -999
                    local msecnt = 0
                    foreach mse in `multse' {
                        local msecnt = `msecnt'+1                
                        matrix `vecname'_tbl[`rowi'*`msfact'-(`msenum'-`msecnt'),`colj'] = -999
                        }
                }
            }
        }
      }
    }
    
    if "`cut'" ~= "cut" {
        /* Add _e and _r */
        if `e_exist' {capture matrix `vecname'_tbl = `vecname'_tbl \ `vecname'_e}
        if _rc==503 {disp as err "conformability error for `vecname'_e"
                     exit _rc}
        else {error _rc}
        if `r_exist' {capture matrix `vecname'_tbl = `vecname'_tbl \ `vecname'_r}
        if _rc==503 {disp as err "conformability error for `vecname'_r"
                     exit _rc}
        else {error _rc}
        }
    
    /* Transpose back if necessary */
    if "`horizontal'" == "horizontal" {
        matrix `vecname'_b = `vecname'_b '
        if "`multse'"==""  {matrix `vecname'_se = `vecname'_se '}
        else {
            foreach mse in `multse' {
                matrix `vecname'_se`mse' = `vecname'_se`mse' '
            }       
        }
    }
    
end
