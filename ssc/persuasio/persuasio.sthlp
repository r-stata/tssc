{smcl}

{p 4 4 2}
{it:version 0.1.0} 



{title:Title}

{phang}{cmd:persuasio} {hline 2} Conduct causal inference on persuasive effects 


{title:Syntax}

{p 8 8 2} {cmd:persuasio} {it:subcommand} {it:varlist} [{it:if}] [{it:in}] [, {cmd:level}(#) {cmd:model}({it:string}) {cmd:method}({it:string}) {cmd:nboot}(#) {cmd:title}({it:string})]

{p 4 4 2}{bf:Options}

{col 5}{it:Option}{col 24}{it:Description}
{space 4}{hline 44}
{col 5}{cmd:level}(#){col 24}Set confidence level; default is {cmd:level}(95)
{col 5}{cmd:model}({it:string}){col 24}Regression model when {it:covariates} are present
{col 5}{cmd:method}({it:string}){col 24}Inference method; default is {cmd:method}("normal")
{col 5}{cmd:nboot}(#){col 24}Perform # bootstrap replications
{col 5}{cmd:title}({it:string}){col 24}Title
{space 4}{hline 44}

{title:Description}

{p 0 0 2}{cmd:persuasio} conducts causal inference on persuasive effects. It is a wrapper that calls a variety of subroutines. {it:subcommand} has several options:{p_end}

{col 5}{it:Subcommand}{col 19}{it:Description}
{space 4}{hline 70}
{col 5}{cmd:apr}{col 19}inference on APR when y,t,z are observed
{col 5}{cmd:lpr}{col 19}inference on LPR when y,t,z are observed
{col 5}{cmd:yz}{col 19}inference on APR and LPR when y,z are observed
{col 5}{cmd:calc}{col 19}bound estimates on APR and LPR with summary statistics
{space 4}{hline 70}
{p 4 4 2}{cmd:apr} and {cmd:lpr} refer to a data scenario where binary outcomes {it:y}, binary treatments {it:t}, and binary instruments {it:z} are observed (with covariates {it:x} if exist) for each observational unit. {cmd:apr} and {cmd:lpr} provide causal inference on the average persuasion rate (APR) and the local persuasion rate (LPR), respectively.{p_end}

{p 4 4 2}{cmd:yz} is concerned with another data scenario where persuasive treatment {it:t} is unobserved. In this case, bounds on the APR are the same as those on the LPR. It provides causal inference for the APR and hence, for the LPR as well.{p_end}    {break}

{p 4 4 2}{cmd:calc} is designed for the case when summary statistics on Pr(y=1|z) and/or Pr(t=1|z) for each z=0,1 are available. It provides the lower and upper bounds on the APR as well as the lower and upper bounds on the LPR.{p_end} 
		

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
By the nature of identification, one-sided confidence intervals are produced. 

{p 4 8 2}1. When {it:x} is present, it needs to be set as {cmd:method}("bootstrap"); 
otherwise, the confidence interval will be missing.
	
{p 4 8 2}2. When {it:x} is absent, both options yield non-missing confidence intervals.
	
{cmd:nboot}(#) chooses the number of bootstrap replications.

{p 4 4 2}
The default option is {cmd:nboot}(50).
It is only relevant when {cmd:method}("bootstrap") is selected.

{cmd:title}({it:string}) specifies a title.

{p 4 4 2}
All these options are irrelevant for subcommands {cmd:calc}. 


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
The first example conducts inference on APR when y,t,z are observed.
		
{p 4 4 2}
		. persuasio apr voteddem_all readsome post, level(80) method("normal")
		
{p 4 4 2}
The second example conducts inference on LPR when y,t,z are observed.	
		
{p 4 4 2}
		. persuasio lpr voteddem_all readsome post, level(80) method("normal")
		
{p 4 4 2}
The third example conducts bootstrap inference on APR and LPR when y,z are observed with a covariate, MZwave2, interacting with the instrument, post. 
		
{p 4 4 2}
		. persuasio yz voteddem_all post MZwave2, level(80) model("interaction") method("bootstrap") nboot(1000)	

{p 4 4 2}
The fourth example considers the case when we have summary statistics on Pr(y=1|z) and/or Pr(t=1|z).
	
{p 4 4 2}
We first compute summary statistics.

{p 6} . foreach var in voteddem_all readsome {  {p_end}
{p 10}			foreach treat in 0 1 {          {p_end}
{p 12}				sum {c 96}var{c 39} if post == {c 96}treat{c 39}     {p_end}
{p 12}				scalar {c 96}var{c 39}_treat{c 39} = r(mean)   {p_end}
{p 10}				} {p_end}
{p 8}		  } {p_end}

{p 4 4 2}
Then, we calculate the bound estimates on the APR and LPR.

{p 4 4 2}
		. persuasio calc voteddem_all_1 voteddem_all_0 readsome_1 readsome_0
			
	

{title:Stored results}

{p 4 4 2}{cmd:apr} calls this package{c 39}s command {cmd:persuasio4ytz}, {cmd:lpr}  command {cmd:persuasio4ytz2lpr},
{cmd:yz} command {cmd:persuasio4yz}, and {cmd:calc} command {cmd:calc4persuasio}, respectively.
Check help files for these commands for details on stored results.{p_end}


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



