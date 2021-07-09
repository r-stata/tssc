{smcl}
{* *! version July 26, 2018 @ 23:13:28}{...}
{* link to manual entries (really meant for stata to link to its own docs}{...}
{viewerjumpto "Syntax" "opendir##syntax"}{...}
{viewerjumpto "Description" "opendir##description"}{...}
{viewerjumpto "Options" "opendir##options"}{...}
{viewerjumpto "Remarks" "opendir##remarks"}{...}
{viewerjumpto "Examples" "opendir##examples"}{...}
{viewerjumpto "Author" "opendir##author"}{...}
{...}
{title:Title}

{phang}
{cmd:opendir} {hline 2} Open folder/directory window in the operating system
{p_end}

{marker syntax}{...}
{title:Syntax}

{* put the syntax in what follows. Don't forget to use [ ] around optional items}{...}
{p 8 16 2}
   {cmd: opendir}
   {{it:folder}]
   [{cmd:,}
   {cmdab:s:ysdir(}{it:name}{cmd:)}
   ]
{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:opendir} opens the specified folder/directory in a (non-Stata) window. It is nothing fancy, just useful.
If no folder/directory gets specified, it opens the current working directory.
{p_end}

{marker options}{...}
{title:Options}

{phang}{cmdab:s:ysdir} allows you to specify a so-called {help sysdir}, such as {bf:PERSONAL}. 
{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
Sometimes it is nicer and simpler to see what is in a folder/directory through the typical window in the operating system than via a file listing. {cmd:opendir} is meant for this.
It will open the specified folder/directory in the Finder (macOS), Explorer (MS Windows), or whatever windows manager you use in unix.
{p_end}

{marker examples}{...}
{title:Example(s)}{* Be sure to change Example(s) to either Example or Examples}

{phang}{cmd:. opendir}{break}
opens the current working directory.
{p_end}

{phang}{cmd:. opendir ..}{break}
opens the parent of the current working directory.
{p_end}

{phang}{cmd:. opendir ~/Documents}{break}
opens the {bf:Documents} directory in your home folder.
{p_end}

{marker author}{...}
{title:Author}

{pstd}
Bill Rising, StataCorp{break}
email: brising@stata.com{break}
web: {browse "http://louabill.org":http://louabill.org}

