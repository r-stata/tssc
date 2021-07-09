{smcl}
{cmd:help mata Elabel_Syntax()}
{hline}

{title:Title}

{phang}
{cmd:Elabel_Syntax()} {hline 2} Parse {cmd:elabel} syntax (class)


{title:Syntax}

{p 8 12 2}
{cmd:class Elabel_Syntax scalar} {it:s}

{p 8 12 2}
{it:void}{bind:                      }
{it:s}{cmd:.set(}{it:string scalar str_to_parse}{cmd:)}


{p 8 12 2}
{it:string rowvector}{bind:          }
{it:s}{cmd:.lblnamelist()}

{p 8 12 2}
{it:string rowvector}{bind:          }
{it:s}{cmd:.newlblnamelist()}

{p 8 12 2}
{it:string rowvector}{bind:          }
{it:s}{cmd:.labelnamelist()}

{p 8 12 2}
{it:string rowvector}{bind:          }
{it:s}{cmd:.varvaluelabel()}

{p 8 12 2}
{it:string scalar}{bind:             }
{it:s}{cmd:.anything()}

{p 8 12 2}
{it:string scalar}{bind:             }
{it:s}{cmd:.mappings()}

{p 8 12 2}
{it:string scalar}{bind:             }
{it:s}{cmd:.iff_eexp()}

{p 8 12 2}
{it:string scalar}{bind:             }
{it:s}{cmd:.filename()}

{p 8 12 2}
{it:string scalar}{bind:             }
{it:s}{cmd:.options()}


{p 8 12 2}
{it:void}{bind:                      }
{it:s}{cmd:.newlblnameok(}{it:real scalar val}{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:               }
{it:s}{cmd:.newlblnameok()}

{p 8 12 2}
{it:void}{bind:                      }
{it:s}{cmd:.varvaluelabelok(}{it:real scalar val}{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:               }
{it:s}{cmd:.varvaluelabelok()}

{p 8 12 2}
{it:void}{bind:                      }
{it:s}{cmd:.anythingok(}{it:real scalar val}{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:               }
{it:s}{cmd:.anythingok()}

{p 8 12 2}
{it:void}{bind:                      }
{it:s}{cmd:.iffword(}{it:string rowvector iffword}{cmd:)}

{p 8 12 2}
{it:string rowvector}{bind:          }
{it:s}{cmd:.iffword()}

{p 8 12 2}
{it:void}{bind:                      }
{it:s}{cmd:.usingword(}{it:string scalar usingword}{cmd:)}

{p 8 12 2}
{it:string scalar}{bind:             }
{it:s}{cmd:.usingword()}

{p 8 12 2}
{it:void}{bind:                      }
{it:s}{cmd:.strict(}{it:real scalar val}{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:               }
{it:s}{cmd:.strict()}

{p 8 12 2}
{it:void}{bind:                      }
{it:s}{cmd:.broadmappings(}{it:real scalar val}{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:               }
{it:s}{cmd:.broadmappings()}


{p 4 10 2}
where {it:val} evaluates to true ({it:val}!=0) or false ({it:val}==0).


{title:Description}

{pstd}
{cmd:Elabel_Syntax()} returns instances of {cmd:class Elabel_Syntax}; 
{cmd:Elabel_Syntax()} extends 
{helpb mf_elabel_unab_class:Elabel_Unab()}. The class is used for 
developing the {cmd:elabel} package. See {helpb elabel_parse:elabel parse} 
for the corresponding command. The functions call Stata's {helpb syntax} 
and reset the corresponding locals.

{pstd}
{it:s}{cmd:.set()} sets the {it:string scalar str_to_parse} that is to be 
parsed. A {it:str_to_parse} contains the elements 

{p 12 12 2}
[ {it:{help elabel##elblnamelist:elblnamelist}} ] 
[ {it:{help elabel##mappings:mappings}} ] 
[ {helpb elabel##iffeexp:iff {it:eexp}} ] 
[ {helpb using} {it:{help filename}} ] 
[ {cmd:,} {it:options} ]

{pstd}
where none of the elements needs to appear but when it appears it must 
appear in the indicated postition. 

{phang2}
{it:s}{cmd:.set()} without arguments is seldom called and returns 
{it:str_to_parse}. The function might be called if you change the 
settings and should be called if you change settings in 
{helpb mf_elabel_unab_class:Elabel_Unab()}; in that case, code: 
{it:s}{cmd:.set(}{it:s}{cmd:.set())}.


{pstd}
{it:s}{cmd:.lblnamelist()} obtains the {it:lblnamelist}, if any, from 
{it:str_to_parse}. In {it:lblnamelist} all value label names are 
unabbreviated; any value label attached to {it:varname} is added if it 
is indirectly specified. The function aborts with error if {it:lblname} 
or {cmd:(}{it:varlist}{cmd:)} is invalid.

{phang2}
{it:s}{cmd:.lblnamelist(0)} returns {it:lblnamelist} including empty 
columns if {it:s}{cmd:.strict()} included them; default is to omit 
those empty columns.

{pstd}
{it:s}{cmd:.newlblnamelist()}, if new, not yet defined, value labels 
are allowed in {it:elblnamelist}, returns any {it:lblname} in 
{it:elblnamelist} that could not be matched.

{phang2}
{it:s}{cmd:.newlblnamelist(0)} returns {it:newlblnamelist} including empty 
columns if {it:s}{cmd:.strict()} included them; default is to omit 
those empty columns.

{pstd}
{it:s}{cmd:.labelnamelist()} is a convenience function and returns 
{cmd:(}{it:s}{cmd:.lblnamelist(0)+}{it:s}{cmd:.newlblnamelist(0)}{cmd:)} 
if new, not yet defined, value labels are allowed in {it:elblnamelist}; 
otherwise it returns {it:s}{cmd:.lblnamelist(0)}.

{pstd}
{it:s}{cmd:.varvaluelabel()}, if {it:s}{cmd:.varvaluelabelok()}!=0 and 
{it:s}{cmd:.anythingok()}==0 and {it:s}{cmd:.broadmappings()}==0, returns 
a {it:rowvector} with elements {it:varname} [{it:varname ...}] 
[{it:new}]{it:lblname}{cmd:,} {it:...} from {it:elblnamelist} or 
{it:newlblnamelist}.

{pstd}
{it:s}{cmd:.anything()}, if {it:elblnamelist} may contain anything, 
obtains whatever is typed in {it:str_to_parse} in place of 
{it:elblnamelist} and {it:newlblnamelist} run together; contents are 
not checked but returned as typed. 

{pstd}
{it:s}{cmd:.mappings()} obtains the {it:mappings}, if any, from 
{it:str_to_parse}. Note that {it:mappings} are not checked for 
errors but returned as typed.

{pstd}
{it:s}{cmd:.iff_eexp()}, if {it:iffword}!="", obtains {it:eexp} following 
{it:iffword} (typically: {cmd:iff}), if any, from {it:str_to_parse}. The 
function aborts with error if {it:eexp} is invalid. 

{phang2}
{it:s}{cmd:.iff_eexp(0)} returns {it:iffword eexp}.

{pstd}
{it:s}{cmd:.filename()}, if {it:usingword}!="", obtains {it:filename} 
following {it:usingword} (typically: {cmd:using}), if any, from 
{it:str_to_parse}; {it:filename} is returned with quotes, if any.

{phang2}
{it:s}{cmd:.filename(0)} returns {it:usingword filename}.

{pstd}
{it:s}{cmd:.options()} obtains {it:options}, if any, from 
{it:str_to_parse}. Returned is {cmd:,} {it:options}, that is, a comma 
followed by a white space and {it:options} as typed; no checks are 
performed.

{phang2}
{it:s}{cmd:.options(0)} returns {it:options} without a leading comma 
and without leading white space.


{pstd}
{it:s}{cmd:.newlblnameok()} specifies whether {it:elblnamelist} may 
contain new, not yet defined, value label names ({it:val}!=0) or not 
({it:val}==0, the default). 

{phang2}
{it:s}{cmd:.newlblnamesok()} is a synonym.

{pstd}
{it:s}{cmd:.varvaluelabelok()} specifies whether 
{it:elblnamelist} (or {it:newlblnamelist}, if allowed) may contain 
variable-to-value-label-mappings of the form {it:varname}{cmd::}{it:lblname} 
({it:val}!=0) or not ({it:val}==0, the default). The full diagram for such 
mappings is 

{phang2}
{{cmd:(}{varlist}{cmd:)} | {varname}} {cmd::} {it:{help elabel##elblnamelist:elblname}}

{pstd}
where {it:elblname} must be exactly one value label name, and new, 
not yet defined, value label names are allowed according to 
{it:s}{cmd:.newlblnameok()}. You do not want to 
{it:s}{cmd:.varvaluelabelok(1)} if {it:s}{cmd:.anythingok()}!=0 or 
{it:s}{cmd:.broadmappings()}!=0.

{pstd}
{it:s}{cmd:.anythingok()} specifies whether {it:elblnamelist} may  
contain anything ({it:val}!=0) or not ({it:val}==0, the default).

{pstd}
{it:s}{cmd:.iffword()} specifies the keyword indicating an {cmd:iff} 
{it:eexp}. The default {it:iffword} is {cmd:"iff"}; if 
{it:iffword}=={cmd:""}, {cmd:iff} {it:eexp} is treated as part of 
{it:elblnamelist} or {it:mappings}.

{phang2}
If {help version} is set to less than 16, {it:iffword} defaults to 
{cmd:("if", "iff")}.

{pstd}
{it:s}{cmd:.usingword()} specifies the keyword indicating {cmd:using} 
{it:filename}. The default {it:usingword} is {cmd:""} and specifies 
that {cmd:using} {it:filename} is treated as part of {it:elblnamelist} 
or {it:mappings}. {it:usingword} should be {cmd:""} or {cmd:"using"}.

{pstd}
{it:s}{cmd:.strict()}, if {it:val!=0}, returns an empty column for 
each variable in {cmd:(}{it:varlist}{cmd:)} that has no value label 
attached. The default, {it:val}==0, exits with error if one of the 
variables in {cmd:(}{it:varlist}{cmd:)} has no value label attached.

{pstd}
{it:s}{cmd:.broadmappings()}, if {it:val}!=0, treats any element 
in {it:elblnamelist}, {it:newlblnamelist}, or {it:anything} that 
is not a name (possibly enclosed in parentheses and including 
wildcard characters) as part of {it:mappings}. Default is {it:val}==0 
and it is seldom changed.


{pstd}
{it:s}{cmd:.nomem()}, {it:s}{cmd:.mlang()}, and more are inherited from 
{helpb mf_elabel_unab_class:Elabel_Unab()}. If you call these functions, 
you also want to code {it:s}{cmd:.set(}{it:s}{cmd:.set())}.


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
