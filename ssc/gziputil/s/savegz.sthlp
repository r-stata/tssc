{smcl}
{* *! version 0.3.0 25sep2019}{...}
{vieweralsosee "save" "help save"}{...}
{vieweralsosee "gziputil overview" "help gziputil"}{...}
{cmd:savegz} {hline 2} Save gzip compressed Stata dataset


{title:Syntax}

{phang}
{cmd:savegz} has exactly the same interface as {help save}. Therefore, see 
{help save} for detailed help.


{title:Description}

{pstd}
{cmd:savegz} is a wrapper around {help save} which writes gzip compressed 
Stata files ({it:.dta.gz}). Details on the how and why are available
in the {help gziputil##general:general package Description}.


{title:Author}

{pstd}
Matthias Gomolka, Deutsche Bundesbank, Research Data and Service Centre{break}
{browse "mailto:matthias.gomolka@bundesbank.de":matthias.gomolka@bundesbank.de}
{p_end}
