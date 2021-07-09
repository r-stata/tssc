{smcl}
{* *! version 1.0.0  01apr2014}{...}
{cmd:help gvselect}
{hline}
{title:Title}

{p2colset 5 17 18 2}{...}
{p2col :{hi:gvselect} {hline 2}}Best subsets variable selection{p_end}
{p2colreset}{...}

{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmd:gvselect} {cmd:<}{it:term}{cmd:>} {it:{help varlist:varlist}}, {opt nm:odels(#)}: {help gvselect##est_cmd:{it:est_cmd}}

{marker est_cmd}{...}
{p 12 12 2}
{it:est_cmd} may be an estimation command that stores the {cmd:e(ll)} result.   

{p 12 12 2}
Instances of {cmd:<}{it:term}{cmd:>} (with the angle brackets) that occur
within {it:est_cmd} are replaced in {it:est_cmd} by subsets of {it:varlist} to
determine the best subsets of {it:varlist} for estimating the model of interest.

{marker description}
{title:Description}

{pstd}
{cmd:gvselect} performs best subsets variable selection.  The Furnival-Wilson
(1974) leaps-and-bounds algorithm is applied using the log likelihoods of
candidate models, allowing variable selection to be performed on a wide family
of normal and non-normal regression models.  This method is described in
Lawless and Singhal (1978).

{pstd}
The log likelihood, Akaike's information criterion, and the Bayesian information
criterion are reported for the best regressions at each predictor quantity.

{marker options}
{title:Options}

{phang} {cmd:nmodels(}{it:#}{cmd:)} Report the best {it:#} models for each quantity of predictors. 

{marker examples}
{title:Examples}

{synoptline}
{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}Linear regression variable selection{p_end}
{phang2}{cmd:. gvselect <term> weight trunk length, nmodels(2): regress mpg <term> i.foreign}{p_end}

{synoptline}
{pstd}Setup{p_end}
{phang2}{cmd:. use dvisits}{p_end}

{pstd}Poisson regression variable selection{p_end}
{phang2}{cmd:. gvselect <term> sex age agesq income levyplus freepoor freerepa illness actdays hscore chcond1 chcond2: poisson docvis <term>}{p_end}

{synoptline}

{marker results}
{title:Stored results}

{pstd}
When {cmd:nmodels()} < 2, {cmd:gvselect} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 25 29 2: Macros}{p_end}
{synopt:{cmd:r(bestk)}}variable list of predictors from best {it:k} predictor model{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:{cmd:r(best1)}}variable list of predictors from best 1 predictor model{p_end}

{p2col 5 25 29 2: Matrices}{p_end}
{synopt:{cmd:r(info)}}contains the information criteria for the best models{p_end}
{p2colreset}{...}


{pstd}
When {it:m} = {cmd:nmodels()} > 1, {cmd:gvselect} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 25 29 2: Macros}{p_end}
{synopt:{cmd:r(bestk1)}}variable list of predictors from best {it:k} predictor model{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:{cmd:r(best11)}}variable list of predictors from best 1 predictor model{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:{cmd:r(bestkm)}}variable list of predictors from {it:m}th best {it:k} predictor model{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:{cmd:r(best1m)}}variable list of predictors from {it:m}th best 1 predictor model{p_end}

{p2col 5 25 29 2: Matrices}{p_end}
{synopt:{cmd:r(info)}}contains the information criteria for the best models{p_end}
{p2colreset}{...}

{marker authors}
{title:Authors}

{pstd}Charles Lindsey{p_end}
{pstd}StataCorp{p_end}
{pstd}College Station, TX{p_end}
{pstd}clindsey@stata.com{p_end}

{pstd}Simon Sheather{p_end}
{pstd}Department of Statistics{p_end}
{pstd}Texas A&M University{p_end}
{pstd}College Station, TX{p_end}


{marker references}{...}
{title:References}

{phang}
Furnival, G. M., and R. W. Wilson. 1974. Regression by leaps and bounds. {it:Technometrics}. 16: 499-511.

{phang}
Lawless, J. F., and K. Singhal. 1978. Efficient screening of nonnormal
regression models.  {it:Biometrics} 34: 318-327.
