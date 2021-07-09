{smcl}
{hline}
{cmd:help: {helpb dlagif}}{space 50} {cmd:dialog:} {bf:{dialog dlagif}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: dlagif: Irving Fisher Arithmetic Distributed Lag Model}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb dlagif##01:Syntax}{p_end}
{p 5}{helpb dlagif##02:Description}{p_end}
{p 5}{helpb dlagif##03:Model}{p_end}
{p 5}{helpb dlagif##04:GMM Options}{p_end}
{p 5}{helpb dlagif##05:Ridge Options}{p_end}
{p 5}{helpb dlagif##06:Weight Options}{p_end}
{p 5}{helpb dlagif##07:Weighted Variable Type Options}{p_end}
{p 5}{helpb dlagif##08:Other Options}{p_end}
{p 5}{helpb dlagif##09:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb dlagif##10:Autocorrelation Tests}{p_end}
{p 5}{helpb dlagif##11:Heteroscedasticity Tests}{p_end}
{p 5}{helpb dlagif##12:Non Normality Tests}{p_end}
{p 5}{helpb dlagif##13:Saved Results}{p_end}
{p 5}{helpb dlagif##14:References}{p_end}

{p 1}*** {helpb dlagif##15:Examples}{p_end}

{p 5}{helpb dlagif##16:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{cmd:dlagif} {depvar} {it:{help varlist:indepvars}} {ifin} , {err: [} {opt model(als, arch, bcox, gls, gmm, ols, qreg, rreg)}{p_end} {p 5 5 6} 
{opt weights(yh|yh2|abse|e2|x|xi|x2|xi2)} {opt wv:ar(varname)} {opt tech:n(str)} {opt cond:ition}{p_end} 
{p 5 5 6} 
{opt rid:ge(orr|grr1|grr2|grr3)} {opt kr(#)} {opt het:cov(type)} {opt nol:ag} {opt li:st}{p_end} 
{p 5 5 6} 
{opt lma:uto} {opt lmh:et} {opt lmn:orm} {opt tune(#)} {opt diag dn tolog lad test}{p_end} 
{p 5 5 6} 
{opt mfx(lin, log)} {opt nocons:tant} {opt lag(#)} {opt ar(#)} {opt hetc:ov(gmm_type)}{p_end} 
{p 5 5 6} 
{opt pred:ict(new_var)} {opt res:id(new_var)} {opt  two:step} {opt quan:tile(#)} {opt l:evel(#)} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:dlagif} estimates Irving Fisher Distributed Lag Model via
(ALS - ARCH - Box-Cox - GLS - GMM - OLS - QREG - RREG - Ridge) Regression models.

{pstd}
{cmd:dlagif} can compute:

{p 2 5 5}1- Autocorrelation, Heteroscedasticity, and Non Normality Tests.{p_end}

{p 2 5 5}2- Model Selection Diagnostic Criteria.{p_end}

{p 2 5 5}3- Marginal effects and elasticities in long run.{p_end}

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
{synopt:{opt als}}Autoregressive Least Squares (ALS){p_end}
{synopt:{opt arch}}Autoregressive Conditional Heteroskedasticity (ARCH){p_end}
{synopt:{opt bcox}}Box-Cox Regression Model (Box-Cox){p_end}
{synopt:{opt gls}}Generalized Least Squares (GLS){p_end}
{synopt:{opt gmm}}Generalized Method of Moments (GMM){p_end}
{synopt:{opt ols}}Ordinary Least Squares (OLS){p_end}
{synopt:{opt qreg}}Quantile Regression (QREG){p_end}
{synopt:{opt rreg}}Robust   Regression (RREG){p_end}

{marker 04}{bf:{err:{dlgtab:GMM Options}}}

{synoptset 16}{...}
{p2coldent:{it:hetcov Options}}Description{p_end}

{synopt:{bf:hetcov({err:{it:white}})}}White Method{p_end}
{synopt:{bf:hetcov({err:{it:bart}})}}Bartlett Method{p_end}
{synopt:{bf:hetcov({err:{it:crag}})}}Cragg (1983) Auxiliary Variables Method{p_end}
{synopt:{bf:hetcov({err:{it:dan}})}}Daniell Method{p_end}
{synopt:{bf:hetcov({err:{it:hdun}})}}Horn-Duncan (1975) Method{p_end}
{synopt:{bf:hetcov({err:{it:hink}})}}Hinkley (1977) Method{p_end}
{synopt:{bf:hetcov({err:{it:jack}})}}Jackknife Mackinnon-White (1985) Method{p_end}
{synopt:{bf:hetcov({err:{it:nwest}})}}Newey-West Method{p_end}
{synopt:{bf:hetcov({err:{it:parzen}})}}Parzen Method{p_end}
{synopt:{bf:hetcov({err:{it:quad}})}}Quadratic Spectral Method{p_end}
{synopt:{bf:hetcov({err:{it:tent}})}}Tent Method{p_end}
{synopt:{bf:hetcov({err:{it:trunc}})}}Truncated Method{p_end}
{synopt:{bf:hetcov({err:{it:tukey}})}}Tukey Method{p_end}
{synopt:{bf:hetcov({err:{it:tukeym}})}}Tukey-Hamming Method{p_end}
{synopt:{bf:hetcov({err:{it:tukeyn}})}}Tukey-Hanning Method{p_end}

{marker 05}{bf:{err:{dlgtab:Ridge Options}}}

{p 3 6 2} {opt kr(#)} Ridge k value, must be in the range (0 < k < 1).{p_end}

{p 3 6 2}IF {bf:kr(0)} in {opt ridge(orr, grr1, grr2, grr3)}, the model will be an OLS regression.{p_end}

{col 3}{bf:ridge({err:{it:orr}})} : Ordinary Ridge Regression    [Judge,et al(1988,p.878) eq.21.4.2].
{col 3}{bf:ridge({err:{it:grr1}})}: Generalized Ridge Regression [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:ridge({err:{it:grr2}})}: Iterative Generalized Ridge  [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:ridge({err:{it:grr3}})}: Adaptive Generalized Ridge   [Strawderman(1978)].

{p 2 4 2}{cmd:dlagif} estimates Ordinary Ridge regression as a multicollinearity remediation method.{p_end}
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

{marker 06}{bf:{err:{dlgtab:Weight Options}}}

{synoptset 16}{...}
{synopt:{bf:wvar({err:{it:varname}})}}Weighted Variable Name{p_end}

{marker 07}{bf:{err:{dlgtab:Weighted Variable Type Options}}}

{synoptset 16}{...}
{p2coldent:{it:weights Options}}Description{p_end}

{synopt:{bf:weights({err:{it:yh}})}}Yh - Predicted Value{p_end}
{synopt:{bf:weights({err:{it:yh2}})}}Yh^2 - Predicted Value Squared{p_end}
{synopt:{bf:weights({err:{it:abse}})}}abs(E) - Absolute Value of Residual{p_end}
{synopt:{bf:weights({err:{it:e2}})}}E^2 - Residual Squared{p_end}
{synopt:{bf:weights({err:{it:x}})}}(x) Variable{p_end}
{synopt:{bf:weights({err:{it:xi}})}}(1/x) Inverse Variable{p_end}
{synopt:{bf:weights({err:{it:x2}})}}(x^2) Squared Variable{p_end}
{synopt:{bf:weights({err:{it:xi2}})}}(1/x^2) Inverse Squared Variable{p_end}

{marker 08}{bf:{err:{dlgtab:Other Options}}}
{synoptset 16}{...}
{synopt:{opt lamp( )}}Transformation Type in {bf:model({err:{it:bcox}})}{p_end}
{synopt:{bf:lamp({err:{it:lhs}})}}Power Transformations on (LHS) Left Hand Side Only; default{p_end}
{synopt:{bf:lamp({err:{it:rhs}})}}Power Transformations on (RHS) Right Hand Side Only{p_end}
{synopt:{bf:lamp({err:{it:alls}})}}Power Transformations on both (LHS) & (RHS) are the Same{p_end}
{synopt:{bf:lamp({err:{it:alld}})}}Power Transformations on both (LHS) & (RHS) are Different{p_end}

{col 3}{opt lag(#)}{col 20}Lag Length Order of Arithmetic Distributed Lag Model; default (2)

{col 3}{opt ar(#)}{col 20}Lag Order for Model Tests; default (1)

{col 3}{opt cond:ition}{col 20}use conditional MLE instead of full MLE with {bf:model({err:{it:als}})}

{col 3}{opt dn}{col 20}Use (N) divisor instead of (N-K) for Degrees of Freedom (DF)

{col 3}{opt quan:tile(#)}{col 20}Quantile Value

{col 3}{opt tune(#)}{col 20}use # as the biweight tuning constant;
{col 20}default is tune(7) with {bf:model({err:{it:qreg}})}

{col 3}{opt nol:ag}{col 20}Use Independent Variables in current period X(t), instead of lag X(t-1)

{col 3}{opt li:st}{col 20}Print Converted Variables according to Arithmetic Distributed Lag

{col 3}{opt two:step}{col 20}Two-Step estimation, stop after first iteration, same as iter(1)

{col 3}{opt iter(#)}{col 20}number of iterations; Default is iter(50)

{col 3}{opt tol:erance(#)}{col 20}tolerance for coefficient vector; Default is tol(0.00001)

{col 3}{opt test}{col 20}Display ALL lma, lmh, lmn tests

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

{synopt:{opt tech:n(name)}}Maximization of Log Likelihood Function (LLF) Technique Algorithm{p_end}
{p 22}{bf:techn({err:{it:nr}})} Newton-Raphson (NR); default{p_end}
{p 22}{bf:techn({err:{it:bhhh}})} Berndt-Hall-Hall-Hausman (BHHH){p_end}
{p 22}{bf:techn({err:{it:dfp}})} Davidon-Fletcher-Powell (DFP){p_end}
{p 22}{bf:techn({err:{it:bfgs}})} Broyden-Fletcher-Goldfarb-Shanno (BFGS){p_end}

{p2colreset}{...}
{marker 09}{bf:{err:{dlgtab:Model Selection Diagnostic Criteria}}}
	* Model Selection Diagnostic Criteria
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
{marker 10}{bf:{err:{dlgtab:Autocorrelation Tests}}}
 	Ho: No Autocorrelation - Ha: Autocorrelation
	- Breusch-Godfrey LM Test (drop 1 obs)
	- Breusch-Godfrey LM Test (keep 1 obs)
	- Breusch-Pagan-Godfrey LM Test

{p2colreset}{...}
{marker 11}{bf:{err:{dlgtab:Heteroscedasticity Tests}}}
	Ho: Homoscedasticity - Ha: Heteroscedasticity
	- Engle LM ARCH Test
	- Hall-Pagan LM Test:      E2 = Yh
	- Hall-Pagan LM Test:      E2 = Yh2
	- Hall-Pagan LM Test:      E2 = LYh2

{p2colreset}{...}
{marker 12}{bf:{err:{dlgtab:Non Normality Tests}}}
 	Ho: Normality - Ha: Non Normality
	- Jarque-Bera LM Test
	- White IM Test
	- Geary LM Test

{marker 13}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:dlagif} saves the following in {cmd:e()}:

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

{err:*** Autocorrelation Tests:}
{col 4}{cmd:e(lmabgd#)}{col 20}Breusch-Godfrey LM Test (drop i obs)
{col 4}{cmd:e(lmabgdp#)}{col 20}Breusch-Godfrey LM Test (drop i obs) P-Value
{col 4}{cmd:e(lmabgk#)}{col 20}Breusch-Godfrey LM Test (keep i obs)
{col 4}{cmd:e(lmabgkp#)}{col 20}Breusch-Godfrey LM Test (keep i obs) P-Value
{col 4}{cmd:e(lmabpg#)}{col 20}Breusch-Pagan-Godfrey LM Test AR(i)
{col 4}{cmd:e(lmabpgp#)}{col 20}Breusch-Pagan-Godfrey LM Test AR(i) P-Value

{err:*** Heteroscedasticity Tests:}
{col 4}{cmd:e(lmharch)}{col 20}Engle LM ARCH Test AR(i)
{col 4}{cmd:e(lmharchp)}{col 20}Engle LM ARCH Test AR(i) P-Value
{col 4}{cmd:e(lmhhp1)}{col 20}Hall-Pagan LM Test
{col 4}{cmd:e(lmhhp1p)}{col 20}Hall-Pagan LM Test P-Value
{col 4}{cmd:e(lmhhp2)}{col 20}Hall-Pagan LM Test
{col 4}{cmd:e(lmhhp2p)}{col 20}Hall-Pagan LM Test P-Value
{col 4}{cmd:e(lmhhp3)}{col 20}Hall-Pagan LM Test
{col 4}{cmd:e(lmhhp3p)}{col 20}Hall-Pagan LM Test P-Value

{err:*** Non Normality Tests:}
{col 4}{cmd:e(lmnjb)}{col 20}Jarque-Bera LM Test
{col 4}{cmd:e(lmnjbp)}{col 20}Jarque-Bera LM Test P-Value
{col 4}{cmd:e(lmnw)}{col 20}White IM Test
{col 4}{cmd:e(lmnwp)}{col 20}White IM Test P-Value
{col 4}{cmd:e(lmng)}{col 20}Geary LM Test
{col 4}{cmd:e(lmngp)}{col 20}Geary LM Test P-Value

{marker 14}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Breusch, Trevor (1978)
{cmd: "Testing for Autocorrelation in Dynamic Linear Models",}
{it:Aust. Econ. Papers, Vol. 17}; 334-355.

{p 4 8 2}Breusch, Trevor & Adrian Pagan (1980)
{cmd: "The Lagrange Multiplier Test and its Applications to Model Specification in Econometrics",}
{it:Review of Economic Studies 47}; 239-253.

{p 4 8 2}C.M. Jarque  & A.K. Bera (1987)
{cmd: "A Test for Normality of Observations and Regression Residuals"}
{it:International Statistical Review}, Vol. 55; 163-172.

{p 4 8 2}Durbin, James (1970a)
{cmd: "Testing for Serial Correlation in Least-Squares Regression When Some of the Regressors are Lagged Dependent Variables",}
{it:Econometrica, vol.38, no.3, May}; 410-421.

{p 4 8 2}Durbin, James (1970b)
{cmd: "An Alternative to the Bounds Test for Testing for Serial Correlation in Least Square Regression",}
{it:Econometrica, Vol. 38, No. 2, May}; 422-429.

{p 4 8 2}Engle, Robert (1982)
{cmd: "Autoregressive Conditional Heteroscedasticity with Estimates of Variance of United Kingdom Inflation"}
{it:Econometrica, 50(4), July, 1982}; 987-1007.

{p 4 8 2}Evagelia, Mitsaki (2011)
{cmd: "Ridge Regression Analysis of Collinear Data",}
{browse "http://www.stat-athens.aueb.gr/~jpan/diatrives/Mitsaki/chapter2.pdf"}

{p 4 8 2}Geary R.C. (1947)
{cmd: "Testing for Normality"} {it:Biometrika, Vol. 34}; 209-242.

{p 4 8 2}Geary R.C. (1970)
{cmd: "Relative Efficiency of Count of Sign Changes for Assessing Residuals Autoregression in Least Squares Regression"}
{it:Biometrika, Vol. 57}; 123-127.

{p 4 8 2}Godfrey, L. (1978)
{cmd: "Testing for Higher Order Serial Correlation in Regression Equations when the Regressors Include Lagged Dependent Variables",}
{it:Econometrica, Vol., 46}; 1303-1310.

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA}; 616-618.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Upper Saddle River, NJ: Prentice-Hall}; 387-388.

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
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 615.

{p 4 8 2}Kmenta, Jan (1986)
{cmd: "Elements of Econometrics",}
{it: 2nd ed., Macmillan Publishing Company, Inc., New York, USA}; 718.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}; 358-366.

{p 4 8 2}Marquardt D.W. (1970)
{cmd: "Generalized Inverses, Ridge Regression, Biased Linear Estimation, and Nonlinear Estimation",}
{it:Technometrics, 12}; 591-612.

{p 4 8 2}Marquardt D.W. & R. Snee (1975)
{cmd: "Ridge Regression in Practice",}
{it:The American Statistician, 29}; 3-19.

{p 4 8 2} Shehata, Emad Abd Elmessih (1996)
{cmd:"Supply Response for Some Field Crops",}
{it:Cairo University - Faculty of Agriculture - Department of Economics - Egypt}.

{p 4 8 2}Strawderman, W. E. (1978)
{cmd: "Minimax Adaptive Generalized Ridge Regression Estimators",}
{it:Journal American Statistical Association, 73}; 623-627.

{p 4 8 2}Theil, Henri (1971)
{cmd: "Principles of Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}White, Halbert (1980)
{cmd: "A Heteroskedasticity-Consistent Covariance Matrix Estimator and a Direct Test for Heteroskedasticity",}
{it:Econometrica, 48}; 817-838.

{p 4 8 2}William E. Griffiths, R. Carter Hill and George G. Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.  

{marker 15}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse dlagif.dta , clear}

 {stata db dlagif}

{bf:{err:* (1) Ordinary Least Squares (OLS)}}
 {stata dlagif y x z , model(ols) mfx(lin) test}
 {stata dlagif y x z , model(ols) mfx(log) test tolog}
 {stata dlagif y x z , model(ols) lag(1) diag}
 {stata dlagif y x z , model(ols) lag(2) diag}
 {stata dlagif y x z , model(ols) lag(3) diag}
{hline}

{bf:{err:* (2) Autoregressive Least Squares (ALS)}}
 {stata dlagif y x z , model(als) mfx(lin) test}
 {stata dlagif y x z , model(als) mfx(lin) test ar(2)}
 {stata dlagif y x z , model(als) mfx(log) test tolog}
 {stata dlagif y x z , model(als) mfx(lin) test twostep}
{hline}

{bf:{err:* (3) Autoregressive Conditional Heteroskedasticity (ARCH)}}
 {stata dlagif y x z , model(arch) mfx(lin) test}
 {stata dlagif y x z , model(arch) mfx(lin) test ar(2)}
 {stata dlagif y x z , model(arch) mfx(log) test tolog}
{hline}

{bf:{err:* (4) Box-Cox Regression Model (Box-Cox)}}
 {stata dlagif y x z , model(bcox) mfx(lin) test}
{hline}

{bf:{err:* (5) Generalized Least Squares (GLS)}}
 {stata dlagif y x z , model(gls) wvar(x) mfx(lin) test}
 {stata dlagif y x z , model(gls) wvar(x) mfx(log) test tolog}
{hline}

{bf:{err:* (6) Quantile Regression (QREG)}}
 {stata dlagif y x z , model(qreg) mfx(lin) test}
 {stata dlagif y x z , model(qreg) mfx(log) test tolog}
{hline}

{bf:{err:* (7) Robust Regression (RREG)}}
 {stata dlagif y x z , model(qreg) mfx(lin) test}
 {stata dlagif y x z , model(qreg) mfx(log) test tolog}
{hline}

{bf:{err:* (8) Generalized Method of Moments (GMM)}}
White:              {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(white)}
Bartlett:           {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(bart)}
Cragg:              {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(crag)}
Daniell:            {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(dan)}
Horn-Duncan:        {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(hdun)}
Hinkley:            {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(hink)}
Jackknife:          {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(jack)}
Newey-West:         {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(nwest)}
Parzen:             {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(parzen)}
Quadratic Spectral: {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(quad)}
Tent:               {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(tent)}
Truncated:          {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(trunc)}
Tukey:              {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(tukey)}
Tukey-Hamming:      {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(tukeym)}
Tukey-Hanning:      {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(tukeyn)}
{hline}

{bf:{err:* (9) Weighted OLS & GMM Regression}}
 {stata dlagif y x z , mfx(lin) test model(ols) weights(yh)}
 {stata dlagif y x z , mfx(lin) test model(ols) weights(yh2)}
 {stata dlagif y x z , mfx(lin) test model(ols) weights(abse)}
 {stata dlagif y x z , mfx(lin) test model(ols) weights(e2)}
 {stata dlagif y x z , mfx(lin) test model(ols) weights(x) wvar(x)}
 {stata dlagif y x z , mfx(lin) test model(ols) weights(xi) wvar(x)}
 {stata dlagif y x z , mfx(lin) test model(ols) weights(x2) wvar(x)}
 {stata dlagif y x z , mfx(lin) test model(ols) weights(xi2) wvar(x)}

 {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(white) weights(yh)}
 {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(white) weights(x) wvar(x)}
{hline}

{bf:{err:* (10) Ridge Regression}}
 {stata dlagif y x z , mfx(lin) test model(ols) ridge(orr) kr(0.5)}
 {stata dlagif y x z , mfx(lin) test model(ols) ridge(orr) kr(0.5) weights(x) wvar(x)}
 {stata dlagif y x z , mfx(lin) test model(ols) ridge(grr1)}
 {stata dlagif y x z , mfx(lin) test model(ols) ridge(grr2)}
 {stata dlagif y x z , mfx(lin) test model(ols) ridge(grr3)}

 {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(white) ridge(orr) kr(0.5)}
 {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(white) ridge(orr) kr(0.5) weights(x) wvar(x)}
 {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(white) ridge(grr1)}
 {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(white) ridge(grr2)}
 {stata dlagif y x z , mfx(lin) test model(gmm) hetcov(white) ridge(grr3)}
{hline}

. clear all
. sysuse dlagif.dta , clear
. dlagif y x z , model(ols) test mfx(lin)

==============================================================================
           *** Irving Fisher Arithmetic Distributed Lag Model ***
==============================================================================
 *** Ordinary Least Squares (OLS) ***

 y = [+ 2*L1.x + 1*L2.x  + 2*L1.z + 1*L2.z]/3 

------------------------------------------------------------------------------
 Sample Size        =          33   |   Sample Range            =      4 - 36
 Wald Test          =   1024.1447   |   P-Value > Chi2(2)       =      0.0000
 F-Test             =    512.0724   |   P-Value > F(2 , 30)     =      0.0000
 R2  (R-Squared)    =      0.9715   |   Raw Moments R2          =      0.9999
 R2a (Adjusted R2)  =      0.9696   |   Raw Moments R2 Adj      =      0.9999
 Root MSE (Sigma)   =      4.0297   |   Log Likelihood Function =    -91.2443
------------------------------------------------------------------------------
- R2h= 0.9715   R2h Adj= 0.9696  F-Test =  512.07 P-Value > F(2 , 30)  0.0000
- R2v= 0.9715   R2v Adj= 0.9696  F-Test =  512.07 P-Value > F(2 , 30)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
           x |   2.037683   .2810455     7.25   0.000     1.463712    2.611655
           z |  -1.043649   .5333626    -1.96   0.060    -2.132921     .045623
       _cons |   70.79627   10.57861     6.69   0.000     49.19185    92.40068
------------------------------------------------------------------------------

==============================================================================
*** Model Selection Diagnostic Criteria - (Model= OLS)
==============================================================================
- Log Likelihood Function                   LLF            =    -91.2443
---------------------------------------------------------------------------
- Akaike Information Criterion              (1974) AIC     =     17.7059
- Akaike Information Criterion              (1973) Log AIC =      2.8739
---------------------------------------------------------------------------
- Schwarz Criterion                         (1978) SC      =     20.2863
- Schwarz Criterion                         (1978) Log SC  =      3.0099
---------------------------------------------------------------------------
- Amemiya Prediction Criterion              (1969) FPE     =     17.7148
- Hannan-Quinn Criterion                    (1979) HQ      =     18.5353
- Rice Criterion                            (1984) Rice    =     18.0429
- Shibata Criterion                         (1981) Shibata =     17.4464
- Craven-Wahba Generalized Cross Validation (1979) GCV     =     17.8625
------------------------------------------------------------------------------

==============================================================================
*** Autocorrelation Tests - (Model= OLS)
------------------------------------------------------------------------------
 Ho: No Autocorrelation - Ha: Autocorrelation
------------------------------------------------------------------------------
- Rho Value for Order(1)               AR(1)=  0.4993
- Breusch-Godfrey LM Test (drop 1 obs) AR(1)= 10.2208  P-Value >Chi2(1) 0.0014
- Breusch-Godfrey LM Test (keep 1 obs) AR(1)=  8.7690  P-Value >Chi2(1) 0.0031
- Breusch-Pagan-Godfrey LM Test        AR(1)=  2.9613  P-Value >Chi2(1) 0.0853
------------------------------------------------------------------------------

==============================================================================
*** Heteroscedasticity Tests - (Model= OLS)
------------------------------------------------------------------------------
 Ho: Homoscedasticity - Ha: Heteroscedasticity
------------------------------------------------------------------------------
- Engle LM ARCH Test AR(1) E2=E2_1-E2_1=   0.2307    P-Value > Chi2(1)  0.6310
------------------------------------------------------------------------------
- Hall-Pagan LM Test:      E2 = Yh     =   0.6349    P-Value > Chi2(1)  0.4256
- Hall-Pagan LM Test:      E2 = Yh2    =   0.6864    P-Value > Chi2(1)  0.4074
- Hall-Pagan LM Test:      E2 = LYh2   =   0.5835    P-Value > Chi2(1)  0.4449
------------------------------------------------------------------------------
- Harvey LM Test:       LogE2 = X      =   6.0460    P-Value > Chi2(2)  0.0487
- White Test -Koenker(R2): E2 = X      =   1.0200    P-Value > Chi2(2)  0.6005
- White Test -B-P-G (SSR): E2 = X      =   1.6479    P-Value > Chi2(2)  0.4387
------------------------------------------------------------------------------

==============================================================================
*** Non Normality Tests - (Model= OLS)
------------------------------------------------------------------------------
 Ho: Normality - Ha: Non Normality
------------------------------------------------------------------------------
- Jarque-Bera LM Test                  =   5.3428     P-Value > Chi2(2) 0.0692
- White IM Test                        =   6.0750     P-Value > Chi2(2) 0.0480
- Geary LM Test                        =  -3.0042     P-Value > Chi2(2) 0.2227
------------------------------------------------------------------------------

* Marginal Effect - Elasticity - Standardized Beta (Model= OLS): Linear *

+--------------------------------------------------------------------+
|       Variable |     Margin | Elasticity |    St_Beta |       Mean |
|----------------+------------+------------+------------+------------|
|              x |     2.0377 |     1.1280 |     1.3406 |   193.6451 |
|              z |    -1.0436 |    -0.3304 |    -0.3618 |   110.7479 |
+--------------------------------------------------------------------+
 Mean of Dependent Variable =    349.8016

{marker 16}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:DLAGIF Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2016)}{p_end}
{p 1 10 1}{cmd:DLAGIF: "Stata Module to Estimate Irving Fisher Arithmetic Distributed Lag Model"}{p_end}

{title:Online Help:}

{hline 83}
{bf:{err:*** Distributed Lag Models:}}
{helpb almon1}{col 9}Shirley Almon Polynomial Distributed Lag Model{col 72}(ALMON1)
{helpb almon}{col 9}Shirley Almon Generalized Polynomial Distributed Lag Model{col 72}(ALMON)
{helpb dlagaj}{col 9}Alt France-Jan Tinbergen Distributed Lag Model{col 72}(DLAGAJ)
{helpb dlagdj}{col 9}Dale Jorgenson Rational Distributed Lag Model{col 72}(DLAGDJ)
{helpb dlagfd}{col 9}Frank De Leeuw Inverted V Distributed Lag Model{col 72}(DLAGFD)
{helpb dlagif}{col 9}Irving Fisher Arithmetic Distributed Lag Model{col 72}(DLAGIF)
{helpb dlagmf}{col 9}Milton Fridman Partial Adjustment-Adaptive Expectations
{col 9}Distributed Lag Model{col 72}(DLAGMF)
{helpb dlagmn}{col 9}Marc Nerlove Partial Adjustment Distributed Lag Model{col 72}(DLAGMN)
{helpb dlagrs}{col 9}Robert Solow Pascal Triangle Distributed Lag Model{col 72}(DLAGRS)
{helpb dlagrw}{col 9}Rudolf Wolffram Segmenting Partial Adjustment Distributed Lag{col 72}(DLAGRW)
{helpb dlagtq}{col 9}Tweeten-Quance Partial Adjustment Distributed Lag Model{col 72}(DLAGTQ)
{hline 83}
{bf:{err:*** Demand System Models:}}
{helpb dles}{col 9}Linear Expenditure System (LES){col 72}(DLES)
{helpb deles}{col 9}Extended Linear Expenditure System (ELES){col 72}(DELES)
{helpb dqes}{col 9}Quadratic Expenditure System (QES){col 72}(DQES)
{helpb drot}{col 9}Rotterdam Demand System{col 72}(DROT)
{helpb droti}{col 9}Inverse Rotterdam Demand System{col 72}(DROTI)
{helpb daidsla}{col 9}Linear Approximation Almost Ideal Demand System (AIDS-LA){col 72}(DAIDSLA)
{helpb daidsfd}{col 9}First Difference Almost Ideal Demand System (AIDS-FD){col 72}(DAIDSFD)
{helpb daidsi}{col 9}Inverse Almost Ideal Demand System(AIDS-I) {col 72}(DAIDSI)
{helpb darmin}{col 9}Primal Armington Demand System{col 72}(DARMIN)
{helpb dengel}{col 9}Engel Demand System{col 72}(DENGEL)
{helpb dgads}{col 9}Generalized AddiLog Demand System (GADS){col 72}(DGADS)
{helpb dtlog}{col 9}Transcendental Logarithmic Demand System{col 72}(DTLOG)
{helpb dwork}{col 9}Working Demand System{col 72}(DWORK)
{hline 83}
{helpb pfm}{col 9}Production Function Models{col 72}(PFM)
{helpb pfmnl}{col 9}Non-Linear Production Function Models{col 72}(PFMNL)
{hline 83}
{helpb cfm}{col 9}Cost Function Models{col 72}(CFM)
{helpb costreg}{col 9}Quadratic and Cubic Cost Functions{col 72}(COSTREG)
{hline 83}
{helpb ffm}{col 9}Profit Function Models{col 72}(FFM)
{hline 83}
{helpb iic}{col 9}Investment Indicators Criteria{col 72}(IIC)
{hline 83}
{helpb index}{col 9}Index Numbers{col 72}(INDEX)
{hline 83}
{helpb iot}{col 9}Leontief Input - Output Table{col 72}(IOT)
{hline 83}
{helpb mef}{col 9}Marketing Efficiency Models{col 72}(MEF)
{hline 83}
{helpb pam}{col 9}Policy Analysis Matrix{col 72}(PAM)
{helpb pem}{col 9}Partial Equilibrium Model{col 72}(PEM)
{hline 83}
{bf:{err:*** Financial Analysis Models:}}
{helpb fam}{col 9}Financial Analysis Models{col 72}(FAM)
{helpb fbep}{col 9}Financial Break-Even Point Analysis (BEP){col 72}(FBEP)
{helpb fxbcr}{col 9}Benefit-Cost Ratio (BCR){col 72}(FXBCR)
{helpb fxirr}{col 9}Internal Rate of Return (IRR-XIRR){col 72}(FXIRR)
{helpb fxmirr}{col 9}Modified Internal Rate of Return (MIRR-XMIRR){col 72}(FXMIRR)
{helpb fxnfv}{col 9}Net Future Value (NFV-XNFV){col 72}(FXNFV)
{helpb fxnpv}{col 9}Net Present Value (NPV-XNPV){col 72}(FXNPV)
{helpb fxpp}{col 9}Payback Period (PP){col 72}(FXPP)
{hline 83}
{bf:{err:*** Black-Scholes European Option Pricing:}}
{helpb bsopm}{col 9}Black-Scholes European Option Pricing Model{col 72}(BSOPM)
{helpb imvol}{col 9}Implied Volatility Black-Scholes European Option Pricing Model{col 72}(IMVOL)
{hline 83}
{bf:{err:*** Trade Models:}}
{helpb wtm}{col 9}World Trade Models{col 72}(WTM)
{helpb wtic}{col 9}World Trade Indicators Criteria{col 72}(WTIC)
{helpb wtrca}{col 9}World Trade Revealed Comparative Advantage{col 72}(WTRCA)
{helpb wtrgc}{col 9}World Trade Regional Geographical Concentration{col 72}(WTRGC)
{helpb wtsgc}{col 9}World Trade Sectoral Geographical Concentration{col 72}(WTSGC)
{hline 83}
{bf:{err:*** Forecasting Models:}}
{helpb arfimax}{col 9}Autoregressive Fractionally Integrated Moving Average Models{col 72}(ARFIMAX)
{helpb arimax}{col 9}Autoregressive Integrated Moving Average Models{col 72}(ARIMAX)
{helpb varx}{col 9}Vector Autoregressive Models{col 72}(VARX)
{helpb vecx}{col 9}Vector Error Correction Models{col 72}(VECX)
{hline 83}
{bf:{err:*** Spatial Econometrics Regression Models:}}
{helpb spregcs}{col 9}Spatial Cross Section Regression Econometric Models{col 72}(SPREGCS)
{helpb spregxt}{col 9}Spatial Panel Regression Econometric Models{col 72}(SPREGXT)
{hline 83}

{psee}
{p_end}

