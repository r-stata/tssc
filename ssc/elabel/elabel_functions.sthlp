{smcl}
{cmd:help elabel functions}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel functions} {hline 2} {cmd:elabel} (pseudo-)functions


{title:Syntax}

{p 8 12 2}
{cmd:elabel} {cmdab:var:iable}
{varlist}
{cmd:= {it:fcn}}{opt (arguments)} 
[ {it:{help elabel_functions##iff:iff}} ]
[ {cmd:,} {it:options} ]

{p 8 12 2}
{cmd:elabel} {cmdab:de:fine}
{it:{help elabel##elblnamelist:elblnamelist}}
{cmd:= {it:fcn}}{opt (arguments)} 
[ {it:{help elabel_functions##iff:iff}} ]
[ {cmd:,} {{opt a:dd}|{opt modify}|{opt replace}} {opt nofix} 
{it:options} ]


{p 4 10 2}
where depending on {cmd:{it:fcn}}, {it:arguments} is usually

{p 10 10 2}
{ {varlist} | {it:{help elabel##elblnamelist:elblnamelist}} }

{marker iff}{...}
{p 4 10 2}
{it:iff} is typically {helpb elabel}'s {helpb elabel##iffeexp:iff {it:eexp}} 
but, depending on {cmd:{it:fcn}}, might be Stata's {ifin} qualifiers

{p 4 10 2}
options {opt add}, {opt modify}, {opt replace}, and {opt nofix} 
are those of {helpb elabel_define:elabel define}, and {it:options} 
are {cmd:{it:fcn}}-specific

{p 4 10 2}
{cmd:{it:fcn}} is one of

{marker fcnsvar}{...}
{dlgtab:variable labels}

{p 10 10 2}
{cmd:copy(}{varname}{cmd:)}
{p_end}
{p 14 14 2}
copies the variable label of {it:varname} and attaches it to 
the variables in {it:varlist}.

{p 10 10 2}
{helpb elabel_programming##addfcn:{it:newfcn}()}
{p_end}
{p 14 14 2}
user-supplied {cmd:{it:fcn}}
{p_end}

{marker fcns}{...}
{dlgtab:value labels}

{p 10 10 2}
{cmd:combine(}{it:{help elabel##elblnamelist:elblnamelist}}{cmd:)}
[ {helpb elabel##iffeexp:iff {it:eexp}} ]
[ {cmd:, update} {opt sep:arator(char)} ]
{p_end}
{p 14 14 2}
combines the integer-to-text mappings in {it:elblnamelist} into one 
set of value labels. Integer-to-text mappings are defined according 
to the order of {it:elblnamelist}. Earlier integer-to-text mappings 
are not overwritten by integer-to-text mappings from value labels 
mentioned later.
{p_end}

{p 14 14 2}
Option {opt update} reverses the default behavior and keeps 
integer-to-text mappings from value labels mentioned later.

{p 14 14 2}
{opt separator(char)} combines labels that are associated with the 
same integer values, using {it:char} as a separator.

{p 10 10 2}
{cmd:copy(}{it:{help elabel##elblnamelist:elblname}}{cmd:)}
[ {helpb elabel##iffeexp:iff {it:eexp}} ]
{p_end}
{p 14 14 2}
copies integer-to-text mappings from {it:elblname}. This is 
a convenience function for making multiple copies of a given 
value label.

{p 10 10 2}
{cmd:levels(}[ {it:{help varlist:numvar}} ] 
{it:{help varlist:strvar}}{cmd:)} {ifin}
[ {cmd:,} {opt uniq} {opt force} ]
{p_end}
{p 14 14 2}
defines value labels from variables, associating the (integer) values 
in {it:numvar} with the text (labels) in {it:strvar}. If {it:numvar} 
is omitted, the sequence 1, 2, ... is used as values. The optional 
{helpb if} and {helpb in} are Stata's qualifiers, which accept Stata 
{help exp:expressions} and usually refer to observations in the 
dataset. 
{p_end}

{p 14 14 2}
Option {opt uniq} is only allowed if {it:numvar} is not specified and 
selects the distinct values (text/labels) of {it:strvar}; the resulting 
labels are unique.
{p_end}

{p 14 14 2}
{opt force} allows the same values in {it:numvar} to 
be associated with different text (labels) in {it:strvar} and keeps 
the last observed integer-to-text mapping.
{p_end}

{p 10 10 2}
{helpb elabel_programming##addfcn:{it:newfcn}()}
{p_end}
{p 14 14 2}
user-supplied {cmd:{it:fcn}}
{p_end}


{title:Description}

{pstd}
{cmd:elabel} (pseudo-)functions are used with  
{helpb elabel_variable:elabel variable} or
{helpb elabel_define:elabel define}; used with the former, 
functions manipulate variable labels; used with the latter, 
functions define new or modify existing value labels.

{pstd}
If you are interested in writing your own {cmd:elabel} (pseudo-)functions, 
read {help elabel_programming##addfcn:Adding (pseudo-)functions to elabel}.


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help label}, {help egen}
{p_end}

{psee}
if installed: {help elabel}
{p_end}
