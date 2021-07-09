{smcl}
{* *! version 1.0.0  23jul2018}{...}
{vieweralsosee "[IRT] irt 1pl" "help irt 1pl"}{...}
{vieweralsosee "[IRT] irt 1pl postestimation" "help irt 1pl postestimation"}{...}
{vieweralsosee "[IRT] irt" "help irt"}{...}
{p2colset 1 13 15 2}{...}
{p2col:{bf:raschify} {hline 2}}Transform 1PL model estimates to Rasch metric{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:raschify}


{marker description}{...}
{title:Description}

{pstd}
{cmd:raschify} transforms 1PL model estimates to the Rasch metric.
All the postestimation tools available
after {helpb irt 1pl postestimation:irt 1pl} can be used with
the transformed results.


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse masc1}

{pstd}Fit a 1PL model to binary items {cmd:q1-q9}{p_end}
{phang2}{cmd:. irt 1pl q1-q9}

{pstd}Transform the 1PL model coefficients to the Rasch metric{p_end}
{phang2}{cmd:. raschify}

{pstd}Display parameters of the Rasch model{p_end}
{phang2}{cmd:. irt}

{pstd}Use the Rasch model parameters to plot the ICCs{p_end}
{phang2}{cmd:. irtgraph icc, blocation xlabel(,alt) legend(off)}

{pstd}Predict the latent trait{p_end}
{phang2}{cmd:. predict ability, latent}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:raschify} changes the following results:

{synoptset 11 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(title)}}Rasch model{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector, slope-intercept parameterization{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{p2colreset}{...}


{marker authors}{...}
{title:Authors}

{pstd}
Rafal Raciborski{break}
{browse "mailto:rraciborski@gmail.com":rraciborski@gmail.com}{break}
