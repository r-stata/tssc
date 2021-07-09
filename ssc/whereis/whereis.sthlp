{smcl}
{* 6feb2017}{...}
{title:Title}

{phang}
{bf:whereis} {hline 2} maintains a directory of external programs
 and ancillary files and folders

{title:Syntax}

{p 4 6 2}
{cmd:whereis} [{it:name} [{it:location}]]

{title:Description}

{pstd}
This command may be called to get or set the location of an external program, 
or an ancillary file or folder that may be used by a Stata command or program. 

{title:Arguments}

{phang}
{it:name} specifies the name of the  resource. 
This should be a single word  conforming to Stata conventions for names.
For example {bf:pandoc}.

{phang}
{it:location} is used when registering a resource and should be a full path 
specifying the location of the file or folder. This must conform to Stata 
conventions for file or folder names, see {help filename}. 
In particular, the path should be enclosed in quotes if it contains spaces.
For example the location of {bf:pandoc} may be 
{bf:"c:\program files (x86)\pandoc\pandoc.exe"}.

{title:Output}

{pstd}
The {cmd:whereis} command displays the location as specified or retrieved and 
stores it in a macro called {cmd:r(name)} using the name of the resource. 
For example a call to {bf:whereis pandoc} will return the location in the macro 
{bf:r(pandoc)}.

{pstd}
If called with no arguments the command simply lists all the
resources registered with {bf:whereis}.

{title:Notes}

{pstd}
The {cmd:whereis} command uses a text file to maintain a list of 
resource names and locations. This file is called {bf:whereis.dir}
and will be created in the ado path when first used.
(Type {cmd:adopath} to display the ado-file path in your system.)

{title:Tips For Users}

{pstd}
Users who install external programs that will then be registered with
{cmd:whereis} need to make a note of the location of the executable.
If you are not sure where the program was installed, the operating
system may help locate it.

{p 8 8 8}
On Unix and Mac systems open a terminal window and use
the shell command {cmd:which}. 
For example to find where pandoc is installed type in the terminal
window {cmd:which pandoc}.
On a Mac this may print /usr/local/bin/pandoc, but of course the
location may be different in your system.
Another Unix command you could try is {cmd:whereis}, after which
this Stata command is named.

{p 8 8 8}
On Windows system you can open a command prompt window and use the 
equivalent command {cmd:where}. By default this will search the
user's path, but the /R option will search recursively starting at
a given folder. To search the entire C drive for pandoc.exe type
in a command window {cmd:where /R c:\ pandoc.exe}. On a Windows 
system this may print c:\program files (x86)\pandoc\pandoc.exe,
but again the location in your system may be different.

{pstd}
In both cases, once you have located the program or resource file
use the Stata {cmd:whereis} command to register the location permanently.

{title:Notes For Programmers}

{pstd}
Programmers using {cmd:whereis} to retrieve the location of a resource 
should allow for the possibility that the path includes spaces. 
For example to execute {cmd:pandoc} one could code

{phang2}{cmd:. whereis pandoc}{p_end}
{phang2}{cmd:. shell "`r(pandoc)'" {it:arguments}}

{pstd}
Some programmers ask users to store resource locations using global
macros defined in the user's profile.do file. 
The {bf:whereis} command has the advantage of running on demand 
and checking that the file or folder is in fact at the specified location, 
both when storing and retrieving the resource location.

{title:Acknowledgement}

{pstd}
Diana Goldemberg suggested using {bf:whereis} to store folders as well as files
and indicated how to modify the code to enable this extension.

{title:Author}

{pstd}
Germ{c a'}n Rodr{c i'}guez <grodri@princeton.edu>
{browse "https://data.princeton.edu/stata/whereis":data.princeton.edu/stata/whereis}.
