{smcl}
{hline}
{cmd:help: {helpb lmnwhite}}{space 55} {cmd:dialog:} {bf:{dialog lmnwhite}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmnwhite: OLS White Non Normality Lagrange Multiplier Test}

{bf:{err:{dlgtab:Syntax}}}

{p 10 16 2}
{opt lmnwhite} {depvar} {indepvars} {ifin} {weight} , [ {opt nocons:tant} {opth vce(vcetype)} ]{p_end} 

{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{synopt :{opt nocons:tant}}suppress constant term{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt ols},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, 
   {opt jack:knife}, {opt hc2}, or {opt hc3}{p_end}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:lmnwhite} computes White Non Normality Test for OLS residuals after {helpb regress} command.{p_end} 

{bf:{err:{dlgtab:Saved Results}}}

{cmd:lmnwhite} saves the following in {cmd:r()}:

{col 4}{cmd:r(lmn)}{col 20}White IM Test
{col 4}{cmd:r(lmnp)}{col 20}White IM Test P-Value
{col 4}{cmd:r(lmndf)}{col 20}Degrees of Freedom

{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}.

{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata sysuse lmnwhite.dta, clear}

	{stata db lmnwhite}

	{stata lmnwhite y x1 x2}

	{stata return list}
{hline}

. clear all
. sysuse lmnwhite.dta , clear
. lmnwhite y1 x1 x2

      Source |       SS       df       MS              Number of obs =      17
-------------+------------------------------           F(  2,    14) =  136.68
       Model |  8460.93712     2  4230.46856           Prob > F      =  0.0000
    Residual |  433.313039    14  30.9509313           R-squared     =  0.9513
-------------+------------------------------           Adj R-squared =  0.9443
       Total |  8894.25016    16  555.890635           Root MSE      =  5.5634

------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   1.061709   .2666739     3.98   0.001     .4897506    1.633668
          x2 |  -1.382986   .0838143   -16.50   0.000    -1.562749   -1.203222
       _cons |   130.7066   27.09429     4.82   0.000     72.59515    188.8181
------------------------------------------------------------------------------

==============================================================================
* OLS White Lagrange Multiplier Non Normality Test
==============================================================================
    Ho: Normality - Ha: Non Normality

    White LM Test             =    1.06961
    Degrees of Freedom        =        2.0
    P-Value > Chi2(2)         =    0.58578

{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:lmnwhite Citation}}}

{phang}Shehata, Emad Abd Elmessih (2012){p_end}
{phang}{cmd: LMNWHITE: "Stata Module to Compute White Non Normality Lagrange Multiplier Test after OLS Regression"}{p_end}

{title:Online Help:}

{p 4 12 2}
{helpb lmnjb}, {helpb lmngry} {opt (if installed)}.{p_end}

{psee}
{p_end}
