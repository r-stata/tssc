{smcl}
{* *! version 1.2.1  07mar2013}{...}
{vieweralsosee "tesensitivity" "tesensitivity"}{...}
{viewerjumpto "Syntax" "tesensitivity_cpi##syntax"}{...}
{viewerjumpto "Description" "tesensitivity_cpi##description"}{...}
{viewerjumpto "Options" "tesensitivity_cpi##options"}{...}
{viewerjumpto "Remarks" "tesensitivity_cpi##remarks"}{...}
{viewerjumpto "Stored Results" "tesensitivity_cpi##results"}{...}
{viewerjumpto "Examples" "tesensitivity_cpi##examples"}{...}
{title:Title}

{phang}
{cmd:tesensitivity cpi} {hline 2} Conditional partial independence analysis

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:tesensitivity cpi}
({it:{help varname:ovar} {help varlist:omvarlist}}) ({it:{help varname:tvar} {help varlist:tmvarlist}})
{ifin}
[{cmd:,} 
{it:{help tesensitivity_cpi##stat:stat}} {help tesensitivity_cpi##stat_options:stat_options} 
{help tesensitivity_cpi##general_options:general_options}]

{phang}
{it:ovar} is a continuous or binary outcome of interest.

{phang}
{it:omvarlist} specifies the covariates in the outcome model.

{phang}
{it:tvar} is a binary variable representing treatment.

{phang}
{it:tmvarlist} specifies the covariates in the treatment-assignment model.

{synoptset 20 tabbed}{...}
{marker stat}{...}
{synopthdr:stat}
{synoptline}
{synopt:{opt ate}}Average Treatment Effect; the default{p_end}
{synopt:{opt atet}}Average Treatment Effect on the Treated{p_end}
{synopt:{opt qte}}Quantile Treatment Effect{p_end}
{synopt :{opt cqte}}Conditional Quantile Treatment Effect{p_end}
{synopt :{opt cate}}Conditional Average Treatment Effect{p_end}
{synoptline}
{p 4 6 2}
{it:stat} specifies the treatment effect statistic that will be analyzed

{synoptset 20 tabbed}{...}
{marker stat_options}{...}
{synopthdr:stat_options}
{synoptline}
{synopt:{opt q:uantile(#)}}treatment effect quantile for quantile statistics (qte, cqte){p_end}
{synopt:{opt med:ian}}calculate conditional statistics (cqte, cate) at median; evaluted at mean by default{p_end}
{synopt:{opt cov:supp}({it:{help tesensitivity_cpi##cov_spec:cov_spec}})}support points of covariates for conditional stastics (cqte, cate) {p_end}
{synopt:{opt qcov:supp}({it:{help tesensitivity_cpi##cov_spec:cov_spec}})}quantiles of support points of covariates for conditional stastics (cqte, cate) {p_end}
{synoptline}
{p 4 6 2}
{it:stat_options} specify options for the statistic selected

{synoptset 20 tabbed}{...}
{marker general_options}{...}
{synopthdr:general_options}
{synoptline}
{syntab: Main}
{synopt:{opt c:grid(#)}}number of values in grid of c-dependence levels{p_end}
{synopt:{opt cref:erence}}include reference c-dependence levels from leave-one-out analysis (see below){p_end}
{synopt:{opt break:down(#)}}calculate breakdown point for stat > #; default 0{p_end}
{synopt:{opt nobreak:down}}don't calculate breakdown point

{syntab:Tuning options}
{synopt:{opt nodes(#)}}number of interpolation nodes used to approximate integrals{p_end}
{synopt:{opt tol(#)}}maximum error in calculation of breakdown point{p_end}

{syntab:Display options}
{synopt:{opt verbose}}display progress bars for long computations{p_end}
{synoptline}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:tesensitivity cpi} estimates bounds on the treatment effect statistic selected 
maintaining the assumption of conditional c-dependence. Bounds are calculated for 
a uniform grid of c-dependence values from 0 to 1 with the number of point set by
the {cmd:cgrid} option. The breakdown point for the conclusion
that {it: stat} > {it:breakdown} is also calculated unless {cmd:nobreakdown} is selected.
Results of the analysis are displayed in a table and saved in {cmd:e()}. For details 
on conditional c-dependence and the breakdown point see Remarks.  

{marker options}{...}
{title:Options}

{dlgtab:Stat}

{phang}
{it: stat} is one of five treatment effect statistics: {cmd:ate}, {cmd:atet}, 
{cmd:qte}, {cmd:cate}, or {cmd:cqte}. {cmd:ate} is the default. Only one 
statistic can be specified.

{pmore}
{cmd:ate} specifies that the average treatment effect be analyzed.

{pmore}
{cmd:atet} specifies that the average treatment effect on the treated be analyzed.

{pmore}
{cmd:qte} specifies that the quantile treatment effect be analyzed.

{pmore}
{cmd:cate} specifies that the conditional average treatment effect be analyzed.

{pmore}
{cmd:cqte} specifies that the conditional quantile treatment effect be analyzed.

{dlgtab:Stat options}

{p 4 4 2}
{it: stat_options} apply to the particular treatment effect statistic chosen. 
For conditional statistics, these set the support point of the covariates that
the treatment effect is conditional on. For quantile statistics, these set the
quantile of the treatment effect distribution.

{pmore}
{cmd:quantile(#)} specifies quantiles for (conditional) quantile treatment effects
stasitics. If no quantile is specified, the default option is 0.5.

{pmore}
{cmd:median} By default conditional statistics are calculated at the mean of the
covariates. This switches the default to the median.

{pmore}
{cmd:covsupp}({it:cov_spec}) directly specifies covariate support points for conditional 
quantile statistics. See below for input formats.

{pmore}
{cmd:qcovsupp}({it:cov_spec}) specifies quantiles of covariate support points for 
conditional quantile statistics. See below for input formats.


{marker cov_spec}{...}
{p 12 12 4}
In the previous two options, {it:cov_spec} is a covariate specification. 
This can be in three formats:

{p 14 14 4}
1. list of values separated with spaces

{p 14 14 4}
2. 1 x K unlabeled matrix 

{p 14 14 4}
3. 1 x S matrix with column names corresponding to covariate variable names 

{p 12 12 4} where K is the number of covariates, and S <= K. If formats 1 or 2 
are used, values must be provided for all covariates and
they must be in the same order as they were in {it:tmvarlist} and/or {it:omvarlist}. 
If format 3 is used, it is not necessary to specify
the support for all covariates. Covariates not included will be evaluated at the
mean by default or at the median if the {cmd:median} option is selected. If format 3
is used, it is also possible to used both the {cmd:covariates} and {cmd:qcovariates}
options for different covariates.

{dlgtab:General options}

{phang}
Main

{pmore}
{opt cgrid(#)} specifies the number of values of c in a uniform grid over [0,1]. 
If not specified, the default is 40.

{pmore}
{opt creference} if selected, also calculate bounds on {it: stat} for values of
c corresponding to the maximum propensity score deviation in the leave-one-out
analysis for each covariate. For details see Remarks.

{pmore}
{opt breakdown(#)} specifies the conclusion for which the breakdown point is
calculated. The conclusion is: {it: stat} > #. For details see Remarks.

{pmore}
{opt nobreakdown} if selected, the breakdown point is not calculated.

{phang}
Tuning Parameters

{pmore}
{opt nodes(#)} specifies the number of Chebyschev nodes used in Piecewise Cubic Hermite Interpolating Polynomial (PCHIP) in the computation of integrals. If it is not specified, the default number of nodes is 100. For details see Remarks.

{pmore}
{opt tol(#)} specifies a tolerance for the precision of the breakdown point. The breakdown point is computed using bisection algorithm, so this is a tolerance criterion for the bisection algorithm. The default value is 0.001.

{phang}
Display Options

{pmore}
{opt verbose} prints updates on execution of the estimation and progress bars
for long computations.

{marker remarks}{...}
{title:Remarks}

{p 4 4 4}
See {help tesensitivity##further_information:here} for links to the articles 
this package is based on, more detailed documentation on the implementation in 
this package, and examples of its use.

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:tesensitivity cpi} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(y_breakdown)}}conclusion lower bound in breakdown point analysis (stat > y_breakdown){p_end}
{synopt:{cmd:e(c_breakdown)}}breakdown point relative to the conclusion specified{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:tesensitivity}{p_end}
{synopt:{cmd:e(subcmd)}}{cmd:cpi}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(stat)}}treatment effect statistic{p_end}
{synopt:{cmd:e(tvar)}}treatment variable{p_end}
{synopt:{cmd:e(properties)}}{cmd:b}{p_end}
{synopt:{cmd:e(depvar)}}outcome variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of bound estimates{p_end}
{synopt:{cmd:e(c_table)}}rectangular table of bound estimates and c-dependence values{p_end}
{synopt:{cmd:e(covsupp)}}matrix of covariate support{p_end}
{synopt:{cmd:e(cref)}}column vector of maximum deviations of covariates in leave-one-out analysis{p_end}

{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse lalonde1986, clear}{p_end}
{pstd}Loads LaLonde (1986) dataset included with tesensitivity package.

{phang}{cmd:. tesensitivity cpi (re78 age education) (treat age education) if sample1, ate}{p_end}
{pstd}
Calculates bounds on the average treatment effect for the model specified for a grid
of 40 values of c-dependence between 0 and 1, and the breakdown point for the
conclusion that {it:ATE} > 0. Displays a table with the results and stores the
results in {cmd:e()}.

{phang} For more examples see this {browse "https://github.com/mattmasten/tesensitivity/blob/master/vignette/vignette.pdf":vignette}.

