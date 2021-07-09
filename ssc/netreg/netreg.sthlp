{smcl}
{* *! version 1.0.0	01Aug2018}{...}
{cmd:help netreg}
{hline}

{title:Title}

{phang}
{bf:netreg} {hline 2} linear regression of a network response with the exchangeable assumption

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:netreg}
{it: varlist}
[{helpb if}]
[{helpb in}]
[{cmd:,} {it:undirected} {it:withnode} {it:reweight} {it:tol(real)} {it:maxit(#)} {it:n_total(#)} {it:cilevel(#)}]

{synoptset 10 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt undirect}} Optional indicator of whether input data is for a directed network. The default is directed network.
 Undirected data format is lower triangle of adjacency matrix.{p_end}
{synopt:{opt withnode}} Optional indicator of whether the (directed) relation pairs to which each entry in Y and each row in X corresponds 
is included in the dataset.( the dataset¡¯s last two rows should be integers).{p_end}
{synopt:{opt reweight}} Optional indicator of whether iteratively
 reweighted least squares should be used to compute estimate of coefficients.{p_end}
{synopt:{opt tol}} Optional numeric, tolerance of stopping criteria of iteratively 
reweighted least squares estimate of coefficients. Default is tol=1e-6.{p_end}
{synopt:{opt maxit}} Optional integer,
 maximum number of iterations for iteratively reweighted least squares estimate of coefficients. Default is maxit=50.{p_end}
{synopt:{opt n_total}} Optional numeric, actor size of the network. At least one of {opt n_total} or {opt withnode} option should be clarified.{p_end}
{synopt:{opt cilevel}} Optional integer. Confidence level of confidence interval being displayed at the result.The default is 95.{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:netreg} provides methods for performing a regression of a network response, where each data point represents an edge on a network or covariates of interest. 
 It takes advantage of the exchangeable assumption for residuals, and this assumption dramatically simplified the covariance matrix of residuals.
 With this new assumption, we can provide a better estimation for the coefficients¡¯ covariance matrix, resulting in an accurate confidence interval for coefficients.
 Also, applying exchangeable assumption enables the iteratively reweighted least squares method for better estimation.  For more details, see Marrs (2017). This package is also available in R, you can search netregR in R for this package.
 {p_end}

{pstd} By default, data should be arranged column-wise. There are two possible ways to input the varlist:
{p_end}

{pstd}
For the first way, users can clarify the size of actors as {opt n_total} in the function and exclude {opt withnode} option. 
With this setting, complete network observation of adjacency matrix without diagonal entries (self-loops) is assumed. 
The function will take the first item of the varlist as the response for each edge. 
The rest items in the varlist will be the covariates for corresponding edges. 
{p_end}

{pstd}
In the second method, users can clarify {opt withnode} option in the function. 
With this setting, the first item of varlist will be taken as responses for edges. 
The last two items indicate the (directed) relation pairs to which each entry in the varlist corresponds.
The rest items in the varlist represent the covariates of each edge. 
Make sure that the last two rows are integers. Otherwise, stata will pop out errors.
{p_end}

{pstd}
 The {opt undirect} option is for undirected net.
 When undirected option being included, this function will automatically consider each edge of this network is undirected.
 When one edge corresponds to two data, this function will take the data that first comes out.   
{p_end}

{pstd}
The {opt reweight} option indicates that iteratively reweighted least squares should be used to compute an estimate of coefficients. 
When {opt reweight} option is included, users can also declare the tol and maxit option. 
The tol is the tolerance of stopping criteria of the iteratively reweighted least squares method.
Here the definition of tolerance is dimensionless, i.e. change of coefficients over the length of coefficients. 
The maxit is the maximum number of iterations for iteratively reweighted least squares estimate.
{p_end}

{pstd}
It needs notice that, since the distribution of coefficients is just asymptotically normal, the confidence interval is constructed with normal distribution.
{p_end}
 

{marker examples}{...}
{title:Examples}

{pstd}Here is an example of network linear regression with exchangeable assumption. Data used here is a wolf data from Junk, (1987). It is now available on the author's github website.
One can visit https://github.com/DayouLuo1995/NetregStata/blob/master/wolf.dta for the test data.
{p_end}

{phang2}{cmd:. use wolf.dta}{p_end}
{phang2}{cmd:. netreg wolf age_diff same_sex wolf1 wolf2,withnode}{p_end}
{pstd}
This is a simple linear regression. The exchangeable assumption is used to construct confidence intervals for coefficients.
{p_end}

{phang2}{cmd:. netreg wolf age_diff same_sex,n_total(16)}{p_end}
{pstd}
Also you can give the size of actors in the network and omit relation pairs (wolf1 wolf2). {cmd:netreg} will automatically assume that the data set is complete and is arranged in required order.
However, commands with relation pairs are recommanded because {helpb if} and {helpb in} options are avaliable with nodes included.
{p_end}

{phang2}{cmd:. netreg wolf age_diff same_sex wolf1 wolf2 , withnode reweight}{p_end}
{pstd}
Here {cmd:netreg} takes advantage of an iteration regression method. For more information, see Marrs (2017).
{p_end}

{phang2}{cmd:. use wolf_undirected.dta}{p_end}
{phang2}{cmd:. netreg wolf age_diff same_sex wolf1 wolf2, undirect reweight n_total(16)}{p_end}
{pstd}
Iteratively reweighted least squares method for undirected network. The data is avaliable at https://github.com/DayouLuo1995/NetregStata/blob/master/wolf_undirected.dta
{p_end}


{marker saved_results}{...}
{title:Saved results}
{pstd}

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Macros}{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(cmd)}}netreg{p_end}
{synopt:{cmd: e(properties)}}{opt b} {opt V}{p_end}

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Matrices}{p_end}
{synopt:{cmd: e(b)}}coefficient vector{p_end}
{synopt:{cmd: e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Function}{p_end}
{synopt:{cmd: e(sample)}} marks estimation sample{p_end}


{marker references}{...}
{title:References}

{phang} Marrs, F. W., McCormick, T. H., & Fosdick, B. K. (2017). Standard errors for regression on relational data with exchangeable errors. arXiv preprint arXiv:1701.05530.{p_end}

{marker author}{...}
{title:Author}

{phang}Dayou Luo{p_end}
{phang}dayoul@uw.edu{p_end}
