{smcl}
{* 24feb2005}{...}
{hline}
help for {hi:wtdml}
{hline}

{title:Maximum likelihood estimation with Waiting Time Distribution data}

{p 8 16 2}{cmd:wtdml},  
	[{cmd:prevd(}{it:fr_dens}{cmd:)}
	{cmd:hdens(}{it:inc_dens}{cmd:)}
	{cmd:ddens(}{it:exit_dens}{cmd:)}
	{cmd:cens(}{it:cens_type}{cmd:)}
	{cmd:norobust}
	{cmd:robust}
	{cmd:level(}{it:#}{cmd:)}
	{it:ml_model_opts}]

{p 8 16 2}{cmd:wtdml}

{p 4 4 2} 
{cmd:wtdml} is for use with Waiting Time Distribution data; see help
{help wtd}. You must {cmd:wtdset} your data before using this
command; see help {help wtdset}.

{title:Notes on syntax}

{p 4 8 2}
{it:fr_dens} is one of

{p 12 12 2}
{cmd:exp} | {cmd:lnorm} | {cmd:wei}

{p 4 8 2}
{it:inc_dens} is one of

{p 12 12 2}
{cmd:exp} | {cmd:unif}

{p 4 8 2}
{it:exit_dens} is one of

{p 12 12 2}
{cmd:exp} | {cmd:unif}

{p 4 8 2}
In the current version {it:inc_dens} must equal {it:exit_dens}.

{p 4 8 2}
{it:cens_type} is one of

{p 12 12 2}
{cmd:depphi} | {cmd:dep} | {cmd:indep} | {cmd:none}

{p 4 8 2} {it:ml_model_opts} are (some!) options allowed with
{cmd:ml model}, see help {help ml}, such as maximum number of iterations,
maximization technique, etc. You should rarely need this, and please
keep in mind that no thorough validation have been made to ensure that
all options will work!

{title:Description}

{p 4 4 2} {cmd:wtdml} performs maximum likelihood estimation for
Waiting Time Distribution (wtd) data; see help {help wtd}. {cmd:wtdml}
without options and no '{cmd:,}' redisplays the results from the
previously estimated model. On the other hand {cmd:wtdml,} without
options fits the simplest possible model, as described below.

{title:Options for {cmd:wtdml}}

{p 4 8 2}
{cmd:prevd(}{it:fr_dens}{cmd:)} specifies the forward recurrence
density to use. They are named after their corresponding interarrival
density, i.e. {cmd:exp} means Exponential, {cmd:lnorm} means
Log-Normal, and {cmd:wei} means Weibull. The forward recurrence
density {it:f(t)} for an interarrival density {it:g(t)} is given by

{p 24 24 2}
{it:f(t)} = {it:S(t) / mu}

{p 8 8 2}
where {it:S(t)} is the survivor function for {it:g(t)} and {it:mu}
is the mean for {it:g(t)}. If not specified it defaults to {it:exp}.
{* Parametrizations!!!}

{p 8 8 2}
The actual parametrizations used are:

{p 8 8 2} {bf:FR-Exponenential}:

{p 16 24 2} {it:f(t) = exp(-(eb * t)) * eb}

{p 8 12 2} where {it:eb = exp(beta)}.

{p 8 8 2} {bf:FR-Weibull}:

{p 16 24 2} {it:f(t) = exp(-(eb * t) ^ea - lngamma(1 + 1/ea)) * eb}

{p 12 12 2} where {it:ea = e(alpha)} and {it:eb = exp(beta)}.

{p 8 8 2} {bf:FR-Log-Normal}:

{p 16 24 2} {it:f(t) = normprob(-(ln(x) - mu)/exp(lns)) / exp(mu + exp(2 * lns)/2)}

{p 12 12 2} where {it:lns = ln(sigma)}.


{p 4 8 2}
{cmd:hdens(}{it:inc_dens}{cmd:)} specifies the incidence density over
the observation interval to be Exponential or Uniform. If not
specified it defaults to {it:exp}.

{p 4 8 2}
{cmd:ddens(}{it:exit_dens}{cmd:)} specifies the exit density over
the observation interval to be Exponential or Uniform. If not
specified it defaults to {it:exp}, if {cmd:cens()} is not set to
{it:none}.

{p 4 8 2} 
{cmd:cens(}{it:cens_type}{cmd:)} specifies the dependency structure
between event and exit times. {cmd:depphi} implies dependency on both
initial disease status and long term dependency between event and exit
times among non-prevalents (as measured by the parameter {it:phi},
hence the name). {cmd:dep} implies dependency on initial
disease status only. {cmd:indep} implies full independence between
event and exit times regardless of initial treatment status.
{cmd:none} implies that no model should be fitted for exit times, and
only event times be considered.

{p 4 8 2}{cmd:robust} specifies that the Huber/White/sandwich
estimator of variance is to be used in place of the traditional
calculation in the estimation. {cmd:robust} combined with
{cmd:cluster()} (must be set with {cmd:wtdset}) further allows
observations which are not independent within cluster (although they
must be independent between clusters). See help {help wtdset} for
further information.

{p 4 8 2}{cmd:norobust} specifies that the estimation should {bf:not}
use the Huber/White/sandwich estimator of variance, even though this
was specified in the {cmd:wtdset} statement, see help {help wtdset}.

{p 4 8 2}
{cmd:level(}{it:#}{cmd:)} is the standard confidence-level option. It
specifies the confidence level, in percent, for confidence intervals
of the coefficients. The default is {cmd:level(95)} or as set by
{cmd:set level}; see help {help level}.

{title:Remarks}

{p 4 4 2} A more detailed description of the parameters is given in
the paper by Støvring and Vach (2005), see help {help wtd}. Briefly,
the parameters are:

{p 8 12 2}
{it:p} is prevalence
 
{p 8 12 2}
{it:lambda} is incidence rate

{p 8 12 2} {it:d}[i] is i'th exit rate (1 is for prevalents, 0 for
non-prevalents, and if i is missing then it is the joint rate for all)

{p 8 12 2}
{it:phi} measures departure from independence between event and exit
times among non-prevalents

{p 8 12 2}
{it:alpha}, {it:beta}, {it:mu}, and {it:sigma} are the parameters of
the forward recurrence density

{p 4 4 2} Note that the maximization procedure involves numerical
integration. This is implemented through the use of a Monte Carlo
technique with antithetic sampling. This results in rather fast code
yielding high precision (although it may still take a while depending
on problem, problem size, and hardware), but it does result in small
(usually very small) random error in estimates. Thus, on a re-run with
exact same data, you will observe a small change in estimates. This
should be considered a feature, as it allows for direct evaluation of
the uncertainty due to the numerical integration, but can be avoided
by setting the seed prior to maximization, see help {help seed}.

{title:Examples}

{p 4 8 2}
{cmd:. wtdset event exit, i(id) start(31dec1996) end(31dec1997) scale(365)}

{p 4 8 2}
{cmd:. wtdml, prevd(wei) cens(depphi)}

{p 4 8 2}
{cmd:. wtdml, prevd(exp) hdens(exp) cens(none)} 

{p 4 8 2}
{cmd:. wtdml,                                   /* same as above */ }

{p 4 8 2}
{cmd:. wtdml                                    /* redisplays results */}

{title:Also see}

{p 4 13 2}Online:  help for {help wtd}, {help ml}
