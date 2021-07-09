{smcl}
{hline}
{cmd:help: {helpb almon}}{space 50} {cmd:dialog:} {bf:{dialog almon}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: almon: Shirley Almon Generalized Polynomial Distributed Lag Model}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb almon##01:Syntax}{p_end}
{p 5}{helpb almon##02:Description}{p_end}
{p 5}{helpb almon##03:Model Options}{p_end}
{p 5}{helpb almon##04:Almon Options}{p_end}
{p 5}{helpb almon##05:GMM Options}{p_end}
{p 5}{helpb almon##06:Ridge Options}{p_end}
{p 5}{helpb almon##07:Weight Options}{p_end}
{p 5}{helpb almon##08:Weighted Variable Type Options}{p_end}
{p 5}{helpb almon##09:Other Options}{p_end}
{p 5}{helpb almon##10:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb almon##11:Autocorrelation Tests}{p_end}
{p 5}{helpb almon##12:Heteroscedasticity Tests}{p_end}
{p 5}{helpb almon##13:Non Normality Tests}{p_end}
{p 5}{helpb almon##14:Saved Results}{p_end}
{p 5}{helpb almon##15:References}{p_end}

{p 1}*** {helpb almon##16:Examples}{p_end}

{p 5}{helpb almon##17:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{cmd:almon} {depvar} {it:{help varlist:indepvars}} {ifin} {weight} , {opt zl:ag(vars)} {opt pdl(#)} {opt end:pr(#)}{p_end} 
{p 5 5 6} 
{err: [} {opt model(als, arch, bcox, gls, gmm, ols, qreg, rreg)}{p_end} 
{p 5 5 6} 
{opt weights(yh|yh2|abse|e2|le2|x|xi|x2|xi2)} {opt wv:ar(varname)} {opt tech:n(str)} {opt cond:ition}{p_end} 
{p 5 5 6} 
{opt rid:ge(orr|grr1|grr2|grr3)} {opt kr(#)} {opt tune(#)} {opt het:cov(type)}{p_end} 
{p 5 5 6} 
{opt lma:uto} {opt lmh:et} {opt lmn:orm} {opt sig diag dn tolog} {opt nol:ag}{p_end} 
{p 5 5 6} 
{opt mfx(lin, log)} {opt nocons:tant} {opt test:s} {opt lag(#)} {opt dlag(#)} {opt hetc:ov(gmm_type)}{p_end} 
{p 5 5 6} 
{opt lam:p(lhs|rhs|alls|alld)} {opt vce(str)} {opt tech:n(str)} {opt iter(#)}{p_end} 
{p 5 5 6} 
{opt ar(#)} {opt tol:erance(#)} {opt pred:ict(new_var)} {opt res:id(new_var)} {opt two:step} {opt quan:tile(#)} {opt l:evel(#)} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:almon} estimates Shirley Almon Polynomial Distributed Lag Model for many variables with different lag order, endpoint restrictions, and polynomial degree order via (ALS - ARCH - Box-Cox - GLS - GMM - OLS - QREG - RREG - Ridge) Regression models, 
and computes Autocorrelation, Heteroscedasticity, and Non Normality Tests. Model Selection Diagnostic Criteria,
and Marginal effects and elasticities in both short and long run.

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{marker 03}{bf:{err:{dlgtab:Model Options}}}

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

{marker 04}{bf:{err:{dlgtab:Almon Options}}}

{synopt:{bf:pdl(#)}}Polynomial Degree (Must be Specified){p_end}

{synopt:{opt end:pr(#)}}Endpoint Restriction Range Must be Specified as (0, 1, 2, 3){p_end}
{synopt:{opt end:pr(0)}}No Endpoint Polynomial Restrictions{p_end}
{synopt:{opt end:pr(1)}}Left Side Endpoint Polynomial Restrictions{p_end}
{synopt:{opt end:pr(2)}}Right Side Endpoint Polynomial Restrictions{p_end}
{synopt:{opt end:pr(3)}}Left & Right Side Endpoint Restrictions of Polynomial{p_end}

{synopt:{bf:zlag(vars)}}Polynomial Variables (Must be Specified){p_end}
{p 22}Number of zlag(#) must Equal Number of endpr(#){p_end}

{marker 05}{bf:{err:{dlgtab:GMM Options}}}

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

{marker 06}{bf:{err:{dlgtab:Ridge Options}}}

{p 3 6 2} {opt kr(#)} Ridge k value, must be in the range (0 < k < 1).{p_end}

{p 3 6 2}IF {bf:kr(0)} in {opt ridge(orr, grr1, grr2, grr3)}, the model will be an OLS regression.{p_end}

{p 3}{bf:ridge({err:{it:orr}})} : Ordinary Ridge Regression    [Judge,et al(1988,p.878) eq.21.4.2]{p_end}
{p 3}{bf:ridge({err:{it:grr1}})}: Generalized Ridge Regression [Judge,et al(1988,p.881) eq.21.4.12]{p_end}
{p 3}{bf:ridge({err:{it:grr2}})}: Iterative Generalized Ridge  [Judge,et al(1988,p.881) eq.21.4.12]{p_end}
{p 3}{bf:ridge({err:{it:grr3}})}: Adaptive Generalized Ridge   [Strawderman(1978)]{p_end}

{p 2 4 2}{cmd:almon} estimates Ordinary Ridge regression as a multicollinearity remediation method.{p_end}
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

{marker 07}{bf:{err:{dlgtab:Weight Options}}}

{synoptset 16}{...}
{synopt:{bf:wvar({err:{it:varname}})}}Weighted Variable Name{p_end}

{marker 08}{bf:{err:{dlgtab:Weighted Variable Type Options}}}

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

{marker 09}{bf:{err:{dlgtab:Other Options}}}
{synoptset 16}{...}

{synopt:{opt lamp( )}}Transformation Type in {bf:model({err:{it:bcox}})}{p_end}
{synopt:{bf:lamp({err:{it:lhs}})}}Power Transformations on (LHS) Left Hand Side Only; default{p_end}
{synopt:{bf:lamp({err:{it:rhs}})}}Power Transformations on (RHS) Right Hand Side Only{p_end}
{synopt:{bf:lamp({err:{it:alls}})}}Power Transformations on both (LHS) & (RHS) are the Same{p_end}
{synopt:{bf:lamp({err:{it:alld}})}}Power Transformations on both (LHS) & (RHS) are Different{p_end}

{synopt:{opt tech:n(name)}}Maximization of Log Likelihood Function (LLF) Technique Algorithm{p_end}
{p 22}{bf:techn({err:{it:nr}})} Newton-Raphson (NR); default{p_end}
{p 22}{bf:techn({err:{it:bhhh}})} Berndt-Hall-Hall-Hausman (BHHH){p_end}
{p 22}{bf:techn({err:{it:dfp}})} Davidon-Fletcher-Powell (DFP){p_end}
{p 22}{bf:techn({err:{it:bfgs}})} Broyden-Fletcher-Goldfarb-Shanno (BFGS){p_end}

{synopt:{bf:dlag({err:{it:#}})}}Location of Lagged Dependent Variable{p_end}

{synopt:{bf:lag({err:{it:#}})}}Lag Length Order Tests; Autocorrelation, Heteroscedasticity, and Unit Roots {p_end}

{synopt:{opt ar(#)}}Autoregressive Variables Lag Length{p_end}

{col 3}{opt cond:ition}{col 20}use conditional MLE instead of full MLE with {bf:model({err:{it:als}})}

{col 3}{opt dn}{col 20}Use (N) divisor instead of (N-K) for Degrees of Freedom (DF)

{col 3}{opt quan:tile(#)}{col 20}Quantile Value

{col 3}{opt tune(#)}{col 20}use # as the biweight tuning constant;
{col 20}default is tune(7) with {bf:model({err:{it:qreg}})}

{synopt:{opt two:step}}Two-Step estimation, stop after first iteration, same as iter(1){p_end}

{synopt:{opt iter(#)}}number of iterations; Default is iter(200){p_end}

{synopt:{opt tol:erance(#)}}tolerance for coefficient vector; Default is tol(0.00001){p_end}

{synopt:{opt test:s}}Display ALL lma, lmh, lmn, lmi, lmcl, diag, reset tests{p_end}

{synopt:{opt nocons:tant}}Exclude Constant Term from Equation{p_end}

{col 3}{opt nol:ag}{col 20}Use Independent Variables in current period X(t), instead of lag X(t-1)

{synopt:{opt pred:ict(new_var)}}Predicted values variable{p_end}

{synopt:{opt res:id(new_var)}}Residuals values variable{p_end}

{synopt:{opt mfx(lin, log)}}functional form: Linear model {cmd:(lin)}, or Log-Log model {cmd:(log)}, to compute Marginal Effects and Elasticities{p_end}
   - In Linear model: marginal effects are the coefficients (Bm),
        and elasticities are (Es = Bm X/Y).
   - In Log-Log model: elasticities are the coefficients (Es),
        and the marginal effects are (Bm = Es Y/X).
     - {opt mfx(log)} and {opt tolog} options must be combined, to transform variables to log form.

{synopt:{opt tolog}}Convert dependent and independent variables{p_end}
{p 22}to LOG Form in the memory for Log-Log regression{p_end}
{p 22}{opt tolog} Transforms {depvar} and {indepvars}{p_end}
{p 22}to Log Form without lost the original data variables{p_end}

{synopt:{opt sig}}print significance level for each entry in Correlation Matrix{p_end}

{synopt:{opt l:evel(#)}}Confidence Intervals Level; default is level(95){p_end}

{synopt :{opth vce(vcetype)} {opt ols}, {opt r:obust}, {opt cl:uster}, {opt boot:strap}, {opt jack:knife}, {opt hc2}, {opt hc3}}{p_end}

{synopt:{opt tech:n(name)}}Maximization of Log Likelihood Function (LLF) Technique Algorithm{p_end}
{p 22}{bf:techn({err:{it:nr}})} Newton-Raphson (NR); default{p_end}
{p 22}{bf:techn({err:{it:bhhh}})} Berndt-Hall-Hall-Hausman (BHHH){p_end}
{p 22}{bf:techn({err:{it:dfp}})} Davidon-Fletcher-Powell (DFP){p_end}
{p 22}{bf:techn({err:{it:bfgs}})} Broyden-Fletcher-Goldfarb-Shanno (BFGS){p_end}

{marker 10}{bf:{err:{dlgtab:diag: Model Selection Diagnostic Criteria}}}
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

{marker 11}{bf:{err:{dlgtab:lmauto: Autocorrelation Tests}}}
 	Ho: No Autocorrelation - Ha: Autocorrelation
	- Durbin  h Test (Lag DepVar)
	- Durbin  h Test after ALS(1)
	- Harvey LM Test (Lag DepVar)
	- Harvey LM Test after ALS(1)
	- Wald    T Test
	- Wald Chi2 Test
	- Berenblut-Webb Test
	- King Test (MA)
	- Rho Value for
	- Durbin-Watson Test
	- Von Neumann Ratio Test
	- Durbin m Test (drop 1 obs)
	- Durbin m Test (keep 1 obs)
	- Breusch-Godfrey LM Test (drop 1 obs)
	- Breusch-Godfrey LM Test (keep 1 obs)
	- Breusch-Pagan-Godfrey LM Test
	- Ljung-Box  LM Test
	- Box-Pierce LM Test
	- Z Test

{marker 12}{bf:{err:{dlgtab:lmhet: Heteroscedasticity Tests}}}
 	Ho: Homoscedasticity - Ha: Heteroscedasticity
	- Engle LM ARCH Test
	- Hall-Pagan LM Test:      E2 = Yh
	- Hall-Pagan LM Test:      E2 = Yh2
	- Hall-Pagan LM Test:      E2 = LYh2
	- Harvey LM Test:       LogE2 = X
	- Wald LM Test:         LogE2 = X
	- Glejser LM Test:        |E| = X
	- Breusch-Godfrey Test:    E2 = E2_1 X
	- Machado-Santos-Silva Test: Ev=Yh Yh2
	- Machado-Santos-Silva Test: Ev=X
	- White Test -Koenker(R2): E2 = X
	- White Test -B-P-G (SSR): E2 = X
	- White Test -Koenker(R2): E2 = X X2
	- White Test -B-P-G (SSR): E2 = X X2
	- White Test -Koenker(R2): E2 = X X2 XX
	- White Test -B-P-G (SSR): E2 = X X2 XX
	- Cook-Weisberg LM Test  E2/Sig2 = Yh
	- Cook-Weisberg LM Test  E2/Sig2 = X

{marker 13}{bf:{err:{dlgtab:lmnorm: Non Normality Tests}}}
 	Ho: Normality - Ha: Non Normality
	*** Non Normality Tests:
	- Jarque-Bera LM Test
	- White IM Test
	- Doornik-Hansen LM Test
	- Geary LM Test
	- Anderson-Darling Z Test
	- D'Agostino-Pearson LM Test
	*** Skewness Tests:
	- Srivastava LM Skewness Test
	- Small LM Skewness Test
	- Skewness Z Test
	*** Kurtosis Tests:
	- Srivastava  Z Kurtosis Test
	- Small LM Kurtosis Test
	- Kurtosis Z Test
	- Runs Test

{marker 14}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:almon} saves the following in {cmd:e()}:

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
{col 4}{cmd:e(rho#)}{col 20}Rho Value for AR(i)
{col 4}{cmd:e(lmabgd#)}{col 20}Breusch-Godfrey LM Test (drop i obs)
{col 4}{cmd:e(lmabgdp#)}{col 20}Breusch-Godfrey LM Test (drop i obs) P-Value
{col 4}{cmd:e(lmabgk#)}{col 20}Breusch-Godfrey LM Test (keep i obs)
{col 4}{cmd:e(lmabgkp#)}{col 20}Breusch-Godfrey LM Test (keep i obs) P-Value
{col 4}{cmd:e(lmabpg#)}{col 20}Breusch-Pagan-Godfrey LM Test AR(i)
{col 4}{cmd:e(lmabpgp#)}{col 20}Breusch-Pagan-Godfrey LM Test AR(i) P-Value
{col 4}{cmd:e(lmabp#)}{col 20}Box-Pierce LM Test AR(i)
{col 4}{cmd:e(lmabpp#)}{col 20}Box-Pierce LM Test AR(i) P-Value
{col 4}{cmd:e(lmadho)}{col 20}Durbin  h Test (Lag DepVar)
{col 4}{cmd:e(lmadhop)}{col 20}Durbin  h Test (Lag DepVar) P-Value
{col 4}{cmd:e(lmadha)}{col 20}Durbin  h Test after ALS(1)
{col 4}{cmd:e(lmadhap)}{col 20}Durbin  h Test after ALS(1) P-Value
{col 4}{cmd:e(lmadmd#)}{col 20}Durbin m Test (drop i obs) AR(i)
{col 4}{cmd:e(lmadmdp#)}{col 20}Durbin m Test (drop i obs) AR(i) P-Value
{col 4}{cmd:e(lmadmk#)}{col 20}Durbin m Test (keep i obs) AR(i)
{col 4}{cmd:e(lmadmkp#)}{col 20}Durbin m Test (keep i obs) AR(i) P-Value
{col 4}{cmd:e(lmadw#)}{col 20}Durbin-Watson Test AR(i)
{col 4}{cmd:e(lmahho)}{col 20}Harvey LM Test (Lag DepVar)
{col 4}{cmd:e(lmahhop)}{col 20}Harvey LM Test (Lag DepVar) P-Value
{col 4}{cmd:e(lmahha)}{col 20}Harvey LM Test after ALS(1)
{col 4}{cmd:e(lmahhap)}{col 20}Harvey LM Test after ALS(1) P-Value
{col 4}{cmd:e(lmalb#)}{col 20}Ljung-Box LM Test AR(i)
{col 4}{cmd:e(lmalbp#)}{col 20}Ljung-Box LM Test AR(i) P-Value
{col 4}{cmd:e(lmawt)}{col 20}Wald T Test
{col 4}{cmd:e(lmawtp)}{col 20}Wald T Test P-Value
{col 4}{cmd:e(lmawc)}{col 20}Wald Chi2 Test
{col 4}{cmd:e(lmawcp)}{col 20}Wald Chi2 Test P-Value
{col 4}{cmd:e(lmabw)}{col 20}Berenblut-Webb Test
{col 4}{cmd:e(lmakg)}{col 20}King Test (MA)
{col 4}{cmd:e(lmavon#)}{col 20}Von Neumann Ratio Test AR(i)
{col 4}{cmd:e(lmaz#)}{col 20}Z Test AR(i)
{col 4}{cmd:e(lmazp#)}{col 20}Z Test AR(i) P-Value

{err:*** Heteroscedasticity Tests:}
{col 4}{cmd:e(lmharch)}{col 20}Engle LM ARCH Test AR(i)
{col 4}{cmd:e(lmharchp)}{col 20}Engle LM ARCH Test AR(i) P-Value
{col 4}{cmd:e(lmhhp1)}{col 20}Hall-Pagan LM Test
{col 4}{cmd:e(lmhhp1p)}{col 20}Hall-Pagan LM Test P-Value
{col 4}{cmd:e(lmhhp2)}{col 20}Hall-Pagan LM Test
{col 4}{cmd:e(lmhhp2p)}{col 20}Hall-Pagan LM Test P-Value
{col 4}{cmd:e(lmhhp3)}{col 20}Hall-Pagan LM Test
{col 4}{cmd:e(lmhhp3p)}{col 20}Hall-Pagan LM Test P-Value
{col 4}{cmd:e(lmhharv)}{col 20}Harvey LM Test
{col 4}{cmd:e(lmhharvp)}{col 20}Harvey LM Test P-Value
{col 4}{cmd:e(lmhwald)}{col 20}Wald LM Test
{col 4}{cmd:e(lmhwaldp)}{col 20}Wald LM Test P-Value
{col 4}{cmd:e(lmhgl)}{col 20}Glejser LM Test
{col 4}{cmd:e(lmhglp)}{col 20}Glejser LM Test P-Value
{col 4}{cmd:e(lmhmss1)}{col 20}Machado-Santos-Silva Test: Ev=Yh Yh2 LM Test
{col 4}{cmd:e(lmhmss1p)}{col 20}Machado-Santos-Silva Test: Ev=Yh Yh2 LM Test P-Value
{col 4}{cmd:e(lmhmss2)}{col 20}Machado-Santos-Silva Test: Ev=X LM Test
{col 4}{cmd:e(lmhmss2p)}{col 20}Machado-Santos-Silva Test: Ev=X LM Test P-Value
{col 4}{cmd:e(lmhbg)}{col 20}Breusch-Godfrey Test
{col 4}{cmd:e(lmhbgp)}{col 20}Breusch-Godfrey Test P-Value
{col 4}{cmd:e(lmhw01)}{col 20}White Test (X) - Koenker(R2)
{col 4}{cmd:e(lmhw01p)}{col 20}White Test (X) - Koenker(R2) P-Value
{col 4}{cmd:e(lmhw02)}{col 20}White Test (X) - B-P-G (SSR)
{col 4}{cmd:e(lmhw02p)}{col 20}White Test (X) - B-P-G (SSR) P-Value
{col 4}{cmd:e(lmhw11)}{col 20}White Test (X X2) - Koenker(R2)
{col 4}{cmd:e(lmhw11p)}{col 20}White Test (X X2) - Koenker(R2) P-Value
{col 4}{cmd:e(lmhw12)}{col 20}White Test (X X2) - B-P-G (SSR)
{col 4}{cmd:e(lmhw12p)}{col 20}White Test (X X2) - B-P-G (SSR) P-Value
{col 4}{cmd:e(lmhw21)}{col 20}White Test (X X2 XX) - Koenker(R2)
{col 4}{cmd:e(lmhw21p)}{col 20}White Test (X X2 XX) - Koenker(R2) P-Value
{col 4}{cmd:e(lmhw22)}{col 20}White Test (X X2 XX) - B-P-G (SSR)
{col 4}{cmd:e(lmhw22p)}{col 20}White Test (X X2 XX) - B-P-G (SSR) P-Value
{col 4}{cmd:e(lmhcw1)}{col 20}Cook-Weisberg LM Test E2/Sig2n = Yh 
{col 4}{cmd:e(lmhcw1p)}{col 20}Cook-Weisberg LM Test E2/Sig2n = Yh P-Value
{col 4}{cmd:e(lmhcw2)}{col 20}Cook-Weisberg LM Test E2/Sig2n = X
{col 4}{cmd:e(lmhcw2p)}{col 20}Cook-Weisberg LM Test E2/Sig2n = X P-Value

{err:*** Non Normality Tests:}
{col 4}{cmd:e(lmnjb)}{col 20}Jarque-Bera LM Test
{col 4}{cmd:e(lmnjbp)}{col 20}Jarque-Bera LM Test P-Value
{col 4}{cmd:e(lmnw)}{col 20}White IM Test
{col 4}{cmd:e(lmnwp)}{col 20}White IM Test P-Value
{col 4}{cmd:e(lmndh)}{col 20}Doornik-Hansen LM Test
{col 4}{cmd:e(lmndhp)}{col 20}Doornik-Hansen LM Test P-Value
{col 4}{cmd:e(lmng)}{col 20}Geary LM Test
{col 4}{cmd:e(lmngp)}{col 20}Geary LM Test P-Value
{col 4}{cmd:e(lmnad)}{col 20}Anderson-Darling Z Test
{col 4}{cmd:e(lmnadp)}{col 20}Anderson-Darling Z Test P-Value
{col 4}{cmd:e(lmndp)}{col 20}D'Agostino-Pearson LM Test
{col 4}{cmd:e(lmndpp)}{col 20}D'Agostino-Pearson LM Test P-Value
{col 4}{cmd:e(lmnsvs)}{col 20}Srivastava LM Skewness Test
{col 4}{cmd:e(lmnsvsp)}{col 20}Srivastava LM Skewness Test P-Value
{col 4}{cmd:e(lmnsms)}{col 20}Small LM Skewness Test
{col 4}{cmd:e(lmnsmsp)}{col 20}Small LM Skewness Test P-Value
{col 4}{cmd:e(lmnsz)}{col 20}Skewness Z Test
{col 4}{cmd:e(lmnszp)}{col 20}Skewness Z Test P-Value
{col 4}{cmd:e(lmnsvk)}{col 20}Srivastava  Z Kurtosis Test
{col 4}{cmd:e(lmnsvkp)}{col 20}Srivastava  Z Kurtosis Test P-Value
{col 4}{cmd:e(lmnsmk)}{col 20}Small LM Kurtosis Test
{col 4}{cmd:e(lmnsmkp)}{col 20}Small LM Kurtosis Test P-Value
{col 4}{cmd:e(lmnsmk)}{col 20}Kurtosis Z Test
{col 4}{cmd:e(lmnsmkp)}{col 20}Kurtosis Z Test P-Value
{col 4}{cmd:e(sk)}{col 20}Skewness Coefficient
{col 4}{cmd:e(sksd)}{col 20}Skewness Standard Deviation
{col 4}{cmd:e(ku)}{col 20}Kurtosis Coefficient
{col 4}{cmd:e(kusd)}{col 20}Kurtosis Standard Deviation
{col 4}{cmd:e(en)}{col 20}Mean Runs E(k)
{col 4}{cmd:e(sn)}{col 20}Standard Deviation Runs Sig(k)
{col 4}{cmd:e(lower)}{col 20}95% Lower Conf. Interval
{col 4}{cmd:e(upper)}{col 20}95% Upper Conf. Interval

Matrixes
{col 4}{cmd:e(b)}{col 20}coefficient vector
{col 4}{cmd:e(V)}{col 20}variance-covariance matrix of the estimators
{col 4}{cmd:e(mfxlin)}{col 20}Marginal Effect and Elasticity in Lin Form
{col 4}{cmd:e(mfxlog)}{col 20}Marginal Effect and Elasticity in Log Form
{col 4}{cmd:e(restc)}{col 20}Restriction Matrix

{marker 15}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Shirley Montag Almon (1935–1975)
{browse "http://en.wikipedia.org/wiki/Shirley_Montag_Almon"}

{p 4 8 2} Almon, Shirley (1965)
{cmd:The Distributed Lag Between Capital Appropriations and Expenditures,}
{it:Econometrica, Vol. 33, No. 1, Jan.;} 178-196.

{p 4 8 2} Almon, Shirley (1968)
{cmd:Lags Between Investment Decisions and Their Causes,}
{it:Rev. Econ. Stat., Vol. 50;} 193-206.

{p 4 8 2}Anderson T.W., Darling D.A. (1954)
{cmd: "A Test of Goodness of Fit",}
{it:Journal of the American Statisical Association, 49}; 765–69. 

{p 4 8 2}Box, George & Pierce D. (1970)
{cmd: "Distribution of Residual Autocorrelations in Autoregressive Integrated Moving Average Time Series Models",}
{it:Journal of the American Statisical Association, 65}; 1509-1526.

{p 4 8 2}Breusch, Trevor (1978)
{cmd: "Testing for Autocorrelation in Dynamic Linear Models",}
{it:Aust. Econ. Papers, Vol. 17}; 334-355.

{p 4 8 2}Breusch, Trevor & Adrian Pagan (1980)
{cmd: "The Lagrange Multiplier Test and its Applications to Model Specification in Econometrics",}
{it:Review of Economic Studies 47}; 239-253.

{p 4 8 2}C.M. Jarque  & A.K. Bera (1987)
{cmd: "A Test for Normality of Observations and Regression Residuals"}
{it:International Statistical Review}, Vol. 55; 163-172.

{p 4 8 2}Cook, R.D., & S. Weisberg (1983)
{cmd: "Diagnostics for Heteroscedasticity in Regression",}
{it:Biometrica 70}; 1-10.

{p 4 8 2}D. Belsley (1991)
{cmd: "Conditioning Diagnostics, Collinearity and Weak Data in Regression",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}D. Belsley, E. Kuh, and R. Welsch (1980)
{cmd: "Regression Diagnostics: Identifying Influential Data and Sources of Collinearity",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}D'Agostino, R. B., & Rosman, B. (1974)
{cmd: "The Power of Geary’s Test of Normality",}
{it:Biometrika, 61(1)}; 181-184.

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}DeBenedictis, L. F. & Giles D. E. A. (1998)
{cmd: "Diagnostic Testing in Econometrics: Variable Addition, RESET and Fourier Approximations",}
{it:In: A. Ullah  & D. E. A. Giles (Eds.), Handbook of Applied Economic Statistics. Marcel Dekker, New York}; 383-417.

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

{p 4 8 2}Farrar, D. and Glauber, R. (1976)
{cmd: "Multicollinearity in Regression Analysis: the Problem Revisited",}
{it:Review of Economics and Statistics, 49}; 92-107.

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

{p 4 8 2}Ljung, G. & George Box (1979)
{cmd: "On a Measure of Lack of Fit in Time Series Models",}
{it:Biometrika, Vol. 66}; 265–270.

{p 4 8 2}Machado, J.A.F. and Santos Silva, J.M.C. (2000)
{cmd: "Glejser's Test Revisited",}
{it: Journal of Econometrics, 97(1)}; 189-202.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}; 358-366.

{p 4 8 2}Marquardt D.W. (1970)
{cmd: "Generalized Inverses, Ridge Regression, Biased Linear Estimation, and Nonlinear Estimation",}
{it:Technometrics, 12}; 591-612.

{p 4 8 2}Marquardt D.W. & R. Snee (1975)
{cmd: "Ridge Regression in Practice",}
{it:The American Statistician, 29}; 3-19.

{p 4 8 2}Pearson, E. S., D'Agostino, R. B., & Bowman, K. O. (1977)
{cmd: "Tests for Departure from Normality: Comparison of Powers",}
{it:Biometrika, 64(2)}; 231-246.

{p 4 8 2}Pidot, George (1969)
{cmd: "A Principal Components Analysis of the Determinants of Local Government Fiscal Patterns",}
{it:Review of Economics and Statistics, Vol. 51}; 176-188.

{p 4 8 2}Ramsey, J. B. (1969)
{cmd: "Tests for Specification Errors in Classical Linear Least-Squares Regression Analysis",}
{it: Journal of the Royal Statistical Society, Series B 31}; 350-371.

{p 4 8 2}Rencher, Alvin C. (1998)
{cmd: "Multivariate Statistical Inference and Applications",}
{it:John Wiley & Sons, Inc., New York, USA}; 21-22.

{p 4 8 2}Strawderman, W. E. (1978)
{cmd: "Minimax Adaptive Generalized Ridge Regression Estimators",}
{it:Journal American Statistical Association, 73}; 623-627.

{p 4 8 2}Szroeter, J. (1978)
{cmd: "A Class of Parametric Tests for Heteroscedasticity in Linear Econometric Models",}
{it:Econometrica, 46}; 1311-28.

{p 4 8 2}Theil, Henri (1971)
{cmd: "Principles of Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Von, Neumann (1941)
{cmd: "Distribution of the Ratio of the Mean Square Successive Difference to the Variance",}
{it:Annals Math. Stat., Vol. 12}; 367-395.

{p 4 8 2}White, Halbert (1980)
{cmd: "A Heteroskedasticity-Consistent Covariance Matrix Estimator and a Direct Test for Heteroskedasticity",}
{it:Econometrica, 48}; 817-838.

{p 4 8 2}William E. Griffiths, R. Carter Hill and George G. Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.  

{marker 16}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse almon.dta , clear}

 {stata gen lx1=log(x1)}
 {stata gen lx2=log(x2)}

{bf:{err:* (1) Ordinary Least Squares (OLS)}}
 {stata almon y l(0/3).x1 , zlag(x1) pdl(2) end(0) model(ols) nolag}
 
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(log) test tolog}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) lma lag(1)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) lma lag(2)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) lma lag(3)}

 {stata almon y l.y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) lma lag(1) dlag(1)}
 {stata almon y l(0/3).x1 l.y l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) lma lag(1) dlag(2)}
 {stata almon y l(0/3).x1 l(0/3).x2 l.y , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) lma lag(1) dlag(3)}
{hline}

{bf:{err:* (2) Autoregressive Least Squares (ALS)}}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(als) mfx(lin) test}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(als) mfx(log) test tolog}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(als) mfx(lin) test twostep}

 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(als) mfx(lin) ar(1) test}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(als) mfx(lin) ar(2) test}
{hline}

{bf:{err:* (3) Quantile Regression (QREG)}}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(qreg) mfx(lin) test}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(qreg) mfx(log) test tolog}
{hline}

{bf:{err:* (4) Robust Regression (RREG)}}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(rreg) mfx(lin) test}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(rreg) mfx(log) test tolog}
{hline}

{bf:{err:* (5) Generalized Method of Moments (GMM)}}
White:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(white)}
Bartlett:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(bart)}
Cragg:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(crag)}
Daniell:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(dan)}
Horn-Duncan:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(hdun)}
Hinkley:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(hink)}
Jackknife:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(jack)}
Newey-West:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(nwest)}
Parzen:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(parzen)}
Quadratic Spectral:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(quad)}
Tent:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(tent)}
Truncated:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(trunc)}
Tukey:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(tukey)}
Tukey-Hamming:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(tukeym)}
Tukey-Hanning:
 {stata almon y l(0/3).x1 l(0/3).x2, zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(tukeyn)}
{hline}

{bf:{err:* (6) Weighted OLS & GMM Regression}}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test weights(yh)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test weights(yh2)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test weights(abse)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test weights(e2)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test weights(le2)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test weights(x) wvar(x1)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test weights(xi) wvar(x1)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test weights(x2) wvar(x1)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test weights(xi2) wvar(x1)}

 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0)model(gmm) mfx(lin) test hetcov(white) weights(yh)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0)model(gmm) mfx(lin) test hetcov(white) weights(x) wvar(x1)}
{hline}

{bf:{err:* (7) Ridge Regression}}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test ridge(orr) kr(0.5)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test ridge(orr) kr(0.5) weights(x) wvar(x1)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test ridge(grr1)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test ridge(grr2)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) mfx(lin) test ridge(grr3)}

 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(white) ridge(orr) kr(0.5)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(white) ridge(orr) kr(0.5) weights(x) wvar(x1)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(white) ridge(grr1)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(white) ridge(grr2)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(gmm) mfx(lin) test hetcov(white) ridge(grr3)}
{hline}

{bf:{err:* (8) Box-Cox Regression (Box-Cox)}}
 {stata almon y l(0/3).lx1 l(0/3).lx2 , zlag(x1 x2) pdl(2 2) end(0 0) model(bcox) test mfx(lin) lag(3) lamp(lhs)}
 {stata almon y l(0/3).lx1 l(0/3).lx2 , zlag(x1 x2) pdl(2 2) end(0 0) model(bcox) test mfx(lin) lag(3) lamp(rhs)}
 {stata almon y l(0/3).lx1 l(0/3).lx2 , zlag(x1 x2) pdl(2 2) end(0 0) model(bcox) test mfx(lin) lag(3) lamp(alls)}
 {stata almon y l(0/3).lx1 l(0/3).lx2 , zlag(x1 x2) pdl(2 2) end(0 0) model(bcox) test mfx(lin) lag(3) lamp(alld)}
{hline}

{bf:{err:* (9) Autoregressive Conditional Heteroskedasticity (ARCH)}}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(arch) lag(1) test diag mfx(lin)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(arch) lag(2) test diag mfx(lin)}
 {stata almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(arch) lag(1) test diag mfx(log) tolog}
{hline}

 {stata almon y l(0/3).x1 l(0/3).x2 , model(ols) zlag(x1 x2) pdl(2 2) end(0 0) mfx(lin)}

 {stata almon y l(0/3).x1 , model(ols) zlag(x1) pdl(2) end(0)}
 {stata almon y l(0/3).x1 l(0/3).x2 , model(ols) zlag(x1 x2) pdl(2 2) end(1 1)}
 {stata almon y l(0/4).x1 l(0/3).x2 x3 , model(ols) zlag(x1 x2) pdl(2 2) end(3 2)}

 {stata tsset t}
 {stata constr def 1  x1 - 3*L.x1 + 3*L2.x1 - L3.x1 = 0}
 {stata cnsreg y l(0/3).x1 l(0/3).x2 , c(1)}
 {stata almon y l(0/3).x1 , model(ols) zlag(x1) pdl(2) end(0) mfx(lin)}
 
 {stata tsset t}
 {stata constr def 1  x2 - 3*L.x2 + 3*L2.x2 - L3.x2 = 0}
 {stata cnsreg y l(0/3).x2 , c(1)}
 {stata almon y l(0/3).x2 , model(ols) zlag(x2) pdl(2) end(0) mfx(lin)}

 {stata tsset t}
 {stata constr def 1  x1 - 3*L.x1 + 3*L2.x1 - L3.x1 = 0}
 {stata constr def 2  x2 - 3*L.x2 + 3*L2.x2 - L3.x2 = 0}
 {stata cnsreg y l(0/3).x1 l(0/3).x2 , c(1-2)}
 {stata almon y l(0/3).x1 l(0/3).x2 , model(ols) zlag(x1 x2) pdl(2 2) end(0 0) mfx(lin)}
{hline}

. clear all
. sysuse almon.dta , clear
. almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0) model(ols) test mfx(lin)

==============================================================================
      *** Shirley Almon Generalized Polynomial Distributed Lag Model ***
==============================================================================
 *** Ordinary Least Squares (OLS) ***
-------------------------------------------------------
- Polynomial Variables:  x1 x2
- Lag Length:            l(0/3).x1 l(0/3).x2 
- Polynomial Degree:     PDL(2 2)
- Endpoint Restriction:  End(0 0)
* x1: No Endpoint Polynomial Restrictions
* x2: No Endpoint Polynomial Restrictions
------------------------------------------------------------------------------
 y = x1 L.x1 L2.x1 L3.x1 x2 L.x2 L2.x2 L3.x2
------------------------------------------------------------------------------
* Restrictions:
     1:  x1 - 3*L.x1 + 3*L2.x1 - L3.x1 = 0
     2:  x2 - 3*L.x2 + 3*L2.x2 - L3.x2 = 0
------------------------------------------------------------------------------
 Sample Size        =          32   |   Sample Range            =      1 - 36
 Wald Test          =   1800.8301   |   P-Value > Chi2(6)       =      0.0000
 F-Test             =    300.1384   |   P-Value > F(6 , 25)     =      0.0000
 R2  (R-Squared)    =      0.9863   |   Raw Moments R2          =      0.9999
 R2a (Adjusted R2)  =      0.9830   |   Raw Moments R2 Adj      =      0.9999
 Root MSE (Sigma)   =      2.8840   |   Log Likelihood Function =    -75.3504
------------------------------------------------------------------------------
- R2h= 0.9863  R2h Adj=  0.9830  F-Test =  300.14 P-Value > F(6 , 25)  0.0000
- R2v= 0.9863  R2v Adj=  0.9830  F-Test =  300.14 P-Value > F(6 , 25)  0.0000
- R2r= 0.9999  R2r Adj=  0.9999  F-Test =68028.22 P-Value > F(7 , 25)  0.0000
------------------------------------------------------------------------------
 Akaike Criterion AIC =    162.7009 |   Schwarz Criterion SC    =    171.4953
------------------------------------------------------------------------------
- Joint F-Test Restriction: x1          =    23.876   P > F(3, 25)     0.0000
- Joint F-Test Restriction: x2          =     0.748   P > F(3, 25)     0.5340
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |
         --. |   1.224306   .3235994     3.78   0.001     .5578402    1.890771
         L1. |   .5102923   .3001897     1.70   0.102      -.10796    1.128544
         L2. |   .0228886   .3091815     0.07   0.942    -.6138825    .6596598
         L3. |  -.2379053   .4256806    -0.56   0.581    -1.114611    .6388004
             |
          x2 |
         --. |  -.0057917   .2024303    -0.03   0.977    -.4227048    .4111214
         L1. |   .1321913   .1463322     0.90   0.375    -.1691856    .4335681
         L2. |   .0477574   .1419953     0.34   0.739    -.2446875    .3402022
         L3. |  -.2590934    .180877    -1.43   0.164    -.6316165    .1134297
             |
       _cons |   70.12386   9.369416     7.48   0.000     50.82719    89.42053
------------------------------------------------------------------------------

==============================================================================
*** Model Selection Diagnostic Criteria - (Model= OLS)
==============================================================================
- Log Likelihood Function                   LLF            =    -75.3504
---------------------------------------------------------------------------
- Akaike Information Criterion              (1974) AIC     =     10.0646
- Akaike Information Criterion              (1973) Log AIC =      2.3090
---------------------------------------------------------------------------
- Schwarz Criterion                         (1978) SC      =     13.8690
- Schwarz Criterion                         (1978) Log SC  =      2.6297
---------------------------------------------------------------------------
- Amemiya Prediction Criterion              (1969) FPE     =     10.1372
- Hannan-Quinn Criterion                    (1979) HQ      =     11.1932
- Rice Criterion                            (1984) Rice    =     11.5524
- Shibata Criterion                         (1981) Shibata =      9.3412
- Craven-Wahba Generalized Cross Validation (1979) GCV     =     10.6467
------------------------------------------------------------------------------

==============================================================================
*** Autocorrelation Tests - (Model= OLS)
------------------------------------------------------------------------------
 Ho: No Autocorrelation - Ha: Autocorrelation
------------------------------------------------------------------------------
- Durbin  h Test cannot be computed
- Durbin  h Test after ALS(1)          AR(1)=  1.7480  P-Value >Z(0,1)  0.0805
------------------------------------------------------------------------------
- Harvey LM Test (Lag DepVar)          AR(1)= -3.2482  P-Value >Chi2(1) 0.0715
- Harvey LM Test after ALS(1)          AR(1)=  3.0553  P-Value >Chi2(1) 0.0805
------------------------------------------------------------------------------
- Wald    T Test                       AR(1)=  3.1693  P-Value >Z(0,1)  0.0015
- Wald Chi2 Test                       AR(1)= 10.0443  P-Value >Z(0,1)  0.0015
------------------------------------------------------------------------------
- Berenblut-Webb Test                  AR(1)=  0.8549  df: (8 , 32)
- King Test (MA)                       AR(1)=  0.6983  df: (8 , 32)
------------------------------------------------------------------------------
- Rho Value for Lag(1)                 AR(1)=  0.4548
- Z Test                               AR(1)=  2.5726  P-Value >Chi2(1) 0.1087
- Box-Pierce LM Test                   AR(1)=  6.6181  P-Value >Chi2(1) 0.0101
- Ljung-Box  LM Test                   AR(1)=  7.2586  P-Value >Chi2(1) 0.0071
- Durbin-Watson Test                   AR(1)=  1.0210  df: (8 , 32)
- Von Neumann Ratio Test               AR(1)=  1.0539  df: (8 , 32)
- Durbin m Test (drop 1 obs)           AR(1)=  7.6611  P-Value >Chi2(1) 0.0056
- Durbin m Test (keep 1 obs)           AR(1)=  7.3202  P-Value >Chi2(1) 0.0068
- Breusch-Godfrey LM Test (drop 1 obs) AR(1)=  8.9446  P-Value >Chi2(1) 0.0028
- Breusch-Godfrey LM Test (keep 1 obs) AR(1)=  9.2076  P-Value >Chi2(1) 0.0024
* Breusch-Pagan-Godfrey LM Test        AR(1)=  3.0344  P-Value >Chi2(1) 0.0815
------------------------------------------------------------------------------

==============================================================================
*** Heteroscedasticity Tests - (Model= OLS)
------------------------------------------------------------------------------
 Ho: Homoscedasticity - Ha: Heteroscedasticity
------------------------------------------------------------------------------
- Engle LM ARCH Test AR(1) E2=E2_1-E2_1=   0.4052    P-Value > Chi2(1)  0.5244
------------------------------------------------------------------------------
- Hall-Pagan LM Test:      E2 = Yh     =   0.2690    P-Value > Chi2(1)  0.6040
- Hall-Pagan LM Test:      E2 = Yh2    =   0.2638    P-Value > Chi2(1)  0.6075
- Hall-Pagan LM Test:      E2 = LYh2   =   0.2747    P-Value > Chi2(1)  0.6002
------------------------------------------------------------------------------
- Harvey LM Test:       LogE2 = X      =   4.7756    P-Value > Chi2(2)  0.0918
- Wald LM Test:         LogE2 = X      =  11.7834    P-Value > Chi2(1)  0.0006
- Glejser LM Test:        |E| = X      =   8.0715    P-Value > Chi2(2)  0.0177
- Breusch-Godfrey Test:    E2 = E2_1 X =  11.3301    P-Value > Chi2(1)  0.0008
------------------------------------------------------------------------------
- Machado-Santos-Silva Test: Ev=Yh Yh2 =   0.3817    P-Value > Chi2(2)  0.8263
- Machado-Santos-Silva Test: Ev=X      =   8.9885    P-Value > Chi2(8)  0.3433
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X      =   9.8833    P-Value > Chi2(8)  0.2733
- White Test -B-P-G (SSR): E2 = X      =   7.2499    P-Value > Chi2(8)  0.5099
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X X2   =  19.0564    P-Value > Chi2(16) 0.2657
- White Test -B-P-G (SSR): E2 = X X2   =  13.9787    P-Value > Chi2(16) 0.6003
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X X2 XX=  32.0000    P-Value > Chi2(31) 0.4167
- White Test -B-P-G (SSR): E2 = X X2 XX=  23.4735    P-Value > Chi2(31) 0.8314
------------------------------------------------------------------------------
- Cook-Weisberg LM Test  E2/Sig2 = Yh  =   0.1973    P-Value > Chi2(1)  0.6569
- Cook-Weisberg LM Test  E2/Sig2 = X   =   7.2499    P-Value > Chi2(8)  0.5099
------------------------------------------------------------------------------

==============================================================================
*** Non Normality Tests - (Model= OLS)
------------------------------------------------------------------------------
 Ho: Normality - Ha: Non Normality
------------------------------------------------------------------------------
*** Non Normality Tests:
- Jarque-Bera LM Test                  =   0.5171     P-Value > Chi2(2) 0.7722
- White IM Test                        =   1.0258     P-Value > Chi2(2) 0.5988
- Doornik-Hansen LM Test               =   0.2038     P-Value > Chi2(2) 0.9031
- Geary LM Test                        =  -2.1426     P-Value > Chi2(2) 0.3426
- Anderson-Darling Z Test              =   0.1895     P > Z( 1.371)     0.9147
- D'Agostino-Pearson LM Test           =   0.3501     P-Value > Chi2(2) 0.8394
------------------------------------------------------------------------------
*** Skewness Tests:
- Srivastava LM Skewness Test          =   0.1385     P-Value > Chi2(1) 0.7098
- Small LM Skewness Test               =   0.1859     P-Value > Chi2(1) 0.6663
- Skewness Z Test                      =   0.4312     P-Value > Chi2(1) 0.6663
------------------------------------------------------------------------------
*** Kurtosis Tests:
- Srivastava Z Kurtosis Test           =  -0.6154     P-Value > Z(0,1)  0.5383
- Small LM Kurtosis Test               =   0.1641     P-Value > Chi2(1) 0.6854
- Kurtosis Z Test                      =  -0.4051     P-Value > Chi2(1) 0.6854
------------------------------------------------------------------------------
    Skewness Coefficient =  0.1611     - Standard Deviation =  0.4145
    Kurtosis Coefficient =  2.4671     - Standard Deviation =  0.8094
------------------------------------------------------------------------------
    Runs Test: (11) Runs -  (15) Positives - (17) Negatives
    Standard Deviation Runs Sig(k) =  2.7712 , Mean Runs E(k) = 16.9375
    95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (11.5059 , 22.3691 )
------------------------------------------------------------------------------

==============================================================================

* Marginal Effect - Elasticity - Standardized Beta (Model= OLS): Linear *

+----------------------------------------------------------------------------+
|              y |       Margin |   Elasticity |      St_Beta |         Mean |
|----------------+--------------+--------------+--------------+--------------|
|y               |              |              |              |              |
|             x1 |       1.2243 |       0.6857 |       0.8374 |     196.6850 |
|           L.x1 |       0.5103 |       0.2834 |       0.3436 |     194.9896 |
|          L2.x1 |       0.0229 |       0.0126 |       0.0151 |     193.2746 |
|          L3.x1 |      -0.2379 |      -0.1299 |      -0.1551 |     191.6763 |
|             x2 |      -0.0058 |      -0.0037 |      -0.0042 |     224.8154 |
|           L.x2 |       0.1322 |       0.0839 |       0.0933 |     222.9883 |
|          L2.x2 |       0.0478 |       0.0301 |       0.0333 |     221.1494 |
|          L3.x2 |      -0.2591 |      -0.1618 |      -0.1807 |     219.3559 |
+----------------------------------------------------------------------------+
 Mean of Dependent Variable =    351.1539

------------------------------------------------------------------------------
* Variable   Mean Lag   Full Lag    SUM(Coefs.)   Std. Err.  T-Test     P>|t|
------------------------------------------------------------------------------
  x1         -0.1037     0.8963       1.5196       0.3592     4.230     0.0003
------------------------------------------------------------------------------
  x2          6.4704     7.4704      -0.0849       0.3373    -0.252     0.8033
------------------------------------------------------------------------------

------------------------------------------------------------------------------
* Variable    Marginal Effect (B)         |      Elasticity (Es)
              Short Run      Long Run     |      Short Run      Long Run
------------------------------------------------------------------------------
  x1             1.2243         1.5196    |       0.6857         0.8518
------------------------------------------------------------------------------
  x2            -0.0058        -0.0849    |      -0.0037        -0.0515
------------------------------------------------------------------------------

{marker 17}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}


{bf:{err:{dlgtab:ALMON Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2016)}{p_end}
{p 1 10 1}{cmd:ALMON: "Stata Module to Estimate Shirley Almon Generalized Polynomial Distributed Lag Model"}{p_end}

{title:Online Help:}

{bf:*** Distributed Lag Models}
{helpb almon1}{col 12}Shirley Almon Polynomial Distributed Lag Model{col 75}(ALMON1)
{helpb almon}{col 12}Shirley Almon Generalized Polynomial Distributed Lag Model{col 75}(ALMON)
{helpb dlagft}{col 12}Alt France-Jan Tinbergen Distributed Lag Model{col 75}(DLAGFT)
{helpb dlagdj}{col 12}Dale Jorgenson Rational Distributed Lag Model{col 75}(DLAGDJ)
{helpb dlagfd}{col 12}Frank De Leeuw Inverted V Distributed Lag Model{col 75}(DLAGFD)
{helpb dlagif}{col 12}Irving Fisher Arithmetic Distributed Lag Model{col 75}(DLAGIF)
{helpb dlagmf}{col 12}Milton Fridman Partial Adjustment-Adaptive Expectations
{col 12}Distributed Lag Model{col 75}(DLAGMF)
{helpb dlagmn}{col 12}Marc Nerlove Partial Adjustment Distributed Lag Model{col 75}(DLAGMN)
{helpb dlagrs}{col 12}Robert Solow Pascal Triangle Distributed Lag Model{col 75}(DLAGRS)
{helpb dlagrw}{col 12}Rudolf Wolffram Segmenting Partial Adjustment Distributed Lag{col 75}(DLAGRW)
{helpb dlagtq}{col 12}Tweeten-Quance Partial Adjustment Distributed Lag Model{col 75}(DLAGTQ)
{hline 83}

{bf:*** Demand System Models}
{helpb dles}{col 12}Linear Expenditure System (LES){col 75}(DLES)
{helpb deles}{col 12}Extended Linear Expenditure System (ELES){col 75}(DELES)
{helpb dqes}{col 12}Quadratic Expenditure System (QES){col 75}(DQES)
{helpb drot}{col 12}Rotterdam Demand System{col 75}(DROT)
{helpb droti}{col 12}Inverse Rotterdam Demand System{col 75}(DROTI)
{helpb daidsla}{col 12}Linear Approximation Almost Ideal Demand System (AIDS-LA){col 75}(DAIDSLA)
{helpb daidsfd}{col 12}First Difference Almost Ideal Demand System (AIDS-FD){col 75}(DAIDSFD)
{helpb daidsi}{col 12}Inverse Almost Ideal Demand System(AIDS-I) {col 75}(DAIDSI)
{helpb daidsq}{col 12}Quadratic Almost Ideal Demand System (QAIDS){col 75}(AIDSQ)
{helpb darmin}{col 12}Primal Armington Demand System{col 75}(DARMIN)
{helpb dengel}{col 12}Engel Demand System{col 75}(DENGEL)
{helpb dgads}{col 12}Generalized AddiLog Demand System (GADS){col 75}(DGADS)
{helpb dtlog}{col 12}Transcendental Logarithmic Demand System{col 75}(DTLOG)
{helpb dwork}{col 12}Working Demand System{col 75}(DWORK)
{hline 83}
{helpb prodfm}{col 12}Production Function Models{col 75}(PRODFM)
{hline 83}
{helpb proffm}{col 12}Profit Function Models{col 75}(PROFFM)
{hline 83}
{helpb costfm}{col 12}Cost Function Models{col 75}(COSTFM)
{helpb cost3}{col 12}Quadratic and Cubic Cost Functions{col 75}(COST3)
{hline 83}
{helpb iic}{col 12}Investment Indicators Criteria{col 75}(IIC)
{hline 83}
{helpb iot}{col 12}Leontief Input - Output Table{col 75}(IOT)
{hline 83}
{helpb index}{col 12}Index Numbers{col 75}(INDEX)
{hline 83}
{helpb mef}{col 12}Marketing Efficiency Models{col 75}(MEF)
{hline 83}
{helpb pam}{col 12}Policy Analysis Matrix{col 75}(PAM)
{helpb pem}{col 12}Partial Equilibrium Model{col 75}(PEM)
{hline 83}
{bf:*** Financial Analysis Models}
{helpb fam}{col 12}Financial Analysis Models{col 75}(FAM)
{helpb xbcr}{col 12}Benefit-Cost Ratio{col 75}(XBCR)
{helpb xirr}{col 12}Internal Rate of Return{col 75}(XIRR)
{helpb xmirr}{col 12}Modified Internal Rate of Return{col 75}(XMIRR)
{helpb xnfv}{col 12}Net Future Value{col 75}(XNFV)
{helpb xnpv}{col 12}Net Present Value{col 75}(XNPV)
{helpb xpp}{col 12}Payback Period{col 75}(XPP)
{hline 83}
{bf:*** Trade Models}
{helpb wtm}{col 12}World Trade Models{col 75}(WTM)
{helpb wtic}{col 12}World Trade Indicators Criteria{col 75}(WTIC)
{helpb wtrca}{col 12}World Trade Revealed Comparative Advantage{col 75}(WTRCA)
{helpb wtrgc}{col 12}World Trade Regional Geographical Concentration{col 75}(WTRGC)
{helpb wtsgc}{col 12}World Trade Sectoral Geographical Concentration{col 75}(WTSGC)
{hline 83}

{psee}
{p_end}

