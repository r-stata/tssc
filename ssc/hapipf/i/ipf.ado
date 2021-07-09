*! Date    : 21 Jul 2009
*! Version : 1.40
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk

*! Iterative proportional fitting in contingency tables

/*
 1Nov2006 v1.38 Add in the squared ascii character to the output
15May2009 v1.39 Move to version 10 added extra numeric check on unique varlist
21Jul2009 v1.40 Remove the extra numeric check on unique varlist because hapipf needs strings
*/

program define ipf, rclass
version 10.0
preserve

di "{txt}Deleting all matrices......"
matrix drop _all

tempfile master
qui save "`master'"

/*********************************************************************************
 * parse the syntax fit(x*y + x*z +y*z)
 *
 * NB if the user doesn't do a varlist then the program will calculate it for you 
 * NOTE then you will have a blank varlist and you might use ulist (unique list) or 
 * vlist (variable list from fit() instead throughout
 *********************************************************************************/

syntax [varlist(default=none)] [fweight/] , FIT(string) [ CONstr(string) CONFILE(string) CONVARS(varlist) SAVE(string) EXPect NOLOG ACC(real 0.000001)]
tokenize "`varlist'"

di
di "{txt}Expansion of the various marginal models"
di "{dup 40:{c -}}"

local i 1
local vlist " "
gettoken mmodel fit:fit, parse("+")
while "`mmodel'"~="" {
   while "`mmodel'"=="+" {
     gettoken mmodel fit:fit, parse("+") 
   }

/* now split mmodel into the variables in the interaction terms */

   gettoken left mmodel:mmodel, parse("*")

/*
  Split left into the individual variables
  The resultant varlist is put into marg1-margn
*/

   while "`left'"~="" {
     while "`left'"=="*" {
       gettoken left mmodel:mmodel, parse("*") 
     }
     
     cap confirm variable `left'
     if _rc==111 di "{err}Make sure `left' exists in your dataset"
     confirm variable `left'

     local marg`i' "`marg`i'' `left'"
     gettoken left mmodel:mmodel, parse("*")
   }

/* Put the complete set of variables in vlist WITH replicates */

   local vlist "`vlist' `marg`i++''" 
   gettoken mmodel fit:fit, parse("+")
} 

/****************************************************************************
 * The next bit of the code will be able to remove the
 * multiples in the varlist constructed from the model statement
 * this is held in `vlist'
 *
 * NB: There could be a problem here if a variable in the varlist has the
 * same name as ANY local macro used in the program
 ****************************************************************************/

foreach uvar of varlist `vlist' {
  if "``uvar''"=="" {
    local ulist "`ulist' `uvar'"
    local `uvar' "seen"
  }
}

isnumeric `uvar'

/****************************************************************************
 * Take individual data as the default or else use the frequency variable
 * from the option
 ****************************************************************************/  

tempvar freqwt
if "`weight'"=="" qui gen double `freqwt'=1
else qui gen double `freqwt'=`exp'

/****************************************************************************
   Display the marginal models varlists This is part check part information 
   Make sure you DONT change the local macro i from the previous usage
 ****************************************************************************/
   
local nomargs = `i'-1
forval i=1/`nomargs' {
  di as res "marginal model `i' varlist : `marg`i'' "
}

/********************************************************************************
 * Now I need to expand to dataset to cover all possible cells and give
 * them all frequency 0 before doing a contract statement
 ********************************************************************************/

if "`varlist'"=="" {
   local ind 1
   foreach var of varlist `ulist' {
     _unique `var'
     mat u`ind'=resp
     local `var' "`r(unique)'"
     local ind = `ind'+1
   }
   tempfile temp
   qui save "`temp'",replace
   drop _all

   foreach var of local ulist {
     gen `var'=.
   }


   tokenize "`ulist'"
   
   qui set obs ``1''
   local last ""
   sort `1'
   local ind 1
   while "`1'"~="" {
      local last "`last' `1'"
      sort `last'
      qui by `last': replace `1'=u`ind'[_n,1]
      cap expand ``2''
      sort `1'
      local last "`last' `1'"
      mac shift 1
      local ind = `ind'+1
   }
   qui gen double `freqwt'=0
   sort `ulist'


}

/******************************************************
 * The varlist defines the dimension of the data space 
 * (saturated model)
 ******************************************************/

else {
   local ind 1
   tokenize "`varlist'"
   while "`1'"~="" {
     _unique `1'
     mat u`ind'=resp
     local `1' "`r(unique)'"
     local ind = `ind'+1
     mac shift 1
   }

   tempfile temp
   qui save "`temp'",replace
   drop _all
   tokenize "`varlist'"
   while "`1'"~="" {
     gen `1'=.
     mac shift 1
   }

   tokenize "`varlist'"
   qui set obs ``1''
   local last ""
   sort `1'
   local ind 1
   while "`1'"~="" {
      local last "`last' `1'"
      sort `last'
      qui by `last': replace `1'=u`ind'[_n,1]
      cap expand ``2''
      sort `1'
      local last "`last' `1'"
      mac shift 1
      local ind=`ind'+1
   }
   qui gen double `freqwt'=0
   sort `varlist'
}

/*****************************************************************
 * Calculate the model degrees of freedom. Obviously due to
 * structural zeroes and sampling zeroes the degrees of freedom
 * may be lower.
 *****************************************************************/

/* Put the name of unique variables in the macro tok`tind' */

local tind 1
foreach uvar of varlist `ulist' {
  local tok`tind' "`uvar'"
  local tind=`tind'+1
}

/* di "NOW to make an ordered set of margi's" */

local term ""

forval i=1/`nomargs' {
  local uind 1
  while `uind' <= `tind' {
    tokenize "`marg`i''"
    while "`tok`uind''"~="`1'" & "`1'"~="" {
      mac shift 1
    }
    if "`1'"~="" local term`i' "`term`i'' `1'"
    local uind = `uind'+1
  }
}

forval i=1/`nomargs' {
   local marg`i' "`term`i''"
}

/* So now marg1-margn now contain a list of factors that are in the order the varlist */
    
di "unique varlist `ulist'"
    
local term 1
forval i=1/`nomargs' {
  tokenize "`marg`i''"
  
/*
 Compare `marg`i'' to `ulist' ..... 
 I think put the variable number in the macro u1-un
*/ 

  local mind 1
  while "``mind''"~="" {
    local uind 1
    while "``mind''"~="`tok`uind''" {
      local uind=`uind'+1
    }
    local u`mind' = `uind'
    local mind = `mind'+1
  }

/*
  Take each marginal model 

  Expand out the number of interactions in the binary statement
*/

  tokenize "`marg`i''"
  
  local nterms 1
  while "``nterms''"~="" {
    local nterms=`nterms'+1
  }
  local nterms = `nterms'-1 
    local j 0
    while `j'< 2^`nterms' {
       binary `j' `nterms'
       local it 1
       local newuterms ""
       while `it'<=`nterms' {
         if "`newuterms'"=="" local newuterms "`u`r(s`it')''"
         else if "`u`r(s`it')''"~="" local newuterms "`newuterms'-`u`r(s`it')''" 
         local it = `it'+1
       }
       local nmylist "`nmylist' `newuterms'"
       local j=`j'+1
    }

}

/* Having expanded out all the interactions it is time to remove the repeats */

tokenize "`nmylist'"
local mlind 1
while "``mlind''"~="" {
  local ind 1
  while "``mlind''" ~= "``ind''" {
    local ind=`ind'+1
  }
  if (`mlind' == `ind') local nblist "`nblist' ``ind''"
  local mlind=`mlind'+1
}

/* 
  nblist contains numbered variables with interactions AND it is unique!! 
  1 2 3 4 5 6 7 8 9 10 9-10

*/

local nparms 0
foreach var of local nblist {
  local len=length("`var'")
  local prod 1
  if `len'>1 {
    local adevar "`var'"
    gettoken ade adevar: adevar, parse("-")
    while "`ade'"~="" {
      if "`ade'"~="-" local prod = `prod' * (``tok`ade'''-1) 
      gettoken ade adevar: adevar, parse("-")
   }    
  }
  else {
      local ade "`var'"
      local prod = `prod' * (``tok`ade'''-1)
  }
  local nparms = `nparms'+`prod'
}

local ncells 1
local i 1
tokenize "`ulist'"
while "``i''"~="" {
  local ncells = `ncells'* ``tok`i'''
  local i = `i'+1
}
      
/* add one for the constant term :) */

local nparms =`nparms'+1
local df = `ncells'-`nparms'
di
di "{txt}N.B.  structural/sampling zeroes may lead to an incorrect df"
di as res "{txt}Residual degrees of freedom = {res}`df'"
di as res "{txt}Number of parameters        = {res}`nparms'"
di as res "{txt}Number of cells             = {res}`ncells'"
di

/* Now I am adding in the original data.... */

qui append using "`temp'"
   
/***************************************************************************
 * Do a contracting of the dataset on the varlist since
 * the likelihood will be calculated over this space as
 * the model may be on a smaller space
 *
 * NB: the ulist should be a SUBSET of the varlist
 ***************************************************************************/

local LHOOD 0
if "`varlist'"~="" {
   local LHOOD 1
   di as text "N.B. The likelihood is calculated for the cells spanned by `varlist'"
   global tablist "`varlist'"

   sort `varlist'
   qui by `varlist': replace `freqwt'=sum(`freqwt')
   qui by `varlist': keep if _n==_N
   qui save lhood,replace
}

/*********************************************************
 *      Do a contracting of the dataset!
 * 1) This has to be done on the unique list in the model 
 *********************************************************/

sort `ulist'
qui by `ulist': replace `freqwt'=sum(`freqwt')
qui by `ulist': keep if _n==_N

/***********************************************************************
 * Initialise the Expected Frequencies to either be contained in
 * a file or by using the syntax I have devised.
 *
 *  [D==1.T==1]=2 means
 * when D is 1 AND T is 1 the expected starting value
 * is 2 the values of the D and T must be specified otherwise what will
 * the baseline category be?
 ***********************************************************************/

cap confirm new Efreq
qui gen double Efreq=.
cap confirm new Efreqold
qui gen double Efreqold = 1

if "`constr'"~="" & "`confile'"=="" {

  /* get the first variable */

  while "`constr'"~="" {
    gettoken start constr:constr,parse(",")
    gettoken part start:start,parse("[ ")
    gettoken part start:start,parse("]") 
    local conif " `part'"
    gettoken part start:start,parse("] ") 
    di "{err}replacing all values with the condition `conif' with `start'"
     qui replace Efreqold = `start' if `conif'
     gettoken start constr:constr,parse(",")
  }
}


if "`confile'"~="" {
   if "`convars'"=="" {
     di "{err} You must specify convars option when using CONFILE"
     exit(198)
   }
   drop Efreqold
   sort `convars'
   cap drop _merge
   merge `convars' using `confile'
   cap drop _merge

/*Efreqold should be in `confile' */

   cap confirm variable Efreqold
   if _rc==111 {
     di "{err} the constraints file must include Efreqold"
     exit(111)
   }
   tempvar constr constrm
   gen `constr'=(Efreqold ~=.)
   gen `constrm'=(Efreqold ==.)
   replace Efreqold=1 if Efreqold==.
}
gen double Ofreq = `freqwt'


/*********************************************************
 *      Do a contracting of the dataset!
 * Because of the merging
 *********************************************************

sort `ulist' Efreqold
qui by `ulist': replace `freqwt'=sum(`freqwt')
qui by `ulist': keep if _n==_N

*/


/*******************************************************
 * The algorithm loop that stops when the loglikelihood
 *doesnt change much
 *******************************************************/

local llh 1000
local oldllh 0
local iter 1
cap gen double marg=.
cap gen double nmarg=.
  
while (abs(`llh'-`oldllh')>`acc') {
       
   /* Sum over the marginal models */
  
   forval i=1/`nomargs' {
     
     sort `marg`i''
     qui by `marg`i'' : replace marg=sum(Efreqold)
     qui by `marg`i'' : replace nmarg=sum(Ofreq)
     qui by `marg`i'' : replace Efreq=Efreqold*(nmarg[_N]/marg[_N])
                       
     /* Make a copy of the new estimates */
     qui replace Efreqold=Efreq
   }
     
    /* Sum over the constrained section of the continguency table. */

   if "`convars'"~="" {
     sort `convars'
     qui by `convars' : replace marg=sum(Efreqold) if `constr'==0
     qui by `convars' : replace marg=marg[_N] if `constr'==0
     qui by `convars' : replace nmarg=sum(Ofreq) if `constr'==0
     qui by `convars' : replace nmarg=nmarg[_N] if `constr'==0
     qui by `convars' : replace Efreq=Efreqold*(nmarg[_N]/marg[_N]) if `constr'==0
      
     /* Make a copy of the new estimates */
     qui replace Efreqold=Efreq  if `constr'==0
   }
    
/************************************************************************
 * Calculate the Multinomial/Poisson Likelihood if a varlist else the poisson
 * sampling likelihood
 ************************************************************************/

   if "`varlist'"~="" {
     sort `varlist'
     qui save temp,replace
     qui use lhood,replace
     cap drop _merge
     merge `varlist' using temp
     cap drop _merge

     sort `ulist'
     qui by `ulist': replace Efreq=Efreq[_N]/2
     drop Ofreq
     rename `freqwt' Ofreq
     sort `varlist'
   }


/* This is kernel of likelihood only */
      
   tempvar addall
   gen double `addall' = sum( Ofreq * log(Efreq) - Efreq )

   local oldllh = `llh'
   local llh= `addall'[_N]
  if "`nolog'"=="" di "{txt}Loglikelihood = {res}`llh'"
  drop  `addall'

  local iter=`iter'+1
}


/*********************************************************
 * Pearson's and likelihood ratio tests of goodness of fit
 *********************************************************/

tempvar addmn addm
gen double `addmn'=sum(((Efreq-Ofreq)^2)/Efreq)
gen double `addm'=sum(Ofreq*log(Ofreq/Efreq))
local g2 = 2*`addm'[_N]
local x2 = `addmn'[_N]
local pv_g = chiprob(`df',`g2')
local pv_x = chiprob(`df',`x2')
di
di "{txt}Goodness of Fit Tests"
di "{dup 21:{c -}}"
di "{txt}df = {res}`df'"
di "{txt}Likelihood Ratio Statistic G{c 178} = {res}" %8.4f `g2', "{txt}p-value = {res}" %5.3f `pv_g'
di "{txt}Pearson Statistic          X{c 178} = {res}" %8.4f `x2', "{txt}p-value = {res}" %5.3f `pv_x'

drop `addm' `addmn'

/*********************************************************
 * Calculating the probabilities of each category with
 * groups defined by the varlist
 *********************************************************/

if "`varlist'"~="" {
   sort `varlist'
   qui save temp,replace
   use lhood,replace
   merge `varlist' using temp
   sort `ulist'
   qui by `ulist': replace Efreq=Efreq[_N]
   
   sort `varlist'
   qui gen double prob=sum(Efreq)
   qui replace prob=Efreq/prob[_N]
   sort `varlist'
   qui compress
   if "`expect'"~="" l `varlist' Efreq Ofreq prob, noobs nodisplay 
   if "`save'"~="" {
      keep `varlist' Efreq Ofreq prob
      cap confirm new `save'.dta
      if _rc~=0 save "`save'", replace 
      else save "`save'" 
   }
}
else {
   qui sort `ulist'
   qui gen double prob=sum(Efreq)
   qui replace prob=Efreq/prob[_N]
   qui compress
   if "`expect'"~="" l `ulist' Efreq Ofreq prob, noobs nodisplay 
   if "`save'"~="" {
      keep `ulist' Efreq Ofreq prob
      cap confirm new `save'.dta
      if _rc~=0 save "`save'", replace
      else save "`save'"
   }
}

use "`master'",replace
return local vlist "`ulist'"
return scalar df=`df'
return scalar parms=`nparms'
return scalar ncells=`ncells'
return scalar llh = `llh'
return scalar g2 = `g2'
return scalar x2 = `x2'
return scalar pvg = `pv_g'
return scalar pvx = `pv_x'
restore

end
          
/**********************************************
 * Calculate the unique values in
 **********************************************/

program define _unique, rclass
  syntax [varlist]

preserve
qui bys `varlist': keep if _n==1
qui count if `varlist'==.
if `r(N)'>0 {
  di "{err} `varlist' has missing data and missing data must be coded as an integer value"
  exit(666)
}
return scalar unique=_N
cap mkmat `varlist', matrix(resp)
if _rc~=0 {
 di "{err}Too many unique values to form resp! in _unique"
 di "{err} there are {res}"_N 
 noi list `varlist'
}
restore

end

/**********************************************
 * Work out binary
 **********************************************/

program define binary, rclass
args dec nterms

local two=2^(`nterms'-1)
local ind "`nterms'"

local rem "`dec'"
local str`nterms' bin ""
while `two'>1 {
  if `rem'>=`two' {
    return local s`ind'=`ind'
    local bin "`bin'1"
  }
  else {
    return local s`ind'=""
    local bin  "`bin'0"
  }
  local rem=mod(`rem',`two')
  
  local ind=`ind'-1
  local two=`two'/2
}
local bin "`bin'`rem'"
return local bin="`bin'"
if `rem'==0 return local s1="" 
else  return local s1=`rem' 

end

/**********************************************
 * Work out binary
 **********************************************/
/*
This was to check for string variables but I have dropped this again due to hapipf interaction
*/
pr isnumeric
/*syntax [varlist(numeric)]*/
syntax [varlist]
end

