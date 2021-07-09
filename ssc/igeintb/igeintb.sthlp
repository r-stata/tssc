{smcl}
{* *! version 2.0  14feb2019 Pablo Mitnik}{...}

{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] regress" "help regress"}{...}
{vieweralsosee "[R] ivregress" "help ivregress"}{...}
{vieweralsosee "[R] poisson" "help poisson"}{...}
{vieweralsosee "[R] ivpoisson" "help ivpoisson"}{...}
{vieweralsosee "igeset (if installed)" "help igeset"}{...}
{vieweralsosee "igesetci (if installed)" "help igesetci"}{...}
{viewerjumpto "Syntax and options" "igeintb##syntax"}{...}
{viewerjumpto "Description" "igeintb##description"}{...}
{viewerjumpto "Remarks and related commands" "igeintb##remarks"}{...}
{viewerjumpto "Examples" "igeintb##examples"}{...}
{viewerjumpto "Stored results" "igeintb##results"}{...}
{viewerjumpto "Author and suggested citation" "igeintb##author"}{...}
{viewerjumpto "References" "igeintb##references"}{...}
{viewerjumpto "Disclaimer" "igeintb##disclaimer"}{...}

{title:Title}

{p2colset 5 22 23 2}{...}
{bf:igeintb} {hline 2} Set estimation of intergenerational income elasticities (IGEs) with multiple sets of instruments
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax and options}                                
{phang}

{p 8 17 2}
{cmd:igeintb} {it:cvar} {it:pvar} {ifin} [{it:{help igeintb##weight:weight}}][{cmd:,} {it:options}]

where {it:cvar} is the name of the children's income or log income variable, as relevant, and {it:pvar} is the name of the log parental-income variable

{synoptset 28 tabbed}{...}
{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab :Required options}
{synopt :{opt ige:(igetype)}}{it:igetype} is either {opt igee}, the IGE of the expectation, or {opt igeg}, the IGE of the geometric mean{p_end}
{synopt :{opth insts1:(varlist:varlist1)}}{it:varlist1} specifies the first set of instruments used to produce an estimate of  the upper bound{p_end}
{synopt :{opth insts2:(varlist:varlist2)}}{it:varlist2} specifies the second set of instruments used to produce an estimate of the upper bound{p_end}

{syntab :Additional sets of instruments}
{synopt :{opth insts3:(varlist:varlist3)}}{it:varlist3} specifies the third set of instruments used to produce an estimate of the upper bound{p_end}
{synopt: .} {p_end}
{synopt: .} {p_end}
{synopt: .} {p_end}
{synopt :{opth insts10:(varlist:varlist10)}}{it:varlist10} specifies the tenth (and last) set of instruments used to produce an estimate of the upper bound{p_end}

{syntab :Other options}
{synopt :{opth exvars:(varlist:varlist11)}}{it:varlist11} specifies exogenous variables, i.e., independent variables other than log parental income{p_end}
{synopt :{opt hmu}}requires reporting of the half-median unbiased estimate of the upper bound{p_end}
{synopt :{opt gmm}}requires that the two-step GMM estimator be used for the estimation of the IGE of the geometric mean (the default is to use the {cmd: 2SLS} estimator){p_end}
{synopt :{opth c:luster(varname:varlist 12)}}{it:varlist12} are variables identifying sample clusters{p_end}
{synopt :{opt tech:nique()}}{opt technique()} specifies the optimization technique to use with the instrumental-variable estimator of the IGE of the expectation, which may be gn (the default), nr, dfp, or bfgs{p_end}
{synopt :{opt l:evel(#)}}confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt nsim(#)}}number of simulations used to compute critical values; default is {cmd:nsim(10000)}{p_end}
{synopt :{opt seed(#)}}seed number for simulations used to compute critical values; default is {cmd:seed(123456789)}{p_end}
{synopt :{opt show}}requires that the full results of estimating the individual bound estimates on which the reported set estimate is based be shown{p_end}
{synoptline}
{marker weight}{...}
{p 4 6 2}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see {help weight}.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:igeintb} set estimates, or "brackets," IGEs of children's income with respect to parental income. To estimate the lower bound, {cmd:igeintb} uses an estimator assumed to be affected by attenuation bias given the parental 
information available (i.e., a short-run instead of a long-run parental-income measure). To estimate the upper bound, {cmd:igeintb} uses an instrumental-variable (IV) estimator and at least two (and up to ten) sets of {it:invalid} 
instruments assumed to be positively correlated with the error term of the population regression function of interest. The estimated IGE may be the IGE of the expectation or the IGE of the geometric mean 
(see {help igeintb##references:Mitnik and Grusky [Forthcoming]} for these two IGEs). {cmd:igeintb} computes confidence intervals that take into account that the use of multiple sets of instruments to estimate the upper bound 
entails that the identified set is equal to the intersection of all the sets than can be formed by combining the probability limit of the IV estimator based on one set of instruments with the probability limit of the lower-bound 
estimator.

{marker remarks}{...}
{title:Remarks and related commands}

{pstd}
{cmd:igeintb} stacks the upper-bound models and produces {it: simultaneous} IV estimates of the upper bound based on all sets of instruments specified by the user. To this end, {cmd:igeintb} uses the Poisson {cmd:gmm} additive-error 
IV estimator (see {help ivpoisson:ivpoisson}), in the case of the IGE of the expectation, and a linear IV estimator ({cmd:2sls} or {cmd:gmm}, see {help ivregress:ivregress}), in the case of the IGE of the geometric mean. Stacked 
estimation allows {cmd:igeintb} to produce a {it:joint} variance-covariance matrix for the upper-bound estimates. {cmd:igeintb} estimates the lower bound using the Poisson Pseudo-Maximum Likelihood estimator 
(see {help poisson:poisson}) in the case of the IGE of the expectation, and the Ordinary Least Squares estimator (see {help regress:regress}) in the case of the IGE of the geometric mean. 

{pstd}
By default, {cmd:igeintb} reports as upper-bound estimate the minimum of the estimates of the upper bound across sets of instruments produced with either {help ivpoisson:ivpoisson} or {help ivregress:ivregress}, as relevant. If the
option {opt hmu} is specified, {cmd:igeintb} also reports an estimate of the upper bound produced by a half-median unbiased estimator, i.e., an estimator with the property that at least half of its values across samples are above the 
true upper bound. This estimator is the minimum of the {it: corrected} estimates of the upper bound; the correction is the one proposed by {help igeintb##references:Chernozhukov et al. (2013)}, which adds to the point estimate its 
standard error multiplied by a critical value. Although both estimators are consistent, neither is asymptotically unbiased (no estimator involving minimization or maximization can be asymptotically unbiased). While the risk with the 
default estimator is that in finite samples it may produce estimates that are significantly downward biased, the alternative estimator has the shortcoming that it may tend to be overly conservative. The reason is that, unlike a 
median unbiased estimator, a half-median unbiased estimator of the upper bound may have the bulk of its distribution "way to the right."

{pstd}The reported set estimate is in both cases the result of combining the lower-bound estimate with the minimum of the upper-bound estimates (corrected or uncorrected, as relevant). {cmd:igeintb} computes a confidence interval 
for the partially identified IGE (rather than for the identified set) using the approach advanced by {help igeintb##references:Nevo and Rosen (2012:Sect. IV)} for parameters set estimated in intersection-bounds contexts, but 
modified to use "adaptive inequality selection" (AIS; see {help igeintb##references:Chernozhukov et al. [2013]}) to determine the contact set.(The "contact set" is the set of upper-bound estimates that are sufficiently close to binding to affect the 
asymptotic distribution of the estimator that selects the minimum among a set of upper-bound estimates.) The corrected upper-bound estimates, AIS and the confidence interval for the partially identifierd IGE all require the 
computation of critical values that are obtained through simulations. When the option {opt hmu} is specified, the estimate of the width of the identified set (which is needed for the computation of the confidence interval) is based 
on the minimum of the corrected upper-bound estimates; otherwise, the minimum of the uncorrected estimates is used to compute that width.

{pstd} Whenever the option {opt cluster} is specified, similarly to many other Stata commands, {cmd:igeintb} computes a type of standard error that allows for correlations among observations within clusters. However, whenever the {cmd:gmm} 
estimator is employed, {cmd:igeintb} uses the weighting matrix of type {it:robust}, rather than a matrix that accounts for the correlations among observations within clusters, even if the option {opt cluster} is specified. This 
entails some loss of efficiency, which is made necessary by the stacking of the upper-bound models. If {cmd:igeintb} employed the weighting matrix that accounts for correlations among observations, then it would not produce the same 
point estimates as those produced by the underlying individual models, when the latter are estimated with the same type of weighting matrix. {cmd:igeintb} does reproduce the point estimates produced by the underlying individual models 
as long as they are estimated with the weighting matrix of type {it: robust}. Whenever {cmd:igeintb} uses a {cmd:gmm} estimator, it is the two-step rather than the iterative version of the estimator.

{pstd} If the option {opt show} is specified, {cmd:igeintb} shows the full results it obtains by simultaneously estimating the upper bounds (as well as the full results of its estimation of the lower bound). This allows the user to 
confirm that {cmd:igeintb} produces the same individual IV point estimates of the upper bound that are obtained without stacking the models.  

{pstd}
See {help igeintb##references:Mitnik (Forhcoming)} for additional details on the set estimation of IGEs with multiple sets of instruments and the computation of confidence intervals for the partially identified IGE in that context. 

{pstd}
{cmd:igeintb} has been conceived for use in contexts in which the upper bound is estimated with multiple sets of instruments. If an IGE is set estimated with only one set of invalid instruments, then set estimation can be carried out 
with {cmd:igeset} (see {help igeset:igeset}, if installed). Alternatively, the estimates of the lower and upper bounds may be generated first, and then {cmd:igesetci} can be used to produce a valid confidence interval for the 
partially identified IGE (see {help igesetci:igesetci} if installed). 

{marker examples}{...}
{title:Examples}

{smcl}
{pstd}Read and describe data and add new variables (which is needed because {cmd:igeintb} does not accept factor variables){p_end}

     . {stata "use igeintb_data, clear"} 
     . {stata "describe"}
     . {stata "gen p_educ_sq = p_educ^2"}
     . {stata "gen p_age_sq = p_age^2"}
     . {stata "tab p_occ, generate(occ)"}
     . {stata "drop occ1"}

{pstd}IGE of the expectation: Six examples of set estimation with multiple sets of instruments{p_end}

     . {stata "igeintb c_inc p_ln_inc, ige(igee) insts1(p_educ) insts2(p_educ_sq)"}

     . {stata "igeintb c_inc p_ln_inc [pw=c_wcore], ige(igee) insts1(p_educ) insts2(occ*)"}

     . {stata "igeintb c_inc p_ln_inc [pw=c_wcore], ige(igee) insts1(p_educ) insts2(occ*) exvars(p_age p_age_sq)"}

     . {stata "igeintb c_inc p_ln_inc [pw=c_wcore], ige(igee) insts1(p_educ) insts2(occ*) hmu"}

     . {stata "igeintb c_inc p_ln_inc [pw=c_wcore], ige(igee) insts1(p_educ) insts2(occ*) insts3(p_educ p_educ_sq) insts4(p_educ p_educ_sq occ*) cluster(clusvar) nsim(20000) seed(123)"}

     . {stata "igeintb c_inc p_ln_inc [pw=c_wcore], ige(igee) insts1(p_educ) insts2(occ*) exvars(p_age p_age_sq) tech(nr)"}

{pstd}IGE of the geometric mean: Six examples of set estimation with multiple sets of instruments{p_end}

     . {stata "igeintb c_ln_inc p_ln_inc, ige(igeg) insts1(p_educ) insts2(p_educ_sq)"} 

     . {stata "igeintb c_ln_inc p_ln_inc [pw=c_wcore], ige(igeg) insts1(p_educ) insts2(occ*)"}

     . {stata "igeintb c_ln_inc p_ln_inc [pw=c_wcore], ige(igeg) insts1(p_educ) insts2(occ*) exvars(p_age p_age_sq)"}

     . {stata "igeintb c_ln_inc p_ln_inc [pw=c_wcore], ige(igeg) insts1(p_educ) insts2(occ*) hmu"}

     . {stata "igeintb c_ln_inc p_ln_inc [pw=c_wcore], ige(igeg) insts1(p_educ) insts2(occ*) insts3(p_educ p_educ_sq) insts4(p_educ p_educ_sq occ*) cluster(clusvar) nsim(20000) seed(123)"}

     . {stata "igeintb c_ln_inc p_ln_inc [pw=c_wcore], ige(igeg) insts1(p_educ) insts2(occ*) exvars(p_age p_age_sq) gmm"}
{p2colreset}{...}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:igeintb} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:igeintb}{p_end}
{synopt:{cmd:e(ige)}}igeg or igee {p_end}
{synopt:{cmd:e(cvar)}}children's income or log income variable{p_end}
{synopt:{cmd:e(pvar)}}log parental-income variable{p_end}
{synopt:{cmd:e(insts_ub)}}instruments that produced the estimate of the upper bound{p_end}
{synopt:{cmd:e(insts_ub_hmu)}}instruments that produced the half-median unbiased estimate of the hupper-bound{p_end}
{synopt:{cmd:e(exvars)}}exogenous variables{p_end}
{synopt:{cmd:e(iv_estimator)}}IV estimator, {cmd:gmm} or {cmd:2sls}{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable/s{p_end}
{synopt:{cmd:e(technique)}}optimization technique used to estimate the upper bound of the igee{p_end}

{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(pe_lb)}}lower bound of set estimate{p_end}
{synopt:{cmd:e(pe_ub)}}upper bound of set estimate {p_end}
{synopt:{cmd:e(pe_ub_hmu)}}upper bound of half-median unbiased set estimate {p_end}
{synopt:{cmd:e(ci_lb)}}lower bound of confidence interval{p_end}
{synopt:{cmd:e(ci_ub)}}upper bound of confidence interval{p_end}
{synopt:{cmd:e(ci_ub_hmu)}}upper bound of confidence interval based on half-median unbiased estimate{p_end}
{synopt:{cmd:e(ci_lb_hmu)}}lower bound of confidence interval based on half-median unbiased estimate{p_end}
{synopt:{cmd:e(k_lb)}}critical value used to construct lower-bound of confidence interval{p_end}
{synopt:{cmd:e(k_ub)}}critical value used to construct upper-bound of confidence interval{p_end}
{synopt:{cmd:e(k_ub_hmu)}}critical value used to construct upper-bound of confidence interval based on half-median unbiased estimate{p_end}
{synopt:{cmd:e(k_lb_hmu)}}critical value used to construct lower-bound of confidence interval based on half-median unbiased estimate{p_end}
{synopt:{cmd:e(confidence_level)}}confidence level{p_end}
{synopt:{cmd:e(nsim)}}number of simulations{p_end}
{synopt:{cmd:e(seed)}}seed number for simulations{p_end}

{marker author}{...}
{title:Author}

{pstd}
Pablo A. Mitnik, Center on Poverty and Inequality, Stanford University.

{title:Suggested citation if using {cmd:igeintb} in published work}

{pstd}
{cmd:igeintb} is not an official Stata command. It is a free contribution to the research community, produced jointly with {help igeintb##references:Mitnik (Forhcoming)}. Citation of this paper when using {cmd:igeintb} would be appreciated. 

{marker references}{...}
{title:References}

{pstd} Chernozhukov, Victor, Sokbae Lee and Adam Rosen. 2013. "Intersection Bounds: Estimation and Inference." {it: Econometrica} 81(2): 667-737.{p_end}
{pstd} Mitnik, Pablo. Forthcoming. "Intergenerational Income Elasticities, Instrumental Variable Estimation and Bracketing Strategies." {it:Sociological Methodology}.{p_end}
{pstd} Mitnik, Pablo and David Grusky. Forthcoming. "The Intergenerational Elasticity of What? The Case for Redefining the Workhorse Measure of Economic Mobility." {it:Sociological Methodology}.{p_end}
{pstd} Nevo, Aviv and Adam Rosen. 2012. "Identification with Imperfect Instruments." {it: Review of Economics and Statistics} 94(3): 659-671.{p_end}

{marker disclaimer}{...}
{title:Disclaimer}

{pstd}
{cmd:igeintb} is provided as is, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and 
noninfringement. 



