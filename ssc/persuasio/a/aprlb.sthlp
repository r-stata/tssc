{smcl}


{title:Title}

{phang}{cmd:aprlb} {hline 2} Estimate the lower bound on the average persuasion rate


{title:Syntax}

{p 8 8 2} {cmd:aprlb} {it:depvar} {it:instrvar} [{it:covariates}] [{it:if}] [{it:in}] [, {cmd:model}({it:string}) {cmd:title}({it:string})]

{p 4 4 2}{bf:Options}

{col 5}{it:option}{col 24}{it:Description}
{space 4}{hline 44}
{col 5}{cmd:model}({it:string}){col 24}Regression model when {it:covariates} are present
{col 5}{cmd:title}({it:string}){col 24}Title
{space 4}{hline 44}


{title:Description}

{p 4 4 2}
{bf:aprlb} estimates the lower bound on the average persuasion rate (APR).
{it:varlist} should include {it:depvar} {it:instrvar} {it:covariates} in order.
Here, {it:depvar} is binary outcomes ({it:y}), {it:instrvar} is binary instruments ({it:z}), 
and {it:covariates} ({it:x}) are optional. 

{p 4 4 2}
There are two cases: (i) {it:covariates} are absent and (ii) {it:covariates} are present.

{break}    - Without {it:x}, the lower bound ({cmd:theta_L}) on the APR is defined by 

	{cmd:theta_L} = {Pr({it:y}=1|{it:z}=1) - Pr({it:y}=1|{it:z}=0)}/{1 - Pr({it:y}=1|{it:z}=0)}.

{p 4 4 2}
	The estimate and its standard error are obtained by the following procedure:
	
{break}    1. Pr({it:y}=1|{it:z}=1) and Pr({it:y}=1|{it:z}=0) are estimated by regressing {it:y} on {it:z}.
{break}    2. {cmd:theta_L} is computed using the estimates obtained above.
{break}    3. The standard error is computed via STATA command {bf:nlcom}. 

{break}    - With {it:x}, the lower bound ({cmd:theta_L}) on the APR is defined by 

	{cmd:theta_L} = E[{cmd:theta_L}({it:x})],
	
{p 4 4 2}
	where

	{cmd:theta_L}({it:x}) = {Pr({it:y}=1|{it:z}=1,{it:x}) - Pr({it:y}=1|{it:z}=0,{it:x})}/{1 - Pr({it:y}=1|{it:z}=0,{it:x})}.
	
{p 4 4 2}
The estimate is obtained by the following procedure.
	
{p 4 4 2}
If {cmd:model}("no_interaction") is selected (default choice),
	
{break}    1. Pr({it:y}=1|{it:z},{it:x}) is estimated by regressing {it:y} on {it:z} and {it:x}.
	
{p 4 4 2}
Alternatively, if {cmd:model}("interaction") is selected,
	
{break}    1a. Pr({it:y}=1|{it:z}=1,{it:x}) is estimated by regressing {it:y} on {it:x} given {it:z} = 1.
{break}    1b. Pr({it:y}=1|{it:z}=0,{it:x}) is estimated by regressing {it:y} on {it:x} given {it:z} = 0.
	
{p 4 4 2}
Ater step 1, both options are followed by:
	
{break}    2. For each {it:x} in the estimation sample, {cmd:theta_L}({it:x}) is evaluated.
{break}    3. The estimates of {cmd:theta_L}({it:x}) are averaged to estimate {cmd:theta_L}.
	
{p 4 4 2}
	When {it:covariates} are present, the standard error is missing because an analytic formula for the standard error is complex.
	Bootstrap inference is implemented when this package{c 39}s command {bf:persuasio} is called to conduct inference. 
	

{title:Options}

{cmd:model}({it:string}) specifies a regression model of {it:y} on {it:z} and {it:x}. 

{p 4 4 2}
This option is only relevant when {it:x} is present.
The default option is "no_interaction" between {it:z} and {it:x}. 
When "interaction" is selected, full interactions between {it:z} and {it:x} are allowed; 
this is accomplished by estimating Pr({it:y}=1|{it:z}=1,{it:x}) and Pr({it:y}=1|{it:z}=0,{it:x}), separately.

{cmd:title}({it:string}) specifies a title.


{title:Remarks}

{p 4 4 2}
It is recommended to use this package{c 39}s command {bf:persuasio} instead of calling {bf:aprlb} directly.


{title:Examples}

{p 4 4 2}
We first call the dataset included in the package.

{p 4 4 2}
		. use GKB, clear

{p 4 4 2}
The first example estimates the lower bound on the APR without covariates.
		
{p 4 4 2}
		. aprlb voteddem_all post

{p 4 4 2}
The second example adds a covariate.

{p 4 4 2}
		. aprlb voteddem_all post MZwave2
		
{p 4 4 2}
The third example estimates the lower bound by the covariate.		
		
        . by MZwave2, sort: aprlb voteddem_all post		


{title:Stored results}

{p 4 4 2}{bf:Scalars}

{p 8 8 2} {bf:e(N)}: sample size

{p 8 8 2} {bf:e(lb_coef)}: estimate of the lower bound on the average persuasion rate

{p 8 8 2} {bf:e(lb_se)}: standard error of the lower bound on the average persuasion rate


{p 4 4 2}{bf:Macros}

{p 8 8 2} {bf:e(outcome)}: variable name of the binary outcome variable

{p 8 8 2} {bf:e(instrument)}: variable name of the binary instrumental variable 

{p 8 8 2} {bf:e(covariates)}: variable name(s) of the covariates if they exist

{p 8 8 2} {bf:e(model)}: regression model specification ("no_interaction" or "interaction")

{p 4 4 2}{bf:Functions:}

{p 8 8 2} {bf:e(sample)}: 1 if the observations are used for estimation, and 0 otherwise. 



{title:Authors}

{p 4 4 2}
Sung Jae Jun, Penn State University, <sjun@psu.edu> 

{p 4 4 2}
Sokbae Lee, Columbia University, <sl3841@columbia.edu>


{title:License}

{p 4 4 2}
GPL-3


{title:References}

{p 4 4 2}
Sung Jae Jun and Sokbae Lee (2019), 
Identifying the Effect of Persuasion, 
{browse "https://arxiv.org/abs/1812.02276":arXiv:1812.02276 [econ.EM]} 


{title:Version}

{p 4 4 2}
0.1.0 30 January 2021



