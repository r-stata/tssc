{smcl}
{* *! version 1.3  28Oct2008}{...}
{hline}
help for {cmd:bollenstine} {right:author: {browse "http://stas.kolenikov.name/":Stas Kolenikov}}
{right:also see: {help cfa}, {help cfa_estat:cfa postestimation}}
{hline}

{title:Bollen-Stine bootstrap following confirmatory factor analysis}

{phang}{cmd:bollenstine, }{cmdab:r:eps(}{it:#}{cmd:) }
{cmdab:sav:ing(}{it:filename}{cmd:) }
{cmdab:cfaopt:ions(...) }
{it:bootstrap_options}
{p_end}

{p}{cmd:bollenstine} performs Bollen and Stine (1992) bootstrap
following structural equation models (confirmatory factor analysis) estimation.
The original data are rotated to conform to the fitted structure.
By default, {cmd:bollenstine} re-estimates the model
with rotated data, and uses the estimates as
starting values in each bootstrap iterations. It also rejects samples
where convergence was not achieved (implemented through
{cmd:reject( e(converged) == 0)} option supplied to
{helpb bootstrap}).


{title:Options}

{phang}{cmdab:r:eps(}{it:#}{cmd:)} specifies the number of bootstrap replications.
The default is 200.{p_end}

{phang}{cmdab:sav:ing(}{it:filename}{cmd:)} specifies the file
where the simulation results (the parameter estimates and the fit statistics)
are to be stored. The default is a temporary file that will
be deleted as soon as {cmd:bollenstine} finishes.{p_end}

{phang}{cmdab:cfaopt:ions(...)} allows to transfer options
to {helpb cfa}. Some bootstrap replications may result in
samples in which iterative maximization never converges,
so in order to speed up computations,
it might make sense to limit the number of iterations, say
with {cmd:cfaoptions( iter(20) )}.{p_end}

{phang}{bf}All non-standard model options, like {it:unitvar} or {it:correlated}, must be specified with
bollenstine to produce correct results!{sf}

{phang}All other options are assumed to be {it:bootstrap_options}
and passed through to {helpb bootstrap}.

{title:Example}

{phang2}{cmd:. use http://web.missouri.edu/~kolenikovs/stata/hs-cfa.dta, clear}{p_end}
{phang2}{cmd:. cfa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(iv) corr(x7:x8)}{p_end}
{phang2}{cmd:. set seed 10101}{p_end}
{phang2}{cmd:. bollenstine, reps(200) cfaoptions( iter(20) corr( x7:x8 ) )}


{title:Also see}

{psee}Online: {helpb cfa}, {helpb cfa_estat:cfa postestimation}, {helpb bootstrap}.{p_end}

{title:References}

{phang}{bind:}Bollen, K. and Stine, R. (1992)
Bootstrapping Goodness of Fit Measures in Structural
Equation Models. {it:Sociological Methods and Research}, {bf:21}, 205--229.
{p_end}


{title:Contact}

Stas Kolenikov, kolenikovs {it:at} missouri.edu
