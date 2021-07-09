{smcl}
{hline}
{cmd:help: {helpb lmnad}}{space 50} {cmd:dialog:} {bf:{dialog lmnad}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmnad: OLS Non Normality Anderson-Darling Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmnad##01:Syntax}{p_end}
{p 5}{helpb lmnad##02:Description}{p_end}
{p 5}{helpb lmnad##03:Options}{p_end}
{p 5}{helpb lmnad##04:Saved Results}{p_end}
{p 5}{helpb lmnad##05:References}{p_end}

{p 1}*** {helpb lmnad##06:Examples}{p_end}

{p 5}{helpb lmnad##07:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{cmd:lmnad} {depvar} {it:{help varlist:indepvars}} {ifin} , {err: [} {opt nocons:tant} {opt coll} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:lmnad} computes OLS Non Normality Anderson-Darling Test

 	Ho: Normality - Ha: Non Normality
	- Anderson-Darling Z Test

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{marker 03}{bf:{err:{dlgtab:Options}}}
{synoptset 16}{...}

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmnad} saves the following in {cmd:e()}:

{col 4}{cmd:e(lmnad)}{col 20}Anderson-Darling Z Test
{col 4}{cmd:e(lmnadp)}{col 20}Anderson-Darling Z Test P-Value

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Anderson T.W., Darling D.A. (1954)
{cmd: "A Test of Goodness of Fit",}
{it:Journal of the American Statisical Association, 49}; 765–69. 

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{marker 06}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse lmnad.dta , clear}

 {stata db lmnad}

 {stata lmnad y x1 x2}
{hline}

. clear all
. sysuse lmnad.dta , clear
. lmnad y x1 x2


==============================================================================
* Ordinary Least Squares (OLS)
==============================================================================
  y = x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          17
  Wald Test         =    273.3662   |   P-Value > Chi2(2)       =      0.0000
  F-Test            =    136.6831   |   P-Value > F(2 , 14)     =      0.0000
 (Buse 1973) R2     =      0.9513   |   Raw Moments R2          =      0.9986
 (Buse 1973) R2 Adj =      0.9443   |   Raw Moments R2 Adj      =      0.9984
  Root MSE (Sigma)  =      5.5634   |   Log Likelihood Function =    -51.6471
------------------------------------------------------------------------------
- R2h= 0.9513   R2h Adj= 0.9443  F-Test =  136.68 P-Value > F(2 , 14)  0.0000
- R2v= 0.9513   R2v Adj= 0.9443  F-Test =  136.68 P-Value > F(2 , 14)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   1.061709   .2666739     3.98   0.001     .4897506    1.633668
          x2 |  -1.382986   .0838143   -16.50   0.000    -1.562749   -1.203222
       _cons |   130.7066   27.09429     4.82   0.000     72.59515    188.8181
------------------------------------------------------------------------------

==============================================================================
*** OLS Non Normality Anderson-Darling Test
==============================================================================
 Ho: Normality - Ha: Non Normality
------------------------------------------------------------------------------
- Anderson-Darling Z Test              =   0.1989     P > Z( 1.272)     0.8983
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

{bf:{err:{dlgtab:LMNAD Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2014)}{p_end}
{p 1 10 1}{cmd:LMNAD: "Stata Module to Compute OLS Non Normality Anderson-Darling Test"}{p_end}


{title:Online Help:}

{bf:{err:* Non Normality Tests:}}

{bf:{err:* (1) (OLS) * Ordinary Least Squares Tests:}}
{helpb lmnreg}{col 12}OLS Non Normality Tests
{helpb lmnad}{col 12}OLS Non Normality Anderson-Darling Test
{helpb lmndh}{col 12}OLS Non Normality Doornik-Hansen Test
{helpb lmndp}{col 12}OLS Non Normality D'Agostino-Pearson Test
{helpb lmngry}{col 12}OLS Non Normality Geary Runs Test
{helpb lmnjb}{col 12}OLS Non Normality Jarque-Bera Test
{helpb lmnwhite}{col 12}OLS Non Normality White Test
---------------------------------------------------------------------------
{bf:{err:* (2) (NLS) * Non Linear Least Squares Tests:}}
{helpb lmnnls}{col 12}NLS Non Normality Tests
{helpb lmnadnl}{col 12}NLS Non Normality Anderson-Darling Test
{helpb lmndhnl}{col 12}NLS Non Normality Doornik-Hansen Test
{helpb lmndpnl}{col 12}NLS Non Normality D'Agostino-Pearson Test
{helpb lmngrynl}{col 12}NLS Non Normality Geary Runs Test
{helpb lmnjbnl}{col 12}NLS Non Normality Jarque-Bera Test
{helpb lmnwhitenl}{col 12}NLS Non Normality White Test
---------------------------------------------------------------------------
{bf:{err:* (3) (MLE) * Maximum Likelihood Estimation Tests:}}
{helpb lmnmle}{col 12}MLE Non Normality Tests
{helpb lmnadml}{col 12}MLE Non Normality Anderson-Darling Test
{helpb lmndhml}{col 12}MLE Non Normality Doornik-Hansen Test
{helpb lmndpml}{col 12}MLE Non Normality D'Agostino-Pearson Test
{helpb lmngryml}{col 12}MLE Non Normality Geary Runs Test
{helpb lmnjbml}{col 12}MLE Non Normality Jarque-Bera Test
{helpb lmnwhiteml}{col 12}MLE Non Normality White Test
---------------------------------------------------------------------------
{bf:{err:* (4) (2SLS-IV) * Two-Stage Least Squares & Instrumental Variables Tests:}}
{helpb lmnreg2}{col 12}2SLS-IV Non Normality Tests
{helpb lmnad2}{col 12}2SLS-IV Non Normality Anderson-Darling Test
{helpb lmndh2}{col 12}2SLS-IV Non Normality Doornik-Hansen Test
{helpb lmndp2}{col 12}2SLS-IV Non Normality D'Agostino-Pearson Test
{helpb lmngry2}{col 12}2SLS-IV Non Normality Geary Runs Test
{helpb lmnjb2}{col 12}2SLS-IV Jarque-Bera LM Non Normality Test
{helpb lmnwhite2}{col 12}2SLS-IV White IM Non Normality Test
---------------------------------------------------------------------------
{bf:{err:* (5) Panel Data Tests:}}
{helpb lmnxt}{col 12}Panel Data Non Normality Tests
{helpb lmnadxt}{col 12}Panel Data Non Normality Anderson-Darling Test
{helpb lmndhxt}{col 12}Panel Data Non Normality Doornik-Hansen Test
{helpb lmndpxt}{col 12}Panel Data Non Normality D'Agostino-Pearson Test
{helpb lmngryxt}{col 12}Panel Data Non Normality Geary Runs Test
{helpb lmnjbxt}{col 12}Panel Data Non Normality Jarque-Bera Test
{helpb lmnwhitext}{col 12}Panel Data Non Normality White Test
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


