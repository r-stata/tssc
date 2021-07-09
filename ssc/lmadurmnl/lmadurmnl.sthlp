{smcl}
{hline}
{cmd:help: {helpb lmadurmnl}}{space 50} {cmd:dialog:} {bf:{dialog lmadurmnl}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmadurmnl: NLS Autocorrelation Dynamic Durbin m Test at Higher Order AR(p)}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmadurmnl##01:Syntax}{p_end}
{p 5}{helpb lmadurmnl##02:Options}{p_end}
{p 5}{helpb lmadurmnl##03:Description}{p_end}
{p 5}{helpb lmadurmnl##04:Saved Results}{p_end}
{p 5}{helpb lmadurmnl##05:References}{p_end}

{p 1}*** {helpb lmadurmnl##06:Examples}{p_end}

{p 5}{helpb lmadurmnl##07:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 3 5 6}
{cmd:lmadurmnl} {depvar} {ifin} {weight} , {opt fun(expression)} {opt lag:s(#)}{p_end} 
{p 5 5 6}
{err: [} {opt in:itial(init_val)} {opth var:iables(varlist)} {cmd:vce(}{it:{help nl##vcetype:vcetype}} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Options}}}
{synoptset 16}{...}

{col 3}{bf:lags({err:{it:#}})}{col 24}Lag Length Order

{col 3}{opt depvar}{col 24}Dependent Variable

{col 3}{opth var:iables(varlist)}{col 24}Independent Variables in model

{col 3}{opt in:itial(init_val)}{col 24}Parameters (initial) Starting Values

{col 3}{opt fun(expression)}{col 24}RHS Mathematical Expression

{syntab :SE/Robust}
{synopt :{cmd:vce(}{it:{help nl##vcetype:vcetype}}{cmd:)}}{it:vcetype}
    may be {opt gnr}, {opt r:obust}, {opt cl:uster} {it:clustvar},
    {opt boot:strap}, {opt jack:knife}, {opt hac} {it:kernel}, {opt hc2}, or
    {opt hc3} {p_end}

{marker 03}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:lmadurmnl} computes NLS Autocorrelation Dynamic Durbin m Test at Higher Order AR(p).

 	Ho: No Autocorrelation - Ha: Autocorrelation
	- Rho Value for
	- Durbin m Test (drop 1 obs)
	- Durbin m Test (keep 1 obs)

{marker 04}{bf:{err:{dlgtab:Saved Results}}}
{pstd}

{cmd:lmadurmnl} saves the following in {cmd:e()}:

{col 4}{cmd:e(rho#)}{col 20}Rho Value for AR(i)

{col 4}{cmd:e(lmadmd#)}{col 20}Durbin m Test (drop i obs) AR(i)
{col 4}{cmd:e(lmadmdp#)}{col 20}Durbin m Test (drop i obs) AR(i) P-Value

{col 4}{cmd:e(lmadmk#)}{col 20}Durbin m Test (keep i obs) AR(i)
{col 4}{cmd:e(lmadmkp#)}{col 20}Durbin m Test (keep i obs) AR(i) P-Value

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}Durbin, James (1970a)
{cmd: "Testing for Serial Correlation in Least-Squares Regression When Some of the Regressors are Lagged Dependent Variables",}
{it:Econometrica, vol.38, no.3, May}; 410-421.

{p 4 8 2}Durbin, James (1970b)
{cmd: "An Alternative to the Bounds Test for Testing for Serial Correlation in Least Square Regression",}
{it:Econometrica, Vol. 38, No. 2, May}; 422-429.

{p 4 8 2}Kmenta, Jan (1986)
{cmd: "Elements of Econometrics",}
{it: 2nd ed., Macmillan Publishing Company, Inc., New York, USA}; 718.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}.

{p 4 8 2}William E. Griffiths, R. Carter Hill and George G. Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}; 721-725.

{marker 06}{bf:{err:{dlgtab:Examples}}}

{stata clear all}

{stata sysuse lmadurmnl.dta , clear}

{stata gen ly=ln(y)}

{stata "lmadurmnl ly , fun({B0}+{B1}*k+{B2}*l)"}

{stata "lmadurmnl ly, fun({B}-({H}/{R})*ln({D}*l^(-{R})+(1-{D})*k^(-{R}))) in(B 1 H 1 R 1 D 0.5) lag(4)"}
{hline}

. clear all
. sysuse lmadurmnl.dta , clear
. gen ly=ln(y)
. lmadurmnl ly, fun({B}-({H}/{R})*ln({D}*l^(-{R})+(1-{D})*k^(-{R}))) in(B 1 H 1 R 1 D 0 .5) lag(4)

      Source |       SS       df       MS
-------------+------------------------------         Number of obs =        30
       Model |   59.529144     3   19.843048         R-squared     =    0.9713
    Residual |   1.7610762    26    .0677337         Adj R-squared =    0.9680
-------------+------------------------------         Root MSE      =   .260257
       Total |  61.2902202    29  2.11345587         Res. dev.     =  .0781436

------------------------------------------------------------------------------
          ly |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /B |   .1244908   .0783444     1.59   0.124    -.0365483      .28553
          /H |   1.012594   .0506832    19.98   0.000     .9084134    1.116775
          /R |   3.010934   2.323389     1.30   0.206    -1.764861    7.786728
          /D |   .3366735   .1361129     2.47   0.020     .0568895    .6164575
------------------------------------------------------------------------------
  Parameter B taken as constant term in model & ANOVA table

==============================================================================
*** NLS Autocorrelation Dynamic Durbin m Test
==============================================================================
 Ho: No Autocorrelation - Ha: Autocorrelation
------------------------------------------------------------------------------
- Rho Value for Order(1)               AR(1)=  0.0271
- Durbin m Test (drop 1 obs)           AR(1)=  0.0091  P-Value >Chi2(1) 0.9240
- Durbin m Test (keep 1 obs)           AR(1)=  0.0004  P-Value >Chi2(1) 0.9847
------------------------------------------------------------------------------
- Rho Value for Order(2)               AR(2)=  0.0098
- Durbin m Test (drop 2 obs)           AR(2)=  0.2035  P-Value >Chi2(2) 0.9032
- Durbin m Test (keep 2 obs)           AR(2)=  0.0626  P-Value >Chi2(2) 0.9692
------------------------------------------------------------------------------
- Rho Value for Order(3)               AR(3)= -0.0134
- Durbin m Test (drop 3 obs)           AR(3)=  0.1972  P-Value >Chi2(3) 0.9780
- Durbin m Test (keep 3 obs)           AR(3)=  0.1308  P-Value >Chi2(3) 0.9879
------------------------------------------------------------------------------
- Rho Value for Order(4)               AR(4)= -0.3725
- Durbin m Test (drop 4 obs)           AR(4)=  4.8917  P-Value >Chi2(4) 0.2986
- Durbin m Test (keep 4 obs)           AR(4)=  4.8220  P-Value >Chi2(4) 0.3060
------------------------------------------------------------------------------

{marker 07}{bf:{err:{dlgtab:Authors}}}

- {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

- {hi:Sahra Khaleel A. Mickaiel}
  {hi:Professor (PhD Economics)}
  {hi:Cairo University - Faculty of Agriculture - Department of Economics - Egypt}
  {hi:Email: {browse "mailto:sahra_atta@hotmail.com":sahra_atta@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://sahraecon.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/pmi520.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/pmi520.htm"}}

{bf:{err:{dlgtab:LMADURMNL Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2012)}{p_end}
{p 1 10 1}{cmd:LMADURMNL: "NLS Autocorrelation Dynamic Durbin m Test at Higher Order AR(p)"}{p_end}


{title:Online Help:}

{bf:{err:* Autocorrelation Tests:}}

{bf:{err:* (1) (OLS) * Ordinary Least Squares Tests:}}
{helpb lmareg}{col 12}OLS Autocorrelation Tests
{helpb lmabp}{col 12}OLS Autocorrelation Box-Pierce Test
{helpb lmabg}{col 12}OLS Autocorrelation Breusch-Godfrey Test
{helpb lmabpg}{col 12}OLS Autocorrelation Breusch-Pagan-Godfrey Test
{helpb lmadurh}{col 12}OLS Autocorrelation Dynamic Durbin h, Harvey LM, Wald Tests
{helpb lmadurm}{col 12}OLS Autocorrelation Dynamic Durbin m Test
{helpb lmadw}{col 12}OLS Autocorrelation Durbin-Watson Test
{helpb lmalb}{col 12}OLS Autocorrelation Ljung-Box Test
{helpb lmavon}{col 12}OLS Autocorrelation Von Neumann Ratio Test
{helpb lmaz}{col 12}OLS Autocorrelation Z Test
---------------------------------------------------------------------------
{bf:{err:* (2) (NLS) * Non Linear Least Squares Tests:}}
{helpb lmanls}{col 12}Non Linear Least Squares Autocorrelation Tests
{helpb lmabpnl}{col 12}NLS Autocorrelation Box-Pierce Test
{helpb lmabgnl}{col 12}NLS Autocorrelation Breusch-Godfrey Test
{helpb lmabpgnl}{col 12}NLS Autocorrelation Breusch-Pagan-Godfrey Test
{helpb lmadurmnl}{col 12}NLS Autocorrelation Dynamic Durbin m Test
{helpb lmadwnl}{col 12}NLS Autocorrelation Durbin-Watson Test
{helpb lmalbnl}{col 12}NLS Autocorrelation Ljung-Box Test
{helpb lmavonnl}{col 12}NLS Autocorrelation Von Neumann Ratio Test
{helpb lmaznl}{col 12}NLS Autocorrelation Z Test
---------------------------------------------------------------------------
{bf:{err:* (3) (MLE) * Maximum Likelihood Estimation Tests:}}
{helpb lmamle}{col 12}MLE Autocorrelation Tests
{helpb lmabpml}{col 12}MLE Autocorrelation Box-Pierce Test
{helpb lmabgml}{col 12}MLE Autocorrelation Breusch-Godfrey Test
{helpb lmabpgml}{col 12}MLE Autocorrelation Breusch-Pagan-Godfrey Test
{helpb lmadurhml}{col 12}MLE Autocorrelation Dynamic Durbin h, Harvey LM, Wald Tests
{helpb lmadurmml}{col 12}MLE Autocorrelation Dynamic Durbin m Test
{helpb lmadwml}{col 12}MLE Autocorrelation Durbin-Watson Test
{helpb lmalbml}{col 12}MLE Autocorrelation Ljung-Box Test
{helpb lmavonml}{col 12}MLE Autocorrelation Von Neumann Ratio Test
{helpb lmazml}{col 12}MLE Autocorrelation Z Test
---------------------------------------------------------------------------
{bf:{err:* (4) (2SLS-IV) * Two-Stage Least Squares & Instrumental Variables Tests:}}
{helpb lmareg2}{col 12}2SLS-IV Autocorrelation Tests
{helpb lmabg2}{col 12}2SLS-IV Autocorrelation Breusch-Godfrey Test
{helpb lmabp2}{col 12}2SLS-IV Autocorrelation Box-Pierce Test
{helpb lmabpg2}{col 12}2SLS-IV Autocorrelation Breusch-Pagan-Godfrey Test
{helpb lmadurh2}{col 12}2SLS-IV Autocorrelation Dynamic Durbin h, Harvey LM, Wald Tests
{helpb lmadurm2}{col 12}2SLS-IV Autocorrelation Dynamic Durbin m Test
{helpb lmadw2}{col 12}2SLS-IV Autocorrelation Durbin-Watson Test
{helpb lmalb2}{col 12}2SLS-IV Autocorrelation Ljung-Box Test
{helpb lmavon2}{col 12}2SLS-IV Von Neumann Ratio Autocorrelation Test
{helpb lmaz2}{col 12}2SLS-IV Autocorrelation Z Test
---------------------------------------------------------------------------
{bf:{err:* (5) Panel Data Tests:}}
{helpb lmaxt}{col 12}Panel Data Autocorrelation Tests
{helpb lmabxt}{col 12}Panel Data Autocorrelation Baltagi Test
{helpb lmabgxt}{col 12}Panel Data Autocorrelation Breusch-Godfrey Test
{helpb lmabpxt}{col 12}Panel Data Autocorrelation Box-Pierce Test
{helpb lmabpgxt}{col 12}Panel Data Autocorrelation Breusch-Pagan-Godfrey Test
{helpb lmadurhxt}{col 12}Panel Data Autocorrelation Dynamic Durbin h and Harvey LM Tests
{helpb lmadurmxt}{col 12}Panel Data Autocorrelation Dynamic Durbin m Test
{helpb lmadwxt}{col 12}Panel Data Autocorrelation Durbin-Watson Test
{helpb lmavonxt}{col 12}Panel Data Von Neumann Ratio Autocorrelation Test
{helpb lmawxt}{col 12}Panel Data Autocorrelation Wooldridge Test
{helpb lmazxt}{col 12}Panel Data Autocorrelation Z Test
---------------------------------------------------------------------------
{bf:{err:* (6) (3SLS-SUR) * Simultaneous Equations Tests:}}
{helpb lmareg3}{col 12}(3SLS-SUR) Overall System Autocorrelation Tests
{helpb lmhreg3}{col 12}(3SLS-SUR) Overall System Heteroscedasticity Tests
{helpb lmnreg3}{col 12}(3SLS-SUR) Overall System Non Normality Tests
{helpb lmcovreg3}{col 12}(3SLS-SUR) Breusch-Pagan Diagonal Covariance Matrix
{helpb r2reg3}{col 12}(3SLS-SUR) Overall System R2, F-Test, and Chi2-Test
{helpb diagreg3}{col 12}(3SLS-SUR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (7) (SEM-FIML) * Structural Equation Modeling Tests:}}
{helpb lmasem}{col 12}(SEM-FIML) Overall System Autocorrelation Tests
{helpb lmhsem}{col 12}(SEM-FIML) Overall System Heteroscedasticity Tests
{helpb lmnsem}{col 12}(SEM-FIML) Overall System Non Normality Tests
{helpb lmcovsem}{col 12}(SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2sem}{col 12}(SEM-FIML) Overall System R2, F-Test, and Chi2-Test
{helpb diagsem}{col 12}(SEM-FIML) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (8) (NL-SUR) * Non Linear Seemingly Unrelated Regression Tests:}}
{helpb lmanlsur}{col 12}(NL-SUR) Overall System Autocorrelation Tests
{helpb lmhnlsur}{col 12}(NL-SUR) Overall System Heteroscedasticity Tests
{helpb lmnnlsur}{col 12}(NL-SUR) Overall System Non Normality Tests
{helpb lmcovnlsur}{col 12}(NL-SUR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2nlsur}{col 12}(NL-SUR) Overall System R2, F-Test, and Chi2-Test
{helpb diagnlsur}{col 12}(NL-SUR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (9) (VAR) * Vector Autoregressive Model Tests:}}
{helpb lmavar}{col 12}(VAR) Overall System Autocorrelation Tests
{helpb lmhvar}{col 12}(VAR) Overall System Heteroscedasticity Tests
{helpb lmnvar}{col 12}(VAR) Overall System Non Normality Tests
{helpb lmcovvar}{col 12}(VAR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2var}{col 12}(VAR) Overall System R2, F-Test, and Chi2-Test
{helpb diagvar}{col 12}(VAR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------

{psee}
{p_end}


