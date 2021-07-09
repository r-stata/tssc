{smcl}
{hline}
{cmd:help: {helpb spmstard}}{space 50} {cmd:dialog:} {bf:{dialog spmstard}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:spmstard: (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression}
{p 9 1 1}{bf:(Spatial Durbin Cross Sections Models)}{p_end}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb spmstard##01:Syntax}{p_end}
{p 5}{helpb spmstard##02:Description}{p_end}
{p 5}{helpb spmstard##03:Options}{p_end}
{p 5}{helpb spmstard##04:Saved Results}{p_end}
{p 5}{helpb spmstard##05:References}{p_end}

{p 1}*** {helpb spmstard##06:Examples}{p_end}

{p 5}{helpb spmstard##07:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt spmstard} {depvar} {indepvars} {weight} , {opt wmf:ile(weight_file)} {opt nw:mat(#)} {opt nocons:tant} {opt aux(varlist)}{p_end} 
{p 3 5 6} 
{err: [} {opt stand inv inv2} {opt dist(norm|weib)} {opt mfx(lin, log)} {opt coll zero tolog nolog robust}{p_end} 
{p 5 5 6} 
{opt pred:ict(new_var)} {opt res:id(new_var)} {opt iter(#)} {opt tech(name)} {opt tobit} {opt ll(real 0)}{p_end} 
{p 5 5 6} 
 {opt l:evel(#)} {opth vce(vcetype)} {helpb maximize} {it:other maximization options} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:spmstard} estimates Spatial econometric regression (MSTAR) "Multiparametric Spatio Temporal AutoRegressive Regression" for Spatial Durbin Cross Sections models.{p_end}

{cmd:spmstard} estimates Continuous and Truncated Dependent Variables models {cmd:tobit}.

{p 2 2 2} {cmd:spmstard} deals with data either continuous or truncated dependent variable. If {depvar} has missing values or lower limits,
so in this case {cmd:spmstard} will fit spatial cross section model via {helpb tobit} model,
and thus {cmd:spmstard} can resolve the problem of missing values that exist in many kinds of data. Otherwise, in the case of continuous data, the normal estimation will be used.{p_end}

{p 2 4 2}{cmd:spmstard} can generate:{p_end}
    {cmd:- Binary / Standardized Weight Matrix.}
    {cmd:- Inverse  / Inverse Squared Standardized Weight Matrix.}
    {cmd:- Binary / Standardized / Inverse Eigenvalues Variable.}

{p 2 4 2} {cmd:spmstard} predicted values are obtained from conditional expectation expression.{p_end}

{pmore2}{bf:Yh = E(y|x) = inv(I-Rho*W) * X*Beta}

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{bf:{err:*** Important Notes:}}
{cmd:spmstard} generates some variables names with prefix:
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

{p 2 2 2}{bf:spmstard} is used with more than Weight Matrix: (Border, Language, Currency, Trade...){p_end}

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
{p 10 10 1} {opt dist(norm, weib)} can be used.{p_end}

{p 10 10 1}{bf:dist({err:{it:norm}})} is the default distribution.{p_end}

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

{p 2 4 2 }{cmd:spmstard} saves the following results in {cmd:e()}:

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
{bf:Note 3:} You can use the dialog box for {dialog spmstard}.
{hline}

{stata clear all}

{stata sysuse spmstard.dta, clear}

{bf:{err:* (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression}}
{bf:{bf:* (m-STAR) Durbin Model}}

*** {bf:YOU MUST HAVE DIFFERENT Weighted Matrixes Files:}

{bf:* (1) *** Normal Distribution}
 {stata spmstard y x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)}
 {stata spmstard y x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) dist(norm)}
 {stata spmstard y x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) dist(norm)}
 {stata spmstard y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm)}

 {stata spmstard y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm) aux(x3 x4)}
 
 {stata spmstard ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm) tobit ll(0)}
 {stata spmstard ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm) tobit ll(3)}
 
{hline}

{bf:* (2) *** Weibull Distribution}
 {stata spmstard y x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)}
 {stata spmstard y x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) dist(weib)}
 {stata spmstard y x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) dist(weib)}
 {stata spmstard y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib)}

 {stata spmstard y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib) aux(x3 x4)}

 {stata spmstard ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib) tobit ll(0)}
 {stata spmstard ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib) tobit ll(3)}
{hline}

{bf:* (3) Weighted mSTAR Normal Distribution:}
 {stata spmstard y x1 x2  [weight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)}
 {stata spmstard y x1 x2 [aweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)}
 {stata spmstard y x1 x2 [iweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)}
{hline}

{bf:* (4) Weighted mSTAR Weibull Distribution:}
 {stata spmstard y x1 x2  [weight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)}
 {stata spmstard y x1 x2 [aweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)}
 {stata spmstard y x1 x2 [iweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)}
{hline}

. clear all
. sysuse spmstard.dta, clear
. spmstard y x1 x2 , wmfile(SPWmcs1) nwmat(1) dist(norm) mfx(lin)

==============================================================================
*** Binary (0/1) Weight Matrix: 49x49 (Non Normalized)
==============================================================================
==============================================================================
* MLE Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial Durbin Normal Model (1 Weight Matrix)
==============================================================================
  y = x1 + x2 + w1x_x1 + w1x_x2
------------------------------------------------------------------------------
  Sample Size       =          49
  Wald Test         =     62.7350   |   P-Value > Chi2(4)       =      0.0000
  F-Test            =     15.6838   |   P-Value > F(4 , 45)     =      0.0000
 (Buse 1973) R2     =      0.5878   |   Raw Moments R2          =      0.9250
 (Buse 1973) R2 Adj =      0.5603   |   Raw Moments R2 Adj      =      0.9200
  Root MSE (Sigma)  =     11.0953   |   Log Likelihood Function =   -184.6725
------------------------------------------------------------------------------
- R2h= 0.5878   R2h Adj= 0.5603  F-Test =   15.69 P-Value > F(4 , 45)  0.0000
- R2v= 0.5954   R2v Adj= 0.5684  F-Test =   16.19 P-Value > F(4 , 45)  0.0000
------------------------------------------------------------------------------
- Sum of Rho's =    0.0416823    Sum must be < 1 for Stability Condition
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y            |
          x1 |   -.250281   .0960709    -2.61   0.009    -.4385765   -.0619854
          x2 |  -1.532047   .3148392    -4.87   0.000    -2.149121   -.9149737
      w1x_x1 |  -.0713523   .0436152    -1.64   0.102    -.1568366     .014132
      w1x_x2 |   .0911799   .1195827     0.76   0.446    -.1431979    .3255577
       _cons |   66.25538   6.042699    10.96   0.000      54.4119    78.09885
-------------+----------------------------------------------------------------
        Rho1 |   .0416823   .0238573     1.75   0.081    -.0050771    .0884417
       Sigma |   10.43752   1.055823     9.89   0.000     8.368147     12.5069
------------------------------------------------------------------------------
 Wald Test [Rho1=0]:                 3.0525        P-Value > Chi2(1) 0.0806
 Acceptable Range for Rho1: -0.3199 < Rho1 < 0.1633
------------------------------------------------------------------------------

* Beta, Total, Direct, and InDirect Linear: Marginal Effect *

+--------------------------------------------------------------------------+
|     Variable |   Beta(B) |     Total |    Direct |  InDirect |      Mean |
|--------------+-----------+-----------+-----------+-----------+-----------|
|y             |           |           |           |           |           |
|           x1 |   -0.2503 |   -0.2480 |   -0.1982 |   -0.0498 |   38.4362 |
|           x2 |   -1.5320 |   -1.5179 |   -1.2133 |   -0.3046 |   14.3749 |
|       w1x_x1 |   -0.0714 |   -0.0707 |   -0.0565 |   -0.0142 |  180.6248 |
|       w1x_x2 |    0.0912 |    0.0903 |    0.0722 |    0.0181 |   69.1116 |
+--------------------------------------------------------------------------+

* Beta, Total, Direct, and InDirect Linear: Elasticity *

+--------------------------------------------------------------------------+
|     Variable |  Beta(Es) |     Total |    Direct |  InDirect |      Mean |
|--------------+-----------+-----------+-----------+-----------+-----------|
|           x1 |   -0.2738 |   -0.2713 |   -0.2169 |   -0.0544 |   38.4362 |
|           x2 |   -0.6269 |   -0.6211 |   -0.4965 |   -0.1247 |   14.3749 |
|       w1x_x1 |   -0.3669 |   -0.3635 |   -0.2905 |   -0.0729 |  180.6248 |
|       w1x_x2 |    0.1794 |    0.1777 |    0.1421 |    0.0357 |   69.1116 |
+--------------------------------------------------------------------------+
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

{bf:{err:{dlgtab:SPMSTARD Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2012)}{p_end}
{p 1 12 1}{cmd:SPMSTARD: "(m-STAR) Spatial Multiparametric Spatio Temporal AutoRegressive Regression: Spatial Durbin Cross Sections Models"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457504.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457504.htm"}


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

