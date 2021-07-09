{smcl}
{hline}
help for {hi:senspec}{right:(Roger Newson)}
{hline}


{title:Sensitivity and specificity results saved in generated variables}

{p 8 15 2}
{cmd:senspec} {it:refvar} {it:classvar} {ifin} {weight}
[{cmd:,}
{cmdab:p:osif}{cmd:(}{it:relational_operator}{cmd:)}
{cmdab:se:nsitivity}{cmd:(}{it:newvarname}{cmd:)} {cmdab:sp:ecificity}{cmd:(}{it:newvarname}{cmd:)}
{cmdab:fp:os}{cmd:(}{it:newvarname}{cmd:)} {cmdab:fn:eg}{cmd:(}{it:newvarname}{cmd:)}
{cmdab:ntp:os}{cmd:(}{it:newvarname}{cmd:)} {cmdab:ntn:eg}{cmd:(}{it:newvarname}{cmd:)}
{cmdab:nfp:os}{cmd:(}{it:newvarname}{cmd:)} {cmdab:nfn:eg}{cmd:(}{it:newvarname}{cmd:)}
{cmd:float}
]

{p 4 4 2}
where {it:refvar} and {it:classvar} are names of an existing numeric reference variable
and an existing numeric classification variable, respectively,
and {it:relational_operator} may be any one of the
{help operators:relational operators} {hi:>}, {hi:<}, {hi:>=} or {hi:<=}.

{p 4 4 2}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are
allowed, and are all treated in the same way. See help for {help weights}.


{title:Description}

{p 4 4 2}
{cmd:senspec} inputs a reference variable with two values and a quantitative classification variable.
It creates, as output, a set of new variables, containing, in each observation,
the numbers and/or rates of true positives, true negatives, false positives and false negatives
observed if the classification variable is used to define a diagnostic test,
with a threshold equal to the value of the classification variable for that observation.
The two variables {it:refvar} and {it:classvar} must be numeric. The reference variable {it:refvar}
indicates the true state of the observation, such as diseased and non-diseased, or
normal and abnormal. It must have only 2 values, for example 0 and 1, of which the lower
value identifies negative observations and the higher value identifies positive observations.
The rating or outcome of the diagnostic test is recorded in {it:classvar}, which must be at least ordinal.
{cmd:senspec} is similar to {helpb roctab}, but produces output variables instead of plots and listings,
so that users can create plots and listings in their own chosen formats.


{title:Options}

{p 4 8 2}
{cmd:posif(}{it:relational_operator}{cmd:)} specifies one of the 4 {help operators:relational operators}
{hi:>}, {hi:<}, {hi:>=} or {hi:<=}.
These {help operators:relational operators} specify that a positive test result is
defined as a value of the classification variable above the threshold, below the threshold,
at or above the threshold, or at or below the threshold, respectively.
If {cmd:posif()} is not specified, then {hi:>=} is assumed,
and the test is assumed to have a positive result if and only if the classification variable is
at or above the threshold.

{p 4 8 2}
{cmd:sensitivity(}{it:newvarname}{cmd:)} specifies the name of a new variable to be generated,
containing, in each observation, the sensitivity of the diagnostic test if the threshold
is equal to the value of the classification variable in that observation.

{p 4 8 2}
{cmd:specificity(}{it:newvarname}{cmd:)} specifies the name of a new variable to be generated,
containing, in each observation, the specificity of the diagnostic test if the threshold
is equal to the value of the classification variable in that observation.

{p 4 8 2}
{cmd:fpos(}{it:newvarname}{cmd:)} specifies the name of a new variable to be generated,
containing, in each observation, the false positive rate of the diagnostic test if the threshold
is equal to the value of the classification variable in that observation.

{p 4 8 2}
{cmd:fneg(}{it:newvarname}{cmd:)} specifies the name of a new variable to be generated,
containing, in each observation, the false negative rate of the diagnostic test if the threshold
is equal to the value of the classification variable in that observation.

{p 4 8 2}
{cmd:ntpos(}{it:newvarname}{cmd:)} specifies the name of a new variable to be generated,
containing, in each observation, the number of true positives (weighted if {help weight:weights}
are specified) if the threshold is equal to the value of the classification variable in that observation.

{p 4 8 2}
{cmd:ntneg(}{it:newvarname}{cmd:)} specifies the name of a new variable to be generated,
containing, in each observation, the number of true negatives (weighted if {help weight:weights}
are specified) if the threshold is equal to the value of the classification variable in that observation.

{p 4 8 2}
{cmd:nfpos(}{it:newvarname}{cmd:)} specifies the name of a new variable to be generated,
containing, in each observation, the number of false positives (weighted if {help weight:weights}
are specified) if the threshold is equal to the value of the classification variable in that observation.

{p 4 8 2}
{cmd:nfneg(}{it:newvarname}{cmd:)} specifies the name of a new variable to be generated,
containing, in each observation, the number of false negatives (weighted if {help weight:weights}
are specified) if the threshold is equal to the value of the classification variable in that observation.

{p 4 8 2}
{cmd:float} specifies that the derived variables specified by the {cmd:sensitivity()},
{cmd:specificity()}, {cmd:fpos()} and {cmd:fneg()} options will have {help datatype:storage type}
no higher than {hi:float}. If {cmd:float} is not specified, then these derived variables
will be created initially as type {hi:double}. Whether or not {cmd:float} is specified,
the derived variables are {help compress:compressed} to the lowest numeric
{help datatypes:storage type} possible without loss of information.


{title:Equations and formulas}

{p 4 4 2}
{cmd:senspec} starts by calculating the numbers (or weighted numbers, if {help weight:weights}
are specified) of true positives, true negatives, false positives and false negatives.
These are stored in variables that may be saved for future use by the {cmd:ntpos()}, {cmd:nfpos()},
{cmd:ntneg()} and {cmd:nfneg()} options, respectively. These variables are created as type
{cmd:double} if {help weight:aweights}, {help weight:pweights} or {help weight:iweights}
are specified, or as type {cmd:long} if {help weight:fweights} or no weights are specified,
and are {help compress:compressed} to the lowest numeric {help datatypes:storage type}
possible without loss of information.
{cmd:senspec} then calculates any derived variables requested by the options
{cmd:sensitivity()}, {cmd:specificity()}, {cmd:fpos()} and {cmd:fneg()},
using the following formulas:

{p 4 4 2}
{cmd: sensitivity=ntpos/(ntpos+nfneg)}

{p 4 4 2}
{cmd: specificity=ntneg/(ntneg+nfpos)}

{p 4 4 2}
{cmd: fpos=nfpos/(ntneg+nfpos)}

{p 4 4 2}
{cmd: fneg=nfneg/(ntpos+nfneg)}

{p 4 4 2}
The user can calculate other results using other formulas by specifying the options
{cmd:ntpos()}, {cmd:nfpos()}, {cmd:ntneg()} and {cmd:nfneg()}, and then generating
further variables from the new variables. Confidence intervals for
the area under the specificity-sensitivity
(or {helpb roc:ROC}) curve can be calculated using the {helpb somersd} package,
downloadable from {help ssc:SSC}.
The {helpb somersd} package offers a choice of normalizing and/or variance-stabilizing transformations,
the ability to adjust for clustering, and the ability to estimate differences between
{help roc:ROC areas} for two alternative classification variables,
using {helpb lincom} or {helpb nlcom}.
See {help senspec##references:Newson (2002)} and {help senspec##references:Newson (2006)}
for more about {helpb somersd}.


{title:Examples}

{p 4 8 2}{cmd:. senspec foreign mpg, sensitivity(sens1) fpos(fpos1)}{p_end}
{p 4 8 2}{cmd:. scatter sens1 fpos1, sort(fpos sens1) connect(L) mlab(mpg)}{p_end}

{p 4 8 2}The following example will work if the user has installed {helpb xcontract}
(downloadable from {help ssc:SSC}).

{p 4 8 2}{cmd:. senspec foreign weight, posif(<=) sens(sens2) spec(spec2)}{p_end}
{p 4 8 2}{cmd:. xcontract weight sens2 spec2, list(,) format(sens2 spec2 %8.4f)}{p_end}


{title:Saved results}

{pstd}
{cmd:senspec} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}Number of observations{p_end}
{synopt:{cmd:r(N_pos)}}Number of positive observations{p_end}
{synopt:{cmd:r(N_neg)}}Number of negative observations{p_end}


{title:Author}

{p}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{marker references}{title:References}

{p}
Newson, R.  2002.  Parameters behind "nonparametric" statistics: Kendall's tau, Somers' D and median differences.
{it:The Stata Journal} 2(1): 45-64.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0007":the {it:Stata Journal} website}.

{p}
Newson, R.  2006.
Confidence intervals for rank statistics: Somers' D and extensions.
{it:The Stata Journal} 6(3): 309-334.
Download from
{browse "http://www.stata-journal.com/article.html?article=snp15_6":the {it:Stata Journal} website}.


{title:Also see}

{p 4 13 2}
Manual:  {mansection R roc:[R] roc}

{p 4 13 2}
Online:  help for {helpb roctab}
{break} help for {helpb somersd} and {helpb xcontract} if installed
{p_end}
