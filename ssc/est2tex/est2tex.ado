*! version 2.1.5  13dec2004  by Marc-Andreas Muendler <muendler@ucsd.edu> (MAM)
*! options label and preserve added  16jan2002  by Mark Holmes <mark_holmes@unc.edu> (MH)
program define est2tex
    version 7
    args vecname

    capture syntax newvarname [, REPLACE DROPALL PREServe Path(string) MULTSE(string) Mark(string) LEVels(string) MARKTBL PREcision(real 0) DIGits(integer 3) FLExible(integer 2) FANcy HORIzontal CUT LABel COLLABels(string) EXtracols(string) DOTs SUPPRESS PLAIN(string) READY LEADZERO THOUSEP]
    if _rc==100 {
       disp as err "matrix initial required" 
       exit _rc
       }
    if _rc~=0 {error _rc} 

    local vecname= subinstr("`vecname'",",","",1)
    if "$S_OS" == "MacOS" {
      local dirsep = ":"
      }
    else {
      local dirsep = "/"
      }
    if (substr("`path'",-1,1)~="\" & substr("`path'",-1,1)~="/" & substr("`path'",-1,1)~=":") & "`path'"~="" {
      local path="`path'" + "`dirsep'"
      }
    local file1= "`path'" + "`vecname'_tbl.dta"
    if "`plain'"==""    {
      local file2= "`path'" + "`vecname'.tex"
      }
    if "`plain'"=="csv" {
      local file2= "`path'" + "`vecname'.csv"
      }
    if "`plain'"=="tab" {
      local file2= "`path'" + "`vecname'.txt"
      }
    if "`replace'"~="replace" {
      confirm new file "`file1'"
      confirm new file "`file2'"
      }
    if `digits'~=float(0) & `precision'~=float(0) {
      disp as err "digits() and precision() invalid"
      exit 198
      }
    local positse = -3
    local linesup = 1
    if "`multse'"~="" & "`mark'"~="" {
        local positse = -4
        tokenize "`mark'"
        local markse = "`2'"
        tokenize "`multse'"
        local maxx = wordcount("`multse'")
        local linesup = 0
        forvalues x = 1/`maxx' {
          if ``x'' == `markse' {
            local linesup = `x'
            }
          }
        if real("`markse'") == . {
            disp as err "multse() and mark() without reference invalid"
            exit 198}
        }
    if "`ready'"=="ready" & "`mark'"~="" {
        tokenize "`mark'"
        local markse = "`2'"
        if real("`markse'") ~= . {
            disp as err "ready and mark() with reference invalid"
            exit 198}
        disp in blu "mark() option will not work properly if `vecname'_tbl contains multiple se"
        more
        }
    if "`levels'"=="" {
        if $S_level>99.9                { local levels = "99 $S_level 99.99" }
        if $S_level>99 & $S_level<=99.9 { local levels = "99 $S_level 99.9" }
        if $S_level>98 & $S_level<=99   { local levels = "95 $S_level 99.5" }
        if $S_level>95 & $S_level<=98   { local levels = "95 $S_level 99" }
        if $S_level>90 & $S_level<=95   { local levels = "90 $S_level 99" }
        if $S_level<=90                 { local levels = "$S_level 90 95" }
        }
    tokenize "`levels'" 
    forvalues i = 1/3 { 
        capture confirm number ``i''
        if _rc~=0 { if "``i''"=="" { local `i' = "no entry" }
                    disp as err "levels() invalid. ``i'' found where number expected" 
                    exit _rc }
        if ``i''<=0 | ``i''>=100 {
                    disp as err "levels() invalid. ``i'' found where number between 0 and 100 expected" 
                    exit 7 }
        local lvl`i' = (100-``i'')/200 
        }
    if "`ready'"=="ready" & "`multse'"~="" {
        disp as err "ready and multse() invalid"
        exit 198
        }
    if `precision'~=0 {
        local precision = `precision' - int(`precision')
        local digits = length(string(`precision'))-1
        }
    if `digits'~=0 {
      local precision = 10^(-`digits')
      }
    local addzeros = ""
    forvalues i = 1/`digits' {
      local addzeros = "`addzeros'" + "0"
      }
    if substr("`mark'",1,5)~="stars" & substr("`mark'",1,5)~="starb" & substr("`mark'",1,2)~="it" { local mark = "" }
    local toknum 0
    if "`extracols'" ~= "" {
        tokenize "`extracols'"
        local toknum : word count `extracols'
        forvalues i = 1/`toknum' {
            capture confirm integer number ``i''
            if _rc~=0 | ``i''<=0 {
                       disp as err "``i'' found where positive integer expected in extracols()"
                       capture confirm integer number .5
                       exit _rc
                       }
        }
    }
    if "`multse'" ~= "" {
        tokenize "`multse'"
        local msenum : word count `multse'
        forvalues i = 1/`msenum' {
            if ``i'' > 9 | ``i'' < 1 {
              local `i' = ``i'' + .5
              }
            capture confirm integer number ``i''
            if _rc~=0 {
              local `i' = int(``i'')
              disp as err "``i'' found where single-digit integer expected in multse()"
              exit _rc
              }
        }
    }
    if "`plain'"~="" & "`plain'"~="tab" & "`plain'"~="csv" {
        disp as err "option plain allows tab or csv"
        exit 198
        }
    if "`leadzero'"~="" & "`fancy'"~="fancy" {
        disp as err "option leadzero not allowed without option fancy"
        exit 198
        }
    if "`thousep'"~="" & "`fancy'"~="fancy" {
        disp as err "option thousep not allowed without option fancy"
        exit 198
        }
    if "`replace'"=="replace" & "`ready'"~="ready" {
      capture matrix drop `vecname'_tbl
      }
    if "`horizontal'" == "horizontal" | "`ready'"=="ready" { 
      local label = "" 
      local collabels = ""
      } 
    if "`label'"=="label" {   /* MH 16jan2002, adapted: MAM 26jun2002 */
        local i = 1
        local vars : rownames `vecname'_b
        foreach var in `vars' {
            capture confirm variable `var'
            if _rc==0 { 
              local L`i' : variable label `var' 
              }
            if "`L`i''"=="" { 
              local L`i' = "`var'" 
              }
            local i = `i'+1
            }
        }
    if "`collabels'"~="" {
        tokenize `collabels'
        local colmax = colsof(`vecname'_b)
        forvalues i = 1/`colmax' {
            local labl`i' = ""
            local labl`i' = "``i''"
            if subinword("`collabels'","``i''","",.)~=subinword("`collabels'","``i''","",1) {
                disp as err "names in collabels() are not unique"
                error 110
                }
            }
        }
    if "`preserve'"=="preserve" {   /* MH 16jan2002 */
        local dropall "dropall"
        preserve
        }
    if "`dropall'"=="dropall" {
      drop _all
      } 
    if _N>0 & "`preserve'"~="preserve" {
      error 4
      }
    if _N>0 {
      qui drop _all
      }
    if "`horizontal'"=="horizontal" {
      local cut = "cut"
      }


    /* Start working */

    local lblfile = "`path'" + "`vecname'_rowlbl" + ".dta"
    capture use "`lblfile'"
    if _rc==0 {
      local label = "label"
      local lblnum = _N
      forvalues l = 1/`lblnum' {
        local V`l' = _rowname[`l']
        local L`l' = _rowlbl[`l']
        if "`L`l''"== "" { 
          local L`l' = "`V`l''" 
          }
        }
      qui drop _all
      }
    if "`ready'"~="ready" { 
      est2one `vecname', `cut' `horizontal' multse(`multse') 
      }
    local colmax = colsof(`vecname'_tbl)
    local colnm : colfullnames `vecname'_tbl
    tokenize `colnm'
    forvalues i = 1/`colmax' {
      if subinword("`colnm'","``i''","",.)~=subinword("`colnm'","``i''","",1) {
        disp as err "columns of `vecname' are not uniquely named"
        error 110
        }
      }
  
    /* Create table of significance levels */

    if substr("`mark'",1,2)=="it" | substr("`mark'",1,4)=="star" { 
        local msenum : word count `multse'
        local msfact = `msenum'+1
        if "`ready'"~="ready" {
            if "`horizontal'"~="horizontal" {
                local rowsz = rowsof(`vecname'_b)
                local colsz = colsof(`vecname'_b)
            }
            else {
                local rowsz = colsof(`vecname'_b)
                local colsz = rowsof(`vecname'_b)          
            }
            local rowmax = `rowsz'
            local colmax = `colsz'
            }
        else {
            local rowsz = rowsof(`vecname'_tbl)
            local colsz = colsof(`vecname'_tbl)
            local colmax = `colsz'
            local rowmax = 0
            local rowload : rownames `vecname'_tbl
            tokenize "`rowload'"
            forvalues i = 1/`rowsz' {
                if substr("``i''",-3,3) == "_se" {local rowmax = `rowmax' + 1}
                }
            }
        if "`marktbl'" == "" {tempname t_stars}
        else {local t_stars = "t_stars"}
        if "`multse'"==""  {matrix `t_stars' = J(`rowsz'*2,`colsz',0)}
        else {matrix `t_stars' = J(`rowsz'*`msfact',`colsz',0)}
        local colnm : colfullnames `vecname'_tbl
        matrix colnames `t_stars' = `colnm'
        local rowsstar = min(rowsof(`t_stars'),rowsof(`vecname'_tbl))
        tempname justrows
        matrix `justrows' = `vecname'_tbl[1..`rowsstar',1]
        local rownm : rowfullnames `justrows'
        matrix rownames `t_stars' = `rownm'
        if "`ready'"~="ready" {
            if "`multse'"==""  {
                if "`horizontal'" == "horizontal" {matrix `vecname'_b  = `vecname'_b '
                                                   matrix `vecname'_se = `vecname'_se'}
                forvalues colj = 1/`colmax' {
                  forvalues rowi = 1/`rowmax' {
                    if abs(`vecname'_b[`rowi',`colj']/`vecname'_se[`rowi',`colj']) > abs(invnorm(`lvl1')) & abs(`vecname'_b[`rowi',`colj']/`vecname'_se[`rowi',`colj'])~=. {matrix `t_stars'[`rowi'*2-1,`colj']=1}
                    if abs(`vecname'_b[`rowi',`colj']/`vecname'_se[`rowi',`colj']) > abs(invnorm(`lvl2')) & abs(`vecname'_b[`rowi',`colj']/`vecname'_se[`rowi',`colj'])~=. {matrix `t_stars'[`rowi'*2-1,`colj']=2}
                    if abs(`vecname'_b[`rowi',`colj']/`vecname'_se[`rowi',`colj']) > abs(invnorm(`lvl3')) & abs(`vecname'_b[`rowi',`colj']/`vecname'_se[`rowi',`colj'])~=. {matrix `t_stars'[`rowi'*2-1,`colj']=3}
                    if `vecname'_se[`rowi',`colj']==-999 & substr("`mark'",1,2)=="it" {matrix `t_stars'[`rowi'*2-1,`colj']=9}
                  }
                }
                if "`horizontal'" == "horizontal" {matrix `vecname'_b  = `vecname'_b '
                                                   matrix `vecname'_se = `vecname'_se'}
            }
            else {
                if "`horizontal'" == "horizontal" {matrix `vecname'_b          = `vecname'_b '
                                                   matrix `vecname'_se`markse' = `vecname'_se'`markse'}
                forvalues colj = 1/`colmax' {
                  forvalues rowi = 1/`rowmax' {
                    if abs(`vecname'_b[`rowi',`colj']/`vecname'_se`markse'[`rowi',`colj']) > abs(invnorm(`lvl1')) & abs(`vecname'_b[`rowi',`colj']/`vecname'_se`markse'[`rowi',`colj'])~=. {matrix `t_stars'[`rowi'*`msfact'-`msenum',`colj']=1}
                    if abs(`vecname'_b[`rowi',`colj']/`vecname'_se`markse'[`rowi',`colj']) > abs(invnorm(`lvl2')) & abs(`vecname'_b[`rowi',`colj']/`vecname'_se`markse'[`rowi',`colj'])~=. {matrix `t_stars'[`rowi'*`msfact'-`msenum',`colj']=2}
                    if abs(`vecname'_b[`rowi',`colj']/`vecname'_se`markse'[`rowi',`colj']) > abs(invnorm(`lvl3')) & abs(`vecname'_b[`rowi',`colj']/`vecname'_se`markse'[`rowi',`colj'])~=. {matrix `t_stars'[`rowi'*`msfact'-`msenum',`colj']=3}
                    if `vecname'_se`markse'[`rowi',`colj']==-999 & substr("`mark'",1,2)=="it" {matrix `t_stars'[`rowi'*`msfact'-`msenum',`colj']=9}
                  }
                }           
                if "`horizontal'" == "horizontal" {matrix `vecname'_b          = `vecname'_b '
                                                   matrix `vecname'_se`markse' = `vecname'_se'`markse'}
            }
        }
        else {
            forvalues colj = 1/`colmax' {
              forvalues rowi = 1/`rowmax' {
                if abs(`vecname'_tbl[(`rowi')*2-1,`colj']/`vecname'_tbl[(`rowi')*2,`colj']) > abs(invnorm(`lvl1')) & abs(`vecname'_tbl[(`rowi')*2-1,`colj']/`vecname'_tbl[(`rowi')*2,`colj'])~=. {matrix `t_stars'[`rowi'*2-1,`colj']=1}
                if abs(`vecname'_tbl[(`rowi')*2-1,`colj']/`vecname'_tbl[(`rowi')*2,`colj']) > abs(invnorm(`lvl2')) & abs(`vecname'_tbl[(`rowi')*2-1,`colj']/`vecname'_tbl[(`rowi')*2,`colj'])~=. {matrix `t_stars'[`rowi'*2-1,`colj']=2}
                if abs(`vecname'_tbl[(`rowi')*2-1,`colj']/`vecname'_tbl[(`rowi')*2,`colj']) > abs(invnorm(`lvl3')) & abs(`vecname'_tbl[(`rowi')*2-1,`colj']/`vecname'_tbl[(`rowi')*2,`colj'])~=. {matrix `t_stars'[`rowi'*2-1,`colj']=3}
                if `vecname'_tbl[(`rowi')*2,`colj']==-999 & substr("`mark'",1,2)=="it" {matrix `t_stars'[`rowi'*2-1,`colj']=9}
              }
            }
            local starle = `rowmax'*2
            matrix `t_stars' = `t_stars'[1..`starle',1..`colmax']
        }
    }


    /* Transformation of master table to TeX */
    if `precision'~=0 & `precision' < .000001 {
      qui matsave `vecname'_tbl, path("`path'") t(double) `replace'
      }
    else {
      qui matsave `vecname'_tbl, path("`path'") t(float) `replace'
      }
    disp in blue "matrix " in yellow "`file1'" in blue " saved"
    local colname : colfullnames `vecname'_tbl
    local colmax = colsof(`vecname'_tbl)
    tokenize "`colname'"
    if `precision' ~= 0 {
        forvalues vari = 1/`colmax' {
        local strlen = `digits' + 2
          if `flexible' == 0 {
            qui gen str`strlen' s_``vari'' = ""
            qui replace ``vari'' = sign(``vari'') * int( (1/`precision') * abs(``vari'') + .5) * `precision' if ``vari''~=-999
            }
          else {
           if `flexible' == 1 {
            local strlen = `strlen' + 1
            qui gen str`strlen' s_``vari'' = ""
            qui replace ``vari'' = sign(``vari'') * int( (1/`precision') * abs(``vari'') + .5) * `precision'       if ``vari''~=-999 & abs(``vari'') >= `precision'
            qui replace ``vari'' = sign(``vari'') * int( (10/`precision') * abs(``vari'') + .5) * `precision'/10   if ``vari''~=-999 & abs(``vari'') < `precision' & abs(``vari'') >=`precision'/10
           }
           else {
            local strlen = `strlen' + 2
            qui gen str`strlen' s_``vari'' = ""
            qui replace ``vari'' = sign(``vari'') * int( (1/`precision') * abs(``vari'') + .5) * `precision'       if ``vari''~=-999 & abs(``vari'') >= `precision'
            qui replace ``vari'' = sign(``vari'') * int( (10/`precision') * abs(``vari'') + .5) * `precision'/10   if ``vari''~=-999 & abs(``vari'') < `precision'     & abs(``vari'') >= `precision'/10
            qui replace ``vari'' = sign(``vari'') * int( (100/`precision') * abs(``vari'') + .5) * `precision'/100 if ``vari''~=-999 & abs(``vari'') < `precision'/10 & abs(``vari'') >= `precision'/100
           }
          }
        if "`dots'"=="dots" {
          qui replace s_``vari'' = "." if ``vari''==-999 & substr(trim(_rowname),`positse',3)~="_se" & substr(trim(_rowname),-4,4)~="_se`mse'"
          }
        else {
          qui replace s_``vari'' = "" if ``vari''==-999
          }
        qui replace s_``vari'' = string(``vari'') if ``vari''~=-999
        if "`fancy'" == "fancy" & "`plain'"=="" {
          qui replace s_``vari'' = string(``vari'') + "00000" if ( ( ( length(s_``vari'') - index(s_``vari'',".") ) == `digits' - 5 & index(s_``vari'',".")~=0 ) | ( ( length(s_``vari'') - index(s_``vari'',".") ) == `digits' - 5 & length(s_``vari'')>1 & substr(s_``vari'',1,1)=="." ) ) & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r("
          qui replace s_``vari'' = string(``vari'') + "0000" if ( ( ( length(s_``vari'') - index(s_``vari'',".") ) == `digits' - 4 & index(s_``vari'',".")~=0 ) | ( ( length(s_``vari'') - index(s_``vari'',".") ) == `digits' - 4 & length(s_``vari'')>1 & substr(s_``vari'',1,1)=="." ) ) & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r("
          qui replace s_``vari'' = string(``vari'') + "000" if ( ( ( length(s_``vari'') - index(s_``vari'',".") ) == `digits' - 3 & index(s_``vari'',".")~=0 ) | ( ( length(s_``vari'') - index(s_``vari'',".") ) == `digits' - 3 & length(s_``vari'')>1 & substr(s_``vari'',1,1)=="." ) ) & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r("
          qui replace s_``vari'' = string(``vari'') + "00" if ( ( ( length(s_``vari'') - index(s_``vari'',".") ) == `digits' - 2 & index(s_``vari'',".")~=0 ) | ( ( length(s_``vari'') - index(s_``vari'',".") ) == `digits' - 2 & length(s_``vari'')>1 & substr(s_``vari'',1,1)=="." ) ) & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r("
          qui replace s_``vari'' = string(``vari'') + "0" if ( ( ( length(s_``vari'') - index(s_``vari'',".") ) == `digits' - 1 & index(s_``vari'',".")~=0 ) | ( ( length(s_``vari'') - index(s_``vari'',".") ) == `digits' - 1 & length(s_``vari'')>1 & substr(s_``vari'',1,1)=="." ) ) & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r("
          qui count if index(string(``vari''),".")~=0
          if `r(N)'>0 {
            qui replace s_``vari'' = string(``vari'') + ".`addzeros'" if index(s_``vari'',".")==0 & ``vari''~=-999 & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r(" & substr(_rowname,-4,2)~="e(" & substr(_rowname,-4,2)~="r("
            qui replace s_``vari'' = substr(s_``vari'',2,length(s_``vari'')) if substr(s_``vari'',1,2)=="0." 
            }
          if "`thousep'" == "thousep" {
            qui count if index(string(``vari''),".")~=0
            if `r(N)'==0 {
              qui replace s_``vari'' = substr(string(``vari''),-length(string(``vari'')),mod(length(string(``vari'')),3)) + "," + substr(string(``vari''),-12,3) + "," + substr(string(``vari''),-9,3) + "," + substr(string(``vari''),-6,3) + "," + substr(string(``vari''),-3,3) if index(s_``vari'',".")==0 & ``vari''~=-999 & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r(" & length(string(``vari''))<15 & length(string(``vari''))>12
              qui replace s_``vari'' = substr(string(``vari''),-12,3) + "," + substr(string(``vari''),-9,3) + "," + substr(string(``vari''),-6,3) + "," + substr(string(``vari''),-3,3) if index(s_``vari'',".")==0 & ``vari''~=-999  & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r(" & length(string(``vari''))==12
              qui replace s_``vari'' = substr(string(``vari''),-length(string(``vari'')),mod(length(string(``vari'')),3)) + "," + substr(string(``vari''),-9,3) + "," + substr(string(``vari''),-6,3) + "," + substr(string(``vari''),-3,3) if index(s_``vari'',".")==0 & ``vari''~=-999  & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r(" & length(string(``vari''))<12 & length(string(``vari''))>9
              qui replace s_``vari'' = substr(string(``vari''),-9,3) + "," + substr(string(``vari''),-6,3) + "," + substr(string(``vari''),-3,3) if index(s_``vari'',".")==0 & ``vari''~=-999  & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r(" & length(string(``vari''))==9
              qui replace s_``vari'' = substr(string(``vari''),-length(string(``vari'')),mod(length(string(``vari'')),3)) + "," + substr(string(``vari''),-6,3) + "," + substr(string(``vari''),-3,3) if index(s_``vari'',".")==0 & ``vari''~=-999  & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r(" & length(string(``vari''))<9 & length(string(``vari''))>6
              qui replace s_``vari'' = substr(string(``vari''),-6,3) + "," + substr(string(``vari''),-3,3) if index(s_``vari'',".")==0 & ``vari''~=-999  & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r(" & length(string(``vari''))==6
              qui replace s_``vari'' = substr(string(``vari''),-length(string(``vari'')),mod(length(string(``vari'')),3)) + "," + substr(string(``vari''),-3,3) if index(s_``vari'',".")==0 & ``vari''~=-999  & substr(_rowname,1,2)~="e(" & substr(_rowname,1,2)~="r(" & length(string(``vari''))<6 & length(string(``vari''))>3
              }
            }
        }
        if "`leadzero'" == "leadzero" & "`plain'"=="" {
          qui replace s_``vari'' = "0" + string(``vari'') if length(s_``vari'')>1 & substr(s_``vari'',1,1)=="."
          }
        qui drop ``vari''
        }
    }
    else {
        local strlen = 9
        forvalues vari = 1/`colmax' {
            qui gen str`strlen' s_``vari'' = ""
            if "`dots'"=="dots" { qui replace s_``vari'' = "." if ``vari''==-999 }
            else { qui replace s_``vari'' = "" if ``vari''==-999 }
        qui drop ``vari''
        }
    }
    
    local incr = "r"
    local explic = "l"
    
    forvalues vari = 1/`colmax' {
        qui gen str7 _stars`vari' = ""
        }
    if substr("`mark'",1,4)=="star" | substr("`mark'",1,2)=="it" { svmat byte `t_stars', names(col) }
    if substr("`mark'",1,4)=="star" { local incr = "c" }
    if substr("`mark'",1,2)=="it" & "`plain'"=="" {
      forvalues vari = 1/`colmax' {
        qui replace s_``vari'' = "\it " + s_``vari'' if ``vari''==0 & substr(trim(_rowname),`positse',3)~="_se" & ( s_``vari''~="." & s_``vari''~="" )
        }  
      }
    if substr("`mark'",1,5) == "stars" {
      forvalues vari = 1/`colmax' {
        qui replace _stars`vari' = "$^{*}$" if ``vari''[_n-`linesup']>=1 & substr(trim(_rowname),`positse',3)=="_se" & _n-`linesup'>0
        if `lvl2' < `lvl1' { qui replace _stars`vari' = "$^{**}$"  if ``vari''[_n-`linesup']>=2 & substr(trim(_rowname),`positse',3)=="_se" & _n-`linesup'>0 }
        if `lvl3' < `lvl1' & `lvl3' < `lvl2' { qui replace _stars`vari' = "$^{***}$" if ``vari''[_n-`linesup']>=3 & substr(trim(_rowname),`positse',3)=="_se" & _n-`linesup'>0 }
        }
      }
    if substr("`mark'",1,5) == "starb" {
      forvalues vari = 1/`colmax' {
        qui replace _stars`vari' = "$^{*}$" if ``vari''>=1 & substr(trim(_rowname),`positse',3)~="_se"
        if `lvl2' < `lvl1' { qui replace _stars`vari' = "$^{**}$"  if ``vari''>=2 & substr(trim(_rowname),`positse',3)~="_se" }
        if `lvl3' < `lvl1' & `lvl3' < `lvl2' { qui replace _stars`vari' = "$^{***}$" if ``vari''>=3 & substr(trim(_rowname),`positse',3)~="_se" }
        qui replace s_``vari'' = s_``vari'' + _stars`vari'  if substr(trim(_rowname),`positse',3)~="_se" & substr(trim(_rowname[_n+1]),`positse',3)=="_se" & ( s_``vari''~="." & s_``vari''~="" )
        }
      }
    if "`plain'"=="" {
      forvalues vari = 1/`colmax' {
        if "`multse'"=="" {qui replace s_``vari'' = "\raisebox{.7ex}[0pt]{\scriptsize (" + s_``vari'' + ")" + _stars`vari' + "}" if substr(trim(_rowname),`positse',3)=="_se" & ( s_``vari''~="." & s_``vari''~="" )}
        else {
            local msi = 0
            foreach mse in `multse' {
                local msi = `msi' + 1
                local raise = .7 + 1.0*(`msi'-1)
                qui replace s_``vari'' = "\raisebox{`raise'ex}[0pt]{\scriptsize (" + s_``vari'' + ")" + _stars`vari' + "}" if substr(trim(_rowname),-4,4)=="_se`mse'" & ( s_``vari''~="." & s_``vari''~="" )
            }        
        }
      }
      forvalues vari = 1/`colmax' {
          if `vari' < `colmax'  {qui replace s_``vari'' = s_``vari'' + " &"}
          if `vari' == `colmax' {qui replace s_``vari'' = s_``vari'' + " \" + "\" if _n < _N}
          local explic = "`explic'" + "`incr'"
          if substr("`mark'",1,4)=="star" | substr("`mark'",1,2)=="it" {qui drop ``vari''}
      }
      foreach vari in `extracols' {
          if `vari' < `colmax'  {qui replace s_``vari'' = s_``vari'' + "&"}
          local explic = "`explic'" + "`incr'"
      }
    } 
    else {  /* if option plain is chosen: */
      forvalues vari = 1/`colmax' {
        if "`multse'"=="" {qui replace s_``vari'' = "(" + s_``vari'' + ")" + _stars`vari' if substr(trim(_rowname),`positse',3)=="_se" & ( s_``vari''~="." & s_``vari''~="" )}
        else {
            foreach mse in `multse' {
                qui replace s_``vari'' = "(" + s_``vari'' + ")" + _stars`vari' if substr(trim(_rowname),-4,4)=="_se`mse'" & ( s_``vari''~="." & s_``vari''~="" )
            }        
        }
      }
    }
    forvalues vari = 1/`colmax' {
        drop _stars`vari'
        }
    
    if "`suppress'"=="suppress" {
        if "`multse'"=="" {qui drop if substr(trim(_rowname),`positse',3)=="_se"}
        else {qui drop if substr(trim(_rowname),-4,3)=="_se"}
        }
    else {
        if "`multse'"=="" {qui replace _rowname = " " if substr(trim(_rowname),`positse',3)=="_se"}
        else {qui replace _rowname = " " if substr(trim(_rowname),-4,3)=="_se"}
        }
    
    qui replace _rowname = "cons" if _rowname == "_cons"
    if "`label'"=="label" { 
      qui replace _rowname = "Const." if _rowname == "cons" 
      } 
    qui replace _rowname = subinstr(_rowname,"_","-",length(_rowname))
    if "`plain'"=="" {
      qui replace _rowname = _rowname + " &"
      }


    /* Layout */
    
    if "`fancy'" ~= "fancy" & "`plain'"=="" {
        qui gen byte _line = _n
        order _line
        qui expand 3 in 1
        quietly summ _line
        qui expand 2 if _line==`r(max)'
        sort _line
        qui drop _line
        qui replace _rowname = "\begin{tabular}{`explic'}" if _n == 1
        qui replace _rowname = "" if _n == 2
        local vardsp = subinstr("`1'","_","-",length("`1'"))
        if "`collabels'"~="" & "`labl1'"~="" { local vardsp = "`labl1'" }
        qui replace s_`1' = "& `vardsp' &" if _n == 2
        forvalues vari = 1/`colmax' {
            qui replace s_``vari'' = "" if _n == 1
            local vardsp = subinstr("``vari''","_","-",length("``vari''"))
            if "`collabels'"~="" & "`labl`vari''"~="" { local vardsp = "`labl`vari''" }
            if `vari'>1 & `vari'<`colmax' { qui replace s_``vari'' = "`vardsp' &" if _n == 2 }
            qui replace s_``vari'' = "" if _n == _N
        }
        local vardsp = subinstr("``colmax''","_","-",length("``colmax''"))
        if "`collabels'"~="" & "`labl`colmax''"~="" { local vardsp = "`labl`colmax''" }
        qui replace s_``colmax'' = "`vardsp' \" + "\" if _n == 2
        qui replace _rowname = "\end{tabular}%" if _n == _N
        foreach vari in `extracols' {
            if `vari' < `colmax'  { qui replace s_``vari'' = s_``vari'' + "&" if _n == 2 }
        }
    }

    if "`fancy'" == "fancy" & "`plain'"=="" {
        qui gen byte _line = _n
        order _line
        qui expand 6 in 1
        quietly summ _line
        qui expand 3 if _line==`r(max)'
        sort _line
        qui drop _line
        qui replace _rowname = "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}`explic'}" if _n == 1
        qui replace _rowname = "" if _n == 2
        local vardsp = subinstr("`1'","_","-",length("`1'"))
        if "`collabels'"~="" & "`labl1'"~="" { local vardsp = "`labl1'" }
        qui replace s_`1' = "& \multicolumn{1}{`incr'}{`vardsp'} &" if _n == 2
        local coltabl = `colmax' + 1 + `toknum'
        qui replace _rowname = "\cline{2-`coltabl'}" if _n == 3
        qui replace _rowname = "" if _n == 4
        qui replace s_`1' = "& \multicolumn{1}{`incr'}{(1)\mbox{\ }} &" if _n == 4
        qui replace _rowname = "\hline" if _n == 5
        forvalues vari = 1/`colmax' {
            qui replace s_``vari'' = "" if _n == 1
            qui replace s_``vari'' = "" if _n == 3
            qui replace s_``vari'' = "" if _n == 5
            if `vari'>1 & `vari'<`colmax' {
                local vardsp = subinstr("``vari''","_","-",length("``vari''"))
                if "`collabels'"~="" & "`labl`vari''"~="" { local vardsp = "`labl`vari''" }
                qui replace s_``vari'' = "\multicolumn{1}{`incr'}{`vardsp'} &" if _n == 2
                qui replace s_``vari'' = "\multicolumn{1}{`incr'}{(`vari')\mbox{\ }} &" if _n == 4
                }
            qui replace s_``vari'' = "" if _n == _N-1
            qui replace s_``vari'' = "" if _n == _N
        }
        local vardsp = subinstr("``colmax''","_","-",length("``colmax''"))
        if "`collabels'"~="" & "`labl`colmax''"~="" { local vardsp = "`labl`colmax''" }
        qui replace s_``colmax'' = "\multicolumn{1}{`incr'}{`vardsp'} \" + "\" if _n == 2
        qui replace s_``colmax'' = "\multicolumn{1}{`incr'}{(`colmax')} \" + "\" if _n == 4
        qui replace s_``colmax'' = s_``colmax'' + " \" + "\" if _n == _N-2
        qui replace _rowname = "\hline\hline" if _n == _N-1
        qui replace _rowname = "\end{tabular*}%" if _n == _N
        foreach vari in `extracols' {
            if `vari' < `colmax'  {qui replace s_``vari'' = s_``vari'' + "&" if _n == 2
                                   qui replace s_``vari'' = s_``vari'' + "&" if _n == 4}
        }
        if "`label'"=="label" {
            qui replace _rowname = "Obs. &" if _rowname=="e(N) &" | _rowname=="r(N) &"
            qui replace _rowname = "$ R^2$ &" if _rowname=="e(r2) &"
            qui replace _rowname = "$ F$ statistic &"      if _rowname=="e(F) &"    | _rowname=="r(F) &"
            qui replace _rowname = "$ \chi^2$ statistic &" if _rowname=="e(chi2) &" | _rowname=="r(chi2) &"
            qui replace _rowname = "Degrees of freedom &"  if _rowname=="e(df) &"   | _rowname=="r(df) &"
            qui replace _rowname = "$ p$-value &"          if _rowname=="r(p) &"
            qui replace _rowname = "Log likelihood &"      if _rowname=="e(ll_r) &"   | _rowname=="r(ll_r) &"
            qui replace _rowname = "Model degrees of freedom &"    if _rowname=="e(df_m) &"  | _rowname=="r(df_m) &"
            qui replace _rowname = "Residual degrees of freedom &" if _rowname=="e(df_r) &"  | _rowname=="r(df_r) &"
            qui replace _rowname = "Model sum of squares &"        if _rowname=="e(mss) &"   | _rowname=="r(mss) &"
            qui replace _rowname = "Residual sum of sqaures &"     if _rowname=="e(rss) &"   | _rowname=="r(rss) &"
        }
    qui drop if substr(s_``colmax'',-1,1)~="\" & substr(_rowname,1,1)~="\" & substr(_rowname,1,1)~=" " & _rowname~=""
    }

    if "`plain'"~="" {
        qui gen byte _line = _n
        order _line
        qui expand 2 in 1
        sort _line
        qui replace _rowname = "" if _n == 1
        forvalues vari = 1/`colmax' {
            local vardsp = subinstr("``vari''","_","-",length("``vari''"))
            qui replace s_``vari'' = "`vardsp'" if _n == 1
        }
    }
    if "`label'"=="label" & "`lblnum'"=="" {  /* MH 16jan2002 */
        local i = 1
        local rowmax = rowsof(`vecname'_b)
        tokenize `vars'
        while `i'<=`rowmax' {
            qui replace _rowname = "`L`i'' &" if _rowname=="``i'' &"
            local i = `i'+1
            }
        }
    if "`lblnum'"~="" {
      forvalues l = 1/`lblnum' {
        qui replace _rowname = "`L`l'' &"  if  _rowname=="`V`l'' &"
        }
      forvalues l = 1/`lblnum' {
        qui replace _rowname = substr(_rowname,1,index(_rowname,":")) + "`L`l'' &"  if  _rowname==substr(_rowname,1,index(_rowname,":")) + "`V`l'' &"
        qui replace _rowname = "`L`l''" + substr(_rowname,index(_rowname,":"),length(_rowname)) if  _rowname=="`V`l''" + + substr(_rowname,index(_rowname,":"),length(_rowname))
        }
      }

    if "`plain'"==""    {
      capture outsheet using "`file2'", noquote nonames replace
      }
    if "`plain'"=="csv" {
      capture outsheet using "`file2'", noquote nonames comma replace
      }
    if "`plain'"=="tab" {
      capture outsheet using "`file2'", noquote nonames replace
      }
    if _rc==0 {
      disp in blue "TeX file " in yellow "`file2'" in blue " saved"
      }
    else {
      use "`file1'", clear
      error _rc
      }

    use "`file1'", clear
end
