{smcl}
{cmd:help elabel define}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel define} {hline 2} Define and modify value labels


{title:Syntax}

{p 4 10 2}
Basic syntax

{p 8 12 2}
{cmd:elabel {ul:de}fine}
{it:{help elabel##elblnamelist:elblnamelist}}
{it:#} {cmd:"}{it:label}{cmd:"}
[ {it:#} {cmd:"}{it:label}{cmd:"} {it:...} ]
[ {cmd:,} {it:options} ]


{p 4 10 2}
Extended syntax

{p 8 12 2}
{cmd:elabel {ul:de}fine}
{it:{help elabel##elblnamelist:elblnamelist}}
{cmd:(}{it:{help elabel_define##valspec:valspec}}{cmd:)}
{cmd:(}{it:{help elabel_define##lblspec:lblspec}}{cmd:)}
[ {cmd:,} {it:options} ]

{p 8 12 2}
{cmd:elabel {ul:de}fine}
{it:{help elabel##elblnamelist:elblnamelist}}
{cmd:=}
{helpb elabel_define##fcn:{it:fcn}}{opt (arguments)}
[ {cmd:,} {it:options} ]


{p 4 8 2}
where, with few exceptions, {it:elblnamelist} may contain 
{help elabel##varvaluelabel:{it:varname}{bf::}{it:elblname}}

{marker valspec}{...}
{p 4 8 2}
{it:valspec} is one of
{{it:#}|{it:{help elabel_define##nlist:numlist}}}, or, 
{cmd:=}{it:{help elabel##elabel_eexp:eexp}}

{marker nlist}{...}
{p 10 8 2}
and {it:{help numlist}} may contain sequences of missing value codes 
such as {cmd:.a/.c}

{marker lblspec}{...}
{p 4 8 2}
{it:lblspec} is one of 
{cmd:"}{it:label}{cmd:"} [ {cmd:"}{it:label}{cmd:"} {it:...} ], or,
{cmd:=}{it:{help elabel##elabel_eexp:eexp}}

{marker fcn}{...}
{p 4 8 2}
{it:fcn}() is an 
{help elabel_functions##fcns:{bf:elabel} (pseudo-)function} and 
{it:arguments} are function specific


{title:Description}

{pstd}
{cmd:elabel define} defines new value labels or modifies existing value 
labels. 

{pstd}
The basic syntax mirrors that of {helpb label:label define}, except that 
more than one value label name may be specified. The extended syntax is 
described under {help elabel_define##remarks:Remarks}.


{marker remarks}{...}
{title:Remarks}

{pstd}
Remarks are presented under the following headings

{phang2}
{help elabel_define##newlbl:Define new value labels}
{p_end}
{phang2}
{help elabel_define##modify:Modify or replace existing value labels}
{p_end}
{phang2}
{help elabel_define##nonint:Noninteger values in {it:eexp}}
{p_end}
{phang2}
{help elabel_define##fcns:elabel (pseudo-)functions (third syntax)}
{p_end}
{phang2}
{help elabel_define##rules:Further extended syntax: recoding rules}
{p_end}


{marker newlbl}{...}
{pstd}
{bf:{ul:Define new value labels}}

{pstd}
If you define new value labels with the second syntax, specify as many 
labels in {it:lblspec} as there are values in {it:numlist}; the mapping 
of values to labels is one-to-one. If only one label is specified, this 
label is associated with all values in {it:numlist}; you typically do 
not want to map different values to the same label.

{pstd}
If you define new value labels with the second syntax, you may specify 
{it:eexp} only in one of {it:valspec} or {it:lblspec} but not in both. If 
{it:eexp} is specified in {it:valspec}, only the {cmd:@} character may be 
used; it refers to labels in {it:lblspec}. If {it:eexp} is specified in 
{it:lblspec}, only the {cmd:#} character may be used; it refers to the 
values in {it:valsepc}.

{marker modify}{...}
{pstd}
{bf:{ul:Modify or replace existing value labels}}

{pstd}
If you modify or replace existing value labels with the second syntax, 
specify as many labels in {it:lblspec} as there are values in {it:numlist}; 
the mapping of values to labels is one-to-one. If only one label is 
specified, this label is associated with all values in {it:numlist}; this 
is useful for deleting integer-to-text mappings from value labels.

{pstd}
If you modify or replace existing value labels with the second syntax, you 
may specify {it:eexp} in both {it:valspec} and {it:lblspec}. In both, 
{it:valspec} and {it:lblspec}, the {cmd:#} character refers to the values 
of the value labels in {it:elblnamelist} and the {cmd:@} character refers 
to the text of value labels in {it:elblnamelist}.

{pstd}
If you modify or replace existing value labels and specify {it:eexp}, 
you typically want to specify {it:eexp} in both {it:valspec} and 
{it:lblspec}. If existing value labels are modified or replaced and if 
{it:eexp} is specified in only one of {it:valspec} or {it:lblspec}, the 
meaning of the {cmd:#} character and {cmd:@} character might not be what 
you expect: In {it:valspec}, the {cmd:#} character refers to the values 
of the value labels in {it:elblnamelist} that are associated with the 
labels in {it:lblspec}; the {cmd:@} character refers to the labels in 
{it:lblspec}. Likewise, in {it:lblspec}, the {cmd:#} character refers to 
the values in {it:valspec}; the {cmd:@} character refers to the text of 
the value labels in {it:elblnamelist} that is associated with the values 
in {it:valspec}.

{marker nonint}{...}
{pstd}
{bf:{ul:Noninteger values}}

{pstd}
If {it:eexp} in {it:valspec} evaluates to noninteger values, these values 
are truncated; {it:eexp} may not evaluate to system missing.

{marker fcns}{...}
{pstd}
{bf:{ul:elabel (pseudo-)functions}}

{pstd}
With the third syntax, you specify an 
{help elabel_functions:{bf:elabel} (pseudo-)function} 
to define new or modify existing value labels. See 
{help elabel_functions##fcns:{bf:elabel} (pseudo-)functions} 
for a list of available (pseudo-)functions.

{marker rules}{...}
{pstd}
{bf:{ul:Further extended syntax: recoding rules}}

{pstd}
{cmd:elabel define} accepts recoding rules similar to those used 
with the {helpb recode} command for manipuating variables. If you 
are interested in using recoding rules for manipulating value labels, 
you probably want to use {helpb elabel_recode:elabel recode}.

{pstd}
The syntax for using recoding rules with {cmd:elabel define} is

{p 8 12 2}
{cmd:elabel {ul:de}fine}
{it:{help elabel##elblnamelist:elblnamelist}}
{cmd:(}{it:rule}{cmd:)}
[ {cmd:(}{it:rule}{cmd:)} {it:...} ]
{cmd:,} {{opt add}|{opt modify}|{opt replace}} [ {opt nofix} ]

{pstd}
where {it:rule} is explained in 
{helpb elabel_recode:elabel recode}. When you specify recoding rules 
with {cmd:elabel define}, you may modify or replace existing value 
labels but you cannot define new value labels.


{title:Options}

{phang}
{opt a:dd} is the same as with {help label##options:label define}, 
and adds integer to text mappings to a value label.

{phang}
{opt modify} is the same as with {help label##options:label define}, 
and modifies existing value labels.

{phang}
{opt replace} is the same as with {help label##options:label define}, 
and redefines value labels.

{pstd}
{opt nofix} is the same as with {help label##options:label define}.


{title:Examples}

{pstd}
Define value label {cmd:yesno}

{phang2}{stata elabel define yesno 0 "yes" 1 "no":. elabel define yesno 0 "yes" 1 "no"}{p_end}

{pstd}
Interchange the values in value label {cmd:yesno}

{phang2}{stata elabel define yesno (= 1-#) (= @) , modify:. elabel define yesno (= 1-#) (= @) , modify}{p_end}

{pstd}
Add labels for missing answers to value label {cmd:yesno}

{phang2}{stata elabel define yesno (.a/.c) ("don't know" "refused" "N/A") , add:. elabel define yesno (.a/.c) ("don't know" "refused" "N/A") , add}{p_end}


{title:Saved results}

{pstd}
{cmd:elabel define}, if {it:rules} are specified, saves the 
following in {cmd:r()}:

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(rules)}}transformation rules with all labels removed
{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help label}
{p_end}

{psee}
if installed: {help elabel}
{p_end}
