{smcl}
{cmd:help cisd}
{hline}

{title:Title}
{phang}

{bf:cisd} {hline 2} Postestimation command to {bf:regress} and {bf:anova}: Confidence interval for SD(error)

{title:Syntax}

{p 8 17 2}
{bf:cisd} [, level(#)]

{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}

{title:Description}

In the {bf:regress} and {bf:anova} output, {bf:Root MSE} is the standard deviation (SD)
of the error term, but the uncertainty of this estimate is not shown.
{bf:cisd} displays the confidence interval for the SD(error) estimate. 

The 95% confidence limits for the SD estimate are functions of SD and DF 
(degrees of freedom):
	Lower limit: SD*sqrt(DF/invchi2(DF,0.975))
	Upper limit: SD*sqrt(DF/invchi2(DF,0.025))


{title:Examples}

	{inp:. sysuse auto}
	{inp:. regress mpg weight}
	{inp:. cisd}
	{inp:. cisd, level(90)}

{title:Authors}

Morten Frydenberg and Svend Juul
Department of Public Health, Aarhus University, Denmark
Email: {browse "mailto:morten@biostat.au.dk":morten@biostat.au.dk}



