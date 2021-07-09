{smcl}
{* Juli 16, 2009 @ 09:05:25 UK}{...}
{hi:help ltex}
{hline}

{title:Title}

{phang}
Featured list of LaTeX files in the working directory
{p_end}

{title:Syntax}
{phang2}{cmd:ltex} [ {it:stub} ] {cmd:, }{cmdab:e:rase}  

{pstd}where {it:stub} may be a single letter or any combination of
characters that can be used for filenames.

{title:Description}

{pstd} {cmd:ltex} returns a list of LaTex files that are stored in the
working directory. If {it:stub} is specified, only files with names
containing {it: stub} are listed. Along with the file names,
the programs offer a list of click-able links for some typical tasks
that one wants to do for LaTeX files. {p_end}

{pstd}Specifically, {cmd:ltex} provides links for viewing, editing,
and typesetting each of the LaTeX files in the working directory.{p_end}

{pstd} By default, the Stata do-file editor is invoked when clicking
the edit-item of the {cmd:ltex}-output. However, you can use a
different editor by setting the global macro "MYEDITOR" to the command
that opens your preferred text editor. I, for example, have the line
{p_end}

{p 8 0 0} {hline 19} profile.do {p_end}
{p 8 0 0} {cmd:global MYEDITOR !emacsclient -n}{p_end}
{p 8 0 0} {hline 31}{p_end}

{pstd}in my profile file, which works under Linux. Windows users might
prefer something along the following lines

{p 8 0 0} {hline 20} profile.do {p_end}
{p 8 0 0} {cmd:global MYEDITOR winexec textpad}{p_end}
{p 8 0 0} {hline 31}{p_end}

{pstd}Note that setting the macro MYEDITOR also affects the editor
used to open do-files with {help ldo}.{p_end}

{pstd} Typesetting the LaTeX-file is done with the pdflatex, which
produces PDF output. After typesetting, the created file is opened
immediately. Typesetting requires that LaTeX is installed properly on
your computer. Opening the created PDF requires that a previewer for
PDF files is installed on the computer. By default, acrobat reader is
assumed as previewer, but this can be changed by setting the global
macro "MYPDFVIEWER". I, for example have the{p_end}

{p 8 0 0} {hline 19} profile.do {p_end}
{p 8 0 0} {cmd:global MYPDFVIEWER xpdf}{p_end}
{p 8 0 0} {hline 31}{p_end}

{pstd}in my profile file.{p_end}


{title:Technical note}

{pstd}LaTeX files produced by Stata are often incomplete in the sense
that they don't have a preamble. Before typesetting {cmd:ltex}
therefore looks in the first 30 rows of the file whether there is a
preamble or not. If not, {cmd:ltex} tries to run the file with a
minimal preamble. This works sometimes, but sometimes not.{p_end}

{title:Options}

{phang}{cmdab:e:rase} brings up yet another click-able item which
allows to erase files on disk. Clicking on that item removes the
respective file immediately from the disk. The file is not moved to
the recycle bin. The erase button is printed in red to
indicate that it should be handled with care.
{p_end}


{title:Example}

{phang2}{cmd:. ltex}{p_end}

{title:Author}

{pstd}Ulrich Kohler, kohler@wzb.eu{p_end}

{title:Also see}

{psee} Online: {help ldta}, {help cdout}, {help clickout},
{help fastcd} (if installed)
{p_end}

