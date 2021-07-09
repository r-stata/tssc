{smcl}
{hline}
{cmd:help: {helpb almon1}}{space 50} {cmd:dialog:} {bf:{dialog almon1}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: almon1: Shirley Almon Polynomial Distributed Lag Model}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb almon1##01:Syntax}{p_end}
{p 5}{helpb almon1##02:Description}{p_end}
{p 5}{helpb almon1##03:Model}{p_end}
{p 5}{helpb almon1##04:End Point Polynomial Restrictions Options}{p_end}
{p 5}{helpb almon1##05:Other Options}{p_end}
{p 5}{helpb almon1##06:Model Selection Diagnostic Criteria}{p_end}
{p 5}{helpb almon1##07:Autocorrelation Tests}{p_end}
{p 5}{helpb almon1##08:Heteroscedasticity Tests}{p_end}
{p 5}{helpb almon1##09:Non Normality Tests}{p_end}
{p 5}{helpb almon1##10:Saved Results}{p_end}
{p 5}{helpb almon1##11:References}{p_end}

{p 1}*** {helpb almon1##12:Examples}{p_end}

{p 5}{helpb almon1##13:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{cmd:almon1} {depvar} {it:{help varname:indepvar}} {ifin} , {err:[} {opt model(ols, als, gls, arch)}{p_end} 
{p 5 5 6} 
{opt lag(#)} {opt pdl(#)} {opt end:pr(0,1,2,3)} {opt ord:er(#)} {opt nocons:tant} {opt nol:ag} {opt mfx(lin, log)} {opt tolog} {opt wvar(name)} {p_end} 
{p 5 5 6} 
{opt iter:ate(#)} {opt tech:nique(name)} {opt diag dn test ominv} {opt pred:ict(new_var)} {opt res:id(new_var)} {opt l:evel(#)} {err:]}{p_end} 
{marker 02}{bf:{err:{dlgtab:Description}}}

{pstd}
{cmd:almon1} estimates Shirley Almon Polynomial Distributed Lag Model for many variables with the same lag order, endpoint restrictions, and polynomial degree order via (OLS - ALS - GLS - ARCH) Regression models.

{pstd}
{cmd:almon1} used Allen McDowell (2004, p183) for polynomial order with some modifications to allow
inclusion or exclusion intercept, and also for estimation (ALS) and (ARCH) models.

{pstd}
{cmd:almon1} can compute:

{p 2 5 5}1- Autocorrelation, Heteroscedasticity, and Non Normality Tests.{p_end}

{p 2 5 5}2- Model Selection Diagnostic Criteria.{p_end}

{p 2 5 5}3- Marginal effects and elasticities in both short and long run.{p_end}

{p 2 5 5}4- Impact or short run multiplier, and long run or total distributed lag multiplier is the sum of lag coefficients for each variable. SUM(Coefs.) is called Long Run Dynamic Multiplier{p_end}

{p 2 5 5}5- Mean lag gives a measure of the speed of adjustment,it has a useful interpretation if lag coefficients are all positive, so the full time period to response is (Full Lag = Mean Lag +1){p_end}

{p 2 5 5}6- Joint-F or Joint Chi2-Test to test the null hypothesis that all coefficients associated with the distributed lag variable are simultaneously equal to zero.{p_end}

{p 2 5 5}7- lag(#) order always starts from (0).{p_end}

{p 2 5 5}8- If pdl(0) and endpr(0) then unrestricted lag model is estimated.{p_end}

{p 2 5 5}9- Almon Polynomial Distributed Lag Model is useful in estimating supply response function for durable goods or perennial crops.

{p 3 4 2} R2, R2 Adjusted, and F-Test, are obtained from 4 ways:{p_end} 
{p 5 4 2} 1- (Buse 1973) R2.{p_end}
{p 5 4 2} 2- Raw Moments R2.{p_end}
{p 5 4 2} 3- squared correlation between predicted (Yh) and observed dependent variable (Y).{p_end}
{p 5 4 2} 4- Ratio of variance between predicted (Yh) and observed dependent variable (Y).{p_end}

{p 5 4 2} - Adjusted R2: R2_a=1-(1-R2)*(N-1)/(N-K-1).{p_end}
{p 5 4 2} - F-Test=R2/(1-R2)*(N-K-1)/(K).{p_end}

{marker 03}{bf:{err:{dlgtab:Model}}}

{synoptset 16}{...}
{p2coldent:{it:model}}description{p_end}
{synopt:{opt ols}}Ordinary Least Squares (OLS){p_end}
{synopt:{opt als}}Autoregressive Least Squares (ALS){p_end}
{synopt:{opt gls}}Generalized Least Squares (GLS){p_end}
{synopt:{opt arch}}Autoregressive Conditional Heteroskedasticity (ARCH){p_end}

{marker 04}{bf:{err:{dlgtab:End Point Restriction Options}}}

{synoptset 16}{...}
{p2coldent:{it:endpr Options}}Description{p_end}

{col 3}{opt endp:pr(0)}{col 20}No Endpoint Polynomial Restrictions; the default
{col 3}{opt endp:pr(1)}{col 20}Left Side Endpoint Polynomial Restrictions
{col 3}{opt endp:pr(2)}{col 20}Right Side Endpoint Polynomial Restrictions
{col 3}{opt endp:pr(3)}{col 20}Left & Right Side Endpoint Polynomial Restrictions

{pstd}
Lag Length {cmd:lag(#)} must be greater than Polynomial Degree {cmd:pdl(#)}} by at lesat (1)

{pstd}
Endpoint restrictions may be specified for any polynomial. The use of Endpoint restrictions increases the number of restrictions imposed in the model.

{marker 05}{bf:{err:{dlgtab:Other Options}}}
{synoptset 16}{...}

{col 3}{opt lag(#)}{col 20}Lag Length Order of Polynomial Distributed Lag Model; default (3)

{col 3}{opt pdl(#)}{col 20}Polynomial Degree Order (Pascal Triangle); default (2)

{pstd}
{almon1} estimates Almon polynomial distributed lag model at the same order with respect to: lag length, order of polynomial and Endpoint restriction on any independent variable in the model.

{col 3}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{col 3}{opt nol:ag}{col 20}Use Independent Variables in current period X(t), instead of lag X(t-1)

{col 3}{opt pred:ict(new_var)}{col 20}Predicted values variable

{col 3}{opt res:id(new_var)}{col 20}Residuals values variable

{col 3}{opt dn}{col 20}Use (N) divisor instead of (N-K) for Degrees of Freedom (DF) in {cmd:(diag)} 

{col 3}{opt ord:er(#)}{col 20}Lag Order for (ALS) and (ARCH) Models; default (1)

{col 3}{opt wvar(var)}{col 20}required variable name for Omega or Omega Inverse in {cmd:(GLS)} model

{col 3}{opt ominv}{col 20}Use Omega Inverse instead of Omega in {cmd:(GLS)} model

{col 3}{opt mfx(lin, log)}{col 20}functional form: Linear model {cmd:(lin)}, or Log-Log model {cmd:(log)},
{col 20}to compute Marginal Effects and Elasticities
   - In Linear model: marginal effects are the coefficients (Bm),
        and elasticities are (Es = Bm X/Y).
   - In Log-Log model: elasticities are the coefficients (Es),
        and the marginal effects are (Bm = Es Y/X).
     - {opt mfx(log)} and {opt tolog} options must be combined, to transform variables to log form.

{col 3}{opt tolog}{col 20}Convert dependent and independent variables
{col 20}to LOG Form in the memory for Log-Log regression.
{col 20}{opt tolog} Transforms {depvar} and {indepvars}
{col 20}to Log Form without lost the original data variables

{col 3}{opt iter:ate(#)}{col 20}number of iterations; Default is iter(300)

{col 3}{opt tech:nique(name)}{col 20}specifies how the likelihood function is to be maximized

{col 3}{opt technique(nr)}{col 20}Newton-Raphson (NR) algorithm ; The default.
{col 3}{opt technique(bhhh)}{col 20}Berndt-Hall-Hall-Hausman (BHHH) algorithm.
{col 3}{opt technique(dfp)}{col 20} Davidon-Fletcher-Powell (DFP) algorithm.
{col 3}{opt technique(bfgs)}{col 20} Broyden-Fletcher-Goldfarb-Shanno (BFGS) algorithm.

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Model Selection Diagnostic Criteria}}}
        - Log Likelihood Function                   LLF
        - Akaike Information Criterion              (1974) AIC
        - Akaike Information Criterion              (1973) Log AIC
        - Schwarz Criterion                         (1978) SC
        - Schwarz Criterion                         (1978) Log SC
        - Amemiya Prediction Criterion              (1969) FPE
        - Hannan-Quinn Criterion                    (1979) HQ
        - Rice Criterion                            (1984) Rice
        - Shibata Criterion                         (1981) Shibata
        - Craven-Wahba Generalized Cross Validation (1979) GCV

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:Autocorrelation Tests}}}
 	Ho: No Autocorrelation - Ha: Autocorrelation
	- Breusch-Godfrey LM Test (drop 1 obs)
	- Breusch-Godfrey LM Test (keep 1 obs)
	- Breusch-Pagan-Godfrey LM Test

{p2colreset}{...}
{marker 08}{bf:{err:{dlgtab:Heteroscedasticity Tests}}}
 	Ho: Homoscedasticity - Ha: Heteroscedasticity
	- Engle LM ARCH Test
	- Hall-Pagan LM Test:      E2 = Yh
	- Hall-Pagan LM Test:      E2 = Yh2
	- Hall-Pagan LM Test:      E2 = LYh2

{p2colreset}{...}
{marker 09}{bf:{err:{dlgtab:Non Normality Tests}}}
 	Ho: Normality - Ha: Non Normality
	- Jarque-Bera LM Test

{marker 10}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:almon1} saves the following in {cmd:e()}:

{err:*** Model Selection Diagnostic Criteria:}
{col 4}{cmd:e(N)}{col 20}number of observations
{col 4}{cmd:e(r2bu)}{col 20}R-squared (Buse 1973)
{col 4}{cmd:e(r2bu_a)}{col 20}R-squared Adj (Buse 1973)
{col 4}{cmd:e(r2raw)}{col 20}Raw Moments R2
{col 4}{cmd:e(r2raw_a)}{col 20}Raw Moments R2 Adj
{col 4}{cmd:e(f)}{col 20}F-test
{col 4}{cmd:e(fp)}{col 20}F-test P-Value
{col 4}{cmd:e(wald)}{col 20}Wald-test
{col 4}{cmd:e(waldp)}{col 20}Wald-test P-Value
{col 4}{cmd:e(r2h)}{col 20}R2 Between Predicted (Yh) and Observed DepVar (Y)
{col 4}{cmd:e(r2h_a)}{col 20}Adjusted r2h
{col 4}{cmd:e(fh)}{col 20}F-test due to r2h
{col 4}{cmd:e(fhp)}{col 20}F-test due to r2h P-Value
{col 4}{cmd:e(r2v)}{col 20}R2 Variance Ratio Between Predicted (Yh) and Observed DepVar (Y)
{col 4}{cmd:e(r2v_a)}{col 20}Adjusted r2v
{col 4}{cmd:e(fv)}{col 20}F-test due to r2v
{col 4}{cmd:e(fvp)}{col 20}F-test due to r2v P-Value
{col 4}{cmd:e(sig)}{col 20}Root MSE (Sigma)
{col 4}{cmd:e(llf)}{col 20}Log Likelihood Function{col 62}LLF
{col 4}{cmd:e(aic)}{col 20}Akaike Information Criterion{col 62}(1974) AIC
{col 4}{cmd:e(laic)}{col 20}Akaike Information Criterion{col 62}(1973) Log AIC
{col 4}{cmd:e(sc)}{col 20}Schwarz Criterion{col 62}(1978) SC
{col 4}{cmd:e(lsc)}{col 20}Schwarz Criterion{col 62}(1978) Log SC
{col 4}{cmd:e(fpe)}{col 20}Amemiya Prediction Criterion{col 62}(1969) FPE
{col 4}{cmd:e(hq)}{col 20}Hannan-Quinn Criterion{col 62}(1979) HQ
{col 4}{cmd:e(rice)}{col 20}Rice Criterion{col 62}(1984) Rice
{col 4}{cmd:e(shibata)}{col 20}Shibata Criterion{col 62}(1981) Shibata
{col 4}{cmd:e(gcv)}{col 20}Craven-Wahba Generalized Cross Validation (1979) GCV

{err:*** Autocorrelation Tests:}
{col 4}{cmd:e(lmabgd#)}{col 20}Breusch-Godfrey LM Test (drop i obs)
{col 4}{cmd:e(lmabgdp#)}{col 20}Breusch-Godfrey LM Test (drop i obs) P-Value
{col 4}{cmd:e(lmabgk#)}{col 20}Breusch-Godfrey LM Test (keep i obs)
{col 4}{cmd:e(lmabgkp#)}{col 20}Breusch-Godfrey LM Test (keep i obs) P-Value
{col 4}{cmd:e(lmabpg#)}{col 20}Breusch-Pagan-Godfrey LM Test AR(i)
{col 4}{cmd:e(lmabpgp#)}{col 20}Breusch-Pagan-Godfrey LM Test AR(i) P-Value

{err:*** Heteroscedasticity Tests:}
{col 4}{cmd:e(lmharch)}{col 20}Engle LM ARCH Test AR(i)
{col 4}{cmd:e(lmharchp)}{col 20}Engle LM ARCH Test AR(i) P-Value
{col 4}{cmd:e(lmhhp1)}{col 20}Hall-Pagan LM Test
{col 4}{cmd:e(lmhhp1p)}{col 20}Hall-Pagan LM Test P-Value
{col 4}{cmd:e(lmhhp2)}{col 20}Hall-Pagan LM Test
{col 4}{cmd:e(lmhhp2p)}{col 20}Hall-Pagan LM Test P-Value
{col 4}{cmd:e(lmhhp3)}{col 20}Hall-Pagan LM Test
{col 4}{cmd:e(lmhhp3p)}{col 20}Hall-Pagan LM Test P-Value

{err:*** Non Normality Tests:}
{col 4}{cmd:e(lmnjb)}{col 20}Jarque-Bera LM Test
{col 4}{cmd:e(lmnjbp)}{col 20}Jarque-Bera LM Test P-Value

Matrixes
{col 4}{cmd:e(b)}{col 20}coefficient vector
{col 4}{cmd:e(V)}{col 20}variance-covariance matrix of the estimators

{marker 11}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Shirley Montag Almon (1935–1975)
{browse "http://en.wikipedia.org/wiki/Shirley_Montag_Almon"}

{p 4 8 2} Almon, Shirley (1965)
{cmd:The Distributed Lag Between Capital Appropriations and Expenditures,}
{it:Econometrica, Vol. 33, No. 1, Jan.;} 178-196.

{p 4 8 2} Almon, Shirley (1968)
{cmd:Lags Between Investment Decisions and Their Causes,}
{it:Rev. Econ. Stat., Vol. 50;} 193-206.

{p 4 8 2}Breusch, Trevor (1978)
{cmd: "Testing for Autocorrelation in Dynamic Linear Models",}
{it:Aust. Econ. Papers, Vol. 17}; 334-355.

{p 4 8 2}Breusch, Trevor & Adrian Pagan (1980)
{cmd: "The Lagrange Multiplier Test and its Applications to Model Specification in Econometrics",}
{it:Review of Economic Studies 47}; 239-253.

{p 4 8 2}C.M. Jarque  & A.K. Bera (1987)
{cmd: "A Test for Normality of Observations and Regression Residuals"}
{it:International Statistical Review}, Vol. 55; 163-172.

{p 4 8 2}Damodar Gujarati (2004)
{cmd: "Basic Econometrics"}
{it:4th Edition, McGraw Hill, New York, USA}; 687.

{p 4 8 2}Damodar Gujarati & Dawn C. Porter (2009)
{cmd: "Basic Econometrics"}
{it:5th Edition, McGraw Hill, New York, USA}; 645.

{p 4 8 2}Engle, Robert (1982)
{cmd: "Autoregressive Conditional Heteroscedasticity with Estimates of Variance of United Kingdom Inflation"}
{it:Econometrica, 50(4), July, 1982}; 987-1007.

{p 4 8 2} Frost, P.A. (1975)
{cmd:"Some Properties of the Almon Lag Technique When One Searches for Degree of Polynomial and Lag,}
{it:J. Amer. Stat. Assoc., Vol. 70, March}; 606-612.

{p 4 8 2}Godfrey, L. (1978)
{cmd: "Testing for Higher Order Serial Correlation in Regression Equations when the Regressors Include Lagged Dependent Variables",}
{it:Econometrica, Vol., 46}; 1303-1310.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Upper Saddle River, NJ: Prentice-Hall}; 387-388.

{p 4 8 2}Griffiths, W., R. Carter Hill & George Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}; 602-606.

{p 4 8 2}Harvey, Andrew (1990)
{cmd: "The Econometric Analysis of Time Series",}
{it:2nd edition, MIT Press, Cambridge, Massachusetts}.

{p 4 8 2}McDowell, Allen (2004)
{cmd: "From the Help Desk: Polynomial Distributed Lag Models",}
{it:Stata Journal, 4(2)}; 180–189.

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

{p 4 8 2} Shehata, Emad Abd Elmessih (1996)
{cmd:"Supply Response for Some Field Crops",}
{it:Cairo University - Faculty of Agriculture - Department of Economics - Egypt}.

{p 4 8 2}William E. Griffiths, R. Carter Hill and George G. Judge (1993)
{cmd: "Learning and Practicing Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}; 687.

{marker 12}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata db almon1}

 {stata sysuse almon1.dta , clear}

{bf:{err:* (1) Ordinary Least Squares (OLS)}}
 
 {stata almon1 y x , model(ols) lag(3) pdl(2) mfx(lin)}
 
 {stata almon1 y x}

 {stata almon1 y x ,   model(ols) lag(3) pdl(0) end(0) mfx(lin)}

 {stata almon1 y x z , model(ols) lag(3) pdl(2) end(0) mfx(lin)}

 {stata almon1 y x z , model(ols) lag(4) pdl(3) end(0) mfx(lin)}

{hline}
 {stata tsset t}

 {stata reg y l(0/3).x}

 {stata almon1 y x , model(ols) lag(3) pdl(0) end(0)}
{hline}

 {stata almon1 y x , model(ols) lag(3) pdl(2) end(0)}

 {stata almon1 y x , model(ols) lag(3) pdl(2) end(1)}

 {stata almon1 y x , model(ols) lag(3) pdl(2) end(2)}

 {stata almon1 y x , model(ols) lag(3) pdl(2) end(3)}

 {stata almon1 y x , model(ols) lag(3) pdl(2) end(0) test mfx(lin)}

 {stata almon1 y x , model(ols) lag(3) pdl(2) end(0) test mfx(log) tolog}

 {stata almon1 y x , model(ols) lag(3) pdl(2) end(0) test mfx(lin) predict(Yh) resid(Ue)}
{hline}

{bf:{err:* (2) Autoregressive Least Squares (ALS)}}

 {stata almon1 y x , model(als) lag(3) pdl(2) end(0) test mfx(lin)}
 
 {stata almon1 y x , model(als) lag(3) pdl(2) end(0) test mfx(lin) order(1)}

 {stata almon1 y x , model(als) lag(3) pdl(2) end(0) test mfx(lin) order(2)}
{hline}

{bf:{err:* (3) Generalized Least Squares (GLS)}}

 {stata almon1 y x , model(gls) lag(3) pdl(2) wvar(x)}
 
 {stata almon1 y x , model(gls) lag(3) pdl(2) wvar(x) ominv}
{hline}

{bf:{err:* (4) Autoregressive Conditional Heteroskedasticity (ARCH)}}

 {stata almon1 y x , model(arch) lag(4) pdl(2) end(0) test mfx(lin)}
 
 {stata almon1 y x , model(arch) lag(4) pdl(2) end(0) test mfx(lin) order(1)}

 {stata almon1 y x , model(arch) lag(4) pdl(2) end(0) test mfx(lin) order(2)}
{hline}

* Example from Damodar [2009, p. 651].

 {stata clear all}

 {stata sysuse almon2.dta , clear}

 {stata almon1 y x , model(ols) lag(3) pdl(2) end(0)}
{hline}

* Example from Griffiths, Hill and Judge [1993, p. 687].

 {stata clear all}

 {stata sysuse almon3.dta , clear}

 {stata almon1 y x , model(ols) lag(8) pdl(2) end(0)}
{hline}

 {stata clear all}

 {stata sysuse almon1.dta , clear}

 {stata almon1 y x , model(ols) lag(3) pdl(2) end(0) test mfx(lin) predict(Yh) resid(Ue)}

. clear all
. sysuse almon1.dta , clear
. almon1 y x  , model(ols) lag(3) pdl(2) end(0) test mfx(lin) predict(Yh) resid(Ue)

==============================================================================
              *** Shirley Almon Polynomial Distributed Lag Model ***
==============================================================================
 *** Ordinary Least Squares (OLS) ***
 *** No Endpoint Polynomial Restrictions ***
------------------------------------------------------------------------------
- Lag Length: Lag(3) - Polynomial Degree PDL(2) - Endpoint Restriction End(0)
------------------------------------------------------------------------------
 Sample Size        =          32   |   Sample Range            =      4 - 36
 Wald Test          =   1848.5961   |   P-Value > Chi2(3)       =      0.0000
 F-Test             =    616.1987   |   P-Value > F(3 , 28)     =      0.0000
 R2  (R-Squared)    =      0.9851   |   Raw Moments R2          =      0.9999
 R2a (Adjusted R2)  =      0.9835   |   Raw Moments R2 Adj.     =      0.9999
 Root MSE (Sigma)   =      2.8448   |   Log Likelihood Function =    -76.7249
------------------------------------------------------------------------------
- R2h= 0.9851   R2h Adj= 0.9835  F-Test =  616.20 P-Value > F(3 , 28)  0.0000
- R2v= 0.9851   R2v Adj= 0.9835  F-Test =  616.20 P-Value > F(3 , 28)  0.0000
------------------------------------------------------------------------------
 Akaike Criterion AIC =    161.4498 |   Schwarz Criterion SC    =    167.3128
------------------------------------------------------------------------------
- Joint F-Test Restriction   x          = 616.199     P > F(3, 28)     0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
           x |
         --. |   1.202501   .2993337     4.02   0.000     .5893435    1.815658
         L1. |   .6681351     .27373     2.44   0.021     .1074245    1.228846
         L2. |   .0904505   .2717045     0.33   0.742    -.4661109    .6470119
         L3. |   -.530553   .3083609    -1.72   0.096    -1.162202    .1010957
             |
       _cons |   68.57335   6.809186    10.07   0.000     54.62537    82.52134
------------------------------------------------------------------------------

==============================================================================
*** Model Selection Diagnostic Criteria
------------------------------------------------------------------------------
* Stata Method
- Akaike Information Criterion              (1974) AIC     =    161.4498
- Schwarz Criterion                         (1978) SC      =    167.3128
-------------------------------------------------------------------------
- Log Likelihood Function                   (LLF)          =    -76.7249
---------------------------------------------------------------------------
- Akaike Information Criterion              (1974) AIC     =      9.0923
- Akaike Information Criterion              (1973) Log AIC =      2.2074
- Corrected Akaike Information Criterion    AICC           =     10.5738
---------------------------------------------------------------------------
- Schwarz Criterion                         (1978) SC      =     10.9206
- Schwarz Criterion                         (1978) Log SC  =      2.3906
---------------------------------------------------------------------------
- Final Prediction Criterion                (1969) FPE     =      9.1043
- Hannan-Quinn Criterion                    (1979) HQ      =      9.6616
- Rice Criterion                            (1984) Rice    =      9.4415
- Shibata Criterion                         (1981) Shibata =      8.8514
- Craven-Wahba Generalized Cross Validation (1979) GCV     =      9.2488
------------------------------------------------------------------------------

==============================================================================
*** Autocorrelation Tests - (Model= ols)
------------------------------------------------------------------------------
 Ho: No Autocorrelation - Ha: Autocorrelation
------------------------------------------------------------------------------
- Rho Value for Order(1)               AR(1)=  0.5062
- Breusch-Godfrey LM Test (drop 1 obs) AR(1)=  8.4650  P-Value >Chi2(1) 0.0036
- Breusch-Godfrey LM Test (keep 1 obs) AR(1)=  8.7436  P-Value >Chi2(1) 0.0031
- Breusch-Pagan-Godfrey LM Test        AR(1)=  2.9570  P-Value >Chi2(1) 0.0855
------------------------------------------------------------------------------

==============================================================================
*** Heteroscedasticity Tests - (Model= ols)
------------------------------------------------------------------------------
 Ho: Homoscedasticity - Ha: Heteroscedasticity
------------------------------------------------------------------------------
- Engle LM ARCH Test AR(1) E2=E2_1-E2_1=   0.7476    P-Value > Chi2(1)  0.3872
------------------------------------------------------------------------------
- Hall-Pagan LM Test:      E2 = Yh     =   0.1063    P-Value > Chi2(1)  0.7444
- Hall-Pagan LM Test:      E2 = Yh2    =   0.0904    P-Value > Chi2(1)  0.7637
- Hall-Pagan LM Test:      E2 = LYh2   =   0.1239    P-Value > Chi2(1)  0.7248
------------------------------------------------------------------------------
- Harvey LM Test:       LogE2 = X      =   0.0362    P-Value > Chi2(2)  0.9821
- White Test -Koenker(R2): E2 = X      =   0.0758    P-Value > Chi2(1)  0.7831
- White Test -B-P-G (SSR): E2 = X      =   0.0647    P-Value > Chi2(1)  0.7993
------------------------------------------------------------------------------

==============================================================================
*** Non Normality Tests - (Model= ols)
------------------------------------------------------------------------------
 Ho: Normality - Ha: Non Normality
------------------------------------------------------------------------------
- Jarque-Bera LM Test                  =   0.2503     P-Value > Chi2(2) 0.8824
- White IM Test                        =   1.6090     P-Value > Chi2(2) 0.4473
- Geary LM Test                        =  -3.0347     P-Value > Chi2(2) 0.2193
------------------------------------------------------------------------------

*** Marginal Effect - Elasticity (Model= OLS): Linear *

+----------------------------------------------------------------------------+
|    Variable | Marginal Effect(B) |     Elasticity(Es) |               Mean |
|-------------+--------------------+--------------------+--------------------|
|           x |             1.2025 |             0.6735 |           196.6850 |
|         L.x |             0.6681 |             0.3710 |           194.9896 |
|        L2.x |             0.0905 |             0.0498 |           193.2746 |
|        L3.x |            -0.5306 |            -0.2896 |           191.6763 |
+----------------------------------------------------------------------------+
 Mean of Dependent Variable =    351.1539

------------------------------------------------------------------------------
* Variable   Mean Lag   Full Lag    SUM(Coefs.)   Std. Err.  T-Test     P>|t|
------------------------------------------------------------------------------
  x          -0.5191     0.4809      1.4305        0.0356    40.1586    0.0000
------------------------------------------------------------------------------

------------------------------------------------------------------------------
* Variable    Marginal Effect (B)         |      Elasticity (Es)
              Short Run      Long Run     |      Short Run      Long Run
------------------------------------------------------------------------------
  x            1.2025         1.4305      |       0.6735         0.8047
------------------------------------------------------------------------------

{marker 13}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:ALMON1 Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2014)}{p_end}
{p 1 10 1}{cmd:ALMON1: "Stata Module to Estimate Shirley Almon Polynomial Distributed Lag Model"}{p_end}

{title:Online Help:}

{bf:*** Distributed Lag Models}
{helpb almon1}{col 12}Shirley Almon Polynomial Distributed Lag Model{col 75}(ALMON1)
{helpb almon}{col 12}Shirley Almon Generalized Polynomial Distributed Lag Model{col 75}(ALMON)
{helpb dlagaj}{col 12}Alt France-Jan Tinbergen Distributed Lag Model{col 75}(DLAGAJ)
{helpb dlagdj}{col 12}Dale Jorgenson Rational Distributed Lag Model{col 75}(DLAGDJ)
{helpb dlagfd}{col 12}Frank De Leeuw Inverted V Distributed Lag Model{col 75}(DLAGFD)
{helpb dlagif}{col 12}Irving Fisher Arithmetic Distributed Lag Model{col 75}(DLAGIF)
{helpb dlagmf}{col 12}Milton Fridman Partial Adjustment-Adaptive Expectations
{col 12}Distributed Lag Model{col 75}(DLAGMF)
{helpb dlagmn}{col 12}Marc Nerlove Partial Adjustment Distributed Lag Model{col 75}(DLAGMN)
{helpb dlagrs}{col 12}Robert Solow Pascal Triangle Distributed Lag Model{col 75}(DLAGRS)
{helpb dlagrw}{col 12}Rudolf Wolffram Segmenting Partial Adjustment Distributed Lag{col 75}(DLAGRW)
{helpb dlagtq}{col 12}Tweeten-Quance Partial Adjustment Distributed Lag Model{col 75}(DLAGTQ)
{hline 83}

{bf:*** Demand System Models}
{helpb dsles}{col 12}Linear Expenditure System (LES){col 75}(DSLES)
{helpb dseles}{col 12}Extended Linear Expenditure System (ELES){col 75}(DSELES)
{helpb dsqes}{col 12}Quadratic Expenditure System (QES){col 75}(DSQES)
{helpb dsrot}{col 12}Rotterdam Demand System{col 75}(DSROT)
{helpb dsroti}{col 12}Inverse Rotterdam Demand System{col 75}(DSROTI)
{helpb dsaidsla}{col 12}Linear Approximation Almost Ideal Demand System (AIDS-LA){col 75}(DSAIDSLA)
{helpb dsaidsfd}{col 12}First Difference Almost Ideal Demand System (AIDS-FD){col 75}(DSAIDSFD)
{helpb dsaidsi}{col 12}Inverse Almost Ideal Demand System(AIDS-I) {col 75}(DSAIDSI)
{helpb dsarm}{col 12}Primal Armington Demand System{col 75}(DSARM)
{helpb dsengel}{col 12}Engel Demand System{col 75}(DSENGEL)
{helpb dsgads}{col 12}Generalized AddiLog Demand System (GADS){col 75}(DSGADS)
{helpb dstlog}{col 12}Transcendental Logarithmic Demand System{col 75}(DSTLOG)
{helpb dsw}{col 12}Working Demand System{col 75}(DSW)
{hline 83}
{helpb pfm}{col 12}Production Function Models{col 75}(PFM)
{hline 83}
{helpb ffm}{col 12}Profit Function Models{col 75}(FFM)
{hline 83}
{helpb cfm}{col 12}Cost Function Models{col 75}(CFM)
{hline 83}
{helpb iic}{col 12}Investment Indicators Criteria{col 75}(IIC)
{hline 83}
{helpb iot}{col 12}Leontief Input - Output Table{col 75}(IOT)
{hline 83}
{helpb index}{col 12}Index Numbers{col 75}(INDEX)
{hline 83}
{helpb mef}{col 12}Marketing Efficiency Models{col 75}(MEF)
{hline 83}
{helpb pam}{col 12}Policy Analysis Matrix{col 75}(PAM)
{helpb pem}{col 12}Partial Equilibrium Model{col 75}(PEM)
{hline 83}
{bf:*** Financial Analysis Models}
{helpb fam}{col 12}Financial Analysis Models{col 75}(FAM)
{helpb xbcr}{col 12}Benefit-Cost Ratio{col 75}(XBCR)
{helpb xirr}{col 12}Internal Rate of Return{col 75}(XIRR)
{helpb xmirr}{col 12}Modified Internal Rate of Return{col 75}(XMIRR)
{helpb xnfv}{col 12}Net Future Value{col 75}(XNFV)
{helpb xnpv}{col 12}Net Present Value{col 75}(XNPV)
{helpb xpp}{col 12}Payback Period{col 75}(XPP)
{hline 83}
{bf:*** Trade Models}
{helpb wtm}{col 12}World Trade Models{col 75}(WTM)
{helpb wtic}{col 12}World Trade Indicators Criteria{col 75}(WTIC)
{helpb wtrgc}{col 12}World Trade Regional Geographical Concentration{col 75}(WTRGC)
{helpb wtsgc}{col 12}World Trade Sectoral Geographical Concentration{col 75}(WTSGC)
{helpb wtrca}{col 12}World Trade Revealed Comparative Advantage{col 75}(WTRCA)
{hline 83}

{psee}
{p_end}

