{smcl}
{hline}
{cmd:help: {helpb lmnwhitenl}}{space 50} {cmd:dialog:} {bf:{dialog lmnwhitenl}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmnwhitenl: NLS Non Normality White Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmnwhitenl##01:Syntax}{p_end}
{p 5}{helpb lmnwhitenl##02:Options}{p_end}
{p 5}{helpb lmnwhitenl##03:Description}{p_end}
{p 5}{helpb lmnwhitenl##04:Saved Results}{p_end}
{p 5}{helpb lmnwhitenl##05:References}{p_end}

{p 1}*** {helpb lmnwhitenl##06:Examples}{p_end}

{p 5}{helpb lmnwhitenl##07:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 3 5 6}
{cmd:lmnwhitenl} {depvar} {ifin} {weight} , {opt fun(expression)}{p_end} 
{p 5 5 6}
{err: [} {opt in:itial(init_val)} {opth var:iables(varlist)} {cmd:vce(}{it:{help nl##vcetype:vcetype}} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Options}}}
{synoptset 16}{...}

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
{cmd:lmnwhitenl} computes Non Linear Least Squares Non Normality White Test.

 	Ho: Normality - Ha: Non Normality
	- White IM Test

{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmnwhitenl} saves the following in {cmd:e()}:

{col 4}{cmd:e(lmnw)}{col 20}White IM Test
{col 4}{cmd:e(lmnwp)}{col 20}White IM Test P-Value

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}William E. Griffiths, R. Carter Hill and George G. Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}; 721-725.

{marker 06}{bf:{err:{dlgtab:Examples}}}

{stata clear all}

{stata sysuse lmnwhitenl.dta , clear}

{stata gen ly=ln(y)}

{stata "lmnwhitenl ly , fun({B0}+{B1}*k+{B2}*l)"}

{stata "lmnwhitenl ly, fun({B}-({H}/{R})*ln({D}*l^(-{R})+(1-{D})*k^(-{R}))) in(B 1 H 1 R 1 D 0.5)"}
{hline}

. clear all
. sysuse lmnwhitenl.dta , clear
. gen ly=ln(y)
. lmnwhitenl ly, fun({B}-({H}/{R})*ln({D}*l^(-{R})+(1-{D})*k^(-{R}))) in(B 1 H 1 R 1 D 0.5)

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
*** NLS Non Normality White Test
==============================================================================
 Ho: Normality - Ha: Non Normality
------------------------------------------------------------------------------
*** Non Normality Tests:
- White IM Test                        =   2.0403     P-Value > Chi2(2) 0.3605
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

{bf:{err:{dlgtab:LMNWHITENL Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2012)}{p_end}
{p 1 10 1}{cmd:LMNWHITENL: "NLS Non Normality White Test"}{p_end}


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


