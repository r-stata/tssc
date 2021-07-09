{smcl}
{hline}
help for {cmd:jformat} {right:(Roger Newson)}
{hline}


{title:Justify formats for a list of variables}

{p 8 15}{cmd:jformat} [ {varlist} ] [ {cmd:,} {opt j:ustify(justification)} ]

{pstd}
where {it:justification} is one of

{pstd}
{opt l:eft} | {opt r:ight} | {opt c:entre}


{title:Description}

{pstd}
{cmd:jformat} changes the {help format:display formats} of a list of variables
to be left-justified, right-justified or centre-justified.
Other features of the formats (such as the format width) are preserved.


{title:Options}

{p 4 8 2}
{opt j:ustify(justification)} specifies whether the formats of the {varlist}
will be changed to be left-justified, right-justified or centre-justified.
If the {cmd:justify()} option is absent,
then {cmd:jformat} assumes {cmd:justify(left)},
and the formats are changeed to be left-justified.


{title:Remarks}

{pstd}
At the time of writing, Stata only allows centre-justified formats for string variables.
And, even then, they are ignored and treated as right-justified by most Stata commands,
with the exception of the {helpb display} command.
However, the option {cmd:justify(centre)} was added in case Stata policy changes,
or in case users write packages which do not ignore centre-justified formats.


{title:Examples}

{pstd}
Set-up:

{p 16 20}{cmd:. sysuse auto, clear}{p_end}
{p 16 20}{cmd:. describe, full}{p_end}
{p 16 20}{cmd:. list in 1/20, abbr(32)}{p_end}

{pstd}
Left-justify formats for all variables:

{p 16 20}{cmd:. jformat}{p_end}
{p 16 20}{cmd:. describe, full}{p_end}
{p 16 20}{cmd:. list in 1/20, abbr(32)}{p_end}


{pstd}
Right-justify format for the variable {cmd:make}:

{p 16 20}{cmd:. jformat make, j(r)}{p_end}
{p 16 20}{cmd:. describe make, full}{p_end}
{p 16 20}{cmd:. list make in 1/20, abbr(32)}{p_end}


{pstd}
Right-justify format for the variables {cmd:price} and {cmd:trunk}:

{p 16 20}{cmd:. jformat price trunk, j(r)}{p_end}
{p 16 20}{cmd:. describe price trunk, full}{p_end}
{p 16 20}{cmd:. list price trunk in 1/20, abbr(32)}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {cmd:[D] formar}, {cmd:[D] describe}
{p_end}
{p 4 13 2}
On-line: help for {helpb format}, {helpb describe}
{p_end}
