{smcl}
{hline}
{cmd:help: {helpb varprod}}{space 50} {cmd:dialog:} {bf:{dialog varprod}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: varprod: Generate Row Product of Variables}

{bf:{err:{dlgtab:Syntax}}}

{cmd: egen [type] newvar = varprod(varlist) [if] [in]}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}varprod generates (row) product of variables in varlist, and looks like function (rowtotal) in egen command that creates (row) sum of the variables in varlist{p_end}

{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata sysuse varprod.dta , clear}

	{stata egen px1 = varprod(x1 x2 x3 x4)}

	{stata egen px2 = varprod(x*)}

	{stata gen  px3 = x1*x2*x3*x4}
	
	{stata list px1 px2 px3}

	{stata egen pxy1 = varprod(x1 x2 x3 x4 y1 y2 y3)}

	{stata egen pxy2 = varprod(x* y*)}

	{stata gen  pxy3 = x1*x2*x3*x4*y1*y2*y3}

	{stata list pxy1 pxy2 pxy3}

{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:VARPROD Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:VARPROD: "Stata Module to Generate Row Product of Variables"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457410.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457410.htm"}

{psee}
{p_end}

