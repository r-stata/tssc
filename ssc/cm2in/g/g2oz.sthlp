{smcl}
{* Januar 6, 2011 @ 16:13:33 UK}{...}
{hi:help g2oz} 
{hline}

{title:Title}

{phang}
{cmd:msq2ftsq} Conversion between ounce <-> gramm (and others)
{p_end}

{title:Syntax}
{p 8 17 2}
   {cmd: g2oz}
   [ #[{it}unit{sf}] [, {cmdab:u:nit(}{it}unit{sf})]
{p_end}

{pstd}{it}#{sf} is a number and {it}unit{sf} is a unit for mass.{p_end}

{title:Description}

{pstd} {cmd:g2oz} converts standare measures of mass such as ounces
or pounds given in one unit into various other units. The program is
focused on converting gramms to ounces but it also provides conversion
from/to the following other units:{p_end}

{p2colset 5 12 12 12}
{p2col:Unit}Explanation{p_end}
{p2line}
{p2col:{cmd:g}}gramm{p_end}
{p2col:{cmd:kg}}kilogramm{p_end}
{p2col:{cmd:oz}}ounce{p_end}
{p2col:{cmd:lb}}pound{p_end}
{p2col:{cmd:st}}stone{p_end}
{p2col:{cmd:tnl}}long ton (GB){p_end}
{p2col:{cmd:tnsh}}short ton (US){p_end}
{p2col:{cmd:gr}}grain{p_end}
{p2line}
{p2colset 5 12 5 12}

{pstd} {cmd:g2oz} converts the numbers given by the user into all the
measures mentiond above. If no unit is given, gramm is implied. The
unit of the number can be specified with the number, or with
the option {opt unit()}, or with both.{p_end}

{title:Options}

{phang}{opt unit(unit)} is used to specify the unit of the numbers
provided. As unit, any of g, kg, oz, lb, st, tnl, tnsh and gr are
allowed. Note carefully that {it:gr} stands for "grain", a measure
commonly used for masses of bullets, gunpowder, and smokeless
powder. The symbol for gramm is {it:g}.

{pmore}The unit(s) can be appended directly to the specified
number(s). If more than one number is specified, option {opt unit()}
might be easier to use. Note that any unit specified for one specific
number overwrites the unit-option for that number.{p_end}

{title:Example(s)}

{phang}{cmd:. g2oz}{p_end}
{phang}{cmd:. g2oz 4}{p_end}
{phang}{cmd:. g2oz 1g 2kg 3oz 4lb 5st 6tnl 7tnsh 8gr}{p_end}
{phang}{cmd:. g2oz 1 4 9 12 100, u(lb)}{p_end}

{title:Author}

Ulrich Kohler
{browse "mailto:kohler@wzb.eu"}

{title:Acknowledgement}

{phang}I am grateful to Kit Baum for reporting a bug and making
helpful suggestions.{p_end}

{title:Also see}

{psee}
Online: help for {help cm2in}, {help msq2ftsq} (if installed)
{p_end}

{psee}
Web:   {browse "http://stata.com":Stata's Home}
{p_end}


