{smcl}
{hline}
{cmd:help: {helpb spgmm}}{space 50} {cmd:dialog:} {bf:{dialog spgmm}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:spgmm: Spatial Autoregressive Generalized Method of Moments}"
{p 10}{bf:Cross Sections Regression}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb spgmm##01:Syntax}{p_end}
{p 5}{helpb spgmm##02:Description}{p_end}
{p 5}{helpb spgmm##03:Options}{p_end}
{p 5}{helpb spgmm##04:Spatial Aautocorrelation Tests}{p_end}
{p 5}{helpb spgmm##05:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb spgmm##06:Heteroscedasticity Tests}{p_end}
{p 5}{helpb spgmm##07:Non Normality Tests}{p_end}
{p 5}{helpb spgmm##08:Saved Results}{p_end}
{p 5}{helpb spgmm##09:References}{p_end}

{p 1}*** {helpb spgmm##10:Examples}{p_end}

{p 5}{helpb spgmm##11:Acknowledgments}{p_end}
{p 5}{helpb spgmm##12:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 3 5 6}
{opt spgmm} {depvar} {indepvars} , {opt wmf:ile(weight_file)}{p_end} 
{p 3 5 6} 
{err: [} {opt lmsp:ac} {opt lmh:et} {opt lmn:orm} {opt diag} {opt test:s} {opt stand inv inv2}{p_end} 
{p 5 5 6} 
{opt mfx(lin, log)} {opt ll(real 0)} {opt pred:ict(new_var)} {opt res:id(new_var)}{p_end} 
{p 5 5 6} 
{opt coll zero tobit tolog} {opt nocons:tant} {opt l:evel(#)} {opth vce(vcetype)} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

 {cmd:spgmm} estimates Spatial Autoregressive Generalized Method of Moments (SPGMM)
 for Spatial Cross Sections Regression

{p 3 3 3}When cross section data model with error are both spatially correlated.
Generalized Method of Moments (GMM) that suggested in Kelejian-Prucha (1999) is used in the estimation of {bf:({err:{it:spgmm}})}{p_end}

{p 2 4 2}{cmd:spgmm} can generate:{p_end}
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
{cmd:spgmm} generates some variables names with prefix:
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

{col 3}{opt tobit}{col 20}Estimate {bf:({err:{it:spgmm}})} via Tobit Spatial cross section GMM 

{col 3}{opt ll(#)}{col 20}value of minimum left-censoring dependent variable; default is 0

{col 3}{opt zero}{col 20}convert missing values observations to Zero

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

{synopt :{opth vce(vcetype)} {opt ols}, {opt r:obust}, {opt cl:uster}, {opt boot:strap}, {opt jack:knife}, {opt hc2}, {opt hc3}}{p_end}

{col 3}{opt level(#)}{col 20}confidence intervals level; default is level(95)

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

{p 2 4 2 }{cmd:spgmm} saves the following results in {cmd:e()}:

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

{p 4 8 2}Harry H. Kelejian and Ingmar R. Prucha (1999)
{cmd: "A Generalized Moments Estimator for the Autoregressive Parameter in a Spatial Model",}
{it:International Economic Review, (40)}; 509-533.
{browse "http://econweb.umd.edu/~prucha/Papers/IER40(1999).pdf"}

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
{bf:Note 3:} You can use the dialog box for {dialog spgmm}.
{hline}

{stata clear all}
{stata sysuse spgmm.dta, clear}

{bf:{err:* (1) Spatial Autoregressive Generalized Method of Moments (SPGMM)}}
 {stata spgmm y  x1 x2 , wmfile(SPWcs) mfx(lin) test}
 {stata spgmm y  x1 x2 , wmfile(SPWcs) mfx(log) tolog test}
{hline}

{bf:{err:* (2) Tobit Spatial Autoregressive Generalized Method of Moments (SPGMM)}}
 {stata spgmm ys x1 x2 , wmfile(SPWcs) mfx(lin) test tobit ll(0)}
 {stata spgmm ys x1 x2 , wmfile(SPWcs) mfx(lin) test tobit ll(3)}
 {stata spgmm ys x1 x2 , wmfile(SPWcs) mfx(log) test tobit ll(3) tolog}
{hline}

{bf:{err:* (3) Spatial Autoregressive Generalized Method of Moments (SPGMM)} (Cont.)}
 This example is taken from Prucha data about:
 Generalized Moments Estimator for the Autoregressive Parameter in a Spatial Model  
 More details can be found in:
 {browse "http://econweb.umd.edu/~prucha/Research_Prog1.htm"}
 Results of {bf:model({err:{it:spgmm}})} is identical to:
 {browse "http://econweb.umd.edu/~prucha/STATPROG/OLS/PROGRAM1.log"}

	{stata clear all}
	{stata sysuse spgmm1.dta , clear}
	{stata spgmm y x1 , wmfile(SPWcs1)}
{hline}

. clear all
. sysuse spgmm.dta, clear
. spgmm y x1 x2 , wmfile(SPWcs) mfx(lin) test

==============================================================================
*** Binary (0/1) Weight Matrix: 49x49 (Non Normalized)
==============================================================================
==============================================================================
* Spatial Autoregressive Generalized Method of Moments (SPGMM)
==============================================================================
  y = x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          49
  Wald Test         =     67.5466   |   P-Value > Chi2(2)       =      0.0000
  F-Test            =     33.7733   |   P-Value > F(2 , 47)     =      0.0000
 (Buse 1973) R2     =      0.5517   |   Raw Moments R2          =      0.9185
 (Buse 1973) R2 Adj =      0.5422   |   Raw Moments R2 Adj      =      0.9168
  Root MSE (Sigma)  =     11.3216   |   Log Likelihood Function =   -187.4159
------------------------------------------------------------------------------
- R2h= 0.5521   R2h Adj= 0.5426  F-Test =   28.36 P-Value > F(2 , 47)  0.0000
- R2v= 0.5839   R2v Adj= 0.5750  F-Test =   32.28 P-Value > F(2 , 47)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |  -.2653697   .0924285    -2.87   0.006    -.4513119   -.0794275
          x2 |   -1.68514   .3110111    -5.42   0.000    -2.310813   -1.059466
       _cons |   69.51514   4.299667    16.17   0.000     60.86533    78.16496
------------------------------------------------------------------------------

==============================================================================
* Model Selection Diagnostic Criteria
==============================================================================
- Log Likelihood Function                   LLF            =   -187.4159
---------------------------------------------------------------------------
- Akaike Information Criterion              (1974) AIC     =    138.9621
- Akaike Information Criterion              (1973) Log AIC =      4.9342
---------------------------------------------------------------------------
- Schwarz Criterion                         (1978) SC      =    156.0267
- Schwarz Criterion                         (1978) Log SC  =      5.0500
---------------------------------------------------------------------------
- Amemiya Prediction Criterion              (1969) FPE     =    136.0264
- Hannan-Quinn Criterion                    (1979) HQ      =    145.2049
- Rice Criterion                            (1984) Rice    =    140.1023
- Shibata Criterion                         (1981) Shibata =    138.0016
- Craven-Wahba Generalized Cross Validation (1979) GCV     =    139.5064
------------------------------------------------------------------------------

==============================================================================
*** Spatial Aautocorrelation Tests
==============================================================================
  Ho: Error has No Spatial AutoCorrelation
  Ha: Error has    Spatial AutoCorrelation

- GLOBAL Moran MI            =   0.1401     P-Value > Z( 1.899)   0.0575
- GLOBAL Geary GC            =   0.7388     P-Value > Z(-1.968)   0.0491
- GLOBAL Getis-Ords GO       =  -0.6746     P-Value > Z(-1.898)   0.0577
------------------------------------------------------------------------------
- Moran MI Error Test        =   0.6421     P-Value > Z(7.826)    0.5208
------------------------------------------------------------------------------
- LM Error (Burridge)        =   2.1293     P-Value > Chi2(1)     0.1445
- LM Error (Robust)          =   1.2154     P-Value > Chi2(1)     0.2703
------------------------------------------------------------------------------
  Ho: Spatial Lagged Dependent Variable has No Spatial AutoCorrelation
  Ha: Spatial Lagged Dependent Variable has    Spatial AutoCorrelation

- LM Lag (Anselin)           =   1.1214     P-Value > Chi2(1)     0.2896
- LM Lag (Robust)            =   0.2075     P-Value > Chi2(1)     0.6487
------------------------------------------------------------------------------
  Ho: No General Spatial AutoCorrelation
  Ha:    General Spatial AutoCorrelation

- LM SAC (LMErr+LMLag_R)     =   2.3369     P-Value > Chi2(2)     0.3109
- LM SAC (LMLag+LMErr_R)     =   2.3369     P-Value > Chi2(2)     0.3109
------------------------------------------------------------------------------

==============================================================================
* Heteroscedasticity Tests
==============================================================================
 Ho: Homoscedasticity - Ha: Heteroscedasticity
------------------------------------------------------------------------------
- Hall-Pagan LM Test:      E2 = Yh     =   0.6811    P-Value > Chi2(1)  0.4092
- Hall-Pagan LM Test:      E2 = Yh2    =   0.4517    P-Value > Chi2(1)  0.5015
- Hall-Pagan LM Test:      E2 = LYh2   =   0.4948    P-Value > Chi2(1)  0.4818
------------------------------------------------------------------------------
- Harvey LM Test:       LogE2 = X      =   2.7093    P-Value > Chi2(2)  0.2580
- Wald LM Test:         LogE2 = X      =   6.6850    P-Value > Chi2(1)  0.0097
- Glejser LM Test:        |E| = X      =   6.5158    P-Value > Chi2(2)  0.0385
------------------------------------------------------------------------------
- Machado-Santos-Silva Test: Ev=Yh Yh2 =   1.8396    P-Value > Chi2(2)  0.3986
- Machado-Santos-Silva Test: Ev=X      =   6.2968    P-Value > Chi2(2)  0.0429
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X      =   7.1334    P-Value > Chi2(2)  0.0282
- White Test -B-P-G (SSR): E2 = X      =  10.5848    P-Value > Chi2(2)  0.0050
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X X2   =   8.0831    P-Value > Chi2(4)  0.0886
- White Test -B-P-G (SSR): E2 = X X2   =  11.9941    P-Value > Chi2(4)  0.0174
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X X2 XX=  20.2918    P-Value > Chi2(5)  0.0011
- White Test -B-P-G (SSR): E2 = X X2 XX=  30.1098    P-Value > Chi2(5)  0.0000
------------------------------------------------------------------------------
- Cook-Weisberg LM Test  E2/Sig2 = Yh  =   1.0107    P-Value > Chi2(1)  0.3147
- Cook-Weisberg LM Test  E2/Sig2 = X   =  10.5848    P-Value > Chi2(2)  0.0050
------------------------------------------------------------------------------
*** Single Variable Tests (E2/Sig2):
- Cook-Weisberg LM Test: x1                =   1.5660 P-Value > Chi2(1) 0.2108
- Cook-Weisberg LM Test: x2                =   3.9024 P-Value > Chi2(1) 0.0482
------------------------------------------------------------------------------
*** Single Variable Tests:
- King LM Test: x1                         =   0.3168 P-Value > Chi2(1) 0.5735
- King LM Test: x2                         =   4.4035 P-Value > Chi2(1) 0.0359
------------------------------------------------------------------------------

==============================================================================
* Non Normality Tests
==============================================================================
 Ho: Normality - Ha: Non Normality
------------------------------------------------------------------------------
*** Non Normality Tests:
- Jarque-Bera LM Test                  =   2.8366     P-Value > Chi2(2) 0.2421
- White IM Test                        =   7.5596     P-Value > Chi2(2) 0.0228
- Doornik-Hansen LM Test               =   4.8559     P-Value > Chi2(2) 0.0882
- Geary LM Test                        =  -2.7412     P-Value > Chi2(2) 0.2540
- Anderson-Darling Z Test              =   0.3252     P > Z( 0.108)     0.5432
- D'Agostino-Pearson LM Test           =   3.7132     P-Value > Chi2(2) 0.1562
------------------------------------------------------------------------------
*** Skewness Tests:
- Srivastava LM Skewness Test          =   0.9246     P-Value > Chi2(1) 0.3363
- Small LM Skewness Test               =   1.1122     P-Value > Chi2(1) 0.2916
- Skewness Z Test                      =  -1.0546     P-Value > Chi2(1) 0.2916
------------------------------------------------------------------------------
*** Kurtosis Tests:
- Srivastava  Z Kurtosis Test          =   1.3828     P-Value > Z(0,1)  0.1667
- Small LM Kurtosis Test               =   2.6010     P-Value > Chi2(1) 0.1068
- Kurtosis Z Test                      =   1.6127     P-Value > Chi2(1) 0.1068
------------------------------------------------------------------------------
    Skewness Coefficient = -0.3365     - Standard Deviation =  0.3398
    Kurtosis Coefficient =  3.9677     - Standard Deviation =  0.6681
------------------------------------------------------------------------------
    Runs Test: (16) Runs -  (24) Positives - (25) Negatives
    Standard Deviation Runs Sig(k) =  3.4619 , Mean Runs E(k) = 25.4898
    95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (18.7045 , 32.2751 )
------------------------------------------------------------------------------

* Marginal Effect - Elasticity: Linear *

+---------------------------------------------------------------------------+
|   Variable | Marginal_Effect(B) |     Elasticity(Es) |               Mean |
|------------+--------------------+--------------------+--------------------|
|         x1 |            -0.2654 |            -0.2904 |            38.4362 |
|         x2 |            -1.6851 |            -0.6896 |            14.3749 |
+---------------------------------------------------------------------------+
 Mean of Dependent Variable =     35.1288

{p2colreset}{...}
{marker 11}{bf:{err:{dlgtab:Acknowledgments}}}

  I would like to thank professor Ingmar Prucha.

{p2colreset}{...}
{marker 12}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:SPGMM Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:SPGMM: "Spatial Autoregressive Generalized Method of Moments Cross Sections Regression"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457480.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457480.htm"}


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

