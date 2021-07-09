{smcl}
{hline}
{cmd:help: {helpb lmhnlsur}}{space 50} {cmd:dialog:} {bf:{dialog lmhnlsur}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmhnlsur: Overall System NL-SUR Heteroscedasticity Tests}

{bf:{err:{dlgtab:Syntax}}}

     {cmd: lmhnlsur}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}lmhnlsur computes Overall System NL-SUR Heteroscedasticity tests, after:{p_end}
{p 2 2 2}- (NL-SUR) Non-Linear Seemingly Unrelated Regression Estimation {helpb nlsur} for sets of equations.{p_end}

{p 2 2 2}lmhnlsur calculates single Equation Heteroscedasticity:{p_end}
{p 4 2 2}- Engle LM ARCH Test.{p_end}
{p 4 2 2}- Hall-Pagan LM Test: E2 = Yh.{p_end}
{p 4 2 2}- Hall-Pagan LM Test: E2 = Yh2.{p_end}
{p 4 2 2}- Hall-Pagan LM Test: E2 = LYh2.{p_end}

{p 2 2 2}lmhnlsur calculates overall system Heteroscedasticity:{p_end}
{p 4 2 2}- Breusch-Pagan LM Test.{p_end}
{p 4 2 2}- Likelihood Ratio LR Test.{p_end}
{p 4 2 2}- Wald Test.{p_end}

{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmhnlsur} saves the following in {cmd:r()}:

{synoptset 12 tabbed}{...}
{p2col 5 12 12 2: Scalars}{p_end}

{synopt:{cmd:r(lmhlm)}}Breusch-Pagan LM Test{p_end}
{synopt:{cmd:r(lmhlmp)}}Breusch-Pagan LM Test P-Value{p_end}
{synopt:{cmd:r(lmhlr)}}Likelihood Ratio LR Test{p_end}
{synopt:{cmd:r(lmhlrp)}}Likelihood Ratio LR Test P-Value{p_end}
{synopt:{cmd:r(lmhw)}}Wald Test{p_end}
{synopt:{cmd:r(lmhwp)}}Wald Test P-Value{p_end}

{col 4}{cmd:e(mharch_#)}{col 20}Engle LM ARCH Test for eq.i
{col 4}{cmd:e(mharchp_#)}{col 20}Engle LM ARCH Test for eq.# P-Value
{col 4}{cmd:e(lmhhp1_#)}{col 20}Hall-Pagan LM Test E2 = Yh for eq.#
{col 4}{cmd:e(lmhhp1p_#)}{col 20}Hall-Pagan LM Test E2 = Yh for eq.# P-Value
{col 4}{cmd:e(lmhhp2_#)}{col 20}Hall-Pagan LM Test E2 = Yh2 for eq.#
{col 4}{cmd:e(lmhhp2p_#)}{col 20}Hall-Pagan LM Test E2 = Yh2 for eq.# P-Value
{col 4}{cmd:e(lmhhp3_#)}{col 20}Hall-Pagan LM Test E2 = Yh3 for eq.#
{col 4}{cmd:e(lmhhp3p_#)}{col 20}Hall-Pagan LM Test E2 = Yh3 for eq.# P-Value

{bf:{err:{dlgtab:References}}}

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA.}; 492-493.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Macmillan Publishing Company Inc., New York, USA.}; 534-536.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 494.

{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse lmanlsur.dta , clear}

* (1) NL-SUR Model:

 {stata nlsur (y1={B10}+{B11}*y2+{B12}*x1+{B13}*x2) (y2={B20}+{B21}*y1+{B22}*x3+{B23}*x4)}

 {stata lmhnlsur}

 {stata return list}

* (2) SUR Model:

 {stata sureg (y1 y2 x1 x2) (y2 y1 x3 x4)}

 {stata lmhnlsur}

 {stata return list}

. clear all
. sysuse lmhnlsur.dta , clear
. nlsur (y1={B10}+{B11}*y2+{B12}*x1+{B13}*x2) (y2={B20}+{B21}*y1+{B22}*x3+{B23}*x4)

FGNLS regression 
---------------------------------------------------------------------
       Equation |       Obs  Parms       RMSE      R-sq     Constant
----------------+----------------------------------------------------
 1           y1 |        20      4   125.6433    0.8266          B10
 2           y2 |        20      4   19.52663    0.7801          B20
---------------------------------------------------------------------

------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        /B10 |  -68.61381   119.3219    -0.58   0.565    -302.4804    165.2528
        /B11 |   6.586666   .6994811     9.42   0.000     5.215708    7.957623
        /B12 |   .0771727   .0496441     1.55   0.120     -.020128    .1744733
        /B13 |  -.3247027   .2355698    -1.38   0.168    -.7864111    .1370056
        /B20 |    11.0109   24.11753     0.46   0.648    -36.25859    58.28038
        /B21 |    .137451   .0141117     9.74   0.000     .1097926    .1651094
        /B22 |  -.0018792   .0116164    -0.16   0.871    -.0246469    .0208885
        /B23 |  -.0024405   .0142685    -0.17   0.864    -.0304061    .0255252
------------------------------------------------------------------------------

. lmhnlsur
==============================================================================
* NL-SUR System Heteroscedasticity Tests
==============================================================================
*** Single Equation Heteroscedasticity Tests:
  Ho: Homoscedasticity - Ha: Heteroscedasticity

 Eq. 1     : Engle LM ARCH Test: E2 = E2_1  =  0.0314 P-Value > Chi2(1) 0.8595
 Eq. 1     : Hall-Pagan LM Test: E2 = Yh    =  5.2793 P-Value > Chi2(1) 0.0216
 Eq. 1     : Hall-Pagan LM Test: E2 = Yh2   =  5.3205 P-Value > Chi2(1) 0.0211
 Eq. 1     : Hall-Pagan LM Test: E2 = LYh2  =  4.7232 P-Value > Chi2(1) 0.0298
------------------------------------------------------------------------------
 Eq. 2     : Engle LM ARCH Test: E2 = E2_1  =  0.0238 P-Value > Chi2(1) 0.8774
 Eq. 2     : Hall-Pagan LM Test: E2 = Yh    =  1.9040 P-Value > Chi2(1) 0.1676
 Eq. 2     : Hall-Pagan LM Test: E2 = Yh2   =  1.3369 P-Value > Chi2(1) 0.2476
 Eq. 2     : Hall-Pagan LM Test: E2 = LYh2  =  2.3780 P-Value > Chi2(1) 0.1231
------------------------------------------------------------------------------

*** Overall NL-SUR Heteroscedasticity Tests:
 Ho: No Overall System Heteroscedasticity

- Breusch-Pagan LM Test         =   9.8474       P-Value > Chi2(1)   0.0017
- Likelihood Ratio LR Test      =  13.5600       P-Value > Chi2(1)   0.0002
- Wald Test                     =  19.9578       P-Value > Chi2(1)   0.0000
------------------------------------------------------------------------------

{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:lmhnlsur Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:LMHNLSUR: "Overall System NL-SUR Heteroscedasticity Tests"}{p_end}

{title:Online Help:}

{p 2 10 2}
{helpb lmanlsur}, {helpb lmhnlsur}, {helpb lmnnlsur}, {helpb lmcovnlsur}, {helpb r2nlsur}{p_end}
{p 2 10 2}
{helpb lmareg3}, {helpb lmhreg3}, {helpb lmnreg3}, {helpb lmcovreg3}, {helpb r2reg3}{p_end}
{p 2 10 2}
{helpb lmasem}, {helpb lmhsem}, {helpb lmnsem}, {helpb lmcovsem}, {helpb r2sem}. {opt (if installed)}.{p_end}

{psee}
{p_end}

