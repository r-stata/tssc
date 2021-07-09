{smcl}
{* *! version 0.1, 02oct2014}{...}
{vieweralsosee "[R] assert" "help assert"}{...}
{vieweralsosee "[R] capture" "help capture"}{...}
{viewerjumpto "Syntax" "capass##syntax"}{...}
{viewerjumpto "Description" "capass##description"}{...}
{viewerjumpto "Options" "capass##options"}{...}
{viewerjumpto "Example" "capass##example"}{...}
{viewerjumpto "Author" "capass##author"}{...}
{viewerjumpto "License" "capass##license"}{...}
{title:Title}

{phang}
{bf:capass} {hline 2} Extends {bf:{help assert}} by throwing error messages


{marker syntax}{title:Syntax}

{p 8 17 2}
{cmd:capass}
{it:{help exp}} {ifin}
[{cmd:,} {cmdab:r:c0} {cmdab:n:ull} {cmdab:f:ast} {cmdab:t:hrow}({it:string})]

{pstd}
{cmd:by} is allowed; see {help by}


{marker description}{...}
{title:Description}

{pstd}
{opt capass} is a simple wrapper for Stata's built-in {bf:{help assert}} command
that allows to throw error messages if the assertion evaluates to false. This is
especially useful if the assertion is hidden in quietly executed parts of the
code or in preserved mode.


{marker options}{...}
{title:Options}

{phang}
{opt t:hrow} specifies the error message to be shown if the assertion evaluates
to false.


{pstd}
The remaining options are just like {bf:{help assert}}'s options, so here is
what the built-in Stata Help has to say about their use:

{phang}
{opt r:c0} forces a return code of 0, even if the assertion is false.

{phang}
{opt n:ull} forces a return code of 8 on null assertions.

{phang}
{opt f:ast} forces the command to exit at the first occurrence that
{it:{help exp}} evaluates to false.


{marker example}{...}
{title:Example}

{pstd}
Instead of typing

{phang2}. {stata assert 1 + 1 == 3}{p_end}
{phang2}assertion is false{p_end}
{phang2}r(9);{p_end}

{pstd}
and wondering what the assertion was actually about, just type

{phang2}. {stata capass 1 + 1 == 3, throw("1 + 1 = 2. You should know this from elementary school...")}{p_end}
{phang2}1 + 1 = 2. You should know this from elementary school...{p_end}
{phang2}assertion is false{p_end}
{phang2}r(9);{p_end}

{pstd}
That's it.


{marker author}{...}
{title:Author}

{pstd}
{cmd:capass} was written by Max Löffler ({browse "mailto:loeffler@zew.de":loeffler@zew.de}),
Centre for European Economic Research (ZEW), Mannheim, Germany. Comments and
suggestions are welcome.

{pstd}
This command is no rocket science at all, so all credit goes to StataCorp for
their highly useful {bf:{help assert}} command. Thanks to Sebastian Siegloch
for inspiration.


{marker license}{...}
{title:License}

{pstd}
Copyright (C) 2014, {browse "mailto:loeffler@zew.de":Max Löffler}

{pstd}
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

{pstd}
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

{pstd}
You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

