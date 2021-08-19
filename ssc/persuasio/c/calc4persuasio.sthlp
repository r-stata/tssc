{smcl}


{title:Title}

{phang}{cmd:calc4persuasio} {hline 2} Calculate the effect of persuasion when 
information on Pr(y=1|z) and optimally Pr(t=1|z) for each z=0,1 is available


{title:Syntax}

{p 8 8 2} {cmd:calc4persuasio} {it:y1} {it:y0} {it:e1} {it:e0}


{title:Description}

{p 4 4 2}
{bf:calc4persuasio} calculates the effect of persuasion when 
information on Pr(y=1|z) and optimally Pr(t=1|z) for each z=0,1 is available.
The inputs to this command are {it:y1}, {it:y0}, {it:e1} and {it:e0}. They are all scalars
and refer to the estimates of Pr({it:y}=1|{it:z}=1), Pr({it:y}=1|{it:z}=0),
Pr({it:t}=1|{it:z}=1), and Pr({it:t}=1|{it:z}=0), where ({it:y}, {it:t}, {it:z})
are binary outcomes, binary treatments, and binary instruments, respectively.    {break}

{p 4 4 2}
The outputs of this command are the lower and upper bounds on the average persuasion rate (APR) 
as well as the lower and upper bounds on the local persuasion rate (LPR).     {break}


{p 4 4 2}
There are two cases: (i) all four inputs are given and (ii) only {it:y1} and {it:y0} are given.

{p 4 4 2}
In case (i), {bf:calc4persuasio} provides the following bounds.

{break}    - The lower bound on the APR is defined by 

{p 8 8 2} ({it:y1} - {it:y0})/(1 - {it:y0}).

{break}    - The upper bound on the APR is defined by 

{p 8 8 2} {min(1, {it:y1} + 1 - {it:e1}) - max(0, {it:y0} - {it:e0})}/{1 - max(0, {it:y0} - {it:e0})}.	
	
{break}    - The lower bound on the LPR is defined by 

{p 8 8 2} max{({it:y1} - {it:y0})/(1 - {it:y0}), ({it:y1} - {it:y0})/({it:e1} - {it:e0})}.

{break}    - The upper bound on the LPR is simply 1.

{p 4 4 2}
In case (ii), {bf:calc4persuasio} provides the following bounds.	

{break}    - The lower bound on both the APR and LPR is defined by 

{p 8 8 2} ({it:y1} - {it:y0})/(1 - {it:y0}).
		
{break}    - The upper bound on both the APR and LPR is simply 1.		
		

{title:Remarks}

{p 4 4 2}
The purpose of {bf:calc4persuasio} is to provide bound estimates of both average and local persuasion rates
when summary statistics on Pr(y=1|z) and/or Pr(t=1|z) for each z=0,1 are available.     {break}


{title:Examples }

{p 4 4 2}
We first call the dataset included in the package.

{p 4 4 2}
		. use GKB, clear

{p 4 4 2}
We now compute summary statistics.

{p 6} . foreach var in voteddem_all readsome {  {p_end}
{p 10}			foreach treat in 0 1 {          {p_end}
{p 12}				sum {c 96}var{c 39} if post == {c 96}treat{c 39}     {p_end}
{p 12}				scalar {c 96}var{c 39}_treat{c 39} = r(mean)   {p_end}
{p 10}				} {p_end}
{p 8}		  } {p_end}

{p 4 4 2}
Then, we calculate the bound estimates on the APR and LPR.

{p 4 4 2}
		. calc4persuasio voteddem_all_1 voteddem_all_0 readsome_1 readsome_0
		
{p 4 4 2}
Finally, we compare this with the following.		

{p 4 4 2}
		. calc4persuasio voteddem_all_1 voteddem_all_0


{title:Stored results}

{p 4 4 2}{bf:Scalars}

{p 8 8 2} {bf:r(apr_lb)}: estimate of the lower bound on the average persuasion rate 

{p 8 8 2} {bf:r(apr_ub)}: estimate of the upper bound on the average persuasion rate

{p 8 8 2} {bf:r(lpr_lb)}: estimate of the lower bound on the local persuasion rate 

{p 8 8 2} {bf:r(lpr_ub)}: estimate of the upper bound on the local persuasion rate


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



