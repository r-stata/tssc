{smcl}
{hline}
{cmd:help: {helpb lmcovxt}}{space 50} {cmd:dialog:} {bf:{dialog lmcovxt}}
{hline}

{bf:{err:{dlgtab:Title}}}

{p 4 8 2}
{bf:lmcovxt: Panel Data Breusch-Pagan Diagonal Covariance Matrix LM Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmcovxt##01:Syntax}{p_end}
{p 5}{helpb lmcovxt##02:Options}{p_end}
{p 5}{helpb lmcovxt##03:Description}{p_end}
{p 5}{helpb lmcovxt##04:Saved Results}{p_end}
{p 5}{helpb lmcovxt##05:References}{p_end}

{p 1}*** {helpb lmcovxt##06:Examples}{p_end}

{p 5}{helpb lmcovxt##07:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 4 4 6}
{opt lmcovxt} {depvar} {indepvars} {ifin} {weight} , {bf:{err:id(var)}} {bf:{err:it(var)}} {err:[}{opt nocons:tant} {opth vce(vcetype)} {opt l:evel(#)}{err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}
{p 1 1 1}

{synoptset 15 tabbed}{...}

{col 3}* {cmd: {opt id(var)}{col 20}Cross Sections ID variable name}
{col 3}* {cmd: {opt it(#)}{col 20}Time Series ID variable name}

{col 3}{opt nocons:tant}{col 20}suppress constant term

{synopt :{opth vce(vcetype)}}{opt ols}, {opt r:obust}, {opt cl:uster}, {opt boot:strap}, {opt jack:knife}, {opt hc2}, {opt hc3}{p_end}

{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:lmcovxt} computes Panel Data Breusch-Pagan Diagonal Covariance Matrix LM Test.{p_end} 
{p 2 2 2} for balanced cross sections data.{p_end} 
{p 2 2 2} Ho: Null hypothesis of diagonal covariance matrix means no cross-section correlation. LM test has an asymptotic Chi2 distribution with [N(N-1)/2] degrees of freedom.{p_end}

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:lmcovxt} saves the following in {cmd:r()}:

{col 4}{cmd:r(lmcov)}{col 20}LM Diagonal Covariance Matrix Test
{col 4}{cmd:r(lmcovp)}{col 20}LM Diagonal Covariance Matrix Test P-Value
{col 4}{cmd:r(lmcovdf)}{col 20}Chi2 Degrees of Freedom

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

  {stata sysuse lmcovxt.dta, clear}

  {stata db lmcovxt}

  {stata lmcovxt y x1 , id(id) it(t)}

==============================================================================
* Panel Data Breusch-Pagan Diagonal Covariance Matrix LM Test
==============================================================================
    Ho: Run OLS Regression  -  Ha: Run Panel Regression

    Lagrange Multiplier Test  =   25.23999
    Degrees of Freedom        =        6.0
    P-Value > Chi2(6)         =    0.00031
==============================================================================

{marker 07}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:LMCOVXT Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:LMCOVXT: "Stata Module to Compute Panel Data Breusch-Pagan Diagonal Covariance Matrix LM Test"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457412.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457412.htm"}


{title:Online Help:}

{p 2 12 2}Official: {helpb xtdpd}, {helpb xtfrontier}, {helpb xtgls}, {helpb xtivreg}, {helpb xtpcse}, {helpb xtrc}, {helpb xtreg}, {helpb xtregar}, {helpb xttobit}.{p_end}
---------------------------------------------------------------------------

{bf:{err:* Breusch-Pagan Diagonal Covariance Matrix Test:}}
{helpb lmcovreg3}{col 12}(3SLS-SUR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovsem}{col 12}(SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovnlsur}{col 12}(NL-SUR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovvar}{col 12}(VAR) Breusch-Pagan Diagonal Covariance Matrix Test
{helpb lmcovxt}{col 12}Panel Data Breusch-Pagan Diagonal Covariance Matrix Test
---------------------------------------------------------------------------

{bf:{err:Panel Data Regression Models:}}
{helpb diagxt}{col 12}Panel Data Models: Ridge & Weighted Regression
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

{bf:{err:Panel Data Tests:}}

{bf:{err:* (1) * Autocorrelation Tests:}}
{helpb lmaxt}{col 12}Panel Data Autocorrelation Tests
{helpb lmabxt}{col 12}Panel Data Autocorrelation Baltagi Test
{helpb lmabgxt}{col 12}Panel Data Autocorrelation Breusch-Godfrey Test
{helpb lmabpxt}{col 12}Panel Data Autocorrelation Box-Pierce Test
{helpb lmabpgxt}{col 12}Panel Data Autocorrelation Breusch-Pagan-Godfrey Test
{helpb lmadurhxt}{col 12}Panel Data Autocorrelation Dynamic Durbin h and Harvey LM Tests
{helpb lmadurmxt}{col 12}Panel Data Autocorrelation Dynamic Durbin m Test
{helpb lmadwxt}{col 12}Panel Data Autocorrelation Durbin-Watson Test
{helpb lmavonxt}{col 12}Panel Data Von Neumann Ratio Autocorrelation Test
{helpb lmawxt}{col 12}Panel Data Autocorrelation Wooldridge Test
{helpb lmazxt}{col 12}Panel Data Autocorrelation Z Test
---------------------------------------------------------------------------
{bf:{err:* (2) * Heteroscedasticity Tests:}}
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
{bf:{err:* (3) * Non Normality Tests:}}
{helpb lmnxt}{col 12}Panel Data Non Normality Tests
{helpb lmnadxt}{col 12}Panel Data Non Normality Anderson-Darling Test
{helpb lmndhxt}{col 12}Panel Data Non Normality Doornik-Hansen Test
{helpb lmndpxt}{col 12}Panel Data Non Normality D'Agostino-Pearson Test
{helpb lmngryxt}{col 12}Panel Data Non Normality Geary Runs Test
{helpb lmnjbxt}{col 12}Panel Data Non Normality Jarque-Bera Test
{helpb lmnwhitext}{col 12}Panel Data Non Normality White Test
---------------------------------------------------------------------------
{bf:{err:* (4) * Panel Data Error Component Tests:}}
{helpb lmecxt}{col 12}Panel Data Error Component Tests
---------------------------------------------------------------------------
{bf:{err:* (5) * Panel Data Diagonal Covariance Matrix Test:}}
{helpb lmcovxt}{col 12}Panel Data Breusch-Pagan Diagonal Covariance Matrix LM Test
---------------------------------------------------------------------------
{bf:{err:* (6) * Panel Data ModeL Selection Diagnostic Criteria:}}
{helpb diagxt}{col 12}Panel Data ModeL Selection Diagnostic Criteria
---------------------------------------------------------------------------
{bf:{err:* (7) * Panel Data Specification Tests:}}
{helpb lmhausxt}{col 12}Panel Data Hausman Specification Test
{helpb resetxt}{col 12}Panel Data REgression Specification Error Tests (RESET)
---------------------------------------------------------------------------
{bf:{err:* (8) * Panel Data Identification Variables:}}
{helpb xtidt}{col 14}Identification Variables in Panel Data
---------------------------------------------------------------------------

{psee}
{p_end}

