{smcl}
{* 21may2012}{...}
{cmd:help for gformula}{right:Rhian Daniel}
{hline}


{title:G-computation formula routine for estimating causal effects in the presence of}
{title:time-varying confounding or mediation}


{title:Syntax}

{phang2}
{cmd:gformula}
{it:mainvarlist}
{ifin}
[{cmd:,} {it:time-varying_options mediation_options}]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :{cmd:gformula} {it:time-varying_options}}

{synopt :{opt out:come(varname)}}the outcome variable{p_end}
{synopt :{opt com:mands(string)}}the commands to be used for model-fitting for each variable to be simulated{p_end}
{synopt :{opt eq:uations(string)}}the RHS of the equations for model-fitting for each variable to be simulated{p_end}
{synopt :{opt i:dvar(varname)}}the subject id{p_end}
{synopt :{opt t:var(varname)}}the time variable{p_end}
{synopt :{opt var:yingcovariates(varlist)}}the time-varying covariates{p_end}
{synopt :{opt intvars(varlist)}}the intervention variables{p_end}
{synopt :{opt interventions(string)}}the interventions to be compared{p_end}
{synopt :{opt dynamic}}for comparing dynamic regimes{p_end}
{synopt :{opt eofu}}the outcome is measured at the end of follow-up (as opposed to survival){p_end}
{synopt :{opt pooled}}the model-fitting is to be done by pooling across time-points{p_end}
{synopt :{opt monotreat}}the time-varying treatment is binary, and changes at most once (from zero to one){p_end}
{synopt :{opt death(varname)}}the variable containing data on censoring due to death{p_end}
{synopt :{opt derived(varlist)}}the derived variables{p_end}
{synopt :{opt derrules(string)}}the rules for deriving the derived variables{p_end}
{synopt :{opt fix:edcovariates(varlist)}}the time-fixed covariates{p_end}
{synopt :{opt lag:gedvars(varlist)}}the lagged variables{p_end}
{synopt :{opt lagrules(string)}}the rules for deriving the lagged variables{p_end}
{synopt :{opt msm(string)}}the marginal structural model{p_end}
{synopt :{opt minsim}}suppresses some unnecessary simulation, reducing MC error{p_end}
{synopt :{opt impute(varlist)}}the variables with missing values to be imputed{p_end}
{synopt :{opt imp_cmd(string)}}the commands to be used for imputing each of the incomplete variables{p_end}
{synopt :{opt imp_eq(string)}}the RHS of the equations to be used for imputing each of the incomplete variables{p_end}
{synopt :{opt imp_cycles(#)}}the number of cycles to be used when imputing each of the incomplete variables using chained equations{p_end}
{synopt :{opt sim:ulations(#)}}the number of MC simulations{p_end}
{synopt :{opt sam:ples(#)}}the number of bootstrap samples{p_end}
{synopt :{opt seed(#)}}the random number seed{p_end}
{synopt :{opt all}}all bootstrap CIs are to be calculated{p_end}
{synopt :{opt graph}}a Kaplan-Meier curve is to be plotted{p_end}
{synopt :{opt saving(string)}}the filename under which the MC simulated data are to be stored{p_end}
{synopt :{opt replace}}replace the file of the same name if it exists{p_end}

{syntab :{cmd:gformula} {it:mediation_options}}

{synopt :{opt mediation}}the analysis is a mediation analysis (as opposed to time-varying confounding){p_end}
{synopt :{opt out:come(varname)}}the outcome variable{p_end}
{synopt :{opt com:mands(string)}}the commands to be used for model-fitting for each variable to be simulated{p_end}
{synopt :{opt eq:uations(string)}}the RHS of the equations for model-fitting for each variable to be simulated{p_end}
{synopt :{opt derived(varlist)}}the derived variables{p_end}
{synopt :{opt derrules(string)}}the rules for deriving the derived variables{p_end}
{synopt :{opt msm(string)}}the marginal structural model{p_end}
{synopt :{opt ex:posure(varlist)}}the exposure(s){p_end}
{synopt :{opt mediator(varlist)}}the mediator(s){p_end}
{synopt :{opt control(string)}}the value(s) of the mediator(s) at which the CDE is to be estimated{p_end}
{synopt :{opt baseline(string)}}the baseline value(s) of the exposure(s){p_end}
{synopt :{opt obe}}there is only one binary exposure{p_end}
{synopt :{opt oce}}there is only one categorical exposure{p_end}
{synopt :{opt base_confs(varlist)}}the confounders that are not affected by the exposure(s){p_end}
{synopt :{opt post_confs(varlist)}}the confounders that are affected by the exposure(s){p_end}
{synopt :{opt linexp}}specifies that the exposure is continuous and its effect assumed to be linear{p_end}
{synopt :{opt minsim}}suppresses some unnecessary simulation, reducing MC error{p_end}
{synopt :{opt moreMC}}specifies that the number of MC simulations will be greater than the sample size{p_end}
{synopt :{opt impute(varlist)}}the variables with missing values to be imputed{p_end}
{synopt :{opt imp_cmd(string)}}the commands to be used for imputing each of the incomplete variables{p_end}
{synopt :{opt imp_eq(string)}}the RHS of the equations to be used for imputing each of the incomplete variables{p_end}
{synopt :{opt imp_cycles(#)}}the number of cycles to be used when imputing each of the incomplete variables using chained equations{p_end}
{synopt :{opt sim:ulations(#)}}the number of MC simulations{p_end}
{synopt :{opt sam:ples(#)}}the number of bootstrap samples{p_end}
{synopt :{opt seed(#)}}the random number seed{p_end}
{synopt :{opt all}}all bootstrap CIs are to be calculated{p_end}
{synopt :{opt saving(string)}}the filename under which the MC simulated data are to be stored{p_end}
{synopt :{opt replace}}replace the file of the same name if it exists{p_end}

{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:gformula} is an implementation of the g-computation procedure, used to estimate the causal effect of time-varying exposure(s)
(A) on an outcome (Y) in the presence of time-varying confounders (L) that are themselves also affected by the exposure(s). The procedure can
also be used to address the related problem of estimating controlled direct effects and natural direct/indirect effects when the
causal effect of the exposure(s) on an outcome is mediated by intermediate variables, and in particular when confounders of the
mediator-outcome relationships are themselves affected by the exposure(s).

{dlgtab:Time-varying confounding}

{pstd}
The g-computation procedure for time-varying confounding works by first modelling the relationships between the variables seen in
the observational data. Using these models, it simulates what would have happened to the subjects in the study had the time-varying
exposures been determined by intervention, rather than been allowed to evolve naturally as in the observational data. The modelling
and simulation is carried out forward in time. That is, it starts by modelling the time 1 data given the time 0 data, which allows
the time 1 data to be simulated under various hypothetical interventions (on the time 0 exposure) to be compared. Then it models the
time 2 data given the time 0 and time 1 data in order to simulate the data at time 2 under the various interventions (on time 0 and
time 1 exposures), and so on. All post-baseline confounders and outcome(s) are simulated under each intervention. 

{pstd}
Causal inference can then be done by comparing the outcome(s) under different interventions as if these had been generated from a
randomised experiment. This can either be done by comparing the simulated outcomes directly, or via a specified marginal structural model.

{dlgtab:Mediation}

{pstd}
A substantively different, yet methodologically highly related, problem arises when we wish to decompose the causal effect of an exposure
X on an outcome Y into an indirect effect, acting through a mediator M, and a direct effect not mediated by M. Standard methods cannot be used
if there are confounders L of the M-Y relationship that are themselves affected by X.

{pstd}
To discuss precisely what we mean by direct and indirect effects, we use some counterfactual notation. Let Y(x,m) be the potential outcome if,
possibly contrary to fact, X were set (by intervention) to x and M were set (by intervention) to m. The {it:controlled direct effect}
(CDE(m)) is a comparison of E{Y(x,m)} for different values of x, whilst keeping m fixed. For example, if X is univariate and binary,
we might specifically consider the controlled direct effect (at m) to be

{phang2}
CDE(m)=E[Y(1,m)]-E[Y(0,m)]

{pstd}
Now let M(x) be the potential value of the mediator if, possibly contrary to fact, X were set to x.

{pstd}
The {it:total causal effect} (TCE) is a comparison of E(Y[x,M(x)]) for different values of x. Again, for binary X, we would have

{phang2}
TCE=E(Y[1,M(1)])-E(Y[0,M(0)])

{pstd}
It would be desirable to use these quantities to infer an indirect effect as the difference between the total effect and the direct effect.
The fact that the controlled direct effect is a function of m makes this impossible.

{pstd}
For this reason, the {it:natural direct effect} (NDE(x0)) is defined to be a comparison of E(Y[x,M(x0)]) for different values of x,
keeping x0 fixed (usually at the baseline value of X, if such a natural choice exists). In other words, it is the effect of X on Y,
were M to take on its natural value under the baseline intervention. For binary X, we would have

{phang2}
NDE(0)=E(Y[1,M(0)])-E(Y[0,M(0)])

{pstd}
Then the {it:natural indirect effect} (NIE(x1)) can be defined as the difference between the total causal effect and the natural direct effect.
Then it is a comparison of E(Y[x1,M(x)]) for different values of x, whilst keeping x1 fixed (at a natural choice of non-baseline value).
This is best illustrated by thinking again of a binary X, when the natural indirect effect becomes

{phang2}
NIE(1)=E(Y[1,M(1)])-E(Y[1,M(0)])

{pstd}
The g-computation procedure for the mediation example works in a similar way, except that for the natural direct and indirect effects,
simulations under different hypothetical interventions need to be combined. Suppose that X is binary, then M is simulated under both
X=1 and X=0, giving M(1) and M(0), respectively. To simulate Y[1,M(0)] (needed to estimate the natural direct effect), X is set to 1 at the
same time as M is set to the simulated value under the intervention X=0.

{pstd}
If X is not binary and/or if X is multivariate, there may not be a natural comparison (such as 1 vs. 0) for calculating the total causal effect,
controlled direct effect or natural direct/indirect effects. In this case, the formulae above are replaced by

{phang2}
CDE(m)=E[Y(X,m)]-E[Y(0,m)]

{phang2}
TCE=E(Y(X,M(X)))-E(Y(0,M(0)))

{phang2}
NDE(0)=E(Y[X,M(0)])-E(Y[0,M(0)])

{pstd}
and

{phang2}
NIE(X)=E(Y[X,M(X)])-E(Y[X,M(0)])

{pstd}
where 0 is still the baseline value(s) of X, but is now compared with the distribution of X arising naturally in the observational data.


{dlgtab:Data structure}

{pstd}
The outcome can be binary or continuous, or (in the time-varying confounding option) time-to-event.

{pstd}
For the time-varying confounding option (as opposed to the mediation option---see below), the data must be in long format (see {help reshape}), 
i.e. there should be a separate record for each subject at each time-point. If the outcome is time-to-event, the outcome data for each subject 
should be given as a series of binary variables measured at each time-point. No records should be included in the dataset for subjects who have 
been censored before that time, due to death or loss to follow-up, or (in the case of a time-to-event outcome) due to having experienced the event 
before that time.

{pstd}
Any value which is to be imputed (including those at intermittent missing visits, for which a record must be included) should be denoted by a 
full stop (.), according to Stata's convention.

{pstd}
For the mediation option, there should be exactly one record per subject. Again, missing values to be imputed should be denoted by a 
full stop.



{title:Options}

{dlgtab:gformula (time-varying confounding options)}

{phang}
{opt outcome(varname)} specifies that {it:varname} is the outcome variable.

{phang}
{opt commands(string)} specifies which command (either {cmd:regress}, {cmd:logit}, {cmd:mlogit} or {cmd:ologit}) should be used when fitting each of the parametric
models. The variable name is followed by a colon (:), which is followed by the command name, with a comma (,) separating the different variables.

{pin}
Commands should be specified for the models for the outcome variable, time-varying confounders and the time-varying exposure. If there is
censoring due to death, then the command used for the model for death should also be specified.

{pin}
For a survival outcome (and death, if applicable), the command should be chosen as {cmd:logit}, since the outcome (or death) is given
(and simulated) as a sequence of binary variables.

{phang}
{opt equations(string)} specifies the right-hand side of the equations used when fitting the models listed above. The name of the dependent
variable is followed by a colon, which is followed by the list of independent variables. A comma (,) should separate the equations for the
different dependent variables.

{pin}
Since the data are stored in long format, lagged variables will need to be used (see below) to incorporate the dependence on data from previous
visits.

{pin}
The equation for any particular variable, for example a time-varying confounder L, must be the same at each visit.

{pin}
The prefix {opt i.} should be used for any variable that is to be treated as categorical.


{phang}
{opt idvar(varname)} specifies that varname is the numeric variable identifying the subject.

{phang}
{opt tvar(varname)} specifies that varname is the numeric variable identifying the time-point.

{phang}
{opt varyingcovariates(varlist)} specifies that varlist are the time-varying covariates. If lagged versions of these variables are to be used,
only the unlagged versions should be included in this list.

{phang}
{opt intvars(varlist)} specifies that varlist are the variables on which interventions are to be specified. If lagged versions of these variables
are to be used, only the unlagged versions should be included in this list.

{phang}
{opt interventions(string)} specifies the exact interventions to be compared. Different interventions should be separated by a comma (,)
and different commands within one intervention should be separated by a backwards slash (\).

{phang}
{opt dynamic} specifies that the regimes to be compared are dynamic. If this option is not specified, it is assumed that the regimes to be
compared (except for the observational regime) are all static.

{phang}
{opt eofu} specifies that the outcome is measured only at the end of follow-up. If this option is not specified, it is assumed that the
outcome is time-to-event.

{phang}
{opt pooled} specifies that the models defined by the {opt command} and {opt equation} options above (and the imputation models - see below - if 
relevant) should be fitted to data from all
visits at once, pooling across time-points. If this option is not specified, the models are fitted separately at each visit.

{phang}
{opt monotreat} specifies that the time-varying exposure in the observational data is binary, and changes at most once (from zero to one). Thus 
the exposure data for a given subject consists of a sequence of zeros followed by a sequence of ones (or a sequence containing only zeros, or only 
ones). This is common in many settings in which treatment may be initiated at some point, but never discontinued. Specifying this option only 
affects the way in which data are simulated under the observational regime. When using the {opt monotreat} option, the corresponding command for 
simulating the time-varying exposure should be specified as {cmd:logit}.

{phang}
{opt death(varname)} gives the name of the variable (a sequence of binary variables at each time-point) which takes the value 0 if a subject
is still alive at that time-point and 1 if a subject died between the previous and current time-points. (No further records following death
will be included in the original dataset.) 

{pin}
It is assumed that all censoring (before the final visit) where death=0 is due to loss to follow-up. Simulations are then drawn to
mimic a situation in which there are deaths but no losses to follow-up.

{pin}
If the {opt death} option is not specified, all censoring (before the final visit) is assumed to be due to loss to follow-up and simulations
are drawn to mimic no losses to follow-up.

{phang}
{opt derived(varlist)} lists all the variables which are to be derived from other variables, such as interactions. Lagged variables themselves
should not be included here, but variables derived using one or more lagged variables should be included. The derived variables must exist in
the original dataset.

{phang}
{opt derrules(string)} describes how the derived variables are to be obtained from the other variables. For example, if the variable al
is to be created as the product of a and l, the code is derrules(al:a*l) (and al should be included in {opt derived(varlist)}
above). The rules for generating more than one derived variable should be separated using a comma.

{phang}
{opt fixedcovariates(varlist)} lists the time-fixed covariates. These do not depend on the time-varying exposure and thus are not simulated.

{phang}
{opt laggedvars(varlist)} lists the lagged variables. The lagged variables must exist in the original dataset.

{phang}
{opt lagrules(string)} gives further details of the lagged variables. For example, if the variable a_lag is the lagged version of a,
and a_lag2 is the double-lagged version of a, this would be denoted as lagrules(a_lag:a 1, a_lag2:a 2).

{phang}
{opt msm(string)} specifies the form of the marginal structural model, for example, msm(regress y a_lag a_lag2) or
msm(stcox a_lag a_lag2).

{phang}
{opt minsim} suppresses the simulation of the outcome, and uses just the predicted means instead. This reduces unnecessary MC error in some contexts. Note: categorical outcomes fitted using ologit or mlogit are still
simulated even with minsim.

{phang}
{opt impute(varlist)} gives a list of the variables that contain missing values to be imputed via the method of single stochastic imputation 
using chained equations.

{phang}
{opt imp_cmd(string)} specifies which command (either {cmd:regress}, {cmd:logit}, {cmd:mlogit} or {cmd:ologit}) should be used when fitting each of the 
imputation models. The syntax is the same as for the {opt commands} option described above.

{phang}
{opt imp_eq(string)} specifies the RHS of each of the equations to be used for fitting each of the imputation models. 
The syntax is the same as for the {opt equations} option described above.

{phang}
{opt imp_cycles(#)} specifies the number of cycles of chained equations to be used in the imputation procedure. The default is 10.

{phang}
{opt simulations(#)} specifies the size of the Monte Carlo simulated dataset. The default is the same size as the observed dataset,
but for computational reasons, it can be smaller.

{phang}
{opt samples(#)} specifies the number of bootstrap samples. The default is 1,000.

{phang}
{opt seed(#)} sets the random-number seed to {it:#}.

{phang}
{opt all} specifies that all bootstrap confidence intervals are to be displayed (normal, percentile, bias corrected, and bias corrected and
accelerated). The default is to give normal-based bootstrap confidence intervals only. See {help bootstrap}.

{phang}
{opt graph} specifies that a Kaplan-Meier plot of the survival curves under each intervention be displayed. This option is only relevant for
a time-varying confounding analysis with a time-to-event outcome.

{phang}
{opt saving(string)} saves the dataset containing the original observational data and all the Monte Carlo simulations in a Stata dataset
named {opt string}. The dataset contains a variable _int which takes the value 0 for the observational data, the value 1 for the
simulations corresponding to intervention 1, and so on for each of the n specified interventions. Finally, the Monte Carlo simulations
under the observational regime appear at the end of the dataset, with _int taking the value n+1.

{phang}
{opt replace} specifies that if the .dta file given in the option {opt saving(string)} already exists, it should be overwritten.


{dlgtab:gformula (mediation options)}

{phang}
{opt mediation} specifies that the analysis is a mediation analysis. If this option is not specified, then a time-varying confounding analysis
is assumed.

{phang}
{opt outcome(varname)} specifies that {it:varname} is the outcome variable.

{phang}
{opt commands(string)} specifies which command (either {cmd:regress}, {cmd:logit}, {cmd:mlogit} or {cmd:ologit}) should be used when fitting the simulation models. The
variable name is followed by a colon (:), which is followed by the command name, with a comma (,) separating the different variables. 

{pin}
Models must be specified for the mediator(s), outcome, and the post-baseline confounders of the mediator-outcome relationship that are affected
by the exposure.

{phang}
{opt equations(string)} specifies the right-hand side of the equations used when fitting the models listed above. The name of the dependent
variable is followed by a colon (:), which is followed by the list of independent variables. A comma (,) should separate the equations for the
different dependent variables.

{pin}
The prefix {opt i.} should be used for any variable that is to be treated as categorical.

{phang}
{opt derived(varlist)} lists all the variables which are to be derived from other variables, such as interactions. 

{phang}
{opt derrules(string)} describes how the derived variables are to be obtained from the other variables. For example, if the variable al is
to be created as the product of a and l, the code is derrules(al:a*l) (and al should be included in {opt derived(varlist)}
above). The rules for generating more than one derived variable should be separated using a comma.

{phang}
{opt msm(string)} specifies the form of the marginal structural model, for example, msm(regress y x m) or msm(logit y x m xm). 

{phang}
{opt exposure(varlist)} specifies the exposure variable(s).

{phang}
{opt mediator(varlist)} specifies the mediator variable(s).

{phang}
{opt control(string)} specifies the value(s) at which the mediator(s) should be controlled for the controlled direct effect.
If this option is not specified, only natural direct/indirect effects are estimated.

{phang}
{opt obe} specifies that there is only one binary exposure, and that the comparisons should be made between X=1 and X=0.
If neither this nor {opt oce} (see next option) is specified, comparisons are made between the distribution of X in the observed data, and the baseline value(s).

{phang}
{opt oce} specifies that there is only one categorical exposure, and that the comparisons should be made between each non-baseline level of 
X and the baseline level, as specified using the {opt baseline} option above. If neither this nor {opt obe} is specifid, 
comparisons are made between the distribution of X in the observed data, and the baseline value(s).

{phang}
{opt baseline(string)} specifies the value(s) of the exposure(s) to be taken as baseline value(s). 

{phang}
{opt base_confs(varlist)} specifies the confounder(s) of the exposure-outcome relationship(s). 

{phang}
{opt post_confs(varlist)} specifies the confounder(s) of the mediator-outcome relationship(s). 

{phang}
{opt linexp} specifies that the exposure is continuous and that its effect is assumed to be linear. Thus, the CDE is defined as E{Y(X+1,m)-Y(X,m)}, and so on.

{phang}
{opt minsim} suppresses the simulation of the outcome, and uses just the predicted means instead. This reduces unnecessary MC error in some contexts. Note: categorical outcomes fitted using ologit or mlogit are still
simulated even with minsim. In addition, if the option {opt linexp} has been specified, even fewer outcomes need be simulated, and these unnecessary simulations are avoided when this option is specified.

{phang}
{opt moreMC} specifies that the number of MC simulations will be greater than the sample size. This can be useful in reducing MC error.

{phang}
{opt impute(varlist)} gives a list of the variables that contain missing values to be imputed via the method of single stochastic imputation 
using chained equations.

{phang}
{opt imp_cmd(string)} specifies which command (either {cmd:regress}, {cmd:logit}, {cmd:mlogit} or {cmd:ologit}) should be used when fitting each of the 
imputation models. The syntax is the same as for the {opt commands} option described above.

{phang}
{opt imp_eq(string)} specifies the RHS of each of the equations to be used for fitting each of the imputation models. 
The syntax is the same as for the {opt equations} option described above.

{phang}
{opt imp_cycles(#)} specifies the number of cycles of chained equations to be used in the imputation procedure. The default is 10.

{phang}
{opt simulations(#)} specifies the size of the Monte Carlo simulated dataset. The default is the same size as the observed dataset.

{phang}
{opt samples(#)} specifies the number of bootstrap samples. The default is 1,000.

{phang}
{opt seed(#)} sets the random-number seed to {it:#}.

{phang}
{opt all} specifies that all bootstrap confidence intervals are to be displayed (normal, percentile, bias corrected, and bias corrected
and accelerated). The default is to give normal-based bootstrap confidence intervals only. See {help bootstrap}.

{phang}
{opt saving(string)} saves the dataset containing the original observational data and all the Monte Carlo simulations in a Stata dataset
named {opt string}.

{phang}
{opt replace} specifies that if the .dta file given in the option {opt saving(string)} already exists, it should be overwritten.


{title:Authors}

{pstd}
Rhian Daniel, Bianca De Stavola and Simon Cousens.{break}
Centre for Statistical Methodology, London School of Hygiene and Tropical Medicine.{break}
Rhian.Daniel@LSHTM.ac.uk


{title:Further reading}

{phang}
Daniel, R. M., De Stavola, B. L., and Cousens, S. N. 2011. gformula: Estimating causal effects in the presence of time-varying confounding or mediation 
using the g-computation formula. {it:The Stata Journal} {cmd:11}(4):479-517.

{phang}
Robins, J. M. 1986. A new approach to causal inference in mortality studies with a sustained exposure period - application to control of the
healthy worker survivor effect. {it:Mathematical Modelling} {cmd:7}:1393-1512.

{phang}
Robins, J. M., and Hernan, M. A. 2009. {it:Longitudinal Data Analysis}, chap. 23: Estimation of the causal effects of time-varying exposures,
553-599. New York: Chapman and Hall / CRC Press.

{phang}
Pearl, J. 2001. Direct and Indirect Effects. In {it:Proceedings of the 17th Conference on Uncertainty in Artificial Intelligence}. 411-420.

{phang}
Didelez, V. 2006. Direct and Indirect Effects of Sequential Treatments. In {it:Proceedings of the 22nd Conference on Uncertainty in Artificial Intelligence}. 138-146.


{title:Acknowledgements}

{pstd}
{cmd:gformula} makes use of the {cmd:detangle} and {cmd:formatlist} procedures from {cmd:ice}, by kind permission of Patrick Royston.

{pstd}
This work was supported by the Medical Research Council, UK (Grant number: G0701024).

{pstd}
We are very grateful to Daniela Zugna, Deborah Ford and Linda Harrison for the suggestions they have made to improve this command.

