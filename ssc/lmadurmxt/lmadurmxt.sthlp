{smcl}
{hline}
{cmd:help: {helpb lmadurmxt}}{space 50} {cmd:dialog:} {bf:{dialog lmadurmxt}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmadurmxt: Panel Data Autocorrelation Dynamic Durbin m Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmadurmxt##01:Syntax}{p_end}
{p 5}{helpb lmadurmxt##02:Description}{p_end}
{p 5}{helpb lmadurmxt##03:Options}{p_end}
{p 5}{helpb lmadurmxt##04:Saved Results}{p_end}
{p 5}{helpb lmadurmxt##05:References}{p_end}

{p 1}*** {helpb lmadurmxt##06:Examples}{p_end}

{p 5}{helpb lmadurmxt##07:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt lmadurmxt} {depvar} {indepvars} {ifin} {weight} , {bf:{err:id(var)}} {bf:{err:it(var)}} {err: [} {opt nocons:tant} {opt coll} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:lmadurmxt} computes Panel Data Autocorrelation Dynamic Durbin m Test.

	* Ho: No AR(1) Panel AutoCorrelation - Ha: AR(1) Panel AutoCorrelation
	- Durbin  m Panel Test (Lag DepVar)

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Options}}}

{col 3}* {cmd: {opt id(var)}{col 20}Cross Sections ID variable name}
{col 3}* {cmd: {opt it(var)}{col 20}Time Series ID variable name}

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:lmadurmxt} saves the following results in {cmd:e()}:

{col 4}{cmd:e(rho)}{col 20}Panel Rho Value
{col 4}{cmd:e(lmadmd)}{col 20}Durbin m Panel Test (drop 1 cs obs)
{col 4}{cmd:e(lmadmdp)}{col 20}Durbin m Panel Test (drop 1 cs obs) P-Value
{col 4}{cmd:e(lmadmk)}{col 20}Durbin m Panel Test (keep 1 cs obs)
{col 4}{cmd:e(lmadmkp)}{col 20}Durbin m Panel Test (keep 1 cs obs) P-Value

{p2colreset}{...}
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

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Examples}}}

  {stata clear all}

  {stata sysuse lmadurmxt.dta, clear}

  {stata db lmadurmxt}

  {stata lmadurmxt y y1 x1 x2 , id(id) it(t)}

. clear all
. sysuse lmadurmxt.dta, clear
. lmadurmxt y y1 x1 x2 , id(id) it(t)

==============================================================================
* Ordinary Least Squares (OLS) Regression
==============================================================================
  y = y1 + x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          49   |   Cross Sections Number   =           7
  Wald Test         =    107.1056   |   P-Value > Chi2(3)       =      0.0000
  F-Test            =     35.7019   |   P-Value > F(3 , 46)     =      0.0000
 (Buse 1973) R2     =      0.6996   |   Raw Moments R2          =      0.9454
 (Buse 1973) R2 Adj =      0.6865   |   Raw Moments R2 Adj      =      0.9430
  Root MSE (Sigma)  =      9.3686   |   Log Likelihood Function =   -177.6110
------------------------------------------------------------------------------
- R2h= 0.6996   R2h Adj= 0.6865  F-Test =   34.93 P-Value > F(3 , 46)  0.0000
- R2v= 0.6996   R2v Adj= 0.6865  F-Test =   34.93 P-Value > F(3 , 46)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          y1 |   .4571583   .0963145     4.75   0.000     .2632873    .6510294
          x1 |  -.2783915   .0845554    -3.29   0.002    -.4485926   -.1081903
          x2 |  -.8975503   .3109251    -2.89   0.006     -1.52341   -.2716905
       _cons |   42.84119   6.674359     6.42   0.000      29.4064    56.27598
------------------------------------------------------------------------------

==============================================================================
*** Panel Data Autocorrelation Dynamic Durbin m Test
==============================================================================
  Ho: No AR(1) Panel AutoCorrelation - Ha: AR(1) Panel AutoCorrelation

- Panel Rho Value                         =   0.0293
------------------------------------------------------------------------------
- Durbin m Test (drop 1 cs obs)           =   0.0571  P-Value > F(1,37) 0.8124
- Durbin m Test (keep 1 cs obs)           =   0.0580  P-Value > F(1,44) 0.8108
------------------------------------------------------------------------------

{p2colreset}{...}
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

{bf:{err:{dlgtab:LMADURMXT Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2013)}{p_end}
{p 1 10 1}{cmd:LMADURMXT: "Panel Data Autocorrelation Dynamic Durbin m Test"}{p_end}


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


