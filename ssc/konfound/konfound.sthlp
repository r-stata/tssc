{smcl}
{* *! version 1.1.1  23jan2017}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "konfoundhelpfile##syntax"}{...}
{viewerjumpto "Description" "konfoundhelpfile##description"}{...}
{viewerjumpto "Options" "konfoundhelpfile##options"}{...}
{viewerjumpto "Remarks" "konfoundhelpfile##remarks"}{...}
{viewerjumpto "Examples" "konfoundhelpfile##examples"}{...}
{viewerjumpto "Authors" "konfoundhelpfile##authors"}{...}
{viewerjumpto "References" "konfoundhelpfile##references"}{...}

{title:Title}

{phang}
{bf:konfound} {hline 2} Beta version: For user's model, this command calculates (1) how much bias there must be in an estimate to invalidate/sustain an inference; (2) the impact of an omitted variable necessary to invalidate/sustain an inference for a regression coefficient.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:konfound}
[{varlist}]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt varlist}} a list of variables in the previous model. Users can provide 1 to 10 variable names{p_end}



{synoptline}



{marker description}{...}
{title:Description}

{phang}
{cmd:konfound} (1) Calculates how much bias there must be in an estimate to invalidate/sustain an inference from the immediately preceding model, and interpret in terms of sample replacement. 
After running a model (example: linear regression), user can provide the list of variable names, and {cmd:konfound} will produces % bias needed to invalidate/sustain the inference for each variable in the variable list. 
The command will also provide sensitivity plots for those variables that are statistically significant in the user's model. {p_end}
{phang}
{cmd:konfound} also calculates (2) the impact of an omitted variable necessary to invalidate/sustain an inference for a regression coefficient from a user's model. It 
also assesses how strong an omitted variable has to be correlated with the outcome and the predictor of interest to invalidate/sustain the inference.
After running a model (example: linear regression), the user can provide a list of variable names, and {cmd:konfound} will produce the impact of an omitted variable (Frank, 2000) necessary to invalidate/sustain an inference.  
The command will also produce the correlation of the omitted variable with the outcome and the predictor of interest necessary to invalidate/sustain the inference. 
The command will also provide the observed impact table for all observed covariates in the user's previous model. {p_end}


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
{opt uncond(#)} calculate the impact and component correlations before or after conditioning on covariates in the model. The default is to
calculate the impact and component correlations after conditioning on covariates  {cmd:uncond(0)}. To change the calculation to before conditioning (unconditional) on covariates use {cmd:uncond(1)}

{phang}
{opt rep_0(#)} For % bias, this controls the effect in the replacement cases;
               the default is null effect (which may or may not be 0) {cmd:rep_0(0)}; to force replacing cases with effect of zero use {cmd:rep_0(1)}

{phang}
{opt non_li(#)} Basis for interpreting % bias to invalidate/sustain an inference for non-linear models (e.g., logit or probit). Default is to use the original coefficient {cmd:non_li(0)};
		to change the calcuation based on average partial effects use {cmd:non_li(1)}. 


{marker remarks}{...}
{title:Remarks}

{phang}
For a graphical illustration of the impact of a confounding variable see {browse "https://msu.edu/~kenfrank/research.htm#impact_diagram"} {p_end}

{phang}
For additional details of the calculations in a spreadsheet format and other supporting materials see {browse "https://msu.edu/~kenfrank/research.htm#causal"}. {p_end}

{marker examples}{...}
{title:Examples}
{phang}{cmd:. use http://www.ats.ucla.edu/stat/stata/examples/chp/p025b, clear} {p_end}

{phang}{cmd:. rename y2 x5} {p_end}

{phang}{cmd:. regress y1 x1 x4 x5} {p_end}

{phang}{cmd:. konfound x1}{p_end}

{phang}{cmd:. regress y1 x1 x4 x5} {p_end}

{phang}{cmd:. konfound x1, uncond(1)}{p_end}

{phang}{cmd:. regress y1 x1 x4 x5} {p_end}

{phang}{cmd:. konfound x1, sig(0.1) nu(.5) rep_0(1)}{p_end}

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
