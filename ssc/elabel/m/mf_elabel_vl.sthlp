{smcl}
{cmd:help mata elabel_vl{it:*}()}
{hline}

{title:Title}

{phang}
{cmd:elabel_vl{it:*}()} {hline 2} Manipulate value label


{title:Syntax}

{p 8 38 2}
({it:transmorphic}){bind:   }
{it:vl} {cmd:= elabel_vlinit(}{it:string scalar name}{cmd:)}

{p 8 38 2}
({it:transmorphic}){bind:   }
{it:vl} {cmd:= elabel_vlinit(}{it:name}{cmd:,}
{it:real colvector values}{cmd:,}
{it:string colvector labels}{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vlcopy(}{it:vl}{cmd:,} {it:vl2}{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vlset(}{it:vl}{cmd:,} {it:real colvector values}{cmd:,}
{it:string colvector labels}{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vlmark(}{it:vl}{cmd:,} {it:real colvector touse}{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vlmarkiff(}{it:vl}{cmd:,} {it:string scalar eexp}{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vlmarkall(}{it:vl}{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vldefine(}{it:vl}{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vldefine(}{it:vl}{cmd:,} {it:real scalar replace}[{cmd:,}
{it:real scalar fixformat}]{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vlmodify(}{it:vl}{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vlmodify(}{it:vl}{cmd:,} {it:real scalar add}[{cmd:,}
{it:real scalar fixformat}]{cmd:)}

{p 8 38 2}
{it:string scalar}{bind:    }
{cmd:elabel_vlname(}{it:vl}{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vlname(}{it:vl}{cmd:,} {it:string scalar newname}{cmd:)}

{p 8 38 2}
{it:real colvector}{bind:   }
{cmd:elabel_vlvalues(}{it:vl}{cmd:)}

{p 8 38 2}
{it:string colvector}{bind: }
{cmd:elabel_vllabels(}{it:vl}{cmd:)}

{p 8 38 2}
{it:real colvector}{bind:   }
{cmd:elabel_vlnull(}{it:vl}{cmd:)}

{p 8 38 2}
{it:real colvector}{bind:   }
{cmd:elabel_vltouse(}{it:vl}{cmd:)}

{p 8 38 2}
{it:real scalar}{bind:      }
{cmd:elabel_vlk(}{it:vl}{cmd:)}

{p 8 38 2}
{it:real scalar}{bind:      }
{cmd:elabel_vlK(}{it:vl}{cmd:)}

{p 8 38 2}
{it:real scalar}{bind:      }
{cmd:elabel_vlnemiss(}{it:vl}{cmd:)}

{p 8 38 2}
{it:real scalar}{bind:      }
{cmd:elabel_vlsysmiss(}{it:vl}{cmd:)}

{p 8 38 2}
{it:string rowvector}{bind: }
{cmd:elabel_vlusedby(}{it:vl}{cmd:)}

{p 8 38 2}
{it:void}{bind:             } 
{cmd:elabel_vllist(}{it:vl}{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vllist(}{it:vl}{cmd:,} {it:values}{cmd:,} {it:labels}{cmd:)}

{p 8 38 2}
{it:void}{bind:             } 
{cmd:elabel_vllistmappings(}{it:vl}{cmd:)}

{p 8 38 2}
{it:void}{bind:             }
{cmd:elabel_vlassert_add(}{it:vl}{cmd:)}


{title:Description}

{pstd}
{cmd:elabel_vl{it:*}()} functions manipulate value labels. Technically, the 
functions access the elements in 
{helpb mf_elabel_valuelabel_class:class Elabel_ValueLabel} and are provided 
so the class does not have to be used directly; see 
{help elabel_development:elabel development}.

{pstd}
{cmd:elabel_vlinit()} returns {it:vl} that you pass to the other 
{cmd:elabel_vl{it:*}()} functions; if you declare {it:vl}, declare it 
{it:transmorphic}. In {it:vl}, if {it:name} is an existing value label, 
and if {it:values} and {it:labels} are not specified, the integer to 
text mappings from {it:name} are loaded. Specify {it:values} and 
{it:labels} to define new integer-to-text mappings. Note that no 
changes are made to value label {it:name} until you 
{cmd:elabel_vldefine(}{it:vl}{cmd:)} or 
{cmd:elabel_vlmodify(}{it:vl}{cmd:)}. Think of {it:vl} as a copy of existing 
value label {it:name} or as a blueprint for new value label {it:name}.

{pstd}
{cmd:elabel_vlcopy()} copies {it:vl} to {it:vl2}; if you declare {it:vl2}, 
declare it {it:transmorphic}. This function respects {it:touse}.

{pstd}
{cmd:elabel_vlset()} replaces {it:values} and {it:labels} in {it:vl}. 

{pstd}
{cmd:elabel_vlmark()} specifies the integer values and text 
in {it:vl} to be used by other functions. Default is 
{it:touse}={cmd:J(rows(}{it:values}{cmd:), 1, 1)}, meaning that 
all integer-to-text mappings are used.

{pstd}
{cmd:elabel_vlmarkiff()} is an alternative to {cmd:elabel_vlmark()}. Instead 
of specifying a {it:real colvector} you pass a {it:string scalar} containing 
an {it:{help elabel##elabel_eexp:eexp}} that evaluates to true (!=0) or false 
(==0) for each integer value and associated text. The function does nothing 
if {it:eexp}=={cmd:""}.

{pstd}
{cmd:elabel_vlmarkall()} is a convenience function and specifies that all 
values and text in {it:vl} are used by other functions.

{pstd}
{cmd:elabel_vldefine()} defines the value label {it:name} based on the 
information in {it:vl}. If {it:replace}!=0 is specified, existing value 
label {it:name} is replaced. If {it:fixformat}!=0, the display format 
of variables that have value label {it:name} attached is changed; see 
{help label:option nofix}. This function respects {it:touse}.

{pstd}
{cmd:elabel_vlmodify()} modifies the value label {it:name} based on the 
information in {it:vl}. If {it:add}!=0 is specified, only new integer 
to text mappings may be added to existing value label {it:name}. If 
{it:fixformat}!=0, the display format of variables that have value label 
{it:name} attached is changed; see {help label:option nofix}. This 
function respects {it:touse}.

{pstd}
{cmd:elabel_vlname()} without arguments returns the {it:name} stored in 
{it:vl}. If {it:newname} is specified {it:name} in {it:vl} is changed 
to {it:newname}; remember that value labels are neither defined nor 
modified until you {cmd:elabel_vldefine(}{it:vl}{cmd:)} or 
{cmd:elabel_vlmodify(}{it:vl}{cmd:)}. 

{pstd}
{cmd:elabel_vlvalues()} returns {it:real colvector values} from {it:vl}. This 
function respects {it:touse}.

{pstd}
{cmd:elabel_vllabels()} returns {it:string colvector labels} from {it:vl}. This 
function respects {it:touse}.

{pstd}
{cmd:elabel_vlnull()} returns a {it:real colvector} indicating the rows of 
{it:labels} that are empty, i.e., null strings. This function respects 
{it:touse}.

{pstd}
{cmd:elabel_vltouse()} returns a {it:real colvector} indicating the rows 
of {it:values} and {it:labels} to be used.

{pstd}
{cmd:elabel_vlk()} returns the number of integer-to-text mappings in 
{it:vl}. This function respects {it:touse}.

{pstd}
{cmd:elabel_vlK()} (note capitalization) returns the number of integer 
to text mappings in {it:vl}, ignoring {it:touse}.

{pstd}
{cmd:elabel_vlnemiss()} returns the number of extended missing values in 
{it:values}. This function respects {it:touse}.

{pstd}
{cmd:elabel_vlsysmiss()} returns a {it:real scalar} indicating whether 
{it:values} has system missing values. System missing values are usually 
considered an error in value labels but Mata allows them. This function 
respects {it:touse}.

{pstd}
{cmd:elabel_vlusedby()} returns a {it:string rowvector} of variable names 
that have value label {it:name} attached (in the current label 
language). 

{pstd}
{cmd:elabel_vllist()} and 
{cmd:elabel_vllist(}{it:values}{cmd:,} {it:labels}{cmd:)} both list the 
{it:name} and integer-to-text mappings in {it:vl} in the same format as 
Stata's {helpb label:label list}. The types of {it:values} and {it:labels} 
are irrelevant because they are replaced with {it:string scalars} 
holding the integer values and labels in {it:vl}, respectively. These 
functions respect {it:touse}.

{pstd}
{cmd:elabel_vllistmappings()} list only the integer-to-text mappings in 
{it:vl}, exclding the {it:name}. This function respects {it:touse}.

{pstd}
{cmd:elabel_vlassert_add()} exits with the respective Stata error message 
if any of the values in {it:values} is already defined in the value label 
stored in {it:vl}. This function respects {it:touse}.


{title:Conformability}

{pstd}
As indicated above.

		 
{title:Diagnostics}

{pstd}
Not documented in detail; functions are provided for convenience. If there is 
a problem with the arguments that you pass, the functions typically exit with 
Mata error messages and produce traceback logs. {cmd:elabel_vlinit()}, 
{cmd:elabel_vldefine()}, and  {cmd:elabel_vlmodify()} exit with Stata error 
messages if a problem occurs. If {it:name} or {it:newname} are not valid 
Stata names, the respective Stata error message is issued.


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
