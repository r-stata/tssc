{smcl}
{* *! version 3.1.3  22jul2015}{...}
{vieweralsosee "mvmeta_make (if installed)" "mvmeta_make"}{...}
{vieweralsosee "metan (if installed)" "metan"}{...}
{vieweralsosee "metareg (if installed)" "metareg"}{...}
{vieweralsosee "network (if installed)" "network"}{...}
{viewerjumpto "Description" "mvmeta##description"}{...}
{viewerjumpto "Syntax" "mvmeta##syntax"}{...}
{viewerjumpto "Model options" "mvmeta##modeloptions"}{...}
{viewerjumpto "Estimation options" "mvmeta##estimationoptions"}{...}
{viewerjumpto "Output options: fixed parameters" "mvmeta##outputoptionsfixed"}{...}
{viewerjumpto "Output options: weights and borrowing of strength" "mvmeta##wt"}{...}
{viewerjumpto "Output options: probability-of-being-best" "mvmeta##pbest"}{...}
{viewerjumpto "Output options: variance parameters" "mvmeta##outputoptionsvar"}{...}
{viewerjumpto "Output options: miscellaneous" "mvmeta##outputoptionsmisc"}{...}
{viewerjumpto "Covariance structures" "mvmeta##covstructures"}{...}
{viewerjumpto "Studies in which some outcomes are unestimated" "mvmeta##missing"}{...}
{viewerjumpto "Changes in mvmeta version 2.3" "mvmeta##changes2"}{...}
{viewerjumpto "Changes from version 2.3 to version 3.1" "mvmeta##changes3"}{...}
{viewerjumpto "Examples" "mvmeta##examples"}{...}
{viewerjumpto "Details" "mvmeta##details"}{...}
{viewerjumpto "Known problems" "mvmeta##problems"}{...}
{viewerjumpto "References" "mvmeta##references"}{...}
{viewerjumpto "Author and updates" "mvmeta##updates"}{...}
{title:Title}

{phang}
{bf:mvmeta} {hline 2} Multivariate random-effects meta-analysis and meta-regression


{title:Description}{marker description}

{p 4 4 2}
Standard meta-analysis combines estimates of one parameter over several studies. 
Multivariate meta-analysis is an extension that can combine estimates of several related parameters. 
For example, we may have estimates of treatment effects on two different outcomes in a set of randomised trials, 
or we may have estimates of the difference in outcome between "high", "medium" and "low" levels of a covariate. 
For further discussion of the multivariate meta-analysis model and its applications see {help mvmeta##Jackson++11:Jackson et al (2011)}.

{p 4 4 2}
{cmd:mvmeta} performs multivariate random-effects meta-analysis {help mvmeta##White09:(White, 2009)} 
and multivariate random-effects meta-regression {help mvmeta##White11:(White, 2011)}
on a data-set of point estimates, variances and (optionally) covariances.

{p 4 4 2}Demonstrations are available on 
{help mvmetademo_setup:getting the data into mvmeta format} 
and {help mvmetademo_run:running mvmeta}.

{p 4 4 2}If you are doing network meta-analysis, please see my {help network} suite,
which includes commands to formulate and run {cmd:mvmeta} models for network meta-analysis.


{title:Syntax}{marker syntax}

{p 8 17 2}
{cmd:mvmeta} b V [xvars]
{ifin}
[{cmd:,} 
{* MODEL OPTIONS}
{cmdab:v:ars(}{it:varlist}{cmd:)}
{cmd:wscorr(}{it:expression}|{cmd:riley}{cmd:)}
{cmdab:bscov:ariance(}{it:covtype [matexp]}{cmd:)}
{cmdab:eq:uations(}{it:yvar1}:{it:xvars1}[, {it:yvar2}:{it:xvars2}[, ...]]{cmd:)}
{cmdab:nocons:tant}
{cmdab:common:parm}
{* ESTIMATION OPTIONS}
{cmd:reml}|{cmd:ml}|{cmd:mm1}|{cmd:mm2}|{cmd:fixed}
{cmd:start(}{it:expression}{cmd:)}
{cmd:longparm}
{cmd:noposdef}
{cmd:psdcrit(#)}
{it:maximize_options}
{cmdab:supp:ress(}[fe] [uv] [mm]{cmd:)} 
{* OUTPUT OPTIONS: FIXED}
{cmdab:nounc:ertainv}
{cmd:eform}[({it:name})]
{cmd:dof(}{it:expression}{cmd:)}
{cmd:randfix}[({it:suboptions})]
{* OUTPUT OPTIONS: WT}
{cmd:wt}[({it:suboptions})]
{* OUTPUT OPTIONS: PBEST}
{cmd:pbest(min}|{cmd:max} {ifin}, {it:pbest_options}{cmd:)}
{* OUTPUT OPTIONS: VAR}
{cmd:print(}{it:string}{cmd:)}
{cmd:i2}
{opth i2fmt(%fmt)}
{cmd:ciscale(sd}|{cmd:logsd}|{cmd:logh)} 
{cmdab:test:sigma}
{* OUTPUT OPTIONS: MISC}
{cmdab:shows:tart}
{cmd:id(}{it:varname}{cmd:)}
{cmdab:showa:ll}]

{p 4 4 2}
where the data are arranged with one line per study: 
the point estimates are held in variables b*, 
the variance of bx is held in variable Vxx, 
and the covariance of bx and by is held in variable Vxy. 
If you have individual participant data, you can use {helpb mvmeta_make} 
to produce a dataset of the required format.


{title:Model options}{marker modeloptions}

{phang}
{cmdab:v:ars(}{it:varlist}{cmd:)} specifies which variables are to be used. 
By default, all variables named b* are used, but any variable named b is ignored.
Note that {cmd:vars(}b1 b2 b3{cmd:)} and {cmd:vars(}b3 b2 b1{cmd:)} 
specify the same model but a different parameterisation.

{phang}
{cmd:wscorr(}{it:expression}{cmd:)} specifies the value of all within-study correlations. 
This means that covariance variables Vxy need not exist. 
(For any that do exist, {cmd:wscorr()} is ignored.) 
Alternatively, {cmd:wscorr(riley)} can be used when within-study correlations are unknown.
It uses the alternative model of {help mvmeta##Riley++08:Riley et al (2008)} to estimate an overall correlation.
{help mvmeta##Riley09:Riley (2009)} discusses other ways to handle unknown within-study correlations.

{phang}
{cmdab:bscov:ariance(}{it:covtype [matexp]}{cmd:)}
specifies the between-studies covariance structure: 
see {help mvmeta##covstructures:Covariance structures} below.

{phang}
{cmdab:eq:uations(}{it:yvars1:xvars1 [,yvars2:xvars2[,...]]}{cmd:)} 
allows different outcomes to have different regression models. 
For example, {cmd:equations(y1 y2:x1, y3:x2)} regresses y1 and y2 on x1 and y3 on x2.

{phang}
{cmdab:nocons:tant} suppresses the constant in the regression models.

{phang}
{cmdab:common:parm} forces the coefficients to be the same for all outcomes. 
This option requires all equations to contain the same number of variables. 
It can be useful in network meta-analysis and is illustrated in {help mvmeta##White12:White et al (2012)}.


{title:Estimation options}{marker estimationoptions}

{phang}
{cmd:reml} specifies that restricted maximum likelihood is to be used for estimation (the default).

{phang}
{cmd:ml} specifies that maximum likelihood is to be used for estimation.
This is likely to underestimate the variance, so restricted maximum likelihood is usually preferred.

{phang}
{cmd:mm1} specifies that the multivariate method of moments procedure of
{help mvmeta##Jackson++10:Jackson et al, 2010} is to be used for estimation. 
This is a multivariate generalisation of the procedure of 
{help mvmeta##DL:DerSimonian and Laird (1986)} and is faster than the likelihood-based methods.
However, the {cmd:mm2} option is to be preferred.

{phang}
{cmd:mm2} specifies that the multivariate method of moments procedure of
{help mvmeta##Jackson++13:Jackson et al, 2013} is to be used for estimation. 
This is a matrix-based extension of the method given by the {cmd:mm1} option and is to be preferred.
This method is used if {cmd:mm} is specified.

{phang}
{cmd:fixed} specifies that the fixed-effect model 
(that is, the model allowing no heterogeneity between studies) 
is to be used for estimation.

{phang}
{cmd:start(}{it:matrix}|{it:matrix expression}|{cmd:mm}|{it:#}{cmd:)} specifies a starting value for the between-studies variance. The syntax depends on the covariance structure: see {help mvmeta##covstructures:Covariance structures} below.

{phang}
{cmd:longparm} parameterises the model as one regression model for each outcome. 
Without covariates, this is usually less convenient than the default 
(all outcomes forming a single regression model), but is required if the {cmd:pbest()} option will be used. 
With covariates, {cmd:longparm} is the default and cannot be changed.

{phang} {cmd:noposdef} does not immediately halt execution if a within-study variance-covariance matrix is declared not to be positive semidefinite.

{phang} {cmd:psdcrit(}{it:#}{cmd:)} changes the criterion for judging a variance/covariance matrix not to be positive semidefinite. 
A variance-covariance matrix is regarded as positive semidefinite if the ratio of the smallest to the largest ratio is greater than the negative of #. Default is 1E-8.

{phang}{it:maximize_options} allows standard maximization options: see {manhelp maximize R}.

{phang}
{cmdab:supp:ress(}[fe] [uv] [mm]{cmd:)} suppresses one of more of the following analyses 
which are run by default:
a fixed-effect analysis (for the {cmd:randfix()} option), 
univariate analyses (for the {cmd:wt(rv)} option), 
and a method-of-moments analysis with unstructured covariance matrix (for the {cmd:i2} option).
This option is useful if these analyses fail. 


{title:Output options: fixed parameters}{marker outputoptionsfixed}

{phang}
{cmdab:nounc:ertainv} computes alternative (smaller) standard errors that ignore
the uncertainty in the estimated variance-covariance matrix, and therefore
agree with results produced by procedures such as SAS PROC MIXED (without the
ddfm=kr option) and {helpb metareg}. (Note however that confidence intervals do not
agree, because {cmd:mvmeta} by default uses a Normal approximation whereas the other procedures
approximate the degrees of freedom of a t distribution.)

{phang}
{cmd:eform}[({it:name})] exponentiates the reported mean parameters and, 
if the optional argument is used, reports them as {it:name}.

{phang}{cmd:dof(}{it:expression}{cmd:)} specifies the degrees of freedom for t-tests and confidence intervals. 
The expression may include "n", the number of observations. The default is to use a normal distribution.

{phang}{cmd:randfix}[({it:varlist})] describes the impact of heterogeneity on the estimated coefficients in the models for the specified variables (which must be outcome variables in the fitted model). 
If no varlist is specified then all outcome variables are used. 

{pmore}
The method is described by {help mvmeta##Jackson++12:Jackson et al (2012)}.
The estimated variance-covariance matrix is compared with that estimated under a fixed-effect model: 
the square roots of the determinants of these matrices are reported, followed by R, defined as the qth root of the ratio of these square roots, where q is the number of parameters involved. 
R is a multivariate generalisation of the R statistic of {help mvmeta##HigginsThompson02:Higgins and Thompson (2002)}, who note that R is often approximately equal to H, where I^2=(H^2-1)/H^2.


{title:Output options: weights and borrowing of strength}{marker wt}

{p 4 4 2}The option {cmd:wt}[({it:suboptions})]
reports study weights and/or borrowing of strength.
A publication describing the methods is under review. The {it:suboptions} are:

{phang}
{cmd:sd} (the default) reports study weights and borrowing of strength 
using the score decomposition method.
The method computes, for each parameter, the percentage of the total information for that parameter 
by study and source, 
where source is direct (from that outcome), borrowed (from other outcomes) and total.
By default, the total for each study across sources
and the total for each source across studies are reported. 

{phang}
{cmd:rv} reports borrowing of strength using the relative variances method.
This compares the variance of each coefficient in the multivariate meta-analysis 
with its variance in a univariate meta-analysis.
Unlike the {cmd:sd} method, the {cmd:rv} method takes account of changes 
in the estimated between-studies heterogeneity matrix, 
and hence may report negative values for borrowing of strength.

{phang}
{cmd:dpc} reports data point coefficients. These show how each estimated parameter 
is derived as a weighted sum of data points. 

{phang}{cmd:details} outputs a table of the full score decomposition ({cmd:sd} method only) 
                      or of the separate standard errors ({cmd:rv} method only).

{phang}{cmd:format}({it:fmt}) specifies the output format for all methods.

{phang}{cmd:clear} ({cmd:sd} method only) loads the data for the table into memory.

{phang}{cmd:keepmat(}{it:name}{cmd:)}  saves the matrices.
With the {cmd:sd} method, three matrices, 
{it:name}borrowed, {it:name}direct and {it:name}total, are saved.
For {cmd:rv} & {cmd:dpc} methods, one matrix, {it:name}, is saved.

{phang}{cmd:unscaled} ({cmd:sd} method only)
modifies the {cmd:details} and {cmd:keepmat(}{it:name}{cmd:)} options
to give unscaled, not scaled weights.

{phang}{cmd:wide} with the {cmd:sd} and {cmd:details} options causes the output to be in wide format.


{title:Output options: probability-of-being-best}{marker pbest}

{p 4 4 2}{cmd:pbest(min}|{cmd:max} {ifin}, [{it:suboptions}]{cmd:)}
is useful in {help network:network meta-analysis}.
It requests estimation of the probability that each linear predictor is the best 
-- that is, the maximum or minimum, depending on the first argument of {cmd:pbest()}. 
Estimation is performed for each record in the current data that satisfies the if and in criteria. 

{p 4 4 2}
The probability is estimated under a Bayesian model with flat priors, 
assuming that the posterior distribution of the parameter estimates is approximated 
by a Normal distribution with mean and variance 
equal to the frequentist estimates and variance-covariance matrix. 
Rankings are constructed by drawing the coefficients multiple times  
from their approximate posterior density. 
For each draw, the linear predictor is evaluated for each study, 
and the largest linear predictor is noted. 

{p 4 4 2}
For models without covariates, {cmd:pbest()} is only available if {cmd:longparm} was specified when the model was fitted.

{p 4 4 2}
The {it:suboptions} of {cmd:pbest()} are:

{phang}
{cmd:reps(}{it:#}{cmd:)} specifies the number of draws used. The default is 1000.

{phang}
{cmd:zero} specifies that zero is to be considered as another linear predictor. 

{phang}{cmd:gen(}{it:string}{cmd:)} specifies that the probabilities be saved in variables with prefix {it: string}. 

{phang}{cmd:seed(}{it:#}{cmd:)} specifies the random number seed.

{phang}{opth format(%fmt)} specifies the output format.

{phang}{cmd:id(}{it:varname}{cmd:)} specifies an identifier for the output. 

{phang}
{cmdab:pred:ict} ranks the true effects in a future study with the same covariates, 
thus allowing for heterogeneity as well as parameter uncertainty, 
as in the calculation of prediction intervals {help mvmeta##Higgins++09:(Higgins et al, 2009)}.
The default behaviour is instead to rank linear predictors and does not allow for heterogeneity.

{phang}{cmd:all} causes all ranks to be output, not just the best, as in {help mvmeta##Salanti++11:Salanti et al (2011)}.

{phang}{cmd:saving(}{it:filename}{cmd:)} writes the draws from the posterior distribution 
(indexed by the identifier and the replication number) to {it:filename}, 
and {cmdab:rep:lace} allows this file to be overwritten.

{phang}{cmd:clear} causes the summarised probabilities to be loaded into memory, 
so that the user can produce their own tabulations or graphs. This disables the {cmd:gen()} option.

{phang}{cmd:bar} draws a bar graph of the probabilities.

{phang}{cmd:line} draws a line graph of the probabilities.

{phang}{cmdab:cum:ulative} changes the bar or line graph to show cumualtive probabilties. 
The rankogram of {help mvmeta##Salanti++11:Salanti et al (2011)}
is produced by specifying this together with the {cmd:line} suboption.

{phang}{cmd:mcse} adds the Monte Carlo standard errors to the tables.

{phang}{cmdab:mean:rank} adds the mean rank and the SUCRA {help mvmeta##Salanti++11:(Salanti et al, 2011)} 
to the table. 
The SUCRA is the rescaled mean rank: it
is 1 when a treatment is certain to be the best and 0 when a treatment is certain to be the worst.

{phang}{cmdab:tabdisp:options(}{it:string}{cmd:)} specifies options valid for {help tabdisp} which draws the results table.
For example, {cmd:tabdispoptions(cellwidth(10))}.


{title:Output options: variance parameters}{marker outputoptionsvar}

{phang}
{cmd:print(}{it:string}{cmd:)} determines how the between-studies variance-covariance matrix is reported. 
{cmd:print(bscorr)}, the default, reports the between-studies standard deviations and correlation matrix. 
{cmd:print(bscov)} reports the between-studies variance-covariance matrix. 
{cmd:print(bscov bscorr)} reports both.

{phang}{cmd:i2} reports the between-study variance and the I-squared statistic for each outcome, 
together with their confidence intervals.
I-squared is computed as between / (within + between) 
where "between" is the appropriate element of Sigma 
and "within" is given by equation (9) of {help mvmeta##HigginsThompson02:Higgins and Thompson (2002)}. 
The method is described in section 3.6 of {help mvmeta##White11:White (2011)}.

{pmore}Confidence intervals are computed as follows.
With {cmd:fixed} or {cmd:mm1} estimation, the method of {help mvmeta##HigginsThompson02:Higgins and Thompson (2002)} is used,
implemented by {helpb heterogi}.
With {cmd:reml} or {cmd:ml} estimation, confidence intervals are computed by {helpb nlcom} 
on a scale specified by the {cmd:ciscale} option.
With {cmd:mm2} estimation, I have implemented a new and even more ad hoc method:
the estimated between-study variance is used to reconstruct the diagonal elements of the Q matrix, 
and the method of {help mvmeta##HigginsThompson02:Higgins and Thompson (2002)} 
is used as if this were the observed Q matrix. 

{phang}{opth i2fmt(%fmt)} specifies the output format for the I-squared statistics.

{phang}{cmd:ncchi2} uses this option of {helpb heterogi} in computing confidence intervals. It is only relevant after {cmd:mm} estimation.

{phang}{cmd:ciscale(sd}|{cmd:logsd}|{cmd:logh)} determines the scale on which confidence intervals for the between-study variance and I-squared are computed after reml or ml estimation: 
tau, log(tau) or log(H), where tau^2 is the "between" variance above and H^2 = (1 + between / within). 
The default is {cmd:ciscale(sd)}. 

{phang}{cmdab:test:sigma} performs a likelihood ratio test of Sigma=0, if reml or ml estimation was used. 


{title:Output options: miscellaneous}{marker outputoptionsmisc}

{phang}
{cmdab:shows:tart} reports the starting values used.

{phang}{cmd:id(}{it:varname}{cmd:)} specifies an identifier for the output.
This affects {cmd:wt()} and {cmd:pbest()}.

{phang}
{cmdab:showa:ll} reports the estimated values of the basic parameters underlying the between-studies 
variance matrix.


{title:Covariance structures}{marker covstructures}

{phang}The between-studies variance-covariance matrix Sigma may be modelled in various ways.
Each option has a different way to specify the starting values for Sigma.
In each case, the starting value for the fixed parameters is derived from the starting value of Sigma.

{phang}{cmdab:bscov:ariance(}{cmdab:uns:tructured)} estimates an unstructured Sigma, and is the default. 
Starting values for Sigma may be specified explicitly by {cmd:start(}{it:matrix_expression}{cmd:)}.
{cmd:start(}{cmd:mm}{cmd:)} (the default) specifies that the starting value is computed by the {cmd:mm} method. 
{cmd:start(0)} uses a starting value of 0.001 times the default. 

{phang}{cmdab:bscov:ariance(}{cmdab:prop:ortional} {it:matexp}{cmd:)} models Sigma = tau^2*{it:matexp}, where tau is an unknown parameter and {it:matexp} is a known matrix expression (e.g. a matrix name or I(2)). 
{cmd:start(#)} specifies the starting value for the scalar tau.

{phang}{cmdab:bscov:ariance(}{cmdab:exch:angeable} #{cmd:)} is a shorthand for {cmd:bscovariance(proportional P)} 
where {cmd:P} is a matrix with 1's on the diagonal and # off the diagonal. 
{cmd:bscovariance(exchangeable 0.5)} is widely used in network meta-analysis.

{phang}{cmdab:bscov:ariance(}{cmdab:eq:uals} {it:matexp}{cmd:)} forces Sigma = {it:matexp}, where is a known matrix expression (e.g. a matrix name or I(2)). 
{cmd:start()} is not required.

{phang}{cmdab:bscov:ariance(}{cmdab:corr:elation} {it:matexp}{cmd:)} models Sigma = D*{it:matexp}*D, 
where {it:matexp} is a known matrix expression containing the between-study correlations, 
and D is an unknown diagonal matrix containing the between-studies standard deviations. 
{cmd:start({it:rowvector})} specifies the starting values for the diagonal of D.


{title:Studies in which some outcomes are unestimated}{marker missing}

{phang}
{cmd:mvmeta} now deals naturally with cases where a study reports only a subset of outcomes: 
that is, all computation methods are adapted to handle this case.
{cmd:mvmeta} ignores variances and covariances specified for missing point estimates. 
Conversely, it expects non-missing variances and covariances to accompany non-missing point estimates.

{phang}
{helpb mvmeta_make} automatically fills in missing values using the augmentation algorithm described in White (2009).


{title:Changes in mvmeta version 2.3}{marker changes2}

{cmd:mvmeta} version 2.3 was published in the SJ {help mvmeta##White11:(White, 2011)} with the following changes:

{phang}
Meta-regression is allowed. 
The simple syntax is {cmd:mvmeta b V xvars}. 
The more flexible syntax uses the {cmd:eq()} option. 
For example, for 2-dimensional b, {cmd:mvmeta b V x} is the same as {cmd:mvmeta b V, eq(b1:x,b2:x)}.

{phang}
{cmd:mvmeta}, typed without specifying b and V, redisplays the latest estimation results. 
All the output options listed above may be used, except {cmd:keepmat()}.

{phang}
{cmd:eform} is correctly implemented, and is ignored if long parameterisation is used without covariates.

{phang}
The starting values (for {cmd:bscov(uns)}) are produced by default by the method of moments.

{phang}
Option {cmd:showchol} has been renamed {cmd:showall}.

{phang}
The likelihood is coded using mata and appears on initial tests to be 2-5 times faster.

{phang}
{cmd:corr()} has been renamed {cmd:wscorr()}.

{phang}
{cmd:bscorr} and {cmd:bscov} have been renamed {cmd:print(bscorr)} and {cmd:print(bscov)}.


{title:Changes from version 2.3 to version 3.1}{marker changes3}

{phang}
The command has been modified to work with the new {help network} suite for network meta-analysis.
Particular changes include the new {cmd:commonparm} option, and the shorthand {cmd:bscov(exchangeable #)}.

{phang}The {cmd:equations()} option now allows lists of y-variables.

{phang}The matrix-based method of moments has been added as the {cmd:mm2} option 
and is the default if {cmd:mm} is specified.

{phang}
The following new suboptions for {cmd:pbest} allow various graphical displays, saving of results and numerical summaries of the estimated ranks: 
{cmd:all}
{cmd:saving(}{it:filename}{cmd:)} 
{cmd:clear} 
{cmd:bar} 
{cmd:line} 
{cmdab:cum:ulative}
{cmd:mcse} 
{cmdab:mean:rank} 
{cmdab:tabdisp:options(}{it:string}{cmd:)}  

{phang}
The new {cmd:wt} option displays study weights and borrowing of strength.

{phang}
The new {cmd:randfix} option compares random-effects with fixed-effect results. 

{phang}
The program structure has been changed: by default, the fixed-effect model, all univariate models and the unstructured method of moments are fitted before the specified model. 
The {cmd:suppress()} option can be used to suppress some or all of these analyses; in particular, it is used by {cmd:network}.

{phang}
The augmentation procedures used by version 1 of {cmd:mvmeta} are unnecessary and are now undocumented. 
The options {cmd:augment}, {cmd:augquiet}, {cmd:missest(#)} and {cmd:missvar(#)} remain available.

{phang}
A bug in the estimation procedure for the {cmd:wscorr(riley)} method which led to wrong answers has been fixed.
A number of minor bugs have also been fixed. 


{title:Examples}{marker examples}

{p 0 0 0}First stage, starting with individual participant data ({cmd:fg} has levels 1-5):

{phang}{cmd:. xi: mvmeta_make stcox ages i.fg, strata(sex tr) nohr saving(FSCstage1) replace by(cohort) usevars(i.fg) names(b V) esave(N)}

{p 0 0 0}The individual participant data are not publicly available, but you can get the summary data produced by the above command using 

        {com}. {stata "net get st0156, from(http://www.stata-journal.com/software/sj9-1)"}{txt}

Second stage:

        {com}. {stata use FSCstage1, clear}{txt}

        {com}. {stata mvmeta b V}{txt}

{p 0 0 0}For more examples, please see the {help mvmetademo_run:demonstration}.


{title:Details}{marker details}

{p 0 0 0}
The reml and ml methods use Newton-Raphson maximisation of the likelihood 
or restricted likelihood using 
{helpb ml}. 
The between-studies variance matrix (using {cmd:bscov(uns)}) is parameterised 
via its Cholesky decomposition in 
order to ensure that it is non-negative definite.
{* The forest option of {cmd:mvmeta} requires the additional programs {help coefplot}.}{...}

{p 0 0 0}
Parts of {cmd:mvmeta} require the additional programs {help sencode}.

{p 0 0 0}
{cmd:mvmeta} has been tested under Stata versions 12 and later. 
I hope it also works under Stata versions 9-11.


{title:Known problems}{marker problems}

{p 0 0 0}With methods of moments, none of wscorr(riley), bscov(prop) and bscov(corr) has been implemented: in fact we don't yet have methods.

{p 0 0 0}Please report any other problems to ian.white@ucl.ac.uk.


{title:References}{marker references}

{phang}{marker DL}DerSimonian R, Laird N. 
Meta-analysis in clinical trials. 
Controlled Clinical Trials 1986; 7: 177-188.
{browse "http://www.sciencedirect.com/science/article/pii/0197245686900462"}

{phang}{marker HigginsThompson02}Higgins JPT, Thompson SG. 
Quantifying heterogeneity in a meta-analysis. Statistics in Medicine 2002; 21: 1539-58.
{browse "http://onlinelibrary.wiley.com/doi/10.1002/sim.1186/abstract"}

{phang}{marker Higgins++09}Higgins JPT, Thompson SG, Spiegelhalter DJ. 
A re-evaluation of random-effects meta-analysis. 
Journal of the Royal Statistical Society (A) 2009; 172: 137-159.
{browse "http://onlinelibrary.wiley.com/doi/10.1111/j.1467-985X.2008.00552.x/abstract"}

{phang}{marker Jackson++10}Jackson D, White IR, Thompson SG. 
Extending DerSimonian and Laird's methodology to perform multivariate random effects meta-analyses. 
Statistics in Medicine 2010; 29: 1282-1297.
{browse "http://onlinelibrary.wiley.com/doi/10.1002/sim.3602/abstract"}

{phang}{marker Jackson++11}Jackson D, Riley R, White IR. 
Multivariate meta-analysis: potential and promise. 
Statistics in Medicine 2011; 30: 2481-2498.
{browse "http://onlinelibrary.wiley.com/doi/10.1002/sim.4172/abstract"}

{phang}{marker Jackson++12}Jackson D, White IR, Riley R.
Quantifying the impact of between-study heterogeneity in multivariate meta-analyses
Statistics in Medicine 2012; 31: 3805-3820.
{browse "http://onlinelibrary.wiley.com/doi/10.1002/sim.5453/abstract"}

{phang}{marker Jackson++13}Jackson D, White IR, Riley R. 
A matrix based method of moments for fitting the random effects model 
    for meta-analysis and meta-regression. 
Biometrical Journal 2013; 55: 231-245.
{browse "http://onlinelibrary.wiley.com/doi/10.1002/bimj.201200152/abstract"}

{phang}{marker Riley09}Riley RD. 
Multivariate meta-analysis: the effect of ignoring within-study correlation. Journal of the Royal Statistical Society (A) 2009; 172: 789-811.
{browse "http://onlinelibrary.wiley.com/doi/10.1111/j.1467-985X.2008.00593.x/abstract"}

{phang}{marker Riley++08}Riley RD, Thompson JR, Abrams KR. 
An alternative model for bivariate random-effects meta-analysis when the within-study correlations are unknown. Biostatistics 2008; 9: 172-186.
{browse "http://biostatistics.oxfordjournals.org/content/9/1/172.short"}

{phang}{marker Salanti++11}Salanti G, Ades A, Ioannidis J. 
Graphical methods and numerical summaries for presenting results from multiple-treatment meta-analysis: 
    an overview and tutorial. 
Journal of Clinical Epidemiology 2011; 64: 163-171.
{browse "http://www.ncbi.nlm.nih.gov/pubmed/20688472"}

{phang}{marker White09}* White IR. 
Multivariate random-effects meta-analysis. 
Stata Journal 2009; 9: 40-56.
{browse "http://www.stata-journal.com/article.html?article=st0156"}

{phang}{marker White11}* White IR. 
Multivariate random-effects meta-regression: Updates to mvmeta. 
Stata Journal 2011; 11: 255-270.
{browse "http://www.stata-journal.com/article.html?article=st0156_1"}

{phang}{marker White12}White IR, Barrett JK, Jackson D, Higgins JPT. 
Consistency and inconsistency in network meta-analysis: 
    model estimation using multivariate meta-regression.
Research Synthesis Methods 2012; 3: 111-125.
{browse "http://onlinelibrary.wiley.com/doi/10.1002/jrsm.1045/abstract"}

* Please use these references to cite this program.


{title:Author and updates}{marker updates}

{p}Ian White, MRC Clinical Trials Unit at UCL, London, UK. 
Email {browse "mailto:ian.white@ucl.ac.uk":ian.white@ucl.ac.uk}.

{p}You can get the latest version of this and my other Stata software using 
{stata "net from http://www.homepages.ucl.ac.uk/~rmjwiww/stata/"}.



