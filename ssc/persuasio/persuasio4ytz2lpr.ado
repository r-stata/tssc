/***

Title
-----

{phang}{cmd:persuasio4ytz2lpr} {hline 2} Conduct causal inference on the local persuasion rate 
for binary outcomes _y_, binary treatments _t_ and binary instruments _z_

Syntax
------

> {cmd:persuasio4ytz2lpr} _depvar_ _treatvar_ _instrvar_ [_covariates_] [_if_] [_in_] [, {cmd:level}(#) {cmd:model}(_string_) {cmd:method}(_string_) {cmd:nboot}(#) {cmd:title}(_string_)]

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

{phang}{cmd:persuasio4ytz2lpr} conducts causal inference on causal inference on the local persuasion rate.

It is assumed that binary outcomes _y_, binary treatments _t_, and binary instruments _z_ are observed. 
This command is for the case when persuasive treatment (_t_) is observed, 
using estimates of the local persuasion rate (LPR) via 
this package's command {cmd:lpr4ytz}.

_varlist_ should include _depvar_ _treatvar_ _instrvar_ _covariates_ in order. 
Here, _depvar_ is binary outcome (_y_), _treatvar_ is binary treatment,
_instrvar_ is binary instrument (_z_), and _covariates_ (_x_) are optional. 

There are two cases: (i) _covariates_ are absent and (ii) _covariates_ are present.

- Without _x_, the LPR is defined by 

	{cmd:LPR} = {Pr({it:y}=1|{it:z}=1)-Pr({it:y}=1|{it:z}=0)}/{Pr[{it:y}=0,{it:t}=0|{it:z}=0]-Pr[{it:y}=0,{it:t}=0|{it:z}=1]}.
	
	The estimate and its standard error are obtained by the following procedure:
	
1. The numerator of the LPR is estimated by regressing _y_ on _z_.
2. The denominator is estimated by regressing (1-{it:y})*(1-{it:t}) on _z_.
3. The LPR is obtained as the ratio.
4. The standard error is computed via STATA command __nlcom__. 
{p 4 8 2}5. Then, a confidence interval for the LPR is obtained via the usual normal approximation.

- With _x_, the LPR is defined by 

	{cmd:LPR} = E[{cmd:LPR}({it:x}){e(1|x) - e(0|x)}]/E[e(1|x) - e(0|x)]
	
	where

{p 4 8 2}	{cmd:LPR}({it:x}) = {Pr({it:y}=1|{it:z}=1,{it:x}) - Pr({it:y}=1|{it:z}=0,{it:x})}/{Pr[{it:y}=0,{it:t}=0|{it:z}=0,{it:x}] - Pr[{it:y}=0,{it:t}=0|{it:z}=1,{it:x}]},
	
	e(1|x) = Pr({it:t}=1|{it:z}=1,{it:x}), and e(0|x) = Pr({it:t}=1|{it:z}=0,{it:x}).
	
The estimate is obtained by the following procedure.
	
If {cmd:model}("no_interaction") is selected (default choice),
	
1. The numerator of the LPR is estimated by regressing _y_ on _z_ and _x_.
2. The denominator is estimated by regressing (1-{it:y})*(1-{it:t}) on _z_ and _x_.
3. The LPR is obtained as the ratio.
4. The standard error is computed via STATA command __nlcom__. 	
{p 4 8 2}5. Then, a confidence interval for the LPR is obtained via the usual normal approximation.
	
Note that in this case, {cmd:LPR}({it:x}) does not depend on _x_ because of the linear regression model specification.
	
Alternatively, if {cmd:model}("interaction") is selected,
	
{p 4 8 2} 1. Pr({it:y}=1|{it:z},{it:x}) is estimated by regressing {it:y} on _x_ given _z_ = 0,1.

{p 4 8 2} 2. Pr[{it:y}=0,{it:t}=0|{it:z},{it:x}] is estimated by regressing (1-{it:y})*(1-{it:t}) on _x_ given _z_ = 0,1.

{p 4 8 2} 3. Pr({it:t}=1|{it:z},{it:x}) is estimated by regressing _t_ on _x_ given _z_ = 0,1.

{p 4 8 2} 4. For each _x_ in the estimation sample, both {cmd:LPR}({it:x}) and {e(1|x)-e(0|x)} are evaluated.

{p 4 8 2} 5. Then, the sample analog of {cmd:LPR} is constructed.

{p 4 8 2} 6. Finally, the bootstrap procedure is implemented via STATA command {cmd:bootstrap}.

Options
-------

{cmd:model}(_string_) specifies a regression model of _y_ on _z_ and _x_. 

This option is only relevant when _x_ is present.
The default option is "no_interaction" between _z_ and _x_. 
When "interaction" is selected, full interactions between _z_ and _x_ are allowed.

{cmd:level}(#) sets confidence level; default is {cmd:level}(95). 

{cmd:method}(_string_) refers the method for inference.

The default option is {cmd:method}("normal").
Since the LPR is point-identified, usual two-sided confidence intervals are produced. 

{p 4 8 2}1. When {cmd:model}("interaction") is chosen as an option, it needs to be set as {cmd:method}("bootstrap"); 
otherwise, the confidence interval will be missing.
		
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

The first example conducts inference on the LPR without covariates, using normal approximation.
		
		. persuasio4ytz2lpr voteddem_all readsome post, level(80) method("normal")
		
The second example conducts bootstrap inference on the LPR.
		
		. persuasio4ytz2lpr voteddem_all readsome post, level(80) method("bootstrap") nboot(1000)	
		
The third example conducts bootstrap inference on the LPR with a covariate, MZwave2, interacting with the instrument, post. 
		
		. persuasio4ytz2lpr voteddem_all readsome post MZwave2, level(80) model("interaction") method("bootstrap") nboot(1000)			
		
Stored results
--------------

### Matrices

> __e(lpr_est)__: (1*1 matrix) estimate of the local persuasion rate

> __e(lpr_ci)__: (1*2 matrix) confidence interval for the local persuasion rate in the form of [lb_ci, ub_ci] 


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
capture program drop persuasio4ytz2lpr
program persuasio4ytz2lpr, eclass sortpreserve byable(recall)

	version 14.2
	
	syntax varlist (min=3) [if] [in] [, level(cilevel) model(string) method(string) nboot(numlist >0 integer) title(string)]
			
	marksample touse
	
	gettoken Y varlist_without_Y : varlist
	gettoken T varlist_without_YT : varlist_without_Y
	gettoken Z X : varlist_without_YT
		
	quietly lpr4ytz `Y' `T' `Z' `X' if `touse', model("`model'")
		
	tempname lpr_coef lpr_se
	scalar `lpr_coef' = e(lpr_coef)
	scalar `lpr_se' = e(lpr_se)
		
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
		
		tempname cv_cns lb_end ub_end
		scalar `cv_cns' = invnormal(1-`alpha_level'/2) /* two-sided critical value */
		scalar `lb_end' = max(0,`lpr_coef' - `cv_cns'*`lpr_se')
		scalar `ub_end' = min(1,`lpr_coef' + `cv_cns'*`lpr_se')
		
		*scalar `lb_end' = `lpr_coef' - `cv_cns'*`lpr_se'
		*scalar `ub_end' = `lpr_coef' + `cv_cns'*`lpr_se'
				
		* Displaying results
	    display " "
		display as text "{hline 65}"
		display "{bf:persuasio4ytz2lpr:} Causal inference on the local Persuasion rate"
		display " when outcome, instrument and instrument are observed"
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
		display as text "{hline 25}{c TT}{hline 40}"

		display as text %24s  "Parameter" " {c |}" /*
		*/ _col(28) "Estimate" /*
		*/ _col(48) "`level'% Conf. Interval" 
        display as text "{hline 25}{c +}{hline 40}"
	    
		display as text %24s "Local Persuasion Rate" " {c |}" /*
		*/ as result /*
		*/ _col(27) %8.0g `lpr_coef' " " /*
		*/ _col(47) %8.0g `lb_end' " "  /*
		*/ _col(53) %8.0g `ub_end' " "
		
		display as text "{hline 25}{c BT}{hline 40}"

		display " "
		display "Note: `level'% conf. interval is based on normal approximation."
		display "   Conf. interval is missing (given as [0,1])  if interactions are"
		display "   allowed between x and z. Use option bootstrap for that case."
		display " "
	
	}
	
	* inference based on bootstrap
	if "`method'" == "bootstrap" { 
	
	    * Displaying results
	    display " "
		display as text "{hline 65}"
		display "{bf:persuasio4ytz2lpr:} Causal inference on the local persuasion rate"
		display " when outcome, instrument and instrument are observed"
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

		local bs_level = round(10000*(1 - `alpha_level'))/100 /* level for bootstrap */
		
		* lower bound
		
		if "`nboot'" != "" {
			bootstrap coef=e(lpr_coef), reps(`nboot') level(`bs_level') notable nowarn: lpr4ytz `Y' `T' `Z' `X' if `touse', model("`model'")
		}
		if "`nboot'" == "" {
			bootstrap coef=e(lpr_coef), reps(50) level(`bs_level') notable nowarn: lpr4ytz `Y' `T' `Z' `X' if `touse', model("`model'")
			
		}
		
		tempname bs_ci_percentile lb_end ub_end
		matrix `bs_ci_percentile' = e(ci_percentile)
		scalar `lb_end' = max(0,`bs_ci_percentile'[1,1]) 
		scalar `ub_end' = min(1,`bs_ci_percentile'[2,1]) 
		
		* Displaying results further
		display " "
		display as text "{hline 25}{c TT}{hline 40}"

		display as text %24s  "Parameter" " {c |}" /*
		*/ _col(28) "Estimate" /*
		*/ _col(48) "`level'% Conf. Interval" 
        display as text "{hline 25}{c +}{hline 40}"
	    
		display as text %24s "Local Persuasion Rate" " {c |}" /*
		*/ as result /*
		*/ _col(27) %8.0g `lpr_coef' " " /*
		*/ _col(47) %8.0g `lb_end' " " /*
		*/ _col(53) %8.0g `ub_end' " "
		
		display as text "{hline 25}{c BT}{hline 40}"

		display " "
		display "Note: `level'% conf. interval is based on percentile bootstrap."
		display " "
	
	}
	
	tempname coef_matrix ci_matrix
	
	matrix `coef_matrix' = (`lpr_coef')
	matrix `ci_matrix' = (`lb_end',`ub_end')
	
	ereturn clear
	ereturn matrix lpr_est = `coef_matrix'
	ereturn matrix lpr_ci = `ci_matrix'
	ereturn local cilevel = (1-`alpha_level')*100
	ereturn local inference_method "`method'"
	
	display "Reference: Jun and Lee (2019), arXiv:1812.02276 [econ.EM]"
	
end

