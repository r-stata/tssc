
*! version 2.0.1  13may2005
*  updated to version 8 to enable streg and stcox
*  commands to work rather than gamma, gompertz, cox, etc
*  Also uses a __ prefix for constructed continuous continuous
*  interactions and the program checks for these 

program define fitint
	version 8.0

	gettoken cmd 0 : 0

/*      
   This program generates variables prefixed by a double underscore __ 
   check none already exists before proceeding and WARN user if any do
*/
	  capture renpfix __ __ 
	    if _rc==110 {
            di in red "__ prefixed variables already defined"
	    exit 110 
	    }

* Unabbrieviate those submitted commands than can be abbrieviated

        if ("`cmd'"=="clog" | "`cmd'"=="clogi") local cmd clogit
        if (substr("`cmd'",1,3)=="tob")  local cmd tobit 
        if (substr("`cmd'",1,3)=="cnr")  local cmd cnreg 
        if ("`cmd'"=="logi")  local cmd logit 
        if (substr("`cmd'",1,4)=="olog")  local cmd ologit 
        if (substr("`cmd'",1,5)=="oprob")  local cmd oprobit 
        if (substr("`cmd'",1,4)=="prob")  local cmd probit 
        if (substr("`cmd'",1,3)=="reg")  local cmd regress 


* Check the command is one of those allowed with fitint

	tokenize clogit cloglog cnreg glm logistic logit nbreg /*
	     */  ologit oprobit poisson probit regress  stcox /*
	     */  streg scobit tobit 
	local notrec=0
	local done=0
	while "`1'"~="" & `done'==0 {
		if ("`1'"=="`cmd'")  local done = 1 
		mac shift
	}
	if `done'==0 {
	  local notrec = 1
	}

	if `notrec' == 1 {
	 di in red "invalid or unrecognised command, `cmd'"
	 exit 198 
      }

* Sort out the syntax when command is stcox or streg 

	if ("`cmd'"=="stcox" | "`cmd'"=="streg") {
        syntax varlist [if] [in] [aw fw pw iw] [, FACtor(varlist) /*
        */ TWOWAY(string) noSHOW *]
	}
	else {
        gettoken yvar 0 : 0
        syntax varlist [if] [in] [aw fw pw iw] [, FACtor(varlist) /*
        */ TWOWAY(string) noSHOW *]
	}

/*
   Mark the observations not to be used to ensure that the same
   number of obervations are used in the nested models
*/

        marksample touse

* Trap the ROBUST and/or CLUSTER options and exit program if used

	  quietly capture `cmd' `yvar' `varlist', `options'
	   if "`e(vcetype)'"=="Robust"  {
            di in red "Robust or Cluster option invalid"
	      exit 198 
	   }

* Trap the no constant option and exit program if used

        local noc=index("`options'","nocon")
	  if `noc'~=0  {
            di in red "Noconstant option invalid"
	      exit 198 
        }
        if "`cmd'"=="regress" {
          local noc=index("`options'","noc")
	    if `noc'~=0  {
            di in red "Noconstant option invalid"
	      exit 198 
	    }
        }

* Decide whether a likelihood ratio or F test is required

        local fit_tst LR
	  if ("`cmd'"=="regress") local fit_tst F 
	  if "`cmd'"=="glm" {
	    quietly capture `cmd' `yvar' `varlist', `options'
	     if (e(varfunct)=="Gaussian" & e(linkt)=="Identity") local fit_tst F 
	  }

/*
   Obtain the number of predictors and tokenize
   the predictor variable list into pred1, pred2, ..., predn
*/

        local xvar "`varlist'"
        local numb : word count `xvar'
        token `xvar'

* Problems occur with duplicate entries into the varlist, trap this

local i = 1

        while `i'<`numb' {
         local j=`i'+1
           while `j'<=`numb' {
                if "``i''"=="``j''" {
                 di in red "Repeated term " "``i''" " in x-variable list"
	           exit 141 
		    }
                local j = `j'+1
           }
         local i = `i'+1
        }

        local i = 1

        while `i'<=`numb' {

                local pred`i' `1'
                macro shift

                local i = `i'+1
        }

/*
   Obtain the number of interaction terms and tokenize
   the factor variable list into int1, int2, ..., intk
*/

if "`twoway'"~="" {

     /*
     Tokenize the string into the sets of variable lists for
     which pairwise interactions are required
     */

     tokenize "`twoway'", p(",")

     local i = 1
     while "`1'"~="" {
          if "`1'"~="," {
               local intls`i'  `1'
               local i = `i'+1
          }
		macro shift
	}

	local intln = `i'-1

*   Process each list to produce the pairs of predictors

local l = 1

local i = 1
while `i' <= `intln' {

    unab intls`i' : `intls`i'', min(2) max(40) name(atleast one TWOWAY list has)

    local intn : word count `intls`i''

    token `intls`i''
    local j = 1
    while `j'<=`intn' {

         local int`j' `1'
         macro shift
         local j = `j' + 1
    }

    /*
    Check that the variables in the interaction list also
    appear in the predictor list
    */

    local j = 1

    while `j'<=`intn' {
         local k = 1
         local inc`j'=0
         while `k'<=`numb' {
              if "`int`j''"=="`pred`k''" {
                   local inc`j' = 1
              }
              local k = `k' + 1
         }
         local j = `j' + 1
    }

    local j = 1
    while `j'<=`intn' {
         if `inc`j''==0 {
              di in red "`int`j''" " not in x-variable list"
              exit 498
         }
         local j = `j' + 1
    }

    /*
    Construct the local macros that indicate the number of the
    predictors to use seperated by an underscore e.g. 1_2 1_4 2_4
    */


    local j = 1
    while `j' <= `intn' {
         local k = 1
         while `k' <= `numb' {
              if "`int`j''"=="`pred`k''" {
                   local pnum`j' = `k'
              }
              local k = `k' + 1
         }
         local j = `j' + 1
    }

    local j = 1
    while `j' < `intn' {
         local k = `j' + 1
         while `k' <= `intn' {
              if "`pnum`j''" < "`pnum`k''" {
                   local intp`l' = "`pnum`j''_`pnum`k''"
                   local l = `l' + 1
              }
              else {
                   local intp`l' = "`pnum`k''_`pnum`j''"
                   local l = `l' + 1
              }
         local k = `k' + 1
         }
    local j = `j' + 1
    }
local i = `i' + 1
}

local intpn = `l' - 1

* Check for duplicate pairs of interactions


local i = 1
while `i'<`intpn' {
    local j = `i' + 1
    local dup`i' = 0
    while `j'<=`intpn' {
         if "`intp`i''"=="`intp`j''" {
         local dup`i' = 1
         }
    local j = `j' + 1
    }
local i = `i' + 1
}
local dup`intpn' = 0 /* last pair cannot be a duplicate" */

/*
Remove any duplicate interaction pairs and rename the local macros
*/

local i = 1
local j = 1
while `i'<= `intpn' {
    if `dup`i''==0 {
         local intpr`j'="`intp`i''"
         local j = `j' + 1
    }
    local i = `i' + 1
}

local intprn = `j' - 1

/*
   Distingush between those main effects to be tested and those
   which are included in interactions
*/

local i = 1
while `i' <= `numb' {
    local j = 1
    local fit`i'= 1
    while `j' <= `intprn' {
        local pos = index("`intpr`j''","_")
        if substr("`intpr`j''",1,`pos'-1)=="`i'" | substr("`intpr`j''",`pos'+1,.)=="`i'" {
        local fit`i' = 0
        }
        local j = `j' + 1
    }
    local i = `i'+1
}


} /* This ends the IF TWOWAY EXISTS statement */
else {

/*
   Set the macros that denote a main effect to
   be tested to 1 (i.e. no interactions).
*/

   local i = 1

   while `i' <= `numb' {
         local fit`i' = 1
         local i = `i' + 1
   }
}

/*
   Obtain the number of factors and tokenize
   the factor variable list into fac1, fac2, ..., fack
*/

if "`factor'"~="" {
    token `factor'
    local facn : word count `factor'
    local pref "xi:"
    local i = 1

    while `i'<=`facn' {
         local fac`i' `1'
         macro shift
         local i = `i'+1
    }

    /*
    Check that the variables in the factor list also appear in
    the predictor list
    */

    local i = 1

    while `i'<=`facn' {
         local j = 1
         local inc`i'=0
         while `j'<=`numb' {
              if ("`fac`i''"=="`pred`j''") local inc`i' = 1               
              local j = `j'+1
         }
         local i = `i'+1
    }

    local i = 1
    while `i'<=`facn' {
         if `inc`i''==0 {
              di in red "`fac`i''" " not in x-variable list"
	      exit 498
         }
         local i = `i'+1
    }


    /*
    Prefix the predictor variables with i. where these are factors
    to enable there use with the xi command
    */

    local i = 1
    while `i'<=`numb' {
         local j = 1
         local fact`i'=0
         while `j'<=`facn' {
              if "`pred`i''"=="`fac`j''" {
                   local fact`i' = 1
              }
              local j = `j'+1
         }
         local i = `i'+1
    }

    local i = 1
    while `i'<=`numb' {
         if `fact`i''== 1 {
              local pred`i' "i.`pred`i''"
         }
         local i = `i'+1
    }
}
else {

    * Generate the local macros that identify factors containing 0

    local i = 1
    while `i'<=`numb' {
         local fact`i' = 0
         local i = `i'+1
    }
}

/*
   Generate the labels used in the table of results
*/

local i = 1
while `i'<=`numb' {
    local label`i' "`pred`i''"
    local i = `i'+1
}

if "`twoway'"~="" {

    /*
    Construct the twoway interaction terms from the
    intpr1, ... , intpr`intprn' macros
    */

    local j = `numb'+1
    local i = 1

    while `i' <= `intprn' {

         local pos = index("`intpr`i''","_")
         local first = substr("`intpr`i''",1,`pos'-1)
         local second = substr("`intpr`i''",`pos'+1,.)

         if `fact`first''== 1 {
              local pred`j' = "`pred`first''*`pred`second''"
              local label`j' = "`pred`first''*`pred`second''"
              local fit`j' = 1
         }
         else if `fact`second''== 1 {
              local pred`j' = "`pred`second''*`pred`first''"
              local label`j' = "`pred`second''*`pred`first''"
              local fit`j' = 1
         }
         else {
              gen __`j'_`k' = `pred`first''*`pred`second''
              local pred`j' = "__`j'_`k'"
              local label`j' = "`pred`first''*`pred`second''"
              local fit`j' = 1
         }
    local i=`i'+1
    local j=`j'+1
    }

* Reset the number of terms

local numb = `j'-1
}

/*
   All the setting up has been completed and the nested model sequence
   can begin.

   Reconstruct the variable list  pred1, pred2, ... , predn with
   the i. prefixed factors and place in the local macro allvar.
*/

local i = 1
while `i'<=`numb' {
    local allvar "`allvar' `pred`i''"
    local i = `i'+1
}

* Fit the orginal and nested series of models

* Original model

if "`show'"~="" {
    quietly `pref' `cmd' `yvar' `allvar' [`weight'`exp'] if `touse' == 1, `options'
}
else {
    `pref' `cmd' `yvar' `allvar' [`weight'`exp'] if `touse' == 1, `options'
}

* Obtain the information needed

if "`fit_tst'"=="LR" {
    tempname V
    mat `V'=e(V)
    local fdf=colsof(`V')-diag0cnt(`V')
    mat drop `V'
    local fdev=-2*e(ll)
    local fn=e(N)
    local dv=e(depvar)
    local cd=e(cmd)
}

if "`fit_tst'"=="F" & "`cmd'"=="regress" {
    local frss=e(rss)
    local fdf=e(df_r)
    local fn=e(N)
    local dv=e(depvar)
    local cd=e(cmd)
}

if "`fit_tst'"=="F" & "`cmd'"=="glm" {
    local frss=e(deviance)
    local fdf=e(df_pear)
    local fn=e(N)
    local dv=e(depvar)
    local cd=e(cmd)
}

* Set up the appropriate table for F-test or Chi-square test

if "`fit_tst'"=="LR" {
    #delimit ;
    di in gr _n(1) _dup(72) "-" _n
    "Fitting and testing any interactions and any main effects not included" _n
    "in interaction terms using the change in deviance from the full model" _n
    "when each term is removed in turn to obtain the likelihood ratio chi" _n
    "square statistic" _n _dup(72) "-" _n(2)
    in bl "Model summary" _n
    in gr "Number of observations used in estimation: " in ye %7.0f `fn' _n in gr
    "Regression command:  " in ye %8s "`cd'" _n in gr
    "Dependent variable:  " in ye %8s "`dv'" _n in gr
    "Full model deviance: " in ye %8.2f `fdev' _n in gr
    "degrees of freedom:  " in ye %8.0f `fdf' _n(2) in gr
    _dup(72) "-" _n %~17s "Term" _col(20) "|" _col(24)
    "Model deviance" _col(44) "Chi-square" _col(58) "df" _col(66) "P>Chi" _n
    _dup(19) "-" "+" _dup(52) "-" ;
    #delimit cr
}

if "`fit_tst'"=="F" {
    #delimit ;
    di in gr _n _dup(72) "-" _n
    "Fitting and testing any interactions and any main effects not included" _n
    "in interaction terms using the ratio of the mean square error of each" _n
    "term and the residual mean square error to obtain an F ratio statistic" _n _dup(72) "-" _n(2)
    in bl "Model summary" _n
    in gr "Number of observations used in estimation: " in ye %7.0f `fn' _n in gr
    "Regression command:  " in ye %14s "`cd'" _n in gr
    "Dependent variable:  " in ye %14s "`dv'" _n in gr
    "Residual MSE:        " in ye %14.2f `frss'/`fdf' _n in gr
    "degrees of freedom:  " in ye %14.0f `fdf' _n(2) in gr
    _dup(72) "-" _n %~17s "Term" _col(20) "|"  _col(24)
    "Mean square" _col(39) "F ratio" _col(48) "df1" _col(55) "df2"
    _col(68) "P>F" _n _dup(19) "-" "+" _dup(52) "-"  ;
    #delimit cr
}

/*
   Fit the sequence of nested models
*/

local i = 1

* Excluding each variable of interest

while `i' <= `numb' {

    if `fit`i'' == 1 {
         local j = 1
         local redvar ""

         * Construct the reduced variable list

         while `j' <= `numb' {
              if `j' ~= `i' {
                   local redvar "`redvar' `pred`j''"
              }
              local j = `j'+1
         }

         * Fit the reduced model

         quietly `pref' `cmd' `yvar' `redvar' [`weight'`exp'] if `touse'==1, `options'

         * Obtain the information needed

         if "`fit_tst'"=="LR" & "`cmd'"~="glm" {
              local rdev=-2*e(ll)
              tempname V
              mat `V'=e(V)
              local rdf=colsof(`V')-diag0cnt(`V')
              mat drop `V'
              local rn=e(N)
              local cdev=`rdev'-`fdev'
              local cdf=`fdf'-`rdf'
              local p=chiprob(`cdf',`cdev')
              #delimit ;
              di in gr _col(2) %~17s "`label`i''" _col(20) "|" in ye _col(28) %10.2f `rdev'
              _col(44) %10.2f `cdev' _col(57) %3.0f `cdf' _col(65) %6.4f `p' ;
              #delimit cr
         }


         if "`fit_tst'"=="LR" & "`cmd'"=="glm" {
              local rdev=e(deviance)
              tempname V
              mat `V'=e(V)
              local rdf=colsof(`V')-diag0cnt(`V')
              mat drop `V'
              local rn=e(N)
              local cdev=`rdev'-`fdev'
              local cdf=`fdf'-`rdf'
              local p=chiprob(`cdf',`cdev')
              #delimit ;
              di in gr _col(2) %~17s "`label`i''" _col(20) "|" in ye _col(28) %10.2f `rdev'
              _col(44) %10.2f `cdev' _col(57) %3.0f `cdf' _col(65) %6.4f `p' ;
              #delimit cr
         }

         if "`fit_tst'"=="F" & "`cmd'"=="regress" {
              local rrss=e(rss)
              local rdf=e(df_r)
              local rn=e(N)
              local ms=(`rrss'-`frss')/(`rdf'-`fdf')
              local fr=`ms'/(`frss'/`fdf')
              local df1=`rdf'-`fdf'
              local p = fprob(`df1',`fdf',`fr')
              #delimit ;
              di in gr _col(2) %~17s "`label`i''" _col(20) "|" in ye _col(23) %12.2f `ms'
              _col(38) %8.2f `fr' _col(48) %3.0f `df1' _col(55) %3.0f `fdf'
              _col(65) %6.4f `p' ;
              #delimit cr
         }

         if "`fit_tst'"=="F" & "`cmd'"=="glm" {
              local rrss=e(deviance)
              local rdf=e(df_pear)
              local rn=e(N)
              local ms=(`rrss'-`frss')/(`rdf'-`fdf')
              local fr=`ms'/(`frss'/`fdf')
              local df1=`rdf'-`fdf'
              local p = fprob(`df1',`fdf',`fr')
              #delimit ;
              di in gr _col(2) %~17s "`label`i''" _col(20) "|" in ye _col(23) %12.2f `ms'
              _col(38) %8.2f `fr' _col(48) %3.0f `df1' _col(55) %3.0f `fdf'
              _col(65) %6.4f `p' ;
              #delimit cr
         }
    }

    local i=`i'+1

}

di in gr _dup(72) "-"

capture xi
capture drop __*

end

