{smcl}
{* *! version 1.0 10 Jan 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "report##syntax"}{...}
{viewerjumpto "Description" "report##description"}{...}
{viewerjumpto "Options" "report##options"}{...}
{viewerjumpto "Remarks" "report##remarks"}{...}
{viewerjumpto "Examples" "report##examples"}{...}
{title:Title}
{phang}
{bf:report} {hline 2} A command to produce tables for XML

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:report}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt rows(string)}}  specifies the variable(s) used for the rows of the table.

{pstd}
{p_end}
{synopt:{opt cols(string)}}  specifies the variables used for the columns of the table.

{pstd}
{p_end}
{synopt:{opt file(string)}}  specifies the filename of the file to contain the new table.

{pstd}
{p_end}
{synopt:{opt t:itle(string asis)}}  specifies the text used as the title of the table.

{pstd}
{p_end}
{synopt:{opt toptions(string asis)}}  specifies the additional text options used for the table.

{pstd}
{p_end}
{synopt:{opt adj:acentcolumns}}  indicates that columns are placed next to each other and not nested.

{pstd}
{p_end}
{synopt:{opt adjacentrows}}  indicates that rows are placed next to each other and not nested.

{pstd}
{p_end}
{synopt:{opt tableoptions(string asis)}}  specifies the additional options used for the table.

{pstd}
{p_end}
{synopt:{opt usecollabels}}  uses the value label to determine the values tabulated as opposed to which values are observed.

{pstd}
{p_end}
{synopt:{opt userowlabels}}  uses the value label to determine the values tabulated as opposed to which values are observed.

{pstd}
{p_end}
{synopt:{opt font(string)}}  specifies the font to be used in the table.

{pstd}
{p_end}
{synopt:{opt landscape}}  specifies whether the table is created in landscape mode.

{pstd}
{p_end}
{synopt:{opt pagesize(string)}}  specifies the page size.

{pstd}
{p_end}
{synopt:{opt row}}  specifies to produce row percentages for a frequency table.

{pstd}
{p_end}
{synopt:{opt col:umn}}  specifies to produce column percentages for a frequency table.

{pstd}
{p_end}
{synopt:{opt totals}}  specifies to produce total columns and rows for a frequency table.

{pstd}
{p_end}
{synopt:{opt note(string)}}  specifies the text to place in the table note.

{pstd}
{p_end}
{synopt:{opt nofreq}}  indicates that frequency values are not included in the table.

{pstd}
{p_end}
{synopt:{opt replace}}   specifies that a new file be created.

{pstd}
{p_end}
{synopt:{opt missing}}  specifies that missing values will be reported separately for frequency tables and NOT summary tables.

{pstd}
{p_end}
{synopt:{opt dropfirst(#)}}  specifies that the first # lines are dropped.

{pstd}
{p_end}
{synopt:{opt droplast(#)}}  specifies that the last # lines are dropped.

{pstd}
{p_end}
{synopt:{opt rowtotals}}  specifies that additional totals are added to the inner row variable.

{pstd}
{p_end}
{synopt:{opt coltotals}}  specifies to produce column totals for a frequency table.

{pstd}
{p_end}
{synopt:{opt rowsby(varname)}}  indicates that the summary statistics table has a subdivision on the rows, this can be used in conjuntion with cols() but not adjacentcolumns().

{pstd}
{p_end}
{synopt:{opt overall}}  specifies that overall summary statistics are included in the summary statistics tables.

{pstd}
{p_end}
{synopt:{opt *}}  extras{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:report} produces a single table that can be added to an existing docx file or 
 used to create a new docx file.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt rows(string)}     specifies the variable(s) used for the rows of the table.

{pstd}
{p_end}
{phang}
{opt cols(string)}     specifies the variables used for the columns of the table.

{pstd}
{p_end}
{phang}
{opt file(string)} report    specifies the filename of the file to contain the new table.

{pstd}
{p_end}
{phang}
{opt t:itle(string asis)}     specifies the text used as the title of the table.

{pstd}
{p_end}
{phang}
{opt toptions(string asis)}     specifies the additional text options used for the table.

{pstd}
{p_end}
{phang}
{opt adj:acentcolumns}     indicates that columns are placed next to each other and not nested.

{pstd}
{p_end}
{phang}
{opt adjacentrows}     indicates that rows are placed next to each other and not nested.

{pstd}
{p_end}
{phang}
{opt tableoptions(string asis)}     specifies the additional options used for the table.

{pstd}
{p_end}
{phang}
{opt usecollabels}     uses the value label to determine the values tabulated as opposed to which values are observed.

{pstd}
{p_end}
{phang}
{opt userowlabels}     uses the value label to determine the values tabulated as opposed to which values are observed.

{pstd}
{p_end}
{phang}
{opt font(string)}     specifies the font to be used in the table.

{pstd}
{p_end}
{phang}
{opt landscape}     specifies whether the table is created in landscape mode.

{pstd}
{p_end}
{phang}
{opt pagesize(string)}     specifies the page size.

{pstd}
{p_end}
{phang}
{opt row}     specifies to produce row percentages for a frequency table.

{pstd}
{p_end}
{phang}
{opt col:umn}     specifies to produce column percentages for a frequency table.

{pstd}
{p_end}
{phang}
{opt totals}     specifies to produce total columns and rows for a frequency table.

{pstd}
{p_end}
{phang}
{opt note(string)}     specifies the text to place in the table note.

{pstd}
{p_end}
{phang}
{opt nofreq}     indicates that frequency values are not included in the table.

{pstd}
{p_end}
{phang}
{opt replace} replace     specifies that a new file be created.

{pstd}
{p_end}
{phang}
{opt missing}     specifies that missing values will be reported separately for frequency tables and NOT summary tables.

{pstd}
{p_end}
{phang}
{opt dropfirst(#)}     specifies that the first # lines are dropped.

{pstd}
{p_end}
{phang}
{opt droplast(#)}     specifies that the last # lines are dropped.

{pstd}
{p_end}
{phang}
{opt rowtotals}     specifies that additional totals are added to the inner row variable.

{pstd}
{p_end}
{phang}
{opt coltotals}     specifies to produce column totals for a frequency table.

{pstd}
{p_end}
{phang}
{opt rowsby(varname)}     indicates that the summary statistics table has a subdivision on the rows, this can be used in conjuntion with cols() but not adjacentcolumns().

{pstd}
{p_end}
{phang}
{opt overall}     specifies that overall summary statistics are included in the summary statistics tables.

{pstd}
{p_end}
{phang}
{opt *}  extras {p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
First read in some data

{pstd}
{stata webuse citytemp2, clear} <--- this will delete your data!

{pstd}
The simplest table is to create a list of unique levels of a variable and places it 
in a file called test.docx (replacing it if it already exists).

{pstd}
{stata report,  rows(region) nofreq file(test) replace}

{pstd}
Then freqencies of each category and percentages can be added to the same filename test.docx (by not specifying replace)

{pstd}
{stata report,  rows(region) title(Frequency and row percentages) file(test) row}

{pstd}

{pstd}
Often the same sort of report can be desired for two variables, this can be done by adding in an additional variable
into the rows() option.

{pstd}
{stata report,  rows(region agecat)   title(2-way Freq table) file(test) row}

{pstd}
However, this is not the usual way of producing a frequency table and the useful one is having
region as the row variable and agecat as the column variable. To give the more familiar table.

{pstd}
{stata report, rows(region) cols(agecat) column totals file(test)}

{pstd}
Higher dimensions are allowable 

{pstd}
{stata report, rows(region division) cols(agecat) column totals file(test)}

{pstd}
which does not seem correct because region is derived from division and there are plenty of zero cells
in the table. However you could do separate tables with rows either region or division but to 
combine into one table you can use the adjacentrows option

{pstd}
{stata report, rows(region division) cols(agecat) column totals file(test) adjacentrows}

{pstd}

{pstd}
A table containing summary statistics can also be created with the following command. Note that you can put formating statements for each of 
the summary statistics. Also the statistics are the words used in the collapse command and any of the collapse 
statistics can be used.

{pstd}
{stata report, rows(tempjan, mean %5.2f | tempjan, sd  %5.2f| tempjan, count | tempjuly, mean  %5.2f| tempjuly, median  %5.2f) cols(region agecat)  font(,8) file(test)}

{pstd}

{pstd}
Rather than nesting age within region, it might be preferred to have the columns alongside each other and here we add the adjacentcolumns option

{pstd}
{stata report, rows(tempjan, mean %5.2f | tempjan, sd  %5.2f| tempjan, count | tempjuly, mean  %5.2f| tempjuly, median  %5.2f) cols(region agecat)  font(,8) file(test) adjacentcolumns}

{pstd}
Also it is possible to add the overall category alongside the column variables.

{pstd}
{stata report, rows(tempjan, mean %5.2f | tempjan, sd  %5.2f| tempjan, count | tempjuly, mean  %5.2f| tempjuly, median  %5.2f) cols(region agecat)  font(,8) file(test) adjacentcolumns overall}

{pstd}
Or perhaps you want to subdivide the rows by region and have age categories as columns, this is handled by adding a rowsby() option.

{pstd}
{stata report, rows(tempjan, mean %5.2f | tempjan, sd  %5.2f| tempjan, count | tempjuly, mean  %5.2f| tempjuly, median  %5.2f) cols(agecat) rowsby(region) font(,8) file(test) }

{pstd}
Then to produce the table in landscape because it doesn't fit well in portrait (which is the default)
{stata report, rows(heatdd, mean %5.2f | heatdd, count | heatdd, sd %5.3f | tempjan, mean %5.2f | tempjan, sd  %5.2f| tempjan, count | tempjuly, mean  %5.2f| tempjuly, median  %5.2f) cols(region agecat)  font(,8) landscape file(test2) replace}

{pstd}

{pstd}

{pstd}


{title:Author}
{p}

Prof Adrian Mander, Cardiff University.

Email {browse "mailto:mandera@cardiff.ac.uk":mandera@cardiff.ac.uk}


