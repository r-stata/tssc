{smcl}
{right:version:  1.2.0}
{cmd:help flexmat} {right:July 19, 2021}
{hline}

{title:Title}

{p 4 8}{cmd:flexmat}  {hline 2}  Creates a flexible matrix of real, string and complex elements {p_end}


{title:Syntax}

{p 8 15 2}
{cmd:flexmat}
{it:{help flexmat##sub:sub_command}} 
{cmd:,}
[{opt r:ow(int)}
{opt c:ol(int)}
{opt data(text or number)}
{opt file:name(str)}
{opt reset}
{opt p:arse(str)}
{opt loc:ation(int)}
{opt newloc:ation}
{opt sameloc:ation}
{opt swap}
{opt merge}
{opt matloc(int, int)}
{opt keep(int)}
{opt getlocinfo}
{opt emptyok}
{opt hide:cw}
]

{title:Description}

{p 4 4 2} {cmd: flexmat} creates flexible matrices of text, numbers or both. 
This program is specifically usesful when numeric and string results need to be
stored in a matrix form or in a table. {cmd:flexmat} hardly throws any 
comfortability error. So we can add cells, rows, columns, or even previously stored
matrices to the current matrix without worrying about comfortability or about 
mixing reals with string. 

{title:Sub-commands}

{marker sub_opt}{...}
{synoptset 25}{...}
{synopthdr:sub_commands}
{synoptline}
{synopt :{help flexmat##addcell:addcell}}add a single cell to a table{p_end}
{synopt :{help flexmat##addrow:addrow}}add a row of data to a table{p_end}
{synopt :{help flexmat##addcol:addcol}}add a column of data to a table{p_end}
{synopt :{help flexmat##addmat:addmat}}add an existing matrix to a table{p_end}
{synopt :{help flexmat##insertrow:insertrow}}insert a row of data to a table{p_end}
{synopt :{help flexmat##insertcol:insertcol}}insert a column of data to a table{p_end}
{synopt :{help flexmat##droprow:droprow}}drop a row {p_end}
{synopt :{help flexmat##dropcol:dropcol}}drop a column {p_end}
{synopt :{help flexmat##droploc:droploc}}drop a location; must be used with option {help flexmat##location:location()} {p_end}
{synopt :{help flexmat##showmat:showmat}}display the stored tables / matrices {p_end}
{synopt :{help flexmat##merge:merge}}merge two matrices; must be used with the option {help flexmat##matloc:matloc()} {p_end}
{synopt :{help flexmat##reset:reset}}deletes existing matrices and clears memory {p_end}

{synoptline}
{marker options}
{title:Options}

{synoptset 25}{...}
{synopthdr:options}
{synoptline}
{synopt :{opth data:(flexmat##data:text1, text2, ...)}}pass data contents, separated by a parse character{p_end}
{synopt :{opth parse:(flexmat##parse:comma, space, pipe)}}sepecify the parsing character used in the option data{p_end}
{synopt :{opth row:(flexmat##row:#)}}specify row number; default is 1{p_end}
{synopt :{opth col:(flexmat##col:#)}}specify column number; default is 1{p_end}
{synopt :{opth loc:ation:(flexmat##location:#)}}specify location number; default is 1{p_end}

{synopt :{opth file:name(flexmat##filename:file_name)}}file name to store the flexmat output on disk{p_end}
{synopt :{opt newloc:ation}}to build table on a new location {p_end}
{synopt :{opt sameloc:ation}}write contents to the last location used {p_end}
{synopt :{opt swap}}replace contents of the last location used {p_end}
{synopt :{opth matloc:(flexmat##matloc:#,#)}}specify locations of matrices while merging(used with sub_command {help flexmatmat##merge:merge}){p_end}

{synopt :{opth keep:(flexmat##keep:#,#)}}used with the sub_command {help flexmatmat##merge:merge} to keep existing matrices, eg {opt keep(1)} , {opt keep(1,2)}{p_end}
{synopt :{opt locinfo}}report location number (used with the sub_command {help flexmat##showmat:showmat}) {p_end}
{synopt :{opt hide:cw}}hide control words (used with the sub_command {help flexmat##showmat:showmat}) {p_end}
{synopt :{opt emptyok}}If need to add empty cells {p_end}
{synoptline}
{marker sub}

{title:Details and Examples : Sub-commands}

{marker addcell}
{p 4 4 2} 1. {cmd: addcell} : The sub-command{cmd: addcell} adds cells to a matrix. This sub_command has three
required options : {opt data(str)}, {opt row(int)}, and {opt col(int)}. Whatever
we pass on to the program through the option {bf: data()} is considered as one cell
and is written to the row and column combination of {opt row()} and {opt col()}.
Consider the following example : {break}

{p 4 8 2} {hi:Example 1 - Constructing a table / matrix cell by cell} {break}
{stata "flexmat reset": flexmat reset} {break}
{stata "flexmat addcell, data(Year) r(1) c(1)": flexmat addcell, data(Year) row(1) col(1)} {break}
{stata "flexmat addcell, data(Mean) r(1) c(2)": flexmat addcell, data(Mean) row(1) col(2)} {break}
{stata "flexmat addcell, data(SD)   r(1) c(3)": flexmat addcell, data(StDe) row(1) col(3)} {break}
{stata "flexmat addcell, data(2001) r(2) c(1)": flexmat addcell, data(2001) row(2) col(1)} {break}
{stata "flexmat addcell, data(5.1%) r(2) c(2)": flexmat addcell, data(5.1%) row(2) col(2)} {break}
{stata "flexmat addcell, data(1.5%) r(2) c(3)": flexmat addcell, data(1.5%) row(2) col(3)} {break}


{p 4 4 2} and the resuling table looks like this;


	 0  | 1              2       3 
	----+---------------------------
	  1 | Year        Mean      StDe 
	----+---------------------------
	  2 | 2001        5.1%      1.5% 
	--------------------------------


{p 4 4 2} 2. {cmd: addrow} : The sub-command {cmd: addrow} adds a row to a matrix. It has three
required options : {opt data(data1, data2, data3, ...)}, {opt row(int)}, and {opt col(int)}. 
The data items in the option data should be seperated by a comma or any other delimters.
The default parsing character (delimiter) is comma. If delimiter is not the comma, 
then option {opt parse(comma, space, pipe)} has to be used to specify the delimiter. 
Let us continue writing to the same matrix that we strated in the above example.
This time, instead of writing individual cells, we shall write a complete row.
Our row will start from row number 3 and column number 1. We shall use the default
delimiter, i.e. comma, hence option {opt parse(comma)} is omitted.{break}

{p 4 8 2} {hi:Example 2 - add row to a table} {break}
{stata "flexmat addrow, data(2002, 6.74, 1.68) row(3) col(1)": flexmat addrow, data(2002, 6.74, 1.68) row(3) col(1)} {break}
{stata "flexmat addrow, data(2003, 6.58, 1.61) row(4) col(1)": flexmat addrow, data(2003, 6.58, 1.61) row(4) col(1)} {break}

{p 4 4 2}With the addition of the two more rows, our table now looks like:

	  0 | 1              2       3 
	----+----------------------------
	  1 | Year        Mean    StDe 
	----+----------------------------
	  2 | 2001        5.1%    1.5% 
	  3 | 2002        6.74    1.68 
	  4 | 2003        6.58    1.61 
	---------------------------------


{p 4 4 2} 3. {cmd: addcol}: The sub-command {cmd: addcol} adds a colum to a matrix. This sub_command has three
required options : {opt data(data1, data2, data3, ...)}, {opt row(int)}, and {opt col(int)}. 
The data items in the option data should be seperated by a comma or any other delimters.
The default parsing character (delimiter) is comma. If the delimiter is not comma, 
then option {opt parse(space, pipe)} has to be used to specify the delimiter. 
Let us continue writing to the same matrix that we strated previously. 
This time, we shall add two new columns.
Our row will start from row number 1 and column number 4. We shall use the default
parsing, i.e. comma.{break}

{p 4 8 2} {hi:Example 3 - add columns to a table} {break}
{stata "flexmat addcol, data(Min, 0, .012, 0.025) r(1) c(4)": flexmat addcol, data(Min, 0, .012, 0.025) row(1) col(4)} {break}
{stata "flexmat addcol, data(Max, 10%, 11, 9) r(1) c(5)": flexmat addcol, data(Max, 0, .012, 0.025) row(1) col(5)} {break}

{p 4 4 2}With the addition of two more columns, our table now looks like:

	  0 | 1            2      3        4     5 
	----+----------------------------------------
	  1 | Year      Mean     SD      Min   Max 
	----+----------------------------------------
	  2 | 2001      5.1%   1.5%        0   10% 
	  3 | 2002      6.74   1.68     .012    11 
	  4 | 2003      6.58   1.61    0.025     9 
	---------------------------------------------


{p 4 4 2} 4. {cmd: addmat}: This sub-command appends existing matrix to the matrix on file. The matrix
can be either a current matrix in the Stata memory or a saved matrix on a file.
In the later case, the file name should be supplied in the option {opt matname(matrix name)}. This sub_command has three
required options : {opt matname(matrix name)}, {opt row(int)}, and {opt col(int)}. 
Further, {cmd: addmat} has three optional options, that can be used to skip adding names of
rows, columns, or both rows and columns of the matrix that is being added. These
options are summarized below:{break}

{synoptset 15}{...}
{synopthdr:options}
{synoptline}
{synopt :{opt non:ames}}skip column and row names{p_end}
{synopt :{opt noc:olname}}skip the matrix column names{p_end}
{synopt :{opt nor:owname}}skip the matrix row name{p_end}
{synoptline}

{p 4 8 2} {hi:Example 4 - add a matrix} {break}
In the following example, let us first create a Stata matrix, name it A, and then
add it to our previously created table. To avaoid the matrix row and column names, 
we shall use the option {opt nonames}. Also, we shall use option {opt dec(3)} to
restrict decimal points to only three. {break}

{p 8 8 2}{stata "mat A = J(2,5,runiform())" : mat A = J(2,5,runiform())} {break}
{stata "flexmat addmat, matname(A) r(5) c(1) nonames dec(3)" : flexmat addmat, matname(A) row(5) col(1) nonames dec(3)} {break}

	  0 |1                          2           3           4           5 
	----+---------------------------------------------------------------------
	  1 |Year                    Mean          SD         Min         Max 
	----+---------------------------------------------------------------------
	  2 |2001                    5.1%        1.5%           0         10% 
	  3 |2002                    6.74        1.68        .012          11 
	  4 |2003                    6.58        1.61       0.025           9 
	  5 |0.370                  0.370       0.370       0.370       0.370 
	  6 |0.370                  0.370       0.370       0.370       0.370 
	--------------------------------------------------------------------------

{marker insertrow}
{p 4 4 2} {cmd: 5. insertrow} : The sub-command {cmd: insertrow} inserts a row to a matrix. 
It differs from the {opt addrow} in a sense that it creates an additional row, while
{opt addrow} adds or replaces contents at the given cell and column combination. 
Therefo{opt insertrow} will always increase the row count of the matrix by one. 
On the other hand, {opt addrow} will increase count of the rows only when the 
specified {opt row(#)} number is greater than the existing rows of the matrix.
In other aspects, it is similr to the {opt addrow} option. {break}

{p 4 8 2} {hi:Example 5 - insert row at row location of 5} {break}
{stata "flexmat insertrow, data(2004, 7.74, 3.68, .04, 11) row(5) col(1)": flexmat insertrow, data(2004, 7.74, 3.68, .04, 11) row(3) col(1)} {break}

{p 4 4 2}With the insert of one more rows, our table now looks like:

	  0 |1                          2           3           4           5 
	----+---------------------------------------------------------------------
	  1 |Year                    Mean          SD         Min         Max 
	----+---------------------------------------------------------------------
	  2 | 2001                    5.1%        1.5%           0         10% 
	  3 | 2002                    6.74        1.68        .012          11 
	  4 | 2003                    6.58        1.61       0.025           9 
	  5 | 2004                    7.74        3.68         .04          11
	  6 | 0.370                  0.370       0.370       0.370       0.370 
	  7 | 0.370                  0.370       0.370       0.370       0.370 
	--------------------------------------------------------------------------

{marker insertcol}
{p 4 4 2} {cmd: 6. insertcol} : The sub-command {cmd: insertcol} inserts a column to a matrix. 
it differs fom {opt addcol} as {opt insertrow} differs from {opt addrow}.

{p 4 8 2} {hi:Example 6 - insert column at column location of 6} {break}
{stata "flexmat insertcol, data(Median, 4, 5, 7, 9,0.370,0.370) row(1) col(6)": flexmat insertcol, data(Median, 4, 5, 7, 9,0.370,0.370) row(1) col(6) row(1) col(6)} {break}

{p 4 4 2}With the insert of one more olumn, our table now looks like:

	  0 |1                          2           3           4           5          6 
	----+-------------------------------------------------------------------------------
	  1 |Year                    Mean          SD         Min         Max     Median  
	----+-------------------------------------------------------------------------------
	  2 | 2001                    5.1%        1.5%           0         10%         4
	  3 | 2002                    6.74        1.68        .012          11         5 
	  4 | 2003                    6.58        1.61       0.025           9         7 
	  5 | 2004                    7.74        3.68         .04          11         9
	  6 | 0.370                  0.370       0.370       0.370       0.370     0.370 
	  7 | 0.370                  0.370       0.370       0.370       0.370     0.370 
	-----------------------------------------------------------------------------------
{marker droprow}
{p 4 4 2} {cmd: 7. droprow} : It deletes a row. Option row() must be used with this sub-command.

{marker dropcol} 
{p 4 4 2} {cmd: 8. dropcol} : It deletes a column. Option col() must be used with this sub-command.

{marker droploc} 
{p 4 4 2} {cmd: 8. droploc} : It deletes a {help flexmat##location:location}. 
Option loc() must be used with this sub-command.
{marker merge}
  
 {p 4 4 1}{cmd: 11. merge} : It merges two matrices; must use option {opt matloc()},
 {opt row()} and {opt col()}. Think of {opt merge} as 1:1 merge of the official
 {help merge } command. The two matrices are merged from two difference locations
 on the same {help flexmat##filename:filename}. The merge happens on the similarity 
 of contents of the two matrices in thier first column. In other words, the two
 matrices are merged on thier first columns. Values that are not merged, are
 added to the merged matrix at its end. The sub-command merge has one required option {opt matloc(#,#)} and one 
 optional option opt keep(#,#)}. These are discussed below:{break}
 {marker matloc}{break}
 
 {p 8 8 1}{opt 11.1 matloc(#,#)}: The location numbers are specified
 in the option {opt matloc(#,#)}. For example, if the two matrices are located
 at location 1 and 2, the option matloc() will be typed as {opt matloc(1,2)}.
 
 {marker keep}
 {p 8 8 1}{opt 11.2 keep(#,#)}: Further, we can use option {opt keep(#,#)} to keep either
 the first matrix one, the second matrix, or both
 in the flexmat system. If option {opt keep(#,#)} is not used, flexmat will delete
 these matrices and will keep just the newely merged matrix. Option {opt keep(#,#)} 
 can be used as as follows:{break}
 
 {synoptset 15}{...}
{synopthdr:options}
{synoptline}
{synopt :{opt keep(1)}}To keep the merged matrix and the first matrix in flexmat{p_end}
{synopt :{opt keep(2)}}To keep the merged matrix and the second matrix in flexmat{p_end}
{synopt :{opt keep(1,2)}}To keep the merged matrix and both the first and the second matrix in flexmat{p_end}
{synoptline}

{p 4 8 2} {hi:Example 7 - merge two matrices of location 1 and 2} {break}
As shown in Example 6 above, we have a matrix that is currently stored in the 
default locaation of 1. Let us first create another matrix at location 2, and
then merge it with the matrix at location. To expedite the process, let us use
option addrow() to write full row in one line of code. 


{p 8 8 2}{stata "flexmat addrow, data(Year, P75) loc(2)": flexmat addrow, data(Year, P75) loc(2)} {break}
{stata "flexmat addrow, data(2001, 4%) loc(2) row(2)": flexmat addrow, data(2001, 4%) loc(2) row(2)} {break}
{stata "flexmat addrow, data(2004, 9.3) loc(2) row(3)": flexmat addrow, data(2004, 9.3) loc(2) row(3)} {break}

{p 8 8 2}The flexmat contents at this stage look like this: Note the loc = 1 and
loc = 2, that show the location information of the two matrices.

	flexmat showmat, locinfo
	Loc = 1
	  0 |1                         2           3           4           5         6 
	----+-------------------------------------------------------------------------------
	  1 |Year                   Mean          SD         Min         Max    Median 
	----+-------------------------------------------------------------------------------
	  2 |2001                   5.1%        1.5%           0         10%         4 
	  3 |2002                   6.74        1.68        .012          11         5 
	  4 |2003                   6.58        1.61       0.025           9         7 
	  5 |2004                   7.74        3.68         .04          11         9 
	  6 |0.349                 0.349       0.349       0.349       0.349     0.037 
	  7 |0.349                 0.349       0.349       0.349       0.349     0.370 
	------------------------------------------------------------------------------------
	
	Loc = 2
	
	  0 |1            2 
	----+---------------------------
	  1 |Year       P75 
	----+---------------------------
	  2 |2001        4% 
	  3 |2004       9.3 
	--------------------------------

	{p 8 8 2}The two matrices have three values in common in thier first rows:
	Year, 2001, 2004. Now let us merge the two matrices.
	
	{p 8 8 2}{stata "flexmat merge, matloc(1,2)": flexmat merge, matloc(1,2)} {break}
	 
	  0 |1                        2           3           4           5         6     7 
	----+-------------------------------------------------------------------------------------
	  1 |Year                  Mean          SD         Min         Max    Median   P75 
	----+-------------------------------------------------------------------------------------
	  2 |2001                  5.1%        1.5%           0         10%         4    4% 
	  3 |2002                  6.74        1.68        .012          11         5       
	  4 |2003                  6.58        1.61       0.025           9         7       
	  5 |2004                  7.74        3.68         .04          11         9   9.3 
	  6 |0.349                 0.349       0.349       0.349       0.349     0.370       
	  7 |0.349                 0.349       0.349       0.349       0.349     0.370       
	------------------------------------------------------------------------------------------




 {marker showmat}
{p 4 4 2} {cmd: 12. showmat} : displays the contents of the active flexmat file.
The sub-command does not need any option. For example: 

{p 8 8 2}{stata "flexmat showmat": flexmat showmat} {break}


{marker option}

{title:Options}

{marker data}
{p 4 4 2} {opt 1. data(text1, text2)}:{break}

{p 8 8 2} Option data() receives data contents (text, numeric, or alpha-numeric) and 
builds table cells with it. With the sub-commands {help flexmat##addrow:addrow}
and {help flexmat##addcol:addcol}, flexmat parses the input data using the default delimiter
of comma, i.e. ",". Each of the parsed token then goes to the specified cells of the table. However, 
with the sub-command {help flexmat##addcell:addcell}, flexmat does not parse 
the input data and considers everything as part of a single cell.

{marker parse}
{p 4 4 2} {opt 2.} {opt p:arse(comma, semicolon, colon, space, pipe)}:{break}

{p 8 8 2} When using the sub-commands {help flexmat##addrow:addrow}
or {help flexmat##addcol:addcol}, data contents must be delimited by a delimiter
such as comma "{hi:,}", semicolon "{hi:;}", colon "{hi::}", space "{hi: }", or pipe "{hi:|}". 
Option {p:arse()} must specify the delimiter, with delimiter name in english. 
See the following examples{p_end}

{synoptset 15}{...}
{synopthdr:options}
{synoptline}
{synopt :{opt p:arse(comma)}}parsing on comma, that is "{hi:,}"{p_end}
{synopt :{opt p:arse(semicolon)}}parsing on semicolon, that is "{hi:;}"{p_end}
{synopt :{opt p:arse(colon)}}parsing on colon, that is "{hi::}"{p_end}
{synopt :{opt p:arse(space)}}parsing on space, that is "{hi: }"{p_end}
{synopt :{opt p:arse(pipe)}}parsing on pipe, that is "{hi:|}"{p_end}
{synoptline}
{marker col}{marker row}
{p 4 4 2} {opt 3.}{opth r:ow(int)} and {opth c:ol(int)}:{break}

{p 8 8 2} Both option row() and col() accept integers and marks the starting
point at which the data contents are written in the matrix / table. The default
of both the options is 1, hence if these options are not used, the data is written
to the first row and first column combination of the table, that is cell 1. 
To increase readability of the flexmat table, the output is shown with the row 
and column number on the screen. If data is written to a cell, row, or a column, that
has existing contents, it is over-written without any warning. However, if 
data is written to a new cell, row, or a column, flexmat will automatically add 
the new element to the matrix and populate it with the given data.  

{marker location}
{p 4 4 2} {opt 4.}{opth loc:ation(int)}:{break}

{p 8 8 2}The concept of locations in flexmat is to create separate enteties or
files. A simple example would be to create two matrices, keep them separate, 
and have an ability to access and modify their elements. We would then call 
matrix 1 as location = 1, and matrix 2 as location = 2. This way flexmat can
hold multiple matrices and text blocks, and still provide its users an ability 
to access and modify these with convenience. By default, data is written to 
locaton = 1. 

{p 4 8 2} {hi:Example 5 - add table / matrix at location 2} {break}

{p 8 8 2}{stata "mat B = J(2,5,runiform())" : mat B = J(2,5,runiform())} {break}
{stata "flexmat addmat, matname(B) nonames location(2)" : flexmat addmat, matname(B) nonames loc(2)} {break}


{p 4 8 2} {hi:Example 6 - modify the matrix at location 2}{break}
{stata "flexmat  addcell, data(Year) row(1) col(1) loc(2)" : flexmat  addcell, data(Year) row(1) col(1) loc(2)}{break}
{stata "flexmat  addcell, data(Mean) row(1) col(2) loc(2)" : flexmat  addcell, data(Mean) row(1) col(1) loc(2)}{break}
{stata "flexmat  addcell, data(SD) row(1) col(3) loc(2)"   : flexmat  addcell, data(SD) row(1) col(1) loc(2)}{break}

{p 8 8 2}{stata "flexmat  addrow, data(2010, 1200, 1300) row(3) loc(2)" : flexmat  addrow, data(2010, 1200, 1300) row(3) loc(2)}{break}
{stata "flexmat  addcol, data(Min, .023, 1400) c(4) loc(2)" : flexmat  addcol, data(Min, .023, 1400) c(4) loc(2)}{break}

{marker filename}
{p 4 4 2} {opt 5.}{opth file:name(file_name)}:{break}

{p 8 8 2}flexmat writes its matrices to a file on disk. The default file name 
used by flexmat is {hi:"stored_results.flexmat"}. It is stored in the current
directory. However, if you have used asdocx in the current Stata session, then 
asdocx borrows the file name from there and is saved in the {hi: "current_direcor\_asdocx"}
directory, where "current_directory" is not a literal name, it is the current
directory where Stata is currently saving / reading files from.
Both the {hi: ".flexmat"}
extension and the file name {hi:"stored_results"} can be changed. However, unless
it is necessary to change these, it is not advised to change them. The reason
is that once you change them, then you must use the option {opt matname()}
to tell flexmat which file are you reading from when writing further contents to the file.


{marker getlocinfo} 
{p 4 4 1} {cmd: 6. getlocinfo} : It writes the highest location number to a 
global macro {hi:flexmat_current_loc}. This command is rarely used. Actually, 
{opt getlocinfo} is used by 
{browse "http://www.fintechprofessor.com/asdocx":asdocx}
 to find next available {help flexmat##location:location}
 for writing contents. Besides writing this global macro, it also displays the  contents of the active flexmat file.

 
{p 4 4 2} {cmd: 7. reploc} Option {opt reploc} is used with {opt flexmat show} to
report the location numbers with data stored in different locations.


{p 4 4 2}{cmd: 8. reset} : {break}Option {opt reset} deletes any stored matrices. If the reset is used 
withouth any option, it will delete the default matrices, i.e stored_results.flexmat file in the current directory.
reset(mydirectory/filename.ext) will delete file filename.ext in the mydirectory. {break}

{p 4 8 2} {hi:Example 7 - reset / delete locations} {break}
* Reset the active flexmat file{break}
{stata "flexmat reset" : flexmat reset}{break}

{p 8 8 2}* Reset a specific file in a given directory{break}
{stata "flexmat reset(c:/flex/Mytable.flexmat)" : flexmat reset(c:/flex/Mytable.flexmat)}{break}


{title:HOW TO EXPORT FLEXMAT TABLE} 

{p 4 4 2} Once the flexmat file is ready, it can be then exported to any of the 
{browse "https://fintechprofessor.com/asdocx": asdocx's} supported formats, that include MS Word, Excel, or LaTeX. 
asdocx is a premium version of asdoc and is available for a nominal fee of $9.99.
Following is
 the asdocx syntax for exporting flexmat files.
{title:Syntax}

{p 8 15 2}
{cmd:asdocx exportflex}
{cmd:,}
[{opt asdocx_options}]

{p 4 4 2}Since the default output format is .docx, therefore, if just typed:

{p 8 15 2}{cmd: asdocx exportflex}

{p 4 4 2}the flexmat file will be exported to a Word file with {it:.docx} format. In case we wish to
send the output to an Excel file, then we would use the asdocx option 
{opt save(Myfile.xlsx)}. For example:

{p 8 15 2}{cmd:asdocx exportflex, save(Myfile.xlsx)}

{p 4 4 2} We can also use other asdocx options such as font(font_name)  to change the font
 family or fs(#) to set the font size of the document.



{title:Author}


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: *
*                                                                   *
*            Dr. Attaullah Shah                                     *
*            Institute of Management Sciences, Peshawar, Pakistan   *
*            Email: attaullah.shah@imsciences.edu.pk                *
*           {browse "www.OpenDoors.Pk": www.OpenDoors.Pk}                                       *
*           {browse "www.FinTechProfessor.com": www.FinTechProfessor.com}                               *
*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*



{marker also}{...}
{title:Also see}

{psee}
{browse "https://fintechprofessor.com/asdocx": asdocx    : Premium version - easy yet extremely powerful version of asdoc}   {p_end}
{psee}{stata "ssc desc asdoc":asdoc : Easily send Stata tables to MW Word} {p_end}
{browse "http://www.opendoors.pk/home/paid-help-in-empirical-finance/stata-program-to-construct-j-k-overlappy-momentum-portfolios-strategy":    asm: for momentum portfolios}
{psee}{stata "ssc desc astile":astile : for creating fastest quantile groups} {p_end}
{psee}{stata "ssc desc asreg":asgen : for weighted average mean} {p_end}
{psee}{stata "ssc desc asrol":asrol : for rolling-window statistics} {p_end}
{psee}{stata "ssc desc asreg":asreg : for rolling-window, by-group, and Fama and MacBeth regressions} {p_end}
{psee}{stata "ssc desc ascol":ascol : for converting asset returns and prices from daily to a weekly, monthly, quarterly, and yearly frequency}{p_end}
{psee}{stata "ssc desc searchfor":searchfor : for searching text in data sets} {p_end}







