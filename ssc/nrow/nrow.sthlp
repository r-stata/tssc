{smcl}
{* *! version 1.0.1 November 2015}{...}
{cmd:help nrow}{...}
{hline}

{title:Title}

{pstd}
{hi:nrow} {hline 2} Rename variables as their {it:n}th-row values.

{title:Syntax}

{p 8 16 2}
{cmd:nrow} [{opt row#}] [, {opt k:eep} {opt v:arlist(varlist)}]
{p_end}

{title:Description}

{pstd}
{cmd:nrow} is a simple command for easily renaming variables as their {it:n}th-row values.
When run it renames all variables as their first row values, as the {it:firstrow} option in {help import_excel:import excel}.
The optional argument {opt row#} can be specified to choose any row as the one to rename the variables for.
It must be any positive integer not greater than {help  _variables:_N}.
If the value of the {it:n}th-row of a particular variable is not a valid Stata name, the command automatically transforms it by use of the {help strtoname:strtoname()} function.
If {varlist} is specified, then the command only renames those variables.
The command defaults to droping all rows up to and including {opt row#}, but these rows can be kept using the {opt k:eep} option.

{title:Examples}

This example uses the nrow_example.dta ancillary dataset (included). It can be loaded with:
	{cmd:. sysuse nrow_example, clear}

To set the first row as variable names we can simply type:
	{cmd:. nrow}
	
This deletes the first row, though. If we want to keep that row, we need to reload the dataset and use the {opt k:eep} option:
	{cmd:. sysuse nrow_example, clear}
	{cmd:. nrow, keep}
	
Notice that the last two variables have a few illegal Stata variable characters which are replaced by underscores.
Since those names are intelligible, it may be better to use the second row as variable names: 
	{cmd:. nrow 2, keep}
	
Lastly, it may be preferable to use first row values for the first two variables, but then use second row values for the last three variables:
	{cmd:. nrow, varlist(id birth)}
	{cmd:. nrow, varlist(var1 - var3)}

{title:Author}

{pstd}Alvaro Carril, J-PAL LAC, Chile {break}
acarril@fen.uchile.cl
