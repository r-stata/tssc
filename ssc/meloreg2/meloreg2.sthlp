{smcl}
{hline}
{cmd:help: {helpb meloreg2}}{space 55} {cmd:dialog:} {bf:{dialog meloreg2}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: meloreg2: Minimum Expected Loss (MELO) Instrumental Variables Regression}

{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb meloreg2##1:Syntax}{p_end}
{p 5}{helpb meloreg2##2:Options}{p_end}
{p 5}{helpb meloreg2##3:Weight Options}{p_end}
{p 5}{helpb meloreg2##4:Weighted Variable Type Options}{p_end}
{p 5}{helpb meloreg2##5:Description}{p_end}
{p 5}{helpb meloreg2##6:Saved Results}{p_end}
{p 5}{helpb meloreg2##7:References}{p_end}

{p 1}*** {helpb meloreg2##8:Examples}{p_end}

{p 5}{helpb meloreg2##9:Author}{p_end}

{marker 1}{bf:{err:{dlgtab:Syntax}}}

{p 2 4 2} 
{cmd:meloreg2} {depvar} {it:{help varlist:indepvars}} {cmd:({it:{help varlist:endog}} = {it:{help varlist:inst}})} {ifin} , {err: [} {opt nocons:tant} {opt noconexog} {opt dn} {p_end} 
{p 12 6 2}
{opt weights(type)} {opt wv:ar(varname)} {opt pred:ict(new_var)} {opt res:id(new_var)} {err:]}{p_end}

{marker 2}{bf:{err:{dlgtab:Options}}}

{synoptset 16}{...}

{synopt:{opt nocons:tant}}Exclude Constant Term from RHS Equation only{p_end}

{synopt:{bf:noconexog}}Exclude Constant Term from all Equations (both RHS and Instrumental Equations). Results of using {cmd:noconexog} option are identical to Stata {helpb ivregress} and {helpb ivreg2}.
 Including Constant Term in both RHS and Instrumental Equations is default in {cmd:meloreg2}{p_end}

{synopt:{bf:dn}}Use (N) divisor instead of (N-K) for Degrees of Freedom (DF){p_end}

{synopt:{opt pred:ict(new_var)}}Predicted values variable{p_end}

{synopt:{opt res:id(new_var)}}Residuals values variable{p_end}

{marker 3}{bf:{err:{dlgtab:Weight Options}}}

{synoptset 16}{...}
{synopt:{bf:wvar({err:{it:varname}})}}Weighted Variable Name{p_end}

{marker 4}{bf:{err:{dlgtab:Weighted Variable Type Options}}}

{synoptset 16}{...}
{p2coldent:{it:Type Options}}Description{p_end}

{synopt:{bf:weights({err:{it:yh}})}}Yh - Predicted Value{p_end}
{synopt:{bf:weights({err:{it:yh2}})}}Yh^2 - Predicted Value Squared{p_end}
{synopt:{bf:weights({err:{it:abse}})}}abs(E) - Absolute Value of Residual{p_end}
{synopt:{bf:weights({err:{it:e2}})}}E^2 - Residual Squared{p_end}
{synopt:{bf:weights({err:{it:le2}})}}log(E^2) - Log Residual Squared{p_end}
{synopt:{bf:weights({err:{it:x}})}}(x) Variable{p_end}
{synopt:{bf:weights({err:{it:xi}})}}(1/x) Inverse Variable{p_end}
{synopt:{bf:weights({err:{it:x2}})}}(x^2) Squared Variable{p_end}
{synopt:{bf:weights({err:{it:xi2}})}}(1/x^2) Inverse Squared Variable{p_end}

{marker 5}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:meloreg2} estimate Minimum Expected Loss (MELO) Instrumental Variables Regression. {cmd:meloreg2} dont deal with Missing values (.) in variables{p_end}

{marker 6}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:meloreg2} saves the following in {cmd:e()}:

{col 4}{cmd:e(f)}{col 20}F Test
{col 4}{cmd:e(fp)}{col 20}F Test P-Value
{col 4}{cmd:e(N)}{col 20}Number of obs
{col 4}{cmd:e(r2c)}{col 20}R2
{col 4}{cmd:e(r2c_a)}{col 20}adj R2
{col 4}{cmd:e(r2cc)}{col 20}Corrected R2
{col 4}{cmd:e(r2cc_a)}{col 20}adj Corrected R2
{col 4}{cmd:e(r2u)}{col 20}Raw R2
{col 4}{cmd:e(r2u_a)}{col 20}Adj Raw R2
{col 4}{cmd:e(sig)}{col 20}Sigma (MSE)
{col 4}{cmd:e(wald)}{col 20}Wald Test
{col 4}{cmd:e(waldp)}{col 20}Wald Test P-Value

Matrixes
{col 4}{cmd:e(b)}{col 22}coefficient vector
{col 4}{cmd:e(V)}{col 22}variance-covariance matrix of the estimators

{marker 7}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 615.

{p 4 8 2}Park, S. (1982)
{cmd: "Some Sampling Properties of Minimum Expected Loss (MELO) Estimators of Structural Coefficients",}
{it:J. Econometrics, Vol. 18, No. 2, April,}; 295-311.

{p 4 8 2}Zellner, Arnold (1978)
{cmd: "Estimation of Functions of Population Means and Regression Coefficients Including Structural Coefficients: A Minimum Expected Loss (MELO) Approach",}
{it:J. Econometrics, Vol. 8,}; 127-158.

{p 4 8 2}Zellner, Arnold & S. Park (1979)
{cmd: "Minimum Expected Loss (MELO) Estimators for Functions of Parameters and Structural Coefficients of Econometric Models",}
{it:J. Am. Stat. Assoc., Vol. 74}; 185-193.

{marker 8}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse meloreg2.dta , clear}

 {stata db meloreg2}

 {stata meloreg2 y1 x1 x2 (y2 = x1 x2 x3 x4)}

 {stata ereturn list}

 {stata tsset t}

 {stata gen y1_1=L.y1}

*** replace missing value in first observation with (0).
 {stata replace y1_1= 0 if y1_1 == .}

 {stata meloreg2 y1 y1_1 x1 x2 (y2 = y1_1 x1 x2 x3 x4)}

{hline}

{bf:{err:* Weighted MELO (WMELO)}}

 {stata meloreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(yh)}

 {stata meloreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(yh2)}

 {stata meloreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(abse)}

 {stata meloreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(e2)}

 {stata meloreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(le2)}

 {stata meloreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(x) wvar(x1)}

 {stata meloreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(xi) wvar(x1)}

 {stata meloreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(x2) wvar(x1)}

 {stata meloreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(xi2) wvar(x1)}
{hline}

. clear all
. sysuse meloreg2.dta , clear
. meloreg2 y1 x1 x2 (y2 = x1 x2 x3 x4)
==============================================================================
* Minimum Expected Loss (MELO) Instrumental Variables Regression)
==============================================================================
  y1 = y2 + x1 + x2
------------------------------------------------------------------------------
 K - Class (MELO) Value  =   0.72727
  Number of Obs    =         17
  Wald Test        =    81.2132         P-Value > Chi2(3)        =     0.0000
  F Test           =    27.0711         P-Value > F(3 , 13)      =     0.0000
  R-squared        =     0.8616         Raw R2                   =     0.9955
  R-squared Adj    =     0.8297         Raw R2 Adj               =     0.9945
  Root MSE (Sigma) =    10.1364         Log Likelihood Function  =   -61.2160
------------------------------------------------------------------------------
          y1 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          y2 |   .1951374   .2125644     0.92   0.375    -.2640801    .6543549
          x1 |   .3229772   .5276595     0.61   0.551    -.8169618    1.462916
          x2 |  -1.101973   .3260175    -3.38   0.005    -1.806291   -.3976546
       _cons |   152.1958   58.82774     2.59   0.023     25.10624    279.2854
------------------------------------------------------------------------------

{marker 9}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:meloreg2 Citation}}}

{phang}Shehata, Emad Abd Elmessih (2012){p_end}
{phang}{cmd: MELOREG2: "Stata Module to Estimate Minimum Expected Loss (MELO) Instrumental Variables Regression"}{p_end}

{title:Online Help:}

{p 4 12 2}
{helpb ivregress}, {helpb diagreg2}, {helpb meloreg2}, (if installed)}.{p_end}

{psee}
{p_end}

