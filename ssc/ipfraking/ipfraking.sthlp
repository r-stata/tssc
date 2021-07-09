{smcl}
{* *! version 1.3.74  29Apr2018}{...}
{cmd:help ipfraking} {right: ({browse "http://web.missouri.edu/~kolenikovs/stata/":Stas Kolenikov's webpage})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{hi:ipfraking} {hline 2}}Weight raking by iterative proportional fitting{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 11 2}
{cmd:ipfraking}
{ifin}
{cmd:[pw=}{it:weight}{cmd:]}
[{cmd:,} {it:options}]

{synoptset 43 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Control figures}
{synopt :{cmdab:ctot:al(}{it:matname} [{it:matname} ...]{cmd:)}}matrices of control totals{p_end}
{syntab:The new weight variable}
{synopt :{cmdab:gen:erate(}{it:newvarname}{cmd:)}}new variable to write the raked weights to{p_end}
{synopt :{cmd:replace}}overwrite the existing weight variable{p_end}
{synopt :{cmd:double}}generate the new variable of {help double} type{p_end}
{syntab:Convergence control, diagnostic and reporting}
{synopt:{cmdab:iter:ate(}{it:#}{cmd:)}}maximum number of iterations{p_end}
{synopt:{cmdab:tol:erance(}{it:#}{cmd:)}}convergence tolerance{p_end}
{synopt:{cmdab:ctrltol:erance(}{it:#}{cmd:)}}required accuracy of the controls{p_end}
{synopt:{cmd:trace}}produce the trace plot{p_end}
{synopt:{cmdab:nodiv:ergence}}ignore divergence of the max difference of successive weights{p_end}
{synopt:{cmd:nograph}}suppress the diagnostic histograms{p_end}
{syntab:Trimming}
{synopt:{cmd:trimhirel(}{it:#}{cmd:)}}the upper bound on the greatest factor by which the weights can increase{p_end}
{synopt:{cmd:trimhiabs(}{it:#}{cmd:)}}the upper bound on the greatest value the weights can achieve{p_end}
{synopt:{cmd:trimlorel(}{it:#}{cmd:)}}the lower bound on the smallest factor by which the weights can increase{p_end}
{synopt:{cmd:trimloabs(}{it:#}{cmd:)}}the lower bound on the smallest value the weights can achieve{p_end}
{synopt:{cmdab:trimfreq:ency(}{it:keyword}{cmd:)}}stages of raking when weight trimming should be applied{p_end}
{syntab:Miscellaneous}
{synopt:{cmd:loglevel(}{it:#}{cmd:)}}level of detail in the output{p_end}
{synopt:{cmd:meta}}store some meta-info concerning the raking procedure{p_end}
{synopt:{cmd:linear}}perform linear calibration instead of raking{p_end}


{title:Description}

{pstd}{cmd:ipfraking} performs iterative proportional fitting, or raking,
to produce a set of calibrated survey weights such that the
sample weighted totals of control variables match the known population totals.
Typically, these control totals represent the number of population
units in categories of a discrete variable, such as age groups
in human surveys or industry in establishment surveys.
These control totals must come from a census, a survey of much
greater accuracy, or administrative data.

{pstd}The adjustment of the weights is performed by adjusting each of
the given control margins sequentially, until convergence is achieved.
In other words, for a given control variable (e.g., gender),
the {help total} sizes of subpopulations are estimated, and
the weights in separate categories (males, females) are multiplied
by a group-specific factor (ratio of the known population total
to the estimated total) so that the new set of weights produces
total estimates conforming to the known totals.

{pstd}
Please cite this package as Kolenikov (2012), ipfraking:
iterative proportional fitting weight calibration.


{title:Options}

{dlgtab:Section}

{phang}{cmd:option(}{it:whatever}{cmd:)}

{dlgtab:Control figures}

{phang}{cmdab:ctot:al(}{it:matrix_name} [{it:matrix_name} ...]{cmd:)} specifies the control totals.

{pmore}Each matrix is expected to be a result of Stata {help total} estimation command.
If the latter was issued with {cmd:over(}{help varname}{cmd:)} option,
the matrix has to be additionally augmented with the name of that variable as a rowname.
See {help ipfraking##remarks:Remarks} and {help ipfraking##examples:Examples}.

{phang}See Remark 1 below.

{dlgtab:Weight variable}

{phang}{cmdab:gen:erate(}{it:newvarname}{cmd:)} specifies the name of the new variable to contain the raked weights.

{phang}{cmd:replace} overwrite the existing weight variable

{phang}{cmd:double} generate the new variable as {help double} type{p_end}

{dlgtab:Convergence diagnostic and reporting}

{phang}{cmdab:iter:ate(}{it:#}{cmd:)} maximum number of iterations (default = 2000)

{phang}{cmdab:tol:erance(}{it:#}{cmd:)} convergence tolerance. Convergence will be declared if the largest relative difference
of the weights in two successive iterations (a full cycle over all raking variables) does not exceed this value.

{phang}{cmdab:ctrltol:erance(}{it:#}{cmd:)} required accuracy of the controls. If, upon convergence of the algorithm
(see the previous option), the relative difference of the weighted totals/means and the control totals/means
is greater than this value, an error message will be issued.

{phang}{cmd:trace} produce the trace plot to show how the control total discrepancy changes with the iteration number.

{phang}{cmdab:nodiv:ergence} ignore divergence of the objective function (max relative difference of the weights).

{phang}{cmd:alpha(}{it:#}{cmd:)} changes the adjustment factor to (factor)^alpha.

{phang}See Remark 2 below.

{phang}{cmd:nograph}suppress the diagnostic histograms to speed up the process.

{dlgtab:Trimming}

{phang}{cmd:trimhirel(}{it:#}{cmd:)} specifies the upper bound on the adjustment factor over the baseline weight. The weights
that exceeds the baseline times this value will be trimmed down.{p_end}

{phang}{cmd:trimhiabs(}{it:#}{cmd:)} specifies the upper bound on the greatest value of the raked weights.
The weights that exceed this value will be trimmed down.{p_end}

{phang}{cmd:trimlorel(}{it:#}{cmd:)} specifies the lower bound on the adjustment factor over the baseline weight.
The weights that are smaller than the baseline times this value will be increased.{p_end}

{phang}{cmd:trimloabs(}{it:#}{cmd:)} specifies the lower bound on the smallest value of the raked weights.
The weights that are smaller than this value will be increased.{p_end}

{phang}{cmdab:trimfreq:ency(}{it:keyword}{cmd:)} specifies when the trimming operations are to be performed.{p_end}

{phang2}{cmd:often} means that the trimming operations will be performed after each marginal adjustment.{p_end}

{phang2}{cmd:sometimes} means that the trimming operations will be performed in the end of each iteration
(cycle over all margins). This is the default setting.{p_end}

{phang2}{cmd:once} means that the trimming operation will be performed once, after convergence has been achieved.{p_end}

{phang}See Remark 3 below.{p_end}

{dlgtab:Miscellaneous}

{phang}{cmd:loglevel(}{it:#}{cmd:)} level of detail in the output.{p_end}

{phang2}0 is the default value; only the iteration log will be produced.{p_end}

{phang2}1 provides additional output on the intermediate trimming steps.{p_end}

{phang2}2 is a lot of detailed (and not always useful) output.{p_end}

{phang}{cmd:meta} puts the name(s) of the control vectors as a {help note}
stored with the variable specified in {cmd:generate()} option.{p_end}

{phang}{cmd:linear} performs linear calibration. As it is performed analytically,
it is much, MUCH faster than raking, but may produce negative weights if the
samples are way out of balance vis-a-vis the population.{p_end}

{title:Returned values}

{phang}Scalars:

{synopt:{cmd:r(converged)}}1, if convergence of the algorithm was achieved, and 0 otherwise.{p_end}
{synopt:{cmd:r(badcontrols)}}1, if any of the control totals or means were not approximated accurately, and 0 otherwise.{p_end}
{synopt:{cmd:r(maxreldif)}}the largest relative difference of the weights at the last iteration{p_end}
{synopt:{cmd:r(raked_mean)}}the mean of the raked weights{p_end}
{synopt:{cmd:r(raked_min)}}the smallest raked weight; >= {cmd:trimloabs()} value if specified{p_end}
{synopt:{cmd:r(raked_max)}}the largest raked weight; <= {cmd:trimhiabs()} value if specified{p_end}
{synopt:{cmd:r(raked_sd)}}the standard deviation of the raked weights{p_end}
{synopt:{cmd:r(raked_cv)}}coefficient of variation of the raked weights; useful in eyeballing the design effect as{p_end}

{phang2}{cmd:. display 1 + r(raked_cv)^2}{p_end}

{synopt:{cmd:r(factor_mean)}}the average adjustment factor{p_end}
{synopt:{cmd:r(factor_min)}}the smallest adjustment factor; >= {cmd:trimlorel()} value if specified{p_end}
{synopt:{cmd:r(factor_max)}}the greatest adjustment factor; <= {cmd:trimhirel()} value if specified{p_end}
{synopt:{cmd:r(factor_sd)}}the standard deviation of the adjustment factor{p_end}
{synopt:{cmd:r(factor_cv)}}coefficient of variation of the adjustment factor{p_end}

{phang}Macros:

{synopt:{cmd:r(ctotal)}}the list of the control vectors (copy of the {cmd:ctotal()} option)


{marker remarks}{title:Remark 1 -- control vectors}

{pstd}Matrices that {cmd:ipfraking} expects to receive as inputs via {opt ctotal(...)}
option must conform to the following specifications:

{phang2}1. They need to be {it:1 x c} matrices (row-vectors)

{phang2}2. They must have column names in estimation results format, i.e., {it:variable}:{it:#}.

{phang2}3. They must have rowname that contains the categorical variable over the categories of which
the totals were computed.

{pstd}These requirements are easily satisfied by getting the matrices as result of

{phang2}{cmd:total} {it:varname} {weight}, {cmd:over(}{it:varname}{cmd:, nolab)}

{pstd}The {cmd:nolab} option is important, otherwise, the column names
may contain the labels of the categorical variable that may be defined
differently in the sample, or not defined at all. Also, only one variable
should be specified in the {cmd:over()} option, as otherwise Stata provides
generic column names {cmd:_subpop_}{it:#} that are dependent on the data.


{title:Remark 2 -- convergence}

{pstd}For algorithmic purposes, convergence is defined as achieving
a stable state where the raked weights do not change (much) from
iteration to iteration. In some sources, convergence of the raking
algorithm is defined as whether the control totals are accurately
approximated. These are two separate outcomes. The procedure may
converge in the sense of having obtained stable weights, but these
weights may fail to satisfy the control totals.

{pstd}The current algorithm pursues convergence of the weights
to stable values, and its objective function is the maximum relative
difference in weights from one iteration to the next. The algorithm
continues as far as this difference declines, until this difference
is sufficiently small. Sometimes, especially with raking,
this objective function may start increasing.
Usually, this is only a temporary phenomenon that appears
for one to three iterations, after which the objective function
continues declining.

{pstd}If the algorithm converges with inadequate accuracy of the totals
(of which an error message will be issued), it means that the calibration
constraints have been difficult to satisfy. The most common solutions to
this problem is to omit some of the variables. In the (most common) case of the control
totals being the sizes of subpopulation groups, one can collapse/combine
some cells, thus specifying fewer control totals.

{pstd}Another common source of the lack of convergence to the control
totals are trimming requirements that are too strict. If the weights
converge, but control totals are not satisfied, try relaxing the trimming
parameters.


{title:Remark 3 -- trimming}

{pstd}Weight trimming is often used in practice to reduce the spread of weights,
and thus decrease the design effect. It may not be entirely clear what the effect
of trimming might be on estimates that are but weakly related to the control
variables, so this operation should be applied with caution.

{pstd}The setting {cmd:trimfreq(sometimes)} appears to make the greatest sense.
The weakness of the setting {cmd:trimfreq(once)} is that it does not guarantee that
the resulting weights ensure the calibration constraints. The weakness of
the setting {cmd:trimfreq(often)} is that the resulting weights may depend
on the order in which the calibration variables are entered, especially
when convergence is difficult to achieve.


{marker examples}{title:Examples}


{pstd}Calibration over a single margin (post-stratification){p_end}

{phang2}{cmd:. webuse nhanes2, clear}{p_end}
{phang2}{cmd:. * setting up the totals}{p_end}
{phang2}{cmd:. generate byte _one = 1}{p_end}
{phang2}{cmd:. svy: total _one, over(sex, nolab)}{p_end}
{phang2}{cmd:. matrix total_sex = e(b)}{p_end}
{phang2}{cmd:. matrix rownames total_sex = sex}{p_end}
{phang2}{cmd:. * obtaining the sample}{p_end}
{phang2}{cmd:. sample 500, count by(region)}{p_end}
{phang2}{cmd:. * calibrating the weights}{p_end}
{phang2}{cmd:. ipfraking [pw=finalwgt], ctotal(total_sex) generate(rakedwgt1)}{p_end}
{phang2}{cmd:. * quality control}{p_end}
{phang2}{cmd:. total _one [pw=rakedwgt1], over(sex)}{p_end}
{phang2}{cmd:. matrix list e(b), format(%12.0g)}{p_end}
{phang2}{cmd:. matrix list total_sex, format(%12.0g)}{p_end}

{pstd}Note that zero standard errors in the last estimation command
are appropriate: there is no sampling variability in these totals
since they are known.
Generally, however, the variances will be overestimated,
unlike with the proper {man poststratification}.
Also, {cmd:ipfraking} performs the quality control internally
and reports problems, if any.

{pstd}Calibration over two margins{p_end}

{phang2}{cmd:. webuse nhanes2, clear}{p_end}
{phang2}{cmd:. * setting up the totals}{p_end}
{phang2}{cmd:. generate byte _one = 1}{p_end}
{phang2}{cmd:. svy: total _one, over(sex, nolab)}{p_end}
{phang2}{cmd:. matrix total_sex = e(b)}{p_end}
{phang2}{cmd:. matrix rownames total_sex = sex}{p_end}
{phang2}{cmd:. svy: total _one, over(race, nolab)}{p_end}
{phang2}{cmd:. matrix total_race = e(b)}{p_end}
{phang2}{cmd:. matrix rownames total_race = race}{p_end}
{phang2}{cmd:. * obtaining the sample}{p_end}
{phang2}{cmd:. sample 500, count by(region)}{p_end}
{phang2}{cmd:. * calibrating the weights}{p_end}
{phang2}{cmd:. ipfraking [pw=finalwgt], ctotal(total_sex total_race) generate(rakedwgt2)}{p_end}


{pstd}Calibration over two margins with weight trimming{p_end}

{phang2}{cmd:. webuse nhanes2, clear}{p_end}
{phang2}{cmd:. * setting up the totals}{p_end}
{phang2}{cmd:. generate byte _one = 1}{p_end}
{phang2}{cmd:. svy: total _one, over(sex, nolab)}{p_end}
{phang2}{cmd:. matrix total_sex = e(b)}{p_end}
{phang2}{cmd:. matrix rownames total_sex = sex}{p_end}
{phang2}{cmd:. svy: total _one, over(race, nolab)}{p_end}
{phang2}{cmd:. matrix total_race = e(b)}{p_end}
{phang2}{cmd:. matrix rownames total_race = race}{p_end}
{phang2}{cmd:. * obtaining the sample}{p_end}
{phang2}{cmd:. sample 500, count by(region)}{p_end}
{phang2}{cmd:. * calibrating the weights}{p_end}
{phang2}{cmd:. ipfraking [pw=finalwgt], ctotal(total_sex total_race) trimhiabs(200000) generate(rakedwgt3)}{p_end}


{pstd}Calibration over two margins with weight trimming, failure to achieve the control totals:{p_end}

{phang2}{cmd:. webuse nhanes2, clear}{p_end}
{phang2}{cmd:. * setting up the totals}{p_end}
{phang2}{cmd:. generate byte _one = 1}{p_end}
{phang2}{cmd:. svy: total _one, over(sex, nolab)}{p_end}
{phang2}{cmd:. matrix total_sex = e(b)}{p_end}
{phang2}{cmd:. matrix rownames total_sex = sex}{p_end}
{phang2}{cmd:. svy: total _one, over(race, nolab)}{p_end}
{phang2}{cmd:. matrix total_race = e(b)}{p_end}
{phang2}{cmd:. matrix rownames total_race = race}{p_end}
{phang2}{cmd:. * obtaining the sample}{p_end}
{phang2}{cmd:. sample 500, count by(region)}{p_end}
{phang2}{cmd:. * calibrating the weights}{p_end}
{phang2}{cmd:. ipfraking [pw=finalwgt], ctotal(total_sex total_race) trimhiabs(200000) generate(rakedwgt4) trimhirel(5.4)}{p_end}


{title:References}

{phang}Deming, W. E., and Stephan, F. F. (1940).
On a Least Squares Adjustment of a Sampled Frequency Table When the Expected Marginal Totals are Known. {it:Annals of Mathematical Statistics} {bf:11} (4),
 427–444. doi: {browse "http://dx.doi.org/10.1214/aoms/1177731829":10.1214/aoms/1177731829}.

{phang}Ruschendorf, L. (1995). Convergence of the Iterative Proportional Fitting Procedure.
{it:The Annals of Statistics}, {bf:23} (4), pp. 1160-1174.
{browse "http://www.jstor.org/stable/2242759":JSTOR link}.

{phang}Deville, J.-C., Sarndal, C.-E., and Sautory, O. (1993). Generalized Raking Procedures in Survey Sampling
{it:Journal of the American Statistical Association}, {bf:88} (423) pp. 1013-1020.
{browse "http://www.jstor.org/stable/2290793":JSTOR link}.

{phang}Kott, P. (2006) Using Calibration Weighting to Adjust for Nonresponse and Coverage Errors.
{it:Survey Methodology}, {bf:32} (2), pp. 133­142.
{browse "http://www.statcan.gc.ca/pub/12-001-x/12-001-x2006002-eng.pdf":Statistics Canada website access}.

{phang}Kolenikov, S. (2014). Calibrating survey data using iterative proportional fitting.
{it:The Stata Journal}, {bf:14} (1), pp. 22--59.
{browse "https://ideas.repec.org/a/tsj/stataj/v14y2014i1p22-59.html":Stata Journal website}

{title:Author}

{pstd}Stanislav Kolenikov{p_end}
{pstd}Senior Scientist{p_end}
{pstd}Abt Associates{p_end}
{pstd}skolenik at gmail dot com{p_end}


{title:Also see}

{psee}{help survey} -- official survey capabilities of Stata

{psee}{help survwgt} package by N. Winter (weight calibration, jackknife and BRR weights)

{psee}{help maxentropy} package by M. Wittenberg ({browse "http://www.stata-journal.com/article.html?article=st0196":The Stata Journal article})

{psee}{help ipfweight} package by M. Bergmann

