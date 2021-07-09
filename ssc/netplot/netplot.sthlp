{smcl}
{.-}
help for netplot
{.-}

{title:netplot - Social Network Visualization}


{title:Syntax}
	{p 8 15 2}
	{cmdab:netplot}
	{it: var1 var2}
	{ifin}
	[{cmd:,} {it:options}]
	

{title:Description}

{opt netplot} produces a graphical representation of a network stored as an extended edgelist or arclist in {it: var1} and {it: var2}. 


{title:Options}

{phang}
{opt t:ype(string)} specifies the type of layout. Valid values are:

{phang2}
{opt circle}: vertices are arranged on a circle

{phang2}
{opt mds}: positions of vertices are calculated using multidimensional scaling. This is the default; omitting {opt type()} is equivalent to specifying {opt type(mds)}.

{phang}
{opt l:abel} specifies that vertices are to be labeled using their identifiers in {it: var1} and {it: var2} 

{phang}
{opt a:rrows} specifies that arrows rather than lines are drawn between vertices. Arrows run from the vertex in {it: var1} to the vertex in {it: var2}. This option is useful for arclists that represent directed relations.

{phang}
{opt i:terations(#)} specifies the maximum number of iterations in the multidimensional scaling procedure. The default is {cmd: iterate(1000)}.


{title:Remarks}

{p}
An extended edglelist or arclist is a set of two variables representing relations (i.e., edges (undirected) or arcs (undirected)) between entities (vertices). Vertices are identified by the entries in the cells. 
For example:

      		 {c TLC}{hline 9}{c -}{c TRC}
	         {c |} {res} v1   v2 {txt}{c |}
    	         {c LT}{hline 9}{c -}{c RT}
	      1. {c |} {res} 1    2  {txt}{c |}
	      2. {c |} {res} 2    3  {txt}{c |}
	      3. {c |} {res} 4    .  {txt}{c |}
	      	 {c BLC}{hline 9}{c -}{c BRC}

{p}
represents relations among four vertices. There are edges between 1 and 2 and between 2 and 3. The fact that the value in v2 for vertex 4 is missing indicates that vertex 4 is isolated. 





{title:Also see}

{psee}
Online: {manhelp mdsmat MV}, 
	{manhelp twoway_scatter G}, 
	{manhelp twoway_pcspike G}
{p_end}
