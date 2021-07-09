{smcl}
{* *! version 0.1.0  29may2016}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] ci" "help ci"}{...}
{vieweralsosee "[R] summarize" "help summarize"}{...}
{vieweralsosee "[R] tabstat" "help tabstat"}{...}
{vieweralsosee "[R] predict" "help predict"}{...}
{vieweralsosee "[D] egen" "help egen"}{...}
{vieweralsosee "[D] duplicates" "help duplicates"}{...}
{vieweralsosee " metareg" "help metareg"}{...}
{vieweralsosee " qqvalue" "help qqvalue"}{...}
{vieweralsosee " latabstat" "help latabstat"}{...}
{vieweralsosee " savesome" "help savesome"}{...}
{viewerjumpto "Syntax" "getmstatistic##syntax"}{...}
{viewerjumpto "Description" "getmstatistic##description"}{...}
{viewerjumpto "Options" "getmstatistic##options"}{...}
{viewerjumpto "Remarks" "getmstatistic##remarks"}{...}
{viewerjumpto "Examples" "getmstatistic##examples"}{...}
{title:Title}

{phang}
{bf:getmstatistic} {hline 2} Quantifying Systematic Heterogeneity in Meta-Analysis


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:getm:statistic}
[{varlist}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt nopri:nt}}suppress the display of results{p_end}
{synopt:{opt lat:exout}}display results as latex output{p_end}
{synopt:{opt nogr:aph}}suppress creation of graphs {p_end}
{synopt:{opt save:dataset}}save the dataset of computed M statistics{p_end}
{synopt:{opt mm:}}use method-of-moments to estimate tau2 {p_end}
{synopt:{opt reml:}}use residual maximum likelihood to estimate tau2 {p_end}
{synopt:{opt eb:}}use empirical Bayes to estimate tau2 {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is not allowed; see {manhelp by D}.{p_end}
{p 4 6 2}
{cmd:fweight}s are not allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:getmstatistic} -- computes M statistics to assess the contribution of each 
participating study in a meta-analysis. It's primary use is to identify outlier 
studies, which either show "null" effects or consistently show stronger or weaker 
genetic effects than average, across the panel of variants examined in a GWAS 
meta-analysis. In contrast to conventional heterogeneity metrics (Q-statistic, 
I-squared and tau-squared) which measure random heterogeneity at individual 
variants, the M-statistic measures systematic (non-random) heterogeneity across 
multiple independently associated variants.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt noprint} By default, the results are displayed in three tables(summary,
weaker studies and influential studies). The summary table reports the
number of variants, studies, expected mean, expected standard deviation and
the critical value for M at alpha = 0.05. The weaker and influential
studies tables report M statistics, confidence intervals and bonferroni adjusted
p-values of studies significant at the 5% level. {opt noprint} suppresses this
output.

{phang}
{opt latexout} Produces latex tables for the weaker and influential
studies that can be included in a report.

{phang}
{opt nograph} Suppresses the creation of graphs (three) showing: the M statistic values
of studies against the average variant effect-size in each study (with and without 
error bars). A histogram of the M statistics.

{phang}
{opt reml} Specifies the usage of residual maximum likelihood to estimate between-study 
heterogeneity.  
 {p_end}

{phang}
{opt mm} Specifies the usage of method-of-moments to estimate 
between-study heterogeneity. This is the default.
{p_end}

{phang}
{opt eb} Specifies the usage of empirical Bayes to estimate 
between-study heterogeneity. {p_end}

{phang}
{opt savedataset} Saves the dataset of computed M statistics, which includes the 
following variables: {p_end}

{p 16 25 2} Mstatistic {space 2} mean aggregate multi-variant heterogeneity statistic{p_end}
{p 16 25 2} M_se {space 8} standard error of M{p_end}
{p 16 25 2} lowerbound {space 2} lowerbound of M 95% confidence interval{p_end}
{p 16 25 2} upperbound {space 2} upperbound of M 95% confidence interval{p_end}
{p 16 25 2} bonfpvalue {space 2} 2-sided bonferroni pvalues of M{p_end}


{p 16 25 2} tau2 {space 8} tau_squared, REML estimates of between-study heterogeneity{p_end}
{p 16 25 2} I2 {space 10} I_squared, proportion of total variation due to between study variance{p_end}
{p 16 25 2} Q {space 11} Cochran's Q{p_end}
{p 16 25 2} xb {space 10} fitted values excluding random effects{p_end}
{p 16 25 2} usta {space 8} standardized predicted random effect (SPRE){p_end}
{p 16 25 2} xbu {space 9} fitted values including random effects{p_end}
{p 16 25 2} stdxbu {space 6} standard error of prediction (fitted values) including random effects{p_end}
{p 16 25 2} hat {space 9} diagonal elements of the projection hat matrix{p_end}
{p 16 25 2} study {space 7} study numbers{p_end}
{p 16 25 2} snp {space 9} variant numbers{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
For statistical theory behind the M statistic, see 
Magosi LE, Goel A, Hopewell JC, Farrall M, on behalf of the CARDIoGRAMplusC4D Consortium 
(2017) Identifying systematic heterogeneity patterns in genetic association meta-analysis 
studies. PLoS Genet 13(5): e1006755. https://doi.org/10.1371/journal.pgen.1006755 and 
{browse "https://magosil86.github.io/getmstatistic/":vignette}.

{marker examples}{...}
{title:Examples}

{phang}{cmd:abbreviations: beta_flipped (study effect-size) gcse (standard error) }{p_end}

    {hline}
    Setup
{phang2}{cmd:. use heartgenes214}{p_end}

{phang2}{cmd:. notes}{p_end}

{pstd}Compute M statistics; displays influential and weaker studies by default{p_end}
{phang2}{cmd:. getmstatistic beta_flipped gcse variants studies}{p_end}

{pstd}Compute M statistics; using method-of-moments to estimate tau2{p_end}
{phang2}{cmd:. getmstatistic beta_flipped gcse variants studies, mm}{p_end}

{pstd}Compute M statistics; save dataset containing computation results{p_end}
{phang2}{cmd:. getmstatistic beta_flipped gcse variants studies, savedataset}{p_end}

{pstd}Compute M statistics for a subset of the dataset; displays results as latex
tables and suppresses graphs{p_end}
{phang2}{cmd:. getmstatistic beta_flipped gcse variants studies if studies <= "10" in 1/1325, latex nograph}{p_end}

{pstd}Compute M statistics for a subset of variants and save dataset to extract Q-statistic and I-squared values; suppresses
graphical display and saves dataset{p_end}
{phang2}{cmd:. getmstatistic beta_flipped gcse variants studies if variants > "rs10071096" & variants <= "rs2891168", savedataset noprint}{p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:getmstatistic} stores the following in {cmd:r()}:

{synoptset 25 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(number_variants)}} number of variants{p_end}
{synopt:{cmd:r(number_studies)}} number of participating studies{p_end}
{synopt:{cmd:r(M_expected_mean)}} expected mean for M{p_end}
{synopt:{cmd:r(M_expected_sd)}} expected standard deviation for M{p_end}
{synopt:{cmd:r(M_crit_alpha_0_05)}} M critical at alpha=0.05{p_end}
{p2colreset}{...}


{title:References}

{phang}Harbord, R. M., & Higgins, J. P. T. (2008). Meta-regression in Stata.
{it:Stata Journal} 8: 493–519.

{title:Dependencies}
Commands that need to be installed for getmstatistic to work:
{help cii}
{help duplicates}
{help egen}
{help latabstat}
{help metareg}
{help savesome}
{help summarize}
{help tabstat}
{help qqvalue}


{title:Authors}

{pstd}Lerato E. Magosi, Jemma C. Hopewell and Martin Farrall{p_end}
{pstd}Wellcome Trust Centre for Human Genetics{p_end}
{pstd}University of Oxford, UK{p_end}
{pstd}{browse "mailto:lmagosi@well.ox.ac.uk":lmagosi@well.ox.ac.uk}{p_end}
{pstd}{browse "mailto:magosil86@gmail.com":magosil86@gmail.com}{p_end}

{title:Acknowledgments}
The code employs Roger M. Harbord's {cmd:metareg} command for computation of 
standardized predicted random effects which are then incorporated into calculations
for the M statistics.

