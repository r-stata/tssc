{smcl}
{* *! version 1.0  7 Jun 2016}{...}
{viewerjumpto "Syntax" "codebook_ripper##syntax"}{...}
{viewerjumpto "Description" "codebook_ripper##description"}{...}
{viewerjumpto "Options" "codebook_ripper##options"}{...}
{viewerjumpto "Remarks" "codebook_ripper##remarks"}{...}
{viewerjumpto "Examples" "codebook_ripper##examples"}{...}
{title:Title}
{phang}
{bf:codebook_ripper} {hline 2} Rip metadata saved in a Excel workbook and 
generate a do file with code for labels, value labels and notes.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:codebook_ripper}
using Excel_workbook_path_and_name
[{cmd:,}
{it:options}]

{marker options}{...}
{title:Options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Mandatory}
{synopt:{opt var:iable(name)}} The column title text in the Excel workbook specifying which column to use for variable names.{break}
The column title text is in the first row on the sheet specified by the sheet option.{break}
{red:The column title text is transformed into a Stata variable name when the sheet is imported, eg spaces are removed.}{break}
{red:THAT name is the one to specify}.{p_end}

{synopt:{opt lab:el(name)}} The column title text in the Excel workbook specifying which column to use for variable label text.{break}
The column title text is in the first row on the sheet specified by the sheet option.{break}
{red:The column title text is transformed into a Stata variable name when the sheet is imported, eg spaces are removed.}{break}
{red:THAT name is the one to specify}.{p_end}

{synopt:{opt s:heet(string)}} The name from where to read the columns containing variables, labels value labels and notes.{break}
When the sheet is imported first row is used as a base for the Stata names to refer to.{p_end}

{syntab:Optional}
{synopt:{opt val:uelabels(name)}} The column title text in the Excel workbook specifying which column to use for value labels.{break}
The column text is in the first row on the sheet specified by the sheet option.{break}
{red:The column text is transformed into a Stata variable name when the sheet is imported, eg spaces are removed.}{break}
{red:THAT name is the one to specify}.{break}
Value label text syntax is specified the options delimiter and equal2 below.{p_end}

{synopt:{opt nolow:ername}} Naming conventions here are to have names in lower 
letters. If names are not to be forced to be lowered use this option.{p_end}

{synopt:{opt ren:ame(name)}} The column title text in the Excel workbook specifying which column to use as new variable names.{break}
The column text is in the first row on the sheet specified by the sheet option.{break}
{red:The column text is transformed into a Stata variable name when the sheet is imported, eg spaces are removed.}{break}
{red:THAT name is the one to specify}.{p_end}

{synopt:{opt del:imiter(string)}} The delimiter separates each assignment of value 
and value label in the column of value labels.{break}
Default value is ";" (semicolon).{p_end}

{synopt:{opt eq:ual2(string)}} The equal2 separates value and value label for 
each assignment of value and value label in the column of value labels.{break}
Default value is "=" (equal to).{break}
Extra spaces around to equal2 value are ignored.{p_end}

{synopt:{opt not:es(namelist)}} A set of additional column title names adding a set of notes to the variable in the order specified in option notes.{break}
{red:The column title texts in the Excel workbook are transformed into a Stata variable names when the sheet is imported, eg spaces are removed.}{break}
{red:THESE name is the ones to specify}.{break}
Notes could eg be based on information on the original questions, units or formulas saved in the sheet.
{p_end}

{synopt:{opt do:file(string)}} Which do file to save the commands into.{break}
Default value is the workbookname underscore the sheet name (eg workbook_sheet).{p_end}

{synopt:{opt out:path(string)}} Path to save the do file into.{break}
Default value is the workbookname underscore the sheet name (eg workbook_sheet).{p_end}

{synopt:{opt rep:lace}} Use option replace if it is ok to replace existing do file.{p_end}

{synopt:{opt run}} If the dataset to use the do file upon is opened in Stata option run will {cmd:run} (command) the do file at the end.{break}
{red:This is only relevant if the dataset to use the do file upon is loaded up front}.{p_end}

{synopt:{opt do}} If the dataset to use the do file upon is opened in Stata option run will {cmd:do} (command) the do file at the end.{break}
{red:This is only relevant if the dataset to use the do file upon is loaded up front}.{p_end}

{synopt:{opt open}} This option opens the do file in the Do-file editor at the end.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
Metadata such as labels for variables, value labels and other information are
sometimes saved in sheets from a Excel workbook.

{pstd}
The command {cmd:codebook_ripper} can convert that information into a do file 
template that adds this information to the dataset.

{pstd}
{cmd:codebook_ripper} imports the specified sheet table into Stata and from 
there the necessary commands are generated and saved into the do file.

{pstd}
The dataset possibly present at Stata will be preserved in the process.

{marker examples}{...}
{title:Examples}

{pstd}
Assume metadata are in sheet metadata1 in a Excel workbook named metadata.

{pstd}
The flat file table consist of the columns named Variable names, Labels, Value 
Labels, note1 and note2. 

{pstd}
Hence delimiter and equal2 are by default set to "," and "=", respectively.

{pstd}
An example of a cell value in the column with name Value labels could be: 
0 = Female, 1=Male.
 
{pstd}
Set the default working directory:

{phang}
	{cmd:cd }c:/mydata 

{pstd}
Load the dataset which needs the labels etc from the sheet in the Excel workbook:

{phang}
	{cmd:use }"./dataset_with_no_labels/dataset.dta", clear

{pstd}
Now running the command below will generate the do file ./do/my_label_file that 
the dataset dataset.dta containing the variables listed in column 
Variablenames (note that space is removed).

{pstd}
These variables will get labels from the values in the column Labels. 
Value labels will be generated from column Valuelabels. 
Note1 and note2 follow the same recipe.

{pstd}
The do file will be replaced (option replace) if necessary and it will also 
be run in the end of the command {cmd:codebook_ripper} (option do).
All in the command:

{phang}
	{cmd:codebook_ripper} using "metadata.xlsx", variable(Variablenames) label(Labels) valuelabels(Valuelabels) sheet(metadata1) dofile(./do/my_label_file) notes(note1 note2) replace do


{title:Authors and support}

{phang}{bf:Author:}{break}
 	Niels Henrik Bruun, {break}
	Section for General Practice, {break}
	Dept. Of Public Health, {break}
	Aarhus University
{p_end}
{phang}{bf:Support:} {break}
	nhbr@ph.au.dk
{p_end}
