{smcl}
{* 22oct2013}{...}
{cmd:help vmerge}{right:Version 1.0}
{hline}

{title:Title}

{p 4 11 2}
{hi:vmerge} {hline 2} Verbose merge: a wrapper for the Stata merge command that provides additional details regarding the results of the {it:update} and {it:replace} options.{p_end}


{marker syntax}{title:Syntax}

{p 8 27 2}
{cmdab:vmerge}
[{it:merge_specification}]
[{cmd:,} {it: merge_options} {it: verbose} {it: {ul on}conserve{ul off}memory} ]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt merge_options}} are options of {cmd:merge}. See help on {help merge}.{p_end}
{synopt:{opt verbose}} even more verbose output{p_end}
{synopt:{opt {ul on}conserve{ul off}memory}} alternate method that conserves memory but uses more disk and CPU.{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
This command provides a summary table that lists each variable in the master data set and indicates how many variables were affected by the 
{cmd: merge} {it:update} and {it:replace} options. This summary table only reflects observations that are in the master data set (_merge==1, 3, 4, and 5).

{pstd}
This command sends {it:merge_specification} and {it:merge_options} to the Stata {cmd:merge} command without modification, without comment, 
and without any assessment as to whether using the verbose merge makes sense. If the syntax is incorrect, the Stata {cmd:merge} command will let you know.

{pstd}
Warning: this command temporarily duplicates all variables in the master data set, thus requiring additional memory
equal to the size of the master data set. The {it:conservememory} option eliminates the need to use this
additional memory, but uses more disk space, takes longer, and results in more cryptic output.

{title:Options}

{phang}
{cmdab: verbose} For each variable in the master data set, gives a lists of observations where that variable was updated or replaced.

{phang}
{cmdab: conservememory} Performs the merge twice (with and without {it:update/replace}), compares the results using {cmd:cf}, and restores
the session to the desired condition after the requested {cmd:merge}. If the {it:verbose} option is specified it is passed to {cmd:cf}.

{title:Author}

{pstd}
Joseph Canner{break}
Johns Hopkins University School of Medicine{break}
Department of Surgery{break}
Center for Surgical Trials and Outcomes Research{break}

{pstd}
Email {browse mailto:jcanner1@jhmi.edu}



 

