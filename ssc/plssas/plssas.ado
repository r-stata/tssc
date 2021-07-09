*! Date    : 21 Jun 2012
*! Version : 1.02
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk


*! plssas, y(a b c) x(abcdefghijklmnopqrstuvwxyz x1 x2 x3)

/*
 7May09 v 1.00  The command is born
20Jun12 v 1.01  Bug fixes!
21Jun12 v 1.02  The coded coefficient error in displaying
*/

pr plssas
version 9.1
preserve
syntax [varlist] , Y(varlist) X(varlist) [Nfac(integer 0) NOSAS NOFILE Method(string) Prefix(string) EXE(string asis) ]

cap confirm file `"`prefix'out.csv"'
if _rc==0 {
  di "{err}Note: `prefix'out.csv exists and to be sure that this file is "
  di "      overwritten you should delete all the following csv files:"
  di "        codedcoef.csv, csp.csv, out.csv, perc.csv, pest.csv, xeff.csv, "
  di "        xload.csv, xweights.csv, yweights.csv"
}
  
if `"`exe'"'=="" local saspath `"c:\Program Files\SAS\SAS 9.1\sas.exe"'
else local saspath `"`exe'"'

/* Select the method */
if "`method'"=="" local method "rrr"
if "`method'"~="rrr" & "`method'"~="pls" & "`method'"~="simpls" & "`method'"~="pcr" {
  di "{error}WARNING: Method can only be specified as rrr, pls, simpls or pcr"
  di "NOT `method'"
  exit(198)
}

/* No coded coefficients when using pls*/
if "`method'"=="pls" local cc 0
else local cc 1


local nyvar:list sizeof y
local nxvar:list sizeof x

/*****************************************************
 * Check whether any capitals in the variable list as 
 * SAS doesn't handle them well
 *****************************************************/
foreach yv of local y {
  if "`yv'"~=lower("`yv'") {
    di "{err}WARNING: variable names must be lower case e.g. `yv'"
    exit(198)
  }
  if length("`yv'")>15 {
    di "{err}WARNING: variable names must be shorter than 16 characters e.g. `yv'"
    exit(198)
  }
}
foreach xv of local x {
  if "`xv'"~=lower("`xv'") {
    di "{err}WARNING: variable names must be lower case e.g. `xv'"
    exit(198)
  }
}

/* Calculate the default number of factors min(15,p,N) p predictors  N to do with CV option not implemented here*/
if `nfac'==0 {
  if "`method'"=="rrr" local nfac= min(15,`nyvar')
  else local nfac=min(15,`nxvar')
}
if `nfac'>`nyvar' & "`method'"=="rrr" {
  di "{err}WARNING: the number of factors specified is more than number of y-variables for method RRR!"
  di "              LOWER nfac() option"
  exit(198)
}

/* Create the CSV data file */

if "`nofile'"=="" outsheet `varlist' using "`c(pwd)'\temp.csv", comma replace

/*Write the SAS code */
if "`nosas'"=="" { 
  tempname myfile
  file open `myfile' using temp.sas, write replace
  file write `myfile' "PROC IMPORT OUT= TEMP" _n
  file write `myfile' `"  DATAFILE= "`c(pwd)'\temp.csv""' _n
  file write `myfile' "  DBMS=CSV REPLACE;" _n
  file write `myfile' "  GETNAMES=YES;" _n
  file write `myfile' "  DATAROW=2;" _n
  file write `myfile' "RUN;" _n
  file write `myfile' "ods listing close;" _n
  file write `myfile' "ods output CenScaleParms=csp;" _n
  if `cc' file write `myfile' "ods output Codedcoef=codedcoef;" _n
  file write `myfile' "ods output ParameterEstimates=pest;" _n
  file write `myfile' "ods output percentvariation=perc;" _n
  file write `myfile' "ods output xeffectcenscale=xeff;" _n
  file write `myfile' "ods output XLoadings=xloadings;" _n
  file write `myfile' "ods output XWeights=xweights;" _n
  file write `myfile' "ods output YWeights=yweights;" _n
  file write `myfile' "proc pls data=temp method=`method' varss nfac=`nfac' details censcale;" _n
  file write `myfile' "model `y' =" _n

/* if the x list is a little too long */
  local temp ""
  foreach xvar of local x {
    if length("`temp'")+length("`xvar'") < 50 local temp "`temp' `xvar'"
    else {
      file write `myfile' "`temp'" _n
      local temp "`xvar'"
    }
  }
  file write `myfile' "`temp'/solution;" _n
  file write `myfile' "output out=temp2 XSCORE=xscore YSCORE=yscore;" _n
  file write `myfile' "run;" _n
  file write `myfile' `"PROC EXPORT DATA= temp2             OUTFILE= "`prefix'out.csv" DBMS=CSV REPLACE; run;"' _n
  file write `myfile' `"PROC EXPORT DATA= csp               OUTFILE= "`prefix'csp.csv" DBMS=CSV REPLACE; run;"' _n
  if `cc' file write `myfile' `"PROC EXPORT DATA= codedcoef OUTFILE= "`prefix'codedcoef.csv" DBMS=CSV REPLACE; run;"' _n
  file write `myfile' `"PROC EXPORT DATA= pest              OUTFILE= "`prefix'pest.csv" DBMS=CSV REPLACE; run;"' _n
  file write `myfile' `"PROC EXPORT DATA= perc              OUTFILE= "`prefix'perc.csv" DBMS=CSV REPLACE; run;"' _n
  file write `myfile' `"PROC EXPORT DATA= xeff              OUTFILE= "`prefix'xeff.csv" DBMS=CSV REPLACE; run;"' _n
  file write `myfile' `"PROC EXPORT DATA= xloadings OUTFILE= "`prefix'xload.csv"  DBMS=CSV REPLACE;  run;"' _n
  file write `myfile' `"PROC EXPORT DATA= xweights  OUTFILE= "`prefix'xweights.csv" DBMS=CSV REPLACE; run;"' _n
  file write `myfile' `"PROC EXPORT DATA= yweights  OUTFILE= "`prefix'yweights.csv" DBMS=CSV REPLACE; run;"' _n
  file close `myfile'

/* Run the SAS code */

  if "`c(os)'"~="Windows" {
    di "{error} WARNING: You are running the `c(os)' operating system, this command only works for Windows"
    di "{error} I *might* implement a Unix/Mac version but I need to know the SAS command line that is required to run in batch mode"
    di "{error} Please email me with the command line and I can try and implement this command for `c(os)'"
    exit(198)
  }

  di "{text}NOTE: About to run SAS using a shell ....."
  di
  cap confirm file `"`saspath'"'
  if _rc~=0 {
    di "{error}WARNING: {input}`saspath' {error}does not exist"
    exit(198)
  }
  di `"{phang}This command is being run !"`saspath'" -SYSIN "temp.sas" -NOSPLASH -ICON -PRINT test.lst "'
  di
/*
  !"`saspath'" -SYSIN "temp.sas" -ALTLOG "plssas.log" -NOSPLASH -ICON -PRINT test.lst  
*/
  !"`saspath'" -SYSIN "temp.sas"
}


/* Display starts*/

di "{text}Results from the partial least squares routine in SAS"
di "Method `method'"
di
di "Y Variable(s): "
di as res " `y'"
di as text "X Variable(s):"
foreach vx of local x {
  if length("`tempx' `vx'")>`c(linesize)'+1 {
    di "{result}`tempx'"
    local tempx " `vx'"
  }
  else local tempx "`tempx' `vx'"
}
di "{result}`tempx'"

/* Display the Loadings */
qui insheet using `prefix'xweights.csv,names clear
local nof  = _N
local nof2 = 2*_N
qui xpose, clear v
qui drop if _varname=="numberoffactors"
sort _varname
forv j=1/`nof' {
  rename v`j' xw`j'
}
qui save temp,replace
qui insheet using `prefix'xload.csv,names clear
local nof = _N
qui xpose, clear v

/* need to check whether the number of factors equals the number of x variables */
if `nof'~=`nxvar' & "`method'"~="rrr" {
  di "{red}Note: The number of factors `nof' does not equal the number of X variables `nxvar'"
}
if `nof'~=`nyvar' & "`method'"=="rrr" {
  di "{red}Note: The number of factors `nof' does not equal the number of Y variables `nyvar'"
}


qui drop if _varname=="numberoffactors"
sort _varname
qui merge _varname using temp
qui compress

/* this big finds out the length of variable names .. trying to minimise the space needed to display */
tempvar length
qui gen `length'=length(_varname)
qui su `length' 
local len =`r(max)'
if `len' <10 local len 10
local len2=`len'+2


di
di "{text}  X loadings and X weights"
di

/* 
too many things to display on one line... need to split 

When there are more than 12 this all breaks!!!!!!!!

left   - just indicates whether there are any more variables
startj 1
len    - this is the maximum length of variable name
len2   - this is len+2
nof    is the number of factors 
nof2   - this is 2*nof

*/

local left 1
local startj 1
while `left'~=0 {
  /* check whether we can fit the original number of wts and lds on one line */
  if `len'+7*2*(`nof'-`startj'+1)>`c(linesize)' {
    local tnof = int( (`c(linesize)'-`len')/14.0 )+`startj'-1
    local tnof2 = `tnof'*2
  }
  else {
    local tnof `nof'
    local tnof2 = 2*`nof'
    local left 0
  }

  /* select the start factor in terms of v? numbers */
  local startj2 = `startj'*2-1

  di _continue "{text}{c TLC}{dup `len':{c -}}{c TT}"
  forv j=`startj2'/`tnof2' {
    if `j'~=`tnof2' di _continue "{dup 6:{c -}}{c TT}"
    else di _continue "{dup 6:{c -}}{c TRC}"
  }
  di
  di _continue "{text}{c |} Variable {col `len2'}{c |}"
  forv j=`startj'/`tnof' {
    local col = `len2'+7*(`j'-`startj')
    local c2 = `col'+7
    di as res _continue "{text}{col `col'} Ld `j'{col `c2'}{text}{c |}"
  }
  forv j=`startj'/`tnof' {
    local col = `len2'+7*(`tnof'-`startj'+1)+7*(`j'-`startj')
    local c2 = `col'+7
    di as res _continue "{col `col'}{text} Wt `j'{col `c2'}{text}{c |}"
  }
  di
  di _continue "{c LT}{dup `len':{c -}}{c +}"
  forv j=`startj2'/`tnof2' {
    if `j'~=`tnof2' di _continue "{dup 6:{c -}}{c +}"
    else di _continue "{dup 6:{c -}}{c RT}"
  }
  di
  forv i=1/`=_N' {
    di _continue "{text}{c |}{result}" _varname[`i'] "{text}{col `len2'}{c |}"
    forv j=`startj'/`tnof' {
      local v: di %6.3f v`j'[`i']
      local col = `len2'+7*(`j'-`startj')
      local c2  = `col'+6
      di as res _continue "{col `col'}{result}`v'{text}{col `c2'}{c |}"
    }
    forv j=`startj'/`tnof' {
      local xw: di %6.3f xw`j'[`i']
      local col = `len2'+7*(`tnof'-`startj'+1)+7*(`j'-`startj')
      local c2 = `col'+6
      di as res _continue "{col `col'}{result}`xw'{text}{col `c2'}{c |}"
    }
    di
  }
  di _continue "{c BLC}{dup `len':{c -}}{c BT}"
  forv j=`startj2'/`tnof2' {
    if `j'~=`tnof2' di _continue "{dup 6:{c -}}{c BT}"
    else di _continue "{dup 6:{c -}}{c BRC}"
  }
  di
  if `left' local startj = `tnof'+1


} /* end of while loop */


/* Display the Y-WeightsLoadings */
qui insheet using `prefix'yweights.csv,names clear
local nof = _N
qui xpose, clear v
qui drop if _varname=="numberoffactors"
tempvar length
qui gen `length'=length(_varname)
qui su `length' 
local len =`r(max)'
if `len' <10 local len 10
local len2=`len'+2

di
di "{text}  Y weights"
di

local left 1
local startj 1
while `left'~=0 {
  /* check whether we can fit the original number of wts and lds on one line */
  if `len2'+8*(`nof'-`startj'+1)>`c(linesize)' local tnof = int( (`c(linesize)'-`len2')/8.0 )+`startj'-1
  else {
    local tnof `nof'
    local left 0
  }

  di _continue "{text}{c TLC}{dup `len':{c -}}{c TT}"
  forv j=`startj'/`tnof' {
    if `j'~=`tnof' di _continue "{dup 7:{c -}}{c TT}"
    else di _continue "{dup 7:{c -}}{c TRC}"
  }
  di

/*
di _continue "{text}{c TLC}{dup `len':{c -}}{c TT}"
forv j=1/`nof' {
  if `j'~=`nof' di _continue "{dup 8:{c -}}{c TT}"
  else di _continue "{dup 8:{c -}}{c TRC}"
}
di
*/

di _continue "{text}{c |}Variable{col `len2'}{c |}"
  forv j=`startj'/`tnof' {
    local col = `len2'+8*(`j'-`startj')
    local c2 = `col'+8
    di as res _continue "{text}{col `col'} Wt `j' {col `c2'}{text}{c |}"
  }
di

di _continue "{c LT}{dup `len':{c -}}{c +}"
forv j=`startj'/`tnof' {
  if `j'~=`tnof' di _continue "{dup 7:{c -}}{c +}"
  else di _continue "{dup 7:{c -}}{c RT}"
}
di

forv i=1/`=_N' {
  di _continue "{text}{c |}{result}" _varname[`i'] "{text}{col `len2'}{c |}"
  forv j=`startj'/`tnof' {
    local v: di %6.3f v`j'[`i']
    local col = `len2'+8*(`j'-`startj')
    local c2 = `col'+8
    di as res _continue "{col `col'}{result}`v'{col `c2'}{text}{c |}"
  }
  di
}

di _continue "{c BLC}{dup `len':{c -}}{c BT}"
forv j=`startj'/`tnof' {
  if `j'~=`tnof' di _continue "{dup 7:{c -}}{c BT}"
  else di _continue "{dup 7:{c -}}{c BRC}"
}
di

if `left' local startj = `tnof'+1
}

/* Display the Variation */
qui insheet using `prefix'perc.csv,names clear
local nof = _N
qui xpose, clear v
qui drop if _varname=="numberoffactors"

tempvar length
qui gen `length'=length(_varname)
qui su `length' 
local len =`r(max)'
if `len' <10 local len 10
local len2=`len'+2


di
di "{text}  Cumulative Variation Explained"
di

local left 1
local startj 1
while `left'~=0 {
  /* check whether we can fit the original number of wts and lds on one line */
  if `len2'+8*(`nof'-`startj'+1)>`c(linesize)' local tnof = int( (`c(linesize)'-`len2')/8.0 )+`startj'-1
  else {
    local tnof `nof'
    local left 0
  }

di _continue "{text}{c TLC}{dup `len':{c -}}{c TT}"
forv j=`startj'/`tnof' {
  if `j'~=`tnof' di _continue "{dup 7:{c -}}{c TT}"
  else di _continue "{dup 7:{c -}}{c TRC}"
}
di
di _continue "{text}{c |} Variable {col `len2'}{c |}"
  forv j=`startj'/`tnof' {
    local col = `len2'+8*(`j'-`startj')
    local c2 = `col'+8
    di as res _continue "{text}{col `col'} %Exp`j'{col `c2'}{text}{c |}"
  }
di
di _continue "{c LT}{dup `len':{c -}}{c +}"
forv j=`startj'/`tnof' {
  if `j'~=`tnof' di _continue "{dup 7:{c -}}{c +}"
  else di _continue "{dup 7:{c -}}{c RT}"
}
di

forv i=1/`=_N' {
  if _varname[`i']=="currentxvariation" {
    di _continue "{c LT}{dup `len':{c -}}{c +}"
    forv j=`startj'/`tnof' {
      if `j'~=`tnof' di _continue "{dup 7:{c -}}{c +}"
      else di _continue "{dup 7:{c -}}{c RT}"
    }
    di
  }

  di _continue "{text}{c |}{result}" _varname[`i'] "{text}{col `len2'}{c |}"
  forv j=`startj'/`tnof' {
    local v: di %7.3f v`j'[`i']
    local col = `len2'+8*(`j'-`startj')
    di as res _continue "{col `col'}{result}`v'{text}{c |}"
  }
  di
  if _varname[`i']=="totalxvariation" {
    di _continue "{c LT}{dup `len':{c -}}{c +}"
    forv j=`startj'/`tnof' {
      if `j'~=`tnof' di _continue "{dup 7:{c -}}{c +}"
      else di _continue "{dup 7:{c -}}{c RT}"
    }
    di
  }


}
di _continue "{c BLC}{dup `len':{c -}}{c BT}"
forv j=`startj'/`tnof' {
  if `j'~=`tnof' di _continue "{dup 7:{c -}}{c BT}"
  else di _continue "{dup 7:{c -}}{c BRC}"
}
di
if `left' local startj = `tnof'+1

}

/***************************************************
 * Display the Coded Coefficient 
 ***************************************************/

 
 if `cc'  { 
  qui insheet using `prefix'codedcoef.csv,names clear
  qui su numberoffactors
  local nof = `r(max)'
  qui reshape wide `y' , j(numberoffactors) i(effect) 
  tempvar length
  qui gen `length'=length(effect)
  qui su `length' 
  local len =`r(max)'
  if `len' <10 local len 10
  local len2=`len'+2
  local ncol = `nyvar'*`nof'

  di
  di "  Coded Coefficients"
  di

 
  local left 1
  local startj 1
  while `left'~=0 {
    /* check whether we can fit the original number of wts and lds on one line */
    if `len2'+9*(`ncol'-`startj'+1)>`c(linesize)' local tncol = int( (`c(linesize)'-`len2')/9.0 )+`startj'-1
    else {
      local tncol `ncol'
      local left 0
    }
    di _continue "{text}{c TLC}{dup `len':{c -}}{c TT}"
    forv j=`startj'/`tncol' {
      if `j'~=`tncol' di _continue "{dup 8:{c -}}{c TT}"
      else di _continue "{dup 8:{c -}}{c TRC}"
    }
    di
    di _continue "{text}{c |} Variable {col `len2'}{c |}"
    forv k=`startj'/`tncol' {

/* 
   j contains the jth variable in the y-varlist 
  jj contains the factor number
*/

      local j = mod(`k',`nyvar')+1
      local jj = (`k'-mod(`k'-1,`nyvar')-1)/`nyvar'+1

      local yy: word `j' of `y'
      local yy "`yy'`jj'"
      local col = `len2'+9*(`k'-`startj')
      local c2 = `col'+9
      di as res _continue "{col `col'}`yy'{col `c2'}{text}{c |}"
    }
    di
    di _continue "{c LT}{dup `len':{c -}}{c +}"
    forv j=`startj'/`tncol' {
      if `j'~=`tncol' di _continue "{dup 8:{c -}}{c +}"
      else di _continue "{dup 8:{c -}}{c RT}"
    }
    di
    forv i=1/`=_N' {
      di _continue "{text}{c |}{result}" effect[`i'] "{text}{col `len2'}{c |}"
      forv k=`startj'/`tncol' {
        local j = mod(`k',`nyvar')+1
        local jj = (`k'-mod(`k'-1,`nyvar')-1)/`nyvar'+1
        local yy: word `j' of `y'
        local yy "`yy'`jj'"
        local v: di %6.3f `yy'[`i']  /*ERROR fractional jj occurs */
        local col = `len2'+9*(`k'-`startj')
        local c2 = `col'+9
        di as res _continue "{col `col'}{result}`v'{col `c2'}{text}{c |}"
      }
      di
    }
    di _continue "{c BLC}{dup `len':{c -}}{c BT}"
    forv j=`startj'/`tncol' {
      if `j'~=`tncol' di _continue "{dup 8:{c -}}{c BT}"
      else di _continue "{dup 8:{c -}}{c BRC}"
    }
    di
    if `left' local startj = `tncol'+1
  }
}

restore
end

