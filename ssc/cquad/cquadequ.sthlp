{smcl}

{cmd:help cquadequ}{right:also see:  {help clogit}, {help cquadbasic}, {help cquadext}}
{hline}

{title:Title}

{p2colset 5 17 21 2}{...}
{p2col :{hi:cquadequ} {hline 2}}Conditional maximum likelihood estimation for the modified
version of the quadratic exponential model proposed by Bartolucci, Nigro & Pigini (2013){p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}{cmd:cquadequ} {depvar} id [{indepvars}]

{title:Description}

{pstd} 
Fit by conditional maximum likelihood a modified version of the model for binary logitudinal
data proposed by Bartolucci & Nigro (2010), in which the interaction terms have an extended
form. This modified version is used to test for state dependence as described in Bartolucci 
et al. (2013).

{pstd} 
For a vector y_i of T observations (y_{i,1},...,y_{i,T}) for unit i, the model is based on the assumption:

{pstd} 
p(y_i) {proportional to} exp[(y_{i,2}x_{i,2} + ... + y_{i,T}x_{i,T})'beta + (1{y_{i,1}==y_{i,2}} + ... + 1{y_{i,T-1}==y_{i,T}})gamma]

{pstd} 
where x_{i,t} is a column vector of covariates and the first observation is taken as initial condition
and 1{.} is the indicator function. The function can be also used with unbalanced panel data.

{pstd} 
id (compulsory) is the list of the reference unit of each observation{p_end}

{title:Examples}

{pstd}Setup{p_end}
{phang}{cmd:. webuse union}{p_end}

{pstd}Fit (modified) quadratic exponential model{p_end}
{phang}{cmd:. cquadequ union idcode age grade}{p_end}

{title:Saved results}

{pstd}
{cmd:cquadequ} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(lk)}}final conditional log-likelihood{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:cquadequ}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(be)}}coefficient vector{p_end}
{synopt:{cmd:e(se)}}standard errors{p_end}
{synopt:{cmd:e(ser)}}robust standard errors{p_end}
{synopt:{cmd:e(tstat)}}t-statistics{p_end}
{synopt:{cmd:e(pv)}}p-values{p_end}

{title:Author}

{pstd}Francesco Bartolucci{p_end}
{pstd}Department of Economics, University of Perugia {p_end}
{pstd}Perugia, Italy{p_end}
{pstd}bart@stat.unipg.it{p_end}

{title:References}

{pstd}
Bartolucci, F. & Nigro, V. (2010). A dynamic model for binary panel data with unobserved heterogeneity admitting a root-n consistent conditional estimator. Econometrica, 78, pp. 719-733.

{pstd}
Bartolucci, F., Nigro, V. & Pigini, C. (2013). Testing for state dependence in binary panel data with individual covariates, MPRA Paper 48233, University Library of Munich, Germany.


