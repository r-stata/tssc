{smcl}
{* November 19, 2010 @ 12:16:53}{...}
{hi:help leps}
{hline}

{title:Title}

{phang}
Featured list of EPS files in the working directory
{p_end}

{title:Syntax}
{phang2}{cmd:ltex} [ {it:stub} ] {cmd:, }{cmdab:e:rase}  

{pstd}where {it:stub} may be a single letter or any combination of
characters that can be used for filenames.

{title:Description}

{pstd} {cmd:leps} returns a list of encapsulated postscript files
(eps) that are stored in the working directory. If {it:stub} is
specified, only files with names containing {it: stub} are
listed. Along with the file names, the programs offer a list of
click-able links for some typical tasks that one wants to do for EPS
files. {p_end}

{pstd}Specifically, {cmd:leps} provides links for viewing, printing,
and PDF-conversion of each of the EPS files in the working
directory. There is also a link for PDF conversion of all EPS files
shown in the list. {p_end}

{pstd} PDF-conversion of the EPS-files is done with epstopdf. This
requires that epstopdf is properly installed on your system. Unter
Linux/UNIX/Mac this should be normaly the case. The same is true for
all Windows systems with a working installation of MiKTeX on it. After
converting the EPS file to PDF, a link to open the file is created.


{title:Options}

{phang}{cmdab:e:rase} brings up yet another click-able item which
allows to erase files on disk. Clicking on that item removes the
respective file immediately from the disk. The file is not moved to
the recycle bin. The erase button is printed in red to
indicate that it should be handled with care.
{p_end}


{title:Example}

{phang2}{cmd:. leps}{p_end}

{title:Author}

{pstd}Ulrich Kohler, kohler@wzb.eu{p_end}

{title:Also see}

{psee} Online: {help dirtools}, {help ldir}, {help lall}, {help cdout}, {help clickout},
{help fastcd} (if installed)
{p_end}

