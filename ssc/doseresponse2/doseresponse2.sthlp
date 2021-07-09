{smcl}
{* 27march2013}{...}
{cmd:help doseresponse2}, {cmd:help doseresponse_model}{right: ({browse "http://mpra.ub.uni-muenchen.de/45013/"})}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{hi:doseresponse2} {hline 2}}Estimation of the dose-response function through through the GLM approach{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 20 2}
{cmd:doseresponse2}
{varlist} 
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
{cmd:family}{cmd:(}{it:string}{cmd:)}
{cmd:link}{cmd:(}{it:string}{cmd:)}
[{cmd:t_transf}{cmd:(}{it:transformation}{cmd:)}
{cmd:normal_test}{cmd:(}{it:test}{cmd:)}
{cmd:norm_level}{cmd:(}{it:#}{cmd:)}
{cmd:test_varlist}{cmd:(}{it:varlist}{cmd:)}
{cmd:test}{cmd:(}{it:type}{cmd:)}
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
{cmd:flag_b}{cmd:(}{it:#}{cmd:)}
{cmd:opt_nb}{cmd:(}{it:string}{cmd:)}
{cmd:opt_b}{cmd:(}{it:varname}{cmd:)}
{cmdab:det:ail}]


{p 8 26 2}
{cmd:doseresponse_model}
{it: treat_var GPS_var}
{ifin}
{weight},
{cmd:outcome}{cmd:(}{it:varname}{cmd:)}
[{cmd:cmd}{cmd:(}{it:regression_cmd}{cmd:)}
{cmd:reg_type_t}{cmd:(}{it:type}{cmd:)}
{cmd:reg_type_gps}{cmd:(}{it:type}{cmd:)}
{cmd:interaction}{cmd:(}{it:#}{cmd:)}]


{pstd}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.


{title:Description}

{pstd} {cmd:doseresponse2} estimates the generalized propensity score (GPS) by GLM, 
allowing six different distribution functions: binomial, gamma, inverse gaussian, 
negative binomial, normal and poisson coupled with admissible links; tests the 
balancing property by calling the routine {cmd:gpscore2}. For the normal case 
assesses the validity of the assumed normal distribution model by a user-specified 
goodness-of-fit test. Then it estimates the conditional expectation of the outcome 
given the observed treatment and the estimated GPS by calling the routine {cmd:doseresponse_model}. 
Finally, {cmd:doseresponse2} estimates the average potential outcome for each level 
of the treatment in which the user is interested.

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
the GLM estimate of the conditional standard error of the treatment given 
the covariates, obtained from Pearson residuals.

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

{phang} {cmd:family}{cmd:(}{it:string}{cmd:)} specifies the distribution family
name of the treated variable. {it:string} identifies the distribution family name.

{phang} {cmd:link}{cmd:(}{it:string}{cmd:)} specifies the link function for the treated
variable. The default is the canonical link for the family specified.

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

{phang} {cmd:analysis_level}{cmd:(}{it:#}{cmd:)} sets the confidence level of the 
confidence intervals. The default is {cmd:analysis_level(0.95)}.

{phang} {cmd:graph}{cmd:(}{it:filename}{cmd:)} stores the plots of the
estimated dose-response function and the estimated treatment effects to a new
file called {it: filename}. When the outcome variable is categorical,
{cmd:doseresponse} creates a new file for each category {it: i} of the outcome
variable and names it {it:filename_i}.

{phang} {cmd:flag_b}{cmd:(}{it:#}{cmd:)} skips either the balancing or the 
normal test or both, takes as argument 0; 1; 2. If not specified in the commands 
the program estimates the {cmd:gpscore} performing both the balancing and 
the normal test. {cmd:flag_b(0)} skips both the balancing and the
normal test; {cmd:flag_b(1)} skips only the balancing test; {cmd:flag_b(2)}
skips only the normal test. 

{phang} {cmd:opt_nb}{cmd:(}{it:string}{cmd:)} negative binomial dispersion
parameter. In the GLM approach you specify {cmd:fam(nb #k)} where {it:#k}
is specified through the option {cmd:opt_nb}. The GLM then searches for 
{it:#k} that results in the deviance-based dispersion being 1. Instead, 
{cmd:nbreg} finds the ML estimate of {it:#k}.

{phang} {cmd:opt_b}{cmd:(}{it:varname}{cmd:)} name of the variable which contains the
number of binomial trials.

{phang} {cmd: detail} displays detailed output for the {cmd: gpscore} command
and the results of the regression of the outcome on the treatment and the GPS.


{title:Remarks} 

{pstd} Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.
Otherwise, this program may not run properly.

{pstd} Pay attention to the family-link combination, not all the combinations
are feasible.

{pstd} Make sure that the variables in {it:varlist} do not contain missing values.


{title:Examples}

{inp:. Fractional logit }
  {inp:. egen max_p=max(prize) }
  {inp:. gen fraction= prize/max_p }
  {inp:. qui gen     cut1 = 23/max_p  if fraction<=23/max_p }
  {inp:. qui replace cut1 = 80/max_p  if fraction>23/max_p & fraction<=80/max_p }
  {inp:. qui replace cut1 = 485/max_p if fraction >80/max_p }
  {inp:. mat def tp1 = (0.10\0.20\0.30\0.40\0.50\0.60\0.70\0.80) }

  {inp:. #delimit ;}
  {inp:. doseresponse2 male ownhs owncoll tixbot workthen yearw yearm1 yearm2, }
  {inp:. t(fraction) gpscore(gps_flog) predict(y_hat_fl) sigma(sd_fl) }
  {inp:. cutpoints(cut1) index(mean) nq_gps(5) family(binomial) link(logit) }
  {inp:. outcome(year6) dose_response(dose_response) tpoints(tp1) delta(0.1) }
  {inp:. reg_type_t(quadratic) reg_type_gps(quadratic)  interaction(1) }
  {inp:. filename("outputbin")  graph("graphoutputbin.eps")  }
  {inp:. bootstrap(yes) boot_reps(10)   analysis(yes) det }
  {inp:. ;}



{inp:. Negative binomial distribution}
  {inp:. gen edu=owncoll+ownhs }
  {inp:. qui gen     cut3 = 3  if edu<=3 }
  {inp:. qui replace cut3 = 6  if edu>3 & edu<=6 }
  {inp:. qui replace cut3 = 9 if edu >6 }
  {inp:. mat def tp3 = (0\1\2\3\4\5\6\7\8\9) }

  {inp:. #delimit ;}
  {inp:. doseresponse2 male workthen yearw yearm1 yearm2, t(edu) gpscore(gps_nb) }
  {inp:. predict(y_hat_nb) sigma(sd_nb) cutpoints(cut3) index(p50) }
  {inp:. nq_gps(5) family(nb) link(log) outcome(year6) dose_response(dose_response) }     
  {inp:. tpoints(tp3) delta(1)  reg_type_t(quadratic) reg_type_gps(quadratic)  interaction(1) }
  {inp:. filename("outputnb")  graph("graphoutputnb.eps") }
  {inp:. bootstrap(yes) boot_reps(10)   analysis(yes) det }
  {inp:. ;}



{inp:. Gamma distribution}
  {inp:. #delimit ;}
  {inp:. qui gen     cut2 = 35 if agew<=35 }
  {inp:. qui replace cut2 = 47  if agew>35 & agew<=59 }
  {inp:. qui replace cut2 = 59  if agew >59 }
  {inp:. mat def tp2 = (10\20\30\40\50\60\70\80)}

  {inp:. #delimit ;}
  {inp:. doseresponse2 male ownhs owncoll tixbot workthen yearw yearm1 yearm2,}
  {inp:. t(agew) gpscore(gps_gam) predict(y_hat_g) sigma(sd_g) cutpoints(cut2) index(p50)}
  {inp:. nq_gps(5) family(gamma) link(log) outcome(year6) dose_response(dose_response)  }
  {inp:. tpoints(tp2) delta(1)  reg_type_t(quadratic) reg_type_gps(quadratic)  interaction(1) }
  {inp:. filename("outputgam")  graph("graphoutputgam.eps") }
  {inp:. bootstrap(yes) boot_reps(10)   analysis(yes) det }
  {inp:. ;}


{title:Acknowledgment}

{pstd} We thank H. Hirano, A. Mattei and J. Wooldridge for their 
useful comments and suggestions in an early stage of the work.
{p_end}


{title:Authors}

{phang}Barbara Guardabascio{p_end}
{phang}ISTAT, Italian National Institute of Statistics{p_end}
{phang}National Accounts and Economic Statistics Department{p_end}
{phang}{browse "mailto:guardabascio@istat.it":guardabascio@istat.it}{p_end}

{phang}Marco Ventura{p_end}
{phang}ISTAT, Italian National Institute of Statistics{p_end}
{phang}Econometric Studies and Economic Forecasting Division{p_end}
{phang}{browse "mailto:mventura@istat.it":mventura@istat.it}{p_end}

{title:Also see}

{psee}
Article: {it:Stata Journal}, volume 10, number 4: {browse "http://www.stata-journal.com/article.html?article=up0030":st0150_3},{break}
         {it:Stata Journal}, volume 9, number 4: {browse "http://www.stata-journal.com/article.html?article=up0026":st0150_2},{break}
         {it:Stata Journal}, volume 8, number 4: {browse "http://www.stata-journal.com/article.html?article=up0023":st0150_1},{break}
         {it:Stata Journal}, volume 8, number 3: {browse "http://www.stata-journal.com/article.html?article=st0150":st0150}

{psee}
Online:  {helpb doseresponse} {helpb gpscore} {helpb gpscore2}
{p_end}