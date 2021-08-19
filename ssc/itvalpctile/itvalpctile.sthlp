{smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:itvalpctile} {hline 2} Executes estimation of interval-valued percentiles (quantiles) for interval-valued data.


{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:itvalpctile}
{it:lower}
{it:upper}
{ifin}
[{cmd:,} {bf:cover}({it:real}) {bf:pl}({it:real}) {bf:ph}({it:real}) {bf:np}({it:real}) {bf:conditional}({it:varname}) {bf:location}({it:real})]


{marker description}{...}
{title:Description}

{phang}
{cmd:itvalpctile} executes estimation of percentiles (quantiles) for interval-valued data based on 
Beresteanu and Sasaki (2020). 
It applies to interval-valued survey and questionnaire responses.
The command takes the lower bound ({it:lower}) and the upper bound ({it:upper}) of the intervals.
It returns interval-valued percentiles (and their valid confidence sets if {it:lower} and {it:upper} are continuous).
The command can also compute conditional interval-valued percentiles and their confidence sets by calling the option {it:conditional}.


{marker options}{...}
{title:Options}

{phang}
{bf:cover({it:real})} sets the nominal probability that the confidence sets cover the true percentiles. The default value is {bf: cover(.95)}.

{phang}
{bf:pl({it:real})} sets the lowest percent at which the interval-valued percentile is reported. The default value is {bf: pl(10)}.

{phang}
{bf:ph({it:real})} sets the highest percent at which the interval-valued percentile is reported. The default value is {bf: ph(90)}.

{phang}
{bf:np({it:real})} sets the number of percent points at which the interval-valued percentile is reported. The default value is {bf: np(9)}.

{phang}
{bf:conditional({it:varname})} sets a conditioning variables with which the conditional interval-valued percentiles are estimated. Not calling this option tells the command to estimate the unconditional interval-valued percentiles.

{phang}
{bf:location({it:real})} sets the location of the conditioning variable at which the conditional interval-valued percentiles are estimated. Not calling this option results in using the mean value of the conditioning variable as the location.


{marker examples}{...}
{title:Examples}

{phang}
({bf:ylower} lower bound, {bf:yupper} upper bound, {bf:x} conditioning variable)

{phang}Estimation of interval-valued percentiles at the percent points 10, 20, 30, 40, 50, 60, 70, 80 and 90:

{phang}{cmd:. itvalpctile ylower yupper}{p_end}

{phang}Estimation of interval-valued percentiles at the percent points 25, 30, 35, 40, 45, 50, 55, 60, 65, 70 and 75:

{phang}{cmd:. itvalpctile ylower yupper, pl(25) ph(75) np(11)}{p_end}

{phang}Estimation of interval-valued percentiles with 90% confidence sets:

{phang}{cmd:. itvalpctile ylower yupper, cover(0.90)}{p_end}

{phang}Estimation of conditional interval-valued percentiles given {bf:x}=0 for a "{it:continuous}" variable {bf:x}:

{phang}{cmd:. itvalpctile lower upper, conditional(x) location(0)}{p_end}

{phang}Estimation of conditional interval-valued percentiles given {bf:x}=0 for a "{it:discrete}" variable {bf:x}:

{phang}{cmd:. itvalpctile lower upper if x == 0}{p_end}


{title:Reference}

{p 4 8}Beresteanu, A. and Y. Sasaki. 2020. Quantile Regression with Interval Data.
{it:Econometric Reviews, Special Issue in Honor of Cheng Hsiao}, forthcoming.
{p_end}

{title:Authors}

{p 4 8}Arie Beresteanu, University of Pittsburgh, Pittsburgh, PA.{p_end}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}



