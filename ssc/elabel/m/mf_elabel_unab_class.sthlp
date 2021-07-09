{smcl}
{cmd:help mata Elabel_Unab()}
{hline}

{title:Title}

{phang}
{cmd:Elabel_Unab()} {hline 2} Unabbreviate value label names (class)


{title:Syntax}

{p 8 12 2}
{cmd:class Elabel_Unab scalar} {it:u}

{p 8 12 2}
{it:string rowvector}{bind:        }
{it:u}{cmd:.unab(}{it:string scalar lblname}{cmd:)}

{p 8 12 2}
{it:string rowvector}{bind:        }
{it:u}{cmd:.unab(}{it:string scalar lblname}{cmd:,} {it:newlblname}{cmd:)}

{p 8 12 2}
{it:void}{bind:                    }
{it:u}{cmd:.nomem(}{it:real scalar val}{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:             }
{it:u}{cmd:.nomem()}

{p 8 12 2}
{it:void}{bind:                    }
{it:u}{cmd:.abbrv(}{it:real scalar val}{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:             }
{it:u}{cmd:.abbrv()}

{p 8 12 2}
{it:void}{bind:                    }
{it:u}{cmd:.mlang(}{it:real scalar val}{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:             }
{it:u}{cmd:.mlang()}

{p 8 12 2}
{it:void}{bind:                    }
{it:u}{cmd:.nonamesok(}{it:real scalar val}{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:             }
{it:u}{cmd:.nonamesok()}


{p 4 10 2}
where {it:val} evaluates to true ({it:val}!=0) or false ({it:val}==0).


{title:Description}

{pstd}
{cmd:Elabel_Unab()} returns instances of {cmd:class Elabel_Unab}; 
{cmd:Elabel_Unab()} extends 
{helpb mf_elabel_dir_class:Elabel_Dir()}. The class is used 
for developing the {cmd:elabel} package. See 
{helpb mf_elabel_unab:elabel_unab()} for the corresponding Mata 
function.

{pstd}
{it:u}{cmd:.unab(}{it:lblname}{cmd:)} returns {it:lblname} 
unabbreviated or errors out with the corresponding Stata 
error message. 

{pstd}
{it:u}{cmd:.unab(}{it:lblname}{cmd:,} {it:newlblname}{cmd:)} 
returns {it:lblname} unabbreviated and replaces {it:newlblname} 
with {cmd:J(1, 0, "")}, or, if {it:lblname} could not be matched, 
puts {it:lblname} into {it:newlblname} and returns {cmd:J(1, 0, "")}. 

{pstd}
{it:u}{cmd:.nomem()} specifies how to treat nonexistent value 
labels. The default is to treat nonexistent value labels as such, 
i.e., {it:nomem}==0. The complementary {it:u}{cmd:.mlang()} is 
inherited from {helpb mf_elabel_dir_class:Elabel_Dir()}.

{pstd}
{it:u}{cmd:.abbrv()} specifies whether value label names may be 
abbreviated. The default setting is {it:val}=0, meaning value label 
names may not be abbreviated.

{pstd}
{it:u}{cmd:.nonamesok()}, if {it:val}!=0, causes {cmd:unab()} to exit 
with a Stata error message if no value labels are stored in memory. The 
default setting is {it:val}=1. 


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
