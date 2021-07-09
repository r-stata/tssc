{smcl}
{* *! version 1.0.0 3jun2014}{...}
{cmd: help switchoprobitsim}
{right:also see: {help switchoprobitsim postestimation}}
{hline}

{title:Latent Factor Ordered Probit Switching Regression}

{phang}
{bf:switchoprobitsim} {hline 2} Estimate effect of potentially endogenous binary treatment on discrete, ordered outcome.

{title:Syntax}

{p 8 17 2}
{cmdab:switchoprobitsim}
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
{synopt:{opt sim:ulations(integer)}} number of draws from the distribution of the latent factor; the default is 100 {p_end}
{synopt:{opt facdens:ity(string)}} density of the latent factor distribution; the default is normal {p_end}
{synopt:{opt mixpi(integer)}} specifies the mixing proportion for 2-component mixture of normals: see below {p_end}
{synopt:{opt facsk:ew(integer)}} specifies skewness of latent factor, for use with {cmd:chi2} distribution {p_end}
{synopt:{opt start:point(integer)}} specifies the starting point of the draws from halton sequence used to draw from latent factor distribution {p_end}
{synopt:{opt facsc:ale(real)}} scale of the latent factor; also scale of mixing distribution if {cmd: mixture} is chosen for the density {p_end}
{synopt:{opt facmean(real)}} specifies mean of latent factor distribution; particularly useful with {cmd: gamma} distribution; also specifies the mean of the
second component of the mixing distribution if {cmd:mixture} is chosen; see below {p_end}
{synopt:{opt sesim(real)}} specifies number of draws of parameter vector to use in computing standard errors of ATE and ATT {p_end}
{synopt:{opt c:luster(varname)}} cluster standard errors using {it:varname} {p_end}
{synopt:{opt r:obust}} compute robust variance covariance matrix  {p_end}
{synoptline}
{p 4 6 2}
{cmd: pweight, iweight, aweight}s are allowed; see {help weight}


{title:Description}
{pstd}
{cmd:switchoprobitsim} estimates a model in which {cmd:treat} is a binary indicator for a treatment ({it:y_treat}) for which selection is believed 
correlated with the outcome of interest, {it: y_ordered}. The model assumes that the unobservables in treatment and outcome equations follow the distribution
specified in {cmd:facdensity}, and that outcomes for treated and untreated groups are distinct. (A test for the hypothesis that the treated and untreated groups
belong to a single outcome regime are reported as part of standard output.) Parameters of the model are estimated by maximum simulated likelihood.

{title:Options}
{dlgtab:Main}
{phang}
{opt facdens:ity} the density of the latent factor; the default is {cmd:normal}; other options are {cmd:uniform},{cmd:logit}, {cmd:chi2}, {cmd:lognormal} and {cmd:gamma}. {cmd:mixture}
can produces a density that is a two-component mixture of normals, with the option {cmd:mixpi (integer)} giving the mixing proportion of a normal (0,1); {cmd:facmean} and 
{cmd:facscale} specify the mean and scale of the second component; the default value for {cmd:mixpi} is 50.

{phang}
{opt facsk:ew} specifies skewness of latent factor distribution, for use with {cmd:chi2}; the default is {cmd:facskew(2)}.

{phang}
{opt start:point} specifies the starting point for the Halton sequence draws that are used to simulate the latent factor distribution; 
the default is {cmd: startpoint(5)}.


{phang}
{opt facsc:ale} specifies the standard deviation of the latent factor distribution; the default is {cmd: facscale(1)}.
 
{phang}
{opt facmean} specifies the mean of the latent factor distribution; all of the distributions are normalized to be mean zero, so this parameter essentially only
effects the skewness of the {cmd:gamma} distribution, which uses {cmd: invgammap} to simulate it. see {bf:[D] functions.}



{title:Examples}

{phang} Let self assessed health {bf: SAH} be ordered on a 1-5 scale (excellent, very good, good, fair, poor), and {bf:medicaid} be an indicator of participation in Medicaid: {p_end}
   {cmd:. use nhisdataex, clear}
   
{phang}{cmd:. switchoprobitsim sah female married, treat(medicaid=female married) sim(200) facdens(logit) robust}
{phang}{cmd:. switchoprobitsim sah female married [pweight=weight], treat(medicaid=female married) sim(200) facdens(logit) vce(robust)}
{smcl}

{title:Author}

{pstd}
Christian A. Gregory, Economic Research Service, USDA, cgregory@ers.usda.gov
