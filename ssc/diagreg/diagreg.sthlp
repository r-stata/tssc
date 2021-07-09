{smcl}
{hline}
{cmd:help: {helpb diagreg}}{space 50} {cmd:dialog:} {bf:{dialog diagreg}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:diagreg: OLS Model Selection Diagnostic Criteria}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb diagreg##01:Syntax}{p_end}
{p 5}{helpb diagreg##02:Options}{p_end}
{p 5}{helpb diagreg##03:Description}{p_end}
{p 5}{helpb diagreg##04:Saved Results}{p_end}
{p 5}{helpb diagreg##05:References}{p_end}

{p 1}*** {helpb diagreg##06:Examples}{p_end}

{p 5}{helpb diagreg##07:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 8 16 2}
{opt diagreg} {depvar} {indepvars} {ifin} , [ {opt nocons:tant} {opt coll} ]{p_end} 

{marker 02}{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{col 3}{opt nocons:tant}{col 20}suppress constant term

{col 3}{opt coll}{col 20}Keep Collinear Variables

{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:diagreg} computes OLS Model Selection diagnostic criteria, after OLS regression.{p_end} 

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

{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:diagreg} saves the following in {cmd:e()}:

{synoptset 12 tabbed}{...}
{bf:Scalars}
{col 4}{cmd:e(N)}{col 20}number of observations
{col 4}{cmd:e(r2bu)}{col 20}R-squared (Buse 1973)
{col 4}{cmd:e(r2bu_a)}{col 20}R-squared Adj (Buse 1973)
{col 4}{cmd:e(r2raw)}{col 20}Raw Moments R2
{col 4}{cmd:e(r2raw_a)}{col 20}Raw Moments R2 Adj
{col 4}{cmd:e(f)}{col 20}F-test
{col 4}{cmd:e(fp)}{col 20}F-test P-Value
{col 4}{cmd:e(wald)}{col 20}Wald-test
{col 4}{cmd:e(waldp)}{col 20}Wald-test P-Value
{col 4}{cmd:e(r2h)}{col 20}R2 Between Predicted (Yh) and Observed DepVar (Y)
{col 4}{cmd:e(r2h_a)}{col 20}Adjusted r2h
{col 4}{cmd:e(fh)}{col 20}F-test due to r2h
{col 4}{cmd:e(fhp)}{col 20}F-test due to r2h P-Value
{col 4}{cmd:e(r2v)}{col 20}R2 Variance Ratio Between Predicted (Yh) and Observed DepVar (Y)
{col 4}{cmd:e(r2v_a)}{col 20}Adjusted r2v
{col 4}{cmd:e(fv)}{col 20}F-test due to r2v
{col 4}{cmd:e(fvp)}{col 20}F-test due to r2v P-Value
{col 4}{cmd:e(sig)}{col 20}Root MSE (Sigma)

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

{bf:Matrixes}
{col 4}{cmd:e(b)}{col 20}coefficient vector
{col 4}{cmd:e(V)}{col 20}variance-covariance matrix of the estimators

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 242.

{marker 06}{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata db diagreg}

	{stata sysuse diagreg.dta, clear}

	{stata diagreg y x1 x2}

	{stata ereturn list}

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
*** OLS Model Selection Diagnostic Criteria
==============================================================================
- Log Likelihood Function                   LLF            =    -51.6471
---------------------------------------------------------------------------
- Akaike Information Criterion              (1974) AIC     =     36.2772
- Akaike Information Criterion              (1973) Log AIC =      3.5912
---------------------------------------------------------------------------
- Schwarz Criterion                         (1978) SC      =     42.0234
- Schwarz Criterion                         (1978) Log SC  =      3.7382
---------------------------------------------------------------------------
- Amemiya Prediction Criterion              (1969) FPE     =     36.4129
- Hannan-Quinn Criterion                    (1979) HQ      =     36.8113
- Rice Criterion                            (1984) Rice    =     39.3921
- Shibata Criterion                         (1981) Shibata =     34.4851
- Craven-Wahba Generalized Cross Validation (1979) GCV     =     37.5833
------------------------------------------------------------------------------

{marker 07}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:DIAGREG Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:DIAGREG: "Stata Module to Compute OLS Model Selection Diagnostic Criteria"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457358.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457358.htm"}

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

