{smcl}
{* November 14, 2016 @ 13:26:31}{...}
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



{cmd:help sqclusterdat}{right:(SJ6-4: st0111)}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{hi:sqclusterdat} {hline 2}}Add solution of MDS on dissimilarity matrix to sequence data{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:sqclusterdat [, return keep]}


{title:Description}

{pstd}If the command {helpb sqom} was performed with option {cmd:full},
further analysis of the resulting dissimilarity matrix becomes
indispensable. Cluster analysis is the most common technique for this
step. Unfortunately, sequence data and the resulting dissimilarity
matrices have different dimensions, so that the cluster variables
cannot easily be attached to the sequence data on a row-by-row
basis. {cmd:sqclusterdat} allows linking the results of user-specified
cluster commands to the original sequence data.

{pstd}Without {cmd:return}, the command constructs a dataset
that is built from instructions left over from the last {cmd:sqom}
command.  The user may then specify arbitrary {helpb clustermat}
commands, as well as applicable {help cluster:postclustering commands}
in this dataset.  After performing the cluster analysis,
{cmd:sqclusterdat, return} brings the cluster results back into the
original sequence data.

{pstd}Note that {cmd:sqclusterdat, return} only works if you have specified
the option {cmd:add} in for any cluster analyisis performed with
{cmd:clustermat}. 

{pstd} The option {cmd:keep(}{varlist}{cmd:)} is usable for
{cmd:clusterdat, return} only. It is used to specify a list of
hand-made variables that should be merged to the original dataset as
well. This is especially useful for variables created with
{helpb cluster generate}. 

{pstd}The convenience command {helpb sqclustermat} allows
performing the three steps with one single command. Cluster
postestimation commands do not work in this case, however.


{title:Author}

{pstd}Ulrich Kohler, University of Potsdam, ulrich.kohler@uni-potsdam.de{p_end}


{title:Examples}

{phang}{cmd:. sqom, full k(2)}{p_end}
{phang}{cmd:. sqclusterdat}{p_end}
{phang}{cmd:. clustermat singlelinkage SQdist, add name(mydist1)}{p_end}
{phang}{cmd:. clustermat singlelinkage SQdist, add name(mydist2)}{p_end}
{phang}{cmd:. cluster tree mydist1}{p_end}
{phang}{cmd:. cluster generate gr = groups(2)}{p_end}
{phang}{cmd:. sqclusterdat, return keep(gr)}{p_end}


{title:Also see}

{psee}
Manual:  {bf:[MV] clustermat}

{psee} Online: {helpb sq},
{helpb sqdemo}, {helpb sqset}, {helpb sqdes}, {helpb sqegen}, {helpb sqstat},
{helpb sqindexplot}, {helpb sqparcoord}, {helpb sqom},
{helpb sqclusterdat}, {helpb sqclustermat} {p_end}
