
{smcl}
{* *! version 2.0 05may2021}{...}
{viewerdialog masum "dialog masum"}{...}


{marker syntax}{...}

{title:Syntax}

{phang}
Basic fixed- and random-effects inverse-variance weighted meta-analysis.

{p 8 16 2}
{cmd:masum} {effectsizevar}  {ifin} {cmd:,}
{opt var(varname)}
{opt w(varname)}
{opt se(varname)}
[_options_]

{pstd} where {it:effectsize} is the effect size variable. The
{it:effect size} can be any effect size type, such as Cohen's {it:d},
Hedges' {it:g}, logged odds ratio, logged risk ratio, logged logit,
{it:r} or Fisher's {it:Zr}, among others. It is critical that the
effect size is in its analyzable form. For example, the effect size
can be a logged odds ratio but not an odds ratio. One of the following
must also be specified:

{phang2}
o  {it:var({varname})}: the variance of the effect size

{phang2}
o  {it:w({varname})}: the inverse variance weight of the effect size

{phang2}
o  {it:se({varname})}: the standard error of the effect size

{pstd} The relationship among these is assumed to be {it:w} =
1/{it:var} = 1/{it:se^2}.  {p_end}


{marker reoptions}{...}
{synoptset 20 tabbed}{...}
{synopthdr :Options}
{synoptline}
{syntab:Model Type}
{synopt :{opt model(_string_)}}
 model type; default is REML (restricted maximum likelihood); options
 include FE (fixed effect), DL (Dersimonian & Laird), HE (Hedges), HS
 (Hunter & Schmidt), SJ (Sidik-Jonkman), SJIT (Sidik-Jonkman,
 iterative), ML (maximum likelihood), REML (restricted maximum
 likelihood), and EB (empirical bayes)
{p_end}

{syntab:Print Options}
{synopt :{opt print(_string_)}}
print options convert results for ease of interpretation; {it:exp}
exponentiates results, {it:ivzr} is the inverse Fisher's {it:z} transformation,
producing {it:r}, and {it:prop} converts logits back into proportions
{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:masum} performs a meta-analysis under either a fixed-effect model
(also called a common-effect model) or a random-effects model. Several
estimators for the random effects variance component (tau^2) are
available.  The command requires an effect size and its associated
standard error, variance, or inverse variance weight.

{pstd} Meta-analytic regresson (aka, meta-regression) can be performed
with the {cmd:mareg} command (see {help mareg}). Subgroup or
categorical moderator analysis (i.e., analog-to-the-ANOVA) can be
performed with the {cmd:maanova} command (see {help maanova}).

{pstd}
As of Stata version 16.0, Stata has a built-in command for conducting
meta-analysis. See {help meta}.

{marker description}{...}
{title:Acknowledgments}

{pstd} {cmd:masum} was written by David B. Wilson and is an updated
version of a command written as a companion to a book on meta-analysis
he co-authored with Mark Lipsey (Lipsey & Wilson, 2001). Portions of
this program are based on code from Wolfgang Viechtbauer's
{it:metafor} package for R.

{marker description}{...}
{title:References}

{pstd}
Lipsey, M. W., & Wilson, D. B. (2001). {it} Practical
meta-analysis. {sf} Sage.


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:masum} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(mean)}}mean effect size{p_end}
{synopt:{cmd:r(tau2)}}random effects variance component{p_end}

