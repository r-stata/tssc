{smcl}
{* *! version 1.1  5nov2019}{...}
{cmd:help stackreg} and {cmd:xtstackreg}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...} {phang} {bf:stackreg} and {bf:xtstackreg} {hline 2} Stacked linear regression analysis to facilitate testing of multiple hypotheses{p_end} {p2colreset}{...} 

{title:Syntax}

{p 10 17 2} {cmd:stackreg} {it:{help varlist:depvars}} = {it:{help varlist:indepvars}} {ifin} {weight} [, {cmd:}{it:{help stackreg##options:options}}] 

{p 8 17 2} {cmd:xtstackreg} {it:{help varlist:depvars}} = {it:{help varlist:indepvars}} {ifin} {weight} [, {cmd:}{it:{help stackreg##options:options}}] 


{synoptset 28 tabbed}{...}
{marker Variables}{...}
{synopthdr :Variables}
{synoptline}
{syntab :Model}
{synopt :{it:{help varname:depvars}}}left-hand-side variables{p_end}
{synopt :{it:{help varname:indepvars}}}right-hand-side variables{p_end}

{synoptset 28 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Main}
{synopt :{opt {ul on}nocons{ul off}tant}}suppress constant term{p_end}
{synopt :{opt {ul on}c{ul off}onstraints}{bf:(}{help numlist:{it:numlist}}{bf:)}}apply specified linear constraints{p_end}
{synopt :{opt {ul on}nocom{ul off}mon}}keep observations with any non-missing values in {it:depvars}{p_end}

{syntab :Panel Data}
{synopt :{opt {ul on}fe{ul off}}}apply within-transformation to {it:depvars} and {it:indepvars} (equiv. to using {cmd:xtstackreg}){p_end}

{syntab :SE/Inference}
{synopt :{opt clu:ster}{bf:(}{help varlist:{it:clustvarlist}}{bf:)}}estimate clustered standard errors (level of clustering higher than obs. unit){p_end}
{synopt :{opt df}{bf:(}{it:dftype}{bf:)}}degrees-of-freedom adjustment ({it:dftype} may be {bf:adjust}, {bf:raw}, or {bf:areg}){p_end}
{synopt :{opt w:ald}}use Wald- instead of of F-test after {cmd:stackreg}{p_end}

{syntab :Speed}
{synopt :{opt {ul on}sr{ul off}eshape}}use {cmd:sreshape} to increase speed{p_end}

{syntab :Reporting}
{synopt :{opt lev:el(#)}}set confidence level; default as set by set level{p_end}
{synopt :{opt edit:tozero(#)}}edit coefficient covariance matrix for roundoff error (zeros); see mata {help mf_edittozero:edittozero()}{p_end}
{synopt :{opt omit:ted}}display omitted collinear variables{p_end}
{synopt :{opt empty:cells}}display empty cells for interactions of factor variables{p_end}
{synopt :{help regress##display_options :{it:display_options}}}further options for displaying output{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{it:depvars} and {it:indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}{help ereturn##display_options :{it:display_options}} are those available for {cmd:ereturn display}.{p_end}
{p 4 6 2}The prefix commands {cmd:bootstrap} and {cmd:jackknife} are allowed; {cmd:by} and {cmd:svy} are not allowed; see {help prefix}.{p_end}
{p 4 6 2}
{opt aweight}s, {opt fweight}s, {opt iweight}s, and {opt pweight}s are allowed, {opt pweight}s is the default; see {help weight}.{p_end}
{p 4 6 2}The available postestimation commands are (almost) the same as for {cmd:regress}; see 
{help regress_postestimation :regress postestimation}.{p_end}
{p 4 6 2}{cmd:predict} and {cmd:margins} behave in the same way as they behave after {cmd:mvreg}; see {help mvreg_postestimation :mvreg postestimation}.{p_end} 


{title:Description}

{pstd} {cmd:stackreg} implements the stacked regression analysis which facilitates statistical testing in a multiple testing framework.
The stacked regression approach was suggested e.g. by Weesie (1999) and Pei et al. (2019).
{cmd:stackreg} is closely realted to the real Stata command {cmd:}{help suest}. 
Unlike {cmd:suest}, which is extremely flexible in allowing inference involving regression models of different type, {cmd:stackreg} is confined to the linear model.
However, in the context of the linear model, {cmd:stackreg} is more flexible than {cmd:suest} in several respects.
In detail: (i) {cmd:stackreg} accomodates multi-way clustering (Cameron et al., 2011), 
if the community-distributed command {cmd:}{help cgmreg} (by Jonah B. Gelbach and Douglas L. Miller) is installed;
(ii) {cmd:stackreg} allows imposing cross-equation constraints by specifying the option {opt constraints()};
(iii) {cmd:stackreg} is a panel data command that accomodates fixed-effects estimation;
(iv) unlike {cmd:suest}, {cmd:stackrg} applies a degrees-of-freedom adjustment that exactly reproduces the standard errors equation-by-equantion estimation yields; 
(v) {cmd:stackreg} allows for factor-variables in {it:depvars}.
{cmd:stackreg} can also be regared as more robust alternative to {cmd:}{help sureg} and {cmd:}{help mvreg} in particular.
Whlie these commands implement an FGLS estimator and, hence, rely on strong assumptions when estimating cross-equation coeffient covariances, {cmd:stackreg} uses clustering in the same fashion as {cmd:suest}.
The stacked regression approach may alternatively implemted using the data management tool {cmd:}{help stack}.
Implementing the stacked regression approach on basis of {cmd:stack} is however cumbersome, in particular with panel fixed-effects estimation.
Technically {cmd:stackreg} runs a simple OLS regression in which the left-hand-side variable is the stacked variables in {it: depvars},
while the variables in {it: indepvars} enter the right-and side as a saturated set of interactions with indicators for each element of {it: indepvars}.
In terms of the estimated coefficients and standard errors (see options {help stackreg##SE:SE/Inference}) this is fully equivalent to separately regressing each element of {it: depvars} on {it: indepvars},
unless cross-equation restrictions are imposed on the coefficients.
However, unlike separate regressions, the stacked approach inherently accommodates estimating coefficient covariances across equations.
This is of major importance for testing hypotheses that involve coefficients from more than one equation.
{cmd:stackreg} is hence not an estimation procedure in its own right, but a procedure that prepares the ground for jointly testing multiple hypotheses.
After running {cmd:stackreg}, {cmd:test} or {cmd:testparm} can be used in the usual fashion to test hypotheses that involve coefficients from different equations.
{cmd:xtstackreg} is the same as {cmd:stackreg}{opt , fe}.


{title:Variables}

{dlgtab:Model}

{phang} {opt depvars} specifies the list of dependent variables in the stacked regression. 
{opt depvars} may include factor variables and hence allows for straightforwardly considering interactions and polynomials in the regressions that precedes the joint test of multiple hypotheses.

{phang} {opt indepvars} specifies the list of independent variables in the stacked regression. 
In a very basic setting of a balancing check, {opt indepvars} consists of a single treatment indicator.
Yet, more ivolved analyses may require a more complex specification of {opt indepvars}. 
One example is a difference-in-differences setting,
where the common trend assumption implies that the interaction of the post-treatment-period indicator ({it:post}) and treatment-group indicator ({it:tgroup}) has no explanatory power for any element of {opt depvars}.
In this example {opt indepvars} is specified as {it:post##tgroup} and the joint null hypothesis can be tested with {cmd:testparm post#tgroup} after running {cmd:stackreg}; see {help stackreg##example1:Example 1}.
{opt indepvars} may include factor variables.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang} {opt noconstant} makes {cmd:stackreg} suppress the constant terms in the stacked regression.

{phang} {opt constraints(numlist)} makes {cmd:stackreg} apply the linear constraints specified by {it:numlist}.
{it:numlist} needs to comply with Stata's {help numlist:numlist} syntax; i.e. 1/3 is allowed for referring to the constraints 1, 2, and 3, while 1-3 is not allowed.  
The specified constraints need to be defined in advance using {cmd:}{help constraint}.
The syntax for defining the constraints has to be of the form {opt [depvar]indepvar}.
That is in order to identify a coefficient on which a restriction is imposed, both the equation (dependent variable) and the right-hand-side variable need to be specified.
Factor variables syntax is allowed for specifying constraints, e.g. {opt [c.lfare#c.lfare]1998.year = 0}.
Any linear constraints are allowed including cross-equation restrictions.
Option {opt constraints()} cannot be combined with multi-way clustering.
If {opt constraints()} is specified, and {opt noconstant} is not specified, {cmd:stackreg} estimates an overall constant and drops the equation-specific constant from the final equation.

{phang} {opt nocommon} makes {cmd:stackreg} use observations for which information on some variables in {it:depvars} is missing.
The default is to consider only observations for which information on all variables in {it:depvars} is available.
That is, by default the estimation sample and the number of observations is homogeneous across equations. 
With {opt nocommon} specified, {cmd:stackreg} selects the estimation sample on a equation-by-equation basis, 
i.e. the number of observations that enter the regression analysis may vary across the left-hand-side variables.
The information about whether or not the estimation sample is heterogeneous across equations is saved in {opt e(common)}.

{dlgtab:Panel Data}

{phang} {opt fe} makes {cmd:stackreg} use within-transformed variables rather than their levels when estimating the stacked regression.
That is with option {opt fe}, {cmd:stackreg} allows for individual fixed effects.
{opt fe} requires that the data is declared to be panel data using {cmd:}{help xtset}.
{cmd:stackreg} with option {opt fe} is fully equivalent to {cmd:xtstackreg} (with and without option {opt fe}, i.e. {opt fe} has no effet with {cmd:xtstackreg}).
Providing a separate {opt xt} command is just to make more salient that {cmd:stackreg} can be used with panel data.
{cmd:xtstackreg} requires {cmd:stackreg} to be installed.

{marker SE}{...}
{dlgtab:SE/Inference}

{phang} {opt cluster(clustvarlist)} makes {cmd:stackreg} cluster the standard errors (and covariances) at a higher level than the original unit of observation.
By default, an identifier of the original observations serves as {it:clustvar}, since stacking the regression makes each original sampling unit contribute several observations to the stacked regression analysis.
{cmd:stackreg} accomodates multi-way higher-level clustering, i.e. {it:clustvarlist} may consist of more than one variable.
Multi-way clustering requires the community-contributed command {cmd:}{help cgmreg} (by Jonah B. Gelbach and Douglas L. Miller, later versions by Judson Caskey) to be installed. 
{cmd:stackreg} has been tested with {cmd:cgmreg} version 3.0.0 (by J.B. Gelbach and D.L. Miller).
Other versions of {cmd:cgmreg} may behave differently and might make {cmd:stackreg} fail or produce incorrect results.
Multi-way clustering combined with option {opt constraints()}.

{phang} {opt df(adjust|raw|areg)} specifies the type of degrees-of-freedom adjustment {cmd:stackreg} applies. {opt df(adjust)} is the default. 
With {opt df(adjust)},
{cmd:stackreg} adjusts the degrees-of-freedom correction such that the reported standard errors coincide with those one gets from separately regressing the elements of {it:depvars} on {it:indepvars}, using {cmd:regress, robust}. 
This, depending on how the option {opt cluster()} is specified, likewise applies to the standard errors one gets from {cmd:regress,} {opt cluster()} and {cmd:cgmreg,} {opt cluster()}, respectively.
In the most simple case (no higher-level clustering, no panel data, homogeneous number of obs. across {it:depvars}) the initially estimated variance-covariance matrix is adjusted by the factor {it:(N-1)/(N-1/G)},
with {it:N} denoting the genuine number of observations, and {it:G} denoting the number of variables in {it:depvars}.
(With multi-level clustering and option {opt nocommon}, the match with the standard errors from {cmd:cgmreg} may not be perfect; 
see Cameron et al. (2011) for different approaches to the degree-of-freedom correction in a multi-level-clustering setting; some are based on internal results not accessible via what {cmd:cgmreg} saves in {opt e()}.)
For {cmd:xtstackreg} the default, i.e. {opt df(adjust)}, is to adjust the degrees-of-freedom correction such that the standard error coincide with those from {cmd:xtreg,} {opt fe robust} and {cmd:xtreg,} {opt fe cluster()}, respectively.
This implies that {cmd:xtstackreg} by default clusters the standard errors at the level of {it:panelvar}, what is also the default with {cmd:xtreg,} {opt fe robust}.
If {opt df(areg)} is specified, {cmd:xtstackreg} adjusts the degrees-of-freedom such that the standard errors match those from {cmd:areg,}
{opt absorb(panelvar)} {opt robust} and {cmd:areg,} {opt absorb(panelvar)} {opt cluster()}, respectively.
That is with {opt df(areg)}, {cmd:stackreg} does not cluster the standard errors at the level of {it:panelvar} unless this explicitely requested with {opt cluster(panelvar)}.
{opt df(areg)} is ignored by {cmd:stackreg} if {opt fe} is not specified.
{opt df(raw)} prevents {cmd:stackreg} from adjusting the degrees-of-freedom correction to the stacked regression setting.

{phang} {opt wald} prevents {cmd:stackreg} from saving the residual degrees of freedom in {opt e(df_r)}. 
This makes {cmd:test} and {cmd:testparm} apply a Wald- rather than an F-test after {cmd:stackreg}.
With multi-way clustering and heterogeneous numbers of observations {opt e(df_r)} is never saved, because there is no (universal) answer to the question what the number of clusters is.
In consequence {cmd:test} and {cmd:testparm} apply a Wald-test in these cases.

{dlgtab:Speed}

{phang} {opt sreshape} makes {cmd:stackreg}, if installed, call the community-contributed command {cmd:sreshape} (by K.L. Simons) instead of {cmd:reshape}.
Since {cmd:sreshape} is much faster than {cmd:reshape} (Simons 2016) in many settings, specifying {opt sreshape} may speed up {cmd:stackreg}.

{dlgtab:Reporting}

{phang} {opt level(#)}; see {helpb estimation options##level():[R] estimation options}. One may change the reported confidence level by retyping 
{cmd:stackreg} without arguments and only specifying the option {opt level(#)}. 

{phang} {opt edittozero(#)} specifies how small the numeric deviation from zero of an element of the estimated variance-covariance needs to be in order to set this element to the value of zero.
The specified value is just passed through to the {cmd:mata} function {cmd:edittozero()}; see {helpb mf_edittozero:[M-5] edittozero()}. 
Minimal editing that is {opt edittozero(1)} is the default.
The different estimation commands that are alternatively called by {cmd:stackreg} may differ with respect to how estimated coefficient variances that are close to zero are dealt with.
Specifying {opt edittozero()} aligns their behaviors. 

{phang} {opt omitted} specifies that variables that were omitted because of collinearity are displayed and labeled as "(omitted)".
The default is not to display them, i.e. {opt noomitted}. 

{phang} {opt emptycells} specifies that empty cells for interactions of factor variables are displayed and labeled as "(empty)".
The default is not to display them, i.e. {opt noemptycells}.

{phang} For further {it:display_options}, see {helpb estimation options##display_options:[R] estimation options}.


{marker example1}{...}
{title:Example 1} (Wooldridge, 2012, p. 456; difference-in-differences analysis, effect of new garbage incinerator on house prices)

{pstd}Load data{p_end}
{phang2}{cmd:. use "http://fmwww.bc.edu/ec-p/data/wooldridge/kielmc.dta", clear}{p_end}

{pstd}Regression of primary interest (difference-in-differences with controls){p_end}
{phang2}{cmd:. regress rprice age c.age#c.age intst area land rooms baths y81##nearinc}{p_end}

{pstd}Stacked balancing regression {p_end}
{phang2}{cmd:. stackreg age c.age#c.age intst area land rooms baths = y81##nearinc}{p_end}

{pstd}Test of joint significance of interaction of post-treatment-period indicator {it:y81} and treatment-group indicator {it:nearinc}{p_end}
{phang2}{cmd:. testparm y81#nearinc}{p_end}


{title:Example 2} (Wooldridge, 2012, p. 506-507; fixed-effects estimation, effect of market concentration on flight fares; second outcome {it:lpassen} (log-number of passengers) added)

{pstd}Load data{p_end}
{phang2}{cmd:. use "http://fmwww.bc.edu/ec-p/data/wooldridge/airfare.dta", clear}{p_end}

{pstd}Stacked fixed-effects estimation (standard errors match those from {cmd:xtreg, fe robust}){p_end}
{phang2}{cmd:. xtstackreg lfare lpassen = concen i.year}{p_end}

{pstd}Test of null that market concentration neither affects the fare nor the number of passengers{p_end}
{phang2}{cmd:. test concen}{p_end}

{pstd}Same as above with standard errors that match those from {cmd:areg, absorb(id) robust}{p_end}
{phang2}{cmd:. xtstackreg lfare lpassen = concen i.year, df(areg)}{p_end}
{phang2}{cmd:. test concen}{p_end}

{pstd}Same as above with two-way (origin and destination) clustering ({cmd:cgmreg} called from {cmd:stackreg}){p_end}
{phang2}{cmd:. egen gorigin = group(origin)}{p_end}
{phang2}{cmd:. egen gdestin = group(destin)}{p_end}
{phang2}{cmd:. xtstackreg lfare lpassen = concen i.year, cluster(gorigin gdestin)}{p_end}
{phang2}{cmd:. test concen}{p_end}
 

{title:Saved results}

{pstd}
{cmd:stackreg} and {cmd:xtstackreg} save the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations (not expanded by stacking){p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {opt e(b)}{p_end}
{synopt:{cmd:e(N_g)}}number of groups (only saved with {cmd:xtstackreg} or option {opt fe}){p_end}
{synopt:{cmd:e(rank)}}rank of {opt e(V)}{p_end}
{synopt:{cmd:e(N_stack)}}number of observations in stacked regression{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom (only saved if {opt wald} ist not specified and {opt e(common)} : "common" and {opt e(estimator)} : "regress"){p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom (not saved if {opt e(common)} : "nocommon") or {opt e(estimator)} : "cnsreg"){p_end}
{synopt:{cmd:e(N_l)}}number of observations lth equation (only saved if {opt e(common)} : "nocommon"){p_end}
{synopt:{cmd:e(rank_l)}}rank of lth block (lth equation) of {opt e(V)} (only saved if {opt e(common)} : "nocommon" or {opt e(estimator)} : "cnsreg"){p_end}
{synopt:{cmd:e(df_r_l)}}residual degrees of freedom lth equation (only saved if {opt e(common)} : "nocommon"){p_end}
{synopt:{cmd:e(df_m_l)}}model degrees of freedom lth equation (only saved if {opt e(common)} : "nocommon" or {opt e(estimator)} : "cnsreg"){p_end}
{synopt:{cmd:e(level)}}confidence level{p_end}
{synoptset 20 tabbed}{...} {p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(title)}}{cmd:Stacked Regression}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:stackreg} or {cmd:xtstackreg}{p_end}
{synopt:{cmd:e(depvar)}}names in {it:depvars}{p_end}
{synopt:{cmd:e(eqnames)}}names in {it:depvars}{p_end}
{synopt:{cmd:e(estimator)}}{cmd:regress}, {cmd:cnsreg}, or {cmd:cgmreg}{p_end}
{synopt:{cmd:e(model)}}either {opt ols} or {opt fe}{p_end}
{synopt:{cmd:e(common)}}either {opt common} or {opt nocommon} ({opt nocommon} indicates that the estimation sample varies across equations){p_end}
{synopt:{cmd:e(vcetype)}}{cmd:Clust. Robust}{p_end}
{synopt:{cmd:e(marginsok)}}predictions allowed by {opt margins}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {opt predict}{p_end}
{synopt:{cmd:e(properties)}}{opt b V}{p_end}
{synoptset 20 tabbed}{...} {p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of estimated coefficients{p_end}
{synopt:{cmd:e(V)}}estimated coefficient variance-covariance matrix{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix (only saved if {opt e(estimator)} : "cnsreg"){p_end}

{synoptset 20 tabbed}{...}{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:References}

{pstd} Cameron, A., Gelbach, J. and Miller, D. (2011). Robust Inference With Multiway Clustering. {it:Journal of Business & Economic Statistics} 29(2), 238-249.

{pstd} Pei, Z., Pischke, J.-S. and Schwandt, H. (2019). Poorly Measured Confounders are More Useful on the Left than on the Right. {it:Journal of Business & Economic Statistics} 37(2), 205-216.  

{pstd} Simons, K. L. (2016). A sparser, speedier reshape. {it:Stata Journal} 16(3), 632-649.

{pstd} Wooldridge, J. M. (2002). Econometric Analysis of Cross Section and Panel Data. {it:MIT Press}.

{pstd} Wooldridge, J.M. (2012). Introductory Econometrics: A Modern Approach, 5th edition. {it:South-Western}.  

{pstd} Weesie, J. (1999). Seemingly unrelated estimation and the cluster-adjusted sandwich estimator. {it:Stata Technical Bulletin} 52, 34-47.


{title:Also see}

{psee} Manual:  {manlink R suest},   {manlink MV mvreg},   {manlink R test},   {manlink R areg},   {manlink R cnsreg},   {manlink R sureg},   {manlink XT xtset}

{psee} {space 2}Help:  {manhelp suest R:suest}, {manhelp mvreg MV:mvreg}, {manhelp test R:test}, {manhelp areg R:areg}, {manhelp cnsreg R:cnsreg}, {manhelp sureg R:sureg}, {manhelp xtset XT:xtset}, {help cgmreg :cgmreg}, {help sreshape :sreshape}{break}  


{title:Authors}

{psee} Michael Oberfichtner{p_end}{psee}  Institute for Employment Research (IAB){p_end}{psee} N{c u:}rnberg, 
Germany{p_end}{psee}E-mail: Michael.Oberfichtner2@iab.de {p_end}

{psee} Harald Tauchmann{p_end}{psee} Friedrich-Alexander-Universit{c a:}t Erlangen-N{c u:}rnberg (FAU){p_end}{psee} N{c u:}rnberg, 
Germany{p_end}{psee}E-mail: harald.tauchmann@fau.de {p_end}


{title:Disclaimer}
 
{pstd} This software is provided "as is" without warranty of any kind, either expressed or implied. The entire risk as to the quality and 
performance of the program is with you. Should the program prove defective, you assume the cost of all necessary servicing, repair or 
correction. In no event will the copyright holders or their employers, or any other party who may modify and/or redistribute this software, 
be liable to you for damages, including any general, special, incidental or consequential damages arising out of the use or inability to 
use the program.{p_end} 


{title:Acknowledgements}

{pstd} We would like to thank Julia Lang, Johannes Ludsteck, Sabrina Schubert, and an anonymous reviewer for many valuable comments and suggestions. 
Excellent research assistance from Irina Simankova is gratefully acknowledged. {p_end} 


{pstd} {p_end} 
