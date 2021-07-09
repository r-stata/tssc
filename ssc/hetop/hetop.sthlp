{smcl}
{* last edited Jul 10, 2019}{...}
{hline}
help file for {cmd:hetop} version 3.0
{hline}

{title:Title}

{phang}
{bf:hetop} {hline 2} heteroskedastic ordered probit models

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmdab:hetop}
{it:grpvar levelvar}
{cmd: ,} {opt numcats(#)}
[ {opt modtype(string)}
  {opt identify(string)}
  {opt setref(#)}
  {opt phop(varname [ , mean ])}
  {opt SETCuts(numlist)}
  {opt pkvals(varname)}
  {opt STARTFRom(namelist)}
  {opt kappa(#)}
  {opt save([ string , star prime raw se cov ])} 
  {opt ADDCONStraints(string)}
  {opt minsize(#)}
  {opt initvals}
  {opt gaps} 
  {opt noisily}
  {opt homop}
  {opt CSD(#)}
  {it:maximize_options} ]


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}

{synopt:{opt numcats(#)}}
number of ordered categories in outcome variable{p_end}

{syntab:Optional}

{synopt:{opt modtype(hetop/homop)}}
specify a heteroskedastic or homoskedastic model; allowable options are 
{it:hetop} (the default) or {it:homop}{p_end}

{synopt:{opt identify(sums/refgroup/cuts)}}
type of constraints used to identify the model; allowable options are {it:sums} 
(the default) or {it:refgroup} or {it:cuts}{p_end}

{synopt:{opt setref(#)}}
the ID number from {it:grpvar} of the group to be constrained as a reference
group{p_end}

{synopt:{opt phop(varname [ , mean ])}}
constrain groups with {it:varname}=1 to have a single, common ln(SD) estimate. 
Optionally typing phop(varname, mean) will constrain this single ln(SD) estimate
to be equal to the (unweighted) mean ln(SD) estimate for all groups with
{it:varname}=0{p_end}

{synopt:{opt setcuts(numlist)}}
estimate the model with cut scores fixed to the values in {it:numlist}. Length
of {it:numlist} must be equal to {it:numcats}-1.{p_end}

{synopt:{opt pkvals(varname)}}
specifies a variable containing the population proportions of each group. If not
specified, by default the sample proportions in the data will be used as the
population proportions of each group{p_end}

{synopt:{opt STARTFRom(namelist)}}
start estimation from values specified in the matrix {it:namelist}.{p_end}

{synopt:{opt kappa(1/2)}}
adjust the de-referencing equations. Recommended to leave this option
blank.{p_end}

{synopt:{opt save([ string , star prime raw se cov ])}}
save estimated means and standard deviations in variables named
"mstar{bf:string}", "mstar{bf:string}_se", etc. Leaving {it:string} blank is
allowed. Estimates can be in the star, prime, and/or raw metric.
Optionally save estimated standard errors ({it:se}) and/or covariance
between mean and standard deviation estimate ({it:cov}).{p_end} 

{synopt:{opt ADDCONStraints(string)}}
index values of additional pre-defined constraints to pass to the
maximization.{p_end}

{synopt:{opt minsize(#)}}
exclude all groups with sample sizes smaller than # from estimation.{p_end}

{synopt:{opt initvals}}
calculate initial starting values for estimation.{p_end}

{synopt:{opt gaps}}
display additional statistics.{p_end}

{synopt:{opt noisily}}
print output during estimation.{p_end}

{synopt:{opt homop}}
a shortcut equivalent to typing {opt modtype(homop)}.{p_end}

{synopt:{opt CSD(#)}}
constrain the single, common SD parameter to {it:#} when estimating a
HOMOP model; the default is 1.{p_end}

{synopt:{it: maximize_options}}
options for the maximization process, see {help maximize} for details.{p_end}

{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:hetop} uses maximum likelihood (ML) to estimate means and standard
deviations of underlying continuous,
normal distributions for each group in {it:grpvar} based on the frequency counts
of observations in each variable with the stem {it:levelvar}*. The estimates
are returned in a standardized metric to facilitate interpretation and
subsequent analyses.

{pstd}
The {it:grpvar} variable must uniquely identify the groups,
and it is recommended to number the groups consecutively 1:G. There should be
one row per group, with one column of frequency counts for each of the {it: K}
ordered categories. The count variables should be named as {it:levelvarX} where
X is a sequence of ordered integer values indicating the order of the categories.
While the order of these values must correspond to the ordering of the categories,
the magnitude of the values is arbitrary (so {it:levelvar1}, {it:levelvar2},
{it:levelvar3} is the same as {it:levelvar0}, {it:levelvar4}, {it:levelvar5}).
The starting value calculations are based on the integer codes; the best
starting values tend to be obtained when the values are sequential integers.

{pstd}
Earlier versions of {cmd:hetop} extended and relied on the {help oglm} command
for Stata to carry out the estimation. Although the current version no longer
relies on {help oglm} the estimation and approach are informed by {help oglm}.

{pstd}
The data file should have the following layout:

	+---------------------------------------------------------+
	| grpvar  levelvar0   levelvar1   levelvar2   levelvar3   |
	|---------------------------------------------------------|
	|   1        750        1428          741          66     |
	|   2        600        1197          811         155     |
	|   3        840        1653         1080         160     |
	|  ...       ...         ...          ...         ...     |
	|   G       2204        3622         2507         570     |
	|---------------------------------------------------------|

{pstd}
The {cmd:hetop} function can be used to estimate the following models:

{pstd}
{bf:HETOP}: {bf:het}eroskedastic {bf:o}rdered {bf:p}robit models with a unique
mean and standard deviation for each group.

{pstd}
{bf:PHOP}: {bf:p}artially {bf:h}eteroskedastic {bf:o}rdered {bf:p}robit models
with unique means for all groups, unique standard deviations for one set of
groups and a single, pooled standard deviation estimate for remaining groups.

{pstd}
{bf:HOMOP}: {bf:hom}oskedastic {bf:o}rdered {bf:p}robit model with a unique mean
estimated for each group but standard deviations of all groups constrained to
be equal.

{pstd}
{cmd:hetop} relies on a user-written ML function ({cmd:hetop_lf.ado}) to
carry out the ML estimation using Stata's {help ml} features.

{pstd}
Note that when there are data in only two categories it is only possible to
estimate a HOMOP model. When there are more than 2 categories but there are
only non-zero counts
in 2 or fewer categories for some groups, finite ML estimates for the means and
standard deviations of those groups may not exist. {help hetop} issues warnings
about the presence of such gruops but does not apply formal checks or other
precautions. In some cases, the estimation algorithm may
indicate convergence to a false solution in the presence of such groups. Slow
convergence or very large standard errors can be signs that the ML estimates
for some groups do not exist or are poorly identified.

{p}

{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt numcats} If numcats<3 only a HOMOP model can be fit.

{dlgtab:Optional}

{phang}
{opt modtype(string)} This can be either {it:homop} for a HOMOP model or
{it:hetop} when fitting HETOP or PHOP models. Default is {opt modtype(hetop)}.

{phang}
{opt identify(string)} In order to identify the model and set the scale for the
estimates, constraints must be placed on the parameter estimates. There are
three possible types of constraints used in {cmd:hetop}.
The {it:sums} option constrains the
weighted sum of the log(SD) estimates and the weighted sum of the means to be 0,
where the weights for each group are the proportion of each group in the
population or the weights specified in {opt pkvals(varname)}. This identification
method can only  be used with G<=300 groups.
The {it:refgroup} option constraints the mean and log(SD) of a single group
to be 0. This group is referred to as a "reference" group. When
specifying {opt identify(refgroup)}, an automatic reference group
will be selected unless a specific group is specified with {opt setref(#)}.
The {it:cuts} option constrains the first two cut scores to -1 and 0, respectively.
If there is only 1 cut score (2 categories), the cut score will be constrained to
be 0; if a HOMOP model is fit a msingle cut score will be set to 0.
All 3 sets of constraints yield theoretically equivalent models; however,
in some cases the reference group approach may yield higher convergence rates for
problematic samples. In all cases, {cmd:hetop} produces "star" estimates that are
in a standardized metric as described in Reardon et al. (2017). These standardized
estimates should be identical regardless of which identification method is
used. Default is {opt identify(sums)}.

{phang}
{opt setref(#)} See above description of {opt identify}. Specifying {opt setref}
without specifying {opt identify} is the same as specifying
{opt identify(refgroup)}.

{phang}
{opt phop(varname [ , mean ])} Specifies a 0/1 indicator variable. All groups with
{it:varname}=0 will receive a unique standard deviation estimate and all
groups with {it:varname}=1 will receive a single, pooled standard deviation
estimate. The {it:mean} option further constraints the single pooled ln(SD)
estimate to be equal to the (unweighted) mean of the ln(SD) estimates for all
groups with {it:varname}=0. Cannot be specified with the {opt modtype(homop)}
option. Note that the {it:mean} option will only work if there are 479 or
fewer unconstrained group SD estimates.

{phang}
{opt setcuts(numlist)} Constrains the cut scores to be equal to the values in
{it:numlist}. The values in {it:numlist} must be ascending. This is a
shortcut to specifying these constraints with the {opt addconstraints()} option.

{phang}
{opt pkvals(varname)} A variable specifying the proportion of each
group in the population.
These are used to identify the model for the sums constraints method and
are also used in the standardization and standard error calculations. No
checks made to verify that, e.g., these sum to 1.

{phang}
{opt STARTFRom(namelist)} Specifies a matrix containing starting values
to use as initial values for the ML estimation. Names must match the
parameters names used in estimation (see e(b)). No checks are made to verify the
names or reasonableness of the values.

{phang}
{opt kappa(1/2)} See Reardon et al. (2016) for details about this option.
Default is {opt kappa(1)}.

{phang}
{opt save([ string , star prime raw se cov ])} Option to save mean and standard
deviation estimates as new variables. Including the {it:star/prime/raw} options
will include saved estimates in the star, prime, and/or raw metric.
The star metric estimates are on a standardized scale with a marginal mean of 0
and standard deviation of 1 across all groups. The prime metric estimates
are in a metric for which the weighted sum of the means and sum of the ln(SD)
estimates are 0. The raw metric estimates are relative to the model identification
used; i.e., relative to the sums, reference group, or cut score constraints. In
some cases the prime and raw metric estimates are identical. Specifying {it:se}
will also save estimated standard errors. Specifying {it:cov} will also save
the estimated sampling covariance between each group's mean and standard 
deviation estimate. The new variables will have names of the form
m`metric'{bf:string}, s`metric'{bf:string},
m`metric'{bf:string}_se, s`metric'{bf:string}_se, and z`metric'{bf:string}_cov,
where `metric' is one of {it:star/prime/raw}. It is allowable to leave {it:string}
blank. Failing to specify at least one of {it:star/prime/raw} will not save
any variables.

{phang}
{opt ADDCONStraints(string)} Many models fit by {cmd:hetop} specify constraints
automatically. This option can be used to place additional constraints on the
model. These constraints must be defined prior to running {cmd:hetop}.
Contraint numbers listed here will be added to the call to {help oglm}.
WARNING: no checks are made to ensure that these constraints are compatible with
those that will automatically be applied within {cmd:hetop}. Use at own risk.

{phang}
{opt minsize(#)} A convenience for excluding small groups from estimation.
Any group with fewer than {it:minsize} observations will be excluded from
estimation.

{phang}
{opt initvals} Initial values are computed by treating the integer codes for
the ordinal categories as interval scores. A mean and standard deviation is
calculated for each group as an approximate starting value and rescaled
according to the model identification strategy. If not specified, default is
to start all mean and ln(SD) values at 0, with the cut scores set at the
standard normal quantiles of observed cumulative category proportions.

{phang}
{opt gaps} If specified, an additional matrix of pairwise gaps will be returned.
This may slow down the runtime of the code.

{phang}
{opt noisily} Displays output while running the {cmd ml} estimation.

{phang}
{opt homop} Equivalent to {opt modtype(homop)}.

{phang}
{opt CSD(#)} When estimating a HOMOP model, the common group standard deviation
value must be constrained to a fixed value. Specifying {opt CSD(#)} will constrain
it to {bf:#}. By default it will be constrained to 1.

{phang}
{it:maximize_options} See {help maximize} for more details. It should not
generally be necessary to specify any of these options.

{marker remarks}{...}
{title:Remarks}

{pstd}
For detailed explanation of the models fit see Reardon, Shear, 
Castellano and Ho (2017).
{p_end}

{marker examples}{...}
{title:Examples}

use "hetop-example.dta" , clear

*Fit HETOP model with fewest possible options:
hetop id level , numcats(4)
ml display

*Which is equivalent to:
hetop id level , numcats(4) modtype(hetop) identify(refgroup)
ml display

*Fit HOMOP model with fewest possible options:
hetop id level , numcats(4) homop

*Which is equivalent to:
hetop id level , numcats(4) modtype(homop) identify(refgroup)

*Fit PHOP model with fewest possible options; all groups with n<=185 to have a single standard deviation estimate:
preserve
  g phopvar = ng <= 185
  hetop id level , numcats(4) phop(phopvar, mean) save(,star)

  * show that this value is equal to the (unweighted) mean of unconstrained lns estimates:
  g lnstar = ln(sstar)
  table phopvar , c(m lnstar sd lnstar)
restore
  
*Fit HETOP model with reference group constraints; automatically selected reference group:
hetop id level , numcats(4) identify(refgroup)

*Fit HETOP model with reference group constraints; use group 1 as reference group:
hetop id level , numcats(4) setref(1)

*Use cut score identification
hetop id level , numcats(4) identify(cuts) noisily
mat lis e(craw)
mat lis e(cstar)

*Use sums constraints
hetop id level , numcats(4) identify(sums) noisily

*If integer codes are not sequential
preserve
  rename level4 level6
  hetop id level , numcats(4) initvals
restore

*Fix cut scores to pre-specified values
hetop id level , numcats(4) setcuts(-1 0 1)
ml display

*Choose reference group to be group 2
hetop id level , numcats(4) identify(refgroup) setref(2)
ml display

* Add a user-defined constraint
constraint free
local c1 = `r(free)'
constraint define `c1' [mean]:1.id=0.5
constraint free
local c2 = `r(free)'
constraint define `c2' [lnsigma]:1.id=0
hetop id level , numcats(4) identify(refgroup) setref(5) addconstraints(`c1' `c2')
constraint dir
constraint drop `c1' `c2'
constraint dir
ml display 

{title:Stored results}

{pstd}
{cmd:hetop} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}

{synopt:{cmd:e(N)}}sum of counts across all groups{p_end}
{synopt:{cmd:e(initvals)}}0 if not used; 1 if used{p_end}
{synopt:{cmd:e(mseRC)}}error code for mstar Std. Err. calculations{p_end}
{synopt:{cmd:e(sseRC)}}error code for sstar Std. Err. calculations{p_end}
{synopt:{cmd:e(cseRC)}}error code for cstar Std. Err. calculations{p_end}
{synopt:{cmd:e(varmatsRC)}}error code for other Std. Err. calculations{p_end}
{synopt:{cmd:e(icchat)}}estimated ICC{p_end}
{synopt:{cmd:e(icchatratio)}}alternate form of estimated ICC{p_end}
{synopt:{cmd:e(refgrp)}}reference group ID; 0 if reference group not used.{p_end}
{synopt:{cmd:e(numgrps)}}number of groups.{p_end}
{synopt:{cmd:e(varsigprime)}}estimated sampling variance of sigmaprime{p_end}
{synopt:{cmd:e(sigmab)}}estimated between group variance in prime metric{p_end}
{synopt:{cmd:e(sigmaw)}}estimated within group variance in prime metric{p_end}
{synopt:{cmd:e(sigmaprime)}}estimated total standard deviation in prime metric{p_end}
{synopt:{cmd:e(icchat_var)}}estimated sampling variance of ICC{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}

{synopt:{cmd:e(grpid)}}name of group ID variable{p_end}
{synopt:{cmd:e(levelvars)}}name of category count variables used{p_end}
{synopt:{cmd:e(csd)}}value of CSD() used in estimation; "." if not used{p_end}
{synopt:{cmd:e(phop)}}name of PHOP variable, "." if not used.{p_end}
{synopt:{cmd:e(cmd)}}hetop{p_end}
{synopt:{cmd:e(modtype)}}either "hetop" or "homop"{p_end}
{synopt:{cmd:e(identify)}}either "sums" or "refgroup" or "cuts".{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}

{synopt:{cmd:e(b)}}parameter estimates returned by ml{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimates from ml{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix{p_end}
{synopt:{cmd:e(mstar)}}vector of estimated means in standardized metric{p_end}
{synopt:{cmd:e(mstar_se)}}vector of standard errors of estimated means in standardized metric{p_end}
{synopt:{cmd:e(sstar)}}vector of estimated standard deviations in standardized metric{p_end}
{synopt:{cmd:e(sstar_se)}}vector of standard errors of estimated standard deviations in standardized metric{p_end}
{synopt:{cmd:e(cstar)}}vector of estimated cut scores in standardized metric{p_end}
{synopt:{cmd:e(cstar_se)}}vector of standard errors of estimated cut scores in standardized metric{p_end}

{synopt:{cmd:e(Vstar)}}sampling variance-covariance matrix of mstar{p_end}
{synopt:{cmd:e(Wstar)}}sampling variance-covariance matrix of sstar{p_end}
{synopt:{cmd:e(Zstar)}}sampling variance-covariance matrix of mstar and sstar{p_end}
{synopt:{cmd:e(Dstar)}}sampling variance-covariance matrix of sstar and cstar{p_end}
{synopt:{cmd:e(Astar)}}sampling variance-covariance matrix of mstar and cstar{p_end}
{synopt:{cmd:e(Bstar)}}sampling variance-covariance matrix of cstar{p_end}

{synopt:{cmd:e(mprime)}}vector of estimated means in prime metric{p_end}
{synopt:{cmd:e(mprime_se)}}vector of standard errors of estimated means in prime metric{p_end}
{synopt:{cmd:e(sprime)}}vector of estimated standard deviations in prime metric{p_end}
{synopt:{cmd:e(sprime_se)}}vector of standard errors of estimated standard deviations in prime metric{p_end}
{synopt:{cmd:e(gprime)}}vector of estimated ln(SD) values in prime metric{p_end}
{synopt:{cmd:e(gprime_se)}}vector of standard errors of estimated ln(SD) values in prime metric{p_end}
{synopt:{cmd:e(cprime)}}vector of estimated cut scores in prime metric{p_end}
{synopt:{cmd:e(cprime_se)}}vector of standard errors of estimated cut scores in prime metric{p_end}

{synopt:{cmd:e(Vprime)}}sampling variance-covariance matrix of mprime{p_end}
{synopt:{cmd:e(Wprime)}}sampling variance-covariance matrix of sprime{p_end}
{synopt:{cmd:e(Zprime)}}sampling variance-covariance matrix of mprime and sprime{p_end}
{synopt:{cmd:e(Dprime)}}sampling variance-covariance matrix of sprime and cprime{p_end}
{synopt:{cmd:e(Aprime)}}sampling variance-covariance matrix of mprime and cprime{p_end}
{synopt:{cmd:e(Bprime)}}sampling variance-covariance matrix of cprime{p_end}

{synopt:{cmd:e(mraw)}}vector of estimated means in raw metric{p_end}
{synopt:{cmd:e(mraw_se)}}vector of standard errors of estimated means in raw metric{p_end}
{synopt:{cmd:e(sraw)}}vector of estimated standard deviations in raw metric{p_end}
{synopt:{cmd:e(sraw_se)}}vector of standard errors of estimated standard deviations in raw metric{p_end}
{synopt:{cmd:e(craw)}}vector of estimated cut scores in raw metric{p_end}
{synopt:{cmd:e(craw_se)}}vector of standard errors of estimated cut scores in raw metric{p_end}

{synopt:{cmd:e(Vraw)}}sampling variance-covariance matrix of mraw{p_end}
{synopt:{cmd:e(Wraw)}}sampling variance-covariance matrix of sraw{p_end}
{synopt:{cmd:e(Zraw)}}sampling variance-covariance matrix of mraw and sraw{p_end}
{synopt:{cmd:e(Araw)}}sampling variance-covariance matrix of mraw and craw{p_end}
{synopt:{cmd:e(Braw)}}sampling variance-covariance matrix of craw{p_end}

{synopt:{cmd:e(initvalsmat)}}vector of initial starting values for all model parameters{p_end}
{synopt:{cmd:e(refrank)}}vector of group ID values, sorted in order of (potentially) best to worst reference groups{p_end}
{synopt:{cmd:e(PI)}}matrix used for standardization, based on e(pk) values{p_end}
{synopt:{cmd:e(pk)}}vector of proportions used as population proportions for each group in computations{p_end}

{synopt:{cmd:e(G)}}matrix of all pairwise standardized mean differences between groups, using an equally weighted pooled SD (if gaps option specified){p_end}
{synopt:{cmd:e(Gvar1)}}matrix of estimated sampling variances for each gap (if gaps option specified){p_end}

{p2colreset}{...}

{title:References}

{pstd}Reardon, S. F., Shear, B. R., Castellano, K. E., & Ho, A. D.
(2017). Using heteroskedastic ordered probit models to recover moments
of continuous test score distributions from coarsened data.
{it:Journal of Educational and Behavioral Statistics}, {it:42}(1), 3–45.
{break}DOI: 10.3102/1076998616666279{break}
Pre-publication version available at:
{browse "http://cepa.stanford.edu/content/using-heteroskedastic-ordered-probit-models-recover-moments-continuous-test-score-distributions-coarsened-data"}

{title:Acknowledgements}

{pstd}
We gratefully acknowledge the help of Katherine Castellano, Andrew Ho,
Erin Fahle, Demetra Kalogrides, and JR Lockwood in developing and testing the HETOP
methods and code used here. {cmd:hetop} initially relied on and is informed by
the design of {cmd:oglm}, an excellent Stata program written by Richard Williams.
Richard Williams provided helpful input during development.

{pstd}
Development of {cmd:hetop} was partially funded by an Institute of Education Sciences
training grant (#R305B090016).

{title:Citing hetop in published work}

{pstd}
{cmd:hetop} is a free contribution to the research community. If you use 
{cmd:hetop} in published work please cite it.

Suggested citation:

{pstd}Shear, B. R., & Reardon, S. F. (2019).
HETOP: Stata module for estimating heteroskedastic ordered probit models with ordered frequency data.
Version 3.0.

If you have questions or suggestions for improvements, please do not hesitate
to contact the authors at the addresses below.

{title:Authors}

{pstd}
Benjamin R. Shear{break}
University of Colorado Boulder{break}
benjamin.shear@colorado.edu{break}

{pstd}
sean f. reardon.{break}
Stanford University{break}
sean.reardon@stanford.edu{break}
