{smcl}
{hline}
{cmd:help: {helpb lmnreg3}}{space 55} {cmd:dialog:} {bf:{dialog lmnreg3}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmnreg3: Overall System Non Normality Tests after (3SLS-SURE) Regressions}

{bf:{err:{dlgtab:Syntax}}}

     {cmd: lmnreg3}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}lmnreg3 computes overall system Non Normality Tests, after:{p_end}
{p 2 2 2}- (3SLS) Three-Stage Least Squares {helpb reg3} for systems of simultaneous equations.{p_end}
{p 2 2 2}- (SURE) Seemingly Unrelated Regression Estimation {helpb sureg} for sets of equations.{p_end}

{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmnreg3} saves the following in {cmd:r()}:

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

	{stata sysuse lmnreg3.dta , clear}

   * (1) SUR Model:

	{stata sureg (y1 x1 z1) (y2 x2 z2) (y3 x3 z3) (y4 x4 z4)}

	{stata lmnreg3}

	{stata return list}


   * (2) 3SLS Model:

	{stata reg3 (y1 x1 z1) (y2 x2 z2) (y3 x3 z3) (y4 x4 z4)}

	{stata lmnreg3}

	{stata return list}

* If you want to use dialog box: Press OK to compute lmnreg3

	{stata db lmnreg3}


. clear all
. sysuse lmnreg3.dta , clear
. reg3 (y1 x1 z1) (y2 x2 z2) (y3 x3 z3) (y4 x4 z4)
. lmnreg3

=================================================
* System Non Normality Tests (3sls) 
=================================================
*** Single Equation Non Normality Tests:
  Ho: Normality - Ha: Non Normality

 Eq. y1    : Jarque-Bera LM Test   =   1.4515        P-Value > Chi2(2)  0.4840
 Eq. y2    : Jarque-Bera LM Test   =  18.1562        P-Value > Chi2(2)  0.0001
 Eq. y3    : Jarque-Bera LM Test   =   2.0054        P-Value > Chi2(2)  0.3669
 Eq. y4    : Jarque-Bera LM Test   =   0.8628        P-Value > Chi2(2)  0.6496
------------------------------------------------------------------------------

*** Overall System Non Normality Tests:
 Ho: No Overall System Non Normality

*** Non Normality Tests:
- Jarque-Bera LM Test              =   2.3287        P-Value > Chi2(2)  0.3121
- Doornik-Hansen LM Test           =   3.2725        P-Value > Chi2(2)  0.1947
- Geary LM Test                    =  -2.2504        P-Value > Chi2(2)  0.3246
- Anderson-Darling Z Test          =   0.5028        P-Value>Z( 3.409)  0.9997
- D'Agostino-Pearson LM Test       =   3.0259        P-Value > Chi2(2)  0.2203
------------------------------------------------------------------------------
*** Skewness Tests:
- Srivastava LM Skewness Test      =   1.0859        P-Value > Chi2(1)  0.2974
- Small LM Skewness Test           =   1.2242        P-Value > Chi2(1)  0.2685
- Skewness Z Test                  =  -1.1064        P-Value > Chi2(1)  0.2685
------------------------------------------------------------------------------
*** Kurtosis Tests:
- Srivastava Z Kurtosis Test       =   1.1148        P-Value > Z(0,1)   0.2649
- Small LM Kurtosis Test           =   1.8017        P-Value > Chi2(1)  0.1795
- Kurtosis Z Test                  =   1.3423        P-Value > Chi2(1)  0.0898
------------------------------------------------------------------------------
    Skewness Coefficient =   -0.2854     - Standard Deviation =  0.2689
    Kurtosis Coefficient =    3.6106     - Standard Deviation =  0.5318
------------------------------------------------------------------------------
    Runs Test: (31) Runs -  (40) Positives - (40) Negatives
    Standard Deviation Runs Sig(k) =  4.4437 , Mean Runs E(k) = 41.0000
    95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (32.2903 , 49.7097 )
------------------------------------------------------------------------------

{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:lmnreg3 Citation}}}

{phang}Shehata, Emad Abd Elmessih (2011){p_end}
{phang}{cmd: "LMNREG: Stata Module to Compute Overall System Non Normality Tests after (3SLS-SURE) Regressions"}{p_end}

{title:Online Help:}

{p 4 12 2}
{helpb lmnreg} {helpb lmnreg2} {helpb lmnreg3} {opt (if installed)}.{p_end}

{psee}
{p_end}

