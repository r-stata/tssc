{smcl}
{hline}
{cmd:help: {helpb spregcs}}{space 50} {cmd:dialog:} {bf:{dialog spregcs}}
{hline}
{bf:{err:{dlgtab:Title}}}
{bf:spregcs: Spatial Cross Sections Econometric Regression Models:}
{p 9 1 1}{bf:(SAR - SEM - SDM - SAC - mSTAR - GWR - GS2SLS - GS2SLSAR - GS3SLS - GS3SLSAR -}{p_end}
{p 10 1 1}{bf:IVTOBIT - SARARGS - SARARIV - SARARML - SPGMM - OLS - LAG - DURBIN)}{p_end}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb spregcs##01:Syntax}{p_end}
{p 5}{helpb spregcs##02:Description}{p_end}
{p 5}{helpb spregcs##03:Options}{p_end}
{p 5}{helpb spregcs##04:Model Options}{p_end}
{p 5}{helpb spregcs##05:Run Options}{p_end}
{p 5}{helpb spregcs##06:GMM Options}{p_end}
{p 5}{helpb spregcs##07:Ridge Options}{p_end}
{p 5}{helpb spregcs##08:Weight Options}{p_end}
{p 5}{helpb spregcs##09:Weighted Variable Type Options}{p_end}
{p 5}{helpb spregcs##10:Other Options}{p_end}
{p 5}{helpb spregcs##11:Spatial Aautocorrelation Tests}{p_end}
{p 5}{helpb spregcs##12:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb spregcs##13:Heteroscedasticity Tests}{p_end}
{p 5}{helpb spregcs##14:Non Normality Tests}{p_end}
{p 5}{helpb spregcs##15:Hausman Specification Test OLS/IV-2SLS Tests}{p_end}
{p 5}{helpb spregcs##16:Identification Restrictions LM Tests}{p_end}
{p 5}{helpb spregcs##17:REgression Specification Error Tests (RESET)}{p_end}
{p 5}{helpb spregcs##18:Linear vs Log-Linear Functional Form Tests}{p_end}
{p 5}{helpb spregcs##19:Multicollinearity Diagnostic Tests}{p_end}
{p 5}{helpb spregcs##20:Saved Results}{p_end}
{p 5}{helpb spregcs##21:References}{p_end}

{p 1}*** {helpb spregcs##22:Examples}{p_end}

{p 5}{helpb spregcs##23:Acknowledgments}{p_end}
{p 5}{helpb spregcs##24:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt spregcs} {depvar} {indepvars} , {p_end} 
{p 3 5 6} 
{err: [}{opt m:odel(sar|sem|sdm|sac|gwr|mstar|mstard|sararml|sarargs|sarariv)}{p_end} 
{p 4 5 6} 
{opt m:odel(spgmm|gs2sls|gs2slsar|gs3sls|gs3slsar|ols|lag|durbin)}{p_end} 
{p 5 5 6}
{opt run(ols|tobit|sfa|2sls|fuller|gmm|kclass|liml|melo)} {opt hetc:ov(gmm_type)} {p_end}
{p 5 5 6} 
{opt wmf:ile(weight_file)} {opt weights(yh|yh2|abse|e2|x|xi|x2|xi2)} {opt wv:ar(varname)} {opt rid:ge(orr|grr1|grr2|grr3)} {opt kr(#)}{p_end} 
{p 5 5 6} 
{opt lmsp:ac} {opt lma:uto} {opt lmh:et} {opt lmf:orm} {opt lmn:orm} {opt lmcl} {opt lmi:den} {opt haus:man} {opt reset} {opt diag} {opt test:s}{p_end} 
{p 5 5 6} 
{opt stand inv inv2 dn} {opt dist(norm|exp|weib|hn|tn)} {opt mfx(lin, log)} {opt spar(rho, lam)}{p_end} 
{p 5 5 6} 
{opt endog(vars)} {opt inst(vars)} {opt var2(varlist)} {opt aux(varlist)} {opt mhet(varlist)}{p_end} 
{p 5 5 6} 
{opt vhet(varlist)} {opt nw:mat(#)} {opt ord:er(#)} {opt inr:ho(real 0)} {opt inl:ambda(real 0)} {opt ll(real 0)}{p_end} 
{p 5 5 6} 
{opt eq(1, 2)} {opt pred:ict(new_var)} {opt res:id(new_var)} {opt iter(#)} {opt tech(name)} {opt rest(#)}{p_end} 
{p 5 5 6} 
{opt coll cost} {opt zero} {opt ols 2sls 3sls sure mvreg first} {opt nocons:tant} {opt noconexog}{p_end} 
{p 5 5 6} 
{opt tobit tolog nolog} {opt rob:ust} {opt twos:tep} {opt grids(#)} {opt het} {opt impower(#)} {opt l:evel(#)}{p_end} 
{p 5 5 6} 
{opth vce(vcetype)} {helpb maximize} {it:other maximization options} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

 {cmd:spregcs} is a complete toolkit software package
 for Spatial Cross Sections Regression Models estimation
 Many types of spatial autocorrelations were taken under consedration, i.e.,
 (SAR - SEM - SDM - SAC - MSTAR - GS2SLS - GS2SLSAR - GS3SLS - GS3SLSAR -
  IVTOBIT - SARARGS - SARARIV - SARARML - SPGMM - OLS - LAG - DURBIN)

 {cmd:spregcs} can estimate the following models:
   1- Heteroscedastic Regression Models in disturbance term.
   2- Non Normal Regression Models in disturbance term.
   3- Multicollinearity Regression Models in independent variables.

In fact {cmd:spregcs} estimates many Spatial & Non Spatial Models, even OLS regression:

 - {cmd:spregcs varlist , model(ols) run(ols)}
   without choosing: wmfile( )
   {cmd:spregcs} let you get identical OLS results from {helpb regress}

 - ALL Diagnostic tests also are valid in the case of all models.

 {cmd:spregcs} estimates Continuous and Truncated Dependent Variables models {cmd:tobit}.

{p 2 2 2} {bf:model({err:{it:sar, sem, sdm, sac, spgmm, ols, lag, durbin}})} deals with data either continuous or truncated dependent variable. If {depvar} has missing values or lower limits,
so in this case {bf: model({err:{it:sar, sem, sdm, sac, spgmm, ols, lag, durbin}})} will fit spatial cross section model via {helpb tobit} model,
and thus {cmd:spregcs} can resolve the problem of missing values that exist in many kinds of data. Otherwise, in the case of continuous data, the normal estimation will be used.{p_end}

{p 2 4 2}{cmd:spregcs} can generate:{p_end}
    {cmd:- Binary / Standardized Weight Matrix.}
    {cmd:- Inverse  / Inverse Squared Standardized Weight Matrix.}
    {cmd:- Binary / Standardized / Inverse Eigenvalues Variable.}
    {cmd:- Spatial lagged variables up to 4th order.}

{p 2 4 2} {cmd:spregcs} predicted values in {bf: model({err:{it:sar, sdm, sac}})} models are obtained from conditional expectation expression.{p_end}

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
{cmd:spregcs} generates some variables names with prefix:
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

{synoptset 3 tabbed}{...}
{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Model Options}}}

{cmd: 1-} {bf:model({err:{it:sar}})}      MLE Spatial Lag Model (SAR)

{cmd: 2-} {bf:model({err:{it:sdm}})}      MLE Spatial Durbin Model (SDM)

{cmd: 3-} {bf:model({err:{it:sem}})}      MLE Spatial Error Model (SEM)

{cmd: 4-} {bf:model({err:{it:sac}})}      MLE Spatial Lag / Error Model (SAC) "Spatial AutoCorrelation"

{cmd: 5-} {bf:model({err:{it:mstar}})}    Multiparametric Spatio Temporal AutoRegressive Regression Model
{p 20 20 2}mSTAR Lag Model{p_end}

{cmd: 6-} {bf:model({err:{it:mstard}})}   Multiparametric Spatio Temporal AutoRegressive Regression Model
{p 20 20 2}mSTAR Durbin Model{p_end}
{p 2 2 2}{bf:model({err:{it:mstar, mstard}})} are used with more than Weight Matrix: (Border, Language, Currency, Trade...){p_end}

{cmd: 7-} {bf:model({err:{it:gwr}})}      Geographically Weighted Regressions (GWR)

{cmd: 8-} {bf:model({err:{it:spgmm}})}    Spatial Autoregressive Generalized Method of Moments Model
{p 20 20 2}When cross section data model with error are both spatially correlated.
Generalized Method of Moments (GMM) that suggested in Kelejian-Prucha (1999) is used in the estimation of {bf:model({err:{it:spgmm}})}{p_end}

{cmd: 9-} {bf:model({err:{it:spgmm}})}    Tobit Spatial Autoregressive GMM {bf: with option({err:{it:tobit}})}

{cmd:10-} {bf:model({err:{it:gs2sls}})}   Generalized Spatial 2SLS

{cmd:11-} {bf:model({err:{it:gs2slsar}})} Generalized Spatial Autoregressive 2SLS [Kelejian-Prucha(1998)]
{p 20 20 2}Since no softwares available till now to estimate generalized spatial cross section autoregressive 2SLS models, I designed {cmd:gs2slsar} as a modification of Kapoor-Kelejian-Prucha (1999).{p_end}

{cmd:12-} {bf:model({err:{it:gs3sls}})}   Generalized Spatial 3SLS Model

{cmd:13-} {bf:model({err:{it:gs3slsar}})} Generalized Spatial Autoregressive 3SLS Model [Kelejian-Prucha(2004)]

{cmd:14-} {bf:model({err:{it:ivtobit}})} MLE - IV Spatial Tobit Model Truncated {depvar}  ({help ivtobit})

{cmd:15-} {bf:model({err:{it:sararml}})} MLE - Spatial Lag/Autoregressive Error ({help spreg})
{p 20 20 2}{it:Requires Stata v11.2 and (sppack) module} {bf:{stata ssc install sppack}}

{cmd:16-} {bf:model({err:{it:sarargs}})} Generalized Spatial Lag/Autoregressive Error GS2SLS ({help spreg})
{p 20 20 2}{it:Requires Stata v11.2 and (sppack) module} {bf:{stata ssc install sppack}}

{cmd:17-} {bf:model({err:{it:sarariv}})} Generalized Spatial Lag/Autoregressive Error IV-GS2SLS ({help spivreg})
{p 20 20 2}{it:Requires Stata v11.2 and (sppack) module} {bf:{stata ssc install sppack}}

{cmd:18-} {bf:model({err:{it:ols}})}    Linear Models (Non Spatial)
{cmd:19-} {bf:model({err:{it:lag}})}    Linear Spatial Lag Models (SAR)
{cmd:20-} {bf:model({err:{it:durbin}})} Linear Spatial Durbin Models (SDM)

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Run Options}}}

{synopt :{opt run( )} is used with Spatial: {bf:model({err:{it:ols, lag, durbin, gs2sls, gs2slsar}})}}{p_end}

 {bf: 1- run(ols)}{col 20}[{helpb regress}] Ordinary Least Squares (OLS)
 {bf: 2- run(qreg)}{col 20}[{helpb qreg}] Quantile Regression (QREG)
 {bf: 3- run(rreg)}{col 20}[{helpb rreg}] Robust   Regression (RREG)
 {bf: 4- run(sfa)}{col 20}[{helpb frontier}] Stochastic Frontier Regression
 {bf: 5- run(tobit)}{col 20}[{helpb tobit}] Tobit Regression

 {bf: 6- run(2sls)}{col 20}Two-Stage Least Squares (2SLS)
 {bf: 7- run(fuller)}{col 20}Fuller k-Class LIML
{col 23}{bf:kf({err:{it:#}})} Fuller k-Class LIML Value
 {bf: 8- run(gmm)}{col 20}Generalized Method of Moments (GMM)
 {bf: 9- run(kclass)}{col 20}Theil K-Class LIML
{col 23}{bf:kc({err:{it:#}})} Theil k-Class LIML Value
 {bf:10- run(liml)}{col 20}Limited-Information Maximum Likelihood (LIML)
 {bf:11- run(melo)}{col 20}Minimum Expected Loss (MELO)

{col 3}{opt rob:ust}{col 20}Use Huber-White Variance-Covariance Matrix

{marker 06}{bf:{err:{dlgtab:GMM Options}}}

{synoptset 16}{...}
{p2coldent:{it:hetcov Options}}Description{p_end}

{synopt:{bf:hetcov({err:{it:white}})}}White Method{p_end}
{synopt:{bf:hetcov({err:{it:bart}})}}Bartlett Method{p_end}
{synopt:{bf:hetcov({err:{it:dan}})}}Daniell Method{p_end}
{synopt:{bf:hetcov({err:{it:nwest}})}}Newey-West Method{p_end}
{synopt:{bf:hetcov({err:{it:parzen}})}}Parzen Method{p_end}
{synopt:{bf:hetcov({err:{it:quad}})}}Quadratic Spectral Method{p_end}
{synopt:{bf:hetcov({err:{it:tent}})}}Tent Method{p_end}
{synopt:{bf:hetcov({err:{it:trunc}})}}Truncated Method{p_end}
{synopt:{bf:hetcov({err:{it:tukeym}})}}Tukey-Hamming Method{p_end}
{synopt:{bf:hetcov({err:{it:tukeyn}})}}Tukey-Hanning Method{p_end}

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:Ridge Options}}}

{p 3 6 2} {opt kr(#)} Ridge k value, must be in the range (0 < k < 1).{p_end}

{p 3 6 2}IF {bf:kr(0)} in {opt ridge(orr, grr1, grr2, grr3)}, model will be normal cross section regression.{p_end}

{col 3}{bf:ridge({err:{it:orr}})} : Ordinary Ridge Regression    [Judge,et al(1988,p.878) eq.21.4.2].
{col 3}{bf:ridge({err:{it:grr1}})}: Generalized Ridge Regression [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:ridge({err:{it:grr2}})}: Iterative Generalized Ridge  [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:ridge({err:{it:grr3}})}: Adaptive Generalized Ridge   [Strawderman(1978)].

	{bf:ridge( )} {cmd:works only with:} 
	{bf:model({err:{it:ols, lag, durbin, spgmm}})}
	{bf:run({err:{it:2sls, fuller, gmm, kclass, liml, melo}})}

{p 2 4 2}{cmd:spregcs} estimates Ridge regression as a multicollinearity remediation method.{p_end}
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
{marker 08}{bf:{err:{dlgtab:Weight Options}}}

{synoptset 16}{...}
{synopt:{bf:wvar({err:{it:varname}})}}Weighted Variable Name{p_end}

{col 10}{bf:wvar( )} {cmd:must be combined with:} {bf:weights(x, xi, x2, xi2)}"

{p2colreset}{...}
{marker 09}{bf:{err:{dlgtab:Weighted Variable Type Options}}}
{synoptset 16}{...}

{synopt:{bf:weights({err:{it:yh}})}}Yh - Predicted Value{p_end}
{synopt:{bf:weights({err:{it:yh2}})}}Yh^2 - Predicted Value Squared{p_end}
{synopt:{bf:weights({err:{it:abse}})}}abs(E) - Absolute Value of Residual{p_end}
{synopt:{bf:weights({err:{it:e2}})}}E^2 - Residual Squared{p_end}
{synopt:{bf:weights({err:{it:x}})}}(x) Variable{p_end}
{synopt:{bf:weights({err:{it:xi}})}}(1/x) Inverse Variable{p_end}
{synopt:{bf:weights({err:{it:x2}})}}(x^2) Squared Variable{p_end}
{synopt:{bf:weights({err:{it:xi2}})}}(1/x^2) Inverse Squared Variable{p_end}

{p2colreset}{...}
{marker 10}{bf:{err:{dlgtab:Other Options}}}
{synoptset 8}{...}

{col 3}{opt zero}{col 20}convert missing values observations to Zero

{col 3}{opt ord:er(1,2,3,4)}{col 20}Order of lagged independent variables up to maximum 4th order.
{col 15}{bf:order(2,3,4)} works only with: {bf:model({err:{it:gs2sls, gs2slsar}})}. Default is 1

{col 3}{opt nw:mat(1,2,3,4)}{col 20}number of Rho's matrixes to be used with: {bf:model({err:{it:mstar, mstard}})}}

{col 3}{opt endog(vars)}{col 20}add other additional Endogenous Variables
{col 20}in {bf:model({err:{it:gs2sls, gs2slsar, sarariv, ivtobit}})}

{col 3}{opt inst(vars)}{col 20}add other additional Instrumental Variables with
{col 20}{bf:model({err:{it:gs2sls, gs2slsar, sarariv, ivtobit}})}
{col 20}if the same variables are included in {opt aux(varlist)},
{col 20}so Instrumental Variables will be Exogenous variables in RHS side

{cmd:spregcs command:}
{stata spregcs y1 x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) endog(y2) inst(x3 x4)}

{cmd:is identical to}
{stata ivregress 2sls y1 x1 x2 (w1y_y1 y2 = x1 x2 x3 x4 w1x_x1 w1x_x2)}

***{cmd:Both additional Endogenous and Instrumental Variables in:}
   {bf:model({err:{it:gs2sls, gs2slsar, sarariv, ivtobit}})}
   {cmd:will be added without converting them to spatial lagged variables}

{synopt:{opt eq(1, 2)}}Tests for equation (#) in {bf:model({err:{it:gs3sls, gs3slsar}})}, default is 1.{p_end}

{synopt:{opt var2(varlist)}}Dependent-Independent Variables for second equation in {bf:model({err:{it:gs3sls, gs3slsar}})}.{p_end}

	var2(varlist) must be combine with: model(gs3sls)
	if you have system of 2 Equations:
	Y1 = Y2 X1 X2
	Y2 = Y1 X3 X4
	Variables of Eq.1 are: Dep. & Indep. Variables
	Variables of Eq.2 are: Dep. & Indep. Variables [in option var2( )]; i.e,
	{stata spregcs y1 x1 x2 , wmfile(SPWcs) model(gs3sls) var2(y2 x3 x4) eq(1)}
	{stata spregcs y1 x1 x2 , wmfile(SPWcs) model(gs3sls) var2(y2 x3 x4) eq(2)}

{col 3}{opt rest(#)}{col 20}Number of Restrections.

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{col 3}{opt cost}{col 20}Fit Cost Frontier instead of Production Function {cmd:run({helpb frontier})}

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from RHS Equation only
{col 20}not valid in {bf:model({err:{it:sem, sac}})}

{col 3}{opt noconexog}{col 20}Exclude Constant Term from all Equations
{col 20}(both RHS and Instrumental Equations).
{col 20}Default of {cmd:spregcs} is including Constant Term
{col 20} in both RHS and Instrumental Equations

{col 3}{opt haus:man}{col 20}Hausman Specification Tests

{col 3}{opt test:s}{col 20}display ALL lma, lmc, lmf, lmh, lmn, lmsp, lmi, diag, reset, haus tests

{col 3}{opt dn}{col 20}Use (N) divisor instead of (N-K) for Degrees of Freedom (DF)

{col 3}{opt ols}{col 20}{bf:model({err:{it:gs3sls}})} Ordinary Least Squares (OLS)
{col 3}{opt 2sls}{col 20}{bf:model({err:{it:gs3sls}})} Two-Stage Least Squares (2SLS)
{col 3}{opt 3sls}{col 20}{bf:model({err:{it:gs3sls}})} Three-Stage Least Squares (3SLS)
{col 3}{opt sure}{col 20}{bf:model({err:{it:gs3sls}})} Seemingly Unrelated Regression Estimation (SURE)
{col 3}{opt mvreg}{col 20}{bf:model({err:{it:gs3sls}})} SURE with OLS DF adjustment (MVREG)
{col 3}{opt first}{col 20}{bf:model({err:{it:gs3sls, ivtobit}})}
{col 20}display Full first-stage regression, diagnostic and identification tests

{col 3}{opt grids(#)}{col 20}{bf:model({err:{it:sararml}})}initial grid search values of lambda and rho parameters

{col 3}{opt het}{col 20}{bf:model({err:{it:sarargs, sarariv}})} Use estimator for heteroskedastic disturbance terms

{col 3}{opt impower(#)}{col 20}{bf:model({err:{it:sarargs, sarariv}})}
{col 20}Use q powers of matrix W to form instrument matrix H (q= 2,3,...,7).
{col 20}Default is 2

{col 3}{opt mle}{col 20}conditional maximum-likelihood estimator; {cmd:model({helpb ivtobit)}

{col 3}{opt two:step}{col 20}Newey's two-step estimator; {cmd:model({helpb ivtobit)}

{col 3}{opt inrho(#)}{col 20}Set initial value for rho; default is 0

{col 3}{opt inlam:bda(#)}{col 20}Set initial value for lambda; default is 0

{col 3}{opt nolog}{col 20}suppress iteration of the log likelihood

{col 3}{opt tobit}{col 20}Estimate model via Tobit regression 

{col 3}{opt ll(#)}{col 20}value of minimum left-censoring dependent variable with:
{col 20}{bf:model({err:{it:sar, sem, sdm, sac, spgmm}})}, and {bf:run({err:{it:tobit}})}; default is 0

{col 3}{opt mfx(lin, log)}{col 20}functional form: Linear model {cmd:(lin)}, or Log-Log model {cmd:(log)},
{col 20}to compute Total, Direct, and InDirect Marginal Effects and Elasticities
   - In Linear model: marginal effects are the coefficients (Bm),
        and elasticities are (Es = Bm X/Y).
   - In Log-Log model: elasticities are the coefficients (Es),
        and the marginal effects are (Bm = Es Y/X).
   - {opt mfx(log)} and {opt tolog} options must be combined, to transform linear variables to log form.

{p 8 4 2}{opt mfx(lin, log)} with {bf:model({err:{it:sar, sdm, sac, mstar, mstard}})} can calculate:{p_end}
		{cmd:- Total    Marginal Effects and Elasticities.}
		{cmd:- Direct   Marginal Effects and Elasticities.}
		{cmd:- InDirect Marginal Effects and Elasticities.}

{col 3}{opt tolog}{col 20}Convert dependent and independent variables
{col 20}to LOG Form in the memory for Log-Log regression.
{col 20}{opt tolog} Transforms {depvar} and {indepvars}
{col 20}to Log Form without lost the original data variables

{synopt :{opt spar(rho, lam)}}type of spatial autoregressive coefficients, {cmd:(rho)} [Rho], and {cmd:(lam)} [Lambda]{p_end}
       - {opt spar(rho)} is default for {bf:model({err:{it:sar, sac, sdm, mstar, mstard, sararml, sarargs, sarariv}})}
       - {opt spar(rho)} cannot be used with {bf:model({err:{it:sem}})}

       - {opt spar(lam)} is default for {bf:model({err:{it:sem}})}
       - {opt spar(lam)} cannot be used with {bf:model({err:{it:sar, sdm, mstar, mstard}})}
       - {opt spar(lam)} is an alternative with {bf:model({err:{it:sac}})}
       
       - {bf:model({err:{it:sac, sararml, sarargs, sarariv}})} work with the two types {opt spar(rho, lam)}
       - {bf:model({err:{it:lag, gs2sls, gs2slsar, gs3sls, gs3slsar, ivtobit}})}
         not work with the two types {opt spar(rho, lam)}

{synopt :{bf:dist({err:{it:norm, exp, weib}})} Distribution of error term:}{p_end}
{p 12 2 2}1- {bf:dist({err:{it:norm}})} Normal distribution; default.{p_end}
{p 12 2 2}2- {bf:dist({err:{it:exp}})}  Exponential distribution.{p_end}
{p 12 2 2}3- {bf:dist({err:{it:weib}})} Weibull distribution.{p_end}

{p 12 2 2}4- {bf:dist({err:{it:hn}})} Half-Normal distribution, {bf:run({err:{it:sfa}})}.{p_end}
{p 12 2 2}5- {bf:dist({err:{it:tn}})} Truncated-Normal distribution, {bf:run({err:{it:sfa}})}.{p_end}

{p 10 10 1}{cmd:dist} option is used to remedy non normality problem, when the error term has non normality distribution.{p_end}
{p 10 10 1} {opt dist(norm, exp, weib)} with {bf:model({err:{it:sar, sem, sdm, sac, mstar, mstard}})}.{p_end}

{p 10 10 1}{bf:dist({err:{it:norm}})} is the default distribution.{p_end}

{p 2 10 10}{opt aux(varlist)}}add Auxiliary Variables into regression model without converting them to spatial lagged variables, or without {cmd:log} form, i.e., dummy variables.
This option dont include these auxiliary variables among spatial lagged variables, it is useful in {bf:model({err:{it:sdm, durbin, mstard}})}
to avoid lost degrees of freedom (DF).
Using many dummy variables must be used with caution to avoid multicollinearity problem, that causes singular matrix, and lead to abort estimation.
{opt aux( )} not works with {bf:model({err:{it:sem, sac}})}.{p_end} 

{p 2 10 10}{opt mhet(varlist)} Set variable(s) that will be included in {cmd:Spatial cross section Multiplicative Heteroscedasticity} model, this option is used with {bf:model({err:{it:sar, sdm, mstar, mstard}})}, to remidy Heteroscedasticity.
option {weight}, can be used in the case of Heteroscedasticity in errors.{p_end}

{p 2 10 10}{opt vhet(varlist)} Explanatory Variables for idiosyncratic error variance function; use noconstant to suppress constant term. this option is used with {bf:run({err:{it:sfa}})}.{p_end}

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
{marker 11}{bf:{err:{dlgtab:Spatial Aautocorrelation Tests}}}

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
   - Geographically Weighted Regression: wY = wBX    ; e = lWe+u

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
{marker 12}{bf:{err:{dlgtab:Model Selection Diagnostic Criteria}}}

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
{marker 13}{bf:{err:{dlgtab:Heteroscedasticity Tests}}}

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
{marker 14}{bf:{err:{dlgtab:Non Normality Tests}}}

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
{marker 15}{bf:{err:{dlgtab:Hausman Specification Test (InConsistent Problem)}}}

{synopt:{opt haus:man}}Hausman Specification Test (InConsistent Problem){p_end}
	- Ho = B Consistent  * Ha = B InConsistent
	  LM = (Bi-Bo)'inv(Vi-Vo)*(Bi-Bo)

{p2colreset}{...}
{marker 16}{bf:{err:{dlgtab:Identification Restrictions LM Tests}}}

{synopt :{opt lmiden} Identification Restrictions LM Tests:}{p_end}
	- Y  = LHS Dependent Variable in Equation i
	- Yi = RHS Endogenous Variables in Equation i
	- Xi = RHS Included Exogenous Variables in   Equation i
	- Z  = Overall Exogenous Variables in the System
	- Sargan  LM Test
	- Basmann LM Test
	- Hansen Over Identification LM Test

{p2colreset}{...}
{marker 17}{bf:{err:{dlgtab:REgression Specification Error Tests (RESET)}}}

{synopt :{opt reset} REgression Specification Error Tests (RESET)}{p_end}
	* Ho: Model is Specified - Ha: Model is Misspecified
	- Ramsey RESET2 Test: Y= X Yh2
	- Ramsey RESET3 Test: Y= X Yh2 Yh3
	- Ramsey RESET4 Test: Y= X Yh2 Yh3 Yh4
	- DeBenedictis-Giles Specification ResetL Test
	- DeBenedictis-Giles Specification ResetS Test
	- White Functional Form Test: E2= X X2

{p2colreset}{...}
{marker 18}{bf:{err:{dlgtab:Linear vs Log-Linear Functional Form Tests}}}

{synopt:{opt lmf:orm}} Linear vs Log-Linear Functional Form Tests{p_end}
	- R-squared
 	- Log Likelihood Function (LLF)
 	- Antilog R2
 	- Box-Cox Test
 	- Bera-McAleer BM Test
 	- Davidson-Mackinnon PE Test

{p2colreset}{...}
{marker 19}{bf:{err:{dlgtab:Multicollinearity Diagnostic Tests}}}

{synopt:{opt lmcl}} Multicollinearity Diagnostic Tests{p_end}
	- works if there are two independent variables or more in the model.
         {cmd:spregcs} computes OLS Multicollinearity Diagnostic Tests:

 1- VIF: variance inflation factors for independent variables
 2- Eigenvalues (Eigenval)
 3- Condition Index (C_Index)
 4- Condition Number (C_Number)
 5- R2 between each independent variable with other independent variables (R2_xi,X)

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

{p2colreset}{...}
{marker 20}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:spregcs} saves the following results in {cmd:e()}:

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

{col 4}{cmd:e(lmihj)}{col 20}Hansen Over Identification J Test for run(gmm)
{col 4}{cmd:e(lmihjp)}{col 20}Hansen Over Identification J Test P-Value
{col 4}{cmd:e(dfgmm)}{col 20}Hansen Over Identification DF

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

{err:*** Linear vs Log-Linear Functional Form Tests:}
{col 4}{cmd:e(r2lin)}{col 20}Linear R2
{col 4}{cmd:e(r2log)}{col 20}Log-Log R2
{col 4}{cmd:e(llflin)}{col 20}LLF - Linear
{col 4}{cmd:e(llflog)}{col 20}LLF - Log-Log
{col 4}{cmd:e(r2lina)}{col 20}Antilog R2 Linear  vs Log-Log: R2Lin
{col 4}{cmd:e(r2loga)}{col 20}Antilog R2 Log-Log vs Linear: R2log
{col 4}{cmd:e(boxcox)}{col 20}Box-Cox Test
{col 4}{cmd:e(boxcoxp)}{col 20}Box-Cox Test P-Value
{col 4}{cmd:e(bmlin)}{col 20}Bera-McAleer BM Test - Linear ModeL
{col 4}{cmd:e(bmlinp)}{col 20}Bera-McAleer BM Test - Linear ModeL P-Value
{col 4}{cmd:e(bmlog)}{col 20}Bera-McAleer BM Test - Log-Log ModeL
{col 4}{cmd:e(bmlogp)}{col 20}Bera-McAleer BM Test - Log-Log ModeL P-Value
{col 4}{cmd:e(dmlin)}{col 20}Davidson-Mackinnon PE Test - Linear ModeL
{col 4}{cmd:e(dmlinp)}{col 20}Davidson-Mackinnon PE Test - Linear ModeL P-Value
{col 4}{cmd:e(dmlog)}{col 20}Davidson-Mackinnon PE Test - Log-Log ModeL
{col 4}{cmd:e(dmlogp)}{col 20}Davidson-Mackinnon PE Test - Log-Log ModeL P-Value

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
{col 4}{cmd:e(first)}{col 20}First-stage regression results

Functions      
{col 4}{cmd:e(sample)}{col 20}marks estimation sample

{marker 21}{bf:{err:{dlgtab:References}}}

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

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA.}.

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

{p 4 8 2}Hays, Jude C., Aya Kachi & Robert J. Franzese, Jr (2010)
{cmd: "A Spatial Model Incorporating Dynamic, Endogenous Network Interdependence: A Political Science Application",}
{it:Statistical Methodology 7(3)}; 406-428.

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

{p 4 8 2}Theil, Henri (1971)
{cmd: "Principles of Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}White, Halbert (1980)
{cmd: "A Heteroskedasticity-Consistent Covariance Matrix Estimator and a Direct Test for Heteroskedasticity",}
{it:Econometrica, 48}; 817-838.

{p2colreset}{...}
{marker 22}{bf:{err:{dlgtab:Examples}}}

{bf:Note 1:} you can use: {helpb spweight}, {helpb spweightcs}, {helpb spweightxt} to create Spatial Weight Matrix.
{bf:Note 2:} Remember, your spatial weight matrix must be:
    *** {bf:{err:1-Cross Section Dimention  2- Square Matrix 3- Symmetric Matrix}}
{bf:Note 3:} You can use the dialog box for {dialog spregcs}.
{hline}

{stata clear all}

{stata sysuse spregcs.dta, clear}

 {stata spregcs y x1 x2 , model(ols) run(ols)}
 {stata spregcs y x1 x2 , model(ols) run(ols) dn lmsp wmfile(SPWcs)}

 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sar) mfx(lin)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) stand tests}
{hline}

{bf:{err:* (1) MLE Spatial Lag Model (SAR):}}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sar) tests}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sar) mfx(lin)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sar) mfx(log) tolog}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sar) predict(Yh) resid(Ue)}
 {stata spregcs ys x1 x2, wmfile(SPWcs) model(sar) tobit ll(0)}
 {stata spregcs ys x1 x2, wmfile(SPWcs) model(sar) tobit ll(3)}
{hline}

{bf:{err:* (2) MLE Spatial Error Model (SEM):}}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sem) mfx(lin)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sem) mfx(log) tolog}
 {stata spregcs ys x1 x2, wmfile(SPWcs) model(sem) tobit ll(0)}
{hline}

{bf:{err:* (3) MLE Spatial Durbin Model (SDM):}}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sdm) mfx(lin)}
 {stata spregcs ys x1 x2, wmfile(SPWcs) model(sdm) tobit ll(0)}
 {stata spregcs y x1    , wmfile(SPWcs) model(sdm) mfx(lin) aux(x2)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sdm) mfx(log) tolog}
{hline}

{bf:{err:* (4) MLE Spatial AutoCorrelation Model (SAC):}}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) spar(rho)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sac) mfx(log) spar(rho) tolog}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) spar(lam)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sac) mfx(log) spar(lam) tolog}
 {stata spregcs ys x1 x2, wmfile(SPWcs) model(sac) tobit ll(0)}
{hline}

{bf:{err:* (5) Spatial Exponential Regression Model}}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sar) dist(exp)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sem) dist(exp)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sdm) dist(exp)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sac) dist(exp)}
{hline}

{bf:{err:* (6) Spatial Weibull Regression Model}}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sar) dist(weib)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sem) dist(weib)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sdm) dist(weib)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sac) dist(weib)}
{hline}

{bf:{err:* (7) (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression}}
*** {bf:YOU MUST HAVE DIFFERENT Weighted Matrixes Files:}
{bf:{bf:*      (m-STAR) Lag Model}}

{bf:* (7-1) *** rum mstar in 1st nwmat}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstar) dist(norm)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstar) dist(exp)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstar) dist(weib)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstar) mhet(x1 x2)}

 {stata spregcs ys x1 x2, wmfile(SPWmcs1) nwmat(1) model(mstar) tobit ll(0)}

{bf:* (7-2) *** Import 1     Weight Matrix,   and rum mstar in 2nd nwmat}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstar) dist(norm)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstar) dist(exp)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstar) dist(weib)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstar) mhet(x1 x2)}

 {stata spregcs ys x1 x2, wmfile(SPWmcs2) nwmat(2) model(mstar) tobit ll(0)}

{bf:* (7-3) *** Import 1,2   Weight Matrixes, and rum mstar in 3rd nwmat}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstar) dist(norm)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstar) dist(exp)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstar) dist(weib)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstar) mhet(x1)}

 {stata spregcs ys x1 x2, wmfile(SPWmcs3) nwmat(3) model(mstar) tobit ll(0)}

{bf:* (7-4) *** Import 1,2,3 Weight Matrixes, and rum mstar in 4th nwmat}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstar) dist(norm)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstar) dist(exp)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstar) dist(weib)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstar) mhet(x1)}

 {stata spregcs ys x1 x2, wmfile(SPWmcs4) nwmat(4) model(mstar) tobit ll(0)}
{hline}

{bf:{err:* (8) (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression}}
*** {bf:YOU MUST HAVE DIFFERENT Weighted Matrixes Files:}
{bf:{bf:*       (m-STAR) Durbin Model}}

{bf:* (8-1) *** rum mstar in 1st nwmat}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstard) dist(norm)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstard) dist(exp)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstard) dist(weib)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstard) mhet(x1 x2)}

 {stata spregcs ys x1 x2, wmfile(SPWmcs1) nwmat(1) model(mstard) tobit ll(0)}

{bf:* (8-2) *** Import 1     Weight Matrix,   and rum mstar in 2nd nwmat}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstard) dist(norm)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstard) dist(exp)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstard) dist(weib)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstard) mhet(x1 x2)}

 {stata spregcs ys x1 x2, wmfile(SPWmcs2) nwmat(2) model(mstard) tobit ll(0)}

{bf:* (8-3) *** Import 1,2   Weight Matrixes, and rum mstar in 3rd nwmat}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstard) dist(norm)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstard) dist(exp)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstard) dist(weib)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstard) mhet(x1)}

 {stata spregcs ys x1 x2, wmfile(SPWmcs3) nwmat(3) model(mstard) tobit ll(0)}

{bf:* (8-4) *** Import 1,2,3 Weight Matrixes, and rum mstar in 4th nwmat}
 {stata spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstard) dist(norm)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstard) dist(exp)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstard) dist(weib)}
 {stata spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstard) mhet(x1)}

 {stata spregcs ys x1 x2, wmfile(SPWmcs4) nwmat(4) model(mstard) tobit ll(0)}
{hline}

{bf:{err:* (9) Weighted MLE Spatial Models:}}

{bf:* (9-1) Weighted MLE Spatial Lag Model (SAR):}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sar) wvar(x1)}

{bf:* (9-2) Weighted MLE Spatial Error Model (SEM):}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sem) wvar(x1)}

{bf:* (9-3) Weighted MLE Spatial Durbin Model (SDM):}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sdm) wvar(x1)}

{bf:* (9-4) Weighted MLE Spatial AutoCorrelation Model (SAC):}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sac) wvar(x1)}

{bf:* (9-5) Weighted (m-STAR) Lag Model}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(mstar) nw(1) wvar(x1)}

{bf:* (9-6) Weighted (m-STAR) Durbin Model}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(mstard) nw(1) wvar(x1)}
{hline}

{bf:{err:* (10) Spatial Tobit} - Truncated Dependent Variable (ys)}
 {stata spregcs ys x1 x2 , wmfile(SPWcs) model(sar)}
 {stata spregcs ys x1 x2 , wmfile(SPWcs) model(sem)}
 {stata spregcs ys x1 x2 , wmfile(SPWcs) model(sdm)}
 {stata spregcs ys x1 x2 , wmfile(SPWcs) model(sac)}
 {stata spregcs ys x1 x2 , wmfile(SPWcs) model(lag) run(tobit)}
 {stata spregcs ys x1 x2 , wmfile(SPWcs) model(durbin) run(tobit)}
{hline}

{bf:{err:* (11) Spatial Multiplicative Heteroscedasticity}}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sar) mhet(x1 x2)}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sdm) mhet(x1 x2)}
{hline}

{bf:{err:* (12) Spatial IV Tobit (IVTOBIT)}}
{stata spregcs ys x1 x2 , wmfile(SPWcs) model(ivtobit) endog(y2) inst(x3 x4)}
{stata spregcs ys x1 x2 , wmfile(SPWcs) model(ivtobit) order(1) lmiden}
{stata spregcs ys x1 x2 , wmfile(SPWcs) model(ivtobit) order(2) lmiden}
{stata spregcs ys x1 x2 , wmfile(SPWcs) model(ivtobit) order(3) lmiden}
{stata spregcs ys x1 x2 , wmfile(SPWcs) model(ivtobit) order(4) lmiden}
{hline}

{bf:{err:* (13) MLE -Spatial Lag/Autoregressive Error (SARARML)}}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(sararml) mfx(lin) spar(rho)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(sararml) mfx(lin) spar(lam)}
{hline}

{bf:{err:* (14) Generalized Spatial Lag/Autoregressive Error GS2SLS (SARARGS)}}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(sarargs) mfx(lin) spar(rho)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(sarargs) mfx(lin) spar(lam)}
{hline}

{bf:{err:* (15) Generalized Spatial Lag/Autoregressive Error IV-GS2SLS (SARARIV)}}

{stata spregcs y x1 x2 , wmfile(SPWcs) model(sarariv) endog(y2) spar(rho) mfx(lin) inst(x3 x4)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(sarariv) endog(y2) spar(rho) mfx(lin) lmiden}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(sarariv) endog(y2) spar(lam) mfx(lin) lmiden}
{hline}

{bf:{err:* (16) Spatial Autoregressive Generalized Method of Moments (SPGMM)}}
 {stata spregcs y  x1 x2 , wmfile(SPWcs) model(spgmm) mfx(lin)}
 {stata spregcs y  x1 x2 , wmfile(SPWcs) model(spgmm) ridge(orr) kr(0.5)}
 {stata spregcs y  x1 x2 , wmfile(SPWcs) model(spgmm) ridge(grr1) weight(x) wvar(x1)}

{hline}

{bf:{err:* (17) Tobit Spatial Autoregressive Generalized Method of Moments (SPGMM)}}
 {stata spregcs ys x1 x2 , wmfile(SPWcs) model(spgmm) tobit ll(0)}
 {stata spregcs ys x1 x2 , wmfile(SPWcs) model(spgmm) tobit ll(0) ridge(grr1)}
 {stata spregcs ys x1 x2 , wmfile(SPWcs) model(spgmm) tobit ll(0) ridge(orr) kr(0.5)}
 {stata spregcs ys x1 x2 , wmfile(SPWcs) model(spgmm) tobit ll(0) ridge(grr1) weight(x) wvar(x1)}
{hline}

{bf:{err:* (18) Generalized Spatial 2SLS Models}}
{bf:* (18-1) Generalized Spatial 2SLS - AR(1) (GS2SLS)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) endog(y2) inst(x3 x4)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) ridge(grr1)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) ridge(orr) kr(0.5)}
{stata spregcs ys x1 x2, wmfile(SPWcs) model(gs2sls) run(2sls) order(1) tobit ll(0)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) order(1) lmiden}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(melo)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(liml)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(kclass) kc(0.5)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(fuller) kf(0.5)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(white)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(white) weights(x) wvar(x1)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(bart)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(dan)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(nwest)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(parzen)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(quad)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(tent)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(trunc)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(tukeym)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(tukeyn)}
{bf:* (18-2) Generalized Spatial 2SLS - AR(2) (GS2SLS)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) order(2)}
{bf:* (18-3) Generalized Spatial 2SLS - AR(3) (GS2SLS)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) order(3)}
{bf:* (18-4) Generalized Spatial 2SLS - AR(4) (GS2SLS)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) order(4)}
{hline}

{bf:{err:* (19) Generalized Spatial Autoregressive 2SLS (GS2SLSAR)}}
{bf:* (19-1) Generalized Spatial Autoregressive 2SLS - AR(1) (GS2SLSAR)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) endog(y2) inst(x3 x4)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) ridge(grr1)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) ridge(orr) kr(0.5)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) order(1) lmi haus}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(liml) order(1) lmi haus}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(melo) order(1) lmi haus}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(gmm) hetcov(white) lmi haus}
{bf:* (19-2) Generalized Spatial Autoregressive 2SLS - AR(2) (GS2SLSAR)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) order(2)}
{bf:* (19-3) Generalized Spatial Autoregressive 2SLS - AR(3) (GS2SLSAR)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) order(3)}
{bf:* (19-4) Generalized Spatial Autoregressive 2SLS - AR(4) (GS2SLSAR)}
{stata spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) order(4)}
{hline}

{bf:{err:* (20) Generalized Spatial 3SLS - (G32SLS)}}
* Y1 = Y2 X1 X2
* Y2 = Y1 X3 X4
{bf:* (20-1) Generalized Spatial 3SLS - AR(1) (GS3SLS)}
{stata spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) order(1)}
{bf:* (20-2) Generalized Spatial 3SLS - AR(2) (GS3SLS)}
{stata spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) order(2)}
{bf:* (20-3) Generalized Spatial 3SLS - AR(3) (GS3SLS)}
{stata spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) order(3)}
{bf:* (20-4) Generalized Spatial 3SLS - AR(4) (GS3SLS)}
{stata spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) order(4)}
{hline}

{bf:{err:* (21) Generalized Spatial Autoregressive 3SLS - (GS3SLSAR)}}
{bf:* (21-1) Generalized Spatial Autoregressive 3SLS - AR(1) (GS3SLSAR)}
{stata spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1)}
{stata spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(1)}
{bf:* (21-2) Generalized Spatial Autoregressive 3SLS - AR(2) (GS3SLSAR)}
{stata spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(2)}
{bf:* (21-3) Generalized Spatial Autoregressive 3SLS - AR(3) (GS3SLSAR)}
{stata spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(3)}
{bf:* (21-4) Generalized Spatial Autoregressive 3SLS - AR(4) (GS3SLSAR)}
{stata spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(4)}
{hline}

{bf:{err:* (22) Geographically Weighted Regressions (GWR)}}
* ols   {stata spregcs y x1 x2 , wmfile(SPWcs) model(gwr) run(ols)}
* sfa   {stata spregcs y x1 x2 , wmfile(SPWcs) model(gwr) run(sfa)}
* sfa   {stata spregcs y x1 x2 , wmfile(SPWcs) model(gwr) run(sfa) cost}
* tobit {stata spregcs ys x1 x2, wmfile(SPWcs) model(gwr) run(tobit)}
{hline}

{bf:{err:* (23) Non Spatial Regression Models}}
{bf:* Ordinary Least Squares (OLS) Regression:}
* ols      {stata spregcs y x1 x2 , wmfile(SPWcs) model(ols) run(ols)}
{bf:* Frontier Regression}
* sfa {stata spregcs y x1 x2 , wmfile(SPWcs) model(ols) run(sfa)}
* sfa {stata spregcs y x1 x2 , wmfile(SPWcs) model(ols) run(sfa) cost}
{bf:* Tobit Regression}
* tobit  {stata spregcs ys x1 x2 , wmfile(SPWcs) model(ols) run(tobit)}
{hline}

{bf:{err:* (24) Spatial Lag Regression Models (LAG)}}
* ols   {stata spregcs y x1 x2 , wmfile(SPWcs) model(lag) run(ols)}
* sfa   {stata spregcs y x1 x2 , wmfile(SPWcs) model(lag) run(sfa)}
* sfa   {stata spregcs y x1 x2 , wmfile(SPWcs) model(lag) run(sfa) cost}
* tobit {stata spregcs ys x1 x2, wmfile(SPWcs) model(lag) run(tobit)}
{hline}

{bf:{err:* (25) Spatial Durbin Regression Models (DURBIN)}}
* ols   {stata spregcs y x1 x2 , wmfile(SPWcs) model(durbin) run(ols)}
* sfa   {stata spregcs y x1 x2 , wmfile(SPWcs) model(durbin) run(sfa)}
* sfa   {stata spregcs y x1 x2 , wmfile(SPWcs) model(durbin) run(sfa) cost}
* tobit {stata spregcs ys x1 x2, wmfile(SPWcs) model(durbin) run(tobit)}
{hline}

{bf:{err:* (26) Restrected Spatial Regression Models}}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sar) rest(1) mfx(lin) tests}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(sdm) rest(1) mfx(lin) tests}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(mstar) rest(1) mfx(lin) tests}
 {stata spregcs y x1 x2 , wmfile(SPWcs) model(mstard) rest(1) mfx(lin) tests}
{hline}

{bf:{err:* (17) Spatial Autoregressive Generalized Method of Moments (SPGMM)} (Cont.)}
 This example is taken from Prucha data about:
 Generalized Moments Estimator for the Autoregressive Parameter in a Spatial Model  
 More details can be found in:
 {browse "http://econweb.umd.edu/~prucha/Research_Prog1.htm"}
 Results of {bf:model({err:{it:spgmm}})} is identical to:
 {browse "http://econweb.umd.edu/~prucha/STATPROG/OLS/PROGRAM1.log"}

	{stata clear all}
	{stata sysuse spregcs1.dta , clear}
	{stata spregcs y x1 , wmfile(SPWcs1) model(spgmm)}
{hline}

{bf:{err:* (19) Generalized Spatial Autoregressive 2SLS (GS2SLSAR)} (Cont.)}
 This example is taken from Prucha data about:
 Generalized Spatial Two-Stage Least Squares Procedures for Estimating
 a Spatial Autoregressive Model with Autoregressive Disturbances
 More details can be found in:
 {browse "http://econweb.umd.edu/~prucha/Research_Prog2.htm"}
 Results of {bf:model({err:{it:gs2slsar}})} with order(2) is identical to:
 {browse "http://econweb.umd.edu/~prucha/STATPROG/2SLS/PROGRAM2.log"}

	{stata clear all}
	{stata sysuse spregcs2.dta , clear}
	{stata spregcs y x1 , wmfile(SPWcs1) model(gs2slsar) run(2sls) order(2)}
{hline}

{bf:{err:* (21) Generalized Spatial Autoregressive 3SLS (GS3SLSAR)} (Cont.)}
 This example is taken from Prucha data about:
 Estimation of Simultaneous Systems of Spatially Interrelated Cross Sectional Equations
 More details can be found in:
 {browse "http://econweb.umd.edu/~prucha/Research_Prog4.htm"}
 Results of {bf:model({err:{it:gs3slsar}})} with order(2) is identical to:
 {browse "http://econweb.umd.edu/~prucha/STATPROG/SIMEQU/PROGRAM4.log"}

	{stata clear all}
	{stata sysuse spregcs3.dta , clear}
	{stata spregcs y1 x1 , var2(y2 x2) wmfile(SPWcs1) model(gs3slsar) order(2)}
{hline}

{p2colreset}{...}
{marker 23}{bf:{err:{dlgtab:Acknowledgments}}}

  I would like to thank the authors of the following Stata modules:

   - David Drukker, and Ingmar Prucha for writing {helpb sppack}.

{p2colreset}{...}
{marker 24}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:SPREGCS Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2016)}{p_end}
{p 1 10 1}{cmd:SPREGCS: "Stata Module Econometric Toolkit to Estimate Spatial Cross Section Regression Models"}{p_end}


{title:Online Help:}

{bf:{err:*** Spatial Econometrics Regression Models:}}

--------------------------------------------------------------------------------
{bf:{err:*** (1) Spatial Panel Data Regression Models:}}
{helpb spregxt}{col 14}Spatial Panel Regression Models: {cmd:Econometric Toolkit}
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
{helpb spregcs}{col 14}Spatial Cross Section Regression Models: {cmd:Econometric Toolkit}
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

