{smcl}

{cmd:help cquadpseudo}{right:also see:  {help clogit}, {help cquadbasic}, {help cquadext}}
{hline}

{title:Title}

{p2colset 5 17 21 2}{...}
{p2col :{hi:cquadpseudo} {hline 2}}Pseudo conditional maximum likelihood estimation of the dynamic logit model
(Bartolucci and Nigro, 2012){p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}{cmd:cquadpseudo} {depvar} id [{indepvars}]

{title:Description}

{pstd} 
Estimate the dynamic logit model for binary logitudinal data by the pseudo conditional maximum likelihood method 
proposed by Bartolucci & Nigro (2012).

{pstd} 
For a vector y_i of T observations (y_{i,1},...,y_{i,T}) for unit i, the model is based on the assumption:

{pstd} 
p(y_{i,t}) {proportional to} exp(y_{i,t}x_{i,t}'beta + y_{i,t-1}y_{i,t}gamma)

{pstd} 
where x_{i,t} is a column vector of covariates and the first observation is taken as initial condition.
The function can be also used with unbalanced panel data.

{pstd} 
id (compulsory) is the list of the reference unit of each observation{p_end}

{title:Examples}

{pstd}Setup{p_end}
{phang}{cmd:. webuse union}{p_end}

{pstd}Fit (simplified) quadratic exponential model{p_end}
{phang}{cmd:. cquadpseudo union idcode age grade}{p_end}

{title:Saved results}

{pstd}
{cmd:cquadpseudo} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(lk)}}final conditional log-likelihood{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:cquadpseudo}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(be)}}coefficient vector{p_end}
{synopt:{cmd:e(se)}}standard errors{p_end}
{synopt:{cmd:e(ser)}}robust standard errors{p_end}
{synopt:{cmd:e(tstat)}}t-statistics based on robust standard errors{p_end}
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
Bartolucci, F. & Nigro, V. (2012). Pseudo conditional maximum likelihood estimation of the dynamic logit model for binary panel data. Journal of Econometrics, 170, pp. 102-116.


