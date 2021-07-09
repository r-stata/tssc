{smcl}
{* *! version 1.0.0  17june2014}{...}
{cmd:help mqgamma}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:mqgamma} {hline 2}}Marginal quantile estimation{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{opt mqgamma} {it:depvar} [{it:indeps}] {ifin} 
{cmd:,}  [{cmd:quantile(}{it:numlist}{cmd:)} {cmd:lns(}{it:varlist}{cmd:)}
{cmd:fail(}{it:varname}{cmd:)} {cmdab:aeq:uations} 
{cmd:from(}{it:matrix}{cmd:)} {it:display options}
]


{marker description}{...}
{title:Description}

{pstd}{cmd:mqgamma} estimates marginal quantiles for the potential outcome
corresponding to each treatment level from censored observational data in
which the dependent variable is inherently positive, such as time-to-event
data and health-expenditure data.  Differences in these marginal quantiles
are quantile treatment effects.

{it:mqgamma} fits a two-parameter gamma distribution the conditional
distributions from which the marginal distributions are subsequently
estimated by regression adjustment.

{pstd}Drukker (2014) derives the implemented estimator and provides an
introduction to this command.

{marker options}{...}
{title:Options}

{phang}{cmd:treat(}{it:varname}{cmd)} is a required option and it specifies
the binary treatment variable. The treatment variable must be coded 0 for
control cases and 1 for treated cases.

{phang}{cmd:quantile(}{it:numlist}{cmd:)} specifies the marginal quantiles
to estimated.  Each specified quantile must be in {cmd:(0,1)}.

{phang}{cmd:lns(}{it:varlist}{cmd:)} specifies the variables used to model
the natural log of the scale.  See the Methods and Formulas section of
Drukker (2014) for details.

{phang}{cmd:fail(}{it:varname}{cmd:)} specifies the binary failure indicator
which must be coded {cmd:1} for an observed value and {cmd:0} for a censored
observation.

{phang}{cmd:aequations} specifies that the auxiliary-equation parameters
should be displayed.

{phang}{cmd:from(}{it:matrix}{cmd:)} specifies a row vector of initial
values for the optimization routine. Each element in the specified matrix
specifies the initial value for the corresponding parameter.

{phang}{it:display options} are the standard display options.  See 
{help estimation options##display_options:estimation options}


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use exercise}{p_end}

{pstd}Medians of potential outcomes estimation{p_end}
{phang2}{cmd:. mqgamma t active, treat(exercise) fail(fail) lns(health)}{p_end}

{pstd}QTE(.25) and QTE(.75) estimation{p_end}
{phang2}{cmd:. mqgamma t active, treat(exercise) fail(fail) lns(health) quantile(.25 .75)}{p_end}
{phang2}{cmd:. nlcom (_b[q25_1:_cons] - _b[q25_0:_cons]) (_b[q75_1:_cons] - _b[q75_0:_cons])}{p_end}




{title:References}
{phang}Drukker, D. M. 2014. Quantile treatment effect estimation from
censored data by regression adjustment.  Working paper, submitted to the
Stata Journal.
{browse "http://www.stata.com/ddrukker/mqgamma.pdf":pdf paper}

