{smcl}
{cmd:help pathutil}
{hline}

{title:Title}

{p 5}
{cmd:pathutil} {hline 2} File path manipulation


{title:Syntax}

{p 5 8 2}
Split path

{p 8 8 2}
{cmd:pathutil split} 
[{cmd:"}]{it:{help filename:path}}[{cmd:"}]


{p 5 8 2}
Cut path into pieces

{p 8 8 2}
{cmd:pathutil pieces} 
[{cmd:"}]{it:{help filename:path}}[{cmd:"}]


{p 5 8 2}
Join path

{p 8 8 2}
{cmd:pathutil join} 
[{cmd:"}]{it:{help filename:path1}}[{cmd:"}]
[{cmd:"}]{it:{help filename:path2}}[{cmd:"}]


{p 5 8 2}
Path to directory

{p 8 8 2}
{cmd:pathutil to} 
[{it:{help filename:directory}}]


{p 5 8 2}
Confirm directory

{p 8 8 2}
{cmd:pathutil} {cmd:confirm} [ {opt new} | {opt url} | {opt abs:olute} ] 
{cmd:"}{it:{help filename:path}}{cmd:"}


{title:Description}

{pstd}
{cmd:pathutil} is a bundle of utility commands for file 
path manipulation. The commands are inteded for use by 
programmers. All commands are implemented in terms of 
Mata's {helpb mf_pathjoin:path*()} functions.

{pstd}
{cmd:pathutil split} splits {it:path} into directory, filename and 
extension/suffix and returns elements in {cmd:s()}. If path has no 
directory, filename or file extension/suffix, the respective elements 
are omitted from {cmd:s()}.

{pstd}
{cmd:pathutil pieces} cuts {it:path} into pieces and returns the elements 
{cmd:s()}.

{pstd}
{cmd:pathutil join} forms {it:path1}{ccl dirsep}{it:path2} and returns it in 
{cmd:s()}.

{pstd}
{cmd:pathutil to} is a clone of {cmd:pathof} ({help path##ref:Barker 2014}), 
conceptually. It returns in {cmd:s()} the current working directory up to 
the specifed {it:directory} or the root of the current working directory, if 
{it:directory} is not specified.

{pstd}
{cmd:pathutil confirm} confirms that {it:path} is of the claimed type 
(see {helpb confirm}). Nothing is returned in {cmd:s()} and previous 
contents in {cmd:s()} are preserved. This command is similar to 
{help path##ref:Blanchette's (2011)} {cmd:confirmdir}. 


{title:Remarks}

{pstd}
Earlier versions of the command were released under the simpler name 
{cmd:path}; typing {cmd:path} instead of {cmd:pathutil} continues to
work until some day StataCorp decides to write their own {cmd:path} 
command. Thus, I recommend typing {cmd:pathutil}. 


{title:Example}

{phang2}
{cmd:. pathutil split "c:{ccl dirsep}ado{ccl dirsep}plus{ccl dirsep}path.ado"}
{p_end}
{phang2}
{cmd:. sreturn list}
{p_end}

{phang2}
{cmd:. pathutil pieces "c:{ccl dirsep}ado{ccl dirsep}plus{ccl dirsep}path.ado"}
{p_end}
{phang2}
{cmd:. sreturn list}
{p_end}

{phang2}
{cmd:. pathutil join "c:{ccl dirsep}ado" "plus{ccl dirsep}path.ado"}
{p_end}
{phang2}
{cmd:. sreturn list}
{p_end}

{phang2}
{cmd:. pathutil confirm "c:{ccl dirsep}ado"}
{p_end}


{title:Saved results}

{pstd}
{cmd:pathutil split} saves in {cmd:s()}

{pstd}
Macros{p_end}
{synoptset 21 tabbed}{...}
{synopt:{cmd:s(filename)}}{it:filename} 
(without extension/suffix){p_end}
{synopt:{cmd:s(extension)}}{it:extension} of {it:filename}
(same as {cmd:s(suffix)}){p_end}
{synopt:{cmd:s(suffix)}}{it:suffix} of {it:filename}
(same as {cmd:s(extension)}){p_end}
{synopt:{cmd:s(directory)}}{it:directory}{p_end}

{pstd}
{cmd:pathutil pieces} saves in {cmd:s()}

{pstd}
Macros{p_end}
{synoptset 21 tabbed}{...}
{synopt:{cmd:s(pieces)}}number of pieces ({cmd:0} if none){p_end}
{synopt:{cmd:s(piece{it:#})}}elements of {it:path}{p_end}

{pstd}
{cmd:pathutil join} saves in {cmd:s()}

{pstd}
Macros{p_end}
{synoptset 21 tabbed}{...}
{synopt:{cmd:s(path)}}{it:path1}{ccl dirsep}{it:path2}{p_end}

{pstd}
{cmd:pathutil of} saves in {cmd:s()}

{pstd}
Macros{p_end}
{synoptset 21 tabbed}{...}
{synopt:{cmd:s(path)}}{cmd:{ccl pwd}} (up to {it:directory}){p_end}

{pstd}
{cmd:pathutil confirm} saves nothing in {cmd:s()}

{marker ref}
{title:References}

{pstd}
Barker, M. (2014). {stata findit pathof:PATHOF}: Stata module 
to return the absolute path of any parent directory of the 
current working directory. {it:Statistical Software Components}.

{pstd}
Blanchette, D. (2011). {stata findit confirmdir:CONFIRMDIR}: 
Stata module to confirm if a directory exists. 
{it:Statistical Software Components}.


{title:Author}

{pstd}
Daniel Klein, INCHER-Kassel, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb mf_pathjoin:pathjoin()}, {helpb confirm}, 
{help _getfilename}
{p_end}

{psee}
if installed: {help pathof}, {help confirmdir}, 
{help getfilename2}, {help normalizepath}, {help extractfilename}
{p_end}

