{smcl}
{hline}
{cmd:help: {helpb lmhlmxt}}{space 55} {cmd:dialog:} {bf:{dialog lmhlmxt}}
{hline}

{bf:{err:{dlgtab:Title}}}

{p 4 8 2}
{bf:lmhlmxt: Breusch-Pagan Lagrange Multiplier Panel Heteroscedasticity Test}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb lmhlmxt##01:Syntax}{p_end}
{p 5}{helpb lmhlmxt##02:Options}{p_end}
{p 5}{helpb lmhlmxt##03:Description}{p_end}
{p 5}{helpb lmhlmxt##04:Saved Results}{p_end}
{p 5}{helpb lmhlmxt##05:References}{p_end}

{p 1}*** {helpb lmhlmxt##06:Examples}{p_end}

{p 5}{helpb lmhlmxt##08:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt lmhlmxt} {depvar} {indepvars} {ifin} {weight} , {bf:{err:id(#)}}  {err:[} {opt nocons:tant} {opth vce(vcetype)} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}
{p 1 1 1}

{synoptset 3 tabbed}{...}

{synopt :* {cmd: {opt id(#)} Number of Cross Sections in the Model}}{p_end} 

{col 7}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{synopt :{opth vce(vcetype)} {opt ols}, {opt r:obust}, {opt cl:uster}, {opt boot:strap}, {opt jack:knife}, {opt hc2}, {opt hc3}}{p_end}


{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:lmhlmxt} computes Breusch-Pagan Lagrange Multiplier Panel Heteroscedasticity Test.{p_end}

	* Ho: Panel Homoscedasticity - Ha: Panel Heteroscedasticity

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:lmhlmxt} saves the following in {cmd:r()}:

{col 4}{cmd:r(lmh)}{col 20}Lagrange Multiplier LM Test
{col 4}{cmd:r(lmhp)}{col 20}Lagrange Multiplier LM Test P-Value
{col 4}{cmd:r(lmhdf)}{col 20}Chi2 Degrees of Freedom

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Breusch, Trevor & Adrian Pagan (1980)
{cmd: "The Lagrange Multiplier Test and its Applications to Model Specification in Econometrics",}
{it:Review of Economic Studies 47}; 239-253.

{p 4 8 2}Greene, William (2003)
{cmd: "Econometric Analysis",}
{it:5th ed., Macmillan Publishing Company Inc., New York, USA.}; 328-330.

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Examples}}}

  {stata clear all}

  {stata sysuse lmhlmxt.dta, clear}

  {stata db lmhlmxt}

  {stata lmhlmxt i f c , id(5)}

==============================================================================
* Breusch-Pagan Lagrange Multiplier Panel Heteroscedasticity Test
==============================================================================
  Ho: Panel Homoscedasticity - Ha: Panel Heteroscedasticity

    Lagrange Multiplier LM Test    =   46.62979
    Degrees of Freedom             =        4.0
    P-Value > Chi2(4)              =    0.00000
==============================================================================

{marker 08}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:lmhlmxt Citation}}}

{phang}Shehata, Emad Abd Elmessih (2012){p_end}
{phang}{cmd:LMHLMXT: "Stata Module to Compute Breusch-Pagan Lagrange Multiplier Panel Heteroscedasticity Test"}{p_end}

{title:Online Help:}

{p 2 12 2}{helpb lmhlmxt}, {helpb lmhlrxt}. {opt (if installed)}.{p_end}

{psee}
{p_end}

