{smcl}
{* *! version 1.0  29jan2019}{...}
{cmd:help xtlhazard} 
{hline}

{title:Title}

{p2colset 5 20 22 2}{...} {phang} {bf:xtlhazard} {hline 2} Adjusted First-Differences Estimation of the Linear Discrete-Time Hazard Model{p_end} {p2colreset}{...} 

{title:Syntax}

{p 8 17 2} {cmd:xtlhazard} {it:{help varname:depvar}} {it:{help varname:indepvars}} {ifin} {weight} [, {cmd:}{it:{help xtlhazard##options:options}}] 


{synoptset 28 tabbed}{...}
{marker Variables}{...}
{synopthdr :Variables}
{synoptline}
{synopt :{it:{help varname:depvar}}}binary variable indicating absorbing state{p_end}
{synopt :{it:{help varname:indepvars}}}explanatory variables{p_end}

{synoptset 28 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Model}
{synopt :{opt {ul on}d{ul off}ifference(#)}}set order of differencing; {opt difference(1)} that is first-differences is the default{p_end}
{synopt :{opt {ul on}noabsorb{ul off}ing}}forces estimation if {it:depvar} is inconsitent with model{p_end}
{synopt :{opt {ul on}tol{ul off}erance(#)}}set tolerance for {it:luinv()}; {opt tolerance(3)} is the default{p_end}
{synopt :{opt edittozero(#)}}use Mata function {it:edittozero()} to set matrix entries close to zero to zero;  {opt edittozero(0)} that is no editing is the default{p_end}

{syntab :SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt mo:del} [, {opt f:orce}], or {opt ols}; {opt vce(robust)} is the default{p_end}

{marker Reporting}{...}
{syntab :Reporting}
{synopt :{opt noeomit:ted}}do not consider omitted collinear variables in {hi:e(b)} and {hi:e(V)}{p_end}
{synopt :{opt lev:el(#)}}set confidence level; default as set by set level{p_end}
{synopt :{opt noci}}suppress confidence intervals{p_end}
{synopt :{opt nopv:alues}}suppress p-values and their test statistics{p_end}
{synopt :{opt noomit:ted}}do not display omitted collinear variables{p_end}
{synopt :{opt vsquish}}suppress blank space separating factor variables or time-series variables{p_end}
{synopt :{opt noempty:cells}}do not display empty interaction cells of factor variables{p_end}
{synopt :{opt basel:evels}}display base levels of factor variables{p_end}
{synopt :{opt allbase:levels}}display all base levels for factor variables and interactions{p_end}
{synopt :{opt nofvlab:el}}display factor-variable level values rather than value labels{p_end}
{synopt :{opt fvwrap(#)}}allow # lines when wrapping long value labels{p_end}
{synopt :{opt fvwrapon(style)}}apply {it:style} for wrapping long value labels; {it:style} may be {opt word} or {opt width}{p_end}
{synopt :{opt cformat(%fmt)}}format for coefficients, standard errors, and confidence limits{p_end}
{synopt :{opt pformat(%fmt)}}format for p-values{p_end}
{synopt :{opt sformat(%fmt)}}format for test statistics{p_end}
{synopt :{opt nolstretch}}do not automatically widen coefficient table for long variable names{p_end}

{syntab :Generate}
{synopt :{opth ie:ffect(newvar)}}generate variable {it:newvar} containing estimated individual fixed-effects{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}The data needs to be {cmd:xtset} before using {cmd: xtlhazard}, {it:timevar} needs to be specified; see {helpb xtset:[XT] xtset}.{p_end}
{p 4 6 2}{it:indepvars} may contain factor variables and and time-series operators; see {help fvvarlist} and {help tsvarlist}. factor variables and and time-series operators are not allowed for {it:depvar}.{p_end}
{p 4 6 2}{cmd:bootstrap} is allowed, {cmd:by} and {cmd:svy} are not allowed; see {helpb prefix:[U] prefix}.{p_end}
{p 4 6 2}{opt pweight}s, {opt fweight}s, {opt aweight}s and {opt iweight}s are allowed, with {opt pweight} being the default.{p_end}
{p 4 6 2}Many standard postestimation commands, such as {cmd:predict}, {cmd:margins}, {cmd:test}, {cmd:testnl}, {cmd:lincom}, and {cmd:nlcom} are available; see {helpb regress_postestimation :[R] regress postestimation}.
{cmd:predict}, {opt res} is not allowed; use {cmd:predict}, {opt score} for obtaining residuals.{p_end} 


{title:Description}

{pstd}{cmd:xtlhazard} implements the adjusted first-differences estimator for the linear discrete-time hazard model proposed by Tauchmann (2019). This procedure addresses the issue that,
conventional linear fixed-effects panel estimators (within-transformation, first-differences; see {helpb xtreg:[XT] xtreg}), 
fail to eliminate unobserved time-invariant heterogeneity and are biased and inconsistent if {it:depvar} is a binary dummy indicating an absorbing state.
This even applies if the unobserved time-invariant heterogeneity is uncorrelated with the regressors in the population. 
Besides conventional survivor bias - from which also pooled OLS suffers even if the unobserved heterogeneity is uncorrelated with the regressors - these estimators suffer from a second source of bias.
This second bias, which is severe in many settings, originates from the transformation of the data itself und is present even in the absence of any unobserved heterogeneity. 
The adjusted first-differences estimator eliminates this second source of bias and confines the asymptotic bias to survivor bias under the assumption
that the unobserved heterogeneity is uncorrelated with changes in the regressors in the population, while allowing for correlations with their levels. 
Technically, {cmd:xtlhazard} rescales the coefficients from unadjusted first-differences estimation (with constant terms) by the matrix {it:inv(I+inv(d.X'd.X)*d.X'l.X)}, which ('s transpose) is stored in {hi:e(Adjust)}.
By specifying the option {opt difference(#)}, one makes the estimation procedure use higher-order rather than first-differences.
This allows confining the asymptotic bias to survivor bias under the alternative assumption of unobserved heterogeneity being uncorrelated with higher-order differences of the explanatory variables.


{marker variables}{...}
{title:Variables}

{dlgtab:Dependent Variable}

{phang} {it:depvar} needs to be a binary (either numeric or string) indicator.
Its (alphanumerically) smaller value indicates that a unit is still at risk, while the (alphanumerically) larger value indicates that the absorbing state is reached. 
A 0/1 indicator is hence the most obvious choice for coding {it:depvar}.
Sequences of {it:depvar}, observed at the individual level, such as {it:0,..,0,1} and {it:0,..,0,0} are consistent with the data generating process that is assumed by {cmd:xtlhazard}. 
This also applies to sequences of the form {it:0,..,0,1,..,1}. Yet, for a sequence of this type, observations for periods later than the first occurrence of 1 do not enter the estimation procedure. 
Sequences like {it:0,1,0,...} or {it:1,0,1,...} are inconsistent with the assumed DGP. Here {it:depvar} = 1 is not an absorbing state and {cmd:xtlhazard} is an inappropriate estimation routine.
{cmd:xtreg} ...,{opt fe} or {cmd:regress} {opt D}.(...) are supposedly better suited.
For this reason {cmd:xtlhazard} breaks and returns an error message if {it:depvar} is recognized to indicate a (potentially) repeated event, unless the option {opt noabsorbing} is specified.


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang} {opt difference(#)} specifies the order of the differences-transformation that is applied to the variables. 
The default is {opt difference(1)} that is taking first differences. {opt difference(2)} makes {cmd:xtlhazard} take differences of differences, {opt difference(3)} induces taking differences of differences of differences, et cetera.
While considering higher-order differences allows for estimation under alternative, presumably weaker, assumptions, it makes the identification rest on very little variation. This may result in imprecisely estimated and potentially misleading coefficients. 

{phang} {opt noabsorbing} forces {cmd:xtlhazard} to produce estimation results even if the observed distribution of {it:depvar} is inconsistent with using a hazard model; see {cmd:}{it:{help xtlhazard##variables:variables}}.
In this case, {cmd:xtlhazard} is most likely severly biased and represents an inappropriate estimation procedure. Users are hence strongly discouraged from specifying {opt noabsorbing} in serious empirical applications. 
If {opt noabsorbing} is specified and the data are inconsistent with data generating process assumed by {cmd:xtlhazard}, a warning is issued and the value 1 is saved in {cmd:e(irregular)}.
If {opt noabsorbing} is specified and {it:depvar} is consistent with the assumed data generating process, {cmd:e(irregular)} saves the value 0.

{phang} {opt tolerance(#)} temporarily sets the {help [M-1] tolerance:tolerance} level for the Mata functions {help mf_luinv:luinv()} and {help mf_rank:rank()}.
The tolerance level matters, since the adjusted first-differences estimator does not exist if {it:(I+inv(d.X'd.X)*d.X'l.X)} is singular. 
Due to numeric imprecision, there will always by a (small) numerical deviation from singularity. 
{opt tolerance(#)} determines how big this deviation must be in order to regard {it:(I+inv(d.X'd.X)*d.X'l.X)} nonsingular; see {helpb [M-1] tolerance:[M-1] tolerance}. 
The default value used by {cmd:xtlhazard} is 3, which is less generous in assuming nonsingularity than Mata's standard default level of 1.  
If according to the specified tolerance level {it:(I+inv(d.X'd.X)*d.X'l.X)} is singular, {cmd:xtlhazard} breaks and issues an error message.
If this happens, rerunning {cmd:xtlhazard} with {opt tolerance(0)} may help in figuring out which variable(s) cause the problem. 
With {opt tolerance(0)}, {cmd:xtlhazard} will produce some results.
Extremely large reported coefficients and standard errors may indicate which variable(s) render(s) {it:(I+inv(d.X'd.X)*d.X'l.X)} (almost) singular.

{phang} {opt edittozero(#)} invokes the Mata function {opt edittozero()} to set entries in the adjustment matrix and in its inverse, which are close to zero, to zero; see {helpb mf_edittozero:[M-5] edittozero()}.
In certain settings, some entries are known to be zero but deviate from this value in empirical applications due to numerical imprecision. One may exploit the margin for improving precision by specifying {opt edittozero()}.
Yet, this gain in precision is likely to be negligible.   


{dlgtab:SE/Robust}

{phang} {opt vce(vcetype)} specifies the method used for estimating standard errors. {opt robust}, {opt cluster} {it:clustvar}, {opt model} [, {opt force}], and {opt ols} are available as {it:vcetype}.
The default ist {opt robust}. With {it:vcetype} {opt robust}, {cmd:xtlhazard} calculates a Huber-White covariance matrix for unadjusted first-differences estimation and adjusts it appropriately using {it:inv(I+inv(d.X'd.X)*d.X'l.X)}.
{it:vcetype} {opt cluster} {it:clustvar} proceeds in the same way, yet is calculates cluster robust standard errors for the unadjusted coefficients.
Theory does not suggest clustering at the level of {it:panelvar}, since according to the assumed DGP the errors are serially uncorrelated.
{it:vcetype} {opt model} estimates standard errors taking the type of heteroscedasticity into account that is inherent to the assumed DGP.
This will rarely succeed in practice, because of some estimated error variances taking negative values.
One may force {cmd:xtlhazard} to calculate {opt model} standard errors by specifying {opt vce(model, force)}. This makes {cmd:xtlhazard} set negative variance estimates to the value of zero.
This is likely to result in severely underestimated standard errors. Using {it:vcetype} {opt model} is hence not recommended.
This also applies to {it:vcetype} {opt ols}, which ignores the heteroscedasticity inherent to any linear probability model. 
{cmd:xtlhazard} does not include an internal bootstrapping routine.
Yet the prefix command {cmd:bootstrap} still allows obtaining bootstrap standard errors. When using {cmd:bootstrap} clustering at the level of {it:panelvar} is essential.
I.e. the {cmd:bootstrap} options {opt cluster()} and {opt idcluster()} are required.


{dlgtab:Reporting}

{phang} {opt noeomitted} makes {cmd:xtlhazard} ignore omitted collinear variables and empty cells in {hi:e(b)}, {hi:e(V)}, {hi:e(Adjust)}, and {hi:e(invAdjust)}.
By default, as it is the standard for stata's estimation routines, the matrices saved in {hi:e()} contain columns of zeroes if the model includes collinear variables.
With factor variables in {it:indepvars}, this will regularly be the case. While this is no obstacle to using stata's postestimation commands, matrix algebra using these matrices may be hampered.
For instance, one can retrieve the coefficients and the covariance matrix of unadjusted first-differences estimation as {hi:e(b)*inv(e(Adjust))} and {hi:inv(e(Adjust))'*e(V)*inv(e(Adjust))}.
This will, however, not work if {hi:e(Adjust)} includes columns and rows of zeroes, since its (regular) inverse then does not exist.{p_end}

{phang}See {helpb estimation options##level():[R] estimation options} for a more detailed description of the {cmd:}{it:{help xtlhazard##Reporting:display_options}} listed above.
They are essentially the same as for {cmd:}{it:{help ereturn##display_options:eretun display}}, to which they are passed through. Maximum likelihood related reporting options are not available since {cmd:xtlhazard} is not an ML estimator.


{dlgtab:Generate}

{phang} {opt ieffects(newvar)} generates the new variable {it:newvar} that contains estimates of individual fixed effects. Individual fixed effects are estimated as group means of residuals.


{title:Example}

{pstd}Load Stata example data set {it:cancer.dta}.{p_end}
{phang2}{cmd:. sysuse cancer, clear}{p_end}

{pstd}Bring data in panel format required for using {cmd:xtlhazard}; see {manlink  ST discrete}, {helpb stset:[ST] stset}, and {helpb stsplit:[ST] stsplit}.{p_end}
{phang2}{cmd:. gen id = _n}{p_end}
{phang2}{cmd:. stset studytime, failure(died) id(id)}{p_end}
{phang2}{cmd:. stsplit nt, every(1)}{p_end}

{pstd}{cmd:xtset} data.{p_end}
{phang2}{cmd:. xtset id _t}{p_end}
 
{pstd}Use {cmd:xtlhazard} to estimate quadratic baseline hazards as deviation from placebo group.{p_end}
{phang2}{cmd:. xtlhazard _d i(2 3).drug#c._t i.drug#c._t#c._t}{p_end} 
{pstd}Same as above with bootstrapped standard errors.{p_end}
{phang2}{cmd:. gen _id = id}{p_end}
{phang2}{cmd:. bootstrap, cluster(_id) idcluster(id): xtlhazard _d i(2 3).drug#c._t i.drug#c._t#c._t}{p_end}


{title:Saved results}

{pstd}
{cmd:xtlhazard} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations (excluding waves eliminated by taking differences){p_end}
{synopt:{cmd:e(N_g)}}number of groups (cross-sectional units in panel){p_end}
{synopt:{cmd:e(difference)}}order of differencing{p_end}
{synopt:{cmd:e(chi2)}}model chi-squared{p_end}
{synopt:{cmd:e(p)}}model significance, p-value{p_end}
{synopt:{cmd:e(r2)}}pseudo R-squared for differences (variance of differenced predictions over variance of {it:depvar}){p_end}
{synopt:{cmd:e(r2_a)}}adjusted pseudo R-squared (differences){p_end}
{synopt:{cmd:e(r2_lev)}}pseudo R-squared for levels (variance of predictions over variance of {it:depvar}){p_end}
{synopt:{cmd:e(r2_a_lev)}}adjusted pseudo R-squared (levels){p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(rank)}}rank of inverse adjustment matrix{p_end}
{synopt:{cmd:e(tolerance)}}tolerance level for {it:luinv()} and {it:rank()}{p_end}
{synopt:{cmd:e(level)}}confidence level{p_end}
{synopt:{cmd:e(irregular)}}indicator saved with option {opt noabsorbing}: 0 if {it:depvar} is regular, 1 if {it:depvar} is irregular, -1 if {it:depvar} is regular but obs after absorbing state is reached enter estimation sample{p_end}
{synopt:{cmd:e(wgtsum)}}sum of weights (only saved if weights are specified){p_end}
{synopt:{cmd:e(N_clust)}}number of clusters (only saved with {it:vcetype} {it:cluster}){p_end}

{synoptset 20 tabbed}{...} {p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(tvar)}}name of {it:timevar}{p_end}
{synopt:{cmd:e(ivar)}}name of {it:panelvar}{p_end}
{synopt:{cmd:e(marginsok)}}predictions allowed by {opt margins}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {opt predict}{p_end}
{synopt:{cmd:e(chi2type)}}{hi:Wald}{p_end}
{synopt:{cmd:e(depvar)}}name of {it:depvar}{p_end}
{synopt:{cmd:e(vcest)}}{it:vcetype} specified in {opt vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(wtype)}}weight type (only saved if weights are specified){p_end}
{synopt:{cmd:e(wexp)}}= {it:weight expression} (only saved if weights are specified){p_end}
{synopt:{cmd:e(title)}}{cmd:Adjusted first-differences linear discrete-time hazard estimation}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:xtlhazard}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {opt predict}{p_end}
{synopt:{cmd:e(properties)}}{opt b V}{p_end}

{synoptset 20 tabbed}{...} {p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of estimated coefficients{p_end}
{synopt:{cmd:e(V)}}estimated coefficient variance-covariance matrix{p_end}
{synopt:{cmd:e(Adjust)}}adjustment matrix, i.e. {it:inv(I+inv(d.X'd.X)*d.X'l.X)'} for first-differences{p_end}
{synopt:{cmd:e(invAdjust)}}inverse adjustment matrix, i.e. {it:(I+inv(d.X'd.X)*d.X'l.X)'} for first-differences{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample (first period not included){p_end}
{p2colreset}{...}


{title:References}
 
{pstd} Tauchmann, H. (2019). {browse "https://www.stata.com/meeting/germany19/slides/germany19_Tauchmann.pdf":Linear discrete time hazard estimation using Stata}, presentation at the {it:2019 German Stata Users Group Meeting}.

{pstd} Tauchmann, H. (2019). Fixed Effects Estimation of the Discrete-Time Linear-Probability Hazard Model: an Adjusted First-Differences Estimator, 
{it:FAU Discussion Papers in Economics} {browse "https://www.iwf.rw.fau.de/files/2019/11/09_2019.pdf":#9/2019}.


{title:Also see}

{psee} Manual:  {manlink R regress}, {manlink ST discrete}, {manlink ST stcox}, {manlink ST streg}, {manlink ST stset}, {manlink ST stsplit}, {manlink XT xtreg}, {manlink XT xtset}

{psee} {space 2}Help:  {manhelp regress R:regress}, {manhelp stcox ST:stcox}, {manhelp streg ST:streg}, {manhelp stset ST:stset}, {manhelp stsplit ST:stsplit}, {manhelp xtreg XT:xtreg}, {manhelp xtset XT:xtset}{break} 

{psee} Online:   {helpb dthaz}, {helpb hshaz}, {helpb pgmhaz8}{p_end} 


{title:Author}

{psee} Harald Tauchmann{p_end}{psee} Friedrich-Alexander-Universit{c a:}t Erlangen-N{c u:}rnberg (FAU){p_end}{psee} N{c u:}rnberg, 
Germany{p_end}{psee}E-mail: harald.tauchmann@fau.de {p_end}


{title:Disclaimer}
 
{pstd} This software is provided "as is" without warranty of any kind, either expressed or implied. The entire risk as to the quality and 
performance of the program is with you. Should the program prove defective, you assume the cost of all necessary servicing, repair or 
correction. In no event will the copyright holders or their employers, or any other party who may modify and/or redistribute this software, 
be liable to you for damages, including any general, special, incidental or consequential damages arising out of the use or inability to 
use the program.{p_end} 


{title:Acknowledgements}

{pstd} I gratefully acknowledge comments and suggestions by Helene K{c o:}nnecke, Sabrina Schubert, Irina Simankova and the participants of the 2019 German Stata Users Group Meeting.{p_end} 
