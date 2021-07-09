{smcl}
{* *! version 1.0 July 2 2019 J. N. Luchman}{...}
{cmd:help domme}
{hline}{...}

{title:Title}

{pstd}
{ul on}Dom{ul off}inance analysis for {ul on}m{ul off}ulitple {ul on}e{ul off}quation models{p_end}

{title:Syntax}

{phang}
{cmd:domme} [{cmd:(}{it:eqname1 = paramlist1}{cmd:)} 
{cmd:(}{it:eqname2 = paramlist2}{cmd:)} ...
{cmd:(}{it:eqnameN = paramlistN}{cmd:)}] 
{ifin} {weight}{cmd:,} {opt r:eg(full_estcmd)} 
{opt f:itstat(returned_scalar | built_in_options)}
[{cmd:{ul on}s{ul off}ets( [(}
{it:eqnameS11 = paramlistS11}{cmd:)}...{cmd:(}{it:eqnameS1N = paramlistS1N}{cmd:) ]} ... 
{cmd:[ (}{it:eqnameSM1 = paramlistSM1}{cmd:)}...{cmd:(}{it:eqnameSMN = paramlistSMN}{cmd:)] )}
{cmd:{ul on}a{ul off}ll((}{it:eqname1 = paramlist1}{cmd:)}...
{cmd:(}{it:eqnameN = paramlistN}{cmd:))} 
{opt rop:ts(opts_list)}
{opt nocond:itional} 
{opt nocom:plete} 
{opt rev:erse}]

{synoptline}
{phang}{cmd:pweight}s, {cmd:aweight}s, {cmd:iweight}s, and {cmd:fweight}s are allowed but must 
be able to be used by the command in {opt reg()}, see help {help weights:weights}.  
{help Time series operators} are also allowed for commands in {opt reg()} that accept them.  
Finally, {help Factor variables} are also allowed, but like weights and time series operators, 
must be accepted by the command in {opt reg()}.

{phang}{cmd:domme} requires installation of Ben Jann's {cmd:moremata} package 
(install here: {stata ssc install moremata}).  Users are strongly encouraged to install 
{stata ssc install domin:domin} as well and read over its help file for basic information on 
dominance analysis.

{title:Description}

{pstd}
Dominance analysis for mulitple equation models is an extention of standard dominance analysis 
(see {help domin}) which focuses on finding the relative importance 
of parameter estimates in an estimation model based on contribution of each parameter 
estimate to an overall model fit statistic (see Luchman, 2019 for a discussion).  
As an extension of standard dominance analysis, it is recommended that the user 
familiarize themselves with standard dominance analysis before attempting to use the 
multiple equation version of the methodology.

{pstd}
Dominance analysis for mulitple equation models differs from standard dominance analysis
primarily in how the ensemble of fit metrics are collected.  Standard dominance analysis 
obtains the ensemble of fit metrics to compute dominance statistics by including or 
excluding independent variables from a statistical model.  Dominance analysis for mulitple 
equation models obtains the ensemble of fit metrics to compute dominance statistics by 
using {help constraint}s which permit each parameter estimate to be estimated from the 
data or constrained to zero in a given statistical model.  Constraining a parameter estimate to 
zero effectively omits the parameter from estimation and it cannot contribute to model fit.

{title:Set-up}

{pstd}
{cmd:domme} requires that all parameters to be dominance analyzed are written out in the 
initial {res:(eqname = paramlist)} statements.  {cmd:domme} will use the {res:(eqname = paramlist)} 
statements (similar to those of commands like {help sureg}) to create parameter statements that 
it will produce {help constraint:constraints} from.  Each entry in {res:paramlist} is given a 
separate constraint with the associated {res:eqname}.  For example, the statement:

{pstd}
{res:(price = mpg turn trunk foreign)}

{pstd}
will create the series of four parameters:

{pstd}
{res:_b[price:mpg] _b[price:turn] _b[price:trunk] _b[price:foreign]}

{pstd}
such parameters would be produced by a model like {cmd:glm price mpg turn trunk foreign}

{pstd}Note that the current version of {cmd:domme} does not check to ensure that the 
parameters supplied it are in the model and it is the user's responsibility to ensure that the lists 
supplied are valid parameters in the estimated model.  

{marker options}{...}
{title:Options}

{phang}{opt reg(full_estcmd)} refers {cmd:domme} to a command that accepts {help constraint}s, 
uses {help ml} to estimate parameters, and that can produce the scalar in the {opt fitstat()} option.  
{cmd:domme} is quite flexible and can be applied to any built-in or user-written 
{help program}.  

{pmore}The {it:full_estcmd} is the full estimation command, not including options following the 
comma, as would be submitted to Stata.  The {opt reg()} option has no default and the user is 
required to provide a valid statistical model.

{phang}{opt f:itstat(returned_scalar | built_in_options)} refers {cmd:domme} to ascalar valued 
model fit summary statistic used to compute all dominance statistics.  The scalar in 
{opt fitstat()} can be any {help return:returned}, {help ereturn:ereturned}, or other 
{help scalar:scalar} produced by the estimation command in {opt reg()}.

{pmore}In addition to fit statistics produced by the estimation command in {opt reg()}, {cmd:domme} 
also allows several built-in model fit statistics to be computed using the model log-likelihood and
degrees of freedom.  Four fit statistics are available using the built-in options for {cmd:domme}. 
These options are the McFadden pseudo-R squared ({res:mcf}), the Estrella pseudo-R squared 
({res:est}), the Akaike information criterion ({res:aic}), and the Bayesian information criterion 
({res:bic}).

{pmore}To instruct {cmd:domme} to compute a built-in fit statistic, supply the {opt fitstat()} option 
with an empty ereturned statistic indicator (i.e., {res:e()}) and provide the three character code 
for the desired fit statistic.  For example, to ask {cmd:domme} to compute McFadden's pseuod-R 
square as a fit statistic, type {res:fitstat(e(), mcf)}.  Note that {cmd:domme} has no default 
and the user is required to provide a valid fit statistic.

{phang}{opt sets()} binds together parameter estimates as a set in the all possible combinations 
ensemble. Hence, all parameter estimates in a set will always appear together and are considered a 
single parameter estimate in the all possible combinations ensemble. 

{pmore}{opt sets()} are generated in a way similar to that of the initial statements to {cmd:domme} 
in that a series of {res:(eqname = paramlist)} statements must be provided and then bound together
to produce a set.  Any set of {res:(eqname = paramlist)} in a single set must be bound by brackets 
"{res:[]}".  For example, consider again the model {cmd:glm price mpg turn trunk foreign}.  To 
produce two sets of parameters, one that includes {it:mpg} and {it:turn} as well as a second that 
includes {it:trunk} and {it:foreign}, the {opt sets()} type {res:sets( [(price = mpg turn)]} 
{res:[(price = trunk foreign)] )}.  

{pmore}This above {opt sets()} statement is rather simple and refers to single equations within 
a model.  A single set can include parameters from multiple equations - in fact, doing so is 
how independent variable dominance statistics can be computed in {cmd:domme} ... note re: independent variables ...

{phang}{opt all()} defines a set of parameter estimates to be included in all the combinations in the 
ensemble.  Thus, all parameter estimates included in the {opt all()} option are effectively used 
as of covariates which are to be included in the model fit metric, but for which dominance 
statistics will not be computed.  Thus, the magnitude of the overall fit statistic associated 
with the set of parameter in the {opt all()} option are subtracted from overall fit metric prior 
to the computation of dominance statistics for all the parameter estimiates to be dominance 
analyzed. ...note this is how to take them out of the constant...

{pmore}The {opt all()} statements are set up in a way identical to that of the initial statments 
in a {res:(eqname = paramlist)} format.

{phang}{opt ropts()} supplies the command in {opt reg()} with any relevant estimation options.  
Any options formally following the comma in standard Stata syntax, besides {opt constraints()}, 
can be supplied to the statisical model this way.  

{phang}{opt noconditional} suppresses the computation and display of of the conditional dominance 
statistics.  Suppressing the computation of the conditional dominance statistics can save 
computation time when conditional dominance statistics are not desired.  Suppressing the 
computation of conditional dominance statistics also suppresses the 
"strongest dominance designations" list.

{phang}{opt nocomplete} suppresses the computation of the complete dominance designations.  
Suppressing the computation of the complete dominancedesignations can save computation time 
when complete dominance designations are not desired.  Suppressing the computation of 
complete dominance designations also suppresses the "strongest dominance designations" list.

{phang}{opt reverse} reverses the interpretation of all dominance statistics in the 
{cmd:e(ranking)} vector, {cmd:e(cptdom)} matrix, fixes the computation of the 
{cmd:e(std)} vector, and the "strongest dominance designations" list.  
{cmd:domin} assumes by default that higher values on overall fit statistics constitute 
better fit, as dominance analysis has historically been based on the explained-variance R2 metric.  
However, dominance analysis can be applied to any model fit statistic 
(see Azen, Budescu, & Reiser, 2001 for other examples).  {opt reverse} is then useful 
for the interpetation of dominance statistics based on overall model fit statistics 
that decrease with better fit (e.g., the built in AIC, BIC statistics).

{title:Final Remarks}

{pstd}Any parameter estimates in the model but not in either the initial syntax for 
to dominance analyze, the {opt sets()} option, or the {opt all()} option are assumed to act as 
a part of the model constant and are in some cases ignored in computing the model fit statistic.  
Thus, any parameter estimate not included in some modeling statement will be treated like a 
regression constant in most regression models; that is, as a baseline against which the 
full model is compared in terms of the log likelihood.  "Constant" parameters are omitted entirely 
from fit statistic computations for the built in {res:mcf} and {res:est} options but are 
reported as a part of the constant model fit statistic for the {res:aic} and {res:bic} 
options in {opt fitstat()}.

{pstd}When not using the built-in options, it is the responsibility of the user to supply 
{cmd:domme} with an overall fit statistic that can be validly dominance analyzed.  Non-R2 
overall fit statistics can be used however {cmd:domme} assumes that the fit statistic supplied 
{it:acts} like an R2 statistic.  Thus, {cmd:domin} assumes that better model fit is associated 
with increases to the fit statistic and all marginal contributions can be obtained by subtraction.  
For model fit statistics that decrease with better fit (i.e., AIC, BIC, deviance), the 
interpretation of the dominance relationships need to be reversed (see Example #2).  

{title:Introductory examples}

{phang} {cmd:webuse auto}{p_end}

{phang}Example 1: Path analysis/seemingly unrelated regression (SUR) with built in McFadden pseudo-R squared{p_end}
{phang} {cmd:sureg (price = length foreign gear_ratio) (headroom = mpg)} {p_end}
{phang} {cmd:domme (price = length foreign gear_ratio) (headroom = mpg), reg(sureg (price = length foreign gear_ratio) (headroom = mpg)) fitstat(e(), mcf)} {p_end}

{phang}Example 2: Zero-inflated Poisson with built in BIC{p_end}
{phang} {cmd:generate zi_pr = price*foreign} {p_end}
{phang} {cmd:zip zi_pr headroom trunk,inflate(gear_ratio turn)} {p_end}
{phang} {cmd:domme (zi_pr = headroom trunk) (inflate = gear_ratio turn), reg(zip zi_pr headroom trunk) f(e(), bic) ropt(inflate(gear_ratio turn)) reverse} {p_end}

{phang}Example 3: Path analysis/SUR model with all option {p_end}
{phang} {cmd:sem (foreign <- headroom) (price <- foreign length weight) (weight <- turn)} {p_end}
{phang} {cmd:estat ic} {p_end}
{phang} {cmd:domme (price = length foreign) (foreign = headroom), all((price = weight) (weight = turn)) reg(sem (foreign <- headroom) (price <- foreign length weight) (weight <- turn)) fitstat(e(), aic) reverse} {p_end}

{phang}Example 4: Generalized negative binomial with all and parmeters treated as _cons in the dominance analysis (i.e., _b[price:foreign]) {p_end}
{phang} {cmd:gnbreg price foreign weight turn headroom, lnalpha(weight length)} {p_end}
{phang} {cmd:domme (price = turn headroom) (lnalpha = weight length), reg(gnbreg price foreign weight turn headroom) f(e(), mcf) ropt(lnalpha(weight length)) all( (price = weight) )} {p_end}

{phang}Example 5: Generalized structural equation model with factor variables{p_end}
{phang} {cmd:webuse nlsw88, clear} {p_end}
{phang} {cmd:gsem (wage <- union hours, regress) (south <- age ib1.race union, logit)} {p_end}
{phang} {cmd:domme (wage = union hours) (south = age union 2.race 3.race), reg(gsem (wage <- union hours, regress) (south <- age ib1.race union, logit)) fitstat(e(), mcf)}{p_end}

{phang}Example 6: Generalized structural equation model with sets to evaluate independent variables{p_end}
{phang} {cmd:gsem (south smsa union <- wage tenure ttl_exp, logit)} {p_end}
{phang} {cmd:domme, reg(gsem ( south smsa union <- wage tenure ttl_exp, logit)) sets( [(south = wage) (smsa = wage) (union = wage)] [(south = tenure) (smsa = tenure) (union = tenure)] [(south = ttl_exp) (smsa = ttl_exp) (union = ttl_exp)])} 
{cmd:fitstat(e(), mcf)} {p_end}



{title:Saved results}

{phang}{cmd:domme} saves the following results to {cmd: e()}:

{synoptset 16 tabbed}{...}
{p2col 5 15 19 2: scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(fitstat_o)}}overall fit statistic value{p_end}
{synopt:{cmd:e(fitstat_a)}}fit statistic value associated with variables in {opt all()}{p_end}
{synopt:{cmd:e(fitstat_c)}}fit statistic value computed by default when the constant model is non-zero{p_end}
{p2col 5 15 19 2: macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}{cmd:Dominance analysis for multiple equations}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:domme}{p_end}
{synopt:{cmd:e(fitstat)}}contents of the {opt fitstat()} option{p_end}
{synopt:{cmd:e(reg)}}contents of the {opt reg()} option (before comma){p_end}
{synopt:{cmd:e(regopts)}}contents of the {opt reg()} option (after comma){p_end}
{synopt:{cmd:e(properties)}}{cmd:b}{p_end}
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

{p 4 8 2}Luchman, J. N., Lei, X., and Kaplan, S. A. (2019/forthcoming). Relative importance analysis with multivariate models: Shifting the focus from independent variables to parameter estimates. {it:SAGE Open, x(x)}, 1–10.{p_end}

{title:Author}

{p 4}Joseph N. Luchman{p_end}
{p 4}Senior Scientist{p_end}
{p 4}Fors Marsh Group LLC{p_end}
{p 4}Arlington, VA{p_end}
{p 4}jluchman@forsmarshgroup.com{p_end}
