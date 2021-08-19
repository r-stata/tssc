{smcl}


{title:Title}

{phang}{cmd:persuasio4ytz2lpr} {hline 2} Conduct causal inference on the local persuasion rate 
for binary outcomes {it:y}, binary treatments {it:t} and binary instruments {it:z}


{title:Syntax}

{p 8 8 2} {cmd:persuasio4ytz2lpr} {it:depvar} {it:treatvar} {it:instrvar} [{it:covariates}] [{it:if}] [{it:in}] [, {cmd:level}(#) {cmd:model}({it:string}) {cmd:method}({it:string}) {cmd:nboot}(#) {cmd:title}({it:string})]

{p 4 4 2}{bf:Options}

{col 5}{it:option}{col 24}{it:Description}
{space 4}{hline 44}
{col 5}{cmd:level}(#){col 24}Set confidence level; default is {cmd:level}(95)
{col 5}{cmd:model}({it:string}){col 24}Regression model when {it:covariates} are present
{col 5}{cmd:method}({it:string}){col 24}Inference method; default is {cmd:method}("normal")
{col 5}{cmd:nboot}(#){col 24}Perform # bootstrap replications
{col 5}{cmd:title}({it:string}){col 24}Title
{space 4}{hline 44}

{title:Description}

{phang}{cmd:persuasio4ytz2lpr} conducts causal inference on causal inference on the local persuasion rate.

{p 4 4 2}
It is assumed that binary outcomes {it:y}, binary treatments {it:t}, and binary instruments {it:z} are observed. 
This command is for the case when persuasive treatment ({it:t}) is observed, 
using estimates of the local persuasion rate (LPR) via 
this package{c 39}s command {cmd:lpr4ytz}.

{p 4 4 2}
{it:varlist} should include {it:depvar} {it:treatvar} {it:instrvar} {it:covariates} in order. 
Here, {it:depvar} is binary outcome ({it:y}), {it:treatvar} is binary treatment,
{it:instrvar} is binary instrument ({it:z}), and {it:covariates} ({it:x}) are optional. 

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
{p 4 8 2}5. Then, a confidence interval for the LPR is obtained via the usual normal approximation.

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
{p 4 8 2}5. Then, a confidence interval for the LPR is obtained via the usual normal approximation.
	
{p 4 4 2}
Note that in this case, {cmd:LPR}({it:x}) does not depend on {it:x} because of the linear regression model specification.
	
{p 4 4 2}
Alternatively, if {cmd:model}("interaction") is selected,
	
{p 4 8 2} 1. Pr({it:y}=1|{it:z},{it:x}) is estimated by regressing {it:y} on {it:x} given {it:z} = 0,1.

{p 4 8 2} 2. Pr[{it:y}=0,{it:t}=0|{it:z},{it:x}] is estimated by regressing (1-{it:y})*(1-{it:t}) on {it:x} given {it:z} = 0,1.

{p 4 8 2} 3. Pr({it:t}=1|{it:z},{it:x}) is estimated by regressing {it:t} on {it:x} given {it:z} = 0,1.

{p 4 8 2} 4. For each {it:x} in the estimation sample, both {cmd:LPR}({it:x}) and {e(1|x)-e(0|x)} are evaluated.

{p 4 8 2} 5. Then, the sample analog of {cmd:LPR} is constructed.

{p 4 8 2} 6. Finally, the bootstrap procedure is implemented via STATA command {cmd:bootstrap}.


{title:Options}

{cmd:model}({it:string}) specifies a regression model of {it:y} on {it:z} and {it:x}. 

{p 4 4 2}
This option is only relevant when {it:x} is present.
The default option is "no_interaction" between {it:z} and {it:x}. 
When "interaction" is selected, full interactions between {it:z} and {it:x} are allowed.

{cmd:level}(#) sets confidence level; default is {cmd:level}(95). 

{cmd:method}({it:string}) refers the method for inference.

{p 4 4 2}
The default option is {cmd:method}("normal").
Since the LPR is point-identified, usual two-sided confidence intervals are produced. 

{p 4 8 2}1. When {cmd:model}("interaction") is chosen as an option, it needs to be set as {cmd:method}("bootstrap"); 
otherwise, the confidence interval will be missing.
		
{cmd:nboot}(#) chooses the number of bootstrap replications.

{p 4 4 2}
The default option is {cmd:nboot}(50).
It is only relevant when {cmd:method}("bootstrap") is selected.

{cmd:title}({it:string}) specifies a title.


{title:Remarks}

{p 4 4 2}
It is recommended to use {cmd:nboot}(#) with # at least 1000. 
A default choice of 50 is meant to check the code initially 
because it may take a long time to run the bootstrap part.
The bootstrap confidence interval is based on percentile bootstrap.
Normality-based bootstrap confidence interval is not recommended 
because bootstrap standard errors can be unreasonably large in applications. 


{title:Examples}

{p 4 4 2}
We first call the dataset included in the package.

{p 4 4 2}
		. use GKB, clear

{p 4 4 2}
The first example conducts inference on the LPR without covariates, using normal approximation.
		
{p 4 4 2}
		. persuasio4ytz2lpr voteddem_all readsome post, level(80) method("normal")
		
{p 4 4 2}
The second example conducts bootstrap inference on the LPR.
		
{p 4 4 2}
		. persuasio4ytz2lpr voteddem_all readsome post, level(80) method("bootstrap") nboot(1000)	
		
{p 4 4 2}
The third example conducts bootstrap inference on the LPR with a covariate, MZwave2, interacting with the instrument, post. 
		
{p 4 4 2}
		. persuasio4ytz2lpr voteddem_all readsome post MZwave2, level(80) model("interaction") method("bootstrap") nboot(1000)			
		

{title:Stored results}

{p 4 4 2}{bf:Matrices}

{p 8 8 2} {bf:e(lpr_est)}: (1*1 matrix) estimate of the local persuasion rate

{p 8 8 2} {bf:e(lpr_ci)}: (1*2 matrix) confidence interval for the local persuasion rate in the form of [lb_ci, ub_ci] 


{p 4 4 2}{bf:Macros}

{p 8 8 2} {bf:e(cilevel)}: confidence level

{p 8 8 2} {bf:e(inference_method)}: inference method: "normal" or "bootstrap" 


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



