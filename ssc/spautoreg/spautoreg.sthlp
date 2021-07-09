{smcl}
{hline}
{cmd:help: {helpb spautoreg}}{space 50} {cmd:dialog:} {bf:{dialog spautoreg}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:spautoreg: Spatial Cross Sections Regression Models:}
{p 9 1 1}{bf:(SAR - SEM - SDM - SAC - SARARGS - SARARIV - SARARML - SPGMM}{p_end}
{p 10 1 1}{bf:GS2SLS - GS2SLSAR - GS3SLS - GS3SLSAR - IVTOBIT)}{p_end}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb spautoreg##01:Syntax}{p_end}
{p 5}{helpb spautoreg##02:Description}{p_end}
{p 5}{helpb spautoreg##03:Model Options}{p_end}
{p 5}{helpb spautoreg##04:Options}{p_end}
{p 5}{helpb spautoreg##05:Spatial Aautocorrelation Tests}{p_end}
{p 5}{helpb spautoreg##06:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb spautoreg##07:Heteroscedasticity Tests}{p_end}
{p 5}{helpb spautoreg##08:Non Normality Tests}{p_end}
{p 5}{helpb spautoreg##09:Hausman Specification Test OLS/IV-2SLS Tests}{p_end}
{p 5}{helpb spautoreg##10:Identification Restrictions LM Tests}{p_end}
{p 5}{helpb spautoreg##11:REgression Specification Error Tests (RESET)}{p_end}
{p 5}{helpb spautoreg##12:Saved Results}{p_end}
{p 5}{helpb spautoreg##13:References}{p_end}

{p 1}*** {helpb spautoreg##14:Examples}{p_end}

{p 5}{helpb spautoreg##15:Acknowledgments}{p_end}
{p 5}{helpb spautoreg##16:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt spautoreg} {depvar} {indepvars} {weight} , {opt wmf:ile(weight_file)}  
{p_end} 
{p 3 5 6} 
{opt m:odel(sar|sem|sdm|sac|sararml|sarargs|sarariv|spgmm|gs2sls|gs2slsar|gs3sls|gs3slsar)}{p_end} 
{p 5 5 6} 
{err: [}{opt lmsp:ac} {opt lma:uto} {opt lmh:et} {opt lmn:orm} {opt lmcl} {opt lmi:den} {opt haus:man} {opt reset} {opt diag} {opt test:s}{p_end} 
{p 5 5 6} 
{opt stand inv inv2} {opt dist(norm|exp|weib)} {opt mfx(lin, log)} {opt spar(rho, lam)} {opt aux(varlist)}{p_end} 
{p 5 5 6} 
{opt mhet(varlist)} {opt ord:er(#)} {opt inr:ho(real 0)} {opt inl:ambda(real 0)}{p_end} 
{p 5 5 6} 
{opt var2(varlist)} {opt eq(1, 2)} {opt pred:ict(new_var)} {opt res:id(new_var)} {opt iter(#)} {opt tech(name)}{p_end} 
{p 5 5 6} 
{opt coll zero ols 2sls 3sls sure mvreg tobit} {opt ll(real 0)} {opt nocons:tant}{p_end} 
{p 5 5 6} 
{opt het tolog nolog robust} {opt twos:tep} {opt grids(#)} {opt impower(#)} {opt l:evel(#)}{p_end} 
{p 5 5 6} 
{opth vce(vcetype)} {helpb maximize} {it:other maximization options} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

 {cmd:spautoreg} estimates Spatial Cross Sections Regression Models estimation
 Many types of spatial autocorrelations were taken under consedration, i.e.,
 (SAR - SEM - SDM - SAC - GS2SLS - GS2SLSAR - GS3SLS - GS3SLSAR -
  IVTOBIT - SARARGS - SARARIV - SARARML - SPGMM)

 {cmd:spautoreg} can estimate the following models:
   1- Heteroscedastic Regression Models in disturbance term.
   2- Non Normal Regression Models in disturbance term.

 {cmd:spautoreg} estimates Continuous and Truncated Dependent Variables models {cmd:tobit}.

{p 2 2 2} {bf:model({err:{it:sar, sem, sdm, sac, spgmm}})} deals with data either continuous or truncated dependent variable. If {depvar} has missing values or lower limits,
so in this case {bf: model({err:{it:sar, sem, sdm, sac, spgmm}})} will fit spatial cross section model via {helpb tobit} model,
and thus {cmd:spautoreg} can resolve the problem of missing values that exist in many kinds of data. Otherwise, in the case of continuous data, the normal estimation will be used.{p_end}

{p 2 4 2}{cmd:spautoreg} can generate:{p_end}
    {cmd:- Binary / Standardized Weight Matrix.}
    {cmd:- Inverse  / Inverse Squared Standardized Weight Matrix.}
    {cmd:- Binary / Standardized / Inverse Eigenvalues Variable.}
    {cmd:- Spatial lagged variables up to 4th order.}

{p 2 4 2} {cmd:spautoreg} predicted values in {bf: model({err:{it:sar, sdm, sac}})} models are obtained from conditional expectation expression.{p_end}

{pmore2}{bf:Yh = E(y|x) = inv(I-Rho*W) * X*Beta}

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{p 5 5 5}Buse(1973) R2 in {bf: model({err:{it:gs2sls, gs2slsar}})} may be negative, to avoid negative R2, you can increase number on instrumental variables by choosing order more than 1 {cmd:order(2, 3, 4)}{p_end}

{bf:{err:*** Important Notes:}}
{cmd:spautoreg} generates some variables names with prefix:
{cmd:w1x_ , w2x_ , w3x_ , w4x_ , w1y_ , w2y_ , mstar_ , spat_}
{cmd:So, you must avoid to include variables names with thes prefixes}

{synoptset 3 tabbed}{...}
{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Model Options}}}

{cmd: 1-} {bf:model({err:{it:sar}})}      MLE Spatial Lag Model (SAR)

{cmd: 2-} {bf:model({err:{it:sdm}})}      MLE Spatial Durbin Model (SDM)

{cmd: 3-} {bf:model({err:{it:sem}})}      MLE Spatial Error Model (SEM)

{cmd: 4-} {bf:model({err:{it:sac}})}      MLE Spatial Lag / Error Model (SAC) "Spatial AutoCorrelation"

{cmd: 5-} {bf:model({err:{it:spgmm}})}    Spatial Autoregressive Generalized Method of Moments Model
{p 20 20 2}When cross section data model with error are both spatially correlated.
Generalized Method of Moments (GMM) that suggested in Kelejian-Prucha (1999) is used in the estimation of {bf:model({err:{it:spgmm}})}{p_end}

{cmd: 6-} {bf:model({err:{it:spgmm}})}    Tobit Spatial Autoregressive GMM {bf: with option({err:{it:tobit}})}

{cmd: 7-} {bf:model({err:{it:gs2sls}})}   Generalized Spatial 2SLS

{cmd: 8-} {bf:model({err:{it:gs2slsar}})} Generalized Spatial Autoregressive 2SLS [Kelejian-Prucha(1998)]
{p 20 20 2}Since no softwares available till now to estimate generalized spatial cross section autoregressive 2SLS models, I designed {cmd:gs2slsar} as a modification of Kapoor-Kelejian-Prucha (1999),
but here I let the estimations deal with cross section 2SLS models, with original constant term.{p_end}

{cmd: 9-} {bf:model({err:{it:gs3sls}})}   Generalized Spatial 3SLS Model

{cmd:10-} {bf:model({err:{it:gs3slsar}})} Generalized Spatial Autoregressive 3SLS Model [Kelejian-Prucha(2004)]

{cmd:11-} {bf:model({err:{it:ivtobit}})} MLE - IV Spatial Tobit Model Truncated {depvar}  {help ivtobit}

{cmd:12-} {bf:model({err:{it:sararml}})} MLE - Spatial Lag/Autoregressive Error ({help spreg})

{cmd:13-} {bf:model({err:{it:sarargs}})} Generalized Spatial Lag/Autoregressive Error GS2SLS ({help spreg})

{cmd:14-} {bf:model({err:{it:sarariv}})} Generalized Spatial Lag/Autoregressive Error IV-GS2SLS ({help spivreg})

{bf:model({err:{it:sararml|sarargs|sarariv}})} {it:Requires}
 - Stata v11.2
 - (sppack) module {bf:{stata ssc install sppack}}
 - Binary Weight Matrix must be used.

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Options}}}

{col 3}{opt wmf:ile(weight_file)}{col 20} Open CROSS SECTION weight matrix file.

	Spatial Cross Sections Weight Matrix file should be:
	 1- Square Matrix [NxN] 
	 2- Symmetric Matrix (Optional)

{col 3}Spatial Weight Matrix has two types: Standardized and binary weight matrix.

{col 3}{opt stand}{col 20}Use Standardized Weight Matrix, (each row sum equals 1)
{col 20}Default is Binary spatial Weight Matrix which each element is 0 or 1

{col 3}{opt inv}{col 20}Use Inverse Standardized Weight Matrix (1/W)

{col 3}{opt inv2}{col 20}Use Inverse Squared Standardized Weight Matrix (1/W^2)

{col 3}{opt zero}{col 20}convert missing values observations to Zero

{col 3}{opt ord:er(1, 2, 3, 4)}{col 20} Order of lagged independent variables up to maximum 4th order.
{col 15}{bf:order(2,3,4)} works only with: {bf:model({err:{it:gs2sls, gs2slsar}})}. Default is 1

{synopt:{opt eq(1, 2)}}Tests for equation (#) in {bf:model({err:{it:gs3sls, gs3slsar}})}, default is 1.{p_end}

{synopt:{opt var2(varlist)}}Dependent-Independent Variables for the second equation in {bf:model({err:{it:gs3sls, gs3slsar}})}.{p_end}

	var2(varlist) must be combine with: model(gs3sls)
	if you have system of 2 Equations:
	Y1 = Y2 X1 X2
	Y2 = Y1 X3 X4
	Variables of Eq. 1 will be Dep. & Indep. Variables
	Variables of Eq. 2 will be Dep. & Indep. Variables in option var2( ); i.e,
	{stata spautoreg y1 x1 x2 , wmfile(SPWcs) model(gs3sls) var2(y2 x3 x4) eq(1)}
	{stata spautoreg y1 x1 x2 , wmfile(SPWcs) model(gs3sls) var2(y2 x3 x4) eq(2)}

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from RHS Equation
{col 20}not valid in {bf:model({err:{it:sem, sac}})}

{col 3}{opt haus:man}{col 20}Hausman Specification Tests

{col 3}{opt test:s}{col 20}display ALL lma, lmh, lmn, lmsp, lmi, diag, reset, haus tests

{col 3}{opt dn}{col 20}Use (N) divisor instead of (N-K) for Degrees of Freedom (DF)

{col 3}{opt ols}{col 20}{bf:model({err:{it:gs3sls}})} Ordinary Least Squares (OLS)
{col 3}{opt 2sls}{col 20}{bf:model({err:{it:gs3sls}})} Two-Stage Least Squares (2SLS)
{col 3}{opt 3sls}{col 20}{bf:model({err:{it:gs3sls}})} Three-Stage Least Squares (3SLS)
{col 3}{opt sure}{col 20}{bf:model({err:{it:gs3sls}})} Seemingly Unrelated Regression Estimation (SURE)
{col 3}{opt mvreg}{col 20}{bf:model({err:{it:gs3sls}})} SURE with OLS DF adjustment (MVREG)

{col 3}{opt grids(#)}{col 20}{bf:model({err:{it:sararml}})}initial grid search values of lambda and rho parameters

{col 3}{opt het}{col 20}{bf:model({err:{it:sarargs, sarariv}})} Use estimator for heteroskedastic disturbance terms

{col 3}{opt impower(#)}{col 20}{bf:model({err:{it:sarargs, sarariv}})}
{col 20}Use q powers of matrix W to form instrument matrix H (q= 2,3,...,7).
{col 20}Default is 2

{col 3}{opt two:step}{col 20}two-step estimate {cmd:model({helpb ivtobit)}}

{col 3}{opt inrho(#)}{col 20}Set initial value for rho; default is 0

{col 3}{opt inlam:bda(#)}{col 20}Set initial value for lambda; default is 0

{col 3}{opt nolog}{col 20}suppress iteration of the log likelihood

{col 3}{opt tobit}{col 20}Estimate model via Tobit regression 

{col 3}{opt ll(#)}{col 20}value of minimum left-censoring dependent variable with:
{col 20}{bf:model({err:{it:sar, sem, sdm, sac, spgmm, ivtobit}})}, and {helpb tobit}; default is 0

{col 3}{opt mfx(lin, log)}{col 20}functional form: Linear model {cmd:(lin)}, or Log-Log model {cmd:(log)},
{col 20}to compute Total, Direct, and InDirect Marginal Effects and Elasticities
   - In Linear model: marginal effects are the coefficients (Bm),
        and elasticities are (Es = Bm X/Y).
   - In Log-Log model: elasticities are the coefficients (Es),
        and the marginal effects are (Bm = Es Y/X).
   - {opt mfx(log)} and {opt tolog} options must be combined, to transform linear variables to log form.

{p 8 4 2}{opt mfx(lin, log)} with {bf:model({err:{it:sar, sdm, sac}})} can calculate:{p_end}
		{cmd:- Total    Marginal Effects and Elasticities.}
		{cmd:- Direct   Marginal Effects and Elasticities.}
		{cmd:- InDirect Marginal Effects and Elasticities.}

{col 3}{opt tolog}{col 20}Convert dependent and independent variables
{col 20}to LOG Form in the memory for Log-Log regression.
{col 20}{opt tolog} Transforms {depvar} and {indepvars}
{col 20}to Log Form without lost the original data variables

{col 3}{opt spar(rho, lam)}{col 20}type of spatial autoregressive coefficients:
{col 20}{cmd:(rho)} [Rho] and {cmd:(lam)} [Lambda]
       - {opt spar(rho)} is default for {bf:model({err:{it:sar, sac, sdm, sararml, sarargs, sarariv}})}
       - {opt spar(rho)} cannot be used with {bf:model({err:{it:sem}})}

       - {opt spar(lam)} is default for {bf:model({err:{it:sem}})}
       - {opt spar(lam)} cannot be used with {bf:model({err:{it:sar, sdm}})}
       - {opt spar(lam)} is an alternative with {bf:model({err:{it:sac}})}
       
       - {bf:model({err:{it:sac, sararml, sarargs, sarariv}})} work with the two types {opt spar(rho, lam)}
       - {bf:model({err:{it:gs2sls, gs2slsar, gs3sls, gs3slsar, ivtobit}})}
         not work with the two types {opt spar(rho, lam)}

{synopt :{bf:dist({err:{it:norm, exp, weib}})} Distribution of error term:}{p_end}
{p 12 2 2}1- {bf:dist({err:{it:norm}})} Normal distribution; default.{p_end}
{p 12 2 2}2- {bf:dist({err:{it:exp}})}  Exponential distribution.{p_end}
{p 12 2 2}3- {bf:dist({err:{it:weib}})} Weibull distribution.{p_end}

{p 10 10 1}{cmd:dist} option is used to remedy non normality problem, when the error term has non normality distribution.{p_end}
{p 10 10 1} {opt dist(norm, exp, weib)} with {bf:model({err:{it:sar, sem, sdm, sac}})}.{p_end}

{p 10 10 1}{bf:dist({err:{it:norm}})} is the default distribution.{p_end}

{p 2 10 10}{opt aux(varlist)} add Auxiliary Variables into regression model without converting them to spatial lagged variables, or without {cmd:log} form, i.e., dummy variables.
This option dont include these auxiliary variables among spatial lagged variables, it is useful to avoid lost degrees of freedom (DF).
Using many dummy variables must be used with caution to avoid multicollinearity problem.
{opt aux( )} not works with {bf:model({err:{it:sem, sac}})}.{p_end} 

{p 2 10 10}{opt mhet(varlist)} Set variable(s) that will be included in {cmd:Spatial cross section Multiplicative Heteroscedasticity} model, this option is used with {bf:model({err:{it:sar, sdm}})}, to remidy Heteroscedasticity.
option {weight}, can be used in the case of Heteroscedasticity in errors.{p_end}

{col 3}{opt pred:ict(new_variable)}{col 30}Predicted values variable

{col 3}{opt res:id(new_variable)}{col 30}Residuals values variable computed as Ue=Y-Yh

{col 3}{opt rob:ust}{col 20}Huber-White standard errors {bf:model({err:{it:sar, sdm, spgmm}})}

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

	*** cross section Tobit Model Heteroscedasticity LM Tests
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
{marker 09}{bf:{err:{dlgtab:Hausman Specification Test (InConsistent Problem)}}}

{synopt:{opt haus:man}}Hausman Specification Test (InConsistent Problem){p_end}
	- Ho = B Consistent  * Ha = B InConsistent
	  LM = (Bi-Bo)'inv(Vi-Vo)*(Bi-Bo)

{p2colreset}{...}
{marker 10}{bf:{err:{dlgtab:Identification Restrictions LM Tests}}}

{synopt :{opt lmiden} Identification Restrictions LM Tests:}{p_end}
	- Y  = LHS Dependent Variable in Equation i
	- Yi = RHS Endogenous Variables in Equation i
	- Xi = RHS Included Exogenous Variables in   Equation i
	- Z  = Overall Exogenous Variables in the System
	- Sargan  LM Test
	- Basmann LM Test
	- Hansen Over Identification LM Test

{p2colreset}{...}
{marker 11}{bf:{err:{dlgtab:REgression Specification Error Tests (RESET)}}}

{synopt :{opt reset} REgression Specification Error Tests (RESET)}{p_end}
	* Ho: Model is Specified - Ha: Model is Misspecified
	- Ramsey RESET2 Test: Y= X Yh2
	- Ramsey RESET3 Test: Y= X Yh2 Yh3
	- Ramsey RESET4 Test: Y= X Yh2 Yh3 Yh4
	- DeBenedictis-Giles Specification ResetL Test
	- DeBenedictis-Giles Specification ResetS Test
	- White Functional Form Test: E2= X X2

{p2colreset}{...}
{marker 12}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:spautoreg} saves the following results in {cmd:e()}:

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

{col 4}{cmd:e(df1)}{col 20}DF1
{col 4}{cmd:e(df2)}{col 20}DF2
{col 4}{cmd:e(rmse)}{col 20}Root Mean Squared Error
{col 4}{cmd:e(rss)}{col 20}Residual Sum of Squares
{col 4}{cmd:e(maxEig)}{col 20}Maximum Eigenvalue
{col 4}{cmd:e(minEig)}{col 20}minimum Eigenvalue

{col 4}{cmd:e(rank)}{col 20}rank of e(V)
{col 4}{cmd:e(rmse_}{it:#}{cmd:)}{col 20}root mean squared error for equation {it:#}
{col 4}{cmd:e(rss_}{it:#}{cmd:)}{col 20}residual sum of squares for equation {it:#}

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

{err:*** Hausman Specification cross section/IV-cross section Tests:}
{col 4}{cmd:e(lmhs)}{col 20}Hausman cross section vs IV-cross section
{col 4}{cmd:e(lmhsp)}{col 20}Hausman cross section vs IV-cross section P-Value

{err:*** Identification Restrictions LM Tests (gs2sls, gs2slsar, gs3sls, gs3slsar, sarariv, ivtobit):}
{col 4}{cmd:e(lmb)}{col 20}Basmann LM Test
{col 4}{cmd:e(lmbp)}{col 20}Basmann LM Test P-Value
{col 4}{cmd:e(lms)}{col 20}Sargan LM Test
{col 4}{cmd:e(lmsp)}{col 20}Sargan LM Test P-Value

{err:*** REgression Specification Error Tests (RESET):}
{col 4}{cmd:e(resetf1)}{col 20}Ramsey Specification ResetF1 Test
{col 4}{cmd:e(resetf1p)}{col 20}Ramsey Specification ResetF1 Test P-Value
{col 4}{cmd:e(resetf2)}{col 20}Ramsey Specification ResetF2 Test
{col 4}{cmd:e(resetf2p)}{col 20}Ramsey Specification ResetF2 Test P-Value
{col 4}{cmd:e(resetf3)}{col 20}Ramsey Specification ResetF3 Test
{col 4}{cmd:e(resetf3p)}{col 20}Ramsey Specification ResetF3 Test P-Value

{col 4}{cmd:e(resetl1)}{col 20}DeBenedictis-Giles Specification ResetL1 Test
{col 4}{cmd:e(resetl1p)}{col 20}DeBenedictis-Giles Specification ResetL1 Test P-Value
{col 4}{cmd:e(resetl2)}{col 20}DeBenedictis-Giles Specification ResetL2 Test
{col 4}{cmd:e(resetl2p)}{col 20}DeBenedictis-Giles Specification ResetL2 Test P-Value
{col 4}{cmd:e(resetl3)}{col 20}DeBenedictis-Giles Specification ResetL3 Test
{col 4}{cmd:e(resetl3p)}{col 20}DeBenedictis-Giles Specification ResetL3 Test P-Value

{col 4}{cmd:e(resets1)}{col 20}DeBenedictis-Giles Specification ResetS1 Test
{col 4}{cmd:e(resets1p)}{col 20}DeBenedictis-Giles Specification ResetS1 Test P-Value
{col 4}{cmd:e(resets2)}{col 20}DeBenedictis-Giles Specification ResetS2 Test
{col 4}{cmd:e(resets2p)}{col 20}DeBenedictis-Giles Specification ResetS2 Test P-Value
{col 4}{cmd:e(resets3)}{col 20}DeBenedictis-Giles Specification ResetS3 Test
{col 4}{cmd:e(resets3p)}{col 20}DeBenedictis-Giles Specification ResetS3 Test P-Value

{col 4}{cmd:e(lmw)}{col 20}Functional Form White LM Test
{col 4}{cmd:e(lmwp)}{col 20}Functional Form White LM Test P-Value

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

{col 4}{cmd:e(mfxlinb)}{col 20}Beta, Total, Direct, and InDirect Marginal Effect
{col 20} for model(sar, sdm, sac, sararml, sarargs, sarariv) in Lin Form
{col 4}{cmd:e(mfxline)}{col 20}Beta, Total, Direct, and InDirect Elasticity
{col 20} for model(sar, sdm, sac, sararml, sarargs, sarariv) in Lin Form

{col 4}{cmd:e(mfxlogb)}{col 20}Beta, Total, Direct, and InDirect Marginal Effect
{col 20} for model(sar, sdm, sac, sararml, sarargs, sarariv) in Log Form
{col 4}{cmd:e(mfxloge)}{col 20}Beta, Total, Direct, and InDirect Elasticity
{col 20} for model(sar, sdm, sac, sararml, sarargs, sarariv) in Log Form

{col 4}{cmd:e(mfxlin)}{col 20}Marginal Effect and Elasticity in Lin Form
{col 4}{cmd:e(mfxlog)}{col 20}Marginal Effect and Elasticity in Log Form

{col 4}{cmd:e(gradient)}{col 20}gradient vector
{col 4}{cmd:e(ilog)}{col 20}iteration log (up to 20 iterations)
{col 4}{cmd:e(ml_h)}{col 20}derivative tolerance, {cmd:(abs(b)+1e-3)*1e-3}
{col 4}{cmd:e(ml_scale)}{col 20}derivative scale factor
{col 4}{cmd:e(Sigma)}{col 20}Sigma hat matrix

Functions      
{col 4}{cmd:e(sample)}{col 20}marks estimation sample

{marker 13}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Anderson T.W., Darling D.A. (1954)
{cmd: "A Test of Goodness of Fit",}
{it:Journal of the American Statisical Association, 49}; 765–69. 

{p 4 8 2}Anderson, T. W. & H. Rubin (1950)
{cmd: "The Asymptotic Properties of Estimates of the Parameters of a Single Equation in a Complete System of Stochastic Equations",}
{it:Annals of Mathematical Statistics, Vol. 21}; 570-82.

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

{p 4 8 2}Basmann, R.L. (1960)
{cmd: "On Finite Sample Distributions of Generalized Classical Linear Identifiability Test Statistics"},
{it:Journal of the American Statisical Association, 55, Issue 292, DecemberA}; 650-59.

{p 4 8 2}Breusch, Trevor & Adrian Pagan (1980)
{cmd: "The Lagrange Multiplier Test and its Applications to Model Specification in Econometrics",}
{it:Review of Economic Studies 47}; 239-253.

{p 4 8 2}Brundson,C. A. S. Fotheringham, & M. Charlton (1996)
{cmd:"Geographically Weighted Regression: A Method for Exploring Spatial Nonstationarity"}
{it:Geographical Analysis,V ol. 28}; 281-298.

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

{p 4 8 2}Drukker, D. M., I. R. Prucha, and R. Raciborski. (2011)
{cmd: "Maximum-likelihood and generalized spatial two-stage least-squares estimators for a spatial-autoregressive model with spatial-autoregressive disturbances",}
{it:Working paper, University of Maryland, Department of Economics}.
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spreg_2011.pdf"}.

{p 4 8 2}Drukker, D. M., I. R. Prucha, and R. Raciborski. (2011)
{cmd: "A command for estimating spatial-autoregressive models with spatial autoregressive disturbances and additional endogenous variables",}
{it:Working paper, The University of Maryland, Department of Economics}.
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spivreg_2011.pdf"}.

{p 4 8 2}Elhorst, J. Paul (2003)
{cmd: "Specification and Estimation of Spatial Panel Data Models"}
{it:International Regional Science review 26, 3}; 244–268.

{p 4 8 2}Elhorst, J. Paul (2009)
{cmd: "Spatial Panel Data Models"}
{it:in Mandfred M. Fischer and Arthur Getis, eds., Handbook of Applied Spatial Analysis, Berlin: Springer}.

{p 4 8 2}Geary R.C. (1947)
{cmd: "Testing for Normality"} {it:Biometrika, Vol. 34}; 209-242.

{p 4 8 2}Geary R.C. (1970)
{cmd: "Relative Efficiency of Count of Sign Changes for Assessing Residuals Autoregression in Least Squares Regression"}
{it:Biometrika, Vol. 57}; 123-127.

{p 4 8 2}Godfrey, L. G. (1978)
{cmd: "Testing for Multiplicative Heteroskedasticity",}
{it:Journal of Econometrics, Vol.8}; 227-236.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Macmillan Publishing Company Inc., New York, USA.}.

{p 4 8 2}Griffiths, W., R. Carter Hill & George Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Harry H. Kelejian and Ingmar R. Prucha (1998)
{cmd: "A Generalized Spatial Two-Stage Least Squares Procedures for Estimating a Spatial Autoregressive Model with Autoregressive Disturbances",}
{it:Journal of Real Estate Finance and Economics, (17)}; 99-121.
{browse "http://econweb.umd.edu/~prucha/Papers/JREFE17(1998).pdf"}

{p 4 8 2}Harry H. Kelejian and Ingmar R. Prucha (1999)
{cmd: "A Generalized Moments Estimator for the Autoregressive Parameter in a Spatial Model",}
{it:International Economic Review, (40)}; 509-533.
{browse "http://econweb.umd.edu/~prucha/Papers/IER40(1999).pdf"}

{p 4 8 2}Harry H. Kelejian and Ingmar R. Prucha (2004)
{cmd: "Estimation of Simultaneous Systems of Spatially Interrelated Cross Sectional Equations",}
{it:Journal of Econometrics, (118)}; 27-50.
{browse "http://econweb.umd.edu/~prucha/Papers/JE118(2004).pdf"}

{p 4 8 2}Harvey, Andrew (1990)
{cmd: "The Econometric Analysis of Time Series",}
{it:2nd edition, MIT Press, Cambridge, Massachusetts}.

{p 4 8 2}Hausman, Jerry (1978)
{cmd: "Specification Tests in Econometrics",}
{it:Econometrica, vol.46, Nov.}; 1251-1271.

{p 4 8 2}Hausman, Jerry & Taylor W. (1983)
{cmd: "Identification in Linear Simultaneous Equations Models with Covariance Restrictions: An Instrumental Variables Interpretation",}
{it:Econometrica, vol.51.}; 1527-1549.

{p 4 8 2}James LeSage and R. Kelly Pace (2009)
{cmd: "Introduction to Spatial Econometrics",}
{it:Publisher: Chapman & Hall/CRC}.

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

{p 4 8 2}Ljung, G. & George Box (1979)
{cmd: "On a Measure of Lack of Fit in Time Series Models",}
{it:Biometrika, Vol. 66}; 265–270.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}.

{p 4 8 2}Pagan, Adrian .R. & Hall, D. (1983)
{cmd: "Diagnostic Tests as Residual Analysis",}
{it:Econometric Reviews, Vol.2, No.2,}. 159-218.

{p 4 8 2}Pearson, E. S., D'Agostino, R. B., & Bowman, K. O. (1977)
{cmd: "Tests for Departure from Normality: Comparison of Powers",}
{it:Biometrika, 64(2)}; 231-246.

{p 4 8 2}Ramsey, J. B. (1969)
{cmd: "Tests for Specification Errors in Classical Linear Least-Squares Regression Analysis",}
{it: Journal of the Royal Statistical Society, Series B 31}; 350-371.

{p 4 8 2}Sargan, J.D. (1958)
{cmd: "The Estimation of Economic Relationships Using Instrumental Variables",}
{it:Econometrica, vol.26}; 393-415.

{p 4 8 2}Szroeter, J. (1978)
{cmd: "A Class of Parametric Tests for Heteroscedasticity in Linear Econometric Models",}
{it:Econometrica, 46}; 1311-28.

{p 4 8 2}White, Halbert (1980)
{cmd: "A Heteroskedasticity-Consistent Covariance Matrix Estimator and a Direct Test for Heteroskedasticity",}
{it:Econometrica, 48}; 817-838.

{p2colreset}{...}
{marker 14}{bf:{err:{dlgtab:Examples}}}

{bf:Note 1:} you can use: {helpb spweight}, {helpb spweightcs}, {helpb spweightxt} to create Spatial Weight Matrix.
{bf:Note 2:} Remember, your spatial weight matrix should be:
    *** {bf:{err:1-Cross Section Dimention  2- Square Matrix 3- Symmetric Matrix}}
{bf:Note 3:} You can use the dialog box for {dialog spautoreg}.
{hline}

{stata clear all}

{stata sysuse spautoreg.dta, clear}

{bf:{err:* (1) MLE Spatial Lag Model (SAR):}}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) test}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) test}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sar) mfx(log) test tolog}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sar) predict(Yh) resid(Ue)}
 {stata spautoreg ys x1 x2, wmfile(SPWcs) model(sar) lmn lmh tobit ll(0)}
 {stata spautoreg ys x1 x2, wmfile(SPWcs) model(sar) lmn lmh tobit ll(3)}
{hline}

{bf:{err:* (2) MLE Spatial Error Model (SEM):}}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sem) mfx(lin) test}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sem) mfx(log) test tolog}
 {stata spautoreg ys x1 x2, wmfile(SPWcs) model(sem) lmn lmh tobit ll(0)}
{hline}

{bf:{err:* (3) MLE Spatial Durbin Model (SDM):}}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sdm) mfx(lin) test}
 {stata spautoreg ys x1 x2, wmfile(SPWcs) model(sdm) lmn lmh tobit ll(0)}
 {stata spautoreg y x1    , wmfile(SPWcs) model(sdm) mfx(lin) test aux(x2)}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sdm) mfx(log) test tolog}
{hline}

{bf:{err:* (4) MLE Spatial AutoCorrelation Model (SAC):}}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) test spar(rho)}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sac) mfx(log) test spar(rho) tolog}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) test spar(lam)}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sac) mfx(log) test spar(lam) tolog}
 {stata spautoreg ys x1 x2, wmfile(SPWcs) model(sac) lmn lmh tobit ll(0)}
{hline}

{bf:{err:* (5) Spatial Exponential Regression Model:}}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sar) dist(exp) mfx(lin) test}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sem) dist(exp) mfx(lin) test}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sdm) dist(exp) mfx(lin) test}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sac) dist(exp) mfx(lin) test}
{hline}

{bf:{err:* (6) Spatial Weibull Regression Model:}}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sar) dist(weib) mfx(lin) test}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sem) dist(weib) mfx(lin) test}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sdm) dist(weib) mfx(lin) test}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sac) dist(weib) mfx(lin) test}
{hline}

{bf:{err:* (7) Weighted MLE Spatial Models:}}

{bf:* (7-1) Weighted MLE Spatial Lag Model (SAR):}
 {stata spautoreg y x1 x2 [weight = x1], wmfile(SPWcs) model(sar) mfx(lin) test}

{bf:* (7-2) Weighted MLE Spatial Error Model (SEM):}
 {stata spautoreg y x1 x2 [weight = x1], wmfile(SPWcs) model(sem) mfx(lin) test}

{bf:* (7-3) Weighted MLE Spatial Durbin Model (SDM):}
 {stata spautoreg y x1 x2 [weight = x1], wmfile(SPWcs) model(sdm) mfx(lin) test}

{bf:* (7-4) Weighted MLE Spatial AutoCorrelation Model (SAC):}
 {stata spautoreg y x1 x2 [weight = x1], wmfile(SPWcs) model(sac) mfx(lin) test}
{hline}

{bf:{err:* (8) Spatial Tobit} - Truncated Dependent Variable (ys):}
 {stata spautoreg ys x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) test tobit ll(0)}
 {stata spautoreg ys x1 x2 , wmfile(SPWcs) model(sem) mfx(lin) test tobit ll(0)}
 {stata spautoreg ys x1 x2 , wmfile(SPWcs) model(sdm) mfx(lin) test tobit ll(0)}
 {stata spautoreg ys x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) test tobit ll(0)}
{hline}

{bf:{err:* (9) Spatial Multiplicative Heteroscedasticity:}}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sar) mhet(x1 x2) mfx(lin) test}
 {stata spautoreg y x1 x2 , wmfile(SPWcs) model(sdm) mhet(x1 x2) mfx(lin) test}
{hline}

{bf:{err:* (10) Spatial IV Tobit (IVTOBIT):}}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(ivtobit) order(1) mfx(lin) test tobit ll(0)}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(ivtobit) order(2) mfx(lin) test tobit ll(0)}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(ivtobit) order(3) mfx(lin) test tobit ll(0)}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(ivtobit) order(4) mfx(lin) test tobit ll(0)}
{hline}

{bf:{err:* (11) MLE -Spatial Lag/Autoregressive Error (SARARML):}}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(sararml) spar(rho) mfx(lin) test}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(sararml) spar(lam) mfx(lin) test}
{hline}

{bf:{err:* (12) Generalized Spatial Lag/Autoregressive Error GS2SLS (SARARGS):}}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(sarargs) spar(rho) mfx(lin) test}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(sarargs) spar(lam) mfx(lin) test}
{hline}

{bf:{err:* (13) Generalized Spatial Lag/Autoregressive Error IV-GS2SLS (SARARIV):}}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(sarariv) spar(rho) mfx(lin) test}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(sarariv) spar(lam) mfx(lin) test}
{hline}

{bf:{err:* (14) Spatial Autoregressive Generalized Method of Moments (SPGMM):}}
 {stata spautoreg y  x1 x2 , wmfile(SPWcs) model(spgmm) mfx(lin) test}
{hline}

{bf:{err:* (15) Tobit Spatial Autoregressive Generalized Method of Moments (SPGMM):}}
 {stata spautoreg ys x1 x2 , wmfile(SPWcs) model(spgmm) mfx(lin) test tobit ll(0)}
{hline}

{bf:{err:* (16) Generalized Spatial 2SLS Models:}}
{bf:* (16-1) Generalized Spatial 2SLS - AR(1) (GS2SLS):}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(gs2sls) mfx(lin) test}

{bf:* (16-2) Generalized Spatial 2SLS - AR(2) (GS2SLS):}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(gs2sls) order(2) mfx(lin) test}

{bf:* (16-3) Generalized Spatial 2SLS - AR(3) (GS2SLS):}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(gs2sls) order(3) mfx(lin) test}

{bf:* (16-4) Generalized Spatial 2SLS - AR(4) (GS2SLS):}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(gs2sls) order(4) mfx(lin) test}
{hline}

{bf:{err:* (17) Generalized Spatial Autoregressive 2SLS (GS2SLSAR):}}
{bf:* (17-1) Generalized Spatial Autoregressive 2SLS - AR(1) (GS2SLSAR):}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(gs2slsar) order(1) lmi haus}

{bf:* (17-2) Generalized Spatial Autoregressive 2SLS - AR(2) (GS2SLSAR):}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(gs2slsar) order(2) mfx(lin) test}

{bf:* (17-3) Generalized Spatial Autoregressive 2SLS - AR(3) (GS2SLSAR):}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(gs2slsar) order(3) mfx(lin) test}

{bf:* (17-4) Generalized Spatial Autoregressive 2SLS - AR(4) (GS2SLSAR):}
{stata spautoreg y x1 x2 , wmfile(SPWcs) model(gs2slsar) order(4) mfx(lin) test}
{hline}

{bf:{err:* (18) Generalized Spatial 3SLS - (G32SLS)}}
* Y1 = Y2 X1 X2
* Y2 = Y1 X3 X4

{bf:* (18-1) Generalized Spatial 3SLS - AR(1) (GS3SLS):}
{stata spautoreg ys x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) lmn lmh}
{stata spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) order(1)}

{bf:* (18-2) Generalized Spatial 3SLS - AR(2) (GS3SLS):}
{stata spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) order(2)}

{bf:* (18-3) Generalized Spatial 3SLS - AR(3) (GS3SLS):}
{stata spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) order(3)}

{bf:* (18-4) Generalized Spatial 3SLS - AR(4) (GS3SLS):}
{stata spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) order(4)}
{hline}

{bf:{err:* (19) Generalized Spatial Autoregressive 3SLS - (GS3SLSAR):}}
{bf:* (19-1) Generalized Spatial Autoregressive 3SLS - AR(1) (GS3SLSAR):}
{stata spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) lmn lmh}
{stata spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(1) lmn}

{bf:* (19-2) Generalized Spatial Autoregressive 3SLS - AR(2) (GS3SLSAR):}
{stata spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(2)}

{bf:* (19-3) Generalized Spatial Autoregressive 3SLS - AR(3) (GS3SLSAR):}
{stata spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(3)}

{bf:* (19-4) Generalized Spatial Autoregressive 3SLS - AR(4) (GS3SLSAR):}
{stata spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(4)}
{hline}

{bf:{err:* (14) Spatial Autoregressive Generalized Method of Moments (SPGMM)} (Cont.):}
 This example is taken from Prucha data about:
 Generalized Moments Estimator for the Autoregressive Parameter in a Spatial Model  
 More details can be found in:
 {browse "http://econweb.umd.edu/~prucha/Research_Prog1.htm"}
 Results of {bf:model({err:{it:spgmm}})} is identical to:
 {browse "http://econweb.umd.edu/~prucha/STATPROG/OLS/PROGRAM1.log"}

   {stata clear all}
   {stata sysuse spautoreg1.dta , clear}
   {stata spautoreg y x1 , wmfile(SPWcs1) model(spgmm)}
{hline}

{bf:{err:* (16) Generalized Spatial Autoregressive 2SLS (GS2SLSAR)} (Cont.):}
 This example is taken from Prucha data about:
 Generalized Spatial Two-Stage Least Squares Procedures for Estimating
 a Spatial Autoregressive Model with Autoregressive Disturbances
 More details can be found in:
 {browse "http://econweb.umd.edu/~prucha/Research_Prog2.htm"}
 Results of {bf:model({err:{it:gs2slsar}})} with order(2) is identical to:
 {browse "http://econweb.umd.edu/~prucha/STATPROG/2SLS/PROGRAM2.log"}

   {stata clear all}
   {stata sysuse spautoreg2.dta , clear}
   {stata spautoreg y x1 , wmfile(SPWcs1) model(gs2slsar) order(2)}
{hline}

{bf:{err:* (17) Generalized Spatial Autoregressive 3SLS (GS3SLSAR)} (Cont.):}
 This example is taken from Prucha data about:
 Estimation of Simultaneous Systems of Spatially Interrelated Cross Sectional Equations
 More details can be found in:
 {browse "http://econweb.umd.edu/~prucha/Research_Prog4.htm"}
 Results of {bf:model({err:{it:gs3slsar}})} with order(2) is identical to:
 {browse "http://econweb.umd.edu/~prucha/STATPROG/SIMEQU/PROGRAM4.log"}

   {stata clear all}
   {stata sysuse spautoreg3.dta , clear}
   {stata spautoreg y1 x1 , var2(y2 x2) wmfile(SPWcs1) model(gs3slsar) order(2)}
{hline}

. clear all
. sysuse spautoreg.dta, clear
. spautoreg y x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) test

==============================================================================
*** Binary (0/1) Weight Matrix: 49x49 (Non Normalized)
==============================================================================

==============================================================================
* MLE Spatial Lag Normal Model (SAR)
==============================================================================
  y = x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          49   |   Cross Sections Number   =       
  Wald Test         =     56.4471   |   P-Value > Chi2(2)       =      0.0000
  F-Test            =     28.2236   |   P-Value > F(2 , 47)     =      0.0000
 (Buse 1973) R2     =      0.5510   |   Raw Moments R2          =      0.9184
 (Buse 1973) R2 Adj =      0.5414   |   Raw Moments R2 Adj      =      0.9166
  Root MSE (Sigma)  =     11.3305   |   Log Likelihood Function =   -186.8161
------------------------------------------------------------------------------
- R2h= 0.5510   R2h Adj= 0.5415  F-Test =   28.23 P-Value > F(2 , 47)  0.0000
- R2v= 0.5543   R2v Adj= 0.5448  F-Test =   28.61 P-Value > F(2 , 47)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y            |
          x1 |   -.252788   .1007052    -2.51   0.012    -.4501667   -.0554094
          x2 |  -1.585978   .3198759    -4.96   0.000    -2.212924    -.959033
       _cons |   64.04514   6.233457    10.27   0.000     51.82779    76.26249
-------------+----------------------------------------------------------------
         Rho |   .0211161   .0197638     1.07   0.285    -.0176202    .0598524
       Sigma |   10.94111    1.10546     9.90   0.000     8.774445    13.10777
------------------------------------------------------------------------------
 LR Test SAR vs. OLS (Rho=0):      1.1415   P-Value > Chi2(1)   0.2853
 Acceptable Range for Rho:        -0.3199 < Rho < 0.1633
------------------------------------------------------------------------------

==============================================================================
* Model Selection Diagnostic Criteria - Model= (sar)
==============================================================================
- Log Likelihood Function                   LLF            =   -186.8161
---------------------------------------------------------------------------
- Akaike Information Criterion              (1974) AIC     =    139.1818
- Akaike Information Criterion              (1973) Log AIC =      4.9358
---------------------------------------------------------------------------
- Schwarz Criterion                         (1978) SC      =    156.2734
- Schwarz Criterion                         (1978) Log SC  =      5.0516
---------------------------------------------------------------------------
- Amemiya Prediction Criterion              (1969) FPE     =    136.2414
- Hannan-Quinn Criterion                    (1979) HQ      =    145.4344
- Rice Criterion                            (1984) Rice    =    140.3238
- Shibata Criterion                         (1981) Shibata =    138.2198
- Craven-Wahba Generalized Cross Validation (1979) GCV     =    139.7269
------------------------------------------------------------------------------

==============================================================================
*** Spatial Aautocorrelation Tests - Model= (sar)
==============================================================================
  Ho: Error has No Spatial AutoCorrelation
  Ha: Error has    Spatial AutoCorrelation

- GLOBAL Moran MI            =   0.1476     P-Value > Z( 1.984)   0.0472
- GLOBAL Geary GC            =   0.7581     P-Value > Z(-1.861)   0.0627
- GLOBAL Getis-Ords GO       =  -0.7111     P-Value > Z(-1.980)   0.0476
------------------------------------------------------------------------------
- Moran MI Error Test        =   0.6624     P-Value > Z(8.047)    0.5077
------------------------------------------------------------------------------
- LM Error (Burridge)        =   2.3900     P-Value > Chi2(1)     0.1221
- LM Error (Robust)          =   2.9300     P-Value > Chi2(1)     0.0869
------------------------------------------------------------------------------
  Ho: Spatial Lagged Dependent Variable has No Spatial AutoCorrelation
  Ha: Spatial Lagged Dependent Variable has    Spatial AutoCorrelation

- LM Lag (Anselin)           =   0.0097     P-Value > Chi2(1)     0.9215
- LM Lag (Robust)            =   0.5497     P-Value > Chi2(1)     0.4585
------------------------------------------------------------------------------
  Ho: No General Spatial AutoCorrelation
  Ha:    General Spatial AutoCorrelation

- LM SAC (LMErr+LMLag_R)     =   2.9397     P-Value > Chi2(2)     0.2300
- LM SAC (LMLag+LMErr_R)     =   2.9397     P-Value > Chi2(2)     0.2300
------------------------------------------------------------------------------

==============================================================================
* Heteroscedasticity Tests - Model= (sar)
==============================================================================
 Ho: Homoscedasticity - Ha: Heteroscedasticity
------------------------------------------------------------------------------
- Hall-Pagan LM Test:      E2 = Yh     =   0.9799    P-Value > Chi2(1)  0.3222
- Hall-Pagan LM Test:      E2 = Yh2    =   0.5735    P-Value > Chi2(1)  0.4489
- Hall-Pagan LM Test:      E2 = LYh2   =   1.1041    P-Value > Chi2(1)  0.2934
------------------------------------------------------------------------------
- Harvey LM Test:       LogE2 = X      =   2.7678    P-Value > Chi2(2)  0.2506
- Wald LM Test:         LogE2 = X      =   6.8293    P-Value > Chi2(1)  0.0090
- Glejser LM Test:        |E| = X      =   7.1015    P-Value > Chi2(2)  0.0287
------------------------------------------------------------------------------
- Machado-Santos-Silva Test: Ev=Yh Yh2 =   2.8060    P-Value > Chi2(2)  0.2459
- Machado-Santos-Silva Test: Ev=X      =   7.0429    P-Value > Chi2(2)  0.0296
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X      =   7.1879    P-Value > Chi2(2)  0.0275
- White Test -B-P-G (SSR): E2 = X      =   9.9225    P-Value > Chi2(2)  0.0070
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X X2   =   7.5497    P-Value > Chi2(4)  0.1095
- White Test -B-P-G (SSR): E2 = X X2   =  10.4218    P-Value > Chi2(4)  0.0339
------------------------------------------------------------------------------
- White Test -Koenker(R2): E2 = X X2 XX=  18.7572    P-Value > Chi2(5)  0.0021
- White Test -B-P-G (SSR): E2 = X X2 XX=  25.8930    P-Value > Chi2(5)  0.0001
------------------------------------------------------------------------------
- Cook-Weisberg LM Test  E2/Sig2 = Yh  =   1.3527    P-Value > Chi2(1)  0.2448
- Cook-Weisberg LM Test  E2/Sig2 = X   =   9.9225    P-Value > Chi2(2)  0.0070
------------------------------------------------------------------------------
*** Single Variable Tests (E2/Sig2):
- Cook-Weisberg LM Test: x1                =   0.8877 P-Value > Chi2(1) 0.3461
- Cook-Weisberg LM Test: x2                =   4.5468 P-Value > Chi2(1) 0.0330
------------------------------------------------------------------------------
*** Single Variable Tests:
- King LM Test: x1                         =   0.0468 P-Value > Chi2(1) 0.8287
- King LM Test: x2                         =   4.7943 P-Value > Chi2(1) 0.0286
------------------------------------------------------------------------------

==============================================================================
* Non Normality Tests - Model= (sar)
==============================================================================
 Ho: Normality - Ha: Non Normality
------------------------------------------------------------------------------
*** Non Normality Tests:
- Jarque-Bera LM Test                  =   1.6737     P-Value > Chi2(2) 0.4331
- White IM Test                        =   5.4242     P-Value > Chi2(2) 0.0664
- Doornik-Hansen LM Test               =   3.8663     P-Value > Chi2(2) 0.1447
- Geary LM Test                        =  -3.3066     P-Value > Chi2(2) 0.1914
- Anderson-Darling Z Test              =   0.3147     P > Z( 0.181)     0.5716
- D'Agostino-Pearson LM Test           =   2.5887     P-Value > Chi2(2) 0.2741
------------------------------------------------------------------------------
*** Skewness Tests:
- Srivastava LM Skewness Test          =   0.4911     P-Value > Chi2(1) 0.4835
- Small LM Skewness Test               =   0.6007     P-Value > Chi2(1) 0.4383
- Skewness Z Test                      =  -0.7750     P-Value > Chi2(1) 0.4383
------------------------------------------------------------------------------
*** Kurtosis Tests:
- Srivastava  Z Kurtosis Test          =   1.0875     P-Value > Z(0,1)  0.2768
- Small LM Kurtosis Test               =   1.9880     P-Value > Chi2(1) 0.1585
- Kurtosis Z Test                      =   1.4100     P-Value > Chi2(1) 0.1585
------------------------------------------------------------------------------
    Skewness Coefficient = -0.2452     - Standard Deviation =  0.3398
    Kurtosis Coefficient =  3.7611     - Standard Deviation =  0.6681
------------------------------------------------------------------------------
    Runs Test: (14) Runs -  (23) Positives - (26) Negatives
    Standard Deviation Runs Sig(k) =  3.4501 , Mean Runs E(k) = 25.4082
    95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (18.6460 , 32.1703 )
------------------------------------------------------------------------------

==============================================================================
*** Tobit Heteroscedasticity LM Tests Model= (sar)
==============================================================================
 Separate LM Tests - Ho: Homoscedasticity
- LM Test: x1                   =    0.8065   P-Value > Chi2(1)   0.3692
- LM Test: x2                   =    8.2353   P-Value > Chi2(1)   0.0041

 Joint LM Test     - Ho: Homoscedasticity
 - LM Test                      =    8.2933   P-Value > Chi2(2)   0.0158

==============================================================================
*** Tobit Non Normality LM Tests - Model= (sar)
==============================================================================
 LM Test - Ho: No Skewness
 - LM Test                      =    0.4723   P-Value > Chi2(1)   0.4919

 LM test - Ho: No Kurtosis
 - LM Test                      =    2.5256   P-Value > Chi2(1)   0.1120

 LM Test - Ho: Normality (No Kurtosis, No Skewness)
 - Pagan-Vella LM Test          =    2.5809   P-Value > Chi2(2)   0.2751
 - Chesher-Irish LM Test        =   48.9962   P-Value > Chi2(2)   0.0000
------------------------------------------------------------------------------

==============================================================================
*** REgression Specification Error Tests (RESET) - Model= (sar)
==============================================================================
 Ho: Model is Specified  -  Ha: Model is Misspecified
------------------------------------------------------------------------------
* Ramsey Specification ResetF Test
- Ramsey RESETF1 Test: Y= X Yh2         =   1.466  P-Value > F(1,  45) 0.2324
- Ramsey RESETF2 Test: Y= X Yh2 Yh3     =   0.717  P-Value > F(2,  44) 0.4940
- Ramsey RESETF3 Test: Y= X Yh2 Yh3 Yh4 =   1.214  P-Value > F(3,  43) 0.3162
------------------------------------------------------------------------------
* DeBenedictis-Giles Specification ResetL Test
- Debenedictis-Giles ResetL1 Test       =   1.304  P-Value > F(2, 44)  0.2818
- Debenedictis-Giles ResetL2 Test       =   0.986  P-Value > F(4, 42)  0.4253
- Debenedictis-Giles ResetL3 Test       =   0.940  P-Value > F(6, 40)  0.4772
------------------------------------------------------------------------------
* DeBenedictis-Giles Specification ResetS Test
- Debenedictis-Giles ResetS1 Test       =   1.632  P-Value > F(2, 44)  0.2071
- Debenedictis-Giles ResetS2 Test       =   1.697  P-Value > F(4, 42)  0.1688
- Debenedictis-Giles ResetS3 Test       =   1.990  P-Value > F(6, 40)  0.0900
------------------------------------------------------------------------------
- White Functional Form Test: E2= X X2  =   7.550  P-Value > Chi2(1)   0.0229
------------------------------------------------------------------------------

* Beta, Total, Direct, and InDirect (Model= sar): Linear: Marginal Effect *

+-------------------------------------------------------------------------------+
|     Variable |    Beta(B) |      Total |     Direct |   InDirect |       Mean |
|--------------+------------+------------+------------+------------+------------|
|y             |            |            |            |            |            |
|           x1 |    -0.2528 |    -0.2522 |    -0.2266 |    -0.0256 |    38.4362 |
|           x2 |    -1.5860 |    -1.5824 |    -1.4218 |    -0.1606 |    14.3749 |
+-------------------------------------------------------------------------------+

* Beta, Total, Direct, and InDirect (Model= sar): Linear: Elasticity *

+-------------------------------------------------------------------------------+
|     Variable |   Beta(Es) |      Total |     Direct |   InDirect |       Mean |
|--------------+------------+------------+------------+------------+------------|
|           x1 |    -0.2766 |    -0.2760 |    -0.2480 |    -0.0280 |    38.4362 |
|           x2 |    -0.6490 |    -0.6475 |    -0.5818 |    -0.0657 |    14.3749 |
+-------------------------------------------------------------------------------+
 Mean of Dependent Variable =     35.1288

{p2colreset}{...}
{marker 15}{bf:{err:{dlgtab:Acknowledgments}}}

  I would like to thank the authors of the following Stata modules:

   - David Drukker, and Ingmar Prucha for writing {helpb sppack}.

   - Maurizio Pisati for stata module {helpb spatreg}.

   - Wilner Jeanty for stata module {helpb spmlreg}.

{p2colreset}{...}
{marker 16}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:SPAUTOREG Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:SPAUTOREG: "Spatial Cross Sections Regression Models:}{p_end}
{phang}{cmd:(SAR-SEM-SDM-SAC-SARARGS-SARARIV-SARARML-SPGMM-}{p_end}
{phang}{cmd:GS2SLS-GS2SLSAR-GS3SLS-GS3SLSAR-IVTOBIT)"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457338.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457338.htm"}


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
{helpb gs3sls}{col 14}Generalized Spatial Autoregressive 3SLS Regression 
{helpb gs3slsar}{col 14}Generalized Spatial Autoregressive 3SLS Cross Sections Regression
{helpb gsp3sls}{col 14}Generalized Spatial 3SLS Cross Sections Regression
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

