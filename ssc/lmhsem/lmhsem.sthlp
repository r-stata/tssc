{smcl}
{hline}
{cmd:help: {helpb lmhsem}}{space 55} {cmd:dialog:} {bf:{dialog lmhsem}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmhsem: Overall System Heteroscedasticity Tests after (SEM) Regressions}

{bf:{err:{dlgtab:Syntax}}}

     {cmd: lmhsem}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}lmhsem computes overall system Heteroscedasticity tests, after:{p_end}
{p 2 2 2}- (SEM) Structural Equation Modeling Regressions {helpb sem} for system of simultaneous equations.{p_end}

{p 2 2 2}lmhsem calculates single Equation Heteroscedasticity:{p_end}
{p 4 2 2}- Engle LM ARCH Test.{p_end}
{p 4 2 2}- Hall-Pagan LM Test: E2 = Yh.{p_end}
{p 4 2 2}- Hall-Pagan LM Test: E2 = Yh2.{p_end}
{p 4 2 2}- Hall-Pagan LM Test: E2 = LYh2.{p_end}

{p 2 2 2}lmhsem calculates overall system Heteroscedasticity:{p_end}
{p 4 2 2}- Breusch-Pagan LM Test.{p_end}
{p 4 2 2}- Likelihood Ratio LR Test.{p_end}

{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmhsem} saves the following in {cmd:r()}:

{synoptset 12 tabbed}{...}
{p2col 5 12 12 2: Scalars}{p_end}

{synopt:{cmd:r(lmhlm)}}Breusch-Pagan LM Test{p_end}
{synopt:{cmd:r(lmhlmp)}}Breusch-Pagan LM Test P-Value{p_end}
{synopt:{cmd:r(lmhlr)}}Likelihood Ratio LR Test{p_end}
{synopt:{cmd:r(lmhlrp)}}Likelihood Ratio LR Test P-Value{p_end}

{col 4}{cmd:e(mharch_#)}{col 20}Engle LM ARCH Test for eq.i
{col 4}{cmd:e(mharchp_#)}{col 20}Engle LM ARCH Test for eq.# P-Value
{col 4}{cmd:e(lmhhp1_#)}{col 20}Hall-Pagan LM Test E2 = Yh for eq.#
{col 4}{cmd:e(lmhhp1p_#)}{col 20}Hall-Pagan LM Test E2 = Yh for eq.# P-Value
{col 4}{cmd:e(lmhhp2_#)}{col 20}Hall-Pagan LM Test E2 = Yh2 for eq.#
{col 4}{cmd:e(lmhhp2p_#)}{col 20}Hall-Pagan LM Test E2 = Yh2 for eq.# P-Value
{col 4}{cmd:e(lmhhp3_#)}{col 20}Hall-Pagan LM Test E2 = Yh3 for eq.#
{col 4}{cmd:e(lmhhp3p_#)}{col 20}Hall-Pagan LM Test E2 = Yh3 for eq.# P-Value

{bf:{err:{dlgtab:Examples}}}

 in this example FIML will be used as follows:

	{stata clear all}

	{stata sysuse lmhsem.dta , clear}

	{stata sem (y1 <- y2 x1 x2) (y2 <- y1 x3 x4), cov(e.y1*e.y2)}

	{stata lmhsem}

	{stata return list}

* If you want to use dialog box: Press OK to compute lmhsem

	{stata db lmhsem}

. clear all
. sysuse lmhsem.dta , clear
. sem (y1 <- y2 x1 x2) (y2 <- y1 x3 x4), cov(e.y1*e.y2)

Structural equation model                       Number of obs      =        17
Estimation method  = ml
Log likelihood     = -363.34588
------------------------------------------------------------------------------
             |                 OIM
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
Structural   |
  y1 <-      |
          y2 |   .2425937   .2106232     1.15   0.249    -.1702201    .6554075
          x1 |   .2568409    .462485     0.56   0.579     -.649613    1.163295
          x2 |  -1.037016   .3154059    -3.29   0.001      -1.6552   -.4188317
       _cons |   147.0826    54.4491     2.70   0.007     40.36431    253.8009
  -----------+----------------------------------------------------------------
  y2 <-      |
          y1 |  -.6282929   .6148239    -1.02   0.307    -1.833326    .5767398
          x3 |  -.5226661   .3235637    -1.62   0.106    -1.156839    .1115071
          x4 |     3.4208   1.440664     2.37   0.018     .5971513    6.244449
       _cons |   62.44495   42.36071     1.47   0.140    -20.58052    145.4704
-------------+----------------------------------------------------------------
Variance     |
        e.y1 |   80.17577   28.99122                      39.46865    162.8673
        e.y2 |   142.4478   80.80501                      46.86006    433.0208
-------------+----------------------------------------------------------------
Covariance   |
  e.y1       |
        e.y2 |   25.62619   53.75243     0.48   0.634    -79.72665     130.979
------------------------------------------------------------------------------
LR test of model vs. saturated: chi2(2)   =      0.12, Prob > chi2 = 0.9408

. lmhsem

=================================================
* System Heteroscedasticity Tests (ml) 
=================================================
*** Single Equation Heteroscedasticity Tests:
  Ho: Homoscedasticity - Ha: Heteroscedasticity

 Eq. 1     : Engle LM ARCH Test: E2 = E2_1  =  0.0319 P-Value > Chi2(1) 0.8582
 Eq. 1     : Hall-Pagan LM Test: E2 = Yh    =  3.2488 P-Value > Chi2(1) 0.0715
 Eq. 1     : Hall-Pagan LM Test: E2 = Yh2   =  3.5925 P-Value > Chi2(1) 0.0580
 Eq. 1     : Hall-Pagan LM Test: E2 = LYh2  =  2.9051 P-Value > Chi2(1) 0.0883
------------------------------------------------------------------------------
 Eq. 2     : Engle LM ARCH Test: E2 = E2_1  =  0.6860 P-Value > Chi2(1) 0.4075
 Eq. 2     : Hall-Pagan LM Test: E2 = Yh    =  1.0007 P-Value > Chi2(1) 0.3171
 Eq. 2     : Hall-Pagan LM Test: E2 = Yh2   =  0.8447 P-Value > Chi2(1) 0.3581
 Eq. 2     : Hall-Pagan LM Test: E2 = LYh2  =  1.1165 P-Value > Chi2(1) 0.2907
------------------------------------------------------------------------------
*** Overall System Heteroscedasticity Tests:
 Ho: No Overall System Heteroscedasticity

- Breusch-Pagan LM Test         =   0.9775       P-Value > Chi2(1)   0.3228
- Likelihood Ratio LR Test      =   1.0067       P-Value > Chi2(1)   0.3157
------------------------------------------------------------------------------

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

{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:lmhsem Citation}}}

{phang}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{phang}{cmd:LMHSEM: "Stata Module to Compute Overall System Heteroscedasticity Tests after Structural Equation Modeling (SEM) Regressions"}{p_end}

{title:Online Help:}

{p 2 10 2}
{helpb lmasem}, {helpb lmhsem}, {helpb lmnsem}, {helpb lmcovsem}, {helpb r2sem},{p_end}
{p 2 10 2}
{helpb lmareg3}, {helpb lmhreg3}, {helpb lmnreg3}, {helpb lmcovreg3}, {helpb r2reg3}. {opt (if installed)}.{p_end}

{psee}
{p_end}

