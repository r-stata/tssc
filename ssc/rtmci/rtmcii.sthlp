{smcl}
{* *! version 1.1.0 03Mar2013}{...} 
{* *! version 1.0.0 31Jan2013}{...}
{cmd:help rtmcii}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:rtmcii} {hline 2}}Regression to the mean effects with confidence intervals {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
	{cmd:rtmcii} {it:mean_pre sd_pre cut-off rho} [{cmd:,} {it:{help rtmcii##options:options}}]

{pstd}{it:mean_pre} is the mean of pre-test variable, {it:sd_pre}
is the standard deviation of the pre-test variable, {it:cut-off} is the cutoff value on the pre-test variable, 
and {it:rho} is the correlation between the pre- and post-test variables.{p_end}
 	

{marker options}{...}
{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{help rtmcii##main:Main}}
{synopt:{cmdab:per:iods(}{it:#}{cmd:)}}{...}
	defines the number of periods used for calculating the pre-test mean and standard deviation {it:mean_pre} and {it:sd_pre} {p_end}
{synopt:{cmdab:n:umber(}{it:#}{cmd:)}}{...}
	defines the number of observations to be used in generating the artifical dataset {p_end}
{synopt:{cmd:seed(}{it:#}{cmd:)}}{...}
	sets the random-number seed to {it:#}, which will be used for both generating the artificial dataset 
	and for estimating bootstrapped confidence intervals {p_end}
{synopt:{cmdab:fig:ure}}{...}
	 produces a plot of the expected pre- and post-test means and confidence intervals for values 
	 above and below the cutoff {p_end}
	
{syntab:{help rtmcii##sim:Bootstrapped CIs}}
{synopt:{cmd:reps(}{it:#}{cmd:)}}{...}
	specifies the number of replications to be performed {p_end}
{synopt :{opt si:ze(#)}}{...}
	draws samples of size {it:#}{p_end}
{synopt :{opt lev:el(#)}}{...}
	sets the confidence level; default is {cmd:level(95)}{p_end}
{synopt :{help prefix_saving_option:{bf:saving(}{it:filename}{bf:, ...)}}}
	saves results to {it:filename}{p_end}	
{synoptline}
{p2colreset}{...}
	
{title:Description}

{pstd}
{cmd:rtmcii} calculates the regression to the mean effect for a variable that is generally measured 
at two points in time (ie, "pre-test" and "post-test"), based on a defined cutoff value on the "pre-test" measure, and 
estimates confidence intervals using bootstrap simulation; see {help bootstrap}. {cmd:rtmcii} is an immediate form of {help rtmci}; see {help immed} 
for more on immediate commands. {p_end}


{title:Options}

{marker main}{...}
{dlgtab:Main}

{p 4 8 2}
{cmd:periods(}{it:#}{cmd:)} defines the number of periods used for calculating 
the pre-test {it:mean_pre} and {it:sd_pre}; default is {cmd:per(1)}.

{p 4 8 2}
{cmd:number(}{it:#}{cmd:)} defines the number of observations to be used 
in generating the artificial dataset; default is {cmd:n(1000)}.

{p 4 8 2}
{opt seed(#)} sets the random-number seed to {it:#}, which will be used for both 
generating the artifical dataset and for estimating bootstrapped confidence intervals. Specifying 
this option is equivalent to typing {cmd:. set seed} {it:#} before calling {cmd:rtmcii}; default is {cmd:seed(1234)}.

{p 4 8 2}
{opt figure} produces a plot of the expected pre- and post-test means and confidence intervals for values 
	 above and below the cutoff. This option requires Roger Newson's {help xsvmat} and {help eclplot} packages to be 
	 installed; both are downloadable from {help ssc:SSC}

{marker sim}{...}
{dlgtab:Bootstrapped CIs}

{p 4 8 2}
{opt reps(#)} specifies the number of replications to be performed; default
is {cmd:reps(1000)}.
	
{p 4 8 2}
{opt size(#)} sets the number of observations drawn at each replication; default is {help _N}.

{p 4 8 2}
{opt level(#)} specifies the confidence level, as a percentage, for confidence
   intervals. The default is {cmd:level(95)} or as set by {helpb set level}.

{p 4 8 2}
{help prefix_saving_option:{bf:saving(}{it:filename}{bf:, ...)}}
saves the bootstrapped results of the simulations to {it:filename}. See
{it:{help prefix_saving_option}} for details about {it:suboptions}.

{synoptline}
{p2colreset}{...}

{title:Remarks} 

{pstd}
Regression to the mean (RTM), originally termed “regression toward mediocrity”, was described over a century ago by Sir Francis Galton (1886)
upon discovering that on average, tall parents had children shorter themselves and short parents had 
taller children. An excellent historical review of RTM is provided by Stigler (1997). 

{pstd}
RTM poses a major threat to the internal validity of any study in which 
subjects are initially selected for their extreme values. Upon remeasurement, the sample mean 
from this outlier group is likely to be much closer to the overall population mean. This 
statistical phenomenon can be easily confused with a treatment effect in intervention studies. 

{pstd}
{cmd:rtmcii} calculates the expected pre-test value, post-test value, and estimated RTM effects using
equations proposed by Gardner & Hardy (1973) and Davis (1976) for Normally distributed data. Importantly, {cmd:rtmcii} provides 
confidence intervals to indicate the precision (uncertainty) for these estimates. 

{pstd}
{cmd:rtmcii} uses the summary statistics provided by the user to create artificial "pre-test" and "post-test" variables using {cmd:corr2data}. These 
artificial variables then serve as the basis for estimating the bootstrapped confidence intervals. Thus, {cmd:rtmcii}  
can calculate all the RTM related measures and estimate confidence intervals when all that is known are summary statistics. See Linden (2013)
for the results of simulation a more comprehensive discussion.


   

{title:Examples}

{pstd}
Example 1: Taken from Yudkin and Stratton (1996) where the mean value of the single pre-test variable is 5.21, the standard deviation is 1.02, 
the cutoff value is 6.50 and the correlation between the pre- and post-tests is 0.67. We set the observations for generating the artificial dataset 
at 1914 to replicate their sample size. Finally, we produce a figure of the expected values.{p_end}

{phang}{stata "rtmcii 5.21 1.02 6.50 0.67, period(1) n(1914) fig": . rtmcii 5.21 1.02 6.50 0.67, period(1) n(1914) fig}

{pstd}
Example 2: Taken from Davis (1976) where the mean value of the single pre-test variable is 5.331, the standard deviation is 0.17, 
the cutoff value is 5.580 and the correlation between the pre- and post-tests is 0.82. We set the observations for generating the artificial dataset 
at 1346 to replicate the sample size in the paper. We also set the number of bootstrap repetitions to 2000 with sample draws of 50.{p_end}

{phang}{stata "rtmcii 5.331 0.17 5.580 0.82, n(1346) reps(2000) seed(4321) size(50)": . rtmcii 5.331 0.17 5.580 0.82, n(1346) reps(2000) seed(4321) size(50)}

{pstd}
Example 3: Taken from Linden (2007, data for Figure 2) where the mean value of the single pre-test variable is 53.12, the standard deviation is 8.27, 
the cutoff value is 44.25 and the correlation between the pre- and post-tests is 0.742. We set the observations for generating the artificial dataset 
at 118 to replicate the sample size in the paper. We follow this with {cmd:estat bootstrap} to display all available confidence intervals.{p_end}

{phang}{stata "rtmcii 53.12 8.27 44.25 0.742, n(118)": . rtmcii 53.12 8.27 44.25 0.742, n(118)}

{phang}{stata "estat bootstrap, all": . estat bootstrap, all}

{marker output_tables}{...}
{title:Output tables}

{pstd}
{cmd:rtmcii} produces standard bootstrap output tables. Below is a cross reference to the variables in the tables:

{synoptset 20 tabbed}{...}
{p2col 5 25 19 2:}{p_end}
{synopt:{cmd:Variable}}{cmd:Description}{p_end}

{synopt:{cmd:mu}}pre-test mean{p_end}
{synopt:{cmd:sd}}pre-test sd{p_end}
{synopt:{cmd:rho}}correlation between pre-test and post-test{p_end}
{synopt:{cmd:firstval_high}}expected pre-test value above the cutoff{p_end}
{synopt:{cmd:secondval_high}}expected post-test value above the cutoff{p_end}
{synopt:{cmd:rtm_high}}RTM effect above the cutoff{p_end}
{synopt:{cmd:pct_rtm_high}}percent RTM effect above the cutoff{p_end}
{synopt:{cmd:firstval_low}}expected pre-test value below the cutoff{p_end}
{synopt:{cmd:secondval_low}}expected post-test value below the cutoff{p_end}
{synopt:{cmd:rtm_low}}RTM effect below the cutoff{p_end}
{synopt:{cmd:pct_rtm_low}}percent RTM effect below the cutoff{p_end}
{p2colreset}{...}


{title:References}

{p 4 8 2}
Davis CE. The effect of regression to the mean in epidemiologic and clinical studies. {it:American Journal of Epidemioliology} 1976;104:493-498.{p_end}

{p 4 8 2}
Galton F. Regression towards mediocrity in hereditary stature. {it:Journal of the Anthropological Institute} 1886;15:246-263.{p_end}

{p 4 8 2}
Gardner MJ, Hardy JA. Some effects of within person variability in epidemiological studies. {it:Journal of Chronic Disease} 1973;26:781-795.{p_end}

{p 4 8 2}
Linden A. Estimating the effect of regression to the mean in health management programs. {it:Disease Management & Health Outcomes} 2007;15(1):7-12. {p_end}

{p 4 8 2}
Linden A. Assessing regression to the mean effects in health care initiatives. {it:BMC Medical Research Methodology} 2013;13(119):1-7. {p_end}

{p 4 8 2}
Stigler SM. Regression towards the mean, historically considered. {it:Statistical Methods in Medical Research} 1997;6(2):103-14.{p_end}

{p 4 8 2}
Yudkin PL, Stratton IM. How to deal with regression to the mean in intervention studies. {it:Lancet} 1996;347:241-243. {p_end}


{marker citation}{title:Citation of {cmd:rtmcii}}

{p 4 8 2}{cmd:rtmcii} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel (2013). rtmcii: Stata module for estimating regression to the mean effects with confidence intervals.
{browse "http://www.lindenconsulting.org":http://www.lindenconsulting.org}
{p_end}



{title:Author}

{p 4 8 2}	Ariel Linden{p_end}
{p 4 8 2}	President, Linden Consulting Group, LLC{p_end}
{p 4 8 2}	Ann Arbor, MI, USA{p_end}
{p 4 8 2}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
{p 4 8 2}{browse "http://www.lindenconsulting.org"}{p_end}

         
{title:Acknowledgments} 

{p 4 4 2} I would like to thank Nicholas J. Cox for providing extremely helpful
comments. Without his help, {cmd:rtmcii} would provide nothing more than point estimates. I would also like to thank
Roger Newson for his guidance in creating the figure option using his {help xsvmat} and {help eclplot} programs.


{title:Also see}

{p 4 8 2} Manual: {bf:[D] corr2data}, {bf:[R] bootstrap}{p_end}

{p 4 8 2} Online:  {helpb corr2data}, {helpb bootstrap}, {helpb xsvmat} (if installed), {helpb eclplot} (if installed)  {p_end}

