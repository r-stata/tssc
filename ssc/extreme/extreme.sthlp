{smcl}
{* *! version 1.2.0 17 May 2017}{...}
{cmd:help extreme}
{hline}{...}

{title:Title}

{pstd}
Extreme value theory models: fitting and graphical diagnostics{p_end}

{title:Syntax}

{phang}
{cmd:extreme} {it:model} {it:{help varlist}} {ifin} {weight} [{cmd:,} {it:estimation_options}]

{phang}
- or, usually after the above -

{phang}
{cmd:extreme plot} [{it:{help varname}}] {ifin} {weight} [{cmd:,} {it:plot_options}]

{phang}The {it:{help varlist}} in an {cmd:extreme} {it:model} command line should have one entry unless fitting a model with multiple order statistics. The {it:{help varname}} in an {cmd:extreme plot} command
is only used for the {cmd:mrl} plot type. All {it:{help varname}}s and {it:{help varlist}}s may include factor variable and time-series operators; see {help fvvarlist}.{p_end}

{synoptset 34 tabbed}{...}
{synopthdr:model}
{synoptline}
{synopt:{opt gpd}}Generalized Pareto distribution (GPD){p_end}
{synopt:{opt gev}}Generalized Extreme Value distribution (GEV) with one or more order statistics{p_end}
{synoptline}

{synopthdr:estimation_options}
{synoptline}
{syntab:Model}
{synopt:{opt thresh:old}{cmd:(}{it:{help varname}} | {it:{help numlist}}{cmd:)}}Set minimum value(s) for estimation sample, relative to which excedences are computed; GPD only{p_end}
{synopt:{opt mu:vars}{cmd:(}[{it:{help varlist:varlist}}] [, {opt nocons:tant}]{cmd:)}}Specify linear determinants (covariates) for mu (location) parameter; GEV only{p_end}
{synopt:{opt sig:vars}{cmd:(}[{it:{help varlist:varlist}}] [, {opt nocons:tant}]{cmd:)}}Specify linear determinants for log sigma (scale) parameter{p_end}
{synopt:{opt xi:vars}{cmd:(}[{it:{help varlist:varlist}}] [, {opt nocons:tant}]{cmd:)}}Specify linear determinants for xi (shape) parameter{p_end}
{synopt:{opt gumb:el}}Impose xi=0: exponential distribution for GPD, Gumbel distribution for GEV{p_end}
{synopt:{opt const:raints}{cmd:(}{it:{help estimation options##constraints():constraints}}{cmd:)}}Impose other linear constraints on parameters{p_end}

{syntab:Estimation}
{synopt:{opt init(rowvector)}}Override default starting point for maximization; see {help ml##ml_noninteract_descript:help ml}.{p_end}
{synopt:{it:ml_opts}}Standard {help ml} {help ml##noninteractive_maxopts:maximize options} to control Maximum Likelihood search; seldom needed{p_end}
	
{syntab:Corrections to classical estimates}
{synopt:{opth vce(vcetype)}}{it:vcetype} may be {opt r:obust}; {opt cl:uster} {it:clustvar}; {opt opg}; {opt oim}; {opt boot:strap} [{cmd:,} {it:bootstrap_options}]; or (equivalently) {opt bs} [{cmd:,} 
{it:bootstrap_options}]; see {help vce_option}{p_end}
{synopt:{cmd:small(}{c -(}{opt cs} | {opt bs} [{cmd:,} {opt r:eps(#)}]{c )-}{cmd:)}}{cmd:cs}: Analytical (Cox-Snell) bias correction to coefficient estimates
{break}{cmd:bs}: parametric-bootstrap-based bias correction and computation of VCE{p_end}

{syntab:Display}
{synopt:{opt l:evel(#)}}Set confidence level; default is 95{p_end}
{synopt:{opt qui:etly}}Suppress most output other than final results{p_end}
{synopt:{it:display_opts}}Standard {help ml##display_options:ml display options} to control results display; seldom needed{p_end}

{syntab:Graphing}
{synopt:{it:graph_opts}}Most {help twoway_options:graph twoway options} for formatting plots; relevant for GPD estimation with multiple thresholds specified, which triggers graphing{p_end}
{synoptline}

{synopthdr:plot_options}
{synoptline}
{synopt:{opt mrl}[{cmd:(}{it:{help numlist}}{cmd:)}]}Mean residual life diagnostic plot for {help varname}; may be requested before estimation{p_end}
{synopt:{opt pp}}Probability-probability diagnostic plot{p_end}
{synopt:{opt qq}}Quantile-quantile diagnostic plot{p_end}
{synopt:{opt ret:urn}}Return level-return period diagnostic plot{p_end}
{synopt:{opt dens:ity}}Kernel density diagnostic plot{p_end}
{synopt:{cmdab:xiprof:ile(}[{it:{help numlist}}]{cmd:)}}Profile likelihood plot for xi at specified values{p_end}
{synopt:{cmdab:retprof:ile(}[{it:{help numlist}}]{cmd:,} {opt per:iod(#)}{cmd:)}}Profile likelihood plot for return level, for specified return period{p_end}
{synopt:{cmdab:rateprof:ile(}[{it:{help numlist}}]{cmd:,} {opt ret:level(#)}{cmd:)}}Profile likelihood plot for return rate, for specified return level{p_end}
{synopt:{opt l:evel(#)}}Set confidence level for plotted confidence intervals; default is 95{p_end}
{synopt:{opt name(stub)}}Specify prefix for storage names of plots produced; default is {cmd:extreme}{p_end}
{synopt:{it:graph_opts}}Most {help twoway_options:graph twoway options} for formatting plots{p_end}
{synopt:{it:kdens_opts}}When requesting the {opt dens:ity} plot, standard {help twoway kdensity} options may be included{p_end}
{synoptline}

{pstd}{cmd:extreme} shares features of all estimation commands; see help {help estcom}

{pstd}
The syntax of {help predict} following {cmd:extreme} is{p_end}

{phang}{cmd:predict} [{it:type}] {it:newvarname} {ifin} [{cmd:,} {it:statistic} {cmdab:eq:uation(}{cmd:#}{it:eqno}|{it:eqname}{cmd:)}]

{phang2}where {it:statistic} is {opt xb}, {opt pr}, {opt cdf}, {opt ccdf}, or {cmd:invccdf(}{it:#} | {it:{help varname}} | {it:{help exp}}{cmd:)}

{title:Donate?}

{pstd}
Has {cmd:extreme} improved your career or your marriage?
Consider giving back through a {browse "http://j.mp/1iptvDY":donation} to support the work of its self-employed author, {browse "http://davidroodman.com":David Roodman}.

{title:Description}

{pstd}
{cmd:extreme} estimates the most-used models in univariate extreme value theory, using Maximum Likelihood. It is strongly influenced by the textbook of Coles (2001)
and the associated {browse "http://cran.r-project.org/web/packages/ismev/ismev.pdf":ismev} package for R, maintained by Eric Gilleland. In addition to fitting models,
{cmd:extreme} offers several diagnostic
and profile plots. As a result, and as a measure of its scope, {cmd:extreme} can run most of the numerical and graphical examples in Coles (2001). (See {help extreme##examples:examples} below.)

{pstd}
Specifically, {cmd:extreme} fits:

{p 8 10 2}* The generalized Pareto distribution (GPD), which is appropriate for modeling exceedances of a threshold, i.e., right tails of distributions. The GPD cumulative distribution function (cdf)
takes the form G(x)=1-(1+xi*(x-mu)/sigma)^(-1/xi), where mu is a pre-specified threshold.{p_end}
{p 8 10 2}* The generalized extreme value distribution (GEV), which is appropriate for modeling block maxima. Its cdf is G(x)=exp(-(1+xi*(x-mu)/sigma)^(-1/xi)).{p_end}
{p 8 10 2}* The extension of the GEV for multiple order statistics for blocks, such as the highest, second-highest, and third-highest daily rainfall totals in a 
year. Its cdf does not have a closed form, but its probability density function (pdf) does (Coles 2001, eq 3.15). The number of order statistics available may vary by observation.{p_end}

{pstd}
The GPD model has two parameters to be estimated: a scale parameter, sigma, and a shape parameter, xi. {cmd:extreme} enters sigma in logarthmic form, so that the 
core parameter displayed in estimation results is lnsigma. (Normally the implied value for sigma is also displayed, at the bottom.) Fitting 
the GPD also requires specifying a threshold, relative to which exceedances are computed. Observations at or below the threshold are excluded.

{pstd}
The GEV model too contains scale and shape parameters. In addition, in place of the pre-specified threshold, there is a third parameter for location, mu.

{pstd}
Multiple order statistics are specified by including multiple variables in the {it:{help varlist}} after {cmd:extreme gev}, in descending order. For each observation,
{cmd:extreme} will model as many order statistics as available data permit. E.g., if you list 10 variables and just variable 5 is missing for some observation,
then {cmd:extreme} will model the top 4 statistics for that observation.

{pstd}
{cmd:extreme} allows for non-stationary models: all core parameters may depend linearly on variables or factor variables specified with the {opt mu:vars()}, {opt sig:vars()}, {opt xi:vars()}
options.

{pstd}
{cmd:extreme}'s major novelty is the ability to compute the Cox-Snell small-sample bias correction for all models fit, via the {opt small()} option. The correction for the GPD is 
derived in Giles, Feng, and Godwin (2015). The correction for the GEV, including for multiple order statistics, is new. Its efficacy has been demonstrated
in simulations, and a write-up is pending. The correction has been extended to the non-stationary case too. Maximum Likelihood is always biased in finite samples, and the bias can be 
significant in the small samples often used in extreme value analysis. (On analytical bias correction generally, see Cordeiro and Cribaro-Neto (2014, ch. 4).)

{pstd}
By default, the variance-covaraince matrix
from the classical Maximum Likelihood fit and, thus, the standard errors are retained after this correction to the parameter estimates. Simulations suggests that the correction hardly affects
the standard errors. But you can at once bypass and check this assertion by bootstrapping the standard errors of the corrected estimator, e.g., by adding a {cmd:vce(bs)} option.

{pstd}
However, {cmd:extreme} also offers bias-correction via a parametric bootstrap. This has the advantage of working for values of xi for which ML is consistent, but for which the
Cox-Snell correction is not defined: formally between -1 and -1/3, in practice between -1 and about -0.2. Also, it works for models with constraints, including the {cmd:gumbel} 
constraint. When bootstrapping
the bias correction, {cmd:extreme} also automatically bootstraps the variance-covariance matrix of the estimate.

{pstd}
When bootstrapping the VCE or bias correction, the precise results depend on the initial state of Stata's pseudorandom number generator. See {help set_seed:set seed}. {cmd:extreme} displays this state
and stores it in the return value {cmd:e(seed)}.

{pstd}
As an estimation command built on Stata's {help ml}, {cmd:extreme} accepts observation weights, linear constraints on parameters, {help vce_option:vce() options}, and options 
for {help maximize:controlling optimization}, all according to standard {help ml} syntax.

{pstd}
When fitting the GPD, specifying multiple thresholds in the {cmdab:thresh:old()} option causes {cmd:extreme} to fit the model for each threshold, adjusting the sample accordingly, and then
graph the estimates of lnsig and xi against the
thresholds. In addition, all of the {cmd:extreme plot} subcommands of course generate plots. In all cases, {cmd:extreme} makes minimal effort to format and label
graphs. This reduces interference with any {help twoway_options: graph twoway options} that {it:you} include in the command line, to change the {help help schemes:scheme}, titles, etc.

{pstd}
You can request multiple plots in one {cmd:extreme plot} command line, as in {cmd:extreme plot, qq pp density xiprofile}. Most plot types do not affect the stored numerical estimation 
results. However, requesting {opt xiprof:ile()}, {opt retprof:ile()}, or  {opt rateprof:ile()} will cause {cmd:extreme} to save matrices named {cmd:e(xiprofileCI)} and {cmd:e(retprofileCI)} holding the confidence
sets derived through graphing the profile likelihood.

{pstd}
Anyone working with these models is likely to be familiar with Coles (2001). The easiest way to learn {cmd:extreme} is probably to study the {help extreme##examples:replications below}
of many examples in that book.

{title:Estmation options}

{phang}{opt thresh:old}{cmd:(}{it:{help varname}} | {it:{help numlist}}{cmd:)} is for the GPD model only. It sets the minimum value for inclusion in the sample. For fitting, 
{cmd:extreme} subtracts the threshold from all observations above it. Observations less than or equal to it are excluded. The threshold defaults to the minimum value in the sample.
If a {it:{help varname}} is specified, then the threshold may vary by observation.
If multiple thresholds are specified, {cmd:extreme} graphs the estimated lnsig and xi parameters against the chosen thresholds. If exactly two thresholds are specified,
{cmd:extreme} interprets them as minimum and maximum values with 100 steps in between.

{phang}{opt mu:vars}{cmd:(}[{it:{help varlist:varlist}}] [, {opt nocons:tant}]{cmd:)}, {opt sig:vars}{cmd:(}[{it:{help varlist:varlist}}] [, {opt nocons:tant}]{cmd:)}, 
{opt xi:vars}{cmd:(}[{it:{help varlist:varlist}}] [, {opt nocons:tant}]{cmd:)} specify covariates for non-stationary models. They allow mu, log sigma (not sigma), and xi
to depend linearly on covariates. Factor variables are allowed.

{phang}{opt gumb:el} imposes the constraint xi=0. In the context of the GPD model, this specifies the exponential model. In the context of the GEV, this specifies
the Gumbel model.

{phang}{opt const:raints}{cmd:(}{it:{help estimation options##constraints():constraints}}{cmd:)} imposes constraints according to {help constraint:standard Stata syntax}.

{phang}{opt l:evel(#)} specifies the confidence level, in percent, for confidence intervals; see {help level:help level}. The default is 95. It affects display of regression results
and plots of confidence intervals.

{phang}{opt qui:etly} suppresses most output, but not final results.

{phang}{opt init(vector)} passes a row vector of user-chosen starting values for the model fit, in the manner of the {help ml: ml init, copy} 
command. The vector must contain exactly one element for each parameter {cmd:extreme} will estimate, and in the same order as in the output (excluding the derived sigma results at bottom). The default initial coefficient for any non-constant
covariate is 0. As for constants--including all parameters in stationary models--the default initial value for the xi equation is also 0. The defaults for lnsigma and, in the GEV model, mu are what the true values would be if xi=0 and
the observed first and second moments of the modeled variable exactly equal the true ones. That is, fixing xi=0, if x ~ GPD, then Var[x]=sigma^2; and if x ~ GEV, 
E[x] = mu + sigma * gamma, Var[x] = sigma^2*pi^2/6, where gamma is the Euler-Mascheroni constant. Solving these equations for mu and sigma and substituting empirical values
for E[x] and Var[x] yields the default initial values.

{phang}{it:ml_opts}: {cmd:extreme} accepts the following standard {help ml} options to control the search for the maximum: {opt tr:ace}
	{opt nolo:g}
	{opt grad:ient}
	{opt hess:ian}
	{cmd:showstep}
	{opt tech:nique(algorithm_specs)}
	{opt iter:ate(#)}
	{opt tol:erance(#)}
	{opt ltol:erance(#)}
	{opt gtol:erance(#)}
	{opt nrtol:erance(#)}
	{opt nonrtol:erance}
	{opt shownrt:olerance}
	{cmdab:dif:ficult}
	
{phang}{cmd:vce(}{cmd:oim} | {cmdab:o:pg} | {cmdab:r:obust} | {cmdab:cl:uster} {it:varname} | {c -(}{opt boot:strap} | {opt bs}{c )-} [{cmd:,} {it:bootstrap_options}]{cmd:)} governs the estimation of the
variance-covariance matrix of the parameter estimates (VCE). See {help vce_option}. If a bootstrapped VCE is chosen, the bootstrap is {it:non-parametric}, as is standard in Stata, meaning that 
the data are randomly resampled for each replication. This contrasts with the parametric bootstrap deployed by {cmd:small(bs)}, discussed next.

{phang}{cmd:small(}{c -(}{opt cs} | {opt bs} [{cmd:,} {opt r:eps(#)}]{c )-}{cmd:)} requests bias correction. ML has o(1/N) bias, which can be significant for small samples. {cmd:small(cs)} requests the
analytical Cox-Snell (1968) bias correction; this is available for xi>-0.2, so if xi<=-.2 no correction is made. The CS correction for 
the GPD is derived in Giles, Feng, and Godwin (2015). The correction for the GEV, including for multiple order statistics, is from Roodman (2017).

{pin}Alternatively, {cmd:small(bs)} requests a simulation-based bias correction. A parametric bootstrap
is performed--"parametric" meaning that instead of resampling the data as with {cmd:vce(bs)}, simulations of the modeled variable are repeatedly drawn from the 
ML-estimated distribution (Horwitz 2001, section 3.1). {cmd:small(bs)} also automatically bootstraps the VCE during this process. The optional {opt r:eps(#)} suboption controls the number of replications; the default is 
50. As an example, suppose ML estimates xi=0.27 on a 
small sample. It is 
then found that in simulated data sets of the same size with xi=0.27, the ML estimate averages 0.29, for an empirical bias of +0.02. That suggests that the bias embedded in our 
original ML estimate is also about 0.02, so we correct it to 0.25.

{pin}Combining {cmd:small(bs)} with {cmd:vce(bs)} tells {cmd:extreme} to nonparametrically bootstrap the VCE of the parametric-bootstrap-corrected coefficients (and thus to set aside
the parametrically bootsrapped VCE computed anyway). This is feasible but slow.

{phang}{it:display_opts}: {cmd:extreme} accepts the following standard {help ml##mldisplay:ml display} options: {opt noh:eader}
{opt nofoot:note}
{opt f:irst}
{opt neq(#)}
{opt showeq:ns}
{opt pl:us}
{opt nocnsr:eport}
{opt noomit:ted}
{opt vsquish}
{opt noempty:cells}
{opt base:levels}
{opt allbase:levels}
{opth cformat(%fmt)}
{opth pformat(%fmt)}
{opth sformat(%fmt)}
{opt nolstretch}
{opt coefl:egend}

{phang}{it:graph_opts}: Most {help twoway_options:graph twoway options} for formatting plots can be added to {cmd:extreme gpd} command lines
when multiple thresholds are provided, in order to override formatting defaults.

{title:Plot options}

{phang}An {cmd:extreme plot} command line may include multiple plot types.

{phang}{opt mrl}[{cmd:(}{it:{help numlist}}{cmd:)}] requests a mean residual life diagnostic plot, which 
graphs the average amount by which observations above a threshold
exceed it, as a function of the threshold. If the tail of a distribution is well-approximated by the GPD
above some threshold, then the MRL plot should be linear above that point 
(Coles 2001, section 4.3.1). Among {cmd:extreme plot} types, {cmd:mrl} is anomolous in being available 
before estimation and, by the same token, requiring a 
{it:{help varname}} before the command line's main comma. The {it:{help numlist}} indicates at which 
thresholds the mean residual should be computed. If the {it:{help numlist}}
is omitted, all observed values of the variable
are used, which can be time-consuming in large data sets. If exactly two values are provided, 
these are taken as the minimum and maximum with 100 
steps in between; missing values for either bound are interpreted as the variable's minimum or 
maximum. Otherwise, the mean residual is computed only at the listed values.

{phang}{opt pp} plots modeled versus empirical cumulative distribution functions. If the model is 
a good fit, the plotted points should track closely to a 45-degree
line. See {manlink R diagnostic plots} and Coles (2001, section 3.3.5). The "empirical cumulative 
distribution function" is essentially the (weighted) share of the observations smaller or equal to
a given observation. E.g, if there are 99 observations, the values of the empirical cdf are 0.01, 
0.02...0.99. (This formulation avoids working with the empirical cdf to 0 or 1, which could
correspond to infinite values of the modeled variable.) The modeled cdf for each observation is 
computed using the estimated parameters. 

{phang}{opt qq} plots modeled versus empirical cumulative quantiles of the distribution of the modeled 
variable. Again, if the model fits well, the plotted points should follow a 45-degree
line. See {manlink R diagnostic plots} and Coles (2001, section 3.3.5). The empirical quantiles are 
just the values of the modeled variable, in order. The modeled quantiles result from
applying the inverse cumulative distribution function to "empirical cdf" values listed above, using 
the estimated parameters. For non-stationary models, the data are 
pre-transformed to the Gumbel distribution, as described in Coles (2001, section 6.2.3).

{phang}{opt ret:urn} requests a graph of the return level as a function of the return period, as 
predicted by the fitted model, and compares that to the pattern of extremes
in the data. See Coles (2001, section 3.3.5). E.g., if the model fit implies that a category 4 or 
higher hurricane occurs every 20 years, then one should appear in the data about
that often. Available for stationary models only.

{phang}{opt dens:ity} produces a plot comparing the modeled distribution to the actual distribution, the latter respresented by
superimposed dot and kernel density plots. Available for stationary models only.

{phang}{cmdab:xiprof:ile(}[{it:{help numlist}}]{cmd:)} requests a likelihood profile plot for the shape parameter xi. The model is 
repeatedly estimated with xi each time constrained 
to a different value. The
maximized (profile) log likelihood is plotted against xi. This can provide a more reliable 
basis for constructing confidence intervals. The coverage of the confidence interval
is controlled by the {cmdab:l:evel()} option. The derived confidence interval is stored in 
the matrix {cmd:e(xiprofileCI)}. The optional {it:{help numlist}} is parsed as with the
{cmd:mrl} option, except that missing values are not allowed. If the {it:{help numlist}} is omitted,
{cmd:extreme} will automatically choose endpoints for the search. Available only for models 
that are stationary in xi.

{phang}{cmdab:retprof:ile(}[{it:{help numlist}}]{cmd:,} {opt per:iod(#)}{cmd:)}, analogous to 
the previous option, requests a likelihood profile plot for the return level for a given
return period. The model is 
repeatedly estimated with the return level each time constrained to a different value. The
maximized (profile) log likelihood is plotted against the return level. The derived confidence 
interval is stored in the matrix {cmd:e(retprofileCI)}. The required 
suboption {opt per:iod(#)} specifies the return period. Available for stationary models only.

{phang}{cmdab:rateprof:ile(}[{it:{help numlist}}]{cmd:,} {opt ret:level(#)}{cmd:)} requests a 
likelihood profile plot for the return rate (reciprocal of return period), for a given return level. The model is 
repeatedly estimated with the return rate each time constrained to a different value. The
maximized (profile) log likelihood is plotted against the return level. The derived confidence 
interval is stored in the matrix {cmd:e(rateprofileCI)}. The required 
suboption {opt ret:level(#)} specifies the return magnitude. Available for stationary models only.

{phang}{it:graph_opts}: Most {help twoway_options:graph twoway options} for formatting plots can be added to {cmd:extreme plot} command lines
to override plot formatting defaults, from schemes, to fonts, to scaling, to labelling.

{phang}{it:kdens_opts}: When running the {opt dens:ity} plot, standard {help twoway kdensity} options may be included to tune the kernel regressions.

{title:predict syntax}

{pstd}Options for {help predict} after {cmd:extreme} are:

{synoptset 23 tabbed}{...}
{synoptline}
{synopt :{opt xb}}The default: linear prediction of mu, lnsig, or xi{p_end}
{synopt :{cmdab:eq:uation(}{cmd:#}{it:eqno}|{it:eqname}{cmd:)}}Equation for linear prediction; irrelavant for other statistics{p_end}
{synopt :{cmd:pr}}Probability density for each observation{p_end}
{synopt :{cmd:cdf}}Cumulative probability density{p_end}
{synopt :{cmd:ccdf}}Complementary cumulative probability density (1-cdf, return rate){p_end}
{synopt :{cmd:invccdf(}{it:#}|{it:varname}|{it:{help exp}}{cmd:)}}Inverse complementary cumulative probability density (return level) for return rate specified by a constant, variable, or expression{p_end}
{synoptline}

{title:Stored results}

{pstd}
{cmd:extreme} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations (2 for GPD, 3 for GEV){p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables (same){p_end}
{synopt:{cmd:e(converged)}}1 if converged, 0 otherwise{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in overall model test{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(chi2)}}statistic from overall model fit test{p_end}
{synopt:{cmd:e(p)}}associated {it:p} value{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(Nthresh)}}number of thresholds in {cmd:thresh()} option (for GPD){p_end}
{synopt:{cmd:e(Ndepvar)}}number of dependent variables (>1 for GEV with multiple order statistics){p_end}
{synopt:{cmd:e(zeta)}}fraction of potential sample exceeding threshold (for GPD){p_end}
{synopt:{cmd:e(stationary)}}0 if model has covariates (in {cmdab:muvars()}, {cmdab:sigvars()}, {cmdab:xivars()} options), 1 otherwise{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}"extreme"{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(muvars)}}content of {cmdab:muvars()} option, if any{p_end}
{synopt:{cmd:e(sigvars)}}content of {cmdab:sigvars()} option, if any{p_end}
{synopt:{cmd:e(xivars)}}content of {cmdab:xivars()} option, if any{p_end}
{synopt:{cmd:e(diparmopts)}}options passed to {cmd:ml display} when displaying results{p_end}
{synopt:{cmd:e(gumbel)}}"gumbel" if that option used{p_end}
{synopt:{cmd:e(model)}}model type (cmd:gpd} or {cmd:gev}{p_end}
{synopt:{cmd:e(depvar)}}modeled variable{p_end}
{synopt:{cmd:e(seed)}}initial pseudorandom number generator state, if bootstrap estimation{p_end}
{synopt:{cmd:e(chi2type)}}"Wald"{p_end}
{synopt:{cmd:e(opt)}}"moptimize"{p_end}
{synopt:{cmd:e(vce)}}{cmd:vce()} type{p_end}
{synopt:{cmd:e(title)}}title for results{p_end}
{synopt:{cmd:e(user)}}program to compute likelihood{p_end}
{synopt:{cmd:e(ml_method)}}{cmd:ml} optimization method (lf2){p_end}
{synopt:{cmd:e(technique)}}search technique{p_end}
{synopt:{cmd:e(which)}}max{p_end}
{synopt:{cmd:e(properties)}}b V{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}parameter vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the parameter estimates{p_end}
{synopt:{cmd:e(ilog)}}iteration log{p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(xiprofileCI)}}profile-based confidence interval for xi (after {cmd:extreme plot, xiprofile()}){p_end}
{synopt:{cmd:e(xiprofileplot)}}matrix containing coordinates of graphed profile for xi{p_end}
{synopt:{cmd:e(retprofileCI)}}profile-based confidence interval for return level (after {cmd:extreme plot, retprofile()}){p_end}
{synopt:{cmd:e(retprofileplot)}}matrix containing coordinates of graphed profile for return level{p_end}
{synopt:{cmd:e(rateprofileCI)}}profile-based confidence interval for return rate (after {cmd:extreme plot, rateprofile()}){p_end}
{synopt:{cmd:e(rateprofileplot)}}matrix containing coordinates of graphed profile for return rate{p_end}

{p2col 5 20 24 2: Function}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{marker examples}{...}
{title:Examples}

All examples are clickable.

{hilite:* Examples from Coles (2001), chapter 3}

{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/p/portpirie"}{p_end}
{phang}. {stata "extreme gev SeaLevel"}{p_end}
{phang}. {stata "extreme plot, xiprofile(-.3 .3) retprofile(4.15 4.6, period(10))"} // Figures 3.2, 3.3{p_end}
{phang}. {stata "extreme plot, retprofile(4.4 6, period(100)) pp qq return density"} // Figures 3.4, 3.5{p_end}
{phang}. {stata "est store GEV"} // save results for this unrestricted model{p_end}

{phang}. {stata "extreme gev SeaLevel, gumbel"} // impose Gumbel constraint (xi = 0){p_end}
{phang}. {stata "lrtest GEV"} // likelihood ratio test of Gumbel vs. unrestricted model: accepts restriction{p_end}
{phang}. {stata "extreme plot, pp qq return density"} // Figure 3.6{p_end}

{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/g/glass"}{p_end}
{phang}. {stata "gen negBreakingStrength = -BreakingStrength"}{p_end}
{phang}. {stata "extreme gev negBreakingStrength"}{p_end}
{phang}. {stata "extreme plot, pp qq return density"} // Figure 3.7{p_end}

{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/v/venice"}{p_end}
{phang}. {stata "extreme gev SeaLevel1"} // Table 3.1{p_end}
{phang}. {stata "extreme gev SeaLevel1-SeaLevel5"} // Table 3.1{p_end}
{phang}. {stata "extreme plot, pp qq return density"} // Figure 3.9{p_end}
{phang}. {stata "extreme gev SeaLevel1-SeaLevel10"} // Table 3.1: use 10 order stats, except only 6 availble for 1935{p_end}

{phang}. forvalues r=2/10 {c -(}{space 35} {it:(Click {stata "for R in numlist 2/10: extreme gev SeaLevel1-SeaLevelR \ extreme plot, return name(vR) nodraw title(r=R)":here} to run loop)}{p_end}
{phang}.   extreme gev SeaLevel1-SeaLevel`r'{p_end}
{phang}.   extreme plot, return name(v`r') nodraw title(r=`r'){p_end}
{phang}. {c )-}{p_end}
{phang}. {stata graph combine v2Return v3Return v4Return v5Return v6Return v7Return v8Return v9Return v10Return} // Figure 3.8{p_end}

{hilite:* Examples from Coles (2001), chapter 4}

{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/r/rain"}{p_end}
{phang}. {stata "extreme plot Rainfall, mrl(. .)"} // Figure 4.1{p_end}
{phang}. {stata "extreme gpd Rainfall, thresh(0(2.5)50)"} // Figure 4.2{p_end}
{phang}. {stata "extreme gpd Rainfall, thresh(30)"}{p_end}
{phang}. {stata "extreme plot, pp qq return density"} // Figure 4.3{p_end}
{phang}. {stata "nlcom Return100: `e(threshold)' + exp([lnsig]_cons)/[xi]_cons * ((365*100 * `e(zeta)')^[xi]_cons - 1)"} // conf. interval for 100-year return level{p_end}
{phang}. {stata "extreme plot, xiprofile(-.1 .6) retprofile(79 220, period(36500))"} // Figures 4.4, 4.5{p_end}

{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/d/dowjones"}{p_end}
{phang}. {stata "gen change = 100*ln(Index/Index[_n-1])"}{p_end}
{phang}. {stata "extreme plot change, mrl(-7 5)"} // Figure 4.6{p_end}
{phang}. {stata "extreme gpd change, thresh(2)"}{p_end}
{phang}. {stata "extreme plot, pp qq return density"} // Figure 4.7{p_end}

{hilite:* Examples from Coles (2001), chapter 6}

{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/p/portpirie"}{p_end}
{phang}. {stata "extreme gev SeaLevel"}{p_end}
{phang}. {stata "est store Stationary"}{p_end}
{phang}. {stata "extreme gev SeaLevel, muvar(Year)"} // add covariate Year to location equation{p_end}
{phang}. {stata "lrtest Stationary"} // LR test comparing it to stationary model{p_end}

{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/f/fremantle"}{p_end}
{phang}. {stata "replace Year = Year - 1896"} // code 1897 as 1{p_end}
{phang}. {stata "extreme gev SeaLevel"} // stationary model{p_end}
{phang}. {stata "est store Stationary"}{p_end}
{phang}. {stata "extreme gev SeaLevel, muvar(Year)"} // add covariate Year to location equation{p_end}
{phang}. {stata "predict muhat"}{p_end}
{phang}. {stata "scatter SeaLevel Year || line muhat Year"} // Figure 6.1{p_end}
{phang}. {stata "lrtest Stationary"} // LR test comparing it to stationary model{p_end}
{phang}. {stata "est store muYear"}{p_end}
{phang}. {stata "extreme plot, pp qq"} // Figure 6.2{p_end}
{phang}. {stata "extreme gev SeaLevel, muvar(SOI)"} // add covariate Southern Oscillation Index to location equation{p_end}
{phang}. {stata "extreme gev SeaLevel, muvar(Year SOI)"} // add Year back too{p_end}
{phang}. {stata "lrtest muYear"} // LR test comparing this to Year-only model{p_end}

{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/v/venice"}{p_end}
{phang}. {stata "extreme gev SeaLevel*, muvar(Year)"}{p_end}
{phang}. {stata "predict muhat"}{p_end}
{phang}. {stata "scatter SeaLevel* Year, pstyle(p1...) msize(vsmall...) || line muhat Year, legend(off)"} // Figure 6.5{p_end}

{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/r/rain"}{p_end}
{phang}. {stata "gen time = _n"}{p_end}
{phang}. {stata "extreme gpd Rainfall, thresh(30) sigvar(time)"} // model log sigma = beta_0 + beta_1*time{p_end}
{phang}. {stata "extreme plot, pp qq"} // Figure 6.7	{p_end}

{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/w/wooster"}{p_end}
{phang}. {stata "gen negTemperature = -Temperature"}{p_end}
{phang}. {stata "gen byte Season = mod(floor((Day+30)/(365.25/4)),4)+1"} // seasons definition?{p_end}
{phang}. {stata "mat threshmat = -10, -25, -50, -30"} // Coles seasonal thresholds{p_end}
{phang}. {stata "gen threshvar = threshmat[1,Season]"}{p_end}
{phang}. {stata "bysort Season: extreme gpd negTemperature, thresh(threshvar)"} // separate model for each season{p_end}
{phang}. {stata "extreme gpd negTemperature, thresh(threshvar) sigvar(ibn.Season, nocons)"} // combined model with single shape parameter{p_end}

{hilite:* Other examples}

{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/p/portpirie"}{p_end}
{phang}. {stata "extreme gev SeaLevel"}{p_end}
{phang}. {stata "extreme plot, xiprofile(-.3 .3) retprofile(4.15 4.6, period(10)) rateprofile(.05 .3, retlevel(4.2))"}{p_end}
{phang}. {stata "mat list e(xiprofileCI)"} // programmatically extract profile-based confidence interval for xi{p_end}
{phang}. {stata "mat list e(retprofileCI)"} // programmatically extract profile-based confidence interval for return level{p_end}
{phang}. {stata "mat list e(rateprofileCI)"} // programmatically extract profile-based confidence interval for return rate{p_end}
{phang}. {stata "extreme plot, qq scheme(s1rcolor) aspect(1) title(Quantile-quantile plot) xtitle(Modeled sea level quantile)"} // Q-Q plot with altered appearance{p_end}
{phang}. {stata "extreme gev SeaLevel, muvar(Year) small(cs)"} // Cox-Snell bias correction for non-stationary GEV model{p_end}
{phang}. {stata "extreme gev SeaLevel, muvar(Year) small(cs) vce(bs, reps(100))"} // Same, with bootstrapped standard errors{p_end}
{phang}. {stata "extreme gev SeaLevel, muvar(Year) small(bs, reps(200))"} // Parametric-bootstrap-based bias correction and standard errors{p_end}
{phang}. {stata "predict mypr, pr"} // Predict probability densities{p_end}
{phang}. {stata "predict myretlevel, invccdf(1/100)"} // Predict 100-year SeaLevel value, as modeled function of Year{p_end}

{title:References}

{p 4 8 2}Coles, S. 2001. {it:An introduction to statistical modeling of extreme values}. Springer.{p_end}
{p 4 8 2}Cordeiro, G., and F. Cribaro-Neto. 2014. Analytical and bootstrap bias correctlions. In {it:Introduction to Bartlett Correction and Bias Reduction}. Springer.{p_end}
{p 4 8 2}Cox, D.R, and E.J. Snell. 1968. A general definition of residuals. {it:Journal of the Royal Statistical Society. Series B}.{p_end}
{p 4 8 2}Giles, D.A., H. Feng, and R.T. Godwin. 2015. Bias-corrected maximum likelihood estimation of the parameters of the generalized Pareto
distribution. {it:Communications in Statistics - Theory and Methods}.{p_end}
{p 4 8 2}Horwitz, J.L. 2001. The bootstrap. {it:Handbook of Econometrics}. Elsevier Science.{p_end}
{p 4 8 2}Roodman, D. 2017. Bias and size corrections in extreme value modeling. {it:Communications in Statistics - Theory and Methods}. DOI: 10.1080/03610926.2017.1353630.{p_end}

{title:Author}

{p 4}David Roodman{p_end}
{p 4}david@davidroodman.com{p_end}

