{smcl}
{hline}
{cmd:help: {helpb resetxt}}{space 50} {cmd:dialog:} {bf:{dialog resetxt}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:resetxt: Panel Data REgression Specification Error Tests (RESET)}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb resetxt##01:Syntax}{p_end}
{p 5}{helpb resetxt##02:Description}{p_end}
{p 5}{helpb resetxt##03:Model}{p_end}
{p 5}{helpb resetxt##04:Options}{p_end}
{p 5}{helpb resetxt##05:Saved Results}{p_end}
{p 5}{helpb resetxt##06:References}{p_end}

{p 1}*** {helpb resetxt##07:Examples}{p_end}

{p 5}{helpb resetxt##08:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt resetxt} {depvar} {indepvars} {ifin} {weight} , {bf:{err:id(var)}} {bf:{err:it(var)}}{p_end} 
{p 3 5 6} 
{err: [} {opt m:odel(xtbe|xtfe|xtfm|xtfrontier|xtgls|xtkmhet1|xtkmhet2|xtkmhomo|)}{p_end}
          {opt (xtmle|xtpa|xtparks|xtpcse|xtrc|xtre|xtregar|xtsa|xttobit)}

{p 4 5 6} 
{opt corr(name)} {opt panels(name)} {opt rhot:ype(name)} {opt nocons:tant}{p_end} 
{p 4 5 6} 
{opt coll cost ti tvd igls} {opt het:only} {opt ind:ep} {opt noskip tobit} {opt twos:tep} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:resetxt} computes Panel Data REgression Specification Error Tests (RESET)

	* Ho: Panel Model is Specified - Ha: Panel Model is Misspecified
	- Ramsey RESET2 Test: Y= X Yh2
	- Ramsey RESET3 Test: Y= X Yh2 Yh3
	- Ramsey RESET4 Test: Y= X Yh2 Yh3 Yh4
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

{synoptset 3 tabbed}{...}
{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Model}}}

{bf:1- model(xtbe)}{col 20}[{helpb xtreg} , be] Between-Effects Panel Regression
{bf:2- model(xtfe)}{col 20}[{helpb xtreg} , fe] Fixed-Effects Panel Regression
{bf:3- model(xtpa)}{col 20}[{helpb xtreg} , pa] Population Averaged-Effects Panel Regression

{bf:4- model(xtmle)}{col 20}[{helpb xtreg} , mle] MLE Random-Effects Panel Regression
{bf:5- model(xtfm)}{col 20}[{bf:{err:NEW}}] Fama-MacBeth Panel Regression
{bf:6- model(xtrc)}{col 20}[{helpb xtrc}] Swamy Random Coefficients Panel Regression
{bf:7- model(xtre)}{col 20}[{helpb xtreg} , re] GLS Random-Effects Panel Regression

{bf:8- model(xtgls)}{col 20}[{helpb xtgls}] Autocorrelation & Heteroskedasticity GLS Panel Regression
{bf:9- model(xtkmhomo)}{col 20}[{helpb xtgls}] Kmenta Homoscedastic GLS AR(1) Panel Regression
{col 26}{cmd:* with Options: panels(iid) corr(psar1)}
{bf:10- model(xtkmhet1)}{col 20}[{helpb xtgls}] Kmenta Heteroscedastic GLS - different AR(1) in each Panel
{col 26}{cmd:* with Options: panels(het) corr(psar1)}
{bf:11- model(xtkmhet2)}{col 20}[{helpb xtgls}] Kmenta Heteroscedastic GLS - SAME/Common AR(1) in all Panels
{col 26}{cmd:* with Options: panels(het) corr(ar1)}
{bf:12- model(xtparks)}{col 20}[{helpb xtgls}] Parks Full Heteroscedastic Cross-Section GLS AR(1) Panel Regression
{col 26}{cmd:* with Options: panels(corr) corr(psar1)}

{bf:13- model(xtpcse)}{col 20}[{helpb xtpcse}] Corrected Standard Error Panel Regression
{bf:14- model(xtregar)}{col 20}[{helpb xtregar}] AR(1) Panel Regression

{bf:15- model(xtfrontier)}{col 20}[{helpb xtfrontier}] Stochastic Frontier Panel Regression

{bf:16- model(xttobit)}{col 20}[{helpb xttobit}] Tobit Random-Effects Panel Regression


{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Options}}}

{col 3}* {cmd: {opt id(var)}{col 20}Cross Sections ID variable name}
{col 3}* {cmd: {opt it(var)}{col 20}Time Series ID variable name}

{col 3}{opt be}  Between Effects {col 33}(BE) {cmd:model(xtbe)}
{col 3}{opt fe}  Fixed-Effects {col 33}(FE) {cmd:model(xtfe, xtregar)}
{col 3}{opt re}  GLS-Random-Effects {col 33}(RE) {cmd:model(xtre)}
{col 3}{opt mle} MLE-Random-Effects {col 33}(MLE) {cmd:model(xtmle)}
{col 3}{opt pa}  Population-Averaged {col 33}(PA) {cmd:model(xtpa)}

{col 3}{opt coll}{col 20}keep collinear variables; default is removing collinear variables.

{col 3}{opt cost}{col 20}Fit Cost Frontier instead of Production Function {cmd:model({helpb xtfrontier})}

{col 3}{opt ti}{col 20}use Time-Invariant {cmd:model({helpb xtfrontier})}

{col 3}{opt tvd}{col 20}use Time-Varying Decay {cmd:model({helpb xtfrontier})}

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{col 3}{opt het:only}{col 20}assume panel-level heteroskedastic errors {cmd:model({helpb xtpcse})}

{col 3}{opt igls}{col 20}iterated GLS instead of two-step GLS {cmd:model({helpb xtgls})}

{col 3}{opt ind:ep}{col 20}assume independent errors across panels {cmd:model({helpb xtpcse})}

{col 3}{opt noskip}{col 20}likelihood-ratio test {cmd:model({helpb xttobit})}

{col 3}{opt tobit}{col 20}likelihood-ratio test comparing against pooled tobit {cmd:model({helpb xttobit})}

{col 3}{opt ll(#)}{col 20}value of minimum left-censoring dependent variable
{col 20}with {cmd:model({helpb xttobit})}. Default is 0

{col 3}{opt twos:tep}{col 20}two-step estimate {cmd:model({helpb xtregar})}

{col 3}{cmdab:p:anels:(}{cmdab:i:id)}{col 20}Homoscedastic Error with No Cross-Sections Correlation
{col 21}{cmd:model({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}

{col 3}{cmdab:p:anels:(}{cmdab:h:et)}{col 20}Heteroscedastic Error with No Cross-Sections Correlation
{col 21}{cmd:model({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}

{col 3}{cmdab:p:anels:(}{cmdab:c:orr)}{col 20}Heteroscedastic Error with Cross-Sections Correlation
{col 21}{cmd:model({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}

{col 3}{cmdab:c:orr:(}{cmdab:i:ndep)}{col 20}No Autocorrelation within Panels
{col 21}{cmd:model({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}

{col 3}{cmdab:c:orr:(}{cmdab:ar1)}{col 20}Common AR(1) Autocorrelation within Panels
{col 21}{cmd:model({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}

{col 3}{cmdab:c:orr:(}{cmdab:psar1)}{col 20}AR(1) Autocorrelation within Panels, and in each Panel
{col 21}{cmd:model({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}

{col 3}{cmdab:c:orr:(}{cmdab:c:orr)}{col 20}Autocorrelation within Panels
{col 21}{cmd:model({helpb xtgls}, {helpb xtpcse}, {helpb xtregar})}

{phang}
{opt rhot:ype(rhomethod)} types of Rho estimators {cmd:model({helpb xtpcse}, {helpb xtregar})}:{p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:dw)}{space 7} Durbin-Watson: rho_dw = 1 - dw/2{p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:reg:ress)}{space 2} rho_reg = B from residual regression e_t = B*e_(t-1){p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:freg)}{space 5} rho_leads = B from residual regression e_t = B*e_(t+1){p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:tsc:orr)}{space 3} time series autocorrelation: rho_tscorr = e'e_(t-1)/e'e{p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:th:eil)}{space 4} Theil = rho_tscorr * (N-k)/N{p_end}
{p 5 16 2}{cmd:rhotype(}{cmdab:nag:ar)}{space 4} rho_nagar = (rho_dw * N*N+k*k)/(N*N-k*k){p_end}
{p 5 26 2}{cmd:rhotype(}{cmdab:one:step)}{space 2} rho_onestep = (n/m_c)*rho_tscorr, where n is obs. and m_c is number of consecutive pairs of residuals


{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:resetxt} saves the following results in {cmd:e()}:

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

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{p 4 8 2}DeBenedictis, L. F. & Giles D. E. A. (1998)
{cmd: "Diagnostic Testing in Econometrics: Variable Addition, RESET and Fourier Approximations",}
{it:In: A. Ullah  & D. E. A. Giles (Eds.), Handbook of Applied Economic Statistics. Marcel Dekker, New York}; 383-417.

{p 4 8 2}Fama, E. F., & J. D. MacBeth (1973)
{cmd:"Risk, Return, and Equilibrium: Empirical Tests"}
{it:Journal of Political Economy, Vol. 81, Issue 3}; 607-636.

{p 4 8 2} Fuller, W.A. & G.E. Battese (1974)
{cmd: "Estimation of Linear Models with Cross-Error Structure",}
{it:Journal of Econometrics, 2}; 67–78.

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

{p 4 8 2}Kmenta, Jan (1986)
{cmd: "Elements of Econometrics",}
{it:2nd ed., Macmillan Publishing Company, Inc., New York, USA}; 618-625.

{p 4 8 2}Parks, R. (1967)
{cmd: "Efficient Estimation of a System of Regression Equations when Disturbances are Both Serially and Contemporaneously Correlated",}
{it: Journal of the American Statisical Association, 62}; 500-509.

{p 4 8 2}Ramsey, J. B. (1969)
{cmd: "Tests for Specification Errors in Classical Linear Least-Squares Regression Analysis",}
{it: Journal of the Royal Statistical Society, Series B 31}; 350-371.

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:Examples}}}

  {stata clear all}

  {stata sysuse resetxt.dta, clear}

  {stata db resetxt}

  {stata xtset id t}

{bf:{err:* Between-Effects Panel Regression:}}
* xtbe     {stata resetxt y x1 x2 , id(id) it(t) model(xtbe)}

{bf:{err:* Fama-MacBeth Model Panel Regression}}
* xtfm     {stata resetxt y x1 x2 , id(id) it(t) model(xtfm)}

{bf:{err:* Fixed-Effects Panel Regression:}}
* xtfe     {stata resetxt y x1 x2 , id(id) it(t) model(xtfe)}

{bf:{err:* Population-Averaged Effects Panel Regression}}
* xtpa     {stata resetxt y x1 x2 , id(id) it(t) model(xtpa)}

{bf:{err:* Random-Effects MLE Panel Regression}}
* xtmle    {stata resetxt y x1 x2 , id(id) it(t) model(xtmle)}

{bf:{err:* Swamy Random-Coefficients Panel Regression}}
* xtrc     {stata resetxt y x1 x2 , id(id) it(t) model(xtrc)}

{bf:{err:* Random-Effects GLS Panel Regression}}
* xtre     {stata resetxt y x1 x2 , id(id) it(t) model(xtre)}

{bf:{err:* Autocorrelation & Heteroskedasticity Generalized Least Squares Panel Regression}}
* xtgls    {stata resetxt y x1 x2 , id(id) it(t) model(xtgls)}

{bf:{err:* Kmenta Homoscedastic Generalized Least Squares AR(1) Panel Regression}}
* xtkmhomo {stata resetxt y x1 x2 , id(id) it(t) model(xtkmhomo)}

{bf:{err:* Kmenta Heteroscedastic GLS AR(1) different in each Panel}}
* xtkmhet1 {stata resetxt y x1 x2 , id(id) it(t) model(xtkmhet1)}

{bf:{err:* Kmenta Heteroscedastic GLS AR(1) SAME/Common in all Panels}}
* xtkmhet2 {stata resetxt y x1 x2 , id(id) it(t) model(xtkmhet2)}

{bf:{err:* Parks (FULL) Heteroscedastic Cross-Section GLS AR(1) Panel Regression}}
* xtparks  {stata resetxt y x1 x2 , id(id) it(t) model(xtparks)}

{bf:{err:* Linear Corrected Standard Error (PCSE) Panel Regression}}
* xtpcse   {stata resetxt y x1 x2 , id(id) it(t) model(xtpcse)}

{bf:{err:* Linear AR(1) Panel Regression}}
* xtregar  {stata resetxt y x1 x2 , id(id) it(t) model(xtregar)}

{bf:{err:* Frontier Panel Regression}}
* xtfrontier {stata resetxt y x1 x2 , id(id) it(t) model(xtfrontier) ti}
* xtfrontier {stata resetxt y x1 x2 , id(id) it(t) model(xtfrontier) tvd}
* xtfrontier {stata resetxt y x1 x2 , id(id) it(t) model(xtfrontier) ti cost}

{bf:{err:* Tobit Panel Regression}}
* xttobit  {stata resetxt y x1 x2 , id(id) it(t) model(xttobit)}
{hline}

. clear all
. sysuse resetxt.dta, clear
. resetxt y x1 x2 , id(id) it(t) model(xtmle)

==============================================================================
* MLE Random-Effects Panel Data Regression
==============================================================================
  y = x1 + x2
------------------------------------------------------------------------------
 Sample Size        =          49   |   Cross Sections Number   =           7
 Wald Test          =     56.6673   |   P-Value > Chi2(2)       =      0.0000
 F-Test             =     28.3337   |   P-Value > F(2 , 40)     =      0.0000
 R2  (R-Squared)    =      0.5345   |   Raw Moments R2          =      0.9154
 R2a (Adjusted R2)  =      0.4414   |   Raw Moments R2 Adj      =      0.8984
 Root MSE (Sigma)   =     12.5053   |   Log Likelihood Function =   -180.4529
------------------------------------------------------------------------------
- R2h= 0.5500   R2h Adj= 0.4599  F-Test =   28.11 P-Value > F(2 , 40)  0.0000
- R2v= 0.3811   R2v Adj= 0.2573  F-Test =   14.16 P-Value > F(2 , 40)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
y            |
          x1 |   -.267284   .0802264    -3.33   0.002    -.4294276   -.1051405
          x2 |  -1.216145   .2792884    -4.35   0.000    -1.780608   -.6516825
       _cons |   62.88424   4.842509    12.99   0.000     53.09716    72.67131
------------------------------------------------------------------------------

==============================================================================
*** REgression Specification Error Tests (RESET) - Model= (xtmle)
==============================================================================
 Ho: Model is Specified  -  Ha: Model is Misspecified
------------------------------------------------------------------------------
* Ramsey Specification ResetF Test
- Ramsey RESETF1 Test: Y= X Yh2         =   4.001  P-Value > F(1,  45) 0.0515
- Ramsey RESETF2 Test: Y= X Yh2 Yh3     =   1.994  P-Value > F(2,  44) 0.1483
- Ramsey RESETF3 Test: Y= X Yh2 Yh3 Yh4 =   2.403  P-Value > F(3,  43) 0.0806
------------------------------------------------------------------------------
* DeBenedictis-Giles Specification ResetL Test
- Debenedictis-Giles ResetL1 Test       =   1.908  P-Value > F(2, 44)  0.1605
- Debenedictis-Giles ResetL2 Test       =   1.391  P-Value > F(4, 42)  0.2535
- Debenedictis-Giles ResetL3 Test       =   1.449  P-Value > F(6, 40)  0.2205
------------------------------------------------------------------------------
* DeBenedictis-Giles Specification ResetS Test
- Debenedictis-Giles ResetS1 Test       =   0.236  P-Value > F(2, 44)  0.7910
- Debenedictis-Giles ResetS2 Test       =   2.083  P-Value > F(4, 42)  0.1001
- Debenedictis-Giles ResetS3 Test       =   2.192  P-Value > F(6, 40)  0.0639
------------------------------------------------------------------------------
- White Functional Form Test: E2= X X2  =   6.621  P-Value > Chi2(1)   0.0365
------------------------------------------------------------------------------

{p2colreset}{...}
{marker 08}{bf:{err:{dlgtab:Authors}}}

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

{bf:{err:{dlgtab:RESETXT Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2015)}{p_end}
{p 1 10 1}{cmd:RESETXT: "Stata Module to Compute Panel Data REgression Specification Error Tests (RESET)"}{p_end}


{title:Online Help:}

{p 2 12 2}Official: {helpb xtdpd}, {helpb xtfrontier}, {helpb xtgls}, {helpb xtivreg}, {helpb xtpcse}, {helpb xtrc}, {helpb xtreg}, {helpb xtregar}, {helpb xttobit}.{p_end}
---------------------------------------------------------------------------

{bf:{err:Panel Data Regression Models:}}
{helpb regxt}{col 12}Panel Data Econometric Regression Models: Stata Module Toolkit
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

{bf:{err:* Model Selection Diagnostic Criteria:}}
{helpb diagmle}{col 12}MLE Model Selection Diagnostic Criteria
{helpb diagnl}{col 12}NLS Model Selection Diagnostic Criteria
{helpb diagnlsur}{col 12}(NL-SUR) Overall System ModeL Selection Diagnostic Criteria
{helpb diagreg}{col 12}OLS Model Selection Diagnostic Criteria
{helpb diagreg2}{col 12}2SLS-IV Model Selection Diagnostic Criteria
{helpb diagreg3}{col 12}(3SLS-SUR) Overall System ModeL Selection Diagnostic Criteria
{helpb diagsem}{col 12}(SEM-FIML) Overall System ModeL Selection Diagnostic Criteria
{helpb diagvar}{col 12}(VAR) Overall System ModeL Selection Diagnostic Criteria
{helpb diagxt}{col 12}Panel Data ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* Linear vs Log-Linear Functional Form Tests:}}
{helpb lmfmle}{col 12}MLE Linear vs Log-Linear Functional Form Tests
{helpb lmfreg}{col 12}OLS Linear vs Log-Linear Functional Form Tests
{helpb lmfreg2}{col 12}2SLS-IV Linear vs Log-Linear Functional Form Tests
---------------------------------------------------------------------------
{helpb lmhaus2}{col 12}2SLS-IV Hausman Specification Test
{helpb lmhausxt}{col 12}Panel Data Hausman Specification Test
---------------------------------------------------------------------------
{helpb lmiden2}{col 12}2SLS-IV Over Identification Restrictions Tests
---------------------------------------------------------------------------
{helpb lmeg}{col 12}Augmented Engle-Granger Cointegration Test
{helpb lmgc}{col 12}2SLS-IV Granger Causality Test
{helpb lmsrd}{col 12}OLS Spurious Regression Diagnostic
---------------------------------------------------------------------------
{bf:{err:* REgression Specification Error Tests (RESET):}}
{helpb reset}{col 12}OLS REgression Specification Error Tests (RESET)
{helpb reset2}{col 12}2SLS-IV REgression Specification Error Tests (RESET)
{helpb resetmle}{col 12}MLE REgression Specification Error Tests (RESET)
{helpb resetxt}{col 12}Panel Data REgression Specification Error Tests (RESET)
---------------------------------------------------------------------------

{psee}
{p_end}

