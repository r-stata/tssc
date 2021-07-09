{smcl}
{cmd:help mata Elabel_Options__()}
{hline}

{title:Title}

{phang}
{cmd:Elabel_Options__()} {hline 2} Manage {cmd:elabel} options (class)


{title:Syntax}

{p 8 12 2}
{cmd:class Elabel_Options__ scalar}{bind:  }{it:o}

{p 8 12 2}
{it:void}{bind:                          }
{it:o}{cmd:.st_get()}

{p 8 12 2}
{it:void}{bind:                          }
{it:o}{cmd:.st_get_aa()}

{p 8 12 2}
{it:void}{bind:                          }
{it:o}{cmd:.st_get_mm()}

{p 8 12 2}
{it:void}{bind:                          }
{it:o}{cmd:.st_get_options()}

{p 8 12 2}
{it:real scalar}{bind:                   }
{it:o}{cmd:.add()}

{p 8 12 2}
{it:real scalar}{bind:                   }
{it:o}{cmd:.modify()}

{p 8 12 2}
{it:real scalar}{bind:                   }
{it:o}{cmd:.replace()}

{p 8 12 2}
{it:real scalar}{bind:                   }
{it:o}{cmd:.fixfmt()}

{p 8 12 2}
{it:real scalar}{bind:                   }
{it:o}{cmd:.nomem()}

{p 8 12 2}
{it:real scalar}{bind:                   }
{it:o}{cmd:.current()}

{p 8 12 2}
{it:string scalar}{bind:                 }
{it:o}{cmd:.st_options(}[{it:real scalar comma}]{cmd:)}

{p 8 12 2}
{it:string scalar}{bind:                 }
{it:o}{cmd:.printamrnf(}[{it:real scalar comma}]{cmd:)}

{p 8 12 2}
{it:string scalar}{bind:                 }
{it:o}{cmd:.print_opts(}[{it:real scalar comma}]{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:                   }
{it:o}{cmd:.aa()}

{p 8 12 2}
{it:real scalar}{bind:                   }
{it:o}{cmd:.mm()}

{p 8 12 2}
{it:string scalar}{bind:                 }
{it:o}{cmd:.sep()}


{title:Description}

{pstd}
{cmd:Elabel_Options__()} returns instances of 
{cmd:class Elabel_Options__}. The class is used 
for developing the {cmd:elabel} package.

{pstd}
{it:o}{cmd:.st_get()} obtains the settings for all options, except 
{opt append}, {opt merge0}, and {opt merge()}, from the respective 
Stata local macros; the function is usually called after 
{helpb mf_elabel_utilities_class:{it:u}.u_st_syntax()} or a direct 
call to Stata's {helpb syntax}. If {cmd:replace} is combined with 
{cmd:add} or {cmd:modify}, the respective Stata error message is 
issued. If {cmd:modify} is specified, {cmd:add} is set to false 
({it:o}{cmd:.add()}==0).

{pstd}
{it:o}{cmd:.st_get_aa()} and {it:o}{cmd:.st_get_mm()} obtain the 
settings for options {opt append}, {opt merge0}, and {opt merge()} 
from the respective Stata local macros; the function is usually called 
after {it:o}{cmd:.st_get()}. If {opt append} is specified with one of 
{opt modify} or {opt replace}, or if {opt append} is specified without 
{opt add}, a Stata error message is issued. If {opt merge} is specified 
with {opt replace}, or if {opt merge} is specified without {opt modify}, 
a Stata error message is issued. Also, if {opt merge()} is specified with 
more than one word, a Stata error message is issued. Option {opt merge()} 
should be specified in the {helpb syntax} command as 
{cmd:MERGE(string asis)}.

{pstd}
{it:o}{cmd:.st_get_options()} obtains {cmd:st_local("options")}.

{pstd}
{it:o}{cmd:.add()}, {it:o}{cmd:.modify()}, {it:o}{cmd:.replace()} are 
called after {it:o}{cmd:.st_get()} and return the settings of the 
respective options.

{pstd}
{it:o}{cmd:.fixfmt()} is called after {it:o}{cmd:.st_get()}; 
{it:o}{cmd:.fixfmt()} is the counterpart of option {cmd:nofix}. If
{cmd:nofix} is specified, {it:o}{cmd:.fixfmt()}==0.

{pstd}
{it:o}{cmd:.nomem()} and {it:o}{cmd:.current()} are called after 
{it:o}{cmd:.st_get()} and return the settings of the respective 
options. If {cmd:current} is specified, {cmd:nomem} is set to true 
({it:o}{cmd:.nomem()}!=0).

{pstd}
{it:o}{cmd:.st_options()} is called after {it:o}{cmd:.st_get()} and 
returns any additional options as specified, preceded by a comma.

{pstd}
{it:o}{cmd:.printamrnf()} is called after {it:o}{cmd:.st_get()} and 
returns whichever of {cmd:add modify replace nofix} was specified, 
preceded by a comma.

{pstd}
{it:o}{cmd:.print_opts()} is called after {it:o}{cmd:.st_get()} and 
returns {it:o}{cmd:.printamrnf()} {cmd:+} {it:o}{cmd:.st_options()}.

{pstd}
{it:o}{cmd:.aa()}, {it:o}{cmd:.mm()}, and {it:o}{cmd:.sep()} are called 
after {it:o}{cmd:.st_get_aa()} and {it:o}{cmd:.mm()} and return the 
settings of the respective options. {it:o}{cmd:.sep()} returns 
{helpb mf_char:char(32)}, i.e., {cmd:" "}, if {opt merge0} was specified 
without {opt merge()}.


{title:Conformability}

{pstd}
As indicated above.

		 
{title:Diagnostics}

{pstd}
Not documented; class functions are for internal use.


{title:Source code}

{pstd}
Distributed with the {cmd:elabel} package.
{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb mata}
{p_end}

{psee}
if installed: {help elabel}
{p_end}
