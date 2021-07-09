{smcl}
{* 13dec2016 }{...}
{cmd:help for do2screen <v 3.0>} 
{hline}
{* SYNTAX *}
{title:Syntax}

{p 6 16 2}
{cmd:do2screen}{cmd: [using/]},  [	 {it:{help do2screen##options:Options}}  ] 
 

{marker sections}{...}
{title:Sections}

{pstd}
Sections are presented under the following headings:

		{it:{help do2screen##desc:Command description}}
		{it:{help do2screen##Options2:Options description}}
		{it:{help do2screen##Examples:Examples}}

{marker options}{...}
{title:Options}
{synoptset 27 tabbed}{...}
{synopthdr:}
{synoptline}
{syntab:{help do2screen##display:Display option}}
{synopt:{opt var:iables(string)}}Select variables to analyze. May not be combined with 
{it:find} or {it:range} options.{p_end}

{synopt:{opt find(s1)}}Look for {it:s1} in the do-file. By default, {cmd:do2screen} displays the
 subsequent 5 lines to the line in which {it:s1} is found.{p_end}

{synopt:{opt range(numlist min=1 max=2)}}Displays specified range of code lines.{p_end}

{synopt:{opt lines(integer)}}Number of lines after first finding using {it:find} option. Default 5 lines.{p_end}

{synopt:{opt noprevious}}Suppress display of previous variables.{p_end}

{synopt:{opt lables}}Show creation of labels of variables.{p_end}

{syntab:{help do2screen##specify:Specification}}
{synopt:{opt folder(string)}}Directory path in which do-file/ is/are located. Default current directory{p_end}

{syntab:{help do2screen##export:Export}}
{synopt:{opt text(string)}}Name and path of text file to save results.{p_end}

{synopt:{opt replace}}Replace existing text file.{p_end}

{syntab:{help do2screen##advanced:Advanced}}
{synopt:{opt lrep}}Left quote handle (`). default LlLl{p_end}

{synopt:{opt rrep}}Right quote handle ('). default RrRr{p_end}

{synopt:{opt dblq}}Double quote handle (""). default DQDQ{p_end}

{synopt:{opt scalar:name(string)}}Scalar name with returned output. Default is  s_varcode{p_end}

{synopt:{opt comments}}Include comments on code. By default {cmd:do2screen} supresses comments but it makes the process slower. Use this option to speed up process but probably with undesired results.{p_end}

{synopt:{opt nolinenumbers}}Supress line number from output. programers option{p_end}

{marker desc}{...}
{title:Description}

{p 4 6 2}{cmd:do2screen} is a Stata package that allows the user to review specific sections 
of a particular do-file, or set of do-files, directly in the Stata screen. {cmd:do2screen} 
has three functionalities. i) It displays the specific lines of code in which a particular
variable is created, modified, or dropped during a routine. In this version of 
{cmd:do2screen}, the creation of previous variables are displayed. ii) It displays all the code
in which a specific {it:string} is located and, by default, it shows the subsequent 5 lines
of code. The user can change the number of subsequent lines to display. iii) It displays
a specific section of the do-file by selecting the range of lines of code that are desired 
to be analyzed. 

{p 4 6 2}The basic idea behind {cmd:do2screen} is to take advantage of all the information
 contained in the do-files for specific project. It is common to find yourself with a 
thousand-line script in which a single variable is used in several sections of the do-file
and it is not always easy to track its development throughout the routine. Additionally, 
{cmd:do2screen} is able to find interactions of a variable across do-file. Thus, you can
know where your variable under analysis is being used or modified in several do-files of the 
same project. 

{p 4 6 2}Whenever you search for a specific do file, {cmd:do2screen} will allow you open the file 
just clicking the {it:Open} link.

{marker Options2}{...}
{title:Options description}
{marker display}{...} 

{dlgtab:Display option}

{phang} 
{opt var:iables(string)} Select variables to analyze. More than one variable is allowed. It may not be combined with {it:find} or
 {it:range}. 

{phang} 
{opt find(s1)} It is possible to look for any word or sentence within the do-file. 
In order to specify a sentences and separate them from each other, make sure you are using
 double compound quotes (`" "'). For example, you can differentiate the search of 
 {it:"Creation of income variables"} from the single word {it:"income"} by specifying 
 {cmd: find(`" "Creation of income variables" income "')}. Take into account that to find specific senteces, 
you need to embraced them with double quotes ("") inside the double component quotes (`""'). For instance, 
 {cmd: find(`"Creation of income variables"')} won't find the sentence {it:"Creation of income variables"} rather 
 each word separately i.e. {it:Creation}, {it:of}, {it:income}, and {it:variables}. Therefore the proper way
 is to type {cmd: find(`" "Creation of income variables" "')}

{phang} 
{opt range(numlist min=1 max=2)} Range option may be used in two different ways. 

{p 10 13 2}{cmd:i)} Select the line number in which the analysis it's going to start and ii) specify how many lines 
ahead should be displayed. for example,  {cmd:do2scree}{it:[...]}{cmd:, range(253) lines(10)} will display the code lines
 of a certain do-file from line 253 to line 263 because 10 lines ahead was specified. 
 If 'lines' is not specified {cmd:do2screen} will analyze the following five
 lines. 
 
{p 10 13 2}{cmd:ii)} Specify the range of analysis by typing the starting and ending lines. 
The example above will display the same results if you type {cmd:do2scree}{it:[...]}{cmd:, range(253 263)} 

{phang} 
{opt noprevious} Suppress display of previous variables. By default, {cmd:do2screen}
displays the whole procedure for creating a particular variable. For example, if 
variable {it:a} is created as {cmd:gen a = b + c}, {cmd: do2screen} will identify not only 
the creation of {it:a}, but also the creation of {it:b} and {it:c}. Option 
{it:noprevious} suppress the creation of {it:b} and {it:c} and only display the creation
of {it:a}. In case {it:b} and {it:c} are not original variables (i.e are not created
within the do-file), {cmd:do2screen} will display the creation of any variable needed
for the creation of {it:b} and {it:c} and will do the same over and over again until
it reaches only original variables. That is, the output of {cmd:do2screen} allows
the user to reconstruct a variable from the beginning of the do-file regardless 
of it order in the do-file.

{phang} 
{opt labels}  By default, {cmd:do2screen} does not display any line of the do-file that
creates or modifies variables labels. Option {it:labels} allows the user to see the
creation of any label; {cmd:label var...}, {cmd:label define...}, or {cmd:label values...}.


{marker specify}{...}
{dlgtab:Specifications}

{p 4 6 2}{cmd:using} specifies name of do-file to be analyzed. If no directory path is provided,
{cmd:do2screen} will search do-file name in current directory. see {it:{help do2screen##Examples:examples}} 
below

{p 4 6 2}{opt folder(dir path)} will analyze do-file specified in {it:using} syntax. If no do-file
name is specified in {it:using}, {cmd:do2screen} will analyze all do-files contained in {it:dir path}.
Therefore, 

{p 14 16 2}{cmd:do2screen using test.do, folder(C:\mydata)} 

{p 6 6 2}is equivalent to 

{p 14 16 2}{cmd:do2screen using "C:\mydata\test.do"}

{marker export}{...}
{dlgtab:Export}

{p 4 6 2}{opt text(string)} name of text-file displayed results of {cmd:do2screen}. If no path is 
specified, text-file will be saved in current directory. For instance, {cmd:text(C:\mydata\example)} 
will save file {it:example.txt} in folder {it:C:\mydata\}

{phang} {* Replace*}
{opt replace} Replace existing text-file.{p_end}

{marker advanced}{...}
{dlgtab:Advanced}

{phang} 
{opt lrep, rrep, dblq.} {it:lrep} Left quote handle (`). default LlLl. 
{it:rrep} Right quote handle ('). default RrRr. {it:dblq} Double quote handle ("").
default DQDQ. Given that {cmd:do2screen} reads do-files and display them on the screen, 
it needs to handle quotes in sufch a way that Stata do not interpret them as real local
macros or strings. Thus, uring the process, do2screen replace each quote to the
corresponding handle and replace it back at the end of the do-file. Use this option
only if the default handles are actually in used in your code so that when the 
replacement is done back again, it will mess up your code. 

{phang} 
{opt comments} By default, {cmd:do2screen} do not project any comment from your 
code in the result window because it assumes that you only want to see real code. 
However, removing all comments from a Stata script a lot of computational power. 
If you are interested in see your comments or/and speed up the process. Uses this option. 




{marker Examples}{...}
{title:Examples}{p 40 20 2}

{dlgtab:Variables}

{pstd} i) Look for variables "weight" and "expenditure" in a specific Do-file in current directory

{p 8 12}{cmd:do2screen using "test.do", var( weight expenditure ) }


{pstd} ii) Look for variables "weight" and "expenditure" in a specific Do-file in "C:\mydata\" directory

{p 8 12}{cmd:do2screen using "C:\mydata\test.do", var( weight expenditure ) }


{pstd} iii) Look for variables "weight" and "expenditure" in all available do-files in current directory

{p 8 12}{cmd:do2screen, var( weight expenditure) }

{pstd} iv) Look for variables "weight" and "expenditure" in a specific Folder 
(it will search in all available do-files)

{p 8 12}{cmd:do2screen , var( weight expenditure )  folder("C:\Users")}

{dlgtab: Find}

{pstd} i) Look for the word "Poverty"

{p 8 12}{cmd:do2screen using "test.do", find("Poverty") }

{p 4 6 2} ii) Look for the word "Poverty" and specify how many lines, after the word, should 
be shown (default 5 lines)

{p 8 12}{cmd:do2screen using "test.do", find("Poverty") lines(10)}


{p 4 6 2} iii) Look for the phrase "Poverty and Inequality" on one hand, and "Severity", on 
the other hand

{p 8 12}{cmd:do2screen using "test.do", find(`" "poverty and inequality" severity"')}

{dlgtab: Range}

{p 4 6 2} i) Specify a Range to be shown in the result screen

{p 8 12}{cmd:do2screen using "test.do", range(10 30)}

{p 4 6 2} ii) Specify and initial line and the amount of lines to be displayed

{p 8 12}{cmd:do2screen using "test.do", range(10) lines(10) }

{dlgtab: Export Results}

{p 4 6 2} i) Export results to a text file (.txt)

{p 8 12}{cmd:do2screen using "test.do", var( weight expenditure ) text("text_file")}

{p 4 6 2} ii) Export results to a text file (.txt) and replace existing txt file.

{p 8 12}{cmd:do2screen using "test.do", var( weight expenditure ) text("text_file") replace}

{title:Saved Results}
{p 4 6 2} By default, {cmd:do2screen} saves the retrieved code in the scalar 
{it:s_varcode}. If you have this name in used already, please use option {it:scalarname}.

{title:Authors}

{p 4 4 4}Santiago Garriga, The World Bank{p_end}
{p 6 6 4}Email {browse "santiago.garriga@psestudent.eu":santiago.garriga@psestudent.eu}{p_end}
{p 6 6 4}Email {browse "garrigasantiago@gmail.com":garrigasantiago@gmail.com}{p_end}

{p 4 4 4}R.Andres Castaneda, The World Bank{p_end}
{p 6 6 4}Email {browse "acastanedaa@worldbank.org":acastanedaa@worldbank.org}{p_end}
{p 6 6 4}Email {browse "r.andres.castaneda@gmail.com ":r.andres.castaneda@gmail.com }{p_end}


