{smcl}
{* *! version 1.0.1 06jul2021}{...}
{viewerjumpto "Title" "docd##title"}{...}
{viewerjumpto "Syntax" "docd##syntax"}{...}
{viewerjumpto "Description" "docd##description"}{...}
{viewerjumpto "Examples" "docd##examples"}{...}
{viewerjumpto "Author" "docd##author"}{...}
{viewerjumpto "Acknowledgement" "docd##acknowledgement"}{...}
{marker title}{...}
{title:Title}

{pstd}
splitpath {hline 2} Split a path to a file into the directory and the filename.


{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd:splitpath} 
{it:path}


{marker description}{...}
{title:Description}

{pstd}
{cmd:splitpath} splits the path to a file into the directory containing the file
and the filename. Relative directories are supported. The results are store in
{hi:r(directory)} and {hi:r(filename)} respectively.


{marker examples}{...}
{title:Examples}

	{cmd:. splitpath "sub\dir\example.do"}
	{cmd:. return list}
	
	macros:
		r(filename)  : "example.do"
		r(directory) : "sub/dir/"


	{cmd:. splitpath "..\dir\example.do"}
	{cmd:. return list}

	macros:
		r(filename)  : "example.do"
		r(directory) : "../dir/"


{marker author}{...}
{title:Author} 

{pstd}
Hendri Adriaens, Centerdata, The Netherlands.{break}
hendri.adriaens@centerdata.nl


{marker acknowledgement}{...}
{title:Acknowledgement}

The package borrowed code from the function {cmd:project_pathname} from the {cmd:project} package.
