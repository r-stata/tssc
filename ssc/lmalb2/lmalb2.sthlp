{smcl}
{hline}
{cmd:help: {helpb lmalb2}}{space 50} {cmd:dialog:} {bf:{dialog lmalb2}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmalb2: 2SLS-IV Autocorrelation Ljung-Box Test at Higher Order AR(p)}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmalb2##01:Syntax}{p_end}
{p 5}{helpb lmalb2##02:Description}{p_end}
{p 5}{helpb lmalb2##03:Model}{p_end}
{p 5}{helpb lmalb2##04:GMM Options}{p_end}
{p 5}{helpb lmalb2##05:Other Options}{p_end}
{p 5}{helpb lmalb2##06:Saved Results}{p_end}
{p 5}{helpb lmalb2##07:References}{p_end}

{p 1}*** {helpb lmalb2##08:Examples}{p_end}

{p 5}{helpb lmalb2##09:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 2 4 2} 
{cmd:lmalb2} {depvar} {it:{help varlist:indepvars}} {cmd:({it:{help varlist:endog}} = {it:{help varlist:inst}})} {ifin} , {p_end} 
{p 6 6 2}
{opt model(2sls, liml, gmm, melo, fuller, kclass)}{p_end} 
{p 6 6 2}
{err: [} {opt lag:s(#)} {opt kc(#)} {opt kf(#)} {opt hetcov(type)} {opt nocons:tant} {opt noconexog} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:lmalb2} computes 2SLS-IV Autocorrelation Ljung-Box Test at Higher Order AR(p) for instrumental variables regression models, via 2sls, liml, melo, gmm, and kclass.{p_end}

 	Ho: No Autocorrelation - Ha: Autocorrelation
	- Ljung-Box LM Test

                                  J
   {cmd: Ljung-Box LM test} = N(N+2) [ Sum(Rho_i^2/(N-k)) ] ~ Chi2(J)
                                 i=1
where
       N = Number of Observations.
       k = Number of Parameters.
       J = Order of Lag Length.
   Rho_i = Autoregressive Coefficient of Lag i.


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

{synopt:{bf:lags({err:{it:#}})}}Order of Lag Length{p_end}

{synopt:{opt nocons:tant}}Exclude Constant Term from RHS Equation only{p_end}

{synopt:{bf:noconexog}}Exclude Constant Term from all Equations (both RHS and Instrumental Equations). Results of using {cmd:noconexog} option are identical to Stata {helpb ivregress}.
 The default of {cmd:lmalb2} is including Constant Term in both RHS and Instrumental Equations{p_end}

{marker 06}{bf:{err:{dlgtab:Saved Results}}}

{cmd:lmalb2} saves the following in {cmd:e()}:

{col 4}{cmd:e(rho#)}{col 20}Rho Value for AR(i)
{col 4}{cmd:e(lmalb#)}{col 20}Ljung-Box LM Test AR(i)
{col 4}{cmd:e(lmalbp#)}{col 20}Ljung-Box LM Test AR(i) P-Value

{marker 07}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA}; 616-618.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Upper Saddle River, NJ: Prentice-Hall}; 387-388.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Ljung, G. & George Box (1979)
{cmd: "On a Measure of Lack of Fit in Time Series Models",}
{it:Biometrika, Vol. 66}; 265–270.

{marker 08}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse lmalb2.dta , clear}

 {stata db lmalb2}

 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls) lag(4)}

 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(melo)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(liml)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(fuller) kf(0.5)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(kclass) kc(0.5)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(white)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(bart)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(dan)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(nwest)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(parzen)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(quad)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tent)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(trunc)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeym)}
 {stata lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeyn)}
{hline}

. clear all
. sysuse lmalb2.dta , clear
. lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls) lag(4)

==============================================================================
* Two Stage Least Squares (2SLS)
==============================================================================
  y1 = y2 + x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          17
  Wald Test         =     79.9520   |   P-Value > Chi2(3)       =      0.0000
  F-Test            =     26.6507   |   P-Value > F(3 , 13)     =      0.0000
 (Buse 1973) R2     =      0.8592   |   Raw Moments R2          =      0.9954
 (Buse 1973) R2 Adj =      0.8267   |   Raw Moments R2 Adj      =      0.9944
  Root MSE (Sigma)  =     10.2244   |   Log Likelihood Function =    -61.3630
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
*** 2SLS-IV Autocorrelation Ljung-Box Test - Model= (2sls)
==============================================================================
 Ho: No Autocorrelation - Ha: Autocorrelation
------------------------------------------------------------------------------
- Rho Value for Order(1)               AR(1)= -0.0855
- Ljung-Box  LM Test                   AR(1)=  0.1475  P-Value >Chi2(1) 0.7010
------------------------------------------------------------------------------
- Rho Value for Order(2)               AR(2)= -0.2334
- Ljung-Box  LM Test                   AR(2)=  1.3207  P-Value >Chi2(2) 0.5167
------------------------------------------------------------------------------
- Rho Value for Order(3)               AR(3)=  0.1275
- Ljung-Box  LM Test                   AR(3)=  1.6955  P-Value >Chi2(3) 0.6379
------------------------------------------------------------------------------
- Rho Value for Order(4)               AR(4)= -0.0905
- Ljung-Box  LM Test                   AR(4)=  1.8989  P-Value >Chi2(4) 0.7543
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

{bf:{err:{dlgtab:LMALB2 Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2012)}{p_end}
{p 1 10 1}{cmd:LMALB2: "2SLS-IV Autocorrelation Ljung-Box Test at Higher Order AR(p)"}{p_end}


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


