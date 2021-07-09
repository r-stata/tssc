{smcl}
{hline}
{cmd:help: {helpb lmeg}}{space 50} {cmd:dialog:} {bf:{dialog lmeg}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmeg: Augmented Engle-Granger Cointegration Test at Higher Order AR(p)}

{bf:{err:{dlgtab:Syntax}}}

{p 2 8 2}
{opt lmeg} {depvar} {indepvars} {ifin} , [{opt lag:s(#)} {opt aux(varlist)} {opt nocons:tant} {opt coll}]{p_end} 

{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{col 3}{opt lag:s(#)}{col 20}Order of Lag Length; default is lag(1)

{col 3}{opt nocons:tant}{col 20}suppress constant term

{col 3}{opt coll}{col 20}Keep Collinear Variables

{p 3 20 2}{opt aux(varlist)} add Auxiliary Variables into model without converting them to lagged variables, i.e., dummy variables, time trend, ...etc.{p_end}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:lmeg} computes Augmented Engle-Granger Cointegration Test at Higher Order AR(p) 

{bf:{err:{dlgtab:Saved Results}}}
{pstd}
{cmd:lmeg} saves the following in {cmd:r()}:

{col 4}{cmd:r(lmegz_0)}{col 20}Engle-Granger Cointegration z Test
{col 4}{cmd:r(lmegzp_0)}{col 20}Engle-Granger Cointegration z Test P-Value

{col 4}{cmd:r(lmegt_0)}{col 20}Engle-Granger Cointegration t Test
{col 4}{cmd:r(lmegtp_0)}{col 20}Engle-Granger Cointegration t Test P-Value

{col 4}{cmd:r(lmeg_#)}{col 20}Augmented Engle-Granger Cointegration t Test for order(#)
{col 4}{cmd:r(lmegp_#)}{col 20}Augmented Engle-Granger Cointegration t Test P-Value for order(#)

{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata db lmeg}

	{stata sysuse lmeg.dta , clear}

	{stata lmeg y1 y2 , lags(1)}

	{stata lmeg y1 y2 , lags(1) aux(t)}

	{stata lmeg y1 y2 , lags(1) aux(t y3)}

	{stata lmeg y1 y2 , lags(2)}

	{stata return list}

. clear all
. sysuse lmeg.dta , clear
. lmeg y1 y2 , lags(2)

==============================================================================
***Engle-Granger Cointegration Test
==============================================================================
 Ho: (Non Stationary) - (   Unit Root) - (No Cointegration)
 Ha: (    Stationary) - (no Unit Root) - (   Cointegration)

* Cointegration z Test  AR(0) =  -18.1861   P-Value > z    0.0000
* Cointegration t Test  AR(0) =   -3.4292   P-Value > t    0.0003

==============================================================================
*** Augmented Engle-Granger Cointegration Test
==============================================================================
 Sample Range = 2-40              Sample Size= 39
 Lag Length   = 1
* Cointegration t Test  AR(1) =   -2.0874   P-Value > t    0.0184
------------------------------------------------------------------------------
 Sample Range = 3-40              Sample Size= 38
 Lag Length   = 2
* Cointegration t Test  AR(2) =   -1.3643   P-Value > t    0.0862
------------------------------------------------------------------------------

{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}; 726-729.

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

{bf:{err:{dlgtab:lmeg Citation}}}

{phang}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{phang}{cmd:LMEG: "Augmented Engle-Granger Cointegration Test at Higher Order AR(p)"}{p_end}

{psee}
{p_end}

