{smcl}
{hline}
{cmd:help: {helpb spregxt}}{space 50} {cmd:dialog:} {bf:{dialog spregxt}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:spregxt: Spatial Panel Econometric Regression Models: Stata Module Toolkit}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb spregxt##01:Syntax}{p_end}
{p 5}{helpb spregxt##02:Description}{p_end}
{p 5}{helpb spregxt##03:Options}{p_end}
{p 5}{helpb spregxt##04:Model Options}{p_end}
{p 5}{helpb spregxt##05:Run Options}{p_end}
{p 5}{helpb spregxt##06:Ridge Options}{p_end}
{p 5}{helpb spregxt##07:Weight Options}{p_end}
{p 5}{helpb spregxt##08:Weighted Variable Type Options}{p_end}
{p 5}{helpb spregxt##09:Other Options}{p_end}
{p 5}{helpb spregxt##10:Spatial Panel Aautocorrelation Tests}{p_end}
{p 5}{helpb spregxt##11:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb spregxt##12:Autocorrelation Tests}{p_end}
{p 5}{helpb spregxt##13:Heteroscedasticity Tests}{p_end}
{p 5}{helpb spregxt##14:Non Normality Tests}{p_end}
{p 5}{helpb spregxt##15:Error Component Tests}{p_end}
{p 5}{helpb spregxt##16:Unit Roots Tests}{p_end}
{p 5}{helpb spregxt##17:Hausman Fixed/Random Effects & Specification Panel/IV-Panel Tests}{p_end}
{p 5}{helpb spregxt##18:Identification Restrictions LM Tests}{p_end}
{p 5}{helpb spregxt##19:REgression Specification Error Tests (RESET)}{p_end}
{p 5}{helpb spregxt##20:Linear vs Log-Linear Functional Form Tests}{p_end}
{p 5}{helpb spregxt##21:Multicollinearity Diagnostic Tests}{p_end}
{p 5}{helpb spregxt##22:Saved Results}{p_end}
{p 5}{helpb spregxt##23:References}{p_end}

{p 1}*** {helpb spregxt##24:Examples}{p_end}

{p 5}{helpb spregxt##25:Acknowledgments}{p_end}
{p 5}{helpb spregxt##26:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt spregxt} {depvar} {indepvars} {weight} , {bf:{err:nc(#)}} {p_end} 
{p 3 5 6} 
{err: [} {opt wmf:ile(weight_file)} {opt m:odel(sar|sem|sdm|sac|gwr|mstar|mstard|spgmm|gs2sls|gs2slsar|ols|sarxt|sdmxt)}{p_end} 
{p 5 5 6}
{opt run(ols|xtabond|xtam|xtbe|xtbem|xtdhp|xtdpd|xtdpdsys|xtfe|xtfem|xtfm|xtfrontier|)}{p_end}
       {opt (xtgls|xthh|xtkmhet1|xtkmhet2|xtkmhomo|xtmg|xtmle|xtmln|xtmlh|xtbn|xtpa|)}
       {opt (xtparks|xtpcse|xtrc|xtre|xtrem|xtregar|xtsa|xtmlem|xttobit|xtwem|xtwh)}

{p 5 5 6} 
{opt weights(yh|yh2|abse|e2|le2|x|xi|x2|xi2)} {opt wv:ar(varname)} {opt rid:ge(orr|grr1|grr2|grr3)} {opt kr(#)}{p_end} 
{p 5 5 6} 
{opt lmsp:ac} {opt lma:uto} {opt lmh:et} {opt lmf:orm} {opt lmn:orm} {opt lmec} {opt lmcl} {opt lmu:nit} {opt lmi:den} {opt haus:man} {opt reset} {opt diag} {opt test:s}{p_end} 
{p 5 5 6} 
{opt stand inv inv2 dn} {opt dist(norm|exp|weib)} {opt pmfx} {opt mfx(lin, log)} {opt spar(rho, lam)} {opt aux(varlist)}{p_end} 
{p 5 5 6} 
{opt mhet(varlist)} {opt nw:mat(#)} {opt ord:er(#)} {opt gmm(#)} {opt inr:ho(real 0)} {opt inl:ambda(real 0)} {opt nocons:tant}{p_end} 
{p 5 5 6} 
{opt pred:ict(new_var)} {opt res:id(new_var)} {opt inst(vars)} {opt diff(vars)} {opt endog(vars)} {opt pre(vars)}{p_end} 
{p 5 5 6} 
{opt dgmmiv(varlist)} {opt corr(name)} {opt panels(name)} {opt rhot:ype(name)} {opt iter(#)} {opt tech(name)} {opt ll(real 0)}{p_end} 
{p 5 5 6} 
{opt be fe re coll cost te ti tvd ec2sls igls} {opt het:only} {opt ind:ep} {opt zero} {opt dumcs(prefix)} {opt dumts(prefix)}{p_end} 
{p 5 5 6} 
{opt dlag(#)} {opt nosa tobit tolog} {opt nolog} {opt rob:ust} {opt twos:tep} {opt l:evel(#)} {opt li:st}{p_end} 
{p 5 5 6} 
{opth vce(vcetype)} {helpb maximize} {it:other maximization options} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

 {cmd:spregxt} is a complete Stata module toolkit package
 for Spatial Panel Econometric Regression Models estimation
 Many types of spatial autocorrelations were taken under consedration, i.e.,
 (SAR - SEM - SDM - SAC - SPGMM - GS2SLS - GS2SLSAR) Regressions.

 {cmd:spregxt} can estimate the following models:
   1- Autocorrelated (serial correlation) Regression Models.
   2- Heteroscedastic Regression Models in disturbance term.
   3- Non Normal Regression Models in disturbance term.
   4- Multicollinearity Regression Models in independent variables.

In fact {cmd:spregxt} estimates many Spatial & Non Spatial Models, even OLS regression:

 - {cmd:spregxt varlist , nc(#) model(ols) run(ols)}
   without choosing: wmfile( )
   {cmd:spregxt} results are identical OLS as {helpb regress}

 - {cmd:spregxt varlist , nc(#) model(ols) run(xtbe, xtfe, xtre, xtmle, xtpa, xtgls, ...)}
   without choosing: wmfile( )
   {cmd:spregxt} results are identical Panel as {helpb xtreg} and more XT commands.

 - ALL Diagnostic tests also are valid in the case of all models.

 {cmd:spregxt} estimates Continuous and Truncated Dependent Variables models {cmd:tobit}.

{p 2 2 2} {bf:model({err:{it:sar, sem, sdm, sac, mstar,mstard, spgmm}})} deals with data either continuous or truncated dependent variable. If {depvar} has missing values or lower limits,
so in this case {bf:model({err:{it:sar, sem, sdm, sac, spgmm}})} will fit spatial panel model via {helpb xttobit} model,
and thus {cmd:spregxt} can resolve the problem of missing values that exist in many kinds of data. Otherwise, in the case of continuous data, the normal estimation will be used.{p_end}

{bf:{err:*** Important Notes:}}
{cmd:spregxt} generates some variables names with prefix:
{cmd:w1x_ , w2x_ , w3x_ , w4x_ , w1y_ , w2y_ , mstar_ , spat_}
{cmd:So, you must avoid to include variables names with thes prefixes}

{p 2 4 2}{cmd:spregxt} can generate:{p_end}
    {cmd:- Binary / Standardized Weight Matrix.}
    {cmd:- Inverse  / Inverse Squared Standardized Weight Matrix.}
    {cmd:- Binary / Standardized / Inverse Eigenvalues Variable.}
    {cmd:- Spatial lagged variables up to 4th order.}

{p 2 4 2} {cmd:spregxt} predicted values in {bf:model({err:{it:sar, sdm, sac}})} models are obtained from conditional expectation expression.{p_end}

{pmore2}{bf:Yh = E(y|x) = inv(I-Rho*W) * X*Beta}

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{p 5 4 2} - DF=N-K for OLS model , and DF=N-K-nc otherwise.{p_end}

{p 5 5 5}Buse(1973) R2 in {bf:model({err:{it:gs2sls, gs2slsar}})} may be negative, to avoid negative R2, you can increase number on instrumental variables by choosing order more than 1 {cmd:order(2, 3, 4)}{p_end}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Options}}}

{col 3}* {cmd: {opt nc(#)}{col 20} Number of Cross Sections Units}
{col 3} {err:Time series observations must be Balanced in each Cross Section}

{col 3}{opt wmf:ile(weight_file)}{col 20} Open CROSS SECTION weight matrix file.
{col 20}{cmd:spregxt} will convert automatically spatial cross section weight matrix
{col 20}to spatial PANEL weight matrix.

	Spatial Weight Matrix file must be:
	 1- [SxS] Cross Sections units Dimentions, and not Panel dimentions
	 2- Square Matrix
	 3- Symmetric Matrix (Optional) 

{col 3}Spatial Panel Weight Matrix has two types: Standardized and binary weight matrix.

{col 3}{opt stand}{col 20}Use Standardized Panel Weight Matrix, (each row sum equals 1)
{col 20}Default is Binary spatial panel weight matrix which each element is 0 or 1

{col 3}{opt inv}{col 20}Use Inverse Standardized Weight Matrix (1/W)

{col 3}{opt inv2}{col 20}Use Inverse Squared Standardized Weight Matrix (1/W^2)

{col 3}{opt be}  Between Effects {col 30}(BE) {cmd:model(gs2sls, gs2slsar), run(xthdp)}
{col 3}{opt fe}  Fixed-Effects {col 30}(FE) {cmd:model(gs2sls, gs2slsar), run(xtregar, xthdp)}
{col 3}{opt re}  GLS-Random-Effects {col 30}(RE) {cmd:model(gs2sls, gs2slsar), run(xthdp)}
{synoptset 3 tabbed}{...}
{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Model Options}}}

{synopt :{opt m:odel(sar, sem, sdm, sac, mstar,mstard, spgmm, gs2sls, gs2slsar, ols, sarxt, sdmxt)}}{p_end} 
{col 5} 1- {bf:model({err:{it:sar}})}      MLE Spatial Panel Lag Model (SAR)

{col 5} 2- {bf:model({err:{it:sdm}})}      MLE Spatial Panel Durbin Model (SDM)

{col 5} 3- {bf:model({err:{it:sem}})}      MLE Spatial Panel Error Model (SEM)

{col 5} 4- {bf:model({err:{it:sac}})}      MLE Spatial Panel Lag / Error Model (SAC) "Spatial AutoCorrelation"

{col 5} 5- {bf:model({err:{it:mstar}})}    Multiparametric Spatio Temporal AutoRegressive Regression Model
{p 20 20 2}mSTAR Lag Model{p_end}

{col 5} 6- {bf:model({err:{it:mstard}})}   Multiparametric Spatio Temporal AutoRegressive Regression Model
{p 20 20 2}mSTAR Durbin Model{p_end}

{p 2 2 2}{bf:model({err:{it:mstar, mstard}})} are used with more than Weight Matrix: (Border, Language, Currency, Trade...){p_end}

{col 5} 7- {bf:model({err:{it:spgmm}})}    Spatial Panel Autoregressive Generalized Method of Moments Model
{p 25 25 2}When panel data model with error components are both spatially and time-wise correlated.
Generalized Method of Moments (GMM) that suggested in Kelejian-Prucha (1999), and Kapoor-Kelejian-Prucha (2007) is used in the estimation of {bf:model({err:{it:spgmm}})}{p_end}

{col 5} 8- {bf:model({err:{it:spgmm}})}    Tobit Spatial Panel Autoregressive GMM {bf:with option({err:{it:tobit}})}

{col 5} 9- {bf:model({err:{it:gs2sls}})}   Generalized Spatial Panel 2SLS

{col 5}10- {bf:model({err:{it:gs2slsar}})} Generalized Spatial Panel Autoregressive 2SLS
{p 25 25 2}Since no softwares available till now to estimate generalized spatial panel autoregressive 2SLS models, I designed {cmd:gs2slsar} as a modification of Kapoor-Kelejian-Prucha (2007),
but here I let the estimations deal with Panel 2SLS models, with original constant term.{p_end}

{col 5}11- {bf:model({err:{it:gwr}})}      Geographically Weighted Regressions (GWR)

{col 5}12- {bf:model({err:{it:ols}})}      Linear Panel Models (Non Spatial)

{col 5}13- {bf:model({err:{it:sarxt}})}    Linear Spatial Panel Lag Models (SAR)

{col 5}14- {bf:model({err:{it:sdmxt}})}    Linear Spatial Panel Durbin Models (SDM)

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Run Options}}}

{synopt :{opt run( )} is used with Spatial: {bf:model({err:{it:ols, sarxt, sdmxt}})}}{p_end}

 {bf:1- run(ols)}{col 20}[{helpb regress}] Ordinary Least Squares (OLS)
 {bf:2- run(xtbe)}{col 20}[{helpb xtreg} , be] Between-Effects Panel Regression
 {bf:3- run(xtbem)}{col 20}[{bf:{err:NEW}}] Between-Effects Panel Regression
 {bf:4- run(xtfe)}{col 20}[{helpb xtreg} , fe] Fixed-Effects Panel Regression
 {bf:5- run(xtfem)}{col 20}[{bf:{err:NEW}}] Fixed-Effects Panel Regression
 {bf:6- run(xtpa)}{col 20}[{helpb xtreg} , pa] Population Averaged-Effects Panel Regression

 {bf:7- run(xtmle)}{col 20}[{helpb xtreg} , mle] MLE Random-Effects Panel Regression
 {bf:8- run(xtam)}{col 20}[{bf:{err:NEW}}] Amemiya Random-Effects Panel Regression
 {bf:9- run(xtbn)}{col 20}[{bf:{err:NEW}}] Balestra-Nerlove Random-Effects Panel Regression
{bf:10- run(xtfm)}{col 20}[{bf:{err:NEW}}] Fama-MacBeth Panel Regression
{bf:11- run(xthh)}{col 20}[{bf:{err:NEW}}] Hildreth-Houck Random Coefficients Panel Regression
{bf:12- run(xtrc)}{col 20}[{helpb xtrc}] Swamy Random Coefficients Panel Regression
{bf:13- run(xtre)}{col 20}[{helpb xtreg} , re] GLS Random-Effects Panel Regression
{bf:14- run(xtrem)}{col 20}[{bf:{err:NEW}}] Fuller-Battese GLS Random-Effects Panel Regression
{bf:15- run(xtsa)}{col 20}[{bf:{err:NEW}}] Swamy-Arora Random-Effects Panel Regression
{bf:16- run(xtmlem)}{col 20}[{bf:{err:NEW}}] Trevor Breusch MLE Random-Effects Panel Regression
{bf:17- run(xtwem)}{col 20}[{bf:{err:NEW}}] Within-Effects Panel Regression
{bf:18- run(xtwh)}{col 20}[{bf:{err:NEW}}] Wallace-Hussain Random-Effects Panel Regression

{bf:19- run(xtgls)}{col 20}[{helpb xtgls}] Autocorrelation & Heteroskedasticity GLS Panel Regression
{bf:20- run(xtkmhomo)}{col 20}[{helpb xtgls}] Kmenta Homoscedastic GLS AR(1) Panel Regression
{col 26}{cmd:* with Options: panels(iid) corr(psar1)}
{bf:21- run(xtkmhet1)}{col 20}[{helpb xtgls}] Kmenta Heteroscedastic GLS - different AR(1) in each Panel
{col 26}{cmd:* with Options: panels(het) corr(psar1)}
{bf:22- run(xtkmhet2)}{col 20}[{helpb xtgls}] Kmenta Heteroscedastic GLS - SAME/Common AR(1) in all Panels
{col 26}{cmd:* with Options: panels(het) corr(ar1)}
{bf:23- run(xtparks)}{col 20}[{helpb xtgls}] Parks Full Heteroscedastic Cross-Section GLS AR(1) Panel Regression
{col 26}{cmd:* with Options: panels(corr) corr(psar1)}

{bf:24- run(xtmg)}{col 20}[{helpb xtmg}] Heterogeneous Slopes Time Series Panel Regression 
{p 20 20 2}{it:Requires (xtmg) module} {bf:{stata ssc install xtmg}}

{bf:25- run(xtpcse)}{col 20}[{helpb xtpcse}] Corrected Standard Error Panel Regression
{bf:26- run(xtregar)}{col 20}[{helpb xtregar}] AR(1) Panel Regression

{bf:27- run(xtabond)}{col 20}[{helpb xtabond}] Arellano-Bond Linear Dynamic Panel Regression
{bf:28- run(xtdhp)}{col 20}[{bf:{err:NEW}}] Han-Philips (2010) Linear Dynamic Panel Regression
{bf:29- run(xtdpd)}{col 20}[{helpb xtdpd}] Arellano-Bond (1991) Linear Dynamic Panel Regression
{bf:30- run(xtdpdsys)}{col 20}[{helpb xtdpdsys}] Arellano-Bover/Blundell-Bond (1995, 1998)
{col 31}System Linear Dynamic Panel Regression

{bf:31- run(xtfrontier)}{col 20}[{helpb xtfrontier}] Stochastic Frontier Panel Regression

{bf:32- run(xttobit)}{col 20}[{helpb xttobit}] Tobit Random-Effects Panel Regression

{bf:33- run(xtmln)}{col 20}[{bf:{err:NEW}}] MLE Random-Effects Panel Regression
{col 26}{cmd:* Normal Model}
{bf:34- run(xtmlh)}{col 20}[{bf:{err:NEW}}] MLE Random-Effects Panel Regression
{col 26}{cmd:* Multiplicative Heteroscedasticity Normal Model}

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Ridge Options}}}

{p 3 6 2} {opt kr(#)} Ridge k value, must be in the range (0 < k < 1).{p_end}

{p 3 6 2}IF {bf:kr(0)} in {opt ridge(orr, grr1, grr2, grr3)}, the model will be normal panel regression.{p_end}

{col 3}{bf:ridge({err:{it:orr}})} : Ordinary Ridge Regression    [Judge,et al(1988,p.878) eq.21.4.2].
{col 3}{bf:ridge({err:{it:grr1}})}: Generalized Ridge Regression [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:ridge({err:{it:grr2}})}: Iterative Generalized Ridge  [Judge,et al(1988,p.881) eq.21.4.12].
{col 3}{bf:ridge({err:{it:grr3}})}: Adaptive Generalized Ridge   [Strawderman(1978)].

	{bf:ridge( )} {cmd:works only with:} 
	{bf:model({err:{it:ols, sarxt, sdmxt, spgmm}})}
	{bf:run({err:{it:ols, xtam, xtbem, xtbn, xtfem, xtrem, xtsa, xtmlem, xtwem, xtwh}})}

{p 2 4 2}{cmd:spregxt} estimates Ridge regression as a multicollinearity remediation method.{p_end}
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
{marker 07}{bf:{err:{dlgtab:Weight Options}}}

{synoptset 16}{...}
{synopt:{bf:wvar({err:{it:varname}})}}Weighted Variable Name{p_end}

{col 10}{cmd:spregxt} not like official Stata command {helpb xtreg} in weight option,
{col 10}{cmd:spregxt} can use large types of weighted regression options with:
{col 10}1- Fixed-Effects   {cmd:run(xtfem)}
{col 10}2- Between-Effects {cmd:run(xtbem)}
{col 10}2- Within-Effects  {cmd:run(xtwem)}
{col 10}3- Random-Effects  {cmd:run(xtrem, xtmlem, xtbn, xtam, xtwh, ... etc)}
{col 10}{bf:wvar( )} {cmd:must be combined with:} {bf:weights(x, xi, x2, xi2)}"

{p2colreset}{...}
{marker 08}{bf:{err:{dlgtab:Weighted Variable Type Options}}}
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
{marker 09}{bf:{err:{dlgtab:Other Options}}}
{synoptset 9}{...}

{col 3}{bf:dlag({err:{it:#}})}{col 20}Location of Lagged Dependent Variable; default is (1)

{col 3}{opt zero}{col 20}convert missing values observations to Zero

{col 3}{opt li:st}{col 20}Add Spatial Lagged Variables to Data File

{col 3}{opt ord:er(1,2,3,4)}{col 20}Order of lagged independent variables up to maximum 4th order.
{col 15}{bf:order(2,3,4)} works only with: {bf:model({err:{it:gs2sls, gs2slsar}})}. Default is 1

{col 3}{opt nw:mat(1,2,3,4)}{col 20}number of Rho's matrixes to be used with: {bf:model({err:{it:mstar, mstard}})}}

{synopt :{opt gmm(1,2,3)} GMM Estimators for {bf:model({err:{it:spgmm}})}}{p_end} 
{col 8}{bf:1- Initial GMM Model}
{col 8}{bf:2- Partial Weighted GMM Model}
{col 8}{bf:3- Full Weighted GMM Model}

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{col 3}{opt cost}{col 20}Fit Cost Frontier instead of Production Function {cmd:run({helpb xtfrontier})}

{col 3}{opt te}{col 20}List Confidence Intervals for Technical Efficiency Estimates {cmd:run({helpb xtfrontier})}

{col 3}{opt ti}{col 20}use Time-Invariant model {cmd:run({helpb xtfrontier})}

{col 3}{opt tvd}{col 20}use Time-Varying Decay model {cmd:run({helpb xtfrontier})}

{col 3}{opt ec2sls}{col 20}Baltagi EC2SLS Random-Effects (RE) Model {bf:model({err:{it:gs2sls, gs2slsar}})}

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation
{col 20}not valid in {bf:model({err:{it:sem, sac}})}
{col 20}{cmd:spregxt} not like official Stata command {helpb xtreg} in constant term option,
{col 20}{cmd:spregxt} can exclude constant term from models with:
{col 20}1- Fixed-Effects   {cmd:xtfem}
{col 20}3- Random-Effects  {cmd:xtrem}
{col 20}2- Between-Effects {cmd:xtbem}
{col 20}{cmd:weights} option also can be used here.

{col 3}{opt haus:man}{col 20}Hausman Fixed Effects & Specification Tests

{col 3}{opt het:only}{col 20}assume panel-level heteroskedastic errors {cmd:run({helpb xtpcse})}

{col 3}{opt igls}{col 20}iterated GLS instead of two-step GLS {cmd:run({helpb xtgls})}

{col 3}{opt ind:ep}{col 20}assume independent errors across panels {cmd:run({helpb xtpcse})}

{col 3}{opt test:s}{col 20}display ALL lma, lmh, lmn, lmsp, lmec, lmu, lmi, diag, reset, haus tests

{col 3}{opt dn}{col 20}Use (N) divisor instead of (N-K) for Degrees of Freedom (DF)

{col 3}{opt nosa}{col 20}Baltagi-Chang variance components instead of Swamy-Arora {bf:model({err:{it:gs2sls, gs2slsar}})}

{col 3}{opt two:step}{col 20}two-step estimate {cmd:run({helpb xtregar}, {helpb xtdpd})}

{col 3}{opt inrho(#)}{col 20}Set initial value for rho; default is 0

{col 3}{opt inlam:bda(#)}{col 20}Set initial value for lambda; default is 0

{col 3}{opt nolog}{col 20}suppress iteration of the log likelihood

{col 3}{opt tobit}{col 20}Estimate {bf:model({err:{it:spgmm}})} via Tobit Spatial Panel GMM 

{col 3}{opt ll(#)}{col 20}value of minimum left-censoring dependent variable with:
{col 20}{bf:model({err:{it:sar, sem, sdm, sac, spgmm}})}, and {bf:run({err:{it:xttobit}})}; default is 0

{col 3}{opt pmfx}{col 20}Print Marginal Effects P-Values.

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
       - {opt spar(rho)} is default for {bf:model({err:{it:sar, sac, sdm, mstar, mstard}})}
       - {opt spar(rho)} cannot be used with {bf:model({err:{it:sem}})}

       - {opt spar(lam)} is default for {bf:model({err:{it:sem}})}
       - {opt spar(lam)} cannot be used with {bf:model({err:{it:sar, sdm, mstar, mstard}})}
       - {opt spar(lam)} is an alternative with {bf:model({err:{it:sac}})}
       
       - {bf:model({err:{it:sac}})} work with the two types {opt spar(rho, lam)}
       - {bf:model({err:{it:sarxt, gs2sls, gs2slsar}})} not work with the two types {opt spar(rho, lam)}

{synopt :{bf:dist({err:{it:norm, exp, weib}})} Distribution of error term:}{p_end}
{p 12 2 2}1- {bf:dist({err:{it:norm}})} Normal distribution; default.{p_end}
{p 12 2 2}2- {bf:dist({err:{it:exp}})}  Exponential distribution.{p_end}
{p 12 2 2}3- {bf:dist({err:{it:weib}})} Weibull distribution.{p_end}

{p 10 10 1}{cmd:dist} option is used to remedy non normality problem, when the error term has non normality distribution.{p_end}
{p 10 10 1} {opt dist(norm, exp, weib)} is used with {bf:model({err:{it:sar, sem, sdm, sac, mstar, mstard}})}.{p_end}

{p 10 10 1}{bf:dist({err:{it:norm}})} is the default distribution.{p_end}

{p 2 10 10}{opt aux(varlist)}}add Auxiliary Variables into regression model without converting them to spatial lagged variables, or without {cmd:log} form, i.e., dummy variables.
This option dont include these auxiliary variables among spatial lagged variables, it is useful in {bf:model({err:{it:sdm, sdmxt, mstard}})}
to avoid lost degrees of freedom (DF). Using many dummy variables must be used
with caution to avoid multicollinearity problem, that causes singular matrix,
and lead to abort estimation. {opt aux( )} not works with {bf:model({err:{it:sem, sac}})}.{p_end}

{p 2 10 10}{opt mhet(varlist)} Set variable(s) that will be included in {cmd:Spatial Panel Multiplicative Heteroscedasticity} model, this option is used with
{bf:model({err:{it:sar, sdm, mstar, mstard}})}, to remidy Heteroscedasticity.
option {weight}, can be used in the case of Heteroscedasticity in errors.{p_end}

{col 20}{cmd:Panel Multiplicative Heteroscedasticity} can be used also with with
{col 20}{bf:model({err:{it:ols, sarxt, sdmxt}})} with combining {bf:run({err:{it:xtmlh}})}
{col 20}to remidy Heteroscedasticity, {col 20}option {weight}, can not be used here.

{col 3}{cmdab:p:anels:(}{cmdab:i:id)}{col 20}Homoscedastic Error with No Cross-Sections Correlation
{col 21}{cmd:run({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}
{col 3}{cmdab:p:anels:(}{cmdab:h:et)}{col 20}Heteroscedastic Error with No Cross-Sections Correlation
{col 21}{cmd:run({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}
{col 3}{cmdab:p:anels:(}{cmdab:c:orr)}{col 20}Heteroscedastic Error with Cross-Sections Correlation
{col 21}{cmd:run({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}

{col 3}{cmdab:c:orr:(}{cmdab:i:ndep)}{col 20}No Autocorrelation within Panels
{col 21}{cmd:run({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}
{col 3}{cmdab:c:orr:(}{cmdab:ar1)}{col 20}Common AR(1) Autocorrelation within Panels
{col 21}{cmd:run({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}
{col 3}{cmdab:c:orr:(}{cmdab:psar1)}{col 20}AR(1) Autocorrelation within Panels, and in each Panel
{col 21}{cmd:run({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}
{col 3}{cmdab:c:orr:(}{cmdab:c:orr)}{col 20}Autocorrelation within Panels
{col 21}{cmd:run({helpb xtgls} ,{helpb xtpcse}, {helpb xtregar}, {cmd:xtmle, xtpa})}

{phang}
{opt rhot:ype(rhomethod)} types of Rho estimators {cmd:run({helpb xtpcse}, {helpb xtregar})}:{p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:dw)}{space 7} Durbin-Watson: rho_dw = 1 - dw/2{p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:reg:ress)}{space 2} rho_reg = B from residual regression e_t = B*e_(t-1){p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:freg)}{space 5} rho_leads = B from residual regression e_t = B*e_(t+1){p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:tsc:orr)}{space 3} time series autocorrelation: rho_tscorr = e'e_(t-1)/e'e{p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:th:eil)}{space 4} Theil = rho_tscorr * (N-k)/N{p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:nag:ar)}{space 4} rho_nagar = (rho_dw * N*N+k*k)/(N*N-k*k){p_end}
{p 5 26 2}{cmd:rhotype(}{cmdab:one:step)}{space 2} rho_onestep = (n/m_c)*rho_tscorr, where n is obs. and m_c is number of consecutive pairs of residuals

{col 3}{opt pred:ict(new_variable)}{col 30}Predicted values variable

{col 3}{opt res:id(new_variable)}{col 30}Residuals values variable
{col 15} computed as Ue=Y-Yh ; that is known as combined residual: [Ue = U_i + E_it]
{col 15} in xtreg models overall error component is computed as: [E_it]
{col 15} see: {help xtreg postestimation##predict}

{col 3}{opt dgmmiv(varlist)}{col 27}GMM Instruments for Differenced Equation {cmd:run({helpb xtdpd})}

{col 3}{opt diff(varlist)}{col 27}Already Differenced Exogenous Variables {cmd:run({helpb xtabond})}

{col 3}{opt endog(varlist)}{col 27}Endogenous Variables {cmd:run({helpb xtabond}, {helpb xtdpdsys})}
{col 27}{opt endog(vars)} allows to add other additional Endogenous Variables
{col 27}in {bf:model({err:{it:gs2sls, gs2slsar}})}

{col 3}{opt inst(varlist)}{col 27}add Additional Instrumental Variables {cmd:run({helpb xtabond})}
{col 27}and with {bf:model({err:{it:gs2sls, gs2slsar}})}
{col 27}Dependent Variable Lag length is lag(1) for {cmd:run({helpb xtabond}, {helpb xtdpdsys})}
{col 27}if the same variables are included in {opt aux(varlist)},
{col 27}so Instrumental Variables will be Exogenous variables in RHS side

{cmd:spregxt command:}
{stata spregxt y1 x1 x2, nc(7) wmfile(SPWxt) model(gs2sls) endog(y2) inst(x3 x4)}

{cmd:is identical to}
{stata xtivreg y1 x1 x2 (w1y_y1 y2 = x1 x2 x3 x4 w1x_x1 w1x_x2)}

***{cmd:Both additional Endogenous and Instrumental Variables in:}
   {bf:model({err:{it:gs2sls, gs2slsar}})}
   {cmd:will be added without converting them to spatial lagged variables}

{col 3}{opt pre(varlist)}{col 27}Predetermined Variables {cmd:run({helpb xtabond}, {helpb xtdpdsys})}

{col 3}{opt dumcs(new_varlist)}{col 27}Cross Section Dummy Variables Prefix

{col 3}{opt dumts(new_varlist)}{col 27}Time Series Dummy Variables Prefix

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
{marker 10}{bf:{err:{dlgtab:Spatial Panel Aautocorrelation Tests}}}

{synopt :{opt lmsp:ac} Spatial Panel Aautocorrelation Tests:}{p_end}
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
{marker 11}{bf:{err:{dlgtab:Panel Model Selection Diagnostic Criteria}}}

{synopt :{opt diag} Spatial Panel Model Selection Diagnostic Criteria:}{p_end}
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
{marker 12}{bf:{err:{dlgtab:Panel Serial Autocorrelation Tests}}}

{synopt :{opt lma:uto} Spatial Panel Serial Autocorrelation Tests:}{p_end}
	* Ho: No AR(1) Panel AutoCorrelation - Ha: AR(1) Panel AutoCorrelation
	- Durbin  h Panel Test (Lag DepVar)
	- Harvey LM Panel Test (Lag DepVar)
	- Panel Rho Value
	- Durbin-Watson Panel Test
	- Von Neumann Ratio Panel Test
	- Box-Pierce LM Panel Test
	- Z Panel Test
	- Durbin m Panel Test (drop 1 cs obs)
	- Durbin m Panel Test (keep 1 cs obs)
	- Breusch-Godfrey LM Test (drop 1 cs obs)
	- Breusch-Godfrey LM Test (keep 1 cs obs)
	- Breusch-Pagan-Godfrey Z (keep 1 obs)
	- Breusch-Pagan-Godfrey Z (drop 1 cs obs)
	- Breusch-Pagan-Godfrey Z (keep 1 cs obs)
	- Baltagi LM Panel Test
	- Baltagi  Z Panel Test
	- Wooldridge  F Panel Test
	- Wooldridge LM Panel Test

{p2colreset}{...}
{marker 13}{bf:{err:{dlgtab:Panel Heteroscedasticity Tests}}}

{synopt :{opt lmh:et} Spatial Panel Heteroscedasticity Tests:}{p_end}
	* Ho: Panel Homoscedasticity - Ha: Panel Heteroscedasticity
	- Engle LM ARCH Test AR(1) E2 =E2_1
	- Hall-Pagan LM Test:  E2 = Yh
	- Hall-Pagan LM Test:  E2 = Yh2
	- Hall-Pagan LM Test:  E2 = LYh2
	- Harvey LM Test:    LogE2 = X
	- Wald Test:         LogE2 = X
	- Glejser LM Test:    |E| = X
	- Machado-Santos-Silva LM Test: Ev= Yh Yh2
	- Machado-Santos-Silva LM Test: Ev= X
	- Breusch-Godfrey Test: E = E_1 X
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

	*** Groupwise Panel Heteroscedasticity Tests
	* Ho: Panel Homoscedasticity - Ha: Panel Groupwise Heteroscedasticity
		- Lagrange Multiplier LM Test
		- Likelihood Ratio LR Test
		- Wald Test

	*** Panel Tobit Model Heteroscedasticity LM Tests
 		- Separate LM Tests - Ho: Homoscedasticity
		- Joint LM Test     - Ho: Homoscedasticity

{p2colreset}{...}
{marker 14}{bf:{err:{dlgtab:Panel Non Normality Tests}}}

{synopt :{opt lmn:orm} Spatial Panel Non Normality Tests:}{p_end}
	* Ho: Panel Normality - Ha: Panel Non Normality
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
	*** Tobit Panel Non Normality Tests
		*** LM Test - Ho: No Skewness
		*** LM test - Ho: No Kurtosis
		*** LM Test - Ho: Normality (No Kurtosis, No Skewness)
		    - Pagan-Vella LM Test
		    - Chesher-Irish LM Test

{p2colreset}{...}
{marker 15}{bf:{err:{dlgtab:Panel Error Component Tests}}}

{synopt :{opt lmec} Spatial Panel Error Component Tests:}{p_end}
	* Panel Random Effects Tests
	  Ho: Fixed Effects Model (FEM) - Ha: Random Effects Model (REM)
	  Ho: No AR(1) Autocorrelation  - Ha: AR(1) Autocorrelation
	- Breusch-Pagan  LM Test - Two Side
	- Breusch-Pagan ALM Test - Two Side
	- Sosa-Escudero-Yoon  LM Test - One Side
	- Sosa-Escudero-Yoon ALM Test - One Side
	- Baltagi-Li  LM Autocorrelation Test
	- Baltagi-Li ALM Autocorrelation Test
	- Baltagi-Li LM AR(1) Joint Test

	* Panel Diagonal Covariance Matrix Test
	  Ho: OLS  -  Ha: Panel
	- Breusch-Pagan LM Test

	* Contemporaneous Correlations Across Cross Sctions Test
	  {cmd: Ho: No Contemporaneous Correlations (Independence) - (OLS)}
              Sig12 = Sig13 = Sig23 = ... = 0. 
	  {cmd: Ha:    Contemporaneous Correlations (Dedependence) - (Panel)}
              at least one Covariance is nonzero.

{p 7 10 7}- Panel estimation models assume:{p_end}
{p 7 10 7}1- Independence of the errors in each cross section or no correlations between different periods in the same cross section.{p_end}
{p 7 10 7}2- no correlations between the errors for any of two cross sections between two different periods, this is called {cmd:"Intertemporal Correlation"}.{p_end}
{p 7 10 7}3- correlations may be exist between different two cross sections, but at the same period, and this is called {cmd:"Contemporaneous Correlation"}.{p_end}
{p 7 10 7}4- Panel models can be applied when there is correlations between different two cross sections at the same period.{p_end}
{p 7 10 7}5- If {cmd:"Contemporaneous Correlation"} does not exist, ordinary least squares (OLS) can be applied, the results are fully efficient.{p_end}

{p 7 10 7} Breusch-Pagan LM can test whether contemporaneous diagonal covariance matrix is 0. (Independence of the Errors), or correlated if at least one covariance is nonzero.{p_end}
	  Using {bf:model({err:{it:xtgls, xtkmhomo, xtkmhet1, xtkmhet2, xtparks, xtpcse}})}
	   are solutions for (Contemporaneous Correlation)
	- Breusch-Pagan Diagonal Covariance Matrix Panel LM Test
	- Breusch-Pagan Cross-Section Independence Panel LM Test
        Results of the two tests with [run(xtfe) lmec] are identical
	LM= Lagrange Multiplier ; ALM = Adjusted Lagrange Multiplier

{p2colreset}{...}
{marker 16}{bf:{err:{dlgtab:Panel Unit Roots Tests}}}

{synopt :{opt lmunit} Panel Unit Roots Tests:}{p_end}
	* Ho: All Panels are Stationary - Ha: Some Panels Have Unit Roots
	- Hadri Z Test (No Trend - No Robust)
	- Hadri Z Test (No Trend -    Robust)
	- Hadri Z Test (   Trend - No Robust)
	- Hadri Z Test (   Trend -    Robust)
	  Using {bf:run({err:{it:xtabond, xtdhp, xtdpd, xtdpdsys}})}
	  are solutions for (Non Stationary Models)

{p2colreset}{...}
{marker 17}{bf:{err:{dlgtab:Panel Hausman Fixed/Random Effects & Specification Panel/IV-Panel Tests}}}

{synopt :{opt hausman} Spatial Panel Hausman Fixed Effects & Specification Tests:}{p_end}
	* Ho: Random Effects Model (REM) - Ha: Fixed Effects Model (FEM)
	- Hausman Panel Model vs IV-Panel Model
	- Hausman Fixed Effects vs Random Effects

{p2colreset}{...}
{marker 18}{bf:{err:{dlgtab:Panel Identification Restrictions LM Tests}}}

{synopt :{opt lmiden} Spatial Panel Identification Restrictions LM Tests:}{p_end}
	- Y  = LHS Dependent Variable in Equation i
	- Yi = RHS Endogenous Variables in Equation i
	- Xi = RHS Included Exogenous Variables in   Equation i
	- Z  = Overall Exogenous Variables in the System
	- Sargan  LM Test
	- Basmann LM Test

{p2colreset}{...}
{marker 19}{bf:{err:{dlgtab:Panel REgression Specification Error Tests (RESET)}}}

{synopt :{opt reset} Spatial Panel REgression Specification Error Tests (RESET)}{p_end}
	* Ho: Panel Model is Specified - Ha: Panel Model is Misspecified
	- Ramsey RESET2 Test: Y= X Yh2
	- Ramsey RESET3 Test: Y= X Yh2 Yh3
	- Ramsey RESET4 Test: Y= X Yh2 Yh3 Yh4
	- DeBenedictis-Giles Specification ResetL Test
	- DeBenedictis-Giles Specification ResetS Test
	- White Functional Form Test: E2= X X2

{p2colreset}{...}
{marker 20}{bf:{err:{dlgtab:Panel Linear vs Log-Linear Functional Form Tests}}}

{synopt:{opt lmf:orm}}Spatial Panel Linear vs Log-Linear Functional Form Tests{p_end}
	- R-squared
 	- Log Likelihood Function (LLF)
 	- Antilog R2
 	- Box-Cox Test
 	- Bera-McAleer BM Test
 	- Davidson-Mackinnon PE Test

{p2colreset}{...}
{marker 21}{bf:{err:{dlgtab:Panel Multicollinearity Diagnostic Tests}}}

{synopt:{opt lmcl}}Spatial Panel Multicollinearity Diagnostic Tests{p_end}
	- works if there are two independent variables or more in the model.
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
{marker 22}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }Depending on the model estimated, {cmd:spregxt} saves the following results in {cmd:e()}:

Scalars

{err:*** Spatial Panel Aautocorrelation Tests:}
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

{err:*** Spatial Panel Model Selection Diagnostic Criteria:}

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

{err:*** Spatial Panel Serial Autocorrelation Tests:}
{col 4}{cmd:e(rho)}{col 20}Panel Rho Value
{col 4}{cmd:e(lmadw)}{col 20}Durbin-Watson Panel Test
{col 4}{cmd:e(lmavon)}{col 20}Von Neumann Ratio Panel Test
{col 4}{cmd:e(lmabp)}{col 20}Box-Pierce LM Panel Test
{col 4}{cmd:e(lmabpp)}{col 20}Box-Pierce LM Panel Test P-Value
{col 4}{cmd:e(lmaz)}{col 20}Z Panel Test
{col 4}{cmd:e(lmazp)}{col 20}Z Panel Test P-Value
{col 4}{cmd:e(lmadh)}{col 20}Durbin h Panel Test (Lag DepVar)
{col 4}{cmd:e(lmadhp)}{col 20}Durbin h Panel Test (Lag DepVar) P-Value
{col 4}{cmd:e(lmahh)}{col 20}Harvey LM Panel Test (Lag DepVar)
{col 4}{cmd:e(lmahhp)}{col 20}Harvey LM Panel Test (Lag DepVar) P-Value
{col 4}{cmd:e(lmadmd)}{col 20}Durbin m Panel Test (drop 1 cs obs)
{col 4}{cmd:e(lmadmdp)}{col 20}Durbin m Panel Test (drop 1 cs obs) P-Value
{col 4}{cmd:e(lmadmk)}{col 20}Durbin m Panel Test (keep 1 cs obs)
{col 4}{cmd:e(lmadmkp)}{col 20}Durbin m Panel Test (keep 1 cs obs) P-Value
{col 4}{cmd:e(lmabgd)}{col 20}Breusch-Godfrey LM Test (drop 1 cs obs)
{col 4}{cmd:e(lmabgdp)}{col 20}Breusch-Godfrey LM Test (drop 1 cs obs) P-Value
{col 4}{cmd:e(lmabgk)}{col 20}Breusch-Godfrey LM Test (keep 1 cs obs)
{col 4}{cmd:e(lmabgkp)}{col 20}Breusch-Godfrey LM Test (keep 1 cs obs) P-Value
{col 4}{cmd:e(lmabpgk)}{col 20}Breusch-Pagan-Godfrey Z Test (keep 1 obs)
{col 4}{cmd:e(lmabpgkp)}{col 20}Breusch-Pagan-Godfrey Z Test (keep 1 obs) P-Value
{col 4}{cmd:e(lmabpgd)}{col 20}Breusch-Pagan-Godfrey Z Test (drop 1 cs obs)
{col 4}{cmd:e(lmabpgdp)}{col 20}Breusch-Pagan-Godfrey Z Test (drop 1 cs obs) P-Value
{col 4}{cmd:e(lmabpgk1)}{col 20}Breusch-Godfrey LM Test (keep 1 obs)
{col 4}{cmd:e(lmabpgk1p)}{col 20}Breusch-Godfrey LM Test (keep 1 obs) P-Value
{col 4}{cmd:e(lmab1)}{col 20}Baltagi LM Panel Test
{col 4}{cmd:e(lmab1p)}{col 20}Baltagi LM Panel Test P-Value
{col 4}{cmd:e(lmab2)}{col 20}Baltagi Z Panel Test
{col 4}{cmd:e(lmab2p)}{col 20}Baltagi Z Panel Test P-Value
{col 4}{cmd:e(lmawold1)}{col 20}Wooldridge F Panel Test
{col 4}{cmd:e(lmawold1p)}{col 20}Wooldridge F Panel Test P-Value
{col 4}{cmd:e(lmawold2)}{col 20}Wooldridge LM Panel Test
{col 4}{cmd:e(lmawold2p)}{col 20}Wooldridge LM Panel Test P-Value

{err:*** Spatial Panel Heteroscedasticity Tests:}
{col 4}{cmd:e(lmharch)}{col 20}Engle LM ARCH Test AR(1)
{col 4}{cmd:e(lmharchp)}{col 20}Engle LM ARCH Test AR(1) P-Value
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
{col 4}{cmd:e(lmhbg)}{col 20}Breusch-Godfrey Test
{col 4}{cmd:e(lmhbgp)}{col 20}Breusch-Godfrey Test P-Value
{col 4}{cmd:e(lmhcw1)}{col 20}Cook-Weisberg LM Test E = Yh
{col 4}{cmd:e(lmhcw1p)}{col 20}Cook-Weisberg LM Test E = Y P-Valueh
{col 4}{cmd:e(lmhcw2)}{col 20}Cook-Weisberg LM Test E = X
{col 4}{cmd:e(lmhcw2p)}{col 20}Cook-Weisberg LM Test E = X P-Value

{err:*** Spatial Panel Groupwise Heteroscedasticity Tests:}
{col 4}{cmd:e(lmhglm)}{col 20}Lagrange Multiplier LM Test
{col 4}{cmd:e(lmhglmp)}{col 20}Lagrange Multiplier LM Test P-Value
{col 4}{cmd:e(lmhglr)}{col 20}Likelihood Ratio LR Test
{col 4}{cmd:e(lmhglrp)}{col 20}Likelihood Ratio LR Test P-Value
{col 4}{cmd:e(lmhgw)}{col 20}Wald Test
{col 4}{cmd:e(lmhgwp)}{col 20}Wald Test P-Value

{err:*** Spatial Panel Non Normality Tests:}
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

{err:*** Spatial Panel Error Component Tests:}
{col 4}{cmd:e(lmec1)}{col 20}Breusch-Pagan Random Effects Test  LM Test -Two Side
{col 4}{cmd:e(lmec1p)}{col 20}Breusch-Pagan Random Effects Test  LM Test -Two Side P-Value
{col 4}{cmd:e(lmec2)}{col 20}Breusch-Pagan Random Effects Test ALM Test -Two Side
{col 4}{cmd:e(lmec2p)}{col 20}Breusch-Pagan Random Effects Test ALM Test -Two Side P-Value
{col 4}{cmd:e(lmec3)}{col 20}Sosa-Escudero-Yoon Random Effects Test  LM Test -One Side
{col 4}{cmd:e(lmec3p)}{col 20}Sosa-Escudero-Yoon Random Effects Test  LM Test -One Side P-Value
{col 4}{cmd:e(lmec4)}{col 20}Sosa-Escudero-Yoon Random Effects Test ALM Test -One Side
{col 4}{cmd:e(lmec4p)}{col 20}Sosa-Escudero-Yoon Random Effects Test ALM Test -One Side P-Value
{col 4}{cmd:e(lmec5)}{col 20}Baltagi-Li Random Effects Test  LM Autocorrelation Test
{col 4}{cmd:e(lmec5p)}{col 20}Baltagi-Li Random Effects Test  LM Autocorrelation Test P-Value
{col 4}{cmd:e(lmec6)}{col 20}Baltagi-Li Random Effects Test ALM Autocorrelation Test
{col 4}{cmd:e(lmec6p)}{col 20}Baltagi-Li Random Effects Test ALM Autocorrelation Test P-Value
{col 4}{cmd:e(lmec7)}{col 20}Baltagi-Li Random Effects Test LM AR(1) Joint Test
{col 4}{cmd:e(lmec7p)}{col 20}Baltagi-Li Random Effects Test LM AR(1) Joint Test P-Value
{col 4}{cmd:e(lmec8)}{col 20}Breusch-Pagan Diagonal Covariance Matrix Test LM Test
{col 4}{cmd:e(lmec8p)}{col 20}Breusch-Pagan Diagonal Covariance Matrix Test LM Test P-Value
{col 4}{cmd:e(lmec9)}{col 20}Breusch-Pagan Cross-Section Independence LM Test
{col 4}{cmd:e(lmec9p)}{col 20}Breusch-Pagan Cross-Section Independence LM Test P-Value

{err:*** Spatial Panel Unit Roots Tests:}
{col 4}{cmd:e(lmu1)}{col 20}Hadri Z Test (No Trend - No Robust)
{col 4}{cmd:e(lmu1p)}{col 20}Hadri Z Test (No Trend - No Robust) P-Value
{col 4}{cmd:e(lmu2)}{col 20}Hadri Z Test (No Trend -    Robust)
{col 4}{cmd:e(lmu2p)}{col 20}Hadri Z Test (No Trend -    Robust) P-Value
{col 4}{cmd:e(lmu3)}{col 20}Hadri Z Test (   Trend - No Robust)
{col 4}{cmd:e(lmu3p)}{col 20}Hadri Z Test (   Trend - No Robust) P-Value
{col 4}{cmd:e(lmu4)}{col 20}Hadri Z Test (   Trend -    Robust)
{col 4}{cmd:e(lmu4p)}{col 20}Hadri Z Test (   Trend -    Robust) P-Value

{err:*** Panel Hausman Specification Panel/IV-Panel Tests:}
{col 4}{cmd:e(lmhs)}{col 20}Hausman Panel vs IV-Panel
{col 4}{cmd:e(lmhsp)}{col 20}Hausman Panel vs IV-Panel P-Value

{err:*** Panel Hausman Fixed/Random Effects Tests:}
{col 4}{cmd:e(lmhsfe)}{col 20}Hausman Fixed Effects vs Random Effects
{col 4}{cmd:e(lmhsfep)}{col 20}Hausman Fixed Effects vs Random Effects P-Value

{err:*** Spatial Panel Identification Restrictions LM Tests (gs2sls, gs2slsar):}
{col 4}{cmd:e(lmb)}{col 20}Basmann LM Test
{col 4}{cmd:e(lmbp)}{col 20}Basmann LM Test P-Value
{col 4}{cmd:e(lms)}{col 20}Sargan LM Test
{col 4}{cmd:e(lmsp)}{col 20}Sargan LM Test P-Value

{err:*** Spatial Panel REgression Specification Error Tests (RESET):}
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

{err:*** Spatial Panel Linear vs Log-Linear Functional Form Tests:}
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

Matrixes       
{col 4}{cmd:e(b)}{col 20}coefficient vector
{col 4}{cmd:e(V)}{col 20}variance-covariance matrix of the estimators

{marker 23}{bf:{err:{dlgtab:References}}}

{p 4 8 2} Amemiya, Takeshi (1971)
{cmd: "The Estimation of the Variances in a Variance-Components Model",}
{it:International Economic Review, Vol. 12, No. 1, Feb.}; 1-13.  

{p 4 8 2} Anderson, T.W. & C. Hsiao (1982)
{cmd: "Formulation and Estimation of Dynamic Models Using Panel Data",}
{it:Journal of Econometrics, 18}; 47–82.

{p 4 8 2}Anderson T.W. & Darling D.A. (1954)
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

{p 4 8 2}Anselin L., Le Gallo J. & Jayet H (2006)
{cmd: "Spatial Panel Econometrics"}
{it:In: Matyas L, Sevestre P. (eds) The Econometrics of Panel Data, Fundamentals and Recent Developments in Theory and Practice, 3rd edn. Kluwer, Dordrecht}; 901-969.

{p 4 8 2} Arellano, M. and S. Bond (1991)
{cmd: "Some Tests of Specification for Panel Data: Monte Carlo Evidence and an Application to Employment Equations"}
{it:The Review of Economic Studies 58}; 277-297.

{p 4 8 2} Arellano, M. and S. Bond (1998)
{cmd: "Dynamic Panel Data Estimation Using DPD98 for Gauss"}
{it:: A Guide for Users}.

{p 4 8 2} Arellano, M. and O. Bover (1995)
{cmd: "Another Look at the Instrumental Variable Estimation of Error-Components Models"}
{it:Journal of Econometrics 68}; 29-51.

{p 4 8 2} Balestra, Pietro (1973)
{cmd: "Best Quadratic Unbiased Estimators of the Variance-Covariance Matrix in Normal Regression",}
{it:Journal of Econometrics, 2}; 17–28.

{p 4 8 2}Balestra, Pietro & Marc Nerlove (1966)
{cmd: "Pooling Cross-Section and Time Series Data in the Estimation of a Dynamic Model: The Demand for Natural Gas",}
{it:Econometrica, Vol. 34, No. 3, July}; 585-612.

{p 4 8 2}Baltagi, B.H. (2006)
{cmd: "Random Effects and Spatial Autocorrelation with Equal Weights"}
{it:Econometric Theory 22(5)}; 973-984.

{p 4 8 2}Baltagi, B. H. & Q. Li (1995)
{cmd: "Testing AR (1) against MA (1) Disturbances in an Error Component Model"}
{it:Journal of Econometrics 68}; 133-151.

{p 4 8 2}Baltagi, B. H., & Q. Li. 1991
{cmd: "A Joint Test for Serial Correlation and Random Individual Effects"}
{it:Statistics and Probability Letters 11}; 277-280.

{p 4 8 2}Baltagi, B. H., Song S.H., Jung BC, & Koh W (2007)
{cmd: "Testing for Serial Correlation, Spatial Autocorrelation and Random Effects Using Panel Data"}
{it:Journal of Econometrics 140(1)}; 5-51.

{p 4 8 2}Basmann, R.L. (1960)
{cmd: "On Finite Sample Distributions of Generalized Classical Linear Identifiability Test Statistics"},
{it:Journal of the American Statisical Association, 55, Issue 292, DecemberA}; 650-59.

{p 4 8 2}Bera, A., W. Sosa-Escudero, & M. Yoon (2001)
{cmd: "Tests for the Error Component Model in the Presence of Local Misspecification"}
{it:Journal of Econometrics 101}; 1-23.

{p 4 8 2}Box, George & Pierce D. (1970)
{cmd: "Distribution of Residual Autocorrelations in Autoregressive Integrated Moving Average Time Series Models",}
{it:Journal of the American Statisical Association, 65}; 1509-1526.

{p 4 8 2}Breusch, Trevor (1978)
{cmd: "Testing for Autocorrelation in Dynamic Linear Models",}
{it:Aust. Econ. Papers, Vol. 17}; 334-355.

{p 4 8 2} Breusch, Trevor (1987)
{cmd: "Maximum Likelihood Estimation of Random Effects Models",}
{it:Journal of Econometrics, 36}; 383–389.

{p 4 8 2}Breusch, Trevor & Adrian Pagan (1980)
{cmd: "The Lagrange Multiplier Test and its Applications to Model Specification in Econometrics",}
{it:Review of Economic Studies 47}; 239-253.

{p 4 8 2}Brundson,C. A. S. Fotheringham, & M. Charlton (1996)
{cmd:"Geographically Weighted Regression: A Method for Exploring Spatial Nonstationarity"}
{it:Geographical Analysis, Vol. 28}; 281-298.

{p 4 8 2}Buse, Adolf (1973)
{cmd:"Goodness of Fit in Generalized Least Squares Estimation"}
{it:American Statistician, Vol. 27(3)}; 106-108.

{p 4 8 2}Buse, Adolf (1979)
{cmd:"Goodness of Fit in the Seemingly Unrelated Regressions Model"}
{it:Journal of Econometrics, Vol. 10}; 109-113.

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

{p 4 8 2}DeBenedictis, L. F. & Giles D. E. A. (1998)
{cmd: "Diagnostic Testing in Econometrics: Variable Addition, RESET and Fourier Approximations",}
{it:In: A. Ullah  & D. E. A. Giles (Eds.), Handbook of Applied Economic Statistics. Marcel Dekker, New York}; 383-417.

{p 4 8 2}Durbin, James (1970a)
{cmd: "Testing for Serial Correlation in Least-Squares Regression When Some of the Regressors are Lagged Dependent Variables",}
{it:Econometrica, vol.38, no.3, May}; 410-421.

{p 4 8 2}Durbin, James (1970b)
{cmd: "An Alternative to the Bounds Test for Testing for Serial Correlation in Least Square Regression",}
{it:Econometrica, Vol. 38, No. 2, May}; 422-429.

{p 4 8 2}Elhorst, J. Paul (2003)
{cmd: "Specification and Estimation of Spatial Panel Data Models"}
{it:International Regional Science review 26, 3}; 244–268.

{p 4 8 2}Elhorst, J. Paul (2009)
{cmd: "Spatial Panel Data Models"}
{it:in Mandfred M. Fischer and Arthur Getis, eds., Handbook of Applied Spatial Analysis, Berlin: Springer}.

{p 4 8 2}Engle, Robert (1982)
{cmd: "Autoregressive Conditional Heteroscedasticity with Estimates of Variance of United Kingdom Inflation"}
{it:Econometrica, 50(4), July}; 987-1007.

{p 4 8 2}Fama, E. F., & J. D. MacBeth (1973)
{cmd:"Risk, Return, and Equilibrium: Empirical Tests"}
{it:Journal of Political Economy, Vol. 81, Issue 3}; 607-636.

{p 4 8 2} Fuller, W.A. & G.E. Battese (1974)
{cmd: "Estimation of Linear Models with Cross-Error Structure",}
{it:Journal of Econometrics, 2}; 67–78.

{p 4 8 2}Geary R.C. (1947)
{cmd: "Testing for Normality"} {it:Biometrika, Vol. 34}; 209-242.

{p 4 8 2}Geary R.C. (1970)
{cmd: "Relative Efficiency of Count of Sign Changes for Assessing Residuals Autoregression in Least Squares Regression"}
{it:Biometrika, Vol. 57}; 123-127.

{p 4 8 2}Godfrey, L. G. (1978)
{cmd: "Testing for Higher Order Serial Correlation in Regression Equations when the Regressors Include Lagged Dependent Variables",}
{it:Econometrica, Vol.46}; 1303-1310.

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

{p 4 8 2} Han, Chirok & Peter C.B. Phillips (2010)
{cmd: "GMM Estimation for Dynamic Panels with Fixed Effects and Strong at Unity"}
{it:Econometric Theory, 26}; 119–151.

{p 4 8 2}Harry H. Kelejian and Ingmar R. Prucha (1999)
{cmd: "A Generalized Moments Estimator for the Autoregressive Parameter in a Spatial Model,}
{it:International Economic Review, (40)}; 509-533.

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

{p 4 8 2} Maddala, G.S. (1971)
{cmd: "The Use of Variance Components Models in Pooling Cross Section and Time Series Data",}
{it:Econometrica, 39}; 341–358.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}.

{p 4 8 2} Maddala, G.S. & T. Mount (1973)
{cmd: "A Comparative Study of Alternative Estimators for Variance Components Models Used in Econometric Applications",}
{it:Journal of the American Statistical Association, 68}; 324–328.

{p 4 8 2}Mudit Kapoor, Harry H. Kelejian & Ingmar R. Prucha (2007)
{cmd: "Panel Data Models with Spatially Correlated Error Components",}
{it:Journal of Econometrics, 140}; 97-130.
{browse "http://econweb.umd.edu/~prucha/Papers/JE140(2007a).pdf"}

{p 4 8 2}Nerlove, Marc (1971)
{cmd: "A Note on Error Components Models",}
{it:Econometrica, Vol. 39, No. 2, March}; 383-396.

{p 4 8 2}Pagan, Adrian .R. & Hall, D. (1983)
{cmd: "Diagnostic Tests as Residual Analysis",}
{it:Econometric Reviews, Vol.2, No.2,}. 159-218.

{p 4 8 2}Parks, R. (1967)
{cmd: "Efficient Estimation of a System of Regression Equations when Disturbances are Both Serially and Contemporaneously Correlated",}
{it: Journal of the American Statisical Association, 62}; 500-509.

{p 4 8 2}Pearson, E. S., D'Agostino, R. B., & Bowman, K. O. (1977)
{cmd: "Tests for Departure from Normality: Comparison of Powers",}
{it:Biometrika, 64(2)}; 231-246.

{p 4 8 2}Ramsey, J. B. (1969)
{cmd: "Tests for Specification Errors in Classical Linear Least-Squares Regression Analysis",}
{it: Journal of the Royal Statistical Society, Series B 31}; 350-371.

{p 4 8 2}Sargan, J.D. (1958)
{cmd: "The Estimation of Economic Relationships Using Instrumental Variables",}
{it:Econometrica, vol.26}; 393-415.

{p 4 8 2}Sosa-Escudero, & Bera, A. (2008)
{cmd: "Tests for unbalanced error-components models under local misspecification"}
{it:The Stata Journal, 8(1)}; 68–78.

{p 4 8 2}Swamy, P.A.V.B. (1970)
{cmd: "Efficient Inference in a Random Coefficient Regression Model"}
{it:Econometrica 38}; 311-323.

{p 4 8 2} Swamy, P.A.V.B. & S.S. Arora (1972)
{cmd: "The Exact Finite Sample Properties of the Estimators of Coefficients in the Error Components Regression Models",}
{it:Econometrica, 40}; 261–275.

{p 4 8 2}Szroeter, J. (1978)
{cmd: "A Class of Parametric Tests for Heteroscedasticity in Linear Econometric Models",}
{it:Econometrica, 46}; 1311-28.

{p 4 8 2}Theil, Henri (1971)
{cmd: "Principles of Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Von, Neumann (1941)
{cmd: "Distribution of the Ratio of the Mean Square Successive Difference to the Variance",}
{it:Annals Math. Stat., Vol. 12}; 367-395.

{p 4 8 2} Wallace, T. & A. Hussain (1969)
{cmd: "The Use of Error Components Models in Combining Cross-Section and Time-Series Data",}
{it:}Econometrica, 37; 55–72.

{p 4 8 2}White, Halbert (1980)
{cmd: "A Heteroskedasticity-Consistent Covariance Matrix Estimator and a Direct Test for Heteroskedasticity",}
{it:Econometrica, 48}; 817-838.

{p 4 8 2}Wooldridge, Jeffrey M. (2002)
{cmd: "Econometric Analysis of Cross Section and Panel Data",}
{it:The MIT Press, Cambridge, Massachusetts, London, England}.

{p2colreset}{...}
{marker 24}{bf:{err:{dlgtab:Examples}}}

{bf:Note 1:} you can use: {helpb spweight}, {helpb spweightcs}, {helpb spweightxt} to create Spatial Weight Matrix.
{bf:Note 2:} Remember, your spatial weight matrix must be:
    *** {bf:{err:1-Cross Section Dimention  2- Square Matrix 3- Symmetric Matrix}}
{bf:Note 3:} You can use the dialog box for {dialog spregxt}.
{bf:Note 4:} xtset is included automatically in {cmd:spregxt} models.

{hline}

  {stata clear all}

  {stata sysuse spregxt.dta, clear}

  {stata db spregxt}

 {stata spregxt y x1 x2 , nc(7) model(ols) run(ols)}
 {stata spregxt y x1 x2 , nc(7) model(ols) run(xtrem)}
 {stata spregxt y x1 x2 , nc(7) model(ols) run(xtrem) ridge(grr1) weight(x) wvar(x1)}

 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) mfx(lin)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) mfx(lin) stand tests}
{hline}

{bf:{err:* (1) MLE Spatial Panel Lag Model (SAR):}}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) tests}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) tests mfx(lin) pmfx}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) mfx(log) pmfx tolog}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) predict(Yh) resid(Ue)}
 {stata spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sar) tobit ll(0)}
 {stata spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sar) tobit ll(3)}
{hline}

{bf:{err:* (2) MLE Spatial Panel Error Model (SEM):}}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sem) mfx(lin)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sem) mfx(log) tolog}
 {stata spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sem) tobit ll(0)}
{hline}

{bf:{err:* (3) MLE Spatial Panel Durbin Model (SDM):}}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) mfx(lin) pmfx}
 {stata spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sdm) tobit ll(0)}
 {stata spregxt y x1    , nc(7) wmfile(SPWxt) model(sdm) mfx(lin) aux(x2)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) mfx(log) pmfx tolog}

 {stata local dum "dcs1 dcs2 dcs3 dcs4"}
 {stata spregxt y x1 x2, nc(7) wmfile(SPWxt) model(sdm) aux(`dum')}
 {stata spregxt y x1 x2 dcs1-dcs5, nc(7) wmfile(SPWxt) model(sdm) noconst}
{hline}

{bf:{err:* (4) MLE Spatial Panel AutoCorrelation Model (SAC):}}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) mfx(lin) pmfx spar(rho)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) mfx(log) pmfx spar(rho) tolog}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) mfx(lin) pmfx spar(lam)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) mfx(log) pmfx spar(lam) tolog}
 {stata spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sac) tobit ll(0)}
{hline}

{bf:{err:* (5) Spatial Panel Autoregressive Generalized Method of Moments}}
 {stata spregxt y  x1 x2 , nc(7) wmfile(SPWxt) model(spgmm) mfx(lin)}
 {stata spregxt y  x1 x2 , nc(7) wmfile(SPWxt) model(spgmm) gmm(1)}
 {stata spregxt y  x1 x2 , nc(7) wmfile(SPWxt) model(spgmm) gmm(2)}
 {stata spregxt y  x1 x2 , nc(7) wmfile(SPWxt) model(spgmm) gmm(3)}
{hline}

{bf:{err:* (6) Tobit Spatial Panel Autoregressive Generalized Method of Moments}}
 {stata spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(spgmm) gmm(1) tobit ll(0)}
 {stata spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(spgmm) gmm(2) tobit ll(0)}
 {stata spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(spgmm) gmm(3) tobit ll(0)}
{hline}

{bf:{err:* (7) Generalized Spatial Panel 2SLS Models}}

 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2sls) endog(y2) inst(x3 x4)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2sls) order(1) lmi haus}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2sls) order(2) lmi haus}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2sls) order(3) lmi haus}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2sls) order(4) lmi haus}
{hline}

{bf:{err:* (8) Generalized Spatial Panel Autoregressive 2SLS Models}}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2slsar) endog(y2) inst(x3 x4)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2slsar) order(1) lmi haus}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2slsar) order(2) lmi haus}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2slsar) order(3) lmi haus}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2slsar) order(4) lmi haus}
{hline}

{bf:{err:* (9) (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression}}
*** {bf:YOU MUST HAVE DIFFERENT Weighted Matrixes Files:}
{bf:{bf:*      (m-STAR) Lag Model}}

{bf:* (9-1) *** rum mstar in 1st nwmat}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstar) mfx(lin) pmfx dist(norm)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstar) mfx(lin) pmfx dist(exp)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstar) mfx(lin) pmfx dist(weib)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstar) mfx(lin) pmfx mhet(x1 x2)}

 {stata spregxt ys x1 x2, nc(7) wmfile(SPWmxt1) nwmat(1) model(mstar) tobit ll(0)}

{bf:* (9-2) *** Import 1     Weight Matrix,   and rum mstar in 2nd nwmat}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstar) mfx(lin) pmfx dist(norm)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstar) mfx(lin) pmfx dist(exp)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstar) mfx(lin) pmfx dist(weib)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstar) mfx(lin) pmfx mhet(x1 x2)}

 {stata spregxt ys x1 x2, nc(7) wmfile(SPWmxt2) nwmat(2) model(mstar) tobit ll(0)}

{bf:* (9-3) *** Import 1,2   Weight Matrixes, and rum mstar in 3rd nwmat}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstar) mfx(lin) pmfx dist(norm)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstar) mfx(lin) pmfx dist(exp)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstar) mfx(lin) pmfx dist(weib)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstar) mfx(lin) pmfx mhet(x1 x2)}

 {stata spregxt ys x1 x2, nc(7) wmfile(SPWmxt3) nwmat(3) model(mstar) tobit ll(0)}

{bf:* (9-4) *** Import 1,2,3 Weight Matrixes, and rum mstar in 4th nwmat}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstar) mfx(lin) pmfx dist(norm)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstar) mfx(lin) pmfx dist(exp)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstar) mfx(lin) pmfx dist(weib)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstar) mfx(lin) pmfx mhet(x1 x2)}

 {stata spregxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) model(mstar) tobit ll(0)}
{hline}

{bf:{err:* (10) (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression}}
*** {bf:YOU MUST HAVE DIFFERENT Weighted Matrixes Files:}
{bf:{bf:*       (m-STAR) Durbin Model}}

{bf:* (10-1) *** rum mstar in 1st nwmat}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstard) mfx(lin) pmfx dist(norm)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstard) mfx(lin) pmfx dist(exp)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstard) mfx(lin) pmfx dist(weib)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstard) mfx(lin) pmfx mhet(x1 x2)}

 {stata spregxt ys x1 x2, nc(7) wmfile(SPWmxt1) nwmat(1) model(mstard) mfx(lin) pmfx tobit ll(0)}

{bf:* (10-2) *** Import 1     Weight Matrix,   and rum mstar in 2nd nwmat}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstard) mfx(lin) pmfx dist(norm)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstard) mfx(lin) pmfx dist(exp)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstard) mfx(lin) pmfx dist(weib)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstard) mfx(lin) pmfx mhet(x1 x2)}

 {stata spregxt ys x1 x2, nc(7) wmfile(SPWmxt2) nwmat(2) model(mstard) mfx(lin) pmfx tobit ll(0)}

{bf:* (10-3) *** Import 1,2   Weight Matrixes, and rum mstar in 3rd nwmat}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstard) mfx(lin) pmfx dist(norm)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstard) mfx(lin) pmfx dist(exp)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstard) mfx(lin) pmfx dist(weib)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstard) mfx(lin) pmfx mhet(x1 x2)}

 {stata spregxt ys x1 x2, nc(7) wmfile(SPWmxt3) nwmat(3) model(mstard) mfx(lin) pmfx tobit ll(0)}

{bf:* (10-4) *** Import 1,2,3 Weight Matrixes, and rum mstar in 4th nwmat}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstard) mfx(lin) pmfx dist(norm)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstard) mfx(lin) pmfx dist(exp)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstard) mfx(lin) pmfx dist(weib)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstard) mfx(lin) pmfx mhet(x1 x2)}

 {stata spregxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) model(mstard) mfx(lin) pmfx tobit ll(0)}
{hline}

{bf:{err:* (11) Weighted MLE Spatial Panel Models:}}

{bf:* (1) Weighted MLE Spatial Panel Lag Model (SAR):}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) mfx(lin) pmfx wvar(x1)}

{bf:* (2) Weighted MLE Spatial Panel Error Model (SEM):}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sem) wvar(x1)}

{bf:* (3) Weighted MLE Spatial Panel Durbin Model (SDM):}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) mfx(lin) pmfx wvar(x1)}

{bf:* (4) Weighted MLE Spatial Panel AutoCorrelation Model (SAC):}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) mfx(lin) pmfx wvar(x1)}

{bf:* (5) Weighted (m-STAR) Lag Model}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(mstar) mfx(lin) pmfx nw(1) wvar(x1)}

{bf:* (6) Weighted (m-STAR) Durbin Model}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(mstard) mfx(lin) pmfx nw(1) wvar(x1)}
{hline}

{bf:{err:* (12) Spatial Panel Tobit} - Truncated Dependent Variable (ys)}
 {stata spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sar) mfx(lin) pmfx}
 {stata spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sem) mfx(lin)}
 {stata spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sdm) mfx(lin) pmfx}
 {stata spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sac) mfx(lin) pmfx}
 {stata spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xttobit)}
 {stata spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xttobit)}
{hline}

{bf:{err:* (13) Spatial Panel Multiplicative Heteroscedasticity}}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) mhet(x1 x2)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) mhet(x1 x2)}
{hline}

{bf:{err:* (14) Spatial Panel Exponential Regression Model}}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) dist(exp)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sem) dist(exp)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) dist(exp)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) dist(exp)}
{hline}

{bf:{err:* (15) Spatial Panel Weibull Regression Model}}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) dist(weib)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sem) dist(weib)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) dist(weib)}
 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) dist(weib)}
{hline}

{bf:{err:* (16) Non Spatial Panel Regression Models}}

{bf:* Ordinary Least Squares (OLS) Regression:}
* ols      {stata spregxt y x1 x2 , nc(7) model(ols) run(ols)}
{bf:* Between-Effects Panel Regression:}
* xtbe     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtbe)}
{bf:* Between-Effects Panel Regression:}
* xtbem    {stata spregxt y x1 x2 , nc(7) model(ols) run(xtbem) ridge(grr1)}
{bf:* Fixed-Effects Panel Regression:}
* xtfe     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtfe)}
{bf:* Fixed-Effects Panel Regression:}
* xtfem    {stata spregxt y x1 x2 , nc(7) model(ols) run(xtfem) ridge(grr1)}
{bf:* Fama-MacBeth Panel Regression:}
* xtfm     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtfm)}
{bf:* Population Averaged Effects Panel Regression:}
* xtpa     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtpa)}
{bf:* Within-Effects Panel Regression:}
* xtwem    {stata spregxt y x1 x2 , nc(7) model(ols) run(xtwem)}
{bf:* Variance Components (Random-Effects) Panel Regression:}
{bf:* Random-Effects MLE Panel Regression:}
* xtmle    {stata spregxt y x1 x2 , nc(7) model(ols) run(xtmle)}
{bf:* Amemiya Variance Components Panel Regression:}
* xtam     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtam)}
{bf:* Balestra-Nerlove Variance Components Panel Regression:}
* xtbn     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtbn)}
{bf:* Hildreth-Houck Random Coefficients Panel Regression:}
* xthh     {stata spregxt y x1 x2 , nc(7) model(ols) run(xthh)}
{bf:* Swamy Random-Coefficients Panel Regression:}
* xtrc     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtrc)}
{bf:* Random-Effects GLS Panel Regression:}
* xtre     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtre)}
{bf:* Fuller-Battese GLS Random Effect Panel Regression:}
* xtrem    {stata spregxt y x1 x2 , nc(7) model(ols) run(xtrem) hausman ridge(grr1)}
{bf:* Swamy-Arora Variance Components Panel Regression:}
* xtsa     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtsa)}
{bf:* Trevor Breusch Random-Effects MLE Panel Regression:}
* xtmlem     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtmlem)}
{bf:* Wallace-Hussain Variance Components Panel Regression:}
* xtwh     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtwh)}
{bf:* Autocorrelation & Heteroskedasticity Generalized Least Squares Panel Regression:}
* xtgls    {stata spregxt y x1 x2 , nc(7) model(ols) run(xtgls)}
{bf:* Kmenta Homoscedastic Generalized Least Squares AR(1) Panel Regression:}
* xtkmhomo {stata spregxt y x1 x2 , nc(7) model(ols) run(xtkmhomo)}
{bf:* Kmenta Heteroscedastic GLS AR(1) different in each Panel:}
* xtkmhet1 {stata spregxt y x1 x2 , nc(7) model(ols) run(xtkmhet1)}
{bf:* Kmenta Heteroscedastic GLS AR(1) SAME/Common in all Panels:}
* xtkmhet2 {stata spregxt y x1 x2 , nc(7) model(ols) run(xtkmhet2)}
{bf:* Parks (FULL) Heteroscedastic Cross-Section GLS AR(1) Panel Regression:}
* xtparks  {stata spregxt y x1 x2 , nc(7) model(ols) run(xtparks)}
{bf:* Panel Time Series with Heterogeneous Slopes Regression:}
* xtmg     {stata spregxt y x1 x2 , nc(7) model(ols) run(xtmg)}
{bf:* Linear Panel-Corrected Standard Error (PCSE) Regression:}
* xtpcse   {stata spregxt y x1 x2 , nc(7) model(ols) run(xtpcse)}
{bf:* Linear Panel AR(1) Regression:}
* xtregar  {stata spregxt y x1 x2 , nc(7) model(ols) run(xtregar)}
{bf:* Linear Dynamic Panel Regression:}
 {stata local dum "dcs1 dcs2 dcs3 dcs4"}
{bf:* Arellano-Bond Linear Dynamic Panel Regression:}
* xtabond  {stata spregxt y x1 x2 , nc(7) model(ols) run(xtabond) inst(x1 x2)}
* xtabond  {stata spregxt y x1 x2 , nc(7) model(ols) run(xtabond) inst(x1 x2) lag(1) pre(x1 x2) diff(`dum')}
{bf:* Han-Philips (2010) Linear Dynamic Panel Regression:}}
* xtdhp    {stata spregxt y x1 x2 , nc(7) model(ols) run(xtdhp) re}
{bf:* Arellano-Bond (1991) Linear Dynamic Panel Regression:}
* xtdpd    {stata spregxt y x1 x2 , nc(7) model(ols) run(xtdpd) dgmmiv(x1 x2)}
{bf:* Arellano-Bover/Blundell-Bond (1995, 1998) System Linear Dynamic Panel Regression:}
* xtdpdsys {stata spregxt y x1 x2 , nc(7) model(ols) run(xtdpdsys) lag(1)}
{bf:* Frontier Panel Regression:}
* xtfrontier {stata spregxt y x1 x2 , nc(7) model(ols) run(xtfrontier) ti}
* xtfrontier {stata spregxt y x1 x2 , nc(7) model(ols) run(xtfrontier) tvd}
* xtfrontier {stata spregxt y x1 x2 , nc(7) model(ols) run(xtfrontier) ti cost}
{bf:* Tobit Panel Regression:}
* xttobit  {stata spregxt y x1 x2 , nc(7) model(ols) run(xttobit)}
{bf:* MLE Random-Effects Panel Regression - Normal Model:}
* xtmln    {stata spregxt y x1 x2 , nc(7) model(ols) run(xtmln)}
{bf:* MLE Random-Effects Multiplicative Heteroscedasticity Panel Regression:}
* xtmlh    {stata spregxt y x1 x2 , nc(7) model(ols) run(xtmlh) mhet(x1 x2)}
{hline}

{bf:{err:* (17) Spatial Panel Geographically Weighted Regressions (GWR)}}
* ols      {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(ols)}
* xtbe     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtbe)}
* xtbem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtbem) ridge(grr1)}
* xtfe     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtfe)}
* xtfem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtfem) ridge(grr1)}
* xtfm     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtfm)}
* xtpa     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtpa)}
* xtwem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtwem)}
* xtmle    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtmle)}
* xtam     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtam)}
* xtbn     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtbn)}
* xthh     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xthh)}
* xtrc     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtrc)}
* xtre     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtre) hausman}
* xtrem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtrem) hausman ridge(grr1)}
* xtsa     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtsa)}
* xtmlem   {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtmlem)}
* xtwh     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtwh)}
* xtgls    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtgls)}
* xtkmhomo {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtkmhomo)}
* xtkmhet1 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtkmhet1)}
* xtkmhet2 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtkmhet2)}
* xtparks  {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtparks)}
* xtmg     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtmg)}
* xtpcse   {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtpcse)}
* xtregar  {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtregar)}

* xtabond  {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtabond) inst(x1 x2)}
* xtdhp    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtdhp) re}
* xtdpd    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtdpd) dgmmiv(x1 x2)}
* xtdpdsys {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtdpdsys)}

* xtmln    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtmln)}
* xtmlh    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtmlh) mhet(x1 x2)}
* xtfrontier {stata spregxt y x1 x2, nc(7) wmfile(SPWxt) model(gwr) run(xtfrontier) ti}
* xtfrontier {stata spregxt y x1 x2, nc(7) wmfile(SPWxt) model(gwr) run(xtfrontier) tvd}
* xtfrontier {stata spregxt y x1 x2, nc(7) wmfile(SPWxt) model(gwr) run(xtfrontier) ti cost}
* xttobit  {stata spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(gwr) run(xttobit)}
{hline}

{bf:{err:* (18) Spatial Panel Lag Regression Models (SAR)}}
* ols      {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(ols)}
* xtbe     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtbe)}
* xtbem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtbem) ridge(grr1)}
* xtfe     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtfe)}
* xtfem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtfem) ridge(grr1)}
* xtfm     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtfm)}
* xtpa     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtpa)}
* xtwem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtwem)}
* xtmle    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmle)}
* xtam     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtam)}
* xtbn     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtbn)}
* xthh     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xthh)}
* xtrc     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtrc)}
* xtre     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtre) hausman}
* xtrem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtrem) hausman ridge(grr1)}
* xtsa     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtsa)}
* xtmlem   {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmlem)}
* xtwh     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtwh)}
* xtgls    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtgls)}
* xtkmhomo {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtkmhomo)}
* xtkmhet1 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtkmhet1)}
* xtkmhet2 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtkmhet2)}
* xtparks  {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtparks)}
* xtmg     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmg)}
* xtpcse   {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtpcse)}
* xtregar  {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtregar)}

* xtabond  {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtabond) inst(x1 x2)}
* xtdhp    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtdhp) re}
* xtdpd    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtdpd) dgmmiv(x1 x2)}
* xtdpdsys {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtdpdsys)}

* xtmln    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmln)}
* xtmlh    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmlh) mhet(x1 x2)}
* xtfrontier {stata spregxt y x1 x2, nc(7) wmfile(SPWxt) model(sarxt) run(xtfrontier) ti}
* xtfrontier {stata spregxt y x1 x2, nc(7) wmfile(SPWxt) model(sarxt) run(xtfrontier) tvd}
* xtfrontier {stata spregxt y x1 x2, nc(7) wmfile(SPWxt) model(sarxt) run(xtfrontier) ti cost}
* xttobit  {stata spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sarxt) run(xttobit)}
{hline}

{bf:{err:* (19) Spatial Panel Durbin Regression Models (SDM)}}
 {stata local dum "dcs1 dcs2 dcs3 dcs4 dcs5"}
* ols      {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(ols)}
* xtbe     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtbe)}
* xtbem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtbem) ridge(grr1)}
* xtfe     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtfe)}
* xtfem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtfem) ridge(grr1)}
* xtfm     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtfm)}
* xtpa     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtpa)}
* xtwem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtwem)}
* xtmle    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmle)}
* xtam     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtam)}
* xtbn     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtbn)}
* xthh     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xthh)}
* xtrc     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtrc)}
* xtre     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtre) hausman}
* xtrem    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtrem) hausman ridge(grr1)}
* xtsa     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtsa)}
* xtmlem   {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmlem)}
* xtwh     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtwh)}
* xtgls    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtgls)}
* xtkmhomo {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtkmhomo)}
* xtkmhet1 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtkmhet1)}
* xtkmhet2 {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtkmhet2)}
* xtparks  {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtparks)}
* xtmg     {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmg)}
* xtpcse   {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtpcse)}
* xtregar  {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtregar)}

* xtabond  {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtabond) inst(x1 x2)}
* xtdhp    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtdhp) re}
* xtdpd    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtdpd) dgmmiv(x1 x2)}
* xtdpdsys {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtdpdsys)}

* xtfrontier {stata spregxt y x1 x2, nc(7) wmfile(SPWxt) model(sdmxt) run(xtfrontier) ti}
* xtfrontier {stata spregxt y x1 x2, nc(7) wmfile(SPWxt) model(sdmxt) run(xtfrontier) tvd}
* xtfrontier {stata spregxt y x1 x2, nc(7) wmfile(SPWxt) model(sdmxt) run(xtfrontier) ti cost}
* xttobit  {stata spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sdmxt) run(xttobit)}
* xtmln    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmln)}
* xtmlh    {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmlh) mhet(x1 x2)}
{hline}

{bf:{err:* (20) Create Spatial Panel Variables:}}

  {stata spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(1) list}
  {stata list w1y_* w1x_*}

  {stata spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(1) stand inv list}
  {stata list w1y_* w1x_*}

  {stata spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(1) stand inv2 list}
  {stata list w1y_* w1x_*}

  {stata spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(1) stand list}
  {stata list w1y_* w1x_*}

  {stata spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(2) list}
  {stata list w1y_* w1x_* w2x_*}

  {stata spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(2) stand list}
  {stata list w1y_* w1x_* w2x_*}

  {stata spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(3) list}
  {stata list w1y_* w1x_* w2x_* w3x_*}

  {stata spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(3) stand list}
  {stata list w1y_* w1x_* w2x_* w3x_*}

  {stata spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(4) list}
  {stata list w1y_* w1x_* w2x_* w3x_* w4x_*}

  {stata spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(4) stand list}
  {stata list w1y_* w1x_* w2x_* w3x_* w4x_*}
{hline}

{bf:{err:* (21) Create Panel Data Dummy Variables:}}
  {stata spregxt y x1 x2, nc(7) dumcs(Dum_cs)}
  {stata spregxt y x1 x2, nc(7) dumts(Dum_ts)}
  {stata spregxt y x1 x2, nc(7) dumcs(Dum_cs) dumts(Dum_ts)}
{hline}

{bf:{err:* (5) Spatial Panel Autoregressive Generalized Method of Moments} (Cont.)}
 This example is taken from Prucha data about Spatial Panel Regression.
 More details can be found in:
 {browse "http://econweb.umd.edu/~prucha/Research_Prog3.htm"}
 Results of {bf:model({err:{it:spgmm}})} with {cmd:gmm(3) option} is identical to:
 {browse "http://econweb.umd.edu/~prucha/STATPROG/PANOLS/PROGRAM3(L3).log"}

  {stata clear all}
  {stata sysuse spregxt1.dta, clear}
  {stata spregxt y x1 , wmfile(SPWxt1) nc(100) model(spgmm) gmm(1) stand}
  {stata spregxt y x1 , wmfile(SPWxt1) nc(100) model(spgmm) gmm(2) stand}
  {stata spregxt y x1 , wmfile(SPWxt1) nc(100) model(spgmm) gmm(3) stand}
{hline}

  {stata clear all}
  {stata sysuse spregxt.dta, clear}
  {stata spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) mfx(lin) pmfx tests predict(Yh) resid(Ue)}
{hline}

==============================================================================
*** Binary (0/1) Weight Matrix: (49x49) : NC=7 NT=7 (Non Normalized)
------------------------------------------------------------------------------
==============================================================================
* MLE Spatial Panel Lag Normal Model (SAR)
==============================================================================
 y = w1y_y x1 x2
------------------------------------------------------------------------------
 Sample Size        =          49   |   Cross Sections Number   =           7
 Wald Test          =     54.7117   |   P-Value > Chi2(2)       =      0.0000
 F-Test             =     27.3558   |   P-Value > F(2 , 40)     =      0.0000
 R2  (R-Squared)    =      0.5433   |   Raw Moments R2          =      0.9169
 R2a (Adjusted R2)  =      0.4519   |   Raw Moments R2 Adj      =      0.9003
 Root MSE (Sigma)   =     12.3874   |   Log Likelihood Function =   -187.2901
------------------------------------------------------------------------------
- R2h= 0.5524   R2h Adj= 0.4628  F-Test =   28.38 P-Value > F(2 , 40)  0.0000
- R2r= 0.9169   R2r Adj= 0.9003  F-Test =  169.29 P-Value > F(3 , 40)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y            |
          x1 |  -.2640053   .1025716    -2.57   0.010    -.4650418   -.0629687
          x2 |  -1.599966   .3231151    -4.95   0.000     -2.23326   -.9666723
       _cons |   69.85042   5.446557    12.82   0.000     59.17537    80.52548
-------------+----------------------------------------------------------------
         Rho |  -.0157471    .037723    -0.42   0.676    -.0896829    .0581887
       Sigma |   11.05584    1.11696     9.90   0.000     8.866635    13.24504
------------------------------------------------------------------------------
 LR Test SAR vs. OLS (Rho=0):      0.1743   P-Value > Chi2(1)   0.6764
 Acceptable Range for Rho:        -0.5201   <  Rho  < 0.3115
------------------------------------------------------------------------------

==============================================================================
* Panel Model Selection Diagnostic Criteria - Model= (sar)
==============================================================================
- Log Likelihood Function                   LLF            =   -187.2901
---------------------------------------------------------------------------
- Akaike Information Criterion              (1974) AIC     =    141.5802
- Akaike Information Criterion              (1973) Log AIC =      4.9529
---------------------------------------------------------------------------
- Schwarz Criterion                         (1978) SC      =    158.9663
- Schwarz Criterion                         (1978) Log SC  =      5.0687
---------------------------------------------------------------------------
- Amemiya Prediction Criterion              (1969) FPE     =    162.8422
- Hannan-Quinn Criterion                    (1979) HQ      =    147.9405
- Rice Criterion                            (1984) Rice    =    142.7418
- Shibata Criterion                         (1981) Shibata =    140.6016
- Craven-Wahba Generalized Cross Validation (1979) GCV     =    142.1347
------------------------------------------------------------------------------

==============================================================================
*** Spatial Panel Aautocorrelation Tests - Model= (sar)
*** Binary (0/1) Weight Matrix (W): (Non Normalized)
==============================================================================
  Ho: Error has No Spatial AutoCorrelation
  Ha: Error has    Spatial AutoCorrelation

- GLOBAL Moran MI            =  -0.0792     P-Value > Z(-0.512)   0.6086
- GLOBAL Geary GC            =   1.0330     P-Value > Z(0.235)    0.8140
- GLOBAL Getis-Ords GO       =   0.2262     P-Value > Z(0.512)    0.6086
------------------------------------------------------------------------------
- Moran MI Error Test        =  -0.0434     P-Value > Z(-0.198)   0.9654
------------------------------------------------------------------------------
- LM Error (Burridge)        =   0.3866     P-Value > Chi2(1)     0.5341
- LM Error (Robust)          =   0.2527     P-Value > Chi2(1)     0.6152
------------------------------------------------------------------------------
  Ho: Spatial Lagged Dependent Variable has No Spatial AutoCorrelation
  Ha: Spatial Lagged Dependent Variable has    Spatial AutoCorrelation

- LM Lag (Anselin)           =   0.1340     P-Value > Chi2(1)     0.7144
- LM Lag (Robust)            =   0.0000     P-Value > Chi2(1)     0.9991
------------------------------------------------------------------------------
  Ho: No General Spatial AutoCorrelation
  Ha:    General Spatial AutoCorrelation

- LM SAC (LMErr+LMLag_R)     =   0.3866     P-Value > Chi2(2)     0.8242
- LM SAC (LMLag+LMErr_R)     =   0.3866     P-Value > Chi2(2)     0.8242
------------------------------------------------------------------------------

==============================================================================
*** Panel Unit Roots Tests - Model= (sar)
==============================================================================
  Ho: All Panels are Stationary - Ha: Some Panels Have Unit Roots

- Hadri Z Test (No Trend - No Robust) =   1.9540   P-Value > Z(0,1)   0.0254
- Hadri Z Test (No Trend -    Robust) =   2.0098   P-Value > Z(0,1)   0.0222
- Hadri Z Test (   Trend - No Robust) =   0.9539   P-Value > Z(0,1)   0.1701
- Hadri Z Test (   Trend -    Robust) =   0.6572   P-Value > Z(0,1)   0.2555
------------------------------------------------------------------------------
==============================================================================
* (1)  (DF):           Dickey-Fuller   Test
* (2) (ADF): Augmented Dickey-Fuller   Test
* (3) (APP): Augmented Phillips-Perron Test
--------------------------------------------------
  Ho: All Panels Have Unit Roots  (Non stationary)
  Ha: At Least One Panel is Stationary
------------------------------------------------------------------------------
  Ho: Non Stationary [0.05, 0.01 < P-Value]
  Ha:     Stationary [0.05, 0.01 > P-Value]
------------------------------------------------------------------------------
*** (1) Dickey-Fuller (DF) Test:
--------------------------------------------------
-  DF Test: [Lag = 0] (No Trend)  =  -2.1511     P-Value > Z(0,1)    0.0157
* Since [.05 > 0.0157]:   Variable (y) has Stationary Process
------------------------------------------------------------------------------
-  DF Test: [Lag = 0] (   Trend)  =  -1.7131     P-Value > Z(0,1)    0.0433
* Since [.05 > 0.0433]:   Variable (y) has Stationary Process
------------------------------------------------------------------------------

------------------------------------------------------------------------------
*** (2) Augmented Dickey-Fuller (ADF) Test:
--------------------------------------------------
- ADF Test: [Lag = 1] (No Trend)  =   0.6539     P-Value > Z(0,1)    0.7434
* Since [.05 < 0.7434]:   Variable (y) has Non Stationary (Unit Roots)
------------------------------------------------------------------------------
- ADF Test: [Lag = 1] (   Trend)  =  -3.8085     P-Value > Z(0,1)    0.0001
* Since [.05 > 0.0001]:   Variable (y) has Stationary Process
------------------------------------------------------------------------------

------------------------------------------------------------------------------
*** (3) Augmented Phillips-Perron (APP) Test:
--------------------------------------------------
- APP Test: [Lag = 1] (No Trend)  =  -2.8930     P-Value > Z(0,1)    0.0019
* Since [.05 > 0.0019]:   Variable (y) has Stationary Process
------------------------------------------------------------------------------
- APP Test: [Lag = 1] (   Trend)  =  -4.5522     P-Value > Z(0,1)    0.0000
* Since [.05 > 0.0000]:   Variable (y) has Stationary Process
------------------------------------------------------------------------------

==============================================================================
*** Panel Error Component Tests - Model= (sar)
==============================================================================
* Panel Random Effects Tests
  Ho: Fixed Effects Model (FEM) - Ha: Random Effects Model (REM)
  Ho: No AR(1) Autocorrelation  - Ha: AR(1) Autocorrelation

- Breusch-Pagan  LM Test -Two Side      =  20.5375  P-Value > Chi2(1)   0.0000
- Breusch-Pagan ALM Test -Two Side      =  10.7351  P-Value > Chi2(1)   0.0011
------------------------------------------------------------------------------
- Sosa-Escudero-Yoon  LM Test -One Side =   4.5318  P-Value > Chi2(1)   0.0333
- Sosa-Escudero-Yoon ALM Test -One Side =   3.2764  P-Value > Chi2(1)   0.0703
------------------------------------------------------------------------------
- Baltagi-Li  LM Autocorrelation Test   =  10.8752  P-Value > Chi2(1)   0.0010
- Baltagi-Li ALM Autocorrelation Test   =   1.0729  P-Value > Chi2(1)   0.3003
------------------------------------------------------------------------------
- Baltagi-Li LM AR(1) Joint Test        =  21.6103  P-Value > Chi2(2)   0.0000
------------------------------------------------------------------------------

* Contemporaneous Correlations Across Cross Sctions Test
  Ho: No Contemporaneous Correlations (Independence) - (OLS)
  Ha:    Contemporaneous Correlations (Dependence)   - (Panel)

- Breusch-Pagan Diagonal Covariance Matrix LM Test=  32.3077 P>Chi2(21) 0.0545
- Breusch-Pagan Cross-Section Independence LM Test=  26.4443 P>Chi2(21) 0.1900
------------------------------------------------------------------------------
    LM= Lagrange Multiplier ; ALM = Adjusted Lagrange Multiplier
------------------------------------------------------------------------------

==============================================================================
*** Panel Serial Autocorrelation Tests - Model= (sar)
==============================================================================
  Ho: No AR(1) Panel AutoCorrelation - Ha: AR(1) Panel AutoCorrelation

- Durbin  h Test (Lag DepVar)             =   4.1606  P-Value > Z(0,1)  0.0000
- Harvey LM Test (Lag DepVar)             =  17.3105  P-Value > Chi2(1) 0.0000
------------------------------------------------------------------------------
- Panel Rho Value                         =   0.4330
- Durbin-Watson Test                      =   1.0273  df: (3 , 49)
- Von Neumann Ratio Test                  =   1.0487  df: (3 , 49)
- Box-Pierce LM Test                      =   9.1884  P-Value > Chi2(1) 0.0024
- Z Test                                  =   3.0312  P-Value > Z(0,1)  0.0024
------------------------------------------------------------------------------
- Durbin m Test (drop 1 cs obs)           =  10.7685  P-Value > F(1,38) 0.0022
- Durbin m Test (keep 1 cs obs)           =  11.9227  P-Value > F(1,45) 0.0012
------------------------------------------------------------------------------
- Breusch-Godfrey LM Test (drop 1 cs obs) =   9.3076  P-Value > Chi2(1) 0.0023
- Breusch-Godfrey LM Test (keep 1 cs obs) =  10.2638  P-Value > Chi2(1) 0.0014
------------------------------------------------------------------------------
- Breusch-Pagan-Godfrey Z (keep 1 nt obs) =   2.9534  P-Value > Z(0,1)  0.0031
- Breusch-Pagan-Godfrey Z (drop 1 cs obs) =   3.0508  P-Value > Z(0,1)  0.0023
- Breusch-Pagan-Godfrey Z (keep 1 cs obs) =   3.2037  P-Value > Z(0,1)  0.0014
------------------------------------------------------------------------------
- Baltagi LM Test                         =  10.7198  P-Value > Chi2(1) 0.0011
- Baltagi  Z Test                         =   3.2741  P-Value > Z(0,1)  0.0011
------------------------------------------------------------------------------
- Wooldridge  F Test                      =   8.6440  P-Value > F(1, 6) 0.0259
- Wooldridge LM Test                      =   7.0879  P-Value > Chi2(1) 0.0078
------------------------------------------------------------------------------

==============================================================================
*** Panel Heteroscedasticity Tests - Model= (sar)
==============================================================================
  Ho: Panel Homoscedasticity - Ha: Panel Heteroscedasticity

- Engle LM ARCH Test AR(1): E2 = E2_1   =   0.5087   P-Value > Chi2(1)  0.4757
------------------------------------------------------------------------------
- Hall-Pagan LM Test:   E2 = Yh         =   0.7757   P-Value > Chi2(1)  0.3785
- Hall-Pagan LM Test:   E2 = Yh2        =   0.4797   P-Value > Chi2(1)  0.4886
- Hall-Pagan LM Test:   E2 = LYh2       =   0.7284   P-Value > Chi2(1)  0.3934
------------------------------------------------------------------------------
- Harvey LM Test:    LogE2 = X          =   5.4808   P-Value > Chi2(2)  0.0645
- Wald Test:         LogE2 = X          =  13.5232   P-Value > Chi2(1)  0.0002
- Glejser LM Test:     |E| = X          =   6.7198   P-Value > Chi2(2)  0.0347
- Breusch-Godfrey Test:  E = E_1 X      =   8.1291   P-Value > Chi2(1)  0.0044
------------------------------------------------------------------------------
- Machado-Santos-Silva Test: Ev=Yh Yh2  =   2.7411   P-Value > Chi2(2)  0.2540
- Machado-Santos-Silva Test: Ev=X       =   6.8996   P-Value > Chi2(2)  0.0318
------------------------------------------------------------------------------
- White Test - Koenker(R2): E2 = X      =   7.0554   P-Value > Chi2(2)  0.0294
- White Test - B-P-G (SSR): E2 = X      =   9.2158   P-Value > Chi2(2)  0.0100
------------------------------------------------------------------------------
- White Test - Koenker(R2): E2 = X X2   =   7.6860   P-Value > Chi2(4)  0.1038
- White Test - B-P-G (SSR): E2 = X X2   =  10.0396   P-Value > Chi2(4)  0.0398
------------------------------------------------------------------------------
- White Test - Koenker(R2): E2 = X X2 XX=  19.7124   P-Value > Chi2(5)  0.0014
- White Test - B-P-G (SSR): E2 = X X2 XX=  25.7486   P-Value > Chi2(5)  0.0001
------------------------------------------------------------------------------
- Cook-Weisberg LM Test: E2/S2n = Yh    =   1.0132   P-Value > Chi2(1)  0.3141
- Cook-Weisberg LM Test: E2/S2n = X     =   9.2158   P-Value > Chi2(2)  0.0100
------------------------------------------------------------------------------
*** Single Variable Tests (E2/Sig2):
- Cook-Weisberg LM Test: x1             =   1.0861   P-Value > Chi2(1)  0.2973
- Cook-Weisberg LM Test: x2             =   3.7967   P-Value > Chi2(1)  0.0514
------------------------------------------------------------------------------
*** Single Variable Tests:
- King LM Test: x1                      =   0.1519   P-Value > Chi2(1)  0.6968
- King LM Test: x2                      =   4.2287   P-Value > Chi2(1)  0.0397
------------------------------------------------------------------------------

==============================================================================
* Panel Groupwise Heteroscedasticity Tests
==============================================================================
  Ho: Panel Homoscedasticity - Ha: Panel Groupwise Heteroscedasticity

- Lagrange Multiplier LM Test   =      7.3373    P-Value > Chi2(6)   0.2908
- Likelihood Ratio LR Test      =      7.1253    P-Value > Chi2(6)   0.3094
- Wald Test                     =     12.4812    P-Value > Chi2(7)   0.0858
------------------------------------------------------------------------------

==============================================================================
* Panel Non Normality Tests - Model= (sar)
==============================================================================
 Ho: Normality - Ha: Non Normality
------------------------------------------------------------------------------
*** Non Normality Tests:
- Jarque-Bera LM Test                  =   1.6062     P-Value > Chi2(2) 0.4479
- White IM Test                        =   5.8155     P-Value > Chi2(2) 0.0546
- Doornik-Hansen LM Test               =   3.5054     P-Value > Chi2(2) 0.1733
- Geary LM Test                        =  -2.7412     P-Value > Chi2(2) 0.2540
- Anderson-Darling Z Test              =   0.3237     P > Z( 0.118)     0.5472
- D'Agostino-Pearson LM Test           =   2.5494     P-Value > Chi2(2) 0.2795
------------------------------------------------------------------------------
*** Skewness Tests:
- Srivastava LM Skewness Test          =   0.6074     P-Value > Chi2(1) 0.4358
- Small LM Skewness Test               =   0.7396     P-Value > Chi2(1) 0.3898
- Skewness Z Test                      =  -0.8600     P-Value > Chi2(1) 0.3898
------------------------------------------------------------------------------
*** Kurtosis Tests:
- Srivastava  Z Kurtosis Test          =   0.9994     P-Value > Z(0,1)  0.3176
- Small LM Kurtosis Test               =   1.8098     P-Value > Chi2(1) 0.1785
- Kurtosis Z Test                      =   1.3453     P-Value > Chi2(1) 0.1785
------------------------------------------------------------------------------
    Skewness Coefficient = -0.2727     - Standard Deviation =  0.3398
    Kurtosis Coefficient =  3.6994     - Standard Deviation =  0.6681
------------------------------------------------------------------------------
    Runs Test: (16) Runs -  (24) Positives - (25) Negatives
    Standard Deviation Runs Sig(k) =  3.4619 , Mean Runs E(k) = 25.4898
    95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (18.7045 , 32.2751 )
------------------------------------------------------------------------------

==============================================================================
***  REgression Specification Error Tests (RESET) - (Model= sar)
==============================================================================
 Ho: Model is Specified  -  Ha: Model is Misspecified
------------------------------------------------------------------------------
* Ramsey Specification ResetF Test
- Ramsey RESETF1 Test: Y= X Yh2         =   2.723  P-Value > F(1,  45) 0.1059
- Ramsey RESETF2 Test: Y= X Yh2 Yh3     =   1.344  P-Value > F(2,  44) 0.2713
- Ramsey RESETF3 Test: Y= X Yh2 Yh3 Yh4 =   1.922  P-Value > F(3,  43) 0.1402
------------------------------------------------------------------------------
* DeBenedictis-Giles Specification ResetL Test
- Debenedictis-Giles ResetL1 Test       =   1.585  P-Value > F(2, 44)  0.2164
- Debenedictis-Giles ResetL2 Test       =   1.244  P-Value > F(4, 42)  0.3073
- Debenedictis-Giles ResetL3 Test       =   1.273  P-Value > F(6, 40)  0.2915
------------------------------------------------------------------------------
* DeBenedictis-Giles Specification ResetS Test
- Debenedictis-Giles ResetS1 Test       =   1.754  P-Value > F(2, 44)  0.1850
- Debenedictis-Giles ResetS2 Test       =   2.189  P-Value > F(4, 42)  0.0867
- Debenedictis-Giles ResetS3 Test       =   1.416  P-Value > F(6, 40)  0.2323
------------------------------------------------------------------------------

==============================================================================
*** Multicollinearity Diagnostic Tests - Model= (sar)
==============================================================================

* Correlation Matrix
+------------------------------------------+
|   Variable |       y |      x1 |      x2 |
|------------+---------+---------+---------|
|          y |   1.000 |         |         |
|         x1 |  -0.574 |   1.000 |         |
|         x2 |  -0.696 |   0.500 |   1.000 |
+------------------------------------------+

             |        y       x1       x2
-------------+---------------------------
           y |   1.0000 
             |
             |
          x1 |  -0.5745*  1.0000 
             |   0.0000
             |
          x2 |  -0.6956*  0.4999*  1.0000 
             |   0.0000   0.0003
             |

* Multicollinearity Diagnostic Criteria
+----------------------------------------------------------------------------+
| Variable | Eigenval | C_Number |  C_Index |      VIF |    1/VIF |  R2_xi,X |
|----------+----------+----------+----------+----------+----------+----------|
|       x1 |   1.4999 |   1.0000 |   1.0000 |   1.3331 |   0.7501 |   0.2499 |
|       x2 |   0.5001 |   2.9990 |   1.7318 |   1.3331 |   0.7501 |   0.2499 |
+----------------------------------------------------------------------------+

* Farrar-Glauber Multicollinearity Tests
  Ho: No Multicollinearity - Ha: Multicollinearity
--------------------------------------------------

* (1) Farrar-Glauber Multicollinearity Chi2-Test:
    Chi2 Test =   13.3697    P-Value > Chi2(1) 0.0003

* (2) Farrar-Glauber Multicollinearity F-Test:
+------------------------------------------------------------------------+
|   Variable |       F_Test |          DF1 |          DF2 |      P_Value |
|------------+--------------+--------------+--------------+--------------|
|         x1 |       15.657 |       47.000 |        2.000 |        0.062 |
|         x2 |       15.657 |       47.000 |        2.000 |        0.062 |
+------------------------------------------------------------------------+

* (3) Farrar-Glauber Multicollinearity t-Test:
+------------------------------------+
|   Variable |        x1 |        x2 |
|------------+-----------+-----------|
|         x1 |         . |           |
|------------+-----------+-----------|
|         x2 |     3.957 |         . |
+------------------------------------+

* |X'X| Determinant:
  |X'X| = 0 Multicollinearity - |X'X| = 1 No Multicollinearity
  |X'X| Determinant:       (0 < 0.7501 < 1)
---------------------------------------------------------------

* Theil R2 Multicollinearity Effect:
  R2 = 0 No Multicollinearity - R2 = 1 Multicollinearity
     - Theil R2:           (0 < 0.2706 < 1)
---------------------------------------------------------------

* Multicollinearity Range:
  Q = 0 No Multicollinearity - Q = 1 Multicollinearity
     - Gleason-Staelin Q0: (0 < 0.4999 < 1)
    1- Heo Range Q1:       (0 < 0.1974 < 1)
    2- Heo Range Q2:       (0 < 0.2499 < 1)
    3- Heo Range Q3:       (0 < 0.1339 < 1)
    4- Heo Range Q4:       (0 < 0.6494 < 1)
    5- Heo Range Q5:       (0 < 0.2372 < 1)
    6- Heo Range Q6:       (0 < 0.2499 < 1)
------------------------------------------------------------------------------

==============================================================================
*** Linear vs Log-Linear Functional Form Tests - (Model= OLS)
==============================================================================
 (1) R-squared
      Linear  R2                   =    0.5524
      Log-Log R2                   =    0.3749
---------------------------------------------------------------------------
 (2) Log Likelihood Function (LLF)
      LLF - Linear                 = -187.3772
      LLF - Log-Log                = -224.3892
---------------------------------------------------------------------------
 (3) Antilog R2
      Linear  vs Log-Log: R2Lin    =    0.5269
      Log-Log vs Linear : R2log    =    0.1208
---------------------------------------------------------------------------
 (4) Box-Cox Test                  =   36.2567   P-Value > Chi2(1)   0.0000
      Ho: Choose Log-Log Model - Ha: Choose Linear  Model
---------------------------------------------------------------------------
 (5) Bera-McAleer BM Test
      Ho: Choose Linear  Model     =    2.3994   P-Value > F(1, 44)  0.1285
      Ho: Choose Log-Log Model     =    0.8078   P-Value > F(1, 45)  0.3736
---------------------------------------------------------------------------
 (6) Davidson-Mackinnon PE Test
      Ho: Choose Linear  Model     =    2.3994   P-Value > F(1, 44)  0.1285
      Ho: Choose Log-Log Model     =    0.8078   P-Value > F(1, 45)  0.3736
------------------------------------------------------------------------------

==============================================================================

* Beta, Total, Direct, and InDirect (Model= sar): Linear: Marginal Effect *

+-------------------------------------------------------------------------------+
|     Variable |    Beta(B) |      Total |     Direct |   InDirect |       Mean |
|--------------+------------+------------+------------+------------+------------|
|y             |            |            |            |            |            |
|           x1 |    -0.2640 |    -0.2638 |    -0.2758 |     0.0120 |    38.4362 |
|           x2 |    -1.6000 |    -1.5989 |    -1.6716 |     0.0727 |    14.3749 |
+-------------------------------------------------------------------------------+

* Beta, Total, Direct, and InDirect (Model= sar): Linear: Elasticity *

+-------------------------------------------------------------------------------+
|     Variable |   Beta(Es) |      Total |     Direct |   InDirect |       Mean |
|--------------+------------+------------+------------+------------+------------|
|           x1 |    -0.2889 |    -0.2887 |    -0.3018 |     0.0131 |    38.4362 |
|           x2 |    -0.6547 |    -0.6543 |    -0.6840 |     0.0298 |    14.3749 |
+-------------------------------------------------------------------------------+
 Mean of Dependent Variable =     35.1288

------------------------------------------------------------------------------
*** P-Value: Total, Direct, and InDirect Marginal Effect ***
------------------------------------------------------------------------------

*** (1) Total Marginal Effect ***
------------------------------------------------------------------------------
       Total |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y            |
          x1 |  -.2638216   .1025716    -2.57   0.014    -.4711265   -.0565168
          x2 |  -1.598853   .3231151    -4.95   0.000    -2.251893   -.9458132
------------------------------------------------------------------------------

*** (2) Direct Marginal Effect ***
------------------------------------------------------------------------------
      Direct |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y            |
          x1 |  -.2758194   .1025716    -2.69   0.010    -.4831243   -.0685146
          x2 |  -1.671564   .3231151    -5.17   0.000    -2.324604   -1.018524
------------------------------------------------------------------------------

*** (3) InDirect Marginal Effect ***
------------------------------------------------------------------------------
    InDirect |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y            |
          x1 |   .0119978   .1025716     0.12   0.907    -.1953071    .2193026
          x2 |   .0727109   .3231151     0.23   0.823    -.5803291    .7257508
------------------------------------------------------------------------------

{p2colreset}{...}
{marker 25}{bf:{err:{dlgtab:Acknowledgments}}}

  I would like to thank the authors of the following Stata modules:

   - Mudit Kapoor, Harry H. Kelejian and Ingmar R. Prucha.
   - Christopher F Baum for {helpb xttest2}.
   - Markus Eberhardt for {helpb xtmg}.
   - Walter Sosa Escudero & Anil Bera {helpb xttest1}.

{p2colreset}{...}
{marker 26}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:{col 20}{browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:IDEAS:{col 20}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:EconPapers:{col 20}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}
  {hi:Google Scholar:{col 20}{browse "http://scholar.google.com/citations?hl=en&user=cOXvc94AAAAJ"}}

{bf:{err:{dlgtab:SPREGXT Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2016)}{p_end}
{p 1 10 1}{cmd:SPREGXT: "Stata Module Econometric Toolkit to Estimate Spatial Panel Regression Models"}{p_end}


{title:Online Help:}

{bf:{err:*** Spatial Econometrics Regression Models:}}

--------------------------------------------------------------------------------
{bf:{err:*** (1) Spatial Panel Data Regression Models:}}
{helpb spregxt}{col 17}Spatial Panel Regression Models: {cmd:Econometric Toolkit}
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
{helpb spregcs}{col 17}Spatial Cross Section Regression Models: {cmd:Econometric Toolkit}
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

