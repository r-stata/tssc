{smcl}
{* *! version 1.0  19Feb2019 Pablo Mitnik}{...}

{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] regress" "help regress"}{...}
{vieweralsosee "[R] ivregress" "help ivregress"}{...}
{vieweralsosee "[R] poisson" "help poisson"}{...}
{vieweralsosee "[R] ivpoisson" "help ivpoisson"}{...}
{vieweralsosee "igeset (if installed)" "help igeset"} {...}
{vieweralsosee "igeintb (if installed)" "help igeintb"} {...}
{viewerjumpto "Syntax and options" "igesetci##syntax"}{...}
{viewerjumpto "Description" "igesetci##description"}{...}
{viewerjumpto "Remarks and related commands" "igesetci##remarks"}{...}
{viewerjumpto "Examples" "igesetci##examples"}{...}
{viewerjumpto "Stored results" "igesetci##results"}{...}
{viewerjumpto "Author and suggested citation" "igesetci##author"}{...}
{viewerjumpto "References" "igesetci##references"}{...}
{viewerjumpto "Disclaimer" "igesetci##disclaimer"}{...}

{title:Title}

{p2colset 5 22 23 2}{...}
{bf:igesetci} {hline 2} Computation of confidence intervals for partially identified intergenerational income elasticities (IGEs)
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax and options}                             
{phang}

{p 8 17 2}
{cmd:igesetci} {it:cvar} {it:pvar}, {opt lb:ound}({it:name1}) {opt ub:ound}({it:name2}) {opt ige:}({it:igetype}) [{opt ci:}({it:citype}) {opt l:evel(#)}]

where {it:cvar} is the name of the children's income or log income variable, as relevant, and {it:pvar} is the name of the log parental-income variable

{synoptset 28 tabbed}{...}
{marker options_table}{...}
{synopthdr}
{synoptline}
{synopt :{opt lb:ound(name1)}}{it:name1} is the name under which estimation results for the lower-bound model were stored via {helpb estimates store:estimates store}{p_end}
{synopt :{opt ub:ound(name2)}}{it:name2} is the name under which estimation results for the upper-bound model were stored via {helpb estimates store:estimates store}{p_end}
{synopt :{opt ige:(igetype)}}{it:igetype} is either {opt igee}, the IGE of the expectation, or {opt igeg}, the IGE of the geometric mean{p_end}
{synopt :{opt ci:(citype)}}{it:citype} is either {opt im}, Imbens and Manki's (2004) confidence interval (the default); {opt nr}, Nevo and Rosen's (2012) confidence interval; or {opt imnr}, both confidence intervals{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:igesetci} is a post-estimation command that computes {help igesetci##references:Imbens and Manski's (2004)} and {help igesetci##references:Nevo and Rosen's (2012: Sec. IV)} confidence intervals for a partially identified parameter 
(rather than for the identified set) in contexts in which the parameter in question is the IGE of the expectation or the IGE of the geometric mean (see {help igesetci##references:Mitnik and Grusky [Forthcoming]} for these two IGEs), and either 
(a) a set estimate of the IGE of the expectation has been produced by combining a lower-bound estimate obtained with the command {help poisson:poisson} and an upper-bound estimate obtained with the command {help ivpoisson:ivpoisson} 
or (b) a set estimate of the IGE of the geometric mean has been produced by combining a lower-bound estimate obtained with the command {help regress:regress} and an upper-bound estimate obtained with the command 
{help ivregress:ivregress}. See {help igesetci##references:Mitnik (Forthcoming)} for details regarding the set estimation of IGEs. 

{marker remarks}{...}
{title:Remarks and related commands}

{pstd}
While {cmd:igesetci} is a {it: post-estimation} command, {cmd: igeset} (see {help igeset:igeset} if installed) is a closely related {it: estimation} command that both set estimates IGEs and computes the confidence intervals computed 
by {cmd:igesetci} in one pass, but at the cost of some loss of flexibility for the user (e.g., {cmd:igeset} allows the user less control of optimization options, gmm options, VCE options and so forth). 

{pstd}
The confidence intervals for a partially identified parameter computed by {cmd:igesetci} are valid when there is one lower-bound estimate and one upper-bound estimate, and where these estimates are 
produced by estimators that are consistent and asymptotically normally distributed (see {help igesetci##references:Mitnik [Forthcoming]} for a brief discussion of the rationale of, and formulae for the computation of, these confidence 
intervals). There are cases, however, in which the upper-bound (lower-bound) estimate is defined as the minimum (maximum) of a set of a estimates. In the estimation of IGEs, this happens when the upper-bound is estimated more than 
once with different sets of instruments. The command {cmd: igeintb} (see {help igeintb:igeintb} if installed) both set estimates IGEs and computes appropriate confidence intervals in this context. 

{marker examples}{...}
{title:Examples}

{pstd}Read and describe data{p_end}

     .{stata "use igesetci_data, clear"}
     .{stata "describe"}

{pstd}IGE of the expectation: Three examples of set estimation followed by the computation of confidence interval/s{p_end}

     .{stata "poisson c_inc p_ln_inc, robust"}  
     .{stata "estimates store poi"}  
     .{stata "ivpoisson gmm c_inc (p_ln_inc = p_educ)"} 
     .{stata "estimates store ivp_educ"}  
     .{stata "igesetci c_inc p_ln_inc, lb(poi) ub(ivp_educ) ige(igee)"}  

     .{stata "poisson c_inc c.p_age c.p_age#c.p_age p_ln_inc [pw = c_wcore]"} 
     .{stata "estimates store poi"}  
     .{stata "ivpoisson gmm c_inc c.p_age c.p_age#c.p_age (p_ln_inc = i.p_occ) [pw = c_wcore]"}
     .{stata "estimates store ivp_occ"}  
     .{stata "igesetci c_inc p_ln_inc, lb(poi) ub(ivp_occ) ige(igee) ci(nr)"}  

     .{stata "poisson c_inc p_ln_inc, robust"}  
     .{stata "estimates store poi"}  
     .{stata "ivpoisson gmm c_inc (p_ln_inc = c.p_educ c.p_educ#c.p_educ i.p_occ)"}  
     .{stata "estimates store ivp_educ_occ"}  
     .{stata "igesetci c_inc p_ln_inc, lb(poi) ub(ivp_educ_occ) ige(igee) ci(imnr)"}  

{pstd}IGE of the geometric mean: Three examples of set estimation followed by the computation of confidence interval/s{p_end}

     .{stata "regress c_ln_inc p_ln_inc, robust"}  
     .{stata "estimates store ols"}  
     .{stata "ivregress 2sls c_ln_inc (p_ln_inc = p_educ), robust"}  
     .{stata "estimates store iv_educ"}  
     .{stata "igesetci c_ln_inc p_ln_inc, lb(ols) ub(iv_educ) ige(igeg)"} 

     .{stata "regress c_ln_inc c.p_age c.p_age#c.p_age p_ln_inc [pw = c_wcore]"} 
     .{stata "estimates store ols"}  
     .{stata "ivregress 2sls c_ln_inc c.p_age c.p_age#c.p_age (p_ln_inc = i.p_occ) [pw = c_wcore]"}  
     .{stata "estimates store iv_occ"}  
     .{stata "igesetci c_ln_inc p_ln_inc, lb(ols) ub(iv_occ) ige(igeg) ci(nr)"}  

     .{stata "regress c_ln_inc p_ln_inc, robust"}  
     .{stata "estimates store ols"}  
     .{stata "ivregress gmm c_ln_inc (p_ln_inc = c.p_educ c.p_educ#c.p_educ i.p_occ)"}  
     .{stata "estimates store iv_educ_occ"}  
     .{stata "igesetci c_ln_inc p_ln_inc, lb(ols) ub(iv_educ_occ) ige(igeg) ci(imnr)"} 

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:igesetci} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}{cmd:igesetci}{p_end}
{synopt:{cmd:r(ige)}}igee or igeg {p_end}
{synopt:{cmd:r(ci)}}type of confidence interval: im, nr, or imnr{p_end}
{synopt:{cmd:r(model_lb)}}name of lower-bound model {p_end}
{synopt:{cmd:r(model_ub)}}name of upper-bound model {p_end}

{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(pe_lb)}}lower bound of set estimate{p_end}
{synopt:{cmd:r(pe_ub)}}upper bound of set estimate {p_end}
{synopt:{cmd:r(ci_im_lb)}}lower bound of IM confidence interval for partially identified IGE{p_end}
{synopt:{cmd:r(ci_im_ub)}}upper bound of IM confidence interval for partially identified IGE{p_end}
{synopt:{cmd:r(c)}}critival value used to construct IM confidence interval{p_end}
{synopt:{cmd:r(ci_nr_lb)}}lower bound of NR confidence interval for partially identified IGE{p_end}
{synopt:{cmd:r(ci_nr_ub)}}upper bound of NR confidence interval for partially identified IGE{p_end}
{synopt:{cmd:r(k)}}critival value used to construct NR confidence interval{p_end}
{synopt:{cmd:r(confidence_level)}}confidence level{p_end}

{marker author}{...}
{title:Author}

{pstd}
Pablo A. Mitnik, Center on Poverty and Inequality, Stanford University.

{title:Suggested citation if using {cmd:igesetci} in published work}

{pstd}
{cmd:igesetci} is not an official Stata command. It is a free contribution to the research community, produced jointly with {help igesetci##references:Mitnik (Forthcoming)}. Citation of this paper when using {cmd:igesetci} would be appreciated. 

{marker references}{...}
{title:References}

{pstd} Imbens, Guido and Charles Manski. 2004. "Confidence Intervals for Partially Identified Parameters." {it: Econometrica} 72(6): 1845-1857.{p_end}
{pstd} Mitnik, Pablo. Forthcoming. "Intergenerational Income Elasticities, Instrumental Variable Estimation and Bracketing Strategies." {it:Sociological Methodology}.{p_end}
{pstd} Mitnik, Pablo and David Grusky. Forthcoming. "The Intergenerational Elasticity of What? The Case for Redefining the Workhorse Measure of Economic Mobility." {it:Sociological Methodology}.{p_end}
{pstd} Nevo, Aviv and Adam Rosen. 2012. "Identification with Imperfect Instruments." {it: The Review of Economics and Statistics} 94(3): 659-671.{p_end}

{marker disclaimer}{...}
{title:Disclaimer}

{pstd}
{cmd:igesetci} is provided as is, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and 
noninfringement. 



