{smcl}
{* *! Version 10 june2011}
{cmd:help probitmiss}
{hline}

{title:Title}

{phang}
{bf: Efficient Estimator for Probit model with missing data}

{title:Syntax}
{p 8 17 2}
{cmdab: probitmiss}
[{depvar}]
[{varlist:w}]
[{varlist:x}]
[{cmd:,}]
[{it:options}]

{synoptset 20 tabbed}
{synopthdr}
{synoptline}

{synopt:{opt numw}} specifies the number of variables with missing data Ò default is {cmd:numw(1)}{p_end}

{synoptline}

{title:Description}

{pstd}
{cmd:probitmiss} provides efficient parameter estimates for a probit model of  [{depvar}] on the variables listed in [{varlist:w}] and [{varlist:x}] when the variables listed in [{varlist:w}] have missing values. The command is implemented by                typing {cmd:probitmiss} followed by [{depvar}] [{varlist:w}] [{varlist:x}]. [{varlist:w}] is the set of explanatory variables for which some observations are missing and [{varlist:x}] is the set of explanatory variables with no missing data.          The conditions needed for efficiency are discussed in more detail in Conniffe and OÌNeill (2011)

{pstd}
{cmd:probitmiss} also reports the results of a Hausman type test for the Missing at Random assumption of the estimator. 


{title:Example 1}

    {hline}
{phang}{cmd:. probitmiss riskydum2 rho_new eta eta2 college woman staciv_1 area5_2 area5_3 area5_4 area5_5, numw(1)}{p_end}

{pstd}
This estimates a probit model of {cmd:riskydum2} on {cmd:rho_new-area5_5} when only {cmd:rho_new} contains missing data.
    
    {hline}


{title:Example 2}

    {hline}
{phang}{cmd:. probitmiss riskydum2 rho_new eta college woman staciv_1 area5_2 area5_3 area5_4 area5_5, numw(3)}{p_end}

{pstd}
This estimates a probit model of {cmd:riskydum2} on {cmd:rho_new-area5_5} when {cmd:rho_new, eta and college} all contain missing data.

    {hline}


{title:Saved Results}

{pstd}
{cmd:probitmiss} saves the following in {cmd:e()}:

{synoptset 15 tabbed}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}} number of complete observations{p_end}
{synopt:{cmd:e(N2)}} total sample size(including incomplete observations){p_end}
{synopt:{cmd:e(Chi2)}} Chi-squared statistic for Hausman test of MAR{p_end}



{synoptset 15 tabbed}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}} coefficient vector{p_end}
{synopt:{cmd:e(V)}} variance-covariance matrix of the estimator{p_end}

{title: References}

{pstd} Conniffe,D. and D.OÌNeill (2011) Efficient Probit Estimation with Partially Missing Covariates,Ó forthcoming in Advances in Econometrics: Volume 27, Missing Data Methods editor D. Drukker.










