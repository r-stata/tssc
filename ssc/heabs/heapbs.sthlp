{smcl}
{* 19feb2020}{...}
{cmd:help heapbs}
{hline}

{title:Title}
{p}{bf:heapbs} Calculates the Probability of Miscoverage, the Probability of Cost Effectiveness and draws a graph of the Cost Effectiveness with a confidence ellipse.
Requires data generated from a bootstrap of the heabs function, or equivalent. {p_end}


{title:Syntax}
{p 4}
{cmd:heapbs},
[{cmd:lci(varname)}
{cmd:uci(varname)}
{cmd:ref(int)}
{cmd:inb(varname)}
{cmd:draw}
{cmd:cost(varname)}
{cmd:effect(varname)}
{cmd:w2p(int)}
{cmd:scatteropts(string)}
{cmd:lineopts(string)}
{cmd:meanopts(string)}
{cmd:ellipopts(string)}
{it:twoway_options}]
{p_end}


{title:Description}

{p} Can return one or more of: the Probability of Miscoverage (PoM), the Probability of Cost Effectiveness (PCE) and a plot of the Cost Effectiveness, depending on input.
 Uses the ellip command to draw plot. Defaults have been specified but most can be overidden. See {help ellip} for more information.
{p_end}


{title:Options}

{p 4}{opt lci(var)} used to indicate the lower confidence interval variable of the Incremental Net Benefit. (needed for PoM)

{p 4}{opt uci(var)} used to indicate the upper confidence interval variable of the Incremental Net Benefit. (needed for PoM)

{p 4}{opt ref(#)} the reference Incremental Net Benefit to be used in PoM. (needed for PoM)

{p 4}{opt inb(var)} used to indicate the Incremental Net Benefit. (needed for PCE)

{p 4}{opt draw} used to indicate a graph should be generated. (needed for plot)

{p 4}{opt cost(var)} used to indicate the cost variable to be plotted. (needed for plot)

{p 4}{opt effect(var)} used to indicate the effect variable to be plotted. (needed for plot)

{p 4}{opt w2p(int)} used to add the threshold of willingness-to-pay onto the graph. (optional for plot)

{p 4}{opt scatteropts(string)} used to customise appearance of scatterplot, using twoway syntax. (optional for plot)

{p 4}{opt lineopts(string)} used to customise appearance of willingness-to-pay threshold, using twoway syntax. (optional for plot)

{p 4}{opt meanopts(string)} used to customise appearance of marker for mean of estimates, using twoway syntax. (optional for plot)

{p 4}{opt ellipopts(string)} used to customise appearance of ellipse twoway syntax. (optional for plot)

{p 4}{it:twoway_options} allow control of graph titles, legends etc. See {it:{help twoway_options}}




{title:Examples}

{p}{bf:heapbs}, lci(NB1Lo) uci(NB1Up) ref(341.9783) inb(NB1) draw  cost(cost1) effect(effect1) name("graph1", replace) 

{p}{bf:heapbs}, lci(NB1Lo) uci(NB1Up) ref(341.9783) inb(NB1) draw w2p(30) cost(cost1) effect(effect1) scatteropts(msize(small)) ///
 lineopts(lcolor(blue)) meanopts(msymbol(Sh)) ellipopts(lcolor(blue)) name("graph2", replace) 

{bf:heapbs}, lci(NB1Lo) uci(NB1Up) ref(-200)

{bf:heapbs}, lci(NB2Lo) uci(NB2Up) ref(300) inb(NB1)



{title:Authors}

{pstd}
Daniel Gallacher {break}
Warwick Evidence {break}
Warwick Medical School{break}
University of Warwick {break}
D.Gallacher@Warwick.ac.uk {p_end}


{psee}Online:  {helpb ellip}{p_end}

