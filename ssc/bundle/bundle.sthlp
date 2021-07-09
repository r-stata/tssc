{smcl}
{* 21sep2014}{...}
{cmd:help bundle}
{hline}

{title:Title}

    {hi:Bundle png images in a web page by encoding them using base64}

{title:Syntax}

{p 8 18 2}
{cmd: bundle} {cmd:using} {it:{help filename:filename_in}} 
	[{cmd:,}
	{opt out:put(filename_out)}]

{title:Description}

{pstd}
{opt bundle} reads an html file, finds all image tags linking to png files,
reads each file in turn, and attaches the image to the document by encoding 
it in base 64 format using a data URI.

{pstd}
The name of the input file may omit the extension, which will
default to {cmd:.html}. This must be an existing file.

{pstd}
The name of the output file is optional. If omitted the command
will use the same name and extension as the input file appending
{cmd:-b} (for bundle) to the name. If the name is specified the 
extension may be omitted and will default to {cmd:.html}. 
If the file exists it will be overwritten.

{pstd}
The command lists each image file as it is processed. 
If no image files are found no output is generated.

{title:Examples}

{pstd}Bundle images in page.html and write page-b.html{p_end}
{phang2}{cmd:. bundle using page}

{pstd}Read source.html and save with encoded images in bundled.html{p_end}
{phang2}{cmd:. bundle using source, out(bundled)}

{pstd}Bundle images in links.htm and save self-contained page links2.htm{p_end}
{phang2}{cmd:. bundle using links.htm, out(links2.htm)}

{title:Author}

{pstd}
	G. Rodr{c i'}guez <grodri@princeton.edu> 
	{browse "http://data.princeton.edu/stata/bundle":data.princeton.edu/stata/bundle}.

