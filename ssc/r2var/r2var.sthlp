{smcl}
{hline}
{cmd:help: {helpb r2var}}{space 50} {cmd:dialog:} {bf:{dialog r2var}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:r2var: (VAR) Overall System R2, F-Test, and Chi2-Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb r2var##01:Syntax}{p_end}
{p 5}{helpb r2var##02:Options}{p_end}
{p 5}{helpb r2var##03:Description}{p_end}
{p 5}{helpb r2var##04:Saved Results}{p_end}
{p 5}{helpb r2var##05:References}{p_end}

{p 1}*** {helpb r2var##06:Examples}{p_end}

{p 5}{helpb r2var##07:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt r2var} {depvars} {ifin} , {err: [} {opt noconst:ant} {opth la:gs(numlist)}
{opth ex:og(varlist)}{p_end} 
{p 5 5 6} 
{opt nolo:g} {cmdab:const:raints(}{it:{help estimation options##constraints():numlist}}{cmd:)} {opt it:erate(#)} {opt dfk} {opt nobig:f} {opt sm:all}{p_end} 
{p 5 5 6} 
 {opt tol:erance(#)} {opt nois:ure} {opt nocnsr:eport} {opt l:evel(#)} {err:]}{p_end}
 
{marker 02}{bf:{err:{dlgtab:Options}}}

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}

{synopt:{opt noconst:ant}}suppress constant term{p_end}

{synopt:{opt lag:s(#/#)}}Dependent Variables Lag length; default is (1/1){p_end}

{synopt:{opth exog(varlist)}}use exogenous variables {it:varlist}{p_end}

{syntab:Model 2}
{synopt:{cmdab:const:raints(}{it:{help estimation options##constraints():numlist}}{cmd:)}}apply specified linear constraints{p_end}
{synopt:{opt nolo:g}}suppress SURE iteration log{p_end}
{synopt:{opt tol:erance(#)}}set convergence tolerance of SURE{p_end}
{synopt:{opt nois:ure}}use one-step SURE{p_end}
{synopt:{opt dfk}}make small-sample degrees-of-freedom adjustment{p_end}
{synopt:{opt sm:all}}report small-sample t and F statistics{p_end}
{synopt:{opt nobig:f}}do not compute parameter vector for coefficients implicitly set to zero {p_end}
{synopt:{opt it:erate(#)}}set maximum number of iterations for SURE; default is {cmd:iterate(1600)}{p_end}
{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}

*** {helpb tsset} must be used before using {cmd:r2var}

{it:depvarlist} and {it:varlist} may contain time-series operators; see {help tsvarlist}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:r2var} computes Overall System R-squared (R2), Adjusted R2, and the overall significance of F-Test, and Chi2-Test, after:{p_end}
{p 3 2 2}- ({helpb var}): Vector Autoregressive Model (VAR).{p_end}

 Most {cmd:r2var} options are identically to official ({helpb var}) command

{p 2 2 2}{cmd:r2var} used 5 types of criteria and tests, as discussed in:{p_end}
{p 2 2 2}{cmd: McElroy(1977), Judge et al(1985), Dhrymes(1974), Greene(1993), and Berndt(1991)}.{p_end} 
{p 6 2 2}see eq.12.1.33-36 in Judge et al(1985, p.477).{p_end}

   {cmd:1- Berndt  System R2} = 1-|E'E|  / |Yb'Yb|
   {cmd:2- McElroy System R2} = 1-(U'W*U)/ (Y'W*Y)
   {cmd:3- Judge   System R2} = 1-(U'U)  / (Y'Y)
                           Q
   {cmd:4- Dhrymes System R2} = Sum [R2i (yi' Dt yi']/[Y(I(Q) # Dt)Y]
                          i=1
   {cmd:5- Greene  System R2} = 1-(Q/trace(inv(Sig))*SYs)

{p 2 2 2}From each type of these system R2's, {cmd:r2var} can calculate Adjusted R2, F-Test, and Chi2-Test:{p_end}

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

{p 3 2 2}- ({helpb var}) model with SURE estimations assumes:{p_end} 
{p 4 7 7}1- Independence of the errors in each eqution or no correlations between different periods in the same equation.{p_end} 
{p 4 7 7}2- no correlations between the errors for any of two equtions between two different periods, this is called {cmd:"Intertemporal Correlation"}.{p_end} 
{p 4 7 7}3- correlations may be exist between different two equations, but at the same period, and this is called {cmd:"Contemporaneous Correlation"}.{p_end} 
{p 4 7 7}4- SURE can be applied when there is correlations between different two equations at the same period, or if the independent variables are differnt from equation to equation.{p_end} 
{p 4 7 7}4- If {cmd:"Contemporaneous Correlation"} does not exist, ordinary least squares (OLS) can be applied separately to each equation, the results are fully efficient and there is no need to estimate SURE.{p_end} 
{p 4 4 4} Breusch-Pagan Diagonal Covariance Matrix LM Test can test whether contemporaneous diagonal covariance matrix is 0. (Independence of the Errors), or correlated if at least one covariance is nonzero.{p_end} 
{p 4 4 4} Ho: {cmd:no Contemporaneous Correlation}: Sig12 = Sig13 = Sig23 = ... = 0.{p_end} 
{p 4 4 4} Ha: {cmd:   Contemporaneous Correlation}: at least one Covariance is nonzero.{p_end}

{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:r2var} saves the following in {cmd:r()}:

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
{col 4}{cmd:r(llf)}{col 20}Log Likelihood Function

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Berndt, Ernst R. (1991)
{cmd: "The practice of econometrics: Classical and contemporary",}
{it:Addison-Wesley Publishing Company}; 468.

{p 4 8 2}Dhrymes, Phoebus J. (1974)
{cmd: "Econometrics: Statistical Foundations and Applications",}
{it:2ed edition Springer- Verlag New York, USA.}.

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA.}; 490-491.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 758-763.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 477-478.

{p 4 8 2}Kmenta, Jan (1986)
{cmd: "Elements of Econometrics",}
{it:2nd ed., Macmillan Publishing Company, Inc., New York, USA}; 645.

{p 4 8 2}McElroy, Marjorie B. (1977)
{cmd: "Goodness of Fit for Seemingly Unrelated Regressions: Glahn's R2y,x and Hooper's r~2",}
{it:Journal of Econometrics, 6(3), November}; 381-387.

{marker 06}{bf:{err:{dlgtab:Examples}}}

 * If you want to use dialog box: Press OK to compute r2var

	{stata db r2var}

{cmd:* Data of This example are taken from:}
{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 758-763.

	{stata clear all}

	{stata sysuse r2var.dta , clear}

	{stata tsset t}

	{stata r2var y1 y2 , lags(1/1) exog(x1 x2)}

	{stata r2var y1 y2 in 5/71 , lags(1/1)}

	{stata r2var y1 y2 in 5/71 , lags(1/2)}

	{stata r2var y1 y2 in 5/71 , lags(1/3)}

	{stata return list}
{hline}

. clear all
. sysuse r2var.dta , clear
. tsset t
. r2var y1 y2 in 5/71 , lags(1/1)

Vector autoregression

Sample:  5 - 71                                    No. of obs      =        67
Log likelihood = -566.0542                         AIC             =  17.07625
FPE            =  89376.34                         HQIC            =  17.15437
Det(Sigma_ml)  =  74711.32                         SBIC            =  17.27368

Equation           Parms      RMSE     R-sq      chi2     P>chi2
----------------------------------------------------------------
y1                    3     16.6829   0.2878   27.07799   0.0000
y2                    3     19.9034   0.1863   15.33891   0.0005
----------------------------------------------------------------

------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y1           |
          y1 |
         L1. |  -.0903073   .1279538    -0.71   0.480    -.3410921    .1604774
             |
          y2 |
         L1. |   .5189002    .114004     4.55   0.000     .2954564     .742344
             |
       _cons |   7.949964   2.585932     3.07   0.002      2.88163     13.0183
-------------+----------------------------------------------------------------
y2           |
          y1 |
         L1. |   .1970232   .1526549     1.29   0.197    -.1021748    .4962212
             |
          y2 |
         L1. |    .297665   .1360122     2.19   0.029     .0310861     .564244
             |
       _cons |   8.537288   3.085138     2.77   0.006     2.490528    14.58405
------------------------------------------------------------------------------

==============================================================================
* (VAR) Overall System R2 - Adjusted R2 - F Test - Chi2 Test - (Lag = 1)
==============================================================================

+----------------------------------------------------------------------------+
|     Name |       R2 |   Adj_R2 |        F |  P-Value |     Chi2 |  P-Value |
|----------+----------+----------+----------+----------+----------+----------|
|   Berndt |   0.3369 |   0.3162 |  16.2580 |   0.0000 |  27.5253 |   0.0000 |
|  McElroy |   0.1943 |   0.1691 |   7.7171 |   0.0000 |  14.4751 |   0.0059 |
|    Judge |   0.2315 |   0.2075 |   9.6397 |   0.0000 |  17.6423 |   0.0014 |
|  Dhrymes |   0.2315 |   0.2075 |   9.6397 |   0.0000 |  17.6423 |   0.0014 |
|   Greene |   0.0604 |   0.0311 |   2.0580 |   0.0898 |   4.1760 |   0.3827 |
+----------------------------------------------------------------------------+
  (VAR) Lag Order              =           1
  Number of Parameters         =           6
  Number of Equations          =           2
  Degrees of Freedom F-Test    =      (4, 134)
  Degrees of Freedom Chi2-Test =           4
  Log Determinant of Sigma     =     11.2214
  Log Likelihood Function      =   -566.0542
------------------------------------------------------------------------------

{marker 07}{bf:{err:{dlgtab:Authors}}}

- {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

- {hi:Sahra Khaleel A. Mickaiel}
  {hi:Professor (PhD Economics)}
  {hi:Cairo University - Faculty of Agriculture - Department of Economics - Egypt}
  {hi:Email: {browse "mailto:sahra_atta@hotmail.com":sahra_atta@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/pmi520.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/pmi520.htm"}}

{bf:{err:{dlgtab:R2VAR Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2014)}{p_end}
{p 1 10 1}{cmd:R2VAR: "Stata Module to Compute (VAR) Overall System R2, F-Test, and Chi2-Test"}{p_end}

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

