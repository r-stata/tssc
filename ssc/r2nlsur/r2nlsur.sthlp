{smcl}
{hline}
{cmd:help: {helpb r2nlsur}}{space 50} {cmd:dialog:} {bf:{dialog r2nlsur}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:r2nlsur: (NL-SUR) Overall System R2 - Adjusted R2 - F Test - Chi2 Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb r2nlsur##01:Syntax}{p_end}
{p 5}{helpb r2nlsur##02:Description}{p_end}
{p 5}{helpb r2nlsur##03:Saved Results}{p_end}
{p 5}{helpb r2nlsur##04:References}{p_end}

{p 1}*** {helpb r2nlsur##05:Examples}{p_end}

{p 5}{helpb r2nlsur##06:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{cmd: r2nlsur}

{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:r2nlsur} computes Overall Nonlinear Seemingly Unrelated Regression (NL-SUR) System R2, Adj. R2, F-Test, and Chi2-Test after:{p_end}
{p 3 2 2}- {helpb nlsur}: (NL-SUR) Nonlinear Seemingly Unrelated Regression for sets of equations.{p_end}

{p 2 2 2}{cmd:r2nlsur} used 5 types of criteria and tests, as discussed in:{p_end}
{p 2 2 2}{cmd: McElroy(1977), Judge et al(1985), Dhrymes(1974), Greene(1993), and Berndt(1991)}.{p_end} 
{p 6 2 2}see eq.12.1.33-36 in Judge et al(1985, p.477).{p_end}

   {cmd:1- Berndt  System R2} = 1-|E'E|  / |Yb'Yb|
   {cmd:2- McElroy System R2} = 1-(U'W*U)/ (Y'W*Y)
   {cmd:3- Judge   System R2} = 1-(U'U)  / (Y'Y)
                           Q
   {cmd:4- Dhrymes System R2} = Sum [R2i (yi' Dt yi']/[Y(I(Q) # Dt)Y]
                          i=1
   {cmd:5- Greene  System R2} = 1-(Q/trace(inv(Sig))*SYs)

{p 2 2 2}From each type of these system R2's, {cmd:r2nlsur} can calculate Adjusted R2, F-Test, and Chi2-Test:{p_end}

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
{cmd:r2nlsur} saves the following in {cmd:r()}:

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

 {stata sysuse r2nlsur.dta , clear}

{cmd:* (1) NL-SUR Model:}

 {stata nlsur (y1={B10}+{B11}*y2+{B12}*x1+{B13}*x2) (y2={B20}+{B21}*y1+{B22}*x3+{B23}*x4)}

 {stata r2nlsur}


{cmd:* (2) SUR Model:}

 {stata sureg (y1 y2 x1 x2) (y2 y1 x3 x4)}

 {stata r2reg3}

 {stata return list}

 * If you want to use dialog box: Press OK to compute r2nlsur

	{stata db r2nlsur}
{hline}

. clear all
. sysuse r2nlsur.dta , clear
. nlsur (y1={B10}+{B11}*y2+{B12}*x1+{B13}*x2) (y2={B20}+{B21}*y1+{B22}*x3+{B23}*x4)

Calculating NLS estimates...
Iteration 0:  Residual SS =  3275.692
Iteration 1:  Residual SS =  3275.692
Calculating FGNLS estimates...
Iteration 0:  Scaled RSS =  33.99796
Iteration 1:  Scaled RSS =  33.99796

FGNLS regression 
---------------------------------------------------------------------
       Equation |       Obs  Parms       RMSE      R-sq     Constant
----------------+----------------------------------------------------
 1           y1 |        17      4   8.827101    0.8628          B10
 2           y2 |        17      4   10.71362    0.8332          B20
---------------------------------------------------------------------

------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        /B10 |   159.7348   48.37047     3.30   0.001     64.93046    254.5392
        /B11 |   .1440474   .1473363     0.98   0.328    -.1447264    .4328211
        /B12 |   .3736436   .4464905     0.84   0.403    -.5014617    1.248749
        /B13 |   -1.17085   .2398822    -4.88   0.000     -1.64101   -.7006895
        /B20 |   40.22012   31.80722     1.26   0.206    -22.12087    102.5611
        /B21 |  -.0911744   .2613464    -0.35   0.727    -.6034038    .4210551
        /B22 |  -.3973436   .2758714    -1.44   0.150    -.9380417    .1433545
        /B23 |   2.480269    1.01631     2.44   0.015     .4883381    4.472201
------------------------------------------------------------------------------

. r2nlsur

==============================================================================
* Nonlinear Seemingly Unrelated Regression: Method = (fgnls)
* (NL-SUR) Overall System R2 - Adjusted R2 - F Test - Chi2 Test
==============================================================================

+----------------------------------------------------------------------------------+
|     Name |        R2 |    Adj_R2 |         F |   P-Value |      Chi2 |   P-Value |
|----------+-----------+-----------+-----------+-----------+-----------+-----------|
|   Berndt |    0.9326 |    0.9171 |   59.9838 |    0.0000 |   45.8573 |    0.0000 |
|  McElroy |    0.8506 |    0.8161 |   24.6660 |    0.0000 |   32.3159 |    0.0000 |
|    Judge |    0.8466 |    0.8111 |   23.9065 |    0.0000 |   31.8647 |    0.0000 |
|  Dhrymes |    0.8466 |    0.8111 |   23.9065 |    0.0000 |   31.8647 |    0.0000 |
|   Greene |    0.8173 |    0.7751 |   19.3807 |    0.0000 |   28.8954 |    0.0001 |
+----------------------------------------------------------------------------------+
  Number of Parameters         =           8
  Number of Equations          =           2
  Degrees of Freedom F-Test    =      (6, 34)
  Degrees of Freedom Chi2-Test =           6
  Log Determinant of Sigma     =      9.0985
  Log Likelihood Function      =   -125.5810
------------------------------------------------------------------------------

{marker 06}{bf:{err:{dlgtab:Author}}}

- {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:R2NLSUR Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2014)}{p_end}
{p 1 10 1}{cmd:R2NLSUR: "Stata Module to Compute (NL-SUR) Overall System R2, F-Test, and Chi2-Test"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457493.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457493.htm"}

{title:Online Help:}

{bf:{err:* Model Selection Diagnostic Criteria:}}
{helpb diagmle}{col 12}MLE Model Selection Diagnostic Criteria
{helpb diagnl}{col 12}NLS Model Selection Diagnostic Criteria
{helpb diagnlsur}{col 12}(NL-SUR) Overall System Model Selection Diagnostic Criteria
{helpb diagreg}{col 12}OLS Model Selection Diagnostic Criteria
{helpb diagreg2}{col 12}2SLS-IV Model Selection Diagnostic Criteria
{helpb diagreg3}{col 12}(3SLS-SUR) Overall System Model Selection Diagnostic Criteria
{helpb diagsem}{col 12}(SEM-FIML) Overall System Model Selection Diagnostic Criteria
{helpb diagvar}{col 12}(VAR) Overall System Model Selection Diagnostic Criteria
{helpb diagxt}{col 12}Panel Data Model Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* Linear vs Log-Linear Functional Form Tests:}}
{helpb lmfmle}{col 12}MLE Linear vs Log-Linear Functional Form Tests
{helpb lmfreg}{col 12}OLS Linear vs Log-Linear Functional Form Tests
{helpb lmfreg2}{col 12}2SLS-IV Linear vs Log-Linear Functional Form Tests
---------------------------------------------------------------------------
{helpb lmhaus2}{col 12}2SLS-IV Hausman Specification Test
{helpb lmhausxt}{col 12}Panel Data Hausman Specification Test
---------------------------------------------------------------------------
{helpb lmiden2}{col 12}2SLS-IV Over Identification Restrictions Tests
---------------------------------------------------------------------------
{helpb lmeg}{col 12}Augmented Engle-Granger Cointegration Test
{helpb lmgc}{col 12}2SLS-IV Granger Causality Test
{helpb lmsrd}{col 12}OLS Spurious Regression Diagnostic
---------------------------------------------------------------------------
{bf:{err:* REgression Specification Error Tests (RESET):}}
{helpb reset}{col 12}OLS REgression Specification Error Tests (RESET)
{helpb reset2}{col 12}2SLS-IV REgression Specification Error Tests (RESET)
{helpb resetmle}{col 12}MLE REgression Specification Error Tests (RESET)
{helpb resetxt}{col 12}Panel Data REgression Specification Error Tests (RESET)
---------------------------------------------------------------------------

{psee}
{p_end}

