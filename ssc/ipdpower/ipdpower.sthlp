{smcl}
{* 05Apr2014}{...}
{hline}
help for {hi:ipdpower}
{hline}
                                                                                                                                    
{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:ipdpower} {hline 2}} Simulation based power calculations for mixed effects modelling {p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 8 2}
{cmd:ipdpower}
{cmd:,} sn({it:#}) ssl({it:#}) ssh({it:#}) b0({it:#}) b1({it:#}) b2({it:#}) b3({it:#}) [{it:{help ipdpower##optional:optional}}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :required}
{synopt :{opt sn(#)}}Number of simulations to execute
{p_end}
{synopt :{opt ssl(#)}}Total number of patiens across all higher level units
{p_end}
{synopt :{opt ssh(#)}}Number of higher level units (e.g. studies, general practices etc)
{p_end}
{synopt :{opt b0(#)}}Coefficient for intercept
{p_end}
{synopt :{opt b1(#)}}Coefficient for exposure (intervention)
{p_end}
{synopt :{opt b2(#)}}Coefficient for covariate
{p_end}
{synopt :{opt b3(#)}}Coefficient for exposure-covariate interaction
{p_end}
{synoptline}
{syntab :data structure}
{synopt :{opt minsh(#)}}Minimum mumber of patients in a higher level unit (default is 50)
{p_end}
{synopt :{opt hpoisson}}Higher unit sizes drawn from a Poisson distribution
{p_end}
{synopt :{opt icluster}}Clustered exposure group (e.g. cluster-RCT)
{p_end}
{synopt :{opt outc(string)}}Type of outcome: continuous("cont"- default); dichotomous ("binr"); count ("count")
{p_end}
{synopt :{opt cb(#)}}Probability for the exposure group, for unbalanced designs (default is 0.5)
{p_end}
{synopt :{opt cexp}}Continuous exposure instead of binary, the default
{p_end}
{synopt :{opt cexpd(string)}}Distribution for continuous exposure: normal ("norm"-default); moderate skew ("sknorm"); extreme skew ("xsknorm")
{p_end}
{synopt :{opt errsd(#)}}For continuous outcome, residual error standard deviation (default is 1)
{p_end}
{synopt :{opt sderrsd(#)}}For continuous outcome, standard deviation across higher levels for residual error SD (default is 0)
{p_end}
{synopt :{opt derr(string)}}For continuous outcome, distribution for errors and hence outcome: normal ("norm"-default); moderate skew ("sknorm"); extreme skew ("xsknorm")
{p_end}
{synopt :{opt ccovd(string)}}Distribution for continuous covariate: normal ("norm"-default); moderate skew ("sknorm"); extreme skew ("xsknorm")
{p_end}
{synopt :{opt bcov}}Binary covariate instead of continuous, the default
{p_end}
{synopt :{opt bcb(#)}}Probability for the binary covariate (default is 0.5)
{p_end}
{synopt :{opt bsd(#)}}SD for varying probability for the binary covariate across higher level units (default is 0)
{p_end}
{synopt :{opt slcov}}Higher-level covariate, instead of patient-level (the default)
{p_end}
{synoptline}
{syntab :random effects}
{synopt :{opt tsq0(#)}}Random effect between variance for the intercept (default is 0)
{p_end}
{synopt :{opt tsq1(#)}}Random effect between variance for the exposure (default is 0)
{p_end}
{synopt :{opt tsq2(#)}}Random effect between variance for the covariate (default is 0)
{p_end}
{synopt :{opt tsq3(#)}}Random effect between variance for the exposure-covariate interaction (default is 0)
{p_end}
{synopt :{opt dtp0(string)}}Distribution for intercept random effect: normal ("norm"-default); moderate skew ("sknorm"); extreme skew ("xsknorm")
{p_end}
{synopt :{opt dtp1(string)}}Distribution for exposure random effect: normal ("norm"-default); moderate skew ("sknorm"); extreme skew ("xsknorm")
{p_end}
{synopt :{opt dtp2(string)}}Distribution for covariate random effect: normal ("norm"-default); moderate skew ("sknorm"); extreme skew ("xsknorm")
{p_end}
{synopt :{opt dtp3(string)}}Distribution for interaction random effect: normal ("norm"-default); moderate skew ("sknorm"); extreme skew ("xsknorm")
{p_end}
{synopt :{opt covmat(name)}}Covariance matrix for normally distributed random-effects (alternative definition)
{p_end}
{synoptline}
{syntab :missing data}
{synopt :{opt missp(#)}}Percentage of missing data
{p_end}
{synopt :{opt mar(#)}}Missing at random (MAR) assumption, Odds ratio for 'missingness'
{p_end}
{synopt :{opt mnar(#)}}Missing not at random (MNAR) assumption, Odds ratio for 'missingness'
{p_end}
{synopt :{opt minum(#)}}Number of multiple imputations
{p_end}
{synopt :{opt mipmm(#)}}For continuous outcome, impute using pmm instead of regress (# defines neighbours)
{p_end}
{synoptline}
{syntab :modelling}
{synopt :{opt model(#)}}Model choice for analysis: 1 simple, 2 random effects for intercept, 3-7 various mixed effects options
{p_end}
{synopt :{opt clvl(#)}}Set confidence level
{p_end}
{synopt :{opt seed(#)}}Set seed number
{p_end}
{synopt :{opt nskip}}Add 'noskip' option to xtlogit or xtpoisson to return pseudo R^2
{p_end}
{synopt :{opt dnorm}}Add 'normal' option to xtpoisson to assume normally distributed random effect
{p_end}
{synopt :{opt xnodts}}Do not display simulation dots
{p_end}
{synopt :{opt nodi:splay}}Do not display results
{p_end}
{synopt :{opt moreon}}Set more on (default is off)
{p_end}

{title:Description}

{p 4 4 2}
{cmd:ipdpower} is a simulations-based command that calculates power for complex mixed effects two-level data structures. The command was developed having
individual patient data meta-analyses in mind, where patients are nested within studies, but the methods apply to any two-level structure (say patients within
general practices in a primary care database). The command proceeds in two steps. First, it generates the outcome data according to the specified coefficients
for the intercept, the exposure (intervention), the covariate and the exposure-covariate interaction and the outcome can be continuous, binary or count data (selected
using {opt outc(string)}). Second, it uses regression modelling (selected using {opt model(#)}) to return average model fit statistics, power and coverage calculations.
Power indicates the percentage of iterations in which a model coefficient was found to be statistically significant and of the same direction as the hypothesised.
Coverage indicates the percentage of confidence intervals that include the true coefficient and should correspond to the hypothesised alpha level. Binomial confidence
intervals using the {cmd:cii} command are calculated for both power and coverage.
Inputs {opt b0(#)}, {opt b1(#)}, {opt b2(#)} and {opt b3(#)} always refer to coefficients (i.e. log odds ratios or log incidence rate ratios for binary and count outcomes respectively)
and the simulations always assume standardised exposure and covariate, when continuous. To help users define the correct coefficient values for hypothesised statistics,
we have provided a supplementary file in MS Excel available {browse "http://www.statanalysis.co.uk/files/defining_betas.xlsx":here}. The command also returns aggregated simulation
statistics, allowing users to double-check the hypothesised coefficients and adjust if necessary.
{cmd:ipdpower} is flexible and the higher-level inputs can be ignored, for a simple power calculation of a sigle higher-level unit. In addition, if a parameter is
not needed (say the covariate or the interaction) the user can just set the respective coefficient to zero.

{title:Required}

{phang}
{opt sn(#)} Number ({it:integer}) of simulations to execute. At least 1000 are recommended for relatively narrow confidence intervals.

{phang}
{opt ssl(#)} Total number ({it:integer}) of patients across all higher level units (clusters).

{phang}
{opt ssh(#)} Number ({it:integer}) of higher level units (e.g. studies, general practices etc).

{phang}
{opt b0(#)} Coefficient ({it:real}) for the intercept (constant) of regression model. For logistic and Poisson regression log odds and log incidence-rate ratios are
expected respectively. The coefficient can be zero.

{phang}
{opt b1(#)} Coefficient ({it:real}) for the exposure variable (e.g. intervention: treatment vs no treatment) of the regression model. For logistic and Poisson
regression log odds and log incidence-rate ratios are expected respectively. The coefficient can be zero.

{phang}
{opt b2(#)} Coefficient ({it:real}) for the covariate variable (e.g. age) of the regression model. It can be continuous (default) or binary ({opt bcov} option),
and patient-level (default) or study-level ({opt slcov} option). For logistic and Poisson regression log odds and log incidence-rate ratios are expected respectively.
The coefficient can be zero. Note that the covariate, when continuous, is always assumed to be standardised (mean=0 and sd=1) since interactions are included in the models.
Users need to take that into consideration when deciding on b2.

{phang}
{opt b3(#)} Coefficient ({it:real}) for the exposure*covariate interaction variable. The command can automatically handle a binary by continuous or binary by binary
interaction term. For logistic and Poisson regression log odds and log incidence-rate ratios are expected respectively. The coefficient can be zero. Note that the covariate, when continuous, is always assumed to be standardised (mean=0 and sd=1) to allow for meaningful estimates. Users need to
take that into consideration when deciding on b3.

{marker optional}{...}
{title:Optional}

{dlgtab:Data structure}

{phang}
{opt minsh(#)} Minimum mumber ({it:integer}) of patients in a higher level unit. The default is 50 since this is usually the threshold above which the effort required to
obtain individual patient data for meta-analysis is justified. The command uses the numbers provided with {opt ssl(#)}, {opt ssh(#)} and {opt minsh(#)} to draw sizes
for the higher level units from a uniform distribution. If the average size for the higher level unit is smaller than the minimum number of patients the command will
return an error.

{phang}
{opt hpoisson} Inform the command that the higher level unit sizes will not be drawn from a uniform but a Poisson distribution with mean={opt ssl(#)}/{opt ssh(#)}. This approach provides cluster
sizes that are much more similar in size. Cannot be used with option {opt minsh(#)}.

{phang}
{opt icluster} Inform the command that the exposure is clustered at the higher level units (e.g. cluster-RCT). Can only be selected when exposure is binary and with balanced designs (i.e. cannot be
used with {opt cexp} or {opt cb(#)}). Clusters assigned an odd identifier are assumed to include controls and clusters assigned even identifiers are assumed to include the intervention cases (i.e. if an odd
number of higher level units is simulated with {opt icluster} there will be an additional cluster of controls).

{phang}
{opt outc(string)} Type of outcome: continuous ("cont"-default); dichotomous ("binr"); count ("count"). The model for a continuous outcome is y=b0+b1*grp+b2*xcovar+b3*xcovar*grp+u0+u1*grp+u2*xcovar+u3*xcovar*grp+errx,
where {it:grp} the exposure variable, {it:xcovar} the covariate, {it:xcovar*grp} their interaction, {it:u0-u3} the random effects components and {it:errx} the residual errors.
For a binary outcome the model is y={help uniform()}<invlogit(b0+b1*grp+b2*xcovar+b3*xcovar*grp+u0+u1*grp+u2*xcovar+u3*xcovar*grp) and for a count outcome it is
y=rpoisson(exp(b0+b1*grp+b2*xcovar+b3*xcovar*grp+u0+u1*grp+u2*xcovar+u3*xcovar*grp)). Negative binomial models were considered as an alternative for count data but they were thought to be too complex
to be of much practical use in the assumption-laden context of power calculations. Note that residual errors can only be directly controlled in the OLS regression model.

{phang}
{opt cb(#)} Probability ({it:real}) for patient membership to the exposure group (grp=1). The default is 0.5 for a balanced design.

{phang}
{opt cexp} Inform the command that exposure is continuous (standardised, i.e. mean=0 and sd=1) rather than binary (the default).

{phang}
{opt cexpd(string)} Distribution for continuous exposure: normal ("norm"-default); moderate skew ("sknorm"); extreme skew ("xsknorm"). Normal distribution for the exposure (skew=0, kurtotis=3), when continuous, is the default.
Moderate (skew=1, kurtotis=4) and extreme skewness (skew=2, kurtotis=9) are implemented using the Ramberg et al. (1979) method. The distribution for the exposure will not affect the distribution of the outcome much
unless b1 is reasonably large. Note that the exposure, when continuous, is always assumed to be standardised (mean=0 and sd=1) since interactions are included in the models. Users need to take that into
consideration when deciding on b2 and b3.

{phang}
{opt errsd(#)} For continuous outcome only, standard deviation for the residual error ({it:real}). The default is 1. This value, combined with the model coefficients, will affect the model fit; e.g.
a large value will drive down the average adjusted R^2. It also affects model heterogeneity since this is effectively the sd for the outcome within the higher level unit (e.g. within-study variability).

{phang}
{opt sderrsd(#)} For continuous outcome only, standard deviation for the standard deviation of the residual error ({it:real}). In other words, it allows the residual error to vary across higher-level units,
which might be a more realistic modelling strategy. The default is 0, not allowing variation which complies with modelling and heterogeneity assumptions (e.g. pooled within-variance is used for heterogeneity calculations).

{phang}
{opt derr(string)} For continuous outcome only, distribution for errors and hence outcome: normal ("norm"-default); moderate skew ("sknorm");extreme skew ("xsknorm"). Normal distribution for the error (skew=0, kurtotis=3)
is the default. Moderate (skew=1, kurtotis=4) and extreme skewness (skew=2, kurtotis=9) are implemented using the Ramberg et al. (1979) method. The distribution for the errors will affect the distribution of the outcome and
the larger the modelled errors the more similar the two distributions.

{phang}
{opt ccovd(string)} Distribution for continuous covariate: normal ("norm"-default); moderate skew ("sknorm"); extreme skew ("xsknorm"). Normal distribution for the covariate (skew=0, kurtotis=3) is the default.
Moderate (skew=1, kurtotis=4) and extreme skewness (skew=2, kurtotis=9) are implemented using the Ramberg et al. (1979) method. The distribution for the covariate will not affect the distribution of the outcome much
unless b2 is reasonably large. Note that the covariate, when continuous, is always assumed to be standardised (mean=0 and sd=1) since interactions are included in the models. Users need to take that into
consideration when deciding on b2 and b3.

{phang}
{opt bcov} Inform the command that the covariate is binary instead of continuous (the default).

{phang}
{opt bcb(#)} For binary covariate only, probability ({it:real}) that xcovar=1. The default is 0.5.

{phang}
{opt bsd(#)} For binary covariate only, standard deviation of the probability ({it:real}) that xcovar=1 across higher level units (default is 0). Allows for higher level units with very different
composition in terms of the binary covariate (e.g. studies that only enrolled men or women).

{phang}
{opt slcov} Inform the command that the covariate is higher-level (e.g. study-level: recruitment setting) rather than patient-level(the default).

{dlgtab:Random effects}

{phang}
{opt tsq0(#)} Random effect between higher level variance for the intercept. The default value is 0, which assumes homogeneity and no random effects. Heterogeneity for this model factor (intercept) would
be calculated using tsq0 and errsd. For example I^2=100*tausq0/(tausq0+errsd^2) and H^2=1/(1-tausq0/(tausq0+errsd^2)). Solving for tausq0 we obtain tausq0=(I^2/100*errsd^2)/(100-I^2/100) and tausq0=H^2*errsd^2-errsd^2.
Although {cmd:ipdpower} does not allow I^2 or H^2 inputs for the random effects components, they can be easily calculated using these formulas. Additionally users can use the obtained
hypothesised heterogeneity levels for the inputted within- and between- variance parameters (say in a small trial simulation, if unsure of calculations).

{phang}
{opt tsq1(#)} Random effect between higher level variance for the exposure. The default value is 0, which assumes homogeneity and no random effects. Heterogeneity for this model factor (exposure) would
be calculated using tsq1 and errsd. See {opt tsq0(#)} for calculation details.

{phang}
{opt tsq2(#)} Random effect between higher level variance for the covariate. The default value is 0, which assumes homogeneity and no random effects. Heterogeneity for this model factor (covariate) would
be calculated using tsq2 and errsd. See {opt tsq0(#)} for calculation details.

{phang}
{opt tsq3(#)} Random effect between higher level variance for the exposure*covariate interaction term. The default value is 0, which assumes homogeneity and no random effects. Heterogeneity for this model
factor (interaction) would be calculated using tsq3 and errsd. See {opt tsq0(#)} for calculation details.

{phang}
{opt dtp0(string)} Distribution for intercept random effect: normal ("norm"); moderate skew ("sknorm"); extreme skew ("xsknorm"). Normal distribution (skew=0, kurtotis=3) is the default. Moderate (skew=1, kurtotis=4)
and extreme skewness (skew=2, kurtotis=9) are implemented using the Ramberg et al. (1979) method. In the standard two-stage meta-analysis setting, a non-normal distribution for the random effects has been found
to have a small effect on power and coverage - even when the distribution is quite extreme (Kontopantelis and Reeves, 2010).

{phang}
{opt dtp1(string)} Distribution for exposure random effect: normal ("norm"-default, skew=0 kurtosis=3); moderate skew ("sknorm", skew=1 kurtosis=4); extreme skew ("xsknorm", skew=2 kurtosis=9).

{phang}
{opt dtp2(string)} Distribution for covariate random effect: normal ("norm"-default, skew=0 kurtosis=3); moderate skew ("sknorm", skew=1 kurtosis=4); extreme skew ("xsknorm", skew=2 kurtosis=9).

{phang}
{opt dtp3(string)} Distribution for exposure*covariate interaction random effect: normal ("norm"-default, skew=0 kurtosis=3); moderate skew ("sknorm", skew=1 kurtosis=4); extreme skew ("xsknorm", skew=2 kurtosis=9).

{phang}
{opth covmat(name)} Covariance matrix for normally distributed random effects. Alternative random effects definition to allow modelling of relationships between the random effects components.
The matrix needs to be a 4x4 symmetrical non-negative matrix, with the diagonal elements corresponding to the random effects variances for intercept ({it:name}[1,1]), exposure (({it:name}[2,2]),
covariate (({it:name}[3,3]) and interaction (({it:name}[4,4]). Non-normal random effects cannot be modelled using this approach.

{dlgtab:Missing data}

{phang}
{opt missp(#)} Probability ({it:real}) that outcome is missing, to allow for missing data mechanisms. If option {opt mar(#)} is defined, data is assumed to be missing
under a missing at random (MAR) mechanism. If option {opt mnar(#)} is defined, data is assumed to be missing under a missing not at random (MNAR) mechanism. If neither
{opt mar(#)} or {opt mnar(#)} are provided along with {opt missp(#)}, data is assumed to be missing under a missing completely at random (MCAR) mechanism.
Please note that multiple imputation models can satisfactorily deal with MCAR and MAR mechanisms and not MNAR mechanisms, although they will improve power in all three scenarios.
In terms of minimising estimate bias, multiple imputations are not really needed for MCAR data (a complete case analysis should provide similar estimates) and are mainly needed for MAR data.
There is some evidence that multiple imputation can offer some protection against MNAR mechanisms, but in general the estimates from such models will be biased. However, it is impossible
to assess whether data are MNAR, without obtaining additional external data, and the multiple imputation models are now used routinely to deal whenever 'missingness' is encountered.
Therefore, we decided to offer a MNAR modelling option with the underperforming, in this scenario, multiple imputation approach to allow inquisitive researchers to practically calculate
the performance of these models, in terms of power.

{phang}
{opt mar(#)} Odds ratio ({it:real}) that defines a missing at random (MAR) mechanism. The relationship between the covariate and missingness in the outcome is
defined by z=ln({opt mar(#)})*xcovar (i.e a logistic regression model), and the missing data are selected (i.e. set to missing) from the z=1 subsample. So a value of 1 implies the
mechanism is MCAR, a value above 1 implies that the outcome is more likely to be missing for larger values of the covariate and a value below 1 implies that the
outcome is more likely to be missing for smaller values of the covariate.

{phang}
{opt mnar(#)} Odds ratio ({it:real}) that defines a missing not at random (MNAR) mechanism. The relationship between the outcome and missingness in the outcome is
defined by z=ln({opt mnar(#)})*y (i.e a logistic regression model), and the missing data are selected (i.e. set to missing) from the z=1 subsample. So a value of 1 implies the
mechanism is MCAR, a value above 1 implies that the outcome is more likely to be missing for larger values of the outcome and a value below 1 implies that the
outcome is more likely to be missing for smaller values of the outcome.

{phang}
{opt minum(#)} Number ({it:integer}>1) of multiple imputations to be executed. This options informs {cmd:ipdpower} that multiple-imputation models will be used and therefore missing data with one
of the three available structures (MCAR, MAR, MNAR) need to have been defined. For the imputations, univariate linear, logistic or Poisson regression is used depending on the outcome (see {help mi impute}).
Under all imputation models, the outcome depends on exposure, covariate and their interaction, and for multi-level models (2-7) additionally on higher level units (clusters - see strategy #1
{browse "http://www.stata.com/support/faqs/statistics/clustering-and-mi-impute/":here}). The imputed
datasets are then analysed using {help mi estimate} as a prefix, for the seven available models. Note that this process can be time consuming for complex models and binary or count outcomes, while convergence issues
are amplified since all imputed datasets must run successfully for {mi estimate} to return results. Therefore 5 imputations are recommended for most models, and 2-3 for non-continuous outcomes and
models 5, 6 or 7 (see option {opt model(#)}).

{phang}
{opt mipmm(#)} For a continuous outcome, it informs that missing data will be imputed using a predictive mean matching algorithm (rather than linear regression). The algorithm is computationally more expensive and
# defines the number ({it:integer}>=1) of closest observations (nearest neighbors) to draw from.

{dlgtab:Modelling}

{phang}
{opt model(#)} Model choice for analysis: 1 simple, 2 random effects for intercept, 3-7 various mixed effects options. Model 1 corresponds to a regression with {help regress}, {help logit} or {help poisson},
for continuous, binary and count outcomes respectively. Random effects are not considered at all under these models. Model 2 uses the {help xt} family of models, sets the higher level as a panel variable with
{help xtset} and analyses with {help xtreg}, {help xtlogit} or {help xtpoisson}.Only a random effects component for the intercept is considered under with this set of models.
Models 3-7 allow for more advanced modelling options, accounting for various random effect components, but are computationally expensive and do not always converge (using {help xtmixed}, {help xtmelogit} and
{help xtmepoisson} which have been renamed in Stata v13 - but we wished to ensure {cmd:ipdpower} was compatible with v12). The modelling approaches have been described for {help ipdforest} (Kontopantelis and Reeves, 2013)
and in the following descriptions we assume the highel level is study (i.e. patients nested within studies), for convenience. Model 3 assumes a fixed common intercept, random treatment effects and fixed effect for the
covariate. Model 4 assumes fixed study specific intercepts, random treatment effects and fixed study specific effects for the covariate (which is usually the recommended model for performing individual patient data
meta-analysis). Model 5 assumes random study intercepts, random treatment effects and fixed study specific effects for the covariate. Model 6 assumes random study intercepts, random treatment effects and random effects
for the covariate. Model 7 assumes random study intercept, random treatment effects, random effects for the covariate and random effects for the interaction. Models 5 and 6 often fail to converge and for model 7 non-convergence
is more frequent than convergence.

        {hline 10}{c TT}{hline 90}
           {it:model}  {c |}   {it:commands}                         {it:intercept}     {it:exposure}     {it:covariate}     {it:interaction}
        {hline 10}{c +}{hline 90}
             1    {c |}   {help regress}/{help logit}/{help poisson}            fixed         fixed        fixed         fixed
             2    {c |}   {help xtreg}/{help xtlogit}/{help xtpoisson}          random        fixed        fixed         fixed
             3    {c |}   {help xtmixed}/{help xtmelogit}/{help xtmepoisson}    fixed         random       fixed         fixed
             4    {c |}   {help xtmixed}/{help xtmelogit}/{help xtmepoisson}    fixed*        random       fixed*        fixed
             5    {c |}   {help xtmixed}/{help xtmelogit}/{help xtmepoisson}    random        random       fixed*        fixed
             6    {c |}   {help xtmixed}/{help xtmelogit}/{help xtmepoisson}    random        random       random        fixed
             7    {c |}   {help xtmixed}/{help xtmelogit}/{help xtmepoisson}    random        random       random        random
        {hline 10}{c BT}{hline 90}
        *cluster-specific fixed-effects, i.e. a different estimate for each higher level unit rather than an overall fixed effect

{phang}
{opt clvl(#)} Set confidence level. The default is 95% (alpha level of 5%). See {help level}.

{phang}
{opt seed(#)} Set initial value of random-number seed, for the simulations. See {help set seed}.

{phang}
{opt nskip} Add {opt noskip} option to xtlogit or xtpoisson to return pseudo R^2. This option is only relevant when {opt model(2)} with {opt outc(binr)} or {opt outc(count)} is used. Computationally, this approach is more expensive
since it additionally fits a full maximum-likelihood model with only a constant for the regression equation be fit (which is used as the base model for the comparison with the final model).

{phang}
{opt dnorm} Add {opt normal} option to xtpoisson to assume normally distributed random effects for the intercept. The default is gamma-distributed which is computationally less expensive. Additionally, when the
{opt normal} option is specified, model convergence often fails. This option is only relevant when {opt model(2)} with {opt outc(count)}. A skew-normal distribution is similar to gamma and perhaps skew-normal random
effects should be considered when modelling count data.

{phang}
{opt xnodts} Suppress simulation progress display. If option not specified, a '.' is displayed for each successful model run (i.e. converging) and an 'x' for each unsuccessful iteration.

{phang}
{opt nodi:splay} Do not display results at the end of the simulation process. Suppressed results include: simulation characteristics, average model fit, average statistics for the outcome,
average b0-b3, hypothesised heterogeneity values, power and coverage.

{phang}
{opt moreon} Set {help more} on (default is off).


{title:Remarks}

{p 4 4 2}
A description of methods and details in the use of {cmd:ipdpower}, as well as more examples, have been provided in a Journal paper: {browse "https://www.jstatsoft.org/article/view/v074i12":https://www.jstatsoft.org/article/view/v074i12}

{p 4 4 2}
Effectively breaking the command can be difficult. The Stata break button is likely to terminate a regression iteration which will be marked as non-coverging (reported as an 'x') but not {cmd:ipdpower}. To exit the command,
Windows users should keep {it:Ctrl+Pause/Break} pressed for a few seconds. Users of other systems please see {browse "http://www.stata.com/manuals13/u9.pdf":here}.

{title:Examples}

{p 4 4 2}
100 simulations, total sample size 5000, from 20 studies with no heterogeneity modelled and using defaults: continuous normally distributed outcome, balanced exposure, continuous patient-level covariate.

{phang2}{cmd:. ipdpower, sn(100) ssl(5000) ssh(20) b0(1) b1(0.5) b2(0.3) b3(0.1)}{p_end}

{p 4 4 2}
Adding heterogeneity for the exposure (I^2=33.3%, H^2=1.5).

{phang2}{cmd:. ipdpower, sn(100) ssl(5000) ssh(20) b0(1) b1(0.5) b2(0.3) b3(0.1) tsq1(0.5)}{p_end}

{p 4 4 2}
Binary outcome modelled with {help logit}.

{phang2}{cmd:. ipdpower, sn(100) ssl(5000) ssh(20) b0(1) b1(0.5) b2(0.3) b3(0.1) tsq1(0.5) outc(binr)}{p_end}

{p 4 4 2}
Binary outcome modelled with {help xtlogit} (which assumes heterogeneity for the intercept, not the exposure).

{phang2}{cmd:. ipdpower, sn(100) ssl(5000) ssh(20) b0(1) b1(0.5) b2(0.3) b3(0.1) tsq1(0.5) outc(binr) model(2)}{p_end}

{p 4 4 2}
Continuous non-normally distributed outcome modelled with {help xtreg} (which assumes heterogeneity for the intercept, not the exposure) and higher residual error.

{phang2}{cmd:. ipdpower, sn(100) ssl(5000) ssh(20) b0(1) b1(0.5) b2(0.3) b3(0.1) tsq1(0.5) errsd(2) derr(sknorm) model(2)}{p_end}

{p 4 4 2}
As above but with a binary covariate and assuming heterogeneity for the intercept instead.

{phang2}{cmd:. ipdpower, sn(100) ssl(5000) ssh(20) b0(1) b1(0.5) b2(0.3) b3(0.1) tsq0(0.5) errsd(2) derr(sknorm) model(2) bcov bcb(0.8)}{p_end}

{p 4 4 2}
As above but with a study-level covariate instead.

{phang2}{cmd:. ipdpower, sn(100) ssl(5000) ssh(20) b0(1) b1(0.5) b2(0.3) b3(0.1) tsq0(0.5) errsd(2) derr(sknorm) model(2) bcov bcb(0.8) slcov}{p_end}


{title:Saved results}

{pstd}
{cmd:ipdpower} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(bo)}}Average coefficient estimate for the intercept{p_end}
{synopt:{cmd:r(b1)}}Average coefficient estimate for the exposure{p_end}
{synopt:{cmd:r(b2)}}Average coefficient estimate for the covariate{p_end}
{synopt:{cmd:r(b3)}}Average coefficient estimate for the interaction{p_end}
{synopt:{cmd:r(nsim)}}Number of simulations{p_end}
{synopt:{cmd:r(nrun)}}Number of successful simulations{p_end}
{synopt:{cmd:r(ctime)}}Computational time in minutes{p_end}
{synopt:{cmd:r(rsq)}}Adjusted or pseudo R^2{p_end}
{synopt:{cmd:r(errsd)}}within-sd (error){p_end}
{synopt:{cmd:r(consd)}}between-sd (intercept){p_end}
{synopt:{cmd:r(grpsd)}}between-sd (exposure){p_end}
{synopt:{cmd:r(covsd)}}between-sd (covariate){p_end}
{synopt:{cmd:r(intsd)}}between-sd (interaction){p_end}
{synopt:{cmd:r(pow0)}}Power to detect b0{p_end}
{synopt:{cmd:r(lpow0)}}Power to detect b0, lower CI{p_end}
{synopt:{cmd:r(upow0)}}Power to detect b0, upper CI{p_end}
{synopt:{cmd:r(pow1)}}Power to detect b1{p_end}
{synopt:{cmd:r(lpow1)}}Power to detect b1, lower CI{p_end}
{synopt:{cmd:r(upow1)}}Power to detect b1, upper CI{p_end}
{synopt:{cmd:r(pow2)}}Power to detect b2{p_end}
{synopt:{cmd:r(lpow2)}}Power to detect b2, lower CI{p_end}
{synopt:{cmd:r(upow2)}}Power to detect b2, upper CI{p_end}
{synopt:{cmd:r(pow3)}}Power to detect b3{p_end}
{synopt:{cmd:r(lpow3)}}Power to detect b3, lower CI{p_end}
{synopt:{cmd:r(upow3)}}Power to detect b3, upper CI{p_end}
{synopt:{cmd:r(cov0)}}Coverage for b0{p_end}
{synopt:{cmd:r(lcov0)}}Coverage for b0, lower CI{p_end}
{synopt:{cmd:r(ucov0)}}Coverage for b0, upper CI{p_end}
{synopt:{cmd:r(cov1)}}Coverage for b1{p_end}
{synopt:{cmd:r(lcov1)}}Coverage for b1, lower CI{p_end}
{synopt:{cmd:r(ucov1)}}Coverage for b1, upper CI{p_end}
{synopt:{cmd:r(cov2)}}Coverage for b2{p_end}
{synopt:{cmd:r(lcov2)}}Coverage for b2, lower CI{p_end}
{synopt:{cmd:r(ucov2)}}Coverage for b2, upper CI{p_end}
{synopt:{cmd:r(cov3)}}Coverage for b3{p_end}
{synopt:{cmd:r(lcov3)}}Coverage for b3, lower CI{p_end}
{synopt:{cmd:r(ucov3)}}Coverage for b3, upper CI{p_end}


{title:Author}

{p 4 4 2}
Evangelos Kontopantelis, Centre for Health Informatics, Institute of Population Health

{p 29 4 2}
University of Manchester, e.kontopantelis@manchester.ac.uk


{title:Please cite as}

{phang}
Kontopantelis E, Springate D, Parisi R and Reeves D. 2015.
{it:Simulation-based power calculations for mixed effects modelling: ipdpower in Stata}.
JSS, 2016, 74(12). Paper available {browse "https://www.jstatsoft.org/article/view/v074i12":here}.


{title:Other references}

{p 4 4 2}
Ramberg JS, Dudewicz EJ, Tadikamalla PR and Mykytka EF. A probability distribution and its uses in fitting data. Technometrics 1979; 21(2): 201–214.

{p 4 4 2}
Kontopantelis E and Reeves D. Performance of statistical methods for meta-analysis when true study effects are non-normally distributed: A simulation study.
Statistical Methods in Medical Research (first published online on December 9, 2010), 2012 Aug; 21(4): 409-426. doi: 10.1177/0962280210392008.

{p 4 4 2}
Kontopantelis E and Reeves D. A short guide and a forest plot command (ipdforest) for one-stage meta-analysis. The Stata Journal, 2013 Oct; 13(3): 574-587.

{title:Also see}

{p 4 4 2}
help for {help ipdforest}

