{smcl}
{cmd:help mata Elabel_ValueLabel()}
{hline}

{title:Title}

{phang}
{cmd:Elabel_ValueLabel()} {hline 2} Manipulate value label (class)


{title:Syntax}

{p 8 12 2}
{cmd:class Elabel_ValueLabel scalar} {it:l}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.setup(}{it:string scalar name}{cmd:)}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.setup(}{it:name}{cmd:,}
{it:real colvector vvec}{cmd:,}
{it:string colvector tvec}{cmd:)}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.reset()}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.reset(}{it:real colvector vvec}{cmd:,}
{it:string colvector tvec}{cmd:)}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.mark(}{it:real colvector touse}{cmd:)}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.markiff(}{it:string scalar expr}{cmd:)}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.markall()}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.define()}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.define(}{it:real scalar replace}[{cmd:,}
{it:real scalar fixformat}]{cmd:)}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.modify()}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.modify(}{it:real scalar add}[{cmd:,}
{it:real scalar fixformat}]{cmd:)}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.append(}[{it:real scalar fixformat}{cmd:,}
{it:string scalar sep}]{cmd:)}

{p 8 40 2}
{it:string scalar}{bind:                 }
{it:l}{cmd:.name()}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.name(}{it:string scalar newname}{cmd:)}

{p 8 40 2}
{it:real colvector}{bind:                }
{it:l}{cmd:.vvec()}

{p 8 40 2}
{it:string colvector}{bind:              }
{it:l}{cmd:.tvec()}

{p 8 40 2}
{it:real colvector}{bind:                }
{it:l}{cmd:.null()}

{p 8 40 2}
{it:real colvector}{bind:                }
{it:l}{cmd:.touse()}

{p 8 40 2}
{it:real scalar}{bind:                   }
{it:l}{cmd:.k()}

{p 8 40 2}
{it:real scalar}{bind:                   }
{it:l}{cmd:.K()}

{p 8 40 2}
{it:real scalar}{bind:                   }
{it:l}{cmd:.nemiss()}

{p 8 40 2}
{it:real scalar}{bind:                   }
{it:l}{cmd:.sysmiss()}

{p 8 40 2}
{it:string rowvector}{bind:              }
{it:l}{cmd:.usedby()}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.list()}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.list(}{it:values}{cmd:,} 
{it:text}[{cmd:,}
{it:real scalar noisily}]{cmd:)}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:._list(}[{it:real scalar includename}]{cmd:)}

{p 8 40 2}
{it:void}{bind:                          }
{it:l}{cmd:.assert_add()}


{title:Description}

{pstd}
{cmd:Elabel_ValueLabel()} returns instances of 
{cmd:class Elabel_ValueLabel}. {cmd:Elabel_ValueLabel()} extends
{helpb mf_elabel_utilities_class:Elabel_Utilities()}. The class is 
used for developing the {cmd:elabel} package. See 
{helpb mf_elabel_vl:elabel_vl{it:*}()} for the corresponding Mata 
functions.

{pstd}
{it:l}{cmd:.setup()} sets up value label {it:name}. If {it:name} is an 
existing value label, and if {it:vvec} and {it:tvec} are not specified, 
the integer-to-text mappings from {it:name} are loaded and stored in 
{it:l}. Specify {it:vvec} and {it:tvec} to create new interger to text 
mappings. Note that no changes are made to value label {it:name} until 
you {it:l}{cmd:.define()} or {it:l}{cmd:.modify()}. Think of {it:l} as a 
copy of existing value label {it:name} or as a blueprint for new value 
label {it:name}.

{pstd}
{it:l}{cmd:.reset()} replaces {it:vvec} and {it:tvec} in {it:l}. Without 
arguments, {it:vvec} is reset to {cmd:J(0, 1, .)} and {it:tvec} is reset 
to {cmd:J(0, 1, "")}. 

{pstd}
{it:l}{cmd:.mark()} specifies the integer values and text 
in {it:l} to be used by other functions. Default is 
{it:touse}={cmd:J(rows(}{it:vvec}{cmd:), 1, 1)}, meaning that 
all integer-to-text mappings are used.

{pstd}
{it:l}{cmd:.markiff()} is an alternative to {it:l}{cmd:.mark()}. Instead 
of specifying a {it:real colvector} you pass a {it:string scalar} containing 
an {it:{help elabel##elabel_eexp:eexp}} that evaluates to true (!=0) or false 
(==0) for each integer value and associated text. The function does nothing 
if {it:eexp}=={cmd:""}.

{pstd}
{it:l}{cmd:.markall()} is a convenience function, short for 
{it:l}{cmd:.mark(J(}{it:l}{cmd:.K(), 1, 1))}, and selects all 
integer values and text in {it:l}.

{pstd}
{it:l}{cmd:.define()} defines the value label {it:name} based on the 
information in {it:l}. If {it:replace}!=0 is specified, existing value 
label {it:name} is replaced. If {it:fixformat}!=0, the display format 
of variables that have value label {it:name} attached is changed; see 
{help label:option nofix}. This function respects {it:touse}.

{pstd}
{it:l}{cmd:.modify()} modifies the value label {it:name} based on the 
information in {it:l}. If {it:add}!=0 is specified, only new integer 
to text mappings may be added to existing value label {it:name}. If 
{it:fixformat}!=0, the display format of variables that have value label 
{it:name} attached is changed; see {help label:option nofix}. This 
function respects {it:touse}.

{pstd}
{it:l}{cmd:.append()} modifies the value label {it:name} based on the 
information in {it:l}. If {it:sep} is not specified, integer values 
in {it:l} must either not be present in existing value label {it:name}, 
or if they are present in {it:name}, must define the same integer-to-text 
mappings. If {it:sep} is specified, {it:sep} is used as separator to append 
any text that is associated with the same integer value. If {it:fixformat}!=0, 
the display format of variables that have value label {it:name} attached is 
changed; see {help label:option nofix}. This function respects {it:touse}.

{pstd}
{it:l}{cmd:.name()} without arguments returns the {it:name} stored in 
{it:l}. If {it:newname} is specified {it:name} in {it:l} is changed 
to {it:newname}.

{pstd}
{it:l}{cmd:.vvec()} returns {it:real colvector vvec} from {it:l}. This 
function respects {it:touse}.

{pstd}
{it:l}{cmd:.tvec()} returns {it:string colvector tvec} from {it:l}. This 
function respects {it:touse}.

{pstd}
{it:l}{cmd:.null()} returns a {it:real colvector} indicating the rows of 
{it:tvec} that are empty, i.e., null strings. This function respects 
{it:touse}.

{pstd}
{it:l}{cmd:.touse()} returns a {it:real colvector} indicating the rows 
of {it:vvec} and {it:tvec} to be used.

{pstd}
{it:l}{cmd:.k()} returns the number of integer-to-text mappings in 
{it:l}. This function respects {it:touse}.

{pstd}
{it:l}{cmd:.K()} (note capitalization) returns the number of integer 
to text mappings in {it:l}, ignoring {it:touse}.

{pstd}
{it:l}{cmd:.nemiss()} returns the number of extended missing values in 
{it:vvec}. This function respects {it:touse}.

{pstd}
{it:l}{cmd:.sysmiss()} returns a {it:real scalar} indicating whether 
{it:vvec} has system missing values. System missing values are usually 
considered an error in value labels but Mata allows them. This function 
respects {it:touse}.

{pstd}
{it:l}{cmd:.usedby()} returns a {it:string rowvector} of variable names 
that have value label {it:name} attached (in the current label 
language). 

{p 8 8 2}{...}
The function has an optional argument, {it:update}, that is best not 
specified. If {it:update}==0, {it:l}{cmd:.usedby(0)} returns the 
{it:string rowvector} that has previously been obtained from {it:l}, 
which might or might not be related to {it:name}; when you 
{it:l}{cmd:.reset()} or even {it:l}{cmd:.setup()} another {it:name}, 
the result from {it:l}{cmd:.usedby(0)} will still be the same 
{it:string colvector} that you have previously obtained.

{pstd}
{it:l}{cmd:.list()} and 
{it:l}{cmd:.list(}{it:values}{cmd:,} {it:text}[{cmd:,} {it:noisily}]{cmd:)} 
both list the {it:name} and integer-to-text mappings in {it:l} in the same 
format as Stata's {helpb label:label list}. The types of {it:values} and 
{it:text} are irrelevant because they are replaced with {it:string scalars} 
holding the integer values and text in {it:l}, respectively. If 
{it:noisily}==0, output is suppressed. These functions respect {it:touse}.

{pstd}
{it:l}{cmd:._list()} is called by {it:l}{cmd:.list()}; if 
{it:includename}==0, the value label name is not listed. The function 
respects {it:touse}.

{pstd}
{it:l}{cmd:.assert_add()} exits with the respective Stata error message 
if any of the values in {it:vvec} is already defined in the value label 
stored in {it:l}. This function respects {it:touse}.


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
