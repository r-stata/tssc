{smcl}
{hline}
help for {hi:psgraph}
{hline}

{title:Graph propensity score histogram}

{p 8 21 2}{cmdab:psgraph}
{cmd:[,}
	{cmdab:bin}{cmd:(}{it:#}{cmd:)}
	{cmdab:t:reated}{cmd:(}{it:varname}{cmd:)}
	{cmdab:sup:port}{cmd:(}{it:varname}{cmd:)}
	{cmdab:p:score}{cmd:(}{it:varname}{cmd:)}
	{it:graph_options}]

{title:Description}

{p 4 4 2}{cmd:psgraph} graphs the propensity score histogram by treatment status. 

{p 4 4 2}{cmd:psgraph} can be called without options after {cmd:psmatch2}. In this case {cmd:psgraph} will use
the generate variables {it:_treated} and {it:_pscore}. The options treated and pscore override this
behavior.

{title:Options}

{p 4 8 2}{cmdab:bin}{cmd:(}{it:#}{cmd:)} specifies the number of intervals to use for
accumulating the histogram. The default is {cmd:bin(20)}.

{p 4 8 2}{cmdab:t:reated}{cmd:(}{it:varname}{cmd:)} specifies treatment indicator variable.
Assumes the following: 0 = controls, 1 = treated.

{p 4 8 2}{cmdab:sup:port}{cmd:(}{it:varname}{cmd:)} Common support indicator (0/1).

{p 4 8 2}{cmdab:p:score}{cmd:(}{it:varname}{cmd:)} specifies the propensity score.

{title:Also see}

{p 4 4 2}The commands {help psmatch2}, {help pstest}.

{title:Author}

{p 4 4 2}Edwin Leuven,  École Nationale de la Statistique et de l'Administration Économique. If
you observe any problems {browse "mailto:leuven@ensae.fr"}.

{p 4 4 2}Barbara Sianesi, Institute for Fiscal Studies, London, UK.
