{smcl}

{cmd:help cquadext}{right:also see:  {help clogit}, {help cquadbasic}, {help cquadequ}}
{hline}

{title:Title}

{p2colset 5 17 21 2}{...}
{p2col :{hi:cquadext} {hline 2}}Conditional maximum likelihood estimation of the quadratic exponential model by Bartolucci and Nigro (2010){p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}{cmd:cquadext} {depvar} id [{indepvars}]

{title:Description}

{pstd} 
Fit by conditional maximum likelihood the model for binary logitudinal data proposed by Bartolucci & Nigro (2010).

{pstd} 
For a vector y_i of T observations (y_{i,1},...,y_{i,T}) for unit i, the model is based on the assumption:

{pstd} 
p(y_i) {proportional to} exp[(y_{i,2}x_{i,2} + ... + y_{i,T}x_{i,T})'beta1 + y_{i,T}(phi+x_{i,T}'beta2)
+(y_{i,1}y_{i,2} + ... + y_{i,T-1}y_{i,T})gamma]

{pstd} 
where x_{i,t} is a column vector of covariates and the first observation is taken as initial condition.
The function can be also used with unbalanced panel data.

{pstd} 
id (compulsory) is the list of the reference unit of each observation{p_end}

{pstd}
phi is indicated by diff-int in the output 

{pstd}
beta is indicated by diff-cov1... in the output 

{title:Examples}

{pstd}Setup{p_end}
{phang}{cmd:. webuse union}{p_end}

{pstd}Fit quadratic exponential model{p_end}
{phang}{cmd:. cquadext union idcode age grade}{p_end}

{title:Saved results}

{pstd}
{cmd:cquadext} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(lk)}}final conditional log-likelihood{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:cquadext}{p_end}

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
Bartolucci, F. & Nigro, V., (2010). A dynamic model for binary panel data with unobserved heterogeneity admitting a root-n consistent conditional estimator. Econometrica, 78, pp. 719-733.{p_end}


