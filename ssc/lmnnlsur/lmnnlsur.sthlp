{smcl}
{hline}
{cmd:help: {helpb lmnnlsur}}{space 55} {cmd:dialog:} {bf:{dialog lmnnlsur}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmnnlsur: Overall System NL-SUR Non Normality Tests}

{bf:{err:{dlgtab:Syntax}}}

     {cmd: lmnnlsur}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}lmnnlsur computes Overall System NL-SUR Non Normality Tests, after:{p_end}
{p 2 2 2}- (NL-SUR) Non-Linear Seemingly Unrelated Regression Estimation {helpb nlsur} for sets of equations.{p_end}

{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmnnlsur} saves the following in {cmd:r()}:

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

 {stata clear all}

 {stata sysuse lmnnlsur.dta , clear}

* (1) NL-SUR Model:

 {stata nlsur (y1={B10}+{B11}*y2+{B12}*x1+{B13}*x2) (y2={B20}+{B21}*y1+{B22}*x3+{B23}*x4)}

 {stata lmnnlsur}

 {stata return list}

* (2) SUR Model:

 {stata sureg (y1 y2 x1 x2) (y2 y1 x3 x4)}

 {stata lmnnlsur}

 {stata return list}

. clear all
. sysuse lmnnlsur.dta , clear
. nlsur (y1={B10}+{B11}*y2+{B12}*x1+{B13}*x2) (y2={B20}+{B21}*y1+{B22}*x3+{B23}*x4)

FGNLS regression 
---------------------------------------------------------------------
       Equation |       Obs  Parms       RMSE      R-sq     Constant
----------------+----------------------------------------------------
 1           y1 |        20      4   125.6433    0.8266          B10
 2           y2 |        20      4   19.52663    0.7801          B20
---------------------------------------------------------------------

------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        /B10 |  -68.61381   119.3219    -0.58   0.565    -302.4804    165.2528
        /B11 |   6.586666   .6994811     9.42   0.000     5.215708    7.957623
        /B12 |   .0771727   .0496441     1.55   0.120     -.020128    .1744733
        /B13 |  -.3247027   .2355698    -1.38   0.168    -.7864111    .1370056
        /B20 |    11.0109   24.11753     0.46   0.648    -36.25859    58.28038
        /B21 |    .137451   .0141117     9.74   0.000     .1097926    .1651094
        /B22 |  -.0018792   .0116164    -0.16   0.871    -.0246469    .0208885
        /B23 |  -.0024405   .0142685    -0.17   0.864    -.0304061    .0255252
------------------------------------------------------------------------------

. lmnnlsur
==============================================================================
* System NL-SUR Non Normality Tests
==============================================================================
*** Single Equation Non Normality Tests:
  Ho: Normality - Ha: Non Normality

 Eq. 1     : Jarque-Bera LM Test   =   1.5868        P-Value > Chi2(2)  0.4523
 Eq. 2     : Jarque-Bera LM Test   =   2.3209        P-Value > Chi2(2)  0.3133
------------------------------------------------------------------------------

==============================================================================
*** Overall System NL-SUR Non Normality Tests:
 Ho: No Overall System Non Normality
------------------------------------------------------------------------------
*** Non Normality Tests:
- Jarque-Bera LM Test                  =  33.3557     P-Value > Chi2(2) 0.0000
- Doornik-Hansen LM Test               =  22.9825     P-Value > Chi2(2) 0.0000
- Geary LM Test                        =  -0.9475     P-Value > Chi2(2) 0.6227
- Anderson-Darling Z Test              =   1.8507     P > Z( 3.693)     0.9999
- D'Agostino-Pearson LM Test           =  15.0782     P-Value > Chi2(2) 0.0005
------------------------------------------------------------------------------
*** Skewness Tests:
- Srivastava LM Skewness Test          =   4.0267     P-Value > Chi2(1) 0.0448
- Small LM Skewness Test               =   4.4539     P-Value > Chi2(1) 0.0348
- Skewness Z Test                      =  -2.1104     P-Value > Chi2(1) 0.0348
------------------------------------------------------------------------------
*** Kurtosis Tests:
- Srivastava  Z Kurtosis Test          =   5.4156     P-Value > Z(0,1)  0.0000
- Small LM Kurtosis Test               =  10.6242     P-Value > Chi2(1) 0.0011
- Kurtosis Z Test                      =   3.2595     P-Value > Chi2(1) 0.0011
------------------------------------------------------------------------------
    Skewness Coefficient = -0.7772     - Standard Deviation =  0.3738
    Kurtosis Coefficient =  7.1949     - Standard Deviation =  0.7326
------------------------------------------------------------------------------
    Runs Test: (18) Runs -  (19) Positives - (21) Negatives
    Standard Deviation Runs Sig(k) =  3.1135 , Mean Runs E(k) = 20.9500
    95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (14.8476 , 27.0524 )
------------------------------------------------------------------------------

{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:lmnnlsur Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:LMNNLSUR: "Overall System NL-SUR Non Normality Tests"}{p_end}

{title:Online Help:}

{p 2 10 2}
{helpb lmanlsur}, {helpb lmhnlsur}, {helpb lmnnlsur}, {helpb lmcovnlsur}, {helpb r2nlsur}{p_end}
{p 2 10 2}
{helpb lmareg3}, {helpb lmhreg3}, {helpb lmnreg3}, {helpb lmcovreg3}, {helpb r2reg3}{p_end}
{p 2 10 2}
{helpb lmasem}, {helpb lmhsem}, {helpb lmnsem}, {helpb lmcovsem}, {helpb r2sem}. {opt (if installed)}.{p_end}

{psee}
{p_end}

