{smcl}
{hline}
{cmd:help: {helpb reset}}{space 50} {cmd:dialog:} {bf:{dialog reset}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: reset: OLS REgression Specification Error Tests (RESET)}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb reset##01:Syntax}{p_end}
{p 5}{helpb reset##02:Description}{p_end}
{p 5}{helpb reset##03:Options}{p_end}
{p 5}{helpb reset##04:Saved Results}{p_end}
{p 5}{helpb reset##05:References}{p_end}

{p 1}*** {helpb reset##06:Examples}{p_end}

{p 5}{helpb reset##07:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{cmd:reset} {depvar} {it:{help varlist:indepvars}} {ifin} , {err: [} {opt nocons:tant} {opt coll} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:reset} computes REgression Specification Error Tests (RESET)

 	Ho: Model is Specified  -  Ha: Model is Misspecified
	- Ramsey RESETF Test
	- DeBenedictis-Giles Specification ResetL Test
	- DeBenedictis-Giles Specification ResetS Test
	- White Functional Form Test

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{marker 03}{bf:{err:{dlgtab:Options}}}
{synoptset 16}{...}

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:reset} saves the following in {cmd:e()}:

{err:*** REgression Specification Error Tests (RESET) Tests:}
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

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}DeBenedictis, L. F. & Giles D. E. A. (1998)
{cmd: "Diagnostic Testing in Econometrics: Variable Addition, RESET and Fourier Approximations",}
{it:In: A. Ullah  & D. E. A. Giles (Eds.), Handbook of Applied Economic Statistics. Marcel Dekker, New York}; 383-417.

{p 4 8 2}Ramsey, J. B. (1969)
{cmd: "Tests for Specification Errors in Classical Linear Least-Squares Regression Analysis",}
{it: Journal of the Royal Statistical Society, Series B 31}; 350-371.

{marker 06}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse reset.dta , clear}

 {stata db reset}

 {stata reset y x1 x2}
{hline}

. clear all
. sysuse reset.dta , clear
. reset y x1 x2

==============================================================================
* Ordinary Least Squares (OLS)
==============================================================================
  y = x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          17
  Wald Test         =    273.3662   |   P-Value > Chi2(2)       =      0.0000
  F-Test            =    136.6831   |   P-Value > F(2 , 14)     =      0.0000
 (Buse 1973) R2     =      0.9513   |   Raw Moments R2          =      0.9986
 (Buse 1973) R2 Adj =      0.9443   |   Raw Moments R2 Adj      =      0.9984
  Root MSE (Sigma)  =      5.5634   |   Log Likelihood Function =    -51.6471
------------------------------------------------------------------------------
- R2h= 0.9513   R2h Adj= 0.9443  F-Test =  136.68 P-Value > F(2 , 14)  0.0000
- R2v= 0.9513   R2v Adj= 0.9443  F-Test =  136.68 P-Value > F(2 , 14)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   1.061709   .2666739     3.98   0.001     .4897506    1.633668
          x2 |  -1.382986   .0838143   -16.50   0.000    -1.562749   -1.203222
       _cons |   130.7066   27.09429     4.82   0.000     72.59515    188.8181
------------------------------------------------------------------------------

==============================================================================
*** REgression Specification Error Tests (RESET)
==============================================================================
 Ho: Model is Specified  -  Ha: Model is Misspecified
------------------------------------------------------------------------------
* Ramsey Specification ResetF Test
- Ramsey RESETF1 Test: Y= X Yh2         =  11.787  P-Value > F(1,  13) 0.0044
- Ramsey RESETF2 Test: Y= X Yh2 Yh3     =   5.488  P-Value > F(2,  12) 0.0203
- Ramsey RESETF3 Test: Y= X Yh2 Yh3 Yh4 =   3.604  P-Value > F(3,  11) 0.0494
------------------------------------------------------------------------------
* DeBenedictis-Giles Specification ResetL Test
- Debenedictis-Giles ResetL1 Test       =   3.873  P-Value > F(2, 12)  0.0504
- Debenedictis-Giles ResetL2 Test       =   1.919  P-Value > F(4, 10)  0.1838
- Debenedictis-Giles ResetL3 Test       =   1.052  P-Value > F(6, 8)   0.4598
------------------------------------------------------------------------------
* DeBenedictis-Giles Specification ResetS Test
- Debenedictis-Giles ResetS1 Test       =   2.020  P-Value > F(2, 12)  0.1753
- Debenedictis-Giles ResetS2 Test       =   0.886  P-Value > F(4, 10)  0.5067
- Debenedictis-Giles ResetS3 Test       =   2.437  P-Value > F(6, 8)   0.1215
------------------------------------------------------------------------------
- White Functional Form Test: E2= X X2  =   4.936  P-Value > Chi2(1)   0.0847
------------------------------------------------------------------------------

{marker 07}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:reset Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:RESET: "OLS REgression Specification Error Tests (RESET)"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457333.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457333.htm"}

{title:Online Help:}

{p 4 12 2}
{helpb reset}, {helpb reset2}. {opt (if installed)}.{p_end}

{psee}
{p_end}

