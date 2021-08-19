/***

_version 0.1.0_ 


Title
-----

{phang}{cmd:persuasio} {hline 2} Conduct causal inference on persuasive effects 

Syntax
------

> {cmd:persuasio} _subcommand_ _varlist_ [_if_] [_in_] [, {cmd:level}(#) {cmd:model}(_string_) {cmd:method}(_string_) {cmd:nboot}(#) {cmd:title}(_string_)]

### Options

| _Option_          | _Description_           | 
|-------------------|-------------------------|
| {cmd:level}(#) | Set confidence level; default is {cmd:level}(95) |
| {cmd:model}(_string_)   | Regression model when _covariates_ are present |
| {cmd:method}(_string_) | Inference method; default is {cmd:method}("normal")    |
| {cmd:nboot}(#) | Perform # bootstrap replications |
| {cmd:title}(_string_) | Title      |

Description
-----------

{p 0 0 2}{cmd:persuasio} conducts causal inference on persuasive effects. It is a wrapper that calls a variety of subroutines. _subcommand_ has several options:{p_end}

| _Subcommand_ | _Description_                                          |
|--------------|--------------------------------------------------------|
| {cmd:apr}    | inference on APR when y,t,z are observed               |
| {cmd:lpr}    | inference on LPR when y,t,z are observed               |
| {cmd:yz}     | inference on APR and LPR when y,z are observed         |
| {cmd:calc}   | bound estimates on APR and LPR with summary statistics |

{p 4 4 2}{cmd:apr} and {cmd:lpr} refer to a data scenario where binary outcomes _y_, binary treatments _t_, and binary instruments _z_ are observed (with covariates _x_ if exist) for each observational unit. {cmd:apr} and {cmd:lpr} provide causal inference on the average persuasion rate (APR) and the local persuasion rate (LPR), respectively.{p_end}

{p 4 4 2}{cmd:yz} is concerned with another data scenario where persuasive treatment _t_ is unobserved. In this case, bounds on the APR are the same as those on the LPR. It provides causal inference for the APR and hence, for the LPR as well.{p_end}  

{p 4 4 2}{cmd:calc} is designed for the case when summary statistics on Pr(y=1|z) and/or Pr(t=1|z) for each z=0,1 are available. It provides the lower and upper bounds on the APR as well as the lower and upper bounds on the LPR.{p_end} 
		
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

All these options are irrelevant for subcommands {cmd:calc}. 

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
		
The first example conducts inference on APR when y,t,z are observed.
		
		. persuasio apr voteddem_all readsome post, level(80) method("normal")
		
The second example conducts inference on LPR when y,t,z are observed.	
		
		. persuasio lpr voteddem_all readsome post, level(80) method("normal")
		
The third example conducts bootstrap inference on APR and LPR when y,z are observed with a covariate, MZwave2, interacting with the instrument, post. 
		
		. persuasio yz voteddem_all post MZwave2, level(80) model("interaction") method("bootstrap") nboot(1000)	

The fourth example considers the case when we have summary statistics on Pr(y=1|z) and/or Pr(t=1|z).
	
We first compute summary statistics.

{p 6} . foreach var in voteddem_all readsome {  {p_end}
{p 10}			foreach treat in 0 1 {          {p_end}
{p 12}				sum `var' if post == `treat'     {p_end}
{p 12}				scalar `var'_`treat' = r(mean)   {p_end}
{p 10}				} {p_end}
{p 8}		  } {p_end}

Then, we calculate the bound estimates on the APR and LPR.

		. persuasio calc voteddem_all_1 voteddem_all_0 readsome_1 readsome_0
			
	
Stored results
--------------

{p 4 4 2}{cmd:apr} calls this package's command {cmd:persuasio4ytz}, {cmd:lpr}  command {cmd:persuasio4ytz2lpr},
{cmd:yz} command {cmd:persuasio4yz}, and {cmd:calc} command {cmd:calc4persuasio}, respectively.
Check help files for these commands for details on stored results.{p_end}

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
capture program drop persuasio
program persuasio, eclass sortpreserve byable(recall)

	version 14.2
	
	syntax anything [if] [in] [, level(cilevel) model(string) method(string) nboot(numlist >0 integer) title(string)]
			
	marksample touse
	
	gettoken sampletype varlist : anything
		
	if "`sampletype'" == "apr" {
			
		persuasio4ytz `varlist' if `touse', level(`level') model("`model'") method("`method'") nboot(`nboot') title("`title'")	
	}
	
	if "`sampletype'" == "lpr" {
			
		persuasio4ytz2lpr `varlist' if `touse', level(`level') model("`model'") method("`method'") nboot(`nboot') title("`title'")	
	}
			
	if "`sampletype'" == "yz" {
			
		persuasio4yz `varlist' if `touse', level(`level') model("`model'") method("`method'") nboot(`nboot') title("`title'")	
	}
	
	if "`sampletype'" == "calc" {
			
		calc4persuasio `varlist'	
	}
		
end

