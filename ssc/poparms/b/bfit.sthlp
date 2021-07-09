{smcl}
{* *! version 1.0.0  24aug2012}{...}
{viewerjumpto "Syntax" "bfit##syntax"}{...}
{viewerjumpto "Description" "bfit##description"}{...}
{viewerjumpto "Options" "bfit##options"}{...}
{viewerjumpto "Examples" "bfit##examples"}{...}
{viewerjumpto "Saved results" "bfit##saved_results"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :}Best fit model selection{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:bfit regress} {it:depvar} {it:indepvars} {ifin} 
[{cmd:,} {cmd:corder(}{it:#}{cmd:)} {cmd:sort(}{cmd:bic}|{cmd:aic}{cmd:)}
{it:options}]

{p 8 15 2}
{cmd:bfit logit}  {it:depvar} {it:indepvars} {ifin} 
[{cmd:,} {cmd:corder(}{it:#}{cmd:)} {cmd:sort(}{cmd:bic}|{cmd:aic}{cmd:)}
{it:options}]

{p 8 15 2}
{cmd:bfit poisson} {it:depvar} {it:indepvars} {ifin} 
[{cmd:,} {cmd:corder(}{it:#}{cmd:)} {cmd:sort(}{cmd:bic}|{cmd:aic}{cmd:)}
{it:options}]

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

INCLUDE help shortdes-coeflegend
{synoptline}
{p2colreset}{...}
{p 4 6 2}{it:gpsvars} and {it:cvars} may
contain time-series operators; see {help fvvarlist}.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:bfit} {it:subcmd} sorts a set of fitted candidate regression models by
an information criterion, puts the best-fitting model in {cmd:ereturn}, and
displays a table showing the ranking of the models fitted. The Bayesian
information criterion (BIC) is the default and the Akaike information
criterion (AIC) may optionally be specified as the ranking criterion.

{pstd}
{cmd:bfit} {it:subcmd} sorts a set of fitted candidate regression models by
{cmd:bfit regress} fits the candidate linear-regression models by ordinary
least squares. {cmd:bfit mlogit} fits the candidate mulitinomial-logit
models by maximum likelihood. {cmd:bfit poisson} fits the candidate poisson
regression models by maximum likelihood.

{pstd}
{cmd:bfit} {it:subcmd} sorts a set of fitted candidate regression models by
For each {it:subcmd}, the candidate models are a series of polynomials in
{it:indepvars}. The smallest of the candidate models includes only the
first variable specified in {it:indepvars}. The largest of the candidate
models is a fully-interacted polynomial of the order specified in 
{cmd:corder()}. See {cmd:Methods and formulas} in !! for details on the set
of candidate models.

{pstd}
{browse " http://www-personal.umich.edu/~cattaneo/papers/Cattaneo-Drukker-Holland_2012_STATA.pdf":Cattaneo, Drukker, and Holland (2012)} 
provides an introduction to this command.

{marker options}{...}
{title:Options}

{phang}
{cmd:{ul:cord}er(}{it:#}{cmd:)} specifies the maximum order of the covariate
polynomial. The default is 2 which specifies a fully-interacted second-order
polynomial.

{phang}
{cmd:sort()} specifies the information criterion by which the candidate
models are to be sorted. {cmd:sort(bic)}, the default, sorts the fitted
candidate models by the Bayesian information criterion. {cmd:sort(aic)}
sorts the fitted candidate models by the Akaike information criterion.

{phang}
{it:coptions} are passed to the estimation command. The allow options depend
on the estimation command invoked by the {it:subcommand}. For example, 
{it:base()} may be specified only the with {cmd:logit} subcommand.  See
{help regress}, {help mlogit}, and {help poisson} for the allowable command
options.


{marker examples}{...}
{title:Examples}

    {hline}
    Setup
{phang2}{cmd:. use spmdata}{p_end}

{pstd}Model selection with logit{p_end}
{phang2}{cmd:. bfit logit w pindex eindex}{p_end}

{pstd}Model selection with logit up to a third-order model{p_end}
{phang2}{cmd:. bfit logit w pindex eindex, corder(3)}{p_end}

{pstd}Model selection with logit, and AIC selection{p_end}
{phang2}{cmd:. bfit logit w pindex eindex, sort(aic)}{p_end}

{pstd}Model selection with regress{p_end}
{phang2}{cmd:. bfit regress spmeasure pindex eindex}{p_end}

{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:bift} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(subcmd)}}{cmd:regress}, {cmd:logit}, or {cmd:poisson}{p_end}
{synopt:{cmd:r(bmodel)}}Name of selected model in {cmd:estimates store}{p_end}
{synopt:{cmd:r(bvlist)}}Variables in selected model{p_end}
{synopt:{cmd:r(sortby)}}{cmd:bic} or {cmd:aic}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(S)}}Results for each model fit{p_end}

{p 4 4 2}The matrix {cmd:r(S)} has 7 columns with the following model-specific information
in each row:{p_end}
{p 8 10 2}Column 1 contains the names of the model in {cmd:estimates store}{p_end}
{p 8 10 2}Column 2 contains the number of observations in the sample{p_end}
{p 8 10 2}Column 3 contains the value of the log-likelihood function for the 
constant-only model{p_end}
{p 8 10 2}Column 4 contains the value of the log-likelihood function{p_end}
{p 8 10 2}Column 5 contains the degrees of freedom in the model{p_end}
{p 8 10 2}Column 6 contains the AIC{p_end}
{p 8 10 2}Column 7 contains the BIC{p_end}


{title:References}

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

