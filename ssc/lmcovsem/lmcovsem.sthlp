{smcl}
{hline}
{cmd:help: {helpb lmcovsem}}{space 50} {cmd:dialog:} {bf:{dialog lmcovsem}}
{hline}

{bf:{err:{dlgtab:Title}}}

{p 4 8 2}
{bf:lmcovsem: (SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix LM Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmcovsem##01:Syntax}{p_end}
{p 5}{helpb lmcovsem##02:Description}{p_end}
{p 5}{helpb lmcovsem##03:Saved Results}{p_end}
{p 5}{helpb lmcovsem##04:References}{p_end}

{p 1}*** {helpb lmcovsem##05:Examples}{p_end}

{p 5}{helpb lmcovsem##06:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 10 4 6}
{opt lmcovsem}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}
{p 2 2 2}- (SEM) Structural Equation Modeling Regressions {helpb sem} for system of simultaneous equations.{p_end}
{p 3 2 2}- SEM Estimations assume:{p_end} 
{p 4 7 7}1- Independence of the errors in each eqution or no correlations between different periods in the same equation.{p_end} 
{p 4 7 7}2- no correlations between the errors for any of two equtions between two different periods, this is called {cmd:"Intertemporal Correlation"}.{p_end} 
{p 4 7 7}3- correlations may be exist between different two equations, but at the same period, and this is called {cmd:"Contemporaneous Correlation"}.{p_end} 
{p 4 7 7}4- SEM can be applied when there is correlations between different two equations at the same period, or if the independent variables are differnt from equation to equation.{p_end} 
{p 4 7 7}5- If {cmd:"Contemporaneous Correlation"} does not exist, ordinary least squares (OLS) can be applied separately to each equation, the results are fully efficient and there is no need to estimate SEM.{p_end} 
{p 4 4 4} Breusch-Pagan LM can test whether contemporaneous diagonal covariance matrix is 0. (Independence of the Errors), or correlated if at least one covariance is nonzero.{p_end} 
{p 4 4 4} Ho: {cmd:no Contemporaneous Correlation}: Sig12 = Sig13 = Sig23 = ... = 0.{p_end} 
{p 4 4 4} Ha: {cmd:   Contemporaneous Correlation}: at least one Covariance is nonzero.{p_end} 

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:lmcovsem} saves the following in {cmd:r()}:

{col 4}{cmd:r(lmcov)}{col 20}LM Diagonal Covariance Matrix Test
{col 4}{cmd:r(lmcovp)}{col 20}LM Diagonal Covariance Matrix Test P-Value
{col 4}{cmd:r(lmcovdf)}{col 20}Chi2 Degrees of Freedom

{marker 04}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 456-461.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Examples}}}

 in this example FIML will be used as follows:

	{stata clear all}

	{stata sysuse lmcovsem.dta , clear}

	{stata sem (y1 <- y2 x1 x2) (y2 <- y1 x3 x4), cov(e.y1*e.y2)}

	{stata lmcovsem}

	{stata return list}

 * If you want to use dialog box: Press OK to compute lmcovsem

	{stata db lmcovsem}
{hline}

. clear all
. sysuse lmcovsem.dta , clear
. sem (y1 <- y2 x1 x2) (y2 <- y1 x3 x4), cov(e.y1*e.y2)

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

. lmcovsem
==============================================================================
* (SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix LM Test - Method(ml) 
==============================================================================
    Ho: Diagonal Disturbance Covariance Matrix (Independent Equations)
    Ho: Run OLS  -  Ha: Run SEM

    Lagrange Multiplier Test  =    0.97750
    Degrees of Freedom        =        1.0
    P-Value > Chi2(1)         =    0.32282
==============================================================================

{marker 06}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:LMCOVSEM Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:LMCOVSEM: "Stata Module to Compute (SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix LM Test"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457435.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457435.htm"}


{title:Online Help:}

{bf:{err:* Breusch-Pagan Diagonal Covariance Matrix Test:}}
{helpb lmcovnlsur}{col 12}(NL-SUR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovreg3}{col 12}(3SLS-SUR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovsem}{col 12}(SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovvar}{col 12}(VAR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovxt}{col 12}Panel Data Breusch-Pagan Diagonal Covariance Matrix Test
---------------------------------------------------------------------------

{bf:{err:* (1) (3SLS-SUR) * Simultaneous Equations:}}
{helpb lmareg3}{col 12}(3SLS-SUR) Overall System Autocorrelation Tests
{helpb lmhreg3}{col 12}(3SLS-SUR) Overall System Heteroscedasticity Tests
{helpb lmnreg3}{col 12}(3SLS-SUR) Overall System Non Normality Tests
{helpb lmcovreg3}{col 12}(3SLS-SUR) Breusch-Pagan Diagonal Covariance Matrix
{helpb r2reg3}{col 12}(3SLS-SUR) Overall System R2, F-Test, and Chi2-Test
{helpb diagreg3}{col 12}(3SLS-SUR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (2) (SEM-FIML) * Structural Equation Modeling:}}
{helpb lmasem}{col 12}(SEM-FIML) Overall System Autocorrelation Tests
{helpb lmhsem}{col 12}(SEM-FIML) Overall System Heteroscedasticity Tests
{helpb lmnsem}{col 12}(SEM-FIML) Overall System Non Normality Tests
{helpb lmcovsem}{col 12}(SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2sem}{col 12}(SEM-FIML) Overall System R2, F-Test, and Chi2-Test
{helpb diagsem}{col 12}(SEM-FIML) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (3) (NL-SUR) * Non Linear Seemingly Unrelated Regression:}}
{helpb lmanlsur}{col 12}(NL-SUR) Overall System Autocorrelation Tests
{helpb lmhnlsur}{col 12}(NL-SUR) Overall System Heteroscedasticity Tests
{helpb lmnnlsur}{col 12}(NL-SUR) Overall System Non Normality Tests
{helpb lmcovnlsur}{col 12}(NL-SUR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2nlsur}{col 12}(NL-SUR) Overall System R2, F-Test, and Chi2-Test
{helpb diagnlsur}{col 12}(NL-SUR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (4) (VAR) * Vector Autoregressive Model:}}
{helpb lmavar}{col 12}(VAR) Overall System Autocorrelation Tests
{helpb lmhvar}{col 12}(VAR) Overall System Heteroscedasticity Tests
{helpb lmnvar}{col 12}(VAR) Overall System Non Normality Tests
{helpb lmcovvar}{col 12}(VAR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2var}{col 12}(VAR) Overall System R2, F-Test, and Chi2-Test
{helpb diagvar}{col 12}(VAR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------

{psee}
{p_end}

