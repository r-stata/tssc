{smcl}
{cmd:help mata Elabel_eExp()}
{hline}

{title:Title}

{phang}
{cmd:Elabel_eExp()} {hline 2} Manipulate {cmd:elabel} eexpression (class)


{title:Syntax}

{p 8 12 2}
{cmd:class Elabel_eExp scalar} {it:e}

{p 8 12 2}
{it:void}{bind:                    }
{it:e}{cmd:.eexp(}{it:string scalar eexp}{cmd:)}

{p 8 12 2}
{it:transmorphic colvector}{bind:  }
{it:e}{cmd:.eexp()}

{p 8 12 2}
{it:void}{bind:                    }
{it:e}{cmd:.wildcards(}{it:real colvector hash}{cmd:,}
{it:string colvector at}{cmd:)}

{p 8 12 2}
{it:real colvector}{bind:          }
{it:e}{cmd:.hash()}

{p 8 12 2}
{it:string colvector}{bind:        }
{it:e}{cmd:.at()}

{p 8 12 2}
{it:real scalar}{bind:             }
{it:e}{cmd:.hashash()}

{p 8 12 2}
{it:real scalar}{bind:             }
{it:e}{cmd:.hasat()}

{p 8 12 2}
{it:string scalar}{bind:           }
{it:e}{cmd:.eexp_asis()}

{p 8 12 2}
{it:real scalar}{bind:             }
{it:e}{cmd:.get_rc()}


{title:Description}

{pstd}
{cmd:Elabel_eExp()} returns instances of {cmd:class Elabel_eExp}; 
{cmd:Elabel_eExp()} extends 
{helpb mf_elabel_utilities_class:Elabel_Utilities()}. The class is 
used for developing the {cmd:elabel} package. See 
{helpb mf_elabel_u:elabel_u_eexp()} for the corresponding Mata 
function.

{pstd}
{it:e}{cmd:.eexp(}{it:string scalar eexp}{cmd:)} sets an {it:eexp} 
that may contain the wildcard characters {cmd:#} and {cmd:@}.

{pstd}
{it:e}{cmd:.eexp()} obtains a previously set {it:eexp} with all wildcard 
characters replaced and evaluated by Stata. If {it:eexp} evaluates to a 
numeric scalar (or vector) the result is {it:real scalar} 
(or {it:real colvector}); if {it:eexp} evaluates to a string scalar 
(or vector) the result is {it:string scalar} (or {it:string colvector}). The 
function returns {cmd:J(1, 1, "")} if {it:eexp} is {cmd:""}.

{pstd}
{it:e}{cmd:.wildcards()} sets the {it:real colvector} and 
{it:string colvector} that replace the respective wildcard characters in 
{it:eexp}. Both are initalized as missing scalars. In general, {it:hash} 
and {it:at} must have the same number of rows. However, if {it:hash} is 
{it:r x} 1 and {it:at} is 1 {it:x} 1, the latter is replaced with 
{cmd:J(}{it:r}{cmd:, 1,} {it:at}{cmd:)}. The same applies the other way
round, if {it:at} is {it:r x} 1 and {it:hash} is 1 {it:x} 1.

{pstd}
{it:e}{cmd:.hash()} and {it:e}{cmd:.at()} are used to obtain the currently 
set {it:real colvector} and {it:string colvector} that replace the 
respective wildcard characters in {it:eexp}. 

{pstd}
{it:e}{cmd:.hashash()} and {it:e}{cmd:.hasat()} indicate whether 
{it:eexp} contains the respective wildcard characters.

{pstd}
{it:e}{cmd:.eexp_asis()} returns {it:eexp} as previously set, including 
all wildcard characters.

{pstd}
{it:e}{cmd:.get_rc()} returns the Stata return code when evaluating {it:eexp}.


{title:Conformability}

{pstd}
As indicated above.

		 
{title:Diagnostics}

{pstd}
{it:e}{cmd:.eexp()} produces Stata error messages when {it:eexp} 
cannot be evaluated by Stata. Other functions might produce Mata 
traceback logs.


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
