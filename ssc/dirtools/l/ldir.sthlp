{smcl}
{* August 18, 2011 @ 10:43:41 UK}{...}
{hi:help ldir}

{hline}

{title:Title}

{phang}
{cmd:ldir} Clickable list of folder names
{p_end}

{title:Syntax}
{p 8 17 2}
   {cmd: ldir}
   [ {it:stub} ]
   [ {cmd:,} 
   {opt h:idden}
   ]
{p_end}

{title:Description}

{pstd} {cmd:ldir} lists the names of folders or directories in compact
form and allow to click on the names to make it the working directory.
{p_end}

{pstd}If {it:stub} is specified, only folders with names containing
{it: stub} are listed.{p_end}

{pstd}If Nick Winter's user written program {it:fastcd} has been used
to define bookmarks, those bookmarks are also shown. In addition ldir
shows the clickable link [+] for adding the current working directory
to the list of bookmarks. If the current working directory is already
bookmarked the clickable link [-] can be used to remove it from the
list of bookmarks. {p_end}

{pstd}The list of foldernames is returned in r(folders), so long as
that is not empty.{p_end}

{title:Options}

{phang}{opt hidden} By default, {cmd:ldir} does not list folder names
starting with "."; these are the so called "hidden" folders on
Linux/UNIX systems. The option {cmd:hidden} lists these folders as
well.  {p_end}

{title:Example(s)}

{phang}{cmd:. ldir}{break}
{p_end}

{title:Acknowledgments}

{pstd}{cmd:ldir} is build from Nick Cox's program {cmd:folders}
available on SSC. I would like to thank Nick Cox for allowing me to
distribute {cmd:ldir} on SSC{p_end}

{title:Also see}

{psee}
Manual: {hi:[R] dir; [R] cd; [R] pwd}
{p_end}

{psee}
Online: help for {help dirtools};  help for {help folders} (if installed)
{p_end}

{title:Author}

Ulrich Kohler
email: {browse mailto:kohler@wzb.eu}
web: {browse `"http://www.wzb.eu/~kohler/default.htm"'}

Address: Wissenschaftszentrum Berlin
Reichpietschufer 50
10785 Berlin
Germany

