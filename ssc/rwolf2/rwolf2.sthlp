{smcl}
{* July 07, 2021 @ 10:01:52}{...}
{hline}
help for {hi:rwolf2}
{hline}

{title:Title}

{p 8 20 2}
    {hi:rwolf2} {hline 2} A more flexible syntax to calculate Romano-Wolf stepdown p-values for multiple hypothesis testing

{title:Syntax}

{p 8 14 2}
{cmd:rwolf2}
{cmd:(}{it:method1}
{depvar:1} 
{varlist:1} {ifin} [{it:{help weight:weight}}] [{cmd:,} {it:options1}]{cmd:)}{p_end}
{p 15 14 2}
{cmd:(}{it:method2}
{depvar:2} 
{varlist:2} {ifin} [{it:{help weight:weight}}] [{cmd:,} {it:options2}]{cmd:)}{p_end}
{p 15}{it:...}{p_end}
{p 15 14 2}
{cmd:(}{it:methodN}
{depvar:N} 
{varlist:N} {ifin} [{it:{help weight:weight}}] [{cmd:,} {it:optionsN}]{cmd:)}{cmd:,}
{p_end}
	       {it:indepvars(vars1, vars2, ..., varsN)} [{it:options}]



{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{cmd:indepvars(}{it:varlist}{cmd:)}}This is a required option. Each indepdendent variable should be indicated for which the multiple hypothesis correction is desired.
These refer to variables indicated in each of the independent variable {help varlist}s of models specified in the syntax.  Variables in each model should be separated by commas.
If a correction is desired for a single independent variable from each model this should be specified as (var1, var2, ..., varN).
It is possible to indicate various independent (treatment) variables which should be corrected across models and this quantity can vary for each model, for example
(var1a var1b, var2, ..., varNa VarNb varNc).
{p_end}
{...}
{synopt :{cmd:reps({help bootstrap:#})}}Perform # bootstrap replication; default is {cmd:reps(100)}.
Where possible prefer a considerably larger number of replications for more precise p-values. 
{p_end}
{...}
{synopt :{cmd:seed({help set seed:#})}}Sets seed to indicate the initial value for the pseudo-random number generator.  # can be any integer between 0 and 2^31-1. 
{p_end}
{...}
{synopt :{cmd:holm}}Along with standard output, additionally provide p-values corresponding to the
Holm multiple hypothesis correction. 
{p_end}
{...}
{synopt :{cmd:graph}}Requests that a graph be produced showing the Romano-Wolf null distribution
corresponding to each hypothesis test considered.
{p_end}
{...}
{synopt :{cmd:varlabels}}Name panels on the graph of null distributions using their variable labels
rather than their variable names.
{p_end}
{...}
{synopt :{cmd:onesided({help string})}}Indicates that p-values based on one-sided tests should be calculated.
Unless specified, p-values based on two-sided tests are provided, corresponding to the null that
each parameter is equal to 0 (or the values indicated in {cmd:nulls()}). In {cmd:onesided({help string})},
{help string} must be either "positive", in which case the null is that each parameter is greater
than or equal to 0, or "negative" in which case the null is that each parameter is less than or equal to 0.
{p_end}
{...}
{synopt :{cmd:nodots}}Suppress replication dots in bootstrap resamples.
{p_end}
{...}
{synopt :{cmd:noplusone}}Calculate the Resampled and Romano-Wolf adjusted p-values without
adding one to the numerator and denominator.
{p_end}
{...}
{synopt :{cmd:nulls({help numlist})}}Indicates the parameter values of interest used in
each test. If specified, a single scalar value should be indicated for each of the multiple
hypotheses tested, and these should be listed in the same order that variables are
listed as indepvars in the command syntax. If this option is not used, it is assumed
that each null hypothesis is that the parameter is equal to 0.
{p_end}
{...}
{synopt :{cmd:strata({help varlist})}}Specifies the variables identifying strata.  If {cmd:strata()} is specified, bootstrap samples are selected within each stratum when forming the resampled null distributions.
{p_end}
{...}
{synopt :{opth cl:uster(varlist)}}Specifies the variables identifying resampling clusters.
If {cmd:cluster()} is specified, the sample drawn when forming the resampled null
distributions is a bootstrap sample of clusters. This option does not cluster standard errors
in each original regression.  If desired, this should be additionally specified as an option
in the individual regression models.
{p_end}
{...}
{synopt :{opth idcluster(newvar)}}In cases where clustered resampling is used, the idcluster
option should be used as used in {help bsample} to specify a new name for resampled clusters, such
that clustering within each bootstrap is based on newvar rather than the original (repeated)
cluster variable.  If this option is used, any instances of {cmd:cluster(var)} or {cmd:vce(cluster var)}
will be replaced with {cmd:cluster(newvar)} or {cmd: vce(cluster newvar)} within each bootstrap resample.
{p_end}
{synopt :{cmd:verbose}}Requests additional output, including display of the initial
(uncorrected) models estimated. 
{p_end}
{...}
{synopt :{cmd:usevalid}}In cases of bootstrap replicates where invalid Studentized test
statistics are generated, these will be removed from the multiple hypothesis correction
procedure.  In cases where such
invalid statistics are generated (for example due to no valid underlying estimate or standard error),
a warning will be issued by rwolf2 that the usevalid option should be specified.  This is highly
recommended.  In cases where bootstrapped models result in errors causing the command to exit with error,
the usevalid option can be used to skip these replicates, and avoid errors with the program.
{p_end}
{...}
{synoptline}
{p2colreset}


{title:Description}

{p 6 6 2}
{hi:rwolf2} calculates Romano and Wolf's (2005a,b) step-down adjusted p-values robust to
multiple hypothesis testing.  It provides a more general syntax than that provided in
the {hi:rwolf} command, although the underlying algorithm is the same.
This program follows the resampling algorithm described in
Romano and Wolf (2016), and provides a p-value corresponding to the significance of a
hypothesis test where S tests have been implemented, providing strong control of the
familywise error rate (the probability of committing any Type I error among all	
of the S hypotheses tested).  The {hi:rwolf2} algorithm constructs a null
distribution for each of the S hypothesis tests based on Studentized bootstrap replications
of a subset of the tested variables.  Full details of the procedure are described in
Romano and Wolf (2016), additional discussion related to the procedure in Stata is provided
in Clarke, Romano and Wolf (2019).

{p 6 6 2}
This command follows a syntax similar to {help sureg} where multiple models of interest
should each be specified in a separate set of parentheses.  These models will be estimated,
and bootstrap replicates will be generated, and based on these estimates and bootstrap
replicates, the Romano-Wolf correction will be implemented.  The variables of interest
(for which the multiple hypothesis correction is desired) should be indicated in the
required option {cmd:indepvars()}.  This syntax can be used to implement any 
Stata {help mi estimation:estimation command} that returns a parameter vector and variance-covariance
matrix, as well as other non-native commands including user-written ados such as reghdfe,
ivreg2 (and related programs) and rdrobust.

{p 6 6 2}
In each model, optionally, regression {help weight}s,
{help if}
or {help in} can be specified.  By default, 100 {help bootstrap} replications are run
for each of the S multiple hypotheses.  Where possible, a much larger number of replications
should be preferred given that p-values are computed by comparing estimates to a
bootstrapped null distribution constructed from these replications.  The number of
replications is set using the {cmd:reps({help bootstrap:#})} option, and to replicate
results, the {cmd:seed({help seed:#})} should be set.

{p 6 6 2}
By default, the re-sampled null distributions are formed using a simple bootstrap
procedure.  However, more complex stratified and/or clustered resampling procedures
can be specified using the {cmd:strata()} and {cmd:cluster()} options.  The
{cmd:cluster()} option refers only to the {help bsample:resampling} procedure, and
not to the standard errors estimated in each original regression model.  If the standard
variance estimator is not desired for regression models, this should be indicated
in the syntax of each method indicated in the command syntax.

{p 6 6 2}
The command returns the Romano Wolf p-value corresponding to each variable, standard
(bootstrapped) uncorrected p-values, and for reference, the original uncorrected
(analytical) p-value from the initial tests when {hi:rwolf2} estimates baseline
regression models.  {hi:rwolf2} is an e-class command, and a matrix is returned as
e(RW) providing the full set of Romano-Wolf corrected p-values (and other p-values
mentioned above).

{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Use the auto dataset to run multiple regressions of various independent variables on a single dependent variable of interest (weight) controlling for trunk and mpg and correcting for multiple testing on weight.  {break}

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. rwolf2 (regress headroom weight trunk mpg) (regress turn weight trunk mpg) (regress price weight trunk mpg) (regress rep78 weight trunk mpg), indepvars(weight, weight, weight, weight) reps(250)}{p_end}

    {hline}

{pstd}Estimate an IV and OLS model, correcting for a single variable in the IV regression, and two variables in the OLS regression. {break}

{phang2}{cmd:. rwolf2 (ivregress 2sls price (weight = length)) (regress price weight trunk), indepvars(weight, weight trunk) verbose}{p_end}

    {hline}

{pstd}Run multiple hypothesis tests using the National Longitudinal (panel) Survey with an xtreg, fe model plus a standard OLS regression, stratifying resamples by occupation.{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. rwolf2 (xtreg wks_ue nev_mar i.year age, fe) (xtreg tenure nev_mar i.year age, fe) (reg hours nev_mar i.year), indepvars(nev_mar, nev_mar, nev_mar) seed(12011303) strata(occ_code)}{p_end}

    {hline}



{marker results}{...}
{title:Saved results}

{pstd}
{cmd:rwolf2} saves the following in {cmd:e()}:

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(rw_depvar1_indepvar1)}} The Romano Wolf p-value associated with indepdendent variable 1 in model 1, where
model 1 is indicated by the dependent variable name. Dependent variable--independent variable pair will be returned using both variables names. {p_end}
{synopt:{cmd:...}} {p_end}
{synopt:{cmd:e(rw_depvar2_indepvar1)}} The Romano Wolf p-value associated with indepdendent variable 1 in model 2, where
model 2 is indicated by the dependent variable name. Dependent variable--independent variable pair will be returned using both variables names. {p_end}
{synopt:{cmd:...}} {p_end}


{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Matrix}{p_end}
{synopt:{cmd:e(RW)}}The full set of Romano-Wolf corrected p-values, as well as the uncorrected p-values estimated by bootstrap and the baseline model, and Holm's p-value (if requested){p_end}

{p2colreset}{...}


{marker acknowledgements}{...}
{title:Acknowledgements}

{p 6 6 2}
I am grateful to many users of rwolf for providing feedback and suggestions, and to David McKenzie for suggesting the alternative syntax implemented here.

	

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
Clarke, D., Romano J.P. and Wolf M., 2020.
{it: The Romano-Wolf Multiple Hypothesis Correction in Stata}, Stata Journal 20(4): 812-843.
{p_end}

{marker Clarke2021}{...}
{phang}
Clarke, D.,  2021. {it: rwolf2 Implementation and Flexible Syntax}.  {browse "http://www.damianclarke.net/computation/rwolf2.pdf":Online}.
{p_end}

{title:Author}

{pstd}
Damian Clarke, Department of Economics, University of Chile. {browse "mailto:dclarke@fen.uchile.cl":dclarke@fen.uchile.cl}
{p_end}

