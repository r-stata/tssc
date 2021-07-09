{smcl}
{* *! mimix version 1.4 20Apr2018}{...}
{cmd:help mimix}{right: ({browse "http://www.stata-journal.com/article.html?article=st0440":SJ16-2: st0440})}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:mimix} {hline 2}}Reference-based multiple imputation, for sensitivity analysis of longitudinal trials with protocol deviation{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 13 2}
{cmdab:mimix} {depvar} {it:treatvar}{cmd:,} {opth id(varname)} {opth time(varname)} [{it:options}]

{phang}
{bf:mimix} requires data in long format with one record per individual per
timepoint, where {depvar} identifies the numeric outcome variable with missing
data and {it:treatvar} identifies the treatment group variable in the existing
dataset.  See {helpb reshape} for help converting data from wide into long
form.  {it:treatvar} may be either a numeric or a string variable.

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt id(varname)}}variable identifying individuals in the existing dataset{p_end}
{p2coldent:* {opt time(varname)}}variable identifying units of time in the existing dataset (must be numeric){p_end}
{p2coldent:* {opt clear}}clear the original dataset from memory and load the imputed dataset into memory{p_end}
{p2coldent:* {cmdab:sav:ing(}{it:{help filename}}[{cmd:, replace}]{cmd:)}}save the dataset of imputed values in {it:filename}{cmd:.dta}{p_end}
{synopt:{opt cov:ariates(varlist)}}existing fully observed numeric variable(s) identifying any additional baseline covariate(s) to be included in the multiple imputation model and analysis if either 
the {cmd:regress} or the {cmd:mixed} option is specified; see {help mimix##specifying_the_covariates:Specifying the covariates}{p_end}
{synopt:{opt interim(string)}}specify that all interim missing values be imputed under missing at random (MAR); see {help mimix##specifying_the_imputation_method:Specifying the imputation method}{p_end}
{synopt:{opt iref(string)}}specify the level of {it:treatvar} chosen for the reference for all interim missing values{p_end}
{synopt:{opt method(string)}}specify the imputation method for all individuals;
see {help mimix##specifying_the_imputation_method:Specifying the imputation method}{p_end}
{synopt:{opt methodvar(varname)}}existing variable identifying the individual-specific imputation method(s);
see {help mimix##specifying_the_imputation_method:Specifying the imputation method}{p_end}
{synopt:{opt mixed}}fit a linear mixed model using restricted maximum
likelihood and combine
results using {help mimix##R1987:Rubin's (1987)} rules{p_end}
{synopt:{opt ref:group(string)}}specify the level of {it:treatvar} chosen for the reference group for all individuals;
required with {cmd:j2r}, {cmd:cir}, and {cmd:cr} imputation; see {help mimix##specifying_the_imputation_method:Specifying the imputation method}{p_end}
{synopt:{opt refgroupvar(varname)}}specify the variable that identifies the level of {it:treatvar} chosen for the reference group for each individual in the existing dataset;
required with {cmd:j2r}, {cmd:cir}, and {cmd:cr} imputation;
see {help mimix##specifying_the_imputation_method:Specifying the imputation method}{p_end}
{synopt:{opt regress}}fit a linear regression of {depvar} at the final timepoint on {it:treatvar},
and any included {opt covariates()}, to each of the imputed datasets and
combine results using Rubin's (1987) rules{p_end}
{synopt:{opt burnb:etween(#)}}specify the number of iterations between imputations in the Markov chain Monte Carlo (MCMC) procedure; default is {cmd:burnbetween(100)}{p_end}
{synopt:{opt burn:in(#)}}specify the number of iterations for the burn-in period in the MCMC procedure; default is {cmd:burnin(100)}{p_end}
{synopt:{opt m:(#)}}specify the number of imputations to be created; default is {cmd:m(5)}{p_end}
{synopt:{opt seed(#)}}set the random-number seed; default is {cmd:seed(0)} {p_end}
{synoptline}
{p2colreset}{...}
{pstd}* {cmd:id()}, {cmd:time()}, and {cmd:clear} or {cmd:saving()} are
required.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:mimix} imputes missing numerical outcomes for a longitudinal trial with
protocol deviation under distinct treatment arm-based assumptions for the
unobserved data, following the general algorithm of 
{help mimix##R2013:Carpenter, Roger, and Kenward (2013)}.  See 
{help mimix##implementing_the_imputation_procedure:Implementing the imputation procedure} 
for a summary of the general algorithm.

{pstd}
The imputation methods, which each correspond to an underlying accessible
assumption for the missing data, are as follows:

{col 8}{hline 60}
{col 8}{ralign 40:Method name}{ralign 20: Name to specify}
{col 48}{ralign 20:in {opt method()}}
{col 48}{ralign 20:or {opt methodvar()}}
{col 8}{hline 60}
{col 8}{ralign 40:Randomized-arm missing at random}{ralign 20:{cmd:mar}}
{col 8}{ralign 40:Jump to reference}{ralign 20:{cmd:j2r}}
{col 8}{ralign 40:Last mean carried forward}{ralign 20:{cmd:lmcf}}
{col 8}{ralign 40:Copy increments in reference}{ralign 20:{cmd:cir} or {cmd:ciir}}
{col 8}{ralign 40:Copy reference}{ralign 20:{cmd:cr}}
{col 8}{hline 60}

{pstd}
Each method constructs appropriate joint distributions for the observed and
unobserved data for deviating individuals, based on an underlying assumption
for the missing data.  These joint distributions imply conditional
distributions for the missing data, given that observed, from which
imputations can be drawn.  The underlying assumptions for the missing data of
each method follow.

{pstd}
'Randomized-arm MAR' assumes that the joint distribution of an individual's
observed and missing outcome data is multivariate normal (MVN) with a mean and
covariance matrix from the individual's randomized treatment group.

{pstd}
'Jump to reference' assumes that the joint distribution of an individual's
observed and missing outcome data is MVN with a mean vector from the
individual's randomized group up to his or her last observed time.
Postdeviation, the mean follows that observed for a specified reference group
(typically the control).  The covariance matrix matches that from the
randomized arm for the predeviation measurements and the reference arm for the
conditional components for the postdeviation given the predeviation
measurements.  Missing data for individuals in the reference group are imputed
under on-treatment group MAR.  This option is particularly appropriate when
the postdeviation individuals ceased their randomized treatment and started
treatment similar to that available in one of the other trial arms (the
reference arm).

{pstd}
'Last mean carried forward' assumes that the joint distribution of an
individual's observed and missing outcome data is MVN with a mean vector from
their randomized group up to his or her last observed time.  Postdeviation,
the mean vector is set equal to the value of the marginal mean for the
individual's randomized treatment group at his or her last observed time.  The
covariance matrix remains that from the individual's randomized treatment
group.  This option is particularly appropriate when it is assumed that the
individuals' unobserved responses will remain constant, on average.

{pstd}
'Copy increments in reference' assumes that the joint distribution of an
individual's observed and missing outcome data is MVN with a mean vector from
the individual's randomized group up to his or her last observed time before
deviating.  Postdeviation, the individual's mean increments follow those from
a specified reference group (typically the control).  The covariance matrix is
the same as for jump to reference.  Missing data for individuals in the
reference group are imputed under on-treatment group MAR.

{pstd}
'Copy reference' assumes that the joint distribution of an individual's
observed and missing outcome data is MVN with a mean vector and covariance
matrix from a specified reference group (typically the control), regardless of
deviation time.  Missing data for individuals in the reference group are
imputed under on-treatment group MAR.

{pstd} 
For full technical details, see
{help mimix##R2013:Carpenter, Roger, and Kenward (2013)}.

{pstd}
A missing value is termed interim whenever a response is later observed for
that individual.  If the {opt interim()} option is specified, then any interim
missing-data values will be imputed under MAR.  This is often a reasonable
assumption for interim missing data.  If {opt interim()} is not used, then any
interim missing-data values will be imputed under the method specified by
{cmd:method()} or {opt methodvar()}.

{pstd}
The imputed data are {helpb mi set} ready to analyze using {helpb mi estimate}.
In addition, they are ready to output in memory if {opt clear} is
specified and to be saved in {it:filename}{cmd:.dta} if {opt saving()} is
specified.

{pstd}
The substantive model of interest used in the primary analysis of the trial,
which defines the treatment group by randomization, should be retained in the
sensitivity analysis to assess the impact of alternative treatment profiles
for deviating individuals on the treatment effect of interest.  Two
substantive model options are built into {cmd:mimix}.  If {opt regress} is
specified, a linear regression of {depvar} at the final timepoint on
{it:treatvar}, and any included {opt covariates()}, is performed on each
imputed dataset, and results are combined according to the combination rules
by {help mimix##R1987:Rubin (1987)}.  If {opt mixed} is specified, a linear
mixed model (with a separate mean for each treatment and time, full
covariate-time interactions for any included {opt covariates()}, and a
separate unstructured variance matrix for each arm) is fit to each of the
imputed datasets using restricted maximum likelihood, and results are combined
using Rubin's rules.


{marker options}{...}
{title:Options}

{phang}
{opt id(varname)} specifies the variable identifying individuals in the
existing dataset.  {cmd:id()} is required and may be either a numeric or a
string variable.

{phang}
{opt time(varname)} specifies the variable identifying units of time in the
original dataset.  {cmd:time()} is required and must be a numeric variable.

{phang}
{opt clear} specifies that the original data in memory be cleared and replaced
by the imputed dataset.  The imputed dataset must be saved manually if
required.  One of {opt clear} or {opt saving()} is required.

{phang}
{cmdab:saving(}{it:{help filename}}[{cmd:, replace}]{cmd:)} saves the imputed
datasets.  A new filename is required unless {opt replace} is also specified.
{opt replace} allows the {it:filename} to be overwritten with new data.  One
of {opt clear} or {opt saving()} is required.

{phang}
{opt covariates(varlist)} specifies any additional baseline covariates to be
included in the multiple-imputation model and analysis if either the
{cmd:regress} or {opt mixed} option is specified.  Any specified
covariates must be fully observed numerical variables.  Dummy variables must
be generated for any factor covariates.  See 
{help mimix##specifying_the_covariates:Specifying the covariates}.

{phang}
{opt interim(string)} specifies an alternative imputation method for all
interim missing values (where the individual has data observed later).
{it:string} may be {cmd:mar}, {cmd:j2r}, {cmd:lmcf}, {cmd:cir}, or
{cmd:cr} (not case sensitive).  See 
{help mimix##specifying_the_imputation_method:Specifying the imputation method}.

{phang}
{opt iref(string)} specifies the level of {it:treatvar} chosen for the
reference for all interim missing values (where the individual has data
observed later).  {cmd:iref()} is required when using the {cmd:j2r},
{cmd:cir}, or {cmd:cr} imputation method.  See 
{help mimix##specifying_the_imputation_method:Specifying the imputation method}.

{phang}
{opt method(string)} defines the imputation method for all individuals.
{it:string} may be {cmd:mar}, {cmd:j2r}, {cmd:lmcf}, {cmd:cir} (or
{cmd:ciir}), or {cmd:cr} (not case sensitive).  {cmd:method()} and
{cmd:methodvar()} are mutually exclusive; specifying both will return an
error message.  See 
{help mimix##specifying_the_imputation_method:Specifying the imputation method}.

{phang}
{opt methodvar(varname)} specifies the variable in the original dataset that
contains the individual-specific imputation method(s).  This option should be
used if different imputation methods are required for different individuals.
{cmd:methodvar()} must be a string variable containing one of {cmd:mar},
{cmd:j2r}, {cmd:lmcf}, {cmd:cir}, or {cmd:cr} (not case sensitive) for each
individual.  {cmd:methodvar()} and {cmd:method()} are mutually exclusive;
specifying both will return an error message.  See 
{help mimix##specifying_the_imputation_method:Specifying the imputation method}.

{phang}
{opt mixed} uses {cmd:mi estimate} with Stata's default options to fit a
saturated repeated-measures model using restricted maximum likelihood -- with
a separate mean for each treatment and time, full covariate-time interactions
for any included {cmd:covariates()}, and a separate unstructured covariance
matrix for each arm -- to each of the imputed datasets.  {cmd:mixed} combines
results using {help mimix##R1987:Rubin's (1987)} rules for inference.  This
option may add substantially to the postimputation computation time if a large
number of imputations have been specified.

{phang}
{opt refgroup(string)} specifies the level of {it:treatvar} chosen for the
reference group for all individuals.  This option is required when using the
{cmd:j2r}, {cmd:cir}, or {cmd:cr} imputation method.  {cmd:refgroup()} and
{cmd:refgroupvar()} are mutually exclusive; specifying both will return an
error message.  See 
{help mimix##specifying_the_imputation_method:Specifying the imputation method}.

{phang}
{opt refgroupvar(varname)} specifies the variable in the original dataset that
identifies the level of {it:treatvar} chosen for the reference for each
individual.  This option is required when using the {cmd:j2r}, {cmd:cir}, or
{cmd:cr} imputation method.  {opt refgroupvar()} and {opt refgroup()} are
mutually exclusive; specifying both will return an error message.  See 
{help mimix##specifying_the_imputation_method:Specifying the imputation method}.

{phang}
{opt regress} uses {cmd:mi estimate} with Stata's default options to fit a
linear regression of {it:depvar} at the final timepoint on {it:treatvar}, and
any included {cmd:covariates()}, to each of the imputed datasets.  It combines
results using {help mimix##R1987:Rubin's (1987)} rules for inference.

{phang}
{opt burnbetween(#)} specifies the number of iterations between pulls for the
posterior in the MCMC.  The default is {cmd:burnbetween(100)}.

{phang}
{opt burnin(#)} specifies the number of iterations in the MCMC burn-in.  The
default is {cmd:burnin(100)}.

{phang}
{opt m(#)} specifies the number of imputations required.  The default is
{cmd:m(5)}.

{phang}
{opt seed(#)} specifies the seed for the random-number generator.  The default
is {cmd:seed(0)}, meaning that no seed is specified by the user and so the
current value of Stata's random-number seed will be used; this will result in
different sets of imputations for multiple program runs.  To reproduce a set
of imputations, the same random-number seed should be used with the original
data sorted in exactly the same order. If the covariates option is used then
covariates must be specified in the same order to obtain replicable results. 
This is due to an internal command which re-orders the data to correspond 
with the order of the covariate specification; MI is a Monte-Carlo (i.e. stochastic) 
method which will produce different results depending on the order specificed for included variables.


{marker remarks}{...}
{title:Remarks}

{pstd}
Remarks are presented under the following headings:{p_end}

{phang2}{help mimix##general_remarks:General remarks}{p_end}
{phang2}{help mimix##specifying_the_imputation_method:Specifying the imputation method}{p_end}
{phang2}{help mimix##implementing_the_imputation_procedure:Implementing the imputation procedure}{p_end}
{phang2}{help mimix##specifying_the_covariates:Specifying the covariates}{p_end}


{marker general_remarks}{...}
    {title:General remarks}

{pstd}
Data are required in long format with one record per individual per timepoint.
See {helpb reshape} for help converting data from wide into long form.  The
imputed dataset is produced in long format, with one record per individual per
timepoint per imputation and is {cmd:mi set} ready to analyze using 
{helpb mi estimate}.  The imputed dataset is output in memory if {cmd:clear}
is specified and is saved in {it:filename}{cmd:.dta} if {cmd:saving()} is
specified.

{pstd}
Because of extensive data manipulation, {cmd:mimix} uses the {helpb preserve}
and {helpb restore} commands.  While {cmd:mimix} can be successfully run on
data that are already preserved, we recommend that users cancel any previous
data preserve by using {cmd:restore, not} to ensure the {opt clear} and
{cmd:saving()} options of {cmd:mimix} work as intended.


{marker specifying_the_imputation_method}{...}
    {title:Specifying the imputation method}

{pstd}
The five imputation options of {cmd:mimix} are randomized-arm MAR, jump to
reference, last mean carried forward, copy increments in reference, and copy
reference.  Each method constructs appropriate joint distributions for the
observed and unobserved data for deviating individuals based on an underlying
assumption for the missing data.  These joint distributions imply conditional
distributions for the missing data, given that observed, from which
imputations can be drawn.

{pstd}
The {cmd:mimix} command must contain either the {opt method()} option to
indicate which imputation method should be employed for all individuals or the
{opt methodvar()} option to indicate which imputation method should be
employed for each individual.

{pstd}
Values must be one of {cmd:mar} (randomized-arm MAR), {cmd:j2r} (jump to
reference), {cmd:lmcf} (last mean carried forward), {cmd:cir} or {cmd:ciir}
(copy increments in reference), or {cmd:cr} (copy reference).  Values are not
case sensitive.

{pstd}
If the {cmd:j2r}, {cmd:cir}, or {cmd:cr} imputation method is used, then
either the {opt refgroup()} option must also be used to specify the reference
level of the {it:treatvar} for all individuals or the {opt refgroupvar()}
option must also be used to indicate the reference level of the {it:treatvar}
for each individual.  Together, these variables fully specify the required
imputation method.  If one of the imputation methods that includes a reference
group is specified for all individuals (or for specific individuals via
{cmd:methodvar()}), then missing data for individuals in that reference group
(with the reference-imputation specification) are imputed under randomized-arm
MAR.

{pstd}
Different postdeviation assumptions can be made for different individuals as
specified by the required {opt methodvar()} variable.  However, the
specification cannot vary within an individual over time.

{pstd}
The {opt interim()} option specifies the imputation method for all interim
missing values, defined as missing values with responses observed later for
that individual.  If this option is not used, any interim missing values will
be imputed under the specified imputation method, in the same way as missing
postdeviation data.


{marker implementing_the_imputation_procedure}{...}
    {title:Implementing the imputation procedure}

{pstd}
The general algorithm of
{help mimix##R2013:Carpenter, Roger, and Kenward (2013)} that is implemented
by the {cmd:mimix} command can be summarized as follows:

{pstd}
1. Separately for each treatment arm, take all the observed data, assume MAR,
and fit an MVN distribution with an unstructured mean (that is, a separate
mean for each of the baseline and the postrandomization observation times) and
a variance-covariance matrix using a Bayesian approach with an improper prior
for the mean and an uninformative Jeffreys prior for the covariance matrix.

{pstd}
2. Draw a mean vector and covariance matrix from the posterior distribution
for each treatment arm.  Specifically, we use the MCMC method to draw from the
appropriate Bayesian posterior, with a sufficient burn-in, and we update the
chain sufficiently in between to ensure that subsequent draws are independent.
The sampler is initiated using the expectation-maximization (EM) algorithm.

{pstd}
3. Use the draws in step 2 to form the joint distribution for each deviating
individual's observed and missing outcome data as required, depending on the
assumption for the missing data.  See {help mimix##description:Description}
for the available imputation options.

{pstd}
4. Construct the conditional distribution of missing given observed outcome
data for each individual who deviated from the joint distribution formed in
step 3.  Sample missing data from the conditional distributions to create a
completed dataset.

{pstd}
5. Repeat steps 2-4 m times, resulting in m imputed datasets.

{pstd}
To complete steps 1 and 2 of the general procedure, {cmd:mimix} uses Stata's
{helpb mi impute mvn} command with the {opt mcmconly} option.  If the response
variable of interest is measured at an occasion with only a very few complete
cases, then {cmd:mi impute mvn} may terminate with an error messageif there is
not enough information in the observed data to reliably estimate aspects of
the covariance structure in the required MVN model.  If this is the case, we
advise the user to explore an alternative viable MVN model for the data by
using the {cmd:mi impute mvn} command.  See {helpb mi impute mvn}.  The
response at the occasion with few observed outcomes may potentially need to be
excluded from the analysis and {cmd:mimix} rerun.


{marker specifying_the_covariates}{...}
    {title:Specifying the covariates}

{pstd}
Any additional baseline covariates that are to be included in the imputation
model (and the analysis if {opt regress} or {opt mixed} is specified) must be
fully observed and numeric.  At the imputation step, they are formally treated
as continuous in the MVN imputation.  Binary variables can be included,
provided they have a numeric coding.  Dummy variables must be generated for
any factor covariates, that is, c-level categorical variables must be included
as (c-1) numeric dummy indicator variables.

{pstd}
Covariates must also be constant over time for each individual.  If not, the
first value across all timepoints will be used.

{pstd}
Individuals with missing covariates will be dropped from the multiple
imputation and noted in the output.


{marker examples}{...}
{title:Examples}

{pstd}
Analyzing the asthma trial data{p_end}
{phang2}{cmd:. use asthma}{p_end}

{pstd}
Multiple imputation assuming the response variable {cmd:fev} is MAR{p_end}
{phang2}{cmd:. mimix fev treat, id(id) time(time) method(mar) covariates(base) clear m(50) seed(101)}{p_end}

{pstd}
Multiple imputation and regression analysis assuming last mean carried forward
for the response variable {cmd:fev}{p_end}
{phang2}{cmd:. use asthma, clear}{p_end}
{phang2}{cmd:. mimix fev treat, id(id) time(time) method(lmcf) covariates(base) clear m(50) regress seed(101)}{p_end}

{pstd}
Multiple imputation and regression analysis assuming jump to reference for the
response variable {cmd:fev}, with placebo=2 as the reference{p_end}
{phang2}{cmd:. use asthma, clear}{p_end}
{phang2}{cmd:. mimix fev treat, id(id) time(time) method(j2r) refgroup(2) covariates(base) clear m(50) regress seed(101)}{p_end}

{pstd}
Saving the imputed dataset with filename {cmd:mimix_example}, assuming
copy increments in reference for the response variable {cmd:fev}, with
placebo=2 as the reference{p_end}
{phang2}{cmd:. use asthma, clear}{p_end}
{phang2}{cmd:. mimix fev treat, id(id) time(time) method(cir) refgroup(2) covariates(base) saving(mimix_example, replace) m(50) seed(101)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mimix} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}total sample size{p_end}
{synopt:{cmd:r(Nmiss)}}total number of individuals with incomplete data{p_end}
{synopt:{cmd:r(Ncomp)}}total number of individuals with complete data{p_end}
{synopt:{cmd:r(M)}}number of imputations{p_end}
{synopt:{cmd:r(burnin)}}number of MCMC burn-in iterations{p_end}
{synopt:{cmd:r(bbetween)}}number of MCMC burn-between iterations{p_end}

{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:r(treatvar)}}name of treatment group variable{p_end}
{synopt:{cmd:r(covariates)}}names of covariates{p_end}
{synopt:{cmd:r(method)}}imputation method (with {opt method()} only) {p_end}
{synopt:{cmd:r(methodvar)}}imputation method variable (with {opt methodvar()} only) {p_end}
{synopt:{cmd:r(rgroup)}}name of reference group (with {opt refgroup()} only) {p_end}
{synopt:{cmd:r(rgroupvar)}}name of reference group variable (with {opt refgroupvar()} only) {p_end}
{synopt:{cmd:r(rseed)}}random-number seed{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(Ntreat)}}sample size in each treatment group{p_end}
{synopt:{cmd:r(Ntreat_mis)}}number of individuals with incomplete data in each treatment group{p_end}
{synopt:{cmd:r(Ntreat_comp)}}number of individuals with complete data in each treatment group{p_end}
{synopt:{cmd:r(Ntreat_pat)}}number of unique missing-value patterns in each treatment group{p_end}
{synopt:{cmd:r(niter_em)}}number of iterations EM takes to converge in each treatment group{p_end}
{synopt:{cmd:r(lpobs_em)}}observed log posterior in EM in each treatment group{p_end}
{synopt:{cmd:r(conv_em)}}convergence flag for EM in each treatment group{p_end}
{p2colreset}{...}


{title:Acknowledgments}

{pstd}
This Stata program is an adaptation of the SAS macro, miwithd, written by James Roger available at www.missingdata.org.uk.
I also thank Tim Morris (MRC CTU at UCL, UK) and Baptiste Leurent (London School of
Hygiene and Tropical Medicine, UK)  for their helpful comments on the program.


{marker references}{...}
{title:References}

{marker R2013}{...}
{phang}
Carpenter, J. R., J. H. Roger, and M. G. Kenward. 2013. Analysis of longitudinal trials with protocol deviation: A framework for relevant, accessible assumptions, and inference via multiple imputation. 
{it:Journal of Biopharmaceutical Statistics} 23: 1352-1371.

{marker R1987}{...}
{phang}
Rubin, D. B. 1987.  {it:Multiple Imputation for Nonresponse in Surveys}. New
York: Wiley.


{title:Author}

{pstd}
Suzie Cro{break}
London School of Hygiene & Tropical Medicine, UK{break}
MRC Clinical Trials Unit, University College London, UK{break}
s.cro@imperial.ac.uk


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 16, number 2: {browse "http://www.stata-journal.com/article.html?article=st0440":st0440}{p_end}
