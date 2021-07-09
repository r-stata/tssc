{smcl}
{* *! version 1.1.0 03Mar2013}{...} 
{* *! version 1.0.0 11Feb2013}{...}
{cmd:help rtmci}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:rtmci} {hline 2}}Regression to the mean effects with confidence intervals {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
        {cmd:rtmci} {it:pre-test} {it:post-test} {ifin} {cmd:,} cutoff [{it:{help rtmci##options:options}}] 

	
{pstd}{it:pre-test} is the pre-test variable, {it:post-test} is the post-test variable, 
and {it:cut-off} is the cutoff value on the pre-test variable.{p_end}


{marker options}{...}
{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{help rtmci##main:Main}}
{synopt:{cmdab:per:iods(}{it:#}{cmd:)}}{...}
	defines the number of periods that the {it:pre-test} variable represents{p_end}
{synopt:{cmdab:fig:ure}}{...}
	 produces a plot of the expected pre- and post-test means and confidence intervals for values 
	 above and below the cutoff {p_end}
	
{syntab:{help rtmci##sim:Bootstrapped CIs}}
{synopt:{cmd:seed(}{it:#}{cmd:)}}{...}
	sets the random-number seed to {it:#}{p_end}
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
{p 4 6 2}
{opt by} is allowed with {cmd:rtmci}; see {manhelp by D}.{p_end}

	
	
{title:Description}

{pstd}
{cmd:rtmci} calculates the regression to the mean effect for a variable that is generally measured 
at two points in time (i.e., "pre-test" and "post-test"), based on a defined cutoff value on the "pre-test" measure, and 
estimates confidence intervals using bootstrap simulation; see {help bootstrap}. If only summary level statistics are 
available (e.g., as published in a journal article), the user may consider using {help rtmcii}, an immediate form of {cmd:rtmci}.{p_end}


{title:Options}

{marker main}{...}
{dlgtab:Main}

{p 4 8 2}
{cmd:periods(}{it:#}{cmd:)} defines the number of periods that the {it:pre-test}
variable represents; default is {cmd:per(1)}.

{p 4 8 2}
{opt figure} produces a plot of the expected pre- and post-test means and confidence intervals for values 
	 above and below the cutoff. This option requires Roger Newson's {help xsvmat} and {help eclplot} packages to be 
	 installed; both are downloadable from {help ssc:SSC}


{marker sim}{...}
{dlgtab:Bootstrapped CIs}

{p 4 8 2}
{opt seed(#)} sets the random-number seed to {it:#}. Specifying this option 
is equivalent to typing {cmd:. set seed} {it:#} before calling {cmd:rtmci}; default is {cmd:seed(1234)}.

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
{p 4 6 2}


{title:Remarks} 

{pstd}
Regression to the mean (RTM), originally termed “regression toward mediocrity”, was described over a century ago by Sir Francis Galton (1886)
upon discovering that on average, tall parents had children shorter themselves and short parents had 
taller children. An excellent historical review of RTM is provided by Stigler (1997). 

{pstd}
RTM poses a major threat to the internal validity of any study in which 
subjects are initially selected for their extreme values. Upon remeasurement, the sample mean 
from this outlier group is likely to be much closer to the overall population mean. This 
statistical phenomenon can be easily confused with a treatment effect. 

{pstd}
{cmd:rtmci} calculates the expected pre-test value, post-test value, and estimated RTM effects using
equations proposed by Gardner & Hardy (1973) and Davis (1976) for Normally distributed data. Importantly, {cmd:rtmci} provides 
confidence intervals to indicate the precision (uncertainty) for these estimates. See Linden (2013) for the results of simulation
a more comprehensive discussion.


{title:Examples}

{pstd}

{p 4 8 2}{cmd:. rtmci pretest posttest, cutoff(44.25) period(1) fig}

{p 4 8 2}{cmd:. rtmci pretest posttest, cut(44.25) per(1) reps(2000) seed(4321) size(50)}

{p 4 8 2}{cmd:. estat bootstrap, all}

{p 4 8 2}{cmd:. bys treat: rtmci pretest posttest, cut(44.25) per(1) reps(2000) seed(4321) size(50)}



{marker output_tables}{...}
{title:Output tables}

{pstd}
{cmd:rtmci} produces standard bootstrap output tables. Below is a cross reference to the variables in the tables:

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
Linden A. Assessing regression to the mean effects in health care initiatives. {it:BMC Medical Research Methodology} 2013;13(119):1-7.{p_end}

{p 4 8 2}
Stigler SM. Regression towards the mean, historically considered. {it:Statistical Methods in Medical Research} 1997;6(2):103-14.{p_end}



{marker citation}{title:Citation of {cmd:rtmci}}

{p 4 8 2}{cmd:rtmci} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel (2013). rtmci: Stata module for estimating regression to the mean effects with confidence intervals.
{browse "http://www.lindenconsulting.org":http://www.lindenconsulting.org}
{p_end}



{title:Author}

{p 4 8 2}	Ariel Linden{p_end}
{p 4 8 2}	President, Linden Consulting Group, LLC{p_end}
{p 4 8 2}	Ann Arbor, MI, USA{p_end}
{p 4 8 2}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
{p 4 8 2}{browse "http://www.lindenconsulting.org"}{p_end}

         
{title:Acknowledgments} 

{p 4 4 2} I would like to thank Nicholas J. Cox for his never-ending support and patience with me while 
developing both {cmd:rtmci} and its immediate form; {cmd:rtmcii}. He knows Stata better than Stata knows Stata.
I would also like to thank Roger Newson for his guidance in creating the figure option using his {help xsvmat} 
and {help eclplot} programs.


{title:Also see}

{p 4 8 2} Manual: {bf:[R] bootstrap}, {bf:[D] by} {p_end}

{p 4 8 2} Online:  {helpb bootstrap}, {helpb by}, {helpb xsvmat} (if installed), {helpb eclplot} (if installed) {p_end}

