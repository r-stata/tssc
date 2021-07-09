{smcl}
{hline}
{cmd:help: {helpb ridge2sls}}{space 50} {cmd:dialog:} {bf:{dialog ridge2sls}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: ridge2sls: Two-Stage Least Squares (2SLS): Ridge & Weighted Regression}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb ridge2sls##01:Syntax}{p_end}
{p 5}{helpb ridge2sls##02:Description}{p_end}
{p 5}{helpb ridge2sls##03:Ridge Options}{p_end}
{p 5}{helpb ridge2sls##04:Weight Options}{p_end}
{p 5}{helpb ridge2sls##05:Weighted Variable Type Options}{p_end}
{p 5}{helpb ridge2sls##06:Options}{p_end}
{p 5}{helpb ridge2sls##07:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb ridge2sls##08:Saved Results}{p_end}
{p 5}{helpb ridge2sls##09:References}{p_end}

{p 1}*** {helpb ridge2sls##10:Examples}{p_end}

{p 5}{helpb ridge2sls##11:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 2 4 2} 
{cmd:ridge2sls} {depvar} {it:{help varlist:indepvars}} {cmd:({it:{help varlist:endog}} = {it:{help varlist:inst}})} {ifin} , {p_end} 
{p 6 6 2}
{err: [} {opt rid:ge(orr|grr1|grr2|grr3)} {opt kr(#)} {opt dn diag}{p_end} 
{p 8 6 2}
{opt mfx(lin|log)} {opt weights(yh|yh2|abse|e2|le2|x|xi|x2|xi2)} {opt wv:ar(varname)}{p_end} 
{p 8 6 2}
{opt first} {opt nocons:tant} {opt noconexog} {opt pred:ict(new_var)} {opt res:id(new_var)} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:ridge2sls} estimates Two-Stage Least Squares (2SLS),
with Ridge and Weighted Regression, and computes Model Selection Diagnostic Criteria,
and Marginal Effects and Elasticities.

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 3 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- Corrected R2, if original R2 is negative.{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}
{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}

{marker 03}{bf:{err:{dlgtab:Ridge Options}}}

{p 3 6 2} {opt kr(#)} Ridge k value, must be in the range (0 < k < 1).{p_end}

{p 3 6 2}IF {bf:kr(0)} in {opt ridge(orr, grr1, grr2, grr3)}, the model will be an IV-2SLS regression.{p_end}

{col 3}{bf:ridge({err:{it:orr}})} : Ordinary Ridge Regression    [Judge,et al(1988,p.878) eq.21.4.2].
{col 3}{bf:ridge({err:{it:grr1}})}: Generalized Ridge Regression [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:ridge({err:{it:grr2}})}: Iterative Generalized Ridge  [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:ridge({err:{it:grr3}})}: Adaptive Generalized Ridge   [Strawderman(1978)].

{p 2 4 2}{cmd:ridge2sls} estimates Ordinary Ridge regression as a multicollinearity remediation method.{p_end}
{p 2 4 2}General form of Ridge Coefficients and Covariance Matrix are:{p_end}

{p 2 4 2}{cmd:Br = inv[X'X + kI] X'Y}{p_end}

{p 2 4 2}{cmd:Cov=Sig^2 * inv[X'X + kI] (X'X) inv[X'X + kI]}{p_end}

where:
    Br = Ridge Coefficients Vector (k x 1).
   Cov = Ridge Covariance Matrix (k x k).
     Y = Dependent Variable Vector (N x 1).
     X = Independent Variables Matrix (N x k).
     k = Ridge Value (0 < k < 1).
     I = Diagonal Matrix of Cross Product Matrix (Xs'Xs).
    Xs = Standardized Variables Matrix in Deviation from Mean. 
  Sig2 = (Y-X*Br)'(Y-X*Br)/DF

{marker 04}{bf:{err:{dlgtab:Weight Options}}}

{synoptset 16}{...}
{synopt:{bf:wvar({err:{it:varname}})}}Weighted Variable Name{p_end}

{marker 05}{bf:{err:{dlgtab:Weighted Variable Type Options}}}

{synoptset 16}{...}
{p2coldent:{it:Type Options}}Description{p_end}

{synopt:{bf:weights({err:{it:yh}})}}Yh - Predicted Value{p_end}
{synopt:{bf:weights({err:{it:yh2}})}}Yh^2 - Predicted Value Squared{p_end}
{synopt:{bf:weights({err:{it:abse}})}}abs(E) - Absolute Value of Residual{p_end}
{synopt:{bf:weights({err:{it:e2}})}}E^2 - Residual Squared{p_end}
{synopt:{bf:weights({err:{it:le2}})}}log(E^2) - Log Residual Squared{p_end}
{synopt:{bf:weights({err:{it:x}})}}(x) Variable{p_end}
{synopt:{bf:weights({err:{it:xi}})}}(1/x) Inverse Variable{p_end}
{synopt:{bf:weights({err:{it:x2}})}}(x^2) Squared Variable{p_end}
{synopt:{bf:weights({err:{it:xi2}})}}(1/x^2) Inverse Squared Variable{p_end}

{marker 06}{bf:{err:{dlgtab:Options}}}

{synoptset 16}{...}

{col 3}{opt dn}{col 20}Use (N) divisor instead of (N-K) for Degrees of Freedom (DF)

{col 3}{opt first}{col 20}Display Reduced Form Equations (First Stage Regression

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from RHS Equation only

{col 3}{bf:noconexog}{col 20}Exclude Constant Term from all Equations
{col 20}(both RHS and Instrumental Equations).
{col 20}Results of using {cmd:noconexog} option are identical to
{col 20}Stata {helpb ivregress}.
{col 20}Including Constant Term in both RHS and Instrumental Equations
{col 20}is default in {cmd:ridge2sls}

{col 3}{opt mfx(lin, log)}{col 20}functional form: Linear model {cmd:(lin)}, or Log-Log model {cmd:(log)},
{col 20}to compute Marginal Effects and Elasticities
   - In Linear model: marginal effects are the coefficients (Bm),
        and elasticities are (Es = Bm X/Y).
   - In Log-Log model: elasticities are the coefficients (Es),
        and the marginal effects are (Bm = Es Y/X).

{synopt:{opt pred:ict(new_var)}}Predicted values variable{p_end}

{synopt:{opt res:id(new_var)}}Residuals values variable{p_end}

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:Model Selection Diagnostic Criteria}}}

{synopt:{opt diag}}Model Selection Diagnostic Criteria{p_end}

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

{marker 08}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:ridge2sls} saves the following in {cmd:e()}:

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

Matrixes
{col 4}{cmd:e(b)}{col 20}coefficient vector
{col 4}{cmd:e(V)}{col 20}variance-covariance matrix of the estimators
{col 4}{cmd:e(mfxlin)}{col 20}Marginal Effect and Elasticity in Lin Form
{col 4}{cmd:e(mfxlog)}{col 20}Marginal Effect and Elasticity in Log Form

{marker 09}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}Evagelia, Mitsaki (2011)
{cmd: "Ridge Regression Analysis of Collinear Data",}
{browse "http://www.stat-athens.aueb.gr/~jpan/diatrives/Mitsaki/chapter2.pdf"}

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Upper Saddle River, NJ: Prentice-Hall}; 387-388.

{p 4 8 2}Griffiths, W., R. Carter Hill & George Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}; 602-606.

{p 4 8 2}Hoerl A. E. (1962)
{cmd: "Application of Ridge Analysis to Regression Problems",}
{it:Chemical Engineering Progress, 58}; 54-59.

{p 4 8 2}Hoerl, A. E. and R. W. Kennard (1970a)
{cmd: "Ridge Regression: Biased Estimation for Non-Orthogonal Problems",}
{it:Technometrics, 12}; 55-67.

{p 4 8 2}Hoerl, A. E. and R. W. Kennard (1970b)
{cmd: "Ridge Regression: Applications to Non-Orthogonal Problems",}
{it:Technometrics, 12}; 69-82.

{p 4 8 2}Hoerl, A. E. ,R. W. Kennard, & K. Baldwin  (1975)
{cmd: "Ridge Regression: Some Simulations",}
{it:Communications in Statistics, A, 4}; 105-123.

{p 4 8 2}Hoerl, A. E. and R. W. Kennard (1976)
{cmd: "Ridge Regression: Iterative Estimation of the Biasing Parameter",}
{it:Communications in Statistics, A, 5}; 77-88.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 615.

{p 4 8 2}Kmenta, Jan (1986)
{cmd: "Elements of Econometrics",}
{it: 2nd ed., Macmillan Publishing Company, Inc., New York, USA}; 718.

{p 4 8 2}Marquardt D.W. (1970)
{cmd: "Generalized Inverses, Ridge Regression, Biased Linear Estimation, and Nonlinear Estimation",}
{it:Technometrics, 12}; 591-612.

{p 4 8 2}Marquardt D.W. & R. Snee (1975)
{cmd: "Ridge Regression in Practice",}
{it:The American Statistician, 29}; 3-19.

{p 4 8 2}Theil, Henri (1971)
{cmd: "Principles of Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}White, Halbert (1980)
{cmd: "A Heteroskedasticity-Consistent Covariance Matrix Estimator and a Direct Test for Heteroskedasticity",}
{it:Econometrica, 48}; 817-838.

{p 4 8 2}William E. Griffiths, R. Carter Hill and George G. Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.  

{marker 10}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse ridge2sls.dta , clear}

 {stata db ridge2sls}

{bf:{err:* (1) Two Stages Least Squares (2SLS)}}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(grr1) diag mfx(lin)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , mfx(log)}
{hline}

{bf:{err:* (2) Weighted Two Stages Least Squares (W2SLS)}}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(yh)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(yh2)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(abse)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(e2)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(le2)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(x) wvar(x1)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(xi) wvar(x1)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(x2) wvar(x1)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(xi2) wvar(x1)}
{hline}

{bf:{err:* (3) Ridge Two Stages Least Squares (R2SLS)}}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(orr) kr(0.5) weights(x) wvar(x1)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(orr) kr(0.5)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(grr1)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(grr2)}

 {stata ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(grr3)}
{hline}

. clear all
. sysuse ridge2sls.dta , clear
. ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(grr1) diag mfx(lin)

==============================================================================
* Two Stage Least Squares (2SLS)
==============================================================================
  y1 = y2 + x1 + x2
------------------------------------------------------------------------------
 Ridge k Value      =   0.04629     |   Generalized Ridge Regression
------------------------------------------------------------------------------
  Sample Size       =          17
  Wald Test         =     76.3982   |   P-Value > Chi2(3)       =      0.0000
  F-Test            =     25.4661   |   P-Value > F(3 , 13)     =      0.0000
 (Buse 1973) R2     =      0.8526   |   Raw Moments R2          =      0.9952
 (Buse 1973) R2 Adj =      0.8186   |   Raw Moments R2 Adj      =      0.9941
  Root MSE (Sigma)  =     10.4595   |   Log Likelihood Function =    -61.7495
------------------------------------------------------------------------------
- R2h= 0.8528   R2h Adj= 0.8188  F-Test =   25.10 P-Value > F(3 , 13)  0.0000
- R2v= 0.8339   R2v Adj= 0.7956  F-Test =   21.76 P-Value > F(3 , 13)  0.0000
------------------------------------------------------------------------------
          y1 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          y2 |   .2967317   .1638088     1.81   0.093    -.0571557    .6506192
          x1 |   .1904857    .494348     0.39   0.706    -.8774883     1.25846
          x2 |  -.9198076   .2468019    -3.73   0.003    -1.452991   -.3866245
       _cons |   137.0235   55.16998     2.48   0.027     17.83605     256.211
------------------------------------------------------------------------------
* Y  = LHS Dependent Variable:       1 = y1
* Yi = RHS Endogenous Variables:     1 = y2
* Xi = RHS Included Exogenous Vars:  2 = x1 x2
* Xj = RHS Excluded Exogenous Vars:  2 = x3 x4
* Z  = Overall Instrumental Vars:    4 = x1 x2 x3 x4

==============================================================================
* 2SLS-IV Model Selection Diagnostic Criteria
==============================================================================
- Log Likelihood Function                   LLF            =    -61.7495
---------------------------------------------------------------------------
- Akaike Information Criterion              (1974) AIC     =    133.9348
- Akaike Information Criterion              (1973) Log AIC =      4.8974
---------------------------------------------------------------------------
- Schwarz Criterion                         (1978) SC      =    162.9435
- Schwarz Criterion                         (1978) Log SC  =      5.0934
---------------------------------------------------------------------------
- Amemiya Prediction Criterion              (1969) FPE     =    135.1436
- Hannan-Quinn Criterion                    (1979) HQ      =    136.5705
- Rice Criterion                            (1984) Rice    =    158.0251
- Shibata Criterion                         (1981) Shibata =    123.0299
- Craven-Wahba Generalized Cross Validation (1979) GCV     =    143.0641
------------------------------------------------------------------------------

* Marginal Effect - Elasticity: Linear *

+---------------------------------------------------------------------------+
|   Variable | Marginal_Effect(B) |     Elasticity(Es) |               Mean |
|------------+--------------------+--------------------+--------------------|
|         y2 |             0.2967 |             0.3351 |           146.8118 |
|         x1 |             0.1905 |             0.1509 |           102.9824 |
|         x2 |            -0.9198 |            -0.5399 |            76.3118 |
+---------------------------------------------------------------------------+
 Mean of Dependent Variable =    130.0118

{marker 11}{bf:{err:{dlgtab:Authors}}}

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

{bf:{err:{dlgtab:RIDGE2SLS Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2013)}{p_end}
{p 1 10 1}{cmd:RIDGE2SLS: "Two-Stage Least Squares (2SLS): Ridge & Weighted Regression"}{p_end}


{title:Online Help:}

{bf:{err:* Econometric Regression Models:}}

{bf:{err:* (1) (OLS) * Ordinary Least Squares Regression Models:}}
{helpb olsreg}{col 12}OLS Econometric Ridge & Weighted Regression Models: Stata Module Toolkit
{helpb ridgereg}{col 12}OLS Ridge Regression Models
{helpb gmmreg}{col 12}OLS Generalized Method of Moments (GMM): Ridge & Weighted Regression
{helpb chowreg}{col 12}OLS Structural Change Regressions and Chow Test
---------------------------------------------------------------------------
{bf:{err:* (2) (2SLS-IV) * Two-Stage Least Squares & Instrumental Variables Regression Models:}}
{helpb reg2}{col 12}2SLS-IV Econometric Ridge & Weighted Regression Models: Stata Module Toolkit
{helpb gmmreg2}{col 12}2SLS-IV Generalized Method of Moments (GMM): Ridge & Weighted Regression
{helpb limlreg2}{col 12}Limited-Information Maximum Likelihood (LIML) IV Regression
{helpb meloreg2}{col 12}Minimum Expected Loss (MELO) IV Regression
{helpb ridgereg2}{col 12}Ridge 2SLS-LIML-GMM-MELO-Fuller-kClass IV Regression
{helpb ridge2sls}{col 12}Two-Stage Least Squares Ridge Regression
{helpb ridgegmm}{col 12}Generalized Method of Moments (GMM) IV Ridge Regression
{helpb ridgeliml}{col 12}Limited-Information Maximum Likelihood (LIML) IV Ridge Regression
{helpb ridgemelo}{col 12}Minimum Expected Loss (MELO) IV Ridge Regression
---------------------------------------------------------------------------
{bf:{err:* (3) * Panel Data Regression Models:}}
{helpb regxt}{col 12}Panel Data Econometric Ridge & Weighted Regression Models: Stata Module Toolkit
{helpb xtregdhp}{col 12}Han-Philips (2010) Linear Dynamic Panel Data Regression
{helpb xtregam}{col 12}Amemiya Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregbem}{col 12}Between-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregbn}{col 12}Balestra-Nerlove Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregfem}{col 12}Fixed-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregmle}{col 12}Trevor Breusch MLE Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregrem}{col 12}Fuller-Battese GLS Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregsam}{col 12}Swamy-Arora Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregwem}{col 12}Within-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregwhm}{col 12}Wallace-Hussain Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtreghet}{col 12}MLE Random-Effects Multiplicative Heteroscedasticity Panel Data Regression
---------------------------------------------------------------------------
{bf:{err:* (4) (MLE) * Maximum Likelihood Estimation Regression Models:}}
{helpb mlereg}{col 12}MLE Econometric Regression Models: Stata Module Toolkit
{helpb mleregn}{col 12}MLE Normal Regression
{helpb mleregln}{col 12}MLE Log Normal Regression
{helpb mlereghn}{col 12}MLE Half Normal Regression
{helpb mlerege}{col 12}MLE Exponential Regression
{helpb mleregle}{col 12}MLE Log Exponential Regression
{helpb mleregg}{col 12}MLE Gamma Regression
{helpb mlereglg}{col 12}MLE Log Gamma Regression
{helpb mlereggg}{col 12}MLE Generalized Gamma Regression
{helpb mlereglgg}{col 12}MLE Log Generalized Gamma Regression
{helpb mleregb}{col 12}MLE Beta Regression
{helpb mleregev}{col 12}MLE Extreme Value Regression
{helpb mleregw}{col 12}MLE Weibull Regression
{helpb mlereglw}{col 12}MLE Log Weibull Regression
{helpb mleregilg}{col 12}MLE Inverse Log Gauss Regression
---------------------------------------------------------------------------
{bf:{err:* (5) * Autocorrelation Regression Models:}}
{helpb autoreg}{col 12}Autoregressive Least Squares Regression Models: Stata Module Toolkit
{helpb alsmle}{col 12}Beach-Mackinnon AR(1) Autoregressive Maximum Likelihood Estimation Regression
{helpb automle}{col 12}Beach-Mackinnon AR(1) Autoregressive Maximum Likelihood Estimation Regression
{helpb autopagan}{col 12}Pagan AR(p) Conditional Autoregressive Least Squares Regression
{helpb autoyw}{col 12}Yule-Walker AR(p) Unconditional Autoregressive Least Squares Regression
{helpb autopw}{col 12}Prais-Winsten AR(p) Autoregressive Least Squares Regression
{helpb autoco}{col 12}Cochrane-Orcutt AR(p) Autoregressive Least Squares Regression
{helpb autofair}{col 12}Fair AR(1) Autoregressive Least Squares Regression
---------------------------------------------------------------------------
{bf:{err:* (6) * Heteroscedasticity Regression Models:}}
{helpb hetdep}{col 12}MLE Dependent Variable Heteroscedasticity
{helpb hetmult}{col 12}MLE Multiplicative Heteroscedasticity Regression
{helpb hetstd}{col 12}MLE Standard Deviation Heteroscedasticity Regression
{helpb hetvar}{col 12}MLE Variance Deviation Heteroscedasticity Regression
{helpb glsreg}{col 12}Generalized Least Squares Regression
---------------------------------------------------------------------------
{bf:{err:* (7) * Non Normality Regression Models:}}
{helpb robgme}{col 12}MLE Robust Generalized Multivariate Error t Distribution
{helpb bcchreg}{col 12}Classical Box-Cox Multiplicative Heteroscedasticity Regression
{helpb bccreg}{col 12}Classical Box-Cox Regression
{helpb bcereg}{col 12}Extended Box-Cox Regression
---------------------------------------------------------------------------
{bf:{err:* (8) (NLS) * Nonlinear Least Squares Regression Regression Models:}}
{helpb autonls}{col 12}Non Linear Autoregressive Least Squares Regression
{helpb qregnls}{col 12}Non Linear Quantile Regression
---------------------------------------------------------------------------
{bf:{err:* (9) * Logit Regression Models:}}
{helpb logithetm}{col 12}Logit Multiplicative Heteroscedasticity Regression
{helpb mnlogit}{col 12}Multinomial Logit Regression
---------------------------------------------------------------------------
{bf:{err:* (10) * Probit Regression Models:}}
{helpb probithetm}{col 12}Probit Multiplicative Heteroscedasticity Regression
{helpb mnprobit}{col 12}Multinomial Probit Regression
---------------------------------------------------------------------------
{bf:{err:* (11) * Tobit Regression Models:}}
{helpb tobithetm}{col 12}Tobit Multiplicative Heteroscedasticity Regression 
---------------------------------------------------------------------------
{bf:{err:* Multicollinearity Tests:}}
{helpb lmcol}{col 12}OLS Multicollinearity Diagnostic Tests
{helpb fgtest}{col 12}Farrar-Glauber Multicollinearity Chi2, F, t Tests
{helpb theilr2}{col 12}Theil R2 Multicollinearity Effect
---------------------------------------------------------------------------
{psee}
{p_end}

