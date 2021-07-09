{smcl}
{* *! version 3.0  14feb2019 Pablo Mitnik}{...}

{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] regress" "help regress"}{...}
{vieweralsosee "[R] ivregress" "help ivregress"}{...}
{vieweralsosee "[R] poisson" "help poisson"}{...}
{vieweralsosee "[R] ivpoisson" "help ivpoisson"}{...}
{vieweralsosee "igesetci (if installed)" "help igesetci"}{...}
{vieweralsosee "igeintb (if installed)" "help igeintb"}{...}
{viewerjumpto "Syntax and options" "igeset##syntax"}{...}
{viewerjumpto "Description" "igeset##description"}{...}
{viewerjumpto "Remarks and related commands" "igeset##remarks"}{...}
{viewerjumpto "Examples" "igeset##examples"}{...}
{viewerjumpto "Stored results" "igeset##results"}{...}
{viewerjumpto "Author and suggested citation" "igeset##author"}{...}
{viewerjumpto "References" "igeset##references"}{...}
{viewerjumpto "Disclaimer" "igeset##disclaimer"}{...}

{title:Title}

{p2colset 5 22 23 2}{...}
{bf:igeset} {hline 2} Set estimation of intergenerational income elasticities (IGEs) with a single set of instruments
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax and options}                                
{phang}

{p 8 17 2}
{cmd:igeset} {it:cvar} {it:pvar} {ifin} [{it:{help igeset##weight:weight}}][{cmd:,} {it:options}]

where {it:cvar} is the name of the children's income or log income variable, as relevant, and {it:pvar} is the name of the log parental-income variable

{synoptset 28 tabbed}{...}
{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab :Required options}
{synopt :{opt ige:(igetype)}}{it:igetype} is either {opt igee}, the IGE of the expectation, or {opt igeg}, the IGE of the geometric mean{p_end}
{synopt :{opth insts:(varlist:varlist1)}}{it:varlist1} specifies the set of instruments used to produce an estimate of  the upper bound{p_end}

{syntab :Other options}
{synopt :{opth exvars:(varlist:varlist2)}}{it:varlist2} specifies exogenous variables, i.e., independent variables other than log parental income{p_end}
{synopt :{opt ci:(citype)}}{it:citype} is either {opt im}, Imbens and Manki's (2004) confidence interval (the default); {opt nr}, Nevo and Rosen's (2012) confidence interval; or {opt imnr}, both confidence intervals{p_end}
{synopt :{opt gmm}}requires that the GMM estimator be used for the estimation of the IGE of the geometric mean (the default is to use the {cmd: 2SLS} estimator){p_end}
{synopt :{opt igmm}}requires that the iterative instead of two-step GMM estimator be used; requires option {opt gmm} if option {opt ige(igeg)} has been specified{p_end}
{synopt :{opth c:luster(varname:varlist3)}}{it:varlist3} are variables identifying sample clusters{p_end}
{synopt :{opt tech:nique()}}{opt technique()} specifies the optimization technique to use with the instrumental-variable estimator of the IGE of the expectation, which may be gn (the default), nr, dfp, or bfgs{p_end}
{synopt :{opt l:evel(#)}}confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt show}}requires that the full results of estimating the individual bound estimates on which the reported set estimate is based be shown{p_end}
{synoptline}
{marker weight}{...}
{p 4 6 2}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see {help weight}.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:igeset} set estimates, or "brackets," IGEs of children's income with respect to parental income. To estimate the lower bound, {cmd:igeset} uses an estimator assumed to be affected by attenuation bias given the parental 
information available (i.e., a short-run instead of a long-run parental-income measure). To estimate the upper bound, {cmd:igeset} uses an instrumental-variable (IV) estimator and one (and only one) set of {it:invalid} 
instruments assumed to be positively correlated with the error term of the population regression function of interest. The estimated IGE may be the IGE of the expectation or the IGE of the geometric mean 
(see {help igeset##references:Mitnik and Grusky [Forthcoming]} for these two IGEs). 

{marker remarks}{...}
{title:Remarks and related commands}

{pstd}
{cmd:igeset} set estimates (a) the IGE of the geometric mean, by combining a lower-bound estimate obtained with the Ordinary Least Squares estimator (see {help regress:regress}) and an upper-bound estimate obtained with a linear 
IV estimator ({cmd:gmm} or {cmd:2sls}, see {help ivregress:ivregress}), or (b) the IGE of the expectation, by combining a lower-bound estimate obtained with the Poisson Pseudo Maximum Likelihood estimator (see {help poisson:poisson}) and an 
upper-bound estimate obtained with the Poisson {cmd:gmm} additive-error IV estimator (see {help ivpoisson:ivpoisson}). If the option {opt show} is specified, {cmd:igeset} shows the full results of its estimation of the upper and lower bounds. This allows the user to confirm that {cmd:igeset} produces the same estimates as those obtained with 
the underlying commands. {cmd:igeset} computes {help igeset##references:Imbens and Manski's (2004)} and (optionally) {help igeset##references:Nevo and Rosen's (2012: Sec. IV)} confidence intervals for the partially identified IGEs 
it estimates (rather than for the identified set). See {help igeset##references:Mitnik (Forthcoming)} for a detailed discussion regarding the set estimation of IGEs.

{pstd}
While {cmd:igeset} is an {it:estimation} command, the command {cmd:igesetci} (see {help igesetci:igesetci}, if installed) is a closely related {it: post-estimation} command that computes the confidence intervals computed by 
{cmd:igeset} after the upper and lower bounds have already been estimated by the user, and which provides more flexibility (e.g., gives the user full control of estimators, optimization options, VCE options and so forth) but requires 
more coding. 

{pstd}
The command {cmd:igeset} cannot be used to estimate IGEs with multiple sets of instruments (as different from multiple instruments). The command {cmd:igeintb} may be used instead. It set estimates IGEs by generating multiple 
estimates of the upper-bound and selecting the minimun estimate as the final estimate of the upper bound (see {help igeintb:igeintb}, if installed).

{marker examples}{...}
{title:Examples}

{pstd}Read and describe data{p_end}

     .{stata "use igeset_data, clear"}  
     .{stata "de"}  

{pstd}IGE of the expectation: Three examples 

     .{stata "igeset c_inc p_ln_inc, insts(p_educ) ige(igee)"} 

     .{stata "igeset c_inc p_ln_inc [pw = c_wcore], insts(i.p_occ) ige(igee) ci(nr) exvars(c.p_age c.p_age#c.p_age) igmm"} 

     .{stata "igeset c_inc p_ln_inc, insts(c.p_educ c.p_educ#c.p_educ i.p_occ) ige(igee) ci(imnr) igmm tech(nr)"} 

{pstd}IGE of the geometric mean: Three examples 

     .{stata "igeset c_ln_inc p_ln_inc, insts(p_educ) ige(igeg)"} 

     .{stata "igeset c_ln_inc p_ln_inc [pw = c_wcore], insts(i.p_occ) ige(igeg) ci(nr) exvars(c.p_age c.p_age#c.p_age)"} 

     .{stata "igeset c_ln_inc p_ln_inc, insts(c.p_educ c.p_educ#c.p_educ i.p_occ) ige(igeg) ci(imnr) gmm igmm"} 

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:igeset} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:igeset}{p_end}
{synopt:{cmd:e(ige)}}igeg  or igee {p_end}
{synopt:{cmd:e(ci)}}im, nr, or imnr{p_end}
{synopt:{cmd:e(cvar)}}children's income or log income variable{p_end}
{synopt:{cmd:e(pvar)}}log parental-income variable{p_end}
{synopt:{cmd:e(insts)}}instruments{p_end}
{synopt:{cmd:e(exvars)}}exogenous variables{p_end}
{synopt:{cmd:e(estimator)}}{cmd:gmm} or {cmd:2sls}{p_end}
{synopt:{cmd:e(gmmestimator)}}{cmd:twostep} or {cmd:igmm}{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable/s{p_end}
{synopt:{cmd:e(technique)}}optimization technique used to estimate the upper bound of the igee{p_end}

{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(pe_lb)}}lower bound of set estimate{p_end}
{synopt:{cmd:e(pe_ub)}}upper bound of set estimate {p_end}
{synopt:{cmd:e(ci_im_lb)}}lower bound of IM confidence interval for partially identified IGE{p_end}
{synopt:{cmd:e(ci_im_ub)}}upper bound of IM confidence interval for partially identified IGE{p_end}
{synopt:{cmd:e(c)}}critival value used to construct IM confidence interval{p_end}
{synopt:{cmd:e(ci_nr_lb)}}lower bound of NR confidence interval for partially identified IGE{p_end}
{synopt:{cmd:e(ci_nr_ub)}}upper bound of NR confidence interval for partially identified IGE{p_end}
{synopt:{cmd:e(k)}}critival value used to construct NR confidence interval{p_end}
{synopt:{cmd:e(confidence_level)}}confidence level{p_end}

{marker author}{...}
{title:Author}

{pstd}
Pablo A. Mitnik, Center on Poverty and Inequality, Stanford University.

{title:Suggested citation if using {cmd:igeset} in published work}

{pstd}
{cmd:igeset} is not an official Stata command. It is a free contribution to the research community, produced jointly with {help igeset##references:Mitnik (Forthcoming)}. Citation of this paper when using {cmd:igeset} would be appreciated. 

{marker references}{...}
{title:References}

{pstd} Chernozhukov, Victor, Sokbae Lee and Adam Rosen. 2013. "Intersection Bounds: Estimation and Inference." {it: Econometrica} 81(2): 667-737.{p_end}
{pstd} Imbens, Guido and Charles Manski. 2004. "Confidence Intervals for Partially Identified Parameters." {it: Econometrica} 72(6): 1845-1857.{p_end}
{pstd} Mitnik, Pablo. Forthcoming. "Intergenerational Income Elasticities, Instrumental Variable Estimation and Bracketing Strategies." {it:Sociological Methodology}.{p_end}
{pstd} Mitnik, Pablo and David Grusky. Forthcoming. "The Intergenerational Elasticity of What? The Case for Redefining the Workhorse Measure of Economic Mobility." {it:Sociological Methodology}.{p_end}
{pstd} Nevo, Aviv and Adam Rosen. 2012. "Identification with Imperfect Instruments." {it: Review of Economics and Statistics} 94(3): 659-671.{p_end}

{marker disclaimer}{...}
{title:Disclaimer}

{pstd}
{cmd:igeset} is provided as is, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and 
noninfringement. 



