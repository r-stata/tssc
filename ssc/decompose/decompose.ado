*!version 1.2 02sep2002
* version 1.1 30auf2002
* -- completely rewritten
* version 1.0 22aug2002
*! Ben Jann, ETH Zurich, Switzerland
program define decompose, rclass
version 7.0
syntax [varlist(default=none)] [if] [in] [aweight fweight pweight iweight] /*
 */ [, Save(string) LAmbda(varlist max=1) Detail Estimates BY(varlist max=1) /*
 */ GPooled NPooled Noisy *]
if "`save'"!=""&("`detail'"!=""|"`estimates'"!=""|"`lambda'"!=""|"`varlist'"!=""|"`by'"!="") {
  di as error "error: save() not allowed with any other options"
  exit
}
if ("`varlist'"!=""&"`by'"=="")|("`varlist'"==""&"`by'"!="") {
  di as error "error: varlist and by() both have to be specified"
  exit
}
tempname D BX B X touse obs fH cmean pred cat

*** Coefficients and means of high/low/pooled model (if varlist not specified)
if "`save'"!="" {
  local save=lower("`save'")
  if substr("high",1,length("`save'"))=="`save'" { local save "high"}
  else if substr("low",1,length("`save'"))=="`save'" { local save "low" }
  else if substr("pooled",1,length("`save'"))=="`save'" { local save "pooled" }
  else { error 119 }

  *** Set up matrix and calculate means
  mat `BX'=e(b)
  if "`save'"!="pooled" {
    mark `touse' if e(sample)
    if "`e(wexp)'"!="" {
      local wexp=e(wexp)
      local weight "aweight"
      local wwexp: word 2 of `wexp'
      qui sum `wwexp' if `touse'
      scalar `obs'=r(sum)
    }
    else {scalar `obs'=e(N)}
    local k=colsof(`BX')
    mat `BX'=`BX'',J(`k',1,1)
    local varnames: rownames(`BX')
    tokenize `varnames'
    local j 1
    while `j'<=`k' {
      if "``j''"!="_cons" {
        qui sum ``j'' if `touse' [`weight' `wexp']
        mat `BX'[`j',2]=r(mean)
      }
      local j=`j'+1
    }

  *** Save matrix
    mat `save'cm=`BX'
    scalar `save'obs=`obs'
    di as txt `"(coefficients and means saved in matrix "`save'cm")"'
    if "`wexp'"!="" {di as txt `"(sum of weights saved in scalar "`save'obs")"'}
    else {di as txt `"(n. of obs saved in scalar "`save'obs")"'}
  }
  else {
    mat `BX'=`BX''
    mat `save'c=`BX'
    di as txt `"(coefficients of pooled model saved in matrix "`save'c")"'
  }
}

*** Estimate coefficients (if varlist specified)
if "`varlist'"!="" {
  marksample touse
  markout `touse' `by', strok
  if "`weight'"!="" {
    local aweight "aweight"
    local wwexp: word 2 of `exp'
    }
  if "`noisy'"=="" {local qui "qui"}
  if "`gpooled'"!="" {local gp 1}
  else {local gp 0}
  if "`npooled'"!="" {
    local p 0
    local gp 0
  }
  else {local p 1}

  *** Generate dummies for by-categories and evaluate high model
  qui tabulate `by' if `touse'
  if `r(r)'>20 {
    di as error "error: to many by-groups (> 20)"
    exit
  }
  else if `r(r)'<2 {
    di as error "error: by() must specify at least two groups"
    exit
  }
  qui tabulate `by' if `touse', g(`cat')
  local ncat=r(r)
  if `ncat'==2&`gp' {local gp 0}
  local depvar: word 1 of `varlist'
  local chigh 1
  local c 1
  while `c'<=`ncat' {
    qui sum `depvar' if `touse'&`cat'`c' [`aweight' `exp']
    if `c'==1 { scalar `cmean'=r(mean) }
    if `r(mean)'>`cmean' {
      scalar `cmean'=r(mean)
      local chigh=`c'
    }
    local c=`c'+1
  }
  local chighlab: variable label `cat'`chigh'

  *** Estimate/save models
  local c 1
  while `c'<=`ncat' {
    local clab: variable label `cat'`c'
    `qui' di as txt _n "--> Separate model: `clab'"
    `qui' reg `varlist' if `touse'&`cat'`c' [`weight' `exp'] , `options'
    mat `BX'`c'=e(b)
    if "`weight'"!="" {
      qui su `wwexp' if `touse'&`cat'`c'
      scalar `obs'`c'=r(sum)
      }
    else {scalar `obs'`c'=e(N)}
    if `c'==1 {
      local k=colsof(`BX'`c')
      local varnames: colnames(`BX'`c')
      tokenize `varnames'
    }
    mat `BX'`c'=`BX'`c'',J(`k',1,1)
    local j 1
    while `j'<=`k' {
      if "``j''"!="_cons" {
        qui sum ``j'' if `touse'&`cat'`c' [`aweight' `exp']
        mat `BX'`c'[`j',2]=r(mean)
      }
      local j=`j'+1
    }
    if !`gp'&`p'&`c'!=`chigh' {
      `qui' di as txt _n "--> Pooled model: `chighlab' | `clab'"
      `qui' reg `varlist' if `touse'&(`cat'`c'|`cat'`chigh') [`weight' `exp'] , `options'
      mat `BX'p`c'=e(b)
      mat `BX'p`c'=`BX'p`c''
    }
    local c=`c'+1
  }
  if `gp' {
    `qui' di as txt _n "--> Pooled model (over all categories)"
    `qui' reg `varlist' if `touse' [`weight' `exp'] , `options'
    mat `BX'p=e(b)
    mat `BX'p=`BX'p'
  }
}

*** Calculate and display decomposition
if "`save'"=="" {
  if "`varlist'"=="" {
    scalar `obs'1=scalar(highobs)
    scalar `obs'2=scalar(lowobs)
    scalar drop highobs lowobs
    mat `BX'1t=matrix(highcm)
    mat `BX'2t=matrix(lowcm)
    mat drop highcm lowcm
    capture local p=pooledc[1,1]
    if _rc!=0 {
      local p 0
      local gp 0
      }
    else {
      mat `BX'pt=matrix(pooledc)
      mat drop pooledc
      local p 1
      local gp 1
      }
    local ncat 2
    local chigh 1
    local varnameshi: rownames `BX'1t
    local varnameslo: rownames `BX'2t
    local k: word count `varnameshi'
    local klo: word count `varnameslo'
    if "`varnameshi'"!="`varnameslo'" {
      local j 1
      while `j'<=`k' {
        local varname: word `j' of `varnameshi'
        local varnameslo: subinstr local varnameslo "`varname'" "", word
        local j=`j'+1
        }
      local klob: word count `varnameslo'
    }
    else {local klob 0}
    local j 1
    while `j'<=`k'+1 {
      local varname: word `j' of `varnameshi'
      if ("`varname'"=="_cons"|"`varname'"=="")&`klob'>0 {
        local jlo 1
        while `jlo'<=`klob' {
          local varnamelo: word `jlo' of `varnameslo'
          local varnames "`varnames' `varnamelo'"
          local jlo=`jlo'+1
        }
        local klob=0
      }
      local varnames "`varnames' `varname'"
      local j=`j'+1
    }
    local k: word count `varnames'
    mat `BX'1=J(`k',2,0)
    mat `BX'2=J(`k',2,0)
    mat rownames `BX'1=`varnames'
    mat rownames `BX'2=`varnames'
    if `p' {
      mat `BX'p=J(`k',1,1)
      mat rownames `BX'p=`varnames'
    }
    local j 1
    while `j'<=`k' {
      local varname: word `j' of `varnames'
      if rownumb(`BX'1t,"`varname'")!=. {
        mat `BX'1[`j',1]=`BX'1t["`varname'",1]
        mat `BX'1[`j',2]=`BX'1t["`varname'",2]
        }
      else if rownumb(`BX'2t,"`varname'")!=. {mat `BX'1[`j',1]=`BX'2t["`varname'",1]}
      if rownumb(`BX'2t,"`varname'")!=. {
        mat `BX'2[`j',1]=`BX'2t["`varname'",1]
        mat `BX'2[`j',2]=`BX'2t["`varname'",2]
        }
      else if rownumb(`BX'1t,"`varname'")!=. {mat `BX'2[`j',1]=`BX'1t["`varname'",1]}
      if `p' {
        if rownumb(`BX'pt,"`varname'")==.&(rownumb(`BX'1t,"`varname'")!=. /*
        */ |rownumb(`BX'2t,"`varname'")!=.) {
          di as error "error: missing variable(s) in pooled model"
          exit
        }
        else {mat `BX'p[`j',1]=`BX'pt["`varname'",1]}
      }
      local j=`j'+1
    }
    matrix drop `BX'1t `BX'2t
    if `p' {matrix drop `BX'pt}
  }
  if "`lambda'"!="" {local varnames: subinstr local varnames "`lambda'" "", word}
  local k: word count `varnames'
  if "`lambda'"=="" {
    mat `B'h=`BX'`chigh'[1..`k',1]
    mat `X'h=`BX'`chigh'[1..`k',2]'
    if `gp' {mat `B'p=`BX'p}
  }
  else {
    mat `B'h=J(`k',1,0)
    mat `X'h=J(1,`k',0)
    if `gp' {mat `B'p=J(`k',1,0)}
    local j 1
    while `j'<=`k' {
      local varname: word `j' of `varnames'
      mat `B'h[`j',1]=`BX'`chigh'["`varname'",1]
      mat `X'h[1,`j']=`BX'`chigh'["`varname'",2]
      if `gp' {mat `B'p[`j',1]=`BX'p["`varname'",1]}
      local j=`j'+1
    }
  }

  *** Set up decomposition matrix
  local c 1
  while `c'<=`ncat' {
    if `c'!=`chigh' {
      if "`varlist'"!="" {local clab: variable label `cat'`c'}
      if `p'&!`gp' {mat `BX'p=`BX'p`c'}
      if "`lambda'"=="" {
        mat `B'l=`BX'`c'[1..`k',1]
        mat `X'l=`BX'`c'[1..`k',2]'
        if `p'&!`gp' {mat `B'p=`BX'p}
      }
      else {
        mat `B'l=J(`k',1,0)
        mat `X'l=J(1,`k',0)
        if `p'&!`gp' {mat `B'p=J(`k',1,0)}
        local j 1
        while `j'<=`k' {
          local varname: word `j' of `varnames'
          mat `B'l[`j',1]=`BX'`c'["`varname'",1]
          mat `X'l[1,`j']=`BX'`c'["`varname'",2]
          if `p'&!`gp' {mat `B'p[`j',1]=`BX'p["`varname'",1]}
          local j=`j'+1
        }
      }
      mat `pred'=`X'h*`B'h,`X'l*`B'l,`X'h*`B'h-`X'l*`B'l
      scalar `fH'=`obs'`chigh'/(`obs'`chigh'+`obs'`c')
      if "`lambda'"!="" {
        mat `BX'=`BX'`chigh'["`lambda'",1]*`BX'`chigh'["`lambda'",2] /*
          */ -`BX'`c'["`lambda'",1]*`BX'`c'["`lambda'",2]
        local dlambda=`BX'[1,1]
      }
      mat `D'=diag(`B'l)*(`X'h'-`X'l'),diag(`B'h-`B'l)*`X'l', /*
       */ diag(`B'h-`B'l)*(`X'h'-`X'l')
      mat `D'=`D',`D'[1..`k',1],`D'[1..`k',1]+`D'[1..`k',3], /*
       */ `D'[1..`k',1]+`D'[1..`k',3]*0.5,`D'[1..`k',1]+`D'[1..`k',3]*`fH'
      if `p' {mat `D'=`D',diag(`B'p)*(`X'h'-`X'l')}
      mat `D'=`D'\J(1,`k',1)*`D'
      mat `BX'=`BX'`chigh',diag(`BX'`chigh'[1...,1])*`BX'`chigh'[1...,2], /*
       */ `BX'`c',diag(`BX'`c'[1...,1])*`BX'`c'[1...,2]
      if `p' {mat `BX'=`BX',`BX'p}

      *** Display summary output
      if `p' {local con "_c"}
      di as txt _n "Summary of decomposition results:"
      if "`varlist'"!="" {
        di as txt "High: `chighlab'"
        di as txt "Low:  `clab'"
      }
      di as txt `con' "{hline 59}"
      if `p' {di "{hline 8}"}
      di as txt %27s "Mean prediction high (H):" as result %8.3f `pred'[1,1]
      di as txt %27s "Mean prediction low (L):" as result %8.3f `pred'[1,2]
      di as txt %27s "Raw differential (R) {H-L}:" as result %8.3f `pred'[1,3]
      di as txt %27s "- due to endowments (E):" as result %8.3f `D'[`k'+1,1]
      di as txt %27s "- due to coefficients (C):" as result %8.3f `D'[`k'+1,2]
      di as txt %27s "- due to interaction (CE):" as result %8.3f `D'[`k'+1,3]
      di as txt `con' "{hline 59}"
      if `p' {di "{hline 8}"}
      di as txt `con' _col(26) "D:   0       1       0.5  " %8.3f `fH'
      if `p'{di "   *"}
      di as txt `con' _col(31) "{hline 29}"
      if `p' {di "{hline 8}"}
      di as txt `con' %27s "Unexplained (U){C+(1-D)CE}:" as result /*
       */ %8.3f `pred'[1,3]-`D'[`k'+1,4] %8.3f `pred'[1,3]-`D'[`k'+1,5] /*
       */ %8.3f `pred'[1,3]-`D'[`k'+1,6] %8.3f `pred'[1,3]-`D'[`k'+1,7]
      if `p' {di %8.3f `pred'[1,3]-`D'[`k'+1,8]}
      di as txt `con' %27s "Explained (V) {E+D*CE}:" as result /*
       */ %8.3f `D'[`k'+1,4] %8.3f `D'[`k'+1,5] %8.3f `D'[`k'+1,6] %8.3f `D'[`k'+1,7]
      if `p' {di %8.3f `D'[`k'+1,8]}
      di as txt `con' %27s "% unexplained {U/R}:" as result /*
       */ %8.1f (`pred'[1,3]-`D'[`k'+1,4])/`pred'[1,3]*100 /*
       */ %8.1f (`pred'[1,3]-`D'[`k'+1,5])/`pred'[1,3]*100 /*
       */ %8.1f (`pred'[1,3]-`D'[`k'+1,6])/`pred'[1,3]*100 /*
       */ %8.1f (`pred'[1,3]-`D'[`k'+1,7])/`pred'[1,3]*100
      if `p' {di %8.1f (`pred'[1,3]-`D'[`k'+1,8])/`pred'[1,3]*100}
      di as txt `con' %27s "% explained (V/R):" as result /*
       */ %8.1f `D'[`k'+1,4]/`pred'[1,3]*100 %8.1f `D'[`k'+1,5]/`pred'[1,3]*100 /*
       */ %8.1f `D'[`k'+1,6]/`pred'[1,3]*100 %8.1f `D'[`k'+1,7]/`pred'[1,3]*100
      if `p' {di %8.1f `D'[`k'+1,8]/`pred'[1,3]*100}
      di as txt `con' "{hline 59}"
      if `p' {di "{hline 8}"}
      di as txt "Note: D in 4th column = relative frequency of high group"
      if `p' {
        if `gp' {di as txt "      * reference: pooled model over all categories"}
        else {di as txt "      * reference: pooled model over both categories"}
      }
        if "`lambda'"!="" {
        di "Note: Prediction ajusted for selection (differential due to"
        di "      selection variable '`lambda'': " %5.3f `dlambda' ")"
      }

      *** Display detailed decomposition
      if "`detail'"!="" {
        di as txt _n "Decomposition results for variables:"
        di as txt `con' "{hline 59}"
        if `p' {di "{hline 8}"}
        di as txt _col(39) "explained: D = "
        di as txt `con' _col(38) "{hline 22}"
        if `p' {di "{hline 8}"}
        di as txt `con' " Variables    E(D=0)  C       CE      1       0.5  " %8.3f `fH'
        if `p' {di "   *"}
        di as txt `con' "{hline 59}"
        if `p' {di "{hline 8}"}
        local j 1
        while `j'<=`k' {
          local varname: word `j' of `varnames'
          di as txt `con' %10s "`varname'" as result %9.3f `D'[`j',1] %8.3f `D'[`j',2]/*
          */ %8.3f `D'[`j',3] %8.3f `D'[`j',5] %8.3f `D'[`j',6] %8.3f `D'[`j',7]
          if `p' {di %8.3f `D'[`j',8]}
          local j=`j'+1
        }
        di as txt `con' "{hline 59}"
        if `p' {di "{hline 8}"}
        di as txt `con' %10s "Total" as result %9.3f `D'[`k'+1,1] %8.3f `D'[`k'+1,2]/*
          */ %8.3f `D'[`k'+1,3] %8.3f `D'[`k'+1,5] %8.3f `D'[`k'+1,6] %8.3f `D'[`k'+1,7]
          if `p' {di %8.3f `D'[`k'+1,8]}
        di as txt `con' "{hline 59}"
        if `p' {di "{hline 8}"}
      }

      *** Display coefficients and means
      if "`estimates'"!="" {
        di as txt _n "Coefficients, Means and Predictions:"
        di as txt `con' "{hline 59}"
        if `p' {di "{hline 8}"}
        di as txt `con' _col(20) "High model" _col(44) "Low model"
        if `p' { di _col(62) "Pooled"}
        di as txt `con' _col(13) "{hline 23} {hline 23}"
        if `p' {di " {hline 7}"}
        di as txt `con' " Variables    Coef.   Mean    Pred.   Coef.   Mean    Pred."
        if `p' {di "   Coef."}
        di as txt `con' "{hline 59}"
        if `p' {di "{hline 8}"}
        local evarnames: rownames `BX'
        local ek: word count `evarnames'
        local j 1
        while `j'<=`ek' {
          local varname: word `j' of `evarnames'
          di as txt `con' %10s "`varname'" as result %9.3f `BX'[`j',1] %8.3f `BX'[`j',2] /*
           */ %8.3f `BX'[`j',3] %8.3f `BX'[`j',4] %8.3f `BX'[`j',5] %8.3f `BX'[`j',6]
          if `p' {di %8.3f `BX'[`j',7]}
          local j=`j'+1
        }
        di as txt `con' "{hline 59}"
        if `p' {di "{hline 8}"}
        if "`lambda'"!="" {
          di as txt %10s "Total" _col(28) as result %8.3f `pred'[1,1]+ /*
          */ `BX'`chigh'[rownumb(`BX'`chigh',"`lambda'"),1] /*
          */ *`BX'`chigh'[rownumb(`BX'`chigh',"`lambda'"),2] _col(52) /*
          */ %8.3f `pred'[1,2]+`BX'`c'[rownumb(`BX'`c',"`lambda'"),1] /*
          */ *`BX'`c'[rownumb(`BX'`c',"`lambda'"),2]
        }
        else {
          di as txt %10s "Total" _col(28) as result %8.3f `pred'[1,1] _col(52) /*
            */ %8.3f `pred'[1,2]
        }
        di as txt `con' "{hline 59}"
        if `p' {di "{hline 8}"}
      }
    }
    local c=`c'+1
  }

  ***Returns
  mat rownames `pred'=prediction
  mat colnames `pred'=H L H-L
  mat rownames `D'=`varnames' total
  if `p' {
    mat colnames `D'=E C CE D=0 D=1 D=1/2 D=fH D=*
    mat colnames `BX'=bH xH bH*xH bL xL bL*xL bP
  }
  else {
    mat colnames `D'=E C CE D=0 D=1 D=1/2 D=fH
    mat colnames `BX'=bH xH bH*xH bL xL bL*xL
  }
  return scalar fH=`fH'
  return matrix pred `pred'
  return matrix decomp `D'
  return matrix xb `BX'
}
end
