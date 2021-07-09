{smcl}
{* *! version 1.2.0  02jun2011}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:codebookout} {hline 2} Save codebook in excel format


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:codebookout}
{it:{help filename}}
[{cmd:,} {it:options}]


{title:Description}

{pstd}
{cmd:codebookout} saves name, label, storage type of all the variables in the existing dataset with their corresponding values and value labels in memory to MS excel {it:{help filename}} file. 

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt replace } overwrite existing dataset.           



{marker remarks}{...}
{title:Remarks}

{pstd}
For feedback please email to kdas@icddrb.org


{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse auto}{p_end}

{phang}{cmd:. codebookout "D:auto codebook.xls"}{p_end}
