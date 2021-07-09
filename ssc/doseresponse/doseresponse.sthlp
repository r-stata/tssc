{smcl}
{* 07aug2007}{...}
{cmd:help doseresponse}, {cmd:help doseresponse_model}{right: ({browse "http://www.stata-journal.com/article.html?article=st0150":SJ8-3: st0150})}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{hi:doseresponse} {hline 2}}Estimation of the dose-response function through adjustment for the generalized propensity score{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 20 2}
{cmd:doseresponse}
{it: varlist} 
{ifin}
{weight}{cmd:,}
{cmd:outcome}{cmd:(}{it:varname}{cmd:)}
{cmd:t}{cmd:(}{it:varname}{cmd:)}
{cmd:gpscore}{cmd:(}{it:newvar}{cmd:)}
{cmd:predict}{cmd:(}{it:newvar}{cmd:)}
{cmd:sigma}{cmd:(}{it:newvar}{cmd:)}
{cmd:cutpoints}{cmd:(}{it:varname}{cmd:)}
{cmd:index}{cmd:(}{it:string}{cmd:)}
{cmd:nq_gps}{cmd:(}{it:#}{cmd:)}
{cmd:dose_response}{cmd:(}{it:newvarlist}{cmd:)}
[{cmd:t_transf}{cmd:(}{it:transformation}{cmd:)}
{cmd:normal_test}{cmd:(}{it:test}{cmd:)}
{cmd:norm_level}{cmd:(}{it:#}{cmd:)}
{cmd:test_varlist}{cmd:(}{it:varlist}{cmd:)}
{cmd:test}{cmd:(}{it:type}{cmd:)}
{cmd:flag}{cmd:(}{it:#}{cmd:)}
{cmd:cmd}{cmd:(}{it:regression_cmd}{cmd:)}
{cmd:reg_type_t}{cmd:(}{it:type}{cmd:)}
{cmd:reg_type_gps}{cmd:(}{it:type}{cmd:)}
{cmd:interaction}{cmd:(}{it:#}{cmd:)}
{cmd:tpoints}{cmd:(}{it:vector}{cmd:)}
{cmd:npoints}{cmd:(}{it:#}{cmd:)}
{cmd:delta}{cmd:(}{it:#}{cmd:)}
{cmd:filename}{cmd:(}{it:filename}{cmd:)}
{cmdab:boot:strap}{cmd:(}{it:string}{cmd:)}
{cmd:boot_reps}{cmd:(}{it:#}{cmd:)}
{cmd:analysis}{cmd:(}{it:string}{cmd:)}
{cmd:analysis_level}{cmd:(}{it:#}{cmd:)}
{cmd:graph}{cmd:(}{it:filename}{cmd:)}
{cmdab:det:ail}]


{p 8 26 2}
{cmd:doseresponse_model}
{it: treat_var GPS_var}
{ifin}
[{it:weight}],
{cmd:outcome}{cmd:(}{it:varname}{cmd:)}
[{cmd:cmd}{cmd:(}{it:regression_cmd}{cmd:)}
{cmd:reg_type_t}{cmd:(}{it:type}{cmd:)}
{cmd:reg_type_gps}{cmd:(}{it:type}{cmd:)}
{cmd:interaction}{cmd:(}{it:#}{cmd:)}]


{pstd}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.


{title:Description}

{pstd} {cmd:doseresponse} estimates the generalized propensity score (GPS),
verifies the normal model used for the GPS, and tests the balancing property
by calling the routine {cmd:gpscore}. Then it estimates the conditional
expectation of the outcome given the observed treatment and the estimated GPS
by calling the routine {cmd:doseresponse_model}. Finally, {cmd:doseresponse}
estimates the average potential outcome for each level of the treatment in
which the user is interested.

{pstd} {cmd:doseresponse_model} defines all these models and estimates each of
them by using the estimated GPS.


{title:Options}

    {title:Required}

{phang} {cmd:outcome}{cmd:(}{it:varname}{cmd:)} ({cmd:doseresponse} and
{cmd:doseresponse_model}) specifies that {it:varname} is the outcome variable.

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

{phang} {cmd:dose_response}{cmd:(}{it:newvarlist}{cmd:)} specifies the
variable name(s) for the estimated dose-response function(s).

    {title:Optional}

{phang} {cmd:t_transf}{cmd:(}{it:transformation}{cmd:)} specifies the
transformation of the treatment variable used in estimating the GPS. The
default {it:transformation} is the identity function.  The supported
transformations are the logarithmic transformation, {cmd:t_transf(ln)}; the
zero-skewness log transformation, {cmd:t_transf(lnskew0)}; the zero-skewness
Box-Cox transformation, {cmd:t_transf(bcskew0)}; and the Box-Cox
transformation, {cmd:t_transf(boxcox)}.

{phang} {cmd:normal_test}{cmd:(}{it:test}{cmd:)} specifies
the goodness-of-fit test that {cmd:gpscore} will perform to assess
the validity of the assumed normal distribution model for the
treatment conditional on the covariates. By default, {cmd:gpscore}
performs the Kolmogorov-Smirnov test ({cmd:normal_test(ksmirnov)}). Possible alternatives are the
Shapiro-Francia test,  {cmd:normal_test(sfrancia)};
the Shapiro-Wilk test,  {cmd:normal_test(swilk)}; and
the Stata skewness and kurtosis test for normality, {cmd:normal_test(sktest)}.

{phang} {cmd:norm_level}{cmd:(}{it:#}{cmd:)} sets the significance level of
the goodness-of-fit test for normality. The default is {cmd:norm_level(0.05)}.

{phang} {cmd:test_varlist}{cmd:(}{it:varlist}{cmd:)} specifies that the extent
of covariate balancing has to be inspected for each variable in {it:varlist}.
The default {it:varlist} consists of the variables used to estimate the GPS.
This option is useful when there are categorical variables among the
covariates to test the balancing property for the omitted group.

{phang} {cmd:test}{cmd:(}{it:type}{cmd:)} specifies whether the balancing
property has to be tested using a standard two-sided t test (the default) or a
Bayes-factor-based method.

{phang} {cmd:flag}{cmd:(}{it:#}{cmd:)} specifies that
{cmd:gpscore} estimates the GPS without performing either a goodness-of-fit
test for normality or a balancing test. The default {it:#} is 1, meaning that
both the normal distribution model and the balancing property are tested; the
default level is recommended.

{phang} {cmd:cmd}{cmd:(}{it:regression_cmd}{cmd:)} ({cmd:doseresponse} and
{cmd:doseresponse_model}) defines the regression command to be used for
estimating the conditional expectation of the outcome given the treatment and
the GPS. The default for the outcome variable is {cmd:cmd(logit)} when
there are two distinct values, {cmd:cmd(mlogit)} when there are 3-5 values, and
{cmd:cmd(regress)} otherwise. The supported regression commands are {cmd:logit},
{cmd:probit}, {cmd:mlogit}, {cmd:mprobit}, {cmd:ologit}, {cmd:oprobit}, and
{cmd:regress}.

{phang} {cmd:reg_type_t}{cmd:(}{it:type}{cmd:)} ({cmd:doseresponse} and
{cmd:doseresponse_model}) defines the maximum power of the treatment variable
in the polynomial function used to approximate the predictor for the
conditional expectation of the outcome given the treatment and the GPS. The
default {it:type} is {cmd:linear}. Alternatively, {it:type} can be
{cmd:quadratic} or {cmd:cubic}.

{phang} {cmd:reg_type_gps}{cmd:(}{it:type}{cmd:)} ({cmd:doseresponse} and
{cmd:doseresponse_model}) defines the maximum power of the estimated GPS in
the polynomial function used to approximate the predictor for the conditional
expectation of the outcome given the treatment and the GPS. The default
{it:type} is {cmd:linear}.  Alternatively, {it:type} can be {cmd:quadratic}
or {cmd:cubic}.

{phang} {cmd:interaction}{cmd:(}{it:#}{cmd:)} ({cmd:doseresponse} and
{cmd:doseresponse_model}) specifies whether the model for the conditional
expectation of the outcome given the treatment and the GPS has the interaction
between treatment and GPS.  The default {it:#} is 1, meaning that the
interaction is included.

{phang} {cmd:tpoints}{cmd:(}{it:vector}{cmd:)} specifies that
{cmd:doseresponse} estimates the average potential outcome for each level of
the treatment in {it:vector}. By default, {cmd:doseresponse} creates a
vector with the {it:i}th element equal to the {it:i}th observed treatment value.
This option cannot be used with the {cmd:npoints}{cmd:(}{it:#}{cmd:)}
option.

{phang} {cmd:npoints}{cmd:(}{it:#}{cmd:)} specifies that {cmd:doseresponse}
estimates the average potential outcome for each level of the treatment
belonging to a set of evenly spaced values {it:t0, t1, ..., t#}, that cover
the range of the observed treatment.  This option cannot be used with
the {cmd:tpoints}{cmd:(}{it:vector}{cmd:)} option.

{phang} {cmd:delta}{cmd:(}{it:#}{cmd:)} specifies that {cmd:doseresponse} also
estimates the treatment-effect function considering a {it:#}-treatment gap,
which is defined as E[{it:Y}({it:t} + {it:#})] - E[{it:Y}({it:t})]. The
default {it:#} is 0, meaning that {cmd:doseresponse} estimates only the
dose-response function.

{phang} {cmd:filename}{cmd:(}{it:filename}{cmd:)} stores the treatment levels
specified through the {cmd:tpoints}{cmd:(}{it:vector}{cmd:)} option or the
{cmd:npoints}{cmd:(}{it:#}{cmd:)} option, the estimated dose-response
function, and, eventually, the estimated treatment-effect function, along with
their standard errors (if calculated), to a new file called {it:filename}.

{phang} {cmd:bootstrap}{cmd:(}{it:string}{cmd:)} specifies the use of
bootstrap methods to derive standard errors and confidence intervals. By
default, {cmd:doseresponse} does not apply bootstrap techniques. In such a
case, no standard error is calculated.  To activate this option, {it:string}
should be set to {cmd:yes}.

{phang} {cmd:boot_reps}{cmd:(}{it:#}{cmd:)} specifies the number of bootstrap
replications to be performed. The default is {cmd:boot_reps}{cmd:(}50{cmd:)}.
This option produces an effect only if the {cmd:bootstrap()} option is set to
{cmd:yes}.

{phang} {cmd:analysis}{cmd:(}{it:string}{cmd:)} specifies that
{cmd:doseresponse} plots the estimated dose-response function(s) and the
estimated treatment-effect function(s), along with the corresponding confidence
intervals if they are calculated with bootstrapping. By default,
{cmd:doseresponse} plots only the estimated dose-response and treatment
function(s). If the user types {cmd:analysis(no)}, no plot is
shown.

{phang} {cmd:analysis_level}{cmd:(}{it:#}{cmd:)} sets the confidence level of the confidence intervals. The default is {cmd:analysis_level(0.95)}.

{phang} {cmd:graph}{cmd:(}{it:filename}{cmd:)} stores the plots of the
estimated dose-response function and the estimated treatment effects to a new
file called {it: filename}. When the outcome variable is categorical,
{cmd:doseresponse} creates a new file for each category {it: i} of the outcome
variable and names it {it:filename_i}.

{phang} {cmd: detail} displays detailed output for the {cmd: gpscore} command
and the results of the regression of the outcome on the treatment and the GPS.


{title:Remarks} 

{pstd} Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.
Otherwise, this program may not run properly.

{pstd} The treatment has to be continuous. The outcome can be of any nature:
binary, categorical, or continuous.

{pstd} Make sure that the variables in {it:varlist} do not contain missing values.


{title:Examples}

   {inp:. #delimit ;}
   {inp:. doseresponse  agew ownhs male tixbot workthen yearw,}
   {inp:. outcome(year6) t(prize) gpscore(mygps) predict(hat_treat) sigma(hat_sd)}
   {inp:. cutpoints(cut) index(p50) nq_gps(5) dose_response(mydoseresponse)} 
   {inp:. ;}

   {inp:. #delimit ;}
   {inp:. doseresponse  agew ownhs male tixbot workthen yearw,}
   {inp:. outcome(year6) t(prize) gpscore(mygps) predict(hat_treat) sigma(hat_sd)}
   {inp:. cutpoints(cut) index(p50) nq_gps(5) dose_response(mydoseresponse)} 
   {inp:. t_transf(ln) normal_test(0.01) reg_type_t(quadratic) }
   {inp:. reg_type_gps(quadratic) bootstrap(yes)}
   {inp:. ;}

   {inp:. #delimit ;}
   {inp:. doseresponse  agew ownhs male tixbot workthen yearw,}
   {inp:. outcome(year6) t(prize) gpscore(mygps) predict(hat_treat) sigma(hat_sd)}
   {inp:. cutpoints(cut) index(p50) nq_gps(5) dose_response(mydoseresponse)} 
   {inp:. t_transf(ln) normal_test(0.01) test(Bayes_factor)}
   {inp:. reg_type_t(quadratic) reg_type_gps(quadratic) bootstrap(yes) analysis(no)}
   {inp:. ;}


{title:Authors}

{phang}Michela Bia{p_end}
{phang}Laboratorio Riccardo Revelli{p_end}
{phang}Centre for Employment Studies, Collegio Carlo Alberto {p_end}
{phang}{browse "mailto:michela.bia@laboratoriorevelli.it":michela.bia@laboratoriorevelli.it}{p_end}

{phang}Alessandra Mattei{p_end}
{phang}Department of Statistics, "Giuseppe Parenti", University of Florence{p_end}
{phang}{browse "mailto:mattei@ds.unifi.it":mattei@ds.unifi.it}{p_end}


{title:Also see}

{psee}
Article: {it:Stata Journal}, volume 8, number 3: {browse "http://www.stata-journal.com/article.html?article=st0150":st0150}

{psee}
Online:  {helpb gpscore}
{p_end}
