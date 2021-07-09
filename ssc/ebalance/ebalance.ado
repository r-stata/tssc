*! version 1.5.4 Jens Hainmueller, Yiqing Xu 01/29/15
program ebalance , eclass
        version 11.2

syntax varlist(min=1 numeric fv) [if] [in] [, TARgets(numlist >0 <=3 integer) ///
                                           MANUALtargets(numlist) ///
										   BASEwt(varname numeric) ///
										   NORMconst(real 1.0) ///
                                           Generate(name) ///
										   WTTReat ///
										   MAXIter(integer 20) ///
										   TOLerance(real .015) ///
										   Keep(string) ///
										   REPlace]

qui: marksample touse // exclude obs with missng data
tempvar baseweight treated controls

/* Initial Checks */
preserve // in case one of the checks fails

/* check new variable name */
if "`generate'"=="" {
  loc generate = "_webal"
}
cap confirm variable `generate', exact
if _rc == 0 {
   if "`generate'"=="_webal" {
	 cap drop _webal   
   }
   else {
     dis as err "variable `generate' already defined"
     exit	 
   }
}

/* check replace under keep() */
if ("`keep'" == "" & "`replace'" != "") {
  dis as err "option replace invalid -- keep() is not specified"
  exit
}


/* check file already exists */
if ("`keep'" != "" & "`replace'" == "") {
  confirm new file `keep'
  confirm new file `keep'.dta
}


/* check for treatment indicator and colinearity  */
if ("`manualtargets'"!="") { // manual mode: single group where treat is omitted
  if ("`targets'"!="") {
    dis as err "targets() and manualtargets() are not compatible"
	exit
  }
  if "`wttreat'"!="" {
	dis as err "wttreat and manualtargets() are not compatible"
	exit
  }
  * check number of observations
  qui: count if  `touse' == 1  
  if (`r(N)' <= 1) {
      dis as err "insufficient observations"
      exit
  }	
  * create factor variables as temporary variables (so they can be used with other commands)
  fvrevar `varlist'
  local fvarlist `r(varlist)'
  * drop colinear temp vars
   qui: _rmcoll `fvarlist' if `touse', forcedrop
   local fvarlist `r(varlist)'
  * create list of varnames for labeling
   _rmcoll `varlist' if `touse', expand 
   local lfvarlist `r(varlist)'

  * create pseudo treatment indicator 
  tempvar D
  qui: gen `D'=0 if `touse'==1
}   
else {  // auto mode: two groups with treat specified
  * parse treatment var
  gettoken D varlist: varlist
  if ("`varlist'"=="") {
    disp as err "too few variables specified"
	exit
  }
  * check treatment variable
  _fv_check_depvar `D'
    qui: count if `D'!=1 & `D'!=0 & `touse' == 1
    if (`r(N)'>0) {
      dis as err "treatment indicator (`D') must be a logical variable, TRUE (1) or FALSE (0)"
      exit
    }
    qui: sum `D' if `touse' == 1  
    if (`r(Var)' == 0) {
      dis as err "treatment indicator (`D') must contain both treatment and control observations"
      exit
    }
    qui: count if `D'==0 & `touse' == 1  
    if (`r(N)' <= 1) {
      dis as err "insufficient observations"
      exit
    }	
	* create factor variables as temp vars 
   fvrevar `varlist'
   local fvarlist `r(varlist)'   
  * drop colinear temp vars  
   qui: _rmcoll `fvarlist' if `touse' & `D'==0, force
   local fvarlist `r(varlist)'
  * create list of varnames for labeling
   _rmcoll `varlist' if `touse' & `D'==0 , expand   
   local lfvarlist `r(varlist)'  
}

* remove omitted factor variables from list of varnames for labels
foreach var of local lfvarlist {
  _ms_parse_parts `var'
  if !`r(omit)' {
	local list `list' `var'
  }	
  else { 
    if ("`r(type)'"=="factor") dis as txt "note: `var' omitted because of collinearity"
  }
}
* final list of varnames for labeling
local lfvarlist `list' 

/* check baseweight */
if ("`basewt'"!="") {
   if ("`wttreat'"=="") {
         /* case without base weights for treated units */  
         /* drop controls with missing weight */
		 di "test"
        qui: count if `basewt'==. & `D' == 0 & `touse' == 1
		if (`r(N)'>0)  di as txt "note: `r(N)' control units with missing base weights are not assigned weights"
        qui: replace  `touse'=0 if `basewt'==. & `D' == 0 & `touse' == 1	
        /* if user specified baswt has numbers in it for treated */
        qui: count if (`basewt'~=.|`basewt'~=0) & `D' == 1 & `touse' == 1
        if (`r(N)'~=0) di as txt "note: base weights for the treated units are set to one unless wttreat is specified"
        qui: gen     `baseweight' = `basewt' if `D' == 0 & `touse' == 1
        qui: replace `baseweight' = 1  if `D' == 1 & `touse' == 1
    }
    else {
	/* case with base weights for treated units */
         qui: count if `basewt'==. & `touse' == 1
		 if ("`manualtargets'"!="") {
		 qui: replace  `basewt' = 1 in -1 /* base weight for artificial treated unit in single group case */
		 }
		 qui: replace  `touse'=0 if `basewt'==. & `touse' == 1	/* drop units with missing weight */
		 if (`r(N)'>0)  di as txt "note: `r(N)' units with missing base weights are dropped"
		 qui: gen `baseweight' = `basewt' if  `touse' == 1
    }
 }
 else {
    if "`wttreat'"!="" {
	    dis as err "weigthing variable required"
		exit
    }
    else {
        qui: gen `baseweight' = 1 if `touse' == 1
    }
 }

*--------------populate values for target moments ---------------------------

/* get number of covariates */
local tempvarlist `fvarlist'
local xnum1 = 0
local xnum2 = 0  //# of 2nd order moment constraints
local xnum3 = 0  //# of 3rd order moment constraints
while "`tempvarlist'"~="" {
   gettoken xx tempvarlist: tempvarlist
   local ++xnum1
}

/* single group mode vs. two group mode */
if ("`manualtargets'"!="") { // single group mode
  /* check numlist in manualtargets*/
  if wordcount("`manualtargets'")>`xnum1' {
     dis as err "manualtargets() invalid -- numlist has too many elements"
	 exit
  }
  if wordcount("`manualtargets'")<`xnum1' {
     dis as err "manualtargets() invalid -- numlist has too few elements"
	 exit
  }
  /* generate one artifical treated in new last row */
  mata st_addobs(1)
  qui: replace `D'    =1 in -1
  qui: replace `touse'=1 in -1
  qui: replace `baseweight' = 1 if `touse' == 1
  
 /* fill in target moments */
  tokenize "`manualtargets'"
  local tempvarlist `fvarlist'
  local i = 1
  while "`tempvarlist'"~="" {
    gettoken xx tempvarlist: tempvarlist
    qui: replace `xx' = ``i'' in -1
	local ++i   
  }
  
  /* create Xnames matrix with (temp varname, label) passing vars to mata algo. */
  mata: Xnames1 =  J(0,2,"")
  local tempvarlist `fvarlist'
  local labelvarlist `lfvarlist'
  forvalues i=1(1)`xnum1' {
      gettoken xx tempvarlist: tempvarlist
	  gettoken yy labelvarlist: labelvarlist
	  mata: Xnames1 = Xnames1 \ ("`xx'","`yy'")
  }
  mata: Xnames = Xnames1
}
else {  //two-group mode
  /* check target numlist */
  if "`targets'"=="" {
     local targets = "1"
  }
  if wordcount("`targets'")>`xnum1' {
     dis as err "targets() invalid -- numlist has too many elements"
	 exit
  }
  else {
     if wordcount("`targets'")<`xnum1' {
  /* if only one number, expand it to full exp., e.g. 2 means (2, 2, ..., 2) */
         if wordcount("`targets'")==1 {
  	       local target0="`targets'"
  	       local i=1
	  	   while (`i++'<`xnum1'){
		     local targets = "`targets'"+ " " + "`target0'"
		   }
	     }
	     else {
	       dis as err "targets() invalid -- numlist has too few elements"
		   exit
	     }	
      }
   }
     
   /* create Xnames matrix with (temp varname, label) passing vars to mata algo. */
   * start with empty matrix  for 1st, 2nd, and 3rd order moments
   foreach name in Xnames1 Xnames2 Xnames3 {
      mata: `name'  =  J(0,2,"")
   }
   local tempvarlist `fvarlist'
   local labelvarlist `lfvarlist'

   tokenize "`targets'"
   forvalues i=1(1)`xnum1' {
     /* populate matrix for 1st order moments */
     gettoken xx tempvarlist: tempvarlist
	 gettoken yy labelvarlist: labelvarlist
	 mata: Xnames1 = Xnames1 \ ("`xx'","`yy'")
	 if (``i''>= 2) {
	 /* populate matrix for 2nd order moments */
	    /* exclude high orders for bivariate covars */
    	 qui: sum(`xx') if `D'==1 & `touse' == 1    // less than 2 values among the treated
    	 if (r(sd)==0) {
		    dis as txt "note: higher order constraint omitted due to too few values of `xx'"
            continue
      	 }
	    qui: sum(`xx') if `D'==0 & `touse' == 1    // less than 2 values among controls
        if (r(sd)==0) {
		    dis as txt "note: higher order constraint omitted due to too few values of `xx'"
            continue
	    }
	    /* gen temp squared terms (degrees of freedom adjusted) */
        qui: sum(`xx') [aweight=`baseweight'] if `D'==1 & `touse' == 1
	    local treat_mean = r(mean)
	    local treat_N = r(N)
	    qui: sum(`xx') [aweight=`baseweight'] if `D'==0 & `touse' == 1
	    local ctrl_N = r(N)
	    tempvar `xx'_2
	    qui: gen     ``xx'_2' =  (`xx' - `treat_mean')^2*`ctrl_N'/(`ctrl_N'-1)    if `touse' == 1 & `D'==0
	    qui: replace ``xx'_2' =  (`xx' - `treat_mean')^2*`treat_N'/(`treat_N'-1)  if `touse' == 1 & `D'==1
	    * mata: idxvar2 = idxvar2, (st_varindex(tokens("``xx'_2'")))
		mata: Xnames2 = Xnames2 \ ("``xx'_2'","`yy'")
		local ++xnum2
    }
    if (``i''== 3) {
	  /* populate matrix for 3rd order moments */
      /* gen temp cubed terms (degrees of freedom adjusted to be consistent with STATA defination , see Manual "summarize" ) */
	    tempvar `xx'_3
        qui: gen     ``xx'_3' =  (`xx' - `treat_mean')^3*(`ctrl_N'/(`ctrl_N'-1))^1.5    if `touse' == 1 & `D'==0
        qui: replace ``xx'_3' =  (`xx' - `treat_mean')^3*(`treat_N'/(`treat_N'-1))^1.5  if `touse' == 1 & `D'==1
		mata: Xnames3 = Xnames3 \ ("``xx'_3'","`yy'")
		local ++xnum3
    }
  }
   mata: Xnames = Xnames1 \ Xnames2 \ Xnames3  /* complete var matrix for passing to main mata algo */
}

/* create variable names for 1st, 2nd, 3rd order moment constraints */
forvalues i=1(1)3 {
  mata: constrt`i'=""
  forvalues v=1(1)`xnum`i'' {
     mata: constrt`i'=constrt`i'+" "+Xnames`i'[`v',2]
  }
  mata: st_local("constrt`i'",constrt`i')  
}
mata: constrts=constrt1+constrt2+constrt3
mata: st_local("constrts", constrts)

/* check overlap */
local tempvarlist `fvarlist'
while "`tempvarlist'"~="" {
   gettoken xx tempvarlist: tempvarlist
   qui: sum `xx' if `D'==1 & `touse'==1
   local tmax = r(max)
   local tmin = r(min)
   qui: sum `xx' if `D'==0 & `touse'==1
   local cmax = r(max)
   local cmin = r(min)
   if (`tmax'<`cmin' | `cmax'<`tmin') {
      if ("`manualtargets'"~="") dis as err "target beyond the range of `xx'"
      else dis as err "no overlap in `xx'"
	  exit
   }
}
 

/********************* Produce initial output ************************* */
di _newline(1)
di as res "Data Setup"
if ("`manualtargets'"=="") {
  di as txt "Treatment variable:   " as res "`D'"
  mata: printf("{txt}Covariate adjustment:")
  mata: printf("%s ", constrt1)
  if `xnum2'!=0 mata: printf("{txt}(1st order).{res}%s {txt}(2nd order).",constrt2)
  if `xnum3'!=0 mata: printf("{res}%s {txt}(3rd order).\n",constrt3)
}
else mata: printf("{txt}Covariate adjustment:{res}%s{txt}\n", constrt1)
di _newline(1)


/* ********************** Main Algo ************************* */
qui: gen     `treated'  = 0
qui: replace `treated'  = 1 if `D' == 1 & `touse' == 1
qui: gen     `controls' = 0
qui: replace `controls' = 1 if `D' == 0 & `touse' == 1

di as res "Optimizing..."
mata: eb("`treated'","`controls'",Xnames[,1]',"`baseweight'","`generate'",`maxiter',`tolerance')

if (res_converge == 0) {  /* report the most demanding variable in case of non-convegence */
  if (res_maxdist == 0) dis as txt "note: The algorithm fails to adjust the summation of weights (possibly due to too few control units)" 
  else if (res_maxdist <= `xnum1') di as txt "note: The algorithm fails to adjust the mean (1st order moment) of " as res word("`constrt1'",res_maxdist) 
  else if (res_maxdist <= `xnum1'+`xnum2') di as txt "note: The algorithm fails to adjust the variance (2nd order moment) of " as res word("`constrt2'",res_maxdist-`xnum1')
  else di as txt "note: The algorithm fails to adjust the 3rd order moment of " as res word("`constrt2'",res_maxdist-`xnum1'-`xnum2')
  
  if ("`keep'" != "") dis as txt "note: convergence not achieved; balance table not saved"
  
  /* disp tabstat without eb weighting: manual and auto cases */
  if ("`manualtargets'"!="") {
    di _newline(1)
    if "`basewt'"=="" di as res "Pre-balancing: " as txt "without weighting"
    else di as res "Pre-balancing: " as txt "`basewt' as the weighting variable"
    qui: tabstat `fvarlist' [aweight=`baseweight'] if `touse' == 1, c(s) s(mean variance skewness) longstub save 
    tempname Pre Post
    mat `Pre' =  r(StatTotal)'
    mat rownames `Pre' = `lfvarlist' 
    matlist `Pre', tw(12) format(%9.4g)
  }
  else {
    di _newline(1)
    if "`basewt'"=="" di as res "Pre-balancing: " as txt "without weighting"
    else di as res "Pre-balancing: " as txt "`basewt' as the weighting variable"
    qui: tabstat `fvarlist' [aweight=`baseweight'] if `touse' == 1, c(s) by(`D') s(mean variance skewness) nototal longstub save 
    tempname Pre Post
    mat `Pre' = r(Stat2)', r(Stat1)'
    mat colnames `Pre' = mean variance skewness mean variance skewness
    mat coleq `Pre' = Treat Treat Treat Control Control Control
    mat rownames `Pre' = `lfvarlist' 
    matlist `Pre', tw(12) lines(eq) showcoleq(c)  format(%9.4g) 
  }
  restore
  
  /* return results when convergence is not achieved */
  ereturn post, esample(`touse')
  ereturn scalar convg = res_converge
  ereturn scalar maxdiff = res_maxdiff
  ereturn matrix preBal = `Pre'
  ereturn local cmdline `"`0'"'
  ereturn local title "Entropy Balancing"
  ereturn local cmd "ebalance"
  exit
}
else restore, not /* after convergence is reached, cancel the previous "preserve" */

label variable `generate' "entropy balancing weights"

/* weighting for the treated */
if ("`wttreat'"=="") {
   qui: replace `generate'= 1 if `D'==1 & `touse'==1
}
else {
   qui: replace `generate'= `baseweight' if `D'==1 & `touse'==1
}

/* nomalization adjustment */
if ("`manualtargets'"!="") {
  qui: drop in -1                  /* drop artifical treated unit */
  qui: sum `generate' if `touse'==1
  qui: replace `generate'= `generate'*`normconst'*`r(N)'/`r(sum)' if `touse'==1
}
else {
  qui: sum `generate' if `D'==1 & `touse'==1
  loc  trwt = `r(sum)'
  qui: sum `generate' if `D'==0 & `touse'==1
  loc  cowt = `r(sum)'
  qui: replace `generate'= `generate'*`normconst'*`trwt'/`cowt' if `D'==0 & `touse'==1
}

/* ******************  Organize output ********************* */

/* show results */
if ("`manualtargets'"!="") {
  di _newline(1)
  qui: sum `generate' if `D'==0 & `touse'==1
  di as res "No. of units adjusted: " as txt "`r(N)' " as res "total of weights: " as txt round(`r(sum)')

  di _newline(1)
  if "`basewt'"=="" di as res "Before: " as txt "without weighting"
  else di as res "Before: " as txt "`basewt' as the weighting variable"
  qui: tabstat `fvarlist' [aweight=`baseweight'] if `touse' == 1, c(s) s(mean variance skewness) longstub save 
  tempname Pre Post
  mat `Pre' =  r(StatTotal)'
  mat rownames `Pre' = `lfvarlist' 
  matlist `Pre', tw(12) format(%9.4g)
  
  di _newline(1)
  di as res "After:  " as txt "`generate' as the weighting variable"
  qui: tabstat `fvarlist' [aweight=`generate'] if `touse' == 1, c(s) s(mean variance skewness) longstub save
  mat `Post' =  r(StatTotal)'
  mat rownames `Post' = `lfvarlist' 
  matlist `Post', tw(12) format(%9.4g)
}
else {
  di _newline(1)
  qui: sum `generate' if `D'==1 & `touse'==1
  di as res "Treated units: " as txt "`r(N)'" _column(24) as res "total of weights: " as txt round(`r(sum)')
  qui: sum `generate' if `D'==0 & `touse'==1
  di as res "Control units: " as txt "`r(N)'" _column(24) as res "total of weights: " as txt round(`r(sum)')

  di _newline(1)
  if "`basewt'"=="" di as res "Before: " as txt "without weighting"
  else di as res "Before: " as txt "`basewt' as the weighting variable"
  qui: tabstat `fvarlist' [aweight=`baseweight'] if `touse' == 1, c(s) by(`D') s(mean variance skewness) nototal longstub save 
 
  tempname Pre Post
  mat `Pre' = r(Stat2)', r(Stat1)'
  mat colnames `Pre' = mean variance skewness mean variance skewness
  mat coleq `Pre' = Treat Treat Treat Control Control Control
  mat rownames `Pre' = `lfvarlist' 
  matlist `Pre', tw(12) lines(eq) showcoleq(c)  format(%9.4g) 
  
  di _newline(1)
  di as res "After:  " as txt "`generate' as the weighting variable"
  qui: tabstat `fvarlist' [aweight=`generate'] if `touse' == 1, c(s) by(`D') s(mean variance skewness) nototal longstub save 
  mat `Post' = r(Stat2)', r(Stat1)'
  mat colnames `Post' = mean variance skewness mean variance skewness
  mat coleq `Post' = Treat Treat Treat Control Control Control
  mat rownames `Post' = `lfvarlist' 
  matlist `Post', tw(12) lines(eq) showcoleq(c) format(%9.4g) 
}



/* ****************** Save Balance Table ********************* */

if ("`keep'" != "") {
  preserve
  cap drop Xname mean_Tr var_Tr skew_Tr mean_Co_Pre var_Co_Pre skew_Co_Pre mean_Co_Post var_Co_Post skew_Co_Post
  qui: gen Xname=""
  local tempvarlist `lfvarlist'
  local i=1
  while (`i'<=`xnum1') {
    gettoken xx tempvarlist: tempvarlist
    qui: replace Xname = "`xx'" in `i'
	local ++i
  }
  if ("`manualtargets'"!="") {  // treated and reweighted control
   	mat colnames `Pre'  = mean_Pre  var_Pre  skew_Pre
	mat colnames `Post' = mean_Post var_Post skew_Post
    svmat double `Pre' , names(col)
    svmat double `Post', names(col) 
	order Xname mean_Pre mean_Post var_Pre var_Post skew_Pre skew_Post
	qui keep Xname mean_Pre var_Pre skew_Pre mean_Post var_Post skew_Post
	label variable Xname     "covariate names"
    label variable mean_Pre  "mean in raw data"
    label variable var_Pre   "variance in raw data"
    label variable skew_Pre  "skewness in raw data" 
    label variable mean_Post "mean in reweighted data"
    label variable var_Post  "variance in reweighted data"
    label variable skew_Post "skewness in reweighted data" 	
  }
  else { 
    tempname Post2   // reweighted control only
    mat `Post2' = `Post'[1..., 4..6]
  	mat colnames `Pre' = mean_Tr var_Tr skew_Tr mean_Co_Pre var_Co_Pre skew_Co_Pre
  	mat colnames `Post2' = mean_Co_Post var_Co_Post skew_Co_Post
    svmat double `Pre', names(col)
    svmat double `Post2', names(col)
 	order  Xname mean_Tr mean_Co_Pre mean_Co_Post  var_Tr var_Co_Pre var_Co_Post
	qui keep  Xname mean_Tr var_Tr skew_Tr mean_Co_Pre var_Co_Pre skew_Co_Pre mean_Co_Post var_Co_Post skew_Co_Post
   	qui: gen sdiff_Pre  = (mean_Tr - mean_Co_Pre) / (var_Tr^0.5)
    qui: gen sdiff_Post = (mean_Tr - mean_Co_Post)/ (var_Tr^0.5)
 	label variable Xname        "covariate names"
    label variable mean_Tr      "mean in treated units"
    label variable var_Tr       "variance in treated units"
    label variable skew_Tr      "skewness in treated units" 
    label variable mean_Co_Pre  "mean in raw control units"
    label variable var_Co_Pre   "variance in raw control units"
    label variable skew_Co_Pre  "skewness in raw control units" 
    label variable mean_Co_Post "mean in reweighted control units"
    label variable var_Co_Post  "variance in reweighted control units"
    label variable skew_Co_Post "skewness in reweighted control units" 
    label variable sdiff_Pre    "std diff btw treated and raw control group" 
    label variable sdiff_Post   "std diff btw treated and reweighted control group" 
  }
  qui drop if Xname ==""
  label data ""
  if ("`replace'" != "") qui save `keep', `replace'
  else qui save `keep'
  restore
} 

/* ******************  Return Results ********************* */

/* delete the first items of the two vector*/
mat res_moments = res_moments[2...,1...]
mat res_lambdas = res_lambdas[2...,1...]

/* adjust row/col names*/
* fill orders if higher moments are specified
if (`xnum2'~=0) {
  forvalues i=1(1)3 {
    mata: st_matrix("order`i'", J(`xnum`i'',1,`i'))
  } 
  mat orders = (order1 \ order2)
  if (`xnum3'~=0) {
     mat orders = (order1 \ order2 \ order3)
  }
  mat res_moments = (orders, res_moments) 
  mat res_lambdas = (orders, res_lambdas)
}

if (`xnum2'~=0) {
   mat colnames res_moments = order mconstrnt
   mat colnames res_lambdas = order lambda
}
else {
   mat colnames res_moments = mconstrnt
   mat colnames res_lambdas = lambda
}

* rownames
mat rownames res_moments = `constrts'
mat rownames res_lambdas = `constrts'

/* return results*/
ereturn post, esample(`touse')
ereturn scalar convg = res_converge
ereturn scalar maxdiff = res_maxdiff
ereturn matrix postBal = `Post'
ereturn matrix preBal = `Pre'
ereturn matrix moments res_moments
ereturn matrix lambdas res_lambdas

ereturn local cmdline `"`0'"'
ereturn local title "Entropy Balancing"
ereturn local cmd "ebalance"

end

/* *************************** Mata **************************** */

mata:
mata clear

/* line search */
void linesearch(todo, ss, Q, cX, M, coefs, nstep, maxdiff, g, H)
{
 	   pragma unused todo
	   pragma unused g
	   pragma unused H

	   real matrix wr
	   real matrix weightsebal
	   real matrix xxs
	   	
       wr = exp(cX*(coefs-(ss:*nstep)')')
       weightsebal = wr:*Q
       xxs = weightsebal'*cX
       maxdiff = max(abs(xxs-M'))
}

/* entropy balancing */
void eb(string Tr, string Co, string matrix X, string Baseweight, string Newvar, real Numiter, real Tol)
 {
 real matrix coX
 real matrix trX
 real matrix baseweight
 real matrix treatweight
 real vector moment                    
 real matrix coefs                      // coefficients (lambdas)
 real scalar rr
 real scalar cc

 /* to suppress misleading warnings */
 pragma unset coX
 pragma unset trX
 pragma unset baseweight
 pragma unset treatweight
 pragma unset rr
 pragma unset cc

 /* load in data matrix */
st_view(baseweight ,.,Baseweight,Co)      
st_view(treatweight,.,Baseweight,Tr)      // base weight for the treated

st_view(trX,.,X,Tr)                      // take from X, treated
moment = quadcolsum(treatweight:*trX)    
moment = moment:/quadcolsum(treatweight) // column "average" of trX
moment = 1, moment
moment = moment'
moment_mag = editmissing(exp(trunc(log10(abs(moment)))*log(10)),1)   //normalized order of magnitude of "moment";  **********
moment = moment:/moment_mag                                          

st_view(coX,.,X,Co)               // take from X, controls
coX = J(rows(coX),1,1), coX       // add a vector of (1, 1, .. , 1)'
coX = (coX' :/ moment_mag)'       //normalized control units by order of magnitude of "moment" 
  
/* coefs: start from (0, 0, 0, ...)  */
coefs = J(1,cols(coX),0)

/* Start algo here */
iter = 1
maxdiff = Tol + 1
/* maxdiff */

while (maxdiff > Tol & iter<=Numiter) {

 wr = exp(coX*coefs')
 weightsebal = wr:*baseweight
 xxs  = weightsebal'*coX    
 gradient = xxs - moment'   /* gradient */
 hessian = coX'*(weightsebal:*coX)  /* hessian */
 Coefs = coefs
 nstep = cholsolve(hessian,gradient',1e-8)
 if (nstep[1]==.) nstep = svsolve(hessian,gradient')
 coefs = coefs - nstep'
 
/* now check if we should take the full newton step or not */
 S = optimize_init()
 optimize_init_evaluator(S, &linesearch())
 optimize_init_argument(S, 1, baseweight)
 optimize_init_argument(S, 2, coX)
 optimize_init_argument(S, 3, moment)
 optimize_init_argument(S, 4, coefs)
 optimize_init_argument(S, 5, nstep)
 optimize_init_params(S, 0)
 optimize_init_conv_warning(S, "on")
 (void) optimize_evaluate(S)
 lossnew = optimize_result_value(S)
 optimize_init_argument(S, 4, Coefs)
 optimize_init_params(S, 0)
 (void) optimize_evaluate(S)
 lossold = optimize_result_value(S)

/* if not the full newton then do a line search */
  zerostep = 0                                // indicator for line search failure
  if (lossold <= lossnew) {
   n = 5 /* this sets the number of values searched: should do golden section here but Stata does not have it */
   Store = J(n,2,.)
   for(i=1; i<=n; i++) {
     optimize_init_params(S, 1/i)
     (void) optimize_evaluate(S)
     Store[i,1] = optimize_result_value(S)
     Store[i,2] = optimize_result_params(S)  // stores optimizing value and resulting parameters
    }
   minindex(Store[.,1],1,rr,cc)
   ss = Store[rr[1],2]
   zerostep = 0
   if (ss==0) zerostep = 1
   coefs = Coefs - (ss:*nstep)'
 }
 maxdiff = max(abs(gradient))/moment[1]     // rescale according to weight total of the treated
 maxdist = maxw = 0
 maxindex(abs(gradient),1,maxdist,maxw)  //store the most demanding variable in maxdist
 printf("{txt}Iteration %f: Max Difference = {res}%g", iter, maxdiff)
 printf("{txt}\n")
 if (zerostep ==1) {
  /* printf("{txt} (line search fails)\n") */
   break
  }
 else {
    iter = iter + 1
 }
} /* close while loop */

if (maxdiff<=Tol) {
  printf("{txt}maximum difference smaller than the tolerance level; {res}convergence achieved\n")
  converge = 1
}
else {
  if (zerostep==0) printf("{err}algorithm does not converge within specified tolerance; try increasing maxiter(#) or relaxing tolerance\n")
  else printf("{err}algorithm does not converge within specified tolerance; no solution AND/OR near colinearity of covariates (and possibly their higher orders)\n")
  converge = 0
}

moment = moment :* moment_mag //adjust back order of magnitude

/* save results */
st_numscalar("res_converge", converge)
st_numscalar("res_maxdiff", maxdiff)
st_numscalar("res_maxdist", maxdist[1]-1)  //Most demanding constrait; note: the first one is about the the sum of weights
st_matrix("res_lambdas", coefs')
st_matrix("res_moments", moment)
/* save eweights in a new variable */
(void) st_addvar("double", Newvar)
st_store(., Newvar, Co, weightsebal)
} /* close function */

end
