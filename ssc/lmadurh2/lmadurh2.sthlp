{smcl}
{hline}
{cmd:help: {helpb lmadurh2}}{space 50} {cmd:dialog:} {bf:{dialog lmadurh2}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmadurh2: 2SLS-IV Autocorrelation Dynamic Durbin h, Harvey LM, and Wald Tests}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmadurh2##01:Syntax}{p_end}
{p 5}{helpb lmadurh2##02:Description}{p_end}
{p 5}{helpb lmadurh2##03:Model}{p_end}
{p 5}{helpb lmadurh2##04:GMM Options}{p_end}
{p 5}{helpb lmadurh2##05:Other Options}{p_end}
{p 5}{helpb lmadurh2##06:Saved Results}{p_end}
{p 5}{helpb lmadurh2##07:References}{p_end}

{p 1}*** {helpb lmadurh2##08:Examples}{p_end}

{p 5}{helpb lmadurh2##09:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 2 4 2} 
{cmd:lmadurh2} {depvar} {it:{help varlist:indepvars}} {cmd:({it:{help varlist:endog}} = {it:{help varlist:inst}})} {ifin} , {p_end} 
{p 6 6 2}
{opt model(2sls, liml, gmm, melo, fuller, kclass)}{p_end} 
{p 6 6 2}
{err: [} {opt dlag(#)} {opt kc(#)} {opt kf(#)} {opt hetcov(type)} {opt nocons:tant} {opt noconexog} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:lmadurh2} computes 2SLS-IV Autocorrelation Dynamic Durbin h, Harvey LM, and Wald Tests for instrumental variables regression models, via 2sls, liml, melo, gmm, and kclass.{p_end}

 	Ho: No Autocorrelation - Ha: Autocorrelation
	- Durbin  h Test (Lag DepVar)
	- Durbin  h Test after ALS(1)
	- Harvey LM Test (Lag DepVar)
	- Harvey LM Test after ALS(1)
	- Wald    T Test
	- Wald Chi2 Test

{p 2 2 2 }Durbin h Test can not be computed, if the square root has negative value.{p_end}

     **************************************************************
     *   h  > 1.96  (Autocorrelation)                             *
     *   h  < 1.96  (No Autocorrelation)                          *
     *          h(+3) > +1.96    Positive Autocorrelation         *
     *          h(-3) < -1.96    Negative Autocorrelation         *
     *  -1.96 < h(+1) < +1.96    No       Autocorrelation         *
     **************************************************************

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

{col 3}{bf:dlag({err:{it:#}})}{col 20}Location of Lagged Dependent Variable
{col 20}Default is (1).

{synopt:{opt nocons:tant}}Exclude Constant Term from RHS Equation only{p_end}

{synopt:{bf:noconexog}}Exclude Constant Term from all Equations (both RHS and Instrumental Equations). Results of using {cmd:noconexog} option are identical to Stata {helpb ivregress}.
 The default of {cmd:lmadurh2} is including Constant Term in both RHS and Instrumental Equations{p_end}

{marker 06}{bf:{err:{dlgtab:Saved Results}}}

{cmd:lmadurh2} saves the following in {cmd:e()}:

{col 4}{cmd:e(lmadho)}{col 20}Durbin  h Test (Lag DepVar)
{col 4}{cmd:e(lmadhop)}{col 20}Durbin  h Test (Lag DepVar) P-Value
{col 4}{cmd:e(lmadha)}{col 20}Durbin  h Test after ALS(1)
{col 4}{cmd:e(lmadhap)}{col 20}Durbin  h Test after ALS(1) P-Value
{col 4}{cmd:e(lmahho)}{col 20}Harvey LM Test (Lag DepVar)
{col 4}{cmd:e(lmahhop)}{col 20}Harvey LM Test (Lag DepVar) P-Value
{col 4}{cmd:e(lmahha)}{col 20}Harvey LM Test after ALS(1)
{col 4}{cmd:e(lmahhap)}{col 20}Harvey LM Test after ALS(1) P-Value
{col 4}{cmd:e(lmawt)}{col 20}Wald T Test
{col 4}{cmd:e(lmawtp)}{col 20}Wald T Test P-Value
{col 4}{cmd:e(lmawc)}{col 20}Wald Chi2 Test
{col 4}{cmd:e(lmawcp)}{col 20}Wald Chi2 Test P-Value

{marker 07}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}Durbin, James (1970a)
{cmd: "Testing for Serial Correlation in Least-Squares Regression When Some of the Regressors are Lagged Dependent Variables",}
{it:Econometrica, vol.38, no.3, May}; 410-421.

{p 4 8 2}Durbin, James (1970b)
{cmd: "An Alternative to the Bounds Test for Testing for Serial Correlation in Least Square Regression",}
{it:Econometrica, Vol. 38, No. 2, May}; 422-429.

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA}.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Upper Saddle River, NJ: Prentice-Hall}.

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

 {stata sysuse lmadurh2.dta , clear}

 {stata db lmadurh2}

 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(2sls) dlag(1)}
 {stata lmadurh2 y1 x1 y11 x2 (y2 = y11 x1 x2 x3 x4) , model(2sls) dlag(2)}
 {stata lmadurh2 y1 x1 x2 y11 (y2 = y11 x1 x2 x3 x4) , model(2sls) dlag(3)}

 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(melo)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(liml)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(fuller) kf(0.5)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(kclass) kc(0.5)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(white)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(bart)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(dan)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(nwest)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(parzen)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(quad)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(tent)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(trunc)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(tukeym)}
 {stata lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(tukeyn)}
{hline}

. clear all
. sysuse lmadurh2.dta , clear
. lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(2sls) dlag(1)

==============================================================================
* Two Stage Least Squares (2SLS)
==============================================================================
  y1 = y2 + y11 + x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          17
  Wald Test         =    232.9156   |   P-Value > Chi2(4)       =      0.0000
  F-Test            =     58.2289   |   P-Value > F(4 , 12)     =      0.0000
 (Buse 1973) R2     =      0.9506   |   Raw Moments R2          =      0.9986
 (Buse 1973) R2 Adj =      0.9342   |   Raw Moments R2 Adj      =      0.9982
  Root MSE (Sigma)  =      6.0480   |   Log Likelihood Function =    -51.7567
------------------------------------------------------------------------------
- R2h= 0.9507   R2h Adj= 0.9342  F-Test =   57.82 P-Value > F(4 , 12)  0.0000
- R2v= 0.9609   R2v Adj= 0.9479  F-Test =   73.78 P-Value > F(4 , 12)  0.0000
------------------------------------------------------------------------------
          y1 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          y2 |  -.1227586   .1494559    -0.82   0.427     -.448395    .2028778
         y11 |  -.1167566   .1707067    -0.68   0.507    -.4886945    .2551813
          x1 |   1.228178   .3224539     3.81   0.002      .525611    1.930744
          x2 |   -1.70445   .2721733    -6.26   0.000    -2.297464   -1.111435
       _cons |   171.3375   44.71636     3.83   0.002     73.90887     268.766
------------------------------------------------------------------------------
* Y  = LHS Dependent Variable:       1 = y1
* Yi = RHS Endogenous Variables:     1 = y2
* Xi = RHS Included Exogenous Vars:  3 = y11 x1 x2
* Xj = RHS Excluded Exogenous Vars:  2 = x3 x4
* Z  = Overall Instrumental Vars:    5 = y11 x1 x2 x3 x4

==============================================================================
*** 2SLS-IV Autocorrelation Dynamic Tests - Model= (2sls)
==============================================================================
 Ho: No Autocorrelation - Ha: Autocorrelation
------------------------------------------------------------------------------
- Durbin  h Test (Lag DepVar)          AR(1)= -1.4290  P-Value >Z(0,1)  0.1530
- Durbin  h Test after ALS(1)          AR(1)=  2.2898  P-Value >Z(0,1)  0.0220
------------------------------------------------------------------------------
- Harvey LM Test (Lag DepVar)          AR(1)=  2.0420  P-Value >Chi2(1) 0.1530
- Harvey LM Test after ALS(1)          AR(1)=  5.2433  P-Value >Chi2(1) 0.0220
------------------------------------------------------------------------------
- Wald    T Test                       AR(1)= -0.4057  P-Value >Z(0,1)  0.6850
- Wald Chi2 Test                       AR(1)=  0.1646  P-Value >Z(0,1)  0.6850
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

{bf:{err:{dlgtab:LMADURH2 Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2012)}{p_end}
{p 1 10 1}{cmd:LMADURH2: "2SLS-IV Autocorrelation Dynamic Durbin h, Harvey LM, and Wald Tests"}{p_end}


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


