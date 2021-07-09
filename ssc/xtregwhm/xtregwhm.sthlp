{smcl}
{hline}
{cmd:help: {helpb xtregwhm}}{space 50} {cmd:dialog:} {bf:{dialog xtregwhm}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:xtregwhm: Wallace-Hussain Random-Effects Panel Data Regression}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb xtregwhm##01:Syntax}{p_end}
{p 5}{helpb xtregwhm##02:Description}{p_end}
{p 5}{helpb xtregwhm##03:Options}{p_end}
{p 5}{helpb xtregwhm##04:Ridge Options}{p_end}
{p 5}{helpb xtregwhm##05:Weight Options}{p_end}
{p 5}{helpb xtregwhm##06:Weighted Variable Type Options}{p_end}
{p 5}{helpb xtregwhm##07:Other Options}{p_end}
{p 5}{helpb xtregwhm##08:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb xtregwhm##09:Heteroscedasticity Tests}{p_end}
{p 5}{helpb xtregwhm##10:Saved Results}{p_end}
{p 5}{helpb xtregwhm##11:References}{p_end}

{p 1}*** {helpb xtregwhm##12:Examples}{p_end}

{p 5}{helpb xtregwhm##13:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt xtregwhm} {depvar} {indepvars} {ifin} , {bf:{err:id(var)}} {bf:{err:it(var)}}{p_end} 
{p 3 5 6} 
{err: [} {opt rid:ge(orr|grr1|grr2|grr3)} {opt kr(#)}{p_end} 
{p 4 5 6} 
{opt lmh:et} {opt diag} {opt mfx(lin|log)} {opt pred:ict(new_var)} {opt res:id(new_var)}{p_end} 
{p 4 5 6} 
{opt weights(yh|yh2|abse|e2|le2|x|xi|x2|xi2)} {opt wv:ar(varname)} {opt iter(#)}{p_end} 
{p 4 5 6} 
{opt nocons:tant} {opt coll dn tolog} {opt l:evel(#)} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:xtregwhm} estimates Wallace-Hussain Random-Effects Panel Data with Ridge and Weighted Regression, and calculate Panel Heteroscedasticity,
 Model Selection Diagnostic Criteria, and Marginal Effects and Elasticities{p_end}

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Options}}}

{col 3}* {cmd: {opt id(var)}{col 20}Cross Sections ID variable name}
{col 3}* {cmd: {opt it(var)}{col 20}Time Series ID variable name}

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Ridge Options}}}

{p 3 6 2} {opt kr(#)} Ridge k value, must be in the range (0 < k < 1).{p_end}

{p 3 6 2}IF {bf:kr(0)} in {opt ridge(orr, grr1, grr2, grr3)}, the model will be normal panel regression.{p_end}

{col 3}{bf:ridge({err:{it:orr}})} : Ordinary Ridge Regression    [Judge,et al(1988,p.878) eq.21.4.2].
{col 3}{bf:ridge({err:{it:grr1}})}: Generalized Ridge Regression [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:ridge({err:{it:grr2}})}: Iterative Generalized Ridge  [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:ridge({err:{it:grr3}})}: Adaptive Generalized Ridge   [Strawderman(1978)].

{p 2 4 2}{cmd:xtregwhm} estimates Ordinary Ridge regression as a multicollinearity remediation method.{p_end}
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

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Weight Options}}}

{synoptset 16}{...}
{synopt:{bf:wvar({err:{it:varname}})}}Weighted Variable Name{p_end}

{col 10}{cmd:xtregwhm} not like official Stata command {helpb xtreg} in weight option,
{col 10}{cmd:xtregwhm} can use large types of weighted regression options.
{col 10}{bf:wvar( )} {cmd:must be combined with:} {bf:weights(x, xi, x2, xi2)}"

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Weighted Variable Type Options}}}
{synoptset 16}{...}

{synopt:{bf:weights({err:{it:yh}})}}Yh - Predicted Value{p_end}
{synopt:{bf:weights({err:{it:yh2}})}}Yh^2 - Predicted Value Squared{p_end}
{synopt:{bf:weights({err:{it:abse}})}}abs(E) - Absolute Value of Residual{p_end}
{synopt:{bf:weights({err:{it:e2}})}}E^2 - Residual Squared{p_end}
{synopt:{bf:weights({err:{it:le2}})}}log(E^2) - Log Residual Squared{p_end}
{synopt:{bf:weights({err:{it:x}})}}(x) Variable{p_end}
{synopt:{bf:weights({err:{it:xi}})}}(1/x) Inverse Variable{p_end}
{synopt:{bf:weights({err:{it:x2}})}}(x^2) Squared Variable{p_end}
{synopt:{bf:weights({err:{it:xi2}})}}(1/x^2) Inverse Squared Variable{p_end}

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:Other Options}}}

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{col 20}{cmd:xtregwhm} not like official Stata command {helpb xtreg} in constant term option,
{col 20}{cmd:xtregwhm} can exclude constant term.
{col 20}{cmd:weights} option also can be used here.

{col 3}{opt dn}{col 20}Use (N) divisor instead of (N-K) for Degrees of Freedom (DF)

{col 3}{opt iter(#)}{col 20}number of iterations; Default is iter(100)

{col 3}{opt level(#)}{col 20}confidence intervals level. Default is level(95)

{col 3}{opt mfx(lin, log)}{col 20}functional form: Linear model {cmd:(lin)}, or Log-Log model {cmd:(log)},
{col 20}to compute Marginal Effects and Elasticities
   - In Linear model: marginal effects are the coefficients (Bm),
        and elasticities are (Es = Bm X/Y).
   - In Log-Log model: elasticities are the coefficients (Es),
        and the marginal effects are (Bm = Es Y/X).
   - {opt mfx(log)} and {opt tolog} options must be combined, to transform linear variables to log form.

{col 3}{opt tolog}{col 20}Convert dependent and independent variables
{col 20}to LOG Form in the memory for Log-Log regression.
{col 20}{opt tolog} Transforms {depvar} and {indepvars}
{col 20}to Log Form without lost the original data variables

{col 3}{opt pred:ict(new_variable)}{col 30}Predicted values variable

{col 3}{opt res:id(new_variable)}{col 30}Residuals values variable
{col 15} computed as Ue=Y-Yh ; that is known as combined residual: [Ue = U_i + E_it]
{col 15} overall error component is computed as: [E_it]
{col 15} see: {help xtreg postestimation##predict}

{p2colreset}{...}
{marker 08}{bf:{err:{dlgtab:Model Selection Diagnostic Criteria}}}

{synopt :{opt diag} Model Selection Diagnostic Criteria:}{p_end}
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

{p2colreset}{...}
{marker 09}{bf:{err:{dlgtab:Groupwise Panel Heteroscedasticity Tests}}}
{synopt :{opt lmh:et} Groupwise Panel Heteroscedasticity Tests:}{p_end}
	* Ho: Panel Homoscedasticity - Ha: Panel Groupwise Heteroscedasticity
	- Lagrange Multiplier LM Test
	- Likelihood Ratio LR Test
	- Wald Test

{p2colreset}{...}
{marker 10}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:xtregwhm} saves the following results in {cmd:e()}:

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

{err:*** Groupwise Heteroscedasticity Tests:}
{col 4}{cmd:e(lmhglm)}{col 20}Lagrange Multiplier LM Test
{col 4}{cmd:e(lmhglmp)}{col 20}Lagrange Multiplier LM Test P-Value
{col 4}{cmd:e(lmhglr)}{col 20}Likelihood Ratio LR Test
{col 4}{cmd:e(lmhglrp)}{col 20}Likelihood Ratio LR Test P-Value
{col 4}{cmd:e(lmhgw)}{col 20}Wald Test
{col 4}{cmd:e(lmhgwp)}{col 20}Wald Test P-Value

Matrixes
{col 4}{cmd:e(b)}{col 20}coefficient vector
{col 4}{cmd:e(V)}{col 20}variance-covariance matrix of the estimators
{col 4}{cmd:e(mfxlin)}{col 20}Marginal Effect and Elasticity in Lin Form
{col 4}{cmd:e(mfxlog)}{col 20}Marginal Effect and Elasticity in Log Form

{p2colreset}{...}
{marker 11}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Breusch, Trevor & Adrian Pagan (1980)
{cmd: "The Lagrange Multiplier Test and its Applications to Model Specification in Econometrics",}
{it:Review of Economic Studies 47}; 239-253.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Macmillan Publishing Company Inc., New York, USA.}.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2} Wallace, T. & A. Hussain (1969)
{cmd: "The Use of Error Components Models in Combining Cross-Section and Time-Series Data",}
{it:}Econometrica, 37; 55–72.

{p2colreset}{...}
{marker 12}{bf:{err:{dlgtab:Examples}}}

  {stata clear all}

  {stata sysuse xtregwhm.dta, clear}

  {stata db xtregwhm}

  {stata xtregwhm y x1 x2 , id(id) it(t) mfx(lin) predict(Yh) resid(Eu) diag lmh}

  {stata xtregwhm y x1 x2 , id(id) it(t) mfx(log) predict(Yh) resid(Eu) diag lmh tolog}

  {stata xtregwhm y x1 x2 , id(id) it(t) mfx(lin) ridge(orr) kr(0.5)}

  {stata xtregwhm y x1 x2 , id(id) it(t) mfx(lin) ridge(grr1)}

  {stata xtregwhm y x1 x2 , id(id) it(t) mfx(lin) ridge(grr2)}

  {stata xtregwhm y x1 x2 , id(id) it(t) mfx(lin) ridge(grr3)}

  {stata xtregwhm y x1 x2 , id(id) it(t) mfx(lin) ridge(grr1) weight(x) wvar(x1) diag lmh}
{hline}

. clear all
. sysuse xtregwhm.dta, clear
. xtregwhm y x1 x2 , id(id) it(t) mfx(lin) ridge(grr1) weight(x) wvar(x1) diag lmh

==============================================================================
* Wallace-Hussain Random-Effects Panel Data: Ridge and Weighted Regression
==============================================================================
  y = x1 + x2
------------------------------------------------------------------------------
* Weighted Regression Type: (X)     -   Variable: (x1) *
------------------------------------------------------------------------------
  Ridge k Value     =   0.07455     |   Generalized Ridge Regression
------------------------------------------------------------------------------
  Sample Size       =          49   |   Cross Sections Number   =           7
 Wald Test          =   1599.0836   |   P-Value > Chi2(2)       =      0.0000
 F-Test             =    799.5418   |   P-Value > F(2 , 40)     =      0.0000
 (Buse 1973) R2     =      0.7489   |   Raw Moments R2          =      0.9536
 (Buse 1973) R2 Adj =      0.6986   |   Raw Moments R2 Adj      =      0.9443
  Root MSE (Sigma)  =      8.6813   |   Log Likelihood Function =   -170.4536
------------------------------------------------------------------------------
- R2h= 0.5504   R2h Adj= 0.4604  F-Test =   28.15 P-Value > F(2 , 40)  0.0000
- R2v= 0.2651   R2v Adj= 0.1181  F-Test =    8.30 P-Value > F(2 , 40)  0.0010
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |  -.2201342   .0112158   -19.63   0.000    -.2428021   -.1974663
          x2 |   -1.02225   .0392573   -26.04   0.000    -1.101592   -.9429083
       _cons |    56.3973   .8890886    63.43   0.000     54.60039    58.19422
------------------------------------------------------------------------------

==============================================================================
* Panel Model Selection Diagnostic Criteria
==============================================================================
- Log Likelihood Function                   LLF            =   -170.4536
---------------------------------------------------------------------------
- Akaike Information Criterion              (1974) AIC     =     69.5371
- Akaike Information Criterion              (1973) Log AIC =      4.2419
---------------------------------------------------------------------------
- Schwarz Criterion                         (1978) SC      =     78.0762
- Schwarz Criterion                         (1978) Log SC  =      4.3577
---------------------------------------------------------------------------
- Amemiya Prediction Criterion              (1969) FPE     =     79.9799
- Hannan-Quinn Criterion                    (1979) HQ      =     72.6609
- Rice Criterion                            (1984) Rice    =     70.1076
- Shibata Criterion                         (1981) Shibata =     69.0564
- Craven-Wahba Generalized Cross Validation (1979) GCV     =     69.8094
------------------------------------------------------------------------------

==============================================================================
* Panel Groupwise Heteroscedasticity Tests
==============================================================================
  Ho: Panel Homoscedasticity - Ha: Panel Groupwise Heteroscedasticity

- Lagrange Multiplier LM Test     =   7.3373     P-Value > Chi2(6)   0.2908
- Likelihood Ratio LR Test        =   7.1253     P-Value > Chi2(6)   0.3094
- Wald Test                       =  12.4812     P-Value > Chi2(7)   0.0858
------------------------------------------------------------------------------

* Marginal Effect - Elasticity: Linear *

+---------------------------------------------------------------------------+
|   Variable | Marginal_Effect(B) |     Elasticity(Es) |               Mean |
|------------+--------------------+--------------------+--------------------|
|         x1 |            -0.2201 |            -0.2409 |            38.4362 |
|         x2 |            -1.0223 |            -0.4183 |            14.3749 |
+---------------------------------------------------------------------------+
 Mean of Dependent Variable =     35.1288

{p2colreset}{...}
{marker 13}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:XTREGWHM Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:XTREGWHM: "Wallace-Hussain Random-Effects Panel Data: Ridge and Weighted Regression"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457462.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457462.htm"}


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

{bf:{err:Panel Data Tests:}}

{bf:{err:* (1) * Autocorrelation Tests:}}
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
{bf:{err:* (2) * Heteroscedasticity Tests:}}
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
{bf:{err:* (3) * Non Normality Tests:}}
{helpb lmnxt}{col 12}Panel Data Non Normality Tests
{helpb lmnadxt}{col 12}Panel Data Non Normality Anderson-Darling Test
{helpb lmndhxt}{col 12}Panel Data Non Normality Doornik-Hansen Test
{helpb lmndpxt}{col 12}Panel Data Non Normality D'Agostino-Pearson Test
{helpb lmngryxt}{col 12}Panel Data Non Normality Geary Runs Test
{helpb lmnjbxt}{col 12}Panel Data Non Normality Jarque-Bera Test
{helpb lmnwhitext}{col 12}Panel Data Non Normality White Test
---------------------------------------------------------------------------
{bf:{err:* (4) * Panel Data Error Component Tests:}}
{helpb lmecxt}{col 12}Panel Data Error Component Tests
---------------------------------------------------------------------------
{bf:{err:* (5) * Panel Data Diagonal Covariance Matrix Test:}}
{helpb lmcovxt}{col 12}Panel Data Breusch-Pagan Diagonal Covariance Matrix LM Test
---------------------------------------------------------------------------
{bf:{err:* (6) * Panel Data ModeL Selection Diagnostic Criteria:}}
{helpb diagxt}{col 12}Panel Data ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (7) * Panel Data Specification Tests:}}
{helpb lmhausxt}{col 12}Panel Data Hausman Specification Test
{helpb resetxt}{col 12}Panel Data REgression Specification Error Tests (RESET)
---------------------------------------------------------------------------
{bf:{err:* (8) * Panel Data Identification Variables:}}
{helpb idt}{col 12}Create Identification Variables in Panel Data
{helpb xtidt}{col 12}Create Identification Variables in Panel Data
---------------------------------------------------------------------------

{psee}
{p_end}

