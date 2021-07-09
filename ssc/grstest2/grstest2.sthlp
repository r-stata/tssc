{smcl}
{* *! version 1.2.1  07mar2013}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:grstest2} {hline 2} Program to implement the Gibbons, Ross, Shanken (1989) test to assess asset pricing model performance. 


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:grstest2}
{varlist}
[if]
{cmd:,} {it:flist(string) [alphas nqui]}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt flist}}Required option. Enter the factors here (e.g. market factor){p_end}
{synopt:{opt alphas}}Displays the magnitude of each individual intercept estimate{p_end}
{synopt:{opt nqui}}Does not suppress regression output{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:grstest2} calculates the Gibbons, Ross, Shanken (GRS) test statistic (1989) for the variables in
{varlist} and the factors when the data is in wide-format (each portfolio return has its own column). The GRS test statistic is:

{pstd}
J1 = (T-N-K)/N * (1+E[f]'  var[f]^-1  E[f]') alpha sigma^-1 alpha ~ F(N,T-N-K)

{pstd}
where T is the number of observations in the time-series, N is the number of assets, K is the number of factors. 
Further, E[f] is the sample mean of the factors, var[f] is their estimated variance-covariance matrix, alpha are the estimated intercepts from the individual time-series regressions and sigma is the estimated variance-covariance matrix of the intercepts. 

{pstd}
{cmd:grstest2} further reports an asymptotically valid chi-square test:

{pstd}
J0 = T(1+E[f]' var[f]^-1 E[f]') alpha sigma^-1 alpha ~ Chisquared(N)

{pstd}
To derive J1, normally distributed errors are assumed. J0 does not need that assumption but is only asymptotically valid.

{pstd}
Moreover, {cmd:grstest2} displays the average intercept, the average adjusted R^2, the average standard error of the intercepts, the average absolute value of the intercepts and the sharpe ratio of the intercepts. 


{marker remarks}{...}
{title:Remarks}

{pstd}
1. {cmd:grstest2} requires data to be in wide format, i.e. portfolio returns in columns, time in rows.

{pstd}
2. {cmd:grstest2} uses excess returns (returns in excess of the risk-free rate), i.e. the time-series regression run to estimate the individual intercepts (alphas) is:

{pstd}
r_it - r_ft = alpha_i + beta_i' f_t + e_it 

{pstd}
If you do not use excess returns, the test statistic will be wrong.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. grstest2 r*, flist(Rm)}{p_end}

{phang}{cmd:. grstest2 r*, flist(Rm SMB HML WML) alphas}{p_end}

{phang}{cmd:. grstest2 return1 return2, flist(Rm SMB HML WML) alphas nqui}{p_end}


{marker References}{...}
{title:References}
Gibbons, M.R., Ross, S.A. & Shanken, J., 1989. A test of the efficiency of a given portfolio. 
Econometrica, 57(5), 1121–1152.

{marker Author}{...}
{title:Author}
Markus Ibert
Swedish House of Finance
Stockholm School of Economics
markus.ibert@phdstudent.hhs.se

