{smcl}
{* October 2010}{...}
{hline}
{cmd:help for spseudor2} 
{hline}

{title:Title}

{p 4 8 2}
{bf:spseudor2 --- Calculates goodness-of-fit measures in spatial autoregressive models}

{title:Syntax}

{phang}
{cmd: spseudor2}{cmd:,} {opt wmat(name)}


{title:Description}

{pstd}{cmd:spseudor2} calculates two so-called pseudo R2 measures to assess goodness of fit in spatial 
autoregressive models estimated by spatial two stage least squares or spatial GMM. The first measure is 
computed as the square of the correlation between the predicted and observed values of the dependent 
variable. The other one is calculated as the ratio of the variance of the predicted values to the 
variance of the observed values of the dependent variable.

{pstd}In calculating the predicted values of the dependent variable, {cmd:spseudor2} takes into account 
the fact that the spatially lagged dependent variable is endogenous.

{pstd}
{bf:N.B.: } {cmd:spseudor2} is intended to work after {help ivregress} and {help ivreg29} and requires at least Stata 10.1.

{pmore}   Also, {cmd:spseudor2} assumes that the spatially lagged dependent variable precedes all other endogenous variables, if any, and is 
the first variable of the listed right-hanside variables in the model.
  

{title:Options}

{dlgtab:Options}

{pstd}
{opt wmat(name)} indicates the name of the spatial weights matrix used in the spatial autoregressive 
model estimation. The matrix must have been saved to a Mata file.


{title:Saved Results}

{p}{cmd:spseudor2} saves the following results in {cmd:r()}:

Scalars        
{col 4}{cmd:r(sqcorr)}{col 19}The square of the correlation between the predicted and observed values of the dependent variable
{col 4}{cmd:r(varRatio)}{col 19}The ratio of the variance of the predicted value to the variance of the observed value of the dependent variable


{title:Example}

{phang}{cmd:. spseudor2, wmat(winvecon)}

{phang}
Go to {browse "http://stasacode.com": http://stasacode.com} for more examples as to how to add the calculated goodness-of-fit measures 
to estimation results for model comparison purposes. 
 
 
{title:Author}

{p 4 4 2}{hi: P. Wilner Jeanty}, Dept. of Agricultural, Environmental, and Development Economics,{break} 
           The Ohio State University{break}
           
{p 4 4 2}Email to {browse "mailto:jeanty.1@osu.edu":jeanty.1@osu.edu}



