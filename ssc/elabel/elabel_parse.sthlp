{smcl}
{cmd:help elabel parse}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel parse} {hline 2} Parse {cmd:elabel} syntax


{title:Syntax}

{p 4 10 2}
Old syntax (continues to work)

{p 8 12 2}
{cmd:elabel parse} 
[ {it:description_of_string} ] 
{cmd::} [ {it:string_to_parse} ]


{p 4 10 2}
Modern syntax (requires Stata 16 or higher)

{p 8 12 2}
{cmd:elabel parse} 
[ {it:description_of_string} ]



{p 4 10 2}
where {it:description_of_string} may contain the elements

{p 10 10 2}
{
{helpb elabel_parse##elblnamelist:{ul:elbl}namelist}{...}
{helpb elabel_parse##newlblnamelist:{ul:newlbl}namelist}{...}
|{...}
{helpb elabel_parse##anything:anything}
}{...}
{helpb elabel_parse##mappings:{ul:map}pings}{...}
{helpb elabel_parse##iffeexp:iff}{...}
{helpb elabel_parse##using:using}{...}
{helpb elabel_parse##options:, {it:options}}

{p 4 10 2}
and any element may be enclosed in square brackets.

{p 4 10 2}
{it:string_to_parse} contains the elements described in {help elabel}

{p 10 10 2}
{it:{help elabel##elblnamelist:elblnamelist}}{...}
{it:{help elabel##mappings:mappings}}{...}
{help elabel##iffeexp:{bf:iff}} 
{it:{help elabel##elabel_eexp:eexp}}{...}
{helpb using} {it:{help filename}}
{cmd:,} {it:options}

{p 4 10 2}
and typical usage of {cmd:elabel parse} is

{p 10 12 2}
{cmd:program elabel_cmd_mycommand}
{p_end}
{p 14 16 2}
{cmd:version 11.2}
{p_end}
{p 14 16 2}
{cmd:elabel parse elblnamelist [ mappings ] [ iff ] [ , OPname ] : `0'}
{p_end}
{p 14 16 2}
{it:code referring to} {cmd:`lblnamelist'}
{p_end}
{p 14 16 2}
{it:code referring to} {cmd:`mappings'}
{p_end}
{p 14 16 2}
{it:code referring to} {cmd:`iff'}
{p_end}
{p 14 16 2}
{it:code referring to} {cmd:`opname'}
{p_end}
{p 14 16 2}
{it:...}
{p_end}
{p 10 12 2}
{cmd:end}

{p 4 10 2}
or, with Stata 16 or higher

{p 10 12 2}
{cmd:program elabel_cmd_mycommand}
{p_end}
{p 14 16 2}
{cmd:version 16}
{p_end}
{p 14 16 2}
{cmd:elabel parse elblnamelist [ mappings ] [ iff ] [ , OPname ]}
{p_end}
{p 14 16 2}
{it:code referring to} {cmd:`lblnamelist'}
{p_end}
{p 14 16 2}
{it:code referring to} {cmd:`mappings'}
{p_end}
{p 14 16 2}
{it:code referring to} {cmd:`iff'}
{p_end}
{p 14 16 2}
{it:code referring to} {cmd:`opname'}
{p_end}
{p 14 16 2}
{it:...}
{p_end}
{p 10 12 2}
{cmd:end}


{p 4 10 8}
{cmd:elabel parse} defines the following locals

{p 10 14 2}
{cmd:`lblnamelist'} contains the unabbreviated list of value 
label names

{p 10 14 2}
{cmd:`newlblnamelist'} contains the list of new value label names

{p 10 14 2}
{cmd:`anything'} contains {it:elblnamelist} and {it:newlblnamelist}, 
as typed

{p 10 14 2}
{cmd:`mappings'} contains {it:mappings}, as typed

{p 10 14 2}
{cmd:`iff'} contains {cmd:iff} followed by {it:eexp}, as typed 

{p 10 14 2}
{cmd:`using'} contains {cmd:using} followed by {it:filename}, 
as typed, including double quotes

{p 10 14 2}
{it:options} contain the respective {it:options}


{title:Description}

{pstd}
{cmd:elabel parse} parses {cmd:elabel} syntax; the command is similar 
to Stata's {helpb syntax} command. 

{pstd}
The elements in {it:string_to_parse} are matched with the elements 
in {it:description_of_string}. Elements that do not appear in 
{it:description_of_string} may not appear in {it:string_to_parse} 
and if they do, an error message is issued. 

{pstd}
Elements that are enclosed in brackets in {it:description_of_string} 
may appear in {it:string_to_parse} but need not appear in 
{it:string_to_parse}.

{pstd}
Elements that appear in {it:description_of_string} and that are not 
enclosed in brackets must appear in {it:string_to_parse}.

{pstd}
In {it:description_of_string}, everything that follows the first comma 
is interpreted as a part of {it:options}, meaning that {it:options} must 
be mentioned last; all other elements may appear in any order but may 
not be mentioned more than once. The elements in {it:description_of_string} 
are described {help elabel_parse##dos:below}.

{pstd}
In {it:string_to_parse} all elements must appear in the indicated 
position.

{pstd}
{cmd:elabel parse} exits with return code {search r(197) , local:r(197)} 
if there is an error in {it:description_of_string} or the command 
itself, not in what is parsed.


{marker dos}{...}
{title:Description of string}

{marker elblnamelist}{...}
{title:elblnamelist}

{pstd}
If you type {cmd:elblnamelist}, {it:string_to_parse} must contain at 
least one (existing) value label name. If you type {cmd:[elblnamelist]}, 
{it:string_to_parse} may contain one or more value label names. If you 
do not type anything, {it:string_to_parse} may not contain an 
{it:elblnamelist}.

{pstd}
You may type {opt elblnamelist(spec)}, where {it:spec} is one or more 
of

{phang2}
{opt newlbl:namelist} allows new (not yet defined) value label names 
in {it:elblnamelist}. All value label names are returned in 
{cmd:`lblnamelist'} in the specified order. New value label names, if 
any, are additionally returned in {cmd:`newlblnamelist'}. Note that
{it:string_to_parse} might contain only new, not yet defined, value 
label names.

{phang2}
{opt nomem:ory} treats value label names attached to variables as 
if they were defined in memory.

{phang2}
{opt cur:rent} implies {opt nomemory} and restricts not yet defined 
value labels to those in the current label language.

{phang2}
{opt abbrev:ok} allows abbreviated value label names; if combined with 
{opt newlblnamelist}, abbreviated value label names are treated as 
existing value labels, not new value label names.

{phang2}
{opt varval:uelabel} allows 
{help elabel##varvaluelabel:{it:varname}{bf::}{it:elblname}} in 
{it:elblnamelist}. Returned in {cmd:`varvaluelabel'} is
{cmd:(}{it:varname} [{it:varname ...}] {it:lblname}{cmd:)} 
[ {cmd:(}{it:varname ...} {it:lblname}{cmd:) {it:...}} ]; also see 
{helpb elabel_varvaluelabel:elabel varvaluelabel}.

{pstd}
{cmd:elblnamelist} may not be combined with {cmd:anything}. The 
unabbreviated list of value label names is returned in {cmd:`lblnamelist'}.


{marker newlblnamelist}{...}
{title:newlblnamelist}

{pstd}
If you type {cmd:newlblnamelist}, {it:string_to_parse} must contain 
at least one new (not yet defined) value label name. If you type 
{cmd:[newlblnamelist]}, {it:string_to_parse} may contain one or more 
new value label names. If you do not type anything, {it:string_to_parse} 
may not contain any new value label names. 

{pstd}
You may type {opt newlblnamelist(spec)}, where {it:spec} is one or more 
of

{phang2}
{opt elbl:namelist} allows existing value label names in 
{it:newlblnamelist}. All value label names are returned in 
{cmd:`lblnamelist'} in the specified order. New value label names 
are additionally returned in {cmd:`newlblnamelist'}. Note that 
{it:string_to_parse} must contain at least one new, not yet defined, 
value label name.

{phang2}
{opt nomem:ory} treats value label names attached to variables as 
if they were defined in memory.

{phang2}
{opt cur:rent} implies {opt nomemory} and restricts not yet defined 
value labels to those in the current label language.

{phang2}
{opt abbrev:ok} allows abbreviated value label names; abbreviated value 
label names are treated as existing value labels, not new value label 
names.

{phang2}
{opt varval:uelabel} allows 
{help elabel##varvaluelabel:{it:varname}{bf::}{it:newlblname}} in 
{it:newlblnamelist}. Returned in {cmd:`varvaluelabel'} is
{cmd:(}{it:varname} [{it:varname ...}] {it:lblname}{cmd:)} 
[ {cmd:(}{it:varname ...} {it:lblname}{cmd:) {it:...}} ]; also see 
{helpb elabel_varvaluelabel:elabel varvaluelabel}.

{pstd}
{cmd:newlblnamelist} may not be combined with {cmd:anything} but may 
be combined with {cmd:elblnamelist}. The list of new value label names 
is returned in {cmd:`newlblnamelist'}.


{marker anything}{...}
{title:anything}

{pstd}
If you type {cmd:anything} (or {cmd:[anything]}), {it:string_to_parse} 
must (or may) contain something in the place of {it:elblnamelist}, or 
{it:newlblnamelist}; these elements are, however, not parsed but returned 
as typed.

{pstd}
{cmd:anything} may not be combined with any of {cmd:elblnamelist} or 
{cmd:newlblnamelist}. Whatever is typed in place of {it:elblnamelist} 
and {it:newlblnamelist} is returned in {cmd:`anything'}.


{marker mappings}{...}
{title:mappings}

{pstd}
If you type {cmd:mappings}, {it:string_to_parse} must contain 
{it:mappings}. If you type {cmd:[mappings]}, {it:string_to_parse} may 
contain {it:mappings}. If you do not type anything, {it:string_to_parse} 
may not contain {it:mappings}. In any case, {it:mappings} are indicated 
by a number like {cmd:42}, or an extended missing value code like {cmd:.f}, 
or an equals sign, optionally enclosed in parentheses, i.e., {cmd:=}, or, 
{cmd:(={it:...})}. Everything following one of these elements is treated as 
a part of {it:mappings}, except {cmd:iff} {it:eexp}, {cmd:using} 
{it:filename}, and {it:options}.

{pstd}
You may type {cmd:mappings(broad)} to request that any element in 
{it:string_to_parse} that is not a name (possibly enclosed in parentheses 
and possibly containing wildcard characters) is treated as a part of 
{it:mappings}. This might be useful when {cmd:mappings} is combined with 
{cmd:anything}.

{pstd}
{it:mappings} are returned in {cmd:`mappings'} as typed.


{marker iffeexp}{...}
{title:iff}

{pstd}
If you type {cmd:iff}, {it:string_to_parse} must contain an
{cmd:iff} {it:eexp}. If you type {cmd:[iff]}, {it:string_to_parse} 
may contain an {cmd:iff} {it:eexp}. If you do not type anything, 
{it:string_to_parse} may not contain an {cmd:iff} {it:eexp}. In any 
case, everything following the word {cmd:iff} is treated as a part of 
{it:eexp}, except {cmd:using} {it:filename} and {it:options}.

{pstd}
Returned in {cmd:`iff'} is {cmd:iff} followed by {it:eexp}, as typed.

{phang2}
If {help version} is set to less than 16, you may type {cmd:if} in 
place of {cmd:iff} and if you do, {it:string_to_parse} may contain 
{cmd:if} or {cmd:iff}; either way, returned in {cmd:`if'} is {cmd:if} 
followed by {it:eexp}.


{marker using}{...}
{title:using}

{pstd}
If you type {cmd:using}, {it:string_to_parse} must contain {cmd:using} 
{it:filename}. If you type {cmd:[using]}, {it:string_to_parse} may 
contain {cmd:using} {it:filename}. If you do not type anything, 
{it:string_to_parse} may not contain {cmd:using} {it:filename}.

{pstd}
Returned in {cmd:`using'} is {cmd:using} followed by {it:filename}, 
as typed, including any double quotes.


{marker options}{...}
{title:options}

{pstd}
The rules for options are the same as those for Stata's 
{help syntax##description_of_options:syntax} command. Technically, 
{cmd:elabel parse} passes the description thru to {cmd:syntax}.


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help syntax}, {help gettoken}, {help label}
{p_end}

{psee}
if installed: {help elabel}
{p_end}
