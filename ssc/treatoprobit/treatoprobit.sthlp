{smcl}
{* *! version 1.0.0 3mar2014}{...}
{cmd: help treatoprobit}
{right:also see: {help treatoprobit postestimation}}
{hline}

{title:Treatment Effects Ordered Probit}

{phang}
{bf: treatoprobit} {hline 2} Estimate effect of binary treatment on discrete, ordered outcome.

{title:Syntax}

{p 8 17 2}
{cmdab:treatoprobit}
y_ordered x_ordered
{ifin}
{weight}
{cmd:, treat}
(y_treat x_treat)
[{it: options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab: Main}
{synopt:{opt c:luster(varname)}} cluster standard errors using {it:varname} {p_end}
{synopt:{opt r:obust}} compute robust variance covariance matrix / standard errors {p_end}
{synoptline}
{p 4 6 2}
{cmd: pweight, iweight, aweight}s are allowed; see {help weight}


{title:Description}
{pstd}
{cmd:treatoprobit} estimates a model in which {cmd:treat} is a binary indicator for a treatment ({it:y_treat}) for which selection is believed 
correlated with the outcome of interest, {it: y_ordered}. The model assumes that the unobservables in treatment and outcome equations have a bivariate normal distribution. Parameters of the model are estimated by maximum likelihood.


{title:Examples}
{phang} Let self assessed health {bf: SAH} be ordered on a 1-5 scale (excellent, very good, good, fair, poor), and {bf:medicaid} be an indicator of participation in Medicaid: {p_end}
    {cmd:. use nhisdataex, clear}
   
{phang}{cmd:. treatoprobit sah female married, treat(medicaid female married)}
{phang}{cmd:. treatoprobit sah female married [pweight=weight], treat(medicaid female married) vce(robust)}
{smcl}

{title:Author}

{pstd}
Christian A. Gregory, Economic Research Service, USDA, cgregory@ers.usda.gov










