{smcl}
{* *! version 0.3.0 25sep2019}{...}
{vieweralsosee "append" "help append"}{...}
{vieweralsosee "gziputil overview" "help gziputil"}{...}
{cmd:appendgz} {hline 2} Append gzip compressed Stata dataset


{title:Syntax}

{phang}
{cmd:appendgz} has exactly the same interface as {help append}. Therefore, see 
{help append} for detailed help.


{title:Description}

{pstd}
{cmd:appendgz} is a wrapper around {help append} which appends gzip compressed 
Stata files ({it:.dta.gz}). Details on the how and why are available
in the {help gziputil##general:general package Description}.

{pstd}
To create gzip compressed {it:.dta.gz} files, use {help savegz}.


{title:Author}

{pstd}
Matthias Gomolka, Deutsche Bundesbank, Research Data and Service Centre{break}
{browse "mailto:matthias.gomolka@bundesbank.de":matthias.gomolka@bundesbank.de}
{p_end}
