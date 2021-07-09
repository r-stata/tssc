{smcl}
{* december 18, 2016 @ 19:27:51}{...}
{hi:help plausexog}{right:see also: {helpb ivregress}}
{hline}

{title:Title}

{p 4 4 2}{hi:plausexog} {hline 2} Stata implementation of IV estimation under flexible (plausibly exogenous) conditions


{title:Syntax}

{p 8 14 2}
{cmd:plausexog} {it:method} {it:depvar} [{it:{help varlist:varlist1}}]
{cmd:(}{it:{help varlist:varlist2}} {cmd:=}
         {it:{help varlist:varlist_iv}}{cmd:)} {ifin} {weight}
[{cmd:,} {it:options}]



{synoptset 27}{...}
{synopthdr:method}
{synoptline}
{synopt:{opt uci}} Union of confidence intervals{p_end}
{synopt:{opt ltz}} Local to Zero approach {p_end}
{synoptline}

{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt level(#)}}set confidence level; default is {cmd:level(0.95)}{p_end}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt un:adjusted},
 {opt r:obust}, or {opt cl:uster} {it:clustvar}{p_end}

{syntab :uci}
{synopt:{opth gmin(numlist)}}Minimum gamma for plausibly exogneous variable(s){p_end}
{synopt:{opth gmax(numlist)}}Maximum gamma for plausibly exogneous variable(s){p_end}
{synopt :{opt grid(#)}}Specifies number of points (in [gmin, gmax]) at which to
calculate bounds; default is {cmd:grid(2)}{p_end}

{syntab :ltz}
{synopt:{opt mu(#)}}Value specifying mean of prior for support of gamma assuming a normal distribution {p_end}
{synopt:{opt omega(#)}}Value specifying variance of prior for support of gamma assuming a normal distribution {p_end}
{synopt:{opth dist:ribution(name, params)}}Allows for the specification of gammas with arbitrary distributions.  Allowed distributaions are: normal, uniform, chi2, poisson, t, gamma, or special.
Numerical parameters associated with the distributions are specified as "params". As many parameters are required as plausibly exogenous variables and {help rnormal:distribution moments}.  Further details are provided below. {p_end}
{synopt :{opt seed(#)}}Sets the {help seed} for simulation-based calculations when using a non-Gaussian prior for the LTZ option.
Only required when specifying the distribution option.{p_end}
{synopt :{opt iterations(#)}}Determines the number of iterations for simulation-based calculations when using a non-Gaussian prior for the LTZ option.
Only required when specifying the distribution option; default is {cmd:iterations(5000)}{p_end}

{syntab :Graphing}
{synopt:{opth gra:ph(varname)}}{p_end}
{p2coldent:* {opt graphmu(numlist)}}List of values of mu over which graph should be plotted {p_end}
{p2coldent:* {opt graphom:ega(numlist)}}List of values of omega corresponding to each point on the graph{p_end}
{p2coldent:* {opt graphdelta(numlist)}}List of values to characterise each distribution on the graph (x axis values).  If symmetric distribution is assumed, delta=gamma {p_end}
{synopt :{opt *}}Any other options documented in {manhelpi twoway_options G-3}.  Overrides default graph options (ie title, axis labels) {p_end}


{synoptline}
{p2colreset}{...}
{p 4 6 2}* These options must be specified only when graphing with the {cmd:ltz} option.{p_end}



{title: Description}

{pstd}
{cmd:plausexog} implements "Plausibly Exogenous" estimation developed by Conley et
al. (2012).  This allows for inference using instrumental variable estimation in
situations where the exclusion restriction need not hold precisely.  A comprehensive
description of this method of inference is provided in
{browse "http://ideas.repec.org/a/tpr/restat/v94y2012i1p260-272.html":{it:Conley et al (2012)}}.

{pstd}
Briefly, consider a {help depvar:dependent variable} {it:y}, a set of exogenous
variables {it:X1}, a set of endogenous variables {it:X2} (together referred to as
{it:X}), and a set of instrumental variables {it:Z}.  Standard IV estimation requires
that gamma=0 in the following equation:

{p 8 12 2}y_i = {bind:X_i * Beta} + {bind:Z_i * gamma} + u_i      (1)

{pstd}
However, using {cmd:plausexog}, the restriction that gamma=0 can be relaxed, and
replaced with the assumption that gamma is close to, but not necessarily equal to,
zero.  This assumption about gamma can take a number of forms: either the support
of gamma can be assumed, or distributional assumptions about gamma can be made.  
The first assumption is more conservative but generally will lead to wider bounds 
on the estimated coefficients on {it:X2}.

{pstd}
The first of these methods is referred to as the {bf:union of confidence interval}
approach (UCI) and the user need simply specify the maximum and minimum value which
gamma can take.  These values can be either symmetrical or non-symmetrical around
zero.  The second method: the {bf:local to zero} (LTZ) approach requires the specification
of the distribution which descripes the prior belief about gamma.  Once again this
can either be symmetrical around zero (for example by specifying a normal distribution
centred at zero, or non-symmetrical around zero (for example by specififying a uniform
U[0,G] distribution, where G is some scalar reflecting the maximum believed deviation
from zero).

{pstd}
Analytical bounds in the local to zero approach are based on an assumed normal distribution
for gamma.  However, Conley et al. document that a simulation-based approach can be
used to calculate bounds for non-normal distributions of gamma in the LTZ approach.
{cmd:plausexog} has implemented this simulation-based approach for a number of
{help rnormal:common distributions} such as the uniform, Chi-squared, Poisson, or
Gamma distribution.  Additionally, non-standard and empirical distributions for gamma
can be used when a sample from this distribution is passed to the command as a
variable.  Instructions are available in the {opt distribution} option, and  full
details of the simulation-based algorithm followed by {cmd:plausexog} are available
on page 265 of Conley et al. (2012).

{pstd}
{cmd:plausexog} can return results in various ways.  By default it returns an output
(stored as a matrix) presenting upper and lower bounds (and point estimates where
appropriate), however it also can return scalars for the upper and lower bound on
each endogenous variable. Graphical results can also be automatically generated
which display confidence intervals and point estimates under various assumptions
about the support or distribution of gamma using the graphing commands.


{title:Options}

{dlgtab:Method}

{phang}
{opt uci} use the union of confidence interval approach for estimation of bounds.
This requires the specification of a maximum and minimum prior for gamma: the
sign on the plausibly exogenous variable in the structural equation above.
The result then provides the union of all interval estimates of beta conditional
on a grid of all possible gamma values.

{phang}
{opt ltz} use the local to zero approach to estimate.  This requires specifying
a full prior distribution for gamma in the structural equation via a series of
distributional parameters.

{dlgtab:General options}

INCLUDE help vce_rcbj

{phang}
{opt level(#)}; see
{helpb estimation options##level():[R] estimation options}.

{dlgtab:UCI options}

{phang}
{opt grid(#)} specifies the number of grid points for gamma over which to estimate beta.
For example, if gmin is -x and gmax is +x then specifying grid(2) will result in two estimates
of beta: once at gamma=-x and once at gamma=x.  Similarly, specifying 5 will result in
five estimates: at gamma=-x, gamma=-x/2, gamma=0, gamma=x/2 and gamma=x.

{phang}
{opt gmin(numlist)} specifies the minimum prior for gamma believed to characterise the
degree that Z may diverge from true exogeneity (ie the smallest possible value that gamma
is believed to take in the first stage).  One value should be specified for each potentially
exogenous variable included.  If multiple Z variables are used and some are believed to be
exogenous then for these variables both gmin and gmax should take the value of 0.

{phang}
{opt gmax(numlist)} specifies the maximum prior for gamma believed to characterise the
degree that Z may diverge from true exogeneity (ie the largest possible value that gamma
is believed to take in the first stage).  One value should be specified for each potentially
exogenous variable included.  

	  {pmore}
gmin and gmax do not have to be symmetrical around zero.  Any value can be entered based
on the researcher's prior.


{dlgtab:LTZ options}

{phang}
{opt mu(#)} the value for the researchers's prior for the mean of gamma in the structural
equation (1).  This value refers to the mean when a Gaussian prior is imposed on gamma in
the LTZ approach, and results in an exact set of confidence intervals.  


{phang}
{opt omega(#)} the value describing the researcher's prior for the variance of gamma
in the structural equation (1).  Along with the value specified in {opt mu(#)}, this
describes the Gaussian prior over gamma to be used in calculating bounds on the
parameter of interest.

{phang}
{opt distribution(name, params)} allows for non-Guassian priors for the distribution
of gamma.  When using the distribution option, the mu and omega option do not need
to be specified.  Bounds based on non-normal distributions for gamma are calculated
using the simulation-based algorithm described in Conley et al. page 265.  Accepted
distributions names are: normal, uniform, chi2, poisson, t, gamma, and special.
When specifying any of the first six options, parameters must be specified along
with each of these distributions.  For normal, parameters are the assumed mean and
standard deviation; for uniform, the parameters are the minimum and maximum; for
chi2 (Chi squared) it is the degrees of freedom; for Poisson it is the distribution
mean, for t it is the degrees of freedom; and for gamma it is the shape and scale
of the assumed distribution.  For any assumed distribution of gamma which is not
contained in the previous list, {opt special} can be specified, and a variable can
be passed which contains analytical draws from this distribution.  If more than
one plausibly exogenous variable is used, the relevant parameters must be specified
for each plausibly exogenous variable.  Note that although a Gaussian prior is allowed
in this format, if a Gaussian prior is assumed it is preferable to use the {opt mu(#)}
and {opt omega(#)} options, as these give an exact, rather than approximate (simulated)
set of bounds.

{phang}
{opt seed(#)} Sets the {help seed} for simulation-based calculations when using a
non-Gaussian prior for the LTZ option.  Setting the seed allows for bounds to be
replicated when using the simulation-based process described above.
Only required when specifying the distribution option.

{phang}
{opt iterations(#)} Determines the number of iterations for simulation-based
calculations when using a non-Gaussian prior for the LTZ option. Only required
when specifying the distribution option; default is {cmd:iterations(5000)}.
In Stata IC and Small Stata the number of iterations are limited by the maximum
matrix size of Stata (800 and 100 respectively). Given this, the {opt distribution}
option should be used with caution in these versions of Stata.

{phang}
{opt graphmu(numlist)}; see {helpb plausexog##graphing:plausexog graphing}

{phang}
{opt graphomega(numlist)}; see {helpb plausexog##graphing:plausexog graphing}

{phang}
{opt graphdelta(numlist)}; see {helpb plausexog##graphing:plausexog graphing}


{marker graphing}{...}
{dlgtab:Graphing}

{phang}
{opt graph(varname)} the name of the (plausibly exogneous) Z variable that the 
user wishes to graph.  In the UCI method, confidence intervals will be graphed, 
while in the LTZ approach both confidence intervals and a point estimate will be 
graphed over a range of gamma values.

{phang}
{opt graphmu(numlist)} this option must be used with the LTZ model when a graph
is desired.  This provides the values for a series of mu values (see mu() under LTZ options) 
for each point desired on the graph.  For example, if five points should be 
plotted on the line graph then 5 separate values should be provided in graphmu().
See the {helpb plausexog##examples:examples below} for an example of this syntax.

{phang}
{opt graphomega(numlist)} this option must be used with the LTZ model when a graph is desired.
This provides the values for a series of omega values (see omega() under LTZ options) for each
point desired on the graph.  Each graphomega values must correspond to the graphmu value
specified in graphmu()

{phang}
{opt graphdelta(numlist)} this option must be used with the LTZ model when a graph is desired.
This provides a series of values which correspond to each point on the graph characterised by
graphmu and graphomega above.  For example, if gamma is assumed normally distributed and the
x-axis should disply the variance at each point on the graph, then the variance corresponding
to each graphmu() and graphomega() should be listed in graphdelta().  See the
{helpb plausexog##examples:examples below} for an example of this syntax.

{phang}
{opt *} overrides the typical graphing options built-in to 
plausexog.  This allows for the inclusion of any {helpb twoway_options:graphing commands} 
permissable  in Stata's line plots to be incorporated, including 
{helpb added_line_options:added lines}, {helpb added_text_options:added text},
{helpb axis_options:changes to axes}, {helpb title_options:alternative titles} 
and so forth.  For example, to include a horizontal line at zero the following 
syntax can be used: yline(0).

{marker examples}{...}
{title: Examples}


{pstd}Setup{p_end}
{phang2}{cmd:. webuse set http://www.damianclarke.net/data/}{p_end}
{phang2}{cmd:. webuse Conleyetal2012}{p_end}
{phang2}{cmd:. local xvar i2 i3 i4 i5 i6 i7 age age2 fsize hs smcol col marr twoearn db pira hown}{p_end}

{pstd} Run union of confidence interval (UCI) estimation with Conley et al's REStat data{p_end}
{phang2}{cmd:. plausexog uci net_tfa `xvar' (p401 = e401), gmin(-10000) gmax(10000) grid(2) level(.95) vce(robust)}{p_end}

{pstd} Run local to zero (LTZ) estimation with Conley et al's REStat data{p_end}
{phang2}{cmd:. plausexog ltz net_tfa `xvar' (p401 = e401), mu(0) omega(25000) level(.95) vce(robust)}{p_end}

{pstd} Run same local to zero (LTZ) estimation using simulation-based method which works for arbitrary distributions (here normal with mean zero and standard deviation 5000){p_end}
{phang2}{cmd:. plausexog ltz net_tfa `xvar' (p401 = e401), distribution(normal, 0, 5000)}{p_end}

{pstd} Run local to zero (LTZ) estimation and graph output as per Conley et al. (figure 2){p_end}
{phang2}{cmd:. plausexog ltz net_tfa `xvar' (p401 = e401), omega(25000) mu(0) level(.95) vce(robust) graph(p401) graphmu(1000 2000 3000 4000 5000) graphomega(333333.33 1333333.3 3000000 5333333.3 8333333.3) graphdelta(2000 4000 6000 8000 10000)} {p_end}

{title: Saved results}

{pstd}
{cmd:plausexog} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(lb_endogname)}}Lower bound estimate for each (plausibly) instrumented variable{p_end}
{synopt:{cmd:e(ub_endogname)}}Upper bound estimate for each (plausibly) instrumented variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}Coefficient vector under plausible exogeneity{p_end}
{synopt:{cmd:e(V)}}Variance-covariance matrix of the estimators under plausible exogeneity{p_end}
{p2colreset}{...}



{title:References}
{marker Conetal}{...}
{phang}
Conley, T. G., Hansen, C. B., and Rossi, P. E. 2012. Plausibly Exogenous.
{it:The Review of Economics and Statistics} 94(1): 260-272.



{title:Acknowledgements}
    {p 4 4 2} The original plausibly exogenous code was written by Christian Hansen, Tim Conley and
Peter Rossi.  I thank Christian Hansen for his very useful comments on this version of the code.

{title:Also see}

{psee}
Online:  {manhelp ivregress R: ivregress}


{title:Author}

{pstd}
Damian Clarke, Department of Economics, Universidad de Santiago de Chile. {browse "mailto:damian.clarke@usach.cl":damian.clarke@usach.cl}
{p_end}
