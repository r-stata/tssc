{smcl}
{* *! version 1.0.0 3jun2014}{...}
{cmd: help treatoprobitsim}
{right:also see: {help treatoprobitsim postestimation}}
{hline}

{title:Treatment Effects Latent Factor Ordered Probit Regression}

{phang}
{bf:treatoprobitsim} {hline 2} Estimate effect of potentially endogenous binary treatment on discrete, ordered outcome.

{title:Syntax}

{p 8 17 2}
{cmdab:treatoprobitsim}
y_ordered x_ordered
{ifin}
{weight}
{cmd:, treat}(y_treat = x_treat)
{cmd: simulations}(integer)
[{it: options}]



{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab: Main}
{synopt:{opt sim:ulations(integer)}} number of draws from the distribution of the latent factor {p_end}
{synopt:{opt facdens:ity(string)}} density of the latent factor distribution {p_end}
{synopt:{opt facsk:ew(integer)}} specifies skewness of latent factor, for use with {cmd:chi2} distribution {p_end}
{synopt:{opt start:point(integer)}} specifies the starting point of the draws from halton sequence used to draw from latent factor distribution {p_end}
{synopt:{opt facsc:ale(real)}} standard deviation of the latent factor {p_end}
{synopt:{opt facmean(real)}} specifies mean of latent factor distribution; particularly useful with {cmd: gamma} distribution {p_end}
{synopt:{opt sesim(real)}} specifies the number of draws of the parameter vector are used in computing standard errors of ATE and ATT; default is 500 {p_end}
{synopt:{opt c:luster(varname)}} cluster standard errors using {it:varname} {p_end}
{synopt:{opt r:obust}} compute robust variance covariance matrix  {p_end}
{synoptline}
{p 4 6 2}
{cmd: pweight, iweight, aweight}s are allowed; see {help weight}


{title:Description}
{pstd}
{cmd:treatoprobitsim} estimates a model in which {cmd:treat} is a binary indicator for a treatment ({it:y_treat}) for which selection is believed 
correlated with the outcome of interest, {it: y_ordered}. The model assumes that the unobservables in treatment and outcome equations follow the distribution
specified in {cmd:facdensity}, and that outcomes for treated and untreated groups are not distinct. Parameters of the model are estimated by maximum likelihood.

{title:Options}
{dlgtab:Main}
{phang}
{opt facdens:ity} the density of the latent factor; the default is {cmd:normal}; other options are {cmd:uniform},{cmd:logit}, {cmd:chi2}, {cmd:lognormal}, and {cmd:gamma}.

{phang}
{opt facsk:ew} specifies skewness of latent factor distribution, for use with {cmd:chi2}; the default is {cmd:facskew(2)}.

{phang}
{opt start:point} specifies the starting point for the Halton sequence draws that are used to simulate the latent factor distribution; 
the default is {cmd: startpoint(5)}.


{phang}
{opt facsc:ale} specifies the scale of the latent factor distribution; the default is {cmd: facscale(1)}.
 
{phang}
{opt facmean} specifies the mean of the latent factor distribution; all of the distributions are normalized to be mean zero, so this parameter essentially only
effects the skewness of the {cmd:gamma} distribution, which uses {cmd: invgammap} to simulate it. see {bf:[D] functions.}



{title:Examples}
{phang} Let self assessed health {bf: SAH} be ordered on a 1-5 scale (excellent, very good, good, fair, poor), and {bf:medicaid} be an indicator of participation in Medicaid: {p_end}
     {cmd:. use nhisdataex, clear}
   
{phang}{cmd:. treatoprobitsim sah female married, treat(medicaid=female married) sim(200) facdens(logit) robust}
{phang}{cmd:. treatoprobitsim sah female married [pweight=weight], treat(medicaid=female married) sim(200) facdens(logit) vce(robust)}
{smcl}

{title:Author}

{pstd}
Christian A. Gregory, Economic Research Service, USDA, cgregory@ers.usda.gov
