{smcl}
{hline}
{cmd:help: {helpb lmcol}}{space 50} {cmd:dialog:} {bf:{dialog lmcol}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmcol: OLS Multicollinearity Diagnostic Tests}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmcol##01:Syntax}{p_end}
{p 5}{helpb lmcol##02:Description}{p_end}
{p 5}{helpb lmcol##03:Options}{p_end}
{p 5}{helpb lmcol##04:References}{p_end}

{p 1}*** {helpb lmcol##05:Examples}{p_end}

{p 5}{helpb lmcol##06:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{cmd:lmcol} {depvar} {it:{help varlist:indepvars}} {ifin} , {err: [} {opt nocons:tant} {opt coll} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Options}}}
{synoptset 16}{...}

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.


{marker 03}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:lmcol} computes OLS Multicollinearity Diagnostic Tests

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

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

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

{marker 04}{bf:{err:{dlgtab:References}}}

{p 4 8 2}D. Belsley (1991)
{cmd: "Conditioning Diagnostics, Collinearity and Weak Data in Regression",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}D. Belsley, E. Kuh, and R. Welsch (1980)
{cmd: "Regression Diagnostics: Identifying Influential Data and Sources of Collinearity",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}Evagelia, Mitsaki (2011)
{cmd: "Ridge Regression Analysis of Collinear Data",}
{browse "http://www.stat-athens.aueb.gr/~jpan/diatrives/Mitsaki/chapter2.pdf"}

{p 4 8 2}Farrar, D. and Glauber, R. (1976)
{cmd: "Multicollinearity in Regression Analysis: the Problem Revisited",}
{it:Review of Economics and Statistics, 49}; 92-107.

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA}; 616-618.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Upper Saddle River, NJ: Prentice-Hall}; 387-388.

{p 4 8 2}Griffiths, W., R. Carter Hill & George Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}; 602-606.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 615.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}; 358-366.

{p 4 8 2}Marquardt D.W. (1970)
{cmd: "Generalized Inverses, Ridge Regression, Biased Linear Estimation, and Nonlinear Estimation",}
{it:Technometrics, 12}; 591-612.

{p 4 8 2}Rencher, Alvin C. (1998)
{cmd: "Multivariate Statistical Inference and Applications",}
{it:John Wiley & Sons, Inc., New York, USA}; 21-22.

{p 4 8 2}Theil, Henri (1971)
{cmd: "Principles of Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}William E. Griffiths, R. Carter Hill and George G. Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.  

{marker 05}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse lmcol.dta , clear}

 {stata db lmcol}

 {stata lmcol y x1 x2 x3}
{hline}

. clear all
. sysuse lmcol.dta , clear
. lmcol y x1 x2 x3

==============================================================================
* Ordinary Least Squares (OLS)
==============================================================================
  y = x1 + x2 + x3
------------------------------------------------------------------------------
  Sample Size       =          17
  Wald Test         =    253.9319   |   P-Value > Chi2(3)       =      0.0000
  F-Test            =     84.6440   |   P-Value > F(3 , 13)     =      0.0000
 (Buse 1973) R2     =      0.9513   |   Raw Moments R2          =      0.9986
 (Buse 1973) R2 Adj =      0.9401   |   Raw Moments R2 Adj      =      0.9983
  Root MSE (Sigma)  =      5.7724   |   Log Likelihood Function =    -51.6441
------------------------------------------------------------------------------
- R2h= 0.9513   R2h Adj= 0.9401  F-Test =   84.64 P-Value > F(3 , 13)  0.0000
- R2v= 0.9513   R2v Adj= 0.9401  F-Test =   84.64 P-Value > F(3 , 13)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   1.060841   .2769969     3.83   0.002     .4624256    1.659257
          x2 |  -1.397391   .2321721    -6.02   0.000    -1.898969    -.895814
          x3 |  -.0034456   .0514889    -0.07   0.948    -.1146807    .1077894
       _cons |   132.2612   36.46863     3.63   0.003     53.47554    211.0469
------------------------------------------------------------------------------

==============================================================================
*** Multicollinearity Diagnostic Tests
==============================================================================

* Correlation Matrix
(obs=17)

             |       x1       x2       x3
-------------+---------------------------
          x1 |   1.0000
          x2 |   0.1788   1.0000
          x3 |  -0.1832  -0.9296   1.0000

* Multicollinearity Diagnostic Criteria
+-------------------------------------------------------------------------------+
|   Var |  Eigenval |  C_Number |   C_Index |       VIF |     1/VIF |   R2_xi,X |
|-------+-----------+-----------+-----------+-----------+-----------+-----------|
|    x1 |    1.9954 |    1.0000 |    1.0000 |    1.0353 |    0.9659 |    0.0341 |
|    x2 |    0.9342 |    2.1361 |    1.4615 |    7.3632 |    0.1358 |    0.8642 |
|    x3 |    0.0704 |   28.3396 |    5.3235 |    7.3753 |    0.1356 |    0.8644 |
+-------------------------------------------------------------------------------+

* Farrar-Glauber Multicollinearity Tests
  Ho: No Multicollinearity - Ha: Multicollinearity
--------------------------------------------------

* (1) Farrar-Glauber Multicollinearity Chi2-Test:
    Chi2 Test =   28.7675    P-Value > Chi2(3) 0.0000

* (2) Farrar-Glauber Multicollinearity F-Test:
+--------------------------------------------------------+
|   Variable |   F_Test |      DF1 |      DF2 |  P_Value |
|------------+----------+----------+----------+----------|
|         x1 |    0.247 |   14.000 |    3.000 |    0.971 |
|         x2 |   44.543 |   14.000 |    3.000 |    0.005 |
|         x3 |   44.627 |   14.000 |    3.000 |    0.005 |
+--------------------------------------------------------+

* (3) Farrar-Glauber Multicollinearity t-Test:
+-------------------------------------+
| Variable |     x1 |     x2 |     x3 |
|----------+--------+--------+--------|
|       x1 |      . |        |        |
|       x2 |  0.680 |      . |        |
|       x3 | -0.697 | -9.435 |      . |
+-------------------------------------+

* Determinant of |X'X|:
  |X'X| = 0 Multicollinearity - |X'X| = 1 No Multicollinearity
  Determinant of |X'X|:      (0 < 0.1313 < 1)
---------------------------------------------------------------

* Theil R2 Multicollinearity Effect:
  R2 = 0 No Multicollinearity - R2 = 1 Multicollinearity
    - Theil R2:              (0 < 0.7606 < 1)
---------------------------------------------------------------

* Multicollinearity Range:
  Q = 0 No Multicollinearity - Q = 1 Multicollinearity
     - Gleason-Staelin Q0:   (0 < 0.5567 < 1)
    1- Heo Range  Q1:        (0 < 0.8356 < 1)
    2- Heo Range  Q2:        (0 < 0.8098 < 1)
    3- Heo Range  Q3:        (0 < 0.6377 < 1)
    4- Heo Range  Q4:        (0 < 0.5425 < 1)
    5- Heo Range  Q5:        (0 < 0.8880 < 1)
    6- Heo Range  Q6:        (0 < 0.5876 < 1)
------------------------------------------------------------------------------

{marker 06}{bf:{err:{dlgtab:Authors}}}

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

{bf:{err:{dlgtab:LMCOL Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2012)}{p_end}
{p 1 10 1}{cmd:LMCOL: "OLS Multicollinearity Diagnostic Tests"}{p_end}


{title:Online Help:}

{bf:{err:* OLS Multicollinearity Tests:}}
{helpb lmcol}{col 12}OLS Multicollinearity Diagnostic Tests
{helpb fgtest}{col 12}Farrar-Glauber Multicollinearity Chi2, F, t Tests
{helpb theilr2}{col 12}Theil R2 Multicollinearity Effect

{psee}
{p_end}

