{smcl}


{title:Title}

{phang}{cmd:lpr4ytz} {hline 2} Estimate the local persuasion rate


{title:Syntax}

{p 8 8 2} {cmd:lpr4ytz} {it:depvar} {it:treatrvar} {it:instrvar} [{it:covariates}] [{it:if}] [{it:in}] [, {cmd:model}({it:string}) {cmd:title}({it:string})]

{p 4 4 2}{bf:Options}

{col 5}{it:option}{col 24}{it:Description}
{space 4}{hline 44}
{col 5}{cmd:model}({it:string}){col 24}Regression model when {it:covariates} are present
{col 5}{cmd:title}({it:string}){col 24}Title
{space 4}{hline 44}


{title:Description}

{p 4 4 2}
{bf:lpr4ytz} estimates the local persuasion rate (LPR).
{it:varlist} should include {it:depvar} {it:treatrvar} {it:instrvar} {it:covariates} in order.
Here, {it:depvar} is binary outcomes ({it:y}), {it:treatrvar} is binary treatments ({it:t}), 
{it:instrvar} is binary instruments ({it:z}), and {it:covariates} ({it:x}) are optional. 

{p 4 4 2}
There are two cases: (i) {it:covariates} are absent and (ii) {it:covariates} are present.

{break}    - Without {it:x}, the LPR is defined by 

	{cmd:LPR} = {Pr({it:y}=1|{it:z}=1)-Pr({it:y}=1|{it:z}=0)}/{Pr[{it:y}=0,{it:t}=0|{it:z}=0]-Pr[{it:y}=0,{it:t}=0|{it:z}=1]}.
	
{p 4 4 2}
	The estimate and its standard error are obtained by the following procedure:
	
{break}    1. The numerator of the LPR is estimated by regressing {it:y} on {it:z}.
{break}    2. The denominator is estimated by regressing (1-{it:y})*(1-{it:t}) on {it:z}.
{break}    3. The LPR is obtained as the ratio.
{break}    4. The standard error is computed via STATA command {bf:nlcom}. 

{break}    - With {it:x}, the LPR is defined by 

	{cmd:LPR} = E[{cmd:LPR}({it:x}){e(1|x) - e(0|x)}]/E[e(1|x) - e(0|x)]
	
{p 4 4 2}
	where

{p 4 8 2}	{cmd:LPR}({it:x}) = {Pr({it:y}=1|{it:z}=1,{it:x}) - Pr({it:y}=1|{it:z}=0,{it:x})}/{Pr[{it:y}=0,{it:t}=0|{it:z}=0,{it:x}] - Pr[{it:y}=0,{it:t}=0|{it:z}=1,{it:x}]},
	
{p 4 4 2}
	e(1|x) = Pr({it:t}=1|{it:z}=1,{it:x}), and e(0|x) = Pr({it:t}=1|{it:z}=0,{it:x}).
	
{p 4 4 2}
The estimate is obtained by the following procedure.
	
{p 4 4 2}
If {cmd:model}("no_interaction") is selected (default choice),
	
{break}    1. The numerator of the LPR is estimated by regressing {it:y} on {it:z} and {it:x}.
{break}    2. The denominator is estimated by regressing (1-{it:y})*(1-{it:t}) on {it:z} and {it:x}.
{break}    3. The LPR is obtained as the ratio.
{break}    4. The standard error is computed via STATA command {bf:nlcom}. 	
	
{p 4 4 2}
Note that in this case, {cmd:LPR}({it:x}) does not depend on {it:x}, because of the linear regression model specification.
	
{p 4 4 2}
Alternatively, if {cmd:model}("interaction") is selected,
	
{p 4 8 2} 1. Pr({it:y}=1|{it:z},{it:x}) is estimated by regressing {it:y} on {it:x} given {it:z} = 0,1.

{p 4 8 2} 2. Pr[{it:y}=0,{it:t}=0|{it:z},{it:x}] is estimated by regressing (1-{it:y})*(1-{it:t}) on {it:x} given {it:z} = 0,1.

{p 4 8 2} 3. Pr({it:t}=1|{it:z},{it:x}) is estimated by regressing {it:t} on {it:x} given {it:z} = 0,1.

{p 4 8 2} 4. For each {it:x} in the estimation sample, both {cmd:LPR}({it:x}) and {e(1|x)-e(0|x)} are evaluated.

{p 4 8 2} 5. Then, the sample analog of {cmd:LPR} is constructed.
	
{p 4 4 2}
	When {it:covariates} are present, the standard error is missing because an analytic formula for the standard error is complex.
	Bootstrap inference is implemented when this package{c 39}s command {bf:persuasio} is called to conduct inference. 
	

{title:Options}

{cmd:model}({it:string}) specifies a regression model.

{p 4 4 2}
This option is only relevant when {it:x} is present.
The default option is "no_interaction" between {it:z} and {it:x}. 
When "interaction" is selected, full interactions between {it:z} and {it:x} are allowed.

{cmd:title}({it:string}) specifies a title.


{title:Remarks}

{p 4 4 2}
It is recommended to use this package{c 39}s command {bf:persuasio} instead of calling {bf:lpr4ytz} directly.


{title:Examples }

{p 4 4 2}
We first call the dataset included in the package.

{p 4 4 2}
		. use GKB, clear

{p 4 4 2}
The first example estimates the LPR without covariates.
		
{p 4 4 2}
		. lpr4ytz voteddem_all readsome post

{p 4 4 2}
The second example adds a covariate.

{p 4 4 2}
		. lpr4ytz voteddem_all readsome post MZwave2
		
{p 4 4 2}
The third example allows for interactions between {it:x} and {it:z}.

{p 4 4 2}
		. lpr4ytz voteddem_all readsome post MZwave2, model("interaction")		


{title:Stored results}

{p 4 4 2}{bf:Scalars}

{p 8 8 2} {bf:e(N)}: sample size

{p 8 8 2} {bf:e(lpr_coef)}: estimate of the local persuasion rate

{p 8 8 2} {bf:e(lpr_se)}: standard error of the estimate of the local persuasion rate

{p 4 4 2}{bf:Macros}

{p 8 8 2} {bf:e(outcome)}: variable name of the binary outcome variable

{p 8 8 2} {bf:e(treatment)}: variable name of the binary treatment variable 

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



