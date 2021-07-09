{smcl}
{* Copyright 2018 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 20Apr2018}{...}
{cmd:help dyadid}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:dyadid} {hline 2}}Create dyads using linked IDs{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:dyadid} egoID alterID, gen(index)


{title:Description}

{pstd}{cmd:dyadid} links records in a file using IDs. Where a file
contains records about multiple individuals within groups (e.g., persons
within households), it creates an index variable to create specific
dyads, such as spouse pairs.{p_end}

{pstd}{cmd:egoID} is the main ID variable. {cmd:alterID} is the variable
containing the ID of the other element of the dyad (e.g., the spouse).
The values of {cmd:alterID} should be unique (this is not tested: if not
unique the last record will be used). The {cmd:gen} option creates a new
variable that is the case number of the linked record. The index
variable can then be used to create variables with values drawn from the
linked record (see example below).{p_end}

{pstd}See ancillary files dyadsim.dta and dyadsim.do.{p_end}

{title:Author}

{phang}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{pstd}Using the ancillary file dyadsim.dta: {p_end}

{phang}{cmd:. use dyadsim}{p_end}
{phang}{cmd:. dyadid id sid, gen(sidx)}{p_end}
{phang}{cmd:. gen spage = age[sidx]}{p_end}
{phang}{cmd:. ttest spage == age if sex==1}{p_end}