/***

Title
-----

{phang}{cmd:aprlb} {hline 2} Estimate the lower bound on the average persuasion rate

Syntax
------

> {cmd:aprlb} _depvar_ _instrvar_ [_covariates_] [_if_] [_in_] [, {cmd:model}(_string_) {cmd:title}(_string_)]

### Options

| _option_          | _Description_           | 
|-------------------|-------------------------|
| {cmd:model}(_string_)   | Regression model when _covariates_ are present |
| {cmd:title}(_string_)   | Title     |


Description
-----------

__aprlb__ estimates the lower bound on the average persuasion rate (APR).
_varlist_ should include _depvar_ _instrvar_ _covariates_ in order.
Here, _depvar_ is binary outcomes (_y_), _instrvar_ is binary instruments (_z_), 
and _covariates_ (_x_) are optional. 

There are two cases: (i) _covariates_ are absent and (ii) _covariates_ are present.

- Without _x_, the lower bound ({cmd:theta_L}) on the APR is defined by 

	{cmd:theta_L} = {Pr({it:y}=1|{it:z}=1) - Pr({it:y}=1|{it:z}=0)}/{1 - Pr({it:y}=1|{it:z}=0)}.

	The estimate and its standard error are obtained by the following procedure:
	
1. Pr({it:y}=1|{it:z}=1) and Pr({it:y}=1|{it:z}=0) are estimated by regressing _y_ on _z_.
2. {cmd:theta_L} is computed using the estimates obtained above.
3. The standard error is computed via STATA command __nlcom__. 

- With _x_, the lower bound ({cmd:theta_L}) on the APR is defined by 

	{cmd:theta_L} = E[{cmd:theta_L}({it:x})],
	
	where

	{cmd:theta_L}({it:x}) = {Pr({it:y}=1|{it:z}=1,{it:x}) - Pr({it:y}=1|{it:z}=0,{it:x})}/{1 - Pr({it:y}=1|{it:z}=0,{it:x})}.
	
The estimate is obtained by the following procedure.
	
If {cmd:model}("no_interaction") is selected (default choice),
	
1. Pr({it:y}=1|{it:z},{it:x}) is estimated by regressing _y_ on _z_ and _x_.
	
Alternatively, if {cmd:model}("interaction") is selected,
	
1a. Pr({it:y}=1|{it:z}=1,{it:x}) is estimated by regressing _y_ on _x_ given _z_ = 1.
1b. Pr({it:y}=1|{it:z}=0,{it:x}) is estimated by regressing _y_ on _x_ given _z_ = 0.
	
Ater step 1, both options are followed by:
	
2. For each _x_ in the estimation sample, {cmd:theta_L}({it:x}) is evaluated.
3. The estimates of {cmd:theta_L}({it:x}) are averaged to estimate {cmd:theta_L}.
	
	When _covariates_ are present, the standard error is missing because an analytic formula for the standard error is complex.
	Bootstrap inference is implemented when this package's command __persuasio__ is called to conduct inference. 
	
Options
-------

{cmd:model}(_string_) specifies a regression model of _y_ on _z_ and _x_. 

This option is only relevant when _x_ is present.
The default option is "no_interaction" between _z_ and _x_. 
When "interaction" is selected, full interactions between _z_ and _x_ are allowed; 
this is accomplished by estimating Pr({it:y}=1|{it:z}=1,{it:x}) and Pr({it:y}=1|{it:z}=0,{it:x}), separately.

{cmd:title}(_string_) specifies a title.

Remarks
-------

It is recommended to use this package's command __persuasio__ instead of calling __aprlb__ directly.

Examples
--------

We first call the dataset included in the package.

		. use GKB, clear

The first example estimates the lower bound on the APR without covariates.
		
		. aprlb voteddem_all post

The second example adds a covariate.

		. aprlb voteddem_all post MZwave2
		
The third example estimates the lower bound by the covariate.		
		
        . by MZwave2, sort: aprlb voteddem_all post		

Stored results
--------------

### Scalars

> __e(N)__: sample size

> __e(lb_coef)__: estimate of the lower bound on the average persuasion rate

> __e(lb_se)__: standard error of the lower bound on the average persuasion rate


### Macros

> __e(outcome)__: variable name of the binary outcome variable

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
capture program drop aprlb
program aprlb, eclass sortpreserve byable(recall)

	version 14.2
	
	syntax varlist (min=2) [if] [in] [, model(string) title(string)]
		
	marksample touse
		
	gettoken Y varlist_without_Y : varlist
	gettoken Z X : varlist_without_Y
	
	quietly levelsof `Y'
	if "`r(levels)'" != "0 1" {
	
	display "`Y' is not a 0/1 variable"
	error 450	
	}
	
	quietly levelsof `Z'
	if "`r(levels)'" != "0 1" {
	
	display "`Z' is not a 0/1 variable"
	error 450
	}
	
	display " "
	display as text "{hline 65}"
	display "{bf:aprlb:} Estimating the Lower Bound on the Average Persuasion Rate"
	display as text "{hline 65}"
	display " "
	display " - Binary outcome: `Y'"
	display " - Binary instrument: `Z'"
	display " - Covariates (if exist): `X'"
    display " "
	
	* if there are no covariates (X) 
	if "`X'" == "" { 
	
	quietly reg `Y' `Z' if `touse', robust
		
	local nobs = e(N)
	
	quietly nlcom lower_bound:_b[`Z']/(1-_b[_cons])
				
    tempname b V lb se
	
	matrix `b' = r(b)
	matrix `V' = r(V)	
	scalar `lb' = `b'[1,1]
	scalar `se' = sqrt(`V'[1,1])
	
	ereturn post `b' `V', obs(`nobs') esample(`touse')
	ereturn display, nopv	
	
	display " "
	display "Note: It is recommended to use {bf:persuasio} for causal inference."
    display " "
	
	ereturn scalar lb_coef = `lb'
    ereturn scalar lb_se = `se'
    ereturn local outcome `Y'
    ereturn local instrument `Z'
 		
	}
	
	* if there are covariates (X)
	if "`X'" != "" {
	
	tempvar yhat yhat1 yhat0 thetahat_num thetahat_den thetahat
	
		if "`model'" == "" | "`model'" == "no_interaction" { 
	
		quietly reg `Y' `Z' `X' if `touse', robust

		tempname bhat b_coef
		
		matrix `bhat' = e(b)
		scalar `b_coef' = `bhat'[1,1]
		
		quietly predict `yhat' if `touse'
				
		gen `yhat1' = `yhat' + `b_coef' - `b_coef'*`Z'
		gen `yhat0' = `yhat' - `b_coef'*`Z'
	
		}
		
		if "`model'" == "interaction" { 
	
			quietly {
			reg `Y' `X' if `Z'==1 & `touse', robust
			predict `yhat1' if `touse'	
			reg `Y' `X' if `Z'==0 & `touse', robust
			predict `yhat0' if `touse'
			}
		
		}
		
	quietly replace `yhat1' = min(max(`yhat1',0),1)
	quietly replace `yhat0' = min(max(`yhat0',0),1)

	gen `thetahat_num' = `yhat1' - `yhat0'
	gen `thetahat_den' = 1 - `yhat0'
	quietly replace `thetahat_den' = max(`thetahat_den', 1e-8)
	gen `thetahat' = `thetahat_num'/`thetahat_den'
    
	quietly sum `thetahat' if `touse'
		
	tempname lower_bound_coef lower_bound_se
	
	local nobs = r(N)
	
	tempname b lb se
	
	scalar `lb' = r(mean)
	scalar `se' = .
		
	matrix `b' = r(mean)
	matrix colnames `b' = lower_bound
	
    ereturn post `b', obs(`nobs') esample(`touse')
	ereturn display, nopv	
	
	display " "
	display "Notes: It is recommended to use {bf:persuasio} for causal inference."
	display "       Standard errors are missing if covariates are present."
    display " "
	
	ereturn scalar lb_coef = `lb'
    ereturn scalar lb_se = `se'
    ereturn local outcome `Y'
    ereturn local instrument `Z'
    ereturn local covariates `X'
	ereturn local model `model'
	
	}
	
	display "Reference: Jun and Lee (2019), arXiv:1812.02276 [econ.EM]"

end
