{smcl}
{* 6june2014}{...}
{cmd:help tex2col}{right:Version 1.0.0}
{hline}

{title:Title}

{p 4 11 2}
{hi:tex2col} {hline 2} Split Text into Columns{p_end}


{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:tex2col} {ifin} 
[, {break}
{cmdab:col:umns}({it:#)} {break}
{cmdab:data}({it:string)} {break}
{cmdab:cname}({it:stub}) {break}
{cmdab:rname}({it:newvarname}) {break}
{cmdab:dpcomma} {break}
{cmdab:ignore}({it:"chars"})]

{synoptset 35 tabbed}{...}
{synopthdr:{it:}{col 18}}
{synoptline}
{syntab: Main}
{p2coldent :* {cmdab:col:umns}({it:#})}Number of columns
   with data{p_end}
{p2coldent :* {cmdab:data}({it:string})}Name of the variable 
   that contains the data{p_end}
   
{syntab: Options}
{synopt :{opt cname}(stub)}Column names{p_end}
{synopt :{opt rname}(newvarname)}Row name{p_end}
{synopt :{opt dpcomma}}Convert data with commas as decimals to period-decimal format{p_end}
{synopt :{cmd: ignore}("chars")}Remove specified non-numeric characters{p_end}
{synoptline}
{p 4 6 2}* Required option{p_end}

{marker desc}{title:Description}

{pstd} {cmd:tex2col} is aimed to split the contents of one Stata cell into
       different columns,
       and is particularly useful for extracting data from a PDF file and
	   manage it in an easy way. Use this command to convert the selected
	   {it:data} into a table, splitting the text into different columns.

{pstd} {cmd:tex2col} functioning rests on two basic principles:

{phang2}{space 1}o{space 2}First, the data variable should not have intermediate
							subtitles. If that's the case, please use the command
							twice, one with the first part and then with the other.{p_end}

{phang2}{space 1}o{space 2}Second, the data variable should not be in one single line
							but in different lines; the number of lines
							depends on the number of observations.{p_end}

{pstd}While the command has been set with the dot as decimal unit({it:default}), the comma decimal unit
may be included in the options. In addition, several characters may be added to ignore in the number conversion.

{title:Data format}

{pstd} {cmd:tex2col} requires that the information within the {it:data} variable
		be separated with spaces like the example below.

{marker structure}{pstd}The following table shows an example of the 
      usefulness of the {cmd:tex2col} command. The first column
       refers to the {it:data} variable where the original information is 
	   stored. The second column is what the command calls {it:rname} indicating
      the name of the units under analysis (e.g. countries, states, counties). 
	  Finally, the last two colums refer to {it:cname} and thus to the information
	  extracted from the original {it:data} variable.

{center: DATA                      ROW              COL_1  COL_2}
{center:{hline 58}}                                        
{center: Chaco Seco 16.2 24.3      Chaco Seco       16.2   24.3}
{center: Valles del Sur 12.2 18.1  Valles del Sur   12.2   18.1}
{center:{hline 58}}

{title:Options description}

{dlgtab:Main}

{phang}
{cmd: columns}{it:(#)} Number of columns for which the data will be splited. 

{phang}
{cmd: data}{it:(string)} Name of the variable that contains the information.
   
{dlgtab:Options}

{phang}
{cmd: cname}{it:(stub)} specifies column {it:stub} names e.g. if {it:cname} is {it:col},
	the variable names of the columns will then be col1, col2 and so on
	(up to the number of columns specified in the {it:columns} option).
	The default is {it:col_}.

{phang}
{cmd: rname}{it:(newvarname)} specifies row name. The default rowname is {it:row}.

{phang}
{cmd: dpcomma} convert data with commas as decimals to 
	period-decimal format. 

{phang}
{cmd: ignore} {it:("chars")} remove specified non-numeric characters{p_end}

{title:Examples }

{txt}      {it: Example I}
{cmd}
    . clear
    . input str60 (data)
	. "Chaco Húmedo 16,6 25,1 21,5 881,5 58 73 66"
	. "Chaco Seco 16,2 24,3 21,3 736,1 60 79 71"
	. "Valles Centrales 14,7 18,3 16,9 721,4 50 74 62"
	. "Valles del Sur 12,2 18,1 16 351,3 40 70 53"
    . end
    . tex2col, data(data) col(7)
    . list	

{txt}      {it: Example II}
{cmd}
    . clear
    . input str60 (data)
	. "Chaco Húmedo 16,6 25,1 21,5 881,5 58 73 66"
	. "Chaco Seco 16,2 24,3 21,3 736,1 60 79 71"
	. "Valles Centrales 14,7 18,3 16,9 721,4 50 74 62"
	. "Valles del Sur 12,2 18,1 16 351,3 40 70 53"
    . end
    . tex2col, data(data) col(7) dpcomma
    . list

{txt}      {it: Example III}
{cmd}
    . clear
    . input str60 (data)
	. "Argentina 2011 18.7%"
	. "Bolivia 2011 0.4%"
	. "Brasil 2011 3.6%"
	. "Chile 2011 1.7%"
	. "Colombia 2011 5.2%"
	. "Costa Rica 2010 8.0%"
	. "Ecuador 2011 3.1%"
	. "El Salvador 2010 0.3%"
	. "Honduras 2011 3.0%"
	. "México 2010 3.1%"
	. "Panamá 2011 0.6%"
	. "Paraguay 2010 0.9%"
	. "Perú 2011 24.1%"
	. "Uruguay 2011 4.3%"
	. "Venezuela 2011 10.3%"
    . end
    . tex2col, data(data) col(2) ignore(%)
    . list

{title:Author}

{p 4} Santiago Garriga {p_end}
{p 4} Facultad de Ciencias Económicas (UNLP - Argentina)  {p_end}
{p 4} LCSPP - World Bank {p_end}
{p 4} {browse "mailto:garrigasantiago@gmail.com":garrigasantiago@gmail.com}

{title:Also see}

{psee}
{helpb egen}, {helpb string functions}, {helpb destring}
{p_end}

