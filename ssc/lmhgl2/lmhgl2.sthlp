{smcl}
{hline}
{cmd:help: {helpb lmhgl2}}{space 50} {cmd:dialog:} {bf:{dialog lmhgl2}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmhgl2: 2SLS-IV Heteroscedasticity Glejser Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmhgl2##01:Syntax}{p_end}
{p 5}{helpb lmhgl2##02:Description}{p_end}
{p 5}{helpb lmhgl2##03:Model}{p_end}
{p 5}{helpb lmhgl2##04:GMM Options}{p_end}
{p 5}{helpb lmhgl2##05:Other Options}{p_end}
{p 5}{helpb lmhgl2##06:Saved Results}{p_end}
{p 5}{helpb lmhgl2##07:References}{p_end}

{p 1}*** {helpb lmhgl2##08:Examples}{p_end}

{p 5}{helpb lmhgl2##09:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 2 4 2} 
{cmd:lmhgl2} {depvar} {it:{help varlist:indepvars}} {cmd:({it:{help varlist:endog}} = {it:{help varlist:inst}})} {ifin} , {p_end} 
{p 6 6 2}
{opt model(2sls, liml, gmm, melo, fuller, kclass)}{p_end} 
{p 6 6 2}
{err: [} {opt kc(#)} {opt kf(#)} {opt hetcov(type)} {opt nocons:tant} {opt noconexog} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:lmhgl2} computes 2SLS-IV Heteroscedasticity Glejser Test for instrumental variables regression models, via 2sls, liml, melo, gmm, and kclass.{p_end}

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
 The default of {cmd:lmhgl2} is including Constant Term in both RHS and Instrumental Equations{p_end}

{marker 06}{bf:{err:{dlgtab:Saved Results}}}

{cmd:lmhgl2} saves the following in {cmd:e()}:

{err:*** Heteroscedasticity Tests:}
{col 4}{cmd:e(lmhgl)}{col 20}Glejser LM Test
{col 4}{cmd:e(lmhgl)}{col 20}Glejser LM Test P-Value

{marker 07}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}Glejser, Robert (1982)
{cmd: "Autoregressive Conditional Heteroscedasticity with Estimates of Variance of United Kingdom Inflation"}
{it:Econometrica, 50(4), July, 1982}; 987-1007.

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA}.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Upper Saddle River, NJ: Prentice-Hall}.

{p 4 8 2}Griffiths, W., R. Carter Hill & George Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}; 602-606.

{p 4 8 2}Harvey, Andrew (1990)
{cmd: "The Econometric Analysis of Time Series",}
{it:2nd edition, MIT Press, Cambridge, Massachusetts}.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Kmenta, Jan (1986)
{cmd: "Elements of Econometrics",}
{it: 2nd ed., Macmillan Publishing Company, Inc., New York, USA}.

{marker 08}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse lmhgl2.dta , clear}

 {stata db lmhgl2}

 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(melo)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(liml)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(fuller) kf(0.5)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(kclass) kc(0.5)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(white)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(bart)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(dan)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(nwest)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(parzen)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(quad)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tent)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(trunc)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeym)}
 {stata lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeyn)}
{hline}

. clear all
. sysuse lmhgl2.dta , clear
. lmhgl2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)

==============================================================================
* Two Stage Least Squares (2SLS)
==============================================================================
  y1 = y2 + x1 + x2
------------------------------------------------------------------------------
 Sample Size        =          17
 Wald Test          =    233.0853   |   P-Value > Chi2(3)       =      0.0000
 F-Test             =     77.6951   |   P-Value > F(3 , 13)     =      0.0000
 R2  (R-Squared)    =      0.9467   |   Raw Moments R2          =      0.9985
 R2a (Adjusted R2)  =      0.9344   |   Raw Moments R2 Adj      =      0.9982
 Root MSE (Sigma)   =      6.0383   |   Log Likelihood Function =    -52.4099
------------------------------------------------------------------------------
- R2h= 0.9468   R2h Adj= 0.9345  F-Test =   77.05 P-Value > F(3 , 13)  0.0000
- R2v= 0.9598   R2v Adj= 0.9506  F-Test =  103.52 P-Value > F(3 , 13)  0.0000
------------------------------------------------------------------------------
          y1 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          y2 |  -.1454956    .143086    -1.02   0.328    -.4546141     .163623
          x1 |   1.202563   .3208808     3.75   0.002     .5093422    1.895784
          x2 |  -1.580143   .2141722    -7.38   0.000    -2.042834   -1.117452
       _cons |   152.6071     36.451     4.19   0.001     73.85946    231.3547
------------------------------------------------------------------------------
* Y  = LHS Dependent Variable:       1 = y1
* Yi = RHS Endogenous Variables:     1 = y2
* Xi = RHS Included Exogenous Vars:  2 = x1 x2
* Xj = RHS Excluded Exogenous Vars:  2 = x3 x4
* Z  = Overall Instrumental Vars:    4 = x1 x2 x3 x4

==============================================================================
*** 2SLS-IV Heteroscedasticity Glejser Test - Model= (2sls)
==============================================================================
 Ho: Homoscedasticity - Ha: Heteroscedasticity
------------------------------------------------------------------------------
- Glejser LM Test:        |E| = X      =   4.7123    P-Value > Chi2(2)  0.0948
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

{bf:{err:{dlgtab:LMHGL2 Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2015)}{p_end}
{p 1 10 1}{cmd:LMHGL2: "Stata Module to Compute 2SLS-IV Heteroscedasticity Glejser Test}{p_end}


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


