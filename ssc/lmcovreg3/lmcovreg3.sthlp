{smcl}
{hline}
{cmd:help: {helpb lmcovreg3}}{space 50} {cmd:dialog:} {bf:{dialog lmcovreg3}}
{hline}

{bf:{err:{dlgtab:Title}}}

{p 4 8 2}
{bf:lmcovreg3: Breusch-Pagan LM Diagonal Covariance Matrix Test after (3SLS-SURE)}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmcovreg3##01:Syntax}{p_end}
{p 5}{helpb lmcovreg3##02:Description}{p_end}
{p 5}{helpb lmcovreg3##03:Saved Results}{p_end}
{p 5}{helpb lmcovreg3##04:References}{p_end}

{p 1}*** {helpb lmcovreg3##05:Examples}{p_end}

{p 5}{helpb lmcovreg3##06:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 10 4 6}
{opt lmcovreg3}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:lmcovreg3} computes Breusch-Pagan LM Diagonal Covariance Matrix Test after:{p_end}
{p 3 2 2}- (3SLS) Three-Stage Least Squares {helpb reg3} for systems of simultaneous equations.{p_end}
{p 3 2 2}- (SUR) Seemingly Unrelated Regression {helpb sureg} for sets of equations.{p_end} 

{p 3 2 2}- 3SLS or SURE Estimations assume:{p_end} 
{p 4 7 7}1- Independence of the errors in each eqution or no correlations between different periods in the same equation.{p_end} 
{p 4 7 7}2- no correlations between the errors for any of two equtions between two different periods, this is called {cmd:"Intertemporal Correlation"}.{p_end} 
{p 4 7 7}3- correlations may be exist between different two equations, but at the same period, and this is called {cmd:"Contemporaneous Correlation"}.{p_end} 
{p 4 7 7}4- SURE can be applied when there is correlations between different two equations at the same period, or if the independent variables are differnt from equation to equation.{p_end} 
{p 4 7 7}5- If {cmd:"Contemporaneous Correlation"} does not exist, ordinary least squares (OLS) can be applied separately to each equation, the results are fully efficient and there is no need to estimate SURE.{p_end} 
{p 4 4 4} Breusch-Pagan LM can test whether contemporaneous diagonal covariance matrix is 0. (Independence of the Errors), or correlated if at least one covariance is nonzero.{p_end} 
{p 4 4 4} Ho: {cmd:no Contemporaneous Correlation}: Sig12 = Sig13 = Sig23 = ... = 0.{p_end} 
{p 4 4 4} Ha: {cmd:   Contemporaneous Correlation}: at least one Covariance is nonzero.{p_end} 

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:lmcovreg3} saves the following in {cmd:r()}:

{col 4}{cmd:r(lmcov)}{col 20}LM Diagonal Covariance Matrix Test
{col 4}{cmd:r(lmcovp)}{col 20}LM Diagonal Covariance Matrix Test P-Value
{col 4}{cmd:r(lmcovdf)}{col 20}Chi2 Degrees of Freedom

{marker 04}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 456-461.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata sysuse lmcovreg3.dta , clear}

 {cmd:* (1) SUR Model:}

	{stata sureg (y1 y2 x1 x2) (y2 y1 x3 x4)}

	{stata lmcovreg3}

	{stata return list}

 {cmd:* (2) 3SLS Model:}

	{stata reg3 (y1 y2 x1 x2) (y2 y1 x3 x4) , exog(x1 x2 x3 x4)}

	{stata lmcovreg3}

	{stata return list}
{hline}

. clear all
. sysuse lmcovreg3.dta , clear
. sureg (y1 y2 x1 x2) (y2 y1 x3 x4)

* Seemingly unrelated regression

. lmcovreg3
==============================================================================
* Breusch-Pagan LM Diagonal Covariance Matrix Test (sure) 
==============================================================================
    Ho: Diagonal Disturbance Covariance Matrix (Independent Equations)
    Ho: Run OLS  -  Ha: Run SUR

    Lagrange Multiplier Test  =    0.00149
    Degrees of Freedom        =        1.0
    P-Value > Chi2(1)         =    0.96921
==============================================================================

. reg3 (y1 y2 x1 x2) (y2 y1 x3 x4) , exog(x1 x2 x3 x4)

* Three-stage least-squares regression

. lmcovreg3
==============================================================================
* Breusch-Pagan LM Diagonal Covariance Matrix Test (3sls) 
==============================================================================
    Ho: Diagonal Disturbance Covariance Matrix (Independent Equations)
    Ho: Run OLS  -  Ha: Run 3SLS

    Lagrange Multiplier Test  =    0.99968
    Degrees of Freedom        =        1.0
    P-Value > Chi2(1)         =    0.31739
==============================================================================
{hline}

{p 2 4 2}Example of Breusch-Pagan LM Diagonal Covariance Matrix Test{p_end}
{p 6 6 2}is decribed in: [Judge, et al(1988, p.461)].{p_end}

	{stata clear all}
	{stata sysuse lmcovreg31.dta, replace}
	{stata gen ly=ln(y)}
	{stata gen lq1=ln(q1)}
	{stata gen lq2=ln(q2)}
	{stata gen lq3=ln(q3)}
	{stata gen lp1=ln(p1)}
	{stata gen lp2=ln(p2)}
	{stata gen lp3=ln(p3)}
	{stata sureg (lq1 lp1 ly) (lq2 lp2 ly)  (lq3 lp3 ly)}
	{stata lmcovreg3}
{hline}

 lmcovreg3
==============================================================================
* Breusch-Pagan LM Diagonal Covariance Matrix Test (sure) 
==============================================================================
    Ho: Diagonal Disturbance Covariance Matrix (Independent Equations)
    Ho: Run OLS  -  Ha: Run SUR

    Lagrange Multiplier Test  =   18.73338
    Degrees of Freedom        =        3.0
    P-Value > Chi2(3)         =    0.00031
==============================================================================
{hline}

{marker 06}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:LMCOVREG3 Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:LMCOVREG3: "Stata Module to Compute Breusch-Pagan Lagrange Multiplier Diagonal Covariance Matrix Test after (3SLS-SURE) Regressions"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457411.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457411.htm"}


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

