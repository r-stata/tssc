{smcl}
{hline}
{cmd:help: {helpb lmngry2}}{space 50} {cmd:dialog:} {bf:{dialog lmngry2}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmngry2: 2SLS-IV Non Normality Geary Runs Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmngry2##01:Syntax}{p_end}
{p 5}{helpb lmngry2##02:Description}{p_end}
{p 5}{helpb lmngry2##03:Model}{p_end}
{p 5}{helpb lmngry2##04:GMM Options}{p_end}
{p 5}{helpb lmngry2##05:Other Options}{p_end}
{p 5}{helpb lmngry2##06:Saved Results}{p_end}
{p 5}{helpb lmngry2##07:References}{p_end}

{p 1}*** {helpb lmngry2##08:Examples}{p_end}

{p 5}{helpb lmngry2##09:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 2 4 2} 
{cmd:lmngry2} {depvar} {it:{help varlist:indepvars}} {cmd:({it:{help varlist:endog}} = {it:{help varlist:inst}})} {ifin} , {p_end} 
{p 6 6 2}
{opt model(2sls, liml, gmm, melo, fuller, kclass)}{p_end} 
{p 6 6 2}
{err: [} {opt kc(#)} {opt kf(#)} {opt hetcov(type)} {opt nocons:tant} {opt noconexog} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:lmngry2} computes 2SLS-IV Non Normality Geary Runs Test for instrumental variables regression models, via 2sls, liml, melo, gmm, and kclass.{p_end}

 	Ho: Normality - Ha: Non Normality
	- Geary LM Test
	- Runs Test

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{marker 03}{bf:{err:{dlgtab:Model}}}

{synoptset 16}{...}
{p2coldent:{it:model}}description{p_end}
{synopt:{opt 2sls}}Two-Stage Least Squares (2SLS){p_end}
{synopt:{opt liml}}Limited-Information Maximum Likelihood (LIML){p_end}
{synopt:{opt melo}}Minimum Expected Loss (MELO){p_end}
{synopt:{opt fuller}}Fuller k-Class LIML{p_end}
{synopt:{opt kclass}}Theil K-Class LIML{p_end}
{synopt:{opt gmm}}Generalized Method of Moments (GMM){p_end}

{marker 04}{bf:{err:{dlgtab:GMM Options}}}

{synoptset 16}{...}
{p2coldent:{it:hetcov Options}}Description{p_end}

{synopt:{bf:hetcov({err:{it:white}})}}White Method{p_end}
{synopt:{bf:hetcov({err:{it:bart}})}}Bartlett Method{p_end}
{synopt:{bf:hetcov({err:{it:dan}})}}Daniell Method{p_end}
{synopt:{bf:hetcov({err:{it:nwest}})}}Newey-West Method{p_end}
{synopt:{bf:hetcov({err:{it:parzen}})}}Parzen Method{p_end}
{synopt:{bf:hetcov({err:{it:quad}})}}Quadratic spectral Method{p_end}
{synopt:{bf:hetcov({err:{it:tent}})}}Tent Method{p_end}
{synopt:{bf:hetcov({err:{it:trunc}})}}Truncated Method{p_end}
{synopt:{bf:hetcov({err:{it:tukeym}})}}Tukey-Hamming Method{p_end}
{synopt:{bf:hetcov({err:{it:tukeyn}})}}Tukey-Hanning Method{p_end}

{marker 05}{bf:{err:{dlgtab:Other Options}}}

{synoptset 16}{...}
{synopt:{bf:kf({err:{it:#}})}}Fuller k-Class LIML Value{p_end}

{synopt:{bf:kc({err:{it:#}})}}Theil k-Class LIML Value{p_end}

{synopt:{opt nocons:tant}}Exclude Constant Term from RHS Equation only{p_end}

{synopt:{bf:noconexog}}Exclude Constant Term from all Equations (both RHS and Instrumental Equations). Results of using {cmd:noconexog} option are identical to Stata {helpb ivregress}.
 The default of {cmd:lmngry2} is including Constant Term in both RHS and Instrumental Equations{p_end}

{marker 06}{bf:{err:{dlgtab:Saved Results}}}

{cmd:lmngry2} saves the following in {cmd:e()}:

{col 4}{cmd:e(lmng)}{col 20}Geary LM Test
{col 4}{cmd:e(lmngp)}{col 20}Geary LM Test P-Value
{col 4}{cmd:e(sk)}{col 20}Skewness Coefficient
{col 4}{cmd:e(sksd)}{col 20}Skewness Standard Deviation
{col 4}{cmd:e(ku)}{col 20}Kurtosis Coefficient
{col 4}{cmd:e(kusd)}{col 20}Kurtosis Standard Deviation
{col 4}{cmd:e(en)}{col 20}Mean Runs E(k)
{col 4}{cmd:e(sn)}{col 20}Standard Deviation Runs Sig(k)
{col 4}{cmd:e(lower)}{col 20}95% Lower Conf. Interval
{col 4}{cmd:e(upper)}{col 20}95% Upper Conf. Interval

{marker 07}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}; 419-420.

{p 4 8 2}Geary R.C. (1947) {cmd: "Testing for Normality"} {it:Biometrika, Vol. 34}; 209-242.

{p 4 8 2}Geary R.C. (1970) {cmd: "Relative Efficiency of Count of Sign Changes for Assessing Residuals Autoregression in Least Squares Regression"}
{it:Biometrika, Vol. 57}; 123-127.

{marker 08}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse lmngry2.dta , clear}

 {stata db lmngry2}

 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(melo)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(liml)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(fuller) kf(0.5)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(kclass) kc(0.5)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(Geary)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(bart)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(dan)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(nwest)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(parzen)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(quad)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tent)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(trunc)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeym)}
 {stata lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeyn)}
{hline}

. clear all
. sysuse lmngry2.dta , clear
. lmngry2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)

==============================================================================
* Two Stage Least Squares (2SLS)
==============================================================================
  y1 = y2 + x1 + x2
------------------------------------------------------------------------------
 Sample Size        =          17
 Wald Test          =     79.9520   |   P-Value > Chi2(3)       =      0.0000
 F-Test             =     26.6507   |   P-Value > F(3 , 13)     =      0.0000
 R2  (R-Squared)    =      0.8592   |   Raw Moments R2          =      0.9954
 R2a (Adjusted R2)  =      0.8267   |   Raw Moments R2 Adj      =      0.9944
 Root MSE (Sigma)   =     10.2244   |   Log Likelihood Function =    -61.3630
------------------------------------------------------------------------------
- R2h= 0.8593   R2h Adj= 0.8268  F-Test =   26.46 P-Value > F(3 , 13)  0.0000
- R2v= 0.8765   R2v Adj= 0.8480  F-Test =   30.75 P-Value > F(3 , 13)  0.0000
------------------------------------------------------------------------------
          y1 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          y2 |    .237333   .2422811     0.98   0.345    -.2860835    .7607495
          x1 |   .2821278   .5433329     0.52   0.612    -.8916715    1.455927
          x2 |  -1.044795    .362648    -2.88   0.013    -1.828248   -.2613411
       _cons |   145.8444   61.72083     2.36   0.034     12.50468    279.1842
------------------------------------------------------------------------------
* Y  = LHS Dependent Variable:       1 = y1
* Yi = RHS Endogenous Variables:     1 = y2
* Xi = RHS Included Exogenous Vars:  2 = x1 x2
* Xj = RHS Excluded Exogenous Vars:  2 = x3 x4
* Z  = Overall Instrumental Vars:    4 = x1 x2 x3 x4

==============================================================================
*** 2SLS-IV Non Normality Geary Runs Test
==============================================================================
 Ho: Normality - Ha: Non Normality
------------------------------------------------------------------------------
- Geary LM Test                        =  -0.2366     P-Value > Chi2(2) 0.8884
------------------------------------------------------------------------------
    Skewness Coefficient = -0.8136     - Standard Deviation =  0.5497
    Kurtosis Coefficient =  3.9517     - Standard Deviation =  1.0632
------------------------------------------------------------------------------
    Runs Test: (9) Runs -  (9) Positives - (8) Negatives
    Standard Deviation Runs Sig(k) =  1.9887 , Mean Runs E(k) =  9.4706
    95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = ( 5.5727 , 13.3685 )
------------------------------------------------------------------------------

{marker 09}{bf:{err:{dlgtab:Authors}}}

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

{bf:{err:{dlgtab:LMNGRY2 Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2015)}{p_end}
{p 1 10 1}{cmd:LMNGRY2: "Stata Module to Compute 2SLS-IV Non Normality Geary Runs Test}{p_end}


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


