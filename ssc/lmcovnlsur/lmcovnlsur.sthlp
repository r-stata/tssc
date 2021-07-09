{smcl}
{hline}
{cmd:help: {helpb lmcovnlsur}}{space 50} {cmd:dialog:} {bf:{dialog lmcovnlsur}}
{hline}

{bf:{err:{dlgtab:Title}}}

{p 4 8 2}
{bf:lmcovnlsur: (NL-SUR) Breusch-Pagan Diagonal Covariance Matrix LM Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmcovnlsur##01:Syntax}{p_end}
{p 5}{helpb lmcovnlsur##02:Description}{p_end}
{p 5}{helpb lmcovnlsur##03:Saved Results}{p_end}
{p 5}{helpb lmcovnlsur##04:References}{p_end}

{p 1}*** {helpb lmcovnlsur##05:Examples}{p_end}

{p 5}{helpb lmcovnlsur##06:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 10 4 6}
{opt lmcovnlsur}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:lmcovnlsur} computes (NL-SUR) Breusch-Pagan Diagonal Covariance Matrix LM Test after:{p_end}
{p 3 2 2}- (NL-SUR) Seemingly Unrelated Regression {helpb nlsur} for sets of equations.{p_end} 

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:lmcovnlsur} saves the following in {cmd:r()}:

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

 {stata clear all}

 {stata sysuse lmcovnlsur.dta , clear}

{cmd:* (1) NL-SUR Model:}

 {stata nlsur (y1={B10}+{B11}*y2+{B12}*x1+{B13}*x2) (y2={B20}+{B21}*y1+{B22}*x3+{B23}*x4) , variables(y1 y2 x1 x2 x3 x4)}

 {stata lmcovnlsur}

 {stata return list}


{cmd:* (2) SUR Model:}

 {stata sureg (y1 y2 x1 x2) (y2 y1 x3 x4)}

 {stata lmcovnlsur}

 {stata return list}
{hline}


. clear all
. sysuse lmcovnlsur.dta , clear
. nlsur (y1={B10}+{B11}*y2+{B12}*x1+{B13}*x2) (y2={B20}+{B21}*y1+{B22}*x3+{B23}*x4) , variables(y1 y2 x1 x2 x3 x4)
(obs = 17)

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

. lmcovnlsur

==============================================================================
* (NL-SUR) Breusch-Pagan Diagonal Covariance Matrix LM Test: Method = (fgnls)
==============================================================================
    Ho: Diagonal Disturbance Covariance Matrix (Independent Equations)
    Ho: Run NLS  -  Ha: Run NL-SUR

    Lagrange Multiplier Test  =    0.00149
    Degrees of Freedom        =        1.0
    P-Value > Chi2(1)         =    0.96921
==============================================================================

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

. lmcovnlsur

==============================================================================
* (NL-SUR) Breusch-Pagan Diagonal Covariance Matrix LM Test: Method = (sure)
==============================================================================
    Ho: Diagonal Disturbance Covariance Matrix (Independent Equations)
    Ho: Run NLS  -  Ha: Run NL-SUR

    Lagrange Multiplier Test  =    0.00149
    Degrees of Freedom        =        1.0
    P-Value > Chi2(1)         =    0.96921
==============================================================================

{marker 06}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:LMCOVNLSUR Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:LMCOVNLSUR: "Stata Module to Compute (NL-SUR) Breusch-Pagan Diagonal Covariance Matrix LM Test"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457490.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457490.htm"}


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

