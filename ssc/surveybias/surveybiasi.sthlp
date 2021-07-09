{smcl}
{* *! version 1.4 Aug 07 2015}{...}
{vieweralsosee "surveybias" "help surveybias"}{...}
{viewerjumpto "Syntax" "surveybias##syntax"}{...}
{viewerjumpto "Description" "surveybias##description"}{...}
{viewerjumpto "Options" "surveybias##options"}{...}
{viewerjumpto "Remarks" "surveybias##remarks"}{...}
{viewerjumpto "Examples" "surveybias##examples"}{...}
{viewerjumpto "Saved Results" "surveybias##saved_results"}{...}
{title:Title}

{phang} {bf:surveybiasi} {hline 2} Immediate command for calculating
various measures of bias in survey

{phang}Command for raw data (single survey): {help surveybias}

{phang}Command for aggregated data (series of surveys): {help surveybiasseries}

{marker syntax}{...}
{title:Syntax}

{p 4 11 2}
{cmd:surveybiasi}
{cmd:,} {opt POP:values(#..#)} {opt SAMPLE:values(#..#)}
{opt n(#)} [{opt l:evel(#)}] [{opt prop}]
	
{marker description}{...}
{title:Description}

{pstd} {cmd:surveybiasi} compares the distribution of categorical
variable in a sample {opt SAMPLE:values(#..#)} to its true
distribution in the population, which is specified as a {help numlist}
in {opt POP:values(#..#)}


{marker options}{...}
{title:Options}

{phang} {opt POP:values} specify distribution of in the population.
Must not be omitted. Distribution can be given as counts or relative
frequencies, as it is rescaled to unity.

{phang} {opt SAMPLE:values} specify distribution of variable in the
population. Must not be omitted. Distribution can be given as counts
or relative frequencies, as it is rescaled to unity.

{phang}
{opt n(#)} specifies sample size. Must not be omitted.

{phang}
{opt prop} Switch to estimation via {cmd:proportion}. Chiefly used for testing.


{phang}
{opt l:evel(#)} sets the confidence level.

{marker remarks}{...}
{title:Remarks}

{pstd} The number of categories must not exceed twelve. The order of
categories must match. For detailed information on A', B and B_w, see
{it: Arzheimer, Kai and Jocelyn Evans, A New Multinomial Accuracy Measure}
{it: for Polling Bias, Political Analysis, Political Analysis 2014 (22), 31-44.}
{browse "http://dx.doi.org/10.1093/pan/mpt012"}

{pstd} Proportions must be strictly positive. If a category is not
observed at all, consider merging it with other categories. If the
category needs to be retained, you may enter its proportion as a very
small fraction (say 10^-6), but the estimates could be numerically
unstable.

{pstd}
For very small samples and/or sparse tables, an exact chi-square as implemented
in mgof (ssc describe mgof) should be used.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. surveybiasi , popvalues(30 40 30) samplevalues(40 40 20) n(1000)}{p_end}

{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:surveybiasi} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...} {p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(chi2p)}}Pearson chi-square value{p_end}
{synopt:{cmd:e(chi2lr)}}likelihood-ratio chi-square value{p_end}
{synopt:{cmd:e(df)}}degrees of freedom for goodness-of-fit test
{p_end} {synopt:{cmd:e(pp)}}p-value based on Pearson chi-square{p_end}
{synopt:{cmd:e(plr)}}p-value based on likelihood-ratio
chi-square{p_end}



{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:surveybias}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{title:Also see}

{psee} surveybias (calculation of B and friends from raw data in
memory) {help surveybias}

{psee} surveybiasseries (calculation of B for a series of surveys from
a dataset of margins) {help surveybiasseries}


{psee} Online:  {helpb mgof}
