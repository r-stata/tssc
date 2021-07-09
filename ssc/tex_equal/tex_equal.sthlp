{smcl}
{* 7july2014}{...}
{cmd:help tex_equal}{right:Version 1.0.0}
{hline}

{title:Title}

{p 4 11 2}
{hi:tex_equal} {hline 2} Compare ASCII text or binary files{p_end}


{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:tex_equal}  
[, {break}
{cmdab:file1}({it:filename1)} {break}
{cmdab:file2}({it:filename2)} {break}
{cmdab:display} {break}
{cmdab:range}({it:numlist}) {break}
{cmdab:lines}({it:integer})]

{synoptset 35 tabbed}{...}
{synopthdr:{it:}{col 18}}
{synoptline}
{syntab: Main}
{p2coldent :* {cmdab:file1}({it:filename1})}Name of the first file.{p_end}
{p2coldent :* {cmdab:file2}({it:filename2})}Name of the second file.{p_end}
   
{syntab: Options}
{synopt :{opt display}}Display differences if any.{p_end}
{synopt :{opt range}(numlist  min=1 max=2)}Select a specific range of the file.{p_end}
{synopt :{opt lines}(integer)}Number of lines after first finding on {it:range} option.{p_end}
{synoptline}
{p 4 6 2}* Required option{p_end}

{marker desc}{title:Description}

{pstd} {cmd:tex_equal} is aimed to compare the contents of {it:file1} with {it:file2}. It is 
extremely useful when dealing with many files to compare. The comparison is done line by line
e.g. line 1 in {it:file1} against line 1 in {it:file2}. Furthermore, it allows to compare either the 
whole file or an extract using the {it:range} and/or {it:lines} options.  Use this command to compare
 any type of ASCII text or binary files.

{pstd}While the command has not been set to display discrepancies it's possible to do so using the
{it:display} option. Finally, the program allows opening
each of the files (using the default program set by the computer) just clicking on the icon {it:open}.

{title:Options description}

{dlgtab:Main}

{phang}
{cmd: file1}{it:(filename1)} name of the first file. It is important to add the extension of the file
	like .do, .ado or .txt, among others.

{phang}
{cmd: file2}{it:(filename2)} name of the second file. As before, its important to add the 
	extension of the file.
   
{dlgtab:Options}

{phang}
{cmd: display} present existing discrepancies between files, if any, in
	the result screen. When this option is active, lines with discrepancies belonging to each of
	the files, will appear in the result screen. Furthermore, this option presents the line's number
	and each the complete text in both files present at that line.
	
{phang}
{cmd: range}{it:(numlist min=1 max=2)} specify range of lines over which the analysis should be done. If
 two elements are specified, the comparison will be done over that section of the file. If only one 
 element is specified and lines option is also used, the section 
 will start in that line and conclude in the number of lines added through the {it:lines} option. 
	For example range(3) lines(10) will analyze the lines of a certain file from line 3 to line 13 
	because 10 lines ahead was specified.If {it:lines} option is missing and only one element is 
	specified in the range option, the comparison will start on the selected line until the end of the file.

{phang}
{cmd: lines}{it:(integer)} if a complete range is provided in the {it:range} option, i.e. two 
	elements, this option is not allowed. It is useful only in the case that just one element
	is specified. If {it:lines} is zero, the analysis will be done only in the line specified in the 
	range option.{p_end}

	
{title:Stored results}

{p 4 2 1}
{cmd:tex_equal} stores the following in {cmd:r()}:

{synopt:{cmd:r(comparison)}}is equal to 1 if files are the same or 0 otherwise{p_end}
{synopt:{cmd:r(ndif)}}number of differences if any{p_end}
{synopt:{cmd:r(file1)}}Name of {it:filename1}{p_end}
{synopt:{cmd:r(file2)}}Name of {it:filename2}{p_end}
		
{title:Author}

{p 4} Santiago Garriga {p_end}
{p 4} Facultad de Ciencias Económicas (UNLP - Argentina)  {p_end}
{p 4} LCSPP - World Bank {p_end}
{p 4} {browse "mailto:garrigasantiago@gmail.com":garrigasantiago@gmail.com}

{title:Also see}

{psee}
{helpb file}, {helpb filefilter}
{p_end}

