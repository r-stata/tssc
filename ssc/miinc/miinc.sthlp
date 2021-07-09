{smcl}
{* *! miinc version 2.0 August 7, 2014 J. N. Luchman}{...}
{cmd:help mmiinc}
{hline}{...}

{title:Title}

{pstd}
{ul on}M{ul off}ulti-model {ul on}i{ul off}nference using {ul on}in{ul off}formation {ul on}c{ul off}riteria (MIINC){p_end}

{title:Syntax}

{phang}
{cmd:miinc} [{cmd:se}] {it:{help depvar}} [{it:{help indepvars}}] {ifin} {weight} [{cmd:,} {opt {ul on}r{ul off}eg(estcmd, regopts)} 
{opt ic(aicc | aic | bic | noic)} {opt {ul on}b{ul off}estmodels(#)} {opt pip} {opt {ul on}s{ul off}ets((varlist) (varlist) ...)} 
{opt {ul on}a{ul off}ll(varlist)} {opt ttest} {opt ll(scalar)} {opt parm(scalar)} {opt obs(scalar)}]

or

{phang}
{cmd:miinc me} [{cmd:(}{it:eqname1 = indepvars}{cmd:)} {cmd:(}{it:eqname2 = indepvars}{cmd:)} ...] {cmd:,} 
{opt {ul on}r{ul off}eg(full estcmd with comma)} [{opt ic(aicc | aic | bic | noic)}  {opt {ul on}b{ul off}estmodels(#)} {opt pip}
{opt {ul on}s{ul off}ets((parmlist) (parmlist) ...)} {opt ttest} {opt ll(scalar)} {opt parm(scalar)} {opt obs(scalar)}]

{phang}{cmd:mi estimate} is allowed (see {help mi estimate}); see {help prefix}.  {cmd:pweight}s, {cmd:aweight}s, {cmd:iweight}s, and 
{cmd:fweight}s are allowed but must be able to be used by the estimation command in {opt reg()}, see help {help weights:weights}, and must 
be included in the {opt reg()} option with {cmd:miinc me}.  {help Factor variables} are also allowed, but like weights, must be accepted by 
the estimation command in {opt reg()}. {cmd:svy} is allowed (see {help svy}); but only as a prefix to the command within {opt reg()}.

{title:Description: Basic Information and Use}

{pstd}
{cmd:miinc} is a suite of utility commands for model selection, model averaging, and independent variable/parameter inclusion probability 
using information criteria as the basis for model fit.  The framework implemented in {cmd:miinc} derives from Burnham and Anderson's 
(2002; 2004) work on multi-model inference.  A model, in the present case, refers to a set of independent variables or parameter estimates.

{pstd}
{cmd:miinc} has 2 different modes.  The first mode, {cmd:miinc se}, is the single equation version of {cmd:miinc}.  {cmd:miinc se} is for use with 
estimation commands that follow the traditional {it:{help depvar} {help indepvars}} format common to most single equation commands.  {cmd:miinc se} 
is the default version of {cmd:miinc} and does not require the {cmd:se} suffix.  The second mode, {cmd:miinc me}, is the multiple equation 
version of {cmd:miinc}.  {cmd:miinc me} is more flexible than {cmd:miinc se} as it allows for multiple equations of any form, but does require that 
the estimation command in {opt reg()} accept {help constraint}s.  All commands to be used by {cmd:miinc} must produce and store some sort of 
log-likelihood, parameter estimate count, and number of observations.  {cmd:miinc}'s defaults are to look for {cmd:e(ll)} as a log-likelihood, 
{cmd:e(rank)} as a parameter estimate count, and {cmd:e(N)} as a number of observations count to derive information criteria.

{pstd}
The {cmd:miinc} modes operate differently in terms of how they implement multi-model inference, which requires some description.  {cmd:miinc se} 
operates by treating all the variables in the {help indepvars} list as independent variables about which the user is uncertain and would like to 
model average.  Additionally, all the independent variables bound together in the same or separate sets by the {opt sets()} option are considered 
to be uncertain, but should be included together in any particular model.  Thus, independent variables bound together in a distinct {opt sets()} 
set have joint (un-)certainty.  Finally, independent variables in the {opt all()} option are those about which the user has certainty and are 
thus included in every/all model(s).  By default constants are included in every model.  {cmd:miinc se} uses the {it:estcmd} or estimation 
command specified in the {opt reg()} option by substituting everything on the left-hand side of the comma in the {opt reg()} option 
(including prefixes) at the beginning of the command.  {cmd:miinc se} puts everything to the right-hand side of the comma in {opt reg()} at the 
end of the command as options or {it:regopts}.  The comma in the {opt reg()} option for {cmd:miinc se} is optional (as the user may not have 
{it:regopts} to pass to the {it:estcmd}. In fact, {opt reg()} is itself optional as the default {it:estcmd} is {help regress} with all of 
{cmd:regress}' command defaults.

{pstd}
{cmd:miinc me} forces the user to specify a {it:full estcmd} in {opt reg()}.  That is, the {it:full estcmd} requires that the user write out 
a full command (prefixes [other than {cmd:mi estimate}], command name, model components, and options) to be interpreted by Stata and would be 
interpreted as an estimation command if inputted to Stata outside of the {opt reg()} option.  {cmd:miinc me} also requires a comma for options to 
be included in {opt reg()} whether or not any options are included as the multi-model inference is conducted using {help constraint}.  Given the 
{it:full estcmd} in {opt reg()}, {cmd:miinc me} parses all the equations enclosed in parentheses before the comma, building a {it:parmname} by
linking the {it:eqname} on the left-hand side of the equal sign with each separate independent variable in the associated {help indepvars} varlist.  
Thus, {cmd:miinc me} creates a set of {it:parmname}s of the form "{it:eqname:indepvar}" about which the user is uncertain in the {it:full estcmd} 
in {opt reg()}.  The {opt sets()} option operates similarly, except that the user must write out each {it:parmname} in the form 
"{it:eqname:indepvar}".  Thus, a {it:parmlist} can be generated by enclosing sevaral {it:parmname}s in parentheses to bind.  Just as in 
{cmd:miinc se}, the {it:parmname}s bound together by parentheses are considered jointly (un-)certain.  {cmd:miinc me} has no {opt all()} option as 
all parameters not either specified in the equations before the comma or in the {opt sets()} option are considered to be certain and are included 
in every model.

{title:Description: Technical}

{pstd}
In terms of model selection, {cmd:miinc}'s approach stems from of information theory.  In particular, {cmd:miinc} uses the Kullback-Liebler 
divergence estimate from information theory as represented by the Akaike (aic and small-sample corrected aicc) or Bayesian (bic) information 
criterion.  Models are ranked based on the focal information criterion and can be returned using the {opt bestmodels()} option.  As is 
noted by Burnham and Anderson (2004; p. 271), differences between {res}0{txt} and {res}2{txt} from the smallest information criterion 
producing/best model can be interpreted as having strong support, differerences between {res}4{txt} and {res}7{txt} can be interpreted as 
having coniderably less support than the best model, and differences greater than {res}10{txt} have essentially no support compared to 
the best model.

{pstd}
{cmd:miinc}'s main focus is on model averaging.  The model coefficients are averaged based on weights derived from the focal 
information criterion following Burnham and Anderson (2002; 2004).  Specifically, each model's information criterion is subtracted from the 
smallest information criterion obtained across all models {it:i} (obtaining {it:IC_difference_i}).  Each model's information criterion is then 
transformed back into a likelihood of the model given the data (i.e., {it:adj_lhd_i} = exp(-2*{it:IC_difference_i})).  Information criterion 
weights are then obtained for each model by forming a ratio of {it:adj_lhd_i} to the sum of all the {it:adj_lhd}s across all models to obtain 
{it:IC_weight_i}.  Finally, the model average coefficient vector is the sum of the product of {it:IC_weight_i} and the coefficient 
vector for model {it:i} across all models (see Burnham & Anderson, 2004; Equation 1).  The model average variance-covariance matrix for the 
estimator is similarly derived.  Specifically, the model averaged sampling variance-covariance matrix is obtained by summing the product of of 
{it:IC_weight_i} and the sum of model {it:i}'s sampling (co-)variance estimate and the squared (for a sampling variance) or the product of the 
differences (for a sampling covariance) between the model averaged coefficient(s) and model {it:i}'s estimate of that/those coefficient(s), 
summed across all models (see Burnham & Anderson, 2004; Equations 4 & 5).

{pstd}
{cmd:miinc} can also produce estimates of independent variable/parameter inclusion probability.  The approach taken by {cmd:miinc} mirrors 
the posterior inclusion probability metric produced by many Bayesian model averaging routines (see {stata findit bma}).  Thus, the inclusion 
probability values produced by {cmd:miinc} are the sum, across all models, of the {it:IC_weight}s (see Burnham & Anderson, 2004; p. 274).

{pstd}
{cmd:miinc} prodeeds by first estimating coefficients and samping variance-covariances from the specified model for each valid subset of the 
independent variables or parameters about which the user has uncertainty. {cmd:miinc} is {help factor variables} "smart."  That is, {cmd:miinc} 
does not allow inapproproate models to be estimated and averaged.  For models with dummy codes/indicators (i.e., {help factor variables} with 
"{cmd:i.}"), all indicators associated with an independent variable for {cmd:miinc se} are bound together and always included in the same models 
like a set from {opt sets()}.  By contrast, with {cmd:miinc me} parameters with the same equation and independent variable need to be bound 
together explicitly in a {opt sets()}.  Hence, all the dummy codes/indicators are and need to be considered as a set.  For models with exponents 
or interactions (i.e., {help factor variables} with "{cmd:#}" or factorials "{cmd:##}"), all lower-order or marginal terms must be present when a 
higher-order term is present in a model.  {cmd:miinc} drops all models that include higher-order terms but do not include lower-order or marginal 
terms prior to all subsets estimation.  {cmd:Note:} factor variable specifications of the type i(# #..#).{it:varname} are not allowed in 
{cmd:miinc se}'s varlist as the spaces in the factor variable notation disrupt syntax parsing.  Specific levels should be included explicitly 
in {opt sets()} as #.{it:varname} #.{it:varname}..#.{it:varname}.

{marker options}{...}
{title:Options}

{phang}{opt reg(estcmd, regopts)}{cmd: (}{it:for {cmd:miinc se}}{cmd:) }specifies the regression command to be model averaged - which can include 
any user-written program.  As applied to {cmd:miinc se} user-written programs must follow the traditional {it: cmd depvar indepvars} syntax.  
{opt reg()} also allows the user to pass options for the estimation command used by {cmd:miinc}.  When a comma is added in {opt reg()}, all the 
syntax following the comma will be passed to each run of the estimation command as options. {cmd:miinc se} defaults to {opt reg(regress)} and will 
produce a warning.  

{phang}{opt reg(full estcmd with comma)}{cmd: (}{it:for {cmd:miinc me}}{cmd:) }specifies the full command to be interpreted by Stata and model averaged - 
which can also include any user-written program.  {opt reg()} is required for {cmd:miinc me} and requires a comma to be included in the command 
if there are not any {it:regopts} specified in the {it:full estcmd} in option {opt reg()}.  A comma must be included as {cmd:miinc me} uses the 
contents of {opt reg()} are used as: {cmd: "{it:contents of option reg()"} constraints({it:numlist})} directly in Stata's command prompt.  
Thus, without a comma, the {cmd:constraints({it:numlist})} is interpreted as a part of the equation specification (which will produce an error).  
Note that other {help constraint}s cannot be used with {cmd:miinc me} currently.

{phang}{opt ic(aicc | aic | bic | noic)} specifies the information criterion that {cmd:miinc} uses for model selection, averaging, and inclusion
probability.  {cmd:miinc} currently has 4 options for information criteria.  The {res}aic{txt} computed as {res}-2*(ll)+2*(parm){txt}. 
The {res}bic{txt} computed as {res}-2*(ll)+(parm)*ln((obs)){txt}.  The {res}aicc{txt} (the small sample corrected aic) computed as 
{res}-2*(ll)+2*(parm)+(2*(parm)*((parm)+1)/((obs)-(parm)-1)){txt}.  Finally, {opt ic(noic)} is a non-informative or equal weighting approach and 
only produces model averaging (i.e., cannot rank models/independent variables and thus will not produce a set of best models with 
option {opt bestomdels()} or inclusion probabilities with {opt pip}).  {cmd:miinc} defaults to {opt ic(aicc)} and will produce a warning.

{phang}{opt sets()} binds together independent variables or parameter estimates as a set in the each subset estimation. Hence, all variables in 
a set will always appear together in a model. 

{phang}The user can specify as many sets of arbitrary size as is desired and the basic syntax follows: ({it:for {cmd:miinc se}}) 
{opt sets((x1 x2) (x3 x4))}, and ({it:for {cmd:miinc me}}) {cmd:sets((}{it:eq1:x1 eq1:x2}{cmd:) (}{it:eq2:x3 eq3:x4}{cmd:))}; this will create 
two sets.  The first set (denoted "set1" in the results) will created from the variables x1 and x2 (or parameters eq1:x1 and eq1:x2) and the 
second set (denoted "set2" in the results) will be created from the variables x3 and x4 (or parameters eq2:x3 and eq3:x4).  All sets must be 
bound by parentheses - thus, each set must begin with a left paren "(" and end with a right paren ")" and all parentheses separating sets in 
the {opt sets()} option syntax must be separated by at least one space.  Independent variables in a set will receive identical information 
criterion weights (when using option {opt pip}) and will always be selected together (if using option {opt bestmodels()}).

{phang}{opt all()}{cmd: (}{it:for {cmd:miinc se}}{cmd:) } includes a set of independent variables in all models.  Thus, all independent variables included in the {opt all()} option 
appear in all the models estimated by {cmd:miinc}.  Thus, the {opt all()} option allows the user to incorporate variables about which they are 
more certain in terms of their inclusion in the model.  Consequently, variables in the {opt all()} option do not produce informative 
information criterion weights (i.e., if the {opt pip} option is used as they will {it:always} be 1).  

{phang}{opt all()}{cmd: (}{it:for {cmd:miinc me}}{cmd:) }is not a valid option as all parameters not included in the equations before the comma 
or the {opt sets()} option in {cmd:miinc me} are considered to be {opt all()} parameters and will not produce informative information 
criterion weights (i.e., if the {opt pip} option is used as they will {it:always} be 1).

{phang}{opt bestmodels()} tells {cmd:miinc} to return the number of models with the lowest information criterion differences.  The matrix returned 
by {opt bestmodels()} has the information criterion differences in its first column.  Each column that follows is associated with a coefficient 
from the {cmd:e(b)} or coefficient vector matrix.  Missing values in the {opt bestmodels()} matrix indicate that the parameter associated with the 
column in question was not in the model associeted with the row in question.

{phang}{opt pip} tells {cmd:miinc} to return a vector of inclusion probabilities for the independent variables.  The {opt pip} vector is a 
"weight of evidence" metric and shows reflects how much confidence the user can have in the the inclusion of the independent variable in the model.  
The {opt pip} metrics are, of course, relative to the best model under consideration and, consequently, do not guarantee that highly likely variables 
are necesarily in the true model.  Rather, the {opt pip} metric} simply suggests the usefulness of the independent variable (which is sometimes 
taken as an indication of variable importance).  Interaction and non-linear terms. owing to their conditioning on having the lower-order or 
marginal terms in the model, will produce {opt pip} values that are bounded by their lower-order terms.

{phang}{opt ttest} changes the test statistic distribution each coefficient in {cmd:e(b)} is tested against from the normal (i.e., "z") to the 
Student's t (i.e., "t") distribution, as is displayed in the output.  Useful for estimation commands that test against the Student's t such as 
{cmd:regress}.

{phang}{opt ll()} changes the scalar (pseudo-)log-likelihood value {cmd:miinc} looks for and substitutes into {res}(ll){txt} in the information 
criterion computations (see entry for option {opt ic()} above).  The default scalar {cmd:miinc} searches for is {cmd:e(ll)} (see {help ereturn}).

{phang}{opt parm()} changes the scalar parameter estimate count {cmd:miinc} looks for and substitutes into {res}(parm){txt} in the information 
criterion computations (see entry for option {opt ic()} above).  The default scalar {cmd:miinc} searches for is {cmd:e(rank)} (see {help ereturn}).

{phang}{opt obs()} changes the scalar observations count {cmd:miinc} looks for and substitutes into {res}(obs){txt} in the information 
criterion computations (see entry for option {opt ic()} above).  The default scalar {cmd:miinc} searches for is {cmd:e(N)} (see {help ereturn}).

{title:Final Remarks}

{phang}{cmd:miinc se} and {cmd:miinc me} are a very flexible convenience commands that can incorporate existing commands (by Stata Corp or 
user-written) to model average so long as they follow the traditional {it:depvar indepvars} format ({it:for {cmd:miinc se}}) or allow 
{help constraint}s ({it:for {cmd:miinc me}}).  Thus, most any program estimated by {help ml} or {help nl} could be model averaged using {cmd:miinc}.

{phang}For user-written commands or wrappers, {cmd:miinc se} requires that the program accept at least one optional argument and must accept an 
{help if} statement in its {help syntax} line.  {cmd:miinc me} has no such requirements, but must be compatible with {help constraint} (thus requires 
{help ml} as estimator).

{phang}{cmd:miinc} stores the {help ereturn}ed results from the full model in memory and adds to/replaces those results in memory.  Thus, most 
postestimation commands that work with the base estimation command will work with the model-averaged results returned by {cmd:miinc} (e.g., 
{help margins}, {help test}, {help predict}, etc.)

{phang}{cmd:miinc se} and {cmd:miinc me} do not directly accept the {help svy} prefix - but do accept the {cmd:svy} prefix within the {opt reg()} 
option.  When {cmd:miinc se} and {cmd:miinc me} detect the {cmd:svy} prefix, the information criterion automatically changes to {opt ic(aicw)} 
(unless {opt ic(noic)} is specified) or the rao-scott adjusted AIC and will check the command in {opt reg()} to determine whether the command returns 
the necessary matrices (i.e., {cmd:e(V)}, {cmd:e(V_srs)}, [both needed for the rao-scott adjustment] and {cmd:e(ilog)} [to obtain the 
pseudo-log-likelihood]; see {help svy_tabulate_twoway:svy: tabulate twoway} for an discussion of the adjustment; see also Scott, 2013; for the 
conceptual foundation and example #7).  In addition, {cmd:miinc se} can model average {cmd:xtgee} models using the user-written 
{stata findit qic:qic} command/metric.  To use the {cmd:qic} metric, the {stata findit qic:qic} command must be {stata ssc install qic:installed} 
and it must be included in the (opt reg() option (see example #9).  When {cmd:miinc se} detects {cmd:qic}, it automatically switches to 
{opt ic(qic)} (again, unless {opt ic(noic)} is specified).  The {cmd:qic} command will not work properly with {cmd:miinc me} and should only be 
used with {cmd:miinc se}.

{title:Introductory examples}

{phang} {cmd:webuse auto}{p_end}

{phang}Example 1: default linear regression-based model averaging with and without the (optional) "se" suffix{p_end}
{phang} {cmd:miinc price mpg rep78 headroom, ttest} {p_end}
{phang} {cmd:miinc se price mpg rep78 headroom, ttest} {p_end}
or
{phang} {cmd:miinc me (price = mpg rep78 headroom), reg(sureg (price = mpg rep78 headroom), dfk2) ttest} {p_end}
{phang} {err}{cmd:Note: cnsreg} and {cmd:glm} do not work with {cmd:miinc me} due to incompatibility in the way {cmd: miinc me} 
creates constraints and how both commands use contsraints.{txt}{p_end}

{phang}Example 2: Ordered outcome model averaging with certain "turn" variable and the BIC{p_end}
{phang} {cmd:miinc se rep78 trunk weight length, reg(ologit) ic(bic) all(turn)} {p_end}
or
{phang} {cmd:miinc me (rep78 = trunk weight length), reg(ologit rep78 trunk weight length turn,) ic(bic)} {p_end}

{phang}Example 3: Poisson model averaging with factor varaible and set{p_end}
{phang} {cmd:miinc se price weight i.rep78, reg(poisson) ic(aicc) sets((trunk turn))} {p_end}
or
{phang} {cmd:miinc me (price = weight), reg(poisson price weight ib1.rep78 trunk turn,) ic(aicc)} 
{cmd: sets((price:trunk price:turn) (price:1b.rep78 price:2.rep78 price:3.rep78 price:4.rep78 price:5.rep78))} {p_end}

{phang}Example 4: Model averaging with interaction and non-linear variables showing 10 best models {p_end}
{phang} {cmd:miinc se price c.mpg##c.headroom c.mpg#c.mpg c.headroom#c.headroom, reg(regress) bestmodels(10) ttest ic(aicc)} {p_end}

{phang}Example 5: Model averaging with posterior inclusion probability and bootstrap standard errors{p_end}
{phang} {cmd:miinc se price mpg headroom trunk turn gear_ratio foreign length weight, reg(regress, vce(bootstrap)) ttest ic(aicc) pip} {p_end}

{phang}Example 6: Seemingly unrelated regression model averaging{p_end}
{phang} {cmd:miinc me (price = mpg turn) (gear_ratio = displacement), reg(sureg (price = mpg turn) (gear_ratio = displacement),) ic(aicc)} {p_end}

{phang}Example 7: Survey regression with rao-scott adjusted AIC{p_end}
{phang} {cmd:webuse nhanes2f, clear} {p_end}
{phang} {cmd:svyset psuid [pweight=finalwgt], strata(stratid)} {p_end}
{phang} {cmd:miinc se zinc age age2 weight female black orace rural, reg(svy: glm)} {p_end}

{phang}Example 8: Multiply imputed model averaging{p_end}
{phang} {cmd:webuse mheart1s20, clear} {p_end}
{phang} {cmd:mi estimate: miinc se attack smokes age bmi hsgrad female, reg(logit) ic(aicc)} {p_end}
or
{phang} {cmd:mi estimate: miinc me (attack = smokes age bmi hsgrad female), reg(logit attack smokes age bmi hsgrad female,) ic(aicc)} {p_end}

{phang}Example 9: Generalized estimating equation model averaging{p_end}
{phang} {cmd:webuse nlswork, clear} {p_end}
{phang} {cmd:xtset id year} {p_end}
{phang} {cmd:miinc se union c_city not_smsa collgrad tenure, reg(qic)} {p_end}

{title:Saved results}

{phang}{cmd:miinc} adds/replaces the following results in {cmd: e()}:

{synoptset 16 tabbed}{...}
{p2col 5 15 19 2: scalars}{p_end}
{synopt:{cmd:e(bestic)}}information criterion value associated with the best model{p_end}
{p2col 5 15 19 2: macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}{cmd:Multi-model inference}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:miinc}{p_end}
{synopt:{cmd:e(miinc)}}{cmd:se} {it:or} {cmd:me}{p_end}
{synopt:{cmd:e(ic)}}contents of the {opt ic()} option{p_end}
{synopt:{cmd:e(reg)}}contents of the {opt reg()} option{p_end}
{synopt:{cmd:e(test)}}test type for coefficients (affected by {opt ttest}){p_end}
{synopt:{cmd:e(set#)}}independent variables or parameters included in set#{p_end}
{synopt:{cmd:e(all)}}contents of the {opt all()} option {it:or} all parameters estimated but not in equations or {opt sets()}{p_end}
{p2col 5 15 19 2: matrices}{p_end}
{synopt:{cmd:e(b)}}model-averaged coefficient vector{p_end}
{synopt:{cmd:e(V)}}model-averaged estimator variance-covariance matrix{p_end}
{synopt:{cmd:e(pip)}}posterior inclusion probability vector{p_end}
{synopt:{cmd:e(best_mods)}}best models matrix{p_end}
{p2col 5 15 19 2: functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{title:References}

{p 4 8 2}Cui, J. (2007). QIC program and model selection in GEE analyses. {it:Stata journal, 7(2)}, 209-220.{p_end}
{p 4 8 2}Burnham, K. P., & Anderson, D. R. (2002). {it:Model selection and multimodel inference: a practical information-theoretic approach}. Springer.{p_end}
{p 4 8 2}Burnham, K. P., & Anderson, D. R. (2004). Multimodel inference understanding AIC and BIC in model selection. {it:Sociological methods & research, 33(2)}, 261-304.{p_end}
{p 4 8 2}Scott, A. (August, 2013). Information criteria under complex sampling. {it:Proceedings 59th ISI World Statistics Congress}, Hong Kong (Session STS075). Rerieved from {browse "http://2013.isiproceedings.org/Files/STS075-P3-S.pdf"}.{p_end}

{title:Author}

{p 4}Joseph N. Luchman{p_end}
{p 4}Behavioral Statistics Lead{p_end}
{p 4}Fors Marsh Group LLC{p_end}
{p 4}Arlington, VA{p_end}
{p 4}jluchman@forsmarshgroup.com{p_end}
