{smcl}
{hline}
{cmd:help: {helpb fgtest}}{space 55} {cmd:dialog:} {bf:{dialog fgtest}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: fgtest: Farrar-Glauber Multicollinearity Tests"}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb fgtest##01:Syntax}{p_end}
{p 5}{helpb fgtest##02:Options}{p_end}
{p 5}{helpb fgtest##03:Description}{p_end}
{p 5}{helpb fgtest##04:Saved Results}{p_end}
{p 5}{helpb fgtest##05:References}{p_end}

{p 1}*** {helpb fgtest##06:Examples}{p_end}

{p 5}{helpb fgtest##07:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 4 8 6}
{opt fgtest} {depvar} {indepvars} {ifin} {weight} , {err: [} {opt noconst:ant} {err:]}{p_end} 

{marker 02}{bf:{err:{dlgtab:Options}}}
{p 2 6 2}

{synoptset 6 tabbed}{...}
{synopthdr}
{synoptline}

{synopt :{opt nocons:tant}}suppress constant term{p_end}

{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 4 2}{cmd:fgtest} computes Farrar-Glauber Multicollinearity tests{p_end}
	  * Farrar-Glauber Multicollinearity Chi2-Test
	  * Farrar-Glauber Multicollinearity F-Test
	  * Farrar-Glauber Multicollinearity t-Test

{p 2 4 2} more details can be found in Mitsaki(2011)

{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:fgtest} saves the following in {cmd:e()}:

scalars:
{col 4}{cmd:e(fgchi)}{col 20}Farrar-Glauber Multicollinearity Chi2-Test

matrixes:
{col 4}{cmd:e(fgf)}{col 20}Farrar-Glauber Multicollinearity F-Test
{col 4}{cmd:e(fgt)}{col 20}Farrar-Glauber Multicollinearity t-Test

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Evagelia, Mitsaki (2011)
{cmd: "Ridge Regression Analysis of Collinear Data",}
{browse "http://www.stat-athens.aueb.gr/~jpan/diatrives/Mitsaki/chapter2.pdf"}

{p 4 8 2}Farrar, D. and Glauber, R. (1976)
{cmd: "Multicollinearity in Regression Analysis: the Problem Revisited",}
{it:Review of Economics and Statistics, 49}; 92-107.

{marker 06}{bf:{err:{dlgtab:Examples}}}

{p 2 4 4} Example of Farrar-Glauber Multicollinearity Chi2, F, t Tests{p_end}
{p 6 6 2}is decribed in:[Evagelia(2011, chap.2, p.23)].{p_end}

	{stata clear all}

	{stata sysuse fgtest.dta, clear}

	{stata fgtest y x1 x2 x3 x4 x5 x6}


. fgtest y x1 x2 x3 x4 x5 x6

======================================================================
* Farrar-Glauber Multicollinearity Tests
======================================================================
  Ho: No Multicollinearity - Ha: Multicollinearity

* (1) Farrar-Glauber Multicollinearity Chi2-Test:
    Chi2 Test =  218.5559    P-Value > Chi2(15) 0.0000

* (2) Farrar-Glauber Multicollinearity F-Test:
+--------------------------------------------------------+
|   Variable |   F_Test |      DF1 |      DF2 |  P_Value |
|------------+----------+----------+----------+----------|
|         x1 |  269.064 |   10.000 |    5.000 |    0.000 |
|         x2 | 3574.850 |   10.000 |    5.000 |    0.000 |
|         x3 |   65.238 |   10.000 |    5.000 |    0.000 |
|         x4 |    5.178 |   10.000 |    5.000 |    0.042 |
|         x5 |  796.307 |   10.000 |    5.000 |    0.000 |
|         x6 | 1515.957 |   10.000 |    5.000 |    0.000 |
+--------------------------------------------------------+

* (3) Farrar-Glauber Multicollinearity t-Test:
+----------------------------------------------------------------+
| Variable |     x1 |     x2 |     x3 |     x4 |     x5 |     x6 |
|----------+--------+--------+--------+--------+--------+--------|
|       x1 |      . |        |        |        |        |        |
|       x2 | 24.228 |      . |        |        |        |        |
|       x3 |  2.503 |  2.398 |      . |        |        |        |
|       x4 |  1.660 |  1.578 | -0.570 |      . |        |        |
|       x5 | 15.248 | 23.530 |  2.986 |  1.237 |      . |        |
|       x6 | 23.610 | 32.409 |  2.841 |  1.452 | 28.624 |      . |
+----------------------------------------------------------------+

{marker 07}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:fgtest Citation}}}

{phang}Shehata, Emad Abd Elmessih (2012){p_end}
{phang}{cmd:FGTEST: "Stata Module to Compute Farrar-Glauber Multicollinearity Chi2, F, t Tests"}{p_end}

{title:Also see}

{p 4 12 2}Online: {helpb fgtest}, {helpb ridgereg}, (if installed).{p_end}

{psee}
{p_end}

