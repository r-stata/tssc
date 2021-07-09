{smcl}
{hline}
help for {cmd:adostore} and {cmd:adorestore}{right:(Roger Newson)}
{hline}


{title:Store and restore the current ado-path}

{p 8 21 2}
{cmd:adostore} [ {it:global_macro_name} ] [ , {cmd:replace} ]

{p 8 21 2}
{cmd:adorestore} [ {it:global_macro_name} ]


{title:Description}

{pstd}
{cmd:adostore} stores the current {help adopath:ado-file path} to a {help macro:global macro},
which defaults to {cmd:S_ADOSTORE}.
{cmd:adorestore} restores a stored ado-path to the current {help adopath:ado-file path} from a {help macro:global macro},
which defaults to {cmd:S_ADOSTORE}.
These commands enable the user to practice safe ado-path management
by storing the current ado-path before temporarily modifying the ado-path,
and restoring the stored ado-path after using the modified ado-path.


{title:Options}

{phang}
{cmd:replace} specifies that any existing value in the global macro specified by the {it:global_macro_name}
will be overwritten.
If {cmd:replace} is not specified,
and the global macro specified by the {it:global_macro_name} is non-empty,
then {cmd:adostore} will fail.


{title:Remarks}

{pstd}
It is often a good idea to use the {helpb program:program drop _all} command
immediately before or after {cmd:adorestore}, {helpb adopath},
or any other command that modifies the ado-path. This is because,
if you have used one version of an ado-file on one ado-path,
and then change the ado-path in order to use another version of the same ado-file,
then the first version will still be in the memory.
The {helpb program:program drop _all} command will cause the old version to be removed from memory.
If this is done, and the ado-file is called again,
then the new version will be loaded from the new ado-path.

{pstd}
Note that {cmd:adorestore} will fail if asked to restore an ado-path
from an empty {help macro:global macro},
as this would result in an empty ado-path.
If this happened, then Stata would be able to do very little,
and the best course of action would probably be to exit Stata and to start Stata again.


{title:Examples}

{pstd}
The following example works if the current directory has a daughter directory {cmd:./myadofiles},
containing a Stata ado-file {cmd:hithere.ado},
and if no Stata ado-file {cmd:hithere.ado} exists on the existing ado-path.

{phang2}{cmd:. adopath}{p_end}
{phang2}{cmd:. adostore, replace}{p_end}
{phang2}{cmd:. program drop _all}{p_end}
{phang2}{cmd:. adopath + ./myadofiles}{p_end}
{phang2}{cmd:. hithere}{p_end}
{phang2}{cmd:. program drop _all}{p_end}
{phang2}{cmd:. adorestore}{p_end}
{phang2}{cmd:. adopath}{p_end}

{pstd}
The following example is like the previous example,
except that the existing ado-path is stored to a global macro {cmd:MYOLDPATH},
instead of being stored to the default global macro {cmd:S_ADOSTORE}.

{phang2}{cmd:. adopath}{p_end}
{phang2}{cmd:. adostore MYOLDPATH, replace}{p_end}
{phang2}{cmd:. program drop _all}{p_end}
{phang2}{cmd:. adopath + ./myadofiles}{p_end}
{phang2}{cmd:. hithere}{p_end}
{phang2}{cmd:. program drop _all}{p_end}
{phang2}{cmd:. adorestore MYOLDPATH}{p_end}
{phang2}{cmd:. adopath}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
Manual: {hi:[P] sysdir}
{p_end}
{p 4 13 2}
Online: help for {helpb adopath}, {helpb sysdir}
{p_end}
