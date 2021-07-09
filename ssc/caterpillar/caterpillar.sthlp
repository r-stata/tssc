{smcl}
{* 4 January 2018}{…}
{hline}
help for {hi:caterpillar} 
{hline}

{title:Title}

{pstd}{cmd:caterpillar} - Given a set of estimates and standard errors, generate confidence intervals, Bonferroni-corrected confidence intervals, and null distribution.

{title:Syntax}

{pstd}{cmd:caterpillar} {it:est} {it:se} {it:id} {ifin}, [saving(dataset) by(id) {it: options}]

{synoptset 25 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{synopt :{opt center}} If specified, centers estimates around their precision-weighted mean and creates new variable, {it:contrast}. 
{p_end}

{synopt :{opt graph}} If specified, creates graph of estimates (centered if {it:center} is also used), 95% pointwise confidence intervals, Bonferroni-corrected confidence intervals, and null distribution. Cannot be used with -by-.  
{p_end}

{title:Description}

{pstd}{cmd:caterpillar} takes a set of estimates {it:est} and standard errors {it:se}, along with a unique identifier {it:id} for each estimate. 
The estimates may represent the effects of different programs (as in von Hippel & Bellows, 2017) or the results of different studies (as in a meta-analysis).

{pstd}{cmd:caterpillar} outputs a "caterpillar plot" containing point estimates (sorted in ascending order), along with 95% pointwise confidence intervals, Bonferroni-corrected 95% confidence intervals, and an estimate of the null distribution. 
The null distribution represents what the distribution of estimates would look like under homogeneity -- i.e., if there were no differences between the effects, and the estimates differed only because of random estimation error.

{pstd}{cmd:caterpillar} prints summary statistics on the plot, including Cochran's Q test (with degrees of freedom and p value), a method-of-moments estimate of the heterogeneity standard deviation (tau), and the Higgins-Thompson estimate of the reliability (rho). All calculations described in von Hippel and Bellows (2018). 

{pstd}The program generates five variables, {it:CI_lo}, {it:CI_hi}, {it:CI_lo_bon}, {it:CI_hi_bon}, and {it:null_quantile}, that contain the confidence intervals and quantiles of the null distribution. 

{pstd}{cmd:caterpillar} optionally saves Cochran's Q test, degrees of freedom for Cochran's Q, p value for Cochran's Q, the heterogeneity standard deviation, and the reliability into a separate dataset. 


{title:Remarks} 

{pstd}{cmd:caterpillar} requires that {cmd:_gwtmean} be installed from SSC. 

{pstd}{cmd:caterpillar} requires a unique identifier for estimates and will not complete if a unique identifier is not given. If the -by- option is used, {cmd:caterpillar} requires that the identifier is unique within each group. 

{title:Examples}

{pstd}This example uses the dataset {it:caterpillar_replication.dta} to replicate some results from von Hippel & Bellows (2018). 
To replicate von Hippel & Bellows more completely, run the code in {it:vonHippelBellows2018.do}. 

Use install {it:caterpillar_replication.dta} and {it:vonHippelBellows2018.do} in the working directory, run {}cmd:ssc install caterpillar, all}.

. // Graph CIs, Bonferroni-corrected CIs, and null distribution 
. // for all New York City teacher preparation programs (TPPs) in math
. use caterpillar_replication, clear
. caterpillar est se tpp if state=="NYC" & subject=="Math" ///
. 	& size=="All", graph center

. // Re-graph without the outlier. 
. // The Q test becomes non-significant, and 
. // the heterogeneity and reliability estimates go to 0.
. use caterpillar_replication, clear
. caterpillar est se tpp if state=="NYC" & subject=="Math" ///
. 	& size=="All" & est<.4, graph center

. // Generate the same statistics (except for graph) separately for different states and test subjects (math, reading, etc.), 
. //  as well as different data subsets and modeling decisions described in von Hippel & Bellows (2018).
. use caterpillar_replication, clear
. caterpillar est se tpp, by(state subject size schlfe experienced se_inflation) ///
. 	center saving(tpp_estimates, replace)

{title:Saved Results}

{pstd}Scalars: {p_end}

{pstd}{cmd:r(Q)}{space 6}Cochran's Q statistic {p_end}
{pstd}{cmd:r(df)}{space 5}Degrees of freedom for Cochran's Q statistic {p_end}
{pstd}{cmd:r(p)}{space 6}P-value for Cochran's Q statistic {p_end}
{pstd}{cmd:r(tau)}{space 4}Heterogeneity standard deviation {p_end}
{pstd}{cmd:r(rho)}{space 4}Reliability {p_end}

{pstd}Matrices: {p_end}

{pstd}If -by- is used, instead of scalars, statistics are saved into vectors. Also, a local macro {cmd:r(levels)} holds the -by- levels for reference. 

{pstd}{cmd:r(Q)}{space 6} Vector of Cochran's Q statistics, by group {p_end}
{pstd}{cmd:r(df)}{space 5} Vector of degrees of freedom for Cochran's Q statistic, by group  {p_end}
{pstd}{cmd:r(p)}{space 6} Vector of p-values for Cochran's Q statistic, by group {p_end}
{pstd}{cmd:r(tau)}{space 4} Vector of heterogeneity standard deviation, by group  {p_end}
{pstd}{cmd:r(rho)}{space 4} Vector of reliabilities, by group {p_end}

{title:Authors} 

{pstd}Laura Bellows, Duke University, USA{break}
laura.bellows@duke.edu

{pstd}Paul von Hippel, University of Texas at Austin, USA{break}
paulvonhippel.utaustin@gmail.com


{title:References}

{pstd}von Hippel, Paul T., and Laura Bellows (2018). "How Much Does Teacher Quality Vary Across Teacher Preparation Programs? Reanalyses from 6 States." Economics of Education Review, in press. 
Also available as SSRN Working Paper, https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2990498.

{pstd}Higgins, J. P. T., & Thompson, S. G. (2002). Quantifying heterogeneity in a meta-analysis. Statistics in Medicine, 21(11), 1539–1558. https://doi.org/10.1002/sim.1186

{title:Also see} 

{pstd}von Hippel, Paul T., Laura Bellows, Cynthia Osborne, Jane Lincove, and Nicholas Mills (2016). "Teacher Quality Differences Between Teacher Preparation Programs: How Big? How Reliable? Which Programs Are Different?" {it}Economics of Education Review 53, {sf}31-45. doi:10.1016/j.econedurev.2016.05.002 


