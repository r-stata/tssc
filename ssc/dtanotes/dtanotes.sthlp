{smcl}
{* *! version 1.0.1 Matthew White 09mar2015}{...}
{title:Title}

{phang}
{cmd:dtanotes} {hline 2} Add metadata as dataset notes


{marker syntax}{...}
{title:Syntax}

{phang}
Add {cmd:dtanotes} notes

{p 8 10 2}
{cmd:dtanotes,} {opt creator(string)} [{opt nogit}]


{phang}
Drop {cmd:dtanotes} notes

{p 8 10 2}
{cmd:dtanotes drop}


{marker description}{...}
{title:Description}

{pstd}
{cmd:dtanotes} adds useful metadata as dataset {help notes}:

{* Using -help anova- as a template.}{...}
{phang2}o  Creating do-file or process{p_end}
{phang2}o  Current date and time{p_end}
{phang2}o  Names of computer and user{p_end}
{phang2}o  {help datasignature:Data signature}{p_end}
{phang2}o  Git SHA-1 hash of the current commit{p_end}
{phang2}o  Git working tree status{p_end}
{phang2}o  Git uncommitted changes, including untracked files and
directories{p_end}

{pstd}
{cmd:dtanotes} also {help label:labels} the dataset with
{cmd:"See notes."} so that the notes are not overlooked.

{pstd}
{cmd:dtanotes drop} drops {cmd:dtanotes} notes.


{marker options_dtanotes}{...}
{title:Options for dtanotes}

{phang}
{opt creator(string)} is required and specifies the name of the do-file or
process that created the dataset.

{phang}
{opt nogit} specifies that {cmd:dtanotes} not add information about
a Git repository to notes.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:dtanotes} drops previous {cmd:dtanotes} notes before adding new ones.
It resets the data signature before adding it to notes.

{pstd}
Because {cmd:dtanotes} adds information about a Git repository to notes,
the SSC program {cmd:stgit} is required. The working directory should be set to
the repository that contains the code that created the dataset.
If the project does not use Git, specify option {opt nogit} when adding notes.

{pstd}
The GitHub repository for {cmd:dtanotes} is
{browse "https://github.com/PovertyAction/dtanotes":here}.


{marker author}{...}
{title:Author}

{pstd}Matthew White{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/dtanotes/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}


{title:Also see}

{psee}
Help:  {manhelp notes D}, {manhelp datasignature D}

{psee}
User-written:  {helpb stgit}
{p_end}
