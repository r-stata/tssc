*! Date        : 21 Feb 2011
*! Version     : 1.47
*! Authors     : Adrian Mander/David Clayton
*! Email       : adrian.mander@mrc-bsu.cam.ac.uk
*! Description : Weighted Hotdeck imputation

/*
21/2/11 v1.47  Found a bug with the global macro variable substitution $`1' NOT solved yet!
*/

/* e.g. whotdeck y xmiss zy z, predmis(y z zy) command(logit y xmiss, nolog) parms(xmiss _cons)  impute(50)  
* whotdk4 y zy xmiss z, predmis(y z zy) command(logit y xmiss, nolog) parms(xmiss _cons)  impute(50)  
*/

program define whotdeck
 version 6.0
 syntax [varlist] [if] [in] [using/] , PREDMIS(string) [ BY(string) IMPute(integer 2) STORE GENerate(string) COMMAND(string) PARMS(string) REPlace OUTPUT NOISE QUIET ]
 tokenize "`varlist'"
 preserve
 estimates clear

di in red "WARNING: this program will run incorrectly unless you execute it in Stata version 7 or earlier"
tempfile olddata

/******************************************
 * Check which part of the dataset to use
 ******************************************/
tempvar touse
mark `touse' `if' `in'
markout `touse' `by'

di in ye "DELETING all matrices...."
mat drop _all

matrix debug=J(3,`impute',0)

/****************************************************
 * The missing data pattern given the variable list
 ****************************************************/
_misspat `varlist'
global allpat = r(allpat)
local miss = (_N-r(nmiss))/_N


/****************************************************
 * Argument checking
 ****************************************************/
if "`by'"~="" {
  di in red "The by command has been disabled ..."
  local by ""
}

if "`command'"=="" {
  di in red "WARNING: When the <command> option is not selected "
  di in red "then no analysis is performed on the imputed datasets "
  if "`store'"=="" {
	di "ALSO STORE isnt selected so hotdeck will appear to do nothing" 
	exit(198)
  }
}
if `impute'<1 {
	di in red "The number of imputations should be more than 0, not `impute'"
	exit(666)
}

if `impute'==1 {
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
 * Loop for the number of imputed data sets 
 * required
 ************************************************/

qui save `olddata'

local i 1
while `i' <= `impute' {
	use `olddata',clear				   		/* Use original dataset	*/
        bbsample `varlist', imp(`i')

	if "`noise'"~="" {_predmis `varlist', predmis(`predmis') `noise' }
        else { _predmis `varlist', predmis(`predmis') }
        if "`using'"=="" {
            local using "imp"
        }
        if "`store'"~="" { qui save `using'`i',replace }   	   	   	/* Save imputed datasets */

	if "`command'"~="" {
		if "`noise'"~="" { `command' }
		else { qui `command' }					/* Do the analysis */
		_parms, parms(`parms') command(`command') iter(`i')	/* Select Parameters of interest*/
 	}
local i=`i'+1
}

if "`command'"~="" {

************************************************************
* Loop to combine the estimates that have been setup during 
* the _parms command
*
* First get the dimensions of the parameter matrices
************************************************************

local dim= rowsof(impV1)
mat Qbar = J(1,`dim',0)
mat Ubar = J(`dim',`dim',0)

* calc the averaging factor
local inv = 1/`impute'

* calc the average coef and variance qbar and ubar
local i 1
while `i'<= `impute' {
	mat Qbar= `inv'*impb`i'+ Qbar
	mat Ubar= `inv'*impV`i'+ Ubar
local i=`i'+1
}

*calc between variances
mat B=J(`dim',`dim',0)
local inv1 = 1/(`impute'-1)

local i 1
while `i'<= `impute' {
	mat B= B + `inv1'*(impb`i' - Qbar)'*(impb`i' - Qbar)
local i=`i'+1
}

*Calc total variance
local tmp = 1+1/`impute'
mat T = Ubar+`tmp'*B

mat tempmt = inv(Ubar)
mat tempmt=B*tempmt
local trace=trace(tempmt)
local r1 = 1-((1+1/`impute')*`trace'/`dim')

local  names: rownames(impb1)
 matrix rownames Qbar = `names'
local  names: colnames(impb1)
matrix colnames Qbar = `names'

local  names: rownames(impV1)
matrix rownames T = `names'
matrix rownames B = `names'
matrix rownames Ubar = `names'
local  names: colnames(impV1)
matrix colnames T = `names'
matrix colnames B = `names'
matrix colnames Ubar = `names'

mat Tsurr= `r1'*T
mat D=inv(Tsurr)
mat D=Qbar*D
mat D = D*Qbar'
local D1 = D[1,1]/`dim'

local t=`dim'*(`impute'-1)
local v1= 4+(`t'-4)*(1+(1-2/`t')*1/`r1')^2

local ftest= fprob(`dim',`v1',`D1')

********************************************************
* The next will output the main results in Stata style 
* if the normal approximation is good then you could 
* use the matrix post command
********************************************************
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
di in gr _col(40) "Number of Obs.", _col(57) "   = ", _N
di in gr _col(40) "No. of Imputations", _col(57) "= ", `impute'
di in gr _col(40) "% Missing in `z'", _col(55) "   = ", `miss'*100,"%"

di in gr _col(40) "F(",%6.3f `v1',",`dim')", _col(55) " = ", %9.4f `D1'
di in gr _col(40) "Prob > F " , _col(55) "   = ", %9.4f `ftest'
if "`output'"=="" {
	di _dup(79) "-"
	local  names: colnames(impb1)
	local name : word 1 of `names'
	local i 1
	di _continue "Variable |",_col(12) "Average",_col(21) "Between", _col(30) "Within", _col(40) "Total", _col(50) "df", _col(59) "t", _col(65) "p-value"
	di
	di _continue"         |",_col(12) "Coef.",_col(21) "Imp. SE", _col(30) "Imp. SE", _col(39) "  SE", _col(50) "", _col(59) "", _col(65) ""
	di
	di _continue "---------+---------------------------------------------------------------------"

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
	di _dup(79) "-"
	local name : word 1 of `names'
	local i 1
	di _continue "Variable |",_col(12) "[$S_level% Conf. Interval]"
	di
	di _continue "---------+---------------------------------------------------------------------"
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
	di _dup(79) "-"
}
else {
	matrix post Qbar T
	matrix mlout
}
*	matrix post Qbar T

} /* end of the command if nothing in these brackets is executed no output or analysis */

restore
end

*************************************************
* Sample N_0 missing values from the N_0 missing
* Sample N_1 values from the N_1 observed
*************************************************

program define bbsample
  syntax [varlist], [IMP(integer 2)]

tempvar zz
gen `zz'=ipattern==.

tempvar nobs bstrp b2strp temp

sort `zz'

qui by `zz': gen long `nobs' = _N
qui by `zz': gen long `bstrp' = int(uniform()*`nobs'+1)

local myname=int(uniform()*10)+10*int(uniform()*10)+100*int(uniform()*10)+1000*int(uniform()*10)+10000

    tokenize "`varlist'"
    while "`1'"~="" {
      local myname=`myname'+1
      global `1'="ade`myname'"
      qui by `zz': gen $`1' = `1'[`bstrp']

      mac shift 1
    }
end


*******************************************************************
* Get the parameters or a subset of them from the 
* model and the subset 
* the covariance variance matrix as well
* Note that this section can also handle non-regression commands 
* and macro lists
*******************************************************************

program define _parms
  syntax [varlist], [PARMS(string) ITER(integer 1) COMMAND(string) GENerate(string) REPlace]

local 0 "`parms'"
while "`parms'"~="" {
	gettoken 0 parms: parms , parse(" ,")
	cap syntax [varlist]
	if _rc~=0 { 
		if "`0'"=="_cons" { local vlist="`vlist' `0'" }
		else { local plist="`plist' `0'" }
	}
	else {  local vlist="`vlist' `varlist'" }
}

/* if results were not part of a regression command */

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
		if "``1''"=="" {
			di in red "`1' is missing "
			exit(666)
		}
		if "``2''"=="" {
			di in red "`2' is missing "
			exit(666)
		}
		mat impb`iter'[1,`np'] = `1'
		mat impV`iter'[`np',`np'] = `2'
	local np=`np'+1
	mac shift 2
	}
	
	cap matrix colnames impb`iter'=`names1'
        if _rc~=0{ noi di in red "you must have macros with fewer than 8 characters"
        exit(198)}
	matrix colnames impV`iter'=`names1'
	matrix rownames impV`iter'=`names1'
}

else {
	matrix myb = get(_b)
	matrix myV = get(VCE)
	tokenize "`vlist'"
	if "`2'"~="" {
		cap mat impb`iter' = myb[.,"`1'"]
                if _rc==111 {
                  di as error "Are you sure `1' is in the model??"
                  exit(111)
                }
		mac shift 1
		while "`1'"~="" {
		  mat temp=myb[.,"`1'"]
		  mat impb`iter'= impb`iter' , temp
		  mac shift 1
		}

		tokenize "`vlist'", parse(" ")
		mat impVt`iter' = myV[.,"`1'"]
		mac shift 1
		while "`1'"~="" {
			mat temp=myV[.,"`1'"]
			mat impVt`iter'= impVt`iter' , temp
			mac shift 1
		}

		tokenize "`vlist'", parse(" ")
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

/*********************************************
 * Predict missing by a logistic regression
 *
 *********************************************/

program define _predmis
  syntax varlist, predmis(string) [ NOISE ]

/* Model to predict missingness */

qui {
 tempvar miss temp
 gen `miss'=ipattern==.
}


local str80 ade=""
tokenize "`predmis'", parse(" ")
while "`1'"~="" {
  
  local ade "`ade' $`1'"
  mac shift 1
}

qui {
 logistic `miss' `ade'

/* Predict the probability of missingness */

predict xb2

/* from the probability of missing calculate the odds of missing */

gen W1= xb2/(1-xb2)
gen weights=W1

sort `miss'

gen cprob=sum(weights) if `miss'==0
qui by `miss': replace cprob=cprob/cprob[_N]

drop xb2

/*************************************************
 * Weighted Resampling using the probabilities 
 * estimated by predmiss and sbeta
 *************************************************/

gen new=uniform() if `miss'==1
sort `miss' cprob new

gen chk=_n if `miss'==0
gen comb=cond(`miss'==0,cprob,new)
sort comb
     
gen line=1 in 1
  
replace line=cond(chk==., cond(chk[_n-1]~=.,line[_n-1]+1,line[_n-1]), chk) if _n>1
       
/* WHY? this is wrong replace line = line +`miss' */

sort cprob new
       
	tokenize "`varlist'"
	while "`1'"~="" {

                gen `temp'=$`1'[line]
		replace `1' = `temp' if `miss'==1
                drop `temp'
                drop $`1'
		mac shift 1
	}

}
estimates clear
end

*************************************************
* Look at the missing pattern in the varlist
*************************************************

program define _misspat,rclass
syntax varlist

tokenize "`varlist'"
qui gen str20 pattern=""

local allstr ""
while "`1'"~="" {
   qui replace pattern = cond(`1'==.,pattern+"*",pattern+"-")
   local allstr="-`allstr'"
mac shift 1
}
qui compress pattern
sort pattern

di
di "Table of the Missing data patterns "
di " * signifies missing and - is not missing"
di
di "Varlist order: `varlist'"
tab pattern
local n=r(N)

qui count if pattern=="`allstr'"
if r(N)==`n' {
 di in red "There is no missing data in the varlist"
 exit(198)
}
qui gen ipattern=cond(pattern=="`allstr'",1,.)

return scalar nmiss = r(N)
return local allpat = "`allstr'"

end




