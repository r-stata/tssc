{smcl}
{hline}
{cmd:help: {helpb lmgc}}{space 50} {cmd:dialog:} {bf:{dialog lmgc}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmgc: Granger Causality Test at Higher Order AR(p)}

{bf:{err:{dlgtab:Syntax}}}

{p 2 8 2}
{opt lmgc} {depvar} {indepvars} {ifin} , [{opt lag:s(#)} {opt aux(varlist)} {opt nocons:tant} {opt reg coll}]{p_end} 

{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{col 3}{opt lag:s(#)}{col 20}Order of Lag Length; default is lag(1)

{col 3}{opt nocons:tant}{col 20}suppress constant term

{col 3}{opt reg}{col 20}display regression results for unrestricted model

{col 3}{opt coll}{col 20}Keep Collinear Variables

{p 3 20 2}{opt aux(varlist)} add Auxiliary Variables into model without converting them to lagged variables, i.e., dummy variables, time trend, ...etc.{p_end}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:lmgc} computes Granger Causality Test at Higher Order AR(p) 

{bf:{err:{dlgtab:Saved Results}}}
{pstd}
{cmd:lmgc} saves the following in {cmd:r()}:

{col 4}{cmd:r(lmgc1_#)}{col 20}F Test for order(#)
{col 4}{cmd:r(lmgc1p_#)}{col 20}F Test for order(#) P-Value

{col 4}{cmd:r(lmgc2_#)}{col 20}Wald Test for order(#)
{col 4}{cmd:r(lmgc2p_#)}{col 20}Wald Test for order(#) P-Value

{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata db lmgc}

	{stata sysuse lmgc.dta , clear}

	{stata lmgc y1 y2 , lags(1) reg}

	{stata lmgc y1 y2 , lags(1) aux(t) reg}

	{stata lmgc y1 y2 , lags(1) aux(t y3) reg}

	{stata lmgc y1 y2 , lags(2)}

	{stata return list}

. clear all
. sysuse lmgc.dta , clear
. lmgc y1 y2 , lags(2)

==============================================================================
*** Granger Causality Test
==============================================================================
 Ho: y2 does not Granger-Cause y1

 Sample Range = 2-40              Sample Size= 39
 Lag Length   = 1
 * F-Test     =      0.5339       P-Value > F(1 , 36)      = 0.4697
 * Wald Test  =      0.5784       P-Value > Chi2(1)        = 0.4469
----------------------------------------------------------------------
 Sample Range = 3-40              Sample Size= 38
 Lag Length   = 2
 * F-Test     =      4.9514       P-Value > F(2 , 33)      = 0.0132
 * Wald Test  =     11.4031       P-Value > Chi2(2)        = 0.0033
----------------------------------------------------------------------

{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}; 620-623.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 767-770.

{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:lmgc Citation}}}

{phang}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{phang}{cmd:LMGC: "Granger Causality Test at Higher Order AR(p)"}{p_end}

{psee}
{p_end}

