{smcl}
{* *! version 1.0.0, 14aug2012}{...}
{cmd:fastcc}
{hline}

{title:Title}

{phang}
{bf:fastcc -- ("fast copycode") run -copycode- with standard options}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:fastcc} [{it:projectname}] [{cmd:,} {cmd:{c -(}} {opt set:tings(set_arg[:set_value])} | {it:fastcc_options} {it:copycode_options} {cmd:{c )-}} ]

{synoptset 32 tabbed}{...}
{synopthdr:main_options}
{synoptline}
{syntab:    }
{synopt: {it:projectname}}Name of project to be processed{p_end}
{synopt: {opt set:tings(set_arg[:set_value])}}Record {cmd:fastcc} settings to ini file{p_end}
{synopt:}{p_end}
{synopthdr:fastcc_options}
{synoptline}
{synopt: {opt alld:epon(depfilename)}}Process all projects that use file {it:depfilename}{p_end}
{synopt: {opt v:erbose}}Show detailed {cmd:copycode} output instead of {cmd:fastcc}'s summary output{p_end}
{synopt:}{p_end}
{synopthdr:copycode_options}
{synoptline}
{synopt: {opt noc:opy}}See {help copycode}{p_end}
{synopt: {opt si:mplemode}}See {help copycode}{p_end}
{synopt: {opt force}}See {help copycode}{p_end}
{synopt: {opt st:arbang(stb_mode)}}See {help copycode}{p_end}
{synopt: {opt nop:rogdrop}}See {help copycode}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
You must be familiar with {help copycode} before you can understand what {cmd:fastcc} is doing.

{pstd}
{cmd:fastcc} has two main uses. First, it runs {help copycode} with standard options so you do not have to type them at the command line.

{pstd}
Secondly, {cmd:fastcc} can re-process all projects that depend on one particular file.
This is done by option {opt alldepon}.


{marker option}{...}
{title:Options}

{phang}
{cmd:projectname} will process project {it:projectname}.

{phang}
{cmd:settings({it:set_arg}[{it::set_value}])} displays and sets values recorded in {cmd:fastcc}'s ini file.
This option is exclusive: You may not use it in conjunction with any other option.

{pmore}
The values of the path to the input file and to the target directory of the target file are stored in the text file `c(sysdir_plus)'/f/fastcc.ini (the "ini file").
If you wish, you can open and modify this file directly.
Alternatively, issuing

{pmore}
{cmd:. fastcc, settings(inputfile: {it:inputfilepathandname})}{break}
{cmd:. fastcc, settings(targetdir: {it:targetdirpath})}

{pmore}
will record your settings in the ini file.
Each {it:set_arg} (inputfile or targetdir) must be followed by a colon and by a valid path to a file (inputfile) or directory (targetdir).
{cmd:fastcc} assumes an output file name of {it:projectname}.ado which it will append to {it:targetdirpath}.
Relative file paths are not allowed in the ini file.
Settings arguments may not exceed 244 characters.

{pmore}
In addition,

{pmore}
{cmd:. fastcc, settings(list)}

{pmore}
will list the current ini file entries.

{phang}
{cmd:alldepon(depfilename)} will process all projects that depend on file {it:depfilename}.
Note that {it:depfilename} must be supplied with extension since {cmd:fastcc} must be able to identify the file among .mata, .stp, .adv, etc. files.

{pmore}
The interaction of this option with option {opt simplemode} is of particular importance.
If you leave out option {opt simplemode}, {cmd:fastcc} runs through all projects in the input file and determines for each project whether the condition for ado mode are given (i.e. the project has a "main adv").
If so, it compiles a list of all first-order and higher-order dependencies; if {it:depfilename} is among them, it includes this project among the projects to be processed.
If the conditions for ado mode for a particular project are not met, {cmd:fastcc} checks only the direct dependencies for the occurence of {it:depfilename}.
If they inlcude {it:depfilename}, the project is added to the list of projects to be processed.

{pmore}
If you do use option {opt simplemode}, {cmd:fastcc} checks for each project only the direct dependencies for the occurence of {it:depfilename}.

{pmore}
If you use option {opt alldepon}, you cannot specify {it:projectname}.

{phang}
{cmd:verbose} will display detailed output from {cmd:copycode} instead of the summary output from {cmd:fastcc}.

{phang}
{cmd:nocopy}, {cmd:simplemode}, {cmd:force}, {cmd:starbang}, and {cmd:noprogdrop} fully correspond to {cmd:copycode} options and are passed to each {cmd:copycode} call made by {cmd:fastcc}.


{marker remarks}{...}
{title:Remarks}

{pstd}
You can use {cmd:fastcc} to work more efficiently with {help copycode}.
{cmd:fastcc} runs copycode with standard options.
These standard options are:

{p2colset 8 30 30 0}{...}
{p2col:{it:copycode option}}{it:{cmd:fastcc} equivalent}{p_end}
{p2line}
{p2col:inputfile}as recorded in {cmd:fastcc}'s ini file{p_end}
{p2col:targetfile}path join of target directory as recorded in {cmd:fastcc}'s ini file and the output file name, which is assumed to be the project name plus ado file extension{p_end}
{p2col:replace}is always assumed{p_end}

{pstd}
That way, a copycode statement like

{p 8 10 2}
{cmd: . copycode myproject, input(pathtoinput/input.txt)  target(pathtotarget/myproject.ado) replace}

{pstd}
conveniently collapses into

{pmore}
{cmd: . fastcc myproject}

{pstd}
If you are in the process of developing and testing an ado file and you are constantly making small changes and re-processing the project, this saves a good bit of typing.

{pstd}
The standard options are based on a set of assumptions that are typically true in practice:

{p2colset 5 10 12 0}{...}
{p2col:}- You are using only one input file that lists all of your projects.
Very rarely will you have several versions of an input file or several input files for different purposes.{p_end}
{p2col:}- The project names correspond to the names of the ado files you want to create.{p_end}
{p2col:}- You know what you are doing when executing {cmd:fastcc} and it is ok to overwrite existing ado files.{p_end}
{p2col:}- Your self-written ados reside in one directory (e.g. c:\ado\personal).{p_end}

{pstd}
The second main purpose of {cmd:fastcc} is related to the following problem:
Suppose you have made changes to a file called {it:depfilename} that goes into several of your projects.
You do not know, however, the list of projects that directly or indirectly depend on {it:depfilename}.
The statement

{pmore}
{cmd:. fastcc, alldepon(depfilename) nocopy}

{pstd}
will provide you with screen output on the list of projects in question.
This list will also be saved in {bf:r()}.

{pstd}
If you leave out option {opt nocopy} from the above statement, all of these projects will be re-processed.
That way, after making changes to one particular file you can quickly bring all of your ado projects to the latest stage of your code development.
After a succesful run of the certification scripts for the projects that have been re-processed (or, ideally, after running certification scripts on all your ado projects) you are all set.

{pstd}
{bf:{ul:  --- Warning ---}}{break}
There is no {opt replace} option in {cmd:fastcc}.
Unless option {it:nocopy} is supplied, {cmd:fastcc} will always create or {hi:overwrite} a file called {it:projectname}.ado.
Similarly, when using option {opt alldepon}, it will create or {hi:overwrite} files {it:projectname1}.ado, {it:projectname2}.ado, ..., where these file names correspond to the projects that have been processed.
Be sure that you know what you are doing when using {cmd:fastcc}.


{marker examples}{...}
{title:Examples}

{pstd}
Before you can use {cmd:fastcc} you first have to set the default input file path and the target directory for output files.
This requires running two statements (here: with bogus arguments)

{phang2}{cmd:. fastcc, settings(inputfile : c:\mypath\input.txt)}{p_end}
{phang2}{cmd:. fastcc, settings(targetdir : c:\mytargetdir)}{p_end}

{pstd}
Since they are stored in a file, these settings are kept in between Stata sessions and reboots.
If you want to change these settings you simply re-issue these commands using different arguments.
You can always query the current settings by

{phang2}{cmd:. fastcc, settings(list)}{p_end}

{pstd}
Continuing the examples from {help copycode}, the command

{phang2}{cmd:. fastcc proj_a}{p_end}

{pstd}
is identical to the {cmd:copycode} statement of the {help copycode##example_a:first copycode example}:

{phang2}{cmd:. copycode proj_a, inputfile(c:\mypath\input.txt) targetfile(c:\mytargetdir\proj_a.ado) replace}{p_end}

{pstd}
and will produce an identical outputfile.
Note the implied {opt replace} option by the usage of {cmd:fastcc}.

{pstd}
Applying option {opt alldepon},

{phang2}{cmd:. fastcc, alldepon(proj_a.adv)}{p_end}

{pstd}
is identical to the two {cmd:copycode} statements of the {help copycode##example_a:first copycode example} and the {help copycode##example_b:second copycode example}:

{phang2}{cmd:. copycode proj_a, inputfile(c:\mypath\input.txt) targetfile(c:\mytargetdir\proj_a.ado) replace}{p_end}
{phang2}{cmd:. copycode proj_b, inputfile(c:\mypath\input.txt) targetfile(c:\mytargetdir\proj_b.ado) replace}{p_end}

{pstd}
and will produce identical output files.
This is because both proj_a and proj_b depend on proj_a.adv.


{marker savedresults}{...}
{title:Saved results}

{pstd}
{cmd:fastcc} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 0: Macros}{p_end}
{synopt:}When supplying {it:projectname}, results saved will correspond exactly to the ones returned by {cmd:copycode}.{p_end}
{synopt:}{p_end}
{synopt:}When using option {opt alldepon}, saved results are instead:{p_end}
{synopt:{cmd:r(projectlist)}}List of projects that depend on {it:depfilename}.
Contains tokens from r(failed_make) but not from r(failed_check).{p_end}
{synopt:{cmd:r(failed_make)}}List of projects that could not be processed because errors occured{p_end}
{synopt:{cmd:r(failed_check)}}List of projects that could not be checked for dependencies because errors occured{p_end}
{p2colreset}{...}

{pstd}
All returned values are lower case, irrespective of what the actual casing of the files on disk or in the input file is.


{marker author}{...}
{title:Author}

{phang}
Daniel C. Schneider, Goethe University Frankfurt, schneider_daniel@hotmail.com


{marker references}{...}
{title:References}

{phang}
Schneider, D.C. (2012).
Modular Programming in Stata.
Presentation at the German Stata Users Group Meeting 2012, Berlin.
Available at {browse "http://www.stata.com/meeting/germany12/abstracts/desug12_schneider.pdf":http://www.stata.com/meeting/germany12/abstracts/desug12_schneider.pdf}.
