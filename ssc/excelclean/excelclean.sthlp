{smcl}
{* *! version 0.1  07jul2018}{...}
{viewerdialog excelclean "dialog misc"}{...}
{viewerjumpto "Syntax" "misc##syntax"}{...}
{viewerjumpto "Contact" "misc##contact"}{...}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:excelclean} {hline 2} clean and integrate excel files} 
{p_end}
{p2colreset}{...}


{marker description}{...}
{title:Description} 

{p 4 4 2}{cmd:excelclean} automatically loads all excel files in a specified directory, organizes variable names and labels, reshapes the dataset if necessary, and integrates all files into a cleaned dataset.

{marker syntax}{...}
{title:Syntax}

{p 4 4 2}
{cmd:excelclean} datadir(string) sheet(string) cellrange(string) [{cmd:,} {it:options}]

{phang2}
{opt datadir(string)} directory where excel files are stored. Please close and save all excel files under this directory before executing the command.
{p_end}
{pmore2} e.g., datadir("c:/myplace/")

{phang2}
{opt sheet(string)} the excel sheet in each excel file to be loaded into Stata. 
{p_end}
{pmore2} e.g., sheet("sheet1") or sheet("Results")

{phang2}
{opt cellrange(string)} the range of data cells on each excel sheet to be loaded into Stata.
{p_end}
{pmore2} e.g., cellrange("A1") to extract all cells; cellrange("B3") to extract cells starting from the second column and the third row.


{title:Options} 

{phang2}
{opt integrate} integrate all datasets into a single dta file. The default is to save each dta file separately using the name of the corresponding excel file. 
{p_end}

{phang2}
{opt pivot} reshape variables from a wide format to a long format. By default, the program recogonizes the last word from the formulated variable names as the time indicator. 
{p_end}
{pmore2} The program will detect the variables that need to be reshaped into a long format, e.g. Var2000, Var2001, Var2002 -> Var 

{phang2}
{opt droplist(string)} drop redundant variables from the dataset in the data integration process. It helps to reduce the file size and processing time. Separate variable names by a space " ".
{p_end}
{pmore2} e.g., droplist("Var1 Var2 "). Remember to leave a space at the end of the last variable.

{phang2}
{opt resultdir(string)} specify the directory where the results are saved. The default is the directory "datadir" where the excel files are stored. 
{p_end}
{pmore2} e.g., resultdir("C:/myresultdir/"). Always use the {hi:full path} of the directory to aviod possible conflicts.

{phang2}
{opt extension(string)} specify the extension of files to be included. The deault is "xlsx". 
{p_end}
{pmore2} e.g., extension("xls")

{phang2}
{opt namerange(integer)} specify the rows that record variables names. The default is the first row. 
{p_end}
{pmore2} e.g., namelines(4) to indicate that the first four rows contain information about variable names. Note that the first four lines will be deleted from the dataset after creating the variable names.

{phang2}
{opt namelines(string)} select the rows to formulate variables names. The default is the first row. 
{p_end}
{pmore2} e.g., namelines("1 3") to specify the first and the third rows to be used to formulate variable names

{phang2}
{opt wordfilter(string)} specify specific characters to be excluded from variable names. 
{p_end}
{pmore2} e.g., wordfilter("year quarter the"); to exclude the space before any word use wordfilter(`"" word1" " word2""')



{marker contact}{...}
{title:Author}

{phang}
Lu Han

{phang}
Faculty of Economics, Universtiy of Cambridge

{phang}
Please report issues on Github
{browse "https://github.com/hanlulong/excelclean":https://github.com/hanlulong/excelclean}
{p_end}
