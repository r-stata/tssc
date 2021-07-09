{smcl}
{* *! version 0.3.0 25sep2019}{...}
{vieweralsosee "merge" "help merge"}{...}
{vieweralsosee "gziputil overview" "help gziputil"}{...}
{cmd:mergegz} {hline 2} Merge gzip compressed Stata dataset


{title:Syntax}

{phang}
{cmd:mergegz} has exactly the same interface as {help merge}. Therefore, see 
{help merge} for detailed help.


{title:Description}

{pstd}
{cmd:mergegz} is a wrapper around {help merge} which merges gzip compressed 
Stata files ({it:.dta.gz}). Details on the how and why are available
in the {help gziputil##general:general package Description}.

{pstd}
To create gzip compressed {it:.dta.gz} files, use {help savegz}.


{title:Author}

{pstd}
Matthias Gomolka, Deutsche Bundesbank, Research Data and Service Centre{break}
{browse "mailto:matthias.gomolka@bundesbank.de":matthias.gomolka@bundesbank.de}
{p_end}
