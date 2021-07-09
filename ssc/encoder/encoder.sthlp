{smcl}
{cmd:help elabel encoder}
{hline}

{title:Title}

{p 4 8 2}
{cmd:encoder} {hline 2} Encode strings into numerics with the option to replace.
 
{title:Syntax}

{phang}
String variable to numeric variable

{p 8 12 2}
{opt encoder} {it:varname} {ifin} {cmd:,} [{opt gen:erate(newvar)}
{opt l:abel}{cmd:(}{it:name}{cmd:)} {opt noe:xtend} {opt replace} {opt set:zero}]

{phang}
Multiple string variables to numeric variables

{p 8 12 2}
{opt encoderall} [{it:varlist}] {ifin} {cmd:,} [{opt l:abel}{cmd:(}{it:name}{cmd:)} {opt noe:xtend} {opt noextenda:ll} {opt set:zero}]


{title:Description}

{pstd}
{cmd:encoder} is identical to {helpb encode}, but also includes options to (i) replace an existing variable instead of generating a new variable, and (ii) set the first labeled value to start at 0, rather than at 1. The second option can be useful, among other things, when the encoded variable will be used as a predictor variable in a regression. Another small difference from Stata's encode command is that encoded variables are always compressed to the smallest possible format.

{pstd}
{cmd:encoderall} operates on a list of variables (or on all variables when no list is given), and encode all possible variables in the list. Variables that cannot be encoded are ignored. The newly-created variables replace the original variables.

{pstd}
Variable labels and order are preserved when using these commands to replace existing variables. However, notes and characteristics are not preserved. 

{pstd}
Important: the {opt setzero} option is dependent on Daniel Klein's {helpb elabel} program. You will need to install {cmd:elabel} first if you plan to use the {opt setzero} option. You can install elabel by typing -ssc install elabel-

{pstd}
Code for this module is heavily based on Kenneth L. Simmon's earlier program {helpb rencode} (March 2006), and should be viewed as a revised version of that program.


{title:Options for encoder}

{phang}
{opth generate(newvar)} specifies the name of a variable to be created. This is required unless the replace option is specified.

{phang}
{opt label(name)} specifies the name of the value label to be created or used and added to if the named value label already exists. If {opt label()} is not specified, {cmd:encoder} uses the same name for the label as it does for the new variable, and if a label by this name already exists then it is used.

{phang}
{opt noextend} specifies that if there are values contained in {it:varname} that are not present in {opt label(name)}, {it:varname} not be encoded. By default, any values not present in {opt label(name)} will be added to that label.

{phang}
{opt replace} if specified causes the encoded variable to replace the original string variable, instead of generating a new variable. This may not be combined with the {opth generate(newvar)} option.

{phang}
{opt setzero} specifies that encoded values should start at 0. If this option is not specified, then encoded values will begin at 1 (similar to Stata's {cmd:encode} program).


{title:Options for encoderall}

{phang}
{opt label(name)} specifies the name of a single value label to be created or used and added to when the named value label already exists. This label will apply to all
variables encoded. If {opt label()} is not specified, {cmd:encoderall} uses a different label for each variable, with in each case the name of the label being the name of the variable. If there is a pre-existing label by this name then it is used.

{phang}
{opt noextend} specifies that if there are values contained in {it:varname} that are not present in {opt label(name)} - or if {opt label(name)} is not specified then in any existing label that shares the name of the variable - {it:varname} not be encoded. If {opt label(name)} is not specified and no pre-existing label has the same name as the variable, then the noextend option is ignored (unless you specify the {opt noextendall} option). By default, any values not present in the label will be added to the label. If {it:varname} cannot be encoded, {cmd:rencode} will continue trying to encode other variables (unless you specify the {opt noextendall} option), so only variables that can be fully encoded with the relevant label end up being encoded.

{phang}
{opt noextendall} implies {opt noextend}, but indicates that all variables should be able to be encoded using existing labels without extending them. If they cannot be, the command exits with an error message.

{phang}
{opt setzero} specifies that all encoded variables start with values at 0. If this option is not specified, then all encoded variables start at 1 (similar to Stata's {cmd:encode} program).


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use https://stats.idre.ucla.edu/stat/stata/faq/hsbs, clear}{p_end}

{pstd}Replaces string variable with encoded variable labeled with the same strings{p_end}
{phang2}{cmd:. encoder gender, replace}{p_end}

{pstd}Same as before but values are [0,1] rather than [1,2]{p_end}
{phang2}{cmd:. encoder gender, replace setzero}{p_end}

{pstd}Encodes and replaces all string variables in data, with each variable starting at 0{p_end}
{phang2}{cmd:. encoderall, setzero}{p_end}


{title:Author}

{p 4}David Tannenbaum{p_end}
{p 4}Department of Management{p_end}
{p 4}University of Utah{p_end}
{p 4}{browse "https://davetannenbaum.github.io"}{p_end}


{title:Also see}

{psee}
Manual: {bf:[D] encode}

{psee}
Online: {helpb encode}
{p_end}