{smcl}
{* 23 June 2013}{...}
{hline}
help for {hi:labellacking}
{hline}

{title:Report numeric variables with values lacking value labels}


{title:Syntax}

{p 8 17 2}
{cmd:labellacking} 
[{it:varlist}]
{ifin}
[
{cmd:,} 
{cmdab:a:ll}
{cmdab:miss:ing} 
{cmdab:r:eportnovaluelabels} 
] 


{title:Description}

{p 4 4 2}{cmd:labellacking} reports on numeric variables in {it:varlist}
listing observed integer values lacking assigned value labels.
{it:varlist} is optional and defaults to all numeric variables. String
variables are always ignored even if specified directly or indirectly.
The effect of specifying {cmd:if} and/or {cmd:in} is to restrict
reporting to the observations implied. Note that non-integers and system
missing values {cmd:.} are always ignored, as they cannot be labelled. 


{title:Options}

{p 4 8 2}{cmdab:a:ll} reports "(none)" whenever all observed integer
values have been assigned value labels, so none are lacking value
labels. The default is to report nothing about any such variables. 

{p 4 8 2}{cmdab:miss:ing} extends reporting to observed extended missing
values (any of .a ... .z) not assigned value labels. The default is to
ignore all such missing values.

{p 4 8 2}{cmdab:r:eportnovaluelabels} specifies that numeric variables
lacking any value labels be reported explicitly. The default is to
ignore them. It is unlikely that you will want to use this option, but
it is provided for completeness. See also {help ds} (or {help findname}
if installed). 


{title:Examples}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. label define rep78 1 abysmal 2 adequate}{p_end}
{p 4 8 2}{cmd:. label val rep78 rep78}

{p 4 8 2}{cmd:. labellacking price-foreign}{p_end}
{p 4 8 2}{cmd:. labellacking price-foreign, all}{p_end}
{p 4 8 2}{cmd:. labellacking price-foreign, all report}

{p 4 8 2}{cmd:. labellacking rep78, missing}{p_end}
{p 4 8 2}{cmd:. replace rep78 = .a if rep78 == .}{p_end}
{p 4 8 2}{cmd:. labellacking rep78, missing}


{title:Authors} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break}
n.j.cox@durham.ac.uk

{p 4 4 2}Robert Picard{break}
picard@netbox.com


{title:Also see}

{psee}Online: {manhelp label D}; {manhelp codebook D}; 
{manhelp labelbook D}; {manhelp ds D}; {help findname} (if installed). 
