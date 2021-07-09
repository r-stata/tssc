{smcl}
{cmd:help cisd1}
{hline}

{title:Title}
{phang}

{bf:cisd1} {hline 2} Estimation of the standard deviation with confidence interval of a sample from a normal distribution.

{title:Syntax}

{p 8 17 2}
{bf:cisd1} {it:varname} [if] [in] [, level(#) zero]

{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt z:ero}}assuming mean zero; default is not assumed{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}

{title:Description}

A confidence interval for the standard deviation is calculated based
on the assumption of normally distributed data.

If zero mean is assumed by option {bf:zero}, the command also reports
sd/sqrt(2). This is the standard deviation of a single measurement if
{it:varname} is the difference between two identical measurements.


The 95% confidence limits for an SD estimate are functions of SD
and DF (degrees of freedom):
	Lower limit: SD*sqrt(DF/invchi2(DF,0.975)
	Upper limit: SD*sqrt(DF/invchi2(DF,0.025)


{title:Examples}

	{inp:. cisd1 sbp}

	{inp:. generate dif = sbp1-sbp2}
	{inp:. cisd1 dif, zero}
	{inp:. cisd1 dif, level(90)}

{title:Authors}

Morten Frydenberg and Svend Juul
Department of Public Health, Aarhus University, Denmark
Email: {browse "mailto:morten@biostat.au.dk":morten@biostat.au.dk}



