{smcl}
{hline}
{cmd:help: {helpb lmhreg3}}{space 55} {cmd:dialog:} {bf:{dialog lmhreg3}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmhreg3: Overall System Heteroscedasticity Tests after (3SLS-SURE) Regressions}

{bf:{err:{dlgtab:Syntax}}}

     {cmd: lmhreg3}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}lmhreg3 computes overall system Heteroscedasticity tests, after:{p_end}
{p 2 2 2}- (3SLS) Three-Stage Least Squares {helpb reg3} for systems of simultaneous equations.{p_end}
{p 2 2 2}- (SURE) Seemingly Unrelated Regression Estimation {helpb sureg} for sets of equations.{p_end}


{p 2 2 2}lmhreg3 calculates single Equation Heteroscedasticity:{p_end}
{p 4 2 2}- Engle LM ARCH Test.{p_end}
{p 4 2 2}- Hall-Pagan LM Test: E2 = Yh.{p_end}
{p 4 2 2}- Hall-Pagan LM Test: E2 = Yh2.{p_end}
{p 4 2 2}- Hall-Pagan LM Test: E2 = LYh2.{p_end}

{p 2 2 2}lmhreg3 calculates overall system Heteroscedasticity:{p_end}
{p 4 2 2}- Breusch-Pagan LM Test.{p_end}
{p 4 2 2}- Likelihood Ratio LR Test.{p_end}
{p 4 2 2}- Wald Test.{p_end}

{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmhreg3} saves the following in {cmd:r()}:

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

{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata sysuse lmhreg3.dta , clear}

   * (1) SUR Model:

	{stata sureg (y1 x1 z1) (y2 x2 z2) (y3 x3 z3) (y4 x4 z4)}

	{stata lmhreg3}

	{stata return list}


   * (2) 3SLS Model:

	{stata reg3 (y1 x1 z1) (y2 x2 z2) (y3 x3 z3) (y4 x4 z4)}

	{stata lmhreg3}

	{stata return list}

* If you want to use dialog box: Press OK to compute lmhreg3

	{stata db lmhreg3}

. clear all
. sysuse lmhreg3.dta , clear
. reg3 (y1 x1 z1) (y2 x2 z2) (y3 x3 z3) (y4 x4 z4)
. lmhreg3


=================================================
* System Heteroscedasticity Tests (3sls) 
=================================================
*** Single Equation Heteroscedasticity Tests:
  Ho: Homoscedasticity - Ha: Heteroscedasticity

 Eq. y1    : Engle LM ARCH Test: E2 = E2_1  =  6.3690 P-Value > Chi2(1) 0.0116
 Eq. y1    : Hall-Pagan LM Test: E2 = Yh    =  0.9303 P-Value > Chi2(1) 0.3348
 Eq. y1    : Hall-Pagan LM Test: E2 = Yh2   =  0.8921 P-Value > Chi2(1) 0.3449
 Eq. y1    : Hall-Pagan LM Test: E2 = LYh2  =  0.7534 P-Value > Chi2(1) 0.3854
------------------------------------------------------------------------------
 Eq. y2    : Engle LM ARCH Test: E2 = E2_1  =  0.3761 P-Value > Chi2(1) 0.5397
 Eq. y2    : Hall-Pagan LM Test: E2 = Yh    =  0.4260 P-Value > Chi2(1) 0.5139
 Eq. y2    : Hall-Pagan LM Test: E2 = Yh2   =  0.1462 P-Value > Chi2(1) 0.7022
 Eq. y2    : Hall-Pagan LM Test: E2 = LYh2  =  0.7281 P-Value > Chi2(1) 0.3935
------------------------------------------------------------------------------
 Eq. y3    : Engle LM ARCH Test: E2 = E2_1  =  0.9578 P-Value > Chi2(1) 0.3277
 Eq. y3    : Hall-Pagan LM Test: E2 = Yh    =  0.3958 P-Value > Chi2(1) 0.5293
 Eq. y3    : Hall-Pagan LM Test: E2 = Yh2   =  0.9242 P-Value > Chi2(1) 0.3364
 Eq. y3    : Hall-Pagan LM Test: E2 = LYh2  =  0.0165 P-Value > Chi2(1) 0.8979
------------------------------------------------------------------------------
 Eq. y4    : Engle LM ARCH Test: E2 = E2_1  =  0.0143 P-Value > Chi2(1) 0.9047
 Eq. y4    : Hall-Pagan LM Test: E2 = Yh    =  2.0117 P-Value > Chi2(1) 0.1561
 Eq. y4    : Hall-Pagan LM Test: E2 = Yh2   =  2.0956 P-Value > Chi2(1) 0.1477
 Eq. y4    : Hall-Pagan LM Test: E2 = LYh2  =  1.8364 P-Value > Chi2(1) 0.1754
------------------------------------------------------------------------------
*** Overall System Heteroscedasticity Tests:
 Ho: No Overall System Heteroscedasticity

- Breusch-Pagan LM Test         =  10.7443       P-Value > Chi2(6)   0.0966
- Likelihood Ratio LR Test      =  14.0682       P-Value > Chi2(6)   0.0289
- Wald Test                     =  19.9272       P-Value > Chi2(6)   0.0029
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

{bf:{err:{dlgtab:lmhreg3 Citation}}}

{phang}Shehata, Emad Abd Elmessih (2011){p_end}
{phang}{cmd: "LMHREG3: Stata Module to Compute Overall System Heteroscedasticity Tests after (3SLS-SURE) Regressions"}{p_end}

{title:Online Help:}

{p 4 12 2}
{helpb lmhreg} {helpb lmhreg} {helpb lmhreg2} {helpb lmhreg3} {opt (if installed)}.{p_end}

{psee}
{p_end}

