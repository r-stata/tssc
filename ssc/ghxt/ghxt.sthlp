{smcl}
{hline}
{cmd:help: {helpb ghxt}}{space 55} {cmd:dialog:} {bf:{dialog ghxt}}
{hline}

{bf:{err:{dlgtab:Title}}}

{p 4 8 2}
{bf:ghxt: Panel Groupwise Heteroscedasticity Tests}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb ghxt##01:Syntax}{p_end}
{p 5}{helpb ghxt##02:Options}{p_end}
{p 5}{helpb ghxt##03:Description}{p_end}
{p 5}{helpb ghxt##04:Saved Results}{p_end}
{p 5}{helpb ghxt##05:References}{p_end}

{p 1}*** {helpb ghxt##06:Examples}{p_end}

{p 5}{helpb ghxt##08:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt ghxt} {depvar} {indepvars} {ifin} {weight} , {bf:{err:id(#)}}  {err:[} {opt nocons:tant} {opth vce(vcetype)} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}
{p 1 1 1}

{synoptset 3 tabbed}{...}

{synopt :* {cmd: {opt id(#)} Number of Cross Sections in the Model}}{p_end} 

{col 7}{opt nocons:tant}{col 20}Exclude Constant Term from Equation

{synopt :{opth vce(vcetype)} {opt ols}, {opt r:obust}, {opt cl:uster}, {opt boot:strap}, {opt jack:knife}, {opt hc2}, {opt hc3}}{p_end}


{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:ghxt} computes the following Panel Groupwise Heteroscedasticity Tests.{p_end}

	* Ho: Panel Homoscedasticity - Ha: Panel Groupwise Heteroscedasticity
		- Lagrange Multiplier LM Test
		- Likelihood Ratio LR Test
		- Wald Test

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:ghxt} saves the following Panel Groupwise Heteroscedasticity Tests in {cmd:r()}:

{col 4}{cmd:r(lmhglm)}{col 20}Lagrange Multiplier LM Test
{col 4}{cmd:r(lmhglmp)}{col 20}Lagrange Multiplier LM Test P-Value
{col 4}{cmd:r(lmhglr)}{col 20}Likelihood Ratio LR Test
{col 4}{cmd:r(lmhglrp)}{col 20}Likelihood Ratio LR Test P-Value
{col 4}{cmd:r(lmhgw)}{col 20}Wald Test
{col 4}{cmd:r(lmhgwp)}{col 20}Wald Test P-Value

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Greene, William (1993)
{cmd: "Econometric Analysis",}
{it:2nd ed., Macmillan Publishing Company Inc., New York, USA.}.

{p 4 8 2}Greene, William (2007)
{cmd: "Econometric Analysis",}
{it:6th ed., Macmillan Publishing Company Inc., New York, USA.}.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Examples}}}

  {stata clear all}

  {stata sysuse ghxt.dta, clear}

  {stata db ghxt}

  {stata ghxt y x1 , id(4)}


==============================================================================
* Panel Groupwise Heteroscedasticity Tests
==============================================================================
  Ho: Homoscedasticity - Ha: Groupwise Heteroscedasticity

- Lagrange Multiplier LM Test     =   5.8261     P-Value > Chi2(3)   0.1204
- Likelihood Ratio LR Test        =   5.5501     P-Value > Chi2(3)   0.1357
- Wald Test                       =   9.8611     P-Value > Chi2(4)   0.0428


{marker 08}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:ghxt Citation}}}

{phang}Shehata, Emad Abd Elmessih (2011){p_end}
{phang}{cmd:GHXT: "Stata Module to Compute Panel Groupwise Heteroscedasticity Tests"}{p_end}

{title:Online Help:}

{p 2 12 2}{helpb lmhreg}, {helpb lmhreg2}, {helpb lmhreg3}, {helpb lmhxt}, {helpb ghxt}. {opt (if installed)}.{p_end}

{psee}
{p_end}

