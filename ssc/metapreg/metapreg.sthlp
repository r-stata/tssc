{smcl}
{* *! version 1.0.0 8May2019}{...}
{viewerdialog metapreg "dialog metapreg"}{...}
{vieweralsosee "[ME] meqrlogit" "help ME meqrlogit"}{...}
{vieweralsosee "[ME] meqrlogit" "mansection ME meqrlogit"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] binreg" "help R binreg"}{...}
{vieweralsosee "[R] binreg" "mansection R binreg"}{...}
{viewerjumpto "Syntax" "metapreg##syntax"}{...}
{viewerjumpto "Menu" "metapreg##menu"}{...}
{viewerjumpto "Description" "metapreg##description"}{...}
{viewerjumpto "Options" "metapreg##options"}{...}
{viewerjumpto "Remarks" "metapreg##remarks"}{...}
{viewerjumpto "Examples" "metapreg##examples"}{...}
{viewerjumpto "Stored results" "metapreg##results"}{...}

{title:Title}
{p2colset 5 18 25 2}{...}
{p2col :{opt metapreg} {hline 2}} Fixed-effects and random-effects meta-analysis and meta-analysis 
of proportions{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
[{help by} {varlist}{cmd::}] 
{opt metapreg n N} 
[{indepvars}] 
{ifin}
{cmd:,} 
{opt stu:dyid}({it:{help varname:studyid}}) 
[{it:{help metapreg##options_table:options}}]


{p 4 4 2}
{it:studyid} is a variable identifying each study.{p_end}
	
{p 4 6 2}{it:indepvars} may be {cmd:string} for categorical variables and/or {cmd:numeric} for continous variables. {cmd:The variable names should not contain underscores}.{p_end}

{marker options_table}{...}
{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synoptline}

{synopt :{opth m:odel(metapreg##modeltype:type[, modelopts])}}specifies the type of model to fit; default is {cmd:model(fixed)}. {help metapreg##optimization_options:modelopts}
control the control the optimization process{p_end}
{synopt :{opth sec:ond(metapreg##modeltype:type[, modelopts])}}specifies the second type of model to fit{p_end}
{synopt :{opt iv}}requests not to perform inverse-variance weighted meta-analysis. By default the logitstic regression model is fitted{p_end}
{synopt :{opt pair:ed}}requests to fit repeated measures logistic regression analysis  {p_end}
{synopt :{opt ft:t}}requests use Freeman-Tukey double arcsine transformation{p_end}
{synopt :{opth wgt:(varname:weightvar)}}specifies the {cmd:weightvar} with alternative weighting assigned to each study{p_end}
{synopt :{opth by:(varname:byvar)}}specificies the stratifying variable{p_end}
{synopt :{opth cc:(int:#)}}specifies a fixed continuity correction {p_end}


{synoptline}
{syntab:Reporting}
{synoptline}
{synopt :{opt nota:ble}}requests not to display the table with the study-specific estimates{p_end}
{synopt :{opth dp:(int:#)}} sets decimal points to display; default is {cmd:dp(2)}{p_end}
{synopt :{opth il:evel(level)}} sets confidence level for the individual studies; default is {cmd: ilevel(95)}{p_end}
{synopt :{opth ol:evel(level)}} sets confidence level for summaries and overall values; default is {cmd: olevel(95)}{p_end}
{synopt :{opth pow:er(int:#)}} sets the exponentiating power; default is {cmd: power(0)}. {cmd:#} is any real value {p_end}
{synopt :{opt plots:tat(label)}} specifies the label(name) for proportions/relative ratios in the graph {p_end}
{synopt :{opt tables:tat([raw(label) logodds(label) abs(label) rr(label)])}}specifies the labels for the displayed computed estimates in the summary tables{p_end} 
{synopt :{opth sor:tby(varlist)}}requests to sort the data by variables in {it:varlist}{p_end}
{synopt :{opth ci:method(metapreg##citype:citype)}}specifies how the confidence intervals 
for the individuals studies are computed; default is {cmd:cimodel(exact)} for proportions and {cmd:cimodel(koopman)} for relative ratios{p_end}
{synopt :{opth label:(varname:[namevar=varname], [yearvar=varname])}}specifies that date be labelled by its name and/or year{p_end}
{synopt :{opt noove:rall}} suppresses the overall estimate; by default the overall estimate is displayed{p_end}
{synopt :{opt nosub:group}}prevents the display of within-group summary estimates. By default both within-group and overall summaries are displayed{p_end}
{synopt :{opt nosecs:ub}}prevents the display of subestimates using the second model if {cmd:second()} is used{p_end}
{synopt :{opt rf:dist}}compute the predictive intervals{p_end}

{dlgtab:logit}

{synopt :{opth outp:lot(metapreg##output:abs|rr)}}specifies to display/plot absolute/relative measures; default is {cmd:outplot(abs)}{p_end}
{synopt :{opth outt:able(metapreg##output:all|raw|logodds|abs|rr)}}specifies to display the {cmd:raw coefficients} and group (adjusted) and overall(standardized) {cmd:log odds}, 
{cmd:proportions} and/or the {cmd:relative ratios}; by default only the study-specific and the overall estimates are displayed{p_end}

{dlgtab:nologit}

{synopt :{opt sgw:eight}}requests to display weight as percentage within each strata seperately; default is to display weight as 
percentage of the overall total weight{p_end}

{synoptline}
{syntab:Forest plot}
{synoptline}
{synopt :{opt nogr:aph}} suppresses the forest plot; by default the forestplot is displayed{p_end}
{synopt :{opt noov:line}} suppresses the overall line; by default the overall line is displayed{p_end}
{synopt :{opt sub:line}} displays the group line; by default the group lines is not displayed{p_end}
{synopt :{opt xla:bel(list)}} defines x-axis labels. No checks are made as to whether these points are sensible. 
So the user may define anything if the {cmd:force} option is used. The points in the list {cmd:must} be comma separated.{p_end}
{synopt :{opt fo:rce}} forces the x-axis scale to be in the range specified by {cmd:xlabel(list)}{p_end}
{synopt :{opt xt:ick(list)}} adds the listed tick marks to the x-axis. The points in the list {cmd:must}
be comma separated.{p_end}
{synopt :{opt nost:ats}} suppresses the display of study specific proportions(or the relative ratios) and the confidence intervals{p_end}
{synopt :{opt tex:ts(#)}}increases or decreases the text size of the label{p_end}
{synopt :{opth lc:ols(varlist)}}specifies additional columns to the left of the plot{p_end}
{synopt :{opth rc:ols(varlist)}}specifies additional columns to the right of the plor{p_end}
{synopt :{opt as:text(percentage)}}specifies the percentage of the graph to be taken up by text; default is {cmd:astext(50)}{p_end}
{synopt :{opt double:}}allows variables specified in {cmd:lcols(varlist)} and {cmd:rcols(varlist)} to run over two lines in the plot{p_end}
{synopt :{opt nohet:}}prevents display of heterogeneity statistics{p_end} 
{synopt :{opt summary:only}}requests to show only the summary estimates{p_end}
{synopt :{opth diam:opt(scatter##connect_options:connect_options)}}controls the diamonds{p_end}
{synopt :{opth point:opt(scatter##marker_options:marker_options)}}controls the points for the study estimates{p_end}
{synopt :{opth cio:pt(scatter##connect_options:connect_options)}}controls the appearance of confidence intervals for studies{p_end}
{synopt :{opth pred:ciopt(scatter##connect_options:connect_options)}}controls the appearance of the prediction intervals for studies{p_end}
{synopt :{opth ol:ineopt(scatter##connect_options:connect_options)}}controls the overall and subgroup estimates line{p_end} 
{synopt :{opth rfl:evel(level)}}sets the confidence level of the predictive interval; default is {cmd:rflevel(95)}{p_end}
{synopt :{opt cl:assic}} specifies that solid black boxes without point estimate markers are used{p_end}
{synopt :{help twoway_options}}specifies other overall graph options{p_end}

{dlgtab:nologit}
{synopt :{opth boxo:pt(scatter##marker_options:marker_options)}}controls the boxes (e.g., shape, colour, but not size){p_end}
{synopt :{opt boxs:ca(percentage)}}controls the {it:weighted} box scaling; default is boxsca(100){p_end}
{synopt :{opt nowt:}} suppresses the display of weights assigned to each study in perfoming weighted analysis{p_end}

{synoptline}
{marker modeltype}{...}
{synoptline}
{synopthdr :model type}
{synoptline}
{syntab:Independent analysis}

{synopt :{opt random}}fits a {cmd:random} study-effects{p_end}
{synopt :{opt fixed}}fits a {cmd:fixed}-effects{p_end}

{syntab:Repeated measures analysis}

{synopt :{opt random}}fits a model with {cmd:random} study and {cmd:random} treatment effects. This model allows the treatment effect to vary between the studies {p_end}
{synopt :{opt fixed}}fits a model with random study effects and {cmd:fixed} treatment effects{p_end}
{synopt :{opt marginal}}fits a model with {cmd:fixed} study effects and {cmd:fixed} treatment effects{p_end}

{synoptline}

{marker citype}{...}
{synopthdr :citype}
{synoptline}
{dlgtab:abs}

{synopt :{opt exact}}computes exact confidence intervals; the default{p_end}
{synopt :{opt wald}}computes Wald confidence intervals{p_end}
{synopt :{opt wilson}}computes Wilson confidence intervals{p_end}
{synopt :{opt agres:ti}}computes Agresti-Coull confidence intervals{p_end}
{synopt :{opt jeff:reys}}computes Jeffreys confidence intervals{p_end}

{dlgtab:rr}

{synopt :{opt koopman}}computes Koopman asymptotic score confidence intervals; the {cmd:default}. These intervals have better coverage even for small sample size{p_end}

{synoptline}
{marker outtable}{...}
{synopthdr :outtable}
{synoptline}
{synopt :{opt abs}}requests the display of the adjusted absolute measures in a table{p_end}
{synopt :{opt rr}}requests the display of the adjusted relative ratios in a table{p_end}
{synopt :{opt logodds}}requests the display of adjusted log-odds estimates of the fitted model in a table{p_end}
{synopt :{opt raw}}requests the display of raw coefficients of the fitted model in a table{p_end}

{synoptline}
{marker outplot}{...}
{synopthdr :outplot}
{synoptline}
{synopt :{opt abs}}requests the display of the study-specific and overall absolute measures in a table and /or a graph; the default{p_end}
{synopt :{opt rr}}requests the display of the study-specific and overall relative ratios in a table and /or a graph{p_end}

{synoptline}

{marker optimization_options}{...}
{synoptline}
{synopthdr :optimization options}
{synoptline}
{syntab:Maximization}
{synopt :{opt fisher(#)}}Fisher scoring steps{p_end}
{synopt :{opt search}}search for good starting values{p_end}
{synopt :{opt other options}}{opth tech:nique(maximize##algorithm_spec:algorithm_spec)},
	[{cmd:{ul:no}}]{opt lo:g},{opt tr:ace},{opt grad:ient},
	{opt showstep},
	{opt hess:ian},
	{opt showtol:erance},
	{opt dif:ficult},
	{opt iter:ate(#)}, 
	{opt tol:erance(#)},
	{opt ltol:erance(#)},
	{opt nrtol:erance(#)},{opt nonrtol:erance}, and
	{opt from(init_specs)}; see {manhelp maximize R}. These options are seldom used{p_end}

{syntab:Random-effects integration}
{synopt :{opt intp:oints(# [# ...])}}sets the number of 
integration (quadrature) points; default is {cmd:intpoints(7)}{p_end}
{synopt :{opt lap:lace}}use Laplacian approximation; equivalent to 
{cmd:intpoints(1)}{p_end}

{syntab :Random-effects maximization}
{synopt :{opt retol:erance(#)}}tolerance for random-effects estimates; default 
is {cmd:retolerance(1e-8)}; seldom used{p_end}
{synopt :{opt reiter:ate(#)}}maximum number of iterations for random-effects
estimation; default is {cmd:reiterate(50)}; seldom used{p_end}
{synopt :{opt matsqrt}}parameterize variance components using matrix square
roots; the default{p_end}
{synopt :{opt matlog}}parameterize variance components using matrix logarithms
{p_end}
{synopt :{opth refine:opts(meqrlogit##maximize_options:maximize_options)}}control
the maximization process during refinement of starting values
{p_end}
{synoptline}

{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:metapreg} is a routine for pooling and summarizing proportions 
from binomial data, from seperate but modelologically and 
epidemiologically similar studies. The routine implements the Dersimonian-Laird ({help metapreg##DL1986: Dersimonian and Laird 1986}) model for 
(inverse-variance) weighted analysis. Alternatively, 
a generalized linear model for the binomial family with a logit link is fitted, i.e logistic regression. 

{pstd}
In both cases, a fixed- and/or a random-effects model can be fitted. 
A random-effects model accounting for and allowing the quantification of heterogeneity between studies. 
A fixed-effects model assuming homogeneous studies or whenever the random-effects
model cannot be fitted, i.e when there are less than {cmd:3} studies.

{pstd}
In logistic regression {helpb meqrlogit} is used for the random-effects model and {helpb binreg} for the fixed-effects model. 
The binomial distribution is used to model the within-study variability ({help metapreg##Hamza2008:Hamza et al. 2008}).
Studies with less variability have more influence in the pooled estimate since they contribute more to the likelihhod function. The 
weighting is not explicit because parameter estimation is an iterative procedure. Therefore, even though the forest plot displays
equal weights for the individual studies, weighting is indeed done. The logistic regression requires at least two studies to run.

{pstd}
The random-effects model using the model of DerSimonian and Laird, the estimate of heterogeneity is taken from
the inverse-variance fixed-effect model. 

{pstd}
Stratified analysis can be done within the inverse-variance weighted framework while the logistic 
regression framework allows meta-regression and repeated measures analysis. When repeated measures analysis is perfomed, either the proportions
or the relative ratios can be tabulated and/or plotted (i.e with 1 or 2 covariates).

{pstd}
When there are no covariates, heterogeneity is also quantified using the I-squared measure({help metapreg##ZD2014:Zhou and Dendukuri 2014}).

{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opt model(type)} specifies the type of model to fit. {it:type} is either {cmd:fixed}, {cmd:marginal}  or {cmd:random}.

{pmore}
{cmd:model(fixed)} fits a fixed-effects model be fitted to the data. In repeated measures analysis, 
a conditional model with random study effects and fixed treatment effects is fitted.

{pmore}
{cmd:model(marginal)} fits a marginal model with fixed study effects and fixed treatment effects. This option is only relevant in 
repeated measures analysis. 

{pmore}
{cmd:model(random)} requests that random-effects model be fitted to the data. In repeated measures analysis, 
a conditional model with random study and random treatment effects. As such the model allows the treatment effect varies 
between the studies.

{phang}
{cmd:second({it:model})} 
A second analysis may be performed using another model, using {cmd:second(fixed)}, 
{cmd:second(random)}, or {cmd:second(marginal)}. Note that if {cmd:by} is used then sub-estimates
from the second model are not displayed with user defined estimates.

{phang}
{cmd:nologit} specificies the logistic regression should not be perfomed. The Dersimonian-Liard weighted-analysis is instead perfomed.

{phang}
{cmd:paired} Indicates that data is paired and to perfom repeated measures analysis. When there are paired observations from each study, the proportions are correlated. As such, models for independent samples are inappropriate. An analysis accounting for this dependence can help improve the precision of statistical inferences for within-study effects. 
This options is relevant in logistic regression and requires that data has atleast one covariate, a string covariate indicating the the first and second pair.


{phang}
{opt optimopts(options)} specifies the options that give the user
more control on the optimization process. The appropriate options 
feed into the {cmd:binreg}(see {it:{help binreg##maximize_options:maximize_options}}) 
or {cmd:meqrlogit} (see {it:{help meqrlogit##maximize_options:maximize_options}} and 
{it:{help meqrlogit##laplace:integration_options}}). 

{pmore}
The fixed-effects model is maximized using Stata's {help ml} command. This implies that
{cmd: irls} would be inadmissible option and {cmd: ml} is implicit. 

{pmore}
Examples, {cmd: optimopts(intpoint(9))} to increase the integration points, 
{cmd: optimopts(technique(bfgs))} to specify Stata's BFGS maximiztion algorithm.


{phang}
{cmd:ftt} Calculate the pooled estimate after Freeman-Tukey Double Arcsine 
Transformation({help metapreg##FT1950:Freeman, M. F. , and Tukey, J. W. 1950}) to stabilize the variances. 

{phang}
{opth wgt(weightvar)} specifies alternative weighting
for any data type. The pooled estimate size is to be computed by assigning 
a weight of {it:weightvar} to the studies. You should only use this option if you are
satisfied that the weights are meaningful. By default the weights are the inverse of the variance and 
are computed automatically from the data. In logistic regression, the weights are implicit from the data.

{phang}
{cmd:by(byvar)} specifies that the meta-analysis is to be stratified/grouped according to the variable declared. This is useful in investigating whether
the proportions vary between the group. The formal comparison should be perfomed in meta-regression by specifying covariates rather than with the {cmd:by()} option.

{pmore}
This option is not the same as the Stata {help by} prefix which repeates the analysis for each group of observation for which the values of the prefixed variable are the same.

{phang}
{cmd:cc(}{it:#}{cmd:)} defines a fixed continuity correction to add in the case where 
a study has zero success. In weighted-analysis, studies with zero success are automatically excluded. 
The {cmd:cc()} option allows the use of	{cmd:non-negative} constants. This option is not necessary
when the Freeman-Tukey Double Arcsine transformation is performed.

{dlgtab:Reporting}

{phang}
{opt notable} requests not to display the table{p_end}

{phang}
{opt dp(#)} sets decimal points to display in the table and graph; default is {cmd:dp(2)}{p_end}

{phang}
{opth ilevel(level)} sets confidence level for the individual studies confidence intervals; default is {cmd: ilevel(95)}
{cmd:ilevel()} and {cmd:olevel()} need not be the same.

{phang}
{opth olevel(level)} sets confidence level for summaries and overall values; default is {cmd: olevel(95)}
{cmd:ilevel()} and {cmd:olevel()} need not be the same.

{phang}
{opt power(#)} sets the exponentiating power with base 10; default is {cmd: power(0)}. Any real value is allowed. 
indicates the power of ten with which to multiply the estimates. 
{cmd: power(2)} would report percentages.
The x-axis labels should be adjusted accordingly when power(#) is adjusted.

{phang}
{opt plotstat(label)} specifies the label(name) for proportions/relative ratios in the forest plot and/or corresponding table{p_end}
 
{phang}
{opth sortby(varlist)} requests to sort the data by variables in {it:varlist}{p_end}

{phang}
{opt cimethod(citype)} specifies how the confidence intervals 
for the individuals studies are computed. 

{pmore}
{opt cimodel(exact)} is the default for proportions and specifies exact/Clopper-Pearson binomial confidence intervals.
The intervals are based directly
on the binomial distribution unlike the Wilson score or Agresti-Coull. Their actual
coverage probability can be more than nomial value. This conservative nature
of the interval means that they are widest, especially with 
small sample size and/or extreme probilities.

{pmore}
{opt cimodel(wald)} specifies the Wald confidence intervals. 

{pmore}
{opt cimodel(wilson)} specifies Wilson confidence intervals. 
Compared to the Wald confidence intervals, Wilson score intervals; 
have the actual coverage probability close to the nomimal value
and have good properties even with small sample size and/or extreme probilities.
However, the actual confidence level does not converge to the nominal level as {it:n}
increases.

{pmore}
{opt cimodel(agresti)} specifies the Agresti-Coull({help metapreg##AC1998:Agresti, A., and Coull, B. A. 1998}) confidence intervals
The intervals have better coverage with extreme probabilities
but slightly more conservation than the Wilson score intervals.

{pmore}
{opt cimodel(jeffreys)} specifies the Jeffreys confidence intervals

{pmore}
See {help metapreg##BCD2001:Brown, Cai, and DasGupta (2001)} and {help metapreg##Newcombe1998:Newcombe (1998)} for a discussion and
comparison of the different binomial confidence intervals.


{phang}
{opt label([namevar=varname] [yearvar=varname])}specifies that date be labelled by its name and/or year. Either or both variables 
need not be specified. For the table display, the overall length of the
label is restricted to 20 characters. The {cmd:lcols()} option will override this when specified.

{phang}
{opt nooverall} suppresses the overall estimate; by default the overall estimate is displayed. This automatically
enforces the {cmd: nowt} option.

{phang}
{opt nosubgroup} prevents the display of within-group summary estimates. By default both within-group and overall summaries are displayed{p_end}

{phang}
{opt nosecsub} prevents the display of subestimates using the second model if {cmd:second()} is used{p_end}

{phang}
{cmd:rfdist}
displays the confidence interval of the approximate predictive
distribution of a future study, based on the extent of heterogeneity in the random-effects model.

{pmore}
In weighted analysis, uncertainty on the spread of the random-
effects distribution using the formula {cmd: t(N-k) x sqrt(se2 + tau2)}
where t is the t-distribution with N-k degrees of freedom (N is the number of studies, k is the number of the model parameters), se2 is the
squared standard error and tau2 the heterogeneity statistic.
Note that with <3 studies the distribution is inestimable and effectively infinite, thus
displayed with dotted lines, and where heterogeneity is zero there is still
a slight extension as the t-statistic is always greater than the corresponding
normal deviate. For further information, see {help metapreg##HT2001:Higgins and Thompson 2001}.

{pmore}
In  logistic regression, the predictive intervals are percentile intervals following parametric simulations of the assumed predictive distribution.

{phang}
{opt outplot(abs|rr)} specifies to plot absolute/relative measures; default is {cmd:output(abs)}. 

{pmore} 
{opt outplot(abs)} is the default and specifies that the absolute measures be presented in the table and/or in the graph. 

{pmore}
{opt outplot(rr)} requests that the relative ratios be presented in the table and/or in the graph. This options is relevant in logistic regression with paired data. 

{phang}
{opt outtable(raw|logodds|abs|rr)} requests raw coefficients, summary the log odds, proportions and relative ratios from the the fitted model be presented in a table. This options is relevant in logistic regression.

{pmore}
{opt outtable(rr)} requests that the summary relative ratios be presented in the table. This options is relevant in logistic regression with paired data.

{pmore}
{opt output(all)} requests the {cmd: raw}, {cmd: logodds}, {cmd: abs} and {cmd: rr} summary estimates be presented in a table. This option is relevant in logistic regression.

{phang}
{opt sgweight} requests to display weight as percentage within each strata seperately; default is to display weight as 
percentage of the overall total weight{p_end}

{dlgtab:Forest plot}

{phang}
{opt nograph} suppresses the forest plot; by default the forestplot is displayed{p_end}

{phang}
{opt noovline} suppresses the overall line; by default the overall line is displayed{p_end}

{phang}
{opt subline} displays the group line; by default the group lines is not displayed{p_end}

{phang}
{opt xlabel(list)} defines x-axis labels. No checks are made as to whether these points are sensible. 
So the user may define anything if the {cmd:force} option is used. The points in the list {cmd:must} be comma separated.{p_end}

{phang}
{opt force} forces the x-axis scale to be in the range specified by {cmd:xlabel(list)}{p_end}

{phang}
{opt xtick(list)} adds the listed tick marks to the x-axis. The points in the list {cmd:must}
be comma separated.{p_end}

{phang}
{opt nostats} suppresses the display of study specific proportions(or the relative ratios) and the confidence intervals{p_end}

{phang}
{opt texts(#)} increases or decreases the text size of the
label by specifying {it:#} to be more or less than unity. The default is
usually satisfactory but may need to be adjusted.

{phang}
{cmd:lcols(}{it:varlist}{cmd:)}, {cmd:rcols(}{it:varlist}{cmd:)} 
define columns of additional data to 
the left or right of the plot. The first two columns on the right are 
automatically set to the estimate and weight, unless suppressed using 
the options {cmd:nostats} and {cmd:nowt}. {cmd:texts()} can be used to fine-tune 
the size of the text in order to achieve a satisfactory appearance. 
The columns are labelled with the variable label, or the variable name 
if this is not defined. The first variable specified in {cmd:lcols()} is assumed to be
the study identifier and this is used in the table output. 

{phang}
{opt astext(percentage)} specifies the percentage of the graph to be taken up by text; 
default is {cmd:astext(50)}. The percentage must be in the range 10-90.

{phang}
{opt double} allows variables specified in {cmd:lcols(varlist)} and {cmd:rcols(varlist)} to 
run over two lines in the plot. This may be of use if long strings are to be used.

{phang}
{opt nohet} prevents display of heterogeneity statistics{p_end} 

{phang}
{opt summaryonly} requests to show only the summary estimates. Useful in multiple subgroup analyses.

{phang}
{opth diamopt(options)} controls the appearance of the diamonds. 
See {help scatter##connect_options:connect_options} for the relevant options. e.g {cmd: diamopt(lcolor(red))}
displays {cmd:red} (a) red diamond(s).

{phang}
{opt pointopt(options)} controls the points for the study estimates. 
See {help scatter##marker_options:marker_options} for the relevant options. e.g {cmd: pointopt(msymbol(x)msize(0))}

{phang}
{opt ciopt(options)} ontrols the appearance of confidence intervals for studies. 
See {help scatter##connect_options:connect_options} for the relevant options.

{phang}
{opt predciopt(options)} controls the appearance of the prediction intervals for studies.
See {help scatter##connect_options:connect_options} for the relevant options.

{phang}
{opt olineopt(options)} controls the overall and subgroup estimates line. 
See {help scatter##connect_options:connect_options} for the relevant options.

{phang}
{opth rflevel(level)} sets the confidence level of the predictive interval; default is {cmd:rflevel(95)}.

{phang}
{opt classic} specifies that solid black boxes without point estimate markers are used.

{phang}
{opt boxopt(options)} controls the boxes (e.g., shape, colour, but not size).
See {help scatter##marker_options:marker_options} for the relevant options. This options is relevant in weighted analysis.

{phang}
{opt boxsca(percentage)} controls the {it:weighted} box scaling; default is boxsca(100). This options is relevant in weighted analysis.

{phang}
{opt nowt} suppresses the display of weights assigned to each study in perfoming weighted analysis. 
In logistic regression the weights are implicit and never displayed.
	
{phang}
{help twoway_options} specifies overall graph options that would appear at the end of a
when all the different plots are combined together. This allows the addition of titles, subtitles, captions,
etc., control of margins, plot regions, graph size, aspect ratio, and the use of schemes.

{marker examples}{...}
{title:Examples}
{marker example_one}{...}
{cmd : 1.1 Stratified weighted-analysis with untransformed proportions}

{pmore}
The dataset used in examples 1.1-1.3 was used previously to produce Figure 1 
in {help metapreg##MA_etal2009:Marc Arbyn et al. (2009)}.

{pmore}
Pooling untransformed proportions, grouped by triage group,
with specified x-axis label, ticks on x-axis added,
suppressed weights, increased text size, a red diamond for the confidence intervals of the pooled estimate, 
a black vertical line at zero, a red dashed line for the pooled estimate, e.t.c. 

{pmore2}
{stata "use http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta":. use http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta}
{p_end}

{pmore2}
{cmd :. #delimit ;}
{p_end}

{pmore2}
{cmd :. metapreg num denom, }
{p_end}
{pmore3}
{cmd : studyid(study) }
{p_end}
{pmore3}
{cmd :iv }
{p_end}
{pmore3}
{cmd :model(random) }
{p_end}
{pmore3}
{cmd :by(tgroup)  }
{p_end}
{pmore3}
{cmd :cimethod(exact) }
{p_end}
{pmore3}
{cmd :label(namevar=author, yearvar=year) }
{p_end}
{pmore3}
{cmd :xlab(.25,0.5,.75,1) }
{p_end}
{pmore3}
{cmd :xline(0, lcolor(black)) }
{p_end}
{pmore3}
{cmd :subti(Atypical cervical cytology, size(4)) }
{p_end}
{pmore3}
{cmd :xtitle(Proportion,size(2))  }
{p_end}
{pmore3}
{cmd :nowt }
{p_end}
{pmore3}
{cmd :olineopt(lcolor(red)lpattern(shortdash))}
{p_end}
{pmore3}
{cmd :plotregion(icolor(ltbluishgray)) }
{p_end}
{pmore3} 
{cmd :diamopt(lcolor(red)) }
{p_end}
{pmore3}
{cmd :pointopt(msymbol(x)msize(0))  }
{p_end}
{pmore3}
{cmd :boxopt(msymbol(S) mcolor(black)) }
{p_end}
{pmore3}
{cmd : astext(70)  }
{p_end}
{pmore3}
{cmd :texts(150);}	
{p_end}

{pmore2}
{cmd:. #delimit cr}
{p_end}

{pmore}
{it:({stata "metapreg_examples metapreg_example_one_one":click to run})}

{synoptline}
{cmd: 1.2 Separate mixed-effects logistic regression for each group in the by variable}

{pmore}
With the {cmd: by(tgroup)} option in {help metapreg##example_one:Example1.1} separate logistic regressions 
for each subgroup are fitted and the results combined in one graph and table. To obtain seperate tables and 
graphs, use instead the {help by} prefix instead i.e {cmd: bysort tgroup:} or {cmd: by tgroup:}.

{pmore}
Pooling proportions from raw cell counts with logistic regression for each category in triage group,
with specified x-axis label, ticks on x-axis added, score confidence intervals for the studies,
increased text size, a red diamond for the confidence intervals of the pooled estimate, a black 
vertical line at zero, a red dashed line for the pooled estimate, e.t.c.

{pmore2}
{stata "use http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta":. use http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta}
{p_end}

{pmore2}
{cmd:. #delimit cr}
{p_end}

{pmore2}
{cmd:. bys tgroup, rc0: metapreg num denom, }
{p_end}
{pmore3}
{cmd:studyid(study) }
{p_end}
{pmore3}
{cmd:model(random)  }
{p_end}
{pmore3}
{cmd:cimethod(wilson) }
{p_end}
{pmore3}
{cmd:label(namevar=author, yearvar=year)}
{p_end}
{pmore3}
{cmd:xlab(.25,0.5,.75,1) }
{p_end}
{pmore3}
{cmd:xline(0, lcolor(black)) }
{p_end}
{pmore3}
{cmd:subti(Atypical cervical cytology, size(4)) }
{p_end}
{pmore3}
{cmd:xtitle(Proportion,size(2))  }
{p_end}
{pmore3}
{cmd:olineopt(lcolor(red)lpattern(shortdash)) }
{p_end}
{pmore3}
{cmd:plotregion(icolor(ltbluishgray)) }
{p_end}
{pmore3} 
{cmd:diamopt(lcolor(red))}
{p_end}
{pmore3}
{cmd:astext(50) }
{p_end}
{pmore3}
{cmd:texts(90);}
{p_end}
{pmore3}

{pmore2}
{cmd:. #delimit cr}
{p_end}

{pmore2}
{it:({stata "metapreg_examples metapreg_example_one_two":click to run})}

{synoptline}
{cmd: 1.3 Mixed-effects logistic meta-regression with one covariate}

{pmore}
 The use of {cmd: by(tgroup)} in {help metapreg##example_one:Example1.1} only allows informal testing of heterogeneity between the sub-groups.
 The formal testing is perfomed by fitting a logistic regression with triage used as a categorical variable and {cmd:entered in string format}. 
 Since {cmd:tgroup} is a factor variable, the {help decode} function creates the new string variable based on the existing numerical variable and its value labels.

{pmore}
Pooling proportions from raw cell counts with logistic regression with triage group as a covariate,
with specified x-axis label, ticks on x-axis added,
increased text size, a red diamond for the confidence intervals of the pooled estimate, a black vertical line at zero, a red dashed line for the pooled estimate, e.t.c.

{pmore2}
{stata "use http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta":. use http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta}
{p_end}

{pmore2}
{cmd:. decode tgroup, g(STRtgroup)}
{p_end}

{pmore2}
{cmd:. metapreg num denom STRtgroup, ///}
{p_end}
{pmore3}
{cmd:studyid(study) ///}
{p_end}
{pmore3}
{cmd:outtable(all) ///}
{p_end}
{pmore3}
{cmd:model(random)  ///}
{p_end}
{pmore3}
{cmd:cimethod(exact) ///}
{p_end}
{pmore3}
{cmd:label(namevar=author, yearvar=year) ///}
{p_end}
{pmore3}
{cmd:xlab(.25,0.5,.75,1) ///}
{p_end}
{pmore3}
{cmd:xline(0, lcolor(black)) ///}
{p_end}
{pmore3}
{cmd:subti(Atypical cervical cytology, size(4)) ///}
{p_end}
{pmore3}
{cmd:xtitle(Proportion,size(2))  ///}
{p_end}
{pmore3}
{cmd:olineopt(lcolor(red)lpattern(shortdash)) ///}
{p_end}
{pmore3}
{cmd:plotregion(icolor(ltbluishgray)) ///}
{p_end}
{pmore3} 
{cmd:diamopt(lcolor(red)) ///}
{p_end}
{pmore3}
{cmd:astext(50) ///}
{p_end}
{pmore3}
{cmd:texts(90)}
{p_end}

{pmore2}		
{it:({stata "metapreg_examples metapreg_example_one_three":click to run})}


{synoptline}
{marker example_two_one}{...}
{cmd : 2.1 Weighted-analysis with Freeman-Tukey double arcsine transformed proportions}

{pmore}
Pooling proportions with Freeman-Tukey double arcsine transformation, 
with specified x-axis label, ticks on x-axis added,
suppressed weights, increased text size, a black diamond for the confidence intervals of the pooled estimate, a black vertical line at zero, a red dashed line, for the pooled estimate, e.t.c.

{pmore}
The dataset used in this example produced the top-left graph in figure one in
{help metapreg##Ioanna_etal2009:Ioanna Tsoumpou et al. (2009)}.

{pmore2}
{stata "use http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2WNL.dta":. use http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2WNL.dta}
{p_end}

{pmore2}
{cmd:.	metapreg p16p p16tot, ///}
{p_end}
{pmore3}
{cmd: studyid(study) ///}
{p_end}
{pmore3}
{cmd: iv ///}
{p_end}
{pmore3}
{cmd: model(random) ///}
{p_end}
{pmore3}
{cmd: ftt ///}
{p_end}
{pmore3}
{cmd: label(namevar=author, yearvar=year) ///}
{p_end}
{pmore3}
{cmd: sortby(year author) ///}
{p_end}
{pmore3}
{cmd: xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) ///}
{p_end}
{pmore3}
{cmd: xline(0, lcolor(black)) ///}
{p_end}
{pmore3}
{cmd: ti(Positivity of p16 immunostaining, size(4) color(blue)) ///}
{p_end}
{pmore3}
{cmd: subti("Cytology = WNL", size(4) color(blue)) ///}
{p_end}
{pmore3}
{cmd: xtitle(Proportion,size(3)) ///}
{p_end}
{pmore3}
{cmd: nowt ///}
{p_end}
{pmore3}
{cmd: nostats ///}
{p_end}
{pmore3}
{cmd: olineopt(lcolor(red) lpattern(shortdash)) ///}
{p_end}
{pmore3}
{cmd: diamopt(lcolor(black)) ///}
{p_end}
{pmore3}
{cmd: pointopt(msymbol(x)msize(0)) ///}
{p_end}
{pmore3}
{cmd: boxopt(msymbol(S) mcolor(black))  ///}
{p_end}
{pmore3}
{cmd: astext(70) ///}
{p_end}
{pmore3}
{cmd: texts(100) ///}
{p_end}
{pmore}
{it:({stata "metapreg_examples metapreg_example_two_one":click to run})}

{synoptline}
{cmd : 2.2 Mixed-effects logistic regression}

{pmore}
In {help metapreg##example_two_one:Example2.1}  the {cmd:ftt} options option enables inclusion of studies with proportion eaqual to {cmd:0} which would otherwise be excluded in the classical weighted analysis. Logistic regression correctly handles the extreme cases appropriately without need for transformation.
 
 {pmore2}
{stata "use http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2WNL.dta":. use http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2WNL.dta}
{p_end}

{pmore2}
{cmd:.	metapreg p16p p16tot, ///}
{p_end}
{pmore3}
{cmd: model(random) /// }
{p_end}
{pmore3}
{cmd: studyid(study) ///}
{p_end}
{pmore3}
{cmd: label(namevar=author, yearvar=year) /// }
{p_end}
{pmore3}
{cmd: sortby(year author) ///}
{p_end}
{pmore3}
{cmd: xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) /// }
{p_end}
{pmore3}
{cmd: xline(1, lcolor(black)) ///}
{p_end}
{pmore3}
{cmd: ti(Positivity of p16 immunostaining, size(4) color(blue)) ///}
{p_end}
{pmore3}
{cmd: subti(Cytology = HSIL, size(4) color(blue)) ///}
{p_end}
{pmore3}
{cmd: xtitle(Proportion,size(3)) ///}
{p_end}
{pmore3}
{cmd: nostats ///}
{p_end}
{pmore3}
{cmd: olineopt(lcolor(red) lpattern(shortdash)) ///}
{p_end}
{pmore3}
{cmd: diamopt(lcolor(black)) ///}
{p_end}
{pmore3}
{cmd: pointopt(msymbol(s)msize(2)) /// }
{p_end}
{pmore3}
{cmd: astext(70) ///}  
{p_end}
{pmore3}
{cmd: texts(100)}
{p_end}

 {pmore2}
{it:({stata "metapreg_examples metapreg_example_two_two":click to run})}


{synoptline}
{marker example_three_one}{...}
{cmd : 3.1 Risk-ratios: Mixed-effects logistic meta-regressions with one covariate}

{pmore}
The data used in examples 3.1-3.3 are as presented in table IV of {help metapreg##Berkey_etal1995:Berkey et al. (1995)}
By supplying the risk-ratios and their variability, {help metapreg##Sharp1998:Sharp (1998)} Sharp demonstrates meta-analysis of odds-ratios with the {help meta} command. He fitted a random and a fixed effects model to the data. 

{pmore}
To appropriately account for both within- and between-study heterogeneity, logistic regression with repeated measures is fitted with vaccination arm as a covariate. The options {cmd:paired} indicates that the data is paired. The first covariate, identifies the first and the second observations of the pair. The risk-ratios can be requested with the option {cmd:outplot(rr)}. All output tables are requested with the {cmd:outtable(lor logodds abs rr)}. 

{pmore}
To fit an equivalent random and a fixed effects model to the data as in {help metapreg##Sharp1998a:Sharp (1998)}, use the options {cmd: model(fixed)} and {cmd:second(marginal)} respectively. Risk-ratios and not odds-ratios are presented because they are more comprehensible.
   
{pmore2}
{stata `"use "https://github.com/VNyaga/Metapreg/blob/master/bcg.dta?raw=true""':. use "https://github.com/VNyaga/Metapreg/blob/master/bcg.dta?raw=true"}
{p_end}

{pmore2}
{cmd: .metapreg cases_tb population bcg,  /// }
{p_end}
{pmore3}
{cmd: studyid(study) ///}
{p_end}
{pmore3}
{cmd: model(fixed)  /// }
{p_end}
{pmore3}
{cmd: second(marginal) ///}
{p_end}
{pmore3}
{cmd: outtable(raw logodds abs rr)  ///}
{p_end}
{pmore3}
{cmd: tablestat(raw(Raw_Coeff) logodds(Logit) abs(Proportion) rr(Risk_ratio)) ///}
{p_end}
{pmore3}
{cmd: paired	///}
{p_end}
{pmore3}
{cmd: outplot(rr) ///}
{p_end}
{pmore3}
{cmd: plotstat(Risk ratio) ///}
{p_end}
{pmore3}
{cmd: plotregion(color(white)) /// }
{p_end}
{pmore3}
{cmd: graphregion(color(white)) /// }
{p_end}
{pmore3}
{cmd: xlab(0, 1, 2) /// }
{p_end}
{pmore3}
{cmd: xtick(0, 1, 2)  /// }
{p_end}
{pmore3}
{cmd: force ///} 
{p_end}
{pmore3}
{cmd: xtitle(Relative Ratio,size(2)) /// }
{p_end}
{pmore3}
{cmd: olineopt(lcolor(black) lpattern(shortdash)) /// }
{p_end}
{pmore3}
{cmd: diamopt(lcolor(black)) /// }
{p_end}
{pmore3}
{cmd: rcols(cases_tb population) /// }
{p_end}
{pmore3}
{cmd: astext(80) /// }
{p_end}
{pmore3}
{cmd: texts(150)} 
{p_end}

{pmore2} 
{it:({stata "metapreg_examples metapreg_example_three_one":click to run})}


{synoptline}
{marker example_three_two}{...}
{cmd : 3.2 Risk-ratios: Mixed-effects logistic meta-regressions with a matching covariate}

{pmore}
In {help metapreg##example_three_two:Example3.2} the effects for arm are fixed. To allow the arm effects to vary between-studies, use {cmd:model(random)} option together with {cmd:paired} option.

{pmore2}
{stata `"use "https://github.com/VNyaga/Metapreg/blob/master/bcg.dta?raw=true""':. use "https://github.com/VNyaga/Metapreg/blob/master/bcg.dta?raw=true"}
{p_end}

{pmore2}
{cmd: .metapreg cases_tb population bcg,  /// }
{p_end}
{pmore3}
{cmd: studyid(study) ///}
{p_end}
{pmore3}
{cmd: model(random)  /// }
{p_end}
{pmore3}
{cmd: second(fixed) ///}
{p_end}
{pmore3}
{cmd: outtable(raw logodds abs rr)  ///}
{p_end}
{pmore3}
{cmd: paired	///}
{p_end}
{pmore3}
{cmd: outplot(rr) ///}
{p_end}
{pmore3}
{cmd: plotstat(Risk ratio) ///}
{p_end}
{pmore3}
{cmd: plotregion(color(white)) /// }
{p_end}
{pmore3}
{cmd: graphregion(color(white)) /// }
{p_end}
{pmore3}
{cmd: xlab(0, 1, 2) /// }
{p_end}
{pmore3}
{cmd: xtick(0, 1, 2)  /// }
{p_end}
{pmore3}
{cmd: force ///} 
{p_end}
{pmore3}
{cmd: xtitle(Relative Ratio,size(2)) /// }
{p_end}
{pmore3}
{cmd: olineopt(lcolor(black) lpattern(shortdash)) /// }
{p_end}
{pmore3}
{cmd: diamopt(lcolor(black)) /// }
{p_end}
{pmore3}
{cmd: rcols(cases_tb population) /// }
{p_end}
{pmore3}
{cmd: astext(80) /// }
{p_end}
{pmore3}
{cmd: texts(150)} 
{p_end}

{pmore2} 
{it:({stata "metapreg_examples metapreg_example_three_two":click to run})}


{synoptline}
{cmd :3.3 Risk-ratios: Mixed-effects logistic meta-regressions with a matching and continous covariate}

{pmore}
With {help metareg}, {help metapreg##Sharp1998:Sharp (1998)} investigages the effect of latitude on BCG vaccination. The analysis suggested that BCG vaccination was more effective at higher absolute latitude.

{pmore}
A logistic regression with {cmd:bcg}, a categorical variable for the arm and {cmd:lat}, a continous variable with absolute latitude are fitted. 

{pmore}
Activated by the option {cmd:interaction}, an interaction term allows to assess whether the log OR for arm vary by absolute latitude. 

{pmore}
The interaction term from {cmd:metapreg} and the coefficient for lat using {cmd:metareg} as was done by {help metapreg##Sharp1998:Sharp (1998)} are equivalent. 

{pmore2}
{stata `"use "https://github.com/VNyaga/Metapreg/blob/master/bcg.dta?raw=true""':. use "https://github.com/VNyaga/Metapreg/blob/master/bcg.dta?raw=true"}
{p_end}

{pmore2}
{cmd:. metapreg cases_tb population bcg lat,  /// }
{p_end}
{pmore3}
{cmd:studyid(study) ///}
{p_end}
{pmore3}
{cmd:model(fixed, optimopts(intpoints(1)))  /// }
{p_end}
{pmore3}
{cmd:sortby(lat) ///}
{p_end}
{pmore3}
{cmd:second(marginal) ///}
{p_end}
{pmore3}
{cmd:outtable(all) ///}
{p_end}
{pmore3}
{cmd:paired  ///}
{p_end}
{pmore3}
{cmd:outplot(rr) ///}
{p_end}
{pmore3}
{cmd:interaction ///}
{p_end}
{pmore3}
{cmd:plotregion(color(white)) /// }
{p_end}
{pmore3}
{cmd:graphregion(color(white)) /// }
{p_end}
{pmore3}
{cmd:xlab(0, 1, 2) ///} 
{p_end}
{pmore3}
{cmd:xtick(0, 1, 2)  /// }
{p_end}
{pmore3}
{cmd:force ///} 
{p_end}
{pmore3}
{cmd:xtitle(Relative Ratio,size(2)) ///} 
{p_end}
{pmore3}
{cmd:plotstat(Rel Ratio) ///}
{p_end}
{pmore3}
{cmd:olineopt(lcolor(black) lpattern(shortdash)) /// }
{p_end}
{pmore3}
{cmd:diamopt(lcolor(black)) /// }
{p_end}
{pmore3}
{cmd:rcols(cases_tb population) ///} 
{p_end}
{pmore3}
{cmd:astext(80) ///} 
{p_end}
{pmore3}
{cmd:texts(150) }  
{p_end}

{pmore2}
{it:({stata "metapreg_examples metapreg_example_three_three":click to run})}

{synoptline}
{marker example_four_one}{...}
{cmd : 4.1 Risk-ratios: Mixed-effects logistic meta-regressions with a matching and a categorical covariate}
{pmore}
Using {help metan}, {help metapreg##Chaimani_etal2014:Chaimani et al. (2014)} informaly assessed the difference in treatment effect of haloperidol compared to placebo in treating schizophrenia.

{pmore}
The analysis is more appropriately perfomed using {cmd:metapreg} by including {cmd:arm} and {cmd:missingdata} as covariates. The interaction term allows to test whether the risk-ratios for arm differ between the group with  and without missing data.

{pmore2}
{stata `"use "https://github.com/VNyaga/Metapreg/blob/master/schizo.dta?raw=true""':. use "https://github.com/VNyaga/Metapreg/blob/master/schizo.dta?raw=true"}
{p_end}

{pmore2}
{cmd:. metapreg response total arm missingdata,  ///}
{p_end}
{pmore3}
{cmd:studyid(firstauthor) ///}
{p_end}
{pmore3}
{cmd:sortby(year) ///}
{p_end}
{pmore3}
{cmd:model(fixed)  ///}
{p_end}
{pmore3}
{cmd:second(marginal) ///}
{p_end}
{pmore3}
{cmd:outtable(all) ///}
{p_end}
{pmore3}
{cmd:paired  ///}
{p_end}
{pmore3}
{cmd:outplot(rr) ///}
{p_end}
{pmore3}
{cmd:interaction ///}
{p_end}
{pmore3}
{cmd:plotregion(color(white)) ///}
{p_end}
{pmore3}
{cmd:graphregion(color(white)) ///}
{p_end}
{pmore3}
{cmd:xlab(0, 5, 15) ///}
{p_end}
{pmore3}
{cmd:xtick(0, 5, 15)  /// }
{p_end}
{pmore3}
{cmd:force ///}
{p_end}
{pmore3}
{cmd:xtitle(Relative Ratio,size(2)) ///}
{p_end}
{pmore3}
{cmd:plotstat(Rel Ratio) ///}
{p_end}
{pmore3}
{cmd:olineopt(lcolor(black) lpattern(shortdash)) ///}
{p_end}
{pmore3}
{cmd:diamopt(lcolor(black)) /// }
{p_end}
{pmore3}
{cmd:lcols(firstauthor year) /// }
{p_end}
{pmore3}
{cmd:astext(80) /// }
{p_end}
{pmore3}
{cmd:texts(150)}


{pmore2}		
{it:({stata "metapreg_examples metapreg_example_four_one":click to run})}

{synoptline}
{marker example_four_one}{...}
{cmd : 4.2 Proportions: Mixed-effects logistic meta-regressions with a matching and a categorical covariate}

{pmore}
If it is preferred to present the absolute proportions, use the option {cmd:outplot(abs)}.

{pmore2}
{stata `"use "https://github.com/VNyaga/Metapreg/blob/master/schizo.dta?raw=true""':. use "https://github.com/VNyaga/Metapreg/blob/master/schizo.dta?raw=true"}
{p_end}

{pmore2}
{cmd:. metapreg response total arm missingdata,  ///}
{p_end}
{pmore3}
{cmd:studyid(firstauthor) ///}
{p_end}
{pmore3}
{cmd:sortby(missingdata arm year) ///}
{p_end}
{pmore3}
{cmd:model(fixed)  ///}
{p_end}
{pmore3}
{cmd:second(marginal) ///}
{p_end}
{pmore3}
{cmd:outtable(all) ///}
{p_end}
{pmore3}
{cmd:paired  ///}
{p_end}
{pmore3}
{cmd:outplot(abs) ///}
{p_end}
{pmore3}
{cmd:interaction ///}
{p_end}
{pmore3}
{cmd:plotregion(color(white)) ///}
{p_end}
{pmore3}
{cmd:graphregion(color(white)) ///}
{p_end}
{pmore3}
{cmd:xlab(0, 5, 15) ///}
{p_end}
{pmore3}
{cmd:xtick(0, 5, 15)  /// }
{p_end}
{pmore3}
{cmd:force ///}
{p_end}
{pmore3}
{cmd:xtitle(Proportion,size(2)) ///}
{p_end}
{pmore3}
{cmd:plotstat(Proportion) ///}
{p_end}
{pmore3}
{cmd:olineopt(lcolor(black) lpattern(shortdash)) ///}
{p_end}
{pmore3}
{cmd:diamopt(lcolor(black)) /// }
{p_end}
{pmore3}
{cmd:lcols(firstauthor year) /// }
{p_end}
{pmore3}
{cmd:astext(80) /// }
{p_end}
{pmore3}
{cmd:texts(120)}


{pmore2}		
{it:({stata "metapreg_examples metapreg_example_four_two":click to run})}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:metapreg} stores the following in {cmd:r()}:

{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(i_sq)}}Estimated I squared{p_end}
{synopt:{cmd:r(wtau2)}}Within-study variability in paired studies{p_end}
{synopt:{cmd:r(tau2)}}Between-study variability{p_end}
{synopt:{cmd:r(p_chi2)}}p-value for LR comparing the fixed and random effects models{p_end}
{synopt:{cmd:r(chi2)}}chisq. for LR comparing the fixed and random effects models{p_end}
{synopt:{cmd:r(p_het)}}p-value for Q heterogeneity statistic{p_end}
{synopt:{cmd:r(df)}}Degrees of freedom{p_end}
{synopt:{cmd:r(het)}}Q heterogeneity statistic{p_end}
{synopt:{cmd:r(p_z)}}p-value for testing if ES=0 (IV) or ES=0.5 (logistic){p_end}
{synopt:{cmd:r(z)}}Z for testing if ES=0 (IV) or ES=0.5 (logistic){p_end}
{synopt:{cmd:r(ci_upp)}}upper confidence limit of the overall estimate{p_end}
{synopt:{cmd:r(ci_low)}}lower confidence limit of the overall estimate{p_end}
{synopt:{cmd:r(seES)}}standard error of the overall estimate{p_end}
{synopt:{cmd:r(ES)}}Overall estimate{p_end}

{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(paired)}}paired analysis indicator{p_end}
{synopt:{cmd:r(model)}}model fitted{p_end}
{synopt:{cmd:r(measure)}}plotted statistic{p_end}

{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(rrout)}}summary relative ratios{p_end}
{synopt:{cmd:r(absout)}}summary proportions{p_end}
{synopt:{cmd:r(logodds)}}summary log-odds{p_end}
{synopt:{cmd:r(raw)}}Fitted raw coefficients{p_end}
{p2colreset}{...}

{title:Technical note}
{pstd}
When prefix {cmd:by} or {cmd:second()} is used, only the results from the last group or the first model will be stored respectively.

{title:Author}
{pmore}
Victoria N. Nyaga ({it:Victoria.NyawiraNyaga@sciensano.be}) {p_end}
{pmore}
Belgian Cancer Center/Unit of Cancer Epidemiology, {p_end}
{pmore}
Sciensano,{p_end}
{pmore} 
Juliette Wytsmanstraat 14, {p_end}
{pmore}
B1050 Brussels, {p_end}
{pmore}
Belgium.{p_end}

{title:References}

{marker AC1998}{...}
{phang}
Agresti, A., and Coull, B. A. 1998. Approximate is better than 'exact'
for interval estimation of binomial proportions. {it:The American Statistician.}
52:119-126. 

{marker ZD2014}{...}
{phang}
Zhou, Y., and Dendukuri, N. 2014. Statistics for quantifying heterogeneity in univariate 
and bivariate meta-analyses of binary data: The case of meta-analyses of diagnostic accuracy.
{it:Statistics in Medicine} 33(16):2701-2717.

{marker BCD2001}{...}
{phang}
Brown, L. D., T. T. Cai, and A. DasGupta. 2001.  
Interval estimation for a binomial proportion. 
{it:Statistical Science} 16: 101-133.

{marker CP1934}{...}
{phang}
Clopper, C. J., and E. S. Pearson. 1934.  The
use of confidence or fiducial limits illustrated in the case of the binomial.  
{it:Biometrika} 26: 404-413.

{marker Hamza2008}{...}
{phang}
Hamza et al. 2008. The binomial distribution of meta-analysis was preferred to model within-study variability. 
{it:Journal of Clinical Epidemiology} 61: 41-51.

{marker HT2001}{...}
{phang}
Higgins, J. P. T., and S. G. Thompson.  2001. Presenting random-effects
meta-analyses: Where we are going wrong?  {it:9th International Cochrane
Colloquium, Lyon, France}.

{marker DL1986}{...}
{phang}
DerSimonian, R. and Laird, N. 1986. Meta-analysis in clinical trials. {it:Controlled Clinical Trials} 7(3):177-188. 

{marker Newcombe1998}{...}
{phang}
Newcombe, R. G. 1998. Two-sided confidence intervals for 
the single proportion: comparison of seven models. 
{it:Statistics in Medicine} 17: 857-872.

{marker Pavlou_etal2015}{...}
{phang}
Pavlou M. et. al. 2015.
A note on obtaining correct marginal predictions from a random intercepts model for binary outcomes.
{it:BMC Medical Research modelology} 15(1):1-6

{marker MA_etal2009}{...}
{phang}
Arbyn, M., et al. 2009. Triage of women with equivocal
or low-grade cervical cytology results.  A meta-analysis
of the HPV test positivity rate.
{it:Journal for Cellular and Molecular Medicine} 13(4):648-59.

{marker Ioanna_etal2009}{...}
{phang}
Tsoumpou, I., et al. 2009. p16INK4a immunostaining in 
cytological and histological specimens from the uterine 
cervix: a systematic review and meta-analysis. 
{it:Cancer Treatment Reviews} 35: 210-20.

{marker Sharp1998}{...}
{phang}
Stephen Sharp. 1998. sbe23. Meta-analysis regression. 
{it:Stata Technical Bulletin} 16-22.

{marker Berkey_etal1995}{...}
{phang}
Berkey, C., et al. 1995. A random-effects regression model for meta-analysis. 
{it:Statistics in Medicine} 14:395-411.

{marker Chaimani_etal2014}{...}
{phang}
Chaimani, A., Mavridis, D., & Salanti G. 2014. A hands-on practical tutorial on perfoming meta-analysis with Stata. 
{it:Evidence Based Mental Health} 17(4):111-116.
