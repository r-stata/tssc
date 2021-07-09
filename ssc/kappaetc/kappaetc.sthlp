{smcl}
{cmd:help kappaetc}{right: ({browse "http://www.stata-journal.com/article.html?article=st0544":SJ18-4: st0544})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col:{cmd:kappaetc} {hline 2}}Interrater agreement{p_end}
{p2colreset}{...}


{title:Syntax}

{pstd}
Interrater agreement, variables record raw ratings

{p 8 16 2}
{cmd:kappaetc} 
{it:{help varname:varname1}} 
{it:{help varname:varname2}}
[{it:{help varname:varname3}} {it:...}]
{ifin} 
{weight}
[{cmd:,} {it:{help kappaetc##opts:kappaetc_options}}]


{pstd}
Interrater agreement, variables record frequency of ratings

{p 8 16 2}
{cmd:kappaetc} 
{it:{help varname:varname1}} 
{it:{help varname:varname2}}
[{it:{help varname:varname3}} {it:...}]
{ifin} 
{weight}{cmd:,} {opt fre:quency} [{it:{help kappaetc##opts:kappaetc_options}}]


{pstd}
Immediate command, interrater agreement, two raters, contingency table

{p 8 16 2}
{cmd:kappaetci}
{it:#11} {it:#12} [{it:...}] {cmd:\}
{it:#21} {it:#22} [{it:...}] [{cmd:\} {it:...}]
[{cmd:, tab} 
{it:{help kappaetc##opts:kappaetc_options}}]


{pstd}
More

{p 8 18 2}
{help kappaetc_choosing:Choosing an appropriate method of analysis}

{p 8 18 2}
{help kappaetc_ttest:Test differences of correlated agreement coefficients}

{p 8 18 2}
{help kappaetc_icc:Intraclass correlation coefficients (interrater and intrarater reliability)}

{p 8 18 2}
{help kappaetc_loa:Limits of agreement (Bland-Altman plot)}


{synoptset 28 tabbed}{...}
{marker opts}{...}
{synopthdr:kappaetc_options}
{synoptline}
{syntab:Main}
{synopt:{cmd:{ul:w}gt(}{it:wgtid} [{cmd:,} {it:wgt_options}]{cmd:)}}specify 
how disagreements are weighted; see {it:{help kappaetc##opt_wgt:Options}} for 
alternatives
{p_end}
{synopt:{cmd:se(}{it:se_type}{cmd:)}}specify how standard errors are estimated; 
see {it:{help kappaetc##opt_se:Options}} for alternatives
{p_end}
{synopt:{opt fre:quency}}specify that variables record rating frequencies
{p_end}
{synopt:{opt cat:egories(numlist)}}specify predetermined rating categories
{p_end}
{synopt:{opt list:wise}}exclude subjects with missing ratings
{p_end}

{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default is 
{cmd:level({ccl level})}
{p_end}
{synopt:{opt showw:eights}}display weighting matrix
{p_end}
{synopt:{cmdab:bench:mark}[{cmd:(}{it:benchmark_method} [{cmd:,} {it:benchmark_options}]{cmd:)}]}{break}benchmark interrater agreement coefficients; see {it:{help kappaetc##opt_benchmark:Options}}{p_end}
{synopt:{opt shows:cale}}display benchmark scale
{p_end}
{synopt:{cmdab:testval:ue(}[{it:{help operator:relop}}]{it:#}{cmd:)}}test whether coefficients are equal 
to {it:#}; default is {cmd:testvalue(0)}
{p_end}
{synopt:{opt nociclip:ped}}do not clip confidence intervals at -1 and 1
{p_end}
{synopt:{opt noh:eader}}suppress output header
{p_end}
{synopt:{opt notab:le}}suppress coefficient table
{p_end}
{synopt:{it:{help kappaetc##opt_di:format_options}}}control column formats
{p_end}

{syntab:Advanced}
{synopt:{opt nsubjects(#)}}specify size of subject universe
{p_end}
{synopt:{opt nraters(#)}}specify size of rater population
{p_end}
{synopt:{opt largesample}}use standard normal distribution 
for p-values and intervals
{p_end}

{syntab:Immediate command}
{synopt:{opt t:ab}}display contingency table{p_end}

{syntab:Miscellaneous}
{synopt:{cmd:{ul:sto}re(}{it:name}|{it:stub}{cmd:*}{cmd:)}}store 
(additional) returned results under {it:name} or {it:stub}{cmd:*}{p_end}
{synopt:{opt ttest}}perform paired t tests of differences between correlated 
agreement coefficients; see {helpb kappaetc_ttest:kappaetc, ttest}
{p_end}
{synopt:{opt icc(model)}}estimate intraclass correlation coefficients
(interrater
and intrarater reliability); see {helpb kappaetc_icc:kappaetc, icc()}
{p_end}
{synopt:{cmd:loa}[{cmd:(}{it:#}{cmd:)}]}estimate limits of agreement 
and produce Bland-Altman plot; see {helpb kappaetc_loa:kappaetc, loa}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is allowed only with {cmd:kappaetc}; see {manlink D by}.
{p_end}
{p 4 6 2}
{cmd:fweight}s and {cmd:iweight}s are allowed only with {cmd:kappaetc}; 
see {help weight}.


{title:Description}

{pstd}
{cmd:kappaetc} estimates various interrater agreement coefficients, their
standard errors, and their confidence intervals.  Statistics are estimated for
any number of raters, any number of rating categories, and in the presence of
missing values (that is, varying number of ratings per subject).  Disagreement
among raters may be weighted by user-defined weights or a set of prerecorded
weights, suitable for any level of measurement.

{pstd}
The command is implemented using methods and formulas discussed in Gwet
(2014).  It calculates percent agreement, the Brennan and Prediger (1981)
coefficient, Cohen's (1960, 1968) kappa and its generalization by Conger
(1980), Fleiss's (1971) kappa, Gwet's (2008, 2014) AC, and Krippendorff's
(1970, 2011, 2013) alpha coefficient.

{pstd}
Standard errors are estimated conditionally upon the sample of raters,
allowing results to be projected only to the subject universe.  Optionally,
{cmd:kappaetc} calculates (jackknife) standard errors conditional on the
sample of subjects or unconditional standard errors, allowing projection of
results to both the subject universe and the rater population.

{pstd}
{cmd:kappaetc} assumes that each observation is a subject (unit of analysis)
and that variables contain the ratings by raters (coders, judges, observers).
Thus, the first variable records the ratings assigned by the first rater, the
second variable records the ratings assigned by the second rater, and so on.
With the {opt frequency} option, each observation is still assumed to
represent one subject.  However, variables are expected to record the
frequencies of ratings.

{pstd}
{cmd:kappaetc} also assumes that all possible rating categories are observed
in the data.  This assumption is crucial.  If some of the rating categories
are not used by any of the raters, the full set of conceivable ratings must be
specified in the {helpb kappaetc##opt_cat:categories()} option.  Failing to do
so might produce incorrect results for all weighted agreement coefficients;
Brennan and Prediger's coefficient and Gwet's AC will be incorrectly estimated
even if no weights are used.

{pstd}
{cmd:kappaetci} calculates interrater agreement for two raters from a
contingency table of rating frequencies.  The rows and columns of the table
are assumed to represent the rating categories, and the cell frequencies
indicate the number of subjects that have been classified into the respective
categories by the two raters.  The syntax mirrors that of 
{helpb tabulate_twoway:tabi}.  Also see {help immed} for a general description
of immediate commands.


{title:Options}

{dlgtab:Main}

{marker opt_wgt}{...}
{phang}
{cmd:wgt(}{it:wgtid} [{cmd:,} {it:wgt_options}]{cmd:)} specifies that
{it:wgtid} be used to weight disagreements.  The available weights and
{it:wgt_options} are described below.

{phang2}
{opt i:dentity} weights are the q x q identity matrix, where q is the number
of categories used to rate subjects.  Identity weights are the default and
result in the unweighted analysis.

{phang2}
{opt o:rdinal} weights are defined as 1 - {help comb:comb}(|k-l|+1),
2)/comb(q, 2) for all k!=l, where k and l represent the ranked categories 1,
2, ..., q and q is the number of rating categories.  The {it:wgt_option} 
{opt krippen:dorff} is allowed and specifies that ordinal weights suggested by
Krippendorff (2011) be used instead.  The latter are defined as 1 - sum(n_g -
(n_k+n_l)/2)^2, where the n_* are the observed number of pairable values k and
l.  Note that standard errors are not available with Krippendorff's ordinal
weights.

{phang2}
{opt l:inear} weights are defined as 1 - |k-l|/|q_max-q_min|, where k and l
refer to the actual ratings and q_max and q_min are the maximum and minimum of
all ratings.  The {it:wgt_option} {opt noa:bsolute} is allowed and specifies
that k and l be interpreted as row and column indices of the weighting matrix.
{opt w} is a synonym for {opt linear} with {it:wgt_option} {opt noabsolute}.
These are the same weights as those used by {helpb kap}.

{phang2}
{opt q:uadratic} weights are defined as 1 - (k-l)^2/(q_max-q_min)^2, where k
and l refer to the actual ratings and q_max and q_min are the maximum and
minimum of all observed ratings.  The {it:wgt_option} {opt noa:bsolute} is
allowed and specifies that k and l be interpreted as row and column indices of
the weighting matrix.  {opt w2} is a synonym for {opt quadratic} with
{it:wgt_option} {opt noabsolute}.  These are the same weights as those used by
{helpb kap}.

{phang2}
{opt rad:ical} weights are defined as 1 - 
{help sqrt:sqrt}(|k-l|)/sqrt(|q_max-q_min|), where k and l refer to the actual
ratings and q_max and q_min are the maximum and minimum of all ratings.  The
{it:wgt_option} {opt noa:bsolute} is allowed and specifies that k and l be
interpreted as row and column indices of the weighting matrix.

{phang2}
{opt r:atio} weights are defined as 1 -
[(k-l)/(k+l)]^2/[(q_max-q_min)/(q_max+q_min)]^2, where k and l refer to the
actual ratings and q_max and q_min are the maximum and minimum of all ratings.
The {it:wgt_option} {opt noa:bsolute} is allowed and specifies that k and l be
interpreted as row and column indices of the weighting matrix.

{phang2}
{opt c:ircular} [{cmd:pi}|{cmd:180}|{it:#}] weights are defined as 1 - 
{help sin():sin}({it:angle}*(k-l)/(q_max-q_min+1))^2/M, where {it:angle} is pi
radians if {cmd:pi} was specified or 180 degrees if {cmd:180} was specified
and where k and l refer to the actual ratings, q_max and q_min are the maximum
and minimum of all ratings, and M is the maximum of all weights; the sine
function's argument defaults to {cmd:pi} (that is, 
{helpb creturn##other:c(pi)}).  When {it:#} is specified as 0 <= {it:#} < 1,
circular weights proposed by Warrens and Pratiwi (2016) are used instead.  The
latter are defined as {it:#}*[(|k-l|==1)+(|k-l|==|q-1)] for all k!=l.  When
{it:#} is specified, the {it:wgt_option} {opt noa:bsolute} is required and
specifies that k and l are interpreted as row and column indices of the
weighting matrix.

{phang2}
{opt b:ipolar} weights are defined as (k-l)^2/[M(k+l-2*q_min)*(2*q_max-k-l)],
where k and l refer to the actual ratings, q_max and q_min are the maximum and
minimum of all ratings, and M is the maximum of all weights.

{phang2}
{cmd:{ul:p}ower} {it:#} weights are defined as 1 -
(|k-l|^{it:#})/(|q_max-q_min|^{it:#}), where k and l refer to the actual
ratings and q_max and q_min are the maximum and minimum of all ratings.  These
weights are discussed in Warrens (2014) as a generalization of identity
({it:#}=0), linear ({it:#}=1), quadratic ({it:#}=2), and radical ({it:#}=0.5)
weights.  The {it:wgt_option} {opt noa:bsolute} is allowed and specifies that
k and l be interpreted as row and column indices of the weighting matrix.

{phang2}
{it:kapwgt} are weights defined with the {helpb kapwgt} command.  The
{it:wgt_option} {opt kap:wgt} is allowed and must be used if {it:kapwgt} has
the same name as one of the prerecorded weights (or their abbreviations)
discussed above.

{phang2}
{it:matname} are weights defined in a Stata {helpb matrix_define:matrix}.  The
{it:wgt_option} {opt mat:rix} is allowed and must be used if {it:matname} is
the same name as {it:kapwgt} or any of the prerecorded weights (or their
abbreviations) discussed above.

{marker opt_se}{...}
{phang}
{cmd:se(}{it:se_type}{cmd:)} specifies how standard errors are estimated.  Any
estimated interrater agreement coefficient potentially depends on two samples:
subjects to be rated might be drawn from a universe of subjects, while raters
might be drawn from a rater population.  Standard errors may therefore be
conditional upon either of the samples, or unconditional, accounting for the
two respective sampling errors.  The appropriateness of these different
standard errors depends on the research questions.  Available {it:se_type}s
are described below.

{phang2}
{cmdab:cond:itional} [{opt r:aters}] are the default standard errors and are
estimated conditionally upon the sample of raters.  These standard errors are
appropriate when results are to be generalized to the subject universe, given
the specific raters.

{phang2}
{cmdab:cond:itional} {opt s:ubjects} requests that standard errors be
estimated conditionally upon the sample of subjects.  The extent of agreement
among all but one rater is obtained for each of the r raters in the sample.
Technically, these standard errors are implemented using a jackknife approach.
These standard errors allow projection of results to the rater population,
given the rated subjects.

{phang2}
{cmd:{ul:uncond}itional} standard errors are appropriate if the results are to
be projected to the universe of subjects and the rater population.  They are
calculated as the square root of the  sum of variances due to the subject and
rater sample.

{phang}
{opt frequency} specifies that variables represent rating categories.  The
first variable records the frequency of the first rating category, the second
variable records the frequency of the second rating category, and so on.
Rating categories are assumed to be the integer sequence 1, 2, ..., q (but see
the option {helpb kappaetc##opt_cat:categories()}).  Note that all possible
ratings must be represented by one variable even if the frequency is 0 for all
subjects.  Cohen's (1960, 1968) and Conger's (1980) kappa cannot be calculated
from recorded rating frequencies, and only the default standard errors,
conditional on the rater sample, are available.

{marker opt_cat}{...}
{phang}
{cmd:categories(}{it:{help numlist}}{cmd:)} specifies the predetermined rating
categories.  By default, the set of rating categories is obtained from the
data.  There are two situations where this option should be used.

{p 8 8 2}
When variables contain ratings (the default), the full set of possible rating
categories must be specified if not all of them are observed in the data.
Failing to do so may lead to incorrect results.  The order in which rating
categories are specified does not matter; categories are sorted internally.
Note that noninteger values are processed in {help data_types:double}
precision.  To convert them to {help data_types:float} precision, specify
{cmd:categories(float(}{it:numlist}{cmd:))}.

{p 8 8 2}
With the {opt frequency} option, the ratings are assumed to be the integer
sequence 1, 2, ..., q that corresponds to the specified variables.  Likewise,
with the immediate form of the command, the ratings are assumed to be the
integer sequence 1, 2, ..., q of rows and columns entered.  In both cases, the
{cmd:categories()} option may be used to specify alternative rating
categories, including noninteger, negative, and even missing values.  Also in
both cases, the order in which the rating categories are specified matters and
corresponds to the respective variables or sorted values underlying the table.

{phang}
{opt listwise} specifies that subjects with missing ratings be excluded from
the analysis.  By default, all subjects that are rated by at least one (two,
for Krippendorff's alpha) rater or raters are used to estimate expected
agreement.  Observed agreement is based only on those subjects that are rated
by two or more raters.  {opt case:wise} is a synonym for {opt listwise}.

{dlgtab:Reporting}

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence
and benchmark intervals.  The default is {cmd:level({ccl level})}.

{phang}
{opt showweights} additionally displays the weighting matrix below the
coefficient table.  For the unweighted analysis, the identity matrix is shown.

{marker opt_benchmark}{...}
{phang}
{cmd:benchmark}[{cmd:(}{it:benchmark_method} [{cmd:,}
{it:benchmark_options}]{cmd:)}] benchmarks the estimated interrater agreement
coefficients using the Landis and Koch (1977) scale and the method proposed by
Gwet (2014).

{p 8 8 2}
Landis and Koch (1977) suggest the following benchmark scale for interpreting
the kappa statistic:

{p2colset 32 42 42 8}{...}
{p2col:{bind:    }<0.00}Poor{p_end}
{p2col:0.00-0.20}Slight{p_end}
{p2col:0.21-0.40}Fair{p_end}
{p2col:0.41-0.60}Moderate{p_end}
{p2col:0.61-0.80}Substantial{p_end}
{p2col:0.81-1.00}Almost Perfect{p_end}
{p2colreset}{...}

{p 8 8 2}
Gwet (2014) argues that the probability distribution of an agreement
coefficient depends on the number of subjects, raters, and categories in the
study.  Therefore, the error margin associated with these sources of variance
must be accounted for when comparing estimated coefficients with predetermined
thresholds.  Consequently, benchmarking should be probabilistic rather than
deterministic.  He proposes a statistical method that consists of three steps.
First, the probability for an agreement coefficient to fall into each of the
intervals, defined by the benchmark limits, is calculated.  Next, the
cumulative probability for the intervals, starting from the highest level, is
computed.  Finally, the interval associated with a cumulative probability
larger than a given threshold ({ccl level}% by default) determines the
benchmark level.

{p 8 8 2}
With the {opt benchmark} option, {cmd:kappaetc} displays the estimated
coefficients and their standard errors.  It reports the probability for each
coefficient to fall into the selected benchmark interval along with the
cumulative probability exceeding the predetermined threshold associated with
this interval.  The interval limits are shown as well.

{p 8 8 2}
Available {it:benchmark_method}s are described below.

{phang2}
{opt p:robabilistic} is the default method and selects the benchmark interval
associated with the smallest cumulative membership probability exceeding
{cmd:c(level)}.  The threshold is controlled by the {opt level()} option.

{phang2}
{opt d:eterministic} selects the benchmark interval associated with the
estimated agreement coefficient.  This method is deterministic in that the
chosen interval is determined solely by the point estimate, ignoring any
uncertainty associated with its estimation.

{p 8 8 2}
With both {it:benchmark_method}s, the following {it:benchmark_option} is
allowed.

{phang2}
{opt s:cale(spec)} specifies the benchmark scale.  {it:spec} is usually one of
{cmd:landis} (or {cmd:koch}), {cmd:fleiss}, or {cmd:altman}.  The default is
{cmd:scale(landis)} (or {cmd:scale(koch)}) and results in the Landis and Koch
scale as shown above.  {cmd:fleiss} requests a three-level scale, suggested by
Fleiss, Levin, and Paik (2003), and {cmd:altman} collapses the first two
levels of the default scale into one category yielding the Altman (1991)
scale.  Alternatively, {it:spec} explicitly specifies the (upper-limit)
benchmarks as a {it:{help numlist}}.  The Landis and Koch scale could be
obtained as {cmd:scale(0(.2)1)}.

{phang}
{opt showscale} additionally displays the benchmark scale for interpreting
coefficients.  This option is ignored when {opt benchmark} is not specified.

{phang}
{cmd:testvalue(}[{it:{help operator:relop}}]{it:#}{cmd:)} tests whether the
estimated agreement coefficients equal {it:#}.  The default is
{cmd:testvalue(0)}.  {it:relop} is one of the relational operators
{cmd:>}[{cmd:=}] or {cmd:<}[{cmd:=}] and performs one-sided tests.

{phang}
{opt nociclipped} reports confidence intervals as estimated.  The default is
to restrict confidence limits to fall into the range of -1 < # < 1.

{phang}
{opt noheader} suppresses the report about the number of subjects, ratings per
subject, and rating categories.  Only the coefficient table is displayed.

{phang}
{opt notable} suppresses the display of the coefficient table.

{marker opt_di}{...}
{phang}
{it:format_options} are any of the following:

{phang2}
{cmd:cformat(}{it:{help format:{bf:%}fmt}}{cmd:)} specifies how to format
coefficients, standard errors, and confidence limits.  The maximum format
width is 8.

{phang2}
{cmd:pformat(}{it:{help format:{bf:%}fmt}}{cmd:)} specifies how to format
p-values.  The maximum format width is 5.

{phang2}
{cmd:sformat(}{it:{help format:{bf:%}fmt}}{cmd:)} specifies how to format test
statistics.  The maximum format width is 6.

{dlgtab:Advanced}

{phang}
{opt nsubjects(#)} specifies the size of the subject universe to be used for
the finite sample correction.  The default is {cmd:nsubjects(.)}, leading to a
sampling fraction of 0 that is assumed to be negligible.  This option is
seldom used.

{phang}
{opt nraters(#)} specifies the size of the rater population to be used for the
finite sample correction.  The default is {cmd:nraters(.)}, leading to a
sampling fraction of 0 that is assumed to be negligible.  This option is
relevant only for standard errors that are conditional on the sample of
subjects or unconditional standard errors.  It is seldom used although the
default might overestimate the variance for small rater populations.

{phang}
{opt largesample} specifies that the calculation of p-values and intervals be
based on the standard normal distribution rather than the t distribution.
This is the default for unconditional standard errors.  {opt largesample} is a
reporting option and it is seldom used.

{dlgtab:Immediate command}

{phang}
{opt tab} displays the two-way table of cell frequencies.  The option is
useful for data entry verification.

{dlgtab:Miscellaneous}

{marker opt_ttest}{...}
{phang}
{cmd:store(}{it:name}|{it:stub}{cmd:*}{cmd:)} returns additional results in
{cmd:r()} and stores them under {it:name}.  This option is intended for use
with the {opt ttest} option (see below).  Results are stored using 
{helpb _return:_return hold}.  Note that any results previously held under
{it:name} will be overwritten.  When the option {opt store()} is combined with
the {cmd:by} prefix, results are stored under {it:stub}{cmd:1} {it:...}
{it:stubq}.

{phang}
{opt ttest} performs paired t tests of correlated agreement coefficients.  See
{helpb kappaetc_ttest:kappaetc, ttest}.

{phang}
{opt icc(model)} estimates intraclass correlation coefficients as a measure of
interrater and intrarater reliability.  See
{helpb kappaetc_icc:kappaetc, icc()}.

{phang}
{cmd:loa}[{cmd:(}{it:#}{cmd:)}] estimates {it:#} percent limits of agreement
and produces a Bland-Altman plot.  See {helpb kappaetc_loa:kappaetc, loa()}.


{title:Remarks}

{pstd}
Remarks are presented under the following headings:

{phang2}
{help kappaetc##kap:Relation to official Stata's kap and kappa commands}
{p_end}
{phang2}
{help kappaetc##aka:Equivalent agreement coefficients}
{p_end}


{marker kap}{...}
{pstd}
{bf:{ul:Relation to official Stata's kap and kappa commands}}

{pstd}
The percent agreement that is reported by {cmd:kappaetc} is the same as the
observed agreement reported by Stata's {helpb kappa:kap} command.
{cmd:kappaetc} additionally estimates a standard error and confidence interval
for the observed agreement.

{pstd}
For two unique raters and no missing ratings, both {cmd:kappaetc} and Stata's
{cmd:kap} command estimate the same Cohen's kappa coefficient.  However, the
standard error and p-value differ between the two commands.  Stata's {cmd:kap}
command implements a model-based (analytic) approximate formula for the
standard error and reports a one-sided test based on the standard normal
distribution.  {cmd:kappaetc} implements a design-based formula to obtain the
standard error and reports a two-sided test based on the t distribution with
n-1 degrees of freedom.  {cmd:kappaetc} additionally provides a confidence
interval.

{pstd}
For more than two (nonunique) raters and no missing ratings (that is, a
constant number of ratings per subject), both {cmd:kappaetc} (possibly with
the {opt frequency} option) and Stata's {cmd:kap} (or {cmd:kappa}) command
estimate the same Fleiss kappa coefficient.  However, {cmd:kappaetc} does not
report a kappa coefficient for each rating category.  Standard errors and
p-values differ between the commands for the same reasons explained for the
two unique raters case above.


{marker aka}{...}
{pstd}
{bf:{ul:Equivalent agreement coefficients}}

{pstd}
The Brennan and Prediger coefficient, estimated by {cmd:kappaetc}, is
essentially equivalent to Bennet, Alpert, and Goldstein's (1954) S, the G
Index (Holley and Guilford 1964), the random-error coefficient (Maxwell 1970,
1977), Janson and Vegelius's (1979) C, Perreault and Leigh's (1989) Ir, and
Byrt, Bishop, and Carlin's (1993) prevalence-adjusted and bias-adjusted kappa,
also known as PABAK (compare Gwet [2014, 30, 65-69]).

{pstd}
Fleiss's kappa reduces to Scott's pi (1955) in the case of two raters (compare
Gwet [2014, 53]).  The latter is identical to Byrt, Bishop, and Carlin's
(1993) bias-adjusted kappa, also known as BAK (compare Gwet [2014, 69]).


{title:Examples}

{pstd}
Examples are drawn from those in {helpb kappa##examples:kap} and 
{manlink R kappa}.

{pstd}
Two raters{p_end}
{phang2}{cmd:. webuse rate2}{p_end}
{phang2}{cmd:. kappaetc rada radb}{p_end}
{phang2}{cmd:. kappaetc rada radb, wgt(linear)}{p_end}

{phang2}{cmd:. kapwgt xm 1 \ .8 1 \ 0 0 1 \ 0 0 .8 1}{p_end}
{phang2}{cmd:. kappaetc rada radb, wgt(xm, kapwgt)}{p_end}

{pstd}
More than two raters, varying number of ratings per subject (missing
values){p_end}
{phang2}{cmd:. webuse rvary2}{p_end}
{phang2}{cmd:. kappaetc rater1-rater5}{p_end}


{title:Stored results}

{pstd}
{cmd:kappaetc} stores the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 24 tabbed}{...}
{synopt:{cmd:r(N)}}number of subjects{p_end}
{synopt:{cmd:r(r)}}number of raters (maximum number of ratings per subject)
{p_end}
{synopt:{cmd:r(r_min)}}minimum number of ratings per subject{p_end}
{synopt:{cmd:r(r_avg)}}average number of ratings per subject{p_end}
{synopt:{cmd:r(r_max)}}maximum number of ratings per subject 
(same as {cmd:r(r)}){p_end}
{synopt:{cmd:r(jk_miss)}}number of missing jackknife coefficients{p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}

{pstd}
Macros{p_end}
{synoptset 24 tabbed}{...}
{synopt:{cmd:r(cmd)}}{cmd:kappaetc}{p_end}
{synopt:{cmd:r(wtype)}}weight type{p_end}
{synopt:{cmd:r(wexp)}}weight expression{p_end}
{synopt:{cmd:r(wgt)}}{it:wgtid} for weighting disagreement{p_end}
{synopt:{cmd:r(userwgt)}}{cmd:kapwgt} or {cmd:matrix}
(only with user-defined {it:wgtid}){p_end}
{synopt:{cmd:r(setype)}}{cmd:conditional} or {cmd:unconditional}{p_end}
{synopt:{cmd:r(seconditional)}}{cmd:raters} or {cmd:subjects}{p_end}

{pstd}
Matrices{p_end}
{synoptset 24 tabbed}{...}
{synopt:{cmd:r(b)}}coefficient vector{p_end}
{synopt:{cmd:r(table)}}information from the coefficient table{p_end}
{synopt:{cmd:r(se)}}standard errors{p_end}
{synopt:{cmd:r(b_jknife)}}jackknife coefficients{p_end}
{synopt:{cmd:r(se_cond_subjects)}}standard errors 
conditional on subjects{p_end}
{synopt:{cmd:r(se_cond_raters)}}standard errors 
conditional on raters{p_end}
{synopt:{cmd:r(df)}}coefficient-specific degrees of freedom{p_end}
{synopt:{cmd:r(prop_o)}}observed proportion of agreement{p_end}
{synopt:{cmd:r(prop_e)}}expected proportion of agreement{p_end}
{synopt:{cmd:r(W)}}weighting matrix for disagreement 
(note capitalization){p_end}
{synopt:{cmd:r(categories)}}distinct levels of ratings{p_end}
{synopt:{cmd:r(estimable)}}whether coefficient could be estimated{p_end}
{synopt:{cmd:r(table_benchmark_prob)}}information from the probabilistic
benchmark table{p_end}
{synopt:{cmd:r(table_benchmark_det)}}information from the deterministic
benchmark table{p_end}
{synopt:{cmd:r(benchmarks)}}upper limits of benchmark intervals{p_end}
{synopt:{cmd:r(imp)}}probability to fall into an interval{p_end}
{synopt:{cmd:r(p_cum)}}cumulative interval membership probability{p_end}
{synopt:{cmd:r(weight_i)}}subject-level weights{p_end}
{synopt:{cmd:r(b_istar)}}subject-level agreement coefficients{p_end}


{title:Acknowledgments}

{pstd}
I am deeply grateful to Kilem Gwet for continuous support and patiently
clarifying my questions during the implementation of {cmd:kappaetc}.

{pstd}
The name {cmd:kappaetc} is borrowed from {cmd:entropyetc} with approval from
Nicholas Cox (2016).


{title:References}

{phang}
Altman, D. G. 1991. {it:Practical Statistics for Medical Research}. London: 
Chapman & Hall.

{phang}
Bennet, E. M., R. Alpert, and A. C. Goldstein. 1954. Communications through 
limited response questioning. {it:Public Opinion Quarterly} 18: 303-308.

{phang}
Brennan, R. L., and D. J. Prediger. 1981. Coefficient kappa: Some uses, 
misuses, and alternatives. {it:Educational and Psychological Measurement} 41:
687-699.

{phang}
Byrt, T., J. Bishop, and J. B. Carlin. 1993. Bias, prevalence and 
kappa. {it:Journal of Clinical Epidemiology} 46: 423-429.

{phang}
Cohen, J. 1960. A coefficient of agreement for nominal
scales. {it:Educational and Psychological Measurement} 20: 37-46.

{phang}
------. 1968. Weighted kappa: Nominal scale agreement with provision for 
scaled disagreement or partial credit. {it:Psychological Bulletin} 70: 
213-220.

{phang}
Conger, A. J. 1980. Integration and generalization of kappas for multiple 
raters. {it:Psychological Bulletin} 88: 322-328.

{phang}
Cox, N. J. 2016. entropyetc: Stata module for entropy and related measures for categories. Statistical Software Components S458272, Department of Economics, Boston College. {browse "https://ideas.repec.org/c/boc/bocode/s458272.html"}.

{phang}
Fleiss, J. L. 1971. Measuring nominal scale agreement among many
raters. {it:Psychological Bulletin} 76: 378-382.

{phang}
Fleiss, J. L., B. Levin, and M. C. Paik. 2003. {it:Statistical Methods for Rates and Proportions}. 3rd ed. Hoboken, NJ: Wiley.

{phang}
Gwet, K. L. 2008. Computing inter-rater reliability and its variance in the
presence of high agreement. {it:British Journal of Mathematical and Statistical Psychology} 61: 29-48.

{phang}
------. 2014. {it:Handbook of Inter-Rater Reliability: The Definitive Guide to Measuring the Extent of Agreement Among Raters}. 4th ed. Gaithersburg, MD:
Advanced Analytics.

{phang}
Holley, J. W., and J. P. Guilford. 1964. A note on the G index of agreement. {it:Educational and Psychological Measurement} 24: 749-753.

{phang}
Janson, S., and J. Vegelius. 1979. On generalizations of the G index and the PHI
coefficient to nominal scales. {it:Multivariate Behavioral Research} 14:
255-269.

{phang}
Krippendorff, K. 1970. Estimating the reliability, systematic error and
random error of interval data. {it:Educational and Psychological Measurement}
30: 61-70.

{phang}
------. 2011. Computing Krippendorff's 
alpha-reliability. {browse "https://repository.upenn.edu/asc_papers/43/"}.

{phang}
------. 2013.  {it:Content Analysis: An Introduction to Its Methodology}. 3rd
ed. Thousand Oaks, CA: Sage.

{phang}
Landis, J. R., and G. G. Koch. 1977. The measurement of observer agreement 
for categorical data. {it:Biometrics} 33: 159-174.

{phang}
Maxwell, A. E. 1970 Comparing the classification of subjects by two
independent judges. {it:British Journal of Psychiatry} 116: 651-655.

{phang}
------. 1977. Coefficient of agreement between observers and their 
interpretation. {it:British Journal of Psychiatry} 130: 79-83.

{phang}
Perreault, W. D., and L. E. Leigh. 1989. Reliability of nominal data based on 
qualitative judgments. {it:Journal of Marketing Research} 26: 135-148.

{phang}
Scott, W. A. 1955. Reliability of content analysis: The case of nominal 
scale coding. {it:Public Opinion Quarterly} 19: 321-325.

{phang}
Warrens, M. J. 2014. Power weighted versions of Bennett, Alpert, and 
Goldstein's S. {it:Journal of Mathematics} 2014: 231909.

{phang}
Warrens, M. J., and B. C. Pratiwi. 2016. Kappa coefficients for circular 
classifications. {it:Journal of Classification} 33: 507-522.


{title:Author}

{pstd}
Daniel Klein{break}
International Centre for Higher Education Research Kassel{break}
Kassel, Germany{break}
klein@incher.uni-kassel.de


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 4: {browse "http://www.stata-journal.com/article.html?article=st0544":st0544}{p_end}

{p 7 14 2}
Help:  {manhelp kappa R}, {manhelp icc R}, {helpb kappa2}, {helpb kapci}, 
{helpb kappci}, {helpb kanom}, {helpb kalpha}, {helpb krippalpha}, {helpb kapssi},
{helpb concord}, {helpb classtabi}, {helpb entropyetc} (if installed){p_end}
