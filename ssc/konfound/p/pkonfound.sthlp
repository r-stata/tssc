{smcl}
{* *! version 1.1.1  24jan2017}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "pkonfoundhelpfile##syntax"}{...}
{viewerjumpto "Description" "pkonfoundhelpfile##description"}{...}
{viewerjumpto "Options" "pkonfoundhelpfile##options"}{...}
{viewerjumpto "Remarks" "pkonfoundhelpfile##remarks"}{...}
{viewerjumpto "Examples" "pkonfoundhelpfile##examples"}{...}
{viewerjumpto "Authors" "pkonfoundhelpfile##authors"}{...}
{viewerjumpto "References" "pkonfoundhelpfile##references"}{...}
{title:Title}

{phang}
{bf:pkonfound} {hline 2} Beta version: For published studies, this command calculates (1) how much bias there must be in an estimate to invalidate/sustain an inference; (2) the impact of an omitted variable necessary to invalidate/sustain an inference for a regression coefficient.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:pkonfound}
[{# # # #}]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt First #}} the estimated value of the regression coefficient{p_end}
{synopt:{opt Second #}} the standard error of the regression coefficient{p_end}
{synopt:{opt Third #}} the sample size{p_end}
{synopt:{opt Fourth #}} the number of covariates in the model{p_end}



{synoptline}



{marker description}{...}
{title:Description}

{pstd}
{cmd:pkonfound} this command calculates (1) how much bias there must be in an estimate to invalidate/sustain an inference. 
The bias necessary to invalidate/sustain an inference is interpreted in terms of sample replacement; (2) the impact of an omitted variable necessary to invalidate/sustain an inference for a regression coefficient. 
It also assesses how strong an omitted variable has to be correlated with the outcome and the predictor of interest to invalidate/sustain the inference.

{marker options}{...}
{title:Options}

{phang}
{opt sig(#)} Significance level of the test; default is 0.05 {cmd:sig(.05)}. 
             To change the significance level to .10 use {cmd:sig(.1)}

{phang}
{opt nu(#)} The null hypothesis against which to test the estimate. The
default is 0 {cmd:nu(0)}

{phang}
{opt onetail(#)} One-tail or two-tail test;
        the default is two-tail {cmd:onetail(0)};
		to change to one-tail use {cmd:onetail(1)}

{phang}
{opt rep_0(#)} For % bias, this controls the effect in the replacement cases;
               the default is the null effect (which may or may not be 0) {cmd:rep_0(0)}; to force replacing cases with effect of zero use {cmd:rep_0(1)}

{marker remarks}{...}
{title:Remarks}

{phang}
For a graphical illustration of the impact of a confounding variable see  {browse "https://msu.edu/~kenfrank/research.htm#impact_diagram"} {p_end}

{phang}
For additional details of the calculations in a spreadsheet format and other supporting materials see {browse "https://msu.edu/~kenfrank/research.htm#causal"}. {p_end}


{marker examples}{...}
{title:Examples}

{pstd}
## Assume in a study the estimate is 10, the standard error of the estimate is 2, the sample size is 100, and the number of covariates is 5


{phang}{cmd:. pkonfound 10 2 100 5}{p_end}

{phang}{cmd:. pkonfound 10 2 100 5, sig(0.1) nu(1) onetail(1) rep_0(1) }{p_end}


{marker authors}{...}
{title:Authors}

{phang} Kenneth A. Frank {p_end}
{phang} Michigan State University {p_end}

{phang} Ran Xu {p_end}
{phang} Michigan State University {p_end}

{phang} Please email {bf:ranxu@msu.edu} if you observe any problems. {p_end}

{marker references}{...}
{title:References}

{pstd}
Frank, K.A. 2000. Impact of a Confounding Variable on the Inference of a Regression Coefficient. Sociological Methods and Research, 29(2), 147-194

{pstd}
Pan, W., and Frank, K.A. 2004. An Approximation to the Distribution of the Product of Two Dependent Correlation Coefficients. Journal of Statistical Computation and Simulation, 74, 419-443

{pstd}
Pan, W., and Frank, K.A., 2004. A probability index of the robustness of a causal inference. Journal of Educational and Behavioral Statistics, 28, 315-337.

{pstd}
*Frank, K. A. and Min, K. 2007. Indices of Robustness for Sample Representation. Sociological Methodology.  Vol 37, 349-392. * co first authors.

{pstd}
Frank, K.A., Gary Sykes, Dorothea Anagnostopoulos, Marisa Cannata, Linda Chard, Ann Krause, Raven McCrory. 2008. Extended Influence: National Board Certified Teachers as Help Providers.  Education, Evaluation, and Policy Analysis.  Vol 30(1): 3-30.

{pstd}
Frank, K.A., Maroulis, S., Duong, M., and Kelcey, B. 2013.  What would it take to Change an Inference?: Using Rubin’s Causal Model to Interpret the Robustness of Causal Inferences.   Education, Evaluation and Policy Analysis.  Vol 35: 437-460.
