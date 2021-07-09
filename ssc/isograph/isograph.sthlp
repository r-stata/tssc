{smcl}
{* *! version 1.1  18Oct2016}{...}
{cmd: help isograph}
{hline}

{title: Title}
{phang}
{bf: isograph -- inequality over logit ranks of social hierarchy}


{marker syntax}{...}
{title:Syntax}
{cmd:isograph} {it:yvar} {ifin} [{it:weight}][{cmd:,}{it:options}]

{title:Description}
{phang}
{cmd:isograph} The Isograph describes inequalities in different income levels, 
thus providing the overall pattern of inequality together with level-specific 
inequalities, serving as Meta-Gini. The formal definition of Isograph is as follows:
ISO_i=(ln((income_i)/median(income)))/(logit(r_i))
Where logit(r) = ln(r/(1-r)) and r_i is element of ]0,1[ and
is the fractional rank order of income quantiles. 
For individual i of income_i, the fractional rank is r_i. The value X_i= logit(r_i), 
the "logit rank", varies from minus to plus infinite, with a value of 0 for the median. 

{title:Options}

{phang}
{opt repeats(n)} Provides bootstrap based confidence intervals (95%) with {it: n} iterations.

{phang}
{opt seed(n)} Sets the seed for the bootstrapping.

{phang}
{opt span(n)} sets the span of the logitrank default is from -3 to 3. The span is always symmetrical.
In case where there are not enough observations in the left of right tail of the distribution, the result
for this tail would be null.



{marker examples}{...}
{title:Examples}

    {hline}
	   
{p} {cmd:use http://www.louischauvel.org/psid9707.dta , clear}

{p} {cmd:isograph} equivalent_income [weight=wgt] {break}{cmd:isograph} equivalent_income [weight=wgt], repeats (10) seed(3739) span(4)
 
{marker references}{...}
{title:References}
   {hline}
Chauvel, L. (2016). The intensity and shape of inequality: the ABG method of distributional analysis. {it:Review of Income and Wealth}, 62(1), 52-68.
{break}
Chauvel, L. an Bar-Haim, E. (2016) Varieties of Capitalism (VoC) and Varieties of Distributions (VoD): How Welfare Regimes Affect the Pre- and {break} Post-Transfer Shapes of Inequalities? {it:LIS working papaer series}, No. 677



{marker Author}{...}
{title:Author}
   {hline}
   Louis Chauvel, PEARL Institute for Research on Socio-Economic Inequality (IRSEI), University of Luxembourg, louis.chauvel@uni.lu  
   Eyal Bar-Haim, PEARL Institute for Research on Socio-Economic Inequality (IRSEI), University of Luxembourg, eyal.bar-haim@uni.lu
   