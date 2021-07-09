{smcl}
{* 07aug2007}{...}
{cmd:help gpscore}{right: ({browse "http://www.stata-journal.com/article.html?article=st0150":SJ8-3: st0150})}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:gpscore} {hline 2}}Estimation of the generalized propensity score{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:gpscore}
{it: varlist} 
{ifin}
{weight}{cmd:,}
{cmd:t}{cmd:(}{it:varname}{cmd:)}
{cmd:gpscore}{cmd:(}{it:newvar}{cmd:)}
{cmd:predict}{cmd:(}{it:newvar}{cmd:)}
{cmd:sigma}{cmd:(}{it:newvar}{cmd:)}
{cmd:cutpoints}{cmd:(}{it:varname}{cmd:)}
{cmd:index}{cmd:(}{it:string}{cmd:)}
{cmd:nq_gps}{cmd:(}{it:#}{cmd:)}
[{cmd:t_transf}{cmd:(}{it:transformation}{cmd:)}
{cmd:normal_test}{cmd:(}{it:test}{cmd:)}
{cmd:norm_level}{cmd:(}{it:#}{cmd:)}
{cmd:test_varlist}{cmd:(}{it:varlist}{cmd:)}
{cmd:test}{cmd:(}{it:type}{cmd:)}
{cmd:flag}{cmd:(}{it:#}{cmd:)}
{cmdab:det:ail}]

{pstd}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.


{title:Description}

{pstd} {cmd:gpscore} estimates the parameters of the conditional distribution
of the treatment given the control variables in {it:varlist} by maximum
likelihood, which is assumed to be normal; assesses the validity of the
assumed normal distribution model by a user-specified goodness-of-fit test;
and estimates the generalized propensity score (GPS).  The estimated
GPS is defined as {it: R=r(T,X)}, where {it:r(.,.)} is the conditional density
of the treatment given the covariates, {it:T} is the observed treatment, and
{it:X} is the vector of the observed covariates. Then {cmd:gpscore} tests the
balancing property by using the algorithm suggested by Hirano and Imbens (2004),
and informs the user whether and at what extent the balancing property is
supported by the data.


{title:Options}

    {title:Required}

{phang} {cmd:t}{cmd:(}{it:varname}{cmd:)} specifies that {it:varname} is the
treatment variable.

{phang} {cmd:gpscore}{cmd:(}{it:newvar}{cmd:)} specifies the variable name for
the estimated GPS, which is added to the dataset.

{phang} {cmd:predict}{cmd:(}{it:newvar}{cmd:)} creates a new variable to hold
the fitted values of the treatment variable.

{phang} {cmd:sigma}{cmd:(}{it:newvar}{cmd:)} creates a new variable to hold
the maximum likelihood estimate of the conditional standard error of the
treatment given the covariates.

{phang} {cmd:cutpoints}{cmd:(}{it:varname}{cmd:)} divides the set of potential
treatment values into intervals according to the sample distribution of the
treatment variable, cutting at {it:varname} quantiles.

{phang} {cmd:index}{cmd:(}{it:string}{cmd:)} specifies the representative
point of the treatment variable at which the GPS has to be evaluated within
each treatment interval. {it:string} identifies either the mean ({it:string} =
{cmd:mean}) or a percentile ({it:string} = {cmd:p1}, ..., {cmd:p100}) of the
treatment.

{phang} {cmd:nq_gps}{cmd:(}{it:#}{cmd:)} specifies that the values of the GPS
evaluated at the representative point {cmd:index}{cmd:(}{it:string}{cmd:)} of
each treatment interval have to be divided into {it:#} (1 <= {it:#} <= 100)
intervals, defined by the quantiles of the GPS evaluated at the representative
point {cmd:index}{cmd:(}{it:string}{cmd:)}.

    {title:Optional}

{phang} {cmd:t_transf}{cmd:(}{it:transformation}{cmd:)} specifies the
transformation of the treatment variable used in estimating the GPS. The
default {it:transformation} is the identity function.  The supported
transformations are the logarithmic transformation, {cmd:t_transf(ln)}; the
zero-skewness log transformation, {cmd:t_transf(lnskew0)}; the zero-skewness
Box-Cox transformation, {cmd:t_transf(bcskew0)}; and the Box-Cox
transformation, {cmd:t_transf(boxcox)}.

{phang} {cmd:normal_test}{cmd:(}{it:test}{cmd:)} specifies the goodness-of-fit
test that {cmd:gpscore} will perform to assess the validity of the assumed
normal distribution model for the treatment conditional on the covariates. By
default, {cmd:gpscore} performs the Kolmogorov-Smirnov test
({cmd:normal_test(ksmirnov)}). Possible alternatives are the Shapiro-Francia
test, {cmd:normal_test(sfrancia)}; the Shapiro-Wilk test,
{cmd:normal_test(swilk)}; and the Stata skewness and kurtosis
test for normality, {cmd:normal_test(sktest)}.

{phang} {cmd:norm_level}{cmd:(}{it:#}{cmd:)} sets the significance level of
the goodness-of-fit test for normality. The default is {cmd:norm_level(0.05)}.

{phang} {cmd:test_varlist}{cmd:(}{it:varlist}{cmd:)} specifies that the extent
of covariate balancing has to be inspected for each variable of {it:varlist}.
The default {it:varlist} consists of the variables used to estimate the GPS.
This option is useful when there are categorical variables among the
covariates to test the balancing property for the omitted group.

{phang} {cmd:test}{cmd:(}{it:type}{cmd:)} specifies whether the balancing
property has to be tested using a standard two-sided t test (the default) or a
Bayes-factor-based method.

{phang} {cmd:flag}{cmd:(}{it:#}{cmd:)} specifies that {cmd:gpscore} estimates
the GPS without performing either a goodness-of-fit test for normality or a
balancing test. The default {it:#} is 1, meaning that both the normal
distribution model and the balancing property are tested; the default level is
recommended.

{phang} {cmd:detail} displays more detailed output showing the results of the
goodness-of-fit test for normality, some summary statistics of the
distribution of the GPS evaluated at the representative point of each
treatment interval, and the results of the balancing test within each
treatment interval.


{title:Remarks} 

{pstd} Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.
Otherwise, this program may not run properly.

{pstd} The treatment has to be continuous.

{pstd} Make sure that the variables in {it:varlist} do not contain missing
values.


{title:Examples}

   {inp:. #delimit ;}
   {inp:. gpscore  agew ownhs male tixbot workthen yearw,}
   {inp:. t(prize) gpscore(mygps) predict(hat_treat) sigma(hat_sd) }
   {inp:. cutpoints(cut) index(p50) nq_gps(5)}
   {inp:. ;}

   {inp:. #delimit ;}
   {inp:. gpscore  agew ownhs male tixbot workthen yearw,}
   {inp:. t(prize) gpscore(mygps) predict(hat_treat) sigma(hat_sd) }
   {inp:. cutpoints(cut) index(p50) nq_gps(5)}
   {inp:. t_transf(ln) normal_test(0.01)} 
   {inp:. ;}

   {inp:. #delimit ;}
   {inp:. gpscore  agew ownhs male tixbot workthen yearw,}
   {inp:. t(prize) gpscore(mygps) predict(hat_treat) sigma(hat_sd) }
   {inp:. cutpoints(cut) index(p50) nq_gps(5)}
   {inp:. t_transf(ln) normal_test(0.01)} test(Bayes_factor)
   {inp:. ;}


{title:Reference}

{phang}
Hirano, K., and G. W. Imbens. 2004. The propensity score with continuous
treatments. In
{it:Applied Bayesian Modeling and Causal Inference from Incomplete-Data}
{it:Perspectives}, ed. A. Gelman and X.-L. Meng, 73-84. West Sussex, England:
Wiley InterScience. {p_end}


{title:Authors}

{phang}Michela Bia{p_end}
{phang}Laboratorio Riccardo Revelli{p_end}
{phang}Centre for Employment Studies, Collegio Carlo Alberto{p_end}
{phang}{browse "mailto:michela.bia@laboratoriorevelli.it":michela.bia@laboratoriorevelli.it}{p_end}

{phang}Alessandra Mattei{p_end}
{phang}Department of Statistics,"Giuseppe Parenti", University of Florence{p_end}
{phang}{browse "mailto:mattei@ds.unifi.it":mattei@ds.unifi.it}{p_end}


{title:Also see}

{psee}
Article: {it:Stata Journal}, volume 8, number 3: {browse "http://www.stata-journal.com/article.html?article=st0150":st0150}

{psee}
Online:  {helpb doseresponse}, {helpb doseresponse_model}
{p_end}
