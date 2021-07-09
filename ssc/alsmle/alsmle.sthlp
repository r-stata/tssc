{smcl}
{hline}
{cmd:help: {helpb alsmle}}{space 55} {cmd:dialog:} {bf:{dialog alsmle}}
{hline}

{bf:{err:{dlgtab:Title}}}

{p 4 8 2}
{bf:alsmle: Beach-Mackinnon AR(1) Autoregressive Maximum Likelihood Estimation}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb alsmle##01:Syntax}{p_end}
{p 5}{helpb alsmle##02:Options}{p_end}
{p 5}{helpb alsmle##03:Description}{p_end}
{p 5}{helpb alsmle##04:Saved Results}{p_end}
{p 5}{helpb alsmle##05:References}{p_end}

{p 1}*** {helpb alsmle##06:Examples}{p_end}

{p 5}{helpb alsmle##07:Acknowledgment}{p_end}
{p 5}{helpb alsmle##08:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt alsmle} {depvar} {indepvars} {ifin} {weight} , {err: [} {opt nocons:tant} {opt diag} {opt mfx(lin, log)} {opt dn}{p_end} 
{p 12 5 6}
{opt log tolog} {opt two:step} {opt iter(#)} {opt tol:erance(#)} {opt pred:ict(new_var)} {opt res:id(new_var)}{p_end} 
{p 12 5 6} 
{opt l:evel(#)} {opth vce(vcetype)} {err:]}{p_end} 

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{synopt :{opt nocons:tant}}Exclude Constant Term from Equation{p_end} 
{synopt :{opt dn}}Use (N) divisor instead of (N-K) for Degrees of Freedom (DF){p_end} 
{synopt :{opt log}}display iteration of Log Likelihood{p_end} 
{synopt :{opt tolog}}Convert dependent and independent variables to LOG Form in the memory for Log-Log regression. {opt tolog} Transforms {depvar} and {indepvars} to Log Form without lost the original data variables{p_end} 
{synopt :{opt iter(#)}}number of iterations; Default is iter(50){p_end} 
{synopt :{opt tol:erance(#)}}tolerance for coefficient vector; Default is tol(0.00001){p_end} 
{synopt :{opt two:step}}Two-Step estimation, stop after first iteration, same as iter(1){p_end} 
{synopt :{opt pred:ict(new_var)}}Predicted values variable{p_end} 
{synopt :{opt res:id(new_var)}}Residuals values variable{p_end} 
{synopt :{opt level(#)}}confidence intervals level; Default is level(95){p_end} 
{synopt :{opth vce(vcetype)}}{opt ols}, {opt r:obust}, {opt cl:uster}, {opt boot:strap}, {opt jack:knife}, {opt hc2}, {opt hc3}{p_end} 
{synopt :{opt mfx(lin, log)}}Type of functional form, either Linear model {cmd:(lin)}, or Log-Log model {cmd:(log)}, to compute Marginal Effects and Elasticities.{p_end} 
{pmore}- In Linear model marginal effects are the transformed coefficients (Bm), and elasticities are (Es=Bm X/Y).

{pmore}- In Log-Log model the transformed coefficients are elasticities, and the marginal effects are (Bm =Es Y/X).

{pmore}- Using {opt mfx(log)} requires {opt tolog} option, to trnsform variables to log form.

{col 7}{opt diag}{col 17}Model Selection Diagnostic Criteria:
		- Log Likelihood Function       LLF
		- Akaike Final Prediction Error AIC
		- Schwartz Criterion            SC
		- Akaike Information Criterion  ln AIC
		- Schwarz Criterion             ln SC
		- Amemiya Prediction Criterion  FPE
		- Hannan-Quinn Criterion        HQ
		- Rice Criterion                Rice
		- Shibata Criterion             Shibata
		- Craven-Wahba Generalized Cross Validation-GCV

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:alsmle} estimates Autoregressive Least Squares (ALS) via Maximum Likelihood Estimation (MLE), according to Beach-Mackinnon (1978) method for Autocorrelated Errors with first order AR(1).{p_end} 
{p 2 2 2} {cmd:alsmle} can also estimate weighted Autoregressive Maximum Likelihood Estimation {helpb weight}, with or without constant term.{p_end} 
{p 2 2 2} {cmd:alsmle} can compute model selection diagnostic criteria, marginal effects, and elasticities.{p_end}

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }Depending on the model estimated, {cmd:alsmle} saves the following results in {cmd:e()}:

Scalars:
{col 4}{cmd:e(N)}{col 20}number of observations
{col 4}{cmd:e(r2c)}{col 20}R-squared
{col 4}{cmd:e(r2c_a)}{col 20}Adjusted R-squared
{col 4}{cmd:e(r2u)}{col 20}Raw Moments R-squared
{col 4}{cmd:e(r2u_a)}{col 20}Raw Moments Adjusted R2
{col 4}{cmd:e(f)}{col 20}F-test
{col 4}{cmd:e(fp)}{col 20}F-test P-Value
{col 4}{cmd:e(wald)}{col 20}Wald-test
{col 4}{cmd:e(waldp)}{col 20}Wald-test P-Value
{col 4}{cmd:e(llf)}{col 20}Log Likelihood Function
{col 4}{cmd:e(aic)}{col 20}Akaike Final Prediction Error AIC
{col 4}{cmd:e(sc)}{col 20}Schwartz Criterion SC
{col 4}{cmd:e(laic)}{col 20}Akaike Information Criterion ln AIC
{col 4}{cmd:e(lsc)}{col 20}Schwarz Criterion Log SC
{col 4}{cmd:e(fpe)}{col 20}Amemiya Prediction Criterion FPE
{col 4}{cmd:e(hq)}{col 20}Hannan-Quinn Criterion HQ
{col 4}{cmd:e(shibata)}{col 20}Shibata Criterion Shibata
{col 4}{cmd:e(rice)}{col 20}Rice Criterion Rice
{col 4}{cmd:e(gcv)}{col 20}Craven-Wahba Generalized Cross Validation-GCV

Matrixes:
{col 4}{cmd:e(b)}{col 20}coefficient vector
{col 4}{cmd:e(V)}{col 20}variance-covariance matrix of the estimators
{col 4}{cmd:e(mfx)}{col 20}Beta and Marginal Effect

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Beach, Charles & James G. Mackinnon (1978)
{cmd: "A Maximum Likelihood Procedure for Regression with Autocorrelated Errors",}
{it:Econometrica, Vol. 46, No. 1, Jan.}; 51-58.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Examples}}}

  {stata clear all}

  {stata sysuse alsmle.dta, clear}

  {stata db alsmle}

  {stata alsmle y x1 x2}

  {stata alsmle y x1 x2 , iter(1)}

  {stata alsmle y x1 x2 , twostep}

  {stata alsmle y x1 x2 , iter(10)}

  {stata alsmle y x1 x2 , noconstant}

  {stata alsmle y x1 x2 , mfx(lin) log}
  
  {stata alsmle y x1 x2 [weight=x1]}

  {stata alsmle y x1 x2 [aweight=x1]}

  {stata alsmle y x1 x2 [iweight=x1]}

  {stata alsmle y x1 x2 [pweight=x1]}

  {stata alsmle y x1 x2 in 2/16 [weight=x1] , noconstant}

  {stata alsmle y x1 x2 , mfx(lin) diag predict(Yh) resid(Ue)}

  {stata alsmle y x1 x2 , mfx(log) diag tolog predict(Yh) resid(Ue)}

  {stata alsmle y x1 x2 , mfx(log) log tolog}

. clear all
. sysuse alsmle.dta, clear
. alsmle y x1 x2 , mfx(lin) diag log

==============================================================================
* Beach-Mackinnon AR(1) Autoregressive Maximum Likelihood Estimation
==============================================================================
    Iteration       Rho             LLF           SSE
    0                0.000000       -51.6471       433.3130
    1               -0.184911       -51.6645       419.9530
    2               -0.197405       -51.4007       419.7750
    3               -0.197972       -51.3972       419.7692
    4               -0.197997       -51.3971       419.7691
------------------------------------------------------------------------------
  Number of Obs    =         17
  Wald Test        =   457.1243         P-Value > Chi2(2)        =     0.0000
  F Test           =   228.5621         P-Value > F(2 , 14)      =     0.0000
  R-squared        =     0.9528         Raw Moments R2           =     0.9987
  R-squared Adj    =     0.9461         Raw Moments R2 Adj       =     0.9985
  Root MSE (Sigma) =     5.4757         Log Likelihood Function  =   -51.3971
  Autoregressive Coefficient (Rho) Value = -0.1979982
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   1.065033   .2067004     5.15   0.000     .6217044    1.508361
          x2 |  -1.375032   .0643558   -21.37   0.000    -1.513061   -1.237002
       _cons |   129.6105   20.87587     6.21   0.000     84.83621    174.3848
------------------------------------------------------------------------------

==============================================================================
* Model Selection Diagnostic Criteria
==============================================================================
  Log Likelihood Function       LLF             =    -51.3971
  Akaike Final Prediction Error AIC             =     32.3009
  Schwartz Criterion            SC              =     35.6275
  Akaike Information Criterion  ln AIC          =      3.4751
  Schwarz Criterion             ln SC           =      3.5731
  Amemiya Prediction Criterion  FPE             =     34.6460
  Hannan-Quinn Criterion        HQ              =     32.6171
  Rice Criterion                Rice            =     33.3836
  Shibata Criterion             Shibata         =     31.5353
  Craven-Wahba Generalized Cross Validation GCV =     32.7901
---------------------------------------------------------------

* Linear: Marginal Effect - Elasticity

+-----------------------------------------------------------------------------+
|     Variable | Marginal_Effect(B) |     Elasticity(Es) |               Mean |
|--------------+--------------------+--------------------+--------------------|
|           x1 |             1.0650 |             0.8154 |           102.9824 |
|           x2 |            -1.3750 |            -0.7801 |            76.3118 |
+-----------------------------------------------------------------------------+
 Mean of Dependent Variable =   134.5059

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:Acknowledgment}}}

  I would like to thank Professor James G. Mackinnon
  for sending to me his reference paper (1978)

{marker 08}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:alsmle Citation}}}

{phang}Emad Abd Elmessih Shehata (2012){p_end}
{phang}{cmd:ALSMLE: "Stata Module to Estimate Beach-Mackinnon First Order AR(1) Autoregressive Maximum Likelihood Estimation"}{p_end}

{title:Online Help:}

{p 2 12 2}Official: {helpb regress}, {helpb prais}.{p_end}

{psee}
{p_end}

