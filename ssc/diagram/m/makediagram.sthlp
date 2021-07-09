{smcl}
{title:Title}

{phang}
{cmd:makediagram} {hline 2} generates DOT diagram file from data sets 

{title:Syntax}

{p 8 16 2}
{cmd: makediagram} [{help using} {it:filename}] {cmd:,} 
{it:export(filename)} [ {it:replace} {it:graphtype(name)} 
{it:style(filename)} ]
{p_end}

{* the new Stata help format of putting detail before generality}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt e:xport(filename)}}export the DOT diagram file. {p_end}
{synopt:{opt graphtype(name)}}specifies the type of the graph which can 
be {bf:digraph} (default) or {bf:graph} (i.e. undirected). {p_end}
{synopt:{opt replace}}replace the exported DOT file{p_end}
{synopt:{opt style(filename)}}appends an external DOT style sheet to the DOT file.{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{p 4 4 2}
{bf:makediagram} generates a  {browse "http://en.wikipedia.org/wiki/Dot":DOT} file from 
a data set that can be rendered to a graphical file using {help diagram} program 
within Stata. the data set should be prepared as explained in the next section.



{title:Variable discription}

{p 4 4 2}
The data set should have 5 variables named {bf:cluster} (numeric), {bf:from} 
(numeric or string), {bf:to} (numeric or string), {bf:label} (string), and 
{bf:properties} (string). The numeric variables can have labels which also changes 
the labels in the DOT file. 

	

{title:   cluster     from       to        label     properties}
   numeric     numeric    numeric   string    string
   or          or         or
   string      string     string



{p 4 4 2}
the {bf:cluster}, {bf:label}, and {bf:properties} can be missing. however, the 
{bf:from} and {bf:to} variables specifies which nodes are connected to one another. 
in directed graphs, the direction is {bf:"from"} towards {bf:"to"}. However, in 
undirected graphs, this direction is of no significance and only shows a connection. 

{p 4 4 2}
the {bf:cluster} variable defines in which subgraph the connection takes place 
(see the examples)

{p 4 4 2}
the {bf:from} and {bf:to} variables specify the nodes where the connection begines and 
ends. the variables can be numeric, e.g. the nodes can be {bf:1 -> 2} or strings
such as {bf:A -> B} or {bf:"Node A" -> "Node B"}. If the variables are numeric, 
their label is automatically used to alter the labels of the DOT graph (see the examples). 

{p 4 4 2}
the {bf:label} variable simply "labels the connection". this merely specifies the "label" or 
"value" for the arrow. the label of the connection can also be specified within the 
{bf:properties} variable, but due to its common use and importance 
({it:and to make life easier for those who don{c 39}t wish to learn the DOT language}), 
it is made available as a separate variable. yet, adding {bf:label="} {it:label} {bf:"} 
in the {bf:properties} variable can change the connection label. 


{title:Example(s)}

{p 4 4 2}
the  {browse "https://raw.githubusercontent.com/haghish/diagram/master/torture_test.do":diagram torture test} 
includes several examples and example data sets for testing the package. 

    exporting a directed DOT script file from a data set
        . makediagram using name.dta, export("name.txt") label("diagram's label")

    exporting undirected DOT script file
        . makediagram using name.dta, export("name.txt") graphtype(graph)


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
{browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/markdoc.php":http://www.haghish.com/markdoc}           {break}
Package Updates on  {browse "http://www.twitter.com/Haghish":Twitter} 

    {hline}

{p 4 4 2}
This help file was dynamically produced by {help markdoc:MarkDoc Literate Programming package}

