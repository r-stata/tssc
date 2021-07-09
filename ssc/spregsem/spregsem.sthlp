{smcl}
{hline}
{cmd:help: {helpb spregsem}}{space 50} {cmd:dialog:} {bf:{dialog spregsem}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:spregsem: Maximum Likelihood Estimation Spatial Error Cross Sections Regression}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb spregsem##01:Syntax}{p_end}
{p 5}{helpb spregsem##02:Description}{p_end}
{p 5}{helpb spregsem##03:Options}{p_end}
{p 5}{helpb spregsem##04:Spatial Aautocorrelation Tests}{p_end}
{p 5}{helpb spregsem##05:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb spregsem##06:Heteroscedasticity Tests}{p_end}
{p 5}{helpb spregsem##07:Non Normality Tests}{p_end}
{p 5}{helpb spregsem##08:Saved Results}{p_end}
{p 5}{helpb spregsem##09:References}{p_end}

{p 1}*** {helpb spregsem##10:Examples}{p_end}

{p 5}{helpb spregsem##11:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 3 5 6}
{opt spregsem} {depvar} {indepvars} {weight} , {opt wmf:ile(weight_file)}{p_end} 
{p 3 5 6} 
{err: [} {opt lmsp:ac} {opt lmh:et} {opt lmn:orm} {opt diag} {opt test:s} {opt stand inv inv2}{p_end} 
{p 5 5 6} 
{opt dist(norm|exp|weib)} {opt mfx(lin, log)} {opt pred:ict(new_var)} {opt res:id(new_var)}{p_end} 
{p 5 5 6} 
 {opt iter(#)} {opt tech(name)} {opt ll(real 0)} {opt tobit coll zero tolog nolog}{p_end} 
{p 5 5 6} 
{opt l:evel(#)} {opth vce(vcetype)} {helpb maximize} {it:other maximization options} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

 {cmd:spregsem} estimates MLE Spatial Error Cross Sections Regression Models

 {cmd:spregsem} can estimate the following models:
   1- Heteroscedastic Regression Models in disturbance term.
   2- Non Normal Regression Models in disturbance term.

 {cmd:spregsem} estimates Continuous and Truncated Dependent Variables models {cmd:tobit}.

{p 2 2 2} {cmd:spregsem} deals with data either continuous or truncated dependent variable. If {depvar} has missing values or lower limits,
so in this case {cmd:spregsem} will fit spatial cross section model via {helpb tobit} model,
and thus {cmd:spregsem} can resolve the problem of missing values that exist in many kinds of data. Otherwise, in the case of continuous data, the normal estimation will be used.{p_end}

{p 2 4 2}{cmd:spregsem} can generate:{p_end}
    {cmd:- Binary / Standardized Weight Matrix.}
    {cmd:- Inverse  / Inverse Squared Standardized Weight Matrix.}
    {cmd:- Binary / Standardized / Inverse Eigenvalues Variable.}

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{bf:{err:*** Important Notes:}}
{cmd:spregsem} generates some variables names with prefix:
{cmd:w1x_ , w2x_ , w3x_ , w4x_ , w1y_ , w2y_ , mstar_ , spat_}
{cmd:So, you must avoid to include variables names with thes prefixes}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Options}}}

{col 3}{opt wmf:ile(weight_file)}{col 20} Open CROSS SECTION weight matrix file.

	Spatial Cross Sections Weight Matrix file must be:
	 1- Square Matrix [NxN] 
	 2- Symmetric Matrix (Optional) 

{col 3}Spatial Weight Matrix has two types: Standardized and binary weight matrix.

{col 3}{opt stand}{col 20}Use Standardized Weight Matrix, (each row sum equals 1)
{col 20}Default is Binary spatial Weight Matrix which each element is 0 or 1

{col 3}{opt inv}{col 20}Use Inverse Standardized Weight Matrix (1/W)

{col 3}{opt inv2}{col 20}Use Inverse Squared Standardized Weight Matrix (1/W^2)

{col 3}{opt zero}{col 20}convert missing values observations to Zero

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{col 3}{opt test:s}{col 20}display ALL lmh, lmn, lmsp, diag tests

{col 3}{opt nolog}{col 20}suppress iteration of the log likelihood

{col 3}{opt tobit}{col 20}Estimate model via Tobit regression 

{col 3}{opt ll(#)}{col 20}value of minimum left-censoring dependent variable with:
{col 20} {bf:({err:{it:tobit}})}; default is 0

{col 3}{opt mfx(lin, log)}{col 20}functional form: Linear model {cmd:(lin)}, or Log-Log model {cmd:(log)},
{col 20}to compute Marginal Effects and Elasticities
   - In Linear model: marginal effects are the coefficients (Bm),
        and elasticities are (Es = Bm X/Y).
   - In Log-Log model: elasticities are the coefficients (Es),
        and the marginal effects are (Bm = Es Y/X).
   - {opt mfx(log)} and {opt tolog} options must be combined, to transform linear variables to log form.

{p 8 4 2}{opt mfx(lin, log)} option can calculate:{p_end}
		{cmd:- Total    Marginal Effects and Elasticities.}
		{cmd:- Direct   Marginal Effects and Elasticities.}
		{cmd:- InDirect Marginal Effects and Elasticities.}

{col 3}{opt tolog}{col 20}Convert dependent and independent variables
{col 20}to LOG Form in the memory for Log-Log regression.
{col 20}{opt tolog} Transforms {depvar} and {indepvars}
{col 20}to Log Form without lost the original data variables

{synopt :{bf:dist({err:{it:norm, exp, weib}})} Distribution of error term:}{p_end}
{p 12 2 2}1- {bf:dist({err:{it:norm}})} Normal distribution; default.{p_end}
{p 12 2 2}2- {bf:dist({err:{it:exp}})}  Exponential distribution.{p_end}
{p 12 2 2}3- {bf:dist({err:{it:weib}})} Weibull distribution.{p_end}

{p 10 10 1}{cmd:dist} option is used to remedy non normality problem, when the error term has non normality distribution.{p_end}

{p 10 10 1}{bf:dist({err:{it:norm}})} is the default distribution.{p_end}

{col 3}{opt pred:ict(new_variable)}{col 30}Predicted values variable

{col 3}{opt res:id(new_variable)}{col 30}Residuals values variable computed as Ue=Y-Yh

{col 3}{opt tech(name)}{col 20}technique algorithm for maximization of the log likelihood function LLF
{col 8}{cmdab:tech(nr)}{col 20}Newton-Raphson (NR) algorithm; default
{col 8}{cmdab:tech(bhhh)}{col 20}Berndt-Hall-Hall-Hausman (BHHH) algorithm
{col 8}{cmdab:tech(dfp)}{col 20}Davidon-Fletcher-Powell (DFP) algorithm
{col 8}{cmdab:tech(bfgs)}{col 20}Broyden-Fletcher-Goldfarb-Shanno (BFGS) algorithm

{col 3}{opt iter(#)}{col 20}maximum iterations; default is 100
{col 20} if {opt iter(#)} is reached (100), this means convergence not achieved yet,
{col 20} so you can use another technique algorithm to converge LLF function
{col 20} or exceed number of maximum iterations more than 100.

{synopt :{opth vce(vcetype)} {opt ols}, {opt r:obust}, {opt cl:uster}, {opt boot:strap}, {opt jack:knife}, {opt hc2}, {opt hc3}}{p_end}

{col 3}{opt level(#)}{col 20}confidence intervals level; default is level(95)

{p 2 4 2}{help maximize:Other maximization_options} allows the user to specify other maximization options (e.g., difficult, trace, iterate(#), etc.).  
However, you should rarely have to specify them, though they may be helpful if parameters approach boundary values.

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Spatial Aautocorrelation Tests}}}

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
{marker 05}{bf:{err:{dlgtab:Model Selection Diagnostic Criteria}}}

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
{marker 06}{bf:{err:{dlgtab:Heteroscedasticity Tests}}}

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
{marker 07}{bf:{err:{dlgtab:Non Normality Tests}}}

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
{marker 08}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:spregsem} saves the following results in {cmd:e()}:

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
{col 4}{cmd:e(technique)}{col 20}maximization technique from technique() option
{col 4}{cmd:e(title)}{col 20}title in estimation output

Matrixes       
{col 4}{cmd:e(b)}{col 20}coefficient vector
{col 4}{cmd:e(V)}{col 20}variance-covariance matrix of the estimators
{col 4}{cmd:e(mfxlin)}{col 20}Marginal Effect and Elasticity in Lin Form
{col 4}{cmd:e(mfxlog)}{col 20}Marginal Effect and Elasticity in Log Form

Functions      
{col 4}{cmd:e(sample)}{col 20}marks estimation sample

{marker 09}{bf:{err:{dlgtab:References}}}

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
{marker 10}{bf:{err:{dlgtab:Examples}}}

{bf:Note 1:} you can use: {helpb spweight}, {helpb spweightcs}, {helpb spweightxt} to create Spatial Weight Matrix.
{bf:Note 2:} Remember, your spatial weight matrix must be:
    *** {bf:{err:1-Cross Section Dimention  2- Square Matrix 3- Symmetric Matrix}}
{bf:Note 3:} You can use the dialog box for {dialog spregsem}.
{hline}

{stata clear all}

{stata sysuse spregsem.dta, clear}

{bf:{err:* (1) MLE Spatial Error Normal Regression Model}}
 {stata spregsem y x1 x2 , wmfile(SPWcs) mfx(lin) test}
 {stata spregsem y x1 x2 , wmfile(SPWcs) mfx(lin) test}
 {stata spregsem y x1 x2 , wmfile(SPWcs) mfx(log) test tolog}
 {stata spregsem y x1 x2 , wmfile(SPWcs) predict(Yh) resid(Ue)}
{hline}

{bf:{err:* (2) MLE Spatial Error Exponential Regression Model}}
 {stata spregsem y x1 x2 , wmfile(SPWcs) mfx(lin) test dist(exp)}
{hline}

{bf:{err:* (3) MLE Spatial Error Weibull Regression Model}}
 {stata spregsem y x1 x2 , wmfile(SPWcs) mfx(lin) test dist(weib)}
{hline}

{bf:{err:* (4) Weighted MLE Spatial Error Regression Model}}
 {stata spregsem y x1 x2  [weight = x1], wmfile(SPWcs) mfx(lin) test}
 {stata spregsem y x1 x2 [aweight = x1], wmfile(SPWcs) mfx(lin) test}
{hline}

{bf:{err:* (5) MLE Spatial Error Tobit} - Truncated Dependent Variable (ys)}
 {stata spregsem ys x1 x2, wmfile(SPWcs) mfx(lin) test tobit ll(0)}
 {stata spregsem ys x1 x2, wmfile(SPWcs) mfx(lin) test tobit ll(3)}
{hline}

. clear all
. sysuse spregsem.dta, clear
. spregsem y x1 x2 , wmfile(SPWcs) mfx(lin) test

==============================================================================
*** Binary (0/1) Weight Matrix: 49x49 (Non Normalized)
==============================================================================

==============================================================================
* MLE Spatial Error Normal Model (SEM)
==============================================================================
  y = x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          49
  Wald Test         =     55.9482   |   P-Value > Chi2(2)       =      0.0000
  F-Test            =     27.9741   |   P-Value > F(2 , 47)     =      0.0000
 (Buse 1973) R2     =      0.5488   |   Raw Moments R2          =      0.9180
 (Buse 1973) R2 Adj =      0.5392   |   Raw Moments R2 Adj      =      0.9162
  Root MSE (Sigma)  =     11.3582   |   Log Likelihood Function =   -187.3257
------------------------------------------------------------------------------
- R2h= 0.5524   R2h Adj= 0.5428  F-Test =   28.38 P-Value > F(2 , 47)  0.0000
- R2v= 0.5456   R2v Adj= 0.5359  F-Test =   27.61 P-Value > F(2 , 47)  0.0000
------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y            |
          x1 |  -.2664578   .1026322    -2.60   0.009    -.4676131   -.0653024
          x2 |  -1.602789   .3245591    -4.94   0.000    -2.238913   -.9666652
       _cons |   67.42264   5.930373    11.37   0.000     55.79933    79.04596
-------------+----------------------------------------------------------------
      Lambda |    .003772   .0117793     0.32   0.749     -.019315     .026859
       Sigma |   11.06736   1.117975     9.90   0.000     8.876172    13.25855
------------------------------------------------------------------------------
 LR Test SEM vs. OLS (Lambda=0):   0.1025   P-Value > Chi2(1)   0.7488
 Acceptable Range for Lambda:     -0.3199 < Lambda < 0.1633
------------------------------------------------------------------------------

==============================================================================
* Model Selection Diagnostic Criteria
==============================================================================
- Log Likelihood Function                   LLF            =   -187.3257
---------------------------------------------------------------------------
- Akaike Information Criterion              (1974) AIC     =    139.8630
- Akaike Information Criterion              (1973) Log AIC =      4.9407
---------------------------------------------------------------------------
- Schwarz Criterion                         (1978) SC      =    157.0382
- Schwarz Criterion                         (1978) Log SC  =      5.0565
---------------------------------------------------------------------------
- Amemiya Prediction Criterion              (1969) FPE     =    136.9082
- Hannan-Quinn Criterion                    (1979) HQ      =    146.1462
- Rice Criterion                            (1984) Rice    =    141.0106
- Shibata Criterion                         (1981) Shibata =    138.8963
- Craven-Wahba Generalized Cross Validation (1979) GCV     =    140.4108
------------------------------------------------------------------------------

==============================================================================
*** Spatial Aautocorrelation Tests
==============================================================================
  Ho: Error has No Spatial AutoCorrelation
  Ha: Error has    Spatial AutoCorrelation

- GLOBAL Moran MI            =   0.1437     P-Value > Z( 1.940)   0.0524
- GLOBAL Geary GC            =   0.7310     P-Value > Z(-2.052)   0.0402
- GLOBAL Getis-Ords GO       =  -0.6922     P-Value > Z(-1.190)   0.2342
------------------------------------------------------------------------------
- Moran MI Error Test        =   0.6660     P-Value > Z(8.097)    0.5054
------------------------------------------------------------------------------
- LM Error (Burridge)        =   2.4383     P-Value > Chi2(1)     0.1184
- LM Error (Robust)          =   0.2634     P-Value > Chi2(1)     0.6078
------------------------------------------------------------------------------
  Ho: Spatial Lagged Dependent Variable has No Spatial AutoCorrelation
  Ha: Spatial Lagged Dependent Variable has    Spatial AutoCorrelation

- LM Lag (Anselin)           =   5.8363     P-Value > Chi2(1)     0.0157
- LM Lag (Robust)            =   3.6614     P-Value > Chi2(1)     0.0557
------------------------------------------------------------------------------
  Ho: No General Spatial AutoCorrelation
  Ha:    General Spatial AutoCorrelation

- LM SAC (LMErr+LMLag_R)     =   6.0997     P-Value > Chi2(2)     0.0474
- LM SAC (LMLag+LMErr_R)     =   6.0997     P-Value > Chi2(2)     0.0474
------------------------------------------------------------------------------

==============================================================================
* Heteroscedasticity Tests
==============================================================================
 Ho: Homoscedasticity - Ha: Heteroscedasticity
------------------------------------------------------------------------------
- Hall-Pagan LM Test:      E2 = Yh     =   0.7711    P-Value > Chi2(1)  0.3799
- Hall-Pagan LM Test:      E2 = Yh2    =   0.4686    P-Value > Chi2(1)  0.4937
- Hall-Pagan LM Test:      E2 = LYh2   =   0.6939    P-Value > Chi2(1)  0.4048
------------------------------------------------------------------------------
- Harvey LM Test:       LogE2 = X      =   4.5974    P-Value > Chi2(2)  0.1004
- Wald LM Test:         LogE2 = X      =  11.3437    P-Value > Chi2(1)  0.0008
- Glejser LM Test:        |E| = X      =   6.8153    P-Value > Chi2(2)  0.0331
------------------------------------------------------------------------------
- Machado-Santos-Silva Test: Ev=Yh Yh2 =   2.4381    P-Value > Chi2(2)  0.2955
- Machado-Santos-Silva Test: Ev=X      =   6.7439    P-Value > Chi2(2)  0.0343
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X      =   7.1516    P-Value > Chi2(2)  0.0280
- White Test -B-P-G (SSR): E2 = X      =  10.0156    P-Value > Chi2(2)  0.0067
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X X2   =   7.8472    P-Value > Chi2(4)  0.0973
- White Test -B-P-G (SSR): E2 = X X2   =  10.9898    P-Value > Chi2(4)  0.0267
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X X2 XX=  19.8512    P-Value > Chi2(5)  0.0013
- White Test -B-P-G (SSR): E2 = X X2 XX=  27.8011    P-Value > Chi2(5)  0.0000
------------------------------------------------------------------------------
- Cook-Weisberg LM Test  E2/Sig2 = Yh  =   1.0799    P-Value > Chi2(1)  0.2987
- Cook-Weisberg LM Test  E2/Sig2 = X   =  10.0156    P-Value > Chi2(2)  0.0067
------------------------------------------------------------------------------
*** Single Variable Tests (E2/Sig2):
- Cook-Weisberg LM Test: x1                =   1.2477 P-Value > Chi2(1) 0.2640
- Cook-Weisberg LM Test: x2                =   4.0249 P-Value > Chi2(1) 0.0448
------------------------------------------------------------------------------
*** Single Variable Tests:
- King LM Test: x1                         =   0.2045 P-Value > Chi2(1) 0.6511
- King LM Test: x2                         =   4.4057 P-Value > Chi2(1) 0.0358
------------------------------------------------------------------------------

==============================================================================
* Non Normality Tests
==============================================================================
 Ho: Normality - Ha: Non Normality
------------------------------------------------------------------------------
*** Non Normality Tests:
- Jarque-Bera LM Test                  =   2.1234     P-Value > Chi2(2) 0.3459
- White IM Test                        =   6.3843     P-Value > Chi2(2) 0.0411
- Doornik-Hansen LM Test               =   4.2736     P-Value > Chi2(2) 0.1180
- Geary LM Test                        =  -2.7412     P-Value > Chi2(2) 0.2540
- Anderson-Darling Z Test              =   0.3465     P > Z( 0.029)     0.5117
- D'Agostino-Pearson LM Test           =   3.0424     P-Value > Chi2(2) 0.2184
------------------------------------------------------------------------------
*** Skewness Tests:
- Srivastava LM Skewness Test          =   0.6634     P-Value > Chi2(1) 0.4154
- Small LM Skewness Test               =   0.8060     P-Value > Chi2(1) 0.3693
- Skewness Z Test                      =  -0.8978     P-Value > Chi2(1) 0.3693
------------------------------------------------------------------------------
*** Kurtosis Tests:
- Srivastava  Z Kurtosis Test          =   1.2083     P-Value > Z(0,1)  0.2269
- Small LM Kurtosis Test               =   2.2364     P-Value > Chi2(1) 0.1348
- Kurtosis Z Test                      =   1.4955     P-Value > Chi2(1) 0.1348
------------------------------------------------------------------------------
    Skewness Coefficient = -0.2850     - Standard Deviation =  0.3398
    Kurtosis Coefficient =  3.8456     - Standard Deviation =  0.6681
------------------------------------------------------------------------------
    Runs Test: (16) Runs -  (24) Positives - (25) Negatives
    Standard Deviation Runs Sig(k) =  3.4619 , Mean Runs E(k) = 25.4898
    95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (18.7045 , 32.2751 )
------------------------------------------------------------------------------

* Marginal Effect - Elasticity: Linear *

+---------------------------------------------------------------------------+
|   Variable | Marginal_Effect(B) |     Elasticity(Es) |               Mean |
|------------+--------------------+--------------------+--------------------|
|y           |                    |                    |                    |
|         x1 |            -0.2665 |            -0.2915 |            38.4362 |
|         x2 |            -1.6028 |            -0.6559 |            14.3749 |
+---------------------------------------------------------------------------+
 Mean of Dependent Variable =     35.1288

{p2colreset}{...}
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

{bf:{err:{dlgtab:SPREGSEM Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2014)}{p_end}
{p 1 10 1}{cmd:SPREGSEM: "Maximum Likelihood Estimation Spatial Error Cross Sections Regression"}{p_end}


{title:Online Help:}

{bf:{err:*** Spatial Econometrics Regression Models:}}

--------------------------------------------------------------------------------
{bf:{err:*** (1) Spatial Panel Data Regression Models:}}
{helpb spregxt}{col 17}Spatial Panel Regression Econometric Models: {cmd:Stata Module Toolkit}
{helpb gs2slsxt}{col 17}Generalized Spatial Panel 2SLS Regression
{helpb gs2slsarxt}{col 17}Generalized Spatial Panel Autoregressive 2SLS Regression
{helpb spglsxt}{col 17}Spatial Panel Autoregressive Generalized Least Squares Regression
{helpb spgmmxt}{col 17}Spatial Panel Autoregressive Generalized Method of Moments Regression
{helpb spmstarxt}{col 17}(m-STAR) Spatial Lag Panel Models
{helpb spmstardxt}{col 17}(m-STAR) Spatial Durbin Panel Models
{helpb spmstardhxt}{col 17}(m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Panel Models
{helpb spmstarhxt}{col 17}(m-STAR) Spatial Lag Multiplicative Heteroscedasticity Panel Models
{helpb spregdhp}{col 17}Spatial Panel Han-Philips Linear Dynamic Regression: Lag & Durbin Models
{helpb spregdpd}{col 17}Spatial Panel Arellano-Bond Linear Dynamic Regression: Lag & Durbin Models
{helpb spregfext}{col 17}Spatial Panel Fixed Effects Regression: Lag & Durbin Models
{helpb spregrext}{col 17}Spatial Panel Random Effects Regression: Lag & Durbin Models
{helpb spregsacxt}{col 17}MLE Spatial AutoCorrelation Panel Regression (SAC)
{helpb spregsarxt}{col 17}MLE Spatial Lag Panel Regression (SAR)
{helpb spregsdmxt}{col 17}MLE Spatial Durbin Panel Regression (SDM)
{helpb spregsemxt}{col 17}MLE Spatial Error Panel Regression (SEM)
--------------------------------------------------------------------------------
{bf:{err:*** (2) Spatial Cross Section Regression Models:}}
{helpb spregcs}{col 17}Spatial Cross Section Regression Econometric Models: {cmd:Stata Module Toolkit}
{helpb gs2sls}{col 17}Generalized Spatial 2SLS Cross Sections Regression
{helpb gs2slsar}{col 17}Generalized Spatial Autoregressive 2SLS Cross Sections Regression
{helpb gs3sls}{col 17}Generalized Spatial Autoregressive 3SLS Regression 
{helpb gs3slsar}{col 17}Generalized Spatial Autoregressive 3SLS Cross Sections Regression
{helpb gsp3sls}{col 17}Generalized Spatial 3SLS Cross Sections Regression
{helpb spautoreg}{col 17}Spatial Cross Section Regression Models
{helpb spgmm}{col 17}Spatial Autoregressive GMM Cross Sections Regression
{helpb spmstar}{col 17}(m-STAR) Spatial Lag Cross Sections Models
{helpb spmstard}{col 17}(m-STAR) Spatial Durbin Cross Sections Models
{helpb spmstardh}{col 17}(m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Cross Sections Models
{helpb spmstarh}{col 17}(m-STAR) Spatial Lag Multiplicative Heteroscedasticity Cross Sections Models
{helpb spregsac}{col 17}MLE Spatial AutoCorrelation Cross Sections Regression (SAC)
{helpb spregsar}{col 17}MLE Spatial Lag Cross Sections Regression (SAR)
{helpb spregsdm}{col 17}MLE Spatial Durbin Cross Sections Regression (SDM)
{helpb spregsem}{col 17}MLE Spatial Error Cross Sections Regression (SEM)
--------------------------------------------------------------------------------
{bf:{err:*** (3) Tobit Spatial Regression Models:}}

{bf:*** (3-1) Tobit Spatial Panel Data Regression Models:}
{helpb sptobitgmmxt}{col 17}Tobit Spatial GMM Panel Regression
{helpb sptobitmstarxt}{col 17}Tobit (m-STAR) Spatial Lag Panel Models
{helpb sptobitmstardxt}{col 17}Tobit (m-STAR) Spatial Durbin Panel Models
{helpb sptobitmstardhxt}{col 17}Tobit (m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Panel Models
{helpb sptobitmstarhxt}{col 17}Tobit (m-STAR) Spatial Lag Multiplicative Heteroscedasticity Panel Models
{helpb sptobitsacxt}{col 17}Tobit MLE Spatial AutoCorrelation (SAC) Panel Regression
{helpb sptobitsarxt}{col 17}Tobit MLE Spatial Lag Panel Regression
{helpb sptobitsdmxt}{col 17}Tobit MLE Spatial Panel Durbin Regression
{helpb sptobitsemxt}{col 17}Tobit MLE Spatial Error Panel Regression
{helpb spxttobit}{col 17}Tobit Spatial Panel Autoregressive GLS Regression
--------------------------------------------------------------
{bf:*** (3-2) Tobit Spatial Cross Section Regression Models:}
{helpb sptobitgmm}{col 17}Tobit Spatial GMM Cross Sections Regression
{helpb sptobitmstar}{col 17}Tobit (m-STAR) Spatial Lag Cross Sections Models
{helpb sptobitmstard}{col 17}Tobit (m-STAR) Spatial Durbin Cross Sections Models
{helpb sptobitmstardh}{col 17}Tobit (m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Cross Sections
{helpb sptobitmstarh}{col 17}Tobit (m-STAR) Spatial Lag Multiplicative Heteroscedasticity Cross Sections
{helpb sptobitsac}{col 17}Tobit MLE AutoCorrelation (SAC) Cross Sections Regression
{helpb sptobitsar}{col 17}Tobit MLE Spatial Lag Cross Sections Regression
{helpb sptobitsdm}{col 17}Tobit MLE Spatial Durbin Cross Sections Regression
{helpb sptobitsem}{col 17}Tobit MLE Spatial Error Cross Sections Regression
--------------------------------------------------------------------------------
{bf:{err:*** (4) Spatial Weight Matrix:}}
{helpb spcs2xt}{col 17}Convert Cross Section to Panel Spatial Weight Matrix
{helpb spweight}{col 17}Cross Section and Panel Spatial Weight Matrix
{helpb spweightcs}{col 17}Cross Section Spatial Weight Matrix
{helpb spweightxt}{col 17}Panel Spatial Weight Matrix
--------------------------------------------------------------------------------

{psee}
{p_end}

