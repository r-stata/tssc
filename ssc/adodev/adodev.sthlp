{smcl}
{hline}
help for {cmd:adodev}, {cmd:adoind}, {cmd:adofac} and {cmd:adoins}{right:(Roger Newson)}
{hline}


{title:Reorder ado-path for developers and other independent-minded users}

{p 8 21 2}
{cmd:adodev}

{p 8 21 2}
{cmd:adoind}

{p 8 21 2}
{cmd:adofac}

{p 8 21 2}
{cmd:adoins} [ {it:path_or_codeword_list} ]

{pstd}
where {it:path_or_codeword_list} is a list of {it:path_or_codeword} items as recognised by {helpb adopath}.


{title:Description}

{pstd}
{cmd:adodev} re-orders the {help adopath:ado-file path} to start with the Stata system folders
{cmd:UPDATES}, {cmd:BASE}, {cmd:.}, {cmd:PERSONAL}, {cmd:PLUS}, {cmd:SITE}, and {cmd:OLDPLACE},
in that order.
{cmd:adoind} re-orders the {help adopath:ado-file path} to start with the Stata system folders
{cmd:UPDATES}, {cmd:BASE}, {cmd:PERSONAL}, {cmd:PLUS}, {cmd:SITE}, {cmd:.}, and {cmd:OLDPLACE},
in that order.
{cmd:adofac} re-orders the {help adopath:ado-file path} to start with the Stata system folders
{cmd:UPDATES}, {cmd:BASE}, {cmd:SITE}, {cmd:.}, {cmd:PERSONAL}, {cmd:PLUS}, and {cmd:OLDPLACE},
in that order.
{cmd:adoins} re-orders the {help adopath:ado-file path} to start with the Stata system folders
{cmd:UPDATES} and {cmd:BASE} (in that order),
followed by the folders specified by the {it:path_or_codeword_list},
followed by the Stata system folders
{cmd:SITE}, {cmd:.}, {cmd:PERSONAL}, {cmd:PLUS}, and {cmd:OLDPLACE},
in that order.
All these commands preserve any existing ordering between any other folders
on the {help adopath:ado-file path},
while keeping {cmd:UPDATES} and {cmd:BASE} at the start of the path (for safety).


{title:Remarks}

{pstd}
The {cmd:adodev} command was written for development work,
and allows the user to develop ado-files in the current folder.
The {cmd:adoind} command was written for independent-minded users,
who think that they can update packages faster than their Stata site administrators
(if any Stata site administrators exist).
The {cmd:adofac} command restores the factory setting of the ordering between system folders,
as defined in the manuals for {help version:Stata Version 10}.
The {cmd:adoins} command was written for independent-minded users
who want to insert other libraries of their choice
immediately after the {cmd:UPDATES} and {cmd:BASE} folders.
Note that the {it:path_or_codeword_list} for {cmd:adoins} can be empty or can include codewords.
Therefore, {cmd:adoins} is equivalent to {cmd:adoind},
{cmd:adoins .} is equivalent to {cmd:adodev},
and {cmd:adoins SITE .} is equivalent to {cmd:adofac}.

{pstd}
The modules of the {cmd:adodev} package should probably usually be used
with the {helpb adostore} and {helpb adorestore} modules of the {helpb adoretore} packages,
so the pre-existing ado-path can be saved using {helpb adostore},
and restored afterwards using {helpb adorestore}, if necessary.


{title:Examples}

{phang2}{cmd:.adopath}{p_end}
{phang2}{cmd:.adodev}{p_end}
{phang2}{cmd:.adoind}{p_end}
{phang2}{cmd:.adofac}{p_end}

{pstd}
The following example assumes that the current folder has a sister folder {cmd:../cprddata},
with a subfolder {cmd:/ado} containing ado-files.

{phang2}{cmd:.adopath}{p_end}
{phang2}{cmd:.adoins ../cprddata/ado}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
Manual: {hi:[P] sysdir}
{p_end}
{p 4 13 2}
Online: help for {helpb adopath}, {helpb sysdir}{break}
help for (helpb adostore} if installed
{p_end}
