{smcl}
{* *! version 3.2 April 08 2016 J. N. Luchman}{...}
{cmd:help domin}
{hline}{...}

{title:Title}

{pstd}
Dominance analysis{p_end}

{title:Syntax}

{phang}
{cmd:domin} {it:depvar} [{it:indepvars} {ifin} {weight} {cmd:,} 
{opt {ul on}f{ul off}itstat(scalar)} {opt {ul on}r{ul off}eg(command, options)} 
{opt {ul on}s{ul off}ets((varlist) (varlist) ...)} {opt {ul on}a{ul off}ll(varlist)} 
{opt {ul on}nocond{ul off}itional} {opt {ul on}nocom{ul off}plete} {opt {ul on}eps{ul off}ilon} 
{opt mi} {opt miopt(mi_est_opts)} {opt {ul on}cons{ul off}model} 
{opt {ul on}rev{ul off}erse}]

{phang}{cmd:pweight}s, {cmd:aweight}s, {cmd:iweight}s, and {cmd:fweight}s are allowed but must be able to be used by the 
command in {opt reg()}, see help {help weights:weights}.  {help Time series operators} are also allowed for commands 
in {opt reg()} that accept them.  Finally, {help Factor variables} are also allowed, but can only be included in the {opt all(varlist)} 
and {opt sets((varlist) (varlist) ...)} options and, like weights and time series operators, must be accepted by the command 
in {opt reg()}.

{phang}{cmd:domin} requires installation of Ben Jann's {cmd:moremata} package (install here: {stata ssc install moremata}).

{title:Description}

{pstd}
Dominance analysis determines the relative importance of independent variables in an estimation model based on contribution to an overall 
model fit statistic (see Gr{c o:}mping, 2007 for a discussion).  Dominance analysis is an ensemble method in which importance determinations 
about independent variables are made by aggregating results across multiple models, though the method usually requires the ensemble contain 
each possible combination of the independent variables in the full model.  The all possible combinations ensemble with {it:p} independent 
variables in the full model results in 2^{it:p}-1 models estimated.  That is, each combiation of {it:p} variables alterating between included 
versus excluded (i.e., the 2 base to the exponent) where the constant[s]-only model is omitted (i.e., the -1 representing the distinct 
combination where no independent variables are included; see Budescu, 1993). {cmd:domin} derives 3 statistics from the 2^{it:p}-1 estimation models. 

{pstd}
{res}General dominance{txt} statistics are the most commonly reported and easiest to interpret. General dominance statistics are derived as
a weighted average marginal/incremental contribution to the overall fit statistic an independent variable makes across all models in which the 
independent variable is included.  If independent variable {it:X} has a larger general dominance statistic than independent variable {it:Y},
independent variable {it:X} "generally dominates" independent variable {it:Y}.  If general dominance statistics are equal for two independent 
variables, no general dominance designation can be made between those independent variables.

{pstd}
General dominance statistics distill the entire ensemble of models into a single value for each independent variable, which is why they are 
easiest to interpret. In addition, a useful property of the general dominance statistics is that they are an additive decomposition of the 
fit statistic associated with the full model (i.e., the general dominance statistics can be summed to obtain the value of the full model's fit 
statistic).  Thus, general dominance statistics are equivalent to Shapley values (see {stata findit shapley}).  General dominance statistics 
are the arithmetic average of all conditional dominance statistics discussed next.

{pstd}
{res}Conditional dominance{txt} statistics are also derived from the all possible combinations ensemble.  Conditional dominance 
statistics are computed as the average incremental contributions to the overall model fit statistic within a single "order" for models 
in which the independent variable is included - where "order" refers to a distinct number of independent variables in the estimation model.  One 
order is thus all models that include 1 independent variable.  Another order is all models that include 2 independent variables, and so on to 
{it:p} - or the order including only the model with all {it:p} independent variables.  Each independent variable will then have {it:p} different 
conditional dominance statistics.

{pstd}
The evidence conditional dominance statistics provide with respect to relative importance is stronger than that provided by general dominance 
statistics.  Because general dominance statistics are the arithmetic average of all {it:p} conditional dominance statistics, conditional 
dominance statistics, considered as a set, provide more information about each independent variable or, alternatively, are less "averaged" than 
general dominance statistics.  Conditional dominance statistics also provide information about independent variable redundancy, collinearity, 
and suppression effects as the user can see how the inclusion of any independent variable is, on average, affected by the inclusion of other
independent variables in the estimation model in terms of their effect on model fit. 

{pstd}
If independent variable {it:X} has larger conditional dominance statistics than independent variable {it:Y} 
across all {it:p} orders, independent variable {it:X}  "conditionally dominates" independent variable {it:Y}.  To be more specific, for 
{it:X} to conditionally dominate {it:Y}, the conditional dominance statistic associated with {it:X} at order 1 must be larger than 
the conditional dominance statistic associated with {it:Y} at order 1.  The conditional dominance statistic associated with {it:X} 
at order 2 must also be larger than the conditional dominance statistic associated with {it:Y} at order 2.  The conditional dominance 
statistic associated with {it:X} at order 3 must also be larger than the conditional dominance statistic associated with {it:Y} at order 3 and so 
on to order {it:p}.  Thus, the conditional dominance statistics at each order must all be larger for {it:X} than for {it:Y}.  If, at any order, 
the conditional dominance statistics for two independent variables are equal or there is a change rank order (i.e., {it:X}'s conditional 
dominance statistic is smaller than {it:Y}'s conditional dominance statistic), no conditional dominance designation can be made between 
those independent variables.  Conditional dominance imples general dominance as well, but the reverse is not true.  {it:X} can 
generally dominate {it:Y}, but not conditionally dominate {it:Y}.

{pstd}
{res}Complete dominance{txt} designations are the final designation derived from the all possible combinations ensemble.  Complete dominance 
designations are made by comparing all possible incremental contributions to model fit for two independent variables. The evidence the complete 
dominance designation provides with respect to relative importance is the strongest possible, and supercedes that of general and conditional 
dominance.  Complete dominance is the strongest evidence as it is completely un-averaged and pits each independent variable against one another 
in every possible comparison.  Thus, it is not possible for some good incremental contributions to compensate for some poorer incremental 
contributions as can occur when such data are averaged.  Complete dominance then provides information on a property of the entire ensemble 
of models, as it relates to a comparison between two independent variables.

{pstd}
If independent variable {it:X} has a larger incremental contribution to model fit than independent variable {it:Y} across all possible 
comparisons, independent variable {it:X}  "completely dominates" independent variable {it:Y}. As with conditional dominance designations, 
for {it:X} to completely dominate {it:Y}, the incremental contribution to fit associated with {it:X} without any other independent variables 
in the model must be larger than the incremental contribution to fit associated with {it:Y} without any other independent variables in the 
model.  The incremental contribution to fit associated with {it:X} with independent variable {it:Z} also in the model must also be larger 
than the incremental contribution to fit associated with {it:Y} with independent variable {it:Z} also in the model.  The incremental 
contribution to fit associated with {it:X} with independent variable {it:W} also in the model must also be larger than the incremental 
contribution to fit associated with {it:Y} with independent variable {it:W} also in the model and so on for all other 2^({it:p}-2) 
comparisons (i.e., all possible combinations of the other independent variables in the model).  Thus, the incremental contribution 
to fit associated with {it:X} for each of the possible 2^({it:p}-2)  comparisons must all be larger than the incremental contribution 
to fit associated with {it:Y}.  If, for any comparison, the incremental contribution to fit for two independent variables are equal 
or there is a change in rank order (i.e., {it:X}'s incremental contribution to fit is smaller than {it:Y}'s the incremental 
contribution to fit with the same set of other independent variables in the model), no complete dominance designation can be made 
between those independent variables.  Complete dominance imples both general and conditional dominance, but, again, the reverse is 
not true.  {it:X} can generally and/or conditionally dominate {it:Y}, but not completely dominate {it:Y}.

{pstd}
By comparison to general and conditional dominance designations, the complete dominance designation has no natural statistic.  That said, 
{cmd:domin} returns a complete dominance matrix which reads from the left to right.  Thus, a value of 1 means that the indepdendent variable 
in the row completely dominates the independent variable in the column.  Conversely, a value of -1 means the opposite, that the independent 
variable in the row is completely dominated by the independent variable in the column.  A 0 value means no complete dominance designation 
could be made as the comparison independent variables' incremental contributions differ in relative magnitude from model to model.

{title:Display}

{pstd}
{cmd:domin}, by default, will produce all three types (i.e., general, conditional, and complete) of dominance statistics.  The general dominance 
statistics cannot be suppressed in the output, is the first set of statistics to be displayed, mirror the output style of most single equation 
commands (e.g., {cmd:regress}), and produces two additional results.  Along with the general dominance statistics, the general dominance statistics 
display a vector of standardized general dominance statistics; which is general dominance statistic vector normed or standardized to be out of 100%.  
The final column is a ranking or the relative importance of the independent variables based on the general dominance statistics.  

{pstd}
The conditional dominance statistics are second, can be suppressed by the {opt noconditional} option, and are displayed in matrix format.  The first 
column displays the average marginal contribution to the overall model fit statistic with 1 independent variable in the model, the second column 
displays the average marginal contribution to the overall model fit statistic with 2 independent variables in the model, and so on until 
column {it:p} which displays the average marginal contribution to the overall model fit statistic with all {it:p} independent variables in the 
model.  Each row corresponds to an independent variable.

{pstd}
Complete dominance is third, can be suppressed by the {opt nocomplete} option, and are also displayed in matrix format.  The rows of the 
complete dominance matrix correspond to dominance of the independent variable in that row over the independent variable in each column.  If a 
row entry has a 1, the independent variable associated with the row completely dominates the independent variable associated with the column.  By 
contrast, if a row entry has a -1, the independent variable associated with the row is completely dominated by the independent variable 
associated with the column.  A 0 indicates no complete dominance relationship between the independent variable associated with the row and 
the independent variable associated with the column.

{pstd}
Finally, if all three dominance statistics are reported, a "strongest dominance designations" list is reported.  The strongest dominance designations 
list reports the strongest dominance designation between all pairwise, independent variable comparisons.

{marker options}{...}
{title:Options}

{phang}{opt fitstat(scalar)} refers {cmd:domin} to the scalar valued model fit summary statistic used to compute all dominance 
statistics.  The scalar in {opt fitstat()} can be any {help return:returned}, {help ereturn:ereturned}, or other {help scalar:scalar}. 
{cmd:domin} defaults to {opt fitstat(e(r2))} and will produce a warning denoting the default behavior.

{phang}{opt reg(command, options)} refers {cmd:domin} to a command which produces the scalar in {opt fitstat()} - which can include any 
user-written {help program:program}.  User-written programs must follow the traditional Stata single equation {it: cmd depvar indepvars} syntax.  
{opt reg()} also allows the user to pass options for the command used by {cmd:domin}.  When a comma is added in {opt reg()}, all the syntax 
following the comma will be passed to each run of the command as options. {cmd:domin} defaults to {opt reg(regress)} and will produce a 
warning denoting the default behavior.

{phang}{opt sets()} binds together independent variables as a set in the all possible combinations ensemble. Hence, all variables in a set 
will always appear together and are considered a single independent variable in the all possible combinations ensemble. 

{pmore}The user can specify as many independent variable sets of arbitrary size as is desired.  The basic syntax follows: 
{opt sets((x1 x2) (x3 x4))} which will create two sets (denoted "set1" and "set2" in the output).  set1 will be created from the variables 
x1 and x2 whereas set2 will be created from the variables x3 and x4.  All sets must be bound by parentheses - thus, each set must begin with a 
left paren "(" and end with a right paren ")" and all parentheses separating sets in the {opt sets()} option syntax must be separated by at 
least one space.

{pmore}The {opt sets()} option is useful for obtaining dominance statistics for independent variables that are more interpretable when combined, 
such as several dummy or effects codes reflecting mutually exclusive groups.  {help Factor variables} can be included in any 
{opt sets()} (see Example #3 below).

{phang}{opt all()} defines a set of independent variables to be included in all the combinations in the ensemble.  Thus, all independent 
variables included in the {opt all()} option are used as a set of covariates for which dominance statistics will not be computed.  Rather, 
the magnitude of the overall fit statistic associated with the set of independent variables in the {opt all()} option are subtracted from 
the dominance statistics for all independent 
variables.  The {opt all()} option accepts {help factor variables} (see Example #2 below).

{phang}{opt noconditional} suppresses the computation and display of of the conditional dominance statistics.  Suppressing the computation 
of the conditional dominance statistics can save computation time when conditional dominance statistics are not desired.  Suppressing 
the computation of conditional dominance statistics also suppresses the "strongest dominance designations" list.

{phang}{opt nocomplete} suppresses the computation of the complete dominance designations.  Suppressing the computation of the complete dominance
designations can save computation time when complete dominance designations are not desired.  Suppressing the computation of complete dominance 
designations also suppresses the "strongest dominance designations" list.

{phang}{opt epsilon} is a faster version of dominance analysis (i.e., relative weights or "epsilon"; Johnson, 2000).  {opt epsilon} obviates the 
each subset regression by orthogonalizing independent variables using singular value decomposition (see {help matrix svd}).  {opt epsilon}'s 
singular value decomposition approach is not equivalent to the all possible combinations ensemble approach but is many fold faster for 
models with many independent variables and tends to produce similar answers regarding relative importance (LeBreton, Ployhart, & Ladd, 2004).  
{opt epsilon} also does not allow the use of {opt all()}, {opt sets()}, {opt mi}, {opt consmodel}, {opt reverse}, and does not allow the 
use of {help weights}.  Using {opt epsilon} also only produces general dominance statistics (i.e., requires {opt noconditional} and 
{opt nocomplete}).  

{pmore}Option {opt epsilon} can obtain general dominance statistics for {cmd:regress}, {cmd:glm} (for any {opt link()} and {opt family()}; 
see Tonidandel & LeBreton, 2010), as well as {cmd:mvdom} (the user written wrapper program for multivariate regression; see LeBreton & 
Tonidandel, 2008; see also Example #6 below).  By default, {opt epsilon} assumes {opt reg(regress)} and {opt fitstat(e(r2))}.  Note that 
{opt epsilon} ignores entries in {opt fitstat()} as it produces its own fit statistic.

{pmore}{cmd:Note:} The {opt epsilon} approach has been recently criticized for being conceptually flawed and biased (see Thomas, Zumbo, Kwan, 
& Schweitzer, 2014), despite research showing similarity between dominance and {opt epsilon}-based methods (e.g., Ladd et al., 2004).  
Thus, the user is cautioned in the use of {opt epsilon} as its speed may come at the cost of bias.

{phang}{opt mi} invokes Stata's {help mi} options within {cmd:domin}.  Thus, each analysis is run using the {cmd:mi estimate} prefix and all 
the {opt fitstat()} statistics returned by the analysis program are averaged across all imputations (see Example #10 below).  

{phang}{opt miopt()} includes options in {cmd:mi estimate} within {cmd:domin}.  Each analysis is passed the options in {opt miopt()} and each of
the entries in {opt miopt()} must be a valid option for {cmd:mi estimate}.  Invoking {opt miopt()} without {opt mi} turns {opt mi} on and produces
a warning noting that the user neglected to also specify {opt mi}.

{phang}{opt consmodel} adjusts all fit statistics for a baseline level of the fit statistic in {opt fitstat()}.  Specifically, {cmd:domin} 
subtracts the value of {opt fitstat()} with no independent variables (i.e., omitting all entries in the varlist, in {opt sets()}, and in 
{opt all()}).  {opt consmodel} is useful for obtaining dominance statistics using overall model fit statistics that are not 0 when a 
constant[s]-only model is estimated (e.g., AIC, BIC) and the user wants to obtain dominance statistics adjusting for the constant[s]-only 
baseline value.

{phang}{opt reverse} reverses the interpretation of all dominance statistics in the {cmd:e(ranking)} vector, {cmd:e(cptdom)} matrix, fixes the 
computation of the {cmd:e(std)} vector, and the "strongest dominance designations" list.  {cmd:domin} assumes by default that higher values on 
overall fit statistics constitute better fit, as dominance analysis has historically been based on the explained-variance R2 metric.  
However, dominance analysis can be applied to any model fit statistic (see Azen, Budescu, & Reiser, 2001 for other examples).  
{opt reverse} is then useful for the interpetation of dominance statistics based on overall model fit statistics that decrease with 
better fit (e.g., AIC, BIC).

{title:Final Remarks}

{pstd}It is the responsibility of the user to supply {cmd:domin} with an overall fit statistic that can be validly dominance analyzed.  
Traditionally, only R2 and pseudo-R2 statistics have been used for dominance analysis due to their interpretability - but {cmd:domin} was 
developed with extensibility in mind and any statistic {it:could} potentially be used (see Azen, Budescu, & Reiser, 2001 for other examples).
Arguably, the most important criteria for an overall fit statistic to be used to compute dominance statistics are a] {it:monononicity} or that 
the fit statistic will not decrease with inclusion of more independent variables (without a degree of freedom adjustment such as those in 
information criteria), b] {it:linear invariance} or that the fit statistic is invariant/unchanged for non-singular transformations 
of the independent variables, and c] {it:information content} or interpretation of the fit statistic as providing information about overall 
model fit.

{pstd}Although non-R2 overall fit statistics can be used, {cmd:domin} assumes that the fit statistic supplied {it:acts} like an R2 statistic.  
Thus, {cmd:domin} assumes that better model fit is associated with increases to the fit statistic and all marginal contributions can be 
obtained by subtraction.  For model fit statistics that decrease with better fit (i.e., AIC, BIC, deviance), the interpretation of the 
dominance relationships need to be reversed (see Examples #7 and #9).  

{pstd}It is the responsibility of the user to provide {cmd:domin} with predictor combinations that can be validly dominance analyzed.  
That is, including products of variables and individual dummy codes from a dummy code set can produce invalid dominance analysis results or can 
at least, produce dominance statistics with a complicated interpretation.  If an independent variable should not be analyzed {it:by itself} in 
a regression model, than it should not be included in the {it:varlist} and the user should consider using a {opt sets()} specification.  

{pstd}Some users may be interested in obtaining relative importance comparisons for interactions, non-linear variables, as well as for indicator 
variables or dummy codes (i.e., any variable that can be constructed by a {help factor variable}).  Whereas dummy codes should be included together 
in a {opt sets()} set, users can follow the residualization method laid out by LeBreton, Tonidandel, and Krasikova (2013; see Example #4) to 
obtain relative importance of interaction and non-linear variables.

{pstd}{cmd:domin} can also produce standard errors using {help bootstrap}ping (see Example #5).  Although standard errors {it:can} be produced, 
the sampling distribution for dominance weights have not been extensively studied.  {help permute} tests are also conceptually applicable to 
dominance weights as well.

{pstd}{cmd:domin} comes with 2 wrapper programs {cmd:mvdom} and {cmd:mixdom}.  {cmd:mvdom} implements multivariate regression-based dominance 
analysis described by Azen and Budescu (2006; see {help mvdom}).  {cmd:mixdom} implements linear mixed effects regression-based dominance analysis 
described by Luo and Azen (2013; see {help mixdom}).  Both programs are intended to be used as wrappers into {cmd:domin} and serve to illustrate 
how the user can also adapt existing regressions (by Stata Corp or user-written) to evaluate in a relative importance analysis when they do not 
follow the traditional {it:depvar indepvars} format.  As long as the wrapper program can be expressed in some way that can be evaluated in 
{it:depvar indepvars} format, any analysis could be dominance analyzed. 

{pstd}Any program used by as a wrapper by {cmd:domin} must accept at least one optional argument and must accept an {help if} statement in its 
{help syntax} line.

{pstd}{cmd:domin} does not directly accept the {help svy} prefix - but does accept {cmd:pweight}s.  Because {cmd:domin} does not produce standard 
errors by defualt, to respect the sampling design for complex survey data the user need only provide {cmd:domin} the {cmd:pweight} variable for 
commands that accept {cmd:pweight}s (see Luchman, 2015).

{title:Introductory examples}

{phang} {cmd:webuse auto}{p_end}

{phang}Example 1: linear regression dominance analysis{p_end}
{phang} {cmd:domin price mpg rep78 headroom} {p_end}

{phang}Example 2: Ordered outcome dominance analysis with covariate (e.g., Luchman, 2014){p_end}
{phang} {cmd:domin rep78 trunk weight length, reg(ologit) fitstat(e(r2_p)) all(turn)} {p_end}

{phang}Example 3: Binary outcome dominance analysis with factor varaible (e.g., Azen & Traxel, 2009) {p_end}
{phang} {cmd:domin foreign trunk weight, reg(logit) fitstat(e(r2_p)) sets((i.rep78))} {p_end}

{phang}Example 4: Comparison of interaction and non-linear variables {p_end}
{phang} {cmd:generate mpg2 = mpg^2} {p_end}
{phang} {cmd:generate headr2 = headroom^2} {p_end}
{phang} {cmd:generate mpg_headr = mpg*headroom} {p_end}
{phang} {cmd:regress mpg2 mpg} {p_end}
{phang} {cmd:predict mpg2r, resid} {p_end}
{phang} {cmd:regress headr2 headroom} {p_end}
{phang} {cmd:predict headr2r, resid} {p_end}
{phang} {cmd:regress mpg_headr mpg headroom} {p_end}
{phang} {cmd:predict mpg_headrr, resid} {p_end}
{phang} {cmd:domin price mpg headroom mpg2r headr2r mpg_headrr} {p_end}

{phang}Example 5: Epsilon-based linear regression approach to dominance with bootstrapped standard errors{p_end}
{phang} {cmd:bootstrap, reps(500): domin price mpg headroom trunk turn gear_ratio foreign length weight, epsilon} {p_end}
{phang} {cmd:estat bootstrap}{p_end}

{phang}Example 6: Multivariate regression with wrapper {help mvdom}; using default Rxy metric (e.g., Azen & Budescu, 2006; LeBreton & Tonidandel, 2008){p_end}
{phang} {cmd:domin price mpg headroom trunk turn, reg(mvdom, dvs(gear_ratio foreign length weight)) fitstat(e(r2))} {p_end}
{phang}Comparison dominance analysis with Pxy metric{p_end}
{phang} {cmd:domin price mpg headroom trunk turn, reg(mvdom, dvs(gear_ratio foreign length weight) pxy) fitstat(e(r2))} {p_end}
{phang}Comparison dominance analysis with {opt epsilon}{p_end}
{phang} {cmd:domin price mpg headroom trunk turn, reg(mvdom, dvs(gear_ratio foreign length weight)) epsilon)} {p_end}

{phang}Example 7: Gamma regression with deviance fitstat and constant-only comparison using {opt reverse}{p_end}
{phang} {cmd:domin price mpg rep78 headroom, reg(glm, family(gamma) link(power -1)) fitstat(e(deviance)) consmodel reverse} {p_end}
{phang} Comparison dominance analysis with {opt epsilon} {p_end}
{phang} {cmd:domin price mpg rep78 headroom, reg(glm, family(gamma) link(power -1)) epsilon} {p_end}

{phang}Example 8: Mixed effects regression with wrapper {help mixdom} (e.g., Luo & Azen, 2013){p_end}
{phang} {cmd:webuse nlswork, clear}{p_end}
{phang} {cmd:domin ln_wage tenure hours age collgrad, reg(mixdom, id(id)) fitstat(e(r2_w)) sets((i.race))} {p_end}

{phang}Example 9: Multinomial logistic regression with simple program to return BIC {p_end}
{phang} {cmd:program define myprog, eclass}{p_end}
{phang} {cmd:syntax varlist if , [option]}{p_end}
{phang} {cmd:tempname estlist}{p_end}
{phang} {cmd:mlogit `varlist' `if'}{p_end}
{phang} {cmd:estat ic}{p_end}
{phang} {cmd:matrix `estlist' = r(S)}{p_end}
{phang} {cmd:ereturn scalar bic = `estlist'[1,6]}{p_end}
{phang} {cmd:end}{p_end}
{phang} {cmd:domin race tenure hours age nev_mar, reg(myprog) fitstat(e(bic)) consmodel reverse} {p_end}
{phang} Comparison dominance analysis with McFadden's pseudo-R2 {p_end}
{phang} {cmd:domin race tenure hours age nev_mar, reg(mlogit) fitstat(e(r2_p))} {p_end}

{phang}Example 10: Multiply imputed dominance analysis {p_end}
{phang} {cmd:webuse mheart1s20, clear} {p_end}
{phang} {cmd:domin attack smokes age bmi hsgrad female, reg(logit) fitstat(e(r2_p)) mi} {p_end}
{phang} Comparison dominance analysis without {cmd:mi} ("in 1/154" keeps only original observations for comparison as in 
{bf:{help mi_intro_substantive:[MI] intro substantive}}) {p_end}
{phang} {cmd:domin attack smokes age bmi hsgrad female in 1/154, reg(logit) fitstat(e(r2_p))} {p_end}

{title:Saved results}

{phang}{cmd:domin} saves the following results to {cmd: e()}:

{synoptset 16 tabbed}{...}
{p2col 5 15 19 2: scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(fitstat_o)}}overall fit statistic value{p_end}
{synopt:{cmd:e(fitstat_a)}}fit statistic value associated with variables in {opt all()}{p_end}
{synopt:{cmd:e(fitstat_c)}}constant(s)-only fit statistic value computed with {opt consmodel}{p_end}
{p2col 5 15 19 2: macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(cmd)}}{cmd:domin}{p_end}
{synopt:{cmd:e(fitstat)}}contents of the {opt fitstat()} option{p_end}
{synopt:{cmd:e(reg)}}contents of the {opt reg()} option (before comma){p_end}
{synopt:{cmd:e(regopts)}}contents of the {opt reg()} option (after comma){p_end}
{synopt:{cmd:e(mi)}}{cmd:mi}{p_end}
{synopt:{cmd:e(miopt)}}contents of the {opt miopt()} option{p_end}
{synopt:{cmd:e(estimate)}}estimation method ({cmd:dominance} or {cmd:epsilon}){p_end}
{synopt:{cmd:e(properties)}}{cmd:b}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(set{it:#})}}variables included in {opt set(#)}{p_end}
{synopt:{cmd:e(all)}}variables included in {opt all()}{p_end}
{p2col 5 15 19 2: matrices}{p_end}
{synopt:{cmd:e(b)}}general dominance statistics vector{p_end}
{synopt:{cmd:e(std)}}general dominance standardized statistics vector{p_end}
{synopt:{cmd:e(ranking)}}rank ordering based on general dominance statistics vector{p_end}
{synopt:{cmd:e(cdldom)}}conditional dominance statistics matrix{p_end}
{synopt:{cmd:e(cptdom)}}complete dominance designation matrix{p_end}
{p2col 5 15 19 2: functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{title:References}

{p 4 8 2}Azen, R., Budescu, D. V., & Reiser, B. (2001). Criticality of predictors in multiple regression. {it:British Journal of Mathematical and Statistical Psychology, 54(2)}, 201-225.{p_end}
{p 4 8 2}Azen, R. & Budescu D. V. (2003). The dominance analysis approach for comparing predictors in multiple regression. {it:Psychological Methods, 8}, 129-148.{p_end}
{p 4 8 2}Azen, R., & Budescu, D. V. (2006). Comparing predictors in multivariate regression models: An extension of dominance analysis. {it:Journal of Educational and Behavioral Statistics, 31(2)}, 157-180.{p_end}
{p 4 8 2}Azen, R. & Traxel, N. M. (2009). Using dominance analysis to determine predictor importance in logistic regression. {it:Journal of Educational and Behavioral Statistics, 34}, pp 319-347.{p_end}
{p 4 8 2}Budescu, D. V. (1993). Dominance analysis: A new approach to the problem of relative importance of predictors in multiple regression, {it:Psychological Bulletin, 114}, 542-551.{p_end}
{p 4 8 2}Gr{c o:}mping, U. (2007). Estimators of relative importance in linear regression based on variance decomposition. {it:The American Statistician, 61(2)}, 139-147.{p_end}
{p 4 8 2}Johnson, J. W. (2000). A heuristic method for estimating the relative weight of predictor variables in multiple regression. {it:Multivariate Behavioral Research, 35(1)}, 1-19.{p_end}
{p 4 8 2}LeBreton, J. M., Ployhart, R. E., & Ladd, R. T. (2004). A Monte Carlo comparison of relative importance methodologies. {it:Organizational Research Methods, 7(3)}, 258-282.{p_end}
{p 4 8 2}LeBreton, J. M., & Tonidandel, S. (2008). Multivariate relative importance: Extending relative weight analysis to multivariate criterion spaces. {it:Journal of Applied Psychology, 93(2)}, 329-345.{p_end}
{p 4 8 2}LeBreton, J. M., Tonidandel, S., & Krasikova, D. V. (2013). Residualized relative importance analysis a technique for the comprehensive decomposition of variance in higher order regression models. {it:Organizational Research Methods}, 16(3)}, 449-473.{p_end}
{p 4 8 2}Luchman, J. N. (2015). Determining subgroup difference importance with complex survey designs: An application of weighted dominance analysis. {it:Survey Practice, 8(5)}, 1–10.{p_end}
{p 4 8 2}Luchman, J. N. (2014). Relative importance analysis with multicategory dependent variables: An extension and review of best practices. {it:Organizational Research Methods, 17(4)}, 452-471.{p_end}
{p 4 8 2}Luo, W., & Azen, R. (2013). Determining predictor importance in hierarchical linear models using dominance analysis. {it:Journal of Educational and Behavioral Statistics, 38(1)}, 3-31.{p_end}
{p 4 8 2}Tonidandel, S., & LeBreton, J. M. (2010). Determining the relative importance of predictors in logistic regression: An extension of relative weight analysis. {it:Organizational Research Methods, 13(4)}, 767-781.{p_end}
{p 4 8 2}Thomas, D. R., Zumbo, B. D., Kwan, E., & Schweitzer, L. (2014). On Johnson's (2000) relative weights method for assessing variable importance: A reanalysis. {it:Multivariate Behavioral Research, 49(4)}, 329-338.{p_end}

{title:Author}

{p 4}Joseph N. Luchman{p_end}
{p 4}Senior Scientist{p_end}
{p 4}Fors Marsh Group LLC{p_end}
{p 4}Arlington, VA{p_end}
{p 4}jluchman@forsmarshgroup.com{p_end}

{title:Acknowledgements}

Thanks to Nick Cox, Ariel Linden, Amanda Yu, Torsten Neilands, Arlion N., Eric Melse, De Liu, and Patricia "Economics student" for suggestions 
and bug reporting.
