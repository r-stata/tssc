{smcl}
{hline}
{cmd:help: {helpb diagreg2}}{space 50} {cmd:dialog:} {bf:{dialog diagreg2}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: diagreg2: 2SLS-IV Model Selection Diagnostic Criteria}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb diagreg2##01:Syntax}{p_end}
{p 5}{helpb diagreg2##02:Description}{p_end}
{p 5}{helpb diagreg2##03:Model}{p_end}
{p 5}{helpb diagreg2##04:GMM Options}{p_end}
{p 5}{helpb diagreg2##05:Other Options}{p_end}
{p 5}{helpb diagreg2##06:Saved Results}{p_end}
{p 5}{helpb diagreg2##07:References}{p_end}

{p 1}*** {helpb diagreg2##08:Examples}{p_end}

{p 5}{helpb diagreg2##09:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 2 4 2} 
{cmd:diagreg2} {depvar} {it:{help varlist:indepvars}} {cmd:({it:{help varlist:endog}} = {it:{help varlist:inst}})} {ifin} , {p_end} 
{p 6 6 2}
{opt model(2sls, liml, gmm, melo, fuller, kclass)}{p_end} 
{p 6 6 2}
{err: [} {opt kc(#)} {opt kf(#)} {opt hetcov(type)} {opt nocons:tant} {opt noconexog} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:diagreg2} computes 2SLS-IV Model Selection Diagnostic Criteria for instrumental variables regression models, via 2sls, liml, melo, gmm, and kclass.{p_end}

        - Log Likelihood Function                   LLF
        - Akaike Information Criterion              (1974) AIC
        - Akaike Information Criterion              (1973) Log AIC
        - Schwarz Criterion                         (1978) SC
        - Schwarz Criterion                         (1978) Log SC
        - Amemiya Prediction Criterion              (1969) FPE
        - Hannan-Quinn Criterion                    (1979) HQ
        - Rice Criterion                            (1984) Rice
        - Shibata Criterion                         (1981) Shibata
        - Craven-Wahba Generalized Cross Validation (1979) GCV

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

{synopt:{bf:noconexog}}Exclude Constant Term from all Equations (both RHS and Instrumental Equations). Results of using {cmd:noconexog} option are identical to Stata {helpb ivregress} and {helpb ivreg2}.
 The default of {cmd:diagreg2} is including Constant Term in both RHS and Instrumental Equations{p_end}

{marker 06}{bf:{err:{dlgtab:Saved Results}}}

{cmd:diagreg2} saves the following in {cmd:e()}:

{err:*** Model Selection Diagnostic Criteria:}
{col 4}{cmd:e(N)}{col 20}number of observations
{col 4}{cmd:e(r2bu)}{col 20}R-squared (Buse 1973)
{col 4}{cmd:e(r2bu_a)}{col 20}R-squared Adj (Buse 1973)
{col 4}{cmd:e(r2raw)}{col 20}Raw Moments R2
{col 4}{cmd:e(r2raw_a)}{col 20}Raw Moments R2 Adj
{col 4}{cmd:e(f)}{col 20}F-test
{col 4}{cmd:e(fp)}{col 20}F-test P-Value
{col 4}{cmd:e(wald)}{col 20}Wald-test
{col 4}{cmd:e(waldp)}{col 20}Wald-test P-Value
{col 4}{cmd:e(r2cc)}{col 20}Corrected R2
{col 4}{cmd:e(r2cc_a)}{col 20}adj Corrected R2
{col 4}{cmd:e(sig)}{col 20}Sigma (MSE)

{col 4}{cmd:e(llf)}{col 20}Log Likelihood Function{col 62}LLF
{col 4}{cmd:e(aic)}{col 20}Akaike Information Criterion{col 62}(1974) AIC
{col 4}{cmd:e(laic)}{col 20}Akaike Information Criterion{col 62}(1973) Log AIC
{col 4}{cmd:e(sc)}{col 20}Schwarz Criterion{col 62}(1978) SC
{col 4}{cmd:e(lsc)}{col 20}Schwarz Criterion{col 62}(1978) Log SC
{col 4}{cmd:e(fpe)}{col 20}Amemiya Prediction Criterion{col 62}(1969) FPE
{col 4}{cmd:e(hq)}{col 20}Hannan-Quinn Criterion{col 62}(1979) HQ
{col 4}{cmd:e(rice)}{col 20}Rice Criterion{col 62}(1984) Rice
{col 4}{cmd:e(shibata)}{col 20}Shibata Criterion{col 62}(1981) Shibata
{col 4}{cmd:e(gcv)}{col 20}Craven-Wahba Generalized Cross Validation (1979) GCV

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

{p 4 8 2}Griffiths, W., R. Carter Hill & George Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}; 602-606.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 615.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}; 358-366.

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

 {stata sysuse diagreg2.dta , clear}

 {stata db diagreg2}

 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(melo)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(liml)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(fuller) kf(0.5)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(kclass) kc(0.5)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(white)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(bart)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(dan)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(nwest)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(parzen)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(quad)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tent)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(trunc)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeym)}
 {stata diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeyn)}
{hline}

. clear all
. sysuse diagreg2.dta , clear
. diagreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)

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
* 2SLS-IV Model Selection Diagnostic Criteria - (Model= 2sls)
==============================================================================
- Log Likelihood Function                   LLF            =    -61.3630
---------------------------------------------------------------------------
- Akaike Information Criterion              (1974) AIC     =    127.9815
- Akaike Information Criterion              (1973) Log AIC =      4.8519
---------------------------------------------------------------------------
- Schwarz Criterion                         (1978) SC      =    155.7008
- Schwarz Criterion                         (1978) Log SC  =      5.0479
---------------------------------------------------------------------------
- Amemiya Prediction Criterion              (1969) FPE     =    129.1366
- Hannan-Quinn Criterion                    (1979) HQ      =    130.5000
- Rice Criterion                            (1984) Rice    =    151.0010
- Shibata Criterion                         (1981) Shibata =    117.5613
- Craven-Wahba Generalized Cross Validation (1979) GCV     =    136.7050
------------------------------------------------------------------------------

{marker 09}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:DIAGREG2 Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:DIAGREG2: "Stata Module to Compute 2SLS-IV Heteroscedasticity Tests"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457384.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457384.htm"}

{title:Online Help:}

{bf:{err:* Model Selection Diagnostic Criteria:}}
{helpb diagmle}{col 12}MLE Model Selection Diagnostic Criteria
{helpb diagnl}{col 12}NLS Model Selection Diagnostic Criteria
{helpb diagnlsur}{col 12}(NL-SUR) Overall System Model Selection Diagnostic Criteria
{helpb diagreg}{col 12}OLS Model Selection Diagnostic Criteria
{helpb diagreg2}{col 12}2SLS-IV Model Selection Diagnostic Criteria
{helpb diagreg3}{col 12}(3SLS-SUR) Overall System Model Selection Diagnostic Criteria
{helpb diagsem}{col 12}(SEM-FIML) Overall System Model Selection Diagnostic Criteria
{helpb diagvar}{col 12}(VAR) Overall System Model Selection Diagnostic Criteria
{helpb diagxt}{col 12}Panel Data Model Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* Linear vs Log-Linear Functional Form Tests:}}
{helpb lmfmle}{col 12}MLE Linear vs Log-Linear Functional Form Tests
{helpb lmfreg}{col 12}OLS Linear vs Log-Linear Functional Form Tests
{helpb lmfreg2}{col 12}2SLS-IV Linear vs Log-Linear Functional Form Tests
---------------------------------------------------------------------------
{helpb lmhaus2}{col 12}2SLS-IV Hausman Specification Test
{helpb lmhausxt}{col 12}Panel Data Hausman Specification Test
---------------------------------------------------------------------------
{helpb lmiden2}{col 12}2SLS-IV Over Identification Restrictions Tests
---------------------------------------------------------------------------
{helpb lmeg}{col 12}Augmented Engle-Granger Cointegration Test
{helpb lmgc}{col 12}2SLS-IV Granger Causality Test
{helpb lmsrd}{col 12}OLS Spurious Regression Diagnostic
---------------------------------------------------------------------------
{bf:{err:* REgression Specification Error Tests (RESET):}}
{helpb reset}{col 12}OLS REgression Specification Error Tests (RESET)
{helpb reset2}{col 12}2SLS-IV REgression Specification Error Tests (RESET)
{helpb resetmle}{col 12}MLE REgression Specification Error Tests (RESET)
{helpb resetxt}{col 12}Panel Data REgression Specification Error Tests (RESET)
---------------------------------------------------------------------------

{psee}
{p_end}

