{smcl}
{* *! version 1.4 Aug 07 2015}{...}
{vieweralsosee "surveybiasi" "help surveybiasi"}{...}
{viewerjumpto "Syntax" "surveybias##syntax"}{...}
{viewerjumpto "Description" "surveybias##description"}{...}
{viewerjumpto "Options" "surveybias##options"}{...}
{viewerjumpto "Remarks" "surveybias##remarks"}{...}
{viewerjumpto "Examples" "surveybias##examples"}{...}
{viewerjumpto "Saved Results" "surveybias##saved_results"}{...}
{title:Title}

{phang}
{bf:surveybias} {hline 2} Calculate various measures of bias in survey


{marker syntax}{...}
{title:Syntax}

{p 4 11 2}
{cmd:surveybias}
{varname}
{ifin}
{weight} 
{cmd:,} {opt POP:values(#..#)} [{opt VERB:ose}] [{opt prop}]  [{opt vce(vcetype)}] [{opt cl:uster} {it:clustvar}] [{opt svy}] [{opt subpop(var)}] [{opt l:evel(#)}] 


	
{phang}Immediate command: {help surveybiasi}

{phang}Command for aggregated data (series of surveys): {help surveybiasseries}

{marker description}{...}
{title:Description}

{pstd} {cmd:surveybias} compares the distribution of categorical variable {varname}
in the dataset to its true distribution in the population, which is specified as a
{help numlist} in {opt POP:values(#..#)}


{marker options}{...}
{title:Options}



{phang} {opt POP:values} specifies the distribution of {varname} in the population.
Must not be omitted. Distribution can be given as counts or relative frequencies, as
it is rescaled to unity.

{phang}
{opt VERB:ose} displays detailed information on {varname}.

{phang}
{opt prop} Switch to estimation via {cmd:proportion}. Chiefly used for testing.

{phang}
{cmd:bootstrap}, {cmd:by}, {cmd:jackknife} and {cmd:statsby} are allowed, see {help prefix}.

{phang}
{opt vce}, {opt cl:uster} uses complex variance estimators. Cluster, bootstrap, and jacknife estimators are allowed. Switches to numerical methods.

{phang}
{opt svy} uses survey characteristics of your data. Switches to numerical methods and requires that the survey design variables be identified using
{help svyset}

{phang}
{opt subpop(var)} identifies subpopulation for use with survey estimator. Implies {opt svy} 


{phang}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see {help weight}. 



{phang}
{opt l:evel(#)} sets confidence level.


{marker remarks}{...}
{title:Remarks}

{pstd} Values of {varname} must be strictly positive integers. The number of
categories must not exceed twelve. The order of categories in {opt POP:values} and
{varname} must match. If in doubt, use {opt VERB:ose}, or {help inspect} {varname}.
For detailed information on A', B and B_w, see
{it: Arzheimer, Kai and Jocelyn Evans, A New Multinomial Accuracy Measure}
{it: for Polling Bias, Political Analysis, Political Analysis 2014 (22), 31-44.}
{browse "http://dx.doi.org/10.1093/pan/mpt012"}


{pstd} For very small samples and/or sparse tables, an exact chi-square as
implemented in mgof (ssc describe mgof) should be used.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. use onefrenchsurvey, replace}{p_end}
{phang}{cmd:. surveybias vote, popval(28.6 27.18 17.9 9.13  11.1  2.31 1.15 1.79 0.8) }{p_end}

{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:surveybias} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...} {p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end} {synopt:{cmd:e(chi2p)}}Pearson
chi-square value{p_end} {synopt:{cmd:e(chi2lr)}}likelihood-ratio chi-square
value{p_end} {synopt:{cmd:e(df)}}degrees of freedom for goodness-of-fit test {p_end}
{synopt:{cmd:e(pp)}}p-value based on Pearson chi-square{p_end}
{synopt:{cmd:e(plr)}}p-value based on likelihood-ratio chi-square{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:surveybias}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(depvar)}}name of variable in sample{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{title:Also see}

{psee} surveybiasi  (immediate calculation of B and friends) {help surveybiasi}

{psee} surveybiasseries (calculation of B for a series of surveys from a dataset
of margins) {help surveybiasseries}

{psee} Online:  {helpb mgof}
