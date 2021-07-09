{smcl}
{* *! version 1.1.1  24jan2017}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "mkonfoundhelpfile##syntax"}{...}
{viewerjumpto "Description" "mkonfoundhelpfile##description"}{...}
{viewerjumpto "Options" "mkonfoundhelpfile##options"}{...}
{viewerjumpto "Remarks" "mkonfoundhelpfile##remarks"}{...}
{viewerjumpto "Examples" "mkonfoundhelpfile##examples"}{...}
{viewerjumpto "Authors" "mkonfoundhelpfile##authors"}{...}
{viewerjumpto "References" "mkonfoundhelpfile##references"}{...}
{title:Title}

{phang}
{bf:mkonfound} {hline 2} Beta version: For multiple studies, this command calculates (1) how much bias there must be in an estimate to invalidate/sustain an inference; (2) the impact of an omitted variable necessary to invalidate/sustain an inference for a regression coefficient.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:mkonfound}
[{var1 var2}]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt var1}}the observed t-ratio from each study{p_end}
{synopt:{opt var2}}the degrees of freedom from each study{p_end}


{synoptline}



{marker description}{...}
{title:Description}

{phang}
{cmd:mkonfound} (1) Calculate how much bias there must be in an estimate to invalidate/sustain an inference for multiple studies. The bias necessary to invalidate/sustain an inference is interpreted in terms of sample replacement.
Users input two variables: the observed t-ratio and the degrees of freedom in each study. The command {cmd:mkonfound} produces two variables.
First variable is {it:percent_replace}, indicating how many percent of the original cases must be replaced to invalidate the inference;
Second variable is {it:percent_sustain}, indicating how many percent of the original cases must be replaced to sustain the inference. {p_end}
{phang}
{cmd:mkonfound} (2) Calculate the impact of an omitted variable on the inference of a regression coefficient for multiple studies. The command also assesses how strong an omitted variable 
has to be correlated with the outcome and the predictor of interest to invalidate/sustain the inference for each study.
Users input two variables: the observed t-ratio and the degrees of freedom in each study. The command {cmd:mkonfound} produces four variables.
First variable is {it:itcv_}, indicating the impact of an omitted variable needed to invalidate/sustain the inference.
Second variable is {it:r_cv_y}, indicating the correlation between the omitted variable and the outcome necessary to invalidate/sustain an inference, conditioning on other covariates.
Third variable is {it:r_cv_x}, indicating the correlation between the omitted variable and the predictor of interest necessary to invalidate/sustain an inference, conditioning on other covariates.
Fourth variable is {it:stat_sig_}, indicating if the original regression coefficient is statistically significant. 1 if yes and 0 otherwise. {p_end}

{marker options}{...}
{title:Options}

{phang}
{opt sig(#)}  Significance level of the test; default is 0.05 {cmd:sig(.05)}.  To change the significance level to .10 use {cmd:sig(.1)}


{phang}
{opt nu(#)}  The null hypothesis against which to test the estimate. Null hypothesis is defined as a correlation, ranging from -1 to 1. The
default is 0 {cmd:nu(0)}

{phang}
{opt onetail(#)} One-tail or two-tail test;
        the default is two-tail {cmd:onetail(0)};
		to change to one-tail use {cmd:onetail(1)}

{phang}
{opt rep_0(#)} For % bias, this controls the effect in the replacement cases;
               the default is the null effect (which may or may not be 0) {cmd:rep_0(0)}; to force replacing cases with effect of zero use {cmd:rep_0(1)}

{phang}
{opt z_tran(#)} Calculates the % bias based on Fisher's z-transformation (only apply to non-zero hypothesis testing);
        default calculation is based on the original test statistic {cmd:z_tran(0)};
		to calculate based on Fisher's z use {cmd:z_tran(1)}. 
		And the command will produce two additional variables based on Fisher's z: {it:percent_replace_z} and {it:percent_sustain_z}
		
		
{marker remarks}{...}
{title:Remarks}

{phang}
For a graphical illustration of the impact of a confounding variable see {browse "https://msu.edu/~kenfrank/research.htm#impact_diagram"} {p_end}

{phang}
For additional details of the calculations in a spreadsheet format and other supporting materials see {browse "https://msu.edu/~kenfrank/research.htm#causal"}. {p_end}


{marker examples}{...}
{title:Examples}

{phang}{cmd:. mkonfound var1 var2}{p_end}

{phang}{cmd:. mkonfound var1 var2, sig(0.1) nu(.5) rep_0(1) onetail(1) }{p_end}


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
