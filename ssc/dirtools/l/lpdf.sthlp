{smcl}
{* August 18, 2011 @ 10:26:10 UK}{...}
{hi:help lpdf}
{hline}

{title:Title}

{phang}
Featured list of PDF files in the working directory
{p_end}

{title:Syntax}
{phang2}{cmd:lpdf} [ {it:stub} ] {cmd:, }{cmdab:e:rase}  

{pstd}where {it:stub} may be a single letter or any combination of
characters that can be used for filenames.

{title:Description}

{pstd} {cmd:lpdf} returns a list of portable document format files
(pdf) that are stored in the working directory. If {it:stub} is
specified, only files with names containing {it: stub} are
listed. Along with the file names, the programs offer a list of
click-able links for some typical tasks that one wants to do for PDF
files. {p_end}

{pstd}Specifically, {cmd:lpdf} provides links for viewing, printing,
and PostScript-conversion of each of the PDF files in the working
directory. There is also a link for PostScript conversion of all PDF files
shown in the list. {p_end}

{pstd} PDF-conversion of the EPS-files is done with pdftops. This
requires that pdf2ps is properly installed on your system. Unter
Linux/UNIX/Mac this should be normaly the case. The same is true for
all Windows systems with a working installation of MiKTeX on it. After
converting the PDF file to PS, a link to open the file is created.


{title:Options}

{phang}{cmdab:e:rase} brings up yet another click-able item which
allows to erase files on disk. Clicking on that item removes the
respective file immediately from the disk. The file is not moved to
the recycle bin. The erase button is printed in red to
indicate that it should be handled with care.
{p_end}


{title:Example}

{phang2}{cmd:. lpdf}{p_end}

{title:Author}

{pstd}Ulrich Kohler, kohler@wzb.eu{p_end}

{title:Also see}

{psee} Online: {help dirtools}, {help ldir}, {help lall}, {help cdout}, {help clickout},
{help fastcd} (if installed)
{p_end}

