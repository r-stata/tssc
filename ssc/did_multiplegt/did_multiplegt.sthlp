{smcl}
{* *! version 1  2018-07-27}{...}
{viewerjumpto "Syntax" "did_multiplegt##syntax"}{...}
{viewerjumpto "Description" "did_multiplegt##description"}{...}
{viewerjumpto "Options" "did_multiplegt##options"}{...}
{viewerjumpto "Examples" "did_multiplegt##examples"}{...}
{viewerjumpto "Saved results" "did_multiplegt##saved_results"}{...}

{title:Title}

{p 4 8}{cmd:did_multiplegt} {hline 2} Estimation in sharp Difference-in-Difference designs with multiple groups and periods.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:did_multiplegt Y G T D} {ifin} 
[{cmd:,} 
{cmd:placebo(}{it:#}{cmd:)}
{cmd:dynamic(}{it:#}{cmd:)}
{cmd:controls(}{it:varlist}{cmd:)} 
{cmd:trends_nonparam(}{it:varlist}{cmd:)} 
{cmd:trends_lin(}{it:varlist}{cmd:)}
{cmd:weight(}{it:varlist}{cmd:)} 
{cmd:breps(}{it:#}{cmd:)} 
{cmd:cluster(}{it:varname}{cmd:)}
{cmd:covariances}
{cmd:average_effect(}{it:string}{cmd:)}
{cmd:{ul:recat}_treatment(}{it:varlist}{cmd:)}
{cmd:{ul:threshold}_stable_treatment(}{it:#}{cmd:)}
{cmd:save_results(}{it:path}{cmd:)}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:did_multiplegt} estimates the effect of a treatment on an outcome, in sharp DID designs with multiple groups and periods. It computes the DIDM estimator introduced in Section 4 of Chaisemartin and D'Haultfoeuille (2019), 
which generalizes the standard DID estimator with two groups, two periods and a binary treatment to situations with many groups, many periods and a potentially non-binary treatment. For each pair of consecutive time periods t-1 and t and for each value of the treatment d, the command computes a DID estimator comparing the outcome evolution among the switchers, the groups whose treatment changes from d to some other value between t-1 and t, to the same evolution among control groups whose treatment is equal to d both in t-1 and t. Then, the DIDM estimator is equal to the average of those DIDs across all pairs of consecutive time periods and across all values of the treatment. Under a parallel trends assumption, DIDM is an unbiased and consistent estimator of the average treatment effect among switchers, at the time period when they switch.
The command can also compute placebo estimators that can be used to test the parallel trends assumption.
Finally, in staggered adoption designs where each group's treatment is weakly increasing over time, it can compute estimators of switchers' dynamic treatment effects, one time period or more after they have started receiving the treatment.
{p_end}

{p 4 8}{cmd:Y} is the outcome variable.{p_end}

{p 4 8}{cmd:G} is the group variable.{p_end}

{p 4 8}{cmd:T} is the time period variable.{p_end}

{p 4 8}{cmd:D} is the treatment variable.

{marker options}{...}
{title:Options}

{p 4 8}{cmd:placebo(}{it:#}{cmd:)} gives the number of placebo estimators to be estimated. Placebo estimators compare switchers' and non switchers' outcome evolution before switchers' treatment changes. Under the parallel trends assumption underlying the DIDM estimator, the placebo estimators should not significantly differ from 0. The number of placebos requested can be at most equal to the number of time periods in the data minus 2.{p_end}

{p 4 8}{cmd:dynamic(}{it:#}{cmd:)} gives the number of dynamic treatment effects to be estimated. This option should only be used in staggered adoption designs, where each group's treatment is weakly increasing over time, and when treatment is binary. The estimators of dynamic effects are similar to the DIDM estimator, except that they make use of long differences of the outcome (e.g. from t-1 to t+1) rather than first differences. The number of dynamic effects requested can be at most equal to the number of time periods in the data minus 2.{p_end}

{p 4 8}{cmd:controls(}{it:varlist}{cmd:)} gives the names of all the control variables to be included in the estimation.{p_end}

{p 4 8}{cmd:trends_nonparam(}{it:varlist}{cmd:)}: when this option is specified, time fixed effects interacted with {it:varlist} are included in the estimation. {it:varlist} can only include one categorical variable. For instance, if one works with a county*year data set and one wants to allow for state-specific trends, then one should write {cmd:trends_nonparam(}state{cmd:)}, where state is the state identifier.{p_end}

{p 4 8}{cmd:trends_lin(}{it:varlist}{cmd:)}: when this option is specified, linear time trends interacted with {it:varlist} are included in the estimation. {it:varlist} can only include one categorical variable. For instance, if one works with a village*year data set and one wants to allow for village-specific linear trends, one should write {cmd:trends_lin(}village{cmd:)}, where village is the village identifier. The {cmd:trends_nonparam(}{it:varlist}{cmd:)} and {cmd:trends_lin(}{it:varlist}{cmd:)} options cannot be specified at the same time.{p_end}

{p 4 8}{cmd:weight(}{it:varlist}{cmd:)} gives the name of a variable to be used to weight the data. For instance, if one works with a district*year data set and one wants to weight the estimation by each district*year's population, one should write {cmd:weight(}population{cmd:)}, where population is the population in each district*year. The weight option can only be used when the data is aggregated at the group*time level. When one works with disaggregated data, e.g. with individual-level data while groups are counties, the estimation is automatically weighted by the number of units in each group*time cell.{p_end}

{p 4 8}{cmd:breps(}{it:#}{cmd:)} gives the number of bootstrap replications to be used in the computation of estimators' standard errors. If that option is not specified, the command does not compute estimators' standard errors.{p_end}

{p 4 8}{cmd:cluster(}{it:varname}{cmd:)} computes the standard errors of the estimators using a block bootstrap at the {it:varname} level. Only one clustering variable is allowed.{p_end}

{p 4 8}{cmd:covariances}: if this option and the {cmd:breps(}{it:#}{cmd:)} option are specified, the command computes the covariances between all the pairs of instantaneous and dynamic effects requested, and between all the pairs of placebos requested. This option can be useful to assess whether some average of the instantaneous and dynamic effects is statistically significant. For instance, assume that you estimate the instantaneous effect, effect_0, and one dynamic effect, effect_1. You would like to assess whether 2/3*effect_0+1/3*effect_1, a weighted average of those two effects, is statistically significant. You can specify the {cmd:covariances} option, use the fact that Var(2/3*effect_0+1/3*effect_1))=4/9V(effect_0)+1/9V(effect_1)+4/9cov(effect_0,effect_1) to compute the standard error of 2/3*effect_0+1/3*effect_1, and finally assess if this average effect is significant. This option can also be useful to run an F-test of whether the placebos are all equal to 0, when several placebos are requested.{p_end}

{p 4 8}{cmd:average_effect(}{it:string}{cmd:)}: if that option is specified, the command will compute an average of the instantaneous and dynamic effects requested. If {cmd:average_effect(}{it:simple}{cmd:)} is specified, the command will compute the simple average of the effects and its standard error. If {cmd:average_effect(}{it:prop_number_switchers}{cmd:)} is specified, the command will compute an average where each effect receives a weight proportional to the number of switchers the effect applies to. When {cmd:average_effect} is specified, the {cmd:covariances} option also has to be specified, and the number of dynamic effects requested should be greater than or equal to 1.{p_end}

{p 4 8}{cmd:recat_treatment(}{it:varlist}{cmd:)} pools some values of the treatment together when determining the groups whose outcome evolution are compared. This option may be useful when the treatment takes a large number of values, and some values are rare in the sample. For instance, assume that treatment D takes the values 0, 1, 2, 3, and 4, but few observations have a treatment equal to 2. Then, there may be a pair of consecutive time periods where one group goes from 2 to 3 units of treatment but no group has a treatment equal to 2 at both dates. To avoid loosing that observation, one can create a variable D_recat that takes the same value when D=1 or 2 (e.g.: D_recat=(D>=1)+(D>=3)+(D>=4)), and then specify the {cmd:recat_treatment(}D_recat{cmd:)} option. Then, the command can also use groups with a treatment equal to 1 at two consecutive dates as controls for groups going from 2 to 3 units of treatment, thus making it more likely that all switchers have a non empty set of controls.{p_end}

{p 4 8}{cmd:threshold_stable_treatment(}{it:#}{cmd:)}: this option may be useful when the treatment is continuous, or takes a large 
number of values. The DIDM estimator uses as controls groups whose treatment does not change between consecutive time periods. 
With a continuous treatment, there may not be any pair of consecutive time periods between which the treatment of at least one group 
remains perfectly stable. For instance, if the treatment is rainfall and one uses a county*year data set, there is probably not a 
single county*year whose rainfall is exactly the same as in the same county in the previous year. 
Then, one needs to specify the {cmd:threshold_stable_treatment(}{it:#}{cmd:)} option, with {it:#} a positive real number. 
For each pair of consecutive time periods, the command will use counties whose rainfall changed in absolute value by less than {it:#} as 
controls. {it:#} should be large enough so that there are counties whose rainfall levels change by less than {it:#} between two consecutive years, but it should be small enough so that a change in rainfall of {it:#} would be unlikely to affect the outcome.{p_end}

{p 4 8}{cmd:save_results(}{it:path}{cmd:)}: if this option and the {cmd:breps(}{it:#}{cmd:)} options are specified, the command saves the estimators requested, their standard error, their 95% confidence interval, and the number of observations used in the estimation in a separate data set, at the location specified in {it:path}.{p_end}

    {hline}

{marker saved_results}{...}
{title:Saved results}

{p 4 8}In what follows, let {it:k} denote the number specified in the {cmd:placebo(}{it:#}{cmd:)} option, and let {it:j} denote the number specified in the {cmd:dynamic(}{it:#}{cmd:)} option. {cmd:did_multiplegt} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{synopt:{cmd:e(effect_0)}} estimated effect of the treatment at the time period when switchers switch.{p_end}

{synopt:{cmd:e(N_effect_0)}} number of observations used in the estimation of {cmd:e(effect_0)}. This number is the number of first differences of the outcome and of the treatment used in the estimation.{p_end}

{synopt:{cmd:e(N_switchers_effect_0)}}: {cmd:e(effect_0)} is the average effect of the treatment across the switchers. {cmd:e(N_switchers_effect_0)} is the number of switchers this effect applies to.{p_end}

{synopt:{cmd:e(se_effect_0)}} estimated standard error of {cmd:e(effect_0)}, if the option {cmd:breps(}{it:#}{cmd:)} has been specified.{p_end}

{synopt:{cmd:e(placebo_i)}} estimated placebo effect i periods before switchers switch treatment, for all i in 0, 1, ..., k.{p_end}

{synopt:{cmd:e(N_placebo_i)}} number of observations used in the estimation of {cmd:e(placebo_i)}. This number is the number of first differences of the outcome and of the treatment used in the estimation.{p_end}

{synopt:{cmd:e(se_placebo_i)}} estimated standard error of {cmd:e(placebo_i)}, if the option {cmd:breps(}{it:#}{cmd:)} has been specified.{p_end}

{synopt:{cmd:e(effect_i)}} estimated effect of the treatment i periods after switchers have switched treatment, for all i in 1, ..., j.{p_end}

{synopt:{cmd:e(N_effect_i)}} number of observations used in the estimation of {cmd:e(effect_i)}. This number is the number of long differences of the outcome and of the treatment used in the estimation.{p_end}

{synopt:{cmd:e(N_switchers_effect_i)}}: {cmd:e(effect_i)} is the average effect of the treatment across the switchers, i periods after they have switched. {cmd:e(N_switchers_effect_i)} is the number of switchers this effect applies to.

{synopt:{cmd:e(se_effect_i)}} estimated standard error of {cmd:e(effect_i)}, if the option {cmd:breps(}{it:#}{cmd:)} has been specified.{p_end}

{synopt:{cmd:e(cov_effects_hi)}} estimated covariance between {cmd:e(effect_h)} and {cmd:e(effect_i)}, for all 0<=h<i<=j, if the options {cmd:covariances(}{it:#}{cmd:)} and {cmd:breps(}{it:#}{cmd:)} have been specified.{p_end}

{synopt:{cmd:e(cov_placebo_hi)}} estimated covariance between {cmd:e(placebo_h)} and {cmd:e(placebo_i)}, for all 1<=h<i<=j, if the options {cmd:covariances(}{it:#}{cmd:)} and {cmd:breps(}{it:#}{cmd:)} have been specified, and at least 2 placebos have been requested.{p_end}

{synopt:{cmd:e(effect_average)}} average of the instantaneous and dynamic effects requested by the user, if the {cmd:average_effect} option has been specified. 

{synopt:{cmd:e(N_effect_average)}} number of observations used in the estimation of {cmd:e(effect_average)}. This number is the number of first differences of the outcome and of the treatment used in the estimation.{p_end}

{synopt:{cmd:e(se_effect_average)}} estimated standard error of {cmd:e(effect_average)}.{p_end}


{marker Graph}{...}
{title:Graph}

{p2col 5 20 24 2: If the option breps has been specified, the command returns a graph with all the estimated treatment effects and placebos, and their 95% confidence intervals constructed using a normal approximation.}{p_end}

{marker Example}{...}
{title:Example: estimating the effect of union membership on wages, using the same panel of workers as in Vella and Verbeek (1998)}

{p 4 8}ssc install bcuse{p_end}
{p 4 8}bcuse wagepan{p_end}
{p 4 8}did_multiplegt lwage nr year union, placebo(1) breps(50) cluster(nr){p_end}
{p 4 8}ereturn list{p_end}  

{title:References}

{p 4 8}de Chaisemartin, C. and D'Haultfoeuille, X. Forthcoming, American Economic Review. 
{browse "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3148607":Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects}.{p_end}
{p 4 8}Vella, F. and Verbeek, M. 1998. Journal of Applied Econometrics 13(2), 163–183. 
{browse "https://onlinelibrary.wiley.com/doi/abs/10.1002/(SICI)1099-1255(199803/04)13:2%3C163::AID-JAE460%3E3.0.CO;2-Y":Whose wages do unions raise? a dynamic model of unionism and wage rate determination for young men}.{p_end}


{title:Authors}

{p 4 8}Clément de Chaisemartin, University of California at Santa Barbara, Santa Barbara, California, USA.
{browse "mailto:clementdechaisemartin@ucsb.edu":clementdechaisemartin@ucsb.edu}.{p_end}

{p 4 8}Xavier D'Haultfoeuille, CREST, Palaiseau, France.
{browse "mailto:xavier.dhaultfoeuille@ensae.fr":xavier.dhaultfoeuille@ensae.fr}.{p_end}

