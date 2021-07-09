{smcl}
{hline}
{cmd:help: {helpb lmnjb}}{space 55} {cmd:dialog:} {bf:{dialog lmnjb}}
{hline}


{bf:{err:{dlgtab:Title}}}

{bf: lmnjb: Jarque-Bera Non Normality Lagrange Multiplier Test}


{bf:{err:{dlgtab:Syntax}}}

{p 8 16 2}
{opt lmnjb} {depvar} {indepvars} {ifin} {weight} , [ {opt nocons:tant} {opth vce(vcetype)} ]{p_end} 

{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{synopt :{opt nocons:tant}}suppress constant term{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt ols},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, 
   {opt jack:knife}, {opt hc2}, or {opt hc3}{p_end}


{bf:{err:{dlgtab:Description}}}

{p 2 2 2} lmnjb computes Lagrange Multiplier Jarque-Bera normality test for OLS residuals after {helpb regress} command.{p_end}

{p 2 2 2} Ho: Error has normality distribution.{p_end}
{p 2 2 2} Ha: Error has non normality distribution.{p_end}

{p 2 2 2} LM Jarque-Bera test has degrees of freedom with chi2 at 2 DF (5.99).{p_end}


{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmnjb} saves the following in {cmd:r()}:

{synoptset 10 tabbed}{...}
{p2col 5 10 10 2: Scalars}{p_end}
{synopt:{cmd:r(lmn)}}LM Jarque-Bera Normality Test{p_end}
{synopt:{cmd:r(df)}}Chi2 degrees of freedom{p_end}
{synopt:{cmd:r(p)}}P-Value significance{p_end}


{bf:{err:{dlgtab:Example}}}

	{stata clear all}

	{stata sysuse lmnjb.dta, clear}

	{stata lmnjb y x1 x2}

	{stata return list}

	{stata db lmnjb}


{bf:{err:{dlgtab:References}}}

{p 4 8 2}C.M. Jarque and A.K. Bera (1987)
{cmd: "A Test for Normality of Observations and Regression Residuals"}
{it:International Statistical Review, Vol. 55}; 163-172.


{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}


{bf:{err:{dlgtab:lmnjb Citation}}}

{phang}Shehata, Emad Abd Elmessih (2011){p_end}
{phang}{cmd: "lmnjb: Stata Module to Compute Jarque-Bera Non Normality Lagrange Multiplier Runs Test"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457319.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/S457319.htm"}

{psee}
{p_end}

