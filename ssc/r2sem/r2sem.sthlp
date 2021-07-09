{smcl}
{hline}
{cmd:help: {helpb r2sem}}{space 50} {cmd:dialog:} {bf:{dialog r2sem}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:r2sem: (SEM-FIML) Overall System R2 - Adjusted R2 - F Test - Chi2 Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb r2sem##01:Syntax}{p_end}
{p 5}{helpb r2sem##02:Description}{p_end}
{p 5}{helpb r2sem##03:Saved Results}{p_end}
{p 5}{helpb r2sem##04:References}{p_end}

{p 1}*** {helpb r2sem##05:Examples}{p_end}

{p 5}{helpb r2sem##06:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{cmd: r2sem}

{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:r2sem} computes Overall System R-squared (R2), Adjusted R2, and the overall significance of F-Test, and Chi2-Test, after:{p_end}
{p 3 2 2}- {helpb sem}: (SEM) Structural Equation Modeling for systems of simultaneous equations.{p_end}

{p 2 2 2}{cmd:r2sem} used 4 types of criteria and tests, as discussed in:{p_end}
{p 2 2 2}{cmd: McElroy(1977), Judge et al(1985), Greene(1993), and Berndt(1991)}.{p_end} 
{p 6 2 2}see eq.12.1.33-36 in Judge et al(1985, p.477).{p_end}

   {cmd:1- Berndt  System R2} = 1-|E'E|  / |Yb'Yb|
   {cmd:2- McElroy System R2} = 1-(U'W*U)/ (Y'W*Y)
   {cmd:3- Judge   System R2} = 1-(U'U)  / (Y'Y)
   {cmd:4- Greene  System R2} = 1-(Q/trace(inv(Sig))*SYs)

{p 2 2 2}From each type of these system R2's, {cmd:r2sem} can calculate Adjusted R2, F-Test, and Chi2-Test:{p_end}

    {cmd:Adjusted R2} = 1-(1-R2)*((QN-Q)/(QN-K))
         {cmd:F-Test} = R2/(1-R2)*[(QN-K)/(K-Q)]
      {cmd:Chi2-Test} = -N*(log(1-R2))

where
   |E'E| = determinant of residual matrix (NxQ)
 |Yb'Yb| = determinant of dependent variables matrix in deviation from mean (NxQ)
      yi = dependent variable of eq. i (Nx1)
       Y = stacked vector of dependent variables (QNx1)
       U = stacked vector of residuals (QNx1)
       W = variance-covariance matrix of residuals (W=inv(Omega) # I(N))
       N = number of observations
       K = Number of Parameters
       Q = Number of Equations
     R2i = R2 of eq. i
      Dt = I(N)-JJ'/N, with J=(1,1,...,1)' (Nx1)
     SYs = (Yb1*Yb2*...Ybq)/N
     Sig = Sigma hat Matrix
 Degrees of Freedom F-Test    = (K-Q), (QN)
 Degrees of Freedom Chi2-Test = (K-Q)
 Log Determinant of Sigma     = log|Sigma matrix|

{marker 03}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:r2sem} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 15 2: Scalars}{p_end}
{col 4}{cmd:r(N)}{col 20}Number of Observations
{col 4}{cmd:r(k)}{col 20}Number of Parameters
{col 4}{cmd:r(k_eq)}{col 20}Number of Equations
{col 4}{cmd:r(chi_df)}{col 20}DF chi-squared
{col 4}{cmd:r(f_df1)}{col 20}F-Test DF1 Numerator
{col 4}{cmd:r(f_df2)}{col 20}F-Test DF2 Denominator
{col 4}{cmd:r(r2_b)}{col 20}Berndt R-squared
{col 4}{cmd:r(r2_j)}{col 20}Judge R-squared
{col 4}{cmd:r(r2_m)}{col 20}McElroy R-squared
{col 4}{cmd:r(r2_g)}{col 20}Greene R-squared
{col 4}{cmd:r(r2a_b)}{col 20}Berndt Adjusted R-squared
{col 4}{cmd:r(r2a_j)}{col 20}Judge Adjusted R-squared
{col 4}{cmd:r(r2a_m)}{col 20}McElroy Adjusted R-squared
{col 4}{cmd:r(r2a_g)}{col 20}Greene Adjusted R-squared
{col 4}{cmd:r(f_b)}{col 20}Berndt F Test
{col 4}{cmd:r(f_j)}{col 20}Judge F Test
{col 4}{cmd:r(f_m)}{col 20}McElroy F Test
{col 4}{cmd:r(f_g)}{col 20}Greene F Test
{col 4}{cmd:r(chi_b)}{col 20}Berndt Chi2 Test
{col 4}{cmd:r(chi_j)}{col 20}Judge Chi2 Test
{col 4}{cmd:r(chi_m)}{col 20}McElroy Chi2 Test
{col 4}{cmd:r(chi_g)}{col 20}Greene Chi2 Test
{col 4}{cmd:r(lsig2)}{col 20}Log Determinant of Sigma
{col 4}{cmd:r(llf)}{col 20}Log Likelihood Function{col 62}LLF

{marker 04}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Berndt, Ernst R. (1991)
{cmd: "The practice of econometrics: Classical and contemporary",}
{it:Addison-Wesley Publishing Company}; 468.

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA.}; 490-491.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 477-478.

{p 4 8 2}Kmenta, Jan (1986)
{cmd: "Elements of Econometrics",}
{it:2nd ed., Macmillan Publishing Company, Inc., New York, USA}; 645.

{p 4 8 2}McElroy, Marjorie B. (1977)
{cmd: "Goodness of Fit for Seemingly Unrelated Regressions: Glahn's R2y,x and Hooper's r~2",}
{it:Journal of Econometrics, 6(3), November}; 381-387.

{marker 05}{bf:{err:{dlgtab:Examples}}}

 in this example FIML will be used as follows:

	{stata clear all}

	{stata sysuse r2sem.dta , clear}

	{stata sem (y1 <- y2 x1 x2) (y2 <- y1 x3 x4), cov(e.y1*e.y2)}

	{stata r2sem}

	{stata return list}

 * If you want to use dialog box: Press OK to compute r2sem

	{stata db r2sem}
{hline}

. clear all
. sysuse r2sem.dta , clear
. sem (y1 <- y2 x1 x2) (y2 <- y1 x3 x4), cov(e.y1*e.y2)

Endogenous variables

Observed:  y1 y2

Exogenous variables

Observed:  x1 x2 x3 x4

Fitting target model:

Iteration 0:   log likelihood = -363.34854  
Iteration 1:   log likelihood = -363.34588  
Iteration 2:   log likelihood = -363.34588  

Structural equation model                       Number of obs      =        17
Estimation method  = ml
Log likelihood     = -363.34588

------------------------------------------------------------------------------
             |                 OIM
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
Structural   |
  y1 <-      |
          y2 |   .2425937   .2106232     1.15   0.249    -.1702201    .6554075
          x1 |   .2568409    .462485     0.56   0.579     -.649613    1.163295
          x2 |  -1.037016   .3154059    -3.29   0.001      -1.6552   -.4188317
       _cons |   147.0826    54.4491     2.70   0.007     40.36431    253.8009
  -----------+----------------------------------------------------------------
  y2 <-      |
          y1 |  -.6282929   .6148239    -1.02   0.307    -1.833326    .5767398
          x3 |  -.5226661   .3235637    -1.62   0.106    -1.156839    .1115071
          x4 |     3.4208   1.440664     2.37   0.018     .5971513    6.244449
       _cons |   62.44495   42.36071     1.47   0.140    -20.58052    145.4704
-------------+----------------------------------------------------------------
Variance     |
        e.y1 |   80.17577   28.99122                      39.46865    162.8673
        e.y2 |   142.4478   80.80501                      46.86006    433.0208
-------------+----------------------------------------------------------------
Covariance   |
  e.y1       |
        e.y2 |   25.62619   53.75243     0.48   0.634    -79.72665     130.979
------------------------------------------------------------------------------
LR test of model vs. saturated: chi2(2)   =      0.12, Prob > chi2 = 0.9408

. r2sem

==============================================================================
* Structural Equation Modeling: SEM - Method(ml)
* (SEM-FIML) Overall System R2 - Adjusted R2 - F Test - Chi2 Test
==============================================================================

+----------------------------------------------------------------------------------------+
|     Name |         R2 |     Adj_R2 |          F |    P-Value |       Chi2 |    P-Value |
|----------+------------+------------+------------+------------+------------+------------|
|   Berndt |     0.9189 |     0.8962 |    40.4497 |     0.0000 |    42.6990 |     0.0000 |
|  McElroy |     0.8043 |     0.7495 |    14.6785 |     0.0000 |    27.7303 |     0.0002 |
|    Judge |     0.8227 |     0.7731 |    16.5746 |     0.0000 |    29.4107 |     0.0001 |
|   Greene |     0.8096 |     0.7563 |    15.1863 |     0.0000 |    28.1969 |     0.0002 |
+----------------------------------------------------------------------------------------+
  Number of Parameters         =           9
  Number of Equations          =           2
  Degrees of Freedom F-Test    =      (7, 34)
  Degrees of Freedom Chi2-Test =           7
  Log Determinant of Sigma     =      9.2840
  Log Likelihood Function      =   -363.3459
------------------------------------------------------------------------------

{marker 06}{bf:{err:{dlgtab:Author}}}

- {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:R2SEM Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:R2SEM: "Stata Module to Compute (SEM-FIML) Overall System R2 - Adjusted R2 - F Test - Chi2 Test"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457431.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457431.htm"}


{title:Online Help:}

{bf:{err:* (1) (3SLS-SUR) * Simultaneous Equations:}}
{helpb lmareg3}{col 12}(3SLS-SUR) Overall System Autocorrelation Tests
{helpb lmhreg3}{col 12}(3SLS-SUR) Overall System Heteroscedasticity Tests
{helpb lmnreg3}{col 12}(3SLS-SUR) Overall System Non Normality Tests
{helpb lmcovreg3}{col 12}(3SLS-SUR) Breusch-Pagan Diagonal Covariance Matrix
{helpb r2reg3}{col 12}(3SLS-SUR) Overall System R2, F-Test, and Chi2-Test
{helpb diagreg3}{col 12}(3SLS-SUR) Overall System Model Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (2) (SEM-FIML) * Structural Equation Modeling:}}
{helpb lmasem}{col 12}(SEM-FIML) Overall System Autocorrelation Tests
{helpb lmhsem}{col 12}(SEM-FIML) Overall System Heteroscedasticity Tests
{helpb lmnsem}{col 12}(SEM-FIML) Overall System Non Normality Tests
{helpb lmcovsem}{col 12}(SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2sem}{col 12}(SEM-FIML) Overall System R2, F-Test, and Chi2-Test
{helpb diagsem}{col 12}(SEM-FIML) Overall System Model Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (3) (NL-SUR) * Non Linear Seemingly Unrelated Regression:}}
{helpb lmanlsur}{col 12}(NL-SUR) Overall System Autocorrelation Tests
{helpb lmhnlsur}{col 12}(NL-SUR) Overall System Heteroscedasticity Tests
{helpb lmnnlsur}{col 12}(NL-SUR) Overall System Non Normality Tests
{helpb lmcovnlsur}{col 12}(NL-SUR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2nlsur}{col 12}(NL-SUR) Overall System R2, F-Test, and Chi2-Test
{helpb diagnlsur}{col 12}(NL-SUR) Overall System Model Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (4) (VAR) * Vector Autoregressive Model:}}
{helpb lmavar}{col 12}(VAR) Overall System Autocorrelation Tests
{helpb lmhvar}{col 12}(VAR) Overall System Heteroscedasticity Tests
{helpb lmnvar}{col 12}(VAR) Overall System Non Normality Tests
{helpb lmcovvar}{col 12}(VAR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2var}{col 12}(VAR) Overall System R2, F-Test, and Chi2-Test
{helpb diagvar}{col 12}(VAR) Overall System Model Selection Diagnostic Criteria
---------------------------------------------------------------------------

{psee}
{p_end}

