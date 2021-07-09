{smcl}
{hline}
{cmd:help: {helpb lmngry}}{space 55} {cmd:dialog:} {bf:{dialog lmngry}}
{hline}


{bf:{err:{dlgtab:Title}}}

{bf: lmngry: Geary Non Normality Lagrange Multiplier Runs Test}

{bf:{err:{dlgtab:Syntax}}}

{p 8 16 2}
{opt lmngry} {depvar} {indepvars} {ifin} {weight} , [ {opt nocons:tant} {opth vce(vcetype)} ]{p_end} 

{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{synopt :{opt nocons:tant}}suppress constant term{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt ols},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, 
   {opt jack:knife}, {opt hc2}, or {opt hc3}{p_end}


{bf:{err:{dlgtab:Description}}}

{p 2 2 2} lmngry computes Geary Lagrange Multiplier non normality runs test for OLS residuals after {helpb regress} command.{p_end}

{p 2 2 2} Ho: Error has normality distribution.{p_end}
{p 2 2 2} Ha: Error has non normality distribution.{p_end}

{p 2 2 2} Geary LM test has degrees of freedom with chi2 at 2 DF (5.99).{p_end}


{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmngry} saves the following in {cmd:r()}:

{synoptset 10 tabbed}{...}
{p2col 5 10 10 2: Scalars}{p_end}
{synopt:{cmd:r(lmn)}}Geary LM Test{p_end}
{synopt:{cmd:r(df)}}Chi2 degrees of freedom{p_end}
{synopt:{cmd:r(p)}}P-Value significance{p_end}


{bf:{err:{dlgtab:Example}}}

	{stata clear all}

	{stata sysuse lmngry.dta, clear}

	{stata lmngry y x1 x2}

	{stata return list}

	{stata db lmngry}


{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}; 419-420.

{p 4 8 2}Geary R.C. (1947) {cmd: "Testing for Normality"} {it:Biometrika, Vol. 34}; 209-242.

{p 4 8 2}Geary R.C. (1970) {cmd: "Relative Efficiency of Count of Sign Changes for Assessing Residuals Autoregression in Least Squares Regression"}
{it:Biometrika, Vol. 57}; 123-127.


{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}


{bf:{err:{dlgtab:lmngry Citation}}}

{phang}Shehata, Emad Abd Elmessih (2011){p_end}
{phang}{cmd: "lmngry: Stata Module to Compute Geary Non Normality Lagrange Multiplier Runs Test"}{p_end}

{psee}
{p_end}

