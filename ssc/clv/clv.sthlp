{smcl}
{* 29 juillet 2019}{* version 2.17}{...}
{hline}
help for {hi:clv}{right:Jean-Benoit Hardouin}
{hline}

{title:Clustering around latent variables }

{p 8 14 2}{cmd:clv} [{it:varlist}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [{cmd:weight}]
[{cmd:,} {cmdab:nostand:ardized}  {cmdab:ker:nel}({it:numlist}) {cmdab:meth:od}({it:keyword}) {cmdab:cons:olidation}({it:#}) {cmd:genlv}(string) {cmdab:rep:lace}
{cmdab:noden:dro} {cmdab:saved:endro}({it:filename}[,replace]) {cmdab:cut:number}({it:#}) {cmdab:show:count} {cmdab:texts:ize}({it:string}) {cmdab:deltaT} 
{cmdab:hor:izontal} {cmdab:abb:rev}({it:#}) {cmdab:tit:le}({it:string}) {cmdab:cap:tion}({it:string}) 
{cmdab:bar} {cmdab:nobip:lot} {cmdab:add:var} {cmd:std} {cmd:dim}({it:string}) {cmdab:files:ave} {cmdab:dirs:ave}({it:string})]




{title:Description}

{p 4 8 2}{cmd:clv} clusters variables around latent components. The variables are clustered by
seeking to minimize at each step the decrease of the T criterion, computed as the sum of the
first eigenvalues of the matrices of data of all the clusters. A hierarchical cluster analysis
based on this criterion is performed. A iterative consolidation procedure can be subsequently run which
allows each variable to be assigned to the latent component it is the most correlated with.

{title:Options}

{p 0 8 2}{cmd:Options concerning the method CLV}

{p 4 8 2}{cmd:nostandardized} uses centered variables instead of standardized variables.

{p 4 8 2}{cmd:kernel} defines one or several kernels of variables (variables which are clustered together in an initial step). The first number #k1 indicates that the first #k1 variables are clustered together, the second number #k2 indicates that the following #k2 variables are clustered together...

{p 4 8 2}{cmd:method} indicates the method to cluster the variables among {it:classical} (by default) for the method described by Vigneau and Qannari,
 {it:polychoric} for a use of the matrix of polychoric coefficients of correlation (instead of Pearson coefficients of correlation), {it:v2} for a modified
 algorithm wich search to minimize the maximum second eigenvalue among the clusters of 2 variables and more, {it:polychoricv2} which correspond to the {it:v2}
 option with the matrix of polychoric coefficients of correlation,  and {it:centroid} which is defined by Vigneau and Qannari as an adaptation of CLV when
 the sign of the correlation coefficients between the variables is important.

{p 4 8 2}{cmd:consolidation} performs a consolidation procedure with the obtained partition into the specified number of clusters (by default, no consolidation procedure is performed).

{p 4 8 2}{cmd:genlv} saves the latent variables in new variables with the defined string as prefix (followed by a number). This option must be used in conjonction with the {cmd:consolidation} option.

{p 4 8 2}{cmd:replace} allows replacing the created variables with the {cmd:genlv} option if they already exist.

{p 0 8 2}{cmd:Options concerning the drawing of the dendrogram}

{p 4 8 2}{cmd:nodendro} avoids to display of the dendrogram.

{p 4 8 2}{cmd:savedendro} saves the dendrogram in the file defined by this option. If this file already exists, it is possible to replace it with the {cmd:replace} option.

{p 4 8 2}{cmd:cutnumber} defines the maximal number of clusters displayed in the dendrogram (40 by default).

{p 4 8 2}{cmd:showcount} displays the number of variables in each cluster (useful with the {cmd:cutnumber} option).

{p 4 8 2}{cmd:textsize} defines the size of the labels of the variables on the dendrogram (see {help textsizestyle}).

{p 4 8 2}{cmd:deltaT} uses the variation of the T criterion as height variable for the dendrogram.

{p 4 8 2}{cmd:horizontal} displays an horizontal (instead a vertical) dendrogram.

{p 4 8 2}{cmd:abbrev} defines the length of the variables labels on the dendrogram (15 characters by default).

{p 4 8 2}{cmd:title} defines the title of the dendrogram.

{p 4 8 2}{cmd:caption} defines the caption of the axis of the dendrogram which indicates the names of the variables.

{p 0 8 2}{cmd:Options concerning the others graphs}

{p 4 8 2}{cmd:bar} displays a chart of the decrease in the T criterion at each step.

{p 4 8 2}{cmd:nobiplot} avoids to display a biplot of the latent variables with the {cmd:consolidation} option.

{p 4 8 2}{cmd:addvar} allows drawing the items on the graphical representation on the biplot.

{p 4 8 2}{cmd:std} allows standardizing the latent variables for the graphical representation on the biplot.

{p 4 8 2}{cmd:dim}({it:string}) allows choosing the axes represented on the biplot.

{p 4 8 2}{cmd:filesave} allows saving the graphs in gph files on the default directory or on the directory defined by the {cmd:dirsave} option.

{p 4 8 2}{cmd:dirsave}({it:string}) allows determining the directory to save the graphs (usefull with the {cmd:filesave} option).

{p 4 8 2} If no {it:varlist} is indicated, the procedure uses the varlist from the last {cmd:clv} procedure, but does not perform the hierarchical cluster analysis.

{title:Notes}

{p 4 8 2} The classifications around latent variables (CLV) is defined by its authors (Vigneau and Qannari, 2003) only for continuous variables. Results with binary or ordinal variables must be interpreted with precautions.

{p 4 8 2} Only {cmd:fweights} are allowed. The biplots are disabled if weights are used.

{p 4 8 2} In this procedure, all the individuals with at least one missing value are omitted.

{p 4 8 2} With the {it:polychoric} and {it:polychoricv2} methods, the {cmd:nostandardized} option is disabled.

{p 4 8 2} This module uses the following modules downloadable on SSC: {stata ssc describe polychoric}, {stata ssc describe biplotvlab} and {stata ssc describe genscore}

{title:Example}

	{p 4 8 2}{cmd:. clv var1-var15} /*performs the HCA procedure*/

	{p 4 8 2}{cmd:. clv var1-var15, cons(6) bar nodendro meth(centroid)} /* performs the HCA procedure based on the centroid method followed by a consolidation procedure with 6 clusters*/

	{p 4 8 2}{cmd:. clv, cons(3)  addvar} /*performs only the consolidation procedure with 3 clusters, based on the preceeding HCA procedure*/

{title:Aknowledgements}

{p 4 8 2} The author thanks Ronan Conroy for all the propositions of improvements.

{title:Reference}

{p 4 8 2} Vigneau E. and Qannari E. M. Clustering of variables around latent components. Communications in Statistics - Simulation and Computation. 32(4): 1131-1150, 2003.

{title:Author}

{p 4 8 2}Jean-Benoit Hardouin, PhD, assistant professor{p_end}
{p 4 8 2}INSERM UMR 1246-SPHERE "MethodS in Patients-centered outcomes and HEalth ResEarch"{p_end}
{p 4 8 2}Nantes University - University of Tours{p_end}
{p 4 8 2}Institute for Research in Health 2 (IRS2), Nantes, France{p_end}
{p 4 8 2}Email:
{browse "mailto:jean-benoit.hardouin@univ-nantes.fr":jean-benoit.hardouin@univ-nantes.fr}{p_end}
{p 4 8 2}Website {browse "http://www.anaqol.org":AnaQol}
