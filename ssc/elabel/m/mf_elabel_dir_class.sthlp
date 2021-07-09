{smcl}
{cmd:help mata Elabel_Dir()}
{hline}

{title:Title}

{phang}
{cmd:Elabel_Dir()} {hline 2} Obtain lists of value label names 
and languages (class)


{title:Syntax}

{p 8 12 2}
{cmd:class Elabel_Dir scalar} {it:d}

{p 8 12 2}
{it:string colvector}{bind:       }
{it:d}{cmd:.rnames()}

{p 8 12 2}
{it:string colvector}{bind:       }
{it:d}{cmd:.attached()}

{p 8 12 2}
{it:string colvector}{bind:       }
{it:d}{cmd:.nonexistent()}

{p 8 12 2}
{it:string colvector}{bind:       }
{it:d}{cmd:.orphans()}

{p 8 12 2}
{it:string colvector}{bind:       }
{it:d}{cmd:.used()}

{p 8 12 2}
{it:string colvector}{bind:       }
{it:d}{cmd:.allnames()}

{p 8 12 2}
{it:string scalar}{bind:          }
{it:d}{cmd:.clang()}

{p 8 12 2}
{it:string colvector}{bind:       }
{it:d}{cmd:.langs(}[{it:real scalar exclude}]{cmd:)}

{p 8 12 2}
{it:(varies)}{bind:               }
{it:d}{cmd:.mlang(}[{it:real scalar mlang}]{cmd:)}

{p 8 12 2}
{it:void}{bind:                   }
{it:d}{cmd:.resetnames()}


{title:Description}

{pstd}
{cmd:Elabel_Dir()} returns instances of {cmd:class Elabel_Dir}; 
{cmd:Elabel_Dir()} extends 
{helpb mf_elabel_utilities_class:Elabel_Utilities()}. The 
class is used for developing the {cmd:elabel} package. See 
{helpb mf_elabel_dir:elabel_dir()} and {helpb mf_elabel_ldir:elabel_ldir()} 
for the corresponding Mata functions.

{pstd}
{it:d}{cmd:.rnames()} returns all value label names that are stored 
in memory. The functions calls Stata's {helpb label dir}.

{pstd}
{it:d}{cmd:.attached()} returns all value label names that are attached 
to at least one variable in the dataset, including value label names that 
are not stored in memory. Value label names in memory that are not attached 
to any variables are omitted.

{pstd}
{it:d}{cmd:.nonexistent()} returns value label names that are not stored 
in memory but attached to at least one variable in the dataset; 
{it:d}{cmd:.undefined()} is a synonym for {it:d}{cmd:.nonexistent()}.

{pstd}
{it:d}{cmd:.orphans()} returns value label names that are stored in memory 
but not attached to any of the variables in the dataste; 
{it:d}{cmd:.notused()} is a synonym for {it:d}{cmd:.orphans()}.

{pstd}
{it:d}{cmd:.used()} returns value label names that are stored in memory and 
attached to at least one variable in the dataset.

{pstd}
{it:d}{cmd:.allnames()} is a convenience function and returns 
{cmd:(}{it:d}{cmd:.attached()\} {it:d}{cmd:.orphans())}.

{pstd}
{it:d}{cmd:.clang()} returns the current label language; see 
{help label_language:label language}.

{pstd}
{it:d}{cmd:.langs()} returns a list of all label languages, excluding the 
current label language. If {it:exclude}=0, the current label language is 
included in the list of label languages.

{pstd}
{it:d}{cmd:.mlang()}, if {it:mlang}!=0 (the default), collects nonexistent 
value label names from all label languages in 
{help label_language:multilingual datasets}; conversely, setting {it:mlang}=0 
restricts those value label names to the current label language. Called 
without arguments, the function returns the current setting of {it:mlang}.

{pstd}
{it:d}{cmd:.resetnames()} resets all results. The function must be called 
after new value labels have been defined, value labels have been dropped, 
or variables have been added or dropped from the dataset.


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
