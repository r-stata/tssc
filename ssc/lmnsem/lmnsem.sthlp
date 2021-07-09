{smcl}
{hline}
{cmd:help: {helpb lmnsem}}{space 55} {cmd:dialog:} {bf:{dialog lmnsem}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmnsem: Overall System Non Normality Tests after (SEM) Regressions}

{bf:{err:{dlgtab:Syntax}}}

     {cmd: lmnsem}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}lmnsem computes overall system Non Normality Tests, after:{p_end}
{p 2 2 2}- (SEM) Structural Equation Modeling Regressions {helpb sem} for system of simultaneous equations.{p_end}

{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmnsem} saves the following in {cmd:r()}:

{synoptset 12 tabbed}{...}
{p2col 5 12 12 2: Scalars}{p_end}

{col 4}{cmd:r(lmnjb_#)}{col 20}Jarque-Bera LM Test for eq.# 
{col 4}{cmd:r(lmnjbp_#)}{col 20}Jarque-Bera LM Test for eq.# P-Value

{col 4}{cmd:r(lmnjb)}{col 20}Jarque-Bera LM Test
{col 4}{cmd:r(lmnjbp)}{col 20}Jarque-Bera LM Test P-Value
{col 4}{cmd:r(lmndh)}{col 20}Doornik-Hansen LM Test
{col 4}{cmd:r(lmndhp)}{col 20}Doornik-Hansen LM Test P-Value
{col 4}{cmd:r(lmng)}{col 20}Geary LM Test
{col 4}{cmd:r(lmngp)}{col 20}Geary LM Test P-Value
{col 4}{cmd:r(lmnad)}{col 20}Anderson-Darling Z Test
{col 4}{cmd:r(lmnadp)}{col 20}Anderson-Darling Z Test P-Value
{col 4}{cmd:r(lmndp)}{col 20}D'Agostino-Pearson LM Test
{col 4}{cmd:r(lmndpp)}{col 20}D'Agostino-Pearson LM Test P-Value
{col 4}{cmd:r(lmnsvs)}{col 20}Srivastava LM Skewness Test
{col 4}{cmd:r(lmnsvsp)}{col 20}Srivastava LM Skewness Test P-Value
{col 4}{cmd:r(lmnsms1)}{col 20}Small LM Skewness Test
{col 4}{cmd:r(lmnsms1p)}{col 20}Small LM Skewness Test P-Value
{col 4}{cmd:r(lmnsms2)}{col 20}Skewness Z Test
{col 4}{cmd:r(lmnsms2p)}{col 20}Skewness Z Test P-Value
{col 4}{cmd:r(lmnsvk)}{col 20}Srivastava Z Kurtosis Test
{col 4}{cmd:r(lmnsvkp)}{col 20}Srivastava Z Kurtosis Test P-Value
{col 4}{cmd:r(lmnsmk1)}{col 20}Small LM Kurtosis Test
{col 4}{cmd:r(lmnsmk1p)}{col 20}Small LM Kurtosis Test P-Value
{col 4}{cmd:r(lmnsmk2)}{col 20}Kurtosis Z Test
{col 4}{cmd:r(lmnsmk2p)}{col 20}Kurtosis Z Test P-Value
{col 4}{cmd:r(sk)}{col 20}Skewness Coefficient
{col 4}{cmd:r(sksd)}{col 20}Skewness Standard Deviation
{col 4}{cmd:r(ku)}{col 20}Kurtosis Coefficient
{col 4}{cmd:r(kusd)}{col 20}Kurtosis Standard Deviation
{col 4}{cmd:r(sn)}{col 20}Standard Deviation Runs Sig(k)
{col 4}{cmd:r(en)}{col 20}Mean Runs E(k)
{col 4}{cmd:r(lower)}{col 20}Lower 95% Conf. Interval [E(k)- 1.96* Sig(k)]
{col 4}{cmd:r(upper)}{col 20}Upper 95% Conf. Interval [E(k)+ 1.96* Sig(k)]

{bf:{err:{dlgtab:References}}}

{p 4 8 2}Anderson T.W., Darling D.A. (1954)
{cmd: "A Test of Goodness of Fit",}
{it:Journal of the American Statisical Association, 49}; 765–69. 

{p 4 8 2}C.M. Jarque  & A.K. Bera (1987)
{cmd: "A Test for Normality of Observations and Regression Residuals"}
{it:International Statistical Review} , Vol. 55; 163-172.

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

{p 4 8 2}Pearson, E. S., D'Agostino, R. B., & Bowman, K. O. (1977)
{cmd: "Tests for Departure from Normality: Comparison of Powers",}
{it:Biometrika, 64(2)}; 231-246.

{bf:{err:{dlgtab:Examples}}}

 in this example FIML will be used as follows:

	{stata clear all}

	{stata sysuse lmnsem.dta , clear}

	{stata sem (y1 <- y2 x1 x2) (y2 <- y1 x3 x4), cov(e.y1*e.y2)}

	{stata lmnsem}

	{stata return list}

* If you want to use dialog box: Press OK to compute lmnsem

	{stata db lmnsem}

. clear all
. sysuse lmnsem.dta , clear
. sem (y1 <- y2 x1 x2) (y2 <- y1 x3 x4), cov(e.y1*e.y2)

Structural equation model                       Number of obs      =        17
Estimation method  = ml
Log likelihood     = -363.34588
------------------------------------------------------------------------------
             |                 OIM
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
Structural   |
  y1 <-      |
          y2 |   .2425937   .2106232     1.15   0.249    -.1702201    .6554075
          x1 |   .2568409    .462485     0.56   0.579     -.649613    1.163295
          x2 |  -1.037016   .3154059    -3.29   0.001      -1.6552   -.4188317
       _cons |   147.0826    54.4491     2.70   0.007     40.36431    253.8009
  -----------+----------------------------------------------------------------
  y2 <-      |
          y1 |  -.6282929   .6148239    -1.02   0.307    -1.833326    .5767398
          x3 |  -.5226661   .3235637    -1.62   0.106    -1.156839    .1115071
          x4 |     3.4208   1.440664     2.37   0.018     .5971513    6.244449
       _cons |   62.44495   42.36071     1.47   0.140    -20.58052    145.4704
-------------+----------------------------------------------------------------
Variance     |
        e.y1 |   80.17577   28.99122                      39.46865    162.8673
        e.y2 |   142.4478   80.80501                      46.86006    433.0208
-------------+----------------------------------------------------------------
Covariance   |
  e.y1       |
        e.y2 |   25.62619   53.75243     0.48   0.634    -79.72665     130.979
------------------------------------------------------------------------------
LR test of model vs. saturated: chi2(2)   =      0.12, Prob > chi2 = 0.9408

. lmnsem

=================================================
* System Non Normality Tests (ml) 
=================================================
*** Single Equation Non Normality Tests:
  Ho: Normality - Ha: Non Normality

 Eq. 1     : Jarque-Bera LM Test   =   2.6232        P-Value > Chi2(2)  0.2694
 Eq. 2     : Jarque-Bera LM Test   =   2.2936        P-Value > Chi2(2)  0.3177
------------------------------------------------------------------------------

*** Overall System Non Normality Tests:
 Ho: No Overall System Non Normality

*** Non Normality Tests:
- Jarque-Bera LM Test              =   5.4681        P-Value > Chi2(2)  0.0650
- Doornik-Hansen LM Test           =   4.9476        P-Value > Chi2(2)  0.0843
- Geary LM Test                    =   0.4365        P-Value > Chi2(2)  0.8039
- Anderson-Darling Z Test          =  -0.4223        P-Value>Z( 1.361)  0.9133
- D'Agostino-Pearson LM Test       =   7.0244        P-Value > Chi2(2)  0.0298
------------------------------------------------------------------------------
*** Skewness Tests:
- Srivastava LM Skewness Test      =   4.4358        P-Value > Chi2(1)  0.0352
- Small LM Skewness Test           =   4.9358        P-Value > Chi2(1)  0.0263
- Skewness Z Test                  =  -2.2217        P-Value > Chi2(1)  0.0263
------------------------------------------------------------------------------
*** Kurtosis Tests:
- Srivastava Z Kurtosis Test       =   1.0160        P-Value > Z(0,1)   0.3096
- Small LM Kurtosis Test           =   2.0887        P-Value > Chi2(1)  0.1484
- Kurtosis Z Test                  =   1.4452        P-Value > Chi2(1)  0.0742
------------------------------------------------------------------------------
    Skewness Coefficient =   -0.8848     - Standard Deviation =  0.4031
    Kurtosis Coefficient =    3.8536     - Standard Deviation =  0.7879
------------------------------------------------------------------------------
    Runs Test: (19) Runs -  (19) Positives - (15) Negatives
    Standard Deviation Runs Sig(k) =  2.8300 , Mean Runs E(k) = 17.7647
    95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (12.2179 , 23.3115 )
------------------------------------------------------------------------------

{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:lmnsem Citation}}}

{phang}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{phang}{cmd:LMNSEM: "Stata Module to Compute Overall System Non Normality Tests after Structural Equation Modeling (SEM) Regressions"}{p_end}

{title:Online Help:}

{p 2 10 2}
{helpb lmasem}, {helpb lmhsem}, {helpb lmnsem}, {helpb lmcovsem}, {helpb r2sem},{p_end}
{p 2 10 2}
{helpb lmareg3}, {helpb lmhreg3}, {helpb lmnreg3}, {helpb lmcovreg3}, {helpb r2reg3}. {opt (if installed)}.{p_end}

{psee}
{p_end}

