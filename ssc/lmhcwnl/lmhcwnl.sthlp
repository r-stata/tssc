{smcl}
{hline}
{cmd:help: {helpb lmhcwnl}}{space 50} {cmd:dialog:} {bf:{dialog lmhcwnl}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmhcwnl: NLS Heteroscedasticity Cook-Weisberg Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmhcwnl##01:Syntax}{p_end}
{p 5}{helpb lmhcwnl##02:Options}{p_end}
{p 5}{helpb lmhcwnl##03:Description}{p_end}
{p 5}{helpb lmhcwnl##04:Saved Results}{p_end}
{p 5}{helpb lmhcwnl##05:References}{p_end}

{p 1}*** {helpb lmhcwnl##06:Examples}{p_end}

{p 5}{helpb lmhcwnl##07:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 3 5 6}
{cmd:lmadwnl} {depvar} {ifin} {weight} , {opt fun(expression)}{p_end} 
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
{cmd:lmhcwnl} computes Non Linear Least Squares Heteroscedasticity Cook-Weisberg and King Tests.

 	Ho: Homoscedasticity - Ha: Heteroscedasticity
	- Cook-Weisberg LM Test  E2/Sig2 = Yh
	- Cook-Weisberg LM Test  E2/Sig2 = X

	*** Single Variable Tests:
	- Cook-Weisberg LM Test: E2/Sig2 = xi

	*** Single Variable Tests:
	- King LM Test: xi

{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmhcwnl} saves the following in {cmd:e()}:

{col 4}{cmd:e(lmhcw1)}{col 20}Cook-Weisberg LM Test E2/Sig2n = Yh 
{col 4}{cmd:e(lmhcw1p)}{col 20}Cook-Weisberg LM Test E2/Sig2n = Yh P-Value
{col 4}{cmd:e(lmhcw2)}{col 20}Cook-Weisberg LM Test E2/Sig2n = X
{col 4}{cmd:e(lmhcw2p)}{col 20}Cook-Weisberg LM Test E2/Sig2n = X P-Value

{col 4}{cmd:e(lmhcw_xi)}{col 20}Cook-Weisberg LM Single Variable Test
{col 4}{cmd:e(lmhcwp_xi)}{col 20}Cook-Weisberg LM Single Variable Test P-Value

{col 4}{cmd:e(lmhq_xi)}{col 20}King LM Single Variable Test
{col 4}{cmd:e(lmhqp_xi)}{col 20}King LM Single Variable Test P-Value

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Cook, R.D., & S. Weisberg (1983)
{cmd: "Diagnostics for Heteroscedasticity in Regression",}
{it:Biometrica 70}; 1-10.

{p 4 8 2}Harvey, Andrew (1990)
{cmd: "The Econometric Analysis of Time Series",}
{it:2nd edition, MIT Press, Cambridge, Massachusetts}.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}.

{p 4 8 2}Szroeter, J. (1978)
{cmd: "A Class of Parametric Tests for Heteroscedasticity in Linear Econometric Models",}
{it:Econometrica, 46}; 1311-28.

{p 4 8 2}William E. Griffiths, R. Carter Hill and George G. Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}; 721-725.

{marker 06}{bf:{err:{dlgtab:Examples}}}

{stata clear all}

{stata sysuse lmhcwnl.dta , clear}

{stata gen ly=ln(y)}

{stata "lmhcwnl ly , fun({B0}+{B1}*k+{B2}*l)"}

{stata "lmhcwnl ly, fun({B}-({H}/{R})*ln({D}*l^(-{R})+(1-{D})*k^(-{R}))) in(B 1 H 1 R 1 D 0.5)"}
{hline}

. clear all
. sysuse lmhcwnl.dta , clear
. gen ly=ln(y)
. lmhcwnl ly, fun({B}-({H}/{R})*ln({D}*l^(-{R})+(1-{D})*k^(-{R}))) in(B 1 H 1 R 1 D 0.5)

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
*** NLS Heteroscedasticity Cook-Weisberg Test
==============================================================================
 Ho: Homoscedasticity - Ha: Heteroscedasticity
------------------------------------------------------------------------------
- Cook-Weisberg LM Test  E2/Sig2 = Yh  =   0.7331    P-Value > Chi2(1)  0.3919
- Cook-Weisberg LM Test  E2/Sig2 = X   =   3.3748    P-Value > Chi2(4)  0.4972
------------------------------------------------------------------------------
*** Single Variable Tests:
- Cook-Weisberg LM Test: E2/Sig2 = B   =   1.3959    P-Value > Chi2(1)  0.2374
- Cook-Weisberg LM Test: E2/Sig2 = H   =   0.7331    P-Value > Chi2(1)  0.3919
- Cook-Weisberg LM Test: E2/Sig2 = R   =   1.3267    P-Value > Chi2(1)  0.2494
- Cook-Weisberg LM Test: E2/Sig2 = D   =   0.5681    P-Value > Chi2(1)  0.4510
------------------------------------------------------------------------------
*** Single Variable Tests:
- King LM Test: B                      =   3.2524    P-Value > Chi2(1)  0.0713
- King LM Test: H                      =   0.4416    P-Value > Chi2(1)  0.5063
- King LM Test: R                      =   1.6471    P-Value > Chi2(1)  0.1994
- King LM Test: D                      =   0.2638    P-Value > Chi2(1)  0.6075
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

{bf:{err:{dlgtab:LMHCWNL Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2012)}{p_end}
{p 1 10 1}{cmd:LMHCWNL: "NLS Heteroscedasticity Cook-Weisberg Test"}


{title:Online Help:}

{bf:{err:* Heteroscedasticity Tests:}}

{bf:{err:* (1) (OLS) * Ordinary Least Squares Tests:}}
{helpb lmhreg}{col 12}OLS Heteroscedasticity Tests
{helpb lmharch}{col 12}OLS Heteroscedasticity Engle (ARCH) Test
{helpb lmhcw}{col 12}OLS Heteroscedasticity Cook-Weisberg Test
{helpb lmhgl}{col 12}OLS Heteroscedasticity Glejser Test
{helpb lmhharv}{col 12}OLS Heteroscedasticity Harvey Test
{helpb lmhhp}{col 12}OLS Heteroscedasticity Hall-Pagan Test
{helpb lmhmss}{col 12}OLS Heteroscedasticity Machado-Santos-Silva Test
{helpb lmhwald}{col 12}OLS Heteroscedasticity Wald Test
{helpb lmhwhite}{col 12}OLS Heteroscedasticity White Test
---------------------------------------------------------------------------
{bf:{err:* (2) (NLS) * Non Linear Least Squares Tests:}}
{helpb lmhnls}{col 12}Non Linear Least Squares Heteroscedasticity Tests
{helpb lmharchnl}{col 12}NLS Heteroscedasticity Engle (ARCH) Test
{helpb lmhcwnl}{col 12}NLS Heteroscedasticity Cook-Weisberg Test
{helpb lmhglnl}{col 12}NLS Heteroscedasticity Glejser Test
{helpb lmhharvnl}{col 12}NLS Heteroscedasticity Harvey Test
{helpb lmhhpnl}{col 12}NLS Heteroscedasticity Hall-Pagan Test
{helpb lmhmssnl}{col 12}NLS Heteroscedasticity Machado-Santos-Silva Test
{helpb lmhwaldnl}{col 12}NLS Heteroscedasticity Wald Test
{helpb lmhwhitenl}{col 12}NLS Heteroscedasticity White Test
---------------------------------------------------------------------------
{bf:{err:* (3) (MLE) * Maximum Likelihood Estimation Tests:}}
{helpb lmhmle}{col 12}MLE Heteroscedasticity Tests
{helpb lmharchml}{col 12}MLE Heteroscedasticity Engle (ARCH) Test
{helpb lmhcwml}{col 12}MLE Heteroscedasticity Cook-Weisberg Test
{helpb lmhglml}{col 12}MLE Heteroscedasticity Glejser Test
{helpb lmhharvml}{col 12}MLE Heteroscedasticity Harvey Test
{helpb lmhhpml}{col 12}MLE Heteroscedasticity Hall-Pagan Test
{helpb lmhmssml}{col 12}MLE Heteroscedasticity Machado-Santos-Silva Test
{helpb lmhwaldml}{col 12}MLE Heteroscedasticity Wald Test
{helpb lmhwhiteml}{col 12}MLE Heteroscedasticity White Test
---------------------------------------------------------------------------
{bf:{err:* (4) (2SLS-IV) * Two-Stage Least Squares & Instrumental Variables Tests:}}
{helpb lmhreg2}{col 12}2SLS-IV Heteroscedasticity Tests
{helpb lmharch2}{col 12}2SLS-IV Heteroscedasticity Engle (ARCH) Test
{helpb lmhcw2}{col 12}2SLS-IV Heteroscedasticity Cook-Weisberg Test
{helpb lmhgl2}{col 12}2SLS-IV Heteroscedasticity Glejser Test
{helpb lmhharv2}{col 12}2SLS-IV Heteroscedasticity Harvey Test
{helpb lmhhp2}{col 12}2SLS-IV Heteroscedasticity Hall-Pagan Test
{helpb lmhmss2}{col 12}2SLS-IV Heteroscedasticity Machado-Santos-Silva Test
{helpb lmhwald2}{col 12}2SLS-IV Heteroscedasticity Wald Test
{helpb lmhwhite2}{col 12}2SLS-IV Heteroscedasticity White Test
---------------------------------------------------------------------------
{bf:{err:* (5) Panel Data Tests:}}
{helpb lmhxt}{col 12}Panel Data Heteroscedasticity Tests
{helpb lmhgwxt}{col 12}Panel Data Groupwise Heteroscedasticity Tests
{helpb ghxt}{col 12}Panel Groupwise Heteroscedasticity Tests
{helpb lmhlmxt}{col 12}Panel Data Groupwise Heteroscedasticity Breusch-Pagan LM Test
{helpb lmhlrxt}{col 12}Panel Data Groupwise Heteroscedasticity Greene LR Test
{helpb lmharchxt}{col 12}Panel Data Heteroscedasticity Engle (ARCH) Test
{helpb lmhcwxt}{col 12}Panel Data Heteroscedasticity Cook-Weisberg Test
{helpb lmhglxt}{col 12}Panel Data Heteroscedasticity Glejser Test
{helpb lmhharvxt}{col 12}Panel Data Heteroscedasticity Harvey Test
{helpb lmhhpxt}{col 12}Panel Data Heteroscedasticity Hall-Pagan Test
{helpb lmhmssxt}{col 12}Panel Data Heteroscedasticity Machado-Santos-Silva Test
{helpb lmhwaldxt}{col 12}Panel Data Heteroscedasticity Wald Test
{helpb lmhwhitext}{col 12}Panel Data Heteroscedasticity White Test
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


