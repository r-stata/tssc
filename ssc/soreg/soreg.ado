program define soreg, eclass

version 6.0
syntax varlist [if] [in] [fweight/][,Maxdim(integer 1) Constraints(numlist)]
preserve

/* Generate names for some temporary variables, and initialise */

tempvar wt newdep ll devres oldi newy ys eta mu 
tempname ests thisest Wscale touse
tempfile preds

/* get the dependent and predictor variables */
tokenize `varlist'
local depvar `1'
macro shift
local indvars `*'

if "`indvars'" == "" {
    noi di in red "You must provide at least one predictor variable."
    exit
}

local numvars : word count `indvars'

/* Check that there are between 3 and 12 levels in the response variable. */ 

quietly {
    tab `depvar'
    local ncat=r(r)
    if `ncat' > 12 {
	noi display "Response factor `varlist' has more than 12 categories."
	exit
    }
    if `ncat' <= 2 {
	noi display "Response factor `varlist' has fewer than 3 categories."
	exit
    }
    
    /* Calculate the dimension to use: 1 if not specified*/
    if "`maxdim'" == "" {
	local maxdim = 1
    }
    /* Check that the specified dimension is reasonable */
    else {
	if `maxdim' > `numvars' {
	    local maxdim = `numvars'
	}
	if `maxdim' > `ncat' - 1 {
	    local maxdim = `ncat' - 1 
	}
    }
    /* store the levels of the factor in the vector faclev */
    
    matrix faclev = J(1,`ncat',0)
    sort `depvar'
    gen temp1=`depvar'
    collapse (mean) temp1, by(`depvar')
    mkmat `depvar', matrix(faclev)
    restore
    preserve 
    
    /* Expand data set by a factor number of levels */
/* Select relevant records */
    mark `touse' `if' `in' 
    markout `touse' `depvar' `indvars'
    keep if `touse' == 1

    if "`weight'" ~= "" {
	expand `exp'
    }
    gen `oldi'=_n
    local numsubs = _N
    
    expand `ncat'
    sort `oldi'
    gen byte `newy' = mod(_n-1,`ncat')+1
    local counter = 1
    gen byte `ys'=(`depvar'==el(faclev,`ncat',1)) & (`newy' == `ncat')
    while `counter' < `ncat' {
	local testval = el(faclev,`counter',1)
	replace `ys'=1 if (`depvar'== `testval') & `newy' == `counter'
	local counter = `counter' + 1
	}
	
    /* Now we can work out how many parameters there are in our final model */
    local params = `maxdim'*(`ncat' + `numvars')
    
    /*
    Now that the data has been preserved, we can create some new 
    variables 
    */

    gen `wt' = 0
    gen `newdep' = 0
    gen `ll' = 0
    gen `devres' = 0
    gen `eta' = 0
    gen `mu' = 0

    sort `oldi' `newy' 

/* 
   Fit a multinomial model. This is a re-parameterisation of a	     
   stereotype model of dimension d, where d is the smaller of the   
   number of variables and the number of levels in the response -   
   We will calculate initial estimates of the stereotype  
   parameters from this model 
*/

    mlogit `newy' `indvars' if `ys' == 1, base(`ncat')
    matrix `ests' = e(b)
    scalar null_ll = e(ll_0)
    scalar full_ll = e(ll)
    scalar full_df = e(df_m)

    /* Get predicted values from this model */
    predict __p1-__p`ncat'
    local counter = 1
    while `counter' <= `ncat' {
	replace `mu' = __p`counter' if `newy' == `counter'
	local counter = `counter' + 1
    }
    replace `eta' = log(`mu')

/*
  Extract the parameters from the multinomial model: use them to	   
  define initial values  for the parameters of the stereotype model. 
  Because the stereotype model is non-linear, we need to have local 
  macros to keep track of the current parameter values, as well as 
  variables used to estimate the changes in the parameters. 
*/

/* 
   First we generate the local macros. We need: 
   beta_ij, i=1 to numvars, j=1 to maxdim
   phi_kj   k=1 to ncat-1, j=1 to maxdim 
   gam_ij, i=1 to numvars, j=1 to maxdim
*/

    local counter = 1
    while `counter' <= `maxdim' {
	local base`counter' = 1
	tokenize `indvars'
	local varnum = 1
	while "`1'" ~= "" {
	    matrix `thisest' = `ests'[1,"`counter':`1'"]
	    local beta`varnum'`counter' = el(`thisest',1,1)
	    if `varnum' > 1 {
		local gam`varnum'`counter' = 			    /* 
    */                `beta`varnum'`counter'' / `beta1`counter''
	    }
	    local phi`ncat'`counter' = 0
	    local inner = 1
	    while `inner' < `ncat' {
		if `varnum' == 1 {
		    local phi`inner'`counter' = 0
		}
		matrix `thisest' = `ests'[1,"`inner':`1'"]
		local phi`inner'`counter' =	`phi`inner'`counter'' +	    /* 
    */                el(`thisest',1,1) / `beta`varnum'1' 
		local inner = `inner' + 1
	    }
	    local varnum = `varnum' + 1    
	    macro shift
	}
	local inner = 1
	while `inner' < `ncat' {
	    local phi`inner'`counter' = `phi`inner'`counter'' / `numvars'
	    local inner = `inner' + 1
	}
	/*								
	Now we generate a series of variables phi_j, containing the 
	value of phi_ij for that observaton.
	*/
	gen phi`counter' = 1
	replace phi`counter' = 0 if `newy' == `ncat'
	local inner = 2
	while `inner' < `ncat' {
	    replace phi`counter' = `phi`inner'`counter'' if `newy'==`inner'
	    local inner = `inner' + 1
	}
	local counter = `counter' + 1
    }
    
/* Now we need to calculate the predictor variables */

/* The phi variables have already been initialised */
/* now create the variables used to estimate the beta0s */

    local counter = 1
    while `counter'  < `ncat' {
	gen byte beta0`counter' = (`newy' == `counter')
	local predlst `predlst' beta0`counter'
	local counter = `counter' + 1
    } 

/* Now we can generate the variables to produce the other betas */
/* First, get the current approximation to xB                   */
    local counter = 1
    while `counter' <= `maxdim' {
	tokenize `indvars'
	gen lsum`counter' = 0
	local varnum = 1
	while "`1'" ~= "" {
	    replace lsum`counter' = lsum`counter' + `1'*`beta`varnum'`counter''
	    local varnum = `varnum' + 1
	    macro shift
	}
	local counter = `counter' + 1
    }

/* 
  Now we can create the linearizing u and v variables, and add them 
  to predlst 
*/
    local counter = 1
    while `counter' <= `maxdim' {
	tokenize `indvars'
	local varnum = 1
	while "`1'" ~= "" {
	    if `varnum' == `base`counter'' {
		gen beta`varnum'`counter' = lsum`counter'*phi`counter' /* 
    */                              / `beta`base`counter''`counter'' 
	    }
	    else {
		gen beta`varnum'`counter' = phi`counter'*`1'
	    }
	    local predlst `predlst' beta`varnum'`counter'	
	    local varnum = `varnum' + 1
	    macro shift
	}

    /* Finally, generate the variables to produce the phis */

	local inner = 1
	while `inner' <= `ncat' {
	    gen phi`inner'`counter' = lsum`counter'/`beta1`counter'' /* 
    */                                 * (`newy' == `inner')
	    local predlst `predlst' phi`inner'`counter'
	    local inner = `inner' + 1
	}
	local counter = `counter' + 1
    }
 
/*
  Now we need to check if any constraints have been defined, and if
  so, to apply them. First, we need dummy matrices containing the 
  parameter names 
*/

matrix estlist = J(1,`params',0)
matrix covlist = J(`params',`params',0)
local vnames
local counter = 1
while `counter' <= `maxdim' {
    local inner = 1
    while `inner' <= `ncat' {
	local vnames `vnames' phi`inner'`counter'
	local inner = `inner' + 1
    }
    local inner = 1
    while `inner' <= `numvars' {
	local vnames `vnames' beta`inner'`counter'
	local inner = `inner' + 1
    }
    local counter = `counter' + 1
}

matrix colnames estlist = `vnames'
matrix colnames covlist = `vnames'
matrix rownames covlist = `vnames'

/* 
   Now post dummy estimates and covariance matrix and get back a 
   constraint matrix 
*/
if "`constra'" ~= "" {
    matrix b = estlist
    matrix V = covlist
    estimates post b V
    matrix makeCns `constra'
    noi matrix dispCns
    matrix consmat = get(Cns)
    matrix colnames consmat = `vnames' r
}
/* 
    If no constraints given, define our own for simple cases
    Otherwise, object
*/
else {
    if `maxdim' == 1 {
	matrix consmat = J(2,`params'+1,0)
	matrix colnames consmat = `vnames' r
	matrix consmat[1,1]          = 1
	matrix consmat[1,`params'+1] = 0
	matrix consmat[2,`ncat']     = 1
	matrix consmat[2,`params'+1] = 1
    }
    else if `maxdim' == 2 {
	matrix consmat = J(6,`params'+1,0)
	matrix colnames consmat = `vnames' r
	matrix consmat[1,1]                       = 1
	matrix consmat[1,`params'+1]              = 0
	matrix consmat[2,2]                       = 1
	matrix consmat[2,`params'+1]              = 1
	matrix consmat[3,`ncat']                  = 1
	matrix consmat[3,`params'+1]              = 0
	matrix consmat[4,`ncat'+`numvars'+1]      = 1
	matrix consmat[4,`params'+1]              = 0
	matrix consmat[5,`ncat'+`numvars'+2]      = 1
	matrix consmat[5,`params'+1]              = 1
	matrix consmat[6,`ncat'+`numvars'+`ncat'] = 1
	matrix consmat[6,`params'+1]              = 0
    }
    else {
	noi di in red 						    /* 
*/"For models of dimension > 2, you must define your own constraints"
	noi di in red 						    /* 
*/"for the phi variables."
	exit
    }
}

local consgrp = 0
local pos = 0
local neg = 0
local consnum = rowsof(consmat)
local consbet
local counter = 1
while `counter' <= `consnum' {
    local inner = 1
    local count = 0
    local done  = 0
    while `inner' <= `params' {
	if el(consmat,`counter',`inner') ~= 0 {
	    local count = `count' + 1
	}
	if el(consmat,`counter',`inner') == 1 {
	    local pos = `inner'
	}
	if el(consmat,`counter',`inner') == -1 {
	    local neg = `inner'
	}
    local inner = `inner' + 1
    }
    if `count' > 2 {
	local cnum : word `counter' of `constra'
	noi di in red "Constraint `cnum' is too complicated."
	exit
    }
    else if `count' == 2 {
    /* Two parameters constrained to be equal */
	local parnam1 : word `pos' of `vnames'
	if substr("`parnam1'",1,5) == "beta1" {
	noi di in red				                   /* 
    */      "You cannot apply constraints to the first predictor variable."
	    exit
	}
	local parnam2 : word `neg' of `vnames'
	if substr("`parnam2'",1,5) == "beta1" {
	    noi di in red					    /* 
    */      "You cannot apply constraints to the first predictor variable."
	    exit
	}
	local inner = 1
	while `inner' <= `consgrp' {
	    tokenize `cgrp`consgrp''
	    while "`1'" ~= "" {
		if "`parnam1'" == "`1'" {
		    local cgrp`consgrp' `cgrp`consgrp'' `parnam2'
		    local done = 1
		}
		if "`parnam2'" == "`1'" {
		    local cgrp`consgrp' `cgrp`consgrp'' `parnam1'
		    local done = 1
		}
		macro shift
	    }
	    local inner = `inner' + 1
	}
	if `done' == 0 {
	    local consgrp = `consgrp' + 1
	    local cgrp`consgrp' `parnam1' `parnam2'
	}
    }
    else if `count' == 1 {
    /* One parameter has its value constrained */
    /* 
    The parameter needs to have its inital value reset, 	
    and be removed from predlst 
    */
	local parnam : word `pos' of `vnames'
	if substr("`parnam'",1,4) == "beta" {
	    local dim = substr("`parnam'",6,1) 
	    if substr("`parnam'",5,1) == "`base`dim''" {
		local base`dim' = `base`dim'' + 1
		}
	}
	local `parnam' = el(consmat, `counter', `params' + 1)
	local exclist `exclist' `parnam'
    }
    local counter = `counter' + 1
}

/*								    
  Now add all variables but one from each cgrp to exclist, unless a 
  parameter has been set equal to a fixed parameter, in which case remove 
  them all
*/

local counter = 1
local excnum : word count `exclist'
while `counter' <= `consgrp' {
    local match = ""
    tokenize `cgrp`counter''
    while "`1'" ~= "" {
	local inner = 1
	while `inner' <= `excnum' {
	    local thisvar : word `inner' of `exclist'
	    if "`1'" == "`thisvar'" {
		local match = "`thisvar'"
	    }
	    local inner = `inner' + 1
	}
	macro shift
    }
    if "`match'" == "" {
	tokenize `cgrp`counter''
	macro shift
	local exclist `exclist' `*'
    } 
    else {
	tokenize `cgrp`counter''
	while "`1'" ~= "" {
	    if "`1'" ~= "`match'" {
		local `1' = ``match''
	    }
	    local exclist `exclist' `1'
	    macro shift
	}
    }
    local counter = `counter' + 1
}


/* Finally, we can remove all of the variables in exclist from predlst */
local templst `predlst'
local predlst
local excnum : word count `exclist'
tokenize `templst'
while "`1'" ~= "" {
    local add = 1
    local inner = 1
    while `inner' <= `excnum' {
	local thisvar : word `inner' of `exclist'
	if "`thisvar'" == "`1'" {
	    local add = 0
	}
	local inner = `inner' + 1
    }
    if `add' == 1 {
	local predlst `predlst' `1'
    }
    macro shift
}

/* Finally, we may need to reset the phi_i variables if they are constrained */

local counter = 1
while `counter' <= `maxdim' {
    local inner = 1
    while `inner' <= `ncat' {
	replace phi`counter' = `phi`inner'`counter'' if `newy' == `inner'
	local inner = `inner' + 1
    }
    local counter = `counter' + 1
}

/* Initialise the variables used in the iterations */

local olddev = 0
local done = 0
local iter = 0

while "`done'" == "0" & `iter' < 100 {
    /* Calculate weights: (g(mu)**2 * var(y))**-1 */

    replace `wt' = `mu'

    /* Calculate dependent variable */

    replace `newdep' = `eta' + (`ys' - `mu') / `mu'

    /* Perform weighted regression */

    summarize `wt'
    scalar `Wscale' = r(mean)
*    regress `newdep' `predlst' [iw=`wt'/`Wscale']
*    regress `newdep' `predlst' [iw=`wt'/`Wscale'] if `newy' < `ncat'
     clogit `ys' `predlst', group(`oldi')
    drop `mu'
    predict `mu'
    replace `eta' = ln(`mu')

    /* Compare deviance to previous deviance */
    replace `devres' = `eta' * `ys'
    replace `ll' = sum(`devres')
    local newll = `ll'[_N]
    noi di "iteration `iter': Log Likelihood = " %9.4f `newll'
    if `iter' > 1 {
	local devdiff = `oldll' - `newll'
	if abs(`devdiff') < 1e-7 {
	    local done = 1
	}
    }
    local oldll = `newll'
    local iter = `iter' + 1

    /* Recalculate Design Matrix */

    /* First, store the calculated values of phi */

/* 
  Note: first store beta, cos the other coefficients must be divided by it
*/

    local counter = 1
    matrix `ests' = e(b)
    while `counter'  <= `maxdim' {
    /* 
       now create the variables used to estimate the other betas 
       First, update the betas and get the current approximation 
       to xB    
    */     
	tokenize `indvars'
	local varnum = 1
	while "`1'" ~= "" {
	    if `varnum' == `base`counter'' {
		capture matrix `thisest' = `ests'[1,"beta`varnum'`counter'"]
		/* Check if the variable is being constrained */
		if _rc == 0 {
		    local beta`varnum'`counter' = el(`thisest',1,1)
		}		
	    }
	    else {
		capture matrix `thisest' = `ests'[1,"beta`varnum'`counter'"]
		/* Check if the variable is being constrained */
		if _rc == 0 {
		    local beta = el(`thisest',1,1)
		    local gam`varnum'`counter' =		    /* 
    */                    `gam`varnum'`counter'' + 		    /* 
    */                    `beta'/`beta`base`counter''`counter''
		    local beta`varnum'`counter' =		    /* 
    */              `gam`varnum'`counter'' * `beta`base`counter''`counter''
		}
	    }
	    /* Check if the variable is being used for others */
	    local outer = 1
	    while `outer' <= `consgrp' {
		local thisvar : word 1 of `cgrp`outer''
		if "`thisvar'" == "beta`varnum'`counter'" {
		    local inner = 2
		    local vcount : word count `cgrp`outer''
		    while `inner' <= `vcount' {
			local `1' = `beta`varnum'`counter''
			local inner = `inner' + 1
		    }
		}
		local outer = `outer' + 1
	    }
	    local varnum = `varnum' + 1
	    macro shift
	}
	tokenize `indvars'
	replace lsum`counter' = 0
	local varnum = 1
	while "`1'" ~= "" {
	    replace lsum`counter' = lsum`counter' + 		    /* 
*/                                  (`1' * `beta`varnum'`counter'') 
	    local varnum = `varnum' + 1
	    macro shift
	}
    /* 
	Next, update the approximations to phi, both macros and variables 
    */
	local inner = 1
	while `inner' <= `ncat' {
	    capture matrix `thisest' = `ests'[1,"phi`inner'`counter'"]
	    if _rc == 0 {
		local phidiff = el(`thisest',1,1)
		local phi`inner'`counter' = `phi`inner'`counter'' 	    /* 
    */               + `phidiff'/  `beta`base`counter''`counter'' 
		replace phi`counter' = `phi`inner'`counter'' 	    /* 
*/                                     if `newy' == `inner'
	    }
	    local inner = `inner' + 1
	}
	/* Check if the variable is being used for others */
	local vout = 1 
	while `vout' <= `ncat' {
	    local outer = 1
	    while `outer' <= `consgrp' {
		local thisvar : word 1 of `cgrp`outer''
		if "`thisvar'" == "phi`vout'`counter'" {
		    local inner = 2
		    local vcount : word count `cgrp`outer''
		    while `inner' <= `vcount' {
			local thisvar : word `inner' of `cgrp`outer''
			local varnum = substr("`thisvar'",4,1)
			local `thisvar' = `phi`vout'`counter''
			replace phi`counter' = `phi`vout'`counter''  /* 
*/                                             if `newy' == `varnum'
			local inner = `inner' + 1
		    }
		}
		local outer = `outer' + 1
	    }
	    local vout = `vout' + 1
	}
    /*  
	Now we can update the linearizing u and v variables 
    */
	tokenize `indvars'
	local varnum = 1
	while "`1'" ~= "" {
	    if `varnum' == `base`counter'' {
		replace beta`varnum'`counter' = 		    /* 
*/            lsum`counter'*phi`counter'/`beta`base`counter''`counter''
	    }
	    else {
		replace beta`varnum'`counter' = phi`counter'*`1'
	    }	
	    local varnum = `varnum' + 1
	    macro shift
	}
    /* 
	Finally, update the variables to produce the phis 
    */
	local inner = 1
	while `inner' <= `ncat' {
	    replace phi`inner'`counter' = lsum`counter'/	    /* 
*/                                        `beta`base`counter''`counter'' /*  
    */                                 * (`newy' == `inner')
	    local inner = `inner' + 1
	}
	local counter = `counter' + 1
    }
    /*	
    Now we need to set the variable in the model to the value of the 
    variable to which it is constrained. (Trust me, its easier done 
    than said).
    */
    local counter = 1
    while `counter' <= `consgrp' {
	tokenize `cgrp`counter''
	local modvar `1'
	macro shift
	while "`1'" ~= "" {
	    replace `modvar' = `1' if `1' ~= 0
	    macro shift
	}
	local counter = `counter' + 1
    }
}}

matrix `ests' = e(V)

if `done' == 0 {
    noi di in red "Model failed to converge in 100 iterations"
    exit
}

/* 
  We now have a nicely converged model. However, we need to get the  
  parameters and standard errors into a nice format. Its easiest to 
  do the covariance matrix first: recalculate the design 
  matrix and do the regression again 
*/
local counter = 1
while `counter'  <= `maxdim' {
/* 
   now create the variables used to estimate the other betas 
   First, update the betas and get the current approximation 
   to xB    
*/     
    tokenize `indvars'
    replace lsum`counter' = 0
    local varnum = 1
    while "`1'" ~= "" {
	replace lsum`counter' = lsum`counter' + 		    /* 
*/                                  (`1' * `beta`varnum'`counter'') 
	local varnum = `varnum' + 1
	macro shift
    }
    /* 
	Next, update the approximations to phi, both macros and variables 
    */
    local inner = 1
    while `inner' <= `ncat' {
	replace phi`counter' = `phi`inner'`counter'' 	    /* 
*/                                  if `newy' == `inner'
	local inner = `inner' + 1
	}
	/* Check if the variable is being used for others */
    local vout = 1 
    while `vout' <= `ncat' {
	local outer = 1
	while `outer' <= `consgrp' {
	    local thisvar : word 1 of `cgrp`outer''
	    if "`thisvar'" == "phi`vout'`counter'" {
		local inner = 2
		local vcount : word count `cgrp`outer''
		while `inner' <= `vcount' {
		    local thisvar : word `inner' of `cgrp`outer''
		    local varnum = substr("`thisvar'",4,1)
		    local `thisvar' = `phi`vout'`counter''
		    replace phi`counter' = `phi`vout'`counter''  /* 
*/                                             if `newy' == `varnum'
		    local inner = `inner' + 1
		}
	    }
	    local outer = `outer' + 1
	}
	local vout = `vout' + 1
    }
    /*  
	Now we can update the beta and phi variables 
    */
    tokenize `indvars'
    local varnum = 1
    while "`1'" ~= "" {
	replace beta`varnum'`counter' = phi`counter'*`1'
	local varnum = `varnum' + 1
	macro shift
    }
    /* 
	Finally, update the variables to produce the phis 
    */
    local inner = 1
    while `inner' <= `ncat' {
	replace phi`inner'`counter' = lsum`counter'*(`newy' == `inner')
	local inner = `inner' + 1
    }
    local counter = `counter' + 1
}

clogit `ys' `predlst', group(`oldi')
matrix fullvar = e(V)
matrix fullest = e(b) 
/* 
  We now have a nicely converged model. However, we need to get the  
  parameters and standard errors into a nice format. We have 
  estimates for the parameters, we just need to put them into a matrix
*/

local counter = 1
while `counter' <= `maxdim' {
    local inner = 1
    while `inner' <= `ncat' {
	local posn = (`counter'-1)*(`ncat' + `numvars')+`inner'
	matrix estlist[1,`posn'] = `phi`inner'`counter''
	local inner = `inner' + 1
    }
    local inner = 1
    while `inner' <= `numvars' {
	local posn = (`counter'-1)*(`ncat' + `numvars')+`ncat' + `inner'
	matrix estlist[1,`posn'] = `beta`inner'`counter''
	local inner = `inner' + 1
    }
    local counter = `counter' + 1
}

/* now get covariance and variances from fullvar, put them in covlist */

local counter = 1
while `counter' <= `params' {
    local var1 : word `counter' of `vnames'
    local inner = `counter'
    while `inner' <= `params' {
	local var2 : word `inner' of `vnames'
	capture matrix `thisest' = fullvar["`var1'","`var2'"]
	if _rc == 0 {
	    matrix covlist[`counter',`inner'] = el(`thisest',1,1)
	    if `inner' > `counter' {
		matrix covlist[`inner',`counter'] = el(`thisest',1,1)
	    }
	}
	else {
	    matrix covlist[`counter',`inner'] = 0
	    if `inner' > `counter' {
		matrix covlist[`inner', `counter'] = 0
	    }
	}
	local inner = `inner' + 1
    }
    local counter = `counter' + 1
}
 
matrix covdiag = vecdiag(covlist)
local params = 0
local length = colsof(covdiag)
local counter = 1
while `counter' <= `length' {
    if el(covdiag, 1, `counter') > 0 {
	local params = `params' + 1
    }
    local counter = `counter' + 1
}

estimates post estlist covlist

scalar chi2     = 2*(`newll' - null_ll)
scalar chi2_dif = 2*(full_ll - `newll')

matrix faclev = faclev'
estimates scalar N = `numsubs'
estimates scalar ll_0 = null_ll
estimates scalar ll = `newll'
estimates scalar ll_full = full_ll
estimates scalar df_m = `params'
estimates scalar df_full = full_df
* estimates scalar basecat = el(faclev,`ncat',1)
* estimates scalar ibasecat = `ncat'
estimates scalar k_cat = `ncat' 

estimates matrix cat faclev

estimates local depvar `depvar'
estimates local chi2type "LR"
estimates local cmd "soreg"


noi di ""
noi di in green "Stereotype Logistic Regression" 		    /* 
*/  _col(54) "Number of obs = "  in ye %9.0g `numsubs'
noi di ""
noi di in green "Comparison to null model"	                    /* 
*/ _col(54) "LR Chi2(" in ye (`params') in green ")"                /* 
*/ _col(68)"= " in ye %9.2f chi2
noi di in green _col(54) "Prob > chi2   = " in ye %9.4f 	    /* 
*/                           chiprob(`params',chi2)
noi di ""
noi di in green "Comparison to full model"			    /* 
*/ _col(54) "LR Chi2(" in ye full_df - `params' in green ")"        /* 
*/ _col(68) "= "  in ye %9.2f chi2_dif
noi di in green _col(54) "Prob > chi2   = " in ye %9.4f 	    /* 
*/                 chiprob(full_df - `params' ,chi2_dif)
noi di ""
noi estimates display

local counter = 1
while `counter' <= `numvars' {
    local varname : word `counter' of `indvars'
    noi di in green "beta`counter' = " in yellow "`varname'"
    local counter = `counter' + 1
}

end

