{smcl}
{* 01Feb2012 }{...}
{cmd:help for makeddi}{hline 1} 
{hline}
{* SYNTAX *}
{title:Syntax}

{p 6 16 2}
{cmd:makeddi using }{it: filename {cmd:,}} [	 {it:{help makeddi##options:Options}}  ] 

{p 6 16 2} where {it: filename} refers to a do-file where variable derivation script is written
 

{marker sections}{...}
{title:Sections}

{pstd}
Sections are presented under the following headings:

		{it:{help makeddi##desc:Command description}}
		{it:{help makeddi##Options2:Options description}}
		{it:{help makeddi##Examples:Examples}}

{marker options}{...}
{synoptset 27 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:{help makeddi##basics:Basics}}
{synopt:{opt var:iables(string)}}List variables to be documented. May not be combined with {it:data} option.{p_end}

{syntab:{help makeddi##advanced:Advanced}}
{synopt:{opt data(string)}}Name of the data where variables names will be taken.{p_end}

{synopt:{opt sort}}Document variables in alphabetical order. May be combined only with {it:data} option {p_end}

{synopt:{opt exclude(string)}}Exclude variables from {it:data}.{p_end}

{syntab:{help makeddi##export:Export}}
{synopt:{opt name(string)}}Name of the DDI that will be generated.{p_end}

{synopt:{opt rootddi(string)}}Folder where DDI will be saved.{p_end}

{synopt:{opt add(string)}}Add {it:variables} to existing DDI.{p_end}

{synopt:{opt replace}}Replace existing DDI.{p_end}

{marker desc}{...}
{title:Description}
{p 50 20 2}{p_end}

{pstd}
{cmd:makeddi} aims to improve the quality and efficiency of the meta-data documentation production.
 The idea behind this tool is to extract from the do-file and locate into the DDI file the code 
 lines that derivate the variables of the micro data that is intended to be documented. {cmd:makeddi}  
 identifies specific lines of code that create and modify each variable of the data. These 
 lines of code are stored and located in the particular fields of the "variable derivation" 
 section of the  
Data Documentation Initiative ({browse www.ddialliance.org/what:DDI}) XML file. 
{cmd:makeddi} generates a XML file that will be ready to be loaded by the Metadata Editor 
({browse www.ihsn.org/home/software/ddi-metadata-editor:IHSN}). Whenever you generate a DDI, 
{cmd:makeddi} will allow you open the file {it:.xml} just clicking the 'Open' link.

{marker Options2}{...}
{title:Options description}
{p 50 20 2}{p_end}

{marker basics}{...}
{dlgtab: Basics}

{phang} {* VARIABLES *}
{opt var:iables(string)}  Specify variables to be documented in the DDI. Undoubtedly more than one variable is allowed. 

{marker advanced}{...} {p 80 20 2}{p_end}
{dlgtab:Advanced}

{phang} {* DATA*}
{opt data(string)} Search in {it:data} the variable names to be documented. Option {it:data} and {it:variables} are mutually exclusive. Either you specify the variables in {it:variables} or ask the command to look for the variables in {it:data}.  {p_end}

{phang} {* SORT*}
{opt sort} Document variables in alphabetical order i.e. first docucment variable "make", then "mpg", "price" and so on. {p_end}

{phang} {* EXCLUDE *}
 {opt exclude(string)} This option is useful when you do not want to document some variables. For instance those that may alter confidentialy or privacy like for example household id. Variables in {it:exclude} option are not documented. {p_end}
 
{marker export}{...} {p 80 20 2}{p_end}
{dlgtab:Export}

{phang} {* NAME*}
{opt name(string)} Set name of the DDI.{p_end}

{phang} {* ROOTDDI*}
{opt rootddi(string)} Set path where the DDI will be stored. Default is current directory.{p_end}

{phang} {* ADD*}
{opt add(string)} It may be the case that the user may want to add a variable (or more than one) to an existing DDI. If so, this is the option 
that should be used. The default option uses a template xml to document the variable creation, but if this option is activated instead of starting from the template {it:makeddi} uses an existing DDI.{p_end}

{phang} {* REPLACE*}
{opt replace} Replace existing DDI (.xml file).{p_end}


{hline}
{marker Examples}{...}
{title:Examples}{p 40 20 2}{p_end}
{pstd}

{dlgtab: Variables}

{p 8 12}{cmd: makeddi using "test.do",  variables(weight income consumption id) name(DDI-Auto)}{p_end}

{pstd} Make DDI for variables weight, income, consumption and id; DDI is saved in current directory. 


{p 8 12}{cmd: makeddi using "test.do",  variables(weight income consumption id) name(DDI-Auto) rootddi(C:\mydata\)}{p_end}

{pstd} Make DDI for variables weight, income, consumption and id; DDI is save in C:\mydata. 


{p 8 12}{cmd: makeddi using "test.do",  variables(weight income consumption id) name(DDI-Auto) rootddi(C:\mydata\) replace}{p_end}

{pstd} Replace existing DDI. 


{dlgtab: Data}

{p 8 12}{cmd: makeddi using "test.do",  data(auto) replace name(DDI-Auto)}{p_end}

{pstd} Generate DDI for variables present in data.


{p 8 12}{cmd: makeddi using "test.do",  data(auto) replace sort name(DDI-Auto)}{p_end}

{pstd} Generate DDI for variables the present in {it:data} and {it:sort} them in alphabetical order.


{p 8 12}{cmd: makeddi using "test.do",  data(auto) replace exclude( mpg rep78 headroom ) name(DDI-Auto)}{p_end}

{pstd} Generate DDI for the variables present in {it:data} excluding mpg rep78 and headroom.


{dlgtab: Add information on existing DDI}

{p 8 12}{cmd: makeddi using "test.do",  add(C:\mydata\DDI-Auto.xml) var(tempvar) name(DDI-Auto2)}{p_end}

{pstd} Add variable tempvar to existing DDI-Auto.xml and named the new DDI as DDI-Auto2.xml

	
{title:Authors}

{p 4 4 4}Santiago Garriga, The World Bank{p_end}
{p 6 6 4}Email {browse "sgarriga@worldbank.org":sgarriga@worldbank.org}{p_end}
{p 6 6 4}Email {browse "garrigasantiago@gmail.com":garrigasantiago@gmail.com}{p_end}

{p 4 4 4}R.Andres Castaneda, The World Bank{p_end}
{p 6 6 4}Email {browse "acastanedaa@worldbank.org":acastanedaa@worldbank.org}{p_end}
{p 6 6 4}Email {browse "r.andres.castaneda@gmail.com ":r.andres.castaneda@gmail.com }{p_end}
	

{title:Also see other Stata program by the same authors}

{psee}
 {helpb do2screen} (if installed)
{p_end}

