{smcl}
{hline}
{cmd:help: {helpb lmcovvar}}{space 50} {cmd:dialog:} {bf:{dialog lmcovvar}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmcovvar: (VAR) Breusch-Pagan Diagonal Covariance Matrix Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmcovvar##01:Syntax}{p_end}
{p 5}{helpb lmcovvar##02:Options}{p_end}
{p 5}{helpb lmcovvar##03:Description}{p_end}
{p 5}{helpb lmcovvar##04:Saved Results}{p_end}
{p 5}{helpb lmcovvar##05:References}{p_end}

{p 1}*** {helpb lmcovvar##06:Examples}{p_end}

{p 5}{helpb lmcovvar##07:Authors}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt lmcovvar} {depvars} {ifin} , {err: [} {opt noconst:ant} {opth la:gs(numlist)}
{opth ex:og(varlist)}{p_end} 
{p 5 5 6} 
{opt nolo:g} {cmdab:const:raints(}{it:{help estimation options##constraints():numlist}}{cmd:)} {opt it:erate(#)} {opt dfk} {opt nobig:f} {opt lut:stats} {opt sm:all}{p_end} 
{p 5 5 6} 
{opt tol:erance(#)} {opt nois:ure} {opt nocnsr:eport} {opt l:evel(#)} {err:]}{p_end}

{marker 02}{bf:{err:{dlgtab:Options}}}

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}

{synopt:{opt noconst:ant}}suppress constant term{p_end}
{synopt:{opt lag:s(#/#)}}Dependent Variables Lag length; default is (1/1){p_end}
{synopt:{opth exog(varlist)}}use exogenous variables {it:varlist}{p_end}

{syntab:Model 2}
{synopt:{cmdab:const:raints(}{it:{help estimation options##constraints():numlist}}{cmd:)}}apply specified linear constraints{p_end}
{synopt:{opt nolo:g}}suppress SURE iteration log{p_end}
{synopt:{opt tol:erance(#)}}set convergence tolerance of SURE{p_end}
{synopt:{opt nois:ure}}use one-step SURE{p_end}
{synopt:{opt dfk}}make small-sample degrees-of-freedom adjustment{p_end}
{synopt:{opt sm:all}}report small-sample t and F statistics{p_end}
{synopt:{opt nobig:f}}do not compute parameter vector for coefficients implicitly set to zero {p_end}
{synopt:{opt it:erate(#)}}set maximum number of iterations for SURE; default is {cmd:iterate(1600)}{p_end}
{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{opt lut:stats}}report L{c u:}tkepohl lag-order selection statistics{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}

*** {helpb tsset} must be used before using {cmd:lmcovvar}

{it:depvarlist} and {it:varlist} may contain time-series operators; see {help tsvarlist}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:lmcovvar} computes Breusch-Pagan Diagonal Covariance Matrix Test after:{p_end}
{p 3 2 2}- (VAR) Vector Autoregressive Model ({helpb var}).{p_end} 
{p 3 2 2}- {cmd:lmcovvar} options are identically to official ({helpb var}) command.{p_end}

{p 3 2 2}- ({helpb var}) model with SURE estimations assumes:{p_end} 
{p 4 7 7}1- Independence of the errors in each eqution or no correlations between different periods in the same equation.{p_end} 
{p 4 7 7}2- no correlations between the errors for any of two equtions between two different periods, this is called {cmd:"Intertemporal Correlation"}.{p_end} 
{p 4 7 7}3- correlations may be exist between different two equations, but at the same period, and this is called {cmd:"Contemporaneous Correlation"}.{p_end} 
{p 4 7 7}4- SURE can be applied when there is correlations between different two equations at the same period, or if the independent variables are differnt from equation to equation.{p_end} 
{p 4 7 7}5- If {cmd:"Contemporaneous Correlation"} does not exist, ordinary least squares (OLS) can be applied separately to each equation, the results are fully efficient and there is no need to estimate SURE.{p_end} 
{p 4 4 4} Breusch-Pagan Diagonal Covariance Matrix LM Test can test whether contemporaneous diagonal covariance matrix is 0. (Independence of the Errors), or correlated if at least one covariance is nonzero.{p_end} 
{p 4 4 4} Ho: {cmd:no Contemporaneous Correlation}: Sig12 = Sig13 = Sig23 = ... = 0.{p_end} 
{p 4 4 4} Ha: {cmd:   Contemporaneous Correlation}: at least one Covariance is nonzero.{p_end}

{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmcovvar} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 15 2: Scalars}{p_end}

{col 4}{cmd:r(lmcov)}{col 20}LM Diagonal Covariance Matrix Test
{col 4}{cmd:r(lmcovp)}{col 20}LM Diagonal Covariance Matrix Test P-Value
{col 4}{cmd:r(lmcovdf)}{col 20}Chi2 Degrees of Freedom

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA.}; 490-491.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 758-763.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 477-478.

{p 4 8 2}Kmenta, Jan (1986)
{cmd: "Elements of Econometrics",}
{it:2nd ed., Macmillan Publishing Company, Inc., New York, USA}; 645.

{marker 06}{bf:{err:{dlgtab:Examples}}}

	{stata clear all}
	{stata sysuse lmcovvar.dta , clear}
	{stata tsset t}
	{stata lmcovvar y1 y2, lags(1/1) exog(x1 x2)}
	{stata return list}

 * If you want to use dialog box: Press OK to compute lmcovvar

	{stata db lmcovvar}

{cmd:* This example is taken from:}
{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 758-763.

	{stata clear all}
	{stata sysuse lmcovvar.dta , clear}
	{stata tsset t}

	{stata lmcovvar y1 y2 in 5/71 , lags(1/1)}
	{stata lmcovvar y1 y2 in 5/71 , lags(1/2)}
	{stata lmcovvar y1 y2 in 5/71 , lags(1/3)}

	{stata return list}
{hline}

. clear all
. sysuse lmcovvar.dta , clear
. tsset t
. lmcovvar y1 y2 in 5/71 , lags(1/1)

Vector autoregression

Sample:  5 - 71                                    No. of obs      =        67
Log likelihood = -566.0542                         AIC             =  17.07625
FPE            =  89376.34                         HQIC            =  17.15437
Det(Sigma_ml)  =  74711.32                         SBIC            =  17.27368

Equation           Parms      RMSE     R-sq      chi2     P>chi2
----------------------------------------------------------------
y1                    3     16.6829   0.2878   27.07799   0.0000
y2                    3     19.9034   0.1863   15.33891   0.0005
----------------------------------------------------------------

------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y1           |
          y1 |
         L1. |  -.0903073   .1279538    -0.71   0.480    -.3410921    .1604774
             |
          y2 |
         L1. |   .5189002    .114004     4.55   0.000     .2954564     .742344
             |
       _cons |   7.949964   2.585932     3.07   0.002      2.88163     13.0183
-------------+----------------------------------------------------------------
y2           |
          y1 |
         L1. |   .1970232   .1526549     1.29   0.197    -.1021748    .4962212
             |
          y2 |
         L1. |    .297665   .1360122     2.19   0.029     .0310861     .564244
             |
       _cons |   8.537288   3.085138     2.77   0.006     2.490528    14.58405
------------------------------------------------------------------------------

==============================================================================
* (VAR) Breusch-Pagan LM Diagonal Covariance Matrix Test
==============================================================================
 Ho: Diagonal Disturbance Covariance Matrix (Independent Equations)
 Ho: Run OLS  -  Ha: Run SUR

    Lagrange Multiplier Test  =   17.24311
    Degrees of Freedom        =        1.0
    P-Value > Chi2(1)         =    0.00003
==============================================================================

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

{bf:{err:{dlgtab:LMCOVVAR Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2012)}{p_end}
{p 1 10 1}{cmd:LMCOVVAR: "(VAR) Breusch-Pagan Diagonal Covariance Matrix Test"}{p_end}


{title:Online Help:}

{bf:{err:* Breusch-Pagan Diagonal Covariance Matrix Test:}}
{helpb lmcovnlsur}{col 12}(NL-SUR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovreg3}{col 12}(3SLS-SUR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovsem}{col 12}(SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovvar}{col 12}(VAR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovxt}{col 12}Panel Data Breusch-Pagan Diagonal Covariance Matrix Test
---------------------------------------------------------------------------

{bf:{err:* (1) (3SLS-SUR) * Simultaneous Equations:}}
{helpb lmareg3}{col 12}(3SLS-SUR) Overall System Autocorrelation Tests
{helpb lmhreg3}{col 12}(3SLS-SUR) Overall System Heteroscedasticity Tests
{helpb lmnreg3}{col 12}(3SLS-SUR) Overall System Non Normality Tests
{helpb lmcovreg3}{col 12}(3SLS-SUR) Breusch-Pagan Diagonal Covariance Matrix
{helpb r2reg3}{col 12}(3SLS-SUR) Overall System R2, F-Test, and Chi2-Test
{helpb diagreg3}{col 12}(3SLS-SUR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (2) (SEM-FIML) * Structural Equation Modeling:}}
{helpb lmasem}{col 12}(SEM-FIML) Overall System Autocorrelation Tests
{helpb lmhsem}{col 12}(SEM-FIML) Overall System Heteroscedasticity Tests
{helpb lmnsem}{col 12}(SEM-FIML) Overall System Non Normality Tests
{helpb lmcovsem}{col 12}(SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2sem}{col 12}(SEM-FIML) Overall System R2, F-Test, and Chi2-Test
{helpb diagsem}{col 12}(SEM-FIML) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (3) (NL-SUR) * Non Linear Seemingly Unrelated Regression:}}
{helpb lmanlsur}{col 12}(NL-SUR) Overall System Autocorrelation Tests
{helpb lmhnlsur}{col 12}(NL-SUR) Overall System Heteroscedasticity Tests
{helpb lmnnlsur}{col 12}(NL-SUR) Overall System Non Normality Tests
{helpb lmcovnlsur}{col 12}(NL-SUR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2nlsur}{col 12}(NL-SUR) Overall System R2, F-Test, and Chi2-Test
{helpb diagnlsur}{col 12}(NL-SUR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (4) (VAR) * Vector Autoregressive Model:}}
{helpb lmavar}{col 12}(VAR) Overall System Autocorrelation Tests
{helpb lmhvar}{col 12}(VAR) Overall System Heteroscedasticity Tests
{helpb lmnvar}{col 12}(VAR) Overall System Non Normality Tests
{helpb lmcovvar}{col 12}(VAR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2var}{col 12}(VAR) Overall System R2, F-Test, and Chi2-Test
{helpb diagvar}{col 12}(VAR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------

{psee}
{p_end}

