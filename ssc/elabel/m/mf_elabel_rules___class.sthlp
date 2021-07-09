{smcl}
{cmd:help mata Elabel_Rules__()}
{hline}

{title:Title}

{phang}
{cmd:Elabel_Rules__()} {hline 2} Parse transformation rules (class)


{title:Syntax}

{p 8 12 2}
{cmd:class Elabel_Rules__ scalar} {it:r}

{p 8 12 2}
{it:void}{bind:                       }
{it:r}{cmd:.set(}{it:string scalar rules}{cmd:)}

{p 8 12 2}
{it:string scalar}{bind:              }
{it:r}{cmd:.set()}

{p 8 12 2}
{it:real colvector}{bind:             }
{it:r}{cmd:.from()}

{p 8 12 2}
{it:real colvector}{bind:             }
{it:r}{cmd:.to()}

{p 8 12 2}
{it:string colvector}{bind:           }
{it:r}{cmd:.text()}

{p 8 12 2}
{it:real colvector}{bind:             }
{it:r}{cmd:.null()}

{p 8 12 2}
{it:string scalar}{bind:              }
{it:r}{cmd:.rules()}


{p 4 10 2}
where {it:rules} is 
{cmd:(}{it:from_}{{it:#}|{it:numlist}}
{cmd:=}
{it:to_}{{it:#}|{it:numlist}}
[ {cmd:"}{it:label}{cmd:"} [{it:...}] ]{cmd:)}
{it:...}


{title:Description}

{pstd}
{cmd:Elabel_Rules__()} returns instances of {cmd:class Elabel_Rules__}; 
{cmd:Elabel_Rules__()} extends 
{helpb mf_elabel_utilities_class:Elabel_Utilities()}. The 
class is used for developing the {cmd:elabel} package. See 
{helpb mf_elabel_u:elabel_u_parse_rules()} for the corresponding Mata 
function.

{pstd}
{it:r}{cmd:.set()} sets the {it:rules} to be parsed; without arguments, 
the function returns {it:rules} as typed.

{pstd}
{it:r}{cmd:.from()}, {it:r}{cmd:.to()}, and {it:r}{cmd:.text()} return 
the respective elements in {it:rules}. 

{pstd}
{it:r}{cmd:.null()} indicates, for each element of {it:r}{cmd:.text()}, 
whether a null string ({cmd:""}) has been specified.  

{pstd}
{it:r}{cmd:.rules()} returns {it:rules} in the form 
{cmd:(}{it:#}{cmd:=}{it:#}{cmd:)} {it:...}, i.e., all {it:numlists} are 
split into single numbers, and any {it:labels} are omitted.


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
