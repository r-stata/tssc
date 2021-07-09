{smcl}
{.-}
help for {cmd:normalrir} {right:(Roger Newson)}
{.-}

{title:Calculate ridits of inverse ridits between Normal populations}

{p 8 27}
{cmd:normalrir} {it:newvarname} [{cmd:if} {it:exp}] [{cmd:in} {it:range}] ,
  {cmdab:un:iform}{cmd:(}{it:expression_1}{cmd:)} [
  {cmdab:mu:}{cmd:(}{it:expression_2}{cmd:)}
  {cmdab:sd:}{cmd:(}{it:expression_3}{cmd:)}
  {cmdab:muz:ero}{cmd:(}{it:expression_4}{cmd:)}
  {cmdab:sdz:ero}{cmd:(}{it:expression_5}{cmd:)}
  {cmd:float}
  ]

{pstd}
where {it:expression_i} (for {it:i} an integer} is a numeric expression.
The numeric expression for each
option must be in the form required by the {cmd:generate} command. That is to say,
each expression must be specified so that the command

{pstd}
{cmd:gene double }{it:newvarname}{cmd:=(}{it:expression}{cmd:)}

{pstd}
will work.


{title:Description}

{pstd}
{cmd:normalrir} inputs expressions to deliver, respectively, a uniform deviate variable,
2 means for 2 Normal populations (Population 1 and Population 0),
and 2 standard deviations for the same 2 Normal populations.
It outputs a new variable, containing, in each observation,
the ridit with respect to Population 0
of a value sampled from Population 1,
whose Normal cumulative distribution function for Population 1 has the value of the uniform deviate variable
in the same observation.
{cmd:normalrir} can be used with the {help ssc:SSC} packages {helpb expgen} and {helpb powercal}
to perform multi-scenario power and sample size calculations for the 2-sample rank statistics
Somers' {it:D} and Harrell's {it:c},
assuming that there exists an unspecified transformation that transforms the outcome variable
to a variable with a Normal distribution in each of the 2 populations
from which the 2 samples are sampled.


{title:Options}

{p 0 4}
{cmd:uniform(}{it:expression_1}{cmd:)} gives an expression,
whose value is interpreted as a uniform deviate from the continuous uniform distribution from 0 to 1.
This option is required.
The output variable will have a nonmissing value in and only in observations
in which the {cmd:uniform()} expression evaluates to a value in the closed interval
from 0 to 1 inclusive.

{p 0 4}
{cmd:mu(}{it:expression_2}{cmd:)} gives an expression, whose value is the mean of Population 1.
If absent, it is set to 0.
Note that the expression may contain variables and/or scalars and/or constants,
but defines a variable whose values are different in different observations,
because we may be comparing multiple pairs of populations in different observations,
as in a multi-scenario power calculation..

{p 0 4}
{cmd:sd(}{it:expression_3}{cmd:)} gives an expression,
whose value is the standard deviation of Population 1.
If absent, it is set to 1.

{p 0 4}
{cmd:muzero(}{it:expression_4}{cmd:)} gives an expression,
whose value is the mean of Population 0.
If absent, it is set to 0.

{p 0 4}
{cmd:sdzero(}{it:expression_5}{cmd:)} gives an expression,
whose value is the standard deviation of Population 0.
If absent, it is set to 1.

{p 0 4}
{cmd:float} specifies that the output variable will have a {help datatypes:storage type} no higher than {hi:float}.
If {cmd:float} is not specified, then {cmd:normalrir} creates the output variable with storage type {hi:double}.
Whether or not {cmd:float} is specified, {cmd:normalrir} compresses the output variable as much as possible
without loss of precision. (See help for {helpb compress}.)


{title:Methods and formulas}

{pstd}
{cmd:normalrir} computes the ridits, with respect to Population 0,
of the inverse ridits, with respect to Population 1,
of the uniform deviates supplied by the {cmd:uniform()} option.
Ridits were introduced in {help normalrir##normalrir_references:Bross (1958)},
and are equal, for a continuously-distributed variable,
to the cumulative distribution function (CDF)
of the population with respect to which the ridits are defined.
More precisely, the ridit with respect to Population 0
of the inverse ridit with respect to Population 1
of a value {cmd:U} in the closed interval from 0 to 1 inclusive
is denoted as {hi:RIR_01(U)}, and is defined as 0 for {hi:U=0}, 1 for {hi:U=1},
and

{pstd}
{hi:RIR_01(U) = F_0(invF_1(U))}

{pstd}
if {hi:0<U<1}, where {hi:F_i(.)} is the CDF of Population {it:i},
{hi:invF_i(.)} is the inverse CDF of Population {it:i},
and {it:i} can be 0 or 1.
{cmd:normalrir} assumes that {hi:F_1(.)} belongs to a Normal distribution,
with mean and standard deviation (SD) supplied by the {cmd:mu()} and {cmd:sd()} expressions,
and that {hi:F_0()} belongs to a Normal distribution,
with mean and SD supplied by the {cmd:muzero()} and {cmd:sdzero()} expressions.

{pstd}
The main appication of ridits of inverse ridits is in power calculations for 2-sample rank statistics,
estimating the 2-sample parameters Harrell's {it:c(Y|X)} and Somers' {it:D(Y|X)},
where {it:X} is a binary variable indicating membership of Subpopulation 1 instead of Subpopulation 0,
and {it:Y} is an outcome variable,
assumed by {cmd:normalrir} to be transformable, using an unidentified transformation,
to a variable with a Normal distribution
within each of the 2 subpopulations (1 and 0).
By the argument of Chapter 5 of {help normalrir##normalrir_references:Serfling (1980)},
the asymptotic distribution of the sample estimate of Harrell's {it:c(Y|X)}
is Normal,
with a sampling variance which converges in ratio
(as the sample numbers become large and their ratio stays the same)
to

{pstd}
{hi:Var[RIR_01(U)]/N_1 + Var[RIR_10(U)]/N_0},

{pstd}
where {hi:U} is a uniform deviate distributed between 0 and 1,
{hi:RIR_10()} is the ridit with respect to Population 1
of the inverse ridit with respect to Population 0,
and {cmd:N_1} and {cmd:N_0} are the sample numbers of individuals
sampled from Population 1 and Population 0, respectively.
The 2 variances can be estimated numerically,
using {cmd:normalrir} with the {helpb collapse} command in Stata,
and then used in power calculations,
using the {help ssc:SSC} package {helpb powercal} described in
{help normalrir##normalrir_references:Newson (2004)}.
The {help ssc:SSC} package {helpb expgen} can be very useful here,
especially if the power calculations are multi-scenario.

{pstd}
For more about the estimation of Somers {it:D} and Harrell's {it:c} using Stata,
see {help normalrir##normalrir_references:Newson (2006)}.
For more about the details of the maths behind {cmd:normalrir},
see Newson (2017).


{title:Examples}

{pstd}
The following examples use a generated dataset,
with a single variable containing a uniform deviate,
with values spanning the closed interval from 0 to 1 inclusive.
We then use {cmd:normalrir} to define new variables,
containing the ridits with rspect to Population 0
of the inverse ridits with repect to Population 1,
and use {helpb scatter} to plot the ridits of inverse ridits against the original uniform deviates.
The 3 ridits of inverse ridits assume, respectively,
that Populations 0 and 1
have the same SD and the same mean,
the same SD and different means,
and different SDs and different means.

{pstd}
Set-up:

{p 8 16}{inp:. clear}{p_end}
{p 8 16}{inp:. set obs 101}{p_end}
{p 8 16}{inp:. gene unidev=(_n-1)/(_N-1)}{p_end}
{p 8 16}{inp:. lab var unidev "Uniform deviate"}{p_end}
{p 8 16}{inp:. summ unidev, detail}{p_end}

{pstd}
Simple examples:

{p 8 16}{inp:. normalrir rir1, uniform(unidev)}{p_end}
{p 8 16}{inp:. scatter rir1 unidev}{p_end}

{p 8 16}{inp:. normalrir rir2, uniform(unidev) mu(2) muzero(1)}{p_end}
{p 8 16}{inp:. scatter rir2 unidev}{p_end}

{p 8 16}{inp:. normalrir rir3, uniform(unidev) mu(2) muzero(1) sd(1) sdzero(0.5)}{p_end}
{p 8 16}{inp:. scatter rir3 unidev}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{marker normalrir_references}{...}
{title:References}

{phang}
Bross, I. D. J.  1958.
How to use ridit analysis.
{it:Biometrics} 14(1): 18-38.

{pstd}
Newson, R. B.
2017.
Asymptotic distributions of two-sample rank statistics for continuous outcomes.
Download from
{browse "http://www.rogernewsonresources.org.uk/papers.htm#miscellaneous_documents":Roger Newson's website}.

{pstd}
Newson, R.
2006.
Confidence intervals for rank statistics: Somers' {it:D} and extensions.
{it:The Stata Journal} 6(3): 309-334.
Download from
{browse "http://www.stata-journal.com/article.html?article=snp15_6":The Stata Journal website}.

{pstd}
Newson, R.
2004.
Generalized power calculations for generalized linear models and more.
{it:The Stata Journal} 4(4): 379-401.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0074":The Stata Journal website}.

{pstd}
Serfling R. J. 1980. Approxination Theorems of Mathematical Statistics. New York, NY: John Wiley & Sons.


{title:Also see}

{p 4 13 2}
{bind: }Manual:  {hi:[R] collapse}, {hi: [G2] graph twoway scatter}
{p_end}
{p 4 13 2}
On-line: help for {helpb collapse}, {helpb scatter}{break}
          help for {helpb powercal}, {helpb somersd}, {helpb expgen} (if installed)
{p_end}
