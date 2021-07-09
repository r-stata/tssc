{smcl}
{hline}
{cmd:help: {helpb ridgereg}}{space 50} {cmd:dialog:} {bf:{dialog ridgereg}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:ridgereg: OLS-Ridge Regression Models and Diagnostic Tests}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb ridgereg##01:Syntax}{p_end}
{p 5}{helpb ridgereg##02:Description}{p_end}
{p 5}{helpb ridgereg##03:Ridge Model Options}{p_end}
{p 5}{helpb ridgereg##04:Weight Options}{p_end}
{p 5}{helpb ridgereg##05:Weighted Variable Type Options}{p_end}
{p 5}{helpb ridgereg##06:Options}{p_end}
{p 5}{helpb ridgereg##07:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb ridgereg##08:Multicollinearity Diagnostic Tests}{p_end}
{p 5}{helpb ridgereg##09:Saved Results}{p_end}
{p 5}{helpb ridgereg##10:References}{p_end}

{p 1}*** {helpb ridgereg##11:Examples}{p_end}

{p 5}{helpb ridgereg##12:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{cmd:ridgereg} {depvar} {it:{help varlist:indepvars}} {ifin} , {opt model(orr|grr1|grr2|grr3)}{p_end} {p 3 5 6} 
{err: [} {opt weights(yh|yh2|abse|e2|le2|x|xi|x2|xi2)} {opt wv:ar(varname)}{p_end} 
{p 5 5 6} 
{opt kr(#)} {opt lmcol} {opt diag dn tolog} {opt mfx(lin, log)} {opt nocons:tant}{p_end} 
{p 5 5 6} 
{opt pred:ict(new_var)} {opt res:id(new_var)} {opt coll} {opt l:evel(#)} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:ridgereg} estimates (OLS-Ridge Regression models, and computes many tests, i.e., Mmulticollinearity Tests, and Model Selection Diagnostic Criteria,
and Marginal Effects and Elasticities.

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{marker 03}{bf:{err:{dlgtab:Ridge Model Options}}}

{p 3 6 2} {opt kr(#)} Ridge k value, must be in the range (0 < k < 1).{p_end}

{p 3 6 2}IF {bf:kr(0)} in {opt ridge(orr, grr1, grr2, grr3)}, the model will be an OLS regression.{p_end}

{col 3}{bf:model({err:{it:orr}})} : Ordinary Ridge Regression    [Judge,et al(1988,p.878) eq.21.4.2].
{col 3}{bf:model({err:{it:grr1}})}: Generalized Ridge Regression [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:model({err:{it:grr2}})}: Iterative Generalized Ridge  [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:model({err:{it:grr3}})}: Adaptive Generalized Ridge   [Strawderman(1978)].

{p 2 4 2}{cmd:ridgereg} estimates Ordinary Ridge regression as a multicollinearity remediation method.{p_end}
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
{p2coldent:{it:weights Options}}Description{p_end}

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

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{col 3}{opt pred:ict(new_var)}}Predicted values variable

{col 3}{opt res:id(new_var)}}Residuals values variable

{col 3}{opt mfx(lin, log)}{col 20}functional form: Linear model {cmd:(lin)}, or Log-Log model {cmd:(log)},
{col 20}to compute Marginal Effects and Elasticities
   - In Linear model: marginal effects are the coefficients (Bm),
        and elasticities are (Es = Bm X/Y).
   - In Log-Log model: elasticities are the coefficients (Es),
        and the marginal effects are (Bm = Es Y/X).
     - {opt mfx(log)} and {opt tolog} options must be combined, to transform variables to log form.

{col 3}{opt tolog}{col 20}Convert dependent and independent variables
{col 20}to LOG Form in the memory for Log-Log regression.
{col 20}{opt tolog} Transforms {depvar} and {indepvars}
{col 20}to Log Form without lost the original data variables

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

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

{p2colreset}{...}
{marker 08}{bf:{err:{dlgtab:Multicollinearity Diagnostic Tests}}}

{synopt:{opt lmcol}}Multicollinearity Diagnostic Tests{p_end}
	* Correlation Matrix
	* Multicollinearity Diagnostic Criteria
	* Farrar-Glauber Multicollinearity Tests
  	Ho: No Multicollinearity - Ha: Multicollinearity
	* (1) Farrar-Glauber Multicollinearity Chi2-Test
	* (2) Farrar-Glauber Multicollinearity F-Test
	* (3) Farrar-Glauber Multicollinearity t-Test
	* Multicollinearity Ranges
	* Determinant of |X'X|
	* Theil R2 Multicollinearity Effect:
	- Gleason-Staelin Q0
	- Heo Range  Q1

{cmd:- Multicollinearity Detection:}
{p 2 4 2}1. A high F statistic or R2 leads to reject the joint hypothesis that all of the coefficients are zero, but individual t-statistics are low.{p_end} 
{p 2 4 2}2. High simple correlation coefficients are sufficient but not necessary for multicollinearity.{p_end} 
{p 2 4 2}3. One can compute condition number. That is, the ratio of largest to smallest root of the matrix x'x. This may not always be useful as the standard errors of the estimates depend on the ratios of elements of characteristic vectors to the roots.{p_end} 

{cmd:- Multicollinearity Remediation:}
{p 2 4 2}1. Use prior information or restrictions on the coefficients. One clever way to do this was developed by Theil and Goldberger. See {helpb tgmixed}, and Theil(1971, pp 347-352).{p_end} 
{p 2 4 2}2. Use additional data sources. This does not mean more of the same. It means pooling cross section and time series.{p_end} 
{p 2 4 2}3. Transform the data. For example, inversion or differencing.{p_end} 
{p 2 4 2}4. Use a principal components estimator. This involves using a weighted average of the regressors, rather than all of the regressors.{p_end} 
{p 2 4 2}5. Another alternative regression technique is ridge regression. This involves putting extra weight on the main diagonal of X'X.{p_end} 
{p 2 4 2}6. Dropping troublesome RHS variables. This begs the question of specification error.{p_end}

{marker 09}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:ridgereg} saves the following in {cmd:e()}:

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

{marker 10}{bf:{err:{dlgtab:References}}}

{p 4 8 2}D. Belsley (1991)
{cmd: "Conditioning Diagnostics, Collinearity and Weak Data in Regression",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}D. Belsley, E. Kuh, and R. Welsch (1980)
{cmd: "Regression Diagnostics: Identifying Influential Data and Sources of Collinearity",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}Evagelia, Mitsaki (2011)
{cmd: "Ridge Regression Analysis of Collinear Data",}
{browse "http://www.stat-athens.aueb.gr/~jpan/diatrives/Mitsaki/chapter2.pdf"}

{p 4 8 2}Farrar, D. and Glauber, R. (1976)
{cmd: "Multicollinearity in Regression Analysis: the Problem Revisited",}
{it:Review of Economics and Statistics, 49}; 92-107.

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA}; 616-618.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Upper Saddle River, NJ: Prentice-Hall}; 387-388.

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

{p 4 8 2}Marquardt D.W. (1970)
{cmd: "Generalized Inverses, Ridge Regression, Biased Linear Estimation, and Nonlinear Estimation",}
{it:Technometrics, 12}; 591-612.

{p 4 8 2}Marquardt D.W. & R. Snee (1975)
{cmd: "Ridge Regression in Practice",}
{it:The American Statistician, 29}; 3-19.

{p 4 8 2}Pidot, George (1969)
{cmd: "A Principal Components Analysis of the Determinants of Local Government Fiscal Patterns",}
{it:Review of Economics and Statistics, Vol. 51}; 176-188.

{p 4 8 2}Rencher, Alvin C. (1998)
{cmd: "Multivariate Statistical Inference and Applications",}
{it:John Wiley & Sons, Inc., New York, USA}; 21-22.

{p 4 8 2}Strawderman, W. E. (1978)
{cmd: "Minimax Adaptive Generalized Ridge Regression Estimators",}
{it:Journal American Statistical Association, 73}; 623-627.

{p 4 8 2}Theil, Henri (1971)
{cmd: "Principles of Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.

{marker 11}{bf:{err:{dlgtab:Examples}}}

{p 2 4 2}(1) Example of Ridge regression models,{p_end}
{p 6 6 2}is decribed in: [Judge, et al(1988, p.882)], and also Theil R2 Multicollinearity Effect in: [Judge, et al(1988, p.872)], for Klein-Goldberger data.{p_end}

	{stata clear all}

	{stata sysuse ridgereg1.dta, clear}

	{stata ridgereg y x1 x2 x3 , model(orr) kr(0.5) mfx(lin) lmcol diag}

        {stata ridgereg y x1 x2 x3 , model(orr) kr(0.5) mfx(lin) weights(x) wvar(x1)}

	{stata ridgereg y x1 x2 x3 , model(grr1) mfx(lin)}

	{stata ridgereg y x1 x2 x3 , model(grr2) mfx(lin)}

	{stata ridgereg y x1 x2 x3 , model(grr3) mfx(lin)}

{p 2 4 4}(2) Example of Gleason-Staelin, and Heo Multicollinearity Ranges,{p_end}
{p 6 6 2}is decribed in: [Rencher(1998, pp. 20-22)].{p_end}

	{stata clear all}

	{stata sysuse ridgereg2.dta, clear}

	{stata ridgereg y x1 x2 x3 x4 x5 , model(orr) lmcol}

{p 2 4 4}(3) Example of Farrar-Glauber Multicollinearity Chi2, F, t Tests{p_end}
{p 6 6 2}is decribed in:[Evagelia(2011, chap.2, p.23)].{p_end}

	{stata clear all}

	{stata sysuse ridgereg3.dta, clear}

	{stata ridgereg y x1 x2 x3 x4 x5 x6 , model(orr) lmcol}
{hline}

. clear all
. sysuse ridgereg1.dta , clear
. ridgereg y x1 x2 x3 , model(orr) kr(0) diag lmcol mfx(lin)

==============================================================================
* (OLS) Ridge Regression - Ordinary Ridge Regression
==============================================================================
  y = x1 + x2 + x3
------------------------------------------------------------------------------
  Ridge k Value     =   0.00000     |   Ordinary Ridge Regression
------------------------------------------------------------------------------
  Sample Size       =          20
  Wald Test         =    322.1130   |   P-Value > Chi2(3)       =      0.0000
  F-Test            =    107.3710   |   P-Value > F(3 , 16)     =      0.0000
 (Buse 1973) R2     =      0.9527   |   Raw Moments R2          =      0.9971
 (Buse 1973) R2 Adj =      0.9438   |   Raw Moments R2 Adj      =      0.9965
  Root MSE (Sigma)  =      4.5272   |   Log Likelihood Function =    -56.3495
------------------------------------------------------------------------------
- R2h= 0.9527   R2h Adj= 0.9438  F-Test =  107.37 P-Value > F(3 , 16)  0.0000
- R2v= 0.9527   R2v Adj= 0.9438  F-Test =  107.37 P-Value > F(3 , 16)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   1.058783    .173579     6.10   0.000     .6908121    1.426754
          x2 |   .4522435   .6557569     0.69   0.500    -.9378991    1.842386
          x3 |   .1211505   1.087042     0.11   0.913    -2.183275    2.425576
       _cons |   8.132845   8.921103     0.91   0.375    -10.77905    27.04474
------------------------------------------------------------------------------

==============================================================================
* OLS Model Selection Diagnostic Criteria - Model= (orr)
==============================================================================
- Log Likelihood Function       LLF             =    -56.3495
- Akaike Final Prediction Error AIC             =     22.1330
- Schwarz Criterion             SC              =     25.6984
- Akaike Information Criterion  ln AIC          =      3.0971
- Schwarz Criterion             ln SC           =      3.2464
- Amemiya Prediction Criterion  FPE             =     23.5700
- Hannan-Quinn Criterion        HQ              =     22.7878
- Rice Criterion                Rice            =     23.4236
- Shibata Criterion             Shibata         =     21.3155
- Craven-Wahba Generalized Cross Validation GCV =     22.6941
------------------------------------------------------------------------------

==============================================================================
*** Multicollinearity Diagnostic Tests - Model= (orr)
==============================================================================

* Correlation Matrix
(obs=20)

             |       x1       x2       x3
-------------+---------------------------
          x1 |   1.0000
          x2 |   0.7185   1.0000
          x3 |   0.9152   0.6306   1.0000

* Multicollinearity Diagnostic Criteria
+-------------------------------------------------------------------------------+
|   Var |  Eigenval |  C_Number |   C_Index |       VIF |     1/VIF |   R2_xi,X |
|-------+-----------+-----------+-----------+-----------+-----------+-----------|
|    x1 |    2.5160 |    1.0000 |    1.0000 |    7.7349 |    0.1293 |    0.8707 |
|    x2 |    0.4081 |    6.1651 |    2.4830 |    2.0862 |    0.4793 |    0.5207 |
|    x3 |    0.0758 |   33.1767 |    5.7599 |    6.2127 |    0.1610 |    0.8390 |
+-------------------------------------------------------------------------------+

* Farrar-Glauber Multicollinearity Tests
  Ho: No Multicollinearity - Ha: Multicollinearity
--------------------------------------------------

* (1) Farrar-Glauber Multicollinearity Chi2-Test:
    Chi2 Test =   43.8210    P-Value > Chi2(3) 0.0000

* (2) Farrar-Glauber Multicollinearity F-Test:
+--------------------------------------------------------+
|   Variable |   F_Test |      DF1 |      DF2 |  P_Value |
|------------+----------+----------+----------+----------|
|         x1 |   57.246 |   17.000 |    3.000 |    0.003 |
|         x2 |    9.233 |   17.000 |    3.000 |    0.046 |
|         x3 |   44.308 |   17.000 |    3.000 |    0.005 |
+--------------------------------------------------------+

* (3) Farrar-Glauber Multicollinearity t-Test:
+-------------------------------------+
| Variable |     x1 |     x2 |     x3 |
|----------+--------+--------+--------|
|       x1 |      . |        |        |
|       x2 |  4.259 |      . |        |
|       x3 |  9.362 |  3.350 |      . |
+-------------------------------------+

* |X'X| Determinant:
  |X'X| = 0 Multicollinearity - |X'X| = 1 No Multicollinearity
  |X'X| Determinant:       (0 < 0.0779 < 1)
---------------------------------------------------------------

* Theil R2 Multicollinearity Effect:
  R2 = 0 No Multicollinearity - R2 = 1 Multicollinearity
     - Theil R2:           (0 < 0.8412 < 1)
---------------------------------------------------------------

* Multicollinearity Range:
  Q = 0 No Multicollinearity - Q = 1 Multicollinearity
     - Gleason-Staelin Q0: (0 < 0.7641 < 1)
    1- Heo Range Q1:       (0 < 0.8581 < 1)
    2- Heo Range Q2:       (0 < 0.8129 < 1)
    3- Heo Range Q3:       (0 < 0.7209 < 1)
    4- Heo Range Q4:       (0 < 0.7681 < 1)
    5- Heo Range Q5:       (0 < 0.8798 < 1)
    6- Heo Range Q6:       (0 < 0.7435 < 1)
------------------------------------------------------------------------------

* Marginal Effect - Elasticity (Model= orr): Linear *

+---------------------------------------------------------------------------+
|   Variable | Marginal_Effect(B) |     Elasticity(Es) |               Mean |
|------------+--------------------+--------------------+--------------------|
|         x1 |             1.0588 |             0.7683 |            52.5840 |
|         x2 |             0.4522 |             0.1106 |            17.7245 |
|         x3 |             0.1212 |             0.0088 |             5.2935 |
+---------------------------------------------------------------------------+
 Mean of Dependent Variable =     72.4650

{marker 12}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:RIDGEREG Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:RIDGEREG: "OLS-Ridge Regression Models and Diagnostic Tests"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457347.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457347.htm"}


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

