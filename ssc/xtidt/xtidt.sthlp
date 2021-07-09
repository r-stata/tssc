{smcl}
{hline}
{cmd:help: {helpb xtidt}}{space 55} {cmd:dialog:} {bf:{dialog xtidt}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: xtidt: Create Identification Panel Data Variables}

{bf:{err:{dlgtab:Syntax}}}
{p 8 16 2}
{opt xtidt} {ifin} , {opt id(#)} {opt t(#)} {opt year(varname)} {opt panel(varname)}{p_end}
{p 35 8 2} [ {opt time(varname)} {opt dumcs(prefix)} {opt dumts(prefix)} {opt list} ]{p_end} 

{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{col 7}{opt id(#)}{col 30}Number of Cross Sections

{col 7}{opt t(#)}{col 30}Number of Years

{col 7}{opt panel(varname)}{col 30}Name of ID Cross Sections variable

{col 7}{opt year(varname)}{col 30}Name of ID years variable

{col 7}{opt time(varname)}{col 30}Time Trend variable

{col 7}{opt dumcs(new_varlist)}{col 30}Cross Section Dummy Variables (Prefix name)

{col 7}{opt dumts(new_varlist)}{col 30}Time Series Dummy Variables (Prefix name)

{col 7}{opt list}{col 30}Display Panel and Time ID Variables

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:xtidt} Create Identification Panel Data Variables for using in {helpb xtreg} regression.{p_end}

{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata db xtidt}

	{stata xtidt , id(2) t(3) panel(id) year(year) time(time) list}

	{stata xtidt , id(2) t(4) panel(id) year(year) time(time) list}

	{stata xtidt , id(3) t(4) panel(id) year(year) time(time) list}
	
	{stata xtidt , id(4) t(3) panel(id) year(year) time(time) list}
	
	{stata xtidt , id(3) t(5) panel(id) year(year) time(time) list}

	{stata xtidt , id(3) t(5) panel(id) year(year) time(time) dumcs(Cs) dumts(Ts) list}

	{stata list id year time Cs1 Cs2 Cs3 Ts1 Ts2 Ts3 Ts4 Ts5}
 
	{stata xtset id year}

	{stata list}

     +------------------------------------------------------------------+
     | id   year   time   Cs1   Cs2   Cs3   Ts1   Ts2   Ts3   Ts4   Ts5 |
     |------------------------------------------------------------------|
  1. |  1      1      1     {bf:{red:1}}     0     0     {bf:{red:1}}     0     0     0     0 |
  2. |  1      2      2     {bf:{red:1}}     0     0     0     {bf:{red:1}}     0     0     0 |
  3. |  1      3      3     {bf:{red:1}}     0     0     0     0     {bf:{red:1}}     0     0 |
  4. |  1      4      4     {bf:{red:1}}     0     0     0     0     0     {bf:{red:1}}     0 |
  5. |  1      5      5     {bf:{red:1}}     0     0     0     0     0     0     {bf:{red:1}} |
     |------------------------------------------------------------------|
  6. |  2      1      6     0     {bf:{red:1}}     0     {bf:{red:1}}     0     0     0     0 |
  7. |  2      2      7     0     {bf:{red:1}}     0     0     {bf:{red:1}}     0     0     0 |
  8. |  2      3      8     0     {bf:{red:1}}     0     0     0     {bf:{red:1}}     0     0 |
  9. |  2      4      9     0     {bf:{red:1}}     0     0     0     0     {bf:{red:1}}     0 |
 10. |  2      5     10     0     {bf:{red:1}}     0     0     0     0     0     {bf:{red:1}} |
     |------------------------------------------------------------------|
 11. |  3      1     11     0     0     {bf:{red:1}}     {bf:{red:1}}     0     0     0     0 |
 12. |  3      2     12     0     0     {bf:{red:1}}     0     {bf:{red:1}}     0     0     0 |
 13. |  3      3     13     0     0     {bf:{red:1}}     0     0     {bf:{red:1}}     0     0 |
 14. |  3      4     14     0     0     {bf:{red:1}}     0     0     0     {bf:{red:1}}     0 |
 15. |  3      5     15     0     0     {bf:{red:1}}     0     0     0     0     {bf:{red:1}} |
     +------------------------------------------------------------------+


 This example is taken from:
{p 4 8 2}Greene, William (2012) {cmd: "Econometric Analysis",} {it:7th ed., Prentice Hall Publishing Company Inc., New York, USA.}; 368-377.

	{stata clear all}

	{stata sysuse xtidt.dta , clear}

	{stata xtidt, t(7) id(595) year(t) panel(id)}

	{stata xtreg lwage exp exp2 wks occ ind south smsa ms union ed fem blk , re}
	{stata xtreg lwage exp exp2 wks occ ind south smsa ms union ed fem blk , fe}

	{stata xtreg lwage exp exp2 wks occ ind south smsa ms union , fe}
	{stata est store LM_Fixed}

	{stata xtreg lwage exp exp2 wks occ ind south smsa ms union , re}
	{stata hausman LM_Fixed}

	{stata xttest0}

{bf:{err:{dlgtab:Acknowledgments}}}

  I would like to thank Professor Christopher F Baum, for his help during design this module.

{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

	{browse "http://econpapers.repec.org/software/bocbocode/S457363.htm"}

	{browse "http://ideas.repec.org/c/boc/bocode/s457363.html"}

{bf:{err:{dlgtab:xtidt Citation}}}

{phang}Shehata, Emad Abd Elmessih (2011){p_end}
{phang}{cmd: "XTIDT: Stata Module to Create Identification Panel Data Variables"}{p_end}

{psee}
{p_end}

