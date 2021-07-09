{smcl}
{hline}
{cmd:help: {helpb lmhwaldxt}}{space 50} {cmd:dialog:} {bf:{dialog lmhwaldxt}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmhwaldxt: Panel Data Heteroscedasticity Wald Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmhwaldxt##01:Syntax}{p_end}
{p 5}{helpb lmhwaldxt##02:Options}{p_end}
{p 5}{helpb lmhwaldxt##03:Description}{p_end}
{p 5}{helpb lmhwaldxt##04:Saved Results}{p_end}
{p 5}{helpb lmhwaldxt##05:References}{p_end}

{p 1}*** {helpb lmhwaldxt##06:Examples}{p_end}

{p 5}{helpb lmhwaldxt##07:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt lmhwaldxt} {depvar} {indepvars} {ifin} , {bf:{err:id(var)}} {bf:{err:it(var)}} {err: [} {opt nocons:tant} {opt cross} {opt coll} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}

{col 3}* {cmd: {opt id(var)}{col 20}Cross Sections ID variable name}
{col 3}* {cmd: {opt it(var)}{col 20}Time Series ID variable name}

{col 3}{opt cross}{col 20}estimates each Cross Section regression,
{col 20}to stack each residual variable in one variable,
{col 20}and the same method for predict variable.

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:lmhwaldxt} computes Panel Data Heteroscedasticity Wald Test.

	* Ho: Panel Homoscedasticity - Ha: Panel Heteroscedasticity
	- Wald Test:         LogE2 = X

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:lmhwaldxt} saves the following results in {cmd:e()}:

{col 4}{cmd:e(lmhwald)}{col 20}Wald Test
{col 4}{cmd:e(lmhwaldp)}{col 20}Wald Test P-Value

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA.}.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Macmillan Publishing Company Inc., New York, USA.}.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Examples}}}

  {stata clear all}

  {stata sysuse lmhwaldxt.dta, clear}

  {stata db lmhwaldxt}

  {stata lmhwaldxt y x1 x2 , id(id) it(t)}
{hline}

. clear all
. sysuse lmhwaldxt.dta, clear
. lmhwaldxt y x1 x2 , id(id) it(t)

==============================================================================
* Ordinary Least Squares (OLS) Regression
==============================================================================
  y = x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          49   |   Cross Sections Number   =           7
  Wald Test         =     56.7713   |   P-Value > Chi2(2)       =      0.0000
  F-Test            =     28.3857   |   P-Value > F(2 , 46)     =      0.0000
 (Buse 1973) R2     =      0.5524   |   Raw Moments R2          =      0.9186
 (Buse 1973) R2 Adj =      0.5329   |   Raw Moments R2 Adj      =      0.9151
  Root MSE (Sigma)  =     11.4350   |   Log Likelihood Function =   -187.3772
------------------------------------------------------------------------------
- R2h= 0.5524   R2h Adj= 0.5329  F-Test =   28.39 P-Value > F(2 , 46)  0.0000
- R2v= 0.5524   R2v Adj= 0.5329  F-Test =   28.39 P-Value > F(2 , 46)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |  -.2739317   .1031986    -2.65   0.011    -.4816598   -.0662037
          x2 |  -1.597311   .3341306    -4.78   0.000    -2.269881   -.9247407
       _cons |   68.61898   4.735484    14.49   0.000     59.08694    78.15101
------------------------------------------------------------------------------

==============================================================================
*** Panel Data Heteroscedasticity Wald Test
==============================================================================
  Ho: Panel Homoscedasticity - Ha: Panel Heteroscedasticity

- Wald Test:         LogE2 = X          =   8.6588   P-Value > Chi2(1)  0.0033
------------------------------------------------------------------------------

{p2colreset}{...}
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

{bf:{err:{dlgtab:LMHWALDXT Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2013)}{p_end}
{p 1 10 1}{cmd:LMHWALDXT: "Panel Data Heteroscedasticity Wald Test"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457715.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457715.htm"}


{title:Online Help:}

{bf:{err:* Heteroscedasticity Tests:}}

{bf:{err:* (1) (OLS) * Ordinary Least Squares Tests:}}
{helpb lmhreg}{col 12}OLS Heteroscedasticity Tests
{helpb lmharch}{col 12}OLS Heteroscedasticity Engle (ARCH) Test
{helpb lmhcw}{col 12}OLS Heteroscedasticity Cook-Weisberg Test
{helpb lmhgl}{col 12}OLS Heteroscedasticity Glejser Test
{helpb lmhharv}{col 12}OLS Heteroscedasticity Harvey Test
{helpb lmhhp}{col 12}OLS Heteroscedasticity Hall-Pagan Test
{helpb lmhmss}{col 12}OLS Heteroscedasticity Machado-Santos-Silva Test
{helpb lmhwald}{col 12}OLS Heteroscedasticity Wald Test
{helpb lmhwhite}{col 12}OLS Heteroscedasticity White Test
---------------------------------------------------------------------------
{bf:{err:* (2) (NLS) * Non Linear Least Squares Tests:}}
{helpb lmhnls}{col 12}Non Linear Least Squares Heteroscedasticity Tests
{helpb lmharchnl}{col 12}NLS Heteroscedasticity Engle (ARCH) Test
{helpb lmhcwnl}{col 12}NLS Heteroscedasticity Cook-Weisberg Test
{helpb lmhglnl}{col 12}NLS Heteroscedasticity Glejser Test
{helpb lmhharvnl}{col 12}NLS Heteroscedasticity Harvey Test
{helpb lmhhpnl}{col 12}NLS Heteroscedasticity Hall-Pagan Test
{helpb lmhmssnl}{col 12}NLS Heteroscedasticity Machado-Santos-Silva Test
{helpb lmhwaldnl}{col 12}NLS Heteroscedasticity Wald Test
{helpb lmhwhitenl}{col 12}NLS Heteroscedasticity White Test
---------------------------------------------------------------------------
{bf:{err:* (3) (MLE) * Maximum Likelihood Estimation Tests:}}
{helpb lmhmle}{col 12}MLE Heteroscedasticity Tests
{helpb lmharchml}{col 12}MLE Heteroscedasticity Engle (ARCH) Test
{helpb lmhcwml}{col 12}MLE Heteroscedasticity Cook-Weisberg Test
{helpb lmhglml}{col 12}MLE Heteroscedasticity Glejser Test
{helpb lmhharvml}{col 12}MLE Heteroscedasticity Harvey Test
{helpb lmhhpml}{col 12}MLE Heteroscedasticity Hall-Pagan Test
{helpb lmhmssml}{col 12}MLE Heteroscedasticity Machado-Santos-Silva Test
{helpb lmhwaldml}{col 12}MLE Heteroscedasticity Wald Test
{helpb lmhwhiteml}{col 12}MLE Heteroscedasticity White Test
---------------------------------------------------------------------------
{bf:{err:* (4) (2SLS-IV) * Two-Stage Least Squares & Instrumental Variables Tests:}}
{helpb lmhreg2}{col 12}2SLS-IV Heteroscedasticity Tests
{helpb lmharch2}{col 12}2SLS-IV Heteroscedasticity Engle (ARCH) Test
{helpb lmhcw2}{col 12}2SLS-IV Heteroscedasticity Cook-Weisberg Test
{helpb lmhgl2}{col 12}2SLS-IV Heteroscedasticity Glejser Test
{helpb lmhharv2}{col 12}2SLS-IV Heteroscedasticity Harvey Test
{helpb lmhhp2}{col 12}2SLS-IV Heteroscedasticity Hall-Pagan Test
{helpb lmhmss2}{col 12}2SLS-IV Heteroscedasticity Machado-Santos-Silva Test
{helpb lmhwald2}{col 12}2SLS-IV Heteroscedasticity Wald Test
{helpb lmhwhite2}{col 12}2SLS-IV Heteroscedasticity White Test
---------------------------------------------------------------------------
{bf:{err:* (5) Panel Data Tests:}}
{helpb lmhxt}{col 12}Panel Data Heteroscedasticity Tests
{helpb lmhgwxt}{col 12}Panel Data Groupwise Heteroscedasticity Tests
{helpb ghxt}{col 12}Panel Groupwise Heteroscedasticity Tests
{helpb lmhlmxt}{col 12}Panel Data Groupwise Heteroscedasticity Breusch-Pagan LM Test
{helpb lmhlrxt}{col 12}Panel Data Groupwise Heteroscedasticity Greene LR Test
{helpb lmharchxt}{col 12}Panel Data Heteroscedasticity Engle (ARCH) Test
{helpb lmhcwxt}{col 12}Panel Data Heteroscedasticity Cook-Weisberg Test
{helpb lmhglxt}{col 12}Panel Data Heteroscedasticity Glejser Test
{helpb lmhharvxt}{col 12}Panel Data Heteroscedasticity Harvey Test
{helpb lmhhpxt}{col 12}Panel Data Heteroscedasticity Hall-Pagan Test
{helpb lmhmssxt}{col 12}Panel Data Heteroscedasticity Machado-Santos-Silva Test
{helpb lmhwaldxt}{col 12}Panel Data Heteroscedasticity Wald Test
{helpb lmhwhitext}{col 12}Panel Data Heteroscedasticity White Test
---------------------------------------------------------------------------
{bf:{err:* (6) (3SLS-SUR) * Simultaneous Equations Tests:}}
{helpb lmareg3}{col 12}(3SLS-SUR) Overall System Autocorrelation Tests
{helpb lmhreg3}{col 12}(3SLS-SUR) Overall System Heteroscedasticity Tests
{helpb lmnreg3}{col 12}(3SLS-SUR) Overall System Non Normality Tests
{helpb lmcovreg3}{col 12}(3SLS-SUR) Breusch-Pagan Diagonal Covariance Matrix
{helpb r2reg3}{col 12}(3SLS-SUR) Overall System R2, F-Test, and Chi2-Test
{helpb diagreg3}{col 12}(3SLS-SUR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (7) (SEM-FIML) * Structural Equation Modeling Tests:}}
{helpb lmasem}{col 12}(SEM-FIML) Overall System Autocorrelation Tests
{helpb lmhsem}{col 12}(SEM-FIML) Overall System Heteroscedasticity Tests
{helpb lmnsem}{col 12}(SEM-FIML) Overall System Non Normality Tests
{helpb lmcovsem}{col 12}(SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2sem}{col 12}(SEM-FIML) Overall System R2, F-Test, and Chi2-Test
{helpb diagsem}{col 12}(SEM-FIML) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (8) (NL-SUR) * Non Linear Seemingly Unrelated Regression Tests:}}
{helpb lmanlsur}{col 12}(NL-SUR) Overall System Autocorrelation Tests
{helpb lmhnlsur}{col 12}(NL-SUR) Overall System Heteroscedasticity Tests
{helpb lmnnlsur}{col 12}(NL-SUR) Overall System Non Normality Tests
{helpb lmcovnlsur}{col 12}(NL-SUR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2nlsur}{col 12}(NL-SUR) Overall System R2, F-Test, and Chi2-Test
{helpb diagnlsur}{col 12}(NL-SUR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (9) (VAR) * Vector Autoregressive Model Tests:}}
{helpb lmavar}{col 12}(VAR) Overall System Autocorrelation Tests
{helpb lmhvar}{col 12}(VAR) Overall System Heteroscedasticity Tests
{helpb lmnvar}{col 12}(VAR) Overall System Non Normality Tests
{helpb lmcovvar}{col 12}(VAR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb r2var}{col 12}(VAR) Overall System R2, F-Test, and Chi2-Test
{helpb diagvar}{col 12}(VAR) Overall System ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------

{psee}
{p_end}


