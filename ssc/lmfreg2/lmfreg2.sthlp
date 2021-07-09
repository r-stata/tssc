{smcl}
{hline}
{cmd:help: {helpb lmfreg2}}{space 50} {cmd:dialog:} {bf:{dialog lmfreg2}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmfreg2: 2SLS-IV Linear vs Log-Linear Functional Form Tests}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmfreg2##01:Syntax}{p_end}
{p 5}{helpb lmfreg2##02:Description}{p_end}
{p 5}{helpb lmfreg2##03:Model}{p_end}
{p 5}{helpb lmfreg2##04:GMM Options}{p_end}
{p 5}{helpb lmfreg2##05:Other Options}{p_end}
{p 5}{helpb lmfreg2##06:Saved Results}{p_end}
{p 5}{helpb lmfreg2##07:References}{p_end}

{p 1}*** {helpb lmfreg2##08:Examples}{p_end}

{p 5}{helpb lmfreg2##09:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 2 4 2} 
{cmd:lmfreg2} {depvar} {it:{help varlist:indepvars}} {cmd:({it:{help varlist:endog}} = {it:{help varlist:inst}})} {ifin} , {p_end} 
{p 6 6 2}
{opt model(2sls, liml, gmm, melo, fuller, kclass)}{p_end} 
{p 6 6 2}
{err: [} {opt kc(#)} {opt kf(#)} {opt hetcov(type)} {opt nocons:tant} {opt noconexog} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:lmfreg2} computes 2SLS-IV Linear vs Log-Linear Functional Form Tests for instrumental variables regression models, via 2sls, liml, melo, gmm, and kclass.{p_end}

	- R-squared
 	- Log Likelihood Function (LLF)
 	- Antilog R2
 	- Box-Cox Test
 	- Bera-McAleer BM Test
 	- Davidson-Mackinnon PE Test

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
 The default of {cmd:lmfreg2} is including Constant Term in both RHS and Instrumental Equations{p_end}

{marker 06}{bf:{err:{dlgtab:Saved Results}}}

{cmd:lmfreg2} saves the following in {cmd:e()}:

{err:*** Linear vs Log-Linear Functional Form Tests:}
{col 4}{cmd:e(r2lin)}{col 20}Linear R2
{col 4}{cmd:e(r2log)}{col 20}Log-Log R2
{col 4}{cmd:e(llflin)}{col 20}LLF - Linear
{col 4}{cmd:e(llflog)}{col 20}LLF - Log-Log
{col 4}{cmd:e(r2lina)}{col 20}Antilog R2 Linear  vs Log-Log: R2Lin
{col 4}{cmd:e(r2loga)}{col 20}Antilog R2 Log-Log vs Linear: R2log
{col 4}{cmd:e(boxcox)}{col 20}Box-Cox Test
{col 4}{cmd:e(boxcoxp)}{col 20}Box-Cox Test P-Value
{col 4}{cmd:e(bmlin)}{col 20}Bera-McAleer BM Test - Linear ModeL
{col 4}{cmd:e(bmlinp)}{col 20}Bera-McAleer BM Test - Linear ModeL P-Value
{col 4}{cmd:e(bmlog)}{col 20}Bera-McAleer BM Test - Log-Log ModeL
{col 4}{cmd:e(bmlogp)}{col 20}Bera-McAleer BM Test - Log-Log ModeL P-Value
{col 4}{cmd:e(dmlin)}{col 20}Davidson-Mackinnon PE Test - Linear ModeL
{col 4}{cmd:e(dmlinp)}{col 20}Davidson-Mackinnon PE Test - Linear ModeL P-Value
{col 4}{cmd:e(dmlog)}{col 20}Davidson-Mackinnon PE Test - Log-Log ModeL
{col 4}{cmd:e(dmlogp)}{col 20}Davidson-Mackinnon PE Test - Log-Log ModeL P-Value

{marker 07}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}; 210,265.

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA}; 616-618.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Upper Saddle River, NJ: Prentice-Hall}; 387-388.

{p 4 8 2}Griffiths, W., R. Carter Hill & George Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}; 602-606.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 615.

{p 4 8 2}Kmenta, Jan (1986)
{cmd: "Elements of Econometrics",}
{it: 2nd ed., Macmillan Publishing Company, Inc., New York, USA}; 718.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}; 222-223, 358-366.

{p 4 8 2}Park, S. (1982)
{cmd: "Some Sampling Properties of Minimum Expected Loss (MELO) Estimators of Structural Coefficients",}
{it:J. Econometrics, Vol. 18, No. 2, April,}; 295-311.

{p 4 8 2}White, Halbert (1980)
{cmd: "A Heteroskedasticity-Consistent Covariance Matrix Estimator and a Direct Test for Heteroskedasticity",}
{it:Econometrica, 48}; 817-838.

{p 4 8 2}William E. Griffiths, R. Carter Hill and George G. Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.  

{p 4 8 2}Zellner, Arnold (1978)
{cmd: "Estimation of Functions of Population Means and Regression Coefficients Including Structural Coefficients: A Minimum Expected Loss (MELO) Approach",}
{it:J. Econometrics, Vol. 8,}; 127-158.

{p 4 8 2}Zellner, Arnold & S. Park (1979)
{cmd: "Minimum Expected Loss (MELO) Estimators for Functions of Parameters and Structural Coefficients of Econometric Models",}
{it:J. Am. Stat. Assoc., Vol. 74}; 185-193.

{marker 08}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse lmfreg2.dta , clear}

 {stata db lmfreg2}

 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(melo)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(liml)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(fuller) kf(0.5)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(kclass) kc(0.5)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(white)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(bart)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(dan)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(nwest)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(parzen)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(quad)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tent)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(trunc)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeym)}
 {stata lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeyn)}
{hline}

. clear all
. sysuse lmfreg2.dta , clear
. lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)

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
* 2SLS-IV Linear vs Log-Linear Functional Form Tests - Model= (2sls)
==============================================================================
 (1) R-squared
      Linear  R2                   =    0.8592
      Log-Log R2                   =    0.8756
------------------------------------------------------------------------------
 (2) Log Likelihood Function (LLF)
      LLF - Linear                 =  -61.3630
      LLF - Log-Log                =  -60.6539
------------------------------------------------------------------------------
 (3) Antilog R2
      Linear  vs Log-Log: R2Lin    =    0.8434
      Log-Log vs Linear : R2log    =    0.8853
------------------------------------------------------------------------------
 (4) Box-Cox Test                  =    1.1614   P-Value > Chi2(1)   0.2812
      Ho: Choose Log-Log Model - Ha: Choose Linear  Model
------------------------------------------------------------------------------
 (5) Bera-McAleer BM Test
      Ho: Choose Linear  Model     =    0.3475   P-Value > F(1, 12)  0.5665
      Ho: Choose Log-Log Model     =    1.3163   P-Value > F(1, 12)  0.2736
------------------------------------------------------------------------------
 (6) Davidson-Mackinnon PE Test
      Ho: Choose Linear  Model     =    0.3928   P-Value > F(1, 12)  0.5426
      Ho: Choose Log-Log Model     =    1.4537   P-Value > F(1, 12)  0.2512
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

{bf:{err:{dlgtab:LMFREG2 Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2012)}{p_end}
{p 1 10 1}{cmd:LMFREG2: "2SLS-IV Linear vs Log-Linear Functional Form Tests"}{p_end}


{title:Online Help:}

{helpb diagmle}{col 12}MLE Model Selection Diagnostic Criteria
{helpb diagnl}{col 12}NLS Model Selection Diagnostic Criteria
{helpb diagnlsur}{col 12}(NL-SUR) Overall System ModeL Selection Diagnostic Criteria
{helpb diagreg}{col 12}OLS Model Selection Diagnostic Criteria
{helpb diagreg2}{col 12}2SLS-IV Model Selection Diagnostic Criteria
{helpb diagreg3}{col 12}(3SLS-SUR) Overall System ModeL Selection Diagnostic Criteria
{helpb diagsem}{col 12}(SEM-FIML) Overall System ModeL Selection Diagnostic Criteria
{helpb diagvar}{col 12}(VAR) Overall System ModeL Selection Diagnostic Criteria
{helpb diagxt}{col 12}Panel Data ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------

{helpb lmfmle}{col 12}MLE Linear vs Log-Linear Functional Form Tests
{helpb lmfreg}{col 12}OLS Linear vs Log-Linear Functional Form Tests
{helpb lmfreg2}{col 12}2SLS-IV Linear vs Log-Linear Functional Form Tests

{helpb lmhaus2}{col 12}2SLS-IV Hausman Specification Test
{helpb lmhausxt}{col 12}Panel Data Hausman Specification Test

{helpb lmiden2}{col 12}2SLS-IV Over Identification Restrictions Tests

{helpb lmeg}{col 12}Augmented Engle-Granger Cointegration Test
{helpb lmgc}{col 12}2SLS-IV Granger Causality Test
{helpb lmsrd}{col 12}OLS Spurious Regression Diagnostic

{helpb reset}{col 12}OLS REgression Specification Error Tests (RESET)
{helpb reset2}{col 12}2SLS-IV REgression Specification Error Tests (RESET)
{helpb resetmle}{col 12}MLE REgression Specification Error Tests (RESET)
{helpb resetxt}{col 12}Panel Data REgression Specification Error Tests (RESET)

{psee}
{p_end}

