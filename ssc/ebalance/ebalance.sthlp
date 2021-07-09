{smcl}
{* *! version 1.5.3  25jan2014}{...}
{cmd:help ebalance}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:ebalance} {hline 2}}Entropy reweighting to create balanced samples {p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 18 2}
{cmdab:ebalance} [{it:{help varname:treat}}] {it:{help varlist:covar}}
{ifin}
[{cmd:,}
{it:options}]

{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Main}
{synopt:{opth tar:gets(numlist)}}set balance constraints for covariates; default is {cmd:targets(1)}{p_end}
{synopt:{opth manual:targets(numlist)}}alternative for manual specification of balance constraints{p_end}
{synopt:{opth base:wt(varname)}}variable with base weights; default is base weight of 1 for all units{p_end}
{synopt:{opt norm:const(real)}}set normalization constant; default is {cmd:normconst(1.0)}{p_end}

{syntab:Advanced}
{synopt:{opt wttr:eat}}accept base weights for treated units; {opt basewt()} is required{p_end}
{synopt:{opth g:enerate(newvar)}}specify varname for variable that stores the entropy balancing weights{p_end}
{synopt:{opt k:eep(filename)}}specify filename of a dataset that stores the balance table{p_end}
{synopt:{opt rep:lace}}overwrite existing dataset{p_end}
{synopt:{opt maxi:ter(#)}}set maximum number of iterations; default is {cmd:maxiter(20)}{p_end}
{synopt:{opt tol:erance(real)}}set tolerance level for convergence; default is {cmd:tolerance(.015)}{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
  {it:{help varlist: covar}} is a {it:{help varlist}} that may include factor variables, see {help fvvarlist}.
  {p_end}


{title:Description}

{pstd}
{opt ebalance} implements entropy balancing, a data preprocessing procedure that allows users 
to reweight a dataset such that the covariate distributions in the reweighted data satisfy a set 
of specified moment conditions (see Hainmueller 2012 for details). This can be useful to create balanced samples in observational 
studies with a binary treatment where the control group data can be reweighted to match the 
covariate moments in the treatment group. Entropy balancing can also be used to reweight a 
survey sample to known characteristics from a target population. {opt ebalance} can be used to 
adjust differences in the first, second, and third moment of the covariate 
distributions (ie. covariate means, variances, and skewness). Moments of the joint distribution 
can also be adjusted by including interaction terms for the covariates. The weights 
that result from entropy balancing can be passed 
to any standard model to subsequently analyze the reweighted data. {p_end}

{title:Required}

{phang}
{cmd:treat} {it:{help varname}} that specifies the binary treatment variable. Values should be 1 for treated
 and 0 for control units. By default {opt ebalance} will reweight the data from the control units to match the 
 moments computed from the data of the treated units. If the user just has a single data group (eg. a survey sample) 
 that should be reweighted to match some known moments (eg. from a target population), then the {cmd:manualtargets()} 
 option should be used and in this case the {it:treat} variable should be omitted (see {cmd:manualtargets()} for details).

{phang}
{cmd:covar} {it:{help varlist}} that specifies the covariates to be balanced on. At least one variable should be specified.


{title:Options}

{dlgtab:Main}

{phang}
{opth targets(numlist)} specifies the highest order of moment constraints (1, 2, or 3) for each
 variable specified in {it:covar}. For example, {cmd:tar(3 1 2)} means that the adjustment includes the
 1st, 2nd, and 3rd moment for the first covariate, the 1st moment for the second covariate, and the 1st and 2nd moment 
 for the third covariate. By adjustment we mean that the control group data will be reweighted such that the 
 specified moments match the values of the same moments in the treatment group data. 
 The length of {it:numlist} should be identical to the number of covariates specified in {it:covar} except 
 when only a single number is specified, which means that all the covariates will be adjusted to the same highest order 
 as specified by that number, e.g. {cmd:tar(1)} is equivalent to {cmd:tar(1 1 1)} if three covariates are 
 used in {it:covar}. Note that for a binary covariate only its first moment will be considered, regardless what
 number is specified for it in {cmd:targets()}, since matching the 1st moment is sufficient to balance higher moments.

 {phang}
 {opth manualtargets(numlist)} if the user just has a single data group (eg. a survey sample), the {cmd:manualtargets()}
 option can be used to reweight the data such that it matches some user specified target moments for the covariates.
  For example, {cmd:manualtargets(25 10 0.8)} implies that the balancing weights will be chosen such that the means of the 
  1st, 2nd, and 3rd covariate in {it: covar} will match 25, 10, and 0.8, respectively. The length 
  of {it:numlist} should be identical to the number of covariates specified in {it:covar}. Since there is only a single group,
  no {it: treat} variable should be used. The {cmd:manualtargets()} option is not compatible with {cmd:targets()} and {cmd:wttreat}.
  
{phang}
{opth basewt(varname)} a {it:{help varname}} that specifies a variable with survey base weights. If not 
specified, the default is to set all base weights to 1. If specified, the base weights for 
the control units are taken from {cmd:basewt(varname)}, but the base weights for the treated units
are still set to 1 unless {cmd:wttreat} is also specified. In the latter case, the base weights for all
units are taken from {cmd:basewt(varname)}.

{phang}
{opt normconst(real)} a real number that specifies the normalizing constant (the default is 1). The resulting {cmd:ebalance} weights
for the control units are multiplied with this specified real number, e.g. {cmd:normconst(2)} means that the
total of the {cmd:ebalance} weights for the control units is two times the total of the weights for the treated units. 

{dlgtab:Advanced}

{phang}
{opt wttreat} specifies that survey weights for treated units should be taken into consideration.
  The weights are stored in the variable specified by {cmd:basewt()}. Not compatible with {cmd:manualtargets()}. See {cmd:basewt()}.

{phang}
{opth generate(newvar)} creates a new variable {it:newvar} that stores the estimated balancing weights. If not specified,
 the weights are stored in a variable named {it:_webal} by default. Note that {it:_webal} will be replaced when {cmd:ebalance}
 is called again.
 
{phang}
{opt keep(filename)} saves a dataset with the balance table in the file {it:filename}{cmd:.dta}, which will hold the following variables
 (balance table for a single group is slightly different):{p_end}

{p 8 17 15}{cmd:Xname:} covariate that was balanced on

{p 8 17 15}{cmd:mean_Tr:} mean of the treated units

{p 8 17 15}{cmd:mean_Co_Pre:} mean of the raw control units

{p 8 17 15}{cmd:mean_Co_Post:} mean of the reweighted control units

{p 8 17 15}{cmd:var_Tr:} variance of the treated units

{p 8 17 15}{cmd:var_Co_Pre:} variance of the raw control units

{p 8 17 15}{cmd:var_Co_Post:} variance of the reweighted control units

{p 8 17 15}{cmd:skew_Tr:} skewness of the treated units

{p 8 17 15}{cmd:skew_Co_Pre:} skewness of the raw control units

{p 8 17 15}{cmd:skew_Co_Post:} skewness of the reweighted control units

{p 8 17 15}{cmd:sdiff_Pre:} standardized difference between treated and raw control groups

{p 8 17 15}{cmd:sdiff_Post:} standardized difference between treated and reweighted control groups

{phang}
{opt replace} permits {cmd:keep()} to overwrite an existing dataset.
 
{phang}
{opt maxiter(#)} specifies the maximum number of iterations for the algorithm. Usually the default setting of 20 iterations should be sufficient,
 but the maximum number of iterations can be increased if no convergence is achieved. Notice that increasing the number 
 of iterations will not help to achieve convergence if the algorithm fails because too many 
 potentially collinear moment constraints are specified. In such cases, one should 
 lower the order of the moment conditions by resetting {cmd:targets()} or dropping variables in {it: covar}. 
 Another option is to relax the tolerance level. Note that even if convergence is not
 achieved within the maximum number of iterations, {cmd:ebalance} will still return 
 the weights obtained in the last iteration.

{phang}
{opt tolerance(real)} specifies the tolerance level for the convergence of the algorithm. The tolerance level refers to the
maximum deviation across the specified moment constraints. Convergence is achieved if all specified moments match within the
specified tolerance level.

{title:Examples}

{pstd}Load example data (Lalonde Dataset){p_end}
{p 4 8 2}{stata "sysuse cps1re74":. sysuse cps1re74}{p_end}

{pstd}Basic syntax{p_end}
{p 4 8 2}{stata "ebalance treat age educ black, tar(1)":. ebalance treat age educ black, tar(1)}{p_end}

{p 6 6 2}tar(1), short for tar(1 1 1), means that the control units are reweighted to satisfy the balance constraints 
that the 1st moments (means) of {it:age}, {it:educ} and {it:black} match the corresponding moments of the treated units. 
{p_end}

{p 4 8 2}{stata "ebalance treat age educ black, tar(3 2 1)":. ebalance treat age educ black, tar(3 2 1)}{p_end}

{p 6 6 2}control units are reweighted to satisfy the balance constraints that the 1st, 2nd, and 3rd moment 
(means, variances, and skewness) of {it:age}, the 1st and 2nd moment of {it: educ}, and the 1st moment of {it: black} 
match the corresponding moments of the treated units. Since {it: black} is binary, adjusting its 1st moment is sufficient to adjust
the higher moments. {p_end}

{pstd}New variable and higher order constraints{p_end}
{p 4 8 2}{stata "ebalance treat age educ black, g(ebw1) tar(1)":. ebalance treat age educ black, g(ebw1) tar(1)}{p_end}
{p 4 8 2}{stata "ebalance treat age educ black, g(ebw2) tar(3 1 1)":. ebalance treat age educ black, g(ebw2) tar(3 1 1)}{p_end}

{p 6 6 2}The two commands store the estimated balancing weights in the newly generated variables {it:ebw1} and {it:ebw2}
 respectively. {stata `"twoway (kdensity age if treat==1, bw(3)) (kdensity age [aweight=ebw1] if treat==0, bw(3)), xtitle("age") legend(label(1 "treated") label(2 "control")) title("Balancing on the 1st order")"':figure1} and 
{stata `"twoway (kdensity age if treat==1, bw(3)) (kdensity age [aweight=ebw2] if treat==0, bw(3)), xtitle("age") legend(label(1 "treated") label(2 "control")) title("Balancing on the 1st, 2nd and 3rd orders")"':figure2} display the kernel
 densities of {it:age} for the treatment and control group data in the two cases and show how balancing 
constraints may affect the reweighted covariate distributions.{p_end}

{pstd}Interactions{p_end}
{p 4 8 2}{stata "gen ageXblack = age*black":. gen ageXblack = age*black}{p_end}
{p 4 8 2}{stata "ebalance treat educ age black ageXblack, tar(1)":. ebalance treat educ age black ageXblack, tar(1)}{p_end}
{p 4 8 2}{stata "bysort black: tabstat age [aweight=_webal], by(treat) s(N mean variance) nototal":. bysort black: tabstat age [aweight=_webal], by(treat) s(N me v) nototal}{p_end}

{p 6 6 2}By including interaction terms, covariates will be balanced across subsample groups. In the above case,
 for example, {it:age} is balanced within both black and non-black subgroups. It can also be achieved by using the
 functionality for factor variables (see {help fvvarlist} for details) as follows:{p_end}
 
{p 4 8 2}{cmd:. ebalance treat educ black##c.age, tar(1)}{p_end}
{p 4 8 2}{stata "bysort black: tabstat age [aweight=_webal], by(treat) s(N mean variance) nototal":. bysort black: tabstat age [aweight=_webal], by(treat) s(N me v) nototal}{p_end}

{pstd}Save balance table{p_end}
{p 4 8 2}{stata "ebalance treat age educ black, tar(2) k(baltable) rep":. ebalance treat age educ black, tar(2) k(baltable) rep}{p_end}

{p 6 6 2}The balance table for treated and control units of both raw data and reweighted data is saved as {it:baltable.dta} for further use.{p_end}

{pstd}Estimation after reweighting{p_end}
{p 4 8 2}{stata "reg re78 treat age educ black re74 re75 u74 u75":. reg re78 treat age educ black re74 re75 u74 u75}{p_end}
{p 4 8 2}{stata "ebalance treat age educ black re74 re75 u74 u75, tar(2)":. ebalance treat age educ black re74 re75 u74 u75, tar(2)}{p_end}
{p 4 8 2}{stata "svyset [pweight= _webal]":. svyset [pweight= _webal]}{p_end}
{p 4 8 2}{stata "svy: reg re78 treat":. svy: reg re78 treat}{p_end}

{p 6 6 2}We first run a simple regression controlling for all the covariates in the Lalonde dataset. The estimate 
of the treatment effect is rather far from the experimental target answer of $1,794. Then we use {cmd:ebalance} 
to adjust 1st and 2nd moments of the covariates for the control group. The following regression based
 on the reweighted data generates an estimate with much less bias (see Hainmueller 2012 for details).{p_end}
  
{pstd}Example for Single Group{p_end}
{p 4 8 2}{stata "ebalance age educ black hispan if treat==0, manual(28 10 0.1 0.1)":. ebalance age educ black hispan if treat==0, manual(28 10 0.1 0.1)}{p_end}
 
{p 6 6 2}If the user only has a single data group, for example a survey sample that should be reweighted to match some known target moments, then 
the {cmd: manualtargets()} option should be used to specify the moment constraints. Here we use this option such that the 
 control units are reweighted such that the means of {it:age}, {it:educ}, {it:black} and {it:hisp} are equal to 25, 10, 0.1 and 0.1, respectively. Note that 
 no treatment variable is specified in this case since there is only one group.
 {p_end}
 
{pstd}Base Weights{p_end}
{p 4 8 2}{stata "gen basew = 1":. gen basew=1}{p_end}
{p 4 8 2}{stata "ebalance treat age educ black, tar(3) basewt(basew) norm(2)":. ebalance treat age educ black, tar(3) basewt(basew) norm(2)}{p_end}

{p 6 6 2}{cmd: basewt(basew)} option is used to pass user supplied base weights. Moreover, the {cmd: norm(2)} option is used to
set the total of the weights for the control units to two times the total of the weights for the treated units.{p_end}
 
{p 4 8 2}{stata "replace basew = 5 if treat==1 & age>30":. replace basew=5 if treat==1 & age>30}{p_end}
{p 4 8 2}{stata "ebalance treat age educ black, tar(3) basewt(basew) norm(2) wttr":. ebalance treat age educ black, tar(3) basewt(basew) norm(2) wttr}{p_end}

{p 6 6 2}When {cmd: wttreat} is also specified, the base weights for treated units are also taken from {cmd: basewt(basew)}. 
Because of this, the result is slightly different from above.{p_end}
 
{pstd}Optimization settings{p_end}
{p 4 8 2}{stata "ebalance treat age educ black, tar(3) maxi(15)":. ebalance treat age educ black, tar(3) maxi(15)}{p_end}
{p 4 8 2}{stata "ebalance treat age educ black, tar(3) maxi(15) tol(1)":. ebalance treat age educ black, tar(3) maxi(15) tol(1)}{p_end}

{p 6 6 2} In the first example, the optimization does not converge within the default tolerance, so {cmd: ebalance} returns the
weights from the last iteration which already come pretty close. In the second example, the {cmd: tol()} is increased to 
relaxing the convergence criterion.{p_end}

{title:Saved results}

{p 4 8 2}
By default, {cmd:ebalance} ereturns the following results, which 
can be displayed by typing {cmd: ereturn list} after 
{cmd:ebalance} is finished (also see {help ereturn}).  

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(convg)}}whether convergence is achieved (1 = achieved; 0 = not){p_end}
{synopt:{cmd:e(maxdiff)}}maximum deviation across the specified moment constraints{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{opt ebalance}{p_end}
{synopt:{cmd:e(title)}}Entropy Balance{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(lambdas)}}coefficient vector{p_end}
{synopt:{cmd:e(moments)}}sample moments of the treated{p_end}
{synopt:{cmd:e(preBal)}}balance table before reweighting{p_end}
{synopt:{cmd:e(postBal)}}balance table after reweighting{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{synoptline}
{p2colreset}{...}
{p 4 6 2} {cmd:e(lambdas)} and {cmd:e(moments)} are in the same order as the adjusted covariates
  are shown in the {it:Data Setup} section, i.e. the first order moment constraints come first;
  then the second; then the third.{p_end}

{title:References}

{p 4 8 2}
Hainmueller, J. 2012, "Entropy Balancing: A Multivariate Reweighting Method to 
Produce Balanced Samples in Observational Studies." Political Analysis, 20(1), 25-46.

{p 4 8 2}
Zaslavsky, A. 1988, "Representing local reweighting area adjustments of households", Survey Methodology 14(2), 265-288.

{p 4 8 2}
Ireland, C. and Kullback, S. 1968, "Contingency tables with given marginals", Biometrika 55, 179--188.

{p 4 8 2}
Kullback, S. 1959, "Information Theory and Statistics", Wiley, NY.

{title:Authors}

      Jens Hainmueller, jhain@stanford.edu
      Stanford

      Yiqing Xu, xyq@mit.edu
      MIT
