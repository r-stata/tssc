{smcl}
{cmd:help mata elabel_rename()}
{hline}

{title:Title}

{phang}
{cmd:elabel_rename()} {hline 2} Rename value label


{title:Syntax}

{p 8 12 2}
{it:void} 
{cmd:elabel_rename(}{it:string scalar oldlblname}{cmd:,}
{it:string scalar newlblname}{cmd:)}

{p 8 12 2}
{it:void} 
{cmd:elabel_rename(}{it:oldlblname}{cmd:,}
{it:newlblname}{cmd:,}
{it:real scalar nomemold}[{cmd:,}
{it:real scalar nomemnew}]{cmd:)}


{p 4 10 2}
where {it:oldlblname} is a value label name, possibly with wildcard 
characters {cmd:*}, {cmd:~}, and {cmd:?}.

{p 4 10 2} 
{it:newlblname} is the name of a new, not yet defined, value label.

{p 4 10 2}
{it:nomemold}!=0 treats value labels that are not (yet) defined in 
memory as existing in {it:oldlblname}; default is {it:nomemold}=0.

{p 4 10 2}
{it:nomemnew}!=0 treats value labels that are not (yet) defined in 
memory as existing in {it:newlblname}; default is {it:nomemnew}=1.


{title:Description}

{pstd}
{cmd:elabel_rename()} changes the name of value label {it:oldlblname} to 
{it:newlblname}.

{pstd}
Technically, {cmd:elabel_rename()} copies the contents of {it:oldlblname} 
to {it:newlblname}, drops {it:oldlblname} from memory, and attaches 
{it:newlblname} to all variables that previously had {it:oldlblname} 
attached.


{title:Conformability}

    {cmd:elabel_rename(}{it:oldlblname}{cmd:,} {it:newlblname}[{cmd:,} {it:nomemold}[{cmd:,} {it:nomemnew}]]{cmd:)}
          {it:oldlblname}: 1 {it:x} 1 
          {it:newlblname}: 1 {it:x} 1
            {it:nomemold}: 1 {it:x} 1
            {it:nomemnew}: 1 {it:x} 1
					  
		 
{title:Diagnostics}

{pstd}
{cmd:elabel_rename()} exits with Stata error messages if {it:oldlblname} is not 
found, matches more than one value label name, or is otherwise invalid. It
also exits with error if {it:newlblname} is already defined or otherwise 
invalid.


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
