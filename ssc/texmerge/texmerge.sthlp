{smcl}
{* *! version 1.2.1  9dec2016}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help texmerge"}{...}
{viewerjumpto "Syntax" "texmerge##syntax"}{...}
{viewerjumpto "Description" "texmerge##description"}{...}
{viewerjumpto "Options" "texmerge##options"}{...}
{viewerjumpto "Remarks" "texmerge##remarks"}{...}
{viewerjumpto "Examples" "texmerge##examples"}{...}
{title:Title}

{phang}
{bf:texmerge} {hline 2} Merges .tex files into a single .tex file and compiles the new file to .pdf

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:texmerge}
{it:input_folder}{cmd:,} {cmdab:s:aveto(}{it:output_folder}{cmd:)} 
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt s:aveto(output_name)}}output folder {p_end}
{synopt:{opt f:iles(filenames)}}list of files merged; default is for all
        .tex files in {it:input_folder} to be processed{p_end}
{synopt:{opt pr:e(string)}}adds text to the beginning of the merged .tex document {p_end}
{synopt:{opt po:st(string)}}adds text to the end of the merged .tex document{p_end}
{synopt:{opt pdf:latex}}if specified .tex file will be compiled using pdflatex {p_end}
{synopt:{opt d:el}}if specified new .tex file created in {it:input_folder} will be deleted {p_end}
{synopt:{opt n:ewfile(filename)}}name of output .tex and .pdf file; default name is "mergedfiles" {p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:texmerge} creates a new .tex file in {it:input_folder} which merges all inputted .tex files. A .tex
file of the same name will be created in {it:output_folder} with additional text provided in {opt pre} and 
{opt post}. If {opt pdflatex} is specified the .tex file in {it:output_folder} will be compiled using 
pdflatex.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt saveto(output_folder)} specifies that the new .tex and .pdf files will be  saved in
				{it:output_folder}.

{phang}
{opt files(filenames)} restricts processing to specified files. These files must
			be located in {it:input_folder}. Input should follow the format 
			"file1.tex file2.tex file3.tex ...". Files will be merged in the order they are
			inputted. So text in "file1" will be located at the top of the new file and will be followed by
			text in "file2" and so on.
				
{phang}
{opt pre(string)} adds text in {it:string} to the beginning of the merged .tex file. To add multiple lines
of text parse each separate line with "|". 

{phang}
{opt post(string)} adds text in {it:string} to the end of the merged .tex file. To add multiple lines
of text parse each separate line with "|". 
			
{phang}
{opt pdflatex} specifies that the output .tex file be compiled using pdflatex. The compiled file will
be saved in {it:output_folder}.

{phang}
{opt del} removes the outputted merged .tex file from {it:input_folder}. This .tex file is created during
processing and includes merged text from all inputted .tex files but does not include additional text 
provided by {opt pre} and {opt post}

{phang}
{opt newfile} gives the name of the new .tex and .pdf files to be created. The default name is "mergedfiles".
{it:filename} cannot already exist in either {it:input_folder} or {it:output_folder}.

{marker remarks}{...}
{title:Remarks}

{pstd}
All inputted .tex files are merged into a single .tex file and saved in {it:input_folder}. 
In {it:output_folder} a new .tex file is created which includes merged text from all inputted .tex files
and includes text provided in {opt pre} and {opt post} at the beginning and end of the .tex file. If 
{opt pdflatex} is provided the .tex file in {it:output_folder} will be compiled to .pdf.

{pstd}
If {opt files} is not specified then the order in which files are merged to the new .tex file is alphabetical.

{pstd}
If neither {opt pre} or {opt post} options are supplied then no new .tex is created in {it:input_folder} but a
merged .tex file will still be created in {it:output_folder} and will be compiled to .pdf if {opt pdflatex} is
given. 

{pstd}
{cmd:texmerge} requires {bf:{help tknz:tknz}}, {bf:{help texcompiler:texcompiler}} and 
{bf:{help appendfile:appendfile}}  to be installed.


{marker examples}{...}
{title:Examples}

{pstd}{bf:Example 1: Merging files without compiling}

{pstd}Merge all .tex files located in C:\Users\texfiles to a single .tex file. The files will be
merged in alphabetical order.{p_end}
{phang2}{cmd:. texmerge C:\Users\texfiles, s(C:\Users\output) }{p_end}

{phang2}{cmd:. texmerge C:\Users\texfiles, s(C:\Users\output) n(mergedtex.tex) }{p_end}

{pstd}Merge selected files with text from "file1.tex" apearing before "file2.tex"
in the merged .tex file.{p_end}
{phang2}{cmd:. texmerge C:\Users\texfiles, s(C:\Users\output) n(mergedtex.tex) f(file1.tex file2.tex)}{p_end}


{pstd}{bf:Example 2: Merging files and compiling}

{pstd}Merge all .tex files located in C:\Users\texfiles to a single .tex file. The files will be
merged in alphabetical order. Note that the .tex file will only compile properly if the input 
.tex files have the appropriate preamble in the file appearing first in the alphabet and the 
appropriate closing lines in the file coming last in the alphabet.{p_end}
{phang2}{cmd:. texmerge C:\Users\texfiles, s(C:\Users\output) pdf }{p_end}

{pstd}Merge selected files with text from "file1.tex" apearing before "file2.tex"
in the merged .tex file. Note that "file1.tex" must contain the appropriate preamble and 
"\end{document}" must be the final line in "file2.tex" {p_end}
{phang2}{cmd:. texmerge C:\Users\texfiles, s(C:\Users\output) n(mergedtex.tex) f(file1.tex file2.tex) pdf}{p_end}


{pstd}{bf:Example 3: Merging files, adding additional text and compiling}

{pstd}Merge all .tex files located in C:\Users\texfiles to a single .tex file with
 additional lines added at the beginning and end. Because {opt newfile} is not given and {opt del} is not specified the
total output will be "mergedfiles.tex" in {it:input_folder}, and "mergedfiles.tex" and "mergedfiles.pdf"
in {it:output_folder}. "mergedfiles.tex" located in {it:input_folder} will not contain the additional
text specified in {opt pre} and {opt post}.{p_end}

{phang2}{cmd:. local begin "\documentclass[12pt]{article} | \usepackage{fullpage} | \begin{document}"}{p_end}
{phang2}{cmd:. local end "\end{document}"}{p_end}
{phang2}{cmd:. texmerge C:\Users\texfiles, s(C:\Users\output) pr(`begin') po(`end') pdf}{p_end}

{pstd}To make clear how the final .tex document will look consider the following example where 2 files are merged. {p_end}

{phang2}{cmd:. local begin "\documentclass[12pt]{article} | \usepackage{fullpage} | \begin{document}"}{p_end}
{phang2}{cmd:. local end "\end{document}"}{p_end}
{phang2}{cmd:. texmerge C:\Users\texfiles, s(C:\Users\output) pr(`begin') po(`end') f(file1.tex file2.tex) pdf}{p_end}

{pstd}In this case the final file will look like the following: {p_end}
{phang2}{bf: \documentclass[12pt]{article}}{p_end}
{phang2}{bf: \usepackage{fullpage}}{p_end}
{phang2}{bf: \being{document}}{p_end}
{phang2}{bf: first line in file1.tex file}{p_end}
{phang2}{bf: second line in file1.tex file}{p_end}
{phang2}{bf: ...}{p_end}
{phang2}{bf: final line in file1.tex file}{p_end}
{phang2}{bf: first line in file2.tex file}{p_end}
{phang2}{bf: ...}{p_end}
{phang2}{bf: final line in file2.tex file}{p_end}
{phang2}{bf: \end{document}}{p_end}


{marker author}{...}
{title:Author}

{pstd}Iain Snoddy{p_end}
{pstd}iainsnoddy@gmail.com{p_end}
