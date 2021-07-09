{smcl}
{hline}
{cmd:help: {helpb sptobitmstardh}}{space 50} {cmd:dialog:} {bf:{dialog sptobitmstardh}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:sptobitmstardh: Tobit (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression}
{p 9 1 1}{bf:(Spatial Durbin Multiplicative Heteroscedasticity Cross Sections Models)}{p_end}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb sptobitmstardh##01:Syntax}{p_end}
{p 5}{helpb sptobitmstardh##02:Description}{p_end}
{p 5}{helpb sptobitmstardh##03:Options}{p_end}
{p 5}{helpb sptobitmstardh##04:Saved Results}{p_end}
{p 5}{helpb sptobitmstardh##05:References}{p_end}

{p 1}*** {helpb sptobitmstardh##06:Examples}{p_end}

{p 5}{helpb sptobitmstardh##07:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt sptobitmstardh} {depvar} {indepvars} {weight} , {opt wmf:ile(weight_file)} {opt mhet(varlist)} {opt ll(#){p_end} 
{p 3 5 6} 
{err: [}{opt nw:mat(#)} {opt nocons:tant} {opt aux(varlist)} {opt stand inv inv2} {opt mfx(lin, log)} {opt robust zero}{p_end} 
{p 5 5 6} 
{opt pred:ict(new_var)} {opt res:id(new_var)} {opt iter(#)} {opt tech(name)} {opt tolog nolog coll}}{p_end} 
{p 5 5 6} 
 {opt l:evel(#)} {opth vce(vcetype)} {helpb maximize} {it:other maximization options} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:sptobitmstardh} estimates Tobit Spatial econometric regression (MSTAR) "Multiparametric Spatio Temporal AutoRegressive Regression" models for Spatial Durbin Multiplicative Heteroscedasticity Cross Sections models.{p_end}

{p 2 4 2}{cmd:sptobitmstardh} can generate:{p_end}
    {cmd:- Binary / Standardized Weight Matrix.}
    {cmd:- Inverse  / Inverse Squared Standardized Weight Matrix.}
    {cmd:- Binary / Standardized / Inverse Eigenvalues Variable.}

{p 2 4 2} {cmd:sptobitmstardh} predicted values are obtained from conditional expectation expression.{p_end}

{pmore2}{bf:Yh = E(y|x) = inv(I-Rho*W) * X*Beta}

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{bf:{err:*** Important Notes:}}
{cmd:sptobitmstardh} generates some variables names with prefix:
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

{p 2 2 2}{bf:sptobitmstardh} is used with more than Weight Matrix: (Border, Language, Currency, Trade...){p_end}

{p 2 10 10}{opt mhet(varlist)} Set variable(s) that will be included in {cmd:Spatial cross section Multiplicative Heteroscedasticity} model, to remidy Heteroscedasticity.
option {weight}, can be used in the case of Heteroscedasticity in errors.{p_end}

{synopt :{opt mhet(varlist)}} Default is including all independent variables.{p_end}

{col 3}{opt zero}{col 20}convert missing values observations to Zero

{col 3}{opt nw:mat(1,2,3,4)}{col 20}number of Rho's matrixes to be used

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{col 3}{opt nolog}{col 20}suppress iteration of the log likelihood

{col 3}{opt ll(#)}{col 20}value of minimum left-censoring dependent variable with {bf:({err:{it:tobit}})}.

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

{p 2 10 10}{opt aux(varlist)} add Auxiliary Variables into regression model without converting them to spatial lagged variables, or without {cmd:log} form, i.e., dummy variables.
This option dont include these auxiliary variables among spatial lagged variables, it is useful to avoid lost degrees of freedom (DF).
Using many dummy variables must be used with caution to avoid multicollinearity problem.{p_end}

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

{p 2 4 2 }{cmd:sptobitmstardh} saves the following results in {cmd:e()}:

Scalars

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
{bf:Note 3:} You can use the dialog box for {dialog sptobitmstardh}.
{hline}

{stata clear all}

{stata sysuse sptobitmstardh.dta, clear}

{bf:{err:* Tobit (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression}}
{bf:{bf:* (m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Model}}

*** {bf:YOU MUST HAVE DIFFERENT Weighted Matrixes Files:}

{bf:* (1) mSTAR Model}
{stata sptobitmstardh y x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) mhet(x1) ll(0)}
{stata sptobitmstardh y x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) mhet(x1) ll(0)}
{stata sptobitmstardh y x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) mhet(x1) ll(0)}
{stata sptobitmstardh y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) mhet(x1) ll(0)}
{hline}

{bf:* (2) Weighted mSTAR}
{stata sptobitmstardh y x1 x2  [weight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) mhet(x1) ll(0)}
{stata sptobitmstardh y x1 x2 [aweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) mhet(x1) ll(0)}
{hline}

. clear all
. sysuse sptobitmstardh.dta, clear
. sptobitmstardh y x1 x2 , wmfile(SPWmcs1) mhet(x1 x2) nwmat(1) mfx(lin) ll(0)

==============================================================================
*** Binary (0/1) Weight Matrix: 49x49 (Non Normalized)
==============================================================================
*** y          Lower Limit                  = 0
*** y          Left-  Censored Observations = 0
*** y          Left-UnCensored Observations = 49
------------------------------------------------------------

==============================================================================
* Tobit MLE Multiparametric Spatio Temporal AutoRegressive Regression  (1 Weight Matrix)
* (m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Model
==============================================================================
  y = x1 + x2 + w1x_x1 + w1x_x2
------------------------------------------------------------------------------
  Sample Size       =          49
  Wald Test         =     50.6905   |   P-Value > Chi2(4)       =      0.0000
  F-Test            =     12.6726   |   P-Value > F(4 , 45)     =      0.0000
 (Buse 1973) R2     =      0.5353   |   Raw Moments R2          =      0.9155
 (Buse 1973) R2 Adj =      0.5044   |   Raw Moments R2 Adj      =      0.9099
  Root MSE (Sigma)  =     11.7798   |   Log Likelihood Function =   -182.5892
------------------------------------------------------------------------------
- R2h= 0.5442   R2h Adj= 0.5138  F-Test =   13.13 P-Value > F(4 , 45)  0.0000
- R2v= 0.4223   R2v Adj= 0.3838  F-Test =    8.04 P-Value > F(4 , 45)  0.0001
------------------------------------------------------------------------------
- Sum of Rho's =    0.0357487    Sum must be < 1 for Stability Condition
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y            |
          x1 |  -.1717403   .0916651    -1.87   0.061    -.3514006    .0079201
          x2 |  -1.436416   .2984177    -4.81   0.000    -2.021304   -.8515281
      w1x_x1 |   -.008006   .0474742    -0.17   0.866    -.1010538    .0850418
      w1x_x2 |   .0056663   .1013091     0.06   0.955    -.1928958    .2042285
       _cons |   56.74058   7.479479     7.59   0.000     42.08107    71.40009
-------------+----------------------------------------------------------------
Hetero       |
          x1 |   .0021049   .0060816     0.35   0.729    -.0098149    .0140246
          x2 |  -.0621448   .0339503    -1.83   0.067     -.128686    .0043965
-------------+----------------------------------------------------------------
        Rho1 |   .0357487   .0238089     1.50   0.133    -.0109159    .0824134
       Sigma |    22.5681   13.14127     1.72   0.086    -3.188311    48.32451
------------------------------------------------------------------------------
 Wald Test [Rho1=0]:                 2.2545        P-Value > Chi2(1) 0.1332
 Acceptable Range for Rho1: -0.3199 < Rho1 < 0.1633
------------------------------------------------------------------------------

* Beta, Total, Direct, and InDirect (Model= ): Linear: Marginal Effect *

+-------------------------------------------------------------------------------+
|     Variable |    Beta(B) |      Total |     Direct |   InDirect |       Mean |
|--------------+------------+------------+------------+------------+------------|
|y             |            |            |            |            |            |
|           x1 |    -0.1717 |    -0.1706 |    -0.1413 |    -0.0293 |    38.4362 |
|           x2 |    -1.4364 |    -1.4268 |    -1.1815 |    -0.2453 |    14.3749 |
|       w1x_x1 |    -0.0080 |    -0.0080 |    -0.0066 |    -0.0014 |   180.6248 |
|       w1x_x2 |     0.0057 |     0.0056 |     0.0047 |     0.0010 |    69.1116 |
+-------------------------------------------------------------------------------+

* Beta, Total, Direct, and InDirect (Model= ): Linear: Elasticity *

+-------------------------------------------------------------------------------+
|     Variable |   Beta(Es) |      Total |     Direct |   InDirect |       Mean |
|--------------+------------+------------+------------+------------+------------|
|           x1 |    -0.1879 |    -0.1867 |    -0.1546 |    -0.0321 |    38.4362 |
|           x2 |    -0.5878 |    -0.5839 |    -0.4835 |    -0.1004 |    14.3749 |
|       w1x_x1 |    -0.0412 |    -0.0409 |    -0.0339 |    -0.0070 |   180.6248 |
|       w1x_x2 |     0.0111 |     0.0111 |     0.0092 |     0.0019 |    69.1116 |
+-------------------------------------------------------------------------------+
 Mean of Dependent Variable =     35.1288

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:Authors}}}

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

{bf:{err:{dlgtab:SPTOBITMSTARDH Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2013)}{p_end}
{p 1 10 1}{cmd:SPTOBITMSTARDH: "Tobit (m-STAR) Spatial Multiparametric Spatio Temporal AutoRegressive Regression: Spatial Durbin Multiplicative Heteroscedasticity Cross Sections Models"}{p_end}


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

