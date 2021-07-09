{smcl}
{* Juli 22, 2011 @ 12:19:25}{...}
{hi:help lall}, {hi:help ldo}, {hi:help ldta}, {hi:help lgph}, {hi:help lsmcl}
{hline}

{title:Title}

{phang}
Featured list of Stata files in the working directory
{p_end}

{title:Syntax}

{phang2}{cmd:lall} [ {it:stub} ] [{cmd:, }{cmdab:e:rase}]{p_end}

{phang2}{cmd:ldo} [ {it:stub} ] [{cmd:, }{cmdab:e:rase}]{p_end}

{phang2}{cmd:ldta} [ {it:stub} ] [{cmd:, }{cmdab:e:rase}]{p_end}

{phang2}{cmd:lgph} [ {it:stub} ] [{cmd:, }{cmdab:e:rase}]{p_end}

{phang2}{cmd:lmata} [ {it:stub} ] [{cmd:, }{cmdab:e:rase}]{p_end}

{phang2}{cmd:lsmcl} [ {it:stub} ] [{cmd:, }{cmdab:e:rase}]{p_end}

{pstd}where {it:stub} may be a single letter or any combination of
characters that can be used for filenames.

{title:Description}

{pstd} The above programs return lists of Stata files in the working
directory. Along with the file names, the programs offer a list of
click-able links for some typical tasks that one wants to do for the
files.{p_end}

{pstd}If {it:stub} is specified, only files with names containing
{it: stub} are listed.{p_end}

{pstd}All programs save back the list of files in a local
macro.{p_end}

{pstd}{cmd:ldta} provides links for describing, and using each
Stata data set in the working directory.{p_end}

{pstd}{cmd:ldo} provides links for viewing, editing, and running each
Stata do-file in the working directory. You can define the Editor that
is invoked when clicking on the edit-item of {cmd:ldo} by setting the
global macro "MYEDITOR" to the command that opens your preferred text
editor. I, for example, put {p_end}

{p 8 0 0} {hline 19} profile.do {p_end}
{p 8 0 0} {cmd:global MYEDITOR !emacsclient -n}{p_end}
{p 8 0 0} {hline 31}{p_end}

{pstd}in my profile file, which works under Linux. Windows users might
prefer something along the following lines

{p 8 0 0} {hline 20} profile.do {p_end}
{p 8 0 0} {cmd:global MYEDITOR winexec textpad}{p_end}
{p 8 0 0} {hline 31}{p_end}

{pstd}{cmd:lsmcl} provides links for viewing, and translating each
Stata SMCL-file in the working directory.{p_end}

{pstd}{cmd:lgph} provides links for displaying, printing, and
exporting each Stata gph file in the working directory.{p_end}

{pstd}{cmd:lmata} provides links for viewing, editing, and compiling
each Mata-file in the working directory. You can define the Editor
that is invoked when clicking on the edit-item of {cmd:lmata} by setting
the global macro "MYEDITOR" to the command that opens your preferred
text editor. See help for {cmd:ldo} above.{p_end}

{pstd}{cmd:lall} provides links for all .dta, .do, .smcl, and .gph
files in the working directory along with the click-able links
described above.{p_end}

{pstd}The programs are most valueable if you link them with a
function-key in your profile (see help {help profile}). If you, for
example, add the following lines in your profile.do file, you can
issue the commands by pressing F4, F5, F6 or F7 respectively. {p_end}

{pstd} {hline 15} profile.do {p_end}
{pstd} {cmd:global F4 "ldta, erase ;"}{p_end}
{pstd} {cmd:global F5 "ldo, erase ;"}{p_end}
{pstd} {cmd:global F6 "lgph, erase ;"}{p_end}
{pstd} {cmd:global F7 "lsmcl, erase ;"}{p_end}
{pstd} {hline 26}{p_end}

{title:Options}

{phang}{cmdab:e:rase} brings up yet another click-able item which
allows to erase files on disk. Clicking on that item removes the
respective file immediately from the disk. The file is not moved to
the recycle bin. The erase button is printed in red to
indicate that it should be handled with care.
{p_end}


{title:Example}

{phang2}{cmd:. ldo}{p_end}
{phang2}{cmd:. ldta}{p_end}
{phang2}{cmd:. lgph, e}{p_end}
{phang2}{cmd:. lsmcl, e}{p_end}

{title:Authors}

{pstd}Ulrich Kohler, kohler@wzb.eu{p_end}
{pstd}Roy Wada, roywada@hotmail.com{p_end}

{title:Also see}

{psee} Online: {help cdout}, {help clickout},
{help fastcd} (if installed)
{p_end}

