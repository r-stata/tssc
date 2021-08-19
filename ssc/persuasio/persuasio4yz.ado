/***

Title
-----

{phang}{cmd:persuasio4yz} {hline 2} Conduct causal inference on persuasive effects for binary outcomes _y_ and binary instruments _z_

Syntax
------

> {cmd:persuasio4yz} _depvar_ _instrvar_ [_covariates_] [_if_] [_in_] [, {cmd:level}(#) {cmd:model}(_string_) {cmd:method}(_string_) {cmd:nboot}(#) {cmd:title}(_string_)]

### Options

| _option_          | _Description_           | 
|-------------------|-------------------------|
| {cmd:level}(#) | Set confidence level; default is {cmd:level}(95) |
| {cmd:model}(_string_)   | Regression model when _covariates_ are present |
| {cmd:method}(_string_) | Inference method; default is {cmd:method}("normal")    |
| {cmd:nboot}(#) | Perform # bootstrap replications |
| {cmd:title}(_string_) | Title     |

Description
-----------

{cmd:persuasio4yz} conducts causal inference on persuasive effects.

It is assumed that binary outcomes _y_ and binary instruments _z_ are observed. 
This command is for the case when persuasive treatment (_t_) is unobserved, 
using an estimate of the lower bound on the average persuasion rate (APR) via 
this package's command {cmd:aprlb}.

_varlist_ should include _depvar_ _instrvar_ _covariates_ in order. Here, _depvar_ is binary outcomes (_y_), _instrvar_ is binary instruments (_z_), and _covariates_ (_x_) are optional. 

When treatment _t_ is unobserved, the upper bound on the APR is simply 1. 

There are two cases: (i) _covariates_ are absent and (ii) _covariates_ are present.

- Without _x_, the lower bound ({cmd:theta_L}) on the APR is defined by 

	{cmd:theta_L} = {Pr({it:y}=1|{it:z}=1) - Pr({it:y}=1|{it:z}=0)}/{1 - Pr({it:y}=1|{it:z}=0)}.

	The estimate and confidence interval are obtained by the following procedure:
	
1. Pr({it:y}=1|{it:z}=1) and Pr({it:y}=1|{it:z}=0) are estimated by regressing _y_ on _z_.
2. {cmd:theta_L} is computed using the estimates obtained above.
3. The standard error is computed via STATA command __nlcom__. 
4. Then, a confidence interval for the APR is set by 

{p 8 8 2}		[ _est_ - _cv_ * _se_ , 1 ],
	
where _est_ is the estimate, _se_ is the standard error, and _cv_ is the one-sided standard normal critical value (e.g., _cv_ = 1.645 for {cmd:level}(95)).
	
- With _x_, the lower bound ({cmd:theta_L}) on the APR is defined by 

	{cmd:theta_L} = E[{cmd:theta_L}(x)],
	
	where

	{cmd:theta_L}(x) = {Pr({it:y}=1|{it:z}=1,{it:x}) - Pr({it:y}=1|{it:z}=0,{it:x})}/{1 - Pr({it:y}=1|{it:z}=0,{it:x})}.
		
The estimate is obtained by the following procedure.
	
If {cmd:model}("no_interaction") is selected (default choice),
	
1. Pr({it:y}=1|{it:z},{it:x}) is estimated by regressing _y_ on _z_ and _x_.
	
Alternatively, if {cmd:model}("interaction") is selected,
	
1a. Pr({it:y}=1|{it:z}=1,{it:x}) is estimated by regressing _y_ on _x_ given _z_ = 1.
1b. Pr({it:y}=1|{it:z}=0,{it:x}) is estimated by regressing _y_ on _x_ given _z_ = 0.
	
Ater step 1, both options are followed by:
	
2. For each x in the estimation sample, {cmd:theta_L}(x) is evaluated.
3. The estimates of {cmd:theta_L}(x) are averaged to estimate {cmd:theta_L}.
4. A bootstrap confidence interval for the APR is set by 

{p 8 8 2}		[ bs_est(_alpha_) , 1 ],
		
where bs_est(_alpha_) is the _alpha_ quantile of the bootstrap estimates of {cmd:theta_L}
and 1 - _alpha_ is the confidence level.  
	
The bootstrap procedure is implemented via STATA command {cmd:bootstrap}. 
		
Options
-------

{cmd:model}(_string_) specifies a regression model of _y_ on _z_ and _x_. 

This option is only relevant when _x_ is present.
The default option is "no_interaction" between _z_ and _x_. 
When "interaction" is selected, full interactions between _z_ and _x_ are allowed; 
this is accomplished by estimating Pr({it:y}=1|{it:z}=1,{it:x}) and Pr({it:y}=1|{it:z}=0,{it:x}), separately.

{cmd:level}(#) sets confidence level; default is {cmd:level}(95). 

{cmd:method}(_string_) refers the method for inference.

The default option is {cmd:method}("normal").
By the naure of identification, one-sided confidence intervals are produced. 

{p 4 8 2}1. When _x_ is present, it needs to be set as {cmd:method}("bootstrap"); 
otherwise, the confidence interval will be missing.
	
{p 4 8 2}2. When _x_ is absent, both options yield non-missing confidence intervals.
	
{cmd:nboot}(#) chooses the number of bootstrap replications.

The default option is {cmd:nboot}(50).
It is only relevant when {cmd:method}("bootstrap") is selected.

{cmd:title}(_string_) specifies a title.

Remarks
-------

It is recommended to use {cmd:nboot}(#) with # at least 1000. 
A default choice of 50 is meant to check the code initially 
because it may take a long time to run the bootstrap part.
The bootstrap confidence interval is based on percentile bootstrap.
Normality-based bootstrap confidence interval is not recommended 
because bootstrap standard errors can be unreasonably large in applications. 

Examples
--------

We first call the dataset included in the package.

		. use GKB, clear

The first example conducts inference on the APR without covariates, using normal approximation.
		
		. persuasio4yz voteddem_all post, level(80) method("normal")
		
The second example conducts bootstrap inference on the APR.
		
		. persuasio4yz voteddem_all post, level(80) method("bootstrap") nboot(1000)	
		
The third example conducts bootstrap inference on the APR with a covariate, MZwave2, interacting with the instrument, post. 
		
		. persuasio4yz voteddem_all post MZwave2, level(80) model("interaction") method("bootstrap") nboot(1000)			
				
Stored results
--------------

### Matrices

> __e(apr_est)__: (1*2 matrix) bounds on the average persuasion rate in the form of [lb, 1]

> __e(apr_ci)__: (1*2 matrix) confidence interval for the average persuasion rate in the form of [lb_ci, 1] 


### Macros

> __e(cilevel)__: confidence level

> __e(inference_method)__: inference method: "normal" or "bootstrap" 

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
capture program drop persuasio4yz
program persuasio4yz, eclass sortpreserve byable(recall)

	version 14.2
	
	syntax varlist (min=2) [if] [in] [, level(cilevel) model(string) method(string) nboot(numlist >0 integer) title(string)]
	
	marksample touse
			
	quietly aprlb `varlist' if `touse', model("`model'")
	
	* displaying results
	if "`title'" != "" {
    
	display "`title':"
    
	}
	
	tempname lb_coef
	scalar `lb_coef' = e(lb_coef)
	
	* inference based on normal approximation
	if "`method'" == "" | "`method'" == "normal" { 
	
		if "`level'" != "" {	
		local alpha_level = `level'/100
		}
		if "`level'" == "" {	
		local alpha_level = 0.95
		}
		
		tempname cv_cns lower_bound_ci
		scalar `cv_cns' = invnormal(`alpha_level')   /* one-sided critical value */
		scalar `lower_bound_ci' = e(lb_coef) - `cv_cns'*e(lb_se)
		
		* Displaying results
	    display " "
		display as text "{hline 65}"
		display "{bf:persuasio4yz:} Causal inference on the average persuasion rate"
		display " when binary outcomes and binary instruments are observed"
		display as text "{hline 65}"
		display " "
		if "`title'" != "" {
		display "Title: `title'"
		}
		display " - Binary outcome: `e(outcome)'"
		display " - Binary instrument: `e(instrument)'"
		display " "
		display as text "{hline 13}{c TT}{hline 40}"

		display as text %12s  "Parameter" " {c |}" /*
		*/ _col(16) " Estimate " /*
		*/ _col(30) "[`level'% Conf. Interval]" 
        display as text "{hline 13}{c +}{hline 40}"
	    
		display as text %12s "Lower Bound" " {c |}" /*
		*/ as result /*
		*/ _col(17) %8.0g `lb_coef' " " /*
		*/ _col(32) %8.0g `lower_bound_ci' " " /*
		*/ %8.0g 1 " "
		
		display as text "{hline 13}{c BT}{hline 40}"

		display " "
		display "Note: `level'% one-sided conf. interval is based on normal approximation."
		display " "
	
	}
	
	* inference based on bootstrap
	if "`method'" == "bootstrap" { 
	
	    * Displaying results
	    display " "
		display as text "{hline 65}"
		display "{bf:persuasio4yz:} Causal inference on the average persuasion rate"
		display " when binary outcomes and binary instruments are observed"
		display " along with covariates"
		display as text "{hline 65}"
		display " "
		if "`title'" != "" {
		display "Title: `title'"
		}
		display " - Binary outcome: `e(outcome)'"
		display " - Binary instrument: `e(instrument)'"
		display " - Covariates (if exist): `e(covariates)'"
		display " - Regression model (if specified): `e(model)'"
		display " "
	
		if "`level'" != "" {	
		local alpha_level = `level'/100
		}
		if "`level'" == "" {	
		local alpha_level = 0.95
		}
		
		local cv_cns = invnormal(`alpha_level')   /* one-sided critical value */
		local bs_level = round(10000*(1-(1-`alpha_level')*2))/100 /* level for bootstrap */
		
		if "`nboot'" != "" {
			bootstrap coef=e(lb_coef), reps(`nboot') level(`bs_level') notable nowarn: aprlb `varlist' if `touse', model("`model'") 
		}
		if "`nboot'" == "" {
			bootstrap coef=e(lb_coef), reps(50) level(`bs_level') notable nowarn: aprlb `varlist' if `touse', model("`model'")
			
		}
		
		tempname bs_ci_percentile lower_bound_ci
		matrix `bs_ci_percentile' = e(ci_percentile)
		scalar `lower_bound_ci' = `bs_ci_percentile'[1,1] 

		* Displaying results further
		display " "
		display as text "{hline 13}{c TT}{hline 40}"

		display as text %12s  "Parameter" " {c |}" /*
		*/ _col(16) " Estimate " /*
		*/ _col(30) "[`level'% Conf. Interval]" 
        display as text "{hline 13}{c +}{hline 40}"
	    
		display as text %12s "Lower Bound" " {c |}" /*
		*/ as result /*
		*/ _col(17) %8.0g `lb_coef' " " /*
		*/ _col(32) %8.0g `lower_bound_ci' " " /*
		*/ %8.0g 1 " "
		
		display as text "{hline 13}{c BT}{hline 40}"

		display " "
		display "Note: `level'% one-sided conf. interval is based on percentile bootstrap."
		display " "
	
	}
	
	tempname lb_coef_matrix lb_ci_matrix
	
	matrix `lb_coef_matrix' = (`lb_coef',1)
	matrix `lb_ci_matrix' = (`lower_bound_ci',1)
	
	ereturn clear
	ereturn matrix apr_est = `lb_coef_matrix'
	ereturn matrix apr_ci = `lb_ci_matrix'
	ereturn local cilevel = `alpha_level'*100
	ereturn local inference_method "`method'"
	
	display "Reference: Jun and Lee (2019), arXiv:1812.02276 [econ.EM]"
	
end

