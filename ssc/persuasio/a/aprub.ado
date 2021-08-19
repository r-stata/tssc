/***

Title
-----

{phang}{cmd:aprub} {hline 2} Estimate the upper bound on the average persuasion rate

Syntax
------

> {cmd:aprub} _depvar_ _treatrvar_ _instrvar_ [_covariates_] [_if_] [_in_] [, {cmd:model}(_string_) {cmd:title}(_string_)]

### Options

| _option_          | _Description_           | 
|-------------------|-------------------------|
| {cmd:model}(_string_)   | Regression model when _covariates_ are present |
| {cmd:title}(_string_)   | Title      |


Description
-----------

__aprub__ estimates the upper bound on the average persuasion rate (APR).
_varlist_ should include _depvar_ _treatrvar_ _instrvar_ _covariates_ in order.
Here, _depvar_ is binary outcomes (_y_), _treatrvar_ is binary treatment (_t_), 
_instrvar_ is binary instruments (_z_), and _covariates_ (_x_) are optional. 

There are two cases: (i) _covariates_ are absent and (ii) _covariates_ are present.

- Without _x_, the upper bound ({cmd:theta_U}) on the APR is defined by 

	{cmd:theta_U} = {E[{it:A}|{it:z}=1] - E[{it:B}|{it:z}=0]}/{1 - E[{it:B}|{it:z}=0]},

	where {it:A} = 1({it:y}=1,{it:t}=1)+1-1({it:t}=1) and 
		  {it:B} = 1({it:y}=1,{it:t}=0).
	
	The estimate and its standard error are obtained by the following procedure:
	
1. E[{it:A}|{it:z}=1] is estimated by regressing {it:A} on _z_.
2. E[{it:B}|{it:z}=0] is estimated by regressing {it:B} on _z_.
3. {cmd:theta_U} is computed using the estimates obtained above.
4. The standard error is computed via STATA command __nlcom__. 

- With _x_, the upper bound ({cmd:theta_U}) on the APR is defined by 

	{cmd:theta_U} = E[{cmd:theta_U}({it:x})],
	
	where

	{cmd:theta_U}({it:x}) = {E[{it:A}|{it:z}=1,{it:x}] - E[{it:B}|{it:z}=0,{it:x}]}/{1 - E[{it:B}|{it:z}=0,{it:x}]}.
	
The estimate is obtained by the following procedure.
	
If {cmd:model}("no_interaction") is selected (default choice),
	
1. E[{it:A}|{it:z}=1,{it:x}] is estimated by regressing {it:A} on _z_ and _x_.
2. E[{it:B}|{it:z}=0,{it:x}] is estimated by regressing {it:B} on _z_ and _x_.
	
Alternatively, if {cmd:model}("interaction") is selected,
	
1. E[{it:A}|{it:z}=1,{it:x}] is estimated by regressing {it:A} on _x_ given _z_ = 1.
2. E[{it:B}|{it:z}=0,{it:x}] is estimated by regressing {it:B} on _x_ given _z_ = 0.
	
Ater step 1, both options are followed by:
	
3. For each _x_ in the estimation sample, {cmd:theta_U}({it:x}) is evaluated.
4. The estimates of {cmd:theta_U}({it:x}) are averaged to estimate {cmd:theta_U}.
	
	When _covariates_ are present, the standard error is missing because an analytic formula for the standard error is complex.
	Bootstrap inference is implemented when this package's command __persuasio__ is called to conduct inference. 
	
Options
-------

{cmd:model}(_string_) specifies a regression model.

This option is only relevant when _x_ is present.
The dependent variable is 
either {it:A} or {it:B}. 
The default option is "no_interaction" between _z_ and _x_. 
When "interaction" is selected, full interactions between _z_ and _x_ are allowed.

{cmd:title}(_string_) specifies a title.

Remarks
-------

It is recommended to use this package's command __persuasio__ instead of calling __aprub__ directly.

Examples
--------

We first call the dataset included in the package.

		. use GKB, clear

The first example estimates the upper bound on the APR without covariates.
		
		. aprub voteddem_all readsome post

The second example adds a covariate.

		. aprub voteddem_all readsome post MZwave2

The third example estimates the upper bound by the covariate.		
		
        . by MZwave2,sort: aprub voteddem_all readsome post
		
Stored results
--------------

### Scalars

> __e(N)__: sample size

> __e(ub_coef)__: estimate of the upper bound on the average persuasion rate

> __e(ub_se)__: standard error of the upper bound on the average persuasion rate


### Macros

> __e(outcome)__: variable name of the binary outcome variable

> __e(treatment)__: variable name of the binary treatment variable 

> __e(instrument)__: variable name of the binary instrumental variable 

> __e(covariates)__: variable name(s) of the covariates if they exist

> __e(model)__: regression model specification ("no_interaction" or "interaction")

### Functions:

> __e(sample)__: 1 if the observations are used for estimation, and 0 otherwise. 


Authors
-------

Sung Jae Jun, Penn State University, <sjun@psu.edu> 

Sokbae Lee, Columbia University, <sl3841@columbia.edu>

License
-------

GPL-3

References
----------

Sung Jae Jun and Sokbae Lee (2019), 
Identifying the Effect of Persuasion, 
[arXiv:1812.02276 [econ.EM]](https://arxiv.org/abs/1812.02276) 

Version
-------

0.1.0 30 January 2021

***/
capture program drop aprub
program aprub, eclass sortpreserve byable(recall)

	version 14.2
	
	syntax varlist (min=3) [if] [in] [, model(string) title(string)]
	
	marksample touse
	
	gettoken Y varlist_without_Y : varlist
	gettoken T varlist_without_YT : varlist_without_Y
	gettoken Z X : varlist_without_YT
	
	quietly levelsof `Y'
	if "`r(levels)'" != "0 1" {
	
	display "`Y' is not a 0/1 variable"
	error 450	
	}
	
	quietly levelsof `T'
	if "`r(levels)'" != "0 1" {
	
	display "`T' is not a 0/1 variable"
	error 450
	}
	
	quietly levelsof `Z'
	if "`r(levels)'" != "0 1" {
	
	display "`Z' is not a 0/1 variable"
	error 450
	}
	
	display " "
	display as text "{hline 65}"
	display "{bf:aprub:} Estimating the Upper Bound on the Average Persuasion Rate"
	display as text "{hline 65}"
	display " "
	display " - Binary outcome: `Y'"
	display " - Binary treatment: `T'"
	display " - Binary instrument: `Z'"
	display " - Covariates (if exist): `X'"
    display " "
	
	
	* generate variables used in estimating persuation rates

	tempvar case_id a_u b_l
	gen  `case_id' = _n            /* generate temporary Case ID */
	gen `a_u' = `Y'*`T' + (1-`T')
	gen `b_l' = `Y'*(1-`T')
	
	* if there are no covariates (X) 
	if "`X'" == "" { 
		
	quietly {
		reg `a_u' `Z' if `touse'
		local nobs = e(N)
		est store a_u_reg
		reg `b_l' `Z' if `touse'
		est store b_l_reg
		suest a_u_reg b_l_reg, vce(cluster `case_id') 

		* estimate of the uppe bound for average persuation rate  
		
		nlcom (upper_bound: ([a_u_reg_mean]_cons + [a_u_reg_mean]`Z' - [b_l_reg_mean]_cons)/(1-[b_l_reg_mean]_cons))
		}
				
    tempname b V ub se
	
	matrix `b' = r(b)
	matrix `V' = r(V)	
	scalar `ub' = `b'[1,1]
	scalar `se' = sqrt(`V'[1,1])
	
	ereturn post `b' `V', obs(`nobs') esample(`touse')
	ereturn display, nopv	
	
	display " "
	display "Note: It is recommended to use {bf:persuasio} for causal inference."
    display " "
	
	ereturn scalar ub_coef = `ub'
    ereturn scalar ub_se = `se'
    ereturn local outcome `Y'
	ereturn local treatment `T'
    ereturn local instrument `Z'
	
	estimates clear		
	}
	
	* if there are covariates (X)
	if "`X'" != "" {
	
	tempvar yhat_a_u yhat_b_l yhat1 yhat0 thetahat_num thetahat_den thetahat
	
		if "`model'" == "" | "`model'" == "no_interaction" { 
	
		quietly {
		
		    tempname bhat b_coef
			
			reg `a_u' `Z' `X' if `touse'
			
			matrix `bhat' = e(b)
			scalar `b_coef' = `bhat'[1,1]
			predict `yhat_a_u' if `touse'
			gen `yhat1' = `yhat_a_u' + `b_coef' - `b_coef'*`Z'
	
			reg `b_l' `Z' `X' if `touse'
						
			matrix `bhat' = e(b)
			scalar `b_coef' = `bhat'[1,1]
			predict `yhat_b_l' if `touse'
			gen `yhat0' = `yhat_b_l' - `b_coef'*`Z'
			}
	
		}
		
		if "`model'" == "interaction" { 
	
		quietly reg `a_u' `X' if `Z'==1 & `touse', robust
		quietly predict `yhat1' if `touse'
	
		quietly reg `b_l' `X' if `Z'==0 & `touse', robust
		quietly predict `yhat0' if `touse'
		}
		
	quietly replace `yhat1' = min(max(`yhat1',0),1)
	quietly replace `yhat0' = min(max(`yhat0',0),1)

	gen `thetahat_num' = `yhat1' - `yhat0'
	gen `thetahat_den' = 1 - `yhat0'
	quietly replace `thetahat_den' = max(`thetahat_den', 1e-8)
	gen `thetahat' = `thetahat_num'/`thetahat_den'
    
	quietly sum `thetahat' if `touse'
	
	tempname upper_bound_coef
	
	local nobs = r(N)
	
	tempname b ub se
	
	scalar `ub' = r(mean)
	scalar `se' = .
		
	matrix `b' = r(mean)
	matrix colnames `b' = upper_bound
	
    ereturn post `b', obs(`nobs') esample(`touse')
	ereturn display, nopv	
	
	display " "
	display "Notes: It is recommended to use {bf:persuasio} for causal inference."
	display "       Standard errors are missing if covariates are present."
    display " "
	
	ereturn scalar ub_coef = `ub'
    ereturn scalar ub_se = `se'
    ereturn local outcome `Y'
	ereturn local treatment `T'
    ereturn local instrument `Z'
    ereturn local covariates `X'
	ereturn local model `model'
	
	}
	
	display "Reference: Jun and Lee (2019), arXiv:1812.02276 [econ.EM]"

end
