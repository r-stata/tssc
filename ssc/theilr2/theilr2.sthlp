{smcl}
{hline}
{cmd:help: {helpb theilr2}}{space 55} {cmd:dialog:} {bf:{dialog theilr2}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: theilr2: Theil R2 Multicollinearity Effect"}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb theilr2##01:Syntax}{p_end}
{p 5}{helpb theilr2##02:Options}{p_end}
{p 5}{helpb theilr2##03:Description}{p_end}
{p 5}{helpb theilr2##04:Saved Results}{p_end}
{p 5}{helpb theilr2##05:References}{p_end}

{p 1}*** {helpb theilr2##06:Examples}{p_end}

{p 5}{helpb theilr2##07:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 4 8 6}
{opt theilr2} {depvar} {indepvars} {ifin} {weight} , {err: [} {opt noconst:ant} {err:]}{p_end} 

{marker 02}{bf:{err:{dlgtab:Options}}}
{p 2 6 2}

{synoptset 6 tabbed}{...}
{synopthdr}
{synoptline}

{synopt :{opt nocons:tant}}suppress constant term{p_end}

{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 4 2}{cmd:theilr2} computes Theil R2 Multicollinearity Effect, and Determinant of |X'X|{p_end}
{p 2 4 2} more details in: [Theil(1971, p.179)], [Judge, et al(1988, p.870-872)]{p_end}

{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:theilr2} saves the following in {cmd:e()}:

{col 4}{cmd:e(r2t)}{col 20}Theil R2 Multicollinearity Effect
{col 4}{cmd:e(dcor)}{col 20}Determinant of |X'X|

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 870-872.

{p 4 8 2}Theil, Henri (1971)
{cmd: "Principles of Econometrics",}
{it:John Wiley & Sons, Inc., New York, USA}.

{marker 06}{bf:{err:{dlgtab:Examples}}}

{p 2 4 2}(1) Example of Theil R2 Multicollinearity Effect in: [Judge, et al(1988, p.872)], for Klein-Goldberger data.{p_end}

	{stata clear all}

	{stata sysuse theilr2.dta, clear}

	{stata theilr2 y x1 x2 x3}


. theilr2 y x1 x2 x3
-----------------------------------------------------------------
* Theil R2 Multicollinearity Effect
  R2 = 0 No Multicollinearity - R2 = 1 Multicollinearity

    - Theil R2:              (0 < 0.8412 < 1)
-----------------------------------------------------------------

* Determinant of |X'X|:
  |X'X| = 1 No Multicollinearity - |X'X| = 0 Multicollinearity

    Determinant of |X'X|:    (0 < 0.0779 < 1)
-----------------------------------------------------------------

{marker 07}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:theilr2 Citation}}}

{phang}Shehata, Emad Abd Elmessih (2012){p_end}
{phang}{cmd:THEILR2: "Stata Module to Compute Theil R2 Multicollinearity Effect"}{p_end}

{title:Also see}

{p 4 12 2}Online: {helpb theilr2}, {helpb ridgereg}, (if installed).{p_end}

{psee}
{p_end}

