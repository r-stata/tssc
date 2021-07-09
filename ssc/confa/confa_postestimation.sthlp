{smcl}
{* *! version 1.1.13  04jun2007}{...}
{hline}
help for {cmd:confa} postestimation{right:author: {browse "http://stas.kolenikov.name/":Stas Kolenikov}}
{right:also see: {help confa}, {help bollenstine}}
{hline}

{title:Postestimation tools for confa}

{pstd}The following commands are available after {help confa}:{p_end}

{synoptset 17}{...}
{p2coldent :command}description{p_end}
{synoptline}
{synopt :{helpb confa_estat##fit:estat fitindices}}fit indices{p_end}
{synopt :{helpb confa_estat##fit:estat aic}}AIC{p_end}
{synopt :{helpb confa_estat##fit:estat bic}}BIC{p_end}
{synopt :{helpb confa_estat##corr:estat correlate}}correlations of factors and measurement errors{p_end}
{synopt :{helpb confa_estat##predict:predict}}factor scores{p_end}
{synoptline}
{p2colreset}{...}

{title:Special interest postestimation commands}

{pstd}These commands provide some additional post-estimation output.

{marker corr}{...}
{pstd}{opt estat }{cmdab:corr:elate} transforms the covariance parameters
     into correlations for factor covariances and measurement error covariances.
     The delta method standard errors are given; for correlations close to
     plus or minus 1, the confidence intervals may extend beyond the range of
     admissible values. Additional options are allowed:{p_end}
     {phang2}{cmd:level(}{it:#}{cmd:)} specifies the CI level{p_end}
     {phang2}{cmd:bound} provides an alternative CI based on Fisher's {it:z}-transform
            (arctanh) of the correlation coefficient. It guarantees that the
            end points of the interval are in (-1,1) range, which may not
            produce desirable results for Heywood cases.{p_end}

{marker fit}{...}
{pstd}{opt estat aic} and {opt estat bic} compute the Akaike and Schwarz Bayesian
     information criteria.

{pstd}{opt estat }{cmdab:fit:indices} computes, prints, and saves into {cmd:r()} results
a number of traditional fit indices. The following options of {cmd: estat fitindices}
request specific indices:

{synoptset 17}{...}
{p2coldent :option}fit index{p_end}
{synoptline}
{synopt :{opt aic}}AIC, Akaike information criteria{p_end}
{synopt :{opt bic}}BIC, Schwarz Bayesian information criteria{p_end}
{synopt :{opt rmsea}}RMSEA, root mean squared error of approximation{p_end}
{synopt :{opt rmsr}}RMSR, root mean square residual{p_end}
{synopt :{opt tli}}TLI, Tucker-Lewis index{p_end}
{synopt :{opt cfi}}CFI, comparative fit index{p_end}
{synopt :{opt _all}}all of the above indices, the default{p_end}
{synoptline}
{p2colreset}{...}



{marker predict}{...}
{title:Syntax for predict}

{p 8 19 2}
{cmd:predict} {dtype} {it:{help newvarlist}} {ifin} [{cmd:,} {it:scoring_method}]

{cmd:predict} can be used to create factor scores following {cmd:confa}.
The number of variables in {it:newvarlist} must be the same as the
number of factors in the model specification; all factors
are predicted at once by the relevant matrix formula, anyway.
The following methods are supported:

{synoptset 17}{...}
{p2coldent :option}factor scoring method{p_end}
{synoptline}
{synopt :{cmdab:reg:ression}}regression, or empirical Bayes, score{p_end}
{synopt :{cmdab:emp:iricalbayes}}alias for {cmd:regression}{p_end}
{synopt :{cmdab:eb:ayes}}alias for {cmd:regression}{p_end}
{synopt :{opt mle}}MLE, or Bartlett score{p_end}
{synopt :{cmdab:bart:lett}}MLE, or Bartlett score, alias for {cmd:mle}{p_end}
{synoptline}
{p2colreset}{...}

{marker bs}{...}
{title:Bollen-Stine bootstrap}

{phang}{cmd:bollenstine, }{cmdab:r:eps(}{it:#}{cmd:) }
{cmdab:sav:ing(}{it:filename}{cmd:) }
{cmdab:confaopt:ions(...) }
{it:bootstrap_options}
{p_end}

{p}{cmd:bollenstine} performs Bollen and Stine (1992) bootstrap.
The original data are rotated to conform to the fitted structure.
By default, {cmd:bollenstine} re-estimates the model
with rotated data, and uses the estimates as
starting values in each bootstrap iterations. It also rejects samples
where convergence was not achieved (implemented through
{cmd:reject( e(converged) == 0)} option supplied to
{helpb bootstrap}).


{p}The following options are supported:

{phang}{cmdab:r:eps(}{it:#}{cmd:)} specifies the number of bootstrap replications.
The default is 200.{p_end}

{phang}{cmdab:sav:ing(}{it:filename}{cmd:)} specifies the file
where the simulation results (the parameter estimates and the fit statistics)
are to be stored. The default is a temporary file that will
be deleted as soon as {cmd:bollenstine} finishes.{p_end}

{phang}{cmdab:confaopt:ions(...)} allows to transfer options
to {helpb confa}. Some bootstrap replications produce non-convergent
samples that may never converge, so in order to speed up computations,
it might make sense to limit the number of iterations, say
with {cmd:confaoptions( iter(20) )}.{p_end}

{phang}{bf}All non-standard model options, like unitvar or correlated, must be specified with
bollenstine to produce correct results!{sf}

{phang}All other options are assumed to be {it:bootstrap_options}
and passed through to {helpb bootstrap}.

{title:Example}

{phang2}{cmd:. use http://web.missouri.edu/~kolenikovs/stata/hs-cfa.dta, clear}{p_end}
{phang2}{cmd:. confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(iv) corr(x7:x8)}{p_end}
{phang2}{cmd:. estat fit}{p_end}
{phang2}{cmd:. estat corr}{p_end}
{phang2}{cmd:. estat corr, bound}{p_end}
{phang2}{cmd:. predict fa1-fa3, reg}{p_end}
{phang2}{cmd:. predict fb1-fb3, bart}{p_end}

{title:Also see}

{psee}Online: {helpb confa}, {helpb bollenstine}.{p_end}

{title:References}

{phang}{bind:}Bollen, K. and Stine, R. (1992)
Bootstrapping Goodness of Fit Measures in Structural
Equation Models. {it:Sociological Methods and Research}, {bf:21}, 205--229.
{p_end}


{title:Contact}

Stas Kolenikov, kolenikovs {it:at} missouri.edu
