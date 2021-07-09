{smcl}
{cmd:help elabel fcncall}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel fcncall} {hline 2} Parse call to {cmd:elabel_fcn_{it:fcn}}


{title:Syntax}

{p 8 12 2}
{cmd:elabel fcncall}
{{cmdab:var:iable}|{cmdab:de:fine}|{cmd:*}} 
[ {it:lmacname1} ] {it:lmacname2} {it:lmacname3}
{cmd::} {it:elabel_fcn_call}


{p 4 10 2}
where {it:lmacname1}, {it:lmacname2}, and {it:lmacname3} are 
local macro names; {it:elabel_fcn_call} is

{p 10 10 2}
{it:subcommand}
{it:namelist} 
{cmd:=} {it:arguments} [ {cmd:,} {it:options} ]

{p 4 10 2}
and local macros are filled with the elements of 
{it:elabel_fcn_call}

{col 10}local macro{col 24}contains
{col 10}{hline 42}
{p2colset 10 24 24 2}{...}
{p2col:{it:lmacname1}}{it:subcommand}{p_end}
{p2col:{it:lmacname2}}{it:namelist}{p_end}
{p2col:{it:lmacname3}}{it:arguments} [ {cmd:,} {it:options} ]{p_end}
{p2colreset}{...}


{p 4 10 2}
If {help version} is set to 16 or higher, the syntax 

{p 8 12 2}
{cmd:elabel fcncall}
{{cmdab:var:iable}|{cmdab:de:fine}|{cmd:*}} 
[ {it:lmacname1} ] {it:lmacname2} {it:lmacname3}

{p 4 10 2}
is allowed and obtains {it:elabel_fcn_call} from what the caller has typed.
 

{title:Description}

{pstd}
{cmd:elabel fcncall} is a convenience tool for parsing calls to 
{cmd:elabel_fcn_{it:fcn}} programs. 

{pstd}
If you are writing a {help elabel_functions##fcnsvar:(pseudo-)function} 
for {helpb elabel_variable:elabel variable}, specify 
{cmd:elabel fcncall variable {it:...}}

{pstd}
If you are writing a {help elabel_functions##fcns:(pseudo-)function} 
for {helpb elabel_define:elabel define}, specify 
{cmd:elabel fcncall define {it:...}}

{pstd}
In the rare cases where you want to write a 
{help elabel_functions##functions:(pseudo-)function} for both 
{helpb elabel_variable:elabel variable} and
{helpb elabel_define:elabel define}, specify 
{cmd:elabel fcncall *} {it:lmacname1 ...}


{title:Remarks}

{pstd}
As explained in 
{help elabel_programming##addfcn:Adding (pseudo-)functions to {bf:elabel}}, 
when you type

{phang2}
{cmd:. elabel define {it:elblnamelist} = {it:fcn}({it:arguments})} 
[ {cmd:,} {{cmd:add}|{cmd:modify}|{cmd:replace}} {cmd:nofix} {it:options} ]
{p_end}

{phang}
{cmd:elabel} internally calls {cmd:elabel_fcn_{it:fcn}} as

{phang2}
{cmd:elabel_fcn_{it:fcn}}
{cmd:define}
{it:lblnamelist} 
{cmd: = {it:arguments}}
[ {cmd:,} {{cmd:add}|{cmd:modify}|{cmd:replace}} {cmd:nofix} {it:options} ]
{p_end}

{phang}
{cmd:elabel fcncall} splits this internal call and returns the 
respective elements in local macros. Typical usage of 
{cmd:elabel fcncall} is

{p 10 12 2}
{cmd:program elabel_fcn_newfcn}
{p_end}
{p 14 16 2}
{cmd:version {ccl stata_version}}
{p_end}
{p 14 16 2}
{cmd:elabel fcncall}{{cmd:define}|{cmd:variable}} {cmd:lblnames 0 : `0'}
{p_end}
{p 14 16 2}
{{cmd:syntax {it:...}}|{cmd:elabel parse {it:...} {cmd:: `0'}}}
{p_end}
{p 14 16 2}
{it:...}
{p_end}
{p 10 12 2}
{cmd:end}

{pstd}
where you omit {it:lmacname1} because you already know that the subcommand
is {cmd:define} or {cmd:variable}.


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb gettoken}{p_end}

{psee}
if installed: {help elabel}
{p_end}
