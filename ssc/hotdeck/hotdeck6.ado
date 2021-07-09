*! Date        : 1 Aug 2005
*! Version     : 1.64
*! Authors     : Adrian Mander/David Clayton
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*! Description : Hotdeck imputation

program define hotdeck6
version 6.0
syntax [varlist] [if] [in] [using/], [BY(varlist) IMPute(integer 1) STORE GENerate(string) COMmand(string) PARMS(string) REPlace NOISE KEEP(varlist) SEED(string) QUIET INFILES(string) ] 
tokenize "`varlist'"
local z "`1'"

preserve
if "`if'"~="" {
  qui keep `if'
}


/* Check the seed option */
if "`seed'"=="1" { local seed 2}
if "`seed'"=="" { local seed 1 }
confirm number `seed'

/* To generate a seed from the time */
if `seed'==1 {
  local time = "$S_TIME"
  local date = "$S_DATE"
  tokenize "`time'", parse(":") 
  local seed1 "`1'`3'`5'"
  tokenize "`date'", parse(" ")
  local dat "`1'`2'`3'"
  local dat1 = date("`dat'","dmy")
  local seed1 "`seed1'`dat1'"
  di
  local l_seed "2^31-1"
  local seed1 = mod(`seed1',`l_seed')
  di in green "Seed is `seed1'"
  set seed `seed1'

}



estimates clear
tempfile olddata

/*NOT SURE if I must implement no strings in BY() option
tokenize "`by'"
while "`1'"~="" {
  confirm numeric variable `1'
  mac shift 1
}
*/
  
tempvar touse
mark `touse' `if' `in'
markout `touse' `by', strok

di in green "DELETING all matrices...."
mat drop _all


if "`infiles'"=="" {
  if "`by'"=="" { _misspat `varlist' `if' `in' }
  else { _misspat `varlist' `if' `in', by(`by') }
  local nfill=r(nmiss)
}

qui save "`olddata'"

if "`infiles'"=="" {
   global allpat = r(allpat)
   count if `touse'
   local miss = (r(N)-`nfill')/r(N)
}

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
	if "`parms'"=="" {
		di in red "To obtain any output from the command option you must also specify "
		di in red "the parameters of interest using the parms() option"
		exit(198)
	}
}
	
/************************************************
 * Loop over the number of imputed data sets 
 * required
 ************************************************/

if "`seed'"~="1" {set seed `seed'}

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
      if "`noise'"~="" { `command' }
      else { qui `command'  }		 	/* Do the analysis		*/
       _parms, parms(`parms') command(`command') iter(`i')	/* Select Parameters of interest*/
      local i =`i'+1
   }
   local impute=`i'-1
}

else {
   local i 1
   while `i'<= `impute' {
      use "`olddata'",clear					/* Use original dataset		*/
      qui keep if `touse'

      if "`by'"~="" { _hotdeck `varlist', by(`by')  }
      else { _hotdeck `varlist' }				/* Impute values		*/
      if "`store'"~="" {					/* Save imputed datasets	*/
        if "`using'"=="" {
            local using "imp"
         }
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
         if "`noise'"~="" { `command' }
         else { qui `command'  }			/* Do the analysis		*/
         _parms, parms(`parms') command(`command') iter(`i')	/* Select Parameters of interest*/
      }
   local i=`i'+1
   }
}

if "`command'"~="" {

/********************************************************
 * Loop to calculate the estimates needed
 *
 * First get the dimensions of the parameter matrices
 ********************************************************/

local dim= rowsof(impV1)
mat Qbar = J(1,`dim',0)
mat Ubar = J(`dim',`dim',0)

/* calc the averaging factor */
local inv = 1/`impute'

/* calc the average coef and variance qbar and ubar */
local i 1
while `i'<= `impute' {
	mat Qbar= `inv'*impb`i'+ Qbar
	mat Ubar= `inv'*impV`i'+ Ubar
local i=`i'+1
}

/* calc between variances */
mat B=J(`dim',`dim',0)
local inv1 = 1/(`impute'-1)

local i 1
while `i'<= `impute' {
	mat B= B + `inv1'*(impb`i' - Qbar)'*(impb`i' - Qbar)
local i=`i'+1
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
  local  names: colfullnames(impb1)
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
local r1 = 1-((1+1/`impute')*`trace'/`dim')
local  names: rowfullnames(impb1)
matrix rownames Qbar = `names'
local  names: colfullnames(impb1)
matrix colnames Qbar = `names'

local  names: rowfullnames(impV1)
matrix rownames T = `names'
matrix rownames B = `names'
matrix rownames Ubar = `names'
local  names: colfullnames(impV1)
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
	di in red "WARNING: t less than 4 invalid global test increase "
	di in red "parameters OR imputations"
}
}
di
di in gr _col(1) "Number of Obs.", _col(45) "   = ", _N
di in gr _col(1) "No. of Imputations", _col(48) "= ", `impute'

if "`infiles'"=="" {
  di in gr _col(1) "% Lines of Missing Data", _col(45) "   = ", `miss'*100,"%"
}
        
di in gr _col(1) "F(",%6.3f `v1',",`dim')", _col(45) " = ", %9.4f `D1'
di in gr _col(1) "Prob > F " , _col(45) "   = ", %9.4f `ftest'

	di in gr _dup(83) "-"
	local  names: colfullnames(impb1)
	local name : word 1 of `names'
	local i 1
	di in gr _continue "Variable     |",_col(12) "Average",_col(21) "Between", _col(30) "Within", _col(40) "Total", _col(50) "df", _col(59) "t", _col(65) "p-value"
	di
	di in gr _continue"             |",_col(12) "Coef.",_col(21) "Imp. SE", _col(30) "Imp. SE", _col(39) "  SE", _col(50) "", _col(59) "", _col(65) ""
	di
	di in gr _continue "-------------+---------------------------------------------------------------------"

	while "`name'"~="" {
		di 
		mat qhat=Qbar[1,"`name'"]
		mat b=B["`name'","`name'"]
		mat u=Ubar["`name'","`name'"]
		mat t=T["`name'","`name'"]
		local df = (`impute'-1)*(1+(u[1,1])/((1+1/`impute')*b[1,1]))^2
		local ttest= qhat[1,1]/sqrt(t[1,1])
		di _continue "`name'",_col(9) "|", _col(10) %7.4f qhat[1,1],_col(17) %9.3f sqrt(b[1,1]), _col(25) %9.3f sqrt(u[1,1]), _col(34) %9.3f sqrt(t[1,1]), _col(44) %9.1f `df', _col(53) %9.3f `ttest', _col(62) %9.3f tprob(`df',`ttest')
		local i=`i'+1
		local name : word `i' of `names'
	}
	di
	di in gr _continue "-------------+---------------------------------------------------------------------"
	di
	local name : word 1 of `names'
	local i 1
	di in gr _continue "Variable     |",_col(12) "[$S_level% Conf. Interval]"
	di
	di in gr _continue "-------------+---------------------------------------------------------------------"
	while "`name'"~="" {
		di 
		mat qhat=Qbar[1,"`name'"]
		mat b=B["`name'","`name'"]
		mat u=Ubar["`name'","`name'"]
		mat t=T["`name'","`name'"]
		local df = (`impute'-1)*(1+(u[1,1])/((1+1/`impute')*b[1,1]))^2
		local ttest= qhat[1,1]/sqrt(t[1,1])
		local prob = 1-((100-$S_level)/2)/100
		local tvalue = invt(`df',`prob')
		local left = qhat[1,1]-`tvalue'*sqrt(t[1,1])
		local right = qhat[1,1]+`tvalue'*sqrt(t[1,1])
		di _continue "`name'",_col(9) "|", %9.4f `left', %9.4f `right'
		local i=`i'+1
		local name : word `i' of `names'
	}
	di ""
	di in gr _dup(83) "-"

} /* end of command if statement */

restore
end

/****************************************************
 * The approximate Bayesian Bootstrap hotdecking
 ****************************************************/

program define _hotdeck
version 6.0
syntax [varlist] [using], [BY(string)]
tokenize "`varlist'"
local z "ipattern"

if "`by'"!="" {
  confirm ex var `by'
}
	
tempvar nobs bstrp b2strp temp temp2

qui {
  local nold = _N
  local nnew = _N
  sort `by' `z' `varlist'
  gen long `nobs' = (`z'!=.)

  if "`by'"=="" {
    replace `nobs' = sum(`nobs')
    replace `nobs' = `nobs'[_N]
    gen long `bstrp' = int(uniform()*`nobs'+1)
    gen long `b2strp' = int(uniform()*`nobs'+1)
    gen long `temp' = `bstrp'[`b2strp']
    replace `bstrp' = `temp'
    replace `bstrp' = _n if _n<=`nobs'
 
    tokenize "`varlist'"
    while "`1'"~="" {
      gen `temp2' = `1'[`bstrp']
      replace `1' = `temp2'
      drop `temp2'
      mac shift 1
    }
  }
  else {
    by `by': replace `nobs' = sum(`nobs')
    by `by': replace `nobs' = `nobs'[_N]
    by `by': gen long `bstrp' = int(uniform()*`nobs'+1)
    by `by': gen long `b2strp' = int(uniform()*`nobs'+1)

    by `by': gen long `temp' = `bstrp'[`b2strp']
    by `by': replace `bstrp' = `temp'

    by `by': replace `bstrp' = _n if _n<=`nobs'

    tokenize "`varlist'"
    while "`1'"~="" {
      by `by': gen `temp2' = `1'[`bstrp']
      
      by `by': replace `1' = `temp2'
      mac shift 1
      drop `temp2'
    }
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
 syntax [varlist], [PARMS(string) ITER(integer 1) COMMAND(string) GENerate(string) REPlace]

local 0 "`parms'"
while "`parms'"~="" {
	gettoken 0 parms: parms , parse(" ,")
	cap syntax [varlist]
	if _rc~=0 { 
		if "`0'"=="_cons" { local vlist "`vlist' `0'" }
		else { local plist "`plist' `0'" }
	}
	else {  local vlist "`vlist' `varlist'" }
}

* if results were not part of a regression command

if "`e(cmd)'"=="" {
	local names = ""
	if `iter'==1 { di in red "Using Non Regression Parameters and Command" }
	tokenize "`plist' `vlist'"

	local np=0
	while "`1'"~="" {
		local names1 ="`names1' `1'"
		local names2 ="`names2' `2'"
		if "`2'"=="" { di in red "Must supply variance estimate of `1'"
			exit(302)
		}
		mac shift 2
		local np = `np'+1
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

                if "``1''"~="" { mat impb`iter'[1,`np'] = ``1'' }
                if "$`1'"~="" & "``1''"=="" { mat impb`iter'[1,`np'] = $`1' }
		if "$`2'"=="" & "``2''"=="" {
                   di in red "Global = $`2' Local = ``2''"
		   di in red "Global/local macro `2' is missing "
		   exit(198)
		}
                if "``2''"~="" { mat impV`iter'[`np',`np'] = ``2'' }
                if "$`2'"~="" & "``2''"=="" { mat impV`iter'[`np',`np'] = $`2' }

	local np=`np'+1
	mac shift 2
	}
	
	matrix colnames impb`iter'=`names1'
	matrix colnames impV`iter'=`names1'
	matrix rownames impV`iter'=`names1'
}
else {
	matrix myb = get(_b)
	matrix myV = get(VCE)
	tokenize "`vlist' `plist'"
	if "`2'"~="" { 
         	cap mat impb`iter' = myb[.,"`1'"]
                if _rc==111 {
                  di as error "Are you sure `1' is in the model??"
                  di as error "Check the matrix of estimates and only include column names in the parameters NOT variable names"
                  exit(111)
                }
		mac shift 1
		while "`1'"~="" {
		mat temp=myb[.,"`1'"]
		mat impb`iter'= impb`iter' , temp
		mac shift 1
		}

		tokenize "`vlist' `plist'", parse(" ")
		mat impVt`iter' = myV[.,"`1'"]
		mac shift 1
		while "`1'"~="" {
			mat temp=myV[.,"`1'"]
			mat impVt`iter'= impVt`iter' , temp
			mac shift 1
		}

		tokenize "`vlist' `plist'", parse(" ")
		mat impV`iter' = impVt`iter'["`1'",.]
		mac shift 1
		while "`1'"~="" {
			mat temp=impVt`iter'["`1'",.]
			mat impV`iter'= impV`iter' \ temp
			mac shift 1
		}

		mat drop myb
		mat drop myV
		mat drop impVt`iter'
		mat drop temp
	}
	else {
		cap mat impb`iter' = myb[.,"`1'"]
                if _rc==111 {
                  di as error "Are you sure `1' is in the model??"
                  exit(111)
                }
		mat impVt`iter'=myV[.,"`1'"]
		mat impV`iter' = impVt`iter'["`1'",.]
	}
}
end

/*************************************************
 * Look at the missing pattern in the varlist
 *************************************************/

program define _misspat,rclass
syntax varlist [if] [in] , [BY(string) ]
tokenize "`varlist'"
tempvar touse2

mark `touse2' `if' `in'
markout `touse2'

qui gen str40 pattern=""

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
di in green "----------------"
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
  di in green "STRATUM information"
  di in green "-------------------"
  di
  di in green "Listing the number observed (No_obs) and "
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
  if `r(N)'>0 { di in red "WARNING: `r(N)' strata with NO observed data" }
  qui count if No_obs==1
  if `r(N)'>0 { di in blue "`r(N)' strata with only 1 observed data"}
  qui count if (No_obs>1 & No_obs<6)
  if `r(N)'>0 { di in blue "`r(N)' strata with 2-5 observed data"}
  di
}

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
     if "`0'"=="_cons" {
       local vlist "`vlist' `0'"
     }
     else { local plist "`plist' `0'" }
   }
   else {
     local vlist "`vlist' `varlist'"
   }
}
	return local vlist "`o_vlist' `vlist'"

end


