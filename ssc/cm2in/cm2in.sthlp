{smcl}
{* Januar 6, 2011 @ 16:16:47 UK}{...}
{hi:help cm2in} 
{hline}

{title:Title}

{phang}
{cmd:cm2in} Conversion between inch/cm (and others)
{p_end}

{title:Syntax}
{p 8 17 2}
   {cmd: cm2in}
   [ #[{it}unit{sf}] | {it}keyword{sf} ] [, {cmdab:u:nit(}{it}unit{sf})]
{p_end}

{pstd} In the syntax diagram, {it}#{sf} is a number, {it}unit{sf} is
unit of length, and {it}keyword{sf} is a keyword for a standard paper
format.{p_end}

{title:Description}

{pstd} {cmd:cm2in} converts length or lists of length given in one
metric unit into various other metric units. The program is focused on
converting centimeters to inches but it also provides conversion
from/to the following other units:{p_end}

{p2colset 5 12 12 12}
{p2col:Unit}Explanation{p_end}
{p2line}
{p2col:{cmd:cm}}centimeter{p_end}
{p2col:{cmd:m}}meter{p_end}
{p2col:{cmd:in}}international inch{p_end}
{p2col:{cmd:ft}}international feet{p_end}
{p2col:{cmd:yd}}international yard{p_end}
{p2col:{cmd:ch}}chain{p_end}
{p2col:{cmd:mi}}statute mile{p_end}
{p2col:{cmd:pt}}desktop publishing point (PostScript point){p_end}
{p2col:{cmd:pica}}computer pica{p_end}
{p2line}
{p2colset 5 12 5 12}

{pstd} {cmd:cm2in} allows as input numbers or keywords for some
standard paper format. If a number is specified the number is
converted to all the metric units mentioned above. If no unit is
given, cm is implied. The metric unit of the number can be specified
with the number, or with option {opt unit()}, or both.{p_end}

{pstd} {cmd:cm2in} allows as input the specification of keywords
for some standard paper formats. If a keyword is specified, the
program shows the height and width of the specified paper format in
the various metric units. The paper format is requested by any of the
following keywords:{p_end}

{p2colset 5 23 23 23}
{p2col:Keyword}Explanation{p_end}
{p2line}
{p2col:American paper formats}{p_end}
{p2col:{cmd:letter}}Letter format{p_end}
{p2col:{cmd:legal}}Legal format{p_end}
{p2col:{cmd:executive}}Executive format{p_end}
{p2col:{cmd:tabloid}}Tabloid format (Synonym: {cmd:ledger}){p_end}
{p2col:{cmd:broadsheet}}Broadsheet format{p_end}

{p2col:German paper formats (aka ISO 216)}{p_end}
{p2col:{cmd:A0}, {cmd:A1}, ..., {cmd:A10}}German DIN A formats{p_end}
{p2col:{cmd:B0}, {cmd:B1}, ..., {cmd:B10}}German DIN B formats{p_end}
{p2col:{cmd:C0}, {cmd:C1}, ..., {cmd:C10}}German DIN C formats{p_end}
{p2col:{cmd:D0}, {cmd:D1}, ..., {cmd:D10}}German DIN D formats{p_end}

{p2col:Special formats}{p_end}
{p2col:{cmd:Graph}}Size of active graph scheme{p_end}
{p2line}

{pstd} The keyword specification of {cmd:cm2in} can be useful for
controlling the size of a graph using the options {opt xsize()} and
{opt ysize()}. Here, for example we use the command to get a figure in
A4 format:{p_end}

{p 8 8 0}{cmd:. sysuse auto}{p_end}
{p 8 8 0}{cmd:. cm2in A4}{p_end}
{p 8 8 0}{cmd:. graph dot mpg, over(make) ysize(`r(in1)') xsize(`r(in2)')} {p_end}

{pstd} Specifying the command without a paper format or a number
defaults to converting 1cm into the other metric units.{p_end}


{title:Options}

{phang}{opt unit(unit)} is used to specify the metric unit of the
numbers provided. As unit, any of cm, m, in, ft, yd, ch, mi, pt, and pica
are allowed. Note that the metric unit can be also appended directly
to the numbers. However, if more than one number is specified, option
{opt unit()} might be easier to use. Note also that any metric unit
specified for one specific number overwrites the unit-option for that
number.{p_end}

{title:Notes}

{pstd} The German system of paper sizes was introduced 1922 as a DIN
standard by Johann Beckmann, who followed earlier ideas of the German
scientist Georg Christoph Lichtenberg (1798). It has been adopted as
the standard paper format by the International Standardization
Organization in 1982 (IS0 128) and is today used in most countries of
the world {c -} the U.S., Canada and Mexico being notable exceptions.
{p_end}

{pstd}The advantage of the German system is that the paper has an
aspect ratio of sqrt(2). Dividing a paper with an aspect ratio of
sqrt(2) into two equal halves parallel to its shortest sides always
retains the aspect ratio of sqrt(2). This has some highly desirable
consequences for modern offices: Folded brochures of any size can be
made by using sheets of the next larger size, e.g. A4 sheets are
folded to make A5 brochures. The system allows scaling without
compromising the aspect ratio from one size to another - as provided
by office photocopiers, e.g. enlarging A4 to A3 or reducing A3 to
A4. Similarly, two sheets of A4 can be scaled down and fit exactly 1
sheet without any cutoff or margins
({browse "http://en.wikipedia.org/wiki/ISO_216":Wikipedia}). {p_end}

{title:Example(s)}

{phang}{cmd:. cm2in}{p_end}
{phang}{cmd:. cm2in 4}{p_end}
{phang}{cmd:. cm2in 4cm 7pica 8in}{p_end}
{phang}{cmd:. cm2in 1 4 9 12 100, u(pt)}{p_end}
{phang}{cmd:. cm2in letter}{p_end}
{phang}{cmd:. cm2in A6}{p_end}

{phang}{cmd:. sysuse auto}{p_end}
{phang}{cmd:. scatter price mpg}{p_end}
{phang}{cmd:. cm2in Graph}{p_end}

{title:Author}

Ulrich Kohler
{browse "mailto:kohler@wzb.eu"}

{title:Acknowledgement}

{phang}I am grateful to Kit Baum for reporting a bug and making
helpful suggestions.{p_end}

{title:Also see}

{psee}
Online: help for {help msq2ftsq}, {help g2oz} (if installed)
{p_end}

