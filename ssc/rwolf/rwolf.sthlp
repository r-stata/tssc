{smcl}
{* December 01, 2016 @ 17:34:22}{...}
{hline}
help for {hi:rwolf}
{hline}

{title:Title}

{p 8 20 2}
    {hi:rwolf} {hline 2} Calculate Romano-Wolf stepdown p-values for multiple hypothesis testing

{title:Syntax}

{p 8 20 2}
{cmdab:rwolf} {it:{help varnames:depvars}} {ifin} [{it:{help weight}}]{cmd:,} [{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{cmd:indepvar(}{it:varlist}{cmd:)}}Indicates the independent (treatment) variable which is included in multiple hypothesis tests. This will typically be a single independent variable,
however it is possible to indicate various independent (treatment) variables which are
included in the same model, and the Romano-Wolf procedure will be implemented
efficiently returning p-values for each dependent variable of interest, corresponding
to each of the specified independent variables.  This option must be specified, unless the {cmd:nobootstraps} option is indicated.
{p_end}
{...}
{synopt :{cmd:method({help regress} | {help logit} | {help probit} | {help ivregress} |...)}}Indicates to Stata how each of the multiple hypothesis tests are performed (ie the baseline models).
Any estimation command permitted by Stata can be included.
See {help regress} for a full list of estimation commands in Stata.  
    If not specified, {help regress} is assumed. If an IV regression is desired, this must
    be specified with {help ivregress} only, and the iv() option below must be specified.
{p_end}
{...}
{synopt :{cmd:controls({help varlist})}}Lists all other control variables which are to be included in the model to be tested multiple times.  Any variable format accepted by {help varlist} is permitted including time series and factor variables.
{p_end}
{...}
{synopt :{cmd:nulls({help numlist})}}Indicates the parameter values of interest used in
each test. If specified, a single scalar value should be indicated for each of the multiple
hypotheses tested, and these should be listed in the same order that variables are
listed as depvars in the command syntax. In the case that multiple {cmd:indepvars}
are specified, null parameters should be specified grouped first by {cmd:indepvars} and
then by {cmd:depvars}. For example, if two independent variables are considered with
four dependent variables, first the four null parameters associated with the first
independent variable should be listed, followed by the four null parameters associated
with the second independent variable. If this option is not used, it is assumed
that each null hypothesis is that the parameter is equal to 0.
{p_end}
{...}
{synopt :{cmd:seed({help set seed:#})}}Sets seed to indicate the initial value for the pseudo-random number generator.  # can be any integer between 0 and 2^31-1. 
{p_end}
{...}
{synopt :{cmd:reps({help bootstrap:#})}}Perform # bootstrap replication; default is {cmd:reps(100)}.  Where possible prefer a larger number of replications for
more precise p-values.  In IV models, a considerably larger number of replications is
highly recommended.
{p_end}
{...}
{synopt :{cmd:verbose}}Request additional output indicating degree of advance of procedure.  Initial
models are also displayed.
{p_end}
{...}
{synopt :{cmd:strata({help varlist})}} specifies the variables identifying strata.  If {cmd:strata()} is specified, bootstrap samples are selected within each stratum when forming the resampled null distributions.
{p_end}
{...}
{synopt :{cmd:cluster({help varlist})}} specifies the variables identifying resampling clusters.
If {cmd:cluster()} is specified, the sample drawn when forming the resampled null
distributions is a bootstrap sample of clusters. This option does not cluster standard errors
in each regression.  If desired, this should be additionally specified using
{cmd:vce(cluster clustvar)}.
{p_end}
{...}
{synopt :{cmd:onesided({help string})}} Indicates that p-values based on one-sided tests should be calculated.
Unless specified, p-values based on two-sided tests are provided, corresponding to the null that
each parameter is equal to 0 (or the values indicated in {cmd:nulls()}). In {cmd:onesided({help string})},
{help string} must be either "positive", in which case the null is that each parameter is greater
than or equal to 0, or "negative" in which case the null is that each parameter is less than or equal to 0.
{p_end}
{...}
{synopt :{cmd:iv({help varlist})}} only necessary when {cmd:method(ivregress)} is specified.
The instrumental variables for the treatment variable of interest should be specified in {cmd:iv()}.
At least as many instruments as endogenous variables must be included.
{p_end}
{...}
{synopt :{cmd:otherendog({help varlist})}} If more than one endogenous variable is required in
{help ivregress} models, additional endogenous variables can be included using this option.
By default, when {help ivregress} is specified it is assumed that the variable specified in
{cmd:indepvar(varname)} is an endogenous variable which must be instrumented.  If this is the
case, the variable should not be entered again in {cmd:otherendog({help varlist})}.
{p_end}
{...}
{synopt :{cmd:indepexog}}If {help ivregress} is specified, but {cmd:indepvar(varname)} is an
exogenous variable, {cmd:indepexog} should be indicated.  In this case all endogenous
variables must be specified in {cmd:otherendog({help varlist})} and all instruments
must be specified in {cmd:iv({help varlist})}.
{p_end}
{...}
{synopt :{cmd:bl({help string})}}Allows for the inclusion of baseline measures of the dependent
variable as controls in each model.  If desired, these variables should be created with some suffix, and
the suffix should be included in the {cmd:bl()} option.  For example, if outcome variables are
called y1, y2 and y3, variables y1_bl, y2_bl and y3_bl should be created with baseline values,
and {cmd:bl(}_bl{cmd:)} should be specified.
{p_end}
{...}
{synopt :{cmd:noplusone}}Calculate the Resampled and Romano-Wolf adjusted p-values without
adding one to the numerator and denominator.
{p_end}
{...}
{synopt :{cmd:nodots}}Suppress replication dots in bootstrap resamples.
{p_end}
{...}
{synopt :{cmd:holm}}Along with standard output, additionally provide p-values corresponding to the
Holm multiple hypothesis correction.
{p_end}
{...}
{synopt :{cmd:graph}}Requests that a graph be produced showing the Romano-Wolf null distribution
corresponding to each variable examined.
{p_end}
{...}
{synopt :{cmd:varlabels}}Name panels on the graph of null distributions using their variable labels
rather than their variable names.
{p_end}
{...}
{synopt :{opt other options}}Any additional options which correspond to the baseline regression model.  All options permitted by the indicated method are allowed.
{p_end}
{...}

{syntab :Options specific to cases where resampled estimates are user-provided}
{synopt :{cmd:nobootstraps}} Indicates that bootstrap replications do not need to be estimated by
the {hi:rwolf} command. In this case, each variable indicated in depvars must consist of M
bootstrap realizations of the statistic of interest corresponding to each of the
multiple baseline models. Additionally, for each variable indicated in depvars, the
corresponding standard errors for each of the M bootstrap replicates should be stored
as another variable, and these variables should be indicated as {cmd:stdests({help varlist})}.
Finally, the original estimates corresponding to each model in the full sample should
be provided in {cmd:pointestimates({help numlist})}, and the original standard errors should
be provided in {cmd:stderrs({help numlist})}. This option may not be specified if {cmd:indepvar()}
and {cmd:method()} are specified. For all standard implementations based on regression
models, {cmd:indepvar()} and {cmd:method()} should be preferred.
{p_end}
{...}
{synopt :{cmd:pointestimates({help numlist})}} Provides the estimated statistics of
interest in the full sample corresponding to each of the {help depvars} indicated in the
command. These estimates must be provided in the same order as the {help depvars} are
specified. This option may not be specified if {cmd:indepvar()}
and {cmd:method()} are specified. For all standard implementations based on regression
models, {cmd:indepvar()} and {cmd:method()} should be preferred.
{p_end}
{...}
{synopt :{cmd:stderrs({help numlist})}}Provides the estimated standard errors for each
estimated statistic in the full sample. These estimates must be provided in the same order
as the {help depvars}
are specified. This option may not be specified if {cmd:indepvar()}
and {cmd:method()} are specified. For all standard implementations based on regression
models, {cmd:indepvar()} and {cmd:method()} should be preferred.
{p_end}
{...}
{synopt :{cmd:stdests({help varlist})}}Contains variables consisting of estimated standard errors from each
of the M resampled replications. These standard errors should correspond to the
resampled estimates listed as each {help depvar} and must be provided in the same order
as the {help depvars} are specified. This option may not be specified if {cmd:indepvar()}
and {cmd:method()} are specified. For all standard implementations based on regression
models, {cmd:indepvar()} and {cmd:method()} should be preferred.
{p_end}
{...}
{synopt :{cmd:nullimposed}}Indicates that resamples are centered around the null, rather than the
original estimate. This option is generally only used when permutations rather than
bootstrap resamples are performed.
{p_end}
{...}
{synoptline}
{p2colreset}


{title:Description}

{p 6 6 2}
{hi:rwolf} calculates Romano and Wolf's (2005a,b) step-down adjusted p-values robust to
multiple hypothesis testing. This program follows the resampling algorithm described in
Romano and Wolf (2016), and provides a p-value corresponding to the significance of a
hypothesis test where S tests have been implemented, providing strong control of the
familywise error rate (the probability of committing any Type I error among all	
of the S hypotheses tested).  The {hi:rwolf} algorithm constructs a null
distribution for each of the S hypothesis tests based on Studentized bootstrap replications
of a subset of the tested variables.  Full details of the procedure are described in
Romano and Wolf (2016), and further discussion of this program and its implementation,
plus a full discussion of this ado, is provided in Clarke, Romano and Wolf (2019).

{p 6 6 2}
There are two ways for this command to be used. First, either {cmd:indepvar()}
and {cmd:method()} must be specified if the complete Romano-Wolf procedure should be
implemented including the estimation of bootstrap replications and generation of
adjusted p-values.  Alternatively, the user can provide rwolf with pre-computed
bootstrap or permuted replications of the estimated statistic and standard errors
for each of their multiple hypothesis tests of interest.  In this case, the {cmd:nobootstraps}
and {cmd:pointestimates(numlist)}, {cmd:stderrs(numlist)} and {cmd:stdests(varlist)}
should be indicated, and rwolf calculates the adjusted p-values from the replicates provided. 

{p 6 6 2}
In the former case where {hi:rwolf} takes care of estimating the {help bootstrap} replicates
of each test statistic and its standard error, {hi:rwolf} simply requires that the user
indicates the multiple dependent variables to be tested, the independent variable of
interest, and (optionally) a series of control variables which should be included in
each test.  {hi:rwolf} works with any {help regress:estimation-based regression command}
allowed in Stata, which should be indicated using the {cmd:method()} option. If not
specified, {help regress} is assumed.  In the case that {help ivregress} is specified,
it is assumed that the independent variable is the endogenous variable, and the
instrumental variable(s) should be indicated in the {cmd:iv()} option. If this is not
the case (ie if the treatment variable is an exogenous variable in the IV model), this
should be indicated with the {cmd:indepexog} option. Optionally, regression {help weight}s,
{help if}
or {help in} can be specified.  By default, 100 {help bootstrap} replications are run
for each of the S multiple hypotheses.  Where possible, a larger number of replications
should be preferred given that p-values are computed by comparing estimates to a
bootstrapped null distribution constructed from these replications.  The number of
replications is set using the {cmd:reps({help bootstrap:#})} option, and to replicate
results, the {cmd:seed({help seed:#})} should be set.

{p 6 6 2}
In the case of more complex situations where a user wishes to pre-compute their
test statistics, standard errors, and a large number of {help bootstrap} replicates
of each these, the user can request for only the p-value correction algorithm to
be implemented with the {cmd:bootstrap} option.  This allows for cases where different
estimation methodologies or different independent variables are used in each model
within the family of hypothesis tests, or where more complicated resampling procedures
are used, such as those based on permutation.  

{p 6 6 2}
By default, the re-sampled null distributions are formed using a simple bootstrap
procedure.  However, more complex stratified and/or clustered resampling procedures
can be specified using the {cmd:strata()} and {cmd:cluster()} options.  The
{cmd:cluster()} option refers only to the {help bsample:resampling} procedure, and
not to the standard errors estimated in each regression model.  If the standard
variance estimator is not desired for regression models, this should be indicated
using the same {help regress:vce()} specification as in the original regression
models, for example {cmd:vce(cluster clustvar)}.

{p 6 6 2}
The command returns the Romano Wolf p-value corresponding to each variable, standard
(bootstrapped) uncorrected p-values, and for reference, the original uncorrected
(analytical) p-value from the initial tests when {hi:rwolf} estimates baseline
regression models.  {hi:rwolf} is an e-class command, and the Romano Wolf p-value for each
variable is returned as a scalar in e(rw_varname).  A matrix is also returned as
e(RW) providing the full set of Romano-Wolf corrected p-values.

{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Use the auto dataset to run multiple regressions of various independent variables on a single dependent variable of interest (weight) controlling for trunk and mpg.  {break}

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. rwolf headroom turn price rep78, indepvar(weight) controls(trunk mpg) reps(250)}{p_end}

    {hline}

{pstd}Run the same analysis, however using areg to absorb a series of fixed effects {break}

{phang2}{cmd:. rwolf headroom turn price rep78, indepvar(weight) controls(trunk) reps(250) method(areg) abs(mpg)}{p_end}

    {hline}

{pstd}Run an instrumental variables model where the treatment variable (weight) is endogenous and a single instrument (length) is available {break}

{phang2}{cmd:. rwolf headroom turn price rep78, indepvar(weight) controls(trunk)  method(ivregress) iv(length)}{p_end}

{hline}

{pstd}Run multiple hypothesis tests using the National Longitudinal (panel) Survey with clustered re-sampling.{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. rwolf wks_ue ln_wage hours tenure, indepvar(nev_mar) controls(i.year age) method(xtreg) seed(51) fe cluster(ind_code) verbose}{p_end}

    {hline}



{marker results}{...}
{title:Saved results}

{pstd}
{cmd:rwolf} saves the following in {cmd:e()}:

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(rw_var1)}}The Romano Wolf p-value associated with variable 1 (var1 will be changed for variable name) {p_end}
{synopt:{cmd:...}} {p_end}

{synopt:{cmd:e(rw_varS)}}The Romano Wolf p-value associated with variable S.  Each of the dependent variables will be returned in this way. {p_end}

{synopt:{cmd:e(rw_depvar1_indepvar1)}} In the case that multiple independent variables are indicated, p-values for each
dependent variable--independent variable pair will be returned using both variables names. {p_end}
{synopt:{cmd:...}} {p_end}

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Matrix}{p_end}
{synopt:{cmd:e(RW)}}The full set of Romano-Wolf corrected p-values, as well as the uncorrected p-values estimated by bootstrap and the baseline model (if relevant).{p_end}

{synopt:{cmd:e(RW_indepvar)}}In the case that multiple independent variables are indicated, the full set of Romano-Wolf corrected p-values, as well as the uncorrected p-values estimated by bootstrap and the baseline model (if relevant) are returned corresponding to each {cmd:indepvar}.{p_end}

{p2colreset}{...}


{marker acknowledgements}{...}
{title:Acknowledgements}

{p 6 6 2}
I am grateful to Pinar Keskin, Francisco Oteiza and a large number of other users for feedback related to prior versions of this code and useful suggestions which have been implemented in this version of the ado.

	

{marker references}{...}
{title:References}

{marker RomanoWolf2005a}{...}
{phang}
Romano J.P. and Wolf M., 2005a.
{it:Exact and Approximate Stepdown Methods for Multiple Hypothesis Testing},
Journal of the American Statistical Association 100(469): 94-108.

{marker RomanoWolf2005b}{...}
{phang}
Romano J.P. and Wolf M., 2005b.
{it: Stepwise Multiple Testing as Formalized Data Snooping},
Econometrica 73(4): 1237-1282.

{marker RomanoWolf2016}{...}
{phang}
Romano J.P. and Wolf M., 2016.
{it: Efficient computation of adjusted p-values for resampling-based stepdown multiple testing},
Statistics and Probability Letters 113: 38-40.

{marker Clarketal2019}{...}
{phang}
Clarke, D, Romano J.P. and Wolf M., 2019.
{it: The Romano-Wolf Multiple Hypothesis Correction in Stata}, Mimeo.
{p_end}


{title:Author}

{pstd}
Damian Clarke, Department of Economics, Universidad de Santiago de Chile. {browse "mailto:damian.clarke@usach.cl":damian.clarke@usach.cl}
{p_end}

