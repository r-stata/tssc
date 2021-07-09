{smcl}
{* Januar 6, 2011 @ 16:14:42 UK}{...}
{hi:help msq2ftsq} 
{hline}

{title:Title}

{phang}
{cmd:msq2ftsq} Square measure conversion
{p_end}

{title:Syntax}
{p 8 17 2}
   {cmd: msq2ftsq}
   [ #[{it}unit{sf}] [, {cmdab:u:nit(}{it}unit{sf})]
{p_end}

{pstd}{it}#{sf} is a number and {it}unit{sf} is a square measure.{p_end}

{title:Description}

{pstd} {cmd:msq2ftsq} converts square measures such as acre or are given
in one metric unit into various other metric units. The program is
focused on converting square meters to square feets but it also provides
conversion from/to the following other units:{p_end}

{p2colset 5 12 12 12}
{p2col:Unit}Explanation{p_end}
{p2line}
{p2col:{cmd:msq}}square meter{p_end}
{p2col:{cmd:a}}are; ar{p_end}
{p2col:{cmd:ha}}hectar{p_end}
{p2col:{cmd:kmsq}}square kilometer{p_end}
{p2col:{cmd:ftsq}}square feet{p_end}
{p2col:{cmd:ydsq}}square yard{p_end}
{p2col:{cmd:acre}}acre{p_end}
{p2col:{cmd:misq}}square mile{p_end}
{p2line}
{p2colset 5 12 5 12}

{pstd} {cmd:msq2ftsq} converts the numbers given by the user into all
the square measures mentiond above. If no unit is given, square meter
is implied. The metric unit of the number can be specified with the
number, or with option {opt unit()}, or both.{p_end}

{title:Options}

{phang}{opt unit(unit)} is used to specify the metric unit of the
numbers provided. As unit, any of msq, a, h, ftsq, ydsq, acre, and
misq are allowed. Note that the metric unit can be also appended
directly to the numbers. However, if more than one number is
specified, option {opt unit()} might be easier to use. Note also that
any metric unit specified for one specific number overwrites the
unit-option for that number.{p_end}

{title:Example(s)}

{phang}{cmd:. msq2ftsq}{p_end}
{phang}{cmd:. msq2ftsq 4}{p_end}
{phang}{cmd:. msq2ftsq 4a 5ha 6ftsq 7ydsq 8acre 9misq}{p_end}
{phang}{cmd:. msq2ftsq 1 4 9 12 100, u(acre)}{p_end}

{title:Author}

Ulrich Kohler
{browse "mailto:kohler@wzb.eu"}

{title:Acknowledgement}

{phang}I am grateful to Kit Baum for reporting a bug and making
helpful suggestions.{p_end}

{title:Also see}

{psee}
Online: help for {help cm2in}, {help g2oz} (if installed)
{p_end}

{psee}
Web:   {browse "http://stata.com":Stata's Home}
{p_end}
