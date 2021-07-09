{smcl}
{cmd:help mata elabel_unab()}
{hline}

{title:Title}

{phang}
{cmd:elabel_unab()} {hline 2} Unabbreviate value label names


{title:Syntax}

{p 8 12 2}
{it:string rowvector} 
{cmd:elabel_unab(}{it:lblnamelist}[{cmd:,}
{it:nomem}[{cmd:,}
{it:mlang}[{cmd:,}
{it:abbrevok}]]]{cmd:)}


{p 4 10 2}
where {it:lblnamelist} is a {it:string rowvector} containing value label 
names, possibly with wildcard characters {cmd:*}, {cmd:~}, and {cmd:?}; 
{it:abbrevok}, {it:nomem}, and {it:mlang} are {it:real scalar}.

{p 4 10 2} 
{it:nomem}!=0 specifies that nonexistent value label names are treated 
as if they were defined in memory. Default is {it:nomem}=0.

{p 4 10 2}
{it:mlang}!=0 respects multilingual datasets (see {help label language}) 
when {it:nomem}!=0. Default is {it:mlang}=1.

{p 4 10 2} 
{it:abbrevok} specifies whether {it:lblname} may be abbreviated. The 
default is {it:abbrevok}=0, meaning that value label names may not be 
abbreviated.


{title:Description}

{pstd}
{cmd:elabel_unab()} returns a row vector with all value label names that 
match the {it:lblnames} in {it:lblnamelst}. When {it:lblname} does not 
contain the wildcard characters {cmd:*} or {it:?}, or when {it:lblname} 
contains the wildcard character {cmd:~}, only one name is allowed to 
match.


{title:Conformability}

    {cmd:elabel_unab(}{it:lblnamelist}[{cmd:,} {it:nomem}[{cmd:,} {it:mlang}[{cmd:,} {it:abbrevok}]]]{cmd:)}
              {it:lblnamelist}: 1 {it:x c} 
                    {it:nomem}: 1 {it:x} 1
                    {it:mlang}: 1 {it:x} 1
                 {it:abbrevok}: 1 {it:x} 1
					  
		 
{title:Diagnostics}

{pstd}
{cmd:elabel_unab()} exits with Stata error messages if {it:lblname} is not a 
valid name, if {it:lblname} is not found, and if {it:lblname} matches too 
many or none value label name. {cmd:elabel_unab()} exits with error if no 
value labels are found.


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
