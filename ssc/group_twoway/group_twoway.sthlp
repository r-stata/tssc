{smcl}
{* *! version 1.2.1 07mar2013}{...}
{vieweralsosee "[R] help" "help help "}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}
{phang}

{bf:group_twoway} {hline 2} groups observations by the connected components of two variables 

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:group_twoway}
 parent child
{cmd:,}
{it: gen(newwar)}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opth gen:erate(newvar)}}creates {it:newvar} with a numeric ID for each connected component{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}
{pstd}

{p 4 4 2} {cmd:group_twoway} groups observations by the connected components of the {it:parent} and {it:child} variables.{p_end}

{p 4 4 2} For instance, given a list of family relationships between people, this grouping will connect any two individuals for whom there is a "family path" connecting them (cousin, of a cousin, of a cousin, etc)
 even if there are no direct family relationships between them.{p_end}

{p 4 4 2} This can be useful when classifications (sectorial, regional) change over time and one wants to create a constant classification over the period.{p_end}

{p 4 4 2} The command will interpret vertices with the same name appearing the both {it:parent} and {it:child} variables as being the same and will make the appropriate connections.
If that is not the case, change names in {it:parent} or {it:child} so that the lists are non overlapping (see example2).{p_end}

{p 4 4 2} Most algorithms convert the graph into adjacency matrix form to compute the connected components, which, in Stata, limit's the number of edges than can be considered. 
We keep the edge-list format and use the power's of Stata's own "group" function. Thus it can handle edge lists of virtually any size fits into memory.{p_end}


 
{marker examples}{...}
{title:Examples}

{phang}Example 1: connected components. 

{phang}{cmd:. clear}{p_end}
{phang}{cmd:. input str1 parent str1 child }{p_end}
{phang}{cmd:. 	A T}{p_end}
{phang}{cmd:. 	B T}{p_end}
{phang}{cmd:. 	C Y}{p_end}
{phang}{cmd:. 	C U}{p_end}
{phang}{cmd:. 	D W}{p_end}
{phang}{cmd:. 	E W}{p_end}
{phang}{cmd:. 	E Z}{p_end}
{phang}{cmd:. 	F Z}{p_end}
{phang}{cmd:. end}{p_end}
{phang}{cmd:. group_twoway parent child , gen(extended_family)}{p_end}

{phang}Interpreting this as classifications, or some grouping variable, notice we have 3 cases:{p_end}
{phang}		- simple division: A and B merge to form T{p_end}
{phang}		- simple union: C divides into Y and U{p_end}
{phang}		- complex (division and union): Notice how despite D and F not being connected, the fact that E divides into W, which is formed by merging with D, and Z, which is formed by merging with F, creates an indirect link between D and F. {p_end}

{phang}Example 2: Be careful if vertex names that aprear in both Child and Parent lists.{p_end}

{phang}{cmd:. clear}{p_end}
{phang}{cmd:. input str1 parent str1 child }{p_end}
{phang}{cmd:. 	A T}{p_end}
{phang}{cmd:. 	B T}{p_end}
{phang}{cmd:. 	C A}{p_end}
{phang}{cmd:. 	C B}{p_end}
{phang}{cmd:. end}{p_end}
{phang}{cmd:. group_twoway parent child , gen(extended_family)}{p_end}

{p 4 4 2}Note that vertices A and B appear in {it:parent} and {it:child} and, thus, the group_twoway connects all vertices into the same group.{p_end}
{p 4 4 2}If vertices of each variable are different by definition, regardless of name repetition, as is the case with most classification changes, then change the names so the name lists are disjoint for both variables, as bellow{p_end}

{phang}{cmd:. gen child2=child+"child"}{p_end}
{phang}{cmd:. group_twoway parent child2 , gen(extended_family2)}{p_end}


{marker author}{...}
{title:Authors}
{pstd}

{phang}{cmd:Lucas F. Mation} , Instituto de Pesquisa Econômica Aplicada (IPEA) , Brazil{p_end}
{phang}{cmd:Aguinaldo N. Maciente } , Instituto de Pesquisa Econômica Aplicada (IPEA) , Brazil{p_end}
