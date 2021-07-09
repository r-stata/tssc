{smcl}
{* *! version 1.0  2020-04-18}{...}
{cmd:help desclong} (vs1.0: 2020-04-18)
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{bf:desclong} {hline 2} Creating and saving a dataset holding variable information – similar as facilitated by 
the -describe- command - while including long variable labels (originally stored through the notes-characteristics).
{p2colreset}{...}


{title:Syntax}

{p 4 16 2}
{opt desclong} [varlist] {cmd:,} {opt name}({it:string}) [{opt folder}({it:string}) {opt dropvars}({it:string}) {opt sortvars}({it:string}) {opt clear} {opt preserve} {opt excel}]
					

{title:Description}

{pstd}
{cmd:desclong} 
is a program that creates and saves a variable information-dataset (similar to what is facilitated by the -describe- command) where originally abbreviated variable labels - with Stata holding the full 
labels stored as notes-characteristics - are displayed with respect to their full length. (This situation may arise when exporting a 
dataset with long variable labels to Stata, e.g. from a SAS-format, where the long labels will then be put into Stata-notes; with abbreviated 
versions filling the actual Stata variable labels.) 

{pstd}
It is mandatory to state a filename for the saved variable information-dataset; 
all other options are optional. 

{pstd}
Note that this in the above sense extends the built-in -describe- command, which it also uses internally as part of the dataset construction.


{title:Options}

{pstd}
{opt name}({it:string}) Name of output dataset holding the stored variable information. Mandatory option.

{pstd}
{opt folder}({it:string}) Defines the directory where to save the variable information-dataset.  
The default directory is the current working directory (pwd; '.'). Full paths - absolute or relative - may be used.

{pstd}
{opt dropvars}({it:string}) Defines which variables, if any, to drop from the final set of variables to be saved.
As a default, all variables are kept.

{pstd}
{opt sortvars}({it:string}) Defines which variables, if any, to use for a final sort of the variable information-dataset
(through the usual sorting procedure). As a default, keep the original sort order.

{pstd} 
{opt clear} Passed on to the corresponding -describe- option. Hence, it may be used to insist on replacing the data
in memory although edits have been made after the last save.

{pstd}
{opt preserve} Preserves the original data to restore it after execution of the command, i.e. running the command without
affecting the data in memory before vs. after execution of the command.

{pstd}
{opt excel} Additionally export the final dataset to Excel ('.xlsx') form.


{title:Examples}

    {hline}

{pstd} 1. Save variable information to a named file {it:fname} in a specified directory {it:fpath}.{p_end}
{phang2}{cmd:. desclong	, name("fname") folder("fpath")}{p_end}

    {hline}

{pstd} 2. Save variable information to a named file {it:fname} in a specified directory {it:fpath}
and additionally save it as an Excel-file.{p_end}
{phang2}{cmd:. desclong	, name("fname") folder("fpath") excel}{p_end}

    {hline}

{pstd} 3. Save variable information for a selected set of variables {it:fvars*} to a named file {it:fname} in a specified directory {it:fpath}.{p_end}
{phang2}{cmd:. desclong	fvars*, name("fname") folder("fpath")}{p_end}

    {hline}

{pstd} 4. Save variable information to a named file {it:fname} in a specified directory {it:fpath} and return to the original data after completion.{p_end}
{phang2}{cmd:. desclong	, name("fname") folder("fpath") preserve}{p_end}

    {hline}

{pstd} 5. Save variable information to a named file {it:fname} in a specified directory {it:fpath} even if the original data has been changed since last save.{p_end}
{phang2}{cmd:. desclong	, name("fname") folder("fpath") clear}{p_end}

    {hline}

{pstd} 6. Save variable information to a named file {it:fname} in a specified directory {it:fpath} while also dropping the variables {it:position} and {it:isnumeric}.{p_end}
{phang2}{cmd:. desclong	, name("fname") folder("fpath") dropvars(pos isnum)}{p_end}

    {hline}

{pstd} 7. Save variable information to a named file {it:fname} in a specified directory {it:fpath} while also sorting the dataset based on variables {it:name} and {it:type}.{p_end}
{phang2}{cmd:. desclong	, name("fname") folder("fpath") sortvars(name type)}{p_end}

    {hline}

{pstd} 8. Save variable information to a named file {it:fname} in the default (current working) directory.{p_end}
{phang2}{cmd:. desclong	, name("fname")}{p_end}

    {hline}


{title:Version}

{pstd} Stata version 15.1.


{title:Dependence}

{pstd} The command depends on the built-in Stata commands {cmd:describe} and {cmd:export excel}, respectively.


{title:Author}

{pstd} Lars {c 196}ngquist {break}
       Lars.Angquist@sund.ku.dk {break}
       lars@angquist.se


{title:Also see}

{psee}
{space 2}Help:  [help pages on] {help describe}, {help export excel}, {help notes}, {help pwd}.
{p_end}
