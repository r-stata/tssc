{smcl}
{cmd:help mata Elabel_Utilities()}
{hline}

{title:Title}

{phang}
{cmd:Elabel_Utilities()} {hline 2} Utility tools for {cmd:elabel} (class)


{title:Syntax}

{p 8 40 2}
{cmd:class Elabel_Utilities scalar} {it:u}

{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_assert0(}[{it:string scalar where}]{cmd:)}

{p 8 40 2}
{it:(varies)}{bind:                     }
{it:u}{cmd:.u_assert_lblname(}{it:string rowvector namelist}[{cmd:,}
{it:real scalar err}]{cmd:)}

{p 8 40 2}
{it:(varies)}{bind:                     }
{it:u}{cmd:.u_assert_name(}{it:string rowvector namelist}[{cmd:,}
{it:real scalar err}]{cmd:)}

{p 8 40 2}
{it:(varies)}{bind:                     }
{it:u}{cmd:.u_assert_newfile(}{it:string scalar fn}{cmd:,}
{it:real scalar replace}[{cmd:,}
{it:real scalar err}]{cmd:)}

{p 8 40 2}
{it:(varies)}{bind:                     }
{it:u}{cmd:.u_assert_newlblname(}{it:string rowvector namelist}[{cmd:,}
{it:real scalar err}]{cmd:)}

{p 8 40 2}
{it:(varies)}{bind:                     }
{it:u}{cmd:.u_assert_nosysmiss(}{it:real vector v}[{cmd:,}
{it:real scalar err}]{cmd:)}

{p 8 40 2}
{it:(varies)}{bind:                     }
{it:u}{cmd:.u_assert_uniq(}{it:string rowvector list}[{cmd:,}
{it:transmorphic scalar arg}]{cmd:)}


{p 8 40 2}
{it:string matrix}{bind:                }
{it:u}{cmd:.u_bslsq(}{it:string matrix s}{cmd:)}


{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_err_alreadydefined(}{it:string scalar item}[{cmd:,}
{it:string scalar what}]{cmd:)}

{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_err_expected(}{it:string scalar expected}[{cmd:,}
{it:string scalar found}]{cmd:)}

{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_err_fewmany(}{it:real scalar fewmany}{cmd:,}
{it:string scalar what}{cmd:)}

{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_err_notallowed(}{it:string scalar item}[{cmd:,}
{it:string scalar what}]{cmd:)}

{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_err_notfound(}{it:string scalar item}[{cmd:,}
{it:string scalar what}]{cmd:)}

{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_err_numlist(}[{it:real scalar rc}{cmd:,}
{it:string scalar nlist}]{cmd:)}

{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_err_required(}{it:string scalar item}{cmd:,}
{it:string scalar what}{cmd:)}

{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_err_unbalanced(}{it:string scalar par}{cmd:)}

{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_exerr(}{it:real scalar rc}{cmd:,}
{it:string scalar msg}[{cmd:,} {it:string scalar arg}]{cmd:)}


{p 8 40 2}
{it:string scalar}{bind:                }
{it:u}{cmd:.u_get_varlabel(}{it:scalar var}{cmd:,}
{it:string scalar lang}{cmd:)}

{p 8 40 2}
{it:string scalar}{bind:                }
{it:u}{cmd:.u_get_varvaluelabel(}{it:scalar var}{cmd:,}
{it:string scalar lang}{cmd:)}


{p 8 40 2}
{it:string scalar}{bind:                }
{it:u}{cmd:.u_invtoken(}{it:string rowvector s}{cmd:)}

{p 8 40 2}
{it:real scalar}{bind:                  }
{it:u}{cmd:.u_iseexp(}{it:string scalar s}[{cmd:,} 
{it:r1}]{cmd:)}

{p 8 40 2}
{it:real scalar}{bind:                  }
{it:u}{cmd:.u_isgmappings(}{it:string scalar s}[{cmd:,} 
{it:r1}{cmd:,} {it:r2}]{cmd:)}

{p 8 40 2}
{it:real scalar}{bind:                  }
{it:u}{cmd:.u_ispfcn(}{it:string scalar s}{cmd:,} 
{it:r1}{cmd:,} {it:r2}[{cmd:,} {it:r3}]{cmd:)}

{p 8 40 2}
{it:transmorphic}{bind:                 }
{it:u}{cmd:.u_selectnm(}{it:transmorphic vector x}[{cmd:,} 
{it:real scalar asvec}]{cmd:)}

{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_st_exe(}{it:string scalar cmd}[{cmd:,} 
{it:real scalar nooutput}]{cmd:)}

{p 8 40 2}
{it:void}{bind:                         }
{it:u}{cmd:.u_st_syntax(}{it:string scalar 0}[{cmd:,} 
{it:string scalar dos}{cmd:,} {it:rc}]{cmd:)}

{p 8 40 2}
{it:string scalar}{bind:                }
{it:u}{cmd:.u_strip_wildcards(}{it:string scalar s}[{cmd:,}
{it:haswc}]{cmd:)}

{p 8 40 2}
{it:string rowvector}{bind:             }
{it:u}{cmd:.u_st_numvarlist(}{it:string scalar s}{cmd:)}


{p 8 40 2}
{it:string scalar}{bind:                }
{it:u}{cmd:.u_tokenget_inpar(}{it:t}[{cmd:,}
{it:real scalar pars}{cmd:,} {it:rc}]{cmd:)}

{p 8 40 2}
{it:string rowvector}{bind:             }
{it:u}{cmd:.u_tokensq(}{it:string scalar s}{cmd:)}


{p 8 40 2}
{it:real scalar}{bind:                  }
{it:u}{cmd:.u_unabbr(}{it:string scalar abbr}{cmd:,}
{it:string scalar full}{cmd:)}


{title:Description}

{pstd}
{cmd:Elabel_Utilities()} returns instances of 
{cmd:class Elabel_Utilities}. The class is used for developing 
the {cmd:elabel} package.


{pstd}
{it:u}{cmd:.u_assert0()} displays 
{err:elabel unexpected error}[ {err:in {it:where}}] and exists
with return code 42.

{pstd}
{it:u}{cmd:.u_assert_lblname()} issues a Stata error message if any 
of the value labels in {it:namelist} is not defined in memory or if 
any of {it:namelist} is an invalid name. If {it:err}==0, the function 
never exists with error but returns whether the assertion is true (==1) 
or false (==0).

{pstd}
{it:u}{cmd:.u_assert_name()} issues a Stata error message if any of 
{it:namelist} is not a valid name. If {it:err}==0, the function never 
exists with error but returns whether the assertion is true (==1) or 
false (==0).

{pstd}
{it:u}{cmd:.u_assert_newfile()} issues a Stata error message if {it:fn} 
exists and {it:replace}==0; if {it:replace==1} and {it:fn} does not exist, 
the function prints a notification. If {it:err}==0, the function executes 
quietly, never exists with error, and returns whether the assertion is 
true (==1) or false (==0).

{pstd}
{it:u}{cmd:.u_assert_newlblname()} issues a Stata error message if 
any of {it:namelist} is an already defined value label or if any of 
{it:namelist} is an invalid name. If {it:err}==0, the function never 
exists with error but returns whether the assertion is true (==1) or 
false (==0).

{pstd}
{it:u}{cmd:.u_assert_nosysmiss()} issues the Stata error message 
{err:invalid attempt to modify label} and exist with return code 180 
if {it:v} contains system missing values. If {it:err}==0, the function 
never exists with error but returns whether the assertion is true (==1) 
or false (==0).

{pstd}
{it:u}{cmd:.u_assert_uniq()} does nothing if {it:list} has no duplicate 
elements. In {it:list}, any columns containing null string ({cmd:""}) or 
only white spaces ({cmd:" "}) are ignored. If {it:list} has duplicate 
elements, and if {it:arg} is {it:string scalar}, the functions issues the 
Stata error message {err:{it:arg first_duplicate} mentioned more than once} 
and exists with return code 110; if {it:arg} is not specified the function 
exists with return code 198. If {it:arg}==0, the function never exists with 
error but returns whether the assertion is true (==1) or false (==0).


{pstd}
{it:u}{cmd:.u_bslsq()} returns {it:s} with all single left quotes ({cmd:`}) 
prefixed with a backslash; the function replaces {cmd:`} with {cmd:\`}.


{pstd}
{it:u}{cmd:.u_err_alreadydefined()} issues the error message 
{err:{it:what item} already defined} and exists with return code 110; 
{it:what} defaults to {cmd:value label}.

{pstd}
{it:u}{cmd:.u_err_expected()} issues the error message 
{err:'{it:found}' where {it:expected} expected} and exits with 
return code 198.

{pstd}
{it:u}{cmd:.u_err_fewmany()} does nothing if {it:fewmany}==0 and issues 
the error message {err:too {few|many} {it:what} specified} otherwise; if 
{it:fewmany}<0 the word {cmd:few} is used; if {it:fewmany}>0 the word 
{cmd:many} is used.

{pstd}
{it:u}{cmd:.u_err_notallowed()} does nothing if {it:item}=="". Otherwise, 
the function issues the error message {err:{{it:what}|{it:item}} not allowed} 
and exists with return code 101.

{pstd}
{it:u}{cmd:.u_err_notfound()} issues the error message 
{err:{it:what item} not found} and exists with return code 111; 
{it:what} defaults to {cmd:value label}.

{pstd}
{it:u}{cmd:.u_err_numlist()} issues the error message 
{err:{it:nlist} -- invalid numlist} followed by the full error 
message specific to {it:rc}; the latter defaults to 121.

{pstd}
{it:u}{cmd:.u_err_required()} does nothing if {it:item}!="". Otherwise, 
the functions issues the error message {err:{it:what} required} and exists 
with return code 100.

{pstd}
{it:u}{cmd:.u_err_unbalanced()} issues the error message 
{err:unmatched {open|close} parenthesis} and exists with return code 132; 
if {it:par}={cmd:(} the word open is used; if {it:par}={cmd:)} the word 
close is used. The function exists with error and produces a Mata 
traceback log if {it:par} is not one of {cmd:(} or {cmd:)}.

{pstd}
{it:u}{cmd:.u_exerr()} issues the specified error message ({it:msg}) 
just like {helpb mata_errprintf:errprintf()} but with a maximum of one 
argument, {it:arg}; the function exits with the specified return code 
({it:rc}).


{pstd}
{it:u}{cmd:.u_get_varlabel()} returns the variable label of {it:var} in 
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
{it:u}{cmd:.u_get_varvaluelabel()} returns the value label name that 
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
{it:u}{cmd:.u_invtoken()} returns the elements of {it:s} 
concatenated into a string scalar. The function returns 
{cmd:""} if {it:s}={cmd:J(0, 0, "")}; otherwise it returns 
{cmd:invtokens(u_selectnm(}{it:s}{cmd:))} (see below).

{pstd}
{it:u}{cmd:.u_iseexp()} returns 1 if {it:s} is {cmd:=} {it:...} and 
returns 0 otherwise. If the function returns 1, {it:r1} is replaced 
with a {it:string scalar} containing everything that follows the 
equals sign.

{pstd}
{it:u}{cmd:.u_isgmappings()} returns 1 if {it:s} is 
{cmd:(}{it:...}{cmd:)(}{it:...}{cmd:)} and returns 0 otherwise. If 
the function returns 1, {it:r1} is replaced with a {it:string scalar} 
containing the contents found within the first pair of parentheses; 
{it:r2} is replaced with the contents found in the second pair of 
parentheses.

{pstd}
{it:u}{cmd:.u_ispfcn()} returns 1 if {it:s} is 
{cmd:= {it:fcn}({it:...})}[{cmd:{it:...}}] and if 
{cmd:elabel_fcn_{it:fcn}} is a program in memory or stored as an 
ado-file; {it:r1} is replaced with a {it:string scalar} containing 
{cmd:{it:fcn}} and {it:r2} contains {cmd:{it:...}}, i.e., whatever 
follows the open parenthesis with the matching close parenthesis 
removed. If {it:r3} is specified, {it:r2} contains only the contents 
enclosed in parentheses, but not the parentheses; {it:r3} contains 
whatever follows the close parenthesis. The function returns 0 if {it:s} 
does not have the expected form. If {it:s} has the expected form but 
{cmd:elabel_fcn_{it:fcn}} is not found, the function exists with the 
respective error message and return code 133. If {it:s} has the expected 
form and {cmd:elabel_fcn_{it:fcn}} is found but {it:r3} is not any of 
{{cmd:iff}|{cmd:if}|{cmd:in}|{cmd:,{it:...}}}, the function exits with 
an error message and sets the return code to 198.


{pstd}
{it:u}{cmd:.u_selectnm()} selects the non-missing elements from {it:x}. If 
{it:x}={cmd:J(}{it:r}{cmd:, 0,} {it:val}{cmd:)}, the function returns 
{cmd:J(1, 0, missingof(}{it:x}{cmd:))}; if {it:x}={cmd:J(0,} {it:c}{cmd:,} 
{it:val}{cmd:)}, the function returns {cmd:J(0, 1, missingof(}{it:x}{cmd:))}; 
if {it:asvec}==0 and if {it:x}=={cmd:missingof(}{it:x}{cmd:)}, the function 
returns {it:x}. Typical usage is 
{cmd:invtokens(u_selectnm(}{it:x}{cmd:, 0))} to avoid conformability errors.

{pstd}
{it:u}{cmd:.u_st_exe()} is a convenience function; the code is:
{cmd:if ( rc=_stata(cmd, nooutput) ) exit(rc)}.

{pstd}
{it:u}{cmd:.u_st_syntax()} puts {it:0} into Stata local {cmd:0} and 
executes {helpb syntax} with {it:dos} ({it:description_of_syntax}). The 
type of {it:capture} is irrelevant and it is replaced with a 
{it:real scalar} containing the Stata return code. If {it:capture} is 
specified, any output form {cmd:syntax} is suppressed. 

{pstd}
{it:u}{cmd:.u_strip_wildcards()} returns {it:s} with all {cmd:*} and 
{cmd:~} removed, and all {cmd:?} changed to {cmd:_}. If specified, 
{it:haswc} is replaced with a {it:real scalar} indicating whether 
{it:name} contains any wildcard characters.

{pstd}
{it:u}{cmd:.u_st_numvarlist()} calls 
{it:u}{cmd:.u_st_syntax(}{it:s}{cmd:, "varlist(numeric)")} and returns 
the expanded {it:varlist} from Stata. If there are string variables in 
{it:varlist}, the function exits with error 
{search r(181), local:r(181)}; if there is another problem, the function 
exits with the respective error message.


{pstd}
{it:u}{cmd:.u_tokenget_inpar()} expectes a parsing environment obtained 
from {helpb tokenget:tokeninit()}. The function obtains from {it:t} the 
next token defined as everything enclosed in parentheses, including the 
parentheses themselves. The string in {it:t} is expected to be of the 
form {cmd:({it:...})}[{cmd:{it:...}}] and if it is not, the function 
exists with error, unless {it:rc} is specified. More specifically, if 
{it:rc} is not specified, the function produces a Mata traceback log if 
the string in {it:t} does not start with an open parenthesis. The function 
issues an unbalanced parenthesis error if parentheses are unbalanced. If 
{it:rc} is specified, the function does not exit with error; it replaces 
{it:rc} with 0 if there is no problem, with 132 if there is an unmatched 
open parenthesis and with -132 if the string in {it:t} does not start with
an open parenthesis. If {it:par}=0, the returned token is not enclosed in 
parentheses.

{pstd}
{it:u}{cmd:.u_tokensq()} returns the tokens in {it:s}, preserving (nested) 
double quotes.


{pstd}
{it:u}{cmd:.u_unabbr()} returns whether {it:abbr}==={it:full}; {it:full} 
is {it:minimal_abbreviation}{cmd::}{it:rest}.


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
