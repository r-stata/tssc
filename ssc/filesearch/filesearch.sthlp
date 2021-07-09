{smcl}
{* *! version 1.0 20 September 2018}{...}
{vieweralsosee "neps" "help neps"}{...}
{vieweralsosee "nepsmgmt" "help NEPSmgmt"}{...}
{vieweralsosee "ls" "help ls"}{...}
{viewerjumpto "Syntax" "filesearch##syntax"}{...}
{viewerjumpto "Description" "filesearch##description"}{...}
{viewerjumpto "Options" "filesearch##options"}{...}
{viewerjumpto "Remarks" "filesearch##remarks"}{...}
{viewerjumpto "Examples" "filesearch##examples"}{...}
{viewerjumpto "Author" "filesearch##author"}{...}
{viewerjumpto "Also see" "filesearch##alsosee"}{...}
help for {cmd:filesearch}  {right:version 1.0  (20 September 2018)}
{hline}


{title:Title}

{phang}
{bf:filesearch} {hline 2} recursively list files matching to a pattern or regular expression


{title:Table of contents}

	{help filesearch##syntax:Syntax}
	{help filesearch##description:Description}
	{help filesearch##options:Options}
	{help filesearch##remarks:Remarks}
	{help filesearch##examples:Examples}
	{help filesearch##author:Author}
	{help filesearch##results:Saved results}
	{help filesearch##alsosee:Also see}


{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmd:filesearch} [[{c 'g}]"]{hilite:pattern}["[']] [, {it:options}]{p_end}

{p 12 18 2}Note: If {hilite:pattern} contains at least one comma, it has to be enclosed in double quotes.{break}
If {hilite:pattern} contains double quotes, it has to be enclosed in compound double quotes (see {help quotes:help quotes}).{p_end}

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Searching}
{synopt:{opt subdir:ectories}} search for subdirectory names instead of filenames{p_end}
{synopt:{opt dir:ectory(directory)}} search in {it:directory}{p_end}
{synopt:{opt r:ecursive}} recursive search in subdirectories{p_end}
{synopt:{opt m:axdepth(num)}} descend no more than {it:num} levels into subdirectories in recursive search{p_end}
{synopt:{opt regex:pression}} {hilite:pattern} is to be interpreted as regular expression{p_end}
{syntab:Output}
{synopt:{opt full:path}} return full file paths (instead of relative ones){p_end}
{synopt:{opt noquote}} don't enclose results with double quotes{p_end}
{synopt:{opt quiet}} suppress displaying (non-error) output{p_end}
{synopt:{opt strip}} remove {hilite:pattern} from result{p_end}
{synopt:{opt l:ocal(macname)}} return result in local {it:macname} instead of {it:r(filenames)}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}
{title:Description}

{pstd}
{cmd:filesearch} (recursively) reads file- or subdirectory names from a filesystem directory.{...}
It can filter results by string match patterns or regular expressions.
It is quite similar to the popular {stata "ssc describe fs":fs} by Nicholas J. Cox, but adds additional capabilites.{p_end}

{phang}The most prominent additions are:{break}
{c -} case sensitive search even on Windows operating systems{break}
{c -} recursive search{break}
{c -} search using regular expressions instead of "simple" string matching patterns{p_end}


{marker options}
{title:Options}

{dlgtab:Searching}

{phang}
{opt subdirectories} if specified, search for subdirectory names instead of filenames.{p_end}

{phang}
{opt directory(directory)} if specified, search for the results inside {it:directory}. If omitted, the working directory is used.
{break}If {opt directory(directory)} is specified but {it:directory} is not accessible or does not exist, the working directory is used instead and a warning message is displayed.

{phang}
{opt recursive} if specified, the search is performed recursively throughout subdirectories in the specified {it:directory}.{p_end}

{phang}
{opt maxdepth(num)} implies {opt recursive}; if specified, recursive search will descend no more than {it:num} levels of subdirectories.{break}
{it:num} has to be a integer value greater or equal to 0, or the system missing value (leading to indefinite descent through subdirectores).{p_end}

{phang}
{opt regexpression} if specified, {hilite:pattern} will be treated as regular expression.{...}
{cmd:filesearch} will use Stata's regular expression engine to filter the results list.
Information about regular expressions can be found on the internet, and in {help regex:Stata's help} and {browse "https://www.stata.com/support/faqs/data-management/regular-expressions":FAQ} about the topic.{p_end}

{dlgtab:Output}

{phang}
{opt fullpath} if specified, search results will contain the full path (including {it:directory}).{p_end}

{phang}
{opt noquote} if specified, search results will not be quoted. Default is to enclose each result in double quotes.{p_end}

{phang}
{opt quiet} if specified, search results will not be displayed (but returned in {it:r()}).
Warning messages, if any, will be displayed anyways{p_end}

{phang}
{opt local(macname)} if specified, return search results to the local macro {it:macname} instead of {it:r()}.{break}
The local macro {it:macname} will be overwritten without warning.{p_end}

{phang}
{opt strip} if specified, remove the string part that matches {hilite:pattern} from the output.{p_end}


{marker remarks}
{title:Remarks}

{pstd}
It is recommended that even if you use Windows,{...}
you use forward slashes (/) rather than backward slashes (\) for specifying directory names.{...}
Stata will understand and there will then be no clash with other meanings for the backward slash.{p_end}

{pstd}
This command is part of the NEPmgmt bundle, written to help creating the {browse "https://www.neps-data.de/":NEPS} dataset files.{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later.{...}
The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.{p_end}

{pstd}
{cmd:filesearch} is the successor to an older command, {cmd:retrievefilenames}, which is now deprecated.{break}
Users of {cmd:retrievefilenames} are encouraged to migrate their syntax.{...}
The following table presents aid for translating your syntax:{p_end}

{p2colset 10 65 67 11}{...}
{p2col :{cmd:retrievefilenames} syntax}{text:{c -}{c -}>}{bind:      }{cmd:filesearch} syntax equivalent{p_end}
{p2line}
{p2col :{input:retrievefilenames}}{text:{c -}{c -}>}{bind:      }{input:filesearch *}{p_end}
{p2col :{input:retrievefilenames, filedirectory(dirname)}}{text:{c -}{c -}>}{bind:      }{input:filesearch *, directory(dirname)}{p_end}
{p2col :{input:retrievefilenames, subdirectories}}{text:{c -}{c -}>}{bind:      }{input:filesearch *, subdirectories}{p_end}
{p2col :{input:retrievefilenames, extension(dta)}}{text:{c -}{c -}>}{bind:      }{input:filesearch *.dta}{p_end}
{p2col :{input:retrievefilenames, searchexpression(\.(dta)|(DTA)$)}}{text:{c -}{c -}>}{bind:      }{input:filesearch \.(dta)|(DTA)$, regexpression}{p_end}
{p2col :{input:retrievefilenames, extension(dta) local(filelist)}}{text:{c -}{c -}>}{bind:      }{input:filesearch *.dta, local(filelist)}{p_end}
{p2col :{input:retrievefilenames, extension(dta) strip}}{text:{c -}{c -}>}{bind:      }{input:filesearch \.dta$, regexpression strip}{p_end}
{p2colreset}{...}


{marker examples}
{title:Examples}

{phang}Get all filenames from working directory:{p_end}
{phang}{cmd:. filesearch *}{p_end}

{phang}Get all names of subdirectories from working directory:{p_end}
{phang}{cmd:. filesearch *, subdirectories}{p_end}

{phang}Find all files ending with "{it:.txt}" in working directory:{p_end}
{phang}{cmd:. filesearch *.txt}{p_end}

{phang}Retrieve filenames ending with "{it:.txt}" from directory {it:/home/user/Desktop} and remove "{it:.txt}" from output:{p_end}
{phang}{cmd:. filesearch \.txt$, directory(/home/user/Desktop) regexpression strip}{p_end}

{phang}Do the same, put suppress displaying the results:{p_end}
{phang}{cmd:. filesearch \.txt$, directory(/home/user/Desktop) regexpression strip quiet}{p_end}

{phang}Recursively search all files ending with "{it:.txt}" in all subdirectories of {it:/home/user/Desktop},{...}
and return their full path names:{p_end}
{phang}{cmd:. filesearch *.txt, directory(/home/user/Desktop) recursive fullpath}{p_end}


{marker author}
{title:Author}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}), Leibniz Institute for Educational Trajectories (LIfBi), Germany.{p_end}


{marker results}
{title:Saved results}

{pstd}
{cmd:filesearch} saves the following in {cmd:r()}:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Locals}{p_end}
{synopt:{cmd:r(filenames)}}filenames that match the search pattern{p_end}
{pin}or{p_end}
{synopt:{cmd:r(dirnames)}}subdirectory names retrieved that match the search pattern (if option {opt subdirectories} is specified){p_end}
{pin}or{p_end}
{synopt:{it:nothing}}, if option {opt local()} is specified{p_end}
{p2colreset}{...}


{marker alsosee}
{title:Also see}

{psee}
{space 2}Help: {help NEPSmgmt}, {help ls}, {manhelp f_regexm F}, {browse "http://www.stata.com/support/faqs/data/regex.html"}
{p_end}
