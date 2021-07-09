{smcl}
{* *! version 1.0.1  28nov2012}{...}
{viewerjumpto "Syntax" "poparms##syntax"}{...}
{viewerjumpto "Description" "poparms##description"}{...}
{viewerjumpto "Options" "poparms##options"}{...}
{viewerjumpto "Examples" "poparms##examples"}{...}
{viewerjumpto "Saved results" "poparms##saved_results"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :}Potential outcome parameter estimation{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{opt poparms} ({it:treatvar} {it:gpsvars}) ({it:depvar} {it:cvars}) {ifin} 
[{cmd:,} {it:options}]

{synoptset 28 tabbed}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt quant:iles}({it:numlist})}estimate specified quantiles{p_end}

{synopt :{opt vce:}(vcetype [, {it:vceoptions}])}{it:vcetype} may be 
	{opt bootstrap}, {opt analytic},  or {opt none}.{p_end}
{p 34 34 2}{opt analytic} is the default when {opt quantiles()} is not 
specified.  {opt bootstrap} is the default when {opt quantiles()} is 
specified.{p_end}
{p 34 34 2}{it:vceoptions} vary over {it:vcetype} and are discussed
below.{p_end}

{synopt :{opt ipw}}use inverse-probability-weighted (IPW) estimator instead
of default efficient-influence-function (EIF) estimator

INCLUDE help shortdes-coeflegend

{synoptline}
{p2colreset}{...}
{p 4 6 2}{it:gpsvars} and {it:cvars} may
contain time-series operators; see {help fvvarlist}.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:poparms} estimates parameters of the potential-outcome distributions in
causal inference.  

{pstd}
The estimators implemented in {cmd:poparms} were derived in 
{browse "http://www.sciencedirect.com/science/article/pii/S030440760900236X":Cattaneo(2010)}.
{browse " http://www-personal.umich.edu/~cattaneo/papers/Cattaneo-Drukker-Holland_2012_STATA.pdf":Cattaneo, Drukker, and Holland (2012)} 
provides an introduction to this command.


{marker options}{...}
{title:Options}

{phang}
{cmd:quantiles()} specifies the quantiles of the potential outcome
distributions that are to be estimated jointly with the means.  By default,
only the means are estimated.  By default, method {cmd:vce(bootstrap)} is
used when {cmd:quantiles()} is specified.  We strongly recommend not using
{cmd:vce(analytic)} when {cmd:quantiles()} is specified.

{phang}
{cmd:vce()} specifies the method used to estimate the variance-covariance of
the estimator.

{p 8 10 2}{cmd:vce:(}{it:vcetype} [, {it:vceoptions}])} specifies the
{it:vcetype} and the type specific options.

{p 10 12 2}When specifying {cmd:vce(bootstrap)}, the {it:vceoption} is
{it:reps(#)} which specifies the number of bootstrap repetitions which must
be integer that is at least 50.

{p 10 12 2}
With method {cmd:analytic}, the {it:vceoptions} are 
{cmd:bwscale(}{it:#}{cmd:))}, {cmd:bwidths(}{it:matname}{cmd:)}, and 
{cmd:densities(}{it:matname}{cmd:)}.  These suboptions are mutually
exclusive.  

{p 10 12 2}
By default, {cmd:poparms} uses an analytic estimator when only
means are estimated and it uses a bootstrap estimator when quantiles are
estimated.  We recommend not using the analytic method when quantiles are
specified because this method performed poorly in Monte Carlo simulations.

{p 12 14 2}
With method {cmd:bootstrap}, you may change the number of repetitions from 
the default 2000 by specifying {cmd:vce(bootstrap , reps(}{it:#}{cmd:))}.
The specified number of repetitions must an integer greater than 49.

{p 12 14 2}
With method {cmd:analytic}, you may rescale the bandwidths used to
estimate the densities by specifying 
{cmd:vce(analytic, bwscale(}{it:#}{cmd:))}.
The specified number must be in the interval [.1, 10].

{p 12 14 2}
With method {cmd:analytic}, you may specify the bandwidths used to
estimate the densities by specifying 
{cmd:vce(analytic, bwidths(}{it:matname}{cmd:))}, where {it:matname}
specifies a Stata row vector with the number of columns equal to the number
of quantiles times the number of treatment levels.

{p 12 14 2}
With method {cmd:analytic}, you may specify the densities used 
{cmd:vce(analytic, densities(}{it:matname}{cmd:))}, where {cmd:matname}
specifies a Stata row vector with the number of columns equal to the number
of quantiles times the number of treatment levels.

{phang}
{cmd:ipw} specifies that {cmd:poparms} use the IPW estimator instead
of the default EIF estimator.  The methods and differences are described
in 
{browse " http://www-personal.umich.edu/~cattaneo/papers/Cattaneo-Drukker-Holland_2012_STATA.pdf":Cattaneo, Drukker, and Holland (2012)}.

{phang}
{opt coeflegend}; see
     {helpb estimation options##coeflegend:[R] estimation options}.


{marker examples}{...}
{title:Examples}

    {hline}
    Setup
{phang2}{cmd:. use spmdata}{p_end}

{pstd}Mean estimation{p_end}
{phang2}{cmd:. poparms (w pindex eindex) (spmeasure pindex eindex)}{p_end}

{pstd}Mean estimation with polynomial for conditional mean{p_end}
{phang2}{cmd:. poparms (w pindex eindex) (spmeasure c.(pindex eindex)#c.(pindex eindex))}{p_end}

{pstd}Mean and quantile estimation with polynomial for conditional
mean{p_end}
{p 8 8 2}This example limits the number of of bootstrap repetitions to 50 so
that the example runs relatively quickly.  We recommend using at least the
default of 2000 repetitions in practice.{p_end}

{phang2}{cmd:. poparms (w pindex eindex) (spmeasure c.(pindex eindex)#c.(pindex eindex)), quantiles(.25 .75) vce(bootstrap, reps(50))}{p_end}

{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:poparms} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of variables in conditional mean{p_end}
{synopt:{cmd:e(bwscale)}}scale for bandwidths, if specified{p_end}
{synopt:{cmd:e(reps)}}number of requested bootstrap repetitions, if specified}{p_end}
{synopt:{cmd:e(bsreps)}}number of successful bootstrap repetitions, if specified}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:poparms}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(title2)}}second title in estimation output{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(quantiles)}}specified quantiles{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V} or {cmd:b} if {cmd:vce(none)}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(V1)}}outer product Psi functions used in variance{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:References}

{phang}
Cattaneo, M. D. 2010.  Efficient Semiparametric Estimation of Multi-valued
Treatment Effects under Ignorability. Journal of Econometrics 155(2):
138-154.
{browse "http://www.sciencedirect.com/science/article/pii/S030440760900236X"}

{phang}
Cattaneo, M. D., D. M. Drukker, and A. Holland. 2012.
Estimation of multivalued treatment effects
under conditional independence.
Working paper, University of Michigan, Department of Economics,
{browse " http://www-personal.umich.edu/~cattaneo/papers/Cattaneo-Drukker-Holland_2012_STATA.pdf"}.


{title:Authors}

{phang}
Matias D. Cattaneo, University of Michigan, Ann Arbor, MI.
{browse "mailto:cattaneo@umich.edu":cattaneo@umich.edu}.

{phang}
David M. Drukker, StataCorp, College Station, TX.
{browse "mailto:ddrukker@stata.com":ddrukker@stata.com}.

{phang}
Ashley D. Holland, Grace College, Winona Lake, IN.
{browse "mailto:hollana@grace.edu":hollana@grace.edu}.
