{smcl}
{* *! version 1.0  2014-11-01}{...}
{title:Title}

{p2colset 5 15 23 2}{...}
{p2col :{cmd:pathof} {hline 2}}Return the absolute path of any parent directory of the current working directory.{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:pathof}
[{it:parent directory}]
[{cmd:,} {opt l:ocal(macname)}]


{marker description}{...}
{title:Description}

{pstd}
{cmd:pathof} searches the path of the current working directory for the specified parent directory.
The path to the parent directory is returned in {cmd:r()} and in the local macro, if specified.  


{marker options}{...}
{title:Options}

{phang}
{cmd:local(}{it:macname}{cmd:)} inserts the path to the parent directory in  
local macro {it:macname} within the calling program's space.  Hence,
that macro will be accessible after {cmd:pathof} has finished.
This is helpful for subsequent use to specify absolute paths within the parent directory.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:pathof} is useful when a project is contained in a parent directory, and that parent
directory may change locations. Absolute file paths in a do-file can be specified using 
the returned values from {cmd:pathof}. These values will be updated when the do-file 
is run again from a new location. 

{pstd}
For example, a single parent folder named "thesis" may have subfolders "original" and 
"final". Do-files anywhere within the "thesis" parent directory can reference 
these locations as follows:

{phang}{cmd:. pathof thesis , local(thesis_dir)}{p_end}
{phang}{cmd:. use  "`thesis_dir'/original/mydata.dta"}{p_end}
{phang}{cmd:. save "`thesis_dir'/final/myfinaldata.dta"}{p_end}

{pstd}
The thesis parent directory can then be moved or shared, and the path names will update 
to the new location. Another useful application is a project that is stored in a Dropbox 
or Google Drive folder that is accessed from multiple computers. 

{pstd}
Note, the path of the current working directory is searched to find the specified parent directory. 
The working directory must be somewhere within the parent directory when the command is run. 

{pstd}
If {it:parent directory} is not specified, the root directory is returned. 

{pstd}
If {it:parent directory} is not found in the current working directory, the program exits
with a warning. No changes are made to {opt l:ocal(macname)} in this case.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. pathof , local(root)}{p_end}
{phang}{cmd:. display "`root'"}{p_end}

{phang}{cmd:. pathof Users}{p_end}
{phang}{cmd:. display "`r(path)'"}{p_end}

{phang}{cmd:. pathof Dropbox, local(dropbox)}{p_end}
{phang}{cmd:. display "`r(path)'"}{p_end}
{phang}{cmd:. display "`dropbox'"}{p_end}

{phang}{cmd:. pathof "Google Drive", local(gdrive)}{p_end}
{phang}{cmd:. display "`r(path)'"}{p_end}
{phang}{cmd:. display "`gdrive'"}{p_end}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:pathof} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(path)}}Path of parent directory{p_end}
{p2colreset}{...}


{title:Author}

{pstd} Michael Barker {p_end}
{pstd} Georgetown University {p_end}
{pstd} mdb96@georgetown.edu {p_end}
{pstd} https://github.com/michaelbarker/stata-pathof {p_end}


{title:Also see}

{pstd} findit dropbox{p_end}
{pstd} findit project{p_end}

