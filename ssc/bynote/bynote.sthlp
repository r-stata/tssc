{smcl}
{hline}
help for {cmd:bynote}{right:(Roger Newson)}
{hline}

{title:Create a note with a user-specified format for use with the {help by_option:by option}}

{p 8 21 2}
{cmd:bynote} {varlist} [ , {opt pr:efix(string)} {opt se:parator(string)} {opt lse:parator(string)} {opt su:ffix(string)}
  {opt lo:cal(name)} ]


{title:Description}

{pstd}
{cmd:bynote} creates a note
for use as the {cmd:note()} suboption of the {help by_option:by-option} of the {helpb graph} command.
This note is made up of the {help label:variable labels} of the variables in the {varlist},
if these labels exist,
and of the names of these variables otherwise.
The user can specify a format for this note, and/or save it in a {help macro:local macro}.
The {help by_option:by-option} automatically sets the overall {cmd:note()} suboption
to a list of by-variable names and/or {help label:labels} by default,
but it does not always have the format that the user wanted,
and may not use all the {help label:variable labels}.


{title:Options}

{phang}
{opt prefix(string)} specifies a string to use as the prefix for the by-note.
If not set by the user, it is set by default to {hi:"Graphs by: "}.

{phang}
{opt separator(string)} specifies a string to use as the separator between successive variable labels (or names).
If not set by the user, it is set by default to {hi:", "}, implying comma separation.

{phang}
{opt lseparator(string)} specifies a special separator to separate the last variable label (or name)
from the immediate previous variable label (or name).
If not set by the user, it is set by default to the value of the {cmd:separator()} option.
The {cmd:lseparator()} option allows the user to specify notes such as
{hi:"Graphs by: Repair Record 1978, Car type and Trunk space (cu. ft.)"}
by specifying {cmd:lseparator(" and ")}.

{phang}
{opt suffix(string)} specifies a string to use as the suffix for the by-note.
For instance, the user may want the by-note to end with a full stop.
If not set by the user, it is set by default to the empty string {hi:""},
implying no suffix.

{phang}
{opt local(name)} specifies the name of a local macro in which the by-note is to be stored.


{title:Examples}

{p 8 12 2}{cmd:. bynote foreign rep78}{p_end}
{p 8 12 2}{cmd:. scatter mpg weight, by(foreign rep78, note("`r(bynote)'"))}{p_end}

{p 8 12 2}{cmd:. bynote foreign rep78 trunk}{p_end}

{p 8 12 2}{cmd:. bynote rep78 foreign trunk, prefix("Plots by ")}{p_end}

{p 8 12 2}{cmd:. bynote foreign rep78 trunk, se(" & ") pr("Plots by ") su(.)}{p_end}

{p 8 12 2}{cmd:. bynote foreign rep78 trunk, lo(locby)}{p_end}

{p 8 12 2}{cmd:. bynote rep78 foreign trunk, prefix("Graphs by ") lse(" and ")}{p_end}


{title:Saved results}

{pstd}
{cmd:bynote} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(bynote)}}by-note created by {cmd:bynote}
{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[G] {it:by_option}}
{p_end}
{p 4 13 2}
On-line: help for {it:{help by_option}}
{p_end}
