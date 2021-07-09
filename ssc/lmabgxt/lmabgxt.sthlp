{smcl}
{hline}
{cmd:help: {helpb lmabgxt}}{space 50} {cmd:dialog:} {bf:{dialog lmabgxt}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmabgxt: Panel Data Autocorrelation Breusch-Godfrey Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmabgxt##01:Syntax}{p_end}
{p 5}{helpb lmabgxt##02:Description}{p_end}
{p 5}{helpb lmabgxt##03:Options}{p_end}
{p 5}{helpb lmabgxt##04:Saved Results}{p_end}
{p 5}{helpb lmabgxt##05:References}{p_end}

{p 1}*** {helpb lmabgxt##06:Examples}{p_end}

{p 5}{helpb lmabgxt##07:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt lmabgxt} {depvar} {indepvars} {ifin} {weight} , {bf:{err:id(var)}} {bf:{err:it(var)}} 
{err: [} {opt nocons:tant} {opt coll} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:lmabgxt} computes Panel Data Autocorrelation Breusch-Godfrey Test.

	* Ho: No AR(1) Panel AutoCorrelation - Ha: AR(1) Panel AutoCorrelation
	- Breusch-Godfrey LM Test (drop 1 cs obs)
	- Breusch-Godfrey LM Test (keep 1 cs obs)

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

{p 2 4 2 }{cmd:lmabgxt} saves the following results in {cmd:e()}:

{err:*** Panel Serial Autocorrelation Tests:}
{col 4}{cmd:e(rho)}{col 20}Panel Rho Value
{col 4}{cmd:e(lmabgd)}{col 20}Breusch-Godfrey LM Test (drop 1 cs obs)
{col 4}{cmd:e(lmabgdp)}{col 20}Breusch-Godfrey LM Test (drop 1 cs obs) P-Value
{col 4}{cmd:e(lmabgk)}{col 20}Breusch-Godfrey LM Test (keep 1 cs obs)
{col 4}{cmd:e(lmabgkp)}{col 20}Breusch-Godfrey LM Test (keep 1 cs obs) P-Value

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Breusch, Trevor (1978)
{cmd: "Testing for Autocorrelation in Dynamic Linear Models",}
{it:Aust. Econ. Papers, Vol. 17}; 334-355.

{p 4 8 2}Breusch, Trevor & Adrian Pagan (1980)
{cmd: "The Lagrange Multiplier Test and its Applications to Model Specification in Econometrics",}
{it:Review of Economic Studies 47}; 239-253.

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}Godfrey, L. (1978)
{cmd: "Testing for Higher Order Serial Correlation in Regression Equations when the Regressors Include Lagged Dependent Variables",}
{it:Econometrica, Vol., 46}; 1303-1310.

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA}; 616-618.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Upper Saddle River, NJ: Prentice-Hall}; 387-388.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 615.

{p 4 8 2}Kmenta, Jan (1986)
{cmd: "Elements of Econometrics",}
{it: 2nd ed., Macmillan Publishing Company, Inc., New York, USA}; 718.

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Examples}}}

  {stata clear all}

  {stata sysuse lmabgxt.dta, clear}

  {stata db lmabgxt}

  {stata lmabgxt y x1 x2 , id(id) it(t)}

. clear all
. sysuse lmabgxt.dta, clear
. lmabgxt y x1 x2 , id(id) it(t)

==============================================================================
* Ordinary Least Squares (OLS) Regression
==============================================================================
  y = x1 + x2
------------------------------------------------------------------------------
 Sample Size        =          49   |   Cross Sections Number   =           7
 Wald Test          =     58.0055   |   P-Value > Chi2(2)       =      0.0000
 F-Test             =     29.0028   |   P-Value > F(2 , 47)     =      0.0000
 (Buse 1973) R2     =      0.5524   |   Raw Moments R2          =      0.9186
 (Buse 1973) R2 Adj =      0.5429   |   Raw Moments R2 Adj      =      0.9169
 Root MSE (Sigma)   =     11.3127   |   Log Likelihood Function =   -187.3772
------------------------------------------------------------------------------
- R2h= 0.5524   R2h Adj= 0.5429  F-Test =   28.39 P-Value > F(2 , 47)  0.0000
- R2v= 0.5524   R2v Adj= 0.5429  F-Test =   28.39 P-Value > F(2 , 47)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |  -.2739317   .1020949    -2.68   0.010    -.4793201   -.0685434
          x2 |  -1.597311   .3305569    -4.83   0.000    -2.262305    -.932316
       _cons |   68.61898   4.684835    14.65   0.000      59.1943    78.04365
------------------------------------------------------------------------------

==============================================================================
*** Panel Data Autocorrelation Breusch-Godfrey Test
==============================================================================
  Ho: No AR(1) Panel AutoCorrelation - Ha: AR(1) Panel AutoCorrelation

- Panel Rho Value                         =   0.4233
- Breusch-Godfrey LM Test (drop 1 cs obs) =   8.9242  P-Value > Chi2(1) 0.0028
- Breusch-Godfrey LM Test (keep 1 cs obs) =   9.8257  P-Value > Chi2(1) 0.0017
------------------------------------------------------------------------------

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:Authors}}}

- {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

- {hi:Sahra Khaleel A. Mickaiel}
  {hi:Professor (PhD Economics)}
  {hi:Cairo University - Faculty of Agriculture - Department of Economics - Egypt}
  {hi:Email: {browse "mailto:sahra_atta@hotmail.com":sahra_atta@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/pmi520.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/pmi520.htm"}}

{bf:{err:{dlgtab:LMABGXT Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2015)}{p_end}
{p 1 10 1}{cmd:LMABGXT: "Stata Module to Compute Panel Data Autocorrelation Breusch-Godfrey Test"}{p_end}


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


