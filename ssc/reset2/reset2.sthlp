{smcl}
{hline}
{cmd:help: {helpb reset2}}{space 50} {cmd:dialog:} {bf:{dialog reset2}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: reset2: 2SLS-IV REgression Specification Error Tests (RESET)}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb reset2##01:Syntax}{p_end}
{p 5}{helpb reset2##02:Description}{p_end}
{p 5}{helpb reset2##03:Model}{p_end}
{p 5}{helpb reset2##04:GMM Options}{p_end}
{p 5}{helpb reset2##05:Other Options}{p_end}
{p 5}{helpb reset2##06:Saved Results}{p_end}
{p 5}{helpb reset2##07:References}{p_end}

{p 1}*** {helpb reset2##08:Examples}{p_end}

{p 5}{helpb reset2##09:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 2 4 2} 
{cmd:reset2} {depvar} {it:{help varlist:indepvars}} {cmd:({it:{help varlist:endog}} = {it:{help varlist:inst}})} {ifin} , {p_end} 
{p 6 6 2}
{opt model(2sls, liml, gmm, melo, fuller, kclass)}{p_end} 
{p 6 6 2}
{err: [} {opt kc(#)} {opt kf(#)} {opt hetcov(type)} {opt nocons:tant} {opt noconexog} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:reset2} computes 2SLS-IV 2SLS-IV REgression Specification Error Tests (RESET) for instrumental variables regression models, via 2sls, liml, melo, gmm, and kclass.{p_end}

 	Ho: Model is Specified  -  Ha: Model is Misspecified
	- Ramsey RESETF Test
	- DeBenedictis-Giles Specification ResetL Test
	- DeBenedictis-Giles Specification ResetS Test
	- White Functional Form Test

{marker 03}{bf:{err:{dlgtab:Model}}}

{synoptset 16}{...}
{p2coldent:{it:model}}description{p_end}
{synopt:{opt 2sls}}Two-Stage Least Squares (2SLS){p_end}
{synopt:{opt liml}}Limited-Information Maximum Likelihood (LIML){p_end}
{synopt:{opt melo}}Minimum Expected Loss (MELO){p_end}
{synopt:{opt fuller}}Fuller k-Class LIML{p_end}
{synopt:{opt kclass}}Theil K-Class LIML{p_end}
{synopt:{opt gmm}}Generalized Method of Moments (GMM){p_end}

{marker 04}{bf:{err:{dlgtab:GMM Options}}}

{synoptset 16}{...}
{p2coldent:{it:hetcov Options}}Description{p_end}

{synopt:{bf:hetcov({err:{it:white}})}}White Method{p_end}
{synopt:{bf:hetcov({err:{it:bart}})}}Bartlett Method{p_end}
{synopt:{bf:hetcov({err:{it:dan}})}}Daniell Method{p_end}
{synopt:{bf:hetcov({err:{it:nwest}})}}Newey-West Method{p_end}
{synopt:{bf:hetcov({err:{it:parzen}})}}Parzen Method{p_end}
{synopt:{bf:hetcov({err:{it:quad}})}}Quadratic spectral Method{p_end}
{synopt:{bf:hetcov({err:{it:tent}})}}Tent Method{p_end}
{synopt:{bf:hetcov({err:{it:trunc}})}}Truncated Method{p_end}
{synopt:{bf:hetcov({err:{it:tukeym}})}}Tukey-Hamming Method{p_end}
{synopt:{bf:hetcov({err:{it:tukeyn}})}}Tukey-Hanning Method{p_end}

{marker 05}{bf:{err:{dlgtab:Other Options}}}

{synoptset 16}{...}
{synopt:{bf:kf({err:{it:#}})}}Fuller k-Class LIML Value{p_end}

{synopt:{bf:kc({err:{it:#}})}}Theil k-Class LIML Value{p_end}

{synopt:{opt nocons:tant}}Exclude Constant Term from RHS Equation only{p_end}

{synopt:{bf:noconexog}}Exclude Constant Term from all Equations (both RHS and Instrumental Equations). Results of using {cmd:noconexog} option are identical to Stata {helpb ivregress} and {helpb ivreg2}.
 The default of {cmd:reset2} is including Constant Term in both RHS and Instrumental Equations{p_end}

{marker 06}{bf:{err:{dlgtab:Saved Results}}}

{cmd:reset2} saves the following in {cmd:e()}:

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

{marker 07}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}DeBenedictis, L. F. & Giles D. E. A. (1998)
{cmd: "Diagnostic Testing in Econometrics: Variable Addition, RESET and Fourier Approximations",}
{it:In: A. Ullah  & D. E. A. Giles (Eds.), Handbook of Applied Economic Statistics. Marcel Dekker, New York}; 383-417.

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

{p 4 8 2}Kmenta, Jan (1986)
{cmd: "Elements of Econometrics",}
{it: 2nd ed., Macmillan Publishing Company, Inc., New York, USA}; 718.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}; 358-366.

{p 4 8 2}Park, S. (1982)
{cmd: "Some Sampling Properties of Minimum Expected Loss (MELO) Estimators of Structural Coefficients",}
{it:J. Econometrics, Vol. 18, No. 2, April,}; 295-311.

{p 4 8 2}Ramsey, J. B. (1969)
{cmd: "Tests for Specification Errors in Classical Linear Least-Squares Regression Analysis",}
{it: Journal of the Royal Statistical Society, Series B 31}; 350-371.

{p 4 8 2}White, Halbert (1980)
{cmd: "A Heteroskedasticity-Consistent Covariance Matrix Estimator and a Direct Test for Heteroskedasticity",}
{it:Econometrica, 48}; 817-838.

{p 4 8 2}William E. Griffiths, R. Carter Hill and George G. Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.  

{p 4 8 2}Zellner, Arnold (1978)
{cmd: "Estimation of Functions of Population Means and Regression Coefficients Including Structural Coefficients: A Minimum Expected Loss (MELO) Approach",}
{it:J. Econometrics, Vol. 8,}; 127-158.

{p 4 8 2}Zellner, Arnold & S. Park (1979)
{cmd: "Minimum Expected Loss (MELO) Estimators for Functions of Parameters and Structural Coefficients of Econometric Models",}
{it:J. Am. Stat. Assoc., Vol. 74}; 185-193.

{marker 08}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse reset2.dta , clear}

 {stata db reset2}

 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(melo)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(liml)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(fuller) kf(0.5)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(kclass) kc(0.5)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(white)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(bart)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(dan)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(nwest)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(parzen)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(quad)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tent)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(trunc)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeym)}
 {stata reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeyn)}
{hline}

. clear all
. sysuse reset2.dta , clear
. reset2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)

==============================================================================
* Two Stage Least Squares (2SLS)
==============================================================================
  y1 = y2 + x1 + x2
------------------------------------------------------------------------------
 Sample Size        =          17
 Wald Test          =     79.9520   |   P-Value > Chi2(3)       =      0.0000
 F-Test             =     26.6507   |   P-Value > F(3 , 13)     =      0.0000
 (Buse 1973) R2     =      0.8592   |   Raw Moments R2          =      0.9954
 (Buse 1973) R2 Adj =      0.8267   |   Raw Moments R2 Adj      =      0.9944
 Root MSE (Sigma)   =     10.2244   |   Log Likelihood Function =    -61.3630
------------------------------------------------------------------------------
- R2h= 0.8593   R2h Adj= 0.8268  F-Test =   26.46 P-Value > F(3 , 13)  0.0000
- R2v= 0.8765   R2v Adj= 0.8480  F-Test =   30.75 P-Value > F(3 , 13)  0.0000
------------------------------------------------------------------------------
          y1 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          y2 |    .237333   .2422811     0.98   0.345    -.2860835    .7607495
          x1 |   .2821278   .5433329     0.52   0.612    -.8916715    1.455927
          x2 |  -1.044795    .362648    -2.88   0.013    -1.828248   -.2613411
       _cons |   145.8444   61.72083     2.36   0.034     12.50468    279.1842
------------------------------------------------------------------------------
* Y  = LHS Dependent Variable:       1 = y1
* Yi = RHS Endogenous Variables:     1 = y2
* Xi = RHS Included Exogenous Vars:  2 = x1 x2
* Xj = RHS Excluded Exogenous Vars:  2 = x3 x4
* Z  = Overall Instrumental Vars:    4 = x1 x2 x3 x4

==============================================================================
*** 2SLS-IV REgression Specification Error Tests (RESET) - Model= (2sls)
==============================================================================
 Ho: Model is Specified  -  Ha: Model is Misspecified
------------------------------------------------------------------------------
* Ramsey Specification ResetF Test
- Ramsey RESETF1 Test: Y= X Yh2         =   1.032  P-Value > F(1,  12) 0.3297
- Ramsey RESETF2 Test: Y= X Yh2 Yh3     =   6.942  P-Value > F(2,  11) 0.0112
- Ramsey RESETF3 Test: Y= X Yh2 Yh3 Yh4 =   5.561  P-Value > F(3,  10) 0.0166
------------------------------------------------------------------------------
* DeBenedictis-Giles Specification ResetL Test
- Debenedictis-Giles ResetL1 Test       =   4.952  P-Value > F(2, 11)  0.0293
- Debenedictis-Giles ResetL2 Test       =   2.960  P-Value > F(4, 9)   0.0813
- Debenedictis-Giles ResetL3 Test       =   1.714  P-Value > F(6, 7)   0.2482
------------------------------------------------------------------------------
* DeBenedictis-Giles Specification ResetS Test
- Debenedictis-Giles ResetS1 Test       =   2.117  P-Value > F(2, 11)  0.1668
- Debenedictis-Giles ResetS2 Test       =   0.438  P-Value > F(4, 9)   0.7786
- Debenedictis-Giles ResetS3 Test       =   0.321  P-Value > F(6, 7)   0.9063
------------------------------------------------------------------------------
- White Functional Form Test: E2= X X2  =   9.977  P-Value > Chi2(1)   0.0068
------------------------------------------------------------------------------

{marker 09}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:reset2 Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:RESET2: "2SLS-IV REgression Specification Error Tests (RESET)"}{p_end}

{title:Online Help:}

{p 4 12 2}
{helpb reset}, {helpb reset2}. {opt (if installed)}.{p_end}

{psee}
{p_end}

