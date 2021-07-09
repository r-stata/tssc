{smcl}
{cmd:help mata elabel_u_}{it:*}{cmd:()}
{hline}

{title:Title}

{phang}
{cmd:mata elabel_u_}{it:*}{cmd:()} {hline 2} {cmd:elabel} utility functions


{title:Syntax}

{p 8 28 2}
{it:(varies)}{bind:        }
{cmd:elabel_u_assert_lblname(}{it:string rowvector namelist}[{cmd:,}
{it:real scalar err}]{cmd:)}

{p 8 28 2}
{it:(varies)}{bind:        }
{cmd:elabel_u_assert_name(}{it:string rowvector namelist}[{cmd:,}
{it:real scalar err}]{cmd:)}

{p 8 28 2}
{it:(varies)}{bind:        }
{cmd:elabel_u_assert_newlblname(}{it:string rowvector namelist}[{cmd:,}
{it:real scalar err}]{cmd:)}

{p 8 28 2}
{it:(varies)}{bind:        }
{cmd:elabel_u_assert_uniq(}{it:string rowvector list}[{cmd:,}
{it:transmorphic scalar arg}]{cmd:)}


{p 8 28 2}
{it:colvector}{bind:       }
{cmd:elabel_u_eexp(}{it:string scalar eexp}{cmd:,} 
{it:real colvector hash}{cmd:,} {it:string colvector at}{cmd:)}


{p 8 28 2}
{it:string scalar}{bind:   }
{cmd:elabel_u_get_varlabel(}{it:transmorphic scalar var}{cmd:,} 
{it:string scalar lang}{cmd:)}

{p 8 28 2}
{it:string scalar}{bind:   }
{cmd:elabel_u_get_varvaluelabel(}{it:transmorphic scalar var}{cmd:,} 
{it:string scalar lang}{cmd:)}


{p 8 28 2}
{it:real scalar}{bind:     }
{cmd:elabel_u_iseexp(}{it:string scalar s}{cmd:,} 
{it:r1}{cmd:)}

{p 8 28 2}
{it:real scalar}{bind:     }
{cmd:elabel_u_isgmappings(}{it:string scalar s}{cmd:,} 
{it:r1}{cmd:,} {it:r2}{cmd:)}


{p 8 28 2}
{it:void}{bind:            }
{cmd:elabel_u_parse_rules(}{it:string scalar rules}{cmd:,} 
{it:from}{cmd:,}
{it:to}{cmd:,}
{it:text}[{cmd:,}
{it:null}{cmd:,}
{it:recode_rules}]{cmd:)}


{p 8 28 2}
{it:void}{bind:            }
{cmd:elabel_u_st_syntax(}{it:string scalar 0}[{cmd:,} 
{it:string scalar descr_of_syntax}{cmd:,} 
{it:capture}]{cmd:)}


{p 8 28 2}
{it:string scalar}{bind:   }
{cmd:elabel_u_tokenget_inpar(}{it:t}[{cmd:,}
{it:real scalar pars}{cmd:,} {it:rc}]{cmd:)}

{p 8 28 2}
{it:string rowvector}{bind:}
{cmd:elabel_u_tokensq(}{it:string scalar s}{cmd:)}


{p 8 28 2}
{it:string rowvector}{bind:}
{cmd:elabel_u_usedby(}{it:string rowvector lblnamelist}[{cmd:,}
{it:real scalar mlang}]{cmd:)}


{title:Description}

{pstd}
These functions are primarily used for developing the {cmd:elabel} 
package but might be of interest to programmers.


{pstd}
{cmd:elabel_u_assert_lblname()} issues a Stata error message if any 
of the value labels in {it:namelist} is not defined in memory or if 
any of {it:namelist} is an invalid name. If {it:err}==0, the function 
never exits with error but returns whether the assertion is true (==1) 
or false (==0).

{pstd}
{cmd:elabel_u_assert_name()} issues a Stata error message if any of 
{it:namelist} is not a valid name. If {it:err}==0, the function never 
exits with error but returns whether the assertion is true (==1) or 
false (==0).

{pstd}
{cmd:elabel_u_assert_newlblname()} issues a Stata error message if 
any of {it:namelist} is an already defined value label or if any of 
{it:namelist} is an invalid name. If {it:err}==0, the function never 
exits with error but returns whether the assertion is true (==1) or 
false (==0).

{pstd}
{cmd:elabel_u_assert_uniq()} does nothing if {it:list} has no duplicate 
elements. In {it:list}, any columns containing null string ({cmd:""}) or 
only white spaces ({cmd:" "}) are ignored. If {it:list} has duplicate 
elements, and if {it:arg} is {it:string scalar}, the functions issues the 
Stata error message {err:{it:arg first_duplicate} mentioned more than once} 
and exits with return code 110; if {it:arg} is not specified the function 
exits with return code 198. If {it:arg}==0, the function never exits with 
error but returns whether the assertion is true (==1) or false (==0).


{pstd}
{cmd:elabel_u_eexp()} returns {it:eexp} with all {cmd:#} characters 
replaced with {it:hash} and all {cmd:@} characters replaced with 
{it:at}. If Stata cannot evaluate {it:eexp}, the function exits with 
the respective Stata error message.


{pstd}
{cmd:elabel_u_get_varlabel()} returns the variable label of {it:var} in 
label language {it:lang}, where {it:lang} is not the current label 
language. {it:var} may be of type {it:string} or {it:real} and specifies a 
variable name or variable index. The function returns {cmd:""} if {it:var} 
has no variable label in {it:lang}, if {it:lang} is the current label 
language, or if {it:lang} is not a label language. Omitting {it:lang} or 
{it:lang}={cmd:""} returns the variable label of {it:var} in the current 
label language. If {it:var} is not {it:string} or {it:real}, or if 
1>{it:var}>{helpb mf_st_nvar:st_nvar()}, the function produces a Mata 
traceback log. 

{pstd}
{cmd:elabel_u_get_varvaluelabel()} returns the value label name that 
is attached to {it:var} in label language {it:lang}, where {it:lang} is not 
the current label language. {it:var} may be of type {it:string} or {it:real} 
and specifies a variable name or variable index. The function returns {cmd:""} 
if {it:varid} has no value label attached in {it:lang}, if {it:lang} is the 
current label language, or if {it:lang} is not a label language. Omitting 
{it:lang} or {it:lang}={cmd:""} returns the value label name that is attached 
to {it:var} in the current label language. If {it:var} is not {it:string} or 
{it:real}, or if 1>{it:var}>{helpb mf_st_nvar:st_nvar()}, the function 
produces a Mata traceback log. 

{pstd}
{cmd:elabel_u_iseexp()} returns 1 if {it:s} is {cmd:=} {it:...} and 
returns 0 otherwise. If the function returns 1, {it:r1} is replaced 
with a {it:string scalar} containing everything that follows the 
equals sign.

{pstd}
{cmd:elabel_u_isgmappings()} returns 1 if {it:s} is 
{cmd:(}{it:...}{cmd:)(}{it:...}{cmd:)} and returns 0 otherwise. If 
the function returns 1, {it:r1} is replaced with a {it:string scalar} 
containing the contents found within the first pair of parentheses; 
{it:r2} is replaced with the contents found in the second pair of 
parentheses.


{pstd}
{cmd:elabel_u_parse_rules()} parses {it:rules} of the form 
{cmd:(}{it:from_numlist} {cmd:=} {it:to_numlist} 
[{cmd:"}{it:label}{cmd:"} [{it:...}]]{cmd:)} {it:...}, and returns the 
respective elements. If {it:null} is specified, it contains information 
whether elements of {it:text} are null strings. If {it:recode_rules} is 
specified, it is filled with {cmd:(}{it:#}{cmd:=}{it:#}{cmd:)} {it:...}, 
i.e., {it:rules} in a format that can be passed to the {helpb recode} 
command. The function exist with Stata error messages if {it:rules} are 
invalid.


{pstd}
{cmd:elabel_u_st_syntax()} puts {it:0} into Stata local {cmd:0} and 
executes {helpb syntax} with {it:dos} ({it:description_of_syntax}). The 
type of {it:capture} is irrelevant and it is replaced with a 
{it:real scalar} containing the Stata return code. If {it:capture} is 
specified, any output from {cmd:syntax} is suppressed.


{pstd}
{cmd:elabel_u_tokenget_inpar()} expectes a parsing environment obtained 
from {helpb tokenget:tokeninit()}. The function obtains from {it:t} the 
next token defined as everything enclosed in parentheses, including the 
parentheses themselves. The string in {it:t} is expected to be of the 
form {cmd:({it:...})}[{cmd:{it:...}}] and if it is not, the function 
exits with error, unless {it:rc} is specified. More specifically, if 
{it:rc} is not specified, the function produces a Mata traceback log if 
the string in {it:t} does not start with an open parenthesis. The function 
issues an unbalanced parenthesis error if parentheses are unbalanced. If 
{it:rc} is specified, the function does not exit with error; it replaces 
{it:rc} with 0 if there is no problem, with 132 if there is an unmatched 
open parenthesis and with -132 if the string in {it:t} does not start with
an open parenthesis. If {it:par}=0, the returned token is not enclosed in 
parentheses.

{pstd}
{cmd:elabel_u_tokensq()} returns the tokens in {it:s}, preserving (nested) 
double quotes.


{pstd}
{cmd:elabel_u_usedby()} returns a rowvector of variable names that have one  
of the value labels in {it:lblnamelist} attached (in any label language). If 
{it:mlang}=0, only the current label language is considered. {it:lblnamelist} 
may contain non-existing value label names; actually, {it:lblnamelist} may 
contain any string. If {it:lblnamelist} contains {cmd:""}, the function 
returns all (numeric) variabels that do not have a value label attached. The 
returned variable names are unique.


{title:Conformability}

{pstd}
As indicated above.

		 
{title:Diagnostics}

{pstd}
Not documented; functions are for internal use.


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
