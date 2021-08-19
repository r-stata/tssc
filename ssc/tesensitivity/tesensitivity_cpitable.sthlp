{smcl}
{* *! version 1.2.1  07mar2013}{...}
{vieweralsosee "tesensitivity" "tesensitivity"}{...}
{viewerjumpto "Syntax" "tesensitivity_cpitable##syntax"}{...}
{viewerjumpto "Description" "tesensitivity_cpi#description"}{...}
{viewerjumpto "Remarks" "tesensitivity_cpi#remarks"}{...}
{viewerjumpto "Examples" "tesensitivity_cpi#examples"}{...}
{title:Title}

{phang}
{bf:tesensitivity cpitable} {hline 2} Compare sensitivity analyses for multiple treatment effect estimates

{marker syntax}{...}
{title:Syntax}

	{cmd:tesensitivity cpitable} {it:estimates}

{phang}
{it:estimates} is a list of stored results from calls to {cmd:tesensitivity cpi}.

{marker description}{...}
{title:Description}
	
{pstd}
{cmd:tesensitivity cpitable} displays a table comparing multiple estimates from
calls to {cmd:tesensitivity cpi}. Two tables are displayed, one with bounds
on the treatment statistic in each call to {cmd:tesensitivity ctable} for the
values of c-dependence specified in those calls, and another comparing the
breakdown points from each call.   

{marker remarks}{...}
{title:Remarks}

{p 4 4 4}
See {help tesensitivity##further_information:here} for links to the articles 
this package is based on, more detailed documentation on the implementation in 
this package, and examples of its use.

{marker examples}{...}
{title:Examples}

{phang} For more examples see this {browse "https://github.com/mattmasten/tesensitivity/blob/master/vignette/vignette.pdf":vignette}.
