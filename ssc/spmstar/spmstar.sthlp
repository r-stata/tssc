{smcl}
{hline}
{cmd:help: {helpb spmstar}}{space 50} {cmd:dialog:} {bf:{dialog spmstar}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:spmstar: (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression}
{p 9 1 1}{bf:(Spatial Lag Cross Sections Models)}{p_end}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb spmstar##01:Syntax}{p_end}
{p 5}{helpb spmstar##02:Description}{p_end}
{p 5}{helpb spmstar##03:Options}{p_end}
{p 5}{helpb spmstar##04:Saved Results}{p_end}
{p 5}{helpb spmstar##05:References}{p_end}

{p 1}*** {helpb spmstar##06:Examples}{p_end}

{p 5}{helpb spmstar##07:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt spmstar} {depvar} {indepvars} {weight} , {opt wmf:ile(weight_file)} {opt nw:mat(#)} {opt nocons:tant}{p_end} 
{p 3 5 6} 
{err: [} {opt dist(norm|weib)} {opt mfx(lin, log)} {opt stand inv inv2 tolog nolog robust coll zero}{p_end} 
{p 5 5 6} 
{opt pred:ict(new_var)} {opt res:id(new_var)} {opt iter(#)} {opt tech(name)} {opt tobit} {opt ll(real 0)}{p_end} 
{p 5 5 6} 
 {opt l:evel(#)} {opth vce(vcetype)} {helpb maximize} {it:other maximization options} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:spmstar} estimates Spatial econometric regression (MSTAR) "Multiparametric Spatio Temporal AutoRegressive Regression" for Spatial Lag Cross Sections Models.{p_end}

{cmd:spmstar} estimates Continuous and Truncated Dependent Variables models {cmd:tobit}.

{p 2 2 2} {cmd:spmstar} deals with data either continuous or truncated dependent variable. If {depvar} has missing values or lower limits,
so in this case {cmd:spmstar} will fit spatial cross section model via {helpb tobit} model,
and thus {cmd:spmstar} can resolve the problem of missing values that exist in many kinds of data. Otherwise, in the case of continuous data, the normal estimation will be used.{p_end}

{p 2 4 2}{cmd:spmstar} can generate:{p_end}
    {cmd:- Binary / Standardized Weight Matrix.}
    {cmd:- Inverse  / Inverse Squared Standardized Weight Matrix.}
    {cmd:- Binary / Standardized / Inverse Eigenvalues Variable.}

{p 2 4 2} {cmd:spmstar} predicted values are obtained from conditional expectation expression.{p_end}

{pmore2}{bf:Yh = E(y|x) = inv(I-Rho*W) * X*Beta}

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{bf:{err:*** Important Notes:}}
{cmd:spmstar} generates some variables names with prefix:
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

{p 2 2 2}{bf:spmstar} is used with more than Weight Matrix: (Border, Language, Currency, Trade...){p_end}

{col 3}{opt zero}{col 20}convert missing values observations to Zero

{col 3}{opt nw:mat(1,2,3,4)}{col 20}number of Rho's matrixes to be used

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{col 3}{opt nolog}{col 20}suppress iteration of the log likelihood

{col 3}{opt tobit}{col 20}Estimate model via Tobit regression 

{col 3}{opt ll(#)}{col 20}value of minimum left-censoring dependent variable with:
{col 20} {bf:({err:{it:tobit}})}; default is 0

{col 3}{opt mfx(lin, log)}{col 20}functional form: Linear model {cmd:(lin)}, or Log-Log model {cmd:(log)},
{col 20}to compute Total, Direct, and InDirect Marginal Effects and Elasticities
   - In Linear model: marginal effects are the coefficients (Bm),
        and elasticities are (Es = Bm X/Y).
   - In Log-Log model: elasticities are the coefficients (Es),
        and the marginal effects are (Bm = Es Y/X).
   - {opt mfx(log)} and {opt tolog} options must be combined, to transform linear variables to log form.

{p 8 4 2}{opt mfx(lin, log)} can calculate:{p_end}
		{cmd:- Total    Marginal Effects and Elasticities.}
		{cmd:- Direct   Marginal Effects and Elasticities.}
		{cmd:- InDirect Marginal Effects and Elasticities.}

{col 3}{opt tolog}{col 20}Convert dependent and independent variables
{col 20}to LOG Form in the memory for Log-Log regression.
{col 20}{opt tolog} Transforms {depvar} and {indepvars}
{col 20}to Log Form without lost the original data variables

{synopt :{bf:dist({err:{it:norm, weib}})} Distribution of error term:}{p_end}
{p 12 2 2}1- {bf:dist({err:{it:norm}})} Normal distribution; default.{p_end}
{p 12 2 2}3- {bf:dist({err:{it:weib}})} Weibull distribution.{p_end}

{p 10 10 1}{cmd:dist} option is used to remedy non normality problem, when the error term has non normality distribution.{p_end}
{p 10 10 1} {opt dist(weib)} can be used.{p_end}

{p 10 10 1}{bf:dist({err:{it:norm}})} is the default distribution.{p_end}

{col 3}{opt pred:ict(new_variable)}{col 30}Predicted values variable

{col 3}{opt res:id(new_variable)}{col 30}Residuals values variable computed as Ue=Y-Yh

{col 3}{opt rob:ust}{col 20}Huber-White standard errors

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
{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:spmstar} saves the following results in {cmd:e()}:

Scalars

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
{col 4}{cmd:e(llf)}{col 20}Log Likelihood Function

Matrixes       
{col 4}{cmd:e(b)}{col 20}coefficient vector
{col 4}{cmd:e(V)}{col 20}variance-covariance matrix of the estimators

{col 4}{cmd:e(mfxlinb)}{col 20}Beta, Total, Direct, and InDirect Marginal Effect{col 70}(in Lin Form)
{col 4}{cmd:e(mfxline)}{col 20}Beta, Total, Direct, and InDirect Elasticity{col 70}(in Lin Form)

{col 4}{cmd:e(mfxlogb)}{col 20}Beta, Total, Direct, and InDirect Marginal Effect{col 70}(in Log Form)
{col 4}{cmd:e(mfxloge)}{col 20}Beta, Total, Direct, and InDirect Elasticity{col 70}(in Log Form)

Functions      
{col 4}{cmd:e(sample)}{col 20}marks estimation sample

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Anselin, L. (2001)
{cmd: "Spatial Econometrics",}
{it:In Baltagi, B. (Ed).: A Companion to Theoretical Econometrics Basil Blackwell: Oxford, UK}.

{p 4 8 2}Anselin, L. (2007)
{cmd: "Spatial Econometrics",}
{it:In T. C. Mills and K. Patterson (Eds).: Palgrave Handbook of Econometrics. Vol 1, Econometric Theory. New York: Palgrave MacMillan}.

{p 4 8 2}Anselin, L. & Florax RJ. (1995)
{cmd: "New Directions in Spatial Econometrics: Introduction. In New Directions in Spatial Econometrics",}
{it:Anselin L, Florax RJ (eds). Berlin, Germany: Springer-Verlag}.

{p 4 8 2}Hays, Jude C., Aya Kachi & Robert J. Franzese, Jr (2010)
{cmd: "A Spatial Model Incorporating Dynamic, Endogenous Network Interdependence: A Political Science Application",}
{it:Statistical Methodology 7(3)}; 406-428.

{p 4 8 2}James LeSage and R. Kelly Pace (2009)
{cmd: "Introduction to Spatial Econometrics",}
{it:Publisher: Chapman & Hall/CRC}.

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Examples}}}

{bf:Note 1:} you can use: {helpb spweight}, {helpb spweightcs}, {helpb spweightxt} to create Spatial Weight Matrix.
{bf:Note 2:} Remember, your spatial weight matrix must be:
    *** {bf:{err:1-Cross Section Dimention  2- Square Matrix 3- Symmetric Matrix}}
{bf:Note 3:} You can use the dialog box for {dialog spmstar}.
{hline}

{stata clear all}

{stata sysuse spmstar.dta, clear}

{bf:{err:* (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression}}
{bf:{bf:* (m-STAR) Lag Model}}

*** {bf:YOU MUST HAVE DIFFERENT Weighted Matrixes Files:}

{bf:* (1) *** Normal Distribution}
 {stata spmstar y x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)}
 {stata spmstar y x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) dist(norm)}
 {stata spmstar y x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) dist(norm)}
 {stata spmstar y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm)}
 {stata spmstar ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm) tobit ll(0)}
 {stata spmstar ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm) tobit ll(3)}
{hline}

{bf:* (2) *** Weibull Distribution}
 {stata spmstar y x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)}
 {stata spmstar y x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) dist(weib)}
 {stata spmstar y x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) dist(weib)}
 {stata spmstar y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib)}
 {stata spmstar ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib) tobit ll(0)}
 {stata spmstar ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib) tobit ll(3)}
{hline}

{bf:* (3) Weighted mSTAR Normal Distribution:}
 {stata spmstar y x1 x2  [weight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)}
 {stata spmstar y x1 x2 [aweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)}
 {stata spmstar y x1 x2 [iweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)}
{hline}

{bf:* (4) Weighted mSTAR Weibull Distribution:}
 {stata spmstar y x1 x2  [weight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)}
 {stata spmstar y x1 x2 [aweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)}
 {stata spmstar y x1 x2 [iweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)}
{hline}

. clear all
. sysuse spmstar.dta, clear
. spmstar y x1 x2 , wmfile(SPWmcs1) nwmat(1) dist(norm) mfx(lin)

==============================================================================
*** Binary (0/1) Weight Matrix: 49x49 (Non Normalized)
==============================================================================
==============================================================================
* MLE Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial Lag Normal Model (1 Weight Matrix)
==============================================================================
  y = x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          49
  Wald Test         =     56.4471   |   P-Value > Chi2(2)       =      0.0000
  F-Test            =     28.2236   |   P-Value > F(2 , 47)     =      0.0000
 (Buse 1973) R2     =      0.5510   |   Raw Moments R2          =      0.9184
 (Buse 1973) R2 Adj =      0.5414   |   Raw Moments R2 Adj      =      0.9166
  Root MSE (Sigma)  =     11.3305   |   Log Likelihood Function =   -186.8161
------------------------------------------------------------------------------
- R2h= 0.5510   R2h Adj= 0.5415  F-Test =   28.23 P-Value > F(2 , 47)  0.0000
- R2v= 0.5543   R2v Adj= 0.5448  F-Test =   28.61 P-Value > F(2 , 47)  0.0000
------------------------------------------------------------------------------
- Sum of Rho's =    0.0211161    Sum must be < 1 for Stability Condition
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y            |
          x1 |   -.252788   .1007052    -2.51   0.012    -.4501667   -.0554094
          x2 |  -1.585978   .3198759    -4.96   0.000    -2.212924    -.959033
       _cons |   64.04514   6.233457    10.27   0.000     51.82779    76.26249
-------------+----------------------------------------------------------------
        Rho1 |   .0211161   .0197638     1.07   0.285    -.0176202    .0598524
       Sigma |   10.94111    1.10546     9.90   0.000     8.774445    13.10777
------------------------------------------------------------------------------
 Wald Test [Rho1=0]:                 1.1415        P-Value > Chi2(1) 0.2853
 Acceptable Range for Rho1: -0.3199 < Rho1 < 0.1633
------------------------------------------------------------------------------

* Beta, Total, Direct, and InDirect Linear: Marginal Effect *

+--------------------------------------------------------------------------+
|     Variable |   Beta(B) |     Total |    Direct |  InDirect |      Mean |
|--------------+-----------+-----------+-----------+-----------+-----------|
|y             |           |           |           |           |           |
|           x1 |   -0.2528 |   -0.2522 |   -0.2266 |   -0.0256 |   38.4362 |
|           x2 |   -1.5860 |   -1.5824 |   -1.4218 |   -0.1606 |   14.3749 |
+--------------------------------------------------------------------------+

* Beta, Total, Direct, and InDirect Linear: Elasticity *

+--------------------------------------------------------------------------+
|     Variable |  Beta(Es) |     Total |    Direct |  InDirect |      Mean |
|--------------+-----------+-----------+-----------+-----------+-----------|
|           x1 |   -0.2766 |   -0.2760 |   -0.2480 |   -0.0280 |   38.4362 |
|           x2 |   -0.6490 |   -0.6475 |   -0.5818 |   -0.0657 |   14.3749 |
+--------------------------------------------------------------------------+
 Mean of Dependent Variable =     35.1288

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:SPMSTAR Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:SPMSTAR: "(m-STAR) Spatial Multiparametric Spatio Temporal AutoRegressive Regression: Spatial Lag Cross Sections Models"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457379.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457379.htm"}


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

