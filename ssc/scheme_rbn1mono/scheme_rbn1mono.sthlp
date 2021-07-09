{smcl}
{* 17apr2003}{...}
{hline}
help for {cmd:scheme_rbn1mono}, {cmd:scheme_rbn2mono}, {cmd:scheme_rbn3mono} and {cmd:scheme_rbn4mono}{right:(Roger Newson)}
{hline}

{* index schemes}{...}
{title:Scheme description:  rbn1mono, rbn2mono, rbn3mono and rbn4mono}

{p 4 4 2}
The {cmd:rbn1mono} schemes are

	{it:schemename}{col 22}foreground{col 34}background{col 46}description
	{hline 70}
{col 9}{cmd:rbn1mono}{...}
{col 22}monochrome{...}
{col 36}white{...}
{col 46}black on white with thick lines
{col 9}{cmd:rbn2mono}{...}
{col 22}monochrome{...}
{col 36}white{...}
{col 46}black on white with thick lines,
{col 46}without scaling for {help by_option:by graphs},
{col 46}{help graph combine} and {help graph matrix}
{col 9}{cmd:rbn3mono}{...}
{col 22}monochrome{...}
{col 36}white{...}
{col 46}black on white with thin lines
{col 9}{cmd:rbn4mono}{...}
{col 22}monochrome{...}
{col 36}white{...}
{col 46}black on white with thin lines,
{col 46}without scaling for {help by_option:by graphs},
{col 46}{help graph combine} and {help graph matrix}
	{hline 70}

{p 4 4 2}
For instance, you might type

{p 8 16 2}
{cmd:. graph}
...{cmd:,}
...
{cmd:scheme(rbn1mono)}

{p 8 16 2}
{cmd:. set}
{cmd:scheme}
{cmd:rbn2mono}
[{cmd:,}
{cmdab:perm:anently}
]

{p 4 4 2}
See help {help scheme_option} and help {help set_scheme}.


{title:Description}

{p 4 4 2}
Schemes determine the overall look of a graph; see help for {help schemes}.

{p 4 4 2}
{cmd:rbn1mono} is Roger Newson's original personal default scheme.
It specifies a minimal and photocopier-friendly black-and-white look,
with gray background lines and minimal gray shading.
It is slightly more minimal and photocopier-friendly than
{help scheme_s1mono:s1mono} (which is its mother scheme), and slightly less minimal and photocopier-friendly than
{help scheme_lean:Svend Juul's lean schemes} (which can be downloaded in their latest form using
the {help findit} command).
The plot area is framed as in the schemes {help scheme_s1color:s1color} and {help scheme_s1mono:s1mono}.
The axis labels use value labels if these exist,
and are perpendicular to the corresponding axis,
so that they occupy a smaller and more predictable amount of axis space,
instead of a larger and less predictable amount of axis space.
The default {help by_option:by-graph style} is {cmd:compact}, to avoid wasting space.
The default number of columns in a {help legend_option:legend} is 1, to enable long and explicit labels.
The default spanning of titles is the whole graph region, not just the plot region.
Labels are right-justified.
The default size of most text,
including titles, subtitles, notes and labels,
is 3 percent of the minor axis dimension.
The default width of most lines,
including plot lines, grid lines and added {it:X}-axis and {it:Y}-axis lines,
is 0.375 percent of the minor axis dimension.
The default {help clockposstyle:clock position} of marker labels is 3.
Any of these defaults can be overridden by the user.

{p 4 4 2}
{cmd:rbn2mono} is Roger Newson's second personal default scheme.
It is an alternative version of {cmd:rbn1mono}, without the default scaling of
{help textsizestyle:text sizes}, {help markersizestyle:marker sizes} and {help linewidthstyle:line widths}
used for {help by_option:by graphs}, {help graph combine} and {help graph matrix}.
If the scheme {cmd:rbn2mono} is used, then these
{help textsizestyle:text sizes}, {help markersizestyle:marker sizes} and {help linewidthstyle:line widths}
are the same, whether or not the user uses
{help by_option:by graphs}, {help graph combine} and {help graph matrix}.
The scheme {cmd:rbn1mono} inherits the scaling regime of {help scheme_s1mono:s1mono}
when {help by_option:by graphs}, {help graph combine} and/or {help graph matrix} are used.
This policy involves some complicated formulas,
which may make it less easy for the user to estimate the correct
{help relativesize:relative size suboptions} to specify.
For technical details of these formulas, see help for
{help scheme by scaling:scaling for by graphs, graph combine, and graph matrix}.

{p 4 4 2}
{cmd:rbn3mono} is Roger Newson's third personal default scheme.
It is like {cmd:rbn1mono}, except that the default width of most lines,
including plot lines, grid lines and added {it:X}-axis and {it:Y}-axis lines,
is 0.25 percent of the minor axis dimension.

{p 4 4 2}
{cmd:rbn4mono} is Roger Newson's fourth personal default scheme.
It is like {cmd:rbn2mono}, except that the default width of most lines,
including plot lines, grid lines and added {it:X}-axis and {it:Y}-axis lines,
is 0.25 percent of the minor axis dimension.

{p 4 4 2}
The default line width of 0.375 percent of the minor dimension,
used by {cmd:rbn1mono} and {cmd:rbn2mono},
was chosen to produce graphics for photocopying, and also for overhead projections,
which should be visible to members of the audience with poor eyesight at the back of the hall.
The default line width of 0.25 percent of the minor dimension,
used by {cmd:rbn3mono} and {cmd:rbn4mono},
is aimed to produce Figures for submission to medical periodicals,
whose instructions to authors typically specify a preference for finer lines.
This is probably because most readers nowadays view them online,
and can choose their own magnification.


{title:Author}

{p 4 4 2}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind:}Manual:  {hi:[G] schemes}, {hi:[G] {it:scheme_option}}, {hi:[G] set scheme}

{p 4 13 2}
Online:  help for {help schemes}, {it:{help scheme_option}}, {help set_scheme}, {help scheme_s1mono}, {help scheme_entries}
{break} help for {help scheme_lean} if installed
{p_end}
