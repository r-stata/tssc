{smcl}
{* *! version 0.3.0 25sep2019}{...}
{vieweralsosee "use" "help use"}{...}
{vieweralsosee "gziputil overview" "help gziputil"}{...}
{cmd:usegz} {hline 2} Use gzip compressed Stata dataset


{title:Syntax}

{phang}
{opt usegz} has exactly the same interface as {help use}. Therefore, see 
{help use} for detailed help.


{title:Description}

{pstd}
{cmd:usegz} is a wrapper around {help use} which reads gzip compressed 
Stata files. Details on the how and why are available in the 
{help gziputil##general:general package Description}.

{pstd}
To create gzip compressed {it:.dta.gz} files, use {help savegz}.


{title:Author}

{pstd}
Matthias Gomolka, Deutsche Bundesbank, Research Data and Service Centre{break}
{browse "mailto:matthias.gomolka@bundesbank.de":matthias.gomolka@bundesbank.de}
{p_end}
