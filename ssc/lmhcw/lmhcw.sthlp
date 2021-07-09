{smcl}
{hline}
{cmd:help: {helpb lmhcw}}{space 50} {cmd:dialog:} {bf:{dialog lmhcw}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmhcw: OLS Heteroscedasticity Cook-Weisberg Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmhcw##01:Syntax}{p_end}
{p 5}{helpb lmhcw##02:Description}{p_end}
{p 5}{helpb lmhcw##03:Options}{p_end}
{p 5}{helpb lmhcw##04:Heteroscedasticity Tests}{p_end}
{p 5}{helpb lmhcw##05:Saved Results}{p_end}
{p 5}{helpb lmhcw##06:References}{p_end}

{p 1}*** {helpb lmhcw##07:Examples}{p_end}

{p 5}{helpb lmhcw##08:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{cmd:lmhcw} {depvar} {it:{help varlist:indepvars}} {ifin} , {err: [} {opt nocons:tant} {opt coll} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:lmhcw} computes OLS Heteroscedasticity Cook-Weisberg Test

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

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Heteroscedasticity Tests}}}

 	Ho: Homoscedasticity - Ha: Heteroscedasticity
	- Cook-Weisberg LM Test  E2/Sig2 = Yh
	- Cook-Weisberg LM Test  E2/Sig2 = X
	*** Single Variable Tests:
	- Cook-Weisberg LM Test: E2/Sig2 = xi
	*** Single Variable Tests:
	- King LM Test: xi

{marker 05}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmhcw} saves the following in {cmd:e()}:

{err:*** Heteroscedasticity Tests:}
{col 4}{cmd:e(lmhcw1)}{col 20}Cook-Weisberg LM Test E2/Sig2n = Yh 
{col 4}{cmd:e(lmhcw1p)}{col 20}Cook-Weisberg LM Test E2/Sig2n = Yh P-Value
{col 4}{cmd:e(lmhcw2)}{col 20}Cook-Weisberg LM Test E2/Sig2n = X
{col 4}{cmd:e(lmhcw2p)}{col 20}Cook-Weisberg LM Test E2/Sig2n = X P-Value
{col 4}{cmd:e(lmhcw_xi)}{col 20}Cook-Weisberg LM Single Variable Test
{col 4}{cmd:e(lmhcwp_xi)}{col 20}Cook-Weisberg LM Single Variable Test P-Value
{col 4}{cmd:e(lmhq_xi)}{col 20}King LM Single Variable Test
{col 4}{cmd:e(lmhqp_xi)}{col 20}King LM Single Variable Test P-Value

{marker 06}{bf:{err:{dlgtab:References}}}

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

{marker 07}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}
 {stata sysuse lmhcw.dta , clear}

 {stata db lmhcw}

 {stata lmhcw y x1 x2}
{hline}

. clear all
. sysuse lmhcw.dta , clear
. lmhcw y x1 x2

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
*** OLS Heteroscedasticity Cook-Weisberg Test
==============================================================================
 Ho: Homoscedasticity - Ha: Heteroscedasticity
------------------------------------------------------------------------------
- Cook-Weisberg LM Test  E2/Sig2 = Yh  =   1.2875    P-Value > Chi2(1)  0.2565
- Cook-Weisberg LM Test  E2/Sig2 = X   =   2.5288    P-Value > Chi2(2)  0.2824
------------------------------------------------------------------------------
*** Single Variable Tests:
- Cook-Weisberg LM Test: E2/Sig2 = x1  =   1.0817    P-Value > Chi2(1)  0.2983
- Cook-Weisberg LM Test: E2/Sig2 = x2  =   1.8757    P-Value > Chi2(1)  0.1708
------------------------------------------------------------------------------
*** Single Variable Tests:
- King LM Test: x1                     =   1.3297    P-Value > Chi2(1)  0.2489
- King LM Test: x2                     =   1.6724    P-Value > Chi2(1)  0.1959
------------------------------------------------------------------------------

{marker 08}{bf:{err:{dlgtab:Authors}}}

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

{bf:{err:{dlgtab:LMHCW Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2014)}{p_end}
{p 1 10 1}{cmd:LMHCW: "Stata Module to Compute OLS Heteroscedasticity Cook-Weisberg Test"}{p_end}


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


