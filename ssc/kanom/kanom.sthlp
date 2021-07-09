{smcl}
{* *! version 1.0  31Mar2016}{...}
{viewerdialog kanom "dialog kanom"}{...}
{viewerjumpto "Syntax" "kanom##syntax"}{...}
{viewerjumpto "Description" "kanom##description"}{...}
{viewerjumpto "Options" "kanom##options"}{...}
{viewerjumpto "Comparison with others commands/software" "kanom##comparison"}{...}
{viewerjumpto "Examples" "kanom##examples"}{...}
{viewerjumpto "Stored results" "kanom##results"}{...}
{viewerjumpto "Author and suggested citation" "kanom##author"}{...}
{viewerjumpto "References" "kanom##references"}{...}
{viewerjumpto "Disclaimer" "kanom##disclaimer"}{...}
{title:Title}

{phang}
{bf:kanom} {hline 2} Krippendorff's alpha for nominal variables

{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:kanom} {it:{help varname:varname1}} {it:{help varname:varname2}}
[{cmd:,} {it:{help kanom##options_table:options}}]

{synoptset 14 tabbed}{...}
{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt :{opt w:var}}weight variable{p_end}
{synopt :{opt c:var}}cluster variable{p_end}
{synopt :{opt s:var}}stratum variable{p_end}
{synopt :{opt noi:nf}}skips inference {p_end}

{synoptline}
{p2colreset}{...}
{marker weight}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:kanom} computes points estimates and 95 percent confidence intervals for Krippendorff's reliability coefficient alpha, for nominal
variables and two measurements. It also tests the null hypotheses that alpha is not larger than 0.67, 0.75 and 0.80, and reports the
corresponding p-values. Calculations are based on the "delta method" (an approximation appropriate in large samples), and optionally take
into account the main features of a complex sampling design. 

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt wvar(varname)} specifices a sampling weight variable.

{phang}
{opt cvar(varname)} specifies that the observations are independent across groups (clusters)
               but not necessarily within groups; varname specifies to which group each
               observation belongs.               
               
{phang}
{opt svar(varname)} specifies the name of a variable that contains sampling stratum identifiers.

{phang}
{opt noinf} specifies that only point estimates be computed; this may be useful when the variables have {bf:many} values, as in that case computing confidence intervals and conducing hypothesis tests may become very slow. 

{marker comparison}{...}
{title:Comparison with other commands/software}

{pstd}
Unlike the previously existing Stata command {cmd:krippalpha}, SAS and SPSS macros "kalpha" (Hayes and Krippendorff 2007), and R package "irr," {cmd:kanom} 
allows taking into account the main features of complex survey designs (sampling weights, clusters, strata). Unlike {cmd:krippalpha} and "irr," {cmd:kanom}
produces confidence intervals and tests the null hypotheses that alpha is not larger than 0.67, 0.75, and 0.8. Unlike the SAS and SPSS macros, which
base statistical inference on the nonparametric bootstrap, in {cmd:kanom} inference is based on the delta method. The previously existing programs, however,
allow computation of Krippendorff's alpha for variables with various metrics, not just the nominal metric.

{marker examples}{...}
{title:Examples}

{phang2}{cmd:. sysuse kanom_exfile.dta", clear}{p_end}

{phang2}{cmd:. kanom measure1 measure2}{p_end}

{phang2}{cmd:. kanom measure1 measure2, wvar(sampwgt)}{p_end}

{phang2}{cmd:. kanom measure1 measure2, wvar(sampwgt) noinf} {p_end}

{phang2}{cmd:. kanom measure1 measure2, wvar(sampwgt) cvar(cluster) svar(strat)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:kanom} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(pe)}}point estimate{p_end}
{synopt:{cmd:e(lb)}}lower bound{p_end}
{synopt:{cmd:e(ub)}}upper bound{p_end}
{synopt:{cmd:e(se)}}standard error{p_end}
{synopt:{cmd:e(p_67)}}p-value of H0 that alpha < 0.67{p_end}
{synopt:{cmd:e(p_75)}}p-value of H0 that alpha < 0.75{p_end}
{synopt:{cmd:e(p_80)}}p-value of H0 that alpha < 0.80{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:kanom}{p_end}
{synopt:{cmd:e(var1)}}name of variable 1{p_end}
{synopt:{cmd:e(var2)}}name of variable 2{p_end}
{synopt:{cmd:e(wvar)}}name of weight variable{p_end}
{synopt:{cmd:e(cvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(svar)}}name of stratum variable{p_end}

{marker author}{...}
{title:Author}

{p 4 4 2} Pablo A. Mitnik, Center on Poverty and Inequality, Stanford University

{title:Suggested citations if using {cmd:kanom} in published work }

{p 4 4 2}{cmd:kanom} is not an official Stata command. It is a free contribution to the research community, produced as a companion to Mitnik and Cumberworth (2016). Citation of this paper when using {cmd:kanom} would be appreciated. 

{marker references}{...}
{title:References}

{p 4 4 2} Hayes, Andrew, and Klaus Krippendorff. 2007. "Answering the Call for a Standard Reliability Measure for Coding Data." {it:Communication Methods and Measures} 1(1):77-89.

{p 4 4 2} Krippendorff, Klaus. 2013. {it:Content Analysis: An Introduction to its Methodology} (3rd edition). Los Angeles: Sage.

{p 4 4 2} Mitnik, Pablo and Erin Cumberworth. 2016. "Measuring Social Class Trends with Changing Occupational Classifications: Reliability, Competing Measurement Strategies, and the 1970-1980 U.S. Classification Divide."
Stanford Center on Poverty and Inequality Working Paper.

{marker disclaimer}{...}
{title:Disclaimer}

{p 4 4 2} {cmd:kanom} is provided as is, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. 





