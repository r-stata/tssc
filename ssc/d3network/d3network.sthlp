{smcl}
{* *! version 1.0 23 May 2014}{...}
help for {cmd:d3network}{right:version 1.0 (23 May 2014)}
{hline}


{title:Title}

{phang}
{bf:d3network} {hline 2} Create network visualizations using D3.js to view in browser


{title:Table of contents}

	{help d3network##syntax:Syntax}
	{help d3network##description:Description}
	{help d3network##options:Options}
	{help d3network##remarks:Remarks}
	{help d3network##example:Example}
	{help d3network##references:References}
	{help d3network##author:Authors}


{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmd:d3network} [using {it: directory}], {it:options}
{p_end}

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Obligatory}
{synopt:{opt network(varlist)}}variables spanning network{p_end}
{synopt:{opt id(variable)}}nodes' unique identifier{p_end}
{synopt:{opt distinction(varlist)}}nesting of networks (i.e., networks' unique identifier(s)){p_end}
{synopt:{opt nodecov(varlist)}}nodal attributes{p_end}

{syntab:Optional}
{synopt:{opt nodecov_newnames(string)}}use new names instead of cryptic variable names{p_end}
{synopt:{opt arrows}}draws directional links{p_end}
{synopt:{opt replace}}overwrite existing network data{p_end}
{synoptline}
{p2colreset}{...}


{marker description}
{title:Description}


{pstd}{cmd:d3network} provides a very convenient way to quickly generate multiple directed network graphs. These graphs can be explored 
interactively in the browser according to user-chosen nodal attributes. This interaction pertains to changes in nodes' size, 
color, links' color, and nodal position via drag-and-drop. The visualization of networks is based on the JavaScript library D3.js (Bostock et al. 2011).{p_end}
{pstd}Technically, {cmd:d3network} converts network data from a stata dataset in wide-format to json-format 
and generates a html file entailing the visualization. Compared to other network visualization software, 
{cmd:d3network}'s strength is the batch generation of multiple networks that can quickly be browsed through.
The generated .html and .json files are either saved to the working directory or to the directory specified by {it: using}.{p_end}



{marker options}{...}
{title:Options}

{dlgtab:Obligatory}

{phang}
{opt n:etwork(varlist)} denotes the variables that span the network. For example, in a school-based survey this could be five variables reflecting students' five best friends within their class.{p_end}

{phang}
{opt id(variable)} indicates the variable that uniquely identifies each sending node.{p_end}

{phang}
{opt distinction(varlist)} clarifies the distinction between multiple networks within one dataset. For example, in a school-based survey
this could be schools (id_school) as level 1, grades as level 2 (id_grade), and classes as level 3 (id_class).{p_end}

{phang}
{opt nodecov(varlist)} provides the list of nodal attributes to be inspected in the visualizations.{p_end}


{dlgtab:Optional}

{phang}
{opt nodecov_newnames(string)} renames the attributes provided in {opt nodecov(varlist)}.{p_end}

{phang}
{opt arrows} provides a visual clarification of link-direction between nodes by adding arrows denoting ingoing links.{p_end}

{phang}
{opt replace} permits {cmd:d3network} to overwrite previously generated networks.{p_end}


{marker remarks}
{title:Remarks}

{pstd}
{cmd:d3network} deals with missing information in the following way. In case of {it: unit nonresponse}, links to the unit (i.e., node) are deleted by default.
If incoming links shall be visualized, the dataset has to be prepared accordingly.{it: Item nonresponse} has to be met by assigning arbitrary values. As a matter
of visualization, these values should tie to the value range of the pertaining item.{p_end}

{pstd}Outgoing links from a node to the node itself (i.e., loops) are not considered.{p_end}

{pstd}
The testing environment included Firefox Version 27.0.1 (as well as 29.0.1) running on Windows 7 SP1.{p_end}

{marker example}
{title:Example}

{pstd}Generating class-level networks from a school-based survey:{break} The variables {it:id_school}, {it:id_grade}, and {it:id_class} represent our distinction between class-level networks.
The variable {it:id_student} uniquely identifies each student. The variables {it:friend1}-{it:friend5} reflect the links, i.e. the friendship nominations, and the ids entailed in those nominations correspond to those of the id variable. 
The attributes we want to look at are sex and ethnicity, which are entailed in the variables {it:p42c8} and {it:g53z2}. As the variable names are very cryptic we want to rename them. In total, we have surveyed 50 classes. 
Thus, we can quickly browse through 50 distinct networks, change nodes' visualizations (i.e., color and size) according to their attributes {it: sex} and {it: ethnicity}, and fix nodes' positions within the graph via drag-and-drop.{p_end}

{phang}{cmd:. d3network, distinction(id_school id_grade id_class) id(id_student) network(friend1-friend5) nodecov(p42c8 g53z2) nodecov_newnames(sex ethnicity)}{p_end}


{marker references}
{title:References}

{phang}Bostock, M., Ogievetsky, V., & Heer, J. (2011). D3: Data-Driven Documents. {it: IEEE Trans. Visualization & Comp. Graphics (Proc. InfoVis)}. 
Available at {browse "http://vis.stanford.edu/files/2011-D3-InfoVis.pdf"} {p_end}

{marker acknowledgements}
{title: Acknowledgements}

{pstd}This routine draws heavily on the work of Michael Bostock and his colleagues. More information on D3.js can be found at {browse "http://www.d3js.org"}.{p_end}
{pstd}We thank Harald Beier, Hanno Kruse, and Lars Leszczensky for their comments and suggestions.{p_end}

{marker author}
{title:Authors}

{pstd}{browse "mailto:sebastian.pink@uni-mannheim.de":Sebastian Pink} and {browse "mailto:svogel@mail.uni-mannheim.de":Sabrina Vogel}, University of Mannheim, Germany.
{p_end}



