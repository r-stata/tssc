{smcl}
{title:Title}

{phang}
{cmd:tbl} {hline 2} creates a dynamic table in {bf:HTML}, {bf:LaTeX}, or {bf:Markdown}. It can also align each column to left, center, or right, and also create 
 multiple-colummns for hierarchical tables. This command belongs to 
 {bf:{help Weaver}} package, but it also supports the {bf:{help MarkDoc}} package. 
 For using the command in {help MarkDoc} package 
 {browse "https://github.com/haghish/MarkDoc/wiki/tbl":see the MarkDoc documentation on GitHub wiki}
 

{title:Syntax}

    Creates dynamic table in HTML/Markdown
	
	{cmdab:tbl} {it:(*[,*...] [\ *[,*...] [\ [...]]])} [{cmd:,} {opt tit:le(str)} {opt w:idth(int)} {opt h:eight(int)} {opt left} {opt center} ]

{pstd}where the {bf:*} represents a {it:display directive} which is

	{cmd:"}{it:double-quoted string}{cmd:"}
{p 8 16 2}{cmd:{c 96}"}{it:compound double-quoted string}{cmd:"{c 39}}{p_end}
	[{help format:{bf:%}{it:fmt}}] [{cmd:=}]{it:{help exp}}
	{cmd:,} 
	{l}
	{c}
	{r}
	{col #}


{title:Display directives}

{p 4 4 2}
The supported {it:display directive}s are:

{synoptset 32}
{synopt:{cmd:"}{it:double-quoted string}{cmd:"}}displays the string without
              the quotes{p_end}

{synopt:{cmd:{c 96}"}{it:compound double-quoted string}{cmd:"{c 39}}}display the string
              without the outer quotes; allows embedded quotes{p_end}

{synopt:[{cmd:%}{it:fmt}] [{cmd:=}] {cmd:exp}}allows results to be formatted;
         see {bf:{mansection U 12.5FormatsControllinghowdataaredisplayed:[U] 12.5 Formats: Controlling how data are displayed}}{p_end}

{synopt:{cmd:,}}separates the directives of each column of the table{p_end}

{synopt:{l}}if placed before any of the directives mentioned above, 
this directive create a left-aligned column. {p_end}

{synopt:{c}}creates a center-aligned column. {p_end}

{synopt:{r}}creates a right-aligned column. {p_end}

{synopt:{col #}}if placed before any of the directives mentioned above, 
this directive will create a multi-column by merging # number of columns. {p_end}
{p2colreset}{...}



{title:Description}

{p 4 4 2}
{bf:tbl} is a command in {help Weaver} package that creates a dynamic table 
in HTML or LaTeX, depending on the markup language used in Weaver log. 
If Weaver HTML is in use, {bf:tbl} will be able to interpret the 
{help Weaver Markup} codes as well as 
{help Weaver_mathematical_notation:Weaver mathematical notations}. In other words, 
Weaver Markups and Weaver mathematical notations
can be used as a display directives within the {bf:tbl} command to alter other 
directives or display mathematical signs and formulas. Advanced users can also use HTML 
code to alter the table.

{p 4 4 2}
If LaTeX markup is used for creating the Weaver log, then {cmd:tbl} command 
creates a LaTeX table. However, neither {help Weaver_Markup:Weaver Markup} nor 
{help Weaver_mathematical_notation:Weaver mathematical notations} are not 
supporting LaTeX. Instead, LaTeX mathematical notations can be 
used for writing mathematical notations or altering the table.


{title:Remarks}

{p 4 4 2}
Note that the tbl command parses the rows using the backslash symbol. Therefore, 
to include LATEX notations in a dynamic table that begin with a backslash such as 
{bf:\beta} or {bf:95\%}, double backslash should be used to avoid conflict with 
the parsing syntax (e.g. {bf:\\beta} and {bf:95\\%} )



{title:Examples}

    creating a simple 2x3 table with string and numbers
        . tbl ("Column 1", "Column 2", "Column 3" {bf:\} 10, 100, 1000 )

		
    creating a table that includes scalars and aligns the columns to left, center, and right respectively
        . tbl ({l}"Left", {c}"Centered", {r}"Right" {bf:\} c(os),  c(machine_type), c(username))

		
    write mathematical notations
	    . tbl ("\( \\beta \)", "\( \\epsilon \)" \ "\( \\sum \)", "\( \\prod \)")


{title:Author}

{p 4 4 2}
{bf:E. F. Haghish}       {break}
Center for Medical Biometry and Medical Informatics       {break}
University of Freiburg, Germany       {break}
{it:and}          {break}
Department of Mathematics and Computer Science         {break}
University of Southern Denmark       {break}
haghish@imbi.uni-freiburg.de       {break}

{p 4 4 2}
{browse "www.haghish.com/weaver":Weaver Homepage}           {break}
Package Updates on  {browse "http://www.twitter.com/Haghish":Twitter} 

    {hline}

{p 4 4 2}
{it:This help file was dynamically produced by {browse "http://www.haghish.com/markdoc/":MarkDoc Literate Programming package}} 

