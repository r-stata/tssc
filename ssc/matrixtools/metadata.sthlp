{smcl}
{* *! version 0.23}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "filelist (If installed)" "help filelist"}{...}
{vieweralsosee "Help describe" "help describe"}{...}
{viewerjumpto "Syntax" "metadata##syntax"}{...}
{viewerjumpto "Description" "metadata##description"}{...}
{viewerjumpto "Examples" "metadata##examples"}{...}
{viewerjumpto "Author and support" "metadata##author"}{...}
{title:Title}
{phang}
{bf:metadata} {hline 2} Presenting metadata from one or more Stata datasets

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:metadata}
{help varlist:varlist}
[{help using:using/}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt sa:vein(string)}} Specify file to save metadata within. The 
filename must have one of the suffix dta or one of the styles from the 
{opt s:tyle} option.{break}
{red:The suffix overrules the {opt s:tyle} option below}.{p_end}
{synopt:{opt k:eep}} Keep metadata in Data editor.{p_end}
{synopt:{opt nol:og}} Do not show any output in the log.{p_end}
{synopt:{opt se:archsubdirs}} If this option is set subdirectories are also 
searched for dataset for which to include metadata. If not set only the specified
directory is searched for datasets.{p_end}
{syntab: {help matprint:matprint} options}
{synopt:{opt s:tyle(string)}} Style for output. One of the values {bf:smcl} (default), 
{bf:csv} (semicolon separated style), 
{bf:latex or tex} (latex style),
{bf:html} (html style) and
{bf:md} (markdown style) 
.{p_end}
{synopt:{opt c:aption(string)}} Title/caption for the matrix output.{p_end}
{synopt:{opt to:p(string)}} String containing text prior to table content.
Default is dependent of the value of the style option.{p_end}
{synopt:{opt u:ndertop(string)}} String containing text between header and table 
content.
Default is dependent of the value of the style option.{p_end}
{synopt:{opt b:ottom(string)}} String containing text after to table content.
Default is dependent of the value of the style option.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:metadata} is a tool to get metadata of datasets without necessarily having
to load the datasets. 

{pstd}The {opt using:} modifier can either a dataset or a directory as argument.

{pstd}If a dataset is specified then the metadata of that dataset is presented in the
Result window, possibly saved in a specified dataset and possibly send Data
Editor window.

{pstd}If a directory is specified then metadata of all datasets in that directory are 
collected.

{pstd}If further the option subdirectories is set then metadata in that directory as 
well as all subdirectories are collected.

{marker examples}{...}
{title:Examples}

{pstd}Below is a set of examples. You can copy the code and insert it in the 
command window or you can just click once on each blue line below.
Then the command is automatically moved to the command window and executed.{p_end}
{pstd}Note that there is progression in the examples such a command line may require 
some of the previous lines to show the intended properly.{p_end}

{phang}First set up the log window to be wider:{p_end}
{phang}{stata `"set linesize 180"'}{p_end}

{phang}And get an example dataset:{p_end}
{phang}{stata `"sysuse auto, clear"'}{p_end}

{phang}{cmd:metadata} is similar discribe, however more meta values are reported:{p_end}
{phang}{stata `"metadata *"'}{p_end}
{phang}{stata `"describe"'}{p_end}

{phang}If the variable xxx do not exist an error is returned:{p_end}
{phang}{stata `"metadata weight make xxx foreign"'}{p_end}

{phang}Subset of variables can chosen using classical notation:{p_end}
{phang}{stata `"metadata weight make foreign rep78"'}{p_end}

{phang}The same output in html:{p_end}
{phang}{stata `"metadata weight make foreign rep78, style(htm) caption(Output in HTML)"'}{p_end}

{phang}{cmd:metadata} can peep into other datasets whithout loosing the current 
dataset:{p_end}
{phang}{stata `"metadata * using `"`c(sysdir_base)'c/census.dta"'"'}{p_end}

{phang}When {cmd:metadata} have a directory after using all datasets in that
directory as well as all subdirectories etc are added:{p_end}
{phang}{stata `"metadata * using `"`c(sysdir_base)'c"', savein(meta.dta, replace) keep"'}{p_end}
{phang}Option {opt sa:vein} makes possible to save metadata in file and option
{opt k:eep} places the metadata in the Data Editor window.{p_end}

{phang}One can limit the to a subset of variables, eg the ones starting with m:{p_end}
{phang}{stata `"metadata m* using `"`c(sysdir_base)'"', savein(meta.md, replace) searchsubdirs"'}{p_end}
{phang}The file metadata.md is saved in the present working directory and it 
can be opened from there in your favorite editor.{p_end}

{phang}Looking for subset of variables can be handy eg when one is looking for 
keys to merge upon.{p_end}
{phang}And one need not close the current data or save it in a file.{p_end}
{phang}{stata `"metadata m* using `"`c(sysdir_base)'"', searchsubdirs"'}{p_end}


{browse "http://www.bruunisejs.dk/StataHacks/My%20commands/metadata/metadata_demo/":To see more examples}


{marker author}{...}
{title:Author and support}

{phang}{bf:Author:}{break}
 	Niels Henrik Bruun, {break}
	Section for General Practice, {break}
	Dept. Of Public Health, {break}
	Aarhus University
{p_end}
{phang}{bf:Support:} {break}
	{browse "mailto:nhbr@ph.au.dk":nhbr@ph.au.dk}
{p_end}
