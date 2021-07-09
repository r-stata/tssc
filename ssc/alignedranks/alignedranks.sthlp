{smcl}
{* *! version 1.0.0  18jul2014}{...}
{cmd:help alignedranks}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:alignedranks}{hline 2}}Two-sample aligned rank-sum (Hodges-Lehmann) test with exact statistics for small samples{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 19 2}
		{cmd:alignedranks} {depvar} {ifin} {cmd:,} {cmd:by(}{it:{help varlist:groupvar}}{cmd:)} 
		[ {opt s:trata}({it:{help varlist:varlist}}) {opt loc:ation}({it:string}) {opt ex:act} {cmd:porder} ]
		

{synoptset 21 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Main}
{p2coldent:* {opth by:(varlist:groupvar)}}grouping variable{p_end}
{synopt :{opth s:trata(varlist:varlist)}}stratify on {it:varlist}{p_end}
{synopt :{opt loc:ation(string)}}measure of location with which alignment is performed (i.e., mean, median, etc.) {p_end}
{synopt :{opt ex:act}}request that exact {it:p}-values be estimated if the total size of the two samples is <= 25{p_end}
{synopt :{opt porder}}probability that {it:depvar} for the first group is larger than {it:depvar} for the second group{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt by(groupvar)} is required.{p_end}
{p 4 6 2}{opt by} is allowed with {cmd:alignedranks};
see {manhelp by D}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:alignedranks} tests the hypothesis that two independent {it:stratified} samples are from populations with the same distribution. 
Hodges & Lehmann (1962) developed an approach that involves ranking observations after they have undergone alignment 
within their respective strata, thereby removing strata-specific effects from the data. The alignment is done by subtracting a symmetric 
and translation-invariant measure of location (i.e., mean, median, etc.) from each observation within their corresponding stratum. These 
transformed observations are then ranked without respect to treatment assignment or strata, followed by the application of the Wilcoxon 
rank-sum test (also known as the Mann-Whitney two-sample statistic) to estimate treatment effects. 


{marker options_alignedranks}{...}
{title:Options}

{dlgtab:Main}

{phang}
{cmd:by(}{it:{help varlist:groupvar}}{cmd:)} is required.  It specifies the
name of the grouping variable.

{phang}
{cmd:strata(}{it:{help varlist:varlist}}{cmd:)} specifies the variable on which to stratify the analysis. Observations will be 
ignored for missing values of {cmd:strata}. If {cmd:strata()} is not specified, {cmd:alignedranks} defaults to {manhelp ranksum R} 
and no alignment is performed.

{phang}
{cmd:location(}{it:string}{cmd:)}  When {cmd:strata()} is specified, {cmd:location} represents the measure of location with which alignment is performed.
Available {cmd:location} types are {it:mean}, {it:median}, {it:sd}, and {it:hl} (see the {cmd:Remarks} section below for discussion); default is {it:mean}. 

{phang}
{opt exact} requests that exact {it:p}-values be estimated if the total size of the two samples is <= 25, according to the method described in 
Harris & Hardin (2013) and implemented in {helpb ranksumex}.

{phang}
{opt porder} displays an estimate of the probability that a random draw from the first population is larger than a random draw from the second 
population.

{synoptline}

{marker remarks}{...}
{title:Remarks}

{pstd} 
Lehmann (2006, p. 140) suggests that any measure of location may be used for alignment, with the only stipulation being that the same transformation
is applied to all observations within the same stratum, thereby preserving the validity of the null distribution. Mehrotra et al. (2010) report achieving 
more robust results with the Hodges–Lehmann estimator of location than when using either the sample mean or median of the pooled responses in each stratum.
The Hodges–Lehmann estimator of location (Hodges & Lehmann, 1963) can be defined as the median of all pairwise means of the pooled responses in each stratum.
It is computed by first generating all unique pairwise combinations of {it: depvar} within each stratum (equalling the combinatorial function 
of [n!/{k!(n - k)!], where n is the total number of observations in the stratum, and k = 2). Next, the mean is computed for each pair, and finally, the median 
of all pairwise means is estimated.

{pstd}
Given the iterative process involved in computing the Hodges–Lehmann estimator of location, users can expect {cmd:alignedranks} to return results slowly in large
data sets when the {cmd:location(}{it:hl}{cmd:)} option is specified. In timing the command with various sample sizes, {cmd:alignedranks} returned results in 4.93 seconds with a sample size of 1003 (275 strata); 
10.71 seconds when N = 10,030 (275 strata); 75.35 seconds when N = 100,300 (275 strata); and 882.93 seconds when N = 1,003,000 (275 strata). These tests were 
performed using Stata SE/13.1 on a MS Windows 7.0, 64-bit operating system with an Intel(R) Core(TM) Duo CPU, 3.0 GHz processor and 4.0 GB of RAM. 


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Load example data{p_end}
{p 4 8 2}{stata "webuse cattaneo2, clear":. webuse cattaneo2, clear}{p_end}

{pstd}Perform aligned rank-sum test on {cmd:bweight} by using the two groups defined by
{cmd:mbsmoke} and specifying {cmd:medu} as the strata variable {p_end}
{p 4 8 2}{stata "alignedranks bweight, by(mbsmoke) strata(medu)":. alignedranks bweight, by(mbsmoke) strata(medu)}{p_end}

{pstd}Same as above, but specify {it:hl} as the location measure, and include an estimate of the probability that the value of
{cmd:bweight} for an observation with {cmd:mbsmoke} = 0 is greater than the value of {cmd:bweight} for an observation when {cmd:mbsmoke} = 1{p_end}
{p 4 8 2}{stata "alignedranks bweight, by(mbsmoke) strata(medu) location(hl) porder":. alignedranks bweight, by(mbsmoke) strata( medu) location(hl) porder}{p_end}

{pstd}We now limit the dataset to 12 observations from each {cmd:mbsmoke} group, and specify the {it:exact} option to get exact statistics. {p_end}
{p 4 8 2}{stata "sample 12, by(mbsmoke) count":. sample 12, by(mbsmoke) count}{p_end}
{p 4 8 2}{stata "alignedranks bweight, by(mbsmoke) strata(medu) location(median) porder exact":. alignedranks bweight, by(mbsmoke) strata(medu) location(median) porder exact}{p_end}

    {hline}


{marker saved_results}{...}
{title:Saved results}

{pstd}{cmd:alignedranks} saves the following in {cmd:r()} if n>25:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N_1)}}sample size n_1{p_end}
{synopt:{cmd:r(N_2)}}sample size n_2{p_end}
{synopt:{cmd:r(z)}}z statistic{p_end}
{synopt:{cmd:r(Var_a)}}adjusted variance{p_end}
{synopt:{cmd:r(group1)}}value of variable for first group{p_end}
{synopt:{cmd:r(sum_obs)}}actual sum of ranks for first group{p_end}
{synopt:{cmd:r(sum_exp)}}expected sum of ranks for first group{p_end}
{synopt:{cmd:r(porder)}}probability that draw from first population is larger than draw from second population{p_end}


{pstd}{cmd:alignedranks} saves the following in {cmd:r()} if n<=25:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(x1)}}value (x) of the distribution such that P(X<=x1){p_end}
{synopt:{cmd:r(x2)}}value (x) of the distribution such that P(X>=x2){p_end}
{synopt:{cmd:r(nx1)}}numerator of probability for P(X<=x1){p_end}
{synopt:{cmd:r(nx2)}}numerator of probability for P(X>=x2){p_end}
{synopt:{cmd:r(den)}}denominator of probabilities{p_end}
{synopt:{cmd:r(p)}}p-value = P(X<=x1) + P(X>=x2){p_end}


{p2colreset}{...}


{marker references}{...}
{title:References}

{phang}
Harris, T., and J. W. Hardin. 2013. Exact Wilcoxon signed-rank and Wilcoxon Mann–Whitney ranksum tests. 
{it:Stata Journal} 13: 337-343.

{phang}
Hodges, J. L., and E. L. Lehmann. 1962. Rank methods for combination of
independent experiments in the analysis of variance. 
{it:Annals of Mathematical Statistics} 33: 482–497.

{phang}
Hodges, J. L., and E. L. Lehmann. 1963. Estimation of location based on ranks. 
{it: Annals of Mathematical Statistics} 34: 598–611.

{phang}
Lehmann, E. L. 2006. {it: Nonparametrics: statistical methods based on ranks (Rev. ed.)}
New York: Springer. 
 
{phang}
Mann, H. B., and D. R. Whitney. 1947. On a test whether one of two random
variables is stochastically larger than the other.
{it:Annals of Mathematical Statistics} 18: 50-60.

{phang}
Mehrotra, D. V., Lu, X. and X. Li. 2010. Rank-based analyses of stratified experiments:
alternatives to the van Elteren Test. {it: The American Statistician} 64: 121-130. 

{phang}
McNeil, R. B., and R. F. Woolson. 2007. Aligned Rank Test. {it: Wiley Encyclopedia of Clinical Trials}. 1–4.

{phang}
Wilcoxon, F. 1945. Individual comparisons by ranking methods.
{it:Biometrics} 1: 80-83.{p_end}


{marker citation}{title:Citation of {cmd:alignedranks}}

{p 4 8 2}{cmd:alignedranks} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel. 2014. 
alignedranks: Stata module for implementing a two-sample aligned rank-sum (Hodges-Lehmann) test with exact statistics for small samples.
{p_end}

{title:Author}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
Ann Arbor, MI, USA{break} 
{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{break}
{browse "http://www.lindenconsulting.org"}{p_end}

        
{title:Acknowledgments} 

{p 4 4 2}
I wish to thank Nicholas J. Cox for his support while developing {cmd:alignedranks}{p_end}


{title:Also see}

{p 4 8 2}Online:  {helpb ranksum}, {helpb egen }(rank() function), {helpb emh} (if installed), 
{helpb vanelteren} (if installed), {helpb ranksumex} (if installed), {helpb somersd} (if installed){p_end}
