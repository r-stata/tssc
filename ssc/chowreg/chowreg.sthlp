{smcl}
{hline}
{cmd:help: {helpb chowreg}}{space 50} {cmd:dialog:} {bf:{dialog chowreg}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:chowreg: Structural Change Regressions and Chow Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb chowreg##01:Syntax}{p_end}
{p 5}{helpb chowreg##02:Options}{p_end}
{p 5}{helpb chowreg##03:Description}{p_end}
{p 5}{helpb chowreg##04:Saved Results}{p_end}
{p 5}{helpb chowreg##05:References}{p_end}

{p 1}*** {helpb chowreg##06:Examples}{p_end}

{p 5}{helpb chowreg##07:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 2 4 2} 
{opt chowreg} {depvar} {indepvars} {ifin} {weight} , {opt d:um(#)} [ {opt t:ype(#)} {opt nocons:tant} {opth vce(vcetype)}]{p_end} 

{marker 02}{bf:{err:{dlgtab:Options}}}

{synoptset 16}{...}
{synopt:{bf:type({err:{it:1, 2, 3}})}}Functional Form Dummy Variables Type{p_end}

	(1) Y = X + D0
	(2) Y = X + DX
	(3) Y = X + D0 + DX
	where:
	D0 = Dummy variable (0,1), takes (0) in first period, and (1) in second period.
	DX = Cross product of each Xi times in D0

{synopt:{bf:dum({err:{it:#}})}}Number of First Period Observations{p_end}

{synopt:{opt nocons:tant}}Exclude Constant Term{p_end}

{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:chowreg} Estimates structural change regressions and compute Chow test"}{p_end}

{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:chowreg} saves the following in {cmd:r()}:

{col 4}{cmd:r(chow)}{col 20}Chow Test
{col 4}{cmd:r(chowp)}{col 20}Chow Test P-Value
{col 4}{cmd:r(fisher)}{col 20}Fisher Test
{col 4}{cmd:r(fisherp)}{col 20}Fisher Test P-Value
{col 4}{cmd:r(wald)}{col 20}Wald Test
{col 4}{cmd:r(waldp)}{col 20}Wald Test P-Value
{col 4}{cmd:r(lr)}{col 20}Likelihood Ratio Test
{col 4}{cmd:r(lrp)}{col 20}Likelihood Ratio Test P-Value
{col 4}{cmd:r(lm)}{col 20}Lagrange Multiplier Test
{col 4}{cmd:r(lmp)}{col 20}Lagrange Multiplier Test P-Value

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA}.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Upper Saddle River, NJ: Prentice-Hall}.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}.

{marker 06}{bf:{err:{dlgtab:Examples}}}

	 {stata clear all}

 	{stata sysuse chowreg.dta , clear}

 	{stata db chowreg}

 	{stata chowreg y x1 x2 , dum(9) type(1)}
 	{stata chowreg y x1 x2 , dum(9) type(2)}
 	{stata chowreg y x1 x2 , dum(9) type(3)}
{hline}

. clear all
. sysuse chowreg.dta , clear
. chowreg y x1 x2 , dum(9) type(1)

==============================================================================
* Structural Change Regression *
==============================================================================

      Source |       SS       df       MS              Number of obs =      17
-------------+------------------------------           F(  3,    13) =   86.07
       Model |  8467.92983     3  2822.64328           Prob > F      =  0.0000
    Residual |  426.320328    13  32.7938714           R-squared     =  0.9521
-------------+------------------------------           Adj R-squared =  0.9410
       Total |  8894.25016    16  555.890635           Root MSE      =  5.7266

------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   .9479218   .3688768     2.57   0.023     .1510118    1.744832
          x2 |  -1.483711   .2345698    -6.33   0.000    -1.990468   -.9769534
          D0 |   -3.91322   8.474379    -0.46   0.652      -22.221    14.39456
       _cons |   151.9528   53.80284     2.82   0.014      35.7188    268.1867
------------------------------------------------------------------------------

 ( 1)  D0 = 0

       F(  1,    13) =    0.21
            Prob > F =    0.6519
==============================================================================
* Structural Change Test: Y = X + D0 *
==============================================================================
  Ho: no Structural Change
- Chow Test                =    0.2132      P-Value > F(1 , 13)   0.6519

. chowreg y x1 x2 , dum(9) type(2)

==============================================================================
* Structural Change Regression *
==============================================================================

      Source |       SS       df       MS              Number of obs =      17
-------------+------------------------------           F(  4,    12) =   78.86
       Model |  8568.30591     4  2142.07648           Prob > F      =  0.0000
    Residual |  325.944251    12  27.1620209           R-squared     =  0.9634
-------------+------------------------------           Adj R-squared =  0.9511
       Total |  8894.25016    16  555.890635           Root MSE      =  5.2117

------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   .9828138   .3162965     3.11   0.009     .2936629    1.671965
          x2 |   -1.35305   .2050101    -6.60   0.000    -1.799729   -.9063713
       Dx_x1 |   .6241894    .334729     1.86   0.087    -.1051225    1.353501
       Dx_x2 |  -1.029671   .5229864    -1.97   0.073    -2.169161    .1098183
       _cons |   136.4496   45.26946     3.01   0.011     37.81594    235.0833
------------------------------------------------------------------------------

 ( 1)  Dx_x1 = 0
 ( 2)  Dx_x2 = 0

       F(  2,    12) =    1.98
            Prob > F =    0.1812
==============================================================================
* Structural Change Test: Y = X + DX *
==============================================================================
  Ho: no Structural Change
- Chow Test                =    1.9765      P-Value > F(2 , 12)   0.1812

. chowreg y x1 x2 , dum(9) type(3)

==============================================================================
* Structural Change Regression *
==============================================================================

      Source |       SS       df       MS              Number of obs =      17
-------------+------------------------------           F(  5,    11) =   75.75
       Model |  8643.23205     5  1728.64641           Prob > F      =  0.0000
    Residual |  251.018117    11  22.8198288           R-squared     =  0.9718
-------------+------------------------------           Adj R-squared =  0.9589
       Total |  8894.25016    16  555.890635           Root MSE      =   4.777

------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   .3623291   .4486735     0.81   0.436    -.6251947    1.349853
          x2 |  -1.683503   .2618556    -6.43   0.000    -2.259843   -1.107162
          D0 |  -154.5432    85.2883    -1.81   0.097    -342.2615    33.17507
       Dx_x1 |   1.732067   .6840704     2.53   0.028     .2264386    3.237696
       Dx_x2 |  -.5282025   .5535151    -0.95   0.360    -1.746481    .6900761
       _cons |   231.5499   66.90452     3.46   0.005     84.29409    378.8058
------------------------------------------------------------------------------

 ( 1)  D0 = 0
 ( 2)  Dx_x1 = 0
 ( 3)  Dx_x2 = 0

       F(  3,    11) =    2.66
            Prob > F =    0.0998
==============================================================================
* Structural Change Tests:  Y = X + D0 + DX
==============================================================================
  Ho: no Structural Change

- Chow Test   [K, N-2*K]   =    2.6628      P-Value > F(3 , 11)   0.0998
- Fisher Test [N2,(N1-K)]  =    4.5197      P-Value > F(8 , 6)    0.0412
- Wald Test                =   12.3458      P-Value > Chi2(8)     0.0021
- Likelihood Ratio Test    =    9.2809      P-Value > Chi2(8)     0.0097
- Lagrange Multiplier Test =    7.1519      P-Value > Chi2(8)     0.0280


{marker 07}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:CHOWREG Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:CHOWREG: "Structural Change Regressions and Chow Test"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457383.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457383.htm"}


{title:Online Help:}

{bf:{err:* Econometric Regression Models:}}

{bf:{err:* (1) (OLS) * Ordinary Least Squares Regression Models:}}
{helpb olsreg}{col 12}OLS Econometric Ridge & Weighted Regression Models: Stata Module Toolkit
{helpb ridgereg}{col 12}OLS Ridge Regression Models
{helpb gmmreg}{col 12}OLS Generalized Method of Moments (GMM): Ridge & Weighted Regression
{helpb chowreg}{col 12}OLS Structural Change Regressions and Chow Test
---------------------------------------------------------------------------
{bf:{err:* (2) (2SLS-IV) * Two-Stage Least Squares & Instrumental Variables Regression Models:}}
{helpb reg2}{col 12}2SLS-IV Econometric Ridge & Weighted Regression Models: Stata Module Toolkit
{helpb gmmreg2}{col 12}2SLS-IV Generalized Method of Moments (GMM): Ridge & Weighted Regression
{helpb limlreg2}{col 12}Limited-Information Maximum Likelihood (LIML) IV Regression
{helpb meloreg2}{col 12}Minimum Expected Loss (MELO) IV Regression
{helpb ridgereg2}{col 12}Ridge 2SLS-LIML-GMM-MELO-Fuller-kClass IV Regression
{helpb ridge2sls}{col 12}Two-Stage Least Squares Ridge Regression
{helpb ridgegmm}{col 12}Generalized Method of Moments (GMM) IV Ridge Regression
{helpb ridgeliml}{col 12}Limited-Information Maximum Likelihood (LIML) IV Ridge Regression
{helpb ridgemelo}{col 12}Minimum Expected Loss (MELO) IV Ridge Regression
---------------------------------------------------------------------------
{bf:{err:* (3) * Panel Data Regression Models:}}
{helpb regxt}{col 12}Panel Data Econometric Ridge & Weighted Regression Models: Stata Module Toolkit
{helpb xtregdhp}{col 12}Han-Philips (2010) Linear Dynamic Panel Data Regression
{helpb xtregam}{col 12}Amemiya Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregbem}{col 12}Between-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregbn}{col 12}Balestra-Nerlove Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregfem}{col 12}Fixed-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregmle}{col 12}Trevor Breusch MLE Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregrem}{col 12}Fuller-Battese GLS Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregsam}{col 12}Swamy-Arora Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregwem}{col 12}Within-Effects Panel Data: Ridge & Weighted Regression
{helpb xtregwhm}{col 12}Wallace-Hussain Random-Effects Panel Data: Ridge & Weighted Regression
{helpb xtreghet}{col 12}MLE Random-Effects Multiplicative Heteroscedasticity Panel Data Regression
---------------------------------------------------------------------------
{bf:{err:* (4) (MLE) * Maximum Likelihood Estimation Regression Models:}}
{helpb mlereg}{col 12}MLE Econometric Regression Models: Stata Module Toolkit
{helpb mleregn}{col 12}MLE Normal Regression
{helpb mleregln}{col 12}MLE Log Normal Regression
{helpb mlereghn}{col 12}MLE Half Normal Regression
{helpb mlerege}{col 12}MLE Exponential Regression
{helpb mleregle}{col 12}MLE Log Exponential Regression
{helpb mleregg}{col 12}MLE Gamma Regression
{helpb mlereglg}{col 12}MLE Log Gamma Regression
{helpb mlereggg}{col 12}MLE Generalized Gamma Regression
{helpb mlereglgg}{col 12}MLE Log Generalized Gamma Regression
{helpb mleregb}{col 12}MLE Beta Regression
{helpb mleregev}{col 12}MLE Extreme Value Regression
{helpb mleregw}{col 12}MLE Weibull Regression
{helpb mlereglw}{col 12}MLE Log Weibull Regression
{helpb mleregilg}{col 12}MLE Inverse Log Gauss Regression
---------------------------------------------------------------------------
{bf:{err:* (5) * Autocorrelation Regression Models:}}
{helpb autoreg}{col 12}Autoregressive Least Squares Regression Models: Stata Module Toolkit
{helpb alsmle}{col 12}Beach-Mackinnon AR(1) Autoregressive Maximum Likelihood Estimation Regression
{helpb automle}{col 12}Beach-Mackinnon AR(1) Autoregressive Maximum Likelihood Estimation Regression
{helpb autopagan}{col 12}Pagan AR(p) Conditional Autoregressive Least Squares Regression
{helpb autoyw}{col 12}Yule-Walker AR(p) Unconditional Autoregressive Least Squares Regression
{helpb autopw}{col 12}Prais-Winsten AR(p) Autoregressive Least Squares Regression
{helpb autoco}{col 12}Cochrane-Orcutt AR(p) Autoregressive Least Squares Regression
{helpb autofair}{col 12}Fair AR(1) Autoregressive Least Squares Regression
---------------------------------------------------------------------------
{bf:{err:* (6) * Heteroscedasticity Regression Models:}}
{helpb hetdep}{col 12}MLE Dependent Variable Heteroscedasticity
{helpb hetmult}{col 12}MLE Multiplicative Heteroscedasticity Regression
{helpb hetstd}{col 12}MLE Standard Deviation Heteroscedasticity Regression
{helpb hetvar}{col 12}MLE Variance Deviation Heteroscedasticity Regression
{helpb glsreg}{col 12}Generalized Least Squares Regression
---------------------------------------------------------------------------
{bf:{err:* (7) * Non Normality Regression Models:}}
{helpb robgme}{col 12}MLE Robust Generalized Multivariate Error t Distribution
{helpb bcchreg}{col 12}Classical Box-Cox Multiplicative Heteroscedasticity Regression
{helpb bccreg}{col 12}Classical Box-Cox Regression
{helpb bcereg}{col 12}Extended Box-Cox Regression
---------------------------------------------------------------------------
{bf:{err:* (8) (NLS) * Nonlinear Least Squares Regression Regression Models:}}
{helpb autonls}{col 12}Non Linear Autoregressive Least Squares Regression
{helpb qregnls}{col 12}Non Linear Quantile Regression
---------------------------------------------------------------------------
{bf:{err:* (9) * Logit Regression Models:}}
{helpb logithetm}{col 12}Logit Multiplicative Heteroscedasticity Regression
{helpb mnlogit}{col 12}Multinomial Logit Regression
---------------------------------------------------------------------------
{bf:{err:* (10) * Probit Regression Models:}}
{helpb probithetm}{col 12}Probit Multiplicative Heteroscedasticity Regression
{helpb mnprobit}{col 12}Multinomial Probit Regression
---------------------------------------------------------------------------
{bf:{err:* (11) * Tobit Regression Models:}}
{helpb tobithetm}{col 12}Tobit Multiplicative Heteroscedasticity Regression 
---------------------------------------------------------------------------

{psee}
{p_end}


