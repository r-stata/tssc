{smcl}
{hline}
{cmd:help: {helpb gs3sls}}{space 50} {cmd:dialog:} {bf:{dialog gs3sls}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:gs3sls: Generalized Spatial Three Stage Least Squares (3SLS)}
{p 9}{bf:Cross Sections Regression}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb gs3sls##01:Syntax}{p_end}
{p 5}{helpb gs3sls##02:Description}{p_end}
{p 5}{helpb gs3sls##03:Method Options}{p_end}
{p 5}{helpb gs3sls##04:Options}{p_end}
{p 5}{helpb gs3sls##05:Spatial Aautocorrelation Tests}{p_end}
{p 5}{helpb gs3sls##06:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb gs3sls##07:Heteroscedasticity Tests}{p_end}
{p 5}{helpb gs3sls##08:Non Normality Tests}{p_end}
{p 5}{helpb gs3sls##09:Saved Results}{p_end}
{p 5}{helpb gs3sls##10:References}{p_end}

{p 1}*** {helpb gs3sls##11:Examples}{p_end}

{p 5}{helpb gs3sls##12:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 3 5 6}
{opt gs3sls} {depvar} {indepvars} {weight} , {opt wmf:ile(weight_file)} {opt var2(varlist)} {opt eq(1, 2)}{p_end} 
{p 3 5 6} 
{err: [} {opt ols 2sls 3sls sure mvreg} {opt lmsp:ac} {opt lmh:et} {opt lmn:orm} {opt diag} {opt test:s} {opt stand inv inv2}{p_end} 
{p 5 5 6} 
{opt aux(varlist)} {opt mfx(lin, log)} {opt ord:er(#)} {opt coll zero tolog} {opt nocons:tant}{p_end} 
{p 5 5 6} 
{opt pred:ict(new_var)} {opt res:id(new_var)} {opt l:evel(#)} {opth vce(vcetype)} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

 {cmd:gs3sls} estimates Generalized Spatial Three Stage Least Squares (3SLS)
 for Cross Sections Regression

{p 2 4 2}{cmd:gs3sls} can generate:{p_end}
    {cmd:- Binary / Standardized Weight Matrix.}
    {cmd:- Inverse  / Inverse Squared Standardized Weight Matrix.}
    {cmd:- Binary / Standardized / Inverse Eigenvalues Variable.}
    {cmd:- Spatial lagged variables up to 4th order.}

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{p 5 5 5}Buse(1973) R2 in {bf:({err:{it:gs3sls}})} may be negative, to avoid negative R2, you can increase number on instrumental variables by choosing order more than 1 {cmd:order(2, 3, 4)}{p_end}

{bf:{err:*** Important Notes:}}
{cmd:gs3sls} generates some variables names with prefix:
{cmd:w1x_ , w2x_ , w3x_ , w4x_ , w1y_ , w2y_ , mstar_ , spat_}
{cmd:So, you must avoid to include variables names with thes prefixes}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Method}}}

{col 3}{opt ols}{col 20}Ordinary Least Squares (OLS)
{col 3}{opt 2sls}{col 20}Two-Stage Least Squares (2SLS)
{col 3}{opt 3sls}{col 20}Three-Stage Least Squares (3SLS)
{col 3}{opt sure}{col 20}Seemingly Unrelated Regression Estimation (SURE)
{col 3}{opt mvreg}{col 20}SURE with OLS DF adjustment (MVREG)

{synoptset 3 tabbed}{...}
{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Options}}}

{col 3}* {opt wmf:ile(weight_file)}{col 20} Open CROSS SECTION weight matrix file.

	Spatial Cross Sections Weight Matrix file must be:
	 1- Square Matrix [NxN] 
	 2- Symmetric Matrix (Optional) 

{col 3}Spatial Weight Matrix has two types: Standardized and binary weight matrix.

{col 3}{opt stand}{col 20}Use Standardized Weight Matrix, (each row sum equals 1)
{col 20}Default is Binary spatial Weight Matrix which each element is 0 or 1

{col 3}{opt inv}{col 20}Use Inverse Standardized Weight Matrix (1/W)

{col 3}{opt inv2}{col 20}Use Inverse Squared Standardized Weight Matrix (1/W^2)

{col 3}{opt zero}{col 20}convert missing values observations to Zero

{col 3}{opt aux(varlist)}{col 20}add Auxiliary Variables into regression model
{col 20}without converting them to spatial lagged variables,
{col 20}or without {cmd:log} form, i.e., dummy variables.

{col 3}{opt ord:er(1, 2, 3, 4)}{col 20} Order of lagged independent variables up to maximum 4th order.

{col 3}{opt eq(1, 2)}{col 20}Tests for equation (#), default is 1.

{col 3}{opt var2(varlist)}{col 20}Dependent-Independent Variables for the second equation.

	var2(varlist) must be combine.
	if you have system of 2 Equations:
	Y1 = Y2 X1 X2
	Y2 = Y1 X3 X4
	Variables of Eq. 1 will be Dep. & Indep. Variables
	Variables of Eq. 2 will be Dep. & Indep. Variables in option var2( ); i.e,
	{stata gs3sls y1 x1 x2 , wmfile(SPWcs) var2(y2 x3 x4) eq(1)}
	{stata gs3sls y1 x1 x2 , wmfile(SPWcs) var2(y2 x3 x4) eq(2)}

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from RHS Equation

{col 3}{opt test:s}{col 20}display ALL lmh, lmn, lmsp, diag tests

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

{col 3}{opt res:id(new_variable)}{col 30}Residuals values variable computed as Ue=Y-Yh

{col 3}{opt iter(#)}{col 20}maximum iterations; default is 100
{col 20} if {opt iter(#)} is reached (100), this means convergence not achieved yet,
{col 20} so you can exceed number of maximum iterations more than 100.

{synopt :{opth vce(vcetype)} {opt ols}, {opt r:obust}, {opt cl:uster}, {opt boot:strap}, {opt jack:knife}, {opt hc2}, {opt hc3}}{p_end}

{col 3}{opt level(#)}{col 20}confidence intervals level; default is level(95)

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Spatial Aautocorrelation Tests}}}

{synopt :{opt lmsp:ac} Spatial Aautocorrelation Tests:}{p_end}
	* Ho: Error has No Spatial AutoCorrelation
	  Ha: Error has    Spatial AutoCorrelation
	    - GLOBAL Moran MI Test
	    - GLOBAL Geary GC Test
	    - GLOBAL Getis-Ords GO Test
	    - Moran MI Error Test
	    - LM Error [SEM] (Burridge) Test
	    - LM Error [SEM] (Robust) Test
	* Ho: Spatial Lagged Dependent Variable has No Spatial AutoCorrelation
	  Ha: Spatial Lagged Dependent Variable has    Spatial AutoCorrelation
	    - LM Lag [SAR]  (Anselin) Test
	    - LM Lag [SAR]  (Robust) Test
	* Ho: No General Spatial AutoCorrelation
	  Ha:    General Spatial AutoCorrelation
	    - LM SAC   (LMErr+LMLag_R) Test
	    - LM SAC   (LMLag+LMErr_R) Test

{synopt :Definitions:}{p_end}

   - Spatial autocorrelation: chock in one country affects neighboring countries

   - Spatial autocorrelation: is correlation of a variable with itself in space.

   - Spatial Lag Model:     Y = BX + rWy + e         ; e = lWe+u
   - Spatial Error Model:   Y = BX + e               ; e = lWe+u
   - Spatial Durbin Model:  Y = BX + aWX* + rWy + e  ; e = lWe+u
   - General Spatial Model: Y = BX + rWy  + LW1y + e ; e = lW1e+u

   - General Spatial Model is used to deal with both types of spatial dependence,
     namely Spatial Lag Dependence and Spatial Error Dependence

   - Spatial Error Model is used to handle the spatial dependence due to
     the omitted variables or errors in measurement through the error term

   - Spatial Autoregressive Model (SAR) is also known as Spatial Lag Model

   - Positive spatial autocorrelation exists when high values correlate
     with high neighboring values or when low values correlate with low
     neighboring values

   - Negative spatial autocorrelation exists when high values correlate
     with low neighboring values and vice versa.

   - presence of positive spatial autocorrelation results in a loss of information,
     which is related to greater uncertainty, less precision, and larger standard errors.

   - Spatial autocorrelation coefficients (in contrast to their counterparts in time)
     are not constrained by -1/+1. Their range depends on the choice of weights matrix.

   - Spatial dependence exists when the value associated with one location
     is dependent on those of other locations.

   - Spatial heterogeneity exists when structural changes related to location
     exist in a dataset, it can result in non-constant error variance
     (heteroscedasticity) across areas, especially when scale-related
     measurement errors are present.

   - Spatial regression models are statistical models that account for
     the presence of spatial effects, i.e., spatial autocorrelation
     (or more generally spatial dependence) and/or spatial heterogeneity.

   - if LM test for spatial lag is more significant than LM test for spatial error,
     and robust LM test for spatial lag is significant but robust LM test for
     spatial error is not, then the appropriate model is spatial lag model.
     Conversely, if LM test for spatial error is more significant than LM test
     for spatial lag and robust LM test for spatial error is significant
     but robust LM test for spatial lag is not, then the appropriate specification
     is spatial error model, [Anselin-Florax (1995)].
	
   - robust versions of Spatial LM tests are considered only when
     standard versions (LM-Lag or LM-Error) are significant
	
   - General Spatial Model is used to deal with both types of spatial dependence,
     namely spatial lag dependence and spatial error dependence
	
   - Spatial Error Model is used to handle spatial dependence due to omitted
     variables or errors in measurement through the error term
	
   - Spatial Autoregressive Model (SAR) is also known as Spatial Lag Model

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Model Selection Diagnostic Criteria}}}

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
{marker 07}{bf:{err:{dlgtab:Heteroscedasticity Tests}}}

{synopt :{opt lmh:et} Heteroscedasticity Tests:}{p_end}
	* Ho: Homoscedasticity - Ha: Heteroscedasticity
	- Hall-Pagan LM Test:  E2 = Yh
	- Hall-Pagan LM Test:  E2 = Yh2
	- Hall-Pagan LM Test:  E2 = LYh2
	- Harvey LM Test:    LogE2 = X
	- Wald Test:         LogE2 = X
	- Glejser LM Test:    |E| = X
	- Machado-Santos-Silva LM Test: Ev= Yh Yh2
	- Machado-Santos-Silva LM Test: Ev= X
	- White Test - Koenker(R2): E2 = X
	- White Test - B-P-G (SSR): E2 = X
	- White Test - Koenker(R2): E2 = X X2
	- White Test - B-P-G (SSR): E2 = X X2
	- White Test - Koenker(R2): E2 = X X2 XX
	- White Test - B-P-G (SSR): E2 = X X2 XX
	- Cook-Weisberg LM Test E = Yh
	- Cook-Weisberg LM Test E = X
	*** Single Variable Tests
		- Cook-Weisberg LM Test: E = xi
		- King LM Test: E = xi

	*** Tobit Model Heteroscedasticity LM Tests
 		- Separate LM Tests - Ho: Homoscedasticity
		- Joint LM Test     - Ho: Homoscedasticity

{p2colreset}{...}
{marker 08}{bf:{err:{dlgtab:Non Normality Tests}}}

{synopt :{opt lmn:orm} Non Normality Tests:}{p_end}
	* Ho: Normality - Ha: Non Normality
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
		- Skewness Coefficient - Standard Deviation
	*** Kurtosis Tests:
		- Srivastava Z Kurtosis Test
		- Small LM Kurtosis Test
		- Kurtosis Z Test
    		- Kurtosis Coefficient - Standard Deviation
	*** Runs Tests:
    		- Runs Test:
		- Standard Deviation Runs Sig(k) - Mean Runs E(k)
    		- 95% Conf. Interval [E(k)+/- 1.96* Sig(k)]
	*** Tobit cross section Non Normality Tests
		*** LM Test - Ho: No Skewness
		*** LM test - Ho: No Kurtosis
		*** LM Test - Ho: Normality (No Kurtosis, No Skewness)
		    - Pagan-Vella LM Test
		    - Chesher-Irish LM Test

{p2colreset}{...}
{marker 09}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:gs3sls} saves the following results in {cmd:e()}:

Scalars

{err:*** Spatial Aautocorrelation Tests:}
{col 4}{cmd:e(mig)}{col 20}GLOBAL Moran MI Test
{col 4}{cmd:e(migp)}{col 20}GLOBAL Moran MI Test P-Value
{col 4}{cmd:e(gcg)}{col 20}GLOBAL Geary GC Test
{col 4}{cmd:e(gcgp)}{col 20}GLOBAL Geary GC Test P-Value
{col 4}{cmd:e(gog)}{col 20}GLOBAL Getis-Ords Test GO
{col 4}{cmd:e(gogp)}{col 20}GLOBAL Getis-Ords GO Test P-Value
{col 4}{cmd:e(mi1)}{col 20}Moran MI Error Test
{col 4}{cmd:e(mi1p)}{col 20}Moran MI Error Test P-Value
{col 4}{cmd:e(lmerr)}{col 20}LM Error (Burridge) Test
{col 4}{cmd:e(lmerrp)}{col 20}LM Error (Burridge) Test P-Value
{col 4}{cmd:e(lmerrr)}{col 20}LM Error (Robust) Test
{col 4}{cmd:e(lmerrrp)}{col 20}LM Error (Robust) Test P-Value
{col 4}{cmd:e(lmlag)}{col 20}LM Lag (Anselin) Test
{col 4}{cmd:e(lmlagp)}{col 20}LM Lag (Anselin) Test P-Value
{col 4}{cmd:e(lmlagr)}{col 20}LM Lag (Robust) Test
{col 4}{cmd:e(lmlagrp)}{col 20}LM Lag (Robust) Test P-Value
{col 4}{cmd:e(lmsac1)}{col 20}LM SAC (LMLag+LMErr_R) Test
{col 4}{cmd:e(lmsac1p)}{col 20}LM SAC (LMLag+LMErr_R) Test P-Value
{col 4}{cmd:e(lmsac2)}{col 20}LM SAC (LMErr+LMLag_R) Test
{col 4}{cmd:e(lmsac2p)}{col 20}LM SAC (LMErr+LMLag_R) Test P-Value

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

{err:*** Heteroscedasticity Tests:}
{col 4}{cmd:e(lmhhp1)}{col 20}Hall-Pagan LM Test E2 = Yh
{col 4}{cmd:e(lmhhp1p)}{col 20}Hall-Pagan LM Test E2 = Yh P-Value
{col 4}{cmd:e(lmhhp2)}{col 20}Hall-Pagan LM Test E2 = Yh2
{col 4}{cmd:e(lmhhp2p)}{col 20}Hall-Pagan LM Test E2 = Yh2 P-Value
{col 4}{cmd:e(lmhhp3)}{col 20}Hall-Pagan LM Test E2 = Yh3
{col 4}{cmd:e(lmhhp3p)}{col 20}Hall-Pagan LM Test E2 = Yh3 P-Value
{col 4}{cmd:e(lmhw01)}{col 20}White Test - Koenker(R2) E2 = X
{col 4}{cmd:e(lmhw01p)}{col 20}White Test - Koenker(R2) E2 = X P-Value
{col 4}{cmd:e(lmhw02)}{col 20}White Test - B-P-G (SSR) E2 = X
{col 4}{cmd:e(lmhw02p)}{col 20}White Test - B-P-G (SSR) E2 = X P-Value
{col 4}{cmd:e(lmhw11)}{col 20}White Test - Koenker(R2) E2 = X X2
{col 4}{cmd:e(lmhw11p)}{col 20}White Test - Koenker(R2) E2 = X X2 P-Value
{col 4}{cmd:e(lmhw12)}{col 20}White Test - B-P-G (SSR) E2 = X X2
{col 4}{cmd:e(lmhw12p)}{col 20}White Test - B-P-G (SSR) E2 = X X2 P-Value
{col 4}{cmd:e(lmhw21)}{col 20}White Test - Koenker(R2) E2 = X X2 XX
{col 4}{cmd:e(lmhw21p)}{col 20}White Test - Koenker(R2) E2 = X X2 XX P-Value
{col 4}{cmd:e(lmhw22)}{col 20}White Test - B-P-G (SSR) E2 = X X2 XX
{col 4}{cmd:e(lmhw22p)}{col 20}White Test - B-P-G (SSR) E2 = X X2 XX P-Value
{col 4}{cmd:e(lmhharv)}{col 20}Harvey LM Test
{col 4}{cmd:e(lmhharvp)}{col 20}Harvey LM Test P-Value
{col 4}{cmd:e(lmhwald)}{col 20}Wald Test
{col 4}{cmd:e(lmhwaldp)}{col 20}Wald Test P-Value
{col 4}{cmd:e(lmhgl)}{col 20}Glejser LM Test
{col 4}{cmd:e(lmhglp)}{col 20}Glejser LM Test P-Value
{col 4}{cmd:e(lmhmss1)}{col 20}Machado-Santos-Silva  LM Test: Ev=Yh Yh2
{col 4}{cmd:e(lmhmss1p)}{col 20}Machado-Santos-Silva LM Test: Ev=Yh Yh2 P-Value
{col 4}{cmd:e(lmhmss2)}{col 20}Machado-Santos-Silva  LM Test: Ev=X
{col 4}{cmd:e(lmhmss2p)}{col 20}Machado-Santos-Silva LM Test: Ev=X P-Value
{col 4}{cmd:e(lmhcw1)}{col 20}Cook-Weisberg LM Test E = Yh
{col 4}{cmd:e(lmhcw1p)}{col 20}Cook-Weisberg LM Test E = Y P-Valueh
{col 4}{cmd:e(lmhcw2)}{col 20}Cook-Weisberg LM Test E = X
{col 4}{cmd:e(lmhcw2p)}{col 20}Cook-Weisberg LM Test E = X P-Value

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
{col 4}{cmd:e(lmnsms1)}{col 20}Small LM Skewness Test
{col 4}{cmd:e(lmnsms1p)}{col 20}Small LM Skewness Test P-Value
{col 4}{cmd:e(lmnsms2)}{col 20}Skewness Z Test
{col 4}{cmd:e(lmnsms2p)}{col 20}Skewness Z Test P-Value
{col 4}{cmd:e(lmnsvk)}{col 20}Srivastava Z Kurtosis Test
{col 4}{cmd:e(lmnsvkp)}{col 20}Srivastava Z Kurtosis Test P-Value
{col 4}{cmd:e(lmnsmk1)}{col 20}Small LM Kurtosis Test
{col 4}{cmd:e(lmnsmk1p)}{col 20}Small LM Kurtosis Test P-Value
{col 4}{cmd:e(lmnsmk2)}{col 20}Kurtosis Z Test
{col 4}{cmd:e(lmnsmk2p)}{col 20}Kurtosis Z Test P-Value
{col 4}{cmd:e(sk)}{col 20}Skewness Coefficient
{col 4}{cmd:e(sksd)}{col 20}Skewness Standard Deviation
{col 4}{cmd:e(ku)}{col 20}Kurtosis Coefficient
{col 4}{cmd:e(kusd)}{col 20}Kurtosis Standard Deviation
{col 4}{cmd:e(sn)}{col 20}Standard Deviation Runs Sig(k)
{col 4}{cmd:e(en)}{col 20}Mean Runs E(k)
{col 4}{cmd:e(lower)}{col 20}Lower 95% Conf. Interval [E(k)- 1.96* Sig(k)]
{col 4}{cmd:e(upper)}{col 20}Upper 95% Conf. Interval [E(k)+ 1.96* Sig(k)]

{col 4}{cmd:e(lmnpv)}{col 20}Pagan-Vella LM Test (Tobit Model)
{col 4}{cmd:e(lmnpvp)}{col 20}Pagan-Vella LM Test (Tobit Model) P-Value
{col 4}{cmd:e(lmnci)}{col 20}Chesher-Irish LM Test (Tobit Model)
{col 4}{cmd:e(lmncip)}{col 20}Chesher-Irish LM Test (Tobit Model) P-Value

Macros         
{col 4}{cmd:e(cmd)}{col 20}name of the command
{col 4}{cmd:e(cmdline)}{col 20}command as typed
{col 4}{cmd:e(depvar)}{col 20}Name of dependent variable
{col 4}{cmd:e(predict)}{col 20}program used to implement {cmd:predict}
{col 4}{cmd:e(wmat)}{col 20}name of spatial weight matrix
{col 4}{cmd:e(dlmat)}{col 20}name of {cmd:spmat} object in {cmd:dlmat()}
{col 4}{cmd:e(elmat)}{col 20}name of {cmd:spmat} object in {cmd:elmat()}
{col 4}{cmd:e(endog)}{col 20}names of endogenous variables
{col 4}{cmd:e(eqnames)}{col 20}names of equations
{col 4}{cmd:e(het)}{col 20}{cmd:heteroskedastic} or {cmd:homoskedastic}
{col 4}{cmd:e(technique)}{col 20}maximization technique from technique() option
{col 4}{cmd:e(title)}{col 20}title in estimation output

Matrixes       
{col 4}{cmd:e(b)}{col 20}coefficient vector
{col 4}{cmd:e(V)}{col 20}variance-covariance matrix of the estimators
{col 4}{cmd:e(mfxlin)}{col 20}Marginal Effect and Elasticity in Lin Form
{col 4}{cmd:e(mfxlog)}{col 20}Marginal Effect and Elasticity in Log Form

{col 4}{cmd:e(gradient)}{col 20}gradient vector
{col 4}{cmd:e(ilog)}{col 20}iteration log (up to 20 iterations)
{col 4}{cmd:e(ml_h)}{col 20}derivative tolerance, {cmd:(abs(b)+1e-3)*1e-3}
{col 4}{cmd:e(ml_scale)}{col 20}derivative scale factor
{col 4}{cmd:e(Sigma)}{col 20}Sigma hat matrix

Functions      
{col 4}{cmd:e(sample)}{col 20}marks estimation sample

{marker 10}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Anselin, L. (2001)
{cmd: "Spatial Econometrics",}
{it:In Baltagi, B. (Ed).: A Companion to Theoretical Econometrics Basil Blackwell: Oxford, UK}.

{p 4 8 2}Anselin, L. (2007)
{cmd: "Spatial Econometrics",}
{it:In T. C. Mills and K. Patterson (Eds).: Palgrave Handbook of Econometrics. Vol 1, Econometric Theory. New York: Palgrave MacMillan}.

{p 4 8 2}Anselin, L. & Kelejian, H. H. (1997)
{cmd: "Testing for Spatial Error Autocorrelation in the Presence of Endogenous Regressors",}
{it:International Regional Science Review, (20)}; 153-182.

{p 4 8 2}Anselin, L. & Florax RJ. (1995)
{cmd: "New Directions in Spatial Econometrics: Introduction. In New Directions in Spatial Econometrics",}
{it:Anselin L, Florax RJ (eds). Berlin, Germany: Springer-Verlag}.

{p 4 8 2}Breusch, Trevor & Adrian Pagan (1980)
{cmd: "The Lagrange Multiplier Test and its Applications to Model Specification in Econometrics",}
{it:Review of Economic Studies 47}; 239-253.

{p 4 8 2}C.M. Jarque  & A.K. Bera (1987)
{cmd: "A Test for Normality of Observations and Regression Residuals"}
{it:International Statistical Review} , Vol. 55; 163-172.

{p 4 8 2}Cook, R.D., & S. Weisberg (1983)
{cmd: "Diagnostics for Heteroscedasticity in Regression",}
{it:Biometrica 70}; 1-10.

{p 4 8 2}D'Agostino, R. B., & Rosman, B. (1974)
{cmd: "The Power of Geary’s Test of Normality",}
{it:Biometrika, 61(1)}; 181-184.

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}Geary R.C. (1947)
{cmd: "Testing for Normality"} {it:Biometrika, Vol. 34}; 209-242.

{p 4 8 2}Geary R.C. (1970)
{cmd: "Relative Efficiency of Count of Sign Changes for Assessing Residuals Autoregression in Least Squares Regression"}
{it:Biometrika, Vol. 57}; 123-127.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Macmillan Publishing Company Inc., New York, USA.}.

{p 4 8 2}Griffiths, W., R. Carter Hill & George Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.

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
{it:2nd ed., Macmillan Publishing Company, Inc., New York, USA}; 618-625.

{p 4 8 2}Koenker, R. (1981)
{cmd: "A Note on Studentizing a Test for Heteroskedasticity",}
{it:Journal of Econometrics, Vol.17}; 107-112.

{p 4 8 2}Pagan, Adrian .R. & Hall, D. (1983)
{cmd: "Diagnostic Tests as Residual Analysis",}
{it:Econometric Reviews, Vol.2, No.2,}. 159-218.

{p 4 8 2}Pearson, E. S., D'Agostino, R. B., & Bowman, K. O. (1977)
{cmd: "Tests for Departure from Normality: Comparison of Powers",}
{it:Biometrika, 64(2)}; 231-246.

{p 4 8 2}Szroeter, J. (1978)
{cmd: "A Class of Parametric Tests for Heteroscedasticity in Linear Econometric Models",}
{it:Econometrica, 46}; 1311-28.

{p2colreset}{...}
{marker 11}{bf:{err:{dlgtab:Examples}}}

{bf:Note 1:} you can use: {helpb spweight}, {helpb spweightcs}, {helpb spweightxt} to create Spatial Weight Matrix.
{bf:Note 2:} Remember, your spatial weight matrix must be:
    *** {bf:{err:1-Cross Section Dimention  2- Square Matrix 3- Symmetric Matrix}}
{bf:Note 3:} You can use the dialog box for {dialog gs3sls}.
{hline}

{stata clear all}

{stata sysuse gs3sls.dta, clear}

* Y1 = Y2 X1 X2
* Y2 = Y1 X3 X4

{bf:* (1) Generalized Spatial 3SLS - AR(1) (GS3SLS)}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(1) mfx(lin) test}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(1) mfx(lin) test}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(1) mfx(lin) test aux(x5)}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(1) mfx(log) test tolog}
{hline}

{bf:* (2) Generalized Spatial 3SLS - AR(2) (GS3SLS)}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(2) mfx(lin) test}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(2) mfx(lin) test}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(2) mfx(lin) test aux(x5)}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(2) mfx(log) test tolog}
{hline}

{bf:* (3) Generalized Spatial 3SLS - AR(3) (GS3SLS)}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(3) mfx(lin) test}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(3) mfx(lin) test}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(3) mfx(lin) test aux(x5)}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(3) mfx(log) test tolog}
{hline}

{bf:* (4) Generalized Spatial 3SLS - AR(4) (GS3SLS)}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(4) mfx(lin) test}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(4) mfx(lin) test}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(4) mfx(lin) test aux(x5)}
{stata gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(4) mfx(log) test tolog}
{hline}

. clear all
. sysuse gs3sls.dta, clear
. gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(1) mfx(lin) test

==============================================================================
*** Binary (0/1) Weight Matrix: 49x49 (Non Normalized)
==============================================================================
==============================================================================
* Generalized Spatial Three Stage Least Squares (GS3SLS)
==============================================================================
  y1 = w1y_y1 + w1y_y2 + y2 + x1 + x2
------------------------------------------------------------------------------
  y2 = w1y_y2 + w1y_y1 + y1 + x3 + x4
------------------------------------------------------------------------------

Three-stage least-squares regression
----------------------------------------------------------------------
Equation          Obs  Parms        RMSE    "R-sq"     F-Stat        P
----------------------------------------------------------------------
y1                 49      5    9.657283    0.7016      26.20   0.0000
y2                 49      5    7.414835    0.8091      52.39   0.0000
----------------------------------------------------------------------

------------------------------------------------------------------------------
             |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y1           |
      w1y_y1 |   .1382035   .1740695     0.79   0.429    -.2078352    .4842423
      w1y_y2 |  -.1088995   .1664627    -0.65   0.515    -.4398164    .2220174
          y2 |   .8254616   .1429166     5.78   0.000     .5413529     1.10957
          x1 |  -.0593876   .0751261    -0.79   0.431    -.2087333    .0899582
          x2 |   -.230459   .3059294    -0.75   0.453    -.8386265    .3777085
       _cons |   5.357097   10.72446     0.50   0.619    -15.96243    26.67662
-------------+----------------------------------------------------------------
y2           |
      w1y_y2 |   .0538141   .1144285     0.47   0.639    -.1736622    .2812905
      w1y_y1 |  -.0685151   .1202225    -0.57   0.570    -.3075095    .1704794
          y1 |   .5043856    .204935     2.46   0.016     .0969882    .9117829
          x3 |   .0517263   .0898243     0.58   0.566    -.1268385     .230291
          x4 |   .3148184   .0914127     3.44   0.001      .133096    .4965409
       _cons |   2.931701   3.871633     0.76   0.451    -4.764852    10.62825
------------------------------------------------------------------------------
Endogenous variables:  y1 y2 w1y_y1 w1y_y2 
Exogenous variables:   x1 x2 x3 x4 w1x_x1 w1x_x2 w1x_x3 w1x_x4 w2x_x1 w2x_x2 
     w2x_x3 w2x_x4 
------------------------------------------------------------------------------
EQ1: R2= 0.7016 - R2 Adj.= 0.6669  F-Test =   19.748   P-Value> F(5, 42) 
   LLF =  -177.446   AIC =  366.891    SC =  378.242   Root MSE =  9.6573

EQ2: R2= 0.8091 - R2 Adj.= 0.7868  F-Test =   35.591   P-Value> F(5, 42) 
   LLF =  -164.498   AIC =  340.997    SC =  352.348   Root MSE =  7.4148
   Yij = LHS Y(i) in Eq.(j)
------------------------------------------------------------------------------

- Overall System R2 - Adjusted R2 - F Test - Chi2 Test

+----------------------------------------------------------------------------+
|     Name |       R2 |   Adj_R2 |        F |  P-Value |     Chi2 |  P-Value |
|----------+----------+----------+----------+----------+----------+----------|
|   Berndt |   0.9525 |   0.9469 | 176.3281 |   0.0000 | 149.2685 |   0.0000 |
|  McElroy |   0.9652 |   0.9611 | 243.8002 |   0.0000 | 164.4958 |   0.0000 |
|    Judge |   0.7531 |   0.7244 |  26.8438 |   0.0000 |  68.5424 |   0.0000 |
+----------------------------------------------------------------------------+
  Number of Parameters         =          12
  Number of Equations          =           2
  Degrees of Freedom F-Test    =      (10, 88)
  Degrees of Freedom Chi2-Test =          10
  Log Determinant of Sigma     =     -6.9131
  Log Likelihood Function      =   -308.4281
------------------------------------------------------------------------------

  y1 = w1y_y1 + w1y_y2 + y2 + x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          49
  Wald Test         =    130.9922   |   P-Value > Chi2(5)       =      0.0000
  F-Test            =     26.1984   |   P-Value > F(5 , 43)     =      0.0000
 (Buse 1973) R2     =      0.7016   |   Raw Moments R2          =      0.9457
 (Buse 1973) R2 Adj =      0.6669   |   Raw Moments R2 Adj      =      0.9394
  Root MSE (Sigma)  =      9.6573   |   Log Likelihood Function =   -177.4457
------------------------------------------------------------------------------
- R2h= 0.7124   R2h Adj= 0.6790  F-Test =   21.30 P-Value > F(5 , 43)  0.0000
- R2v= 0.8989   R2v Adj= 0.8871  F-Test =   76.43 P-Value > F(5 , 43)  0.0000
------------------------------------------------------------------------------
          y1 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y1           |
      w1y_y1 |   .1382035   .1740695     0.79   0.432    -.2128411    .4892482
      w1y_y2 |  -.1088995   .1664627    -0.65   0.516    -.4446036    .2268046
          y2 |   .8254616   .1429166     5.78   0.000     .5372429     1.11368
          x1 |  -.0593876   .0751261    -0.79   0.434    -.2108938    .0921187
          x2 |   -.230459   .3059294    -0.75   0.455    -.8474244    .3865064
       _cons |   5.357097   10.72446     0.50   0.620    -16.27084    26.98503
------------------------------------------------------------------------------
  Rho Value  =  0.1382       F Test =     0.630    P-Value > F(1, 43)   0.4316
------------------------------------------------------------------------------

==============================================================================
*** Spatial Aautocorrelation Tests
==============================================================================
  Ho: Error has No Spatial AutoCorrelation
  Ha: Error has    Spatial AutoCorrelation

- GLOBAL Moran MI            =  -0.1656     P-Value > Z(-1.700)   0.0891
- GLOBAL Geary GC            =   1.1315     P-Value > Z(1.037)    0.2996
- GLOBAL Getis-Ords GO       =   0.7975     P-Value > Z(1.700)    0.0891
------------------------------------------------------------------------------
- Moran MI Error Test        =   0.0204     P-Value > Z(0.485)    0.9837
------------------------------------------------------------------------------
- LM Error (Burridge)        =   2.4912     P-Value > Chi2(1)     0.1145
- LM Error (Robust)          =   5.2022     P-Value > Chi2(1)     0.0226
------------------------------------------------------------------------------
  Ho: Spatial Lagged Dependent Variable has No Spatial AutoCorrelation
  Ha: Spatial Lagged Dependent Variable has    Spatial AutoCorrelation

- LM Lag (Anselin)           =   0.9855     P-Value > Chi2(1)     0.3208
- LM Lag (Robust)            =   3.6965     P-Value > Chi2(1)     0.0545
------------------------------------------------------------------------------
  Ho: No General Spatial AutoCorrelation
  Ha:    General Spatial AutoCorrelation

- LM SAC (LMErr+LMLag_R)     =   6.1877     P-Value > Chi2(2)     0.0453
- LM SAC (LMLag+LMErr_R)     =   6.1877     P-Value > Chi2(2)     0.0453
------------------------------------------------------------------------------

==============================================================================
* Model Selection Diagnostic Criteria
==============================================================================
- Log Likelihood Function       LLF               =  -177.4457
- Akaike Final Prediction Error AIC               =   366.8914
- Schwarz Criterion             SC                =   378.2423
- Akaike Information Criterion  ln AIC            =     4.6497
- Schwarz Criterion             ln SC             =     4.8814
- Amemiya Prediction Criterion  FPE               =   104.6831
- Hannan-Quinn Criterion        HQ                =   114.1588
- Rice Criterion                Rice              =   108.3869
- Shibata Criterion             Shibata           =   101.8864
- Craven-Wahba Generalized Cross Validation-GCV   =   106.2766
------------------------------------------------------------------------------

==============================================================================
* Heteroscedasticity Tests
==============================================================================
 Ho: Homoscedasticity - Ha: Heteroscedasticity
------------------------------------------------------------------------------
- Hall-Pagan LM Test:      E2 = Yh     =   0.2800    P-Value > Chi2(1)  0.5967
- Hall-Pagan LM Test:      E2 = Yh2    =   0.2935    P-Value > Chi2(1)  0.5880
- Hall-Pagan LM Test:      E2 = LYh2   =   0.2923    P-Value > Chi2(1)  0.5887
------------------------------------------------------------------------------
- Harvey LM Test:       LogE2 = X      =   5.3239    P-Value > Chi2(2)  0.0698
- Wald LM Test:         LogE2 = X      =  13.1361    P-Value > Chi2(1)  0.0003
- Glejser LM Test:        |E| = X      =   5.6783    P-Value > Chi2(2)  0.0585
------------------------------------------------------------------------------
- Machado-Santos-Silva Test: Ev=Yh Yh2 =   0.1658    P-Value > Chi2(2)  0.9204
- Machado-Santos-Silva Test: Ev=X      =   4.7179    P-Value > Chi2(5)  0.4513
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X      =   6.4325    P-Value > Chi2(5)  0.2664
- White Test -B-P-G (SSR): E2 = X      =   8.1169    P-Value > Chi2(5)  0.1499
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X X2   =  20.6287    P-Value > Chi2(10) 0.0238
- White Test -B-P-G (SSR): E2 = X X2   =  26.0304    P-Value > Chi2(10) 0.0037
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X X2 XX=  31.9934    P-Value > Chi2(20) 0.0434
- White Test -B-P-G (SSR): E2 = X X2 XX=  40.3709    P-Value > Chi2(20) 0.0045
------------------------------------------------------------------------------
- Cook-Weisberg LM Test  E2/Sig2 = Yh  =   0.3534    P-Value > Chi2(1)  0.5522
- Cook-Weisberg LM Test  E2/Sig2 = X   =   8.1169    P-Value > Chi2(5)  0.1499
------------------------------------------------------------------------------
*** Single Variable Tests (E2/Sig2):
- Cook-Weisberg LM Test: w1y_y1            =   0.5190 P-Value > Chi2(1) 0.4713
- Cook-Weisberg LM Test: w1y_y2            =   0.6825 P-Value > Chi2(1) 0.4087
- Cook-Weisberg LM Test: y2                =   0.6179 P-Value > Chi2(1) 0.4318
- Cook-Weisberg LM Test: x1                =   0.8495 P-Value > Chi2(1) 0.3567
- Cook-Weisberg LM Test: x2                =   1.2808 P-Value > Chi2(1) 0.2577
------------------------------------------------------------------------------
*** Single Variable Tests:
- King LM Test: w1y_y1                     =   0.5607 P-Value > Chi2(1) 0.4540
- King LM Test: w1y_y2                     =   1.0068 P-Value > Chi2(1) 0.3157
- King LM Test: y2                         =   0.3213 P-Value > Chi2(1) 0.5709
- King LM Test: x1                         =   1.1330 P-Value > Chi2(1) 0.2871
- King LM Test: x2                         =   1.8200 P-Value > Chi2(1) 0.1773

==============================================================================
* Non Normality Tests
==============================================================================
 Ho: Normality - Ha: Non Normality
------------------------------------------------------------------------------
*** Non Normality Tests:
- Jarque-Bera LM Test                  =   3.4424     P-Value > Chi2(2) 0.1788
- White IM Test                        =   8.5563     P-Value > Chi2(2) 0.0139
- Doornik-Hansen LM Test               =   3.3724     P-Value > Chi2(2) 0.1852
- Geary LM Test                        =  -1.8746     P-Value > Chi2(2) 0.3917
- Anderson-Darling Z Test              =   0.7111     P > Z( 1.530)     0.9370
- D'Agostino-Pearson LM Test           =   4.5575     P-Value > Chi2(2) 0.1024
------------------------------------------------------------------------------
*** Skewness Tests:
- Srivastava LM Skewness Test          =   2.8825     P-Value > Chi2(1) 0.0895
- Small LM Skewness Test               =   3.2377     P-Value > Chi2(1) 0.0720
- Skewness Z Test                      =   1.7994     P-Value > Chi2(1) 0.0720
------------------------------------------------------------------------------
*** Kurtosis Tests:
- Srivastava  Z Kurtosis Test          =   0.7483     P-Value > Z(0,1)  0.4543
- Small LM Kurtosis Test               =   1.3198     P-Value > Chi2(1) 0.2506
- Kurtosis Z Test                      =   1.1488     P-Value > Chi2(1) 0.2506
------------------------------------------------------------------------------
    Skewness Coefficient =  0.5941     - Standard Deviation =  0.3398
    Kurtosis Coefficient =  3.5237     - Standard Deviation =  0.6681
------------------------------------------------------------------------------
    Runs Test: (19) Runs -  (25) Positives - (24) Negatives
    Standard Deviation Runs Sig(k) =  3.4619 , Mean Runs E(k) = 25.4898
    95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (18.7045 , 32.2751 )
------------------------------------------------------------------------------

* Linear: Marginal Effect - Elasticity *

+-----------------------------------------------------------------------------+
|     Variable | Marginal_Effect(B) |     Elasticity(Es) |               Mean |
|--------------+--------------------+--------------------+--------------------|
|y1            |                    |                    |                    |
|       w1y_y1 |             0.1382 |             0.6704 |           170.4034 |
|       w1y_y2 |            -0.1089 |            -0.5748 |           185.4260 |
|           y2 |             0.8255 |             0.9112 |            38.7779 |
|           x1 |            -0.0594 |            -0.0650 |            38.4362 |
|           x2 |            -0.2305 |            -0.0943 |            14.3749 |
+-----------------------------------------------------------------------------+
 Mean of Dependent Variable =     35.1288

{p2colreset}{...}
{marker 12}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:GS3SLS Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:GS3SLS: "Generalized Spatial Three Stage Least Squares (3SLS) Cross Sections Regression"}{p_end}


{title:Online Help:}

{bf:{err:*** Spatial Econometrics Regression Models:}}

--------------------------------------------------------------------------------
{bf:{err:*** (1) Spatial Panel Data Regression Models:}}
{helpb spregxt}{col 14}Spatial Panel Regression Econometric Models: {cmd:Stata Module Toolkit}
{helpb gs2slsxt}{col 14}Generalized Spatial Panel 2SLS Regression
{helpb gs2slsarxt}{col 14}Generalized Spatial Panel Autoregressive 2SLS Regression
{helpb spglsxt}{col 14}Spatial Panel Autoregressive Generalized Least Squares Regression
{helpb spgmmxt}{col 14}Spatial Panel Autoregressive Generalized Method of Moments Regression
{helpb spmstarxt}{col 14}(m-STAR) Spatial Lag Panel Models
{helpb spmstardxt}{col 14}(m-STAR) Spatial Durbin Panel Models
{helpb spmstardhxt}{col 14}(m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Panel Models
{helpb spmstarhxt}{col 14}(m-STAR) Spatial Lag Multiplicative Heteroscedasticity Panel Models
{helpb spregdhp}{col 14}Spatial Panel Han-Philips Linear Dynamic Regression: Lag & Durbin Models
{helpb spregdpd}{col 14}Spatial Panel Arellano-Bond Linear Dynamic Regression: Lag & Durbin Models
{helpb spregfext}{col 14}Spatial Panel Fixed Effects Regression: Lag & Durbin Models
{helpb spregrext}{col 14}Spatial Panel Random Effects Regression: Lag & Durbin Models
{helpb spregsacxt}{col 14}MLE Spatial AutoCorrelation Panel Regression (SAC)
{helpb spregsarxt}{col 14}MLE Spatial Lag Panel Regression (SAR)
{helpb spregsdmxt}{col 14}MLE Spatial Durbin Panel Regression (SDM)
{helpb spregsemxt}{col 14}MLE Spatial Error Panel Regression (SEM)
--------------------------------------------------------------------------------
{bf:{err:*** (2) Spatial Cross Section Regression Models:}}
{helpb spregcs}{col 14}Spatial Cross Section Regression Econometric Models: {cmd:Stata Module Toolkit}
{helpb gs2sls}{col 14}Generalized Spatial 2SLS Cross Sections Regression
{helpb gs2slsar}{col 14}Generalized Spatial Autoregressive 2SLS Cross Sections Regression
{helpb gs3sls}{col 14}Generalized Spatial 3SLS Cross Sections Regression
{helpb gs3slsar}{col 14}Generalized Spatial Autoregressive 3SLS Cross Sections Regression
{helpb spautoreg}{col 14}Spatial Cross Section Regression Models
{helpb spgmm}{col 14}Spatial Autoregressive GMM Cross Sections Regression
{helpb spmstar}{col 14}(m-STAR) Spatial Lag Cross Sections Models
{helpb spmstard}{col 14}(m-STAR) Spatial Durbin Cross Sections Models
{helpb spmstardh}{col 14}(m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Cross Sections Models
{helpb spmstarh}{col 14}(m-STAR) Spatial Lag Multiplicative Heteroscedasticity Cross Sections Models
{helpb spregsac}{col 14}MLE Spatial AutoCorrelation Cross Sections Regression (SAC)
{helpb spregsar}{col 14}MLE Spatial Lag Cross Sections Regression (SAR)
{helpb spregsdm}{col 14}MLE Spatial Durbin Cross Sections Regression (SDM)
{helpb spregsem}{col 14}MLE Spatial Error Cross Sections Regression (SEM)
--------------------------------------------------------------------------------
{bf:{err:*** (3) Tobit Spatial Regression Models:}}

{bf:*** (3-1) Tobit Spatial Panel Data Regression Models:}
{helpb sptobitgmmxt}{col 14}Tobit Spatial GMM Panel Regression
{helpb sptobitmstarxt}{col 14}Tobit (m-STAR) Spatial Lag Panel Models
{helpb sptobitmstardxt}{col 14}Tobit (m-STAR) Spatial Durbin Panel Models
{helpb sptobitmstardhxt}{col 14}Tobit (m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Panel Models
{helpb sptobitmstarhxt}{col 14}Tobit (m-STAR) Spatial Lag Multiplicative Heteroscedasticity Panel Models
{helpb sptobitsacxt}{col 14}Tobit MLE Spatial AutoCorrelation (SAC) Panel Regression
{helpb sptobitsarxt}{col 14}Tobit MLE Spatial Lag Panel Regression
{helpb sptobitsdmxt}{col 14}Tobit MLE Spatial Panel Durbin Regression
{helpb sptobitsemxt}{col 14}Tobit MLE Spatial Error Panel Regression
{helpb spxttobit}{col 14}Tobit Spatial Panel Autoregressive GLS Regression
--------------------------------------------------------------
{bf:*** (3-2) Tobit Spatial Cross Section Regression Models:}
{helpb sptobitgmm}{col 14}Tobit Spatial GMM Cross Sections Regression
{helpb sptobitmstar}{col 14}Tobit (m-STAR) Spatial Lag Cross Sections Models
{helpb sptobitmstard}{col 14}Tobit (m-STAR) Spatial Durbin Cross Sections Models
{helpb sptobitmstardh}{col 14}Tobit (m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Cross Sections
{helpb sptobitmstarh}{col 14}Tobit (m-STAR) Spatial Lag Multiplicative Heteroscedasticity Cross Sections
{helpb sptobitsac}{col 14}Tobit MLE AutoCorrelation (SAC) Cross Sections Regression
{helpb sptobitsar}{col 14}Tobit MLE Spatial Lag Cross Sections Regression
{helpb sptobitsdm}{col 14}Tobit MLE Spatial Durbin Cross Sections Regression
{helpb sptobitsem}{col 14}Tobit MLE Spatial Error Cross Sections Regression
--------------------------------------------------------------------------------
{bf:{err:*** (4) Spatial Weight Matrix:}}
{helpb spcs2xt}{col 14}Convert Cross Section to Panel Spatial Weight Matrix
{helpb spweight}{col 14}Cross Section and Panel Spatial Weight Matrix
{helpb spweightcs}{col 14}Cross Section Spatial Weight Matrix
{helpb spweightxt}{col 14}Panel Spatial Weight Matrix
--------------------------------------------------------------------------------

{psee}
{p_end}

