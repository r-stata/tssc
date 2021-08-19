/***

Title
-----

{phang}{cmd:persuasio4ytz} {hline 2} Conduct causal inference on persuasive effects 
for binary outcomes _y_, binary treatments _t_ and binary instruments _z_

Syntax
------

> {cmd:persuasio4ytz} _depvar_ _treatvar_ _instrvar_ [_covariates_] [_if_] [_in_] [, {cmd:level}(#) {cmd:model}(_string_) {cmd:method}(_string_) {cmd:nboot}(#) {cmd:title}(_string_)]

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

{cmd:persuasio4ytz} conducts causal inference on persuasive effects.

It is assumed that binary outcomes _y_, binary treatments _t_, and binary instruments _z_ are observed. 
This command is for the case when persuasive treatment (_t_) is observed, 
using estimates of the lower and upper bounds on the average persuasion rate (APR) via 
this package's commands {cmd:aprlb} and {cmd:aprub}.

_varlist_ should include _depvar_ _treatvar_ _instrvar_ _covariates_ in order. 
Here, _depvar_ is binary outcomes (_y_), _treatvar_ is binary treatments,
_instrvar_ is binary instruments (_z_), and _covariates_ (_x_) are optional. 

There are two cases: (i) _covariates_ are absent and (ii) _covariates_ are present.

- Without _x_, the lower bound ({cmd:theta_L}) on the APR is defined by 

	{cmd:theta_L} = {Pr({it:y}=1|{it:z}=1) - Pr({it:y}=1|{it:z}=0)}/{1 - Pr({it:y}=1|{it:z}=0)},
	
	and the upper bound ({cmd:theta_U}) on the APR is defined by 

	{cmd:theta_U} = {E[{it:A}|{it:z}=1] - E[{it:B}|{it:z}=0]}/{1 - E[{it:B}|{it:z}=0]},

	where {it:A} = 1({it:y}=1,{it:t}=1)+1-1({it:t}=1) and 
		  {it:B} = 1({it:y}=1,{it:t}=0).	

	The lower bound is estimated by the following procedure:
	
1. Pr({it:y}=1|{it:z}=1) and Pr({it:y}=1|{it:z}=0) are estimated by regressing _y_ on _z_.
2. {cmd:theta_L} is computed using the estimates obtained above.
3. The standard error is computed via STATA command __nlcom__. 

	The upper bound is estimated by the following procedure:
	
1. E[{it:A}|{it:z}=1] is estimated by regressing {it:A} on _z_.
2. E[{it:B}|{it:z}=0] is estimated by regressing {it:B} on _z_.
3. {cmd:theta_U} is computed using the estimates obtained above.
4. The standard error is computed via STATA command __nlcom__. 

	Then, a confidence interval for the APR is set by 

{p 8 8 2}		[ _est_lb_ - _cv_ * _se_lb_ , _est_ub_ + _cv_ * _se_ub_ ],
	
where _est_lb_ and _est_ub_ are the estimates of the lower and upper bounds, 
_se_lb_ and _se_ub_ are the corresponding standard errors, and 
_cv_ is the critical value obtained via the method of Stoye (2009).
	
- With _x_, the lower bound ({cmd:theta_L}) on the APR is defined by 

	{cmd:theta_L} = E[{cmd:theta_L}(x)],
	
	where

	{cmd:theta_L}(x) = {Pr({it:y}=1|{it:z}=1,{it:x}) - Pr({it:y}=1|{it:z}=0,{it:x})}/{1 - Pr({it:y}=1|{it:z}=0,{it:x})},
	
  and the upper bound ({cmd:theta_U}) on the APR is defined by 

	{cmd:theta_U} = E[{cmd:theta_U}({it:x})],
	
	where

	{cmd:theta_U}({it:x}) = {E[{it:A}|{it:z}=1,{it:x}] - E[{it:B}|{it:z}=0,{it:x}]}/{1 - E[{it:B}|{it:z}=0,{it:x}]}.
			
The lower bound is estimated by the following procedure:
	
If {cmd:model}("no_interaction") is selected (default choice),
	
1. Pr({it:y}=1|{it:z},{it:x}) is estimated by regressing _y_ on _z_ and _x_.
	
Alternatively, if {cmd:model}("interaction") is selected,
	
1a. Pr({it:y}=1|{it:z}=1,{it:x}) is estimated by regressing _y_ on _x_ given _z_ = 1.
1b. Pr({it:y}=1|{it:z}=0,{it:x}) is estimated by regressing _y_ on _x_ given _z_ = 0.
	
After step 1, both options are followed by:
	
2. For each x in the estimation sample, {cmd:theta_L}(x) is evaluated.
3. The estimates of {cmd:theta_L}(x) are averaged to estimate {cmd:theta_L}.

The upper bound is estimated by the following procedure:
	
If {cmd:model}("no_interaction") is selected (default choice),
	
1. E[{it:A}|{it:z}=1,{it:x}] is estimated by regressing {it:A} on _z_ and _x_.
2. E[{it:B}|{it:z}=0,{it:x}] is estimated by regressing {it:B} on _z_ and _x_.
	
Alternatively, if {cmd:model}("interaction") is selected,
	
1. E[{it:A}|{it:z}=1,{it:x}] is estimated by regressing {it:A} on _x_ given _z_ = 1.
2. E[{it:B}|{it:z}=0,{it:x}] is estimated by regressing {it:B} on _x_ given _z_ = 0.
	
After step 1, both options are followed by:
	
3. For each _x_ in the estimation sample, {cmd:theta_U}({it:x}) is evaluated.
4. The estimates of {cmd:theta_U}({it:x}) are averaged to estimate {cmd:theta_U}.

Then, a bootstrap confidence interval for the APR is set by 

{p 8 8 2}		[ bs_est_lb(_alpha_) , bs_est_ub(1 - _alpha_) ],
		
where bs_est_lb(_alpha_) is the _alpha_ quantile of the bootstrap estimates of {cmd:theta_L},
	  bs_est_ub(_alpha_) is the 1 - _alpha_ quantile of the bootstrap estimates of {cmd:theta_U},
and 1 - _alpha_ is the confidence level. 

The resulting coverage probability is 1 - _alpha_ if the identified interval never reduces to a singleton set.
More generally, it will be 1 - 2*{it:alpha} by Bonferroni correction.   
	
The bootstrap procedure is implemented via STATA command {cmd:bootstrap}. 
		
Options
-------

{cmd:model}(_string_) specifies a regression model of _y_ on _z_ and _x_. 

This option is only relevant when _x_ is present.
The default option is "no_interaction" between _z_ and _x_. 
When "interaction" is selected, full interactions between _z_ and _x_ are allowed.

{cmd:level}(#) sets confidence level; default is {cmd:level}(95). 

{cmd:method}(_string_) refers the method for inference.

The default option is {cmd:method}("normal").
By the nature of identification, one-sided confidence intervals are produced. 

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
		
		. persuasio4ytz voteddem_all readsome post, level(80) method("normal")
		
The second example conducts bootstrap inference on the APR.
		
		. persuasio4ytz voteddem_all readsome post, level(80) method("bootstrap") nboot(1000)	
		
The third example conducts bootstrap inference on the APR with a covariate, MZwave2, interacting with the instrument, post. 
		
		. persuasio4ytz voteddem_all readsome post MZwave2, level(80) model("interaction") method("bootstrap") nboot(1000)			
		
Stored results
--------------

### Matrices

> __e(apr_est)__: (1*2 matrix) bounds on the average persuasion rate in the form of [lb, ub]

> __e(apr_ci)__: (1*2 matrix) confidence interval for the average persuasion rate in the form of [lb_ci, ub_ci] 


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
capture program drop persuasio4ytz
program persuasio4ytz, eclass sortpreserve byable(recall)

	version 14.2
	
	syntax varlist (min=3) [if] [in] [, level(cilevel) model(string) method(string) nboot(numlist >0 integer) title(string)]
			
	marksample touse
	
	gettoken Y varlist_without_Y : varlist
	gettoken T varlist_without_YT : varlist_without_Y
	gettoken Z X : varlist_without_YT
		
	quietly aprlb `Y' `Z' `X' if `touse', model("`model'")
		
	tempname lb_coef lb_se
	scalar `lb_coef' = e(lb_coef)
	scalar `lb_se' = e(lb_se)
	
	quietly aprub `Y' `T' `Z' `X' if `touse', model("`model'")
		
	tempname ub_coef ub_se
	scalar `ub_coef' = e(ub_coef)
	scalar `ub_se' = e(ub_se)	
	
	* displaying results
	if "`title'" != "" {
    
	display "`title':"
    
	}
	
	
	* inference based on normal approximation
	if "`method'" == "" | "`method'" == "normal" { 
	
		if "`level'" != "" {	
		local alpha_level = 1 - `level'/100
		}
		if "`level'" == "" {	
		local alpha_level = 0.05
		}
		
		/* compute the critical value using Stoye (2009) */
		
		tempname cv_cns1 cv_cns2 correction_term mincv maxcv gridsize cv_cns_stoye lb_end ub_end
		scalar `cv_cns1' = invnormal(1-`alpha_level')   /* one-sided critical value */
		scalar `cv_cns2' = invnormal(1-`alpha_level'/2) /* two-sided critical value */
		scalar `mincv' = `cv_cns1'-0.01
		scalar `maxcv' = `cv_cns2'+0.01
		scalar `gridsize' = (`maxcv'-`mincv')/(e(N)-1)
		scalar `correction_term' = (`ub_coef'-`lb_coef')/max(`ub_se',`lb_se')

		quietly {
			tempvar cvtmp difftmp
			egen `cvtmp' = fill("0 `=`gridsize''")
			replace `cvtmp' = `cvtmp' + `mincv'
			gen `difftmp' = abs(normal(`cvtmp' + `correction_term') - normal(-`cvtmp') - (1-`alpha_level'))
			sum `difftmp'
			replace `cvtmp' = . if `difftmp' > r(min)				
			sum `cvtmp'
			scalar `cv_cns_stoye' = r(mean)
			}

		*scalar `lb_end' = max(0,`lb_coef' - `cv_cns_stoye'*`lb_se')
		*scalar `ub_end' = min(1,`ub_coef' + `cv_cns_stoye'*`ub_se')
		
		scalar `lb_end' = `lb_coef' - `cv_cns_stoye'*`lb_se'
		scalar `ub_end' = `ub_coef' + `cv_cns_stoye'*`ub_se'
				
		* Displaying results
	    display " "
		display as text "{hline 65}"
		display "{bf:persuasio4ytz:} Causal inference on the Average Persuasion Rate"
		display " when outcome, instrument and instrument are observed"
		display as text "{hline 65}"
		display " "
		if "`title'" != "" {
		display "Title: `title'"
		}
		display " - Binary outcome: `e(outcome)'"
		display " - Binary treatment: `e(treatment)'"
		display " - Binary instrument: `e(instrument)'"
		display " "
		display as text "{hline 25}{c TT}{hline 40}"

		display as text %24s  "Parameter" " {c |}" /*
		*/ _col(28) "Bound Estimate" /*
		*/ _col(48) "`level'% Conf. Interval" 
        display as text "{hline 25}{c +}{hline 40}"
	    
		display as text %24s "Average Persuasion Rate" " {c |}" /*
		*/ as result /*
		*/ _col(27) %8.0g `lb_coef' " " /*
		*/ _col(33) %8.0g `ub_coef' " " /*
		*/ _col(47) %8.0g `lb_end' " " /*
		*/ _col(53) %8.0g `ub_end' " "
		
		display as text "{hline 25}{c BT}{hline 40}"

		display " "
		display "Note: `level'% conf. interval is based on normal approximation"
		display "       using the method of Stoye (2009).                      "
		display "       Conf. interval is missing if covariates are present."
		display "       Use option bootstrap for that case."
		display " "
	
	}
	
	* inference based on bootstrap
	if "`method'" == "bootstrap" { 
	
	    * Displaying results
	    display " "
		display as text "{hline 65}"
		display "{bf:persuasio4ytz:} Causal inference on the Average Persuasion Rate"
		display " when outcome, instrument and instrument are observed"
		display " along with covariates"
		display as text "{hline 65}"
		display " "
		if "`title'" != "" {
		display "Title: `title'"
		}
		display " - Binary outcome: `e(outcome)'"
		display " - Binary treatment: `e(treatment)'"
		display " - Binary instrument: `e(instrument)'"
		display " - Covariates (if exist): `e(covariates)'"
		display " - Regression model (if specified): `e(model)'"
		display " "
	
		if "`level'" != "" {	
		local alpha_level = 1 - `level'/100
		}
		if "`level'" == "" {	
		local alpha_level = 0.05
		}

		local bs_level = round(10000*(1 - `alpha_level'*2))/100 /* level for bootstrap */
		
		* lower bound
		
		if "`nboot'" != "" {
			bootstrap coef=e(lb_coef), reps(`nboot') level(`bs_level') notable nowarn: aprlb `Y' `Z' `X' if `touse', model("`model'")
		}
		if "`nboot'" == "" {
			bootstrap coef=e(lb_coef), reps(50) level(`bs_level') notable nowarn: aprlb `Y' `Z' `X' if `touse', model("`model'")
			
		}
		
		tempname bs_ci_percentile lb_end ub_end
		matrix `bs_ci_percentile' = e(ci_percentile)
		scalar `lb_end' = `bs_ci_percentile'[1,1] 
		
		* upper bound
		
		if "`nboot'" != "" {
			bootstrap coef=e(ub_coef), reps(`nboot') level(`bs_level') notable nowarn: aprub `Y' `T' `Z' `X' if `touse', model("`model'")
		}
		if "`nboot'" == "" {
			bootstrap coef=e(ub_coef), reps(50) level(`bs_level') notable nowarn: aprub `Y' `T' `Z' `X' if `touse', model("`model'")
			
		}
		
		matrix `bs_ci_percentile' = e(ci_percentile)
		scalar `ub_end' = `bs_ci_percentile'[2,1] 
		
		* Displaying results further
		display " "
		display as text "{hline 25}{c TT}{hline 40}"

		display as text %24s  "Parameter" " {c |}" /*
		*/ _col(28) "Bound Estimate" /*
		*/ _col(48) "`level'% Conf. Interval" 
        display as text "{hline 25}{c +}{hline 40}"
	    
		display as text %24s "Average Persuasion Rate" " {c |}" /*
		*/ as result /*
		*/ _col(27) %8.0g `lb_coef' " " /*
		*/ _col(33) %8.0g `ub_coef' " " /*
		*/ _col(47) %8.0g `lb_end' " " /*
		*/ _col(53) %8.0g `ub_end' " "
		
		display as text "{hline 25}{c BT}{hline 40}"

		display " "
		display "Note: `level'% conf. interval is based on percentile bootstrap."
		display "     The conf. level is one-sided for the lower and upper bounds separately."
		display " "
	
	}
	
	tempname coef_matrix ci_matrix
	
	matrix `coef_matrix' = (`lb_coef',`ub_coef')
	matrix `ci_matrix' = (`lb_end',`ub_end')
	
	ereturn clear
	ereturn matrix apr_est = `coef_matrix'
	ereturn matrix apr_ci = `ci_matrix'
	ereturn local cilevel = (1-`alpha_level')*100
	ereturn local inference_method "`method'"
	
	display "Reference: Jun and Lee (2019), arXiv:1812.02276 [econ.EM]"
	
end

