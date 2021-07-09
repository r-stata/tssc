{smcl}
{hline}
{cmd:help: {helpb r2reg3}}{space 50} {cmd:dialog:} {bf:{dialog r2reg3}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:r2reg3: (3SLS-SUR) Overall System R2 - Adjusted R2 - F Test - Chi2 Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb r2reg3##01:Syntax}{p_end}
{p 5}{helpb r2reg3##02:Description}{p_end}
{p 5}{helpb r2reg3##03:Saved Results}{p_end}
{p 5}{helpb r2reg3##04:References}{p_end}

{p 1}*** {helpb r2reg3##05:Examples}{p_end}

{p 5}{helpb r2reg3##06:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{cmd: r2reg3}

{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:r2reg3} computes Overall System R-squared (R2), Adjusted R2, and the overall significance of F-Test, and Chi2-Test, after:{p_end}
{p 3 2 2}- {helpb reg3}: (3SLS) Three-Stage Least Squares for systems of simultaneous equations.{p_end}
{p 3 2 2}- {helpb sureg}: (SUR) Seemingly Unrelated Regression for sets of equations.{p_end}

{p 2 2 2}{cmd:r2reg3} used 5 types of criteria and tests, as discussed in:{p_end}
{p 2 2 2}{cmd: McElroy(1977), Judge et al(1985), Dhrymes(1974), Greene(1993), and Berndt(1991)}.{p_end} 
{p 6 2 2}see eq.12.1.33-36 in Judge et al(1985, p.477).{p_end}

   {cmd:1- Berndt  System R2} = 1-|E'E|  / |Yb'Yb|
   {cmd:2- McElroy System R2} = 1-(U'W*U)/ (Y'W*Y)
   {cmd:3- Judge   System R2} = 1-(U'U)  / (Y'Y)
                           Q
   {cmd:4- Dhrymes System R2} = Sum [R2i (yi' Dt yi']/[Y(I(Q) # Dt)Y]
                          i=1
   {cmd:5- Greene  System R2} = 1-(Q/trace(inv(Sig))*SYs)

{p 2 2 2}From each type of these system R2's, {cmd:r2reg3} can calculate Adjusted R2, F-Test, and Chi2-Test:{p_end}

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
 Log Likelihood Function LLF  =-(N*Q/2)*(1+log(2*_pi))-(N/2*abs(log(Sigma)))

{marker 03}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:r2reg3} saves the following in {cmd:r()}:

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
{col 4}{cmd:r(r2_d)}{col 20}Dhrymes R-squared
{col 4}{cmd:r(r2_g)}{col 20}Greene R-squared
{col 4}{cmd:r(r2a_b)}{col 20}Berndt Adjusted R-squared
{col 4}{cmd:r(r2a_j)}{col 20}Judge Adjusted R-squared
{col 4}{cmd:r(r2a_m)}{col 20}McElroy Adjusted R-squared
{col 4}{cmd:r(r2a_d)}{col 20}Dhrymes Adjusted R-squared
{col 4}{cmd:r(r2a_g)}{col 20}Greene Adjusted R-squared
{col 4}{cmd:r(f_b)}{col 20}Berndt F Test
{col 4}{cmd:r(f_j)}{col 20}Judge F Test
{col 4}{cmd:r(f_m)}{col 20}McElroy F Test
{col 4}{cmd:r(f_d)}{col 20}Dhrymes F Test
{col 4}{cmd:r(f_g)}{col 20}Greene F Test
{col 4}{cmd:r(chi_b)}{col 20}Berndt Chi2 Test
{col 4}{cmd:r(chi_j)}{col 20}Judge Chi2 Test
{col 4}{cmd:r(chi_m)}{col 20}McElroy Chi2 Test
{col 4}{cmd:r(chi_d)}{col 20}Dhrymes Chi2 Test
{col 4}{cmd:r(chi_g)}{col 20}Greene Chi2 Test
{col 4}{cmd:r(lsig2)}{col 20}Log Determinant of Sigma
{col 4}{cmd:r(llf)}{col 20}Log Likelihood Function{col 62}LLF

{marker 04}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Berndt, Ernst R. (1991)
{cmd: "The practice of econometrics: Classical and contemporary",}
{it:Addison-Wesley Publishing Company}; 468.

{p 4 8 2}Dhrymes, Phoebus J. (1974)
{cmd: "Econometrics: Statistical Foundations and Applications",}
{it:2ed edition Springer- Verlag New York, USA.}.

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

	{stata clear all}

	{stata sysuse r2reg3.dta , clear}

 {cmd:* (1) SUR Model:}

	{stata sureg (y1 y2 x1 x2) (y2 y1 x3 x4)}

	{stata r2reg3}

	{stata return list}

 {cmd:* (2) 3SLS Model:}

	{stata reg3 (y1 y2 x1 x2) (y2 y1 x3 x4) , exog(x1 x2 x3 x4)}

	{stata r2reg3}

	{stata return list}

 * If you want to use dialog box: Press OK to compute r2reg3

	{stata db r2reg3}
{hline}

. clear all
. sysuse r2reg3.dta , clear
. * (1) SUR Model:
. sureg (y1 y2 x1 x2) (y2 y1 x3 x4)

Seemingly unrelated regression
----------------------------------------------------------------------
Equation          Obs  Parms        RMSE    "R-sq"       chi2        P
----------------------------------------------------------------------
y1                 17      3    8.827101    0.8628     106.88   0.0000
y2                 17      3    10.71362    0.8332      84.91   0.0000
----------------------------------------------------------------------

------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y1           |
          y2 |   .1440474   .1473363     0.98   0.328    -.1447264    .4328211
          x1 |   .3736436   .4464905     0.84   0.403    -.5014617    1.248749
          x2 |   -1.17085   .2398822    -4.88   0.000     -1.64101   -.7006895
       _cons |   159.7348   48.37047     3.30   0.001     64.93046    254.5392
-------------+----------------------------------------------------------------
y2           |
          y1 |  -.0911744   .2613464    -0.35   0.727    -.6034038    .4210551
          x3 |  -.3973436   .2758714    -1.44   0.150    -.9380417    .1433545
          x4 |   2.480269    1.01631     2.44   0.015     .4883381    4.472201
       _cons |   40.22012   31.80722     1.26   0.206    -22.12087    102.5611
------------------------------------------------------------------------------

. r2reg3

==============================================================================
* Simultaneous Equations (3SLS-SUR) - Method = (sure)
* (3SLS-SUR) Overall System R2 - Adjusted R2 - F Test - Chi2 Test
==============================================================================

+----------------------------------------------------------------------------------------+
|     Name |         R2 |     Adj_R2 |          F |    P-Value |       Chi2 |    P-Value |
|----------+------------+------------+------------+------------+------------+------------|
|   Berndt |     0.9326 |     0.9171 |    59.9838 |     0.0000 |    45.8573 |     0.0000 |
|  McElroy |     0.8506 |     0.8161 |    24.6660 |     0.0000 |    32.3159 |     0.0000 |
|    Judge |     0.8466 |     0.8111 |    23.9065 |     0.0000 |    31.8647 |     0.0000 |
|  Dhrymes |     0.9292 |     0.9128 |    56.8570 |     0.0000 |    45.0101 |     0.0000 |
|   Greene |     0.8173 |     0.7751 |    19.3807 |     0.0000 |    28.8954 |     0.0001 |
+----------------------------------------------------------------------------------------+
  Number of Parameters         =           8
  Number of Equations          =           2
  Degrees of Freedom F-Test    =      (6, 34)
  Degrees of Freedom Chi2-Test =           6
  Log Determinant of Sigma     =      9.0985
  Log Likelihood Function      =   -125.5810
------------------------------------------------------------------------------

. * (2) 3SLS Model:
. reg3 (y1 y2 x1 x2) (y2 y1 x3 x4) , exog(x1 x2 x3 x4)

Three-stage least-squares regression
----------------------------------------------------------------------
Equation          Obs  Parms        RMSE    "R-sq"       chi2        P
----------------------------------------------------------------------
y1                 17      3    8.947416    0.8590     104.54   0.0000
y2                 17      3    11.93733    0.7929      69.52   0.0000
----------------------------------------------------------------------

------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y1           |
          y2 |   .2398091   .2116599     1.13   0.257    -.1750367    .6546549
          x1 |   .2592727   .4671355     0.56   0.579    -.6562961    1.174842
          x2 |   -1.04074   .3167524    -3.29   0.001    -1.661563   -.4199164
       _cons |   147.5251   53.59456     2.75   0.006     42.48173    252.5685
-------------+----------------------------------------------------------------
y2           |
          y1 |  -.6287858   .6029723    -1.04   0.297     -1.81059    .5530181
          x3 |  -.5226034    .332618    -1.57   0.116    -1.174523     .129316
          x4 |    3.42094   1.484046     2.31   0.021     .5122637    6.329616
       _cons |   62.49335    40.3145     1.55   0.121    -16.52163    141.5083
------------------------------------------------------------------------------
Endogenous variables:  y1 y2 
Exogenous variables:   x1 x2 x3 x4 
------------------------------------------------------------------------------

. r2reg3

==============================================================================
* Simultaneous Equations (3SLS-SUR) - Method = (3sls)
* (3SLS-SUR) Overall System R2 - Adjusted R2 - F Test - Chi2 Test
==============================================================================

+----------------------------------------------------------------------------------------+
|     Name |         R2 |     Adj_R2 |          F |    P-Value |       Chi2 |    P-Value |
|----------+------------+------------+------------+------------+------------+------------|
|   Berndt |     0.9191 |     0.9004 |    49.2299 |     0.0000 |    42.7469 |     0.0000 |
|  McElroy |     0.8042 |     0.7590 |    17.7985 |     0.0000 |    27.7216 |     0.0001 |
|    Judge |     0.8228 |     0.7819 |    20.1180 |     0.0000 |    29.4159 |     0.0001 |
|  Dhrymes |     0.9050 |     0.8831 |    41.3032 |     0.0000 |    40.0243 |     0.0000 |
|   Greene |     0.8104 |     0.7666 |    18.5204 |     0.0000 |    28.2672 |     0.0001 |
+----------------------------------------------------------------------------------------+
  Number of Parameters         =           8
  Number of Equations          =           2
  Degrees of Freedom F-Test    =      (6, 34)
  Degrees of Freedom Chi2-Test =           6
  Log Determinant of Sigma     =      9.2772
  Log Likelihood Function      =   -127.1003
------------------------------------------------------------------------------

{marker 06}{bf:{err:{dlgtab:Author}}}

- {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:R2REG3 Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:R2REG3: "Stata Module to Compute (3SLS-SUR) Overall System R2 - Adjusted R2 - F Test - Chi2 Test"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457322.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457322.htm"}

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

