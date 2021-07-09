{smcl}
{.-}
help for {cmd:powercal} {right:(Roger Newson)}
{.-}

{title:Generalized power calculations saving results in variables}

{p 8 27}
{cmd:powercal} {it:newvarname} [{cmd:if} {it:exp}] [{cmd:in} {it:range}] ,
 [ {cmdab:n:unit}{cmd:(}{it:expression_1}{cmd:)} {cmdab:p:ower}{cmd:(}{it:expression_2}{cmd:)}
  {cmdab:a:lpha}{cmd:(}{it:expression_3}{cmd:)} {cmdab:d:elta}{cmd:(}{it:expression_4}{cmd:)}
  {cmdab:s:dinf}{cmd:(}{it:expression_5}{cmd:)} {cmdab:t:df}{cmd:(}{it:expression_6}{cmd:)}
  {cmd:no}{cmdab:ce:iling} {cmd:float} ]

{pstd}
where {it:expression} is a numeric expression. The numeric expression for each
option must be in the form required by the {cmd:generate} command. That is to say,
each expression must be specified so that the command

{pstd}
{cmd:gene double }{it:newvarname}{cmd:=(}{it:expression}{cmd:)}

{pstd}
will work.


{title:Description}

{pstd}
{cmd:powercal} performs generalized power calculations, storing the result in a new
variable with a name specified by {it:newvarname}. All except one of the options
{cmd:nunit}, {cmd:power}, {cmd:alpha}, {cmd:delta} and {cmd:sdinf} must be
specified. The single unspecified option in this list specifies whether the output
variable is the number of sampling units, power, alpha (significance level),
delta (difference in parameter value to be detected), or the standard deviation (SD)
of the influence function. Any of these 5 quantities can be calculated from the
other 4. {cmd:powercal} can be used to calculate any of these quantities, assuming
that we are testing a hypothesis that a parameter is zero, and that the true value is
given by {cmd:delta}, and that the sample statistic is distributed around the
population parameter in such a way that the pivotal quantity

{pstd}
{hi:PQ = sqrt(nunits) {c 42} (delta/sdinf)}

{pstd}
has a standard Normal distribution (if {cmd:tdf()} is not specified) or a t-distribution
with {cmd:tdf()} degrees of freedom (if {cmd:tdf()} is specified). The formulas used by
{cmd:powercal} define power as the probability of detecting a difference in the right
direction, using a two-tailed test.


{title:Options}

{p 0 4}{cmd:nunit(}{it:expression_1}{cmd:)} gives an expression whose value is the number
of independent sampling units. Sampling units are defined very generally. For instance, in
an experiment involving equal-sized samples of individuals from Population A and Population B,
a sampling unit might be a pair of sampled individuals, one from each population. Similarly,
in a case-control study with 4 controls per case, a sampling unit might be a case together
with 4 controls.

{p 0 4}{cmd:power(}{it:expression_2}{cmd:)} gives an expression whose value is the power to
detect a difference specified by the {cmd:delta()} option (see below).
The power is defined as the probability that the sample difference is in the correct direction,
and also large enough to be significant, using a 2-tailed test, at the level specified
by the {cmd:alpha()} option (see below).

{p 0 4}{cmd:alpha(}{it:expression_3}{cmd:)} gives an expression whose value is the size, or
significance level, of the statistical test (in units of probability, not percentage).

{p 0 4}{cmd:delta(}{it:expression_4}{cmd:)} gives an expression whose value is the true
population difference to be detected. This difference is assumed to be positive.
Therefore, if the user wishes to detect a negative difference, then s/he should
specify an expression equal to minus that difference. The difference may be the
log of a ratio parameter, such as an odds ratio, rate ratio, risk ratio
or ratio of geometric means.

{p 0 4}{cmd:sdinf(}{it:expression_5}{cmd:)} gives an expression whose value is the standard
deviation of the influence function. That is to say, it is an expression equal to the
expected standard error of the sample difference multiplied by the square root of the number of sampling
units, where sampling units are defined generally, as specified in the option
{cmd:nunit()}. In the simple case of a paired t-test, {cmd:sdinf()} is the standard
deviation of the paired differences. More generally, {cmd:sdinf()} can be defined by
calculating a standard error for a particular number of units, from a pilot study,
from a simulation or from a formula, and multiplying this standard error by the
square root of the number of units in the pilot study, simulation or formula.

{p 0 4}{cmd:tdf(}{it:expression_6}{cmd:)} gives an expression whose value is the degrees of
freedom of the t-distribution to be assumed for the pivotal quantity {hi:PQ} specified
above. The degrees of freedom expression is not necessarily integer-valued. If {cmd:tdf()}
is absent, then {hi:PQ} is assumed to follow a standard Normal distribution.

{p 0 4}{cmd:noceiling} specifies that, if the output variable specified by {it:newvarname}
is a number of units, then it will not be rounded up to the lowest integer no less than itself
(as calculated by the Stata {cmd:ceil()} function). This option can be useful if the output variable
is intended to specify an amount of exposure, such as a number of person-years,
and the input {cmd:sdinf()} expression specifies a standard deviation of the influence function
per unit exposure. If {cmd:noceiling} is not specified, and {cmd:power()}, {cmd:alpha()},
{cmd:delta()} and {cmd:sdinf()} are specified, then {cmd:powercal} rounds up the output variable,
so that it contains a whole number of units

{p 0 4}{cmd:float} specifies that the output variable will have a {help datatypes:storage type} no higher than {hi:float}.
If {cmd:float} is not specified, then {cmd:powercal} creates the output variable with storage type {hi:double}.
Whether or not {cmd:float} is specified, {cmd:powercal} compresses the output variable as much as possible
without loss of precision. (See help for {help compress}.)


{title:Remarks}

{pstd}
{cmd:powercal} carries out sample size calculations for a more general range of
possible experimental designs than {help sampsi}, and stores the result in a new
variable, instead of reporting the result in the log. The new variable may be input
to further calculations and/or plotted and/or listed. {cmd:powercal} is intended as a
low-level programming tool for users intending to carry out sample size calculations
for a given experimental design. It is the responsibility of the user to ensure that
the expressions are correct, and to choose a parameter scale on which the parameter
is expected to be Normally distributed (or t-distributed), with a variance that does
not vary excessively with the size of the measured difference.

{pstd}
The formulas used by {cmd:powercal} define power as the probability of detecting a
difference in the right direction, using a two-tailed test. It follows that, in the
limit, as the difference {hi:delta} tends to zero, the power to detect a difference
of {hi:delta} with a P-value of {hi:alpha} tends to a minimum of {hi:alpha/2}, and
not to a minimum of {hi:alpha}. {cmd:powercal} converts to missing the results of
all input expressions for {cmd:power()} and {cmd:alpha()} which evaluate to a number
outside the open interval {hi:(0,1)}, and the results of all input expressions for
{cmd:delta()}, {cmd:sdinf()} and {cmd:nunit()} which evaluate to a non-positive number.
{cmd:powercal} also converts to missing all values in the output variable for which
there is not a unique maximum or minimum value of the output quantity.
See Newson (2004),
or the manual
{hi:powercal.pdf} (distributed as an ancillary file with the {cmd:powercal} package),
for details of the Methods and Formulas.


{title:Examples}

{pstd}
The following examples are explained in detail in the manual {hi:powercal.pdf},
which is distributed with the {cmd:powercal} package.

{pstd}
This example creates Figure 1, displaying power as a function of the geometric mean ratio
between 2 treatment groups:

{p 8 16}{inp:. clear}{p_end}
{p 8 16}{inp:. scal cv=0.5}{p_end}
{p 8 16}{inp:. scal sdlog=sqrt(log(cv*cv + 1))}{p_end}
{p 8 16}{inp:. scal r20=exp(-2*sdlog*invnorm(0.2))}{p_end}
{p 8 16}{inp:. disp _n as text "Coefficient of variation: " as result cv  _n as text "SD of logs: " as result sdlog  _n as text "20% tail ratio: " as result r20}{p_end}
{p 8 16}{inp:. set obs 100}{p_end}
{p 8 16}{inp:. gene logratio=log(2)*(_n/_N)}{p_end}
{p 8 16}{inp:. lab var logratio "Log GM ratio"}{p_end}
{p 8 16}{inp:. gene gmratio=exp(logratio)}{p_end}
{p 8 16}{inp:. lab var gmratio "GM ratio"}{p_end}
{p 8 16}{inp:. powercal power, alpha(0.01) delta(logratio) sdinf(sdlog*sqrt(2)) nunit(50) tdf(98)}{p_end}
{p 8 16}{inp:. line power gmratio, sort  ylab(0(0.05)1) yline(0.8 0.9) xlab(1(0.1)2) xscale(log range(1 2))}{p_end}

{pstd}
This example creates Figure 2, displaying detectable geometric mean ratios between 2 groups
as a function of number per group:

{p 8 16}{inp:. clear}{p_end}
{p 8 16}{inp:. scal cv=0.5}{p_end}
{p 8 16}{inp:. scal sdlog=sqrt(log(cv*cv + 1))}{p_end}
{p 8 16}{inp:. scal r20=exp(-2*sdlog*invnorm(0.2))}{p_end}
{p 8 16}{inp:. disp _n as text "Coefficient of variation: " as result cv _n as text "SD of logs: " as result sdlog _n as text "20% tail ratio: " as result r20}{p_end}
{p 8 16}{inp:. set obs 100}{p_end}
{p 8 16}{inp:. gene npergp=_n}{p_end}
{p 8 16}{inp:. lab var npergp "Number per group"}{p_end}
{p 8 16}{inp:. powercal logratio, power(0.9) alpha(0.01) sdinf(sdlog*sqrt(2)) nunit(npergp) tdf(2*(npergp-1))}{p_end}
{p 8 16}{inp:. gene hiratio=exp(logratio)}{p_end}
{p 8 16}{inp:. gene loratio=exp(-logratio)}{p_end}
{p 8 16}{inp:. lab var hiratio "Detectable GM ratio >1"}{p_end}
{p 8 16}{inp:. lab var loratio "Detectable GM ratio <1"}{p_end}
{p 8 16}{inp:. line hiratio loratio npergp if _n>=5, xlab(0(10)100)}{p_end}

{pstd}
This example creates Figures 3 and 4, displaying, respectively, detectable odds ratios in a case-control study
as a function of number of cases and attainable significance levels as a function of odds ratio:

{p 8 16}{inp:. clear}{p_end}
{p 8 16}{inp:. scal conprev=0.25}{p_end}
{p 8 16}{inp:. scal conodds=conprev/(1-conprev)}{p_end}
{p 8 16}{inp:. disp _n as text "Expected control prevalence: " as result conprev _n as text "Expected control odds: " as result conodds}{p_end}
{p 8 16}{inp:. set obs 101}{p_end}
{p 8 16}{inp:. gene logor=log(1.25)+(log(5)-log(1.25))*(_n-1)/(_N-1)}{p_end}
{p 8 16}{inp:. gene or=exp(logor)}{p_end}
{p 8 16}{inp:. gene caseodds=conodds*or}{p_end}
{p 8 16}{inp:. gene caseprev=caseodds/(1+caseodds)}{p_end}
{p 8 16}{inp:. gene sdinflor=sqrt( 1/caseprev + 1/(1-caseprev) + (1/2)*( 1/conprev + 1/(1-conprev) ) );}{p_end}
{p 8 16}{inp:. lab var logor "Log odds ratio"}{p_end}
{p 8 16}{inp:. lab var or "Odds ratio"}{p_end}
{p 8 16}{inp:. lab var caseodds "Case exposure odds"}{p_end}
{p 8 16}{inp:. lab var caseprev "Case exposure prevalence"}{p_end}
{p 8 16}{inp:. lab var sdinflor "SD of influence for log OR"}{p_end}
{p 8 16}{inp:. desc}{p_end}
{p 8 16}{inp:. * Detectable OR by number of cases *}{p_end}
{p 8 16}{inp:. powercal ncases, power(0.9) alpha(0.01) delta(logor) sdinf(sdinflor)}{p_end}
{p 8 16}{inp:. line or ncases if ncases<=2000, yscale(log)}{p_end}
{p 8 16}{inp:. more}{p_end}
{p 8 16}{inp:. * Significance level by odds ratio *}{p_end}
{p 8 16}{inp:. powercal alphamin, power(0.9) delta(logor) sdinf(sdinflor) nunit(100)}{p_end}
{p 8 16}{inp:. line alphamin or, yscale(log reverse) ylab(1 0.05 1e-1 1e-2 1e-3 1e-4 1e-5 1e-6 1e-7) xscale(log) xlab(1 1.25 1.5 2(1)5)}{p_end}
{p 8 16}{inp:. more}{p_end}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{pstd}
Newson R.
2004.
Generalized power calculations for generalized linear models and more.
{it:The Stata Journal} 4(4): 379-401.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0074":The Stata Journal website}.


{title:Also see}

{p 0 21}
{bind: }Manual:  {hi:[R] sampsi}
{p_end}
{p 0 21}
On-line:  help for {helpb sampsi}
{p_end}
