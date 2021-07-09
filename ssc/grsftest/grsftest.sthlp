{smcl}
{* *! version 4.3  22jul2020}{...}
{vieweralsosee "[R] help" "help help "}{...}
{viewerjumpto "Syntax" "grsftest##syntax"}{...}
{viewerjumpto "Description" "grsftest##description"}{...}
{viewerjumpto "Options" "grsftest##options"}{...}
{viewerjumpto "Remarks" "grsftest##remarks"}{...}
{viewerjumpto "Examples" "grsftest##examples"}{...}
{cmd:help grsftest}
{hline}
{title:Title}

{phang}
{bf:grsftest} {hline 2} Module to perform the Gibbons, Ross, Shanken (1989, GRS) test of mean-variance efficiency of asset returns in empirical asset pricing models.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:grsftest}
{varlist}
[{it:{help if}}]
{cmd:, {opth factor(varlist)}}
[{it:{opt d:etails}}]

{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opth factor(varlist)}}one or more factor portfolios with excess returns (e.g. xmkt smb hml){p_end}

{syntab:Optional}
{synopt:{opt d:etails}}displays the estimation results of factor model. It reports the estimated intercepts (on average and by individual asset) and summary statistics of the asset and factor portfolio returns.{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:grsftest} calculates the Gibbons, Ross, Shanken (1989, GRS) F-test statistic for the test assets in {varlist} and the factor portfolios in {cmd:factor()}. When {cmd:grsftest} runs the time-series regression, it assumes the returns for both the test assets and factor portfolios are excess returns (in excess of the riskless rate of return). {cmd:grsftest} uses the following formula to calculate GRS F-test statistic:

{pmore}GRS F-test, H0 representation:{p_end}
{pmore}F = [T/N][(T-N-K)/(T-K-1)] * ({c a^}' Sigma^-1 {c a^}) / (1 + E[rp]' Lambda^-1 E[rp])  ~ F(N,T-N-K)

{pstd}
where, T denotes the number of observations in terms of time series. N denotes the number of test assets. K denotes the number of factor portfolios. E[p] is the sample means of the factor portfolios. {c a^} is the estimated intercepts. Sigma is the estimated covariance matrix of residuals. Lambda is the estimated covariance matrix of factor portfolios without degrees of freedom adjustment: Lambda = (1/T)(rp'*rp) - E[rp]E[rp]'  {p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:grsftest} does not adjust for the degrees of freedom, when calculating estimator of the sample covariance matrix of the factor portfolios. This approach avoids a common misrepresentation of the GRS paper. See Kamstra and Shi (2020) for more. {p_end}


{marker results}{...}
{title:Stored Results}

{pstd}{cmd:grsftest} stores the following in {cmd:r()}, regardless {it:{help grsftest##options:[details]}} is specified or not:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(summary)}}estimated intercepts on average and by individual asset {p_end}
{synopt:{cmd:r(alphas)}}summary statistics of the asset and factor portfolio returns {p_end}
{p2colreset}{...}


{marker examples}{...}
{title:Examples}

{phang}{cmd:. grsftest excess_ret1 excess_ret2, factor(xmkt smb hml) d }{p_end}


{marker references}{...}
{title:References}

{pstd}Gibbons, M.R., S. Ross, and J. Shanken, 1989. "A test of the efficiency of a given portfolio" {it:Econometrica}, 57(5), 1121-1152.{p_end}

{pstd}Kamstra, M.J., R. Shi, 2020. "A Note on the GRS Test" {it: Working Paper}{p_end}


{marker author}{...}
{title:Author}

{pstd}Mengnan(Cliff) Zhu{p_end}
{pstd}Brandeis International Business School{p_end}
{pstd}cliffzhu@brandeis.edu{p_end}

