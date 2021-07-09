{smcl}
{* Mai 5, 2009 @ 13:05:52 UK}{...}

{vieweralsosee "sqclusterdat" "help sqclusterdat "}{...}
{vieweralsosee "sqdes" "help sqdes "}{...}
{vieweralsosee "sqegen" "help sqegen "}{...}
{vieweralsosee "sqindexplot" "help sqindexplot "}{...}
{vieweralsosee "sqmdsadd" "help sqmdsadd "}{...}
{vieweralsosee "sqmodalplot" "help sqmodalplot "}{...}
{vieweralsosee "sqom" "help sqom "}{...}
{vieweralsosee "sqpercentageplot" "help sqpercentageplot "}{...}
{vieweralsosee "sqset" "help sqset "}{...}
{vieweralsosee "sqstat" "help sqstat "}{...}
{vieweralsosee "sqstrlev" "help sqstrlev "}{...}
{vieweralsosee "sqstrmerge" "help sqstrmerge "}{...}
{vieweralsosee "sqtab" "help sqtab "}{...}

{cmd:help sqmdsadd}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{hi:sqmdsadd} {hline 2}}Adds solution of MDS on dissimilarity matrix to sequence data{p_end}
{p2colreset}{...}

{title:Syntax}


{p 8 17 2}{cmd:sqmdsadd using} {it: filename} [{cmd:, }{cmd:keep(}{varlist}{cmd:)}]


{title:Description}
	
{pstd}{cmd:sqmdsadd} merges the solution of a multi dimensional scaling (MDS) on the
distance matrix created by {cmd:sqom}. 

{pstd}The official Stata command {help mdsmat} can be used at any time
to run a MDS on SQdist, which is the name of the distance matrix from
{cmd:sqom}. The values for the MDS dimensions are created with the
post-estimation command {help mds postestimation##predict:predict}, which requires the
specification of a filename holding the predictions. This file should
be added to the original sequence data with {cmd:mdsadd}. 

{title:Options}

{phang} With {opt keep(varlist)} only the variables of varlist are added to
the sequence data. This is seldom used. 

{title:Author}

{pstd}Ulrich Kohler, University of Potsdam, ulrich.kohler@uni-potsdam.de{p_end}

{title:Example}

{phang}{cmd:. sqom, full}{p_end}
{phang}{cmd:. mdsmat SQdist}{p_end}
{phang}{cmd:. predict om1, saving(mds)}{p_end}
{phang}{cmd:. sqmdsadd mds}{p_end}

{title:Also see}

{psee}
Manual:  {bf:[MV] mds} 

{psee} Online: {helpb sq}, {helpb sqdemo}, {helpb sqset},
{helpb sqdes}, {helpb sqegen}, {helpb sqstat}, {helpb sqindexplot},
{helpb sqparcoord}, {helpb sqom}, {helpb sqclusterdat},
{helpb sqclustermat}
{p_end}


