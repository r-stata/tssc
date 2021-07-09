{smcl}
{* November 19, 2010 @ 11:32:16}{...}
{hi:help lado}
{hline}

{title:Title}

{phang} Featured list of ado-files {p_end}

{title:Syntax}
{phang2}{cmd:lado} [ {it:stub} ] {cmd:, }{cmdab:e:rase}  

{pstd}where {it:stub} may be a dot, a single letter or any combination
of characters that can be used for file names, or a dot followed by a
single letter of any combination of characters that can be used for
file names. 

{title:Description}

{pstd} {cmd:lado} is developed for ado file programmers. It returns a
list of ado files stored in the working directory or in any other
directory that has been set as the "ado development folder". If
{it:stub} is specified, only files with names containing {it: stub}
are listed. Along with the file names, the programs offer a list of
click-able links for some typical tasks that one wants to do for
{it:own} ado files. {p_end}

{pstd}Specifically, {cmd:lado} provides links for viewing and editing
each ado file. If a help file exists links for getting help and
editing the help file are also provided. {p_end}

{pstd} By default, the Stata do-file editor is invoked for editing ado
files and help files. However, you can use a different editor by
setting the global macro "MYEDITOR" to the command that opens your
preferred text editor. I, for example, have the line {p_end}

{p 8 0 0} {hline 19} profile.do {p_end}
{p 8 0 0} {cmd:global MYEDITOR !emacsclient -n}{p_end}
{p 8 0 0} {hline 31}{p_end}

{pstd}in my profile file, which works under Linux. Windows users might
prefer something along the following lines

{p 8 0 0} {hline 20} profile.do {p_end}
{p 8 0 0} {cmd:global MYEDITOR winexec textpad}{p_end}
{p 8 0 0} {hline 31}{p_end}

{pstd}Note that setting the macro MYEDITOR also affects the editor
used to open do-files with {help ldo} and the editor used to open
tex-files  with {help ltex}.{p_end}

{pstd}By default, {cmd:lado} lists the ado files in the working
directory. However, you can predefine an
{hi:ado development directory} which is then used instead of the working
directory.  This is done by setting the global macro "ADODEVELOPMENT" to the
directory in which own ado files are created. I have {p_end}

{p 8 0 0} {hline 24} profile.do {p_end}
{p 8 0 0} {cmd:global ADODEVELOPMENT "~/ado/cooker/"}{p_end}
{p 8 0 0} {hline 35}{p_end}

{pstd}in my profile file.{p_end}

{pstd}The ado development folder can be overwritten interactively by
typing a dot in front of or instead of the stub. The command 

{phang2}{cmd:. lado .}{p_end}

{pstd}will list all ado files of your current directory even if you
have predefined an ado development folder. Likewise,

{phang2}{cmd:. lado .l}{p_end}

{pstd}will list all ado files of your current directory starting with
the letter l. 

{title:Options}

{phang}{cmdab:e:rase} brings up yet another click-able item which
allows to erase files on disk. Clicking on that item removes the
respective file immediately from the disk. The file is not moved to
the recycle bin. The erase button is printed in red to
indicate that it should be handled with care.
{p_end}


{title:Example}

{phang2}{cmd:. lado}{p_end}
{phang2}{cmd:. lado, erase}{p_end}


{title:Author}

{pstd}Ulrich Kohler, kohler@wzb.eu{p_end}

{title:Also see}

{psee} Online: {help dirtools}, {help lall}, {help ldir}, {help ltex}, {help cdout}, {help clickout},
{help fastcd} (if installed)
{p_end}

