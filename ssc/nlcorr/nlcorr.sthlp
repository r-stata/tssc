{smcl}
{* Juli 21, 2011 @ 10:16:07 UK}{...}
{hi:help nlcorr} 
{hline}

{title:Title}

{phang}
{cmd:nlcorr}  Correlation metric for cross-sample comparisons using non-linear probability models
{p_end} 

{title:Syntax}

{pstd}
Syntax 1: As post estimation command

{p 8 17 2}
{cmd:nlcorr}

{pstd}
Syntax 2: As stand alone command 

{p 8 17 2}
   {cmd: nlcorr}
   {it: model-type}
   {depvar}
   {varlist}
   {ifin}
   {cmd:,} {opt o:ver(varname [, subpop])}
   [
   {it: options}
   ]
{p_end}

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :required}
{synopt:{opt o:ver(varname [, subpop] )}}over groups{p_end}
{syntab :optional}
{synopt:{opt b:asecategory(num)}}base category for comparison{p_end}
{synopt:{opt altout}}alternative output{p_end}
{synopt:{opt clear}}keep results in memory{p_end}
{synoptline}
{p2colreset}{...}


{pstd} {it:model-type} can be any of {help logit}, {help ologit},
{help probit}, and {help oprobit}.{p_end}

{pstd}{it:depvar} is the name of the dependent variable, and
{it:varlist} is a varlist holding the name(s) of independent
variables.{p_end}

{pstd}{help fvvarlist:Factor variables} are allowed to the extend that
the "i." construct can be used. Specification of interaction terms
are, however, not allowed. {p_end}


{title:Description}

{pstd}The program estimates the (partial) correlation between the
predictor variable(s) of a model and the latent variable, y*, assumed
to underlie an discrete outcome. This correlation metric, developed by
Breen, Karslon, and Holm (2011), can be used to draw cross-group
comparisons based on non-linear probability models in a range
situations met in applied research.  The program also calculates the
standard error of the Fisher transformed correlations, obtained by the
delta method (see Breen, Karlson, and Holm 2011).{p_end}

{pstd} The derivations and interpretation of the correlation metric
are given in Breen, Karlson, and Holm (2011). They show how logit and
probit coefficients, often interpreted in terms of underlying linear
regression coefficients identified up to scale, can be interpreted in
terms of correlation coefficients.{p_end}

{pstd} Let b denote a logit or probit coefficient of a predictor, x,
in a logit or probit model with binary y as the outcome variable,
hypothesized to be a discrete realization of an underlying propensity,
y*:{p_end}

{center:b = beta/s}

{pstd} where beta is a regression coefficient from the linear model
underlying the logit or probit model, and s is a scale parameter,
which is a function of the conditional error variance of the
underlying linear model. Breen, Karlson, and Holm (2011) show that b
may be rewritten as{p_end}

{center:b = r/sqrt(1-r^2) * sd(w)/sd(x)}

{pstd}where r is the correlation between the predictor variable, x,
and the latent outcome, y*, assumed to underlie the binary variable y
(a measure of the biserial correlation), sd(w) is a constant, the
standard deviation of the standard normal or standard logitistic
distribution (1 for the probit and pi/sqrt(3) for the logit), and
sd(x) is the standard deviation of x. This decomposition of the logit
or probit coefficient shows that logit coefficients may be decomposed
into a scale invariant part (the square root of the ratio of explained
relative to unexplained variation in y*) and a scale variant part,
namely sd(x). Breen, Karlson, and Holm (2011) argue that in many
situations met in social research, the scale invariant correlation
metric implied in the decomposition is a natural choice for making
comparisons across groups. Users should consult their article for a
clarification of situations for which the metric will be
suitable. Extensions to partial and multiple correlations and to
ordered models are also given in Breen, Karlson, and
Holm (2011).{p_end}

{pstd}{cmd:nlcorr} be used either as a post-estimation command on the
last estimated model, or as a stand alone command. Used as a
post-estimation command the program shows the estimated coefficients
of the last model rescaled to (partial) correlations. The main purpose
of the program, however, is the comparison of these correlations
between different samples. This purpose might be better achieved by
using the program as a stand alone command. {p_end}

{title:Options}

{phang}{opt over(varname [, subpop ])} requests the estimation of the
correlation for each independend variable over categories of the
variable specified with over. Over is required when using {cmd:nlcorr}
as stand alone program. The sub-option {cmd:subpop} is used only in
connection specifying sampling weights (aka pweights). If the
categories of the over variable refer to supgroups of the population
of a complex sample, you should specify {cmd:subpop}. However, if the
categories of the over variable refer to observations from different
complex samples, you should not use {cmd:subpop}. If the over-variable
is an identifier for different countries, you will very often not want
to use {cmd:subpop}.  {p_end}

{phang}{opt basecategory(num)} shows the results in terms of contrasts
between each over category and the base category.{p_end}

{phang}{opt altout} returns the ratio of the (partial) correlation,
r/sqrt(1-r^2), and the (conditional) standard deviation of x. This is
useful for making the decomposition of the logit or probit coefficient.{p_end}

{phang}{opt clear} replaces the dataset in memory with the resultsset
of {cmd:nlcorr}. This is useful for doing subsequent analysis on the
group specific correlations.{p_end}

{title:Example(s)}

{pstd}
Syntax 1{p_end}

{phang}{cmd:. logit foreign trunk weight}{p_end}
{phang}{cmd:. nlcorr}{p_end}

{pstd}
Syntax 2{p_end}

{phang}{cmd:. nlcorr ologit rep78 trunk weight, over(foreign)}{p_end}
{phang}{cmd:. nlcorr ologit rep78 trunk weight, over(foreign) base(0)}{p_end}


{title:References}

{pstd}Breen, R./Karlson, K.B./Holm, A. (2011): A Reinterpretation of
Coefficients from Logit, Probit, and other Non-Linear Probability
Models: Consequences for Comparative Sociological Research. Working
paper (June 14) available at SSRN: {browse "http://ssrn.com/abstract=1857431":http://ssrn.com/abstract=1857431}.{p_end}


{title:Also see}

{psee}
Online: help for {help khb} (if installed), {help ldecomp} (if installed)
{p_end}

{psee}
Web:   {browse "http://stata.com":Stata's Home}
{p_end}

{title:Author}

{pstd}Ulrich Kohler (kohler@wzb.eu) and Kristian Karlson
(kbk@dpu.dk){p_end}

{pstd}Please send bug reports and questions regarding the program to
Ulrich Kohler. Questions regarding the statistical method itself are
handled by Kristian Karlson.{p_end}

