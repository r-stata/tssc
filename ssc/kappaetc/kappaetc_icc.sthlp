{smcl}
{cmd:help kappaetc, icc()}{right: ({browse "http://www.stata-journal.com/article.html?article=st0544":SJ18-4: st0544})}
{hline}

{title:Title}

{p2colset 5 24 26 2}{...}
{p2col:{cmd:kappaetc, icc()} {hline 2}}Interrater and intrarater
reliability{p_end}
{p2colreset}{...}


{title:Syntax}

{pstd}
One-way random-effects model, intraclass correlation coefficients

{p 8 16 2}
{cmd:kappaetc} 
{it:{help varname:varname1}} 
{it:{help varname:varname2}}
[{it:{help varname:varname3}} {it:...}]
{ifin}{cmd:, icc(oneway)} [{it:{help kappaetc_icc##opts:options}}]


{pstd}
Two-way random-effects model, intraclass correlation coefficients

{p 8 16 2}
{cmd:kappaetc} 
{it:{help varname:varname1}} 
{it:{help varname:varname2}}
[{it:{help varname:varname3}} {it:...}]
{ifin}{cmd:, icc(random)} [{it:{help kappaetc_icc##opts:options}}]


{pstd}
Two-way mixed-effects model, intraclass correlation coefficients

{p 8 16 2}
{cmd:kappaetc} 
{it:{help varname:varname1}} 
{it:{help varname:varname2}}
[{it:{help varname:varname3}} {it:...}]
{ifin}{cmd:, icc(mixed)} [{it:{help kappaetc_icc##opts:options}}]


{synoptset 30 tabbed}{...}
{marker opts}{...}
{synopthdr}
{synoptline}
{p2coldent:* {cmd:icc(}{it:model} [{cmd:,} {it:model_options}]{cmd:)}}fit 
{it:model}; see {help kappaetc_icc##opt_model:{it:Options}}{p_end}
{synopt:{cmdab:i:d(}{varname}{cmd:)}}specify subject identifier for 
repeated measurements{p_end}
{synopt:{opt list:wise}}exclude observations with missing ratings{p_end}
{synopt:{opt bal:anced}}keep only subjects with the same number of repeated 
measurements{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is 
{cmd:level({ccl level})}{p_end}
{synopt:{opt testval:ue(#)}}test whether intraclass correlation coefficients 
are equal to {it:#}; default is {cmd:testvalue(0)}{p_end}
{synopt:{opt stddev:iations}}show random effects and error effect as standard 
deviations; the default{p_end}
{synopt:{opt var:iance}}show random effects and error effect as variances
{p_end}
{synopt:{opt nociclip:ped}}do not clip confidence intervals at 0 and 1{p_end}
{synopt:{opt noh:eader}}suppress output header{p_end}
{synopt:{opt notab:le}}suppress coefficient table{p_end}
{synopt:{it:{help kappaetc##opt_di:format_options}}}control column formats
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* {cmd:icc()} is required.
{p_end}
{p 4 6 2}
{cmd:by} is allowed; see {manlink D by}.
{p_end}


{title:Description}

{pstd}
{cmd:kappaetc} with the {opt icc()} option estimates intraclass correlation
coefficients as a measure of interrater and intrarater reliability.  The
command implements one-way random-effects, two-way random-effects and
mixed-effects models, optionally with repeated measurements.

{pstd}
All models are implemented using formulas for unbalanced designs given in Gwet
(2014).  Intraclass correlation coefficients are estimated in the presence of
missing values; test statistics and confidence intervals, however, are based
on methods for complete data.

{pstd}
{cmd:kappaetc} with the {opt icc()} option assumes that observations are
subjects (units of analysis) and variables contain the ratings by raters
(coders, judges, observers).  Subjects with m repeated measurements are
represented by m observations in the dataset.


{title:Options}

{marker opt_model}{...}
{phang}
{cmd:icc(}{it:model} [{cmd:,} {it:model_options}]{cmd:)} specifies the model
to be fit.  {cmd:icc()} is required.  The available models and
{it:model_options} are described below.

{phang2}
{opt one:way} fits the one-way random-effects model (model 1A).  This model
assumes that each subject is rated by a different group of raters.  Thus, the
subject is the only (random) factor.  Intrarater reliability cannot be
assessed.  The {it:model_option} {opt b} is allowed and requests model 1B to
be fit.  Here the rater is the single (random) factor, and each of the raters
may rate a different set of subjects.  This latter model is seldom used and
cannot be used to estimate interrater reliability.

{phang2}
{opt rand:om} fits the two-way random-effects model (model 2).  Here each
subject is rated by the same group of raters.  Subjects are assumed to be
randomly selected from a universe of subjects, and raters are assumed to be
drawn from the rater population.  The {it:model_option} {opt blend} is allowed
and specifies that the subject-rater interaction be blended together with the
error variance; this is relevant only if some subjects are rated repeatedly by
the same rater.

{phang2}
{opt mixed} fits the two-way mixed-effects model (model 3).  In this model,
each subject is rated by the same group of raters.  Subjects are assumed to be
randomly selected from a universe of subjects.  Raters are assumed to be the
only ones of interest and do not represent any larger rater population.  The
{it:model_option} {opt blend} is allowed and specifies that the subject-rater
interaction be blended together with the error variance; this is relevant only
if some subjects are rated repeatedly by the same rater.

{phang}
{opt id(varname)} declares {it:varname} the subject identifier when subjects
are measured repeatedly.  If specified with a two-way model, interrater and
intrarater reliability is estimated.

{phang}
{opt listwise} specifies that observations with missing ratings be excluded
from the analysis.  Do not confuse observations with subjects in the case of
repeated measurements.  This option does not create a balanced design; for
that, see option {opt balanced} below.  {opt case:wise} is a synonym for
{cmd:listwise}.

{phang}
{opt balanced} restricts the estimation sample to subjects with the same
number of repeated measures.  If the maximum number of repeated measurements is
m, then all subjects that have been measured less than m times are excluded.
Note that this option does not exclude observations with missing values; for
that, see option {opt listwise} above.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence 
intervals.  The default is {cmd:level({ccl level})}.

{phang}
{opt testvalue(#)} tests whether intraclass correlation coefficients are equal
to {it:#}.  The default is {cmd:testvalue(0)}.  One-sided F tests are
performed.

{phang}
{opt stddeviations} displays the random effects and error effect as standard
deviations.  This is the default.

{phang}
{opt variance} displays the random effects and error effect as variances.

{phang}
{opt nociclipped} reports confidence intervals as estimated.  The default is
to restrict confidence limits to fall into the range of 0 < # < 1.

{phang}
{opt noheader} suppresses the report about the number of subjects, ratings per
subject, and rating categories.  Only the coefficient table is displayed.

{phang}
{opt notable} suppresses the display of the coefficient table.

{phang}
{it:{help kappaetc##opt_di:format_options}} are the same as with 
{helpb kappaetc##opt_di:kappaetc}.


{title:Examples}

{pstd}
Examples are drawn from {helpb icc##examples:icc} and {manlink R icc}{p_end}
{phang2}{cmd:. webuse judges}{p_end}
{phang2}{cmd:. reshape wide rating, i(target) j(judge)}{p_end}

{pstd}
One-way random-effects model{p_end}
{phang2}{cmd:. kappaetc rating1-rating4, icc(oneway)}{p_end}

{pstd}
Two-way random-effects model{p_end}
{phang2}{cmd:. kappaetc rating1-rating4, icc(random)}{p_end}


{title:Stored results}

{pstd}
{cmd:kappaetc} with the {opt icc()} option stores the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 24 tabbed}{...}
{synopt:{cmd:r(N)}}number of subjects{p_end}
{synopt:{cmd:r(r)}}number of raters{p_end}
{synopt:{cmd:r(r_min)}}minimum number of ratings per subject{p_end}
{synopt:{cmd:r(r_avg)}}average number of ratings per subject{p_end}
{synopt:{cmd:r(r_max)}}maximum number of ratings per subject{p_end}
{synopt:{cmd:r(M)}}number of observed measurements{p_end}
{synopt:{cmd:r(M_missing)}}number of missing measurements{p_end}
{synopt:{cmd:r(m_min)}}minimum number of replicates per subject{p_end}
{synopt:{cmd:r(m_avg)}}average number of replicates per subject{p_end}
{synopt:{cmd:r(m_max)}}maximum number of replicates per subject{p_end}
{synopt:{cmd:r(icc)}}intraclass correlation coefficient 
(interrater reliability){p_end}
{synopt:{cmd:r(icc_a)}}intraclass correlation coefficient 
(intrarater reliability){p_end}
{synopt:{cmd:r(sigma2_s)}}subject variance{p_end}
{synopt:{cmd:r(sigma2_r)}}rater variance{p_end}
{synopt:{cmd:r(sigma2_sr)}}subject-rater interaction variance{p_end}
{synopt:{cmd:r(sigma2_e)}}error variance{p_end}
{synopt:{cmd:r(MSS)}}mean squares between subjects{p_end}
{synopt:{cmd:r(MSR)}}mean squares between raters{p_end}
{synopt:{cmd:r(MSI)}}subject-rater interaction mean squares{p_end}
{synopt:{cmd:r(MSE)}}error mean squares{p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}
{synopt:{cmd:r(icc_df_2)}}denominator degrees of freedom for intracluster correlation coefficient (ICC){p_end}
{synopt:{cmd:r(icc_df_1)}}numerator degrees of freedom for ICC{p_end}
{synopt:{cmd:r(icc_F)}}F statistic for ICC{p_end}
{synopt:{cmd:r(icc_a_df_2)}}denominator degrees of freedom for ICCa
(repeated measurements only){p_end}
{synopt:{cmd:r(icc_a_df_1)}}numerator degrees of freedom for ICCa
(repeated measurements only){p_end}
{synopt:{cmd:r(icc_a_F)}}F statistic for ICCa
(repeated measurements only){p_end}
{synopt:{cmd:r(has_sr)}}whether subject-rater interaction has been
estimated{p_end}

{pstd}
Macros{p_end}
{synoptset 24 tabbed}{...}
{synopt:{cmd:r(cmd)}}{cmd:kappaetc}{p_end}
{synopt:{cmd:r(cmd2)}}{cmd:icc}{p_end}
{synopt:{cmd:r(model)}}fit model ({cmd:oneway}, {cmd:random}, 
or {cmd:mixed}){p_end}
{synopt:{cmd:r(model_number)}}fit model number ({cmd:1}, {cmd:1B}, 
{cmd:2}, or {cmd:3}){p_end}

{pstd}
Matrices{p_end}
{synoptset 24 tabbed}{...}
{synopt:{cmd:r(table)}}information from the coefficient table{p_end}


{title:Reference}

{phang}
Gwet, K. L. 2014. {it:Handbook of Inter-Rater Reliability: The Definitive Guide to Measuring the Extent of Agreement Among Raters}. 4th ed.
Gaithersburg, MD: Advanced Analytics.


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
Help:  {manhelp kappa R}, {manhelp icc R}, {helpb kappaetc} (if installed){p_end}
