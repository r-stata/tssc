*! Date        : 3 Sep 2007
*! Version     : 1.72
*! Authors     : Adrian Mander/David Clayton
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*! Description : Hotdeck imputation

/* 
25/07/06 version 1.67 - removed some = and investigated the set seed problem 
16/3/07  version 1.68 - spruced up the displays
13/6/07  version 1.69 - Made sure set seed does what the masses want although it is truly the wrong thing to do
27/7/07  version 1.70 - The warnings were not strong enough about the strata information.. in fact I think when there is 
                        no data to impute it still tries to combine results. Also a slight error in the output.
15/8/07  version 1.71 - Corrected the confidence intervals.. the tail probability was wrong
                        ALSO checked the calculation of T B Ubar Qbar by hand!
3/9/07   version 1.72 - Corrected the % lines missing to % lines complete
*/

program define hotdeck
version 9.0
syntax [varlist] [if] [in] [using/], [BY(varlist) IMPute(integer 1) STORE GENerate(string) COMmand(string) PARMS(string asis) REPlace NOISE KEEP(varlist) SEED(string) QUIET INFILES(string) ] 
tokenize "`varlist'"
local z "`1'"

preserve
if "`if'"~="" qui keep `if'

/* Check the seed option */
if "`seed'"=="1" local seed 2
if "`seed'"=="" {
  local noseed "noseed"
  local seed 1
}

confirm number `seed'
/* To generate a seed from the time note need to truncate the seed to be below 2^31-1 */
if `seed'==1 {
  local time "$S_TIME"
  local date "$S_DATE"
  tokenize "`time'", parse(":") 
  local seed1 "`1'`3'`5'"
  tokenize "`date'", parse(" ")
  local dat "`1'`2'`3'"
  local dat1 = date("`dat'","dmy")
  local seed1 "`seed1'`dat1'"
  di
  local l_seed "2^31-1"
  local seed1 = mod(`seed1',`l_seed')
  set seed `seed1'
  local seed "`seed1'"  /* Added to sort out the seed */
}
di "{txt}Seed is set as {res} `seed'"

estimates clear
tempfile olddata

tempvar touse
mark `touse' `if' `in'
markout `touse' `by', strok

di in green "DELETING all matrices...."
mat drop _all

/* Display the patterns of missingness.. only on observed data not imputed */
if "`infiles'"=="" {
  if "`by'"=="" _misspat `varlist' `if' `in' 
  else _misspat `varlist' `if' `in', by(`by')
  local nfill=r(nmiss)
}


qui save "`olddata'"

/* Count the missing data for displaying later */
if "`infiles'"=="" {
  global allpat = r(allpat)
  qui count if `touse'
  local miss = (r(N)-`nfill')/r(N)
}


/* Make sure the users are using the right syntax.. lots of checks here to make sure*/
if "`command'"=="" {
  di in red "WARNING: When the <command> option is not selected "
  di in red "then no analysis is performed on the imputed datasets"
  di 
  if "`store'"=="" {
    di "ALSO STORE isnt selected so hotdeck will appear to do nothing" 
    exit(198)
  }
}

if `impute'<1 {
  di in red "The number of imputations must be more than 0 not `impute'"
  exit(198)
}
              
if `impute'==1 & "`infiles'"=="" {
  if "`store'"=="" | "`command'"~="" {
    di in red "If one imputation is made then command option should NOT be used"
    di in red "AND the store option must be specified"
    exit(198)
  }
}


if "`using'"~="" {
  if "`store'"=="" {
    di in red "To save datasets you must specify the STORE option"
    exit(198)
  }
}
if "`keep'"~="" {
  if "`store'"=="" {
    di in red "If you use the KEEP option you must specify the STORE option"
    exit(198)
  }
}

if "`noise'"~="" & "`command'"=="" {
  di in red "When specifying noise you must also specify the command option"
  exit(198)
}
if "`command'"~="" {
  if `"`parms'"'==`""' {
    di in red "To obtain any output from the command option you must also specify "
    di in red "the parameters of interest using the parms() option"
    exit(198)
  }
}
	
/************************************************
 * Loop over the number of imputed data sets 
 * required
 ************************************************/

if "`seed'"~="1" set seed `seed'

/* This is the if statement that allows the input of imputed datafiles */

if "`infiles'"~="" {
   local i 1
   tokenize "`infiles'"
   while "`1'"~="" {
      use "`1'",replace
      mac shift 1
      if "`command'"=="" {
         di in red "You must use the command option when using INFILES"
         exit(198)
      } 
      if "`noise'"~=""  `command' 
      else qui `command'  	                                    /* Do the analysis		*/
      _parms, parms(`"`parms'"') command(`command') iter(`i')	/* Select Parameters of interest*/
      local i=`i'+1
   }
   local impute=`i'-1
}


/* If there are no INFILES .. then just have to create the imputed datasets and analyse them */
else {
  forv i =1/`impute' {

/* Use original dataset   */
    use "`olddata'",replace					
    qui keep if `touse'

/* Impute values          */
    if "`by'"~="" _hotdeck `varlist', by(`by') i((`seed'+`i')) `noseed'
    else _hotdeck `varlist', i((`seed'+`i')) `noseed' 				

/* Save imputed datasets	*/
    if "`store'"~="" {					
      if "`using'"=="" local using "imp"
        if "`keep'"=="" {
          qui keep `varlist' `by'
          qui save `using'`i',replace
        }
        else {
          mkvlist `varlist' `by', vlist(`keep')
          qui keep `r(vlist)'
          qui save `using'`i',replace
        }
      }
      if "`command'"~="" {

/* Do the analysis		*/
         if "`noise'"~=""  `command' 
         else qui `command'  							

/* Select Parameters of interest*/
         _parms, parms(`"`parms'"') command(`command') iter(`i')	
      }

  }
}


/********************************************************
 * Loop to calculate the estimates needed
 *
 * First get the dimensions of the parameter matrices
 ********************************************************/

if "`command'"~="" {
  local dim= rowsof(impV1)
  mat Qbar = J(1,`dim',0)
  mat Ubar = J(`dim',`dim',0)

/* calc the averaging factor */
  local inv = 1/`impute'

/* calc the average coef and variance qbar and ubar */
  forv i=1/`impute' {
    mat Qbar= `inv'*impb`i'+ Qbar
    mat Ubar= `inv'*impV`i'+ Ubar
  }

/* calc between variances */
  mat B=J(`dim',`dim',0)
  local inv1 = 1/(`impute'-1)

  forv i=1/`impute' {
    mat B= B + `inv1'*(impb`i' - Qbar)'*(impb`i' - Qbar)
  }

/* Calc total variance */
  mat T = Ubar+(1+1/`impute')*B

  cap mat tempmt=B*inv(Ubar)
  if _rc==504 {
    di as error "WARNING: Trying to invert variance matrix with zero elements?"
    local ter = rowsof(Ubar)
    mat temp = J(`ter',1,1)
    mat temp2 = Ubar*temp
    local tei 1
    local names: colfullnames impb1
    matrix rownames temp2 = `names'
    while `tei'<=`ter' {
      if temp2[`tei',1]==0 {
        local var:word `tei' of "`names'"
        di as txt "Variance for covariate `tei' is 0 !!"
      }
      local tei=`tei'+1
    }
    mat tempmt=B*inv(Ubar)
  }

  local trace=trace(tempmt)

/* Everything hunky dorey until now... a strange 1 appears.. */
  local r1 = 1-((1+1/`impute')*`trace'/`dim')

/************************************************
 * Just sorting out the matrix names
 ************************************************/
  local  names: rowfullnames impb1
  matrix rownames Qbar = `names'
  local  names: colfullnames impb1
  matrix colnames Qbar = `names'
  local  names: rowfullnames impV1
  matrix rownames T = `names'
  matrix rownames B = `names'
  matrix rownames Ubar = `names'
  local  names: colfullnames impV1
  matrix colnames T = `names'
  matrix colnames B = `names'
  matrix colnames Ubar = `names'

  mat Tsurr= `r1'*T
  mat D = Qbar*inv(Tsurr)*Qbar'

  local D1 = D[1,1]/`dim'
  local t=`dim'*(`impute'-1)
  local v1= 4+(`t'-4)*(1+(1-2/`t')*1/`r1')^2
  local ftest= fprob(`dim',`v1',`D1')

/********************************************************
 * The next will output the main results in Stata style 
 * if the normal approximation is good then you could 
 * use the matrix post command
 ********************************************************/
  
  if "`quiet'"=="" {
    if `r1'<0 {
      di in red "WARNING: between se larger than within se in one or more "
      di in red "parameters invalidating the global F test"
    }
    if `t'<4 {
      di in red "WARNING: t less than 4 invalid global test "
      di in red "increase parameters OR imputations"
    }
  }

  di
  di in gr _col(1) "Number of Obs.",  _col(45) "= ", as res %5.0f _N
  di in gr _col(1) "No. of Imputations",  _col(45) "= ", as res %5.0f `impute'


  if "`infiles'"=="" di in gr _col(1) "% Lines of Complete Data", _col(45) "= ", as res %10.4f `miss'*100, as text "%"
  di in gr _col(1) "F(",%6.3f `v1',",`dim')", _col(45) "= ", as res %10.4f `D1'
  di in gr _col(1) "Prob > F " , _col(45) "= ", as res %10.4f `ftest'
  di "{text}{dup 14:{c -}}{c TT}{dup 68:{c -}}"

  local names: colfullnames impb1


/* Transform the double quoted names to a macrolist */

  di in gr _continue "Variable" _col(15) "{c |}",_col(17) "Average", _col(28) "Between", _col(38) "Within", _col(48) "Total", _col(58) "df", _col(68) "t", _col(77) "p-value"
  di
  di in gr _continue _col(15) "{c |}", _col(17) "Coef.",_col(28) "Imp. SE", _col(38) "Imp. SE", _col(47) "  SE", _col(58) "", _col(68) "", _col(74) ""
  di
  di _continue "{text}{dup 14:{c -}}{c +}{dup 68:{c -}}"

  foreach name of local names {
    di
    mat qhat=Qbar[1,"`name'"]
    mat b=B["`name'","`name'"]
    mat u=Ubar["`name'","`name'"]
    mat t=T["`name'","`name'"]
    local df = (`impute'-1)*(1+(u[1,1])/((1+1/`impute')*b[1,1]))^2
    local ttest= qhat[1,1]/sqrt(t[1,1])
    di as text _continue "`name'",_col(15) "{c |}", as res _col(10) %7.4f qhat[1,1],_col(17) %9.3f sqrt(b[1,1]), _col(25) %9.3f sqrt(u[1,1]), _col(34) %9.3f sqrt(t[1,1]), _col(44) %9.1f `df', _col(53) %9.3f `ttest', _col(62) %9.3f tprob(`df',`ttest')
  }


di
di _continue "{text}{dup 14:{c -}}{c +}{dup 68:{c -}}"
di
local name : word 1 of `names'
local i 1
di in gr _continue "Variable", _col(15) "{c |}", _col(17) "[$S_level% Conf. Interval]"
di
di _continue "{text}{dup 14:{c -}}{c +}{dup 68:{c -}}"
while "`name'"~="" {
  di 
  mat qhat=Qbar[1,"`name'"]
  mat b=B["`name'","`name'"]
  mat u=Ubar["`name'","`name'"]
  mat t=T["`name'","`name'"]
  local df = (`impute'-1)*(1+(u[1,1])/((1+1/`impute')*b[1,1]))^2
  local ttest= qhat[1,1]/sqrt(t[1,1])

  local prob = 1-((100-$S_level)/2)/100
  local tvalue=abs( invttail(`df',`prob') )
/* The t-distribution function could be very out here.... due to a version 6 bug! 
  version 6 : local tvalue = invt(`df',`prob')

THIS HAS BEEN REMOVED 15Aug07 as the probability is calculated on  adding the two tails AND it should have been 
a single tailed value!!!
*/



  local left = qhat[1,1]-`tvalue'*sqrt(t[1,1])
  local right = qhat[1,1]+`tvalue'*sqrt(t[1,1])
  di as text _continue "`name'",_col(15) "{c |}", as res %9.4f `left', %9.4f `right'
  local i=`i'+1
  local name : word `i' of `names'
}
di ""
di "{text}{dup 14:{c -}}{c BT}{dup 68:{c -}}"

} /* end of command if statement */

restore
end

/****************************************************
 * The approximate Bayesian Bootstrap hotdecking
 ****************************************************/

program define _hotdeck
version 9.0
syntax [varlist] [using], [BY(string) Iseed(string) NOSEED]

local iseed =`iseed'

tokenize "`varlist'"
local z "ipattern"

if "`by'"!="" confirm ex var `by'
	
tempvar nobs bstrp b2strp temp temp2

local nold = _N
local nnew = _N

/* This is the place of difference for a set seed command ..*/

if "`noseed'"=="" set seed `iseed'
qui sort `by' `z' `varlist'




qui gen long `nobs' = (`z'!=.)

if "`by'"=="" {
  qui replace `nobs' = sum(`nobs')
  qui replace `nobs' = `nobs'[_N]
  qui gen long `bstrp' = int(uniform()*`nobs'+1)
  qui gen long `b2strp' = int(uniform()*`nobs'+1)
  qui gen long `temp' = `bstrp'[`b2strp']
  qui replace `bstrp' = `temp'
  qui replace `bstrp' = _n if _n<=`nobs'
  qui tokenize "`varlist'"
  while "`1'"~="" {
    qui gen `temp2' = `1'[`bstrp']
    qui replace `1' = `temp2'
    qui drop `temp2'
    qui mac shift 1
  }
}
else {
  qui by `by': replace `nobs' = sum(`nobs')
  qui by `by': replace `nobs' = `nobs'[_N]
  qui by `by': gen long `bstrp' = int(uniform()*`nobs'+1)
  qui by `by': gen long `b2strp' = int(uniform()*`nobs'+1)
  qui by `by': gen long `temp' = `bstrp'[`b2strp']
  qui by `by': replace `bstrp' = `temp'
  qui by `by': replace `bstrp' = _n if _n<=`nobs'

  qui tokenize "`varlist'"
  while "`1'"~="" {
    qui by `by': gen `temp2' = `1'[`bstrp']
    qui by `by': replace `1' = `temp2'
    qui mac shift 1
    qui drop `temp2'
  }

}
 

end

/*******************************************************************
 * Get the parameters or a subset of them from the 
 * model and the subset 
 * the covariance variance matrix as well
 * Note that this section can also handle non-regression commands 
 * and macro lists
 *******************************************************************/

program define _parms
syntax [varlist], [PARMS(string asis) ITER(integer 1) COMMAND(string) GENerate(string) REPlace]


/*
 previously accepted a varlist in the parms string.. too many difficulties with multiple equation models
 so this code below is being dropped

* local 0 "`parms'"
* while "`parms'"~="" {
*  gettoken 0 parms: parms , parse(" ,")
*  cap syntax [varlist]
*  if _rc~=0 { 
*    if "`0'"=="_cons" local vlist "`vlist' `0'"    <-- just extract _cons
*    else local plist "`plist' `0'" 
*  }
*  else local vlist "`vlist' `varlist'" 
* }
*/


foreach item in `"`parms'"' {
  local vlist `"`vlist' `item'"'
}

/* if results were not part of a regression command */

if "`e(cmd)'"=="" {
  local names ""
  if `iter'==1 di in red "Using Non Regression Parameters and Command" 
  tokenize "`plist' `vlist'"

  local np=0
  while "`1'"~="" {
    local names1 ="`names1' `1'"
    local names2 ="`names2' `2'"
    if "`2'"=="" {
      di in red "Must supply variance estimate of `1'"
	exit(302)
    }
    mac shift 2
    local `np++'
  }
  mat impb`iter' = J(1,`np',0)
  mat impV`iter' = J(`np',`np',0)

  tokenize "`plist' `vlist'"
  local np 1

  while "`1'"~="" {

    if "$`1'"=="" & "``1''"=="" {
       di in red "Global = $`1' Local = ``1''"
       di in red "Global/local macro `1' is missing "
			exit(198)
    }

    if "``1''"~="" mat impb`iter'[1,`np'] = ``1'' 
    if "$`1'"~="" & "``1''"==""  mat impb`iter'[1,`np'] = $`1' 
    if "$`2'"=="" & "``2''"=="" {
       di in red "Global = $`2' Local = ``2''"
	 di in red "Global/local macro `2' is missing "
	 exit(198)
    }
    if "``2''"~=""  mat impV`iter'[`np',`np'] = ``2'' 
    if "$`2'"~="" & "``2''"==""  mat impV`iter'[`np',`np'] = $`2' 

    local np=`np'+1
    mac shift 2
  }
	
	matrix colnames impb`iter'=`names1'
	matrix colnames impV`iter'=`names1'
	matrix rownames impV`iter'=`names1'
}

/* The regression-type output part */
else {
  matrix myb = e(b)
  matrix myV = e(V)

/* This next statement is to handle double quoted strings.. otherwise parms will contain one item in a macro */

  local teparms :di `parms'
  local first 1
  foreach item of local teparms {

    if `first'==1 {
      cap mat impb`iter' = myb[.,"`item'"]
      if _rc==111 {
        di as error `" Attempted to extract `item' from e(b) "'
        mat list e(b)
        di as error "Check the matrix of estimates and only include column names in the parameters NOT variable names"
        exit(111)
      }
      mat impVt`iter'= myV[.,"`item'"]
    }
    else {
      mat temp = myb[.,"`item'"]    
	mat impb`iter'= impb`iter' , temp
      mat drop temp

      mat temp=myV[.,"`item'"]
	mat impVt`iter'= impVt`iter' , temp
      mat drop temp
    }

    local `first++'
  }

  local first 1
  foreach item of local teparms {
      if `first'==1 mat impV`iter' = impVt`iter'["`item'",.]
      else {
        mat temp=impVt`iter'["`item'",.]
	  mat impV`iter'= impV`iter' \ temp
      }
      local `first++'
  }

}

end

/*************************************************
 * Look at the missing pattern in the varlist
 *************************************************/

program define _misspat,rclass
syntax varlist [if] [in] , [BY(string) ]
tokenize "`varlist'"
tempvar touse2 tempid

qui gen long `tempid'=_n

mark `touse2' `if' `in'
markout `touse2'

qui gen str50 pattern=""

local allstr ""
while "`1'"~="" {
  qui replace pattern = cond(`1'==.,pattern+"*",pattern+"-") if `touse2'
  local allstr="-`allstr'"
  mac shift 1
}

qui compress pattern
sort pattern
lab var pattern "Missing pattern"
di
di in green "Missing Patterns"
di "{text}{dup 16:{c -}}"
di
di in green "Table of the Missing data patterns "
di in green " * signifies missing and - is not missing"
di
di "Varlist order: `varlist'"
 
tab pattern if `touse2'
local n=r(N)

qui count if pattern=="`allstr'" & `touse2'

if r(N)==`n' {
 di "There is no missing data in the varlist"
 exit(198)
}

return scalar nmiss = `n'-r(N)
return local allpat = "`allstr'"

qui gen ipattern=cond(pattern=="`allstr'",1,.) if `touse2'

/*****************************************
 * Calculate stratum missing numbers
 *****************************************/

if "`by'"~="" {
  di
  di "{text}STRATUM information"
  di "{text}{dup 19:{c -}}"
  di
  di "{text} Listing the number observed (No_obs) and "
  di in green "the number missing (No_miss) in each stratum"
  tempvar cnt mcnt
  qui sort `by'
  qui by `by':gen `cnt'=sum(ipattern)
  qui by `by':gen `mcnt'=sum(ipattern==.)
  qui by `by': replace `cnt'=cond( _n==_N,`cnt',.)
  qui by `by': replace `mcnt'=cond( _n==_N,`mcnt',.)
  rename `cnt' No_obs
  rename `mcnt' No_miss
  l `by' No_obs No_miss if No_obs~=., noobs
  di 
  qui count if No_obs==0
  if `r(N)'>0 {
    di in red "WARNING: `r(N)' strata with NO complete records" 
    di
    di "{error}This implies that within these strata the missing data will NOT be replaced "
    di "and hence will give the wrong answers in the analysis because the analysis"
    di "command will do casewise deletion"
  }
  qui count if No_obs==1
  if `r(N)'>0 di in blue "Note: `r(N)' strata with only 1 complete record"
  qui count if (No_obs>1 & No_obs<6)
  if `r(N)'>0 di in blue "Note: `r(N)' strata with 2-5 complete records"
  di
}

/* I thought that the following bit of command might've sorted out the seed problem :( but I don't think so */
qui sort `tempid'
end

/*************************************************
 * Expand stata syntax
 *************************************************/

program define mkvlist, rclass
syntax varlist, VLIST(string)

local o_vlist "`varlist'"
local keep "`vlist'"
local 0 "`keep'"
while "`keep'"~="" {
   gettoken 0 keep: keep , parse(" ,")
   cap syntax [varlist]
   if _rc~=0 { 
     if "`0'"=="_cons" local vlist "`vlist' `0'"
     else local plist "`plist' `0'" 
   }
   else local vlist "`vlist' `varlist'"
}
return local vlist "`o_vlist' `vlist'"

end


