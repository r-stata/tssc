{smcl}
{cmd:help elabel programming}
{hline}

{title:Title}

{p 4 12 2}
{cmd:elabel} {hline 2} {cmd:elabel} programming


{title:Description}

{pstd}
The commands and functions described here are primarily used for developing 
the {cmd:elabel} package. Some of these commands and functions might be of 
interest to programmers.

{pstd}
Below the list of commands and functions is a short description of 
{help elabel_programming##addcmd:how to add new commands to {bf:elabel}}.

{dlgtab:Programming commands}
{synoptset 28 tabbed}{...}

{...}
{synopt:{helpb elabel_confirm:elabel confirm}}
Argument verification
{p_end}

{...}
{synopt:{helpb elabel_numlist:elabel numlist}}
Parse numeric list
{p_end}

{...}
{synopt:{helpb elabel_parse:elabel parse}}
Parse {cmd:elabel} syntax
{p_end}

{...}
{synopt:{helpb elabel_unab:elabel unab}}
Unabbreviate value label names
{p_end}

{dlgtab:Mata functions (elabel)}
{synoptset 28 tabbed}{...}

{...}
{synopt:{helpb mf_elabel_dir:elabel_dir()}}
Obtain lists of value label names
{p_end}

{...}
{synopt:{helpb mf_elabel_ldir:elabel_ldir()}}
Obtain list of label languages
{p_end}

{...}
{synopt:{helpb mf_elabel_rename:elabel_rename()}}
Rename value label
{p_end}

{...}
{synopt:{helpb mf_elabel_unab:elabel_unab()}}
Unabbreviate value label names
{p_end}

{...}
{synopt:{helpb mf_elabel_numlist:elabel_numlist()}}
Parse numeric list
{p_end}

{...}
{synopt:{helpb mf_elabel_vl:elabel_vl{it:*}()}}
Manipulate value label
{p_end}

{dlgtab:Mata functions (generic)}
{synoptset 28 tabbed}{...}

{...}
{synopt:{helpb mf_aandb:aandb()}}
Manipulate row vectors
{p_end}

{...}
{synopt:{helpb mf_distinctrowsof:distinctrowsof()}}
Distinct rows of matrix
{p_end}

{...}
{synopt:{helpb mf_range_mv:range_mv()}}
Real vector over range
{p_end}

{...}
{synopt:{helpb mf_tokenpreview:tokenpreview()}}
Peek ahead at tokens
{p_end}

{...}
{synopt:{helpb mf_tokendiscard:tokendiscard()}}
Discard successive tokens
{p_end}

{dlgtab:Mata utilities (elabel)}
{synoptset 28 tabbed}{...}

{...}
{synopt:{helpb mf_elabel_u:elabel_u_{it:*}()}}
{cmd:elabel} utility functions
{p_end}

{dlgtab:Development}

{synopt:{help elabel_development:elabel development}}
{p_end}
{synoptline}


{marker addcmd}{...}
{title:Adding commands to elabel}

{pstd}
New commands for {cmd:elabel} are typically written in 
ado; technically, it suffices to define a program in 
memory. A new command must be named {cmd:elabel_cmd_{it:newcmd}} 
and possibly stored in {cmd:elabel_cmd_{it:newcmd}.ado}, where 
Stata can find it. The new command is then called as 
{cmd:elabel {it:newcmd}} {it:...}

{pstd}
Although a new command must be written in (a)do, much of the work might 
be done in Mata. Many of the programming tools described above are 
written in Mata; these functions, however, often call Stata and often 
exit with Stata error messages.

{pstd}
A new command might look like this:

{p 10 12 2}
{cmd:program elabel_cmd_{it:newcmd}}
{p_end}
{p 14 16 2}
{cmd:version {ccl stata_version}}
{p_end}
{p 14 16 2}
{helpb elabel_parse:elabel parse} {cmd:elblnamelist [ mappings ] [ iff ] [ , OPname ] : `0'}
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
{p 14 16 2}
{cmd:mata : elabel_cmd_{it:newcmd}()}
{p_end}
{p 10 12 2}
{cmd:end}

{p 10 12 2}
{cmd:version {ccl stata_version}}
{p_end}
{p 10 12 2}
{cmd:mata :}
{p_end}
{p 10 12 2}
{cmd:void elabel_cmd_{it:newcmd}()}
{p_end}
{p 10 12 2}
{cmd:{c -(}}
{p_end}
{p 14 16 2}
{it:...}
{p_end}
{p 10 12 2}
{cmd:{c )-}}
{p_end}
{p 10 12 2}
{cmd:end}
{p_end}
{p 10 12 2}
{cmd:exit}
{p_end}

{pstd}
Some of {cmd:elabel}'s subcommands, e.g., 
{helpb elabel_recode:elabel recode}, are implemented as ado-files. 


{marker addfcn}{...}
{title:Adding (pseudo-)functions to elabel}

{pstd}
Some {cmd:elabel} commands allow {help elabel_functions:(pseudo-)functions} 
of the form {cmd:{it:fcn}}{opt (arguments)} in {it:mappings}. These 
(pseudo-)functions are just programs; this section explains how to write 
these programs.

{pstd}
New (pseudo-)functions for {cmd:elabel} are typically written in 
ado; technically, it suffices to define a program in memory. A new 
{cmd:elabel} (pseudo-)function is named {cmd:elabel_fcn_{it:newfcn}} 
and possibly stored in {cmd:elabel_fcn_{it:newfcn}.ado}, where Stata 
can find it. Optionally, {cmd:elabel_fcn_{it:newfcn}} may have 
{help program_properties:program properties} associated with it; 
{help elabel_programming##prop:see below}. 

{pstd}
The syntax for {cmd:elabel} (pseudo-) functions is 

{p 8 12 2}
{cmd:elabel variable}
{varlist}
{cmd:= {it:newfcn}}{opt (arguments)}
[ {it:iff} ]
[ {cmd:,} {it:options} ]
{p_end}
{pstd}
or
{p_end}
{p 8 12 2}
{cmd:elabel define}
{it:{help elabel##elblnamelist:elblnamelist}}
{cmd:= {it:newfcn}}{opt (arguments)}
[ {it:iff} ]
[ {cmd:,} {{opt a:dd}|{opt modify}|{opt replace}} {opt nofix} {it:options} ]
{p_end}

{pstd}
and passed to {cmd:elabel_fcn_{it:newfcn}.ado} is

{p 8 12 2}
{cmd:variable}
{varlist}
{cmd:=} {it:arguments}
[ {it:iff} ]
[ {cmd:,} {it:options} ]
{p_end}
{pstd}
or
{p_end}
{p 8 12 2}
{cmd:define}
{it:lblnamelist}
{cmd:=} {it:arguments}
[ {it:iff} ]
[ {cmd:,} {{opt a:dd}|{opt modify}|{opt replace}} {opt nofix} {it:options} ]
{p_end}

{pstd}
In the above, {varlist} is the expanded variable list {it:lblnamelist} is the expanded {it:elblnamelist}, , and {it:arguments} are {it:arguments} as 
typed; note that {it:iff} and {it:options} are also passed through as 
typed. Typically, {cmd:elabel_fcn_{it:newfcn}.ado} reads

{p 10 12 2}
{cmd:program elabel_fcn_{it:newfcn}}
{p_end}
{p 14 16 2}
{cmd:version {ccl stata_version}}
{p_end}
{p 14 16 2}
{helpb elabel_fcncall:elabel fcncall}
{{cmd:variable}|{cmd:define}} {cmd:names 0 : `0'}
{p_end}
{p 14 16 2}
{{cmd:syntax {it:...}}|{helpb elabel_parse:elabel parse} {it:...} {cmd:: `0'}}
{p_end}
{p 14 16 2}
{it:...}
{p_end}
{p 14 16 2}
{cmd:elabel} {{cmd:variable}|{cmd:define}} `names' {it:...}
{p_end}
{p 10 12 2}
{cmd:end}

{pstd}
See {helpb elabel_fcncall:elabel fcncall} for the recommended way to 
parse {cmd:elabel} (pseudo-)function calls. All existing 
{help elabel_functions:(pseudo-)functions} are implemented as ado-files. 

{pstd}
{cmd:elabel variable} and {cmd:elabel define} do not parse {it:arguments}, 
{it:iff}, and {it:options}, and they do not define new or modify existing 
variable or value labels; {cmd:elabel_fcn_{it:newfcn}} may, and usually 
does, call {cmd:elabel variable} or {cmd:elabel define}.

{pstd}
{ul:Writing (pseudo-)functions for elabel variable}

{pstd}
When {helpb elabel variable} calls 
{cmd:elabel_fcn_{it:newfcn}.ado}, you can be sure that 

{p 8 11 2}
1. variable names in {varlist} are unique

{p 8 11 2}
2. if {cmd:elabel_fcn_{it:newfcn}} exits with error, the data in memory 
is not altered but {help preserve:preserved}

{marker prop}{...}
{pstd}
{ul:Writing (pseudo-)functions for elabel define}

{pstd}
If you write a (pseudo-)function for {helpb elabel define}, you may 
specify program properties {cmd:elabel_vvl} as in

{p 10 12 2}
{cmd:program elabel_fcn_{it:newfcn} , properties(elabel_vvl)}
{p_end}

{pstd}
and if you do, {cmd:elabel_fcn_{it:newfcn}} allows 
{help elabel##varvaluelabel:{it:varname}{bf::}{it:elblname}} in 
{help elabel##elblnamelist:{it:elblnamelist}}. If you specify 
{cmd:elabel_vvl}, {it:elblnamelist} is not expanded but passed 
through as typed. Value labels are not attached to variables, 
either; for that see {helpb elabel_varvaluelabel:elabel varvaluelabel}.

{pstd}
Before {cmd:elabel define} calls {cmd:elabel_fcn_{it:newfcn}.ado}, it 
parses {it:elblnamelist} and its own options; {cmd:elabel_fcn_{it:newfcn}} 
is only called if there is no syntax error. 

{pstd}
When {cmd:elabel define} calls 
{cmd:elabel_fcn_{it:newfcn}.ado}, you can be sure that

{p 8 11 2}
1. only one of the options {opt add}, {opt modify}, or {opt replace} is 
specified

{p 8 11 2}
2. if none of the above options was specified, {it:lblnamelist} only 
contain new, not yet defined, value label names

{p 8 11 2}
3. if {it:lblnamelist} contains new value label names, new value label 
names are unique

{p 8 11 2}
4. if {cmd:elabel_fcn_{it:newfcn}} exits with error, the data in memory 
is not altered but {help preserve:preserved}


{phang}
{bf:{ul:Advanced: Setting locals in the caller's name space}}
{p_end}

{p 4 4 2}
In general, there is nothing special that you need to do to set local macros 
in the name space of {cmd:elabel_cmd_{it:newcmd}}'s (or 
{cmd:elabel_fcn_{it:newfcn}}'s) caller. Technically, {cmd:elabel.ado} 
calls {cmd:elabel_cmd_{it:newcmd}} (or {cmd:elabel_fcn_{it:newfcn}}). Thus, 
when you set local macros in the name space of {cmd:elabel_cmd_{it:newcmd}}'s 
(or {cmd:elabel_fcn_{it:newfcn}}'s) caller, you are setting these local 
macros in the name space of {cmd:elabel.ado}; the latter, however, is set up 
to pass any local macros through to its caller, respectively. 

{pstd}
The only thing that you cannot do in the usual way is (re)set a local 
macro in the caller's name space to missing, i.e. {cmd:""}; to do this, 
you must additionally tell {cmd:elabel} about the local macros that you 
wish to set in its caller's name space. You tell {cmd:elabel} about the 
local macros that you wish to set in its caller's name space by prefixing 
the respective (not documented) command with {cmd:elabel} and then 
listing all local macro names but not their contents. 
{p_end}


{title:Utility commands}

{p 4 10 2}
{ul:Syntax}

{p 8 12 2}
{cmd:elabel _u_gmappings}
{it:lmacname1} {it:lmacname2}
{cmd::} {cmd:(}{it:spec1}{cmd:)} {cmd:(}{it:spec2}{cmd:)}

{p 8 12 2}
{cmd:elabel _u_parse_rules}
[[ {cmd:,} {opt norules} ] {cmd::} ]
{cmd:(}{it:rules}{cmd:)} [ {cmd:(}{it:rules}{cmd:)} {it:...} ]

{p 8 12 2}
{cmd:elabel _u_usedby}
{it:lmacname}
{cmd::} {it:lblnamelist}


{p 4 10 2}
where {it:lmacname1}, {it:lmacname2}, and {it:lmacname} are 
{help macro:local macro} names

{p 10 8 2}
{it:spec1} and {it:spec2} are simply {help strings}

{p 10 8 2}
{it:rules} are the {help elabel_recode##rule:{it:rules}} described in 
{helpb elabel_recode:elabel recode}


{p 4 10 2}
{ul:Description}

{pstd}
{cmd:elabel _u_gmappings} parses grouped {it:mappings} of the form 
{cmd:(}{it:spec1}{cmd:)} {cmd:(}{it:spec2}{cmd:)} and puts {it:spec1} 
into local macro {it:lmacname1} and {it:spec2} into local macro 
{it:lmacname2}. If {it:mapppings} do not have the required form, the 
command exists with return code 498. If there is a syntax error in the 
command itself, the command exits with return code 197.

{pstd}
{cmd:elabel _u_parse_rules} parses {it:rules} of the form 
{cmd:(}{it:from_numlist} {cmd:=} {it:to_numlist} [{cmd:"label"} [{it:...}]]{cmd:)} {it:...}, 
and returns the respective elements in {cmd:s(from}{it:#}{cmd:)}, 
{cmd:s(to}{it:#}{cmd:)}, and {cmd:s(text}{it:#}{cmd:)}. The number of rules 
are returned in {cmd:s(n_rules)}. Additionally, {cmd:s(null}{it:#}{cmd:)} 
contains 1 if {cmd:s(text}{it:#}{cmd:)} is specified as {cmd:""}, and contains 
0 otherwise. If {opt norules} is not specified, {cmd:s(rules)} containes all 
rules in the form {cmd:(}{it:from#}{cmd:=}{it:to#}{cmd:)} {it:...}. If 
{it:rules} are invalid, the command exists with the respective error 
message. If there is a syntax error in the command itself, the command exits 
with return code 197.

{pstd}
{cmd:elabel _u_usedby} puts in {it:lmacname} the variable names that have 
one of {it:lblnamelist} attached (in any {help label language}). If any of 
the names in {it:lblnamelist} is invalid, the command exists with syntax 
error 198. Note that wildcards are not allowed and {cmd:_all} is treated 
as simple name; {cmd:elabel _u_usedby} does not unabbreviate value label 
names. If there is a syntax error in the command itself, the command exits 
with return code 197.


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help Mata}{p_end}

{psee}
if installed: {help elabel}{p_end}
